extends "res://tests/mod_cases.gd"
var acquisitions := 0

func press(shell: Control, view: RefCounted, id: String) -> bool:
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	if not view.active(): return false
	if id == "next" and view.navigation.step().hook == "name" and view.inputs.has_method("random_name"): id = "apply-name"
	elif id == "next" and view.navigation.step().hook == "face" and view._buttons.has("portrait-confirm"): id = "portrait-confirm"
	var incoming = view._buttons.get(id)
	if not is_instance_valid(incoming): return false
	var button: Button = incoming
	if button == null or button.disabled: return false
	shell.panel.get_parent().ensure_control_visible(button)
	button.grab_focus()
	await shell.get_tree().process_frame
	var event := InputEventKey.new(); event.keycode = KEY_ENTER; event.pressed = true
	Input.parse_input_event(event); await shell.get_tree().process_frame
	event = InputEventKey.new(); event.keycode = KEY_ENTER; event.pressed = false
	Input.parse_input_event(event); await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	return true

func image(shell: Control, file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await shell.get_tree().process_frame; await RenderingServer.frame_post_draw
	shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join(file))

func qualify(shell: Control, fixture: Dictionary) -> Array[Dictionary]:
	sandbox = fixture.sandbox
	var view: RefCounted = shell.session_shell.creation_view
	if view.active(): view.exit()
	var provider := preload("res://tests/creation_biography_review_inputs.gd").new()
	provider.definitions = shell.controller.providers.definitions; provider.content = provider.definitions.content_ticket()
	provider.options = provider.definitions.query("char.creation","flows","stock").record.value.choices
	check("biography UI real preparation",true,provider.prepare().ok)
	provider.generation_material = func(_operation: String):
		acquisitions += 1
		var material := PackedByteArray(); material.resize(32); material.fill((acquisitions+20)%256)
		return {"ok":true,"material":material}
	check("biography UI opens labelled later-only review",true,view.open(provider).ok)
	var values := {"race":"breton","gender":"female","class_method":"list","class":"class-00","biography_method":"manual"}
	for hook in ["race","gender","class_method","class","biography_method"]:
		check("biography UI production upstream "+hook,true,view.action("edit",view.navigation.context(),values[hook]).ok)
		check("biography UI upstream next "+hook,true,view.action("next",view.navigation.context()).ok)
	check("biography UI begins questions through stock handler",true,await press(shell,view,"biography-initialize"))
	var value: Dictionary = view.owner.projection().selections.get("biography",{})
	if value.is_empty(): provider.generation_material = Callable(); view.exit(); return checks
	check("biography UI localized DATA question preserves Unicode",true,provider.templates[value.template].questions[0].text.contains("記憶"))
	check("biography UI localized question uses font recovery",true,not view.glyph_diagnostics.is_empty())
	await image(shell,"increment3-biography.png")
	var template: Dictionary = provider.templates[value.template]
	check("biography UI manual first answer before automatic",true,await press(shell,view,"biography-answer/q1/a"))
	check("biography UI Back to method retains partial answers",true,await press(shell,view,"back"))
	check("biography UI stock Back reaches method","biography_method",view.navigation.step().hook)
	check("biography UI stock Back retains creation layer","creation",shell.session_shell.windows.top().get("window"))
	view.action("next",view.navigation.context())
	var retained: Dictionary = view.owner.projection().selections.biography.duplicate(true)
	var before_escape := acquisitions
	check("biography UI navigation above artwork",true,view._buttons.back.global_position.y < view._page.global_position.y)
	for echo in [false,true,true,false]:
		var escape := InputEventKey.new(); escape.keycode = KEY_ESCAPE; escape.pressed = true; escape.echo = echo
		Input.parse_input_event(escape); await shell.get_tree().process_frame
	var escape_release := InputEventKey.new(); escape_release.keycode = KEY_ESCAPE; escape_release.pressed = false
	Input.parse_input_event(escape_release); await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("biography UI Escape reaches method","biography_method",view.navigation.step().hook)
	check("biography UI held Escape never opens pause","creation",shell.session_shell.windows.top().get("window"))
	check("biography UI Escape retains partial biography",retained,view.owner.projection().selections.biography)
	check("biography UI Escape draws nothing",before_escape,acquisitions)
	check("biography UI selects automatic after manual",true,view.action("edit",view.navigation.context(),"automatic").ok)
	check("biography UI returns to retained template",true,view.action("next",view.navigation.context()).ok)
	check("biography UI automatic remaining stock handler",true,await press(shell,view,"biography-complete-automatic"))
	check("biography UI automatic preserves manual first answer","a",view.owner.projection().selections.biography.answers.q1)
	await press(shell,view,"notice/dismiss")
	await press(shell,view,"back")
	await press(shell,view,"biography-previous") # Return from q2 to the first answer.
	for q in template.questions:
		check("biography UI stock answer "+q.id,true,await press(shell,view,"biography-answer/"+q.id+"/"+q.answers[0].id))
	check("biography UI full manual validates",true,view.owner.section_status("biography").ok)
	await press(shell,view,"notice/dismiss")
	await press(shell,view,"back")
	check("biography UI history stock handler",true,await press(shell,view,"biography-history"))
	await image(shell,"increment3-history.png")
	var calls := acquisitions
	shell.render(); shell.render()
	check("biography UI repaint consumes no entropy",calls,acquisitions)
	check("biography UI next complete biography",true,view.action("next",view.navigation.context()).ok)
	for hook in ["name","face"]:
		check("biography UI only later "+hook+" assigned",true,view.action("edit",view.navigation.context(),provider.later.fixture.preset[hook]).ok)
		check("biography UI next later "+hook,true,view.action("next",view.navigation.context()).ok)
	check("biography UI attributes initial stock generation",true,await press(shell,view,"generate-attributes"))
	check("biography UI attribute stock increment",true,await press(shell,view,"starting/strength/1"))
	check("biography UI attribute stock refund",true,await press(shell,view,"starting/strength/-1"))
	check("biography UI Save Roll stock handler",true,await press(shell,view,"save-roll"))
	var saved: Dictionary = view.owner.projection().selections.attributes
	check("biography UI Reroll stock handler",true,await press(shell,view,"reroll-attributes"))
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	var calls_before_hold := acquisitions
	var held_button: Button = view._buttons["reroll-attributes"]
	held_button.grab_focus()
	await shell.get_tree().process_frame
	for echo in [false,true,true]:
		var event := InputEventKey.new(); event.keycode = KEY_ENTER; event.pressed = true; event.echo = echo
		Input.parse_input_event(event); await shell.get_tree().process_frame
	var release := InputEventKey.new(); release.keycode = KEY_ENTER; release.pressed = false
	Input.parse_input_event(release); await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("biography UI held reroll has one generation",calls_before_hold+1,acquisitions)
	check("biography UI Load Roll stock handler",true,await press(shell,view,"load-roll"))
	check("biography UI Load restores complete state",saved,view.owner.projection().selections.attributes)
	check("biography UI unfinished attributes block Next",false,view.action("next",view.navigation.context()).ok)
	var pool: int = saved.roll.pool
	for point in pool: await press(shell,view,"starting/strength/1")
	check("biography UI full attributes validate",true,view.owner.section_status("attributes").ok)
	var unavailable_core := preload("res://scripts/session/session_lifecycle.gd").new()
	provider.bind_preview(view.owner,unavailable_core)
	check("biography UI unavailable preview blocks attribute completion",false,view.owner.section_status("attributes").ok)
	provider.bind_preview(view.owner,shell.session_shell.core)
	unavailable_core.dispose()
	check("biography UI restored preview revalidates attributes",true,view.owner.section_status("attributes").ok)
	var state: Dictionary = view.owner.projection().selections.attributes
	var evaluated: Dictionary = view.owner.validate("attributes",view.owner.token(),state).provenance.evaluation
	var preview: Dictionary = view.owner.attribute_preview(shell.session_shell.core,view.owner.token(),evaluated.final,provider.preset("class-00").spell_points)
	check("biography UI seven owner-backed previews",7,preview.get("values",{}).size())
	await image(shell,"increment3-attributes.png")
	check("biography UI next attributes",true,view.action("next",view.navigation.context()).ok)
	check("biography UI skills initial stock generation",true,await press(shell,view,"generate-skills"))
	check("biography UI skills has no Reroll",false,view._buttons.has("reroll-attributes"))
	check("biography UI skills has no Save Roll",false,view._buttons.has("save-roll"))
	check("biography UI unfinished skills block Next",false,view.action("next",view.navigation.context()).ok)
	var tiers: Dictionary = provider.preset("class-00").tiers
	for tier in ["primary","major","minor"]:
		for point in provider.starting.skills.pools[tier]: await press(shell,view,"starting/"+tiers[tier][0]+"/1")
	check("biography UI full skill pools validate",true,view.owner.section_status("skills").ok)
	await image(shell,"increment3-skills.png")
	check("biography UI next skills",true,view.action("next",view.navigation.context()).ok)
	view.action("edit",view.navigation.context(),provider.later.fixture.preset.reflexes)
	check("biography UI next assigned later reflexes",true,view.action("next",view.navigation.context()).ok)
	check("biography UI reaches final summary","summary",view.navigation.step().hook)
	await image(shell,"increment3-summary.png")
	var captured: Dictionary = view.navigation.capture(view.navigation.context())
	check("biography UI real increment3 immutable capture",true,captured.ok)
	if not captured.ok:
		print("BIOGRAPHY UI CAPTURE ",captured)
		provider.generation_material = Callable(); view.exit(); return checks
	if captured.ok:
		check("biography UI repeated capture retains complete intent",captured.capture,view.navigation.capture(view.navigation.context()).capture)
		check("biography UI captured biography uses actual provider",true,captured.capture.draft.validated.biography.provider.begins_with("char.creation.biography") and captured.capture.draft.validated.biography.provenance.narrative_sources.has("text-4116"))
		check("biography UI captured attributes uses actual provider",true,captured.capture.draft.validated.attributes.provider.begins_with("char.creation.starting"))
		check("biography UI captured skills uses actual provider",true,captured.capture.draft.validated.skills.provider.begins_with("char.creation.starting"))
	check("biography UI summary biography direct edit rejected",false,view.action("summary-edit",view.navigation.context(),"biography").ok)
	check("biography UI summary direct biography operation rejected",false,view.action("biography-operation",view.navigation.context(),{"operation":"automatic"}).ok)
	check("biography UI summary attribute editor allowed",true,view.action("summary-edit",view.navigation.context(),"attributes").ok)
	check("biography UI summary allocation refund",true,await press(shell,view,"starting/strength/-1"))
	check("biography UI summary cannot finish unspent allocation",false,view.action("next",view.navigation.context()).ok)
	await press(shell,view,"starting/strength/1")
	view.action("next",view.navigation.context())
	await press(shell,view,"begin")
	check("biography UI real entry remains unavailable","",shell.session_shell.core.snapshot().session)
	check("biography UI zero early actors",0,shell.session_shell.core.actors._actors.size())
	var original: Dictionary = shell.session_shell.core.last_intent.selection.creation.duplicate(true)
	await press(shell,view,"retry")
	check("biography UI entry retry retains exact resolved intent",original,shell.session_shell.core.last_intent.selection.creation)
	var old_token: Dictionary = view.navigation.context()
	await press(shell,view,"restart")
	check("biography UI Restart discards rolls rewards and slot",{},view.owner.projection().selections)
	check("biography UI retired operation cannot regenerate",false,view.action("biography-operation",old_token,{"operation":"automatic"}).ok)
	provider.generation_material = Callable()
	view.exit()
	return checks
