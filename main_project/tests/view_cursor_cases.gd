extends "res://tests/action_input_cases.gd"
const View = preload("res://scripts/input/view_cursor.gd")
const Configuration = preload("res://scripts/input/binding_configuration.gd")

func motion(value: Vector2, position := Vector2(640,360)) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.relative = value
	event.position = position
	return event

func near(a: float, b: float) -> bool: return absf(a-b) < 0.002

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var core := Core.new()
	core.provider = Provider.new()
	core.startup_route_changed("main_menu")
	check("view real CORE readiness",request(core).kind == "Succeeded")
	var windows := Windows.new(core)
	var actions := Actions.new(core,windows)
	var target := SubViewport.new()
	target.size = Vector2i(1280,720)
	var container := SubViewportContainer.new()
	shell.add_child(container)
	container.add_child(target)
	var camera := Camera3D.new()
	target.add_child(camera)
	camera.current = true
	var view := View.new(actions,target,camera)
	var config := Configuration.defaults()
	check("default view consumer configures",view.configure(config))
	view.advance(0.0)
	feed(actions,motion(Vector2(100,20)))
	view.advance(0.001)
	check("mouse angular displacement independent of delta",near(view.facing.x,10.0) and near(view.facing.y,2.0))
	view.advance(0.5)
	check("mouse impulse consumed once across catchup",near(view.facing.x,10.0))
	feed(actions,motion(Vector2(30,0)))
	feed(actions,motion(Vector2(70,0)))
	view.advance(0.1)
	check("mouse events accumulate before presentation",near(view.facing.x,20.0))
	for index: int in 40:
		feed(actions,motion(Vector2(1000,0)))
		view.advance(0.01)
	check("repeated unrestricted yaw wraps without limit",near(view.facing.x,60.0))
	feed(actions,motion(Vector2(0,10000)))
	view.advance(0.1)
	check("positive pitch clamps at 89",near(view.facing.y,89.0))
	feed(actions,motion(Vector2(0,-10)))
	view.advance(0.1)
	check("pitch clamp discards hidden overshoot",near(view.facing.y,88.0))
	feed(actions,motion(Vector2(0,-10000)))
	view.advance(0.1)
	check("negative pitch clamps at minus 89",near(view.facing.y,-89.0))
	view.center()
	check("center preserves yaw and levels actual camera",near(view.facing.x,60.0) and near(view.facing.y,0.0) and near(camera.rotation.x,0.0))
	check("ordinary camera has no roll",near(camera.rotation.z,0.0))
	var scope: String = core.gates.session
	check("placement accepts current scoped actual facing",view.place_facing(scope,{"version":1,"yaw":15.0,"pitch":20.0}))
	check("placement rejects stale scope",not view.place_facing("stale",{"version":1,"yaw":0,"pitch":0}))
	check("placement rejects nonfinite pitch",not view.place_facing(scope,{"version":1,"yaw":0,"pitch":NAN}))
	check("placement rejects excessive pitch",not view.place_facing(scope,{"version":1,"yaw":0,"pitch":90}))
	var captured: Dictionary = view.capture_facing(scope)
	captured.pitch = 1.0
	check("facing capture is detached",near(view.capture_facing(scope).pitch,20.0))
	config.response.mouse_x = 0.2
	config.response.mouse_y = 0.3
	config.response.mouse_invert = true
	view.configure(config)
	view.advance(0.0)
	feed(actions,motion(Vector2(10,10)))
	view.advance(0.01)
	check("mouse axes and vertical inversion independent",near(view.facing.x,17.0) and near(view.facing.y,17.0))
	config = Configuration.defaults()
	view.configure(config)
	view.place_facing(scope,{"version":1,"yaw":0,"pitch":0})
	view.advance(0.0)
	feed(actions,key(KEY_RIGHT,true))
	view.advance(0.5)
	check("keyboard look uses eligible angular rate",near(view.facing.x,45.0))
	actions.connection_changed(7,true)
	actions.select_controller(7)
	view.advance(0.0)
	feed(actions,axis(JOY_AXIS_RIGHT_X,1.0))
	feed(actions,key(KEY_RIGHT,false))
	feed(actions,key(KEY_RIGHT,true))
	feed(actions,key(KEY_LEFT,true))
	view.advance(0.5)
	check("opposing keyboard look suppresses controller",near(view.facing.x,45.0))
	feed(actions,key(KEY_LEFT,false))
	feed(actions,motion(Vector2(100,0)))
	view.advance(0.5)
	check("mouse suppresses keyboard and controller",near(view.facing.x,55.0))
	feed(actions,motion(Vector2(10,0)))
	feed(actions,motion(Vector2(-10,0)))
	view.advance(0.5)
	check("zero net mouse accumulation still suppresses rates",near(view.facing.x,55.0))
	view.advance(0.5)
	check("keyboard suppresses controller rate",near(view.facing.x,100.0))
	feed(actions,key(KEY_RIGHT,false))
	view.advance(0.25)
	check("selected controller rate applies alone",near(view.facing.x,145.0))
	feed(actions,axis(JOY_AXIS_RIGHT_X,0.1))
	view.advance(0.2)
	check("controller look threshold produces no rotation",near(view.facing.x,145.0))
	feed(actions,axis(JOY_AXIS_RIGHT_X,0.55))
	view.advance(0.2)
	check("controller radial linear response",near(view.facing.x,163.0))
	feed(actions,axis(JOY_AXIS_RIGHT_X,0.0))
	config.response.controller_x = 60.0
	config.response.controller_y = 40.0
	config.response.controller_invert = true
	view.configure(config)
	view.place_facing(scope,{"version":1,"yaw":0,"pitch":0})
	view.advance(0.0)
	feed(actions,axis(JOY_AXIS_RIGHT_Y,1.0))
	view.advance(0.5)
	check("independent controller vertical rate and inversion",near(view.facing.y,-20.0) and near(view.facing.x,0.0))
	feed(actions,axis(JOY_AXIS_RIGHT_Y,0.0))
	config = Configuration.defaults()
	# Exact rate integration: equal elapsed time, independent render cadence.
	var outcomes: Array = []
	for fps: int in [30,60,144]:
		view.configure(config)
		view.place_facing(scope,{"version":1,"yaw":0,"pitch":0})
		view.advance(0.0)
		feed(actions,key(KEY_RIGHT,true))
		for index: int in fps: view.advance(1.0/fps)
		outcomes.append(view.facing.x)
		feed(actions,key(KEY_RIGHT,false))
	check("unsmoothed keyboard equal elapsed time at 30 60 144",near(outcomes[0],90.0) and near(outcomes[0],outcomes[1]) and near(outcomes[1],outcomes[2]))
	outcomes.clear()
	for fps: int in [30,60,144]:
		view.configure(config)
		view.place_facing(scope,{"version":1,"yaw":0,"pitch":0})
		view.advance(0.0)
		feed(actions,axis(JOY_AXIS_RIGHT_X,1.0))
		for index: int in fps: view.advance(0.5/fps)
		outcomes.append(view.facing.x)
	check("unsmoothed controller equal elapsed time at 30 60 144",near(outcomes[0],90.0) and near(outcomes[0],outcomes[1]) and near(outcomes[1],outcomes[2]))
	feed(actions,axis(JOY_AXIS_RIGHT_X,0.0))
	outcomes.clear()
	for fps: int in [30,60,144]:
		config.response.keyboard_smoothing = true
		view.configure(config)
		view.place_facing(scope,{"version":1,"yaw":0,"pitch":0})
		view.advance(0.0)
		feed(actions,key(KEY_RIGHT,true))
		for index: int in fps: view.advance(1.0/fps)
		outcomes.append(view.facing.x)
		feed(actions,key(KEY_RIGHT,false))
	check("smoothed keyboard equal elapsed time at 30 60 144",near(outcomes[0],outcomes[1]) and near(outcomes[1],outcomes[2]))
	outcomes.clear()
	for fps: int in [30,60,144]:
		config.response.controller_smoothing = true
		view.configure(config)
		view.place_facing(scope,{"version":1,"yaw":0,"pitch":0})
		view.advance(0.0)
		feed(actions,axis(JOY_AXIS_RIGHT_X,1.0))
		for index: int in fps: view.advance(1.0/fps)
		outcomes.append(view.facing.x)
	check("smoothed controller equal elapsed time at 30 60 144",near(outcomes[0],outcomes[1]) and near(outcomes[1],outcomes[2]))
	feed(actions,axis(JOY_AXIS_RIGHT_X,0.0))
	outcomes.clear()
	for fps: int in [30,60,144]:
		config.response.mouse_smoothing = true
		view.configure(config)
		view.place_facing(scope,{"version":1,"yaw":0,"pitch":0})
		view.advance(0.0)
		feed(actions,motion(Vector2(100,0)))
		for index: int in fps: view.advance(0.1/fps)
		outcomes.append(view.facing.x)
	check("smoothed mouse impulse equal elapsed time at 30 60 144",near(outcomes[0],outcomes[1]) and near(outcomes[1],outcomes[2]))
	check("smoothing displays actual intermediate facing",view.facing.x > 0.0 and view.facing.x < 10.0)
	var ray: Dictionary = view.ray_context(scope)
	check("center ray follows displayed camera not target",ray.ok and ray.direction.is_equal_approx(-camera.global_basis.z) and near(ray.yaw,view.facing.x))
	check("ray rejects stale session",not view.ray_context("stale").ok)
	ray.yaw = 100.0
	check("ray projection detached",not near(view.ray_context(scope).yaw,100.0))
	view.center()
	var before: Vector2 = view.facing
	view.advance(0.0)
	view.advance(1.0)
	check("center clears smoothing tail",view.facing.is_equal_approx(before))
	feed(actions,motion(Vector2(100,0)))
	view.advance(0.01)
	var opened := windows.open("pause",scope)
	check("ray ticket expires at context handoff",not view.ray_context_current(ray))
	before = view.facing
	view.advance(1.0)
	check("menu clears pending smoothing immediately",view.facing.is_equal_approx(before))
	check("menu owns visible backend cursor",Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)
	windows.close(opened.id,true)
	feed(actions,motion(Vector2(10000,0)))
	view.advance(0.01)
	view.advance(1.0)
	check("menu return rejects queued recapture delta",view.facing.is_equal_approx(before))
	check("eligible captured request with rendered backend verification",view.requested_mouse_mode == Input.MOUSE_MODE_CAPTURED and (DisplayServer.get_name() == "headless" or Input.mouse_mode == Input.MOUSE_MODE_CAPTURED))
	check("gameplay cursor enters through owner",view.toggle())
	check("gameplay cursor centers in viewport",view.cursor.is_equal_approx(Vector2(640,360)))
	check("cursor mode does not pause CORE",core.gates.gameplay_input() and core.gates.simulation())
	view.advance(0.0)
	feed(actions,motion(Vector2(100,0),Vector2(900,400)))
	view.advance(0.1)
	check("cursor mouse motion preserves facing",view.facing.is_equal_approx(before) and view.cursor.is_equal_approx(Vector2(900,400)))
	check("cursor ray selects cursor point",view.ray_context(scope).point == Vector2(900,400))
	check("cursor ray differs from forward",not view.ray_context(scope).direction.is_equal_approx(-camera.global_basis.z))
	var distances: Array = []
	for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080)]:
		target.size = size
		view._center_cursor()
		var start: Vector2 = view.cursor
		feed(actions,axis(JOY_AXIS_RIGHT_X,1.0))
		view.advance(0.1)
		distances.append((view.cursor.x-start.x)/float(size.x))
	check("controller cursor matched UI distance across viewport sizes",near(distances[0],80.0/1280.0) and near(distances[0],distances[1]))
	feed(actions,axis(JOY_AXIS_RIGHT_X,0.0))
	feed(actions,motion(Vector2.ZERO,Vector2(10000,-20)))
	check("cursor clamps to active viewport",view.cursor == Vector2(1920,0))
	opened = windows.open("pause",scope)
	windows.close(opened.id,true)
	view.advance(0.0)
	check("menu preserves gameplay cursor selection and recenters",view.cursor_mode and view.cursor == Vector2(960,540))
	view.toggle()
	view.advance(0.0)
	check("cursor exit preserves facing",view.facing.is_equal_approx(before))
	check("cursor exit restores center ray",view.ray_context(scope).point == Vector2(960,540))
	feed(actions,mouse(MOUSE_BUTTON_RIGHT,true))
	drain(actions)
	feed(actions,motion(Vector2(100,0)))
	view.advance(0.01)
	check("ordinary attack does not reserve look",view.facing.x != before.x)
	feed(actions,mouse(MOUSE_BUTTON_RIGHT,false))
	drain(actions)
	check("ineligible gesture cannot reserve mouse",view.reserve_mouse("combat",scope,false).is_empty())
	var token: Dictionary = view.reserve_mouse("combat",scope,true)
	check("eligible gesture gets scoped reservation",not token.is_empty())
	before = view.facing
	view.advance(0.0)
	feed(actions,motion(Vector2(100,0)))
	view.advance(1.0)
	check("gesture stops mouse and smoothing immediately",view.facing.is_equal_approx(before))
	var forged: Dictionary = token.duplicate(true)
	forged.requester = "other"
	check("gesture rejects foreign release",not view.release_mouse(forged))
	check("gesture releases only matching token",view.release_mouse(token))
	view.advance(0.0)
	view.advance(1.0)
	check("gesture exit cannot replay motion",view.facing.is_equal_approx(before))
	feed(actions,motion(Vector2(100,10000)))
	view.advance(0.2)
	feed(actions,motion(Vector2(0,-10)))
	view.advance(0.2)
	check("smoothed pitch clamp has no overshoot debt",view.facing.y < 89.0)
	config.response.mouse_smoothing = false
	view.configure(config)
	before = view.facing
	view.advance(0.0)
	view.advance(1.0)
	check("smoothing disable discards previous tail",view.facing.is_equal_approx(before))
	feed(actions,motion(Vector2(10,0)))
	view.advance(0.01)
	check("smoothing fully off restores direct impulse",near(view.facing.x,wrapf(before.x+1.0,-180.0,180.0)))
	var hold := core.gates.acquire("other",scope,["input","simulation"])
	before = view.facing
	feed(actions,motion(Vector2(10000,0)))
	view.advance(1.0)
	check("independent hold blocks view and ray",view.facing.is_equal_approx(before) and not view.ray_context(scope).ok)
	core.gates.release(hold,"other")
	view.advance(0.0)
	view.advance(1.0)
	check("final independent hold release has no stale motion",view.facing.is_equal_approx(before))
	actions.connection_changed(7,false)
	view.advance(0.1)
	check("controller disconnect clears accepted look",view.facing.is_equal_approx(before))
	actions.connection_changed(7,true)
	view.advance(0.1)
	check("controller reconnect does not replay deflection",view.facing.is_equal_approx(before))
	view.toggle()
	check("native restore selects captured look",view.place_facing(scope,{"version":1,"yaw":120.0,"pitch":-30.0},true) and not view.cursor_mode)
	view.advance(0.0)
	view.advance(1.0)
	check("native restore clears history and applies actual camera",near(view.facing.x,120.0) and near(view.facing.y,-30.0) and near(rad_to_deg(camera.rotation.y),-120.0))
	var invalid := config.duplicate(true)
	invalid.response.mouse_x = INF
	check("view rejection retains working configuration",not view.configure(invalid) and near(view._response.mouse_x,0.1))
	var old := config.duplicate(true)
	old.response.erase("mouse_smoothing_seconds")
	old.response.mouse_x = 0.25
	old.actions.jump.keyboard = [{},{}]
	old.response.unknown_response = "opaque"
	var owner := Configuration.new()
	var upgraded: Dictionary = owner.upgrade(old)
	check("compatible smoothing addition preserves existing controls",Configuration.valid(upgraded) and upgraded.actions.jump.keyboard == [{},{}] and near(upgraded.response.mouse_x,0.25) and upgraded.response.unknown_response == "opaque")
	view.dispose()
	actions.dispose()
	core.dispose()
	container.queue_free()
	# Actual stock settings handlers and normal input dispatch.
	var stock = shell.session_shell
	shell.controller.route = "main_menu"
	stock.synchronize_startup()
	stock.core.provider = Provider.new()
	check("stock session admits controlled provider",stock.request("new").kind == "Succeeded")
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	stock.open_controls()
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var spin := shell.panel.find_child("mouse_x",true,false) as SpinBox
	check("stock view preference widget exists",spin != null)
	spin.value = 0.35
	check("stock widget stages without effective mutation",near(shell.controller.controls.draft().response.mouse_x,0.35) and near(stock.view._response.mouse_x,0.1))
	find_button(shell,"Apply Controls").pressed.emit()
	await shell.get_tree().process_frame
	check("stock Apply updates view and input coherently",near(stock.view._response.mouse_x,0.35) and shell.controller.controls.effective() == shell.controller.settings.effective[Configuration.SETTING])
	var persisted := ConfigFile.new()
	persisted.load(shell.controller.settings.path)
	check("stock Apply persists response independently",near(persisted.get_value("controls","configuration",{}).get("response",{}).get("mouse_x",0.0),0.35))
	var settings: StartupSettingsOwner = shell.controller.settings
	var old_text := FileAccess.get_file_as_string(settings.path)
	var old_root := str(fixture.sandbox).path_join("before-retry")
	DirAccess.make_dir_recursive_absolute(old_root)
	FileAccess.open(old_root.path_join("settings.ini"),FileAccess.WRITE).store_string(old_text)
	spin = shell.panel.find_child("mouse_x",true,false) as SpinBox
	spin.value = 0.45
	settings.adapter.faults.settings_stage = true
	find_button(shell,"Apply Controls").pressed.emit()
	await shell.get_tree().process_frame
	check("failed save retains effective view and accepted response",near(stock.view._response.mouse_x,0.45) and near(shell.controller.controls.effective().response.mouse_x,0.45))
	check("failed save does not alter persisted file",FileAccess.get_file_as_string(settings.path) == old_text)
	check("failed view save visibly reports UNSAVED and retry","UNSAVED" in shell.controller.controls.status and find_button(shell,"Retry Save Controls") != null)
	settings.adapter.faults.clear()
	find_button(shell,"Retry Save Controls").pressed.emit()
	await shell.get_tree().process_frame
	persisted.load(settings.path)
	check("stock retry persists effective view response",near(persisted.get_value("controls","configuration").response.mouse_x,0.45))
	var recreated := View.new(stock.action_input,shell.get_viewport(),stock.view_camera)
	check("recreated view receives effective preferences",shell.controller.controls.attach(recreated) and near(recreated._response.mouse_x,0.45))
	shell.controller.controls.detach(recreated)
	recreated.dispose()
	spin = shell.panel.find_child("mouse_x",true,false) as SpinBox
	spin.value = 0.55
	stock.close_controls()
	check("stock Cancel discards view draft without undoing applied values",shell.controller.controls.draft().is_empty() and near(stock.view._response.mouse_x,0.45))
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	Input.parse_input_event(key(KEY_ENTER,true))
	Input.parse_input_event(key(KEY_ENTER,false))
	await shell.get_tree().physics_frame
	await shell.get_tree().process_frame
	check("stock rebindable cursor toggle is consumed",stock.view.cursor_mode)
	Input.parse_input_event(key(KEY_HOME,true))
	Input.parse_input_event(key(KEY_HOME,false))
	await shell.get_tree().physics_frame
	await shell.get_tree().process_frame
	check("stock Center view actual camera levels",near(stock.view_camera.rotation.x,0.0))
	if DisplayServer.get_name() != "headless":
		var deliveries: Array = []
		var callback := func(edge: Dictionary): deliveries.append(edge)
		stock.gameplay_edge.connect(callback)
		var pause_button := find_button(shell,"Pause")
		var click := mouse(MOUSE_BUTTON_LEFT,true)
		click.position = pause_button.get_global_rect().get_center()
		click.global_position = click.position
		var hover := motion(Vector2.ZERO,click.position)
		hover.global_position = click.position
		Input.parse_input_event(hover)
		Input.parse_input_event(click)
		var up := mouse(MOUSE_BUTTON_LEFT,false)
		up.position = click.position
		up.global_position = click.position
		Input.parse_input_event(up)
		Input.flush_buffered_events()
		await shell.get_tree().physics_frame
		await shell.get_tree().process_frame
		check("stock HUD widget consumes click before world activation",stock.windows.top().get("window") == "pause" and deliveries.is_empty())
		if not stock.windows.top().is_empty(): stock.windows.close(stock.windows.top().id,true)
		await shell.get_tree().process_frame
		await shell.get_tree().process_frame
		check("menu close does not synthesize activation",deliveries.is_empty())
		stock.gameplay_edge.disconnect(callback)
	stock.focus_changed(false)
	check("focus loss releases backend capture",Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)
	stock.focus_changed(true)
	await shell.get_tree().process_frame
	check("focus return restores selected cursor mode",stock.view.cursor_mode and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)
	if DisplayServer.get_name() != "headless":
		var world := preload("res://tests/view_review.gd").geometry(shell)
		stock.view.place_facing(stock.core.gates.session,{"version":1,"yaw":0,"pitch":0})
		await RenderingServer.frame_post_draw
		var image := shell.get_viewport().get_texture().get_image()
		check("rendered stock camera frame available",not image.is_empty())
		var red_pixels := 0
		for y: int in range(300,600,10):
			for x: int in range(450,850,10):
				var pixel := image.get_pixel(x,y)
				if pixel.r > pixel.g*1.5 and pixel.r > pixel.b*1.5: red_pixels += 1
		check("rendered camera presents controlled facing geometry",red_pixels > 100)
		image.save_png(str(fixture.sandbox).path_join("view-cursor.png"))
		world.queue_free()
	return {"ok":checks.all(func(item: Dictionary): return item.expected == item.actual),"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":{"sequence":"view-cursor-v1","controller":"injected","elapsed":"explicit eligible seconds"}}
