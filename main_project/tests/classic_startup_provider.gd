extends "res://scripts/startup/provider_boundary.gd"
## Real DATA with explicitly controlled downstream IMP-005 outcome, tests only.
func uses_definition_pipeline() -> bool:
	return false # Preserved named controlled interface; never a real publication pass.

func publish_packages(_classic: Dictionary) -> Dictionary:
	return {"ok": true, "source": "controlled-IMP-005-interface-only", "mods": []}
