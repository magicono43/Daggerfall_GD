extends RefCounted
## Validated replaceable assembly inputs; gameplay bindings remain later owners.
static func reason(value: Variant) -> String:
	if not value is Dictionary or value.size() != 4+int(value.has("doorways"))+int(value.has("placement_policy")) or value.get("schema") != "location-assembly-declarations-v1" or not preload("res://scripts/data/actor_input_formats.gd").integer(value.get("ground_archive"),0,511) or not value.get("required_bindings") is Array or not value.get("hit_rules") is Array: return "Complete location assembly declarations required."
	if value.has("placement_policy"):
		var problem := preload("res://scripts/data/placement_policy.gd").reason(value.placement_policy)
		if not problem.is_empty(): return problem
	if value.has("doorways"):
		var problem := preload("res://scripts/data/location_doorway_schema.gd").reason(value.doorways)
		if not problem.is_empty(): return problem
	var owners := {}
	for binding in value.required_bindings:
		if not binding is Dictionary or binding.size() != 2 or not binding.get("record") is String or binding.record.is_empty() or not binding.get("owner") is String or binding.owner.is_empty() or owners.has(binding.record): return "Distinct complete required scoped binding required."
		owners[binding.record] = true
	var regions := {}
	for rule in value.hit_rules:
		if not rule is Dictionary or rule.size() != 2 or not rule.get("candidates") is Array or rule.candidates.size() < 2 or not rule.get("selected") is String or not rule.candidates.has(rule.selected): return "Explicit overlapping hit candidates and selected identity required."
		var unique := {}
		for id in rule.candidates:
			if not id is String or id.is_empty() or unique.has(id) or regions.has(id): return "Duplicate/conflicting hit selection declaration."
			unique[id] = true
			regions[id] = true
	return ""
