extends RefCounted
## Stock controls submit exact owner operations; repaint never generates a roll.
func render(view: RefCounted, expected: Dictionary, hook: String, selected: Dictionary) -> void:
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
