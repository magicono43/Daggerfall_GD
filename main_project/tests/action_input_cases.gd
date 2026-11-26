extends RefCounted
const Core = preload("res://scripts/session/session_lifecycle.gd")
const Provider = preload("res://tests/controlled_session_provider.gd")
const Windows = preload("res://scripts/session/window_stack.gd")
const Actions = preload("res://scripts/input/action_input.gd")
const Bindings = preload("res://scripts/input/action_bindings.gd")
var checks: Array[Dictionary] = []
var serial := 0
var cancellations: Array[Dictionary] = []
var failures: Array[Dictionary] = []
var observations: Dictionary = {}

func check(label: String, passed: bool) -> void:
	checks.append({"scenario":label,"expected":true,"actual":passed})
	if not passed: push_error("IMP-011: " + label)

func key(code: int, pressed: bool, location := 0, echo := false) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.location = location
	event.pressed = pressed
	event.echo = echo
	return event

func button(code: int, pressed: bool, device := 7) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = code
	event.pressed = pressed
	event.device = device
	return event

func mouse(code: int, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = code
	event.pressed = pressed
	return event

func axis(code: int, value: float, device := 7) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = code
	event.axis_value = value
	event.device = device
	return event

func feed(input: RefCounted, event: InputEvent) -> void:
	input.observe(event)
	input.accept(event)

func tap(input: RefCounted, code := KEY_SPACE) -> void:
	feed(input,key(code,true))
	feed(input,key(code,false))

func drain(input: RefCounted) -> Array[Dictionary]:
	return input.deliver(func(_edge: Dictionary) -> Dictionary: return {"kind":"rejected","reason":"controlled consumer cooldown"})

func kinds(outcomes: Array) -> Array:
	return outcomes.map(func(value: Dictionary): return value.edge.kind)

func find_button(shell: Control, prefix: String) -> Button:
	return find_button_in(shell.panel,prefix)

func find_button_in(parent: Node, prefix: String) -> Button:
	for child in parent.get_children():
		if child is Button and child.text.begins_with(prefix): return child
		var nested := find_button_in(child,prefix)
		if nested != null: return nested
	return null

func request(core: SessionLifecycle, mode := "new") -> Dictionary:
	serial += 1
	return core.request({"id":"input-%d" % serial,"mode":mode,"origin":core.snapshot().session,"selection":{}})

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	check("isolated production storage",shell.controller.storage.context.root.begins_with(str(fixture.sandbox)))
	var core := Core.new()
	var provider := Provider.new()
	core.provider = provider
	core.startup_route_changed("main_menu")
	check("controlled real CORE readiness",request(core).kind == "Succeeded")
	var windows := Windows.new(core)
	var entries: Array = Bindings.defaults()
	entries.append({"kind":"key","code":KEY_E,"action":"attack"})
	entries.append({"kind":"key","code":KEY_E,"modifier":"%d:%d" % [KEY_SHIFT,KEY_LOCATION_LEFT],"action":"activate"})
	entries.append({"kind":"trigger","code":JOY_AXIS_TRIGGER_RIGHT,"action":"attack"})
	entries.append({"kind":"mouse","code":MOUSE_BUTTON_WHEEL_UP,"action":"jump"})
	var input := Actions.new(core,windows,Bindings.new(entries))
	input.cancelled.connect(func(report: Dictionary): cancellations.append(report))
	input.failure.connect(func(report: Dictionary): failures.append(report))

	tap(input)
	check("brief tap retains two edges before physics",input.pending_count() == 2 and not input.held("jump"))
	var delivered := drain(input)
	check("brief tap ordered start release",kinds(delivered) == ["started","released"])
	check("tap retains session context hold identity",delivered[0].edge.session == core.snapshot().session and delivered[0].edge.hold == delivered[1].edge.hold and delivered[0].edge.context == windows.context_generation and input.context_current(delivered[0].edge))
	check("receiving owner rejection expires intent",delivered[0].result.kind == "rejected" and drain(input).is_empty())
	tap(input)
	tap(input)
	check("separate taps preserve all ordered edges",kinds(drain(input)) == ["started","released","started","released"])
	for index in 4: check("catch-up update %d has no duplicate" % index,drain(input).is_empty())
	feed(input,key(KEY_SPACE,true))
	feed(input,key(KEY_SPACE,true,0,true))
	feed(input,key(KEY_SPACE,true))
	check("held repeats and echoes cannot start twice",input.pending_count() == 1 and input.held("jump"))
	feed(input,key(KEY_SPACE,false))
	check("repeat leaves single deliberate release",kinds(drain(input)) == ["started","released"])
	# Observe before GUI, accept only after GUI. A GUI-consumed press is never intent.
	input.observe(key(KEY_SPACE,true))
	input.observe(key(KEY_SPACE,false))
	check("GUI consumed press cannot fall through",drain(input).is_empty())

	feed(input,key(KEY_E,true))
	feed(input,mouse(MOUSE_BUTTON_RIGHT,true))
	check("overlap produces one logical start",input.pending_count() == 1 and input.held("attack"))
	feed(input,key(KEY_E,false))
	check("first contributor release retains logical hold",input.pending_count() == 1 and input.held("attack"))
	feed(input,mouse(MOUSE_BUTTON_RIGHT,false))
	check("last contributor deliberate release once",kinds(drain(input)) == ["started","released"])
	feed(input,key(KEY_SHIFT,true,KEY_LOCATION_LEFT))
	feed(input,key(KEY_E,true))
	check("chord precedes plain main key",input.held("activate") and not input.held("attack"))
	feed(input,key(KEY_SHIFT,false,KEY_LOCATION_LEFT))
	check("modifier release cannot switch existing hold",input.held("activate") and not input.held("attack"))
	feed(input,key(KEY_E,false))
	drain(input)
	feed(input,key(KEY_E,true))
	feed(input,key(KEY_SHIFT,true,KEY_LOCATION_LEFT))
	check("late modifier cannot start a second action",input.held("attack") and not input.held("activate"))
	feed(input,key(KEY_E,false))
	feed(input,key(KEY_SHIFT,false,KEY_LOCATION_LEFT))
	drain(input)
	feed(input,key(KEY_SHIFT,true,KEY_LOCATION_RIGHT))
	feed(input,key(KEY_E,true))
	check("modifier sides are explicit",input.held("attack") and not input.held("activate"))
	feed(input,key(KEY_E,false))
	feed(input,key(KEY_SHIFT,false,KEY_LOCATION_RIGHT))
	drain(input)
	feed(input,key(KEY_QUOTELEFT,true))
	feed(input,key(KEY_SHIFT,true,KEY_LOCATION_LEFT))
	feed(input,key(KEY_QUOTELEFT,false))
	feed(input,key(KEY_SHIFT,false,KEY_LOCATION_LEFT))
	check("physical console with late shift toggles once",drain(input).filter(func(v: Dictionary): return v.edge.action == "console" and v.edge.kind == "started").size() == 1)
	feed(input,key(KEY_SHIFT,true,KEY_LOCATION_LEFT))
	tap(input,KEY_QUOTELEFT)
	feed(input,key(KEY_SHIFT,false,KEY_LOCATION_LEFT))
	check("physical shifted console toggles once",drain(input).filter(func(v: Dictionary): return v.edge.action == "console" and v.edge.kind == "started").size() == 1)
	feed(input,mouse(MOUSE_BUTTON_WHEEL_UP,true))
	feed(input,mouse(MOUSE_BUTTON_WHEEL_UP,true))
	check("wheel steps are separate completed taps",kinds(drain(input)) == ["started","released","started","released"])
	var layout_event := key(KEY_SPACE,true)
	layout_event.keycode = KEY_P
	feed(input,layout_event)
	feed(input,key(KEY_SPACE,false))
	check("physical identity ignores active layout label",drain(input)[0].edge.action == "jump")

	feed(input,mouse(MOUSE_BUTTON_RIGHT,true))
	var menu := windows.open("pause",core.snapshot().session)
	check("menu entry cancels pending press synchronously",input.pending_count() == 0 and not input.held("attack") and not cancellations.is_empty())
	check("cancellation is not release",cancellations.back().pending.size() == 1 and cancellations.back().pending[0].kind == "started")
	windows.close(menu.id)
	feed(input,mouse(MOUSE_BUTTON_RIGHT,true))
	check("held return cannot start",drain(input).is_empty())
	feed(input,mouse(MOUSE_BUTTON_RIGHT,false))
	feed(input,mouse(MOUSE_BUTTON_RIGHT,true))
	check("fresh press after return accepted",kinds(drain(input)) == ["started"])
	feed(input,mouse(MOUSE_BUTTON_RIGHT,false))
	var focus := core.gates.acquire("focus-fixture","",["input","simulation"])
	check("focus loss cancels queued release instead of firing",input.pending_count() == 0 and cancellations.back().delivered_unfinished.size() == 1)
	check("focus cancellation names already delivered unfinished hold",cancellations.back().delivered_unfinished[0].action == "attack")
	check("focus blocks delivery",drain(input).is_empty())
	tap(input)
	core.gates.release(focus,"focus-fixture")
	check("blocked focus taps never reach next context",drain(input).is_empty())
	tap(input)
	check("focus recovery fresh tap works",drain(input).size() == 2 and not input.context_current(delivered[0].edge))
	tap(input)
	provider.hold_preflight = true
	request(core,"load")
	check("loading cancels queued completed tap",input.pending_count() == 0 and not core.gates.gameplay_input())
	core.cancel(core.ticket())
	check("cancelled loading cannot resurrect old tap",drain(input).is_empty() and core.gates.gameplay_input())
	provider.hold_preflight = false
	tap(input)
	var old_scope: String = core.snapshot().session
	request(core,"load")
	core.confirm(core.ticket(),true)
	check("replacement session differs",core.snapshot().session != old_scope and core.gates.gameplay_input())
	check("retirement prevents input leakage",drain(input).is_empty())
	tap(input)
	check("new session owns fresh tap",drain(input)[0].edge.session == core.snapshot().session)
	# A context-changing consumer cannot deliver the remainder, even if it closes
	# its window and injects new input reentrantly before returning.
	tap(input)
	var reentrant := input.deliver(func(_edge: Dictionary) -> Dictionary:
		var layer: Dictionary = windows.open("pause",core.snapshot().session)
		windows.close(layer.id)
		tap(input,KEY_X)
		return {"kind":"applied"})
	check("context-changing consumer stops old batch",reentrant.size() == 1)
	check("reentrant new context waits next update",kinds(drain(input)) == ["started","released"])

	input.connection_changed(7,true)
	input.connection_changed(8,true)
	check("connection alone does not select gameplay controller",input.selected_controller == -1)
	check("unknown controller selection rejected",not input.select_controller(99))
	check("explicit connected selection accepted",input.select_controller(7))
	feed(input,button(3,true,8))
	check("unselected controller cannot contribute",drain(input).is_empty())
	feed(input,button(3,true))
	drain(input)
	input.select_controller(8)
	input.connection_changed(8,false)
	var idle_handoff_safe := not input.disconnect_pending() and core.gates.gameplay_input()
	input.select_controller(7)
	feed(input,button(3,true))
	check("selected controller supplies attack",kinds(drain(input)) == ["started"] and input.last_device == "controller" and idle_handoff_safe)
	var other := core.gates.acquire("independent",core.snapshot().session,["input","simulation"])
	input.connection_changed(7,false)
	check("active disconnect adds its own suspension",input.disconnect_pending() and not core.gates.gameplay_input())
	check("disconnect is cancellation not release",not input.held("attack") and drain(input).is_empty())
	check("foreign requester cannot release other hold",not core.gates.release(other,Actions.DISCONNECT_OWNER))
	input.connection_changed(7,true)
	check("reconnection alone never resumes",input.disconnect_pending() and not core.gates.gameplay_input())
	feed(input,button(3,true))
	check("explicit controller continuation succeeds",input.continue_controller())
	check("continuation preserves independent hold",not core.gates.gameplay_input())
	core.gates.release(other,"independent")
	feed(input,button(3,true))
	check("held reconnect button cannot start on resume",drain(input).is_empty())
	feed(input,button(3,false))
	feed(input,button(3,true))
	check("fresh reconnect press works",kinds(drain(input)) == ["started"])
	feed(input,button(3,false))
	drain(input)
	tap(input)
	check("keyboard input changes accepted active device",input.last_device == "keyboard_mouse")
	input.connection_changed(7,false)
	check("idle selected disconnect does not suspend keyboard",not input.disconnect_pending() and core.gates.gameplay_input())
	check("idle disconnect preserves unrelated keyboard pending tap",drain(input).size() == 2)
	feed(input,button(3,true))
	feed(input,axis(JOY_AXIS_LEFT_Y,1.0))
	check("late disconnected device events cannot reactivate input",drain(input).is_empty() and input.movement() == Vector2.ZERO and input.last_device == "keyboard_mouse")
	input.connection_changed(7,true)
	feed(input,button(3,true))
	feed(input,key(KEY_E,true))
	check("controller keyboard overlap starts once",input.pending_count() == 1)
	check("overlapping keyboard contributor becomes active device",input.last_device == "keyboard_mouse")
	input.connection_changed(7,false)
	check("overlap disconnect cancels affected unfinished action",not input.held("attack") and drain(input).is_empty())
	feed(input,key(KEY_E,true))
	check("remaining contributor cannot become new start",drain(input).is_empty())
	feed(input,key(KEY_E,false))
	input.connection_changed(7,true)
	feed(input,button(0,true))
	input.connection_changed(7,false)
	var hold := core.gates.acquire("still-paused",core.snapshot().session,["input"])
	input.continue_keyboard()
	check("keyboard continuation deselects controller",input.selected_controller == -1 and not input.disconnect_pending())
	check("keyboard continuation cannot clear other hold",not core.gates.gameplay_input())
	core.gates.release(hold,"still-paused")
	check("disconnected continuation rejected",not input.continue_controller())
	input.connection_changed(7,true)
	input.select_controller(7)
	feed(input,axis(JOY_AXIS_TRIGGER_RIGHT,0.54))
	check("trigger below press threshold neutral",drain(input).is_empty())
	feed(input,axis(JOY_AXIS_TRIGGER_RIGHT,0.55))
	feed(input,axis(JOY_AXIS_TRIGGER_RIGHT,0.50))
	check("trigger press with hysteresis produces one start",kinds(drain(input)) == ["started"] and input.held("attack"))
	feed(input,axis(JOY_AXIS_TRIGGER_RIGHT,0.45))
	check("trigger deliberate release threshold",kinds(drain(input)) == ["released"])
	tap(input)
	drain(input)
	input.observe(axis(JOY_AXIS_LEFT_Y,1.0))
	check("GUI consumed analog cannot become accepted gameplay",input.movement() == Vector2.ZERO and input.last_device == "keyboard_mouse")
	feed(input,axis(JOY_AXIS_LEFT_Y,0.0))
	feed(input,axis(JOY_AXIS_RIGHT_X,0.05))
	check("deadzone noise cannot steal active device",input.last_device == "keyboard_mouse")
	feed(input,axis(JOY_AXIS_LEFT_Y,1.0))
	check("controller movement full deflection",input.movement().is_equal_approx(Vector2.DOWN))
	feed(input,key(KEY_W,true))
	feed(input,axis(JOY_AXIS_LEFT_Y,1.0))
	check("keyboard forward overrides controller backward",input.movement() == Vector2.UP and input.last_device == "keyboard_mouse")
	feed(input,key(KEY_S,true))
	check("opposing keyboard suppresses stick",input.movement() == Vector2.ZERO)
	feed(input,key(KEY_W,false))
	feed(input,key(KEY_S,false))
	check("release all directions resumes held controller movement",input.movement() == Vector2.DOWN)
	drain(input)
	feed(input,key(KEY_W,true))
	var movement_menu := windows.open("pause",core.snapshot().session)
	check("continuous movement neutral while UI owns context",input.movement() == Vector2.ZERO)
	windows.close(movement_menu.id)
	check("held movement resumes without a new discrete press",input.movement() == Vector2.UP and drain(input).is_empty())
	feed(input,key(KEY_W,false))
	check("movement center deadzone neutral",Actions.radial(Vector2.ZERO,0.15) == Vector2.ZERO)
	check("movement threshold neutral",Actions.radial(Vector2(0.15,0),0.15) == Vector2.ZERO)
	check("look threshold neutral independently",Actions.radial(Vector2(0.10,0),0.10) == Vector2.ZERO)
	check("linear radial rescale",Actions.radial(Vector2(0.575,0),0.15).is_equal_approx(Vector2(0.5,0)))
	check("radial magnitude clamped preserves direction",Actions.radial(Vector2.ONE,0.15).is_equal_approx(Vector2.ONE.normalized()))
	tap(input,KEY_X)
	feed(input,button(3,true))
	feed(input,button(3,false))
	tap(input)
	var partial := input.deliver(func(edge: Dictionary) -> Dictionary:
		if edge.action == "ready_weapon" and edge.kind == "started":
			input.connection_changed(7,false)
			tap(input,KEY_C)
		return {"kind":"applied"})
	check("targeted disconnect retains original batch edges only",partial.size() == 4 and partial.all(func(item: Dictionary): return item.edge.action in ["ready_weapon","jump"]))
	check("new edges after targeted cancellation wait next batch",drain(input).size() == 2)
	input.connection_changed(7,true)
	feed(input,key(KEY_SPACE,true))
	delivered = drain(input)
	check("pre-overflow start delivered separately",delivered.size() == 1)
	for index in Actions.CAPACITY / 2: tap(input,KEY_X)
	check("exact capacity retained",input.pending_count() == Actions.CAPACITY and failures.is_empty())
	var completed_before := input.delivered_edges
	feed(input,key(KEY_E,true))
	check("capacity plus one explicitly fails",failures.size() == 1 and failures[0].pending_edges == Actions.CAPACITY and failures[0].capacity == Actions.CAPACITY)
	check("overflow clears entire unfinished batch",input.pending_count() == 0 and not input.held("jump") and not input.held("attack"))
	check("overflow report distinguishes delivered count",failures[0].delivered_edges == completed_before and delivered[0].edge.kind == "started")
	check("overflow cancels delivered unfinished hold",cancellations.back().reason == "overflow" and cancellations.back().delivered_unfinished.size() == 1)
	check("overflow never delivers cancelled release",drain(input).is_empty())
	feed(input,key(KEY_E,true))
	feed(input,key(KEY_SPACE,true))
	check("overflow requires fresh presses",drain(input).is_empty())
	feed(input,key(KEY_E,false))
	feed(input,key(KEY_SPACE,false))
	check("overflow physical releases cannot fire",drain(input).is_empty())
	tap(input)
	check("fresh input recovers after overflow",kinds(drain(input)) == ["started","released"])
	for index in Actions.CAPACITY / 2: tap(input,KEY_X)
	var started := Time.get_ticks_usec()
	var full := drain(input)
	observations.capacity_delivery_usec = Time.get_ticks_usec()-started
	check("full capacity can deliver without failure",full.size() == Actions.CAPACITY and failures.size() == 1)
	check("full capacity catch-up cannot replay",drain(input).is_empty())
	input.dispose()
	core.dispose()

	# Actual stock composition and host dispatch, not an alternate input owner.
	var startup_provider = preload("res://tests/controlled_startup_provider.gd").new()
	startup_provider.resolved_source = str(fixture.sandbox).path_join("controlled-classic")
	shell.controller.providers = startup_provider
	shell.controller.check_content()
	shell.render()
	var stock: RefCounted = shell.session_shell
	stock.core.provider = Provider.new()
	# This asset-independent stock-input fixture replaces DATA with a controlled
	# non-DATA startup provider. It cannot qualify the required calendar owner;
	# complete-composition calendar cases separately verify that production path.
	stock.core.calendar.definitions = null
	observations.calendar_dependency = "unavailable in asset-independent input fixture; qualified by calendar-clock-v1"
	stock.core.startup_route_changed("main_menu")
	check("stock controlled session begins",request(stock.core).kind == "Succeeded" and shell.controller.route == "main_menu")
	var events: Array = []
	var callback := func(edge: Dictionary): events.append(edge)
	stock.gameplay_edge.connect(callback)
	for event: InputEvent in [key(KEY_SPACE,true),key(KEY_SPACE,false)]:
		shell._input(event)
		shell._unhandled_input(event)
	var stock_results: Array = stock.deliver_input()
	check("stock host delivers actual brief tap",events.size() == 2 and stock_results.size() == 2 and events[0].kind == "started" and events[1].kind == "released" and events[0].is_read_only())
	check("stock host catch-up no duplicates",stock.deliver_input().is_empty())
	for event: InputEvent in [key(KEY_F7,true),key(KEY_F7,false)]:
		shell._input(event)
		shell._unhandled_input(event)
	var hud_before: bool = stock.core.gates.hud_preference
	stock.deliver_input()
	check("F7 reaches actual CORE HUD preference",stock.core.gates.hud_preference != hud_before)
	for event: InputEvent in [key(KEY_F9,true),key(KEY_F9,false),key(KEY_F11,true),key(KEY_F11,false)]:
		shell._input(event)
		shell._unhandled_input(event)
	stock.deliver_input()
	check("stock quicksave quickload conflict rejects both",stock.message.contains("conflict") and stock.windows.top().is_empty())
	check("stock shortcut priority stable",stock.windows.dispatch_actions(["inventory","character"]).action == "character")
	check("stock shortcut conflict with another winner",stock.windows.dispatch_actions(["quicksave","quickload","inventory"]).action == "inventory")
	check("shortcut feedback expires with its dispatch",stock.windows.last_feedback.contains("conflict") and stock.windows.dispatch_actions([]).kind == "none" and stock.windows.last_feedback.is_empty())
	check("suppressed shortcuts not queued",stock.windows.dispatch().kind == "none")
	for event: InputEvent in [key(KEY_F,true),key(KEY_F,false)]:
		shell._input(event)
		shell._unhandled_input(event)
	stock.deliver_input()
	check("cast spell routes spellbook without casting",stock.message == "Spellbook support is unavailable.")
	var focus_during_delivery := func(edge: Dictionary):
		if edge.action == "jump" and edge.kind == "started":
			var token: int = stock.core.gates.acquire("consumer-focus","",["input"])
			stock.core.gates.release(token,"consumer-focus")
	stock.gameplay_edge.connect(focus_during_delivery)
	stock.message = "context sentinel"
	for event: InputEvent in [key(KEY_F,true),key(KEY_F,false),key(KEY_SPACE,true),key(KEY_SPACE,false)]:
		shell._input(event)
		shell._unhandled_input(event)
	stock.deliver_input()
	check("stock shortcut cannot survive transient eligibility handoff",stock.message == "context sentinel")
	stock.gameplay_edge.disconnect(focus_during_delivery)
	shell._input(mouse(MOUSE_BUTTON_RIGHT,true))
	shell._unhandled_input(mouse(MOUSE_BUTTON_RIGHT,true))
	shell._input(key(KEY_ESCAPE,true))
	shell._unhandled_input(key(KEY_ESCAPE,true))
	check("reserved recovery invalidates before next physics",stock.action_input.pending_count() == 0 and stock.deliver_input().is_empty())
	shell._process(0.0)
	check("reserved Escape still opens pause",stock.windows.top().get("window") == "pause")
	shell._input(key(KEY_ESCAPE,false))
	shell._unhandled_input(key(KEY_ESCAPE,false))
	shell._input(mouse(MOUSE_BUTTON_RIGHT,false))
	stock.windows.close(stock.windows.top().id)
	var external: int = stock.core.gates.acquire("physical-focus-independent","",["input"])
	stock.focus_changed(false)
	stock.focus_changed(true)
	check("stock focus return preserves other requester",not stock.core.gates.gameplay_input())
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	stock.core.gates.release(external,"physical-focus-independent")
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	check("last independent hold clears stale gameplay GUI focus",stock.core.gates.gameplay_input() and shell.get_viewport().gui_get_focus_owner() == null)
	stock.controller_connection_changed(7,true)
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var select := find_button(shell,"Select Controller 7")
	check("stock explicit controller selection control exists",select != null)
	if select != null: select.pressed.emit()
	check("stock selection handler reaches input owner",stock.action_input.selected_controller == 7)
	shell._input(button(3,true))
	shell._unhandled_input(button(3,true))
	stock.deliver_input()
	var independent: int = stock.core.gates.acquire("stock-controller-independent","",["input"])
	stock.controller_connection_changed(7,false)
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var keyboard := find_button(shell,"Continue with Keyboard")
	check("stock disconnect prompt exposes keyboard recovery",keyboard != null and stock.action_input.disconnect_pending())
	if keyboard != null: keyboard.pressed.emit()
	check("stock continuation handler preserves other gate",not stock.action_input.disconnect_pending() and stock.action_input.selected_controller == -1 and not stock.core.gates.gameplay_input())
	stock.core.gates.release(independent,"stock-controller-independent")
	var start := button(JOY_BUTTON_START,true,98)
	shell._input(start)
	shell._unhandled_input(start)
	shell._process(0.0)
	check("unselected controller reserved Start recovers menu",stock.windows.top().get("window") == "pause")
	shell._unhandled_input(button(JOY_BUTTON_START,false,98))
	shell._input(button(JOY_BUTTON_B,true,98))
	shell._unhandled_input(button(JOY_BUTTON_B,true,98))
	shell._process(0.0)
	check("controller Back closes existing UI context",stock.windows.top().is_empty())
	shell._input(button(JOY_BUTTON_B,false,98))
	shell._unhandled_input(button(JOY_BUTTON_B,false,98))
	shell._input(key(KEY_ESCAPE,true))
	shell._unhandled_input(key(KEY_ESCAPE,true))
	shell._process(0.0)
	shell._input(button(JOY_BUTTON_START,true,98))
	shell._unhandled_input(button(JOY_BUTTON_START,true,98))
	shell._input(key(KEY_ESCAPE,false))
	shell._unhandled_input(key(KEY_ESCAPE,false))
	shell._input(key(KEY_ESCAPE,true))
	shell._unhandled_input(key(KEY_ESCAPE,true))
	shell._process(0.0)
	check("overlapping reserved bindings cannot toggle twice",stock.windows.top().get("window") == "pause")
	shell._input(key(KEY_ESCAPE,false))
	shell._unhandled_input(key(KEY_ESCAPE,false))
	shell._input(button(JOY_BUTTON_START,false,98))
	shell._unhandled_input(button(JOY_BUTTON_START,false,98))
	stock.windows.close(stock.windows.top().id)
	# Engine event route: GUI-less gameplay capture and real physics callback.
	await shell.get_tree().process_frame
	events.clear()
	Input.parse_input_event(key(KEY_SPACE,true))
	Input.parse_input_event(key(KEY_SPACE,false))
	await shell.get_tree().physics_frame
	await shell.get_tree().process_frame
	check("engine routed tap reached production physics dispatch",events.size() == 2 and events[0].kind == "started" and events[1].kind == "released" and stock.action_input.pending_count() == 0 and shell.get_viewport().gui_get_focus_owner() == null)
	events.clear()
	var mouse_position := Vector2(900,150)
	var motion := InputEventMouseMotion.new()
	motion.position = mouse_position
	motion.global_position = mouse_position
	Input.parse_input_event(motion)
	for down: bool in [true,false]:
		var click := mouse(MOUSE_BUTTON_RIGHT,down)
		click.position = mouse_position
		click.global_position = mouse_position
		Input.parse_input_event(click)
	await shell.get_tree().physics_frame
	await shell.get_tree().process_frame
	check("engine mouse tap in blank stock space reaches gameplay",events.size() == 2 and events[0].action == "attack" and events[0].kind == "started" and events[1].kind == "released")
	if DisplayServer.get_name() != "headless":
		events.clear()
		var pause_button := find_button(shell,"Pause")
		mouse_position = pause_button.get_global_rect().get_center()
		motion = InputEventMouseMotion.new()
		motion.position = mouse_position
		motion.global_position = mouse_position
		Input.parse_input_event(motion)
		for down: bool in [true,false]:
			var click := mouse(MOUSE_BUTTON_LEFT,down)
			click.position = mouse_position
			click.global_position = mouse_position
			Input.parse_input_event(click)
		await shell.get_tree().process_frame
		await shell.get_tree().process_frame
		check("actual stock Pause mouse click consumes gameplay activation",stock.windows.top().get("window") == "pause" and events.is_empty())
		Input.parse_input_event(key(KEY_ESCAPE,true))
		Input.parse_input_event(key(KEY_ESCAPE,false))
		await shell.get_tree().process_frame
		await shell.get_tree().process_frame
		check("mouse-opened pause returns through reserved recovery",stock.windows.top().is_empty() and stock.core.gates.gameplay_input())
		stock.core.provider.hold_preflight = true
		stock.request("load")
		await shell.get_tree().process_frame
		await shell.get_tree().process_frame
		events.clear()
		Input.parse_input_event(key(KEY_SPACE,true))
		Input.parse_input_event(key(KEY_SPACE,false))
		await shell.get_tree().physics_frame
		await shell.get_tree().process_frame
		check("focused Cancel consumes Space without gameplay fallthrough",not stock.core.busy() and stock.core.gates.gameplay_input() and events.is_empty())
		stock.core.provider.hold_preflight = false
		Input.parse_input_event(key(KEY_SPACE,true))
		Input.parse_input_event(key(KEY_SPACE,false))
		await shell.get_tree().physics_frame
		await shell.get_tree().process_frame
		check("fresh Space after UI cancellation delivers one jump",events.size() == 2 and events[0].action == "jump" and events[0].kind == "started" and events[1].kind == "released")
	stock.gameplay_edge.disconnect(callback)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var image := shell.get_viewport().get_texture().get_image()
		check("rendered stock frame available",not image.is_empty())
		image.save_png(str(fixture.sandbox).path_join("action-input.png"))
	var ok := checks.all(func(item: Dictionary): return item.expected == item.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"observations":observations,"inputs":{"sequence":"action-input-v1 fixed events","capacity":Actions.CAPACITY,"controller":"injected interface; no physical device claim","clock":"explicit delivery and engine frame boundaries; no RNG"}}
