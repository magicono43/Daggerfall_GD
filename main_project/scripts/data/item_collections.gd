extends RefCounted
## Locked collection policy and homogeneous per-unit semantic contracts.
const DOMAIN := "item.collections"
const VERSION := "item-collections-v1"
const Paths = preload("res://scripts/mod/package_library.gd")
const N = preload("res://scripts/data/actor_input_formats.gd")
const TYPES := ["ingredient","potion","book","gold","arrow","oil","weapon","armor","clothing"]
const RESTRICTIONS := ["equipped","quest","enchanted","summoned"]
var _sealed := false
var _providers := {"builtin.ordinary-v1":["exact-per-unit-v1"]}
func _init() -> void:
	for type in ["ingredient","potion","book","gold","oil"]: _providers["pending."+type+"-v1"] = ["exact-per-unit-v1"]
func declare_provider(id: String, rules: Array) -> Dictionary:
	if _sealed: return {"ok":false,"kind":"registration_closed"}
	if not Paths.valid_id(id) or _providers.has(id) or id.begins_with("pending.") or rules.is_empty(): return {"ok":false,"kind":"invalid_provider"}
	var seen := {}
	for rule in rules:
		if rule not in ["exact-per-unit-v1","set-content-v1"] or seen.has(rule): return {"ok":false,"kind":"invalid_provider"}
		seen[rule] = true
	_providers[id] = rules.duplicate()
	return {"ok":true}
func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,"item.construction","item-spell.inputs"],"operations":["add","replace","patch"],"required_resources":["policies"],"capabilities":["data."+VERSION],"classic_sources":[]}
func validate_resource_path(path: String) -> String:
	return "" if path == "policies" else "Collection policies required."
func bundled_contributions() -> Array:
	return [{"root":"res://content/items","file":"collections.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/items/collections.json")}]
func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	return {"ok":true,"value":previous.merged(fields,true).duplicate(true)}
static func fields_valid(fields: Variant) -> bool:
	if not fields is Dictionary: return false
	for key in fields:
		if not Paths.valid_id(key) or fields[key] not in ["key","text","integer","boolean","key-set"]: return false
	return true
func validate_record(id: String, v: Dictionary) -> String:
	_sealed = true
	if not Paths.valid_id(id) or v.get("schema") != VERSION or not v.get("provenance") is Dictionary or v.provenance.is_empty(): return "Schema/provenance required."
	if v.get("kind") == "type":
		if v.size() != 10 or typeof(v.get("eligible")) != TYPE_BOOL or not N.integer(v.get("cap"),0,2147483647) or v.get("representation") != "homogeneous-per-unit-v1" or not fields_valid(v.get("contents")) or not v.get("restrictions") is Array or not v.get("provider") is String: return "Complete supported type contract required."
		var seen := {}
		for restriction in v.restrictions:
			if restriction not in RESTRICTIONS or seen.has(restriction): return "Unknown/duplicate restriction override."
			seen[restriction] = true
		if not Paths.valid_id(v.provider) or (not v.restrictions.is_empty() and v.provider == "builtin.ordinary-v1"): return "Special overrides require an explicit per-unit owner provider."
		if v.get("state_rule") not in ["exact-per-unit-v1","set-content-v1"]: return "Unsupported compatibility/allocation rule."
		if not _providers.has(v.provider) or v.state_rule not in _providers[v.provider]: return "Semantic provider/version/rule was not declared before DATA preparation."
		if ("key-set" in v.contents.values()) != (v.state_rule == "set-content-v1"): return "Set contents require their explicit unordered semantic rule."
		return ""
	if v.get("kind") == "template":
		if v.size() != 7 or not Paths.valid_id(v.get("type","")) or typeof(v.get("eligible")) != TYPE_BOOL or not N.integer(v.get("cap"),0,2147483647) or not Paths.valid_id(v.get("template","")): return "Complete template override required."
		if id != "template-"+v.template: return "Template policy key must be template- plus stable profile/template key."
		return ""
	return "Unknown collection policy kind."
func validate_references(resources: Dictionary) -> Array:
	var records: Dictionary = resources.get(DOMAIN+":policies",{}).get("records",{})
	var issues: Array = []
	for type in TYPES:
		if records.get(type,{}).get("value",{}).get("kind") != "type": issues.append({"source":type,"reason":"Required type default missing."})
	var templates := {}
	for id in records:
		var v: Dictionary = records[id].value
		if v.kind != "template": continue
		if records.get(v.type,{}).get("value",{}).get("kind") != "type" or resources.get("item.construction:profiles",{}).get("records",{}).get(v.template,{}).get("value",{}).get("kind") != "template" or templates.has(v.template): issues.append({"source":id,"reason":"Missing/conflicting template/type binding."})
		templates[v.template] = id
	return issues

static func state_reason(state: Variant, contract: Dictionary) -> String:
	if not state is Dictionary or state.size() != 11: return "Complete explicit per-unit state required."
	for flag in ["equipped","quest","enchanted","summoned"]:
		if typeof(state.get(flag)) != TYPE_BOOL: return "Explicit state flags required."
	if not N.integer(state.get("expiry"),0,9007199254740991) or (state.summoned and state.expiry == 0): return "Expiry is absolute native game milliseconds; summoned expiry required."
	for field in ["contents","knowledge","resources","provenance","bindings"]:
		if not state.get(field) is Dictionary: return "Typed state maps required."
	if state.get("representation") != contract.representation: return "Unsupported state representation."
	if state.contents.size() != contract.contents.size(): return "Complete actual contents required."
	for field in contract.contents:
		var value: Variant = state.contents.get(field)
		match contract.contents[field]:
			"key":
				if not value is String or not Paths.valid_id(value): return "Stable content key required."
			"text":
				if not value is String or value.length() > 16384: return "Bounded actual text required."
			"integer":
				if not N.integer(value,0,2147483647): return "Bounded content integer required."
			"boolean":
				if typeof(value) != TYPE_BOOL: return "Content boolean required."
			"key-set":
				if not value is Array or value.size() > 256: return "Bounded content key set required."
				var seen := {}
				for key in value:
					if not key is String or not Paths.valid_id(key) or seen.has(key): return "Unique stable content keys required."
					seen[key] = true
	# Resources are per unit. Stack-wide finite pools/heterogeneous units have no
	# allocator in v1 and must not be smuggled into opaque maps.
	for field in state.resources:
		if not Paths.valid_id(field) or not N.integer(state.resources[field],0,2147483647): return "Per-unit finite resource required."
	for field in state.knowledge:
		if not Paths.valid_id(field) or typeof(state.knowledge[field]) != TYPE_BOOL: return "Explicit per-unit knowledge required."
	for field in state.provenance:
		if not Paths.valid_id(field) or not state.provenance[field] is String: return "Stable provenance required."
	for field in state.bindings:
		if not Paths.valid_id(field) or not state.bindings[field] is String: return "Stable owner binding required."
	return ""

static func ordinary_state() -> Dictionary:
	return {"representation":"homogeneous-per-unit-v1","contents":{},"knowledge":{},"resources":{},"provenance":{},"bindings":{},"expiry":0,"equipped":false,"quest":false,"enchanted":false,"summoned":false}
