extends "res://tests/controlled_session_provider.gd"
## Only lifecycle/activity authorization is controlled; CORE, DATA and TIME real.
var core: RefCounted
var restored: Variant
var baseline_clock: Dictionary = {}
var authorized := true
var callback: Callable
var due_work := false
var peers: Array = []
func prepare(ticket: Dictionary, intent: Dictionary) -> Dictionary:
	var result := super.prepare(ticket,intent)
	if intent.mode == "load": result.calendar_state = restored
	return result
func initialize_baseline(ticket: Dictionary) -> Dictionary:
	baseline_clock = core.calendar.query()
	return super.initialize_baseline(ticket)
func bindings() -> Array:
	return [{"role":"controlled-calendar-entry","owner":"CORE","lifetime":"session","required":true,"ready":true,"provider":self,"calendar_activity":"controlled-rest","calendar_due_work":due_work}]+peers
func calendar_activity_current(_request: Dictionary) -> bool:
	if callback.is_valid(): callback.call()
	return authorized
