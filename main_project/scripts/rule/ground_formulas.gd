extends RefCounted
## Pure standing gait hook; world mapping, source stacking and cap follow in MOVE.
const CONTRACT := "ground-speed-v1"
const HOOK := "move.ground-speed"
static func valid_input(v: Variant) -> bool:
	if not v is Dictionary or v.size() not in [4,5] or (v.has("posture") and (not v.posture is String or v.posture not in ["standing","crouched"])) or v.get("gait") not in ["walk","run","sneak"] or not preload("res://scripts/data/ground_policy.gd").gait_reason(v.get("profile")).is_empty(): return false
	for key in ["speed","running"]:
		if typeof(v.get(key)) != TYPE_INT or v[key] < 0 or v[key] > 1000000000: return false
	return true
func calculate(v: Dictionary) -> float:
	var p: Dictionary = v.profile
	var s: float = v.speed
	var r: float = v.running
	var walk: float = (s+p.walk_add-p.drag*(100.0-maxf(s,p.drag_threshold)))/p.divisor
	if v.get("posture","standing") == "crouched":
		walk = (s+p.crouch_add)/p.divisor
		if v.gait == "run": return walk*(p.run_base+r/p.running_divisor)
		if v.gait == "sneak": return walk/p.sneak_divisor-p.sneak_subtract/p.divisor
		return walk
	if v.gait == "run": return ((s+p.walk_add)/p.divisor)*(p.run_base+r/p.running_divisor)
	if v.gait == "sneak": return walk/p.sneak_divisor-p.sneak_subtract/p.divisor
	return walk
