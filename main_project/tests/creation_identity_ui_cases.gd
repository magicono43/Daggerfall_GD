extends "res://tests/creation_biography_ui_cases.gd"
## Full New Game path: no assigned creation choices or replaced CHAR validators.
var name_draws := 0

func refresh(shell: Control) -> void:
	shell.session_shell.render()
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame

func name_text(shell: Control, view: RefCounted, text: String) -> void:
	await refresh(shell)
	var field: LineEdit = view._editors["name-field"]
	field.text = text
	field.text_changed.emit(text)

func qualify(shell: Control, fixture: Dictionary) -> Array[Dictionary]:
	sandbox = fixture.sandbox
	var view: RefCounted = shell.session_shell.creation_view
	if view.active(): view.exit()
	check("identity UI normal New Game opens",true,view.open().ok)
	check("identity UI no assigned creation provider",false,view.controlled)
	var provider: RefCounted = view.inputs
	provider.generation_material = func(_operation: String):
		var bytes := PackedByteArray(); bytes.resize(32); bytes.fill(41)
		return {"ok":true,"material":bytes}
	provider.name_material = func():
		name_draws += 1
		var bytes := PackedByteArray(); bytes.resize(32); bytes.fill(name_draws+60)
		return {"ok":true,"material":bytes}
	var values := {"race":"breton","gender":"female","class_method":"list","class":"class-00","biography_method":"automatic"}
	for hook in ["race","gender","class_method","class","biography_method"]:
		check("identity UI upstream selection "+hook,true,view.action("edit",view.navigation.context(),values[hook]).ok)
		check("identity UI upstream next "+hook,true,view.action("next",view.navigation.context()).ok)
	check("identity UI production automatic biography",true,view.action("biography-operation",view.navigation.context(),{"operation":"automatic"}).ok)
	check("identity UI complete biography next",true,view.action("next",view.navigation.context()).ok)
	await name_text(shell,view,"")
	var field: LineEdit = view._editors["name-field"]
	field.grab_focus()
	field._composition = true
	var composition_enter := InputEventKey.new(); composition_enter.keycode = KEY_ENTER; composition_enter.pressed = true
	check("identity UI synthetic IME Enter consumed",true,view.route_keyboard(composition_enter))
	check("identity UI synthetic IME blocks submission","composition",view.action("next",view.navigation.context()).kind)
	composition_enter.pressed = false; view.route_keyboard(composition_enter)
	field._composition = false; field._composition_end_frame = Engine.get_process_frames()
	check("identity UI synthetic IME ending frame blocked","composition",view.action("next",view.navigation.context()).kind)
	await shell.get_tree().process_frame; await shell.get_tree().process_frame; await shell.get_tree().process_frame
	var typed := InputEventKey.new(); typed.keycode = KEY_Z; typed.unicode = 90; typed.pressed = true
	Input.parse_input_event(typed); await shell.get_tree().process_frame
	typed = InputEventKey.new(); typed.keycode = KEY_Z; typed.pressed = false
	Input.parse_input_event(typed); await shell.get_tree().process_frame
	check("identity UI actual typed scalar reaches field","Z",field.text)
	field.select_all()
	check("identity UI shared paste handler accepts combining text",true,field.paste_candidate("e\u0301").ok)
	check("identity UI paste keeps combining sequence intact","e\u0301",field.text)
	field.select_all()
	check("identity UI raw newline paste rejected",false,field.paste_candidate("Alice\nBob").ok)
	check("identity UI rejected paste preserves existing text","e\u0301",field.text)
	if DisplayServer.get_name() != "headless":
		var clipboard := DisplayServer.clipboard_get()
		DisplayServer.clipboard_set("Alice\nBob")
		var paste := InputEventKey.new(); paste.keycode = KEY_V; paste.ctrl_pressed = true; paste.pressed = true
		Input.parse_input_event(paste); await shell.get_tree().process_frame
		paste = InputEventKey.new(); paste.keycode = KEY_V; paste.ctrl_pressed = true; paste.pressed = false
		Input.parse_input_event(paste); await shell.get_tree().process_frame
		check("identity UI OS paste cannot silently remove newline","e\u0301",field.text)
		DisplayServer.clipboard_set(clipboard)
	await name_text(shell,view,"  Zoë e\u0301 [b]  ")
	check("identity UI name stock handler",true,await press(shell,view,"apply-name"))
	check("identity UI accepted literal trimmed Unicode","Zoë e\u0301 [b]",view.owner.projection().selections.get("name"))
	await press(shell,view,"back")
	check("identity UI literal markup visibly retained","  Zoë e\u0301 [b]  ",view._editors["name-field"].text)
	var retained: Dictionary = view.owner.projection()
	await name_text(shell,view,"a".repeat(32))
	await press(shell,view,"next")
	check("identity UI overlong Next remains name","name",view.navigation.step().hook)
	check("identity UI invalid visible input retained","a".repeat(32),view._editors["name-field"].text)
	check("identity UI rejected name preserves accepted draft",retained,view.owner.projection())
	await press(shell,view,"random-name")
	check("identity UI Random has one owned draw",1,name_draws)
	check("identity UI Random updates editable visible field",view.owner.projection().selections.name,view._editors["name-field"].text)
	await name_text(shell,view,"記憶")
	await press(shell,view,"apply-name")
	check("identity UI missing glyph name retains Unicode","記憶",view.owner.projection().selections.name)
	await press(shell,view,"back")
	check("identity UI missing glyph explanation",true,not view.glyph_diagnostics.is_empty())
	var history: String = view.owner.projection().validated.biography.provenance.resolved_history
	await name_text(shell,view,"Edited Adventurer")
	await press(shell,view,"next")
	check("identity UI Next commits visible name","Edited Adventurer",view.owner.projection().selections.name)
	check("identity UI name edit preserves established history",history,view.owner.projection().validated.biography.provenance.resolved_history)
	await image(shell,"increment4-face-unselected.png")
	check("identity UI no implicit face zero",false,view.owner.projection().selections.has("face"))
	check("identity UI missing face blocks Next",false,view.action("next",view.navigation.context()).ok)
	await press(shell,view,"portrait-next")
	check("identity UI explicit first portrait","classic-01",view.owner.projection().selections.face.id)
	await press(shell,view,"portrait-previous")
	await press(shell,view,"portrait-previous")
	check("identity UI Previous wraps","classic-09",view.owner.projection().selections.face.id)
	await image(shell,"increment4-face.png")
	view.action("next",view.navigation.context())
	view.action("starting-operation",view.navigation.context(),"generate-attributes")
	var value: Dictionary = view.owner.projection().selections.attributes
	value.roll.allocated.strength = value.roll.pool
	check("identity UI real attributes allocation",true,view.action("edit",view.navigation.context(),value).ok)
	check("identity UI real attributes next",true,view.action("next",view.navigation.context()).ok)
	view.action("starting-operation",view.navigation.context(),"generate-skills")
	value = view.owner.projection().selections.skills
	for tier in ["primary","major","minor"]: value.roll.allocated[provider.preset("class-00").tiers[tier][0]] = provider.starting.skills.pools[tier]
	check("identity UI real skills allocation",true,view.action("edit",view.navigation.context(),value).ok)
	check("identity UI real skills next",true,view.action("next",view.navigation.context()).ok)
	check("identity UI default retained on reaching reflexes","average",view.owner.projection().selections.reflexes)
	await press(shell,view,"reflex/very-high")
	check("identity UI actual reflex handler","very-high",view.owner.projection().selections.reflexes)
	await image(shell,"increment4-reflexes.png")
	view.action("next",view.navigation.context())
	check("identity UI complete production summary","summary",view.navigation.step().hook)
	await image(shell,"increment4-summary.png")
	var overview_facts: Dictionary = view.owner.projection()
	await press(shell,view,"summary-page/career")
	check("identity UI real career review tab",1,view._summary_tab)
	await image(shell,"increment4-summary-career.png")
	await press(shell,view,"summary-page/history")
	check("identity UI real history review tab",2,view._summary_tab)
	await image(shell,"increment4-summary-history.png")
	await press(shell,view,"summary-page/overview")
	check("identity UI real overview review tab",0,view._summary_tab)
	check("identity UI review tabs change no character facts",overview_facts,view.owner.projection())
	view.action("summary-edit",view.navigation.context(),"name")
	await name_text(shell,view,"W".repeat(31))
	await press(shell,view,"next")
	check("identity UI long summary name unchanged","W".repeat(31),view.owner.projection().selections.name)
	var name_scroll: ScrollContainer
	for node in view._page.find_children("*","ScrollContainer",true,false):
		if node.has_meta("creation_summary_name"): name_scroll = node
	check("identity UI long summary name scroll available",true,name_scroll != null and name_scroll.get_h_scroll_bar().max_value > name_scroll.get_h_scroll_bar().page)
	await image(shell,"increment4-long-name.png")
	view.action("summary-edit",view.navigation.context(),"name")
	await name_text(shell,view,"Edited Adventurer")
	await press(shell,view,"next")
	var captured: Dictionary = view.navigation.capture(view.navigation.context())
	check("identity UI complete production capture",true,captured.ok)
	if not captured.ok:
		print("IDENTITY CAPTURE ",captured)
		view.exit(); return checks
	for section in ["name","face","reflexes"]: check("identity UI captured real provider "+section,true,captured.capture.draft.validated[section].provider.begins_with("char.creation.identity-v1/"))
	var frozen: Dictionary = captured.capture.duplicate(true)
	view.action("summary-edit",view.navigation.context(),"name")
	await name_text(shell,view,"Summary Name")
	await image(shell,"increment4-name.png")
	view._editors["name-field"].grab_focus()
	var submit_name := InputEventKey.new(); submit_name.keycode = KEY_ENTER; submit_name.pressed = true
	Input.parse_input_event(submit_name); await shell.get_tree().process_frame
	submit_name = InputEventKey.new(); submit_name.keycode = KEY_ENTER; submit_name.pressed = false
	Input.parse_input_event(submit_name); await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("identity UI Enter completes name editor","summary",view.navigation.step().hook)
	check("identity UI name completion restores eligible focus",true,shell.get_viewport().gui_get_focus_owner() is Button)
	check("identity UI summary name edit","Summary Name",view.owner.projection().selections.name)
	check("identity UI old captured intent immutable","Edited Adventurer",frozen.draft.selections.name)
	check("identity UI summary edit no name generation",1,name_draws)
	view.action("summary-edit",view.navigation.context(),"face")
	await press(shell,view,"portrait-next"); await press(shell,view,"next")
	check("identity UI summary face edit","classic-00",view.owner.projection().selections.face.id)
	view.action("summary-edit",view.navigation.context(),"reflexes")
	await press(shell,view,"reflex/low"); await press(shell,view,"next")
	check("identity UI summary reflex edit","low",view.owner.projection().selections.reflexes)
	var settings: RefCounted = shell.controller.settings
	var videos: bool = settings.effective.get("media/creation_videos",true)
	var media: RefCounted = shell.controller.providers.media_preferences
	media.select_creation_videos(false)
	await refresh(shell)
	await press(shell,view,"creation-videos")
	check("identity UI video toggle actual application",true,settings.effective["media/creation_videos"])
	check("identity UI video toggle persistence",true,settings.value(settings.persisted,"media/creation_videos"))
	settings.adapter.faults.settings_publish = true
	await press(shell,view,"creation-videos")
	check("identity UI video failed save retains application",false,settings.effective["media/creation_videos"])
	check("identity UI video failed save retains old persisted",true,settings.value(settings.persisted,"media/creation_videos"))
	check("identity UI video unsaved feedback",true,view.notice.contains("not saved"))
	settings.adapter.faults.clear()
	check("identity UI video preference retry save",true,settings.save_accepted().ok)
	var validator: Callable = settings.schema["media/creation_videos"].validate
	settings.schema["media/creation_videos"].validate = func(_enabled: Variant): return false
	await press(shell,view,"creation-videos")
	check("identity UI video rejected application retains prior",false,settings.effective["media/creation_videos"])
	check("identity UI video rejected control restores prior",false,view._editors["creation-videos"].button_pressed)
	settings.schema["media/creation_videos"].validate = validator
	settings.effective["media/creation_videos"] = false
	await press(shell,view,"begin")
	check("identity UI unavailable real entry remains failed",true,view._submission_failed)
	check("identity UI submitted character edits require Restart",false,view.action("summary-edit",view.navigation.context(),"name").ok)
	check("identity UI no early live actors",0,shell.session_shell.core.actors._actors.size())
	check("identity UI no playable session","",shell.session_shell.core.snapshot().session)
	var original: Dictionary = shell.session_shell.core.last_intent.selection.creation.duplicate(true)
	await press(shell,view,"retry")
	check("identity UI retry retains complete production intent",original,shell.session_shell.core.last_intent.selection.creation)
	settings.effective["media/creation_videos"] = true
	# The real classic clips are optional; assert ordered attempts and skip fresh
	# presses without waiting for their authored duration. Source failures continue.
	await press(shell,view,"retry")
	var sequence: RefCounted = shell.session_shell.creation_cinematics
	var playback: Control = shell.session_shell.video_playback
	var deadline := Time.get_ticks_msec()+20000
	var skipped := {}
	var held_safe := true
	while shell.session_shell.core.busy() and Time.get_ticks_msec() < deadline:
		await shell.get_tree().process_frame
		if not playback._attempt.is_empty() and playback._attempt.get("ready",false):
			var attempt: String = playback._attempt.scope.attempt
			if not skipped.has(attempt):
				skipped[attempt] = true
				var before_index: int = sequence._index
				var key := InputEventKey.new(); key.keycode = KEY_F8; key.pressed = true
				Input.parse_input_event(key)
				# AV terminal follows audio/window release, not a fixed number of
				# rendered frames. Keep the physical key held through that handoff.
				var handoff_deadline := Time.get_ticks_msec()+5000
				while shell.session_shell.core.busy() and (sequence._index == before_index or playback._attempt.is_empty()) and Time.get_ticks_msec() < handoff_deadline:
					await shell.get_tree().process_frame
				key = InputEventKey.new(); key.keycode = KEY_F8; key.pressed = true
				Input.parse_input_event(key); await shell.get_tree().process_frame
				held_safe = held_safe and sequence._index == before_index+1
				key = InputEventKey.new(); key.keycode = KEY_F8; key.pressed = false
				Input.parse_input_event(key)
	if shell.session_shell.core.busy(): shell.session_shell.core.cancel(shell.session_shell.core.ticket())
	check("identity UI optional three clips settle",false,shell.session_shell.core.busy())
	check("identity UI held skip cannot advance following clip",true,held_safe)
	check("identity UI cinematic release clears creation key quarantine",false,view._keyboard_down.has(KEY_ENTER))
	check("identity UI verified DFU intro target order",sequence.TARGETS,sequence.outcomes.map(func(outcome): return outcome.target))
	check("identity UI clips cannot establish entry","",shell.session_shell.core.snapshot().session)
	check("identity UI clips cannot create actors",0,shell.session_shell.core.actors._actors.size())
	settings.effective["media/creation_videos"] = videos
	media.select_creation_videos(false) # Pinned preference for the fresh process check.
	view.restart()
	check("identity UI Restart clears all but fresh reflex default",{"reflexes":"average"},view.owner.projection().selections)
	view.exit()
	provider.generation_material = Callable(); provider.name_material = Callable()
	check("identity custom normal New Game opens",true,view.open().ok)
	provider = view.inputs
	provider.generation_material = func(_operation: String):
		var bytes := PackedByteArray(); bytes.resize(32); bytes.fill(71)
		return {"ok":true,"material":bytes}
	for pair in [["race","khajiit"],["gender","male"],["class_method","custom"]]:
		check("identity custom upstream "+pair[0],true,view.action("edit",view.navigation.context(),pair[1]).ok)
		check("identity custom upstream next "+pair[0],true,view.action("next",view.navigation.context()).ok)
	var custom: Dictionary = provider.Custom.initial(provider.policy,view.owner.token().id+"/custom")
	custom.name = "Wanderer"
	var skill_index := 0
	for tier in provider.Custom.COUNTS:
		for slot in provider.Custom.COUNTS[tier]:
			custom.tiers[tier][slot] = provider.policy.skills.keys()[skill_index]
			skill_index += 1
	view.action("edit",view.navigation.context(),custom)
	check("identity custom genuine career complete",true,view.action("next",view.navigation.context()).ok)
	view.action("edit",view.navigation.context(),"automatic"); view.action("next",view.navigation.context())
	check("identity custom automatic biography",true,view.action("biography-operation",view.navigation.context(),{"operation":"automatic"}).ok)
	view.action("next",view.navigation.context())
	await name_text(shell,view,"Khajiit Wanderer")
	view.action("next",view.navigation.context())
	view.action("identity-operation",view.navigation.context(),"portrait-previous")
	view.action("next",view.navigation.context())
	view.action("starting-operation",view.navigation.context(),"generate-attributes")
	value = view.owner.projection().selections.attributes
	value.roll.allocated.strength = value.roll.pool
	view.action("edit",view.navigation.context(),value)
	check("identity custom final attributes",true,view.action("next",view.navigation.context()).ok)
	view.action("starting-operation",view.navigation.context(),"generate-skills")
	value = view.owner.projection().selections.skills
	for tier in ["primary","major","minor"]: value.roll.allocated[custom.tiers[tier][0]] = provider.starting.skills.pools[tier]
	view.action("edit",view.navigation.context(),value)
	check("identity custom final skills",true,view.action("next",view.navigation.context()).ok)
	check("identity custom fresh reflex remains Average","average",view.owner.projection().selections.reflexes)
	view.action("next",view.navigation.context())
	check("identity custom complete immutable capture",true,view.navigation.capture(view.navigation.context()).ok)
	check("identity custom zero early actors",0,shell.session_shell.core.actors._actors.size())
	await image(shell,"increment4-custom-summary.png")
	if DisplayServer.get_name() != "headless":
		var size_before: Vector2i = shell.get_window().size
		for window_size in [Vector2i(800,600),Vector2i(640,480)]:
			shell.get_window().size = window_size
			await refresh(shell)
			check("identity small window artwork fits "+str(window_size.x),true,view._page_frame.get_global_rect().end.x <= shell.get_viewport_rect().size.x)
			check("identity small window navigation reachable "+str(window_size.x),true,view._buttons.back.global_position.y >= 0 and view._buttons.back.global_position.y < shell.get_viewport_rect().size.y)
			await image(shell,"increment4-summary-"+str(window_size.x)+".png")
		shell.get_window().size = size_before
		await refresh(shell)
	view.exit(); provider.generation_material = Callable()
	return checks
