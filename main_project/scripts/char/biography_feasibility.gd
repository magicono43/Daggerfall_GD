extends RefCounted
## Exact extrema over independent question choices, without enumerating their
## Cartesian product. max(sum(max(0,x_i))) = max over subsets of sum(x_i).
## Fixed 3/3/6 tiers require at most 64 subsets, regardless of question count.
const Rolls = preload("res://scripts/char/starting_rolls.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")

static func check(template: Dictionary, tiers: Dictionary, rules: Dictionary, skill_numbers: Dictionary) -> Dictionary:
	var member := Rolls.membership(tiers,rules.limits)
	if not member.ok: return member
	var questions: Array = []
	var low := {}; var high := {}
	for id in rules.limits: low[id] = 0; high[id] = 0
	for question in template.questions:
		var answers: Array = []
		for answer in question.answers:
			var changes := {}
			for effect in answer.effects:
				if effect.type != "skill_adjustment": continue
				var id: String = skill_numbers.get(effect.target,"")
				if id.is_empty() or not Rolls.number(effect.parameters.amount,-Rolls.LIMIT,Rolls.LIMIT): return Draft.failure("feasibility","Unsupported biography skill arithmetic.")
				changes[id] = changes.get(id,0)+effect.parameters.amount
			answers.append(changes)
		questions.append(answers)
		for id in low:
			var minimum := Rolls.LIMIT; var maximum := -Rolls.LIMIT
			for answer in answers:
				minimum = mini(minimum,answer.get(id,0)); maximum = maxi(maximum,answer.get(id,0))
			low[id] += minimum; high[id] += maximum
	for id in low:
		var tier: String = member.membership.get(id,"other")
		if rules.ranges[tier].max+high[id] > rules.limits[id].max: return Draft.failure("feasibility","A supported biography outcome exceeds the final cap: "+id)
		if tier == "other" and rules.ranges.other.min+low[id] < rules.limits[id].min: return Draft.failure("feasibility","A supported biography outcome cannot repair an other skill: "+id)
	for tier in Rolls.TIERS:
		var group: Array = tiers[tier]
		var maximum_required := 0
		for mask in (1 << group.size()):
			var constant := 0
			for index in group.size():
				if mask & (1 << index): constant += rules.limits[group[index]].min-rules.ranges[tier].min
			for answers in questions:
				var minimum := 9223372036854775807
				for answer in answers:
					var amount := 0
					for index in group.size():
						if mask & (1 << index): amount += answer.get(group[index],0)
					minimum = mini(minimum,amount)
				constant -= minimum
			maximum_required = maxi(maximum_required,constant)
		var minimum_capacity := 0
		for id in group: minimum_capacity += rules.limits[id].max-rules.ranges[tier].max
		for answers in questions:
			var maximum := -9223372036854775807
			for answer in answers:
				var amount := 0
				for id in group: amount += answer.get(id,0)
				maximum = maxi(maximum,amount)
			minimum_capacity -= maximum
		if maximum_required > rules.pools[tier] or minimum_capacity < rules.pools[tier]: return Draft.failure("feasibility","Not every biography/skill-roll outcome can allocate the "+tier+" pool.")
	return {"ok":true}
