extends "res://tests/mod_cases.gd"
## Production arithmetic over real locked DATA; not biography/UI qualification.
const Rolls = preload("res://scripts/char/starting_rolls.gd")
const Stock = preload("res://scripts/char/creation_inputs.gd")

class Endpoints extends RefCounted:
	var maximum := false
	var count := 0
	func bounded(size: int) -> Dictionary:
		count += 1
		return {"ok":true,"value":size-1 if maximum else 0}

func qualify(shell: Control) -> Array[Dictionary]:
	var provider := Stock.new()
	provider.definitions = shell.controller.providers.definitions
	provider.content = provider.definitions.content_ticket()
	provider.prepare()
	var read: Dictionary = provider.definitions.query("char.starting","policy","stock")
	check("starting DATA policy published",true,read.ok)
	if not read.ok: return checks
	var p: Dictionary = Stock.exact_numbers(read.record.value)
	check("starting resolved policy domains","",Rolls.policy_reason(p,provider.numeric))
	for index in 18:
		var career: Dictionary = provider.preset("class-%02d" % index)
		career.attributes = Rolls.class_attributes(career.attributes)
		check("starting preset %02d all attribute outcomes" % index,true,Rolls.attribute_feasibility(career.attributes,p.attributes,provider.numeric).ok)
		check("starting preset %02d all skill outcomes" % index,true,Rolls.skill_feasibility(career.tiers,p.skills,{}).ok)
	var career: Dictionary = provider.preset("class-00")
	career.attributes = Rolls.class_attributes(career.attributes)
	var context := {"career":"class-00","base":career.attributes,"rules":p.attributes}
	var source := Endpoints.new()
	var rolled := Rolls.generate_attributes(career.attributes,p.attributes,provider.numeric,source,context)
	check("starting independent eight bonuses plus pool",9,source.count)
	check("starting lowest attribute pool",6,rolled.state.pool)
	for id in Rolls.Domain.ATTRIBUTES: check("starting lowest attribute "+id,career.attributes[id],rolled.state.base[id])
	var partial: Dictionary = rolled.state.duplicate(true)
	partial.allocated.strength = 2
	var slot: Dictionary = partial.duplicate(true)
	check("starting partial save validation",4,Rolls.attributes(partial,career.attributes,p.attributes,provider.numeric,context).remaining)
	source.maximum = true
	var rerolled := Rolls.generate_attributes(career.attributes,p.attributes,provider.numeric,source,context)
	check("starting reroll has separate complete draw set",18,source.count)
	check("starting highest attribute pool",14,rerolled.state.pool)
	for id in Rolls.Domain.ATTRIBUTES: check("starting highest attribute "+id,career.attributes[id]+10,rerolled.state.base[id])
	var loaded := Rolls.load_slot(slot,context,career.attributes,p.attributes,provider.numeric)
	check("starting partial load restores whole snapshot",slot,loaded.state)
	check("starting load has no draws",18,source.count)
	loaded.state.allocated.strength += 1
	check("starting slot detached from loaded allocation",2,slot.allocated.strength)
	check("starting incompatible load rejected",false,Rolls.load_slot(slot,{"career":"changed"},career.attributes,p.attributes,provider.numeric).ok)
	check("starting empty load rejected",false,Rolls.load_slot({},context,career.attributes,p.attributes,provider.numeric).ok)
	var forged: Dictionary = partial.duplicate(true)
	forged.allocated.strength = -1
	check("starting negative attribute allocation rejected",false,Rolls.attributes(forged,career.attributes,p.attributes,provider.numeric,context).ok)
	forged.allocated.strength = 7
	check("starting overspent attribute allocation rejected",false,Rolls.attributes(forged,career.attributes,p.attributes,provider.numeric,context).ok)
	forged.allocated.strength = 6
	check("starting full attribute allocation",true,Rolls.attributes(forged,career.attributes,p.attributes,provider.numeric,context).complete)
	forged.allocated.strength = 5
	check("starting refunded attribute incomplete",false,Rolls.attributes(forged,career.attributes,p.attributes,provider.numeric,context).complete)
	var impossible: Dictionary = p.attributes.duplicate(true)
	for id in impossible.values: impossible.values[id].cap = career.attributes[id]+10
	check("starting favorable roll cannot conceal impossible worst case",false,Rolls.attribute_feasibility(career.attributes,impossible,provider.numeric).ok)
	var skill_context := {"career":"class-00","tiers":career.tiers,"rules":p.skills}
	var skill_roll := Rolls.generate_skills(career.tiers,p.skills,{},source,skill_context)
	check("starting one independent draw per skill",18+p.skills.limits.size(),source.count)
	var state: Dictionary = skill_roll.state
	var member := Rolls.membership(career.tiers,p.skills.limits)
	for id in state.base: check("starting highest skill "+id,p.skills.ranges[member.membership.get(id,"other")].max,state.base[id])
	check("starting three untouched pools",p.skills.pools,Rolls.skills(state,career.tiers,p.skills,{},skill_context).remaining)
	for tier in Rolls.TIERS: state.allocated[career.tiers[tier][0]] = 6
	check("starting full isolated skill pools",true,Rolls.skills(state,career.tiers,p.skills,{},skill_context).complete)
	var beta := {}; beta[career.tiers.primary[0]] = 6
	var evaluated := Rolls.skills(state,career.tiers,p.skills,beta,skill_context)
	check("starting biography separately included",43,evaluated.final[career.tiers.primary[0]])
	check("starting biography did not redraw",18+p.skills.limits.size(),source.count)
	check("starting biography did not overwrite baseline",31,state.base[career.tiers.primary[0]])
	state.allocated[career.tiers.primary[0]] = 7
	check("starting skill cross pool borrowing rejected",false,Rolls.skills(state,career.tiers,p.skills,{},skill_context).ok)
	state.allocated[career.tiers.primary[0]] = 6
	var other := ""
	for id in state.base:
		if not member.membership.has(id): other = id; break
	state.allocated[other] = 1
	check("starting other skill allocation rejected",false,Rolls.skills(state,career.tiers,p.skills,{},skill_context).ok)
	state.allocated[other] = 0
	var invalid_beta := {}; invalid_beta[other] = -7
	check("starting other penalty all outcome failure",false,Rolls.skill_feasibility(career.tiers,p.skills,invalid_beta).ok)
	check("starting changed biography visibly invalid",false,Rolls.skills(state,career.tiers,p.skills,invalid_beta,skill_context).complete)
	invalid_beta = {}; invalid_beta[career.tiers.primary[0]] = 70
	check("starting excessive biography bonus rejected before generation",false,Rolls.skill_feasibility(career.tiers,p.skills,invalid_beta).ok)
	var altered: Dictionary = p.skills.duplicate(true)
	altered.ranges.primary = {"min":28,"max":100}
	check("starting sampled favorable skills cannot conceal impossible extremes",false,Rolls.skill_feasibility(career.tiers,altered,{}).ok)
	altered = p.skills.duplicate(true)
	altered.limits[career.tiers.primary[0]].min = 40
	check("starting negative capacity requires more than pool",false,Rolls.skill_feasibility(career.tiers,altered,{}).ok)
	check("starting repeated validation consumes no draws",18+p.skills.limits.size(),source.count)
	return checks
