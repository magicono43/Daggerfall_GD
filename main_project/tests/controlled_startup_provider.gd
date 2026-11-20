extends RefCounted
## Deliberately not a DATA reader. Accept only fixture-selected source outcomes.
var classic_ok := true
var package_ok := true
var menu_ok := true
var classic_calls := 0
var package_calls := 0
var menu_calls := 0
var resolved_source := ""
var on_open := Callable()

func check_classic(candidate: String) -> Dictionary:
	classic_calls += 1
	return {"ok": classic_ok, "source": resolved_source if not resolved_source.is_empty() else candidate,
		"reason": "" if classic_ok else "Controlled missing required file/readability rejection"}

func publish_packages(_classic: Dictionary) -> Dictionary:
	package_calls += 1
	return {"ok": package_ok, "source": "fixture.package@1", "reason": "" if package_ok else "Controlled invalid late contribution",
		"configuration_id": "fixture-configuration-1", "mods": [{"id": "fixture.package", "version": "1"}]}

func open_menu() -> Dictionary:
	menu_calls += 1
	if on_open.is_valid():
		on_open.call()
	return {"ok": menu_ok, "source": "fixture.menu", "reason": "" if menu_ok else "Controlled menu transition failure"}
