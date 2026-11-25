extends RefCounted
## Replaceable MOVE standing gait profile, through ordinary DATA/MOD publication.
const DOMAIN := "move.ground"
const VERSION := "ground-motor-v1"
func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"required_resources":["policy"],"capabilities":["data."+VERSION]}
func validate_resource_path(path: String) -> String:
	return "" if path == "policy" else "Only ground policy is supported."
func bundled_contributions() -> Array:
	return [{"root":"res://content/move","file":"ground.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/move/ground.json")}]
func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var result := previous.duplicate(true)
	for field in fields: result[field] = fields[field]
	return {"ok":true,"value":result}
static func reason(v: Variant) -> String:
	if not v is Dictionary or v.size() != 13 or v.get("schema") != VERSION or not v.get("provenance") is Dictionary or v.provenance.is_empty(): return "Complete ground profile and provenance required."
	var bounds := {"divisor":Vector2(0.001,1000000),"walk_add":Vector2(100,1000000),"drag":Vector2(0,1),"drag_threshold":Vector2(0,100),"run_base":Vector2(1,100),"running_divisor":Vector2(1,1000000),"sneak_divisor":Vector2(1,100),"sneak_subtract":Vector2(0,1),"metres_per_speed_unit":Vector2(0.001,100),"maximum":Vector2(0.001,1000),"moving_metres_per_second":Vector2(0.000001,0.01)}
	for key in bounds:
		var n: Variant = v.get(key)
		if not (n is float or n is int) or not is_finite(float(n)) or n < bounds[key].x or n > bounds[key].y: return "Unsupported finite ground profile field: "+key
	var minimum_walk: float = v.walk_add-v.drag*(100.0-v.drag_threshold)
	if minimum_walk <= 0.0 or minimum_walk/v.sneak_divisor-v.sneak_subtract <= 0.0: return "Profile must produce positive Walk/Sneak throughout the supported stat domain."
	return ""
func validate_record(id: String, v: Dictionary) -> String:
	return reason(v) if id == "player" else "Only player profile supported."
func validate_references(resources: Dictionary) -> Array:
	return [] if resources.get(DOMAIN+":policy",{}).get("records",{}).has("player") else [{"source":DOMAIN,"reason":"Required ground profile missing."}]
