extends "res://tests/text_cases.gd"
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var expected: Dictionary = FileAccess.open(str(fixture.sandbox).path_join("expected-ground-settings.bin"),FileAccess.READ).get_var(false)
	var controls: RefCounted = shell.controller.controls
	var config: Dictionary = controls.effective()
	check("ground reload isolated settings path",expected.path,shell.controller.settings.path)
	check("ground reload exact configuration",expected.configuration,config)
	check("ground reload Run Toggle", "toggle",config.response.run_mode)
	check("ground reload Sneak Toggle","toggle",config.response.sneak_mode)
	check("ground reload actual Run consumer","toggle",shell.session_shell.ground.gait.run_mode)
	check("ground reload actual Sneak consumer","toggle",shell.session_shell.ground.gait.sneak_mode)
	check("ground reload preserves crouch default","toggle",config.response.crouch_mode)
	check("ground reload cannot revive Autorun",false,shell.session_shell.ground.gait.autorun)
	return {"ok":checks.all(func(item): return item.expected == item.actual),"checks":checks,"count":checks.size(),"fixture":"IMP-012-ground-v1","engine":Engine.get_version_info(),"display":DisplayServer.get_name()}
