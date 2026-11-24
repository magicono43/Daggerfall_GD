extends RefCounted
const F = preload("res://scripts/data/actor_input_formats.gd")
static func validate(v: Variant) -> String:
	if not v is Dictionary or v.size() != 10 or v.get("schema") != "actor-recovery-policy-v1": return "Complete recovery policy required."
	if not v.get("outcomes") is Dictionary or v.outcomes.size() != 3: return "Complete supported exhaustion outcomes required."
	for key in ["safe","swimming","threat"]:
		if not v.outcomes.get(key) is String or v.outcomes[key] not in ["safe-hour","lethal"]: return "Unsupported exhaustion outcome."
	for key in ["health_term","rapid_term"]:
		if not F.integer(v.get(key),0,1000000): return "Invalid health recovery term."
	for key in ["health_divisor","pool_divisor"]:
		if not F.integer(v.get(key),1,1000000000): return "Positive recovery divisor required."
	for key in ["minimum","medical_amount"]:
		if not F.integer(v.get(key),0,1000000000): return "Invalid recovery/practice amount."
	# Other durations require an explicitly supported alternative settlement policy.
	if not F.integer(v.get("collapse_duration_usec"),3600000000,3600000000): return "Only the approved complete safe hour is supported."
	var b: Variant = v.get("breath")
	if not b is Dictionary or b.size() != 4 or not b.get("mode") is String or b.mode not in ["instant","gradual"] or not F.integer(b.get("rate"),1,1000000) or not F.integer(b.get("delay_usec"),0,1000000000) or not b.get("unit") is String or b.unit != "simulated-microsecond": return "Explicit bounded breath recovery policy required."
	return ""
