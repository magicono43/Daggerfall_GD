extends RefCounted
## DAGGER.SND records are unsigned 8-bit mono PCM at 11025 Hz, not WAV files.
const VERSION = "classic-sound-v1"
const Value = preload("res://scripts/data/decoded_media.gd")

func decode(raw: Dictionary) -> Dictionary:
	if not raw.get("ok", false):
		var rejected := raw.duplicate(true)
		rejected.converter = VERSION
		rejected.provider = "classic"
		return rejected
	var provenance := {"source": raw.get("source", ""), "record": raw.get("record"),
		"classic_id": raw.get("identity"), "offset": raw.get("offset"), "converter": VERSION,
		"provider": "classic", "ordinal":raw.get("ordinal",-1)}
	var bytes: PackedByteArray = raw.get("bytes", PackedByteArray())
	if bytes.is_empty() or not raw.get("identity") is int:
		return {"ok": false, "kind": "malformed_or_unsupported", "reason": "A nonempty numeric DAGGER.SND record is required.", "provenance": provenance}
	var samples := PackedInt32Array()
	samples.resize(bytes.size())
	for index in bytes.size():
		samples[index] = int(bytes[index]) - 128
	return {"ok": true, "kind": "ready", "value": Value.new({"schema": Value.SCHEMA,
		"domain": "audio", "identity": {"origin": "classic", "domain": "audio", "local_id": "DAGGER.SND/%d/record/%d" % [int(raw.identity),int(raw.get("ordinal",-1))]},
		"provenance": provenance, "encoding": "pcm-u8", "sample_rate_hz": 11025,
		"channels": 1, "frame_count": bytes.size(), "duration_numerator": bytes.size(),
		"duration_denominator": 11025, "samples": samples})}
