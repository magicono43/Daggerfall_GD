extends RefCounted
const U = preload("res://scripts/rule/unsigned64.gd")
const VERSION := "rpg-rng-v1"
const PURPOSES := ["combat", "progression", "loot", "quest"]

static func material_from_os() -> Dictionary:
	return validate_material(OS.get_entropy(32))

static func validate_material(material: Variant) -> Dictionary:
	if not material is PackedByteArray or material.size() != 32:
		return {"ok": false, "error": "initialization_material_unavailable_or_malformed"}
	return {"ok": true, "material": material.duplicate()}

static func derive(material: Variant, purpose: String) -> Dictionary:
	if not validate_material(material).ok or purpose not in PURPOSES:
		return {"ok": false, "error": "invalid_material_or_purpose"}
	var bytes := VERSION.to_ascii_buffer()
	bytes.append(0)
	bytes.append_array(material)
	bytes.append(0)
	bytes.append_array(purpose.to_ascii_buffer())
	var hash := HashingContext.new()
	if hash.start(HashingContext.HASH_SHA256) != OK or hash.update(bytes) != OK:
		return {"ok": false, "error": "hash_initialization_failed"}
	var digest := hash.finish()
	if digest.size() != 32:
		return {"ok": false, "error": "hash_failed"}
	var state := U.from_bytes(digest, 0)
	var sequence := U.from_bytes(digest, 8)
	sequence[3] &= 32767
	return {"ok": true, "initstate": state, "initseq": sequence,
		"source": preload("res://scripts/rule/pcg32.gd").create(state, sequence)}

