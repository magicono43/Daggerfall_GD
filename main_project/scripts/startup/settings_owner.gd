class_name StartupSettingsOwner
extends RefCounted
## ConfigFile INI dialect, format 1. Unknown entries round-trip but are never applied.
var adapter: StartupStorageAdapter
var path: String
var defaults_path := "res://config/defaults.ini"
var defaults: ConfigFile
var accepted: ConfigFile
var persisted: ConfigFile
var effective: Dictionary = {}
var schema: Dictionary = {}
var groups: Dictionary = {}
var last_result: Dictionary = {}
var definition_errors: Array[String] = []

func _init(storage: StartupStorageAdapter, directory: String) -> void:
	adapter = storage
	path = directory.path_join("settings.ini")
	declare("startup/classic_path", "", TYPE_STRING, "restart")
	declare("startup/show_setup", false, TYPE_BOOL, "next_launch")

# Consumer owners register before initialize; fixtures exercise the same interface.
func declare(id: String, default_value: Variant, type: int, timing: String,
		validator := Callable()) -> void:
	if accepted != null or id.split("/").size() != 2 or timing not in ["live", "restart", "next_launch"]:
		definition_errors.append("Invalid or late setting declaration: " + id)
		return
	schema[id] = {"default": default_value, "type": type, "timing": timing, "validate": validator}

func declare_group(id: String, members: Array, validator: Callable) -> void:
	if accepted != null or members.is_empty() or not validator.is_valid():
		definition_errors.append("Invalid or late group declaration: " + id)
		return
	for member in members:
		if not schema.has(member):
			definition_errors.append("Unknown group member: " + str(member))
			return
		for existing: Dictionary in groups.values():
			if existing.members.has(member):
				definition_errors.append("Overlapping setting groups: " + str(member))
				return
	groups[id] = {"members": members, "validate": validator}

func clone(config: ConfigFile) -> ConfigFile:
	var result := ConfigFile.new()
	result.parse(config.encode_to_text())
	return result

func value(config: ConfigFile, id: String) -> Variant:
	var parts := id.split("/", true, 1)
	return config.get_value(parts[0], parts[1]) if config.has_section_key(parts[0], parts[1]) else null

func put(config: ConfigFile, id: String, new_value: Variant) -> void:
	var parts := id.split("/", true, 1)
	config.set_value(parts[0], parts[1], new_value)

func validate(config: ConfigFile, repair: bool) -> Dictionary:
	var resets: Array[String] = []
	for id: String in schema:
		var spec: Dictionary = schema[id]
		var candidate: Variant = value(config, id)
		var parts := id.split("/", true, 1)
		if not config.has_section_key(parts[0], parts[1]):
			if not repair:
				return {"ok": false, "resets": [id]}
			put(config, id, spec.default)
			continue # New owner settings are added quietly.
		var valid := typeof(candidate) == int(spec.type)
		if valid and spec.validate.is_valid():
			valid = spec.validate.call(candidate)
		if not valid:
			if not repair:
				return {"ok": false, "resets": [id]}
			put(config, id, spec.default)
			resets.append(id)
	for id: String in groups:
		var group: Dictionary = groups[id]
		if not group.validate.call(config):
			if not repair:
				return {"ok": false, "resets": [id]}
			for member: String in group.members:
				put(config, member, schema[member].default)
			resets.append("group:" + id)
	return {"ok": true, "resets": resets}

func load_config(source: String) -> ConfigFile:
	var result := ConfigFile.new()
	return result if result.load(source) == OK else null

func supported(config: ConfigFile) -> bool:
	return config != null and config.has_section_key("metadata", "format_version") and typeof(config.get_value("metadata", "format_version")) == TYPE_INT and config.get_value("metadata", "format_version") == 1

func initialize(explicit_reset := false) -> Dictionary:
	# Packaged defaults are validated before any user file is modified.
	if not definition_errors.is_empty():
		return outcome("installation_error", false, "; ".join(definition_errors))
	defaults = load_config(defaults_path)
	if not supported(defaults):
		return outcome("installation_error", false, "Invalid or missing packaged settings defaults")
	# Owner-declared defaults supply extension settings; shipped startup defaults must exist.
	for id: String in schema:
		if value(defaults, id) == null and not id.begins_with("startup/"):
			put(defaults, id, schema[id].default)
	if not validate(defaults, false).ok:
		return outcome("installation_error", false, "Packaged settings defaults failed owner validation")
	var exists := FileAccess.file_exists(path)
	var original := load_config(path) if exists else null
	var source := "active" if exists else "defaults"
	var damaged := exists and original == null
	if original != null and (not original.has_section_key("metadata", "format_version") or typeof(original.get_value("metadata", "format_version")) != TYPE_INT):
		damaged = true
		original = null
	if original != null and not supported(original):
		if not explicit_reset:
			return outcome("incompatible", false, "Unsupported settings format; Quit or explicitly reset after preserving the original")
		damaged = true
		original = null
	var chosen: ConfigFile = clone(original) if original != null else null
	var backup := load_config(path + ".backup")
	var backup_valid: bool = supported(backup) and validate(backup, false).ok
	if chosen == null:
		if damaged and backup_valid and not explicit_reset:
			chosen = clone(backup)
			source = "backup"
		else:
			chosen = clone(defaults)
			source = "defaults"
	var checked := validate(chosen, true)
	if not validate(chosen, false).ok:
		return outcome("installation_error", false, "Owner recovery defaults are incompatible")
	var needs_write := not exists or damaged or chosen.encode_to_text() != original.encode_to_text()
	if damaged:
		var input := FileAccess.open(path, FileAccess.READ)
		if input == null:
			return failed(adapter.failure("preserve_read", path))
		var length := input.get_length()
		var bytes := input.get_buffer(length)
		var read_error := input.get_error()
		input.close()
		if bytes.size() != length or read_error not in [OK, ERR_FILE_EOF]:
			return failed(adapter.failure("preserve_read", path, error_string(read_error)))
		var preserved := adapter.publish_bytes(path + ".recovery", bytes, "recovery")
		if not preserved.ok:
			return failed(preserved)
	accepted = chosen
	if needs_write:
		# Damaged input never becomes a backup. Restored backups stay intact.
		var prior: ConfigFile = original if supported(original) and validate(original, false).ok else null
		var result := publish(chosen, prior, damaged and source == "defaults")
		if not result.ok:
			return failed(result)
	persisted = clone(chosen)
	effective.clear()
	for id: String in schema:
		effective[id] = value(chosen, id)
	var recovered: bool = damaged or not checked.resets.is_empty()
	var details := "Recovered from %s; reset: %s" % [source, ", ".join(checked.resets) if not checked.resets.is_empty() else "whole file" ] if recovered else ""
	return outcome("recovered" if recovered else ("loaded" if exists else "initialized"), true, details)

func publish(candidate: ConfigFile, prior: ConfigFile = null, establish_backup := false) -> Dictionary:
	if not supported(candidate) or not validate(candidate, false).ok:
		return adapter.failure("validate", path)
	var stage := path + ".staged"
	var result := adapter.write_bytes(stage, candidate.encode_to_text().to_utf8_buffer(), "settings_stage")
	if not result.ok:
		return result
	var reopened := load_config(stage)
	if not supported(reopened) or not validate(reopened, false).ok or reopened.encode_to_text() != candidate.encode_to_text():
		return adapter.failure("settings_verify", stage)
	if prior != null and prior.encode_to_text() != candidate.encode_to_text():
		result = adapter.publish_bytes(path + ".backup", prior.encode_to_text().to_utf8_buffer(), "backup")
	elif establish_backup:
		result = adapter.publish_bytes(path + ".backup", defaults.encode_to_text().to_utf8_buffer(), "backup")
	if not result.ok:
		return result
	return adapter.replace(stage, path, "settings_publish")

func save_accepted() -> Dictionary:
	if persisted != null and accepted.encode_to_text() == persisted.encode_to_text():
		return {"ok": true, "unsaved": false}
	var result := publish(accepted, persisted)
	if result.ok:
		persisted = clone(accepted)
	result.unsaved = not result.ok
	return result

func apply(edits: Dictionary, apply_live := Callable()) -> Dictionary:
	var candidate := clone(accepted)
	for id: String in edits:
		if not schema.has(id):
			return {"ok": false, "kind": "rejected", "id": id}
		put(candidate, id, edits[id])
	if not validate(candidate, false).ok:
		return {"ok": false, "kind": "rejected"}
	# A group is an indivisible application unit. Deferred groups never call a consumer.
	var units: Array = []
	var grouped: Array = []
	for group: Dictionary in groups.values():
		units.append(group.members)
		grouped.append_array(group.members)
	for id: String in schema:
		if not grouped.has(id):
			units.append([id])
	var rejected: Array = []
	for members: Array in units:
		var changed := false
		var live := true
		var values := {}
		for id: String in members:
			changed = changed or value(candidate, id) != value(accepted, id)
			live = live and schema[id].timing == "live"
			values[id] = value(candidate, id)
		if not changed:
			continue
		if live and (not apply_live.is_valid() or not apply_live.call(values)):
			rejected.append_array(members)
			continue # Consumer contract: false retains/restores previous working group.
		for id: String in members:
			put(accepted, id, values[id])
			if live:
				effective[id] = values[id]
	var result := save_accepted()
	result.rejected = rejected
	result.pending = pending()
	result.application = "accepted" if rejected.is_empty() else "partial_or_rejected"
	return result

func pending() -> Array:
	var result: Array = []
	for id: String in schema:
		if value(accepted, id) != effective.get(id):
			result.append(id)
	return result

func outcome(kind: String, ok: bool, detail: String) -> Dictionary:
	last_result = {"ok": ok, "kind": kind, "detail": detail}
	return last_result.duplicate(true)

func failed(result: Dictionary) -> Dictionary:
	last_result = result.duplicate(true)
	last_result.kind = "publication_failed"
	last_result.choices = ["Retry", "Quit"]
	return last_result.duplicate(true)
