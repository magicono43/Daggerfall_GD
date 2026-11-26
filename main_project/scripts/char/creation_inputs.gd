extends RefCounted
## Narrow real draft checks. This adapter does not certify reader-only careers,
## biography semantics, portrait resources, rolls, allocations or fresh entry.
const Draft = preload("res://scripts/char/creation_draft.gd")
var definitions: RefCounted
var content := -1
var options: Dictionary = {}

func bindings() -> Dictionary:
	var result := {}
	for section in ["race","gender","class_method","class","biography_method","name","reflexes"]:
		result[section] = {"id":"char.creation.structural-v1/"+section,"validate":validate}
	return result

func choices(section: String) -> Array:
	if section == "class":
		var result: Array = []
		for index in 18:
			var id := "class-%02d" % index
			var read: Dictionary = definitions.query("actor.inputs","catalog",id)
			if read.ok: result.append({"id":id,"label":str(read.record.value.data.name)})
		return result
	return options.get(section,[]).duplicate(true)

func validate(request: Dictionary) -> Dictionary:
	var section: String = request.section
	var value: Variant = request.draft.selections[section]
	if definitions.content_ticket() != content: return Draft.failure("stale","Creation content changed; reopen creation.")
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
	return {"ok":true,"value":value,"retained":{"value":value},"invalidate":invalidated,"provenance":provenance,"semantic_ready":false,"errors":[]}
