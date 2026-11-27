extends RefCounted
## DATA publication of authored policy and selected-classic creation inputs.
const DOMAIN = "char.career"
const VERSION = "creation-career-v1"
const F = preload("res://scripts/data/actor_input_formats.gd")
const Custom = preload("res://scripts/char/custom_career.gd")
const Text = preload("res://scripts/data/structured_text.gd")
var classic: RefCounted
var _source_provenance: Dictionary = {}
var _appearance_receipts: Dictionary = {}

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,"actor.inputs","actor.baseline"],"operations":["add","replace","patch"],"required_resources":["policy","sources"],"capabilities":["data."+VERSION]}

func validate_resource_path(path: String) -> String:
	return "" if path in ["policy","sources"] else "Creation career uses policy and sources."

func bundled_contributions() -> Array:
	var source := read_sources()
	_source_provenance = source.provenance.duplicate(true)
	_appearance_receipts = source.appearances.duplicate(true)
	return [{"root":"res://content/char","file":"career.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/char/career.json")},{"root":"classic://selected","file":"creation-sources.json","version":VERSION,"bytes":JSON.stringify({"domain":DOMAIN,"path":"sources","operation":"add","entries":[{"id":"stock","value":source}]}).to_utf8_buffer()}]

func validate_source_record(_id: String, value: Dictionary, _fields: Dictionary, _path: String, _source: Dictionary, _identity: Dictionary) -> Dictionary:
	if value.get("schema") == "creation-sources-v1" and not F.equal_input(value.get("provenance"),_source_provenance): return {"ok":false,"reason":"Creation source overrides must retain the verified baseline input receipt; authored changes retain their DATA contributor provenance."}
	if value.get("schema") == "creation-sources-v1" and not F.equal_input(value.get("appearances"),_appearance_receipts): return {"ok":false,"reason":"Native appearance qualification receipts cannot be authored. Replace supported mapping definitions; new resource providers retain their later qualification gate."}
	return {"ok":true}

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	for key in fields: value[key] = fields[key]
	return {"ok":true,"value":value}

static func literal(decoded: Dictionary) -> String:
	var result := ""
	for token: Dictionary in decoded.get("tokens",[]):
		if token.kind == "text": result += token.text
		elif token.kind in ["line_break","justify_left","justify_center","page_break"]: result += "\n"
	return result.strip_edges()

func read_sources() -> Dictionary:
	var result := {"schema":"creation-sources-v1","descriptions":{},"questionnaire":{},"picker":{},"appearances":{},"provenance":{}}
	for race in 8:
		var files: Array[String] = ["SCBG%02dI0.IMG" % race]
		for gender in 2:
			files.append("FACE%d%dI0.CIF" % [gender,race])
			for clothed in 2: files.append("BODY%d%dI%d.IMG" % [gender,race,clothed])
		for file in files: result.appearances[file] = classic.creation_appearance(file)
	for id in range(2000,2008):
		var read := Text.read(classic,id)
		result.descriptions[str(id)] = {"ok":read.ok,"text":literal(read) if read.ok else "","reason":read.get("reason","")}
	for id in range(2100,2118):
		var read := Text.read(classic,id)
		result.descriptions[str(id)] = {"ok":read.ok,"text":literal(read) if read.ok else "","reason":read.get("reason","")}
	var questions := Text.read(classic,9000)
	var mapping: Dictionary = classic.creation_source("CLASSES.DAT")
	result.questionnaire = parse_questionnaire(questions,mapping)
	var picker: Dictionary = classic.creation_source("TAMRIEL2.IMG")
	if picker.ok:
		var decoded := preload("res://scripts/data/classic_image.gd").new().decode(picker.bytes,"TAMRIEL2.IMG",0,0)
		if decoded.ok and decoded.width == 320 and decoded.height == 200:
			result.picker = {"ok":true,"width":320,"height":200,"indices":Array(decoded.indices),"sha256":picker.sha256}
		else: result.picker = {"ok":false,"reason":"Invalid 320x200 province picker."}
	else: result.picker = {"ok":false,"reason":picker.reason}
	result.provenance = {"transport":"selected external classic installation","text":"TEXT.RSC:2000..2007,2100..2117,9000","mapping":mapping.get("sha256","unavailable"),"picker":picker.get("sha256","unavailable")}
	return result

static func parse_questionnaire(questions: Dictionary, mapping: Dictionary) -> Dictionary:
	if not questions.get("ok",false) or not mapping.get("ok",false): return {"ok":false,"reason":"Class questionnaire content unavailable. Choose direct selection."}
	var bytes: PackedByteArray = mapping.bytes
	if bytes.size() != 216: return {"ok":false,"reason":"CLASSES.DAT must contain 18 headers and 66 result triples. Choose direct selection."}
	var results := {}
	for index in 66:
		var offset := 18+index*3
		var triple := [int(bytes[offset]),int(bytes[offset+1]),int(bytes[offset+2])]
		var key := "%d/%d/%d" % triple
		var header_index := index/4
		var career := int(bytes[header_index]) if header_index <= 3 else int(bytes[header_index]) & 15
		if triple[0]+triple[1]+triple[2] != 10 or results.has(key) or career >= 18: return {"ok":false,"reason":"Malformed classic class-result mapping. Choose direct selection."}
		results[key] = "class-%02d" % career
	var source := literal(questions)
	var regex := RegEx.new()
	regex.compile("\\{([0-9]+)\\.")
	var matches := regex.search_all(source)
	if matches.size() != 40: return {"ok":false,"reason":"Forty class questions required. Choose direct selection."}
	var library := {}
	for index in 40:
		if matches[index].get_string(1) != str(index+1): return {"ok":false,"reason":"Class question identity mismatch. Choose direct selection."}
		var end: int = matches[index+1].get_start() if index < 39 else source.length()
		var body := source.substr(matches[index].get_end(),end-matches[index].get_end()).trim_suffix("{").strip_edges()
		var parts := RegEx.new()
		parts.compile("[abc]\\)")
		var answers := parts.search_all(body)
		if answers.size() != 3: return {"ok":false,"reason":"Each class question requires three answers. Choose direct selection."}
		var labels: Array = []
		for answer in 3:
			if answers[answer].get_string() != ["a)","b)","c)"][answer]: return {"ok":false,"reason":"Class answers must retain a/b/c ordering. Choose direct selection."}
			var stop: int = answers[answer+1].get_start() if answer < 2 else body.length()
			labels.append(body.substr(answers[answer].get_end(),stop-answers[answer].get_end()).strip_edges())
		library["question-%02d" % index] = {"text":body.substr(0,answers[0].get_start()).strip_edges(),"answers":labels}
	return {"ok":true,"questions":library,"results":results}

func validate_record(id: String, value: Dictionary) -> String:
	if id != "stock": return "Only stock creation policy/source binding is supported."
	if value.get("schema") == "creation-sources-v1": return source_reason(value)
	return policy_reason(value)

static func policy_reason(p: Dictionary) -> String:
	if p.size() != 14 or p.get("schema") != VERSION or not p.get("attributes") is Dictionary or not p.get("skills") is Dictionary or not p.get("traits") is Dictionary or not p.get("races") is Dictionary or not p.get("hp") is Dictionary or not p.get("difficulty") is Dictionary or not p.get("limits") is Dictionary or not p.get("reputation") is Dictionary or not p.get("answer_categories") is Array or not p.get("provenance") is Dictionary or p.provenance.is_empty(): return "Complete typed creation-career policy required."
	if p.attributes.size() != 8 or p.reputation.size() != 5 or p.skills.size() != 35 or p.races.size() != 8 or p.answer_categories.size() != 40 or p.traits.size() > 90: return "Supported creation roster required."
	for collection in [p.attributes,p.reputation]:
		var minimum := 0
		var maximum := 0
		for key in (Custom.ATTRIBUTES if collection == p.attributes else Custom.GROUPS):
			var bound: Variant = collection.get(key)
			if not bound is Dictionary or bound.size() != 3: return "Complete starts and bounds required."
			for field in ["start","min","max"]:
				if not F.integer(bound.get(field),0 if collection == p.attributes else -1000000,1000000): return "Supported integer starts/bounds required."
			if bound.min > bound.max or bound.start < bound.min or bound.start > bound.max: return "Invalid starts/bounds."
			minimum += int(bound.min); maximum += int(bound.max)
		var total: Variant = p.get("attribute_total" if collection == p.attributes else "reputation_total")
		if not F.integer(total,minimum,maximum): return "Impossible allocation budget."
	if p.hp.size() != 3 or p.difficulty.size() != 4 or p.limits.size() != 2: return "Complete HP/difficulty/limit policy required."
	for key in ["start","min","max"]:
		if not F.integer(p.hp.get(key),1,1000000): return "Invalid HP policy."
	if p.hp.min > p.hp.start or p.hp.start > p.hp.max: return "HP bounds must contain the default."
	for key in ["min","max","low_milli","high_milli"]:
		if not F.integer(p.difficulty.get(key),-1000000,1000000): return "Invalid advancement policy."
	if p.difficulty.min >= p.difficulty.max or p.difficulty.low_milli <= 0 or p.difficulty.high_milli < p.difficulty.low_milli: return "Ordered difficulty and positive advancement endpoints required."
	for side in ["advantage","disadvantage"]:
		if not F.integer(p.limits.get(side),0,90): return "Supported per-list counts are 0..90; the baseline is seven."
	var classic_ids := {}
	for key in p.skills:
		if key not in preload("res://scripts/data/actor_baseline.gd").SKILLS: return "Unsupported skill identity."
		var skill: Variant = p.skills[key]
		if not skill is Dictionary or skill.size() != 2 or not skill.get("label") is String or skill.label.is_empty() or not F.integer(skill.get("classic"),0,34) or classic_ids.has(int(skill.classic)): return "Unique supported classic skill identities required."
		if int(skill.classic) != preload("res://scripts/data/actor_baseline.gd").SKILLS.find(key): return "Stable CHAR skill identities cannot be renumbered; replace career assignments instead."
		classic_ids[int(skill.classic)] = true
		if skill.label.length() > 160: return "Bounded skill labels required."
	for row in p.answer_categories:
		if not row is Array or row.size() != 3: return "Three classic answer categories required."
		var categories := {}
		for number in row:
			if not F.integer(number,0,2): return "Supported answer category integer required."
			categories[int(number)] = true
		if categories.size() != 3: return "Three distinct classic answer categories required."
	for key in p.traits:
		var option: Variant = p.traits[key]
		if not option is Dictionary or option.size() != 7 or not option.get("label") is String or option.label.is_empty() or option.get("side") not in ["advantage","disadvantage"] or not F.integer(option.get("cost"),-1000000,1000000) or not option.get("singleton") is bool: return "Typed supported option required."
		if not supported_trait(key,option): return "Unsupported option identity/effect/conflict definition."
		if option.label.length() > 160: return "Bounded option labels required."
	var picker_ids := {}
	for key in ["breton","redguard","nord","dark-elf","high-elf","wood-elf","khajiit","argonian"]:
		var race: Variant = p.races.get(key)
		if not race is Dictionary or race.size() != 7 or not race.get("label") is String or not race.get("benefit") is String or not F.integer(race.get("picker"),1,8) or picker_ids.has(int(race.picker)) or not F.integer(race.get("description"),2000,2007) or not F.integer(race.get("narration"),0,10000) or not race.get("appearance") is Dictionary or not race.get("abilities") is Dictionary: return "Complete supported race definition required."
		picker_ids[int(race.picker)] = true
		if race.label.is_empty() or race.label.length() > 160 or race.benefit.length() > 4096: return "Bounded nonblank race labels and benefit text required."
		var ability: Dictionary = race.abilities
		match ability.get("kind"):
			"resistance", "immunity":
				if ability.size() != 2 or ability.get("effect") not in ["magic","frost","paralysis"]: return "Unsupported racial tolerance definition."
			"weapon_modifiers":
				if ability.size() != 3 or ability.get("scope") not in ["weapon","archery_weapon","non_archery_weapon"] or not F.integer(ability.get("divisor"),1,1000000): return "Supported racial weapon scope/divisor required."
			"effective_climbing":
				if ability.size() != 3 or not F.integer(ability.get("bonus"),0,1000000) or ability.get("order") != "before_enhancement_and_clamp": return "Supported racial climbing definition required."
			"swimming":
				if ability.size() != 4 or not F.integer(ability.get("breath_restore_numerator"),0,1000000) or not F.integer(ability.get("breath_restore_denominator"),1,1000000) or ability.breath_restore_numerator > ability.breath_restore_denominator or not ability.get("failed_check_fatigue_exempt") is bool: return "Supported racial swimming definition required."
			_: return "Unsupported racial ability kind."
		for gender in ["male","female"]:
			var assets: Variant = race.appearance.get(gender)
			if not assets is Dictionary or assets.size() != 4: return "Both race/gender appearance sets required."
			for field in ["body","clothed","heads","background"]:
				if not assets.get(field) is String or assets[field].get_file() != assets[field] or not assets[field].to_upper().ends_with(".CIF" if field == "heads" else ".IMG"): return "Explicit appearance resource filenames required."
	# A concrete legal witness proves reachability even when a mod's bounds
	# require traits. No exponential catalog search or silent baseline substitution.
	if not p.get("tradeoff_witness") is Dictionary or p.tradeoff_witness.size() != 2 or not F.integer(p.tradeoff_witness.get("hit_points_per_level"),int(p.hp.min),int(p.hp.max)) or not p.tradeoff_witness.get("traits") is Array: return "Provide a supported HP/trait reachability witness."
	var witness := Custom.initial(p,"policy-witness")
	witness.name = "Policy validation witness"
	witness.hit_points_per_level = int(p.tradeoff_witness.hit_points_per_level)
	witness.traits = p.tradeoff_witness.traits.duplicate()
	var skill_index := 0
	for tier in Custom.COUNTS:
		for slot in Custom.COUNTS[tier]: witness.tiers[tier][slot] = p.skills.keys()[skill_index]; skill_index += 1
	for values in [witness.attributes,witness.reputation]:
		var bounds: Dictionary = p.attributes if values == witness.attributes else p.reputation
		var remaining := int(p.attribute_total) if values == witness.attributes else int(p.reputation_total)
		for number in values.values(): remaining -= int(number)
		for key in values:
			var adjustment := clampi(remaining,int(bounds[key].min)-int(values[key]),int(bounds[key].max)-int(values[key]))
			values[key] += adjustment; remaining -= adjustment
	var evaluated := Custom.evaluate(witness,p,"policy-witness")
	if not evaluated.ok or not evaluated.get("errors",[]).is_empty(): return "Reachability witness is invalid: "+str(evaluated.get("reason",evaluated.get("errors",[])))
	return ""

static func supported_trait(id: String, option: Dictionary) -> bool:
	const TARGETS = {"acute_hearing":["none"],"adrenaline_rush":["none"],"athleticism":["none"],"bonus_to_hit":["animals","daedra","humanoid","undead"],"phobia":["animals","daedra","humanoid","undead"],"expertise":["axe","blunt","hand_to_hand","long_blade","missile","short_blade"],"forbidden_weaponry":["axe","blunt","hand_to_hand","long_blade","missile","short_blade"],"immunity":["disease","fire","frost","magic","paralysis","poison","shock"],"resistance":["disease","fire","frost","magic","paralysis","poison","shock"],"low_tolerance":["disease","fire","frost","magic","paralysis","poison","shock"],"critical_weakness":["disease","fire","frost","magic","paralysis","poison","shock"],"increased_magery":["1","1.5","1.75","2","3"],"rapid_healing":["general","darkness","light"],"regenerate_health":["general","darkness","light","immersed"],"spell_absorption":["general","darkness","light"],"damage":["holy_places","sunlight"],"darkness_powered_magery":["lower_daylight","unable_daylight"],"light_powered_magery":["lower_darkness","unable_darkness"],"forbidden_armor":["chain","leather","plate"],"forbidden_material":["adamantium","daedric","dwarven","ebony","elven","iron","mithril","orcish","silver","steel"],"forbidden_shield":["buckler","kite","round","tower"],"no_spell_point_regeneration":["none"]}
	var category: Variant = option.get("category")
	var target: Variant = option.get("target")
	if not category is String or not TARGETS.has(category) or target not in TARGETS[category]: return false
	var expected_id: String = category if target == "none" else category+"/"+str(target)
	# Conflict groups and category singleton policy are authored creation rules.
	# Identity, target and effect side still retain their supported owner contract.
	if not option.get("conflict") is String or option.conflict.length() > 64: return false
	for character: String in option.conflict:
		if character not in "abcdefghijklmnopqrstuvwxyz0123456789_-": return false
	var advantage: bool = category in ["acute_hearing","adrenaline_rush","athleticism","bonus_to_hit","expertise","immunity","resistance","increased_magery","rapid_healing","regenerate_health","spell_absorption"]
	return id == expected_id and option.side == ("advantage" if advantage else "disadvantage")

static func source_reason(value: Dictionary) -> String:
	if value.size() != 6 or not value.get("descriptions") is Dictionary or not value.get("questionnaire") is Dictionary or not value.get("picker") is Dictionary or not value.get("provenance") is Dictionary or not value.get("appearances") is Dictionary: return "Complete creation source binding required."
	for file in value.appearances:
		var appearance: Variant = value.appearances[file]
		if not appearance is Dictionary or not appearance.get("ok") is bool: return "Explicit appearance source status required."
		if appearance.ok:
			if appearance.size() != 5 or appearance.get("source") != file or not appearance.get("sha256") is String or appearance.sha256.length() != 64 or not appearance.get("first_frame") is Dictionary or not appearance.get("scope") is String: return "Verified bounded appearance mapping receipt required."
			if appearance.first_frame.size() != 2 or not F.integer(appearance.first_frame.get("width"),1,32767) or not F.integer(appearance.first_frame.get("height"),1,32767): return "Positive appearance frame dimensions required."
		else:
			if appearance.size() != 2 or not appearance.get("reason") is String or appearance.reason.is_empty(): return "Explicit appearance failure required."
	if value.appearances.size() != 56: return "Explicit status for all 56 appearance mappings required."
	for race in 8:
		var files: Array[String] = ["SCBG%02dI0.IMG" % race]
		for gender in 2:
			files.append("FACE%d%dI0.CIF" % [gender,race])
			for clothed in 2: files.append("BODY%d%dI%d.IMG" % [gender,race,clothed])
		for file in files:
			if not value.appearances.has(file): return "Missing stable appearance source status."
	if value.descriptions.size() != 26: return "All race/preset descriptions require explicit source status."
	for number in range(2000,2008):
		if not value.descriptions.has(str(number)): return "Missing stable race description identity."
	for number in range(2100,2118):
		if not value.descriptions.has(str(number)): return "Missing stable preset description identity."
	for item in value.descriptions.values():
		if not item is Dictionary or not item.get("ok") is bool or not item.get("text") is String or not item.get("reason") is String or item.text.length() > 65536 or (item.ok and item.text.strip_edges().is_empty()): return "Typed bounded descriptions required."
		if item.size() != 3 or (not item.ok and item.reason.strip_edges().is_empty()): return "Explicit bounded description failure required."
	if not value.questionnaire.get("ok") is bool or not value.picker.get("ok") is bool: return "Explicit source readiness required."
	for source in [value.questionnaire,value.picker]:
		if not source.ok and (source.size() != 2 or not source.get("reason") is String or source.reason.strip_edges().is_empty()): return "Explicit source failure explanation required."
	if value.picker.ok:
		if value.picker.size() != 5 or value.picker.get("width") != 320 or value.picker.get("height") != 200 or not value.picker.get("indices") is Array or value.picker.indices.size() != 64000 or not value.picker.get("sha256") is String or value.picker.sha256.length() != 64: return "Province picker requires 320x200 indices and source receipt."
		var coverage := 0
		for number in value.picker.indices:
			if not F.integer(number,0,255): return "Invalid province-picker pixel."
			if number >= 1 and number <= 8: coverage |= 1 << int(number)
		if coverage != 510: return "All eight supported home provinces require mapped pixels."
	if value.questionnaire.ok:
		if value.questionnaire.size() != 3 or not value.questionnaire.get("questions") is Dictionary or value.questionnaire.questions.size() != 40 or not value.questionnaire.get("results") is Dictionary or value.questionnaire.results.size() != 66: return "Complete question/result mapping required."
		for index in 40:
			var question: Variant = value.questionnaire.questions.get("question-%02d" % index)
			if not question is Dictionary or question.size() != 2 or not question.get("text") is String or question.text.is_empty() or question.text.length() > 8192 or not question.get("answers") is Array or question.answers.size() != 3: return "Question text and three answers required."
			for answer in question.answers:
				if not answer is String or answer.strip_edges().is_empty() or answer.length() > 8192: return "Bounded nonblank answers required."
		for mage in 11:
			for rogue in range(11-mage):
				var key := "%d/%d/%d" % [mage,rogue,10-mage-rogue]
				if value.questionnaire.results.get(key) not in _preset_ids(): return "Missing/invalid class-result mapping."
	return ""

static func _preset_ids() -> Array:
	var ids: Array = []
	for i in 18: ids.append("class-%02d" % i)
	return ids

func validate_references(resources: Dictionary) -> Array:
	var policy: Dictionary = resources.get(DOMAIN+":policy",{}).get("records",{}).get("stock",{}).get("value",{})
	var sources: Dictionary = resources.get(DOMAIN+":sources",{}).get("records",{}).get("stock",{}).get("value",{})
	if policy.is_empty() or sources.is_empty(): return [{"source":DOMAIN,"reason":"Creation policy/source binding missing."}]
	var numeric: Dictionary = resources.get("actor.baseline:policy",{}).get("records",{}).get("player",{}).get("value",{})
	if not numeric.is_empty():
		for key in Custom.ATTRIBUTES:
			if policy.attributes[key].min < numeric.attributes[key].min or policy.attributes[key].max > numeric.attributes[key].max: return [{"source":DOMAIN,"reason":"Custom attribute bounds incompatible with CHAR numeric policy."}]
	var classes: Dictionary = resources.get("actor.inputs:catalog",{}).get("records",{})
	if not classes.is_empty():
		for id in _preset_ids():
			if not classes.has(id): return [{"source":DOMAIN,"reason":"Missing required preset: "+id}]
			var resolved := preload("res://scripts/char/preset_career.gd").resolve(classes[id].value.data,policy,numeric)
			if not resolved.ok: return [{"source":DOMAIN,"reason":id+": "+str(resolved.reason)}]
			if not numeric.is_empty():
				for index in 8:
					var key: String = Custom.ATTRIBUTES[index]
					var number: int = int(resolved.attributes[index])
					if number < numeric.attributes[key].min or number > numeric.attributes[key].max: return [{"source":DOMAIN,"reason":id+": base attribute incompatible with CHAR numeric domain."}]
	return []
