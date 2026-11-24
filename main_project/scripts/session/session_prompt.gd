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
var presentation: RefCounted
var heading: Label
var answers: Dictionary = {}
var last_layout: Dictionary = {}
var bound_context := -1

func bind(stack: SessionWindowStack, opening: Dictionary, owner: Callable, text_owner: RefCounted = null) -> void:
	windows = stack
	bound_context = windows.context_generation
	layer = opening.duplicate(true)
	resolve = owner
	presentation = text_owner
	var text := Label.new()
	heading = text
	text.text = str(layer.data.get("text", ""))
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.autowrap_trim_flags = 0
	add_child(text)
	if layer.data.get("kind") == "text":
		field = LineEdit.new()
		field.text = layer.data.get("draft", "")
		add_child(field)
		field.text_changed.connect(func(value: String): windows.update_data(layer.id, {"draft": value}))
		field.focus_entered.connect(func(): windows.remember_focus(layer.id,"input"))
		field.text_submitted.connect(func(_text: String): submit("submit"))
		call_deferred("focus_current",field)
	reason = Label.new()
	reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(reason)
	for response: String in layer.data.get("responses", []):
		var button := Button.new()
		button.text = str(layer.data.get("labels", {}).get(response, response.capitalize()))
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.clip_text = false
		button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		answers[response] = button
		button.custom_minimum_size.y = 40
		button.pressed.connect(func(): submit(response))
		button.focus_entered.connect(func(): windows.remember_focus(layer.id,response))
		add_child(button)
		if response == layer.data.get("safe_response", ""):
			call_deferred("focus_current",button)
	if presentation != null:
		var prepared := prepare_locale(presentation.locale)
		if prepared.ok:
			commit_locale(prepared)
		else:
			# Retain a readable blocked prompt rather than dropping required structure.
			heading.text = "Presentation unavailable. Cancel or return to recovery."
			for button: Button in answers.values():
				button.disabled = true
		presentation.bind_view(self)
	resized.connect(reflow)

func resolve_text(reference: Dictionary, fallback: String, selected: String) -> Dictionary:
	var text := fallback
	var context := {"window":layer.id,"scope":layer.scope}
	if not reference.is_empty():
		var result: Dictionary = presentation.lookup(reference.collection,reference.key,selected,reference.get("required_controls"))
		if not result.ok:
			return result
		context.merge({"collection":reference.collection,"key":reference.key,"source":result.source})
		# Unexpanded owner references and required classic controls must not flatten.
		text = ""
		for token: Dictionary in result.tokens:
			if token.kind == "text":
				text += token.text
			elif token.kind == "line_break":
				text += "\n"
			else:
				return {"ok":false,"kind":"unsupported_required_control"}
	var literal: Dictionary = presentation.literal(text,"body",selected,"",context)
	if not literal.diagnostics.is_empty():
		return {"ok":false,"kind":"essential_prompt_glyphs","diagnostics":literal.diagnostics}
	return {"ok":true,"literal":literal,"metrics":preload("res://scripts/session/text_layout.gd").measure(literal.text,literal.font,18,maxf(size.x,1.0))}

func prepare_locale(selected: String) -> Dictionary:
	var current := windows.top()
	if current.get("id") != layer.id or current.scope != layer.scope or windows.context_generation != bound_context or _composition:
		return {"ok":false,"kind":"stale_or_composing"}
	var title := resolve_text(layer.data.get("text_ref",{}),layer.data.get("text",""),selected)
	if not title.ok:
		return title
	var labels := {}
	for response: String in answers:
		var label := resolve_text(layer.data.get("label_refs",{}).get(response,{}),layer.data.get("labels",{}).get(response,response.capitalize()),selected)
		if not label.ok:
			return label
		labels[response] = label
	return {"ok":true,"window":layer.id,"scope":layer.scope,"context":windows.context_generation,"title":title,"labels":labels,"locale":selected}

func locale_plan_current(plan: Dictionary) -> bool:
	return is_inside_tree() and windows.top().get("id") == plan.window and windows.top().scope == plan.scope and windows.context_generation == plan.context and plan.context == bound_context

func commit_locale(plan: Dictionary) -> void:
	# No focus, draft, owner, answer or window mutations. Existing controls survive.
	heading.text = plan.title.literal.text
	heading.add_theme_font_override("font",plan.title.literal.font)
	heading.add_theme_font_size_override("font_size",18)
	for response: String in answers:
		answers[response].text = plan.labels[response].literal.text
		answers[response].add_theme_font_override("font",plan.labels[response].literal.font)
		answers[response].add_theme_font_size_override("font_size",18)
	if field != null:
		field.add_theme_font_override("font",presentation.font("body",plan.locale))
	last_layout = plan

func reflow() -> void:
	if presentation != null and is_inside_tree():
		var prepared := prepare_locale(presentation.locale)
		if prepared.ok:
			commit_locale(prepared)

func _exit_tree() -> void:
	if presentation != null:
		presentation.unbind_view(self)

func focus_current(target: Control) -> void:
	if is_inside_tree() and target.is_inside_tree() and windows.top().get("id") == layer.id:
		target.grab_focus()

func _process(_delta: float) -> void:
	if not is_instance_valid(field) or not field.has_focus() or DisplayServer.get_name() == "headless":
		return
	# Control focus survives native window focus loss. On Windows, polling IME
	# with no focused native window can hit the backend's invalid-window lookup.
	# Retain composition state until this prompt's own window regains focus.
	if not get_window().has_focus():
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
