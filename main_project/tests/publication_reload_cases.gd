extends RefCounted
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var controller = shell.controller
	var owner = controller.mods
	var data = controller.providers.definitions
	var checks: Array[Dictionary] = [
		{"scenario": "fresh launch returns editable setup", "expected": "optional_setup", "actual": controller.route},
		{"scenario": "fresh MOD unlocked", "expected": false, "actual": owner.locked},
		{"scenario": "run-only enabled edits not restored", "expected": 0, "actual": owner.pending().entries.size()},
		{"scenario": "last actual successful profile restored", "expected": "default", "actual": owner.selected},
		{"scenario": "DATA not published by preparation", "expected": "before_readiness", "actual": data.query("fixture.records", "items/main.json", "sword").kind},
		{"scenario": "external loose edit adopted on restart", "expected": 11, "actual": data.projection().resources["fixture.records:items/main.json"].records.sword.value.power},
		{"scenario": "fresh plan excludes unsaved packages", "expected": 0, "actual": data.projection().plan.order.size()},
		{"scenario": "fresh classic readers ready independently", "expected": true, "actual": controller.providers.classic.ready()}]
	var ok := true
	for item: Dictionary in checks:
		ok = ok and item.expected == item.actual
	return {"ok": ok, "count": checks.size(), "checks": checks, "engine": Engine.get_version_info(), "display": DisplayServer.get_name(), "fixture": fixture.fixture, "inputs": fixture.inputs}
