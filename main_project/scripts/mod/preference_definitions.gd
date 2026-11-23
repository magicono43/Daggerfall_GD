extends RefCounted
## DATA owns immutable definitions; MOD owns application preference requests.
const VERSION := "mod-preferences-v1"
const DOMAIN := "mod.preferences"
const Paths = preload("res://scripts/mod/package_library.gd")
const Tokens = preload("res://scripts/data/text_tokens.gd")
const Catalog = preload("res://scripts/data/text_catalog.gd")

func declaration() -> Dictionary:
	return {"id":"mod.preferences.v1","domain":DOMAIN,"reference_domains":[DOMAIN,Catalog.DOMAIN],"operations":["add","replace"],"required_resources":[]}

func validate_resource_path(path: String) -> String:
	return "" if path == "installed" else "Preferences require the installed logical resource."

static func label_ref(value: Variant) -> bool:
	return value is Dictionary and value.size() == 2 and value.get("collection") is String and Paths.valid_id(value.collection) and value.get("key") is String and Tokens.identifier(value.key)

static func valid_value(value: Variant, spec: Dictionary) -> bool:
	match spec.get("type"):
		"bool":
			return value is bool
		"int":
			return (value is int or value is float) and value == int(value) and value >= spec.get("min", 0) and value <= spec.get("max", -1)
		"string":
			return value is String and value.length() <= spec.get("max_length", 0) and (spec.get("choices", []).is_empty() or spec.choices.has(value))
	return false

func validate_record(id: String, value: Dictionary) -> String:
	if value.get("schema") != VERSION or value.get("mod_id") != id or not value.get("version") is float and not value.get("version") is int or value.get("version", 0) < 1 or value.version != int(value.version) or not label_ref(value.get("name")) or not label_ref(value.get("description")) or not value.get("settings") is Dictionary or not value.get("groups") is Dictionary or not value.get("presets") is Dictionary or value.settings.is_empty() or value.settings.size() > 128:
		return "Versioned stable mod identity, localized references, settings/groups/presets required."
	for field: String in value:
		if field not in ["schema", "mod_id", "version", "name", "description", "settings", "groups", "presets"]:
			return "Unknown preference definition field: " + field
	for key: String in value.settings:
		var spec: Variant = value.settings[key]
		if not Paths.valid_id(key) or not spec is Dictionary or not label_ref(spec.get("name")) or not label_ref(spec.get("description")) or spec.get("timing") not in ["live", "next_session", "next_location", "restart"] or not spec.get("group") is String or not value.groups.has(spec.group):
			return "Invalid setting identity, labels, timing or group: " + key
		for field: String in spec:
			if field not in ["type", "default", "name", "description", "timing", "group", "min", "max", "max_length", "choices"]:
				return "Unknown setting constraint: " + field
		if spec.get("type") == "int":
			if not spec.get("min") is float and not spec.get("min") is int or not spec.get("max") is float and not spec.get("max") is int or spec.min != int(spec.min) or spec.max != int(spec.max) or spec.min > spec.max or abs(spec.min) > 2147483647 or abs(spec.max) > 2147483647:
				return "Bounded integer min/max required."
		if spec.get("type") == "string":
			if not spec.get("max_length") is float and not spec.get("max_length") is int or spec.get("max_length", 0) < 1 or spec.max_length > 4096 or spec.max_length != int(spec.max_length) or not spec.get("choices", []) is Array:
				return "Bounded string length and optional explicit choices required."
			var choices: Array = []
			for choice in spec.get("choices", []):
				if not choice is String or choice.length() > spec.max_length or choices.has(choice):
					return "Invalid/duplicate string choice."
				choices.append(choice)
		if not spec.has("default") or not valid_value(spec.default, spec):
			return "Invalid typed default: " + key
	for group: String in value.groups:
		if not Paths.valid_id(group) or not value.groups[group] is Dictionary or value.groups[group].size() != 1 or not value.groups[group].get("constraints") is Array:
			return "Group requires explicit pure constraints array."
		var members: Array = value.settings.keys().filter(func(key: String): return value.settings[key].group == group)
		var timings: Array = []
		for member: String in members:
			if not timings.has(value.settings[member].timing):
				timings.append(value.settings[member].timing)
		if members.is_empty() or (not timings.has("restart") and timings.has("next_session") and timings.has("next_location")):
			return "Empty group or incompatible session/location boundaries; explicitly declare restart."
		for constraint in value.groups[group].constraints:
			if not constraint is Array or constraint.size() != 3 or constraint[0] != "less_equal" or not members.has(constraint[1]) or not members.has(constraint[2]) or value.settings[constraint[1]].type != "int" or value.settings[constraint[2]].type != "int":
				return "Only declared same-group integer less_equal constraints supported."
			if value.settings[constraint[1]].default > value.settings[constraint[2]].default:
				return "Group defaults violate constraints."
	for preset: String in value.presets:
		var item: Variant = value.presets[preset]
		if not Paths.valid_id(preset) or not item is Dictionary or item.size() != 3 or not label_ref(item.get("name")) or not label_ref(item.get("description")) or not item.get("values") is Dictionary:
			return "Preset needs stable identity, localized labels and partial values."
		for key: String in item.values:
			if not value.settings.has(key) or not valid_value(item.values[key], value.settings[key]):
				return "Preset references invalid setting/value."
	return ""

func patch_record(_previous: Dictionary, _fields: Dictionary) -> Dictionary:
	return {"ok":false,"reason":"Replace the complete validated preference definition explicitly."}

func validate_references(resources: Dictionary) -> Array:
	var issues: Array = []
	for record: Dictionary in resources.get(DOMAIN + ":installed", {}).get("records", {}).values():
		var refs: Array = [record.value.name, record.value.description]
		for spec: Dictionary in record.value.settings.values() + record.value.presets.values():
			refs.append_array([spec.name, spec.description])
		for ref: Dictionary in refs:
			if not resources.get(Catalog.DOMAIN + ":" + ref.collection, {}).get("records", {}).has(ref.key):
				issues.append({"source":record.value.mod_id,"reason":"Missing localized preference definition key: " + ref.collection + "/" + ref.key})
	return issues
