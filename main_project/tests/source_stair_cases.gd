extends "res://tests/ground_cases.gd"
## Regression for the original 16-riser stair/ramp boundary, through real MOVE.
## Independent source model 67025 rises 6.1 m across its tread faces; reach the
## final tread (6.0 m threshold), without requiring the next adjoining model.
var check_prefix := "source stair "
func check(id: String, expected: Variant, actual: Variant) -> void:
	super.check(check_prefix+id,expected,actual)

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var contacts: bool = fixture.get("stair_contacts",false)
	if contacts: check_prefix = "source stair contact "
	if await bootstrap(shell,fixture):
		var controls: RefCounted = shell.controller.controls
		var previous: Dictionary = controls.effective().response.duplicate(true)
		controls.begin()
		controls.set_response({"run_mode":"hold","sneak_mode":"hold","crouch_mode":"toggle"})
		controls.apply()
		var body: Node3D = shell.session_shell.placement
		var variants: Array = [["standing","walk"],["standing","run"],["standing","sneak"],["crouched","walk"],["crouched","run"],["crouched","sneak"]]
		if contacts: variants = [["standing","walk",30.0],["standing","walk",-30.0],["standing","run",45.0],["standing","run",-45.0],["crouched","walk",30.0],["crouched","walk",-30.0],["crouched","run",45.0],["crouched","run",-45.0]]
		for variant: Array in variants:
			var label: String = variant[0]+" "+variant[1]+" "
			var angle: float = float(variant[2]) if contacts else 0.0
			if contacts: label += "yaw %d " % int(angle)
			committed_capsules_clear = true
			if motor.gait.crouch_selected != (variant[0] == "crouched"):
				key(KEY_CTRL,true)
				key(KEY_CTRL,false)
			step(0.02)
			check(label+"actual posture",variant[0],body.snapshot().physical.posture)
			key(KEY_SHIFT,variant[1] == "run")
			key(KEY_ALT,variant[1] == "sneak")
			var origin: Vector3 = body.snapshot().position
			var practice_before: int = actors.activity_projection(scope,"ground-player").get("practice",{}).get("running",0)
			var result := {}
			var steps_seen := 0
			var bounded := true
			var input_consistent := true
			var stagnant := 0
			var angled := false
			var touched_wall := false
			key(KEY_W,true)
			for index in 1600:
				if contacts and not angled and body.snapshot().position.z < -2-course.run_metres+0.2:
					shell.session_shell.view.place_facing(scope,{"version":1,"yaw":angle,"pitch":0.0})
					angled = true
				var before: Vector3 = body.snapshot().position
				result = step(0.02)
				if not result.get("ok",false) or result.get("suspended",false) or result.get("handoff_pending",false): break
				var actual_horizontal: Vector3 = body.snapshot().position-before
				actual_horizontal.y = 0
				input_consistent = input_consistent and actual_horizontal.dot(result.get("requested_displacement",Vector3.ZERO)) >= -0.0000001
				steps_seen += int(result.get("steps",0))
				touched_wall = touched_wall or absf(body.snapshot().position.x) > 1.25
				bounded = bounded and result.get("actual_metres_per_second",INF) <= result.get("gait",{}).get("target_metres_per_second",0.0)+0.0001
				stagnant = stagnant+1 if before.distance_to(body.snapshot().position) < 0.000001 else 0
				if body.snapshot().position.y > course.rise+body.snapshot().shape.height*0.5+6.0 or stagnant >= 12: break
			key(KEY_W,false)
			check(label+"uphill stays grounded",true,result.get("ok",false) and not result.get("suspended",false) and not result.get("handoff_pending",false))
			check(label+"ascends full original staircase",true,body.snapshot().position.y > course.rise+body.snapshot().shape.height*0.5+6.0)
			check(label+"actual automatic steps observed",true,steps_seen > 0)
			if contacts: check(label+"wall approach exercised",true,touched_wall)
			measurements.append({"case":label+"upper stairs","position":str(body.snapshot().position),"steps":steps_seen,"last":str(result),"reason":motor.reason})
			if contacts and (not result.get("ok",false) or result.get("suspended",false) or result.get("handoff_pending",false) or stagnant >= 12): break
			if variant == ["standing","walk"]: await capture_course("source-stairs-upper")
			if contacts: shell.session_shell.view.place_facing(scope,{"version":1,"yaw":-angle,"pitch":0.0})
			key(KEY_S,true)
			stagnant = 0
			for index in 1800:
				var before: Vector3 = body.snapshot().position
				result = step(0.02)
				if not result.get("ok",false) or result.get("suspended",false) or result.get("handoff_pending",false): break
				var actual_horizontal: Vector3 = body.snapshot().position-before
				actual_horizontal.y = 0
				input_consistent = input_consistent and actual_horizontal.dot(result.get("requested_displacement",Vector3.ZERO)) >= -0.0000001
				bounded = bounded and result.get("actual_metres_per_second",INF) <= result.get("gait",{}).get("target_metres_per_second",0.0)+0.0001
				stagnant = stagnant+1 if before.distance_to(body.snapshot().position) < 0.000001 else 0
				if body.snapshot().position.z >= origin.z-0.05 or stagnant >= 12: break
			key(KEY_S,false)
			check(label+"return stays grounded",true,result.get("ok",false) and not result.get("suspended",false) and not result.get("handoff_pending",false))
			check(label+"returns from stairs across ramp",true,body.snapshot().position.z >= origin.z-0.05 and absf(body.snapshot().position.y-origin.y) < 0.002)
			check(label+"surface gait speed bounded",true,bounded)
			check(label+"all committed capsules clear",true,committed_capsules_clear)
			if contacts: check(label+"contacts never reverse input",true,input_consistent)
			motor.retry_activity()
			var practice_after: int = actors.activity_projection(scope,"ground-player").get("practice",{}).get("running",0)
			check(label+"actual gait practice",true,practice_after > practice_before if variant[1] == "run" else practice_after == practice_before)
			measurements.append({"case":label+"returned","position":str(body.snapshot().position),"last":str(result),"reason":motor.reason})
			key(KEY_SHIFT,false)
			key(KEY_ALT,false)
			if variant == ["standing","walk"]: await capture_course("source-stairs-return")
			if not result.get("ok",false) or result.get("handoff_pending",false) or stagnant >= 12: break
			if contacts:
				# Reset between trajectories using ordinary input on the lower landing.
				shell.session_shell.view.place_facing(scope,{"version":1,"yaw":0.0,"pitch":0.0})
				step(0.02)
				var lateral: Key = KEY_A if body.snapshot().position.x > 0 else KEY_D
				key(lateral,true)
				for index in 200:
					var remaining: float = absf(body.snapshot().position.x)/float(motor.last.get("gait",{}).get("target_metres_per_second",1.0))
					if remaining < 0.000001: break
					result = step(minf(0.02,remaining))
					if not result.get("ok",false) or result.get("handoff_pending",false): break
				key(lateral,false)
				check(label+"input recentres lower landing",true,absf(body.snapshot().position.x) < 0.002)
		controls.begin()
		controls.set_response({"run_mode":previous.run_mode,"sneak_mode":previous.sneak_mode,"crouch_mode":previous.crouch_mode})
		var restored: Dictionary = controls.apply()
		check("preferences restored",true,restored.get("applied",false) and controls.effective().response == previous)
		actor_core.request({"id":"source-stair-contacts-return" if contacts else "source-stair-return","mode":"return","origin":scope})
		if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		source_a.callback = Callable()
		preload("res://scripts/loc/dungeon_geometry.gd").release(course)
	var ok := true
	for item in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size(),"measurements":measurements}
