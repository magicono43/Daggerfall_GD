extends RefCounted
## Locked, replaceable naming patterns, portrait identities and coupled reflexes.
const DOMAIN = "char.identity"
const VERSION = "creation-identity-v1"
const Typed = preload("res://scripts/char/creation_inputs.gd")
const Reflex = preload("res://scripts/char/reflex_parameters.gd")
const Name = preload("res://scripts/ui/character_name.gd")

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,"char.career"],"operations":["add","replace","patch"],"required_resources":["policy"],"capabilities":["data."+VERSION]}

func validate_resource_path(path: String) -> String:
	return "" if path == "policy" else "Identity definitions use policy."

func bundled_contributions() -> Array:
	return [{"root":"res://content/char","file":"identity.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/char/identity.json")}]

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	for key in fields: value[key] = fields[key]
	return {"ok":true,"value":value}

func validate_record(id: String, raw: Dictionary) -> String:
	if id != "stock" or raw.get("schema") != VERSION: return "Versioned stock creation identity policy required."
	var value: Dictionary = Typed.exact_numbers(raw)
	if not preload("res://scripts/char/creation_draft.gd").plain(value): return "Bounded plain identity definitions required."
	var error := Reflex.reason(value.get("reflexes"))
	if not error.is_empty(): return error
	for key in ["banks","mappings","portraits"]:
		if not value.get(key) is Dictionary or (key != "banks" and value[key].is_empty()): return "Missing identity collection: "+key
	for bank in value.banks.values():
		if not bank is Dictionary or not bank.get("sets") is Array or not bank.get("patterns") is Dictionary: return "Name sets and explicit gender patterns required."
		var maxima: Array[int] = []
		var guaranteed: Array[bool] = []
		for parts in bank.sets:
			if not parts is Array or parts.is_empty(): return "Required name component set is empty."
			var maximum := 0
			var nonblank := true
			for part in parts:
				if not part is String or part.length() > 128: return "Bounded Unicode name component required."
				for index in part.length():
					if Name.forbidden(part.unicode_at(index)): return "Name components cannot contain control or bidi formatting characters."
				maximum = maxi(maximum,TextServerManager.get_primary_interface().string_get_character_breaks(part,"en").size())
				nonblank = nonblank and Name.validate(part).ok
			maxima.append(maximum)
			guaranteed.append(nonblank)
		for gender in ["male","female"]:
			var patterns: Variant = bank.patterns.get(gender)
			if not patterns is Array or patterns.is_empty(): return "Explicit gender patterns required."
			var pattern_ids := {}
			for pattern in patterns:
				if not pattern is Dictionary or not Reflex.integer(pattern.get("weight"),1,10000) or not pattern.get("parts") is Array or pattern.parts.is_empty(): return "Weighted name pattern required."
				if not pattern.get("id") is String or pattern.id.is_empty() or pattern_ids.has(pattern.id): return "Unique stable name-pattern identities required."
				pattern_ids[pattern.id] = true
				var maximum := 0
				var nonblank := false
				for part in pattern.parts:
					if part is int:
						if part < 0 or part >= bank.sets.size(): return "Missing name component set."
						maximum += maxima[part]
						nonblank = nonblank or guaranteed[part]
					elif not part is String or part.length() > 128: return "Unsupported name pattern part."
					else:
						for index in part.length():
							if Name.forbidden(part.unicode_at(index)): return "Name literals cannot contain controls."
						maximum += TextServerManager.get_primary_interface().string_get_character_breaks(part,"en").size()
						nonblank = nonblank or Name.validate(part).ok
				if maximum > Name.LIMIT or not nonblank: return "Every name pattern must guarantee a nonblank result of at most 31 grapheme clusters."
	for set_id in value.portraits:
		var faces: Variant = value.portraits[set_id]
		if not faces is Array or faces.is_empty() or faces.size() > 1024: return "A portrait set requires 1–1024 entries."
		var seen := {}
		for face in faces:
			if not face is Dictionary or not face.get("id") is String or face.id.is_empty() or seen.has(face.id) or not face.get("target") is String or face.target.is_empty() or not Reflex.integer(face.get("classic"),-1,9): return "Unique stable portrait IDs, image targets and explicit classic mapping required."
			seen[face.id] = true
	return ""

func validate_references(resources: Dictionary) -> Array:
	var value: Dictionary = Typed.exact_numbers(resources.get(DOMAIN+":policy",{}).get("records",{}).get("stock",{}).get("value",{}))
	var career: Dictionary = Typed.exact_numbers(resources.get("char.career:policy",{}).get("records",{}).get("stock",{}).get("value",{}))
	for race in career.get("races",{}):
		for gender in ["male","female"]:
			var key: String = race+"/"+gender
			var mapping: Variant = value.get("mappings",{}).get(key)
			if not mapping is Dictionary or not value.get("portraits",{}).has(mapping.get("portraits")): return [{"source":key,"reason":"Explicit compatible portrait set required."}]
			# Random names are optional: absent bank/mapping means an actionable
			# generation failure while manual entry remains available. Provided bank
			# data still has to pass its complete schema; never choose another culture.
			if mapping.has("bank") and not mapping.bank is String: return [{"source":key,"reason":"An optional culture mapping must use a stable bank ID."}]
	return []
