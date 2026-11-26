extends "res://tests/mod_cases.gd"
const Draft = preload("res://scripts/char/creation_draft.gd")
const Nav = preload("res://scripts/char/creation_navigation.gd")
const Inputs = preload("res://tests/controlled_creation_inputs.gd")
const Flow = preload("res://scripts/data/creation_flow.gd")
const Core = preload("res://scripts/session/session_lifecycle.gd")
const Entry = preload("res://tests/controlled_session_provider.gd")
var measurements := {}

func control(shell: Control, text: String) -> bool:
	# Button activation occurs on release and schedules the next view. Wait for
	# its real layout/focus boundary before locating another control; do not retry
	# missing controls or accept duplicate scenario names as a passing inventory.
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var found := await click(shell,text)
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	return found

class ReentrantEntry extends "res://tests/controlled_session_provider.gd":
	var callback := Callable()
	func prepare(ticket: Dictionary, intent: Dictionary) -> Dictionary:
		if callback.is_valid(): callback.call()
		return super.prepare(ticket,intent)

class PendingPreparation extends "res://scripts/session/session_provider.gd":
	var cancelled := 0
	func prepare(_ticket: Dictionary, _intent: Dictionary) -> Dictionary: return {"pending":true}
	func cancel_preparation(_ticket: Dictionary) -> void: cancelled += 1

func build(record: Dictionary, variant := "preset") -> Dictionary:
	var owner := Draft.new()
	var provider := Inputs.new()
	provider.variant = variant
	owner.bind(1,provider.bindings())
	var nav := Nav.new()
	nav.bind(owner,record)
	nav.start()
	return {"owner":owner,"provider":provider,"nav":nav}

func complete(case: Dictionary, class_method: String, biography_method: String, prefix: String) -> void:
	var nav: RefCounted = case.nav
	var values: Dictionary = case.provider.fixture[case.provider.variant].duplicate(true)
	values.class_method = class_method
	values.biography_method = biography_method
	var budget := 20
	while nav.step().hook != "summary" and budget > 0:
		budget -= 1
		var hook: String = nav.step().hook
		var edited: Dictionary = nav.edit(nav.context(),values[hook])
		check(prefix+" edit "+hook,true,edited.ok)
		if not edited.ok: push_error(str(edited)); return
		var before: Dictionary = case.owner.projection()
		check(prefix+" next "+hook,true,nav.next(nav.context()).ok)
		check(prefix+" navigation retains "+hook,before,case.owner.projection())
	check(prefix+" capture",true,nav.capture(nav.context()).ok)

func new_core() -> RefCounted:
	var core := Core.new(func(_ticket: Dictionary,_mode: String): return preload("res://scripts/rule/seed_derivation.gd").validate_material(PackedByteArray([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])))
	core.startup_route_changed("main_menu")
	core.provider = Entry.new()
	return core

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	shell.set_physics_process(false)
	var controller: RefCounted = shell.controller
	controller.settings.effective["startup/show_setup"] = true
	var started := Time.get_ticks_usec()
	controller.select_folder(fixture.classic_source)
	controller.continue_to_menu("run")
	shell.session_shell.synchronize_startup()
	shell.render()
	measurements.complete_composition_usec = Time.get_ticks_usec()-started
	measurements.initial_startup_usec = shell.startup_elapsed_usec
	measurements.classic_preparations = controller.providers.classic_preparations
	check("complete composition menu","main_menu",controller.route)
	var definitions: RefCounted = controller.providers.definitions
	var read: Dictionary = definitions.query(Flow.DOMAIN,"flows","stock")
	check("published creation flow",true,read.ok)
	if not read.ok:
		var incomplete := result(fixture)
		incomplete.publication = controller.result.duplicate(true)
		return incomplete
	var record: Dictionary = read.record
	var career_suite := preload("res://tests/creation_career_cases.gd").new()
	var career_checks: Array = await career_suite.qualify(shell,fixture)
	measurements.career_preparation_usec = career_suite.provider.measurements.preparation_usec
	checks.append_array(career_checks)
	await publication(shell,fixture,record)
	check("published creation provenance",true,record.contributors.any(func(source): return source.provider == "@shipped/creation-flow-v1"))
	check("locked creation publication","locked",definitions.prepare(controller.mods).kind)
	var detached := record.duplicate(true)
	detached.value.steps.race.title = "caller changed"
	check("detached flow projection","Race",definitions.query(Flow.DOMAIN,"flows","stock").record.value.steps.race.title)
	for class_method in ["list","questionnaire","custom"]:
		for biography_method in ["manual","automatic"]:
			var prefix: String = class_method+"/"+biography_method
			var case := build(record,"custom" if class_method == "custom" else "preset")
			complete(case,class_method,biography_method,prefix)
			var before: Dictionary = case.owner.projection()
			for section in Draft.SUMMARY_EDITORS:
				check(prefix+" summary editor "+section,true,case.nav.summary_edit(case.nav.context(),section).ok)
				check(prefix+" summary editor return "+section,true,case.nav.next(case.nav.context()).ok)
			check(prefix+" summary revisit retention",before,case.owner.projection())
			for section in ["race","gender","class","biography"]: check(prefix+" restricted summary "+section,false,case.nav.summary_edit(case.nav.context(),section).ok)
			for index in range(case.nav._path.size()-1): check(prefix+" sequential back "+str(index),true,case.nav.back(case.nav.context()).ok)
			check(prefix+" back retains all facts",before,case.owner.projection())
			check(prefix+" summary Back upstream edit requires restart",false,case.nav.edit(case.nav.context(),"nord").ok)
			check(prefix+" no navigation draws",0,case.provider.draws)
			case.owner.dispose()
	var case := build(record)
	complete(case,"list","manual","mutation")
	var nav: RefCounted = case.nav
	var owner: RefCounted = case.owner
	var original: Dictionary = owner.projection()
	var capture: Dictionary = nav.capture(nav.context()).capture
	check("CHAR rejects UI incomplete required list",false,owner.capture(owner.token(),["race"],capture.route).ok)
	var duplicate_required: Array = capture.required.duplicate()
	duplicate_required[0] = duplicate_required[1]
	check("CHAR rejects UI duplicate required section",false,owner.capture(owner.token(),duplicate_required,capture.route).ok)
	var wrong_revision: Dictionary = owner.token()
	wrong_revision.revision = float(wrong_revision.revision)
	check("CHAR rejects float revision token",false,owner.current(wrong_revision))
	wrong_revision.revision = true
	check("CHAR rejects boolean revision token",false,owner.current(wrong_revision))
	check("active UI route cannot rebind",false,nav.bind(owner,record).ok)
	var biography: Dictionary = original.selections.biography
	check("biography substantive answer edit",true,owner.edit("biography",owner.token(),case.provider.fixture.biography_alternative).ok)
	check("biography changes retain attribute rolls",original.selections.attributes,owner.projection().selections.attributes)
	check("biography changes retain skill rolls",original.selections.skills,owner.projection().selections.skills)
	check("biography old answer outcome retained",true,owner.projection().retained.biography.outcomes.has("childhood/library"))
	check("biography new answer outcome retained",true,owner.projection().retained.biography.outcomes.has("childhood/temple"))
	check("biography answer restoration",true,owner.edit("biography",owner.token(),biography).ok)
	check("biography restoration no redraw",0,case.provider.draws)
	check("biography inactive outcome retained",true,owner.projection().retained.biography.outcomes.has("childhood/temple"))
	original = owner.projection()
	check("identical edit no-op","unchanged",owner.edit("race",owner.token(),"breton").kind)
	check("identical edit retains revision",original,owner.projection())
	for invalid in [true,false,1.5,9223372036854775807,"unknown",null]:
		check("malformed race "+str(invalid),false,owner.edit("race",owner.token(),invalid).ok)
		check("malformed race atomic "+str(invalid),original,owner.projection())
	var previous_token: Dictionary = owner.token()
	check("substantive gender accepted",true,owner.edit("gender",owner.token(),"male").ok)
	check("gender invalidates only face",["face"],owner.projection().invalidated)
	check("gender retains allocation",original.selections.attributes,owner.projection().selections.attributes)
	check("gender retains biography outcomes",original.retained.biography,owner.projection().retained.biography)
	check("stale edit rejected","stale",owner.edit("race",previous_token,"nord").kind)
	check("stale capture rejected","stale",owner.capture(previous_token,["race"],{"route":"test"}).kind)
	for field in ["remaining"]:
		for invalid in [true,false,1.5,-1,101,9223372036854775807]:
			var value: Dictionary = original.selections.attributes.duplicate(true)
			value[field] = invalid
			check("invalid numeric "+str(invalid),false,owner.edit("attributes",owner.token(),value).ok)
	var unspent: Dictionary = original.selections.attributes.duplicate(true)
	unspent.remaining = 1
	check("unspent edit retained",true,owner.edit("attributes",owner.token(),unspent).ok)
	check("unspent prevents completion",false,owner.section_status("attributes").ok)
	check("allocation correction",true,owner.edit("attributes",owner.token(),original.selections.attributes).ok)
	for invalid in [true,1.0]:
		var value: Dictionary = original.selections.attributes.duplicate(true)
		value.remaining = invalid
		check("nested no-op coercion rejected "+str(invalid),false,owner.edit("attributes",owner.token(),value).ok)
	check("career change",true,owner.edit("class",owner.token(),"class-00").ok)
	check("career dependent invalidation",["biography","attributes","skills"],owner.projection().invalidated)
	check("career retains name",original.selections.name,owner.projection().selections.name)
	check("career retains candidate outcome cache",original.retained.biography,owner.projection().retained.biography)
	var stale_context: Dictionary = nav.context()
	var old_id: String = owner.projection().id
	nav.start()
	check("restart new draft identity",false,old_id == owner.projection().id)
	check("restart complete discard",{},{"s":owner.projection().selections}.s)
	check("restart callback stale",false,nav.edit(stale_context,"nord").ok)
	var abandoned_core := new_core()
	check("discarded capture cannot submit",false,owner.submit(abandoned_core,capture).get("ok",false))
	abandoned_core.dispose()
	var token: Dictionary = owner.token()
	case.provider.during_validation = func(): owner.discard()
	check("provider callback retirement","stale",owner.edit("race",token,"nord").kind)
	check("provider cannot repopulate retired draft",{},owner.projection())
	case.provider.during_validation = Callable()
	nav.start()
	check("reentry has no resumed selections",{},owner.projection().selections)
	for mutation in ["cycle","missing","skip","action","completion","branch"]:
		var flow: Dictionary = record.value.duplicate(true)
		match mutation:
			"cycle": flow.routes[0].steps.append("race")
			"missing": flow.routes[0].steps[0] = "absent"
			"skip": flow.routes[0].steps.erase("attributes")
			"action": flow.steps.race.hook = "grant-items"
			"completion": flow.routes[0].steps.erase("summary")
			"branch": flow.routes[0].class_method = "unsupported"
		check("invalid flow "+mutation,false,Flow.reason(flow).is_empty())
	var reordered: Dictionary = record.value.duplicate(true)
	for route: Dictionary in reordered.routes:
		route.steps.erase("name")
		route.steps.push_front("name")
	check("mod independent section reorder supported","",Flow.reason(reordered))
	var duplicate_route: Dictionary = record.value.duplicate(true)
	duplicate_route.routes[1].id = duplicate_route.routes[0].id
	check("duplicate mod route identity rejects",false,Flow.reason(duplicate_route).is_empty())
	var aliased: Dictionary = record.duplicate(true)
	aliased.value.steps["custom-method"] = aliased.value.steps.class_method.duplicate(true)
	for route: Dictionary in aliased.value.routes:
		if route.class_method == "custom": route.steps[route.steps.find("class_method")] = "custom-method"
	var alias_case := build(aliased)
	for section in ["race","gender"]:
		alias_case.nav.edit(alias_case.nav.context(),alias_case.provider.fixture.preset[section])
		alias_case.nav.next(alias_case.nav.context())
	alias_case.nav.edit(alias_case.nav.context(),"custom")
	check("mod branch step identity stays anchored","custom-method",alias_case.nav.step_id())
	alias_case.nav.next(alias_case.nav.context())
	check("mod branch cannot jump to summary","custom",alias_case.nav.step().hook)
	alias_case.owner.dispose()
	var missing_provider := Draft.new()
	missing_provider.bind(1,{})
	missing_provider.start()
	check("missing real provider is unavailable","unavailable",missing_provider.edit("race",missing_provider.token(),"breton").kind)
	missing_provider.dispose()
	case = build(record)
	complete(case,"list","manual","submission")
	owner = case.owner
	capture = case.nav.capture(case.nav.context()).capture
	var core := new_core()
	core.provider.hold_preflight = true
	check("captured handoff pending","pending",owner.submit(core,capture).kind)
	var original_intent: Dictionary = core.last_intent.duplicate(true)
	owner.edit("name",owner.token(),"After admission")
	check("immutable admitted name","Assigned Adventurer",core.last_intent.selection.creation.draft.selections.name)
	var unsubmitted: Dictionary = owner.capture(owner.token(),capture.required,capture.route).capture
	owner.discard()
	check("discard removes other unsubmitted snapshots",false,owner._capture_ids.has(unsubmitted.id))
	check("discard retains only admitted retry snapshot",true,owner._capture_ids.has(capture.id))
	check("duplicate begin retained","pending",owner.submit(core,capture).kind)
	check("one preparation",1,core.provider.prepares)
	var caller_copy := capture.duplicate(true)
	caller_copy.draft.selections.name = "Changed payload"
	check("changed submission identity rejected",false,owner.submit(core,caller_copy).get("ok",false))
	check("captured CORE intent unchanged",original_intent,core.last_intent)
	var pending_ticket: Dictionary = core.ticket()
	check("pending preflight cancellation",true,core.cancel(pending_ticket))
	check("late preflight callback rejected",false,core.complete_preflight(pending_ticket,{"ok":true}))
	check("cancel duplicate remains terminal","Cancelled",owner.submit(core,capture).kind)
	check("cancel creates no session","",core.snapshot().session)
	check("cancel creates no grants",0,core.provider.initializations)
	core.dispose()
	case = build(record,"custom")
	complete(case,"custom","automatic","retry")
	owner = case.owner
	capture = case.nav.capture(case.nav.context()).capture
	core = new_core()
	core.provider.prepare_ok = false
	check("failed preparation retained","Failed",owner.submit(core,capture).kind)
	check("failed preparation preserves input",capture,core.last_intent.selection.creation)
	core.provider.prepare_ok = true
	core.provider.hold_preflight = true
	check("explicit retry pending","pending",owner.retry(core,capture).kind)
	check("retry preserves exact capture",capture,core.last_intent.selection.creation)
	check("retry does not initialize grants",0,core.provider.initializations)
	core.cancel(core.ticket())
	core.dispose()
	case = build(record)
	complete(case,"list","manual","replacement")
	owner = case.owner
	capture = case.nav.capture(case.nav.context()).capture
	core = new_core()
	check("controlled living session baseline","Succeeded",core.request({"id":"existing-controlled-session","mode":"new","origin":"","selection":{}}).kind)
	var living: String = core.snapshot().session
	check("living capture pending consent","pending",owner.submit(core,capture).kind)
	check("CORE retains separate living consent","confirmation",core.snapshot().phase)
	check("consent pending living scope intact",living,core.snapshot().session)
	check("reject replacement consent",true,core.confirm(core.ticket(),false))
	check("declined consent preserves living scope",living,core.snapshot().session)
	core.dispose()
	case = build(record)
	complete(case,"list","manual","reentrant")
	owner = case.owner
	capture = case.nav.capture(case.nav.context()).capture
	core = new_core()
	var reentrant := ReentrantEntry.new()
	reentrant.hold_preflight = true
	core.provider = reentrant
	var reentrant_results: Array = []
	reentrant.callback = func(): reentrant_results.append(owner.submit(core,capture))
	check("reentrant outer pending","pending",owner.submit(core,capture).kind)
	check("reentrant duplicate retained","pending",reentrant_results[0].kind)
	check("reentrant at most one preparation",1,reentrant.prepares)
	check("competing new request busy","busy",core.request({"id":"competing-request","mode":"new","origin":"","selection":{}}).kind)
	core.cancel(core.ticket())
	reentrant.callback = Callable()
	core.dispose()
	# Actual stock New Game control, distinct from the controlled review.
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	check("normal New Game actual button",true,await control(shell,"New Game"))
	var view: RefCounted = shell.session_shell.creation_view
	if view == null:
		check("normal New Game view instantiated",true,false)
		return result(fixture)
	check("normal New Game opens race","race",view.navigation.step().hook)
	check("normal draft is not controlled",false,view.controlled)
	check("normal stock provider still rejects entry",false,shell.session_shell.core.provider.prepare({},{}).ok)
	view.exit()
	var provider := Inputs.new()
	check("controlled real-shell view opens",true,view.open(provider).ok)
	shell.session_shell.render()
	await shell.get_tree().process_frame
	check("stock choice actual handler",true,await control(shell,"breton"))
	check("stock owner receives choice","breton",view.owner.projection().selections.get("race"))
	# Prevalidate the next two steps, then hold Confirm across page handoffs. A
	# repeated press must not advance even when the destination can pass validation.
	view.owner.edit("gender",view.owner.token(),"female")
	view.owner.edit("class_method",view.owner.token(),"list")
	view.owner.edit("class",view.owner.token(),"class-16")
	shell.render()
	await shell.get_tree().process_frame
	var next_button := find_button(shell.panel,"Next")
	next_button.grab_focus()
	var held := InputEventKey.new()
	held.keycode = KEY_ENTER
	held.pressed = true
	Input.parse_input_event(held)
	await shell.get_tree().process_frame
	held.echo = true
	Input.parse_input_event(held)
	await shell.get_tree().process_frame
	check("held keyboard echo cannot skip valid step","race",view.navigation.step().hook)
	held.pressed = false
	held.echo = false
	Input.parse_input_event(held)
	await shell.get_tree().process_frame
	check("fresh keyboard after held release",true,await control(shell,"Next"))
	check("fresh keyboard reaches class method","class_method",view.navigation.step().hook)
	var joy := InputEventJoypadButton.new()
	joy.device = 991
	joy.button_index = JOY_BUTTON_A
	joy.pressed = true
	find_button(shell.panel,"Next").grab_focus()
	shell._input(joy)
	await shell.get_tree().process_frame
	shell._input(joy)
	await shell.get_tree().process_frame
	check("held controller confirm one handoff","class",view.navigation.step().hook)
	joy.pressed = false
	shell._input(joy)
	view.restart()
	shell.render()
	await shell.get_tree().process_frame
	await control(shell,"breton")
	check("stock next actual handler",true,await control(shell,"Next"))
	check("stock next opens gender","gender",view.navigation.step().hook)
	var actual_id: String = view.owner.projection().id
	check("stock restart actual handler",true,await control(shell,"Restart"))
	check("stock restart new identity",false,actual_id == view.owner.projection().id)
	check("stock restart clears values",{},view.owner.projection().selections)
	check("stock exit actual handler",true,await control(shell,"Exit creation"))
	check("stock exit clears draft",{},view.owner.projection())
	view.open(Inputs.new())
	var route_guard := 20
	while view.navigation.step().hook != "name" and route_guard > 0:
		route_guard -= 1
		var hook: String = view.navigation.step().hook
		view.action("edit",view.navigation.context(),view.inputs.fixture.preset[hook])
		view.action("next",view.navigation.context())
	shell.render()
	await shell.get_tree().process_frame
	var name_field: LineEdit
	for child in view._page.get_children():
		if child is LineEdit: name_field = child
	name_field.text = "Clair de Lune"
	name_field.text_changed.emit(name_field.text)
	name_field.grab_focus()
	var before_locale: Dictionary = view.owner.projection()
	check("creation locale owner applies",true,controller.providers.presentation.switch_locale("fr"))
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	check("creation translated Next control",true,find_button(shell.panel,"Suivant") != null)
	check("creation locale changes no draft facts",before_locale,view.owner.projection())
	for child in view._page.get_children():
		if child is LineEdit: name_field = child
	check("creation locale retains typed name","Clair de Lune",name_field.text)
	check("creation locale restores text focus",true,name_field == shell.get_viewport().gui_get_focus_owner())
	check("creation fallback font available",true,name_field.get_theme_font("font") != null)
	controller.providers.presentation.switch_locale("en")
	view.exit()
	view.open(Inputs.new())
	var prepare_guard := 20
	while view.navigation.step().hook != "summary" and prepare_guard > 0:
		prepare_guard -= 1
		var hook: String = view.navigation.step().hook
		view.action("edit",view.navigation.context(),view.inputs.fixture.preset[hook])
		view.action("next",view.navigation.context())
	var stock_provider: RefCounted = shell.session_shell.core.provider
	var pending := PendingPreparation.new()
	shell.session_shell.core.provider = pending
	check("actual shell pending creation admitted","pending",view.action("begin",view.navigation.context()).kind)
	var preflight_ticket: Dictionary = shell.session_shell.core.ticket()
	shell.session_shell.options()
	check("actual shell exit cancels captured preflight",1,pending.cancelled)
	check("actual shell exit discards pending draft",{},view.owner.projection())
	check("actual shell cancelled preflight keeps no session","",shell.session_shell.core.snapshot().session)
	check("actual shell obsolete preflight callback rejected",false,shell.session_shell.core.complete_preflight(preflight_ticket,{"ok":true}))
	shell.session_shell.core.provider = stock_provider
	var art: RefCounted = controller.providers.creation_art
	for target: String in art.FILES:
		var selected: Dictionary = art.resolve(target)
		check("real art "+target,true,selected.ok)
	var cost: Dictionary = art.measurements.duplicate(true)
	started = Time.get_ticks_usec()
	for revisit in 100:
		for target: String in art.FILES: art.resolve(target)
	measurements.revisit_usec = Time.get_ticks_usec()-started
	check("revisits do not decode",cost.baseline_decodes,art.measurements.baseline_decodes)
	check("revisits do not create textures",cost.textures,art.measurements.textures)
	check("unknown art falls back",false,art.resolve("creation.absent").ok)
	measurements.art = art.measurements.duplicate(true)
	if DisplayServer.get_name() != "headless":
		view.open(Inputs.new())
		shell.session_shell.render()
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := shell.get_viewport().get_texture().get_image()
		check("rendered creation image",false,image.is_empty())
		image.save_png(sandbox.path_join("creation-race.png"))
		var guard := 20
		while view.navigation.step().hook != "summary" and guard > 0:
			guard -= 1
			var hook: String = view.navigation.step().hook
			if hook == "name":
				var field: LineEdit
				for child in view._page.get_children():
					if child is LineEdit: field = child
				field.text = "Rendered Adventurer"
				check("rendered name actual apply",true,await control(shell,"Use name"))
			else:
				var value: Variant = view.inputs.fixture.preset[hook]
				var label := ""
				for choice: Dictionary in view.inputs.choices(hook):
					if Draft.same_value(choice.get("value",choice.id),value): label = str(choice.label); break
				check("rendered actual edit "+hook,true,await control(shell,label))
			await RenderingServer.frame_post_draw
			shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join("creation-"+hook+".png"))
			check("rendered actual next "+hook,true,await control(shell,"Next"))
		check("rendered stock controls reach summary","summary",view.navigation.step().hook)
		await RenderingServer.frame_post_draw
		shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join("creation-summary.png"))
		check("rendered begin actual stock rejection",true,await control(shell,"Begin Game"))
		check("rendered begin creates no player session","",shell.session_shell.core.snapshot().session)
		check("rendered unavailable entry explicit",true,view.notice.contains("unavailable"))
		var admission_serial: int = shell.session_shell.core._serial
		await control(shell,"Begin Game")
		check("rendered duplicate begin no new admission",admission_serial,shell.session_shell.core._serial)
		var captured: Dictionary = shell.session_shell.core.last_intent.selection.creation.duplicate(true)
		check("rendered explicit retry control",true,await control(shell,"Retry Begin Game"))
		check("rendered explicit retry one admission",admission_serial+1,shell.session_shell.core._serial)
		check("rendered retry preserves immutable input",captured,shell.session_shell.core.last_intent.selection.creation)
		var original_art: Dictionary = art._textures["creation.race"]
		art._textures["creation.race"] = {"ok":false,"reason":"Controlled optional-art absence."}
		view.restart()
		shell.render()
		await shell.get_tree().process_frame
		check("rendered missing art uses real fallback",true,view._page.get_child(0) is ColorRect)
		await RenderingServer.frame_post_draw
		shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join("creation-missing-art.png"))
		art._textures["creation.race"] = original_art
		view.exit()
	return result(fixture)

func result(fixture: Dictionary) -> Dictionary:
	return {"ok":checks.all(func(item): return item.expected == item.actual),"checks":checks,"count":checks.size(),"fixture":fixture.fixture,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"measurements":measurements,"human_pass":false}

func publication(_shell: Control, fixture: Dictionary, record: Dictionary) -> void:
	var Controller = preload("res://scripts/startup/startup_controller.gd")
	var app := Controller.new()
	app.providers.enable_media_replacements()
	app.providers.enable_actor_inputs()
	app.providers.enable_creation()
	app.start({"executable_dir":sandbox.path_join("publication/executable"),"per_user_dir":sandbox.path_join("publication/user")})
	app.settings.effective["startup/show_setup"] = true
	var package := manifest("creation.review")
	package.capabilities = ["data.creation-flow-v1","data.creation-career-v1","data.actor-inputs-v1","data.actor-baseline-v1","data.media-v1"]
	package.content = ["flow.json","media.json","career.json","preset.json","numbers.json"]
	var root: String = app.mods.root.path_join("Mods/creation")
	preload("res://tests/publication_fixture.gd").write(root.path_join("mod.json"),package)
	var steps: Dictionary = record.value.steps.duplicate(true)
	steps.race.title = "Pack race title"
	var patch := {"domain":Flow.DOMAIN,"path":"flows","operation":"patch","entries":[{"id":"stock","value":{"steps":steps}}]}
	preload("res://tests/publication_fixture.gd").write(root.path_join("flow.json"),patch)
	preload("res://tests/publication_fixture.gd").write(root.path_join("career.json"),{"domain":"char.career","path":"policy","operation":"patch","entries":[{"id":"stock","value":{"attribute_total":401}}]})
	var preset_data: Dictionary = _shell.controller.providers.definitions.query("actor.inputs","catalog","class-16").record.value.data.duplicate(true)
	preset_data.hit_points_per_level = 17 # Pinned Warrior baseline is 20; prove an actual change.
	preload("res://tests/publication_fixture.gd").write(root.path_join("preset.json"),{"domain":"actor.inputs","path":"catalog","operation":"patch","entries":[{"id":"class-16","value":{"data":preset_data}}]})
	var multipliers: Dictionary = _shell.controller.providers.definitions.query("actor.baseline","policy","player").record.value.multipliers.duplicate(true)
	multipliers["5"] = {"numerator":3,"denominator":4}
	preload("res://tests/publication_fixture.gd").write(root.path_join("numbers.json"),{"domain":"actor.baseline","path":"policy","operation":"patch","entries":[{"id":"player","value":{"multipliers":multipliers}}]})
	preload("res://tests/publication_fixture.gd").write(app.mods.root.path_join("Overrides/career.json"),{"domain":"char.career","path":"policy","operation":"patch","entries":[{"id":"stock","value":{"attribute_total":402}}]})
	var image := Image.create(2,2,false,Image.FORMAT_RGBA8)
	image.fill(Color.MAGENTA)
	image.save_png(root.path_join("art.png"))
	var media_patch := {"domain":"media.assets","path":"exports","operation":"add","entries":[{"id":"review-art","value":{"schema":"media-declarations-v1","kind":"export","type":"image","file":"art.png","profile":"png-v1"}}]}
	preload("res://tests/publication_fixture.gd").write(root.path_join("media.json"),media_patch)
	steps.race.title = "Loose race title"
	preload("res://tests/publication_fixture.gd").write(app.mods.root.path_join("Overrides/flow.json"),{"domain":Flow.DOMAIN,"path":"flows","operation":"patch","entries":[{"id":"stock","value":{"steps":steps}}]})
	app.mods.rescan()
	check("creation package discovered",true,app.mods.rows().any(func(row): return row.id == "creation.review"))
	for row: Dictionary in app.mods.rows():
		if row.id == "creation.review" and not row.enabled: app.mods.edit("creation.review","toggle")
	app.select_folder(fixture.classic_source)
	app.continue_to_menu("run")
	check("real package loose creation publication","main_menu",app.route)
	var published: Dictionary = app.providers.definitions.query(Flow.DOMAIN,"flows","stock")
	check("loose creation field wins","Loose race title",published.record.value.steps.race.title)
	check("creation contributors retained",true,published.record.contributors.size() >= 3)
	var career_policy: Dictionary = app.providers.definitions.query("char.career","policy","stock")
	check("career package loose policy precedence",402,int(career_policy.record.value.attribute_total))
	check("career policy contributors retained",true,career_policy.record.contributors.size() >= 3)
	var resolved_provider := preload("res://scripts/char/creation_inputs.gd").new()
	resolved_provider.definitions = app.providers.definitions
	resolved_provider.content = app.providers.definitions.content_ticket()
	resolved_provider.prepare()
	check("career preset package actual mechanics",17,resolved_provider.preset("class-16").hit_points_per_level)
	check("career preset uses resolved mana policy",{"numerator":3,"denominator":4},resolved_provider.preset("class-16").spell_points)
	check("career custom uses resolved mana policy",{"ok":true,"numerator":3,"denominator":4},resolved_provider.custom_spell_points({"traits":[]}))
	var exported: Dictionary = app.providers.media.export_resource("creation.review","review-art","image")
	check("package image export through resolver",true,exported.ok)
	if not exported.ok: print("CREATION PACKAGE DIAGNOSTIC ",exported," contributors ",published.record.contributors)
	check("creation content remains run locked","locked",app.providers.definitions.prepare(app.mods).kind)
	check("late art target registration rejects",false,app.providers.media.register_target("late.creation","image",[],Callable()).ok)
	app.providers.dispose()
	app.storage.adapter.release()
	app = Controller.new()
	app.providers.enable_media_replacements()
	app.providers.enable_creation()
	app.start({"executable_dir":sandbox.path_join("invalid-publication/executable"),"per_user_dir":sandbox.path_join("invalid-publication/user")})
	app.settings.effective["startup/show_setup"] = true
	var invalid: Dictionary = record.value.duplicate(true)
	invalid.routes[0].steps.append("race")
	preload("res://tests/publication_fixture.gd").write(app.mods.root.path_join("Overrides/invalid.json"),{"domain":Flow.DOMAIN,"path":"flows","operation":"replace","entries":[{"id":"stock","value":invalid}]})
	preload("res://tests/publication_fixture.gd").write(app.mods.root.path_join("Overrides/invalid-career.json"),{"domain":"char.career","path":"policy","operation":"patch","entries":[{"id":"stock","value":{"hp":{"start":8,"min":9,"max":30}}}]})
	app.select_folder(fixture.classic_source)
	check("cyclic loose flow blocks candidate","package_recovery",app.route)
	check("invalid flow publishes no partial data",false,app.providers.definitions.query(Flow.DOMAIN,"flows","stock").ok)
	check("career invalid policy publishes no partial data",false,app.providers.definitions.query("char.career","policy","stock").ok)
	check("career invalid HP candidate diagnosed",true,JSON.stringify(app.result.get("issues",[])).contains("HP bounds"))
	app.providers.dispose()
	app.storage.adapter.release()
