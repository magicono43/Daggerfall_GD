extends RefCounted
## Replaceable creation-only ranges, pools and caps. No live progression rules.
const DOMAIN = "char.starting"
const VERSION = "creation-starting-v1"
const Rolls = preload("res://scripts/char/starting_rolls.gd")
const Typed = preload("res://scripts/char/creation_inputs.gd")

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,"actor.baseline","actor.inputs","char.career"],"operations":["add","replace","patch"],"required_resources":["policy"],"capabilities":["data."+VERSION]}

func validate_resource_path(path: String) -> String:
	return "" if path == "policy" else "Starting rules use policy."

func bundled_contributions() -> Array:
	return [{"root":"res://content/char","file":"starting.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/char/starting.json")}]

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	for key in fields: value[key] = fields[key]
	return {"ok":true,"value":value}

func validate_record(id: String, value: Dictionary) -> String:
	if id != "stock" or value.get("schema") != VERSION: return "Versioned stock starting policy required."
	# Cross-owner domains are checked against the resolved candidate, never defaults.
	return "" if preload("res://scripts/char/creation_draft.gd").plain(Typed.exact_numbers(value)) else "Bounded exact starting policy required."

func validate_references(resources: Dictionary) -> Array:
	var p: Dictionary = Typed.exact_numbers(resources.get(DOMAIN+":policy",{}).get("records",{}).get("stock",{}).get("value",{}))
	var numeric: Dictionary = Typed.exact_numbers(resources.get("actor.baseline:policy",{}).get("records",{}).get("player",{}).get("value",{}))
	var reason := Rolls.policy_reason(p,numeric)
	if not reason.is_empty(): return [{"source":DOMAIN,"reason":reason}]
	var catalog: Dictionary = resources.get("actor.inputs:catalog",{}).get("records",{})
	var policy: Dictionary = Typed.exact_numbers(resources.get("char.career:policy",{}).get("records",{}).get("stock",{}).get("value",{}))
	for index in 18:
		var id := "class-%02d" % index
		var source: Dictionary = Typed.exact_numbers(catalog.get(id,{}).get("value",{}).get("data",{}))
		if source.is_empty(): return [{"source":DOMAIN,"reason":"Missing required starting career: "+id}]
		var career := preload("res://scripts/char/preset_career.gd").resolve(source,policy,numeric)
		if not career.ok: return [{"source":DOMAIN,"reason":career.reason}]
		var checked := Rolls.attribute_feasibility(Rolls.class_attributes(career.attributes),p.attributes,numeric)
		if not checked.ok: return [{"source":id,"reason":checked.reason}]
		checked = Rolls.skill_feasibility(career.tiers,p.skills,{})
		if not checked.ok: return [{"source":id,"reason":checked.reason}]
	return []
