extends Node
## Backend realization only. Requesters retain track choice and continuation.
signal boundary(result: Dictionary)
const Native = preload("res://scripts/data/native_media.gd")
const Instances = preload("res://scripts/av/replacement_instances.gd")
var media: RefCounted
var core: RefCounted
var preferences: RefCounted
var _instances: Dictionary = {}
var _serial := 0
var _fade: Dictionary = {}
var _retired: Array = []
var _closing := false
var _music_gain := 1.0
var measurements := {"prepared":0,"retired":0,"peak_instances":0,"underruns":0,"peak_prepare_microseconds":0,"requested_buffer_seconds":0.25,"peak_buffer_frames":0,"peak_buffer_seconds":0.0}

func request(target: String, type: String, scope: Dictionary, loop := false) -> Dictionary:
	if media == null or type not in ["audio","midi"]: return Native.failure("invalid_request","Explicit committed audio/MIDI target required.")
	var resolved: Dictionary = media.resolve(target,type)
	if not resolved.ok: return resolved
	return admit(resolved,type,scope,loop)

func admit(resolved: Dictionary, type: String, scope: Dictionary, loop := false) -> Dictionary:
	if _closing: return Native.failure("closing","Music playback is shutting down.")
	if not resolved.get("ok",false) or scope.get("attempt","").is_empty() or scope.get("operation","").is_empty() or not scope.get("session",null) is String: return Native.failure("invalid_request","Playback requires original attempt/session/operation identity.")
	if not scope.session.is_empty() and (core==null or core.snapshot().session!=scope.session): return Native.failure("stale","Original music session has retired.")
	var began := Time.get_ticks_usec()
	var player: AudioStreamPlayer
	var native: RefCounted
	var captured := {}
	var resource: Dictionary = resolved.get("resource",{})
	if type == "audio":
		var prepared := Instances.audio(resolved,loop)
		if not prepared.ok: return prepared
		player = prepared.player
	elif type == "midi":
		if resource.is_empty() and resolved.get("value") is RefCounted:
			var classic: Dictionary = resolved.value.projection()
			if classic.get("domain") != "sequence": return Native.failure("wrong_type","Classic MIDI sequence required.")
			resource = Native.midi(classic.smf)
			if not resource.ok: return resource
		if loop and int(resource.get("sample_frames",0))<=0: return Native.failure("unsupported","Looping requires a positive whole-score sample duration.")
		captured = preferences.capture() if preferences != null else Native.default_bank()
		if not captured.ok: return captured
		var presets := str(captured.get("presets","")).split(",",false)
		for required: String in resource.get("required_presets",[]):
			if not presets.has(required): return Native.failure("unsupported_bank","Captured bank lacks requested GS preset "+required+"; no implicit instrument substitution.")
		native = Native.adapter()
		if native == null: return Native.failure("backend_unavailable","MIDI extension unavailable.")
		var prepared: Dictionary = native.invoke("midi",resource.bytes,captured.bytes,1 if loop else 0)
		if not prepared.ok: return prepared
		player = AudioStreamPlayer.new()
		var generator := AudioStreamGenerator.new()
		generator.mix_rate = 48000
		# The earlier 120 ms buffer ran dry during real bank preparation in the
		# rendered fixture. This bounded 250 ms buffer is measured again there.
		generator.buffer_length = 0.25
		player.stream = generator
	else: return Native.failure("wrong_type","Audio/MIDI playback type required.")
	_serial += 1
	var id := "music-%d" % _serial
	var instance := {"id":id,"scope":scope.duplicate(true),"player":player,"native":native,"type":type,"bank":captured.get("identity",{}).duplicate(true),"source":resolved.get("provenance",{}).duplicate(true),"gain":0.0,"paused":false,"ended":false,"submitted":0,"loop":loop,"duration_frames":resource.get("sample_frames",0),"boundaries":0}
	_instances[id] = instance
	add_child(player)
	player.volume_db = -80
	player.finished.connect(func(): _natural_end(id))
	player.play()
	if type == "midi": player.stream_paused = true
	instance.playback = weakref(player.get_stream_playback()) if player.playing else null
	if type == "midi": instance.capacity = player.get_stream_playback().get_frames_available()
	if type == "midi":
		measurements.peak_buffer_frames = maxi(measurements.peak_buffer_frames,instance.capacity)
		measurements.peak_buffer_seconds = maxf(measurements.peak_buffer_seconds,float(instance.capacity)/48000)
	if type == "midi": _pump(instance)
	if type == "midi": player.stream_paused = false
	measurements.prepared += 1
	measurements.peak_prepare_microseconds = maxi(measurements.peak_prepare_microseconds,Time.get_ticks_usec()-began)
	measurements.peak_instances = maxi(measurements.peak_instances,_instances.size())
	return {"ok":true,"id":id,"scope":scope.duplicate(true),"bank":instance.bank.duplicate(true),"prepare_microseconds":Time.get_ticks_usec()-began}

func handoff(incoming: String, seconds: float) -> Dictionary:
	if not _instances.has(incoming) or not is_finite(seconds) or seconds<0: return Native.failure("invalid_request","Prepared incoming playback and finite nonnegative fade required.")
	var gains := {}
	for id: String in _instances: gains[id] = _instances[id].gain
	_fade = {"incoming":incoming,"seconds":seconds,"elapsed":0.0,"from":gains}
	if seconds == 0: _advance_fade(0)
	return {"ok":true}

func gain(id: String, value: float) -> bool:
	if not _instances.has(id) or not is_finite(value) or value<0 or value>1: return false
	_instances[id].gain = value
	_apply_volume(_instances[id])
	return true

func _apply_volume(instance: Dictionary) -> void:
	var value: float = instance.gain*_music_gain
	instance.player.volume_db = linear_to_db(value) if value>0 else -80

func set_music_gain(value: float) -> bool:
	if not is_finite(value) or value<0 or value>1: return false
	_music_gain = value
	for instance: Dictionary in _instances.values(): _apply_volume(instance)
	return true

func _advance_fade(delta: float) -> void:
	if _fade.is_empty(): return
	if _instances.has(_fade.incoming) and _instances[_fade.incoming].paused: return
	_fade.elapsed += delta
	var fraction := minf(1.0,_fade.elapsed/_fade.seconds) if _fade.seconds>0 else 1.0
	for id: String in _fade.from:
		if _instances.has(id): gain(id,lerpf(_fade.from[id],1.0 if id==_fade.incoming else 0.0,fraction))
	if fraction == 1:
		var keep: String = _fade.incoming
		_fade.clear()
		for id: String in _instances.keys():
			if id != keep: retire(id,"Replaced")

func _pump(instance: Dictionary) -> void:
	var playback: AudioStreamGeneratorPlayback = instance.player.get_stream_playback()
	if playback == null: return
	measurements.underruns = maxi(measurements.underruns,playback.get_skips())
	var available := playback.get_frames_available()
	while available>0 and not instance.ended:
		var count := mini(available,1024)
		var decoded: Dictionary = instance.native.invoke("render",count)
		if not decoded.ok:
			retire(instance.id,"Failed",decoded.reason)
			return
		var samples: PackedFloat32Array = decoded.pcm.to_float32_array()
		var frames := PackedVector2Array()
		frames.resize(count)
		for index in count: frames[index] = Vector2(samples[index*2],samples[index*2+1])
		if not playback.push_buffer(frames):
			retire(instance.id,"Failed","Audio generator rejected prepared frames.")
			return
		instance.submitted += count
		instance.ended = decoded.ended
		if instance.ended: instance.source_end = instance.submitted
		available -= count
	if instance.ended: _drain_midi(instance,playback)
	if instance.loop and instance.duration_frames>0:
		var presented: int = maxi(0,instance.submitted-instance.capacity+playback.get_frames_available())
		while _instances.has(instance.id) and presented >= (instance.boundaries+1)*instance.duration_frames:
			instance.boundaries += 1
			boundary.emit({"id":instance.id,"scope":instance.scope.duplicate(true),"kind":"LoopBoundary","sequence":instance.boundaries,"sample":instance.boundaries*instance.duration_frames})

func _drain_midi(instance: Dictionary, playback: AudioStreamGeneratorPlayback) -> void:
	var consumed: int = instance.submitted-instance.capacity+playback.get_frames_available()
	var presented := float(consumed)+(AudioServer.get_time_since_last_mix()-AudioServer.get_output_latency())*48000
	if presented>=instance.source_end:
		_natural_end(instance.id)
		return
	# Silence keeps the device clock moving after the final synthesized frame.
	# Stop at its presentation boundary rather than waiting for an empty mixer.
	var tail_end: int = instance.source_end+ceili(AudioServer.get_output_latency()*48000)+instance.capacity
	var count := mini(playback.get_frames_available(),tail_end-instance.submitted)
	if count>0:
		var silence := PackedVector2Array()
		silence.resize(count)
		if playback.push_buffer(silence): instance.submitted+=count

func _natural_end(id: String) -> void:
	if not _instances.has(id): return
	var instance: Dictionary = _instances[id]
	if instance.loop: return
	retire(id,"Finished")

func retire(id: String, kind := "Cancelled", reason := "") -> bool:
	if not _instances.has(id): return false
	var instance: Dictionary = _instances[id]
	_instances.erase(id)
	var released: WeakRef = instance.get("playback")
	instance.player.stop()
	instance.player.stream = null
	instance.player.queue_free()
	if instance.native != null: instance.native.invoke("close")
	measurements.retired += 1
	_retired.append({"playback":released,"result":{"id":id,"scope":instance.scope.duplicate(true),"kind":kind,"reason":reason}})
	return true

func _flush_retired() -> void:
	for index in range(_retired.size()-1,-1,-1):
		var retired: Dictionary = _retired[index]
		if retired.playback != null and retired.playback.get_ref()!=null: continue
		_retired.remove_at(index)
		boundary.emit(retired.result)

func pending_retirements() -> int:
	return _retired.size()

func settle() -> Dictionary:
	var deadline := Time.get_ticks_msec()+2000
	while not _retired.is_empty() and Time.get_ticks_msec()<deadline:
		_flush_retired()
		if not _retired.is_empty(): await get_tree().process_frame
	return {"ok":_retired.is_empty(),"reason":"" if _retired.is_empty() else "The engine audio mixer has not released retired playback."}

func shutdown() -> Dictionary:
	_closing = true
	_fade.clear()
	for id: String in _instances.keys(): retire(id)
	return await settle()

func retire_scope(session: String) -> void:
	for id: String in _instances.keys():
		if _instances[id].scope.session == session: retire(id)

func pause(id: String, value: bool) -> bool:
	if not _instances.has(id): return false
	_instances[id].paused = value
	_instances[id].player.stream_paused = value
	return true

func projection() -> Dictionary:
	var out := {}
	for id: String in _instances:
		var item: Dictionary = _instances[id]
		out[id] = {"scope":item.scope.duplicate(true),"bank":item.bank.duplicate(true),"source":item.source.duplicate(true),"gain":item.gain,"paused":item.paused,"submitted":item.submitted}
	return out

func _process(delta: float) -> void:
	_flush_retired()
	_advance_fade(delta)
	for id: String in _instances.keys():
		if _instances.has(id) and _instances[id].type=="midi" and not _instances[id].paused: _pump(_instances[id])

func _exit_tree() -> void:
	_fade.clear()
	for id: String in _instances.keys(): retire(id)
