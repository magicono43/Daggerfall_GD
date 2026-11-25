extends "res://tests/ground_cases.gd"
## Human review only. Same SessionShell motor/body/CHAR and stock controls.
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	if not await bootstrap(shell,fixture): return {"ok":false,"reason":"Controlled review entry failed.","checks":checks,"count":checks.size()}
	source_a.callback = Callable()
	var controls: RefCounted = shell.controller.controls
	controls.begin()
	controls.set_response({"run_mode":"hold","sneak_mode":"hold"})
	var applied: Dictionary = controls.apply()
	if not applied.get("applied",false): return {"ok":false,"reason":"Review Hold defaults could not apply through Controls.","checks":checks,"count":checks.size()}
	shell.set_physics_process(true)
	var readout := Label.new()
	readout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	readout.position = Vector2(20,20)
	readout.add_theme_font_size_override("font_size",14)
	shell.add_child(readout)
	shell.render()
	var smoke: bool = fixture.get("review_smoke",false) == true
	var smoke_frames := 0
	var smoke_start: Vector3 = shell.session_shell.placement.snapshot().position
	if smoke:
		shell.session_shell.focus_changed(true)
		key(KEY_W,true)
	while shell.is_inside_tree():
		# Review-only presentation: expose the actual course during eligible play;
		# the unmodified stock Pause/Controls panel returns for every menu/hold.
		shell.panel.get_parent().get_parent().visible = not shell.session_shell.windows.top().is_empty() or not actor_core.gates.gameplay_input()
		var cap: Dictionary = actors.ground_capabilities(scope,"ground-player")
		var result: Dictionary = motor.last
		var practice: Dictionary = actors.activity_projection(scope,"ground-player").get("practice",{})
		readout.text = "GROUND REVIEW · controlled entry/LOC readiness/TIME/traits/restrictions\nReal input / view / capsule collision / CHAR / Controls\nWASD · left Shift Run · left Alt Sneak · middle mouse Autorun · Escape menu\nPause → Settings → Controls: independent Run/Sneak Hold or Toggle (starts Hold)\nCourse 80 × 80 m; north wall z=-20 m; white marks every 2 m\nGait %s · target %.3f m/s · actual %.3f m/s · fatigue %s · Running practice %s\n%s\nHuman review has no automatic PASS. Retention is by elapsed/context segments, not frames." % [result.get("gait",{}).get("gait","walk"),result.get("gait",{}).get("target_metres_per_second",0.0),result.get("actual_metres_per_second",0.0),str(actors.vital_projection(scope,"ground-player").get("current",{}).get("fatigue","unavailable")),str(practice.get("running","unavailable")),motor.reason]
		await shell.get_tree().process_frame
		if smoke:
			shell.session_shell.focus_changed(true)
			smoke_frames += 1
			if smoke_frames >= 60:
				key(KEY_W,false)
				check("ground review real physics advances",true,shell.session_shell.placement.snapshot().position.distance_to(smoke_start) > 0.01 and motor.last.has("gait"))
				check("ground review stock input reaches motor",true,motor.last.get("gait",{}).get("direction",Vector2.ZERO).length() > 0.0)
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					var image := shell.get_viewport().get_texture().get_image()
					image.save_png(sandbox.path_join("review-smoke.png"))
					check("ground review rendered course observed",true,not image.is_empty() and not shell.panel.get_parent().get_parent().visible)
				var ok := true
				for item in checks: ok = ok and item.expected == item.actual
				return {"ok":ok,"review_smoke":true,"checks":checks,"count":checks.size(),"frames":smoke_frames,"human_pass":false}
	return {"ok":false,"reason":"Human review has no automatic PASS.","checks":checks,"count":checks.size()}
