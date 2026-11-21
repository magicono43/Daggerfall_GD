extends RefCounted
const ROOT = "res://content/media/native"
const Native = preload("res://scripts/data/native_media.gd")
static func configure(shell: Control) -> void:
	var media: RefCounted = shell.controller.providers.media
	media.shipped_sources = [{"root":ROOT,"file":"c-recording-exports.json"},{"root":ROOT,"file":"d-recording-targets.json"}]
	media.register_target("asset.native.recording","audio",[],Callable())
	media.register_target("asset.native.unavailable-midi","midi",[],midi_baseline)
	media.register_target("asset.native.unavailable-video","video",[],func(): return Native.video(FileAccess.get_file_as_bytes(ROOT+"/vp8-none.bytes"),"webm-v1"))

static func midi_baseline() -> Dictionary:
	var decoded := Native.midi(FileAccess.get_file_as_bytes(ROOT+"/sequence.mid.bytes"))
	return {"ok":true,"provider":"@application","resource":decoded,"provenance":{"provider":"@application","file":"sequence.mid.bytes","converter":Native.VERSION}} if decoded.ok else decoded
