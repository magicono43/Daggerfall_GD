extends Control
## One independently scoped cinematic consumer. Requesters own continuation.
signal terminal(result: Dictionary)
signal input_released(event: InputEvent)
const Native = preload("res://scripts/data/native_media.gd")
const Classic = preload("res://scripts/data/classic_vid.gd")
const Images = preload("res://scripts/data/classic_image.gd")
const PROGRESS_BUDGET_MSEC := 5000
var media: RefCounted
var core: RefCounted
var windows: RefCounted
var preferences: RefCounted
var ambience: RefCounted
var _attempt: Dictionary = {}
var _held: Dictionary = {}
var _handoff_keys: Dictionary = {}

func owns_scope(scope: Dictionary) -> bool:
	return _attempt.get("scope",{}) == scope or _ending.get("attempt",{}).get("scope",{}) == scope

func fence_initial_input(keys: Dictionary) -> void:
	# Transfer only physical input already consumed by the initial sequence.
	# Merge with playback-owned fences; a later release retires each key once.
	for key: String in keys: _handoff_keys[key] = true
var _classic_thread: Thread
var _mutex := Mutex.new()
var _classic_queue: Array = []
var _classic_done := false
var _classic_failure := ""
var _cancelled := false
var _picture: Dictionary = {}
var _sound: Dictionary = {}
var _rect: TextureRect
var _player: AudioStreamPlayer
var _submitted := 0
var _audio_capacity := 0
var _audio_playback: WeakRef
var _audio_rate := 48000
var _audio_started := false
var _video_started_usec := 0
var _ending: Dictionary = {}
var _clock := 0.0
var _video_drained := false
var _audio_drained := false
var _last_picture := -1.0
var measurements := {"frames":0,"dropped_frames":0,"underruns":0,"peak_classic_queue":0,"terminals":0,"peak_audio_buffer_frames":0,"peak_audio_buffer_seconds":0.0,"presented_markers":[]}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	var background := ColorRect.new()
	background.color = Color.BLACK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_rect = TextureRect.new()
	_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)
	_player = AudioStreamPlayer.new()
	add_child(_player)
	visible = false

func request(target: String, scope: Dictionary, current: Callable, skip := "any", flow := "cinematic", ambience_gain := 0.0) -> Dictionary:
	if flow not in ["cinematic","startup","death"] or not is_finite(ambience_gain) or ambience_gain<0 or ambience_gain>1: return Native.failure("invalid_request","Unsupported owner flow or ambience policy.")
	if flow in ["startup","death"]: skip = "any"
	elif preferences != null and preferences.settings != null:
		var preferred := str(preferences.settings.effective.get(preferences.SKIP_SETTING,"authored"))
		if preferred!="authored": skip = preferred
	var resolved: Dictionary = media.resolve(target,"video")
	if not resolved.ok: return resolved
	if resolved.resource.has("classic_source"): return _classic_source(resolved.resource.classic_source,scope,current,float(resolved.resource.aspect),skip)
	return admit(resolved.resource,scope,current,skip,resolved.provenance,ambience_gain)

func _begin(scope: Dictionary, current: Callable, skip: String) -> Dictionary:
	if not _attempt.is_empty() or not _ending.is_empty(): return Native.failure("busy","This consumer already owns a cinematic attempt or cleanup.")
	if skip not in ["any","skip","back","none"] or not current.is_valid() or not current.call(scope.duplicate(true)) or scope.get("attempt","").is_empty() or scope.get("operation","").is_empty() or not scope.get("session",null) is String: return Native.failure("stale","Original current attempt/session/operation required.")
	var opened: Dictionary = windows.open("cinematic",scope.session,{"cursor":"hidden","required_choice":true})
	if opened.kind != "applied": return Native.failure(opened.kind,"Cinematic input scope could not be acquired.")
	_attempt = {"scope":scope.duplicate(true),"current":current,"skip":skip,"window":opened.id,"hud":core.gates.acquire(opened.id,scope.session,["hud"]),"native":null,"classic":false,"ready":false,"aspect":1.0,"audio":false,"seconds":0.0}
	_attempt.preparation_started_msec = Time.get_ticks_msec()
	_attempt.last_progress_msec = _attempt.preparation_started_msec
	_attempt.ambience = ambience.acquire(opened.id,scope.session,0.0) if ambience != null else 0
	_cancelled = false
	_classic_done = false
	_classic_failure = ""
	_submitted = 0
	_clock = 0
	_last_picture = -1
	_video_drained = false
	_audio_drained = false
	_picture.clear()
	_sound.clear()
	measurements.presented_markers.clear()
	visible = true
	return {"ok":true,"kind":"preparing","scope":scope.duplicate(true)}

func admit(resource: Dictionary, scope: Dictionary, current: Callable, skip := "any", provenance: Dictionary = {}, ambience_gain := 0.0) -> Dictionary:
	var began := _begin(scope,current,skip)
	if not began.ok: return began
	_attempt.provenance = provenance.duplicate(true)
	if ambience != null and ambience_gain!=0:
		ambience.release(_attempt.ambience,_attempt.window)
		_attempt.ambience = ambience.acquire(_attempt.window,scope.session,ambience_gain)
	_attempt.native = Native.adapter()
	if _attempt.native == null:
		_finish("Failed","Native video extension unavailable.")
		return Native.failure("backend_unavailable","Native video extension unavailable.")
	var prepared: Dictionary = _attempt.native.invoke("video",resource.bytes,resource.profile,16)
	if not prepared.ok: _finish("Failed",prepared.reason)
	return prepared

func request_classic(access: RefCounted, file: String, scope: Dictionary, current: Callable, aspect: float, skip := "any") -> Dictionary:
	if not is_finite(aspect) or aspect<=0: return Native.failure("invalid_request","Classic caller must supply its verified display aspect.")
	var source: Dictionary = access.video_source(file)
	return _classic_source(source,scope,current,aspect,skip)

func request_death_classic(access: RefCounted, scope: Dictionary, current: Callable) -> Dictionary:
	if not _attempt.is_empty() or not _ending.is_empty(): return Native.failure("busy","Playback or cleanup already owns this consumer.")
	if not current.is_valid() or not current.call(scope.duplicate(true)): return Native.failure("stale","Current CORE death presentation required.")
	return _classic_source(access.death_video_source(),scope,current,1.6,"any")

func _classic_source(source: Dictionary, scope: Dictionary, current: Callable, aspect: float, skip: String) -> Dictionary:
	if not source.ok: return source
	var began := _begin(scope,current,skip)
	if not began.ok: return began
	_attempt.classic = true
	_attempt.aspect = aspect
	_attempt.audio = true
	_attempt.provenance = {"source":source.source,"converter":source.converter,"sha256":Native.digest(source.bytes)}
	_classic_thread = Thread.new()
	var started := _classic_thread.start(func():
		var outcome := Classic.new().decode(source.bytes,-1,func(frame: Dictionary): return _enqueue_classic(frame))
		_mutex.lock()
		_classic_done = true
		_classic_failure = "" if outcome.ok or outcome.get("kind")=="cancelled" else outcome.reason
		_mutex.unlock())
	if started != OK:
		_finish("Failed","Classic decode worker could not start.")
		return Native.failure("preparation_failed","Classic decode worker could not start.")
	return began

func _enqueue_classic(frame: Dictionary) -> bool:
	var image := Images.new().rgba(frame,{"ok":true,"rgb":frame.palette_rgb},-1)
	if not image.ok: return false
	var packet := {"rgba":image.rgba,"width":image.width,"height":image.height,"pts":float(frame.presentation_sample)/11025,"samples":frame.audio,"frame":frame.frame,"source_position":frame.position,"raw_delay":frame.frame_delay_source}
	while true:
		_mutex.lock()
		if _cancelled:
			_mutex.unlock()
			return false
		if _classic_queue.size()<16:
			_classic_queue.append(packet)
			measurements.peak_classic_queue = maxi(measurements.peak_classic_queue,_classic_queue.size())
			_mutex.unlock()
			return true
		_mutex.unlock()
		OS.delay_msec(1)
	return false

func _start_audio(rate := 48000) -> void:
	_audio_rate = rate
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = rate
	generator.buffer_length = 0.25
	_player.stream = generator
	_player.play()
	var playback: AudioStreamGeneratorPlayback = _player.get_stream_playback()
	_audio_capacity = playback.get_frames_available() if playback != null else 0
	measurements.peak_audio_buffer_frames = maxi(measurements.peak_audio_buffer_frames,_audio_capacity)
	measurements.peak_audio_buffer_seconds = maxf(measurements.peak_audio_buffer_seconds,float(_audio_capacity)/rate)
	_audio_playback = weakref(playback) if playback != null else null
	_player.stream_paused = true
	_audio_started = false

func _resume_audio(minimum_frames: int) -> void:
	if _audio_started: return
	var playback: AudioStreamGeneratorPlayback = _player.get_stream_playback()
	if playback != null and _audio_capacity-playback.get_frames_available()>=minimum_frames:
		_audio_started = true
		_attempt.last_progress_msec = Time.get_ticks_msec()
		_player.stream_paused = false

func _timeline(_delta: float) -> void:
	var previous := _clock
	if _attempt.audio:
		if not _audio_started: return
		var playback: AudioStreamGeneratorPlayback = _player.get_stream_playback()
		if playback != null:
			var queued := _audio_capacity-playback.get_frames_available()
			var consumed := maxi(0,_submitted-queued)
			var presented := 0.0 if consumed==0 else minf(float(_submitted)/_audio_rate,float(consumed)/_audio_rate+AudioServer.get_time_since_last_mix()-AudioServer.get_output_latency())
			_clock = maxf(_clock,maxf(0,presented))
			if playback.get_skips()>measurements.underruns:
				measurements.underruns = playback.get_skips()
				measurements.underrun_attempt = _attempt.scope.attempt
	else: _clock = float(Time.get_ticks_usec()-_video_started_usec)/1000000.0
	if _clock>previous: _attempt.last_progress_msec = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if not _ending.is_empty():
		_release_context()
		return
	if _attempt.is_empty(): return
	if not _attempt.current.is_valid() or not _attempt.current.call(_attempt.scope.duplicate(true)) or (not _attempt.scope.session.is_empty() and core.snapshot().session!=_attempt.scope.session) or windows.top().get("id")!=_attempt.window:
		_finish("Cancelled","Owning attempt, session, operation or input context retired.")
		return
	if (not _attempt.ready or (_attempt.audio and not _audio_started)) and Time.get_ticks_msec()-_attempt.preparation_started_msec>PROGRESS_BUDGET_MSEC:
		_finish("Failed","First-buffer preparation exceeded the 5000 ms consumer budget.")
		return
	if _attempt.ready and Time.get_ticks_msec()-_attempt.last_progress_msec>PROGRESS_BUDGET_MSEC:
		_finish("Failed","Playback presentation made no progress for 5000 ms.")
		return
	if _attempt.classic:
		_process_classic(delta)
		return
	if not _attempt.ready:
		var state: Dictionary = _attempt.native.invoke("video_status")
		if not state.ok:
			_finish("Failed",state.reason)
			return
		if state.kind == "preparing": return
		_attempt.aspect = state.aspect
		_attempt.audio = not state.audio_codec.is_empty()
		_attempt.seconds = state.seconds
		_attempt.metadata = state
		if _picture.is_empty():
			var first: Dictionary = _attempt.native.invoke("picture")
			if not first.ok:
				_finish("Failed",first.reason)
				return
			if not first.has("bytes"): return
			_picture = first
		if _attempt.audio and _sound.is_empty():
			var first: Dictionary = _attempt.native.invoke("sound")
			if not first.ok:
				_finish("Failed",first.reason)
				return
			if not first.has("bytes"): return
			_sound = {"values":first.bytes.to_float32_array(),"offset":0,"pts":first.pts}
		_attempt.ready = true
		_video_started_usec = Time.get_ticks_usec()
		if _attempt.audio: _start_audio()
	if _attempt.audio: _pump_audio()
	if _attempt.is_empty(): return
	if _attempt.audio: _resume_audio(_audio_capacity)
	_timeline(delta)
	var latest := {}
	while true:
		if _picture.is_empty():
			var popped: Dictionary = _attempt.native.invoke("picture")
			if not popped.ok:
				_finish("Failed",popped.reason)
				return
			_video_drained = popped.drained
			if not popped.has("bytes"): break
			_picture = popped
		if _picture.pts > _clock+0.001: break
		if not latest.is_empty(): measurements.dropped_frames += 1
		latest = _picture
		_picture = {}
	if not latest.is_empty(): _present(latest.bytes,_attempt.metadata.width,_attempt.metadata.height,latest.pts)
	if _video_drained and (not _attempt.audio or _audio_drained) and _clock>=_attempt.seconds-1.0/48000.0: _finish("Finished")

func _pump_audio() -> void:
	var playback: AudioStreamGeneratorPlayback = _player.get_stream_playback()
	while playback != null and playback.get_frames_available()>0:
		if _sound.is_empty():
			var popped: Dictionary = _attempt.native.invoke("sound")
			if not popped.ok:
				_finish("Failed",popped.reason)
				return
			_audio_drained = popped.drained
			if not popped.has("bytes"): break
			_sound = {"values":popped.bytes.to_float32_array(),"offset":0,"pts":popped.pts}
		if _sound.values.is_empty():
			_sound.clear()
			continue
		var source_sample := roundi(float(_sound.pts)*_audio_rate)+int(_sound.offset)
		if source_sample>_submitted:
			var gap := PackedVector2Array()
			gap.resize(mini(playback.get_frames_available(),source_sample-_submitted))
			if not playback.push_buffer(gap): break
			_submitted += gap.size()
			continue
		if source_sample<_submitted:
			# Codec priming/overlap is trimmed against normalized packet PTS.
			_sound.offset += mini(_submitted-source_sample,_sound.values.size()/2-_sound.offset)
			if _sound.offset*2==_sound.values.size():
				_sound.clear()
				continue
		var take := mini(playback.get_frames_available(),_sound.values.size()/2-_sound.offset)
		var frames := PackedVector2Array()
		frames.resize(take)
		for index in take:
			var at: int = (_sound.offset+index)*2
			frames[index] = Vector2(_sound.values[at],_sound.values[at+1])
		if take == 0 or not playback.push_buffer(frames): break
		_submitted += take
		_sound.offset += take
		if _sound.offset*2 == _sound.values.size(): _sound.clear()
	# Finite audio clock must reach authored video duration even for a short last
	# audio packet. Padding is explicit silence, never duplicated source samples.
	var tail_end := ceili((_attempt.seconds+AudioServer.get_output_latency())*48000)+_audio_capacity
	if _audio_drained and _sound.is_empty() and _submitted<tail_end:
		# Continue the mixer clock through the final device-latency interval.
		# The caller still finishes at authored duration; this tail is silence.
		var count := mini(playback.get_frames_available(),tail_end-_submitted)
		if count>0:
			var silence := PackedVector2Array()
			silence.resize(count)
			if playback.push_buffer(silence): _submitted+=count

func _process_classic(delta: float) -> void:
	_mutex.lock()
	var done := _classic_done
	var issue := _classic_failure
	if _picture.is_empty() and not _classic_queue.is_empty(): _picture = _classic_queue.pop_front()
	var drained := done and _classic_queue.is_empty()
	_mutex.unlock()
	if not issue.is_empty():
		_finish("Failed",issue)
		return
	if not _attempt.ready:
		if _picture.is_empty(): return
		_attempt.ready = true
		_start_audio(11025)
	_timeline(delta)
	if not _picture.is_empty():
		var playback: AudioStreamGeneratorPlayback = _player.get_stream_playback()
		var samples: PackedByteArray = _picture.samples
		var count := samples.size()
		var offset: int = _picture.get("sample_offset",0)
		var take := mini(playback.get_frames_available(),count-offset)
		if take>0:
			var frames := PackedVector2Array()
			frames.resize(take)
			for index in take:
				var value := (float(samples[offset+index])-128.0)/128.0
				frames[index] = Vector2(value,value)
			if playback.push_buffer(frames):
				_submitted += take
				_picture.sample_offset = offset+take
				_resume_audio(1)
		if not _picture.get("presented",false) and _picture.pts<=_clock+0.001:
			_present(_picture.rgba,_picture.width,_picture.height,_picture.pts)
			_attempt.seconds = _picture.pts+float(samples.size())/11025
			_picture.presented = true
		if _picture.get("presented",false) and _picture.get("sample_offset",0)>=count:
			_picture.clear()
	if drained and _picture.is_empty():
		var playback: AudioStreamGeneratorPlayback = _player.get_stream_playback()
		var tail_end := ceili((_attempt.seconds+AudioServer.get_output_latency())*_audio_rate)+_audio_capacity
		var count := mini(playback.get_frames_available(),tail_end-_submitted)
		if count>0:
			var silence := PackedVector2Array()
			silence.resize(count)
			if playback.push_buffer(silence): _submitted += count
		_resume_audio(1)
		if _clock>=_attempt.seconds-1.0/_audio_rate: _finish("Finished")

func _present(bytes: PackedByteArray, width: int, height: int, pts: float) -> void:
	var image := Image.create_from_data(width,height,false,Image.FORMAT_RGBA8,bytes)
	_rect.texture = ImageTexture.create_from_image(image)
	var w := minf(size.x,size.y*_attempt.aspect)
	_rect.size = Vector2(w,w/_attempt.aspect)
	_rect.position = (size-_rect.size)/2
	_last_picture = pts
	measurements.frames += 1
	measurements.presented_markers.append({"source_pts":pts,"presentation_clock":_clock})
	if measurements.presented_markers.size()>1024: measurements.presented_markers.pop_front()

func _input(event: InputEvent) -> void:
	var key := ""
	if event is InputEventKey: key = "key:"+str(event.physical_keycode if event.physical_keycode!=0 else event.keycode)
	elif event is InputEventMouseButton: key = "mouse:"+str(event.button_index)
	elif event is InputEventJoypadButton: key = "joy:%d:%d" % [event.device,event.button_index]
	else: return
	var held: bool = _held.has(key)
	if event.is_pressed(): _held[key] = true
	else:
		_held.erase(key)
		input_released.emit(event) # Observation only; covered UI never receives an activation.
	if _handoff_keys.has(key) or not _ending.is_empty():
		if event.is_pressed(): _handoff_keys[key] = true
		else: _handoff_keys.erase(key)
		get_viewport().set_input_as_handled()
		return
	if _attempt.is_empty(): return
	get_viewport().set_input_as_handled()
	if not event.is_pressed() or held or event.is_echo(): return
	var eligible: bool = _attempt.skip=="any" or (_attempt.skip=="skip" and event.is_action_pressed("ui_accept")) or (_attempt.skip=="back" and event.is_action_pressed("ui_cancel"))
	if eligible: _finish("Skipped")

func cancel(scope: Dictionary) -> bool:
	if _attempt.is_empty() or _attempt.scope!=scope: return false
	_finish("Cancelled")
	return true

func retire_scope(session: String) -> void:
	if not _attempt.is_empty() and _attempt.scope.session==session: _finish("Cancelled","Owning session retired.")

func _finish(kind: String, reason := "") -> void:
	if _attempt.is_empty(): return
	_handoff_keys = _held.duplicate()
	var attempt := _attempt
	_attempt = {} # Reentrant/late completion cannot settle the attempt twice.
	_mutex.lock()
	_cancelled = true
	_mutex.unlock()
	if attempt.native != null: attempt.native.invoke("close")
	if _classic_thread != null and _classic_thread.is_started(): _classic_thread.wait_to_finish()
	_classic_thread = null
	_mutex.lock()
	_classic_queue.clear()
	_mutex.unlock()
	var released: WeakRef = _audio_playback
	_audio_playback = null
	_player.stop()
	_player.stream = null
	_rect.texture = null
	_picture.clear()
	_sound.clear()
	visible = false
	_ending = {"attempt":attempt,"playback":released,"result":{"kind":kind,"reason":reason,"scope":attempt.scope.duplicate(true),"source":attempt.get("provenance",{}).duplicate(true)}}
	_release_context()

func _release_context() -> void:
	if _ending.is_empty(): return
	if _ending.playback != null and _ending.playback.get_ref()!=null: return
	var attempt: Dictionary = _ending.attempt
	var removed: Dictionary = windows.retire_layer(attempt.window,attempt.scope.session)
	if removed.kind == "busy": return
	core.gates.release(attempt.hud,attempt.window)
	if ambience != null: ambience.release(attempt.ambience,attempt.window)
	var result: Dictionary = _ending.result
	_ending.clear()
	measurements.terminals += 1
	terminal.emit(result)

func _exit_tree() -> void:
	_finish("Cancelled","Application shutdown.")

func shutdown() -> Dictionary:
	_finish("Cancelled","Application shutdown.")
	var deadline := Time.get_ticks_msec()+2000
	while not _ending.is_empty() and Time.get_ticks_msec()<deadline:
		_release_context()
		if not _ending.is_empty(): await get_tree().process_frame
	return {"ok":_ending.is_empty(),"reason":"" if _ending.is_empty() else "Video audio/input cleanup has not settled."}
