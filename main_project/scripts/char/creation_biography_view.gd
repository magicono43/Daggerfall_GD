extends RefCounted
var _draft := ""
var position := 0
var history := false
var report := false
const Native = preload("res://scripts/ui/creation_native_controls.gd")

func begin(view: RefCounted, method: String) -> void:
	_draft = view.owner.token().id; position = 0; history = false; report = false
	var result: Dictionary = view.action("biography-operation",view.navigation.context(),{"operation":"automatic" if method == "automatic" else "initialize"})
	if result.ok: report = method == "automatic" and complete(view)
	refresh(view)

func complete(view: RefCounted) -> bool:
	var value: Dictionary = view.owner.projection().selections.get("biography",{})
	return not value.is_empty() and value.answers.size() == view.inputs.templates[value.template].questions.size()

func dismiss_report(view: RefCounted) -> void:
	report = false
	view.action("next",view.navigation.context())
	refresh(view)

func refresh(view: RefCounted) -> void:
	view._render_generation += 1
	view.shell.schedule_render()

func disclosure(view: RefCounted, answer: Dictionary) -> String:
	var lines: Array[String] = []
	for effect in answer.effects:
		var p: Dictionary = effect.parameters
		match effect.type:
			"narrative_token": continue
			"classic_ae_declaration","classic_af_declaration": lines.append("History only; no mechanical effect (DFU baseline).")
			"skill_adjustment":
				var id: String = view.inputs.skill_numbers[effect.target]
				lines.append(str(view.inputs.policy.skills[id].label)+" %+d" % p.amount)
			"item_grant":
				var key := "%d:%d" % [p.group,p.index]
				var item: Dictionary = view.inputs.biography_items[key].record.value.data
				lines.append("Random book; exact title and cover remain a surprise." if p.group == 7 else str(item.name)+("; randomized quantity remains a surprise." if p.group == 3 and p.index == 18 else "; one item"+("; "+str(view.inputs.biography_policy.rewards.material_labels[p.material]) if p.group in [2,3] else "")))
			"gold_adjustment": lines.append("Gold %+d; cannot leave carried gold below zero." % p.amount)
			"social_reputation": lines.append(str(view.inputs.biography_policy.disclosure.social[effect.target.trim_prefix("classic.social:")])+" reputation %+d" % p.amount)
			"faction_reputation": lines.append(str(view.inputs.biography_factions[effect.target].label)+" reputation %+d" % p.amount)
			_: lines.append(str(view.inputs.biography_policy.disclosure.modifiers[effect.type])+": %+d (replaces an earlier biography modifier of this kind)." % p.amount)
	return "\n".join(lines)

func render(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	if _draft != expected.token.id: _draft = expected.token.id; position = 0; history = false; report = false
	var value: Dictionary = selected.get("biography",{})
	if value.is_empty() or history:
		render_review(view,expected,selected)
		return
	if report and selected.get("biography_method") == "automatic":
		var image: Dictionary = view.shell.host.controller.providers.creation_art.resolve("creation.biography-method")
		if image.ok:
			var picture := TextureRect.new(); picture.texture = image.texture; picture.position = Vector2(136,32); picture.size = Vector2(368,336)
			picture.mouse_filter = Control.MOUSE_FILTER_IGNORE; view._page.add_child(picture)
	else:
		var template: Dictionary = view.inputs.templates[value.template]
		position = clampi(position,0,template.questions.size()-1)
		var question: Dictionary = template.questions[position]
		var root := Native.root(view)
		var prompt := Native.text(view,root,question.text,Rect2(30,23,276,44),"biography.question")
		prompt.add_theme_constant_override("line_spacing",4)
		for index in question.answers.size():
			var answer: Dictionary = question.answers[index]
			var rect := Rect2(10+149*(index%2),71+24*(index/2),149,24)
			Native.text(view,root,answer.text,Rect2(rect.position+Vector2(21,5),Vector2(126,18)),"biography.answer")
			Native.button(view,root,"biography-answer/"+question.id+"/"+answer.id,answer.text,rect,func():
				var result: Dictionary = view.action("biography-operation",expected,{"operation":"answer","payload":{"question":question.id,"answer":answer.id}})
				if result.ok:
					Native.click(view)
					if position == template.questions.size()-1 and complete(view): report = true
					else: position = mini(position+1,template.questions.size()-1)
					refresh(view),report or view.navigation.summary_locked())
		if not report:
			var controls := HBoxContainer.new(); view.shell.host.panel.add_child(controls)
			if selected.get("biography_method") == "automatic" and not complete(view):
				var automatic := Button.new(); automatic.text = "Choose remaining answers automatically"
				automatic.disabled = view.navigation.summary_locked(); controls.add_child(automatic)
				view._bind_button(automatic,"biography-complete-automatic",func():
					if view.action("biography-operation",expected,{"operation":"automatic"}).ok:
						Native.click(view); report = complete(view); refresh(view))
			for item in [["biography-previous","Previous question",-1],["biography-following","Next question",1],["biography-history","Read history",0]]:
				var button := Button.new(); button.text = item[1]; controls.add_child(button)
				view._bind_button(button,item[0],func():
					Native.click(view)
					if item[2] == 0: history = true
					else: position = clampi(position+item[2],0,template.questions.size()-1)
					refresh(view))
	if report:
		preload("res://scripts/ui/creation_biography_reputation.gd").render(self,view,expected,value)

func render_review(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var value: Dictionary = selected.get("biography",{})
	if value.is_empty():
		view._text(view._box(Rect2(20,20,600,240)),"Your biography will retain its template, answers and first-selection random rewards. You can review and revise answers before final summary.")
		var automatic: bool = selected.get("biography_method") == "automatic"
		view._button("biography-initialize","Generate biography" if automatic else "Begin questions",Rect2(100,294,400,46),func(): view.action("biography-operation",expected,{"operation":"automatic" if automatic else "initialize"}))
		view._buttons["biography-initialize"].disabled = view.navigation.summary_locked()
		return
	var template: Dictionary = view.inputs.templates[value.template]
	position = clampi(position,0,template.questions.size()-1)
	var box: PanelContainer = view._box(Rect2(16,8,608,278))
	var scroll := ScrollContainer.new(); scroll.follow_focus = true; scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); box.add_child(scroll)
	var list := VBoxContainer.new(); list.size_flags_horizontal = Control.SIZE_EXPAND_FILL; scroll.add_child(list)
	if selected.get("biography_method") == "automatic" and value.answers.size() < template.questions.size():
		var automatic := Button.new(); automatic.text = "Choose remaining answers automatically"; automatic.custom_minimum_size.y = 36
		automatic.disabled = view.navigation.summary_locked(); list.add_child(automatic)
		view._bind_button(automatic,"biography-complete-automatic",func(): view.action("biography-operation",expected,{"operation":"automatic"}))
	if history:
		var evaluated: Dictionary = view.inputs.Bio.evaluate(value,template,view.inputs.biography_policy,view.inputs.biography_texts,view.inputs.skill_numbers,selected.race)
		view._text(list,evaluated.backstory if evaluated.ok else evaluated.reason)
		view._text(list,"Selected answers")
		for q in template.questions:
			for answer in q.answers:
				if answer.id == value.answers.get(q.id): view._text(list,q.text+"\n"+answer.text+"\n"+disclosure(view,answer))
	else:
		var question: Dictionary = template.questions[position]
		view._text(list,"Question %d of %d\n%s" % [position+1,template.questions.size(),question.text])
		for answer in question.answers:
			var button := Button.new(); button.text = answer.text
			button.toggle_mode = true; button.button_pressed = value.answers.get(question.id) == answer.id
			button.disabled = view.navigation.summary_locked()
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; button.custom_minimum_size.y = 34
			list.add_child(button)
			view._bind_button(button,"biography-answer/"+question.id+"/"+answer.id,func(): view.action("biography-operation",expected,{"operation":"answer","payload":{"question":question.id,"answer":answer.id}}))
			view._text(list,disclosure(view,answer))
	view._button("biography-previous","Previous question",Rect2(8,294,172,46),func(): position = maxi(0,position-1); history = false; refresh(view))
	view._button("biography-following","Next question",Rect2(188,294,158,46),func(): position = mini(template.questions.size()-1,position+1); history = false; refresh(view))
	view._button("biography-history","Answers" if history else "Read history",Rect2(354,294,150,46),func(): history = not history; refresh(view))
