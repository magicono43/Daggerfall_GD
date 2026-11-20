class_name StartupController
extends RefCounted
const Storage = preload("res://scripts/startup/storage_owner.gd")
const Settings = preload("res://scripts/startup/settings_owner.gd")
const LaunchLogger = preload("res://scripts/startup/launch_logger.gd")
const Providers = preload("res://scripts/startup/provider_boundary.gd")
var storage := Storage.new()
var settings: StartupSettingsOwner
var logger := LaunchLogger.new()
var providers: RefCounted = Providers.new()
var route := "not_started"
var result: Dictionary = {}
var launch: Dictionary
var active_source := ""
var published: Dictionary = {}
var transition_busy := false
var menu_entered := false
var warnings: Array[String] = []

func start(inputs: Dictionary, fallback := false, reset := false) -> Dictionary:
	launch = inputs.duplicate(true)
	var checked := storage.resolve(inputs, fallback)
	if not checked.ok:
		return set_route("storage_recovery", checked)
	if not logger.initialized:
		logger.start(storage.adapter, checked.context)
		warnings.assign(checked.context.warnings)
		if not logger.warning.is_empty():
			warnings = warnings.filter(func(text: String): return not text.begins_with("Optional logs"))
	if settings == null:
		settings = Settings.new(storage.adapter, checked.context.settings)
	checked = settings.initialize(reset)
	if not checked.ok:
		return set_route("settings_recovery", checked)
	if checked.kind == "recovered" and not warnings.has(checked.detail):
		warnings.append(checked.detail)
	return check_content()

func resolved_path(path: String) -> String:
	return str(launch.executable_dir).path_join(path).simplify_path() if path.is_relative_path() and not path.is_empty() else path

func stored_path(path: String) -> String:
	var base := str(launch.executable_dir).replace("\\", "/").simplify_path().trim_suffix("/")
	var normalized := path.replace("\\", "/").simplify_path()
	if storage.context.mode == "portable" and normalized.to_lower().begins_with(base.to_lower() + "/"):
		return normalized.substr(base.length() + 1)
	return normalized

func check_content() -> Dictionary:
	var requested: String = settings.effective["startup/classic_path"]
	var classic: Dictionary = providers.check_classic(resolved_path(requested))
	if not classic.get("ok", false):
		return set_route("mandatory_setup", classic)
	var packages: Dictionary = published if menu_entered else providers.publish_packages(classic)
	if not packages.get("ok", false):
		return set_route("package_recovery", packages)
	# Publication is accepted only after provider success. No failed candidate leaks.
	published = packages.duplicate(true)
	active_source = classic.source
	logger.mods_established(packages.get("mods", []))
	return set_route("optional_setup", {}) if settings.effective["startup/show_setup"] else continue_to_menu()

func select_folder(candidate: String) -> Dictionary:
	if candidate.is_empty():
		return result # Folder-picker cancellation does not mutate preferences.
	var checked: Dictionary = providers.check_classic(candidate)
	if not checked.get("ok", false):
		return set_route("optional_setup" if menu_entered else "mandatory_setup", checked)
	var saved := settings.apply({"startup/classic_path": stored_path(checked.source)})
	if not saved.ok:
		return set_route("optional_setup" if menu_entered else "settings_recovery", saved)
	if menu_entered and checked.source != active_source:
		return set_route("optional_setup", {"ok": true, "detail": "Saved; source change pending application restart. Current source retained."})
	# Initial source may activate after validation and persistence, before any menu.
	settings.effective["startup/classic_path"] = settings.value(settings.accepted, "startup/classic_path")
	return check_content()

func continue_to_menu() -> Dictionary:
	if route == "main_menu":
		return result.duplicate(true)
	if transition_busy:
		return {"ok": false, "kind": "busy", "route": route}
	if published.is_empty() or active_source.is_empty():
		return set_route("mandatory_setup", {"ok": false, "reason": "Required content is not published."})
	transition_busy = true
	var opened: Dictionary = providers.open_menu()
	transition_busy = false
	if not opened.get("ok", false):
		return set_route("menu_recovery", opened)
	menu_entered = true
	return set_route("main_menu", {"ok": true})

func open_setup() -> Dictionary:
	return set_route("optional_setup" if menu_entered else "mandatory_setup", {})

func cancel_setup() -> Dictionary:
	return continue_to_menu() if menu_entered else set_route("mandatory_setup", result)

func set_route(next: String, details: Dictionary) -> Dictionary:
	route = next
	result = details.duplicate(true)
	result.route = route
	return result.duplicate(true)
