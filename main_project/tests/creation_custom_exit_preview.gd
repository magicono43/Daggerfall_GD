extends "res://tests/creation_picker_preview.gd"
const Custom = preload("res://scripts/char/custom_career.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")

func dismiss() -> void:
	await key(KEY_ESCAPE)

func rejected(view: RefCounted, candidate: Dictionary, expected: String, name: String, fixture: Dictionary) -> void:
	view._working.erase("custom.name")
	suite.check(name+" candidate admitted",true,view.action("edit",view.navigation.context(),candidate).ok)
	await settle()
	var retained: Dictionary = view.owner.projection().selections.custom.duplicate(true)
	await mouse(view._buttons["custom/finish"])
	suite.check(name+" message",expected,view.career_view.custom_exit_message)
	suite.check(name+" stays in custom creator","custom",view.navigation.step().hook)
	suite.check(name+" retains rejected candidate",true,Draft.same_value(retained,view.owner.projection().selections.custom))
	await move(Vector2(2,2))
	await capture(name,fixture)
	await dismiss()
	suite.check(name+" Escape dismisses warning","",view.career_view.custom_exit_message)

func run(checks: RefCounted, host: Control, view: RefCounted, fixture: Dictionary) -> Dictionary:
	suite = checks; shell = host
	shell.get_window().title = "Custom class Exit messages — focused preview"
	if not fixture.get("review_smoke",false):
		if fixture.get("preview_close_test",false):
			await mouse(view._buttons["custom/finish"])
			suite.check("close test has live class warning",true,not view.career_view.custom_exit_message.is_empty())
		return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	var empty: Dictionary = view.owner.projection().selections.custom.duplicate(true)
	await mouse(view._buttons["custom/finish"])
	suite.check("empty name has first priority","Name your character class before exiting.",view.career_view.custom_exit_message)
	suite.check("warning blocks underlying controls",true,view._buttons["hp/up"].disabled)
	suite.check("classic warning replaces debug error list","",view.notice)
	await move(Vector2(2,2)); await capture("custom-exit-name",fixture)
	await mouse(view._buttons["notice/dismiss"])
	suite.check("click-anywhere dismisses name warning","",view.career_view.custom_exit_message)
	var field: LineEdit = view._editors["custom/name-field"]
	field.text = "cats"; field.text_changed.emit(field.text)
	await mouse(view._buttons["custom/finish"])
	suite.check("Exit commits visible pending class name","cats",view.owner.projection().selections.custom.name)
	suite.check("skills message follows name","Three primary, three major, and six minor skills\nmust be selected before exiting.",view.career_view.custom_exit_message)
	await move(Vector2(2,2)); await capture("custom-exit-skills",fixture)
	await dismiss()
	var valid := Custom.initial(view.inputs.policy,view.owner.token().id+"/custom")
	valid.name = "Preview class"
	var skills: Array = view.inputs.policy.skills.keys(); skills.sort()
	var index := 0
	for tier in Custom.COUNTS:
		for slot in Custom.COUNTS[tier]: valid.tiers[tier][slot] = skills[index]; index += 1
	var candidate: Dictionary = empty.duplicate(true); candidate.name = " \t "
	await rejected(view,candidate,"Name your character class before exiting.","custom-exit-whitespace",fixture)
	candidate = valid.duplicate(true); candidate.tiers.primary[0] = ""; candidate.attributes.strength -= 1
	await rejected(view,candidate,"Three primary, three major, and six minor skills\nmust be selected before exiting.","custom-exit-skills-priority",fixture)
	candidate = valid.duplicate(true); candidate.attributes.strength -= 1
	await rejected(view,candidate,"Attribute arrow must equal zero before exiting.","custom-exit-attributes",fixture)
	candidate = valid.duplicate(true)
	candidate.traits = ["regenerate_health/general","spell_absorption/general","immunity/magic","immunity/fire"]
	await rejected(view,candidate,"The difficulty of advancing dagger cannot be\nin the red. Select more advantages to move it\nup, or more disadvantages to move it down.","custom-exit-difficulty",fixture)
	candidate = valid.duplicate(true); candidate.reputation.merchants = 1
	await rejected(view,candidate,"Reputation balance must equal zero before exiting.","custom-exit-reputation",fixture)
	view._working.erase("custom.name")
	suite.check("valid completion candidate admitted",true,view.action("edit",view.navigation.context(),valid).ok)
	await settle(); await mouse(view._buttons["custom/finish"])
	suite.check("valid Exit advances","biography_method",view.navigation.step().hook)
	suite.check("valid Exit leaves no warning","",view.career_view.custom_exit_message)
	return suite.save(str(fixture.sandbox).path_join("result.json"))
