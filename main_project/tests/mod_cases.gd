extends RefCounted
const Configuration = preload("res://scripts/mod/mod_configuration.gd")
const Library = preload("res://scripts/mod/package_library.gd")
const Storage = preload("res://scripts/startup/storage_owner.gd")
var checks: Array[Dictionary] = []
var sandbox := ""

func check(id: String, expected: Variant, actual: Variant) -> void:
	if expected is Dictionary or expected is Array:
		expected = JSON.stringify(expected)
		actual = JSON.stringify(actual)
	checks.append({"scenario": id, "expected": expected, "actual": actual})

func write(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()

func manifest(id: String, version := "1.0.0") -> Dictionary:
	return {"manifest_version": 1, "id": id, "name": "Fixture " + id, "version": version}

func folder(path: String, id: String, version := "1.0.0") -> void:
	write(path.path_join("mod.json"), JSON.stringify(manifest(id, version)))

func archive(path: String, entries: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var zip := ZIPPacker.new()
	zip.open(path)
	for name: String in entries:
		zip.start_file(name)
		zip.write_file(str(entries[name]).to_utf8_buffer())
		zip.close_file()
	zip.close()

func contains_reason(result: Dictionary, text: String) -> bool:
	for diagnostic: Dictionary in result.get("diagnostics", []):
		if str(diagnostic.reason).to_lower().contains(text.to_lower()):
			return true
	return false

func click(shell: Control, text: String) -> bool:
	var button := find_button(shell.panel, text)
	if button == null:
		return false
	shell.panel.get_parent().ensure_control_visible(button)
	button.grab_focus()
	await shell.get_tree().process_frame
	var press := InputEventKey.new()
	press.keycode = KEY_ENTER
	press.pressed = true
	Input.parse_input_event(press)
	await shell.get_tree().process_frame
	var release := InputEventKey.new()
	release.keycode = KEY_ENTER
	release.pressed = false
	Input.parse_input_event(release)
	await shell.get_tree().process_frame
	return true

func find_button(node: Node, text: String) -> Button:
	for child in node.get_children():
		if child is Button and child.text == text:
			return child
		var found := find_button(child, text)
		if found != null:
			return found
	return null

func capture(shell: Control, name: String) -> void:
	await shell.get_tree().process_frame
	var target := "Mods · Discovery" if name in ["mods-selection", "mods-profile"] else ("Choice required:" if name == "mods-duplicate" else "Duplicate decision recorded:")
	if name == "mods-root-recovery":
		target = shell.controller.mods.discovery.path
	for child in shell.panel.get_children():
		if child is Label and child.text.begins_with(target):
			shell.panel.get_parent().scroll_vertical = int(child.position.y)
			break
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := shell.get_viewport().get_texture().get_image()
	check(name + " frame available", false, image.is_empty())
	image.save_png(sandbox.path_join(name + ".png"))

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller = shell.controller
	var owner = controller.mods
	var adapter = controller.storage.adapter
	var root: String = owner.root.path_join("Mods")
	check("normal CORE root used", controller.storage.context.root, owner.root)
	check("Default ready to use", "Default", owner.pending().name)
	check("no successful history at startup", "", owner.committed.last_successful)
	check("group junction excluded", false, owner.grouped().has("outside"))
	check("installed package junction rejected", false, owner.grouped().has("linked-package"))
	check("installed hard link rejected", false, owner.grouped().has("hardlinked"))
	check("link diagnostic retained", true, contains_reason(owner.discovery, "link"))
	var a := root.path_join("category/author/A")
	folder(a, "fixture.a")
	write(a.path_join("Data/hello.txt"), "package A")
	var meta := manifest("fixture.b")
	meta.dependencies = [{"id": "fixture.a", "optional": false, "order": "provider_first", "min": "1.0.0", "max": "2.0.0"}]
	meta.capabilities = ["data.fixture", "executable.luau"]
	archive(root.path_join("author/B.zip"), {"mod.json": JSON.stringify(meta), "Data/hello.txt": "package B"})
	write(root.path_join("invalid-boundary/mod.json"), "{invalid")
	folder(root.path_join("invalid-boundary/nested"), "must.not.discover")
	archive(root.path_join("wrapper.zip"), {"wrapper/mod.json": JSON.stringify(manifest("wrapped"))})
	archive(root.path_join("escape.zip"), {"mod.json": JSON.stringify(manifest("escape")), "../outside.txt": "escape"})
	archive(root.path_join("ambiguous.zip"), {"mod.json": JSON.stringify(manifest("ambiguous")), "Data/x.txt": "x", "data/X.txt": "y"})
	write(root.path_join("unsupported.dfmod"), "unsupported")
	write(root.path_join("broken.zip"), "not zip")
	var scan: Dictionary = owner.rescan()
	write(sandbox.path_join("discovery-checkpoint.json"), JSON.stringify(scan, "\t"))
	check("real ZIP and grouped folder discovered", 2, owner.available().size())
	check("invalid manifest establishes boundary", false, owner.grouped().has("must.not.discover"))
	check("wrapper location diagnostic", true, contains_reason(scan, "ZIP root"))
	check("escape path rejected", true, contains_reason(scan, "Escaping"))
	check("normalized ZIP ambiguity rejected", true, contains_reason(scan, "Ambiguous"))
	check("unsupported format reported", true, contains_reason(scan, "Unsupported package"))
	check("malformed archive reported", true, contains_reason(scan, "Malformed"))
	check("dependency metadata retained", meta.dependencies, owner.available()["fixture.b"].dependencies)
	check("executable capability retained without execution", meta.capabilities, owner.available()["fixture.b"].capabilities)
	check("folder source provenance", a, owner.available()["fixture.a"].source.path)
	check("ZIP format provenance", "zip", owner.available()["fixture.b"].format)
	check("new IDs disabled", [false, false], [owner.rows()[0].enabled, owner.rows()[1].enabled])
	check("folder bounded access case normalization", "package A", owner.read_package_file("fixture.a", "data/HELLO.txt").bytes.get_string_from_utf8())
	check("ZIP bounded access", "package B", owner.read_package_file("fixture.b", "data/hello.txt").bytes.get_string_from_utf8())
	check("escaping package reference rejected", false, owner.read_package_file("fixture.a", "../mod.json").ok)
	check("absolute package reference rejected", false, owner.read_package_file("fixture.b", "C:/secret").ok)
	check("missing package file is failure", false, owner.read_package_file("fixture.b", "missing.txt").ok)
	var locked: Dictionary = Library.new(adapter).scan(sandbox.path_join("locked-mods"))
	check("actual Windows unreadable ZIP reported", true, contains_reason(locked, "read"))
	var invalids := [{}, {"manifest_version": "1", "id": "x", "name": "X", "version": "1.0.0"}, manifest("UPPER"), manifest("bad/version"), manifest("x", "1.0"), {"manifest_version": 1, "id": "x", "name": "", "version": "1.0.0"}, {"manifest_version": 2, "id": "x", "name": "X", "version": "1.0.0"}]
	for index in invalids.size():
		check("manifest rejection %d" % index, false, Library.validate_manifest(invalids[index]).is_empty())
		var invalid_root := sandbox.path_join("invalid-fields-%d" % index)
		write(invalid_root.path_join("folder/mod.json"), JSON.stringify(invalids[index]))
		archive(invalid_root.path_join("archive.zip"), {"mod.json": JSON.stringify(invalids[index])})
		var rejected: Dictionary = Library.new(adapter).scan(invalid_root)
		check("both package forms reject fields %d" % index, true, rejected.candidates.is_empty() and rejected.diagnostics.size() == 2)
	var link_zip := sandbox.path_join("zip-link/symlink.zip")
	archive(link_zip, {"mod.json": JSON.stringify(manifest("zip.link")), "link": "../outside"})
	var link_bytes := FileAccess.get_file_as_bytes(link_zip)
	for index in range(link_bytes.size() - 46):
		if link_bytes.decode_u32(index) == 0x02014b50:
			link_bytes.encode_u32(index + 38, 0xa1ff0000)
	var link_file := FileAccess.open(link_zip, FileAccess.WRITE)
	link_file.store_buffer(link_bytes)
	link_file.close()
	check("ZIP symlink metadata rejected", true, contains_reason(Library.new(adapter).scan(link_zip.get_base_dir()), "link rejected"))
	var encoding_root := sandbox.path_join("encoding")
	var encoding_path := encoding_root.path_join("folder/mod.json")
	write(encoding_path, String.chr(0xfeff) + JSON.stringify(manifest("bom")))
	archive(encoding_root.path_join("bom.zip"), {"mod.json": String.chr(0xfeff) + JSON.stringify(manifest("bom"))})
	var encoding_scan: Dictionary = Library.new(adapter).scan(encoding_root)
	check("BOM rejected in both formats", true, encoding_scan.candidates.is_empty() and encoding_scan.diagnostics.size() == 2)
	var invalid_file := FileAccess.open(encoding_path, FileAccess.WRITE)
	invalid_file.store_buffer(PackedByteArray([255, 254]))
	invalid_file.close()
	check("invalid UTF-8 rejected", true, contains_reason(Library.new(adapter).scan(encoding_root), "UTF-8"))
	var oversized := PackedByteArray()
	oversized.resize(Library.MANIFEST_LIMIT + 1)
	invalid_file = FileAccess.open(encoding_path, FileAccess.WRITE)
	invalid_file.store_buffer(oversized)
	invalid_file.close()
	check("oversized manifest rejected", true, contains_reason(Library.new(adapter).scan(encoding_root), "1 MiB"))
	owner.edit("fixture.a", "toggle")
	owner.edit("fixture.b", "toggle")
	owner.edit("fixture.b", "up")
	check("pending edits separate from saved", [], owner.committed.profiles.default.entries)
	check("save unfinished profile", true, owner.save_profile().ok)
	check("preferred positions saved by ID", "fixture.b", owner.committed.profiles.default.entries[0].id)
	var duplicate := root.path_join("backup/A-copy")
	folder(duplicate, "fixture.a")
	owner.rescan()
	check("duplicate requires explicit choice", ["fixture.a"], owner.unresolved())
	check("duplicate unresolved cannot read", false, owner.read_package_file("fixture.a", "mod.json").ok)
	var set: Array = owner.fingerprint(owner.grouped()["fixture.a"])
	check("explicit duplicate copy choice persisted", true, owner.choose_copy("fixture.a", a, set).ok)
	check("one chosen candidate", a, owner.available()["fixture.a"].path)
	owner.rescan()
	check("equivalent rescan preserves choice", [], owner.unresolved())
	var reopened = Configuration.new(adapter, owner.root)
	check("restore committed profiles", true, reopened.initialize().ok)
	reopened.rescan()
	check("equivalent new owner preserves duplicate choice", [], reopened.unresolved())
	check("profile save does not update history", "", reopened.committed.last_successful)
	check("explicit duplicate skip", true, owner.choose_copy("fixture.a", "", set).ok)
	check("duplicate skip removes eligible ID", false, owner.available().has("fixture.a"))
	var skipped = Configuration.new(adapter, owner.root)
	skipped.initialize()
	skipped.rescan()
	check("duplicate skip persists across reload", false, skipped.available().has("fixture.a"))
	folder(duplicate, "fixture.a", "1.1.0")
	owner.rescan()
	check("version change reprompts", ["fixture.a"], owner.unresolved())
	check("stale copy request rejected", false, owner.choose_copy("fixture.a", a, set).ok)
	DirAccess.remove_absolute(duplicate.path_join("mod.json"))
	owner.rescan()
	check("unique remainder ordinary selection", true, owner.available().has("fixture.a"))
	DirAccess.remove_absolute(root.path_join("author/B.zip"))
	owner.rescan()
	check("missing enabled ID retains position", "fixture.b", owner.rows()[0].id)
	check("missing enabled ID visible unavailable", false, owner.rows()[0].available)
	var saved_before: Dictionary = owner.committed.duplicate(true)
	owner.edit("fixture.b", "skip")
	check("explicit run skip distinct from profile", true, owner.rows()[0].skipped and owner.committed == saved_before)
	owner.edit("fixture.b", "restore")
	check("cancel run skip", false, owner.rows()[0].skipped)
	owner.edit("fixture.b", "remove")
	check("permanent removal remains pending until save", true, owner.dirty() and owner.committed == saved_before)
	var disk := FileAccess.get_file_as_string(owner.path)
	adapter.faults.mod_profiles_publish = true
	check("failed save returns failure", false, owner.save_profile().ok)
	check("failed save preserves committed profile", saved_before, owner.committed)
	check("failed save preserves pending edits", true, owner.dirty())
	check("failed save preserves committed bytes", disk, FileAccess.get_file_as_string(owner.path))
	adapter.faults.clear()
	check("retry save succeeds", true, owner.save_profile().ok)
	var next_before: Dictionary = owner.committed.duplicate(true)
	adapter.faults.mod_profiles_publish_stage = true
	check("profile creation stage failure", false, owner.manage("create", "Failed Creation").ok)
	check("failed creation preserves selection and store", next_before, owner.committed)
	adapter.faults.clear()
	check("create profile", true, owner.manage("create", "Campaign").ok)
	var custom: String = owner.selected
	check("created profile starts empty", [], owner.pending().entries)
	check("rename profile", true, owner.manage("rename", "Campaign Two").ok)
	owner.edit("fixture.a", "toggle")
	owner.select_profile("default")
	owner.select_profile(custom)
	check("profile switching retains draft", true, owner.dirty())
	check("duplicate pending profile", true, owner.manage("duplicate", "Copy").ok)
	check("duplicate retains pending enablement", true, owner.pending().entries[0].enabled)
	check("delete requires confirmation", "confirmation_required", owner.manage("delete").kind)
	check("canceled delete preserves profile", true, owner.committed.profiles.has(owner.selected))
	check("confirmed delete succeeds", true, owner.manage("delete", "", true).ok)
	check("Default remains fallback", "default", owner.selected)
	check("Default cannot be deleted", false, owner.manage("delete", "", true).ok)
	var historical: Dictionary = owner.committed.duplicate(true)
	historical.last_successful = custom
	write(owner.path, JSON.stringify(historical))
	var history = Configuration.new(adapter, owner.root)
	history.initialize()
	check("existing successful history preselects profile", custom, history.selected)
	historical.last_successful = "missing-profile"
	write(owner.path, JSON.stringify(historical))
	history = Configuration.new(adapter, owner.root)
	history.initialize()
	check("unavailable history falls back to Default", "default", history.selected)
	write(owner.path, JSON.stringify(owner.committed))
	var history_before: String = owner.committed.last_successful
	controller.select_folder(fixture.classic_source)
	check("real DATA still reaches unavailable downstream gate", "package_recovery", controller.route)
	check("no main-menu readiness fabricated", false, controller.menu_entered)
	check("Continue rejected before real publication", false, controller.continue_to_menu().get("ok", true))
	check("unsuccessful entry cannot advance profile history", history_before, owner.committed.last_successful)
	check("dependency and DATA readiness remain false", [false, false], [owner.selection().dependency_ready, owner.selection().data_ready])
	# CORE storage modes use separate libraries and profile files, each under a lease.
	for mode: String in ["standard", "portable", "fallback"]:
		var base := sandbox.path_join("mode-" + mode)
		var executable := base.path_join("executable")
		if mode != "standard":
			write(executable.path_join("Portable.txt"), "")
		var storage = Storage.new()
		var launch := {"executable_dir": executable, "per_user_dir": base.path_join("user")}
		if mode == "fallback":
			storage.adapter.faults[executable.path_join("PortableAppdata")] = true
			check("portable failure before explicit fallback", false, storage.resolve(launch).ok)
		var resolved: Dictionary = storage.resolve(launch, mode == "fallback")
		check(mode + " CORE mode", {"standard": "standard", "portable": "portable", "fallback": "standard_fallback"}[mode], resolved.context.mode)
		var separate = Configuration.new(storage.adapter, storage.context.root)
		separate.initialize()
		check(mode + " independent Default", [], separate.pending().entries)
		write(separate.root.path_join("Mods"), "root is file")
		var failed: Dictionary = separate.rescan()
		check(mode + " truthful root failure", "root_unreadable", failed.kind)
		check(mode + " all root recovery choices", 3, failed.choices.size())
		if mode == "standard" and DisplayServer.get_name() != "headless":
			# Bind the stock view to this separately CORE-selected, leased fixture.
			controller.mods = separate
			shell.render()
			check("normal UI failed-root Retry", true, await click(shell, "Retry Mods"))
			await capture(shell, "mods-root-recovery")
			check("normal UI explicit run-empty recovery", true, await click(shell, "Continue without mods for this run"))
			controller.mods = owner
		check(mode + " explicit run empty choice", true, separate.continue_without_mods().ok)
		check(mode + " run choice does not validate downstream", false, separate.selection().data_ready)
		DirAccess.remove_absolute(separate.root.path_join("Mods"))
		check(mode + " missing Mods is empty", true, separate.rescan().ok and separate.available().is_empty())
		check(mode + " retry clears run omission", false, separate.without_mods)
		storage.adapter.release()
	# Broken profile bytes and abandoned stages must not replace committed state.
	write(owner.path + ".staged", "interrupted publication")
	var restart = Configuration.new(adapter, owner.root)
	check("interrupted stage ignored on restore", true, restart.initialize().ok)
	write(owner.path, "{broken")
	var damaged = Configuration.new(adapter, owner.root)
	check("invalid profile store rejected", false, damaged.initialize().ok)
	check("invalid store preserved", "{broken", FileAccess.get_file_as_string(owner.path))
	write(owner.path, JSON.stringify(owner.committed))
	check("repaired profile store retries", true, damaged.initialize().ok)
	controller.set_route("package_recovery", {"ok": false, "reason": "Dependency planning and DATA publication await later accepted increments."})
	owner.status = {}
	shell.render()
	if DisplayServer.get_name() != "headless":
		check("normal UI Rescan action", true, await click(shell, "Rescan Mods"))
		await capture(shell, "mods-selection")
		for action: String in ["Create", "Rename", "Duplicate"]:
			for child in shell.panel.get_children():
				if child is LineEdit:
					child.text = "Rendered " + action
			check("normal UI " + action + " profile", true, await click(shell, action + " Profile"))
		check("normal UI enable package", true, await click(shell, "Enable · fixture.a"))
		check("normal UI save profile", true, await click(shell, "Save Profile"))
		await capture(shell, "mods-profile")
		await click(shell, "Delete Profile…")
		var dialog: ConfirmationDialog
		for child in shell.get_children():
			if child is ConfirmationDialog:
				dialog = child
		var selected_before: String = owner.selected
		check("normal UI delete confirmation visible", true, is_instance_valid(dialog) and dialog.visible)
		dialog.canceled.emit()
		check("normal UI canceled deletion preserves profile", selected_before, owner.selected)
		await shell.get_tree().process_frame
		await click(shell, "Delete Profile…")
		for child in shell.get_children():
			if child is ConfirmationDialog:
				dialog = child
		dialog.confirmed.emit()
		check("normal UI confirmed deletion returns Default", "default", owner.selected)
		folder(duplicate, "fixture.a", "1.2.0")
		await click(shell, "Rescan Mods")
		await capture(shell, "mods-duplicate")
		check("normal UI duplicate skip", true, await click(shell, "Skip duplicate ID fixture.a"))
		await capture(shell, "mods-skip")
	# Leave deliberately unsaved edits/omissions for an independent fresh process.
	folder(root.path_join("Fresh"), "fixture.fresh")
	owner.edit("fixture.a", "toggle")
	owner.edit("fixture.a", "skip")
	var ok := true
	for item: Dictionary in checks:
		ok = ok and item.expected == item.actual
	return {"ok": ok, "checks": checks, "count": checks.size(), "engine": Engine.get_version_info(), "display": DisplayServer.get_name(),
		"fixture": fixture.fixture, "inputs": fixture.inputs, "source": fixture.classic_source, "packages": owner.discovery,
		"profile": owner.selection(), "downstream": "Real CORE storage, MOD and classic DATA readers; dependency planning, definition publication and SAVE compatibility unavailable. No controlled success provider."}
