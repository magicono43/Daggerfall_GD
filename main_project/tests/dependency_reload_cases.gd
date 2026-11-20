extends RefCounted
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var owner = shell.controller.mods
	var plan: Dictionary = owner.validate_dependencies()
	var checks: Array[Dictionary] = [
		{"scenario": "fresh launch validates real plan before publication", "expected": "dependencies", "actual": shell.controller.result.get("source")},
		{"scenario": "Default restored", "expected": "default", "actual": owner.selected},
		{"scenario": "fresh launch remains editable", "expected": false, "actual": owner.locked},
		{"scenario": "unsaved disable not persisted", "expected": true, "actual": owner.rows()[1].enabled},
		{"scenario": "run skip not persisted", "expected": false, "actual": owner.rows()[2].skipped},
		{"scenario": "run suppression not persisted", "expected": true, "actual": owner.suppressions.is_empty()},
		{"scenario": "cycle revalidated on restart", "expected": true, "actual": plan.cycles.has(["plan.a", "plan.b", "plan.c", "plan.a"])},
		{"scenario": "planning never records successful menu", "expected": "", "actual": owner.committed.last_successful}]
	var ok := true
	for entry: Dictionary in checks:
		ok = ok and entry.expected == entry.actual
	return {"ok": ok, "count": checks.size(), "checks": checks, "engine": Engine.get_version_info(), "display": DisplayServer.get_name(),
		"fixture": fixture.fixture, "inputs": fixture.inputs, "plan": plan}
