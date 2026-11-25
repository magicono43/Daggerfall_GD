extends "res://tests/ground_cases.gd"
## Human-discovered pinch contact: actual course, resolved Jump, same MOVE body.
func check(id: String, expected: Variant, actual: Variant) -> void:
	super.check("air contact "+id,expected,actual)

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var f := fixture.duplicate(true)
	f.mode = "ground-review"
	f.air_player = true
	f.ground_entry_id = "air-passage-entry"
	if await bootstrap(shell,f):
		shell.session_shell.focus_changed(true)
		var body: Node3D = shell.session_shell.placement
		key(KEY_W,true)
		for index in 160:
			if body.snapshot().position.z <= -13.0: break
			if not step(0.02).get("ok",false): break
		check("air passage reaches narrow approach",true,body.snapshot().position.z < -12.8)
		key(KEY_SPACE,true)
		step(0.02)
		key(KEY_SPACE,false)
		for index in 100:
			var result := step(0.02)
			if not result.get("ok",false) or result.get("suspended",false):
				print("AIR PASSAGE RECOVERY ",result," pose ",body.snapshot()," history ",body.air.velocity)
				break
		key(KEY_W,false)
		check("air narrow passage blocks without recovery",true,actor_core.gates.safe and motor.reason.is_empty())
		check("air narrow passage keeps capsule outside",true,body.snapshot().position.z > -15.0)
		check("air narrow passage lands",false,body.air.airborne)
		check("air narrow passage capsule remains clear",true,committed_capsules_clear)
		for fps in [30,60,120]:
			var remained_safe := true
			var saw_contact := false
			key(KEY_W,true)
			key(KEY_SPACE,true)
			step(1.0/fps)
			key(KEY_SPACE,false)
			for index in fps*2:
				var result := step(1.0/fps)
				remained_safe = remained_safe and result.get("ok",false) and not result.get("suspended",false)
				saw_contact = saw_contact or result.get("collisions",0) > 0
				if not remained_safe: break
			key(KEY_W,false)
			check("air pinch %d fps continues" % fps,true,remained_safe and actor_core.gates.safe)
			check("air pinch %d fps actual contact" % fps,true,saw_contact)
			check("air pinch %d fps lands" % fps,false,body.air.airborne)
			check("air pinch %d fps cannot pass" % fps,true,body.snapshot().position.z > -15.0)
		check("air repeated pinch capsules remain clear",true,committed_capsules_clear)
		key(KEY_S,true)
		step(0.02,20)
		key(KEY_S,false)
		check("air pinch can walk away",true,body.snapshot().position.z > -14.0)
		# Exercise stock recovery Quit independently from collision success. Stop
		# before process exit at the normal preferences failure/retry boundary.
		actor_core.required_service_lost(scope,"air-contact-fixture")
		shell.render()
		shell.session_shell.request_quit()
		check("air recovery quit offers consent","confirmation",shell.session_shell.quit_phase)
		shell.session_shell.cancel_quit()
		shell.controller.storage.adapter.faults.settings_stage = true
		var settings: StartupSettingsOwner = shell.controller.settings
		var previous_setup: bool = settings.value(settings.accepted,"startup/show_setup")
		settings.apply({"startup/show_setup":not previous_setup})
		shell.session_shell.request_quit()
		shell.render()
		press_control("Discard and Quit")
		await shell.get_tree().process_frame
		await shell.get_tree().process_frame
		check("air recovery quit tears down scope",true,actor_core.snapshot().session.is_empty())
		check("air recovery quit reaches preferences","preferences",shell.session_shell.quit_phase)
		# Prevent the deferred exit while the maintained runner publishes evidence.
		# Test cleanup only: return the completed teardown's preferences hold to
		# the normal cancellation path so subsequent independent fixtures can enter.
		shell.session_shell.quit_phase = "waiting"
		shell.session_shell.cancel_quit()
		shell.controller.storage.adapter.faults.erase("settings_stage")
		settings.apply({"startup/show_setup":previous_setup})
		source_a.callback = Callable()
		course.queue_free()
	var ok := true
	for item in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size()}
