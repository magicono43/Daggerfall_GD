extends "res://tests/binding_config_reload_cases.gd"
const Settings = preload("res://scripts/startup/settings_owner.gd")
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var owner: RefCounted = shell.controller.controls
	var effective: Dictionary = owner.effective()
	check("fresh process view configuration valid",Configuration.valid(effective))
	check("fresh process retry response persisted",is_equal_approx(effective.response.mouse_x,0.45))
	check("fresh process smoothing defaults preserved",not effective.response.mouse_smoothing and is_equal_approx(effective.response.mouse_smoothing_seconds,0.08))
	check("fresh process view and persisted agree",shell.controller.settings.value(shell.controller.settings.persisted,Configuration.SETTING) == effective)
	var previous := Settings.new(shell.controller.settings.adapter,str(fixture.sandbox).path_join("before-retry"))
	var controls := Configuration.new()
	controls.declare_settings(previous)
	check("fresh process pre retry snapshot initializes",previous.initialize().ok)
	check("fresh process pre retry snapshot retains old response",is_equal_approx(previous.effective[Configuration.SETTING].response.mouse_x,0.35))
	check("fresh process snapshot differs from retried response",previous.effective[Configuration.SETTING] != effective)
	shell.session_shell.render()
	check("fresh process stock view receives reloaded effective response",is_equal_approx(shell.session_shell.view._response.mouse_x,0.45))
	controls.dispose()
	return {"ok":checks.all(func(item: Dictionary): return item.expected == item.actual),"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture}
