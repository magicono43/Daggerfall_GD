extends SceneTree
## Separate headless boundary check for newly admitted optional GFX/CEL imagery.
const Codec = preload("res://scripts/data/creation_questionnaire_images.gd")
const Hash = preload("res://scripts/data/actor_input_formats.gd")
var checks: Array = []

func check(name: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":name,"expected":expected,"actual":actual})

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var source := ""; var output := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--classic-source="): source = argument.trim_prefix("--classic-source=")
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
	if source.is_empty() or output.is_empty(): quit(2); return
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/questionnaire_animation_goldens.json"))
	for id in ["rogue","mage","warrior"]:
		var bytes := FileAccess.get_file_as_bytes(source.path_join(id.to_upper()+".CEL"))
		check(id+" pinned source",golden.assets[id].source_sha256,Hash.sha256(bytes))
		var decoded: Dictionary = Codec.new().cel(bytes)
		check(id+" decodes",true,decoded.ok)
		if decoded.ok:
			check(id+" all decoded pixels match independent FFmpeg",golden.assets[id].rgba_sha256,Hash.sha256(decoded.image.get_data()))
			check(id+" timing",71,decoded.delay_msec)
			check(id+" excludes ring frame",int(golden.assets[id].frames),decoded.frames)
		check(id+" truncated header rejected",false,Codec.new().cel(bytes.slice(0,30)).ok)
		var malformed := bytes.duplicate(); malformed.encode_u16(6,129)
		check(id+" excessive frame count rejected",false,Codec.new().cel(malformed).ok)
		malformed = bytes.duplicate(); malformed.encode_u32(bytes.decode_u32(80),4294967295)
		check(id+" escaping frame extent rejected",false,Codec.new().cel(malformed).ok)
		malformed = bytes.duplicate()
		var first := int(bytes.decode_u32(80)); var offset := first+16
		for chunk in bytes.decode_u16(first+6):
			if bytes.decode_u16(offset+4) == 15:
				malformed[offset+7] = 0
				check(id+" zero byte run rejected",false,Codec.new().cel(malformed).ok)
				break
			offset += bytes.decode_u32(offset)
	var background := preload("res://scripts/data/classic_image.gd").new().decode(FileAccess.get_file_as_bytes(source.path_join("CHGN00I0.IMG")),"CHGN00I0.IMG",0,0)
	for name in ["SCRL00I0.GFX","SCRL01I0.GFX"]:
		var bytes := FileAccess.get_file_as_bytes(source.path_join(name))
		var decoded: Dictionary = Codec.new().scroll(bytes,background.embedded_palette)
		check(name+" eight frames decode",true,decoded.ok)
		if decoded.ok: check(name+" atlas extent",Vector2i(320,640),decoded.image.get_size())
		check(name+" truncated rows rejected",false,Codec.new().scroll(bytes.slice(0,100),background.embedded_palette).ok)
		var malformed := bytes.duplicate(); malformed.encode_u16(0,65535)
		check(name+" excessive frame count rejected",false,Codec.new().scroll(malformed,background.embedded_palette).ok)
		malformed = bytes.duplicate(); malformed.encode_u16(14,65535)
		check(name+" row beyond input rejected",false,Codec.new().scroll(malformed,background.embedded_palette).ok)
		malformed = bytes.duplicate(); malformed.encode_u16(bytes.decode_u16(14)+2,0)
		check(name+" zero RLE run rejected",false,Codec.new().scroll(malformed,background.embedded_palette).ok)
	var result := {"ok":checks.all(func(item): return item.expected == item.actual),"count":checks.size(),"checks":checks,"scope":"headless optional questionnaire codec boundary; pinned corpus and malformed fixtures"}
	var file := FileAccess.open(output,FileAccess.WRITE); file.store_string(JSON.stringify(result,"\t")); file.close()
	print("Questionnaire codec checks: ",result.count," passed=",result.ok)
	quit(0 if result.ok else 1)
