extends RefCounted
## Structural source units only. No effect mapping, normalization or runtime state.
const Common = preload("res://scripts/data/actor_input_formats.gd")
const FORMATS = ["spells-std-v1", "magic-def-v1"]
const PROFILES = {
	"spells-std-v1":"d8b34e983a9c646c7e145f862f3c410a046ea889b429f84740c9ff3d3ec3dd47",
	"magic-def-v1":"04ba8a529be11653e8d2bc66adaec2dfc3009f93ceec75f5c175cdeddab808ba"}

static func failure(kind: String, reason: String, source := "", record: Variant = "") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"source":source,"record":record,"schema":"item-spell-source-v1"}

static func signed_byte(value: int) -> int:
	return value - 256 if value > 127 else value

static func source_name(bytes: PackedByteArray) -> String:
	var result := ""
	for byte in bytes:
		if byte == 0: break
		result += String.chr(byte)
	return result

static func decode(format: String, bytes: PackedByteArray, source := "") -> Dictionary:
	if format not in FORMATS: return failure("unsupported", "Unknown item/spell source format.",source)
	var size := 89 if format == "spells-std-v1" else 62
	var start := 0 if format == "spells-std-v1" else 4
	if bytes.size() < start + size or bytes.size() > 16777216 or (bytes.size()-start) % size != 0:
		return failure("malformed", "Truncated or trailing item/spell source bytes.",source)
	var count := (bytes.size()-start) / size
	if start == 4 and bytes.decode_s32(0) != count: return failure("malformed", "MAGIC.DEF count does not match complete payload.",source)
	var records := {}
	for ordinal in int(count):
		var p := start + ordinal * size
		var raw := bytes.slice(p,p+size)
		var record: Dictionary
		if start == 0:
			var effects: Array = []
			for slot in 3:
				effects.append({"type":signed_byte(raw[slot*2]),"subtype":signed_byte(raw[slot*2+1]),"duration":Array(raw.slice(14+slot*3,17+slot*3)),"chance":Array(raw.slice(23+slot*3,26+slot*3)),"magnitude":Array(raw.slice(32+slot*5,37+slot*5))})
			record = {"kind":"spell_source","name":source_name(raw.slice(47,72)),"name_storage":Array(raw.slice(47,72)),"legacy_index":raw[73],"icon":raw[72],"element":raw[6],"range":raw[7],"cost":raw.decode_u16(8),"effects":effects,"unused":{"gap4":Array(raw.slice(10,14)),"gap15":Array(raw.slice(74,89))}}
		else:
			var enchantments: Array = []
			for slot in 10: enchantments.append({"type":signed_byte(raw[35+slot*2]),"parameter":signed_byte(raw[36+slot*2])})
			record = {"kind":"magic_item_source","name":source_name(raw.slice(0,32)),"name_storage":Array(raw.slice(0,32)),"type":raw[32],"group":raw[33],"group_index":raw[34],"enchantments":enchantments,"uses":raw.decode_s16(55),"value":raw.decode_s32(57),"material":raw[61]}
		# An address is a transport coordinate, never a universal definition ID.
		record["source_record"] = {"ordinal":ordinal,"offset":p,"sha256":Common.sha256(raw)}
		records[str(ordinal)] = record
	return {"ok":true,"records":records,"sha256":Common.sha256(bytes),"profile_known":Common.sha256(bytes) == PROFILES[format]}
