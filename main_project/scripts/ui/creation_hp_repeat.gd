extends Node
## One held mouse gesture survives repaint, but never a creator/page retirement.
## Shared HP/attribute arrows; user-selected faster cadence than DFU's 0.3 s.
const INTERVAL_MSEC = 150
var _view: WeakRef
var direction := 0
var _draft := ""
var _next_tick := 0
var _pointer := Vector2.ZERO
var _attribute := ""

func _ready() -> void:
	set_process(false)

func begin(view: RefCounted, step: int, pointer: Vector2, attribute := "") -> void:
	_view = weakref(view)
	_draft = str(view.owner.token().id)
	direction = step
	_pointer = pointer
	_attribute = attribute
	set_process(true)
	_step()
	_next_tick = Time.get_ticks_msec()+INTERVAL_MSEC

func stop() -> void:
	direction = 0
	_view = null
	set_process(false)

func _input(event: InputEvent) -> void:
	if direction == 0: return
	if event is InputEventMouseMotion: _pointer = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed: stop()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_CLOSE_REQUEST]: stop()

func _process(_delta: float) -> void:
	if direction == 0: return
	var view: RefCounted = _view.get_ref() if _view != null else null
	if view == null: stop(); return
	if not _current(view): stop(); return
	var id := ("hp/" if _attribute.is_empty() else "attribute/")+("up" if direction > 0 else "down")
	var control: Control = view._buttons.get(id)
	if not is_instance_valid(control) or control.disabled: stop(); return
	var local_pointer: Vector2 = control.get_global_transform_with_canvas().affine_inverse()*_pointer
	if not Rect2(Vector2.ZERO,control.size).has_point(local_pointer): stop(); return
	if Time.get_ticks_msec() >= _next_tick:
		_step()
		_next_tick = Time.get_ticks_msec()+INTERVAL_MSEC

func _current(view: RefCounted) -> bool:
	return view.active() and not view.shell.core.busy() and str(view.owner.token().id) == _draft and view.navigation.step().get("hook") == "custom" and not view.navigation.summary_locked() and view.career_view.custom_tab == 0 and view.career_view.skill_slot.is_empty() and view.career_view.custom_exit_message.is_empty() and (_attribute.is_empty() or preload("res://scripts/char/custom_career.gd").ATTRIBUTES[view.career_view.custom_attribute] == _attribute)

func _step() -> void:
	var view: RefCounted = _view.get_ref() if _view != null else null
	if view == null or not _current(view): stop(); return
	var candidate: Dictionary = view.owner.projection().selections.get("custom",{}).duplicate(true)
	if candidate.is_empty(): stop(); return
	var policy: Dictionary = view.inputs.policy.hp if _attribute.is_empty() else view.inputs.policy.attributes[_attribute]
	var old_value: int = candidate.hit_points_per_level if _attribute.is_empty() else candidate.attributes[_attribute]
	var value := clampi(old_value+direction,int(policy.min),int(policy.max))
	if value == old_value: stop(); return
	if _attribute.is_empty(): candidate.hit_points_per_level = value
	else: candidate.attributes[_attribute] = value
	var result: Dictionary = view.action("edit",view.navigation.context(),candidate)
	if result.ok: view.shell.host.controller.providers.creation_art.play_dialog_click(view.shell.host)
	else: stop()
