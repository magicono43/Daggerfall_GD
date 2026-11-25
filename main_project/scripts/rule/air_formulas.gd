extends RefCounted
const CONTRACT := "air-formula-v1"
const HOOKS := ["move.jump-impulse","move.landing-damage"]
static func valid_input(hook: String, v: Variant) -> bool:
	if not v is Dictionary or not preload("res://scripts/data/air_policy.gd").reason(v.get("profile")).is_empty(): return false
	if hook == "move.landing-damage":
		return v.size() == 2 and (v.get("distance") is float or v.get("distance") is int) and is_finite(float(v.distance)) and v.distance >= 0.0 and v.distance <= 1000000.0
	if hook != "move.jump-impulse" or v.size() != 6 or typeof(v.get("jumping")) != TYPE_INT or v.jumping < 0 or v.jumping > 1000000000: return false
	for field in ["athleticism","improved_athleticism","enhanced","crouched"]:
		if typeof(v.get(field)) != TYPE_BOOL: return false
	return true
func impulse(v: Dictionary) -> float:
	var p: Dictionary = v.profile
	return p.jump_base*(1.0+float(v.jumping)/p.jumping_divisor+(p.athleticism if v.athleticism else 0.0)+(p.improved_athleticism if v.athleticism and v.improved_athleticism else 0.0)+(p.enhanced if v.enhanced else 0.0))*(p.crouch_factor if v.crouched else 1.0)
func damage(v: Dictionary) -> float:
	return float(int(maxf(0.0,v.profile.damage_per_unit*(v.distance-v.profile.safe_distance))))
