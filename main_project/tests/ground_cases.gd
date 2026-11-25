extends "res://tests/actor_state_cases.gd"
const Supplier = preload("res://tests/controlled_ground_provider.gd")
var shell_ref: Control
var motor: RefCounted
var clock_provider := Supplier.new("controlled-ground-time","TIME",["interval","time"])
var trait_provider := Supplier.new("controlled-ground-traits","CHAR",["traits"])
var restriction_provider := Supplier.new("controlled-ground-restrictions","CHAR",[])
var course: Node3D
var measurements: Array = []
var performance: Dictionary = {}
var source_calls := 0
var fatigue_source := preload("res://tests/controlled_vital_consumer.gd").new()
class MissingTraitIdentity extends RefCounted:
	func ground_traits(_context: Dictionary) -> Dictionary:
		return {"ok":true,"revision":1,"athleticism":false,"improved_athleticism":false,"argonian":false}
	func activity_current(_request: Dictionary) -> bool: return true

func key(code: Key, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	if code in [KEY_SHIFT,KEY_ALT,KEY_CTRL]: event.location = KEY_LOCATION_LEFT
	event.pressed = down
	shell_ref.session_shell.action_input.observe(event)
	shell_ref.session_shell.action_input.accept(event)
	shell_ref.session_shell.deliver_input()
func step(delta: float, count := 1) -> Dictionary:
	var result := {}
	for index in count:
		result = motor.physics_step(delta)
		if not result.has("gait"):
			print("GROUND STEP WITHOUT GAIT ",result,"; focus hold ",shell_ref.session_shell._focus_hold,"; reason ",motor.reason)
		if not result.get("ok",false): break
	return result
func middle() -> void:
	for down in [true,false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_MIDDLE
		event.pressed = down
		shell_ref.session_shell.action_input.observe(event)
		shell_ref.session_shell.action_input.accept(event)
		shell_ref.session_shell.deliver_input()
func axis(value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = 71
	event.axis = JOY_AXIS_LEFT_Y
	event.axis_value = value
	shell_ref.session_shell.action_input.observe(event)
	shell_ref.session_shell.action_input.accept(event)
func joy_button(code: JoyButton, down: bool) -> void:
	var event := InputEventJoypadButton.new()
	event.device = 71
	event.button_index = code
	event.pressed = down
	shell_ref.session_shell.action_input.observe(event)
	shell_ref.session_shell.action_input.accept(event)
	shell_ref.session_shell.deliver_input()
func contribution(provider: RefCounted, id: String, revision: int, factors: Dictionary) -> Dictionary:
	var previous: Dictionary = provider.source_request.duplicate(true)
	provider.source_request = {"session":scope,"source":id,"revision":revision,"lifetime":"session","factors":factors}
	var result: Dictionary = motor.gait.source(provider,provider.source_request)
	if not result.ok: provider.source_request = previous
	return result
func press_control(text: String) -> void:
	for button in shell_ref.find_children("*","Button",true,false):
		if button.text == text:
			button.pressed.emit()
			return
	push_error("Ground stock handler missing: "+text)

func requests_and_sources() -> void:
	var first := Supplier.new("controlled-speed-a","CHAR",[])
	var second := Supplier.new("controlled-speed-b","CHAR",[])
	key(KEY_ALT,true)
	var result := step(0.02)
	near("ground Hold Sneak metres per second",86.5/39.5,result.gait.target_metres_per_second)
	key(KEY_SHIFT,true)
	result = step(0.02)
	check("ground Run wins simultaneous Hold","run",result.gait.gait)
	key(KEY_SHIFT,false)
	check("ground Hold Sneak resumes","sneak",step(0.02).gait.gait)
	key(KEY_ALT,false)
	check("ground source Walk add",true,contribution(first,"speed-a",1,{"walk":2.0}).ok)
	near("ground Walk factor applied once",350.0/39.5,step(0.02).gait.target_metres_per_second)
	key(KEY_ALT,true)
	near("ground Sneak excludes Walk factors",86.5/39.5,step(0.02).gait.target_metres_per_second)
	check("ground independent Sneak factor",true,contribution(second,"speed-b",1,{"sneak":0.5}).ok)
	near("ground Sneak own factor once",43.25/39.5,step(0.02).gait.target_metres_per_second)
	key(KEY_ALT,false)
	check("ground source removal only own source",true,contribution(first,"speed-a",2,{}).ok)
	near("ground Walk source removed",175.0/39.5,step(0.02).gait.target_metres_per_second)
	check("ground source stale revision rejects",false,contribution(first,"speed-a",1,{"walk":2.0}).ok)
	check("ground source changed same revision rejects",false,contribution(second,"speed-b",1,{"sneak":0.75}).ok)
	for bad in [0.0,-1.0,INF,NAN,true]:
		check("ground malformed factor "+str(bad),false,contribution(first,"speed-a",3,{"walk":bad}).ok)
	check("ground bounded large source",true,contribution(first,"speed-a",3,{"walk":1000000.0}).ok)
	near("ground resolved speed cap metres per second",100.0,step(0.02).gait.target_metres_per_second)
	var capped_start: Vector3 = shell_ref.session_shell.placement.snapshot().position
	key(KEY_D,true)
	step(0.02)
	key(KEY_D,false)
	near("ground physical capped speed metres",2.0,shell_ref.session_shell.placement.snapshot().position.distance_to(capped_start))
	key(KEY_A,true)
	step(0.02)
	key(KEY_A,false)
	check("ground clear bounded source",true,contribution(first,"speed-a",4,{}).ok)
	check("ground clear Sneak source",true,contribution(second,"speed-b",2,{}).ok)
	# Retained source tombstones remain associated with their real provider Objects.
	# These fixture providers must live until the contributions are explicitly removed.

func input_handoffs() -> void:
	var stock: RefCounted = shell_ref.session_shell
	var controls: RefCounted = shell_ref.controller.controls
	controls.begin()
	controls.set_response({"run_mode":"hold","sneak_mode":"toggle"})
	controls.apply()
	key(KEY_ALT,true)
	key(KEY_ALT,false)
	check("ground Hold Run Toggle Sneak",["hold","toggle","sneak"],[motor.gait.run_mode,motor.gait.sneak_mode,step(0.02).gait.gait])
	key(KEY_SHIFT,true)
	check("ground mixed Hold Run priority","run",step(0.02).gait.gait)
	key(KEY_SHIFT,false)
	controls.begin()
	controls.set_response({"run_mode":"toggle","sneak_mode":"hold"})
	controls.apply()
	if motor.gait.run_selected:
		key(KEY_SHIFT,true)
		key(KEY_SHIFT,false)
	key(KEY_ALT,true)
	check("ground Toggle Run Hold Sneak","sneak",step(0.02).gait.gait)
	key(KEY_SHIFT,true)
	key(KEY_SHIFT,false)
	check("ground mixed Toggle Run priority","run",step(0.02).gait.gait)
	key(KEY_SHIFT,true)
	key(KEY_SHIFT,false)
	check("ground mixed held Sneak resumes after Toggle Run","sneak",step(0.02).gait.gait)
	key(KEY_ALT,false)
	controls.begin()
	controls.set_response({"run_mode":"toggle","sneak_mode":"toggle"})
	controls.apply()
	var preferences: Dictionary = controls.effective()
	key(KEY_ALT,true)
	key(KEY_ALT,false)
	if not motor.gait.run_selected:
		key(KEY_SHIFT,true)
		key(KEY_SHIFT,false)
	key(KEY_S,true)
	for rate: float in [0.5,2.0]:
		actor_core.gates.intended_rate = rate
		var before_rate: Vector3 = stock.placement.snapshot().position
		step(0.02)
		near("ground CORE intended rate "+str(rate),(200.0/39.5)*1.4*.02*rate,stock.placement.snapshot().position.distance_to(before_rate))
	actor_core.gates.intended_rate = 1.0
	key(KEY_S,false)
	step(0.02)
	check("ground Run clears toggled Sneak",false,motor.gait.sneak_selected)
	# Run was already selected; two rapid toggles end selected without catch-up replay.
	key(KEY_SHIFT,true)
	key(KEY_SHIFT,false)
	key(KEY_SHIFT,true)
	key(KEY_SHIFT,false)
	var selected: bool = motor.gait.run_selected
	step(0.02,3)
	check("ground rapid toggles once across catch-up",selected,motor.gait.run_selected)
	middle()
	check("ground Autorun activated",true,motor.gait.autorun)
	key(KEY_S,true)
	step(0.02)
	check("ground backward cancels Autorun",false,motor.gait.autorun)
	key(KEY_S,false)
	middle()
	stock.pause()
	check("ground menu cancels Autorun",false,motor.gait.autorun)
	check("ground menu preserves toggle selection",selected,motor.gait.run_selected)
	stock.options()
	check("ground menu does not reactivate Autorun",false,motor.gait.autorun)
	check("ground Autorun leaves preferences unchanged",preferences,controls.effective())
	# Injected controller tests qualify the software path, not a physical device.
	stock.action_input.connection_changed(71,true)
	stock.action_input.select_controller(71)
	controls.begin()
	controls.propose("run","controller",0,{"kind":"button","code":JOY_BUTTON_B})
	controls.apply()
	if motor.gait.run_selected:
		key(KEY_SHIFT,true)
		key(KEY_SHIFT,false)
	key(KEY_SHIFT,true)
	joy_button(JOY_BUTTON_B,true)
	check("ground injected mixed device Run toggles once",true,motor.gait.run_selected)
	key(KEY_SHIFT,false)
	check("ground injected other contributor holds Run",true,stock.action_input.held("run"))
	joy_button(JOY_BUTTON_B,false)
	check("ground injected mixed contributors release once",true,not stock.action_input.held("run") and motor.gait.run_selected)
	controls.begin()
	controls.propose("run","controller",0,{})
	controls.apply()
	if not motor.gait.run_selected:
		key(KEY_SHIFT,true)
		key(KEY_SHIFT,false)
	for magnitude in [0.0001,0.5,1.0]:
		axis(-(.15+.85*magnitude))
		var before: Vector3 = stock.placement.snapshot().position
		var result := step(0.02)
		near("ground injected analog Run magnitude "+str(magnitude),(200.0/39.5)*1.4*magnitude*.02,stock.placement.snapshot().position.distance_to(before),0.00001)
		check("ground injected analog gait "+str(magnitude),"run",result.gait.gait)
	key(KEY_S,true)
	check("ground keyboard precedence over injected forward stick",Vector2(0,1),step(0.02).gait.direction)
	key(KEY_S,false)
	axis(0.0)
	middle()
	stock.action_input.last_device = "controller"
	stock.action_input.connection_changed(71,false)
	check("ground disconnect cancels Autorun",false,motor.gait.autorun)
	check("ground disconnect retains simulation hold",false,actor_core.gates.simulation())
	stock.action_input.continue_keyboard()
	check("ground deliberate keyboard recovery",true,actor_core.gates.simulation())
	# Return to the original requested Run selection for the later wall vectors.
	if not motor.gait.run_selected:
		key(KEY_SHIFT,true)
		key(KEY_SHIFT,false)
func near(label: String, expected: float, actual: float, tolerance := 0.0001) -> void:
	measurements.append({"case":label,"expected":expected,"actual":actual,"tolerance":tolerance,"unit":"metre or metre/second as case names specify"})
	check(label,true,absf(expected-actual) <= tolerance)

func capture_course(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		shell_ref.session_shell.focus_changed(true)
		return
	var panel: Control = shell_ref.panel.get_parent().get_parent()
	var was_visible := panel.visible
	panel.visible = false # Review capture only; stock menus/handlers are unchanged.
	await RenderingServer.frame_post_draw
	shell_ref.get_viewport().get_texture().get_image().save_png(sandbox.path_join(label+".png"))
	panel.visible = was_visible
	# Only the automated fixture controls focus between synchronous input vectors.
	# A hidden rendered child can receive host focus-out while yielding for capture.
	# Release only the stock focus owner's hold; retain all unrelated CORE holds.
	# Human ground-review never calls this capture helper.
	shell_ref.session_shell.focus_changed(true)

func bootstrap(shell: Control, fixture: Dictionary) -> bool:
	shell_ref = shell
	sandbox = fixture.sandbox
	shell.set_physics_process(false) # Deterministic controlled scheduling of the stock handler.
	var controller: RefCounted = shell.controller
	var package := manifest("ground.tuning")
	package.content = ["ground-policy.json"]
	package.capabilities = ["data.ground-motor-v1"]
	write(controller.mods.root.path_join("Mods/Ground/mod.json"),JSON.stringify(package))
	write(controller.mods.root.path_join("Mods/Ground/ground-policy.json"),JSON.stringify({"domain":"move.ground","path":"policy","operation":"patch","entries":[{"id":"player","value":{"maximum":90.0}}]}))
	controller.mods.rescan()
	controller.mods.edit("ground.tuning","toggle")
	write(controller.mods.root.path_join("Overrides/ground-policy.json"),JSON.stringify({"domain":"move.ground","path":"policy","operation":"patch","entries":[{"id":"player","value":{"maximum":100.0}}]}))
	controller.select_folder(fixture.classic_source)
	check("ground published composition",true,controller.continue_to_menu("run").ok)
	var published: Dictionary = controller.providers.definitions.query("move.ground","policy","player").record
	check("ground checked loose overrides MOD",["@loose",100.0],[published.winner.provider,float(published.value.maximum)])
	check("ground shipped and MOD provenance retained",true,published.contributors.any(func(source): return source.provider == "ground.tuning") and published.contributors.any(func(source): return source.provider == "@shipped/ground-motor-v1"))
	var malformed: Dictionary = published.value.duplicate(true)
	malformed.divisor = true
	check("ground raw profile rejects boolean divisor",false,preload("res://scripts/data/ground_policy.gd").reason(malformed).is_empty())
	shell.render()
	actor_core = shell.session_shell.core
	actors = actor_core.actors
	motor = shell.session_shell.ground
	actor_core.provider = ActorEntry.new()
	check("ground controlled entry","pending",actor_core.request({"id":"ground-entry","mode":"new","origin":""}).kind)
	scope = actor_core.snapshot().session
	original = actor_core.ticket()
	var capture := captured("ground-player")
	capture.skills.erase("added-skill")
	source_a.callback = func(): source_calls += 1
	var constructed: Dictionary = actors.fresh(scope,original,capture,{"provider":"controlled-ground-time","unit":"game-millisecond","instant":0},[{"id":"controlled-ground-stats","provider":source_a}])
	check("ground real CHAR constructed",true,constructed.ok)
	if not constructed.ok: print("GROUND CONSTRUCTION ",constructed)
	clock_provider.gates = actor_core.gates
	check("ground suppliers explicitly bound",true,motor.bind(scope,"ground-player",clock_provider,trait_provider,restriction_provider).ok)
	var services := [actors.service_binding(scope),motor.service_binding(scope),clock_provider.binding(),trait_provider.binding(),fatigue_source.binding("ground-test-fatigue","CHAR")]
	actor_core.complete_baseline(original,{"ok":true,"services":services})
	course = preload("res://tests/ground_course.gd").new()
	shell.add_child(course)
	course.build()
	var body: Node3D = shell.session_shell.placement
	body.assembly = course
	var door := {"position":Vector3(0,0,1),"normal":Vector3.FORWARD,"points":[Vector3(-2,0,1),Vector3(2,3,1)]}
	course.candidate = {"route_intent_bound":true,"ticket":{"request":{"core_ticket":original.duplicate(true)}},"route":"ground-course","handoff_id":"ground-course-entry","activation_session":scope,"frame":"dungeon-geometry-metres-v1","position":Vector3.ZERO,"forward":Vector3.FORWARD,"pose_kind":"ground-course-sole","desired_context":{"doorway_side":"interior","space":"ground-course"},"entrance":door,"exit":door,"return":{},"marker":{},"placement_policy":body.baseline_policy()}
	await shell.get_tree().physics_frame
	await shell.get_tree().physics_frame
	var candidate: Dictionary = course.candidate
	var physical := preload("res://tests/placement_cases.gd").new().physical()
	var validated: Dictionary = body.validate(candidate,physical)
	if validated.kind == "rejected": print("GROUND PLACEMENT ",validated)
	check("ground course placement validated","exact",validated.kind)
	var placed: Dictionary = body.commit(candidate,validated,func(value: Dictionary): return {"ok":true,"handoff_id":value.handoff_id})
	check("ground existing body placed",true,placed.get("placement_committed",false))
	actor_core.complete_readiness(actor_core.ticket(),{"ok":true,"services":services})
	check("ground real CORE ready",true,actor_core.snapshot().ready)
	return actor_core.snapshot().ready

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var review_script: GDScript = load("res://tests/ground_review.gd")
	check("ground human review entry compiles",true,review_script != null and review_script.can_instantiate())
	if await bootstrap(shell,fixture):
		var body: Node3D = shell.session_shell.placement
		check("ground missing supplier identity rejects at binding",false,motor.bind(scope,"ground-player",clock_provider,MissingTraitIdentity.new(),restriction_provider).ok)
		check("ground provider binding rejection is atomic",true,motor.traits_owner == trait_provider and actor_core.gates.simulation())
		var coherent: Array = [true]
		var char_observer := func(_outcome: Dictionary): coherent[0] = coherent[0] and motor.last.get("position") == body.snapshot().position and motor.last.has("gait") and motor.last.has("activity")
		actors.activity_committed.connect(char_observer)
		var starting: Vector3 = body.snapshot().position
		shell.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		check("ground host focus loss suspends automation",true,step(0.02).get("suspended",false))
		check("ground host focus loss preserves pose",starting,body.snapshot().position)
		await capture_course("ground-start")
		check("ground capture restores controlled focus",true,actor_core.gates.simulation())
		key(KEY_W,true)
		var result := step(0.02,50)
		check("ground collision path success",true,result.get("ok",false))
		var walking: Vector3 = body.snapshot().position-starting
		near("ground one second Walk metres",175.0/39.5,walking.length())
		var walked_pose: Vector3 = body.snapshot().position
		measurements.append({"case":"ground measured world pose","unit":"metre","frame":"dungeon-geometry-metres-v1","profile":"ground-motor-v1","steps":50,"step_simulated_seconds":0.02,"expected_xyz":[starting.x,starting.y,starting.z-175.0/39.5],"actual_xyz":[walked_pose.x,walked_pose.y,walked_pose.z],"tolerance_metres":0.0001})
		await capture_course("ground-walk")
		key(KEY_W,false)
		key(KEY_S,true)
		step(0.02,50)
		key(KEY_S,false)
		near("ground backward returns metres",0,body.snapshot().position.distance_to(starting))
		key(KEY_A,true)
		step(0.02,50)
		key(KEY_A,false)
		near("ground sideways crosses visual marks metres",175.0/39.5,absf(body.snapshot().position.x-starting.x))
		key(KEY_D,true)
		step(0.02,50)
		key(KEY_D,false)
		requests_and_sources()
		key(KEY_W,true)
		key(KEY_D,true)
		step(0.01,100)
		near("ground diagonal capped metres",175.0/39.5,body.snapshot().position.distance_to(starting))
		key(KEY_W,false)
		key(KEY_D,false)
		# Live input uses stock bindings; settings apply through the real owner.
		var controls: RefCounted = shell.controller.controls
		shell.session_shell.open_controls()
		shell.render()
		var run_choice: OptionButton = shell.find_child("run_mode",true,false)
		var sneak_choice: OptionButton = shell.find_child("sneak_mode",true,false)
		run_choice.select(1)
		run_choice.item_selected.emit(1)
		sneak_choice.select(1)
		sneak_choice.item_selected.emit(1)
		check("ground stock toggle edit",true,controls.draft().response.run_mode == "toggle" and controls.draft().response.sneak_mode == "toggle")
		var persisted := FileAccess.get_file_as_string(shell.controller.settings.path)
		shell.controller.settings.adapter.faults.settings_stage = true
		press_control("Apply Controls")
		check("ground stock toggle applies despite failed save",true,controls.effective() == controls.draft() and "UNSAVED" in controls.status)
		check("ground applied gait independent of persistence",["toggle","toggle"],[motor.gait.run_mode,motor.gait.sneak_mode])
		check("ground failed save preserves disk",persisted,FileAccess.get_file_as_string(shell.controller.settings.path))
		shell.controller.settings.adapter.faults.clear()
		press_control("Retry Save Controls")
		check("ground stock toggle retry saves",true,shell.controller.settings.value(shell.controller.settings.persisted,preload("res://scripts/input/binding_configuration.gd").SETTING) == controls.effective())
		check("ground malformed gait preference rejects",false,controls.set_response({"run_mode":"invalid"}).ok)
		press_control("Cancel / Close Controls")
		FileAccess.open(sandbox.path_join("expected-ground-settings.bin"),FileAccess.WRITE).store_var({"path":shell.controller.settings.path,"configuration":controls.effective()},false)
		key(KEY_SHIFT,true)
		key(KEY_SHIFT,false)
		check("ground Run toggled once",true,motor.gait.run_selected)
		var before: Vector3 = body.snapshot().position
		key(KEY_W,true)
		result = step(0.025,40)
		near("ground one second Run metres",(200.0/39.5)*1.4,body.snapshot().position.distance_to(before))
		key(KEY_W,false)
		var activity: Dictionary = actors.activity_projection(scope,"ground-player")
		check("ground real CHAR Running practice",4,activity.practice.running)
		input_handoffs()
		var preparation: int = actors.definitions.timings.prepare_serial
		var saved: Vector3 = body.snapshot().position
		var independent := actor_core.gates.acquire("ground-independent",scope,["simulation"])
		check("ground pause freezes",true,step(0.1,5).get("suspended",false))
		check("ground pause preserves pose",saved,body.snapshot().position)
		actor_core.gates.release(independent,"ground-independent")
		key(KEY_W,true)
		result = step(0.02,250)
		check("ground wall sweep success",true,result.get("ok",false))
		var wall_position: Vector3 = body.snapshot().position
		check("ground real wall blocks capsule",true,wall_position.z >= -19.601 and wall_position.z < -19.59)
		var practice_before: int = actors.activity_projection(scope,"ground-player").practice.running
		step(0.02,50)
		check("ground blocked Run no practice",practice_before,actors.activity_projection(scope,"ground-player").practice.running)
		check("ground point updates skip DATA preparation",preparation,actors.definitions.timings.prepare_serial)
		restriction_provider.run_policy = "walk"
		restriction_provider.revision += 1
		var fallback_result := step(0.02)
		check("ground explicit mod Run fallback","walk",fallback_result.gait.gait)
		near("ground mod fallback uses Walk baseline",175.0/39.5,fallback_result.gait.target_metres_per_second)
		restriction_provider.run_policy = "allow"
		restriction_provider.revision += 1
		# A failed real CHAR delivery preserves physical progress under an owned hold.
		key(KEY_W,false)
		key(KEY_S,true)
		trait_provider.reject_activity = true
		result = step(0.02)
		check("ground performed debt retained",true,not motor._pending.is_empty())
		var performed: Vector3 = body.snapshot().position
		check("ground debt gates simulation",false,actor_core.gates.simulation())
		var debt_cap: Dictionary = actors.ground_capabilities(scope,"ground-player")
		check("ground performed debt protects original actor revision","busy",actors.reconcile(scope,{},"ground-player",debt_cap.revision,debt_cap.content).get("kind"))
		step(0.02)
		check("ground debt cannot replay travel",performed,body.snapshot().position)
		trait_provider.reject_activity = false
		var later_hold := actor_core.gates.acquire("ground-later-menu",scope,["simulation"])
		check("ground eligible debt settles under later hold",true,motor.retry_activity().ok)
		check("ground retry never moves",performed,body.snapshot().position)
		check("ground continuation keeps independent hold",false,actor_core.gates.simulation())
		actor_core.gates.release(later_hold,"ground-later-menu")
		key(KEY_S,false)
		var cap: Dictionary = actors.ground_capabilities(scope,"ground-player")
		motor.retry_activity()
		cap = actors.ground_capabilities(scope,"ground-player")
		source_a.revision += 1
		source_a.contributions = [{"id":"live-speed","kind":"attribute","target":"speed","value":10},{"id":"live-running","kind":"skill","target":"running","value":20}]
		check("ground live CHAR reconciliation",true,actors.reconcile(scope,{},"ground-player",cap.revision,cap.content).ok)
		near("ground next eligible step uses live stats",(210.0/39.5)*1.5,step(0.02).gait.target_metres_per_second)
		var calls_before := source_calls
		motor.retry_activity()
		var retained_before: int = actors.ground_capabilities(scope,"ground-player").activity_count
		var started := Time.get_ticks_usec()
		var sustained := step(1.0/60.0,5000)
		performance.physics_5000_usec = Time.get_ticks_usec()-started
		check("ground sustained beyond former receipt limit",true,sustained.get("ok",false) and not sustained.get("suspended",false))
		motor.retry_activity()
		check("ground elapsed segmentation independent of physics count",84,actors.ground_capabilities(scope,"ground-player").activity_count-retained_before)
		started = Time.get_ticks_usec()
		for index in 1000: actors.ground_capabilities(scope,"ground-player")
		performance.capabilities_1000_usec = Time.get_ticks_usec()-started
		performance.retained_intervals = actors.ground_capabilities(scope,"ground-player").activity_count
		check("ground repeated steps skip actor source preparation",calls_before,source_calls)
		check("ground repeated steps skip catalog preparation",preparation,actors.definitions.timings.prepare_serial)
		# Required optional source removal never changes another owner.
		restriction_provider.voluntary = false
		restriction_provider.revision += 1
		key(KEY_S,true)
		var restricted: Vector3 = body.snapshot().position
		check("ground restriction is checked",true,step(0.02).ok)
		check("ground voluntary restriction stops voluntary travel",restricted,body.snapshot().position)
		restriction_provider.voluntary = true
		restriction_provider.revision += 1
		key(KEY_S,false)
		var duplicate: Dictionary = body._ground_last.request.duplicate(true)
		var pose_before: Vector3 = body.snapshot().position
		check("ground physical operation exact duplicate",body._ground_last.result,body.advance_ground(motor,duplicate))
		check("ground physical duplicate no travel",pose_before,body.snapshot().position)
		duplicate.velocity = Vector3.ONE
		check("ground physical changed intent rejects",false,body.advance_ground(motor,duplicate).ok)
		var recursive: Array = []
		var observer := func(_result: Dictionary): recursive.append(motor.physics_step(0.02))
		motor.committed.connect(observer)
		step(0.02)
		motor.committed.disconnect(observer)
		check("ground scoped observer reentry rejects",false,recursive[0].ok)
		var receipt: Dictionary = motor._proof.duplicate(true)
		var owners := {"motion":motor,"interval":clock_provider,"traits":trait_provider}
		var before_retry: Dictionary = actors.ground_capabilities(scope,"ground-player")
		motor.retry_activity()
		receipt = motor._proof.duplicate(true)
		before_retry = actors.ground_capabilities(scope,"ground-player")
		check("ground real CHAR exact interval retry",true,actors.activity_intake(owners,receipt).ok)
		check("ground interval retry preserves actor revision",before_retry,actors.ground_capabilities(scope,"ground-player"))
		receipt.context.motion.passive_motion = true
		check("ground changed interval intent rejects",false,actors.activity_intake(owners,receipt).ok)
		var malformed_clock: Dictionary = motor._proof.duplicate(true)
		malformed_clock.clock.simulation_unit = &"simulated-microsecond"
		check("ground shared schema rejects interned clock units",false,actors.activity_request_valid(malformed_clock))
		malformed_clock = motor._proof.duplicate(true)
		malformed_clock.clock.end_game = NAN
		check("ground shared schema rejects nonfinite clock",false,actors.activity_request_valid(malformed_clock))
		malformed_clock = motor._proof.duplicate(true)
		malformed_clock.clock.numerator = true
		check("ground shared schema rejects boolean clock ratio",false,actors.activity_request_valid(malformed_clock))
		# Actual view facing, with no new camera authority or movement map.
		shell.session_shell.view.place_facing(scope,{"version":1,"yaw":90.0,"pitch":0.0})
		var facing_start: Vector3 = body.snapshot().position
		key(KEY_W,true)
		step(0.02)
		key(KEY_W,false)
		near("ground actual facing moves east metres",(210.0/39.5)*1.5*.02,body.snapshot().position.x-facing_start.x)
		near("ground actual facing has no north travel",0.0,body.snapshot().position.z-facing_start.z)
		check("ground camera follows committed body",body.snapshot().position,shell.session_shell.view_camera.position)
		# A wall slide can reach a different endpoint than its first sweep. The
		# bounded ground-only course must not slide into unowned air at its corner.
		motor.retry_activity()
		var edge_source := Supplier.new("controlled-edge-speed","CHAR",[])
		contribution(edge_source,"edge-speed",1,{"run":1000000.0})
		shell.session_shell.view.place_facing(scope,{"version":1,"yaw":0.0,"pitch":0.0})
		key(KEY_W,true)
		key(KEY_D,true)
		var corner := {}
		for index in 12:
			corner = step(0.1)
			if corner.get("handoff_pending",false) or not corner.get("ok",false): break
		key(KEY_W,false)
		key(KEY_D,false)
		var guarded: Vector3 = body.snapshot().position
		measurements.append({"case":"ground wall-slide support boundary","unit":"metre","actual_xyz":[guarded.x,guarded.y,guarded.z],"maximum_supported_x":39.7,"expected_height":0.91,"requested_speed_metres_per_second":100.0,"step_simulated_seconds":0.1})
		check("ground sliding exit reports pending handoff",true,corner.get("handoff_pending",false))
		check("ground slide guard keeps supported course pose",true,guarded.x <= 39.7 and absf(guarded.y-0.91) < 0.0001)
		contribution(edge_source,"edge-speed",2,{})
		check("ground sliding performed debt settles",true,motor.retry_activity().ok)
		check("ground sliding settlement never replays travel",guarded,body.snapshot().position)
		shell.session_shell.view.place_facing(scope,{"version":1,"yaw":90.0,"pitch":0.0})
		motor.retry_activity()
		var vital: Dictionary = actors.vital_projection(scope,"ground-player")
		var drain := {"schema":"vital-intake-v1","session":scope,"actor":"ground-player","caller":"ground-test-fatigue","operation":"ground-predepletion-setup","content":vital.content,"revision":vital.revision,"action":"drain","pool":"fatigue","unit":"internal-64","amount":vital.current.fatigue-1,"attribution":{"source":"controlled-fatigue-setup","cause":"ground-exhaustion-boundary","component":"setup"}}
		fatigue_source.active = drain.duplicate(true)
		check("ground controlled fatigue setup through CHAR",true,actors.vital_intake(fatigue_source,drain).ok)
		key(KEY_W,true)
		for index in 6:
			if actors.vital_projection(scope,"ground-player").zero_fatigue: break
			step(0.1)
		key(KEY_W,false)
		check("ground real movement depletes real fatigue",true,actors.vital_projection(scope,"ground-player").zero_fatigue)
		check("ground exhaustion owns simulation gate",false,actor_core.gates.simulation())
		var exhausted: Vector3 = body.snapshot().position
		step(0.02)
		check("ground exhaustion cannot replay movement",exhausted,body.snapshot().position)
		check("ground CHAR observers see coherent physical gait activity",true,coherent[0])
		actors.activity_committed.disconnect(char_observer)
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join("ground-course.png"))
			check("ground rendered frame observed",true,not shell.get_viewport().get_texture().get_image().is_empty())
		actor_core.request({"id":"ground-return","mode":"return","origin":scope})
		if actor_core.snapshot().phase == "confirmation": actor_core.confirm(actor_core.ticket(),true)
		source_a.callback = Callable()
		course.queue_free()
	var ok := true
	for item in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size(),"fixture":"IMP-012-ground-v1","engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"measurements":measurements,"performance":performance,"source":"Real SessionShell input/view/body/CHAR/DATA/CORE; controlled flat course LOC readiness, entry, TIME, traits, restrictions","inputs":fixture.get("inputs",{})}
