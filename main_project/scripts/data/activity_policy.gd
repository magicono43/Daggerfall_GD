extends RefCounted
## Data-only CHAR-020 policy. Integer units avoid frame-dependent rounding.
const SCHEMA := "actor-activity-policy-v1"
const F = preload("res://scripts/data/actor_input_formats.gd")
const ACTIVITIES := ["climbing", "running", "swimming", "ordinary"]

static func validate(v: Variant) -> String:
	if not v is Dictionary or v.size() != 10 or not v.get("schema") is String or v.schema != SCHEMA:
		return "Complete activity policy required."
	if not v.get("rates") is Dictionary or v.rates.size() != 5:
		return "Five supported replacement rates required."
	for key in ["ordinary", "climbing", "running", "swimming", "swimming-failure"]:
		if not F.integer(v.rates.get(key),0,1000000): return "Invalid activity rate."
	if not v.get("priority") is Array or v.priority.size() != 4:
		return "Complete activity priority required."
	var seen := {}
	for key in v.priority:
		if not key is String or key not in ACTIVITIES or seen.has(key): return "Invalid activity priority."
		seen[key] = true
	if v.priority.back() != "ordinary": return "Ordinary must be the final fallback."
	if not v.get("athleticism") is Array or v.athleticism.size() != 3: return "Three exact Athleticism ratios required."
	for ratio in v.athleticism:
		if not ratio is Dictionary or ratio.size() != 2 or not F.integer(ratio.get("numerator"),0,1000) or not F.integer(ratio.get("denominator"),1,1000): return "Invalid Athleticism ratio."
	for key in ["jump_cost", "practice_cap"]:
		if not F.integer(v.get(key),0,1000000000): return "Invalid cost or practice cap."
	if not F.integer(v.get("running_cadence_usec"),1,1000000000): return "Invalid simulated-time cadence."
	if not v.get("practice_amounts") is Dictionary or v.practice_amounts.size() != 5: return "Five supported raw-practice amounts required."
	for key in ["running","jumping","climbing","swimming","rappel"]:
		if not F.integer(v.practice_amounts.get(key),0,1000): return "Invalid raw-practice amount."
	if not v.get("game_minute_unit") is String or not v.get("simulation_unit") is String or v.game_minute_unit != "game-microsecond" or v.simulation_unit != "simulated-microsecond": return "Explicit clock domains required."
	return ""
