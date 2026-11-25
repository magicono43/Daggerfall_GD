extends RefCounted
## Implementation helper for the composed CHAR owner, never a second actor store.
const F = preload("res://scripts/rule/actor_formulas.gd")
const Math = preload("res://scripts/char/activity_math.gd")
const Hooks = preload("res://scripts/rule/activity_formulas.gd")
const Mapping = preload("res://scripts/rule/random_mapping.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const MINUTE := 60000000
const HOUR := 3600000000
const LIMIT := 1000000000
const INSTANT := 9000000000000000
const RETENTION := 4096
var _owner: WeakRef
var _content := -1
var _policy: Dictionary = {}

func _init(owner: RefCounted) -> void:
	_owner = weakref(owner)

func fail(reason: String, kind := "invalid_activity") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason}

func prepare() -> Dictionary:
	var a: RefCounted = _owner.get_ref()
	if a._content == _content: return {"ok":true}
	var p: Dictionary = a.definitions.query("actor.baseline","activity","player")
	var r: Dictionary = a.definitions.query("actor.baseline","recovery","player")
	if not p.ok or not r.ok: return fail("Published activity/recovery definitions required.","unavailable")
	_policy = {"activity":p.record.value.duplicate(true),"recovery":r.record.value.duplicate(true)}
	_content = a._content
	return {"ok":true}

func empty(record: Dictionary) -> Dictionary:
	return {"schema":"activity-retention-v1","policy":_policy.duplicate(true),"game":record.progression.activity_baseline.instant*1000,"simulation":0,"interval_owner":"","fatigue_remainder":0,"running_remainder":0,"swimming_remainder":0,"swimming_tick":0,"swimming_check":{},"checks":{},"receipts":{},"count":0,"events":{},"episodes":{},"active":"","resolved_count":0,"settlements":{},"breath":{"holding":false,"breathable":false,"delay":0,"remainder":0}}

static func request_valid(r: Variant) -> bool:
	if not r is Dictionary or r.size() != 12 or not r.get("schema") is String or r.schema != "actor-activity-v1": return false
	for key in ["session","actor","caller","operation"]:
		if not Paths.valid_id(r.get(key)): return false
	if not F.integer(r.get("content"),0,LIMIT) or not F.integer(r.get("revision"),1,LIMIT) or not r.get("kind") is String or r.kind not in ["segment","jump","climb-check","rappel-complete","breath","exhaustion"]: return false
	if not r.get("context") is Dictionary or not r.get("clock") is Dictionary or not r.get("providers") is Dictionary or not r.get("source") is Dictionary or r.source.size() != 3: return false
	for key in ["source","cause","component"]:
		if not Paths.valid_id(r.source.get(key)): return false
	if r.providers.size() > 8: return false
	for role in r.providers:
		var p: Variant = r.providers[role]
		if not role is String or role not in ["motion","interval","traits","threat","time","recovery","resolution","lethal"] or not p is Dictionary or p.size() != 2 or not Paths.valid_id(p.get("id")) or not F.integer(p.get("revision"),1,LIMIT): return false
	if r.kind == "exhaustion":
		return r.clock.is_empty() and r.context.size() == 2 and r.context.get("transition") is String and r.context.transition.is_valid_int() and str(int(r.context.transition)) == r.context.transition and F.integer(int(r.context.transition),1,LIMIT) and r.context.get("action") in ["advance","resolve","prevention-continuation"]
	var c: Dictionary = r.context
	var clock: Dictionary = r.clock
	if c.size() != 5 or not Math.context_valid(c.get("motion")) or typeof(c.get("argonian")) != TYPE_BOOL or typeof(c.get("success")) != TYPE_BOOL or not Paths.valid_id(c.get("event")) or not c.get("breath") is Dictionary or c.breath.size() != 2 or typeof(c.breath.get("holding")) != TYPE_BOOL or typeof(c.breath.get("breathable")) != TYPE_BOOL or (c.breath.holding and c.breath.breathable): return false
	if clock.size() != 11 or clock.get("interval") != r.operation or clock.get("domain") != "eligible-activity" or not clock.get("ownership") is String or clock.ownership not in ["ordinary","rest","training","travel","paused"] or clock.get("game_unit") != "game-microsecond" or clock.get("simulation_unit") != "simulated-microsecond": return false
	for field in ["start_game","end_game","start_sim","end_sim"]:
		if not F.integer(clock.get(field),0,INSTANT): return false
	return F.integer(clock.get("numerator"),1,1000000) and F.integer(clock.get("denominator"),1,1000000)

func current(owners: Dictionary, r: Dictionary, roles: Array, attest := true) -> Dictionary:
	var a: RefCounted = _owner.get_ref()
	if not a._fresh() or r.content != a._content or not a._actors.has(r.actor) or a._actors[r.actor].record.session != r.session: return fail("Actor/content/session retired.","stale")
	var core: SessionLifecycle = a._core.get_ref()
	for role: String in roles:
		if not r.providers.has(role) or not owners.has(role) or not is_instance_valid(owners[role]) or not core.activity_owner(r.session,owners[role],r.providers[role].id,role): return fail("Required bound "+role+" owner absent.","unavailable")
		if attest:
			var checked := callback(owners[role],"activity_current",r)
			if not checked.ok or typeof(checked.value) != TYPE_BOOL or not checked.value: return fail("Failed/stale "+role+" attestation.","unavailable")
			if not a._fresh() or not a._actors.has(r.actor): return fail("Owner callback retired context.","stale")
	return {"ok":true}

func callback(provider: Object, method: String, request: Dictionary) -> Dictionary:
	if not is_instance_valid(provider) or not provider.has_method(method): return fail("Required owner method unavailable.","unavailable")
	var monitor := preload("res://scripts/rule/formula_error_monitor.gd").new()
	OS.add_logger(monitor)
	var value: Variant = provider.call(method,request.duplicate(true))
	OS.remove_logger(monitor)
	if not monitor.errors.is_empty(): return fail("Required callback failed; retry its retained operation.","technical_failure")
	return {"ok":true,"value":value}

func formula(hook: String, value: Dictionary) -> Dictionary:
	var a: RefCounted = _owner.get_ref()
	return a._core.get_ref().formulas.invoke(hook,value,a._core.get_ref(),a,a._operation.session,a._operation)

func rate(base: int, motion: Dictionary) -> Dictionary:
	var index := 0 if not motion.athleticism else (2 if motion.improved_athleticism else 1)
	var ratio: Dictionary = _policy.activity.athleticism[index]
	var value := formula("char.activity-rate",{"base":base,"numerator":int(ratio.numerator),"denominator":int(ratio.denominator)})
	if value.ok and not F.integer(value.value,0,LIMIT): return fail("Selected activity rate exceeds supported bounds.","overflow")
	return value

func clock_valid(c: Variant, s: Dictionary, event: bool) -> bool:
	if not c is Dictionary or c.size() != 11 or c.get("domain") != "eligible-activity" or not Paths.valid_id(c.get("interval")) or not c.get("ownership") is String or c.ownership not in ["ordinary","rest","training","travel","paused"] or c.get("game_unit") != "game-microsecond" or c.get("simulation_unit") != "simulated-microsecond": return false
	for key in ["start_game","end_game","start_sim","end_sim"]:
		if not F.integer(c.get(key),0,INSTANT): return false
	if not F.integer(c.get("numerator"),1,1000000) or not F.integer(c.get("denominator"),1,1000000): return false
	if c.start_game != s.game or c.start_sim != s.simulation or c.end_game < c.start_game or c.end_sim < c.start_sim: return false
	var game: int = c.end_game-c.start_game
	var sim: int = c.end_sim-c.start_sim
	if game > Math.MAX_DURATION or sim > Math.MAX_DURATION or (event and (game != 0 or sim != 0)): return false
	if c.ownership == "paused": return game == 0 and sim == 0
	return c.ownership != "ordinary" or game*c.denominator == sim*c.numerator

func ground_preview(r: Dictionary) -> Dictionary:
	var a: RefCounted = _owner.get_ref()
	var record: Dictionary = a._actors[r.actor].record
	var state: Dictionary = record.get("activity",{})
	if state.is_empty(): state = empty(record)
	var m: Dictionary = r.context.motion
	if m.climbing or m.swimming or m.riding or r.clock.ownership != "ordinary" or not clock_valid(r.clock,state,false): return fail("Only ordered ordinary ground intervals support preview.")
	var selected: String = Math.segment(_policy.activity,m,0,0,0,0,false).selected
	var resolved := rate(int(_policy.activity.rates[selected]),m)
	if not resolved.ok: return resolved
	var requested: int = F.floor_ratio(int(resolved.value)*(r.clock.end_game-r.clock.start_game)+int(state.fatigue_remainder),MINUTE)
	return {"ok":true,"requested":requested,"settle":requested >= record.current.fatigue}

func intake(owners: Dictionary, r: Dictionary) -> Dictionary:
	var a: RefCounted = _owner.get_ref()
	var ready := prepare()
	if not ready.ok: return ready
	var roles: Array = ["motion","interval","traits"] if r.kind != "exhaustion" else r.providers.keys()
	if not r.providers.has("interval") or r.providers.interval.id != r.caller: return fail("Bound authoritative interval caller required.","unavailable")
	var admitted := current(owners,r,roles,false)
	if not admitted.ok: return admitted
	var record: Dictionary = a._actors[r.actor].record
	var state: Dictionary = record.get("activity",{})
	var old: Dictionary = state.get("receipts",{}).get(r.caller,{}).get(r.operation,{})
	if not old.is_empty(): return old.result.duplicate(true) if old.request == r else fail("Activity identity reused with changed intent.","identity_conflict")
	if r.kind != "exhaustion" and not record.get("lethal",{}).get("active",{}).is_empty(): return fail("Lethal event requires resolution.","busy")
	if r.revision != record.revision: return fail("Obsolete actor revision.","stale")
	if record.revision > LIMIT-32 or state.get("count",0) >= RETENTION: return fail("Activity revision/retention exhausted.","overflow")
	admitted = current(owners,r,roles)
	if not admitted.ok: return admitted
	if r.kind == "exhaustion": return exhaustion(owners,r)
	if state.is_empty():
		if record.progression.activity_baseline.instant > INSTANT/1000: return fail("Legacy activity clock requires migration.","unavailable")
		state = empty(record)
	if state.policy != _policy: return fail("Locked policy migration required.","unavailable")
	if not clock_valid(r.clock,state,r.kind != "segment"): return fail("Stale, overlapping or incompatible owned clocks.","stale")
	if r.providers.interval.id != r.caller or (not state.interval_owner.is_empty() and state.interval_owner != r.caller): return fail("One authoritative interval owner required.","stale")
	var c: Dictionary = r.context
	if c.size() != 5 or not Math.context_valid(c.get("motion")) or typeof(c.get("argonian")) != TYPE_BOOL or typeof(c.get("success")) != TYPE_BOOL or not c.get("breath") is Dictionary or c.breath.size() != 2 or typeof(c.breath.get("holding")) != TYPE_BOOL or typeof(c.breath.get("breathable")) != TYPE_BOOL or not Paths.valid_id(c.get("event")) or (c.breath.holding and c.breath.breathable): return fail("Complete committed motion/inherited-trait/breath context required.")
	var excluded: bool = r.clock.ownership != "ordinary"
	var game: int = r.clock.end_game-r.clock.start_game
	var sim: int = r.clock.end_sim-r.clock.start_sim
	# TIME attests the performed interval's captured eligibility. A later pause or
	# producer-owned continuation hold cannot erase debt already incurred.
	if not excluded and (record.current.health == 0 or record.current.fatigue == 0 or unresolved(record) > 0): return fail("Ordinary activity is gated.","unavailable")
	if not excluded and c.breath.holding and sim > 0: return fail("Breath consumption/drowning cadence is not qualified.","unavailable")
	var event_key: String = r.providers.motion.id+"/"+r.kind+"/"+c.event
	if r.kind != "segment" and state.events.has(event_key): return fail("Committed movement event already reported under another operation.","identity_conflict")
	if state.events.size() >= RETENTION or state.checks.size() > RETENTION-18: return fail("Movement/check retention exhausted.","overflow")
	if r.kind != "segment" and excluded: return fail("Excluded intervals cannot manufacture movement events.")
	if r.kind == "jump" and not c.success: return fail("Only an actual qualifying jump is billable.")
	var m: Dictionary = c.motion
	var amounts: Dictionary = _policy.activity.practice_amounts
	if not excluded and r.kind == "segment" and m.running and m.voluntary_motion and not m.riding and F.floor_ratio(state.running_remainder+sim,int(_policy.activity.running_cadence_usec))*int(amounts.running) > LIMIT: return fail("Raw practice request requires smaller producer segments.","overflow")
	var selected: String = Math.segment(_policy.activity,m,0,0,0,0,false).selected
	var rates := {}
	var required_rates: Array = ["jump"] if r.kind == "jump" else [selected]
	if selected == "swimming" and r.kind == "segment" and not c.argonian: required_rates.append("swimming-failure")
	for key: String in required_rates:
		var resolved := rate(int(_policy.activity.jump_cost if key == "jump" else _policy.activity.rates[key]),m)
		if not resolved.ok: return resolved
		rates[key] = resolved.value
	var highest := 0
	for value: int in rates.values(): highest = maxi(highest,value)
	var worst: int = highest if r.kind == "jump" else F.floor_ratio(highest*game+state.fatigue_remainder,MINUTE)
	if worst > LIMIT: return fail("Integrated drain requires smaller producer segments.","overflow")
	if worst >= record.current.fatigue and record.current.fatigue > 0 and (record.get("vitals",{}).get("next_transition",0) >= LIMIT or record.get("vitals",{}).get("transitions",{}).size() >= RETENTION): return fail("Depletion retention exhausted.","overflow")
	# All foreign validation/formulas precede random checks and local commitment.
	if not current(owners,r,roles,false).ok: return fail("Context retired during formula preparation.","stale")
	var next: Dictionary = state.duplicate(false)
	next.breath = state.breath.duplicate(true)
	var breath: Dictionary = record.breath.duplicate(true)
	var scheduled := schedule_breath(next.breath,breath,c.breath,sim,a._actors[r.actor].derived.limits.breath)
	if not scheduled.ok: return scheduled
	next.breath = scheduled.state
	breath = scheduled.breath
	var requested := 0
	var practice := {}
	var check_additions := {}
	var practice_game := game
	if not excluded and r.kind == "segment":
		var remaining := game
		var rem: int = state.fatigue_remainder
		if selected == "swimming":
			var source: Dictionary = a._core.get_ref().randomness.source(r.session,a,"progression")
			if not source.ok: return fail("Bound Swimming randomness unavailable.","unavailable")
			var swimming: int = state.swimming_remainder
			var check: Dictionary = state.swimming_check.duplicate(true)
			while remaining > 0:
				if swimming == 0:
					var chance := clampi(a._actors[r.actor].derived.skills.swimming.live,0,100)
					var draw: Dictionary = Mapping.percentile(chance,source.source)
					if not draw.ok: return fail("Swimming check unavailable; no interval committed.","unavailable")
					next.swimming_tick += 1
					check = {"tick":next.swimming_tick,"chance":chance,"roll":draw.roll,"success":draw.success}
					check_additions[str(next.swimming_tick)] = check.duplicate(true)
				var duration := mini(remaining,MINUTE-swimming)
				var applied_rate: int = rates["swimming-failure"] if not check.success and not c.argonian else rates.swimming
				var numerator: int = rem+duration*applied_rate
				if applied_rate > 0 and requested < record.current.fatigue and requested+F.floor_ratio(numerator,MINUTE) >= record.current.fatigue:
					var needed: int = (record.current.fatigue-requested)*MINUTE-rem
					practice_game = mini(practice_game,game-remaining+F.floor_ratio(needed+applied_rate-1,applied_rate))
				requested += F.floor_ratio(numerator,MINUTE)
				rem = numerator%MINUTE
				swimming += duration
				remaining -= duration
				if swimming == MINUTE:
					swimming = 0
					if game-remaining <= practice_game: practice["swimming"] = practice.get("swimming",0)+int(amounts.swimming)
				next.swimming_check = check
			next.swimming_remainder = swimming
		else:
			var numerator: int = rem+game*int(rates[selected])
			requested = F.floor_ratio(numerator,MINUTE)
			if rates[selected] > 0 and requested >= record.current.fatigue:
				var needed: int = record.current.fatigue*MINUTE-rem
				practice_game = mini(practice_game,F.floor_ratio(needed+int(rates[selected])-1,int(rates[selected])))
			rem = numerator%MINUTE
		next.fatigue_remainder = rem
		if m.running and m.voluntary_motion and not m.riding:
			var eligible_sim := mini(sim,F.floor_ratio(practice_game*r.clock.denominator,r.clock.numerator))
			var cadence: int = state.running_remainder+eligible_sim
			practice["running"] = F.floor_ratio(cadence,int(_policy.activity.running_cadence_usec))*int(amounts.running)
			next.running_remainder = cadence%int(_policy.activity.running_cadence_usec)
	elif r.kind == "jump":
		requested = rates.jump
		practice["jumping"] = int(amounts.jumping)
	elif r.kind == "climb-check" or (r.kind == "rappel-complete" and c.success): practice["climbing"] = int(amounts.climbing if r.kind == "climb-check" else amounts.rappel)
	if requested > LIMIT: return fail("Integrated drain requires smaller producer segments.","overflow")
	var candidate: Dictionary = record.duplicate(false)
	candidate.current = record.current.duplicate()
	candidate.current.fatigue = maxi(0,record.current.fatigue-requested)
	candidate.breath = breath
	candidate.progression = record.progression.duplicate(false)
	candidate.progression.practice = record.progression.practice.duplicate()
	var awards := {}
	for skill: String in practice:
		awards[skill] = Math.practice(record.progression.practice[skill],practice[skill],int(_policy.activity.practice_cap))
		candidate.progression.practice[skill] = awards[skill].after
	candidate["activity"] = next
	candidate["vitals"] = record.get("vitals",a.Vital.empty()).duplicate(false)
	if record.current.fatigue > 0 and candidate.current.fatigue == 0: candidate.vitals.transitions = candidate.vitals.transitions.duplicate(true)
	var transition: Dictionary = a._record_transitions(candidate,record.current,{"kind":"activity","caller":r.caller,"operation":r.operation,"attribution":r.source.duplicate(true)})
	if not transition.ok: return transition
	candidate.schema = "actor-state-v4" if record.has("lethal") else "actor-state-v3"
	candidate.revision += 1
	next.game = r.clock.end_game
	next.simulation = r.clock.end_sim
	next.interval_owner = r.caller
	var result := {"ok":true,"schema":"applied-activity-v1","kind":r.kind,"phase":"committed","session":r.session,"actor":r.actor,"caller":r.caller,"operation":r.operation,"before":record.current.fatigue,"after":candidate.current.fatigue,"requested":requested,"applied":record.current.fatigue-candidate.current.fatigue,"practice":awards,"selected":selected,"rates":rates.duplicate(),"revision":candidate.revision,"game":game,"simulation":sim}
	# Indexed ledgers are changed only at this final local commit, never cloned.
	for id: String in check_additions: next.checks[id] = check_additions[id]
	if r.kind != "segment": next.events[event_key] = {"caller":r.caller,"operation":r.operation}
	retain(next,r,result)
	a._actors[r.actor].record = candidate
	var events: Array = a._transition_events(candidate,record.get("vitals",{}).get("next_transition",0))
	a._sync_vital_hold(r.actor)
	a.activity_committed.emit(result.duplicate(true))
	for event: Dictionary in events: a.vital_transition.emit(event.duplicate(true))
	return result

func retain(state: Dictionary, request: Dictionary, result: Dictionary) -> void:
	if not state.receipts.has(request.caller): state.receipts[request.caller] = {}
	state.receipts[request.caller][request.operation] = {"request":request.duplicate(true),"result":result.duplicate(true)}
	state.count += 1

func schedule_breath(state: Dictionary, breath: Dictionary, context: Dictionary, elapsed: int, maximum: int) -> Dictionary:
	return preload("res://scripts/char/breath_schedule.gd").resolve(_policy.recovery.breath,state,breath,context,elapsed,maximum)
static func unresolved(record: Dictionary) -> int:
	return record.get("vitals",{}).get("pending_count",0)-record.get("activity",{}).get("resolved_count",0)

static func settled(record: Dictionary, caller: String, operation: String) -> bool:
	var s: Variant = record.get("activity",{})
	if not s is Dictionary or not s.get("settlements",{}) is Dictionary or not s.get("episodes",{}) is Dictionary: return false
	var ledger: Variant = s.get("settlements",{}).get(caller,{})
	if not ledger is Dictionary: return false
	var id: Variant = ledger.get(operation,"")
	if not id is String or id.is_empty(): return false
	var e: Variant = s.get("episodes",{}).get(id,{})
	return e is Dictionary and e.get("phase") == "resolved"

func exhaustion(owners: Dictionary, r: Dictionary) -> Dictionary:
	var a: RefCounted = _owner.get_ref()
	var record: Dictionary = a._actors[r.actor].record
	var c: Dictionary = r.context
	if c.size() != 2 or not c.get("transition") is String or not c.transition.is_valid_int() or str(int(c.transition)) != c.transition or int(c.transition) <= 0 or c.get("action") not in ["advance","resolve","prevention-continuation"] or not r.clock.is_empty(): return fail("Checked transition/action required.")
	var transition: Dictionary = record.get("vitals",{}).get("transitions",{}).get(c.transition,{})
	if transition.is_empty() or transition.pool != "fatigue" or not transition.pending or record.current.health == 0: return fail("Valid living fatigue transition required.","unavailable")
	var state: Dictionary = record.get("activity",{})
	if state.is_empty():
		if record.progression.activity_baseline.instant > INSTANT/1000: return fail("Legacy activity clock requires migration.","unavailable")
		state = empty(record)
		state.interval_owner = r.caller
		record["activity"] = state
		record.schema = "actor-state-v4" if record.has("lethal") else "actor-state-v3"
	if state.interval_owner != r.caller: return fail("Exhaustion must retain the authoritative interval owner.","stale")
	var episode: Dictionary = state.episodes.get(c.transition,{})
	if episode.is_empty():
		if not state.active.is_empty() or state.episodes.size() >= RETENTION: return fail("Another exhaustion episode remains active.","busy")
		for id: String in record.vitals.transitions:
			if int(id) < int(c.transition) and record.vitals.transitions[id].pool == "fatigue" and state.episodes.get(id,{}).get("phase") != "resolved": return fail("Earlier fatigue transition remains unresolved.","busy")
		episode = {"transition":c.transition,"phase":"admitted","stopped":false,"classification":"","classification_context":{},"elapsed":0,"time":{},"recovery":{},"medical":{},"resolution":{},"lethal":{},"reason":"context-required"}
		state.episodes[c.transition] = episode
		if transition.context.has_all(["caller","operation"]):
			if not state.settlements.has(transition.context.caller): state.settlements[transition.context.caller] = {}
			state.settlements[transition.context.caller][transition.context.operation] = c.transition
		state.active = c.transition
		record.revision += 1
	var previous_phase: String = episode.phase
	var result := continue_episode(owners,r,record,state,episode)
	# Retain failed as well as completed continuation attempts. A fresh operation
	# retries unfinished phases; earlier external step identities stay unchanged.
	if a._fresh() and a._actors.has(r.actor):
		if episode.phase == "resolved" and previous_phase != "resolved": state.resolved_count += 1
		record.revision += 1
		retain(state,r,result)
		a._sync_vital_hold(r.actor)
		if episode.phase != "dead": a.activity_committed.emit(result.duplicate(true))
	return result

func episode_result(e: Dictionary, ok := false) -> Dictionary:
	var result := {"ok":ok,"kind":"exhaustion","phase":e.phase,"episode":e.transition,"elapsed":e.elapsed,"reason":e.reason,"continuation_allowed":e.phase == "resolved"}
	if e.lethal.has("v4"):
		result["schema"] = "exhaustion-outcome-v2"
		result["lethal_phase"] = e.lethal.v4.phase
		result["session"] = e.lethal.v4.session
		result["actor"] = e.lethal.v4.actor
	return result

func query(owners: Dictionary, r: Dictionary, role: String, method := "activity_snapshot", payload: Dictionary = {}) -> Dictionary:
	var checked := current(owners,r,[role])
	if not checked.ok: return checked
	var request := r.duplicate(true)
	if not payload.is_empty(): request["continuation"] = payload
	var result := callback(owners[role],method,request)
	if not result.ok: return result
	if not current(owners,r,[role],false).ok: return fail("Callback retired episode context.","stale")
	if not result.value is Dictionary or not _owner.get_ref()._plain(result.value): return fail("Malformed required owner result.")
	var value: Dictionary = result.value
	if typeof(value.get("ok")) != TYPE_BOOL or not F.integer(value.get("revision"),r.providers[role].revision,r.providers[role].revision): return fail("Strict owner status/revision required.","unavailable")
	if role == "motion" and typeof(value.get("swimming" if method == "activity_snapshot" else "stopped")) != TYPE_BOOL: return fail("Strict committed MOVE state required.","unavailable")
	if role == "threat" and (not value.get("purpose") is String or typeof(value.get("threat")) != TYPE_BOOL): return fail("Strict purpose-specific threat state required.","unavailable")
	if role == "resolution" and typeof(value.get("resolved")) != TYPE_BOOL: return fail("Strict resolution state required.","unavailable")
	if role == "lethal" and (not value.get("episode") is String or not value.get("phase") is String): return fail("Strict lethal continuation identity required.","unavailable")
	return {"ok":true,"value":result.value}

func continue_episode(owners: Dictionary, r: Dictionary, record: Dictionary, state: Dictionary, e: Dictionary) -> Dictionary:
	if e.phase == "resolved": return episode_result(e,true)
	if r.context.action == "prevention-continuation":
		if e.lethal.has("v4"): return episode_result(e) # New events resolve only through CHAR-023.
		if e.phase != "lethal-unavailable" or not e.lethal.get("continuation",{}).is_empty(): return episode_result(e)
		var prevented := query(owners,r,"lethal")
		if not prevented.ok or prevented.value != {"ok":true,"revision":r.providers.lethal.revision,"episode":e.transition,"phase":"prevented"}: return episode_result(e)
		e.lethal["continuation"] = prevented.value
		e.phase = "incapacitated" if record.current.fatigue == 0 else "resolved"
		e.reason = "prevention-fatigue-zero" if record.current.fatigue == 0 else "prevention-settled"
		if e.phase == "resolved":
			e.resolution = {"kind":"lethal-owner-prevented"}
			state.active = ""
		return episode_result(e,e.phase == "resolved")
	if r.context.action == "resolve":
		if e.phase != "incapacitated" or record.current.fatigue <= 0: return episode_result(e)
		var resolution := query(owners,r,"resolution")
		if not resolution.ok or resolution.value != {"ok":true,"revision":r.providers.resolution.revision,"resolved":true}: return episode_result(e)
		e.resolution = resolution.value
		e.phase = "resolved"
		e.reason = "owner-resolved"
		state.active = ""
		return episode_result(e,true)
	if e.phase == "incapacitated": return episode_result(e)
	if not e.stopped:
		var stopped := query(owners,r,"motion","activity_execute",{"episode":e.transition,"step":"stop","protected":true})
		if not stopped.ok or stopped.value != {"ok":true,"revision":r.providers.motion.revision,"stopped":true}: return episode_result(e)
		e.stopped = true
	if e.classification.is_empty():
		var motion := query(owners,r,"motion")
		var threat := query(owners,r,"threat")
		if not motion.ok or not threat.ok: return episode_result(e)
		var m: Dictionary = motion.value
		var t: Dictionary = threat.value
		if m.size() != 3 or m.get("ok") != true or not F.integer(m.get("revision"),r.providers.motion.revision,r.providers.motion.revision) or typeof(m.get("swimming")) != TYPE_BOOL or t.size() != 4 or t.get("ok") != true or not F.integer(t.get("revision"),r.providers.threat.revision,r.providers.threat.revision) or t.get("purpose") != "exhaustion" or typeof(t.get("threat")) != TYPE_BOOL: return episode_result(e)
		var outcome: String = _policy.recovery.outcomes["swimming" if m.swimming else ("threat" if t.threat else "safe")]
		e.classification = "lethal" if outcome == "lethal" else "safe"
		e.classification_context = {"motion":m.duplicate(true),"threat":t.duplicate(true),"providers":{"motion":r.providers.motion.duplicate(true),"threat":r.providers.threat.duplicate(true)}}
		e.phase = "classified"
	if e.classification == "lethal":
		var owner: RefCounted = _owner.get_ref()
		# Legacy v3 unavailable receipts remain immutable history. V4 continuation
		# points to the same authoritative event rather than treating them as kills.
		if e.lethal.is_empty(): e.lethal = {"request":{"session":r.session,"actor":r.actor,"operation":"exhaustion-"+e.transition,"attribution":r.source.duplicate(true)},"result":{"ok":false,"kind":"unavailable","reason":"CHAR-023 resolution pending."}}
		var intent: Dictionary = e.lethal.request
		var lethal_result: Dictionary = owner.lethal_boundary(r.session,r.actor,intent.operation,intent.attribution)
		if lethal_result.get("schema") != "lethal-outcome-v1":
			e.phase = "lethal-unavailable"
			e.reason = "lethal-admission-"+str(lethal_result.get("kind","unavailable"))
			return episode_result(e)
		e.lethal["v4"] = lethal_result
		match lethal_result.get("phase",""):
			"prevented":
				e.phase = "incapacitated" if record.current.fatigue == 0 else "resolved"
				e.reason = "prevention-fatigue-zero" if record.current.fatigue == 0 else "prevention-settled"
				if e.phase == "resolved":
					e.resolution = {"kind":"lethal-owner-prevented"}
					state.active = ""
			"dead":
				e.phase = "dead" # Unresolved fatigue obligation survives death.
				e.reason = "confirmed-death"
			_:
				e.phase = "lethal-pending"
				e.reason = "CHAR-023-required"
		return episode_result(e,e.phase == "resolved")
	if e.recovery.is_empty():
		var time_settled: bool = e.time.get("events") == [true,true,true] and e.time.get("ok") == true and e.time.get("phase") in ["completed","interrupted"]
		if not time_settled:
			if not r.providers.has("time") or r.providers.time.id != r.providers.interval.id: return episode_result(e)
			if _owner.get_ref()._core.get_ref().gates.blocked_except("simulation","CHAR:vitals:"+r.actor): return episode_result(e)
			if state.game > INSTANT-(HOUR-e.elapsed): return fail("Forced clock endpoint overflow.","overflow")
			var time_result := query(owners,r,"time","activity_execute",{"episode":e.transition,"step":"safe-hour","protected":true,"unit":"game-microsecond","start_game":state.game-e.elapsed,"end_game":state.game-e.elapsed+HOUR,"requested_usec":HOUR,"elapsed_usec":e.elapsed,"simulation_policy":"required-owner-events","order":["QUEST","MAGIC","WORLD"]})
			if not time_result.ok: return episode_result(e)
			var t: Dictionary = time_result.value
			if t.size() != 5 or typeof(t.get("ok")) != TYPE_BOOL or not F.integer(t.get("revision"),r.providers.time.revision,r.providers.time.revision) or not F.integer(t.get("elapsed_usec"),e.elapsed,HOUR) or not t.get("phase") is String or t.phase not in ["in-progress","completed","interrupted"] or not t.get("events") is Array or t.events.size() != 3: return episode_result(e)
			var unsettled := false
			for index in 3:
				var event: Variant = t.events[index]
				if typeof(event) != TYPE_BOOL or (unsettled and event): return episode_result(e)
				if t.elapsed_usec == e.elapsed and e.time.get("events",[false,false,false])[index] and not event: return episode_result(e)
				unsettled = unsettled or not event
			if e.time.get("phase") == "interrupted" and (t.elapsed_usec != e.elapsed or t.phase != "interrupted"): return episode_result(e)
			state.game += t.elapsed_usec-e.elapsed
			e.elapsed = t.elapsed_usec
			e.time = t.duplicate(true)
			e.phase = "time-pending"
			e.reason = "required-events"
			if not t.ok or unsettled: return episode_result(e)
		if e.time.phase == "interrupted":
			e.phase = "incapacitated"
			e.reason = "unfinished-hour"
			return episode_result(e)
		if e.time.phase != "completed" or e.elapsed != HOUR: return episode_result(e)
		var context := query(owners,r,"recovery")
		if not context.ok: return episode_result(e)
		var recovery := recover(record,context.value,r.providers.recovery.revision)
		if not recovery.ok: return episode_result(e)
		e.recovery = recovery
		e.medical = recovery.medical
	if record.current.fatigue > 0:
		e.phase = "resolved"
		e.reason = "safe-hour-settled"
		e.resolution = {"kind":"completed-safe-hour"}
		state.active = ""
	else:
		e.phase = "incapacitated"
		e.reason = "fatigue-remains-zero"
	return episode_result(e,e.phase == "resolved")

func recover(record: Dictionary, context: Dictionary, revision: int) -> Dictionary:
	if not recovery_context_valid(context) or context.revision != revision: return fail("Current recovery restrictions/environment required.","unavailable")
	var a: RefCounted = _owner.get_ref()
	var d: Dictionary = a._actors[record.actor].derived
	var p: Dictionary = _policy.recovery
	var rapid: bool = context.rapid == "general" or context.rapid == context.environment
	var health := formula("char.recovery-health",{"medical":d.skills.medical.live,"endurance":d.attributes.endurance.live,"maximum":d.limits.health,"term":int(p.rapid_term if rapid else p.health_term),"divisor":int(p.health_divisor),"minimum":int(p.minimum)})
	var fatigue := formula("char.recovery-pool",{"maximum":d.limits.fatigue,"divisor":int(p.pool_divisor),"minimum":int(p.minimum),"blocked":not context.fatigue_allowed})
	var magicka := formula("char.recovery-pool",{"maximum":d.limits.magicka,"divisor":int(p.pool_divisor),"minimum":int(p.minimum),"blocked":not context.magicka_allowed or context.no_magicka})
	if not health.ok or not fatigue.ok or not magicka.ok: return fail("Selected recovery formula unavailable.","unavailable")
	if (not context.fatigue_allowed and fatigue.value != 0) or ((not context.magicka_allowed or context.no_magicka) and magicka.value != 0): return fail("Selected recovery formula violates owner restrictions.","unavailable")
	var rates := {"health":health.value if context.health_allowed else 0,"fatigue":fatigue.value,"magicka":magicka.value}
	for value: Variant in rates.values():
		if not F.integer(value,0,LIMIT): return fail("Unsupported recovery result.","overflow")
	var before: Dictionary = record.current.duplicate()
	var applied := {}
	for pool: String in rates:
		applied[pool] = mini(d.limits[pool]-record.current[pool],rates[pool])
	var medical := Math.practice(record.progression.practice.medical,int(p.medical_amount),int(_policy.activity.practice_cap))
	# One local commitment for all pools and Medical. Breath is untouched.
	for pool: String in applied: record.current[pool] += applied[pool]
	record.progression.practice.medical = medical.after
	return {"ok":true,"before":before,"applied":applied,"after":record.current.duplicate(),"medical":medical,"context":context.duplicate(true),"rates":rates,"maxima":d.limits.duplicate(),"medical_live":d.skills.medical.live,"endurance_live":d.attributes.endurance.live}

static func recovery_context_valid(context: Variant) -> bool:
	if not context is Dictionary or context.size() != 8 or typeof(context.get("ok")) != TYPE_BOOL or not context.ok or not F.integer(context.get("revision"),1,LIMIT) or not context.get("rapid") is String or context.rapid not in ["none","general","light","darkness"] or not context.get("environment") is String or context.environment not in ["light","darkness"]: return false
	for key in ["health_allowed","fatigue_allowed","magicka_allowed","no_magicka"]:
		if typeof(context.get(key)) != TYPE_BOOL: return false
	return true

func valid(record: Dictionary) -> bool:
	if not prepare().ok: return false
	if not record.get("vitals") is Dictionary or not record.vitals.get("receipts") is Dictionary or not record.vitals.get("transitions") is Dictionary or not record.get("progression") is Dictionary or not record.progression.get("practice") is Dictionary or not record.progression.get("activity_baseline") is Dictionary or not F.integer(record.progression.activity_baseline.get("instant"),0,INSTANT/1000): return false
	var s: Variant = record.get("activity")
	if not s is Dictionary or s.size() != 19 or s.get("schema") != "activity-retention-v1" or s.get("policy") != _policy or not F.integer(s.get("resolved_count"),0,RETENTION) or not s.get("settlements") is Dictionary: return false
	for key in ["game","simulation"]:
		if not F.integer(s.get(key),0,INSTANT): return false
	for key in ["checks","receipts","events","episodes"]:
		if not s.get(key) is Dictionary or s[key].size() > RETENTION: return false
	if not F.integer(s.get("count"),0,RETENTION) or not F.integer(s.get("fatigue_remainder"),0,MINUTE-1) or not F.integer(s.get("running_remainder"),0,int(_policy.activity.running_cadence_usec)-1) or not F.integer(s.get("swimming_remainder"),0,MINUTE-1) or not F.integer(s.get("swimming_tick"),0,RETENTION) or not s.get("swimming_check") is Dictionary or not s.get("interval_owner") is String or (not s.interval_owner.is_empty() and not Paths.valid_id(s.interval_owner)) or not s.get("active") is String: return false
	if s.checks.size() != s.swimming_tick: return false
	for id in s.checks:
		var check: Variant = s.checks[id]
		if not id is String or not id.is_valid_int() or str(int(id)) != id or not F.integer(int(id),1,s.swimming_tick) or not check is Dictionary or check.size() != 4 or not F.integer(check.get("tick"),int(id),int(id)) or not F.integer(check.get("chance"),0,100) or not F.integer(check.get("roll"),1,100) or typeof(check.get("success")) != TYPE_BOOL or check.success != (check.roll <= check.chance): return false
	if s.swimming_tick > 0 and s.swimming_check != s.checks[str(s.swimming_tick)]: return false
	if s.swimming_tick == 0 and not s.swimming_check.is_empty(): return false
	var b: Variant = s.get("breath")
	if not b is Dictionary or b.size() != 4 or typeof(b.get("holding")) != TYPE_BOOL or typeof(b.get("breathable")) != TYPE_BOOL or (b.holding and b.breathable) or not F.integer(b.get("delay"),0,int(_policy.recovery.breath.delay_usec)) or not F.integer(b.get("remainder"),0,999999): return false
	var count := 0
	var game := 0
	var simulation := 0
	var revisions := {}
	var depletions := {}
	for ledger: Dictionary in record.vitals.receipts.values():
		for receipt: Dictionary in ledger.values(): revisions[receipt.result.revision] = true
	for caller in s.receipts:
		if not Paths.valid_id(caller) or not s.receipts[caller] is Dictionary or s.receipts[caller].is_empty(): return false
		for operation in s.receipts[caller]:
			count += 1
			var receipt: Variant = s.receipts[caller][operation]
			if not receipt is Dictionary or receipt.size() != 2 or not request_valid(receipt.get("request")) or not receipt.get("result") is Dictionary: return false
			var r: Dictionary = receipt.request
			var result: Dictionary = receipt.result
			if r.caller != caller or r.operation != operation or r.actor != record.actor or r.session != record.session or r.content != record.content or not r.providers.has("interval") or r.providers.interval.id != caller or r.revision >= record.revision: return false
			if r.kind == "exhaustion":
				var v2: bool = result.get("schema") == "exhaustion-outcome-v2"
				if r.context.size() != 2 or not s.episodes.has(r.context.get("transition")) or result.size() != (11 if v2 else 7) or typeof(result.get("ok")) != TYPE_BOOL or result.get("kind") != "exhaustion" or result.get("episode") != r.context.transition or not F.integer(result.get("elapsed"),0,s.episodes[r.context.transition].elapsed) or typeof(result.get("continuation_allowed")) != TYPE_BOOL or result.continuation_allowed != (result.get("phase") == "resolved"): return false
				if v2:
					var phase: Variant = result.get("lethal_phase")
					if result.get("session") != record.session or result.get("actor") != record.actor: return false
					if not s.episodes[r.context.transition].lethal.has("v4") or not phase is String or phase not in ["sources","evaluation","prevented","dead"] or result.ok != (result.phase == "resolved"): return false
					if (phase in ["sources","evaluation"] and result.phase != "lethal-pending") or (phase == "dead" and result.phase != "dead") or (phase == "prevented" and result.phase not in ["incapacitated","resolved"]): return false
				continue
			if result.size() != 18 or result.get("ok") != true or result.get("schema") != "applied-activity-v1" or result.get("phase") != "committed" or result.get("kind") != r.kind or result.get("session") != r.session or result.get("actor") != r.actor or result.get("caller") != caller or result.get("operation") != operation or not F.integer(result.get("revision"),r.revision+1,r.revision+1) or revisions.has(result.revision) or not result.get("rates") is Dictionary: return false
			for value: Variant in result.rates.values():
				if not F.integer(value,0,LIMIT): return false
			revisions[result.revision] = true
			for key in ["before","after","requested","applied"]:
				if not F.integer(result.get(key),0,LIMIT): return false
			if result.after != maxi(0,result.before-result.requested) or result.applied != result.before-result.after or not result.get("practice") is Dictionary: return false
			if result.get("selected") != Math.segment(_policy.activity,r.context.motion,0,0,0,0,false).selected: return false
			if result.before > 0 and result.after == 0: depletions[caller+"/"+operation] = false
			if r.kind != "segment":
				var key: String = r.providers.motion.id+"/"+r.kind+"/"+r.context.event
				if s.events.get(key) != {"caller":caller,"operation":operation}: return false
			if r.kind in ["breath","climb-check","rappel-complete"] and result.requested != 0: return false
			for skill in result.practice:
				var p: Variant = result.practice[skill]
				if not record.progression.practice.has(skill) or not p is Dictionary or not F.integer(p.get("before"),0,LIMIT) or not F.integer(p.get("requested"),0,LIMIT) or p != Math.practice(p.before,p.requested,int(_policy.activity.practice_cap)): return false
			if not r.clock.has_all(["start_game","end_game","start_sim","end_sim"]): return false
			for key in ["start_game","end_game","start_sim","end_sim"]:
				if not F.integer(r.clock[key],0,INSTANT): return false
			if not F.integer(result.get("game"),0,Math.MAX_DURATION) or not F.integer(result.get("simulation"),0,Math.MAX_DURATION) or result.game != r.clock.end_game-r.clock.start_game or result.simulation != r.clock.end_sim-r.clock.start_sim: return false
			game += result.game
			simulation += result.simulation
	if count != s.count: return false
	for t: Dictionary in record.vitals.transitions.values():
		if t.context.get("kind") == "activity":
			var key: String = t.context.caller+"/"+t.context.operation
			if not depletions.has(key) or depletions[key]: return false
			depletions[key] = true
	if not depletions.values().all(func(value): return value): return false
	for key in s.events:
		var event: Variant = s.events[key]
		if not key is String or not event is Dictionary or event.size() != 2: return false
		var receipt: Dictionary = s.receipts.get(event.get("caller"),{}).get(event.get("operation"),{})
		if receipt.is_empty() or receipt.request.kind in ["segment","exhaustion"] or key != receipt.request.providers.motion.id+"/"+receipt.request.kind+"/"+receipt.request.context.event: return false
	var active := 0
	var resolved := 0
	for id in s.episodes:
		var e: Variant = s.episodes[id]
		var transition: Dictionary = record.vitals.transitions.get(id,{})
		if not id is String or transition.is_empty() or transition.pool != "fatigue" or not e is Dictionary or e.size() != 12 or e.get("transition") != id or not e.get("phase") is String or e.phase not in ["admitted","classified","time-pending","incapacitated","resolved","lethal-unavailable","lethal-pending","dead"] or typeof(e.get("stopped")) != TYPE_BOOL or e.get("classification") not in ["","safe","lethal"] or not F.integer(e.get("elapsed"),0,HOUR) or not Paths.valid_id(e.get("reason")): return false
		for key in ["time","recovery","medical","resolution","lethal"]:
			if not e.get(key) is Dictionary: return false
		if not e.get("classification_context") is Dictionary: return false
		if not e.classification.is_empty():
			var observation: Dictionary = e.classification_context
			if observation.size() != 3 or not observation.get("motion") is Dictionary or not observation.get("threat") is Dictionary or not observation.get("providers") is Dictionary or observation.providers.size() != 2: return false
			for role in ["motion","threat"]:
				var provider: Variant = observation.providers.get(role)
				var snapshot: Dictionary = observation[role]
				if not provider is Dictionary or provider.size() != 2 or not Paths.valid_id(provider.get("id")) or not F.integer(provider.get("revision"),1,LIMIT) or not F.integer(snapshot.get("revision"),provider.revision,provider.revision) or typeof(snapshot.get("ok")) != TYPE_BOOL or not snapshot.ok: return false
			if observation.motion.size() != 3 or typeof(observation.motion.get("swimming")) != TYPE_BOOL or observation.threat.size() != 4 or observation.threat.get("purpose") != "exhaustion" or typeof(observation.threat.get("threat")) != TYPE_BOOL: return false
			var selected_outcome: String = _policy.recovery.outcomes["swimming" if observation.motion.swimming else ("threat" if observation.threat.threat else "safe")]
			if e.classification != ("lethal" if selected_outcome == "lethal" else "safe"): return false
		elif not e.classification_context.is_empty(): return false
		if e.phase == "admitted" and (not e.classification.is_empty() or e.elapsed != 0): return false
		if e.phase != "admitted" and (not e.stopped or e.classification not in ["safe","lethal"]): return false
		if e.phase == "classified" and (e.elapsed != 0 or not e.time.is_empty() or not e.recovery.is_empty()): return false
		if e.phase == "time-pending" and (e.classification != "safe" or e.time.is_empty() or not e.recovery.is_empty()): return false
		if not e.resolution.is_empty():
			if e.phase != "resolved": return false
			if e.resolution.has("kind"):
				if e.resolution.size() != 1 or e.resolution.kind not in ["completed-safe-hour","lethal-owner-prevented"]: return false
			elif e.resolution.size() != 3 or typeof(e.resolution.get("ok")) != TYPE_BOOL or not e.resolution.ok or typeof(e.resolution.get("resolved")) != TYPE_BOOL or not e.resolution.resolved or not F.integer(e.resolution.get("revision"),1,LIMIT): return false
		if not e.time.is_empty():
			if e.time.size() != 5 or typeof(e.time.get("ok")) != TYPE_BOOL or not F.integer(e.time.get("revision"),1,LIMIT) or not F.integer(e.time.get("elapsed_usec"),0,HOUR) or e.time.elapsed_usec != e.elapsed or e.time.get("phase") not in ["in-progress","completed","interrupted"] or not e.time.get("events") is Array or e.time.events.size() != 3: return false
			var pending_event := false
			for event: Variant in e.time.events:
				if typeof(event) != TYPE_BOOL or (pending_event and event): return false
				pending_event = pending_event or not event
		if e.classification == "safe" and e.phase in ["resolved","incapacitated"]:
			if e.time.get("ok") != true or e.time.get("events") != [true,true,true] or e.time.get("phase") not in ["completed","interrupted"] or (e.time.phase == "completed" and e.recovery.is_empty()): return false
		if transition.context.has_all(["caller","operation"]) and s.settlements.get(transition.context.caller,{}).get(transition.context.operation) != id: return false
		game += e.elapsed
		if e.phase != "resolved":
			active += 1
			if s.active != id: return false
		else: resolved += 1
		if e.classification == "lethal":
			if e.lethal.size() != 2+int(e.lethal.has("continuation"))+int(e.lethal.has("v4")): return false
			if e.lethal.has("v4"):
				var retained: Dictionary = record.get("lethal",{}).get("events",{}).get("char-exhaustion",{}).get("exhaustion-"+id,{})
				if retained.is_empty() or e.lethal.v4 != _owner.get_ref().lethal.outcome(retained): return false
				if (retained.phase in ["sources","evaluation"] and e.phase != "lethal-pending") or (retained.phase == "dead" and e.phase != "dead") or (retained.phase == "prevented" and e.phase not in ["incapacitated","resolved"]): return false
			elif e.phase in ["lethal-pending","dead"]: return false
			if e.elapsed != 0 or not e.recovery.is_empty() or not e.lethal.get("request") is Dictionary or e.lethal.request.get("actor") != record.actor or e.lethal.request.get("session") != record.session or e.lethal.request.get("operation") != "exhaustion-"+id or e.lethal.get("result",{}).get("kind") != "unavailable": return false
			if e.lethal.request.size() != 4 or not e.lethal.request.get("attribution") is Dictionary or e.lethal.request.attribution.size() != 3 or not e.lethal.get("result") is Dictionary or e.lethal.result.size() != 3 or typeof(e.lethal.result.get("ok")) != TYPE_BOOL or e.lethal.result.ok or not e.lethal.result.get("reason") is String: return false
			for field in ["source","cause","component"]:
				if not Paths.valid_id(e.lethal.request.attribution.get(field)): return false
			if not e.lethal.has("v4") and e.phase != "lethal-unavailable" and (e.lethal.get("continuation",{}).get("phase") != "prevented" or e.lethal.continuation.get("episode") != id): return false
			if e.lethal.has("continuation") and (not e.lethal.continuation is Dictionary or e.lethal.continuation.size() != 4 or typeof(e.lethal.continuation.get("ok")) != TYPE_BOOL or not e.lethal.continuation.ok or not F.integer(e.lethal.continuation.get("revision"),1,LIMIT) or e.lethal.continuation.get("episode") != id or e.lethal.continuation.get("phase") != "prevented"): return false
		if e.elapsed > 0 and (e.classification != "safe" or not e.stopped or e.time.get("elapsed_usec") != e.elapsed): return false
		if not e.recovery.is_empty():
			if e.elapsed != HOUR or e.time.get("phase") != "completed" or e.time.get("events") != [true,true,true] or e.recovery.size() != 10 or e.recovery.get("ok") != true or e.medical != e.recovery.get("medical"): return false
			if not recovery_context_valid(e.recovery.get("context")) or not F.integer(e.recovery.get("medical_live"),-LIMIT,LIMIT) or not F.integer(e.recovery.get("endurance_live"),0,LIMIT) or not e.recovery.get("maxima") is Dictionary or e.recovery.maxima.size() != 4: return false
			for pool in ["health","fatigue","magicka"]:
				for key in ["before","after","applied","rates"]:
					if not e.recovery.get(key) is Dictionary or not F.integer(e.recovery[key].get(pool),0,LIMIT): return false
				if not e.recovery.get("maxima") is Dictionary or not F.integer(e.recovery.maxima.get(pool),0,LIMIT) or e.recovery.after[pool] != mini(e.recovery.maxima[pool],e.recovery.before[pool]+e.recovery.rates[pool]) or e.recovery.applied[pool] != e.recovery.after[pool]-e.recovery.before[pool]: return false
			var medical: Dictionary = e.medical
			if not F.integer(medical.get("before"),0,LIMIT) or not F.integer(medical.get("requested"),0,LIMIT) or medical != Math.practice(medical.before,medical.requested,int(_policy.activity.practice_cap)): return false
		if e.phase == "resolved" and (e.resolution.is_empty() or (e.classification != "lethal" and e.recovery.is_empty() and e.time.get("phase") != "interrupted")): return false
	if active > 1 or (active == 0 and not s.active.is_empty()) or resolved != s.resolved_count: return false
	for caller in s.settlements:
		if not Paths.valid_id(caller) or not s.settlements[caller] is Dictionary: return false
		for operation in s.settlements[caller]:
			var id: Variant = s.settlements[caller][operation]
			if not id is String or not s.episodes.has(id) or record.vitals.transitions[id].context.get("caller") != caller or record.vitals.transitions[id].context.get("operation") != operation: return false
	return s.game == record.progression.activity_baseline.instant*1000+game and s.simulation == simulation and arithmetic_valid(s)

func arithmetic_valid(state: Dictionary) -> bool:
	# Reconstruction-only replay of checked arithmetic, never gameplay callbacks,
	# RNG, notifications or mutation. Point writes/lookups do not visit this ledger.
	var entries: Array = []
	for ledger: Dictionary in state.receipts.values():
		for receipt: Dictionary in ledger.values():
			if receipt.request.kind != "exhaustion": entries.append(receipt)
	entries.sort_custom(func(a,b): return a.result.revision < b.result.revision)
	var debt := 0
	var cadence := 0
	var swimming := 0
	var tick := 0
	var previous_practice := {}
	for receipt: Dictionary in entries:
		var r: Dictionary = receipt.request
		var out: Dictionary = receipt.result
		var requested := 0
		var awards := {}
		var selected: String = out.selected
		var required_rates: Array = ["jump"] if r.kind == "jump" else [selected]
		if selected == "swimming" and r.kind == "segment" and not r.context.argonian: required_rates.append("swimming-failure")
		if out.rates.size() != required_rates.size(): return false
		for key: String in required_rates:
			if not out.rates.has(key): return false
		var cutoff: int = out.game
		if r.kind == "segment" and r.clock.ownership == "ordinary":
			var remaining: int = out.game
			while remaining > 0:
				var rate: int = out.rates[selected]
				var duration := remaining
				if selected == "swimming":
					if swimming == 0: tick += 1
					if not state.checks.has(str(tick)): return false
					if not state.checks[str(tick)].success and not r.context.argonian: rate = out.rates["swimming-failure"]
					duration = mini(duration,MINUTE-swimming)
				var numerator: int = debt+duration*rate
				if rate > 0 and requested < out.before and requested+F.floor_ratio(numerator,MINUTE) >= out.before:
					cutoff = mini(cutoff,out.game-remaining+F.floor_ratio((out.before-requested)*MINUTE-debt+rate-1,rate))
				requested += F.floor_ratio(numerator,MINUTE)
				debt = numerator%MINUTE
				remaining -= duration
				if selected == "swimming":
					swimming += duration
					if swimming == MINUTE:
						swimming = 0
						if out.game-remaining <= cutoff: awards["swimming"] = awards.get("swimming",0)+int(_policy.activity.practice_amounts.swimming)
			if r.context.motion.running and r.context.motion.voluntary_motion and not r.context.motion.riding:
				cadence += mini(out.simulation,F.floor_ratio(cutoff*r.clock.denominator,r.clock.numerator))
				awards["running"] = F.floor_ratio(cadence,int(_policy.activity.running_cadence_usec))*int(_policy.activity.practice_amounts.running)
				cadence %= int(_policy.activity.running_cadence_usec)
		elif r.kind == "jump":
			requested = out.rates.jump
			awards["jumping"] = int(_policy.activity.practice_amounts.jumping)
		elif r.kind == "climb-check" or (r.kind == "rappel-complete" and r.context.success): awards["climbing"] = int(_policy.activity.practice_amounts.climbing if r.kind == "climb-check" else _policy.activity.practice_amounts.rappel)
		if requested != out.requested or awards.size() != out.practice.size(): return false
		for skill: String in awards:
			if not out.practice.has(skill) or out.practice[skill].requested != awards[skill]: return false
			if previous_practice.has(skill) and out.practice[skill].before != previous_practice[skill]: return false
			previous_practice[skill] = out.practice[skill].after
	return debt == state.fatigue_remainder and cadence == state.running_remainder and swimming == state.swimming_remainder and tick == state.swimming_tick

