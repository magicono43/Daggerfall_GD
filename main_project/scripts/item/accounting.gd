extends RefCounted
## Exact bounded arithmetic shared by physical load and monetary participation.
## Millionths of kg are the construction boundary; billionths of a kilogram support finer mods.
const MAX := 9007199254740991
static func integer(v: Variant, low := 0, high := MAX) -> bool:
	return typeof(v) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(v)) and v >= low and v <= high and v == floor(v)
static func fail(kind := "invalid_accounting") -> Dictionary:
	return {"ok":false,"kind":kind}
static func add(a: int, b: int) -> Dictionary:
	if a < 0 or b < 0 or a > MAX-b: return fail("overflow")
	return {"ok":true,"value":a+b}
static func signed_add(a: int, b: int) -> Dictionary:
	if not integer(a,-MAX) or not integer(b,-MAX) or a+b < -MAX or a+b > MAX: return fail("overflow")
	return {"ok":true,"value":a+b}
static func signature(owner: Object, method: String, arguments: int, returns: int) -> bool:
	for declaration: Dictionary in owner.get_method_list():
		if declaration.name != method: continue
		if declaration.args.size() != arguments or declaration["return"].type != returns or not declaration.default_args.is_empty() or (int(declaration.flags)&METHOD_FLAG_VARARG) != 0: return false
		return arguments == 0 or declaration.args[0].type == TYPE_DICTIONARY
	return false
static func multiply(a: int, b: int) -> Dictionary:
	if a < 0 or b < 0 or (b > 0 and a > MAX/b): return fail("overflow")
	return {"ok":true,"value":a*b}
static func round_even(numerator: int, denominator: int) -> Dictionary:
	if not integer(numerator) or not integer(denominator,1): return fail()
	var quotient: int = numerator/denominator
	var remainder: int = numerator%denominator
	# Compare without multiplying remainder and overflowing.
	if remainder > denominator-remainder or (remainder == denominator-remainder and quotient%2 != 0): quotient += 1
	return {"ok":true,"value":quotient}
static func weight(nanokg: Variant, quantum: Variant, exempt := false) -> Dictionary:
	if not integer(nanokg) or not integer(quantum,1,1000000000): return fail()
	if exempt: return {"ok":true,"value":0}
	var converted := round_even(nanokg,quantum)
	if converted.ok and nanokg > 0 and converted.value == 0: return fail("incompatible_precision")
	return converted
