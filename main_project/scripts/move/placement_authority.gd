extends Node3D
signal pose_committed(state: Dictionary)
## MOVE owns the only committed actor pose. Queries never move the actor.
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")
const Policy = preload("res://scripts/data/placement_policy.gd")
var core: RefCounted
var assembly: Node
var _actor: CharacterBody3D
var _shape: CollisionShape3D
var _actor_scope := ""
var _state := {}
var _receipts := {}
var _serial := 0
var _committing := false
var _ground_owner: WeakRef
var _ground_sequence := 0
var _ground_last: Dictionary = {}

func bind_ground(owner: RefCounted) -> bool:
	if _ground_owner != null and _ground_owner.get_ref() != null and _ground_owner.get_ref() != owner: return false
	_ground_owner = weakref(owner)
	return true

func ground_context(scope: String) -> Dictionary:
	if not is_instance_valid(_actor) or not is_instance_valid(_shape) or scope != _actor_scope or _state.get("session") != scope: return {"ok":false,"reason":"Committed MOVE body unavailable."}
	var ready: Dictionary = assembly.readiness(_state.ticket)
	if typeof(ready.get("ok")) != TYPE_BOOL or not ready.ok: return {"ok":false,"reason":"Current collision geometry unavailable."}
	return {"ok":true,"position":_actor.position,"velocity":_actor.velocity,"serial":_serial,"ticket":_state.ticket.duplicate(true),"physical":_state.physical.duplicate(true)}

## Flat-ground support observation only, never placement/clearance validation.
## The standing capsule itself is swept by move_and_collide below.
func _flat_ground(space: PhysicsDirectSpaceState3D, position: Vector3, p: Dictionary) -> bool:
	var ray := PhysicsRayQueryParameters3D.create(position,position+Vector3.DOWN*(p.height*0.5+p.support_depth))
	ray.exclude = [_actor.get_rid()]
	var hit := space.intersect_ray(ray)
	return not hit.is_empty() and hit.normal.dot(Vector3.UP) >= 0.999999 and absf(float(hit.position.y)-(_actor.position.y-p.height*0.5-p.margin*2)) < 0.0001

## Only the session coordinator may advance this existing body. This is not
## placement validation/commit and never resets camera aim or motion history.
func advance_ground(owner: RefCounted, raw: Variant) -> Dictionary:
	if _ground_owner == null or _ground_owner.get_ref() != owner or _committing: return {"ok":false,"reason":"Unbound or reentrant ground authority."}
	if not raw is Dictionary or raw.size() != 6 or typeof(raw.get("sequence")) != TYPE_INT or raw.sequence < 1 or raw.sequence > 1000000000 or raw.get("session") != _actor_scope or not raw.get("velocity") is Vector3 or not raw.velocity.is_finite() or absf(raw.velocity.y) > 0.000001 or raw.velocity.length() > 1000.000001 or not raw.get("forward") is Vector3 or not raw.forward.is_finite() or absf(raw.forward.y) > 0.000001 or absf(raw.forward.length()-1.0) > 0.000001 or not raw.get("delta") is float or not is_finite(raw.delta) or raw.delta <= 0 or raw.delta > 0.1 or typeof(raw.get("placement_serial")) != TYPE_INT or raw.placement_serial != _serial: return {"ok":false,"reason":"Malformed/stale ground step."}
	if raw.sequence == _ground_sequence: return _ground_last.result.duplicate(true) if _ground_last.get("request") == raw else {"ok":false,"reason":"Changed ground step identity."}
	if raw.sequence != _ground_sequence+1 or not core.gates.simulation(): return {"ok":false,"reason":"Out-of-order or suspended ground step."}
	var context := ground_context(raw.session)
	if not context.ok: return context
	if context.physical.get("posture") != "standing" or context.physical.get("mode") != "standing" or context.velocity.y != 0.0: return {"ok":false,"reason":"Posture/air/support owner pending; physical history preserved."}
	var p: Dictionary = _receipts[_state.handoff_id].policy
	var space := _actor.get_world_3d().direct_space_state
	if not _flat_ground(space,_actor.position,p): return {"ok":false,"reason":"Flat support owner boundary; air/surface owner pending."}
	_committing = true
	var before := _actor.position
	var remaining: Vector3 = raw.velocity*raw.delta
	var collisions := 0
	var handoff_pending := false
	for iteration in 4:
		if remaining.length_squared() < 1e-20: break
		# Sliding changes the path after the first hit. Qualify every ordered
		# fragment before moving; never let the final slide silently enter air.
		var sweep := KinematicCollision3D.new()
		var candidate: Vector3 = _actor.position+remaining
		if _actor.test_move(_actor.global_transform,remaining,sweep): candidate = _actor.position+sweep.get_travel()
		if not _flat_ground(space,candidate,p):
			if iteration == 0:
				_committing = false
				return {"ok":false,"reason":"Ground exit requires later air/surface handoff."}
			handoff_pending = true
			break # Prior fragments are performed, retained and must be accounted.
		var hit := _actor.move_and_collide(remaining)
		if hit == null: break
		collisions += 1
		remaining = hit.get_remainder().slide(hit.get_normal())
	var travel := _actor.position-before
	_actor.velocity = travel/raw.delta
	_actor.basis = Basis.looking_at(raw.forward,Vector3.UP)
	_state.position = _actor.position
	_state.forward = raw.forward
	_ground_sequence = raw.sequence
	var result := {"ok":true,"session":raw.session,"sequence":raw.sequence,"position":_actor.position,"requested_displacement":raw.velocity*raw.delta,"voluntary_displacement":travel,"passive_displacement":Vector3.ZERO,"actual_metres_per_second":travel.length()/raw.delta,"collisions":collisions,"placement_serial":_serial,"handoff_pending":handoff_pending,"unsupported_remainder":remaining if handoff_pending else Vector3.ZERO}
	_ground_last = {"request":raw.duplicate(true),"result":result.duplicate(true)}
	# Coordinator publishes combined gait/activity before notifying observers.
	_committing = false
	return result

func snapshot() -> Dictionary:
	return _state.duplicate(true)

func placement_ready(layout_ticket: Dictionary, session: String) -> bool:
	if not is_instance_valid(_actor) or _state.get("ticket") != layout_ticket or _state.get("session") != session: return false
	var value: Dictionary = assembly.marker_candidate(layout_ticket,_state.route,0)
	if value.get("handoff_id") != _state.handoff_id: return false
	var receipt: Dictionary = _receipts[_state.handoff_id]
	var checked := validate(value,receipt.physical,receipt.policy)
	return checked.get("kind") in ["exact","corrected"] and checked.position == _state.position

func _current(value: Dictionary) -> bool:
	if assembly == null or core == null or not value.get("route_intent_bound",false): return false
	if not value.get("ticket") is Dictionary or not value.get("route") is String or not value.get("handoff_id") is String: return false
	return assembly.marker_candidate(value.ticket,value.route,0) == value

func _result(value: Dictionary, reason: String) -> Dictionary:
	return {"kind":"rejected","reason":reason,"handoff_id":value.get("handoff_id",""),"marker":value.marker.duplicate(true) if value.get("marker") is Dictionary else {},"frame":value.get("frame","")}

## A replaceable resolved policy is captured per query, never read during commit.
## Dimensions are metres; offsets are in doorway-inward/right/up coordinates.
func baseline_policy() -> Dictionary:
	return Policy.resolved(Policy.baseline())

func policy_valid(p: Dictionary) -> bool:
	return Policy.reason(p).is_empty()

func _capsule(p: Dictionary) -> CapsuleShape3D:
	var shape := CapsuleShape3D.new()
	shape.radius = p.radius
	shape.height = p.height
	return shape

func _query(shape: Shape3D, position: Vector3, margin: float) -> PhysicsShapeQueryParameters3D:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY,position)
	query.margin = margin
	query.collision_mask = 0xffffffff
	if is_instance_valid(_actor): query.exclude = [_actor.get_rid()]
	return query

func _volume(space: PhysicsDirectSpaceState3D, shape: Shape3D, position: Vector3, p: Dictionary) -> bool:
	return space.intersect_shape(_query(shape,position,p.margin),1).is_empty()

func _support(space: PhysicsDirectSpaceState3D, shape: Shape3D, position: Vector3, p: Dictionary) -> Dictionary:
	var q := _query(shape,position,p.margin)
	q.motion = Vector3.DOWN*p.support_depth
	var fractions := space.cast_motion(q)
	if fractions.size() != 2 or fractions[0] >= 1.0: return {"ok":false,"reason":"missing_ground"}
	q.transform.origin += q.motion*fractions[1]
	q.motion = Vector3.ZERO
	var contact := space.get_rest_info(q)
	if contact.is_empty(): return {"ok":false,"reason":"missing_ground_contact"}
	if contact.normal.dot(Vector3.UP) < cos(deg_to_rad(p.max_slope_degrees)): return {"ok":false,"reason":"unsupported_slope"}
	return {"ok":true,"normal":contact.normal,"distance":p.support_depth*fractions[0]}

func _side(value: Dictionary, position: Vector3, radius: float) -> bool:
	# Preserve the entire shape on the declared side of the bound door plane.
	var door: Dictionary = value.exit if value.desired_context.doorway_side == "interior" else value.entrance
	var normal: Vector3 = door.normal
	return (position-door.position).dot(normal) >= radius

## Conservative correction route: full-shape sweep from a clear exact pose.
## An initially overlapping volume cannot be certified as an escape corridor.
func _route(space: PhysicsDirectSpaceState3D, shape: Shape3D, start: Vector3, target: Vector3, p: Dictionary) -> bool:
	if not _volume(space,shape,start,p): return false
	var q := _query(shape,start,p.margin)
	q.motion = target-start
	var fractions := space.cast_motion(q)
	return fractions.size() == 2 and fractions[0] >= 1.0

func validate(value: Dictionary, physical: Dictionary, policy: Dictionary = {}) -> Dictionary:
	var failed := _result(value,"stale")
	if not _current(value): return failed
	if not value.ticket.request.core_ticket.is_empty() and not core.require_placement(value.ticket.request.core_ticket,value.ticket): return _result(value,"placement_operation_conflict")
	if value.get("frame") != Frame.FRAME or not value.has("desired_context") or not value.has("exit"): return _result(value,"unsupported_context")
	if not value.forward.is_finite() or absf(value.forward.length()-1.0) > 0.000001 or absf(value.forward.y) > 0.000001: return _result(value,"unsupported_facing")
	# Missing advanced owners never turn saved/falling/effect state into standing.
	if physical != {"intent":"doorway","mode":"standing","transport":"foot","effects":[],"fall_history":{},"velocity":Vector3.ZERO,"posture":"standing"}: return _result(value,"physical_owner_unavailable")
	var p: Dictionary = Policy.resolved(value.get("placement_policy",{}) if policy.is_empty() else policy)
	if not policy_valid(p): return _result(value,"invalid_policy")
	var space: PhysicsDirectSpaceState3D = assembly.placement_space(value.ticket)
	if space == null: return _result(value,"physics_unavailable")
	var shape := _capsule(p)
	# Source marker is a sole anchor. Exterior anchors are door-centre-height;
	# recover their explicitly declared floor reference before adding half-height.
	var sole: Vector3 = value.position
	if value.pose_kind == "authored-doorway-anchor":
		var floor_height := INF
		for point: Vector3 in value.entrance.points: floor_height = minf(floor_height,point.y)
		sole.y = floor_height
	var normal: Vector3 = value.exit.normal if value.desired_context.doorway_side == "interior" else value.entrance.normal
	if absf(normal.y) > 0.000001: return _result(value,"unsupported_door_orientation")
	var right := normal.cross(Vector3.UP).normalized()
	if right.length() < 0.99: return _result(value,"unsupported_door_orientation")
	var anchor_adjustment := Vector3.ZERO
	if p.anchor_mode == "door-aperture-clearance":
		var door: Dictionary = value.exit if value.desired_context.doorway_side == "interior" else value.entrance
		var low := INF
		var high := -INF
		for point: Vector3 in door.points:
			low = minf(low,point.dot(right))
			high = maxf(high,point.dot(right))
		var clearance: float = p.radius+p.margin*2
		if high-low < clearance*2: return _result(value,"aperture_too_narrow")
		anchor_adjustment = right*(clampf(sole.dot(right),low+clearance,high-clearance)-sole.dot(right))
		if anchor_adjustment.length() > p.max_distance: return _result(value,"anchor_conversion_bound")
		sole += anchor_adjustment
	var exact: Vector3 = sole+Vector3.UP*(p.height*0.5+p.margin*2)
	var candidates: Array[Vector3] = [exact]
	for offset: Vector3 in p.offsets: candidates.append(exact+right*offset.x+normal*offset.y+Vector3.UP*offset.z)
	var attempts: Array = []
	for index in candidates.size():
		var position := candidates[index]
		var reason := ""
		if not Frame.bounded(position): reason = "coordinate_extent"
		elif not _side(value,position,p.radius+p.margin): reason = "doorway_side"
		elif not _volume(space,shape,position,p): reason = "shape_overlap"
		elif index > 0 and not _route(space,shape,exact,position,p): reason = "blocked_route"
		var support := {}
		if reason.is_empty():
			support = _support(space,shape,position,p)
			if not support.ok: reason = support.reason
		attempts.append({"index":index,"position":position,"reason":reason})
		if not reason.is_empty(): continue
		if not _current(value): return failed
		return {"kind":"exact" if index == 0 else "corrected","handoff_id":value.handoff_id,"marker":value.marker.duplicate(true),"frame":Frame.FRAME,"position":position,"forward":value.forward,"physical":physical.duplicate(true),"policy":p,"attempts":attempts,"support":support,"anchor":value.position,"conversion":{"id":"sole-anchor-to-capsule-centre-v1","aperture_adjustment":anchor_adjustment,"half_height":p.height*0.5,"sole_margin":p.margin*2},"provenance":{"policy":p.id,"candidate":index,"displacement":position-exact,"attempts":attempts.duplicate(true)},"placement_committed":false}
	failed.reason = "candidate_budget_exhausted"
	failed.attempts = attempts
	return failed

## Commitment requires an activated receipt, fresh physics and a final access
## check. Validation-only callbacks are never allowed to publish physical state.
func commit(value: Dictionary, checked: Dictionary, access: Callable) -> Dictionary:
	if _committing: return _result(value,"commit_in_progress")
	_committing = true
	var result := _commit(value,checked,access)
	_committing = false
	return result

func _commit(value: Dictionary, checked: Dictionary, access: Callable) -> Dictionary:
	if not _current(value) or str(value.get("activation_session","")).is_empty(): return _result(value,"activation_pending_or_stale")
	if not core.layout_operation_owns(value.ticket.request.core_ticket): return _result(value,"original_operation_required")
	var key: String = value.handoff_id
	if checked.get("handoff_id") != key or checked.get("kind") not in ["exact","corrected"] or not checked.get("position") is Vector3: return _result(value,"invalid_validation")
	if _receipts.has(key):
		var receipt: Dictionary = _receipts[key]
		for field in ["kind","position","policy","physical"]:
			if checked.get(field) != receipt.get(field): return _result(value,"identity_reused_with_changed_placement")
		return receipt.duplicate(true)
	if not access.is_valid(): return _result(value,"access_provider_unavailable")
	# Tree notifications can reenter CORE. Allocate a dormant body before the
	# final callback/scope/physics checks, never inside the publication section.
	if not is_instance_valid(_actor):
		_actor = CharacterBody3D.new()
		_actor_scope = value.activation_session
		_actor.name = "PlacementActor"
		_actor.collision_mask = 0xffffffff
		_shape = CollisionShape3D.new()
		_actor.add_child(_shape)
		add_child(_actor)
	if not _current(value): return _result(value,"stale")
	var allowed: Variant = access.call(value.duplicate(true))
	if not _current(value): return _result(value,"stale")
	if not allowed is Dictionary or not allowed.get("ok",false) or allowed.get("handoff_id") != key: return _result(value,"access_rejected")
	var fresh := validate(value,checked.get("physical",{}),checked.get("policy",{}))
	if fresh.get("kind") not in ["exact","corrected"] or fresh.position != checked.position: return _result(value,"physical_state_changed")
	if not _current(value) or not is_instance_valid(_actor): return _result(value,"stale")
	_shape.shape = _capsule(fresh.policy)
	_actor.position = fresh.position
	_actor.velocity = Vector3.ZERO
	_actor.basis = Basis.looking_at(fresh.forward,Vector3.UP)
	_serial += 1
	_ground_sequence = 0
	_ground_last.clear()
	_state = {"serial":_serial,"session":value.activation_session,"ticket":value.ticket.duplicate(true),"handoff_id":key,"position":fresh.position,"forward":fresh.forward,"shape":{"radius":fresh.policy.radius,"height":fresh.policy.height},"physical":fresh.physical.duplicate(true),"desired_context":value.desired_context.duplicate(true),"entrance":value.entrance.duplicate(true),"exit":value.exit.duplicate(true),"return":value["return"].duplicate(true),"marker":value.marker.duplicate(true),"camera_reset_serial":_serial,"placement_committed":true,"destination_ready":false}
	_state.route = value.route
	fresh.placement_committed = true
	fresh.commit_serial = _serial
	_receipts[key] = fresh.duplicate(true)
	pose_committed.emit(_state.duplicate(true))
	return fresh

func retire_scope(scope: String) -> void:
	if _actor_scope != scope: return
	if is_instance_valid(_actor): _actor.free()
	_actor = null
	_shape = null
	_actor_scope = ""
	_state.clear()
	_receipts.clear()
	_ground_sequence = 0
	_ground_last.clear()
