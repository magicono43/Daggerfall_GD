extends RefCounted
## Pure construction arithmetic. No identity, custody, source or mutable item input.
const CONTRACT := "item-formula-v1"
const HOOKS := ["item.value","item.weight","item.condition","item.material","item.category","item.eligible"]
const Numbers = preload("res://scripts/data/actor_input_formats.gd")

func declare(registry: RefCounted) -> Dictionary:
	for hook in HOOKS:
		var result: Dictionary = registry.declare_item_hook(hook,Callable(self,hook.trim_prefix("item.")))
		if not result.ok: return result
	return {"ok":true}

static func valid_input(hook: String, v: Variant) -> bool:
	if not v is Dictionary: return false
	if hook == "item.eligible":
		if v.size() != 4 or typeof(v.get("default")) != TYPE_BOOL or typeof(v.get("template")) not in [TYPE_NIL,TYPE_BOOL] or not v.get("restrictions") is Array or not v.get("state") is Dictionary: return false
		for flag in ["equipped","quest","enchanted","summoned_nonarrow"]:
			if typeof(v.state.get(flag)) != TYPE_BOOL: return false
		return v.state.size() == 4
	if hook in ["item.material","item.category"]:
		if v.size() != 3 or not v.get("policy") is Dictionary: return false
		return Numbers.integer(v.get("level"),-1000000,1000000) and Numbers.integer(v.get("raw"),0,255 if hook == "item.material" else 99) and preload("res://scripts/data/item_construction.gd").selector_reason(v.policy).is_empty()
	if v.size() != 3 or v.get("mode") not in ["material","leather","chain","neutral"] or not v.get("coefficients") is Dictionary: return false
	var p: Dictionary = v.coefficients
	if p.size() != 3: return false
	for key in ["value","weight","condition"]:
		if not Numbers.integer(p.get(key),1,1000000): return false
	return Numbers.integer(v.get("base"),0,1000000000)

static func valid_output(hook: String, v: Dictionary, output: Variant) -> bool:
	if hook == "item.eligible":
		if typeof(output) != TYPE_INT or output not in [0,1]: return false
		for flag in v.state:
			if output == 1 and v.state[flag] and flag.trim_suffix("_nonarrow") not in v.restrictions: return false
		return true
	if typeof(output) != TYPE_INT or output < 0 or output > 1000000000000000: return false
	if hook == "item.material": return output < v.policy.materials.size()
	if hook == "item.category": return output < v.policy.categories.size()
	return true

func eligible(v: Dictionary) -> int:
	var allowed: bool = v.default if v.template == null else v.template
	for flag in v.state:
		if v.state[flag] and flag.trim_suffix("_nonarrow") not in v.restrictions: return 0
	return 1 if allowed else 0

func value(v: Dictionary) -> int:
	return int(v.base)*int(v.coefficients.value) if v.mode == "material" else int(v.base)*(2 if v.mode == "chain" else 1)

func weight(v: Dictionary) -> int:
	if v.mode == "leather": return int(v.base)/2
	if v.mode != "material": return int(v.base)
	# Base is millionths of kg. Quarter count is truncated before scaling.
	var numerator: int = (int(v.base)/250000)*int(v.coefficients.weight)
	var quarters: int = numerator/4
	var remainder: int = numerator%4
	if remainder > 2 or (remainder == 2 and quarters%2 != 0): quarters += 1
	return quarters*250000

func condition(v: Dictionary) -> int:
	return int(v.base)*int(v.coefficients.condition)/4 if v.mode == "material" else int(v.base)

func material(v: Dictionary) -> int:
	var p: Dictionary = v.policy
	var delta: int = int(v.level)-int(p.pivot)
	var remaining: int = clampi(int(v.raw)+delta*int(p.below if delta < 0 else p.above),0,256)
	for i in p.materials.size():
		if int(p.entries[i]) >= remaining: return i
		remaining -= int(p.entries[i])
	return -1

func category(v: Dictionary) -> int:
	var remaining: int = int(v.raw)
	for i in v.policy.categories.size():
		if remaining < int(v.policy.chances[i]): return i
		remaining -= int(v.policy.chances[i])
	return -1
