extends RefCounted
## Explicit replaceable policies. Geometry shape/mode qualification is narrow.
const DOMAIN := "move.mechanism"
const VERSION := "mechanism-motion-v1"
const Paths = preload("res://scripts/mod/package_library.gd")
func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"required_resources":["policy"],"capabilities":["data."+VERSION]}
func validate_resource_path(path: String) -> String:
	return "" if path == "policy" else "Only mechanism policies supported."
func bundled_contributions() -> Array:
	return [{"root":"res://content/move","file":"mechanisms.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/move/mechanisms.json")}]
func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	for key in fields: value[key] = fields[key]
	return {"ok":true,"value":value}
static func reason(value: Variant) -> String:
	if not value is Dictionary or value.size() != 9 or value.get("schema") != VERSION or value.get("shape") != "upright-box" or value.get("lethal_mode") not in ["none","grounded-crouch"] or not value.get("provenance") is Dictionary or value.provenance.is_empty() or not value.get("exceptions") is Array or value.exceptions.size() > 16: return "Complete mechanism policy and provenance required."
	for field in ["carry","push","crush"]:
		if typeof(value.get(field)) != TYPE_BOOL: return "Explicit mechanism booleans required."
	if value.crush and (not value.push or value.lethal_mode != "grounded-crouch"): return "Crush requires pushing and qualified grounded posture policy."
	if not preload("res://scripts/data/movement_feedback_policy.gd").finite(value.get("compression_metres"),0.0001,0.01): return "Finite compression tolerance in metres required."
	var seen := {}
	for exception in value.exceptions:
		if not exception is Dictionary or exception.size() != 2 or not Paths.valid_id(exception.get("id")) or seen.has(exception.id) or not exception.get("evidence") is String or exception.evidence.is_empty() or exception.evidence.length() > 4096: return "Unique stable exception identity and bounded evidence required."
		seen[exception.id] = true
	return ""
func validate_record(id: String, value: Dictionary) -> String:
	return reason(value) if preload("res://scripts/mod/package_library.gd").valid_id(id) else "Stable policy ID required."
func validate_references(resources: Dictionary) -> Array:
	return [] if not resources.get(DOMAIN+":policy",{}).get("records",{}).is_empty() else [{"source":DOMAIN,"reason":"Mechanism policy resource missing."}]
