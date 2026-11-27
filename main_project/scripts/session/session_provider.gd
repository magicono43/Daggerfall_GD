extends RefCounted
## Mode owners implement these checked entry points. A pending result is completed
## through CORE.complete_* with the supplied immutable ticket, never global state.
var death_video: Callable
var creation_video: Callable
var cancel_creation_video: Callable
func prepare(_ticket: Dictionary, _intent: Dictionary) -> Dictionary:
	if creation_video.is_valid() and _intent.get("mode") == "new" and _intent.get("selection",{}).get("creation",{}).get("schema") == "creation-submission-v1": return creation_video.call(_ticket,_intent)
	return {"ok": false, "reason": "Character entry and restore support is unavailable in this build."}

func cancel_preparation(_ticket: Dictionary) -> void:
	if cancel_creation_video.is_valid(): cancel_creation_video.call(_ticket)

func cleanup(_ticket: Dictionary, _scope: String) -> Dictionary:
	return {"ok": true} # No provider-owned gameplay services in the stock shell yet.

func initialize(_ticket: Dictionary, _prepared: Dictionary) -> Dictionary:
	return {"ok": false, "reason": "Required gameplay services unavailable."}

func initialize_baseline(_ticket: Dictionary) -> Dictionary:
	return {"ok": false, "reason": "Required baseline owner unavailable."}

func death_presentation(_ticket: Dictionary) -> Dictionary:
	if death_video.is_valid(): return death_video.call(_ticket)
	return {"ok": true, "outcome": "Failed"} # Approved missing-media bypass, no substitute notice.

func open_menu(_ticket: Dictionary) -> Dictionary:
	return {"ok": true}
