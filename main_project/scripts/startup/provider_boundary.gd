class_name StartupProviderBoundary
extends RefCounted
## DATA access has application lifetime; IMP-005 publication remains independent.
var classic := preload("res://scripts/data/classic_access.gd").new()

func check_classic(candidate: String) -> Dictionary:
	return classic.prepare(candidate)

func activate_classic(checked: Dictionary) -> Dictionary:
	return classic.activate(checked)

func discard_classic_candidate() -> void:
	classic.discard_prepared()

func dispose() -> void:
	classic.dispose()

func publish_packages(_classic: Dictionary) -> Dictionary:
	return {"ok": false, "source": "packages", "reason": "Content package preparation is unavailable in this build. Content support is required to continue."}

func open_menu() -> Dictionary:
	return {"ok": true}
