extends "res://tests/ground_cases.gd"
func check(id: String, expected: Variant, actual: Variant) -> void:
	super.check("air retirement "+id,expected,actual)

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var f := fixture.duplicate(true)
	f.reuse_ground_content = true
	f.ground_entry_id = "air-retirement-entry"
	if await bootstrap(shell,f):
		shell.session_shell.focus_changed(true)
		var original_scope: String = scope
		var emissions: Array = [0,0]
		var health_receipt: Array = [{}]
		var movement_observer := func(_r: Dictionary):
			if actor_core.snapshot().session != original_scope: emissions[0] += 1
		var failure_observer := func(_r: Dictionary):
			if actor_core.snapshot().session != original_scope: emissions[1] += 1
		var retirement_observer := func(r: Dictionary):
			if r.caller != "move-landings": return
			health_receipt[0] = r.duplicate(true)
			actor_core.request({"id":"air-landing-callback-return","mode":"return","origin":original_scope})
			if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		motor.committed.connect(movement_observer)
		motor.failed.connect(failure_observer)
		actors.vital_committed.connect(retirement_observer)
		key(KEY_SPACE,true)
		motor.physics_step(0.02)
		key(KEY_SPACE,false)
		for index in 300:
			if actor_core.snapshot().session != original_scope: break
			motor.physics_step(0.02)
		check("CHAR callback actually retires session",true,actor_core.snapshot().session != original_scope and not health_receipt[0].is_empty())
		check("no expired motion notification",0,emissions[0])
		check("no expired failure notification",0,emissions[1])
		check("required landing retained at scope teardown",true,motor.retired_work.has(original_scope) and motor.retired_work[original_scope].get("landing_request",{}).get("session") == original_scope)
		check("retired checkpoint cannot resume",false,motor.capture_air_state().get("ok",true))
		actors.vital_committed.disconnect(retirement_observer)
		motor.committed.disconnect(movement_observer)
		motor.failed.disconnect(failure_observer)
		source_a.callback = Callable()
		course.queue_free()
	var ok := true
	for item in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size()}
