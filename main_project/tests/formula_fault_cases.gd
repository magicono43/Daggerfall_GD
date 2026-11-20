extends "res://tests/formula_cases.gd"
## One intentionally engine-raised GDScript callback abort. Harness admits exactly
## the matched checked diagnostic here, never arbitrary/unexpected script errors.
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	setup_packages(shell,fixture)
	var controller: RefCounted = shell.controller
	var registry: RefCounted = controller.providers.formulas
	var callbacks: Dictionary = shell.get_meta("formula_callbacks")
	registry.stage("formula.a","1.0.0",[Fixture.entry(callbacks.a.replacement_a)])
	registry.stage("formula.b","1.0.0",[Fixture.entry(callbacks.b.throws)])
	controller.check_content()
	check("throwing callable signature validates before invocation",true,registry.projection().ok)
	check("throwing provider chosen by MOD order","formula.b",registry.projection().winners[Fixture.HOOK])
	check("preflight does not probe throwing callback",0,callbacks.b.calls)
	check("throwing fixture uses actual menu publication","main_menu",controller.continue_to_menu("run").route)
	var core := Core.new(material)
	core.formulas = registry
	var owner := Owner.new()
	core.provider = owner
	core.startup_route_changed("main_menu")
	check("throwing fixture uses current CORE owner","Succeeded",core_request(core).kind)
	var before: Dictionary = core.randomness.snapshot()
	var failed: Dictionary = owner.evaluate(registry,core,7)
	check("execution error is distinct from invalid result",["callback_error",0],[failed.kind,failed.integer_output])
	check("callback error identifies hook and selected provider",[Fixture.HOOK,"formula.b"],[failed.hook,failed.provider])
	check("checked engine failure inventory",2 if OS.is_debug_build() else 1,failed.callback_errors.size())
	check("debug callback abort or release engine error kind",Logger.ERROR_TYPE_SCRIPT if OS.is_debug_build() else Logger.ERROR_TYPE_ERROR,failed.callback_errors.back().kind)
	check("actual failing execution identified","FormulaCaseCallbacks.throws" if OS.is_debug_build() else "parse_string",failed.callback_errors.back().function)
	check("no earlier provider or builtin fallback",[0,0,1],[callbacks.builtin.calls,callbacks.a.calls,callbacks.b.calls])
	check("callback abort applies no owner value",[0,0],[owner.applications,owner.applied_value])
	check("callback abort gates owner recovery",[false,"recovery"],[core.snapshot().ready,core.snapshot().application])
	check("callback abort makes no RNG draws",before.sources,core.randomness.snapshot().sources)
	check("callback failure cannot change locked winner","formula.b",registry.active().winners[Fixture.HOOK])
	owner.evaluate(registry,core,7)
	registry.active()
	registry.active()
	check("retry and diagnostics cannot invoke callback again",1,callbacks.b.calls)
	contexts.append({"failure":failed,"core":core.snapshot(),"registry":registry.active()})
	core.dispose()
	if fixture.fixture == "formula-extra-error-v1":
		unexpected_error()
	var result := finish(fixture)
	result.fixture = "IMP-006-formula-fault-v1"
	result.checked_callback_errors = failed.callback_errors.duplicate(true)
	result.debug_build = OS.is_debug_build()
	return result

func unexpected_error() -> void:
	JSON.parse_string("{")
	var empty: Dictionary = {}
	var _value: Variant = empty["unexpected_outside_checked_invocation"]
