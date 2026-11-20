extends RefCounted
const Access = preload("res://scripts/data/classic_access.gd")
const Provider = preload("res://scripts/startup/provider_boundary.gd")
const ControlledPackages = preload("res://tests/classic_startup_provider.gd")
const FILES = ["ARCH3D.BSA", "BLOCKS.BSA", "MAPS.BSA", "DAGGER.SND"]
var checks: Array[Dictionary] = []
var records: Array = []
var sandbox := ""

func check(id: String, expected: Variant, actual: Variant) -> void:
	if expected is Array or expected is Dictionary:
		expected = JSON.stringify(expected)
		actual = JSON.stringify(actual)
	checks.append({"scenario": id, "expected": expected, "actual": actual})

func write_bytes(path: String, bytes: PackedByteArray) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()

func small_archive(path: String, count := 1, named := false) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_16(count)
	file.store_16(0x100 if named else 0x200)
	for index in count:
		file.store_8(40 + index)
	for index in count:
		if named:
			var name := ("TEST%d" % index).to_ascii_buffer()
			name.resize(14)
			file.store_buffer(name)
		else:
			file.store_32(1000 + index)
		file.store_32(1)
	file.close()

func fixture_root(id: String, count := 1) -> String:
	var path := sandbox.path_join(id).path_join("ARENA2")
	DirAccess.make_dir_recursive_absolute(path)
	for name: String in FILES:
		small_archive(path.path_join(name), count)
	return path

func rendered_capture(shell: Control, name: String) -> void:
	shell.render()
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := shell.get_viewport().get_texture().get_image()
	check(name + " rendered frame", false, image.is_empty())
	image.save_png(sandbox.path_join(name + ".png"))

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var source: String = fixture.classic_source
	var access := Access.new()
	check("premature access", "before_readiness", access.read_record("ARCH3D.BSA", 0).kind)
	var direct := access.resolve(source)
	var parent := access.resolve(source.get_base_dir())
	check("real direct resolution", true, direct.ok)
	check("immediate parent resolves same source", str(direct.get("source")).to_lower(), str(parent.get("source")).to_lower())
	var started := Time.get_ticks_usec()
	var valid := access.validate(source)
	var validation_usec := Time.get_ticks_usec() - started
	check("real manifest validation", true, valid.ok)
	check("validation is not ready", false, access.ready())
	var prepared := access.initialize_readers(valid)
	check("real initialization", true, prepared.ok)
	check("initialized access remains unpublished", "before_readiness", access.read_record("ARCH3D.BSA", 0).kind)
	check("all required readers staged", 4, access.prepared_count())
	check("publish complete reader set", true, access.activate(prepared).ok)
	check("real reader readiness", true, access.ready())
	for item: Dictionary in access.inventory():
		var key: Variant = {"ordinal": 0}
		var read: Dictionary = access.read_record(str(item.source).get_file(), key)
		check("real raw record " + str(item.source).get_file(), true, read.ok)
		check("read-only mode " + str(item.source).get_file(), "READ", item.open_mode)
		records.append({"source": item.source, "record": key, "identity": read.get("identity"), "offset": read.get("offset"), "size": read.get("bytes", PackedByteArray()).size(),
			"sha256": payload_hash(read.get("bytes", PackedByteArray())), "directory_type": item.directory_type, "count": item.count})
	check("record absent", "record_not_found", access.read_record("ARCH3D.BSA", 4294967295).kind)
	check("unregistered source differs", "source_unavailable", access.read_record("OTHER.BSA", 1).kind)
	check("unsupported identity differs", "malformed_or_unsupported", access.read_record("ARCH3D.BSA", []).kind)
	var ids := access.inventory()
	check("same-source prepare", true, access.prepare(source).ok)
	check("same-source reader reuse", ids, access.inventory())
	check("Windows case-alias prepare", true, access.prepare(source.to_upper()).ok)
	check("Windows case-alias reader reuse", ids, access.inventory())
	var unavailable := access.validate(sandbox.path_join("absent"))
	check("unavailable root fails", false, unavailable.ok)
	check("unavailable root reported once", 1, unavailable.failures.size())
	var root_file := sandbox.path_join("root-is-file")
	write_bytes(root_file, PackedByteArray([1]))
	check("root access is truthful", "source_unavailable", access.validate(root_file).failures[0].kind)
	var nested := fixture_root("nested/child")
	check("no recursive discovery", false, access.resolve(nested.get_base_dir().get_base_dir()).ok)
	var extra := fixture_root("compatible", 2)
	write_bytes(extra.path_join("unrelated.extra"), PackedByteArray([1, 2, 3]))
	check("modified population and extra files accepted", true, access.validate(extra).ok)
	check("zero population structurally accepted", true, access.validate(fixture_root("zero-population", 0)).ok)
	check("optional video absence has no warnings", false, access.validate(extra).has("warnings"))
	var named := fixture_root("named")
	small_archive(named.path_join("BLOCKS.BSA"), 2, true)
	# Duplicate IDs are structurally valid, including in the supplied real source.
	var duplicate := FileAccess.open(named.path_join("DAGGER.SND"), FileAccess.WRITE)
	duplicate.store_buffer(PackedByteArray([2, 0, 0, 2, 40, 41, 232, 3, 0, 0, 1, 0, 0, 0, 232, 3, 0, 0, 1, 0, 0, 0]))
	duplicate.close()
	var named_access := Access.new()
	var named_prepared := named_access.prepare(named)
	check("named directory accepted", true, named_prepared.ok)
	named_access.activate(named_prepared)
	check("named identity raw read", true, named_access.read_record("BLOCKS.BSA", "test0").ok)
	check("duplicate ID is an explicit ambiguous query", "malformed_or_unsupported", named_access.read_record("DAGGER.SND", 1000).kind)
	named_access.dispose()
	var broken := fixture_root("multiple")
	DirAccess.remove_absolute(broken.path_join("ARCH3D.BSA"))
	write_bytes(broken.path_join("BLOCKS.BSA"), PackedByteArray())
	write_bytes(broken.path_join("MAPS.BSA"), PackedByteArray([1, 0]))
	var bad := access.validate(broken)
	check("multiple failures aggregated", 3, bad.failures.size())
	check("missing required source", "source_unavailable", bad.failures[0].kind)
	check("empty required source", true, str(bad.failures[1].reason).contains("empty"))
	check("truncated header", true, str(bad.failures[2].reason).contains("Truncated"))
	check("manifest context retained", "MAPS.BSA", bad.failures[2].manifest_entry.file)
	var unsupported := fixture_root("unsupported")
	write_bytes(unsupported.path_join("BLOCKS.BSA"), PackedByteArray([0, 0, 123, 0]))
	check("unsupported directory type", "malformed_or_unsupported", access.validate(unsupported).failures[0].kind)
	write_bytes(unsupported.path_join("BLOCKS.BSA"), PackedByteArray([1, 0, 0, 2]))
	check("truncated directory index", false, access.validate(unsupported).ok)
	var bounds := fixture_root("bounds")
	write_bytes(bounds.path_join("MAPS.BSA"), PackedByteArray([1, 0, 0, 2, 42, 232, 3, 0, 0, 255, 255, 255, 127]))
	var bound_failure := access.validate(bounds)
	check("out-of-bounds index fails", false, bound_failure.ok)
	check("out-of-bounds source context", bounds.path_join("MAPS.BSA"), bound_failure.failures[0].source)
	check("out-of-bounds record context", 1000, bound_failure.failures[0].record)
	var retry := Access.new()
	for attempt in 3:
		check("failed retry %d" % attempt, false, retry.prepare(bounds).ok)
		check("failed retry cleanup %d" % attempt, 0, retry.prepared_count())
		check("failed retry readiness %d" % attempt, false, retry.ready())
	var race := fixture_root("validation-initialization")
	var race_valid := retry.validate(race)
	write_bytes(race.path_join("DAGGER.SND"), PackedByteArray([1]))
	check("initialization rechecks validated source", false, retry.initialize_readers(race_valid).ok)
	check("partial initialization cleaned", 0, retry.prepared_count())
	check("partial initialization unavailable", "before_readiness", retry.read_record("ARCH3D.BSA", 1000).kind)
	small_archive(race.path_join("DAGGER.SND"))
	var next := retry.prepare(race)
	check("valid retry after partial failure", true, next.ok)
	check("obsolete publication rejected", false, retry.activate(prepared).ok)
	check("valid retry activates", true, retry.activate(next).ok)
	check("read after retry", true, retry.read_record("MAPS.BSA", 1000).ok)
	# Mutate only disposable data after initialization, never the real installation.
	write_bytes(race.path_join("MAPS.BSA"), PackedByteArray([0]))
	check("later malformed source differs", "malformed_or_unsupported", retry.read_record("MAPS.BSA", 1000).kind)
	DirAccess.remove_absolute(race.path_join("ARCH3D.BSA"))
	check("later unavailable source differs", "source_unavailable", retry.read_record("ARCH3D.BSA", 1000).kind)
	retry.dispose()
	var undeclared := Access.new()
	undeclared.enable_capability("IMP-007-unavailable")
	check("enabled missing capability blocks", "capability_unavailable", undeclared.validate(source).failures[0].kind)
	check("unsupported decoder registration rejected", false, undeclared.register_adapter("woods", [{"file": "WOODS.WLD", "format": "invented"}]))
	var locked := access.validate(fixture.unreadable_root)
	check("Windows exclusive file lock fails read-only open", false, locked.ok)
	check("unreadable source category", "source_unavailable", locked.failures[0].kind)
	check("unreadable file context", true, str(locked.failures[0].source).ends_with("ARCH3D.BSA"))
	# Normal setup requests: real DATA, stock package failure first.
	var controller = shell.controller
	controller.providers = Provider.new()
	controller.check_content()
	var original: String = controller.settings.value(controller.settings.accepted, "startup/classic_path")
	controller.select_folder("")
	check("cancel selection preserves setting", original, controller.settings.value(controller.settings.accepted, "startup/classic_path"))
	if DisplayServer.get_name() != "headless":
		shell.render()
		shell.choose_folder()
		await shell.get_tree().process_frame
		shell.picker.dir_selected.emit(broken)
		shell.picker.hide()
	else:
		controller.select_folder(broken)
	check("invalid selection preserves setting", original, controller.settings.value(controller.settings.accepted, "startup/classic_path"))
	check("invalid selection route", "mandatory_setup", controller.route)
	if DisplayServer.get_name() != "headless":
		await rendered_capture(shell, "classic-invalid")
	var original_disk := FileAccess.get_file_as_string(controller.settings.path)
	controller.storage.adapter.faults["settings_stage"] = true
	controller.select_folder(source)
	controller.storage.adapter.faults.clear()
	check("initial publication failure preserves disk", original_disk, FileAccess.get_file_as_string(controller.settings.path))
	check("initial publication failure preserves accepted path and pending projection", true,
		controller.settings.value(controller.settings.accepted, "startup/classic_path") == original and controller.result.pending == controller.settings.pending())
	check("initial publication failure has no ready access", false, controller.providers.classic.ready())
	check("initial publication failure cleans prepared readers", 0, controller.providers.classic.prepared_count())
	controller.check_content()
	if DisplayServer.get_name() != "headless":
		# Exercise the real FileDialog signal and normal selection callback.
		shell.choose_folder()
		await shell.get_tree().process_frame
		check("normal setup folder picker visible", true, shell.picker.visible)
		shell.picker.dir_selected.emit(source)
		shell.picker.hide()
	else:
		controller.select_folder(source)
	check("real DATA reaches stock package gate", "package_recovery", controller.route)
	check("stock package provider remains unavailable", false, controller.result.ok)
	check("real DATA active despite unavailable packages", true, controller.providers.classic.ready())
	check("no menu readiness fabricated", false, controller.menu_entered)
	if DisplayServer.get_name() != "headless":
		await rendered_capture(shell, "classic-package-gate")
	controller.providers.dispose()
	controller.providers = ControlledPackages.new()
	controller.check_content()
	check("controlled package interface reaches menu", "main_menu", controller.route)
	var retained: Array = controller.providers.classic.inventory()
	var previous_disk := FileAccess.get_file_as_string(controller.settings.path)
	controller.storage.adapter.faults["settings_stage"] = true
	controller.select_folder(extra)
	controller.storage.adapter.faults.clear()
	check("failed settings publication preserves disk", previous_disk, FileAccess.get_file_as_string(controller.settings.path))
	check("failed settings publication preserves accepted path and pending projection", true,
		controller.settings.value(controller.settings.accepted, "startup/classic_path") == source and controller.result.pending == controller.settings.pending())
	check("failed selection preserves reader identity", retained, controller.providers.classic.inventory())
	controller.select_folder(extra)
	check("pending source persisted", extra, controller.settings.value(controller.settings.persisted, "startup/classic_path"))
	check("pending retains active source", source, controller.active_source)
	check("pending retains active readers", retained, controller.providers.classic.inventory())
	check("pending candidate disposed", 0, controller.providers.classic.prepared_count())
	controller.cancel_setup()
	check("pending cancel returns to menu", "main_menu", controller.route)
	# Delivered CORE lifecycle, with explicitly controlled CHAR/WORLD readiness.
	var lifecycle = shell.session_shell.core
	lifecycle.startup_route_changed("main_menu")
	lifecycle.provider = preload("res://tests/controlled_session_provider.gd").new()
	for number in 2:
		var entry: Dictionary = lifecycle.request({"id": "classic-character-%d" % number, "mode": "new", "origin": "", "selection": {"fixture": number}})
		check("controlled character entry %d" % number, "Succeeded", entry.get("outcome", entry.get("kind")))
		var scope: String = lifecycle.snapshot().session
		var returned: Dictionary = lifecycle.request({"id": "classic-return-%d" % number, "mode": "return", "origin": scope})
		if lifecycle.snapshot().phase == "confirmation":
			lifecycle.confirm(lifecycle.ticket(), true)
		check("reader identity across character/menu %d" % number, retained, controller.providers.classic.inventory())
		check("menu return session retired %d" % number, "", lifecycle.snapshot().session)
	var restarted := Access.new()
	var on_restart := restarted.prepare(extra)
	check("restart validates pending source", true, on_restart.ok)
	check("restart activates pending source", true, restarted.activate(on_restart).ok)
	restarted.dispose()
	access.dispose()
	check("application disposal releases ready access", false, access.ready())
	var ok := true
	for item: Dictionary in checks:
		ok = ok and item.expected == item.actual
	return {"ok": ok, "checks": checks, "count": checks.size(), "engine": Engine.get_version_info(), "display": DisplayServer.get_name(),
		"fixture": fixture.fixture, "selected_source": source, "records": records, "validation_usec": validation_usec,
		"validation": valid, "inputs": fixture.inputs, "downstream": "Stock IMP-005 rejection; controlled package and character results only for named interface cases"}

func payload_hash(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()
