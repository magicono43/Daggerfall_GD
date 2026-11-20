extends "res://scripts/startup/provider_boundary.gd"
## Real DATA with explicitly controlled downstream IMP-005 outcome, tests only.
func publish_packages(_classic: Dictionary) -> Dictionary:
	return {"ok": true, "source": "controlled-IMP-005-interface-only", "mods": []}
