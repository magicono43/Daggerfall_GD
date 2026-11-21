extends RefCounted
## Leased authoring workspace. Immutable generation files + one flushed pointer
## replacement define the complete CSV/mapping/review publication boundary.
const VERSION := "translation-import-v1"
const Author = preload("res://scripts/data/text_author.gd")
const Catalog = preload("res://scripts/data/text_catalog.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
var adapter: StartupStorageAdapter
var root: String
var previews: Dictionary = {}
var serial := 0

func _init(storage: StartupStorageAdapter, directory: String) -> void:
	adapter = storage
	root = directory

func fail(reason: String, key := "") -> Dictionary:
	return {"ok":false,"kind":"translation_import","reason":reason,"key":key}

static func digest(bytes: PackedByteArray) -> String:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	return hash.finish().hex_encode()

func pointer_bytes() -> PackedByteArray:
	return FileAccess.get_file_as_bytes(root.path_join("active.ini")) if FileAccess.file_exists(root.path_join("active.ini")) else PackedByteArray()

func load_active() -> Dictionary:
	var bytes := pointer_bytes()
	if bytes.is_empty():
		if FileAccess.file_exists(root.path_join("active.ini")):
			return fail("Unreadable or empty active pointer; repair or retry. No generation adopted.")
		return {"ok":true,"snapshot":{"schema":VERSION,"entries":{}},"pointer":bytes,"csv":""}
	var pointer := ConfigFile.new()
	if pointer.parse(bytes.get_string_from_utf8()) != OK or pointer.get_value("generation", "schema", "") != VERSION:
		return fail("Malformed/incompatible authoring pointer retained unchanged.")
	var generation: Variant = pointer.get_value("generation", "id", "")
	if not generation is String or generation.length() != 64 or not generation.is_valid_hex_number(false):
		return fail("Invalid generation identity.")
	var directory := root.path_join(generation)
	var metadata := FileAccess.get_file_as_bytes(directory.path_join("review.json"))
	var csv := FileAccess.get_file_as_bytes(directory.path_join("catalog.csv"))
	if digest(metadata) != generation or digest(csv) != pointer.get_value("generation", "csv_sha256", ""):
		return fail("Incomplete/corrupt generation; never promote staged work. Prior pointer remains authoritative.")
	var json := JSON.new()
	if json.parse(metadata.get_string_from_utf8()) != OK or not json.data is Dictionary or json.data.get("schema") != VERSION or not json.data.get("entries") is Dictionary:
		return fail("Invalid review/mapping schema.")
	var validation_entries: Dictionary = json.data.entries.duplicate(true)
	for key: String in validation_entries:
		var entry: Variant = validation_entries[key]
		if not entry is Dictionary or not entry.get("collection") is String or not Paths.valid_id(entry.collection) or not entry.get("locale") is String or not Catalog.locale_id(entry.locale) or not validate_entry(entry, entry.collection, entry.locale).ok or entry.key != key or entry.get("review") not in ["new", "reviewed", "needs-review", "orphan"]:
			return fail("Malformed saved mapping/review entry retained unchanged.", key)
		entry.operation = "add"
	var checked := Catalog.new().apply_csv({}, csv_text(validation_entries).to_utf8_buffer(), {"provider":"@authoring","file":"catalog.csv"}) if not validation_entries.is_empty() else {"ok":csv.get_string_from_utf8() == csv_text({})}
	if not checked.ok:
		return fail("Stored runtime CSV does not validate independently.")
	if csv.get_string_from_utf8() != csv_text(json.data.entries):
		return fail("CSV and mapping/review generation disagree.")
	return {"ok":true,"snapshot":json.data,"pointer":bytes,"csv":directory.path_join("catalog.csv")}

static func quote(value: Variant) -> String:
	return '"' + str(value).replace('"', '""') + '"'

static func csv_text(entries: Dictionary) -> String:
	var result := ",".join(Catalog.HEADER) + "\n"
	var keys: Array = entries.keys()
	keys.sort()
	for key: String in keys:
		var entry: Dictionary = entries[key]
		var row: Array = [Catalog.SCHEMA, Author.VERSION, entry.collection, entry.locale, key, entry.operation, entry.base, str(entry.optional), str(entry.essential), "|".join(entry.required), "false", entry.translation]
		result += ",".join(row.map(quote)) + "\n"
	return result

func validate_entry(entry: Variant, collection: String, locale: String, require_translation := true) -> Dictionary:
	if not entry is Dictionary:
		return fail("Entry must be an object.")
	for name: String in ["source_id", "key", "base", "source", "translation", "operation"]:
		if not entry.get(name) is String:
			return fail("Missing string field: " + name)
	if not Catalog.Tokens.identifier(entry.key) or entry.source_id.is_empty() or entry.source_id.length() > 256 or not Catalog.locale_id(entry.base) or entry.operation not in ["add", "replace"] or not entry.get("required") is Array or not entry.get("optional") is bool or not entry.get("essential") is bool or not entry.get("provenance") is Dictionary:
		return fail("Invalid stable mapping, base/classification or provenance.", entry.key)
	if entry.optional and entry.essential:
		return fail("Essential entries cannot be optional.", entry.key)
	var checked := Author.decode(entry.source, entry.required, entry.source_id, entry.key)
	if not checked.ok:
		return checked
	var translated := Author.decode(entry.translation, entry.required, entry.source_id, entry.key)
	if not translated.ok and require_translation:
		return translated
	var compatible: bool = translated.ok and checked.variant_ids == translated.variant_ids and Catalog.Tokens.require_structure(translated.tokens, control_signature(checked.tokens)).ok
	if not compatible and require_translation:
		return fail("Translation changes required placeholders, variant identity, operands or interaction structure.", entry.key)
	var normalized: Dictionary = entry.duplicate(true)
	normalized.collection = collection
	normalized.locale = locale
	normalized.required.sort()
	normalized.source = Author.encode(checked.tokens, checked.variant_ids, normalized.required).text
	if compatible:
		normalized.translation = Author.encode(translated.tokens, translated.variant_ids, normalized.required).text
	return {"ok":true,"entry":normalized,"translation_valid":compatible}

static func control_signature(tokens: Array) -> Array:
	var result: Array = []
	for token: Dictionary in tokens:
		if token.kind in ["text", "reference", "record_end"]:
			continue
		var item := {"kind":token.kind}
		if token.has("operand"):
			item.operand = token.operand
		result.append(item)
	return result

func preview(document: Dictionary) -> Dictionary:
	var active := load_active()
	if not active.ok:
		return active
	if document.get("schema") != VERSION or not document.get("collection") is String or not Paths.valid_id(document.collection) or not document.get("locale") is String or not Catalog.locale_id(document.locale) or not document.get("entries") is Array or document.entries.size() > 4096:
		return fail("Version, explicit collection/locale and at most 4096 mapped entries required.")
	var existing: Dictionary = active.snapshot.entries
	var rows: Dictionary = {}
	var sources: Dictionary = {}
	for entry in document.entries:
		var checked := validate_entry(entry, document.collection, document.locale, false)
		if not checked.ok:
			return checked
		var value: Dictionary = checked.entry
		var key: String = value.key
		if rows.has(key) or sources.has(value.source_id):
			return fail("Ambiguous duplicate key/source mapping; explicitly resolve it.", key)
		sources[value.source_id] = key
		var prior: Dictionary = existing.get(key, {})
		if prior.is_empty() and not checked.translation_valid:
			return fail("New entry needs a valid structural translation; nothing published.", key)
		for other: Dictionary in existing.values():
			if other.source_id == value.source_id and other.key != key:
				return fail("Source already mapped to another stable key; rename/remap needs explicit resolution.", key)
		if not prior.is_empty() and (prior.collection != value.collection or prior.locale != value.locale or prior.source_id != value.source_id or prior.base != value.base or prior.optional != value.optional or prior.essential != value.essential or prior.operation != value.operation):
			return fail("Original key/base identity, classification and mapping cannot be silently changed.", key)
		var changed: bool = not prior.is_empty() and (prior.source != value.source or prior.required != value.required)
		var candidate: Dictionary = value.duplicate(true)
		candidate.review = "needs-review" if changed else prior.get("review", "new")
		candidate.current_source = value.source
		candidate.current_required = value.required.duplicate(true)
		if not prior.is_empty():
			# Keep authored work and original publication metadata until replacement
			# is explicitly selected. Source review is independent of usability.
			candidate = prior.duplicate(true)
			candidate.current_source = value.source
			candidate.current_required = value.required.duplicate(true)
			if changed or prior.get("review") == "orphan":
				candidate.review = "needs-review"
		var replacement := value.duplicate(true)
		replacement.current_source = value.source
		replacement.current_required = value.required.duplicate(true)
		replacement.review = "reviewed"
		rows[key] = {"kind":"addition" if prior.is_empty() else "review" if candidate != prior else "replacement" if value.translation != prior.translation else "unchanged", "preserve":candidate,"replace":replacement,"has_translation":not prior.is_empty(),"replacement_changes":not prior.is_empty() and value.translation != prior.translation}
		if not checked.translation_valid:
			rows[key].erase("replace")
			rows[key].kind = "conflict"
			rows[key].replacement_error = "Replacement is incompatible with current source requirements. Existing translation can be retained with review state."
	for key: String in existing:
		if rows.has(key):
			continue
		if existing[key].collection != document.collection or existing[key].locale != document.locale:
			continue
		var orphan: Dictionary = existing[key].duplicate(true)
		orphan.review = "orphan"
		rows[key] = {"kind":"unchanged" if orphan == existing[key] else "orphan","preserve":orphan,"has_translation":true,"replacement_changes":false}
	serial += 1
	previews[serial] = {"document":document.duplicate(true),"pointer":active.pointer,"rows":rows.duplicate(true),"snapshot":active.snapshot.duplicate(true)}
	return {"ok":true,"id":serial,"rows":rows.duplicate(true),"csv":active.csv}

## selections maps stable key -> preserve/replace; unselected rows are untouched.
func commit(id: int, selections: Dictionary) -> Dictionary:
	if not previews.has(id):
		return fail("Unknown/expired preview.")
	var plan: Dictionary = previews[id]
	if pointer_bytes() != plan.pointer:
		return fail("Stale target; preview again.")
	var refreshed := preview(plan.document)
	if not refreshed.ok or refreshed.rows != plan.rows:
		return fail("Preview no longer validates.")
	var snapshot: Dictionary = plan.snapshot.duplicate(true)
	for key: String in selections:
		if not plan.rows.has(key) or selections[key] not in ["preserve", "replace"] or not plan.rows[key].has(selections[key]):
			return fail("Invalid selected operation; nothing published.", key)
		snapshot.entries[key] = plan.rows[key][selections[key]].duplicate(true)
	if snapshot == plan.snapshot:
		return {"ok":true,"kind":"unchanged","writes":0}
	var csv := csv_text(snapshot.entries).to_utf8_buffer()
	# Validate complete selected runtime output before the first durable write.
	# Replace operations need their original installed definitions; use an add
	# validation copy, preserving the authored add/replace intent in real CSV.
	var validation_entries: Dictionary = snapshot.entries.duplicate(true)
	for entry: Dictionary in validation_entries.values():
		entry.operation = "add"
	var validated := Catalog.new().apply_csv({}, csv_text(validation_entries).to_utf8_buffer(), {"provider":"@authoring","file":"catalog.csv"})
	if not validated.ok:
		return fail("Selected runtime output failed validation.")
	var metadata := JSON.stringify(snapshot, "\t").to_utf8_buffer()
	var generation := digest(metadata)
	var directory := root.path_join(generation)
	var made := adapter.directory(directory)
	if not made.ok:
		return made
	for item: Array in [["catalog.csv",csv], ["review.json",metadata]]:
		var path := directory.path_join(item[0])
		if FileAccess.file_exists(path):
			if FileAccess.get_file_as_bytes(path) != item[1]:
				return fail("Immutable generation collision/corruption; repair or use another workspace.")
		else:
			var written := adapter.publish_bytes(path, item[1], "translation_generation")
			if not written.ok:
				return written
	if pointer_bytes() != plan.pointer:
		return fail("Stale target before publication; prepared generation remains inactive.")
	var pointer := ConfigFile.new()
	pointer.set_value("generation", "schema", VERSION)
	pointer.set_value("generation", "id", generation)
	pointer.set_value("generation", "csv_sha256", digest(csv))
	var published := adapter.publish_bytes(root.path_join("active.ini"), pointer.encode_to_text().to_utf8_buffer(), "translation_publish")
	if not published.ok:
		return published
	previews.clear()
	return {"ok":true,"kind":"committed","csv":directory.path_join("catalog.csv"),"generation":generation}
