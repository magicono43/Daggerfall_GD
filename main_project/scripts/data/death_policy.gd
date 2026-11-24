extends RefCounted
## Supported CHAR-023 parameters. Benefit chance/cost remains with its owner.
const F = preload("res://scripts/rule/actor_formulas.gd")
const D = preload("res://scripts/data/actor_input_formats.gd")
const P = preload("res://scripts/mod/package_library.gd")

static func validate(v: Variant) -> String:
	if not v is Dictionary or v.size() != 8 or v.get("schema") != "actor-death-policy-v1": return "Complete death policy required."
	if not D.integer(v.get("numerator"),0,1000000) or not D.integer(v.get("denominator"),1,1000000) or v.numerator > v.denominator or not D.integer(v.get("minimum"),1,1000000000): return "Bounded survival fraction/minimum required."
	if not v.get("priorities") is Dictionary or v.priorities.size() > 64: return "Bounded priority overrides required."
	for id in v.priorities:
		if not P.valid_id(id) or not D.integer(v.priorities[id],-1000000,1000000): return "Invalid prevention priority."
	for key in ["fade_seconds","return_seconds"]:
		if typeof(v.get(key)) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(v[key])) or v[key] < 0 or v[key] > 60: return "Finite presentation duration in 0..60 required."
	if v.fade_seconds > v.return_seconds: return "Fade must finish before return."
	if not v.get("audio") is String or (not v.audio.is_empty() and not P.valid_id(v.audio)): return "Optional owner-resolved audio identity required."
	if not v.audio.is_empty():
		var ordinal: String = v.audio.trim_prefix("classic-ordinal-")
		if not v.audio.begins_with("classic-ordinal-") or not ordinal.is_valid_int() or str(int(ordinal)) != ordinal or int(ordinal) < 0 or int(ordinal) > 1000000: return "Supported audio uses classic-ordinal-N record identity."
	return ""

static func health(maximum: int, policy: Dictionary) -> int:
	# Product <=1e15, within signed int64. Positive maxima validated by CHAR.
	return mini(maximum,maxi(int(policy.minimum),F.floor_ratio(maximum*int(policy.numerator),int(policy.denominator))))
