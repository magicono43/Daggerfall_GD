extends "res://tests/creation_picker_preview.gd"

func canvas(view: RefCounted) -> Control:
	for node in view._page.find_children("*","Control",true,false):
		if node.get_meta("questionnaire_canvas",false): return node
	return null

func finish_animation(view: RefCounted) -> void:
	var deadline := Time.get_ticks_msec()+5000
	while is_instance_valid(view.career_view.questionnaire_runtime) and view.career_view.questionnaire_runtime.playing and Time.get_ticks_msec() < deadline: await shell.get_tree().process_frame
	await settle()

func choose(view: RefCounted, index: int) -> void:
	# Keyboard a/b/c is the stock DFU alternative to scrolling an answer into view.
	await key([KEY_A,KEY_B,KEY_C][index])

func palette_check(view: RefCounted, category: int, expected_blue: int) -> void:
	var art: RefCounted = shell.controller.providers.creation_art
	var mask: Image = art.resolve("creation.questionnaire.mask").texture.get_image()
	var target := Vector2i(-1,-1)
	for y in 119:
		for x in 320:
			var pixel := mask.get_pixel(x,y)
			if pixel.a > 0 and [pixel.b,pixel.r,pixel.g][category] > 0.5: target = Vector2i(x,y); break
		if target.x >= 0: break
	await RenderingServer.frame_post_draw
	var image := shell.get_viewport().get_texture().get_image()
	var point: Vector2 = canvas(view).get_global_transform_with_canvas()*(Vector2(target)+Vector2(0.5,0.5))
	var blue := roundi(image.get_pixelv(Vector2i(point)).b*255)
	suite.check("rendered constellation blue "+str(expected_blue),true,target.x >= 0 and absi(blue-expected_blue) <= 1)

func click_answer(view: RefCounted, index: int) -> void:
	var surface := canvas(view)
	var button: Control = view._buttons["answer/"+str(index)]
	var target := clampf(button.position.y-4,0,surface.max_scroll)
	while surface.scroll_offset != target: surface.scroll_by(1 if target > surface.scroll_offset else -1)
	await settle()
	var visible: Rect2 = button.get_global_rect().intersection(surface.body.get_parent().get_global_rect())
	suite.check("answer has visible mouse region",true,visible.has_area())
	var position := visible.get_center(); await move(position)
	var event := InputEventMouseButton.new(); event.position = position; event.global_position = position; event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true
	Input.parse_input_event(event); await settle(); event = event.duplicate(); event.pressed = false; Input.parse_input_event(event); await settle()

func run(checks: RefCounted, host: Control, view: RefCounted, fixture: Dictionary) -> Dictionary:
	suite = checks; shell = host
	suite.check("questionnaire initialized on method choice",true,view.owner.projection().selections.has("questionnaire"))
	var original: Dictionary = view.owner.projection().selections.questionnaire.duplicate(true)
	suite.check("ten fixed questions",10,original.questions.size())
	suite.check("questionnaire Next hidden",false,view._buttons.next.visible)
	var art: RefCounted = shell.controller.providers.creation_art
	for id in ["scroll","mask","rogue","mage","warrior"]:
		var resource: Dictionary = art.resolve("creation.questionnaire."+id)
		suite.check("questionnaire asset "+id,true,resource.ok)
		if not resource.ok: print(resource)
	if fixture.get("review_smoke",false): await palette_check(view,0,8)
	await capture("class-questionnaire-initial",fixture)
	if not fixture.get("review_smoke",false):
		if fixture.get("preview_close_test",false):
			await choose(view,0); await shell.get_tree().create_timer(0.2).timeout
			suite.check("shutdown while original animation active",true,view.career_view.questionnaire_runtime.playing)
			await capture("class-questionnaire-close-active",fixture)
		return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	var surface := canvas(view)
	suite.check("scroll content exceeds viewport",true,surface.max_scroll > 0)
	var button: Control = view._buttons["question/scroll/1"]
	var position := point(button); await move(position)
	var event := InputEventMouseButton.new(); event.position = position; event.global_position = position; event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true
	Input.parse_input_event(event); await shell.get_tree().create_timer(0.4).timeout
	event = event.duplicate(); event.pressed = false; Input.parse_input_event(event); await settle()
	suite.check("held scroll end moves text",true,surface.scroll_offset >= 10)
	suite.check("scroll advances cyclic original GFX frames",int(surface.scroll_offset)%16,surface.scroll_frame)
	var offset: float = surface.scroll_offset
	await shell.get_tree().create_timer(0.12).timeout
	suite.check("scroll release stops movement",offset,surface.scroll_offset)
	await capture("class-questionnaire-scrolled",fixture)
	await click_answer(view,0)
	suite.check("answer committed immediately",1,view.owner.projection().selections.questionnaire.answers.size())
	suite.check("answer submits Ignite",1,view.career_view.questionnaire_runtime.ignite_submissions)
	suite.check("answer starts constellation animation",true,view.career_view.questionnaire_runtime.playing)
	var first: Dictionary = view.owner.projection()
	await choose(view,1)
	suite.check("animation rejects second answer",first,view.owner.projection())
	suite.check("rejected animation input makes no sound",1,view.career_view.questionnaire_runtime.ignite_submissions)
	await shell.get_tree().create_timer(0.25).timeout
	await capture("class-questionnaire-trail",fixture)
	await finish_animation(view)
	suite.check("animation advances question",1,view.career_view.question_position)
	var category: int = view.inputs.policy.answer_categories[int(str(original.questions[0]).trim_prefix("question-"))][0]
	await palette_check(view,category,32)
	await capture("class-questionnaire-brighter",fixture)
	await mouse(view._buttons["question/back"])
	suite.check("review retains question order",original.questions,view.owner.projection().selections.questionnaire.questions)
	await choose(view,2); await finish_animation(view)
	suite.check("revision replaces one answer",1,view.owner.projection().selections.questionnaire.answers.size())
	var expected_scores := [0,0,0]
	expected_scores[int(view.inputs.policy.answer_categories[int(str(original.questions[0]).trim_prefix("question-"))][2])] = 1
	suite.check("constellation brightness uses revised category only",expected_scores,canvas(view).get_meta("questionnaire_scores"))
	for index in range(1,10): await choose(view,index%3); await finish_animation(view)
	suite.check("ten answers reach recommendation","class",view.navigation.step().hook)
	suite.check("recommendation is uncommitted",false,view.owner.projection().selections.has("class"))
	suite.check("recommendation has Yes No",true,view._buttons.has("confirm/yes") and view._buttons.has("confirm/no"))
	await capture("class-questionnaire-confirmation",fixture)
	await mouse(view._buttons["confirm/no"])
	suite.check("No opens direct picker","list",view.owner.projection().selections.class_method)
	suite.check("No picker includes Custom",true,view._buttons.has("preset/custom"))
	view.action("back",view.navigation.context()); await settle()
	await mouse(view._buttons["choice/questionnaire"])
	suite.check("reopening retains complete suggestion","class",view.navigation.step().hook)
	await mouse(view._buttons["confirm/yes"])
	suite.check("Yes continues to biography method","biography_method",view.navigation.step().hook)
	suite.check("Yes commits actual recommendation",true,view.owner.projection().selections.has("class"))
	suite.check("questionnaire creates no live actor",0,shell.session_shell.core.actors._actors.size())
	view.restart(); await settle()
	await suite.press(shell,view,"province/nord"); await mouse(view._buttons["confirm/yes"])
	await mouse(view._buttons["gender/female"]); await mouse(view._buttons["choice/questionnaire"])
	await choose(view,0)
	var runtime: Node = view.career_view.questionnaire_runtime
	var held_callback: Callable = view._buttons["answer/1"].pressed.get_connections()[0].callable
	suite.check("cancellation fixture has active animation",true,runtime.playing)
	view.exit(); await settle()
	suite.check("exit frees questionnaire animation controller",false,is_instance_valid(runtime))
	held_callback.call(); await settle()
	suite.check("retired answer cannot recreate draft",true,view.owner.projection().is_empty())
	suite.check("exit releases active Ignite voices",true,view.career_view._narrations.is_empty())
	return suite.save(str(fixture.sandbox).path_join("result.json"))
