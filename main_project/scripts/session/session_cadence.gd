extends RefCounted
## No production frequency/order is selected. Mode owners must explicitly supply
## fixed session configuration and dependency-ordered checked consumers.
var core: SessionLifecycle
var scope := ""
var interval := 0.0
var budget := 0
var accumulated := 0.0
var step := 0
var cursor := 0
var consumers: Array[Dictionary] = []
var failed := false

func _init(lifecycle: SessionLifecycle) -> void:
	core = lifecycle
	core.retiring.connect(func(ended: String):
		if ended == scope:
			clear())

func configure(session: String, seconds: float, work_budget: int, ordered: Array[Dictionary]) -> bool:
	if not scope.is_empty() or session != core.snapshot().session or session.is_empty() or not is_finite(seconds) or seconds <= 0.0 or work_budget <= 0 or ordered.is_empty():
		return false
	var seen: Array[String] = []
	for consumer: Dictionary in ordered:
		if seen.has(consumer.id) or not consumer.callback.is_valid():
			return false
		for dependency: String in consumer.get("after", []):
			if not seen.has(dependency):
				return false
		seen.append(consumer.id)
	scope = session
	interval = seconds
	budget = work_budget
	consumers = ordered.duplicate(true)
	return true

func advance(eligible_delta: float) -> void:
	if scope != core.snapshot().session or not core.gates.simulation() or failed or interval <= 0.0:
		return
	if not is_finite(eligible_delta) or eligible_delta < 0.0:
		return
	accumulated += eligible_delta * core.gates.intended_rate
	var spent := 0
	while accumulated + 0.000000001 >= interval and spent < budget and core.gates.simulation() and not scope.is_empty():
		var origin := scope
		var checked: Dictionary = consumers[cursor].callback.call({"session": scope, "step": step, "interval": interval})
		spent += 1
		if scope != origin:
			return
		if not checked.get("ok", false):
			failed = true
			core.required_service_lost(scope, consumers[cursor].id)
			return # Never replay a potentially partially mutating callback.
		cursor += 1
		if cursor == consumers.size():
			cursor = 0
			step += 1
			accumulated = maxf(0.0, accumulated - interval)

func clear() -> void:
	scope = ""
	accumulated = 0.0
	step = 0
	cursor = 0
	consumers.clear()
	failed = false
