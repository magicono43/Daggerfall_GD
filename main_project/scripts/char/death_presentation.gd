extends ColorRect
## Observer clock is presentation time, independent of suspended simulation.
var shell: RefCounted
var scope := ""
var elapsed := 0.0
var policy: Dictionary = {}
var phase := "idle"
var _serial := 0
var audio: AudioStreamPlayer
var _held: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 90
	color = Color(0,0,0,0)
	visible = false
	audio = preload("res://scripts/av/death_audio.gd").new()
	add_child(audio)

func _input(event: InputEvent) -> void:
	# The later-created AV consumer observes physical holds first. Consume this
	# initial sequence's input before GUI/unhandled routing can activate a view.
	var key := ""
	if event is InputEventKey: key = "key:"+str(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
	elif event is InputEventMouseButton: key = "mouse:"+str(event.button_index)
	elif event is InputEventJoypadButton: key = "joy:%d:%d" % [event.device,event.button_index]
	var fenced: bool = _held.has(key)
	if phase == "initial" and event.is_pressed() and not key.is_empty(): _held[key] = true
	if not event.is_pressed(): _held.erase(key)
	if phase == "initial" or fenced: get_viewport().set_input_as_handled()

func observe(result: Dictionary) -> void:
	if result.get("phase") != "dead" or phase != "idle" or result.get("session") != shell.core.snapshot().session or shell.core.snapshot().status != "dead": return
	var found: Dictionary = shell.core.actors.definitions.query("actor.baseline","death","player")
	if not found.ok: return # Required policy is not a cosmetic resource failure.
	policy = found.record.value.duplicate(true)
	scope = result.session
	elapsed = 0
	phase = "initial"
	visible = true
	shell.view.death_lower(scope,0.0)
	audio.present(scope,policy.audio,shell.host.controller.providers.classic)

func advance(delta: float) -> void:
	if phase == "idle" or not is_finite(delta) or delta < 0: return
	var state: Dictionary = shell.core.snapshot()
	if state.session != scope or state.status != "dead":
		retire(scope)
		return
	if phase == "initial":
		elapsed = minf(60,elapsed+delta)
		var progress := clampf(elapsed/float(policy.fade_seconds),0,1) if policy.fade_seconds > 0 else 1.0
		color.a = progress
		shell.view.death_lower(scope,progress)
		if elapsed >= policy.return_seconds: phase = "return"
	if phase == "return": visible = false # Independent progress/recovery UI must remain usable while busy.
	if phase == "return" and not shell.core.busy() and not shell.core.cleanup_blocked():
		_serial += 1
		# CORE may retire this observer synchronously inside request(). Do not
		# write old phase/scope after returning from that foreign callback.
		shell.core.request({"id":"char-death-return-"+str(_serial),"mode":"death","origin":scope})

func retire(session: String) -> void:
	if session != scope: return
	if is_instance_valid(shell.video_playback):
		shell.video_playback.fence_initial_input(_held)
		_held.clear()
	shell.view.clear_death_view(scope)
	audio.retire(scope)
	scope = ""
	phase = "idle"
	color.a = 0
	visible = false
