extends "res://tests/dungeon_context_reload_cases.gd"
## Compatible fresh-process reconstruction seam, not native SAVE or MOVE.
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	await super.run(shell,fixture)
	var owner: Node = shell.session_shell.dungeon_assembly
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(str(fixture.sandbox).path_join("marker-restart-expectations.json")))
	var result: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#marker-layout"))
	check("markers fresh process reconstructs indexes",true,result.ok)
	if result.ok:
		var inspected: Dictionary = owner.marker_candidate(result.ticket,"door-a")
		check("markers fresh stable version",expected.version,result.marker_version)
		check("markers fresh stable effective marker",true,Layout.Common.equal_input(expected.marker,inspected.marker))
		check("markers fresh reconstruction emits no entry",[],inspected.events)
		check("markers fresh reconstruction does not commit pose",false,inspected.placement_committed)
		check("markers fresh native restoration gate remains open",false,inspected.native_restore_ready)
		var reference: Dictionary = owner.binding(result.ticket,"alpha","start")
		check("markers saved reference reconstruction uses stable binding",true,reference.ok and reference.binding.identity.record == expected.marker.record)
		check("markers compatible reconstruction grants no SAVE",false,result.save_compatible)
	owner.dispose()
	return terminal(fixture)
