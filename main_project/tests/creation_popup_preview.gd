extends RefCounted
## Focused rendered preview, not the full creation qualification fixture.
var checks: Array = []

func check(name: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":name,"expected":expected,"actual":actual})

func settle(shell: Control) -> void:
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame

func press(shell: Control, view: RefCounted, id: String) -> void:
	view._buttons[id].pressed.emit()
	await settle(shell)

func capture(shell: Control, path: String) -> void:
	await settle(shell)
	await RenderingServer.frame_post_draw
	shell.get_viewport().get_texture().get_image().save_png(path)

func save(path: String) -> Dictionary:
	var result := {"scope":"focused gender/race popup preview only","ok":checks.all(func(c): return c.expected == c.actual),"count":checks.size(),"checks":checks,"human_pass":false,"engine":Engine.get_version_info()}
	var output := FileAccess.open(path,FileAccess.WRITE)
	output.store_string(JSON.stringify(result,"\t")); output.close()
	return result

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	shell.get_window().title = "Gender popup — fast visual preview"
	shell.controller.settings.effective["startup/show_setup"] = true
	shell.controller.select_folder(fixture.classic_source)
	shell.controller.continue_to_menu("run")
	shell.session_shell.synchronize_startup()
	shell.session_shell.open_creation()
	var view: RefCounted = shell.session_shell.creation_view
	var art: RefCounted = shell.controller.providers.creation_art
	var clicks: int = art.click_submissions
	view.notice = "GENDER POPUP PREVIEW: uses the stock race and gender controls; no gameplay entry."
	shell.session_shell.render()
	await press(shell,view,"province/nord")
	var first_narration: AudioStreamPlayer = view.career_view._narrations.back()
	check("race remains uncommitted before Yes",false,view.owner.projection().selections.has("race"))
	await capture(shell,str(fixture.sandbox).path_join("race-popup.png"))
	await press(shell,view,"confirm/no")
	check("race No submits one click",clicks+1,art.click_submissions)
	check("race No returns to picker","",view.career_view.candidate)
	check("race No leaves choice uncommitted",false,view.owner.projection().selections.has("race"))
	check("race No preserves narration",true,is_instance_valid(first_narration) and first_narration.playing)
	await press(shell,view,"province/nord")
	check("race clips overlap",true,view.career_view._narrations.size() == 2 and first_narration.playing and view.career_view._narrations.back().playing)
	await press(shell,view,"confirm/yes")
	check("race Yes and page handoff preserve narration",true,is_instance_valid(first_narration) and first_narration.playing)
	check("race Yes submits one click",clicks+2,art.click_submissions)
	check("stock race confirmation reaches gender","gender",view.navigation.step().hook)
	check("preview confirms actual Nord race","nord",view.owner.projection().selections.get("race"))
	check("preview has no assigned gender",false,view.owner.projection().selections.has("gender"))
	check("gender redundant Next hidden",false,view._buttons.next.visible)
	check("gender uses stock map binding","creation.race",view.navigation.step().art)
	var label: Label
	for node: Label in view._page.find_children("*","Label",true,false):
		if node.get_meta("creation_popup_text",false): label = node
	check("gender prompt","Select thy character's gender.",label.text)
	check("gender uses non-SDF font","Daggerfall FONT0003",label.get_theme_font("font").get_font_name())
	check("gender prompt fits",true,label.get_minimum_size().y <= label.get_parent().size.y)
	check("male native sprite size",Vector2(32,16),view._buttons["gender/male"].size)
	check("female native sprite size",Vector2(32,16),view._buttons["gender/female"].size)
	await capture(shell,str(fixture.sandbox).path_join("gender-popup.png"))
	save(str(fixture.sandbox).path_join("preview-state.json"))
	if not fixture.get("review_smoke",false):
		while true: await shell.get_tree().process_frame
	await press(shell,view,"gender/male")
	check("male activation submits one click",clicks+3,art.click_submissions)
	check("click uses a nonempty audio stream",true,is_instance_valid(art._click_player) and art._click_player.stream.get_length() > 0)
	check("stock click selects DFU archive ordinal",360,art._click.get("provenance",{}).get("ordinal",-1))
	check("male stock handler commits choice","male",view.owner.projection().selections.get("gender"))
	check("male choice advances","class_method",view.navigation.step().hook)
	await press(shell,view,"back")
	check("Back returns to gender","gender",view.navigation.step().hook)
	check("Back retains male choice","male",view.owner.projection().selections.get("gender"))
	var late_female: Callable = view._buttons["gender/female"].get_signal_connection_list("pressed")[0].callable
	view._buttons["gender/female"].grab_focus()
	await settle(shell)
	var key := InputEventKey.new(); key.keycode = KEY_ENTER; key.pressed = true
	Input.parse_input_event(key)
	await settle(shell)
	key = InputEventKey.new(); key.keycode = KEY_ENTER; key.pressed = false
	Input.parse_input_event(key)
	await settle(shell)
	check("focused female keyboard handler commits","female",view.owner.projection().selections.get("gender"))
	check("female choice advances","class_method",view.navigation.step().hook)
	check("keyboard female submits one click",clicks+4,art.click_submissions)
	var retained: Dictionary = view.owner.projection()
	late_female.call()
	await settle(shell)
	check("obsolete choice callback leaves draft intact",retained,view.owner.projection())
	check("obsolete callback submits no click",clicks+4,art.click_submissions)
	await press(shell,view,"back")
	await press(shell,view,"back")
	check("gender Back reaches race picker","race",view.navigation.step().hook)
	var deadline := Time.get_ticks_msec()+15000
	while not view.career_view._narrations.is_empty() and Time.get_ticks_msec() < deadline:
		await shell.get_tree().process_frame
	check("narrations finish and release players",true,view.career_view._narrations.is_empty() and not is_instance_valid(first_narration))
	await press(shell,view,"province/nord")
	var retiring: AudioStreamPlayer = view.career_view._narrations.back()
	await press(shell,view,"exit")
	check("creation exit releases active narration",false,is_instance_valid(retiring))
	return save(str(fixture.sandbox).path_join("result.json"))
