extends RefCounted
const Sheet = preload("res://scripts/ui/creation_custom_sheet.gd")

static func root(view: RefCounted) -> Control:
	var control := Control.new(); control.size = Vector2(320,200); control.scale = Vector2(2,2)
	control.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST; view._page.add_child(control)
	control.set_meta("native_art",view.shell.host.controller.providers.creation_art.resolve(view.navigation.step().art).ok)
	return control

static func font(view: RefCounted) -> Font:
	var selected: Font = view.shell.host.controller.providers.creation_art.popup_font(ThemeDB.fallback_font)
	return view._presentation.creation_popup_font(selected) if view._presentation != null else selected

static func text(view: RefCounted, parent: Control, value: String, rect: Rect2, field: String, centered := false) -> Label:
	var display: String = view.display_text(value,field)
	var selected := font(view)
	for index in display.length():
		if display.unicode_at(index) not in [10,13,32] and not selected.has_char(display.unicode_at(index)):
			selected = view._presentation.font() if view._presentation != null else ThemeDB.fallback_font
			break
	var label := Label.new()
	# Configure wrapping before attaching text to the tree; otherwise a long
	# bitmap prompt can retain its initial single-line minimum width.
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = display; Sheet.ink(label,selected)
	label.add_theme_constant_override("line_spacing",0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = rect.position; label.size = rect.size
	parent.add_child(label)
	return label

static func button(view: RefCounted, parent: Control, id: String, label: String, rect: Rect2, callback: Callable, locked := false) -> Button:
	var result := Sheet.button(view,parent,id,label,rect,callback,locked)
	if not parent.get_meta("native_art",true):
		for state in ["normal","hover","pressed","disabled"]:
			var background := StyleBoxFlat.new(); background.bg_color = Color("454c48")
			result.add_theme_stylebox_override(state,background)
		for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
			result.add_theme_color_override(state,preload("res://scripts/ui/creation_popup.gd").TEXT_COLOR)
		result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if id == "apply-name": result.text = "OK"
	return result

static func click(view: RefCounted) -> void:
	view.shell.host.controller.providers.creation_art.play_dialog_click(view.shell.host)
