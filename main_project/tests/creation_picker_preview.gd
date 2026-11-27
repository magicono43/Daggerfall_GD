extends RefCounted
## Real rendered input for the picker and its immediate confirmation/bio callers.
var suite: RefCounted
var shell: Control

func settle() -> void:
	await suite.settle(shell)

func point(control: Control) -> Vector2:
	return control.get_global_transform_with_canvas()*(control.size/2)

func move(position: Vector2, dragging := false) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position; event.global_position = position
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if dragging else 0
	Input.parse_input_event(event)
	await settle()

func mouse(control: Control, double := false, wheel := 0) -> void:
	var position := point(control)
	await move(position)
	var event := InputEventMouseButton.new()
	event.position = position; event.global_position = position
	event.button_index = wheel if wheel else MOUSE_BUTTON_LEFT
	event.pressed = true; event.double_click = double
	Input.parse_input_event(event)
	await settle()
	event = event.duplicate(); event.pressed = false
	Input.parse_input_event(event)
	await settle()

func key(code: Key) -> void:
	var event := InputEventKey.new(); event.keycode = code; event.pressed = true
	Input.parse_input_event(event); await settle()
	event = event.duplicate(); event.pressed = false
	Input.parse_input_event(event); await settle()

func picker(view: RefCounted) -> Control:
	for child in view._page.get_children():
		if child.get_meta("creation_list_picker",false): return child
	return null

func row(view: RefCounted, text: String) -> Button:
	for button: Button in picker(view).buttons:
		if button.text == text: return button
	return null

func capture(name: String, fixture: Dictionary) -> void:
	await suite.capture(shell,str(fixture.sandbox).path_join(name+".png"))

func run(checks: RefCounted, host: Control, view: RefCounted, fixture: Dictionary) -> Dictionary:
	suite = checks; shell = host
	shell.get_window().title = "Class picker — fast visual preview"
	suite.check("class picker reached","class",view.navigation.step().hook)
	var list: Control = picker(view)
	var art: RefCounted = shell.controller.providers.creation_art
	suite.check("picker original texture",true,art.resolve("creation.list-picker").ok)
	suite.check("biography original texture",true,art.resolve("creation.biography-method").ok)
	suite.check("picker has all owner classes plus Custom",view.inputs.choices("class").size()+1,list.buttons.size())
	suite.check("picker nine visible rows",Vector2(138,72),list._body.get_parent().size)
	suite.check("picker original bitmap font","Daggerfall FONT0003",list.buttons[0].get_theme_font("font").get_font_name())
	suite.check("picker native scrollbar size",Vector2(5,82),list._bar.size)
	var thumb: Dictionary = art.resolve("creation.scrollbar-thumb")
	suite.check("original DFU thumb available",true,thumb.ok)
	suite.check("original thumb slice atlas",Vector2i(5,3),thumb.texture.get_image().get_size() if thumb.ok else Vector2i.ZERO)
	suite.check("native scrollbar uses sliced texture",true,list._bar.get_theme_stylebox("grabber") is StyleBoxTexture)
	suite.check("class Next hidden",false,view._buttons.next.visible)
	await capture("class-picker",fixture)
	suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	if not fixture.get("review_smoke",false):
		return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	await mouse(list.buttons[0],false,MOUSE_BUTTON_WHEEL_DOWN)
	suite.check("mouse wheel scrolls list",1,list.scroll_index)
	list.set_scroll(0)
	await settle()
	var drag_start: Vector2 = list._bar.get_global_transform_with_canvas()*Vector2(2,8)
	await move(drag_start)
	var drag := InputEventMouseButton.new(); drag.position = drag_start; drag.global_position = drag_start
	drag.button_index = MOUSE_BUTTON_LEFT; drag.pressed = true
	Input.parse_input_event(drag); await settle()
	var drag_end: Vector2 = list._bar.get_global_transform_with_canvas()*Vector2(2,80)
	await move(drag_end,true)
	drag = drag.duplicate(); drag.position = drag_end; drag.global_position = drag_end; drag.pressed = false
	Input.parse_input_event(drag); await settle()
	suite.check("thumb drag scrolls list",true,list.scroll_index > 0)
	list._bar.value = list._bar.max_value
	await settle()
	suite.check("scrollbar reaches final rows",list.buttons.size()-9,list.scroll_index)
	var warrior := row(view,"Warrior")
	var warrior_index: int = list.buttons.find(warrior)
	suite.check("picker native row height",8.0,warrior.size.y)
	for item in [["font_color",Color8(243,239,44)],["font_hover_color",Color8(255,130,40)],["font_pressed_color",Color8(162,36,12)],["font_hover_pressed_color",Color8(254,56,18)]]:
		suite.check("picker state "+item[0],item[1],warrior.get_theme_color(item[0]))
	var clicks: int = art.click_submissions
	var jingles: int = view.career_view.class_jingle_submissions
	await mouse(warrior)
	suite.check("single selection is silent",clicks,art.click_submissions)
	suite.check("single selection plays no drums",jingles,view.career_view.class_jingle_submissions)
	suite.check("single click selects row",warrior_index,list.selected)
	suite.check("single click does not confirm","",view.career_view.candidate)
	suite.check("single click commits no class",false,view.owner.projection().selections.has("class"))
	await move(Vector2(2,2))
	await capture("class-selected",fixture)
	await move(point(row(view,"Barbarian")))
	await capture("class-hover",fixture)
	await move(point(warrior))
	await capture("class-selected-hover",fixture)
	var retained_scroll: int = list.scroll_index
	var obsolete: Callable = list.get_signal_connection_list("item_activated")[0].callable
	await mouse(warrior,true)
	suite.check("double click activation has no UI click",clicks,art.click_submissions)
	suite.check("class confirmation plays one drum clip",jingles+1,view.career_view.class_jingle_submissions)
	suite.check("class drums select archive ordinal",374,art.class_jingle().get("provenance",{}).get("ordinal",-1))
	suite.check("class drums retain native gain",0.0,view.career_view._narrations.back().volume_db)
	var drum_player: AudioStreamPlayer = view.career_view._narrations.back()
	suite.check("double click opens confirmation",true,not view.career_view.candidate.is_empty())
	suite.check("double click commits no class",false,view.owner.projection().selections.has("class"))
	suite.check("class confirmation original font",true,view._page.find_children("*","Label",true,false).any(func(label): return label.get_meta("creation_popup_text",false) and label.get_theme_font("font").get_font_name() == "Daggerfall FONT0003"))
	await capture("class-confirmation",fixture)
	await suite.press(shell,view,"confirm/no")
	suite.check("No does not replay class drums",jingles+1,view.career_view.class_jingle_submissions)
	suite.check("No lets class drums finish",true,is_instance_valid(drum_player) and drum_player.playing)
	list = picker(view)
	suite.check("No retains selected row",warrior_index,list.selected)
	suite.check("No retains scroll",retained_scroll,list.scroll_index)
	suite.check("No commits no class",false,view.owner.projection().selections.has("class"))
	row(view,"Warrior").grab_focus()
	await key(KEY_UP)
	suite.check("keyboard Up changes selection",warrior_index-1,list.selected)
	await key(KEY_DOWN)
	suite.check("keyboard Down returns selection",warrior_index,list.selected)
	await mouse(row(view,"Warrior"),true)
	var chosen: String = view.career_view.candidate
	await suite.press(shell,view,"confirm/yes")
	suite.check("Yes commits chosen class",chosen,view.owner.projection().selections.get("class"))
	suite.check("Yes reaches biography method","biography_method",view.navigation.step().hook)
	var after_retirement: int = art.click_submissions
	var drums_after_retirement: int = view.career_view.class_jingle_submissions
	obsolete.call(warrior_index)
	await settle()
	suite.check("obsolete picker plays no click",after_retirement,art.click_submissions)
	suite.check("obsolete picker plays no drums",drums_after_retirement,view.career_view.class_jingle_submissions)
	suite.check("obsolete picker cannot change page","biography_method",view.navigation.step().hook)
	suite.check("biography Next hidden",false,view._buttons.next.visible)
	suite.check("automatic bio native hit area",Vector2(167,54),view._buttons["choice/automatic"].size)
	suite.check("manual bio native hit area",Vector2(167,46),view._buttons["choice/manual"].size)
	await move(Vector2(2,2))
	await capture("biography-method",fixture)
	await mouse(view._buttons["choice/automatic"])
	suite.check("automatic bio commits method","automatic",view.owner.projection().selections.biography_method)
	suite.check("automatic bio advances","biography",view.navigation.step().hook)
	await suite.press(shell,view,"back")
	view._buttons["choice/manual"].grab_focus()
	await key(KEY_ENTER)
	suite.check("manual bio keyboard commits method","manual",view.owner.projection().selections.biography_method)
	suite.check("manual bio advances","biography",view.navigation.step().hook)
	await suite.press(shell,view,"back")
	await suite.press(shell,view,"back")
	list = picker(view)
	list.buttons[0].grab_focus()
	await key(KEY_END)
	suite.check("End selects Custom",list.buttons.size()-1,list.selected)
	var before_custom: int = art.click_submissions
	var before_custom_drums: int = view.career_view.class_jingle_submissions
	await key(KEY_ENTER)
	suite.check("keyboard activation has no UI click",before_custom,art.click_submissions)
	suite.check("Custom does not play preset drums",before_custom_drums,view.career_view.class_jingle_submissions)
	suite.check("Custom keyboard activation opens editor","custom",view.navigation.step().hook)
	return suite.save(str(fixture.sandbox).path_join("result.json"))
