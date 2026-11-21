extends RefCounted
const Base = preload("res://tests/replacement_fixture.gd")
const ROOT = "res://content/media/native"
const Native = preload("res://scripts/data/native_media.gd")

static func configure(shell: Control) -> void:
	Base.configure(shell)
	var media: RefCounted = shell.controller.providers.media
	media.shipped_sources.append({"root":ROOT,"file":"a-exports.json"})
	media.shipped_sources.append({"root":ROOT,"file":"b-targets.json"})
	media.register_target("classic.song.d1","midi",["song.d1"],func(): return shell.controller.providers.classic.decode_sequence("D1.HMI"))
	media.register_target("asset.native.song","midi",[],Callable())
	media.register_target("asset.native.recording","audio",[],Callable())
	media.register_target("asset.native.required","midi",[],Callable())
	media.register_target("asset.native.optional_startup","video",[],func(): return optional_startup_missing())
	var clips: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ROOT+"/fixtures.json"))
	for clip: Dictionary in clips.clips: media.register_target("asset.native."+clip.id,"video",[],Callable())
	shell.controller.providers.enable_classic_media([{"file":"MIDI.BSA","format":"bsa-v1"},{"file":"ANIM0011.VID","format":"classic-vid-v1"}])

static func optional_startup_missing() -> Dictionary:
	# An explicitly declared application source is physically absent in this
	# fixture. This is a failure-only baseline, never an invalid-selected fallback.
	var path := ROOT+"/optional-startup.webm"
	var result := Native.failure("fixture_changed" if FileAccess.file_exists(path) else "missing","Optional application startup clip is absent: "+path)
	result.provider = "@application"
	return result

static func be(value: int, count: int) -> PackedByteArray:
	var bytes := PackedByteArray()
	for index in count: bytes.append((value >> ((count-index-1)*8)) & 255)
	return bytes

static func smf(type := 1) -> PackedByteArray:
	var bytes := "MThd".to_ascii_buffer()+be(6,4)+be(type,2)+be(2 if type==1 else 1,2)+be(480,2)
	var tempo := PackedByteArray([0,255,81,3,7,161,32,131,96,255,81,3,15,66,64,131,96,255,47,0])
	var notes := PackedByteArray([0,192,0,0,144,60,100,0,144,67,80,131,96,128,60,0,0,128,67,0,0,144,64,90,131,96,128,64,0,0,255,47,0])
	if type==0:
		notes = PackedByteArray([0,255,81,3,7,161,32,0,192,0,0,144,60,100,0,144,67,80,131,96,255,81,3,15,66,64,0,128,60,0,0,128,67,0,0,144,64,90,131,96,128,64,0,0,255,47,0])
	else: bytes.append_array("MTrk".to_ascii_buffer()+be(tempo.size(),4)+tempo)
	bytes.append_array("MTrk".to_ascii_buffer()+be(notes.size(),4)+notes)
	return bytes

static func chunk(tag: String, data: PackedByteArray) -> PackedByteArray:
	var length := PackedByteArray()
	length.resize(4)
	length.encode_u32(0,data.size())
	return tag.to_ascii_buffer()+length+data+(PackedByteArray([0]) if data.size()&1 else PackedByteArray())

static func table_name(name: String, stride: int) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(stride)
	var text := name.to_ascii_buffer()
	for index in mini(19,text.size()): bytes[index] = text[index]
	return bytes

static func bank() -> PackedByteArray:
	var samples := PackedByteArray()
	samples.resize((480+46)*2)
	for index in 480: samples.encode_s16(index*2,int(round(18000*sin(TAU*1000*index/48000.0))))
	var header := table_name("Project Sine 1000Hz",46)
	header.encode_u32(24,480)
	header.encode_u32(28,0)
	header.encode_u32(32,480)
	header.encode_u32(36,48000)
	header[40] = 60
	header.encode_u16(44,1)
	var phdr := table_name("Project sine",38)+table_name("Project percussion",38)+table_name("EOP",38)
	phdr.encode_u16(38+22,128)
	phdr.encode_u16(38+24,1)
	phdr.encode_u16(76+24,2)
	var inst := table_name("Project sine",22)+table_name("EOI",22)
	inst.encode_u16(22+20,1)
	var pdta := "pdta".to_ascii_buffer()
	for pair: Array in [["phdr",phdr],["pbag",PackedByteArray([0,0,0,0,1,0,0,0,2,0,0,0])],["pmod",PackedByteArray([0,0,0,0,0,0,0,0,0,0])],["pgen",PackedByteArray([41,0,0,0,41,0,0,0,0,0,0,0])],["inst",inst],["ibag",PackedByteArray([0,0,0,0,3,0,0,0])],["imod",PackedByteArray([0,0,0,0,0,0,0,0,0,0])],["igen",PackedByteArray([54,0,1,0,58,0,60,0,53,0,0,0,0,0,0,0])],["shdr",header+table_name("EOS",46)]]:
		pdta.append_array(chunk(pair[0],pair[1]))
	var info := "INFO".to_ascii_buffer()+chunk("ifil",PackedByteArray([2,0,1,0]))+chunk("isng","EMU8000".to_ascii_buffer()+PackedByteArray([0]))+chunk("INAM","Project sine fixture".to_ascii_buffer()+PackedByteArray([0,0]))
	return chunk("RIFF","sfbk".to_ascii_buffer()+chunk("LIST",info)+chunk("LIST","sdta".to_ascii_buffer()+chunk("smpl",samples))+chunk("LIST",pdta))
