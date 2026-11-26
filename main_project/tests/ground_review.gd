extends "res://tests/ground_cases.gd"
## Human review only. Same SessionShell motor/body/CHAR and stock controls.
func review_presentation(shell: Control, readout: Label) -> void:
	var menu_visible: bool = not shell.session_shell.windows.top().is_empty() or not actor_core.gates.gameplay_input()
	shell.panel.get_parent().get_parent().visible = menu_visible
	readout.visible = not menu_visible

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var review_prevention := preload("res://tests/controlled_prevention.gd").new()
	review_prevention.ready = true
	review_prevention.sources = []
	extra_services = [review_prevention.binding()]
	fixture = fixture.duplicate(true)
	fixture.air_player = true
	var mechanism: RefCounted
	if fixture.get("review_platforms",false):
		fixture.mechanism_course = true
		mechanism = preload("res://tests/controlled_mechanism.gd").new("controlled-review-mechanism","MOVE",["motion"])
		extra_services.append(mechanism.binding())
	if not await bootstrap(shell,fixture): return {"ok":false,"reason":"Controlled review entry failed.","checks":checks,"count":checks.size()}
	source_a.callback = Callable()
	var mechanism_controls: VBoxContainer
	if mechanism != null:
		mechanism.geometry = course.get_node("ControlledMechanism")
		mechanism.limits = {"minimum":Vector3(-6,0.25,-6),"maximum":Vector3(6,1.9,6)}
		course.box(Vector3(0,2.6,0),Vector3(20,0.2,20),Color.ORANGE)
		course.label_at("MECHANISM COURSE\nOrange roof underside 2.50 m\nEscape sideways before compression",Vector3(0,3.4,-5))
		course.box(Vector3(13,1.5,0),Vector3(0.2,3,12),Color.FIREBRICK)
		# Separate ordinary half-metre steps, beyond the mechanism roof, provide
		# a hard but normally non-damaging landing for independent feedback review.
		for index in 6:
			var rise: float = (index+1)*0.5
			course.box(Vector3(0,rise*0.5,12+index),Vector3(4,rise,1),Color.SKY_BLUE)
		course.box(Vector3(0,1.5,18),Vector3(4,3,2),Color.STEEL_BLUE)
		course.label_at("FEEDBACK DROP: 6 x 0.50 m steps\n3 m platform beyond orange roof\nWalk off a side; camera Off / On",Vector3(0,2,11))
		await shell.get_tree().physics_frame
		await shell.get_tree().physics_frame
		var binding: Dictionary = motor.bind_mechanism(mechanism,mechanism.id,"grounded-crush")
		if not binding.ok: return {"ok":false,"reason":binding.reason,"checks":checks,"count":checks.size()}
		mechanism_controls = VBoxContainer.new()
		mechanism_controls.position = Vector2(920,360)
		shell.add_child(mechanism_controls)
		for command in ["Ride east 0.5 m/s","Ride west 0.5 m/s","Turn 30 degrees/s","Raise 0.25 m/s (crush hazard)","Lower 0.25 m/s","Stationary mechanism"]:
			var button := Button.new()
			button.text = command
			mechanism_controls.add_child(button)
			var command_action := func():
				mechanism.velocity = Vector3.ZERO
				mechanism.turn = 0.0
				match command:
					"Ride east 0.5 m/s": mechanism.velocity = Vector3(0.5,0,0)
					"Ride west 0.5 m/s": mechanism.velocity = Vector3(-0.5,0,0)
					"Turn 30 degrees/s": mechanism.turn = PI/6
					"Raise 0.25 m/s (crush hazard)": mechanism.velocity = Vector3(0,0.25,0)
					"Lower 0.25 m/s": mechanism.velocity = Vector3(0,-0.25,0)
			button.pressed.connect(command_action)
	var controls: RefCounted = shell.controller.controls
	controls.begin()
	controls.set_response({"run_mode":"hold","sneak_mode":"hold","crouch_mode":"toggle"})
	var applied: Dictionary = controls.apply()
	if not applied.get("applied",false): return {"ok":false,"reason":"Review Hold defaults could not apply through Controls.","checks":checks,"count":checks.size()}
	if fixture.has("connector_model"):
		# Face along the corridor incline so a steep floor does not fill the view
		# at entry. This changes only view facing through its normal owner.
		shell.session_shell.view.place_facing(scope,{"version":1,"yaw":0.0,"pitch":-rad_to_deg(atan2(course.rise,course.run_metres))})
	shell.set_physics_process(true)
	var readout := Label.new()
	readout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	readout.position = Vector2(20,20)
	readout.add_theme_font_size_override("font_size",14)
	shell.add_child(readout)
	shell.render()
	var smoke: bool = fixture.get("review_smoke",false) == true
	var smoke_frames := 0
	var saw_crouch := false
	var saw_air := false
	var smoke_start: Vector3 = shell.session_shell.placement.snapshot().position
	if smoke:
		if mechanism != null: mechanism.velocity = Vector3(0.5,0,0)
		shell.session_shell.focus_changed(true)
		key(KEY_CTRL,true)
		key(KEY_CTRL,false)
		key(KEY_W,true)
	while shell.is_inside_tree():
		# Review-only presentation: expose the actual course during eligible play;
		# the unmodified stock Pause/Controls panel returns for every menu/hold.
		review_presentation(shell,readout)
		var cap: Dictionary = actors.ground_capabilities(scope,"ground-player")
		var result: Dictionary = motor.last
		if mechanism_controls != null: mechanism_controls.visible = not motor.scope.is_empty() and actor_core.snapshot().status == "alive" and not shell.session_shell.windows.top().is_empty() and shell.session_shell.quit_phase.is_empty()
		var practice: Dictionary = actors.activity_projection(scope,"ground-player").get("practice",{})
		var course_hint := "Orange roofs left / blue stairs right / gold slopes beyond / green passages ahead"
		if fixture.has("connector_model"): course_hint = "Orange: original steep corridor floor. Grey: original walls and roof. Blue: test landing."
		if fixture.get("connector_full_block",false): course_hint = "Orange: selected original corridor floor. Explore its original joining passages; mechanisms are inactive."
		if mechanism != null: course_hint = "PLATFORMS: Escape → choose a mechanism command on right → Resume. Walk off / reboard / Jump. Raise is lethal if you remain trapped."
		readout.text = "GROUND REVIEW · controlled entry/LOC readiness/TIME/traits/restrictions\nReal input / view / capsule collision / CHAR / Controls\nWASD / left Ctrl Crouch / left Shift Run · left Alt Sneak · middle mouse Autorun · Escape menu\nPause → Settings → Controls: independent Crouch/Run/Sneak Hold or Toggle\n%s\nGait %s · target %.3f m/s · actual %.3f m/s · fatigue %s · Running practice %s\n%s\nHuman review has no automatic PASS. Retention is by elapsed/context segments, not frames." % [course_hint,result.get("gait",{}).get("gait","walk"),result.get("gait",{}).get("target_metres_per_second",0.0),result.get("actual_metres_per_second",0.0),str(actors.vital_projection(scope,"ground-player").get("current",{}).get("fatigue","unavailable")),str(practice.get("running","unavailable")),motor.reason]
		if fixture.has("connector_model") and not fixture.get("connector_full_block",false):
			readout.text += "\nORIGINAL CORRIDOR %d: walk uphill to the blue landing, then turn and descend.\nRepeat with Run, Sneak and Crouch. Check entry/exit seams and side walls." % int(fixture.connector_model)
		if fixture.get("connector_full_block",false):
			readout.text += "\nSOURCE BLOCK %s · original surrounding model geometry · doors/mechanisms inactive" % str(fixture.get("connector_source_placement",""))
		readout.text += "\nPosture %s · desired %s · pending stand %s\nCHAR recovery exists; this course lacks real TIME/threat handoffs. Exhaustion remains held." % [result.get("posture",{}).get("actual","standing"),result.get("posture",{}).get("desired","standing"),str(result.get("posture",{}).get("pending_stand",false))]
		var physical: Node3D = shell.session_shell.placement
		var landing: Dictionary = physical.air.outcomes.get("landing-"+str(physical.air.segment),{})
		readout.text += "\nSPACE Jump · mode %s · vertical %.2f m/s · health %s · Jumping practice %s\nLast landing: %.3f reference m · damage %s · hard feedback %s" % ["air" if physical.air.airborne else "ground",physical.air.velocity.y,str(actors.vital_projection(scope,"ground-player").get("current",{}).get("health","unavailable")),str(practice.get("jumping",0)),landing.get("distance",0.0),str(landing.get("damage",0)),str(landing.get("hard",false))]
		if mechanism != null: readout.text += "\nVoluntary %.3f m · passive %.3f m · stride %.3f · audible submitted %d\nControls: gait/mounted/landing camera intensity; 0 = Off. Audio intensity is independent." % [result.get("surface_distance",0.0),result.get("passive_displacement",Vector3.ZERO).length(),motor.feedback.phase,shell.session_shell.movement_audio.submitted]
		await shell.get_tree().process_frame
		if smoke:
			shell.session_shell.focus_changed(true)
			smoke_frames += 1
			saw_crouch = saw_crouch or shell.session_shell.placement.snapshot().physical.posture == "crouched"
			saw_air = saw_air or physical.air.airborne
			if smoke_frames == 30:
				key(KEY_CTRL,true)
				key(KEY_CTRL,false)
				if not fixture.has("connector_model"): key(KEY_SPACE,true)
			if smoke_frames == 31: key(KEY_SPACE,false)
			if smoke_frames >= 60:
				key(KEY_W,false)
				check("ground review actual crouch observed",true,saw_crouch)
				check("ground review actual stand observed","standing",shell.session_shell.placement.snapshot().physical.posture)
				if not fixture.has("connector_model"): check("ground review actual air observed",true,saw_air)
				check("ground review real physics advances",true,shell.session_shell.placement.snapshot().position.distance_to(smoke_start) > 0.01 and motor.last.has("gait"))
				check("ground review stock input reaches motor",true,motor.last.get("gait",{}).get("direction",Vector2.ZERO).length() > 0.0)
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					var image := shell.get_viewport().get_texture().get_image()
					image.save_png(sandbox.path_join("review-smoke.png"))
					check("ground review rendered course observed",true,not image.is_empty() and not shell.panel.get_parent().get_parent().visible)
				shell.session_shell.pause()
				review_presentation(shell,readout)
				check("ground review menu hides diagnostics",true,shell.panel.get_parent().get_parent().visible and not readout.visible)
				shell.session_shell.request_quit()
				shell.render()
				review_presentation(shell,readout)
				check("ground review quit consent unobscured",true,shell.session_shell.quit_phase == "confirmation" and shell.panel.get_parent().get_parent().visible and not readout.visible)
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join("review-quit.png"))
				shell.session_shell.cancel_quit()
				var ok := true
				for item in checks: ok = ok and item.expected == item.actual
				return {"ok":ok,"review_smoke":true,"checks":checks,"count":checks.size(),"frames":smoke_frames,"human_pass":false}
	return {"ok":false,"reason":"Human review has no automatic PASS.","checks":checks,"count":checks.size()}
