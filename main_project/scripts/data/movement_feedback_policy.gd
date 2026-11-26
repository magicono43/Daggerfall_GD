extends RefCounted
## DATA owns strides/metres and optional classic sound identities, never playback.
const DOMAIN := "move.feedback"
const VERSION := "movement-feedback-v1"
const Paths = preload("res://scripts/mod/package_library.gd")
func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"required_resources":["policy"],"capabilities":["data."+VERSION]}
func validate_resource_path(path: String) -> String:
	return "" if path == "policy" else "Only feedback policy supported."
func bundled_contributions() -> Array:
	return [{"root":"res://content/move","file":"feedback.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/move/feedback.json")}]
func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	for key in fields: value[key] = fields[key]
	return {"ok":true,"value":value}
static func finite(value: Variant, minimum: float, maximum: float) -> bool:
	return (value is float or value is int) and is_finite(float(value)) and value >= minimum and value <= maximum
static func reason(p: Variant) -> String:
	if not p is Dictionary or p.size() != 10 or p.get("schema") != VERSION or not p.get("strides") is Dictionary or p.strides.size() != 3 or not p.get("surfaces") is Dictionary or p.surfaces.size() > 64 or not p.get("provenance") is Dictionary or p.provenance.is_empty(): return "Complete bounded feedback policy required."
	for gait in ["walk","run","sneak"]:
		if not finite(p.strides.get(gait),0.1,10.0): return "Finite gait stride metres required."
	for category in ["stone","ground","snow","shallow-water","swimming"]:
		if not p.surfaces.has(category): return "Approved surface mapping missing."
	for category in p.surfaces:
		var clips: Variant = p.surfaces[category]
		if not Paths.valid_id(category) or not clips is Array or clips.size() > 8: return "Bounded optional clip list required."
		for clip in clips:
			if not finite(clip,0,499) or clip != int(clip): return "Classic physical sound ordinal required."
	for field in ["hard_clip","damage_clip","splash_clip"]:
		if not finite(p.get(field),0,499) or p[field] != int(p[field]): return "Landing sound ordinal required."
	if not finite(p.get("gait_metres"),0,0.05) or not finite(p.get("mounted_metres"),0,0.05) or not finite(p.get("landing_metres"),0,0.1): return "Bounded positional feedback strength required."
	return ""
func validate_record(id: String, value: Dictionary) -> String:
	return reason(value) if id == "player" else "Only player feedback policy supported."
func validate_references(resources: Dictionary) -> Array:
	return [] if resources.get(DOMAIN+":policy",{}).get("records",{}).has("player") else [{"source":DOMAIN,"reason":"Required feedback policy missing."}]
