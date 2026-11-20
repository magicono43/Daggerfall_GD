extends RefCounted
# Daggerfall Unity: Copyright (C) 2009-2023 Daggerfall Workshop; MIT (DFU_LICENSE.txt).
# Original author Gavin Clayton. Changed: local checked GDScript API, explicit seed and ranges.
# DFU DFRandom-compatible low 32-bit recurrence: higher bits cannot affect bits 16..30.
const VERSION := "dfu-dfrandom-v1"
var _initialized := false
var _state := 0
var raw_count := 0
static func create(seed: Variant) -> RefCounted:
	if typeof(seed) != TYPE_INT or seed < 0 or seed > 0xffffffff:
		return null
	var source = load("res://scripts/rule/classic_random.gd").new()
	source._state = seed
	source._initialized = true
	return source

func raw() -> Dictionary:
	if not _initialized:
		return {"ok": false, "error": "uninitialized_source"}
	_state = (_state * 1103515245 + 12345) & 0xffffffff
	raw_count += 1
	return {"ok": true, "value": (_state >> 16) & 32767}

# Signed 32-bit endpoints, positive signed 32-bit width; matches defined C# arithmetic.
func range_value(lower: Variant, upper: Variant, inclusive: bool = false) -> Dictionary:
	if not _initialized or typeof(lower) != TYPE_INT or typeof(upper) != TYPE_INT or lower < -2147483648 or upper > 2147483647 or lower > upper:
		return {"ok": false, "error": "invalid_range"}
	var width: int = upper - lower + (1 if inclusive else 0)
	if width < 1 or width > 2147483647:
		return {"ok": false, "error": "invalid_width"}
	return {"ok": true, "value": lower + raw().value % width}


