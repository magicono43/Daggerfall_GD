extends RefCounted
## Explicit assigned-input qualification, never selected in normal New Game.
const Draft = preload("res://scripts/char/creation_draft.gd")
var fixture: Dictionary
var variant := "preset"
var callbacks := 0
var draws := 0
var during_validation := Callable()

func _init() -> void:
	fixture = assigned(JSON.parse_string(FileAccess.get_file_as_string("res://tests/creation_fixture.json")))

static func assigned(value: Variant) -> Variant:
	# The pinned fixture declares integer numeric inputs. JSON transports numbers
	# as floats; normalize only this trusted file, never runtime test/user edits.
	if value is float:
		assert(is_finite(value) and value == floor(value) and abs(value) < 1000000000)
		return int(value)
	if value is Dictionary:
		for key in value: value[key] = assigned(value[key])
	elif value is Array:
		for index in value.size(): value[index] = assigned(value[index])
	return value

func bindings() -> Dictionary:
	var result := {}
	for section in Draft.SECTIONS: result[section] = {"id":"controlled.creation-assigned-v1/"+section,"validate":validate}
	return result

func choices(section: String) -> Array:
	var result: Array = []
	for value in fixture.allowed.get(section,[]):
		result.append({"id":value.get("id","assigned."+section) if value is Dictionary else value,"value":value,"label":"Use assigned "+section+" fixture" if value is Dictionary or value is Array else str(value)})
	if result.is_empty() and fixture[variant].has(section): result.append({"id":"assigned."+section,"value":fixture[variant][section],"label":"Use assigned "+section+" fixture"})
	return result

func validate(request: Dictionary) -> Dictionary:
	callbacks += 1
	if during_validation.is_valid(): during_validation.call()
	var section: String = request.section
	var value: Variant = request.draft.selections[section]
	var retained: Dictionary = request.retained.get(section,{}).duplicate(true)
	var invalidated: Array = []
	if section == "name":
		if not value is String or value.is_empty() or value.length() > 31: return Draft.failure("invalid","Controlled fixture name is 1..31 characters.")
	elif section in ["attributes","skills"]:
		if not value is Dictionary or value.size() != 4 or value.get("schema") != "assigned-creation-allocation-v1" or not value.get("base") is Dictionary or not value.get("allocated") is Dictionary or not value.get("remaining") is int or value.remaining < 0 or value.remaining > 100: return Draft.failure("invalid","Exact assigned allocation fields required.")
		for values: Dictionary in [value.base,value.allocated]:
			for key in values:
				if not values[key] is int or values[key] < 0 or values[key] > 100: return Draft.failure("invalid","Integer allocation out of range.")
		if value.base != fixture[variant][section].base: return Draft.failure("invalid","Changed assigned roll context.")
	elif section == "biography":
		if not value is Dictionary or (value != fixture[variant].biography and value != fixture.biography_alternative): return Draft.failure("invalid","Explicit assigned biography required.")
	elif not fixture.allowed.get(section,[]).has(value): return Draft.failure("definition","Unknown controlled definition.")
	var previous: Variant = retained.get("value")
	if previous != value:
		match section:
			"race","gender": invalidated = ["face"]
			"class_method": invalidated = ["questionnaire","class","custom","biography","attributes","skills"]
			"class","custom": invalidated = ["biography","attributes","skills"]
			"biography_method": invalidated = ["biography"]
	retained.value = value.duplicate(true) if value is Dictionary or value is Array else value
	# Assigned outcomes, explicitly no RNG request. Navigation retains them.
	if section == "biography":
		if not retained.has("outcomes"): retained.outcomes = {}
		retained.outcomes.merge(value.outcomes.duplicate(true))
	var errors: Array = []
	if section in ["attributes","skills"] and value.remaining != 0: errors.append("Unspent allocation points: "+str(value.remaining))
	return {"ok":true,"value":value,"retained":retained,"invalidate":invalidated,"provenance":{"fixture":"creation-draft-v1","variant":variant,"provider":"controlled assigned inputs; not real creation semantics"},"semantic_ready":true,"errors":errors}
