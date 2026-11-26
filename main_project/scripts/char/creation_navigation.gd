extends RefCounted
## UI navigation state is runtime-only, separate from CHAR's authoritative facts.
const Flow = preload("res://scripts/data/creation_flow.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")
var owner: RefCounted
var _flow: Dictionary = {}
var _source: Dictionary = {}
var _path: Array = []
var _position := 0
var _visited: Dictionary = {}
var _editor := ""
var _generation := 0
var _summary_seen := false

func bind(draft: RefCounted, record: Dictionary) -> Dictionary:
	if active(): return Draft.failure("busy","Retire the active navigation before rebinding its locked flow.")
	var error := Flow.reason(record.get("value"))
	if not error.is_empty(): return Draft.failure("flow",error)
	owner = draft
	_flow = record.value.duplicate(true)
	_source = record.duplicate(true)
	return {"ok":true}

func start() -> Dictionary:
	if owner == null or _flow.is_empty(): return Draft.failure("unavailable","Creation flow unavailable.")
	var result: Dictionary = owner.start()
	if result.is_empty() or not result.has("schema"): return result
	_generation += 1
	_position = 0
	_visited.clear()
	_editor = ""
	_summary_seen = false
	_refresh_path()
	return {"ok":true}

func discard() -> void:
	_generation += 1
	if owner != null: owner.discard()
	_visited.clear()
	_path.clear()
	_position = 0
	_editor = ""
	_summary_seen = false

func active() -> bool:
	return owner != null and not owner.projection().is_empty() and not _path.is_empty()

func _refresh_path() -> void:
	var choices: Dictionary = owner.projection().get("selections",{})
	# Only the prefix up to each unselected method is navigable. The provisional
	# path selects no character fact and grants no validation.
	for route: Dictionary in _flow.routes:
		if route.class_method == choices.get("class_method","list") and route.biography_method == choices.get("biography_method","manual"):
			_path = route.steps.duplicate()
			return

func context() -> Dictionary:
	return {"generation":_generation,"token":owner.token(),"step":step_id()} if active() else {}

func step_id() -> String:
	return _editor if not _editor.is_empty() else str(_path[_position]) if not _path.is_empty() else ""

func step() -> Dictionary:
	return _flow.steps.get(step_id(),{}).duplicate(true)

func summary_locked() -> bool:
	return _summary_seen and step().get("hook") not in Draft.SUMMARY_EDITORS + ["summary"]

func edit(expected: Dictionary, value: Variant) -> Dictionary:
	if not Draft.same_value(expected,context()): return Draft.failure("stale","Creation control context retired.")
	var hook: String = step().hook
	if hook == "summary": return Draft.failure("invalid","Use a permitted summary editor.")
	if summary_locked(): return Draft.failure("restricted","Restart to change race, gender, class or biography after final review.")
	var checked: Dictionary = owner.edit(hook,expected.token,value)
	if checked.ok and checked.kind == "changed":
		var previous_hook: String = step().hook
		for invalidated in checked.invalidated: _visited.erase(invalidated)
		_visited.erase(hook)
		_refresh_path()
		if _editor.is_empty():
			for index in _path.size():
				if _flow.steps[_path[index]].hook == previous_hook: _position = index; break
		_generation += 1
	return checked

func next(expected: Dictionary) -> Dictionary:
	if not Draft.same_value(expected,context()): return Draft.failure("stale","Creation control context retired.")
	var hook: String = step().hook
	if hook == "summary": return Draft.failure("invalid","Summary requires Begin Game.")
	var checked: Dictionary = owner.section_status(hook)
	if not checked.ok: return checked
	_visited[hook] = true
	if not _editor.is_empty(): _editor = ""
	else: _position += 1
	if step().get("hook") == "summary": _summary_seen = true
	_generation += 1
	return {"ok":true}

func career_route(expected: Dictionary, method: String) -> Dictionary:
	if not Draft.same_value(expected,context()) or summary_locked() or step().get("hook") not in ["class","questionnaire","class_method"] or method not in ["list","custom"]: return Draft.failure("stale","Career route context retired.")
	var checked: Dictionary = owner.edit("class_method",expected.token,method)
	if not checked.ok: return checked
	for invalidated in checked.get("invalidated",[]): _visited.erase(invalidated)
	_refresh_path()
	for index in _path.size():
		if _flow.steps[_path[index]].hook == ("custom" if method == "custom" else "class"): _position = index; break
	_generation += 1
	return {"ok":true}

func back(expected: Dictionary) -> Dictionary:
	if not Draft.same_value(expected,context()): return Draft.failure("stale","Creation control context retired.")
	if not _editor.is_empty(): _editor = ""
	elif _position > 0: _position -= 1
	else: return Draft.failure("first","Already at first creation step.")
	_generation += 1
	return {"ok":true}

func summary_edit(expected: Dictionary, hook: String) -> Dictionary:
	if not Draft.same_value(expected,context()) or step().get("hook") != "summary": return Draft.failure("stale","Final summary required.")
	if hook not in Draft.SUMMARY_EDITORS: return Draft.failure("restricted","Restart to change race, gender, class or biography.")
	for id in _path:
		if _flow.steps[id].hook == hook:
			_editor = id
			_generation += 1
			return {"ok":true}
	return Draft.failure("flow","Summary editor binding unavailable.")

func capture(expected: Dictionary) -> Dictionary:
	if not Draft.same_value(expected,context()) or step().get("hook") != "summary": return Draft.failure("stale","Complete the required creation route before confirmation.")
	var required: Array = []
	for id in _path:
		var hook: String = _flow.steps[id].hook
		if hook == "summary": continue
		if not _visited.has(hook): return Draft.failure("route","Complete the required section: "+hook)
		required.append(hook)
	return owner.capture(expected.token,required,{"schema":"creation-route-receipt-v1","steps":_path.duplicate(),"source":_source.duplicate(true)})
