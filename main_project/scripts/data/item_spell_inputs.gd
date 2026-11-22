extends RefCounted
## Reusable DATA definitions only. ITEM/MAGIC/SAVE semantic gates stay unavailable.
const Formats = preload("res://scripts/data/item_spell_formats.gd")
const Common = preload("res://scripts/data/actor_input_formats.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const DOMAIN = "item-spell.inputs"
const VERSION = "item-spell-inputs-v1"
const ROOT = "res://content/items/"
const ITEM_HASH = "33f4d2703447f4eb8eeabc7b103d8d946115cffaf6490be78578f97db35693a9"
const MAPPING_HASH = "4f6f11b4fe011e2477dc951fe53935bd7db09cf791ed0df8f8a589f75e492725"
const ITEM_INTEGERS = {"index":[0,2147483647],"hitPoints":[0,65535],"capacityOrTarget":[-2147483648,2147483647],"basePrice":[-2147483648,2147483647],"enchantmentPoints":[-32768,32767],"rarity":[0,255],"variants":[0,255],"drawOrderOrEffect":[0,255],"worldTextureArchive":[0,511],"worldTextureRecord":[0,127],"playerTextureArchive":[0,511],"playerTextureRecord":[0,127]}
const ITEM_FLAGS = ["isBluntWeapon","isLiquid","isOneHanded","isIngredient"]
var classic: RefCounted
var _receipts: Dictionary = {}
var _source_mappings: Dictionary = {}
var _source_coordinates: Dictionary = {}

static func sources() -> Array:
	return [{"file":"SPELLS.STD","format":"spells-std-v1"},{"file":"MAGIC.DEF","format":"magic-def-v1"}]

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"operations":["add","replace","patch"],"required_resources":["catalog"],"capabilities":["data."+VERSION],"classic_sources":sources()}

func validate_resource_path(path: String) -> String:
	return "" if path == "catalog" else "Item/spell inputs use catalog."

static func value(kind: String, data: Dictionary, mappings: Array = [], references: Array = []) -> Dictionary:
	return {"schema":VERSION,"kind":kind,"data":data,"mappings":mappings,"references":references}

func bundled_contributions() -> Array:
	_receipts.clear()
	_source_mappings.clear()
	_source_coordinates.clear()
	var entries: Array = []
	var bytes := FileAccess.get_file_as_bytes(ROOT+"dfu-item-templates.json")
	var mapping_bytes := FileAccess.get_file_as_bytes(ROOT+"dfu-item-mappings.json")
	if Common.sha256(bytes) != ITEM_HASH or Common.sha256(mapping_bytes) != MAPPING_HASH:
		return [{"file":"baseline.json","read":Formats.failure("source_unavailable","Pinned DFU packaged baseline/mappings missing or changed.",ROOT)}]
	var items: Array = JSON.parse_string(bytes.get_string_from_utf8())
	var mappings: Dictionary = JSON.parse_string(mapping_bytes.get_string_from_utf8())
	for item: Dictionary in items:
		var data := item.duplicate(true)
		var extensions := {}
		for key in ["isNotRepairable","hasNoEncumbrance"]:
			if data.has(key):
				extensions[key] = data[key]
				data.erase(key)
		data.dfu_extensions = extensions
		var classic_keys: Array = ["template:"+str(int(item.index))]
		for key: String in mappings:
			# DFU Deeds enum is implicit 0/1/2, which aliases gem templates.
			# Retain the evidence table, but do not publish those as deed semantics.
			if key.begins_with("24:"): continue
			if int(mappings[key]) == int(item.index): classic_keys.append("group:"+key)
		var entry := value("item",data,classic_keys)
		entry.input = {"source":ROOT+"dfu-item-templates.json","sha256":ITEM_HASH,"format":"dfu-packaged-items-v1","record":int(item.index),"mapping_sha256":MAPPING_HASH}
		entries.append({"id":"dfu-item-%03d" % int(item.index),"value":entry})
	for source: Dictionary in sources():
		var read: Dictionary = classic.read_record(source.file,"@all") if classic != null else Formats.failure("source_unavailable","Classic registry unavailable.",source.file)
		if not read.ok: return [{"file":"baseline.json","read":read}]
		# Profile ordinals are assigned IDs only for this fingerprinted source edition.
		# Unknown editions remain available through the structural reader, never guessed.
		if read.sha256 != Formats.PROFILES[source.format]: return [{"file":"baseline.json","read":Formats.failure("unsupported","Source identity profile is not registered; raw records remain readable.",read.source)}]
		for address: String in read.records:
			var data: Dictionary = read.records[address].duplicate(true)
			var kind: String = data.kind
			data.erase("kind")
			var id := ("classic-spell-" if kind == "spell_source" else "classic-magic-") + "%03d" % int(address)
			var keys: Array = ["spell:"+str(int(data.legacy_index))] if kind == "spell_source" else ["magic-offset:"+str(int(data.source_record.offset)),"magic-ordinal:"+address]
			var references: Array = []
			if kind == "magic_item_source":
				var pair := "%d:%d" % [int(data.group),int(data.group_index)]
				if not mappings.has(pair): return [{"file":"baseline.json","read":Formats.failure("unsupported","Missing explicit base-item mapping: "+pair,read.source,address)}]
				references.append({"id":"dfu-item-%03d" % int(mappings[pair]),"kind":"item"})
			var entry := value(kind,data,keys,references)
			entry.input = {"source":read.source,"sha256":read.sha256,"record":address,"format":source.format,"profile":"selected-installation-2026-11-21-v1"}
			entries.append({"id":id,"value":entry})
	for entry: Dictionary in entries:
		_receipts[entry.id] = entry.value.input.duplicate(true)
		_source_mappings[entry.id] = entry.value.mappings.duplicate(true)
		if entry.value.data.has("source_record"): _source_coordinates[entry.id] = entry.value.data.source_record.duplicate(true)
	return [{"file":"baseline.json","version":VERSION,"root":"classic-and-dfu-packaged://explicit-profile","bytes":JSON.stringify({"domain":DOMAIN,"path":"catalog","operation":"add","entries":entries}).to_utf8_buffer()}]

func validate_source_record(id: String, record: Dictionary, _fields: Dictionary, _path: String, source: Dictionary, _identity: Dictionary) -> Dictionary:
	if record.has("input") and (not _receipts.has(id) or not Common.equal_input(record.input,_receipts[id])): return Formats.failure("malformed","Unverified item/spell source receipt.",JSON.stringify(source),id)
	if _receipts.has(id) and not Common.equal_input(record.get("input"),_receipts[id]): return Formats.failure("malformed","Replacement must retain baseline receipt.",JSON.stringify(source),id)
	if _source_mappings.has(id) and not Common.equal_input(record.mappings,_source_mappings[id]): return Formats.failure("malformed","Replacement must preserve explicit baseline mappings.",JSON.stringify(source),id)
	if _receipts.has(id):
		var kind: String = {"dfu-packaged-items-v1":"item","spells-std-v1":"spell_source","magic-def-v1":"magic_item_source"}[_receipts[id].format]
		if record.kind != kind: return Formats.failure("malformed","Replacement must preserve the source definition kind.",JSON.stringify(source),id)
		if kind == "item" and record.data.index != _receipts[id].record: return Formats.failure("malformed","Packaged source index is immutable; additions use independent keys.",JSON.stringify(source),id)
		if kind == "spell_source" and not record.mappings.has("spell:"+str(int(record.data.legacy_index))): return Formats.failure("malformed","Source legacy index disagrees with immutable mapping.",JSON.stringify(source),id)
		if _source_coordinates.has(id) and not Common.equal_input(record.data.source_record,_source_coordinates[id]): return Formats.failure("malformed","Original source coordinates/hash must be retained.",JSON.stringify(source),id)
	return {"ok":true}

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var result := previous.duplicate(true)
	for field: String in fields:
		if field in ["schema","kind","mappings","input"] and not Common.equal_input(fields[field],previous.get(field)): return {"ok":false,"reason":"Patch cannot change source or classic identity."}
		result[field] = fields[field]
	return {"ok":true,"value":result}

static func byte_array(data: Variant, count: int) -> bool:
	if not data is Array or data.size() != count: return false
	for number in data:
		if not Common.integer(number,0,255): return false
	return true

func validate_record(_id: String, record: Dictionary) -> String:
	if record.get("schema") != VERSION or record.get("kind") not in ["item","spell_source","magic_item_source"]: return "Unsupported item/spell schema/kind."
	for key: String in record:
		if key not in ["schema","kind","data","mappings","references","input","unused","behavior","spell_contexts"]: return "Unsupported required field: "+key
	if not record.get("data") is Dictionary or not record.get("references") is Array or not record.get("mappings") is Array: return "Typed data, references and mappings required."
	if record.has("unused") and not record.unused is Dictionary: return "Unused metadata must be an object."
	if record.has("input") and not record.input is Dictionary: return "Input receipt must be an object."
	if record.has("behavior") and not Paths.valid_id(record.behavior): return "Behavior needs a stable provider key."
	if record.has("spell_contexts"):
		if record.kind != "magic_item_source" or not record.spell_contexts is Dictionary: return "Spell contexts belong to magic-item enchantment slots."
		for slot: String in record.spell_contexts:
			if not slot.is_valid_int() or str(int(slot)) != slot or int(slot) < 0 or int(slot) > 9 or not Paths.valid_id(record.spell_contexts[slot]): return "Context requires canonical slot and stable spell definition key."
	var seen := {}
	for mapping in record.mappings:
		if not mapping is String or mapping.is_empty() or seen.has(mapping): return "Invalid/duplicate explicit mapping."
		seen[mapping] = true
	for reference in record.references:
		if not reference is Dictionary or reference.get("kind") not in ["item","spell_source","magic_item_source"] or reference.size() != 2: return "Required typed reference needs kind and exactly one id/mapping."
		if reference.has("id"):
			if not Paths.valid_id(reference.id): return "Invalid stable reference key."
		elif not reference.get("mapping") is String: return "Missing reference target."
	var data: Dictionary = record.data
	if record.kind == "item":
		var allowed: Array = ["name","baseWeight","dfu_extensions"] + ITEM_INTEGERS.keys() + ITEM_FLAGS
		for key: String in data:
			if key not in allowed: return "Unknown required item field: "+key
		if not data.get("name") is String or not data.get("baseWeight") is float and not data.get("baseWeight") is int: return "Item requires name and kilogram weight."
		if not is_finite(float(data.baseWeight)) or float(data.baseWeight) < 0: return "Invalid kilogram weight."
		for field: String in ITEM_INTEGERS:
			if not Common.integer(data.get(field),ITEM_INTEGERS[field][0],ITEM_INTEGERS[field][1]): return "Invalid item integer: "+field
		for field: String in ITEM_FLAGS:
			if not data.get(field) is bool: return "Item flags must be explicit booleans."
		if not data.get("dfu_extensions") is Dictionary: return "Explicit DFU extension container required."
		for key: String in data.dfu_extensions:
			if key not in ["isNotRepairable","hasNoEncumbrance"] or not data.dfu_extensions[key] is bool: return "Unknown DFU extension."
		return ""
	var expected := ["name","name_storage","legacy_index","icon","element","range","cost","effects","unused","source_record"] if record.kind == "spell_source" else ["name","name_storage","type","group","group_index","enchantments","uses","value","material","source_record"]
	if data.size() != expected.size(): return "Missing or unknown required source fields."
	for key: String in data:
		if key not in expected: return "Unknown required source field: "+key
	if not data.get("name") is String or not byte_array(data.get("name_storage"),25 if record.kind == "spell_source" else 32): return "Invalid source name/storage."
	if not data.get("source_record") is Dictionary: return "Source coordinate/receipt required."
	if data.source_record.size() != 3 or not Common.integer(data.source_record.get("ordinal"),0,2147483647) or not Common.integer(data.source_record.get("offset"),0,16777216) or not data.source_record.get("sha256") is String or data.source_record.sha256.length() != 64 or not data.source_record.sha256.is_valid_hex_number(false): return "Malformed source coordinate/receipt."
	if record.kind == "spell_source":
		for field in ["legacy_index","icon","element","range","cost"]:
			if not Common.integer(data.get(field),0,65535 if field == "cost" else 255): return "Invalid spell field: "+field
		if not data.get("effects") is Array: return "Effects must be an array."
		# Three slots belong to the classic transport, not an added-definition limit.
		for effect in data.effects:
			if not effect is Dictionary or effect.size() != 5 or not Common.integer(effect.get("type"),-128,127) or not Common.integer(effect.get("subtype"),-128,127): return "Malformed effect type/subtype."
			for pair in [["duration",3],["chance",3],["magnitude",5]]:
				if not byte_array(effect.get(pair[0]),pair[1]): return "Malformed effect parameters: "+pair[0]
		if not data.get("unused") is Dictionary or data.unused.size() != 2 or not byte_array(data.unused.get("gap4"),4) or not byte_array(data.unused.get("gap15"),15): return "Missing format-defined unused bytes."
	else:
		for field in ["type","group","group_index","material","uses","value"]:
			var low := -32768 if field == "uses" else -2147483648 if field == "value" else 0
			var high := 32767 if field == "uses" else 2147483647 if field == "value" else 255
			if not Common.integer(data.get(field),low,high): return "Invalid magic item field: "+field
		if not data.get("enchantments") is Array or data.enchantments.size() != 10: return "Classic magic item needs ten retained slots."
		for enchantment in data.enchantments:
			if not enchantment is Dictionary or enchantment.size() != 2 or not Common.integer(enchantment.get("type"),-128,127) or not Common.integer(enchantment.get("parameter"),-128,127): return "Malformed legacy enchantment."
	return ""

func validate_references(resources: Dictionary) -> Array:
	var records: Dictionary = resources.get(DOMAIN+":catalog",{}).get("records",{})
	var issues: Array = []
	var mappings := {}
	if records.is_empty(): issues.append({"source":DOMAIN+":catalog","target":"baseline","reason":"Required item/spell catalog is empty."})
	for id: String in records:
		for mapping: String in records[id].value.mappings:
			var key: String = records[id].value.kind+":"+mapping
			if not mappings.has(key): mappings[key] = []
			mappings[key].append(id)
	for key: String in mappings:
		if mappings[key].size() > 1 and not key.begins_with("spell_source:"):
			issues.append({"source":DOMAIN+":catalog","target":key,"reason":"Ambiguous item/magic mapping.","candidates":mappings[key]})
	for id: String in records:
		var record: Dictionary = records[id]
		# Declared references cannot strip dependencies encoded by source fields.
		if record.value.kind == "magic_item_source":
			var base_targets: Array = mappings.get("item:group:%d:%d" % [int(record.value.data.group),int(record.value.data.group_index)],[])
			if base_targets.size() != 1:
				issues.append({"source":DOMAIN+":catalog#"+id,"target":"base-item:%d:%d" % [int(record.value.data.group),int(record.value.data.group_index)],"provider":record.winner,"reason":"Required base item mapping missing/ambiguous."})
			for slot in record.value.data.enchantments.size():
				var enchantment: Dictionary = record.value.data.enchantments[slot]
				if int(enchantment.type) in [0,1,2]:
					var target := "spell_source:spell:"+str(int(enchantment.parameter))
					var targets: Array = mappings.get(target,[])
					var context: String = record.value.get("spell_contexts",{}).get(str(slot),"")
					if not context.is_empty(): targets = [context] if targets.has(context) else []
					if targets.size() != 1:
						issues.append({"source":DOMAIN+":catalog#"+id,"effect":slot,"target":target,"provider":record.winner,"reason":"Required spell reference missing/ambiguous; an explicit contextual reference is required."})
		for reference: Dictionary in record.value.references:
			var targets: Array = [reference.id] if reference.has("id") else mappings.get(reference.kind+":"+reference.mapping,[])
			if targets.size() != 1 or not records.has(targets[0]) or records[targets[0]].value.kind != reference.kind:
				issues.append({"source":DOMAIN+":catalog#"+id,"target":reference,"provider":record.winner,"reason":"Missing or ambiguous required typed reference.","candidates":targets})
		if record.value.has("behavior"): issues.append({"source":DOMAIN+":catalog#"+id,"target":record.value.behavior,"provider":record.winner,"reason":"Required ITEM special-behavior provider unavailable."})
	return issues

static func lookup(registry: RefCounted, id: String, use := "structural") -> Dictionary:
	var result: Dictionary = registry.query(DOMAIN,"catalog",id)
	if not result.ok:
		result.referring = DOMAIN+":catalog#"+id
		result.target = id
		return result
	result.structural_available = true
	result.semantic_ready = false
	result.required_owners = ["ITEM IMP-017","MAGIC IMP-033","SAVE compatibility"]
	if use != "structural":
		return {"ok":false,"kind":"semantic_unavailable","reason":"Real ITEM/MAGIC validation is unavailable.","referring":result.record.identity,"target":use,"provider":result.record.winner,"structural_available":true,"semantic_ready":false,"required_owners":result.required_owners}
	return result

static func lookup_classic(registry: RefCounted, kind: String, mapping: String, context := "") -> Dictionary:
	var active: Dictionary = registry.active()
	if active.is_empty(): return Formats.failure("before_readiness","Menu publication required.")
	var matches: Array = []
	for id: String in active.resources.get(DOMAIN+":catalog",{}).get("records",{}):
		var record: Dictionary = active.resources[DOMAIN+":catalog"].records[id]
		if record.value.kind == kind and record.value.mappings.has(mapping) and (context.is_empty() or context == id): matches.append(id)
	if matches.is_empty(): return Formats.failure("record_not_found","Classic mapping/context absent.",kind,mapping)
	if matches.size() != 1:
		var issue := Formats.failure("ambiguous_mapping","Explicit stable source-record context required.",kind,mapping)
		issue.candidates = matches
		return issue
	return lookup(registry,matches[0])

static func convert_spell(record: Dictionary, owner: Callable = Callable()) -> Dictionary:
	# A checked owner projection is an interface probe, never production readiness.
	if not owner.is_valid(): return Formats.failure("semantic_unavailable","MAGIC conversion owner unavailable.",JSON.stringify(record.get("input",{})))
	var reason := new().validate_record("conversion",record)
	if not reason.is_empty() or record.get("kind") != "spell_source": return Formats.failure("malformed","Invalid spell conversion input: "+reason)
	var results: Array = []
	var data: Dictionary = record.get("data",{})
	if not data.get("effects") is Array: return Formats.failure("malformed","Typed spell effects required.")
	var context_result: Variant = owner.call("context",data.duplicate(true))
	if not context_result is Dictionary: return Formats.failure("unsupported","MAGIC owner returned an invalid context projection.")
	var context: Dictionary = context_result
	if context.get("ok") != true:
		var rejected := context.duplicate(true)
		rejected.ok = false
		rejected.kind = context.get("kind","unsupported")
		rejected.reason = context.get("reason","Required MAGIC context interpretation failed.")
		rejected.source = record.get("input",{}).duplicate(true)
		return rejected
	if not context.get("value") is Dictionary or context.value.is_empty(): return Formats.failure("unsupported","MAGIC context owner returned no checked settings.",JSON.stringify(record.get("input",{})))
	for slot in data.effects.size():
		var effect: Dictionary = data.effects[slot]
		if effect.type == -1: continue
		var response: Variant = owner.call("effect",effect.duplicate(true))
		if not response is Dictionary: return Formats.failure("unsupported","MAGIC owner returned an invalid effect projection.","",slot)
		var converted: Dictionary = response
		if converted.get("ok") != true:
			return {"ok":false,"kind":converted.get("kind","unsupported"),"effect":slot,"target":effect.duplicate(true),"source":record.get("input",{}).duplicate(true),"reason":converted.get("reason","Required active effect rejected."),"semantic_ready":false}
		if not converted.get("value") is Dictionary or converted.value.is_empty(): return Formats.failure("unsupported","MAGIC effect owner returned no checked settings.",JSON.stringify(record.get("input",{})),slot)
		results.append(converted.duplicate(true))
	if results.is_empty(): return Formats.failure("unsupported","Empty spell legality requires MAGIC policy.")
	return {"ok":true,"effects":results,"context":context.duplicate(true),"source":record.duplicate(true),"semantic_ready":false,"interface_only":true}

static func conditional_correction(record: Dictionary, rule: Dictionary) -> Dictionary:
	# No production correction registry is enabled. Trusted callers supply rules;
	# packages cannot add approvals. Match complete expected data before replacing.
	var result := record.duplicate(true)
	if rule.get("approved") != true or not rule.get("approval") is String or rule.approval.is_empty(): return {"ok":false,"kind":"unsupported","reason":"Explicit individual approval required."}
	if not Paths.valid_id(rule.get("id")) or not rule.get("expected") is Dictionary or not rule.get("replacement") is Dictionary: return Formats.failure("malformed","Correction requires stable rule ID and complete expected/replacement data.")
	if not Common.equal_input(record.get("data"),rule.get("expected")): return {"ok":true,"value":result,"applied":false}
	result.data = rule.replacement.duplicate(true)
	return {"ok":true,"value":result,"applied":true,"annotation":{"rule":rule.id,"approval":rule.approval,"original":record.data.duplicate(true)}}

static func artifacts(registry: RefCounted) -> Dictionary:
	var active: Dictionary = registry.active()
	if active.is_empty(): return Formats.failure("before_readiness","Menu publication required.")
	var result: Array = []
	for record: Dictionary in active.resources.get(DOMAIN+":catalog",{}).get("records",{}).values():
		if record.value.kind == "magic_item_source" and int(record.value.data.type) in [1,2]: result.append(record.duplicate(true))
	return {"ok":true,"records":result,"semantic_ready":false}

static func validate_magic_interpretation(record: Dictionary, owner: Callable = Callable()) -> Dictionary:
	# Structural publication retains source material/enchantment values. This
	# separate, pure owner boundary must validate every required interpretation.
	var reason := new().validate_record("magic-interpretation",record)
	if not reason.is_empty() or record.get("kind") != "magic_item_source": return Formats.failure("malformed","Invalid magic-item input: "+reason)
	if not owner.is_valid(): return Formats.failure("semantic_unavailable","ITEM material and MAGIC enchantment owners unavailable.",JSON.stringify(record.get("input",{})))
	var requests: Array = [{"stage":"material","value":record.data.material},{"stage":"magic_type","value":record.data.type}]
	for slot in record.data.enchantments.size():
		if record.data.enchantments[slot].type != -1: requests.append({"stage":"enchantment","slot":slot,"value":record.data.enchantments[slot].duplicate(true)})
	if record.has("behavior"): requests.append({"stage":"behavior","value":record.behavior})
	for request: Dictionary in requests:
		var response: Variant = owner.call(request.duplicate(true))
		if not response is Dictionary or response.get("ok") != true:
			return {"ok":false,"kind":response.get("kind","unsupported") if response is Dictionary else "unsupported","reason":"Required owner interpretation failed.","reference":request,"source":record.get("input",{}).duplicate(true),"semantic_ready":false}
	return {"ok":true,"interface_only":true,"semantic_ready":false}
