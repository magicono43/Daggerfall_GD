extends RefCounted
## DATA definitions/occurrences, never live LOC instances.
const F = preload("res://scripts/data/layout_formats.gd")
const P = preload("res://scripts/data/layout_placements.gd")
const G = preload("res://scripts/data/geography_inputs.gd")
const Common = preload("res://scripts/data/actor_input_formats.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const AssemblySchema = preload("res://scripts/data/dungeon_assembly_schema.gd")
const DOMAIN = "layout.inputs"
const VERSION = "layout-inputs-v1"
const ROOT = "res://content/layouts/"
const BASE_PATH = "packs/classic"
const PROFILE_HASH = "a2e629e5d085b3d0ed58f3c17958f4accec4910e9204b6967203ab55af717b75"
const ASSEMBLY_HASH = "386895efaecb1af6c9a3e89974bafaec441d16cfeb1556a09693c130b5a1f056"
const CONTEXT_HASH = "e22bc403672a2980ab9555c93dfe5eaf3e67ad864a2b725ca136f43ff9b69612"
var classic: RefCounted
var media: RefCounted
var resource_sources: Array = [] # Declared by the consumer before classic preparation.
var _profile := {}
var _blocks := {}
var _locations := {}
var _receipts := {}
var _index := {}
var _ticket := -1
var _baseline := PackedByteArray()
var _source_paths := {}
var _assembly_guard := ""
var _context_annotations := {}

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,G.DOMAIN,"media.assets"],"operations":["add","replace","patch"],"required_resources":[BASE_PATH],"capabilities":["data."+VERSION],"classic_sources":[{"file":"BLOCKS.BSA","format":"bsa-v1"},{"file":"MAPS.BSA","format":"bsa-v1"}]+resource_sources.duplicate(true)}

func begin_candidate(_mods: RefCounted, ticket: int, _registry: RefCounted) -> void:
	_ticket = ticket
	_index.clear()

func finish_candidate(_resources: Dictionary, valid: bool) -> void:
	if not valid: _index.clear()

func read_only_index(ticket: int) -> Dictionary:
	if ticket != _ticket or not _index.get("ok",false): return F.fail("Exact committed layout index required.",DOMAIN,null,null,"before_readiness")
	return _index.duplicate(true)

func validate_resource_path(path: String) -> String:
	var parts := path.split("/")
	return "" if parts.size() == 2 and parts[0] == "packs" and Paths.valid_id(parts[1]) else "Use packs/<origin package ID>."

static func value(kind: String, data: Dictionary) -> Dictionary:
	return {"schema":VERSION,"kind":kind,"data":data,"compatibility":{"status":"unverified","remap":{}}}

static func context_annotations() -> Dictionary:
	var bytes := FileAccess.get_file_as_bytes(ROOT+"dungeon_context.json")
	if Common.sha256(bytes) != CONTEXT_HASH: return F.fail("Pinned dungeon context annotations missing/changed.",ROOT,null,null,"source_unavailable")
	return {"ok":true,"data":JSON.parse_string(bytes.get_string_from_utf8())}

static func context_assets(context: Dictionary) -> Array:
	var palettes: Array = [context.baseline,context.override]
	for pool: Array in context.climates.values(): palettes.append_array(pool)
	palettes.append_array(context.get("climate_bindings",{}).values())
	var assets := {}
	for palette_: Dictionary in palettes:
		for slot: Variant in palette_.values():
			if slot is Dictionary:
				for asset: Dictionary in slot.records.values(): assets[JSON.stringify([asset.provider,asset.key])] = asset
	return assets.values()

func bundled_contributions() -> Array:
	var bytes := FileAccess.get_file_as_bytes(ROOT+"profile.json")
	if Common.sha256(bytes) != PROFILE_HASH: return [{"root":ROOT,"file":"baseline.json","read":F.fail("Pinned layout profile missing/changed.",ROOT,null,null,"source_unavailable")}]
	if classic == null or not classic.ready(): return [{"root":ROOT,"file":"baseline.json","read":F.fail("Active classic sources required.",ROOT,null,null,"before_readiness")}]
	if _profile.is_empty(): _profile = JSON.parse_string(bytes.get_string_from_utf8())
	var files := {}
	for item: Dictionary in classic.inventory(): files[str(item.source).get_file().to_upper()] = item.source
	for name: String in _profile.files:
		if not files.has(name) or FileAccess.get_sha256(files[name]) != _profile.files[name]: return [{"root":ROOT,"file":"baseline.json","read":F.fail("Explicit layout edition mapping required.",name,null,null,"unsupported")}]
	_source_paths = files.duplicate(true)
	var annotation_bytes := FileAccess.get_file_as_bytes(ROOT+"dungeon_assembly.json")
	if Common.sha256(annotation_bytes) != ASSEMBLY_HASH: return [{"root":ROOT,"file":"baseline.json","read":F.fail("Pinned assembly annotation missing/changed.",ROOT,null,null,"source_unavailable")}]
	var annotations: Dictionary = JSON.parse_string(annotation_bytes.get_string_from_utf8())
	if annotations.get("schema") != "dungeon-classic-assembly-annotations-v1" or annotations.sources.get("BLOCKS.BSA") != _profile.files["BLOCKS.BSA"] or annotations.sources.get("MAPS.BSA") != _profile.files["MAPS.BSA"]: return [{"root":ROOT,"file":"baseline.json","read":F.fail("Assembly annotation edition guard differs.",ROOT,null,null,"source_changed")}]
	var annotation_guard := FileAccess.get_sha256(files.get("ARCH3D.BSA",""))
	if annotation_guard != _assembly_guard:
		_baseline = PackedByteArray()
		_assembly_guard = annotation_guard
	var use_annotations: bool = annotation_guard == annotations.sources["ARCH3D.BSA"]
	var context_input := context_annotations()
	if not context_input.ok: return [{"root":ROOT,"file":"baseline.json","read":context_input}]
	var contexts: Dictionary = context_input.data
	if contexts.schema != "classic-dungeon-context-annotations-v1" or contexts.sources != annotations.sources: return [{"root":ROOT,"file":"baseline.json","read":F.fail("Dungeon context source guard differs.",ROOT,null,null,"source_changed")}]
	_context_annotations = contexts
	# Source edition metadata is immutable for this application. Only serialized
	# shipped input is reused; final definitions/indexes still rebuild per ticket.
	if not _baseline.is_empty(): return [{"root":ROOT,"file":"baseline.json","version":VERSION,"bytes":_baseline}]
	_blocks.clear()
	_locations.clear()
	_receipts.clear()
	var entries: Array = []
	for block: Dictionary in _profile.blocks:
		_blocks[block.id] = block
		var data := {"mode":"classic-source","format":block.format,"mapping":block.id}
		var v := value("block",data)
		v.input = {"edition":"classic-layout-profile-v1","file":"BLOCKS.BSA","sha256":_profile.files["BLOCKS.BSA"],"name":block.name,"ordinal":block.ordinal,"payload_sha256":block.sha256}
		_receipts[block.id] = v.input.duplicate(true)
		entries.append({"id":block.id,"value":v})
	for location: Dictionary in _profile.locations:
		_locations[location.id] = location
		var v := value("layout",{"mode":"classic-source","location":G.ref(location.id),"mapping":location.id})
		if use_annotations and annotations.layouts.has(location.id):
			var annotation: Dictionary = annotations.layouts[location.id]
			for block: Dictionary in _profile.blocks:
				if annotation.blocks.has(block.id) and annotation.blocks[block.id] != block.sha256: return [{"root":ROOT,"file":"baseline.json","read":F.fail("Assembly annotation input guard differs.",location.id,block.id,null,"source_changed")}]
			v.data.assembly = annotation.assembly.duplicate(true)
			if contexts.layouts.has(location.id): v.data.context = contexts.layouts[location.id].duplicate(true)
		v.input = {"edition":"classic-layout-profile-v1","file":"MAPS.BSA","sha256":_profile.files["MAPS.BSA"],"region":location.region,"ordinal":location.ordinal,"pitem_offset":location.pitem_offset}
		_receipts[location.id] = v.input.duplicate(true)
		entries.append({"id":location.id,"value":v})
	_baseline = JSON.stringify({"domain":DOMAIN,"path":BASE_PATH,"operation":"add","entries":entries}).to_utf8_buffer()
	return [{"root":ROOT,"file":"baseline.json","version":VERSION,"bytes":_baseline}]

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var result := previous.duplicate(true)
	for field: String in fields:
		if field not in ["data","compatibility"]: return F.fail("Patch replaces complete data/compatibility fields only.")
		result[field] = fields[field].duplicate(true) if fields[field] is Dictionary else fields[field]
	return {"ok":true,"value":result}

func validate_replace(previous: Dictionary, entries: Array) -> Dictionary:
	var retained := {}
	for entry in entries:
		if not entry is Dictionary or not entry.get("id") is String: return F.fail("Complete replacement entries require explicit IDs.")
		retained[entry.id] = true
	for id: String in previous.get("records",{}):
		if not retained.has(id): return F.fail("Layout replace must retain every namespace ID; implicit deletion is unsupported.",DOMAIN,id)
	return {"ok":true}

static func valid_transform(t: Variant) -> bool:
	if preload("res://scripts/data/layout_geometry_frame.gd").valid_native(t): return true
	if not t is Dictionary or t.size() != 6 or t.get("frame") != "classic-block-local-v1" or t.get("position_unit") != "classic-layout-integer" or t.get("rotation_unit") != "classic-angle-2048": return false
	for field in ["position","rotation","scale"]:
		if not t.get(field) is Array or t[field].size() != 3: return false
		for n in t[field]:
			if not Common.integer(n,-2147483648,2147483647): return false
	return Common.equal_input(t.scale,[1,1,1])

static func hex_size(v: Variant, size: int) -> bool:
	return v is String and v.length() == size*2 and v.is_valid_hex_number(false)

static func record_reason(r: Dictionary, format_: String) -> String:
	var allowed := ["id","type","transform","marker_purpose","resource","model_id","texture","flags","faction_id","object_type","door_model_index","open_rotation","radius","uninterpreted","action","trigger_starting_lock","sound_index","magnitude","description","unused"]
	for field: String in r:
		if field not in allowed: return "Unknown required record interpretation: "+field
	if r.has("resource"):
		if not r.resource is Dictionary or r.resource.size() != 3 or not r.resource.get("provider") is String or not Paths.valid_id(r.resource.get("key")) or r.resource.get("type") != ("model" if r.type in ["model","door"] else "image") or r.type not in ["model","flat","person","door"]: return "Exact typed media provider/export reference required."
		if r.has("model_id") or r.has("texture") or r.has("door_model_index"): return "Choose one explicit media provider or classic resource reference."
	elif r.type == "model" and not Common.integer(r.get("model_id"),0,4294967295): return "Exact classic model ID required, never a physical ordinal."
	if r.type in ["flat","person"]:
		if not r.has("resource"):
			if not r.get("texture") is Dictionary or not Common.integer(r.texture.get("archive"),0,511) or not Common.integer(r.texture.get("record"),0,127): return "Explicit texture archive/record required."
			if r.get("marker_purpose","") != F.marker(r.texture): return "Marker purpose must match declared classic marker type."
		elif r.get("marker_purpose") not in ["","dungeon-entrance","dungeon-start","quest","quest-item","editor-other"]: return "Explicit supported marker purpose required for authored media."
		if not Common.integer(r.get("flags"),0,65535): return "Flat/person flags required."
		if format_ == "RMB" and not Common.integer(r.get("faction_id"),-32768,32767): return "RMB faction required."
	if r.type == "door" and (format_ != "RMB" or (not r.has("resource") and not Common.integer(r.get("door_model_index"),0,255)) or not Common.integer(r.get("open_rotation"),-32768,32767)): return "Complete RMB door fields required."
	if r.type == "light" and (format_ != "RDB" or not Common.integer(r.get("radius"),0,65535)): return "Complete RDB light fields required."
	if r.type == "section3" and (format_ != "RMB" or not hex_size(r.get("uninterpreted"),4)): return "Retain uninterpreted RMB section3 bytes."
	if r.has("action") and format_ != "RDB": return "RMB action schema unavailable."
	if r.type == "model" and format_ == "RMB" and not Common.integer(r.get("object_type"),0,255): return "Explicit RMB model object type required."
	if r.type == "model" and format_ == "RDB" and (not Common.integer(r.get("trigger_starting_lock"),0,4294967295) or not Common.integer(r.get("sound_index"),0,255)): return "Explicit RDB trigger/starting lock and sound fields required."
	if r.has("description") and (not r.description is String or r.description.length() > 3): return "Model description is an explicit three-character source tag."
	return ""

static func structure_reason(d: Dictionary, ids: Dictionary) -> String:
	var structure: Dictionary = d.structure
	var placed := {}
	var groups: Array = []
	if d.format == "RDB":
		for field: String in structure:
			if field not in ["width","height","model_references","roots"]: return "Unknown RDB structure field: "+field
		if not Common.integer(structure.get("width"),1,4294967295) or not Common.integer(structure.get("height"),1,4294967295): return "Explicit RDB root dimensions required."
		if structure.width > structure.roots.size() or structure.height > structure.roots.size() or structure.width*structure.height != structure.roots.size(): return "RDB dimensions disagree with complete root inventory."
		for model in structure.model_references:
			if not model is Dictionary or model.size() != 2 or not Common.integer(model.get("model_id"),0,4294967295) or not model.get("description") is String: return "Complete typed RDB model references required."
		groups = structure.roots
	else:
		for field: String in structure:
			if field not in ["ground","automap","buildings","misc"]: return "Unknown RMB structure field: "+field
		if not structure.get("misc") is Array or structure.buildings.size() > 32: return "Explicit miscellaneous records and encoded building bound required."
		groups.append(structure.misc)
		var buildings := {}
		for b in structure.buildings:
			if not b is Dictionary or b.size() != 5 or not Paths.valid_id(b.get("id")) or buildings.has(b.id) or ids.has(b.id) or not valid_transform(b.get("transform")) or not b.get("metadata") is Dictionary or not b.get("exterior") is Array or not b.get("interior") is Array: return "Complete stable exterior/interior building structure required."
			buildings[b.id] = true
			var m: Dictionary = b.metadata
			if m.size() != 8 or not m.get("unknown") is Array or m.unknown.size() != 4: return "Complete building metadata required."
			for field in ["name_seed","faction_id","location_id"]:
				if not Common.integer(m.get(field),0,65535): return "Building u16 metadata missing or out of bounds."
			for field in ["building_type","quality"]:
				if not Common.integer(m.get(field),0,255): return "Building u8 metadata missing or out of bounds."
			if not Common.integer(m.get("sector"),-32768,32767) or not Common.integer(m.get("service_time_limit"),0,4294967295): return "Building sector/service metadata missing or out of bounds."
			for i in 4:
				if not Common.integer(m.unknown[i],0,65535 if i < 2 else 4294967295): return "Building unknown raw fields outside encoded widths."
			groups.append_array([b.exterior,b.interior])
	for group in groups:
		if not group is Array: return "Explicit grouped record ID arrays required."
		for id in group:
			if not id is String or not ids.has(id) or placed.has(id): return "Record is missing or claimed by multiple structural scopes."
			placed[id] = true
	if placed.size() != ids.size(): return "Every record requires exactly one structural scope."
	return ""

func validate_record(_id: String, record: Dictionary) -> String:
	if record.get("schema") != VERSION or record.get("kind") not in ["block","layout"] or not record.get("data") is Dictionary: return "Typed layout schema/kind/data required."
	for field: String in record:
		if field not in ["schema","kind","data","compatibility","input"]: return "Unknown layout field: "+field
	var compatibility: Variant = record.get("compatibility")
	if not compatibility is Dictionary or compatibility.get("status") != "unverified" or not compatibility.get("remap") is Dictionary: return "Structural remapping does not establish SAVE/LOC/QUEST compatibility."
	var d: Dictionary = record.data
	if d.has("context"):
		if record.kind != "layout": return "Dungeon context belongs to the effective layout."
		var context_reason := preload("res://scripts/data/dungeon_context_schema.gd").reason(d.context)
		if not context_reason.is_empty(): return context_reason
	if d.has("assembly"):
		if record.kind != "layout": return "Assembly declarations belong to the layout."
		var assembly_reason := AssemblySchema.reason(d.assembly)
		if not assembly_reason.is_empty(): return assembly_reason
	if d.get("mode") == "classic-source":
		if not d.get("mapping") is String or not record.get("input") is Dictionary: return "Classic source requires immutable input/mapping."
		if record.kind == "block" and d.get("format") not in ["RMB","RDB","RDI",""]: return "Unknown inventory classification."
		return ""
	if d.get("mode") != "authored": return "Explicit source or authored mode required."
	if record.kind == "layout":
		for field: String in d:
			if field not in ["mode","location","placements","assembly","context"]: return "Unknown authored layout field: "+field
		if not G.valid_ref(d.get("location")) or not d.get("placements") is Array: return "Layout requires containing location and placements."
		var ids := {}
		for p in d.placements:
			if not p is Dictionary or not Paths.valid_id(p.get("id")) or ids.has(p.id) or not G.valid_ref(p.get("block")) or p.get("context") not in ["exterior","interior","dungeon"] or not valid_transform(p.get("transform")): return "Complete distinct placement identity/context/transform required."
			if p.size() != 4+int(p.has("placement_mode"))+int(p.has("snap")): return "Complete placement has id/context/block/transform and optional placement_mode/snap only."
			var snap_reason := preload("res://scripts/data/layout_geometry_frame.gd").snap_reason(p)
			if not snap_reason.is_empty(): return snap_reason
			ids[p.id] = true
		var destinations := {}
		for old: String in compatibility.remap:
			if not Paths.valid_id(old) or not ids.has(compatibility.remap[old]) or destinations.has(compatibility.remap[old]): return "Missing or ambiguous placement mapping."
			destinations[compatibility.remap[old]] = true
	else:
		for field: String in d:
			if field not in ["mode","format","records","structure"]: return "Unknown authored block field: "+field
		if d.get("format") not in ["RMB","RDB"] or not d.get("records") is Array or not d.get("structure") is Dictionary: return "Complete supported block structure/records required."
		if d.format == "RMB":
			if not d.structure.get("ground") is Dictionary or not hex_size(d.structure.ground.get("header"),8) or not hex_size(d.structure.ground.get("tiles"),256) or not hex_size(d.structure.ground.get("scenery"),256) or not hex_size(d.structure.get("automap"),4096) or not d.structure.get("buildings") is Array: return "Complete RMB ground/automap/building inventory required."
		elif not d.structure.get("model_references") is Array or not d.structure.get("roots") is Array: return "Explicit RDB model/root inventory required."
		var ids := {}
		for r in d.records:
			if not r is Dictionary or not Paths.valid_id(r.get("id")) or ids.has(r.id) or r.get("type") not in ["model","flat","person","section3","door","light"] or not valid_transform(r.get("transform")): return "Distinct typed structural records with checked transforms required."
			var reason := record_reason(r,d.format)
			if not reason.is_empty(): return reason
			ids[r.id] = true
		for r: Dictionary in d.records:
			if r.has("action"):
				if not r.action is Dictionary or not Common.integer(r.action.get("kind"),0,255) or int(r.action.kind) not in F.ACTIONS or not r.action.get("target") is String: return "Supported action and explicit target or empty absent string required."
				var action_fields := ["kind","target","axis","duration","magnitude"] if r.type == "model" else ["kind","target"]
				for field: String in r.action:
					if field not in action_fields: return "Unknown required action parameter: "+field
				if r.type == "model" and (not Common.integer(r.action.get("axis"),0,255) or not Common.integer(r.action.get("duration"),0,65535) or not Common.integer(r.action.get("magnitude"),0,65535)): return "Complete model action parameters required."
				if r.type == "model" and int(r.action.kind) in [1,8] and r.action.axis > 6: return "Unsupported required action axis."
				if r.type == "flat" and (not Common.integer(r.get("magnitude"),0,255) or not Common.integer(r.get("sound_index"),0,255)): return "Complete flat action parameters required."
				if not r.action.target.is_empty() and not ids.has(r.action.target): return "Required action target absent."
				if r.action.kind == 14 and r.action.target.is_empty(): return "Teleport requires an explicit destination."
		var structure_error := structure_reason(d,ids)
		if not structure_error.is_empty(): return structure_error
		if d.format == "RMB":
			for building: Dictionary in d.structure.buildings: ids[building.id] = true
		var destinations := {}
		for old: String in compatibility.remap:
			if not Paths.valid_id(old) or not ids.has(compatibility.remap[old]): return "Explicit remapping target absent."
			if destinations.has(compatibility.remap[old]): return "Ambiguous many-to-one remapping is unsupported."
			destinations[compatibility.remap[old]] = true
	return ""

func validate_source_record(id: String, record: Dictionary, _fields: Dictionary, path: String, source: Dictionary, identity: Dictionary) -> Dictionary:
	if record.has("input") and (not _receipts.has(id) or identity.package != "@shipped/"+VERSION or not Common.equal_input(record.input,_receipts[id])): return F.fail("Source receipt cannot be fabricated or changed.",path,id)
	if record.data.mode == "classic-source" and (not _receipts.has(id) or not record.has("input") or record.data.mapping != id): return F.fail("Classic mapping is not an authorable source address.",path,id)
	if record.data.mode == "classic-source":
		var targets: Array = []
		if record.kind == "block":
			targets = _blocks[id].records.values()+_blocks[id].get("buildings",{}).values()
		else: targets = _locations[id].placements.values()
		var mapped := {}
		for old: String in record.compatibility.remap:
			var target: Variant = record.compatibility.remap[old]
			if not Paths.valid_id(old) or not targets.has(target) or mapped.has(target): return F.fail("Missing or ambiguous source record/placement mapping.",path,old,target,"incompatible")
			mapped[target] = true
	if identity.package == "@shipped/"+VERSION:
		var expected_kind := "block" if _blocks.has(id) else "layout"
		if record.kind != expected_kind: return F.fail("Replacement preserves definition kind.",path,id)
		if record.data.mode == "classic-source":
			var expected := {"mode":"classic-source","mapping":id,"format":_blocks[id].format} if expected_kind == "block" else {"mode":"classic-source","mapping":id,"location":G.ref(id)}
			var mapped_data: Dictionary = record.data.duplicate(true)
			if expected_kind == "layout":
				mapped_data.erase("assembly")
				mapped_data.erase("context")
			if not Common.equal_input(expected,mapped_data): return F.fail("Preserve classic source mapping; replace complete authored data to edit.",path,id)
	if source.provider == identity.package and not str(source.provider).begins_with("@shipped/") and path != "packs/"+("loose" if source.provider == "@loose" else str(source.provider)): return F.fail("Additions use originating package namespace.",path,id)
	return {"ok":true}

func validate_references(resources: Dictionary) -> Array:
	var issues: Array = []
	var names := {}
	var catalog := {}
	for resource: String in resources:
		if not resource.begins_with(DOMAIN+":"): continue
		var path := resource.substr(DOMAIN.length()+1)
		for id: String in resources[resource].records: catalog[path+"#"+id] = resources[resource].records[id]
	for key: String in catalog:
		var r: Dictionary = catalog[key]
		var d: Dictionary = r.value.data
		if r.value.kind == "block" and r.identity.package == "@shipped/"+VERSION:
			var name: String = _blocks[r.identity.record].name
			if names.has(name): issues.append({"source":key,"target":name,"reason":"Ambiguous classic block mapping."})
			names[name] = key
		if r.value.kind != "layout": continue
		if d.has("context"):
			for asset: Dictionary in context_assets(d.context):
				var exports: Dictionary = resources.get("media.assets:exports/"+asset.provider,{}).get("records",{})
				if not exports.has(asset.key) or exports[asset.key].value.kind != "export" or exports[asset.key].value.type != "image": issues.append({"source":key,"target":asset.duplicate(true),"provider":r.winner,"reason":"Required palette image export absent or wrong type."})
			var climate_refs: Dictionary = d.context.climates.duplicate()
			climate_refs.merge(d.context.get("climate_bindings",{}),true)
			for climate: String in climate_refs:
				var c := climate.split("#")
				if not resources.get(G.DOMAIN+":"+c[0],{}).get("records",{}).has(c[1]) or resources[G.DOMAIN+":"+c[0]].records[c[1]].value.kind != "climate": issues.append({"source":key,"target":climate,"provider":r.winner,"reason":"Required palette climate absent or wrong type."})
		var g: PackedStringArray = str(d.get("location","")).split("#")
		if g.size() != 2 or not resources.has(G.DOMAIN+":"+g[0]) or not resources[G.DOMAIN+":"+g[0]].records.has(g[1]) or resources[G.DOMAIN+":"+g[0]].records[g[1]].value.kind != "location": issues.append({"source":key,"target":d.get("location"),"provider":r.winner,"reason":"Required containing location absent."})
		if d.mode == "authored":
			for p: Dictionary in d.placements:
				if not catalog.has(p.block) or catalog[p.block].value.kind != "block": issues.append({"source":key,"record":p.id,"target":p.block,"provider":r.winner,"reason":"Required block absent."})
				elif catalog[p.block].value.data.format != ("RDB" if p.context == "dungeon" else "RMB"): issues.append({"source":key,"record":p.id,"target":p.block,"provider":r.winner,"reason":"Unsupported required block/placement format context."})
	for key: String in catalog:
		var record: Dictionary = catalog[key]
		if record.value.kind != "block" or record.value.data.mode != "authored": continue
		for item: Dictionary in record.value.data.records:
			if not item.has("resource"): continue
			var target: Dictionary = item.resource
			var exports: Dictionary = resources.get("media.assets:exports/"+target.provider,{}).get("records",{})
			if not exports.has(target.key) or exports[target.key].value.type != target.type: issues.append({"source":key,"record":item.id,"target":target.duplicate(true),"provider":record.winner,"reason":"Missing or wrong-type required media export."})
	_index = {"ok":issues.is_empty(),"names":names}
	return issues

static func lookup(registry: RefCounted, ref_: String) -> Dictionary:
	if not G.valid_ref(ref_): return F.fail("Exact layout reference required.",DOMAIN,ref_)
	var parts := ref_.split("#")
	return registry.query(DOMAIN,parts[0],parts[1])

func declared_occurrence_keys(data: Dictionary, kind: String) -> Array:
	# Candidate-time metadata only; this does not decode or certify usable content.
	# The explicit edition ledger reserves identities even for unsupported blocks.
	if data.get("mode") == "classic-source":
		var source: Dictionary = (_locations if kind == "placement" else _blocks).get(data.get("mapping"),{})
		return source.get("placements" if kind == "placement" else "buildings",{}).values().duplicate()
	var entries: Array = data.get("placements",[]) if kind == "placement" else data.get("structure",{}).get("buildings",[])
	return entries.map(func(entry: Dictionary): return entry.id)

static func rmb_building_inputs(definition: Dictionary, mapping: Dictionary) -> Dictionary:
	var buildings := {}
	var records := {}
	for r: Dictionary in definition.records:
		records[r.id] = r
		r.record_context = "exterior"
	if definition.get("mode") == "authored":
		for building: Dictionary in definition.structure.buildings:
			buildings[building.id] = building.duplicate(true)
			for context in ["exterior","interior"]:
				for id: String in building[context]:
					records[id].building_id = building.id
					records[id].record_context = context
	else:
		for sub: Dictionary in definition.subrecords:
			var address := str(int(sub.source_ordinal))
			if not mapping.get("buildings",{}).has(address): return F.fail("Explicit building identity mapping absent.",definition.source,address)
			var id: String = mapping.buildings[address]
			sub.id = id
			# No Y offset is encoded in the RMB building-position table. This is
			# the source parent plane, not a chosen terrain floor or engine pose.
			var parent := F.transform([sub.position.x,0,sub.position.z],[0,sub.position.y_rotation,0])
			var building := {"id":id,"metadata":sub.building.duplicate(true),"transform":parent,"exterior":[],"interior":[]}
			for context in ["exterior","interior"]:
				for r: Dictionary in sub[context].records:
					building[context].append(r.id)
					records[r.id].building_id = id
					records[r.id].record_context = context
			buildings[id] = building
	return {"ok":true,"buildings":buildings}

func decode_block(registry: RefCounted, ref_: String) -> Dictionary:
	var index: Dictionary = registry.domain_index(DOMAIN)
	if not index.ok: return index
	var read := lookup(registry,ref_)
	if not read.ok: return read
	var v: Dictionary = read.record.value
	if v.kind != "block": return F.fail("Reference is not a block.",ref_)
	var definition: Dictionary
	var source_mapping := {}
	if v.data.mode == "authored":
		definition = v.data.duplicate(true)
		for item: Dictionary in definition.records:
			if item.type == "model" and definition.format == "RDB": item.door_metadata = {"classification":"authored-rdb-door-tags-v1","description":item.get("description",""),"candidate":item.get("model_id",-1) != 72100 and item.get("description","") in ["DOR","DDR","NEW","CAV"]}
	else:
		if classic == null or not _blocks.has(v.data.mapping): return F.fail("This layout source provider is unavailable.",ref_,null,null,"provider_unavailable")
		var mapping: Dictionary = _blocks[v.data.mapping]
		source_mapping = mapping
		var raw: Dictionary = classic.read_record("BLOCKS.BSA",{"ordinal":int(mapping.ordinal)})
		if not raw.ok: return raw.merged({"source":_source_paths.get("BLOCKS.BSA",raw.source),"provider":read.record.winner.duplicate(true),"definition":read.record.identity.duplicate(true),"input":v.input.duplicate(true)},true)
		if raw.identity != mapping.name or Common.sha256(raw.bytes) != mapping.sha256: return F.fail("Mapped block source changed; restart/edition mapping required.",ref_,mapping.name)
		definition = F.decode(raw.bytes,mapping.name)
		if not definition.ok: return definition.merged({"provider":read.record.winner.duplicate(true),"definition":read.record.identity.duplicate(true),"input":v.input.duplicate(true)},true)
		for r: Dictionary in definition.records:
			if not mapping.records.has(str(r.address)): return F.fail("Explicit record mapping absent.",ref_,r.address)
			r.id = mapping.records[str(r.address)]
			if r.has("action"):
				r.action.target = mapping.records.get(str(r.action.target_address),"") if r.action.link_required else ""
	if definition.format == "RMB":
		var buildings := rmb_building_inputs(definition,source_mapping)
		if not buildings.ok: return buildings
		definition.building_inputs = buildings.buildings
	elif v.data.mode == "classic-source":
		definition.environment_observation = F.environment(definition.records)
		definition.environment_observation.source_input = v.input.duplicate(true)
		if definition.environment_observation.ok:
			definition.environment_observation.special_roles = ["castle"] if definition.environment_observation.castle else []
			var special: Dictionary = _context_annotations.get("special_blocks",{}).get(v.data.mapping,{})
			if not special.is_empty():
				if special.sha256 != v.input.payload_sha256: return F.fail("Classic special-area annotation input mismatch.",ref_,null,null,"source_changed")
				definition.environment_observation.special_roles.append_array(special.roles)
	return {"ok":true,"definition":definition.duplicate(true),"identity":read.record.identity.duplicate(true),"contributors":read.record.contributors.duplicate(true),"winner":read.record.winner.duplicate(true),"content_context":{"ticket":_ticket,"profile":PROFILE_HASH},"physics_ready":false,"location_ready":false,"save_compatible":false}

func location_inputs(registry: RefCounted, ref_: String) -> Dictionary:
	var committed_index: Dictionary = registry.domain_index(DOMAIN)
	if not committed_index.ok: return committed_index
	var read := lookup(registry,ref_)
	if not read.ok: return read
	if read.record.value.kind != "layout": return F.fail("Reference is not a location layout.",ref_)
	var d: Dictionary = read.record.value.data
	if d.mode == "authored": return {"ok":true,"identity":read.record.identity,"data":d.duplicate(true),"winner":read.record.winner.duplicate(true),"contributors":read.record.contributors.duplicate(true),"content_context":{"ticket":_ticket,"profile":PROFILE_HASH}}
	if classic == null or not _locations.has(d.mapping): return F.fail("This location source provider is unavailable.",ref_,null,null,"provider_unavailable")
	var source_checked := false
	for source: Dictionary in classic.inventory():
		if str(source.source).get_file().to_upper() != "MAPS.BSA": continue
		var digest := FileAccess.get_sha256(source.source)
		if digest.is_empty(): return F.fail("MAPS source is no longer available.",source.source,null,null,"source_unavailable")
		if digest != _profile.files["MAPS.BSA"]: return F.fail("MAPS source changed; explicit edition mapping and restart required.",source.source,null,null,"source_changed")
		source_checked = true
	if not source_checked: return F.fail("Application MAPS source unavailable.",ref_,null,null,"source_unavailable")
	var mapping: Dictionary = _locations[d.mapping]
	var pitem: Dictionary = classic.read_record("MAPS.BSA",{"ordinal":int(mapping.region)*4})
	if not pitem.ok: return pitem
	var ditem: Dictionary = classic.read_record("MAPS.BSA",{"ordinal":int(mapping.region)*4+1})
	if not ditem.ok: return ditem
	var exterior := P.exterior(pitem.bytes,int(mapping.pitem_offset),pitem.source)
	if not exterior.ok: return exterior
	var dungeon := P.dungeon(ditem.bytes,int(mapping.location_id),ditem.source)
	if not dungeon.ok: return dungeon
	var index: Dictionary = registry.domain_index(DOMAIN)
	if not index.ok: return index
	var placements: Array = []
	for context in ["exterior","dungeon"]:
		var decoded: Dictionary = exterior if context == "exterior" else dungeon
		for p: Dictionary in decoded.placements:
			var address := "%s/%d" % [context,int(p.source_ordinal)]
			if not mapping.placements.has(address) or not index.names.has(p.block_name): return F.fail("Required placement mapping/block absent.",ref_,address,p.block_name)
			p.id = mapping.placements[address]
			p.block = index.names[p.block_name]
			placements.append(p)
	var data := {"location":d.location,"placements":placements,"exterior":exterior,"dungeon":dungeon}
	if d.has("assembly"): data.assembly = d.assembly.duplicate(true)
	if d.has("context"): data.context = d.context.duplicate(true)
	return {"ok":true,"identity":read.record.identity,"data":data,"physics_ready":false,"winner":read.record.winner.duplicate(true),"contributors":read.record.contributors.duplicate(true),"content_context":{"ticket":_ticket,"profile":PROFILE_HASH}}

func prepare_location(registry: RefCounted, ref_: String, resource_provider: Callable, required: Array = []) -> Dictionary:
	var layout := location_inputs(registry,ref_)
	if not layout.ok: return layout
	return prepare_structural_inputs(registry,ref_,layout,{},resource_provider,required)

## Pure scoped alternate inputs, supplied by DATA's variant resolver. No publication
## or session state is changed. All normal resource/purpose/parent checks still run.
func prepare_structural_inputs(registry: RefCounted, ref_: String, layout: Dictionary, blocks: Dictionary, resource_provider: Callable, required: Array = [], defer_resources_to_loc := false) -> Dictionary:
	var occurrences: Array = []
	for p: Dictionary in layout.data.placements:
		var block: Dictionary = blocks[p.id].duplicate(true) if blocks.has(p.id) else decode_block(registry,p.block)
		if not block.ok: return block.merged({"placement":p.id,"layout":layout.identity},true)
		if block.definition.format != ("RDB" if p.context == "dungeon" else "RMB"): return F.fail("Block format differs from required placement context.",p.block,p.id,p.context,"unsupported")
		var records: Array = []
		var building_occurrences: Array = []
		for building: Dictionary in block.definition.get("building_inputs",{}).values():
			building_occurrences.append({"identity":{"layout":layout.identity.duplicate(true),"placement":p.id,"record":building.id},"definition":block.identity.duplicate(true),"data":building.duplicate(true)})
		for r: Dictionary in block.definition.records:
			var scoped := {"layout":layout.identity.duplicate(true),"placement":p.id,"record":r.id}
			if r.type in ["model","flat","person","door"] and not defer_resources_to_loc:
				if not resource_provider.is_valid(): return F.fail("Required resource provider unavailable.",p.block,scoped,r.get("model_id",r.get("texture")),"provider_unavailable")
				var resource_request := r.duplicate(true)
				resource_request.definition_identity = block.identity.duplicate(true)
				resource_request.content_context = block.content_context.duplicate(true)
				var result: Dictionary = resource_provider.call(resource_request)
				if not result.get("ok",false): return result.merged({"placement":p.id,"referring":scoped,"provider":block.winner},true)
			var parents: Array = [{"role":"layout-block-placement","source":p.duplicate(true)}]
			if r.has("building_id"):
				if not block.definition.get("building_inputs",{}).has(r.building_id): return F.fail("Required parent building absent.",p.block,r.id,r.building_id)
				parents.append({"role":"rmb-building-placement","identity":{"layout":layout.identity.duplicate(true),"placement":p.id,"record":r.building_id},"transform":block.definition.building_inputs[r.building_id].transform.duplicate(true)})
			parents.append({"role":"record-local","transform":r.transform.duplicate(true)})
			var occurrence := {"identity":scoped,"definition":block.identity.duplicate(true),"record":r.duplicate(true),"context":r.get("record_context",p.context),"placement_context":p.context,"coordinate_handoff":{"schema":"layout-coordinate-handoff-v1","parents":parents,"composition_status":"provider_unavailable","physics_ready":false}}
			if r.has("action") and not r.action.target.is_empty(): occurrence.action_target = {"layout":layout.identity.duplicate(true),"placement":p.id,"record":r.action.target}
			records.append(occurrence)
		occurrences.append({"identity":{"layout":layout.identity.duplicate(true),"placement":p.id},"placement":p.duplicate(true),"definition":block.identity,"records":records,"buildings":building_occurrences})
	for request: Dictionary in required:
		var found := false
		for occurrence: Dictionary in occurrences:
			if occurrence.identity.placement != request.get("placement"): continue
			for record: Dictionary in occurrence.records:
				var type_matches: bool = record.record.type == request.get("type") or (request.get("type") == "door" and record.record.get("door_metadata",{}).get("candidate",false))
				if record.identity.record == request.get("record") and record.record.get("marker_purpose","") == request.get("purpose") and type_matches and (not request.has("context") or request.context == record.context): found = true
		if not found: return F.fail("Required purpose-specific record absent.",ref_,request.get("referring"),request)
	var result := {"ok":true,"layout":layout.identity,"occurrences":occurrences,"content_context":{"ticket":_ticket,"profile":PROFILE_HASH},"structural_only":true,"location_ready":false,"physics_ready":false,"save_compatible":false}
	if defer_resources_to_loc: result.resources_validated = false
	return result

static func resolve_identity(registry: RefCounted, identity: Dictionary) -> Dictionary:
	if identity.get("domain") != DOMAIN or not identity.get("local") is String or not identity.get("record") is String or not identity.get("package") is String: return F.fail("Complete originating layout identity required.")
	var parts: PackedStringArray = identity.local.split("#")
	if parts.size() != 2 or parts[1] != identity.record: return F.fail("Local key and record disagree.")
	var result := lookup(registry,identity.local)
	if result.ok and not Common.equal_input(result.record.identity,identity): return F.fail("Origin differs; never retarget a durable reference.",identity.local,null,null,"missing")
	return result

func prepare_identity(registry: RefCounted, identity: Dictionary, resource_provider: Callable, required: Array = []) -> Dictionary:
	var resolved := resolve_identity(registry,identity)
	if not resolved.ok: return resolved
	return prepare_location(registry,identity.local,resource_provider,required)

func classic_resource(request: Dictionary) -> Dictionary:
	if classic == null or not _index.get("ok",false) or not Common.equal_input(request.get("content_context"),{"ticket":_ticket,"profile":PROFILE_HASH}): return F.fail("Exact active resource content context required.",DOMAIN,null,null,"stale")
	if request.has("resource"):
		if media == null: return F.fail("Actual media export provider unavailable.",DOMAIN,request.get("id"),request.resource,"provider_unavailable")
		var target: Dictionary = request.resource
		var exported: Dictionary = media.export_resource(target.provider,target.key,target.type,_ticket)
		if exported.ok and exported.provenance.get("generation") != _ticket: return F.fail("Obsolete media export generation.",DOMAIN,request.get("id"),target,"stale")
		return exported
	if request.get("type") == "model":
		if not Common.integer(request.get("model_id"),0,4294967295): return F.fail("Exact numeric model identity required.",DOMAIN,request.get("id"))
		return classic.decode_model(int(request.model_id))
	if request.get("type") == "door":
		if not Common.integer(request.get("door_model_index"),0,255) or not _profile.get("rmb_door_models",{}).has(str(int(request.door_model_index))): return F.fail("Unsupported required RMB door resource index; no modulo/default fallback.",DOMAIN,request.get("id"),request.get("door_model_index"),"unsupported")
		return classic.decode_model(int(_profile.rmb_door_models[str(int(request.door_model_index))]))
	if request.get("type") in ["flat","person"]:
		if not request.get("texture") is Dictionary or not Common.integer(request.texture.get("archive"),0,511) or not Common.integer(request.texture.get("record"),0,127): return F.fail("Exact texture archive/record required.",DOMAIN,request.get("id"))
		return classic.read_record("TEXTURE.%03d" % int(request.texture.archive),{"record":int(request.texture.record),"frame":0})
	return F.fail("Unsupported structural resource request.",DOMAIN,request.get("id"),null,"unsupported")

static func convert(request: Dictionary) -> Dictionary:
	var geometry_frame = preload("res://scripts/data/layout_geometry_frame.gd")
	if request.size() == 3 and request.get("source_frame") == geometry_frame.FRAME and request.get("target_frame") == geometry_frame.FRAME and geometry_frame.valid_native(request.get("transform")):
		return {"ok":true,"transform":geometry_frame.pose(request.transform),"tolerance":geometry_frame.POSITION_TOLERANCE,"frame":geometry_frame.FRAME,"physics_ready":false,"motor_qualified":false}
	if request.size() == 3 and request.get("source_frame") == "classic-block-local-v1" and request.get("target_frame") == preload("res://scripts/data/layout_geometry_frame.gd").FRAME and valid_transform(request.get("transform")) and request.transform.frame == request.source_frame:
		var frame = preload("res://scripts/data/layout_geometry_frame.gd")
		var pose: Transform3D = frame.pose(request.transform)
		if not frame.bounded(pose.origin): return F.fail("Geometry precision extent exceeded.",DOMAIN,null,null,"unsupported_conversion")
		return {"ok":true,"transform":pose,"tolerance":frame.POSITION_TOLERANCE,"frame":frame.FRAME,"physics_ready":false,"motor_qualified":false}
	if request.size() != 3 or request.get("source_frame") != "classic-block-local-v1" or request.get("target_frame") != "classic-block-local-v1" or not valid_transform(request.get("transform")) or request.transform.frame != request.source_frame: return F.fail("WORLD/LOC/MOVE conversion provider unavailable.",DOMAIN,null,request.get("target_frame"),"unsupported_conversion")
	return {"ok":true,"transform":request.transform.duplicate(true),"tolerance":0,"rounding":"none","physics_ready":false}

static func check_record_mapping(previous: Array, current: Array, remap: Dictionary, required: Array) -> Dictionary:
	var old_ids := {}
	var new_ids := {}
	for pair in [[previous,old_ids],[current,new_ids]]:
		for id in pair[0]:
			if not Paths.valid_id(id) or pair[1].has(id): return F.fail("Record inventory contains invalid or duplicate identity.",DOMAIN,id,null,"incompatible")
			pair[1][id] = true
	var destinations := {}
	for old in remap:
		var target: Variant = remap[old]
		if not old_ids.has(old) or not new_ids.has(target) or destinations.has(target): return F.fail("Explicit mapping is absent, invalid or ambiguous.",DOMAIN,old,target,"incompatible")
		destinations[target] = true
	for old in required:
		if not old_ids.has(old) or not remap.has(old): return F.fail("Required durable record lacks an explicit mapping.",DOMAIN,old,null,"incompatible")
	return {"ok":true,"mapping":remap.duplicate(true),"structural_only":true,"save_compatible":false,"loc_compatible":false,"quest_compatible":false}
