extends "res://tests/creation_background_identity_preview.gd"

func allocate(view: RefCounted, hook: String) -> void:
	var guard := 0
	while not view.owner.section_status(hook).ok and guard < 100:
		var used := false
		for id in view._buttons.keys():
			if id.begins_with("starting/") and id.ends_with("/1") and not view._buttons[id].disabled:
				await suite.press(shell,view,id); used = true; break
		if not used: break
		guard += 1
	suite.check(hook+" all points allocated",true,view.owner.section_status(hook).ok)

func hold(view: RefCounted, id: String) -> void:
	var position := point(view._buttons[id])
	await move(position)
	var event := InputEventMouseButton.new(); event.position = position; event.global_position = position; event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true
	Input.parse_input_event(event); await settle()
	await shell.get_tree().create_timer(0.37).timeout
	event = event.duplicate(); event.pressed = false; Input.parse_input_event(event); await settle()

func green(view: RefCounted, id: String) -> bool:
	for label: Label in view._page.find_children("*","Label",true,false):
		if label.get_meta("allocation_value","") == id: return label.get_theme_color("font_color") == Color.GREEN
	return false

func run(checks: RefCounted, host: Control, view: RefCounted, fixture: Dictionary) -> Dictionary:
	suite = checks; shell = host
	await preset(view); await mouse(view._buttons["choice/automatic"]); await mouse(view._buttons["notice/dismiss"])
	await mouse(view._buttons["random-name"]); await mouse(view._buttons["apply-name"])
	var art: RefCounted = shell.controller.providers.creation_art
	var dice: int = art.dice_submissions
	await mouse(view._buttons["portrait-confirm"])
	suite.check("attribute entry generates initial roll",true,view.owner.projection().selections.has("attributes"))
	suite.check("initial attribute roll sound",dice+1,art.dice_submissions)
	suite.check("allocation Next hidden",false,view._buttons.next.visible)
	await capture("bonus-attributes-initial",fixture)
	if not fixture.review_smoke and fixture.final_page == "attributes": return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	await suite.press(shell,view,"reroll-attributes"); await suite.press(shell,view,"reroll-attributes")
	suite.check("each reroll submits dice",dice+3,art.dice_submissions)
	var voices := 0
	for child in shell.get_children():
		if child.get_meta("creation_dice_voice",false) and child.playing: voices += 1
	suite.check("rapid dice sounds overlap",true,voices >= 2)
	await hold(view,"starting/strength/1")
	suite.check("attribute hold repeats",true,view.owner.projection().selections.attributes.roll.allocated.strength >= 2)
	suite.check("allocated attribute green",true,green(view,"strength"))
	var allocated: int = view.owner.projection().selections.attributes.roll.allocated.strength
	await shell.get_tree().create_timer(0.2).timeout
	suite.check("released attribute hold stops",allocated,view.owner.projection().selections.attributes.roll.allocated.strength)
	await hold(view,"starting/strength/-1")
	suite.check("attribute hold decrements",true,view.owner.projection().selections.attributes.roll.allocated.strength <= allocated-2)
	await suite.press(shell,view,"save-roll")
	var saved: Dictionary = view.owner.projection().selections.attributes.roll.duplicate(true)
	await suite.press(shell,view,"reroll-attributes"); await suite.press(shell,view,"load-roll")
	suite.check("native load restores allocations",saved,view.owner.projection().selections.attributes.roll)
	await allocate(view,"attributes"); await capture("bonus-attributes-allocated",fixture)
	await mouse(view._buttons["allocation-confirm"])
	suite.check("native attributes OK reaches skills","skills",view.navigation.step().hook)
	await capture("bonus-skills-initial",fixture)
	if not fixture.review_smoke and fixture.final_page == "skills": return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	var career: Dictionary = view.inputs.career_context(view.owner.projection(),"skills").career
	var skill: String = career.tiers.primary[0]
	await hold(view,"starting/"+skill+"/1")
	suite.check("skill hold repeats",true,view.owner.projection().selections.skills.roll.allocated[skill] >= 2)
	suite.check("allocated skill green",true,green(view,skill))
	var skill_allocated: int = view.owner.projection().selections.skills.roll.allocated[skill]
	await hold(view,"starting/"+skill+"/-1")
	suite.check("skill hold decrements",true,view.owner.projection().selections.skills.roll.allocated[skill] <= skill_allocated-2)
	suite.check("zero assigned skill reverts yellow",false,green(view,skill))
	await allocate(view,"skills"); await capture("bonus-skills-allocated",fixture)
	await mouse(view._buttons["allocation-confirm"])
	suite.check("native skills OK reaches reflexes","reflexes",view.navigation.step().hook)
	for label: Label in view._page.find_children("*","Label",true,false):
		if label.get_meta("creation_reflex_explanation",false):
			suite.check("reflex explanation wraps",true,label.get_line_count() > 1)
			suite.check("reflex explanation fits width",true,label.size.x <= 224)
			suite.check("reflex explanation fits parchment",true,label.get_minimum_size().y <= 84)
	suite.check("native skill spinner resolves",true,art.resolve("creation.skill-spinner").ok)
	suite.check("native reflex highlight resolves",true,art.resolve("creation.reflex-highlight").ok)
	await mouse(view._buttons["reflex/high"]); await capture("reflex-picker",fixture)
	if not fixture.review_smoke and fixture.final_page == "reflexes": return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	await mouse(view._buttons["reflex-confirm"])
	suite.check("native reflex OK reaches overview","summary",view.navigation.step().hook)
	await capture("creator-overview",fixture)
	if not fixture.review_smoke: return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	var captured: Dictionary = view.navigation.capture(view.navigation.context())
	suite.check("overview capture initially valid",true,captured.ok)
	await mouse(view._buttons["starting/strength/-1"])
	suite.check("overview redistribution stays on overview","summary",view.navigation.step().hook)
	suite.check("unspent overview blocks capture",false,view.navigation.capture(view.navigation.context()).ok)
	await mouse(view._buttons["summary/confirm"])
	suite.check("invalid overview shows notice",true,view._buttons.has("notice/dismiss"))
	await mouse(view._buttons["notice/dismiss"])
	await mouse(view._buttons["starting/strength/1"])
	suite.check("reallocated overview capture valid",true,view.navigation.capture(view.navigation.context()).ok)
	await mouse(view._buttons["reflex/very-low"])
	suite.check("overview reflex edit accepted","very-low",view.owner.projection().selections.reflexes)
	var face: Dictionary = view.owner.projection().selections.face.duplicate(true)
	await mouse(view._buttons["portrait-next"])
	suite.check("overview face edit accepted",false,Draft.same_value(face,view.owner.projection().selections.face))
	var field: LineEdit = view._editors["summary/name"]
	field.text = "Overview Name"; field.text_changed.emit(field.text)
	await mouse(view._buttons["reflex/average"])
	suite.check("overview name commits with other edit","Overview Name",view.owner.projection().selections.name)
	var unicode_field: LineEdit = view._editors["summary/name"]
	unicode_field.text = "記憶"; unicode_field.text_changed.emit(unicode_field.text)
	suite.check("inline overview Unicode preserved","記憶",view._working["summary.name"])
	suite.check("inline overview unsupported font recovery",true,unicode_field.get_theme_font("font") != preload("res://scripts/ui/creation_native_controls.gd").font(view) and not view.glyph_diagnostics.is_empty())
	unicode_field.text = "Overview Name"; unicode_field.text_changed.emit(unicode_field.text)
	var prior_name: String = view.owner.projection().selections.name
	var stale: Dictionary = view.navigation.context().duplicate(true)
	view.action("summary-change",stale,{"section":"reflexes","value":"high"}); await settle()
	suite.check("retired overview edit rejected",false,view.action("summary-change",stale,{"section":"name","value":"Stale Name"}).ok)
	suite.check("retired edit retains name",prior_name,view.owner.projection().selections.name)
	var active_skill: String = career.tiers.primary[0]
	await mouse(view._buttons["starting/"+active_skill+"/-1"])
	suite.check("overview unspent skill blocks capture",false,view.navigation.capture(view.navigation.context()).ok)
	await mouse(view._buttons["starting/select/"+str(career.tiers.primary[1])])
	await mouse(view._buttons["starting/"+str(career.tiers.primary[1])+"/1"])
	suite.check("overview skill redistribution valid",true,view.navigation.capture(view.navigation.context()).ok)
	view._editors["summary/name"].text = ""; view._editors["summary/name"].text_changed.emit("")
	suite.check("overview invalid name blocks confirmation",false,view.action("begin",view.navigation.context()).ok)
	view._editors["summary/name"].text = prior_name; view._editors["summary/name"].text_changed.emit(prior_name)
	view.action("summary-change",view.navigation.context(),{"section":"name","value":prior_name}); await settle()
	suite.check("edited overview capture valid",true,view.navigation.capture(view.navigation.context()).ok)
	suite.check("no premature live actors",0,shell.session_shell.core.actors._actors.size())
	await capture("creator-overview-edited",fixture)
	if fixture.get("identity_checks_preview",false):
		suite.checks.append_array(preload("res://tests/creation_identity_cases.gd").new().qualify(shell,fixture))
		suite.checks.append_array(await preload("res://tests/creation_identity_ui_cases.gd").new().qualify(shell,fixture))
	return suite.save(str(fixture.sandbox).path_join("result.json"))
