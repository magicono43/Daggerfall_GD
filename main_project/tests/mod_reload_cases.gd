extends RefCounted
## Independent engine process, same disposable storage, ordinary launch routing.
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var owner = shell.controller.mods
	var checks: Array[Dictionary] = []
	checks.append({"scenario": "fresh launch reaches real package recovery", "expected": "package_recovery", "actual": shell.controller.route})
	checks.append({"scenario": "saved Default preselected without success history", "expected": "default", "actual": owner.selected})
	checks.append({"scenario": "fresh launch editable", "expected": false, "actual": owner.locked})
	checks.append({"scenario": "unsaved draft discarded across process", "expected": true, "actual": owner.rows()[0].enabled})
	checks.append({"scenario": "run omission not restored", "expected": false, "actual": owner.rows()[0].skipped})
	checks.append({"scenario": "new installation starts disabled", "expected": false, "actual": owner.rows()[-1].enabled})
	checks.append({"scenario": "persisted duplicate decision resolved", "expected": 0, "actual": owner.unresolved().size()})
	checks.append({"scenario": "fresh process cannot fabricate menu history", "expected": "", "actual": owner.committed.last_successful})
	var ok := true
	for item: Dictionary in checks:
		ok = ok and item.expected == item.actual
	return {"ok": ok, "checks": checks, "count": checks.size(), "engine": Engine.get_version_info(),
		"display": DisplayServer.get_name(), "fixture": fixture.fixture, "inputs": fixture.inputs, "selection": owner.selection()}
