extends RefCounted
## Production race/career draft semantics over locked DATA. Later biography,
## portrait selection, starting rolls/allocations and fresh entry remain separate.
const Draft = preload("res://scripts/char/creation_draft.gd")
var definitions: RefCounted
var content := -1
var options: Dictionary = {}
var policy: Dictionary = {}
var sources: Dictionary = {}
var numeric: Dictionary = {}
var setup_error := ""
var _presets: Dictionary = {}
var _preset_choices: Array = []
var _policy_contributors: Array = []
var _source_contributors: Array = []
var _numeric_contributors: Array = []
var measurements := {}
const Custom = preload("res://scripts/char/custom_career.gd")
const Preset = preload("res://scripts/char/preset_career.gd")

func prepare() -> Dictionary:
	var started := Time.get_ticks_usec()
	_presets.clear()
	_preset_choices.clear()
	var read: Dictionary = definitions.query("char.career","policy","stock")
	if not read.ok: setup_error = read.get("reason","Creation policy unavailable."); return read
	policy = exact_numbers(read.record.value)
	_policy_contributors = exact_numbers(read.record.contributors)
	read = definitions.query("char.career","sources","stock")
	if not read.ok: setup_error = read.get("reason","Creation sources unavailable."); return read
	sources = exact_numbers(read.record.value)
	_source_contributors = exact_numbers(read.record.contributors)
	read = definitions.query("actor.baseline","policy","player")
	if not read.ok: setup_error = read.get("reason","CHAR numeric policy unavailable."); return read
	numeric = exact_numbers(read.record.value)
	_numeric_contributors = exact_numbers(read.record.contributors)
	for index in 18:
		var id := "class-%02d" % index
		read = definitions.query("actor.inputs","catalog",id)
		_presets[id] = Preset.resolve(exact_numbers(read.record.value.data),policy,numeric) if read.ok else read
		if read.ok: _presets[id].provenance = exact_numbers({"record":id,"input":read.record.value.get("input",{}),"contributors":read.record.contributors,"fields":read.record.fields})
		if read.ok: _preset_choices.append({"id":id,"label":str(read.record.value.data.name)})
	measurements.preparation_usec = Time.get_ticks_usec()-started
	return {"ok":true}

static func exact_numbers(value: Variant) -> Variant:
	# DATA schema validates integral JSON values before this narrow conversion.
	if value is float: return int(value) if is_finite(value) and value == floor(value) else value
	if value is Dictionary:
		var result := {}
		for key in value: result[key] = exact_numbers(value[key])
		return result
	if value is Array:
		var result: Array = []
		for child in value: result.append(exact_numbers(child))
		return result
	return value

func bindings() -> Dictionary:
	var result := {}
	for section in ["race","gender","class_method","questionnaire","class","custom","biography_method","name","reflexes"]:
		result[section] = {"id":("char.creation.career-v1/" if section in ["race","gender","class_method","questionnaire","class","custom"] else "char.creation.structural-v1/")+section,"validate":validate}
	return result

func choices(section: String) -> Array:
	if section == "race" and not policy.is_empty():
		var races: Array = []
		for id in policy.races: races.append({"id":id,"label":policy.races[id].label})
		return races
	if section == "class":
		if not _preset_choices.is_empty(): return _preset_choices.duplicate(true)
		var result: Array = []
		for index in 18:
			var id := "class-%02d" % index
			var read: Dictionary = definitions.query("actor.inputs","catalog",id)
			if read.ok: result.append({"id":id,"label":str(read.record.value.data.name)})
		return result
	return options.get(section,[]).duplicate(true)

func race_at(position: Vector2) -> String:
	if not position.is_finite() or sources.is_empty() or not sources.picker.ok or position.x < 0 or position.y < 0 or position.x >= 320 or position.y >= 200: return ""
	var number: int = sources.picker.indices[int(position.y)*320+int(position.x)]
	for id in policy.races:
		if policy.races[id].picker == number: return id
	return ""

func race_benefits(id: String) -> String:
	var ability: Dictionary = policy.races[id].abilities
	match ability.kind:
		"resistance": return str(ability.effect).capitalize()+" resistance flag. Resistance resolution and class stacking remain with their owners."
		"immunity": return str(ability.effect).capitalize()+" immunity flag. Class interactions remain with their owners."
		"weapon_modifiers": return "Hit and damage each gain floor(level / %d), with %s. Unarmed attacks are excluded." % [ability.divisor,str(ability.scope).replace("_"," ")]
		"effective_climbing": return "+%d effective Climbing before enhancement and clamping." % ability.bonus
		"swimming": return "Each breath decrement has a %d/%d chance of restoration. Failed-swimming-check fatigue exemption: %s. Ordinary swimming fatigue still applies. This is not water breathing." % [ability.breath_restore_numerator,ability.breath_restore_denominator,str(ability.failed_check_fatigue_exempt)]
	return "Required racial ability unavailable."

func description(id: String) -> Dictionary:
	if sources.is_empty() or policy.is_empty(): return Draft.failure("unavailable",setup_error)
	var number := int(policy.races[id].description) if policy.races.has(id) else 2100+int(id.trim_prefix("class-")) if _presets.has(id) else -1
	var result: Dictionary = sources.descriptions.get(str(number),{})
	return {"ok":true,"text":result.text} if result.get("ok",false) else Draft.failure("description",result.get("reason","Original description unavailable."))

func preset(id: String) -> Dictionary:
	return _presets.get(id,Draft.failure("definition","Preset definition unavailable.")).duplicate(true)

func custom_spell_points(value: Dictionary) -> Dictionary:
	return Preset.custom_multiplier(value,numeric)

func suggestion(value: Dictionary) -> Dictionary:
	if sources.is_empty() or not sources.questionnaire.ok: return Draft.failure("questionnaire",sources.get("questionnaire",{}).get("reason","Questionnaire unavailable; choose direct selection."))
	var scores := [0,0,0]
	if value.get("questions",[]).size() != 10 or value.get("answers",{}).size() != 10: return Draft.failure("incomplete","Answer all ten class questions.")
	for question in value.questions:
		var answer: Variant = value.answers.get(question)
		if not answer is int or answer < 0 or answer > 2: return Draft.failure("incomplete","Choose one of three answers for every question.")
		scores[int(policy.answer_categories[int(question.trim_prefix("question-"))][answer])] += 1
	var id: String = sources.questionnaire.results.get("%d/%d/%d" % scores,"")
	var career := preset(id)
	if not career.ok: return career
	return {"ok":true,"id":id,"scores":scores}

func validate(request: Dictionary) -> Dictionary:
	var section: String = request.section
	var value: Variant = request.draft.selections[section]
	if definitions.content_ticket() != content: return Draft.failure("stale","Creation content changed; reopen creation.")
	if section in ["race","gender","class","questionnaire","custom"]:
		return validate_career(request)
	if not value is String or value.is_empty(): return Draft.failure("invalid","Choose a valid "+section+".")
	var provenance := {"scope":"draft structure only; later feature semantic qualification pending","content":content}
	if section == "name":
		# Full grapheme, generation, glyph and control policy remains increment 4.
		if value.strip_edges().is_empty() or value.length() > 256: return Draft.failure("invalid","Enter a nonempty bounded name; full name qualification is pending.")
	else:
		var found := false
		for choice: Dictionary in choices(section):
			if choice.id == value: found = true; break
		if not found: return Draft.failure("definition","Selected creation definition is unavailable.")
		if section == "class":
			var read: Dictionary = definitions.query("actor.inputs","catalog",value)
			if not read.ok: return read
			provenance.definition = read.record
	var changed: bool = request.draft.selections.get(section) != value
	# Candidate includes the incoming value. Compare the previously retained
	# section context rather than relying on UI selection labels or list positions.
	var retained: Dictionary = request.retained.get(section,{})
	changed = retained.get("value") != value
	var invalidated: Array = []
	if changed:
		match section:
			"race", "gender": invalidated = ["face"]
			"class_method": invalidated = ["class","custom","questionnaire","biography","attributes","skills"]
			"class": invalidated = ["biography","attributes","skills"]
			"biography_method": invalidated = ["biography"]
	return {"ok":true,"value":value,"retained":{"value":value},"invalidate":invalidated,"provenance":provenance,"semantic_ready":section == "class_method","errors":[]}

func validate_career(request: Dictionary) -> Dictionary:
	if policy.is_empty() or sources.is_empty(): return Draft.failure("unavailable",setup_error if not setup_error.is_empty() else "Creation policy not prepared.")
	var section: String = request.section
	var selected: Dictionary = request.draft.selections
	var value: Variant = selected[section]
	var errors: Array = []
	var invalidated: Array = []
	var retained := {"value":value}
	var provenance := {"policy":"char.career:policy#stock","content":content,"policy_contributors":_policy_contributors.duplicate(true),"source_contributors":_source_contributors.duplicate(true),"sources":sources.provenance.duplicate(true),"scope":"Isolated creation semantics; live effect resolution and stacking deferred."}
	provenance.numeric_contributors = _numeric_contributors.duplicate(true)
	var changed: bool = not Draft.same_value(request.retained.get(section,{}).get("value"),value)
	match section:
		"race":
			if not value is String or not policy.races.has(value): return Draft.failure("race","Choose a supported birth race.")
			var text := description(value)
			if not text.ok: return text
			if not sources.picker.ok: return Draft.failure("map",sources.picker.reason)
			provenance.birth_race = value
			provenance.abilities = policy.races[value].abilities.duplicate(true)
			if changed: invalidated = ["face"]
		"gender":
			if value not in ["male","female"] or not policy.races.has(selected.get("race")): return Draft.failure("gender","Confirm race, then choose Male or Female.")
			provenance.birth_gender = value
			provenance.appearance = policy.races[selected.race].appearance[value].duplicate(true)
			for file in provenance.appearance.values():
				var source: Dictionary = sources.appearances.get(file,{})
				if not source.get("ok",false): return Draft.failure("appearance",source.get("reason","Required appearance mapping unavailable: "+str(file)))
			if changed: invalidated = ["face"]
		"class":
			if not value is String or not _presets.has(value) or selected.get("class_method") not in ["list","questionnaire"]: return Draft.failure("class","Choose a valid preset route and identity.")
			var career := preset(value)
			if not career.ok: return career
			var text := description(value)
			if not text.ok: return text
			if selected.class_method == "questionnaire":
				var recommended := suggestion(selected.get("questionnaire",{}))
				if not recommended.ok: return recommended
				if recommended.id != value: return Draft.failure("class","Confirm the actual questionnaire suggestion or choose direct selection.")
			provenance.resolved = career
			if changed: invalidated = ["biography","attributes","skills"]
		"questionnaire":
			if selected.get("class_method") != "questionnaire" or not value is Dictionary or value.size() != 2 or not value.get("questions") is Array or not value.get("answers") is Dictionary or value.questions != request.assigned_questions or value.questions.size() != 10: return Draft.failure("questionnaire","Use the CHAR-assigned retained question set.")
			if not sources.questionnaire.ok: return Draft.failure("questionnaire",sources.questionnaire.reason)
			for id in value.answers:
				if id not in value.questions or not value.answers[id] is int or value.answers[id] < 0 or value.answers[id] > 2: return Draft.failure("answer","Unsupported questionnaire answer.")
			retained = {"value":value.duplicate(true),"answers":value.answers.duplicate(true)}
			provenance.generation = request.question_generation
			if value.answers.size() != 10: errors.append("Answer all ten questions.")
			else:
				var recommended := suggestion(value)
				if not recommended.ok: return recommended
				provenance.suggestion = recommended
			if changed: invalidated = ["class","biography","attributes","skills"]
		"custom":
			if selected.get("class_method") != "custom": return Draft.failure("route","Choose the Custom route.")
			var evaluated := Custom.evaluate(value,policy,request.draft.id+"/custom")
			if not evaluated.ok: return Draft.failure("custom",evaluated.reason)
			errors = evaluated.errors
			provenance.evaluation = evaluated
			provenance.spell_points = custom_spell_points(value)
			if not provenance.spell_points.ok: return Draft.failure("numeric",provenance.spell_points.reason)
			if changed: invalidated = ["biography","attributes","skills"]
	return {"ok":true,"value":value,"retained":retained,"invalidate":invalidated,"provenance":provenance,"semantic_ready":true,"errors":errors}
