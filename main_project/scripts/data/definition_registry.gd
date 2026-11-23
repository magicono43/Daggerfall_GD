extends RefCounted
## DATA owns clean candidate definitions and committed read-only projections.
const Paths = preload("res://scripts/mod/package_library.gd")
var _adapters: Dictionary = {}
var _candidate: Dictionary = {}
var _active: Dictionary = {}
var _serial := 0
var _started := false
var _loose: Dictionary = {}
var _omissions: Dictionary = {}
var _commit_ticket := -1
var _omission_revision := -1
var timings: Dictionary = {} # Diagnostic microseconds; no latency acceptance budget.
var faults: Dictionary = {} # Isolated verification seams, not player settings.

func validate_adapter(adapter: RefCounted) -> Dictionary:
	if _started or not _active.is_empty():
		return failure("registration_closed", "adapters", "Register content adapters before source preparation.")
	for method: String in ["declaration", "validate_record", "patch_record", "validate_references"]:
		if not adapter.has_method(method):
			return failure("adapter_invalid", "adapters", "Adapter lacks " + method)
	var declaration: Dictionary = adapter.declaration()
	if not Paths.valid_id(declaration.get("id")) or not Paths.valid_id(declaration.get("domain")) or _adapters.has(declaration.domain):
		return failure("adapter_invalid", "adapters", "Adapter ID/domain must be stable and domain ownership unique.")
	if not declaration.get("operations") is Array or not declaration.get("required_resources", []) is Array:
		return failure("adapter_invalid", "adapters", "Declare supported operations and required resources.")
	if declaration.has("reference_domains"):
		if not declaration.reference_domains is Array:
			return failure("adapter_invalid", "adapters", "Reference domains must be an array.")
		for domain in declaration.reference_domains:
			if not Paths.valid_id(domain):
				return failure("adapter_invalid", "adapters", "Reference domains must be stable domain IDs.")
	for operation in declaration.operations:
		if operation not in ["add", "patch", "replace"]:
			return failure("adapter_invalid", "adapters", "Unsupported operation declaration.")
	for path in declaration.get("required_resources", []):
		if not path is String or not Paths.relative_path(path).ok:
			return failure("adapter_invalid", "adapters", "Required resources need normalized relative paths.")
	return {"ok": true, "declaration": declaration}

func register_adapter(adapter: RefCounted, root: String, files: Array) -> Dictionary:
	var checked := validate_adapter(adapter)
	if not checked.ok:
		return checked
	var declaration: Dictionary = checked.declaration
	_adapters[declaration.domain] = {"adapter": adapter, "declaration": declaration.duplicate(true), "root": root, "files": files.duplicate(true)}
	return {"ok": true}

func failure(kind: String, source: String, reason: String, token := "", omittable := false) -> Dictionary:
	return {"ok": false, "kind": kind, "source": source, "reason": reason, "token": token, "omittable": omittable}

func read_file(storage: StartupStorageAdapter, root: String, relative: String) -> Dictionary:
	var normalized := Paths.relative_path(relative)
	if not normalized.ok:
		return failure("invalid_path", root, "Unsupported or escaping contribution path: " + relative)
	var path := root
	var components := relative.replace("\\", "/").split("/")
	components.insert(0, "")
	for component in components:
		if not component.is_empty():
			path = path.path_join(component)
		var state := storage.platform("inspect", path)
		if not state.ok:
			return failure("unreadable", path, state.detail)
		if state.detail == "missing":
			return failure("missing", path, "Declared contribution is missing.")
		if state.detail == "link":
			return failure("invalid_path", path, "Filesystem links are not valid contribution sources.")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return failure("unreadable", path, "Contribution cannot be read.")
	if file.get_length() > 16777216:
		return failure("invalid", path, "Contribution exceeds the 16 MiB intake limit.")
	var bytes := file.get_buffer(file.get_length())
	var error := file.get_error()
	file.close()
	return {"ok": true, "bytes": bytes} if error == OK else failure("unreadable", path, "Incomplete contribution read.")

func collect_loose(storage: StartupStorageAdapter, root: String, relative := "") -> Dictionary:
	var path := root.path_join(relative)
	var state := storage.platform("inspect", path)
	if state.ok and state.detail == "missing" and relative.is_empty():
		return {"ok": true, "files": []}
	if not state.ok or state.detail != "directory":
		return failure("unreadable", path, "Loose override root/subdirectory is unreadable or a link; descendants were not inspected.")
	var directory := DirAccess.open(path)
	if directory == null or directory.list_dir_begin() != OK:
		return failure("unreadable", path, "Loose override directory cannot be enumerated.")
	var names: Array[String] = []
	var name := directory.get_next()
	while not name.is_empty():
		names.append(name)
		name = directory.get_next()
	directory.list_dir_end()
	names.sort()
	var files: Array = []
	for child in names:
		var child_relative := relative.path_join(child)
		state = storage.platform("inspect", root.path_join(child_relative))
		if not state.ok or state.detail in ["link", "missing"]:
			return failure("invalid_path", root.path_join(child_relative), "Loose override contains a link or inaccessible entry.")
		if state.detail == "directory":
			var nested := collect_loose(storage, root, child_relative)
			if not nested.ok:
				return nested
			files.append_array(nested.files)
		else:
			files.append(child_relative)
	return {"ok": true, "files": files}

func source_entries(storage: StartupStorageAdapter, provider: String, root: String, files: Array, mods: RefCounted = null, plan: Dictionary = {}) -> Array:
	var result: Array = []
	var seen := {}
	for item in files:
		var relative: String = item if item is String else str(item.get("file", "")) if item is Dictionary else ""
		var normalized := Paths.relative_path(relative)
		var source := {"provider": provider, "root": root, "file": relative, "version": str(mods.available()[provider].version) if mods != null else "builtin"}
		if not normalized.ok or relative.get_extension().to_lower() not in ["json", "csv"]:
			result.append({"source": source, "read": failure("invalid_path", root, "Contributions must be package-relative JSON or versioned CSV files.")})
			continue
		if seen.has(normalized.path):
			result.append({"source": source, "read": failure("ambiguous_path", root, "Ambiguous normalized contribution path: " + normalized.path)})
			# Mark the earlier entry invalid too: enumeration cannot select a winner.
			result[seen[normalized.path]].read = failure("ambiguous_path", root, "Ambiguous normalized contribution path: " + normalized.path)
			continue
		seen[normalized.path] = result.size()
		source.file = normalized.path
		if item is Dictionary and item.has("integration"):
			var key: String = str(item.integration)
			var declared := false
			var active := false
			for integration: Dictionary in plan.get("integrations", []):
				if integration.key == key and integration.dependent == provider:
					declared = true
					active = integration.active
			if not declared:
				result.append({"source": source, "read": failure("invalid", root, "Contribution integration must name this package's declared relationship.")})
				continue
			if not active:
				result.append({"source": source, "inactive": true})
				continue
		var read: Dictionary = mods.read_package_file(provider, relative) if mods != null else read_file(storage, root, relative)
		result.append({"source": source, "read": read})
	result.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.source.file) < str(b.source.file))
	return result

func prepare(mods: RefCounted) -> Dictionary:
	var started := Time.get_ticks_usec()
	if _commit_ticket >= 0:
		return failure("busy", "definitions", "Menu commit owns the candidate.")
	if not _active.is_empty():
		return failure("locked", "definitions", "Published definitions are locked until restart.")
	timings = {"validators":{},"prepare_serial":_serial+1}
	_started = true
	_serial += 1
	_candidate.clear()
	for registered: Dictionary in _adapters.values():
		if registered.adapter.has_method("begin_candidate"):
			registered.adapter.begin_candidate(mods, _serial, self)
	var plan: Dictionary = mods.validate_dependencies()
	if not plan.ok:
		return failure("dependencies", "packages", "A validated MOD plan is required.")
	if _omission_revision != mods.revision:
		_omissions.clear()
		_omission_revision = mods.revision
	if _adapters.is_empty():
		return failure("adapters_unavailable", "packages", "Required domain definition adapters are unavailable in this build.")
	var entries: Array = []
	var domains := _adapters.keys()
	domains.sort()
	for domain: String in domains:
		var registered: Dictionary = _adapters[domain]
		if registered.adapter.has_method("bundled_contributions"):
			for bundled: Dictionary in registered.adapter.bundled_contributions():
				entries.append({"source":{"provider":"@shipped/" + str(registered.declaration.id),"root":bundled.get("root","res://content/text"),"file":bundled.file,"version":bundled.get("version","text-catalog-v1")},"read":bundled.get("read",{"ok":true,"bytes":bundled.get("bytes",PackedByteArray())})})
		entries.append_array(source_entries(mods.adapter, "@shipped/" + str(registered.declaration.id), registered.root, registered.files))
	var capabilities: Array = []
	for domain: String in domains:
		capabilities.append_array(_adapters[domain].declaration.get("capabilities", []))
	var eligible: Dictionary = mods.available()
	for id: String in plan.order:
		var package: Dictionary = eligible[id]
		for capability: String in package.capabilities:
			if not capabilities.has(capability):
				return failure("capability_unavailable", package.path, "Required package capability is unavailable (executable activation is not implemented): " + capability)
		var files: Variant = package.manifest.get("content", [])
		if not files is Array:
			return failure("invalid", package.path, "Manifest content must be an array of contribution files.")
		entries.append_array(source_entries(mods.adapter, id, package.path, files, mods, plan))
	if _loose.is_empty():
		var loose_root: String = mods.root.path_join("Overrides")
		var catalog := collect_loose(mods.adapter, loose_root)
		if not catalog.ok:
			catalog.reason += " Repair loose overrides and restart; live adoption is unsupported."
		var declarations: Array = []
		var media := {}
		if catalog.ok:
			for file: String in catalog.files:
				var normalized := Paths.relative_path(file)
				if _adapters.has("media.assets") and normalized.ok and normalized.path.begins_with("media/") and normalized.path.get_extension() in ["png","wav","ogg","glb","mid","sf2","webm","mp4"]:
					if media.has(normalized.path):
						catalog = failure("ambiguous_path",loose_root,"Ambiguous normalized loose media path; repair and restart: " + normalized.path)
						break
					media[normalized.path] = read_file(mods.adapter,loose_root,file)
				else:
					declarations.append(file)
		_loose = {"ok": catalog.ok, "entries": source_entries(mods.adapter, "@loose", loose_root, declarations) if catalog.ok else [], "media":media, "failure": catalog}
	if not _loose.ok:
		return _loose.failure.duplicate(true)
	entries.append_array(_loose.entries.duplicate(true))
	var resources := {}
	var issues: Array = []
	var omitted: Array = []
	var inactive: Array = []
	for entry: Dictionary in entries:
		if entry.get("inactive", false):
			inactive.append(entry.source.duplicate(true))
			continue
		var read: Dictionary = entry.read
		var digest: String = read.bytes.hex_encode().sha256_text() if read.ok else JSON.stringify(read).sha256_text()
		var token: String = (JSON.stringify(entry.source) + digest).sha256_text()
		var omittable: bool = not str(entry.source.provider).begins_with("@shipped/") and read.get("kind", "") not in ["ambiguous_path", "invalid_path"]
		if _omissions.has(token):
			omitted.append(entry.source.duplicate(true))
			continue
		entry.source.token = token
		var applied: Dictionary = _apply_owned_contribution(resources, read.bytes, entry.source) if read.ok else read
		if not applied.ok:
			var issue := failure(applied.get("kind", "invalid"), JSON.stringify(entry.source), applied.reason, token, omittable)
			if applied.has("schema"): issue.input_failure = applied.duplicate(true)
			for context: String in ["record","referring","line","target","provider"]:
				if applied.has(context): issue[context] = applied[context]
			issues.append(issue)
		else:
			resources = applied.resources
	timings.intake_usec = Time.get_ticks_usec()-started
	for domain: String in domains:
		var registered: Dictionary = _adapters[domain]
		for required: String in registered.declaration.get("required_resources", []):
			var normalized := Paths.relative_path(required)
			if not normalized.ok or not resources.has(domain + ":" + str(normalized.get("path", ""))):
				issues.append(failure("missing", domain + ":" + required, "Required logical resource is missing; omission cannot bypass it."))
		var validation_started := Time.get_ticks_usec()
		# Each validator still receives detached data. Legacy adapters retain the
		# whole-catalog contract; declared readers copy only their dependencies.
		var validation_input := {}
		if registered.declaration.has("reference_domains"):
			for key: String in resources:
				if key.get_slice(":",0) in registered.declaration.reference_domains:
					validation_input[key] = resources[key].duplicate(true)
		else:
			validation_input = resources.duplicate(true)
		var copied := Time.get_ticks_usec()
		var references: Array = registered.adapter.validate_references(validation_input)
		timings.validators[domain] = {"copy_usec":copied-validation_started,"validate_usec":Time.get_ticks_usec()-copied}
		for reference: Dictionary in references:
			var issue := failure("references", str(reference.get("source", domain)), str(reference.reason), str(reference.get("token", "")), bool(reference.get("omittable", false)))
			for context: String in ["target","provider","referring","line","record","cycle","candidates"]:
				if reference.has(context): issue[context] = reference[context].duplicate(true) if reference[context] is Dictionary else reference[context]
			issues.append(issue)
	_candidate = {"ok": issues.is_empty(), "ticket": _serial, "revision": mods.revision, "profile": mods.selected,
		"input": JSON.stringify(mods.planning_input()), "plan": plan.duplicate(true), "packages": {}, "resources": resources,
		"issues": issues, "omitted": omitted, "inactive": inactive, "source": "packages", "stage": "candidate", "ready": false,
		"reason": "Definition validation failed; fix/remove or explicitly omit a listed contribution." if not issues.is_empty() else "Definitions validated; actual menu entry is still required."}
	for id: String in plan.order:
		_candidate.packages[id] = eligible[id].duplicate(true)
	for registered: Dictionary in _adapters.values():
		if registered.adapter.has_method("finish_candidate"):
			registered.adapter.finish_candidate(resources, issues.is_empty())
	timings.prepare_usec = Time.get_ticks_usec()-started
	var projected := projection()
	timings.projection_usec = Time.get_ticks_usec()-started-int(timings.prepare_usec)
	return projected

func apply_contribution(base: Dictionary, bytes: PackedByteArray, source: Dictionary) -> Dictionary:
	# Public authoring/fixture callers receive an independent candidate. During
	# prepare the owner already owns all resources, and copies only the resource
	# being changed; untouched resources are never mutated or exposed directly.
	return _apply_owned_contribution(base.duplicate(true),bytes,source)

func _apply_owned_contribution(base: Dictionary, bytes: PackedByteArray, source: Dictionary) -> Dictionary:
	if str(source.get("file", "")).get_extension().to_lower() == "csv":
		for registered: Dictionary in _adapters.values():
			if registered.declaration.get("formats", []).has("text-csv-v1") and registered.adapter.has_method("apply_csv"):
				return registered.adapter.apply_csv(base, bytes, source.duplicate(true))
		return failure("reader_unavailable", JSON.stringify(source), "No registered text-csv-v1 reader.")
	var text := bytes.get_string_from_utf8()
	var json := JSON.new()
	if text.to_utf8_buffer() != bytes or (not text.is_empty() and text.unicode_at(0) == 0xfeff) or json.parse(text) != OK or not json.data is Dictionary:
		return failure("invalid", JSON.stringify(source), "Contribution must be a UTF-8 JSON object without BOM.")
	var contribution: Dictionary = json.data
	var domain: String = str(contribution.get("domain", ""))
	var path := Paths.relative_path(str(contribution.get("path", "")))
	if not _adapters.has(domain) or not path.ok or not contribution.get("entries") is Array:
		return failure("invalid", JSON.stringify(source), "Contribution needs a registered domain, normalized path and entries array.")
	var registered: Dictionary = _adapters[domain]
	if registered.adapter.has_method("validate_resource_path"):
		var reason: String = registered.adapter.validate_resource_path(path.path)
		if not reason.is_empty():
			return failure("invalid", JSON.stringify(source), reason)
	if not registered.declaration.get("json_envelopes", true):
		return failure("invalid", JSON.stringify(source), "This domain requires its versioned reader; JSON envelopes are unsupported.")
	var operation: String = str(contribution.get("operation", ""))
	if not registered.declaration.operations.has(operation):
		return failure("invalid", JSON.stringify(source), "Operation is not supported by this adapter: " + operation)
	var logical_path: String = path.path
	if registered.adapter.has_method("resource_path"):
		logical_path = registered.adapter.resource_path(logical_path,source.duplicate(true))
	var key := domain + ":" + logical_path
	var working := base.duplicate(false)
	var previous: Dictionary = working.get(key, {"domain": domain, "path": logical_path, "records": {}, "contributors": [], "winner": {}})
	var target: Dictionary = previous.duplicate(true)
	if operation == "replace":
		if registered.adapter.has_method("validate_replace"):
			var replacement: Dictionary = registered.adapter.validate_replace(previous.duplicate(true),contribution.entries.duplicate(true))
			if not replacement.get("ok",false): return replacement
		target.records = {}
	var seen := {}
	for entry in contribution.entries:
		entry = entry.duplicate(true) if entry is Dictionary else entry
		if entry is Dictionary and entry.get("id") is String and entry.get("value") is Dictionary and registered.adapter.has_method("record_id"):
			entry.id = registered.adapter.record_id(entry.id,entry.value,logical_path)
		if not entry is Dictionary or not entry.get("id") is String or not Paths.valid_id(entry.id) or not entry.get("value") is Dictionary or (operation != "patch" and seen.has(entry.id)):
			return failure("invalid", key, "Entries require stable IDs/object values; add/replace IDs must be unique; deletion is unsupported.")
		seen[entry.id] = true
		var exists: bool = target.records.has(entry.id) if operation == "patch" else previous.records.has(entry.id)
		var prior: Dictionary = target.records.get(entry.id, {}) if operation == "patch" else previous.records.get(entry.id, {})
		if (operation == "add" and target.records.has(entry.id)) or (operation == "patch" and not exists):
			return failure("invalid", key, "Add collision or missing patch target: " + entry.id)
		var value: Dictionary = entry.value.duplicate(true)
		if operation == "patch":
			var patched: Dictionary = registered.adapter.patch_record(prior.value.duplicate(true), value)
			if not patched.get("ok", false):
				return failure("invalid", key, str(patched.get("reason", "Adapter rejected patch.")))
			value = patched.value.duplicate(true)
		var reason: String = registered.adapter.validate_record(entry.id, value)
		if not reason.is_empty():
			return failure("invalid", key, reason).merged({"record":entry.id,"referring":key+"#"+entry.id,"provider":source.duplicate(true),"line":value.get("data",{}).get("line",0) if value.get("data") is Dictionary else 0})
		var identity: Dictionary = prior.identity.duplicate(true) if exists else {"domain": domain, "package": source.provider, "local": str(path.path) + "#" + entry.id, "record": entry.id}
		var fields: Dictionary = prior.fields.duplicate(true) if operation == "patch" else {}
		for field: String in entry.value:
			fields[field] = source.duplicate(true)
		if registered.adapter.has_method("validate_source_record"):
			var prepared: Dictionary = registered.adapter.validate_source_record(entry.id,value.duplicate(true),fields.duplicate(true),logical_path,source.duplicate(true),identity.duplicate(true))
			if not prepared.ok:
				return prepared
		var contributors: Array = prior.contributors.duplicate(true) if exists else []
		contributors.append(source.duplicate(true))
		target.records[entry.id] = {"identity": identity, "value": value, "fields": fields, "contributors": contributors, "winner": source.duplicate(true)}
	target.contributors.append(source.duplicate(true))
	target.winner = source.duplicate(true)
	working[key] = target
	return {"ok": true, "resources": working}

func omit(token: String, ticket: int, mods: RefCounted) -> Dictionary:
	if _commit_ticket >= 0 or not _active.is_empty() or _candidate.get("ticket", -1) != ticket or _candidate.get("revision", -1) != mods.revision or _candidate.get("input", "") != JSON.stringify(mods.planning_input()):
		return failure("stale", "definitions", "Omission request is stale or definitions are locked.")
	for issue: Dictionary in _candidate.get("issues", []):
		if issue.token == token and issue.omittable:
			_omissions[token] = true
			_candidate.clear()
			return {"ok": true}
	return failure("rejected", "definitions", "This failure cannot be omitted; repair its required source or references.")

func check_commit(ticket: int, mods: RefCounted) -> Dictionary:
	if not _active.is_empty() or not _candidate.get("ok", false) or _candidate.get("ticket", -1) != ticket or _candidate.revision != mods.revision or _candidate.profile != mods.selected or _candidate.input != JSON.stringify(mods.planning_input()):
		return failure("stale", "definitions", "Candidate is invalid, obsolete or already committed. Rebuild before entry.")
	if faults.has("publish"):
		return failure("publication_failed", "definitions", "Controlled definition publication rejection.")
	return {"ok": true}

func reserve_commit(ticket: int, mods: RefCounted) -> Dictionary:
	var checked := check_commit(ticket, mods)
	if not checked.ok:
		return checked
	_commit_ticket = ticket
	return {"ok": true}

func release_commit() -> void:
	_commit_ticket = -1

func commit(ticket: int) -> Dictionary:
	# CORE already checked readiness, reserved MOD mutations, opened the menu and
	# committed profile/history. No callbacks or fallible I/O remain in this step.
	if _commit_ticket != ticket or _candidate.get("ticket", -1) != ticket or not _active.is_empty():
		return failure("stale", "definitions", "A current reserved menu commit is required.")
	# Transfer private ownership; all public projections remain detached.
	_active = _candidate
	_active.stage = "published"
	_active.ready = true
	_candidate = {}
	_commit_ticket = -1
	return active()

func projection() -> Dictionary:
	return _candidate.duplicate(true)

func read_loose_media(file: String) -> Dictionary:
	var normalized := Paths.relative_path(file)
	if not normalized.ok: return failure("invalid_path",file,"Unsupported loose media path.")
	return _loose.get("media",{}).get(normalized.path,failure("missing",file,"Loose media was absent at initial intake; restart required.")).duplicate(true)

func active() -> Dictionary:
	return _active.duplicate(true)

func content_ticket() -> int:
	# Constant-cost freshness check; never copy the complete published catalog.
	return int(_active.get("ticket",-1))

func domain_index(domain: String) -> Dictionary:
	# Optional detached domain projection. A prepared index is never readable via
	# this boundary before the exact candidate's actual CORE publication.
	if _active.is_empty(): return failure("before_readiness",domain,"Actual menu publication required.")
	if not _adapters.has(domain) or not _adapters[domain].adapter.has_method("read_only_index"): return failure("source_unavailable",domain,"Domain index provider unavailable.")
	return _adapters[domain].adapter.read_only_index(int(_active.ticket)).duplicate(true)

func dispose() -> void:
	_candidate.clear()
	_active.clear()
	_loose.clear()
	_omissions.clear()
	_adapters.clear()
	_commit_ticket = -1

func query(domain: String, path: String, id: String) -> Dictionary:
	if _active.is_empty():
		return failure("before_readiness", domain, "Definitions have not entered the actual menu commit.")
	var normalized := Paths.relative_path(path)
	var resource: Dictionary = _active.resources.get(domain + ":" + str(normalized.get("path", "")), {})
	if not normalized.ok or not resource.get("records", {}).has(id):
		return failure("missing", domain + ":" + path, "Definition record is absent: " + id)
	return {"ok": true, "record": resource.records[id].duplicate(true)}
