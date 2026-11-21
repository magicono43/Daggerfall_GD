extends RefCounted
## Non-native, byte-checked profiles. No filename dispatch or package code loading.
const VERSION = "replacement-codec-v1"
const Native = preload("res://scripts/data/native_media.gd")

static func fail(kind: String, reason: String) -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"converter":VERSION}

static func decode(bytes: PackedByteArray, profile: String, expected: String) -> Dictionary:
	if bytes.is_empty(): return fail("invalid", "Empty media payload.")
	var value: Dictionary
	match profile:
		"png-v1": value = png(bytes) if expected == "image" else fail("wrong_type", "PNG requires image type.")
		"pcm-wav-v1": value = wav(bytes) if expected == "audio" else fail("wrong_type", "WAV requires audio type.")
		"vorbis-v1": value = vorbis(bytes) if expected == "audio" else fail("wrong_type", "Vorbis requires audio type.")
		"static-glb-v1": value = load("res://scripts/data/replacement_glb.gd").decode(bytes) if expected == "model" else fail("wrong_type", "GLB requires model type.")
		"midi-v1", "sf2-v1", "webm-v1", "mp4-v1":
			if Native.force_unavailable or Native.adapter() == null:
				value = fail("backend_unavailable","Project native media capability is unavailable: "+profile)
			elif expected != {"midi-v1":"midi","sf2-v1":"bank","webm-v1":"video","mp4-v1":"video"}[profile]:
				value = fail("wrong_type","Native profile/type mismatch: "+profile)
			elif profile == "midi-v1": value = Native.midi(bytes)
			elif profile == "sf2-v1": value = Native.bank(bytes)
			else: value = Native.video(bytes,profile)
		_: value = fail("unsupported", "Unsupported declared profile: " + profile)
	value.converter = value.get("converter",VERSION)
	return value

static func png(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 33 or bytes.slice(0,8) != PackedByteArray([137,80,78,71,13,10,26,10]): return fail("wrong_type", "Expected PNG signature and IHDR.")
	if bytes.slice(12,16).get_string_from_ascii() != "IHDR" or bytes[24] != 8 or bytes[25] not in [2,3,6]: return fail("unsupported", "PNG profile requires 8-bit RGB, indexed or RGBA.")
	var position := 8
	var ended := false
	var data := false
	while position < bytes.size():
		if position+12 > bytes.size(): return fail("invalid","Truncated PNG chunk header.")
		var length := big_u32(bytes,position)
		if position+12+length > bytes.size() or ended: return fail("invalid","PNG chunk extent mismatch.")
		var crc := 0xffffffff
		for i in range(position+4,position+8+length):
			crc ^= int(bytes[i])
			for bit in 8: crc = ((crc >> 1) ^ (0xedb88320 if crc & 1 else 0)) & 0xffffffff
		if (crc ^ 0xffffffff) != big_u32(bytes,position+8+length): return fail("invalid","PNG CRC mismatch.")
		var tag := bytes.slice(position+4,position+8).get_string_from_ascii()
		if tag in ["acTL","fcTL","fdAT"]: return fail("unsupported","Animated PNG requires a separate animation profile.")
		data = data or tag == "IDAT"
		ended = tag == "IEND"
		position += 12+length
	if not ended or not data: return fail("invalid","PNG requires complete image data and IEND.")
	var image := Image.new()
	if image.load_png_from_buffer(bytes) != OK or image.is_empty(): return fail("invalid", "PNG decoder rejected payload.")
	image.convert(Image.FORMAT_RGBA8)
	return {"ok":true,"image":image,"width":image.get_width(),"height":image.get_height(),"rgba":image.get_data(),"frame":"png-top-left-v1"}

static func big_u32(bytes: PackedByteArray, position: int) -> int:
	return (int(bytes[position]) << 24) | (int(bytes[position+1]) << 16) | (int(bytes[position+2]) << 8) | int(bytes[position+3])

static func wav(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 12 or bytes.slice(0,4).get_string_from_ascii() != "RIFF" or bytes.slice(8,12).get_string_from_ascii() != "WAVE": return fail("wrong_type", "Expected RIFF WAVE.")
	if bytes.decode_u32(4) + 8 != bytes.size(): return fail("invalid", "RIFF extent mismatch.")
	var position := 12
	var format := PackedByteArray()
	var samples := PackedByteArray()
	var found_data := false
	while position < bytes.size():
		if position + 8 > bytes.size(): return fail("invalid", "Truncated WAV chunk header.")
		var tag := bytes.slice(position,position+4).get_string_from_ascii()
		var size := bytes.decode_u32(position+4)
		position += 8
		if position + size + (size & 1) > bytes.size(): return fail("invalid", "Truncated WAV chunk.")
		if tag == "fmt ":
			if not format.is_empty(): return fail("invalid", "Duplicate WAV format.")
			format = bytes.slice(position,position+size)
		if tag == "data":
			if found_data: return fail("invalid", "Duplicate WAV data.")
			found_data = true
			samples = bytes.slice(position,position+size)
		position += size + (size & 1)
	if format.size() < 16 or not found_data or samples.is_empty(): return fail("invalid", "Missing PCM format/data.")
	var channels := format.decode_u16(2)
	var rate := format.decode_u32(4)
	var bits := format.decode_u16(14)
	if format.decode_u16(0) != 1 or channels not in [1,2] or bits not in [8,16]: return fail("unsupported", "Only unsigned8/signed16 PCM mono/stereo is supported.")
	var alignment: int = channels * bits / 8
	if rate <= 0 or rate > 2147483647 or format.decode_u16(12) != alignment or format.decode_u32(8) != rate * alignment or samples.size() % alignment != 0: return fail("invalid", "PCM rate/alignment/frame count mismatch.")
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS if bits == 8 else AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.stereo = channels == 2
	var engine_bytes := samples.duplicate()
	if bits == 8:
		for i in engine_bytes.size(): engine_bytes[i] = (int(engine_bytes[i]) - 128) & 255
	stream.data = engine_bytes
	return {"ok":true,"stream":stream,"samples":samples,"bits":bits,"channels":channels,"sample_rate_hz":rate,"frames":samples.size()/alignment,"seconds":float(samples.size()/alignment)/rate}

static func vorbis(bytes: PackedByteArray) -> Dictionary:
	# Check complete pages, CRC, packet identity, sequence and EOS before engine decode.
	var position := 0
	var serial := -1
	var sequence := 0
	var packet := PackedByteArray()
	var packets := 0
	var ended := false
	var sample_rate := 0
	var channels := 0
	var frames := -1
	while position < bytes.size():
		if position + 27 > bytes.size() or bytes.slice(position,position+4).get_string_from_ascii() != "OggS" or bytes[position+4] != 0: return fail("invalid", "Truncated or invalid Ogg page.")
		var segments := int(bytes[position+26])
		if position + 27 + segments > bytes.size(): return fail("invalid", "Truncated Ogg segment table.")
		var end := position + 27 + segments
		for i in segments: end += bytes[position+27+i]
		if end > bytes.size() or ended: return fail("invalid", "Ogg extent or chained stream is unsupported.")
		var page := bytes.slice(position,end)
		var crc := page.decode_u32(22)
		page.encode_u32(22,0)
		var actual := 0
		for byte in page:
			actual ^= int(byte) << 24
			for bit in 8: actual = ((actual << 1) ^ (0x04c11db7 if actual & 0x80000000 else 0)) & 0xffffffff
		if actual != crc: return fail("invalid", "Ogg CRC mismatch.")
		if serial < 0: serial = page.decode_u32(14)
		if page.decode_u32(14) != serial or page.decode_u32(18) != sequence: return fail("unsupported", "Multiplexed/chained or unordered Ogg pages.")
		if sequence == 0 and (page[5] & 2) == 0: return fail("invalid", "Missing Ogg BOS.")
		if bool(page[5] & 1) != not packet.is_empty(): return fail("invalid", "Ogg packet continuation mismatch.")
		var data := position + 27 + segments
		for i in segments:
			var length := int(bytes[position+27+i])
			packet.append_array(bytes.slice(data,data+length))
			data += length
			if length < 255:
				if packets < 3 and (packet.size() < 7 or packet[0] != [1,3,5][packets] or packet.slice(1,7).get_string_from_ascii() != "vorbis"): return fail("wrong_type", "Expected Vorbis identification/comment/setup packets.")
				if packets == 0:
					if packet.size() != 30 or packet.decode_u32(7) != 0 or packet[29] != 1: return fail("invalid","Invalid Vorbis identification header.")
					channels = packet[11]
					sample_rate = packet.decode_u32(12)
					if channels not in [1,2] or sample_rate <= 0: return fail("unsupported","Vorbis profile requires positive rate and mono/stereo.")
				packets += 1
				packet.clear()
		ended = bool(page[5] & 4)
		if ended: frames = page.decode_s64(6)
		sequence += 1
		position = end
	if not ended or not packet.is_empty() or packets < 4 or frames <= 0: return fail("invalid", "Missing complete finite Vorbis stream/EOS.")
	var stream := AudioStreamOggVorbis.load_from_buffer(bytes)
	if stream == null or not is_finite(stream.get_length()) or stream.get_length() <= 0: return fail("invalid", "Engine rejected finite Vorbis stream.")
	if abs(stream.get_length()-float(frames)/sample_rate) > 0.001: return fail("invalid","Vorbis engine duration disagrees with source granule/rate.")
	return {"ok":true,"stream":stream,"seconds":stream.get_length(),"codec":"vorbis","pages":sequence,"channels":channels,"sample_rate_hz":sample_rate,"frames":frames}
