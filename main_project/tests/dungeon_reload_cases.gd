extends "res://tests/dungeon_cases.gd"
## Fresh process rebuilds baseline geometry, not native SAVE or actor restoration.
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var controller: RefCounted = shell.controller
	var registry: RefCounted = controller.providers.definitions
	check("fresh remembered source available",true,controller.providers.classic.ready())
	check("fresh complete composition prepares",true,controller.prepared_content.get("ok",false))
	check("fresh actual menu publication",true,controller.continue_to_menu("run").ok)
	await shell.get_tree().process_frame
	shell.session_shell.synchronize_startup()
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/dungeon_source_observation.json"))
	var selected: Dictionary = Layout.lookup(registry,"packs/classic#"+source.location)
	check("fresh baseline uses shipped annotation","@shipped/layout-inputs-v1",selected.record.winner.provider)
	check("fresh baseline has connection declarations",true,selected.record.value.data.has("assembly"))
	var core: RefCounted = shell.session_shell.core
	core.provider = preload("res://tests/controlled_session_provider.gd").new()
	check("fresh controlled CORE session","Succeeded",core.request({"id":"fresh-assembly-session","mode":"new","origin":"","selection":{}}).kind)
	var owner: Node = shell.session_shell.dungeon_assembly
	var result: Dictionary = await assemble(owner,request(owner,"packs/classic#"+source.location))
	check("fresh baseline real assembly",true,result.ok)
	if not result.ok:
		observations.failure = result
		return terminal(fixture)
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(str(fixture.sandbox).path_join("assembly-restart-expectations.json")))
	check("fresh layout/resource version retained",expected.layout_version,result.layout_version)
	check("fresh original placed block count",8,result.occurrences.size())
	check("fresh required source connection count",14,result.connections.size())
	check("fresh source doors are retained",0,result.suppressed.size())
	check("fresh reconstruction is not native SAVE",false,result.save_compatible)
	check("fresh reconstruction does not commit arrival",false,result.placement_committed)
	check("fresh reconstruction cannot certify owner state",false,result.owner_state_ready)
	check("fresh reconstruction cannot certify entry",false,result.destination_ready)
	observations.assembly = owner.measurements.duplicate(true)
	observations.publication = registry.timings.duplicate(true)
	observations.memory_static_bytes = OS.get_static_memory_usage()
	if DisplayServer.get_name() != "headless": await render_review(owner,shell,fixture)
	owner.dispose()
	return terminal(fixture)
