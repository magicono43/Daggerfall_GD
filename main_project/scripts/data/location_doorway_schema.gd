extends RefCounted
## Complete, replaceable declarations; no nearest-marker selection policy.
const Common = preload("res://scripts/data/actor_input_formats.gd")

static func text(value: Variant) -> bool:
	return value is String and not value.is_empty()

static func stable_id(value: Variant) -> bool:
	return preload("res://scripts/mod/package_library.gd").valid_id(value)

static func vector(value: Variant) -> bool:
	return value is Array and value.size() == 3 and value.all(func(n: Variant): return (n is int or n is float) and is_finite(float(n)))

static func guard_reason(value: Variant, marker := false) -> String:
	if not value is Dictionary or value.size() != 3 or not value.get("transform") is Dictionary or not value.get("payload_sha256") is String: return "Exact transform, payload hash (empty for authored), and resource guard required."
	if not valid_pose(value.transform) or (not value.payload_sha256.is_empty() and value.payload_sha256.length() != 64): return "Valid exact source pose and payload SHA-256 required."
	if marker:
		if not value.get("texture") is Dictionary or value.texture.size() != 2 or not Common.integer(value.texture.get("archive"),0,511) or not Common.integer(value.texture.get("record"),0,127): return "Exact marker texture guard required."
	elif not text(value.get("model_sha256")) or value.model_sha256.length() != 64: return "Exact model SHA-256 required."
	return ""

static func valid_pose(value: Dictionary) -> bool:
	return preload("res://scripts/data/layout_geometry_frame.gd").valid_native(value) or preload("res://scripts/data/dungeon_marker_schema.gd").valid_classic_pose(value)

static func reason(value: Variant) -> String:
	if not value is Dictionary or value.size() != 3 or value.get("schema") != "location-doorways-v1" or not value.get("interiors") is Array or not value.get("links") is Array: return "Complete location-doorways-v1 declaration required."
	var interiors := {}
	for item in value.interiors:
		if not item is Dictionary or item.size() != 5: return "Complete building-scoped interior required."
		for field in ["id","placement","building"]:
			if not stable_id(item.get(field)): return "Stable interior/building/placement identity required."
		if interiors.has(item.id) or not item.get("parent") is Dictionary or not valid_pose(item.parent) or not item.get("provenance") is Dictionary or item.provenance.is_empty(): return "Distinct interior, exact parent guard and provenance required."
		interiors[item.id] = true
	var ids := {}
	var exteriors := {}
	var exits := {}
	for link in value.links:
		if not link is Dictionary or not stable_id(link.get("id")) or ids.has(link.id) or not link.get("provenance") is Dictionary or link.provenance.is_empty(): return "Distinct complete doorway link and provenance required."
		var alias: bool = link.has("entry_alias_of")
		if alias:
			if link.size() != 4 or not stable_id(link.entry_alias_of): return "Entry alias requires only id, exterior, entry_alias_of and provenance."
		elif link.size() != 7 or not interiors.has(link.get("interior")): return "Complete doorway link and declared interior required."
		ids[link.id] = link
		for side in (["exterior"] if alias else ["exterior","exit"]):
			var door: Variant = link.get(side)
			if not door is Dictionary or door.size() != 4 or not stable_id(door.get("record")) or not Common.integer(door.get("plane"),0,2147483647) or not stable_id(door.get("placement")): return "Explicit placed static-door plane required."
			var problem := guard_reason(door.get("guard"))
			if not problem.is_empty(): return problem
		var exterior := "%s/%s/%s" % [link.exterior.placement,link.exterior.record,link.exterior.plane]
		if exteriors.has(exterior): return "Ambiguous duplicate exterior; no enumeration-order selection."
		exteriors[exterior] = true
		if alias: continue
		var landing: Variant = link.get("landing")
		if not landing is Dictionary or landing.size() != 4 or not stable_id(landing.get("record")) or not vector(landing.get("forward")) or not landing.get("additional_entry") is bool: return "Explicit marker, facing and additional role declaration required."
		var problem := guard_reason(landing.get("guard"),true)
		if not problem.is_empty(): return problem
		var forward := Vector3(float(landing.forward[0]),float(landing.forward[1]),float(landing.forward[2]))
		if absf(forward.length()-1.0) > 0.000001: return "Unit engine-local interior facing required."
		if not vector(link.get("outside_offset")): return "Explicit exterior landing offset in door-normal metres required."
		var exit := "%s/%s/%s/%s" % [link.interior,link.exit.placement,link.exit.record,link.exit.plane]
		if exits.has(exit): return "Ambiguous duplicate interior exit; no enumeration-order selection."
		exits[exit] = true
	for link in value.links:
		if link.has("entry_alias_of") and (not ids.has(link.entry_alias_of) or ids[link.entry_alias_of].has("entry_alias_of")): return "Entry alias must name a canonical link directly; missing targets, chains and cycles reject."
	return ""
