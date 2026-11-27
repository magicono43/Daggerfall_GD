extends Control
## Presentation-only picker. Selection is local; activation is a separate intent.
signal item_selected(index: int)
signal item_activated(index: int)
signal scrolled(index: int)
const NORMAL = Color8(243,239,44)
const HOVER = Color8(255,130,40)
const SELECTED = Color8(162,36,12)
const SELECTED_HOVER = Color8(254,56,18)
const ROWS = 9
var buttons: Array[Button] = []
var selected := -1
var scroll_index := 0
var _body: Control
var _bar: VScrollBar

func configure(labels: Array, font: Font, image: Texture2D, locked: bool, initial := -1, first := 0, thumb: Texture2D = null) -> void:
	size = Vector2(200,128)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if image != null:
		var background := TextureRect.new()
		background.texture = image
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.size = size
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(background)
	else:
		var background := ColorRect.new(); background.color = Color("bf9968"); background.size = size
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(background)
	var clip := Control.new()
	clip.position = Vector2(26,27); clip.size = Vector2(138,72); clip.clip_contents = true
	add_child(clip)
	_body = Control.new(); _body.size = Vector2(138,labels.size()*8); clip.add_child(_body)
	for index in labels.size():
		var button := Button.new()
		button.text = labels[index]
		button.clip_text = true
		button.tooltip_text = labels[index]
		button.set_meta("accessible_label",labels[index])
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.toggle_mode = true
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.disabled = locked
		button.add_theme_font_override("font",font)
		button.add_theme_font_size_override("font_size",7)
		button.add_theme_color_override("font_color",NORMAL)
		button.add_theme_color_override("font_hover_color",HOVER)
		button.add_theme_color_override("font_pressed_color",SELECTED)
		button.add_theme_color_override("font_hover_pressed_color",SELECTED_HOVER)
		button.add_theme_color_override("font_focus_color",NORMAL)
		button.add_theme_color_override("font_shadow_color",Color8(93,77,12))
		button.add_theme_constant_override("shadow_offset_x",1)
		button.add_theme_constant_override("shadow_offset_y",1)
		for state in ["normal","hover","pressed","disabled","focus"]: button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		_body.add_child(button)
		button.position = Vector2(0,index*8); button.size = Vector2(138,8)
		buttons.append(button)
		button.pressed.connect(func(): select_item(index))
		button.gui_input.connect(func(event: InputEvent):
			if button.disabled: return
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and event.double_click:
				select_item(index); item_activated.emit(index); button.accept_event()
			elif event is InputEventKey and event.pressed and not event.echo:
				if event.is_action("ui_accept"):
					select_item(index); item_activated.emit(index); button.accept_event()
				elif event.keycode in [KEY_UP,KEY_DOWN,KEY_HOME,KEY_END,KEY_PAGEUP,KEY_PAGEDOWN]:
					var next := index-1 if event.keycode == KEY_UP else index+1
					if event.keycode == KEY_HOME: next = 0
					elif event.keycode == KEY_END: next = buttons.size()-1
					elif event.keycode == KEY_PAGEUP: next = index-ROWS
					elif event.keycode == KEY_PAGEDOWN: next = index+ROWS
					select_item(clampi(next,0,buttons.size()-1),true); button.accept_event())
	_bar = VScrollBar.new()
	_bar.position = Vector2(181,23); _bar.size = Vector2(5,82)
	_bar.min_value = 0; _bar.max_value = maxi(ROWS,labels.size()); _bar.page = ROWS; _bar.step = 1
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE if locked else Control.MOUSE_FILTER_STOP
	var empty_icon := ImageTexture.create_from_image(Image.create(1,1,false,Image.FORMAT_RGBA8))
	for icon in ["increment","increment_highlight","increment_pressed","decrement","decrement_highlight","decrement_pressed"]: _bar.add_theme_icon_override(icon,empty_icon)
	for state in ["scroll","scroll_focus"]: _bar.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	for state in ["grabber","grabber_highlight","grabber_pressed"]:
		var style := StyleBoxFlat.new(); style.bg_color = Color8(190,190,185)
		style.border_color = Color8(225,225,213); style.set_border_width_all(1)
		_bar.add_theme_stylebox_override(state,style)
		if thumb != null:
			var sliced := StyleBoxTexture.new()
			sliced.texture = thumb
			sliced.texture_margin_top = 1; sliced.texture_margin_bottom = 1
			_bar.add_theme_stylebox_override(state,sliced)
	add_child(_bar)
	# Adding an unthemed Control may already have expanded it to stock minimums.
	_bar.size = Vector2(5,82)
	_bar.value_changed.connect(func(value: float): set_scroll(int(value)))
	for direction in [-1,1]:
		var arrow := Button.new(); arrow.disabled = locked
		for state in ["normal","hover","pressed","disabled","focus"]: arrow.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		add_child(arrow); arrow.position = Vector2(179,10 if direction < 0 else 108); arrow.size = Vector2(9,9)
		arrow.tooltip_text = "Previous item" if direction < 0 else "Next item"
		arrow.pressed.connect(func(): select_item(clampi(selected+direction,0,buttons.size()-1),true))
	gui_input.connect(func(event: InputEvent):
		if not locked and event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			set_scroll(scroll_index+(-1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1)); accept_event())
	set_scroll(first)
	if initial >= 0 and initial < buttons.size():
		selected = initial
		buttons[initial].set_pressed_no_signal(true)

func set_scroll(index: int) -> void:
	scroll_index = clampi(index,0,maxi(0,buttons.size()-ROWS))
	_body.position.y = -scroll_index*8
	if _bar != null: _bar.set_value_no_signal(scroll_index)
	scrolled.emit(scroll_index)

func select_item(index: int, focus := false) -> void:
	if index < 0 or index >= buttons.size() or buttons[index].disabled: return
	selected = index
	for row in buttons.size(): buttons[row].set_pressed_no_signal(row == index)
	if index < scroll_index: set_scroll(index)
	elif index >= scroll_index+ROWS: set_scroll(index-ROWS+1)
	if focus: buttons[index].grab_focus()
	item_selected.emit(index)
