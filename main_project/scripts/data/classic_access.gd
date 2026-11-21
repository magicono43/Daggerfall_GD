extends RefCounted
## Application-owned registry. Validation, prepared readers and active access differ.
const BsaReader = preload("res://scripts/data/bsa_reader.gd")
const TextReader = preload("res://scripts/data/text_rsc_reader.gd")
const MediaReader = preload("res://scripts/data/classic_media_source.gd")
const SoundDecoder = preload("res://scripts/data/classic_sound.gd")
const ModelDecoder = preload("res://scripts/data/classic_model.gd")
const HmiDecoder = preload("res://scripts/data/classic_hmi.gd")
var _declarations: Dictionary = {}
var _enabled: Array[String] = ["classic-containers-v1"]
var _active: Dictionary = {}
var _prepared: Dictionary = {}
var _active_source := ""
var _prepared_source := ""
var _serial := 0
var _prepared_ticket := 0

func same_source(first: String, second: String) -> bool:
	return first.to_lower() == second.to_lower() if OS.get_name() == "Windows" else first == second

func _init() -> void:
	register_adapter("classic-containers-v1", [
		{"file": "ARCH3D.BSA", "format": "bsa-v1"}, {"file": "BLOCKS.BSA", "format": "bsa-v1"},
		{"file": "MAPS.BSA", "format": "bsa-v1"}, {"file": "DAGGER.SND", "format": "bsa-v1"}])

func register_adapter(id: String, sources: Array) -> bool:
	if not _active.is_empty() or not _prepared.is_empty() or _declarations.has(id) or id.is_empty() or sources.is_empty():
		return false
	for entry: Dictionary in sources:
		var file := str(entry.get("file", ""))
		if file.is_empty() or file.get_file() != file or file.contains("\\") or (entry.get("format") not in ["bsa-v1", TextReader.VERSION] and entry.get("format") not in MediaReader.FORMATS):
			return false # Other formats require their actual owner implementation.
	_declarations[id] = sources.duplicate(true)
	return true

func enable_capability(id: String) -> bool:
	if not _active.is_empty() or not _prepared.is_empty():
		return false
	if not _enabled.has(id):
		_enabled.append(id) # Missing declarations fail closed in manifest composition.
	return true

func manifest() -> Dictionary:
	var entries := {}
	for id: String in _enabled:
		if not _declarations.has(id):
			return {"ok": false, "reason": "Required capability has no registered adapter: " + id, "kind": "capability_unavailable"}
		for entry: Dictionary in _declarations[id]:
			var name := str(entry.file).to_upper()
			if not entries.has(name):
				entries[name] = {"file": name, "format": entry.format, "adapters": []}
			elif entries[name].format != entry.format:
				return {"ok":false,"kind":"capability_unavailable","reason":"Conflicting reader formats for required source: " + name}
			entries[name].adapters.append(id)
	return {"ok": true, "entries": entries.values()}

func _reader(format_id: String) -> RefCounted:
	if format_id == "bsa-v1": return BsaReader.new()
	if format_id == TextReader.VERSION: return TextReader.new()
	if format_id in MediaReader.FORMATS: return MediaReader.new(format_id)
	return null

func resolve(candidate: String) -> Dictionary:
	var path := candidate.replace("\\", "/").simplify_path().trim_suffix("/")
	if candidate.is_empty() or not path.is_absolute_path():
		return _failure(path, [{"source": path, "kind": "source_unavailable", "reason": "Select an absolute ARENA2 folder or its immediate parent."}])
	var directory := DirAccess.open(path)
	if directory == null:
		return _failure(path, [{"source": path, "kind": "source_unavailable", "reason": "Cannot access selected root: " + error_string(DirAccess.get_open_error())}])
	if path.get_file().to_upper() == "ARENA2":
		return {"ok": true, "source": path}
	if directory.list_dir_begin() != OK:
		return _failure(path, [{"source": path, "kind": "source_unavailable", "reason": "Cannot enumerate selected root."}])
	var children: Array[String] = []
	var name := directory.get_next()
	while not name.is_empty():
		if name.to_upper() == "ARENA2" and directory.current_is_dir():
			children.append(name)
		name = directory.get_next()
	directory.list_dir_end()
	if children.size() != 1:
		return _failure(path, [{"source": path, "kind": "source_unavailable", "reason": "Expected one immediate ARENA2 child; found %d. No discovery fallback." % children.size()}])
	return {"ok": true, "source": path.path_join(children[0])}

func _failure(source: String, failures: Array) -> Dictionary:
	var lines: Array[String] = []
	for item: Dictionary in failures:
		lines.append("%s: %s" % [item.source, item.reason])
	return {"ok": false, "source": source, "reason": "\n".join(lines), "failures": failures, "ready": false}

func validate(candidate: String) -> Dictionary:
	var resolved := resolve(candidate)
	if not resolved.ok:
		return resolved
	var declared := manifest()
	if not declared.ok:
		return _failure(resolved.source, [{"source": resolved.source, "kind": declared.kind, "reason": declared.reason}])
	# Verify root enumeration first; never claim individual inspection on root failure.
	var directory := DirAccess.open(resolved.source)
	if directory == null or directory.list_dir_begin() != OK:
		return _failure(resolved.source, [{"source": resolved.source, "kind": "source_unavailable", "reason": "Cannot enumerate resolved root; files were not inspected."}])
	directory.list_dir_end()
	var failures: Array = []
	var checks: Array = []
	for entry: Dictionary in declared.entries:
		var reader := _reader(entry.format)
		var checked: Dictionary = reader.initialize(str(resolved.source).path_join(entry.file))
		reader.close()
		checked.manifest_entry = entry.duplicate(true)
		checks.append(checked)
		if not checked.ok:
			failures.append(checked)
	if not failures.is_empty():
		return _failure(resolved.source, failures)
	return {"ok": true, "source": resolved.source, "checks": checks, "manifest": declared.entries, "ready": false, "stage": "validated"}

func prepare(candidate: String) -> Dictionary:
	discard_prepared()
	var checked := validate(candidate)
	if not checked.ok:
		return checked
	return initialize_readers(checked)

func initialize_readers(validated: Dictionary) -> Dictionary:
	# Reread every index: validation is time-local evidence, never readiness.
	discard_prepared()
	if not validated.get("ok", false) or validated.get("stage") != "validated":
		return {"ok": false, "kind": "before_readiness", "reason": "Validated source required."}
	var checked := validated.duplicate(true)
	var declared := manifest()
	if not declared.ok:
		return declared
	checked.manifest = declared.entries
	if same_source(checked.source, _active_source) and ready():
		return {"ok": true, "source": _active_source, "ready": true, "ticket": 0, "stage": "active"}
	var failures: Array = []
	for entry: Dictionary in checked.manifest:
		var reader := _reader(entry.format)
		var initialized: Dictionary = reader.initialize(str(checked.source).path_join(entry.file))
		if initialized.ok:
			_prepared[entry.file] = reader
		else:
			initialized.manifest_entry = entry
			failures.append(initialized)
	if not failures.is_empty():
		discard_prepared()
		return _failure(checked.source, failures)
	_serial += 1
	_prepared_ticket = _serial
	_prepared_source = checked.source
	checked.ticket = _prepared_ticket
	checked.stage = "initialized_unpublished"
	return checked

func activate(checked: Dictionary) -> Dictionary:
	if checked.get("ticket", -1) == 0 and checked.get("source") == _active_source and ready():
		return {"ok": true, "source": _active_source, "ready": true}
	if _prepared.is_empty() or checked.get("ticket") != _prepared_ticket or checked.get("source") != _prepared_source:
		return {"ok": false, "reason": "No matching initialized reader set.", "kind": "before_readiness"}
	if ready():
		discard_prepared()
		return {"ok": false, "reason": "Source change requires application restart.", "kind": "restart_required"}
	_active = _prepared
	_active_source = _prepared_source
	_prepared = {}
	_prepared_source = ""
	_prepared_ticket = 0
	return {"ok": true, "source": _active_source, "ready": true}

func discard_prepared() -> void:
	for reader: RefCounted in _prepared.values():
		reader.close()
	_prepared.clear()
	_prepared_source = ""
	_prepared_ticket = 0

func ready() -> bool:
	return not _active.is_empty()

func prepared_count() -> int:
	return _prepared.size()

func inventory() -> Array:
	var view: Array = []
	for reader: RefCounted in _active.values():
		view.append(reader.inventory())
	return view

func read_record(file: String, record: Variant) -> Dictionary:
	var path := (_active_source if ready() else _prepared_source).path_join(file)
	if not ready():
		return {"ok": false, "kind": "before_readiness", "source": path, "record": record, "reason": "Required readers are not published."}
	if not _active.has(file.to_upper()):
		return {"ok": false, "kind": "source_unavailable", "source": path, "record": record, "reason": "Source has no active required reader."}
	return _active[file.to_upper()].read_record(record)

func decode_sound(record: Variant) -> Dictionary:
	# Container identity and physical ordinal remain distinct in the returned provenance.
	return SoundDecoder.new().decode(read_record("DAGGER.SND",record))

func decode_model(record: Variant) -> Dictionary:
	return ModelDecoder.new().decode(read_record("ARCH3D.BSA",record))

func decode_sequence(record: Variant) -> Dictionary:
	return HmiDecoder.new().decode(read_record("MIDI.BSA",record))

func video_source(file: String) -> Dictionary:
	if not ready() or not _active.has(file.to_upper()) or not _active[file.to_upper()].has_method("video_source"):
		return {"ok":false,"kind":"source_unavailable","reason":"An active, explicitly declared VID source is required."}
	return _active[file.to_upper()].video_source()

func dispose() -> void:
	discard_prepared()
	for reader: RefCounted in _active.values():
		reader.close()
	_active.clear()
	_active_source = ""
