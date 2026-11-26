extends "res://scripts/char/creation_inputs.gd"
## Deliberate generation and sealed starting-roll validation. Retained outcomes
## belong to the draft; UI can propose allocations but cannot author baselines.
const Rolls = preload("res://scripts/char/starting_rolls.gd")
var starting: Dictionary = {}
var starting_provenance: Array = []
var generation_material: Callable # Trusted test seam; called only for deliberate generation.
var _pending: Dictionary = {}
var _preview_owner: WeakRef
var _preview_core: WeakRef
var starting_ready := false

func bind_preview(owner: RefCounted, core: RefCounted) -> void:
	_preview_owner = weakref(owner)
	_preview_core = weakref(core)

func prepare() -> Dictionary:
	starting_ready = false
	var checked := super.prepare()
	if not checked.ok: return checked
	var read: Dictionary = definitions.query("char.starting","policy","stock")
	if not read.ok: return read
	starting = exact_numbers(read.record.value)
	starting_provenance = exact_numbers(read.record.contributors)
	var reason := Rolls.policy_reason(starting,numeric)
	starting_ready = reason.is_empty()
	if not starting_ready: setup_error = reason
	return {"ok":true} if reason.is_empty() else Draft.failure("starting_policy",reason)

func bindings() -> Dictionary:
	var result := super.bindings()
	for section in ["attributes","skills"]: result[section] = {"id":"char.creation.starting-v1/"+section,"validate":validate}
	return result

func career_context(draft: Dictionary, section: String) -> Dictionary:
	if not starting_ready: return Draft.failure("unavailable",setup_error if not setup_error.is_empty() else "Required starting rules are unavailable; reopen creation after content recovery.")
	var selected: Dictionary = draft.selections
	var career: Dictionary
	var identity: String
	if selected.get("class_method") == "custom":
		var value: Variant = selected.get("custom")
		if not value is Dictionary: return Draft.failure("career","Complete the career first.")
		var checked := Custom.evaluate(value,policy,draft.id+"/custom")
		if not checked.ok or not checked.errors.is_empty(): return Draft.failure("career","Complete a legal custom career first.")
		career = value
		identity = value.id
	else:
		identity = str(selected.get("class",""))
		career = preset(identity)
		if not career.ok: return career
	career.attributes = Rolls.class_attributes(career.attributes)
	var context := {"identity":identity,"content":content,"numeric":numeric.attributes if section == "attributes" else numeric.skills,"rules":starting.get(section,{})}
	context["class_base" if section == "attributes" else "tiers"] = career.attributes.duplicate(true) if section == "attributes" else career.tiers.duplicate(true)
	return {"ok":true,"context":context,"career":career}

func random_source(operation: String) -> Dictionary:
	var seeds = preload("res://scripts/rule/seed_derivation.gd")
	var supplied: Variant = seeds.material_from_os() if generation_material.is_null() else generation_material.call(operation)
	if not supplied is Dictionary or not supplied.get("ok",false) or not seeds.validate_material(supplied.get("material")).ok: return Draft.failure("random","Creation entropy unavailable; no default seed was substituted.")
	var derived: Dictionary = seeds.derive(supplied.material,"progression")
	if not derived.ok: return derived
	return {"ok":true,"source":derived.source,"receipt":{"operation":operation,"algorithm":"pcg32-xsh-rr-v1","derivation":"rpg-rng-v1/progression/independent-creation-operation","material_sha256":preload("res://scripts/data/actor_input_formats.gd").sha256(supplied.material)}}

func adjustments(draft: Dictionary) -> Dictionary:
	return draft.selections.get("biography",{}).get("skill_adjustments",{}).duplicate(true)

func publish_operation(owner: RefCounted, section: String, expected: Dictionary, value: Dictionary) -> Dictionary:
	_pending = {"section":section,"token":expected.duplicate(true),"value":value.duplicate(true)}
	var checked: Dictionary = owner.edit(section,expected,value)
	_pending.clear()
	return checked

func operate(owner: RefCounted, expected: Dictionary, operation: String) -> Dictionary:
	if not owner.current(expected) or not _pending.is_empty(): return Draft.failure("stale","Creation operation retired or busy.")
	var section := "skills" if operation == "generate-skills" else "attributes"
	if operation not in ["generate-attributes","reroll-attributes","save-roll","load-roll","generate-skills"]: return Draft.failure("operation","Unsupported creation generation operation.")
	var draft: Dictionary = owner.projection()
	var resolved := career_context(draft,section)
	if not resolved.ok: return resolved
	var old: Dictionary = draft.retained.get(section,{}).get("value",{})
	var value: Dictionary = old.duplicate(true)
	if operation in ["generate-attributes","generate-skills"] and not old.is_empty():
		if old.roll.context == resolved.context: return owner.edit(section,expected,old)
		for cached in draft.retained[section].get("contexts",[]):
			if cached.roll.context == resolved.context:
				value = cached.duplicate(true)
				value.slot = old.get("slot",{}).duplicate(true)
				return publish_operation(owner,section,expected,value)
	if operation in ["save-roll","load-roll"]:
		if old.is_empty(): return Draft.failure("empty","Generate attributes before saving or loading a roll.")
		if operation == "save-roll": value.slot = {"roll":old.roll.duplicate(true),"generation":old.generation.duplicate(true)}
		else:
			var loaded := Rolls.load_slot(old.slot.get("roll"),resolved.context,resolved.career.attributes,starting.attributes,numeric)
			if not loaded.ok: return loaded
			value.roll = loaded.state; value.generation = old.slot.generation.duplicate(true)
	else:
		var random := random_source(operation)
		if not random.ok: return random
		if not owner.current(expected): return Draft.failure("stale","Creation retired during entropy acquisition.")
		var rolled: Dictionary = Rolls.generate_skills(resolved.career.tiers,starting.skills,adjustments(draft),random.source,resolved.context) if section == "skills" else Rolls.generate_attributes(resolved.career.attributes,starting.attributes,numeric,random.source,resolved.context)
		if not rolled.ok: return rolled
		random.receipt.logical_draws = random.source.logical_count
		random.receipt.raw_draws = random.source.raw_count
		value = {"roll":rolled.state,"generation":random.receipt,"slot":old.get("slot",{}).duplicate(true)}
	return publish_operation(owner,section,expected,value)

func validate(request: Dictionary) -> Dictionary:
	if request.section not in ["attributes","skills"]: return super.validate(request)
	if definitions.content_ticket() != content or starting.is_empty(): return Draft.failure("stale","Starting rules unavailable or retired.")
	var section: String = request.section
	var value: Variant = request.draft.selections[section]
	if not value is Dictionary or value.size() != 3 or not value.get("roll") is Dictionary or not value.get("slot") is Dictionary or not value.get("generation") is Dictionary: return Draft.failure("roll","Complete owner-generated roll required.")
	var resolved := career_context(request.draft,section)
	if not resolved.ok: return resolved
	var retained: Dictionary = request.retained.get(section,{}).get("value",{})
	var authorized: bool = _pending.get("section") == section and _pending.get("value") == value and _pending.get("token") == {"id":request.draft.id,"revision":request.draft.revision,"content":content}
	if not authorized:
		if retained.is_empty(): return Draft.failure("generation","Generate starting values through CHAR first.")
		var immutable: Dictionary = value.duplicate(true)
		immutable.roll.allocated = retained.roll.allocated.duplicate(true)
		if not Draft.same_value(immutable,retained): return Draft.failure("forged_roll","Only allocations may be edited; baseline, pool, slot and RNG provenance are CHAR-owned.")
	var evaluated: Dictionary = Rolls.attributes(value.roll,resolved.career.attributes,starting.attributes,numeric,resolved.context) if section == "attributes" else Rolls.skills(value.roll,resolved.career.tiers,starting.skills,adjustments(request.draft),resolved.context)
	if not evaluated.ok: return evaluated
	var errors: Array = evaluated.get("errors",[]).duplicate()
	if section == "attributes":
		var owner: RefCounted = _preview_owner.get_ref() if _preview_owner != null else null
		var core: RefCounted = _preview_core.get_ref() if _preview_core != null else null
		var multiplier: Dictionary = custom_spell_points(resolved.career) if request.draft.selections.get("class_method") == "custom" else resolved.career.spell_points
		var ratio := {"numerator":multiplier.get("numerator",-1),"denominator":multiplier.get("denominator",0)}
		var preview: Dictionary = owner.attribute_preview(core,owner.token(),evaluated.final,ratio) if owner != null and core != null else Draft.failure("preview","Required derived-stat preview owner is unavailable.")
		if preview.ok: evaluated.derived = preview.values
		else: errors.append(preview.reason)
	if not evaluated.complete: errors.append("Allocate the complete "+section+" pool within the final limits.")
	var contexts: Array = request.retained.get(section,{}).get("contexts",[]).duplicate(true)
	for candidate in [retained,value]:
		if candidate.is_empty(): continue
		var replaced := false
		for index in contexts.size():
			if contexts[index].roll.context == candidate.roll.context: contexts[index] = candidate.duplicate(true); replaced = true; break
		if not replaced: contexts.append(candidate.duplicate(true))
	return {"ok":true,"value":value,"retained":{"value":value.duplicate(true),"contexts":contexts},"invalidate":[],"provenance":{"policy":"char.starting:policy#stock","contributors":starting_provenance,"evaluation":evaluated,"biography_representation":"Skill baselines and allocations exclude biography; final preview includes its adjustment. Apply biography once before progression baseline capture."},"semantic_ready":true,"errors":errors}
