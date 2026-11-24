extends RefCounted
## CHAR helper. All durable facts live in the composed actor record.
const F = preload("res://scripts/rule/actor_formulas.gd")
const P = preload("res://scripts/mod/package_library.gd")
const Policy = preload("res://scripts/data/death_policy.gd")
const LIMIT := 1000000000
var _owner: WeakRef
var _content := -1
var _policy: Dictionary = {}

func _init(owner: RefCounted) -> void:
	_owner = weakref(owner)

func prepare() -> bool:
	var a: RefCounted = _owner.get_ref()
	if a == null or a.definitions == null: return false
	if _content == a.definitions.content_ticket(): return true
	var found: Dictionary = a.definitions.query("actor.baseline","death","player")
	if not found.ok: return false
	_policy = capture_definition(found.record)
	_policy["content_sha256"] = JSON.stringify(_policy.value).sha256_text()
	_content = a.definitions.content_ticket()
	return true

func capture_definition(value: Variant) -> Variant:
	# Trusted, already published DATA metadata may use StringName field keys.
	# Capture portable string-keyed provenance; raw owner requests never coerce.
	if value is Dictionary:
		var result := {}
		var provenance: bool = value.get("provider") is String and value.get("file") is String and value.get("version") is String
		for key: Variant in value:
			# Package/file/version and the resolved-value hash are portable. Expanded
			# roots and root-bound omission tokens belong to one publication only.
			if provenance and str(key) in ["root","token"]: continue
			result[str(key)] = capture_definition(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item: Variant in value: result.append(capture_definition(item))
		return result
	return value

static func empty() -> Dictionary:
	return {"schema":"lethal-retention-v1","events":{},"count":0,"active":{},"dead":{}}

func fail(reason: String, kind := "unavailable") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason}

func current(r: Dictionary, allow_dead := false) -> bool:
	var a: RefCounted = _owner.get_ref()
	if a == null or a.definitions == null: return false
	var core: SessionLifecycle = a._core.get_ref()
	if core == null: return false
	return core.lethal_resolution_current(r.session,a,allow_dead) and a._actors.has(r.actor) and a._actors[r.actor].record.session == r.session and a.definitions.content_ticket() == r.content

func callback(provider: Object, method: String, context: Dictionary) -> Dictionary:
	if not is_instance_valid(provider) or not provider.has_method(method): return fail("Required prevention method absent.")
	var monitor := preload("res://scripts/rule/formula_error_monitor.gd").new()
	OS.add_logger(monitor)
	var value: Variant = provider.call(method,context.duplicate(true))
	OS.remove_logger(monitor)
	# Reserve the enclosing actor/event/index depth so accepted opaque receipts
	# remain representable by the complete checkpoint validator.
	if not monitor.errors.is_empty() or not value is Dictionary or not _owner.get_ref()._plain(value,6): return fail("Required prevention callback failed or returned malformed data.")
	return {"ok":true,"value":value}

func outcome(e: Dictionary) -> Dictionary:
	var result: Dictionary = e.result.duplicate(true)
	result["phase"] = e.phase
	result["ok"] = e.phase in ["prevented","dead"]
	result["kind"] = "lethal"
	result["continuation_allowed"] = e.phase == "prevented"
	if not result.ok:
		# The retained result seed describes the eventual debit. Pending callers
		# receive actual committed pool changes: none until atomic settlement.
		result.applied = 0
		result.remainder = result.requested
	return result

func resolve(r: Dictionary) -> Dictionary:
	var a: RefCounted = _owner.get_ref()
	if not current(r,true): return fail("Lethal context retired.","stale")
	var record: Dictionary = a._actors[r.actor].record
	var state: Dictionary = record.get("lethal",{})
	var e: Dictionary = state.get("events",{}).get(r.caller,{}).get(r.operation,{})
	if not e.is_empty():
		if e.request != r: return fail("Lethal identity reused with changed intent.","identity_conflict")
		if e.phase in ["prevented","dead"]: return outcome(e)
	elif not state.get("active",{}).is_empty(): return fail("Another lethal event requires settlement.","busy")
	else:
		if not current(r) or record.revision != r.revision or record.current.health <= 0: return fail("New lethal event requires a current living actor.","stale")
		if record.revision >= LIMIT-2 or state.get("count",0) >= 4096: return fail("Lethal identity/revision retention exhausted.","overflow")
		if not prepare(): return fail("Required death policy unavailable.")
		if state.is_empty():
			state = empty()
			record["lethal"] = state
			record.schema = "actor-state-v4"
		var maximum: int = a._actors[r.actor].derived.limits.health
		e = {"request":r.duplicate(true),"policy":_policy.duplicate(true),"phase":"sources","catalog":{},"sources":[],"cursor":0,"decisions":{},"settlements":{},"result":{"schema":"lethal-outcome-v1","session":r.session,"actor":r.actor,"caller":r.caller,"operation":r.operation,"attribution":r.attribution.duplicate(true),"requested":r.amount,"applied":record.current.health,"remainder":r.amount-record.current.health,"before":record.current.health,"after":record.current.health,"maximum":maximum,"restored":0,"reason":"prevention-sources-required"},"acknowledged":false}
		if not state.events.has(r.caller): state.events[r.caller] = {}
		state.events[r.caller][r.operation] = e
		state.count += 1
		state.active = {"caller":r.caller,"operation":r.operation}
		record.revision += 1
		a._sync_vital_hold(r.actor)
	if not current(r): return fail("Event retained after scope retirement.","stale")
	var core: SessionLifecycle = a._core.get_ref()
	var binding: Dictionary = core.prevention_provider(r.session)
	if binding.is_empty(): return outcome(e)
	var provider: Object = binding.provider
	var context := {"event":r.duplicate(true),"step":"catalog","source":{},"decision":{}}
	if e.phase == "sources":
		var queried := callback(provider,"lethal_sources",context)
		if not current(r) or not queried.ok: return outcome(e)
		var catalog: Dictionary = queried.value
		if catalog.size() != 4 or typeof(catalog.get("ok")) != TYPE_BOOL or not catalog.ok or catalog.get("provider") != binding.id or not F.integer(catalog.get("revision"),1,LIMIT) or not catalog.get("sources") is Array or catalog.sources.size() > 64: return outcome(e)
		var ids := {}
		for source: Variant in catalog.sources:
			if not source is Dictionary or source.size() != 3 or not P.valid_id(source.get("id")) or ids.has(source.id) or not F.integer(source.get("revision"),1,LIMIT) or not F.integer(source.get("priority"),-1000000,1000000): return outcome(e)
			ids[source.id] = true
		e.catalog = catalog.duplicate(true)
		e.sources = catalog.sources.duplicate(true)
		for source: Dictionary in e.sources: source.priority = e.policy.value.priorities.get(source.id,source.priority)
		e.sources.sort_custom(func(x: Dictionary,y: Dictionary): return x.priority < y.priority if x.priority != y.priority else x.id < y.id)
		e.phase = "evaluation"
		e.result.reason = "prevention-evaluation-required"
	if e.catalog.provider != binding.id: return outcome(e)
	context["catalog"] = e.catalog.duplicate(true)
	while e.cursor < e.sources.size():
		var source: Dictionary = e.sources[e.cursor]
		context.source = source.duplicate(true)
		if not e.decisions.has(source.id):
			context.step = "evaluate"
			var evaluated := callback(provider,"lethal_evaluate",context)
			if not current(r) or not evaluated.ok: return outcome(e)
			var decision: Dictionary = evaluated.value
			if decision.size() != 5 or typeof(decision.get("ok")) != TYPE_BOOL or not decision.ok or decision.get("source") != source.id or decision.get("revision") != source.revision or typeof(decision.get("revision")) != TYPE_INT or typeof(decision.get("success")) != TYPE_BOOL or not decision.get("receipt") is Dictionary or decision.receipt.is_empty(): return outcome(e)
			e.decisions[source.id] = decision.duplicate(true)
		var decision: Dictionary = e.decisions[source.id]
		if decision.success:
			e.result.reason = "prevention-consumption-required"
			# Success cost is owner-defined and idempotent under event/source identity.
			# A committed prefix cannot be undone if the response is lost.
			if not e.settlements.has(source.id):
				context.step = "settle-success"
				context.decision = decision.duplicate(true)
				var consumed := callback(provider,"lethal_consume",context)
				if not current(r) or not consumed.ok: return outcome(e)
				var receipt: Dictionary = consumed.value
				if receipt.size() != 4 or typeof(receipt.get("ok")) != TYPE_BOOL or not receipt.ok or receipt.get("source") != source.id or receipt.get("revision") != source.revision or typeof(receipt.get("revision")) != TYPE_INT or not receipt.get("receipt") is Dictionary or receipt.receipt.is_empty(): return outcome(e)
				e.settlements[source.id] = receipt.duplicate(true)
			e.result.after = Policy.health(e.result.maximum,e.policy.value)
			e.result.restored = e.result.after
			e.phase = "prevented"
			e.result.reason = "prevention-settled"
			break
		e.cursor += 1
		e.result.reason = "prevention-evaluation-required"
	if e.phase != "prevented":
		e.result.after = 0
		e.phase = "dead"
		e.result.reason = "confirmed-death"
		state.dead = {"caller":r.caller,"operation":r.operation}
	# Coherent local publication precedes CORE or observer callbacks.
	record.current.health = e.result.after
	record.revision += 1
	e.result["revision"] = record.revision
	state.active = {}
	if e.phase == "dead" and r.caller != "char-exhaustion": core.confirm_actor_death(r.session,a,r.actor,state.dead)
	if a._actors.has(r.actor) and a._actors[r.actor].record.session == r.session: a._sync_vital_hold(r.actor)
	var result := outcome(e)
	if r.caller != "char-exhaustion": a.lethal_committed.emit(result.duplicate(true))
	return result

func valid(record: Dictionary) -> bool:
	if not P.valid_id(record.get("actor")) or not P.valid_id(record.get("session")) or not F.integer(record.get("revision"),1,LIMIT) or not F.integer(record.get("content"),0,LIMIT) or not record.get("current") is Dictionary: return false
	if not prepare() or record.content != _content: return false
	var s: Variant = record.get("lethal")
	if not s is Dictionary or s.size() != 5 or s.get("schema") != "lethal-retention-v1" or not s.get("events") is Dictionary or not F.integer(s.get("count"),0,4096) or not s.get("active") is Dictionary or not s.get("dead") is Dictionary: return false
	var count := 0
	var active := {}
	var dead := {}
	var intervals: Array = []
	for caller: Variant in s.events:
		if not P.valid_id(caller) or not s.events[caller] is Dictionary or s.events[caller].is_empty(): return false
		for operation: Variant in s.events[caller]:
			count += 1
			var e: Variant = s.events[caller][operation]
			if not e is Dictionary or e.size() != 10 or not preload("res://scripts/char/vital_records.gd").request_valid(e.get("request")) or not e.get("policy") is Dictionary or not e.policy.get("value") is Dictionary or not Policy.validate(e.policy.value).is_empty() or e.get("phase") not in ["sources","evaluation","prevented","dead"] or not e.get("catalog") is Dictionary or not e.get("sources") is Array or not e.get("decisions") is Dictionary or not e.get("settlements") is Dictionary or typeof(e.get("acknowledged")) != TYPE_BOOL or not F.integer(e.get("cursor"),0,e.sources.size()) or e.sources.size() > 64: return false
			var r: Dictionary = e.request
			if not e.phase is String: return false
			if e.policy != _policy: return false
			if r.caller != caller or r.operation != operation or r.session != record.session or r.actor != record.actor or r.content != record.content or r.pool != "health" or r.action not in ["damage","drain","spend"]: return false
			var result: Variant = e.get("result")
			var terminal: bool = e.phase in ["prevented","dead"]
			if not result is Dictionary or result.size() != (15 if terminal else 14) or result.get("schema") != "lethal-outcome-v1" or result.get("reason") not in ["prevention-sources-required","prevention-evaluation-required","prevention-consumption-required","prevention-settled","confirmed-death"]: return false
			for key in ["session","actor","caller","operation","attribution"]:
				if result.get(key) != r[key]: return false
			for key in ["requested","applied","remainder","before","after","maximum","restored"]:
				if not F.integer(result.get(key),0,LIMIT): return false
			if result.maximum < 1 or result.before < 1 or result.before > result.maximum or result.requested != r.amount or result.applied != result.before or result.remainder != r.amount-result.applied: return false
			if terminal:
				if not F.integer(result.get("revision"),r.revision+2,record.revision): return false
				if result.after != (Policy.health(result.maximum,e.policy.value) if e.phase == "prevented" else 0) or result.restored != result.after: return false
				if result.revision == record.revision and record.current.get("health") != result.after: return false
				if e.acknowledged and result.revision >= record.revision: return false
			else:
				if not active.is_empty() or result.after != result.before or result.restored != 0 or e.acknowledged: return false
				active = {"caller":caller,"operation":operation}
				if record.current.get("health") != result.before: return false
			intervals.append({"start":r.revision,"end":result.revision if terminal else record.revision,"dead":e.phase == "dead"})
			if e.phase == "dead":
				if not dead.is_empty() or e.acknowledged: return false
				dead = {"caller":caller,"operation":operation}
			if e.phase == "sources":
				if not e.catalog.is_empty() or not e.sources.is_empty() or not e.decisions.is_empty() or not e.settlements.is_empty() or e.cursor != 0: return false
				continue
			if e.catalog.size() != 4 or e.catalog.get("ok") != true or typeof(e.catalog.ok) != TYPE_BOOL or not P.valid_id(e.catalog.get("provider")) or not F.integer(e.catalog.get("revision"),1,LIMIT) or not e.catalog.get("sources") is Array or e.catalog.sources.size() != e.sources.size(): return false
			var sources := {}
			for source: Variant in e.catalog.sources:
				if not source is Dictionary or source.size() != 3 or not P.valid_id(source.get("id")) or sources.has(source.id) or not F.integer(source.get("revision"),1,LIMIT) or not F.integer(source.get("priority"),-1000000,1000000): return false
				sources[source.id] = source.duplicate(true)
				sources[source.id].priority = e.policy.value.priorities.get(source.id,source.priority)
			var ordered: Array = sources.values()
			ordered.sort_custom(func(x: Dictionary,y: Dictionary): return x.priority < y.priority if x.priority != y.priority else x.id < y.id)
			if ordered != e.sources: return false
			var successes := 0
			for index in e.sources.size():
				var source: Dictionary = e.sources[index]
				var d: Variant = e.decisions.get(source.id)
				if d == null:
					if index < e.cursor or (terminal and e.phase == "dead"): return false
					continue
				if index > e.cursor or not d is Dictionary or d.size() != 5 or typeof(d.get("ok")) != TYPE_BOOL or not d.ok or d.get("source") != source.id or not F.integer(d.get("revision"),source.revision,source.revision) or typeof(d.get("success")) != TYPE_BOOL or not d.get("receipt") is Dictionary or d.receipt.is_empty(): return false
				if d.success:
					successes += 1
					if index != e.cursor or e.phase == "dead": return false
					var cost: Variant = e.settlements.get(source.id)
					if cost == null:
						if terminal: return false
					elif not cost is Dictionary or cost.size() != 4 or typeof(cost.get("ok")) != TYPE_BOOL or not cost.ok or cost.get("source") != source.id or not F.integer(cost.get("revision"),source.revision,source.revision) or not cost.get("receipt") is Dictionary or cost.receipt.is_empty(): return false
				elif index >= e.cursor: return false
			if successes > 1 or e.settlements.size() != (1 if e.phase == "prevented" else 0) or (e.phase == "prevented" and successes != 1) or (e.phase == "dead" and e.cursor != e.sources.size()): return false
			for id: Variant in e.decisions:
				if not sources.has(id): return false
	intervals.sort_custom(func(x: Dictionary,y: Dictionary): return x.start < y.start)
	var end := 0
	var ended := false
	for interval: Dictionary in intervals:
		if ended or interval.start < end: return false
		end = interval.end
		ended = interval.dead
	return count == s.count and active == s.active and dead == s.dead and (dead.is_empty() or record.current.health == 0)
