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
var _gait_profile: Dictionary = {}
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
var _view_height := NAN
var _view_base_y := NAN
var _physical_base_y := NAN
var reason := "Ground interval/traits/restriction providers unavailable."
var air_policy: Dictionary = {}
var _jump_edge: Dictionary = {}
var _jump_sequence := 0
var _jump_debt: Dictionary = {}
var _jump_proof: Dictionary = {}
var _jump_result: Dictionary = {}
var _landing_request: Dictionary = {}
var _landing_hold := 0
signal landed(outcome: Dictionary)
var _air_sources: Dictionary = {}
var _platform: Dictionary = {}
var _air_effect_snapshot: Dictionary = {}

## Narrow MOVE mode/provider handoff. The real specialist must attest successful
## control/entry; input requests alone never protect. No specialist is implemented.
func protection_transition(provider: RefCounted, r: Dictionary) -> Dictionary:
	if _busy or r.size() != 8 or r.get("session") != scope or not preload("res://scripts/mod/package_library.gd").valid_id(r.get("source")) or typeof(r.get("revision")) != TYPE_INT or r.revision < 1 or r.revision > 1000000000 or r.get("kind") not in ["climb","rappel","levitation","water"] or typeof(r.get("active")) != TYPE_BOOL or typeof(r.get("success")) != TYPE_BOOL or not r.get("evidence") is Dictionary or r.get("placement_serial") != placement.snapshot().get("serial"): return {"ok":false,"reason":"Complete current protection transition required."}
	if not core.activity_owner(scope,provider,r.source,"motion") or not provider.has_method("air_transition_current"): return {"ok":false,"reason":"Unbound MOVE protection provider."}
	var old: Dictionary = _air_sources.get(r.source,{})
	if not old.is_empty():
		if old.owner.get_ref() != provider or r.revision < old.request.revision or (r.revision == old.request.revision and r != old.request): return {"ok":false,"reason":"Changed/stale protection source."}
		if r == old.request: return old.result.duplicate(true)
	if _air_sources.size() >= 64 and old.is_empty(): return {"ok":false,"reason":"Protection retention exhausted."}
	_busy = true
	var valid: Variant = provider.air_transition_current(r.duplicate(true))
	_busy = false
	if typeof(valid) != TYPE_BOOL or not valid or not core.activity_owner(scope,provider,r.source,"motion"): return {"ok":false,"reason":"Protection attestation failed."}
	if not r.success: return {"ok":false,"reason":"Failed mode request does not protect."}
	if r.kind == "water" and r.active:
		var e: Dictionary = r.evidence
		if e.size() != 5 or typeof(e.get("entered")) != TYPE_BOOL or not e.entered or typeof(e.get("solid_first")) != TYPE_BOOL or e.solid_first or typeof(e.get("surface_only")) != TYPE_BOOL or typeof(e.get("sufficient_depth")) != TYPE_BOOL or not (e.surface_only or e.sufficient_depth) or not preload("res://scripts/mod/package_library.gd").valid_id(e.get("volume")): return {"ok":false,"reason":"Actual valid water entry without intervening solids required."}
	elif not r.evidence.is_empty(): return {"ok":false,"reason":"Unexpected protection evidence."}
	var body: Dictionary = placement.ground_context(scope)
	if not body.ok: return body
	placement.air.protection(r.source,r.active,body.position.y-placement.snapshot().shape.height*0.5)
	var result := {"ok":true,"active":r.active,"native_save_ready":false}
	_air_sources[r.source] = {"owner":weakref(provider),"request":r.duplicate(true),"result":result.duplicate(true)}
	return result

## Point velocity is linear + angular(rad/s) cross radius(m), sampled by the
## support owner. This is inheritance only, never platform carriage/crushing.
func platform_velocity(provider: RefCounted, r: Dictionary) -> Dictionary:
	if _busy or r.size() != 9 or r.get("session") != scope or not preload("res://scripts/mod/package_library.gd").valid_id(r.get("source")) or not preload("res://scripts/mod/package_library.gd").valid_id(r.get("support")) or typeof(r.get("revision")) != TYPE_INT or r.revision < 1 or r.revision > 1000000000 or r.get("placement_serial") != placement.snapshot().get("serial") or not core.activity_owner(scope,provider,r.source,"motion") or not provider.has_method("air_transition_current"): return {"ok":false,"reason":"Current bound support-point provider required."}
	for field in ["linear","angular","point","center"]:
		if not r.get(field) is Vector3 or not r[field].is_finite() or r[field].length() > 10000.0: return {"ok":false,"reason":"Finite support-point motion required."}
	var point_velocity: Vector3 = r.linear+r.angular.cross(r.point-r.center)
	if point_velocity.length() > 1000.0: return {"ok":false,"reason":"Platform point speed exceeds collision envelope."}
	if not _platform.is_empty() and (_platform.owner.get_ref() != provider or r.revision < _platform.request.revision or (r.revision == _platform.request.revision and r != _platform.request)): return {"ok":false,"reason":"Stale/changed support sample."}
	_busy = true
	var valid: Variant = provider.air_transition_current(r.duplicate(true))
	_busy = false
	if typeof(valid) != TYPE_BOOL or not valid or not core.activity_owner(scope,provider,r.source,"motion"): return {"ok":false,"reason":"Support-point attestation failed."}
	var body: Dictionary = placement.air_context(self,scope,profile.surface)
	if not body.ok or not body.supported or body.airborne or r.point.distance_to(body.base) > profile.surface.contact_gap*4: return {"ok":false,"reason":"Actual current support point required."}
	_platform = {"owner":weakref(provider),"request":r.duplicate(true),"velocity":point_velocity,"sequence":_sequence+1}
	return {"ok":true,"velocity":point_velocity}

func _inherit_platform(detach := true) -> Vector3:
	var inherited := Vector3.ZERO
	if not _platform.is_empty() and _platform.sequence == _sequence+1 and air_policy.inherit_platform: inherited = _platform.velocity
	if detach: _platform = {} # Only a committed takeoff detaches.
	return inherited

func origin_shift(provider: RefCounted, r: Dictionary) -> Dictionary:
	if _busy or r.size() != 5 or r.get("session") != scope or typeof(r.get("revision")) != TYPE_INT or r.revision < 1 or r.revision > 1000000000 or r.get("placement_serial") != placement.snapshot().get("serial") or not r.get("delta") is Vector3 or not r.delta.is_finite() or not core.activity_owner(scope,provider,str(r.get("source","")),"motion") or not provider.has_method("air_transition_current") or core.gates.simulation(): return {"ok":false,"reason":"Bound gated coherent-origin adapter required."}
	_busy = true
	var valid: Variant = provider.air_transition_current(r.duplicate(true))
	_busy = false
	if typeof(valid) != TYPE_BOOL or not valid or not core.activity_owner(scope,provider,r.source,"motion"): return {"ok":false,"reason":"Origin provider failed attestation."}
	var result: Dictionary = placement.rebase_air(self,scope,r.delta)
	if result.ok:
		_view_base_y = NAN
		_physical_base_y = NAN
		_platform.clear()
	return result

func _init(lifecycle: SessionLifecycle, actions: RefCounted, facing: RefCounted, body: Node3D) -> void:
	core = lifecycle
	input = actions
	view = facing
	placement = body
	placement.bind_ground(self)
	gait.formula = _formula
	input.invalidated.connect(gait.interrupt)
	input.invalidated.connect(_interrupt_jump)
	core.retiring.connect(retire)
	placement.pose_committed.connect(_placed)
func _placed(state: Dictionary) -> void:
	# Placement reset is independent of ordinary input suspension.
	_sequence = 0
	_view_height = NAN
	_view_base_y = NAN
	_physical_base_y = NAN
	if gait._scope != state.session: gait.reset(state.session)
	gait.crouch_selected = state.get("desired_posture",state.physical.posture) == "crouched"
## Placement resets the legitimate eye origin, not an old transition history.
func placement_view_position(state: Dictionary) -> Vector3:
	if profile.is_empty() or state.session != scope: return state.position
	var tuning: Dictionary = profile.surface
	var eye: float = tuning.crouched_eye if state.physical.posture == "crouched" else tuning.standing_eye
	if tuning.camera_radius >= state.shape.radius or eye+tuning.camera_radius >= state.shape.height: return state.position
	_view_height = eye
	_view_base_y = state.position.y-state.shape.height*0.5
	_physical_base_y = _view_base_y
	return Vector3(state.position.x,_view_base_y+eye,state.position.z)

func can_configure(candidate: Dictionary) -> bool: return gait.can_configure(candidate)
func configure(candidate: Dictionary) -> bool: return gait.configure(candidate)
func edge(value: Dictionary) -> bool:
	if value.get("action") == "jump":
		if not _busy and input.context_current(value) and value.get("session") == scope and typeof(value.get("sequence")) == TYPE_INT and value.sequence > _jump_sequence:
			_jump_sequence = value.sequence
			if value.get("kind") == "started": _jump_edge = value.duplicate(true)
		return true
	if _busy: return value.get("action") in ["run","sneak","autorun","crouch"]
	return gait.edge(value,input)
func _interrupt_jump(_reason: String) -> void:
	_jump_edge.clear()
func reset_after_load(session: String) -> Dictionary:
	if _busy or not _pending.is_empty() or not _after_pending.is_empty() or session != scope or core.snapshot().session != session or core.snapshot().phase != "initializing": return {"ok":false,"reason":"Gated current load initialization with settled activity required."}
	input.invalidate("ground load boundary")
	var desired: String = placement.snapshot().get("desired_posture","standing")
	gait.reset(session)
	gait.crouch_selected = desired == "crouched"
	_view_height = NAN
	_view_base_y = NAN
	_physical_base_y = NAN
	return {"ok":true,"native_save_ready":false}
func service_binding(session: String) -> Dictionary:
	return {"role":"ground_motion","owner":"MOVE","lifetime":"session","required":true,"ready":session == scope,"provider":self,"formula_hooks":["move.ground-speed","move.jump-impulse","move.landing-damage"],"actor_activity":{"id":"ground-motion","roles":["motion"]},"vital_intake":"move-landings"}

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
	var air_definition: Dictionary = core.actors.definitions.query("move.air","policy","player")
	if not air_definition.ok: return air_definition
	air_policy = air_definition.record.value.duplicate(true)
	profile = definition.record.value.duplicate(true)
	_gait_profile = profile.duplicate()
	_gait_profile.erase("connectors")
	_gait_profile = _gait_profile.duplicate(true)
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

func _scope_current(expected: String) -> bool:
	return not expected.is_empty() and scope == expected and core.snapshot().session == expected

func _retired_result() -> Dictionary:
	return {"ok":false,"retired":true,"reason":"Movement scope retired during required delivery."}

func _stop(message: String) -> Dictionary:
	var changed := reason != message
	reason = message
	if _hold == 0 and not scope.is_empty(): _hold = core.gates.acquire("ground-continuation",scope,["simulation","input","save"])
	var result := {"ok":false,"reason":reason,"performed_debt":not _pending.is_empty() or not _jump_debt.is_empty() or not placement.air.pending.is_empty()}
	if changed:
		var was_busy := _busy
		_busy = true
		failed.emit(result.duplicate(true))
		_busy = was_busy
	return result

func activity_current(request: Dictionary) -> bool:
	if request.get("kind") == "jump": return request == _jump_proof and request.session == scope and core.snapshot().session == scope
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
	if _pending.is_empty() and _jump_debt.is_empty(): return {"ok":true,"unchanged":true}
	_busy = true
	var result := {}
	for index in 2:
		if _pending.is_empty(): break
		result = _settle_one()
		if not result.get("ok",false) or _pending.is_empty(): break
	if (result.is_empty() or result.get("ok",false)) and _pending.is_empty() and not _jump_debt.is_empty(): result = _settle_jump()
	_busy = false
	return result

func _settle_jump() -> Dictionary:
	if _jump_debt.is_empty(): return {"ok":true}
	var operation_scope := scope
	if not _jump_debt.has("admitted"):
		var cap: Dictionary = core.actors.ground_capabilities(scope,actor)
		if not cap.ok: return _stop("Jump activity actor unavailable.")
		_jump_debt.request.revision = cap.revision
		_jump_proof = _jump_debt.request.duplicate(true)
		_jump_debt.admitted = true
	if not _jump_debt.get("captured",false):
		if not time_owner.has_method("capture_ground_event"): return _stop("TIME jump event proof unavailable; takeoff debt retained.")
		var captured: Variant = time_owner.capture_ground_event(_jump_proof.duplicate(true))
		if not _scope_current(operation_scope): return _retired_result()
		if typeof(captured) != TYPE_BOOL or not captured: return _stop("TIME jump event proof unavailable; takeoff debt retained.")
		_jump_debt.captured = true
	var result: Dictionary = core.actors.activity_intake({"motion":self,"interval":time_owner,"traits":traits_owner},_jump_debt.request)
	if not _scope_current(operation_scope): return _retired_result()
	if not result.get("ok",false): return _stop("Jump activity remains unsettled: "+str(result.get("reason","owner failure")))
	_jump_result = result.duplicate(true)
	_jump_debt.clear()
	if _pending.is_empty(): core.actors.release_motion_activity(self,scope,actor)
	if _hold != 0:
		core.gates.release(_hold,"ground-continuation")
		_hold = 0
	reason = ""
	return result

func _settle_one() -> Dictionary:
	_attempted = true
	var operation_scope := scope
	var result: Dictionary = core.actors.activity_intake({"motion":self,"interval":time_owner,"traits":traits_owner},_pending)
	if not _scope_current(operation_scope): return _retired_result()
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
	var step_scope := scope
	if not _jump_debt.is_empty(): return {"ok":false,"reason":"Settle committed jump before further travel."}
	if not placement.air.pending.is_empty(): return {"ok":false,"reason":"Settle committed landing before further travel."}
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
	if not _scope_current(step_scope): return _retired_result()
	if not result.get("ok",false): return _stop(str(result.get("reason","Ground provider failure.")))
	if _hold != 0: result.activity = {"ok":false,"phase":"performed-debt","reason":reason}
	elif not _pending.is_empty() and (_must_settle or _pending.clock.end_sim-_pending.clock.start_sim >= 1000000):
		var settlement := retry_activity()
		result.activity = settlement
	elif not _pending.is_empty(): result.activity = {"ok":true,"phase":"performed-awaiting-boundary","operation":_pending.operation}
	if not _scope_current(step_scope): return _retired_result()
	if result.get("contact_recovery",false):
		_stop("Air collision contact requires owner recovery; motion history retained.")
		core.required_service_lost(scope,"air-contact")
		result.ok = false
		result.reason = reason
	last = result.duplicate(true)
	if result.get("landing",{}).size() > 0:
		var settlement := retry_activity()
		if settlement.get("ok",false): result.landing_settlement = retry_landing()
	if not _scope_current(step_scope): return _retired_result()
	# Both physical and gait/activity outcomes are committed before observers.
	last = result.duplicate(true)
	_busy = true
	committed.emit(last.duplicate(true))
	_busy = false
	return result

func _advance(delta: float) -> Dictionary:
	if core.snapshot().session != scope or core.actors.definitions.content_ticket() != _content: return {"ok":false,"reason":"Ground scope/content retired."}
	if placement.air.segment >= 1000000000 or placement.air.outcomes.size() >= 4096: return {"ok":false,"reason":"Air history retention requires an owner checkpoint/retirement boundary."}
	for source: String in placement.air.protections:
		if source == "@effect/slow-fall": continue
		var retained: Dictionary = _air_sources.get(source,{})
		if retained.is_empty() or not core.activity_owner(scope,retained.owner.get_ref(),source,"motion"): return {"ok":false,"reason":"Active protective mode provider unavailable."}
	var jump_pressed: bool = not _jump_edge.is_empty() and input.context_current(_jump_edge)
	_jump_edge.clear() # Every rejected press expires on this eligible delivery.
	if jump_pressed and not _pending.is_empty():
		var settled := _settle_one()
		if not settled.ok: return settled
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
	var desired := gait.desired_posture(input)
	var posture: Dictionary = placement.prepare_ground_posture(self,scope,desired,profile.surface)
	if not posture.ok: return posture
	var selected := gait.resolve(input,capability,_gait_profile,"",posture.actual)
	if not selected.ok: return selected
	if not capability.voluntary_allowed or not restrictions.voluntary: selected.direction = Vector2.ZERO
	if selected.gait == "run" and restrictions.run != "allow":
		# A provider must explicitly select its supported fallback.
		if restrictions.run == "stop": selected.direction = Vector2.ZERO
		else:
			# Re-resolve through gait owner to preserve independent Walk modifiers.
			var fallback := gait.resolve(input,capability,_gait_profile,"walk",posture.actual)
			if not fallback.ok: return fallback
			selected.gait = fallback.gait
			selected.target_metres_per_second = fallback.target_metres_per_second
	var facing: Dictionary = view.capture_facing(scope)
	if not facing.get("ok",false): return {"ok":false,"reason":"Actual view facing unavailable."}
	var body: Dictionary = placement.ground_context(scope)
	if not body.ok: return body
	var air_context: Dictionary = placement.air_context(self,scope,profile.surface)
	if not air_context.ok: return air_context
	var effects: Dictionary = {}
	if traits_owner.has_method("air_traits"):
		var supplied: Variant = traits_owner.air_traits(context.duplicate(true))
		if not supplied is Dictionary or supplied.size() != 5 or supplied.get("ok") != true or typeof(supplied.get("revision")) != TYPE_INT or supplied.revision != traits.revision or typeof(supplied.get("enhanced")) != TYPE_BOOL or typeof(supplied.get("slow_fall")) != TYPE_BOOL or not (supplied.get("slow_fall_speed") is float or supplied.get("slow_fall_speed") is int) or not is_finite(float(supplied.slow_fall_speed)) or supplied.slow_fall_speed <= 0.0 or supplied.slow_fall_speed > 100.0: return {"ok":false,"reason":"Invalid live air effect projection."}
		effects = supplied.duplicate(true)
		if not _air_effect_snapshot.is_empty() and (effects.revision < _air_effect_snapshot.revision or (effects.revision == _air_effect_snapshot.revision and effects != _air_effect_snapshot)): return {"ok":false,"reason":"Stale or changed same-revision air effects."}
		_air_effect_snapshot = effects.duplicate(true)
	elif jump_pressed or air_context.airborne or not air_context.supported: return {"ok":false,"reason":"Required air effect provider unavailable."}
	var starting_air: bool = not air_context.airborne and not air_context.supported
	if not air_context.airborne and not _platform.is_empty() and (_platform.sequence != _sequence+1 or not core.activity_owner(scope,_platform.owner.get_ref(),_platform.request.source,"motion")): return {"ok":false,"reason":"Current moving-support point sample unavailable."}
	var jumping: bool = jump_pressed and not air_context.airborne and air_context.supported and capability.voluntary_allowed and restrictions.voluntary and not (effects.slow_fall and air_policy.slow_fall_blocks_jump)
	var takeoff := {}
	var initial_velocity := Vector3(body.velocity.x,0,body.velocity.z)
	if jumping:
		var quote: Dictionary = core.actors.quote_jump(self,capability,traits)
		if not quote.ok: return quote
		jumping = quote.eligible
		if jumping:
			var values := {"profile":air_policy.duplicate(true),"jumping":capability.jumping,"athleticism":traits.athleticism,"improved_athleticism":traits.improved_athleticism,"enhanced":effects.enhanced,"crouched":posture.actual == "crouched"}
			var impulse: Dictionary = core.formulas.invoke("move.jump-impulse",values,core,self,scope,_formula_operation)
			if not impulse.ok: return impulse
			initial_velocity.y = minf(impulse.value,air_policy.maximum_impulse)*air_policy.metres_per_reference_unit
			takeoff = {"id":"jump-"+str(_jump_sequence),"event_sequence":_jump_sequence,"kind":"jump","snapshot":values,"gait":selected.duplicate(true),"impulse":initial_velocity.y}
			initial_velocity += Vector3.FORWARD.rotated(Vector3.UP,deg_to_rad(-float(facing.yaw)))*air_policy.boost_speed*air_policy.metres_per_reference_unit
	if starting_air: takeoff = {"id":"walk-off-"+str(_sequence+1),"kind":"walk-off","gait":selected.duplicate(true)}
	if jumping or starting_air: initial_velocity += _inherit_platform(false)
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
	if view.origin_clearance_radius() > profile.surface.camera_radius: return {"ok":false,"reason":"Camera near plane exceeds the validated posture-clearance envelope."}
	var direction: Vector2 = selected.direction
	var velocity: Vector3 = Vector3(direction.x,0,direction.y).rotated(Vector3.UP,deg_to_rad(-float(facing.yaw)))*selected.target_metres_per_second
	if jumping:
		var jump_custody: Dictionary = core.actors.reserve_motion_activity(self,capability)
		if not jump_custody.ok: return jump_custody
		var launch: Dictionary = placement.commit_takeoff(self,{"session":scope,"placement_serial":body.serial,"posture":posture,"velocity":initial_velocity,"takeoff":takeoff})
		if not launch.ok:
			core.actors.release_motion_activity(self,scope,actor)
			return launch
		_platform.clear()
		var event := activity.duplicate(true)
		event.kind = "jump"
		event.operation = takeoff.id
		event.context.event = takeoff.id
		event.source = {"source":"ground-motion","cause":"jump","component":takeoff.id}
		event.clock.interval = takeoff.id
		event.clock.end_game = event.clock.start_game
		event.clock.end_sim = event.clock.start_sim
		_jump_debt = {"request":event}
		launch.gait = selected.duplicate(true)
		launch.activity = {"ok":true,"phase":"takeoff-awaiting-charge","operation":takeoff.id}
		_present_origin(launch,0.0)
		last = launch.duplicate(true)
		var paid := _settle_jump()
		launch.activity = paid.duplicate(true)
		if not paid.get("ok",false) or not core.gates.simulation(): return launch
		# The zero-time event advances CHAR revision but neither TIME cursor.
		capability = core.actors.ground_capabilities(scope,actor)
		if not capability.ok: return capability
		activity.revision = capability.revision
		body = placement.ground_context(scope)
		posture = placement.prepare_ground_posture(self,scope,desired,profile.surface)
		if not body.ok or not posture.ok: return {"ok":false,"reason":"Paid takeoff requires physical recovery."}
	var custody: Dictionary = core.actors.reserve_motion_activity(self,capability)
	if not custody.ok: return custody
	var forward := Vector3.FORWARD.rotated(Vector3.UP,deg_to_rad(-float(facing.yaw)))
	var motion: Dictionary
	var flying: bool = air_context.airborne or jumping or starting_air
	if flying:
		var flight_policy := air_policy.duplicate(true)
		if effects.slow_fall: flight_policy.maximum_downward_speed = minf(flight_policy.maximum_downward_speed,effects.slow_fall_speed/flight_policy.metres_per_reference_unit)
		motion = placement.advance_air(self,{"session":scope,"sequence":_sequence+1,"delta":delta,"forward":forward,"placement_serial":body.serial,"posture":posture,"start":{"velocity":initial_velocity,"takeoff":takeoff} if starting_air else {},"policy":flight_policy,"steering":velocity,"enhanced":effects.enhanced and capability.voluntary_allowed and restrictions.voluntary,"slow_fall":effects.slow_fall})
		if motion.ok and not placement.air.takeoff.get("gait",{}).is_empty(): selected = placement.air.takeoff.gait.duplicate(true)
	else:
		motion = placement.advance_ground(self,{"session":scope,"sequence":_sequence+1,"delta":delta,"velocity":velocity,"forward":forward,"placement_serial":body.serial,"posture":posture})
		if motion.get("handoff_pending",false):
			var inherited := _inherit_platform()
			var detached: Dictionary = placement.finish_walkoff(self,_sequence+1,{"id":"walk-off-"+str(_sequence+1),"kind":"walk-off","gait":selected.duplicate(true)},inherited)
			if not detached.ok: return detached
	if not motion.ok:
		if _pending.is_empty(): core.actors.release_motion_activity(self,scope,actor)
		return motion
	if not motion.get("landing",{}).is_empty():
		placement.air.pending.session = scope
		placement.air.pending.actor = actor
		placement.air.pending.content = _content
		motion.landing = placement.air.pending.duplicate(true)
	if jumping or starting_air: _platform.clear()
	_sequence += 1
	var moving: bool = motion.actual_metres_per_second > profile.moving_metres_per_second
	activity.context.motion.running = selected.gait == "run" and moving
	activity.context.motion.voluntary_motion = moving and not flying
	activity.context.motion.passive_motion = flying and motion.passive_displacement.length_squared() > 0.000000001
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
	_present_origin(motion,delta)
	motion.gait = selected.duplicate(true)
	motion.activity_operation = activity.operation
	motion.activity = {"ok":true,"phase":"performed-awaiting-boundary","operation":activity.operation}
	# Stage coherent physical/gait/performed results before any supplier or CHAR
	# callback can notify a scoped observer. Settlement updates follow by identity.
	last = motion.duplicate(true)
	# Capture original eligible proof even if a later owner rejects delivery.
	var captured: Variant = time_owner.capture_ground(activity.duplicate(true))
	if not _scope_current(activity.session): return _retired_result()
	if typeof(captured) != TYPE_BOOL or not captured: _stop("TIME failed to retain performed interval proof.")
	# TIME first retains the already performed eligible interval. Its proof then
	# permits CHAR settlement under the new landing continuation hold.
	if not motion.get("landing",{}).is_empty() and _landing_hold == 0: _landing_hold = core.gates.acquire("move-landing",scope,["simulation","input","save"])
	if not _after_pending.is_empty():
		var settled := _settle_one()
		if not settled.ok: return motion
	var preview: Dictionary = core.actors.preview_ground_activity(self,_pending)
	if not preview.ok: _stop("Performed ground prediction requires recovery: "+str(preview.get("reason","unavailable")))
	else: _must_settle = preview.settle or jumping or not motion.get("landing",{}).is_empty() or motion.get("contact_recovery",false)
	return motion

func vital_operation_current(request: Dictionary) -> bool:
	return request == _landing_request and request.session == scope and core.snapshot().session == scope and not placement.air.pending.is_empty()

## Supported settled in-memory owner boundary, deliberately not a native SAVE
## reconstruction API. CHAR revision and physical checkpoint prevent rewinding a
## newer consequence. Input and camera interpolation are never durable authority.
func capture_air_state() -> Dictionary:
	if _busy or not _pending.is_empty() or not _jump_debt.is_empty() or not placement.air.pending.is_empty(): return {"ok":false,"reason":"Settle required movement consequences before snapshot."}
	var body: Dictionary = placement.ground_context(scope)
	var cap: Dictionary = core.actors.vital_projection(scope,actor)
	if not body.ok or not cap.ok: return {"ok":false,"reason":"Current owner checkpoint unavailable."}
	return {"ok":true,"schema":"move-air-checkpoint-v1","session":scope,"actor":actor,"content":_content,"actor_revision":cap.revision,"sequence":_sequence,"serial":body.serial,"position":body.position,"posture":body.physical.posture,"air":placement.air.snapshot(),"jump_result":_jump_result.duplicate(true),"native_save_ready":false}

func restore_air_state(s: Dictionary) -> Dictionary:
	if _busy or core.gates.simulation() or not _pending.is_empty() or not _jump_debt.is_empty() or not placement.air.pending.is_empty() or s.size() != 13 or s.get("schema") != "move-air-checkpoint-v1" or s.get("session") != scope or s.get("actor") != actor or s.get("content") != _content or s.get("sequence") != _sequence or s.get("native_save_ready") != false or not preload("res://scripts/move/air_history.gd").valid(s.get("air")): return {"ok":false,"reason":"Gated settled current owner checkpoint required."}
	var body: Dictionary = placement.ground_context(scope)
	var cap: Dictionary = core.actors.vital_projection(scope,actor)
	if not body.ok or not cap.ok or cap.revision != s.get("actor_revision") or body.serial != s.get("serial") or body.position != s.get("position") or body.physical.posture != s.get("posture") or s.air != placement.air.snapshot() or s.get("jump_result") != _jump_result: return {"ok":false,"reason":"Changed owner/CHAR checkpoint cannot rewind motion or consequences."}
	placement.air.restore(s.air)
	input.invalidate("air owner restore")
	gait.reset(scope)
	gait.crouch_selected = body.physical.posture == "crouched"
	_view_height = NAN
	_view_base_y = NAN
	_physical_base_y = NAN
	return {"ok":true,"native_save_ready":false}

## Pull required health outcome; optional feedback observes only settled results.
## Exact retries keep the original CHAR request even if its revision has advanced.
func retry_landing() -> Dictionary:
	if _busy or not _pending.is_empty() or not _jump_debt.is_empty(): return {"ok":false,"reason":"Settle movement activity before landing health."}
	var operation_scope := scope
	var outcome: Dictionary = placement.air.pending
	if outcome.is_empty(): return {"ok":true,"unchanged":true}
	if _landing_hold == 0: _landing_hold = core.gates.acquire("move-landing",scope,["simulation","input","save"])
	_busy = true
	if outcome.phase == "resolved-distance":
		_formula_operation = {"session":scope,"landing":outcome.id,"sequence":_sequence}
		var damage: Dictionary = core.formulas.invoke("move.landing-damage",{"profile":air_policy.duplicate(true),"distance":outcome.distance},core,self,scope,_formula_operation)
		if not _scope_current(operation_scope):
			_busy = false
			return _retired_result()
		if not damage.ok:
			_busy = false
			return _stop("Landing formula failed; retained distance requires recovery.")
		outcome.damage = int(damage.value)
		outcome.hard = outcome.distance > air_policy.hard_distance
		outcome.phase = "health"
	if _landing_request.is_empty():
		var cap: Dictionary = core.actors.vital_projection(scope,actor)
		if not cap.ok:
			_busy = false
			return _stop("Landing CHAR unavailable.")
		_landing_request = {"schema":"vital-intake-v1","session":scope,"actor":actor,"caller":"move-landings","operation":outcome.id,"content":cap.content,"revision":cap.revision,"action":"damage","pool":"health","unit":"points","amount":outcome.damage,"attribution":{"source":"ground-motion","cause":"fall","component":outcome.id}}
	var result: Dictionary = core.actors.vital_intake(self,_landing_request)
	if not _scope_current(operation_scope):
		_busy = false
		return _retired_result()
	outcome.health = result.duplicate(true)
	var death: bool = result.get("schema") == "lethal-outcome-v1" and result.get("phase") == "dead"
	if not result.get("ok",false) and not death:
		_busy = false
		return _stop("Landing health remains pending: "+str(result.get("reason","owner failure")))
	if not death:
		var acknowledged: Dictionary = core.actors.acknowledge_vital(self,_landing_request)
		if not _scope_current(operation_scope):
			_busy = false
			return _retired_result()
		if not acknowledged.get("ok",false):
			_busy = false
			return _stop("Landing acknowledgment remains pending.")
	outcome.phase = "committed"
	placement.air.outcomes[outcome.id] = outcome.duplicate(true)
	placement.air.pending = {}
	_landing_request = {}
	core.gates.release(_landing_hold,"move-landing")
	_landing_hold = 0
	if _hold != 0:
		core.gates.release(_hold,"ground-continuation")
		_hold = 0
	reason = ""
	landed.emit(outcome.duplicate(true))
	_busy = false
	return {"ok":true,"outcome":outcome.duplicate(true)}

## Physical commitment precedes presentation. Smoothing uses eligible simulated
## delta only. A blocked visual path snaps; it cannot move the body or facing.
func _present_origin(motion: Dictionary, delta: float) -> void:
	var tuning: Dictionary = profile.surface
	var target_height: float = tuning.crouched_eye if motion.posture.actual == "crouched" else tuning.standing_eye
	var base_y: float = motion.base.y
	if is_nan(_view_height): _view_height = target_height
	if is_nan(_view_base_y): _view_base_y = base_y
	if is_nan(_physical_base_y): _physical_base_y = base_y
	_view_base_y += base_y-_physical_base_y-motion.get("stair_correction",0.0)
	_physical_base_y = base_y
	_view_base_y = clampf(_view_base_y,base_y-tuning.step_up,base_y+tuning.step_down)
	_view_height = move_toward(_view_height,target_height,absf(tuning.standing_eye-tuning.crouched_eye)*delta/tuning.posture_seconds)
	_view_base_y = base_y+(_view_base_y-base_y)*exp(-delta/tuning.stair_seconds)
	var safe := Vector3(motion.position.x,base_y+target_height,motion.position.z)
	var visual := Vector3(motion.position.x,_view_base_y+_view_height,motion.position.z)
	# A full enclosing-sphere route, rather than collider height, bounds the
	# temporary visual eye. Open-room crouching can therefore remain smooth.
	if not placement.ground_view_route(self,safe,visual,tuning.camera_radius):
		visual = safe
		_view_height = target_height
		_view_base_y = base_y
	motion.view_position = visual

func retire(session: String) -> void:
	if session != scope: return
	# Debt remains diagnosable on the retired coordinator; cannot enter a new scope.
	if not _pending.is_empty() or not _jump_debt.is_empty() or not placement.air.pending.is_empty(): retired_work[scope] = {"request":_pending.duplicate(true),"queued":_after_pending.duplicate(true),"captured_revisions":_captured_revisions.duplicate(),"reason":reason,"physical":last.duplicate(true),"air":placement.air.snapshot(),"jump":_jump_debt.duplicate(true),"landing_request":_landing_request.duplicate(true)}
	_pending.clear()
	_after_pending.clear()
	_captured_revisions.clear()
	_attempted = false
	_must_settle = false
	_proof.clear()
	_jump_edge.clear()
	_jump_sequence = 0
	_jump_proof.clear()
	_jump_result.clear()
	_jump_debt.clear()
	_landing_request.clear()
	_air_sources.clear()
	_air_effect_snapshot.clear()
	_platform.clear()
	_landing_hold = 0
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
	input.invalidated.disconnect(_interrupt_jump)
	core.retiring.disconnect(retire)
	placement.pose_committed.disconnect(_placed)
	for event: Signal in [committed,failed]:
		for connection: Dictionary in event.get_connections(): event.disconnect(connection.callable)
	retired_work.clear()
