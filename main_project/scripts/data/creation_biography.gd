extends RefCounted
## DATA publication for explicit affinity/mappings and isolated biography text.
const DOMAIN = "char.biography"
const VERSION = "creation-biography-v1"
const Typed = preload("res://scripts/char/creation_inputs.gd")
const Formats = preload("res://scripts/data/actor_input_formats.gd")
const Text = preload("res://scripts/data/structured_text.gd")
var classic: RefCounted
var _book_receipts: Dictionary = {}

func validate_source_record(id: String, value: Dictionary, _fields: Dictionary, _path: String, _source: Dictionary, _identity: Dictionary) -> Dictionary:
	if value.get("schema") == "creation-book-metadata-v1" and not Formats.equal_input(value.get("source"),_book_receipts.get(id)): return {"ok":false,"reason":"Book source qualification receipts cannot be authored or changed; unsupported new source providers require their actual reader."}
	return {"ok":true}

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,"actor.inputs","item-spell.inputs","faction-quest.inputs"],"operations":["add","replace","patch"],"required_resources":["policy","texts","books"],"capabilities":["data."+VERSION]}

func validate_resource_path(path: String) -> String:
	return "" if path in ["policy","texts","books"] else "Biography uses policy, texts and book metadata."

func bundled_contributions() -> Array:
	_book_receipts.clear()
	var wanted := {}
	for index in 18:
		wanted[str(4116+index)] = true
		var read: Dictionary = classic.read_record("BIOG%02dT0.TXT" % index,"@all")
		if not read.ok: return [{"file":"biography-texts.json","read":read}]
		for q in read.records.biography.questions:
			for a in q.answers:
				for e in a.effects:
					if e.type == "narrative_token": wanted[str(e.parameters.text_id)] = true
	var entries: Array = []
	for id in wanted:
		var read := Text.read(classic,int(id))
		entries.append({"id":"text-"+id,"value":{"schema":"creation-biography-text-v1","available":read.ok,"text":preload("res://scripts/data/creation_career.gd").literal(read) if read.ok else "","source":{"record":int(id),"source":read.get("source","TEXT.RSC"),"offset":read.get("offset",-1),"reason":read.get("reason","")}}})
	var source_policy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/char/biography.json"))
	var books: Array = []
	for id in source_policy.entries[0].value.books:
		var source: Dictionary = classic.creation_book(int(id))
		var key := "book-"+str(int(id))
		_book_receipts[key] = source.duplicate(true)
		books.append({"id":key,"value":{"schema":"creation-book-metadata-v1","source":source}})
	return [{"root":"res://content/char","file":"biography.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/char/biography.json")},{"root":"classic://selected","file":"biography-texts.json","version":VERSION,"bytes":JSON.stringify({"domain":DOMAIN,"path":"texts","operation":"add","entries":entries}).to_utf8_buffer()},{"root":"classic://selected","file":"biography-books.json","version":VERSION,"bytes":JSON.stringify({"domain":DOMAIN,"path":"books","operation":"add","entries":books}).to_utf8_buffer()}]

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	for key in fields: value[key] = fields[key]
	return {"ok":true,"value":value}

func validate_record(id: String, raw: Dictionary) -> String:
	var value: Dictionary = Typed.exact_numbers(raw)
	if value.get("schema") == "creation-book-metadata-v1": return "" if value.size() == 2 and value.get("source") is Dictionary and value.source.get("ok") is bool else "Explicit book metadata availability required."
	if value.get("schema") == "creation-biography-text-v1":
		return "" if value.size() == 4 and value.get("available") is bool and value.get("text") is String and (not value.text.is_empty() if value.available else value.text.is_empty()) and value.text.length() <= 65536 and value.get("source") is Dictionary else "Explicit biography text availability and provenance required."
	if id != "stock" or value.size() != 12 or value.get("schema") != VERSION or not value.get("order") is Array or not value.get("mappings") is Dictionary or not value.get("narratives") is Dictionary or not value.get("race_contexts") is Dictionary or not value.get("name_banks") is Dictionary or not value.get("books") is Array or value.books.is_empty() or not value.get("items") is Dictionary or not value.get("imperial_names") is Array or value.imperial_names.is_empty() or not value.get("provenance") is Dictionary or not value.get("rewards") is Dictionary or not value.get("disclosure") is Dictionary: return "Complete versioned biography policy required."
	if not value.disclosure.get("social") is Dictionary or not value.disclosure.get("modifiers") is Dictionary: return "Explicit effect disclosure labels required."
	for index in 5:
		if not value.disclosure.social.get(str(index)) is String or value.disclosure.social[str(index)].is_empty(): return "All five social labels required."
	for kind in ["poison_modifier","fatigue_modifier","reaction_modifier","disease_modifier","magic_modifier","avoid_hit_modifier"]:
		if not value.disclosure.modifiers.get(kind) is String or value.disclosure.modifiers[kind].is_empty(): return "All supported modifier labels required."
	var rewards: Dictionary = value.rewards
	if rewards.size() != 6 or not preload("res://scripts/char/starting_rolls.gd").bounds(rewards.get("arrow_quantity"),1,1000000) or not preload("res://scripts/char/starting_rolls.gd").bounds(rewards.get("book_price"),0,1000000) or not rewards.get("armor_materials") is Dictionary or not rewards.get("armor_variants") is Dictionary or not rewards.get("material_labels") is Array or rewards.material_labels.size() != 10: return "Complete bounded reward rules required."
	for key in rewards.armor_materials:
		if not key is String or not key.is_valid_int() or not Formats.integer(rewards.armor_materials[key],512,521): return "Supported explicit armor material mapping required."
	for key in rewards.armor_variants:
		if not key is String or not key.is_valid_int() or not preload("res://scripts/char/starting_rolls.gd").bounds(rewards.armor_variants[key],0,255): return "Bounded armor variant rules required."
	var expected: Array = []
	for index in 18: expected.append("class-%02d" % index)
	if value.order != expected: return "Affinity ties require the approved explicit classic order."
	for career in value.order:
		if not value.mappings.get(career) is Array or value.mappings[career].is_empty(): return "Missing explicit biography mapping: "+career
		var seen := {}
		for template in value.mappings[career]:
			if not template is String or seen.has(template) or not value.narratives.get(template) is String: return "Unique eligible template and explicit narrative mapping required."
			seen[template] = true
	for bank in value.name_banks:
		if not value.name_banks[bank] is Array or value.name_banks[bank].size() != (4 if bank == "Nord" else 5 if bank == "Redguard" else 6): return "Complete supported name bank required."
		for parts in value.name_banks[bank]:
			if not parts is Array or parts.is_empty(): return "Nonempty name parts required."
			for part in parts:
				if not part is String or part.length() > 128: return "Bounded name parts required."
	for race in value.race_contexts:
		var context: Variant = value.race_contexts[race]
		if not context is Dictionary or context.size() != 4 or not value.name_banks.has(context.get("bank")): return "Explicit draft race macro context required."
		for key in ["race","home","terrain"]:
			if not context.get(key) is String or context[key].is_empty(): return "Readable race macro context required."
	for id_book in value.books:
		if not id_book is int or id_book < 0 or id_book > 65535: return "Book IDs must be supported unsigned integers."
	for name in value.imperial_names:
		if not name is String or name.is_empty(): return "Nonempty imperial names required."
	for mapping in value.items:
		if not mapping is String or not value.items[mapping] is String: return "Stable item mappings required."
	return ""

func validate_references(resources: Dictionary) -> Array:
	var policy: Dictionary = Typed.exact_numbers(resources.get(DOMAIN+":policy",{}).get("records",{}).get("stock",{}).get("value",{}))
	var catalog: Dictionary = resources.get("actor.inputs:catalog",{}).get("records",{})
	var texts: Dictionary = resources.get(DOMAIN+":texts",{}).get("records",{})
	var books: Dictionary = resources.get(DOMAIN+":books",{}).get("records",{})
	for id in policy.get("books",[]):
		var source: Dictionary = books.get("book-"+str(id),{}).get("value",{}).get("source",{})
		if not source.get("ok",false): return [{"source":DOMAIN,"reason":"Required biography book metadata missing or invalid: "+str(id)+" "+str(source.get("reason",""))}]
	for career in policy.get("order",[]):
		if catalog.get(career,{}).get("value",{}).get("kind") != "class": return [{"source":DOMAIN,"reason":"Missing affinity class: "+career}]
		for template in policy.mappings[career]:
			if catalog.get(template,{}).get("value",{}).get("kind") != "biography": return [{"source":DOMAIN,"reason":"Missing mapped biography: "+template}]
			if not texts.has(policy.narratives[template]): return [{"source":DOMAIN,"reason":"Missing mapped biography history: "+template}]
	return []
