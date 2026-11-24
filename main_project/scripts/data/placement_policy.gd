extends RefCounted
## DATA validates replaceable layout policy; MOVE owns its physical interpretation.
static func baseline() -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/placement.json"))
	return value if value is Dictionary and reason(value).is_empty() else {}

static func resolved(value: Dictionary) -> Dictionary:
	if not reason(value).is_empty(): return {}
	var result := value.duplicate(true)
	result.offsets = []
	for offset: Variant in value.offsets:
		result.offsets.append(offset if offset is Vector3 else Vector3(offset[0],offset[1],offset[2]))
	return result

static func reason(p: Variant) -> String:
	if not p is Dictionary or p.size() != 10 or p.get("anchor_mode") not in ["sole","door-aperture-clearance"] or not p.get("id") is String or p.id.is_empty() or not p.get("provenance") is Dictionary or p.provenance.is_empty(): return "Complete placement policy required."
	for key in ["radius","height","margin","support_depth","max_slope_degrees","max_distance"]:
		if not (p.get(key) is float or p.get(key) is int) or not is_finite(float(p[key])): return "Finite metre/degree policy values required."
	if p.radius < 0.05 or p.radius > 1.0 or p.height < p.radius*2 or p.height > 3.0 or p.margin < 0.001 or p.margin > 0.02: return "Unsupported capsule or clearance margin."
	if p.support_depth <= p.margin or p.support_depth > 0.20 or p.max_slope_degrees < 0 or p.max_slope_degrees > 45 or p.max_distance < 0 or p.max_distance > 1.0: return "Unsupported support/slope/correction envelope."
	if not p.get("offsets") is Array or p.offsets.size() > 32: return "Bounded ordered candidate list required."
	for offset: Variant in p.offsets:
		if offset is Array:
			if offset.size() != 3: return "Three metre coordinates required."
			for number: Variant in offset:
				if not (number is float or number is int) or not is_finite(float(number)): return "Finite candidate required."
			offset = Vector3(offset[0],offset[1],offset[2])
		if not offset is Vector3 or not offset.is_finite() or offset.length() > p.max_distance or offset == Vector3.ZERO: return "Candidate exceeds local bound or duplicates exact pose."
	return ""
