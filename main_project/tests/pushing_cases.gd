extends "res://tests/ground_cases.gd"
func check(id: String, expected: Variant, actual: Variant) -> void:
	super.check(id,expected,actual)
	checks[-1].scenario = "push "+id

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var provider := preload("res://tests/controlled_mechanism.gd").new("controlled-fast-push","MOVE",["motion"])
	extra_services = [provider.binding()]
	var f := fixture.duplicate(true)
	f.mechanism_course = true
	f.ground_entry_id = "fast-push-entry"
	if await bootstrap(shell,f):
		var body: Node3D = shell.session_shell.placement
		provider.geometry = course.box(Vector3(0,1.5,0),Vector3(0.1,2,4),Color.DARK_ORANGE)
		provider.support = "controlled-pusher"
		await shell.get_tree().physics_frame
		await shell.get_tree().physics_frame
		shell.session_shell.focus_changed(true)
		step(0.02)
		motor.retry_activity()
		check("noncrush policy binds",true,motor.bind_mechanism(provider,provider.id,"carry-push").ok)
		var before: Dictionary = actors.activity_projection(scope,"ground-player")
		provider.velocity = Vector3(20,0,0)
		var fast := step(0.1)
		check("thin fast geometry cannot tunnel",true,fast.get("ok",false) and body.snapshot().position.x > 2.35 and body.snapshot().position.x < 2.36 and fast.get("mechanism_slices",0) > 1)
		check("push travel remains passive",true,fast.surface_distance == 0.0 and fast.mechanism_metres > 1.3 and motor.feedback.steps == 0)
		provider.velocity = Vector3.ZERO
		step(0.02,30)
		motor.retry_activity()
		var after: Dictionary = actors.activity_projection(scope,"ground-player")
		var expected_drain := int((int(before.fatigue_remainder)+(int(after.game)-int(before.game))*11)/60000000)
		check("passive time retains ordinary CHAR fatigue",true,expected_drain > 0 and after.current.fatigue == before.current.fatigue-expected_drain)
		check("passive time never awards Running",before.practice.running,after.practice.running)
		var health: int = after.current.health
		course.box(Vector3(3,1.5,0),Vector3(0.2,3,6),Color.FIREBRICK)
		await shell.get_tree().physics_frame
		await shell.get_tree().physics_frame
		shell.session_shell.focus_changed(true)
		provider.velocity = Vector3(20,0,0)
		var blocked := step(0.1)
		check("blocked noncrush route retains recovery",true,not blocked.get("ok",true) and blocked.get("performed_prefix",false) and not actor_core.gates.simulation())
		check("noncrush policy cannot authorize death",true,motor.crush_outcomes.is_empty() and motor.crush_pending.is_empty() and actors.vital_projection(scope,"ground-player").current.health == health)
		var state: Dictionary = body.snapshot()
		var shape_policy: Dictionary = body._receipts[state.handoff_id].policy.duplicate()
		shape_policy.margin = motor.profile.surface.motion_margin
		check("blocked prefix full capsule remains clear",true,body._volume(body._actor.get_world_3d().direct_space_state,body._shape.shape,state.position,shape_policy))
		var retained: Vector3 = state.position
		motor.physics_step(0.02)
		check("blocked retry never repeats push",retained,body.snapshot().position)
		measurements.append({"case":"thin fast pusher","metres_per_second":20.0,"requested_seconds":0.1,"actual_position_x":fast.position.x,"slices":fast.mechanism_slices,"passive_metres":fast.mechanism_metres,"ordinary_fatigue_drain":expected_drain,"blocked_prefix_seconds":blocked.get("eligible_seconds",0.0)})
		actor_core.request({"id":"push-return","mode":"return","origin":scope})
		if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		source_a.callback = Callable()
		course.queue_free()
	return {"ok":checks.all(func(item): return item.expected == item.actual),"checks":checks,"count":checks.size(),"measurements":measurements}
