extends RefCounted
const Native = preload("res://scripts/ui/creation_native_controls.gd")
const Math = preload("res://scripts/char/starting_rolls.gd")
var attribute := 0
var skills := {"primary":0,"major":0,"minor":0}
var repeat: Node
var message := ""

func clear() -> void:
	if is_instance_valid(repeat): repeat.stop()
	attribute = 0; skills = {"primary":0,"major":0,"minor":0}; message = ""

func evaluation(view: RefCounted, hook: String, selected: Dictionary) -> Dictionary:
	var value: Dictionary = selected.get(hook,{})
	if value.is_empty(): return {"ok":false,"reason":"Starting rolls unavailable."}
	var resolved: Dictionary = view.inputs.career_context(view.owner.projection(),hook)
	if not resolved.ok: return resolved
	return Math.attributes(value.roll,resolved.career.attributes,view.inputs.starting.attributes,view.inputs.numeric,resolved.context) if hook == "attributes" else Math.skills(value.roll,resolved.career.tiers,view.inputs.starting.skills,view.inputs.adjustments(view.owner.projection()),resolved.context)

func change(view: RefCounted, hook: String, id: String, direction: int) -> Dictionary:
	var value: Dictionary = view.owner.projection().selections.get(hook,{}).duplicate(true)
	if value.is_empty(): return {"ok":false}
	value.roll.allocated[id] += direction
	var result: Dictionary = view.action("summary-change",view.navigation.context(),{"section":hook,"value":value}) if view.navigation.step().hook == "summary" else view.action("edit",view.navigation.context(),value)
	if result.ok: Native.click(view)
	return result

func image(view: RefCounted, root: Control, target: String, rect: Rect2) -> void:
	var art: Dictionary = view.shell.host.controller.providers.creation_art.resolve(target)
	if not art.ok: return
	var texture := TextureRect.new(); texture.texture = art.texture
	texture.position = rect.position; texture.size = rect.size
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(texture)

func arrow(view: RefCounted, root: Control, hook: String, id: String, direction: int, rect: Rect2, disabled: bool) -> void:
	var key := "starting/"+id+"/"+str(direction)
	var button := Native.button(view,root,key,"Increase" if direction > 0 else "Decrease",rect,func(): change(view,hook,id,direction),disabled)
	if not is_instance_valid(repeat):
		repeat = preload("res://scripts/ui/creation_allocation_repeat.gd").new(); view.shell.host.add_child(repeat)
	button.gui_input.connect(func(event: InputEvent):
		if not button.disabled and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: repeat.begin(view,hook,id,direction,key,button.get_global_transform_with_canvas()*event.position)
			else: repeat.stop()
			button.accept_event())

func render(view: RefCounted, expected: Dictionary, hook: String, selected: Dictionary) -> void:
	var evaluated := evaluation(view,hook,selected)
	if not evaluated.ok: render_legacy(view,expected,hook,selected); return
	var root := Native.root(view)
	draw(view,root,hook,selected,evaluated)
	if hook == "attributes":
		for entry in [["reroll-attributes","Reroll",Rect2(263,147,39,22)],["save-roll","Save Roll",Rect2(162,162,71,9)],["load-roll","Load Roll",Rect2(162,171,71,9)]]:
			Native.button(view,root,entry[0],entry[1],entry[2],func():
				if view.action("starting-operation",expected,entry[0]).ok and entry[0] != "reroll-attributes": Native.click(view),entry[0] == "load-roll" and selected.attributes.slot.is_empty())
	Native.button(view,root,"allocation-confirm","OK",Rect2(263,172,39,22),func():
		if not view.action("next",expected).ok: message = "You must distribute your bonus points."; view.shell.schedule_render()
		else: Native.click(view))
	if not message.is_empty(): preload("res://scripts/ui/creation_popup.gd").notice(view,message,func(): message = ""; view.shell.schedule_render(),"allocation")

func draw(view: RefCounted, root: Control, hook: String, selected: Dictionary, evaluated: Dictionary) -> void:
	var value: Dictionary = selected[hook]
	if hook == "attributes":
		for index in Math.Domain.ATTRIBUTES.size():
			var id: String = Math.Domain.ATTRIBUTES[index]
			var label := Native.text(view,root,str(evaluated.final[id]),Rect2(8,33+22*index,34,7),"attribute."+id,true)
			label.set_meta("allocation_value",id)
			if value.roll.allocated[id] > 0: label.add_theme_color_override("font_color",Color.GREEN)
			Native.button(view,root,"starting/select/"+id,str(view.inputs.policy.attributes[id].get("label",id.capitalize())),Rect2(7,20+22*index,35,20),func(): attribute = index; Native.click(view); view.shell.schedule_render())
		var active: String = Math.Domain.ATTRIBUTES[attribute]
		var y := 21+22*attribute
		image(view,root,"creation.stat-spinner",Rect2(44,y,15,20))
		Native.text(view,root,str(evaluated.remaining),Rect2(44,y+7,15,7),"attribute.remaining",true)
		arrow(view,root,hook,active,1,Rect2(44,y,15,7),evaluated.remaining <= 0 or evaluated.final[active] >= view.inputs.starting.attributes.values[active].cap)
		arrow(view,root,hook,active,-1,Rect2(44,y+13,15,7),value.roll.allocated[active] <= 0)
		if view.navigation.step().hook != "summary": derived(view,root,evaluated)
	else:
		var resolved: Dictionary = view.inputs.career_context(view.owner.projection(),hook)
		for tier in Math.TIERS:
			var top: int = {"primary":32,"major":81,"minor":130}[tier]
			for index in resolved.career.tiers[tier].size():
				var id: String = resolved.career.tiers[tier][index]
				var name: String = view.inputs.policy.skills[id].label
				Native.text(view,root,name,Rect2(68,top+10*index,106,8),"skill."+id)
				var label := Native.text(view,root,str(evaluated.final[id]),Rect2(185,top+10*index,14,8),"skill.value."+id,true)
				label.set_meta("allocation_value",id)
				if value.roll.allocated[id] > 0: label.add_theme_color_override("font_color",Color.GREEN)
				Native.button(view,root,"starting/select/"+id,name,Rect2(67,top-1+10*index,133,10),func(): skills[tier] = index; Native.click(view); view.shell.schedule_render())
			var active: String = resolved.career.tiers[tier][skills[tier]]
			var y: int = top-1+10*skills[tier]
			image(view,root,"creation.skill-spinner",Rect2(203,y,37,9))
			Native.text(view,root,str(evaluated.remaining[tier]),Rect2(214,y+1,15,7),"skill.remaining."+tier,true)
			arrow(view,root,hook,active,-1,Rect2(203,y,11,9),value.roll.allocated[active] <= 0)
			arrow(view,root,hook,active,1,Rect2(229,y,11,9),evaluated.remaining[tier] <= 0 or evaluated.final[active] >= view.inputs.starting.skills.limits[active].max)

func derived(view: RefCounted, root: Control, evaluated: Dictionary) -> void:
	var resolved: Dictionary = view.inputs.career_context(view.owner.projection(),"attributes")
	var multiplier: Dictionary = resolved.career.get("spell_points",{})
	if view.owner.projection().selections.get("class_method") == "custom": multiplier = view.inputs.custom_spell_points(resolved.career)
	multiplier = {"numerator":multiplier.get("numerator",-1),"denominator":multiplier.get("denominator",0)}
	var preview: Dictionary = view.owner.attribute_preview(view.shell.core,view.owner.token(),evaluated.final,multiplier)
	if not preview.ok: return
	for entry in [["damage",83,22],["capacity",103,32],["magicka",112,49],["resistance",121,71],["agility",97,93],["growth",101,110],["healing",122,120]]:
		var amount: int = preview.values[entry[0]]
		Native.text(view,root,("+" if amount > 0 and entry[0] in ["damage","agility","growth","healing"] else "")+str(amount),Rect2(entry[1],entry[2],35,7),"derived."+entry[0])

## Stock controls submit exact owner operations; repaint never generates a roll.
func render_legacy(view: RefCounted, expected: Dictionary, hook: String, selected: Dictionary) -> void:
	# Original screens contain baked spinners/buttons. Mask inactive hit-like art;
	# keep the original frame and real, token-guarded controls above the mask.
	var mask := ColorRect.new()
	mask.position = Vector2(8,286); mask.size = Vector2(624,114)
	mask.color = Color(0.09,0.11,0.10,1.0); mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view._page.add_child(mask)
	var value: Dictionary = selected.get(hook,{})
	var attribute_mode: bool = hook == "attributes" and not value.is_empty()
	var box: PanelContainer = view._box(Rect2(8,8,402 if attribute_mode else 624,278))
	var column := VBoxContainer.new(); box.add_child(column)
	if value.is_empty():
		view._text(column,"Generate the initial retained "+hook+" rolls. Navigation and previews do not reroll them.")
		view._button("generate-"+hook,"Roll starting "+hook,Rect2(110,294,390,46),func(): view.action("starting-operation",expected,"generate-"+hook))
		return
	var resolved: Dictionary = view.inputs.career_context(view.owner.projection(),hook)
	if not resolved.ok: view._text(column,resolved.reason); return
	var math = preload("res://scripts/char/starting_rolls.gd")
	var beta: Dictionary = view.inputs.adjustments(view.owner.projection())
	var evaluated: Dictionary = math.attributes(value.roll,resolved.career.attributes,view.inputs.starting.attributes,view.inputs.numeric,resolved.context) if hook == "attributes" else math.skills(value.roll,resolved.career.tiers,view.inputs.starting.skills,beta,resolved.context)
	if not evaluated.ok: view._text(column,evaluated.reason); return
	view._text(column,"Remaining: %d · allocate every point" % evaluated.remaining if attribute_mode else "Remaining · Primary %d · Major %d · Minor %d" % [evaluated.remaining.primary,evaluated.remaining.major,evaluated.remaining.minor])
	view._text(column,"Attribute · Rolled + Added = Final" if attribute_mode else "Skill · Rolled + Added + Biography = Final")
	var scroll := ScrollContainer.new()
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation",2)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var identities: Array = math.Domain.ATTRIBUTES if hook == "attributes" else value.roll.base.keys()
	var membership: Dictionary = {} if hook == "attributes" else math.membership(resolved.career.tiers,view.inputs.starting.skills.limits).membership
	for id in identities:
		var row := HBoxContainer.new(); list.add_child(row)
		var label := Label.new()
		label.text = view.display_text(str(view.inputs.policy.attributes[id].get("label",str(id).capitalize())) if hook == "attributes" else str(view.inputs.policy.skills.get(id,{}).get("label",id)))
		if not attribute_mode: label.text += " · "+str(membership.get(id,"other")).capitalize()
		label.custom_minimum_size.x = 105 if attribute_mode else 165
		label.add_theme_font_size_override("font_size",16)
		if view._presentation != null: label.add_theme_font_override("font",view._presentation.font("body"))
		row.add_child(label)
		var amounts := Label.new()
		amounts.text = "%d   +%d   %s%d" % [value.roll.base[id],value.roll.allocated[id],("%+d   " % beta.get(id,0)) if hook == "skills" else "",evaluated.final[id]]
		amounts.custom_minimum_size.x = 118 if attribute_mode else 200
		amounts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		amounts.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		amounts.add_theme_font_size_override("font_size",16)
		if attribute_mode: amounts.tooltip_text = "Class base %d + rolled bonus %d; allocation is separate." % [resolved.career.attributes[id],value.roll.base[id]-resolved.career.attributes[id]]
		row.add_child(amounts)
		if hook == "skills" and not membership.has(id): continue
		for direction in [-1,1]:
			var button := Button.new(); button.text = "−" if direction < 0 else "+"
			button.custom_minimum_size = Vector2(52 if attribute_mode else 64,24 if attribute_mode else 32); row.add_child(button)
			button.disabled = (direction < 0 and value.roll.allocated[id] == 0) or (direction > 0 and (evaluated.remaining if hook == "attributes" else evaluated.remaining[membership[id]]) == 0)
			view._bind_button(button,"starting/"+id+"/"+str(direction),func():
				var candidate := value.duplicate(true)
				candidate.roll.allocated[id] += direction
				view.action("edit",expected,candidate))
	if hook == "attributes":
		var preview_box: PanelContainer = view._box(Rect2(418,8,214,278))
		var preview_scroll := ScrollContainer.new(); preview_scroll.follow_focus = true; preview_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		preview_box.add_child(preview_scroll)
		var previews := VBoxContainer.new(); previews.size_flags_horizontal = Control.SIZE_EXPAND_FILL; preview_scroll.add_child(previews)
		var multiplier: Dictionary = resolved.career.get("spell_points",{})
		if view.owner.projection().selections.get("class_method") == "custom": multiplier = view.inputs.custom_spell_points(resolved.career)
		multiplier = {"numerator":multiplier.get("numerator",-1),"denominator":multiplier.get("denominator",0)}
		var preview: Dictionary = view.owner.attribute_preview(view.shell.core,expected.token,evaluated.final,multiplier)
		if preview.ok:
			for pair in [["damage","Damage modifier"],["capacity","Encumbrance (kg)"],["magicka","Spell points"],["resistance","Magic resist. (attr.)"],["agility","To-hit modifier"],["growth","HP modifier"],["healing","Healing rate mod."]]: view._text(previews,pair[1]+": "+str(preview.values[pair[0]]))
			view._text(previews,"Class magery included. Excludes later racial, biography and runtime effects.")
		else: view._text(previews,"Derived preview unavailable: "+preview.reason)
		for entry in [["reroll-attributes","Reroll"],["save-roll","Save Roll"],["load-roll","Load Roll"]]:
			var index: int = ["reroll-attributes","save-roll","load-roll"].find(entry[0])
			view._button(entry[0],entry[1],Rect2(8+index*166,294,158,46),func(): view.action("starting-operation",expected,entry[0]))
			if entry[0] == "load-roll": view._buttons[entry[0]].disabled = value.slot.is_empty()
	else:
		for error in evaluated.errors: view._text(list,error)
