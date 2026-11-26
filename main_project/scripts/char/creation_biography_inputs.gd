extends "res://scripts/char/creation_starting_inputs.gd"
const Bio = preload("res://scripts/char/biography_evaluator.gd")
var biography_policy: Dictionary = {}
var biography_provenance: Array = []
var templates: Dictionary = {}
var biography_texts: Dictionary = {}
var biography_text_provenance: Dictionary = {}
var biography_items: Dictionary = {}
var biography_books: Dictionary = {}
var biography_factions: Dictionary = {}
var skill_numbers: Dictionary = {}
var _bio_pending: Dictionary = {}
var biography_ready := false

func publish_biography(owner: RefCounted, expected: Dictionary, value: Dictionary) -> Dictionary:
	_bio_pending = {"token":expected.duplicate(true),"value":value.duplicate(true)}
	var checked: Dictionary = owner.edit("biography",expected,value)
	_bio_pending.clear()
	return checked

func prepare() -> Dictionary:
	biography_ready = false
	var checked := super.prepare()
	if not checked.ok: return checked
	checked = prepare_biography()
	biography_ready = checked.ok
	if not checked.ok: setup_error = checked.get("reason","Required biography content is unavailable.")
	return checked

func prepare_biography() -> Dictionary:
	templates.clear(); biography_texts.clear(); biography_text_provenance.clear(); biography_items.clear(); biography_books.clear(); biography_factions.clear(); skill_numbers.clear()
	var started := Time.get_ticks_usec()
	var read: Dictionary = definitions.query("char.biography","policy","stock")
	if not read.ok: return read
	biography_policy = exact_numbers(read.record.value)
	biography_provenance = exact_numbers(read.record.contributors)
	for id in biography_policy.books:
		read = definitions.query("char.biography","books","book-"+str(id))
		if not read.ok: return read
		biography_books[str(id)] = exact_numbers(read.record.value.source)
		if not biography_books[str(id)].ok: return Draft.failure("book",biography_books[str(id)].reason)
	var wanted := {}
	var rewards := {}
	var factions := {}
	for id in policy.skills: skill_numbers["classic.skill:"+str(policy.skills[id].classic)] = id
	for career in biography_policy.mappings:
		for id in biography_policy.mappings[career]:
			if templates.has(id): continue
			read = definitions.query("actor.inputs","catalog",id)
			if not read.ok: return read
			var template: Dictionary = exact_numbers(read.record.value.data)
			template.provenance = exact_numbers({"identity":read.record.identity,"winner":read.record.winner,"contributors":read.record.contributors,"input":read.record.value.input})
			templates[id] = template
			wanted["text-"+str(template.backstory_text_id) if template.backstory_text_id != null else biography_policy.narratives[id]] = true
			for q in template.questions:
				for a in q.answers:
					for e in a.effects:
						if e.type == "narrative_token": wanted["text-"+str(e.parameters.text_id)] = true
						if e.type == "item_grant": rewards["%d:%d" % [e.parameters.group,e.parameters.index]] = true
						if e.type == "faction_reputation": factions[e.target] = true
	for id in wanted:
		read = definitions.query("char.biography","texts",id)
		if not read.ok: return read
		biography_texts[id] = exact_numbers(read.record.value)
		biography_text_provenance[id] = exact_numbers({"identity":read.record.identity,"winner":read.record.winner,"contributors":read.record.contributors,"fields":read.record.fields})
	for key in rewards:
		var id: String = biography_policy.items.get(key,"")
		read = definitions.query("item-spell.inputs","catalog",id)
		if not read.ok: return read
		if read.record.value.kind != "item" or ("group:"+key) not in read.record.value.mappings: return Draft.failure("reward","Biography item mapping disagrees with resolved DATA: "+key)
		biography_items[key] = exact_numbers(read)
	for target in factions:
		var mapping: String = "faction:"+str(target).trim_prefix("classic.faction:")
		var found: Dictionary = definitions.point_query("faction-quest.inputs",{"mapping":mapping})
		if not found.ok: return Draft.failure("faction","Required biography faction target unavailable: "+mapping)
		read = definitions.query("faction-quest.inputs",found.reference.path,found.reference.id)
		if not read.ok or read.record.value.kind != "faction" or mapping not in read.record.value.mappings: return Draft.failure("faction","Biography faction mapping disagrees with resolved DATA: "+mapping)
		biography_factions[target] = exact_numbers({"identity":read.record.identity,"winner":read.record.winner,"contributors":read.record.contributors,"label":read.record.value.data.metadata.get("name",mapping)})
	measurements.biography_preparation_usec = Time.get_ticks_usec()-started
	measurements.biography_templates = templates.size()
	measurements.biography_texts = biography_texts.size()
	return {"ok":true}

func evaluate_biography(value: Dictionary, race: String) -> Dictionary:
	var evaluated := Bio.evaluate(value,templates[value.template],biography_policy,biography_texts,skill_numbers,race)
	if not evaluated.ok: return evaluated
	for obligation in evaluated.intent.obligations:
		if obligation.effect.type != "faction_reputation": continue
		var target: String = obligation.effect.target
		if not biography_factions.has(target): return Draft.failure("faction","Required biography faction binding unavailable: "+target)
		obligation.definition = biography_factions[target].duplicate(true)
	return evaluated

func bindings() -> Dictionary:
	var result := super.bindings()
	for section in ["biography_method","biography"]: result[section] = {"id":"char.creation.biography-v1/"+section,"validate":validate}
	return result

func biography_context(draft: Dictionary) -> Dictionary:
	if not biography_ready: return Draft.failure("unavailable",setup_error if not setup_error.is_empty() else "Required biography content is unavailable; reopen creation after content recovery.")
	var resolved := career_context(draft,"skills")
	if not resolved.ok: return resolved
	var id: String = resolved.context.identity
	if draft.selections.get("class_method") == "custom":
		var matched := Bio.affinity(resolved.career.tiers,_presets,biography_policy.order)
		if not matched.ok: return matched
		id = matched.id
	if not biography_policy.mappings.has(id) or biography_policy.mappings[id].is_empty(): return Draft.failure("mapping","No eligible biographies mapped for "+id)
	return {"ok":true,"id":id,"eligible":biography_policy.mappings[id].duplicate()}

func biography_operation(owner: RefCounted, expected: Dictionary, operation: String, payload: Dictionary = {}) -> Dictionary:
	if not owner.current(expected) or not _bio_pending.is_empty(): return Draft.failure("stale","Biography operation retired or busy.")
	if operation not in ["initialize","automatic","answer"]: return Draft.failure("biography","Unsupported biography operation.")
	var draft: Dictionary = owner.projection()
	var resolved := biography_context(draft)
	if not resolved.ok: return resolved
	var retained: Dictionary = draft.retained.get("biography",{}).get("value",{})
	var value: Dictionary = retained.duplicate(true)
	if not value.is_empty() and value.context != resolved.id:
		value = {}
		for cached in draft.retained.biography.get("contexts",[]):
			if cached.context == resolved.id: value = cached.duplicate(true); break
	if operation == "initialize" and not value.is_empty(): return publish_biography(owner,expected,value)
	if operation == "automatic" and not value.is_empty() and value.answers.size() == templates[value.template].questions.size(): return publish_biography(owner,expected,value)
	if operation == "answer" and not value.is_empty() and value.answers.get(payload.get("question")) == payload.get("answer"): return owner.edit("biography",expected,value)
	var random := random_source("biography/"+operation)
	if not random.ok: return random
	if not owner.current(expected): return Draft.failure("stale","Creation retired during biography entropy acquisition.")
	if value.is_empty():
		for id in resolved.eligible:
			var supported := Bio.supported(templates[id],biography_texts,biography_items,biography_policy.narratives[id],biography_policy)
			if not supported.ok: return supported
			var career := career_context(draft,"skills")
			if not career.ok: return career
			var feasibility := preload("res://scripts/char/biography_feasibility.gd").check(templates[id],career.career.tiers,starting.skills,skill_numbers)
			if not feasibility.ok: return feasibility
		var id: String = resolved.eligible[random.source.bounded(resolved.eligible.size()).value]
		var race: String = draft.selections.get("race","")
		if not biography_policy.race_contexts.has(race): return Draft.failure("macro","Choose a supported birth race first.")
		var bank: String = biography_policy.race_contexts[race].bank
		value = {"context":resolved.id,"template":id,"answers":{},"outcomes":{},"names":{"bn":Bio.name(random.source,bank,biography_policy.name_banks,false),"mn":Bio.name(random.source,bank,biography_policy.name_banks,false),"fn":Bio.name(random.source,bank,biography_policy.name_banks,true),"imp":biography_policy.imperial_names[random.source.bounded(biography_policy.imperial_names.size()).value]},"generation":{"logical_draws":0,"raw_draws":0,"operations":0},"skill_adjustments":{},"known_effects":[],"intent":{}}
	var template: Dictionary = templates[value.template]
	var assignments: Dictionary = {}
	if operation == "automatic":
		for q in template.questions:
			if not value.answers.has(q.id): assignments[q.id] = q.answers[random.source.bounded(q.answers.size()).value].id
	elif operation == "answer":
		if payload.size() != 2 or not payload.get("question") is String or not payload.get("answer") is String: return Draft.failure("answer","Explicit question and answer identities required.")
		assignments[payload.question] = payload.answer
	for qid in assignments:
		var answer := {}
		for q in template.questions:
			if q.id != qid: continue
			for a in q.answers:
				if a.id == assignments[qid]: answer = a; break
		if answer.is_empty(): return Draft.failure("answer","Required biography answer unavailable: "+qid)
		for index in answer.effects.size():
			var effect: Dictionary = answer.effects[index]
			var key: String = qid+"/"+answer.id+"/"+str(index)
			if effect.type != "item_grant" or value.outcomes.has(key): continue
			var item_key := "%d:%d" % [effect.parameters.group,effect.parameters.index]
			var before := {"logical":random.source.logical_count,"raw":random.source.raw_count}
			var reward := Bio.reward(effect,biography_items[item_key],biography_policy,random.source,biography_books)
			if not reward.ok: return reward
			reward.intent.resolution = {"generator":random.receipt.duplicate(true),"before":before,"after":{"logical":random.source.logical_count,"raw":random.source.raw_count},"answer":value.template+"/"+qid+"/"+answer.id,"effect":index}
			value.outcomes[key] = reward.intent
		value.answers[qid] = assignments[qid]
	var evaluated := evaluate_biography(value,draft.selections.race)
	if not evaluated.ok: return evaluated
	for key in ["skill_adjustments","known_effects","intent"]: value[key] = evaluated[key]
	value.generation.logical_draws += random.source.logical_count
	value.generation.raw_draws += random.source.raw_count
	value.generation.operations += 1
	value.generation.last_operation = random.receipt
	return publish_biography(owner,expected,value)

func validate(request: Dictionary) -> Dictionary:
	if request.section not in ["biography_method","biography"]: return super.validate(request)
	if definitions.content_ticket() != content or not biography_ready: return Draft.failure("biography",setup_error if not setup_error.is_empty() else "Published biography policy unavailable.")
	var value: Variant = request.draft.selections[request.section]
	if request.section == "biography_method":
		if value not in ["manual","automatic"]: return Draft.failure("biography","Choose Manual or Automatic.")
		return {"ok":true,"value":value,"retained":{"value":value},"invalidate":[],"provenance":{"policy":"char.biography:policy#stock"},"semantic_ready":true,"errors":[]}
	if not value is Dictionary or value.size() != 9 or not value.get("answers") is Dictionary or not value.get("outcomes") is Dictionary or not value.get("names") is Dictionary or not value.get("generation") is Dictionary or not templates.has(value.get("template")): return Draft.failure("biography","Owner-resolved biography state required.")
	var retained: Dictionary = request.retained.get("biography",{}).get("value",{})
	var authorized: bool = _bio_pending.get("value") == value and _bio_pending.get("token") == {"id":request.draft.id,"revision":request.draft.revision,"content":content}
	if not authorized:
		for key in ["context","template","outcomes","names","generation"]:
			if not Draft.same_value(value.get(key),retained.get(key)): return Draft.failure("biography","Template and retained outcomes must originate from CHAR.")
	var context := biography_context(request.draft)
	if not context.ok: return context
	if value.context != context.id or value.template not in context.eligible: return Draft.failure("biography","Biography is incompatible with the current career mapping.")
	var evaluated := evaluate_biography(value,request.draft.selections.get("race",""))
	if not evaluated.ok: return evaluated
	for key in ["skill_adjustments","known_effects","intent"]:
		if not Draft.same_value(value[key],evaluated[key]): return Draft.failure("biography","Biography effects must match the current authoritative answers.")
	var errors: Array = evaluated.errors.duplicate()
	var narrative_sources := {}
	for id in evaluated.narrative_references: narrative_sources[id] = biography_text_provenance[id].duplicate(true)
	var resolved := career_context(request.draft,"skills")
	if not resolved.ok: return resolved
	var feasible := Rolls.skill_feasibility(resolved.career.tiers,starting.skills,evaluated.skill_adjustments)
	if not feasible.ok: errors.append(feasible.reason)
	var contexts: Array = request.retained.get("biography",{}).get("contexts",[]).duplicate(true)
	for candidate in [retained,value]:
		if candidate.is_empty(): continue
		var replaced := false
		for index in contexts.size():
			if contexts[index].context == candidate.context: contexts[index] = candidate.duplicate(true); replaced = true; break
		if not replaced: contexts.append(candidate.duplicate(true))
	return {"ok":true,"value":value,"retained":{"value":value.duplicate(true),"contexts":contexts},"invalidate":[],"provenance":{"policy":"char.biography:policy#stock","contributors":biography_provenance,"source":templates[value.template].provenance,"resolved_history":evaluated.backstory,"narrative_sources":narrative_sources,"ae_af":"Non-executing metadata, user-approved DFU baseline 2026-11-26","scope":"Resolved draft intent only; no live grants/history SAVE consumers."},"semantic_ready":true,"errors":errors}
