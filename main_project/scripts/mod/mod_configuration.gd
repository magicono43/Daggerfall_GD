extends RefCounted
## MOD owns committed profiles, independent drafts and explicit run-only choices.
const Library = preload("res://scripts/mod/package_library.gd")
const Planner = preload("res://scripts/mod/dependency_planner.gd")
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
var entry_busy := false
var _active_plan: Dictionary = {}
var _active_packages: Dictionary = {}
var status: Dictionary = {}
var revision := 0
var discovery_generation := 0 # Explicit rescan, distinct from plan/profile edits.
var preview_serial := 0
var sort_preview: Dictionary = {}
var suppressions: Dictionary = {} # Profile -> declaration key -> source-bound digest.

func invalidate_plan() -> void:
	revision += 1
	sort_preview.clear()

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
	if locked or entry_busy:
		return failure("Configuration is locked until application restart.")
	invalidate_plan()
	without_mods = false
	discovery_generation += 1
	discovery = Library.new(adapter).scan(root.path_join("Mods"))
	# Discard stale decisions even if a temporarily unique candidate later duplicates.
	var groups := grouped()
	for id in choices.keys():
		if not groups.has(id) or fingerprint(groups[id]) != choices[id].set:
			choices.erase(id)
	return discovery.duplicate(true)

func continue_without_mods() -> Dictionary:
	if locked or entry_busy or discovery.get("ok", true):
		return failure("Continue without mods is available only for a failed discovery root.")
	without_mods = true
	invalidate_plan()
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
	if locked or entry_busy:
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
	invalidate_plan()
	var next := committed.duplicate(true)
	next.choices = choices.duplicate(true)
	return persist(next) # Pending choice remains usable if persistence fails.

func available() -> Dictionary:
	if locked:
		return _active_packages.duplicate(true)
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
	if locked or entry_busy or not committed.get("profiles", {}).has(id):
		return failure("Profile is unavailable or configuration is locked.")
	selected = id # Drafts are retained per profile, never implicitly saved/discarded.
	invalidate_plan()
	return {"ok": true}

func edit(id: String, action: String) -> Dictionary:
	if locked or entry_busy:
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
			invalidate_plan()
			return {"ok": true}
		_: return failure("Unknown selection action.")
	var draft := pending()
	draft.entries = entries
	drafts[selected] = draft
	invalidate_plan()
	return {"ok": true}

func save_profile() -> Dictionary:
	if locked or entry_busy or committed.is_empty():
		return failure("Configuration is locked or profiles are unavailable.")
	var next := committed.duplicate(true)
	next.profiles[selected] = pending()
	next.choices = choices.duplicate(true)
	return persist(next)

func manage(action: String, name := "", confirmed := false) -> Dictionary:
	if locked or entry_busy or committed.is_empty():
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
			suppressions.erase(selected)
		selected = target
		invalidate_plan()
	return saved

func planning_input() -> Dictionary:
	var duplicate_skips: Array[String] = []
	for id: String in choices:
		if choices[id].path.is_empty() and not unresolved().has(id):
			duplicate_skips.append(id)
	return {"available": available(), "rows": rows(), "unresolved_duplicates": unresolved(),
		"duplicate_skips": duplicate_skips, "suppressions": suppressions.get(selected, {}).duplicate(true),
		"discovery_ok": not committed.is_empty() and (discovery.get("ok", false) or without_mods)}

func validate_dependencies() -> Dictionary:
	if locked:
		return _active_plan.duplicate(true)
	var plan := Planner.new().build(planning_input())
	plan.revision = revision
	plan.profile = selected
	plan.data_ready = false
	return plan

func request_sort_preview() -> Dictionary:
	if locked or entry_busy:
		return failure("Configuration is locked.")
	var plan := validate_dependencies()
	if not plan.sortable:
		sort_preview.clear()
		return {"ok": false, "reason": "Resolve missing providers, duplicate choices and cycles before sorting.", "plan": plan}
	preview_serial += 1
	sort_preview = {"ok": true, "id": preview_serial, "revision": revision, "profile": selected,
		"input": JSON.stringify(planning_input()), "order": plan.proposed_order.duplicate()}
	return sort_preview.duplicate(true)

func accept_sort_preview(id: int) -> Dictionary:
	if locked or entry_busy or sort_preview.is_empty() or sort_preview.id != id or sort_preview.revision != revision or sort_preview.profile != selected or sort_preview.input != JSON.stringify(planning_input()):
		return failure("Sort preview is stale or unavailable. Request a new preview.")
	var proposed: Array = sort_preview.order.duplicate()
	var entries := rows()
	var position := 0
	var by_id := {}
	for entry: Dictionary in entries:
		entry.erase("available")
		entry.erase("skipped")
		by_id[entry.id] = entry.duplicate(true)
	for index in entries.size():
		if proposed.has(entries[index].id):
			entries[index] = by_id[proposed[position]].duplicate(true)
			position += 1
	var draft := pending()
	draft.entries = entries
	drafts[selected] = draft
	invalidate_plan()
	return validate_dependencies()

func dismiss_sort_preview(id: int) -> Dictionary:
	if sort_preview.is_empty() or sort_preview.id != id:
		return failure("Sort preview is stale or unavailable.")
	sort_preview.clear()
	return {"ok": true}

func enable_dependency(key: String, expected_revision: int) -> Dictionary:
	if locked or entry_busy or expected_revision != revision:
		return failure("Dependency result is stale or configuration is locked.")
	var plan := validate_dependencies()
	for integration: Dictionary in plan.integrations:
		if integration.key != key or integration.optional or integration.reason != "disabled":
			continue
		var eligible := available()
		if not Planner.compatible(eligible[integration.provider].version, integration.declaration):
			return failure("Installed provider is incompatible; explicit enablement was not applied.")
		var draft := pending()
		var entries := rows()
		for entry: Dictionary in entries:
			entry.erase("available")
			entry.erase("skipped")
			if entry.id == integration.provider:
				entry.enabled = true
		draft.entries = entries
		drafts[selected] = draft
		var omitted: Array = skips.get(selected, []).duplicate()
		omitted.erase(integration.provider)
		skips[selected] = omitted
		invalidate_plan()
		return validate_dependencies()
	return failure("No compatible disabled required provider was offered for this relationship.")

func suppress_optional(key: String, expected_revision: int) -> Dictionary:
	if locked or entry_busy or expected_revision != revision:
		return failure("Dependency result is stale or configuration is locked.")
	var plan := validate_dependencies()
	if not plan.suppressible.has(key):
		return failure("Only an optional integration participating in an ordering cycle can be suppressed.")
	for integration: Dictionary in plan.integrations:
		if integration.key == key and integration.optional:
			var profile_suppressions: Dictionary = suppressions.get(selected, {}).duplicate(true)
			profile_suppressions[key] = integration.binding
			suppressions[selected] = profile_suppressions
			invalidate_plan()
			return validate_dependencies()
	return failure("Optional integration is unavailable.")

func restore_optional(key: String) -> Dictionary:
	if locked or entry_busy:
		return failure("Configuration is locked.")
	var profile_suppressions: Dictionary = suppressions.get(selected, {}).duplicate(true)
	profile_suppressions.erase(key)
	suppressions[selected] = profile_suppressions
	invalidate_plan()
	return validate_dependencies()

func integration_allowed(key: String, consumer: String, expected_revision: int) -> bool:
	if expected_revision != revision or consumer not in ["contributions", "hooks"]:
		return false
	var plan := validate_dependencies()
	if not plan.ok:
		return false
	for integration: Dictionary in plan.integrations:
		if integration.key == key:
			return integration[consumer + "_allowed"]
	return false

func formula_provider(id: String, version: String, integration: String = "") -> Dictionary:
	# Identity/order eligibility only. Trusted controlled Callables do not activate
	# package executables; real executable admission remains IMP-050/051.
	var plan := validate_dependencies()
	var packages := available()
	if not plan.ok or id not in plan.order or not packages.has(id) or packages[id].version != version:
		return failure("Formula provider is not the selected enabled package/version in the valid MOD plan.")
	if not integration.is_empty() and not integration_allowed(integration,"hooks",revision):
		return failure("Formula provider integration is not eligible for hooks.")
	return {"ok":true,"package":packages[id].duplicate(true),"revision":revision,"order":plan.order.duplicate()}

func selection() -> Dictionary:
	if committed.is_empty():
		return {"ok": false, "reason": "Profiles are unavailable.", "dependency_ready": false, "data_ready": false}
	return {"profile": selected, "pending": pending(), "saved": committed.profiles[selected].duplicate(true),
		"available": available(), "unresolved_duplicates": unresolved(), "run_skips": skips.get(selected, []).duplicate(),
		"discovery_ok": discovery.get("ok", false) or without_mods, "without_mods": without_mods,
		"dependency_ready": validate_dependencies().ok, "data_ready": locked, "locked": locked}

func commit_entry_profile(save_edits: bool) -> Dictionary:
	if locked or not entry_busy:
		return failure("Menu commit reservation is required.")
	var next := committed.duplicate(true)
	if save_edits:
		next.profiles[selected] = pending()
	next.choices = choices.duplicate(true)
	next.last_successful = selected
	return persist(next)

func lock_configuration(plan: Dictionary, packages: Dictionary) -> void:
	_active_plan = plan.duplicate(true)
	_active_plan.data_ready = true
	_active_packages = packages.duplicate(true)
	locked = true
	entry_busy = false
	sort_preview.clear()

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
