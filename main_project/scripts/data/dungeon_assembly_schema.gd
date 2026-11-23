extends RefCounted
## Structural content declarations only; LOC performs geometric validation.
const Paths = preload("res://scripts/mod/package_library.gd")
const Numbers = preload("res://scripts/data/actor_input_formats.gd")
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")

static func triple(value: Variant, positive := false) -> bool:
	if not value is Array or value.size() != 3: return false
	for n in value:
		if not Numbers.integer(n,1 if positive else -2147483648,2147483647): return false
	return true

static func native_triple(value: Variant, positive := false) -> bool:
	if not value is Array or value.size() != 3: return false
	for n in value:
		if not (n is int or n is float) or not is_finite(float(n)) or (positive and n <= 0) or absf(float(n)) > Frame.MAX_LOCAL_METRES: return false
	return true

static func reason(value: Variant) -> String:
	if not value is Dictionary or value.size() != 4 or value.get("schema") != "dungeon-assembly-declarations-v1" or not value.get("connections") is Array or not value.get("door_relationships") is Array or not value.get("required_bindings") is Array: return "Complete versioned assembly declarations required."
	var ids := {}
	for link in value.connections:
		if not link is Dictionary: return "Connection declaration required."
		var frame: Variant = link.get("frame","classic-block-local-v1")
		if frame not in ["classic-block-local-v1",Frame.FRAME]: return "Unsupported connector frame."
		var native: bool = frame == Frame.FRAME
		if link.size() != 7+int(link.has("frame")) or not Paths.valid_id(link.get("id")) or ids.has(link.id) or link.get("kind") not in ["passage","stairs"] or not (native_triple(link.get("clearance"),true) if native else triple(link.get("clearance"),true)) or not link.get("conditions") is Array: return "Complete distinct supported connection/envelope required."
		var depth: Variant = link.get("support_depth")
		if native:
			if not (depth is int or depth is float) or not is_finite(float(depth)) or depth <= 0 or depth > Frame.MAX_SUPPORT_DEPTH: return "Native support depth must be positive metres within the v1 51.2 m profile."
		elif not Numbers.integer(depth,1,Frame.GRID_SIDE): return "Classic support depth must be 1..2048 source units."
		ids[link.id] = true
		for condition in link.conditions:
			if not condition is String or condition.is_empty(): return "Explicit scoped door condition required."
		for endpoint in [link.get("a"),link.get("b")]:
			if not endpoint is Dictionary or endpoint.size() != 3 or not Paths.valid_id(endpoint.get("placement")) or not (native_triple(endpoint.get("normal")) if native else triple(endpoint.get("normal"))) or not endpoint.get("path") is Array or endpoint.path.size() < 2: return "Explicit placed connector path/normal required."
			if Frame.vector(endpoint.normal).length_squared() < 0.000001: return "Connector normal cannot be zero."
			for position in endpoint.path:
				if not (native_triple(position) if native else triple(position)): return "Connector path triples must match the declared frame."
	for relation in value.door_relationships:
		if not relation is Dictionary or relation.get("kind") not in ["intentional-pair","duplicate"] or not relation.get("a") is String or not relation.get("b") is String or relation.size() != (4 if relation.kind == "duplicate" else 3): return "Explicit supported door relationship required."
		if relation.kind == "duplicate" and not relation.get("retained") is String: return "Duplicate relationship must name retained door."
	for binding in value.required_bindings:
		if not binding is Dictionary or binding.size() != 2 or not binding.get("record") is String or not binding.get("owner") is String or binding.owner.is_empty(): return "Explicit scoped required owner binding required."
	return ""
