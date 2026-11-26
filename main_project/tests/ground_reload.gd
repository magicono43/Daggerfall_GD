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
	check("ground reload preserves crouch default","toggle",preload("res://scripts/input/binding_configuration.gd").defaults().response.crouch_mode)
	check("ground reload saved Crouch Hold","hold",config.response.crouch_mode)
	check("ground reload actual Crouch consumer","hold",shell.session_shell.ground.gait.crouch_mode)
	check("ground reload cannot revive Autorun",false,shell.session_shell.ground.gait.autorun)
	check("feedback reload applied gait Off",0.0,shell.session_shell.view._response.gait_bob_percent)
	check("feedback reload applied mounted strength",25.0,shell.session_shell.view._response.mounted_bob_percent)
	check("feedback reload applied landing strength",75.0,shell.session_shell.view._response.landing_camera_percent)
	check("feedback reload applied actual audio mute",0.0,shell.session_shell.movement_audio.volume_linear)
	return {"ok":checks.all(func(item): return item.expected == item.actual),"checks":checks,"count":checks.size(),"fixture":"IMP-012-ground-v1","engine":Engine.get_version_info(),"display":DisplayServer.get_name()}
