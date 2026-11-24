extends RefCounted
## Session CHAR authority. All candidates are private until final freshness check.
const Policy = preload("res://scripts/data/actor_baseline.gd")
const Formula = preload("res://scripts/rule/actor_formulas.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const SCHEMA := "actor-state-v1"
const MAXIMUM := 1000000000
var definitions: RefCounted
var _core: WeakRef
var _actors: Dictionary = {}
var _bindings: Dictionary = {}
var _operation: Dictionary = {}
var _serial := 0
var _policy: Dictionary = {}
var _content := -1
var _fresh_receipts: Dictionary = {}
signal vital_committed(outcome: Dictionary)
signal vital_transition(transition: Dictionary)
var _vital_busy := false
var _vital_holds: Dictionary = {}
const Vital = preload("res://scripts/char/vital_records.gd")

func _init(core: SessionLifecycle) -> void:
	_core = weakref(core)

func fail(reason: String, kind := "invalid_actor") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason}

func formula_operation_current(operation: Dictionary) -> bool:
	return not _operation.is_empty() and operation == _operation and _fresh()

func _fresh() -> bool:
	var core: SessionLifecycle = _core.get_ref()
	if core == null or definitions == null or definitions.content_ticket() != _content: return false
	var scope := str(_operation.get("session",""))
	return core.actor_formula_valid(scope,self,"char.damage",_operation) or (_operation.get("core_ticket") == {} and core.formula_owner_valid(scope,self,"char.damage"))

func service_binding(scope: String) -> Dictionary:
	var ready := false
	for entry in _actors.values(): ready = ready or entry.record.session == scope
	return {"role":"actor_baseline","owner":"CHAR","lifetime":"session","required":true,"ready":ready,"provider":self,"formula_hooks":Formula.HOOKS.duplicate()}

func _begin(scope: String, ticket: Dictionary, actor: Variant) -> Dictionary:
	if _vital_busy or not _operation.is_empty(): return fail("Actor operation already active.","busy")
	var core: SessionLifecycle = _core.get_ref()
	if core == null or definitions == null or not Paths.valid_id(actor): return fail("Required CORE/DATA/actor identity absent.")
	var content: int = definitions.content_ticket()
	if content < 0: return fail("Published definitions required.","before_readiness")
	if _content != content:
		var found: Dictionary = definitions.query(Policy.DOMAIN,"policy","player")
		if not found.ok: return found
		_policy = found.record.duplicate(true)
		_content = content
	_serial += 1
	_operation = {"session":scope,"actor":actor,"serial":_serial,"content":content,"core_ticket":ticket.duplicate(true)}
	if not _fresh():
		_operation.clear()
		return fail("Current CORE baseline or ready session required.","stale")
	return {"ok":true}

func _end(result: Dictionary) -> Dictionary:
	_operation.clear()
	return result

func _number(value: Variant, low := 0, high := MAXIMUM) -> bool:
	return Formula.integer(value,low,high)

func _plain(value: Variant, depth := 0) -> bool:
	# CORE's general value boundary permits floats. Owner records additionally
	# require finite metadata and bounded nesting, including opaque obligations.
	if depth > 32: return false
	if value is Dictionary:
		if value.size() > 4096: return false
		for key in value:
			if not key is String or not _plain(value[key],depth+1): return false
		return true
	if value is Array:
		if value.size() > 4096: return false
		for item in value:
			if not _plain(item,depth+1): return false
		return true
	if value is float: return is_finite(value)
	return typeof(value) in [TYPE_NIL,TYPE_BOOL,TYPE_INT,TYPE_STRING]

func _permanent(group: Variant, bounds: Dictionary) -> bool:
	if not group is Dictionary or group.size() != bounds.size(): return false
	for id in bounds:
		if not _number(group.get(id),int(bounds[id].min),int(bounds[id].max)): return false
	return true

func _identity(identity: Variant) -> bool:
	if not identity is Dictionary or identity.size() != 7: return false
	for key in ["name","race","gender","portrait","reflexes","biography","creation_receipt"]:
		if not identity.get(key) is String or identity[key].is_empty(): return false
	return true

func _choices(choices: Variant) -> bool:
	return choices is Dictionary and choices.size() == 4 and choices.get("template") is String and not choices.template.is_empty() and choices.get("answers") is Array and choices.get("outcomes") is Array and choices.get("custom_career") is Dictionary

func _career(id: Variant) -> Dictionary:
	if not id is String or not Paths.valid_id(id): return fail("Explicit career definition required.")
	var found: Dictionary = definitions.query("actor.inputs","catalog",id)
	if not found.ok: return found
	var value: Dictionary = found.record.value
	if value.kind != "class": return fail("Only structurally validated playable career subset is supported.","incompatible_definition")
	# This qualifies HP, multiplier and progression skill references only. It does
	# not execute biography, grants, resistances, appearance or other career flags.
	var groups: Dictionary = value.data.skills
	var selected: Array = []
	for group in ["primary","major","minor"]:
		for index in groups[group]:
			if not Policy.F.integer(index,0,34): return fail("Unsupported career skill mapping.")
			var skill: String = Policy.SKILLS[int(index)]
			if skill in selected: return fail("Career progression groups overlap.")
			selected.append(skill)
	var code: int = (int(value.data.flags.ability_spell_points) & 0x1c00) >> 10
	var tiers := {}
	for tier in groups:
		tiers[tier] = []
		for index in groups[tier]: tiers[tier].append(Policy.SKILLS[int(index)])
	var ratio: Dictionary = _policy.value.multipliers[str(code)]
	return {"ok":true,"record":found.record,"hp":int(value.data.hit_points_per_level),"multiplier":{"numerator":int(ratio.numerator),"denominator":int(ratio.denominator)},"progression_skills":selected,"tiers":tiers}

func _skill_sum(skills: Dictionary, career: Dictionary) -> int:
	var total := 0
	for tier in ["primary","major","minor"]:
		var values: Array = []
		for skill in career.tiers[tier]: values.append(skills[skill])
		values.sort()
		values.reverse()
		for index in {"primary":3,"major":2,"minor":1}[tier]: total += values[index]
	return total

func _clock(clock: Variant) -> bool:
	return clock is Dictionary and _plain(clock) and clock.size() == 3 and clock.get("unit") == "game-millisecond" and clock.get("provider") is String and not clock.provider.is_empty() and _number(clock.get("instant"),0,9000000000000000)

func _progression(p: Variant, skills: Dictionary, career: Dictionary) -> bool:
	if not p is Dictionary or p.size() != 12: return false
	for field in ["actual_level","earned_target"]:
		if not _number(p.get(field),1,1000000): return false
	if p.earned_target < p.actual_level or not _number(p.get("s0"),0,12000000) or not _number(p.get("current_sum"),0,12000000): return false
	if p.current_sum != _skill_sum(skills,career): return false
	if not p.get("practice") is Dictionary or p.practice.size() != skills.size(): return false
	for skill in skills:
		if not _number(p.practice.get(skill),0,MAXIMUM): return false
	if not _clock(p.get("last_advancement")) or not _clock(p.get("activity_baseline")): return false
	if not p.get("training") is Dictionary: return false
	if p.training.get("state") == "never":
		if p.training.size() != 1: return false
	elif p.training.get("state") == "trained":
		if p.training.size() != 2 or not _clock(p.training.get("at")): return false
	else: return false
	if p.get("policy") != {"schema":"captured-progression-policy-v1","mode":"vanilla-ranked-v1"}: return false
	if not p.get("pending") is Array or not p.get("retained_outcomes") is Array or p.get("progression_skills") != career.progression_skills: return false
	return true

func _resolve(bindings: Array, previous: Dictionary) -> Dictionary:
	if bindings.size() > 64: return fail("At most 64 resolved source owners per actor.")
	var sources := {}
	for binding in bindings:
		if not binding is Dictionary or binding.size() != 2 or not Paths.valid_id(binding.get("id")) or sources.has(binding.id) or not is_instance_valid(binding.get("provider")) or not binding.provider.has_method("resolve_actor_contributions"): return fail("Explicit unique required source/provider bindings required.")
		var resolved: Variant = binding.provider.resolve_actor_contributions(_operation.duplicate(true))
		if not _fresh(): return fail("Source callback retired actor context.","stale")
		if not resolved is Dictionary or not _plain(resolved) or typeof(resolved.get("ok")) != TYPE_BOOL or not resolved.ok or resolved.size() != 3 or not _number(resolved.get("revision"),0,MAXIMUM) or not resolved.get("contributions") is Array or resolved.contributions.size() > 256: return fail("Required source is unavailable or malformed.","source_unavailable")
		var old: Dictionary = previous.get(binding.id,{})
		var contributions := {}
		for contribution in resolved.contributions:
			if not contribution is Dictionary or contribution.size() != 4 or not Paths.valid_id(contribution.get("id")) or contributions.has(contribution.id) or not contribution.get("target") is String or contribution.get("kind") not in ["attribute","cap","skill","magicka","health-limiter"] or not _number(contribution.get("value"),-MAXIMUM,MAXIMUM): return fail("Malformed contribution identity/target/value.")
			contributions[contribution.id] = contribution.duplicate(true)
		var ordered_contributions := {}
		var contribution_ids: Array = contributions.keys()
		contribution_ids.sort()
		for id in contribution_ids: ordered_contributions[id] = contributions[id]
		var next := {"revision":resolved.revision,"contributions":ordered_contributions}
		if not old.is_empty() and (next.revision < old.revision or (next.revision == old.revision and next != old)): return fail("Stale source revision or changed same-revision content.","stale")
		sources[binding.id] = next
	var ordered_sources := {}
	var source_ids: Array = sources.keys()
	source_ids.sort()
	for id in source_ids: ordered_sources[id] = sources[id]
	return {"ok":true,"sources":ordered_sources}

func _formula(hook: String, value: int, ratio: Dictionary = {"numerator":1,"denominator":1}) -> Dictionary:
	var core: SessionLifecycle = _core.get_ref()
	return core.formulas.invoke(hook,{"value":value,"numerator":int(ratio.numerator),"denominator":int(ratio.denominator)},core,self,_operation.session,_operation)

func _source_receipts(sources: Dictionary) -> Dictionary:
	var result := {}
	var names: Array = sources.keys()
	names.sort()
	for source in names:
		var ids: Array = sources[source].contributions.keys()
		ids.sort()
		var canonical: Array = []
		for id in ids:
			var c: Dictionary = sources[source].contributions[id]
			canonical.append([c.id,c.kind,c.target,c.value])
		result[source] = {"revision":sources[source].revision,"sha256":JSON.stringify(canonical).sha256_text()}
	return result

func _derive(record: Dictionary, sources: Dictionary, career: Dictionary) -> Dictionary:
	var attributes := {}
	var skills := {}
	for id in record.attributes:
		attributes[id] = {"permanent":record.attributes[id],"raw":record.attributes[id],"base_cap":int(_policy.value.attributes[id].cap),"cap":int(_policy.value.attributes[id].cap),"live":0}
	for id in record.skills:
		skills[id] = {"permanent":record.skills[id],"raw":record.skills[id],"live":record.skills[id]}
	var health: int = record.base_health
	var magicka := 0
	# Sorted iteration makes aggregate rejection/order independent of callback order.
	var source_ids: Array = sources.keys()
	source_ids.sort()
	for source in source_ids:
		var ids: Array = sources[source].contributions.keys()
		ids.sort()
		for id in ids:
			var c: Dictionary = sources[source].contributions[id]
			match c.kind:
				"attribute", "cap":
					if not attributes.has(c.target): return fail("Unknown attribute contribution target.")
					attributes[c.target]["raw" if c.kind == "attribute" else "cap"] += c.value
				"skill":
					if not skills.has(c.target): return fail("Unknown skill contribution target.")
					skills[c.target].raw += c.value
				"health-limiter":
					if c.target != "health" or c.value < 1: return fail("Positive health limiter required.")
					health = mini(health,c.value)
				"magicka":
					if c.target != "magicka": return fail("Unknown pool contribution target.")
					magicka += c.value
	# Aggregate sums fit int64 by source/count limits, then fit the consumer domain.
	for a: Dictionary in attributes.values():
		if not _number(a.raw,-MAXIMUM,MAXIMUM) or not _number(a.cap): return fail("Unsupported raw attribute or effective cap.")
		a.live = clampi(a.raw,0,a.cap)
	for s: Dictionary in skills.values():
		if not _number(s.raw,-MAXIMUM,MAXIMUM): return fail("Unsupported signed live skill.")
		s.live = s.raw
	if not _number(magicka,-MAXIMUM,MAXIMUM): return fail("Unsupported magicka sum.")
	var derived := {}
	var contexts := {"damage":attributes.strength.live,"capacity":attributes.strength.live,"magicka":attributes.intelligence.live,"resistance":attributes.willpower.live,"agility":attributes.agility.live,"growth":record.attributes.endurance,"healing":attributes.endurance.live}
	for key in contexts:
		var result := _formula("char."+key,contexts[key],career.multiplier if key == "magicka" else {"numerator":1,"denominator":1})
		if not result.ok: return result
		derived[key] = result
	if derived.capacity.value < 0 or derived.magicka.value < 0: return fail("Negative capacity/base magicka is incompatible.")
	var limits := {"health":health,"fatigue":(int(attributes.strength.live)+int(attributes.endurance.live))*64,"magicka":maxi(0,int(derived.magicka.value)+magicka),"breath":Formula.floor_ratio(attributes.endurance.live,2)}
	for maximum in limits.values():
		if not _number(maximum): return fail("Derived vital maximum exceeds supported domain.")
	return {"ok":true,"attributes":attributes,"skills":skills,"formulas":derived,"limits":limits,"sources":sources.duplicate(true),"career":{"identity":career.record.identity.duplicate(true),"winner":career.record.winner.duplicate(true),"hp_per_level":career.hp,"multiplier":career.multiplier.duplicate(true)},"policy":{"identity":_policy.identity.duplicate(true),"winner":_policy.winner.duplicate(true)},"units":{"health":"points","fatigue":"internal-64","magicka":"points","breath":"activity-reserve"}}

func fresh(scope: String, ticket: Dictionary, captured: Dictionary, clock: Dictionary, sources: Array) -> Dictionary:
	var begun := _begin(scope,ticket,captured.get("actor",""))
	if not begun.ok: return begun
	if ticket.is_empty() or not _plain(captured) or captured.size() != 10 or captured.get("schema") != "captured-actor-v1" or not _number(captured.get("level"),1,1) or not _identity(captured.get("identity")) or not _choices(captured.get("choices")) or not captured.get("initialization") is Dictionary or typeof(captured.initialization.get("skills_finalized")) != TYPE_BOOL or captured.initialization != {"skills_finalized":true,"grants":"external-owner-pending"} or not _clock(clock): return _end(fail("Complete level-1 captured result, finalized initial skills and initialized clock required."))
	if _actors.has(captured.actor):
		var receipt: Dictionary = _fresh_receipts.get(captured.actor,{})
		if receipt.get("captured") == captured and receipt.get("clock") == clock and _bindings[captured.actor] == sources: return _end(receipt.result.duplicate(true))
		return _end(fail("Actor already exists with different construction input."))
	if not _permanent(captured.get("attributes"),_policy.value.attributes) or not _permanent(captured.get("skills"),_policy.value.skills): return _end(fail("Permanent assignment violates required identities/bounds."))
	var career := _career(captured.get("career"))
	if not career.ok: return _end(career)
	var sum := _skill_sum(captured.skills,career)
	var practice := {}
	for skill in captured.skills: practice[skill] = 0
	var record := {"schema":SCHEMA,"actor":captured.actor,"session":scope,"content":_content,"career":captured.career,"identity":captured.identity.duplicate(true),"choices":captured.choices.duplicate(true),"attributes":captured.attributes.duplicate(true),"skills":captured.skills.duplicate(true),"base_health":0,"current":{},"breath":{"state":"uninitialized","reserve":null,"policy":"activity-owner-pending"},"progression":{"actual_level":1,"earned_target":1,"s0":sum,"current_sum":sum,"practice":practice,"last_advancement":clock.duplicate(true),"activity_baseline":clock.duplicate(true),"training":{"state":"never"},"policy":captured.policy.duplicate(true),"pending":[],"retained_outcomes":[],"progression_skills":career.progression_skills.duplicate()},"obligations":[],"required_sources":[],"revision":1}
	if not _progression(record.progression,record.skills,career): return _end(fail("Complete captured progression policy required."))
	var initial := _formula("char.initial-health",career.hp)
	if not initial.ok: return _end(initial)
	if not _number(initial.value,1,MAXIMUM): return _end(fail("Initial base health must be positive and supported."))
	record.base_health = initial.value
	var resolved := _resolve(sources,{})
	if not resolved.ok: return _end(resolved)
	record.required_sources = _source_receipts(resolved.sources)
	var derived := _derive(record,resolved.sources,career)
	if not derived.ok: return _end(derived)
	for pool in ["health","fatigue","magicka"]: record.current[pool] = derived.limits[pool]
	var published := _publish(record,derived,sources)
	if published.ok: _fresh_receipts[captured.actor] = {"captured":captured.duplicate(true),"clock":clock.duplicate(true),"result":published.duplicate(true)}
	return published

func _publish(record: Dictionary, derived: Dictionary, sources: Array) -> Dictionary:
	if not _fresh(): return _end(fail("Actor context retired before publication.","stale"))
	_actors[record.actor] = {"record":record,"derived":derived,"definition":_policy.identity.duplicate(true)}
	_bindings[record.actor] = sources.duplicate(true)
	_sync_vital_hold(record.actor)
	if not _fresh(): return _end(fail("Actor scope retired during committed gate notification.","stale"))
	return _end({"ok":true,"actor":record.actor,"revision":record.revision,"baseline_valid":true,"entry_ready":false})

func reconcile(scope: String, ticket: Dictionary, actor: String, revision: int, content: int) -> Dictionary:
	if _vital_busy: return fail("Vital publication in progress.","busy")
	var begun := _begin(scope,ticket,actor)
	if not begun.ok: return begun
	if not _actors.has(actor) or _actors[actor].record.session != scope or _actors[actor].record.revision != revision or content != _content: return _end(fail("Stale actor/session/content revision.","stale"))
	var previous: Dictionary = _actors[actor]
	var resolved := _resolve(_bindings[actor],previous.derived.sources)
	if not resolved.ok: return _end(resolved)
	if resolved.sources == previous.derived.sources: return _end({"ok":true,"unchanged":true,"revision":revision})
	if revision >= MAXIMUM: return _end(fail("Actor revision space exhausted; no update published.","overflow"))
	var record: Dictionary = previous.record.duplicate(true)
	record.required_sources = _source_receipts(resolved.sources)
	var career := _career(record.career)
	if not career.ok: return _end(career)
	var derived := _derive(record,resolved.sources,career)
	if not derived.ok: return _end(derived)
	for pool in record.current: record.current[pool] = mini(record.current[pool],derived.limits[pool])
	if record.breath.reserve != null: record.breath.reserve = mini(record.breath.reserve,derived.limits.breath)
	var transitions := _record_transitions(record,previous.record.current,{"kind":"source-reconciliation","sources":record.required_sources.duplicate(true)})
	if not transitions.ok: return _end(transitions)
	record.revision += 1
	var events := _transition_events(record,previous.record.get("vitals",{}).get("next_transition",0))
	var published := _publish(record,derived,_bindings[actor])
	if published.ok:
		_vital_busy = true
		for event in events: vital_transition.emit(event.duplicate(true))
		_vital_busy = false
	return published

func reconstruct(scope: String, ticket: Dictionary, input: Dictionary, sources: Array) -> Dictionary:
	var begun := _begin(scope,ticket,input.get("actor",""))
	if not begun.ok: return begun
	if not _plain(input) or not ((input.size() == 16 and input.get("schema") == SCHEMA) or (input.size() == 17 and input.get("schema") == "actor-state-v2" and Vital.valid(input))) or input.get("session") != scope or input.get("content") != _content or not _identity(input.get("identity")) or not _choices(input.get("choices")) or not _number(input.get("revision"),1,MAXIMUM) or not _number(input.get("base_health"),1,MAXIMUM) or not _permanent(input.get("attributes"),_policy.value.attributes) or not _permanent(input.get("skills"),_policy.value.skills): return _end(fail("Complete compatible authoritative record required."))
	if _vital_busy or (_actors.has(input.actor) and _actors[input.actor].record.has("vitals") and _actors[input.actor].record.vitals != input.get("vitals")): return _end(fail("Reconstruction cannot erase retained mutations or replace an active actor.","busy"))
	# Quiescent replacement requires a CORE initialization ticket; ready-session
	# callers cannot turn hydration into a gameplay vital mutation API.
	if ticket.is_empty(): return _end(fail("Hydration requires gated CORE initialization."))
	var career := _career(input.get("career"))
	if not career.ok: return _end(career)
	if not _progression(input.get("progression"),input.skills,career) or not input.get("obligations") is Array or not input.get("required_sources") is Dictionary: return _end(fail("Missing progression/obligation/source state."))
	var resolved := _resolve(sources,{})
	if not resolved.ok: return _end(resolved)
	if _source_receipts(resolved.sources) != input.required_sources: return _end(fail("Required reconstructed source receipts differ.","source_unavailable"))
	var record := input.duplicate(true)
	var derived := _derive(record,resolved.sources,career)
	if not derived.ok: return _end(derived)
	if not record.get("current") is Dictionary or record.current.size() != 3: return _end(fail("Saved current vital pools required."))
	for pool in ["health","fatigue","magicka"]:
		if not _number(record.current.get(pool),0,derived.limits[pool]): return _end(fail("Invalid saved current vital; migration required."))
	if not record.get("breath") is Dictionary or record.breath.size() != 3 or not record.breath.has_all(["state","reserve","policy"]): return _end(fail("Explicit breath state/policy required."))
	if record.breath.get("state") == "uninitialized":
		if record.breath.get("reserve") != null or record.breath.get("policy") != "activity-owner-pending": return _end(fail("Invalid uninitialized breath."))
	else:
		# Preserve supported opaque activity record as an unresolved obligation.
		if record.breath.get("state") != "owner-pending" or not _number(record.breath.get("reserve"),0,derived.limits.breath) or not record.breath.get("policy") is Dictionary: return _end(fail("Unsupported breath/activity state; explicit migration required."))
	return _publish(record,derived,sources)

func projection(scope: String, actor: String) -> Dictionary:
	var core: SessionLifecycle = _core.get_ref()
	if core == null or core.snapshot().session != scope or not _actors.has(actor) or _actors[actor].record.session != scope: return fail("Unknown or retired actor.","stale")
	var view: Dictionary = _actors[actor].duplicate(true)
	view.ok = true
	view.baseline_valid = true
	view.entry_ready = false
	view.gates = ["creation/grants","TIME","ITEM","MAGIC","activity/breath","progression","SAVE","complete-entry"]
	view.pending_conditions = {"zero_health":view.record.current.health == 0,"zero_fatigue":view.record.current.fatigue == 0,"zero_magicka":view.record.current.magicka == 0,"obligations":not view.record.obligations.is_empty() or not view.record.progression.pending.is_empty() or view.record.get("vitals",{}).get("pending_count",0) > 0}
	return view

func vital_projection(scope: String, actor: String) -> Dictionary:
	var core: SessionLifecycle = _core.get_ref()
	if core == null or core.snapshot().session != scope or not _actors.has(actor) or _actors[actor].record.session != scope: return fail("Unknown or retired actor.","stale")
	var entry: Dictionary = _actors[actor]
	return {"ok":true,"actor":actor,"session":scope,"content":entry.record.content,"revision":entry.record.revision,"current":entry.record.current.duplicate(),"maximum":entry.derived.limits.duplicate(),"units":entry.derived.units.duplicate(),"pending_outcomes":entry.record.get("vitals",{}).get("pending_count",0),"zero_health":entry.record.current.health == 0,"zero_fatigue":entry.record.current.fatigue == 0}

func retire_scope(scope: String) -> void:
	for actor in _actors.keys():
		if _actors[actor].record.session == scope:
			_release_vital_hold(actor)
			_actors.erase(actor)
			_bindings.erase(actor)
			_fresh_receipts.erase(actor)

func dispose() -> void:
	for actor in _vital_holds.keys(): _release_vital_hold(actor)
	_actors.clear()
	_bindings.clear()
	_fresh_receipts.clear()
	_operation.clear()
	_policy.clear()
	definitions = null
	for connection: Dictionary in vital_committed.get_connections(): vital_committed.disconnect(connection.callable)
	for connection: Dictionary in vital_transition.get_connections(): vital_transition.disconnect(connection.callable)

func _release_vital_hold(actor: String) -> void:
	var core: SessionLifecycle = _core.get_ref()
	if _vital_holds.has(actor):
		var token: int = _vital_holds[actor]
		_vital_holds.erase(actor)
		if core != null: core.gates.release(token,"CHAR:vitals:"+actor)

func _sync_vital_hold(actor: String) -> void:
	if not _actors.has(actor): return
	var record: Dictionary = _actors[actor].record
	var pending: bool = record.current.health == 0 or record.current.fatigue == 0
	pending = pending or record.get("vitals",{}).get("pending_count",0) > 0
	if pending and not _vital_holds.has(actor):
		var core: SessionLifecycle = _core.get_ref()
		# Install sentinel before changed observers can reenter. Mutations stay busy.
		_vital_holds[actor] = 0
		var token := core.gates.acquire("CHAR:vitals:"+actor,record.session,["simulation","input","save"])
		if _actors.has(actor): _vital_holds[actor] = token
		else:
			_vital_holds.erase(actor)
			core.gates.release(token,"CHAR:vitals:"+actor)
	elif not pending:
		_release_vital_hold(actor)

func _record_transitions(record: Dictionary, before: Dictionary, context: Dictionary) -> Dictionary:
	for pool in ["health","fatigue","magicka"]:
		if before[pool] <= 0 or record.current[pool] != 0: continue
		if not record.has("vitals"):
			record.schema = "actor-state-v2"
			record["vitals"] = Vital.empty()
		if record.vitals.next_transition >= MAXIMUM or record.vitals.transitions.size() >= 4096: return fail("Transition identity/retention exhausted.","overflow")
		record.vitals.next_transition += 1
		var id := str(record.vitals.next_transition)
		record.vitals.transitions[id] = {"pool":pool,"before":before[pool],"after":0,"context":context.duplicate(true),"pending":pool in ["health","fatigue"],"outcome":"owner-unavailable" if pool in ["health","fatigue"] else "notification"}
		if pool in ["health","fatigue"]: record.vitals.pending_count += 1
	return {"ok":true}

func _transition_events(record: Dictionary, previous: int) -> Array:
	var events: Array = []
	var state: Dictionary = record.get("vitals",{})
	for serial in range(previous+1,state.get("next_transition",0)+1):
		var event: Dictionary = state.transitions[str(serial)].duplicate(true)
		event["schema"] = "vital-transition-v1"
		event["session"] = record.session
		event["actor"] = record.actor
		event["transition"] = str(serial)
		events.append(event)
	return events

func _vital_context(owner: Object, request: Dictionary) -> bool:
	var core: SessionLifecycle = _core.get_ref()
	if core == null or definitions == null or not _actors.has(request.actor) or _actors[request.actor].record.session != request.session or definitions.content_ticket() != request.content: return false
	if core.vital_consumer(request.session,owner,request.caller).is_empty(): return false
	return true

func vital_intake(owner: Object, raw: Variant) -> Dictionary:
	if not Vital.request_valid(raw): return fail("Complete vital-intake-v1 request with strict units, identity, attribution and bounded integer amount required.")
	var request: Dictionary = raw.duplicate(true)
	if _vital_busy or not _operation.is_empty(): return fail("CHAR publication in progress.","busy")
	_vital_busy = true
	var result := _intake(owner,request)
	_vital_busy = false
	return result

func _intake(owner: Object, request: Dictionary) -> Dictionary:
	if not _vital_context(owner,request): return fail("Unbound or stale vital consumer/session/content/actor.","stale")
	var entry: Dictionary = _actors[request.actor]
	var record: Dictionary = entry.record
	# Current lifetime admission precedes lookup; actor revision and operation
	# freshness follow lookup so legitimate technical redelivery survives commit.
	var retained: Dictionary = record.get("vitals",{}).get("receipts",{}).get(request.caller,{}).get(request.operation,{})
	if not retained.is_empty():
		return retained.result.duplicate(true) if retained.request == request else fail("Operation identity reused with changed intent.","identity_conflict")
	if record.revision != request.revision: return fail("Obsolete actor revision.","stale")
	var monitor := preload("res://scripts/rule/formula_error_monitor.gd").new()
	OS.add_logger(monitor)
	var admitted: Variant = owner.vital_operation_current(request.duplicate(true))
	OS.remove_logger(monitor)
	if not monitor.errors.is_empty() or typeof(admitted) != TYPE_BOOL: return fail("Vital owner eligibility callback failed; no mutation published.","technical_failure")
	if not admitted or not _vital_context(owner,request): return fail("Obsolete actor or owner operation after eligibility callback.","stale")
	var domain: String = _core.get_ref().vital_consumer(request.session,owner,request.caller).domain
	if not Vital.eligible(domain,request.action,request.pool): return fail("Consumer is not eligible for this pool operation.","ineligible")
	if record.current.health == 0: return fail("Unresolved reconstructed lethal state cannot be healed or filled.","unavailable")
	if record.revision >= MAXIMUM or record.get("vitals",{}).get("receipt_count",0) >= 4096: return fail("Vital revision/retention exhausted.","overflow")
	var before: int = record.current[request.pool]
	var maximum: int = entry.derived.limits[request.pool]
	var after := before
	var sufficient := true
	match request.action:
		"spend":
			sufficient = before >= request.amount
			if sufficient: after = before-request.amount
		"damage", "drain": after = maxi(0,before-request.amount)
		"heal", "recover":
			# Both operands <=1e9: intermediate <=2e9, safely signed int64.
			after = mini(maximum,before+request.amount)
		"fill": after = maximum
	if request.pool == "health" and before > 0 and after == 0: return fail("Required CHAR-023 lethal owner unavailable; intake unchanged. Submit a fresh attempt after qualification.","unavailable")
	var candidate: Dictionary = record.duplicate(false)
	candidate.current = record.current.duplicate()
	candidate.current[request.pool] = after
	candidate.schema = "actor-state-v2"
	# Copy only the small transition set when a new transition is possible.
	# The receipt index is owner-maintained and never cloned for a point write.
	var state: Dictionary = record.get("vitals",Vital.empty())
	candidate["vitals"] = state.duplicate(false)
	if before > 0 and after == 0: candidate.vitals.transitions = state.transitions.duplicate(true)
	var transitioned := _record_transitions(candidate,record.current,{"kind":"vital-intake","caller":request.caller,"operation":request.operation,"attribution":request.attribution})
	if not transitioned.ok: return transitioned
	var events := _transition_events(candidate,state.next_transition)
	candidate.revision += 1
	var result := {"schema":"applied-vital-v1","ok":sufficient,"kind":"applied" if sufficient else "insufficient","phase":"committed" if sufficient else "rejected","session":request.session,"actor":request.actor,"caller":request.caller,"operation":request.operation,"action":request.action,"pool":request.pool,"unit":request.unit,"requested":request.amount,"before":before,"after":after,"maximum":maximum,"applied":absi(after-before),"remainder":maximum-after if request.action == "fill" else request.amount-absi(after-before),"revision":candidate.revision,"attribution":request.attribution.duplicate(true),"transition_pending":before > 0 and after == 0 and request.pool == "fatigue","continuation_allowed":sufficient and not (before > 0 and after == 0 and request.pool == "fatigue")}
	# Last precommit check. No foreign callback occurs between here and publication.
	if not _vital_context(owner,request): return fail("Context retired before vital commit.","stale")
	if not candidate.vitals.receipts.has(request.caller): candidate.vitals.receipts[request.caller] = {}
	candidate.vitals.receipts[request.caller][request.operation] = {"request":request,"result":result.duplicate(true),"acknowledged":false}
	candidate.vitals.receipt_count += 1
	entry.record = candidate
	_sync_vital_hold(request.actor)
	# Observers see a detached committed outcome. Retirement cannot undo the commit;
	# it does prevent lookup or continuation in the replacement scope.
	vital_committed.emit(result.duplicate(true))
	for event in events: vital_transition.emit(event.duplicate(true))
	return result

func acknowledge_vital(owner: Object, raw: Variant) -> Dictionary:
	if not Vital.request_valid(raw): return fail("Original complete request required.")
	var request: Dictionary = raw.duplicate(true)
	if _vital_busy or not _operation.is_empty(): return fail("CHAR publication in progress.","busy")
	if not _vital_context(owner,request): return fail("Obsolete consumer lifetime.","stale")
	var record: Dictionary = _actors[request.actor].record
	var receipt: Dictionary = record.get("vitals",{}).get("receipts",{}).get(request.caller,{}).get(request.operation,{})
	if receipt.is_empty() or receipt.request != request: return fail("Unknown or changed operation.")
	if not receipt.result.continuation_allowed: return fail("Intake cannot continue; rejected or unresolved outcome.","unavailable")
	if not receipt.acknowledged:
		if record.revision >= MAXIMUM: return fail("Actor revision exhausted.","overflow")
		receipt.acknowledged = true
		record.revision += 1
	return {"ok":true,"phase":"acknowledged","operation":request.operation,"result":receipt.result.duplicate(true)}
