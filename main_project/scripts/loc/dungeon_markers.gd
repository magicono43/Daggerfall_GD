extends RefCounted
## Preparation-private indexes. No physical placement or gameplay commitment.
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")
const Common = preload("res://scripts/data/actor_input_formats.gd")
const Schema = preload("res://scripts/data/dungeon_marker_schema.gd")
const Hash = preload("res://scripts/data/variant_resolution.gd")
var landings := {}
var routes := {}
var version := ""

static func failed(kind: String, reason: String, referring: Variant = null) -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"referring":referring,"marker_ready":false,"destination_ready":false,"placement_validated":false,"placement_committed":false,"save_compatible":false}

func prepare(definition: Dictionary, input: Dictionary, bindings: Dictionary, blocks: Dictionary, location_provider: Callable, block_provider: Callable) -> Dictionary:
	landings.clear()
	routes.clear()
	var reason := Schema.reason(definition)
	if not reason.is_empty(): return failed("invalid_markers",reason)
	for landing: Dictionary in definition.landings:
		var key: String = landing.placement+"/"+landing.record
		if not bindings.has(key):
			landings[landing.id] = failed("missing_marker","Declared placed marker absent.",landing.duplicate(true))
			continue
		var binding: Dictionary = bindings[key]
		var record: Dictionary = binding.record
		if not blocks.has(landing.guard.block): return failed("incompatible_marker","Guard names another effective block.",landing)
		var block: Dictionary = blocks[landing.guard.block]
		if binding.definition != block.identity or record.type != "flat" or record.get("marker_purpose") != landing.purpose or record.transform.frame != landing.frame or not Common.equal_input(record.transform,landing.guard.transform): return failed("incompatible_marker","Role, block, frame or source pose no longer matches.",landing)
		var source: Dictionary = block.definition.get("environment_observation",{}).get("source_input",{})
		if not source.is_empty() and (not landing.guard.has("payload_sha256") or landing.guard.payload_sha256 != source.get("payload_sha256")): return failed("incompatible_marker","Classic binding requires its exact source payload hash.",landing)
		if source.is_empty() and landing.guard.has("payload_sha256"): return failed("incompatible_marker","Classic source guard cannot qualify an authored replacement.",landing)
		var forward: Vector3 = binding.transform.basis * (Frame.normal(landing.forward) if landing.frame != Frame.FRAME else Frame.vector(landing.forward))
		landings[landing.id] = {"ok":true,"kind":"marker_anchor","marker_ready":true,"marker":{"layout":input.identity.duplicate(true),"placement":landing.placement,"record":landing.record},"landing":landing.id,"position":binding.transform.origin,"forward":forward.normalized(),"frame":Frame.FRAME,"pose_kind":"source-marker-anchor","purpose":landing.purpose,"provenance":landing.provenance.duplicate(true),"source":source.duplicate(true),"definition":binding.definition.duplicate(true),"destination_ready":false,"placement_validated":false,"placement_committed":false,"save_compatible":false}
	var return_layouts := {}
	var return_blocks := {}
	for route: Dictionary in definition.routes:
		var linked: Dictionary = route["return"]
		if linked.location != input.data.location: return failed("invalid_return","Return leaves the declared destination site.",route)
		if not return_layouts.has(linked.layout): return_layouts[linked.layout] = location_provider.call(linked.layout)
		var exterior: Dictionary = return_layouts[linked.layout]
		if not exterior.get("ok",false): return failed("missing_return","Required exterior layout context unavailable.",route)
		if exterior.data.location != linked.location: return failed("invalid_return","Return layout belongs to another site.",route)
		var placements: Array = exterior.data.placements.filter(func(p: Dictionary): return p.id == linked.placement and p.context == "exterior")
		if placements.size() != 1: return failed("missing_return","Explicit exterior placement absent or ambiguous.",route)
		var resolved_return := {"id":linked.id,"location":linked.location,"layout":exterior.identity.duplicate(true),"placement":linked.placement,"record":linked.record,"context_resolved":true,"record_resolved":false,"doorway_binding_pending":true,"geometry_ready":false,"traversal_ready":false,"geography_committed":false,"provenance":linked.provenance.duplicate(true),"layout_provenance":{"winner":exterior.winner.duplicate(true),"contributors":exterior.contributors.duplicate(true)}}
		if not linked.record.is_empty():
			var block_ref: String = placements[0].block
			if not return_blocks.has(block_ref): return_blocks[block_ref] = block_provider.call(block_ref)
			var block: Dictionary = return_blocks[block_ref]
			if not block.get("ok",false) or not block.definition.records.any(func(r: Dictionary): return r.id == linked.record and r.get("record_context","exterior") == "exterior"): return failed("missing_return","Explicit exterior record absent in its context.",route)
			resolved_return.record_resolved = true
		var candidates: Array = [route.default]+route.backups
		if route.kind != "general" and not landings[route.default].ok: return failed("missing_marker","Specific route target unavailable; no backups permitted.",route)
		if not candidates.any(func(id: String): return landings[id].ok): return failed("missing_marker","All authored general-route targets are unavailable.",route)
		routes[route.id] = {"id":route.id,"kind":route.kind,"doorway":route.doorway,"candidates":candidates,"selection":route.selection,"return":resolved_return}
	version = Hash.digest({"definition":definition,"layout":input.identity,"records":landings,"returns":routes})
	return {"ok":true,"version":version}

func candidate(route_id: String, index: int) -> Dictionary:
	if not routes.has(route_id): return failed("missing_route","No declared route; no fallback.",route_id)
	var route: Dictionary = routes[route_id]
	if index < 0 or index >= route.candidates.size(): return failed("exhausted","Authored candidates exhausted.",route_id)
	var selected: Dictionary = landings[route.candidates[index]].duplicate(true)
	selected.route = route_id
	selected.route_kind = route.kind
	selected.doorway = route.doorway
	selected.candidate_index = index
	selected.backup = index > 0
	selected["return"] = route["return"].duplicate(true)
	selected.marker_version = version
	return selected
