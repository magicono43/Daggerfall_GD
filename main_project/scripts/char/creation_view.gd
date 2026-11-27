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
var _editors: Dictionary = {}
var glyph_diagnostics: Array = []
var _focus := ""
var _page: Control
var _page_frame: Control
var _last_render_page := ""
var _summary_tab := 0
var _capture: Dictionary = {}
var _render_generation := 0
var _presentation: RefCounted
var _keyboard_down: Dictionary = {}
var career_view := preload("res://scripts/char/creation_career_view.gd").new()
var starting_view := preload("res://scripts/char/creation_starting_view.gd").new()
var biography_view := preload("res://scripts/char/creation_biography_view.gd").new()
var identity_view := preload("res://scripts/char/creation_identity_view.gd").new()

func _init(session_shell: RefCounted) -> void:
	shell = session_shell
	owner = shell.core.creation
	shell.core.retiring.connect(_retire)
	shell.core.terminal.connect(_terminal)
	shell.host.resized.connect(_viewport_resized)
	shell.host.get_window().size_changed.connect(_viewport_resized)

func ui_pixel_ratio() -> float:
	# Canvas stretch can keep a larger logical reference width after the native
	# window shrinks. Fit the classic page in physical pixels, not that reference.
	return maxf(0.1,float(shell.host.get_window().size.x)/maxf(1.0,shell.host.get_viewport_rect().size.x))

func active() -> bool:
	return navigation.active()

func cancel_nested() -> bool:
	if not active() or shell.core.busy() or not inputs.has_method("validate_career"): return false
	if career_view.reputation_warning:
		career_view.reputation_warning = false
		career_view.refresh(self)
		return true
	if not navigation.summary_locked() and navigation.step().get("hook") == "biography":
		action("back",navigation.context())
		return true
	if not career_view.skill_slot.is_empty():
		career_view.skill_slot.clear()
		career_view.refresh(self)
		return true
	if not career_view.candidate.is_empty():
		career_view.candidate = ""
		career_view.refresh(self)
		return true
	if not navigation.summary_locked() and navigation.step().get("hook") == "class" and owner.projection().selections.get("class_method") == "questionnaire":
		action("career-route",navigation.context(),"list")
		return true
	if navigation.step().get("hook") == "custom" and career_view.custom_tab == 3:
		preload("res://scripts/ui/creation_reputation.gd").request_close(career_view,self)
		return true
	if navigation.step().get("hook") == "custom" and career_view.custom_tab != 0:
		career_view.custom_tab = 0
		career_view.refresh(self)
		return true
	return false

func route_keyboard(event: InputEvent) -> bool:
	if not event is InputEventKey or event.keycode not in [KEY_ENTER,KEY_KP_ENTER,KEY_SPACE,KEY_ESCAPE]: return false
	var identity: int = event.keycode
	if not event.pressed:
		_keyboard_down.erase(identity)
		return false
	if _keyboard_down.has(identity): return true
	var focused: Control = shell.host.get_viewport().gui_get_focus_owner()
	if focused != null and focused.has_method("composition_owned") and focused.composition_owned():
		_keyboard_down[identity] = true
		return true # IME confirmation/cancellation cannot submit or discard.
	if event.keycode == KEY_ESCAPE:
		if not active() or shell.windows.top().get("window") != "creation": return false
		if event.echo: return true
		_keyboard_down[identity] = true
		shell.options()
		return true
	if not active() or not shell.host.get_viewport().gui_get_focus_owner() is Button: return false
	if event.echo: return true
	_keyboard_down[identity] = true
	return false # First fresh GUI press; page/exit retains quarantine until release.

func observe_release(event: InputEvent) -> void:
	if event is InputEventKey and not event.pressed: _keyboard_down.erase(int(event.keycode))

func open(provider: RefCounted = null) -> Dictionary:
	if active() or shell.core.busy() or shell.host.controller.route != "main_menu": return Draft.failure("busy","Creation cannot open in this context.")
	var definitions: RefCounted = shell.host.controller.providers.definitions
	if _presentation == null and shell.host.controller.providers.presentation != null:
		_presentation = shell.host.controller.providers.presentation
		_presentation.changed.connect(_locale_changed)
	var read: Dictionary = definitions.query("char.creation","flows","stock")
	if not read.ok: return read
	controlled = provider != null
	var preparation_error := ""
	inputs = provider
	if inputs == null:
		inputs = preload("res://scripts/char/creation_identity_inputs.gd").new()
		inputs.art = shell.host.controller.providers.creation_art
		inputs.definitions = definitions
		inputs.content = definitions.content_ticket()
		inputs.options = read.record.value.choices.duplicate(true)
		var prepared: Dictionary = inputs.prepare()
		if not prepared.ok: preparation_error = prepared.get("reason","Required creation content is unavailable.")
	if inputs.has_method("bind_preview"): inputs.bind_preview(owner,shell.core)
	var checked: Dictionary = owner.bind(definitions.content_ticket(),inputs.bindings())
	if not checked.ok: return checked
	checked = navigation.bind(owner,read.record)
	if not checked.ok: return checked
	checked = navigation.start()
	if not checked.ok: return checked
	if inputs.has_method("initialize_draft"):
		var defaults: Dictionary = inputs.initialize_draft(owner)
		if not defaults.ok: preparation_error = defaults.get("reason","Fresh creation defaults unavailable.")
	_working.clear()
	_summary_tab = 0
	glyph_diagnostics.clear()
	var opened: Dictionary = shell.windows.open("creation",shell.core.snapshot().session,{"cursor":"visible"})
	if opened.kind != "applied": navigation.discard(); return Draft.failure("window","Creation window could not open.")
	layer = opened.id
	_layer_scope = shell.core.snapshot().session
	_submission_failed = false
	shell.message = ""
	_capture.clear()
	notice = preparation_error
	_focus = ""
	shell.schedule_render()
	return {"ok":true}

func exit() -> void:
	career_view.clear()
	navigation.discard()
	_working.clear()
	glyph_diagnostics.clear()
	_capture.clear()
	_render_generation += 1
	if not layer.is_empty(): shell.windows.retire_layer(layer,_layer_scope)
	layer = ""
	shell.schedule_render()

func restart() -> void:
	if not active(): return
	career_view.clear()
	_working.clear()
	_summary_tab = 0
	glyph_diagnostics.clear()
	_capture.clear()
	_submission_failed = false
	notice = ""
	_focus = ""
	navigation.start()
	if inputs.has_method("initialize_draft"):
		var defaults: Dictionary = inputs.initialize_draft(owner)
		if not defaults.ok: notice = defaults.get("reason","Fresh creation defaults unavailable.")
	shell.schedule_render()

func action(id: String, expected: Dictionary, value: Variant = null) -> Dictionary:
	if not active() or shell.windows.top().get("id") != layer or not Draft.same_value(expected,navigation.context()) or shell.core.busy(): return Draft.failure("stale","Creation input context retired.")
	if not _capture.is_empty() and id not in ["begin","retry","restart","exit"]: return Draft.failure("submitted","This creation is retained for retry. Restart to change submitted choices.")
	if navigation.step().get("hook") == "name" and id in ["edit","next","identity-operation"]:
		var field: Control = _editors.get("name-field")
		if is_instance_valid(field) and field.has_method("composition_owned") and field.composition_owned(): return Draft.failure("composition","Finish text composition, then use a separate press to continue.")
	var checked: Dictionary
	match id:
		"identity-operation":
			var hook: String = navigation.step().get("hook","")
			if hook == "name" and value == "random-name":
				checked = inputs.random_name(owner,expected.token)
				if checked.ok: _working.name = owner.projection().selections.name
			elif hook == "face" and value in ["portrait-previous","portrait-next"]:
				checked = inputs.cycle_face(owner,expected.token,-1 if value == "portrait-previous" else 1)
			else: return Draft.failure("permission","Use the corresponding identity editor.")
		"biography-operation":
			if navigation.step().get("hook") != "biography" or navigation.summary_locked(): return Draft.failure("permission","Restart to change biography after final review.")
			checked = inputs.biography_operation(owner,expected.token,str(value.operation),value.get("payload",{})) if inputs.has_method("biography_operation") else Draft.failure("unavailable","Biography operations unavailable.")
		"starting-operation":
			if navigation.step().get("hook") != ("skills" if value == "generate-skills" else "attributes"): return Draft.failure("permission","Use the corresponding starting allocation editor.")
			checked = inputs.operate(owner,expected.token,str(value)) if inputs.has_method("operate") else Draft.failure("unavailable","Starting operations unavailable.")
		"edit": checked = navigation.edit(expected,value)
		"generate-questionnaire": checked = owner.generate_questionnaire(expected.token)
		"career-route": checked = navigation.career_route(expected,str(value))
		"next":
			if inputs.has_method("random_name") and navigation.step().get("hook") == "name":
				checked = navigation.edit(expected,str(_working.get("name",owner.projection().selections.get("name",""))))
				if not checked.ok: notice = str(checked.get("reason","Name edit rejected.")); shell.schedule_render(); return checked
				expected = navigation.context()
			# The visible custom name is part of this completion request, even if
			# the player uses Next instead of the explicit Use name/Enter action.
			if inputs.has_method("validate_career") and navigation.step().get("hook") == "custom" and _working.has("custom.name"):
				var candidate: Dictionary = owner.projection().selections.get("custom",{}).duplicate(true)
				if not candidate.is_empty() and candidate.name != _working["custom.name"]:
					candidate.name = _working["custom.name"]
					checked = navigation.edit(expected,candidate)
					if not checked.ok: notice = str(checked.get("reason","Name edit rejected.")); shell.schedule_render(); return checked
					expected = navigation.context()
			checked = navigation.next(expected)
		"back":
			if navigation.step().get("hook") == "custom" and career_view.custom_tab == 3:
				cancel_nested(); checked = {"ok":true}
			else: checked = navigation.back(expected)
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
	if checked.ok and inputs.has_method("validate_career") and id in ["next","back","career-route"] and navigation.step().get("hook") == "custom" and not owner.projection().selections.has("custom"):
		# Enter through an admitted navigation request, never by mutating on render.
		# Reuse a retained candidate before creating a new blank custom draft.
		var retained: Dictionary = owner.projection().retained.get("custom",{}).get("value",{})
		var candidate: Dictionary = retained if not retained.is_empty() else preload("res://scripts/char/custom_career.gd").initial(inputs.policy,owner.token().id+"/custom")
		checked = navigation.edit(navigation.context(),candidate)
	notice = "" if checked.ok else str(checked.get("reason","Creation request rejected."))
	if checked.has("sections"): notice += "\n"+str(checked.sections)
	if checked.ok and id in ["edit","next","back","summary-edit","career-route","generate-questionnaire","starting-operation","biography-operation","identity-operation"]:
		# A page/selection handoff is a real input boundary, with the existing
		# fresh-press quarantine. Keep the same requester-owned gate and scope.
		shell.windows.replace(layer,"creation",func(_old: Dictionary): return {"ok":true,"data":{"cursor":"visible"}})
	shell.schedule_render()
	return checked

func render() -> void:
	_render_generation += 1
	_buttons.clear()
	_editors.clear()
	glyph_diagnostics.clear()
	var host: Control = shell.host
	var expected: Dictionary = navigation.context()
	var current: Dictionary = navigation.step()
	var hook: String = current.hook
	var page_identity: String = expected.token.id+"/"+expected.step
	if page_identity != _last_render_page:
		_last_render_page = page_identity
		host.panel.get_parent().set_deferred("scroll_vertical",0)
	var pixel_ratio := ui_pixel_ratio()
	host.label(translated("step."+navigation.step_id(),current.title),roundi(26.0/pixel_ratio))
	if controlled and inputs.has_method("biography_operation"): host.label("BIOGRAPHY AND ROLLS REVIEW · real increments 1–3 · assigned name/portrait/reflexes · no playable entry or grants",15)
	elif controlled and inputs.has_method("validate_career"): host.label("CREATION CAREER REVIEW · real race/career · assigned later stages · no playable entry or grants",15)
	elif controlled: host.label("CONTROLLED CREATION REVIEW · assigned inputs · no playable entry or grants",15)
	var art: Dictionary = {"ok":false}
	var resolver: RefCounted = host.controller.providers.creation_art
	if resolver != null: art = resolver.resolve(current.art)
	# Native 320×200 layout at a readable 2× scale. The ordinary shell scrolls on
	# smaller windows. Coordinates position controls only, never select/validate.
	_page = Control.new()
	_page.size = Vector2(640,400)
	var page_scale := minf(640.0,maxf(320.0,float(host.get_window().size.x)-88.0))/(640.0*pixel_ratio)
	_page_frame = Control.new()
	_page_frame.custom_minimum_size = Vector2(640,400)*page_scale
	_page_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	host.panel.add_child(_page_frame)
	_page_frame.add_child(_page)
	_page.scale = Vector2.ONE*page_scale
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
	elif inputs.has_method("random_name") and hook in ["name","face","reflexes"]:
		identity_view.render(self,expected,hook,selected)
	elif inputs.has_method("validate_career") and hook in ["race","gender","class_method","biography_method","class","questionnaire","custom"]:
		career_view.render(self,expected,hook,selected)
	elif inputs.has_method("operate") and hook in ["attributes","skills"]:
		starting_view.render(self,expected,hook,selected)
	elif inputs.has_method("biography_operation") and hook == "biography":
		biography_view.render(self,expected,selected)
	elif hook == "name":
		var field := LineEdit.new()
		field.text = str(_working.get(hook,selected.get(hook,"")))
		field.placeholder_text = "Enter name"
		field.position = Vector2(150,0)
		field.size = Vector2(480,32)
		_page.add_child(field)
		_editors["name-field"] = field
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
	if inputs.has_method("validate_career") and not career_view.candidate.is_empty() and hook in ["race","class"]: _buttons.next.disabled = true
	if inputs.has_method("validate_career") and not career_view.candidate.is_empty() and hook == "race": _buttons.next.hide()
	if inputs.has_method("validate_career") and hook in ["gender","class_method","class","biography_method"]: _buttons.next.hide()
	if inputs.has_method("validate_career") and hook == "custom" and selected.has("custom") and career_view.custom_tab in [0,3]: _buttons.next.hide()
	var row := HBoxContainer.new()
	host.panel.add_child(row)
	for entry in [["back","Back"],["restart","Restart"],["exit","Exit creation"]]:
		var button := Button.new()
		button.text = translated("action."+entry[0],entry[1])
		button.custom_minimum_size = Vector2(140,40)/pixel_ratio
		button.add_theme_font_size_override("font_size",roundi(18.0/pixel_ratio))
		row.add_child(button)
		_bind_button(button,entry[0],func(): action(entry[0],expected))
	if _submission_failed:
		var retry := Button.new()
		retry.text = translated("action.retry","Retry Begin Game")
		retry.custom_minimum_size = Vector2(180,40)
		row.add_child(retry)
		_bind_button(retry,"retry",func(): action("retry",expected))
	# Keep cancellation reachable without scrolling past the 640x400 page.
	host.panel.move_child(row,_page_frame.get_index())
	if hook == "summary" and inputs.has_method("random_name"):
		var media: RefCounted = host.controller.providers.media_preferences
		if media != null:
			var intro := CheckButton.new()
			intro.text = "Play introductory videos"
			intro.add_theme_font_size_override("font_size",roundi(18.0/pixel_ratio))
			intro.custom_minimum_size.y = 40.0/pixel_ratio
			intro.button_pressed = host.controller.settings.effective.get("media/creation_videos",true)
			intro.set_meta("creation_action","creation-videos")
			_editors["creation-videos"] = intro
			_buttons["creation-videos"] = intro
			host.panel.add_child(intro)
			host.panel.move_child(intro,_page_frame.get_index())
			var generation := _render_generation
			intro.toggled.connect(func(enabled: bool):
				if generation != _render_generation or shell.core.busy() or not active() or not Draft.same_value(expected,navigation.context()): return
				var applied: Dictionary = media.select_creation_videos(enabled)
				notice = media.creation_videos_message(applied)
				shell.schedule_render())
	if not notice.is_empty(): host.label(notice)
	if not _capture.is_empty():
		host.label("Retry uses the submitted character. Restart to change these choices.",15)
		for id in _buttons:
			if id not in ["retry","restart","exit"] and not id.begins_with("summary-page/"): _buttons[id].disabled = true
	if not glyph_diagnostics.is_empty(): host.label("Some characters are unavailable in the current font. Your Unicode text is retained unchanged; install a compatible font pack to display them.",15)
	if navigation.summary_locked(): host.label("Restart to change this selection after final review.")
	if not art.ok and not current.art.is_empty(): host.label("Optional interface artwork unavailable; using the readable fallback.",15)
	var focus: Control = _editors.get(_focus,_buttons.get(_focus,_buttons.get("back")))
	if focus is BaseButton and focus.disabled: focus = _buttons.get("retry",_buttons.get("exit"))
	if focus != null: call_deferred("_focus_control",focus,_render_generation)

func _focus_control(control: Control, generation: int) -> void:
	if generation == _render_generation and is_instance_valid(control) and control.is_inside_tree(): control.grab_focus()

func _summary(expected: Dictionary, selected: Dictionary) -> void:
	var identity := _box(Rect2(8,0,474,38))
	var identity_style: StyleBox = identity.get_theme_stylebox("panel")
	identity_style.set_content_margin(SIDE_TOP,1)
	identity_style.set_content_margin(SIDE_BOTTOM,1)
	var name_scroll := ScrollContainer.new()
	name_scroll.set_meta("creation_summary_name",true)
	name_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	identity.add_child(name_scroll)
	var name_label := Label.new()
	name_label.text = display_text(str(selected.get("name","Name incomplete")),"summary-name")
	name_label.tooltip_text = name_label.text
	name_label.add_theme_font_size_override("font_size",16)
	if _presentation != null: name_label.add_theme_font_override("font",_presentation.font("body"))
	name_scroll.add_child(name_label)
	if inputs.has_method("portrait"):
		identity_view.draw_portrait(self,selected,Rect2(492,8,130,86))
	for index in 3:
		var id: String = ["overview","career","history"][index]
		_button("summary-page/"+id,["Attributes & skills","Career & reflexes","History"][index],Rect2(8+index*158,42,154,38),func():
			if not shell.core.busy() and Draft.same_value(expected,navigation.context()): _summary_tab = index; shell.schedule_render())
		_buttons["summary-page/"+id].add_theme_font_size_override("font_size",14)
		_buttons["summary-page/"+id].toggle_mode = true
		_buttons["summary-page/"+id].button_pressed = _summary_tab == index
	var facts := _box(Rect2(8,84,474,308))
	var text := ""
	if _summary_tab == 0:
		var reflex: String = str(selected.get("reflexes","Incomplete"))
		for choice: Dictionary in inputs.choices("reflexes"):
			if choice.id == reflex: reflex = choice.label; break
		text = "Reflexes: "+reflex+"\n\n"
	var sections: Array = [["attributes","skills"],["race","gender","class","custom","reflexes"],["biography"]][_summary_tab]
	for section in sections:
		if not selected.has(section): continue
		var value: Variant = selected[section]
		if section in ["attributes","skills"] and value is Dictionary:
			text += section.capitalize()+"\n"
			if value.has("roll"):
				var receipt: Dictionary = owner.validate(section,owner.token(),value)
				if receipt.ok:
					var evaluated: Dictionary = receipt.provenance.evaluation
					for id in value.roll.base:
						var label: String = str(inputs.policy.skills.get(id,{}).get("label",id)) if section == "skills" else str(id).capitalize()
						text += "  %s: %d rolled + %d allocated%s = %d\n" % [label,value.roll.base[id],value.roll.allocated[id],(" %+d biography" % inputs.adjustments(owner.projection()).get(id,0)) if section == "skills" else "",evaluated.final[id]]
					text += ("Remaining: Primary %d · Major %d · Minor %d\n" % [evaluated.remaining.primary,evaluated.remaining.major,evaluated.remaining.minor]) if evaluated.remaining is Dictionary else "Remaining: "+str(evaluated.remaining)+"\n"
				else: text += "Invalid: "+receipt.reason+"\n"
				continue
			for key in value.get("base",{}): text += "  "+str(key).capitalize()+": "+str(value.base[key])+" + "+str(value.get("allocated",{}).get(key,0))+" assigned\n"
			text += "Unspent points: "+str(value.get("remaining","unavailable"))+"\n"
		elif section == "biography" and value is Dictionary:
			text += "Biography\n"
			if inputs.has_method("biography_operation"):
				var checked: Dictionary = owner.validate("biography",owner.token(),value)
				if checked.ok: text += checked.provenance.resolved_history+"\n"
				for question in inputs.templates[value.template].questions:
					for answer in question.answers:
						if answer.id == value.answers.get(question.id): text += question.text+"\n"+answer.text+"\n"+biography_view.disclosure(self,answer)+"\n"
				continue
			for question in value.get("answers",{}): text += "  "+str(question).capitalize()+": "+str(value.answers[question])+"\n"
			for effect: Dictionary in value.get("known_effects",[]): text += "Known effect: "+str(effect.get("target",""))+" "+str(effect.get("value",""))+" (candidate; applied at entry)\n"
		elif section == "custom" and value is Dictionary:
			text += "Custom career: "+str(value.get("name","Incomplete"))+"\n"
			for tier in value.get("tiers",{}): text += str(tier).capitalize()+" skills: "+_skill_labels(value.tiers[tier])+"\n"
			if value.has("traits") and inputs.has_method("validate_career"):
				for id in value.traits: text += str(inputs.policy.traits[id].label)+"\n"
				var evaluated: Dictionary = preload("res://scripts/char/custom_career.gd").evaluate(value,inputs.policy,owner.token().id+"/custom")
				text += "Class base attributes\n"
				for id in value.attributes: text += "  %s: %d\n" % [str(id).capitalize(),value.attributes[id]]
				text += "Starting reputation\n"
				for id in value.reputation: text += "  %s: %+d\n" % [str(id).capitalize(),value.reputation[id]]
				text += "Advancement multiplier: %.4f\n" % (float(evaluated.advancement.numerator)/evaluated.advancement.denominator)
				var magery: Dictionary = inputs.custom_spell_points(value)
				if magery.ok: text += "Spell points: %.4f × Intelligence\n" % (float(magery.numerator)/magery.denominator)
			else: text += "Advantages: "+str(value.get("advantages",[]))+"\nDisadvantages: "+str(value.get("disadvantages",[]))+"\n"
			text += "HP per level parameter: "+str(value.get("hit_points_per_level","Incomplete"))+"\n"
		else:
			var label := str(value)
			for choice: Dictionary in inputs.choices(section):
				if Draft.same_value(choice.get("value",choice.id),value): label = str(choice.label); break
			text += section.capitalize()+": "+label+"\n"
			if section == "reflexes" and inputs.has_method("random_name") and inputs.identity.reflexes.has(value): text += preload("res://scripts/char/reflex_parameters.gd").explanation(inputs.identity.reflexes[value])+"\n"
			if section == "race" and inputs.has_method("race_benefits"): text += "Birth identity; "+inputs.race_benefits(value)+"\n"
			if section == "class" and inputs.has_method("preset"):
				var career: Dictionary = inputs.preset(value)
				if career.ok:
					for tier in career.tiers: text += str(tier).capitalize()+": "+_skill_labels(career.tiers[tier])+"\n"
					for id in career.traits: text += str(inputs.policy.traits[id].label)+"\n"
					text += "HP per level parameter: %d\nAdvancement: %.4f\n" % [career.hit_points_per_level,float(career.advancement.numerator)/career.advancement.denominator]
					text += "Spell points: %.4f × Intelligence\n" % (float(career.spell_points.numerator)/career.spell_points.denominator)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	facts.add_child(scroll)
	var label := Label.new()
	label.text = display_text(text,"summary")
	if _presentation != null: label.add_theme_font_override("font",_presentation.font("body"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",16)
	scroll.add_child(label)
	var index := 0
	_box(Rect2(488,96,144,240))
	for section in Draft.SUMMARY_EDITORS:
		_button("edit/"+section,section.capitalize(),Rect2(488,100+index*46,144,42),func(): action("summary-edit",expected,section))
		index += 1

func _skill_labels(ids: Array) -> String:
	var labels: Array[String] = []
	for id in ids: labels.append(str(inputs.policy.skills.get(id,{}).get("label",id)) if inputs.has_method("validate_career") else str(id))
	return ", ".join(labels)

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
	var art: RefCounted = shell.host.controller.providers.creation_art
	var parchment: StyleBoxTexture = art.parchment_style() if art != null and navigation.step().get("hook") != "custom" and rect.size.x >= 200 and rect.size.y >= 60 else null
	if parchment != null:
		box.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		box.add_theme_stylebox_override("panel",parchment)
		var theme := Theme.new()
		theme.set_color("font_color","Label",Color("261c12"))
		box.theme = theme
	else: box.add_theme_stylebox_override("panel",style)
	_page.add_child(box)
	return box

func _text(parent: Control, value: String) -> void:
	var label := Label.new()
	label.text = display_text(value)
	if _presentation != null: label.add_theme_font_override("font",_presentation.font("body"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",16)
	parent.add_child(label)

func display_text(value: String, field := "text") -> String:
	if _presentation == null: return value
	var displayed: Dictionary = _presentation.literal(value,"body","","",{"window":"creation","step":navigation.step_id(),"field":field})
	glyph_diagnostics.append_array(displayed.diagnostics)
	return displayed.text

func _button(id: String, text: String, rect: Rect2, callback: Callable) -> void:
	var button := Button.new()
	button.text = translated("action."+id,text)
	button.position = rect.position
	button.size = rect.size
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_page.add_child(button)
	_bind_button(button,id,callback)

func _bind_button(button: Button, id: String, callback: Callable) -> void:
	button.text = display_text(button.text,id)
	_buttons[id] = button
	button.set_meta("creation_action",id)
	button.set_meta("font_role","body")
	if _presentation != null: button.add_theme_font_override("font",_presentation.font("body"))
	# Solid interactive surfaces mask the image's baked English labels. Geometry
	# and focus are still real controls; texture pixels never define actions.
	for state in ["normal","hover","pressed","focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color.TRANSPARENT if state == "focus" else Color("4b493b") if state == "hover" else Color("20261f") if state == "pressed" else Color("30362e")
		style.border_color = Color("ffe6a1") if state in ["focus","pressed"] else Color("a08a58")
		style.set_border_width_all(3 if state in ["focus","pressed"] else 1)
		style.content_margin_left = 6
		style.content_margin_right = 6
		button.add_theme_stylebox_override(state,style)
	var generation := _render_generation
	button.pressed.connect(func():
		if generation == _render_generation: callback.call())
	button.focus_entered.connect(func(): _focus = id)

func dispose() -> void:
	career_view.clear()
	navigation.discard()
	if shell.core.retiring.is_connected(_retire): shell.core.retiring.disconnect(_retire)
	if shell.core.terminal.is_connected(_terminal): shell.core.terminal.disconnect(_terminal)
	if shell.host.resized.is_connected(_viewport_resized): shell.host.resized.disconnect(_viewport_resized)
	if shell.host.get_window().size_changed.is_connected(_viewport_resized): shell.host.get_window().size_changed.disconnect(_viewport_resized)
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

func _viewport_resized() -> void:
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
