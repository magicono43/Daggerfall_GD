extends "res://tests/mod_cases.gd"
const Stock = preload("res://scripts/char/creation_biography_inputs.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")
const Feasible = preload("res://scripts/char/biography_feasibility.gd")
var provider: RefCounted
var owner: RefCounted
var acquisitions := 0

class FirstOutcome extends RefCounted:
	var logical_count := 0
	func bounded(_size: int) -> Dictionary:
		logical_count += 1
		return {"ok":true,"value":0}

class MissingDefinition extends RefCounted:
	var real: RefCounted
	var domain := "char.biography"
	var path := "books"
	func content_ticket() -> int: return real.content_ticket()
	func query(d: String, p: String, id: String) -> Dictionary:
		return {"ok":false,"kind":"missing","reason":"Controlled required definition absence."} if d == domain and p == path else real.query(d,p,id)
	func point_query(d: String, context: Dictionary) -> Dictionary:
		return {"ok":false,"kind":"missing","reason":"Controlled required mapping absence."} if d == domain else real.point_query(d,context)

func arithmetic() -> void:
	var formats = preload("res://scripts/data/actor_input_formats.gd")
	var effects: Array = []
	for command in ["0 +4","r0 +2","rf100 +7","RP +5","FT -5","RR -2","RD +1","MR +6","TH -3","#60001","!60002","?60003","AE M 8 12 +3","AF O 8 12 +1","GP +500"]: effects.append(formats.effect(command).value)
	var later: Array = []
	for command in ["0 -1","r0 +3","r1 -1","rf100 -2","RP +8","RR +4","GP -50","#60004"]: later.append(formats.effect(command).value)
	var template := {"backstory_text_id":60000,"questions":[{"id":"q1","answers":[{"id":"a","effects":effects}]},{"id":"q2","answers":[{"id":"a","effects":later}]}]}
	var state := {"template":"fixture","answers":{"q1":"a","q2":"a"},"outcomes":{},"names":{"bn":"Bert","fn":"Faye","mn":"Mark","imp":"Uriel"}}
	var texts := {}
	for id in [60000,60001,60002,60003,60004]: texts["text-"+str(id)] = {"available":true,"text":["%ra %hpn %hpw %bn %fn %mn %imp %q1 %q1a %q1b %q2 %r1 %r2 %r3 %r4 %r5","first","second","third","fourth"][id-60000]}
	var result: Dictionary = provider.Bio.evaluate(state,template,provider.biography_policy,texts,provider.skill_numbers,"breton")
	check("biography deterministic effect fixture evaluates",true,result.ok)
	if not result.ok: return
	check("biography skill effects add rather than replace",{"medical":3},result.skill_adjustments)
	check("biography social effects add",{"classic.social:0":5,"classic.social:1":-1},result.intent.social_additions)
	check("biography faction effects add",{"classic.faction:100":5},result.intent.faction_additions)
	check("biography all modifier kinds preserve last assignment",{"poison_modifier":8,"fatigue_modifier":-5,"reaction_modifier":4,"disease_modifier":1,"magic_modifier":6,"avoid_hit_modifier":-3},result.intent.modifiers_last_assignment)
	check("biography all supported context and narrative channels","Breton High Rock rolling hills Bert Faye Mark Uriel first second third fourth higher lower unchanged unchanged unchanged",result.backstory)
	check("biography AE AF are retained nonexecuting declarations",2,result.intent.nonexecuting_declarations.size())
	var gold: Array = []
	for obligation in result.intent.obligations:
		if obligation.effect.type == "gold_adjustment": gold.append(obligation.effect.parameters.amount)
	check("biography ordered signed gold intent retained",[500,-50],gold)
	check("biography candidate skill effects explicitly represented",true,result.intent.obligations.filter(func(obligation): return obligation.effect.type == "skill_adjustment").all(func(obligation): return obligation.represented_in_candidate))

func edit(section: String, value: Variant) -> Dictionary:
	return owner.edit(section,owner.token(),value)

func begin(id: String, method := "manual") -> void:
	owner.start()
	edit("race","breton"); edit("gender","female"); edit("class_method","list"); edit("class",id); edit("biography_method",method)

func operation(kind: String, payload: Dictionary = {}) -> Dictionary:
	return provider.biography_operation(owner,owner.token(),kind,payload)

func qualify(shell: Control) -> Array[Dictionary]:
	provider = Stock.new()
	provider.definitions = shell.controller.providers.definitions
	provider.content = provider.definitions.content_ticket()
	provider.options = provider.definitions.query("char.creation","flows","stock").record.value.choices
	var prepared: Dictionary = provider.prepare()
	check("biography real provider preparation",true,prepared.ok)
	if not prepared.ok: print("BIOGRAPHY PREPARE ",prepared); return checks
	var missing := MissingDefinition.new(); missing.real = provider.definitions
	var unavailable := Stock.new(); unavailable.definitions = missing; unavailable.content = provider.content
	check("biography required book preparation fails",false,unavailable.prepare().ok)
	var unavailable_owner := Draft.new(); unavailable_owner.bind(provider.content,unavailable.bindings()); unavailable_owner.start()
	check("biography unavailable provider fails actionably","unavailable",unavailable.biography_operation(unavailable_owner,unavailable_owner.token(),"initialize").kind)
	check("biography unavailable provider publishes no partial biography",false,unavailable_owner.projection().selections.has("biography"))
	unavailable_owner.dispose()
	missing = MissingDefinition.new(); missing.real = provider.definitions; missing.domain = "faction-quest.inputs"
	unavailable = Stock.new(); unavailable.definitions = missing; unavailable.content = provider.content
	check("biography required faction mapping preparation fails",false,unavailable.prepare().ok)
	missing = MissingDefinition.new(); missing.real = provider.definitions; missing.domain = "char.starting"; missing.path = "policy"
	unavailable = Stock.new(); unavailable.definitions = missing; unavailable.content = provider.content
	check("biography required starting preparation fails",false,unavailable.prepare().ok)
	unavailable_owner = Draft.new(); unavailable_owner.bind(provider.content,unavailable.bindings()); unavailable_owner.start()
	check("biography unavailable starting generation fails actionably","unavailable",unavailable.operate(unavailable_owner,unavailable_owner.token(),"generate-attributes").kind)
	unavailable_owner.dispose()
	var references: Array = preload("res://scripts/data/creation_biography.gd").new().validate_references({"char.biography:policy":{"records":{"stock":{"value":provider.biography_policy}}}})
	check("biography required book reference diagnosed before publication",true,not references.is_empty() and references[0].reason.contains("book metadata"))
	arithmetic()
	check("biography explicit available book baseline",90,provider.biography_policy.books.size())
	check("biography all baseline book sources qualified",90,provider.biography_books.size())
	for id in provider.biography_policy.books: check("biography book source "+str(id),true,provider.biography_books[str(id)].ok)
	var source := FirstOutcome.new()
	var book: Dictionary = provider.Bio.reward({"parameters":{"group":7,"index":0,"material":0}},provider.biography_items["7:0"],provider.biography_policy,source,provider.biography_books)
	check("biography retained first book identity",0,book.intent.book_id)
	check("biography independent seeded book price vector",580,book.intent.book_price)
	check("biography book identity and cover draw count",2,source.logical_count)
	check("biography exact random book outcome hidden",true,book.intent.hidden)
	var invalid_items: Dictionary = provider.biography_items.duplicate(true)
	invalid_items["7:0"].record.value.data.variants = 0
	check("biography invalid reward domain rejects template before sampling",false,provider.Bio.supported(provider.templates.biog00t0,provider.biography_texts,invalid_items,"text-4116",provider.biography_policy).ok)
	provider.generation_material = func(_operation: String):
		acquisitions += 1
		var material := PackedByteArray(); material.resize(32); material.fill(acquisitions%256)
		return {"ok":true,"material":material}
	owner = Draft.new(); owner.bind(provider.content,provider.bindings())
	var nonexecuting := 0
	for index in 18:
		var id := "class-%02d" % index
		var prefix := "biography "+id+" "
		begin(id)
		var generated := operation("initialize")
		check(prefix+"template initialized",true,generated.ok)
		if not generated.ok: print(prefix,generated); continue
		var value: Dictionary = owner.projection().selections.biography
		check(prefix+"explicit template mapping",provider.biography_policy.mappings[id][0],value.template)
		check(prefix+"manual starts unanswered",0,value.answers.size())
		check(prefix+"incomplete manual blocked",false,owner.section_status("biography").ok)
		var automatically := operation("automatic")
		check(prefix+"automatic answers",true,automatically.ok)
		if not automatically.ok: print(prefix,automatically); continue
		check(prefix+"real semantic completion",true,owner.section_status("biography").ok)
		value = owner.projection().selections.biography
		check(prefix+"one answer per question",provider.templates[value.template].questions.size(),value.answers.size())
		var history: String = owner.validate("biography",owner.token(),value).provenance.resolved_history
		check(prefix+"expanded readable history",true,history.length() > 100 and not history.contains("%q") and not history.contains("%ra"))
		var retained: Dictionary = value.duplicate(true)
		var calls := acquisitions
		operation("automatic"); operation("initialize"); owner.section_status("biography"); owner.section_status("biography")
		check(prefix+"navigation and repeated automatic preserve facts",retained,owner.projection().selections.biography)
		check(prefix+"queries and repeats consume no entropy",calls,acquisitions)
		for q in provider.templates[value.template].questions:
			for a in q.answers:
				var changed := operation("answer",{"question":q.id,"answer":a.id})
				check(prefix+q.id+"/"+a.id+" supported answer",true,changed.ok)
				if not changed.ok: print(prefix,q.id,"/",a.id," ",changed)
				for e in a.effects:
					if e.type in ["classic_ae_declaration","classic_af_declaration"]: nonexecuting += 1
		var old: Dictionary = owner.projection().selections.biography
		var forged: Dictionary = old.duplicate(true); forged.template = "unrelated"
		check(prefix+"forged template rejected",false,edit("biography",forged).ok)
		forged = old.duplicate(true); forged.skill_adjustments.medical = 999
		check(prefix+"forged effect rejected",false,edit("biography",forged).ok)
		check(prefix+"rejections preserve current state",old,owner.projection().selections.biography)
	check("biography AE AF retained baseline inventory",122,nonexecuting)
	var preset: Dictionary = provider.preset("class-00")
	var tied: Dictionary = provider._presets.duplicate(true)
	for id in tied: tied[id].tiers = preset.tiers.duplicate(true)
	check("biography affinity equal tier weights and explicit first tie","class-00",provider.Bio.affinity(preset.tiers,tied,provider.biography_policy.order).id)
	var unrelated := {"primary":["x1","x2","x3"],"major":["x4","x5","x6"],"minor":["x7","x8","x9","x10","x11","x12"]}
	check("biography no positive affinity rejects default",false,provider.Bio.affinity(unrelated,provider._presets,provider.biography_policy.order).ok)
	tied.erase("class-17")
	check("biography missing affinity preset fails",false,provider.Bio.affinity(preset.tiers,tied,provider.biography_policy.order).ok)
	check("biography unsupported macro fails",false,provider.Bio.expand("%unknown",{},{}).ok)
	check("biography required unavailable text fails",false,provider.Bio.expand("%q1",{"q1":4178},provider.biography_texts).ok)
	check("biography recursive macro fails",false,provider.Bio.expand("%loop",{"loop":1},{"text-1":{"available":true,"text":"%loop"}}).ok)
	var unsupported: Dictionary = provider.templates.biog00t0.duplicate(true)
	unsupported.questions[0].answers[0].effects.append({"type":"unknown_required"})
	check("biography unsupported required semantics fail",false,provider.Bio.supported(unsupported,provider.biography_texts,provider.biography_items,"text-4116").ok)
	var ranges: Dictionary = provider.starting.skills.duplicate(true)
	var first: String = preset.tiers.primary[0]
	var second: String = preset.tiers.primary[1]
	for id in preset.tiers.primary: ranges.limits[id].min = 28
	var targets := {}
	for target in provider.skill_numbers: targets[provider.skill_numbers[target]] = target
	var correlated := {"questions":[{"answers":[{"effects":[{"type":"skill_adjustment","target":targets[first],"parameters":{"amount":-6}}]},{"effects":[{"type":"skill_adjustment","target":targets[second],"parameters":{"amount":-6}}]}]}]}
	check("biography exact correlated feasibility avoids false interval rejection",true,Feasible.check(correlated,preset.tiers,ranges,provider.skill_numbers).ok)
	ranges.pools.primary = 5
	check("biography exact correlated feasibility rejects insufficient pool",false,Feasible.check(correlated,preset.tiers,ranges,provider.skill_numbers).ok)
	begin("class-00")
	operation("initialize")
	operation("answer",{"question":"q1","answer":"a"})
	edit("biography_method","automatic")
	check("biography automatic route fills remaining manual questions",true,operation("automatic").ok)
	check("biography automatic route preserves earlier manual answer","a",owner.projection().selections.biography.answers.q1)
	var route_state: Dictionary = owner.projection().selections.biography
	var route_calls := acquisitions
	edit("biography_method","manual"); edit("biography_method","automatic"); operation("automatic")
	check("biography method switching retains all resolved state",route_state,owner.projection().selections.biography)
	check("biography method switching consumes no entropy",route_calls,acquisitions)
	begin("class-00")
	operation("automatic")
	var selected: Dictionary = owner.projection().selections.biography
	var extended: Dictionary = provider.templates[selected.template].duplicate(true)
	extended.questions.append({"id":"q13","text":"An added chapter","answers":[{"id":"a","text":"A supported added answer","effects":[]}]})
	var extended_state := selected.duplicate(true); extended_state.answers.q13 = "a"
	var evaluated_extension: Dictionary = provider.Bio.evaluate(extended_state,extended,provider.biography_policy,provider.biography_texts,provider.skill_numbers,"breton")
	check("biography consumer supports more than twelve questions",true,evaluated_extension.ok and evaluated_extension.errors.is_empty())
	var random_question := ""; var random_answer := ""; var alternative := ""
	for q in provider.templates[selected.template].questions:
		for a in q.answers:
			for e in a.effects:
				if e.type == "item_grant" and e.parameters.group == 7:
					random_question = q.id; random_answer = a.id
		if q.id == random_question:
			for a in q.answers:
				if a.id != random_answer: alternative = a.id; break
	operation("answer",{"question":random_question,"answer":random_answer})
	var reward: Dictionary = owner.projection().selections.biography.outcomes.duplicate(true)
	operation("answer",{"question":random_question,"answer":alternative})
	check("biography inactive reward cache retained",reward,owner.projection().selections.biography.outcomes)
	operation("answer",{"question":random_question,"answer":random_answer})
	check("biography switching back restores exact reward",reward,owner.projection().selections.biography.outcomes)
	check("biography retained book identity present",true,reward.values().any(func(item): return item.has("book_id")))
	var attributes: Dictionary = provider.operate(owner,owner.token(),"generate-attributes")
	check("biography real attribute generation",true,attributes.ok)
	var skills: Dictionary = provider.operate(owner,owner.token(),"generate-skills")
	check("biography real skill generation",true,skills.ok)
	var previous_skills: Dictionary = owner.projection().selections.get("skills",{}).duplicate(true)
	var previous_bio: Dictionary = owner.projection().selections.biography.duplicate(true)
	provider.operate(owner,owner.token(),"reroll-attributes")
	check("biography attribute reroll isolates skills",previous_skills,owner.projection().selections.skills)
	check("biography attribute reroll isolates biography",previous_bio,owner.projection().selections.biography)
	var attribute_state: Dictionary = owner.projection().selections.attributes.duplicate(true)
	attribute_state.roll.allocated.strength = 2
	check("biography real partial attribute edit",true,edit("attributes",attribute_state).ok)
	check("biography real partial Save Roll",true,provider.operate(owner,owner.token(),"save-roll").ok)
	var saved: Dictionary = owner.projection().selections.attributes.duplicate(true)
	provider.operate(owner,owner.token(),"reroll-attributes")
	var calls := acquisitions
	check("biography real Load Roll",true,provider.operate(owner,owner.token(),"load-roll").ok)
	check("biography Load Roll exact whole-state restoration",saved,owner.projection().selections.attributes)
	check("biography Load Roll consumes no entropy",calls,acquisitions)
	var forged: Dictionary = saved.duplicate(true); forged.roll.base.strength += 1
	check("biography alternate input cannot forge attribute baseline",false,edit("attributes",forged).ok)
	var before_bio: Dictionary = owner.projection().selections.biography
	var before_skills: Dictionary = owner.projection().selections.skills
	edit("class","class-01")
	check("biography upstream career invalidates current facts",false,owner.projection().selections.has("biography"))
	check("biography upstream incompatible Load rejected",false,provider.operate(owner,owner.token(),"load-roll").ok)
	check("biography new context explicitly initializes",true,operation("automatic").ok)
	check("biography new context explicitly generates attributes",true,provider.operate(owner,owner.token(),"generate-attributes").ok)
	check("biography incompatible saved slot still rejected",false,provider.operate(owner,owner.token(),"load-roll").ok)
	edit("class","class-00")
	var no_draws := acquisitions
	check("biography compatible context restores",true,operation("initialize").ok)
	check("biography restored context retains exact outcome cache",before_bio,owner.projection().selections.biography)
	check("biography compatible skill context restores",true,provider.operate(owner,owner.token(),"generate-skills").ok)
	check("biography compatible skill context retains allocation",before_skills,owner.projection().selections.skills)
	check("biography compatible context restoration consumes no entropy",no_draws,acquisitions)
	owner.start()
	edit("race","argonian"); edit("gender","male"); edit("class_method","custom")
	var custom: Dictionary = provider.Custom.initial(provider.policy,owner.token().id+"/custom")
	custom.name = "Biography fixture"
	custom.tiers = provider.preset("class-00").tiers.duplicate(true)
	check("biography real custom career accepted",true,edit("custom",custom).ok)
	edit("biography_method","automatic")
	check("biography real custom automatic route",true,operation("automatic").ok)
	check("biography real custom affinity mapping","class-00",owner.projection().selections.get("biography",{}).get("context"))
	check("biography real custom attributes",true,provider.operate(owner,owner.token(),"generate-attributes").ok)
	check("biography real custom skills",true,provider.operate(owner,owner.token(),"generate-skills").ok)
	var previous_generator: Callable = provider.generation_material
	provider.generation_material = func(_operation: String):
		owner.discard()
		var material := PackedByteArray(); material.resize(32); material.fill(9)
		return {"ok":true,"material":material}
	check("biography interrupted entropy callback rejects stale result",false,provider.operate(owner,owner.token(),"reroll-attributes").ok)
	check("biography interrupted entropy callback leaves draft discarded",{},owner.projection())
	provider.generation_material = previous_generator
	var stale: Dictionary = owner.token(); owner.discard()
	check("biography stale generation cannot repopulate discarded draft",false,provider.biography_operation(owner,stale,"automatic").ok)
	check("biography discard clears all retained outcomes",{},owner.projection())
	provider.generation_material = Callable()
	owner.dispose()
	return checks
