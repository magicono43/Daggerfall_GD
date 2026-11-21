extends "res://tests/mod_cases.gd"

func run(shell: Control, _fixture: Dictionary) -> Dictionary:
	var controller = shell.controller
	var preferences: RefCounted = controller.providers.preferences
	check("fresh process reaches actual menu", "main_menu", controller.route)
	check("fresh process active preference definitions", 2, preferences.stores.size())
	check("fresh process live persisted value", 4, preferences.projection("prefs.a").values.low.accepted)
	check("fresh process restart effective value", true, preferences.projection("prefs.a").values.mixed.effective)
	check("fresh process accepted equals persisted", false, preferences.projection("prefs.a").unsaved)
	check("fresh process second mod unchanged", 1, preferences.projection("prefs.b").values.low.accepted)
	var importer := preload("res://scripts/data/translation_import.gd").new(controller.storage.adapter, controller.storage.context.root.path_join("Authoring/disposable"))
	var active: Dictionary = importer.load_active()
	check("fresh process complete authoring generation", true, active.ok)
	check("fresh process retained orphan", "orphan", active.snapshot.entries.beta.review)
	var interrupted := preload("res://scripts/data/translation_import.gd").new(controller.storage.adapter, controller.storage.context.root.path_join("Authoring/interrupted"))
	var recovered: Dictionary = interrupted.load_active()
	check("fresh process ignores interrupted prepared generation", true, recovered.ok)
	var decoded: Dictionary = preload("res://scripts/data/text_author.gd").decode(recovered.snapshot.entries.kept.translation)
	check("fresh process retains old durable translation", "Keep durable work", decoded.tokens[0].text)
	return {"ok":checks.all(func(item: Dictionary): return item.expected == item.actual),"count":checks.size(),"checks":checks,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":"IMP-007-translation-preferences-relaunch-v1"}
