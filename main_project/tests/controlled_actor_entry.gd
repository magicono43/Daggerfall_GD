extends "res://tests/controlled_session_provider.gd"
## Lifecycle orchestration only. CHAR and RULE are always real composed owners.
func initialize_baseline(_ticket: Dictionary) -> Dictionary:
	return {"pending":true}
func initialize(_ticket: Dictionary, _prepared: Dictionary) -> Dictionary:
	return {"pending":true} # Real entry providers deliberately remain missing.
