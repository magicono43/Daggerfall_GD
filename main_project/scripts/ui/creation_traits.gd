extends RefCounted
## Local picker candidates never enter CHAR until the complete variant is chosen.
const Sheet = preload("res://scripts/ui/creation_custom_sheet.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")
const Custom = preload("res://scripts/char/custom_career.gd")
const PRIMARY = {"expertise":"Expertise In","forbidden_armor":"Forbidden Armor Type","forbidden_shield":"Forbidden Shield Types","no_spell_point_regeneration":"Inability To Regen Spell Points"}
const TARGET_LABELS = {"darkness":"In Darkness","light":"In Light","immersed":"While Immersed","holy_places":"From Holy Places","sunlight":"From Sunlight","lower_daylight":"Lower Magic Ability In Daylight","unable_daylight":"Unable To Use Magic In Daylight","lower_darkness":"Lower Magic Ability In Darkness","unable_darkness":"Unable To Use Magic In Darkness","blunt":"Blunt Weapon","hand_to_hand":"Hand-To-Hand","missile":"Missile Weapon","kite":"Kite Shield","round":"Round Shield","tower":"Tower Shield"}

static func names(view: RefCounted, id: String) -> Array:
	var option: Dictionary = view.inputs.policy.traits[id]
	var pieces: PackedStringArray = str(option.label).split(":",true,1)
	var primary: String = PRIMARY.get(option.category,pieces[0])
	var secondary := ""
	if pieces.size() > 1:
		secondary = pieces[1].strip_edges()
		if option.category in ["immunity","resistance","low_tolerance","critical_weakness"]: secondary = "To "+secondary
		elif option.category == "increased_magery": secondary = str(option.target)+"X INT In Spell Points"
		else: secondary = TARGET_LABELS.get(option.target,secondary)
	return [view.translated("trait.category."+option.category,primary).to_upper(),view.translated("trait.variant."+id.replace("/","."),secondary).to_upper() if not secondary.is_empty() else ""]

static func render(career: RefCounted, view: RefCounted, expected: Dictionary, value: Dictionary) -> void:
	var side := "advantage" if career.custom_tab == 1 else "disadvantage"
	var art: RefCounted = view.shell.host.controller.providers.creation_art
	var font: Font = art.small_font(ThemeDB.fallback_font)
	if view._presentation != null: font = view._presentation.creation_popup_font(font)
	var root := Control.new(); root.size = Vector2(168,200); root.scale = Vector2(2,2)
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.set_meta("custom_traits",side); view._page.add_child(root)
	var image: Dictionary = art.resolve("creation.traits")
	if image.ok:
		var background := TextureRect.new(); background.texture = image.texture
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(background)
	if side == "advantage":
		var overlay: Dictionary = art.resolve("creation.traits-advantages")
		if overlay.ok:
			var background := TextureRect.new(); background.texture = overlay.texture
			background.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(background)
	var generation: int = view._render_generation
	var tab: int = career.custom_tab
	var current := func(): return generation == view._render_generation and view.active() and not view.shell.core.busy() and Draft.same_value(expected,view.navigation.context()) and career.custom_tab == tab and not view.navigation.summary_locked()
	var selected: Array = []
	for id: String in value.traits:
		if view.inputs.policy.traits[id].side == side: selected.append(id)
	var picking: bool = not career.trait_stage.is_empty()
	var locked: bool = view.navigation.summary_locked() or picking
	var scroll := ScrollContainer.new(); scroll.position = Vector2(8,35); scroll.size = Vector2(153,141)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; scroll.follow_focus = true
	root.add_child(scroll)
	var rows := VBoxContainer.new(); rows.add_theme_constant_override("separation",0)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL; scroll.add_child(rows)
	for id: String in selected:
		var text := names(view,id)
		var height := 14 if not text[1].is_empty() else 8
		var row := Control.new(); row.custom_minimum_size.y = height; rows.add_child(row)
		for index in (2 if not text[1].is_empty() else 1):
			var ink := Sheet.label(row,text[index],Rect2(0,index*6,150,5),font)
			ink.add_theme_font_size_override("font_size",5)
		Sheet.button(view,row,"remove/"+id,"Remove "+str(view.inputs.policy.traits[id].label),Rect2(0,0,150,height),func():
			if not current.call(): return
			var revised := value.duplicate(true); revised.traits.erase(id)
			view.action("edit",expected,revised),locked)
	Sheet.button(view,root,"traits/add","Add "+side,Rect2(80,4,72,22),func():
		if not current.call(): return
		art.play_dialog_click(view.shell.host)
		if selected.size() >= int(view.inputs.policy.limits[side]): return
		career.trait_stage = "category"; career.trait_category = ""; career.refresh(view),locked)
	Sheet.button(view,root,"custom/close-panel","Return to career",Rect2(6,179,155,13),func():
		if current.call(): art.play_dialog_click(view.shell.host); career.custom_tab = 0; career.refresh(view),locked)
	if not picking: return
	var ids: Array = []
	var labels: Array = []
	for id: String in view.inputs.policy.traits:
		var option: Dictionary = view.inputs.policy.traits[id]
		if option.side != side: continue
		if career.trait_stage == "category":
			if option.category in ids: continue
			ids.append(option.category); labels.append(names(view,id)[0])
		elif option.category == career.trait_category:
			ids.append(id); labels.append(names(view,id)[1])
	var picker := preload("res://scripts/ui/classic_list_picker.gd").new()
	picker.position = Vector2(120,72); picker.scale = Vector2(2,2)
	picker.set_meta("custom_trait_picker",true); view._page.add_child(picker)
	var paper: Dictionary = art.resolve("creation.list-picker")
	var thumb: Dictionary = art.resolve("creation.scrollbar-thumb")
	picker.configure(labels,font,paper.texture if paper.ok else null,view.navigation.summary_locked(),-1,0,thumb.texture if thumb.ok else null,12,5)
	for index in ids.size(): view._buttons["trait/pick/"+ids[index]] = picker.buttons[index]
	picker.item_activated.connect(func(index: int):
		if not current.call(): return
		var id: String = ids[index]
		if career.trait_stage == "category":
			var variants: Array = []
			for key: String in view.inputs.policy.traits:
				if view.inputs.policy.traits[key].category == id: variants.append(key)
			if variants.is_empty(): return
			var option: Dictionary = view.inputs.policy.traits[variants[0]]
			if option.singleton:
				for existing: String in value.traits:
					if view.inputs.policy.traits[existing].category == id:
						career.trait_stage = ""; career.refresh(view); return
			if option.target != "none":
				career.trait_category = id; career.trait_stage = "variant"; career.refresh(view); return
			id = variants[0]
		career.trait_stage = ""; career.trait_category = ""
		var revised := value.duplicate(true); revised.traits.append(id)
		# Keep owner validation authoritative. Expected selection conflicts reject
		# silently here, with the previously accepted class and gauge retained.
		if Custom.conflict(view.inputs.policy,value.traits,id).is_empty() and selected.size() < int(view.inputs.policy.limits[side]): view.action("edit",expected,revised)
		career.refresh(view))
