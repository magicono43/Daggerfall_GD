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
var locale_editor: OptionButton
var locale_status: Label
var locale_notice: Label
var preference_view: Control
var authoring_view: Control

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
	# This resource is independent of startup, classic data and DATA publication.
	var recovery := preload("res://scripts/data/locale_fonts.gd").load_font({"bundled":"recovery-sans","sha256":preload("res://scripts/data/locale_fonts.gd").HASHES["recovery-sans"]})
	var recovery_theme := Theme.new()
	recovery_theme.default_font = recovery
	recovery_theme.default_font_size = 18
	theme = recovery_theme
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
	if fixture.is_empty() or fixture.get("mode") in ["replacements","replacements_reload"]:
		var registered: Dictionary = controller.providers.enable_media_replacements()
		if not registered.ok:
			label("Media adapter registration failed: " + registered.reason)
			return
	if fixture.is_empty() or fixture.get("mode") in ["translation-preferences", "translation-preferences_reload"]:
		var registered: Dictionary = controller.providers.enable_mod_preferences()
		if not registered.ok:
			label(registered.reason)
			return
	if fixture.is_empty() or fixture.get("mode") in ["text", "structured-text", "locale-fonts", "locale-fonts_reload", "translation-preferences", "translation-preferences_reload"]:
		var registered: Dictionary = controller.providers.register_bundled_text()
		if not registered.ok:
			label("Bundled text registration failed: " + registered.reason)
			essential_button("quit", func(): session_shell.request_quit())
			return
	if fixture.is_empty() or fixture.get("mode") in ["locale-fonts", "locale-fonts_reload", "translation-preferences", "translation-preferences_reload"]:
		var registered: Dictionary = controller.providers.enable_locale_fonts()
		if not registered.ok:
			label("Bundled font registration failed: " + registered.reason)
			essential_button("quit", func(): session_shell.request_quit())
			return
		controller.providers.presentation.changed.connect(refresh_language_controls)
	if fixture.is_empty() or fixture.get("mode") in ["structured-text", "locale-fonts", "locale-fonts_reload", "translation-preferences", "translation-preferences_reload"]:
		if not controller.providers.enable_structured_text():
			label("Required structured text reader registration failed.")
			essential_button("quit", func(): session_shell.request_quit())
			return
	if fixture.get("mode") in ["publication", "publication_reload"]:
		preload("res://tests/publication_fixture.gd").configure(self, fixture)
	if fixture.get("mode") in ["replacements","replacements_reload"]:
		preload("res://tests/replacement_fixture.gd").configure(self)
	if fixture.get("mode") in ["formula","formula-fault"]:
		preload("res://tests/formula_fixture.gd").configure(self,fixture)
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
		essential_button("quit", func(): session_shell.request_quit())
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
	item.autowrap_trim_flags = 0
	if controller.providers.get("presentation") != null:
		var role := "title" if size >= 24 else "small-ui" if size <= 15 else "body"
		item.set_meta("font_role",role)
		item.add_theme_font_override("font",controller.providers.presentation.font(role))
	panel.add_child(item)

func button(text: String, action: Callable, container: Node = null) -> void:
	var item := Button.new()
	item.text = text
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.clip_text = false
	item.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	if container is HBoxContainer:
		# Wrapped controls have no text-derived minimum width. Share the row's
		# available width instead of collapsing MOD/profile actions to padding.
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.custom_minimum_size.y = 40
	var generation := render_generation
	item.pressed.connect(func():
		if generation == render_generation:
			action.call())
	(panel if container == null else container).add_child(item)

func essential_button(key: String, action: Callable, container: Node = null) -> void:
	if controller.providers.get("presentation") != null:
		var readable: Dictionary = controller.providers.presentation.essential(key)
		button(readable.text,action,container)
		var parent: Node = panel if container == null else container
		parent.get_child(parent.get_child_count() - 1).add_theme_font_override("font",readable.font)
		parent.get_child(parent.get_child_count() - 1).set_meta("essential_key",key)
		return
	var catalogs = preload("res://scripts/data/text_catalog.gd")
	var resolved: Dictionary = catalogs.lookup(controller.providers.get("definitions"), "recovery", key)
	# Essential catalog keys have no context references. Draw their validated
	# literal runs, so escaped braces remain literal rather than exposing syntax.
	button(catalogs.essential_literal(resolved,key), action, container)

func retry(fallback := false, reset := false) -> void:
	controller.start(inputs, fallback, reset)
	render()

func render() -> void:
	if is_instance_valid(preference_view) or is_instance_valid(authoring_view):
		return # Modal editors retain their controls, draft, confirmation and focus.
	if controller.providers.get("presentation") != null:
		# Initial font activation occurs after the checked menu transaction returns.
		theme.default_font = controller.providers.presentation.font()
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
			essential_button("retry", retry)
			if result.get("choices", []).has("Use standard storage"):
				essential_button("standard_storage", func(): retry(true))
		"settings_recovery":
			if result.get("kind") == "incompatible":
				essential_button("reset_settings", func(): retry(false, true))
			elif result.get("kind") != "installation_error":
				essential_button("retry", retry)
		"mandatory_setup", "optional_setup", "package_recovery":
			label("Select ARENA2 or its immediate parent folder. Classic data remains read-only.")
			essential_button("choose_folder", choose_folder)
			essential_button("retry", func(): controller.check_content(); render())
			if route == "optional_setup":
				essential_button("continue", func(): controller.continue_to_menu(); render())
				essential_button("cancel", func(): controller.cancel_setup(); render())
			if controller.settings != null and controller.settings.accepted != null:
				var check := CheckBox.new()
				check.text = "Show setup at startup (takes effect next launch)"
				check.button_pressed = controller.settings.value(controller.settings.accepted, "startup/show_setup")
				panel.add_child(check)
				button("Apply startup preference", func():
					var saved := controller.settings.apply({"startup/show_setup": check.button_pressed})
					controller.result = {"detail": "Saved; pending next launch." if saved.ok else "Accepted, not saved. Retry saving preferences."}
					render())
				essential_button("retry_save", func():
					var saved := controller.settings.save_accepted()
					controller.result = {"detail": "Saved." if saved.ok else "Accepted, not saved."}
					render())
		"main_menu":
			label("Main menu ready.")
			button("Settings / Setup", func(): controller.open_setup(); render())
		"menu_recovery":
			essential_button("retry", func(): controller.continue_to_menu(); render())
			essential_button("return_setup", func(): controller.open_setup(); render())
	if controller.mods != null and not controller.menu_entered:
		preload("res://scripts/mod/mod_setup_view.gd").new(self, controller.mods).show()
	essential_button("quit", func(): session_shell.request_quit())
	if controller.providers.get("presentation") != null and controller.menu_entered:
		show_language_settings()
	if controller.menu_entered and controller.providers.get("preferences") != null:
		button("Mod Preferences", open_preferences)
		button("Translation Import / Export", open_authoring)

func open_preferences() -> void:
	if is_instance_valid(preference_view) or is_instance_valid(authoring_view):
		return
	preference_view = preload("res://scripts/mod/preferences_view.gd").new()
	add_child(preference_view)
	preference_view.bind(self, controller.providers.preferences, controller.providers.presentation)

func open_authoring() -> void:
	if is_instance_valid(preference_view) or is_instance_valid(authoring_view):
		return
	authoring_view = preload("res://scripts/data/translation_view.gd").new()
	add_child(authoring_view)
	authoring_view.bind(self)

func show_language_settings() -> void:
	var owner: RefCounted = controller.providers.presentation
	label("Language (live presentation). Requested: %s; effective: %s" % [controller.settings.value(controller.settings.accepted,"presentation/locale"),owner.locale])
	locale_status = panel.get_child(panel.get_child_count() - 1)
	label(owner.notice)
	locale_notice = panel.get_child(panel.get_child_count() - 1)
	locale_notice.visible = not owner.notice.is_empty()
	locale_editor = OptionButton.new()
	for id: String in owner.available():
		locale_editor.add_item(id)
		if id == owner.locale:
			locale_editor.select(locale_editor.item_count - 1)
	panel.add_child(locale_editor)
	button("Apply language", apply_language)
	button("Cancel language edit", cancel_language)
	button("Retry saving language", func():
		var saved := controller.settings.save_accepted()
		label("Saved." if saved.ok else "Applied, not saved. Retry saving language."))

func apply_language() -> Dictionary:
	var selected := locale_editor.get_item_text(locale_editor.selected)
	var saved := controller.settings.apply({"presentation/locale":selected},controller.providers.presentation.apply)
	update_language_status()
	label("Language rejected; previous presentation retained." if not saved.rejected.is_empty() else "Applied and saved." if saved.ok else "Applied, not saved. Retry saving language.")
	return saved

func update_language_status() -> void:
	if is_instance_valid(locale_status):
		locale_status.text = "Language (live presentation). Requested: %s; effective: %s" % [controller.settings.value(controller.settings.accepted,"presentation/locale"),controller.providers.presentation.locale]
	if is_instance_valid(locale_notice):
		locale_notice.text = controller.providers.presentation.notice
		locale_notice.visible = not locale_notice.text.is_empty()

func cancel_language() -> void:
	for index in locale_editor.item_count:
		if locale_editor.get_item_text(index) == controller.providers.presentation.locale:
			locale_editor.select(index)

func refresh_language_controls() -> void:
	# Runs synchronously with prompt commit, before the next layout/draw pass.
	theme.default_font = controller.providers.presentation.font()
	refresh_language_children(panel)

func refresh_language_children(parent: Node) -> void:
	for child in parent.get_children():
		if child.has_meta("font_role"):
			child.add_theme_font_override("font",controller.providers.presentation.font(child.get_meta("font_role")))
		if child.has_meta("essential_key"):
			var readable: Dictionary = controller.providers.presentation.essential(child.get_meta("essential_key"))
			child.text = readable.text
			child.add_theme_font_override("font",readable.font)
		refresh_language_children(child)

func advance_shutdown() -> void:
	session_shell.advance_shutdown()

func restore_session_focus(generation: int) -> void:
	if generation == render_generation:
		session_shell.restore_focus()

func _notification(what: int) -> void:
	if session_shell == null:
		return
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		close_editor()
		session_shell.request_quit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		session_shell.focus_changed(false)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		session_shell.focus_changed(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		if is_instance_valid(preference_view) or is_instance_valid(authoring_view):
			if event.pressed and not event.echo:
				close_editor()
			get_viewport().set_input_as_handled()
			return
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
			if not close_editor():
				session_shell.options()

func close_editor() -> bool:
	if is_instance_valid(preference_view):
		preference_view.close()
		return true
	if is_instance_valid(authoring_view):
		authoring_view.close()
		return true
	return false

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
	elif fixture.get("mode") == "media":
		script_path = "res://tests/media_cases.gd"
	elif fixture.get("mode") == "replacements":
		script_path = "res://tests/replacement_cases.gd"
	elif fixture.get("mode") == "replacements_reload":
		script_path = "res://tests/replacement_reload_cases.gd"
	elif fixture.get("mode") == "mods":
		script_path = "res://tests/mod_cases.gd"
	elif fixture.get("mode") == "mods_reload":
		script_path = "res://tests/mod_reload_cases.gd"
	elif fixture.get("mode") == "planning":
		script_path = "res://tests/dependency_cases.gd"
	elif fixture.get("mode") == "planning_reload":
		script_path = "res://tests/dependency_reload_cases.gd"
	elif fixture.get("mode") == "randomness":
		script_path = "res://tests/randomness_cases.gd"
	elif fixture.get("mode") == "formula":
		script_path = "res://tests/formula_cases.gd"
	elif fixture.get("mode") == "text":
		script_path = "res://tests/text_cases.gd"
	elif fixture.get("mode") == "structured-text":
		script_path = "res://tests/structured_text_cases.gd"
	elif fixture.get("mode") == "translation-preferences_reload":
		script_path = "res://tests/translation_preference_reload_cases.gd"
	elif fixture.get("mode") == "translation-preferences":
		script_path = "res://tests/translation_preference_cases.gd"
	elif fixture.get("mode") == "locale-fonts":
		script_path = "res://tests/locale_font_cases.gd"
	elif fixture.get("mode") == "locale-fonts_reload":
		script_path = "res://tests/locale_font_reload_cases.gd"
	elif fixture.get("mode") == "formula-fault":
		script_path = "res://tests/formula_fault_cases.gd"
	elif fixture.get("mode") == "randomness-session":
		script_path = "res://tests/random_session_cases.gd"
	elif fixture.get("mode") == "randomness-session_reload":
		script_path = "res://tests/random_session_reload_cases.gd"
	elif fixture.get("mode") == "publication":
		script_path = "res://tests/publication_cases.gd"
	elif fixture.get("mode") == "publication_reload":
		script_path = "res://tests/publication_reload_cases.gd"
	var suite = load(script_path).new()
	var checks: Dictionary = await suite.run(self, fixture)
	var target := str(fixture.sandbox).path_join("reload-result.json" if fixture.get("mode") in ["mods_reload", "planning_reload", "publication_reload", "randomness-session_reload", "locale-fonts_reload", "translation-preferences_reload", "replacements_reload"] else "result.json")
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
