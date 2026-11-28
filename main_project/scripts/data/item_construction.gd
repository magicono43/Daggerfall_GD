extends RefCounted
## Semantic DATA adapter. Reader records remain structural, never globally enabled.
const DOMAIN := "item.construction"
const VERSION := "item-construction-v1"
const N = preload("res://scripts/data/actor_input_formats.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
var classic: RefCounted
var visual_checks := 0
static func sources() -> Array:
	# Explicit supported appearance inventory. Added providers/archives must declare
	# their own early reader support; runtime coordinate guessing is unavailable.
	var result: Array = []
	for archive in [207,233,234,235,236,237,238,239,240,241,242,245,246,247,248,249,250,251,252]:
		result.append({"file":"TEXTURE.%03d" % archive,"format":"classic-texture-v1"})
	return result
func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,"item-spell.inputs"],"operations":["add","replace","patch"],"required_resources":["profiles"],"capabilities":["data."+VERSION],"classic_sources":sources()}
func validate_resource_path(path: String) -> String:
	return "" if path == "profiles" else "Construction uses profiles."
func bundled_contributions() -> Array:
	return [{"root":"res://content/items","file":"construction.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/items/construction.json")}]
func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	return {"ok":true,"value":previous.merged(fields,true).duplicate(true)}
static func keys(v: Variant) -> bool:
	if not v is Array or v.is_empty() or v.size() > 1024: return false
	var seen := {}
	for id in v:
		if not id is String or not Paths.valid_id(id) or seen.has(id): return false
		seen[id] = true
	return true
static func selector_reason(p: Variant) -> String:
	if not p is Dictionary or p.size() != 8 or p.get("mode") != "legacy-strict" or not keys(p.get("materials")) or not keys(p.get("categories")): return "Complete strict selector required."
	if not p.get("entries") is Array or p.entries.size() != p.materials.size() or not p.get("chances") is Array or p.chances.size() != p.categories.size(): return "Complete selector mappings required."
	for key in ["pivot","below","above"]:
		if not N.integer(p.get(key),0,1000): return "Unsafe level policy."
	var sum := 0
	for n in p.entries:
		if not N.integer(n,0,1000000): return "Invalid legacy entry."
		sum += int(n)
	if sum < 256: return "Uncovered clamp endpoint."
	sum = 0
	for n in p.chances:
		if not N.integer(n,0,100): return "Invalid category chance."
		sum += int(n)
	return "" if sum == 100 else "Category chances must cover 100 draws."
func validate_record(_id: String, v: Dictionary) -> String:
	if v.get("schema") != VERSION or not v.get("provenance") is Dictionary or v.provenance.is_empty(): return "Version and provenance required."
	if v.get("kind") == "policy":
		if v.size() != 10 or not keys(v.get("dyes")) or not keys(v.get("bodies")) or not keys(v.get("clothing_dyes")) or not v.get("categories") is Dictionary: return "Complete construction policy required."
		var error := selector_reason(v.get("selector"))
		if not error.is_empty(): return error
		if not v.get("dye_adapters") is Dictionary or v.dye_adapters.size() != v.dyes.size(): return "Complete dye adapters required."
		for dye in v.dyes:
			var mapping: Variant = v.dye_adapters.get(dye)
			if not mapping is Dictionary or mapping.size() != 2 or mapping.get("provider") != "classic-dye-v1" or not N.integer(mapping.get("code"),0,25) or int(mapping.code) in [10,11,12,13,14,17]: return "Unsupported dye provider/code."
		var generation: Variant = v.get("generation")
		if not generation is Dictionary or generation.size() != 5 or generation.get("template") != "uniform" or generation.get("style") != "uniform" or generation.get("dye") != "uniform" or not N.integer(generation.get("ammo_min"),1,2147483647) or not N.integer(generation.get("ammo_max"),generation.ammo_min,2147483647): return "Complete supported generation distribution required."
		for dye in v.clothing_dyes:
			if dye not in v.dyes: return "Missing clothing dye."
		for id in v.categories:
			if id == "semantic": return "Category 'semantic' is reserved for ITEM semantic intake."
			var category: Variant = v.categories[id]
			if not Paths.valid_id(id) or not category is Dictionary or category.size() != 2 or category.get("mode") not in ["leather","chain","material","neutral"] or category.get("dye") not in v.dyes: return "Unsupported category adapter."
		for id in v.selector.categories:
			if not v.categories.has(id): return "Unmapped selected category."
		return ""
	if v.get("kind") == "material":
		if v.size() != 7 or not v.get("coefficients") is Dictionary or v.coefficients.size() != 3 or not v.get("dye") is String or v.get("provider") != "builtin.properties-v1": return "Complete supported material provider required."
		for key in ["value","weight","condition"]:
			if not N.integer(v.coefficients.get(key),1,1000000): return "Unsafe material coefficient."
		if v.get("pending_consumers") != ["combat","equipment","save"]: return "Construction cannot certify future consumers."
		return ""
	if v.get("kind") != "template" or v.size() != 13 or v.get("provider") != "builtin.properties-v1" or v.get("type") not in ["weapon","armor","clothing","ammo"] or v.get("identity") not in ["item","stack"]: return "Complete supported template profile required."
	if not v.get("materials") is Array or (v.type in ["weapon","armor"] and not keys(v.materials)) or (v.type in ["ammo","clothing"] and not v.materials.is_empty()): return "Explicit compatible material inventory required."
	if not Paths.valid_id(v.get("template","")) or not keys(v.get("bodies")) or not keys(v.get("dyes")) or not v.get("styles") is Dictionary or v.styles.is_empty() or not v.get("visual") is Dictionary: return "Definition and complete appearance mapping required."
	if v.get("default_dye") not in v.dyes: return "Supported explicit default dye required."
	if v.visual.size() != 3 or v.visual.get("provider") != "classic-item-appearance-v1" or not v.visual.get("archives") is Dictionary or v.visual.archives.size() != v.bodies.size() or not N.integer(v.visual.get("record"),0,127): return "Unsupported visual provider."
	for body in v.bodies:
		if not N.integer(v.visual.archives.get(body),0,511): return "Required body archive missing."
	for category in v.styles:
		if category == "semantic": return "Category 'semantic' is reserved for ITEM semantic intake."
		if (v.type == "weapon" and category != "weapon") or (v.type in ["ammo","clothing"] and category != "neutral") or (v.type == "armor" and category in ["weapon","neutral"]): return "Incompatible template/category mapping."
		if not Paths.valid_id(category) or not v.styles[category] is Dictionary or v.styles[category].is_empty(): return "Compatible style mappings required."
		for style in v.styles[category]:
			if not Paths.valid_id(style) or style == "default" or not N.integer(v.styles[category][style],0,254): return "Stable style key and explicit resource variant required."
	if v.type == "ammo" and (v.identity != "stack" or v.styles.keys() != ["neutral"]): return "Ordinary arrows are neutral stacks."
	if v.type != "ammo" and v.identity != "item": return "Equipment has individual identity."
	return ""
func validate_references(resources: Dictionary) -> Array:
	var records: Dictionary = resources.get(DOMAIN+":profiles",{}).get("records",{})
	var policy: Dictionary = records.get("policy",{}).get("value",{})
	if policy.get("kind") != "policy": return [{"source":DOMAIN,"reason":"Construction policy missing."}]
	var issues: Array = []
	var checked_visuals := {}
	visual_checks = 0
	for id in policy.selector.materials:
		if records.get(id,{}).get("value",{}).get("kind") != "material": issues.append({"source":id,"reason":"Material mapping missing."})
	for id in records:
		var v: Dictionary = records[id].value
		if v.kind == "material" and v.dye not in policy.dyes: issues.append({"source":id,"reason":"Material dye missing."})
		if v.kind != "template": continue
		var base: Dictionary = resources.get("item-spell.inputs:catalog",{}).get("records",{}).get(v.template,{})
		if base.get("value",{}).get("kind") != "item" or base.value.has("behavior") or not N.integer(base.value.data.get("basePrice"),0,1000000000) or not N.integer(base.value.data.get("hitPoints"),0,1000000000) or not N.integer(float(base.value.data.get("baseWeight",-1))*500000,0,500000000):
			issues.append({"source":id,"reason":"Unsupported base definition/properties/provider."})
			continue
		for body in v.bodies:
			if body not in policy.bodies: issues.append({"source":id,"reason":"Missing body mapping."})
		for dye in v.dyes:
			if dye not in policy.dyes: issues.append({"source":id,"reason":"Missing dye mapping."})
		for material in v.materials:
			if records.get(material,{}).get("value",{}).get("kind") != "material": issues.append({"source":id,"reason":"Compatible material mapping missing."})
		for category in v.styles:
			if category not in ["neutral","weapon"] and not policy.categories.has(category): issues.append({"source":id,"reason":"Missing category mapping."})
			for variant in v.styles[category].values():
				if int(variant) >= maxi(1,int(base.value.data.variants)) or int(v.visual.record)+int(variant) > 127: issues.append({"source":id,"reason":"Visual variant outside template inventory."})
				for archive in v.visual.archives.values():
					var tuple := "%d:%d" % [int(archive),int(v.visual.record)+int(variant)]
					if checked_visuals.has(tuple): continue
					checked_visuals[tuple] = true
					visual_checks += 1
					var visual: Dictionary = classic.read_record("TEXTURE.%03d" % int(archive),{"record":int(v.visual.record)+int(variant),"frame":0}) if classic != null else {"ok":false}
					if not visual.ok: issues.append({"source":id,"reason":"Required classic appearance unavailable: "+tuple})
	return issues
