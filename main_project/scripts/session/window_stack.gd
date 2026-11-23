class_name SessionWindowStack
extends RefCounted
## UI owns navigation/focus; CORE owns the resulting gates. No command queue:
## callers receive immediate applied/busy/stale outcomes; refresh cannot evict work.
signal changed
const PRIORITY = ["options", "character", "inventory", "travel", "rest", "transport", "journal", "notebook", "spellbook", "magic_item", "status", "automap", "quicksave", "quickload"]
var core: SessionLifecycle
var _layers: Array[Dictionary] = []
var _serial := 0
var _handoff := false
var context_generation := 0
var no_ui_pause := false
var _held: Dictionary = {}
var _edges: Array[String] = []
var last_feedback := ""
var _pending_response: Dictionary = {}

func _init(lifecycle: SessionLifecycle) -> void:
	core = lifecycle
	core.retiring.connect(retire)

func top() -> Dictionary:
	return {} if _layers.is_empty() else _layers.back().duplicate(true)

func layers() -> Array[Dictionary]:
	return _layers.duplicate(true)

func open(window_id: String, scope: String, data: Dictionary = {}, pause := true) -> Dictionary:
	if _handoff:
		return {"kind": "busy"}
	if not scope.is_empty() and scope != core.snapshot().session:
		return {"kind": "stale"}
	_serial += 1
	var owner := "window-%d" % _serial
	var channels: Array = ["input"]
	if pause and not no_ui_pause:
		channels.append("simulation")
	var layer := {"id": owner, "window": window_id, "scope": scope, "data": data.duplicate(true), "focus": "", "token": core.gates.acquire(owner, scope, channels)}
	_layers.append(layer)
	_boundary()
	return {"kind": "applied", "id": owner}

func close(id: String, force := false) -> Dictionary:
	if _handoff:
		return {"kind": "busy"}
	if _layers.is_empty() or _layers.back().id != id:
		return {"kind": "stale"}
	if not _pending_response.is_empty() and _pending_response.id == id:
		if not force:
			return {"kind": "busy"}
		_pending_response.clear()
	if not force and _layers.back().data.get("required_choice", false):
		return {"kind": "blocked", "reason": "An explicit owner response is required."}
	var layer: Dictionary = _layers.pop_back()
	core.gates.release(layer.token, layer.id)
	_boundary()
	return {"kind": "applied"}

func retire_layer(id: String, scope: String) -> Dictionary:
	# An externally retired cinematic may be below a newer independent window.
	# Remove only its original layer/gate; never close the newer top context.
	if _handoff: return {"kind":"busy"}
	for index in _layers.size():
		var layer: Dictionary = _layers[index]
		if layer.id != id: continue
		if layer.scope != scope: return {"kind":"stale"}
		_layers.remove_at(index)
		if _pending_response.get("id")==id: _pending_response.clear()
		core.gates.release(layer.token,layer.id)
		_boundary()
		return {"kind":"applied"}
	return {"kind":"stale"}

func respond(id: String, response: String, owner: Callable) -> Dictionary:
	if _layers.is_empty() or _layers.back().id != id:
		return {"kind": "stale"}
	if _handoff or not _pending_response.is_empty():
		return {"kind": "busy"}
	var data: Dictionary = _layers.back().data
	if not data.get("responses", []).has(response):
		return {"kind": "invalid"}
	_handoff = true
	var checked: Dictionary = owner.call(response, data.duplicate(true))
	_handoff = false
	if top().get("id") != id:
		return {"kind": "stale"}
	if checked.get("pending", false):
		_pending_response = {"id": id, "generation": context_generation}
	elif checked.get("ok", false):
		close(id, true)
	return checked

func complete_response(id: String, generation: int, accepted: bool) -> Dictionary:
	if _pending_response != {"id": id, "generation": generation} or top().get("id") != id:
		return {"kind": "stale"}
	_pending_response.clear()
	return close(id, true) if accepted else {"kind": "rejected"}

func update_data(id: String, values: Dictionary) -> bool:
	if top().get("id") != id:
		return false
	_layers.back().data.merge(values.duplicate(true), true)
	return true

func return_to_game(scope: String) -> Dictionary:
	if _handoff or not _pending_response.is_empty():
		return {"kind": "busy"}
	if scope.is_empty() or scope != core.snapshot().session:
		return {"kind": "stale"}
	for layer: Dictionary in _layers:
		if layer.scope != scope or layer.data.get("required_choice", false):
			return {"kind": "blocked", "target": layer.id}
	var ending := _layers.duplicate()
	_layers.clear()
	for layer: Dictionary in ending:
		core.gates.release(layer.token, layer.id)
	_boundary()
	return {"kind": "applied"}

func replace(id: String, window_id: String, prepare: Callable) -> Dictionary:
	if _handoff or not _pending_response.is_empty():
		return {"kind": "busy"}
	if top().get("id") != id:
		return {"kind": "stale"}
	_handoff = true
	var checked: Dictionary = prepare.call(top())
	_handoff = false
	if top().get("id") != id:
		return {"kind": "stale"}
	if not checked.get("ok", false):
		return checked # Keep old view, draft, focus and holds on preparation failure.
	# Same navigation lifetime and token; no intermediate resume or HUD flash.
	_layers.back().window = window_id
	_layers.back().data = checked.get("data", {}).duplicate(true)
	_boundary()
	return {"kind": "applied"}

func retire(scope: String) -> void:
	if not _pending_response.is_empty():
		for layer: Dictionary in _layers:
			if layer.scope == scope and layer.id == _pending_response.id:
				_pending_response.clear()
	_handoff = true
	for index in range(_layers.size() - 1, -1, -1):
		var layer: Dictionary = _layers[index]
		if layer.scope == scope:
			core.gates.release(layer.token, layer.id)
			_layers.remove_at(index)
	_handoff = false
	_boundary()

func remember_focus(id: String, target: String) -> void:
	for layer: Dictionary in _layers:
		if layer.id == id:
			layer.focus = target

func capture(action: String, pressed: bool, echo := false) -> void:
	if not pressed:
		_held.erase(action)
	elif not echo and not _held.has(action):
		_held[action] = true
		_edges.append(action)

func dispatch() -> Dictionary:
	var actions := _edges.duplicate()
	_edges.clear()
	return dispatch_actions(actions)

func dispatch_actions(actions: Array) -> Dictionary:
	# Already resolved, once-delivered gameplay presses from MOVE. Never retain
	# suppressed candidates as a second hidden shortcut queue.
	actions = actions.duplicate()
	last_feedback = ""
	if actions.has("quicksave") and actions.has("quickload"):
		actions.erase("quicksave")
		actions.erase("quickload")
		last_feedback = "Quicksave and quickload conflict; neither submitted."
	for action: String in PRIORITY:
		if actions.has(action):
			if action == "options":
				return {"kind": "dispatch", "action": action, "context": context_generation}
			if not _layers.is_empty() or not core.gates.gameplay_input():
				return {"kind": "blocked", "action": action}
			return {"kind": "dispatch", "action": action, "context": context_generation}
	return {"kind": "none"}

func _boundary() -> void:
	context_generation += 1
	_edges.clear() # Handoff input expires; held keys require release before a new edge.
	changed.emit()
