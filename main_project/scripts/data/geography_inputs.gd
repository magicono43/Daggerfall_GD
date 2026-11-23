extends RefCounted
## Immutable DATA geography. WORLD/LOC/MOVE/SAVE and discovery remain separate.
const Formats = preload("res://scripts/data/geography_formats.gd")
const Common = preload("res://scripts/data/actor_input_formats.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const DOMAIN = "geography.inputs"
const VERSION = "geography-inputs-v1"
const ROOT = "res://content/geography/"
const BASE_PATH = "packs/classic"
var classic: RefCounted
var _receipts := {}
var _source_kinds := {}
var _source_raw := {}
var _source_layout := {}
var _baseline := PackedByteArray()
var _index_ticket := -1
var _index := {}

func begin_candidate(_mods: RefCounted, ticket: int, _registry: RefCounted) -> void:
	_index_ticket = ticket
	_index.clear()

func finish_candidate(_resources: Dictionary, valid: bool) -> void:
	if not valid: _index.clear()

func read_only_index(ticket: int) -> Dictionary:
	if ticket != _index_ticket or not _index.get("ok",false): return Formats.fail("before_readiness","Exact committed geographic index required.")
	return _index.duplicate(true)

static func sources() -> Array:
	return [{"file":"MAPS.BSA","format":"bsa-v1"},{"file":"WOODS.WLD","format":"woods-source-v1"},{"file":"CLIMATE.PAK","format":"geography-pak-v1"},{"file":"POLITIC.PAK","format":"geography-pak-v1"}]

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"required_resources":[BASE_PATH],"capabilities":["data."+VERSION],"classic_sources":sources()}

func validate_resource_path(path: String) -> String:
	var parts := path.split("/")
	return "" if parts.size() == 2 and parts[0] == "packs" and Paths.valid_id(parts[1]) else "Use packs/<origin package ID>."

static func value(kind: String, data: Dictionary, mappings: Array = []) -> Dictionary:
	return {"schema":VERSION,"kind":kind,"data":data,"mappings":mappings}

static func ref(id: String, path := BASE_PATH) -> String:
	return path+"#"+id

func bundle_failure(issue: Dictionary) -> Array:
	return [{"root":ROOT,"file":"baseline.json","read":issue}]

func bundled_contributions() -> Array:
	var profile_bytes := FileAccess.get_file_as_bytes(ROOT+"profile.json")
	if Common.sha256(profile_bytes) != PROFILE_HASH: return bundle_failure(Formats.fail("source_unavailable","Pinned geographic profile missing/changed.",ROOT))
	var profile: Dictionary = JSON.parse_string(profile_bytes.get_string_from_utf8())
	if classic == null or not classic.ready(): return bundle_failure(Formats.fail("before_readiness","Application classic readers required."))
	var inventories := {}
	for source: Dictionary in classic.inventory(): inventories[str(source.source).get_file().to_upper()] = source
	for file: String in profile.files:
		if not inventories.has(file): return bundle_failure(Formats.fail("source_unavailable","Required geographic source absent.",file))
		var source_path: String = inventories[file].source
		var digest := FileAccess.get_sha256(source_path)
		if digest.is_empty(): return bundle_failure(Formats.fail("source_unavailable","Required geographic input no longer readable.",source_path))
		if digest != profile.files[file].sha256: return bundle_failure(Formats.fail("unsupported","Unknown source edition; explicit identity profile required.",source_path))
	# The application source edition is immutable. Reuse only its checked bytes;
	# every candidate still resolves all contributions/indexes from clean state.
	if not _baseline.is_empty(): return bundle(_baseline)
	_receipts.clear()
	_source_kinds.clear()
	_source_raw.clear()
	_source_layout.clear()
	var entries: Array = []
	var by_region := {}
	for mapping: Dictionary in profile.locations:
		if not by_region.has(mapping.region): by_region[mapping.region] = {}
		by_region[mapping.region][int(mapping.ordinal)] = mapping
	for region: Dictionary in profile.regions:
		var ordinal := int(region.ordinal)
		var payloads: Array = []
		var physical: Array = []
		for slot in [3,2,0]:
			var read: Dictionary = classic.read_record("MAPS.BSA",{"ordinal":ordinal*4+slot})
			if not read.ok: return bundle_failure(read)
			payloads.append(read.bytes)
			physical.append({"ordinal":read.ordinal,"offset":read.offset,"directory_name":read.identity})
		var decoded := Formats.region(payloads[0],payloads[1],payloads[2],"MAPS.BSA region "+str(ordinal))
		if not decoded.ok: return bundle_failure(decoded)
		if decoded.locations.size() != int(region.count): return bundle_failure(Formats.fail("unsupported","Region profile count mismatch."))
		var region_value := value("region",{"name":region.name},["selected-classic-v1/region/"+str(ordinal)])
		region_value.input = {"source":"MAPS.BSA","sha256":profile.files["MAPS.BSA"].sha256,"profile":"classic-geography-profile-v1","region":ordinal,"records":physical.duplicate(true)}
		_receipts[region.id] = region_value.input.duplicate(true)
		entries.append({"id":region.id,"value":region_value})
		for location: Dictionary in decoded.locations:
			var mapping: Dictionary = by_region[region.id][int(location.ordinal)]
			for field in ["full_map","map_key","quest_id"]:
				if location[field] != int(mapping[field]): return bundle_failure(Formats.fail("unsupported","Explicit classic mapping does not match source.","MAPS.BSA",mapping.id))
			var data := {"name":location.name,"region":ref(region.id),"position":location.pixel,"type":location.type,"dungeon":location.dungeon,"initial_discovery":{"value":location.source_discovered,"policy":"source-flag-v1","classic_behavior_verified":false},"raw":location.duplicate(true),"layout_source":{"file":"MAPS.BSA","region_record":ref(region.id),"region_ordinal":ordinal,"location_ordinal":location.ordinal,"pitem_offset":location.pitem_offset,"interpretation":"geographic-header-only"}}
			var mappings: Array = ["selected-classic-v1/full/"+str(int(location.full_map)),"selected-classic-v1/pixel/"+str(int(location.map_key))]
			if location.quest_id != 0: mappings.append("selected-classic-v1/quest/"+str(ordinal)+"/"+str(int(location.quest_id)))
			var record := value("location",data,mappings)
			record.input = {"profile":"classic-geography-profile-v1","sha256":profile.files["MAPS.BSA"].sha256,"source":"MAPS.BSA","region":ordinal,"ordinal":location.ordinal}
			_receipts[mapping.id] = record.input.duplicate(true)
			_source_raw[mapping.id] = location.duplicate(true)
			_source_layout[mapping.id] = data.layout_source.duplicate(true)
			entries.append({"id":mapping.id,"value":record})
	var names := ["Ocean","Desert","Desert2","Mountain","Rainforest","Swamp","Subtropical","MountainWoods","Woodlands","HauntedWoodlands"]
	for code in range(223,233):
		entries.append({"id":"climate-"+str(code),"value":value("climate",{"name":names[code-223],"interpretation":"authored-climate-category-v1","category":names[code-223]},["selected-classic-v1/climate/"+str(code)])})
	entries.append({"id":"extent","value":value("context",{"frame":Formats.FRAME,"unit":"map-pixel","bounds":[0,0,1000,500],"tiles":[ref("classic-samples")]})})
	var tile := value("classic_samples",{"bounds":[0,0,1000,500],"profile":"classic-geography-profile-v1","climates":{},"politic":"source-code-only; 64=no-region; 128+region ordinal"})
	for code in range(223,233): tile.data.climates[str(code)] = ref("climate-"+str(code))
	tile.input = profile.files.duplicate(true)
	_receipts["classic-samples"] = tile.input.duplicate(true)
	entries.append({"id":"classic-samples","value":tile})
	for entry: Dictionary in entries: _source_kinds[entry.id] = entry.value.kind
	_baseline = JSON.stringify({"domain":DOMAIN,"path":BASE_PATH,"operation":"add","entries":entries}).to_utf8_buffer()
	return bundle(_baseline)

func bundle(bytes: PackedByteArray) -> Array:
	return [{"root":ROOT,"file":"baseline.json","version":VERSION,"bytes":bytes}]

func validate_source_record(id: String, record: Dictionary, _fields: Dictionary, path: String, source: Dictionary, identity: Dictionary) -> Dictionary:
	if identity.package == "@shipped/"+VERSION and (not _source_kinds.has(id) or _source_kinds[id] != record.kind): return Formats.fail("invalid","Explicit replacement preserves the definition kind.",path,id)
	if record.has("input") and (identity.package != "@shipped/"+VERSION or not _receipts.has(id) or not Common.equal_input(record.input,_receipts[id])): return Formats.fail("invalid","Source receipts cannot be fabricated or changed.",path,id)
	if _receipts.has(id) and identity.package == "@shipped/"+VERSION:
		if not Common.equal_input(record.get("input"),_receipts[id]): return Formats.fail("invalid","Replacement must preserve source receipt.",path,id)
		if record.kind == "location" and (not Common.equal_input(record.data.raw,_source_raw[id]) or not Common.equal_input(record.data.layout_source,_source_layout[id])): return Formats.fail("invalid","Preserve raw geography and physical layout handoff separately from authored position.",path,id)
	if record.kind == "classic_samples" and (not record.has("input") or record.data.profile != "classic-geography-profile-v1"): return Formats.fail("invalid","Classic samples require verified profile.",path,id)
	if source.provider == identity.package and not str(source.provider).begins_with("@shipped/"):
		var owner := "loose" if source.provider == "@loose" else str(source.provider)
		if path != "packs/"+owner: return Formats.fail("invalid","Additions use originating package path.",path,id)
	return {"ok":true}

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var result := previous.duplicate(true)
	for field: String in fields:
		if field in ["schema","kind","input","mappings"] and not Common.equal_input(previous.get(field),fields[field]): return Formats.fail("invalid","Patch cannot change kind/source/mappings.")
		result[field] = fields[field].duplicate(true) if fields[field] is Array or fields[field] is Dictionary else fields[field]
	return {"ok":true,"value":result}

static func valid_ref(target: Variant) -> bool:
	if not target is String: return false
	var parts: PackedStringArray = target.split("#")
	return parts.size() == 2 and Paths.relative_path(parts[0]).ok and Paths.valid_id(parts[1])

static func bounds(value_: Variant) -> bool:
	if not value_ is Array or value_.size() != 4: return false
	for n in value_:
		if not Common.integer(n,-1000000,1000000): return false
	return value_[2] > value_[0] and value_[3] > value_[1] and (value_[2]-value_[0])*(value_[3]-value_[1]) <= 4000000

static func valid_mapping(mapping: Variant, kind: String) -> bool:
	if not mapping is String: return false
	var parts: PackedStringArray = mapping.split("/")
	if parts.size() not in [3,4] or parts[0] != "selected-classic-v1": return false
	var expected := {"region":"region","full":"location","pixel":"location","quest":"location","climate":"climate"}
	if expected.get(parts[1],"") != kind: return false
	var limits := {"region":61,"full":4294967295,"pixel":499999,"quest":61,"climate":255}
	if not parts[2].is_valid_int() or str(int(parts[2])) != parts[2] or int(parts[2]) < 0 or int(parts[2]) > limits[parts[1]]: return false
	if parts[1] == "quest": return parts.size() == 4 and parts[3].is_valid_int() and str(int(parts[3])) == parts[3] and int(parts[3]) > 0 and int(parts[3]) <= 65535
	return parts.size() == 3

func validate_record(_id: String, record: Dictionary) -> String:
	if record.get("schema") != VERSION or record.get("kind") not in ["region","location","climate","context","samples","classic_samples"]: return "Unsupported geography schema/kind."
	for field: String in record:
		if field not in ["schema","kind","data","mappings","input"]: return "Unknown geography field: "+field
	if not record.get("data") is Dictionary or not record.get("mappings") is Array: return "Typed data/mappings required."
	var seen := {}
	for mapping in record.mappings:
		if not valid_mapping(mapping,record.kind) or seen.has(mapping): return "Invalid, wrong-kind or duplicate scoped mapping."
		seen[mapping] = true
	var d: Dictionary = record.data
	match record.kind:
		"region":
			if d.size() != 1 or not d.get("name") is String or d.name.is_empty(): return "Region requires name."
		"climate":
			if d.size() != 3 or not d.get("name") is String or d.get("interpretation") != "authored-climate-category-v1" or not d.get("category") is String or d.category.is_empty(): return "Climate requires explicit versioned category; consumer effects remain unavailable."
		"location":
			for field: String in d:
				if field not in ["name","region","position","type","dungeon","initial_discovery","raw","layout_source"]: return "Unknown location interpretation: "+field
			if not d.get("name") is String or d.name.is_empty() or not valid_ref(d.get("region")): return "Location requires name and region reference."
			if not d.get("position") is Array or d.position.size() != 2: return "Authored pixel required."
			for n in d.position:
				if not Common.integer(n,-1000000,1000000): return "Position must be integral geography pixels."
			if not Common.integer(d.get("type"),0,31) or not Common.integer(d.get("dungeon"),0,255): return "Source classification outside encoded range."
			if not d.get("initial_discovery") is Dictionary or d.initial_discovery.size() != 3 or not d.initial_discovery.get("value") is bool or d.initial_discovery.get("classic_behavior_verified") != false or d.initial_discovery.get("policy") not in ["source-flag-v1","authored-v1"]: return "Explicit authored discovery policy required; no gameplay verification claim."
			if record.has("input") and (not d.get("raw") is Dictionary or not d.get("layout_source") is Dictionary): return "Classic source coordinates/handoff required."
			if not record.has("input") and (d.has("raw") or d.has("layout_source")): return "Authored additions cannot fabricate classic raw/header receipts."
		"context":
			if d.size() != 4 or d.get("frame") != Formats.FRAME or d.get("unit") != "map-pixel" or not bounds(d.get("bounds")) or not d.get("tiles") is Array or d.tiles.is_empty(): return "Versioned extent/frame and explicit coverage tiles required."
			for target in d.tiles:
				if not valid_ref(target): return "Invalid coverage reference."
		"samples":
			if d.size() != 6 or not bounds(d.get("bounds")) or d.get("unit") != "classic-height-u8" or d.get("layout") != "row-major-north-down-v1": return "Sample tile requires explicit extent/unit/layout."
			var count: int = int(d.bounds[2]-d.bounds[0])*int(d.bounds[3]-d.bounds[1])
			for field in ["heights","climates","detail"]:
				if not d.get(field) is Array or d[field].size() != count: return "Incomplete required sample coverage: "+field
			for i in count:
				if not Common.integer(d.heights[i],0,255) or not valid_ref(d.climates[i]) or not d.detail[i] is Array or d.detail[i].size() != 25: return "Invalid required height/climate/detail sample."
				for n in d.detail[i]:
					if not Common.integer(n,0,255): return "Detail samples must be source bytes."
		"classic_samples":
			if d.size() != 4 or not Common.equal_input(d.get("bounds"),[0,0,1000,500]) or d.get("profile") != "classic-geography-profile-v1" or not d.get("climates") is Dictionary or d.climates.size() != 10: return "Unsupported classic tile."
			for code in range(223,233):
				if not valid_ref(d.climates.get(str(code))): return "Every classic climate requires explicit mapping."
	return ""

static func catalog(resources: Dictionary) -> Dictionary:
	var result := {}
	for resource: String in resources:
		if not resource.begins_with(DOMAIN+":"): continue
		var path := resource.substr(DOMAIN.length()+1)
		for id: String in resources[resource].records: result[ref(id,path)] = resources[resource].records[id]
	return result

static func contains(b: Array, x: int, y: int) -> bool:
	return x >= b[0] and y >= b[1] and x < b[2] and y < b[3]

static func indexes(resources: Dictionary) -> Dictionary:
	var records := catalog(resources)
	var mappings := {}
	var pixels := {}
	var names := {}
	var contexts: Array = []
	var issues: Array = []
	for key: String in records:
		var v: Dictionary = records[key].value
		for mapping: String in v.mappings:
			if mappings.has(mapping): issues.append({"source":key,"target":mapping,"reason":"Ambiguous explicit classic mapping."})
			mappings[mapping] = key
		if v.kind == "context": contexts.append(key)
		if v.kind != "location": continue
		var pixel := "%d,%d" % [int(v.data.position[0]),int(v.data.position[1])]
		if not pixels.has(pixel): pixels[pixel] = []
		pixels[pixel].append(key)
		if not names.has(v.data.name): names[v.data.name] = []
		names[v.data.name].append(key)
	if contexts != [ref("extent")]: issues.append({"source":DOMAIN,"reason":"Exactly one required classic extent context must resolve; replace it to expand."})
	var context: Dictionary = records.get(ref("extent"),{}).get("value",{}).get("data",{})
	var tiles: Array = []
	for key: String in records:
		var v: Dictionary = records[key].value
		var targets: Array = []
		var kind := "climate"
		if v.kind == "location":
			targets = [v.data.region]
			if v.data.has("layout_source"): targets.append(v.data.layout_source.region_record)
			kind = "region"
			if not context.is_empty() and not contains(context.bounds,int(v.data.position[0]),int(v.data.position[1])): issues.append({"source":key,"target":v.data.position,"reason":"Location outside declared extent."})
		elif v.kind == "samples": targets = v.data.climates
		elif v.kind == "classic_samples": targets = v.data.climates.values()
		elif v.kind == "context":
			for target: String in v.data.tiles:
				if not records.has(target) or records[target].value.kind not in ["samples","classic_samples"]: issues.append({"source":key,"target":target,"reason":"Missing required sample tile."})
				else: tiles.append(records[target].value.data.bounds)
		for target: String in targets:
			if not records.has(target) or records[target].value.kind != kind: issues.append({"source":key,"target":target,"reason":"Missing required typed geography reference."})
	if not context.is_empty():
		var area := 0
		for i in tiles.size():
			var b: Array = tiles[i]
			if b[0] < context.bounds[0] or b[1] < context.bounds[1] or b[2] > context.bounds[2] or b[3] > context.bounds[3]: issues.append({"source":DOMAIN,"reason":"Tile outside context."})
			area += int(b[2]-b[0])*int(b[3]-b[1])
			for j in i:
				var other: Array = tiles[j]
				if max(b[0],other[0]) < min(b[2],other[2]) and max(b[1],other[1]) < min(b[3],other[3]): issues.append({"source":DOMAIN,"reason":"Overlapping required coverage tiles."})
		if area != int(context.bounds[2]-context.bounds[0])*int(context.bounds[3]-context.bounds[1]): issues.append({"source":DOMAIN,"reason":"Missing interior/extension sample coverage."})
	return {"ok":issues.is_empty(),"issues":issues,"mappings":mappings,"pixels":pixels,"names":names,"records":records,"context":context}

func validate_references(resources: Dictionary) -> Array:
	_index = indexes(resources)
	_index.erase("records") # Derived lookup keys only; registry remains record owner.
	return _index.issues.duplicate(true)

static func lookup(registry: RefCounted, path: String, id: String) -> Dictionary:
	var result: Dictionary = registry.query(DOMAIN,path,id)
	if result.ok:
		result.physics_ready = false
		result.save_compatible = false
	return result

static func resolve_identity(registry: RefCounted, identity: Dictionary) -> Dictionary:
	if identity.get("domain") != DOMAIN or not identity.get("local") is String or not identity.get("record") is String or not identity.get("package") is String: return Formats.fail("malformed","Complete originating definition identity required.")
	var parts: PackedStringArray = identity.local.split("#")
	if parts.size() != 2 or parts[1] != identity.record: return Formats.fail("malformed","Local key and record disagree.")
	var result := lookup(registry,parts[0],parts[1])
	if result.ok and not Common.equal_input(result.record.identity,identity): return Formats.fail("missing","Origin identity differs; never retarget a durable reference.")
	return result

static func search(registry: RefCounted, query: Variant, mode := "pixel") -> Dictionary:
	var index: Dictionary = registry.domain_index(DOMAIN)
	if not index.ok: return index
	var keys: Array = []
	if mode == "pixel":
		if not query is Array or query.size() != 2 or not Common.integer(query[0],-1000000,1000000) or not Common.integer(query[1],-1000000,1000000): return Formats.fail("malformed","Integral pixel query required.")
		if not contains(index.context.bounds,int(query[0]),int(query[1])): return Formats.fail("out_of_bounds","Query outside active geography.")
		keys = index.pixels.get("%d,%d" % [int(query[0]),int(query[1])],[])
	elif mode == "name":
		if not query is String: return Formats.fail("malformed","Name query must be a string.")
		keys = index.names.get(query,[])
	elif mode == "mapping":
		if not query is String: return Formats.fail("malformed","Mapping query must be a string.")
		if not index.mappings.has(query): return Formats.fail("missing","Explicit mapping absent; no name/pixel fallback.")
		keys = [index.mappings[query]]
	else: return Formats.fail("unsupported","Unknown geographic query.")
	var result: Array = []
	for key: String in keys:
		var parts: PackedStringArray = key.split("#")
		var read: Dictionary = registry.query(DOMAIN,parts[0],parts[1])
		if not read.ok: return read
		result.append(read.record)
	return {"ok":true,"records":result,"physics_ready":false}

func sample(registry: RefCounted, x: Variant, y: Variant, clamp_edges := false) -> Dictionary:
	# Validate before conversion: GDScript's float-to-int argument coercion must
	# not silently choose a different source pixel for a fractional request.
	if not Common.integer(x,-2147483648,2147483647) or not Common.integer(y,-2147483648,2147483647): return Formats.fail("malformed","Integral source pixel coordinates required.")
	x = int(x)
	y = int(y)
	# Query only the context and selected tile, not a detached copy of every
	# published actor/location/quest definition for each individual sample.
	var context_read: Dictionary = registry.query(DOMAIN,BASE_PATH,"extent")
	if not context_read.ok: return context_read
	var context: Dictionary = context_read.record.value.data
	var requested := [x,y]
	if not contains(context.bounds,x,y):
		if not clamp_edges: return Formats.fail("out_of_bounds","Ordinary sample query outside geography.")
		x = clampi(x,int(context.bounds[0]),int(context.bounds[2])-1)
		y = clampi(y,int(context.bounds[1]),int(context.bounds[3])-1)
	for key: String in context.tiles:
		var parts: PackedStringArray = key.split("#")
		var tile_read: Dictionary = registry.query(DOMAIN,parts[0],parts[1])
		if not tile_read.ok: return tile_read
		var tile: Dictionary = tile_read.record.value
		if not contains(tile.data.bounds,x,y): continue
		var result: Dictionary
		if tile.kind == "classic_samples":
			if classic == null: return Formats.fail("source_unavailable","Application classic reader provider unavailable.")
			result = classic.read_record("WOODS.WLD",[x,y])
			if not result.ok: return result
			var climate: Dictionary = classic.read_record("CLIMATE.PAK",[x+1,y])
			if not climate.ok: return climate
			var politic: Dictionary = classic.read_record("POLITIC.PAK",[x+1,y])
			if not politic.ok: return politic
			if not tile.data.climates.has(str(climate.value)): return Formats.fail("unsupported","Required climate code has no mapping.",climate.source,climate.value)
			result.climate = tile.data.climates[str(climate.value)]
			result.climate_raw_code = climate.value
			result.climate_source_pixel = [x+1,y]
			result.politic_raw_code = politic.value
			result.source_input = {"source":result.source,"sha256":result.sha256,"detail_offset":result.offset,"climate":{"source":climate.source,"sha256":climate.sha256,"pixel":[x+1,y]},"politic":{"source":politic.source,"sha256":politic.sha256,"pixel":[x+1,y]}}
		else:
			var i: int = (y-int(tile.data.bounds[1]))*int(tile.data.bounds[2]-tile.data.bounds[0])+x-int(tile.data.bounds[0])
			result = {"ok":true,"value":tile.data.heights[i],"detail":tile.data.detail[i].duplicate(),"climate":tile.data.climates[i],"unit":tile.data.unit}
		result.requested = requested
		result.pixel = [x,y]
		result.clamped = requested != [x,y]
		result.frame = Formats.FRAME
		result.source = tile_read.record.winner.duplicate(true)
		result.physics_ready = false
		return result
	return Formats.fail("missing","Required interior coverage absent; never clamp a hole.")

static func detail_neighborhood(raw: Array) -> Dictionary:
	if raw.size() != 25: return Formats.fail("malformed","Classic detail cell requires 25 samples.")
	var samples: Array = []
	for y in range(1,4):
		for x in range(1,4): samples.append(raw[(4-y)*5+x])
	return {"ok":true,"samples":samples,"layout":"row-major-classic-detail-reversed-y-v1","unit":"classic-height-u8","generated":false}
const PROFILE_HASH = "3da6ad3df76d177619329a6a3fdc28e5a9a0d4374bc9dbace55bf90b4696fe8d"

