extends "res://tests/air_cases.gd"
## Real production input/body/CHAR/view with a scoped controlled mechanism owner.
func check(id: String, expected: Variant, actual: Variant) -> void:
	# Avoid the inherited air label for this independently inventoried selection.
	super.check(id,expected,actual)
	checks[-1].scenario = "platform "+id

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var provider := preload("res://tests/controlled_mechanism.gd").new("controlled-mechanism","MOVE",["motion"])
	var prevention := preload("res://tests/controlled_prevention.gd").new()
	prevention.ready = true
	prevention.sources = []
	extra_services = [provider.binding(),prevention.binding()]
	var f := fixture.duplicate(true)
	f.mechanism_course = true
	f.air_player = true
	f.ground_entry_id = "platform-entry"
	if await bootstrap(shell,f):
		var controls: RefCounted = shell.controller.controls
		var previous: Dictionary = controls.effective().response.duplicate(true)
		controls.begin()
		controls.set_response({"gait_bob_percent":50.0,"mounted_bob_percent":50.0,"landing_camera_percent":0.0,"movement_audio_percent":100.0})
		controls.apply()
		provider.geometry = course.get_node("ControlledMechanism")
		var body: Node3D = shell.session_shell.placement
		var view: RefCounted = shell.session_shell.view
		shell.session_shell.focus_changed(true)
		step(0.02)
		motor.retry_activity()
		check("current mechanism binds",true,motor.bind_mechanism(provider,provider.id,"grounded-crush").ok)
		var practice: int = actors.activity_projection(scope,"ground-player").practice.running
		var initial: Vector3 = body.snapshot().position
		provider.velocity = Vector3(1,0,0)
		for dt in [1.0/30,1.0/60,1.0/120]:
			var start: Vector3 = body.snapshot().position
			var started := Time.get_ticks_usec()
			var result := step(dt,int(round(1.0/dt)))
			measurements.append({"case":"coordinated-platform-translation","eligible_timestep_seconds":dt,"eligible_seconds":1.0,"elapsed_usec":Time.get_ticks_usec()-started,"last_update_slices":result.get("mechanism_slices",0)})
			check("translation success "+str(dt),true,result.get("ok",false))
			near("translation metres "+str(dt),1.0,body.snapshot().position.x-start.x,0.0001)
			near("passive no voluntary distance "+str(dt),0,result.get("surface_distance",-1.0),0.000001)
		check("passive practice unchanged",practice,actors.activity_projection(scope,"ground-player").practice.running)
		near("passive three seconds metres",3.0,body.snapshot().position.x-initial.x,0.0002)
		check("passive no footsteps",0,motor.feedback.steps)
		provider.velocity = Vector3.ZERO
		provider.turn = PI/2
		var before: Vector3 = body.snapshot().position
		var relative: Vector3 = before-provider.geometry.position
		var yaw_before: float = view.facing.x
		var turn_result := step(1.0/60,60)
		if not turn_result.get("gait",{}).size() > 0: print("PLATFORM TURN FAILURE ",motor.last," geometry ",provider.geometry.transform)
		var after: Vector3 = body.snapshot().position
		near("yaw attachment point",0,(after-provider.geometry.position-relative.rotated(Vector3.UP,PI/2)).length(),0.0002)
		near("yaw actual retained facing",0,wrapf(view.facing.x-yaw_before+90,-180,180),0.0001)
		view.advance(0.02)
		near("look update no snapback",0,wrapf(view.facing.x-yaw_before+90,-180,180),0.0001)
		near("upright capsule",0,body._actor.basis.y.distance_to(Vector3.UP),0.000001)
		provider.turn = 0.0
		provider.velocity = Vector3(0.5,0,0)
		var observed_cues: Array = []
		var observe_cue := func(event): observed_cues.append(event)
		motor.feedback.cue.connect(observe_cue)
		key(KEY_W,true)
		var walked := step(0.02,30)
		key(KEY_W,false)
		check("relative walking actual voluntary",true,walked.get("surface_distance",0.0) > 0.05 and walked.passive_displacement.x > 0)
		check("physical on-foot cue reaches actual playback",true,shell.session_shell.movement_audio.submitted > 0 and shell.session_shell.movement_audio.stream != null)
		var audio_hold: int = actor_core.gates.acquire("movement-audio-pause",scope,["simulation"])
		shell.session_shell.advance_actor_presentation(0.1)
		check("CORE pause reaches every actual movement voice",true,shell.session_shell.movement_audio._voices.all(func(voice): return voice.stream == null or voice.stream_paused))
		actor_core.gates.release(audio_hold,"movement-audio-pause")
		actor_core.gates.intended_rate = 0.0
		shell.session_shell.advance_actor_presentation(0.1)
		check("zero intended rate pauses actual audio",true,shell.session_shell.movement_audio._voices.all(func(voice): return voice.stream == null or voice.stream_paused))
		actor_core.gates.intended_rate = 1.0
		var resumed_submissions: int = shell.session_shell.movement_audio.submitted
		shell.session_shell.advance_actor_presentation(0.1)
		check("eligible resume never replays completed cues",true,shell.session_shell.movement_audio.submitted == resumed_submissions and shell.session_shell.movement_audio._voices.all(func(voice): return not voice.stream_paused))
		motor.feedback.cue.disconnect(observe_cue)
		var consumer_pose: Vector3 = body.snapshot().position
		var consumer_vitals: Dictionary = actors.vital_projection(scope,"ground-player").current
		controls.begin()
		controls.set_response({"movement_audio_percent":35.0})
		controls.apply()
		check("actual audio consumer replacement",true,shell.session_shell.replace_movement_audio().get("ok",false))
		if not observed_cues.is_empty(): shell.session_shell.movement_audio.present(observed_cues[0])
		check("replacement rejects queued old cue",0,shell.session_shell.movement_audio.submitted)
		check("replacement cannot change physical or vital state",true,consumer_pose == body.snapshot().position and consumer_vitals == actors.vital_projection(scope,"ground-player").current)
		check("replacement reapplies effective audio gain",0.35,shell.session_shell.movement_audio.gain)
		controls.begin()
		controls.set_response({"movement_audio_percent":100.0})
		controls.apply()
		key(KEY_S,true)
		step(0.02,20)
		key(KEY_S,false)
		controls.begin()
		controls.set_response({"gait_bob_percent":0.0})
		controls.apply()
		var before_audio: int = shell.session_shell.movement_audio.submitted
		shell.session_shell.movement_audio.advance(0.11,true) # Controlled eligible presentation interval.
		key(KEY_S,true)
		step(0.02,10)
		key(KEY_S,false)
		check("gait Off leaves actual audio available",true,view.cosmetic_offset == Vector3.ZERO and shell.session_shell.movement_audio.submitted > before_audio)
		controls.begin()
		controls.set_response({"gait_bob_percent":50.0})
		controls.apply()
		key(KEY_W,true)
		step(0.02,3)
		var cursor_pose: Vector3 = body.snapshot().position
		var cursor_facing: Vector2 = view.facing
		before_audio = shell.session_shell.movement_audio.submitted
		shell.session_shell.movement_audio.advance(0.11,true)
		check("actual gameplay cursor enters",true,view.toggle())
		step(0.02,30)
		key(KEY_W,false)
		check("cursor motion audio continues",true,body.snapshot().position.distance_to(cursor_pose) > 1.5 and shell.session_shell.movement_audio.submitted > before_audio)
		check("cursor bob eases neutral on actual camera",true,view.cosmetic_offset.length() < 0.00001 and shell.session_shell.view_camera.position.distance_to(motor.last.view_position) < 0.00001 and view.facing == cursor_facing)
		view.toggle()
		key(KEY_S,true)
		step(0.02,33)
		key(KEY_S,false)
		motor.retry_activity()
		var hold: int = actor_core.gates.acquire("platform-pause",scope,["simulation","save"])
		var checkpoint: Dictionary = motor.capture_ground_state()
		var position: Vector3 = body.snapshot().position
		var mechanism_position := provider.geometry.transform
		step(0.1,5)
		check("pause freezes both owners",true,body.snapshot().position == position and provider.geometry.transform == mechanism_position)
		check("gated current checkpoint restore",true,motor.restore_ground_state(checkpoint).get("ok",false))
		provider.velocity = Vector3(0.25,0,0)
		check("changed mechanism trajectory checkpoint rejects",false,motor.restore_ground_state(checkpoint).get("ok",true))
		provider.velocity = Vector3(0.5,0,0)
		var invalid_state := checkpoint.duplicate(true)
		invalid_state.mechanism.provider_state.velocity = Vector3(NAN,0,0)
		check("nonfinite mechanism checkpoint rejects",false,motor.restore_ground_state(invalid_state).get("ok",true))
		var collision: CollisionShape3D = provider.geometry.get_child(0)
		var original_size: Vector3 = collision.shape.size
		collision.shape.size = original_size+Vector3(0.1,0,0)
		check("incompatible support shape checkpoint rejects",false,motor.restore_ground_state(checkpoint).get("ok",true))
		collision.shape.size = original_size
		var previous_layer: int = provider.geometry.collision_layer
		provider.geometry.collision_layer = 0
		check("missing collision support checkpoint rejects",false,motor.restore_ground_state(checkpoint).get("ok",true))
		provider.geometry.collision_layer = previous_layer
		check("provider and geometry precede reconstruction",true,motor.restore_ground_state(checkpoint).get("ok",false))
		var changed := checkpoint.duplicate(true)
		changed.mechanism.attachment.velocity = Vector3.ZERO
		check("changed support checkpoint rejects",false,motor.restore_ground_state(changed).get("ok",true))
		actor_core.gates.release(hold,"platform-pause")
		var before_jump: Vector3 = body.ground_context(scope).velocity
		key(KEY_SPACE,true)
		var jump := step(0.02)
		key(KEY_SPACE,false)
		check("jump detaches support immediately",true,body.air.airborne and motor.mechanisms.attachment.is_empty())
		near("jump inherits passive velocity once",before_jump.x+0.5,body.air.velocity.x,0.0001)
		check("jump real CHAR charge",true,motor._jump_result.get("ok",false))
		provider.velocity = Vector3.ZERO
		finish_flight()
		motor.retry_activity()
		step(0.02)
		check("reboard current support",true,not motor.mechanisms.attachment.is_empty())
		provider.lose_ack = true
		provider.velocity = Vector3(0.5,0,0)
		var interrupted := step(0.02)
		motor.retry_activity()
		position = body.snapshot().position
		check("lost mechanism receipt retains performed motion",true,not motor.mechanisms.pending_commit.is_empty() and not actor_core.gates.simulation())
		provider.lose_ack = false
		check("mechanism explicit retry settles",true,motor.retry_mechanism().get("ok",false))
		check("mechanism retry never repeats carry",position,body.snapshot().position)
		provider.velocity = Vector3.ZERO
		var cue_count: int = shell.session_shell.movement_audio.streams.size()
		check("actual classic on-foot cues prepared",true,cue_count >= 4)
		await preload("res://tests/platform_boundary_cases.gd").new().run(self,provider)
		measurements.append({"translation_speed_metres_per_second":1.0,"turn_radians_per_second":PI/2,"tolerance_metres":0.0002,"provider":"controlled LOC mechanism, not classic action owner","audio_streams":cue_count})
		controls.begin()
		controls.set_response({"gait_bob_percent":previous.gait_bob_percent,"mounted_bob_percent":previous.mounted_bob_percent,"landing_camera_percent":previous.landing_camera_percent,"movement_audio_percent":previous.movement_audio_percent})
		controls.apply()
		actor_core.request({"id":"platform-return","mode":"return","origin":scope})
		if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		for index in 100:
			if actor_core.snapshot().session.is_empty(): break
			await shell.get_tree().process_frame
		if is_instance_valid(course): course.queue_free()
		source_a.callback = Callable()
	var ok := checks.all(func(item): return item.expected == item.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"fixture":"IMP-012-platforms-v1","measurements":measurements,"engine":Engine.get_version_info(),"display":DisplayServer.get_name()}
