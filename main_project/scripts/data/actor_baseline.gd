extends RefCounted
## Focused CHAR numeric policy. Structural actor inputs retain their own gates.
const DOMAIN := "actor.baseline"
const VERSION := "actor-baseline-v1"
const ATTRIBUTES := ["strength","intelligence","willpower","agility","endurance","personality","speed","luck"]
const SKILLS := ["medical","etiquette","streetwise","jumping","orcish","harpy","giantish","dragonish","nymph","daedric","spriggan","centaurian","impish","lockpicking","mercantile","pickpocket","stealth","swimming","climbing","backstabbing","dodging","running","destruction","restoration","illusion","alteration","thaumaturgy","mysticism","short-blade","long-blade","hand-to-hand","axe","blunt-weapon","archery","critical-strike"]
const F = preload("res://scripts/data/actor_input_formats.gd")
const P = preload("res://scripts/mod/package_library.gd")

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"required_resources":["policy","activity","recovery","death","vitals"],"capabilities":["data."+VERSION]}
func validate_resource_path(path: String) -> String:
	return "" if path in ["policy", "activity", "recovery", "death", "vitals"] else "Only declared actor policies are supported."
func bundled_contributions() -> Array:
	var contributions: Array = []
	for file in ["baseline.json","activity.json","recovery.json","death.json","vitals.json"]:
		contributions.append({"root":"res://content/actors","file":file,"version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/actors/"+file)})
	return contributions
func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var next := previous.duplicate(true)
	for field in fields: next[field] = fields[field]
	return {"ok":true,"value":next}
func validate_record(id: String, v: Dictionary) -> String:
	if v.get("schema") == "vitals-view-v1": return preload("res://scripts/data/vitals_policy.gd").validate(v) if id == "player" else "Only player vitals view supported."
	if v.get("schema") == "actor-death-policy-v1": return preload("res://scripts/data/death_policy.gd").validate(v) if id == "player" else "Only player death policy supported."
	if v.get("schema") == "actor-recovery-policy-v1": return preload("res://scripts/data/recovery_policy.gd").validate(v) if id == "player" else "Only player recovery policy supported."
	if v.get("schema") == "actor-activity-policy-v1":
		return preload("res://scripts/data/activity_policy.gd").validate(v) if id == "player" else "Only player activity policy is supported."
	if id != "player" or v.size() != 5 or v.get("schema") != VERSION or not v.get("attributes") is Dictionary or not v.get("skills") is Dictionary or not v.get("multipliers") is Dictionary or v.get("fatigue_scale") != 64: return "Complete versioned player numeric policy required."
	if v.attributes.size() != ATTRIBUTES.size(): return "Exactly eight approved attributes required."
	for attribute in ATTRIBUTES:
		if not v.attributes.has(attribute): return "Missing attribute: "+attribute
	for skill in SKILLS:
		if not v.skills.has(skill): return "Missing skill: "+skill
	for group: Dictionary in [v.attributes,v.skills]:
		if group.size() > 256: return "At most 256 supported skills."
		for key in group:
			var bound: Variant = group[key]
			if not P.valid_id(key) or not bound is Dictionary or bound.size() != (3 if group == v.attributes else 2): return "Stable identity and complete bounds required."
			if not F.integer(bound.get("min"),0,1000000) or not F.integer(bound.get("max"),0,1000000) or bound.min > bound.max: return "Permanent domain must fit 0..1000000."
			if group == v.attributes and not F.integer(bound.get("cap"),0,1000000000): return "Invalid base live cap."
	if v.multipliers.size() != 8: return "All eight encoded career multiplier cases required."
	for i in 8:
		var ratio: Variant = v.multipliers.get(str(i))
		if not ratio is Dictionary or ratio.size() != 2 or not F.integer(ratio.get("numerator"),0,1000000) or not F.integer(ratio.get("denominator"),1,1000000): return "Exact bounded rational career multipliers required."
	return ""
func validate_references(resources: Dictionary) -> Array:
	for resource in ["policy", "activity", "recovery", "death", "vitals"]:
		var record: Dictionary = resources.get(DOMAIN+":"+resource,{}).get("records",{}).get("player",{})
		var expected: String = VERSION if resource == "policy" else "actor-"+resource+"-policy-v1"
		if resource == "vitals": expected = "vitals-view-v1"
		if record.get("value",{}).get("schema") != expected:
			return [{"source":DOMAIN,"reason":"Required typed player "+resource+" policy absent."}]
	return []
