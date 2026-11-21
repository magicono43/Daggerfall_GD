extends RefCounted
## Bounded little-endian cursor. A failed read never advances or manufactures data.
var bytes: PackedByteArray
var position := 0
var limit := 0
var reason := ""

func _init(input: PackedByteArray, start := 0, end := -1) -> void:
	bytes = input
	limit = input.size() if end < 0 else end
	position = start
	if start < 0 or limit < start or limit > input.size():
		reason = "Invalid byte extent."

func has(count: int) -> bool:
	if not reason.is_empty():
		return false
	if count < 0 or position < 0 or position > limit or count > limit - position:
		reason = "Truncated input at byte %d (need %d, end %d)." % [position, count, limit]
		return false
	return true

func seek(offset: int) -> void:
	if offset < 0 or offset > limit:
		reason = "Offset %d outside input extent %d." % [offset, limit]
	else:
		position = offset

func u8() -> int:
	if not has(1): return 0
	var value := int(bytes[position])
	position += 1
	return value

func u16() -> int:
	if not has(2): return 0
	var value := int(bytes.decode_u16(position))
	position += 2
	return value

func s16() -> int:
	var value := u16()
	return value - 65536 if value >= 32768 else value

func u32() -> int:
	if not has(4): return 0
	var value := int(bytes.decode_u32(position))
	position += 4
	return value

func s32() -> int:
	var value := u32()
	return value - 4294967296 if value >= 2147483648 else value

func take(count: int) -> PackedByteArray:
	if not has(count): return PackedByteArray()
	var value := bytes.slice(position, position + count)
	position += count
	return value
