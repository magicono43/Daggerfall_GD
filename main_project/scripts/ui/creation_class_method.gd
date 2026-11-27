extends RefCounted
## Original BUTN01I0 pixels; native rectangles from DFU CreateCharChooseClassGen.
static func render(view: RefCounted, expected: Dictionary, hook := "class_method") -> void:
	var biography := hook == "biography_method"
	var art: RefCounted = view.shell.host.controller.providers.creation_art
	var image: Dictionary = art.resolve("creation.biography-method" if biography else "creation.class-method")
	var root := Control.new()
	root.size = Vector2(184,168 if biography else 144)
	root.position = (Vector2(640,400)-root.size*2)/2
	root.scale = Vector2(2,2)
	view._page.add_child(root)
	if image.ok:
		var background := TextureRect.new()
		background.texture = image.texture
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.size = root.size
		background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(background)
	var options := [["automatic","Generate biography automatically",Rect2(8,41,167,54)],["manual","Answer biography questions",Rect2(8,113,167,46)]] if biography else [["list","Choose from a list",Rect2(8,41,167,43)],["questionnaire","Answer questions",Rect2(8,100,167,34)]]
	for item in options:
		var id: String = item[0]
		var button := Button.new()
		button.text = view.translated("choice."+hook+"."+id,item[1])
		button.tooltip_text = button.text
		button.set_meta("accessible_label",button.text)
		root.add_child(button)
		view._bind_button(button,"choice/"+id,func():
			if button.disabled or view.shell.core.busy() or not view.active() or not preload("res://scripts/char/creation_draft.gd").same_value(expected,view.navigation.context()): return
			var result: Dictionary = view.action("edit",expected,id)
			if result.ok:
				art.play_dialog_click(view.shell.host)
				view.action("next",view.navigation.context()))
		button.disabled = view.navigation.summary_locked()
		if image.ok:
			button.add_theme_font_size_override("font_size",7)
			button.clip_text = true
			for color in ["font_color","font_hover_color","font_pressed_color","font_disabled_color","font_focus_color"]: button.add_theme_color_override(color,Color.TRANSPARENT)
			for state in ["normal","hover","pressed","disabled"]: button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
			var focus := StyleBoxFlat.new()
			focus.bg_color = Color.TRANSPARENT
			focus.border_color = preload("res://scripts/ui/creation_popup.gd").TEXT_COLOR
			focus.set_border_width_all(1)
			button.add_theme_stylebox_override("focus",focus)
		button.position = item[2].position
		button.size = item[2].size
