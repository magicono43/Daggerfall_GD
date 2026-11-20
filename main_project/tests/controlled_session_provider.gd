extends "res://scripts/session/session_provider.gd"
## Fixture only; does not pretend to be CHAR/SAVE/WORLD/AV.
var hold_preflight := false
var prepare_ok := true
var hold_readiness := false
var cleanup_ok := true
var hold_cleanup := false
var last_cleanup_ticket: Dictionary = {}
var readiness_ok := true
var menu_ok := true
var hold_video := false
var prepares := 0
var cleanups := 0
var initializations := 0
var videos := 0
var calls: Array[String] = []
var services: Array = []

func prepare(_ticket: Dictionary, _intent: Dictionary) -> Dictionary:
	prepares += 1
	calls.append("prepare")
	return {"pending": true} if hold_preflight else {"ok": prepare_ok, "selection": _intent.get("selection", {}).duplicate(true), "reason": "Controlled preparation rejection"}

func cancel_preparation(_ticket: Dictionary) -> void:
	calls.append("cancel")

func cleanup(_ticket: Dictionary, _scope: String) -> Dictionary:
	last_cleanup_ticket = _ticket
	cleanups += 1
	# Explicit owner order, retriable checked disposal; app services are never owned here.
	calls.append_array(["stop", "cancel_work", "disconnect", "release"])
	return {"pending": true} if hold_cleanup else {"ok": cleanup_ok, "reason": "Injected unsafe cleanup"}

func bindings() -> Array:
	return services if not services.is_empty() else [{"role": "fixture_actor", "owner": "fixture", "lifetime": "session", "required": true, "ready": true, "provider": self}]

func initialize(_ticket: Dictionary, _prepared: Dictionary) -> Dictionary:
	initializations += 1
	return {"pending": true} if hold_readiness else {"ok": readiness_ok, "services": bindings(), "death_authority": self, "reason": "Injected readiness failure"}

func initialize_baseline(_ticket: Dictionary) -> Dictionary:
	calls.append("baseline")
	return {"ok": true, "services": bindings()}

func death_presentation(_ticket: Dictionary) -> Dictionary:
	videos += 1
	return {"pending": true} if hold_video else {"ok": true, "outcome": "Failed"}

func open_menu(_ticket: Dictionary) -> Dictionary:
	return {"ok": menu_ok}
