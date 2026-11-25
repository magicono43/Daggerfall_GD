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
	if not v is Dictionary or v.size() != 16 or v.get("schema") != VERSION or not v.get("provenance") is Dictionary or v.provenance.is_empty(): return "Complete ground profile and provenance required."
	var connector_error := preload("res://scripts/data/steep_connector_policy.gd").reason(v.get("connectors"))
	if not connector_error.is_empty(): return connector_error
	return _movement_reason(v,16)

## RULE receives only the fixed-size gait/tuning projection, not a source catalog.
static func gait_reason(v: Variant) -> String:
	return _movement_reason(v,15)

static func _movement_reason(v: Variant, fields: int) -> String:
	if not v is Dictionary or v.size() != fields or v.get("schema") != VERSION or not v.get("provenance") is Dictionary or v.provenance.is_empty(): return "Complete gait profile and provenance required."
	if not (v.get("crouch_add") is float or v.get("crouch_add") is int) or not is_finite(float(v.crouch_add)) or v.crouch_add <= 0.0 or v.crouch_add > 1000000: return "Positive crouched gait domain required."
	var surface_error := surface_reason(v.get("surface"))
	if not surface_error.is_empty(): return surface_error
	var bounds := {"divisor":[0.001,1000000],"walk_add":[100,1000000],"drag":[0,1],"drag_threshold":[0,100],"run_base":[1,100],"running_divisor":[1,1000000],"sneak_divisor":[1,100],"sneak_subtract":[0,1],"metres_per_speed_unit":[0.001,100],"maximum":[0.001,1000],"moving_metres_per_second":[0.000001,0.01]}
	for key in bounds:
		var n: Variant = v.get(key)
		if not (n is float or n is int) or not is_finite(float(n)) or n < bounds[key][0] or n > bounds[key][1]: return "Unsupported finite ground profile field: "+key
	if v.crouch_add/v.sneak_divisor-v.sneak_subtract <= 0: return "Nonpositive crouched Sneak baseline."
	var minimum_walk: float = v.walk_add-v.drag*(100.0-v.drag_threshold)
	if minimum_walk <= 0.0 or minimum_walk/v.sneak_divisor-v.sneak_subtract <= 0.0: return "Profile must produce positive Walk/Sneak throughout the supported stat domain."
	return ""
static func surface_reason(v: Variant) -> String:
	var bounds := {"crouch_height":[0.2,2.0],"standing_eye":[0.1,3.0],"crouched_eye":[0.1,2.0],"posture_seconds":[0.01,1.0],"stair_seconds":[0.01,1.0],"walk_degrees":[0,70],"support_degrees":[1,85],"step_up":[0.001,0.5],"step_down":[0.001,0.5],"contact_gap":[0.002,0.02],"probe_stride":[0.005,0.1],"camera_radius":[0.03,0.15],"motion_margin":[0.001,0.02]}
	if not v is Dictionary or v.size() != bounds.size(): return "Complete surface tuning required."
	for key in bounds:
		var n: Variant = v.get(key)
		if not (n is int or n is float) or not is_finite(float(n)) or n < bounds[key][0] or n > bounds[key][1]: return "Invalid surface tuning: "+key
	if v.motion_margin >= v.contact_gap or v.support_degrees < v.walk_degrees or v.crouched_eye >= v.crouch_height or v.crouched_eye <= v.camera_radius or v.standing_eye <= v.crouched_eye: return "Incompatible surface/eye bounds."
	return ""
func validate_record(id: String, v: Dictionary) -> String:
	return reason(v) if id == "player" else "Only player profile supported."
func validate_references(resources: Dictionary) -> Array:
	return [] if resources.get(DOMAIN+":policy",{}).get("records",{}).has("player") else [{"source":DOMAIN,"reason":"Required ground profile missing."}]
