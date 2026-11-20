extends RefCounted
## MOD owns committed profiles, independent drafts and explicit run-only choices.
const Library = preload("res://scripts/mod/package_library.gd")
var adapter: StartupStorageAdapter
var root := ""
var path := ""
var committed: Dictionary = {}
var drafts: Dictionary = {}
var selected := "default"
var choices: Dictionary = {}
var skips: Dictionary = {}
var discovery: Dictionary = {}
var without_mods := false
var locked := false
var status: Dictionary = {}

func _init(storage: StartupStorageAdapter, storage_root: String) -> void:
	adapter = storage
	root = storage_root
	path = root.path_join("settings/mod_profiles.json")

func failure(reason: String) -> Dictionary:
	status = {"ok": false, "reason": reason, "path": path}
	return status.duplicate(true)

func initialize() -> Dictionary:
	if not committed.is_empty():
		return {"ok": true}
	var defaults := {"schema": 1, "next_id": 1, "last_successful": "", "choices": {},
		"profiles": {"default": {"name": "Default", "entries": []}}}
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return failure("Mod profiles cannot be read; Retry after repairing access.")
		var text := file.get_as_text()
		file.close()
		var parser := JSON.new()
		var parsed_ok := parser.parse(text) == OK
		var parsed: Variant = parser.data
		if not parsed_ok or not valid_store(parsed):
			return failure("Invalid or unsupported mod profile store; original retained. Repair the file and Retry.")
		committed = parsed.duplicate(true)
	else:
		var saved := persist(defaults)
		if not saved.ok:
			return saved
	selected = committed.last_successful if committed.profiles.has(committed.last_successful) else "default"
	choices = committed.choices.duplicate(true)
	return {"ok": true}

static func valid_store(value: Variant) -> bool:
	if not value is Dictionary or value.get("schema") != 1 or not value.get("profiles") is Dictionary or not value.get("choices") is Dictionary:
		return false
	if not value.profiles.has("default") or not value.get("last_successful") is String or not value.get("next_id") is float and not value.get("next_id") is int:
		return false
	if value.next_id < 1 or value.next_id != floor(value.next_id):
		return false
	for key in value.profiles:
		var profile: Variant = value.profiles[key]
		if not Library.valid_id(key) or not profile is Dictionary or not valid_name(profile.get("name")) or not profile.get("entries") is Array:
			return false
		var seen := {}
		for entry in profile.entries:
			if not entry is Dictionary or not Library.valid_id(entry.get("id")) or not entry.get("enabled") is bool or seen.has(entry.id):
				return false
			seen[entry.id] = true
	if value.profiles.default.name != "Default":
		return false
	for id in value.choices:
		var choice: Variant = value.choices[id]
		if not Library.valid_id(id) or not choice is Dictionary or not choice.get("set") is Array or not choice.get("path") is String:
			return false
		for copy in choice.set:
			if not copy is Dictionary or not copy.get("path") is String or copy.get("id") != id or not Library.valid_version(copy.get("version")):
				return false
	return true

static func valid_name(value: Variant) -> bool:
	if not value is String or value != value.strip_edges() or value.is_empty() or value.length() > 80:
		return false
	for character in value:
		if character.unicode_at(0) < 32:
			return false
	return true

func persist(next: Dictionary) -> Dictionary:
	var saved := adapter.publish_bytes(path, JSON.stringify(next, "\t").to_utf8_buffer(), "mod_profiles_publish")
	if not saved.ok:
		status = saved.duplicate(true)
		status.reason = "Mod configuration was not saved. Committed profiles and pending edits were retained."
		return status.duplicate(true)
	committed = next.duplicate(true)
	status = {"ok": true, "detail": "Mod configuration saved; validation and publication are still required."}
	return status.duplicate(true)

func rescan() -> Dictionary:
	if locked:
		return failure("Configuration is locked until application restart.")
	without_mods = false
	discovery = Library.new(adapter).scan(root.path_join("Mods"))
	# Discard stale decisions even if a temporarily unique candidate later duplicates.
	var groups := grouped()
	for id in choices.keys():
		if not groups.has(id) or fingerprint(groups[id]) != choices[id].set:
			choices.erase(id)
	return discovery.duplicate(true)

func continue_without_mods() -> Dictionary:
	if locked or discovery.get("ok", true):
		return failure("Continue without mods is available only for a failed discovery root.")
	without_mods = true
	return {"ok": true, "kind": "run_only_empty_library", "reason": "Discovery omitted for this run. Dependency, DATA and SAVE checks are still required."}

func grouped() -> Dictionary:
	var groups := {}
	if without_mods:
		return groups
	for candidate: Dictionary in discovery.get("candidates", []):
		if not groups.has(candidate.id):
			groups[candidate.id] = []
		groups[candidate.id].append(candidate.duplicate(true))
	return groups

func fingerprint(copies: Array) -> Array:
	var result := []
	for copy: Dictionary in copies:
		result.append({"path": str(copy.path).to_lower(), "id": copy.id, "version": copy.version})
	result.sort_custom(func(a: Dictionary, b: Dictionary): return a.path < b.path)
	return result

func choose_copy(id: String, source: String, expected_set: Array) -> Dictionary:
	if locked:
		return failure("Configuration is locked.")
	var groups := grouped()
	if not groups.has(id) or groups[id].size() < 2 or expected_set != fingerprint(groups[id]):
		return failure("Duplicate candidates changed; review the current copies.")
	var allowed := source.is_empty()
	for copy: Dictionary in groups[id]:
		allowed = allowed or copy.path == source
	if not allowed:
		return failure("Choose a listed copy or explicitly skip this ID.")
	choices[id] = {"set": expected_set.duplicate(true), "path": source.to_lower()}
	var next := committed.duplicate(true)
	next.choices = choices.duplicate(true)
	return persist(next) # Pending choice remains usable if persistence fails.

func available() -> Dictionary:
	var result := {}
	var groups := grouped()
	for id in groups:
		if groups[id].size() == 1:
			result[id] = groups[id][0].duplicate(true)
		elif choices.has(id) and choices[id].set == fingerprint(groups[id]):
			for copy: Dictionary in groups[id]:
				if str(copy.path).to_lower() == choices[id].path:
					result[id] = copy.duplicate(true)
	return result

func unresolved() -> Array:
	var result := []
	var groups := grouped()
	for id in groups:
		if groups[id].size() > 1 and (not choices.has(id) or choices[id].set != fingerprint(groups[id])):
			result.append(id)
	result.sort()
	return result

func pending() -> Dictionary:
	if committed.is_empty():
		return {"name": "", "entries": []}
	if not drafts.has(selected):
		drafts[selected] = committed.profiles[selected].duplicate(true)
	return drafts[selected].duplicate(true)

func dirty() -> bool:
	return not committed.is_empty() and pending() != committed.profiles[selected]

func rows() -> Array:
	var result: Array = pending().entries.duplicate(true)
	var seen := {}
	var eligible := available()
	for entry: Dictionary in result:
		seen[entry.id] = true
	var ids := grouped().keys()
	ids.sort()
	for id: String in ids:
		if not seen.has(id):
			result.append({"id": id, "enabled": false})
	for entry: Dictionary in result:
		entry.available = eligible.has(entry.id)
		entry.skipped = skips.get(selected, []).has(entry.id)
	return result

func select_profile(id: String) -> Dictionary:
	if locked or not committed.get("profiles", {}).has(id):
		return failure("Profile is unavailable or configuration is locked.")
	selected = id # Drafts are retained per profile, never implicitly saved/discarded.
	return {"ok": true}

func edit(id: String, action: String) -> Dictionary:
	if locked:
		return failure("Configuration is locked.")
	var entries := rows()
	var position := -1
	for index in entries.size():
		entries[index].erase("available")
		entries[index].erase("skipped")
		if entries[index].id == id:
			position = index
	if position < 0:
		return failure("Unknown package ID.")
	match action:
		"toggle": entries[position].enabled = not entries[position].enabled
		"up", "down":
			var target := position + (-1 if action == "up" else 1)
			if target >= 0 and target < entries.size():
				var entry: Dictionary = entries.pop_at(position)
				entries.insert(target, entry)
		"remove": entries.remove_at(position)
		"skip", "restore":
			var omitted: Array = skips.get(selected, []).duplicate()
			if action == "skip" and not omitted.has(id):
				omitted.append(id)
			elif action == "restore":
				omitted.erase(id)
			skips[selected] = omitted
			return {"ok": true}
		_: return failure("Unknown selection action.")
	var draft := pending()
	draft.entries = entries
	drafts[selected] = draft
	return {"ok": true}

func save_profile() -> Dictionary:
	if locked or committed.is_empty():
		return failure("Configuration is locked or profiles are unavailable.")
	var next := committed.duplicate(true)
	next.profiles[selected] = pending()
	next.choices = choices.duplicate(true)
	return persist(next)

func manage(action: String, name := "", confirmed := false) -> Dictionary:
	if locked or committed.is_empty():
		return failure("Configuration is locked or profiles are unavailable.")
	if action == "delete" and not confirmed:
		return {"ok": false, "kind": "confirmation_required", "profile": selected}
	if action in ["rename", "delete"] and selected == "default":
		return failure("Default remains available; duplicate it to rename or delete a custom profile.")
	if action != "delete":
		if not valid_name(name):
			return failure("Profile name must be 1–80 trimmed characters without control characters.")
		for id in committed.profiles:
			if (id != selected or action != "rename") and str(committed.profiles[id].name).to_lower() == name.to_lower():
				return failure("Profile name is already used.")
	var next := committed.duplicate(true)
	var target := selected
	match action:
		"create", "duplicate":
			target = "profile-%d" % int(next.next_id)
			while next.profiles.has(target):
				next.next_id += 1
				target = "profile-%d" % int(next.next_id)
			next.next_id += 1
			next.profiles[target] = pending() if action == "duplicate" else {"name": name, "entries": []}
			next.profiles[target].name = name
		"rename": next.profiles[selected].name = name
		"delete":
			next.profiles.erase(selected)
			if next.last_successful == selected:
				next.last_successful = ""
			target = "default"
		_: return failure("Unknown profile action.")
	var saved := persist(next)
	if saved.ok:
		if action == "rename" and drafts.has(selected):
			drafts[selected].name = name
		if action == "delete":
			drafts.erase(selected)
			skips.erase(selected)
		selected = target
	return saved

func selection() -> Dictionary:
	if committed.is_empty():
		return {"ok": false, "reason": "Profiles are unavailable.", "dependency_ready": false, "data_ready": false}
	return {"profile": selected, "pending": pending(), "saved": committed.profiles[selected].duplicate(true),
		"available": available(), "unresolved_duplicates": unresolved(), "run_skips": skips.get(selected, []).duplicate(),
		"discovery_ok": discovery.get("ok", false) or without_mods, "without_mods": without_mods,
		"dependency_ready": false, "data_ready": false, "locked": locked}

func read_package_file(id: String, relative: String) -> Dictionary:
	var eligible := available()
	if not eligible.has(id):
		return failure("Package is unavailable, skipped or needs an explicit duplicate choice.")
	var mods_root := root.path_join("Mods").replace("\\", "/")
	var source: String = eligible[id].path
	if source.to_lower() != mods_root.to_lower() and not source.to_lower().begins_with(mods_root.to_lower() + "/"):
		return failure("Package source is outside the active Mods root.")
	var current := mods_root
	var parts := source.substr(mods_root.length()).trim_prefix("/").split("/", false)
	parts.insert(0, "")
	for part in parts:
		if not part.is_empty():
			current = current.path_join(part)
		var state := adapter.platform("inspect", current)
		if not state.ok or state.detail in ["link", "missing"]:
			return failure("Package source contains an inaccessible entry or filesystem link: " + current)
	return Library.new(adapter).read_bytes(eligible[id], relative)
