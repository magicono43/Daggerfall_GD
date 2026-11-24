extends AudioStreamPlayer
## Optional AV observer; failed decoding/playback never participates in death.
var scope := ""
var outcome := "not-requested"

func present(session: String, resource: String, access: RefCounted) -> bool:
	if not scope.is_empty(): return false
	scope = session
	outcome = "unavailable"
	if resource.is_empty() or access == null: return false
	var decoded: Dictionary = access.decode_sound({"ordinal":int(resource.trim_prefix("classic-ordinal-"))})
	if not decoded.get("ok",false): return false
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
	stream = sound
	play()
	outcome = "submitted"
	return true

func retire(session: String) -> void:
	if scope != session: return
	stop()
	stream = null
	scope = ""
