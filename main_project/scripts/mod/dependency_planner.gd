extends RefCounted
## Pure MOD planning. No implicit enablement, profile writes or DATA publication.
const Library = preload("res://scripts/mod/package_library.gd")

# Decimal comparison avoids integer overflow for arbitrary manifest components.
static func decimal_compare(a: String, b: String) -> int:
	a = a.lstrip("0")
	b = b.lstrip("0")
	if a.length() != b.length():
		return -1 if a.length() < b.length() else 1
	return 0 if a == b else (-1 if a < b else 1)

static func digits(value: String) -> bool:
	for character in value:
		if character < "0" or character > "9":
			return false
	return not value.is_empty()

static func compare_versions(a: String, b: String) -> int:
	var left := a.get_slice("+", 0).split("-", true, 1)
	var right := b.get_slice("+", 0).split("-", true, 1)
	var left_core := left[0].split(".")
	var right_core := right[0].split(".")
	for index in 3:
		var compared := decimal_compare(left_core[index], right_core[index])
		if compared != 0:
			return compared
	if left.size() == 1 or right.size() == 1:
		return 0 if left.size() == right.size() else (1 if left.size() == 1 else -1)
	var left_pre := left[1].split(".")
	var right_pre := right[1].split(".")
	for index in mini(left_pre.size(), right_pre.size()):
		var x := left_pre[index]
		var y := right_pre[index]
		if x == y:
			continue
		if digits(x) and digits(y):
			var compared := decimal_compare(x, y)
			if compared != 0:
				return compared
		elif digits(x) != digits(y):
			return -1 if digits(x) else 1
		else:
			return -1 if x < y else 1
	return 0 if left_pre.size() == right_pre.size() else (-1 if left_pre.size() < right_pre.size() else 1)

static func compatible(version: String, declaration: Dictionary) -> bool:
	return (not declaration.has("min") or compare_versions(version, declaration.min) >= 0) and (not declaration.has("max") or compare_versions(version, declaration.max) < 0)

static func binding(candidate: Dictionary, declaration: Dictionary, index: int) -> String:
	return JSON.stringify({"path": candidate.path, "id": candidate.id, "version": candidate.version,
		"declaration": declaration, "index": index}).sha256_text()

static func problem(kind: String, dependent: String, provider: String, reason: String) -> Dictionary:
	return {"kind": kind, "dependent": dependent, "provider": provider, "reason": reason}

func build(input: Dictionary) -> Dictionary:
	var errors: Array[Dictionary] = []
	var warnings: Array[Dictionary] = []
	var integrations: Array[Dictionary] = []
	var constraints: Array[Dictionary] = []
	var order: Array[String] = []
	var enabled := {}
	var eligible: Dictionary = input.available
	if not input.discovery_ok:
		errors.append(problem("discovery", "", "", "Installed library discovery has not succeeded."))
	for id: String in input.unresolved_duplicates:
		errors.append(problem("duplicate", "", id, "Choose an eligible copy or explicitly skip this ID before dependency planning."))
	for row: Dictionary in input.rows:
		if row.enabled and not row.skipped:
			if eligible.has(row.id):
				enabled[row.id] = true
				order.append(row.id)
			elif not input.duplicate_skips.has(row.id):
				errors.append(problem("missing_enabled", row.id, row.id, "Enabled package is missing or unresolved; repair, skip for this run, or remove it explicitly."))
	# Do not derive dependency facts from unresolved duplicate copies.
	if not input.unresolved_duplicates.is_empty() or not input.discovery_ok:
		return result(order, errors, warnings, integrations, constraints, [], [], [])
	for id: String in order:
		var candidate: Dictionary = eligible[id]
		var dependencies: Array = candidate.dependencies
		for index in dependencies.size():
			var declaration: Dictionary = dependencies[index]
			var provider: String = declaration.id
			var optional: bool = declaration.get("optional", false)
			var key := "%s:%d" % [id, index]
			var record := {"key": key, "binding": binding(candidate, declaration, index), "dependent": id,
				"provider": provider, "optional": optional, "order": declaration.get("order", "provider_first"),
				"active": false, "contributions_allowed": false, "hooks_allowed": false, "reason": "",
				"declaration": declaration.duplicate(true)}
			var kind := ""
			if not eligible.has(provider):
				kind = "missing"
			elif not enabled.has(provider):
				kind = "disabled"
			elif not compatible(eligible[provider].version, declaration):
				kind = "incompatible"
			if not kind.is_empty():
				record.reason = kind
				var issue := problem(kind, id, provider, "Provider is %s for %s." % [kind, id])
				issue.declaration = declaration.duplicate(true)
				issue.key = key
				issue.source = candidate.source.duplicate(true)
				issue.installed_version = eligible[provider].version if eligible.has(provider) else ""
				issue.can_enable = kind == "disabled" and compatible(eligible[provider].version, declaration)
				if not optional:
					errors.append(issue)
				elif kind == "incompatible":
					warnings.append(issue)
			elif optional and input.suppressions.get(key, "") == record.binding:
				record.reason = "suppressed_for_run"
			else:
				record.active = true
				record.contributions_allowed = true
				record.hooks_allowed = true
				if record.order == "provider_first":
					constraints.append({"from": provider, "to": id, "key": key, "optional": optional})
			integrations.append(record)
	var graph := {}
	for id in order:
		graph[id] = []
	for edge: Dictionary in constraints:
		if not graph[edge.from].has(edge.to):
			graph[edge.from].append(edge.to)
	for id in graph:
		graph[id].sort()
	var cycles: Array = []
	var cycle_keys: Array[String] = []
	for edge: Dictionary in constraints:
		var back := find_path(graph, edge.to, edge.from)
		if not back.is_empty():
			var loop: Array = [edge.from]
			loop.append_array(back)
			loop = canonical_cycle(loop)
			if not cycles.has(loop):
				cycles.append(loop)
			if edge.optional:
				cycle_keys.append(edge.key)
	cycles.sort_custom(func(a: Array, b: Array): return JSON.stringify(a) < JSON.stringify(b))
	for loop: Array in cycles:
		var issue := problem("cycle", str(loop[-2]), str(loop[0]), "Ordering cycle: " + " → ".join(loop))
		issue.path = loop.duplicate()
		errors.append(issue)
	var proposed: Array[String] = []
	if cycles.is_empty():
		proposed = stable_sort(order, graph)
	for edge: Dictionary in constraints:
		if order.find(edge.from) > order.find(edge.to):
			errors.append(problem("order", edge.to, edge.from, "Provider must precede dependent in the pending order."))
	return result(order, errors, warnings, integrations, constraints, cycles, cycle_keys, proposed)

func result(order: Array, errors: Array, warnings: Array, integrations: Array, constraints: Array, cycles: Array, cycle_keys: Array, proposed: Array) -> Dictionary:
	var sortable := true
	for issue: Dictionary in errors:
		if issue.kind != "order":
			sortable = false
	return {"ok": errors.is_empty(), "order": order.duplicate(), "errors": errors.duplicate(true), "warnings": warnings.duplicate(true),
		"integrations": integrations.duplicate(true), "constraints": constraints.duplicate(true), "cycles": cycles.duplicate(true),
		"suppressible": cycle_keys.duplicate(), "sortable": sortable, "proposed_order": proposed.duplicate() if sortable else []}

func find_path(graph: Dictionary, start: String, target: String) -> Array:
	var queue: Array = [[start]]
	var seen := {}
	seen[start] = true
	while not queue.is_empty():
		var path: Array = queue.pop_front()
		var node: String = path[-1]
		if node == target:
			return path
		for next: String in graph[node]:
			if not seen.has(next):
				seen[next] = true
				var expanded := path.duplicate()
				expanded.append(next)
				queue.append(expanded)
	return []

func canonical_cycle(loop: Array) -> Array:
	var body := loop.slice(0, loop.size() - 1)
	var smallest := 0
	for index in body.size():
		if body[index] < body[smallest]:
			smallest = index
	var result: Array = body.slice(smallest)
	result.append_array(body.slice(0, smallest))
	result.append(result[0])
	return result

func stable_sort(preferred: Array[String], graph: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var indegree := {}
	for id in preferred:
		indegree[id] = 0
	for id in graph:
		for dependent: String in graph[id]:
			indegree[dependent] += 1
	while result.size() < preferred.size():
		var chosen := ""
		for id in preferred:
			if not result.has(id) and indegree[id] == 0:
				chosen = id
				break
		if chosen.is_empty():
			return []
		result.append(chosen)
		for dependent: String in graph[chosen]:
			indegree[dependent] -= 1
	return result
