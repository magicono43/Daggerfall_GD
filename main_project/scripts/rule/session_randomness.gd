extends RefCounted
## CORE owns this participant. Domain consumers receive revocable source handles,
## never candidate sources or generator state. No owner attempt/result history lives here.
const Seeds = preload("res://scripts/rule/seed_derivation.gd")
const Handle = preload("res://scripts/rule/session_random_source.gd")
const CONTRACT := "session-rng-v1"
var _gates: SessionGates
var _material_provider: Callable
var _candidate: Dictionary = {}
var _active: Dictionary = {}
var _consumers: Dictionary = {}
var _epoch := 0
var _suspended := false
var _disposed := false

func _init(gates: SessionGates, material_provider: Callable = Callable()) -> void:
	_gates = gates
	_material_provider = material_provider

func prepare(ticket: Dictionary, mode: String) -> Dictionary:
	if _disposed or not _candidate.is_empty() or mode not in ["new", "load"]:
		return {"ok": false, "reason": "Random preparation unavailable."}
	_candidate = {"ticket": ticket.duplicate(true), "mode": mode}
	var supplied: Variant = {"ok": false}
	if _material_provider.is_null():
		supplied = Seeds.material_from_os()
	elif _material_provider.is_valid():
		supplied = _material_provider.call(ticket.duplicate(true), mode)
	# The entropy boundary may reenter CORE; cancelled work cannot reappear afterward.
	if _disposed or _candidate.get("ticket", {}) != ticket:
		return {"ok": false, "reason": "Obsolete random preparation."}
	if not supplied is Dictionary or supplied.get("ok") != true or not Seeds.validate_material(supplied.get("material")).ok:
		_candidate.clear()
		return {"ok": false, "reason": "Random initialization material unavailable or malformed."}
	var sources: Dictionary = {}
	for purpose: String in Seeds.PURPOSES:
		var derived := Seeds.derive(supplied.material, purpose)
		if not derived.ok or derived.source == null:
			_candidate.clear()
			return {"ok": false, "reason": "Random derivation failed: " + purpose}
		sources[purpose] = derived.source
	_candidate.merge({"sources": sources, "material_hex": supplied.material.hex_encode()})
	return {"ok": true}

func activate(ticket: Dictionary, scope: String, services: Array) -> Dictionary:
	if _disposed or _candidate.get("ticket", {}) != ticket or not _candidate.has("sources") or scope.is_empty() or not _active.is_empty():
		return {"ok": false, "reason": "Random candidate cannot be activated."}
	var consumers: Dictionary = {}
	for service: Dictionary in services:
		var purposes: Variant = service.get("random_purposes", [])
		if not purposes is Array:
			return {"ok": false, "reason": "Invalid random purpose declaration."}
		if purposes.is_empty():
			continue
		var consumer: Object = service.get("provider")
		if service.get("lifetime") != "session" or not service.get("ready", false) or not is_instance_valid(consumer):
			return {"ok": false, "reason": "Random consumers must be ready session owners."}
		var id := consumer.get_instance_id()
		if not consumers.has(id):
			consumers[id] = {"reference": weakref(consumer), "purposes": []}
		for purpose: Variant in purposes:
			if not purpose is String or purpose not in Seeds.PURPOSES or purpose in consumers[id].purposes:
				return {"ok": false, "reason": "Unknown or duplicate random purpose."}
			consumers[id].purposes.append(purpose)
	_epoch += 1
	_active = _candidate
	_active.scope = scope
	_candidate = {}
	_consumers = consumers
	return {"ok": true}

func discard(ticket: Dictionary) -> void:
	if _candidate.get("ticket", {}) == ticket:
		_candidate.clear()

func suspend_operation(value: bool) -> void:
	_suspended = value

func retire(scope: String) -> void:
	if not _active.is_empty() and _active.scope == scope:
		_epoch += 1
		_active.clear()
		_consumers.clear()

func source(scope: String, consumer: Object, purpose: String) -> Dictionary:
	var checked := _check(scope, consumer, purpose, _epoch)
	if not checked.ok:
		return checked
	return {"ok": true, "source": Handle.new(self, scope, consumer, purpose, _epoch)}

func _check(scope: String, consumer: Object, purpose: String, epoch: int) -> Dictionary:
	if _disposed or _active.is_empty() or epoch != _epoch or scope != _active.scope or scope != _gates.session:
		return {"ok": false, "error": "stale_random_source"}
	if _suspended or not _gates.ready or not _gates.safe:
		return {"ok": false, "error": "random_session_not_ready"}
	if not is_instance_valid(consumer) or not _consumers.has(consumer.get_instance_id()):
		return {"ok": false, "error": "random_consumer_not_bound"}
	var binding: Dictionary = _consumers[consumer.get_instance_id()]
	if binding.reference.get_ref() != consumer or purpose not in binding.purposes:
		return {"ok": false, "error": "random_purpose_not_bound"}
	return {"ok": true}

func draw(scope: String, consumer: Object, purpose: String, epoch: int, bounded: bool, bound: Variant = 0) -> Dictionary:
	var checked := _check(scope, consumer, purpose, epoch)
	if not checked.ok:
		return checked
	var generator: RefCounted = _active.sources[purpose]
	var result: Dictionary = generator.bounded(bound) if bounded else generator.raw()
	return result

func snapshot() -> Dictionary:
	var result := {"contract": CONTRACT, "epoch": _epoch, "scope": "", "sources": {}, "candidate": {}, "disposed": _disposed}
	if not _active.is_empty():
		result.scope = _active.scope
		result.mode = _active.mode
		result.material_hex = _active.material_hex
		result.operation = _active.ticket.duplicate(true)
		for purpose: String in Seeds.PURPOSES:
			var generator: RefCounted = _active.sources[purpose]
			result.sources[purpose] = {"raw_count": generator.raw_count, "logical_count": generator.logical_count}
	if not _candidate.is_empty():
		result.candidate = {"operation": _candidate.ticket.duplicate(true), "mode": _candidate.mode,
			"material_hex": _candidate.get("material_hex", ""), "initialized": _candidate.has("sources")}
	return result # Detached values only; observing or mutating them cannot draw or reseed.

func dispose() -> void:
	_disposed = true
	_epoch += 1
	_active.clear()
	_candidate.clear()
	_consumers.clear()
	_material_provider = Callable()
