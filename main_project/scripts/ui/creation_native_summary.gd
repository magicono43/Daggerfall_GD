extends RefCounted
const Native = preload("res://scripts/ui/creation_native_controls.gd")

static func render(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var root := Native.root(view)
	for section in ["attributes","skills"]:
		var evaluated: Dictionary = view.starting_view.evaluation(view,section,selected)
		if evaluated.ok: view.starting_view.draw(view,root,section,selected,evaluated)
	var field := preload("res://scripts/ui/character_name_field.gd").new()
	field.text = str(view._working.get("summary.name",selected.name))
	field.editable = view._capture.is_empty()
	view.display_text(field.text,"summary-name")
	field.set_meta("creation_summary_name",true); field.set_meta("accessible_label","Character name")
	preload("res://scripts/ui/creation_custom_sheet.gd").ink(field,Native.font(view))
	for index in field.text.length():
		if not Native.font(view).has_char(field.text.unicode_at(index)):
			field.add_theme_font_override("font",view._presentation.font() if view._presentation != null else ThemeDB.fallback_font); break
	for state in ["normal","focus","read_only"]: field.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	root.add_child(field); field.position = Vector2(100,3); field.size = Vector2(214,11)
	view._editors["summary/name"] = field
	var generation: int = view._render_generation
	field.text_changed.connect(func(text: String):
		if generation == view._render_generation:
			view._working["summary.name"] = text
			view.display_text(text,"summary-name")
			var font := Native.font(view)
			for index in text.length():
				if not font.has_char(text.unicode_at(index)):
					font = view._presentation.font() if view._presentation != null else ThemeDB.fallback_font; break
			field.add_theme_font_override("font",font))
	var commit := func():
		if field.composition_owned(): return false
		var result: Dictionary = view.action("summary-change",view.navigation.context(),{"section":"name","value":field.text})
		if result.ok: view._working.erase("summary.name")
		return result.ok
	field.text_submitted.connect(func(_text: String):
		if generation == view._render_generation: commit.call())
	var portrait: Dictionary = view.inputs.portrait(selected.face)
	if portrait.ok:
		var image := TextureRect.new(); image.texture = portrait.texture; image.position = Vector2(247,25)+(Vector2(64,40)-portrait.texture.get_size())/2; image.size = portrait.texture.get_size(); image.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(image)
	for item in [["portrait-previous","Previous",-1,Rect2(245,69,42,9)],["portrait-next","Next",1,Rect2(287,69,26,9)]]:
		Native.button(view,root,item[0],item[1],item[3],func():
			if view.action("summary-change",expected,{"section":"face","direction":item[2]}).ok: Native.click(view))
	view.identity_view.reflex_picker(view,root,expected,selected,Vector2(246,95),true)
	Native.button(view,root,"summary/restart","Restart",Rect2(263,147,39,22),func(): view.action("restart",expected))
	Native.button(view,root,"summary/confirm","OK",Rect2(263,172,39,22),func():
		if field.composition_owned(): return
		if field.text != selected.name and not commit.call(): return
		var result: Dictionary = view.action("begin",view.navigation.context())
		if result.ok: Native.click(view)
		elif result.get("kind") != "pending" and view._capture.is_empty():
			view.starting_view.message = str(result.get("reason","You must distribute your bonus points.")); view.shell.schedule_render())
	if not view.starting_view.message.is_empty():
		preload("res://scripts/ui/creation_popup.gd").notice(view,view.starting_view.message,func(): view.starting_view.message = ""; view.shell.schedule_render(),"summary-allocation")
	var reviews := HBoxContainer.new(); view.shell.host.panel.add_child(reviews)
	for index in 3:
		var review := Button.new(); review.text = ["Overview","Career details","History"][index]; reviews.add_child(review)
		view._bind_button(review,"summary-page/"+["overview","career","history"][index],func(): view._summary_tab = index; view.shell.schedule_render())
