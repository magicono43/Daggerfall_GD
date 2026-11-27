extends RefCounted
const Native = preload("res://scripts/ui/creation_native_controls.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")

static func normalized(text: String) -> String:
	return "\n".join(Array(text.split("\n")).map(func(line): return str(line).strip_edges()))

static func render(career: RefCounted, view: RefCounted, expected: Dictionary, selected: Dictionary) -> void:
	if not is_instance_valid(career.questionnaire_runtime):
		career.questionnaire_runtime = preload("res://scripts/ui/creation_questionnaire_runtime.gd").new()
		view.shell.host.add_child(career.questionnaire_runtime)
	var runtime: Node = career.questionnaire_runtime
	var root := Native.root(view)
	var canvas := preload("res://scripts/ui/creation_questionnaire_canvas.gd").new()
	canvas.size = Vector2(320,200); root.add_child(canvas); canvas.set_meta("questionnaire_canvas",true)
	var generation: int = view._render_generation
	var current := func(): return generation == view._render_generation and view.active() and not view.shell.core.busy() and Draft.same_value(expected,view.navigation.context()) and view.navigation.step().hook == "questionnaire"
	canvas.valid = current
	var value: Dictionary = selected.questionnaire
	var question_id: String = value.questions[career.question_position]
	var question: Dictionary = view.inputs.sources.questionnaire.questions[question_id]
	var art: RefCounted = view.shell.host.controller.providers.creation_art
	var scores := [0,0,0]
	for id in value.answers:
		if runtime.playing and id == question_id: continue
		scores[int(view.inputs.policy.answer_categories[int(str(id).trim_prefix("question-"))][value.answers[id]])] += 1
	var mask: Dictionary = art.resolve("creation.questionnaire.mask")
	if mask.ok:
		var stars := TextureRect.new(); stars.texture = mask.texture; stars.size = Vector2(320,200); stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var material := ShaderMaterial.new(); material.shader = preload("res://scripts/ui/creation_questionnaire_mask.gdshader")
		material.set_shader_parameter("levels",Vector3(8+24*scores[1],8+24*scores[2],8+24*scores[0])/255.0)
		stars.material = material; canvas.add_child(stars)
	var assets := {}
	for id in ["rogue","mage","warrior"]:
		var resource: Dictionary = art.resolve("creation.questionnaire."+id)
		if resource.ok and (resource.texture.get_height()%119 != 0 or resource.texture.get_height()/119 > 128): resource = {"ok":false,"reason":"Questionnaire animation requires at most 128 vertical frames of height 119."}
		assets[id] = resource
	canvas.set_meta("questionnaire_scores",scores.duplicate())
	canvas.answer = func(index: int):
		if not current.call() or runtime.playing: return
		var revised := value.duplicate(true); revised.answers[question_id] = index
		var result: Dictionary = view.action("edit",expected,revised)
		if not result.ok: return
		view._focus = "back"; career.custom_keyboard_focus = false
		var category: int = view.inputs.policy.answer_categories[int(question_id.trim_prefix("question-"))][index]
		var asset: Dictionary = assets[["warrior","rogue","mage"][category]]
		var count: int = asset.texture.get_height()/119 if asset.ok else 0
		var delay: int = asset.get("provenance",{}).get("delay_msec",71)
		runtime.start(view,category,count,delay)
		if career._play_creation_clip(view,art.media.resolve("creation.questionnaire.ignite","audio")): runtime.ignite_submissions += 1
	if runtime.playing:
		var asset: Dictionary = assets[["warrior","rogue","mage"][runtime.category]]
		if asset.ok:
			canvas.effect_frames = asset.texture.get_height()/119; canvas.effect_delay = asset.provenance.get("delay_msec",71)
			canvas.effect_atlas = AtlasTexture.new(); canvas.effect_atlas.atlas = asset.texture; canvas.effect_atlas.region = Rect2(0,0,asset.texture.get_width(),119)
			canvas.effect = TextureRect.new(); canvas.effect.texture = canvas.effect_atlas; canvas.effect.size = Vector2(asset.texture.get_width(),119); canvas.effect.position = Vector2([110,1,79][runtime.category],1); canvas.effect.mouse_filter = Control.MOUSE_FILTER_IGNORE; canvas.add_child(canvas.effect)
			runtime.canvas = weakref(canvas); canvas.update_animation(Time.get_ticks_msec()-runtime.started)
	var scroll: Dictionary = art.resolve("creation.questionnaire.scroll")
	if scroll.ok:
		canvas.scroll_atlas = AtlasTexture.new(); canvas.scroll_atlas.atlas = scroll.texture; canvas.scroll_atlas.region = Rect2(0,0,320,80)
		var image := TextureRect.new(); image.texture = canvas.scroll_atlas; image.position = Vector2(0,120); image.size = Vector2(320,80); image.mouse_filter = Control.MOUSE_FILTER_IGNORE; canvas.add_child(image)
	else:
		var fallback := ColorRect.new(); fallback.color = Color("b88f59"); fallback.position = Vector2(0,120); fallback.size = Vector2(320,80); fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE; canvas.add_child(fallback)
	var clipped := Control.new(); clipped.position = Vector2(0,136); clipped.size = Vector2(320,48); clipped.clip_contents = true; clipped.mouse_filter = Control.MOUSE_FILTER_IGNORE; canvas.add_child(clipped)
	canvas.body = Control.new(); canvas.body.size = Vector2(320,1); clipped.add_child(canvas.body)
	var y := 0.0
	var prompt := Native.text(view,canvas.body,normalized(question.text),Rect2(40,y,270,7),"questionnaire.question")
	prompt.add_theme_color_override("font_color",Color.BLACK); prompt.add_theme_color_override("font_shadow_color",Color.TRANSPARENT)
	y += prompt.get_minimum_size().y
	for index in 3:
		var label := Native.text(view,canvas.body,normalized(question.answers[index]),Rect2(40,y,270,7),"questionnaire.answer."+str(index))
		label.add_theme_color_override("font_color",Color.BLACK); label.add_theme_color_override("font_shadow_color",Color.TRANSPARENT)
		var marker := Native.text(view,canvas.body,["a)","b)","c)"][index],Rect2(20,y,20,7),"questionnaire.marker")
		marker.add_theme_color_override("font_color",Color.BLACK); marker.add_theme_color_override("font_shadow_color",Color.TRANSPARENT)
		var height := maxf(7,label.get_minimum_size().y)
		Native.button(view,canvas.body,"answer/"+str(index),str(question.answers[index]),Rect2(15,y,305,height),func(): canvas.answer.call(index),runtime.playing)
		y += height
	canvas.body.size.y = y; canvas.max_scroll = maxf(0,y-48)
	for direction in [-1,1]:
		var button := Native.button(view,canvas,"question/scroll/"+str(direction),"Scroll up" if direction < 0 else "Scroll down",Rect2(0,120 if direction < 0 else 184,320,16),func(): canvas.scroll_by(direction))
		button.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				canvas.held = direction if event.pressed else 0; canvas._pointer = button.get_global_transform_with_canvas()*event.position; button.accept_event())
	var review := HBoxContainer.new(); view.shell.host.panel.add_child(review)
	for direction in [-1,1]:
		var button := Button.new(); button.text = "Previous question" if direction < 0 else "Next question"; review.add_child(button)
		view._bind_button(button,"question/back" if direction < 0 else "question/next",func():
			if current.call() and not runtime.playing: career.question_position = clampi(career.question_position+direction,0,9); career.refresh(view))
		button.disabled = runtime.playing or (career.question_position == 0 if direction < 0 else career.question_position == 9)
	var direct := Button.new(); direct.text = "Choose directly instead"; review.add_child(direct)
	view._bind_button(direct,"direct-route",func():
		if current.call(): view.action("career-route",expected,"list"))
