extends RefCounted
## Isolated draft evaluation. Original declarations survive; no owner is granted
## a live item, spell, actor, quest or reputation mutation interface here.
const Rolls = preload("res://scripts/char/starting_rolls.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")
const EFFECTS = ["skill_adjustment","narrative_token","item_grant","gold_adjustment","faction_reputation","social_reputation","poison_modifier","fatigue_modifier","reaction_modifier","disease_modifier","magic_modifier","avoid_hit_modifier","classic_ae_declaration","classic_af_declaration"]

static func affinity(custom: Dictionary, presets: Dictionary, order: Array) -> Dictionary:
	var skills := {}
	for tier in Rolls.TIERS:
		if not custom.get(tier) is Array or custom[tier].size() != Rolls.COUNTS[tier]: return Draft.failure("affinity","Twelve distinct career skills required.")
		for id in custom[tier]:
			if skills.has(id): return Draft.failure("affinity","Duplicate custom skill.")
			skills[id] = true
	var highest := 0
	var winner := ""
	for id in order:
		if not presets.get(id,{}).get("ok",false): return Draft.failure("affinity","Required affinity preset unavailable: "+str(id))
		var matches := {}
		for tier in Rolls.TIERS:
			for skill in presets[id].tiers[tier]: matches[skill] = true
		var score := 0
		for skill in skills:
			if matches.has(skill): score += 1
		if score > highest: highest = score; winner = id
	return {"ok":true,"id":winner,"overlap":highest} if highest > 0 else Draft.failure("affinity","No positive twelve-skill biography affinity; no default was substituted.")

static func text_ref(texts: Dictionary, id: String) -> Dictionary:
	return {"ok":true,"text":texts[id].text} if texts.has(id) and texts[id].get("available",false) else Draft.failure("narrative","Missing required biography text: "+id)

static func supported(template: Dictionary, texts: Dictionary, items: Dictionary, root: String, policy: Dictionary = {}) -> Dictionary:
	if template.get("backstory_text_id") != null: root = "text-"+str(template.backstory_text_id)
	if template.get("questions",[]).is_empty() or template.questions.size() > 256 or not texts.has(root): return Draft.failure("biography","Required biography questions/history unavailable.")
	var channels := {}
	for q in template.questions:
		for suffix in ["","a","b"]: channels[q.id+suffix] = []
		for a in q.answers:
			var narrative_index := 0
			for effect in a.effects:
				if effect.type not in EFFECTS: return Draft.failure("effect","Unsupported required biography effect: "+str(effect.type))
				if effect.type == "narrative_token" and not texts.has("text-"+str(effect.parameters.text_id)): return Draft.failure("narrative","Missing answer narrative: "+str(effect.parameters.text_id))
				if effect.type == "narrative_token":
					if narrative_index < 3: channels[q.id+["","a","b"][narrative_index]].append("text-"+str(effect.parameters.text_id))
					narrative_index += 1
				if effect.type == "item_grant":
					var key := "%d:%d" % [effect.parameters.group,effect.parameters.index]
					if not items.get(key,{}).get("ok",false): return Draft.failure("reward","Required item definition missing or ambiguous: "+key)
					if effect.parameters.group in [2,3] and effect.parameters.material > 9: return Draft.failure("reward","Unsupported equipment material.")
					var domain := reward_domain(effect,items[key],policy)
					if not domain.ok: return domain
	return narrative_dependencies(root,texts,channels,{}, {})

static func reward_domain(effect: Dictionary, item: Dictionary, policy: Dictionary) -> Dictionary:
	var p: Dictionary = effect.parameters
	if not policy.has("rewards"): return Draft.failure("reward","Required reward policy unavailable.")
	if p.group in [4,5,13]: return Draft.failure("reward","Required magic/artifact/painting reward construction is not supported by this biography owner.")
	if p.group == 7 and int(item.record.value.data.variants) < 1: return Draft.failure("reward","Random book requires a nonempty cover-variant domain.")
	if p.group == 2:
		if not policy.rewards.armor_materials.has(str(p.material)): return Draft.failure("reward","Required armor material mapping unavailable.")
		var variant_bounds: Dictionary = policy.rewards.armor_variants.get(str(p.index),{"min":0,"max":0})
		if p.index == 5: variant_bounds = {"min":0,"max":int(item.record.value.data.variants)-1}
		if (variant_bounds.max > 0 and variant_bounds.max >= int(item.record.value.data.variants)) or variant_bounds.min < 0 or variant_bounds.max < variant_bounds.min: return Draft.failure("reward","Required armor variants disagree with resolved item definition.")
		return {"ok":true,"variant_bounds":variant_bounds,"material":policy.rewards.armor_materials[str(p.material)]}
	return {"ok":true}

static func narrative_dependencies(id: String, texts: Dictionary, channels: Dictionary, path: Dictionary, memo: Dictionary) -> Dictionary:
	if path.has(id): return Draft.failure("macro","Cyclic possible biography macro dependency is unsupported: "+id)
	if memo.has(id): return {"ok":true,"height":memo[id]}
	var read := text_ref(texts,id)
	if not read.ok: return read
	path[id] = true
	var height := 1
	var regex := RegEx.new(); regex.compile("%[A-Za-z][A-Za-z0-9]*")
	for found in regex.search_all(read.text):
		var key: String = found.get_string().substr(1)
		if key in ["ra","hpn","hpw","bn","fn","mn","imp","r1","r2","r3","r4","r5"]: continue
		if not channels.has(key): return Draft.failure("macro","Unsupported required biography macro: %"+key)
		for child in channels[key]:
			var checked := narrative_dependencies(child,texts,channels,path,memo)
			if not checked.ok: return checked
			height = maxi(height,checked.height+1)
	path.erase(id)
	if height > 16: return Draft.failure("macro","Possible biography narrative expansion exceeds its supported depth.")
	memo[id] = height
	return {"ok":true,"height":height}

static func name_part(source: RefCounted, parts: Array) -> String:
	return parts[source.bounded(parts.size()).value]

static func name(source: RefCounted, bank: String, banks: Dictionary, female: bool) -> String:
	var sets: Array = banks[bank]
	if bank == "Redguard":
		var value := name_part(source,sets[0])+name_part(source,sets[1])+name_part(source,sets[2])
		if female or source.bounded(100).value < 75: value += name_part(source,sets[4 if female else 3])
		return value
	var value := name_part(source,sets[2 if female else 0])+name_part(source,sets[3 if female else 1])
	return value+" "+name_part(source,sets[0])+name_part(source,sets[1])+"sen" if bank == "Nord" else value+" "+name_part(source,sets[4])+name_part(source,sets[5])

static func reward(effect: Dictionary, item: Dictionary, policy: Dictionary, source: RefCounted, books: Dictionary) -> Dictionary:
	var p: Dictionary = effect.parameters
	var domain := reward_domain(effect,item,policy)
	if not domain.ok: return domain
	var result := {"definition":item.record.identity.duplicate(true),"winner":item.record.winner.duplicate(true),"group":p.group,"index":p.index,"material":p.material if p.group in [2,3] else 0,"quantity":1,"variant":0,"hidden":false}
	if p.group == 2:
		result.source_material = p.material
		result.material = domain.material
		var bounds: Dictionary = domain.variant_bounds
		result.variant = bounds.min+(source.bounded(bounds.max-bounds.min+1).value if bounds.max > bounds.min else 0)
		result.hidden = bounds.max > bounds.min
	if p.group == 3 and p.index == 18:
		var bounds: Dictionary = policy.rewards.arrow_quantity
		result.quantity = bounds.min+source.bounded(bounds.max-bounds.min+1).value
		result.material = 0
		result.hidden = true
	if p.group == 7:
		result.book_id = policy.books[source.bounded(policy.books.size()).value]
		var book: Dictionary = books.get(str(result.book_id),{})
		if not book.get("ok",false): return Draft.failure("reward","Required selected book metadata unavailable.")
		result.book_source = book.duplicate(true)
		var prices: Dictionary = policy.rewards.book_price
		var price: Dictionary = preload("res://scripts/rule/classic_random.gd").create(book.price_seed).range_value(prices.min,prices.max,true)
		if not price.ok: return Draft.failure("reward","Book price context unavailable.")
		result.book_price = price.value
		var variants: int = item.record.value.data.variants
		if variants < 1: return Draft.failure("reward","Random book requires a nonempty cover-variant domain.")
		result.variant = source.bounded(variants).value
		result.hidden = true
	return {"ok":true,"intent":result}

static func expand(text: String, macros: Dictionary, texts: Dictionary, depth := 0) -> Dictionary:
	if depth > 16: return Draft.failure("macro","Biography macro recursion exceeds the supported bound.")
	var regex := RegEx.new(); regex.compile("%[A-Za-z][A-Za-z0-9]*")
	var result := ""
	var references: Array = []
	var position := 0
	for found in regex.search_all(text):
		var key: String = found.get_string().substr(1)
		if not macros.has(key): return Draft.failure("macro","Unsupported or missing biography macro: %"+key)
		var replacement: Variant = macros[key]
		if replacement is int:
			var read := text_ref(texts,"text-"+str(replacement))
			if not read.ok: return read
			var reference := "text-"+str(replacement)
			if reference not in references: references.append(reference)
			var expanded := expand(read.text,macros,texts,depth+1)
			if not expanded.ok: return expanded
			for nested in expanded.references:
				if nested not in references: references.append(nested)
			replacement = expanded.text
		result += text.substr(position,found.get_start()-position)+str(replacement)
		position = found.get_end()
	result += text.substr(position)
	return {"ok":true,"text":result,"references":references}

static func evaluate(state: Dictionary, template: Dictionary, policy: Dictionary, texts: Dictionary, skill_numbers: Dictionary, race: String) -> Dictionary:
	if not policy.race_contexts.has(race): return Draft.failure("macro","Birth-race context unavailable.")
	var context: Dictionary = policy.race_contexts[race]
	var macros := {"ra":context.race,"hpn":context.home,"hpw":context.terrain}
	macros.merge(state.names)
	var skills := {}
	var known: Array = []
	var declarations: Array = []
	var obligations: Array = []
	var narrative: Dictionary = {}
	var modifiers := {}
	var social := {}
	var factions := {}
	var errors: Array = []
	var questions := {}
	for q in template.questions: questions[q.id] = q
	for id in state.answers:
		if not questions.has(id): return Draft.failure("answer","Unknown biography question: "+str(id))
	for q in template.questions:
		var answer: Dictionary = {}
		for option in q.answers:
			if option.id == state.answers.get(q.id): answer = option; break
		if answer.is_empty():
			if state.answers.has(q.id): return Draft.failure("answer","Unknown biography answer: "+q.id)
			errors.append("Answer "+q.id+".")
			continue
		var tokens: Array = []
		for index in answer.effects.size():
			var effect: Dictionary = answer.effects[index]
			var p: Dictionary = effect.parameters
			var obligation := {"id":state.template+"/"+q.id+"/"+answer.id+"/"+str(index),"effect":effect.duplicate(true),"represented_in_candidate":false}
			match effect.type:
				"narrative_token": tokens.append(p.text_id); continue
				"classic_ae_declaration","classic_af_declaration": declarations.append(obligation); continue
				"skill_adjustment":
					var skill: String = skill_numbers.get(effect.target,"")
					if skill.is_empty(): return Draft.failure("skill","Unsupported biography skill target.")
					skills[skill] = skills.get(skill,0)+p.amount
					obligation.represented_in_candidate = true
				"item_grant":
					var key: String = q.id+"/"+answer.id+"/"+str(index)
					if not state.outcomes.has(key): return Draft.failure("reward","Resolve the answer's retained reward through CHAR first.")
					obligation.reward = state.outcomes[key].duplicate(true)
				"social_reputation": social[effect.target] = social.get(effect.target,0)+p.amount
				"faction_reputation": factions[effect.target] = factions.get(effect.target,0)+p.amount
				"poison_modifier","fatigue_modifier","reaction_modifier","disease_modifier","magic_modifier","avoid_hit_modifier": modifiers[effect.type] = p.amount
				"gold_adjustment": pass # Ordered signed intent; later ECON applies its floor.
				_: return Draft.failure("effect","Unsupported required biography effect: "+effect.type)
			obligations.append(obligation)
			known.append({"target":effect.target,"type":effect.type,"value":p.get("amount","Item reward; exact randomized contents remain hidden.") if effect.type != "item_grant" else "Item reward; exact randomized contents remain hidden."})
		narrative[q.id] = tokens
	# DFU question channels address the first, second and third narrative records
	# in source effect order. Missing channels are empty, as its null macro result.
	for q in template.questions:
		for index in 3:
			var key: String = q.id+(["","a","b"][index])
			macros[key] = narrative.get(q.id,[])[index] if narrative.get(q.id,[]).size() > index else ""
	for index in 5:
		var amount: int = social.get("classic.social:"+str(index),0)
		macros["r"+str(index+1)] = "higher" if amount > 0 else "lower" if amount < 0 else "unchanged"
	var root: String = "text-"+str(template.backstory_text_id) if template.get("backstory_text_id") != null else policy.narratives[state.template]
	var read := text_ref(texts,root)
	if not read.ok: return read
	var history := expand(read.text,macros,texts)
	if not history.ok: return history
	history.references.push_front(root)
	return {"ok":true,"skill_adjustments":skills,"known_effects":known,"backstory":history.text,"narrative_references":history.references,"intent":{"schema":"creation-biography-intent-v1","obligations":obligations,"nonexecuting_declarations":declarations,"modifiers_last_assignment":modifiers,"social_additions":social,"faction_additions":factions,"application_order":"Commit allocated skill baselines, apply biography once, then capture progression baseline; later grants follow. No live application has occurred."},"errors":errors}
