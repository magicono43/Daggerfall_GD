extends RefCounted
const Configuration = preload("res://scripts/input/binding_configuration.gd")
var checks: Array[Dictionary] = []
func check(label: String, value: bool) -> void:
	checks.append({"scenario":label,"expected":true,"actual":value})

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var owner: RefCounted = shell.controller.controls
	var settings: StartupSettingsOwner = shell.controller.settings
	var effective: Dictionary = owner.effective()
	check("fresh process reload uses same isolated settings file",settings.path == FileAccess.get_file_as_string(str(fixture.sandbox).path_join("binding-expected.txt")))
	check("fresh process controls complete and valid",Configuration.valid(effective))
	check("fresh process deliberate unbound retained",effective.actions.jump.keyboard == [{},{}])
	check("fresh process custom physical key retained",effective.actions.attack.keyboard[1].code == KEY_E)
	check("fresh process controller trigger retained",effective.actions.attack.controller[1] == {"kind":"trigger","code":JOY_AXIS_TRIGGER_RIGHT})
	check("fresh process analog settings retained",effective.analog.movement_pair == 1 and effective.analog.look_pair == 0 and effective.analog.look_deadzone == 0.12)
	check("fresh process unknown settings preserved without application",settings.value(settings.accepted,"fixture/unknown") == "retained" and not settings.effective.has("fixture/unknown"))
	check("fresh process persisted and effective agree",settings.value(settings.persisted,Configuration.SETTING) == effective)
	return {"ok":checks.all(func(item: Dictionary): return item.expected == item.actual),"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture}
