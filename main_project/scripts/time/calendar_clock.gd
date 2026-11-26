extends RefCounted
## Sole TIME timestamp writer. No due-work scheduler is installed in increment 1.
signal committed(outcome: Dictionary)
const Calendar = preload("res://scripts/time/calendar.gd")
const Policy = preload("res://scripts/data/calendar_policy.gd")
const FRACTION_SCALE := 1000000000000 # ns input × rate millionths -> game ms.
var definitions: RefCounted
var _core: WeakRef
var _scope := ""
var _policy: Dictionary = {}
var _timestamp := 0
var _fraction := 0
var _receipts: Dictionary = {}
var _ordinary_receipts: Dictionary = {} # interval -> packed immutable numeric receipt.
var _busy := false
var _ordinary: WeakRef
var _activities: Dictionary = {}
var _required_work := false
var _compatibility := ""

static func compatibility(policy: Dictionary) -> String:
	var weekday: Dictionary = policy.weekday
	var seasons: Dictionary = policy.seasons
	return JSON.stringify(["fixed-360-millisecond-v1",weekday.rule,weekday.get("anchor_day",0),weekday.get("index",0),seasons.winter,seasons.spring,seasons.summer,seasons.fall]).sha256_text()

static func activity_hold_owner(id: String) -> String:
	# Valid activity IDs cannot contain ':'. This namespace cannot alias CORE
	# focus/shutdown/operation or UI window owners, even for an ID like "focus".
	return "time-activity:"+id

func _init(core: RefCounted) -> void:
	_core = weakref(core)

func _failure(reason: String, kind := "rejected") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"scheduler_ready":false}

func preflight(mode: String, restored: Variant) -> Dictionary:
	if definitions == null: return _failure("Resolved DATA unavailable.")
	var resolved: Dictionary = definitions.query(Policy.DOMAIN,"policy","world")
	if not resolved.ok: return resolved
	var error := Policy.reason(resolved.record.value)
	if not error.is_empty(): return _failure(error)
	var candidate := Policy.normalized(resolved.record.value)
	var compatible := compatibility(candidate)
	return validate_snapshot(restored,compatible) if mode == "load" else {"ok":mode == "new"}

func initialize(ticket: Dictionary, mode: String, restored: Variant = null) -> Dictionary:
	var core: RefCounted = _core.get_ref()
	if _busy or core == null or core.ticket() != ticket or core.snapshot().phase != "baseline" or core.gates.simulation(): return _failure("Current gated baseline ticket required.")
	if definitions == null: return _failure("Resolved DATA calendar unavailable.")
	var resolved: Dictionary = definitions.query(Policy.DOMAIN,"policy","world")
	if not resolved.ok: return resolved
	var value: Dictionary = resolved.record.value
	var error := Policy.reason(value)
	if not error.is_empty(): return _failure(error)
	var candidate := Policy.normalized(value)
	var compatible := compatibility(candidate)
	var timestamp: int = Calendar.encode(candidate.opening).timestamp
	var fraction := 0
	if mode == "load":
		var checked := validate_snapshot(restored,compatible)
		if not checked.ok: return checked
		timestamp = restored.timestamp
		fraction = restored.fraction
	elif mode != "new": return _failure("Unsupported initialization mode.")
	# Publish only after complete candidate validation. Start-only/rate changes
	# never rewrite restored instants or absolute deadlines.
	_scope = ticket.scope
	_policy = candidate
	_compatibility = compatible
	_timestamp = timestamp
	_fraction = fraction
	_receipts.clear()
	_ordinary_receipts.clear()
	_activities.clear()
	_required_work = false
	return {"ok":true,"timestamp":_timestamp,"elapsed_origin":_timestamp,"fraction":_fraction,"scheduler_ready":false}

func bind_ordinary(owner: RefCounted) -> bool:
	if _ordinary != null and is_instance_valid(_ordinary.get_ref()) and _ordinary.get_ref() != owner: return false
	_ordinary = weakref(owner)
	return true

func bind_activities(services: Array) -> Dictionary:
	var core: RefCounted = _core.get_ref()
	if core == null or core.snapshot().session != _scope or not core.busy() or core.snapshot().phase != "initializing": return _failure("CORE initializing binding boundary required.")
	var bindings := {}
	var required := false
	for service: Dictionary in services:
		if service.has("calendar_due_work"):
			if typeof(service.calendar_due_work) != TYPE_BOOL: return _failure("Explicit due-work requirement must be boolean.")
			required = required or service.calendar_due_work
		if not service.has("calendar_activity"): continue
		var id: Variant = service.calendar_activity
		var owner: Variant = service.get("provider")
		if not id is String or not preload("res://scripts/mod/package_library.gd").valid_id(id) or bindings.has(id) or not is_instance_valid(owner) or not owner.has_method("calendar_activity_current") or service.get("lifetime") != "session" or service.get("ready") != true: return _failure("Current declared calendar activity provider required.")
		bindings[id] = weakref(owner)
	_activities = bindings
	_required_work = required
	return {"ok":true,"scheduler_ready":false}

func query() -> Dictionary:
	if _scope.is_empty(): return _failure("No calendar session.")
	var result := {"ok":true,"session":_scope,"timestamp":_timestamp,"fraction":_fraction,"fraction_scale":FRACTION_SCALE,"calendar":Calendar.context(_timestamp,_policy),"rate_units":_policy.rate_units,"rate_scale":Policy.RATE_SCALE,"scheduler_ready":false}
	result.make_read_only()
	return result

func capture_snapshot() -> Dictionary:
	var core: RefCounted = _core.get_ref()
	if _busy or _required_work or core == null or _scope.is_empty() or core.snapshot().session != _scope or not core.gates.safe or core.gates.simulation() or core.gates.blocked("save") or core.busy(): return _failure("Settled gated save boundary required.")
	return {"ok":true,"state":{"schema":"calendar-clock-state-v1","timestamp":_timestamp,"fraction":_fraction,"fraction_scale":FRACTION_SCALE,"compatibility":_compatibility,"rate_units":_policy.rate_units,"settled":true}}

static func validate_snapshot(value: Variant, compatible: String) -> Dictionary:
	if not value is Dictionary or value.size() != 7 or value.get("schema") != "calendar-clock-state-v1" or value.get("fraction_scale") != FRACTION_SCALE or typeof(value.get("fraction_scale")) != TYPE_INT or value.get("settled") != true or typeof(value.get("settled")) != TYPE_BOOL: return {"ok":false,"reason":"Unsupported complete settled clock snapshot required."}
	if not Calendar.integer(value.get("timestamp"),0,Calendar.MAX) or not Calendar.integer(value.get("fraction"),0,FRACTION_SCALE-1) or not Calendar.integer(value.get("rate_units"),1,1000000000000) or value.get("compatibility") != compatible: return {"ok":false,"reason":"Malformed or incompatible clock snapshot."}
	return {"ok":true}

func _current() -> bool:
	var core: RefCounted = _core.get_ref()
	return core != null and not _scope.is_empty() and core.snapshot().session == _scope and core.snapshot().ready and core.gates.safe and not core.busy()

func committing() -> bool:
	return _busy

func ordinary(owner: RefCounted, request: Dictionary) -> Dictionary:
	if not _current() or _ordinary == null or _ordinary.get_ref() != owner: return _failure("Stale ordinary scope/provider.")
	if _busy: return _failure("Clock commitment in progress.","busy")
	if request.size() != 5 or request.get("session") != _scope or not Calendar.integer(request.get("interval"),1,Calendar.MAX) or not Calendar.integer(request.get("elapsed_ns"),0,Calendar.MAX) or not Calendar.integer(request.get("eligibility"),0,Calendar.MAX) or not Calendar.integer(request.get("provider"),1,Calendar.MAX): return _failure("Current integer elapsed interval required.")
	var core: RefCounted = _core.get_ref()
	if not core.calendar_source_current(request.provider): return _failure("Retired ordinary provider generation.")
	var key := "ordinary:"+str(request.interval)
	if _ordinary_receipts.has(request.interval):
		var retained: PackedInt64Array = _ordinary_receipts[request.interval]
		if request.elapsed_ns != retained[0] or request.eligibility != retained[1] or request.provider != retained[2]: return _failure("Identity reused with changed intent.")
		return _outcome(retained[3],retained[4],retained[5],"eligible-simulation",str(request.interval),retained[0],retained[4]-retained[3])
	if not core.calendar_interval_current(request): return _failure("Obsolete interval or eligibility generation.")
	if not core.gates.simulation(): return _failure("Ordinary progression suspended.")
	if _required_work: return _failure("Required due-work scheduler unavailable.","deferred")
	var scaled := product(request.elapsed_ns,_policy.rate_units,_fraction)
	if not scaled.ok or scaled.whole > Calendar.MAX-_timestamp: return _failure("Calendar endpoint overflow.")
	return _commit(key,request,scaled.whole,scaled.fraction,"eligible-simulation")

func activity(owner: RefCounted, request: Dictionary) -> Dictionary:
	if not _current(): return _failure("Stale activity session.")
	if _busy: return _failure("Clock is owned by another commitment.","busy")
	if request.size() != 5 or request.get("session") != _scope or not request.get("owner") is String or not request.get("operation") is String or request.operation.is_empty() or request.operation.length() > 160 or not request.get("reason") is String or request.reason.is_empty() or request.reason.length() > 160 or not Calendar.integer(request.get("duration_ms"),1,Calendar.MAX): return _failure("Complete explicit activity request required.")
	var binding: WeakRef = _activities.get(request.owner)
	if binding == null or binding.get_ref() != owner: return _failure("Undeclared activity owner.")
	var key: String = "activity:"+request.owner+":"+request.operation
	if _receipts.has(key): return _retry(key,request)
	var core: RefCounted = _core.get_ref()
	if core.gates.blocked_except("simulation",activity_hold_owner(request.owner),_scope): return _failure("Independent suspension blocks activity.")
	if _required_work: return _failure("Required due-work scheduler unavailable.","deferred")
	if request.duration_ms > Calendar.MAX-_timestamp: return _failure("Calendar endpoint overflow.")
	var captured := request.duplicate(true)
	_busy = true
	var monitor := preload("res://scripts/rule/formula_error_monitor.gd").new()
	OS.add_logger(monitor)
	var valid: Variant = owner.call("calendar_activity_current",request.duplicate(true))
	OS.remove_logger(monitor)
	_busy = false
	if not monitor.errors.is_empty(): return _failure("Activity authorization callback failed.")
	if request != captured or typeof(valid) != TYPE_BOOL or not valid or not _current() or core.gates.blocked_except("simulation",activity_hold_owner(captured.owner),_scope) or binding.get_ref() != owner: return _failure("Activity authorization expired.")
	return _commit(key,request,request.duration_ms,_fraction,request.reason)

func _retry(key: String, request: Dictionary) -> Dictionary:
	return _receipts[key].result.duplicate(true) if _receipts[key].request == request else _failure("Identity reused with changed intent.")

func _commit(key: String, request: Dictionary, duration: int, fraction: int, reason: String) -> Dictionary:
	var previous := _timestamp
	_timestamp += duration
	_fraction = fraction
	var result := _outcome(previous,_timestamp,_fraction,reason,request.get("operation",str(request.get("interval",""))),request.get("elapsed_ns",0),request.get("duration_ms",duration))
	if request.has("elapsed_ns"):
		# All ordinary receipt facts are numeric except run-constant labels/scope.
		# Keep six packed int64 values, not two deep per-frame Dictionaries.
		_ordinary_receipts[request.interval] = PackedInt64Array([request.elapsed_ns,request.eligibility,request.provider,previous,_timestamp,_fraction])
	else:
		_receipts[key] = {"request":request.duplicate(true),"result":result.duplicate(true)}
	_busy = true
	if duration > 0:
		var outcome := result.duplicate(true)
		outcome.make_read_only()
		committed.emit(outcome)
	_busy = false
	return result

func _outcome(previous: int, endpoint: int, fraction: int, reason: String, operation: String, eligible_ns: int, requested_ms: int) -> Dictionary:
	return {"ok":true,"kind":"completed","session":_scope,"old":previous,"new":endpoint,"requested_ms":requested_ms,"actual_ms":endpoint-previous,"eligible_ns":eligible_ns,"operation":operation,"reason":reason,"fraction":fraction,"scheduler_ready":false,"required_due_work":false}

func receipt_count() -> int:
	return _ordinary_receipts.size()+_receipts.size()

## Exact nonnegative multiply/divide with prechecked quotient growth. Fast path
## for ordinary frames; bounded binary decomposition for long intervals.
static func product(elapsed: int, rate: int, fraction: int) -> Dictionary:
	if elapsed <= (Calendar.MAX-fraction)/rate:
		var total := elapsed*rate+fraction
		return {"ok":true,"whole":total/FRACTION_SCALE,"fraction":total%FRACTION_SCALE}
	var whole := 0
	var rest := fraction
	var part_whole: int = elapsed/FRACTION_SCALE
	var part_rest: int = elapsed%FRACTION_SCALE
	var multiplier := rate
	while multiplier > 0:
		if multiplier%2 == 1:
			var carry: int = (rest+part_rest)/FRACTION_SCALE
			if part_whole > Calendar.MAX-whole-carry: return {"ok":false}
			whole += part_whole+carry
			rest = (rest+part_rest)%FRACTION_SCALE
		multiplier /= 2
		if multiplier == 0: break
		var carry: int = (part_rest*2)/FRACTION_SCALE
		if part_whole > (Calendar.MAX-carry)/2: return {"ok":false}
		part_whole = part_whole*2+carry
		part_rest = (part_rest*2)%FRACTION_SCALE
	return {"ok":true,"whole":whole,"fraction":rest}

func retire(scope: String) -> void:
	if scope != _scope: return
	_scope = ""
	_policy.clear()
	_receipts.clear()
	_ordinary_receipts.clear()
	_activities.clear()
	_timestamp = 0
	_fraction = 0
	_compatibility = ""

func dispose() -> void:
	retire(_scope)
	for connection: Dictionary in committed.get_connections(): committed.disconnect(connection.callable)
	_ordinary = null
	definitions = null
