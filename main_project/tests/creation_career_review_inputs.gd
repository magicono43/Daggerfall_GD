extends "res://scripts/char/creation_inputs.gd"
## Explicit human-review-only composition: production race/career semantics,
## assigned later biography/portrait/allocation/reflex inputs. Never normal play.
const REAL = ["race","gender","class_method","questionnaire","class","custom"]
var later := preload("res://tests/controlled_creation_inputs.gd").new()

func bindings() -> Dictionary:
	var result := super.bindings()
	var assigned: Dictionary = later.bindings()
	for section in assigned:
		if section not in REAL: result[section] = assigned[section]
	return result

func choices(section: String) -> Array:
	return super.choices(section) if section in REAL else later.choices(section)
