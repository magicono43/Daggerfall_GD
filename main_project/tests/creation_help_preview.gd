extends "res://tests/creation_picker_preview.gd"
const Help = preload("res://scripts/ui/creation_help.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")

func picker(view: RefCounted) -> Control:
	for child in view._page.get_children():
		if child.get_meta("custom_help_picker",false): return child
	return null

func run(checks: RefCounted, host: Control, view: RefCounted, fixture: Dictionary) -> Dictionary:
	suite = checks; shell = host
	var before: Dictionary = view.owner.projection().selections.custom.duplicate(true)
	suite.check("eight help topics",8,picker(view).buttons.size())
	suite.check("help has no unnecessary thumb",false,picker(view)._bar.visible)
	suite.check("help Next hidden",false,view._buttons.next.visible)
	await move(Vector2(2,2)); await capture("help-picker",fixture)
	if not fixture.get("review_smoke",false):
		if fixture.get("preview_close_test",false): await mouse(view._buttons["help/general"],true)
		return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	await mouse(view._buttons["help/attributes"])
	suite.check("single click only selects","",view.career_view.help_topic)
	for topic: Array in Help.TOPICS:
		await mouse(view._buttons["help/"+topic[0]],true)
		suite.check("confirmed help replaces picker "+topic[0],true,picker(view) == null)
		var read: Dictionary = Help.content(view,view.career_view,topic)
		suite.check("classic help record resolves "+topic[0],true,read.ok and read.body.length() > 40)
		var body: Label
		for label: Label in view._page.find_children("*","Label",true,false):
			if label.get_meta("creation_popup_title",false): suite.check("centered title "+topic[0],HORIZONTAL_ALIGNMENT_CENTER,label.horizontal_alignment)
			if label.get_meta("creation_popup_text",false): body = label
		suite.check("left aligned body "+topic[0],HORIZONTAL_ALIGNMENT_LEFT,body.horizontal_alignment)
		suite.check("body fits parchment "+topic[0],true,body.get_minimum_size().y <= body.get_parent().size.y)
		if topic[0] in ["attributes","general","reputations"]:
			await move(Vector2(2,2)); await capture("help-"+topic[0],fixture)
		if topic[0] == "general": await key(KEY_ESCAPE)
		else: await mouse(view._buttons["notice/dismiss"])
		suite.check("help dismiss returns sheet "+topic[0],0,view.career_view.custom_tab)
		await mouse(view._buttons["custom/panel/4"])
	await key(KEY_ESCAPE)
	suite.check("Escape closes help picker only","custom",view.navigation.step().hook)
	suite.check("Escape restores sheet",0,view.career_view.custom_tab)
	await mouse(view._buttons["custom/panel/4"])
	await suite.press(shell,view,"back")
	suite.check("Back closes Help",0,view.career_view.custom_tab)
	suite.check("Help preserves custom values",true,Draft.same_value(before,view.owner.projection().selections.custom))
	return suite.save(str(fixture.sandbox).path_join("result.json"))
