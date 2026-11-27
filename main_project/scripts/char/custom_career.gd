extends RefCounted
## CHAR candidate evaluator. No live effect interfaces. Rebuild derived state from
## current IDs on every request; completion never trusts a displayed pool/gauge.
const F = preload("res://scripts/data/actor_input_formats.gd")
const ATTRIBUTES = ["strength","intelligence","willpower","agility","endurance","personality","speed","luck"]
const GROUPS = ["merchants","commoners","scholars","nobility","underworld"]
const COUNTS = {"primary":3,"major":3,"minor":6}

static func nonblank(value: String) -> bool:
	# Unicode White_Space, independently of the host's ASCII trim behavior.
	for index in value.length():
		var code := value.unicode_at(index)
		if code not in [9,10,11,12,13,32,133,160,5760,8232,8233,8239,8287,12288] and not (code >= 8192 and code <= 8202): return true
	return false

static func initial(policy: Dictionary, identity: String) -> Dictionary:
	var result := {"id":identity,"name":"","attributes":{},"tiers":{"primary":["","",""],"major":["","",""],"minor":["","","","","",""]},"traits":[],"hit_points_per_level":int(policy.hp.start),"reputation":{}}
	for key in ATTRIBUTES: result.attributes[key] = int(policy.attributes[key].start)
	for key in GROUPS: result.reputation[key] = int(policy.reputation[key].start)
	return result

static func conflict(policy: Dictionary, selected: Array, incoming: String) -> String:
	if not policy.traits.has(incoming): return "Unsupported option."
	var added: Dictionary = policy.traits[incoming]
	for id in selected:
		if not id is String or not policy.traits.has(id): return "Unsupported existing option."
		var old: Dictionary = policy.traits[id]
		if id == incoming: return "This option is already selected."
		if old.category == added.category and (added.singleton or old.singleton): return "Only one variant of "+str(added.category)+" is permitted."
		if not added.conflict.is_empty() and added.conflict == old.conflict and added.target == old.target and added.category != old.category: return "Conflicts with "+str(old.label)+". Remove it first."
	return ""

static func evaluate(value: Variant, policy: Dictionary, identity: String) -> Dictionary:
	if not value is Dictionary or value.size() != 7 or value.get("id") != identity or not value.get("name") is String or value.name.length() > 256 or not value.get("attributes") is Dictionary or not value.get("tiers") is Dictionary or not value.get("traits") is Array or not value.get("reputation") is Dictionary or not value.get("hit_points_per_level") is int:
		return {"ok":false,"reason":"Complete typed custom-career candidate required."}
	if value.attributes.size() != 8 or value.reputation.size() != 5 or value.tiers.size() != 3 or value.traits.size() > 90: return {"ok":false,"reason":"Unsupported custom-career fields."}
	var errors: Array = []
	if not nonblank(value.name): errors.append("Enter a nonblank custom-class name.")
	var total := 0
	for key in ATTRIBUTES:
		var number: Variant = value.attributes.get(key)
		if not number is int or not F.integer(number,0,1000000): return {"ok":false,"reason":"Exact supported integer attribute values required."}
		total += number
		if number < policy.attributes[key].min or number > policy.attributes[key].max: errors.append(key+" is outside its configured bounds.")
	var remaining := int(policy.attribute_total)-total
	if remaining != 0: errors.append("Attribute budget remaining: "+str(remaining))
	var seen: Array = []
	for tier in COUNTS:
		if not value.tiers.get(tier) is Array or value.tiers[tier].size() != COUNTS[tier]: return {"ok":false,"reason":"Exactly 3 Primary, 3 Major and 6 Minor slots required."}
		for skill in value.tiers[tier]:
			if not skill is String: return {"ok":false,"reason":"Stable skill IDs required."}
			if skill.is_empty(): errors.append("Fill every "+tier+" skill slot."); continue
			if not policy.skills.has(skill) or skill in seen: return {"ok":false,"reason":"Skills must be supported and distinct across all twelve slots."}
			seen.append(skill)
	var selected: Array = []
	var counts := {"advantage":0,"disadvantage":0}
	var cost := 0
	var contributions: Array = []
	var effects := {}
	for id in value.traits:
		if not id is String: return {"ok":false,"reason":"Stable option IDs required."}
		var reason := conflict(policy,selected,id)
		if not reason.is_empty(): return {"ok":false,"reason":reason}
		selected.append(id)
		var option: Dictionary = policy.traits[id]
		counts[option.side] += 1
		cost += int(option.cost)
		contributions.append({"id":id,"cost":int(option.cost)})
		effects[id] = {"category":option.category,"target":option.target} # Selection semantics only.
	for side in counts:
		if counts[side] > policy.limits[side]: return {"ok":false,"reason":"Too many "+side+" selections."}
	var hp: int = value.hit_points_per_level
	if not F.integer(hp,0,1000000): return {"ok":false,"reason":"Unsupported HP parameter."}
	if hp < policy.hp.min or hp > policy.hp.max: errors.append("HP per level is outside configured bounds.")
	var hp_cost := hp-int(policy.hp.start) if hp >= policy.hp.start else -2*(int(policy.hp.start)-hp)
	var difficulty := hp_cost+cost
	if difficulty < policy.difficulty.min or difficulty > policy.difficulty.max: errors.append("Difficulty is outside the legal range.")
	# Exact rational encoded as integers; draft facts prohibit floats.
	var width := int(policy.difficulty.max)-int(policy.difficulty.min)
	var advancement := {"numerator":int(policy.difficulty.low_milli)*width+(int(policy.difficulty.high_milli)-int(policy.difficulty.low_milli))*(difficulty-int(policy.difficulty.min)),"denominator":1000*width}
	var reputation_sum := 0
	for group in GROUPS:
		var number: Variant = value.reputation.get(group)
		if not number is int or not F.integer(number,-1000000,1000000): return {"ok":false,"reason":"Exact supported integer reputation required."}
		reputation_sum += number
		if number < policy.reputation[group].min or number > policy.reputation[group].max: errors.append(group+" reputation outside bounds.")
	var balance := int(policy.reputation_total)-reputation_sum
	if balance != 0: errors.append("Reputation balance remaining: "+str(balance))
	return {"ok":true,"errors":errors,"attribute_remaining":remaining,"reputation_remaining":balance,"hp_contribution":hp_cost,"contributions":contributions,"difficulty":difficulty,"advancement":advancement,"effects":effects}
