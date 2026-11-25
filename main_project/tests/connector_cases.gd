extends "res://tests/ground_cases.gd"
## Production motor/CHAR on original corridor meshes. Controlled entry/LOC scope.
var prefix := ""
func check(id: String, expected: Variant, actual: Variant) -> void:
	super.check(prefix+id,expected,actual)

func traverse(posture: String, gait_name: String) -> bool:
	var body: Node3D = shell_ref.session_shell.placement
	var origin: Vector3 = body.snapshot().position
	shell_ref.session_shell.focus_changed(true)
	key(KEY_W,true)
	var total := 0.0
	var bounded := true
	var result := {}
	var physical_bounded := true
	var maximum_physical_excess := 0.0
	var captured_slope := false
	for index in 1600:
		var before: Vector3 = body.snapshot().position
		result = step(0.02)
		if not result.get("ok",false) or result.get("suspended",false) or result.get("handoff_pending",false): break
		total += result.get("surface_distance",0.0)
		bounded = bounded and result.get("actual_metres_per_second",INF) <= result.get("gait",{}).get("target_metres_per_second",0.0)+0.0001
		physical_bounded = physical_bounded and body.snapshot().position.distance_to(before) <= result.get("gait",{}).get("target_metres_per_second",0.0)*0.02+0.0002
		maximum_physical_excess = maxf(maximum_physical_excess,body.snapshot().position.distance_to(before)-result.get("gait",{}).get("target_metres_per_second",0.0)*0.02)
		if not captured_slope and posture == "standing" and gait_name == "walk" and DisplayServer.get_name() != "headless" and body.snapshot().position.y > course.rise*0.5+0.9:
			key(KEY_W,false)
			var facing: Dictionary = shell_ref.session_shell.view.capture_facing(scope)
			shell_ref.session_shell.view.place_facing(scope,{"version":1,"yaw":0.0,"pitch":-rad_to_deg(atan2(course.rise,course.run_metres))})
			await capture_course("connector-%d-slope" % course.model_id)
			shell_ref.session_shell.view.place_facing(scope,facing)
			key(KEY_W,true)
			captured_slope = true
		if body.snapshot().position.y > course.rise+body.snapshot().shape.height*0.5-0.1 and body.snapshot().position.z < -2-course.run_metres-0.6: break
	key(KEY_W,false)
	check("uphill request succeeds",true,result.get("ok",false))
	check("reaches upper landing",true,body.snapshot().position.y > course.rise+body.snapshot().shape.height*0.5-0.1 and body.snapshot().position.z < -2-course.run_metres-0.6)
	check("uphill gait speed bounded",true,bounded)
	check("uphill physical speed bounded",true,physical_bounded)
	check("uphill has no stair lift",true,absf(result.get("stair_correction",INF)) < 0.01)
	var support_policy: Dictionary = body.baseline_policy()
	support_policy.margin = motor.profile.surface.motion_margin
	measurements.append({"case":prefix+"uphill","position":str(body.snapshot().position),"rise_metres":course.rise,"surface_metres":total,"maximum_physical_excess_metres":maximum_physical_excess,"last":str(result),"support":str(body._ground_support(body._actor.get_world_3d().direct_space_state,body.snapshot().position,support_policy,motor.profile.surface,motor.profile.surface.contact_gap*3))})
	if body.snapshot().position.y < course.rise:
		var collision := KinematicCollision3D.new()
		var probe := Vector3.FORWARD*minf(0.05,float(result.get("gait",{}).get("target_metres_per_second",0.0))*0.02)
		var collided: bool = body._actor.test_move(body._actor.global_transform,probe,collision,support_policy.margin*2)
		if collided and collision.get_collision_count() > 0:
			var normal := collision.get_normal()
			var point := collision.get_position()
			var space: PhysicsDirectSpaceState3D = body._actor.get_world_3d().direct_space_state
			var ray := PhysicsRayQueryParameters3D.create(point+normal*0.03,point-normal*0.03)
			ray.exclude = [body._actor.get_rid()]
			var hit := space.intersect_ray(ray)
			var redirected := Vector3.FORWARD.slide(normal).normalized()*probe.length()
			measurements.append({"case":prefix+"blocked seam diagnostic","normal":str(normal),"point":str(point),"hit":str(hit),"permitted":course.ground_surface({},hit) if not hit.is_empty() else false,"redirect_clear":body._clear_route(space,body.snapshot().position,body.snapshot().position+redirected,support_policy),"redirect_support":str(body._ground_support(space,body.snapshot().position+redirected,support_policy,motor.profile.surface,0.2))})
	if posture == "standing" and gait_name == "walk" and DisplayServer.get_name() != "headless":
		var facing: Dictionary = shell_ref.session_shell.view.capture_facing(scope)
		shell_ref.session_shell.view.place_facing(scope,{"version":1,"yaw":180.0,"pitch":60.0})
		await capture_course("connector-%d-upper" % course.model_id)
		shell_ref.session_shell.view.place_facing(scope,facing)
	key(KEY_S,true)
	bounded = true
	physical_bounded = true
	maximum_physical_excess = 0.0
	for index in 1600:
		var before: Vector3 = body.snapshot().position
		result = step(0.02)
		if not result.get("ok",false) or result.get("suspended",false) or result.get("handoff_pending",false): break
		bounded = bounded and result.get("actual_metres_per_second",INF) <= result.get("gait",{}).get("target_metres_per_second",0.0)+0.0001
		physical_bounded = physical_bounded and body.snapshot().position.distance_to(before) <= result.get("gait",{}).get("target_metres_per_second",0.0)*0.02+0.0002
		maximum_physical_excess = maxf(maximum_physical_excess,body.snapshot().position.distance_to(before)-result.get("gait",{}).get("target_metres_per_second",0.0)*0.02)
		if body.snapshot().position.z >= origin.z-0.1: break
	key(KEY_S,false)
	check("downhill request succeeds",true,result.get("ok",false))
	check("returns to lower landing",true,body.snapshot().position.z >= origin.z-0.1 and absf(body.snapshot().position.y-origin.y) < 0.02)
	check("downhill gait speed bounded",true,bounded)
	check("downhill physical speed bounded",true,physical_bounded)
	measurements.append({"case":prefix+"downhill","position":str(body.snapshot().position),"maximum_physical_excess_metres":maximum_physical_excess,"last":str(result)})
	check("performed work settles",true,motor.retry_activity().ok)
	return result.get("ok",false) and not result.get("suspended",false) and not result.get("handoff_pending",false) and body.snapshot().position.z >= origin.z-0.1 and absf(body.snapshot().position.y-origin.y) < 0.02

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	prefix = "connector %d " % int(fixture.connector_model)
	if await bootstrap(shell,fixture):
		var controls: RefCounted = shell.controller.controls
		var previous_response: Dictionary = controls.effective().response.duplicate(true)
		controls.begin()
		controls.set_response({"run_mode":"hold","sneak_mode":"hold","crouch_mode":"toggle"})
		controls.apply()
		var real_formula: Callable = motor.gait.formula
		var observed_formula: Array = [0,true]
		motor.gait.formula = func(value: Dictionary):
			observed_formula[0] += 1
			observed_formula[1] = observed_formula[1] and value.profile.size() == 15 and not value.profile.has("connectors")
			return real_formula.call(value)
		var model_prefix := prefix
		for variant: Array in [["standing","walk"],["standing","run"],["standing","sneak"],["crouched","walk"],["crouched","run"],["crouched","sneak"]]:
			prefix = model_prefix+variant[0]+" "+variant[1]+" "
			if motor.gait.crouch_selected != (variant[0] == "crouched"):
				key(KEY_CTRL,true)
				key(KEY_CTRL,false)
			step(0.02)
			check("actual posture",variant[0],shell.session_shell.placement.snapshot().physical.posture)
			key(KEY_SHIFT,variant[1] == "run")
			key(KEY_ALT,variant[1] == "sneak")
			var practice_before: int = actors.activity_projection(scope,"ground-player").get("practice",{}).get("running",0)
			var completed: bool = await traverse(variant[0],variant[1])
			var practice_after: int = actors.activity_projection(scope,"ground-player").get("practice",{}).get("running",0)
			check("actual gait activity practice",true,practice_after > practice_before if variant[1] == "run" else practice_after == practice_before)
			key(KEY_SHIFT,false)
			key(KEY_ALT,false)
			if not completed: break
		prefix = model_prefix
		motor.gait.formula = real_formula
		check("fixed gait RULE payload excludes source catalog",true,observed_formula[0] > 100 and observed_formula[1])
		var policy := preload("res://scripts/data/steep_connector_policy.gd")
		var rows: Array = motor.profile.connectors
		check("resolved loose connector list overrides disabled MOD list",25,rows.size())
		var duplicate_rows := rows.duplicate(true)
		duplicate_rows.append(rows[0].duplicate(true))
		check("duplicate source row rejects",true,not policy.reason(duplicate_rows).is_empty())
		var malformed := rows.duplicate(true)
		malformed[0].model = true
		check("boolean source model rejects",true,not policy.reason(malformed).is_empty())
		check("removed list grants nothing",{},policy.match_source({},course.source_block,course.source_record,course.prepared.prototype))
		var changed_block: Dictionary = course.source_block.duplicate(true)
		changed_block.definition.environment_observation.source_input.payload_sha256 = "0".repeat(64)
		check("changed source block grants nothing",{},policy.match_source(policy.index(rows),changed_block,course.source_record,course.prepared.prototype))
		var changed_record: Dictionary = course.source_record.duplicate(true)
		changed_record.transform.position[0] += 1
		check("changed source pose grants nothing",{},policy.match_source(policy.index(rows),course.source_block,changed_record,course.prepared.prototype))
		var replacement: Dictionary = course.prepared.prototype.duplicate()
		replacement.kind = "replacement"
		check("replacement mesh grants nothing",{},policy.match_source(policy.index(rows),course.source_block,course.source_record,replacement))
		var tilted := CollisionShape3D.new()
		tilted.shape = course.ramp_collision.shape
		policy.attach(tilted,course.prepared.prototype,course.source_row,Transform3D(Basis(Vector3.RIGHT,0.1),Vector3.ZERO))
		check("unreviewed tilted placement receives no grant",false,tilted.has_meta("ground_connector"))
		tilted.free()
		var bound: Dictionary = course.ramp_collision.get_meta("ground_connector")
		var point: Vector3 = bound.pose*((bound.points[0]+bound.points[1]+bound.points[2])/3)
		var normal: Vector3 = bound.pose.basis*(bound.points[2]-bound.points[0]).cross(bound.points[1]-bound.points[0]).normalized()
		check("selected triangle accepts omitted engine face index",true,policy.permits(course.ramp_collision,-1,normal,point))
		check("nearby position cannot borrow floor permission",false,policy.permits(course.ramp_collision,-1,normal,point+Vector3.RIGHT*10))
		check("wall normal cannot borrow floor permission",false,policy.permits(course.ramp_collision,-1,Vector3.RIGHT,point))
		var saved_pose: Transform3D = course.ramp_node.transform
		course.ramp_node.position.x += 0.1
		check("changed physical pose loses permission",false,policy.permits(course.ramp_collision,-1,normal,point))
		course.ramp_node.transform = saved_pose
		course.ramp_collision.shape.set_faces(course.ramp_collision.shape.get_faces())
		check("shape edits invalidate bound source grant",false,policy.permits(course.ramp_collision,-1,normal,point))
		controls.begin()
		controls.set_response({"run_mode":previous_response.run_mode,"sneak_mode":previous_response.sneak_mode,"crouch_mode":previous_response.crouch_mode})
		var restored: Dictionary = controls.apply()
		check("review preferences restored through owner",true,restored.get("applied",false) and controls.effective().response == previous_response)
		actor_core.request({"id":"connector-return-%d" % int(fixture.connector_model),"mode":"return","origin":scope})
		if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		source_a.callback = Callable()
		preload("res://scripts/loc/dungeon_geometry.gd").release(course)
	var ok := true
	for item in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size(),"measurements":measurements}
