extends RefCounted
## Retained chronological cursor. Providers own indexed next-due queries and
## mutation receipts. This coordinator never materializes an interval's stream.
const Calendar = preload("res://scripts/time/calendar.gd")
const ErrorMonitor = preload("res://scripts/rule/formula_error_monitor.gd")
const DEFAULT_BUDGET := 64
var budget: Variant = DEFAULT_BUDGET
var bindings: Dictionary = {}
var order: Array = []
var precedence: Dictionary = {}
var operation: Dictionary = {}
var _clock: WeakRef
var _running := false
var _serial := 0
var _passes: Dictionary = {}
var _terminal_passes: Dictionary = {}

func _init(clock: RefCounted) -> void:
	_clock = weakref(clock)

func bind(services: Array) -> Dictionary:
	var candidates := {}
	for service: Dictionary in services:
		if not service.get("calendar_due_work",false): continue
		var d: Variant = service.get("calendar_schedule")
		var provider: Variant = service.get("provider")
		if not d is Dictionary or d.size() != 4 or not d.get("id") is String or not preload("res://scripts/mod/package_library.gd").valid_id(d.id) or candidates.has(d.id) or not Calendar.integer(d.get("version"),1,Calendar.MAX) or not d.get("after") is Array or not d.get("interacts") is Array or service.get("lifetime") != "session" or service.get("ready") != true or not is_instance_valid(provider): return {"ok":false,"reason":"Complete current scheduler declaration required."}
		for method: String in ["calendar_schedule_current","calendar_next_due","calendar_due_current","calendar_apply_due","calendar_due_outcome"]:
			if not provider.has_method(method): return {"ok":false,"reason":"Missing required scheduler interface: "+method}
		candidates[d.id] = {"provider":weakref(provider),"declaration":d.duplicate(true)}
	var sorted: Array = candidates.keys()
	sorted.sort()
	var ranked: Array = []
	var remaining := sorted.duplicate()
	for id: String in sorted:
		for field: String in ["after","interacts"]:
			var seen := {}
			for dependency: Variant in candidates[id].declaration[field]:
				if not dependency is String or not candidates.has(dependency) or dependency == id or seen.has(dependency): return {"ok":false,"reason":"Invalid or missing scheduler dependency."}
				seen[dependency] = true
	while not remaining.is_empty():
		var chosen := ""
		for id: String in remaining:
			if candidates[id].declaration.after.all(func(dep): return dep in ranked):
				chosen = id
				break
		if chosen.is_empty(): return {"ok":false,"reason":"Scheduler dependency cycle."}
		ranked.append(chosen)
		remaining.erase(chosen)
	for id: String in sorted:
		for other: String in candidates[id].declaration.interacts:
			if not _precedes(id,other,candidates) and not _precedes(other,id,candidates): return {"ok":false,"reason":"Interacting work requires declared precedence."}
	bindings = candidates
	order = ranked
	precedence = {}
	for id: String in sorted:
		precedence[id] = {}
		for other: String in sorted:
			if _precedes(id,other,candidates): precedence[id][other] = true
	return {"ok":true}

func _precedes(a: String, b: String, directory: Dictionary) -> bool:
	var todo: Array = directory[b].declaration.after.duplicate()
	var seen := {}
	while not todo.is_empty():
		var id: String = todo.pop_back()
		if id == a: return true
		if seen.has(id): continue
		seen[id] = true
		todo.append_array(directory[id].declaration.after)
	return false

func active() -> bool:
	return not operation.is_empty()

func begin(key: String, request: Dictionary, duration: int, fraction: int, reason: String, owner: Object) -> Dictionary:
	if active() or _running: return {"ok":false,"kind":"busy","reason":"A retained advance owns TIME."}
	if not Calendar.integer(budget,1,1000000): return {"ok":false,"kind":"rejected","reason":"Positive bounded work budget required."}
	var clock: RefCounted = _clock.get_ref()
	if _serial == Calendar.MAX: return {"ok":false,"kind":"rejected","reason":"Scheduler operation identity exhausted."}
	_serial += 1
	_passes.clear()
	operation = {"key":key,"request":request.duplicate(true),"owner":weakref(owner),"serial":_serial,"scope":clock._scope,"start":clock._timestamp,"target":clock._timestamp+duration,"fraction":fraction,"initial_fraction":clock._fraction,"reason":reason,"duration":duration,"scan":0,"candidates":{},"cursors":{},"done":{},"instant_done":[],"instant":-1,"interrupted":false,"failed":false,"uncertain":{},"pass":0,"segment":0,"result":{}}
	clock._scheduler_hold(true)
	return process(owner,ticket())

func ticket() -> Dictionary:
	return {} if not active() else {"session":operation.scope,"operation":operation.serial,"pass":operation.pass}

func progress(key: String, request: Dictionary) -> Dictionary:
	if _running: return {"ok":false,"kind":"busy","reason":"Scheduler callback reentrancy."}
	if not active() or operation.key != key: return {"ok":false,"kind":"busy","reason":"A retained advance owns TIME."}
	if operation.request != request: return {"ok":false,"kind":"rejected","reason":"Identity reused with changed scheduler intent."}
	return operation.result.duplicate(true)

func _call(id: String, method: String, packet: Dictionary) -> Dictionary:
	var provider: Object = bindings[id].provider.get_ref()
	if provider == null: return {"ok":false,"reason":"Retired schedule provider."}
	var clock: RefCounted = _clock.get_ref()
	var scope: String = operation.scope
	var monitor := ErrorMonitor.new()
	OS.add_logger(monitor)
	var current: Variant = provider.call("calendar_schedule_current",scope,bindings[id].declaration.version)
	var result: Variant
	if typeof(current) == TYPE_BOOL and current:
		var detached := packet.duplicate(true)
		detached.make_read_only()
		result = provider.call(method,detached)
	OS.remove_logger(monitor)
	if not active() or clock._scope != scope: return {"ok":false,"reason":"Scheduler scope retired during callback."}
	if not monitor.errors.is_empty() or typeof(current) != TYPE_BOOL or not current or not result is Dictionary: return {"ok":false,"reason":"Required schedule callback failed or became stale."}
	return {"ok":true,"value":result.duplicate(true)}

func _packet() -> Dictionary:
	return {"session":operation.scope,"operation":operation.serial,"start":operation.start,"endpoint":operation.target,"committed":_clock.get_ref()._timestamp,"reason":operation.reason,"interrupted":operation.interrupted}

func _matches(packet: Dictionary, result: Dictionary) -> bool:
	return result.get("session") == packet.session and typeof(result.get("operation")) == TYPE_INT and result.operation == packet.operation and result.get("owner") == packet.owner and result.get("occurrence") == packet.occurrence and typeof(result.get("timestamp")) == TYPE_INT and result.timestamp == packet.timestamp and typeof(result.get("revision")) == TYPE_INT and result.revision == packet.revision

func _result(kind: String, reason := "") -> Dictionary:
	var clock: RefCounted = _clock.get_ref()
	var result := {"ok":kind != "failed","kind":kind,"reason":reason,"session":operation.scope,"operation":operation.request.get("operation",str(operation.request.get("interval",""))),"old":operation.start,"new":clock._timestamp,"requested_endpoint":operation.target,"requested_ms":operation.duration,"actual_ms":clock._timestamp-operation.start,"remaining_ms":operation.target-clock._timestamp,"eligible_ns":operation.request.get("elapsed_ns",0),"fraction":clock._fraction,"target_fraction":operation.fraction,"scheduler_ready":true,"required_due_work":true,"settled":kind in ["completed","interrupted"],"continuation":ticket(),"outstanding":operation.candidates.size(),"segment":operation.segment}
	result.planning_remaining = order.size()-operation.scan
	result.reconciliation_required = not operation.uncertain.is_empty()
	result.tail = "discarded" if kind == "interrupted" else ("consumed" if kind == "completed" else "retained")
	if result.settled: result.outstanding = 0
	operation.result = result.duplicate(true)
	return result

func _fail(reason: String) -> Dictionary:
	operation.failed = true
	return _result("failed",reason)

func process(caller: Object, continuation: Dictionary) -> Dictionary:
	var clock: RefCounted = _clock.get_ref()
	if _running: return {"ok":false,"kind":"busy","reason":"Scheduler callback reentrancy."}
	if continuation.size() != 3 or not continuation.get("session") is String or not Calendar.integer(continuation.get("operation"),1,Calendar.MAX) or not Calendar.integer(continuation.get("pass"),0,Calendar.MAX): return {"ok":false,"kind":"rejected","reason":"Complete integer continuation ticket required."}
	var retained_key := str(continuation.get("operation"))+":"+str(continuation.get("pass"))
	if _terminal_passes.has(retained_key):
		var retained: Dictionary = _terminal_passes[retained_key]
		if continuation == retained.ticket and continuation.session == clock._scope and (caller == retained.owner.get_ref() or (clock._ordinary != null and caller == clock._ordinary.get_ref())): return retained.result.duplicate(true)
		return {"ok":false,"kind":"rejected","reason":"Retired or changed continuation."}
	if not active() or continuation.get("session") != operation.scope or continuation.get("operation") != operation.serial or typeof(continuation.get("operation")) != TYPE_INT or not Calendar.integer(continuation.get("pass"),0,Calendar.MAX) or not clock._current(): return {"ok":false,"kind":"rejected","reason":"Stale scheduler continuation."}
	if caller != operation.owner.get_ref() and (clock._ordinary == null or caller != clock._ordinary.get_ref()): return {"ok":false,"kind":"rejected","reason":"Unauthorized continuation provider."}
	if _passes.has(continuation.pass): return _passes[continuation.pass].duplicate(true)
	if continuation != ticket(): return {"ok":false,"kind":"rejected","reason":"Changed continuation identity."}
	if not Calendar.integer(budget,1,1000000): return {"ok":false,"kind":"rejected","reason":"Invalid processing budget."}
	_running = true
	var result := _process_pass()
	_running = false
	if not active(): return result
	operation.pass += 1
	# Retry returns the original pass outcome; current progress supplies next ticket.
	if result.kind in ["completed","interrupted"]:
		if continuation.pass > 0:
			_terminal_passes[retained_key] = {"ticket":continuation.duplicate(true),"owner":operation.owner,"result":result.duplicate(true)}
		for pass_id: int in _passes:
			_terminal_passes[str(operation.serial)+":"+str(pass_id)] = {"ticket":{"session":operation.scope,"operation":operation.serial,"pass":pass_id},"owner":operation.owner,"result":_passes[pass_id]}
		clock._scheduler_finish(operation,result)
		operation = {}
		_passes.clear()
	else:
		operation.result.continuation = ticket()
		result.continuation = ticket()
		_passes[continuation.pass] = result.duplicate(true)
	return result

func _process_pass() -> Dictionary:
	var clock: RefCounted = _clock.get_ref()
	for work in budget:
		if not active(): return {"ok":false,"kind":"rejected","reason":"Retired operation."}
		# Obligations at an already committed instant may settle under independent
		# pause. Moving to another instant requires all independent gates clear.
		if not operation.uncertain.is_empty():
			var uncertain: Dictionary = operation.uncertain
			var reconciled := _call(uncertain.owner,"calendar_due_outcome",uncertain)
			if not active(): return {"ok":false,"kind":"rejected","reason":"Retired operation."}
			if not reconciled.ok: return _fail(reconciled.get("reason","Recovery unavailable."))
			var value: Dictionary = reconciled.value
			if value.get("kind") == "not-applied" and _matches(uncertain,value) and value.get("retry_authorized") == true and typeof(value.get("retry_authorized")) == TYPE_BOOL:
				operation.uncertain = {}
				operation.failed = false
			elif value.get("kind") in ["completed","interrupted"] and _matches(uncertain,value):
				_ack(uncertain,value)
			else: return _fail("Owner reconciliation has not established a committed outcome or safe retry.")
			continue
		if operation.failed: return _fail("Planning failure requires scope replacement; no mutation replay is authorized.")
		if operation.scan < order.size():
			var id: String = order[operation.scan]
			var packet := _packet()
			packet.cursor = operation.cursors.get(id,{})
			var planned := _call(id,"calendar_next_due",packet)
			if not active(): return {"ok":false,"kind":"rejected","reason":"Retired operation."}
			if not planned.ok: return _fail(planned.get("reason","Planning failed."))
			var next: Dictionary = planned.value
			if next.get("kind") != "none":
				if next.size() != 4 or next.get("kind") != "due" or not Calendar.integer(next.get("timestamp"),operation.start+1,operation.target) or next.timestamp < clock._timestamp or not next.get("occurrence") is String or next.occurrence.is_empty() or next.occurrence.length() > 160 or not Calendar.integer(next.get("revision"),0,Calendar.MAX): return _fail("Invalid next-due projection.")
				var identity: String = id+":"+next.occurrence
				if operation.done.has(identity): return _fail("Provider returned a settled occurrence again.")
				if next.timestamp == operation.instant:
					for completed: String in operation.instant_done:
						if precedence[id].has(completed): return _fail("Late same-instant predecessor would violate settled order.")
				operation.candidates[id] = next
			operation.scan += 1
			continue
		# One bounded selection/dispatch (at most one projection per owner).
		var chosen := ""
		var due: int = operation.target
		for id: String in order:
			if operation.candidates.has(id) and (chosen.is_empty() or operation.candidates[id].timestamp < due):
				chosen = id
				due = operation.candidates[id].timestamp
		if operation.interrupted and (chosen.is_empty() or due > clock._timestamp): return _result("interrupted")
		if chosen.is_empty():
			if due > clock._timestamp:
				var authorized: bool = clock._scheduler_authorize_segment(operation)
				if not active(): return {"ok":false,"kind":"rejected","reason":"Retired operation."}
				if not authorized: return _fail("Advance requester expired before a chronological segment.")
				if not clock._scheduler_can_advance(operation.request): return _result("pending-budget","Independent suspension prevents the next chronological segment.")
				clock._scheduler_segment(operation,due)
				if not active(): return {"ok":false,"kind":"rejected","reason":"Retired operation."}
			clock._fraction = operation.fraction
			return _result("completed")
		if operation.instant != due:
			operation.instant = due
			operation.instant_done = []
		var next: Dictionary = operation.candidates[chosen]
		var dispatch := _packet()
		dispatch.merge({"owner":chosen,"occurrence":next.occurrence,"timestamp":due,"revision":next.revision})
		var fresh := _call(chosen,"calendar_due_current",dispatch)
		if not active(): return {"ok":false,"kind":"rejected","reason":"Retired operation."}
		if not fresh.ok or fresh.value.get("kind") != "current" or typeof(fresh.value.get("revision")) != TYPE_INT or fresh.value.revision != next.revision: return _fail("Due projection revision is no longer current.")
		if due > clock._timestamp:
			var authorized: bool = clock._scheduler_authorize_segment(operation)
			if not active(): return {"ok":false,"kind":"rejected","reason":"Retired operation."}
			if not authorized: return _fail("Advance requester expired before a chronological segment.")
			if not clock._scheduler_can_advance(operation.request): return _result("pending-budget","Independent suspension prevents the next chronological segment.")
			clock._scheduler_segment(operation,due)
			if not active(): return {"ok":false,"kind":"rejected","reason":"Retired operation."}
		dispatch.committed = clock._timestamp
		# Set uncertainty BEFORE invoking a mutating owner. No error path may
		# treat absence of a usable return value as evidence of non-commitment.
		operation.uncertain = dispatch.duplicate(true)
		var applied := _call(chosen,"calendar_apply_due",dispatch)
		if not active(): return {"ok":false,"kind":"rejected","reason":"Retired operation."}
		if not applied.ok: return _fail(applied.get("reason","Required owner failed."))
		var value: Dictionary = applied.value
		if value.get("kind") not in ["completed","interrupted"] or not _matches(dispatch,value): return _fail("Owner outcome ambiguous; reconciliation required.")
		_ack(dispatch,value)
	return _result("pending-budget")

func _ack(packet: Dictionary, value: Dictionary) -> void:
	operation.done[packet.owner+":"+packet.occurrence] = true
	operation.cursors[packet.owner] = {"timestamp":packet.timestamp,"occurrence":packet.occurrence}
	operation.instant_done.append(packet.owner)
	operation.interrupted = operation.interrupted or value.kind == "interrupted"
	operation.uncertain = {}
	operation.failed = false
	operation.scan = 0
	operation.candidates = {}

func retire() -> void:
	operation = {}
	_passes.clear()
	_terminal_passes.clear()
	bindings.clear()
	order.clear()
	precedence.clear()
