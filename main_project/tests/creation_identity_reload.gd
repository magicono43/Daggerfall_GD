extends "res://tests/mod_cases.gd"

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var settings: RefCounted = shell.controller.settings
	check("creation fresh process video effective",false,settings.effective.get("media/creation_videos"))
	check("creation fresh process video accepted",false,settings.value(settings.accepted,"media/creation_videos"))
	check("creation fresh process video persisted",false,settings.value(settings.persisted,"media/creation_videos"))
	check("creation fresh process has no unfinished draft",{},shell.session_shell.core.creation.projection())
	shell.controller.select_folder(fixture.classic_source)
	shell.controller.continue_to_menu("run")
	shell.session_shell.synchronize_startup()
	shell.session_shell.open_creation()
	var view: RefCounted = shell.session_shell.creation_view
	check("creation fresh process normal New Game",true,view != null and view.active())
	if view == null: return {"ok":false,"checks":checks,"count":checks.size(),"fixture":fixture.fixture,"engine":Engine.get_version_info(),"display":DisplayServer.get_name()}
	check("creation fresh process Average default","average",view.owner.projection().selections.get("reflexes"))
	check("creation fresh process no generated name",false,view.owner.projection().selections.has("name"))
	check("creation fresh process no actors",0,shell.session_shell.core.actors._actors.size())
	view.exit()
	return {"ok":checks.all(func(c): return c.expected == c.actual),"checks":checks,"count":checks.size(),"fixture":fixture.fixture,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"human_pass":false}
