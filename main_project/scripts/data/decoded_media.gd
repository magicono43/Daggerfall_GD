extends RefCounted
## DATA value object, never an engine resource, cache entry or playback cursor.
## Consumers receive detached copies including packed arrays and nested metadata.
const SCHEMA = "decoded-media-v1"
var _value: Dictionary

func _init(value: Dictionary) -> void:
	_value = value.duplicate(true)

func projection() -> Dictionary:
	return _value.duplicate(true)

func domain() -> String:
	return str(_value.get("domain", ""))

func identity() -> Dictionary:
	return _value.get("identity", {}).duplicate(true)
