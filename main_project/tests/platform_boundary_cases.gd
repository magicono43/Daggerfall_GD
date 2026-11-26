extends RefCounted
func run(t: RefCounted, provider: RefCounted) -> void:
	var body: Node3D = t.shell_ref.session_shell.placement
	var view: RefCounted = t.shell_ref.session_shell.view
	provider.velocity = Vector3.ZERO
	provider.turn = 0.0
	var pose: Vector3 = body.snapshot().position
	var invalid := [{"revision":true},{"revision":provider.motion_revision},{"support":""},{"dimensions":Vector3(INF,1,1)},{"from":Transform3D(Basis.IDENTITY,Vector3(NAN,0,0))},{"to":Transform3D(Basis(Vector3.RIGHT,0.1),provider.geometry.position)}]
	for index in invalid.size():
		var bad: Dictionary = invalid[index]
		provider.sample_edits = bad
		t.check("malformed mechanism sample "+str(index),false,t.motor.mechanisms.prepare(t.motor._sequence+1,body.snapshot().serial,0.02).ok)
	provider.sample_edits.clear()
	t.check("rejected mechanism samples preserve pose",pose,body.snapshot().position)
	var nested: Array = [{}]
	provider.on_sample = func(): nested[0] = t.motor.physics_step(0.02)
	t.step(0.02)
	provider.on_sample = Callable()
	t.check("provider cannot reenter coordinated motion",true,nested[0].get("ok") == false and "reentrant" in nested[0].get("reason",""))
	var committed: int = provider.commit_count
	t.actor_core.gates.intended_rate = 0.0
	t.check("zero intended rate no provider advancement",true,t.step(0.02).get("rate_held",false) and provider.commit_count == committed)
	t.actor_core.gates.intended_rate = 1.0
	provider.velocity = Vector3(0.5,0,0)
	t.restriction_provider.voluntary = false
	t.restriction_provider.revision += 1
	var jumping_practice: int = t.actors.activity_projection(t.scope,"ground-player").practice.jumping
	t.key(KEY_SPACE,true)
	var rejected: Dictionary = t.step(0.02)
	t.key(KEY_SPACE,false)
	t.check("rejected Jump still carries current support",true,not body.air.airborne and not t.motor.mechanisms.attachment.is_empty() and rejected.get("passive_displacement",Vector3.ZERO).x > 0)
	t.check("rejected platform Jump no practice",jumping_practice,t.actors.activity_projection(t.scope,"ground-player").practice.jumping)
	t.restriction_provider.voluntary = true
	t.restriction_provider.revision += 1
	provider.velocity = Vector3.ZERO
	provider.velocity = Vector3(0,0.5,0)
	t.step(0.02)
	var rise_state: Dictionary = body.snapshot()
	var rise_base: float = rise_state.position.y-rise_state.shape.height*0.5
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	var expected_rise: float = (float(body.air.takeoff.get("impulse",0.0))+0.5)*0.02-10.0*0.02*0.02
	var jumped_state: Dictionary = body.snapshot()
	t.near("rising support jump never doubles carriage",expected_rise,jumped_state.position.y-jumped_state.shape.height*0.5-rise_base,0.001)
	t.check("rising support jump detaches actual history",true,body.air.airborne and t.motor.mechanisms.attachment.is_empty())
	provider.velocity = Vector3.ZERO
	t.finish_flight()
	t.motor.retry_activity()
	provider.velocity = Vector3(0,-0.5,0)
	t.step(0.02,2)
	provider.velocity = Vector3.ZERO
	# Actual held keyboard look and platform turning compose on the retained view.
	view.advance(0.001) # Consume any ordinary input fence before measuring.
	t.key(KEY_RIGHT,true)
	provider.turn = PI/6
	var yaw: float = view.facing.x
	for index in 30:
		t.step(1.0/60)
		view.advance(1.0/60)
	t.key(KEY_RIGHT,false)
	t.near("platform yaw plus actual concurrent look",30.0,wrapf(view.facing.x-yaw,-180,180),0.001)
	provider.turn = 0.0
	# Walk off with current support motion, then use actual ordinary step/reboard.
	# Raise above the accepted 0.50 m downward-follow allowance first; walking
	# off a 0.50 m platform is correctly a supported step, rather than a fall.
	provider.velocity = Vector3(0,0.5,0)
	t.step(0.02,40)
	provider.velocity = Vector3(1,0,0)
	t.key(KEY_W,true)
	for index in 300:
		var result: Dictionary = t.step(0.02)
		if body.air.airborne or not result.ok: break
	t.key(KEY_W,false)
	t.check("walk-off immediately detaches",true,body.air.airborne and t.motor.mechanisms.attachment.is_empty())
	t.check("walk-off inherits current platform once",true,Vector2(body.air.velocity.x,body.air.velocity.z).length() > 0.1)
	provider.velocity = Vector3.ZERO
	t.finish_flight()
	t.motor.retry_activity()
	provider.velocity = Vector3(0,-0.5,0)
	t.step(0.02,40)
	provider.velocity = Vector3.ZERO
	var push_direction: Vector3 = body.snapshot().position-provider.geometry.position
	push_direction.y = 0
	provider.velocity = push_direction.normalized()*0.5
	var prior_steps: int = t.motor.feedback.steps
	var prior_practice: int = t.actors.activity_projection(t.scope,"ground-player").practice.running
	var pushed := false
	for index in 300:
		var result: Dictionary = t.step(0.02)
		if not result.ok: break
		if result.get("passive_displacement",Vector3.ZERO).length() > 0.000001:
			pushed = true
			break
	t.check("actual moving side geometry pushes",true,pushed)
	t.check("external push creates no walking steps",prior_steps,t.motor.feedback.steps)
	t.motor.retry_activity()
	t.check("external push creates no Running practice",prior_practice,t.actors.activity_projection(t.scope,"ground-player").practice.running)
	provider.velocity = Vector3.ZERO
	var toward: Vector3 = provider.geometry.position-body.snapshot().position
	view.place_facing(t.scope,{"version":1,"yaw":rad_to_deg(atan2(toward.x,-toward.z)),"pitch":0.0})
	t.key(KEY_W,true)
	for index in 300:
		var result: Dictionary = t.step(0.02)
		if not t.motor.mechanisms.attachment.is_empty() or not result.ok: break
	t.key(KEY_W,false)
	t.check("actual walking reboards",true,not t.motor.mechanisms.attachment.is_empty())
	t.step(0.02)
	t.motor.retry_activity()
	# Angular cross-radius at the actual detachment point, above ordinary steering
	# speed; no already-applied carry is added at takeoff.
	provider.turn = 5.0
	t.trait_provider.enhanced_jumping = true
	t.trait_provider.revision += 1
	var state: Dictionary = body.snapshot()
	var foot: Vector3 = state.position-Vector3.UP*state.shape.height*0.5
	var prior: Vector3 = body.ground_context(t.scope).velocity
	var inherited: Vector3 = Vector3.UP*5.0
	inherited = inherited.cross(foot-provider.geometry.position)
	t.key(KEY_SPACE,true)
	t.step(0.02)
	t.key(KEY_SPACE,false)
	var expected := Vector2(prior.x+inherited.x,prior.z+inherited.z)
	var actual := Vector2(body.air.velocity.x,body.air.velocity.z)
	t.near("rapid turn jump actual angular point velocity",0,actual.distance_to(expected),0.001)
	t.check("already-fast inherited motion retained",true,actual.length() > t.motor.air_policy.steering_speed)
	provider.turn = 0.0
	t.step(0.02)
	t.near("enhanced flight cannot amplify fast inheritance",0,Vector2(body.air.velocity.x,body.air.velocity.z).distance_to(actual),0.001)
	t.trait_provider.enhanced_jumping = false
	t.trait_provider.revision += 1
	t.step(0.02)
	t.near("effect loss retains actual inherited momentum",0,Vector2(body.air.velocity.x,body.air.velocity.z).distance_to(actual),0.001)
	t.finish_flight()
	t.motor.retry_activity()
	provider.valid = false
	var retired_pose: Vector3 = body.snapshot().position
	t.check("retired provider fails closed",false,t.motor.physics_step(0.02).get("ok",true))
	t.check("retirement detaches without pulling player",true,t.motor.mechanisms.attachment.is_empty() and body.snapshot().position == retired_pose)
	provider.valid = true
