extends RefCounted
## Unsigned 64-bit monotonic identity, decimal arithmetic only; never RNG wrapping.
const MAXIMUM := "18446744073709551615"
var _last := {"item":"0","stack":"0"}
var _valid_seed := true

static func valid(value: Variant, zero := false) -> bool:
	if not value is String or value.is_empty() or value.length() > 20: return false
	if value == "0": return zero
	if value[0] == "0": return false
	for c in value:
		if c < "0" or c > "9": return false
	return value.length() < 20 or value <= MAXIMUM

static func successor(value: String) -> String:
	if not valid(value,true) or value == MAXIMUM: return ""
	var digits := value.to_ascii_buffer()
	for i in range(digits.size()-1,-1,-1):
		if digits[i] < 57:
			digits[i] += 1
			return digits.get_string_from_ascii()
		digits[i] = 48
	return "1"+digits.get_string_from_ascii()

func _init(high_water: Dictionary = {}) -> void:
	# Only a new branch allocator may be seeded. Live owners expose no reset API.
	for category in high_water:
		if not _last.has(category) or not valid(high_water[category],true):
			_valid_seed = false
		else: _last[category] = high_water[category]

func allocate(category: String) -> Dictionary:
	if not _valid_seed: return {"ok":false,"kind":"invalid_identity_state"}
	if not _last.has(category): return {"ok":false,"kind":"invalid_category"}
	var next := successor(_last[category])
	if next.is_empty(): return {"ok":false,"kind":"identity_exhausted"}
	_last[category] = next # Burned even if later publication fails; never released.
	return {"ok":true,"id":{"category":category,"number":next}}

func projection() -> Dictionary:
	return _last.duplicate(true)
