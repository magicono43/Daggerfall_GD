extends RefCounted
## Read-only TEXT.RSC directory. Payload interpretation belongs to text_tokens.gd.
const VERSION := "text-rsc-v1"
var _path := ""
var _length := 0
var _index: Dictionary = {}

func close() -> void:
	_index.clear()

func failure(kind: String, reason: String, record: Variant = null, position := -1) -> Dictionary:
	return {"ok":false,"kind":kind,"source":_path,"record":record,"position":position,"reason":reason,"reader":VERSION}

func initialize(path: String) -> Dictionary:
	close()
	_path = path
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null:
		return failure("source_unavailable","Read-only TEXT.RSC open failed.")
	_length = file.get_length()
	var result := _read_index(file)
	file.close()
	if not result.ok:
		close()
	return result

func _read_index(file: FileAccess) -> Dictionary:
	if _length < 14:
		return failure("malformed_text","Truncated TEXT.RSC header/directory.",null,0)
	var header := file.get_16()
	if file.get_error() != OK:
		return failure("source_unavailable","TEXT.RSC header read failed.",null,0)
	if header < 12 or header % 6 != 0 or header + 2 > _length:
		return failure("malformed_text","Invalid six-byte directory extent.",null,0)
	var count := header / 6 - 1
	var entries: Array = []
	var addresses: Array = []
	for ordinal in int(count) + 1:
		var id := file.get_16()
		var offset := file.get_32()
		if file.get_error() != OK:
			return failure("source_unavailable","TEXT.RSC directory read failed.",null,2 + ordinal * 6)
		if offset < header + 2 or offset > _length:
			return failure("malformed_text","Directory address lies outside the payload.",id,2 + ordinal * 6)
		if ordinal == int(count):
			if id != 65535 or offset != _length:
				return failure("malformed_text","Invalid terminal directory entry.",id,2 + ordinal * 6)
		elif id == 65535 or _index.has(id):
			return failure("malformed_text","Reserved or duplicate record identity.",id,2 + ordinal * 6)
		else:
			_index[id] = ordinal
			if offset == _length:
				return failure("malformed_text","Record address points at terminal file boundary.",id,2 + ordinal * 6)
			if not addresses.has(offset):
				addresses.append(offset)
		entries.append({"id":id,"offset":offset})
	addresses.append(_length)
	addresses.sort()
	for ordinal in int(count):
		var entry: Dictionary = entries[ordinal]
		# Real TEXT.RSC has explicitly indexed aliases sharing one byte address.
		# Their extent ends at the next distinct address, not an inferred record ID.
		# Directory enumeration order is not physical address order or key identity.
		var next: int = addresses.find(entry.offset) + 1
		_index[entry.id] = {"offset":entry.offset,"size":addresses[next] - entry.offset}
	return {"ok":true,"source":_path,"reader":VERSION,"count":int(count),"index_bytes":header,"open_mode":"READ"}

func inventory() -> Dictionary:
	return {"source":_path,"reader":VERSION,"reader_id":get_instance_id(),"count":_index.size(),"file_bytes":_length,"open_mode":"READ"}

func read_record(record: Variant) -> Dictionary:
	if _index.is_empty():
		return failure("before_readiness","TEXT.RSC reader is not initialized.",record)
	var file := FileAccess.open(_path,FileAccess.READ)
	if file == null:
		return failure("source_unavailable","Required TEXT.RSC source is no longer available.",record)
	if file.get_length() != _length:
		file.close()
		return failure("malformed_text","Source length changed; restart required.",record)
	if not record is int or record < 0 or record >= 65535:
		file.close()
		return failure("malformed_text","TEXT.RSC requires an explicit unsigned 16-bit record ID.",record)
	if not _index.has(record):
		file.close()
		return failure("record_not_found","Explicit record ID is absent; no neighboring substitution.",record)
	var entry: Dictionary = _index[record]
	file.seek(entry.offset)
	var bytes := file.get_buffer(entry.size)
	var error := file.get_error()
	file.close()
	if bytes.size() != entry.size or error != OK:
		return failure("source_unavailable","Incomplete TEXT.RSC record read.",record,entry.offset)
	return {"ok":true,"source":_path,"reader":VERSION,"record":record,"identity":record,"offset":entry.offset,"bytes":bytes}
