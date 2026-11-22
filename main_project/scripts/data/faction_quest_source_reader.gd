extends RefCounted
## Explicit path only; works for res:// PCK and read-only external inputs.
const Formats = preload("res://scripts/data/faction_quest_formats.gd")
var _kind: String
var _source := ""
var _digest := ""
var _decoded: Dictionary = {}

func _init(kind: String) -> void:
	_kind = kind

func initialize(source: String) -> Dictionary:
	close()
	if DirAccess.dir_exists_absolute(source): return Formats.fail("unavailable","Source path is a directory, not a readable file.",source)
	if not FileAccess.file_exists(source): return Formats.fail("missing","Source missing.",source)
	var file := FileAccess.open(source,FileAccess.READ)
	if file == null: return Formats.fail("unavailable","Source cannot be read.",source)
	if file.get_length() > 16777216:
		file.close()
		return Formats.fail("malformed","Source exceeds 16 MiB.",source)
	var bytes := file.get_buffer(file.get_length())
	var error := file.get_error()
	file.close()
	if error != OK: return Formats.fail("unavailable","Incomplete source read.",source)
	var decoded := Formats.decode(_kind,bytes,source)
	if not decoded.ok: return decoded
	_source = source
	_digest = decoded.sha256
	_decoded = decoded.duplicate(true)
	return {"ok":true,"sha256":_digest,"source":_source}

func read_record(id := "@all") -> Dictionary:
	if _source.is_empty(): return Formats.fail("before_readiness","Reader uninitialized or retired.")
	if FileAccess.get_sha256(_source) != _digest: return Formats.fail("source_unavailable","Source changed/unavailable; restart required.",_source)
	if id == "@all": return _decoded.duplicate(true)
	if _kind != "factions" or not _decoded.records.has(id): return Formats.fail("missing","Source record absent.",_source,0,id)
	return {"ok":true,"value":_decoded.records[id].duplicate(true),"source":_source,"sha256":_digest}

func close() -> void:
	_source = ""
	_digest = ""
	_decoded.clear()
