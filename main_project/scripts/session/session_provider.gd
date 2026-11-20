extends RefCounted
## Mode owners implement these checked entry points. A pending result is completed
## through CORE.complete_* with the supplied immutable ticket, never global state.
func prepare(_ticket: Dictionary, _intent: Dictionary) -> Dictionary:
	return {"ok": false, "reason": "Character entry and restore support is unavailable in this build."}

func cancel_preparation(_ticket: Dictionary) -> void:
	pass

func cleanup(_ticket: Dictionary, _scope: String) -> Dictionary:
	return {"ok": true} # No provider-owned gameplay services in the stock shell yet.

func initialize(_ticket: Dictionary, _prepared: Dictionary) -> Dictionary:
	return {"ok": false, "reason": "Required gameplay services unavailable."}

func initialize_baseline(_ticket: Dictionary) -> Dictionary:
	return {"ok": false, "reason": "Required baseline owner unavailable."}

func death_presentation(_ticket: Dictionary) -> Dictionary:
	return {"ok": true, "outcome": "Failed"} # Approved missing-media bypass, no substitute notice.

func open_menu(_ticket: Dictionary) -> Dictionary:
	return {"ok": true}
