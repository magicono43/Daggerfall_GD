extends RefCounted
## One structural catalog. Registry/CORE own publication; CHAR/NPC own semantics.
const Formats = preload("res://scripts/data/actor_input_formats.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const DOMAIN = "actor.inputs"
const VERSION = "actor-inputs-v1"
const RESOURCE = "catalog"
var classic: RefCounted
var _source_receipts: Dictionary = {}
var _conflict_receipts: Dictionary = {}
var _correction_receipts: Dictionary = {}

static func sources() -> Array:
	var result: Array = [{"file":"FLATS.CFG","format":"flats-cfg-v1"},{"file":"MONSTER.BSA","format":"bsa-v1"},{"file":"PAINT.DAT","format":"paint-dat-v1"},{"file":"BIO.DAT","format":"bio-dat-v1"}]
	# Predefined class consumers use 00..17. CLASS18 is a City Watch source, not a playable class.
	for i in 18: result.append({"file":"CLASS%02d.CFG" % i,"format":"career-cfg-v1"})
	result.append({"file":"CLASS18.CFG","format":"career-source-v1"})
	for i in 18: result.append({"file":"BIOG%02dT0.TXT" % i,"format":"biog-text-v1"})
	return result

func declaration() -> Dictionary:
	return {"id":"actor-inputs-v1","domain":DOMAIN,"operations":["add","replace","patch"],"required_resources":[RESOURCE],"capabilities":["data.actor-inputs-v1"],"classic_sources":sources()}

func validate_resource_path(path: String) -> String:
	return "" if path == RESOURCE else "Actor inputs use the single catalog resource."

func bundled_contributions() -> Array:
	# Bytes originate exclusively from active declared classic readers. This hook
	# runs at the shipped tier before packages, never opens an arbitrary disk path.
	_source_receipts.clear()
	_conflict_receipts.clear()
	_correction_receipts.clear()
	var entries: Array = []
	for source: Dictionary in sources():
		if source.file == "MONSTER.BSA": continue
		var read: Dictionary = classic.read_record(source.file,"@all") if classic != null else Formats.failure("source_unavailable","No classic source registry.",source.file)
		if not read.ok: return [{"file":"baseline.json","read":read}]
		for address: String in read.records:
			var data: Dictionary = read.records[address].duplicate(true)
			var kind: String = data.kind
			var id := kind + "-" + address
			if kind == "flat_conflict": id = "flat-" + address
			var mapping: String = str(data.get("classic",address))
			if source.format == "career-cfg-v1":
				kind = "class"
				mapping = source.file.substr(5,2)
				id = "class-" + mapping
			elif source.format == "career-source-v1":
				mapping = source.file.substr(5,2)
				id = "career-source-" + mapping
			elif source.format == "biog-text-v1":
				mapping = source.file.get_basename().to_lower()
				id = mapping
			data.erase("kind")
			data.erase("classic")
			var references: Array = []
			if kind == "biography": references.append({"id":"class-" + source.file.substr(4,2),"kind":"class"})
			if kind == "class" and int(mapping) < 18: references.append({"id":"biog%02dt0" % int(mapping),"kind":"biography"})
			entries.append({"id":id,"value":{"schema":VERSION,"kind":kind,"classic":mapping,"data":data,"references":references,"input":{"source":read.source,"address":address,"format":source.format,"sha256":read.sha256,"transport":"selected-arena2"}}})
	# Enumerate physical names through the existing checked BSA index. Unknown ANC
	# records remain raw and explicitly unsupported for required interpretation.
	var count := 0
	if classic != null:
		for item: Dictionary in classic.inventory():
			if str(item.source).get_file().to_upper() == "MONSTER.BSA": count = item.count
	var seen := {}
	for ordinal in count:
		var read: Dictionary = classic.read_record("MONSTER.BSA",{"ordinal":ordinal})
		if not read.ok: return [{"file":"baseline.json","read":read}]
		if not read.identity is String: return [{"file":"baseline.json","read":Formats.failure("unsupported","MONSTER career profile requires a named BSA directory.",read.source,ordinal)}]
		var name: String = read.identity
		if not name.begins_with("ENEMY") or not name.ends_with(".CFG"): continue
		var suffix := name.substr(5,3)
		if name.length() != 12 or not suffix.is_valid_int() or seen.has(suffix): return [{"file":"baseline.json","read":Formats.failure("malformed","Invalid/duplicate monster career mapping.",read.source,name)}]
		seen[suffix] = true
		# Monster careers are source metadata, not validated player skill selections.
		var decoded := Formats.decode("career-source-v1",read.bytes,read.source)
		if not decoded.ok: return [{"file":"baseline.json","read":decoded}]
		var data: Dictionary = decoded.records.career
		data.erase("kind")
		entries.append({"id":"enemy-" + suffix,"value":{"schema":VERSION,"kind":"encounter_career","classic":suffix,"data":data,"references":[],"input":{"source":read.source,"address":name,"ordinal":ordinal,"offset":read.offset,"format":"career-source-v1","sha256":Formats.sha256(read.bytes),"transport":"selected-arena2-bsa"}}})
	for entry: Dictionary in entries:
		_source_receipts[entry.id] = entry.value.input.duplicate(true)
		if entry.value.kind == "flat_conflict": _conflict_receipts[entry.id] = entry.value.data.duplicate(true)
		if entry.value.kind == "biography": _correction_receipts[entry.id] = entry.value.data.source_annotations.duplicate(true)
	return [{"file":"profile.json","version":VERSION,"root":"res://content/actors","bytes":FileAccess.get_file_as_bytes("res://content/actors/profile.json")},{"file":"baseline.json","version":VERSION,"root":"classic://selected","bytes":JSON.stringify({"domain":DOMAIN,"path":RESOURCE,"operation":"add","entries":entries}).to_utf8_buffer()}]

func validate_source_record(id: String, value: Dictionary, _fields: Dictionary, _path: String, source: Dictionary, _identity: Dictionary) -> Dictionary:
	# Authors may retain a verified baseline receipt, never invent a classic origin.
	if value.has("input") and (not _source_receipts.has(id) or not Formats.equal_input(value.input,_source_receipts[id])):
		return Formats.failure("malformed","Unverified classic source provenance for " + id,JSON.stringify(source),id)
	if _source_receipts.has(id) and not value.has("input"):
		return Formats.failure("malformed","Replacement must retain its baseline source receipt for " + id,JSON.stringify(source),id)
	if value.kind == "flat_conflict" and (not _conflict_receipts.has(id) or not Formats.equal_input(value.data,_conflict_receipts[id])):
		return Formats.failure("malformed","Conflict diagnostics must retain the verified source alternatives.",JSON.stringify(source),id)
	if value.kind == "biography":
		var annotations: Array = value.data.get("source_annotations",[])
		if not annotations.is_empty() and not _correction_receipts.has(id): return Formats.failure("malformed","Unverified BIOG correction provenance.",JSON.stringify(source),id)
		if _correction_receipts.has(id) and not Formats.equal_input(annotations,_correction_receipts[id]): return Formats.failure("malformed","Biography must retain its original source-correction receipt.",JSON.stringify(source),id)
	return {"ok":true}

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	for field: String in fields:
		if field in ["schema","kind","classic","input"] and fields[field] != previous.get(field): return {"ok":false,"reason":"Schema/kind/classic/source identity cannot be patched."}
		value[field] = fields[field] # Whole top-level object/list replacement.
	return {"ok":true,"value":value}

func validate_record(_id: String, value: Dictionary) -> String:
	if value.get("schema") != VERSION or value.get("kind") not in ["profile","flat","flat_conflict","class","career_source","encounter_career","painting","narrative","biography","actor","appearance"]: return "Expected actor-inputs-v1 and supported kind."
	for key: String in value:
		if key not in ["schema","kind","classic","data","references","input","unused"]: return "Unsupported required field: " + key
	if not value.get("data") is Dictionary or not value.get("references") is Array: return "Typed data and explicit references are required."
	if value.has("classic") and not value.classic is String: return "Classic mapping must be an explicit string."
	if value.has("classic"):
		var mapping: String = value.classic
		if value.kind in ["class","career_source","encounter_career","painting","narrative"]:
			if not mapping.is_valid_int() or not Formats.integer(int(mapping),0,2147483647): return "Invalid classic numeric mapping."
			var canonical := "%02d" % int(mapping) if value.kind in ["class","career_source"] else "%03d" % int(mapping) if value.kind == "encounter_career" else str(int(mapping))
			if mapping != canonical: return "Noncanonical/ambiguous classic numeric mapping."
		elif value.kind == "biography":
			var parts := mapping.trim_prefix("biog").split("t")
			if not mapping.begins_with("biog") or parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int(): return "Invalid classic biography mapping."
			if not Formats.integer(int(parts[0]),0,2147483647) or not Formats.integer(int(parts[1]),0,2147483647) or mapping != "biog%02dt%d" % [int(parts[0]),int(parts[1])]: return "Noncanonical classic biography mapping."
		elif value.kind not in ["flat","flat_conflict"]: return "No classic mapping adapter is defined for this kind."
	if value.has("input") and not value.input is Dictionary: return "Input provenance must be an object."
	if value.has("unused") and not value.unused is Dictionary: return "Unknown unused metadata must be contained in unused."
	for reference in value.references:
		if not reference is Dictionary or reference.keys().size() != 2 or not Paths.valid_id(reference.get("id")) or not reference.get("kind") is String: return "Reference needs stable id and required kind."
	var data: Dictionary = value.data
	var allowed: Array = {"profile":["formats","semantic_ready"],"flat_conflict":[],"flat":["archive","record","caption","gender_source","unknown2","unknown3","face_index"],"class":["name","flags","skills","unknown1","unknown2","name_storage","hit_points_per_level","advancement_fixed_16_16","attributes"],"encounter_career":["name","flags","skills","unknown1","unknown2","name_storage","hit_points_per_level","advancement_fixed_16_16","attributes"],"painting":["bytes"],"narrative":["text"],"biography":["questions","backstory_text_id","source_annotations"],"actor":["appearance","career"],"appearance":["resource"]}["class" if value.kind == "career_source" else value.kind]
	if value.kind == "flat_conflict": allowed = ["profile","alternatives","source_blocks"]
	for field: String in data:
		if field not in allowed: return "Unsupported required data field: " + field
	match value.kind:
		"flat_conflict":
			if not Formats.FLAT_CONFLICTS.has(value.get("classic")) or data.get("profile") != Formats.FLAT_CONFLICT_PROFILE or not data.get("alternatives") is Array or not Formats.known_flat_conflict(data.alternatives): return "Unsupported flat conflict exception."
			if not data.get("source_blocks") is Array or data.source_blocks.size() != data.alternatives.size(): return "Conflict needs both physical source block addresses."
			var seen_blocks := {}
			for block in data.source_blocks:
				if not Formats.integer(block,0,2147483647): return "Invalid conflict source block address."
				if seen_blocks.has(block): return "Conflict source blocks must be distinct."
				seen_blocks[block] = true
		"profile":
			if data != {"formats":Formats.FORMATS,"semantic_ready":false}: return "Unsupported format profile or semantic readiness claim."
		"flat":
			if not Formats.integer(data.get("archive"),0,16777215) or not Formats.integer(data.get("record"),0,127): return "Flat address is outside classic packing; use appearance/actor for added content."
			if not data.get("caption") is String or not data.get("gender_source") is String: return "Flat caption/gender source must be strings."
			for field in ["unknown2","unknown3","face_index"]:
				if not Formats.integer(data.get(field),-2147483648,2147483647): return "Invalid flat integer " + field
			if value.get("classic") != str((int(data.archive) << 7) + int(data.record)): return "Flat mapping does not match source pair."
		"class", "career_source", "encounter_career":
			if not data.get("name") is String or not data.get("flags") is Dictionary or not data.get("skills") is Dictionary: return "Career requires name, flags and skill groups."
			if data.flags.size() != 11 or data.skills.size() != 3: return "Unknown required career flag/skill group."
			for field: String in ["resistance","immunity","low_tolerance","critical_weakness","ability_spell_points","rapid_healing","regeneration","spell_absorption","attack_modifier","forbidden_materials","weapon_armor_shields"]:
				var maximum := 16777215 if field == "weapon_armor_shields" else 65535 if field in ["ability_spell_points","forbidden_materials"] else 255
				if not Formats.integer(data.flags.get(field),0,maximum): return "Career flag missing/out of range: " + field
			for group: String in ["primary","major","minor"]:
				if not data.skills.get(group) is Array or data.skills[group].size() != (6 if group == "minor" else 3): return "Invalid career skill group."
				for skill in data.skills[group]:
					if not Formats.integer(skill,0,34 if value.kind == "class" else 255): return "Unsupported career skill."
			if not Formats.integer(data.get("hit_points_per_level"),0,65535) or not Formats.integer(data.get("advancement_fixed_16_16"),0,4294967295) or not Formats.integer(data.get("unknown1"),0,255): return "Invalid career numeric field."
			for field in ["attributes","unknown2","name_storage"]:
				var size := 16 if field == "name_storage" else 8
				if not data.get(field) is Array or data[field].size() != size: return "Invalid career array " + field
				for number in data[field]:
					if not Formats.integer(number,0,65535 if field == "attributes" else 255): return "Career array value out of range."
		"painting":
			if not data.get("bytes") is Array or data.bytes.size() != 40: return "Painting needs 40 uninterpreted source bytes."
			for byte in data.bytes:
				if not Formats.integer(byte,0,255): return "Invalid painting byte."
		"narrative":
			if not data.get("text") is String: return "Narrative requires literal text."
		"biography": return validate_biography(data,_id)
		"appearance":
			if not data.get("resource") is String or data.resource.is_empty(): return "Appearance needs an explicit resource reference."
		"actor":
			if not data.get("appearance") is String or not data.get("career") is String: return "Actor requires separate appearance/career identities."
			for pair in [[data.appearance,"appearance"],[data.career,"class"]]:
				if not value.references.has({"id":pair[0],"kind":pair[1]}): return "Actor link must declare its required typed reference."
	return ""

func validate_biography(data: Dictionary, id: String) -> String:
	if not data.get("source_annotations",[]) is Array: return "Biography source annotations must be an array."
	for annotation in data.get("source_annotations",[]):
		if not annotation is Dictionary or annotation.size() != 6 or annotation.get("profile") != Formats.BIOG_CORRECTION_PROFILE or not Formats.BIOG_AMPERSAND_QUESTIONS.has(annotation.get("source_file")) or annotation.get("question") != Formats.BIOG_AMPERSAND_QUESTIONS[annotation.source_file] or annotation.get("answer") != "c" or not annotation.get("raw_text") is String or annotation.raw_text.strip_edges() != "&" or not Formats.integer(annotation.get("line"),1,2147483647): return "Unsupported source-correction annotation."
	if not data.get("questions") is Array or data.questions.is_empty(): return "Biography requires stable questions."
	if data.get("backstory_text_id") != null and not Formats.integer(data.backstory_text_id,0,65535): return "Invalid explicit narrative reference."
	var questions := {}
	for q in data.questions:
		if not q is Dictionary or q.size() != 3 or not Paths.valid_id(q.get("id")) or questions.has(q.id) or not q.get("text") is String or not q.get("answers") is Array or q.answers.is_empty(): return "Invalid/duplicate question identity or fields."
		questions[q.id] = true
		var answers := {}
		for a in q.answers:
			if not a is Dictionary or a.size() != 3 or not Paths.valid_id(a.get("id")) or answers.has(a.id) or not a.get("text") is String or not a.get("effects") is Array: return "Invalid/duplicate answer identity or fields."
			answers[a.id] = true
			for effect in a.effects:
				if not effect is Dictionary or not effect.get("classic_command") is String: return "Typed effect needs checked command mapping."
				var decoded := Formats.effect(effect.classic_command)
				if not decoded.ok: return id + "/" + q.id + "/" + a.id + ": " + decoded.reason
				if not Formats.equal_input(decoded.value,effect): return id + "/" + q.id + "/" + a.id + ": Effect fields disagree with checked command declaration for target " + str(effect.get("target","missing"))
	return ""

func validate_references(resources: Dictionary) -> Array:
	var records: Dictionary = resources.get(DOMAIN + ":" + RESOURCE,{}).get("records",{})
	var issues: Array = []
	var mappings := {}
	if not records.has("format-profile") or records["format-profile"].value.kind != "profile": issues.append({"source":DOMAIN + ":catalog","target":"format-profile","reason":"Required shipped format profile is absent."})
	for id: String in records:
		var record: Dictionary = records[id]
		var value: Dictionary = record.value
		var key := DOMAIN + ":" + RESOURCE + "#" + id
		if value.has("classic"):
			var mapping: String = ("flat" if value.kind == "flat_conflict" else value.kind) + ":" + value.classic
			if mappings.has(mapping): issues.append({"source":key,"target":mapping,"provider":record.winner,"reason":"Ambiguous classic mapping with " + str(mappings[mapping])})
			mappings[mapping] = id
		for reference: Dictionary in value.references:
			if not records.has(reference.id) or records[reference.id].value.kind != reference.kind: issues.append({"source":key,"target":reference.id,"provider":record.winner,"reason":"Missing required typed reference: " + reference.kind + "/" + reference.id})
	return issues

static func lookup(registry: RefCounted, id: String, use := "structural") -> Dictionary:
	var result: Dictionary = registry.query(DOMAIN,RESOURCE,id)
	if not result.ok:
		result.referring = DOMAIN + ":" + RESOURCE + "#" + id
		result.target = id
		return result
	if result.record.value.kind == "flat_conflict":
		return {"ok":false,"kind":"ambiguous_mapping","source":result.record.value.input.source,"referring":result.record.identity,"target":"flat:" + result.record.value.classic,"provider":result.record.winner,"candidates":result.record.value.data.alternatives.duplicate(true),"reason":"Known classic flat source conflict is preserved without a unique mapping."}
	result.structural_available = true
	result.semantic_ready = false
	result.required_owners = ["CHAR/NPC (IMP-015/016)","effect target owners","SAVE compatibility"]
	if result.record.value.kind in ["career_source","encounter_career"]:
		result.source_diagnostics = []
		for group: String in result.record.value.data.skills:
			for slot in result.record.value.data.skills[group].size():
				var skill: int = int(result.record.value.data.skills[group][slot])
				if skill > 34: result.source_diagnostics.append({"kind":"unsupported","field":"skills." + group,"slot":slot,"value":skill,"reason":"Source byte retained; no supported skill interpretation."})
	if use != "structural":
		return {"ok":false,"kind":"semantic_unavailable","referring":result.record.identity,"target":use,"provider":result.record.winner,"reason":"Real owner validation is not delivered; structural lookup cannot authorize gameplay.","structural_available":true,"semantic_ready":false}
	return result

static func lookup_classic(registry: RefCounted, kind: String, mapping: String) -> Dictionary:
	var active: Dictionary = registry.active()
	if active.is_empty(): return Formats.failure("before_readiness","Catalog has not entered menu publication.")
	var found: Array[String] = []
	for id: String in active.resources.get(DOMAIN + ":" + RESOURCE,{}).get("records",{}):
		var value: Dictionary = active.resources[DOMAIN + ":" + RESOURCE].records[id].value
		if (value.kind == kind or (kind == "flat" and value.kind == "flat_conflict")) and value.get("classic") == mapping: found.append(id)
	if found.is_empty(): return Formats.failure("record_not_found","No explicit classic mapping.",kind,mapping)
	if found.size() != 1: return Formats.failure("malformed","Ambiguous classic mapping.",kind,mapping)
	return lookup(registry,found[0])
