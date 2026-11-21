extends "res://tests/mod_cases.gd"
const Native = preload("res://scripts/data/native_media.gd")
const Fixture = preload("res://tests/native_fixture.gd")
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var controller: RefCounted = shell.controller
	check("native fresh process setup","optional_setup",controller.route)
	check("native fresh process unlocked",false,controller.mods.locked)
	check("native fresh process unpublished",{},controller.providers.definitions.active())
	check("native persisted bank reference",true,str(controller.settings.effective.get("media/midi_bank","")).contains("native-bank"))
	var candidate: Dictionary = controller.providers.prepare_content(controller.mods)
	check("native fresh candidate valid",true,candidate.ok)
	check("native fresh process adopts loose edit",1,controller.providers.media.export_resource("@loose","loose-native-midi","midi",candidate.ticket).resource.smf_type)
	var bank: Dictionary = controller.providers.media_preferences.capture(candidate.ticket)
	check("native fresh bank captured",true,bank.ok)
	check("native fresh alternate bank identity",Native.digest(Fixture.bank()),bank.get("identity",{}).get("sha256",""))
	check("native successful profile history","default",controller.mods.committed.last_successful)
	check("native fresh classic source ready",true,controller.providers.classic.ready())
	check("native fresh runtime capability",true,Native.capabilities().get("midi",false) and Native.capabilities().get("video",false))
	var ok := true
	for item: Dictionary in checks: ok = ok and item.expected==item.actual
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs}
