extends "res://tests/mod_cases.gd"

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var controller = shell.controller
	var owner: RefCounted = controller.providers.presentation
	check("fresh process real committed menu","main_menu",controller.route)
	check("fresh process requested locale restored","zz-Test",controller.settings.value(controller.settings.accepted,"presentation/locale"))
	check("fresh process persisted locale restored","zz-Test",controller.settings.value(controller.settings.persisted,"presentation/locale"))
	check("fresh process effective locale restored","zz-Test",controller.settings.effective["presentation/locale"])
	check("fresh process presentation locale restored","zz-Test",owner.locale)
	check("fresh process coherent catalog","Synthetic loaded after real process relaunch",owner.lookup("sample","relaunch",owner.locale).text)
	check("fresh process actual bundled font",true,owner.font() is FontFile and not owner.font().allow_system_fallback)
	check("fresh process English only advertised",["en"],owner.available())
	check("fresh process repaired package adopted",false,controller.providers.definitions.active().resources["text.fonts:installed"].records.has("cycle"))
	check("fresh process resources locked","locked",controller.providers.definitions.prepare(controller.mods).kind)
	return {"ok":checks.all(func(c: Dictionary): return c.expected == c.actual),"count":checks.size(),"checks":checks,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":"IMP-007-locale-fonts-relaunch-v1"}
