extends "res://tests/mod_cases.gd"
const Fixture = preload("res://tests/formula_fixture.gd")
const Registry = preload("res://scripts/rule/formula_registry.gd")
const Core = preload("res://scripts/session/session_lifecycle.gd")
const Owner = preload("res://tests/controlled_formula_owner.gd")
const Controller = preload("res://scripts/startup/startup_controller.gd")
const Seeds = preload("res://scripts/rule/seed_derivation.gd")
var sequence := 0
var contexts: Array = []

func core_request(core: SessionLifecycle, mode := "new") -> Dictionary:
	sequence += 1
	var request := {"id":"formula-lifecycle-%d" % sequence,"mode":mode,"origin":core.snapshot().session}
	var result := core.request(request)
	if core.snapshot().phase == "confirmation":
		core.confirm(core.ticket(),true)
	return core.request(request) if result.kind == "pending" else result

func material(_ticket: Dictionary, _mode: String) -> Dictionary:
	var bytes := PackedByteArray()
	bytes.resize(32)
	return Seeds.validate_material(bytes)

func scratch(callbacks: Dictionary) -> RefCounted:
	var registry := Registry.new()
	registry.declare_integer_hook(Fixture.HOOK,callbacks.builtin.builtin)
	return registry

func setup_packages(shell: Control, fixture: Dictionary) -> void:
	sandbox = fixture.sandbox
	var controller: RefCounted = shell.controller
	controller.settings.apply({"startup/show_setup":true})
	controller.settings.effective["startup/show_setup"] = true
	var root: String = controller.mods.root.path_join("Mods")
	folder(root.path_join("A"),"formula.a")
	folder(root.path_join("C"),"formula.c") # Installed but disabled: not a hook provider.
	var b := manifest("formula.b")
	b.dependencies = [{"id":"formula.a"}]
	write(root.path_join("B/mod.json"),JSON.stringify(b))
	controller.mods.rescan()
	controller.mods.edit("formula.a","toggle")
	controller.mods.edit("formula.b","toggle")
	controller.select_folder(fixture.classic_source)
	check("real MOD plan order",["formula.a","formula.b"],controller.mods.validate_dependencies().order)
	check("real DATA candidate remains unpublished","before_readiness",controller.providers.definitions.query("fixture.records","items/main.json","sword").kind)

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	setup_packages(shell,fixture)
	var controller: RefCounted = shell.controller
	var mods: RefCounted = controller.mods
	var registry: RefCounted = controller.providers.formulas
	var callbacks: Dictionary = shell.get_meta("formula_callbacks")
	check("initial default selected at preflight","@builtin",registry.projection().winners[Fixture.HOOK])
	registry.stage("formula.b","1.0.0",[Fixture.entry(callbacks.b.replacement_b)])
	registry.stage("formula.a","1.0.0",[Fixture.entry(callbacks.a.replacement_a)])
	controller.check_content()
	check("last MOD provider wins despite B arriving first","formula.b",registry.projection().winners[Fixture.HOOK])
	check("preflight invokes no callbacks",[0,0,0],[callbacks.builtin.calls,callbacks.a.calls,callbacks.b.calls])
	var other := scratch(callbacks)
	other.stage("formula.a","1.0.0",[Fixture.entry(callbacks.a.replacement_a)])
	other.stage("formula.b","1.0.0",[Fixture.entry(callbacks.b.replacement_b)])
	check("reversing arrival order preserves winner",registry.projection().winners,other.prepare(mods).winners)
	other.dispose()
	for invalid: Dictionary in [
		{"provider":"formula.c","version":"1.0.0","entries":[Fixture.entry(callbacks.a.replacement_a)],"kind":"provider_ineligible"},
		{"provider":"absent.provider","version":"1.0.0","entries":[Fixture.entry(callbacks.a.replacement_a)],"kind":"provider_ineligible"},
		{"provider":"formula.a","version":"2.0.0","entries":[Fixture.entry(callbacks.a.replacement_a)],"kind":"provider_ineligible"},
		{"provider":"formula.a","version":"1.0.0","entries":[Fixture.entry(callbacks.a.replacement_a,"unknown.hook")],"kind":"unknown_hook"},
		{"provider":"formula.a","version":"1.0.0","entries":[Fixture.entry(callbacks.a.wrong_type)],"kind":"signature"},
		{"provider":"formula.a","version":"1.0.0","entries":[Fixture.entry(callbacks.a.wrong_arity)],"kind":"signature"},
		{"provider":"formula.a","version":"1.0.0","entries":[Fixture.entry(callbacks.a.replacement_a.bind(3))],"kind":"signature"},
		{"provider":"formula.a","version":"1.0.0","entries":[],"kind":"invalid_registration"}]:
		other = scratch(callbacks)
		other.stage(invalid.provider,invalid.version,invalid.entries)
		var failed: Dictionary = other.prepare(mods)
		check("preflight rejection " + invalid.kind,invalid.kind,failed.issues[0].kind)
		check("no partial/stale winner " + invalid.kind,{},failed.winners)
		other.dispose()
	other = scratch(callbacks)
	other.stage("formula.a","1.0.0",[Fixture.entry(callbacks.a.replacement_a)],"formula.a:missing")
	check("MOD integration eligibility is enforced","provider_ineligible",other.prepare(mods).issues[0].kind)
	other.dispose()
	other = scratch(callbacks)
	other.stage("formula.a","1.0.0",[Fixture.entry(callbacks.a.replacement_a)])
	other.stage("formula.b","1.0.0",[Fixture.entry(callbacks.b.replacement_b),Fixture.entry(callbacks.b.replacement_b,"unknown.hook")])
	var invalid_late: Dictionary = other.prepare(mods)
	check("invalid high-order late entry blocks whole contribution","unknown_hook",invalid_late.issues[0].kind)
	check("invalid high-order contribution cannot silently expose earlier winner",{},invalid_late.winners)
	check("explicit high-order omission accepted",true,other.omit("formula.b",invalid_late.ticket,mods).ok)
	var recovered: Dictionary = other.prepare(mods)
	check("explicit omission exposes earlier valid provider","formula.a",recovered.winners[Fixture.HOOK])
	check("omission removes every high-order registration/provenance",["formula.a"],recovered.provenance.map(func(p: Dictionary): return p.provider))
	other.dispose()
	registry.stage("formula.a","1.0.0",[Fixture.entry(callbacks.a.replacement_a)])
	controller.check_content()
	check("same-provider duplicate blocks actual preflight","formula_preflight",controller.result.kind)
	check("failed contribution clears winners",{},registry.projection().winners)
	var stale: int = registry.projection().ticket
	check("invalid contribution cannot enter menu","package_recovery",controller.continue_to_menu("run").route)
	check("stale omission rejected",false,registry.omit("formula.a",stale,mods).ok)
	shell.render()
	if DisplayServer.get_name() != "headless":
		await shell.get_tree().process_frame
		await shell.get_tree().process_frame
		var omission := find_button(shell.panel,"Omit formula contribution formula.a for this run")
		if omission != null:
			shell.panel.get_parent().ensure_control_visible(omission)
			omission.grab_focus()
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		check("formula recovery omission reachable",true,omission != null and omission.get_global_rect().end.y <= shell.get_viewport_rect().end.y)
		shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join("formula-recovery.png"))
	check("explicit omission exposed through real setup UI",true,await click(shell,"Omit formula contribution formula.a for this run"))
	check("rebuild selects clean remaining provider","formula.b",registry.projection().winners[Fixture.HOOK])
	check("omission retains required package",["formula.a","formula.b"],mods.validate_dependencies().order)
	check("obsolete A provenance removed",["formula.b"],registry.projection().provenance.map(func(p: Dictionary): return p.provider))
	# A dependency edit invalidates omission/candidates and must revalidate the real plan.
	mods.edit("formula.a","toggle")
	controller.check_content()
	check("rebuild revalidates dependencies","package_recovery",controller.route)
	check("dependency failure discards formula candidate",{},registry.projection())
	mods.edit("formula.a","toggle")
	controller.check_content()
	check("MOD revision clears prior omission","duplicate_registration",registry.projection().issues[0].kind)
	registry.omit("formula.a",registry.projection().ticket,mods)
	controller.check_content()
	controller.providers.faults.menu = true
	check("menu failure preserves unpublished registry","menu_recovery",controller.continue_to_menu("run").route)
	check("menu failure does not lock",false,registry.active().locked)
	controller.providers.faults.clear()
	controller.storage.adapter.faults.mod_profiles_publish = true
	check("profile failure preserves unpublished registry","package_recovery",controller.continue_to_menu("run").route)
	check("profile failure cannot publish hooks",false,registry.active().locked)
	controller.storage.adapter.faults.clear()
	var reentrant: Array = []
	controller.providers.before_menu = func():
		reentrant.append(registry.stage("formula.b","1.0.0",[]).ok)
		reentrant.append(registry.prepare(mods).ok)
		reentrant.append(controller.continue_to_menu("run").kind)
	check("actual checked menu entry succeeds","main_menu",controller.continue_to_menu("run").route)
	controller.providers.before_menu = Callable()
	check("reservations reject reentrant mutation",[false,false,"busy"],reentrant)
	check("DATA MOD and hooks lock together",[true,true,true],[controller.menu_entered,mods.locked,registry.active().locked])
	check("published hook retains selected provider","formula.b",registry.active().winners[Fixture.HOOK])
	check("locked stage rejected",false,registry.stage("formula.a","1.0.0",[]).ok)
	check("locked declaration rejected",false,registry.declare_integer_hook("later.hook",callbacks.a.replacement_a).ok)
	check("locked rebuild rejected",false,registry.prepare(mods).ok)
	var core := Core.new(material)
	core.formulas = registry
	var owner := Owner.new()
	core.provider = owner
	core.startup_route_changed("main_menu")
	check("real CORE controlled owner ready","Succeeded",core_request(core).kind)
	var before: Dictionary = core.randomness.snapshot()
	var result: Dictionary = owner.evaluate(registry,core,7)
	check("selected provider computes known value",[true,207,"formula.b"],[result.ok,result.value,result.provider])
	check("selected provider invoked exactly once",[0,0,1],[callbacks.builtin.calls,callbacks.a.calls,callbacks.b.calls])
	check("pure hook consumes no RNG",before,core.randomness.snapshot())
	var ui_operation := owner.begin(core.snapshot().session)
	check("UI cannot invoke an owner hook","stale_context",registry.invoke(Fixture.HOOK,7,core,shell,ui_operation.session,ui_operation).kind)
	var old := owner.begin(core.snapshot().session)
	owner.begin(core.snapshot().session)
	check("stale owner operation rejected","stale_context",registry.invoke(Fixture.HOOK,7,core,owner,old.session,old).kind)
	check("stale operation cannot invoke provider",1,callbacks.b.calls)
	var operation: Dictionary = owner.current.duplicate(true)
	check("invalid input rejects without invocation","invalid_input",registry.invoke(Fixture.HOOK,1001,core,owner,operation.session,operation).kind)
	check("invalid input preserves invocation count",1,callbacks.b.calls)
	core_request(core,"return")
	check("ended-session operation rejected","stale_context",registry.invoke(Fixture.HOOK,7,core,owner,old.session,old).kind)
	check("title return retains application winner","formula.b",registry.active().winners[Fixture.HOOK])
	core_request(core)
	check("new character retains application winner",207,owner.evaluate(registry,core,7).value)
	core_request(core,"load")
	check("successful controlled load retains application winner",207,owner.evaluate(registry,core,7).value)
	controller.settings.apply({"startup/show_setup":false})
	check("ordinary settings preserve lock",true,registry.active().locked)
	# A selected callback that invalidates the owner operation cannot deliver a value.
	var mutable_operation := owner.begin(core.snapshot().session)
	var captured_operation := mutable_operation.duplicate(true)
	callbacks.b.reenter = func():
		var next := owner.begin(core.snapshot().session)
		mutable_operation.clear()
		mutable_operation.merge(next,true)
	var obsolete: Dictionary = registry.invoke(Fixture.HOOK,7,core,owner,core.snapshot().session,mutable_operation)
	check("postcallback obsolete operation fails","stale_context",obsolete.kind)
	check("caller mutation cannot replace captured operation",captured_operation,obsolete.operation)
	callbacks.b.reenter = Callable()
	check("postcallback stale operation enters CORE recovery",[false,"recovery"],[core.snapshot().ready,core.snapshot().application])
	check("stale operation has no automatic fallback",[0,0,4],[callbacks.builtin.calls,callbacks.a.calls,callbacks.b.calls])
	contexts.append({"selected":registry.active(),"session":core.snapshot(),"random":core.randomness.snapshot()})
	core.dispose()
	await default_and_invalid(shell,fixture)
	if DisplayServer.get_name() != "headless":
		shell.render()
		await RenderingServer.frame_post_draw
		shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join("formula-menu.png"))
		check("actual main menu rendered","main_menu",controller.route)
	return finish(fixture)

func default_and_invalid(_shell: Control, fixture: Dictionary) -> void:
	var controller := Controller.new()
	var callbacks := Fixture.configure_controller(controller,sandbox.path_join("other-shipped"))
	controller.start({"executable_dir":sandbox.path_join("other-executable"),"per_user_dir":sandbox.path_join("other-user"),"development":true})
	controller.settings.effective["startup/show_setup"] = true
	controller.select_folder(fixture.classic_source)
	check("built-in candidate comes from real empty MOD plan","@builtin",controller.providers.formulas.projection().winners[Fixture.HOOK])
	check("built-in locks at actual second menu entry","main_menu",controller.continue_to_menu("run").route)
	var core := Core.new(material)
	core.formulas = controller.providers.formulas
	var owner := Owner.new()
	core.provider = owner
	core.startup_route_changed("main_menu")
	core_request(core)
	check("no replacement invokes declared builtin",14,owner.evaluate(controller.providers.formulas,core,7).value)
	check("builtin invoked exactly once",1,callbacks.builtin.calls)
	var operation := owner.begin(core.snapshot().session)
	check("foreign application registry cannot use current binding","stale_context",_shell.controller.providers.formulas.invoke(Fixture.HOOK,7,core,owner,operation.session,operation).kind)
	core.dispose()
	var missing := Core.new(material)
	missing.provider = Owner.new()
	missing.startup_route_changed("main_menu")
	var rejected := core_request(missing)
	check("unpublished required hook blocks session readiness",["Failed",false,""],[rejected.kind,missing.snapshot().ready,missing.randomness.snapshot().scope])
	missing.dispose()
	controller.providers.dispose()
	controller.logger.stop("Controlled second application finished.")
	controller.storage.adapter.release()
	# Invalid-result runtime case uses a separately entered application registry.
	controller = Controller.new()
	callbacks = Fixture.configure_controller(controller,sandbox.path_join("invalid-shipped"))
	controller.start({"executable_dir":sandbox.path_join("invalid-executable"),"per_user_dir":sandbox.path_join("invalid-user"),"development":true})
	folder(controller.mods.root.path_join("Mods/A"),"formula.a")
	folder(controller.mods.root.path_join("Mods/B"),"formula.b")
	controller.mods.rescan()
	controller.mods.edit("formula.a","toggle")
	controller.mods.edit("formula.b","toggle")
	controller.providers.formulas.stage("formula.a","1.0.0",[Fixture.entry(callbacks.a.replacement_a)])
	controller.providers.formulas.stage("formula.b","1.0.0",[Fixture.entry(callbacks.b.invalid)])
	controller.settings.effective["startup/show_setup"] = true
	controller.select_folder(fixture.classic_source)
	controller.continue_to_menu("run")
	core = Core.new(material)
	core.formulas = controller.providers.formulas
	owner = Owner.new()
	core.provider = owner
	core.startup_route_changed("main_menu")
	core_request(core)
	var failed: Dictionary = owner.evaluate(controller.providers.formulas,core,7)
	check("detectable invalid output has distinct failure",["invalid_result",1000001],[failed.kind,failed.integer_output])
	check("invalid result identifies selected hook/provider",[Fixture.HOOK,"formula.b"],[failed.hook,failed.provider])
	check("invalid result has no script exception",[],failed.callback_errors)
	check("invalid result invokes only winner once",[0,0,1],[callbacks.builtin.calls,callbacks.a.calls,callbacks.b.calls])
	check("invalid output applies no owner consequence",[0,0],[owner.applications,owner.applied_value])
	check("runtime failure gates CORE",[false,"recovery"],[core.snapshot().ready,core.snapshot().application])
	check("runtime failure retains locked provider","formula.b",controller.providers.formulas.active().winners[Fixture.HOOK])
	owner.evaluate(controller.providers.formulas,core,7)
	check("blind retry cannot reinvoke failed winner",1,callbacks.b.calls)
	contexts.append({"invalid_result":failed,"registry":controller.providers.formulas.active()})
	core.dispose()
	controller.providers.dispose()
	controller.logger.stop("Controlled invalid-result application finished.")
	controller.storage.adapter.release()

func finish(fixture: Dictionary) -> Dictionary:
	var ok := true
	for item: Dictionary in checks:
		ok = ok and item.expected == item.actual
	return {"ok":ok,"count":checks.size(),"checks":checks,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),
		"fixture":"IMP-006-formula-v1","contract":"integer-formula-v1","inputs":fixture.inputs,"contexts":contexts}
