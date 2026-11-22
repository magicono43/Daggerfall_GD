extends "res://tests/mod_cases.gd"
const Layout = preload("res://scripts/data/layout_inputs.gd")

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var controller = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var adapter: RefCounted = controller.providers.layouts
	var mods: RefCounted = controller.mods
	var receipt: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(str(fixture.sandbox).path_join("layout-restart-receipt.json")))
	check("layout fresh process editable","optional_setup",controller.route)
	check("layout fresh saved profile","default",mods.selected)
	check("layout fresh saved order",["test.pack","other.pack"],mods.validate_dependencies().get("order",[]))
	check("layout fresh classic ready",true,controller.providers.classic.ready())
	check("layout fresh definitions unpublished",{},registry.active())
	check("layout fresh complete candidate",true,registry.projection().get("ok",false))
	check("layout fresh CORE menu","main_menu",controller.continue_to_menu("run").route)
	var block: Dictionary = adapter.decode_block(registry,"packs/classic#block-0000")
	check("layout fresh source record inventory",14,block.definition.records.size())
	check("layout fresh adopts loose edit",512,Layout.lookup(registry,"packs/test.pack#repeated").record.value.data.placements[0].transform.position[0])
	var exported: Dictionary = controller.providers.media.export_resource("test.pack","marker","image")
	check("layout fresh adopts changed media bytes",[0,255,0,255],Array(exported.resource.rgba.slice(12,16)))
	check("layout fresh profile identity",receipt.profile,Layout.PROFILE_HASH)
	check("layout fresh menu locks",true,mods.locked)
	check("layout fresh repeated menu idempotent","main_menu",controller.continue_to_menu("run").route)
	check("layout fresh actual resources prepare",true,adapter.prepare_location(registry,"packs/test.pack#custom-resources",adapter.classic_resource).ok)
	check("layout fresh media source digest changed",true,exported.provenance.sha256 != receipt.old_media_sha256)
	var ok := true
	for item: Dictionary in checks: ok = ok and Layout.Common.equal_input(item.expected,item.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs}
