extends RefCounted
## Fixed-size published air policy. No source catalog is involved in point queries.
const DOMAIN := "move.air"
const VERSION := "air-motion-v1"
func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"required_resources":["policy"],"capabilities":["data."+VERSION]}
func validate_resource_path(path: String) -> String:
	return "" if path == "policy" else "Only air policy is supported."
func bundled_contributions() -> Array:
	return [{"root":"res://content/move","file":"air.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/move/air.json")}]
func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var result := previous.duplicate(true)
	for field in fields: result[field] = fields[field]
	return {"ok":true,"value":result}
static func reason(p: Variant) -> String:
	var bounds := {"metres_per_reference_unit":[0.01,100.0],"jump_base":[0.01,100.0],"jumping_divisor":[1.0,1000000.0],"athleticism":[0.0,10.0],"improved_athleticism":[0.0,10.0],"enhanced":[0.0,10.0],"crouch_factor":[0.01,1.0],"gravity":[0.01,1000.0],"maximum_impulse":[0.01,100.0],"maximum_downward_speed":[0.01,100.0],"steering_acceleration":[0.01,100.0],"steering_speed":[0.01,100.0],"boost_speed":[0.0,100.0],"safe_distance":[0.0,1000000.0],"damage_per_unit":[0.0,1000.0],"hard_distance":[0.0,1000000.0]}
	if not p is Dictionary or p.size() != bounds.size()+4 or p.get("schema") != VERSION or not p.get("provenance") is Dictionary or p.provenance.is_empty() or typeof(p.get("inherit_platform")) != TYPE_BOOL or typeof(p.get("slow_fall_blocks_jump")) != TYPE_BOOL: return "Complete air policy required."
	for field in bounds:
		var n: Variant = p.get(field)
		if not (n is int or n is float) or not is_finite(float(n)) or n < bounds[field][0] or n > bounds[field][1]: return "Invalid finite air policy: "+field
	if p.maximum_impulse*p.metres_per_reference_unit > 100.0 or p.maximum_downward_speed*p.metres_per_reference_unit > 100.0: return "Air speeds exceed the swept collision envelope."
	if p.steering_speed*p.metres_per_reference_unit > 100.0 or p.boost_speed*p.metres_per_reference_unit > 100.0 or p.steering_acceleration*p.metres_per_reference_unit > 1000.0 or p.gravity*p.metres_per_reference_unit > 1000.0: return "Mapped steering/force/boost exceeds the supported finite envelope."
	return ""
func validate_record(id: String, value: Dictionary) -> String:
	return reason(value) if id == "player" else "Only player air policy supported."
func validate_references(resources: Dictionary) -> Array:
	return [] if resources.get(DOMAIN+":policy",{}).get("records",{}).has("player") else [{"source":DOMAIN,"reason":"Required air policy missing."}]
