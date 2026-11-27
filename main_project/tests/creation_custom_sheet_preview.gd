extends "res://tests/creation_picker_preview.gd"
const Draft = preload("res://scripts/char/creation_draft.gd")

func skill_picker(view: RefCounted) -> Control:
	for child in view._page.get_children():
		if child.get_meta("custom_skill_picker",false): return child
	return null

func dagger(view: RefCounted) -> Control:
	for child in view._page.find_children("*","Control",true,false):
		if child.get_meta("creation_difficulty_dagger",false): return child
	return null

func choose(view: RefCounted, tier: String, slot: int, skill: String) -> void:
	await mouse(view._buttons["skill/"+tier+"/"+str(slot)])
	var list := skill_picker(view)
	var row: Button = view._buttons["custom/skill/"+skill]
	list.set_scroll(maxi(0,list.buttons.find(row)-4))
	await settle()
	await mouse(row,true)

func hold_arrow(view: RefCounted, id: String, duration: int) -> void:
	var position := point(view._buttons[id])
	await move(position)
	var event := InputEventMouseButton.new(); event.position = position; event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true
	Input.parse_input_event(event); await settle()
	var until := Time.get_ticks_msec()+duration
	while Time.get_ticks_msec() < until: await shell.get_tree().process_frame
	event = event.duplicate(); event.pressed = false
	Input.parse_input_event(event); await settle()

func run(checks: RefCounted, host: Control, view: RefCounted, fixture: Dictionary) -> Dictionary:
	suite = checks; shell = host
	shell.get_window().title = "Custom class sheet — focused preview"
	picker(view).set_scroll(1000)
	await settle()
	await mouse(view._buttons["preset/custom"],true)
	suite.check("Custom opens sheet without extra button",true,view._editors.has("custom/name-field") and not view._buttons.has("start-custom"))
	suite.check("custom sheet reached","custom",view.navigation.step().hook)
	suite.check("blank custom attributes",50,view.owner.projection().selections.custom.attributes.strength)
	suite.check("blank custom HP",8,view.owner.projection().selections.custom.hit_points_per_level)
	suite.check("custom arrow texture",true,shell.controller.providers.creation_art.resolve("creation.stat-spinner").ok)
	suite.check("blank primary slots",["","",""],view.owner.projection().selections.custom.tiers.primary)
	suite.check("custom native Next hidden",false,view._buttons.next.visible)
	suite.check("native skill hit area",Vector2(108,8),view._buttons["skill/primary/0"].size)
	suite.check("native HP up hit area",Vector2(8,10),view._buttons["hp/up"].size)
	for value_label: Label in view._page.find_children("*","Label",true,false):
		if value_label.get_meta("custom_attribute_value","") == "strength":
			suite.check("DFU attribute number width",34.0,value_label.size.x)
			suite.check("DFU attribute number position",Vector2(8,33),value_label.position)
	suite.check("DFU attribute hit position",Vector2(7,20),view._buttons["attribute/strength"].position)
	suite.check("dagger native neutral Y",115.0,dagger(view).current_y)
	await move(Vector2(2,2))
	await capture("custom-blank",fixture)
	if fixture.get("custom_exit_preview",false):
		return await preload("res://tests/creation_custom_exit_preview.gd").new().run(suite,shell,view,fixture)
	if fixture.get("reputation_preview",false):
		await mouse(view._buttons["custom/panel/3"])
		return await preload("res://tests/creation_reputation_preview.gd").new().run(suite,shell,view,fixture)
	suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	if not fixture.get("review_smoke",false): return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	var name_field: LineEdit = view._editors["custom/name-field"]
	name_field.text = "Like cats"; name_field.text_changed.emit(name_field.text); name_field.grab_focus()
	await key(KEY_ENTER)
	suite.check("custom name commits through Enter","Like cats",view.owner.projection().selections.custom.name)
	var before: Dictionary = view.owner.projection().selections.custom.duplicate(true)
	await mouse(view._buttons["skill/primary/0"])
	var list := skill_picker(view)
	suite.check("skill picker opens",true,list != null)
	suite.check("skill picker starts alphabetically","Alteration",list.buttons[0].text)
	await mouse(view._buttons["custom/skill/axe"])
	suite.check("single skill click does not commit",true,Draft.same_value(before,view.owner.projection().selections.custom))
	await move(Vector2(2,2))
	await capture("custom-skill-picker",fixture)
	await key(KEY_ESCAPE)
	suite.check("Escape closes skill picker",true,skill_picker(view) == null)
	suite.check("Escape leaves skills unchanged",true,Draft.same_value(before,view.owner.projection().selections.custom))
	await choose(view,"primary",0,"axe")
	suite.check("primary skill owner receives selection","axe",view.owner.projection().selections.custom.tiers.primary[0])
	await choose(view,"major",0,"climbing")
	await choose(view,"major",2,"centaurian")
	await choose(view,"minor",4,"dodging")
	await mouse(view._buttons["skill/primary/1"])
	suite.check("assigned skills excluded across tiers",false,view._buttons.has("custom/skill/axe"))
	await key(KEY_ESCAPE)
	await move(Vector2(2,2))
	await capture("custom-skills-picked",fixture)
	await mouse(view._buttons["hp/down"])
	suite.check("HP down uses owner",7,view.owner.projection().selections.custom.hit_points_per_level)
	await mouse(view._buttons["hp/down"])
	suite.check("HP difficulty follows owner",-4,view.owner.projection().validated.custom.provenance.evaluation.difficulty)
	var gauge := dagger(view)
	suite.check("dagger changed to native Y",128.0,gauge.current_y)
	suite.check("dagger retains recent positions",true,gauge.trails.size() >= 2)
	await move(Vector2(2,2))
	await capture("custom-dagger-trail",fixture)
	var timeout := Time.get_ticks_msec()+1500
	while not gauge.trails.is_empty() and Time.get_ticks_msec() < timeout: await shell.get_tree().process_frame
	suite.check("dagger trail expires after one second",true,gauge.trails.is_empty())
	suite.check("dagger stops processing after fade",false,gauge.is_processing())
	await mouse(view._buttons["attribute/strength"])
	await mouse(view._buttons["attribute/up"])
	suite.check("native attribute spinner owner edit",51,view.owner.projection().selections.custom.attributes.strength)
	await mouse(view._buttons["attribute/down"])
	suite.check("native spinner restores attribute",50,view.owner.projection().selections.custom.attributes.strength)
	var hp_before_attributes: int = view.owner.projection().selections.custom.hit_points_per_level
	await hold_arrow(view,"attribute/up",400)
	var after_attribute_hold: int = view.owner.projection().selections.custom.attributes.strength
	suite.check("attribute hold uses faster repeat cadence",true,after_attribute_hold >= 53)
	var attribute_release_deadline := Time.get_ticks_msec()+250
	while Time.get_ticks_msec() < attribute_release_deadline: await shell.get_tree().process_frame
	suite.check("attribute hold stops on release",after_attribute_hold,view.owner.projection().selections.custom.attributes.strength)
	await hold_arrow(view,"attribute/down",400)
	suite.check("attribute decrement repeats",true,view.owner.projection().selections.custom.attributes.strength <= after_attribute_hold-3)
	suite.check("attribute repeat leaves HP alone",hp_before_attributes,view.owner.projection().selections.custom.hit_points_per_level)
	var attribute_clicks: int = shell.controller.providers.creation_art.click_submissions
	await mouse(view._buttons["attribute/intelligence"])
	suite.check("selecting attribute plays one UI click",attribute_clicks+1,shell.controller.providers.creation_art.click_submissions)
	suite.check("attribute click moves spinner focus",1,view.career_view.custom_attribute)
	var attribute_bound: Dictionary = view.owner.projection().selections.custom.duplicate(true)
	attribute_bound.attributes.intelligence = int(view.inputs.policy.attributes.intelligence.min)+1
	view.action("edit",view.navigation.context(),attribute_bound); await settle()
	await hold_arrow(view,"attribute/down",400)
	suite.check("attribute repeat clamps selected attribute",int(view.inputs.policy.attributes.intelligence.min),view.owner.projection().selections.custom.attributes.intelligence)
	var restored: Dictionary = view.owner.projection().selections.custom.duplicate(true)
	restored.attributes.strength = 50; restored.attributes.intelligence = 50
	view.action("edit",view.navigation.context(),restored); await settle()
	await mouse(view._buttons["attribute/strength"])
	var before_hold: int = view.owner.projection().selections.custom.hit_points_per_level
	var held_position: Vector2 = point(view._buttons["hp/up"])
	await move(held_position)
	var held := InputEventMouseButton.new(); held.position = held_position; held.global_position = held_position
	held.button_index = MOUSE_BUTTON_LEFT; held.pressed = true
	Input.parse_input_event(held); await settle()
	var until := Time.get_ticks_msec()+750
	while Time.get_ticks_msec() < until: await shell.get_tree().process_frame
	suite.check("HP hold repeats across redraws",true,view.owner.projection().selections.custom.hit_points_per_level >= before_hold+3)
	suite.check("mouse HP click has no yellow outline",true,view._buttons["hp/up"].get_theme_stylebox("focus") is StyleBoxEmpty)
	held = held.duplicate(); held.pressed = false
	Input.parse_input_event(held); await settle()
	var after_release: int = view.owner.projection().selections.custom.hit_points_per_level
	until = Time.get_ticks_msec()+400
	while Time.get_ticks_msec() < until: await shell.get_tree().process_frame
	suite.check("HP stops on release",after_release,view.owner.projection().selections.custom.hit_points_per_level)
	view._buttons["hp/up"].grab_focus()
	await key(KEY_ENTER)
	suite.check("HP keyboard step remains available",after_release+1,view.owner.projection().selections.custom.hit_points_per_level)
	suite.check("keyboard focus remains visible",true,view._buttons["hp/up"].get_theme_stylebox("focus") is StyleBoxFlat)
	await mouse(view._buttons["attribute/strength"])
	await move(Vector2(2,2))
	await capture("custom-corrected-attributes",fixture)
	var limit_value: Dictionary = view.owner.projection().selections.custom.duplicate(true)
	limit_value.hit_points_per_level = int(view.inputs.policy.hp.max)-1
	view.action("edit",view.navigation.context(),limit_value)
	await settle()
	held_position = point(view._buttons["hp/up"])
	await move(held_position)
	held.position = held_position; held.global_position = held_position; held.pressed = true
	Input.parse_input_event(held); await settle()
	until = Time.get_ticks_msec()+400
	while Time.get_ticks_msec() < until: await shell.get_tree().process_frame
	suite.check("HP hold clamps at configured maximum",int(view.inputs.policy.hp.max),view.owner.projection().selections.custom.hit_points_per_level)
	held = held.duplicate(); held.pressed = false
	Input.parse_input_event(held); await settle()
	held_position = point(view._buttons["hp/down"])
	await move(held_position)
	held.position = held_position; held.global_position = held_position; held.pressed = true
	Input.parse_input_event(held); await settle()
	var at_pointer_exit: int = view.owner.projection().selections.custom.hit_points_per_level
	await move(Vector2(2,2),true)
	until = Time.get_ticks_msec()+400
	while Time.get_ticks_msec() < until: await shell.get_tree().process_frame
	suite.check("HP hold stops outside arrow",at_pointer_exit,view.owner.projection().selections.custom.hit_points_per_level)
	held = held.duplicate(); held.pressed = false
	Input.parse_input_event(held); await settle()
	await mouse(view._buttons["custom/finish"])
	suite.check("incomplete sheet Exit stays in editor","custom",view.navigation.step().hook)
	suite.check("incomplete skills retained","axe",view.owner.projection().selections.custom.tiers.primary[0])
	await key(KEY_ESCAPE) # Dismiss the completion warning before navigating Back.
	var retained: Dictionary = view.owner.projection().selections.custom.duplicate(true)
	await suite.press(shell,view,"back")
	await suite.press(shell,view,"choice/list")
	picker(view).set_scroll(1000)
	await settle()
	await mouse(view._buttons["preset/custom"],true)
	suite.check("Custom reopens directly",true,view._editors.has("custom/name-field") and not view._buttons.has("start-custom"))
	suite.check("Custom reentry retains edits",true,Draft.same_value(retained,view.owner.projection().selections.custom))
	return suite.save(str(fixture.sandbox).path_join("result.json"))
