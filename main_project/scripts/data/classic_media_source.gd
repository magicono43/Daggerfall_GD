extends RefCounted
## Checked loose media reader. No handles, pixels or playback state retained.
const Images = preload("res://scripts/data/classic_image.gd")
const Value = preload("res://scripts/data/decoded_media.gd")
const Vid = preload("res://scripts/data/classic_vid.gd")
const FORMATS = ["classic-img-v1", "classic-cif-v1", "classic-rci-v1", "classic-texture-v1", "classic-palette-v1", "classic-vid-v1"]
var _format := ""
var _path := ""
var _length := 0
var _initialized := false

func _init(format_id: String) -> void:
	_format = format_id

func close() -> void:
	_initialized = false
	_length = 0

func _failure(kind: String, reason: String, record: Variant = null) -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"source":_path,"record":record,"converter":Vid.VERSION if _format == "classic-vid-v1" else Images.VERSION,"provider":"classic"}

func _load() -> Dictionary:
	var file := FileAccess.open(_path,FileAccess.READ)
	if file == null: return _failure("source_unavailable","Read-only open failed.")
	var length := file.get_length()
	if _initialized and length != _length:
		file.close()
		return _failure("malformed_or_unsupported","Source length changed; restart required.")
	var bytes := file.get_buffer(length)
	var error := file.get_error()
	file.close()
	if bytes.size() != length or error != OK: return _failure("source_unavailable","Incomplete source read.")
	return {"ok":true,"bytes":bytes}

func initialize(path: String) -> Dictionary:
	close()
	_path = path
	var name := path.get_file().to_upper()
	var matches := (_format == "classic-img-v1" and name.ends_with(".IMG")) or (_format == "classic-cif-v1" and name.ends_with(".CIF")) or (_format == "classic-rci-v1" and name.ends_with(".RCI")) or (_format == "classic-texture-v1" and name.begins_with("TEXTURE.")) or (_format == "classic-palette-v1" and name.get_extension() in ["PAL","COL"])
	matches = matches or (_format == "classic-vid-v1" and name.ends_with(".VID"))
	if not matches: return _failure("malformed_or_unsupported","Declared media format does not match the source family.")
	var loaded := _load()
	if not loaded.ok: return loaded
	_length = loaded.bytes.size()
	var checked := _decode(loaded.bytes,0,0)
	if not checked.ok: return checked
	_initialized = true
	return {"ok":true,"source":_path,"format":_format,"file_bytes":_length,"stage":"checked_reader","open_mode":"READ"}

func _decode(bytes: PackedByteArray, record: int, frame: int) -> Dictionary:
	var decoder := Images.new()
	var decoded := decoder.palette(bytes,_path.get_file().to_upper() == "MAP.PAL") if _format == "classic-palette-v1" else decoder.decode(bytes,_path.get_file(),record,frame)
	if _format == "classic-vid-v1":
		if record != 0: return _failure("record_not_found","VID has one sequence record.",record)
		decoded = Vid.new().decode(bytes,frame)
	if not decoded.ok:
		decoded.source = _path
		decoded.record = {"record":record,"frame":frame}
		decoded.provider = "classic"
		return decoded
	decoded.schema = Value.SCHEMA
	decoded.identity = {"origin":"classic","domain":decoded.domain,"local_id":"%s/%d/%d" % [_path.get_file().to_upper(),record,frame]}
	decoded.provenance = {"source":_path,"record":record,"frame":frame,"position":decoded.get("position",0),"converter":decoded.get("converter",Images.VERSION),"provider":"classic","format":_format}
	decoded.erase("ok")
	return {"ok":true,"kind":"ready","source":_path,"value":Value.new(decoded)}

func read_record(address: Variant) -> Dictionary:
	if not _initialized: return _failure("before_readiness","Reader is not initialized.",address)
	if not address is Dictionary or address.size() != 2 or not address.get("record") is int or not address.get("frame") is int:
		return _failure("malformed_or_unsupported","Media address requires exact integer record and frame fields.",address)
	if _format == "classic-palette-v1" and (address.record != 0 or address.frame != 0): return _failure("record_not_found","Palette has only record/frame 0.",address)
	var loaded := _load()
	if not loaded.ok: return loaded
	return _decode(loaded.bytes,address.record,address.frame)

func inventory() -> Dictionary:
	return {"source":_path,"reader_id":get_instance_id(),"format":_format,"file_bytes":_length,"open_mode":"READ"}
