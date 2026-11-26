extends RefCounted
## Pure CHAR creation arithmetic. Generation receives an operation-local bounded
## source; inspection, feasibility, allocation and snapshot checks never draw.
const Domain = preload("res://scripts/data/actor_baseline.gd")
const F = preload("res://scripts/rule/actor_formulas.gd")
const TIERS = ["primary","major","minor"]
const COUNTS = {"primary":3,"major":3,"minor":6}
const LIMIT = 1000000

static func class_attributes(value: Variant) -> Dictionary:
	if value is Dictionary: return value.duplicate(true)
	var result := {}
	if value is Array and value.size() == Domain.ATTRIBUTES.size():
		for index in Domain.ATTRIBUTES.size(): result[Domain.ATTRIBUTES[index]] = value[index]
	return result

static func fail(reason: String) -> Dictionary:
	return {"ok":false,"kind":"starting_rolls","reason":reason}

static func number(value: Variant, low := 0, high := LIMIT) -> bool:
	return typeof(value) == TYPE_INT and value >= low and value <= high

static func bounds(value: Variant, low := 0, high := LIMIT) -> bool:
	return value is Dictionary and value.size() == 2 and number(value.get("min"),low,high) and number(value.get("max"),low,high) and value.min <= value.max

static func membership(tiers: Variant, skills: Dictionary) -> Dictionary:
	if not tiers is Dictionary or tiers.size() != 3: return fail("Three complete skill tiers required.")
	var by_skill := {}
	for tier in TIERS:
		if not tiers.get(tier) is Array or tiers[tier].size() != COUNTS[tier]: return fail("Skill tiers require 3/3/6 identities.")
		for id in tiers[tier]:
			if not id is String or not skills.has(id) or by_skill.has(id): return fail("Tier skills must be supported and distinct.")
			by_skill[id] = tier
	return {"ok":true,"membership":by_skill}

static func policy_reason(p: Variant, numeric: Dictionary) -> String:
	if not p is Dictionary or p.size() != 4 or p.get("schema") != "creation-starting-v1" or not p.get("attributes") is Dictionary or not p.get("skills") is Dictionary or not p.get("provenance") is Dictionary or p.provenance.is_empty(): return "Complete starting policy required."
	var a: Dictionary = p.attributes
	if a.size() != 2 or not a.get("values") is Dictionary or a.values.size() != Domain.ATTRIBUTES.size() or not bounds(a.get("pool")): return "Eight attribute bounds and a pool range required."
	for id in Domain.ATTRIBUTES:
		var rule: Variant = a.values.get(id)
		var domain: Variant = numeric.get("attributes",{}).get(id)
		if not rule is Dictionary or rule.size() != 2 or not bounds(rule.get("bonus")) or not number(rule.get("cap")) or not domain is Dictionary or rule.cap > domain.max: return "Attribute bonus/cap exceeds CHAR permanent domain: "+id
	var s: Dictionary = p.skills
	if s.size() != 3 or not s.get("ranges") is Dictionary or s.ranges.size() != 4 or not s.get("pools") is Dictionary or s.pools.size() != 3 or not s.get("limits") is Dictionary or s.limits.size() != numeric.get("skills",{}).size(): return "Complete skill ranges, pools and limits required."
	for tier in TIERS+["other"]:
		if not bounds(s.ranges.get(tier)): return "Invalid skill range: "+tier
		if tier != "other" and not number(s.pools.get(tier)): return "Invalid skill pool: "+tier
	for id in numeric.skills:
		var limit: Variant = s.limits.get(id)
		if not bounds(limit) or limit.min < numeric.skills[id].min or limit.max > numeric.skills[id].max: return "Creation skill limits exceed CHAR permanent domain: "+id
	return ""

static func attribute_feasibility(base: Dictionary, rules: Dictionary, numeric: Dictionary) -> Dictionary:
	if base.size() != Domain.ATTRIBUTES.size(): return fail("Eight actual class bases required.")
	var capacity := 0
	for id in Domain.ATTRIBUTES:
		if not number(base.get(id)): return fail("Exact class attribute required: "+id)
		var rule: Dictionary = rules.values[id]
		if base[id]+rule.bonus.min < numeric.attributes[id].min or base[id]+rule.bonus.max > rule.cap: return fail("Some attribute rolls exceed the creation domain: "+id)
		capacity += rule.cap-base[id]-rule.bonus.max
	if capacity < rules.pool.max: return fail("Highest simultaneous attribute rolls cannot spend the largest pool.")
	return {"ok":true,"minimum_capacity":capacity}

static func skill_feasibility(tiers: Dictionary, rules: Dictionary, beta: Dictionary) -> Dictionary:
	var member := membership(tiers,rules.limits)
	if not member.ok: return member
	for id in beta:
		if not rules.limits.has(id) or not number(beta[id],-LIMIT,LIMIT): return fail("Unsupported biography skill adjustment: "+str(id))
	var required := {"primary":0,"major":0,"minor":0}
	var capacity := required.duplicate()
	for id in rules.limits:
		var tier: String = member.membership.get(id,"other")
		var range_rule: Dictionary = rules.ranges[tier]
		var limit: Dictionary = rules.limits[id]
		var low: int = range_rule.min+beta.get(id,0)
		var high: int = range_rule.max+beta.get(id,0)
		if high > limit.max: return fail("Some skill rolls exceed the final cap: "+id)
		if tier == "other":
			if low < limit.min: return fail("An other skill cannot repair its biography penalty: "+id)
		else:
			# Independent extrema prove all combinations, rather than sampling one.
			required[tier] += maxi(0,limit.min-low)
			capacity[tier] += limit.max-high
	for tier in TIERS:
		if required[tier] > rules.pools[tier] or capacity[tier] < rules.pools[tier]: return fail("Not every skill outcome can allocate the "+tier+" pool.")
	return {"ok":true,"maximum_required":required,"minimum_capacity":capacity}

static func draw(source: RefCounted, range_rule: Dictionary) -> Dictionary:
	var result: Dictionary = source.bounded(range_rule.max-range_rule.min+1)
	return {"ok":true,"value":range_rule.min+result.value} if result.ok else result

static func generate_attributes(base: Dictionary, rules: Dictionary, numeric: Dictionary, source: RefCounted, context: Dictionary) -> Dictionary:
	var checked := attribute_feasibility(base,rules,numeric)
	if not checked.ok: return checked
	var rolled := {}
	var allocated := {}
	for id in Domain.ATTRIBUTES:
		var outcome := draw(source,rules.values[id].bonus)
		if not outcome.ok: return outcome
		rolled[id] = base[id]+outcome.value
		allocated[id] = 0
	var pool := draw(source,rules.pool)
	if not pool.ok: return pool
	return {"ok":true,"state":{"context":context.duplicate(true),"base":rolled,"allocated":allocated,"pool":pool.value}}

static func generate_skills(tiers: Dictionary, rules: Dictionary, beta: Dictionary, source: RefCounted, context: Dictionary) -> Dictionary:
	var checked := skill_feasibility(tiers,rules,beta)
	if not checked.ok: return checked
	var member := membership(tiers,rules.limits)
	var rolled := {}
	var allocated := {}
	# Stable ordering means dictionary/display reordering cannot redirect draws.
	var identities: Array = rules.limits.keys(); identities.sort()
	for id in identities:
		var outcome := draw(source,rules.ranges[member.membership.get(id,"other")])
		if not outcome.ok: return outcome
		rolled[id] = outcome.value
		allocated[id] = 0
	return {"ok":true,"state":{"context":context.duplicate(true),"base":rolled,"allocated":allocated,"pools":rules.pools.duplicate(true)}}

static func attributes(state: Variant, base: Dictionary, rules: Dictionary, numeric: Dictionary, context: Dictionary) -> Dictionary:
	if not state is Dictionary or state.size() != 4 or state.get("context") != context or not state.get("base") is Dictionary or not state.get("allocated") is Dictionary or state.base.size() != 8 or state.allocated.size() != 8 or not number(state.get("pool"),rules.pool.min,rules.pool.max): return fail("Complete compatible attribute roll required.")
	var spent := 0
	var final_values := {}
	for id in Domain.ATTRIBUTES:
		if not number(state.base.get(id),base[id]+rules.values[id].bonus.min,base[id]+rules.values[id].bonus.max) or not number(state.allocated.get(id)): return fail("Invalid attribute baseline/allocation: "+id)
		final_values[id] = state.base[id]+state.allocated[id]
		if final_values[id] > rules.values[id].cap or final_values[id] < numeric.attributes[id].min: return fail("Attribute is outside creation bounds: "+id)
		spent += state.allocated[id]
	if spent > state.pool: return fail("Attribute allocation exceeds its original pool.")
	return {"ok":true,"remaining":state.pool-spent,"final":final_values,"complete":spent == state.pool}

static func skills(state: Variant, tiers: Dictionary, rules: Dictionary, beta: Dictionary, context: Dictionary) -> Dictionary:
	var member := membership(tiers,rules.limits)
	if not member.ok: return member
	if not state is Dictionary or state.size() != 4 or state.get("context") != context or not state.get("base") is Dictionary or not state.get("allocated") is Dictionary or state.base.size() != rules.limits.size() or state.allocated.size() != rules.limits.size() or state.get("pools") != rules.pools: return fail("Complete compatible skill roll required.")
	var remaining: Dictionary = rules.pools.duplicate()
	var final_values := {}
	var errors: Array = []
	for id in rules.limits:
		var tier: String = member.membership.get(id,"other")
		var range_rule: Dictionary = rules.ranges[tier]
		if not number(state.base.get(id),range_rule.min,range_rule.max) or not number(state.allocated.get(id)): return fail("Invalid skill baseline/allocation: "+id)
		if tier == "other" and state.allocated[id] != 0: return fail("Other skills cannot spend tier points.")
		if tier != "other": remaining[tier] -= state.allocated[id]
		final_values[id] = state.base[id]+state.allocated[id]+beta.get(id,0)
		if final_values[id] < rules.limits[id].min or final_values[id] > rules.limits[id].max: errors.append("Final skill outside creation bounds: "+id)
	var complete := errors.is_empty()
	for tier in TIERS:
		if remaining[tier] < 0: return fail("Skill allocation exceeds its original "+tier+" pool.")
		complete = complete and remaining[tier] == 0
	return {"ok":true,"remaining":remaining,"final":final_values,"errors":errors,"complete":complete}

static func load_slot(slot: Variant, context: Dictionary, base: Dictionary, rules: Dictionary, numeric: Dictionary) -> Dictionary:
	var checked := attributes(slot,base,rules,numeric,context)
	if not checked.ok: return fail("Saved roll is empty or incompatible: "+checked.reason)
	return {"ok":true,"state":slot.duplicate(true)}
