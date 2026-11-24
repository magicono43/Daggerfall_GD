extends RefCounted
## Stock title/pause/modal presentation in the existing application shell.
const Lifecycle = preload("res://scripts/session/session_lifecycle.gd")
const Windows = preload("res://scripts/session/window_stack.gd")
const Actions = preload("res://scripts/input/action_input.gd")
var core: SessionLifecycle
var windows: Windows
var action_input: Actions
var view: RefCounted
var view_camera: Camera3D
signal gameplay_edge(edge: Dictionary)
signal gameplay_cancelled(report: Dictionary)
var host: Control
var _counter := 0
var _focus_hold := 0
var _quit_hold := 0
var _recovery_hold := 0
var _recovery_inputs: Dictionary = {}
var quit_phase := ""
var quit_consent_scope := ""
var setup_pending := false
var message := ""
var _render_pending := false
var _prompt_owners: Dictionary = {}
var _startup_route := ""
var _synchronizing_startup := false
var music_playback: Node
var video_playback: Control
var ambience_requests := preload("res://scripts/av/ambience_requests.gd").new()
var _media_shutdown_started := false
var binding_editor: RefCounted
var _ui_controller_down: Dictionary = {}
var _ui_triggers: Dictionary = {}
var _keyboard_layout := -1
var dungeon_assembly: Node
var placement: Node3D

func refresh_control_labels() -> void:
	if windows.top().get("window") != "controls" or DisplayServer.get_name() == "headless": return
	var layout := DisplayServer.keyboard_get_current_layout()
	if layout != _keyboard_layout:
		_keyboard_layout = layout
		schedule_render()

func open_controls() -> void:
	host.controller.controls.begin()
	windows.open("controls",core.snapshot().session)

func close_controls() -> void:
	if binding_editor != null: binding_editor.stop_capture()
	host.controller.controls.cancel()
	if windows.top().get("window") == "controls": windows.close(windows.top().id,true)

func route_controls(event: InputEvent) -> bool:
	if binding_editor != null and windows.top().get("window") == "controls" and binding_editor.route(event):
		if event is InputEventJoypadButton or (event is InputEventJoypadMotion and event.axis in [JOY_AXIS_TRIGGER_LEFT,JOY_AXIS_TRIGGER_RIGHT]):
			var value: Dictionary = binding_editor.event_value(event)
			var identity := "%d:%s:%d" % [value.device,value.kind,value.code]
			if value.pressed: _ui_controller_down[identity] = {"consumed":true}
			else: _ui_controller_down.erase(identity)
		return true
	# Controller UI mappings do not alter Godot's global InputMap or text entry.
	# Intercept legacy Confirm/Back as well, so cleared slots stay cleared.
	var kind := "button"
	var code := -1
	var pressed := false
	if event is InputEventJoypadButton:
		code = event.button_index
		pressed = event.pressed
	elif event is InputEventJoypadMotion and event.axis in [JOY_AXIS_TRIGGER_LEFT,JOY_AXIS_TRIGGER_RIGHT]:
		kind = "trigger"
		code = event.axis
		var trigger_id := "%d:%d" % [event.device,code]
		pressed = _ui_triggers.get(trigger_id,false)
		if event.axis_value >= 0.55: pressed = true
		elif event.axis_value <= 0.45: pressed = false
		_ui_triggers[trigger_id] = pressed
	else: return false
	var identity := "%d:%s:%d" % [event.device,kind,code]
	if not pressed:
		var consumed: bool = _ui_controller_down.get(identity,{}).get("consumed",false)
		_ui_controller_down.erase(identity)
		return consumed
	if _ui_controller_down.has(identity): return _ui_controller_down[identity].consumed
	_ui_controller_down[identity] = {"consumed":false}
	if windows.top().is_empty() and core.gates.gameplay_input(): return false
	if kind == "button" and code == JOY_BUTTON_START: return false # Independent recovery.
	var action: String = host.controller.controls.resolve_ui(kind,code)
	if action.is_empty() and not (kind == "button" and code in [JOY_BUTTON_A,JOY_BUTTON_B]): return false
	_ui_controller_down[identity].consumed = true
	if action == "ui_back": options()
	elif action == "ui_confirm":
		var focused := host.get_viewport().gui_get_focus_owner()
		if focused is Button and not focused.disabled: focused.pressed.emit()
	return true

func _init(shell: Control, material_provider: Callable = Callable()) -> void:
	core = Lifecycle.new(material_provider)
	windows = Windows.new(core)
	action_input = Actions.new(core,windows)
	host = shell
	view_camera = Camera3D.new()
	view_camera.name = "ResolvedLookCamera"
	host.add_child(view_camera)
	view_camera.current = true
	view = preload("res://scripts/input/view_cursor.gd").new(action_input,host.get_viewport(),view_camera)
	Input.joy_connection_changed.connect(controller_connection_changed)
	action_input.controller_changed.connect(schedule_render)
	action_input.cancelled.connect(func(report: Dictionary): gameplay_cancelled.emit(report))
	action_input.failure.connect(func(report: Dictionary):
		message = report.reason
		host.controller.logger.message("WARNING", report.reason)
		schedule_render())
	core.formulas = host.controller.providers.formulas
	core.actors.definitions = host.controller.providers.definitions
	core.gates.changed.connect(schedule_render)
	core.state_changed.connect(func(_old: Dictionary, _new: Dictionary, _reason: String): schedule_render())
	core.terminal.connect(func(result: Dictionary):
		message = str(result.reason) if result.kind == "Failed" else ""
		schedule_render()
		if not quit_phase.is_empty():
			host.call_deferred("advance_shutdown")
		if setup_pending:
			setup_pending = false
			if result.kind == "Succeeded" and core.snapshot().session.is_empty() and not core.cleanup_blocked():
				host.controller.open_setup()
				schedule_render())
	windows.changed.connect(schedule_render)
	windows.changed.connect(func():
		var active := windows.layers().map(func(layer: Dictionary): return layer.id)
		for id: String in _prompt_owners.keys():
			if not active.has(id):
				_prompt_owners.erase(id))
	core.diagnostic.connect(func(reason: String): host.controller.logger.message("WARNING", reason))
	core.retiring.connect(func(_scope: String): _prompt_owners.clear())

func show_prompt(data: Dictionary, owner: Callable) -> String:
	var opening := data.duplicate(true)
	opening.required_choice = true
	var opened := windows.open("prompt", core.snapshot().session, opening)
	if opened.kind != "applied":
		return ""
	_prompt_owners[opened.id] = owner
	return opened.id

func schedule_render() -> void:
	if _synchronizing_startup:
		return # The startup caller is already committing this rendered view.
	if not _render_pending:
		_render_pending = true
		host.call_deferred("render")

func synchronize_startup() -> void:
	if host.controller.providers.get("layouts") != null and dungeon_assembly == null:
		dungeon_assembly = preload("res://scripts/loc/location_assembly.gd").new()
		dungeon_assembly.layouts = host.controller.providers.layouts
		dungeon_assembly.registry = host.controller.providers.definitions
		dungeon_assembly.geography = host.controller.providers.geography
		dungeon_assembly.variants = host.controller.providers.variants
		dungeon_assembly.core = core
		host.add_child(dungeon_assembly)
		core.retiring.connect(dungeon_assembly.retire_scope)
		core.terminal.connect(dungeon_assembly.operation_terminal)
		placement = preload("res://scripts/move/placement_authority.gd").new()
		placement.core = core
		placement.assembly = dungeon_assembly
		core.placement = placement
		host.add_child(placement)
		core.retiring.connect(placement.retire_scope)
		placement.pose_committed.connect(func(state: Dictionary):
			view.place_facing(state.session,{"version":1,"yaw":rad_to_deg(atan2(state.forward.x,-state.forward.z)),"pitch":0.0})
			view_camera.position = state.position
			view_camera.reset_physics_interpolation())
	if host.controller.providers.get("media") != null and music_playback == null:
		music_playback = preload("res://scripts/av/music_playback.gd").new()
		music_playback.media = host.controller.providers.media
		music_playback.core = core
		music_playback.preferences = host.controller.providers.media_preferences
		host.add_child(music_playback)
		core.retiring.connect(music_playback.retire_scope)
		video_playback = preload("res://scripts/av/video_playback.gd").new()
		video_playback.media = host.controller.providers.media
		video_playback.core = core
		video_playback.windows = windows
		video_playback.preferences = host.controller.providers.media_preferences
		video_playback.ambience = ambience_requests
		host.add_child(video_playback)
		core.retiring.connect(video_playback.retire_scope)
	if host.controller.providers.get("preferences") != null and core.preferences == null:
		core.preferences = host.controller.providers.preferences
		core.preferences.register_boundary("next_session", core)
	if _startup_route != host.controller.route:
		_synchronizing_startup = true
		if core.startup_route_changed(host.controller.route):
			_startup_route = host.controller.route
		_synchronizing_startup = false

func request(mode: String, selection: Dictionary = {}) -> Dictionary:
	if mode in ["new", "load"] and host.controller.route != "main_menu":
		return {"kind": "unavailable", "reason": "Complete required startup checks first."}
	_counter += 1
	return core.request({"id": "shell-%d" % _counter, "mode": mode, "selection": selection.duplicate(true), "origin": core.snapshot().session})

func return_to_setup() -> void:
	if core.snapshot().session.is_empty():
		host.controller.open_setup()
		schedule_render()
	else:
		setup_pending = true
		var checked := request("return")
		if checked.kind != "pending":
			setup_pending = false

func dispose() -> void:
	if is_instance_valid(placement): placement.free()
	if is_instance_valid(dungeon_assembly):
		dungeon_assembly.dispose()
		dungeon_assembly.free()
	Input.joy_connection_changed.disconnect(controller_connection_changed)
	host.controller.controls.detach(action_input)
	host.controller.controls.detach(view)
	view.dispose()
	view_camera.free()
	if binding_editor != null: binding_editor.dispose()
	host.controller.controls.dispose()
	action_input.dispose()
	if is_instance_valid(video_playback): video_playback.free()
	if is_instance_valid(music_playback): music_playback.free()
	_prompt_owners.clear()
	for connection: Dictionary in windows.changed.get_connections():
		windows.changed.disconnect(connection.callable)
	core.dispose()

func controller_connection_changed(device: int, connected: bool) -> void:
	action_input.connection_changed(device,connected)
	if not connected:
		for identity: String in _recovery_inputs.keys():
			if identity.begins_with("joy:%d:" % device): capture_recovery(false,false,identity)

func focus_changed(focused: bool) -> void:
	if not focused and _focus_hold == 0:
		if binding_editor != null and not binding_editor.capture.is_empty():
			host.controller.controls.status = "Capture cancelled on focus loss; slot unchanged."
			binding_editor.stop_capture()
		_focus_hold = core.gates.acquire("focus", "", ["simulation", "input"])
	elif focused and _focus_hold != 0:
		action_input.reconcile_focus_return()
		for identity: String in _recovery_inputs.keys():
			var down := Input.is_physical_key_pressed(KEY_ESCAPE)
			if identity.begins_with("joy:"):
				var parts := identity.split(":")
				down = Input.is_joy_button_pressed(int(parts[1]),int(parts[2]))
			if not down: capture_recovery(false,false,identity)
		core.gates.release(_focus_hold, "focus")
		_focus_hold = 0
	schedule_render()

func pause() -> void:
	if core.snapshot().ready and windows.top().is_empty():
		windows.open("pause", core.snapshot().session)

func capture_recovery(pressed: bool, echo := false, identity := "escape") -> void:
	if echo: return
	if not pressed:
		_recovery_inputs.erase(identity)
		if _recovery_inputs.is_empty(): windows.capture("options",false)
		return
	if _recovery_inputs.has(identity): return
	_recovery_inputs[identity] = true
	if _recovery_inputs.size() != 1: return
	windows.capture("options",true)
	if _recovery_hold == 0:
		_recovery_hold = core.gates.acquire("recovery-input","",["input"])

func finish_recovery_dispatch() -> void:
	if _recovery_hold != 0:
		var token := _recovery_hold
		_recovery_hold = 0
		core.gates.release(token,"recovery-input")

func deliver_input() -> Array[Dictionary]:
	var shortcuts: Array = []
	var context := windows.context_generation
	var scope := core.gates.session
	var results: Array[Dictionary] = action_input.deliver(func(edge: Dictionary) -> Dictionary:
		if edge.action in ["center_view","cursor_toggle"]:
			if edge.kind == "started":
				if edge.action == "center_view": view.center()
				else: view.toggle()
			return {"kind":"view_consumed"}
		if Windows.PRIORITY.has(edge.action):
			if edge.kind == "started": shortcuts.append(edge)
			return {"kind":"shortcut_candidate"}
		if edge.action == "hud_toggle" and edge.kind == "started":
			core.gates.hud_preference = not core.gates.hud_preference
			schedule_render()
			return {"kind":"applied"}
		edge.make_read_only()
		gameplay_edge.emit(edge)
		return {"kind":"intent_delivered"})
	if shortcuts.is_empty(): return results
	if context == windows.context_generation and scope == core.gates.session and action_input.context_current(shortcuts[0]):
		var selected := windows.dispatch_actions(shortcuts.map(func(edge: Dictionary): return edge.action))
		if selected.kind == "dispatch":
			# Real gameplay providers are intentionally not invented in this increment.
			message = "%s support is unavailable." % str(selected.action).capitalize()
			schedule_render()
		elif not windows.last_feedback.is_empty():
			message = windows.last_feedback
			schedule_render()
	return results

func options() -> void:
	var top := windows.top()
	if top.get("window") == "controls":
		close_controls()
		return
	if not top.is_empty():
		if top.window == "prompt":
			var response := "cancel" if top.data.get("responses", []).has("cancel") else "ok" if top.data.get("kind") == "information" else ""
			if not response.is_empty():
				windows.respond(top.id, response, func(choice: String, data: Dictionary) -> Dictionary:
					return _prompt_owners[top.id].call({"prompt": top.id, "response": choice, "text": data.get("draft", "")}))
		else:
			if windows.close(top.id).kind == "blocked" and top.window == "settings":
				windows.open("discard_settings", core.snapshot().session, {"required_choice": true})
	else:
		pause()

func render() -> void:
	var backdrop := host.get_node_or_null("StartupBackdrop")
	if backdrop != null: backdrop.visible = core.gates.session.is_empty() or not windows.top().is_empty()
	_render_pending = false
	host.clear()
	host.label("Daggerfall GD", 30)
	host.logging_status = Label.new()
	host.logging_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	host.panel.add_child(host.logging_status)
	host.update_logging_warning()
	var state := core.snapshot()
	if host.controller.settings != null and host.controller.settings.accepted != null:
		host.controller.controls.attach(action_input)
		host.controller.controls.attach(view)
		if binding_editor == null:
			binding_editor = preload("res://scripts/input/binding_editor.gd").new(host.controller.controls,action_input,self)
	if not message.is_empty():
		host.label(message)
	if action_input.disconnect_pending():
		host.label("Selected controller disconnected. Reconnection requires explicit Continue.")
		if action_input.controllers().has(action_input.selected_controller):
			host.button("Continue with Controller", func(): action_input.continue_controller())
		host.button("Continue with Keyboard / Mouse", action_input.continue_keyboard)
	elif action_input.controllers().size() > 0:
		for device: int in action_input.controllers():
			if device != action_input.selected_controller:
				host.button("Select Controller %d · %s" % [device,Input.get_joy_name(device)], func(): action_input.select_controller(device))
	if not quit_phase.is_empty():
		render_quit()
		return
	if windows.top().get("window") == "controls":
		binding_editor.render(host)
		restore_focus()
		return
	if core.cleanup_blocked():
		host.label("Cleanup incomplete. New sessions remain blocked.")
		host.button("Retry Cleanup", func(): core.retry_cleanup(); schedule_render())
		host.essential_button("quit", request_quit)
		return
	if core.busy():
		var operation_ticket := core.ticket()
		host.label("Session operation: " + state.phase)
		if state.phase == "confirmation":
			host.label("Discard unsaved progress? No automatic save will be made.")
			host.button("Keep Playing", func(): core.confirm(operation_ticket, false))
			host.button("Discard and Continue", func(): core.confirm(operation_ticket, true))
		elif state.phase == "preflight":
			host.essential_button("cancel", func(): core.cancel(operation_ticket))
		else:
			host.label("Replacement has started. Wait for completion or recovery.")
		host.essential_button("quit", request_quit)
		return
	if state.application == "recovery":
		host.label("Session unavailable. Safe recovery required.")
		host.essential_button("retry", func(): request(str(core.last_intent.get("mode", "new")), core.last_intent.get("selection", {})))
		host.button("Return to Main Menu", func(): core.recover_menu())
		host.essential_button("return_setup", return_to_setup)
	elif state.session.is_empty():
		host.label("Main menu ready.")
		host.button("New Game", func(): request("new"))
		host.label("Character entry and saved games are unavailable until their support is enabled.", 15)
		host.button("Settings / Setup", func(): host.controller.open_setup(); host.render())
		host.button("Controls",open_controls)
	else:
		host.label("Active session", 18)
		host.label("HUD" if core.gates.hud_visible() else "")
		var top := windows.top()
		if top.is_empty():
			host.label("Session ready.")
			host.button("Pause", pause)
		elif top.window == "pause":
			host.label("Paused", 24)
			host.button("Resume", func(): windows.close(top.id))
			unavailable("Save", "Save support is unavailable.")
			unavailable("Load", "Load support is unavailable.")
			host.label("Sound and music controls are unavailable in this build.", 15)
			host.button("Settings", func(): windows.open("settings", state.session))
			host.button("Return to Title", func(): request("return"))
			host.essential_button("return_setup", return_to_setup)
		elif top.window == "settings":
			render_settings(top)
		elif top.window == "discard_settings":
			host.label("Unapplied preference edit")
			host.button("Keep Editing", func(): windows.close(top.id, true))
			host.button("Apply", func():
				windows.close(top.id, true)
				var parent := windows.top()
				var checked: Dictionary = host.controller.settings.apply({"startup/show_setup": parent.data.get("draft", false)})
				message = "Accepted; pending next launch." if checked.ok else "Accepted but not saved. Retry Save."
				windows.update_data(parent.id, {"required_choice": false})
				schedule_render())
			host.button("Discard", func():
				windows.close(top.id, true)
				windows.close(windows.top().id, true))
		elif top.window == "message":
			host.label(str(top.data.get("text", "")))
			host.button("OK", func(): windows.close(top.id))
		elif top.window == "prompt":
			var prompt := preload("res://scripts/session/session_prompt.gd").new()
			host.panel.add_child(prompt)
			prompt.bind(windows, top, _prompt_owners[top.id],host.controller.providers.get("presentation"))
	host.essential_button("quit", request_quit)
	if host.controller.providers.get("preferences") != null:
		host.button("Mod Preferences", host.open_preferences)
		host.button("Translation Import / Export", host.open_authoring)
	if host.controller.providers.get("presentation") != null:
		host.show_language_settings()
	restore_focus()
	view._sync()

func restore_focus() -> void:
	if windows.top().is_empty() and core.gates.gameplay_input():
		# Returning to gameplay must not leave Space/Enter or controller Confirm
		# armed on the placeholder shell's Pause button. Menus retain UI focus.
		host.get_viewport().gui_release_focus()
		return
	# Stock safe initial focus; restored identity is independent of the old Control.
	if windows.top().get("window") == "prompt":
		return # Prompt owns its safe choice, unarmed choice or active text field.
	var focus_id := str(windows.top().get("focus", ""))
	var layer_id := str(windows.top().get("id", ""))
	var fallback: Button
	for child in host.panel.get_children():
		if child is Button:
			if fallback == null:
				fallback = child
			if child.text == focus_id:
				fallback = child
			if not child.has_meta("focus_bound"):
				child.set_meta("focus_bound", true)
				child.focus_entered.connect(func(): windows.remember_focus(layer_id, child.text))
	if fallback != null:
		fallback.grab_focus()

func unavailable(text: String, reason: String) -> void:
	var button := Button.new()
	button.text = text + " · unavailable"
	button.disabled = true
	button.tooltip_text = reason
	host.panel.add_child(button)

func render_settings(top: Dictionary) -> void:
	host.label("Settings · startup", 24)
	host.button("Controls",open_controls)
	var check := CheckBox.new()
	check.text = "Show setup at startup (next launch)"
	check.button_pressed = top.data.get("draft", host.controller.settings.value(host.controller.settings.accepted, "startup/show_setup"))
	host.panel.add_child(check)
	check.toggled.connect(func(value: bool):
		# Window holds a private draft; no setting is applied by navigation.
		windows.update_data(top.id, {"draft": value, "required_choice": true}))
	host.button("Apply", func():
		var checked: Dictionary = host.controller.settings.apply({"startup/show_setup": check.button_pressed})
		message = "Accepted; pending next launch." if checked.ok else "Accepted but not saved. Retry Save."
		windows.update_data(top.id, {"required_choice": false})
		schedule_render())
	host.button("Retry Save", func():
		message = "Saved." if host.controller.settings.save_accepted().ok else "Accepted but not saved."
		schedule_render())
	var banks: RefCounted = host.controller.providers.get("media_preferences")
	if banks != null:
		host.label("MIDI instrument bank (applies to the next playback)")
		var selector := OptionButton.new()
		var choices: Array = banks.choices()
		var current := str(host.controller.settings.effective.get(banks.SETTING,""))
		for index in choices.size():
			selector.add_item(choices[index].label)
			var reference := "" if choices[index].provider.is_empty() else JSON.stringify({"provider":choices[index].provider,"key":choices[index].key})
			if reference==current: selector.select(index)
		host.panel.add_child(selector)
		host.button("Apply MIDI Bank",func():
			var choice: Dictionary = choices[selector.selected]
			var checked: Dictionary = banks.select_bank(choice.provider,choice.key)
			message = "Bank selected for the next MIDI request." if checked.ok else checked.get("reason","Accepted bank preference is unsaved; Retry Save.")
			schedule_render())
		host.label("Cinematic skip input (startup and death always accept any fresh press)")
		var skip_selector := OptionButton.new()
		var skip_values := ["authored","any","skip","back"]
		for value: String in skip_values:
			skip_selector.add_item(value.capitalize())
			if value==host.controller.settings.effective.get(banks.SKIP_SETTING,"authored"): skip_selector.select(skip_selector.item_count-1)
		host.panel.add_child(skip_selector)
		host.button("Apply Cinematic Skip",func():
			var checked: Dictionary = banks.select_skip(skip_values[skip_selector.selected])
			message = banks.skip_message(checked)
			schedule_render())
	host.button("Cancel / Back", func():
		if windows.close(top.id).kind == "blocked":
			windows.open("discard_settings", core.snapshot().session, {"required_choice": true}))

func request_quit() -> void:
	if not quit_phase.is_empty():
		return
	_quit_hold = core.gates.acquire("shutdown", "", ["simulation", "input", "admission"])
	quit_phase = "waiting"
	advance_shutdown()

func cancel_quit() -> void:
	if quit_phase not in ["waiting", "confirmation"]:
		return
	quit_phase = ""
	quit_consent_scope = ""
	core.gates.release(_quit_hold, "shutdown")
	schedule_render()

func advance_shutdown() -> void:
	if quit_phase.is_empty():
		return
	if core.busy():
		quit_phase = "waiting"
	elif core.cleanup_blocked():
		quit_phase = "cleanup_failed"
	elif not core.snapshot().session.is_empty():
		if core.snapshot().status == "alive" and quit_consent_scope != core.snapshot().session:
			quit_phase = "confirmation"
		else:
			quit_phase = "teardown"
			# Session coordinator performs the same current-scope consent validation.
			request("shutdown")
			if core.snapshot().phase == "confirmation":
				core.confirm(core.ticket(), true)
	else:
		quit_phase = "preferences"
		var saved: bool = host.controller.settings == null or host.controller.settings.save_accepted().ok
		if saved and host.controller.providers.get("preferences") != null:
			saved = host.controller.providers.preferences.save_all()
		if saved: finish_quit()
	schedule_render()

func finish_quit() -> void:
	if is_instance_valid(music_playback):
		if not _media_shutdown_started:
			_media_shutdown_started = true
			quit_phase = "media_cleanup"
			host.call_deferred("settle_media_shutdown")
	else:
		quit_phase = "ready"
		host.get_tree().quit()

func settle_media_shutdown() -> void:
	var video_checked := {"ok":true}
	if is_instance_valid(video_playback): video_checked = await video_playback.shutdown()
	var checked: Dictionary = await music_playback.shutdown()
	if checked.ok and video_checked.ok:
		quit_phase = "ready"
		host.get_tree().quit()
	else:
		_media_shutdown_started = false
		quit_phase = "media_cleanup_failed"
		message = checked.reason if not checked.ok else video_checked.reason
		schedule_render()

func render_quit() -> void:
	host.label("Quit · " + quit_phase, 24)
	match quit_phase:
		"media_cleanup":
			host.label("Releasing media playback.")
		"media_cleanup_failed":
			host.label(message)
			host.button("Retry Media Cleanup",advance_shutdown)
		"waiting":
			host.label("Finishing current operation. No write or replacement will be forcibly interrupted.")
			host.button("Cancel Quit", cancel_quit)
			if core.snapshot().phase == "preflight":
				host.button("Cancel preflight", func(): core.cancel(core.ticket()); advance_shutdown())
		"confirmation":
			host.label("Discard unsaved progress and quit? No automatic save will be made.")
			host.button("Keep Playing", cancel_quit)
			host.button("Discard and Quit", func(): quit_consent_scope = core.snapshot().session; advance_shutdown())
		"cleanup_failed":
			host.label("Cleanup failed. Quit does not mean cleanup succeeded.")
			host.button("Retry Cleanup", func(): core.retry_cleanup(); advance_shutdown())
			host.button("Quit after cleanup failure", finish_quit)
		"preferences":
			host.label("Preferences could not be saved. Quitting without saving may lose accepted changes.")
			host.essential_button("retry", advance_shutdown)
			host.button("Quit Without Saving Preferences", finish_quit)
