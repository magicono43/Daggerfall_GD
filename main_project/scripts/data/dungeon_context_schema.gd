extends RefCounted
## DATA validates declarations; LOC checks their fit against the effective geometry.
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")
const Shapes = preload("res://scripts/data/dungeon_assembly_schema.gd")
const Numbers = preload("res://scripts/data/actor_input_formats.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const VERSION = "dungeon-context-v1"

static func palette(value: Variant) -> bool:
	if not value is Dictionary or value.size() != 6: return false
	for slot in ["119","120","122","123","124","168"]:
		if not slot_value(value.get(slot)): return false
	return true

static func slot_value(value: Variant) -> bool:
	if Numbers.integer(value,0,511): return true
	if not value is Dictionary or value.size() != 2 or not Numbers.integer(value.get("archive"),0,511) or not value.get("records") is Dictionary: return false
	for record: String in value.records:
		if not record.is_valid_int() or str(int(record)) != record or int(record) < 0 or int(record) > 127: return false
		var asset: Variant = value.records[record]
		if not asset is Dictionary or asset.size() != 3 or not asset.get("provider") is String or asset.provider.is_empty() or not Paths.valid_id(asset.get("key")) or asset.get("type") != "image": return false
	return true

static func slot_key(value: String) -> bool:
	return value.is_valid_int() and str(int(value)) == value and int(value) >= 0 and int(value) <= 511

static func bounds(value: Variant) -> bool:
	if not value is Array or value.size() != 2 or not Shapes.native_triple(value[0]) or not Shapes.native_triple(value[1]): return false
	for axis in 3:
		if value[0][axis] >= value[1][axis]: return false
	return true

static func reason(value: Variant) -> String:
	if not value is Dictionary or value.size() != 8+int(value.has("classic_environment"))+int(value.has("climate_bindings")) or value.get("schema") != VERSION or not palette(value.get("baseline")) or not value.get("fixed") is bool or not value.get("eligible") is bool or not value.get("climates") is Dictionary or not value.get("override") is Dictionary or not value.get("water") is Array or not value.get("areas") is Array: return "Complete versioned dungeon palette/environment declarations required."
	if value.has("climate_bindings"):
		if not value.climate_bindings is Dictionary: return "Explicit climate material bindings required."
		for climate: String in value.climate_bindings:
			if not preload("res://scripts/data/geography_inputs.gd").valid_ref(climate) or not value.climate_bindings[climate] is Dictionary: return "Typed climate material binding map required."
			for slot: String in value.climate_bindings[climate]:
				if not slot_key(slot) or not slot_value(value.climate_bindings[climate][slot]): return "Checked source archive slot and binding required."
	if value.has("classic_environment"):
		if not value.classic_environment is Dictionary: return "Explicit classic environmental input matches required."
		for placement: String in value.classic_environment:
			var input: Variant = value.classic_environment[placement]
			if not Paths.valid_id(placement) or not input is Dictionary or input.size() != 5 or not preload("res://scripts/data/geography_inputs.gd").valid_ref(input.get("block")) or not Frame.valid_native(input.get("transform")) or not input.get("sha256") is String or input.sha256.length() != 64 or not input.sha256.is_valid_hex_number(false) or not Numbers.integer(input.get("native_height"),-2040,10000) or not input.get("castle") is bool: return "Complete source/placement-matched classic environmental receipt required."
	for climate: String in value.climates:
		if not preload("res://scripts/data/geography_inputs.gd").valid_ref(climate) or not value.climates[climate] is Array or value.climates[climate].is_empty(): return "Explicit climate reference and nonempty palette pool required."
		for choice in value.climates[climate]:
			if not palette(choice): return "Each variation choice must supply all six slots."
	var override_: Dictionary = value.override
	for slot: String in override_:
		if not slot_key(slot) or not slot_value(override_[slot]): return "Override must name supported source archive slots and checked archive/image bindings."
	var ids := {}
	for volume in value.water:
		if not volume is Dictionary or volume.size() != 6+int(volume.has("anchor")) or not Paths.valid_id(volume.get("id")) or ids.has(volume.id) or not bounds(volume.get("bounds")) or not volume.get("pool") is String or volume.pool.is_empty() or not Numbers.integer(volume.get("priority"),-2147483648,2147483647) or not volume.get("source") is Dictionary: return "Distinct depth-enabled water bounds, pool, priority and provenance required."
		var surface: Variant = volume.get("surface")
		if not (surface is int or surface is float) or not is_finite(float(surface)) or absf(float(surface)) > Frame.MAX_LOCAL_METRES or surface <= volume.bounds[0][1]: return "Water surface must lie above the bounded bottom in the qualified frame."
		if volume.has("anchor"):
			if not Shapes.native_triple(volume.anchor): return "Water anchor requires a checked metre triple."
			for axis in 3:
				if volume.anchor[axis] <= volume.bounds[0][axis] or volume.anchor[axis] >= volume.bounds[1][axis]: return "Water anchor must be inside its volume."
			if volume.anchor[1] >= surface: return "Water anchor must be submerged."
		ids[volume.id] = true
	ids.clear()
	for area in value.areas:
		if not area is Dictionary or area.size() != 4 or not Paths.valid_id(area.get("id")) or ids.has(area.id) or not bounds(area.get("bounds")) or not area.get("uses") is Array or area.uses.is_empty() or not area.get("source") is Dictionary: return "Distinct bounded special area with explicit uses/provenance required."
		var uses := {}
		for use_ in area.uses:
			if not use_ is String or use_.is_empty() or uses.has(use_): return "Distinct declared consumer uses required."
			uses[use_] = true
		ids[area.id] = true
	return ""
