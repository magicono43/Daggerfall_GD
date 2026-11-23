extends RefCounted
## Installed DATA declarations only. Caller-owned selections never live here.
const L = preload("res://scripts/data/layout_inputs.gd")
const G = preload("res://scripts/data/geography_inputs.gd")
const C = preload("res://scripts/data/actor_input_formats.gd")
const P = preload("res://scripts/mod/package_library.gd")
const F = preload("res://scripts/data/layout_formats.gd")
const Resolver = preload("res://scripts/data/variant_resolution.gd")
const DOMAIN = "world.variants"
const VERSION = "variant-inputs-v1"
const ROOT = "res://content/variants/"
var layouts: RefCounted
var _index := {}
var _ticket := -1
var _application := Crypto.new().generate_random_bytes(16).hex_encode()

func bundled_contributions() -> Array:
	return [{"root":ROOT,"file":"baseline.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes(ROOT+"baseline.json")}]

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,L.DOMAIN,G.DOMAIN],"operations":["add","replace","patch"],"capabilities":["data."+VERSION]}

func begin_candidate(_mods: RefCounted, ticket: int, _registry: RefCounted) -> void:
	_ticket = ticket
	_index.clear()

func finish_candidate(_resources: Dictionary, valid: bool) -> void:
	if not valid: _index.clear()

func read_only_index(ticket: int) -> Dictionary:
	if ticket != _ticket or not _index.get("ok",false): return F.fail("Exact committed variant index required.",DOMAIN,null,null,"before_readiness")
	return _index.duplicate(true)

func validate_resource_path(path: String) -> String:
	return "" if path.begins_with("packs/") and path.split("/").size() == 2 and P.valid_id(path.get_file()) else "Use packs/<origin package ID>."

static func target_reason(t: Variant) -> String:
	if not t is Dictionary or t.get("scope") not in ["location-layout","global-block","location-block","placement","building"]: return "Explicit supported target scope required."
	var fields := ["scope","block"] if t.scope == "global-block" else ["scope","location","layout"]
	if t.scope in ["location-block","placement","building"]: fields.append("block")
	if t.scope in ["placement","building"]: fields.append("placement")
	if t.scope == "building": fields.append("building")
	if t.size() != fields.size(): return "Target has missing/unknown scope fields."
	for field: String in fields:
		if not t.has(field): return "Target field absent: "+field
		if field in ["location","layout","block"] and not G.valid_ref(t[field]): return "Explicit edition-mapped stable reference required: "+field
		if field in ["placement","building"] and not P.valid_id(t[field]): return "Explicit occurrence key required: "+field
	return ""

func validate_record(_id: String, v: Dictionary) -> String:
	if v.get("schema") != VERSION or v.get("kind") not in ["variant","default"] or not v.get("target") is Dictionary: return "Versioned typed variant/default required."
	var reason := target_reason(v.target)
	if not reason.is_empty(): return reason
	if v.kind == "variant":
		if v.size() != 5 or not G.valid_ref(v.get("alternate")) or not v.get("mapping") is Dictionary: return "Complete alternate and explicit record mapping required."
		var destinations := {}
		for old in v.mapping:
			var current: Variant = v.mapping[old]
			if not P.valid_id(old) or not P.valid_id(current) or destinations.has(current): return "Invalid/colliding explicit mapping."
			destinations[current] = true
	else:
		if v.target.scope == "building": return "Building defaults are unsupported; use explicit building selections."
		if v.size() != 4 or not v.get("choice") is Dictionary: return "Complete declared default choice required."
		var choice: Dictionary = v.choice
		if choice.get("intent") == "baseline":
			if choice.size() != 1: return "Baseline carries no variant."
		elif choice.get("intent") == "variant":
			if choice.size() != 2 or not G.valid_ref(choice.get("variant")): return "Default requires explicit selected variant reference."
		else: return "Default choice must explicitly name baseline or variant."
	return ""

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var v := previous.duplicate(true)
	for field: String in fields:
		if field not in ["alternate","mapping","choice"]: return F.fail("Patch replaces complete alternate/mapping/choice only.")
		v[field] = fields[field].duplicate(true) if fields[field] is Dictionary else fields[field]
	return {"ok":true,"value":v}

func validate_replace(previous: Dictionary, entries: Array) -> Dictionary:
	var ids := {}
	for entry in entries:
		if not entry is Dictionary or not entry.get("id") is String: return F.fail("Complete replacement entries require explicit IDs.")
		ids[entry.id] = true
		if previous.get("records",{}).has(entry.id):
			var prior: Dictionary = previous.records[entry.id].get("value",{})
			if not entry.get("value") is Dictionary or entry.value.get("kind") != prior.get("kind") or not C.equal_input(entry.value.get("target"),prior.get("target")): return F.fail("Replacement retains declaration kind and target; author a new declaration to retarget.",DOMAIN,entry.id)
	for id: String in previous.get("records",{}):
		if not ids.has(id): return F.fail("Replace retains declared IDs; remove a default by explicit baseline choice, not deletion.",DOMAIN,id)
	return {"ok":true}

func validate_source_record(id: String, v: Dictionary, _fields: Dictionary, path: String, source: Dictionary, identity: Dictionary) -> Dictionary:
	if source.provider == identity.package and not str(source.provider).begins_with("@shipped/") and path != "packs/"+("loose" if source.provider == "@loose" else str(source.provider)): return F.fail("Additions require originating package namespace.",path,id)
	return {"ok":true}

static func catalog(resources: Dictionary, domain: String) -> Dictionary:
	var result := {}
	for key: String in resources:
		if not key.begins_with(domain+":"): continue
		for id: String in resources[key].records: result[key.substr(domain.length()+1)+"#"+id] = resources[key].records[id]
	return result

func validate_references(resources: Dictionary) -> Array:
	var variants := catalog(resources,DOMAIN)
	var layout := catalog(resources,L.DOMAIN)
	var geography := catalog(resources,G.DOMAIN)
	var issues: Array = []
	var defaults := {}
	for key: String in variants:
		var record: Dictionary = variants[key]
		var v: Dictionary = record.value
		var t: Dictionary = v.target
		var reason := ""
		for field in ["layout","block"]:
			if t.has(field) and (not layout.has(t[field]) or layout[t[field]].value.kind != ("layout" if field == "layout" else "block")): reason = "Required typed target absent: "+field
		if t.has("location") and (not geography.has(t.location) or geography[t.location].value.kind != "location"): reason = "Required containing location absent."
		if reason.is_empty() and t.has("layout") and layout[t.layout].value.data.location != t.location: reason = "Layout and containing location disagree."
		if reason.is_empty() and t.has("placement"):
			var definition: Dictionary = layout[t.layout].value.data
			if definition.mode == "authored":
				var placements: Array = definition.placements.filter(func(p: Dictionary): return p.id == t.placement)
				if placements.size() != 1 or placements[0].block != t.block: reason = "Required authored placement/block target absent."
			elif layouts == null or not layouts.declared_occurrence_keys(definition,"placement").has(t.placement): reason = "Explicit classic placement edition mapping absent."
		if reason.is_empty() and t.scope == "building":
			var definition: Dictionary = layout[t.block].value.data
			if definition.mode == "authored":
				if definition.format != "RMB" or not definition.structure.buildings.any(func(b: Dictionary): return b.id == t.building): reason = "Required building record absent."
			elif layouts == null or not layouts.declared_occurrence_keys(definition,"building").has(t.building): reason = "Explicit classic building edition mapping absent."
		if v.kind == "variant":
			if not layout.has(v.alternate) or layout[v.alternate].value.kind != ("layout" if t.scope == "location-layout" else "block"): reason = "Required typed alternate absent."
			elif t.scope == "location-layout" and layout[v.alternate].value.data.location != t.location: reason = "Alternate changes containing geographic identity."
			elif t.has("block") and layout.has(t.block) and layout[t.block].value.data.get("format") != layout[v.alternate].value.data.get("format"): reason = "Alternate block format incompatible."
		else:
			# Canonical field ordering prevents dictionary order from choosing a scope.
			var scope_key := Resolver.target_key(t)
			if defaults.has(scope_key): reason = "Ambiguous overlapping default target."
			defaults[scope_key] = key
			if v.choice.intent == "variant":
				if not variants.has(v.choice.variant) or variants[v.choice.variant].value.kind != "variant" or not C.equal_input(variants[v.choice.variant].value.target,t): reason = "Default variant missing or targets another scope."
		if not reason.is_empty(): issues.append({"source":key,"target":v.get("alternate",t),"provider":record.winner,"reason":reason})
	_index = {"ok":issues.is_empty(),"context":{"schema":VERSION,"ticket":_ticket,"application":_application},"variants":variants,"defaults":defaults}
	return issues

func context(registry: RefCounted) -> Dictionary:
	var index: Dictionary = registry.domain_index(DOMAIN)
	return {"ok":true,"context":index.context.duplicate(true)} if index.ok else index

func resolve(registry: RefCounted, request: Dictionary, resource_provider: Callable) -> Dictionary:
	var result: Dictionary = Resolver.new().resolve(self,registry,request,resource_provider)
	if not result.get("ok",false):
		result.input_schema = result.get("schema","")
		result.schema = "variant-resolution-v1"
		result.referring_owner = request.get("owner","")
		result.selection_committed = false
		result.transition_complete = false
	return result.duplicate(true)
