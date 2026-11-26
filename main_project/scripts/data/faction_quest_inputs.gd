extends RefCounted
## DATA source publication. FACT/QUEST/SAVE interpretation deliberately unavailable.
const Formats = preload("res://scripts/data/faction_quest_formats.gd")
const Common = preload("res://scripts/data/actor_input_formats.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const DOMAIN = "faction-quest.inputs"
const VERSION = "faction-quest-inputs-v1"
const ROOT = "res://content/faction_quest/"
const PROFILE_HASH = "cf66ec631c3462417eae0ea6aa7fbe3797d4fa9232e9f1eaaed3cf894962ac56"
const BASE_PATH = "packs/dfu"
var _index_ticket := -1
var _index: Dictionary = {}

func begin_candidate(_mods: RefCounted, ticket: int, _registry: RefCounted) -> void:
	_index_ticket = ticket
	_index.clear()

func finish_candidate(_resources: Dictionary, valid: bool) -> void:
	if not valid: _index.clear()

func read_only_index(ticket: int) -> Dictionary:
	if ticket != _index_ticket or not _index.get("ok",false): return Formats.fail("before_readiness","Exact committed faction index required.")
	return _index.duplicate(true)

func point_query(ticket: int, context: Dictionary) -> Dictionary:
	# Narrow mapping projection: consumers need not copy the complete faction/
	# quest graph to bind one retained biography obligation.
	if ticket != _index_ticket or not _index.get("ok",false): return Formats.fail("before_readiness","Exact committed faction index required.")
	if context.size() != 1 or not context.get("mapping") is String: return Formats.fail("invalid_mapping","One explicit mapping required.")
	var matches: Array = _index.mappings.get(context.mapping,[])
	if matches.is_empty(): return Formats.fail("missing","Required mapping absent.",DOMAIN,0,"",context.mapping)
	if matches.size() != 1: return Formats.fail("ambiguous","Required mapping is ambiguous.",DOMAIN,0,"",context.mapping)
	var parts: PackedStringArray = str(matches[0]).split("#")
	return {"ok":true,"reference":{"path":parts[0],"id":parts[1]}}

var _receipts: Dictionary = {}
var _mappings: Dictionary = {}
var _kinds: Dictionary = {}

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"required_resources":[BASE_PATH],"capabilities":["data."+VERSION]}

func validate_resource_path(path: String) -> String:
	var parts := path.split("/")
	return "" if parts.size() == 2 and parts[0] == "packs" and Paths.valid_id(parts[1]) else "Use packs/<origin package ID> or an explicit existing replacement target."

static func ref(path: String, id: String) -> Dictionary:
	return {"path":path,"id":id}

static func value(kind: String, data: Dictionary, mappings: Array = []) -> Dictionary:
	return {"schema":VERSION,"kind":kind,"data":data,"mappings":mappings}

static func from_text(kind: String, text: String, source := "") -> Dictionary:
	var parsed := Formats.decode(kind,text.to_utf8_buffer(),source)
	if not parsed.ok: return parsed
	var data: Dictionary = parsed.data.duplicate(true)
	data.text = parsed.text
	return {"ok":true,"value":value(kind,data)}

func bundled_contributions() -> Array:
	_receipts.clear()
	_mappings.clear()
	_kinds.clear()
	var profile_bytes := FileAccess.get_file_as_bytes(ROOT+"profile.json")
	if Common.sha256(profile_bytes) != PROFILE_HASH: return bundle_failure(Formats.fail("source_unavailable","Pinned identity profile missing/changed.",ROOT+"profile.json"))
	var profile: Dictionary = JSON.parse_string(profile_bytes.get_string_from_utf8())
	var entries: Array = []
	var quest_names := {}
	for descriptor: Dictionary in profile.resources:
		if descriptor.kind == "quest": quest_names[descriptor.legacy] = descriptor.id
	for descriptor: Dictionary in profile.resources:
		var file: String = ROOT+descriptor.file
		if not FileAccess.file_exists(file): return bundle_failure(Formats.fail("missing","Shipped source missing.",file))
		var handle := FileAccess.open(file,FileAccess.READ)
		if handle == null: return bundle_failure(Formats.fail("unavailable","Shipped source unreadable.",file))
		var bytes := handle.get_buffer(handle.get_length())
		var read_error := handle.get_error()
		handle.close()
		if read_error != OK: return bundle_failure(Formats.fail("unavailable","Incomplete shipped read.",file))
		if Common.sha256(bytes) != descriptor.sha256: return bundle_failure(Formats.fail("source_unavailable","Shipped source changed; rebuild/restart required.",file))
		var decoded := Formats.decode(descriptor.kind,bytes,file)
		if not decoded.ok: return bundle_failure(decoded)
		var receipt := {"source":file,"sha256":descriptor.sha256,"profile":"dfu-faction-quest-profile-v1","format":descriptor.kind,"license":"DFU_LICENSE.txt"}
		if descriptor.kind == "factions":
			for legacy: String in decoded.records:
				var raw: Dictionary = decoded.records[legacy]
				var metadata: Dictionary = raw.fields.duplicate(true)
				var defaults := {}
				for field in ["rep","rank"]:
					if metadata.has(field):
						defaults[field] = metadata[field]
						metadata.erase(field)
				var data := {"metadata":metadata,"defaults":defaults,"parent":{} if raw.parent.is_empty() else ref(BASE_PATH,"faction-"+raw.parent),"allies":[],"enemies":[],"flats":raw.flats,"line":raw.line,"field_lines":raw.field_lines}
				for field in ["allies","enemies"]:
					for target: int in raw[field]:
						# Explicit zero means an unused relationship slot, not faction zero.
						if target != 0: data[field].append(ref(BASE_PATH,"faction-"+str(target)))
				var record := value("faction",data,["faction:"+legacy])
				record.input = receipt.duplicate(true)
				record.input.record = legacy
				record.input.original = raw.duplicate(true)
				entries.append({"id":"faction-"+legacy,"value":record})
		else:
			var data: Dictionary = decoded.data.duplicate(true)
			data.text = decoded.text
			if descriptor.kind == "list":
				data.targets = {}
				for row: Dictionary in data.rows:
					if not quest_names.has(row.key): return bundle_failure(Formats.fail("missing","List quest has no explicit source mapping.",file,row.line,descriptor.id,row.key))
					data.targets[row.key] = ref(BASE_PATH,quest_names[row.key])
			var record := value(descriptor.kind,data,[descriptor.kind+":"+descriptor.legacy])
			record.input = receipt
			entries.append({"id":descriptor.id,"value":record})
	for entry: Dictionary in entries:
		_receipts[entry.id] = entry.value.input.duplicate(true)
		_mappings[entry.id] = entry.value.mappings.duplicate(true)
		_kinds[entry.id] = entry.value.kind
	return [{"root":ROOT,"file":"baseline.json","version":VERSION,"bytes":JSON.stringify({"domain":DOMAIN,"path":BASE_PATH,"operation":"add","entries":entries}).to_utf8_buffer()}]

func bundle_failure(issue: Dictionary) -> Array:
	return [{"root":ROOT,"file":"baseline.json","read":issue}]

func validate_source_record(id: String, record: Dictionary, _fields: Dictionary, path: String, source: Dictionary, identity: Dictionary) -> Dictionary:
	var builtin: bool = identity.package == "@shipped/"+VERSION
	if builtin:
		if not _receipts.has(id) or not Common.equal_input(record.get("input"),_receipts[id]) or not Common.equal_input(record.mappings,_mappings[id]) or record.kind != _kinds[id]: return Formats.fail("malformed","Baseline replacements retain original source kind, receipt and mappings.",JSON.stringify(source),0,id)
	elif record.has("input"):
		return Formats.fail("malformed","Package additions cannot fabricate shipped receipts.",JSON.stringify(source),0,id)
	if identity.package == source.provider and not builtin:
		var owner: String = "loose" if source.provider == "@loose" else str(source.provider)
		if path != "packs/"+owner: return Formats.fail("invalid","New definitions belong in their originating package path.",JSON.stringify(source),0,id,path)
	return {"ok":true}

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	# Whole source/data replacement only. No executable-line or row-level merge.
	var result := previous.duplicate(true)
	for field: String in fields:
		if field in ["schema","kind","mappings","input"] and not Common.equal_input(previous.get(field),fields[field]): return {"ok":false,"reason":"Patch cannot remap source identity."}
		result[field] = fields[field].duplicate(true) if fields[field] is Dictionary or fields[field] is Array else fields[field]
	return {"ok":true,"value":result}

static func valid_ref(target: Variant) -> bool:
	return target is Dictionary and target.size() == 2 and target.get("path") is String and Paths.relative_path(target.path).ok and Paths.valid_id(target.get("id"))

func validate_record(_id: String, record: Dictionary) -> String:
	if record.get("schema") != VERSION or record.get("kind") not in ["faction","quest","list","table"]: return "Unsupported faction/quest schema or kind."
	for field: String in record:
		if field not in ["schema","kind","data","mappings","input"]: return "Unknown required field: "+field
	if not record.get("data") is Dictionary or not record.get("mappings") is Array: return "Typed data and explicit mappings required."
	if record.has("input") and not record.input is Dictionary: return "Input receipt must be an object."
	var mappings := {}
	for mapping in record.mappings:
		if not mapping is String or not mapping.begins_with(str(record.kind)+":") or mapping.length() <= str(record.kind).length()+1 or mappings.has(mapping): return "Invalid, wrong-kind or duplicate mapping."
		mappings[mapping] = true
	var data: Dictionary = record.data
	if record.kind != "faction":
		if not data.get("text") is String: return "Complete source text required."
		var decoded := Formats.decode(record.kind,data.text.to_utf8_buffer())
		if not decoded.ok: return decoded.kind+": "+decoded.reason
		var expected: Dictionary = decoded.data.duplicate(true)
		expected.text = decoded.text
		if record.kind == "list":
			if not data.get("targets") is Dictionary or data.targets.size() != expected.rows.size(): return "Every selection entry requires exactly one explicit source target."
			var seen := {}
			for row: Dictionary in expected.rows:
				var target: Variant = data.targets.get(row.key)
				if not valid_ref(target): return "Invalid quest target: "+row.key
				var key: String = target.path+"#"+target.id
				if seen.has(key): return "Duplicate same-list quest target, including aliases."
				seen[key] = true
			expected.targets = data.targets
		if not Common.equal_input(data,expected): return "Source text and typed projection disagree; supply complete replacement data."
		return ""
	if data.size() != 8: return "Faction requires exact metadata/defaults/parent/relations/appearance/source-location fields."
	for field in ["metadata","defaults","parent","field_lines"]:
		if not data.get(field) is Dictionary: return "Invalid faction container: "+field
	if not data.metadata.get("name") is String or data.metadata.name.is_empty() or not data.metadata.has("type"): return "Faction name/type required."
	for field: String in data.metadata:
		if field != "name" and (field not in Formats.NUMBERS or field in ["rep","rank"] or not Common.integer(data.metadata[field],-2147483648,2147483647)): return "Invalid faction metadata: "+field
	for field: String in data.defaults:
		if field not in ["rep","rank"] or not Common.integer(data.defaults[field],-2147483648,2147483647): return "Invalid authored starting default."
	if not data.parent.is_empty() and not valid_ref(data.parent): return "Parent requires explicit root {} or path/id."
	if not Common.integer(data.get("line"),0,2147483647): return "Source line required (zero for additions)."
	for tag: String in data.field_lines:
		if tag not in Formats.NUMBERS + ["name","ally","enemy","flat"] or not data.field_lines[tag] is Array: return "Invalid source field-line metadata."
		for line in data.field_lines[tag]:
			if not Common.integer(line,1,2147483647): return "Source field lines must be positive physical line numbers."
	for field in ["allies","enemies","flats"]:
		if not data.get(field) is Array: return "Faction arrays required."
	for field in ["allies","enemies"]:
		for target in data[field]:
			if not valid_ref(target): return "Invalid directional faction target."
	for flat in data.flats:
		if not flat is Array: return "Invalid appearance reference."
		if flat.size() == 1 and Common.integer(flat[0],-1,-1): continue
		if flat.size() != 2 or not Common.integer(flat[0],0,16777215) or not Common.integer(flat[1],0,127): return "Invalid flat source archive/record."
	return ""

static func catalog(resources: Dictionary) -> Dictionary:
	var result := {}
	for resource: String in resources:
		if not resource.begins_with(DOMAIN+":"): continue
		var path := resource.substr(DOMAIN.length()+1)
		for id: String in resources[resource].records: result[path+"#"+id] = resources[resource].records[id]
	return result

static func target_key(target: Dictionary) -> String:
	return str(target.path)+"#"+str(target.id)

static func graph(resources: Dictionary) -> Dictionary:
	var records := catalog(resources)
	var children := {}
	var mappings := {}
	var issues: Array = []
	for key: String in records:
		var record: Dictionary = records[key]
		if record.value.kind == "faction": children[key] = []
		for mapping: String in record.value.mappings:
			if not mappings.has(mapping): mappings[mapping] = []
			mappings[mapping].append(key)
	for mapping: String in mappings:
		if mappings[mapping].size() > 1: issues.append({"source":DOMAIN,"target":mapping,"reason":"Ambiguous explicit legacy mapping.","candidates":mappings[mapping]})
	for key: String in records:
		var record: Dictionary = records[key]
		var data: Dictionary = record.value.data
		var targets: Array = []
		if record.value.kind == "faction":
			targets = data.allies + data.enemies
			if not data.parent.is_empty(): targets.append(data.parent)
		elif record.value.kind == "list": targets = data.targets.values()
		for target: Dictionary in targets:
			var resolved := target_key(target)
			var required_kind := "quest" if record.value.kind == "list" else "faction"
			var line: int = int(data.get("line",0))
			if record.value.kind == "list":
				for row: Dictionary in data.rows:
					if target_key(data.targets[row.key]) == resolved:
						line = int(row.line)
						break
			if not records.has(resolved) or records[resolved].value.kind != required_kind: issues.append({"source":key,"referring":key,"target":resolved,"provider":record.winner,"line":line,"reason":"Missing required typed target."})
		if record.value.kind != "faction": continue
		if not data.parent.is_empty() and children.has(target_key(data.parent)): children[target_key(data.parent)].append(key)
		var path: Array[String] = []
		var cursor := key
		while records.has(cursor) and records[cursor].value.kind == "faction":
			if path.has(cursor):
				path = path.slice(path.find(cursor))
				path.append(cursor)
				issues.append({"source":key,"target":cursor,"provider":record.winner,"reason":"Parent cycle: "+" -> ".join(path),"cycle":path})
				break
			path.append(cursor)
			var parent: Dictionary = records[cursor].value.data.parent
			if parent.is_empty(): break
			cursor = target_key(parent)
	for key: String in children: children[key].sort()
	return {"ok":issues.is_empty(),"children":children,"mappings":mappings,"issues":issues}

func validate_references(resources: Dictionary) -> Array:
	var checked := graph(resources)
	if resources.get(DOMAIN+":"+BASE_PATH,{}).get("records",{}).is_empty(): checked.issues.append({"source":DOMAIN,"target":BASE_PATH,"reason":"Required source catalog is empty."})
	# Lookup keys only; authoritative records stay with DATA.
	_index = checked.duplicate(true)
	_index.ok = checked.issues.is_empty()
	return checked.issues

static func lookup(registry: RefCounted, path: String, id: String, use := "structural") -> Dictionary:
	var result: Dictionary = registry.query(DOMAIN,path,id)
	if not result.ok: return result
	result.structural_available = true
	result.semantic_ready = false
	result.required_owners = ["FACT IMP-032","QUEST IMP-028","SAVE compatibility","CORE-012 opening content"]
	if use != "structural": return Formats.fail("semantic_unavailable","Real FACT/QUEST validation is unavailable.",path,0,id,use).merged({"semantic_ready":false,"structural_available":true})
	return result

static func lookup_mapping(registry: RefCounted, mapping: String) -> Dictionary:
	var index: Dictionary = registry.domain_index(DOMAIN)
	if not index.ok: return index
	var matches: Array = index.mappings.get(mapping,[])
	if matches.is_empty(): return Formats.fail("missing","Mapping absent.",DOMAIN,0,"",mapping)
	if matches.size() != 1: return Formats.fail("ambiguous","Mapping ambiguous.",DOMAIN,0,"",mapping)
	var parts: PackedStringArray = str(matches[0]).split("#")
	return lookup(registry,parts[0],parts[1])

static func children(registry: RefCounted, path: String, id: String) -> Dictionary:
	var record := lookup(registry,path,id)
	if not record.ok: return record
	if record.record.value.kind != "faction": return Formats.fail("unsupported","Children require faction metadata.",path,0,id)
	var index: Dictionary = registry.domain_index(DOMAIN)
	if not index.ok: return index
	return {"ok":true,"children":index.children.get(path+"#"+id,[]).duplicate(true),"semantic_ready":false}

static func table_row(registry: RefCounted, path: String, id: String, key: String) -> Dictionary:
	var record := lookup(registry,path,id)
	if not record.ok: return record
	if record.record.value.kind != "table": return Formats.fail("unsupported","Primary-key row access requires a shared table.",path,0,id,key)
	var data: Dictionary = record.record.value.data
	if not data.index.has(key): return Formats.fail("missing","Table primary key absent; non-primary aliases never choose identity.",path,0,id,key)
	return {"ok":true,"row":data.rows[int(data.index[key])].duplicate(true),"semantic_ready":false,"source":record.record.winner.duplicate(true)}

static func validation_fields(record: Dictionary) -> Array:
	var result: Array = ["parent","allies","enemies","flats"] if record.kind == "faction" else ["grammar","commands","references"]
	if record.kind == "faction":
		for field: String in record.data.metadata: result.append("metadata."+field)
		for field: String in record.data.defaults: result.append("defaults."+field)
	result.sort()
	return result

static func validate_handoff(record: Dictionary, provider := Callable(), resources: Dictionary = {}) -> Dictionary:
	# Trusted controlled provider only; no package callback registration or execution.
	# Whole-text coverage is compulsory: no reduced successful script is accepted.
	var structural_reason: String = new().validate_record("handoff",record)
	if not structural_reason.is_empty(): return Formats.fail("malformed",structural_reason).merged({"semantic_ready":false})
	if not provider.is_valid(): return Formats.fail("semantic_unavailable","Required real owner unavailable.").merged({"semantic_ready":false})
	var request := {"schema":"faction-quest-validation-v1","record":record.duplicate(true),"scope":"static","runtime_binding":"deferred","required_checks":validation_fields(record)}
	var response: Variant = provider.call(request.duplicate(true))
	if not response is Dictionary or not response.get("ok",false): return Formats.fail("unsupported","Owner rejected required interpretation.").merged({"owner_result":response,"semantic_ready":false,"interface_only":true})
	if response.get("static_valid") != true or not response.get("runtime_checks") is Array or not response.get("unsupported") is Array or not response.unsupported.is_empty(): return Formats.fail("unsupported","Incomplete validation handoff.").merged({"semantic_ready":false,"interface_only":true})
	if not response.get("checked") is Array or not Common.equal_input(response.checked,request.required_checks) or not response.get("references") is Array: return Formats.fail("unsupported","Every required field/grammar/reference check needs an explicit acknowledgement.").merged({"semantic_ready":false,"interface_only":true})
	var available := catalog(resources)
	for reference in response.references:
		if not reference is Dictionary or not valid_ref(reference.get("target")) or not reference.get("referring") is String or reference.get("kind") not in ["faction","quest","list","table"]: return Formats.fail("unsupported","Malformed static owner reference.").merged({"semantic_ready":false,"interface_only":true})
		var key := target_key(reference.target)
		if not available.has(key) or available[key].value.kind != reference.kind: return Formats.fail("missing","Required static owner reference unresolved.","",0,reference.referring,reference.target).merged({"semantic_ready":false,"interface_only":true})
	if record.kind == "quest":
		var lines := str(record.data.text).replace("\r\n","\n").replace("\r","\n").split("\n")
		if not response.get("lines") is Array or response.lines.size() != lines.size(): return Formats.fail("unsupported","Every source line requires checked disposition.").merged({"semantic_ready":false,"interface_only":true})
		for i in lines.size():
			var item: Variant = response.lines[i]
			if not item is Dictionary or item.get("line") != i+1 or item.get("text") != lines[i] or item.get("disposition") not in ["blank","comment","text","grammar","executable"] or (item.get("disposition") == "executable" and (item.get("supported") != true or not item.get("command") is String or item.command.is_empty())): return Formats.fail("unsupported","Unknown/uncovered required executable line.","",i+1).merged({"semantic_ready":false,"interface_only":true})
	return {"ok":true,"interface_only":true,"semantic_ready":false,"static_valid":true,"runtime_checks":response.runtime_checks.duplicate(true),"result":response.duplicate(true)}
