extends RefCounted
const Formats = preload("res://scripts/data/actor_input_formats.gd")
var _format: String
var _path := ""
var _length := 0
var _initialized := false
var _warnings: Array = []

func _init(format_id: String) -> void:
	_format = format_id

func close() -> void:
	_initialized = false
	_warnings.clear()

func _load() -> Dictionary:
	var file := FileAccess.open(_path,FileAccess.READ)
	if file == null: return Formats.failure("source_unavailable","Cannot open declared actor source READ.",_path)
	var length := file.get_length()
	if length > 16777216 or (_initialized and length != _length):
		file.close()
		return Formats.failure("malformed","Source length changed or exceeds 16 MiB.",_path)
	var bytes := file.get_buffer(length)
	var error := file.get_error()
	file.close()
	if bytes.size() != length or error != OK: return Formats.failure("source_unavailable","Incomplete actor source read.",_path)
	return {"ok":true,"bytes":bytes}

func initialize(path: String) -> Dictionary:
	close()
	_path = path
	var loaded := _load()
	if not loaded.ok:
		return loaded
	var decoded := Formats.decode(_format,loaded.bytes,_path)
	if not decoded.ok: return decoded
	for key: String in decoded.records:
		if decoded.records[key].kind == "flat_conflict": _warnings.append({"kind":"ambiguous_mapping","record":key,"source":_path,"profile":Formats.FLAT_CONFLICT_PROFILE,"reason":"Known classic flat source conflict retained; unique flat lookup remains unavailable."})
	_length = loaded.bytes.size()
	_initialized = true
	return {"ok":true,"source":_path,"format":_format,"open_mode":"READ","file_bytes":_length,"warnings":_warnings.duplicate(true)}

func read_record(address: Variant) -> Dictionary:
	if not _initialized: return Formats.failure("before_readiness","Actor source is not active.",_path,address)
	if not address is String: return Formats.failure("malformed","Actor source address must be an explicit string key.",_path,address)
	var loaded := _load()
	if not loaded.ok:
		loaded.record = address
		return loaded
	var decoded := Formats.decode(_format,loaded.bytes,_path)
	if not decoded.ok: return decoded
	if address == "@all": return {"ok":true,"kind":"ready","records":decoded.records.duplicate(true),"source":_path,"format":_format,"sha256":Formats.sha256(loaded.bytes)}
	if not decoded.records.has(address): return Formats.failure("record_not_found","Actor source record is absent.",_path,address)
	if decoded.records[address].kind == "flat_conflict":
		var rejected := Formats.failure("ambiguous_mapping","Known classic flat conflict has no approved unique winner.",_path,address)
		rejected.candidates = decoded.records[address].alternatives.duplicate(true)
		rejected.profile = Formats.FLAT_CONFLICT_PROFILE
		return rejected
	return {"ok":true,"kind":"ready","value":decoded.records[address].duplicate(true),"source":_path,"record":address,"format":_format,"sha256":Formats.sha256(loaded.bytes)}

func inventory() -> Dictionary:
	return {"source":_path,"reader_id":get_instance_id(),"format":_format,"file_bytes":_length,"open_mode":"READ","warnings":_warnings.duplicate(true)}
