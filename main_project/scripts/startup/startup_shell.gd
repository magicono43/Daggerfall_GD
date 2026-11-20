extends Control
## Asset-independent normal startup entry. Fixture contexts are explicitly isolated.
const Controller = preload("res://scripts/startup/startup_controller.gd")
var controller := Controller.new()
var inputs: Dictionary
var panel: VBoxContainer
var picker: FileDialog
var fixture: Dictionary = {}
var registered_logger: StartupLaunchLogger
var logging_status: Label
var session_shell: RefCounted
var render_generation := 0

func _ready() -> void:
	get_tree().auto_accept_quit = false
	session_shell = preload("res://scripts/session/session_shell.gd").new(self)
	var background := ColorRect.new()
	background.color = Color("17212a")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 36)
	add_child(margin)
	panel = VBoxContainer.new()
	panel.add_theme_constant_override("separation", 14)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(panel)
	inputs = launch_inputs()
	if inputs.is_empty():
		return
	controller.start(inputs)
	registered_logger = controller.logger
	OS.add_logger(registered_logger)
	render()
	if not fixture.is_empty():
		call_deferred("run_fixture")

func launch_inputs() -> Dictionary:
	var development := OS.has_feature("editor")
	var normal := OS.get_cmdline_user_args().has("--use-player-storage")
	var standard := controller.storage.adapter.per_user_root(development and not normal)
	if not standard.ok:
		label("Storage adapter unavailable", 30)
		label(standard.detail)
		button("Quit", func(): session_shell.request_quit())
		return {}
	var executable := OS.get_executable_path().get_base_dir()
	# Editor executable directories are shared engine installations. Never use their
	# Portable.txt marker implicitly; project runs have a separate development base.
	if development and not normal:
		executable = ProjectSettings.globalize_path("res://").trim_suffix("/")
	var launch_context := {"executable_dir": executable, "per_user_dir": standard.path, "development": development and not normal}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--startup-fixture="):
			var file := arg.trim_prefix("--startup-fixture=")
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(file))
			if not parsed is Dictionary or not parsed.has("sandbox"):
				get_tree().quit(2)
				return {}
			fixture = parsed
			# Fixture roots must be children of the task's disposable workspace.
			var fixture_base := ProjectSettings.globalize_path("res://tests/.runs/") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir().path_join("tests/.runs")
			var allowed := fixture_base.replace("\\", "/").simplify_path().trim_suffix("/") + "/"
			var sandbox := str(fixture.sandbox).replace("\\", "/").simplify_path().trim_suffix("/") + "/"
			if not sandbox.to_lower().begins_with(allowed.to_lower()):
				get_tree().quit(2)
				return {}
			launch_context = {"executable_dir": sandbox.path_join("executable"), "per_user_dir": sandbox.path_join("user"), "development": true}
			if fixture.get("alias", "") == "dot":
				launch_context.per_user_dir += "/./"
			elif fixture.get("alias", "") == "case":
				launch_context.per_user_dir = str(launch_context.per_user_dir).to_upper()
			elif fixture.get("alias", "") == "junction":
				launch_context.per_user_dir = sandbox.path_join("user-junction")
			if fixture.get("portable", false):
				DirAccess.make_dir_recursive_absolute(launch_context.executable_dir)
				FileAccess.open(str(launch_context.executable_dir).path_join("Portable.txt"), FileAccess.WRITE).close()
			for fault: String in fixture.get("faults", []):
				controller.storage.adapter.faults[fault] = true
	return launch_context

func clear() -> void:
	render_generation += 1
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()

func label(text: String, size := 18) -> void:
	var item := Label.new()
	item.text = text
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", size)
	panel.add_child(item)

func button(text: String, action: Callable) -> void:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size.y = 40
	var generation := render_generation
	item.pressed.connect(func():
		if generation == render_generation:
			action.call())
	panel.add_child(item)

func retry(fallback := false, reset := false) -> void:
	controller.start(inputs, fallback, reset)
	render()

func render() -> void:
	session_shell._render_pending = false
	session_shell.synchronize_startup()
	if controller.route == "main_menu" or not session_shell.quit_phase.is_empty():
		session_shell.render()
		call_deferred("restore_session_focus", render_generation)
		return
	clear()
	label("Daggerfall GD · Startup", 30)
	var route := controller.route
	label(route.replace("_", " ").capitalize(), 24)
	logging_status = Label.new()
	logging_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(logging_status)
	update_logging_warning()
	if not controller.storage.context.is_empty():
		label("Storage: %s\n%s" % [controller.storage.context.mode, controller.storage.context.root], 15)
	if not controller.active_source.is_empty():
		label("Active classic source: " + controller.active_source, 15)
	for text: String in controller.warnings:
		label(text)
	var result := controller.result
	label(str(result.get("reason", result.get("detail", ""))))
	if result.has("path"):
		label("%s: %s" % [result.get("operation", "Access"), result.path])
	match route:
		"storage_recovery":
			label("Each storage location has its own data. Switching does not move saves.")
			button("Retry", retry)
			if result.get("choices", []).has("Use standard storage"):
				button("Use standard storage for this launch", func(): retry(true))
		"settings_recovery":
			if result.get("kind") == "incompatible":
				button("Preserve original and reset to defaults", func(): retry(false, true))
			elif result.get("kind") != "installation_error":
				button("Retry", retry)
		"mandatory_setup", "optional_setup", "package_recovery":
			label("Select ARENA2 or its immediate parent folder. Classic data remains read-only.")
			button("Choose Folder", choose_folder)
			button("Retry", func(): controller.check_content(); render())
			if route == "optional_setup":
				button("Continue", func(): controller.continue_to_menu(); render())
				button("Cancel", func(): controller.cancel_setup(); render())
			if controller.settings != null and controller.settings.accepted != null:
				var check := CheckBox.new()
				check.text = "Show setup at startup (takes effect next launch)"
				check.button_pressed = controller.settings.value(controller.settings.accepted, "startup/show_setup")
				panel.add_child(check)
				button("Apply startup preference", func():
					var saved := controller.settings.apply({"startup/show_setup": check.button_pressed})
					controller.result = {"detail": "Saved; pending next launch." if saved.ok else "Accepted, not saved. Retry saving preferences."}
					render())
				button("Retry saving preferences", func():
					var saved := controller.settings.save_accepted()
					controller.result = {"detail": "Saved." if saved.ok else "Accepted, not saved."}
					render())
		"main_menu":
			label("Main menu ready.")
			button("Settings / Setup", func(): controller.open_setup(); render())
		"menu_recovery":
			button("Retry", func(): controller.continue_to_menu(); render())
			button("Return to Setup", func(): controller.open_setup(); render())
	button("Quit", func(): session_shell.request_quit())

func advance_shutdown() -> void:
	session_shell.advance_shutdown()

func restore_session_focus(generation: int) -> void:
	if generation == render_generation:
		session_shell.restore_focus()

func _notification(what: int) -> void:
	if session_shell == null:
		return
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		session_shell.request_quit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		session_shell.focus_changed(false)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		session_shell.focus_changed(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		session_shell.windows.capture("options", event.pressed, event.echo)
		get_viewport().set_input_as_handled()

func choose_folder() -> void:
	if picker != null:
		picker.queue_free()
	picker = FileDialog.new()
	picker.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	picker.access = FileDialog.ACCESS_FILESYSTEM
	picker.title = "Choose ARENA2 or its immediate parent"
	picker.dir_selected.connect(func(path: String): controller.select_folder(path); render())
	add_child(picker)
	picker.popup_centered_ratio(0.75)

func _process(_delta: float) -> void:
	update_logging_warning()
	if session_shell != null:
		var dispatched: Dictionary = session_shell.windows.dispatch()
		if dispatched.get("action") == "options" and dispatched.kind == "dispatch":
			session_shell.options()

func update_logging_warning() -> void:
	if is_instance_valid(logging_status):
		logging_status.text = controller.logger.warning
		logging_status.visible = not logging_status.text.is_empty()

func run_fixture() -> void:
	var script_path := "res://tests/startup_cases.gd"
	if fixture.get("mode") == "session":
		script_path = "res://tests/session_cases.gd"
	elif fixture.get("mode") == "qualification":
		script_path = "res://tests/verification_cases.gd"
	elif fixture.get("mode") == "classic":
		script_path = "res://tests/classic_cases.gd"
	var suite = load(script_path).new()
	var checks: Dictionary = await suite.run(self, fixture)
	var target := str(fixture.sandbox).path_join("result.json")
	var file := FileAccess.open(target, FileAccess.WRITE)
	file.store_string(JSON.stringify(checks, "\t"))
	file.close()
	get_tree().quit(0 if checks.ok else 1)

func _exit_tree() -> void:
	if session_shell != null:
		session_shell.dispose()
	if controller.providers.has_method("dispose"):
		controller.providers.dispose()
	if registered_logger != null:
		OS.remove_logger(registered_logger)
		registered_logger.stop("Process shutdown")
	controller.storage.adapter.release()
