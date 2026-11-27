extends RefCounted
## Classic framing with real, owner-validated name/portrait/reflex controls.
const Name = preload("res://scripts/ui/character_name.gd")
const Reflex = preload("res://scripts/char/reflex_parameters.gd")

func render(view: RefCounted, expected: Dictionary, hook: String, selected: Dictionary) -> void:
	match hook:
		"name": name_page(view,expected,selected)
		"face": face_page(view,expected,selected)
		"reflexes": reflex_page(view,expected,selected)

func name_page(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var column := VBoxContainer.new()
	view._box(Rect2(24,60,592,214)).add_child(column)
	view._text(column,"What is your name?")
	view._text(column,"Enter your name above, or ask for a name from your homeland. You may edit a suggested name before continuing.")
	var field := preload("res://scripts/ui/character_name_field.gd").new()
	field.text = str(view._working.get("name",selected.get("name","")))
	field.placeholder_text = "Enter your name"
	field.position = Vector2(148,0)
	field.size = Vector2(386,34)
	field.set_meta("creation_editor","name")
	if view._presentation != null: field.add_theme_font_override("font",view._presentation.font("body"))
	view._page.add_child(field)
	view._editors["name-field"] = field
	var feedback := Label.new()
	if view._presentation != null: feedback.add_theme_font_override("font",view._presentation.font("body"))
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(feedback)
	field.rejected.connect(func(reason: String): feedback.text = reason)
	var validate_input := func(text: String):
		view._working.name = text
		var checked := Name.validate(text)
		feedback.text = "%d / 31 grapheme clusters" % checked.count if checked.ok else checked.reason
	validate_input.call(field.text)
	var generation: int = view._render_generation
	field.text_changed.connect(func(text: String):
		if generation == view._render_generation: validate_input.call(text))
	field.text_submitted.connect(func(text: String):
		if generation == view._render_generation:
			view._working.name = text
			view.action("next",expected))
	field.focus_entered.connect(func(): view._focus = "name-field")
	view._button("random-name","Random",Rect2(542,0,92,34),func(): view.action("identity-operation",expected,"random-name"))
	view._button("apply-name","Use name",Rect2(314,344,200,46),func(): view.action("edit",expected,field.text))
	view._text(column,"Accepted: "+str(selected.get("name","Not yet entered")))
	if view._focus == "name-field": view.call_deferred("_focus_control",field,generation)

func draw_portrait(view: RefCounted, selected: Dictionary, rect: Rect2) -> void:
	var value: Variant = selected.get("face")
	if not value is Dictionary:
		view._text(view._box(rect),"Choose a portrait")
		return
	var resolved: Dictionary = view.inputs.portrait(value)
	if not resolved.ok:
		view._text(view._box(rect),"Portrait unavailable. Choose a replacement.")
		return
	var image := TextureRect.new()
	image.texture = resolved.texture
	image.position = rect.position
	image.size = rect.size
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view._page.add_child(image)

func face_page(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var set: Dictionary = view.inputs.face_set(selected)
	var column := VBoxContainer.new()
	view._box(Rect2(20,42,430,220)).add_child(column)
	view._text(column,"Choose your face")
	view._text(column,"Browse portraits for your birth race and gender. Your choice remains selected when you return here.")
	var position := -1
	for index in set.faces.size():
		if selected.get("face",{}).get("id") == set.faces[index].id: position = index; break
	view._text(column,"Portrait %d of %d" % [position+1,set.faces.size()] if position >= 0 else "Select Previous or Next to choose a portrait explicitly.")
	view._text(column,"Name: "+str(selected.get("name","")))
	draw_portrait(view,selected,Rect2(492,34,130,100))
	view._button("portrait-previous","Previous",Rect2(488,136,86,36),func(): view.action("identity-operation",expected,"portrait-previous"))
	view._button("portrait-next","Next",Rect2(574,136,60,36),func(): view.action("identity-operation",expected,"portrait-next"))
	for id in ["portrait-previous","portrait-next"]: view._buttons[id].add_theme_font_size_override("font_size",14)

func reflex_page(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var column := VBoxContainer.new()
	view._box(Rect2(16,16,370,320)).add_child(column)
	view._box(Rect2(392,16,240,322))
	view._text(view._box(Rect2(16,340,494,54)),"Choose a setting, then continue.")
	view._text(column,"How quickly do you react in combat?")
	var parameters: Dictionary = view.inputs.identity.get("reflexes",{}).get(selected.get("reflexes"),{})
	if parameters.is_empty(): view._text(column,"Required reflex parameters are unavailable. Select a valid option after restoring its definitions.")
	else: view._text(column,Reflex.explanation(parameters))
	for index in Reflex.IDS.size():
		var id: String = Reflex.IDS[index]
		var definition: Dictionary = view.inputs.identity.get("reflexes",{}).get(id,{})
		view._button("reflex/"+id,str(definition.get("label",id)),Rect2(400,32+index*58,222,50),func(): view.action("edit",expected,id))
		view._buttons["reflex/"+id].toggle_mode = true
		view._buttons["reflex/"+id].button_pressed = selected.get("reflexes") == id
