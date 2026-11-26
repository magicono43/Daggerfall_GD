extends RefCounted
## Detached full-capsule planning for qualified upright box mechanisms.
## Queries exclude only the player and this sample's moving box. Every other
## solid remains an opposing obstruction. No camera ray certifies compression.
static func overlaps(center: Vector3, height: float, radius: float, transform: Transform3D, size: Vector3, margin: float) -> bool:
	var point := transform.affine_inverse()*center
	var half := size*0.5
	var separation := Vector3(maxf(0,absf(point.x)-half.x),maxf(0,absf(point.y)-(height*0.5-radius)-half.y),maxf(0,absf(point.z)-half.z))
	return separation.length_squared() < pow(radius+margin,2)

static func query(body: Node3D, center: Vector3, height: float, radius: float, margin: float, geometry: StaticBody3D) -> PhysicsShapeQueryParameters3D:
	var shape := CapsuleShape3D.new()
	shape.radius = radius
	shape.height = height
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = shape
	q.transform.origin = center
	q.margin = margin
	q.collision_mask = 0xffffffff
	q.exclude = [body._actor.get_rid(),geometry.get_rid()]
	return q

static func route(body: Node3D, start: Vector3, target: Vector3, height: float, radius: float, margin: float, geometry: StaticBody3D) -> Dictionary:
	var space: PhysicsDirectSpaceState3D = body._actor.get_world_3d().direct_space_state
	var q := query(body,start,height,radius,margin,geometry)
	if not space.intersect_shape(q,1).is_empty(): return {"ok":false,"reason":"initial opposing overlap","opposing":space.get_rest_info(q),"start":start,"target":target,"height":height}
	q.motion = target-start
	var fractions := space.cast_motion(q)
	if fractions.size() != 2: return {"ok":false,"reason":"opposing sweep unavailable"}
	if fractions[0] < 1.0:
		# Query the actual blocked full-volume destination. A cast's unsafe
		# fraction can lie on a numerically tangent boundary with no rest witness.
		q.transform.origin = target
		q.motion = Vector3.ZERO
		var hit := space.get_rest_info(q)
		if hit.is_empty():
			q.transform.origin = start+(target-start)*fractions[1]+(target-start).normalized()*margin*2.0
			hit = space.get_rest_info(q)
		return {"ok":false,"fraction":fractions[0],"opposing":hit}
	q.transform.origin = target
	q.motion = Vector3.ZERO
	if space.intersect_shape(q,1).is_empty(): return {"ok":true}
	var witness := space.get_rest_info(q)
	if witness.is_empty() and target != start:
		q.transform.origin = target+(target-start).normalized()*margin*2.0
		witness = space.get_rest_info(q)
	return {"ok":false,"opposing":witness,"reason":"full destination volume obstructed"}

static func escape(body: Node3D, start: Vector3, requested: Vector3, height: float, radius: float, margin: float, sample: Dictionary) -> Dictionary:
	var route_check := route(body,start,requested,height,radius,margin,sample.geometry)
	if route_check.ok and not overlaps(requested,height,radius,sample.to,sample.dimensions,margin): return {"ok":true,"position":requested}
	# A witnessed opposing plane can redirect an actual push along its tangent.
	# No arbitrary side teleport or obstacle pass-through is introduced.
	var hit: Dictionary = route_check.get("opposing",{})
	if not hit.is_empty() and hit.get("normal") is Vector3:
		var displacement := requested-start
		var tangent: Vector3 = displacement.slide(hit.normal)
		var slid := start+tangent
		var slide_route := route(body,start,slid,height,radius,margin,sample.geometry)
		if tangent.length_squared() > 0.000000001 and slide_route.ok and not overlaps(slid,height,radius,sample.to,sample.dimensions,margin): return {"ok":true,"position":slid}
	return {"ok":false,"opposing":hit,"fraction":route_check.get("fraction",0.0),"route":route_check}

static func prepare(body: Node3D, packet: Dictionary, desired: String, tuning: Dictionary) -> Dictionary:
	var sample: Dictionary = packet.sample
	var state: Dictionary = body.snapshot()
	var standing: Dictionary = body._receipts[state.handoff_id].policy
	var height: float = state.shape.height
	var radius: float = state.shape.radius
	var margin: float = tuning.motion_margin
	if packet.policy.compression_metres > tuning.contact_gap*0.5: return {"ok":false,"reason":"Mechanism tolerance exceeds the current contact-clearance envelope."}
	margin = maxf(margin,packet.policy.compression_metres)
	var center: Vector3 = state.position
	var base := center-Vector3.UP*height*0.5
	var support: Dictionary = body._ground_support(body._actor.get_world_3d().direct_space_state,center,{"radius":radius,"height":height,"margin":margin},tuning,tuning.contact_gap*3)
	var attached: bool = support.get("ok",false) and support.get("collider") == sample.geometry.get_instance_id() and not body.air.airborne
	var carry := Vector3.ZERO
	var yaw := 0.0
	if attached and packet.policy.carry:
		carry = sample.to*(sample.from.affine_inverse()*base)-base
		yaw = packet.yaw
	var point_velocity: Vector3 = packet.linear+packet.angular.cross(base-sample.from.origin)
	var target_base := base+carry
	var target_height: float = tuning.crouch_height if desired == "crouched" else standing.height
	var target := target_base+Vector3.UP*target_height*0.5
	var motion: Vector3 = sample.to.origin-sample.from.origin
	var angular_movement: Vector3 = sample.to*(sample.from.affine_inverse()*center)-center
	var active: bool = angular_movement.length() > 0.0000001
	if not active:
		# A stationary action is ordinary collision geometry. Reuse the complete
		# stock posture query, including this box, rather than treating rounded
		# contact/margin disagreement as a mechanism push or crush.
		var ordinary: Dictionary = body.prepare_ground_posture(body._ground_owner.get_ref(),state.session,desired,tuning)
		if not ordinary.ok: return ordinary
		ordinary.mechanism = {"packet":packet.duplicate(true),"attached":attached,"local_point":sample.from.affine_inverse()*base,"point_velocity":Vector3.ZERO,"yaw":0.0,"passive":Vector3.ZERO,"forced":false,"lethal":false,"opposing":{}}
		return ordinary
	var pushing := overlaps(target,target_height,radius,sample.to,sample.dimensions,margin)
	if pushing and not packet.policy.push: return {"ok":false,"reason":"Player intersects non-pushing mechanism; owner recovery required."}
	if pushing:
		var direction := angular_movement.normalized()
		if direction.is_zero_approx(): return {"ok":false,"reason":"Stationary mechanism overlap is placement failure, never crushing."}
		var lo := 0.0
		var hi: float = angular_movement.length()+target_height+radius*2.0+sample.dimensions.length()
		if overlaps(target+direction*hi,target_height,radius,sample.to,sample.dimensions,margin): return {"ok":false,"reason":"Mechanism escape envelope unavailable."}
		for index in 24:
			var mid := (lo+hi)*0.5
			if overlaps(target+direction*mid,target_height,radius,sample.to,sample.dimensions,margin): lo = mid
			else: hi = mid
		target += direction*(hi+margin*2.0)
	var result := escape(body,base+Vector3.UP*target_height*0.5,target,target_height,radius,margin,sample)
	if not result.ok and attached and not pushing and absf(motion.y) <= 0.0000001:
		# A horizontal platform may slide beneath a wall-blocked rider. Resolve
		# only its collision-valid carry prefix, rather than declaring a crush.
		var start := base+Vector3.UP*target_height*0.5
		var lo := 0.0
		var hi := 1.0
		for index in 24:
			var mid := (lo+hi)*0.5
			var candidate := start.lerp(target,mid)
			if route(body,start,candidate,target_height,radius,margin,sample.geometry).ok and not overlaps(candidate,target_height,radius,sample.to,sample.dimensions,margin): lo = mid
			else: hi = mid
		var prefix := start.lerp(target,lo)
		if route(body,start,prefix,target_height,radius,margin,sample.geometry).ok and not overlaps(prefix,target_height,radius,sample.to,sample.dimensions,margin): result = {"ok":true,"position":prefix}
	var forced := false
	var lethal := false
	var opposing: Dictionary = result.get("opposing",{})
	if not result.ok:
		# A translating hazard must actually intersect/compress the body, or be
		# the rising support itself. Mere horizontal frictional carriage is not
		# crushing. The opposing normal is a full-shape collision witness.
		var vertical: bool = active and motion.y > 0.0000001 and Vector2(motion.x,motion.z).length() <= 0.0000001 and absf(packet.yaw) < 0.000001
		var rising_support: bool = attached and vertical and opposing.get("normal",Vector3.ZERO).dot(Vector3.DOWN) > 0.99
		var translating_push: bool = pushing and active and absf(packet.yaw) < 0.000001 and opposing.get("normal",Vector3.ZERO).dot(motion.normalized()) < -0.99
		var grounded: bool = support.get("ok",false) and not body.air.airborne
		var compressing: bool = packet.policy.crush and grounded and not opposing.is_empty() and (rising_support or translating_push) and state.physical.mode == "standing" and state.physical.transport == "foot"
		if compressing:
			forced = true
			target_height = tuning.crouch_height
			var crouch_start := base+Vector3.UP*target_height*0.5
			var crouch_target := target_base+Vector3.UP*target_height*0.5
			if overlaps(crouch_target,target_height,radius,sample.to,sample.dimensions,margin):
				var direction := angular_movement.normalized()
				var low := 0.0
				var high: float = angular_movement.length()+target_height+radius*2+sample.dimensions.length()
				for index in 24:
					var middle := (low+high)*0.5
					if overlaps(crouch_target+direction*middle,target_height,radius,sample.to,sample.dimensions,margin): low = middle
					else: high = middle
				crouch_target += direction*(high+margin*2.0)
			result = escape(body,crouch_start,crouch_target,target_height,radius,margin,sample)
			if not result.ok:
				# Full crouched capsule at the required supported base cannot fit;
				# both obstruction and continuing floor motion are retained evidence.
				lethal = not result.get("opposing",{}).is_empty()
				if not lethal: return {"ok":false,"reason":"Crouched compression evidence inconclusive."}
				result = {"ok":true,"position":crouch_start,"fraction":result.get("fraction",0.0)}
		elif desired == "standing" and state.physical.posture == "crouched":
			target_height = tuning.crouch_height
			result = escape(body,base+Vector3.UP*target_height*0.5,target_base+Vector3.UP*target_height*0.5,target_height,radius,margin,sample)
		if not result.ok: return {"ok":false,"reason":"Mechanism push has no qualified collision-valid route; retain owner recovery. "+str({"attached":attached,"active":active,"vertical":vertical,"opposing":opposing,"route":result,"motion":motion,"mode":state.physical.mode,"transport":state.physical.transport}),"opposing":opposing}
	var position: Vector3 = result.position
	var actual := "crouched" if target_height < standing.height else "standing"
	return {"ok":true,"session":state.session,"serial":state.serial,"from":center,"from_height":height,"position":position,"height":target_height,"actual":actual,"desired":desired,"pending_stand":desired == "standing" and actual == "crouched","tuning":tuning.duplicate(true),"mechanism":{"packet":packet.duplicate(true),"attached":attached,"local_point":sample.from.affine_inverse()*base,"point_velocity":point_velocity if attached else Vector3.ZERO,"yaw":yaw,"passive":position-Vector3.UP*target_height*0.5-base,"forced":forced,"lethal":lethal,"opposing":opposing}}
