extends RefCounted
## Locked DATA/MOD contracts; algorithms are named and deliberately bounded.
const DOMAIN := "item.capacity-tender"
const VERSION := "item-capacity-tender-v1"
const Paths = preload("res://scripts/mod/package_library.gd")
const A = preload("res://scripts/item/accounting.gd")
var _providers := {}
var _sealed := false
func declare_provider(id: String, rules: Array) -> Dictionary:
	if _sealed: return A.fail("registration_closed")
	if not Paths.valid_id(id) or _providers.has(id) or rules.is_empty(): return A.fail("invalid_provider")
	var seen := {}
	for rule in rules:
		if rule not in ["intake-v1","quote-v1","valuation-v1","recovery-v1"] or seen.has(rule): return A.fail("invalid_provider")
		seen[rule] = true
	_providers[id] = rules.duplicate()
	return {"ok":true}
func supports(id: String, rule: String) -> bool:
	return rule in _providers.get(id,[])

func persistence_providers() -> Dictionary:
	var result := _providers.duplicate(true)
	for rules: Array in result.values(): rules.sort()
	return result
func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,"item.construction"],"operations":["add","replace","patch"],"required_resources":["profiles"],"capabilities":["data."+VERSION],"classic_sources":[]}
func validate_resource_path(path: String) -> String:
	return "" if path == "profiles" else "Profiles required."
func bundled_contributions() -> Array:
	return [{"root":"res://content/items","file":"capacity_tender.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/items/capacity_tender.json")}]
func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	return {"ok":true,"value":previous.merged(fields,true).duplicate(true)}
static func keys(value: Variant) -> bool:
	if not value is Array: return false
	var seen := {}
	for key in value:
		if not key is String or not Paths.valid_id(key) or seen.has(key): return false
		seen[key] = true
	return true
func validate_record(id: String, v: Dictionary) -> String:
	_sealed = true
	if not Paths.valid_id(id) or v.get("schema") != VERSION or not v.get("provenance") is Dictionary or v.provenance.is_empty(): return "Schema and provenance required."
	match v.get("kind"):
		"accounting":
			if v.size() != 6 or not A.integer(v.get("quantum_nanokg"),1,1000000000) or 1000000000%int(v.quantum_nanokg) != 0 or v.get("rounding") != "nearest-even-v1" or not A.integer(v.get("display_places"),0,9): return "Complete exact accounting profile required."
			if int(pow(10,int(v.display_places)))%(1000000000/int(v.quantum_nanokg)) != 0: return "Display precision cannot represent accounting units exactly."
		"capacity":
			if v.size() != 6 or v.get("carried") != "char-selected-v1" or not A.integer(v.get("wagon_kg")) or not Paths.valid_id(v.get("accounting","")): return "Selected CHAR capacity and accounting required."
		"weight":
			if v.size() != 6 or not Paths.valid_id(v.get("profile","")) or typeof(v.get("exempt")) != TYPE_BOOL or (v.get("nanokg") != null and not A.integer(v.nanokg)): return "Explicit template weight/exemption required."
			if not v.has("nanokg") or id != "weight-"+v.profile: return "Stable explicit template weight key required."
		"access":
			if v.size() != 7 or v.get("algorithm") not in ["owned-context-v1","physical-reach-v1"] or not A.integer(v.get("distance_mm"),0,1000000) or typeof(v.get("interior")) != TYPE_BOOL or v.get("metric") != "euclidean-feet-to-exit-anchor-inclusive-v1": return "Complete wagon access profile required."
		"denomination":
			if v.size() != 6 or not Paths.valid_id(v.get("unit","")) or not A.integer(v.get("value"),1,1000000000) or not A.integer(v.get("nanokg")): return "Complete denomination required."
		"money":
			if v.size() != 8 or not Paths.valid_id(v.get("unit","")) or not keys(v.get("order")) or v.order.is_empty() or v.get("algorithm") != "bounded-exact-search-v1" or not A.integer(v.get("search_limit"),1,1000000) or not A.integer(v.get("gold_value"),1,1000000000): return "Explicit mapping and bounded tender algorithm required."
		"letter":
			if v.size() != 7 or not Paths.valid_id(v.get("issuer","")) or not Paths.valid_id(v.get("unit","")) or not Paths.valid_id(v.get("provider","")) or not A.integer(v.get("nanokg")): return "Complete distinct credit instrument required."
			if not supports(v.provider,"intake-v1"): return "Undeclared instrument provider."
		"rate":
			if v.size() != 12 or not A.integer(v.get("numerator"),1,1000000000) or not A.integer(v.get("denominator"),1,1000000000) or v.get("rounding") != "exact-lots-v1": return "Conserving exact rational lots required."
			for field in ["issuer","institution","region","face_unit","local_unit","provider"]:
				if not Paths.valid_id(v.get(field,"")): return "Complete valuation context/provider required."
			if not supports(v.provider,"valuation-v1"): return "Undeclared valuation provider."
		_: return "Unsupported policy kind."
	return ""
func validate_references(resources: Dictionary) -> Array:
	var records: Dictionary = resources.get(DOMAIN+":profiles",{}).get("records",{})
	var issues: Array = []
	var required_kinds := {"baseline-accounting":"accounting","baseline-capacity":"capacity","baseline-access":"access","gold":"denomination","baseline-money":"money"}
	for required in required_kinds:
		if records.get(required,{}).get("value",{}).get("kind") != required_kinds[required]: issues.append({"source":required,"reason":"Required baseline missing or wrong kind."})
	var rates := {}
	for id in records:
		var v: Dictionary = records[id].value
		if v.kind == "capacity" and records.get(v.accounting,{}).get("value",{}).get("kind") != "accounting": issues.append({"source":id,"reason":"Missing accounting profile."})
		if v.kind == "money":
			for denomination in v.order:
				var d: Dictionary = records.get(denomination,{}).get("value",{})
				if d.get("kind") != "denomination" or d.get("unit") != v.unit: issues.append({"source":id,"reason":"Missing or incompatible denomination."})
		if v.kind == "weight" and resources.get("item.construction:profiles",{}).get("records",{}).get(v.profile,{}).get("value",{}).get("kind") != "template": issues.append({"source":id,"reason":"Missing construction profile."})
		if v.kind == "rate":
			var key: String = JSON.stringify([v.issuer,v.institution,v.region,v.face_unit,v.local_unit,v.provider])
			if rates.has(key): issues.append({"source":id,"reason":"Conflicting valuation context."})
			rates[key] = true
	return issues
