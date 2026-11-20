extends "res://tests/mod_cases.gd"
const Planner = preload("res://scripts/mod/dependency_planner.gd")
const IDS = ["plan.a", "plan.b", "plan.c"]
var configuration: RefCounted
var library_root := ""
var case_number := 0

func dependency(id: String, optional := false, order := "provider_first", minimum := "", maximum := "") -> Dictionary:
	var value := {"id": id, "optional": optional, "order": order}
	if not minimum.is_empty():
		value.min = minimum
	if not maximum.is_empty():
		value.max = maximum
	return value

func package(id: String, dependencies: Array, version := "1.0.0") -> void:
	var value := manifest(id, version)
	value.dependencies = dependencies.duplicate(true)
	if id == "plan.b":
		archive(library_root.path_join("B.zip"), {"mod.json": JSON.stringify(value)})
	else:
		write(library_root.path_join(id + "/mod.json"), JSON.stringify(value))

func arrange(order: Array) -> void:
	var reversed := order.duplicate()
	reversed.reverse()
	for id: String in reversed:
		for attempt in 3:
			configuration.edit(id, "up")

func configure(a: Array, b: Array, c: Array, enabled: Array = IDS, order: Array = IDS, versions: Array = ["1.0.0", "1.0.0", "1.0.0"]) -> Dictionary:
	case_number += 1
	for index in IDS.size():
		package(IDS[index], [a, b, c][index], versions[index])
	configuration.rescan()
	configuration.manage("create", "Dependency case %d" % case_number)
	for id: String in enabled:
		configuration.edit(id, "toggle")
	arrange(order)
	return configuration.validate_dependencies()

func has_error(plan: Dictionary, kind: String, dependent := "", provider := "") -> bool:
	for issue: Dictionary in plan.errors:
		if issue.kind == kind and (dependent.is_empty() or issue.dependent == dependent) and (provider.is_empty() or issue.provider == provider):
			return true
	return false

func integration(plan: Dictionary, key: String) -> Dictionary:
	for entry: Dictionary in plan.integrations:
		if entry.key == key:
			return entry
	return {}

func planning_capture(shell: Control, name: String) -> void:
	shell.render()
	await shell.get_tree().process_frame
	for child in shell.panel.get_children():
		if child is Label and child.text.begins_with("Dependencies ·"):
			shell.panel.get_parent().scroll_vertical = int(child.position.y)
			break
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := shell.get_viewport().get_texture().get_image()
	check(name + " frame", false, image.is_empty())
	image.save_png(sandbox.path_join(name + ".png"))

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	configuration = shell.controller.mods
	library_root = configuration.root.path_join("Mods")
	var adapter = shell.controller.storage.adapter
	check("empty discovered plan validates", true, configuration.validate_dependencies().ok)
	check("empty plan does not publish DATA", false, configuration.selection().data_ready)
	package("plan.a", [])
	package("plan.b", [dependency("plan.a")])
	package("plan.c", [dependency("plan.b")])
	configuration.rescan()
	for id: String in IDS:
		configuration.edit(id, "toggle")
	arrange(["plan.c", "plan.b", "plan.a"])
	var plan: Dictionary = configuration.validate_dependencies()
	check("chain invalid order blocks validation", false, plan.ok)
	check("chain constraints all active", 2, plan.constraints.size())
	check("chain context identifies dependent and provider", true, has_error(plan, "order", "plan.b", "plan.a"))
	check("unfinished order may save", true, configuration.save_profile().ok)
	var committed: Dictionary = configuration.committed.duplicate(true)
	var pending: Dictionary = configuration.pending()
	var preview: Dictionary = configuration.request_sort_preview()
	check("provider-first chain preview", IDS, preview.order)
	check("preview leaves pending order unchanged", pending, configuration.pending())
	var repeated: Dictionary = configuration.request_sort_preview()
	check("repeated previews deterministic", preview.order, repeated.order)
	check("replaced preview ticket rejected", false, configuration.accept_sort_preview(preview.id).ok)
	check("dismiss preview", true, configuration.dismiss_sort_preview(repeated.id).ok)
	check("dismissal preserves pending", pending, configuration.pending())
	preview = configuration.request_sort_preview()
	check("accepted preview revalidates", true, configuration.accept_sort_preview(preview.id).ok)
	check("accepted order provider-first", IDS, configuration.validate_dependencies().order)
	check("sort affects pending only", committed, configuration.committed)
	check("repeated acceptance rejected", false, configuration.accept_sort_preview(preview.id).ok)
	var sorted_pending: Dictionary = configuration.pending()
	adapter.faults.mod_profiles_publish = true
	check("sorted profile write can fail", false, configuration.save_profile().ok)
	check("failed sorted write retains committed", committed, configuration.committed)
	check("failed sorted write retains pending", sorted_pending, configuration.pending())
	adapter.faults.clear()
	check("sorted profile retry saves", true, configuration.save_profile().ok)
	check("sorting and saving never advance menu history", "", configuration.committed.last_successful)
	preview = configuration.request_sort_preview()
	configuration.edit("plan.c", "toggle")
	check("enablement edit invalidates preview", false, configuration.accept_sort_preview(preview.id).ok)
	configuration.edit("plan.c", "toggle")
	preview = configuration.request_sort_preview()
	configuration.edit("plan.a", "down")
	check("order edit invalidates preview", false, configuration.accept_sort_preview(preview.id).ok)
	arrange(IDS)
	preview = configuration.request_sort_preview()
	configuration.rescan()
	check("rescan invalidates preview", false, configuration.accept_sort_preview(preview.id).ok)
	preview = configuration.request_sort_preview()
	configuration.manage("create", "Switched profile")
	check("profile switch invalidates preview", false, configuration.accept_sort_preview(preview.id).ok)
	plan = configure([], [dependency("plan.missing")], [])
	check("missing required provider blocks", true, has_error(plan, "missing", "plan.b", "plan.missing"))
	check("missing required provider prevents preview", false, configuration.request_sort_preview().ok)
	configuration.edit("plan.b", "toggle")
	check("disabled dependent imposes no constraints", true, configuration.validate_dependencies().ok)
	plan = configure([], [dependency("plan.a")], [], ["plan.b", "plan.c"])
	check("disabled required provider blocks", true, has_error(plan, "disabled", "plan.b", "plan.a"))
	check("disabled provider not implicitly enabled", false, configuration.rows()[0].enabled)
	check("compatible disabled provider offered", true, plan.errors[0].can_enable)
	check("explicit enablement revalidates", true, configuration.enable_dependency("plan.b:0", plan.revision).ok)
	check("explicit enablement enables only requested provider", true, configuration.rows()[0].enabled)
	check("old enablement request rejected", false, configuration.enable_dependency("plan.b:0", plan.revision).ok)
	plan = configure([dependency("plan.missing")], [dependency("plan.a")], [], ["plan.b"])
	var enabled_plan: Dictionary = configuration.enable_dependency("plan.b:0", plan.revision)
	check("explicit enablement exposes provider prerequisites", true, has_error(enabled_plan, "missing", "plan.a", "plan.missing"))
	plan = configure([], [dependency("plan.a", false, "provider_first", "1.0.0", "2.0.0")], [], ["plan.b"], IDS, ["3.0.0", "1.0.0", "1.0.0"])
	check("incompatible disabled provider not offered", false, plan.errors[0].can_enable)
	check("incompatible explicit enablement rejected", false, configuration.enable_dependency("plan.b:0", plan.revision).ok)
	plan = configure([], [dependency("plan.a")], [])
	configuration.edit("plan.a", "skip")
	plan = configuration.validate_dependencies()
	check("run-skipped required provider blocks", true, has_error(plan, "disabled", "plan.b", "plan.a"))
	check("explicit provider recovery restores run skip", true, configuration.enable_dependency("plan.b:0", plan.revision).ok and not configuration.rows()[0].skipped)
	configure([], [dependency("plan.a", false, "provider_first", "2.1.0", "3.0.0")], [], IDS, IDS, ["2.1.0", "1.0.0", "1.0.0"])
	for vector: Array in [["2.1.0", true], ["3.0.0", false], ["2.0.9", false], ["2.1.0-alpha", false], ["2.1.0+build.7", true], ["2.9.999", true]]:
		package("plan.a", [], vector[0])
		configuration.rescan()
		check("range vector " + vector[0], vector[1], configuration.validate_dependencies().ok)
	var versions := [["1.0.0-alpha", "1.0.0-alpha.1"], ["1.0.0-alpha.1", "1.0.0-alpha.beta"], ["1.0.0-beta.2", "1.0.0-beta.11"], ["1.0.0-rc.1", "1.0.0"], ["1.0.0--1", "1.0.0-alpha"], ["999999999999999999999.0.0", "1000000000000000000000.0.0"]]
	for vector: Array in versions:
		check("version ordering " + vector[0], -1, Planner.compare_versions(vector[0], vector[1]))
	check("build metadata does not affect precedence", 0, Planner.compare_versions("1.0.0+left", "1.0.0+right"))
	check("accepted numeric prerelease leading zeros compare by value", 0, Planner.compare_versions("1.0.0-01", "1.0.0-1"))
	plan = configure([], [], [dependency("plan.missing", true)])
	check("missing optional integration inactive without warning", true, plan.ok and plan.warnings.is_empty() and not integration(plan, "plan.c:0").active)
	plan = configure([], [], [dependency("plan.b", true)], ["plan.a", "plan.c"])
	check("disabled optional integration inactive without edge", true, plan.ok and plan.constraints.is_empty() and plan.warnings.is_empty())
	plan = configure([], [], [dependency("plan.b", true, "provider_first", "1.0.0", "2.0.0")], IDS, IDS, ["1.0.0", "2.0.0", "1.0.0"])
	check("enabled incompatible optional warns but permits plan", true, plan.ok and plan.warnings.size() == 1 and not integration(plan, "plan.c:0").active)
	check("incompatible optional contributions refused", false, configuration.integration_allowed("plan.c:0", "contributions", configuration.revision))
	plan = configure([], [], [dependency("plan.b", true)], IDS, ["plan.c", "plan.b", "plan.a"])
	check("compatible optional edge constrains manual order", true, has_error(plan, "order", "plan.c", "plan.b"))
	check("stable sort preserves unrelated preferred order where feasible", ["plan.b", "plan.c", "plan.a"], configuration.request_sort_preview().order)
	plan = configure([], [], [dependency("plan.b", false, "presence_only")], IDS, ["plan.c", "plan.b", "plan.a"])
	check("presence-only does not order", true, plan.ok and plan.constraints.is_empty())
	check("presence-only preview preserves preference", ["plan.c", "plan.b", "plan.a"], configuration.request_sort_preview().order)
	plan = configure([dependency("plan.a", false, "presence_only")], [], [])
	check("self presence-only is not an ordering cycle", true, plan.ok and plan.cycles.is_empty())
	plan = configure([], [], [dependency("plan.b", false, "presence_only", "2.0.0")])
	check("presence-only still validates version", true, has_error(plan, "incompatible", "plan.c", "plan.b"))
	plan = configure([dependency("plan.c")], [dependency("plan.a")], [dependency("plan.b")])
	check("required cycle includes complete loop", true, plan.cycles.has(["plan.a", "plan.b", "plan.c", "plan.a"]))
	check("required cycle blocks sort preview", false, configuration.request_sort_preview().ok)
	check("required edge cannot be suppressed", false, configuration.suppress_optional("plan.a:0", plan.revision).ok)
	plan = configure([dependency("plan.a")], [], [])
	check("self cycle reported completely", [["plan.a", "plan.a"]], plan.cycles)
	plan = configure([dependency("plan.c", true)], [dependency("plan.a")], [dependency("plan.b")])
	check("participating optional edge offered", ["plan.a:0"], plan.suppressible)
	var saved: Dictionary = configuration.committed.duplicate(true)
	check("explicit optional suppression resolves cycle", true, configuration.suppress_optional("plan.a:0", plan.revision).ok)
	check("suppression preserves saved profile", saved, configuration.committed)
	check("suppressed contribution gate closed", false, configuration.integration_allowed("plan.a:0", "contributions", configuration.revision))
	check("suppressed hook gate closed", false, configuration.integration_allowed("plan.a:0", "hooks", configuration.revision))
	check("active required relationship gate open", true, configuration.integration_allowed("plan.b:0", "contributions", configuration.revision))
	check("unknown relationship gate closed", false, configuration.integration_allowed("unknown", "hooks", configuration.revision))
	var admitted_revision: int = configuration.revision
	configuration.rescan()
	check("obsolete consumer admission refused", false, configuration.integration_allowed("plan.b:0", "contributions", admitted_revision))
	check("equivalent rescan retains suppression", true, configuration.validate_dependencies().ok)
	configuration.restore_optional("plan.a:0")
	check("restore integration revalidates cycle", false, configuration.validate_dependencies().ok)
	plan = configuration.validate_dependencies()
	configuration.select_profile(configuration.selected)
	check("obsolete suppression request rejected", false, configuration.suppress_optional("plan.a:0", plan.revision).ok)
	plan = configuration.validate_dependencies()
	configuration.suppress_optional("plan.a:0", plan.revision)
	package("plan.a", [dependency("plan.c", true, "provider_first", "1.0.0")])
	configuration.rescan()
	check("changed declaration cannot inherit suppression", false, configuration.validate_dependencies().ok)
	plan = configure([dependency("plan.b"), dependency("plan.c", true)], [dependency("plan.a")], [dependency("plan.a")])
	check("multiple complete cycle paths", 2, plan.cycles.size())
	check("suppressing optional edge leaves required cycle blocked", false, configuration.suppress_optional("plan.a:1", plan.revision).ok)
	plan = configure([], [], [dependency("plan.b", true)])
	check("non-cycle optional integration cannot be suppressed", false, configuration.suppress_optional("plan.c:0", plan.revision).ok)
	# Production startup consumes the real plan and real DATA readers, never a mock success.
	configure([], [dependency("plan.a")], [dependency("plan.b")], IDS, ["plan.c", "plan.b", "plan.a"])
	shell.controller.select_folder(fixture.classic_source)
	check("normal startup rejects invalid real plan", "dependencies", shell.controller.result.source)
	var retained: Array = shell.controller.providers.classic.inventory()
	preview = configuration.request_sort_preview()
	configuration.accept_sort_preview(preview.id)
	shell.controller.check_content()
	check("valid MOD plan still stops at real DATA publication gate", "packages", shell.controller.result.source)
	check("reader identity retained through planning", retained, shell.controller.providers.classic.inventory())
	check("no actual menu entry fabricated", false, shell.controller.menu_entered)
	check("no publication fabricated", true, shell.controller.published.is_empty())
	if DisplayServer.get_name() != "headless":
		arrange(["plan.c", "plan.b", "plan.a"])
		shell.render()
		check("UI requests preview", true, await click(shell, "Preview Auto-sort"))
		await planning_capture(shell, "planning-preview")
		pending = configuration.pending()
		check("UI dismisses preview", true, await click(shell, "Dismiss Sort Preview"))
		check("UI dismissal preserves order", pending, configuration.pending())
		await click(shell, "Preview Auto-sort")
		check("UI accepts preview", true, await click(shell, "Accept Sort Preview"))
		check("UI accepted order revalidates", true, configuration.validate_dependencies().ok)
		configure([], [dependency("plan.a")], [], ["plan.b", "plan.c"])
		shell.render()
		check("UI explicitly enables provider", true, await click(shell, "Enable required provider plan.a"))
		check("UI enabled provider validated", true, configuration.validate_dependencies().ok)
		configure([dependency("plan.c", true)], [dependency("plan.a")], [dependency("plan.b")])
		await planning_capture(shell, "planning-cycle")
		check("UI suppresses participating optional integration", true, await click(shell, "Suppress optional integration plan.a:0 for this run"))
		check("UI suppressed dependent hooks inactive", false, configuration.integration_allowed("plan.a:0", "hooks", configuration.revision))
		await planning_capture(shell, "planning-suppressed")
		check("UI Continue cannot bypass DATA", true, await click(shell, "Validate and Continue"))
		check("UI Continue stays in package recovery", "package_recovery", shell.controller.route)
	# Independent restart must revalidate the saved declarations with no run suppression.
	package("plan.a", [dependency("plan.c", true)])
	package("plan.b", [dependency("plan.a")])
	package("plan.c", [dependency("plan.b")])
	configuration.rescan()
	configuration.select_profile("default")
	arrange(IDS)
	plan = configuration.validate_dependencies()
	configuration.suppress_optional("plan.a:0", plan.revision)
	configuration.save_profile()
	configuration.edit("plan.b", "toggle")
	configuration.edit("plan.c", "skip")
	var ok := true
	for entry: Dictionary in checks:
		ok = ok and entry.expected == entry.actual
	return {"ok": ok, "count": checks.size(), "checks": checks, "engine": Engine.get_version_info(), "display": DisplayServer.get_name(),
		"fixture": fixture.fixture, "inputs": fixture.inputs, "packages": configuration.discovery, "selection": configuration.selection(),
		"downstream": "Real CORE, MOD dependency planner and classic DATA readers; definition publication, actual menu lock and SAVE unavailable. Integration admission gates only; no executable hooks activated."}
