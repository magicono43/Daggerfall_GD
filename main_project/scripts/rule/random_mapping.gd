extends RefCounted
const Source = preload("res://scripts/rule/random_source.gd")
static func bounded(source: Variant, bound: Variant) -> Dictionary:
	if typeof(bound) != TYPE_INT or bound < 1 or bound > 0xffffffff:
		return {"ok": false, "error": "invalid_bound"}
	if not source is Source:
		return {"ok": false, "error": "invalid_source"}
	var threshold: int = 4294967296 % bound
	var requests := 0
	while true:
		var result: Variant = source.raw()
		requests += 1
		if not result is Dictionary or not result.get("ok", false) or typeof(result.get("value")) != TYPE_INT or result.value < 0 or result.value > 0xffffffff:
			return {"ok": false, "error": "invalid_raw", "raw_requests": requests}
		if result.value >= threshold:
			source.logical_count += 1
			return {"ok": true, "value": result.value % bound, "raw_requests": requests}

	return {"ok": false, "error": "unreachable"}

static func percentile(chance: Variant, source: Variant) -> Dictionary:
	if typeof(chance) != TYPE_INT:
		return {"ok": false, "error": "invalid_chance"}
	if not source is Source:
		return {"ok": false, "error": "invalid_source"}
	var draw: Variant = source.bounded(100)
	if not draw is Dictionary or not draw.get("ok", false) or typeof(draw.get("value")) != TYPE_INT or draw.value < 0 or draw.value >= 100:
		return {"ok": false, "error": "invalid_percentile"}
	var effective: int = clampi(chance, 0, 100)
	var roll: int = draw.value + 1
	return {"ok": true, "chance": chance, "effective_chance": effective, "roll": roll,
		"success": roll <= effective, "failure": roll > effective}



