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
var mods: RefCounted
var prepared_content: Dictionary = {}
var controls := preload("res://scripts/input/binding_configuration.gd").new()

func real_content_pipeline() -> bool:
	return providers.has_method("uses_definition_pipeline") and providers.uses_definition_pipeline()

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
		controls.declare_settings(settings)
		if providers.get("presentation") != null:
			providers.presentation.declare_settings(settings)
		if providers.get("media_preferences") != null:
			providers.media_preferences.declare_settings(settings)
	checked = settings.initialize(reset)
	if not checked.ok:
		return set_route("settings_recovery", checked)
	controls.load_effective()
	for notice: String in controls.notices:
		if not warnings.has(notice): warnings.append(notice)
	if checked.kind == "recovered" and not warnings.has(checked.detail):
		warnings.append(checked.detail)
	if mods == null:
		mods = preload("res://scripts/mod/mod_configuration.gd").new(storage.adapter, storage.context.root)
		var initialized: Dictionary = mods.initialize()
		if initialized.ok:
			mods.rescan()
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
	if menu_entered and real_content_pipeline():
		return set_route("optional_setup", {"ok": true, "detail": "The active package plan and definitions remain locked."})
	var requested: String = settings.effective["startup/classic_path"]
	# MOD/DATA rebuilds do not reconstruct even temporary classic indexes. Explicit
	# folder selections still validate through select_folder; active sources do not switch.
	var reuse_classic: bool = real_content_pipeline() and not active_source.is_empty() and providers.classic.ready()
	var classic: Dictionary = {"ok": true, "source": active_source, "stage": "active", "ready": true} if reuse_classic else providers.check_classic(resolved_path(requested))
	if not classic.get("ok", false):
		return set_route("mandatory_setup", classic)
	if providers.has_method("activate_classic") and not reuse_classic:
		var activated: Dictionary = providers.activate_classic(classic)
		if not activated.ok:
			return set_route("mandatory_setup", activated)
		active_source = classic.source
	var plan: Dictionary = published.get("plan", {}) if menu_entered else (mods.validate_dependencies() if mods != null else {})
	if not plan.is_empty() and not plan.ok:
		prepared_content.clear()
		if real_content_pipeline():
			providers.formulas.discard_candidate()
		return set_route("package_recovery", {"ok": false, "source": "dependencies", "reason": "Repair the package dependency configuration before continuing.", "plan": plan})
	if real_content_pipeline():
		prepared_content = providers.prepare_content(mods)
		if not prepared_content.ok:
			return set_route("package_recovery", prepared_content)
		return set_route("optional_setup", prepared_content) if settings.effective["startup/show_setup"] or mods.dirty() else _commit_prepared_content("run")
	var packages: Dictionary = published if menu_entered else providers.publish_packages(classic)
	if not packages.get("ok", false):
		packages.plan = plan.duplicate(true)
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
	var previous := settings.clone(settings.accepted)
	var saved := settings.apply({"startup/classic_path": stored_path(checked.source)})
	if not saved.ok:
		# Source selection is transactional, unlike ordinary accepted-unsaved preferences.
		settings.accepted = previous
		saved.pending = settings.pending()
		saved.application = "rejected_source_selection"
		if providers.has_method("discard_classic_candidate"):
			providers.discard_classic_candidate()
		return set_route("optional_setup" if menu_entered else "settings_recovery", saved)
	if (menu_entered or (providers.has_method("activate_classic") and not active_source.is_empty())) and checked.source != active_source:
		if providers.has_method("discard_classic_candidate"):
			providers.discard_classic_candidate()
		return set_route("optional_setup" if menu_entered else "package_recovery", {"ok": true, "detail": "Saved; source change pending application restart. Current source retained."})
	if providers.has_method("activate_classic"):
		var activated: Dictionary = providers.activate_classic(checked)
		if not activated.ok:
			return set_route("mandatory_setup", activated)
		active_source = checked.source
	# Initial source may activate after validation and persistence, before any menu.
	settings.effective["startup/classic_path"] = settings.value(settings.accepted, "startup/classic_path")
	return check_content()

func continue_to_menu(profile_choice := "") -> Dictionary:
	if route == "main_menu":
		return result.duplicate(true)
	if transition_busy:
		return {"ok": false, "kind": "busy", "route": route}
	if real_content_pipeline() and not menu_entered:
		return commit_content_menu(profile_choice)
	if published.is_empty() or active_source.is_empty():
		return set_route("mandatory_setup", {"ok": false, "reason": "Required content is not published."})
	transition_busy = true
	var opened: Dictionary = providers.open_menu()
	transition_busy = false
	if not opened.get("ok", false):
		return set_route("menu_recovery", opened)
	menu_entered = true
	return set_route("main_menu", {"ok": true})

func commit_content_menu(profile_choice: String) -> Dictionary:
	if active_source.is_empty() or not providers.classic.ready():
		return set_route("mandatory_setup", {"ok": false, "reason": "Required classic readers are not ready."})
	if not profile_choice.is_empty() and profile_choice not in ["save", "run"]:
		return set_route("optional_setup", {"ok": false, "reason": "Unknown profile continuation choice."})
	prepared_content = providers.prepare_content(mods) # Always rebuild from clean defaults.
	if not prepared_content.ok:
		return set_route("package_recovery", prepared_content)
	return _commit_prepared_content(profile_choice)

func _commit_prepared_content(profile_choice: String) -> Dictionary:
	# check_content may enter here in the same synchronous stack as preparation;
	# interactive Continue still rebuilds through commit_content_menu above.
	if mods.dirty() and profile_choice not in ["save", "run"]:
		return set_route("optional_setup", {"ok": false, "kind": "unsaved_profile", "reason": "Save and Continue, or Continue for This Run?", "choices": ["save", "run"]})
	transition_busy = true
	mods.entry_busy = true
	var reserved: Dictionary = providers.definitions.reserve_commit(prepared_content.ticket, mods)
	if not reserved.ok:
		mods.entry_busy = false
		transition_busy = false
		return set_route("package_recovery", reserved)
	var hooks_reserved: Dictionary = providers.formulas.reserve_commit(prepared_content.formula_ticket,mods)
	if not hooks_reserved.ok:
		providers.definitions.release_commit()
		mods.entry_busy = false
		transition_busy = false
		return set_route("package_recovery",hooks_reserved)
	var opened: Dictionary = providers.open_menu()
	if not opened.get("ok", false):
		providers.definitions.release_commit()
		providers.formulas.release_commit()
		mods.entry_busy = false
		transition_busy = false
		return set_route("menu_recovery", opened)
	var saved: Dictionary = mods.commit_entry_profile(profile_choice == "save")
	if not saved.ok:
		providers.definitions.release_commit()
		providers.formulas.release_commit()
		mods.entry_busy = false
		transition_busy = false
		return set_route("package_recovery", saved)
	# Synchronous checked boundary: no further I/O/callbacks can reject publication.
	var content: Dictionary = providers.definitions.commit(prepared_content.ticket)
	content.formulas = providers.formulas.commit(prepared_content.formula_ticket)
	if providers.presentation != null:
		providers.presentation.commit(prepared_content.ticket,providers.definitions,settings)
	providers.commit_preferences()
	if providers.media != null:
		providers.media.commit_candidate()
	mods.lock_configuration(content.plan, content.packages)
	# commit returns a detached projection; CORE owns this local return value.
	published = content
	published.mods = content.packages.values().map(func(package: Dictionary): return {"id": package.id, "version": package.version})
	logger.mods_established(published.mods)
	menu_entered = true
	transition_busy = false
	return set_route("main_menu", {"ok": true, "configuration_id": content.ticket})

func open_setup() -> Dictionary:
	return set_route("optional_setup" if menu_entered else "mandatory_setup", {})

func cancel_setup() -> Dictionary:
	return continue_to_menu() if menu_entered else set_route("mandatory_setup", result)

func set_route(next: String, details: Dictionary) -> Dictionary:
	route = next
	result = details.duplicate(true)
	result.route = route
	return result.duplicate(true)
