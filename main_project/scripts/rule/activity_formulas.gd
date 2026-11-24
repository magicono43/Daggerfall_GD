extends RefCounted
## Focused pure hooks. No clocks, RNG, actor state or consequence callbacks.
const CONTRACT := "activity-formula-v1"
const HOOKS := ["char.activity-rate","char.recovery-health","char.recovery-pool"]
const F = preload("res://scripts/rule/actor_formulas.gd")

func declare(registry: RefCounted) -> Dictionary:
	for hook: String in HOOKS:
		var result: Dictionary = registry.declare_activity_hook(hook,Callable(self,hook.trim_prefix("char.").replace("-","_")))
		if not result.ok: return result
	return {"ok":true}

static func valid_input(hook: String, v: Variant) -> bool:
	if not v is Dictionary: return false
	match hook:
		"char.activity-rate": return v.size() == 3 and F.integer(v.get("base"),0,1000000000) and F.integer(v.get("numerator"),0,1000) and F.integer(v.get("denominator"),1,1000)
		"char.recovery-health": return v.size() == 6 and F.integer(v.get("medical"),-1000000000,1000000000) and F.integer(v.get("endurance"),0,1000000000) and F.integer(v.get("maximum"),0,1000000000) and F.integer(v.get("term"),0,1000000) and F.integer(v.get("divisor"),1,1000000000) and F.integer(v.get("minimum"),0,1000000000)
		"char.recovery-pool": return v.size() == 4 and F.integer(v.get("maximum"),0,1000000000) and F.integer(v.get("divisor"),1,1000000000) and F.integer(v.get("minimum"),0,1000000000) and typeof(v.get("blocked")) == TYPE_BOOL
	return false

func activity_rate(v: Dictionary) -> int:
	return F.floor_ratio(v.base*v.numerator,v.denominator)
func recovery_health(v: Dictionary) -> int:
	# Product <=1.001e18, within signed int64. Medical division truncates to zero.
	var product: int = (v.medical+v.term)*v.maximum
	@warning_ignore("integer_division")
	var medical: int = absi(product)/v.divisor
	if product < 0: medical = -medical
	return maxi(v.minimum,F.floor_ratio(v.endurance,10)-5+medical)
func recovery_pool(v: Dictionary) -> int:
	return 0 if v.blocked else maxi(v.minimum,F.floor_ratio(v.maximum,v.divisor))
