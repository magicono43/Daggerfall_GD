extends RefCounted
const Formats = preload("res://scripts/data/item_spell_formats.gd")
var _format: String
var _path := ""
var _hash := ""
var _records: Dictionary = {}
var _length := 0

func _init(format: String) -> void:
	_format = format

func close() -> void:
	_records.clear()
	_hash = ""

func initialize(path: String) -> Dictionary:
	close()
	_path = path
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return Formats.failure("source_unavailable","Cannot open declared item/spell source READ.",path)
	_length = file.get_length()
	if _length > 16777216:
		file.close()
		return Formats.failure("malformed","Source exceeds 16 MiB.",path)
	var bytes := file.get_buffer(_length)
	var error := file.get_error()
	file.close()
	if bytes.size() != _length or error != OK: return Formats.failure("source_unavailable","Incomplete source read.",path)
	var decoded := Formats.decode(_format,bytes,path)
	if not decoded.ok: return decoded
	_records = decoded.records
	_hash = decoded.sha256
	return {"ok":true,"source":path,"format":_format,"file_bytes":_length,"open_mode":"READ","profile_known":decoded.profile_known}

func read_record(address: Variant) -> Dictionary:
	if _hash.is_empty(): return Formats.failure("before_readiness","Source is not active.",_path,address)
	if not address is String: return Formats.failure("malformed","Source address must be an explicit ordinal string.",_path,address)
	# Refuse changed input rather than mixing a cached identity with changed bytes.
	if FileAccess.get_sha256(_path) != _hash: return Formats.failure("source_unavailable","Selected source changed; restart preparation required.",_path,address)
	if address == "@all": return {"ok":true,"records":_records.duplicate(true),"source":_path,"sha256":_hash}
	if not _records.has(address): return Formats.failure("record_not_found","Source record absent.",_path,address)
	return {"ok":true,"value":_records[address].duplicate(true),"source":_path,"sha256":_hash}

func inventory() -> Dictionary:
	return {"source":_path,"format":_format,"file_bytes":_length,"count":_records.size(),"sha256":_hash,"open_mode":"READ","reader_id":get_instance_id()}
