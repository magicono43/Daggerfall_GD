extends "res://scripts/char/creation_biography_inputs.gd"
const Name = preload("res://scripts/ui/character_name.gd")
const Reflex = preload("res://scripts/char/reflex_parameters.gd")
var identity: Dictionary = {}
var identity_provenance: Array = []
var identity_record: Dictionary = {}
var art: RefCounted
var name_material: Callable
var _name_pending: Dictionary = {}
var _naming_busy := false

func prepare() -> Dictionary:
	var checked := super.prepare()
	if not checked.ok: return checked
	return prepare_identity()

func prepare_identity() -> Dictionary:
	var read: Dictionary = definitions.query("char.identity","policy","stock")
	if not read.ok: return read
	identity = exact_numbers(read.record.value)
	identity_provenance = exact_numbers(read.record.contributors)
	identity_record = exact_numbers({"identity":read.record.identity,"winner":read.record.winner,"fields":read.record.fields})
	return {"ok":true}

func bindings() -> Dictionary:
	var result := super.bindings()
	for section in ["name","face","reflexes"]: result[section] = {"id":"char.creation.identity-v1/"+section,"validate":validate}
	return result

func initialize_draft(owner: RefCounted) -> Dictionary:
	# A fresh-draft default is validated normally; invalid policy never recovers
	# by substituting Average later during selection, capture or restoration.
	return owner.edit("reflexes",owner.token(),"average")

func choices(section: String) -> Array:
	if section != "reflexes": return super.choices(section)
	var result: Array = []
	for id in Reflex.IDS:
		if identity.get("reflexes",{}).has(id): result.append({"id":id,"label":identity.reflexes[id].label})
	return result

func face_set(selected: Dictionary) -> Dictionary:
	var mapping: Dictionary = identity.get("mappings",{}).get(str(selected.get("race",""))+"/"+str(selected.get("gender","")),{})
	var id: String = mapping.get("portraits","")
	return {"id":id,"faces":identity.get("portraits",{}).get(id,[]).duplicate(true)}

func portrait(value: Dictionary) -> Dictionary:
	if art == null: return Draft.failure("portrait","Portrait image owner unavailable.")
	for face in identity.get("portraits",{}).get(value.get("set"),[]):
		if face.id == value.get("id"): return art.resolve(face.target)
	return Draft.failure("portrait","Portrait identity missing; choose an explicit compatible replacement.")

func cycle_face(owner: RefCounted, expected: Dictionary, direction: int) -> Dictionary:
	if not owner.current(expected) or direction not in [-1,1]: return Draft.failure("stale","Portrait input retired.")
	var selected: Dictionary = owner.projection().selections
	var set := face_set(selected)
	if set.faces.is_empty(): return Draft.failure("portrait","No compatible portraits are available.")
	var current: Dictionary = selected.get("face",{})
	var current_image: Dictionary = portrait(current) if not current.is_empty() else {}
	var index := -1
	for n in set.faces.size():
		if current.get("set") == set.id and current.get("id") == set.faces[n].id: index = n; break
	index = (index+direction+set.faces.size())%set.faces.size() if index >= 0 else (0 if direction > 0 else set.faces.size()-1)
	# A deliberate browse action walks valid images, including when no face was
	# selected yet. Failed first/last images must not trap the selector forever.
	for attempt in set.faces.size():
		var candidate := {"set":set.id,"id":set.faces[index].id}
		var image := portrait(candidate)
		if image.ok:
			# Preserve IDs and mod replacements, but skip identical resolved artwork
			# while browsing (classic Nord female records 0/1 are duplicates).
			if candidate != current and not current_image.get("pixel_hash","").is_empty() and image.get("pixel_hash") == current_image.pixel_hash and image.get("pixel_size") == current_image.get("pixel_size"):
				index = (index+direction+set.faces.size())%set.faces.size()
				continue
			var checked: Dictionary = owner.edit("face",expected,candidate)
			if checked.ok: return checked
		if not owner.current(expected): return Draft.failure("stale","Portrait selection retired during resolution.")
		index = (index+direction+set.faces.size())%set.faces.size()
	return Draft.failure("portrait","No compatible portrait image is available. Restore portrait resources, then choose again.")

func random_name(owner: RefCounted, expected: Dictionary) -> Dictionary:
	if _naming_busy: return Draft.failure("busy","Name generation already owns this operation.")
	_naming_busy = true
	var result := _generate_name(owner,expected)
	_naming_busy = false
	return result

func _generate_name(owner: RefCounted, expected: Dictionary) -> Dictionary:
	if not owner.current(expected) or not _name_pending.is_empty(): return Draft.failure("stale","Name generation retired or busy.")
	var selected: Dictionary = owner.projection().selections
	var key := str(selected.get("race",""))+"/"+str(selected.get("gender",""))
	var mapping: Dictionary = identity.get("mappings",{}).get(key,{})
	var bank: Dictionary = identity.get("banks",{}).get(mapping.get("bank"),{})
	var patterns: Array = bank.get("patterns",{}).get(selected.get("gender"),[])
	if patterns.is_empty(): return Draft.failure("name_bank","Name culture mapping unavailable; enter a name manually.")
	# Separate entropy seam and source from biography/starting operations.
	var seeds = preload("res://scripts/rule/seed_derivation.gd")
	var supplied: Variant = seeds.material_from_os() if name_material.is_null() else name_material.call()
	if not owner.current(expected): return Draft.failure("stale","Draft retired during name entropy acquisition.")
	if not supplied is Dictionary or not supplied.get("ok",false) or not seeds.validate_material(supplied.get("material")).ok: return Draft.failure("random","Name entropy unavailable; existing text is retained and manual entry remains available.")
	var random: Dictionary = seeds.derive(supplied.material,"progression")
	if not random.ok: return random
	var total := 0
	for pattern in patterns: total += pattern.weight
	var draw: Dictionary = random.source.bounded(total)
	if not draw.ok: return draw
	var chosen: Dictionary = patterns[0]
	var offset: int = draw.value
	for pattern in patterns:
		if offset < pattern.weight: chosen = pattern; break
		offset -= pattern.weight
	var text := ""
	for part in chosen.parts:
		if part is String: text += part
		else:
			draw = random.source.bounded(bank.sets[part].size())
			if not draw.ok: return draw
			text += bank.sets[part][draw.value]
	var checked := Name.validate(text)
	if not checked.ok: return Draft.failure("name_bank","Generated name is invalid: "+checked.reason+" Enter a name manually.")
	_name_pending = {"value":checked.value,"generation":{"bank":mapping.bank,"pattern":chosen.id,"mapping":key,"material_sha256":preload("res://scripts/data/actor_input_formats.gd").sha256(supplied.material),"algorithm":"pcg32-xsh-rr-v1","logical_draws":random.source.logical_count,"raw_draws":random.source.raw_count}}
	_name_pending.generation.operation = expected.id+"/name-"+str(expected.revision)
	checked = owner.edit("name",expected,checked.value,true)
	_name_pending.clear()
	return checked

func validate(request: Dictionary) -> Dictionary:
	if request.section not in ["name","face","reflexes"]:
		var checked: Dictionary = super.validate(request)
		if checked.ok and request.section in ["race","gender"]:
			var selected: Dictionary = request.draft.selections
			var face: Variant = selected.get("face")
			var set := face_set(selected)
			if face is Dictionary and face.get("set") == set.id:
				for definition in set.faces:
					if definition.id == face.get("id"): checked.invalidate.erase("face"); break
		return checked
	if definitions.content_ticket() != content or identity.is_empty(): return Draft.failure("identity","Locked identity definitions are unavailable.")
	var section: String = request.section
	var value: Variant = request.draft.selections[section]
	var retained := {"value":value}
	var provenance := {"policy":"char.identity:policy#stock","content":content,"contributors":identity_provenance.duplicate(true),"record":identity_record.duplicate(true)}
	match section:
		"name":
			var checked := Name.validate(value)
			if not checked.ok: return checked
			value = checked.value
			retained.value = value
			var old: Dictionary = request.retained.get("name",{})
			if _name_pending.get("value") == value: retained.generation = _name_pending.generation.duplicate(true)
			elif old.get("value") == value and old.has("generation"): retained.generation = old.generation.duplicate(true)
			provenance.validation = checked
		"face":
			var set := face_set(request.draft.selections)
			if not value is Dictionary or value.size() != 2 or value.get("set") != set.id: return Draft.failure("portrait","Choose a compatible portrait explicitly.")
			var found := false
			for face in set.faces:
				if face.id == value.get("id"): found = true; provenance.definition = face.duplicate(true); break
			if not found: return Draft.failure("portrait","Selected portrait is missing; select a valid replacement.")
			var image := portrait(value)
			if not image.ok: return image
			provenance.image = image.get("provenance",{}).duplicate(true)
		"reflexes":
			if not value is String or not identity.reflexes.has(value): return Draft.failure("reflexes","Choose a valid reflex option; no Average fallback was substituted.")
			provenance.parameters = identity.reflexes[value].duplicate(true)
	return {"ok":true,"value":value,"retained":retained,"invalidate":[],"provenance":provenance,"semantic_ready":true,"errors":[]}
