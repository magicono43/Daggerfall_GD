extends RefCounted
## Presentation only: all accepted candidates and evaluations come from CHAR.
const Draft = preload("res://scripts/char/creation_draft.gd")
const Custom = preload("res://scripts/char/custom_career.gd")
var candidate := ""
var candidate_hook := ""
var question_position := 0
var custom_tab := 0
var _narrations: Array[AudioStreamPlayer] = []
var _draft := ""

func clear() -> void:
	candidate = ""
	candidate_hook = ""
	question_position = 0
	custom_tab = 0
	_draft = ""
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
	if candidate_hook != hook: candidate = ""; candidate_hook = hook
	if view.inputs.policy.is_empty() or view.inputs.sources.is_empty():
		view._text(view._box(Rect2(12,48,616,280)),view.inputs.setup_error)
		return
	match hook:
		"race": _race(view,expected,selected)
		"gender": _gender(view,expected,selected)
		"class_method": preload("res://scripts/ui/creation_class_method.gd").render(view,expected)
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
	refresh(view)

func _confirm(view: RefCounted, expected: Dictionary, hook: String, id: String) -> void:
	var read: Dictionary = view.inputs.description(id)
	if hook == "race":
		preload("res://scripts/ui/creation_popup.gd").confirm(view,read.text if read.ok else read.reason,func():
			var result: Dictionary = view.action("edit",expected,id)
			if result.ok:
				candidate = ""
				view.action("next",view.navigation.context()),func():
			candidate = ""; refresh(view),read.ok)
		return
	var list := _list(view,Rect2(12,16,616,268))
	var label: String = view.inputs.preset(id).get("name",id)
	label = view.translated("choice."+hook+"."+id,label)
	view._text(list,read.text if read.ok else read.reason)
	var career: Dictionary = view.inputs.preset(id)
	if career.ok: _mechanics(view,list,career)
	else: view._text(list,career.reason); read = career
	view._button("confirm/yes","Yes — accept "+label,Rect2(12,290,302,42),func():
		var result: Dictionary = view.action("edit",expected,id)
		if result.ok:
			candidate = ""
			view.action("next",view.navigation.context()))
	view._buttons["confirm/yes"].disabled = not read.ok or view.navigation.summary_locked()
	view._button("confirm/no","No — choose again",Rect2(326,290,302,42),func():
		candidate = ""
		if hook == "class" and view.owner.projection().selections.get("class_method") == "questionnaire": view.action("career-route",expected,"list")
		else: refresh(view))
	view._buttons["confirm/no"].disabled = view.navigation.summary_locked()

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
	if not candidate.is_empty(): _confirm(view,expected,"class",candidate); return
	if selected.get("class_method") == "questionnaire":
		var read: Dictionary = view.inputs.suggestion(selected.get("questionnaire",{}))
		if read.ok: _confirm(view,expected,"class",read.id); return
		view._text(view._box(Rect2(12,16,616,270)),read.reason)
		view._button("direct-route","Choose directly",Rect2(12,286,240,46),func(): view.action("career-route",expected,"list"))
		return
	var list := _list(view,Rect2(100,16,440,316))
	for choice: Dictionary in view.inputs.choices("class"):
		_button(view,list,"preset/"+choice.id,view.translated("choice.class."+choice.id,str(choice.label)),func(): _candidate(view,expected,"class",choice.id))
	_button(view,list,"preset/custom","Custom",func(): view.action("career-route",expected,"custom"))

func _questions(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
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
		var retained: Dictionary = view.owner.projection().retained.get("custom",{}).get("value",{})
		view._button("start-custom","Open custom career",Rect2(80,270,360,54),func(): _edit_custom(view,expected,retained if not retained.is_empty() else Custom.initial(policy,expected.token.id+"/custom")))
		return
	var value: Dictionary = selected.custom
	var evaluated: Dictionary = Custom.evaluate(value,policy,expected.token.id+"/custom")
	if view._presentation != null:
		var display: Dictionary = view._presentation.literal(value.name,"body","","",{"window":"creation","field":"custom.name"})
		view.glyph_diagnostics.append_array(display.diagnostics)
		if not display.diagnostics.is_empty(): view.shell.host.label("The current font cannot display part of this name. Unicode is retained. Display preview: "+str(display.text),16)
	if custom_tab != 0:
		_nested_custom(view,expected,value)
	else:
		view._text(view._box(Rect2(4,0,190,32)),"Class name")
		var name_field := LineEdit.new()
		name_field.text = str(view._working.get("custom.name",value.name))
		name_field.max_length = 256
		name_field.placeholder_text = "Name your class"
		name_field.position = Vector2(196,0)
		name_field.size = Vector2(302,32)
		name_field.editable = not view.navigation.summary_locked()
		view._page.add_child(name_field)
		view._editors["custom/name-field"] = name_field
		name_field.focus_entered.connect(func(): view._focus = "custom/name-field")
		view._button("custom/name","Use name",Rect2(500,0,130,32),func(): var revised := value.duplicate(true); revised.name = name_field.text; _edit_custom(view,expected,revised))
		view._buttons["custom/name"].disabled = view.navigation.summary_locked()
		var generation: int = view._render_generation
		name_field.text_changed.connect(func(text: String):
			if generation == view._render_generation and Draft.same_value(expected,view.navigation.context()): view._working["custom.name"] = text)
		name_field.text_submitted.connect(func(text: String):
			if generation != view._render_generation: return
			var revised := value.duplicate(true); revised.name = text; _edit_custom(view,expected,revised))
		for index in 8:
			var key: String = Custom.ATTRIBUTES[index]
			var box: PanelContainer = view._box(Rect2(4,34+index*44,114,44))
			var column := VBoxContainer.new()
			var box_style: StyleBox = box.get_theme_stylebox("panel")
			box_style.content_margin_top = 0
			box_style.content_margin_bottom = 0
			column.add_theme_constant_override("separation",0)
			box.add_child(column)
			var label := Label.new()
			label.text = key.left(3).to_upper()
			label.tooltip_text = key.capitalize()+" [%d..%d]" % [policy.attributes[key].min,policy.attributes[key].max]
			label.add_theme_font_size_override("font_size",12)
			column.add_child(label)
			_spin(view,column,"attribute/"+key,int(value.attributes[key]),int(policy.attributes[key].min),int(policy.attributes[key].max),func(number: int): var revised := value.duplicate(true); revised.attributes[key] = number; _edit_custom(view,expected,revised))
		view._box(Rect2(122,34,236,356))
		for tier in Custom.COUNTS:
			var top := 34 if tier == "primary" else 132 if tier == "major" else 230
			view._text(view._box(Rect2(124,top,232,26)),tier.capitalize()+" skills")
			for slot in Custom.COUNTS[tier]:
				var picker := OptionButton.new()
				picker.position = Vector2(130,top+28+slot*22)
				picker.size = Vector2(220,24)
				picker.add_theme_font_size_override("font_size",14)
				picker.fit_to_longest_item = false
				picker.clip_text = true
				picker.add_item("Choose skill")
				picker.set_item_metadata(0,"")
				var index := 1
				for skill in policy.skills:
					picker.add_item(view.display_text(str(policy.skills[skill].label),"skill."+skill))
					picker.set_item_metadata(index,skill)
					var assigned := false
					for other in Custom.COUNTS:
						if skill in value.tiers[other]: assigned = true
					picker.set_item_disabled(index,assigned and value.tiers[tier][slot] != skill)
					if value.tiers[tier][slot] == skill: picker.select(index)
					index += 1
				picker.disabled = view.navigation.summary_locked()
				view._page.add_child(picker)
				var action_id: String = "skill/"+tier+"/"+str(slot)
				view._buttons[action_id] = picker
				picker.set_meta("creation_action",action_id)
				picker.focus_entered.connect(func(): view._focus = action_id)
				picker.item_selected.connect(func(chosen: int):
					if generation != view._render_generation: return
					var revised := value.duplicate(true)
					revised.tiers[tier][slot] = picker.get_item_metadata(chosen)
					_edit_custom(view,expected,revised))
		# Source CUST00 positions: keep the central advancement gauge visible.
		var hp_box: PanelContainer = view._box(Rect2(498,34,132,106))
		var hp_column := VBoxContainer.new()
		hp_box.add_child(hp_column)
		view._text(hp_column,"HP / level")
		_spin(view,hp_column,"hp",value.hit_points_per_level,int(policy.hp.min),int(policy.hp.max),func(number: int): var revised := value.duplicate(true); revised.hit_points_per_level = number; _edit_custom(view,expected,revised))
		for entry in [[4,"Details"],[1,"Advantages"],[2,"Disadvantages"],[3,"Reputation"]]:
			var top: int = 148+(int(entry[0])-1)*48 if entry[0] < 4 else 148
			if entry[0] == 1: top = 196
			elif entry[0] == 2: top = 244
			elif entry[0] == 3: top = 292
			view._button("custom/panel/"+str(entry[0]),entry[1],Rect2(498,top,132,44),func(): custom_tab = entry[0]; refresh(view))
			view._buttons["custom/panel/"+str(entry[0])].add_theme_font_size_override("font_size",16)
		# Mask baked English multiplier labels so configured endpoints remain true.
		view._text(view._box(Rect2(366,34,128,62)),"Advancement\nmultiplier")
		view._box(Rect2(366,100,72,290))
		for item in [[146,"× %.3f" % (float(policy.difficulty.high_milli)/1000.0)],[228,"D = "+str(evaluated.difficulty)],[316,"× %.3f" % (float(policy.difficulty.low_milli)/1000.0)]]:
			var label := Label.new()
			label.position = Vector2(370,item[0])
			label.size = Vector2(66,30)
			label.text = item[1]
			label.add_theme_font_size_override("font_size",12)
			view._page.add_child(label)
		var art: Dictionary = view.shell.host.controller.providers.creation_art.resolve("creation.dagger")
		if art.ok:
			var dagger := TextureRect.new()
			dagger.texture = art.texture
			dagger.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			dagger.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			dagger.size = Vector2(48,18)
			var ratio: float = float(evaluated.difficulty-policy.difficulty.min)/float(policy.difficulty.max-policy.difficulty.min)
			var y := 312.0-ratio*156.0
			if policy.difficulty.min < 0 and policy.difficulty.max > 0:
				y = 230.0-74.0*float(evaluated.difficulty)/policy.difficulty.max if evaluated.difficulty >= 0 else 230.0+82.0*float(evaluated.difficulty)/policy.difficulty.min
			dagger.position = Vector2(440,clampf(y,92.0,372.0))
			dagger.mouse_filter = Control.MOUSE_FILTER_IGNORE
			view._page.add_child(dagger)
		else: view.shell.host.label("Optional difficulty dagger artwork unavailable.",15)
	view.shell.host.label("Attributes remaining: %d · Reputation remaining: %d · HP contribution: %+d · Difficulty: %d [%d..%d] · Advancement: %.4f" % [evaluated.attribute_remaining,evaluated.reputation_remaining,evaluated.hp_contribution,evaluated.difficulty,policy.difficulty.min,policy.difficulty.max,float(evaluated.advancement.numerator)/evaluated.advancement.denominator],16)
	view.shell.host.label("Higher advancement multiplier requires more practice. Difficulty outside the legal range remains editable; the dagger position is visually clipped only.",15)
	var contributions: Array[String] = []
	for id in value.traits: contributions.append(str(policy.traits[id].label)+" %+d" % policy.traits[id].cost)
	view.shell.host.label("Trait contributions: "+(", ".join(contributions) if not contributions.is_empty() else "none"),15)
	if not evaluated.errors.is_empty(): view.shell.host.label("Custom completion: "+" ".join(evaluated.errors),16)

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
	elif custom_tab == 3:
		view._text(list,"Initial reputation adjustments")
		for group in Custom.GROUPS:
			_number(view,list,"reputation/"+group,group.capitalize(),value.reputation[group],int(policy.reputation[group].min),int(policy.reputation[group].max),func(number: int): var revised := value.duplicate(true); revised.reputation[group] = number; _edit_custom(view,expected,revised))
		view._text(list,"These are initial custom-class adjustments. No live faction standing changes. Required total: "+str(policy.reputation_total))
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
	var instance: Dictionary = preload("res://scripts/av/replacement_instances.gd").audio(art.narration(id))
	if not instance.ok: return # Optional audio cannot gate selection.
	var player: AudioStreamPlayer = instance.player
	_narrations.append(player)
	view.shell.host.add_child(player)
	player.finished.connect(func():
		_narrations.erase(player)
		player.queue_free(),CONNECT_ONE_SHOT)
	player.play()
