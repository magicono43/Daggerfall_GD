extends LineEdit
## Preserve raw clipboard input until shared validation; native LineEdit paste
## removes line breaks, which would otherwise silently accept different text.
signal rejected(reason: String)
const Policy = preload("res://scripts/ui/character_name.gd")
var _context: PopupMenu
var _composition := false
var _composition_end_frame := -100

func composition_owned() -> bool:
	return _composition or _composition_end_frame >= Engine.get_process_frames()-1

func _process(_delta: float) -> void:
	if not has_focus() or DisplayServer.get_name() == "headless" or not get_window().has_focus(): return
	var composing := not DisplayServer.ime_get_text().is_empty()
	if _composition and not composing: _composition_end_frame = Engine.get_process_frames()
	_composition = composing

func _ready() -> void:
	max_length = 0 # The owner limits graphemes; never truncate native input.
	context_menu_enabled = false
	shortcut_keys_enabled = false
	_context = PopupMenu.new()
	add_child(_context)
	for item in ["Copy","Cut","Paste","Select all"]: _context.add_item(item)
	_context.id_pressed.connect(_menu_action)

func _menu_action(id: int) -> void:
	match id:
		0: menu_option(MENU_COPY)
		1: menu_option(MENU_CUT)
		2: paste_candidate(DisplayServer.clipboard_get())
		3: select_all()

func paste_candidate(raw: String) -> Dictionary:
	var candidate := text
	var position := caret_column
	if has_selection():
		position = get_selection_from_column()
		candidate = candidate.substr(0,position)+candidate.substr(get_selection_to_column())
	candidate = candidate.insert(position,raw)
	var checked := Policy.validate(candidate)
	if not checked.ok:
		rejected.emit(checked.reason)
		return checked
	if has_selection(): delete_text(get_selection_from_column(),get_selection_to_column())
	deselect()
	caret_column = position
	insert_text_at_caret(raw)
	return checked

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_context.position = Vector2i(get_global_mouse_position())
		_context.popup()
		accept_event()
		return
	if not event is InputEventKey or not event.pressed: return
	if event.is_action_pressed("ui_paste"):
		paste_candidate(DisplayServer.clipboard_get()); accept_event()
	elif event.is_action_pressed("ui_copy"):
		menu_option(MENU_COPY); accept_event()
	elif event.is_action_pressed("ui_cut"):
		menu_option(MENU_CUT); accept_event()
	elif event.is_action_pressed("ui_text_select_all"):
		select_all(); accept_event()
	elif event.is_action_pressed("ui_undo"):
		menu_option(MENU_UNDO); accept_event()
	elif event.is_action_pressed("ui_redo"):
		menu_option(MENU_REDO); accept_event()
