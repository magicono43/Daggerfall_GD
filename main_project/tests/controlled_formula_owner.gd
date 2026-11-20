extends "res://tests/controlled_session_provider.gd"
var current: Dictionary = {}
var serial := 0
var applications := 0
var applied_value := 0
var last: Dictionary = {}

func bindings() -> Array:
	return [{"role":"fixture_formula_owner","owner":"controlled-formula-owner-v1","lifetime":"session","required":true,
		"ready":true,"provider":self,"formula_hooks":["fixture.integer"]}]

func begin(scope: String) -> Dictionary:
	serial += 1
	current = {"session":scope,"attempt":serial}
	return current.duplicate(true)

func formula_operation_current(operation: Dictionary) -> bool:
	return not current.is_empty() and operation == current

func evaluate(registry: RefCounted, core: SessionLifecycle, value: int) -> Dictionary:
	var operation := begin(core.snapshot().session)
	last = registry.invoke("fixture.integer",value,core,self,operation.session,operation)
	if last.ok:
		applications += 1
		applied_value = last.value
	current.clear()
	return last.duplicate(true)
