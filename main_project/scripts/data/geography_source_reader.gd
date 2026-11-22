extends RefCounted
const Formats = preload("res://scripts/data/geography_formats.gd")
var _format: String
var _path := ""
var _hash := ""
var _length := 0
var _data: Dictionary = {}

func _init(format: String) -> void:
	_format = format

func close() -> void:
	_data.clear()
	_hash = ""

func initialize(path: String) -> Dictionary:
	close()
	_path = path
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return Formats.fail("source_unavailable","Cannot open geographic source READ.",path)
	_length = file.get_length()
	if _length > 67108864:
		file.close()
		return Formats.fail("malformed","Geographic source exceeds 64 MiB.",path)
	var bytes := file.get_buffer(_length)
	var error := file.get_error()
	file.close()
	if bytes.size() != _length or error != OK: return Formats.fail("source_unavailable","Incomplete geographic source read.",path)
	var decoded := Formats.decode(_format,bytes,path)
	if not decoded.ok: return decoded
	_data = decoded
	_hash = Formats.Common.sha256(bytes)
	return inventory().merged({"ok":true})

func inventory() -> Dictionary:
	var result := {"source":_path,"format":_format,"sha256":_hash,"file_bytes":_length,"open_mode":"READ","reader_id":get_instance_id()}
	if _data.has("header"): result.raw_header = _data.header.hex_encode()
	return result

func read_record(address: Variant) -> Dictionary:
	if _hash.is_empty(): return Formats.fail("before_readiness","Source reader retired/uninitialized.",_path,address)
	if not address is Array or address.size() != 2 or not Formats.Common.integer(address[0],0,int(_data.width)-1) or not Formats.Common.integer(address[1],0,499): return Formats.fail("out_of_bounds","Ordinary source lookup never clamps.",_path,address)
	var file := FileAccess.open(_path,FileAccess.READ)
	if file == null: return Formats.fail("source_unavailable","Selected source unavailable.",_path,address)
	if file.get_length() != _length:
		file.close()
		return Formats.fail("source_unavailable","Selected source changed; restart required.",_path,address)
	var index := int(address[1])*int(_data.width)+int(address[0])
	var result := {"ok":true,"value":int(_data.samples[index]),"source":_path,"sha256":_hash,"frame":Formats.FRAME,"unit":_data.unit,"pixel":address.duplicate()}
	if _format == "woods-source-v1":
		var offset: int = _data.offsets[index]
		file.seek(offset)
		var cell := file.get_buffer(47)
		if cell.size() != 47 or file.get_error() != OK:
			file.close()
			return Formats.fail("source_unavailable","Detail cell read failed.",_path,address)
		result.detail = Array(cell.slice(22,47))
		result.cell_metadata = cell.slice(0,22).hex_encode()
		result.offset = offset
	file.close()
	return result
