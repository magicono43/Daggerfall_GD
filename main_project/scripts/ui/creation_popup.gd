extends RefCounted
## Classic native-pixel message surface; real Buttons retain stock dispatch/focus.
const TEXT_COLOR = Color8(243,239,44)
const SHADOW_COLOR = Color8(93,77,12)

static func confirm(view: RefCounted, text: String, yes: Callable, no: Callable, valid: bool) -> void:
	choices(view,text,[["confirm/yes","Yes",yes,"yes",not valid],["confirm/no","No",no,"no",false]],"race-confirmation")

static func choices(view: RefCounted, text: String, options: Array, field: String) -> Panel:
	var art: RefCounted = view.shell.host.controller.providers.creation_art
	var fallback: Font = view._presentation.font() if view._presentation != null else ThemeDB.fallback_font
	var font: Font = art.popup_font(fallback) if art != null else fallback
	if view._presentation != null: font = view._presentation.creation_popup_font(font)
	var label := Label.new()
	label.text = view.display_text(text,field)
	# Classic ASCII metrics stay seven pixels high. A whole-prompt locale-font
	# recovery avoids enlarging every ASCII row merely by attaching a taller font.
	for index in label.text.length():
		if label.text.unicode_at(index) not in [9,10,13,32] and not font.has_char(label.text.unicode_at(index)):
			font = fallback
			break
	label.add_theme_font_override("font",font)
	label.add_theme_font_size_override("font_size",7)
	label.add_theme_constant_override("line_spacing",0)
	label.add_theme_color_override("font_color",TEXT_COLOR)
	label.add_theme_color_override("font_shadow_color",SHADOW_COLOR)
	label.add_theme_constant_override("shadow_offset_x",1)
	label.add_theme_constant_override("shadow_offset_y",1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	label.set_meta("creation_popup_text",true)
	var natural := font.get_multiline_string_size(label.text,HORIZONTAL_ALIGNMENT_CENTER,-1,7)
	var width := clampf(ceilf((natural.x+20)/22)*22,132,308)
	var paragraph := TextParagraph.new()
	paragraph.add_string(label.text,font,7)
	paragraph.width = width-20
	# Label reserves the font's fallback-aware line height even for all-ASCII text.
	# Account for that too; TextParagraph alone can undercount a bitmap font row.
	var text_height := maxf(font.get_height(7)*paragraph.get_line_count(),paragraph.get_size().y)
	var height := minf(176,ceilf((text_height+20+(0 if options.is_empty() else 20))/22)*22)
	var root := Panel.new()
	root.set_meta("creation_popup",true)
	root.position = ((Vector2(640,400)-Vector2(width,height)*2)/2).floor()
	root.size = Vector2(width,height)
	root.scale = Vector2(2,2)
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var parchment: StyleBox = art.parchment_style() if art != null else null
	if parchment == null:
		var plain := StyleBoxFlat.new(); plain.bg_color = Color("957044"); parchment = plain
	root.add_theme_stylebox_override("panel",parchment)
	view._page.add_child(root)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(10,10)
	scroll.size = Vector2(width-20,height-(20 if options.is_empty() else 40))
	if field == "gender-confirmation":
		# Center the short prompt/button group, as in the classic gender popup.
		scroll.size.y = minf(scroll.size.y,text_height+2)
		scroll.position.y = ceilf((height-scroll.size.y-20)/2)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	root.add_child(scroll)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(label)
	if options.is_empty():
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for index in options.size():
		var item: Array = options[index]
		var button := Button.new()
		button.text = item[1]
		button.tooltip_text = item[1]
		button.position = Vector2(floorf(width/2)-48+index*64,height-32)
		if field == "gender-confirmation": button.position.y = scroll.position.y+scroll.size.y+4
		button.size = Vector2(32,16)
		root.add_child(button)
		var expected: Dictionary = view.navigation.context()
		var callback: Callable = item[2]
		view._bind_button(button,item[0],func():
			if button.disabled or view.shell.core.busy() or not view.active() or not preload("res://scripts/char/creation_draft.gd").same_value(expected,view.navigation.context()): return
			if art != null: art.play_dialog_click(view.shell.host)
			callback.call())
		button.disabled = view.navigation.summary_locked() or item[4]
		button.set_meta("accessible_label",item[1])
		var sprite: Dictionary = art.resolve("creation.dialog."+item[3]) if art != null else {"ok":false}
		if sprite.ok:
			# Keep the semantic Button label for accessibility; pixels carry the ink.
			button.add_theme_font_size_override("font_size",7)
			for color in ["font_color","font_hover_color","font_pressed_color","font_disabled_color","font_focus_color"]: button.add_theme_color_override(color,Color.TRANSPARENT)
			for state in ["normal","hover","pressed","disabled"]:
				var style := StyleBoxTexture.new()
				style.texture = sprite.texture
				button.add_theme_stylebox_override(state,style)
			var focus := StyleBoxFlat.new()
			focus.bg_color = Color.TRANSPARENT
			focus.border_color = TEXT_COLOR
			focus.set_border_width_all(1)
			button.add_theme_stylebox_override("focus",focus)
			button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		else:
			button.add_theme_font_override("font",fallback)
			button.add_theme_font_size_override("font_size",7)
			button.add_theme_color_override("font_color",TEXT_COLOR)
		# Initial stock styles can enlarge a Control before our sprite style binds.
		button.size = Vector2(32,16)
	return root

static func notice(view: RefCounted, text: String, dismiss: Callable, field := "message") -> void:
	var catch_click := Button.new()
	view._page.add_child(catch_click)
	view._bind_button(catch_click,"notice/dismiss",dismiss)
	catch_click.set_meta("accessible_label","Dismiss message")
	for state in ["normal","hover","pressed","disabled","focus"]: catch_click.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	catch_click.size = Vector2(640,400)
	var root := choices(view,text,[],field)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Control in root.find_children("*","Control",true,false): child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view._focus = "notice/dismiss"
