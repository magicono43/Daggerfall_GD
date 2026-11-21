extends "res://tests/mod_cases.gd"
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var controller = shell.controller
	var mods = controller.mods
	var data = controller.providers.definitions
	var media = controller.providers.media
	check("fresh process editable","optional_setup",controller.route)
	check("fresh MOD unlocked",false,mods.locked)
	check("fresh saved profile","default",mods.selected)
	check("fresh enabled order",["media.a","media.b"],mods.validate_dependencies().order)
	check("fresh DATA unpublished",{},data.active())
	var candidate: Dictionary = controller.providers.prepare_content(mods)
	check("fresh candidate valid",true,candidate.ok)
	check("fresh media winner","media.b",media.resolve("sound.3","audio",candidate.ticket).target_record.winner.provider)
	check("fresh loose physical digest changed",true,media.export_resource("@loose","corners","image",candidate.ticket).provenance.sha256 != media.export_resource("@shipped/media-assets","corners","image",candidate.ticket).provenance.sha256)
	check("fresh classic ready",true,controller.providers.classic.ready())
	check("fresh successful history","default",mods.committed.last_successful)
	var ok := true
	for item: Dictionary in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"count":checks.size(),"checks":checks,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs}
