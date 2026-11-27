extends RefCounted
const Custom = preload("res://scripts/char/custom_career.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")
const ClassicPopup = preload("res://scripts/ui/creation_popup.gd")
const Dagger = preload("res://scripts/ui/creation_difficulty_dagger.gd")

static func ink(label: Control, font: Font) -> void:
	label.add_theme_font_override("font",font)
	label.add_theme_font_size_override("font_size",7)
	label.add_theme_color_override("font_color",ClassicPopup.TEXT_COLOR)
	label.add_theme_color_override("font_shadow_color",ClassicPopup.SHADOW_COLOR)
	label.add_theme_constant_override("shadow_offset_x",1)
	label.add_theme_constant_override("shadow_offset_y",1)

static func label(root: Control, text: String, rect: Rect2, font: Font, centered := false) -> Label:
	var result := Label.new()
	result.text = text; ink(result,font)
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	result.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	result.position = rect.position; result.size = rect.size
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(result)
	return result

static func button(view: RefCounted, root: Control, id: String, text: String, rect: Rect2, callback: Callable, locked: bool) -> Button:
	var result := Button.new()
	result.text = text; result.tooltip_text = text
	result.set_meta("accessible_label",text)
	root.add_child(result)
	var expected: Dictionary = view.navigation.context()
	view._bind_button(result,id,func():
		if not view.active() or view.shell.core.busy() or not Draft.same_value(expected,view.navigation.context()): return
		callback.call())
	result.set_meta("creation_action",id)
	result.disabled = locked
	result.add_theme_font_override("font",view.shell.host.controller.providers.creation_art.popup_font(ThemeDB.fallback_font))
	result.clip_text = true; result.add_theme_font_size_override("font_size",7)
	for color in ["font_color","font_hover_color","font_pressed_color","font_disabled_color","font_focus_color"]: result.add_theme_color_override(color,Color.TRANSPARENT)
	for state in ["normal","hover","pressed","disabled"]: result.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	var focus := StyleBoxFlat.new(); focus.bg_color = Color.TRANSPARENT; focus.border_color = ClassicPopup.TEXT_COLOR; focus.set_border_width_all(1)
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: focus.set_content_margin(side,0)
	result.add_theme_stylebox_override("focus",focus if view.career_view.custom_keyboard_focus else StyleBoxEmpty.new())
	result.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			view.career_view.custom_keyboard_focus = false
			result.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
		elif event is InputEventKey and event.pressed:
			view.career_view.custom_keyboard_focus = true
			result.add_theme_stylebox_override("focus",focus))
	result.focus_entered.connect(func(): result.add_theme_stylebox_override("focus",focus if view.career_view.custom_keyboard_focus else StyleBoxEmpty.new()))
	result.position = rect.position; result.size = rect.size
	return result

static func render(career: RefCounted, view: RefCounted, expected: Dictionary, value: Dictionary, evaluated: Dictionary) -> void:
	var policy: Dictionary = view.inputs.policy
	var art: RefCounted = view.shell.host.controller.providers.creation_art
	var fallback: Font = view._presentation.font() if view._presentation != null else ThemeDB.fallback_font
	var font: Font = art.popup_font(fallback)
	if view._presentation != null: font = view._presentation.creation_popup_font(font)
	var root := Control.new(); root.size = Vector2(320,200); root.scale = Vector2(2,2)
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	view._page.add_child(root)
	var locked: bool = view.navigation.summary_locked() or not career.skill_slot.is_empty()
	var name_field := LineEdit.new()
	name_field.text = str(view._working.get("custom.name",value.name))
	name_field.placeholder_text = "Name your class"; name_field.max_length = 256
	name_field.editable = not locked
	var name_font := font
	for index in name_field.text.length():
		if not font.has_char(name_field.text.unicode_at(index)): name_font = fallback; break
	ink(name_field,name_font)
	for state in ["normal","focus","read_only"]: name_field.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	root.add_child(name_field); name_field.position = Vector2(100,5); name_field.size = Vector2(214,9)
	view._editors["custom/name-field"] = name_field
	name_field.set_meta("creation_action","custom/name-field")
	var generation: int = view._render_generation
	var current := func(): return generation == view._render_generation and view.active() and not view.shell.core.busy() and Draft.same_value(expected,view.navigation.context())
	name_field.focus_entered.connect(func(): view._focus = "custom/name-field")
	name_field.text_changed.connect(func(text: String):
		if current.call():
			view._working["custom.name"] = text
			var selected_font := font
			for index in text.length():
				if not font.has_char(text.unicode_at(index)): selected_font = fallback; break
			ink(name_field,selected_font))
	var commit_name := func():
		if not current.call(): return
		var revised := value.duplicate(true); revised.name = name_field.text; career._edit_custom(view,expected,revised)
	name_field.text_submitted.connect(func(_text: String): commit_name.call())
	# Retain the ordinary development action outside the native sheet.
	career._button(view,view.shell.host.panel,"custom/name","Use name",commit_name,locked)
	view._buttons["custom/name"].size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	view._buttons["custom/name"].custom_minimum_size.x = 140
	for index in 8:
		var key: String = Custom.ATTRIBUTES[index]
		var number := label(root,str(value.attributes[key]),Rect2(8,33+22*index,34,6),font,true)
		number.set_meta("custom_attribute_value",key)
		button(view,root,"attribute/"+key,key.capitalize(),Rect2(7,20+22*index,36,20),func(): career.custom_attribute = index; art.play_dialog_click(view.shell.host); career.refresh(view),locked)
	var spinner: Dictionary = art.resolve("creation.stat-spinner")
	var spinner_y: int = 21+22*career.custom_attribute
	if spinner.ok:
		var background := TextureRect.new(); background.texture = spinner.texture; background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background.position = Vector2(44,spinner_y); background.size = Vector2(15,20); root.add_child(background)
	label(root,str(evaluated.attribute_remaining),Rect2(44,spinner_y+7,15,6),font,true)
	for direction in [-1,1]:
		var attribute_arrow := button(view,root,"attribute/"+("up" if direction > 0 else "down"),"Increase attribute" if direction > 0 else "Decrease attribute",Rect2(44,spinner_y+(0 if direction > 0 else 13),15,7),func():
			var key: String = Custom.ATTRIBUTES[career.custom_attribute]
			var revised := value.duplicate(true)
			revised.attributes[key] = clampi(int(value.attributes[key])+direction,int(policy.attributes[key].min),int(policy.attributes[key].max))
			art.play_dialog_click(view.shell.host); career._edit_custom(view,expected,revised),locked)
		attribute_arrow.gui_input.connect(func(event: InputEvent):
			if not locked and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed: career.hp_repeat.begin(view,direction,attribute_arrow.get_global_transform_with_canvas()*event.position,Custom.ATTRIBUTES[career.custom_attribute])
				else: career.hp_repeat.stop()
				attribute_arrow.accept_event())
	for tier in Custom.COUNTS:
		var top := 31 if tier == "primary" else 80 if tier == "major" else 129
		for slot in Custom.COUNTS[tier]:
			var skill: String = value.tiers[tier][slot]
			var text: String = str(policy.skills[skill].label) if not skill.is_empty() else ""
			label(root,view.display_text(text,"custom.skill"),Rect2(69,top+slot*10+2,103,7),font)
			button(view,root,"skill/"+tier+"/"+str(slot),text if not text.is_empty() else "Choose "+tier+" skill "+str(slot+1),Rect2(66,top+slot*10,108,8),func():
				career.skill_slot = [tier,slot]; art.play_dialog_click(view.shell.host); career.refresh(view),locked)
	label(root,str(value.hit_points_per_level),Rect2(269,55,34,7),font,true)
	if not is_instance_valid(career.hp_repeat):
		career.hp_repeat = preload("res://scripts/ui/creation_hp_repeat.gd").new()
		view.shell.host.add_child(career.hp_repeat)
	for direction in [-1,1]:
		var arrow := button(view,root,"hp/"+("up" if direction > 0 else "down"),"Increase HP" if direction > 0 else "Decrease HP",Rect2(252,46 if direction > 0 else 57,8,10),func():
			var revised := value.duplicate(true)
			revised.hit_points_per_level = clampi(value.hit_points_per_level+direction,int(policy.hp.min),int(policy.hp.max))
			art.play_dialog_click(view.shell.host); career._edit_custom(view,expected,revised),locked)
		arrow.gui_input.connect(func(event: InputEvent):
			if not locked and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed: career.hp_repeat.begin(view,direction,arrow.get_global_transform_with_canvas()*event.position)
				else: career.hp_repeat.stop()
				arrow.accept_event())
	for item in [[4,"Details",74],[1,"Advantages",98],[2,"Disadvantages",122],[3,"Reputation",146]]:
		button(view,root,"custom/panel/"+str(item[0]),item[1],Rect2(249,item[2],66,22),func(): career.custom_tab = item[0]; art.play_dialog_click(view.shell.host); career.refresh(view),locked)
	button(view,root,"custom/finish","Exit custom class editor",Rect2(263,172,38,21),func(): view.action("next",expected),locked)
	var now := Time.get_ticks_msec()
	career.dagger_trails = career.dagger_trails.filter(func(trail): return now-int(trail.started) < Dagger.LINGER_MSEC)
	var y := Dagger.gauge_y(evaluated.difficulty,policy.difficulty)
	if career.dagger_points != evaluated.difficulty:
		career.dagger_points = evaluated.difficulty
		career.dagger_trails.append({"y":y,"started":now})
	var dagger: Dictionary = art.resolve("creation.dagger")
	var gauge := Dagger.new(); gauge.size = Vector2(320,200); gauge.texture = dagger.texture if dagger.ok else null; gauge.current_y = y; gauge.trails = career.dagger_trails.duplicate(true)
	gauge.set_meta("creation_difficulty_dagger",true); root.add_child(gauge)
	if not career.skill_slot.is_empty(): skill_picker(career,view,expected,value,font,art)

static func skill_picker(career: RefCounted, view: RefCounted, expected: Dictionary, value: Dictionary, font: Font, art: RefCounted) -> void:
	var options: Array = []
	for id in view.inputs.policy.skills:
		var assigned := false
		for tier in Custom.COUNTS:
			if id in value.tiers[tier]: assigned = true
		if not assigned or value.tiers[career.skill_slot[0]][career.skill_slot[1]] == id:
			options.append({"id":id,"label":view.translated("skill."+id,str(view.inputs.policy.skills[id].label))})
	options.sort_custom(func(a,b): return a.label.naturalnocasecmp_to(b.label) < 0)
	var image: Dictionary = art.resolve("creation.list-picker")
	var thumb: Dictionary = art.resolve("creation.scrollbar-thumb")
	var picker := preload("res://scripts/ui/classic_list_picker.gd").new()
	picker.position = Vector2(120,72); picker.scale = Vector2(2,2); picker.set_meta("custom_skill_picker",true)
	view._page.add_child(picker)
	var initial := 0
	for index in options.size():
		if options[index].id == value.tiers[career.skill_slot[0]][career.skill_slot[1]]: initial = index
	picker.configure(options.map(func(item): return item.label),font,image.texture if image.ok else null,view.navigation.summary_locked(),initial,maxi(0,initial-8),thumb.texture if thumb.ok else null)
	for index in options.size(): view._buttons["custom/skill/"+options[index].id] = picker.buttons[index]
	var generation: int = view._render_generation
	var slot: Array = career.skill_slot.duplicate()
	picker.item_activated.connect(func(index: int):
		if generation != view._render_generation or not view.active() or view.shell.core.busy() or not Draft.same_value(expected,view.navigation.context()) or view.navigation.summary_locked(): return
		var revised := value.duplicate(true); revised.tiers[slot[0]][slot[1]] = options[index].id
		career.skill_slot = []; career._edit_custom(view,expected,revised))
