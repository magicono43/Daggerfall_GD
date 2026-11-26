extends RefCounted
## Stock creation controls. Rebuilt controls carry an exact UI/CHAR context;
## rebuilding for locale/focus never creates choices, rolls or actor mutations.
const Draft = preload("res://scripts/char/creation_draft.gd")
var owner: RefCounted
var navigation := preload("res://scripts/char/creation_navigation.gd").new()
var inputs: RefCounted
var shell: RefCounted
var layer := ""
var _layer_scope := ""
var _submission_failed := false
var notice := ""
var controlled := false
var _working: Dictionary = {}
var _buttons: Dictionary = {}
var _focus := ""
var _page: Control
var _capture: Dictionary = {}
var _render_generation := 0
var _presentation: RefCounted
var _keyboard_down: Dictionary = {}

func _init(session_shell: RefCounted) -> void:
	shell = session_shell
	owner = shell.core.creation
	shell.core.retiring.connect(_retire)
	shell.core.terminal.connect(_terminal)

func active() -> bool:
	return navigation.active()

func route_keyboard(event: InputEvent) -> bool:
	if not event is InputEventKey or event.keycode not in [KEY_ENTER,KEY_KP_ENTER,KEY_SPACE]: return false
	var identity: int = event.keycode
	if not event.pressed:
		_keyboard_down.erase(identity)
		return false
	if _keyboard_down.has(identity): return true
	if not active() or not shell.host.get_viewport().gui_get_focus_owner() is Button: return false
	if event.echo: return true
	_keyboard_down[identity] = true
	return false # First fresh GUI press; page/exit retains quarantine until release.

func open(provider: RefCounted = null) -> Dictionary:
	if active() or shell.core.busy() or shell.host.controller.route != "main_menu": return Draft.failure("busy","Creation cannot open in this context.")
	var definitions: RefCounted = shell.host.controller.providers.definitions
	if _presentation == null and shell.host.controller.providers.presentation != null:
		_presentation = shell.host.controller.providers.presentation
		_presentation.changed.connect(_locale_changed)
	var read: Dictionary = definitions.query("char.creation","flows","stock")
	if not read.ok: return read
	controlled = provider != null
	inputs = provider
	if inputs == null:
		inputs = preload("res://scripts/char/creation_inputs.gd").new()
		inputs.definitions = definitions
		inputs.content = definitions.content_ticket()
		inputs.options = read.record.value.choices.duplicate(true)
	var checked: Dictionary = owner.bind(definitions.content_ticket(),inputs.bindings())
	if not checked.ok: return checked
	checked = navigation.bind(owner,read.record)
	if not checked.ok: return checked
	checked = navigation.start()
	if not checked.ok: return checked
	var opened: Dictionary = shell.windows.open("creation",shell.core.snapshot().session,{"cursor":"visible"})
	if opened.kind != "applied": navigation.discard(); return Draft.failure("window","Creation window could not open.")
	layer = opened.id
	_layer_scope = shell.core.snapshot().session
	_submission_failed = false
	_capture.clear()
	notice = ""
	_focus = ""
	shell.schedule_render()
	return {"ok":true}

func exit() -> void:
	navigation.discard()
	_working.clear()
	_capture.clear()
	_render_generation += 1
	if not layer.is_empty(): shell.windows.retire_layer(layer,_layer_scope)
	layer = ""
	shell.schedule_render()

func restart() -> void:
	if not active(): return
	_working.clear()
	_capture.clear()
	_submission_failed = false
	notice = ""
	_focus = ""
	navigation.start()
	shell.schedule_render()

func action(id: String, expected: Dictionary, value: Variant = null) -> Dictionary:
	if not active() or shell.windows.top().get("id") != layer or not Draft.same_value(expected,navigation.context()) or shell.core.busy(): return Draft.failure("stale","Creation input context retired.")
	var checked: Dictionary
	match id:
		"edit": checked = navigation.edit(expected,value)
		"next": checked = navigation.next(expected)
		"back": checked = navigation.back(expected)
		"summary-edit": checked = navigation.summary_edit(expected,str(value))
		"restart": restart(); return {"ok":true}
		"exit": exit(); return {"ok":true}
		"begin":
			checked = navigation.capture(expected)
			if checked.ok:
				_capture = checked.capture.duplicate(true)
				checked = owner.submit(shell.core,_capture)
				checked.ok = checked.get("kind") in ["pending","Succeeded"]
		"retry":
			checked = owner.retry(shell.core,_capture)
			checked.ok = checked.get("kind") in ["pending","Succeeded"]
		_: return Draft.failure("action","Unsupported creation action.")
	notice = "" if checked.ok else str(checked.get("reason","Creation request rejected."))
	if checked.has("sections"): notice += "\n"+str(checked.sections)
	if checked.ok and id in ["edit","next","back","summary-edit"]:
		# A page/selection handoff is a real input boundary, with the existing
		# fresh-press quarantine. Keep the same requester-owned gate and scope.
		shell.windows.replace(layer,"creation",func(_old: Dictionary): return {"ok":true,"data":{"cursor":"visible"}})
	shell.schedule_render()
	return checked

func render() -> void:
	_render_generation += 1
	_buttons.clear()
	var host: Control = shell.host
	var expected: Dictionary = navigation.context()
	var current: Dictionary = navigation.step()
	var hook: String = current.hook
	host.label(translated("step."+navigation.step_id(),current.title),26)
	if controlled: host.label("CONTROLLED CREATION REVIEW · assigned inputs · no playable entry or grants",15)
	else: host.label("Creation draft · required choice mechanics and playable entry are still being implemented.",15)
	var art: Dictionary = {"ok":false}
	var resolver: RefCounted = host.controller.providers.creation_art
	if resolver != null: art = resolver.resolve(current.art)
	# Native 320×200 layout at a readable 2× scale. The ordinary shell scrolls on
	# smaller windows. Coordinates position controls only, never select/validate.
	_page = Control.new()
	_page.custom_minimum_size = Vector2(640,400)
	_page.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	host.panel.add_child(_page)
	if art.ok:
		var background := TextureRect.new()
		background.texture = art.texture
		background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.size = Vector2(640,400)
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_page.add_child(background)
	else:
		var background := ColorRect.new()
		background.color = Color("252c29")
		background.size = Vector2(640,400)
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_page.add_child(background)
	var selected: Dictionary = owner.projection().selections
	if hook == "summary":
		_summary(expected,selected)
	elif hook == "name":
		var field := LineEdit.new()
		field.text = str(_working.get(hook,selected.get(hook,"")))
		field.placeholder_text = "Enter name"
		field.position = Vector2(150,0)
		field.size = Vector2(480,32)
		_page.add_child(field)
		field.text_changed.connect(func(value: String): _working[hook] = value)
		field.focus_entered.connect(func(): _focus = "name-field")
		var generation := _render_generation
		field.text_submitted.connect(func(value: String):
			if generation == _render_generation: action("edit",expected,value))
		_button("apply-name","Use name",Rect2(158,344,320,46),func(): action("edit",expected,field.text))
		if _focus == "name-field": call_deferred("_focus_control",field,_render_generation)
	else:
		var choices: Array = inputs.choices(hook)
		if choices.is_empty():
			var box := _box(Rect2(90,92,450,196))
			_text(box,"Required "+hook+" mechanics are unavailable in this build. Your draft is retained; choose Back, Restart or Exit.")
		else:
			var area := Rect2(96,72,448,264)
			if hook == "reflexes": area = Rect2(370,208,246,142)
			var box := _box(area)
			var scroll := ScrollContainer.new()
			scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			box.add_child(scroll)
			var list := VBoxContainer.new()
			list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			scroll.add_child(list)
			for choice: Dictionary in choices:
				var button := Button.new()
				button.text = translated("choice."+hook+"."+str(choice.id),str(choice.label)) if choice.id is String else str(choice.label)
				button.toggle_mode = true
				button.disabled = navigation.summary_locked()
				button.button_pressed = Draft.same_value(selected.get(hook),choice.get("value",choice.id))
				button.custom_minimum_size.y = 36
				button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				list.add_child(button)
				_bind_button(button,"choice/"+str(choice.id),func(): action("edit",expected,choice.get("value",choice.id)))
			if hook in ["attributes","skills"] and selected.get(hook) is Dictionary:
				var values: Dictionary = selected[hook]
				var detail := ""
				for key in values.get("base",{}): detail += str(key).capitalize()+": "+str(values.base[key])+" + "+str(values.get("allocated",{}).get(key,0))+" assigned\n"
				detail += "Unspent points: "+str(values.get("remaining","unavailable"))
				_text(list,detail)
		if hook == "attributes": _text(_box(Rect2(512,294,118,46)),"Rolls pending")
		if hook == "face": _text(_box(Rect2(548,16,88,106)),"Portraits pending")
	# Classic OK region; labels are actual localizable controls, never image hits.
	if hook != "summary": _button("next","Next",Rect2(526,344,100,46),func(): action("next",expected))
	else: _button("begin","Begin Game",Rect2(500,344,130,46),func(): action("begin",expected))
	if hook == "summary": _button("restart","Restart",Rect2(500,294,130,46),func(): action("restart",expected))
	var row := HBoxContainer.new()
	host.panel.add_child(row)
	for entry in [["back","Back"],["restart","Restart"],["exit","Exit creation"]]:
		if hook == "summary" and entry[0] == "restart": continue
		var button := Button.new()
		button.text = translated("action."+entry[0],entry[1])
		button.custom_minimum_size = Vector2(140,40)
		row.add_child(button)
		_bind_button(button,entry[0],func(): action(entry[0],expected))
	if _submission_failed:
		var retry := Button.new()
		retry.text = translated("action.retry","Retry Begin Game")
		retry.custom_minimum_size = Vector2(180,40)
		row.add_child(retry)
		_bind_button(retry,"retry",func(): action("retry",expected))
	if not notice.is_empty(): host.label(notice)
	if navigation.summary_locked(): host.label("Restart to change this selection after final review.")
	if not art.ok and not current.art.is_empty(): host.label("Optional interface artwork unavailable; using the readable fallback.",15)
	var focus: Button = _buttons.get(_focus,_buttons.get("back"))
	if focus != null and _focus != "name-field": call_deferred("_focus_control",focus,_render_generation)

func _focus_control(control: Control, generation: int) -> void:
	if generation == _render_generation and is_instance_valid(control) and control.is_inside_tree(): control.grab_focus()

func _summary(expected: Dictionary, selected: Dictionary) -> void:
	var identity := _box(Rect2(8,0,624,38))
	_text(identity,str(selected.get("name","Name incomplete")))
	var facts := _box(Rect2(8,42,474,300))
	var text := ""
	for section in ["race","gender","class","custom","biography","attributes","skills"]:
		if not selected.has(section): continue
		var value: Variant = selected[section]
		if section in ["attributes","skills"] and value is Dictionary:
			text += section.capitalize()+"\n"
			for key in value.get("base",{}): text += "  "+str(key).capitalize()+": "+str(value.base[key])+" + "+str(value.get("allocated",{}).get(key,0))+" assigned\n"
			text += "Unspent points: "+str(value.get("remaining","unavailable"))+"\n"
		elif section == "biography" and value is Dictionary:
			text += "Biography\n"
			for question in value.get("answers",{}): text += "  "+str(question).capitalize()+": "+str(value.answers[question])+"\n"
			for effect: Dictionary in value.get("known_effects",[]): text += "Known effect: "+str(effect.get("target",""))+" "+str(effect.get("value",""))+" (candidate; applied at entry)\n"
		elif section == "custom" and value is Dictionary:
			text += "Custom career: "+str(value.get("name","Incomplete"))+"\n"
			for tier in value.get("tiers",{}): text += str(tier).capitalize()+" skills: "+", ".join(value.tiers[tier])+"\n"
			text += "Advantages: "+str(value.get("advantages",[]))+"\nDisadvantages: "+str(value.get("disadvantages",[]))+"\nHP per level: "+str(value.get("hit_points_per_level","Incomplete"))+"\n"
		else:
			var label := str(value)
			for choice: Dictionary in inputs.choices(section):
				if Draft.same_value(choice.get("value",choice.id),value): label = str(choice.label); break
			text += section.capitalize()+": "+label+"\n"
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	facts.add_child(scroll)
	var label := Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",16)
	scroll.add_child(label)
	var index := 0
	for section in Draft.SUMMARY_EDITORS:
		_button("edit/"+section,section.capitalize(),Rect2(488,42+index*51,144,46),func(): action("summary-edit",expected,section))
		index += 1

func _box(rect: Rect2) -> PanelContainer:
	var box := PanelContainer.new()
	box.position = rect.position
	box.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09,0.11,0.10,1.0)
	style.border_color = Color("ab925c")
	style.set_border_width_all(1)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	box.add_theme_stylebox_override("panel",style)
	_page.add_child(box)
	return box

func _text(parent: Control, value: String) -> void:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",16)
	parent.add_child(label)

func _button(id: String, text: String, rect: Rect2, callback: Callable) -> void:
	var button := Button.new()
	button.text = translated("action."+id,text)
	button.position = rect.position
	button.size = rect.size
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_page.add_child(button)
	_bind_button(button,id,callback)

func _bind_button(button: Button, id: String, callback: Callable) -> void:
	_buttons[id] = button
	button.set_meta("creation_action",id)
	button.set_meta("font_role","body")
	if _presentation != null: button.add_theme_font_override("font",_presentation.font("body"))
	# Solid interactive surfaces mask the image's baked English labels. Geometry
	# and focus are still real controls; texture pixels never define actions.
	for state in ["normal","hover","pressed","focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color.TRANSPARENT if state == "focus" else Color("4b493b") if state == "hover" else Color("20261f") if state == "pressed" else Color("30362e")
		style.border_color = Color("ffe6a1") if state == "focus" else Color("a08a58")
		style.set_border_width_all(3 if state == "focus" else 1)
		style.content_margin_left = 6
		style.content_margin_right = 6
		button.add_theme_stylebox_override(state,style)
	var generation := _render_generation
	button.pressed.connect(func():
		if generation == _render_generation: callback.call())
	button.focus_entered.connect(func(): _focus = id)

func dispose() -> void:
	navigation.discard()
	if shell.core.retiring.is_connected(_retire): shell.core.retiring.disconnect(_retire)
	if shell.core.terminal.is_connected(_terminal): shell.core.terminal.disconnect(_terminal)
	if _presentation != null and _presentation.changed.is_connected(_locale_changed): _presentation.changed.disconnect(_locale_changed)
	_presentation = null
	inputs = null
	shell = null

func translated(key: String, fallback: String) -> String:
	if _presentation == null: return fallback
	var catalog = preload("res://scripts/data/text_catalog.gd")
	var read: Dictionary = catalog.lookup(shell.host.controller.providers.definitions,"creation",key,_presentation.locale)
	return catalog.essential_literal(read,key) if read.ok else fallback

func _locale_changed() -> void:
	if active(): shell.schedule_render()

func _retire(scope: String) -> void:
	if active() and scope == _layer_scope: exit()

func _terminal(result: Dictionary) -> void:
	if _capture.is_empty() or (result.get("id") != _capture.id and not str(result.get("id","")).begins_with(_capture.id+"/retry-")): return
	_submission_failed = result.kind == "Failed"
	if result.kind == "Succeeded": exit()
	elif active():
		notice = str(result.get("reason",""))
		shell.schedule_render()
