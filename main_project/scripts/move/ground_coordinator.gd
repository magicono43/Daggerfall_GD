extends RefCounted
## Session-scoped single ground coordinator. TIME/traits/restrictions are required
## explicit suppliers; stock entry does not invent their missing policies.
signal committed(result: Dictionary)
signal failed(result: Dictionary)
const Gait = preload("res://scripts/move/ground_gait.gd")
var gait := Gait.new()
var core: SessionLifecycle
var input: RefCounted
var view: RefCounted
var placement: Node3D
var scope := ""
var actor := ""
var time_owner: RefCounted
var traits_owner: RefCounted
var restriction_owner: RefCounted
var _trait_identity := ""
var _restriction_identity := ""
var _trait_snapshot: Dictionary = {}
var _restriction_snapshot: Dictionary = {}
var profile: Dictionary = {}
var _content := -1
var _sequence := 0
var _pending: Dictionary = {}
var _after_pending: Dictionary = {}
var _attempted := false
var _must_settle := false
var _captured_revisions: Dictionary = {}
var _proof: Dictionary = {}
var retired_work: Dictionary = {}
var _hold := 0
var _busy := false
var last: Dictionary = {}
var _formula_operation: Dictionary = {}
var reason := "Ground interval/traits/restriction providers unavailable."

func _init(lifecycle: SessionLifecycle, actions: RefCounted, facing: RefCounted, body: Node3D) -> void:
	core = lifecycle
	input = actions
	view = facing
	placement = body
	placement.bind_ground(self)
	gait.formula = _formula
	input.invalidated.connect(gait.interrupt)
	core.retiring.connect(retire)
	placement.pose_committed.connect(_placed)
func _placed(state: Dictionary) -> void:
	# Placement reset is independent of ordinary input suspension.
	_sequence = 0
	if gait._scope != state.session: gait.reset(state.session)
func can_configure(candidate: Dictionary) -> bool: return gait.can_configure(candidate)
func configure(candidate: Dictionary) -> bool: return gait.configure(candidate)
func edge(value: Dictionary) -> bool: return gait.edge(value,input)
func reset_after_load(session: String) -> Dictionary:
	if _busy or not _pending.is_empty() or not _after_pending.is_empty() or session != scope or core.snapshot().session != session or core.snapshot().phase != "initializing": return {"ok":false,"reason":"Gated current load initialization with settled activity required."}
	gait.reset(session)
	return {"ok":true,"native_save_ready":false}
func service_binding(session: String) -> Dictionary:
	return {"role":"ground_motion","owner":"MOVE","lifetime":"session","required":true,"ready":session == scope,"provider":self,"formula_hooks":["move.ground-speed"],"actor_activity":{"id":"ground-motion","roles":["motion"]}}

func formula_operation_current(operation: Dictionary) -> bool:
	return _busy and not scope.is_empty() and core.snapshot().session == scope and operation == _formula_operation
func _formula(value: Dictionary) -> Dictionary:
	return core.formulas.invoke("move.ground-speed",value,core,self,scope,_formula_operation)

## Suppliers must already be qualified by CORE before an eligible physics step.
## This interface enables no story entry or native restore bypass.
func bind(session: String, player: String, clock: RefCounted, traits: RefCounted, restrictions: RefCounted) -> Dictionary:
	if retired_work.size() >= 64: return {"ok":false,"reason":"Retired ground diagnostics require application retirement."}
	if _busy or not _pending.is_empty() or session.is_empty() or core.snapshot().session != session or clock == null or traits == null or restrictions == null or not clock.has_method("ground_interval") or not clock.has_method("capture_ground") or not clock.has_method("activity_current") or not traits.has_method("ground_traits") or not restrictions.has_method("ground_restrictions"): return {"ok":false,"reason":"Required scoped ground suppliers unavailable."}
	var trait_identity: Variant = traits.get("id")
	var restriction_identity: Variant = restrictions.get("id")
	if not preload("res://scripts/mod/package_library.gd").valid_id(trait_identity) or not preload("res://scripts/mod/package_library.gd").valid_id(restriction_identity): return {"ok":false,"reason":"Stable scoped trait/restriction supplier identities required."}
	var definition: Dictionary = core.actors.definitions.query("move.ground","policy","player")
	if not definition.ok: return definition
	profile = definition.record.value.duplicate(true)
	_content = core.actors.definitions.content_ticket()
	scope = session
	actor = player
	time_owner = clock
	traits_owner = traits
	restriction_owner = restrictions
	_trait_identity = trait_identity
	_restriction_identity = restriction_identity
	_trait_snapshot = {}
	_restriction_snapshot = {}
	gait.reset(scope)
	reason = ""
	return {"ok":true}

func _stop(message: String) -> Dictionary:
	var changed := reason != message
	reason = message
	if _hold == 0 and not scope.is_empty(): _hold = core.gates.acquire("ground-continuation",scope,["simulation","input","save"])
	var result := {"ok":false,"reason":reason,"performed_debt":not _pending.is_empty()}
	if changed:
		var was_busy := _busy
		_busy = true
		failed.emit(result.duplicate(true))
		_busy = was_busy
	return result

func activity_current(request: Dictionary) -> bool:
	if request.get("kind") == "exhaustion":
		if request.get("session") != scope or request.get("actor") != actor or scope.is_empty() or core.snapshot().session != scope or request.providers.get("motion") != {"id":"ground-motion","revision":_sequence}: return false
		var capability: Dictionary = core.actors.ground_capabilities(scope,actor)
		return capability.ok and request.content == capability.content and not capability.voluntary_allowed
	return request == _proof and request.session == scope and core.snapshot().session == scope

func activity_snapshot(request: Dictionary) -> Dictionary:
	if not activity_current(request) or not placement.ground_context(scope).get("ok",false): return {"ok":false}
	return {"ok":true,"revision":_sequence,"swimming":false}

func activity_execute(request: Dictionary) -> Dictionary:
	if not activity_current(request) or not _pending.is_empty() or request.get("continuation",{}).get("step") != "stop": return {"ok":false}
	# Stop voluntary advancement, preserving velocity and future passive history.
	return {"ok":true,"revision":_sequence,"stopped":true}

func retry_activity() -> Dictionary:
	if _busy: return {"ok":false,"reason":"Ground delivery reentrant."}
	if _pending.is_empty(): return {"ok":true,"unchanged":true}
	_busy = true
	var result := {}
	for index in 2:
		result = _settle_one()
		if not result.get("ok",false) or _pending.is_empty(): break
	_busy = false
	return result

func _settle_one() -> Dictionary:
	_attempted = true
	var result: Dictionary = core.actors.activity_intake({"motion":self,"interval":time_owner,"traits":traits_owner},_pending)
	if not result.get("ok",false): return _stop("Committed ground interval remains unsettled: "+str(result.get("reason","provider failure")))
	if not _after_pending.is_empty():
		# The queued segment has never been admitted to CHAR. Its original physical
		# capability revision remains in _captured_revisions and TIME's proof;
		# assign only its first intake's expected actor-write revision here.
		var renewed: Dictionary = core.actors.advance_motion_activity(self,scope,actor)
		if not renewed.ok: return _stop("Performed ground custody retired during settlement.")
		_pending = _after_pending
		_after_pending = {}
		_pending.revision = renewed.revision
		_proof = _pending.duplicate(true)
	else:
		core.actors.release_motion_activity(self,scope,actor)
		_pending.clear()
	_attempted = false
	_must_settle = false
	if _hold != 0:
		core.gates.release(_hold,"ground-continuation")
		_hold = 0
	reason = ""
	return result

func physics_step(delta: Variant) -> Dictionary:
	if _busy: return {"ok":false,"reason":"Ground physics reentrant."}
	if scope.is_empty(): return {"ok":false,"reason":reason}
	if _attempted or not _after_pending.is_empty(): return {"ok":false,"reason":"Settle committed activity before further travel."}
	if not core.gates.simulation():
		if not _pending.is_empty(): retry_activity()
		return {"ok":true,"suspended":true}
	if typeof(delta) != TYPE_FLOAT or not is_finite(delta) or delta <= 0.0 or delta > 0.1: return _stop("Unsupported physics interval.")
	var rate: float = core.gates.intended_rate
	if not is_finite(rate) or rate < 0.0: return _stop("Unsupported CORE intended simulation rate.")
	if rate == 0.0:
		if not _pending.is_empty(): retry_activity()
		return {"ok":true,"rate_held":true}
	delta *= rate
	if not is_finite(delta) or delta > 0.1: return _stop("Scaled CORE physics interval requires a supported smaller step.")
	_busy = true
	var result := _advance(delta)
	_busy = false
	if not result.get("ok",false): return _stop(str(result.get("reason","Ground provider failure.")))
	if _hold != 0: result.activity = {"ok":false,"phase":"performed-debt","reason":reason}
	elif not _pending.is_empty() and (_must_settle or _pending.clock.end_sim-_pending.clock.start_sim >= 1000000):
		var settlement := retry_activity()
		result.activity = settlement
	elif not _pending.is_empty(): result.activity = {"ok":true,"phase":"performed-awaiting-boundary","operation":_pending.operation}
	last = result.duplicate(true)
	# Both physical and gait/activity outcomes are committed before observers.
	_busy = true
	committed.emit(last.duplicate(true))
	_busy = false
	return result

func _advance(delta: float) -> Dictionary:
	if core.snapshot().session != scope or core.actors.definitions.content_ticket() != _content: return {"ok":false,"reason":"Ground scope/content retired."}
	var capability: Dictionary = core.actors.ground_capabilities(scope,actor)
	if not capability.ok: return capability
	if capability.activity_count >= 4095 and not _pending.is_empty():
		var flushed := _settle_one()
		if not flushed.ok: return flushed
		capability = core.actors.ground_capabilities(scope,actor)
	if capability.revision > 1000000000-32 or capability.activity_count >= 4096: return {"ok":false,"reason":"CHAR activity retention/revision requires settlement boundary."}
	var context := {"session":scope,"actor":actor,"content":_content,"revision":capability.revision,"sequence":_sequence+1,"rate":core.gates.intended_rate}
	_formula_operation = context.duplicate(true)
	var restrictions: Variant = restriction_owner.ground_restrictions(context.duplicate(true))
	if not restrictions is Dictionary or restrictions.size() != 4 or restrictions.get("ok") != true or typeof(restrictions.get("ok")) != TYPE_BOOL or typeof(restrictions.get("revision")) != TYPE_INT or restrictions.revision < 1 or restrictions.revision > 1000000000 or typeof(restrictions.get("voluntary")) != TYPE_BOOL or not restrictions.get("run") is String or restrictions.run not in ["allow","walk","stop"]: return {"ok":false,"reason":"Required movement restriction state unavailable."}
	if not _restriction_snapshot.is_empty() and (restrictions.revision < _restriction_snapshot.revision or (restrictions.revision == _restriction_snapshot.revision and restrictions != _restriction_snapshot)): return {"ok":false,"reason":"Stale or changed same-revision restriction facts."}
	var traits: Variant = traits_owner.ground_traits(context.duplicate(true))
	if not traits is Dictionary or traits.size() != 5 or typeof(traits.get("ok")) != TYPE_BOOL or not traits.ok or typeof(traits.get("revision")) != TYPE_INT or traits.revision < 1 or traits.revision > 1000000000: return {"ok":false,"reason":"Required effective movement traits unavailable."}
	for field in ["athleticism","improved_athleticism","argonian"]:
		if typeof(traits.get(field)) != TYPE_BOOL: return {"ok":false,"reason":"Strict effective trait booleans required."}
	if not _trait_snapshot.is_empty() and (traits.revision < _trait_snapshot.revision or (traits.revision == _trait_snapshot.revision and traits != _trait_snapshot)): return {"ok":false,"reason":"Stale or changed same-revision trait facts."}
	_trait_snapshot = traits.duplicate(true)
	_restriction_snapshot = restrictions.duplicate(true)
	var selected := gait.resolve(input,capability,profile)
	if not selected.ok: return selected
	if not capability.voluntary_allowed or not restrictions.voluntary: selected.direction = Vector2.ZERO
	if selected.gait == "run" and restrictions.run != "allow":
		# A provider must explicitly select its supported fallback.
		if restrictions.run == "stop": selected.direction = Vector2.ZERO
		else:
			# Re-resolve through gait owner to preserve independent Walk modifiers.
			var fallback := gait.resolve(input,capability,profile,"walk")
			if not fallback.ok: return fallback
			selected.gait = fallback.gait
			selected.target_metres_per_second = fallback.target_metres_per_second
	var facing: Dictionary = view.capture_facing(scope)
	if not facing.get("ok",false): return {"ok":false,"reason":"Actual view facing unavailable."}
	var body: Dictionary = placement.ground_context(scope)
	if not body.ok: return body
	var interval: Variant = time_owner.ground_interval(context.duplicate(true),delta)
	if not interval is Dictionary or interval.size() != 3 or typeof(interval.get("ok")) != TYPE_BOOL or not interval.ok or not interval.get("clock") is Dictionary or not interval.get("provider") is Dictionary: return {"ok":false,"reason":"Eligible TIME interval unavailable."}
	# Validate the exact CHAR envelope before any irreversible physical travel.
	var op: String = interval.clock.get("interval","")
	var activity := {"schema":"actor-activity-v1","session":scope,"actor":actor,"caller":interval.provider.get("id",""),"operation":op,"content":capability.content,"revision":capability.revision,"kind":"segment","context":{"motion":{"climbing":false,"running":false,"voluntary_motion":false,"passive_motion":false,"swimming":false,"riding":false,"athleticism":traits.athleticism,"improved_athleticism":traits.improved_athleticism},"argonian":traits.argonian,"event":op,"success":true,"breath":{"holding":false,"breathable":false}},"clock":interval.clock.duplicate(true),"providers":{"motion":{"id":"ground-motion","revision":_sequence+1},"interval":interval.provider.duplicate(true),"traits":{"id":_trait_identity,"revision":traits.revision}},"source":{"source":"ground-motion","cause":"committed-ground","component":op}}
	if not core.actors.activity_request_valid(activity): return {"ok":false,"reason":"Malformed TIME/activity envelope; no physical travel performed."}
	var c: Dictionary = activity.clock
	var expected_game: int = capability.activity_game if _pending.is_empty() else _pending.clock.end_game
	var expected_sim: int = capability.activity_sim if _pending.is_empty() else _pending.clock.end_sim
	if c.start_game != expected_game or c.start_sim != expected_sim or capability.activity_owner not in ["",activity.caller]: return {"ok":false,"reason":"TIME cursor/interval ownership conflicts with CHAR."}
	if c.ownership != "ordinary" or c.end_sim-c.start_sim <= 0 or absf(float(c.end_sim-c.start_sim)-delta*1000000.0) > 1.001 or c.end_game-c.start_game <= 0 or c.end_game-c.start_game > 1000000000 or (c.end_game-c.start_game)*c.denominator != (c.end_sim-c.start_sim)*c.numerator: return {"ok":false,"reason":"TIME interval does not represent the eligible bounded physics step."}
	for role: String in ["motion","interval","traits"]:
		var supplier: RefCounted = self if role == "motion" else time_owner if role == "interval" else traits_owner
		if not core.activity_owner(scope,supplier,activity.providers[role].id,role): return {"ok":false,"reason":"Required CORE activity service binding absent: "+role}
	if core.snapshot().session != scope or not core.gates.simulation() or core.gates.intended_rate != context.rate or core.actors.ground_capabilities(scope,actor) != capability: return {"ok":false,"reason":"Ground supplier changed capability/scope/gates/rate during preparation."}
	var direction: Vector2 = selected.direction
	var velocity: Vector3 = Vector3(direction.x,0,direction.y).rotated(Vector3.UP,deg_to_rad(-float(facing.yaw)))*selected.target_metres_per_second
	var custody: Dictionary = core.actors.reserve_motion_activity(self,capability)
	if not custody.ok: return custody
	var motion: Dictionary = placement.advance_ground(self,{"session":scope,"sequence":_sequence+1,"delta":delta,"velocity":velocity,"forward":Vector3.FORWARD.rotated(Vector3.UP,deg_to_rad(-float(facing.yaw))),"placement_serial":body.serial})
	if not motion.ok:
		if _pending.is_empty(): core.actors.release_motion_activity(self,scope,actor)
		return motion
	_sequence += 1
	var moving: bool = motion.actual_metres_per_second > profile.moving_metres_per_second
	activity.context.motion.running = selected.gait == "run" and moving
	activity.context.motion.voluntary_motion = moving
	# A segment can grow only before its first delivery, while context and all
	# captured source revisions agree. Collision classification boundaries split it.
	var compatible: bool = not _pending.is_empty() and _pending.context.motion == activity.context.motion and _pending.context.argonian == activity.context.argonian and _pending.providers.traits == activity.providers.traits and _pending.providers.interval == activity.providers.interval and _pending.revision == activity.revision and _pending.clock.numerator == activity.clock.numerator and _pending.clock.denominator == activity.clock.denominator and _captured_revisions[_pending.operation].speed_sources == selected.source_revisions
	if compatible and _captured_revisions[_pending.operation].restriction != restrictions: compatible = false
	if compatible and activity.clock.end_game-_pending.clock.start_game > 1000000000: compatible = false
	if compatible:
		activity.operation = _pending.operation
		activity.context.event = _pending.operation
		activity.source.component = _pending.operation
		activity.clock.interval = _pending.operation
		activity.clock.start_game = _pending.clock.start_game
		activity.clock.start_sim = _pending.clock.start_sim
		activity.providers.motion = _pending.providers.motion.duplicate(true)
	if not _captured_revisions.has(activity.operation): _captured_revisions[activity.operation] = {"capabilities":[capability.revision],"speed_sources":selected.source_revisions.duplicate(),"restriction_source":_restriction_identity,"restriction":restrictions.duplicate(true)}
	elif capability.revision not in _captured_revisions[activity.operation].capabilities: _captured_revisions[activity.operation].capabilities.append(capability.revision)
	if not _pending.is_empty() and not compatible:
		_after_pending = activity.duplicate(true)
	else:
		_pending = activity.duplicate(true)
		_proof = activity.duplicate(true)
	motion.gait = selected.duplicate(true)
	motion.activity_operation = activity.operation
	motion.activity = {"ok":true,"phase":"performed-awaiting-boundary","operation":activity.operation}
	# Stage coherent physical/gait/performed results before any supplier or CHAR
	# callback can notify a scoped observer. Settlement updates follow by identity.
	last = motion.duplicate(true)
	# Capture original eligible proof even if a later owner rejects delivery.
	var captured: Variant = time_owner.capture_ground(activity.duplicate(true))
	if typeof(captured) != TYPE_BOOL or not captured: _stop("TIME failed to retain performed interval proof.")
	if not _after_pending.is_empty():
		var settled := _settle_one()
		if not settled.ok: return motion
	var preview: Dictionary = core.actors.preview_ground_activity(self,_pending)
	if not preview.ok: _stop("Performed ground prediction requires recovery: "+str(preview.get("reason","unavailable")))
	else: _must_settle = preview.settle
	if motion.get("handoff_pending",false): _stop("Ground sliding exit requires later air/surface handoff.")
	return motion

func retire(session: String) -> void:
	if session != scope: return
	# Debt remains diagnosable on the retired coordinator; cannot enter a new scope.
	if not _pending.is_empty(): retired_work[scope] = {"request":_pending.duplicate(true),"queued":_after_pending.duplicate(true),"captured_revisions":_captured_revisions.duplicate(),"reason":reason,"physical":last.duplicate(true)}
	_pending.clear()
	_after_pending.clear()
	_captured_revisions.clear()
	_attempted = false
	_must_settle = false
	_proof.clear()
	gait.reset("")
	scope = ""
	time_owner = null
	traits_owner = null
	restriction_owner = null
	_hold = 0
	reason = "Ground scope retired."

func dispose() -> void:
	gait.formula = Callable()
	input.invalidated.disconnect(gait.interrupt)
	core.retiring.disconnect(retire)
	placement.pose_committed.disconnect(_placed)
	for event: Signal in [committed,failed]:
		for connection: Dictionary in event.get_connections(): event.disconnect(connection.callable)
	retired_work.clear()
