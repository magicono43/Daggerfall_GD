extends RefCounted
## DATA adapter and generation-scoped read-only resources. AV owns live instances.
const DOMAIN = "media.assets"
const VERSION = "media-declarations-v1"
const Paths = preload("res://scripts/mod/package_library.gd")
const Codec = preload("res://scripts/data/replacement_codec.gd")
var _targets: Dictionary = {}
var _aliases: Dictionary = {}
var _mods: RefCounted
var _registry: RefCounted
var _generation := -1
var _cache: Dictionary = {}
var _source_keys: Dictionary = {}
var _loose: Dictionary = {}
var _records: Dictionary = {}
var _active := false
var _valid := false
var measurements: Dictionary = {}
var _context := ""
var _package_reads: Dictionary = {}
var _scan := -1
var shipped_sources: Array = [] # Trusted application declarations before registration.

func bundled_contributions() -> Array:
	var result: Array = []
	for source: Dictionary in shipped_sources:
		result.append({"root":source.root,"file":source.file,"version":VERSION,"bytes":FileAccess.get_file_as_bytes(str(source.root).path_join(source.file))})
	return result

func declaration() -> Dictionary:
	return {"id":"media-assets","domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"capabilities":["data.media-v1"]}

func register_target(id: String, type: String, aliases: Array, baseline: Callable) -> Dictionary:
	if _generation >= 0 or not Paths.valid_id(id) or type not in ["image","model","audio","midi","bank","video"] or _aliases.has(id): return {"ok":false,"reason":"Invalid, ambiguous or late target registration."}
	var seen := {id:true}
	for alias in aliases:
		if not Paths.valid_id(alias) or _aliases.has(alias) or seen.has(alias): return {"ok":false,"reason":"Ambiguous target alias."}
		seen[alias] = true
	_targets[id] = {"type":type,"baseline":baseline}
	for alias in seen: _aliases[alias] = id
	return {"ok":true}

func begin_candidate(mods: RefCounted, ticket: int, registry: RefCounted) -> void:
	_mods = mods
	_registry = registry
	_generation = ticket
	if _scan != mods.discovery_generation:
		_package_reads.clear()
		_scan = mods.discovery_generation
	_context = JSON.stringify([ticket,mods.revision,mods.selected,mods.planning_input()])
	_cache = {}
	_source_keys = {}
	_records = {}
	_valid = false
	measurements = {"source_bytes":0,"decoded_exports":0,"decode_microseconds":0,"generation":ticket}

func validate_resource_path(path: String) -> String:
	return "" if path == "targets" or path == "exports" else "Media resource path must be targets or exports."

func resource_path(path: String, source: Dictionary) -> String:
	return path + "/" + str(source.provider) if path == "exports" else path

func record_id(id: String, _value: Dictionary, path: String) -> String:
	return str(_aliases.get(id,id)) if path == "targets" else id

func validate_record(_id: String, value: Dictionary) -> String:
	if value.get("schema") != VERSION or value.get("type") not in ["image","model","audio","midi","bank","video"]: return "Expected versioned media schema and supported type."
	var keys: Array = ["schema","kind","type","file","profile"] if value.get("kind") == "export" else ["schema","kind","type","asset"]
	for key in value:
		if key not in keys: return "Unsupported media field: " + key
	if value.get("kind") == "export":
		if not value.get("file") is String or not Paths.relative_path(value.file).ok or not value.get("profile") is String: return "Export requires checked relative file and explicit profile."
	elif value.get("kind") == "target":
		if not value.get("asset") is Dictionary or value.asset.size() != 2 or not value.asset.get("provider") is String or not value.asset.get("key") is String or not Paths.valid_id(value.asset.key): return "Target needs exact provider/key export reference."
	else: return "Media kind must be export or target."
	return ""

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	value.merge(fields,true)
	return {"ok":true,"value":value}

func _descriptor(value: Dictionary, fields: Dictionary, id: String) -> String:
	var backend: Variant = Codec.Native.capabilities() if value.get("profile") in ["midi-v1","sf2-v1","webm-v1","mp4-v1"] else "engine"
	return JSON.stringify([_context,id,value,fields.get("file",{}),Codec.VERSION,Engine.get_version_info().hash,backend]).sha256_text()

func _read(source: Dictionary, file: String) -> Dictionary:
	if str(source.provider).begins_with("@shipped/"):
		if not str(source.root).begins_with("res://content/media/"): return Codec.fail("invalid_path","Shipped media requires explicit res://content/media root.")
		var path: String = source.root.path_join(file)
		if not FileAccess.file_exists(path): return Codec.fail("missing","Shipped media dependency missing: " + path)
		return {"ok":true,"bytes":FileAccess.get_file_as_bytes(path)}
	if source.provider == "@loose":
		return _registry.read_loose_media(file)
	var key := JSON.stringify([source.provider,source.root,file])
	if not _package_reads.has(key): _package_reads[key] = _mods.read_package_file(source.provider,file)
	return _package_reads[key].duplicate(true)

func validate_source_record(id: String, value: Dictionary, fields: Dictionary, path: String, source: Dictionary, origin: Dictionary) -> Dictionary:
	if value.kind == "target":
		if path != "targets": return Codec.fail("invalid","Target declaration belongs in targets.")
		if _targets.has(id):
			if _targets[id].type != value.type: return Codec.fail("wrong_type","Target owner type mismatch: " + id)
		elif not id.begins_with("asset." + str(origin.package) + "."):
			return Codec.fail("unknown_target","Unknown target/alias; additions must use asset.<origin provider>.<local>.")
		return {"ok":true}
	if not path.begins_with("exports/"): return Codec.fail("invalid","Export declaration belongs in exports.")
	var descriptor := _descriptor(value,fields,id)
	if _source_keys.has(descriptor): return {"ok":true}
	var loaded := _read(fields.file,value.file)
	if not loaded.ok:
		loaded.reason = "%s/%s (%s): %s" % [fields.file.provider,id,value.file,loaded.reason]
		return loaded
	var start := Time.get_ticks_usec()
	var decoded := Codec.decode(loaded.bytes,value.profile,value.type)
	measurements.decode_microseconds += Time.get_ticks_usec()-start
	if not decoded.ok:
		decoded.reason = "%s/%s (%s, %s): %s" % [fields.file.provider,id,value.file,value.profile,decoded.reason]
		return decoded
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(loaded.bytes)
	var digest := hash.finish().hex_encode()
	var key := JSON.stringify([descriptor,digest,decoded.get("converter"),decoded.get("frame","")]).sha256_text()
	decoded.provenance = {"provider":fields.file.provider,"source":fields.file.duplicate(true),"file":value.file,"profile":value.profile,"sha256":digest,"converter":decoded.converter,"generation":_generation,"cache_key":key}
	if decoded.has("backend"): decoded.provenance.backend = decoded.backend
	_cache[key] = decoded
	_source_keys[descriptor] = key
	measurements.source_bytes += loaded.bytes.size()
	measurements.decoded_exports += 1
	return {"ok":true}

func validate_references(resources: Dictionary) -> Array:
	var issues: Array = []
	for resource: Dictionary in resources.values():
		if resource.domain != DOMAIN: continue
		for id: String in resource.records:
			var record: Dictionary = resource.records[id]
			var value: Dictionary = record.value
			if value.kind != "target": continue
			var exports: Dictionary = resources.get(DOMAIN+":exports/"+value.asset.provider,{}).get("records",{})
			var reason := ""
			if not exports.has(value.asset.key): reason = "Missing exact provider/export: " + JSON.stringify(value.asset)
			elif exports[value.asset.key].value.type != value.type: reason = "Wrong export type for " + id
			if not reason.is_empty():
				var source: Dictionary = record.fields.asset
				issues.append({"source":id,"reason":reason,"token":source.token,"omittable":not str(source.provider).begins_with("@shipped/")})
	return issues

func finish_candidate(resources: Dictionary, valid: bool) -> void:
	_records = {}
	for key: String in resources:
		if resources[key].domain == DOMAIN: _records[key] = resources[key].duplicate(true)
	_valid = valid
	var retained := {}
	for resource: Dictionary in resources.values():
		if resource.domain != DOMAIN: continue
		for id: String in resource.records:
			var record: Dictionary = resource.records[id]
			if record.value.kind == "export":
				var descriptor := _descriptor(record.value,record.fields,id)
				if _source_keys.has(descriptor): retained[_source_keys[descriptor]] = _cache[_source_keys[descriptor]]
	_cache = retained

func commit_candidate() -> void:
	_active = true # All decode/read work already completed before durable history.

func _export(provider: String, key: String, expected: String, request: String) -> Dictionary:
	if not _records.has(DOMAIN+":exports/"+provider) and not _mods.available().has(provider) and provider not in ["@loose","@shipped/media-assets"]: return Codec.fail("missing_provider","Provider unavailable: " + provider)
	var records: Dictionary = _records.get(DOMAIN+":exports/"+provider,{}).get("records",{})
	if not records.has(key): return Codec.fail("missing_export","Missing exact provider/export: " + provider + "/" + key)
	var record: Dictionary = records[key]
	if record.value.type != expected: return Codec.fail("wrong_type","Export type mismatch: " + provider + "/" + key)
	var descriptor := _descriptor(record.value,record.fields,key)
	if not _source_keys.has(descriptor) or not _cache.has(_source_keys[descriptor]): return Codec.fail("unavailable","Prepared resource is unavailable.")
	var cached: Dictionary = _cache[_source_keys[descriptor]]
	# Resources are deliberately read-only by contract; value projections are detached.
	return {"ok":true,"kind":"ready","resource":cached.duplicate(true),"provenance":cached.provenance.duplicate(true),"record":record.duplicate(true),"request_key":JSON.stringify([_generation,request,expected,cached.provenance.cache_key]).sha256_text()}

func export_resource(provider: String, key: String, expected: String, ticket := -1) -> Dictionary:
	if not _valid or (not _active and (ticket != _generation or _context != JSON.stringify([_generation,_mods.revision,_mods.selected,_mods.planning_input()]))): return Codec.fail("before_readiness","Current valid preview ticket or committed media required.")
	var result := _export(provider,key,expected,"provider:"+provider+"/"+key)
	if not result.ok: result.merge({"provider":provider,"export":key,"generation":_generation})
	return result

func resolve(target: String, expected: String, ticket := -1) -> Dictionary:
	if not _valid or (not _active and (ticket != _generation or _context != JSON.stringify([_generation,_mods.revision,_mods.selected,_mods.planning_input()]))): return Codec.fail("before_readiness","Current valid preview ticket or committed media required.")
	var canonical: String = _aliases.get(target,target)
	var records: Dictionary = _records.get(DOMAIN+":targets",{}).get("records",{})
	if records.has(canonical):
		var record: Dictionary = records[canonical]
		if record.value.type != expected: return Codec.fail("wrong_type","Logical target type mismatch: " + canonical)
		var result := _export(record.value.asset.provider,record.value.asset.key,expected,"target:"+canonical)
		result.target = canonical
		result.target_record = record.duplicate(true)
		return result
	if not _targets.has(canonical): return Codec.fail("unknown_target","No owner declares target: " + canonical)
	if _targets[canonical].type != expected: return Codec.fail("wrong_type","Baseline owner type mismatch.")
	var baseline: Callable = _targets[canonical].baseline
	if not baseline.is_valid(): return Codec.fail("baseline_unavailable","Owner baseline unavailable: " + canonical)
	var original: Dictionary = baseline.call() # Never called for an invalid selected replacement.
	original.target = canonical
	original.resolution = "baseline"
	original.provider = original.get("provider","classic")
	return original

func diagnostics() -> Dictionary:
	var rows := {}
	for resource: Dictionary in _records.values():
		for id: String in resource.records:
			var value: Dictionary = resource.records[id].value
			var result: Dictionary
			if value.kind == "target": result = _export(value.asset.provider,value.asset.key,value.type,id)
			else: result = _export(str(resource.path).trim_prefix("exports/"),id,value.type,id)
			rows[resource.path+"#"+id] = {"generation":_generation,"converter":Codec.VERSION,"source":result.get("provenance",{}).duplicate(true),"reason":result.get("reason","")}
	return rows

func has_midi_exports() -> bool:
	for resource: Dictionary in _records.values():
		for record: Dictionary in resource.records.values():
			if record.value.kind == "export" and record.value.type == "midi": return true
	return false

func bank_exports() -> Array:
	var result: Array = []
	for resource: Dictionary in _records.values():
		if not str(resource.path).begins_with("exports/"): continue
		for id: String in resource.records:
			if resource.records[id].value.type == "bank":
				var provider: String = str(resource.path).trim_prefix("exports/")
				result.append({"label":provider+" / "+id,"provider":provider,"key":id})
	return result

func dispose() -> void:
	_cache.clear()
	_source_keys.clear()
	_records.clear()
	_loose.clear()
	_package_reads.clear()
	_targets.clear()
	_aliases.clear()
	_mods = null
	_registry = null
	_valid = false
