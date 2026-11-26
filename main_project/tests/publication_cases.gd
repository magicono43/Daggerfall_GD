extends "res://tests/mod_cases.gd"
const Fixture = preload("res://tests/publication_fixture.gd")
const Schema = preload("res://tests/fixture_definition_adapter.gd")
const Controller = preload("res://scripts/startup/startup_controller.gd")
var configuration: RefCounted
var definitions: RefCounted
var root := ""
var b_manifest: Dictionary
var b_entries: Dictionary

func put(path: String, value: Variant) -> void:
	Fixture.write(path, value)

func record(candidate: Dictionary, id := "sword", path := "items/main.json") -> Dictionary:
	return candidate.resources["fixture.records:" + path].records[id]

func rebuild() -> Dictionary:
	return definitions.prepare(configuration)

func write_b(value: Dictionary, capabilities: Array = ["data.fixture"], files: Array = ["data/patch.json"]) -> void:
	b_manifest.capabilities = capabilities
	b_manifest.content = files
	b_entries = {"mod.json": JSON.stringify(b_manifest), "data/patch.json": JSON.stringify(value)}
	archive(root.path_join("B.zip"), b_entries)
	configuration.rescan()

func capture_publication(shell: Control, name: String) -> void:
	shell.render()
	await shell.get_tree().process_frame
	for child in shell.panel.get_children():
		if child is Label and child.text.begins_with("Definitions ·"):
			shell.panel.get_parent().scroll_vertical = int(child.position.y)
			break
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := shell.get_viewport().get_texture().get_image()
	check(name + " rendered", false, image.is_empty())
	image.save_png(sandbox.path_join(name + ".png"))

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller = shell.controller
	configuration = controller.mods
	definitions = controller.providers.definitions
	root = configuration.root.path_join("Mods")
	# Explicit fixture startup preference; no later game owner settings are invented.
	controller.settings.apply({"startup/show_setup": true})
	controller.settings.effective["startup/show_setup"] = true
	var loose := Fixture.contribution("items/main.json", "patch", [{"id": "sword", "value": {"power": 9, "tags": ["loose"]}}])
	put(configuration.root.path_join("Overrides/z-loose.json"), loose)
	controller.select_folder(fixture.classic_source)
	check("real readers and DATA reach editable setup", "optional_setup", controller.route)
	check("validated definitions remain unpublished", "before_readiness", definitions.query("fixture.records", "items/main.json", "sword").kind)
	check("required adapter source declared before initialization", true, controller.providers.classic.manifest().entries[0].adapters.has("content-fixture-records"))
	check("late adapter registration rejected", false, controller.providers.register_content_adapter(Schema.new(), sandbox, []).ok)
	check("no lock before actual entry", false, configuration.locked)
	var shipped_main: String = sandbox.path_join("shipped/a-main.json")
	DirAccess.remove_absolute(shipped_main)
	var missing_default := rebuild()
	check("missing declared shipped contribution is not empty success", "missing", missing_default.issues[0].kind)
	check("required shipped source failure cannot be omitted", false, missing_default.issues[0].omittable)
	put(shipped_main, Fixture.contribution("items/main.json", "replace", [Fixture.record("sword", 1)]))
	check("repaired shipped source retries from clean base", true, rebuild().ok)
	var a := manifest("pub.a")
	a.capabilities = ["data.fixture"]
	a.content = ["data/z-patch.json", "data/a-add.json"]
	put(root.path_join("A/mod.json"), a)
	put(root.path_join("A/data/a-add.json"), Fixture.contribution("items/main.json", "add", [Fixture.record("extra", 3)]))
	put(root.path_join("A/data/z-patch.json"), Fixture.contribution("items/main.json", "patch", [
		{"id": "sword", "value": {"power": 2, "label": "A", "tags": ["a"], "nested": {"x": 1}, "nullable": "set"}}]))
	b_manifest = manifest("pub.b")
	b_manifest.dependencies = [{"id": "pub.a"}]
	var good_b := Fixture.contribution("items/main.json", "patch", [
		{"id": "sword", "value": {"power": 6, "tags": ["old-b"]}},
		{"id": "sword", "value": {"power": 7, "tags": ["b"], "nested": {"x": 4}, "nullable": null}}])
	write_b(good_b)
	configuration.edit("pub.a", "toggle")
	configuration.edit("pub.b", "toggle")
	var candidate := rebuild()
	check("real ZIP/folder pipeline accepts valid precedence", true, candidate.ok)
	check("loose override wins power", 9, record(candidate).value.power)
	check("omitted patch fields retained", "A", record(candidate).value.label)
	check("lists replace", ["loose"], record(candidate).value.tags)
	check("nested objects use adapter replacement", {"x": 4.0}, record(candidate).value.nested)
	check("explicit nullable field applied", null, record(candidate).value.nullable)
	check("definition identity retains shipped origin", "@shipped/fixture-records", record(candidate).identity.package)
	check("added definition uses originating package", "pub.a", record(candidate, "extra").identity.package)
	check("power field provenance", "@loose", record(candidate).fields.power.provider)
	check("label field provenance", "pub.a", record(candidate).fields.label.provider)
	check("nested field provenance", "pub.b", record(candidate).fields.nested.provider)
	check("contributors retained separately", 5, record(candidate).contributors.size())
	check("same basename in other directory distinct", 3, record(candidate, "other", "other/main.json").value.power)
	check("same local ID in different resources has distinct stable identity", false, record(candidate).identity.local == record(candidate, "sword", "other/main.json").identity.local)
	check("ordinary overrides have no blocking issues", [], candidate.issues)
	var first_ticket: int = candidate.ticket
	var first_resources: Dictionary = candidate.resources.duplicate(true)
	candidate = rebuild()
	check("repeated rebuild is clean and deterministic", first_resources, candidate.resources)
	check("obsolete candidate cannot reserve publication", false, definitions.reserve_commit(first_ticket, configuration).ok)
	check("no direct commit without menu reservation", false, definitions.commit(candidate.ticket).ok)
	var late_patch := Fixture.contribution("items/main.json", "patch", [{"id": "sword", "value": {"label": "must-not-leak"}}, {"id": "absent", "value": {"power": 100}}])
	write_b(late_patch)
	candidate = rebuild()
	check("late invalid patch blocks candidate", false, candidate.ok)
	check("early patch entry rolls back with entire file", "A", record(candidate).value.label)
	check("failure records exact source and reason", true, candidate.issues[0].source.contains("pub.b") and not candidate.issues[0].reason.is_empty())
	check("failed candidate publishes no definitions", {}, definitions.active())
	var obsolete_ticket: int = candidate.ticket
	var obsolete_token: String = candidate.issues[0].token
	configuration.select_profile(configuration.selected)
	check("configuration edit invalidates omission request", false, definitions.omit(obsolete_token, obsolete_ticket, configuration).ok)
	candidate = rebuild()
	var bad_ticket: int = candidate.ticket
	var bad_token: String = candidate.issues[0].token
	check("explicit omission admitted", true, definitions.omit(bad_token, bad_ticket, configuration).ok)
	candidate = rebuild()
	check("omitted contribution rebuilds and validates remainder", true, candidate.ok and candidate.omitted.size() == 1)
	check("omission does not disable package", ["pub.a", "pub.b"], candidate.plan.order)
	check("obsolete omission ticket rejected", false, definitions.omit(bad_token, bad_ticket, configuration).ok)
	write_b(Fixture.contribution("items/main.json", "add", [Fixture.record("must-not-leak", 8), Fixture.record("sword", 99)]))
	candidate = rebuild()
	check("add collision blocks whole contribution", false, candidate.ok)
	check("early addition rolled back", false, candidate.resources["fixture.records:items/main.json"].records.has("must-not-leak"))
	write_b(Fixture.contribution("items/main.json", "patch", [{"id": "missing", "value": {"power": 8}}]))
	check("patch cannot implicitly add", false, rebuild().ok)
	write_b(Fixture.contribution("items/main.json", "patch", [{"id": "sword", "value": {"power": null}}]))
	check("adapter rejects null in required numeric field", false, rebuild().ok)
	write_b(Fixture.contribution("items/main.json", "patch", [{"id": "sword", "value": {"nested": {"y": 5}}}]))
	check("no universal nested deep merge", false, rebuild().ok)
	write_b(Fixture.contribution("items/main.json", "replace", [Fixture.record("x", 1)], "fixture.limited"))
	check("unsupported adapter operation rejected", false, rebuild().ok)
	write_b(Fixture.contribution("items/main.json", "delete", []))
	check("undeclared deletion rejected", false, rebuild().ok)
	write_b(good_b, ["executable.luau"])
	check("executable capability not reinterpreted as data-only", "capability_unavailable", rebuild().kind)
	write_b(good_b, ["data.fixture"], ["missing.json"])
	candidate = rebuild()
	check("declared missing file distinct", "missing", candidate.issues[0].kind)
	check("actual unreadable source distinct", "unreadable", definitions.read_file(configuration.adapter, fixture.unreadable_root, "ARCH3D.BSA").kind)
	write_b(good_b, ["data.fixture"], ["data/patch.json", "DATA/PATCH.JSON"])
	candidate = rebuild()
	check("ambiguous normalized source paths block", false, candidate.ok)
	check("ambiguous paths cannot be omitted to pick a winner", false, candidate.issues[0].omittable)
	write_b(good_b, ["data.fixture"], ["../escape.json"])
	check("escaping package contribution rejected", false, rebuild().ok)
	write_b(Fixture.contribution("items/main.json", "patch", [{"id": "sword", "value": {"ref": "missing"}}]))
	candidate = rebuild()
	check("combined references block candidate", false, candidate.ok)
	check("reference failure identifies introducing contribution", true, candidate.issues[0].omittable and not candidate.issues[0].token.is_empty())
	definitions.omit(candidate.issues[0].token, candidate.ticket, configuration)
	check("reference omission rebuilds entire file", true, rebuild().ok)
	# A later contribution can require an addition: omitting that addition is not a bypass.
	put(root.path_join("A/data/a-add.json"), Fixture.contribution("items/main.json", "add", [Fixture.record("extra", 3), Fixture.record("sword", 99)]))
	write_b(Fixture.contribution("items/main.json", "patch", [{"id": "sword", "value": {"ref": "extra"}}]))
	candidate = rebuild()
	var add_issue: Dictionary = candidate.issues.filter(func(issue: Dictionary): return issue.omittable and issue.kind == "invalid")[0]
	definitions.omit(add_issue.token, candidate.ticket, configuration)
	candidate = rebuild()
	check("omission cannot bypass remaining required references", false, candidate.ok)
	put(root.path_join("A/data/a-add.json"), Fixture.contribution("items/main.json", "add", [Fixture.record("extra", 3)]))
	write_b(good_b)
	candidate = rebuild()
	check("fixed package repairs after explicit rescan", true, candidate.ok)
	# Suppression must keep dependent DATA contributions inactive, not just drop an edge.
	a.dependencies = [{"id": "pub.b", "optional": true}]
	a.content.append({"file": "data/integration.json", "integration": "pub.a:0"})
	put(root.path_join("A/mod.json"), a)
	put(root.path_join("A/data/integration.json"), "invalid JSON must never be parsed when integration is inactive")
	configuration.rescan()
	var cyclic: Dictionary = configuration.validate_dependencies()
	check("real optional integration cycle blocks DATA intake", false, rebuild().ok)
	configuration.suppress_optional("pub.a:0", cyclic.revision)
	candidate = rebuild()
	check("suppressed dependent DATA file remains inactive", true, candidate.ok and candidate.inactive.size() == 1)
	check("suppression retains unconditional package contributions", "A", record(candidate).value.label)
	check("suppressed hook admission remains closed at DATA boundary", false, configuration.integration_allowed("pub.a:0", "hooks", configuration.revision))
	a.dependencies = []
	a.content = ["data/z-patch.json", "data/a-add.json"]
	put(root.path_join("A/mod.json"), a)
	configuration.rescan()
	# Resource replacement preserves matching origin while replacing the record set.
	write_b(Fixture.contribution("items/main.json", "replace", [Fixture.record("sword", 20, "replacement")]))
	candidate = rebuild()
	check("whole replacement removes omitted records", false, candidate.resources["fixture.records:items/main.json"].records.has("extra"))
	check("whole replacement retains matching identity", "@shipped/fixture-records", record(candidate).identity.package)
	check("replacing provider tracked separately", "pub.b", record(candidate).fields.label.provider)
	write_b(good_b)
	# Package order is consumed afresh; dependency-preserving file order remains deterministic.
	var modified_a := Fixture.contribution("items/main.json", "patch", [{"id": "sword", "value": {"label": "first"}}, {"id": "sword", "value": {"label": "A"}}])
	put(root.path_join("A/data/z-patch.json"), modified_a)
	configuration.rescan()
	check("declared patch entry order retained", "A", record(rebuild()).value.label)
	# Restore nested/base fields required by later provenance expectations.
	put(root.path_join("A/data/z-patch.json"), Fixture.contribution("items/main.json", "patch", [{"id": "sword", "value": {"power": 2, "label": "A", "nested": {"x": 1}, "nullable": "set"}}]))
	configuration.rescan()
	candidate = rebuild()
	var revision_ticket: int = candidate.ticket
	configuration.edit("pub.b", "toggle")
	check("configuration edit makes candidate obsolete", false, definitions.reserve_commit(revision_ticket, configuration).ok)
	configuration.edit("pub.b", "toggle")
	check("clean rebuild does not retain earlier replacement or bad patch", true, rebuild().ok and record(rebuild(), "extra").identity.package == "pub.a")
	var readers: Array = controller.providers.classic.inventory()
	var classic_preparations: int = controller.providers.classic_preparations
	controller.check_content()
	check("pre-menu rebuild retains classic readers", readers, controller.providers.classic.inventory())
	check("pre-menu rebuild does not repeat classic preparation", classic_preparations, controller.providers.classic_preparations)
	# Loose files are intake-cached for the application, never live adopted.
	put(configuration.root.path_join("Overrides/z-loose.json"), Fixture.contribution("items/main.json", "patch", [{"id": "sword", "value": {"power": 11, "tags": ["next-launch"]}}]))
	check("external loose edit requires restart", 9, record(rebuild()).value.power)
	# Separate real CORE context verifies Save and Continue and all fallible entry steps.
	var other := Controller.new()
	var default_root: String = sandbox.path_join("shipped")
	other.providers.register_content_adapter(Schema.new(), default_root, ["a-main.json", "z-other.json"])
	other.start({"executable_dir": sandbox.path_join("save-case/executable"), "per_user_dir": sandbox.path_join("save-case/user")})
	other.settings.effective["startup/show_setup"] = true
	other.select_folder(fixture.classic_source)
	var other_mods = other.mods
	var simple := manifest("pub.simple")
	simple.content = ["add.json"]
	put(other_mods.root.path_join("Mods/simple/mod.json"), simple)
	put(other_mods.root.path_join("Mods/simple/add.json"), Fixture.contribution("items/main.json", "add", [Fixture.record("simple", 4)]))
	other_mods.rescan()
	other_mods.edit("pub.simple", "toggle")
	check("unsaved selection requires explicit continuation choice", "unsaved_profile", other.continue_to_menu().kind)
	var committed: Dictionary = other_mods.committed.duplicate(true)
	var pending: Dictionary = other_mods.pending()
	other.providers.definitions.faults.publish = true
	check("publication rejection blocks menu", false, other.continue_to_menu("save").ok)
	check("publication rejection preserves committed profile", committed, other_mods.committed)
	check("publication rejection preserves pending profile", pending, other_mods.pending())
	check("publication failure cannot lock", false, other_mods.locked)
	other.providers.definitions.faults.clear()
	other.providers.faults.menu = true
	check("menu failure remains recovery", "menu_recovery", other.continue_to_menu("save").route)
	check("menu failure publishes no definitions", {}, other.providers.definitions.active())
	check("menu failure advances no successful history", "", other_mods.committed.last_successful)
	other.providers.faults.clear()
	other.storage.adapter.faults.mod_profiles_publish = true
	check("profile persistence failure rejects entry", false, other.continue_to_menu("save").ok)
	check("failed entry persistence retains committed bytes/state", committed, other_mods.committed)
	check("failed entry persistence leaves pending edits", pending, other_mods.pending())
	check("failed entry persistence publishes nothing", {}, other.providers.definitions.active())
	other.storage.adapter.faults.clear()
	var callback_results: Array = []
	other.providers.before_menu = func():
		callback_results.append(other_mods.edit("pub.simple", "toggle").ok)
		callback_results.append(other.providers.definitions.prepare(other_mods).get("kind"))
		callback_results.append(other.continue_to_menu("run").get("kind"))
	check("Save and Continue enters actual menu", "main_menu", other.continue_to_menu("save").route)
	check("menu commit reserves against reentrancy", [false, "busy", "busy"], callback_results)
	check("Save and Continue persists enabled edits", true, other_mods.committed.profiles.default.entries[0].enabled)
	check("history advances only on actual successful entry", "default", other_mods.committed.last_successful)
	check("successful entry locks MOD", true, other_mods.locked)
	check("successful entry publishes DATA", true, other.providers.definitions.query("fixture.records", "items/main.json", "simple").ok)
	other.providers.dispose()
	other.logger.stop("Disposable save-entry fixture complete")
	other.storage.adapter.release()
	# Main fixture exercises normal rendered omission, choices and live title boundary.
	write_b(late_patch)
	controller.check_content()
	if DisplayServer.get_name() != "headless":
		await capture_publication(shell, "publication-rejection")
		var issue: Dictionary = controller.prepared_content.issues[0]
		check("UI explicitly omits rejected contribution", true, await click(shell, "Omit contribution " + issue.token.left(8) + " for this run"))
		check("UI omission revalidates", true, controller.prepared_content.ok)
	else:
		candidate = controller.prepared_content
		definitions.omit(candidate.issues[0].token, candidate.ticket, configuration)
		controller.check_content()
	write_b(good_b)
	controller.check_content()
	check("Continue validates without implicitly saving", "unsaved_profile", controller.continue_to_menu().kind)
	committed = configuration.committed.duplicate(true)
	if DisplayServer.get_name() != "headless":
		await capture_publication(shell, "publication-unsaved")
		check("UI chooses Continue for This Run", true, await click(shell, "Continue for This Run"))
		await capture_publication(shell, "publication-main-menu")
	else:
		controller.continue_to_menu("run")
	check("real MOD plus DATA publication enters actual menu", "main_menu", controller.route)
	check("run-only continuation preserves saved entries", committed.profiles, configuration.committed.profiles)
	check("actual published loose precedence", 9, definitions.query("fixture.records", "items/main.json", "sword").record.value.power)
	check("active plan locked", true, configuration.locked and configuration.selection().data_ready)
	check("locked selection rejects enable edits", false, configuration.edit("pub.a", "toggle").ok)
	check("locked selection rejects rescan", false, configuration.rescan().ok)
	check("locked selection rejects profile changes", false, configuration.manage("create", "Forbidden").ok)
	check("locked selection rejects saving pending run edits", false, configuration.save_profile().ok)
	check("locked DATA rejects rebuild", "locked", rebuild().kind)
	var active: Dictionary = definitions.active()
	active.resources.clear()
	check("consumers receive read-only copies", true, definitions.query("fixture.records", "items/main.json", "sword").ok)
	check("missing published definition is distinct", "missing", definitions.query("fixture.records", "missing/main.json", "sword").kind)
	var locked_plan: Dictionary = configuration.validate_dependencies()
	var identity: Dictionary = definitions.query("fixture.records", "items/main.json", "sword").record.identity
	var lifecycle = shell.session_shell.core
	lifecycle.startup_route_changed("main_menu")
	lifecycle.provider = preload("res://tests/controlled_calendar_entry.gd").new()
	lifecycle.provider.core = lifecycle
	for index in 3:
		var mode := "load" if index == 2 else "new"
		var entered: Dictionary = lifecycle.request({"id": "publication-character-%d" % index, "mode": mode, "origin": "", "selection": {"fixture": index}})
		check("controlled CORE %s entry %d" % [mode, index], "Succeeded", entered.get("outcome", entered.get("kind")))
		# The composed TIME owner now requires its exact settled payload on load.
		var capture_hold: int = lifecycle.gates.acquire("publication-clock-capture",lifecycle.snapshot().session,["simulation"])
		lifecycle.provider.restored = lifecycle.calendar.capture_snapshot().state
		lifecycle.gates.release(capture_hold,"publication-clock-capture")
		lifecycle.request({"id": "publication-return-%d" % index, "mode": "return", "origin": lifecycle.snapshot().session})
		if lifecycle.snapshot().phase == "confirmation":
			lifecycle.confirm(lifecycle.ticket(), true)
		check("published definition identity retained %d" % index, identity, definitions.query("fixture.records", "items/main.json", "sword").record.identity)
		check("published plan retained across character/title %d" % index, locked_plan, configuration.validate_dependencies())
		check("classic reader identity retained across character/title %d" % index, readers, controller.providers.classic.inventory())
	controller.open_setup()
	controller.check_content()
	check("title setup cannot unlock publication", true, configuration.locked and definitions.active().ready)
	controller.cancel_setup()
	check("return from locked setup reaches title", "main_menu", controller.route)
	check("no SAVE compatibility readiness invented", true, not controller.published.has("save_compatible"))
	var ok := true
	for item: Dictionary in checks:
		ok = ok and item.expected == item.actual
	return {"ok": ok, "count": checks.size(), "checks": checks, "engine": Engine.get_version_info(), "display": DisplayServer.get_name(),
		"fixture": fixture.fixture, "inputs": fixture.inputs, "source": fixture.classic_source, "publication": definitions.active(),
		"downstream": "Real CORE/MOD/DATA publication and real classic readers; bounded fixture schemas only; CHAR/WORLD preparation controlled, SAVE/executable/domain integrations unavailable."}
