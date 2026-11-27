extends RefCounted
## Presentation only: all accepted candidates and evaluations come from CHAR.
const Draft = preload("res://scripts/char/creation_draft.gd")
const Custom = preload("res://scripts/char/custom_career.gd")
var candidate := ""
var candidate_hook := ""
var question_position := 0
var questionnaire_runtime: Node
var custom_tab := 0
var _narrations: Array[AudioStreamPlayer] = []
var _draft := ""
var picker_selection := -1
var picker_scroll := 0
var class_jingle_submissions := 0
var custom_attribute := 0
var skill_slot: Array = []
var dagger_points: Variant = null
var dagger_trails: Array = []
var hp_repeat: Node
var custom_keyboard_focus := false
var reputation_warning := false
var custom_exit_message := ""
var help_topic := ""
var help_cache: Dictionary = {}
var trait_stage := ""
var trait_category := ""

func clear() -> void:
	if is_instance_valid(questionnaire_runtime): questionnaire_runtime.stop(); questionnaire_runtime.queue_free()
	questionnaire_runtime = null
	if is_instance_valid(hp_repeat): hp_repeat.stop(); hp_repeat.queue_free()
	hp_repeat = null
	custom_keyboard_focus = false
	reputation_warning = false
	custom_exit_message = ""
	help_topic = ""
	help_cache.clear()
	trait_stage = ""; trait_category = ""
	candidate = ""
	candidate_hook = ""
	question_position = 0
	custom_tab = 0
	_draft = ""
	custom_attribute = 0
	skill_slot.clear()
	dagger_points = null
	dagger_trails.clear()
	picker_selection = -1
	picker_scroll = 0
	stop_narration()

func stop_narration() -> void:
	# Only creation teardown/restart interrupts these independent one-shots.
	for player in _narrations:
		if is_instance_valid(player): player.stop(); player.queue_free()
	_narrations.clear()

func refresh(view: RefCounted) -> void:
	# Retire local UI candidates immediately, before the deferred repaint. A late
	# Yes/answer from the old controls must not survive a cancellation/page change.
	view._render_generation += 1
	view.shell.schedule_render()

func render(view: RefCounted, expected: Dictionary, hook: String, selected: Dictionary) -> void:
	if _draft != expected.token.id: clear(); _draft = expected.token.id
	if candidate_hook != hook:
		trait_stage = ""; trait_category = ""
		help_topic = ""
		candidate = ""; candidate_hook = hook; skill_slot.clear(); reputation_warning = false; custom_exit_message = ""
		if hook != "custom": custom_tab = 0
	if view.inputs.policy.is_empty() or view.inputs.sources.is_empty():
		view._text(view._box(Rect2(12,48,616,280)),view.inputs.setup_error)
		return
	match hook:
		"race": _race(view,expected,selected)
		"gender": _gender(view,expected,selected)
		"class_method": preload("res://scripts/ui/creation_class_method.gd").render(view,expected)
		"biography_method": preload("res://scripts/ui/creation_class_method.gd").render(view,expected,"biography_method")
		"class": _classes(view,expected,selected)
		"questionnaire": _questions(view,expected,selected)
		"custom": _custom(view,expected,selected)

func _list(view: RefCounted, rect: Rect2) -> VBoxContainer:
	var box: PanelContainer = view._box(rect)
	var scroll := ScrollContainer.new()
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	return list

func _button(view: RefCounted, parent: Control, id: String, label: String, callback: Callable, disabled := false) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size.y = 32
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.disabled = disabled or view.navigation.summary_locked()
	parent.add_child(button)
	view._bind_button(button,id,callback)

func _candidate(view: RefCounted, expected: Dictionary, hook: String, id: String) -> void:
	if not Draft.same_value(expected,view.navigation.context()) or view.navigation.summary_locked(): return
	candidate = id
	candidate_hook = hook
	if hook == "race": narrate(view,id)
	elif hook == "class":
		var art: RefCounted = view.shell.host.controller.providers.creation_art
		if _play_creation_clip(view,art.class_jingle()): class_jingle_submissions += 1
	refresh(view)

func _confirm(view: RefCounted, expected: Dictionary, hook: String, id: String) -> void:
	var read: Dictionary = view.inputs.description(id)
	var yes := func():
		var result: Dictionary = view.action("edit",expected,id)
		if result.ok:
			candidate = ""
			view.action("next",view.navigation.context())
	var no := func():
		candidate = ""
		if hook == "class" and view.owner.projection().selections.get("class_method") == "questionnaire": view.action("career-route",expected,"list")
		else: refresh(view)
	preload("res://scripts/ui/creation_popup.gd").choices(view,read.text if read.ok else read.reason,[["confirm/yes","Yes",yes,"yes",not read.ok],["confirm/no","No",no,"no",false]],hook+"-confirmation")

func _race(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	if not candidate.is_empty(): _confirm(view,expected,"race",candidate); return
	var hit := Control.new()
	hit.size = Vector2(640,336)
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	view._page.add_child(hit)
	var generation: int = view._render_generation
	hit.gui_input.connect(func(event: InputEvent):
		if generation != view._render_generation: return
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var id: String = view.inputs.race_at(event.position/2.0)
			if not id.is_empty(): _candidate(view,expected,"race",id))
	view.shell.host.label("Choose your home province on the map, or use the accessible province buttons below.",16)
	var row := HFlowContainer.new()
	view.shell.host.panel.add_child(row)
	for id in view.inputs.policy.races:
		var race: Dictionary = view.inputs.policy.races[id]
		_button(view,row,"province/"+id,view.translated("choice.race."+id,str(race.label)),func(): _candidate(view,expected,"race",id))
	if selected.has("race"): view.shell.host.label("Confirmed birth race: "+str(selected.race))
	if not view.inputs.sources.picker.ok: view.shell.host.label(view.inputs.sources.picker.reason)

func _gender(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var options: Array = []
	for id in ["male","female"]:
		var fallback: String = id.capitalize()
		for choice: Dictionary in view.inputs.choices("gender"):
			if choice.id == id and choice.label != id: fallback = str(choice.label)
		options.append(["gender/"+id,view.translated("choice.gender."+id,fallback),func():
			var result: Dictionary = view.action("edit",expected,id)
			if result.ok: view.action("next",view.navigation.context()),id,false])
	preload("res://scripts/ui/creation_popup.gd").choices(view,view.translated("prompt.gender","Select thy character's gender."),options,"gender-confirmation")

func _mechanics(view: RefCounted, parent: Control, career: Dictionary) -> void:
	view._text(parent,str(career.get("name","Career")))
	for tier in ["primary","major","minor"]:
		var labels: Array[String] = []
		for id in career.tiers[tier]: labels.append(str(view.inputs.policy.skills[id].label))
		view._text(parent,tier.capitalize()+": "+", ".join(labels))
	view._text(parent,"Base attributes: "+str(career.attributes))
	view._text(parent,"HP per level parameter: %d\nAdvancement multiplier: %.4f (higher means more practice required)\nSpell points: %s × Intelligence" % [career.hit_points_per_level,float(career.advancement.numerator)/career.advancement.denominator,career.get("spell_point_multiplier","0.5")])
	if career.traits.is_empty(): view._text(parent,"Special advantages/disadvantages and equipment restrictions: none.")
	for id in career.traits: view._text(parent,str(view.inputs.policy.traits[id].label))
	view._text(parent,"Effects and racial/class stacking require their runtime owners; this draft applies no live grants.")

func _classes(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	if selected.get("class_method") == "questionnaire":
		var read: Dictionary = view.inputs.suggestion(selected.get("questionnaire",{}))
		if read.ok: _confirm(view,expected,"class",read.id); return
		view._text(view._box(Rect2(12,16,616,270)),read.reason)
		view._button("direct-route","Choose directly",Rect2(12,286,240,46),func(): view.action("career-route",expected,"list"))
		return
	var entries: Array = []
	var labels: Array = []
	for choice: Dictionary in view.inputs.choices("class"):
		entries.append(str(choice.id))
		labels.append(view.translated("choice.class."+choice.id,str(choice.label)))
	entries.append("custom"); labels.append(view.translated("choice.class.custom","Custom"))
	var art: RefCounted = view.shell.host.controller.providers.creation_art
	var image: Dictionary = art.resolve("creation.list-picker")
	var thumb: Dictionary = art.resolve("creation.scrollbar-thumb")
	var fallback: Font = view._presentation.font() if view._presentation != null else ThemeDB.fallback_font
	var font: Font = art.popup_font(fallback)
	if view._presentation != null: font = view._presentation.creation_popup_font(font)
	for text: String in labels:
		for index in text.length():
			if not font.has_char(text.unicode_at(index)): font = fallback; break
	var picker := preload("res://scripts/ui/classic_list_picker.gd").new()
	picker.position = Vector2(120,72); picker.scale = Vector2(2,2)
	picker.set_meta("creation_list_picker",true)
	view._page.add_child(picker)
	picker.configure(labels,font,image.texture if image.ok else null,view.navigation.summary_locked() or not candidate.is_empty(),picker_selection,picker_scroll,thumb.texture if thumb.ok else null)
	for index in entries.size(): view._buttons["preset/"+entries[index]] = picker.buttons[index]
	var generation: int = view._render_generation
	var current := func(): return generation == view._render_generation and view.active() and not view.shell.core.busy() and Draft.same_value(expected,view.navigation.context())
	picker.item_selected.connect(func(index: int):
		if not current.call(): return
		picker_selection = index)
	picker.scrolled.connect(func(index: int):
		if current.call(): picker_scroll = index)
	picker.item_activated.connect(func(index: int):
		if not current.call() or view.navigation.summary_locked() or not candidate.is_empty(): return
		if entries[index] == "custom": view.action("career-route",expected,"custom")
		else: _candidate(view,expected,"class",entries[index]))
	if not candidate.is_empty(): _confirm(view,expected,"class",candidate)

func _questions(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	if selected.has("questionnaire") and view.inputs.sources.questionnaire.ok:
		preload("res://scripts/ui/creation_questionnaire.gd").render(self,view,expected,selected)
		return
	_questions_legacy(view,expected,selected)

func _questions_legacy(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var source: Dictionary = view.inputs.sources.questionnaire
	if not source.ok:
		view._text(view._box(Rect2(12,16,616,250)),source.reason)
		view._button("direct-route","Choose directly",Rect2(12,280,240,46),func(): view.action("career-route",expected,"list"))
		return
	if not selected.has("questionnaire"):
		view._text(view._box(Rect2(80,242,480,90)),"Answer ten class questions. The selected questions remain fixed while you review or change answers.")
		view._button("start-questions","Start questionnaire",Rect2(80,178,300,46),func(): view.action("generate-questionnaire",expected))
		return
	var value: Dictionary = selected.questionnaire
	question_position = clampi(question_position,0,9)
	var id: String = value.questions[question_position]
	var question: Dictionary = source.questions[id]
	# Keep the classic sky visible above the readable question/answer area.
	var list := _list(view,Rect2(12,112,616,220))
	view._text(list,str(question.text))
	for index in 3:
		_button(view,list,"answer/"+str(index),("✓ " if value.answers.get(id) == index else "")+str(question.answers[index]),func():
			var revised := value.duplicate(true)
			revised.answers[id] = index
			view.action("edit",expected,revised))
	view._button("question/back","Previous question",Rect2(12,344,172,46),func(): question_position = maxi(0,question_position-1); refresh(view))
	view._buttons["question/back"].disabled = question_position == 0
	view._button("question/next","Next question",Rect2(194,344,172,46),func(): question_position = mini(9,question_position+1); refresh(view))
	view._buttons["question/next"].disabled = question_position == 9
	view._text(list,"Answered: %d / 10. Next below reviews the suggestion after all ten answers." % value.answers.size())
	_button(view,list,"direct-route","Choose directly instead",func(): view.action("career-route",expected,"list"))

func _edit_custom(view: RefCounted, expected: Dictionary, value: Dictionary) -> void:
	view.action("edit",expected,value)

func _custom(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var policy: Dictionary = view.inputs.policy
	if not selected.has("custom"):
		view._text(view._box(Rect2(80,120,480,120)),"Custom class could not be prepared. "+view.notice)
		return
	var value: Dictionary = selected.custom
	var evaluated: Dictionary = Custom.evaluate(value,policy,expected.token.id+"/custom")
	if view._presentation != null:
		var display: Dictionary = view._presentation.literal(value.name,"body","","",{"window":"creation","field":"custom.name"})
		view.glyph_diagnostics.append_array(display.diagnostics)
		if not display.diagnostics.is_empty(): view.shell.host.label("The current font cannot display part of this name. Unicode is retained. Display preview: "+str(display.text),16)
	if custom_tab == 3:
		preload("res://scripts/ui/creation_custom_sheet.gd").render(self,view,expected,value,evaluated)
		preload("res://scripts/ui/creation_reputation.gd").render(self,view,expected,value)
	elif custom_tab == 4:
		preload("res://scripts/ui/creation_custom_sheet.gd").render(self,view,expected,value,evaluated)
		preload("res://scripts/ui/creation_help.gd").render(self,view,expected)
	elif custom_tab in [1,2]:
		preload("res://scripts/ui/creation_custom_sheet.gd").render(self,view,expected,value,evaluated)
		preload("res://scripts/ui/creation_traits.gd").render(self,view,expected,value)
	else:
		preload("res://scripts/ui/creation_custom_sheet.gd").render(self,view,expected,value,evaluated)

func _nested_custom(view: RefCounted, expected: Dictionary, value: Dictionary) -> void:
	var policy: Dictionary = view.inputs.policy
	var list := _list(view,Rect2(8,8,624,328))
	if custom_tab in [1,2]:
		var side := "advantage" if custom_tab == 1 else "disadvantage"
		view._text(list,side.capitalize()+" selections (maximum "+str(policy.limits[side])+")")
		for id in value.traits:
			var option: Dictionary = policy.traits[id]
			if option.side == side:
				_button(view,list,"remove/"+id,"Remove "+str(option.label)+" (%+d)" % option.cost,func(): var revised := value.duplicate(true); revised.traits.erase(id); _edit_custom(view,expected,revised))
		var picker := OptionButton.new()
		picker.add_item("Choose option and subtype (cancel leaves no selection)")
		picker.set_item_metadata(0,"")
		for id in policy.traits:
			var option: Dictionary = policy.traits[id]
			if option.side != side: continue
			picker.add_item(view.display_text(str(option.label)+" (%+d)" % option.cost,"trait."+id))
			picker.set_item_metadata(picker.item_count-1,id)
		picker.set_meta("creation_action","trait-picker/"+side)
		list.add_child(picker)
		_button(view,list,"add/"+side,"Add "+side,func():
			var id: String = picker.get_selected_metadata()
			if id.is_empty(): return
			var revised := value.duplicate(true); revised.traits.append(id); _edit_custom(view,expected,revised))
		view._text(list,"Conflicts reject the new selection and retain existing choices. No birth-race bans. Runtime effects and stacking remain with their respective owners.")
	else:
		view._text(list,"Attributes: redistribute the configured exact total across eight attributes. Assign twelve distinct supported skills: 3 Primary, 3 Major and 6 Minor. Replacement releases the old skill without swapping.")
		view._text(list,"The HP parameter is not guaranteed health gained on every level. Higher advancement multiplier requires more practice; it does not multiply every reward. Reputation is independent from difficulty.")
		for id in value.traits: view._text(list,str(policy.traits[id].label)+" contributes %+d" % policy.traits[id].cost)
		var points: Dictionary = view.inputs.custom_spell_points(value)
		view._text(list,"Configured spell-point multiplier: %.4f × Intelligence. Selected trait parameters pass to later owners; no live effects are inferred or applied here." % (float(points.numerator)/points.denominator) if points.ok else points.reason)
	_button(view,list,"custom/close-panel","Return to career",func(): custom_tab = 0; refresh(view))

func _spin(view: RefCounted, parent: Control, id: String, current: int, minimum: int, maximum: int, callback: Callable) -> SpinBox:
	var field := SpinBox.new()
	field.min_value = minimum
	field.max_value = maximum
	field.allow_greater = true
	field.allow_lesser = true
	field.step = 1
	field.value = current
	field.editable = not view.navigation.summary_locked()
	field.add_theme_font_size_override("font_size",14)
	field.custom_minimum_size = Vector2(84,24)
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field.set_meta("creation_action",id)
	parent.add_child(field)
	view._editors[id] = field.get_line_edit()
	field.get_line_edit().focus_entered.connect(func(): view._focus = id)
	var generation: int = view._render_generation
	field.value_changed.connect(func(number: float):
		if generation == view._render_generation: callback.call(int(number)))
	return field

func _number(view: RefCounted, parent: Control, id: String, title: String, current: int, minimum: int, maximum: int, callback: Callable) -> void:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = title+" [%d..%d]" % [minimum,maximum]
	label.custom_minimum_size.x = 260
	row.add_child(label)
	_spin(view,row,id,current,minimum,maximum,callback)
func narrate(view: RefCounted, id: String) -> void:
	var art: RefCounted = view.shell.host.controller.providers.creation_art
	_play_creation_clip(view,art.narration(id))

func _play_creation_clip(view: RefCounted, resource: Dictionary) -> bool:
	var instance: Dictionary = preload("res://scripts/av/replacement_instances.gd").audio(resource)
	if not instance.ok: return false # Optional audio cannot gate selection.
	var player: AudioStreamPlayer = instance.player
	_narrations.append(player)
	view.shell.host.add_child(player)
	player.finished.connect(func():
		_narrations.erase(player)
		player.queue_free(),CONNECT_ONE_SHOT)
	player.play()
	return true
