extends "res://tests/ground_cases.gd"
func check(id: String, expected: Variant, actual: Variant) -> void:
	super.check("air exhaustion "+id,expected,actual)

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var f := fixture.duplicate(true)
	f.reuse_ground_content = true
	f.ground_entry_id = "air-exhaustion-entry"
	if await bootstrap(shell,f):
		shell.session_shell.focus_changed(true)
		var body: Node3D = shell.session_shell.placement
		step(0.02)
		motor.retry_activity()
		var cap: Dictionary = actors.vital_projection(scope,"ground-player")
		fatigue_source.active = {"schema":"vital-intake-v1","session":scope,"actor":"ground-player","caller":"ground-test-fatigue","operation":"jump-exhaustion-setup","content":cap.content,"revision":cap.revision,"action":"drain","pool":"fatigue","unit":"internal-64","amount":cap.current.fatigue-1,"attribution":{"source":"controlled-fatigue-setup","cause":"jump-exhaustion-boundary","component":"setup"}}
		check("one internal fatigue unit through CHAR",true,actors.vital_intake(fatigue_source,fatigue_source.active).ok)
		var position_before: Vector3 = body.snapshot().position
		var cursor_before: int = clock_provider.simulated
		var practice_before: int = actors.activity_projection(scope,"ground-player").practice.jumping
		key(KEY_SPACE,true)
		var result := step(0.02)
		key(KEY_SPACE,false)
		check("actual takeoff commits before exhaustion",true,result.get("takeoff_committed",false) and body.air.airborne)
		check("additional jump drain saturates",1,motor._jump_result.get("applied",-1))
		check("full additional jump cost recorded",11,motor._jump_result.get("requested",-1))
		check("jump practice committed once",practice_before+1,actors.activity_projection(scope,"ground-player").practice.jumping)
		check("no post-exhaustion flight time",cursor_before,clock_provider.simulated)
		check("takeoff impulse retained without unpaid travel",true,body.air.velocity.y > 0.0 and body.snapshot().position == position_before)
		check("jump receipt settled at exhaustion",true,motor._jump_debt.is_empty())
		var velocity_before: Vector3 = body.air.velocity
		check("exhaustion is retained suspension",true,step(0.02).get("suspended",false))
		check("exhaustion cannot replay impulse",velocity_before,body.air.velocity)
		motor.retry_activity()
		check("exhaustion cannot replay practice",practice_before+1,actors.activity_projection(scope,"ground-player").practice.jumping)
		check("known exhaustion recovery remains held",false,actor_core.gates.simulation())
		actor_core.request({"id":"air-exhaustion-return","mode":"return","origin":scope})
		if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		source_a.callback = Callable()
		course.queue_free()
	var ok := true
	for item in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size()}
