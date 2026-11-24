extends RefCounted
## Pure scheduling shared by CHAR intake/reconstruction. No consumption formula.
const F = preload("res://scripts/rule/actor_formulas.gd")
const D = preload("res://scripts/data/actor_input_formats.gd")
static func resolve(policy: Variant, saved: Variant, reserve: Variant, context: Variant, elapsed: Variant, maximum: Variant) -> Dictionary:
	var failure := {"ok":false,"kind":"unavailable","reason":"Explicit compatible breath recovery state required; consumption/drowning unavailable."}
	if not policy is Dictionary or policy.size() != 4 or policy.get("mode") not in ["instant","gradual"] or not D.integer(policy.get("rate"),1,1000000) or not D.integer(policy.get("delay_usec"),0,1000000000) or policy.get("unit") != "simulated-microsecond" or not F.integer(elapsed,0,1000000000) or not F.integer(maximum,0,1000000000): return failure
	if not saved is Dictionary or saved.size() != 4 or typeof(saved.get("holding")) != TYPE_BOOL or typeof(saved.get("breathable")) != TYPE_BOOL or not F.integer(saved.get("delay"),0,int(policy.delay_usec)) or not F.integer(saved.get("remainder"),0,999999): return failure
	if not context is Dictionary or context.size() != 2 or typeof(context.get("holding")) != TYPE_BOOL or typeof(context.get("breathable")) != TYPE_BOOL or (context.holding and context.breathable): return failure
	if not reserve is Dictionary or reserve.size() != 3 or not reserve.has_all(["state","reserve","policy"]): return failure
	if reserve.reserve == null:
		if reserve != {"state":"uninitialized","reserve":null,"policy":"activity-owner-pending"}: return failure
	elif not F.integer(reserve.reserve,0,maximum) or reserve.state != "owner-pending" or reserve.policy != policy: return failure
	var state: Dictionary = saved.duplicate(true)
	var breath: Dictionary = reserve.duplicate(true)
	if context.holding and breath.reserve == null:
		if maximum == 0: return failure
		breath = {"state":"owner-pending","reserve":maximum,"policy":policy.duplicate(true)}
	if context.holding:
		if breath.reserve == 0 or elapsed > 0: return failure
		state.delay = int(policy.delay_usec)
	elif context.breathable and breath.reserve != null:
		if policy.mode == "instant":
			breath.reserve = maximum
			state.delay = 0
			state.remainder = 0
		else:
			var wait := mini(elapsed,state.delay)
			state.delay -= wait
			var numerator: int = state.remainder+(elapsed-wait)*int(policy.rate)
			breath.reserve = mini(maximum,breath.reserve+F.floor_ratio(numerator,1000000))
			state.remainder = numerator%1000000
	state.holding = context.holding
	state.breathable = context.breathable
	return {"ok":true,"state":state,"breath":breath}
