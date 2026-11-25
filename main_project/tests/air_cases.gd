extends "res://tests/ground_cases.gd"
## Real input, body sweeps, CHAR and RULE; explicit controlled owner suppliers.
func check(id: String, expected: Variant, actual: Variant) -> void:
	super.check("air "+id,expected,actual)

func finish_flight(dt := 0.02) -> Dictionary:
	var result := {}
	for index in 1200:
		result = step(dt)
		if not result.get("ok",false) or result.get("suspended",false) or not shell_ref.session_shell.placement.air.airborne: break
	return result

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var f := fixture.duplicate(true)
	f.reuse_ground_content = fixture.get("reuse_ground_content",false)
	f.ground_entry_id = "air-entry"
	f.air_player = true
	var support_a := Supplier.new("controlled-air-support-a","MOVE",["motion"])
	var support_b := Supplier.new("controlled-air-support-b","MOVE",["motion"])
	var prevention := preload("res://tests/controlled_prevention.gd").new()
	extra_services = [support_a.binding(),support_b.binding(),prevention.binding()]
	if await bootstrap(shell,f):
		var body: Node3D = shell.session_shell.placement
		var controls: RefCounted = shell.controller.controls
		var previous_response: Dictionary = controls.effective().response.duplicate(true)
		controls.begin()
		controls.set_response({"run_mode":"hold","sneak_mode":"hold","crouch_mode":"toggle"})
		controls.apply()
		shell.session_shell.focus_changed(true)
		var baseline: Dictionary = actors.ground_capabilities(scope,"ground-player")
		var impulse: float = 4.5*(1.0+float(baseline.jumping)/200.0)
		for dt in [1.0/30.0,1.0/60.0,1.0/120.0]:
			var label := "timestep "+str(int(round(1.0/dt)))+" "
			step(0.02)
			motor.retry_activity()
			var base_y: float = body.snapshot().position.y-body.snapshot().shape.height*0.5
			var before_practice: int = actors.activity_projection(scope,"ground-player").practice.jumping
			key(KEY_SPACE,true)
			var result := step(dt)
			check(label+"fresh Jump starts flight",true,result.get("ok",false) and body.air.airborne)
			near(label+"latched impulse",impulse,body.air.takeoff.get("impulse",-1.0),0.00001)
			var peak: float = body.air.peak
			for index in 200:
				result = step(dt)
				peak = maxf(peak,body.air.peak)
				if not body.air.airborne or not result.get("ok",false) or result.get("suspended",false): break
			check(label+"landing settles through CHAR",true,not body.air.airborne and body.air.pending.is_empty() and body.air.outcomes.size() > 0)
			near(label+"apex metres",impulse*impulse/40.0,peak-base_y,0.003)
			check(label+"jump practice once",before_practice+1,actors.activity_projection(scope,"ground-player").practice.jumping)
			check(label+"jump base cost once",11,motor._jump_result.get("requested",-1))
			var count: int = body.air.outcomes.size()
			step(dt,20)
			check(label+"held Jump does not repeat",count,body.air.outcomes.size())
			key(KEY_SPACE,false)
			measurements.append({"case":label+"trajectory","impulse_metres_per_second":impulse,"gravity_metres_per_second_squared":20.0,"expected_apex_metres":impulse*impulse/40.0,"actual_apex_metres":peak-base_y,"tolerance_metres":0.003})
		key(KEY_CTRL,true)
		key(KEY_CTRL,false)
		step(0.02)
		var crouched_base: float = body.snapshot().position.y-body.snapshot().shape.height*0.5
		key(KEY_SPACE,true)
		step(0.02)
		key(KEY_SPACE,false)
		near("actual crouch takeoff impulse",impulse*0.8,body.air.takeoff.get("impulse",-1.0),0.00001)
		key(KEY_CTRL,true)
		key(KEY_CTRL,false)
		var before_resize: float = body.snapshot().position.y-body.snapshot().shape.height*0.5
		step(0.02)
		check("airborne resize preserves flight identity",true,body.air.airborne and body.snapshot().physical.posture == "standing" and body.air.peak >= before_resize)
		finish_flight()
		var crouched_peak: float = body.air.peak
		near("crouched trajectory metre apex",pow(impulse*0.8,2)/40.0,crouched_peak-crouched_base,0.003)
		step(0.02)
		key(KEY_SPACE,true)
		step(0.02)
		key(KEY_SPACE,false)
		motor.retry_activity()
		var checkpoint: Dictionary = motor.capture_air_state()
		var hold: int = actor_core.gates.acquire("air-test-pause",scope,["simulation","save"])
		var paused: Dictionary = body.snapshot()
		check("pause suspends flight",true,step(0.1).get("suspended",false))
		check("pause retains pose and velocity",paused,body.snapshot())
		var changed_checkpoint: Dictionary = checkpoint.duplicate(true)
		changed_checkpoint.air.peak = -1000.0
		check("restore cannot erase unresolved peak",false,motor.restore_air_state(changed_checkpoint).get("ok",true))
		check("settled owner snapshot restore",true,motor.restore_air_state(checkpoint).get("ok",false))
		check("snapshot explicitly excludes native SAVE",false,checkpoint.get("native_save_ready",true))
		actor_core.gates.release(hold,"air-test-pause")
		key(KEY_SPACE,true) # Rejected airborne press must expire.
		step(0.02)
		key(KEY_SPACE,false)
		finish_flight()
		var landed_count: int = body.air.outcomes.size()
		step(0.02,20)
		check("rejected airborne press has no landing buffer",landed_count,body.air.outcomes.size())
		motor.retry_activity()
		check("duplicate landing retry unchanged",true,motor.retry_landing().get("unchanged",false))
		check("jump debt fully settled",true,motor._jump_debt.is_empty())
		check("flight capsules remain clear",true,committed_capsules_clear)
		await preload("res://tests/air_boundary_cases.gd").new().run(self,support_a,support_b,prevention)
		controls.begin()
		var staged: Dictionary = controls.set_response({"run_mode":previous_response.run_mode,"sneak_mode":previous_response.sneak_mode,"crouch_mode":previous_response.crouch_mode})
		var restored: Dictionary = controls.apply()
		check("prior Controls preferences restored",true,staged.get("ok",false) and restored.get("applied",false) and controls.effective().response == previous_response)
		actor_core.request({"id":"air-return","mode":"return","origin":scope})
		if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		source_a.callback = Callable()
		course.queue_free()
	var ok := true
	for item in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size(),"measurements":measurements}
