extends RefCounted
const Adapter = preload("res://tests/fixture_definition_adapter.gd")

static func contribution(path: String, operation: String, entries: Array, domain := "fixture.records") -> Dictionary:
	return {"domain": domain, "path": path, "operation": operation, "entries": entries}

static func record(id: String, power: int, label := "Fixture", tags: Array = ["base"]) -> Dictionary:
	return {"id": id, "value": {"label": label, "power": power, "tags": tags}}

static func write(path: String, value: Variant) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value if value is String else JSON.stringify(value))
	file.close()

static func configure(shell: Control, fixture: Dictionary) -> void:
	var root: String = str(fixture.sandbox).path_join("shipped")
	if fixture.mode == "publication":
		write(root.path_join("z-other.json"), contribution("other/main.json", "replace", [record("other", 3), record("sword", 12)]))
		write(root.path_join("a-main.json"), contribution("items/main.json", "replace", [record("sword", 1)]))
	var checked: Dictionary = shell.controller.providers.register_content_adapter(Adapter.new(), root, ["z-other.json", "a-main.json"])
	var limited := Adapter.new()
	limited.limited = true
	var second: Dictionary = shell.controller.providers.register_content_adapter(limited, root, [])
	if not checked.ok or not second.ok:
		push_error("Publication fixture adapter registration failed: " + JSON.stringify([checked, second]))
