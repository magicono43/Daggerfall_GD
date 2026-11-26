extends RefCounted
## DATA validates supported UI declarations before atomic menu publication. These
## declarations contain no expressions, script paths, provider claims or gameplay.
const DOMAIN = "char.creation"
const VERSION = "creation-flow-v1"
const Draft = preload("res://scripts/char/creation_draft.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const COMMON = ["race","gender","class_method","biography_method","biography","name","face","attributes","skills","reflexes","summary"]

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"required_resources":["flows"],"capabilities":["data."+VERSION]}

func validate_resource_path(path: String) -> String:
	return "" if path == "flows" else "Creation declarations use flows."

func bundled_contributions() -> Array:
	return [{"root":"res://content/char","file":"creation.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/char/creation.json")}]

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	for key in fields: value[key] = fields[key]
	return {"ok":true,"value":value}

static func reason(value: Variant) -> String:
	if not value is Dictionary or value.size() != 5 or value.get("schema") != VERSION or not value.get("steps") is Dictionary or not value.get("routes") is Array or value.routes.size() != 6 or not value.get("choices") is Dictionary or not value.get("provenance") is Dictionary or value.provenance.is_empty(): return "Complete creation flow, six supported branch combinations and provenance required."
	if value.choices.keys().size() != 5: return "Five supported choice bindings required."
	for hook in ["race","gender","class_method","biography_method","reflexes"]:
		if not value.choices.get(hook) is Array or value.choices[hook].is_empty() or value.choices[hook].size() > 64: return "Required creation choices missing."
		var choice_ids := {}
		for choice in value.choices[hook]:
			if not choice is Dictionary or choice.size() != 2 or not Paths.valid_id(choice.get("id")) or choice_ids.has(choice.id) or not choice.get("label") is String or choice.label.is_empty() or choice.label.length() > 160: return "Unique choice IDs and bounded labels required."
			choice_ids[choice.id] = true
		if hook == "class_method" and choice_ids.keys().size() != 3: return "All class methods required."
		if hook == "class_method" and not (choice_ids.has("list") and choice_ids.has("questionnaire") and choice_ids.has("custom")): return "Unsupported class method binding."
		if hook == "biography_method" and (choice_ids.keys().size() != 2 or not choice_ids.has("manual") or not choice_ids.has("automatic")): return "Both biography methods required."
	if value.steps.size() > 64: return "Creation flow exceeds supported step count."
	for id in value.steps:
		var step: Variant = value.steps[id]
		if not Paths.valid_id(id) or not step is Dictionary or step.size() != 3 or step.get("hook") not in Draft.SECTIONS + ["summary"] or not step.get("title") is String or step.title.is_empty() or step.title.length() > 160 or not step.get("art") is String or (not step.art.is_empty() and not Paths.valid_id(step.art)): return "Step needs stable identity, supported owner hook, title and optional media target."
	var seen := {}
	var route_ids := {}
	for route in value.routes:
		if not route is Dictionary or route.size() != 4 or not Paths.valid_id(route.get("id")) or route.get("class_method") not in ["list","questionnaire","custom"] or route.get("biography_method") not in ["manual","automatic"] or not route.get("steps") is Array or route.steps.size() > 64: return "Unsupported creation route declaration."
		var combination: String = route.class_method+"/"+route.biography_method
		if route_ids.has(route.id): return "Duplicate creation route identity."
		route_ids[route.id] = true
		if seen.has(combination): return "Duplicate creation branch combination."
		seen[combination] = true
		var hooks: Array = []
		var ids := {}
		for step_id in route.steps:
			if not step_id is String or not value.steps.has(step_id) or ids.has(step_id): return "Missing step or route cycle."
			ids[step_id] = true
			var hook: String = value.steps[step_id].hook
			if hooks.has(hook): return "An owner section cannot repeat in a route."
			hooks.append(hook)
		var required := COMMON.duplicate()
		if route.class_method == "custom": required.insert(3,"custom")
		else:
			required.insert(3,"class")
			if route.class_method == "questionnaire": required.insert(3,"questionnaire")
		if hooks.size() != required.size() or hooks.back() != "summary": return "Route must reach final summary with every required owner section."
		for hook in required:
			if not hooks.has(hook): return "Route bypasses a required owner section."
		var career: String = "custom" if route.class_method == "custom" else "class"
		var dependencies := {"gender":["race"],"face":["race","gender"],career:["class_method"],"biography":[career,"biography_method"],"attributes":[career,"biography"],"skills":[career,"biography"]}
		if route.class_method == "questionnaire": dependencies["class"].append("questionnaire"); dependencies["questionnaire"] = ["class_method"]
		for hook in dependencies:
			for prerequisite in dependencies[hook]:
				if hooks.find(prerequisite) >= hooks.find(hook): return "Route violates required owner prerequisites."
	return ""

func validate_record(id: String, value: Dictionary) -> String:
	return reason(value) if Paths.valid_id(id) else "Stable creation flow identity required."

func validate_references(resources: Dictionary) -> Array:
	var records: Dictionary = resources.get(DOMAIN+":flows",{}).get("records",{})
	return [] if records.has("stock") else [{"source":DOMAIN,"reason":"Stock creation flow binding missing."}]
