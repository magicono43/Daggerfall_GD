extends RefCounted
const Core = preload("res://scripts/session/session_lifecycle.gd")
const Owner = preload("res://tests/controlled_random_owner.gd")
const Seeds = preload("res://scripts/rule/seed_derivation.gd")
const Mapping = preload("res://scripts/rule/random_mapping.gd")
var checks: Array[Dictionary] = []
var sequence := 0
var evidence: Array = []

class MaterialProvider:
	extends RefCounted
	var queue: Array = []
	var calls: Array = []
	var action: Callable
	func supply(ticket: Dictionary, mode: String) -> Dictionary:
		calls.append({"ticket": ticket.duplicate(true), "mode": mode})
		if action.is_valid():
			var callback := action
			action = Callable()
			callback.call()
		return Seeds.validate_material(queue.pop_front()) if not queue.is_empty() else {"ok": false}

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario": id, "expected": expected, "actual": actual})

func intent(core: SessionLifecycle, mode: String = "new", selection: Dictionary = {}) -> Dictionary:
	sequence += 1
	return {"id": "rng-operation-%d" % sequence, "mode": mode, "origin": core.snapshot().session, "selection": selection}

func material(byte: int) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(32)
	bytes.fill(byte)
	return bytes

func active(core: SessionLifecycle) -> Dictionary:
	var view: Dictionary = core.randomness.snapshot()
	view.erase("candidate")
	return view

func source(core: SessionLifecycle, owner: RefCounted, purpose: String) -> RefCounted:
	var selected: Dictionary = core.randomness.source(core.snapshot().session, owner, purpose)
	check("source bound " + purpose, true, selected.ok)
	return selected.get("source")

func start(core: SessionLifecycle, mode: String = "new", selection: Dictionary = {}) -> Dictionary:
	var request := intent(core, mode, selection)
	var result := core.request(request)
	if core.snapshot().phase == "confirmation":
		core.confirm(core.ticket(), true)
	return core.request(request) if result.kind == "pending" else result

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	check("normal isolated leased storage", true, shell.controller.storage.context.root.begins_with(str(fixture.sandbox) + "/"))
	var factory := MaterialProvider.new()
	factory.queue = [material(0)]
	var core := Core.new(factory.supply)
	var owner := Owner.new()
	core.provider = owner
	check("startup readiness remains required", "unavailable", core.request(intent(core)).kind)
	core.startup_route_changed("main_menu")
	var notifications: Array = []
	core.milestone.connect(func(name: String, context: Dictionary):
		if name in ["new_session_ready", "session_restored"]:
			notifications.append({"event": name, "session": context.session, "random": core.randomness.snapshot(),
				"source_ready": core.randomness.source(context.session, owner, "combat").ok}))
	check("new entry succeeds", "Succeeded", start(core).kind)
	check("initialization precedes readiness publication", ["new_session_ready",true], [notifications.back().event,notifications.back().source_ready])
	check("initialization occurs once", 1, factory.calls.size())
	check("all initial purpose counters zero", zero_counts(), active(core).sources)
	var scope: String = core.snapshot().session
	var handles: Dictionary = {}
	for purpose: String in Seeds.PURPOSES:
		handles[purpose] = source(core, owner, purpose)
	check("UI cannot obtain owner source", false, core.randomness.source(scope, shell, "combat").ok)
	check("undeclared purpose rejected", false, core.randomness.source(scope, owner, "presentation").ok)
	check("wrong session rejected", false, core.randomness.source("obsolete", owner, "combat").ok)
	var combat := []
	for i in 6:
		combat.append("%08x" % handles.combat.raw().value)
	check("session combat reference vector", ["863b652e","78d434fe","4231b50f","9bde62af","1404fe92","56575055"], combat)
	var untouched := {}
	for purpose: String in ["progression","loot","quest"]:
		untouched[purpose] = []
	for i in 6:
		for j in i + 1:
			handles.combat.raw()
		for purpose: String in untouched:
			untouched[purpose].append("%08x" % handles[purpose].raw().value)
	check("interleaved purpose isolation", {
		"progression":["ff0b25f6","8e983a84","62fc69c9","0e66c3a5","dbd3a6dd","92396db2"],
		"loot":["75503fb1","6e1b6c39","32e421f2","c05d3b04","e8e299bf","596e4412"],
		"quest":["ed178ad9","b2f009c0","2c2b9c5f","610284ca","018b5f81","9709605b"]}, untouched)
	check("interleaved raw counts", [27,6,6,6], Seeds.PURPOSES.map(func(p: String): return active(core).sources[p].raw_count))
	var before := active(core)
	var copy: Dictionary = core.randomness.snapshot()
	copy.sources.combat.raw_count = 10000
	copy.material_hex = "changed observer copy"
	var preview := Seeds.derive(material(0), "combat")
	for i in 10:
		preview.source.raw()
	check("diagnostic and isolated preview leave live sources intact", before, active(core))
	var hold := core.gates.acquire("fixture-pause", scope, ["simulation","input"])
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	check("pause preserves sources across frames", before, active(core))
	check("pause preserves simulation eligibility", false, core.gates.simulation())
	core.gates.release(hold,"fixture-pause")
	check("resume does not initialize", 1, factory.calls.size())
	# Owner location object replacement uses the existing session gate scope; no RNG lifecycle request.
	var location := Node.new()
	shell.add_child(location)
	location.queue_free()
	await shell.get_tree().process_frame
	check("ordinary scene object replacement leaves sources intact", before, active(core))
	var invalid: Dictionary = handles.loot.bounded(0)
	check("session invalid bound fails", false, invalid.ok)
	check("invalid bound consumes nothing", before, active(core))
	var resolution := owner.prepare_reward("pending", handles.progression)
	check("owner resolves reward once", true, resolution.ok)
	
	before = active(core)
	check("owner retry observes retained result", resolution, owner.prepare_reward("pending", handles.progression))
	check("owner precommit delivery interruption", false, owner.deliver_reward("pending","before_commit").ok)
	check("precommit interruption applies nothing", 0, owner.facts.applications)
	check("owner retry completes delivery", true, owner.deliver_reward("pending").ok)
	check("duplicate delivery is acknowledged", true, owner.deliver_reward("pending").ok)
	check("consequence commits once", [1,resolution.roll], [owner.facts.applications,owner.facts.balance])
	check("result diagnostics and delivery retries do not draw", before, active(core))
	owner.prepare_reward("ack-pending", handles.progression)
	check("postcommit interruption is explicit", false, owner.deliver_reward("ack-pending","after_commit").ok)
	check("postcommit consequence retained", [2,false], [owner.facts.applications,owner.facts.rewards["ack-pending"].acknowledged])
	check("postcommit retry acknowledges", true, owner.deliver_reward("ack-pending").ok)
	check("postcommit retry cannot apply twice", [2,resolution.roll+owner.facts.rewards["ack-pending"].resolution.roll], [owner.facts.applications,owner.facts.balance])
	owner.prepare_reward("saved-pending",handles.progression)
	check("new owner-authorized attempt advances", 3, active(core).sources.progression.logical_count)
	owner.prepare_reward("ack-saved",handles.progression)
	check("saved postcommit interruption explicit", false, owner.deliver_reward("ack-saved","after_commit").ok)
	var saved := owner.retained_snapshot()
	# Write fixture-only owner facts into disposable storage, never a production save schema.
	var file := FileAccess.open(str(fixture.sandbox).path_join("retained-owner.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(saved))
	file.close()
	check("saved owner values include assigned and pending facts", ["Assigned fixture name",false,false], [saved.assigned_name,saved.rewards["saved-pending"].applied,saved.rewards["ack-saved"].acknowledged])
	await load_cases(core, owner, factory, handles, saved)
	await failure_cases(core, owner, factory)
	evidence.append({"controlled_material_requests": factory.calls.duplicate(true), "readiness": notifications.duplicate(true)})
	core.dispose()
	check("disposal clears all sources and candidates", [true,"",{}], [core.randomness.snapshot().disposed,core.randomness.snapshot().scope,core.randomness.snapshot().candidate])
	check("disposal revokes held handles", false, handles.combat.raw().ok)
	var invalid_core := Core.new(Callable(owner,"missing_material_provider"))
	invalid_core.provider = Owner.new()
	invalid_core.startup_route_changed("main_menu")
	check("invalid explicit material provider cannot fall back to OS", "Failed", start(invalid_core).kind)
	invalid_core.dispose()
	await shell_cases(shell, fixture)
	return result(fixture)

func zero_counts() -> Dictionary:
	var result := {}
	for purpose: String in Seeds.PURPOSES:
		result[purpose] = {"raw_count":0,"logical_count":0}
	return result

func load_cases(core: SessionLifecycle, owner: RefCounted, factory: RefCounted, handles: Dictionary, saved: Dictionary) -> void:
	var original := active(core)
	var original_facts: Dictionary = owner.retained_snapshot()
	factory.queue.append(material(255))
	owner.hold_preflight = true
	var request := intent(core,"load",{"retained_owner":saved})
	check("load remains pending in preflight", "pending", core.request(request).kind)
	var old_ticket := core.ticket()
	check("candidate material is initialized independently", [true,material(255).hex_encode()], [core.randomness.snapshot().candidate.initialized,core.randomness.snapshot().candidate.material_hex])
	check("candidate never replaces surviving sources", original, active(core))
	check("candidate exposes no gameplay source", false, handles.loot.raw().ok)
	check("blocked draw consumes nothing", original, active(core))
	check("cancellation succeeds", true, core.cancel(old_ticket))
	check("cancel retains outgoing sources and facts", [original,original_facts], [active(core),owner.retained_snapshot()])
	check("cancel removes candidate", {}, core.randomness.snapshot().candidate)
	check("obsolete preflight callback rejected", false, core.complete_preflight(old_ticket,{"ok":true}))
	check("obsolete callback leaves sources unchanged", original, active(core))
	factory.queue.append(material(255))
	owner.prepare_ok = false
	owner.hold_preflight = false
	check("failed load preflight", "Failed", start(core,"load").kind)
	check("failed load preserves sources and owner values", [original,original_facts], [active(core),owner.retained_snapshot()])
	owner.prepare_ok = true
	factory.queue.append(material(255))
	owner.hold_readiness = true
	owner.default_assigned_name = "Changed fixture name bank"
	check("load reaches held readiness", "pending", start(core,"load",{"retained_owner":saved}).kind)
	var replacement_ticket := core.ticket()
	check("new session is gated before handoff", [false,false], [core.snapshot().ready,core.gates.gameplay_input()])
	check("old handles revoked at retirement", false, handles.combat.raw().ok)
	check("candidate source cannot be acquired during restore", false, core.randomness.source(core.snapshot().session,owner,"combat").ok)
	check("fresh candidate still has no active source", "", active(core).scope)
	owner.hold_readiness = false
	check("successful load handoff", true, core.complete_readiness(replacement_ticket,{"ok":true,"services":owner.bindings(),"death_authority":owner}))
	check("loaded owner facts retained exactly", saved, owner.retained_snapshot())
	check("loaded sources freshly initialized before checks", zero_counts(), active(core).sources)
	check("load adopts only candidate material", material(255).hex_encode(), active(core).material_hex)
	check("duplicate readiness cannot reinitialize", false, core.complete_readiness(replacement_ticket,{"ok":true,"services":owner.bindings()}))
	var restored := source(core,owner,"combat")
	var vectors: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/randomness_vectors.json"))
	var expected: String = vectors.derivations[4].outputs[0]
	check("successful load first draw uses candidate vector", expected, "%08x" % restored.raw().value)
	var old_epoch: int = active(core).epoch
	factory.queue.append(material(255))
	check("repeated successful load initializes again", "Succeeded", start(core,"load",{"retained_owner":saved}).kind)
	check("repeated load replaces epoch", true, active(core).epoch > old_epoch)
	check("repeated load resets every stream", zero_counts(), active(core).sources)
	check("prior loaded source cannot follow replacement", false, restored.raw().ok)
	var repeated := source(core,owner,"combat")
	check("same fixture material may repeat output", expected, "%08x" % repeated.raw().value)
	var before := active(core)
	check("saved pending resolution reused after load", saved.rewards["saved-pending"].resolution, owner.prepare_reward("saved-pending", source(core,owner,"progression")))
	check("saved pending consequence applies", true, owner.deliver_reward("saved-pending").ok)
	check("restored consequence applies only once", [saved.applications+1,saved.balance+saved.rewards["saved-pending"].resolution.roll], [owner.facts.applications,owner.facts.balance])
	check("restored delivery retries", true, owner.deliver_reward("saved-pending").ok)
	owner.deliver_reward("ack-saved")
	check("restored postcommit acknowledgment cannot reapply", [saved.applications+1,saved.balance+saved.rewards["saved-pending"].resolution.roll,true], [owner.facts.applications,owner.facts.balance,owner.facts.rewards["ack-saved"].acknowledged])
	check("restored retries do not draw", before, active(core))

func failure_cases(core: SessionLifecycle, owner: RefCounted, factory: RefCounted) -> void:
	var original := active(core)
	var prepares: int = owner.prepares
	check("entropy failure blocks load preflight", "Failed", start(core,"load").kind)
	check("entropy failure preserves surviving sources", original, active(core))
	check("entropy failure never calls restore provider", prepares, owner.prepares)
	factory.queue.append(material(0))
	factory.action = func(): core.cancel(core.ticket())
	check("reentrant entropy cancellation remains cancelled", "Cancelled", start(core,"load").kind)
	check("obsolete entropy work leaves no candidate", {}, core.randomness.snapshot().candidate)
	check("obsolete entropy work preserves surviving session", original, active(core))
	factory.queue.append(material(0))
	owner.readiness_ok = false
	check("postreplacement readiness failure explicit", "Failed", start(core,"load").kind)
	check("failed restore publishes no active source", [false,"",{}], [core.snapshot().ready,active(core).scope,core.randomness.snapshot().candidate])
	owner.readiness_ok = true
	core.recover_menu()
	factory.queue.append(material(0))
	owner.purposes = ["presentation"]
	check("invalid source binding blocks readiness", "Failed", start(core).kind)
	check("invalid source binding publishes nothing", [false,"",{}], [core.snapshot().ready,active(core).scope,core.randomness.snapshot().candidate])
	owner.purposes = Seeds.PURPOSES.duplicate()
	core.recover_menu()
	factory.queue.append(material(0))
	check("fresh character after recovery", "Succeeded", start(core).kind)
	check("later character inherits no counters", zero_counts(), active(core).sources)
	var held := source(core,owner,"combat")
	owner.hold_cleanup = true
	var request := intent(core,"return")
	core.request(request)
	core.confirm(core.ticket(),true)
	check("pending cleanup revokes sources immediately", false, held.raw().ok)
	check("retiring session has no active source", "", active(core).scope)
	owner.hold_cleanup = false
	core.complete_cleanup(owner.last_cleanup_ticket,{"ok":true})
	check("return ends scope", "", core.snapshot().session)
	check("new entropy failure cannot publish playable session", "Failed", start(core).kind)
	check("new entropy failure stays gated", [false,""], [core.gates.gameplay_input(),active(core).scope])

func find_button(shell: Control, text: String) -> Button:
	for child in shell.panel.get_children():
		if child is Button and child.text == text:
			return child
	return null

func click(shell: Control, text: String) -> void:
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var button := find_button(shell,text)
	check("stock control " + text,true,button != null)
	if button == null:
		return
	if DisplayServer.get_name() == "headless":
		button.pressed.emit()
	else:
		button.grab_focus()
		var event := InputEventKey.new()
		event.keycode = KEY_ENTER
		event.pressed = true
		Input.parse_input_event(event)
		await shell.get_tree().process_frame
		event = InputEventKey.new()
		event.keycode = KEY_ENTER
		event.pressed = false
		Input.parse_input_event(event)
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame

func shell_cases(shell: Control, fixture: Dictionary) -> void:
	var startup = preload("res://tests/controlled_startup_provider.gd").new()
	startup.resolved_source = str(fixture.sandbox).path_join("controlled-classic")
	shell.controller.providers = startup
	shell.controller.check_content()
	var ui: RefCounted = shell.session_shell
	var owner := Owner.new()
	ui.core.provider = owner
	ui.focus_changed(true)
	shell.render()
	await click(shell,"New Game")
	check("stock entry initializes OS-backed session sources", [true,64], [ui.core.snapshot().ready,str(active(ui.core).get("material_hex", "")).length()])
	var before := active(ui.core)
	var storage: RefCounted = shell.controller.storage.adapter
	await click(shell,"Pause")
	await click(shell,"Settings")
	check("pause and settings preserve live source state", before,active(ui.core))
	check("UI has no registered source capability", false,ui.core.randomness.source(ui.core.snapshot().session,shell,"combat").ok)
	var preference: bool = shell.controller.settings.value(shell.controller.settings.accepted,"startup/show_setup")
	for child in shell.panel.get_children():
		if child is CheckBox:
			child.button_pressed = not preference
	await click(shell,"Apply")
	check("ordinary preference edit committed",not preference,shell.controller.settings.value(shell.controller.settings.accepted,"startup/show_setup"))
	check("ordinary preference change cannot reset sources",before,active(ui.core))
	await click(shell,"Cancel / Back")
	await click(shell,"Resume")
	check("resume preserves every source and initialization", before,active(ui.core))
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		shell.get_viewport().get_texture().get_image().save_png(str(fixture.sandbox).path_join("rng-session.png"))
		check("render observes without drawing",before,active(ui.core))
	await click(shell,"Pause")
	await click(shell,"Return to Title")
	await click(shell,"Discard and Continue")
	check("stock return disposes session sources", "", active(ui.core).scope)
	check("storage lease survives source teardown", true,shell.controller.storage.adapter == storage)
	await click(shell,"New Game")
	check("new stock character gets independent zero counters", zero_counts(),active(ui.core).sources)
	evidence.append({"stock_first_initialization":before,"stock_second_initialization":active(ui.core),"entropy":"OS.get_entropy(32)"})

func result(fixture: Dictionary) -> Dictionary:
	var ok := true
	for item: Dictionary in checks:
		ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),
		"fixture":"IMP-006-session-v1","contract":"session-rng-v1","algorithms":["pcg32-xsh-rr-v1","rpg-rng-v1"],
		"inputs":fixture.inputs,"contexts":evidence,"controlled_owners":"retained-owner-v1; not native SAVE/CHAR/WORLD"}
