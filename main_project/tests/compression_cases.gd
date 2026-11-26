extends "res://tests/air_cases.gd"
var prefix := "compression"
func check(id: String, expected: Variant, actual: Variant) -> void:
	super.check(id,expected,actual)
	checks[-1].scenario = prefix+" "+id

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var descending: bool = fixture.get("compression_kind","") == "descending"
	var preventing: bool = fixture.get("prevent_crush",false)
	var retiring: bool = fixture.get("retire_crush",false)
	if descending: prefix = "compression descending"
	if preventing: prefix = "compression prevention"
	if retiring: prefix = "compression retirement"
	var provider := preload("res://tests/controlled_mechanism.gd").new("controlled-compression","MOVE",["motion"])
	var prevention := preload("res://tests/controlled_prevention.gd").new()
	prevention.ready = true
	if not preventing: prevention.sources = []
	extra_services = [provider.binding(),prevention.binding()]
	var f := fixture.duplicate(true)
	f.mechanism_course = true
	f.air_player = true
	f.ground_entry_id = prefix.replace(" ","-")+"-entry"
	if await bootstrap(shell,f):
		var controls: RefCounted = shell.controller.controls
		var previous_crouch: String = controls.effective().response.crouch_mode
		controls.begin()
		controls.set_response({"crouch_mode":"toggle"})
		controls.apply()
		var body: Node3D = shell.session_shell.placement
		provider.geometry = course.get_node("ControlledMechanism")
		var roof: StaticBody3D = course.box(Vector3(0,2.6,0),Vector3(8,0.2,8),Color.ORANGE)
		if descending:
			provider.geometry = roof
			provider.support = "controlled-ceiling"
		await shell.get_tree().physics_frame
		await shell.get_tree().physics_frame
		shell.session_shell.focus_changed(true)
		step(0.02)
		motor.retry_activity()
		check("current policy binds",true,motor.bind_mechanism(provider,provider.id,"grounded-crush").ok)
		step(0.02,10)
		check("stationary elevator no crush",true,motor.crush_pending.is_empty() and motor.crush_outcomes.is_empty() and body.snapshot().physical.posture == "standing")
		var compression_velocity := Vector3(0,-0.5,0) if descending else Vector3(0,0.5,0)
		provider.velocity = compression_velocity
		var forced := false
		for index in 100:
			var result := step(0.02)
			forced = not body.snapshot().get("forced_posture",{}).is_empty()
			if forced or not result.ok: break
		check("full standing compression forces crouch",true,forced and body.snapshot().physical.posture == "crouched")
		check("hazard preserves desired standing",true,body.snapshot().desired_posture == "standing" and body.snapshot().pending_stand)
		check("fitting crouch not lethal",true,motor.crush_outcomes.is_empty() and motor.crush_pending.is_empty())
		provider.velocity = -compression_velocity
		step(0.02,10)
		check("release clears only hazard reason",true,body.snapshot().get("forced_posture",{}).is_empty())
		check("standing restores with full clearance",true,body.snapshot().physical.posture == "standing" and not body.snapshot().pending_stand)
		key(KEY_CTRL,true)
		key(KEY_CTRL,false)
		step(0.02)
		check("deliberate crouch retained",true,body.snapshot().desired_posture == "crouched" and body.snapshot().physical.posture == "crouched")
		provider.velocity = Vector3.ZERO
		motor.retry_activity()
		var hp_before: int = actors.vital_projection(scope,"ground-player").current.health
		provider.velocity = compression_velocity
		prevention.ready = false
		var death_events: Array = []
		var nested: Array = [{}]
		var observer := func(value):
			death_events.append(value)
			nested[0] = motor.retry_crush()
			if retiring:
				actor_core.request({"id":"crush-callback-return","mode":"return","origin":scope})
				if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		actors.lethal_committed.connect(observer)
		for index in 300:
			var result := step(0.02)
			if not motor.crush_pending.is_empty() or actor_core.snapshot().status == "dead" or not result.ok or result.get("suspended",false): break
		check("unavailable prevention retains crush debt",true,not motor.crush_pending.is_empty() and not actor_core.gates.simulation() and actors.vital_projection(scope,"ground-player").current.health == hp_before)
		var retained: Dictionary = motor._crush_request.duplicate(true)
		var retained_pose: Vector3 = body.snapshot().position
		check("pending consequence cannot checkpoint as settled",false,motor.capture_ground_state().get("ok",true))
		motor.physics_step(0.02)
		motor.retry_crush()
		check("technical retry preserves request and safe pose",true,retained == motor._crush_request and retained_pose == body.snapshot().position and death_events.is_empty())
		prevention.ready = true
		var resolved: Dictionary = motor.retry_crush()
		if retiring:
			check("lethal callback retires current session",true,actor_core.snapshot().session != scope and death_events.size() == 1)
			check("expired crush delivery reports retirement",true,resolved.get("retired",false))
			check("original crush request retained at retirement",true,motor.retired_work.get(scope+"/crush",{}).get("request",{}) == retained)
			check("retirement cannot publish current crush outcome",true,motor.crush_pending.is_empty() and motor.crush_outcomes.is_empty())
			check("retired crush cannot attest health",false,motor.vital_operation_current(retained))
			motor.retry_crush()
			check("late retry cannot repeat retired death",1,death_events.size())
			actors.lethal_committed.disconnect(observer)
			controls.begin()
			controls.set_response({"crouch_mode":previous_crouch})
			controls.apply()
			source_a.callback = Callable()
			course.queue_free()
			return {"ok":checks.all(func(item): return item.expected == item.actual),"checks":checks,"count":checks.size(),"measurements":measurements}
		check("required crush retry resolves through CHAR",true,resolved.get("ok",false))
		if preventing: check("real CHAR prevention preserves survival",true,actor_core.snapshot().status == "alive" and actors.vital_projection(scope,"ground-player").current.health > 0)
		else: check("continued crouched compression real CHAR death",true,actor_core.snapshot().status == "dead" and actors.vital_projection(scope,"ground-player").current.health == 0)
		check("one retained compression outcome",1,motor.crush_outcomes.size())
		check("death notification exactly once",1,death_events.size())
		check("crush delivery rejects reentrancy",true,nested[0].get("ok") == false and "Settle" in nested[0].get("reason",""))
		var pose: Vector3 = body.snapshot().position
		motor.retry_crush()
		step(0.02)
		check("repeated contact cannot replay death",true,death_events.size() == 1 and body.snapshot().position == pose)
		if preventing:
			var id: String = motor.crush_outcomes.keys()[0]
			check("prevention retains collision recovery hold",false,actor_core.gates.simulation())
			check("unchanged compression cannot resume",false,motor.recover_crush(provider,id,0.02).get("ok",true))
			provider.velocity = -compression_velocity
			check("new safe mechanism proposal recovers",true,motor.recover_crush(provider,id,0.02).get("ok",false))
			check("recovery retry idempotent",true,motor.recover_crush(provider,id,0.02).get("unchanged",false))
			var health: int = actors.vital_projection(scope,"ground-player").current.health
			step(0.02)
			check("recovered physical continuation never rerolls benefit",true,prevention.costs.size() == 1 and prevention.calls.size() == 1 and actors.vital_projection(scope,"ground-player").current.health == health and actor_core.gates.simulation())
			motor.retry_activity()
			var hold: int = actor_core.gates.acquire("compression-checkpoint",scope,["simulation","save"])
			var saved: Dictionary = motor.capture_ground_state()
			check("settled prevented outcome checkpoint",true,saved.get("ok",false) and motor.restore_ground_state(saved).get("ok",false))
			actor_core.gates.release(hold,"compression-checkpoint")
		actors.lethal_committed.disconnect(observer)
		controls.begin()
		controls.set_response({"crouch_mode":previous_crouch})
		controls.apply()
		measurements.append({"roof_underside_metres":2.5,"standing_height_metres":1.8,"crouched_height_metres":0.9,"rise_metres_per_second":0.5,"health_before":hp_before,"outcomes":motor.crush_outcomes.size(),"scope":"controlled upright-box grounded compression, no classic mechanism execution"})
		actor_core.request({"id":prefix.replace(" ","-")+"-return","mode":"return","origin":scope})
		if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		source_a.callback = Callable()
		course.queue_free()
	return {"ok":checks.all(func(item): return item.expected == item.actual),"checks":checks,"count":checks.size(),"measurements":measurements}
