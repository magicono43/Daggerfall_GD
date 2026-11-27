extends RefCounted
## Classic framing with real, owner-validated name/portrait/reflex controls.
const Name = preload("res://scripts/ui/character_name.gd")
const Reflex = preload("res://scripts/char/reflex_parameters.gd")
const Native = preload("res://scripts/ui/creation_native_controls.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")
var _last_hook := ""
var _draft := ""

func render(view: RefCounted, expected: Dictionary, hook: String, selected: Dictionary) -> void:
	if hook == "name" and (_last_hook != hook or _draft != expected.token.id): view._focus = "name-field"
	_last_hook = hook; _draft = expected.token.id
	match hook:
		"name": name_page(view,expected,selected)
		"face": face_page(view,expected,selected)
		"reflexes": reflex_page(view,expected,selected)

func name_page(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var root := Native.root(view)
	var field := preload("res://scripts/ui/character_name_field.gd").new()
	field.text = str(view._working.get("name",selected.get("name","")))
	field.placeholder_text = ""
	field.set_meta("accessible_label","Character name")
	field.position = Vector2(80,3)
	field.size = Vector2(196,11)
	field.set_meta("creation_editor","name")
	field.add_theme_font_override("font",Native.font(view))
	field.add_theme_font_size_override("font_size",7)
	field.add_theme_color_override("font_color",preload("res://scripts/ui/creation_popup.gd").TEXT_COLOR)
	field.add_theme_color_override("caret_color",preload("res://scripts/ui/creation_popup.gd").TEXT_COLOR)
	for state in ["normal","focus","read_only"]: field.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	field.editable = not view.navigation.summary_locked()
	root.add_child(field)
	field.size = Vector2(196,11)
	view._editors["name-field"] = field
	var feedback := Label.new()
	if view._presentation != null: feedback.add_theme_font_override("font",view._presentation.font("body"))
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	view.shell.host.panel.add_child(feedback)
	field.rejected.connect(func(reason: String): feedback.text = reason)
	var validate_input := func(text: String):
		view._working.name = text
		var checked := Name.validate(text)
		feedback.text = "" if checked.ok or text.is_empty() else checked.reason
		var selected_font := Native.font(view)
		for index in text.length():
			if not selected_font.has_char(text.unicode_at(index)):
				view.display_text(text,"name") # Retain the existing glyph diagnostic.
				selected_font = view._presentation.font() if view._presentation != null else ThemeDB.fallback_font
				break
		field.add_theme_font_override("font",selected_font)
		field.size = Vector2(196,11)
	validate_input.call(field.text)
	field.caret_column = field.text.length()
	var generation: int = view._render_generation
	field.text_changed.connect(func(text: String):
		if generation == view._render_generation: validate_input.call(text))
	field.text_submitted.connect(func(text: String):
		if generation == view._render_generation:
			view._working.name = text
			var result: Dictionary = view.action("next",expected)
			if result.ok: Native.click(view))
	field.focus_entered.connect(func(): view._focus = "name-field")
	var random := Native.button(view,root,"random-name","Random",Rect2(279,3,36,10),func():
		if view.action("identity-operation",expected,"random-name").ok:
			Native.click(view); view._focus = "name-field",view.navigation.summary_locked())
	var shade := ColorRect.new(); shade.color = Color(0.5,0.5,0.5,0.75); shade.position = Vector2(279,3); shade.size = Vector2(36,10)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(shade); root.move_child(shade,root.get_children().find(random))
	Native.text(view,root,view.translated("action.random","Random"),Rect2(279,3,36,10),"name.random",true)
	Native.button(view,root,"apply-name","Use name",Rect2(263,172,39,22),func():
		if view.action("next",expected).ok: Native.click(view),view.navigation.summary_locked())
	if view._focus.is_empty() or view._focus == "back": view._focus = "name-field"
	if view._focus == "name-field": view.call_deferred("_focus_control",field,generation)

func draw_portrait(view: RefCounted, selected: Dictionary, rect: Rect2) -> void:
	var value: Variant = selected.get("face")
	if not value is Dictionary:
		view._text(view._box(rect),"Choose a portrait")
		return
	var resolved: Dictionary = view.inputs.portrait(value)
	if not resolved.ok:
		view._text(view._box(rect),"Portrait unavailable. Choose a replacement.")
		return
	var image := TextureRect.new()
	image.texture = resolved.texture
	image.position = rect.position
	image.size = rect.size
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view._page.add_child(image)

func face_page(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var set: Dictionary = view.inputs.face_set(selected)
	var root := Native.root(view)
	var shown: Dictionary = selected.get("face",{}).duplicate(true)
	if shown.is_empty() and not set.faces.is_empty(): shown = {"set":set.id,"id":set.faces[0].id}
	if not shown.is_empty():
		var resolved: Dictionary = view.inputs.portrait(shown)
		if resolved.ok:
			var portrait := TextureRect.new(); portrait.texture = resolved.texture
			portrait.position = Vector2(247,25)+(Vector2(64,40)-portrait.texture.get_size())/2
			portrait.size = portrait.texture.get_size(); portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
			portrait.set_meta("creation_face_portrait",shown.duplicate(true)); root.add_child(portrait)
		else: Native.text(view,root,"Portrait unavailable",Rect2(247,25,64,40),"face.unavailable")
	var select_shown := func():
		if selected.has("face"): return {"ok":true}
		return view.action("edit",expected,shown)
	for entry in [["portrait-previous","Previous",Rect2(245,69,42,9)],["portrait-next","Next",Rect2(287,69,26,9)]]:
		Native.button(view,root,entry[0],entry[1],entry[2],func():
			if not select_shown.call().ok: return
			if view.action("identity-operation",view.navigation.context(),entry[0]).ok: Native.click(view),view.navigation.summary_locked() or shown.is_empty())
	Native.button(view,root,"portrait-confirm","OK",Rect2(263,172,39,22),func():
		if not select_shown.call().ok: return
		if view.action("next",view.navigation.context()).ok: Native.click(view),view.navigation.summary_locked() or shown.is_empty())

func reflex_page(view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	var root := Native.root(view)
	var panel := Panel.new(); panel.position = Vector2(33,15); panel.size = Vector2(254,110)
	var parchment: StyleBox = view.shell.host.controller.providers.creation_art.parchment_style()
	if parchment == null:
		var fallback := StyleBoxFlat.new(); fallback.bg_color = Color("957044"); parchment = fallback
	panel.add_theme_stylebox_override("panel",parchment)
	root.add_child(panel)
	var explanation := Native.text(view,panel,view.translated("reflex.explanation","Player reflexes determine the overall speed of the game. If you pick VERY HIGH reflexes, the monsters will move and attack quickly, forcing you to be quick with the controls. VERY LOW reflexes means the monsters will move and attack slowly, allowing you to adopt a more cautious, thoughtful play style. Your character will advance a little slower with a lower reflex setting, and will advance a little faster with a higher reflex setting."),Rect2(15,17,224,84),"reflex.explanation",true)
	explanation.set_meta("creation_reflex_explanation",true)
	reflex_picker(view,root,expected,selected,Vector2(127,148))
	Native.button(view,root,"reflex-confirm","OK",Rect2(263,172,39,22),func():
		if view.action("next",expected).ok: Native.click(view))

func reflex_picker(view: RefCounted, root: Control, expected: Dictionary, selected: Dictionary, position: Vector2, summary := false) -> void:
	var art: Dictionary = view.shell.host.controller.providers.creation_art.resolve("creation.reflex-highlight")
	var chosen: int = Reflex.IDS.find(selected.get("reflexes"))
	if art.ok and chosen >= 0:
		var atlas := AtlasTexture.new(); atlas.atlas = art.texture; atlas.region = Rect2(0,chosen*9,66,9)
		var highlight := TextureRect.new(); highlight.texture = atlas; highlight.position = position+Vector2(0,9*chosen); highlight.size = Vector2(66,9); highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(highlight)
	for index in Reflex.IDS.size():
		var id: String = Reflex.IDS[index]
		Native.button(view,root,"reflex/"+id,str(view.inputs.identity.reflexes.get(id,{}).get("label",id)),Rect2(position+Vector2(0,9*index),Vector2(66,9)),func():
			var result: Dictionary = view.action("summary-change",expected,{"section":"reflexes","value":id}) if summary else view.action("edit",expected,id)
			if result.ok: Native.click(view))
