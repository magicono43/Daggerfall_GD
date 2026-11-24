extends RefCounted

func activity_rate(input: Dictionary) -> int:
	return preload("res://scripts/rule/actor_formulas.gd").floor_ratio(input.base*input.numerator,input.denominator)
var calls := 0
var mode := "baseline"
var callback := Callable()
func damage(input: Dictionary) -> int:
	calls += 1
	if callback.is_valid(): callback.call()
	if mode == "runtime-error": JSON.parse_string("{") # Deliberate monitored native error.
	if mode == "invalid": return 1000000000000001
	var value: int = preload("res://scripts/rule/actor_formulas.gd").new().damage(input)
	input.clear() # A provider must never acquire the owner's input by reference.
	return value
func integer(input: int) -> int:
	return input
