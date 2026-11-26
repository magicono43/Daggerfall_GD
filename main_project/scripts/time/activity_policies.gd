extends RefCounted
## Checked fixed recurrence coverage. Equivalence belongs to the bound owner.
const Calendar = preload("res://scripts/time/calendar.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const MODES := ["bulk","coalesced","skipped","endpoint"]
static func reason(value: Variant) -> String:
	if not value is Dictionary or value.size() != 10 or value.get("mode") not in MODES or not value.get("proof") is String or not Paths.valid_id(value.proof) or not value.get("context") is String or not Paths.valid_id(value.context) or typeof(value.get("endpoint_effects")) != TYPE_BOOL or value.endpoint_effects: return "Complete non-destination-changing range policy required."
	if not Calendar.integer(value.get("first"),0,Calendar.MAX) or not Calendar.integer(value.get("period"),1,Calendar.MAX) or not Calendar.integer(value.get("count"),1,Calendar.MAX) or not Calendar.integer(value.get("revision"),1,Calendar.MAX): return "Checked native recurrence required."
	if value.count-1 > (Calendar.MAX-value.first)/value.period: return "Recurrence endpoint overflow."
	if not value.get("reasons") is Array or value.reasons.is_empty() or value.reasons.size() > 64: return "Explicit bounded activity reasons required."
	var seen := {}
	for item in value.reasons:
		if not item is String or item.is_empty() or item.length() > 160 or seen.has(item): return "Invalid or duplicate policy reason."
		seen[item] = true
	if value.get("selection") != {"bulk":"all-equivalent","coalesced":"latest-missed-and-exact","skipped":"exact-only","endpoint":"destination-only"}[value.mode]: return "Explicit supported occurrence selection required."
	return ""

static func applies(policy: Dictionary, request: Dictionary) -> bool:
	return request.get("reason") in policy.reasons and request.get("context") == policy.context

static func exact(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b): return false
	if a is Dictionary:
		if a.size() != b.size(): return false
		for key in a:
			if not b.has(key) or not exact(a[key],b[key]): return false
		return true
	if a is Array:
		if a.size() != b.size(): return false
		for i in a.size():
			if not exact(a[i],b[i]): return false
		return true
	return a == b

static func coverage(policy: Dictionary, start: Variant, endpoint: Variant) -> Dictionary:
	# O(1), integer epoch arithmetic, no occurrence materialization or cap.
	if not reason(policy).is_empty() or not Calendar.integer(start,0,Calendar.MAX) or not Calendar.integer(endpoint,0,Calendar.MAX) or endpoint < start: return {"ok":false,"reason":"Checked forward interval and recurrence required."}
	var last_due: int = policy.first+(policy.count-1)*policy.period
	var first: int = policy.count if start >= last_due else (0 if start < policy.first else (start-policy.first)/policy.period+1)
	var last: int = -1 if endpoint < policy.first else mini(policy.count-1,(endpoint-policy.first)/policy.period)
	var count: int = maxi(0,last-first+1)
	var selected: Array = []
	if count > 0:
		var exact: bool = policy.first+last*policy.period == endpoint
		if policy.mode == "coalesced":
			if count > (1 if exact else 0): selected.append(last-1 if exact else last)
			if exact: selected.append(last)
		elif policy.mode == "skipped" and exact: selected.append(last)
	return {"ok":true,"range_start":start,"range_end":endpoint,"first_index":first,"last_index":last,"count":count,"selected":selected}
