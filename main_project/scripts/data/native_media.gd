extends RefCounted
## Checked source bytes only. Native code never resolves package or media paths.
const VERSION = "native-media-v1"
const BANK = "res://content/media/banks/generaluser-gs-2.0.3.sf2"
const BANK_HASH = "9575028c7a1f589f5770fccc8cff2734566af40cd26ed836944e9a5152688cfe"
const Cursor = preload("res://scripts/data/media_cursor.gd")
static var force_unavailable := false # Failure-only capability seam for preserved inventories.

static func failure(kind: String, reason: String) -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"converter":VERSION}

static func adapter() -> RefCounted:
	return ClassDB.instantiate("NativeMediaAdapter") if not force_unavailable and ClassDB.class_exists("NativeMediaAdapter") else null

static func capabilities() -> Dictionary:
	var native := adapter()
	return native.invoke("capabilities") if native != null else failure("backend_unavailable","Project native media extension is not loaded.")

static func digest(bytes: PackedByteArray) -> String:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	return hash.finish().hex_encode()

static func default_bank() -> Dictionary:
	if not FileAccess.file_exists(BANK): return failure("default_bank_missing","Bundled GeneralUser GS 2.0.3 is missing.")
	var bytes := FileAccess.get_file_as_bytes(BANK)
	if digest(bytes) != BANK_HASH: return failure("default_bank_invalid","Bundled bank identity differs from the pinned build.")
	var decoded := bank(bytes)
	if decoded.ok: decoded.identity = {"provider":"@application","key":"generaluser-gs-2.0.3","sha256":BANK_HASH}
	return decoded

static func be(bytes: PackedByteArray, offset: int, count: int) -> int:
	var value := 0
	for index in count: value = (value << 8) | int(bytes[offset+index])
	return value

static func vlq(cursor: RefCounted) -> int:
	var value := 0
	for unused in 4:
		var byte: int = cursor.u8()
		value = (value << 7) | (byte & 127)
		if byte < 128: return value
	cursor.reason = "SMF VLQ exceeds four bytes."
	return 0

static func midi(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 14 or bytes.slice(0,4).get_string_from_ascii() != "MThd": return failure("wrong_type","Expected complete SMF header.")
	if be(bytes,4,4) != 6: return failure("unsupported","SMF profile requires the six-byte header.")
	var type := be(bytes,8,2)
	var tracks := be(bytes,10,2)
	var division := be(bytes,12,2)
	if type not in [0,1] or tracks < 1 or (type == 0 and tracks != 1) or division == 0 or division & 0x8000: return failure("unsupported","SMF requires type 0/1 with positive PPQ division; SMPTE/type 2 reject.")
	var position := 14
	var events: Array = []
	var end_tick := 0
	for track in tracks:
		if position+8 > bytes.size() or bytes.slice(position,position+4).get_string_from_ascii() != "MTrk": return failure("invalid","Missing/truncated SMF track.")
		var end := position+8+be(bytes,position+4,4)
		if end > bytes.size(): return failure("invalid","SMF track exceeds source bytes.")
		var cursor := Cursor.new(bytes,position+8,end)
		var tick := 0
		var running := 0
		var ended := false
		while cursor.position < end and cursor.reason.is_empty():
			var at: int = cursor.position
			tick += vlq(cursor)
			if tick > 0x7fffffff: return failure("unsupported","SMF tick extent exceeds verified player range.")
			var status: int = cursor.u8()
			if status < 128:
				if running == 0: return failure("invalid","SMF data without channel running status.")
				cursor.position -= 1
				status = running
			var event := {"tick":tick,"track":track,"position":at,"status":status}
			if status < 240:
				running = status
				var length := 1 if (status & 240) in [192,208] else 2
				var data: PackedByteArray = cursor.take(length)
				for byte in data:
					if byte >= 128: return failure("invalid","SMF channel data has status bit set.")
				event.data = data
			elif status == 255:
				running = 0
				var tag: int = cursor.u8()
				var length := vlq(cursor)
				var data: PackedByteArray = cursor.take(length)
				if tag == 81:
					if length != 3 or data.size() != 3 or be(data,0,3) == 0: return failure("invalid","SMF tempo requires three nonzero microsecond bytes.")
					event.tempo = be(data,0,3)
				if tag == 47:
					if length != 0 or cursor.position != end: return failure("invalid","SMF end-of-track must terminate its track.")
					ended = true
				event.meta = tag
			elif status in [240,247]:
				running = 0
				var data: PackedByteArray = cursor.take(vlq(cursor))
				if status!=240 or data not in [PackedByteArray([126,127,9,1,247]),PackedByteArray([65,16,66,18,64,0,127,0,65,247])]: return failure("unsupported","Only complete GM/GS reset SysEx is supported by this MIDI profile.")
				event.reset = true
			else: return failure("unsupported","SMF system common/realtime events are outside the declared profile.")
			events.append(event)
		if not cursor.reason.is_empty(): return failure("invalid",cursor.reason)
		if not ended: return failure("invalid","SMF track lacks end-of-track.")
		end_tick = maxi(end_tick,tick)
		position = end
	if position != bytes.size(): return failure("invalid","Trailing SMF data.")
	events.sort_custom(func(a: Dictionary,b: Dictionary): return a.tick < b.tick or (a.tick == b.tick and (a.track < b.track or (a.track == b.track and a.position < b.position))))
	var tempo := 500000
	var programs := PackedInt32Array()
	programs.resize(16)
	var banks := PackedInt32Array()
	banks.resize(16)
	var required := {}
	var previous := 0
	var numerator := 0
	var denominator := division * 1000000
	for event: Dictionary in events:
		# Integer integration preserves stable rational event/sample positions.
		var step: int = event.tick-previous
		if step>0x7fffffffffffffff/(tempo*48000): return failure("unsupported","SMF duration exceeds rational timeline range.")
		var increment: int = step*tempo*48000
		if increment < 0 or numerator > 0x7fffffffffffffff-increment: return failure("unsupported","SMF duration exceeds rational timeline range.")
		numerator += increment
		event.sample = numerator / denominator
		previous = event.tick
		if event.has("tempo"): tempo = event.tempo
		if event.get("reset",false):
			programs.fill(0)
			banks.fill(0)
		if event.has("data"):
			var channel: int = event.status&15
			var command: int = event.status&240
			if command==192: programs[channel] = event.data[0]
			if command==176 and event.data[0]==0: banks[channel] = event.data[1]
			if command==144 and event.data[1]>0: required["%d:%d" % [128 if channel==9 else banks[channel],programs[channel]]] = true
	var caps := capabilities()
	if not caps.get("midi",false): return failure("backend_unavailable",caps.get("midi_reason",caps.get("reason","FluidSynth unavailable.")))
	return {"ok":true,"converter":VERSION,"bytes":bytes,"events":events,"required_presets":required.keys(),"end_tick":end_tick,"sample_frames":numerator/denominator,"division":division,"smf_type":type,"sample_rate_hz":48000,"backend":caps.fluid_version}

static func bank(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 12 or bytes.slice(0,4).get_string_from_ascii() != "RIFF" or bytes.slice(8,12).get_string_from_ascii() != "sfbk": return failure("wrong_type","Expected RIFF SoundFont 2 bank.")
	if bytes.decode_u32(4)+8 != bytes.size(): return failure("invalid_bank","SF2 RIFF extent mismatch.")
	var position := 12
	var tables := {}
	var sample_bytes := 0
	var groups := {}
	while position < bytes.size():
		if position+12 > bytes.size() or bytes.slice(position,position+4).get_string_from_ascii() != "LIST": return failure("invalid_bank","SF2 requires complete LIST chunks.")
		var length := bytes.decode_u32(position+4)
		var end := position+8+length
		if length < 4 or end+(length&1)>bytes.size(): return failure("invalid_bank","Truncated SF2 list.")
		var group := bytes.slice(position+8,position+12).get_string_from_ascii()
		if group not in ["INFO","sdta","pdta"] or groups.has(group): return failure("unsupported","SF2 requires unique INFO/sdta/pdta groups.")
		groups[group] = true
		var child := position+12
		while child < end:
			if child+8>end: return failure("invalid_bank","Truncated SF2 subchunk.")
			var tag := bytes.slice(child,child+4).get_string_from_ascii()
			var size := bytes.decode_u32(child+4)
			if child+8+size+(size&1)>end: return failure("invalid_bank","SF2 subchunk exceeds list.")
			if tables.has(tag): return failure("invalid_bank","Duplicate SF2 table: "+tag)
			tables[tag] = bytes.slice(child+8,child+8+size)
			if tag == "smpl": sample_bytes = size
			child += 8+size+(size&1)
		position = end+(length&1)
	if groups.size()!=3 or sample_bytes<2 or sample_bytes&1: return failure("invalid_bank","SF2 sample/table groups missing or unaligned.")
	if not tables.has("ifil") or tables.ifil.size()!=4 or tables.ifil.decode_u16(0)!=2: return failure("unsupported","Only SF2 major version 2 banks are supported.")
	for tag: String in {"phdr":38,"pbag":4,"pmod":10,"pgen":4,"inst":22,"ibag":4,"imod":10,"igen":4,"shdr":46}:
		var stride: int = {"phdr":38,"pbag":4,"pmod":10,"pgen":4,"inst":22,"ibag":4,"imod":10,"igen":4,"shdr":46}[tag]
		if not tables.has(tag) or tables[tag].size()<stride or tables[tag].size()%stride!=0: return failure("invalid_bank","Missing or misaligned SF2 table: "+tag)
	var headers: PackedByteArray = tables.shdr
	for at in range(0,headers.size()-46,46):
		var first := headers.decode_u32(at+20)
		var end := headers.decode_u32(at+24)
		var loop_start := headers.decode_u32(at+28)
		var loop_end := headers.decode_u32(at+32)
		var sample_type := headers.decode_u16(at+44)
		if first>=end or end>sample_bytes/2 or loop_start>sample_bytes/2 or loop_end>sample_bytes/2 or loop_start>loop_end or headers.decode_u32(at+36)==0: return failure("invalid_bank","SF2 sample extent/rate/loop invalid.")
		if sample_type not in [1,2,4,8]: return failure("unsupported","Compressed SF3/ROM samples are outside the SF2 PCM profile.")
	var native := adapter()
	if native == null: return failure("backend_unavailable","Project native media extension is not loaded.")
	var decoded: Dictionary = native.invoke("bank",bytes)
	if decoded.ok:
		decoded.bytes = bytes
		decoded.sha256 = digest(bytes)
		decoded.backend = capabilities().fluid_version
	return decoded

static func video(bytes: PackedByteArray, profile: String) -> Dictionary:
	if profile == "webm-v1" and (bytes.size()<4 or bytes.slice(0,4)!=PackedByteArray([26,69,223,163])): return failure("wrong_type","Expected EBML WebM bytes.")
	if profile == "webm-v1":
		var header := webm_header(bytes)
		if not header.ok: return header
	if profile == "mp4-v1" and (bytes.size()<12 or bytes.slice(4,8).get_string_from_ascii()!="ftyp"): return failure("wrong_type","Expected ISO BMFF ftyp bytes.")
	var native := adapter()
	if native == null: return failure("backend_unavailable","Project native media extension is not loaded.")
	# Full decoding runs on a native worker and retains no decoded movie cache.
	var decoded: Dictionary = native.invoke("inspect_video",bytes,profile,1)
	if decoded.ok:
		decoded.bytes = bytes
		decoded.profile = profile
		decoded.backend = capabilities().ffmpeg_build
	return decoded

static func vint(bytes: PackedByteArray, position: int, identifier: bool, maximum: int) -> Dictionary:
	if position>=bytes.size() or bytes[position]==0: return failure("invalid","Truncated/invalid EBML integer.")
	var length := 1
	var marker := 128
	while not (int(bytes[position])&marker):
		length += 1
		marker >>= 1
	if length>maximum or position+length>bytes.size(): return failure("invalid","EBML integer exceeds its byte extent.")
	var value := int(bytes[position]) if identifier else int(bytes[position])&(marker-1)
	for index in range(1,length): value = (value<<8)|int(bytes[position+index])
	return {"ok":true,"value":value,"next":position+length}

static func webm_header(bytes: PackedByteArray) -> Dictionary:
	var header := vint(bytes,4,false,8)
	if not header.ok: return header
	var end: int = header.next+header.value
	if end>bytes.size(): return failure("invalid","Truncated EBML header.")
	var position: int = header.next
	var doctype := false
	while position<end:
		var id := vint(bytes,position,true,4)
		if not id.ok: return id
		var size := vint(bytes,id.next,false,8)
		if not size.ok: return size
		if size.next+size.value>end: return failure("invalid","EBML header field exceeds header.")
		if id.value==0x4282:
			if doctype: return failure("invalid","Duplicate EBML doctype.")
			doctype = true
			if bytes.slice(size.next,size.next+size.value)!="webm".to_ascii_buffer(): return failure("unsupported","This profile requires the actual WebM doctype, not generic Matroska.")
		if id.value in [0x42f7,0x42f2,0x42f3,0x4287,0x4285]:
			if size.value<1 or size.value>4: return failure("unsupported","Unverified EBML header version extent.")
			var limit: int = {0x42f7:1,0x42f2:4,0x42f3:8,0x4287:4,0x4285:2}[id.value]
			if be(bytes,size.next,size.value)>limit: return failure("unsupported","Unverified WebM/EBML version or integer profile.")
		position = size.next+size.value
	return {"ok":true} if doctype else failure("invalid","EBML header lacks WebM doctype.")
