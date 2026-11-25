extends RefCounted

func rule(t: RefCounted, hook: String, value: Dictionary) -> Dictionary:
	t.motor._busy = true
	t.motor._formula_operation = {"session":t.scope,"boundary":hook}
	var result: Dictionary = t.actor_core.formulas.invoke(hook,value,t.actor_core,t.motor,t.scope,t.motor._formula_operation)
	t.motor._busy = false
	return result

func transition(t: RefCounted, provider: RefCounted, revision: int, kind: String, active: bool, success := true, evidence: Dictionary = {}) -> Dictionary:
	provider.transition_request = {"session":t.scope,"source":provider.id,"revision":revision,"kind":kind,"active":active,"success":success,"evidence":evidence,"placement_serial":t.shell_ref.session_shell.placement.snapshot().serial}
	return t.motor.protection_transition(provider,provider.transition_request)

func run(t: RefCounted, a: RefCounted, b: RefCounted, prevention: RefCounted) -> void:
	var body: Node3D = t.shell_ref.session_shell.placement
	var p: Dictionary = t.motor.air_policy.duplicate(true)
	var expected_terminal := 2.0 if t.shell_ref.fixture.get("inputs",{}).get("input_sequence") == "air-cap-2" else 40.0
	t.near("published downward cap selection",expected_terminal,p.maximum_downward_speed,0.00001)
	for value in [true,-1.0,INF,NAN,0.0]:
		var bad := p.duplicate(true)
		bad.gravity = value
		t.check("policy rejects gravity "+str(value),false,preload("res://scripts/data/air_policy.gd").reason(bad).is_empty())
	for distance in [0.0,2.5,2.50001,5.0,5.01,5.199,5.2,5.999,6.0]:
		var result := rule(t,"move.landing-damage",{"profile":p,"distance":distance})
		t.check("distance damage "+str(distance),int(maxf(0.0,5.0*(distance-5.0))),int(result.get("value",-1)))
		var history := preload("res://scripts/move/air_history.gd").new()
		history.begin(distance,Vector3.ZERO,{})
		var landing: Dictionary = history.land(0.0,1.0)
		t.check("distance feedback boundary "+str(distance),distance > 2.5,landing.distance > p.hard_distance)
	for jumping in [0,100,1000000000]:
		for flags in range(8):
			var athletic: bool = flags & 1 != 0
			var improved: bool = flags & 2 != 0
			var enhanced: bool = flags & 4 != 0
			var result := rule(t,"move.jump-impulse",{"profile":p,"jumping":jumping,"athleticism":athletic,"improved_athleticism":improved,"enhanced":enhanced,"crouched":false})
			t.near("formula J "+str(jumping)+" traits "+str(flags),4.5*(1.0+float(jumping)/200.0+(0.1 if athletic else 0.0)+(0.1 if athletic and improved else 0.0)+(0.6 if enhanced else 0.0)),result.get("value",-1.0),0.00001)
	# Pure history qualification: origin compensation and overlapping reasons do
	# not depend on a real MAGIC/WORLD provider and do not claim those integrations.
	var h := preload("res://scripts/move/air_history.gd").new()
	h.begin(10.0,Vector3(2,3,4),{"gait":"run"})
	h.observe(12.0)
	h.origin_y -= 100.0
	h.observe(112.0)
	t.near("origin compensated peak debt",12.0,h.land(100.0,1.0).distance,0.000001)
	# Real provider boundary: a failed grab preserves the active damaging peak.
	t.step(0.02)
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	var old_peak: float = body.air.peak
	t.check("failed climb does not protect",false,transition(t,a,1,"climb",true,false).ok)
	t.check("failed climb keeps actual peak",old_peak,body.air.peak)
	t.check("successful climb protection",true,transition(t,a,2,"climb",true).ok)
	t.check("overlapping levitation protection",true,transition(t,b,1,"levitation",true).ok)
	t.check("climb release keeps other protection",true,transition(t,a,3,"climb",false).ok and not body.air.protections.is_empty())
	t.check("levitation release starts fresh segment",true,transition(t,b,2,"levitation",false).ok and body.air.protections.is_empty())
	var release_base: float = body.snapshot().position.y-body.snapshot().shape.height*0.5
	t.near("protection release actual base",release_base+body.air.origin_y,body.air.peak,0.00001)
	var obstructed := {"entered":true,"solid_first":true,"surface_only":true,"sufficient_depth":false,"volume":"controlled-water"}
	t.check("water under floor rejects",false,transition(t,a,4,"water",true,true,obstructed).ok)
	obstructed.solid_first = false
	t.check("surface-only exterior actual water protects",true,transition(t,a,5,"water",true,true,obstructed).ok)
	t.check("water release succeeds",true,transition(t,a,6,"water",false).ok)
	t.finish_flight()
	t.motor.retry_activity()
	var practice_before_retry: int = t.actors.activity_projection(t.scope,"ground-player").practice.jumping
	t.clock_provider.fail_event_capture = true
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	t.check("interrupted jump retains unpaid event",true,not t.motor._jump_debt.is_empty() and not t.actor_core.gates.simulation())
	var interrupted_pose: Vector3 = body.snapshot().position
	var interrupted_velocity: Vector3 = body.air.velocity
	t.step(0.02)
	t.check("interrupted jump cannot repeat impulse",interrupted_velocity,body.air.velocity)
	t.clock_provider.fail_event_capture = false
	var nested_retry: Array = [{}]
	t.clock_provider.event_callback = func(): nested_retry[0] = t.motor.retry_activity()
	t.check("jump billing explicit retry succeeds",true,t.motor.retry_activity().get("ok",false))
	t.check("jump billing provider cannot reenter",true,nested_retry[0].get("ok") == false and "reentrant" in nested_retry[0].get("reason",""))
	t.clock_provider.event_callback = Callable()
	t.check("jump billing retry never moves",interrupted_pose,body.snapshot().position)
	t.check("jump billing retry awards practice once",practice_before_retry+1,t.actors.activity_projection(t.scope,"ground-player").practice.jumping)
	t.motor.retry_activity()
	t.check("jump billing duplicate cannot award again",practice_before_retry+1,t.actors.activity_projection(t.scope,"ground-player").practice.jumping)
	t.finish_flight()
	t.motor.retry_activity()
	t.step(0.02)
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	t.motor.retry_activity()
	var origin_debt: float = body.air.peak-(body.snapshot().position.y-body.snapshot().shape.height*0.5+body.air.origin_y)
	var origin_hold: int = t.actor_core.gates.acquire("air-origin-fixture",t.scope,["simulation","save"])
	for offset in [100.0,-100.0]:
		for child in t.course.get_children():
			if child is Node3D: child.position.y += offset
		await t.shell_ref.get_tree().physics_frame
		await t.shell_ref.get_tree().physics_frame
		a.transition_request = {"session":t.scope,"source":a.id,"revision":100 if offset > 0 else 101,"placement_serial":body.snapshot().serial,"delta":Vector3(0,offset,0)}
		t.check("coherent origin shift "+str(offset),true,t.motor.origin_shift(a,a.transition_request).ok)
		var debt: float = body.air.peak-(body.snapshot().position.y-body.snapshot().shape.height*0.5+body.air.origin_y)
		t.near("origin shift preserves real fall debt "+str(offset),origin_debt,debt,0.00002)
	t.actor_core.gates.release(origin_hold,"air-origin-fixture")
	t.shell_ref.session_shell.focus_changed(true)
	t.finish_flight()
	t.motor.retry_activity()
	# Platform point velocity sampled on real supported body, including rotation.
	t.step(0.02)
	var base: Vector3 = body.snapshot().position-Vector3.UP*body.snapshot().shape.height*0.5
	a.transition_request = {"session":t.scope,"source":a.id,"support":"controlled-turntable","revision":7,"placement_serial":body.snapshot().serial,"linear":Vector3(1,0,0),"angular":Vector3(0,2,0),"point":base,"center":base-Vector3.RIGHT}
	t.check("rotating platform sample admitted",true,t.motor.platform_velocity(a,a.transition_request).ok)
	t.key(KEY_SPACE,true)
	var launched: Dictionary = t.step(0.02)
	t.key(KEY_SPACE,false)
	t.near("platform translation inherited once",1.0,body.air.velocity.x,0.00001)
	t.near("platform rotation inherited once",-2.0,body.air.velocity.z,0.00001)
	t.check("platform detaches immediately",true,t.motor._platform.is_empty())
	t.step(0.02,4)
	t.near("platform later frames cannot amplify",-2.0,body.air.velocity.z,0.00001)
	t.key(KEY_D,true)
	t.step(0.02)
	t.key(KEY_D,false)
	t.near("ordinary intent cannot steer",1.0,body.air.velocity.x,0.00001)
	t.trait_provider.enhanced_jumping = true
	t.trait_provider.revision += 1
	t.key(KEY_D,true)
	t.step(0.02)
	t.check("enhanced steering accelerates gradually",true,body.air.velocity.x > 1.0 and body.air.velocity.x <= 1.24001)
	var enhanced_velocity: Vector3 = body.air.velocity
	t.trait_provider.enhanced_jumping = false
	t.trait_provider.revision += 1
	t.step(0.02)
	t.near("effect loss preserves horizontal momentum",enhanced_velocity.x,body.air.velocity.x,0.00001)
	t.key(KEY_D,false)
	t.restriction_provider.voluntary = false
	t.restriction_provider.revision += 1
	var restricted_velocity: Vector3 = body.air.velocity
	t.key(KEY_A,true)
	t.step(0.02)
	t.key(KEY_A,false)
	t.near("paralysis retains passive horizontal momentum",restricted_velocity.x,body.air.velocity.x,0.00001)
	t.check("paralysis permits gravity",true,body.air.velocity.y < restricted_velocity.y)
	t.restriction_provider.voluntary = true
	t.restriction_provider.revision += 1
	t.key(KEY_SHIFT,true)
	t.check("airborne gait request stays latched","walk",t.step(0.02).get("gait",{}).get("gait"))
	t.finish_flight()
	t.check("actual landing restores requested ground gait","run",t.step(0.02).get("gait",{}).get("gait"))
	t.key(KEY_SHIFT,false)
	t.motor.retry_activity()
	# A fast inherited platform contribution cannot be repeatedly pumped by the
	# enhanced steering controller, whose voluntary target limit is only 8 m/s.
	t.step(0.02)
	base = body.snapshot().position-Vector3.UP*body.snapshot().shape.height*0.5
	a.transition_request = {"session":t.scope,"source":a.id,"support":"controlled-fast-platform","revision":8,"placement_serial":body.snapshot().serial,"linear":Vector3(20,0,0),"angular":Vector3.ZERO,"point":base,"center":base}
	t.check("fast platform sample admitted",true,t.motor.platform_velocity(a,a.transition_request).ok)
	t.trait_provider.enhanced_jumping = true
	t.trait_provider.revision += 1
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	t.key(KEY_D,true)
	t.step(0.02,5)
	t.key(KEY_D,false)
	t.near("enhanced control cannot pump inherited fast speed",20.0,body.air.velocity.x,0.00001)
	t.trait_provider.enhanced_jumping = false
	t.trait_provider.revision += 1
	t.finish_flight()
	t.motor.retry_activity()
	# Slow Fall is an explicit controlled MAGIC/CHAR projection. Expiry starts
	# a new segment at actual feet; no old peak can reappear.
	t.step(0.02)
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	t.trait_provider.slow_fall = true
	t.trait_provider.revision += 1
	t.step(0.02,8)
	t.check("Slow Fall active history protection",true,body.air.protections.has("@effect/slow-fall"))
	var slow_release: float = body.snapshot().position.y-body.snapshot().shape.height*0.5
	t.trait_provider.slow_fall = false
	t.trait_provider.revision += 1
	t.step(0.02)
	t.check("Slow Fall expiry removes only own protection",false,body.air.protections.has("@effect/slow-fall"))
	t.check("Slow Fall expiry starts at actual position",true,body.air.peak >= slow_release-0.00001 and body.air.peak <= slow_release+0.1)
	t.finish_flight()
	t.motor.retry_activity()
	t.trait_provider.slow_fall = true
	t.trait_provider.revision += 1
	var blocked_practice: int = t.actors.activity_projection(t.scope,"ground-player").practice.jumping
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	t.check("Slow Fall blocks ordinary fresh Jump",false,body.air.airborne)
	t.check("rejected protected Jump adds no practice",blocked_practice,t.actors.activity_projection(t.scope,"ground-player").practice.jumping)
	t.trait_provider.slow_fall = false
	t.trait_provider.revision += 1
	# Ordinary own-foot takeoff momentum is measured before the jump, independent
	# of later view and gait intent. Baseline adds no camera-forward boost.
	t.key(KEY_W,true)
	t.step(0.02,2)
	var own_momentum: Vector3 = body.ground_context(t.scope).velocity
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	t.key(KEY_W,false)
	t.shell_ref.session_shell.view.place_facing(t.scope,{"version":1,"yaw":90.0,"pitch":0.0})
	t.key(KEY_D,true)
	t.step(0.02)
	t.key(KEY_D,false)
	t.near("moving jump retains actual forward momentum",own_momentum.z,body.air.velocity.z,0.00001)
	t.near("looking cannot redirect ordinary momentum",own_momentum.x,body.air.velocity.x,0.00001)
	t.near("vanilla jump adds no forward boost",own_momentum.length(),Vector3(body.air.velocity.x,0,body.air.velocity.z).length(),0.00001)
	t.finish_flight()
	t.motor.retry_activity()
	t.shell_ref.session_shell.view.place_facing(t.scope,{"version":1,"yaw":0.0,"pitch":0.0})
	# Equal-time enhanced steering through the same resolved input and sweeps.
	for fps in [30,60,120]:
		t.trait_provider.enhanced_jumping = true
		t.trait_provider.revision += 1
		t.step(0.02)
		t.key(KEY_SPACE,true)
		t.step(0.02)
		t.key(KEY_SPACE,false)
		var steering_start: Vector3 = body.snapshot().position
		t.key(KEY_D,true)
		t.step(1.0/float(fps),int(fps/5))
		t.key(KEY_D,false)
		t.near("enhanced fps "+str(fps)+" velocity",2.4,body.air.velocity.x,0.0001)
		t.near("enhanced fps "+str(fps)+" displacement",0.24,body.snapshot().position.x-steering_start.x,0.0001)
		t.finish_flight()
		t.trait_provider.enhanced_jumping = false
		t.trait_provider.revision += 1
		t.motor.retry_activity()
	# A real overhead sweep cancels ascent. No downward reversal is introduced.
	var roof_origin: Vector3 = body.snapshot().position
	var roof: StaticBody3D = t.course.box(Vector3(roof_origin.x,2.2,roof_origin.z),Vector3(4,0.2,4),Color.ORANGE)
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	t.shell_ref.session_shell.focus_changed(true)
	t.key(KEY_SPACE,true)
	var ceiling_result: Dictionary = t.step(0.02)
	t.key(KEY_SPACE,false)
	var hit_ceiling := false
	var ceiling_y := 100.0
	for index in 100:
		ceiling_result = t.step(0.02)
		if ceiling_result.get("ceilings",0) > 0:
			hit_ceiling = true
			ceiling_y = body.air.velocity.y
			break
		if not body.air.airborne: break
	t.check("real ceiling contact observed",true,hit_ceiling)
	t.check("ceiling cancellation has no downward kick",true,ceiling_y <= 0.0 and ceiling_y >= -0.40001)
	t.finish_flight()
	roof.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	t.shell_ref.session_shell.focus_changed(true)
	t.motor.retry_activity()
	# Replace the controlled floor with a six-metre drop and a supporting island.
	# The player walks off using resolved input; no fixture writes actor pose.
	var island_center: Vector3 = body.snapshot().position
	t.course.box(Vector3(island_center.x,-0.1,island_center.z),Vector3(3,0.2,3),Color.BLUE)
	t.course.box(Vector3(0,-6.1,0),Vector3(80,0.2,80),Color.DARK_GREEN)
	for child in t.course.get_children():
		if child is StaticBody3D and child.position.y > -1.0:
			var shape: CollisionShape3D = child.get_child(0)
			if shape.shape is BoxShape3D and shape.shape.size.x == 80.0 and shape.shape.size.z == 80.0: child.queue_free()
	await t.shell_ref.get_tree().physics_frame
	await t.shell_ref.get_tree().physics_frame
	t.shell_ref.session_shell.focus_changed(true)
	var drop_health: int = t.actors.vital_projection(t.scope,"ground-player").current.health
	t.key(KEY_W,true)
	var departure := {}
	var support_samples_ok := true
	for index in 100:
		var support_point: Vector3 = body.snapshot().position-Vector3.UP*body.snapshot().shape.height*0.5
		a.transition_request = {"session":t.scope,"source":a.id,"support":"controlled-walkoff-platform","revision":200+index,"placement_serial":body.snapshot().serial,"linear":Vector3(1,0,0),"angular":Vector3(0,2,0),"point":support_point,"center":support_point-Vector3.RIGHT}
		support_samples_ok = support_samples_ok and t.motor.platform_velocity(a,a.transition_request).get("ok",false)
		departure = t.step(0.02)
		if body.air.airborne or not departure.get("ok",false): break
	t.key(KEY_W,false)
	t.check("real walk-off enters flight",true,body.air.airborne and departure.get("ok",false))
	t.check("walk-off retains actual horizontal momentum",true,absf(body.air.velocity.z) > 0.01)
	t.check("platform walk-off samples current",true,support_samples_ok)
	t.near("platform walk-off inherits translation",1.0,body.air.velocity.x,0.00001)
	t.near("platform walk-off inherits angular point motion",-175.0/39.5-2.0,body.air.velocity.z,0.005)
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	t.check("walk-off has no coyote jump","walk-off",body.air.takeoff.get("kind"))
	t.finish_flight()
	t.check("walk-off reaches real lower floor",true,not body.air.airborne and body.snapshot().position.y < -5.0)
	t.check("measured six metre fall damages through CHAR",drop_health-5,t.actors.vital_projection(t.scope,"ground-player").current.health)
	t.motor.retry_activity()
	# Real skill publication gives a capped high jump and an apex-based damaging
	# landing. CHAR remains the sole health writer; no direct actor pose is assigned.
	var cap: Dictionary = t.actors.ground_capabilities(t.scope,"ground-player")
	t.source_a.revision += 1
	t.source_a.contributions = [{"id":"high-jumping","kind":"skill","target":"jumping","value":1000000}]
	t.check("live high Jumping reconciles",true,t.actors.reconcile(t.scope,{},"ground-player",cap.revision,cap.content).ok)
	var health_before: int = t.actors.vital_projection(t.scope,"ground-player").current.health
	var optional_feedback: Array = [0]
	var failed_feedback := func(_outcome: Dictionary) -> bool:
		optional_feedback[0] += 1
		return false
	t.motor.landed.connect(failed_feedback)
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	t.near("valid high impulse caps",20.0,body.air.takeoff.get("impulse",-1.0),0.00001)
	var committed_impulse: float = body.air.velocity.y
	cap = t.actors.ground_capabilities(t.scope,"ground-player")
	t.source_a.revision += 1
	t.source_a.contributions = []
	t.check("live Jumping changes during flight",true,t.actors.reconcile(t.scope,{},"ground-player",cap.revision,cap.content).ok)
	t.near("live Jumping change cannot recompute impulse",committed_impulse,body.air.velocity.y,0.00001)
	t.finish_flight()
	var latest: Dictionary = body.air.outcomes.get("landing-"+str(body.air.segment),{})
	t.near("high jump apex counted in fall",10.0,latest.get("distance",-1.0),0.02)
	t.check("high jump real health loss",health_before-25,t.actors.vital_projection(t.scope,"ground-player").current.health)
	t.check("hard landing independent of feedback listener",true,latest.get("hard",false) and latest.get("damage") == 25)
	t.motor.retry_activity()
	var health_after: int = t.actors.vital_projection(t.scope,"ground-player").current.health
	t.motor.retry_landing()
	t.check("retained landing cannot repeat health",health_after,t.actors.vital_projection(t.scope,"ground-player").current.health)
	t.check("optional failed feedback cannot replay health",1,optional_feedback[0])
	t.motor.landed.disconnect(failed_feedback)
	# Next high landing exercises required CHAR prevention-directory failure and
	# exact retry. A ready empty controlled catalog proves no prevention, not MAGIC.
	prevention.ready = false
	cap = t.actors.ground_capabilities(t.scope,"ground-player")
	t.source_a.revision += 1
	t.source_a.contributions = [{"id":"high-jumping","kind":"skill","target":"jumping","value":1000000}]
	t.actors.reconcile(t.scope,{},"ground-player",cap.revision,cap.content)
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	t.finish_flight()
	t.check("required lethal provider failure retains landing",true,not body.air.pending.is_empty() and not t.actor_core.gates.simulation())
	var retained_request: Dictionary = t.motor._landing_request.duplicate(true)
	prevention.ready = true
	prevention.sources = []
	var dead: Dictionary = t.motor.retry_landing()
	t.check("lethal landing settles through real CHAR",true,dead.get("ok",false) and dead.get("outcome",{}).get("health",{}).get("phase") == "dead")
	t.check("lethal landing confirms real CORE death","dead",t.actor_core.snapshot().status)
	t.check("lethal health saturates once",0,t.actors.vital_projection(t.scope,"ground-player").current.health)
	t.check("lethal original request retained in CHAR","dead",t.actors.vital_intake(t.motor,retained_request).get("phase"))
