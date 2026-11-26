extends "res://scripts/char/creation_biography_inputs.gd"
## Explicit review composition. Only genuinely later increment-4 fields assigned.
var later := preload("res://tests/controlled_creation_inputs.gd").new()
const LATER = ["name","face","reflexes"]

func bindings() -> Dictionary:
	var result := super.bindings()
	var assigned: Dictionary = later.bindings()
	for section in LATER: result[section] = assigned[section]
	return result

func choices(section: String) -> Array:
	return later.choices(section) if section in LATER else super.choices(section)
