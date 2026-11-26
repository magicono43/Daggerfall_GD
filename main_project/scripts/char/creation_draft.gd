extends RefCounted
## Runtime-only CHAR authority. Providers validate detached candidates; no live actor
## or reward interface is available here. Navigation belongs to the UI consumer.
const SCHEMA = "creation-draft-v1"
const SECTIONS = ["race","gender","class_method","questionnaire","class","custom","biography_method","biography","name","face","attributes","skills","reflexes"]
const SUMMARY_EDITORS = ["name","face","attributes","skills","reflexes"]
var _serial := 0
var _submission_serial := 0
var _draft: Dictionary = {}
var _bindings: Dictionary = {}
var _content := -1
var _busy := false
var _captures: Dictionary = {}
var _capture_ids: Dictionary = {}
var _admitted: Dictionary = {}
var _requests: Dictionary = {}
var _retry_serial := 0
var _assigned_questions: Array = []
var _question_generation: Dictionary = {}
var questionnaire_material: Callable # Trusted deterministic fixture seam; OS entropy normally.

func bind(content: int, bindings: Dictionary) -> Dictionary:
	if not _draft.is_empty() or _busy or content < 0: return failure("binding", "Bind providers before opening a draft.")
	var checked := {}
	for section in bindings:
		var binding: Variant = bindings[section]
		if section not in SECTIONS or not binding is Dictionary or binding.size() != 2 or not binding.get("id") is String or binding.id.is_empty() or not binding.get("validate") is Callable or not binding.validate.is_valid(): return failure("binding", "A section requires its actual named validation provider.")
		checked[section] = binding.duplicate()
	_bindings = checked
	_content = content
	return {"ok":true}

func start() -> Dictionary:
	if _busy or _content < 0: return failure("busy", "Creation providers are not bound.")
	discard()
	_serial += 1
	_draft = {"schema":SCHEMA,"id":"creation-%d" % _serial,"revision":1,"content":_content,"selections":{},"validated":{},"retained":{},"invalidated":[]}
	return projection()

func discard() -> void:
	# May run reentrantly from a provider. Its returned work is rejected afterward.
	_draft.clear()
	_assigned_questions.clear()
	_question_generation.clear()
	for key: String in _captures.keys():
		if _admitted.get(_captures[key].draft.id) != _captures[key].id:
			_capture_ids.erase(_captures[key].id)
			_captures.erase(key)

func projection() -> Dictionary:
	return _draft.duplicate(true)

func token() -> Dictionary:
	return {} if _draft.is_empty() else {"id":_draft.id,"revision":_draft.revision,"content":_content}

func current(expected: Dictionary) -> bool:
	return not expected.is_empty() and same_value(expected,token())

static func failure(kind: String, reason: String) -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason}

static func plain(value: Variant, depth := 0) -> bool:
	if depth > 24: return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING: return true
		TYPE_ARRAY:
			if value.size() > 4096: return false
			for child in value:
				if not plain(child,depth+1): return false
			return true
		TYPE_DICTIONARY:
			if value.size() > 4096: return false
			for key in value:
				if typeof(key) not in [TYPE_STRING,TYPE_STRING_NAME] or not plain(value[key],depth+1): return false
			return true
	return false # Fractions, floats, objects, recursive/opaque values are not draft facts.

static func external_value(value: Variant) -> Variant:
	# CORE raw intents use String keys. Canonicalize GDScript's StringName dot
	# keys without a lossy JSON roundtrip that would turn integer facts to floats.
	if value is Dictionary:
		var result := {}
		for key in value: result[str(key)] = external_value(value[key])
		return result
	if value is Array:
		var result: Array = []
		for child in value: result.append(external_value(child))
		return result
	return value

static func same_value(left: Variant, right: Variant) -> bool:
	if typeof(left) != typeof(right): return false
	if left is Dictionary:
		if left.size() != right.size(): return false
		for key in left:
			if not right.has(key) or not same_value(left[key],right[key]): return false
		return true
	if left is Array:
		if left.size() != right.size(): return false
		for index in left.size():
			if not same_value(left[index],right[index]): return false
		return true
	return left == right

func validate(section: String, expected: Dictionary, value: Variant) -> Dictionary:
	if not current(expected): return failure("stale", "This creation view has retired.")
	if _busy: return failure("busy", "A creation provider is resolving this draft.")
	if not _bindings.has(section): return failure("unavailable", "Required creation validation is unavailable for " + section + ".")
	if not plain(value): return failure("invalid", "Creation input requires bounded exact value data.")
	_busy = true
	var candidate := projection()
	candidate.selections[section] = value.duplicate(true) if value is Dictionary or value is Array else value
	var checked: Variant = _bindings[section].validate.call({"schema":"creation-validation-v1","section":section,"draft":candidate,"retained":candidate.retained.duplicate(true),"assigned_questions":_assigned_questions.duplicate(),"question_generation":_question_generation.duplicate(true)})
	_busy = false
	if not current(expected): return failure("stale", "Creation changed during provider validation.")
	if not checked is Dictionary or not plain(checked) or typeof(checked.get("ok")) != TYPE_BOOL: return failure("provider", "Creation provider returned an invalid result.")
	if not checked.ok: return checked.duplicate(true)
	# Provider must explicitly return final facts, retained outcomes and dependent
	# invalidation. No generic UI flag can confer semantic readiness.
	if checked.size() != 7 or not checked.has("value") or not checked.get("retained") is Dictionary or not checked.get("invalidate") is Array or not checked.get("provenance") is Dictionary or checked.provenance.is_empty() or typeof(checked.get("semantic_ready")) != TYPE_BOOL or not checked.get("errors") is Array: return failure("provider", "Incomplete creation provider receipt.")
	for dependent in checked.invalidate:
		if dependent not in SECTIONS or dependent == section: return failure("provider", "Unsupported dependent invalidation.")
	return checked.duplicate(true)

func generate_questionnaire(expected: Dictionary) -> Dictionary:
	if not current(expected) or _busy: return failure("stale","Creation generation context retired.")
	if _draft.selections.get("class_method") != "questionnaire": return failure("route","Choose the questionnaire route first.")
	if _assigned_questions.is_empty():
		# Operation-local progression source; never acquire/reseed a gameplay session
		# source during pre-session creation. Same reviewed PCG/derivation/mapping.
		var seeds = preload("res://scripts/rule/seed_derivation.gd")
		_busy = true
		var supplied: Variant = seeds.material_from_os() if questionnaire_material.is_null() else questionnaire_material.call()
		_busy = false
		if not current(expected): return failure("stale","Creation retired during entropy acquisition.")
		if not supplied is Dictionary or not supplied.get("ok",false) or not seeds.validate_material(supplied.get("material")).ok: return failure("random","Questionnaire initialization material unavailable. Choose direct selection.")
		var derived: Dictionary = seeds.derive(supplied.material,"progression")
		if not derived.ok: return failure("random","Questionnaire random source unavailable. Choose direct selection.")
		var source: RefCounted = derived.source
		var questions: Array = []
		for index in 10:
			var draw: Dictionary = source.bounded(40)
			if not draw.ok: return failure("random","Questionnaire draw failed. Choose direct selection.")
			var number: int = draw.value
			while ("question-%02d" % number) in questions: number = (number+1)%40
			questions.append("question-%02d" % number)
		_assigned_questions = questions
		_question_generation = {"algorithm":"pcg32-xsh-rr-v1","derivation":"rpg-rng-v1/progression/independent-creation-operation","sampling":"dfu-collision-advance-v1/user-approved-2026-11-26","logical_draws":source.logical_count,"raw_draws":source.raw_count,"material_sha256":preload("res://scripts/data/actor_input_formats.gd").sha256(supplied.material)}
	var previous: Dictionary = _draft.retained.get("questionnaire",{})
	return edit("questionnaire",expected,{"questions":_assigned_questions.duplicate(),"answers":previous.get("answers",{}).duplicate(true)})

func edit(section: String, expected: Dictionary, value: Variant) -> Dictionary:
	if not current(expected): return failure("stale", "This creation view has retired.")
	if section not in SECTIONS: return failure("invalid", "Unknown creation section.")
	if not plain(value): return failure("invalid","Creation input requires bounded exact value data.")
	if _draft.selections.has(section) and same_value(_draft.selections[section],value): return {"ok":true,"kind":"unchanged","token":token()}
	var checked := validate(section,expected,value)
	if not checked.ok: return checked
	if _draft.revision >= 1000000000: return failure("overflow", "Creation revision exhausted; restart required.")
	var candidate := projection()
	for dependent in checked.invalidate:
		candidate.selections.erase(dependent)
		candidate.validated.erase(dependent)
	# Retained outcomes are keyed and owned by the bound section. Excluding an
	# answer does not erase its generated result; only discard clears this cache.
	candidate.retained[section] = checked.retained.duplicate(true)
	candidate.selections[section] = checked.value
	candidate.validated[section] = {"provider":_bindings[section].id,"semantic_ready":checked.semantic_ready,"provenance":checked.provenance,"errors":checked.errors}
	candidate.invalidated = checked.invalidate.duplicate()
	candidate.revision += 1
	_draft = candidate
	return {"ok":true,"kind":"changed","token":token(),"invalidated":checked.invalidate.duplicate()}

func section_status(section: String) -> Dictionary:
	if _draft.is_empty(): return failure("stale", "Creation draft unavailable.")
	if not _draft.selections.has(section): return failure("incomplete", "Complete " + section + ".")
	var checked := validate(section,token(),_draft.selections[section])
	if not checked.ok: return checked
	if checked.value != _draft.selections[section] or checked.retained != _draft.retained.get(section,{}): return failure("provider", "Validation attempted to change retained creation facts.")
	if not checked.errors.is_empty(): return failure("incomplete", str(checked.errors))
	return {"ok":true,"semantic_ready":checked.semantic_ready,"validation":{"provider":_bindings[section].id,"semantic_ready":checked.semantic_ready,"provenance":checked.provenance,"errors":checked.errors}}

func capture(expected: Dictionary, required: Array, route_receipt: Dictionary) -> Dictionary:
	if not current(expected): return failure("stale", "Creation draft changed before confirmation.")
	if _busy: return failure("busy", "Creation provider is resolving this draft.")
	if not plain(route_receipt) or route_receipt.get("schema") != "creation-route-receipt-v1": return failure("route", "Validated UI route receipt required.")
	# UI proves traversal; it cannot choose which CHAR facts count as complete.
	# Derive the required sections independently from the admitted branch facts.
	var class_method: Variant = _draft.selections.get("class_method")
	var biography_method: Variant = _draft.selections.get("biography_method")
	if class_method not in ["list","questionnaire","custom"] or biography_method not in ["manual","automatic"]: return failure("incomplete","Choose valid creation branches before confirmation.")
	var complete: Array = ["race","gender","class_method","biography_method","biography","name","face","attributes","skills","reflexes"]
	complete.append("custom" if class_method == "custom" else "class")
	if class_method == "questionnaire": complete.append("questionnaire")
	if required.size() != complete.size(): return failure("route","UI route omits required CHAR facts.")
	var seen := {}
	for section in required:
		if not section is String or section not in complete or seen.has(section): return failure("route","UI route duplicates or bypasses a required CHAR section.")
		seen[section] = true
	var errors := {}
	var current_validations := {}
	for section in required:
		if section not in SECTIONS: return failure("invalid", "Unsupported required creation section.")
		var checked := section_status(section)
		if checked.ok: current_validations[section] = checked.validation.duplicate(true)
		if not checked.ok or not checked.get("semantic_ready",false): errors[section] = checked.get("reason","Required real creation semantics are unavailable.")
		if not current(expected): return failure("stale", "Creation changed during final validation.")
	if not errors.is_empty(): return {"ok":false,"kind":"incomplete","reason":"Creation is incomplete.","sections":errors}
	var key := "%s/%d" % [_draft.id,_draft.revision]
	if not _captures.has(key):
		_submission_serial += 1
		var captured_draft := projection()
		captured_draft.validated = current_validations
		_captures[key] = external_value({"schema":"creation-submission-v1","id":"creation-submit-%d" % _submission_serial,"draft":captured_draft,"required":required.duplicate(),"route":route_receipt.duplicate(true)})
		_capture_ids[_captures[key].id] = key
	elif _captures[key].required != required or _captures[key].route != route_receipt:
		return failure("identity", "Changed route under an existing submission identity.")
	return {"ok":true,"capture":_captures[key].duplicate(true)}

func submit(core: RefCounted, capture_value: Dictionary) -> Dictionary:
	if not plain(capture_value) or not capture_value.get("id") is String or not _capture_ids.has(capture_value.id) or not same_value(_captures[_capture_ids[capture_value.id]],capture_value): return failure("identity", "Unknown or modified immutable creation submission.")
	var draft_id: String = capture_value.draft.id
	if _admitted.has(draft_id) and _admitted[draft_id] != capture_value.id: return failure("submitted","This draft already has an immutable submitted intent.")
	if not _admitted.has(draft_id) and (_draft.is_empty() or _draft.id != draft_id): return failure("stale","The creation draft has retired.")
	# CORE retains this exact request and owns busy, consent, cancellation, failure
	# and once-only admission. No actor/grant initialization is done by this owner.
	if not _requests.has(capture_value.id): _requests[capture_value.id] = {"id":capture_value.id,"mode":"new","origin":core.snapshot().session,"selection":{"creation":capture_value.duplicate(true)}}
	# Seal before invoking CORE: reentrant requests cannot switch the capture.
	_admitted[draft_id] = capture_value.id
	return core.request(_requests[capture_value.id].duplicate(true))

func retry(core: RefCounted, capture_value: Dictionary) -> Dictionary:
	if _admitted.get(capture_value.get("draft",{}).get("id","")) != capture_value.get("id") or not _requests.has(capture_value.id): return failure("identity","Retained submitted creation required for retry.")
	var original: Dictionary = _requests[capture_value.id]
	if not plain(capture_value) or not same_value(original.selection.creation,capture_value): return failure("identity","Captured retry input changed.")
	if core.busy(): return failure("busy","Another CORE operation is active.")
	var previous: Dictionary = core.request(original.duplicate(true))
	if previous.get("kind") != "Failed": return failure("retry","Only a terminal failed creation request can be explicitly retried.")
	if core.snapshot().session != original.origin: return failure("stale","Original replacement scope retired.")
	_retry_serial += 1
	var request := original.duplicate(true)
	request.id = capture_value.id+"/retry-%d" % _retry_serial
	_requests[capture_value.id] = request
	return core.request(request.duplicate(true))

func dispose() -> void:
	discard()
	_bindings.clear()
	_captures.clear()
	_capture_ids.clear()
	_admitted.clear()
	_requests.clear()
