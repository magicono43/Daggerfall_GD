extends RefCounted
# Unsigned 64-bit arithmetic as four little-endian 16-bit limbs.
static func add(a: Array, b: Array) -> Array:
	var out := []
	var carry := 0
	for i in 4:
		var n: int = a[i] + b[i] + carry
		out.append(n & 65535)
		carry = n >> 16
	return out

static func multiply(a: Array, b: Array) -> Array:
	var out := []
	var carry := 0
	for i in 4:
		var n := carry
		for j in i + 1:
			n += a[j] * b[i - j]
		out.append(n & 65535)
		carry = n >> 16
	return out

static func shift(a: Array, bits: int) -> Array:
	var out := [0, 0, 0, 0]
	for i in 4:
		var source := i + bits / 16
		if source < 4:
			out[i] = a[source] >> (bits % 16)
			if bits % 16 != 0 and source + 1 < 4:
				out[i] |= (a[source + 1] << (16 - bits % 16)) & 65535
	return out

static func from_int(value: int) -> Array:
	return [value & 65535, (value >> 16) & 65535, (value >> 32) & 65535, (value >> 48) & 65535]

static func from_bytes(bytes: PackedByteArray, offset: int) -> Array:
	var out := []
	for i in 4:
		out.append(int(bytes[offset + i * 2]) | (int(bytes[offset + i * 2 + 1]) << 8))
	return out
