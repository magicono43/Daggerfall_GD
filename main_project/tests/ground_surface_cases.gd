extends RefCounted
## Independent authored metre dimensions; real collision and coordinated travel.
func run(t: RefCounted) -> void:
	var body: Node3D = t.shell_ref.session_shell.placement
	var origin: Vector3 = body.snapshot().position
	var shell: RefCounted = t.shell_ref.session_shell
	# A small step is below the independent 0.50 m up/down bounds.
	var stair: StaticBody3D = t.course.box(Vector3(origin.x,0.085,origin.z-2),Vector3(4,0.17,3),Color.CORNFLOWER_BLUE)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_W,true)
	var result: Dictionary = t.step(0.02,20)
	t.key(KEY_W,false)
	t.check("surface small step traversal succeeds",true,result.get("ok",false) and not result.get("handoff_pending",false))
	t.near("surface small step actual rise",0.17,body.snapshot().position.y-origin.y,0.002)
	t.check("surface upward camera trails actual step",true,shell.view_camera.position.y < body.snapshot().position.y+0.6999 and shell.view_camera.position.y >= body.snapshot().position.y+0.45)
	await t.capture_course("surface-step-up")
	t.key(KEY_S,true)
	t.step(0.02,20)
	t.key(KEY_S,false)
	t.near("surface small down step returns base",origin.y,body.snapshot().position.y,0.002)
	t.check("surface downward camera offset is smooth and bounded",true,shell.view_camera.position.y > body.snapshot().position.y+0.7001 and shell.view_camera.position.y <= body.snapshot().position.y+0.8801)
	await t.capture_course("surface-step-down")
	t.near("surface step round trip horizontal",origin.z,body.snapshot().position.z,0.05)
	stair.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	# A 0.51 m obstacle exceeds the up bound, even after repeated probes.
	var tall: StaticBody3D = t.course.box(Vector3(origin.x,0.255,origin.z-2),Vector3(4,0.51,3),Color.FIREBRICK)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_W,true)
	result = t.step(0.02,40)
	t.key(KEY_W,false)
	t.check("surface repeated above bound step blocked",true,result.get("ok",false) and body.snapshot().position.z > origin.z-0.5 and absf(body.snapshot().position.y-origin.y) < 0.002)
	var stopped: Vector3 = body.snapshot().position
	t.step(0.02,20)
	t.check("surface stationary probes add no propulsion",stopped,body.snapshot().position)
	tall.queue_free()
	tall = t.course.box(Vector3(origin.x,0.4,origin.z-2),Vector3(4,0.8,3),Color.FIREBRICK)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_W,true)
	result = t.step(0.02,20)
	t.key(KEY_W,false)
	t.check("surface oversized 0.80 m step remains blocked",true,result.get("ok",false) and body.snapshot().position.z > origin.z-0.5 and absf(body.snapshot().position.y-origin.y) < 0.002)
	tall.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	# Return using measured production displacement, never direct body writes.
	var remaining: float = origin.z-body.snapshot().position.z
	t.key(KEY_S,true)
	t.step(remaining/(175.0/39.5))
	t.key(KEY_S,false)
	# Exact up bound, followed by a separately bounded downward transition.
	var bound_origin: Vector3 = body.snapshot().position
	var bound: StaticBody3D = t.course.box(Vector3(bound_origin.x,0.25,bound_origin.z-2),Vector3(4,0.50,3),Color.BLUE)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_W,true)
	result = t.step(0.02,20)
	t.key(KEY_W,false)
	t.near("surface exact up bound traversed",bound_origin.y+0.50,body.snapshot().position.y,0.002)
	var descent: StaticBody3D = t.course.box(Vector3(bound_origin.x,-0.05,bound_origin.z),Vector3(4,0.10,1),Color.BLUE)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_S,true)
	result = t.step(0.02,20)
	t.key(KEY_S,false)
	t.check("surface exact down bound follows",true,result.get("ok",false) and not result.get("handoff_pending",false))
	t.near("surface exact down bound actual base",bound_origin.y,body.snapshot().position.y,0.002)
	t.key(KEY_S,true)
	t.step(0.02,12)
	t.key(KEY_S,false)
	bound.queue_free()
	descent.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.near("surface bounded descent returns floor",bound_origin.y,body.snapshot().position.y,0.002)
	# A low ceiling does not permit a standing step; deliberate crouch fits.
	var low_origin: Vector3 = body.snapshot().position
	var low_step: StaticBody3D = t.course.box(Vector3(low_origin.x,0.085,low_origin.z-2),Vector3(4,0.17,3),Color.BLUE)
	var ceiling: StaticBody3D = t.course.box(Vector3(low_origin.x,1.6,low_origin.z-2),Vector3(4,0.2,3),Color.ORANGE)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_W,true)
	t.step(0.02,20)
	t.key(KEY_W,false)
	t.check("surface low ceiling standing step blocked",true,body.snapshot().position.z > low_origin.z-0.5 and body.snapshot().physical.posture == "standing")
	t.key(KEY_CTRL,true)
	t.key(KEY_CTRL,false)
	t.step(0.02)
	t.key(KEY_W,true)
	result = t.step(0.02,30)
	t.key(KEY_W,false)
	t.check("surface deliberate crouch traverses low step",true,result.get("ok",false) and body.snapshot().physical.posture == "crouched" and body.snapshot().position.z < low_origin.z-1)
	t.key(KEY_S,true)
	t.step(0.02,45)
	t.key(KEY_S,false)
	ceiling.queue_free()
	low_step.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_CTRL,true)
	t.key(KEY_CTRL,false)
	t.step(0.02,12)
	t.near("surface low step returns standing floor",low_origin.y,body.snapshot().position.y,0.002)
	# Climb a 0.51 m platform from a 0.01 m approach tread (rise 0.50 m),
	# then test its far 0.51 m descent to the ordinary floor.
	var drop_origin: Vector3 = body.snapshot().position
	var approach: StaticBody3D = t.course.box(Vector3(drop_origin.x,0.005,drop_origin.z-1.5),Vector3(4,0.01,2),Color.BLUE)
	var drop_step: StaticBody3D = t.course.box(Vector3(drop_origin.x,0.255,drop_origin.z-3),Vector3(4,0.51,2),Color.BLUE)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_W,true)
	t.step(0.02,25)
	t.key(KEY_W,false)
	t.key(KEY_W,true)
	for index in 25:
		result = t.step(0.02)
		if result.get("handoff_pending",false): break
	t.key(KEY_W,false)
	t.check("surface above down bound hands off",true,result.get("handoff_pending",false))
	var retained: Vector3 = body.snapshot().position
	t.motor.retry_activity()
	t.check("surface down handoff retry never moves",retained,body.snapshot().position)
	var intermediate: StaticBody3D = t.course.box(Vector3(drop_origin.x,0.01,drop_origin.z-5),Vector3(4,0.02,2),Color.BLUE)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_W,true)
	t.step(0.02,30)
	t.key(KEY_W,false)
	# Continue beyond the intermediate tread before removing fixture geometry.
	t.key(KEY_W,true)
	t.step(0.02,25)
	t.key(KEY_W,false)
	drop_step.queue_free()
	approach.queue_free()
	intermediate.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.near("surface above down fixture returns floor",drop_origin.y,body.snapshot().position.y,0.002)
	t.key(KEY_S,true)
	for index in 200:
		var return_seconds: float = (drop_origin.z-body.snapshot().position.z)/(175.0/39.5)
		if return_seconds < 0.000001: break
		t.step(minf(0.02,return_seconds))
	t.key(KEY_S,false)
	for width in [0.64,0.58]:
		var passage_origin: Vector3 = body.snapshot().position
		var sides: Array = []
		for side in [-1,1]: sides.append(t.course.box(Vector3(passage_origin.x+side*(10+width*0.5),1.5,passage_origin.z-2),Vector3(20,3,3),Color.GREEN))
		await t.shell_ref.get_tree().physics_frame
		await t.shell_ref.get_tree().physics_frame
		shell.focus_changed(true)
		t.key(KEY_W,true)
		t.step(0.02,25)
		t.key(KEY_W,false)
		if width > 0.6:
			t.check("surface validated 0.64 m passage traversed",true,body.snapshot().position.z < passage_origin.z-1.5)
		else:
			t.check("surface full shape rejects 0.58 m passage",true,body.snapshot().position.z > passage_origin.z-0.5)
		t.key(KEY_S,true)
		t.step(0.02,30)
		t.key(KEY_S,false)
		for side: StaticBody3D in sides: side.queue_free()
		await t.shell_ref.get_tree().physics_frame
		await t.shell_ref.get_tree().physics_frame
		shell.focus_changed(true)
	# A 30-degree ramp measures total surface travel, including diagonal input.
	var ramp: StaticBody3D = t.course.ramp(Vector3(origin.x,0,body.snapshot().position.z-0.5),30.0)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_W,true)
	result = t.step(0.02,30)
	t.key(KEY_W,false)
	t.check("surface walkable slope climbs",true,result.get("ok",false) and body.snapshot().position.y > origin.y+0.5)
	t.check("surface slope distance speed bounded",true,result.get("actual_metres_per_second",INF) <= 175.0/39.5+0.001)
	t.key(KEY_W,true)
	t.key(KEY_D,true)
	result = t.step(0.02,4)
	t.key(KEY_W,false)
	t.key(KEY_D,false)
	t.check("surface diagonal uphill speed bounded",true,result.get("actual_metres_per_second",INF) <= 175.0/39.5+0.001)
	# A real wall contact on the incline cannot charge unperformed upward
	# intent as Running. Flush the approach before measuring the blocked interval.
	var wall_origin: Vector3 = body.snapshot().position
	var slope_wall: StaticBody3D = t.course.box(Vector3(wall_origin.x,wall_origin.y+1,wall_origin.z-0.7),Vector3(4,4,0.2),Color.RED)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_SHIFT,true)
	t.key(KEY_W,true)
	t.step(0.02,15)
	t.motor.retry_activity()
	var blocked_practice: int = t.actors.activity_projection(t.scope,"ground-player").practice.running
	var blocked_pose: Vector3 = body.snapshot().position
	result = t.step(0.02,20)
	t.key(KEY_W,false)
	t.key(KEY_SHIFT,false)
	t.motor.retry_activity()
	t.near("surface blocked incline reports actual zero speed",0,result.actual_metres_per_second,0.0001)
	t.near("surface blocked incline has no physical travel",0,blocked_pose.distance_to(body.snapshot().position),0.0001)
	t.check("surface blocked incline awards no Running practice",blocked_practice,t.actors.activity_projection(t.scope,"ground-player").practice.running)
	slope_wall.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_S,true)
	t.step(0.02,40)
	t.key(KEY_S,false)
	t.near("surface slope descent returns floor",origin.y,body.snapshot().position.y,0.002)
	ramp.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	var steep: StaticBody3D = t.course.ramp(Vector3(body.snapshot().position.x,0,body.snapshot().position.z-0.5),55.0)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	var steep_start: Vector3 = body.snapshot().position
	t.key(KEY_W,true)
	result = t.step(0.02,30)
	t.key(KEY_W,false)
	t.check("surface steep ordinary uphill blocked",true,result.get("ok",false) and body.snapshot().position.y < steep_start.y+0.1)
	t.key(KEY_W,true)
	t.key(KEY_D,true)
	result = t.step(0.02,5)
	t.key(KEY_W,false)
	t.key(KEY_D,false)
	t.check("surface steep diagonal cannot bypass",true,result.get("ok",false) and body.snapshot().position.y < steep_start.y+0.1)
	steep.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	# Reach an elevated level through two real 0.17 m steps. Then replace its
	# support with a tangent 55-degree plane without moving/resizing the actor.
	var support_origin: Vector3 = body.snapshot().position
	var low: StaticBody3D = t.course.box(Vector3(support_origin.x,0.085,support_origin.z-1.5),Vector3(4,0.17,1),Color.BLUE)
	var high: StaticBody3D = t.course.box(Vector3(support_origin.x,0.17,support_origin.z-3.5),Vector3(4,0.34,3),Color.BLUE)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_W,true)
	t.step(0.02,40)
	t.key(KEY_W,false)
	var supported_pose: Vector3 = body.snapshot().position
	t.near("surface elevated support setup",support_origin.y+0.34,supported_pose.y,0.002)
	var plane_y := supported_pose.y-0.6-0.301/cos(deg_to_rad(55.0))-0.005
	var incline: StaticBody3D = t.course.ramp(Vector3(supported_pose.x,plane_y-tan(deg_to_rad(55.0))*2,supported_pose.z+2),55.0,4.0)
	high.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	result = t.step(0.02,10)
	t.check("surface genuinely supported steep remains stable",true,result.get("ok",false) and body.snapshot().position == supported_pose)
	t.key(KEY_W,true)
	result = t.step(0.02,5)
	t.key(KEY_W,false)
	t.check("surface supported steep uphill blocked",supported_pose,body.snapshot().position)
	# Physical support must not depend on membership in the connector list.
	# Remove the lower base so every footprint ray observes the inclined plane,
	# rather than accidentally finding the unrelated flat floor beneath it.
	var base_floor: StaticBody3D = t.course.get_child(0)
	base_floor.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_CTRL,true)
	t.key(KEY_CTRL,false)
	t.step(0.02)
	var crouched_supported_pose: Vector3 = body.snapshot().position
	result = t.step(0.02,5)
	t.check("surface unlisted 55 degree crouched support stable",true,result.get("ok",false) and body.snapshot().physical.posture == "crouched" and body.snapshot().position == crouched_supported_pose)
	t.key(KEY_CTRL,true)
	t.key(KEY_CTRL,false)
	t.step(0.02)
	incline.queue_free()
	var steep_degrees := 69.0
	plane_y = supported_pose.y-0.6-0.301/cos(deg_to_rad(steep_degrees))-0.005
	incline = t.course.ramp(Vector3(supported_pose.x,plane_y-tan(deg_to_rad(steep_degrees))*2,supported_pose.z+2),steep_degrees,4.0)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	result = t.step(0.02,5)
	t.check("surface unlisted 69 degree standing support stable",true,result.get("ok",false) and body.snapshot().position == supported_pose)
	t.key(KEY_W,true)
	t.step(0.02,5)
	t.key(KEY_W,false)
	t.check("surface unlisted 69 degree standing uphill blocked",supported_pose,body.snapshot().position)
	t.key(KEY_CTRL,true)
	t.key(KEY_CTRL,false)
	t.step(0.02)
	crouched_supported_pose = body.snapshot().position
	result = t.step(0.02,5)
	t.check("surface unlisted 69 degree crouched support stable",true,result.get("ok",false) and body.snapshot().physical.posture == "crouched" and body.snapshot().position == crouched_supported_pose)
	t.key(KEY_W,true)
	t.step(0.02,5)
	t.key(KEY_W,false)
	t.check("surface unlisted 69 degree crouched uphill blocked",crouched_supported_pose,body.snapshot().position)
	t.key(KEY_CTRL,true)
	t.key(KEY_CTRL,false)
	t.step(0.02)
	t.motor.retry_activity()
	var before_loss: Dictionary = body.ground_context(t.scope)
	incline.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	var unsupported: Dictionary = body._ground_last.request.duplicate(true)
	unsupported.sequence += 1
	unsupported.velocity = Vector3.ZERO
	unsupported.posture = body.prepare_ground_posture(t.motor,t.scope,"standing",t.motor.profile.surface)
	var rejected: Dictionary = body.advance_ground(t.motor,unsupported)
	t.check("surface loss support checked owner boundary",true,not rejected.ok and "support" in rejected.get("reason","").to_lower())
	t.check("surface support loss preserves physical history",before_loss,body.ground_context(t.scope))
	t.course.box(Vector3(0,-0.1,0),Vector3(80,0.2,80),Color(0.2,0.3,0.25))
	high = t.course.box(Vector3(support_origin.x,0.17,support_origin.z-3.5),Vector3(4,0.34,3),Color.BLUE)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.key(KEY_S,true)
	t.step(0.02,45)
	t.key(KEY_S,false)
	t.near("surface supported steep fixture returns floor",support_origin.y,body.snapshot().position.y,0.002)
	low.queue_free()
	high.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	shell.focus_changed(true)
	t.motor.retry_activity()
