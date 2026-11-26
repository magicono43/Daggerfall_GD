extends AudioStreamPlayer
## Narrow optional on-foot AV bridge; preparation is outside the physics path.
## At most one current cue per 100 ms of eligible time; obsolete audio is omitted.
var scope := ""
var streams: Dictionary = {}
var diagnostics: Array[String] = []
var submitted := 0
var omitted := 0
var _seen: Dictionary = {}
var _cooldown := 0.0
var gain := 1.0
var _voices: Array[AudioStreamPlayer] = []
var _voice_cursor := 0
var placement_serial := -1
var after_sequence := 0

func configure_response(response: Dictionary) -> void:
	gain = response.movement_audio_percent/100.0
	volume_linear = gain
	for voice in _voices: voice.volume_linear = gain

func reset_delivery(session: String, serial := -1, sequence := 0) -> void:
	if session != scope: return
	placement_serial = serial
	after_sequence = sequence
	for voice in _voices:
		voice.stop()
		voice.stream = null
	_seen.clear()
	_cooldown = 0.0

func prepare(session: String, policy: Dictionary, classic: RefCounted, serial := -1, sequence := 0) -> bool:
	retire(scope)
	scope = session
	placement_serial = serial
	after_sequence = sequence
	if not preload("res://scripts/data/movement_feedback_policy.gd").reason(policy).is_empty(): return false
	if _voices.is_empty():
		_voices.append(self)
		for index in 3:
			var voice := AudioStreamPlayer.new()
			voice.volume_linear = gain
			add_child(voice)
			_voices.append(voice)
	var ordinals: Dictionary = {int(policy.hard_clip):true,int(policy.damage_clip):true,int(policy.splash_clip):true}
	for clips: Array in policy.surfaces.values():
		for ordinal in clips: ordinals[int(ordinal)] = true
	for ordinal: int in ordinals:
		if classic == null:
			diagnostics.append("Optional movement cue unavailable: "+str(ordinal))
			continue
		var decoded: Dictionary = classic.decode_sound({"ordinal":ordinal})
		if not decoded.get("ok",false):
			diagnostics.append("Optional movement cue silent: "+str(ordinal)+" "+str(decoded.get("reason","decode failed")))
			continue
		var value: Dictionary = decoded.value.projection()
		var samples: PackedInt32Array = value.samples
		var pcm := PackedByteArray()
		pcm.resize(samples.size()*2)
		for index in samples.size(): pcm.encode_s16(index*2,samples[index]*256)
		var sound := AudioStreamWAV.new()
		sound.format = AudioStreamWAV.FORMAT_16_BITS
		sound.mix_rate = 11025
		sound.stereo = false
		sound.data = pcm
		streams[ordinal] = sound
	return true

func advance(delta: float, eligible: bool) -> void:
	stream_paused = not eligible
	for voice in _voices: voice.stream_paused = not eligible
	if eligible and is_finite(delta) and delta > 0: _cooldown = maxf(0,_cooldown-delta)

func present(event: Dictionary) -> void:
	if scope.is_empty() or event.get("session") != scope or not event.get("id") is String or _seen.has(event.id) or typeof(event.get("cue_sequence")) != TYPE_INT or event.cue_sequence <= after_sequence or typeof(event.get("placement_serial")) != TYPE_INT: return
	if placement_serial == -1: placement_serial = event.placement_serial
	if event.placement_serial != placement_serial: return
	if _seen.size() >= 4096:
		if diagnostics.size() < 128: diagnostics.append("Optional movement audio retention exhausted; silent until relocation/retirement.")
		return
	_seen[event.id] = true
	if gain <= 0 or not streams.has(event.get("ordinal")) or (_cooldown > 0 and event.get("kind") == "step"):
		if not streams.has(event.get("ordinal")) and diagnostics.size() < 128: diagnostics.append("Optional movement cue silent: no prepared mapping for "+str(event.get("ordinal")))
		omitted += 1
		return
	var chosen: AudioStreamPlayer
	for voice in _voices:
		if not voice.playing:
			chosen = voice
			break
	if chosen == null:
		chosen = _voices[_voice_cursor%_voices.size()]
		_voice_cursor += 1
		omitted += 1 # Bounded pool preempts oldest cosmetics, never owner events.
	chosen.stream = streams[event.ordinal]
	chosen.volume_linear = gain
	chosen.play()
	_cooldown = 0.1
	submitted += 1

func retire(session: String) -> void:
	if session != scope: return
	stop()
	stream = null
	for voice in _voices:
		voice.stop()
		voice.stream = null
	streams.clear()
	_seen.clear()
	diagnostics.clear()
	scope = ""
	_cooldown = 0
