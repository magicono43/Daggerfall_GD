extends "res://tests/creation_picker_preview.gd"
const Draft = preload("res://scripts/char/creation_draft.gd")

func panel(view: RefCounted) -> Control:
	for child in view._page.get_children():
		if child.get_meta("custom_reputation",false): return child
	return null

func set_bar(view: RefCounted, group: String, value: int) -> void:
	var control: Control = view._buttons["reputation/"+group]
	var position: Vector2 = control.get_global_transform_with_canvas()*Vector2(control.size.x/2,76-value*5-24)
	await move(position)
	var event := InputEventMouseButton.new(); event.position = position; event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true
	Input.parse_input_event(event); await settle()
	event = event.duplicate(); event.pressed = false
	Input.parse_input_event(event); await settle()

func remaining(view: RefCounted) -> String:
	for node in panel(view).get_children():
		if node.get_meta("reputation_remaining",false): return node.text
	return "missing"

func run(checks: RefCounted, host: Control, view: RefCounted, fixture: Dictionary) -> Dictionary:
	suite = checks; shell = host
	shell.get_window().title = "Reputation menu — focused preview"
	suite.check("reputation submenu opens",3,view.career_view.custom_tab)
	suite.check("reputation source image",true,shell.controller.providers.creation_art.resolve("creation.reputation").ok)
	suite.check("reputation native panel",Vector2(168,189),panel(view).size)
	suite.check("empty reputation balance","0",remaining(view))
	suite.check("reputation parent sheet blocked",true,view._buttons["hp/up"].disabled)
	suite.check("reputation redundant Next hidden",false,view._buttons.next.visible)
	await move(Vector2(2,2))
	await capture("reputation-empty",fixture)
	if not fixture.get("review_smoke",false):
		if fixture.get("preview_close_test",false):
			await set_bar(view,"merchants",10)
			await mouse(view._buttons["custom/close-panel"])
			suite.check("close test includes live warning",true,view.career_view.reputation_warning)
		return suite.save(str(fixture.sandbox).path_join("preview-state.json"))
	var art: RefCounted = shell.controller.providers.creation_art
	var clicks: int = art.click_submissions
	var expected := {"merchants":10,"commoners":-5,"scholars":3,"nobility":-10,"underworld":2}
	for group: String in expected:
		await set_bar(view,group,expected[group])
		suite.check("bar click publishes "+group,expected[group],view.owner.projection().selections.custom.reputation[group])
	suite.check("five reputation changes play five clicks",clicks+5,art.click_submissions)
	suite.check("balanced remaining points","0",remaining(view))
	for child in panel(view).get_children():
		if child.get_meta("reputation_bar","") == "merchants":
			suite.check("positive bar source size",Vector2(5,50),child.size)
			suite.check("positive bar source color",Color(0.388,0.549,0.223),child.color)
		elif child.get_meta("reputation_bar","") == "nobility":
			suite.check("negative bar source size",Vector2(5,50),child.size)
			suite.check("negative bar source color",Color(0.580,0.031,0),child.color)
	await move(Vector2(2,2))
	await capture("reputation-balanced",fixture)
	var obsolete: Callable = view._buttons["reputation/merchants"].get_signal_connection_list("gui_input").back().callable
	await mouse(view._buttons["custom/close-panel"])
	suite.check("balanced Exit closes submenu",0,view.career_view.custom_tab)
	suite.check("balanced Exit stays in custom creator","custom",view.navigation.step().hook)
	suite.check("balanced values retained",true,Draft.same_value(expected,view.owner.projection().selections.custom.reputation))
	var stale := InputEventMouseButton.new(); stale.button_index = MOUSE_BUTTON_LEFT; stale.pressed = true
	var before_stale: int = art.click_submissions
	obsolete.call(stale); await settle()
	suite.check("retired bar callback plays no click",before_stale,art.click_submissions)
	suite.check("retired bar callback changes no values",true,Draft.same_value(expected,view.owner.projection().selections.custom.reputation))
	await mouse(view._buttons["custom/panel/3"])
	await set_bar(view,"scholars",5)
	await set_bar(view,"nobility",6)
	await set_bar(view,"underworld",5)
	suite.check("unbalanced remainder matches reference","-21",remaining(view))
	var unbalanced: Dictionary = view.owner.projection().selections.custom.reputation.duplicate(true)
	await mouse(view._buttons["custom/close-panel"])
	suite.check("unbalanced Exit raises warning",true,view.career_view.reputation_warning)
	suite.check("unbalanced Exit keeps submenu",3,view.career_view.custom_tab)
	var warning_text := ""
	for node: Label in view._page.find_children("*","Label",true,false):
		if node.get_meta("creation_popup_text",false): warning_text = node.text
	suite.check("warning source text","Reputation balance must equal zero before exiting.",warning_text)
	await move(Vector2(2,2))
	await capture("reputation-warning",fixture)
	await mouse(view._buttons["notice/dismiss"])
	suite.check("click dismisses warning",false,view.career_view.reputation_warning)
	suite.check("warning dismissal preserves submenu",3,view.career_view.custom_tab)
	await mouse(view._buttons["custom/close-panel"])
	await key(KEY_ESCAPE)
	suite.check("Escape dismisses warning first",false,view.career_view.reputation_warning)
	suite.check("first Escape keeps submenu",3,view.career_view.custom_tab)
	await key(KEY_ESCAPE)
	suite.check("unbalanced Escape keeps reputation menu",3,view.career_view.custom_tab)
	suite.check("unbalanced Escape raises same warning",true,view.career_view.reputation_warning)
	suite.check("Escape stays on custom sheet","custom",view.navigation.step().hook)
	suite.check("Escape retains unbalanced draft values",true,Draft.same_value(unbalanced,view.owner.projection().selections.custom.reputation))
	suite.check("owner still reports unbalanced reputation",-21,view.owner.projection().validated.custom.provenance.evaluation.reputation_remaining)
	await key(KEY_ESCAPE)
	await suite.press(shell,view,"back")
	suite.check("unbalanced toolbar Back cannot bypass balance",3,view.career_view.custom_tab)
	suite.check("unbalanced toolbar Back warns",true,view.career_view.reputation_warning)
	await key(KEY_ESCAPE)
	view._buttons["reputation/merchants"].grab_focus()
	await key(KEY_DOWN)
	suite.check("keyboard adjusts focused column",9,view.owner.projection().selections.custom.reputation.merchants)
	await key(KEY_HOME)
	suite.check("keyboard clamps to configured maximum",10,view.owner.projection().selections.custom.reputation.merchants)
	for group: String in expected: await set_bar(view,group,0)
	await mouse(view._buttons["custom/close-panel"])
	suite.check("rebalanced Exit succeeds",0,view.career_view.custom_tab)
	await mouse(view._buttons["custom/panel/3"])
	await key(KEY_ESCAPE)
	suite.check("balanced Escape closes only submenu",0,view.career_view.custom_tab)
	suite.check("balanced Escape stays in custom creator","custom",view.navigation.step().hook)
	await mouse(view._buttons["custom/panel/3"])
	await suite.press(shell,view,"back")
	suite.check("toolbar Back closes submenu",0,view.career_view.custom_tab)
	suite.check("toolbar Back keeps custom creator","custom",view.navigation.step().hook)
	return suite.save(str(fixture.sandbox).path_join("result.json"))
