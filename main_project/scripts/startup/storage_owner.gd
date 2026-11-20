class_name StartupStorageOwner
extends RefCounted
const Adapter = preload("res://scripts/startup/storage_adapter.gd")
var adapter := Adapter.new()
var context: Dictionary = {}
var inputs: Dictionary = {}
var selected_mode := ""
var selected_path := ""

func resolve(launch: Dictionary, fallback := false) -> Dictionary:
	# Capture launch selection once. Marker changes and Retry do not reselect it.
	if inputs.is_empty():
		inputs = launch.duplicate(true)
		var portable := FileAccess.file_exists(str(inputs.executable_dir).path_join("Portable.txt"))
		selected_mode = "portable" if portable else "standard"
		selected_path = str(inputs.executable_dir).path_join("PortableAppdata") if portable else str(inputs.per_user_dir)
	if fallback:
		selected_mode = "standard_fallback"
		selected_path = inputs.per_user_dir
	if not context.is_empty():
		return {"ok": true, "context": context.duplicate(true)}
	var result := adapter.acquire(selected_path)
	if result.ok:
		for category in ["saves", "settings", "mod_data"]:
			result = adapter.probe(adapter.root.path_join(category))
			if not result.ok:
				break
	if not result.ok:
		adapter.release()
		if result.kind == "in_use":
			result.detail = "This storage directory is already in use by another process. Retry after closing it, or Quit."
		result.choices = ["Retry", "Quit"]
		if result.kind != "in_use" and selected_mode == "portable":
			result.choices = ["Retry", "Use standard storage", "Quit"]
		return result
	var warnings: Array[String] = []
	for category in ["logs", "cache"]:
		if not adapter.probe(adapter.root.path_join(category)).ok:
			warnings.append("Optional %s storage is unavailable." % category)
	context = {"root": adapter.root, "mode": selected_mode, "fallback": selected_mode == "standard_fallback",
		"development": inputs.get("development", true), "warnings": warnings}
	for category in ["saves", "settings", "mod_data", "logs", "cache"]:
		context[category] = adapter.root.path_join(category)
	return {"ok": true, "context": context.duplicate(true)}
