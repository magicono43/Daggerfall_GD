extends RefCounted
## Per-request VID reconstruction. No engine resource, mutable player or timing patch.
const Cursor = preload("res://scripts/data/media_cursor.gd")
const VERSION = "classic-vid-v1"

func failure(reason: String, position: int, kind := "malformed_or_unsupported") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"position":position,"converter":VERSION}

func decode(bytes: PackedByteArray, requested_frame: int) -> Dictionary:
	var cursor := Cursor.new(bytes)
	if not cursor.has(16) or cursor.take(3).get_string_from_ascii() != "VID": return failure("Truncated/invalid VID header.",0)
	var unknown_1 := cursor.u16()
	var frames := cursor.u16()
	var width := cursor.u16()
	var height := cursor.u16()
	var global_delay := cursor.u16()
	var unknown_2 := cursor.u16()
	if unknown_1 != 512 or unknown_2 != 14: return failure("Unsupported VID header profile.",3)
	if frames == 0 or width == 0 or height == 0 or width * height > bytes.size() * 127: return failure("Invalid VID dimensions/frame count.",5)
	if requested_frame < 0 or requested_frame >= frames: return failure("VID frame absent.",5,"record_not_found")
	if cursor.u8() != 2: return failure("VID header must be followed by palette.",15)
	var colors := _palette(cursor)
	if not cursor.reason.is_empty(): return failure(cursor.reason,cursor.position)
	var pixels := PackedByteArray()
	pixels.resize(width * height)
	var frame := -1
	var audio_sample := 0
	var audio_start := 0
	var audio := PackedByteArray()
	var started := false
	var audio_chunks: Array[Dictionary] = []
	var wanted: Dictionary = {}
	while cursor.position < cursor.limit and cursor.reason.is_empty():
		var at := cursor.position
		var type := cursor.u8()
		if type == 0: continue
		if type == 20:
			if wanted.is_empty(): return failure("VID ended before requested declared frame.",at)
			wanted.audio_chunks = audio_chunks
			wanted.sequence_audio_samples = audio_sample
			wanted.terminal_position = at
			return wanted
		if type == 2:
			colors = _palette(cursor)
			continue
		if type in [124,125]:
			if type == 124:
				var unknown := cursor.u16()
				var rate := cursor.u8()
				if unknown != 0 or rate != 166: return failure("Unsupported VID audio header/rate.",at)
				started = true
			elif not started: return failure("VID incremental audio without audio start.",at)
			var count := cursor.u16()
			audio_start = audio_sample
			audio = cursor.take(count)
			audio_sample += count
			audio_chunks.append({"position":at,"start_sample":audio_start,"end_sample":audio_sample,"pcm_u8":audio})
			continue
		if type not in [1,3,4]: return failure("Unsupported VID block type %d." % type,at)
		var delay := cursor.u16()
		var row := cursor.u16() if type == 4 else 0
		if row >= height: return failure("VID row offset exceeds frame.",at)
		var position := row * width
		while position < pixels.size() and cursor.has(1):
			var code := cursor.u8()
			if code == 0: break
			var count := code - 128 if code >= 128 else code
			if count > pixels.size() - position: return failure("VID run crosses frame boundary.",cursor.position - 1)
			if code >= 128:
				if type == 3:
					var value := cursor.u8()
					for unused in count: pixels[position + unused] = value
				position += count
			else:
				var values := cursor.take(count)
				if not cursor.reason.is_empty(): break
				for pixel in values:
					pixels[position] = pixel
					position += 1
		if not cursor.reason.is_empty(): return failure(cursor.reason,cursor.position)
		frame += 1
		if frame >= frames: return failure("VID contains more image frames than its declared profile.",at)
		if frame != requested_frame: continue
		wanted = {"ok":true,"domain":"video_frame","converter":VERSION,"frame":frame,"frame_count":frames,
			"width":width,"height":height,"indices":pixels,"palette_rgb":colors,"position":at,"block_type":type,
			"global_delay_source":global_delay,"frame_delay_source":delay,"sample_rate_hz":11025,"channels":1,
			"audio_encoding":"pcm-u8","audio":audio,"audio_start_sample":audio_start,"audio_end_sample":audio_sample,
			"audio_chunks":audio_chunks,"timing_profile":"source-audio-samples-v1","timing_patch":"none","orientation":"row-major-top-left"}
		# Earlier frame requests return a self-contained prefix. The last frame
		# also reads to the terminal block, preserving trailing audio chunks.
		if frame < frames - 1: return wanted
	return failure(cursor.reason if not cursor.reason.is_empty() else "VID terminated without requested frame.",cursor.position)

func _palette(cursor: RefCounted) -> PackedByteArray:
	var rgb: PackedByteArray = cursor.take(768)
	for index in rgb.size():
		if rgb[index] > 63:
			cursor.reason = "VID palette component exceeds six-bit profile."
			break
		rgb[index] *= 4
	return rgb
