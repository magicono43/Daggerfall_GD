class_name SessionLifecycle
extends RefCounted
## One CORE authority; providers own prepared data and actual service disposal.
signal state_changed(previous: Dictionary, current: Dictionary, reason: String)
signal milestone(name: String, context: Dictionary)
signal terminal(result: Dictionary)
signal retiring(scope: String)
signal diagnostic(reason: String)
const Gates = preload("res://scripts/session/session_gates.gd")
var gates := Gates.new()
var randomness: RefCounted
var provider: RefCounted = preload("res://scripts/session/session_provider.gd").new()
var _state := {"application": "startup", "session": "", "status": "absent", "ready": false, "baseline_ready": false, "operation": "", "phase": "idle", "version": 0}
var _operation: Dictionary = {}
var _receipts: Dictionary = {}
var _serial := 0
var _publishing := false
var _deferred: Array[Callable] = []
var _cleanup: Dictionary = {}
var _menu_recovery: Dictionary = {}
var _blocked := false
var _operation_hold := 0
var last_intent: Dictionary = {}
var _death_authority: RefCounted
var _cleanup_serial := 0
var _startup_ready := false
var _finishing := false

func _init(material_provider: Callable = Callable()) -> void:
	randomness = preload("res://scripts/rule/session_randomness.gd").new(gates, material_provider)

func snapshot() -> Dictionary:
	var view := _state.duplicate(true)
	view.make_read_only()
	return view

func busy() -> bool:
	return not _operation.is_empty()

func cleanup_blocked() -> bool:
	return _blocked

func startup_route_changed(route: String) -> bool:
	if busy() or _blocked or not _state.session.is_empty():
		return false
	var phase := "menu" if route == "main_menu" else "setup" if route in ["mandatory_setup", "optional_setup", "package_recovery"] else "startup_recovery"
	_startup_ready = phase == "menu"
	_commit({"application": phase}, "checked startup route: " + route, "menu_ready" if phase == "menu" else "")
	return true

func ticket() -> Dictionary:
	return {} if not busy() else {"id": _operation.intent.id, "generation": _operation.generation, "scope": _operation.scope}

func request(intent: Dictionary) -> Dictionary:
	if not _plain_data(intent):
		return {"kind": "invalid", "reason": "Intent must contain immutable value data, not runtime objects."}
	var captured := intent.duplicate(true)
	var id := str(captured.get("id", ""))
	if id.is_empty():
		return {"kind": "invalid", "reason": "Request identity required."}
	if _receipts.has(id):
		return _receipts[id].result.duplicate(true) if _receipts[id].intent == captured else {"kind": "invalid", "reason": "Identity reused with changed intent."}
	if _publishing or _finishing:
		return {"kind": "busy", "reason": "Lifecycle notification in progress; submit at a safe boundary."}
	if busy() or _blocked:
		return {"kind": "busy", "reason": "Cleanup required." if _blocked else "Another session operation is active."}
	var mode := str(captured.get("mode", ""))
	if mode != "shutdown" and not _startup_ready:
		return {"kind": "unavailable", "reason": "Required startup checks and menu readiness are incomplete."}
	if gates.blocked("admission") and mode != "shutdown":
		return {"kind": "busy", "reason": "Shutdown is pending."}
	if mode not in ["new", "load", "return", "death", "shutdown"]:
		return {"kind": "unsupported", "reason": "Unsupported session mode."}
	if str(captured.get("origin", "")) != _state.session:
		return {"kind": "stale"}
	if mode == "death" and _state.status != "dead":
		return {"kind": "invalid", "reason": "CHAR-confirmed current-session death required."}
	_serial += 1
	_operation = {"intent": captured, "generation": _serial, "scope": _state.session, "prepared": {}}
	last_intent = captured.duplicate(true)
	_receipts[id] = {"intent": captured, "result": {"kind": "pending", "id": id}}
	randomness.suspend_operation(true)
	_operation_hold = gates.acquire("operation:" + id, "", ["simulation", "input"])
	_commit({"operation": id, "phase": "preflight"}, "request admitted")
	if not busy() or _operation.intent.id != id or _state.phase != "preflight":
		return _receipts[id].result.duplicate(true)
	if mode == "return" and _state.session.is_empty():
		_finish("Succeeded", "Already at menu; unchanged.")
		return _receipts[id].result.duplicate(true)
	var current := ticket()
	if mode in ["new", "load"]:
		_operation.random_ticket = current.duplicate(true)
		var initialized: Dictionary = randomness.prepare(current, mode)
		if not _matches(current, "preflight"):
			return _receipts[id].result.duplicate(true)
		if not initialized.ok:
			complete_preflight(current, initialized)
			return _receipts[id].result.duplicate(true)
	var checked: Dictionary = {"ok": true} if mode in ["return", "death", "shutdown"] else provider.prepare(current, captured.duplicate(true))
	if not checked.get("pending", false):
		complete_preflight(current, checked)
	return _receipts[id].result.duplicate(true)

func _matches(value: Dictionary, phase: String) -> bool:
	if not busy() or value != ticket() or _state.phase != phase:
		diagnostic.emit("Rejected stale session completion: " + phase)
		return false
	return true

func complete_preflight(value: Dictionary, result: Dictionary) -> bool:
	if _defer_completion("complete_preflight", value, result):
		return true
	if not _matches(value, "preflight"):
		return false
	if not result.get("ok", false):
		_finish("Failed", result.get("reason", "Preparation failed."))
		return true
	_operation.prepared = result.duplicate(true)
	if _state.status == "alive":
		_commit({"phase": "confirmation"}, "Discard unsaved progress? No automatic save.")
	else:
		_begin_replacement()
	return true

func confirm(value: Dictionary, accepted: bool) -> bool:
	if _publishing:
		var captured := value.duplicate(true)
		_deferred.append(func(): confirm(captured, accepted))
		return true
	if not _matches(value, "confirmation"):
		return false
	if not accepted:
		_commit({"phase": "cancelling"}, "discard declined")
		provider.cancel_preparation(value)
		_finish("Cancelled", "Discard declined.")
	else:
		_begin_replacement()
	return true

func cancel(value: Dictionary) -> bool:
	if _publishing:
		var captured := value.duplicate(true)
		_deferred.append(func(): cancel(captured))
		return true
	if not busy() or ticket() != value or _state.phase not in ["preflight", "confirmation"]:
		return false
	_commit({"phase": "cancelling"}, "cancelling preparation")
	provider.cancel_preparation(value)
	_finish("Cancelled", "Cancelled before replacement; outgoing session retained.")
	return true

func _begin_replacement() -> void:
	_commit({"phase": "replacement", "ready": false}, "Replacement started; cancellation unavailable.")
	_cleanup_scope(_state.session, "replace")

func _cleanup_scope(scope: String, purpose: String) -> void:
	_cleanup_serial += 1
	var cleanup_ticket := ticket()
	cleanup_ticket.cleanup_generation = _cleanup_serial
	_cleanup = {"scope": scope, "purpose": purpose, "ticket": cleanup_ticket.duplicate(true), "awaiting": true}
	if not scope.is_empty():
		_commit({"status": "ending", "ready": false}, "scope retiring")
		randomness.retire(scope)
		retiring.emit(scope) # UI disconnects and retires session-owned requests first.
		gates.retire(scope)
	var checked: Dictionary = provider.cleanup(cleanup_ticket.duplicate(true), scope)
	if not checked.get("pending", false):
		complete_cleanup(cleanup_ticket, checked)

func complete_cleanup(value: Dictionary, result: Dictionary) -> bool:
	if _defer_completion("complete_cleanup", value, result):
		return true
	if _cleanup.is_empty() or not _cleanup.awaiting or value != _cleanup.ticket:
		diagnostic.emit("Rejected stale cleanup completion")
		return false
	if not result.get("ok", false):
		_cleanup.awaiting = false
		_blocked = true
		gates.safe = false
		_commit({"application": "recovery", "ready": false, "phase": "cleanup_failed"}, "Unsafe cleanup: Retry Cleanup or Quit.")
		if busy():
			_finish("Failed", result.get("reason", "Cleanup failed."), true)
		return true
	var work := _cleanup.duplicate(true)
	_cleanup.clear()
	_blocked = false
	gates.safe = true
	var old: String = _state.session
	_death_authority = null
	gates.hud_bound = false
	_commit({"session": "", "status": "absent", "ready": false, "baseline_ready": false}, "scope safely ended", "session_ended" if not old.is_empty() else "", {"session": old, "reason": last_intent.get("mode", "failure")})
	if work.purpose == "failure" or not busy():
		_commit({"application": "recovery", "phase": "failed"}, "Safe cleanup complete. Retry, Main Menu or Quit.")
		if busy():
			_finish("Failed", "Initialization failed; incomplete session cleaned.")
		return true
	if _operation.intent.mode in ["return", "death", "shutdown"]:
		_arrive_menu()
	else:
		_serial += 1
		_operation.scope = "session-%d" % _serial
		_commit({"session": _operation.scope, "status": "initializing", "application": "session", "phase": "baseline"}, "clean replacement scope")
		if not busy() or _state.phase != "baseline":
			return true
		var checked: Dictionary = provider.initialize_baseline(ticket())
		if not checked.get("pending", false):
			complete_baseline(ticket(), checked)
	return true

func complete_baseline(value: Dictionary, result: Dictionary) -> bool:
	if _defer_completion("complete_baseline", value, result):
		return true
	if not _matches(value, "baseline"):
		return false
	var checked := validate_bindings(result.get("services", []))
	if not result.get("ok", false) or not checked.ok:
		_commit({"ready": false, "phase": "replacement"}, "Required baseline initialization failed.")
		_cleanup_scope(_state.session, "failure")
		return true
	_commit({"baseline_ready": true}, "required baseline owners initialized", "baseline_ready")
	_commit({"phase": "initializing"}, "entry owner placement/restoration/readiness")
	if not busy() or _state.phase != "initializing":
		return true
	var ready: Dictionary = provider.initialize(ticket(), _operation.prepared.duplicate(true))
	if not ready.get("pending", false):
		complete_readiness(ticket(), ready)
	return true

func retry_cleanup() -> bool:
	if _publishing:
		_deferred.append(retry_cleanup)
		return true
	if not _blocked or _cleanup.is_empty() or _cleanup.awaiting:
		return false
	_cleanup_serial += 1
	_cleanup.ticket = _cleanup.ticket.duplicate(true)
	_cleanup.ticket.cleanup_generation = _cleanup_serial
	_cleanup.awaiting = true
	var checked: Dictionary = provider.cleanup(_cleanup.ticket.duplicate(true), _cleanup.scope)
	if not checked.get("pending", false):
		complete_cleanup(_cleanup.ticket, checked)
	return true

func complete_readiness(value: Dictionary, result: Dictionary) -> bool:
	if _defer_completion("complete_readiness", value, result):
		return true
	if not _matches(value, "initializing"):
		return false
	var checked := validate_bindings(result.get("services", []))
	if not result.get("ok", false) or not checked.ok:
		_commit({"ready": false, "phase": "replacement"}, result.get("reason", checked.get("reason", "Required readiness failed.")))
		_cleanup_scope(_state.session, "failure")
		return true
	var activated: Dictionary = randomness.activate(_operation.random_ticket, _state.session, result.services)
	if not activated.ok:
		_commit({"ready": false, "phase": "replacement"}, activated.reason)
		_cleanup_scope(_state.session, "failure")
		return true
	randomness.suspend_operation(false)
	_death_authority = result.get("death_authority")
	_commit({"status": "alive", "ready": true, "phase": "ready"}, "session ready", "session_restored" if _operation.intent.mode == "load" else "new_session_ready")
	_finish("Succeeded", "Required readiness completed.")
	return true

func validate_bindings(services: Array) -> Dictionary:
	# Inventory is declared by the mode owner, not inferred from object names.
	var roles: Dictionary = {}
	for service: Dictionary in services:
		var role := str(service.get("role", ""))
		if role.is_empty() or service.get("owner", "").is_empty() or service.get("lifetime", "") not in ["session", "location"]:
			return {"ok": false, "reason": "Invalid service declaration."}
		roles[role] = roles.get(role, 0) + 1
	for service: Dictionary in services:
		var valid: bool = roles[service.role] == 1 and service.get("ready", false) and is_instance_valid(service.get("provider"))
		if not valid:
			if service.get("required", true) or service.get("fallback", "").is_empty():
				return {"ok": false, "reason": "Missing/ambiguous required binding: " + service.role}
			diagnostic.emit("Optional capability disabled: " + service.role)
		for dependency: String in service.get("dependencies", []):
			if not roles.has(dependency):
				return {"ok": false, "reason": "Missing dependency: " + dependency}
	return {"ok": not services.is_empty(), "reason": "Mode owner must declare required services."}

func required_service_lost(scope: String, role: String) -> bool:
	if scope != _state.session or scope.is_empty() or _state.status == "ending":
		return false
	gates.safe = false
	if _publishing:
		_deferred.append(func(): required_service_lost(scope, role))
		return true
	_commit({"ready": false, "application": "recovery"}, "Required service lost: " + role)
	return true

func confirm_death(scope: String, authority: RefCounted) -> bool:
	if _publishing:
		_deferred.append(func(): confirm_death(scope, authority))
		return true
	if scope != _state.session or _state.status != "alive" or authority == null or authority != _death_authority:
		return false # Actual CHAR provider must own this entry authority at integration.
	_commit({"status": "dead", "ready": false}, "authoritative death", "confirmed_death")
	return true

func _plain_data(value: Variant) -> bool:
	if value is Dictionary:
		for key: Variant in value:
			if not key is String or not _plain_data(value[key]):
				return false
		return true
	if value is Array:
		for item: Variant in value:
			if not _plain_data(item):
				return false
		return true
	return typeof(value) in [TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING]

func _arrive_menu() -> void:
	if _operation.intent.mode == "shutdown":
		_commit({"application": "ending"}, "safe shutdown teardown complete")
		_finish("Succeeded", "Safe shutdown teardown complete.")
	elif _operation.intent.mode == "death":
		_commit({"phase": "presentation"}, "independent death presentation")
		var checked: Dictionary = provider.death_presentation(ticket())
		if checked.get("pending", false):
			return
		complete_presentation(ticket(), checked)
	else:
		_open_menu()

func complete_presentation(value: Dictionary, result: Dictionary) -> bool:
	if _defer_completion("complete_presentation", value, result):
		return true
	if not _matches(value, "presentation"):
		return false
	_open_menu() # Failed/missing playback bypasses with no replacement death notice.
	return true

func _open_menu() -> void:
	_commit({"phase": "menu"}, "preparing usable menu")
	var checked: Dictionary = provider.open_menu(ticket())
	if not checked.get("pending", false):
		complete_menu(ticket(), checked)

func complete_menu(value: Dictionary, result: Dictionary) -> bool:
	if _defer_completion("complete_menu", value, result):
		return true
	if not _matches(value, "menu"):
		return false
	if not result.get("ok", false):
		_menu_recovery = {"reason": _operation.intent.mode}
		_commit({"application": "recovery"}, "Menu failed: Retry, Return to Setup or Quit.")
		_finish("Failed", result.get("reason", "Menu unavailable."))
	else:
		_menu_recovery.clear()
		_commit({"application": "menu"}, "usable menu", "menu_ready")
		_finish("Succeeded", "Menu ready.")
	return true

func recover_menu() -> bool:
	if _publishing:
		_deferred.append(recover_menu)
		return true
	if busy() or _blocked or not _state.session.is_empty() or not _startup_ready:
		return false
	# Cleanup and presentation already completed. Do not replay either on retry.
	_serial += 1
	var intent := {"id": "menu-retry-%d" % _serial, "mode": "return", "origin": ""}
	_operation = {"intent": intent, "generation": _serial, "scope": ""}
	_receipts[intent.id] = {"intent": intent, "result": {"kind": "pending"}}
	_operation_hold = gates.acquire("operation:" + intent.id, "", ["simulation", "input"])
	_commit({"operation": intent.id}, "menu recovery")
	_open_menu()
	return true

func _finish(kind: String, reason: String, unsafe_cleanup := false) -> void:
	_finishing = true
	var id: String = _operation.intent.id
	randomness.discard(_operation.get("random_ticket", {}))
	var result := {"kind": kind, "id": id, "reason": reason, "session": _state.session}
	_receipts[id].result = result.duplicate(true)
	_operation.clear()
	randomness.suspend_operation(false)
	gates.release(_operation_hold, "operation:" + id)
	_commit({"operation": "", "phase": "cleanup_failed" if unsafe_cleanup else "idle"}, reason)
	_finishing = false
	terminal.emit(result.duplicate(true))

func dispose() -> void:
	# Application/test owner invokes after scopes end; break owned subscriptions.
	randomness.dispose()
	for event: Signal in [state_changed, milestone, terminal, retiring, diagnostic, gates.changed]:
		for connection: Dictionary in event.get_connections():
			event.disconnect(connection.callable)
	_deferred.clear()

func _defer_completion(method: String, value: Dictionary, result: Dictionary) -> bool:
	if not _publishing:
		return false
	var captured_ticket := value.duplicate(true)
	var captured_result := result.duplicate(true)
	_deferred.append(func(): call(method, captured_ticket, captured_result))
	return true

func _commit(fields: Dictionary, reason: String, event := "", context: Dictionary = {}) -> void:
	if _publishing:
		_deferred.append(func(): _commit(fields, reason, event, context))
		return
	var previous := snapshot()
	_state.merge(fields, true)
	gates.session = _state.session
	gates.ready = _state.ready
	if previous == _state and event.is_empty():
		return
	_state.version += 1
	_publishing = true
	state_changed.emit(previous, snapshot(), reason)
	if not event.is_empty():
		milestone.emit(event, context.duplicate(true) if not context.is_empty() else snapshot())
	gates.changed.emit()
	_publishing = false
	while not _deferred.is_empty():
		var action: Callable = _deferred.pop_front()
		action.call()
