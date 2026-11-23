extends "res://tests/dungeon_reload_cases.gd"
## Fresh process plus published DATA: reconstruction, never a native SAVE provider.
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	await super.run(shell,fixture)
	var owner: Node = shell.session_shell.dungeon_assembly
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(str(fixture.sandbox).path_join("context-restart-expectations.json")))
	var input := request(owner,"packs/assembly.test#context-fixed-override")
	input.presentation = expected.configuration
	var result: Dictionary = await assemble(owner,input)
	if not result.ok: observations.context_restart_failure = result.duplicate(true)
	check("context fresh process reconstructs",true,result.ok)
	if result.ok:
		check("context fresh deterministic palette version",expected.palette_version,result.palette.version)
		check("context fresh resource context version",expected.context_version,result.context_version)
		var spatial: Dictionary = owner.spatial_context(result.ticket,Frame.FRAME,Vector3(0,1,0))
		check("context fresh checked water",true,spatial.ok and not spatial.water_absent)
		check("context fresh reconstruct emits no entry",[],spatial.events)
		check("context fresh reconstruction is not MOVE contact",false,spatial.contact_committed)
		check("context fresh reconstruction is not native SAVE",false,result.save_compatible)
	input = request(owner,"packs/assembly.test#context")
	input.presentation = expected.configuration
	var ordinary: Dictionary = await assemble(owner,input)
	check("context fresh ordinary variation reconstructs",true,ordinary.ok)
	if ordinary.ok:
		check("context fresh ordinary variation version",expected.ordinary_version,ordinary.palette.version)
		check("context fresh ordinary variation selection",expected.ordinary_slots,ordinary.palette.slots)
	var png: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#context-png"))
	check("context fresh DATA image binding reconstructs",true,png.ok)
	if png.ok:
		check("context fresh DATA image version ignores transient ticket",expected.png_context_version,png.context_version)
	owner.dispose()
	return terminal(fixture)
