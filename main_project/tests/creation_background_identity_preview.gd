extends "res://tests/creation_picker_preview.gd"
const Draft = preload("res://scripts/char/creation_draft.gd")

func preset(view: RefCounted) -> void:
	var button: Button = view._buttons["preset/class-00"]
	picker(view).set_scroll(picker(view).buttons.find(button))
	await settle(); await mouse(button,true)
	await mouse(view._buttons["confirm/yes"])

func report_checks(view: RefCounted) -> void:
	var changes: Dictionary = view.owner.projection().selections.biography.intent.social_additions
	var count := 0
	for node: Label in view._page.find_children("*","Label",true,false):
		if not node.has_meta("biography_social_direction"): continue
		var index: int = node.get_meta("biography_social_direction")
		var amount: int = changes.get("classic.social:"+str(index),0)
		suite.check("social direction "+str(index),"Higher" if amount > 0 else "Lower" if amount < 0 else "Unchanged",node.text)
		count += 1
	suite.check("five social directions",5,count)

func run(checks: RefCounted, host: Control, view: RefCounted, fixture: Dictionary) -> Dictionary:
	suite = checks; shell = host
	await preset(view)
	await move(Vector2(2,2)); await capture("background-method",fixture)
	if fixture.get("manual_biography_preview",false) and not fixture.get("review_smoke",false):
		await mouse(view._buttons["choice/manual"])
		return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	if not fixture.get("review_smoke",false) and not fixture.get("name_page_preview",false) and not fixture.get("face_page_preview",false) and not fixture.get("preview_close_test",false):
		return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	var art: RefCounted = shell.controller.providers.creation_art
	var clicks: int = art.click_submissions
	await mouse(view._buttons["choice/automatic"])
	suite.check("automatic choice generates immediately",true,view.biography_view.report)
	suite.check("automatic biography complete",true,view.owner.section_status("biography").ok)
	suite.check("automatic choice one click",clicks+1,art.click_submissions)
	report_checks(view)
	await move(Vector2(2,2)); await capture("background-automatic-reputation",fixture)
	if fixture.get("preview_close_test",false) and not fixture.get("name_page_preview",false) and not fixture.get("face_page_preview",false):
		return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	await mouse(view._buttons["notice/dismiss"])
	suite.check("report dismissal reaches name","name",view.navigation.step().hook)
	if fixture.get("review_smoke",false):
		var generated: Dictionary = view.owner.projection().selections.biography.duplicate(true)
		await mouse(view._buttons.back)
		suite.check("automatic Name Back reaches method chooser","biography_method",view.navigation.step().hook)
		suite.check("automatic Back retains generated biography",true,Draft.same_value(generated,view.owner.projection().selections.biography))
		await mouse(view._buttons["choice/automatic"])
		await mouse(view._buttons["notice/dismiss"])
		suite.check("automatic chooser can resume Name","name",view.navigation.step().hook)
	suite.check("name native input position",Vector2(80,3),view._editors["name-field"].position)
	suite.check("name redundant Next hidden",false,view._buttons.next.visible)
	await move(Vector2(2,2)); await capture("name-blank",fixture)
	if fixture.get("name_page_preview",false) and not fixture.get("review_smoke",false): return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	await mouse(view._buttons["random-name"])
	suite.check("Random generates valid owner name",true,preload("res://scripts/ui/character_name.gd").validate(view.owner.projection().selections.name).ok)
	await move(Vector2(2,2)); await capture("name-generated",fixture)
	await mouse(view._buttons["apply-name"])
	suite.check("native name OK advances","face",view.navigation.step().hook)
	await move(Vector2(2,2)); await capture("face-initial",fixture)
	if not fixture.get("review_smoke",false): return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	var first: Dictionary = art.resolve("creation.portrait.nord.female.00")
	var duplicate: Dictionary = art.resolve("creation.portrait.nord.female.01")
	suite.check("source Nord duplicate confirmed",first.pixel_hash,duplicate.pixel_hash)
	clicks = art.click_submissions
	await mouse(view._buttons["portrait-next"])
	suite.check("first Next skips duplicate source",{"set":"nord/female","id":"classic-02"},view.owner.projection().selections.face)
	suite.check("face browse one click",clicks+1,art.click_submissions)
	await mouse(view._buttons["portrait-previous"])
	suite.check("Previous returns first unique image",first.pixel_hash,view.inputs.portrait(view.owner.projection().selections.face).pixel_hash)
	var seen: Array = []
	for index in 9:
		var face: Dictionary = view.owner.projection().selections.face
		var image: Dictionary = view.inputs.portrait(face)
		suite.check("unique browsed Nord face "+str(index),false,image.pixel_hash in seen)
		seen.append(image.pixel_hash)
		await mouse(view._buttons["portrait-next"])
	suite.check("Nord unique cycle wraps","classic-00",view.owner.projection().selections.face.id)
	# Controlled replacement projection at the art-consumer boundary: a distinct
	# resolved image for the original duplicate ID must remain browsable.
	var target := "creation.portrait.nord.female.01"
	var retained_image: Dictionary = art._textures[target].duplicate()
	var replacement := Image.create(29,35,false,Image.FORMAT_RGBA8); replacement.fill(Color.MAGENTA)
	var revised_image := retained_image.duplicate()
	revised_image.texture = ImageTexture.create_from_image(replacement)
	revised_image.pixel_hash = preload("res://scripts/data/actor_input_formats.gd").sha256(replacement.get_data())
	art._textures[target] = revised_image
	await mouse(view._buttons["portrait-next"])
	suite.check("distinct mod projection preserves duplicate ID","classic-01",view.owner.projection().selections.face.id)
	art._textures[target] = retained_image
	view.action("edit",view.navigation.context(),{"set":"nord/female","id":"classic-00"})
	await settle()
	await move(Vector2(2,2)); await capture("face-selected",fixture)
	await mouse(view._buttons["portrait-confirm"])
	suite.check("native face OK advances","attributes",view.navigation.step().hook)
	# A second real flow covers all manual questions and the same completion modal.
	view.restart(); await settle()
	await suite.press(shell,view,"province/nord"); await mouse(view._buttons["confirm/yes"])
	await mouse(view._buttons["gender/female"]); await mouse(view._buttons["choice/list"])
	await preset(view)
	await mouse(view._buttons["choice/manual"])
	suite.check("manual begins without extra prompt",false,view._buttons.has("biography-initialize"))
	var value: Dictionary = view.owner.projection().selections.biography
	var template: Dictionary = view.inputs.templates[value.template]
	# Controlled presentation projection, not a new catalog publication. Repaint
	# must retain Unicode and emit recovery diagnostics without changing the draft.
	var original_prompt: String = template.questions[0].text
	var facts: Dictionary = view.owner.projection().duplicate(true)
	template.questions[0].text = "記憶 — "+original_prompt
	shell.session_shell.render(); await settle()
	suite.check("localized biography projection retains Unicode",true,template.questions[0].text.contains("記憶"))
	suite.check("localized biography glyph recovery",true,not view.glyph_diagnostics.is_empty())
	suite.check("localized repaint preserves facts",true,Draft.same_value(facts,view.owner.projection()))
	await capture("background-localized-recovery",fixture)
	template.questions[0].text = original_prompt
	shell.session_shell.render(); await settle()
	for index in template.questions.size():
		var question: Dictionary = template.questions[index]
		suite.check("manual native question "+str(index),index,view.biography_view.position)
		if index in [0,1,template.questions.size()-1]:
			await move(Vector2(2,2)); await capture("background-question-"+str(index+1),fixture)
		await mouse(view._buttons["biography-answer/"+question.id+"/"+question.answers[0].id])
	suite.check("manual completion opens report",true,view.biography_view.report)
	suite.check("twelve owner answers",12,view.owner.projection().selections.biography.answers.size())
	report_checks(view)
	await move(Vector2(2,2)); await capture("background-manual-reputation",fixture)
	var retained: Dictionary = view.owner.projection().selections.biography.duplicate(true)
	await key(KEY_ESCAPE)
	suite.check("Escape dismisses report to name","name",view.navigation.step().hook)
	suite.check("report dismissal preserves biography",true,Draft.same_value(retained,view.owner.projection().selections.biography))
	await mouse(view._buttons.back)
	suite.check("manual Name Back retains question route","biography",view.navigation.step().hook)
	suite.check("no premature live actors",0,shell.session_shell.core.actors._actors.size())
	if fixture.get("identity_checks_preview",false):
		suite.checks.append_array(preload("res://tests/creation_identity_cases.gd").new().qualify(shell,fixture))
		suite.checks.append_array(await preload("res://tests/creation_identity_ui_cases.gd").new().qualify(shell,fixture))
	return suite.save(str(fixture.sandbox).path_join("result.json"))
