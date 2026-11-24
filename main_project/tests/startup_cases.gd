extends RefCounted
const Controller = preload("res://scripts/startup/startup_controller.gd")
const Settings = preload("res://scripts/startup/settings_owner.gd")
const Adapter = preload("res://scripts/startup/storage_adapter.gd")
const Storage = preload("res://scripts/startup/storage_owner.gd")
const LaunchLog = preload("res://scripts/startup/launch_logger.gd")
const Provider = preload("res://tests/controlled_startup_provider.gd")
var checks: Array[Dictionary] = []
var base: String
var shell: Control
var exercised_corrupt_config := false

func check(name: String, passed: bool, detail := "") -> void:
	checks.append({"scenario": name, "expected": "pass", "actual": "pass" if passed else "FAIL", "detail": detail})
	if not passed:
		push_error("IMP-001 check failed: " + name + " " + detail)

func write(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()

func launch(name: String, portable := false) -> Dictionary:
	var root := base.path_join(name)
	var exe := root.path_join("executable")
	DirAccess.make_dir_recursive_absolute(exe)
	if portable:
		write(exe.path_join("Portable.txt"), "")
	return {"executable_dir": exe, "per_user_dir": root.path_join("user"), "development": true}

func close_controller(controller: StartupController) -> void:
	controller.logger.stop("fixture complete")
	controller.storage.adapter.release()

func run(target: Control, fixture: Dictionary) -> Dictionary:
	shell = target
	base = str(fixture.sandbox).path_join("cases")
	if fixture.get("mode", "suite") == "lease_probe":
		check("cross-process expected route", shell.controller.route == fixture.expected_route)
		if fixture.expected_route == "storage_recovery":
			check("cross-process root-in-use classification", shell.controller.result.kind == "in_use" and shell.controller.result.choices == ["Retry", "Quit"])
		return report()
	if fixture.get("mode", "suite") == "interrupted_publication":
		var owner: StartupSettingsOwner = shell.controller.settings
		var initial := FileAccess.get_file_as_string(owner.path)
		owner.put(owner.accepted, "startup/show_setup", true)
		owner.save_accepted()
		var committed := FileAccess.get_file_as_string(owner.path)
		write(str(fixture.sandbox).path_join("expected-active.ini"), committed)
		write(str(fixture.sandbox).path_join("expected-original.ini"), initial)
		owner.put(owner.accepted, "startup/show_setup", false)
		shell.controller.storage.adapter.before_replace = func(operation: String):
			if operation == fixture.checkpoint:
				write(str(fixture.sandbox).path_join("ready.json"), JSON.stringify({"checkpoint": operation}))
				OS.delay_msec(50000) # External fixture kills this exact child here.
		owner.save_accepted()
		check("interruption controller must terminate child", false)
		return report()
	check("normal entry uses isolated root", shell.controller.storage.context.root.begins_with(str(fixture.sandbox)))
	check("fresh normal entry blocks missing real providers", shell.controller.route == "mandatory_setup")
	check("quiet first launch", shell.controller.settings.last_result.kind == "initialized" and shell.controller.warnings.is_empty())
	if fixture.get("mode", "suite") == "hold":
		write(str(fixture.sandbox).path_join("ready.json"), JSON.stringify(shell.controller.storage.context))
		await shell.get_tree().create_timer(50).timeout
	elif fixture.get("mode", "suite") == "route_only":
		check("expected route", shell.controller.route == fixture.get("expected_route", "mandatory_setup"))
	else:
		storage_cases()
		settings_cases()
		logging_cases()
		routing_cases()
		if DisplayServer.get_name() != "headless":
			await rendered_cases()
	return report()

func report() -> Dictionary:
	var passed := true
	for item: Dictionary in checks:
		passed = passed and item.actual == "pass"
	return {"ok": passed, "fixture": "IMP-001-startup-v1", "engine": Engine.get_version_info(),
		"display": DisplayServer.get_name(), "checks": checks, "count": checks.size(),
		"corrupt_config_profile":"startup-corrupt-config-v1" if exercised_corrupt_config else "",
		"corrupt_config_path":base.path_join("settings-owner/settings.ini") if exercised_corrupt_config else ""}

func storage_cases() -> void:
	var owner := Storage.new()
	var inputs := launch("standard")
	var result := owner.resolve(inputs)
	check("marker absent standard root", result.ok and result.context.mode == "standard" and result.context.root == inputs.per_user_dir)
	for category in ["saves", "settings", "mod_data", "logs", "cache"]:
		check("root handoff " + category, result.context[category] == result.context.root.path_join(category))
	write(str(inputs.executable_dir).path_join("Portable.txt"), "")
	check("launch selection frozen", owner.resolve(inputs).context.root == inputs.per_user_dir)
	var second := Adapter.new()
	check("same process second lease rejected", second.acquire(result.context.root).kind == "in_use")
	check("distinct roots concurrent", second.acquire(base.path_join("distinct")).ok)
	second.release()
	owner.adapter.release()
	check("lease reacquisition", second.acquire(result.context.root).ok)
	second.release()
	owner = Storage.new()
	result = owner.resolve(inputs)
	check("marker reevaluated next launch", result.ok and result.context.mode == "portable")
	owner.adapter.release()
	inputs = launch("portable-failure", true)
	var blocked := str(inputs.executable_dir).path_join("PortableAppdata")
	write(blocked, "required directory blocked by file")
	owner = Storage.new()
	result = owner.resolve(inputs)
	check("portable required failure choices", not result.ok and result.choices == ["Retry", "Use standard storage", "Quit"])
	check("portable retry no silent fallback", not owner.resolve(inputs).ok and owner.context.is_empty())
	result = owner.resolve(inputs, true)
	check("explicit launch-only standard fallback", result.ok and result.context.mode == "standard_fallback")
	check("fallback preserves portable files and marker", FileAccess.get_file_as_string(blocked) == "required directory blocked by file" and FileAccess.file_exists(str(inputs.executable_dir).path_join("Portable.txt")))
	owner.adapter.release()
	owner = Storage.new()
	check("fallback relaunch tries portable", not owner.resolve(inputs).ok and owner.selected_mode == "portable")
	inputs = launch("standard-failure")
	write(inputs.per_user_dir, "blocked")
	owner = Storage.new()
	result = owner.resolve(inputs)
	check("standard failure only retry quit", not result.ok and result.choices == ["Retry", "Quit"])
	inputs = launch("optional-failure")
	write(str(inputs.per_user_dir).path_join("logs"), "blocked optional logs")
	owner = Storage.new()
	result = owner.resolve(inputs)
	check("logging-only failure permits readiness", result.ok and not result.context.warnings.is_empty())
	owner.adapter.release()
	for operation in ["probe_write", "probe_read", "probe_remove"]:
		owner = Storage.new()
		owner.adapter.faults[operation] = true
		result = owner.resolve(launch(operation))
		check("required probe failure " + operation, not result.ok and result.operation == operation)

func settings_cases() -> void:
	exercised_corrupt_config = true
	var adapter := Adapter.new()
	var directory := base.path_join("settings-owner")
	DirAccess.make_dir_recursive_absolute(directory)
	check("settings fixture lease", adapter.acquire(directory).ok)
	var owner := Settings.new(adapter, directory)
	var result := owner.initialize()
	check("settings first run initialized", result.ok and result.kind == "initialized")
	var initial := FileAccess.get_file_as_string(owner.path)
	owner.accepted.set_value("unknown", "future", "opaque-choice")
	owner.put(owner.accepted, "startup/show_setup", true)
	check("ordinary changed revision saved", owner.save_accepted().ok)
	check("previous validated revision backed up", FileAccess.get_file_as_string(owner.path + ".backup") == initial)
	var saved := FileAccess.get_file_as_string(owner.path)
	check("identical save history unchanged", owner.save_accepted().ok and FileAccess.get_file_as_string(owner.path + ".backup") == initial)
	owner = Settings.new(adapter, directory)
	check("parse-only load history unchanged", owner.initialize().ok and FileAccess.get_file_as_string(owner.path + ".backup") == initial)
	check("unknown key retained", owner.accepted.get_value("unknown", "future") == "opaque-choice")
	write(owner.path, "[damaged\nnot valid ini")
	owner = Settings.new(adapter, directory)
	result = owner.initialize()
	check("damaged uses validated backup", result.ok and result.kind == "recovered" and "backup" in result.detail and FileAccess.get_file_as_string(owner.path) == initial)
	check("damaged recovery distinct and backup intact", FileAccess.get_file_as_string(owner.path + ".recovery") == "[damaged\nnot valid ini" and FileAccess.get_file_as_string(owner.path + ".backup") == initial)
	write(owner.path, "[again damaged")
	adapter.faults.recovery = true
	owner = Settings.new(adapter, directory)
	result = owner.initialize()
	check("failed preservation keeps old recovery and active", not result.ok and FileAccess.get_file_as_string(owner.path + ".recovery") == "[damaged\nnot valid ini" and FileAccess.get_file_as_string(owner.path) == "[again damaged")
	adapter.faults.clear()
	write(owner.path + ".backup", "[bad backup")
	result = owner.initialize()
	check("both damaged restore defaults and establish backup", result.ok and "defaults" in result.detail and FileAccess.get_file_as_string(owner.path + ".backup") == initial)
	for version in [0, 2]:
		write(owner.path, initial.replace("format_version=1", "format_version=" + str(version)))
		var unsupported := FileAccess.get_file_as_string(owner.path)
		owner = Settings.new(adapter, directory)
		result = owner.initialize()
		check("unsupported version unchanged " + str(version), not result.ok and result.kind == "incompatible" and FileAccess.get_file_as_string(owner.path) == unsupported)
		check("explicit reset preserves version " + str(version), owner.initialize(true).ok and FileAccess.get_file_as_string(owner.path + ".recovery") == unsupported)
	write(owner.path, saved.replace("show_setup=true", "show_setup=17"))
	owner = Settings.new(adapter, directory)
	result = owner.initialize()
	check("individual recovery preserves unrelated unknown", result.ok and result.kind == "recovered" and owner.value(owner.accepted, "startup/show_setup") == false and owner.accepted.get_value("unknown", "future") == "opaque-choice")
	write(owner.path, initial.replace("show_setup=false", ""))
	owner = Settings.new(adapter, directory)
	result = owner.initialize()
	check("missing owner setting added quietly", result.ok and result.kind == "loaded" and not owner.value(owner.accepted, "startup/show_setup"))
	write(owner.path, "[startup]\nshow_setup=true\n")
	owner = Settings.new(adapter, directory)
	result = owner.initialize()
	check("missing format metadata preserves structurally damaged input", result.ok and result.kind == "recovered" and FileAccess.get_file_as_string(owner.path + ".recovery") == "[startup]\nshow_setup=true\n")
	var before := FileAccess.get_file_as_string(owner.path)
	for fault in ["settings_stage", "backup", "settings_publish"]:
		owner = Settings.new(adapter, directory)
		owner.initialize()
		owner.put(owner.accepted, "startup/show_setup", true)
		adapter.faults[fault] = true
		result = owner.save_accepted()
		check("failed publication keeps active " + fault, not result.ok and result.unsaved and FileAccess.get_file_as_string(owner.path) == before)
		adapter.faults.clear()
	owner = Settings.new(adapter, directory)
	owner.defaults_path = directory.path_join("missing-defaults.ini")
	result = owner.initialize()
	check("invalid packaged defaults no mutation", not result.ok and result.kind == "installation_error" and FileAccess.get_file_as_string(owner.path) == before)
	owner = Settings.new(adapter, directory)
	owner.declare("fixture/unclassified", true, TYPE_BOOL, "unknown")
	check("unclassified setting contract blocks startup", owner.initialize().kind == "installation_error" and FileAccess.get_file_as_string(owner.path) == before)
	# Owner-declared single value and compatible group fixtures.
	owner = Settings.new(adapter, directory)
	owner.declare("fixture/amount", 5, TYPE_INT, "live", func(v): return v >= 1 and v <= 10)
	owner.declare("fixture/left", 1, TYPE_INT, "live")
	owner.declare("fixture/right", 2, TYPE_INT, "restart")
	owner.declare_group("pair", ["fixture/left", "fixture/right"], func(c): return c.get_value("fixture", "left") < c.get_value("fixture", "right"))
	check("new owner defaults quiet", owner.initialize().kind == "loaded")
	var candidate := owner.clone(owner.accepted)
	owner.put(candidate, "fixture/amount", 99)
	owner.put(candidate, "fixture/left", 8)
	owner.put(candidate, "fixture/right", 3)
	write(owner.path, candidate.encode_to_text())
	result = owner.initialize()
	check("out of range resets default without clamping", result.ok and owner.value(owner.accepted, "fixture/amount") == 5 and "fixture/amount" in result.detail)
	check("incompatible group resets compatible defaults", owner.value(owner.accepted, "fixture/left") == 1 and owner.value(owner.accepted, "fixture/right") == 2 and "group:pair" in result.detail)
	adapter.faults.settings_publish = true
	result = owner.apply({"fixture/amount": 6, "fixture/left": 2, "fixture/right": 4}, func(_values): return true)
	check("runtime applied unsaved distinct from pending", not result.ok and result.unsaved and owner.effective["fixture/amount"] == 6 and owner.effective["fixture/left"] == 1 and result.pending.has("fixture/left"))
	adapter.faults.clear()
	check("persistence retry does not activate pending", owner.save_accepted().ok and owner.effective["fixture/left"] == 1)
	result = owner.apply({"fixture/amount": 7}, func(_values): return false)
	check("failed application retains previous accepted and effective", result.rejected.has("fixture/amount") and owner.effective["fixture/amount"] == 6 and owner.value(owner.accepted, "fixture/amount") == 6)
	# Staged output left by an interrupted pre-publication is never promoted on reopen.
	write(owner.path + ".staged", "[unfinished")
	check("interrupted staged output ignored on reopen", owner.initialize().ok and owner.value(owner.accepted, "fixture/amount") == 6)
	adapter.release()

func logging_cases() -> void:
	var storage := Storage.new()
	var context: Dictionary = storage.resolve(launch("logging")).context
	var logger := LaunchLog.new()
	logger.start(storage.adapter, context)
	logger.message("ERROR", "first launch")
	logger.message("EXCEPTION", "fixture exception", "fixture stack trace")
	logger.message("INFO", OS.get_environment("USERPROFILE") + "/fixture")
	var current := str(context.logs).path_join("Player.log")
	var previous := str(context.logs).path_join("Player-prev.log")
	check("message flush visible before close", FileAccess.get_file_as_string(current).contains("first launch"))
	OS.add_logger(logger)
	print("Controlled engine informational diagnostic")
	push_warning("Controlled engine warning diagnostic")
	OS.remove_logger(logger)
	check("engine diagnostics use launch logger", FileAccess.get_file_as_string(current).contains("Controlled engine informational diagnostic") and FileAccess.get_file_as_string(current).contains("Controlled engine warning diagnostic"))
	logger.message("INFO", "Controlled repeated diagnostic")
	logger.message("INFO", "Controlled repeated diagnostic")
	check("repeated messages remain distinct", FileAccess.get_file_as_string(current).count("Controlled repeated diagnostic") == 2)
	var before_debug := FileAccess.get_file_as_bytes(current)
	logger.message("DEBUG", "Not enabled in ordinary release logging")
	check("debug output disabled by default", FileAccess.get_file_as_bytes(current) == before_debug)
	var first := FileAccess.get_file_as_string(current)
	check("privacy and pending mod metadata", first.contains("<user-home>/fixture") and first.contains("not yet established") and first.contains("fixture stack trace"))
	logger.start(storage.adapter, context)
	check("session reentry no rotation", not FileAccess.file_exists(previous))
	logger.stop("fixture close")
	logger = LaunchLog.new()
	logger.start(storage.adapter, context)
	check("second launch retains prior log", FileAccess.get_file_as_string(previous) == first)
	logger.mods_established([{"id": "fixture", "version": "1"}])
	check("mod result appended after discovery", FileAccess.get_file_as_string(current).contains("fixture"))
	logger.cap_bytes = logger.bytes_written + 256
	logger.message("ERROR", "界".repeat(500))
	var capped := FileAccess.get_file_as_bytes(current)
	check("UTF8 log cap with truncation and one warning", capped.size() <= logger.cap_bytes and capped.get_string_from_utf8().contains(LaunchLog.TRUNCATION.strip_edges()) and capped.get_string_from_utf8().ends_with(LaunchLog.LIMIT_NOTICE) and not logger.warning.is_empty())
	logger.message("ERROR", "not recorded")
	check("capped logger stops append", FileAccess.get_file_as_bytes(current) == capped and LaunchLog.CAP_BYTES == 209715200)
	storage.adapter.faults.log_rotate = true
	logger = LaunchLog.new()
	logger.start(storage.adapter, context)
	check("failed rotation preserves both files", logger.file == null and not logger.warning.is_empty() and FileAccess.get_file_as_bytes(current) == capped and FileAccess.get_file_as_string(previous) == first)
	storage.adapter.faults.clear()
	logger = LaunchLog.new()
	logger.start(storage.adapter, context)
	storage.adapter.faults.log_write = true
	logger.message("ERROR", "injected failure")
	check("runtime logging failure nonblocking", logger.file == null and not logger.warning.is_empty() and not storage.context.is_empty())
	var after_failure := FileAccess.get_file_as_bytes(current)
	logger.start(storage.adapter, context)
	logger.message("ERROR", "No automatic retry this launch")
	check("failed logger does not retry or rotate during launch", FileAccess.get_file_as_bytes(current) == after_failure)
	storage.adapter.faults.clear()
	logger = LaunchLog.new()
	logger.start(storage.adapter, context)
	check("logging retries next launch", logger.file != null)
	logger.stop("fixture done")
	storage.adapter.release()
	var controller := Controller.new()
	controller.providers = Provider.new()
	controller.providers.resolved_source = base.path_join("log-unavailable/ARENA2")
	controller.storage.adapter.faults.log_open = true
	controller.start(launch("log-open-failed"))
	check("log creation failure still permits checked menu", controller.route == "main_menu" and not controller.logger.warning.is_empty())
	close_controller(controller)

func routing_cases() -> void:
	var controller := Controller.new()
	var provider := Provider.new()
	provider.classic_ok = false
	controller.providers = provider
	var inputs := launch("routing", true)
	controller.start(inputs)
	check("classic rejection routes mandatory before package", controller.route == "mandatory_setup" and provider.package_calls == 0)
	var before := controller.settings.accepted.encode_to_text()
	controller.select_folder("")
	check("picker cancellation leaves committed state", before == controller.settings.accepted.encode_to_text())
	controller.cancel_setup()
	check("mandatory cancel cannot reach menu", controller.route == "mandatory_setup")
	provider.classic_ok = true
	provider.package_ok = false
	provider.resolved_source = str(inputs.executable_dir).path_join("DF/ARENA2")
	controller.select_folder(str(inputs.executable_dir).path_join("DF"))
	check("package rejection carries source reason", controller.route == "package_recovery" and controller.result.source == "fixture.package@1" and not controller.result.reason.is_empty() and controller.published.is_empty())
	check("portable internal source stored relative executable", controller.settings.value(controller.settings.accepted, "startup/classic_path") == "DF/ARENA2")
	provider.package_ok = true
	provider.menu_ok = false
	controller.check_content()
	check("menu failure independent recovery", controller.route == "menu_recovery" and not controller.menu_entered)
	provider.menu_ok = true
	provider.on_open = func(): check("reentrant menu request busy", controller.continue_to_menu().kind == "busy")
	controller.continue_to_menu()
	provider.on_open = Callable()
	check("valid configuration reaches menu", controller.route == "main_menu" and controller.menu_entered)
	var calls := provider.menu_calls
	controller.continue_to_menu()
	check("repeated continue idempotent", provider.menu_calls == calls)
	controller.open_setup()
	controller.cancel_setup()
	check("optional setup cancel returns menu", controller.route == "main_menu")
	controller.open_setup()
	var active := controller.active_source
	provider.resolved_source = base.path_join("outside/ARENA2")
	controller.select_folder(provider.resolved_source)
	check("menu source change saved pending restart", controller.active_source == active and controller.settings.effective["startup/classic_path"] == "DF/ARENA2" and controller.result.detail.contains("restart"))
	check("external portable source stored absolute", controller.settings.value(controller.settings.accepted, "startup/classic_path") == provider.resolved_source)
	controller.settings.apply({"startup/show_setup": true})
	close_controller(controller)
	controller = Controller.new()
	provider = Provider.new()
	provider.resolved_source = base.path_join("outside/ARENA2")
	controller.providers = provider
	controller.start(inputs)
	check("persisted startup preference optional setup on relaunch", controller.route == "optional_setup" and controller.active_source == provider.resolved_source)
	close_controller(controller)
	controller = Controller.new()
	controller.storage.adapter.faults.settings_publish = true
	controller.providers = Provider.new()
	controller.start(launch("startup-publication-failed"))
	check("startup publication failure blocks content and menu", controller.route == "settings_recovery" and not controller.menu_entered and controller.providers.classic_calls == 0)
	controller.storage.adapter.faults.clear()
	controller.providers.resolved_source = base.path_join("recovered/ARENA2")
	controller.start(controller.launch)
	check("startup publication explicit retry", controller.route == "main_menu")
	close_controller(controller)

func rendered_cases() -> void:
	var original: StartupController = shell.controller
	var controller := Controller.new()
	var inputs := launch("rendered-storage", true)
	write(str(inputs.executable_dir).path_join("PortableAppdata"), "unwritable directory fixture")
	controller.start(inputs)
	shell.controller = controller
	shell.inputs = inputs
	shell.render()
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	shell.get_viewport().get_texture().get_image().save_png(str(base.get_base_dir()).path_join("storage-recovery.png"))
	check("rendered portable recovery buttons", shell.panel.get_child_count() >= 8 and controller.route == "storage_recovery")
	await click_button("Retry")
	check("rendered Retry retains blocking portable failure", controller.route == "storage_recovery" and controller.storage.context.is_empty())
	await click_button("Use standard storage for this launch")
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	shell.get_viewport().get_texture().get_image().save_png(str(base.get_base_dir()).path_join("mandatory-setup.png"))
	check("rendered explicit fallback mandatory setup", controller.route == "mandatory_setup")
	var provider := Provider.new()
	provider.resolved_source = base.path_join("rendered-classic/ARENA2")
	controller.providers = provider
	controller.check_content()
	shell.render()
	await click_button("Settings / Setup")
	check("rendered main menu setup entry", controller.route == "optional_setup")
	await click_button("Show setup at startup (takes effect next launch)")
	await click_button("Cancel")
	check("rendered Cancel discards staged preference", controller.route == "main_menu" and not controller.settings.value(controller.settings.accepted, "startup/show_setup"))
	await click_button("Settings / Setup")
	await click_button("Show setup at startup (takes effect next launch)")
	await click_button("Apply startup preference")
	check("rendered Apply persists deferred preference", controller.settings.value(controller.settings.accepted, "startup/show_setup") and not controller.settings.effective["startup/show_setup"])
	await click_button("Cancel")
	check("rendered Cancel after Apply preserves acceptance", controller.settings.value(controller.settings.accepted, "startup/show_setup"))
	controller.open_setup()
	shell.render()
	controller.storage.adapter.faults.log_write = true
	controller.logger.message("ERROR", "Controlled runtime logging failure")
	await shell.get_tree().process_frame
	check("runtime logging warning shown independently", shell.logging_status.visible and not shell.logging_status.text.is_empty() and shell.logging_status.text == controller.logger.warning and controller.route == "optional_setup")
	controller.storage.adapter.faults.clear()
	close_controller(controller)
	shell.controller = original
	shell.render()

func click_button(text: String) -> void:
	# Stock preference/presentation signals can queue another render. Resolve the
	# actual control only after those renders, rather than retaining a freed one.
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var target: BaseButton
	for item in shell.panel.get_children():
		if item is BaseButton and item.text == text:
			target = item
			break
	if target == null:
		check("rendered input target " + text, false)
		return
	(shell.panel.get_parent() as ScrollContainer).ensure_control_visible(target)
	await shell.get_tree().process_frame
	if not is_instance_valid(target):
		check("rendered input target " + text, false)
		return
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = target.get_global_rect().get_center()
	event.pressed = true
	Input.parse_input_event(event)
	await shell.get_tree().process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await shell.get_tree().process_frame

