extends RefCounted

# Harness qualification only. No substitute gameplay providers or RNG/clock owner.
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var checks: Array[Dictionary] = []
	var root: String = shell.controller.storage.context.root
	checks.append({"scenario": "isolated production storage", "expected": true,
		"actual": root.begins_with(str(fixture.sandbox) + "/")})
	checks.append({"scenario": "qualification value", "expected": 1,
		"actual": 0 if fixture.fixture == "assert-fail-v1" else 1})
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var image := shell.get_viewport().get_texture().get_image()
		checks.append({"scenario": "rendered frame available", "expected": true,
			"actual": not image.is_empty()})
		image.save_png(str(fixture.sandbox).path_join("qualification.png"))
	var ok := true
	for item: Dictionary in checks:
		ok = ok and item.expected == item.actual
	return {"ok": ok, "checks": checks, "count": checks.size(),
		"engine": Engine.get_version_info(), "display": DisplayServer.get_name(),
		"fixture": fixture.fixture, "inputs": fixture.inputs}
