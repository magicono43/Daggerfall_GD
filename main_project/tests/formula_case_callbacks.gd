class_name FormulaCaseCallbacks
extends RefCounted
## Application-owned controlled methods, never loaded from a package.
var calls := 0
var reenter: Callable

func builtin(value: int) -> int:
	calls += 1
	return value * 2

func replacement_a(value: int) -> int:
	calls += 1
	return value + 100

func replacement_b(value: int) -> int:
	calls += 1
	if reenter.is_valid():
		reenter.call()
	return value + 200

func invalid(_value: int) -> int:
	calls += 1
	return 1000001

func throws(_value: int) -> int:
	calls += 1
	# Parser failure is observable even in release, where VM access checks may
	# compile out. Debug additionally aborts on the failed-result access below.
	var failed: Variant = JSON.parse_string("{")
	return failed["missing_fixture_value"]

func wrong_type(_value: String) -> int:
	return 0

func wrong_arity(_first: int, _second: int) -> int:
	return 0
