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
var air := preload("res://scripts/move/air_history.gd").new()
var _takeoff_sequence := 0
var _takeoff_receipt: Dictionary = {}

## Zero-time physical event. CHAR settles this retained actual takeoff before
## any eligible flight duration is advanced. This is not a second body/controller.
func commit_takeoff(owner: RefCounted, raw: Dictionary) -> Dictionary:
	if _ground_owner == null or _ground_owner.get_ref() != owner or _committing or raw.size() != 5 or raw.get("session") != _actor_scope or raw.get("placement_serial") != _serial or not raw.get("posture") is Dictionary or not raw.get("takeoff") is Dictionary or not raw.get("velocity") is Vector3 or not raw.velocity.is_finite() or raw.velocity.length() > 2000.0: return {"ok":false,"reason":"Current checked takeoff required."}
	var event: Variant = raw.takeoff.get("event_sequence")
	if typeof(event) != TYPE_INT or event < 1 or event > 1000000000: return {"ok":false,"reason":"Bounded takeoff identity required."}
	if raw.takeoff.size() != 6 or raw.takeoff.get("id") != "jump-"+str(event) or raw.takeoff.get("kind") != "jump" or not raw.takeoff.get("gait") is Dictionary or not preload("res://scripts/rule/air_formulas.gd").valid_input("move.jump-impulse",raw.takeoff.get("snapshot")) or not raw.takeoff.get("impulse") is float or not is_finite(raw.takeoff.impulse) or raw.takeoff.impulse <= 0.0 or raw.takeoff.impulse > 100.0: return {"ok":false,"reason":"Complete bounded takeoff snapshot required."}
	if event == _takeoff_sequence: return _takeoff_receipt.result.duplicate(true) if _takeoff_receipt.get("request") == raw else {"ok":false,"reason":"Changed takeoff identity."}
	if event < _takeoff_sequence or air.airborne or not air.pending.is_empty() or not core.gates.simulation() or air.segment >= 1000000000 or air.outcomes.size() >= 4096: return {"ok":false,"reason":"Takeoff unavailable or already committed."}
	var checked := prepare_ground_posture(owner,raw.session,raw.posture.get("desired",""),raw.posture.get("tuning",{}))
	if not checked.get("ok",false) or checked != raw.posture: return {"ok":false,"reason":"Takeoff posture changed."}
	var context := air_context(owner,raw.session,checked.tuning)
	if not context.ok or not context.supported or context.physical.mode != "standing" or context.physical.transport != "foot": return {"ok":false,"reason":"Actual ordinary foot support required at takeoff."}
	_committing = true
	var p: Dictionary = _receipts[_state.handoff_id].policy.duplicate()
	if _shape.shape.height != checked.height:
		p.height = checked.height
		_shape.shape = _capsule(p)
		_actor.position = checked.position
	_state.physical.posture = checked.actual
	_state.desired_posture = checked.desired
	_state.pending_stand = checked.pending_stand
	_state.shape.height = checked.height
	air.begin(_actor.position.y-checked.height*0.5,raw.velocity,raw.takeoff)
	_actor.velocity = raw.velocity
	_publish_air()
	_takeoff_sequence = event
	var result := {"ok":true,"takeoff_committed":true,"session":raw.session,"position":_actor.position,"base":_actor.position-Vector3.UP*checked.height*0.5,"posture":checked.duplicate(true),"airborne":true,"velocity":air.velocity,"stair_correction":0.0,"actual_metres_per_second":0.0}
	_takeoff_receipt = {"request":raw.duplicate(true),"result":result.duplicate(true)}
	_committing = false
	return result

## Same MOVE body and sequence as surface travel. Queries do not commit takeoff.
func air_context(owner: RefCounted, scope: String, tuning: Dictionary) -> Dictionary:
	if _ground_owner == null or _ground_owner.get_ref() != owner or _committing: return {"ok":false,"reason":"Unbound air context."}
	var context := ground_context(scope)
	if not context.ok: return context
	var p: Dictionary = _receipts[_state.handoff_id].policy.duplicate()
	p.margin = tuning.motion_margin
	var support := _ground_support(_actor.get_world_3d().direct_space_state,_actor.position,p,tuning,tuning.contact_gap*3,float(_ground_last.get("result",{}).get("support_hint_ny",1.0))) if not air.airborne else {"ok":false}
	context.supported = support.ok
	context.support_collider = support.get("collider",0)
	context.base = _actor.position-Vector3.UP*_shape.shape.height*0.5
	context.airborne = air.airborne
	return context

func _publish_air() -> void:
	_state.position = _actor.position
	_state.physical.velocity = _actor.velocity
	_state.physical.mode = "airborne" if air.airborne else "standing"
	_state.physical.fall_history = {"segment":air.segment,"peak":air.peak,"origin_y":air.origin_y,"protected":air.protections.keys()} if air.airborne else {}

func _air_slide(vector: Vector3, normal: Vector3, planes: Array[Vector3]) -> Vector3:
	var result := vector.slide(normal)
	for plane: Vector3 in planes:
		if result.dot(plane) >= -0.00000001: continue
		# A second witnessed plane must not project motion back into the first.
		# Their shared crease preserves free motion (vertical at a wall pinch).
		var crease := normal.cross(plane)
		if crease.length_squared() < 1e-12: return Vector3.ZERO
		result = crease*(vector.dot(crease)/crease.length_squared())
		for previous: Vector3 in planes:
			if result.dot(previous) < -0.00000001: return Vector3.ZERO
	return result

func _air_sweep(displacement: Vector3, p: Dictionary) -> Dictionary:
	var space := _actor.get_world_3d().direct_space_state
	var start := _actor.position
	var hit := KinematicCollision3D.new()
	var blocked := _actor.test_move(_actor.global_transform,displacement,hit,p.margin*2.0)
	var travel := hit.get_travel() if blocked else displacement
	var normal := hit.get_normal() if blocked and hit.get_collision_count() > 0 else Vector3.ZERO
	var q := _query(_shape.shape,start,p.margin)
	q.motion = displacement
	var fractions := space.cast_motion(q)
	if fractions.size() == 2 and fractions[0] < 1.0:
		blocked = true
		if displacement.length()*fractions[0] < travel.length(): travel = displacement*fractions[0]
		q.transform.origin += displacement*fractions[1]
		q.motion = Vector3.ZERO
		var contact := space.get_rest_info(q)
		if not contact.is_empty(): normal = contact.normal
	if not blocked and not _volume(space,_shape.shape,start+displacement,p):
		blocked = true
		q = _query(_shape.shape,start+displacement,p.margin)
		var endpoint_contact := space.get_rest_info(q)
		if not endpoint_contact.is_empty(): normal = endpoint_contact.normal
	if blocked and normal.length_squared() < 0.5:
		# A short cast can miss contact tolerance. Obtain a real normal from a
		# longer read-only witness, never extend the committed displacement.
		var witness := KinematicCollision3D.new()
		if _actor.test_move(_actor.global_transform,displacement.normalized()*(displacement.length()+p.margin*8.0),witness,p.margin*2.0) and witness.get_collision_count() > 0: normal = witness.get_normal()
		if not normal.is_finite() or normal.length_squared() < 0.5: return {"hit":true,"normal":Vector3.ZERO,"remainder":Vector3.ZERO,"recovery":true}
	if not blocked:
		_actor.position += displacement
		return {"hit":false}
	var backoff := minf(travel.length(),p.margin*2.0/maxf(0.000001,-displacement.normalized().dot(normal)))
	travel -= displacement.normalized()*backoff
	var target := start+travel
	if not _clear_route(space,start,target,p):
		var low := 0.0
		var high := 1.0
		for index in 16:
			var mid := (low+high)*0.5
			if _clear_route(space,start,start+travel*mid,p): low = mid
			else: high = mid
		target = start+travel*low
	_actor.position = target
	return {"hit":true,"normal":normal,"remainder":displacement-(_actor.position-start)}

## A start is an already checked once-only takeoff, never an input callback.
func advance_air(owner: RefCounted, raw: Dictionary) -> Dictionary:
	if _ground_owner == null or _ground_owner.get_ref() != owner or _committing: return {"ok":false,"reason":"Unbound/reentrant air authority."}
	if raw.size() != 11 or typeof(raw.get("slow_fall")) != TYPE_BOOL or raw.get("session") != _actor_scope or typeof(raw.get("sequence")) != TYPE_INT or raw.get("placement_serial") != _serial or not raw.get("posture") is Dictionary or not raw.get("start") is Dictionary or not raw.get("policy") is Dictionary or not raw.get("steering") is Vector3 or not raw.steering.is_finite() or raw.steering.length() > 1000.00001 or typeof(raw.get("enhanced")) != TYPE_BOOL or not raw.get("forward") is Vector3 or not raw.forward.is_finite() or absf(raw.forward.length()-1.0) > 0.000001 or absf(raw.forward.y) > 0.000001 or not raw.get("delta") is float or not is_finite(raw.delta) or raw.delta <= 0.0 or raw.delta > 0.1: return {"ok":false,"reason":"Malformed air step."}
	if raw.sequence == _ground_sequence: return _ground_last.result.duplicate(true) if raw == _ground_last.request else {"ok":false,"reason":"Changed air step identity."}
	if raw.sequence != _ground_sequence+1 or not core.gates.simulation() or not preload("res://scripts/data/air_policy.gd").reason(raw.policy).is_empty(): return {"ok":false,"reason":"Stale/suspended/invalid air step."}
	var checked := prepare_ground_posture(owner,raw.session,raw.posture.get("desired",""),raw.posture.get("tuning",{}))
	if not checked.get("ok",false) or checked != raw.posture or not air.pending.is_empty(): return {"ok":false,"reason":"Air posture changed or landing awaits settlement."}
	if not raw.start.is_empty():
		if air.airborne or raw.start.size() != 2 or not raw.start.get("velocity") is Vector3 or not raw.start.velocity.is_finite() or raw.start.velocity.length() > 2000.0 or not raw.start.get("takeoff") is Dictionary: return {"ok":false,"reason":"Invalid/repeated takeoff."}
		var departure := air_context(owner,raw.session,checked.tuning)
		if not departure.ok or departure.supported or departure.physical.transport != "foot" or raw.start.takeoff.get("kind") != "walk-off": return {"ok":false,"reason":"Actual unsupported foot departure required."}
	elif not air.airborne: return {"ok":false,"reason":"No active air segment."}
	if air.outcomes.size() >= 4096 or air.segment >= 1000000000: return {"ok":false,"reason":"Air outcome retention exhausted."}
	_committing = true
	var p: Dictionary = _receipts[_state.handoff_id].policy.duplicate()
	p.margin = checked.tuning.motion_margin
	if _shape.shape.height != checked.height:
		var dimensions := p.duplicate()
		dimensions.height = checked.height
		_shape.shape = _capsule(dimensions)
		_actor.position = checked.position
	_state.physical.posture = checked.actual
	_state.desired_posture = checked.desired
	_state.pending_stand = checked.pending_stand
	_state.shape.height = checked.height
	var start: Vector3 = _actor.position
	if not raw.start.is_empty(): air.begin(start.y-checked.height*0.5,raw.start.velocity,raw.start.takeoff)
	air.protection("@effect/slow-fall",raw.slow_fall,start.y-checked.height*0.5)
	var steering_limit: float = raw.policy.steering_speed*raw.policy.metres_per_reference_unit
	var steering_acceleration: float = raw.policy.steering_acceleration*raw.policy.metres_per_reference_unit
	var gravity: float = raw.policy.gravity*raw.policy.metres_per_reference_unit
	var terminal: float = raw.policy.maximum_downward_speed*raw.policy.metres_per_reference_unit
	air.velocity.y = maxf(air.velocity.y,-terminal)
	# Integrate at <= 1/240 s, splitting exactly at apex and terminal speed. Full
	# capsule sweeps constrain every fragment; no endpoint-only teleport is used.
	var remaining: float = raw.delta
	var ceilings := 0
	var collisions := 0
	var landed := false
	var contact_recovery := false
	while remaining > 0.00000001:
		var dt := minf(remaining,1.0/240.0)
		var horizontal := Vector3(air.velocity.x,0,air.velocity.z)
		var steered := horizontal
		var steering_target: Vector3 = raw.steering.limit_length(steering_limit)
		var can_steer: bool = raw.enhanced and horizontal.length() <= steering_limit+0.000001
		if can_steer and horizontal.distance_to(steering_target) > 0.000000001: dt = minf(dt,horizontal.distance_to(steering_target)/steering_acceleration)
		if air.velocity.y > 0.0: dt = minf(dt,air.velocity.y/gravity)
		elif air.velocity.y > -terminal: dt = minf(dt,(air.velocity.y+terminal)/gravity)
		if dt < 0.000000001: dt = minf(remaining,1.0/240.0)
		# Above the voluntary limit retain inherited momentum without pumping or
		# deleting it. Within the limit integrate bounded steering over swept time.
		if can_steer: steered = horizontal.move_toward(steering_target,steering_acceleration*dt).limit_length(steering_limit)
		var next_y: float = maxf(-terminal,air.velocity.y-gravity*dt)
		var displacement := Vector3((horizontal.x+steered.x)*0.5,(air.velocity.y+next_y)*0.5,(horizontal.z+steered.z)*0.5)*dt
		air.velocity.x = steered.x
		air.velocity.z = steered.z
		air.velocity.y = next_y
		var residual := displacement
		var contact_planes: Array[Vector3] = []
		for slide in 4:
			if residual.length_squared() < 1e-18: break
			var hit := _air_sweep(residual,p)
			if not hit.hit: break
			if hit.get("recovery",false):
				contact_recovery = true
				remaining = 0.0
				break
			collisions += 1
			var normal: Vector3 = hit.normal
			if normal.y < -0.01 and air.velocity.y > 0.0:
				air.velocity.y = 0.0
				ceilings += 1
			if normal.y >= cos(deg_to_rad(checked.tuning.support_degrees)) and displacement.y <= 0.0:
				var support := _ground_support(_actor.get_world_3d().direct_space_state,_actor.position,p,checked.tuning,checked.tuning.contact_gap*3)
				if support.ok:
					landed = true
					break
			residual = _air_slide(hit.remainder,normal,contact_planes)
			# Collisions can constrain retained momentum, but input cannot replace it.
			var previous_y: float = air.velocity.y
			air.velocity = _air_slide(air.velocity,normal,contact_planes)
			air.velocity.y = minf(previous_y,air.velocity.y)
			if normal.y < -0.01: air.velocity.y = minf(0.0,air.velocity.y)
			contact_planes.append(normal)
		air.observe(_actor.position.y-checked.height*0.5)
		remaining -= dt
		if landed: break
	var landing := air.land(_actor.position.y-checked.height*0.5,raw.policy.metres_per_reference_unit) if landed else {}
	_actor.velocity = air.velocity
	_actor.basis = Basis.looking_at(raw.forward,Vector3.UP)
	_state.forward = raw.forward
	_publish_air()
	_ground_sequence = raw.sequence
	var travel := _actor.position-start
	var result := {"ok":true,"session":raw.session,"sequence":raw.sequence,"position":_actor.position,"base":_actor.position-Vector3.UP*checked.height*0.5,"posture":checked.duplicate(true),"requested_displacement":displacement_for_report(raw.delta),"voluntary_displacement":Vector3.ZERO,"passive_displacement":travel,"actual_metres_per_second":0.0,"surface_distance":0.0,"stair_correction":0.0,"collisions":collisions,"ceilings":ceilings,"steps":0,"placement_serial":_serial,"handoff_pending":false,"airborne":air.airborne,"velocity":air.velocity,"landing":landing}
	result.contact_recovery = contact_recovery
	_ground_last = {"request":raw.duplicate(true),"result":result.duplicate(true)}
	_committing = false
	return result

func displacement_for_report(delta: float) -> Vector3:
	return air.velocity*delta

func finish_walkoff(owner: RefCounted, sequence: int, takeoff: Dictionary, inherited: Vector3) -> Dictionary:
	if _ground_owner == null or _ground_owner.get_ref() != owner or _committing or sequence != _ground_sequence or not air.airborne or air.takeoff.get("kind") != "walk-off" or air.takeoff.has("inherited") or not inherited.is_finite() or inherited.length() > 1000.0: return {"ok":false,"reason":"Current once-only walk-off inheritance required."}
	air.takeoff = takeoff.duplicate(true)
	air.takeoff.inherited = inherited
	air.velocity += inherited
	_actor.velocity = air.velocity
	_publish_air()
	return {"ok":true}

## A coordinate rebase is not swept travel. The external owner must already have
## rebased geometry; the destination capsule must be clear. Absolute peak stays.
func rebase_air(owner: RefCounted, scope: String, delta: Vector3) -> Dictionary:
	if _ground_owner == null or _ground_owner.get_ref() != owner or _committing or core.gates.simulation() or scope != _actor_scope or not delta.is_finite() or delta.length() > 8192.0: return {"ok":false,"reason":"Gated current finite origin shift required."}
	var context := ground_context(scope)
	if not context.ok: return context
	var p: Dictionary = _receipts[_state.handoff_id].policy.duplicate()
	if not _volume(_actor.get_world_3d().direct_space_state,_shape.shape,_actor.position+delta,p): return {"ok":false,"reason":"Rebased collision capsule unavailable."}
	_actor.position += delta
	air.origin_y -= delta.y
	_serial += 1
	_state.serial = _serial
	_publish_air()
	return {"ok":true,"serial":_serial}

func bind_ground(owner: RefCounted) -> bool:
	if _ground_owner != null and _ground_owner.get_ref() != null and _ground_owner.get_ref() != owner: return false
	_ground_owner = weakref(owner)
	return true

func ground_context(scope: String) -> Dictionary:
	if not is_instance_valid(_actor) or not is_instance_valid(_shape) or scope != _actor_scope or _state.get("session") != scope: return {"ok":false,"reason":"Committed MOVE body unavailable."}
	var ready: Dictionary = assembly.readiness(_state.ticket)
	if typeof(ready.get("ok")) != TYPE_BOOL or not ready.ok: return {"ok":false,"reason":"Current collision geometry unavailable."}
	return {"ok":true,"position":_actor.position,"velocity":_actor.velocity,"serial":_serial,"ticket":_state.ticket.duplicate(true),"physical":_state.physical.duplicate(true)}

## Detached posture preparation, revalidated after all external preflight callbacks.
## The existing placement capsule supplies standing dimensions. No pose is changed.
func prepare_ground_posture(owner: RefCounted, scope: String, desired: String, tuning: Dictionary, mechanism: Dictionary = {}) -> Dictionary:
	if _ground_owner == null or _ground_owner.get_ref() != owner or _committing or desired not in ["standing","crouched"]: return {"ok":false,"reason":"Unbound/reentrant posture request."}
	var context := ground_context(scope)
	if not context.ok: return context
	if not preload("res://scripts/data/ground_policy.gd").surface_reason(tuning).is_empty(): return {"ok":false,"reason":"Invalid surface tuning."}
	var standing: Dictionary = _receipts[_state.handoff_id].policy.duplicate()
	standing.margin = tuning.motion_margin
	if tuning.camera_radius >= standing.radius or tuning.crouch_height < standing.radius*2 or tuning.crouch_height >= standing.height or tuning.standing_eye+tuning.camera_radius >= standing.height or tuning.crouched_eye+tuning.camera_radius >= tuning.crouch_height: return {"ok":false,"reason":"Posture tuning incompatible with placement dimensions."}
	var space := _actor.get_world_3d().direct_space_state
	if not _volume(space,_shape.shape,_actor.position,standing): return {"ok":false,"reason":"Initial capsule overlap requires placement recovery."}
	if not mechanism.is_empty(): return preload("res://scripts/move/mechanism_collision.gd").prepare(self,mechanism,desired,tuning)
	var base: Vector3 = _actor.position-Vector3.UP*_shape.shape.height*0.5
	var target := standing.duplicate()
	target.height = tuning.crouch_height if desired == "crouched" else standing.height
	var actual := desired
	var center: Vector3 = base+Vector3.UP*target.height*0.5
	if not _volume(space,_capsule(target),center,standing):
		if desired != "standing" or _state.physical.posture != "crouched": return {"ok":false,"reason":"Intended posture volume obstructed."}
		actual = "crouched"
		target.height = _shape.shape.height
		center = _actor.position
	return {"ok":true,"session":scope,"serial":_serial,"from":_actor.position,"from_height":_shape.shape.height,"position":center,"height":target.height,"actual":actual,"desired":desired,"pending_stand":desired == "standing" and actual == "crouched","tuning":tuning.duplicate(true)}

## A full capsule sweep establishes contact; a centre support ray additionally
## prevents the capsule rim from bridging a gap. Walkability is separate from support.
func _connector(hit: Dictionary) -> bool:
	return assembly != null and assembly.has_method("ground_surface") and assembly.ground_surface(_state.ticket,hit)

func _connector_contact(space: PhysicsDirectSpaceState3D, point: Vector3, normal: Vector3) -> bool:
	var ray := PhysicsRayQueryParameters3D.create(point+normal*0.03,point-normal*0.03)
	ray.exclude = [_actor.get_rid()]
	var hit := space.intersect_ray(ray)
	return not hit.is_empty() and _connector(hit)

func _wall_bounded_floor(space: PhysicsDirectSpaceState3D, position: Vector3, offset: Vector3, depth: float, p: Dictionary, tuning: Dictionary) -> Dictionary:
	# Some source treads end just short of their enclosing wall. A footprint
	# ray in that seam is not an open ledge: require the actual blocking wall
	# near the capsule boundary, then observe a real floor inside it. Full-body
	# clearance and the centre/remaining footprint checks are unchanged.
	var wall_reach: float = _shape.shape.radius+maxf(_shape.shape.radius*0.25,tuning.contact_gap+p.margin*2.0)
	var wall_ray := PhysicsRayQueryParameters3D.create(position,position+offset*wall_reach)
	wall_ray.exclude = [_actor.get_rid()]
	var wall := space.intersect_ray(wall_ray)
	if wall.is_empty() or absf(wall.normal.y) > 0.01 or wall.normal.dot(offset) > -0.9: return {}
	var inside: Vector3 = wall.position+wall.normal*_shape.shape.radius*0.5
	inside.y = position.y
	var floor_ray := PhysicsRayQueryParameters3D.create(inside,inside+Vector3.DOWN*depth)
	floor_ray.exclude = [_actor.get_rid()]
	var floor_hit := space.intersect_ray(floor_ray)
	return floor_hit if not floor_hit.is_empty() and floor_hit.normal.y >= cos(deg_to_rad(tuning.support_degrees)) else {}

func _ground_support(space: PhysicsDirectSpaceState3D, position: Vector3, p: Dictionary, tuning: Dictionary, depth: float, support_hint_ny := 1.0) -> Dictionary:
	var query := _query(_shape.shape,position,p.margin)
	query.motion = Vector3.DOWN*depth
	var fractions := space.cast_motion(query)
	if fractions.size() != 2 or fractions[0] >= 1.0: return {"ok":false,"reason":"capsule_support_cast_missing"}
	query.transform.origin += query.motion*fractions[1]
	query.motion = Vector3.ZERO
	var contact := space.get_rest_info(query)
	if contact.is_empty():
		# The cast's unsafe endpoint can still fall just outside Jolt's contact
		# reporting tolerance at a finite triangle lip. This is an observation
		# only; no actor displacement or clearance relaxation is performed.
		query.transform.origin += Vector3.DOWN*p.margin*2.0
		contact = space.get_rest_info(query)
	# A concave stair edge may report its vertical triangle's normal even
	# though the actual contact is on the capsule's lower hemisphere. Certify
	# that geometry from the measured contact point; a cylinder-side contact
	# has no upward component and cannot supply ground support this way.
	var cap_contact_support := false
	if not contact.is_empty() and contact.normal.y < cos(deg_to_rad(tuning.support_degrees)):
		var cap_centre: Vector3 = query.transform.origin-Vector3.UP*(_shape.shape.height*0.5-_shape.shape.radius)
		var cap_delta: Vector3 = cap_centre-contact.point
		# The terrain angle is checked by the centre/footprint floor rays. A
		# rounded cap can touch a valid stair edge almost horizontally; its
		# contact-vector angle is not the terrain's slope. Require a genuine
		# lower-hemisphere point outside the margin-sized equatorial band.
		cap_contact_support = cap_delta.y > p.margin*2.0 and absf(cap_delta.length()-_shape.shape.radius) <= p.margin*3.0
		if cap_contact_support:
			# Confirm an upward tread at that finite edge. A near-tangent wall
			# point alone cannot become support just because its contact is noisy.
			var inward: Vector3 = Vector3(-cap_delta.x,0,-cap_delta.z).normalized()*p.margin*2.0
			var witness := PhysicsRayQueryParameters3D.create(contact.point+inward+Vector3.UP*tuning.contact_gap,contact.point+inward+Vector3.DOWN*tuning.contact_gap)
			witness.exclude = [_actor.get_rid()]
			var floor_witness := space.intersect_ray(witness)
			cap_contact_support = not floor_witness.is_empty() and floor_witness.normal.y >= cos(deg_to_rad(tuning.support_degrees))
	var physical_contact: bool = not contact.is_empty() and contact.normal.y < 0.99999 and contact.normal.y >= cos(deg_to_rad(tuning.support_degrees))
	var contact_connector: bool = physical_contact and _connector_contact(space,contact.point,contact.normal)
	var ray_depth: float = _shape.shape.height+depth
	if support_hint_ny >= cos(deg_to_rad(tuning.support_degrees)) and support_hint_ny < 1.0:
		ray_depth = maxf(ray_depth,_shape.shape.height*0.5-_shape.shape.radius+(_shape.shape.radius+p.margin)/support_hint_ny+_shape.shape.radius*sqrt(1.0/(support_hint_ny*support_hint_ny)-1.0)+depth)
	if physical_contact:
		# A vertical capsule on a steep plane can have its centre and rear
		# footprint much farther above the floor than its own height. Extend
		# observations only for actual upward contact; the full-shape cast and
		# separate contact-depth limit still establish real nearby support.
		var ny: float = contact.normal.y
		ray_depth = maxf(ray_depth,_shape.shape.height*0.5-_shape.shape.radius+(_shape.shape.radius+p.margin)/ny+_shape.shape.radius*sqrt(1.0/(ny*ny)-1.0)+depth)
	var ray := PhysicsRayQueryParameters3D.create(position,position+Vector3.DOWN*ray_depth)
	ray.exclude = [_actor.get_rid()]
	var centre := space.intersect_ray(ray)
	if centre.is_empty() or centre.normal.y < cos(deg_to_rad(tuning.support_degrees)): return {"ok":false,"reason":"centre_support_missing"}
	var centre_connector: bool = centre.normal.y < cos(deg_to_rad(tuning.walk_degrees)) and _connector(centre)
	# Beyond an incline's upper lip, a higher ordinary tread under the centre
	# supplies footing even while the capsule's rear cap still touches the ramp.
	# Do not extrapolate that finite incline upward through the staircase.
	if contact_connector and centre.normal.y >= cos(deg_to_rad(tuning.walk_degrees)) and centre.position.y >= contact.point.y-p.margin:
		contact_connector = false
	if centre.normal.y < 0.99999:
		var ny: float = centre.normal.y
		ray_depth = maxf(ray_depth,_shape.shape.height*0.5-_shape.shape.radius+(_shape.shape.radius+p.margin)/ny+_shape.shape.radius*sqrt(1.0/(ny*ny)-1.0)+depth)
	# Require a capsule-radius footprint, not a tiny rim contact at a ledge.
	# Each ray is only a support observation; full-shape sweeps/clearance remain
	# mandatory. Height following is still limited separately below.
	var observed_support_ny: float = centre.normal.y
	if physical_contact: observed_support_ny = minf(observed_support_ny,contact.normal.y)
	for offset in [Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK]:
		var edge_position: Vector3 = position+offset*_shape.shape.radius
		var edge_ray := PhysicsRayQueryParameters3D.create(edge_position,edge_position+Vector3.DOWN*ray_depth)
		edge_ray.exclude = [_actor.get_rid()]
		var edge := space.intersect_ray(edge_ray)
		if edge.is_empty():
			# Discovery does not depend on a cached hint (for example just after
			# placement). A longer retry accepts only an upward floor and retains
			# the floor-span bound below.
			var ny: float = cos(deg_to_rad(tuning.support_degrees))
			var discovery_depth: float = _shape.shape.height*0.5-_shape.shape.radius+(_shape.shape.radius+p.margin)/ny+_shape.shape.radius*sqrt(1.0/(ny*ny)-1.0)+depth
			edge_ray.to = edge_position+Vector3.DOWN*discovery_depth
			var discovered := space.intersect_ray(edge_ray)
			if not discovered.is_empty() and discovered.normal.y >= ny: edge = discovered
		if edge.is_empty() or edge.normal.y < cos(deg_to_rad(tuning.support_degrees)):
			var bounded_floor := _wall_bounded_floor(space,position,offset,ray_depth,p,tuning)
			if not bounded_floor.is_empty(): edge = bounded_floor
		if edge.is_empty() or edge.normal.y < cos(deg_to_rad(tuning.support_degrees)): return {"ok":false,"reason":"footprint_support_missing"}
		if edge.normal.y < 0.99999:
			observed_support_ny = minf(observed_support_ny,edge.normal.y)
			var edge_ny: float = edge.normal.y
			ray_depth = maxf(ray_depth,_shape.shape.height*0.5-_shape.shape.radius+(_shape.shape.radius+p.margin)/edge_ny+_shape.shape.radius*sqrt(1.0/(edge_ny*edge_ny)-1.0)+depth)
		var span_ny: float = minf(observed_support_ny,support_hint_ny)
		var floor_span: float = maxf(tuning.step_up,tuning.step_down)+tuning.contact_gap
		if span_ny < 0.99999: floor_span += _shape.shape.radius*sqrt(1.0/(span_ny*span_ny)-1.0)
		if centre.position.y-edge.position.y > floor_span: return {"ok":false,"reason":"footprint_floor_too_distant"}
	# A wall can win get_rest_info at a floor/wall seam. The centre's measured
	# upward plane distinguishes support from that wall; capsule sweep is still
	# mandatory, and distance includes the spherical cap on an inclined plane.
	var height: float = _shape.shape.height
	var radius: float = _shape.shape.radius
	var support_normal: Vector3 = centre.normal
	var ground_y: float = centre.position.y
	var connector := centre_connector
	# At a flat/ramp seam the spherical cap touches the incline before the
	# centre ray reaches it. Only a real, source-qualified floor contact can
	# supply that plane; footprint rays and the capsule sweep still must pass.
	if contact_connector:
		support_normal = contact.normal
		ground_y = contact.point.y-(support_normal.x*(position.x-contact.point.x)+support_normal.z*(position.z-contact.point.z))/support_normal.y
		connector = true
	elif connector and not contact.is_empty() and contact.normal.y >= cos(deg_to_rad(tuning.walk_degrees)):
		# At the upper lip an ordinary landing can become the actual support
		# before the centre sample leaves the corridor's last triangle.
		support_normal = contact.normal
	var required_y: float = ground_y+height*0.5-radius+(radius+p.margin)/support_normal.y
	var distance: float = position.y-required_y
	if connector and not contact.is_empty() and contact.normal.y >= cos(deg_to_rad(tuning.support_degrees)):
		# Jolt's rest point is approximate, particularly on the rounded-cap lip.
		# The full-shape downward cast is the measured clearance, not an infinite
		# plane extrapolated from that approximate point.
		distance = depth*fractions[0]
		required_y = position.y-distance
	if not contact.is_empty() and (contact.normal.y >= cos(deg_to_rad(tuning.support_degrees)) or cap_contact_support):
		# Rounded capsule contact may rest on the edge of a validated step.
		# Still require nearby ground under the centre, never an open gap.
		if distance <= depth or position.y-height*0.5-centre.position.y <= tuning.step_up+tuning.contact_gap:
			# Adjacent treads can have parallel normals at different heights.
			# Their normal agreement cannot replace the actual capsule clearance.
			distance = minf(distance,depth*fractions[0])
	if distance < -p.margin or distance > depth: return {"ok":false,"reason":"support_distance_outside_bound","distance":distance,"depth":depth,"normal":support_normal,"contact":contact,"centre":centre,"connector":connector}
	return {"ok":true,"normal":support_normal,"distance":maxf(0,distance),"collider":centre.collider_id,"plane_y":required_y,"ground_y":centre.position.y,"connector":connector,"support_ny":observed_support_ny}

func _clear_route(space: PhysicsDirectSpaceState3D, start: Vector3, end: Vector3, p: Dictionary) -> bool:
	return _volume(space,_shape.shape,start,p) and _volume(space,_shape.shape,end,p) and _route(space,_shape.shape,start,end,p)

## Candidate step route: full shape up, across, down; no endpoint-only teleport.
func _wall_direction(space: PhysicsDirectSpaceState3D, start: Vector3, requested: Vector3, distance: float, p: Dictionary, tuning: Dictionary, contact_normal: Vector3) -> Dictionary:
	# Probe above any legal riser, so a stair face is not mistaken for an
	# enclosing wall. Resolve these constraints against original intent, not
	# a succession of rounded contact normals that can reverse that intent.
	var origin: Vector3 = start+Vector3.UP*(maxf(_shape.shape.height-_shape.shape.radius,tuning.step_up+tuning.contact_gap*2)-_shape.shape.height*0.5)
	var directions: Array[Vector3] = [Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK]
	var contact_direction := -Vector3(contact_normal.x,0,contact_normal.z).normalized()
	if contact_direction.length_squared() > 0.5: directions.append(contact_direction)
	var direction := requested
	var found := false
	for axis: Vector3 in directions:
		var ray := PhysicsRayQueryParameters3D.create(origin,origin+axis*(_shape.shape.radius+distance+p.margin*3.0))
		ray.exclude = [_actor.get_rid()]
		var hit := space.intersect_ray(ray)
		if hit.is_empty() or absf(hit.normal.y) > 0.01 or direction.dot(hit.normal) >= -0.000001: continue
		direction = direction.slide(hit.normal)
		found = true
	if direction.dot(requested) < 0.000001: direction = Vector3.ZERO
	return {"direction":direction.normalized()} if found else {}

func _step_route(space: PhysicsDirectSpaceState3D, start: Vector3, horizontal: Vector3, p: Dictionary, tuning: Dictionary, obstacle_normal := Vector3.ZERO) -> Dictionary:
	# Measure the obstacle top independently of intermediate capsule-cap contacts.
	# At an angle, the leading cap reaches the riser before a ray projected
	# along the input direction reaches its tread. Sample across the measured
	# obstacle normal, while the actual swept route retains the requested angle.
	var approach := Vector3(obstacle_normal.x,0,obstacle_normal.z)
	var toe: Vector3 = -approach.normalized() if approach.length_squared() > 1e-12 and horizontal.dot(approach) < 0 else horizontal.normalized()
	var ahead: Vector3 = start+horizontal+toe*p.radius
	var top_ray := PhysicsRayQueryParameters3D.create(ahead+Vector3.UP*tuning.step_up,ahead+Vector3.DOWN*(_shape.shape.height*0.5+tuning.step_down))
	top_ray.exclude = [_actor.get_rid()]
	var top := space.intersect_ray(top_ray)
	var base_ray := PhysicsRayQueryParameters3D.create(start,start+Vector3.DOWN*(_shape.shape.height+tuning.step_up))
	base_ray.exclude = [_actor.get_rid()]
	var base := space.intersect_ray(base_ray)
	if top.is_empty() or base.is_empty() or top.normal.y < cos(deg_to_rad(tuning.walk_degrees)) or top.position.y-base.position.y > tuning.step_up+0.00001: return {"ok":false,"reason":"obstacle_top_outside_step_policy"}
	# Lift only as far as the measured tread requires. A larger configured
	# allowance must not invent extra headroom requirements on smaller stairs.
	var lift: float = clampf(top.position.y-(start.y-_shape.shape.height*0.5)+tuning.contact_gap,0,tuning.step_up)
	var raised: Vector3 = start+Vector3.UP*lift
	var across: Vector3 = raised+horizontal
	if not _clear_route(space,start,raised,p) or not _clear_route(space,raised,across,p): return {"ok":false,"reason":"step_up_across_clearance"}
	var drop_query := _query(_shape.shape,across,p.margin)
	drop_query.motion = Vector3.DOWN*(lift+tuning.step_down+tuning.contact_gap*2)
	var fractions := space.cast_motion(drop_query)
	if fractions.size() != 2 or fractions[0] >= 1: return {"ok":false,"reason":"step_destination_missing"}
	var destination: Vector3 = across+drop_query.motion*fractions[0]+Vector3.UP*maxf(0,tuning.contact_gap-p.margin)
	# Qualify support at the intended landing, not the temporarily raised probe.
	var support := _ground_support(space,destination,p,tuning,tuning.contact_gap*3)
	if not support.ok: return {"ok":false,"reason":"step_destination_support"}
	destination.y = maxf(destination.y,support.plane_y+maxf(0,tuning.contact_gap-p.margin))
	var rise: float = destination.y-start.y
	if rise > tuning.step_up+0.00001 or rise < -tuning.step_down-0.00001: return {"ok":false,"reason":"step_height_bound"}
	if not _clear_route(space,across,destination,p): return {"ok":false,"reason":"step_down_clearance"}
	return {"ok":true,"position":destination,"normal":support.normal,"rise":rise,"ground_y":support.ground_y}

## Only the coordinator advances this body. Travel is subdivided spatially,
## preventing endpoint probes from catching a distant floor across a gap.
func advance_ground(owner: RefCounted, raw: Variant) -> Dictionary:
	if _ground_owner == null or _ground_owner.get_ref() != owner or _committing: return {"ok":false,"reason":"Unbound or reentrant ground authority."}
	if not raw is Dictionary or raw.size() != 7 or typeof(raw.get("sequence")) != TYPE_INT or raw.sequence < 1 or raw.sequence > 1000000000 or raw.get("session") != _actor_scope or not raw.get("velocity") is Vector3 or not raw.velocity.is_finite() or absf(raw.velocity.y) > 0.000001 or raw.velocity.length() > 1000.000001 or not raw.get("forward") is Vector3 or not raw.forward.is_finite() or absf(raw.forward.y) > 0.000001 or absf(raw.forward.length()-1.0) > 0.000001 or not raw.get("delta") is float or not is_finite(raw.delta) or raw.delta <= 0 or raw.delta > 0.1 or typeof(raw.get("placement_serial")) != TYPE_INT or raw.placement_serial != _serial or not raw.get("posture") is Dictionary or typeof(raw.posture.get("desired")) != TYPE_STRING or not raw.posture.get("tuning") is Dictionary: return {"ok":false,"reason":"Malformed/stale ground step."}
	if raw.sequence == _ground_sequence: return _ground_last.result.duplicate(true) if _ground_last.get("request") == raw else {"ok":false,"reason":"Changed ground step identity."}
	if raw.sequence != _ground_sequence+1 or not core.gates.simulation(): return {"ok":false,"reason":"Out-of-order or suspended ground step."}
	var context := ground_context(raw.session)
	if not context.ok: return context
	if context.physical.get("mode") != "standing" or context.physical.get("transport") != "foot" or not context.physical.get("fall_history",{}).is_empty(): return {"ok":false,"reason":"Ground request cannot replace active air/special-mode history."}
	var checked := prepare_ground_posture(owner,raw.session,raw.posture.get("desired",""),raw.posture.get("tuning",{}),raw.posture.get("mechanism",{}).get("packet",{}))
	if not checked.get("ok",false) or checked != raw.posture: return {"ok":false,"reason":"Posture/geometry changed during ground preparation."}
	var tuning: Dictionary = checked.tuning
	var p: Dictionary = _receipts[_state.handoff_id].policy.duplicate()
	p.margin = tuning.motion_margin
	var space := _actor.get_world_3d().direct_space_state
	var support := _ground_support(space,_actor.position,p,tuning,tuning.contact_gap*3,float(_ground_last.get("result",{}).get("support_hint_ny",1.0)))
	if not support.ok: return {"ok":false,"reason":"Ground support lost; coordinator must select checked flight.","support_observation":str(support)}
	_committing = true
	_actor.safe_margin = p.margin*2.0
	var old_height: float = _shape.shape.height
	var passive := Vector3.ZERO
	var mechanism_failure := ""
	var mechanism_support_lost := false
	if checked.has("mechanism") and not checked.mechanism.lethal:
		var mechanism_commit: Dictionary = owner.mechanisms.commit(checked.mechanism.packet.sample)
		if _actor_scope != raw.session or core.snapshot().session != raw.session or not is_instance_valid(_actor):
			_committing = false
			return {"ok":false,"retired":true,"reason":"Physical mechanism scope retired during commitment."}
		if not mechanism_commit.ok:
			_committing = false
			return {"ok":false,"reason":mechanism_commit.reason,"mechanism_changed":mechanism_commit.get("changed",false)}
		if mechanism_commit.get("receipt_pending",false): mechanism_failure = "Mechanism acknowledgment pending; performed carriage retained."
	if absf(old_height-checked.height) > 0.000001:
		var dimensions := p.duplicate()
		dimensions.height = checked.height
		_shape.shape = _capsule(dimensions)
		_actor.position = checked.position
	_state.physical.posture = checked.actual
	_state.desired_posture = checked.desired
	_state.pending_stand = checked.pending_stand
	_state.shape.height = checked.height
	if checked.has("mechanism"):
		var plan: Dictionary = checked.mechanism
		# Crush admission retains a safe crouched pose and the unadvanced provider
		# sample under a global consequence hold; it never embeds the survivor.
		if not plan.lethal:
			_actor.position = checked.position
			passive = plan.passive
			if plan.attached: owner.view.carry_yaw(raw.session,plan.yaw)
		else:
			_actor.position = checked.position
		_state.position = _actor.position
		var forced_reasons: Dictionary = _state.get("forced_posture",{}).duplicate(true)
		if plan.forced: forced_reasons[plan.packet.sample.source] = "crouched"
		else: forced_reasons.erase(plan.packet.sample.source)
		_state.forced_posture = forced_reasons
		# Actual support is observed only after mechanism geometry commitment.
		support = _ground_support(space,_actor.position,p,tuning,tuning.contact_gap*3)
		if not support.ok: mechanism_support_lost = true
	var motion_start := _actor.position
	var takeoff_velocity := _actor.velocity
	var budget: float = raw.velocity.length()*raw.delta if mechanism_failure.is_empty() and not mechanism_support_lost and not checked.get("mechanism",{}).get("lethal",false) else 0.0
	var horizontal: Vector3 = raw.velocity.normalized()
	var requested_horizontal := horizontal
	var surface_distance := 0.0
	var collisions := 0
	var handoff_pending := mechanism_support_lost
	var steps := 0
	var stair_correction := 0.0
	var contact_reason := ""
	var blocked_redirects := 0
	# At the supported max speed/delta/stride this bounded loop is <= 20,000.
	while budget > 0.00000001:
		var distance: float = minf(budget,minf(tuning.probe_stride,p.radius*0.25))
		var normal: Vector3 = support.normal
		var tangent := horizontal.slide(normal)
		if normal.y < cos(deg_to_rad(tuning.walk_degrees)) and tangent.y > 0.000001 and not support.get("connector",false):
			# Remove uphill component, preserving contour/downhill voluntary motion.
			var uphill := Vector3.UP.slide(normal).normalized()
			tangent -= uphill*maxf(0,tangent.dot(uphill))
		if tangent.length_squared() < 1e-12: break
		tangent = tangent.normalized()*distance
		var start := _actor.position
		var sweep := KinematicCollision3D.new()
		var candidate := start+tangent
		var blocked := _actor.test_move(_actor.global_transform,tangent,sweep,p.margin*2.0)
		var contact_normal := sweep.get_normal() if sweep.get_collision_count() > 0 else Vector3.ZERO
		var contact_point := sweep.get_position() if sweep.get_collision_count() > 0 else Vector3.ZERO
		var contact_travel := sweep.get_travel()
		# Very short gait fragments can miss test_move's contact tolerance while
		# the authoritative query-margin sweep already meets a floor or wall.
		if not blocked and not _clear_route(space,start,candidate,p):
			blocked = true
			var query := _query(_shape.shape,start,p.margin)
			query.motion = tangent
			var fractions := space.cast_motion(query)
			if fractions.size() == 2 and fractions[0] < 1.0:
				contact_travel = tangent*fractions[0]
				query.transform.origin += tangent*fractions[1]
				query.motion = Vector3.ZERO
				var contact := space.get_rest_info(query)
				if not contact.is_empty():
					contact_normal = contact.normal
					contact_point = contact.point
		# Redirect a bounded fragment onto an approved incline at its actual
		# capsule contact. This consumes the same surface-distance budget; it is
		# not a stair lift, slope-angle increase or collision bypass.
		if blocked and contact_normal.y >= cos(deg_to_rad(tuning.support_degrees)) and contact_normal.y < 0.99999 and _connector_contact(space,contact_point,contact_normal):
			var approach: float = maxf(0.000001,-tangent.normalized().dot(contact_normal))
			var backoff: float = minf(contact_travel.length(),p.margin*2.0/approach)
			var prefix := start+contact_travel-tangent.normalized()*backoff
			var remaining: float = maxf(0,distance-prefix.distance_to(start))
			var redirected := prefix+horizontal.slide(contact_normal).normalized()*remaining
			if _clear_route(space,start,prefix,p) and _clear_route(space,prefix,redirected,p) and _clear_route(space,start,redirected,p):
				tangent = redirected-start
				candidate = redirected
				blocked = false
		if blocked:
			# test_move reports contact travel, not a guaranteed query-margin gap.
			# Back off along the intended route, never push out along a new axis.
			var approach: float = maxf(0.000001,-tangent.normalized().dot(contact_normal))
			var backoff: float = minf(contact_travel.length(),p.margin*2.0/approach)
			candidate = start+contact_travel-tangent.normalized()*backoff
		var target_support := _ground_support(space,candidate,p,tuning,tuning.step_down+tuning.contact_gap*2,float(support.get("support_ny",1.0)))
		var stepped := false
		if blocked:
			var route := _step_route(space,start,Vector3(tangent.x,0,tangent.z),p,tuning,contact_normal)
			contact_reason = route.get("reason","")
			if route.ok and route.rise > 0.000001 and route.normal.y >= cos(deg_to_rad(tuning.walk_degrees)):
				candidate = route.position
				target_support = {"ok":true,"normal":route.normal,"ground_y":route.ground_y}
				stepped = true
		if blocked and not stepped and blocked_redirects < 4:
			var wall_motion := _wall_direction(space,start,requested_horizontal,distance,p,tuning,contact_normal)
			if not wall_motion.is_empty():
				var constrained: Vector3 = wall_motion.direction
				# Preserve a reachable approach prefix when every component is
				# blocked; probing a wall ahead must not stop the body short of it.
				if constrained.length_squared() > 1e-12 and constrained.dot(horizontal) < 0.9999:
					horizontal = constrained
					blocked_redirects += 1
					collisions += 1
					continue
		if blocked and not stepped and candidate.distance_to(start) <= p.margin*3.0:
			var wall := Vector3(contact_normal.x,0,contact_normal.z)
			var along_wall: Vector3 = requested_horizontal.slide(wall.normalized()).normalized() if wall.length_squared() > 1e-12 else Vector3.ZERO
			if along_wall.dot(requested_horizontal) < 0.000001: along_wall = Vector3.ZERO
			# A zero-length blocked prefix cannot leave valid ground. Resolve
			# its wall constraint before probing an unreachable destination.
			if along_wall.length_squared() < 1e-12:
				collisions += 1
				break
			if blocked_redirects < 4 and along_wall.dot(horizontal) < 0.9999:
				horizontal = along_wall
				blocked_redirects += 1
				collisions += 1
				continue
		if target_support.ok and support.ground_y-target_support.ground_y > tuning.step_down+0.00001:
			handoff_pending = true
			break
		if not target_support.ok:
			contact_reason = "target_"+str(target_support.get("reason","support_missing"))
			# A swept unsupported prefix is real departure, not a blocked ground
			# frame whose zero average velocity can strand the player on the rim.
			# Keep the last performed fragment's velocity at the support boundary.
			if _clear_route(space,start,candidate,p) and candidate.distance_to(start) > 0.00000001:
				_actor.position = candidate
				takeoff_velocity = (candidate-start)*(raw.velocity.length()/distance)
				surface_distance += minf(candidate.distance_to(start),distance)
				budget -= distance
			handoff_pending = true
			break
		var before_following := candidate
		if not stepped:
			# Down following is a bounded correction after the swept voluntary path.
			var drop: float = maxf(0,target_support.distance-maxf(0,tuning.contact_gap-p.margin))
			if drop > tuning.step_down+0.00001:
				handoff_pending = true
				break
			var followed := candidate+Vector3.DOWN*drop
			var follow_route_clear := false
			if target_support.normal.y > 0.99999 and target_support.has("plane_y"):
				var level := followed
				level.y = target_support.plane_y+maxf(0,tuning.contact_gap-p.margin)
				# A clear flat landing has an exact height. Keep cast quantization
				# from accumulating hover; a rounded stair lip can still obstruct
				# this route, in which case retain its measured capsule clearance.
				follow_route_clear = _clear_route(space,candidate,level,p)
				if follow_route_clear: followed = level
				else: followed.y = maxf(followed.y,level.y)
			if not follow_route_clear and not _clear_route(space,candidate,followed,p):
				# Mixed tread/riser contacts can make the centre plane propose a
				# descent through the preceding lip. Find a clear prefix of this
				# bounded downward route, then require real nearby support again.
				var clear_fraction := 0.0
				var blocked_fraction := 1.0
				for probe in 12:
					var middle: float = (clear_fraction+blocked_fraction)*0.5
					if _clear_route(space,candidate,candidate.lerp(followed,middle),p): clear_fraction = middle
					else: blocked_fraction = middle
				var limited: Vector3 = candidate.lerp(followed,clear_fraction)
				var limited_support := _ground_support(space,limited,p,tuning,tuning.contact_gap*3,float(target_support.get("support_ny",1.0)))
				if not limited_support.ok or not _clear_route(space,candidate,limited,p):
					contact_reason = "follow_clearance"
					break
				followed = limited
				target_support = limited_support
			candidate = followed
		var connector_motion: bool = not stepped and (support.get("connector",false) or target_support.get("connector",false))
		if connector_motion and candidate.distance_to(start) > distance:
			# Lip following is voluntary corridor travel, not a free stair/drop
			# correction. Bound the actual physical segment by the same gait budget.
			var bounded := start+(candidate-start).limit_length(distance)
			if not _clear_route(space,start,bounded,p): break
			var bounded_support := _ground_support(space,bounded,p,tuning,tuning.contact_gap*3,minf(float(support.get("support_ny",1.0)),float(target_support.get("support_ny",1.0))))
			if not bounded_support.ok:
				handoff_pending = true
				contact_reason = "bounded_connector_support"
				break
			candidate = bounded
			target_support = bounded_support
		# A new steep contact cannot turn a wall into uphill ground.
		if target_support.normal.y < cos(deg_to_rad(tuning.walk_degrees)) and candidate.y > start.y+0.00001 and not target_support.get("connector",false):
			contact_reason = "ordinary_uphill_restricted"
			break
		if stepped:
			_actor.position = candidate # All three full-shape route fragments qualified.
			steps += 1
		else:
			# Commit the qualified across/follow route, not a different diagonal
			# motion through its corner. A second solver's recovery could otherwise
			# leave the capsule overlapping a tall stair lip after a valid sweep.
			# Unblocked across motion and following/bounded motion were already
			# checked above. Only a shortened collision prefix needs this check.
			if blocked and not _clear_route(space,start,before_following,p):
				contact_reason = "collision_prefix_clearance"
				break
			_actor.position = candidate
		if blocked and not stepped:
			collisions += 1
			var wall := Vector3(contact_normal.x,0,contact_normal.z)
			if wall.length_squared() > 1e-12 and requested_horizontal.dot(wall) < -0.000001:
				horizontal = requested_horizontal.slide(wall.normalized()).normalized()
		var performed: float = _actor.position.distance_to(start)
		if performed < 0.00000001:
			if blocked and horizontal.length_squared() > 1e-12 and absf(horizontal.dot(tangent.normalized())) < 0.9999:
				budget -= distance
				continue
			break
		# Count only the swept prefix of voluntary surface motion. A blocked
		# incline cannot retain the requested, unperformed vertical component.
		var intended_horizontal := Vector2(tangent.x,tangent.z)
		var actual_horizontal := Vector2(_actor.position.x-start.x,_actor.position.z-start.z)
		var fraction: float = clampf(actual_horizontal.dot(intended_horizontal)/maxf(1e-20,intended_horizontal.length_squared()),0,1)
		var performed_surface := tangent*fraction
		if connector_motion: performed_surface = _actor.position-start
		takeoff_velocity = performed_surface*(raw.velocity.length()/distance)
		stair_correction += _actor.position.y-start.y-performed_surface.y
		# Float32 committed positions can exceed an exact fragment by a few
		# micrometres. Activity cannot receive more than the consumed gait budget;
		# independent fixtures also bound the actual physical displacement.
		surface_distance += minf(performed_surface.length(),distance)
		budget -= distance
		support = target_support
		if horizontal.length_squared() < 1e-12: break
	var travel := _actor.position-motion_start
	_actor.velocity = travel/raw.delta
	_actor.basis = Basis.looking_at(raw.forward,Vector3.UP)
	_state.position = _actor.position
	_state.physical.velocity = _actor.velocity
	_state.forward = raw.forward
	if handoff_pending:
		air.begin(_actor.position.y-checked.height*0.5,Vector3(takeoff_velocity.x,0,takeoff_velocity.z),{"kind":"walk-off"})
		_actor.velocity = air.velocity
		_publish_air()
	_ground_sequence = raw.sequence
	var result := {"ok":true,"session":raw.session,"sequence":raw.sequence,"position":_actor.position,"base":_actor.position-Vector3.UP*checked.height*0.5,"posture":checked.duplicate(true),"requested_displacement":raw.velocity*raw.delta,"voluntary_displacement":travel,"passive_displacement":Vector3.ZERO,"actual_metres_per_second":surface_distance/raw.delta,"surface_distance":surface_distance,"stair_correction":stair_correction,"contact_reason":contact_reason,"collisions":collisions,"steps":steps,"placement_serial":_serial,"handoff_pending":handoff_pending,"unsupported_remainder":horizontal*budget if handoff_pending else Vector3.ZERO}
	result.support_hint_ny = float(support.get("support_ny",1.0))
	result.passive_displacement = passive
	result.mechanism = checked.get("mechanism",{}).duplicate(true)
	result.mechanism_failure = mechanism_failure
	if checked.has("mechanism") and not handoff_pending:
		var actual_support := _ground_support(space,_actor.position,p,tuning,tuning.contact_gap*3,float(support.get("support_ny",1.0)))
		result.mechanism_supported = actual_support.get("ok",false) and actual_support.get("collider") == checked.mechanism.packet.sample.geometry.get_instance_id()
	_ground_last = {"request":raw.duplicate(true),"result":result.duplicate(true)}
	_committing = false
	return result

## Ordered by the coordinator after swept flight, before performed-work capture.
## This is the same capsule, never an independent mechanism collision callback.
func commit_air_mechanism(owner: RefCounted, scope: String, packet: Dictionary, tuning: Dictionary) -> Dictionary:
	if _committing or _ground_owner == null or _ground_owner.get_ref() != owner or scope != _actor_scope: return {"ok":false,"reason":"Current coordinated air mechanism authority required."}
	var checked := prepare_ground_posture(owner,scope,_state.get("desired_posture",_state.physical.posture),tuning,packet)
	if not checked.ok: return checked
	var plan: Dictionary = checked.mechanism
	_committing = true
	var acknowledgment_pending := false
	if not plan.lethal:
		var committed: Dictionary = owner.mechanisms.commit(packet.sample)
		if _actor_scope != scope or core.snapshot().session != scope or not is_instance_valid(_actor):
			_committing = false
			return {"ok":false,"retired":true,"reason":"Air mechanism scope retired during commitment."}
		if not committed.ok:
			_committing = false
			return committed
		acknowledgment_pending = committed.get("receipt_pending",false)
	if _shape.shape.height != checked.height:
		var dimensions: Dictionary = _receipts[_state.handoff_id].policy.duplicate()
		dimensions.height = checked.height
		_shape.shape = _capsule(dimensions)
	_actor.position = checked.position
	_state.shape.height = checked.height
	_state.physical.posture = checked.actual
	_state.desired_posture = checked.desired
	_state.pending_stand = checked.pending_stand
	var reasons: Dictionary = _state.get("forced_posture",{}).duplicate(true)
	if plan.forced: reasons[packet.sample.source] = "crouched"
	else: reasons.erase(packet.sample.source)
	_state.forced_posture = reasons
	if plan.attached:
		owner.view.carry_yaw(scope,plan.yaw)
		_actor.basis = Basis(Vector3.UP,plan.yaw)*_actor.basis
		_state.forward = -_actor.basis.z
	var base: Vector3 = _actor.position-Vector3.UP*checked.height*0.5
	if air.airborne: air.observe(base.y)
	_publish_air()
	var support: Dictionary = {}
	if not air.airborne:
		var support_policy: Dictionary = _receipts[_state.handoff_id].policy.duplicate()
		support_policy.margin = tuning.motion_margin
		support = _ground_support(_actor.get_world_3d().direct_space_state,_actor.position,support_policy,tuning,tuning.contact_gap*3)
	_committing = false
	return {"ok":true,"position":_actor.position,"base":base,"posture":checked,"passive":plan.passive,"mechanism":plan,"mechanism_supported":support.get("ok",false) and support.get("collider") == packet.sample.geometry.get_instance_id(),"mechanism_failure":"Mechanism acknowledgment pending; performed air push retained." if acknowledgment_pending else ""}

## Geometry-safe view-origin proposal. A near-plane enclosing sphere is swept
## from the validated actual eye; unsafe interpolation snaps to that eye.
func ground_view_route(owner: RefCounted, start: Vector3, target: Vector3, radius: float) -> bool:
	if _ground_owner == null or _ground_owner.get_ref() != owner or not is_instance_valid(_actor): return false
	var sphere := SphereShape3D.new()
	sphere.radius = radius
	var space := _actor.get_world_3d().direct_space_state
	var p := {"margin":0.001}
	return _volume(space,sphere,start,p) and _volume(space,sphere,target,p) and _route(space,sphere,start,target,p)

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
	if (air.airborne or not air.pending.is_empty()) and _actor_scope == value.get("activation_session"): return _result(value,"unresolved_air_requires_explicit_owner_transfer")
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
		_actor.collision_mask = 0xffffffff
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
	air = preload("res://scripts/move/air_history.gd").new()
	_takeoff_sequence = 0
	_takeoff_receipt.clear()
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
