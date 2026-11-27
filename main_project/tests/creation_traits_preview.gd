extends "res://tests/creation_picker_preview.gd"
const Draft = preload("res://scripts/char/creation_draft.gd")

func picker(view: RefCounted) -> Control:
	for child in view._page.get_children():
		if child.get_meta("custom_trait_picker",false): return child
	return null

func choose(view: RefCounted, category: String, variant := "") -> void:
	await mouse(view._buttons["traits/add"])
	await mouse(view._buttons["trait/pick/"+category],true)
	if not variant.is_empty(): await mouse(view._buttons["trait/pick/"+category+"/"+variant],true)

func open_side(view: RefCounted, side: int) -> void:
	if view.career_view.custom_tab != 0: await key(KEY_ESCAPE)
	await mouse(view._buttons["custom/panel/"+str(side)])

func run(checks: RefCounted, host: Control, view: RefCounted, fixture: Dictionary) -> Dictionary:
	suite = checks; shell = host
	var art: RefCounted = shell.controller.providers.creation_art
	suite.check("trait base source resolves",true,art.resolve("creation.traits").ok)
	suite.check("trait advantage overlay resolves",true,art.resolve("creation.traits-advantages").ok)
	suite.check("small font original","Daggerfall FONT0002",art.small_font(ThemeDB.fallback_font).get_font_name())
	await move(Vector2(2,2)); await capture("traits-empty",fixture)
	if not fixture.get("review_smoke",false):
		if fixture.get("preview_close_test",false):
			await mouse(view._buttons["traits/add"])
			await mouse(view._buttons["trait/pick/immunity"],true)
		return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	await open_side(view,2)
	await move(Vector2(2,2)); await capture("traits-disadvantages-empty",fixture)
	await open_side(view,1)
	var before: Dictionary = view.owner.projection().selections.custom.duplicate(true)
	await mouse(view._buttons["traits/add"])
	suite.check("eleven advantage categories",11,picker(view).buttons.size())
	suite.check("twelve compact rows",12,picker(view)._rows)
	suite.check("no unnecessary scrollbar",false,picker(view)._bar.visible)
	await move(Vector2(2,2)); await capture("traits-primary-picker",fixture)
	var clicks: int = art.click_submissions
	await mouse(view._buttons["trait/pick/immunity"])
	suite.check("single click selects without advancing","category",view.career_view.trait_stage)
	await mouse(view._buttons["trait/pick/immunity"],true)
	suite.check("Immunity opens seven varieties",7,picker(view).buttons.size())
	await move(Vector2(2,2)); await capture("traits-secondary-picker",fixture)
	await key(KEY_ESCAPE)
	suite.check("secondary Escape leaves trait menu",1,view.career_view.custom_tab)
	suite.check("secondary cancellation preserves owner",true,Draft.same_value(before,view.owner.projection().selections.custom))
	suite.check("picker selection and cancellation silent",clicks,art.click_submissions)
	await choose(view,"immunity","paralysis")
	suite.check("variant commits complete ID",["immunity/paralysis"],view.owner.projection().selections.custom.traits)
	suite.check("adding only sounds Add button",clicks+1,art.click_submissions)
	await move(Vector2(2,2)); await capture("traits-selected",fixture)
	var old_dagger: Variant = view.career_view.dagger_points
	clicks = art.click_submissions
	await mouse(view._buttons["remove/immunity/paralysis"])
	suite.check("one click removes trait",[],view.owner.projection().selections.custom.traits)
	suite.check("removal silent",clicks,art.click_submissions)
	suite.check("removal changes dagger",true,old_dagger != view.career_view.dagger_points)
	suite.check("removal leaves dagger afterimage",true,view.career_view.dagger_trails.size() > 0)
	await capture("traits-removal-trail",fixture)
	await choose(view,"immunity","fire")
	await open_side(view,2)
	clicks = art.click_submissions
	await choose(view,"low_tolerance","fire")
	suite.check("conflicting trait silently not added",["immunity/fire"],view.owner.projection().selections.custom.traits)
	suite.check("conflict closes picker","",view.career_view.trait_stage)
	suite.check("no conflict warning",false,view._buttons.has("notice/dismiss"))
	suite.check("conflict only sounds Add",clicks+1,art.click_submissions)
	await choose(view,"low_tolerance","frost")
	suite.check("different target accepted",true,"low_tolerance/frost" in view.owner.projection().selections.custom.traits)
	await open_side(view,1)
	for category: String in ["acute_hearing","adrenaline_rush","athleticism"]: await choose(view,category)
	for target: String in ["animals","daedra","humanoid"]: await choose(view,"bonus_to_hit",target)
	suite.check("seven advantages accepted",8,view.owner.projection().selections.custom.traits.size()) # Plus one disadvantage.
	await mouse(view._buttons["traits/add"])
	suite.check("eighth blocked before picker",true,picker(view) == null)
	await move(Vector2(2,2)); await capture("traits-seven-advantages",fixture)
	await key(KEY_ESCAPE)
	suite.check("Escape closes trait menu only","custom",view.navigation.step().hook)
	suite.check("Escape returns sheet",0,view.career_view.custom_tab)
	await open_side(view,2)
	for target: String in ["iron","steel","silver","elven","dwarven","mithril"]: await choose(view,"forbidden_material",target)
	await mouse(view._buttons["traits/add"])
	suite.check("seventh disadvantage accepted eighth blocked",true,view.owner.projection().selections.custom.traits.size() == 14 and picker(view) == null)
	await move(Vector2(2,2)); await capture("traits-seven-disadvantages",fixture)
	await suite.press(shell,view,"back")
	suite.check("Back closes trait menu",0,view.career_view.custom_tab)
	return suite.save(str(fixture.sandbox).path_join("result.json"))
