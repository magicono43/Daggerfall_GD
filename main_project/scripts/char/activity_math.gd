extends RefCounted
## Candidate arithmetic only: never mutates an actor, consumes RNG or grants time.
## Durations <=1e9 microseconds bound rate*duration <=1e18 (signed int64).
const Policy = preload("res://scripts/data/activity_policy.gd")
const F = preload("res://scripts/rule/actor_formulas.gd")
const MINUTE := 60000000
const MAX_DURATION := 1000000000

static func fail(reason: String) -> Dictionary:
	return {"ok":false,"reason":reason}

static func context_valid(c: Variant) -> bool:
	if not c is Dictionary or c.size() != 8: return false
	for key in ["climbing", "running", "voluntary_motion", "passive_motion", "swimming", "riding", "athleticism", "improved_athleticism"]:
		if typeof(c.get(key)) != TYPE_BOOL: return false
	return true

static func adjusted(base: int, c: Dictionary, policy: Dictionary) -> int:
	var index := 0
	if c.athleticism: index = 2 if c.improved_athleticism else 1
	var ratio: Dictionary = policy.athleticism[index]
	return F.floor_ratio(base*int(ratio.numerator),int(ratio.denominator))

static func segment(policy: Variant, context: Variant, game_usec: Variant, simulation_usec: Variant, fatigue_remainder: Variant, running_remainder: Variant, swimming_failure: Variant) -> Dictionary:
	# Complete raw validation precedes conversion, arithmetic and field access.
	if not Policy.validate(policy).is_empty() or not context_valid(context): return fail("Invalid activity policy/context.")
	if not F.integer(game_usec,0,MAX_DURATION) or not F.integer(simulation_usec,0,MAX_DURATION): return fail("Bounded, separately owned clock durations required.")
	var period := int(policy.running_cadence_usec)
	if not F.integer(fatigue_remainder,0,MINUTE-1) or not F.integer(running_remainder,0,period-1): return fail("Invalid retained remainder.")
	if typeof(swimming_failure) != TYPE_BOOL: return fail("Checked Swimming outcome required.")
	var selected := "ordinary"
	for activity: String in policy.priority:
		if activity == "ordinary" or (activity == "climbing" and context.climbing) or (activity == "running" and context.running and context.voluntary_motion) or (activity == "swimming" and context.swimming):
			selected = activity
			break
	var rate_key: String = "swimming-failure" if selected == "swimming" and swimming_failure else selected
	var rate := adjusted(policy.rates[rate_key],context,policy)
	# Fractional fatigue is a numerator over MINUTE, shared across rate changes.
	var numerator: int = rate*game_usec+fatigue_remainder
	var cadence: int = running_remainder
	if context.running and context.voluntary_motion and not context.riding:
		cadence += simulation_usec
	return {"ok":true,"selected":selected,"rate":rate,"drain":F.floor_ratio(numerator,MINUTE),"fatigue_remainder":numerator%MINUTE,"running_requested":F.floor_ratio(cadence,period)*int(policy.practice_amounts.running),"running_remainder":cadence%period}

static func practice(before: Variant, requested: Variant, cap: Variant) -> Dictionary:
	if not F.integer(before,0,1000000000) or not F.integer(requested,0,1000000000) or not F.integer(cap,0,1000000000): return fail("Strict bounded raw practice required.")
	# A lowered cap must not reduce previously accumulated practice.
	var applied := mini(requested,maxi(0,cap-before))
	return {"ok":true,"before":before,"requested":requested,"applied":applied,"after":before+applied,"remainder":requested-applied}
