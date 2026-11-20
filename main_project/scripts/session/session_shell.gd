extends RefCounted
## Stock title/pause/modal presentation in the existing application shell.
const Lifecycle = preload("res://scripts/session/session_lifecycle.gd")
const Windows = preload("res://scripts/session/window_stack.gd")
var core := Lifecycle.new()
var windows := Windows.new(core)
var host: Control
var _counter := 0
var _focus_hold := 0
var _quit_hold := 0
var quit_phase := ""
var quit_consent_scope := ""
var setup_pending := false
var message := ""
var _render_pending := false
var _prompt_owners: Dictionary = {}
var _startup_route := ""
var _synchronizing_startup := false

func _init(shell: Control) -> void:
	host = shell
	core.formulas = host.controller.providers.formulas
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
	_prompt_owners.clear()
	for connection: Dictionary in windows.changed.get_connections():
		windows.changed.disconnect(connection.callable)
	core.dispose()

func focus_changed(focused: bool) -> void:
	if not focused and _focus_hold == 0:
		_focus_hold = core.gates.acquire("focus", "", ["simulation", "input"])
	elif focused and _focus_hold != 0:
		core.gates.release(_focus_hold, "focus")
		_focus_hold = 0
	schedule_render()

func pause() -> void:
	if core.snapshot().ready and windows.top().is_empty():
		windows.open("pause", core.snapshot().session)

func options() -> void:
	var top := windows.top()
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
	_render_pending = false
	host.clear()
	host.label("Daggerfall GD", 30)
	host.logging_status = Label.new()
	host.logging_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	host.panel.add_child(host.logging_status)
	host.update_logging_warning()
	var state := core.snapshot()
	if not message.is_empty():
		host.label(message)
	if not quit_phase.is_empty():
		render_quit()
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
			prompt.bind(windows, top, _prompt_owners[top.id])
	host.essential_button("quit", request_quit)
	restore_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func restore_focus() -> void:
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
		if host.controller.settings == null or host.controller.settings.save_accepted().ok:
			quit_phase = "ready"
			host.get_tree().quit()
	schedule_render()

func render_quit() -> void:
	host.label("Quit · " + quit_phase, 24)
	match quit_phase:
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
			host.button("Quit after cleanup failure", func(): host.get_tree().quit())
		"preferences":
			host.label("Preferences could not be saved. Quitting without saving may lose accepted changes.")
			host.essential_button("retry", advance_shutdown)
			host.button("Quit Without Saving Preferences", func(): host.get_tree().quit())
