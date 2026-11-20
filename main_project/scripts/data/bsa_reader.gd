extends RefCounted
## Classic little-endian BSA/SND container only; payload schemas belong to adapters.
var _file: FileAccess
var _index: Dictionary = {}
var _records: Array[Dictionary] = []
var _initialized := false
var _path := ""
var _length := 0
var _kind := 0

func close() -> void:
	if _file != null:
		_file.close()
	_file = null
	_index.clear()
	_records.clear()
	_initialized = false

func failure(kind: String, reason: String, record: Variant = null) -> Dictionary:
	return {"ok": false, "kind": kind, "source": _path, "record": record, "reason": reason}

func initialize(path: String) -> Dictionary:
	close()
	_path = path
	# The only source open mode in this reader. No source write API is exposed.
	_file = FileAccess.open(path, FileAccess.READ)
	if _file == null:
		return failure("source_unavailable", "Read-only open failed: %s" % error_string(FileAccess.get_open_error()))
	_length = _file.get_length()
	var checked := _read_index()
	if not checked.ok:
		close()
	else:
		_initialized = true
		_file.close()
		_file = null # Retain the index, open only the requested payload on demand.
	return checked

func _read_index() -> Dictionary:
	if _length == 0:
		return failure("malformed_or_unsupported", "Required source is empty.")
	if _length < 4:
		return failure("malformed_or_unsupported", "Truncated 4-byte BSA header.")
	var count := _file.get_16()
	_kind = _file.get_16()
	if count > 32767 or _kind not in [0x100, 0x200]:
		return failure("malformed_or_unsupported", "Unsupported BSA count/directory type.")
	var stride := 18 if _kind == 0x100 else 8
	var directory := _length - count * stride
	if directory < 4:
		return failure("malformed_or_unsupported", "Directory extends before payload/header boundary.")
	_file.seek(directory)
	var offset := 4
	for ordinal in count:
		var key: Variant
		if _kind == 0x100:
			var name := _file.get_buffer(14)
			var end := name.find(0)
			if end < 0:
				end = 14
			key = name.slice(0, end).get_string_from_ascii().to_upper()
			if str(key).is_empty():
				return failure("malformed_or_unsupported", "Empty named directory identity.", ordinal)
		else:
			key = _file.get_32()
		var size := _file.get_32()
		if size > 2147483647 or offset > directory or size > directory - offset:
			return failure("malformed_or_unsupported", "Record extent exceeds payload/index boundary.", key)
		if not _index.has(key):
			_index[key] = []
		_index[key].append(ordinal)
		_records.append({"offset": offset, "size": size, "identity": key})
		offset += size
	if _file.get_error() != OK:
		return failure("source_unavailable", "Index read failed: %s" % error_string(_file.get_error()))
	return {"ok": true, "source": _path, "count": count, "directory_type": _kind, "index_bytes": count * stride, "open_mode": "READ"}

func inventory() -> Dictionary:
	return {"source": _path, "reader_id": get_instance_id(), "count": _records.size(), "directory_type": _kind,
		"first_identity": _records[0].identity if not _records.is_empty() else null, "open_mode": "READ", "file_bytes": _length}

func read_record(record: Variant) -> Dictionary:
	if not _initialized:
		return failure("before_readiness", "Reader is not initialized.", record)
	var file := FileAccess.open(_path, FileAccess.READ)
	if file == null:
		return failure("source_unavailable", "Required source is no longer available.", record)
	if file.get_length() != _length:
		file.close()
		return failure("malformed_or_unsupported", "Source length changed; restart required.", record)
	var entry: Dictionary
	var key: Variant = record.to_upper() if record is String and _kind == 0x100 else record
	if record is Dictionary and record.size() == 1 and record.get("ordinal") is int:
		var ordinal: int = record.ordinal
		if ordinal < 0 or ordinal >= _records.size():
			file.close()
			return failure("record_not_found", "Physical record ordinal is absent.", record)
		entry = _records[ordinal]
	elif (_kind == 0x100 and not key is String) or (_kind == 0x200 and not key is int):
		file.close()
		return failure("malformed_or_unsupported", "Record identity does not match directory type.", record)
	elif not _index.has(key):
		file.close()
		return failure("record_not_found", "Record is absent from the initialized index.", record)
	else:
		if _index[key].size() != 1:
			file.close()
			return failure("malformed_or_unsupported", "Ambiguous ID query; use physical ordinal. Domain mappings belong to adapters.", record)
		entry = _records[_index[key][0]]
	file.seek(entry.offset)
	var bytes := file.get_buffer(entry.size)
	var error := file.get_error()
	file.close()
	if bytes.size() != entry.size or error != OK:
		return failure("source_unavailable", "Record read was incomplete.", record)
	return {"ok": true, "kind": "ready", "source": _path, "record": record, "identity": entry.identity, "offset": entry.offset, "bytes": bytes}
