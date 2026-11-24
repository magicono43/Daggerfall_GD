extends RefCounted
## Validated immutable declarations; LOC owns effective placed resolution.
const VERSION = "dungeon-arrivals-v1"
const Paths = preload("res://scripts/mod/package_library.gd")
const Layouts = preload("res://scripts/data/layout_formats.gd")
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")
const Geography = preload("res://scripts/data/geography_inputs.gd")
const Assembly = preload("res://scripts/data/dungeon_assembly_schema.gd")

static func reason(value: Variant) -> String:
	if not value is Dictionary or value.size() != 3 or value.get("schema") != VERSION or not value.get("landings") is Array or not value.get("routes") is Array: return "Complete versioned landing/route declarations required."
	var landings := {}
	for landing in value.landings:
		if not landing is Dictionary or landing.size() != 8 or not Paths.valid_id(landing.get("id")) or landings.has(landing.id) or not Paths.valid_id(landing.get("placement")) or not Paths.valid_id(landing.get("record")) or landing.get("purpose") not in ["dungeon-start","dungeon-entrance"] or landing.get("frame") not in ["classic-block-local-v1",Frame.FRAME] or not Assembly.native_triple(landing.get("forward")) or not landing.get("provenance") is Dictionary or landing.provenance.is_empty(): return "Distinct explicit scoped landing, role, facing and provenance required."
		if absf(Frame.vector(landing.forward).length()-1.0) > 0.000001: return "Landing forward must be a finite unit vector in its declared local frame."
		var guard: Variant = landing.get("guard")
		if not guard is Dictionary or guard.size() not in [2,3] or not Geography.valid_ref(guard.get("block")) or not guard.get("transform") is Dictionary: return "Source-matched block and exact record-transform guard required."
		if guard.has("payload_sha256") and (not guard.payload_sha256 is String or guard.payload_sha256.length() != 64 or not guard.payload_sha256.is_valid_hex_number(false)): return "Explicit payload SHA-256 required."
		if guard.size() == 3 and not guard.has("payload_sha256"): return "Unknown landing guard field."
		# Uses exactly the same transform boundary as source records.
		if not (Frame.valid_native(guard.transform) if guard.transform.get("frame") == Frame.FRAME else valid_classic_pose(guard.transform)): return "Checked record transform required."
		landings[landing.id] = true
	var routes := {}
	for route in value.routes:
		if not route is Dictionary or route.size() != 7 or not Paths.valid_id(route.get("id")) or routes.has(route.id) or route.get("kind") not in ["general","doorway","opening"] or not route.get("doorway") is String or not route.get("default") is String or not route.get("backups") is Array or route.get("selection") != "authored-order" or not route.get("return") is Dictionary: return "Distinct supported route with authored default/order and return required."
		if not landings.has(route.default): return "Required default landing declaration absent."
		if route.kind == "doorway" and not Paths.valid_id(route.doorway): return "Named doorway retains its explicit identity."
		if route.kind != "doorway" and not route.doorway.is_empty(): return "Only named doorway routes carry doorway identity."
		if route.kind != "general" and not route.backups.is_empty(): return "Named/opening targets cannot have backups."
		var ids := {route.default:true}
		for backup in route.backups:
			if not backup is String or ids.has(backup) or not landings.has(backup): return "Distinct declared ordered general-route backups required."
			ids[backup] = true
		var linked: Dictionary = route["return"]
		if linked.size() != 6 or not Paths.valid_id(linked.get("id")) or not Geography.valid_ref(linked.get("location")) or not Geography.valid_ref(linked.get("layout")) or not Paths.valid_id(linked.get("placement")) or not linked.get("record") is String or (not linked.record.is_empty() and not Paths.valid_id(linked.record)) or not linked.get("provenance") is Dictionary or linked.provenance.is_empty(): return "Explicit exterior return identity/context/provenance required; empty record is an explicit pending doorway binding."
		routes[route.id] = true
	return ""

static func valid_classic_pose(value: Dictionary) -> bool:
	if value.size() != 6 or value.get("frame") != "classic-block-local-v1" or value.get("position_unit") != "classic-layout-integer" or value.get("rotation_unit") != "classic-angle-2048" or not preload("res://scripts/data/actor_input_formats.gd").equal_input(value.get("scale"),[1,1,1]): return false
	return Assembly.triple(value.get("position")) and Assembly.triple(value.get("rotation"))
