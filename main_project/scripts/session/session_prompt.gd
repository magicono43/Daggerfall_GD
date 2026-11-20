extends VBoxContainer
## Stock UI-005 prompt. The active LineEdit owns Godot's text/IME handling;
## composition never becomes a gameplay binding or an implicit owner commit.
var windows: SessionWindowStack
var layer: Dictionary
var resolve: Callable
var field: LineEdit
var reason: Label
var _composition := false
var _composition_end_frame := -1

func bind(stack: SessionWindowStack, opening: Dictionary, owner: Callable) -> void:
	windows = stack
	layer = opening.duplicate(true)
	resolve = owner
	var text := Label.new()
	text.text = str(layer.data.get("text", ""))
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(text)
	if layer.data.get("kind") == "text":
		field = LineEdit.new()
		field.text = layer.data.get("draft", "")
		add_child(field)
		field.text_changed.connect(func(value: String): windows.update_data(layer.id, {"draft": value}))
		field.text_submitted.connect(func(_text: String): submit("submit"))
		field.call_deferred("grab_focus")
	reason = Label.new()
	reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(reason)
	for response: String in layer.data.get("responses", []):
		var button := Button.new()
		button.text = str(layer.data.get("labels", {}).get(response, response.capitalize()))
		button.custom_minimum_size.y = 40
		button.pressed.connect(func(): submit(response))
		add_child(button)
		if response == layer.data.get("safe_response", ""):
			button.call_deferred("grab_focus")

func _process(_delta: float) -> void:
	if field == null or not field.has_focus() or DisplayServer.get_name() == "headless":
		return
	var composing := not DisplayServer.ime_get_text().is_empty()
	if _composition and not composing:
		_composition_end_frame = Engine.get_process_frames()
	_composition = composing

func submit(response: String) -> Dictionary:
	if field != null and (_composition or _composition_end_frame >= Engine.get_process_frames() - 1):
		return {"kind": "composition"}
	var checked := windows.respond(layer.id, response, func(choice: String, data: Dictionary) -> Dictionary:
		return resolve.call({"prompt": layer.id, "response": choice, "text": data.get("draft", "")}))
	if is_instance_valid(reason):
		reason.text = str(checked.get("reason", ""))
	return checked
