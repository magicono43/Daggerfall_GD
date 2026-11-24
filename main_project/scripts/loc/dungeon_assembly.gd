extends Node
## LOC owns staged/committed geometry. CORE alone owns entry eligibility.
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")
const Geometry = preload("res://scripts/loc/dungeon_geometry.gd")
const Hash = preload("res://scripts/data/variant_resolution.gd")
const BODY_LIMIT_SETTING = "physics/jolt_physics_3d/limits/max_bodies"
var _boot_body_limit := int(ProjectSettings.get_setting(BODY_LIMIT_SETTING,0))
var layouts: RefCounted
var registry: RefCounted
var core: RefCounted
var geography: RefCounted
var variants: RefCounted
var _environment: RefCounted
var _prepared_environment: RefCounted
var _markers: RefCounted
var _prepared_markers: RefCounted
var _serial := 0
var _stage := {}
var _committed := {}
var _receipts := {}
var _live: Node3D
var _prepared := {}
var _prepared_viewport: SubViewport
var _prepared_root: Node3D
var measurements := {}

## Source-specific assembly hooks share the same lifetime and publication owner.
func _request_extra(_request: Dictionary) -> int:
	return 0

func _select_placements(input: Dictionary, _request: Dictionary) -> Dictionary:
	var selected: Array = input.data.placements.filter(func(p: Dictionary): return p.context == "dungeon")
	if selected.is_empty(): return _result("missing","No dungeon placements; never substitute a destination.")
	if not input.data.has("assembly"): return _result("unsupported","Required assembly connection declarations unavailable for this layout.")
	return {"ok":true,"placements":selected,"assembly":input.data.assembly.duplicate(true)}

func _stage_block(block: Dictionary, _p: Dictionary) -> Dictionary:
	return {"ok":true} if block.definition.format == "RDB" else _result("unsupported","Dungeon requires RDB geometry.")

func _placement_pose(p: Dictionary) -> Transform3D:
	return Frame.placement(p)

func _records(block: Dictionary, _p: Dictionary) -> Array:
	return block.definition.records

func _record_pose(record: Dictionary, _block: Dictionary, _p: Dictionary, _resource: Dictionary = {}) -> Transform3D:
	return Frame.pose(record.transform)

func _geometry_record(record: Dictionary) -> bool:
	return record.type == "model"

func _binding_identity(p: Dictionary, record: Dictionary) -> Dictionary:
	return {"layout":_stage.input.identity.duplicate(true),"placement":p.id,"record":record.id}

func _after_record(_binding: Dictionary, _resource: Dictionary, _p: Dictionary) -> Dictionary:
	return {"ok":true}

func _after_block(_block: Dictionary, _p: Dictionary, _placed: Node3D) -> Dictionary:
	return {"ok":true}

func _candidate_extension(_candidate: Dictionary) -> void:
	pass

func _current(request: Dictionary) -> bool:
	return _content_current(request) and core != null and core.layout_request_current(request.get("session",""),request.get("core_ticket",{}))

func _content_current(request: Dictionary) -> bool:
	return registry != null and registry.content_ticket() == request.get("content_ticket",-2) and layouts != null and layouts.classic != null and layouts.classic.ready()

func _purge_obsolete_preparation() -> void:
	if not _stage.is_empty() and not _content_current(_stage.ticket.request): _discard("stale")
	if not _prepared.is_empty() and (not _content_current(_prepared.ticket.request) or not core.layout_operation_owns(_prepared.ticket.request.core_ticket)): _drop_prepared()

func _result(kind: String, reason := "") -> Dictionary:
	return {"ok":kind == "assembled","kind":kind,"reason":reason,"assembly_ready":false,"geometry_ready":false,"collision_ready":false,"destination_ready":false,"owner_state_ready":false,"placement_committed":false,"save_compatible":false}

func begin(request: Dictionary) -> Dictionary:
	_purge_obsolete_preparation()
	if not _stage.is_empty(): return _result("busy")
	if request.size() != 7+int(request.has("presentation"))+int(request.has("variants"))+int(request.has("arrival"))+_request_extra(request) or not request.get("id") is String or request.id.is_empty() or not request.get("requester") is String or request.requester.is_empty() or not request.get("layout") is String or not request.get("preparation") is String or request.preparation.is_empty() or not request.get("session") is String or not request.get("core_ticket") is Dictionary or not request.get("content_ticket") is int: return _result("invalid","Complete original requester/session/content/preparation identity required.")
	if request.has("arrival"):
		var arrival: Variant = request.arrival
		if not arrival is Dictionary or arrival.size() != 3 or not preload("res://scripts/mod/package_library.gd").valid_id(arrival.get("route")) or arrival.get("kind") not in ["general","doorway","opening"] or not arrival.get("doorway") is String or (arrival.kind == "doorway" and not preload("res://scripts/mod/package_library.gd").valid_id(arrival.doorway)) or (arrival.kind != "doorway" and not arrival.doorway.is_empty()): return _result("invalid_route_intent","Explicit original route/kind/doorway intent required.")
	if not _current(request): return _result("stale")
	if _boot_body_limit < 1: return _result("physics_unavailable","The qualified Jolt body-capacity setting is unavailable.")
	var key := Hash.digest([request.requester,request.id])
	if _receipts.has(key):
		if _receipts[key].request != request: return _result("invalid","Request identity reused with different input.")
		if _committed.get("ticket") == _receipts[key].result.ticket: return projection(_committed.ticket)
		if _prepared.get("ticket") == _receipts[key].result.ticket: return projection(_prepared.ticket)
		return {"ok":true,"kind":"retained","assembly_ready":false,"geometry_ready":false,"destination_ready":false,"reason":"Completed request was superseded; retained outcome is not current geometry."}
	if not _prepared.is_empty(): return _result("busy","A checked CORE preparation awaits activation or cancellation.")
	var started := Time.get_ticks_usec()
	var input: Dictionary = layouts.location_inputs(registry,request.layout)
	if not input.ok: return input
	var variant: Dictionary = _variant_input(request,input)
	if not variant.ok: return variant
	if variant.has("layout_inputs"): input = variant.layout_inputs
	if request.has("arrival") and not input.data.has("arrivals"): return _result("missing_route","Selected layout has no arrival declarations.")
	var selection := _select_placements(input,request)
	if not selection.ok: return selection
	var placements: Array = selection.placements
	var palette := {}
	var environment: RefCounted
	if input.data.has("context"):
		if geography == null: return _result("provider_unavailable","Destination climate provider unavailable.")
		var location_parts: PackedStringArray = input.data.location.split("#")
		var site: Dictionary = geography.lookup(registry,location_parts[0],location_parts[1])
		if not site.ok: return site
		var position: Array = site.record.value.data.position
		var climate: Dictionary = geography.sample(registry,position[0],position[1])
		if not climate.ok: return climate
		var configuration: Variant = request.get("presentation",{"variation":false,"version":"dungeon-presentation-v1"})
		if not configuration is Dictionary: return _result("invalid_configuration","Explicit presentation configuration required.")
		palette = preload("res://scripts/loc/dungeon_palette.gd").resolve(input.data.context,site.record.identity,climate.climate,configuration)
		if not palette.ok: return palette
		environment = preload("res://scripts/loc/dungeon_environment.gd").new()
		var prepared: Dictionary = environment.prepare(input.data.context)
		if not prepared.ok: return prepared
		if input.data.context.has("classic_environment"):
			var expected: Dictionary = input.data.context.classic_environment
			if expected.size() != placements.size() or not placements.all(func(p: Dictionary): return expected.has(p.id)): return _result("incompatible_environment","Classic environmental annotations must match the complete effective placement scope.")
	elif request.has("presentation"):
		return _result("unsupported_context","Selected layout has no qualified palette/environment declarations.")
	_serial += 1
	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	viewport.size = Vector2i(16,16)
	add_child(viewport)
	var root := Node3D.new()
	root.name = "DungeonAssembly"
	viewport.add_child(root)
	var ticket := {"serial":_serial,"request":request.duplicate(true)}
	_stage = {"ticket":ticket,"input":input,"placements":placements,"next":0,"viewport":viewport,"root":root,"cache":{},"blocks":{},"bindings":{},"occurrences":[],"doors":{},"suppressed":{},"triangles":0,"started":started,"resource_decodes":0,"assembly":selection.assembly,"finishing":false}
	_stage.support = preload("res://scripts/loc/dungeon_support.gd").new()
	_stage.block_versions = {}
	_stage.resource_versions = {}
	_stage.pending_action_bindings = []
	_stage.pending_unknown_action_bindings = []
	_stage.pending_action_axis_bindings = []
	_stage.geometry_instances = 0
	_stage.geometry_cache = {}
	_stage.body_nodes = {}
	_stage.body_limit = mini(_boot_body_limit,int(ProjectSettings.get_setting(BODY_LIMIT_SETTING,0)))
	_stage.palette = palette
	_stage.environment = environment
	_stage.materials = preload("res://scripts/loc/dungeon_materials.gd").new()
	_stage.materials.classic = layouts.classic
	_stage.materials.media = layouts.media
	_stage.materials.ticket = registry.content_ticket()
	_stage.material_bindings = {}
	_stage.variant = variant
	_stage.markers = null
	return {"ok":true,"kind":"staging","ticket":ticket.duplicate(true),"destination_ready":false}

func _variant_input(request: Dictionary, baseline: Dictionary) -> Dictionary:
	if variants == null: return _result("provider_unavailable","Variant DATA provider unavailable.") if request.has("variants") else {"ok":true}
	var choices: Dictionary = variants.assembly_choices(registry,baseline)
	if not choices.ok: return choices
	if not choices.needed and not request.has("variants"): return {"ok":true}
	var selections: Variant = request.get("variants",{"layout_selection":choices.root,"selections":[],"required":[],"compatibility":[]})
	if not selections is Dictionary or selections.size() != 4 or not selections.get("layout_selection") is Dictionary or not selections.get("selections") is Array or not selections.get("required") is Array or not selections.get("compatibility") is Array: return _result("invalid","Complete explicit variant selection intent required.")
	var query: Dictionary = selections.duplicate(true)
	query.schema = "variant-query-v1"
	query.owner = request.requester
	query.content_context = choices.context
	query.layout = baseline.identity
	var proposal: Dictionary = variants.assembly_inputs(registry,query)
	if not proposal.ok: return proposal
	var effective: Dictionary = proposal.layout_inputs
	var old_placements := {}
	var new_placements := {}
	for p: Dictionary in baseline.data.placements: old_placements[p.id] = p
	for p: Dictionary in effective.data.placements: new_placements[p.id] = p
	if Hash.digest(old_placements) != Hash.digest(new_placements) or Hash.digest(baseline.data.get("assembly")) != Hash.digest(effective.data.get("assembly")) or Hash.digest(baseline.data.get("arrivals")) != Hash.digest(effective.data.get("arrivals")): return _variant_pending(proposal,"Changed structural layout/arrival meaning needs its real geometry/owner compatibility gates; LOC-010 grants no migration.")
	for receipt: Dictionary in proposal.compatibility:
		if receipt.scope.scope != "location-layout" or not receipt.changed_payloads.is_empty(): return _variant_pending(proposal,"Changed block/record meaning requires the named IMP-055 and gameplay owner integrations.")
	return proposal

func _variant_pending(proposal: Dictionary, reason: String) -> Dictionary:
	var result := _result("provider_pending",reason)
	result.compatibility_receipts = proposal.compatibility.duplicate(true)
	result.variant_proposals = proposal.proposals.duplicate(true)
	return result

func _valid(ticket: Dictionary) -> bool:
	return not _stage.is_empty() and ticket == _stage.ticket and _current(ticket.request)

func cancel(ticket: Dictionary) -> Dictionary:
	if not _prepared.is_empty() and ticket == _prepared.ticket:
		_drop_prepared()
		return _result("cancelled")
	if _stage.is_empty() or ticket != _stage.ticket: return _result("stale")
	return _discard("cancelled")

func _discard(kind: String, reason := "", referring: Variant = null, provider_failure: Dictionary = {}) -> Dictionary:
	var result := _result(kind,reason)
	result.referring = referring
	if not _stage.is_empty():
		result.ticket = _stage.ticket.duplicate(true)
		result.staged_blocks = _stage.next
		result.physics_bodies = _stage.get("body_nodes",{}).size()
		result.physics_body_limit = _stage.get("body_limit",0)
		result.provider_failure = provider_failure.duplicate(true)
		Geometry.release(_stage.viewport)
		_stage.clear()
	return result

static func record_key(placement: String, record: String) -> String:
	return placement+"/"+record

static func environment_radius(context: Dictionary, placement: String, origin: Vector3) -> float:
	var radius := Frame.MAX_SUPPORT_DEPTH*sqrt(3.0)
	for volume: Dictionary in context.water+context.areas:
		if volume.source.get("placement") != placement: continue
		for x in 2:
			for y in 2:
				for z in 2: radius = maxf(radius,origin.distance_to(Vector3(volume.bounds[x][0],volume.bounds[y][1],volume.bounds[z][2])))
	return radius

static func environment_pose_matches(actual: Transform3D, expected: Transform3D, radius: float) -> bool:
	if actual.origin.distance_to(expected.origin) > Frame.POSITION_TOLERANCE: return false
	var tolerance := Frame.POSITION_TOLERANCE/(4.0*radius)
	return actual.basis.x.distance_to(expected.basis.x) <= tolerance and actual.basis.y.distance_to(expected.basis.y) <= tolerance and actual.basis.z.distance_to(expected.basis.z) <= tolerance

func step(ticket: Dictionary) -> Dictionary:
	if not _valid(ticket):
		if not _stage.is_empty() and ticket == _stage.ticket: return _discard("stale")
		return _result("stale")
	if _stage.next >= _stage.placements.size(): return {"ok":true,"kind":"staged"}
	var p: Dictionary = _stage.placements[_stage.next]
	if not _stage.blocks.has(p.block):
		_stage.blocks[p.block] = _stage.variant.blocks[p.id] if _stage.variant.get("blocks",{}).has(p.id) else layouts.decode_block(registry,p.block)
		if _stage.blocks[p.block].ok: _stage.block_versions[p.block] = Hash.digest(_stage.blocks[p.block].definition)
	var block: Dictionary = _stage.blocks[p.block]
	if not block.ok: return _discard(block.get("kind","failed"),block.get("reason","Required block failed."),p.id,block)
	var checked_block := _stage_block(block,p)
	if not checked_block.ok: return _discard(checked_block.get("kind","unsupported"),checked_block.get("reason","Required block failed."),p.id,checked_block)
	var expected_environment: Dictionary = _stage.input.data.get("context",{}).get("classic_environment",{})
	if expected_environment.has(p.id):
		var observed: Dictionary = block.definition.get("environment_observation",{})
		var expected: Dictionary = expected_environment[p.id]
		var context: Dictionary = _stage.input.data.context
		var placement_transform := Frame.placement(p)
		var radius := environment_radius(context,p.id,placement_transform.origin)
		if not observed.get("ok",false) or p.block != expected.block or not environment_pose_matches(placement_transform,Frame.pose(expected.transform),radius) or observed.get("source_input",{}).get("payload_sha256") != expected.sha256 or observed.native_height != expected.native_height or observed.castle != expected.castle: return _discard("incompatible_environment","Classic environmental annotation no longer matches the effective block/placement input.",p.id,observed)
		if observed.water_present:
			if (placement_transform.basis*Vector3.UP).distance_to(Vector3.UP) > Frame.POSITION_TOLERANCE/(4.0*radius): return _discard("unsupported_environment","Tilted classic water needs an explicit native volume interpretation.",p.id,observed)
			var surface := (placement_transform*Vector3(0,-float(observed.native_height)*Frame.CLASSIC_METRES,0)).y
			if not context.water.any(func(volume: Dictionary): return volume.source.get("placement") == p.id and volume.source.get("block") == block.identity.record and volume.source.get("sha256") == expected.sha256 and observed.markers.any(func(marker: Dictionary): return marker.record == volume.source.get("marker")) and absf(float(volume.surface)-surface) <= Frame.POSITION_TOLERANCE): return _discard("missing_environment","Required classic water has no source-matched checked extent.",p.id,observed)
		for role: String in observed.get("special_roles",[]):
			if not context.areas.any(func(area: Dictionary): return area.source.get("placement") == p.id and area.source.get("block") == block.identity.record and area.source.get("sha256") == expected.sha256 and area.source.get("classic_role") == role): return _discard("missing_environment","Required classic special area has no source-matched explicit scope.",p.id,observed)
	var placed := Node3D.new()
	placed.transform = _placement_pose(p)
	_stage.root.add_child(placed)
	var fixed_body: StaticBody3D
	var protected_targets := {}
	for record: Dictionary in _records(block,p):
		if record.get("action",{}).get("kind",0) != 0 and not record.action.target.is_empty(): protected_targets[record.action.target] = true
	var scoped: Array = []
	for record: Dictionary in _records(block,p):
		var key := record_key(p.id,record.id)
		var binding := {"identity":_binding_identity(p,record),"definition":block.identity.duplicate(true),"record":record.duplicate(true),"transform":placed.transform * _record_pose(record,block,p),"instance":"loc-transient:%d:%d:%s" % [get_instance_id(),_serial,key]}
		if record.has("unused_action"):
			_stage.pending_unknown_action_bindings.append({"identity":binding.identity.duplicate(true),"metadata":record.unused_action.duplicate(true)})
		if record.has("action_axis_metadata"):
			_stage.pending_action_axis_bindings.append({"identity":binding.identity.duplicate(true),"metadata":record.action_axis_metadata.duplicate(true)})
		binding.state_slot = {"identity":binding.identity.duplicate(true),"owner_state_ready":false}
		if not Frame.bounded(binding.transform.origin): return _discard("unsupported_geometry","Local geometry precision extent exceeded.",binding.identity)
		if record.has("action") and not record.action.target.is_empty(): binding.action_target = record_key(p.id,record.action.target)
		if record.get("action",{}).get("kind",0) != 0: _stage.pending_action_bindings.append(binding.identity.duplicate(true))
		if _geometry_record(record):
			var resource_key := Hash.digest(record.get("resource",{"model_id":record.get("model_id"),"door_model_index":record.get("door_model_index")}))
			if not _stage.cache.has(resource_key):
				var resource_request := record.duplicate(true)
				resource_request.definition_identity = block.identity.duplicate(true)
				resource_request.content_context = block.content_context.duplicate(true)
				var resource: Dictionary = layouts.classic_resource(resource_request)
				if not resource.ok: return _discard(resource.get("kind","failed"),resource.get("reason","Required geometry unavailable."),binding.identity,resource)
				_stage.cache[resource_key] = resource
				_stage.resource_decodes += 1
			if not _stage.palette.is_empty() and not _stage.material_bindings.has(resource_key):
				var selected: Dictionary = _stage.materials.bindings(_stage.cache[resource_key],_stage.palette.material_slots)
				if not selected.ok: return _discard(selected.get("kind","required_asset_failed"),selected.get("reason","Required material failed."),binding.identity,selected)
				_stage.material_bindings[resource_key] = selected
			var geometry := Geometry.model(_stage.cache[resource_key],_stage.geometry_cache.get(resource_key,{}),_stage.material_bindings.get(resource_key,{}))
			if not geometry.ok: return _discard(geometry.kind,geometry.reason,binding.identity)
			_stage.geometry_cache[resource_key] = geometry.prototype
			_stage.resource_versions[resource_key] = {"sha256":geometry.provenance.sha256,"converter":geometry.provenance.get("converter",""),"profile":geometry.provenance.get("profile","")}
			binding.geometry_provenance = geometry.provenance.duplicate(true)
			geometry.node.transform = _record_pose(record,block,p,_stage.cache[resource_key])
			binding.transform = placed.transform * geometry.node.transform
			geometry.collision.set_meta("scoped_record",key)
			var separate_body: bool = record.get("door_metadata",{}).get("candidate",false) or record.has("action") or record.has("unused_action") or protected_targets.has(record.id)
			if separate_body or fixed_body == null:
				if _stage.body_nodes.size() >= _stage.body_limit:
					Geometry.release(geometry.node)
					return _discard("physics_capacity","Required collision exceeds the configured Jolt body capacity.",binding.identity)
			if separate_body:
				_stage.body_nodes[geometry.body.get_instance_id()] = geometry.body
			else:
				if fixed_body == null:
					fixed_body = StaticBody3D.new()
					_stage.body_nodes[fixed_body.get_instance_id()] = fixed_body
					placed.add_child(fixed_body)
				# One fixed compound body per occurrence, with independently scoped
				# shape owners. Doors/action targets keep their own physical bodies.
				geometry.body.remove_child(geometry.collision)
				geometry.node.remove_child(geometry.body)
				geometry.body.free()
				geometry.collision.transform = geometry.node.transform
				fixed_body.add_child(geometry.collision)
				geometry.body = fixed_body
			placed.add_child(geometry.node)
			binding.node = geometry.node
			binding.body = geometry.body
			var world_bounds := AABB(binding.transform * geometry.points[0],Vector3.ZERO)
			var points := PackedVector3Array()
			for point: Vector3 in geometry.points:
				var world_point: Vector3 = binding.transform * point
				points.append(world_point)
				world_bounds = world_bounds.expand(world_point)
			if not record.get("door_metadata",{}).get("candidate",false):
				for at in range(0,points.size(),3): _stage.support.add(points[at],points[at+1],points[at+2])
			binding.bounds = world_bounds
			binding.geometry_probe = {"normal":(binding.transform.basis * geometry.normal_probe).normalized(),"triangle":points.slice(0,3),"material_instances":geometry.material_instances}
			binding.geometry_probe.immutable_shape = geometry.prototype.shape.get_instance_id()
			if not Frame.bounded(binding.bounds.position) or not Frame.bounded(binding.bounds.end): return _discard("unsupported_geometry","Transformed model exceeds local precision extent.",binding.identity)
			_stage.triangles += geometry.triangles
			_stage.geometry_instances += 1
			if record.get("door_metadata",{}).get("candidate",false): _stage.doors[key] = true
			var extra := _after_record(binding,_stage.cache[resource_key],p)
			if not extra.ok: return _discard(extra.get("kind","failed"),extra.get("reason","Required record metadata failed."),binding.identity,extra)
		_stage.bindings[key] = binding
		scoped.append(key)
	_stage.occurrences.append({"placement":p.duplicate(true),"definition":block.identity.duplicate(true),"transform":placed.transform,"records":scoped})
	var extra_block := _after_block(block,p,placed)
	if not extra_block.ok: return _discard(extra_block.get("kind","failed"),extra_block.get("reason","Required block geometry failed."),p.id,extra_block)
	_stage.next += 1
	return {"ok":true,"kind":"staged" if _stage.next == _stage.placements.size() else "staging","blocks":_stage.next,"destination_ready":false}

static func _hit_record(body: CollisionObject3D, shape_index: int) -> String:
	var owner_id := body.shape_find_owner(shape_index)
	var shape_owner: Object = body.shape_owner_get_owner(owner_id)
	return str(shape_owner.get_meta("scoped_record","")) if shape_owner != null else ""

func _doors() -> Dictionary:
	var relations := {}
	for relation: Dictionary in _stage.assembly.door_relationships:
		var a: String = relation.a
		var b: String = relation.b
		if not _stage.doors.has(a) or not _stage.doors.has(b) or a == b: return _result("invalid","Door relationship names absent or identical doors.")
		var pair := [a,b]
		pair.sort()
		var key: String = JSON.stringify(pair)
		if relations.has(key): return _result("invalid","Conflicting door relationship.")
		relations[key] = true
		if relation.kind == "duplicate":
			var retained: String = relation.retained
			if retained not in pair: return _result("invalid","Explicit retained door required.")
			var removed: String = b if retained == a else a
			if _stage.suppressed.has(retained) or _stage.suppressed.has(removed): return _result("invalid","Chained duplicate relations unsupported.")
			if removed in _stage.suppressed.values(): return _result("invalid","Previously retained door cannot be suppressed.")
			if _stage.bindings[removed].record.has("action") and _stage.bindings[removed].record.action.kind != 0: return _result("provider_pending","Suppressed action-bearing door needs its real owner compatibility check.")
			if _stage.bindings[removed].record.has("unused_action"): return _result("provider_pending","Suppressed unknown-action door retains a pending owner compatibility gate.")
			for binding: Dictionary in _stage.bindings.values():
				if binding.get("action_target","") == removed and binding.record.get("action",{}).get("kind",0) != 0: return _result("provider_pending","Suppressed door is a required action target; real owner compatibility required.")
			for required: Dictionary in _stage.assembly.required_bindings:
				if required.record == removed: return _result("provider_pending","Suppressed door has required owner references; no automatic remapping.")
			_stage.suppressed[removed] = retained
			_stage.bindings[removed].body.collision_layer = 0
			_stage.bindings[removed].node.visible = false
	for a: String in _stage.doors:
		for b: String in _stage.doors:
			if a >= b: continue
			if _stage.bindings[a].bounds.intersects(_stage.bindings[b].bounds) and not relations.has(JSON.stringify([a,b])): return _result("door_conflict","Overlapping candidate doors require an explicit relationship.")
	return {"ok":true}

func _endpoint(value: Dictionary, native: bool) -> Dictionary:
	for occurrence: Dictionary in _stage.occurrences:
		if occurrence.placement.id != value.placement: continue
		var path := PackedVector3Array()
		for position: Array in value.path:
			var converted: Vector3 = occurrence.transform * (Frame.vector(position) if native else Frame.point(position))
			if not Frame.bounded(converted): return _result("unsupported_connection","Connector exceeds local precision extent.")
			path.append(converted)
		return {"ok":true,"path":path,"normal":(occurrence.transform.basis * (Frame.vector(value.normal).normalized() if native else Frame.normal(value.normal))).normalized()}
	return _result("missing","Required connector placement absent.")

func _connection(connection: Dictionary) -> Dictionary:
	var native: bool = connection.get("frame","") == Frame.FRAME
	var a := _endpoint(connection.a,native)
	var b := _endpoint(connection.b,native)
	if not a.ok: return a
	if not b.ok: return b
	if a.path[-1].distance_to(b.path[-1]) > Frame.POSITION_TOLERANCE or a.normal.dot(b.normal) > -0.9999: return _result("broken_connection","Connector seam pose/normal mismatch.")
	var exclude: Array[RID] = []
	for key: String in connection.conditions:
		if not _stage.bindings.has(key) or _stage.suppressed.has(key): return _result("missing","Traversal condition must name a retained record.")
		if not _stage.doors.has(key): return _result("unsupported_connection","The v1 traversal-condition profile supports retained doors only; mechanism execution is unavailable.")
		exclude.append(_stage.bindings[key].body.get_rid())
	var path: PackedVector3Array = a.path.duplicate()
	var tail: PackedVector3Array = b.path.duplicate()
	tail.reverse()
	path.append_array(tail.slice(1))
	var space: PhysicsDirectSpaceState3D = _stage.viewport.find_world_3d().direct_space_state
	var support_depth: float = float(connection.support_depth) * (1.0 if native else Frame.CLASSIC_METRES)
	for i in range(path.size()-1):
		if not _stage.support.covers(path[i],path[i+1],support_depth): return _result("unsupported_connection","Required segment lacks continuous triangle support at %s." % path[i])
	var size := Frame.vector(connection.clearance) * (1.0 if native else Frame.CLASSIC_METRES)
	# Subdivide support probes as well as sweeping clearance. Endpoint-only floor
	# rays would accept a hole between supported ends.
	var sampled := PackedVector3Array()
	for i in range(path.size()-1):
		var count := maxi(1,ceili(path[i].distance_to(path[i+1]) / minf(0.1,minf(size.x,size.z)/2.0)))
		if sampled.size()+count > 4096: return _result("unsupported_connection","Connection exceeds the v1 4096 support-probe profile.")
		for part in count: sampled.append(path[i].lerp(path[i+1],float(part)/count))
	sampled.append(path[-1])
	path = sampled
	var shape := BoxShape3D.new()
	shape.size = size
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.margin = 0.0001
	query.exclude = exclude
	for i in path.size():
		# Explicit authored geometric envelope, not an actor/capsule/motor test.
		query.transform = Transform3D(Basis.IDENTITY,path[i]+Vector3.UP*(size.y/2.0+Frame.POSITION_TOLERANCE))
		if not Frame.bounded(query.transform.origin-size/2.0) or not Frame.bounded(query.transform.origin+size/2.0): return _result("unsupported_connection","Clearance envelope exceeds local precision extent.")
		query.motion = Vector3.ZERO
		var overlap := space.intersect_shape(query,1)
		if not overlap.is_empty(): return _result("blocked_connection","Authored clearance at %s intersects %s." % [path[i],_hit_record(overlap[0].collider,overlap[0].shape)])
		var ray := PhysicsRayQueryParameters3D.create(path[i]+Vector3.UP*Frame.POSITION_TOLERANCE,path[i]+Vector3.DOWN*support_depth)
		ray.exclude = exclude
		if space.intersect_ray(ray).is_empty():
			# Physics rays can miss a shared triangle edge. Only the pinned 1 mm
			# numerical seam tolerance is permitted, independently of support depth.
			var edge_supported := false
			for offset in [Vector3.RIGHT,Vector3.LEFT,Vector3.BACK,Vector3.FORWARD]:
				var edge := PhysicsRayQueryParameters3D.create(ray.from+offset*Frame.POSITION_TOLERANCE,ray.to+offset*Frame.POSITION_TOLERANCE)
				edge.exclude = exclude
				if not space.intersect_ray(edge).is_empty(): edge_supported = true
			if not edge_supported: return _result("unsupported_connection","Declared path has no collision support at %s." % path[i])
		if i+1 < path.size():
			query.motion = path[i+1]-path[i]
			var fraction := space.cast_motion(query)
			if fraction[0] < 1.0:
				query.transform.origin += query.motion * fraction[1]
				query.motion = Vector3.ZERO
				var hit := space.get_rest_info(query)
				return _result("blocked_connection","Swept clearance at %s crosses collision (%s)." % [path[i],hit])
	return {"ok":true,"id":connection.id,"conditions":connection.conditions.duplicate()}

func finish(ticket: Dictionary) -> Dictionary:
	if not _valid(ticket):
		if not _stage.is_empty() and ticket == _stage.ticket: return _discard("stale")
		var completed := _view(ticket)
		if not completed.is_empty(): return completed.duplicate(true)
		return _result("stale")
	if _stage.next != _stage.placements.size(): return _result("pending","All required blocks must stage first.")
	if _stage.finishing: return _result("busy","Assembly validation already running.")
	_stage.finishing = true
	var doors := _doors()
	if not doors.ok: return _discard(doors.kind,doors.reason)
	# Physics must consume staged changes before querying its isolated world.
	await get_tree().physics_frame
	await get_tree().physics_frame
	if not _valid(ticket):
		if not _stage.is_empty() and ticket == _stage.ticket: return _discard("stale")
		return _result("stale")
	var physics_space: RID = _stage.viewport.find_world_3d().space
	for body: StaticBody3D in _stage.body_nodes.values():
		if PhysicsServer3D.body_get_space(body.get_rid()) != physics_space or PhysicsServer3D.body_get_shape_count(body.get_rid()) < 1: return _discard("physics_unavailable","A required body/shape failed physics-space registration.")
	if _stage.environment != null:
		var checked_environment: Dictionary = _stage.environment.qualify(func(from: Vector3,to: Vector3):
			var query := PhysicsRayQueryParameters3D.create(from,to)
			return {"ok":true,"found":not _stage.viewport.find_world_3d().direct_space_state.intersect_ray(query).is_empty()})
		if not checked_environment.ok: return _discard(checked_environment.get("kind","invalid_environment"),checked_environment.get("reason","Required environment failed."),null,checked_environment)
	var connections: Array = []
	for connection: Dictionary in _stage.assembly.connections:
		var checked := _connection(connection)
		if not checked.ok: return _discard(checked.kind,checked.reason,connection.id)
		connections.append(checked)
	for required: Dictionary in _stage.assembly.required_bindings:
		if not _stage.bindings.has(required.record): return _discard("missing","Required structural binding absent.",required)
		if required.owner != "LOC-structure": return _discard("provider_pending","Required gameplay binding/state needs its real owner.",required)
	if _stage.input.data.has("arrivals"):
		_stage.markers = preload("res://scripts/loc/dungeon_markers.gd").new()
		var checked_markers: Dictionary = _stage.markers.prepare(_stage.input.data.arrivals,_stage.input,_stage.bindings,_stage.blocks,func(ref_: String): return layouts.location_inputs(registry,ref_),func(ref_: String): return layouts.decode_block(registry,ref_))
		if not checked_markers.ok: return _discard(checked_markers.kind,checked_markers.reason,checked_markers.get("referring"))
		if ticket.request.has("arrival"):
			var intended: Dictionary = ticket.request.arrival
			var route: Dictionary = _stage.markers.routes.get(intended.route,{})
			if route.is_empty() or route.kind != intended.kind or route.doorway != intended.doorway: return _discard("invalid_route_intent","Original route kind/doorway does not match its effective binding.",intended)
	var bindings := {}
	for key: String in _stage.bindings:
		var binding: Dictionary = _stage.bindings[key].duplicate(true)
		binding.erase("node")
		binding.erase("body")
		bindings[key] = binding
	var candidate := {"ok":true,"kind":"assembled","schema":"dungeon-assembly-v1","ticket":ticket.duplicate(true),"layout":_stage.input.identity.duplicate(true),"layout_version":Hash.digest({"layout":_stage.input.data,"blocks":_stage.block_versions,"resources":_stage.resource_versions,"frame":Frame.FRAME}),"block_versions":_stage.block_versions.duplicate(true),"frame":Frame.FRAME,"assembly_ready":true,"geometry_ready":true,"collision_ready":true,"destination_ready":false,"owner_state_ready":false,"placement_committed":false,"save_compatible":false,"occurrences":_stage.occurrences.duplicate(true),"bindings":bindings,"connections":connections,"suppressed":_stage.suppressed.duplicate(true)}
	candidate.required_bindings = _stage.assembly.required_bindings.duplicate(true)
	candidate.pending_action_bindings = _stage.pending_action_bindings.duplicate(true)
	candidate.pending_unknown_action_bindings = _stage.pending_unknown_action_bindings.duplicate(true)
	candidate.unknown_action_owner_ready = _stage.pending_unknown_action_bindings.is_empty()
	candidate.pending_action_axis_bindings = _stage.pending_action_axis_bindings.duplicate(true)
	candidate.action_axis_owner_ready = _stage.pending_action_axis_bindings.is_empty()
	candidate.marker_ready = _stage.markers != null
	candidate.marker_version = _stage.markers.version if _stage.markers != null else ""
	candidate.pending_door_bindings = _stage.doors.keys().duplicate()
	var geometry_input: Dictionary = _stage.input.data.duplicate(true)
	geometry_input.erase("context")
	geometry_input.erase("arrivals")
	candidate.geometry_version = Hash.digest({"layout":geometry_input,"blocks":_stage.block_versions,"resources":_stage.resource_versions,"frame":Frame.FRAME})
	candidate.context_ready = _stage.environment != null
	candidate.palette = _stage.palette.duplicate(true)
	candidate.material_assets = _stage.materials.receipts()
	candidate.variant_proposals = _stage.variant.get("proposals",[]).duplicate(true)
	candidate.compatibility_receipts = _stage.variant.get("compatibility",[]).duplicate(true)
	candidate.variant_version = Hash.digest(candidate.compatibility_receipts.map(func(receipt: Dictionary): return {"variant":receipt.variant,"scope":receipt.scope,"source":receipt.source_sha256,"target":receipt.target_sha256,"mapping":receipt.mapping}))
	candidate.variant_geometry_applied = not candidate.variant_proposals.is_empty()
	candidate.structural_migration_accepted = false
	if candidate.context_ready:
		var definition: Dictionary = _stage.input.data.context
		candidate.environment_version = Hash.digest({"geometry":candidate.geometry_version,"profile":preload("res://scripts/loc/dungeon_environment.gd").PROFILE,"water":definition.water,"areas":definition.areas,"classic_environment":definition.get("classic_environment",{})})
		candidate.context_version = Hash.digest({"layout":candidate.layout_version,"definition":definition,"palette":_stage.palette.version,"assets":_stage.materials.asset_version(),"material_profile":preload("res://scripts/av/replacement_instances.gd").DUNGEON_SURFACE_PROFILE,"variant":candidate.variant_version,"environment":candidate.environment_version})
	candidate.layout_provenance = {"winner":_stage.input.winner.duplicate(true),"contributors":_stage.input.contributors.duplicate(true),"content_context":_stage.input.content_context.duplicate(true)}
	_candidate_extension(candidate)
	measurements = {"assembly_usec":Time.get_ticks_usec()-_stage.started,"blocks":_stage.next,"unique_block_decodes":_stage.blocks.size(),"unique_resource_decodes":_stage.resource_decodes,"unique_geometry_builds":_stage.geometry_cache.size(),"geometry_instances":_stage.geometry_instances,"physics_bodies":_stage.body_nodes.size(),"physics_body_limit":_stage.body_limit,"triangles":_stage.triangles}
	measurements.unique_image_resources = _stage.materials.reads
	# Move coherent geometry out of the isolated staging world in one synchronous
	# publication. No entry/simulation eligibility or gameplay event is emitted.
	if not ticket.request.core_ticket.is_empty():
		# Original preflight work survives outgoing-session retirement, but stays
		# isolated until the same CORE operation reaches destination initialization.
		_prepared = candidate
		_prepared_viewport = _stage.viewport
		_prepared_root = _stage.root
		_prepared_environment = _stage.environment
		_prepared_markers = _stage.markers
	else:
		var prior := _live
		if prior != null: remove_child(prior)
		_live = _stage.root
		_stage.viewport.remove_child(_live)
		add_child(_live)
		_stage.viewport.free()
		candidate.activation_session = ticket.request.session
		candidate.activation_version = Hash.digest([candidate.layout_version,candidate.activation_session,ticket.serial])
		_committed = candidate
		_environment = _stage.environment
		_markers = _stage.markers
		if prior != null: Geometry.release(prior)
	_stage.clear()
	var result := projection(ticket)
	var request: Dictionary = ticket.request
	_receipts[Hash.digest([request.requester,request.id])] = {"request":request.duplicate(true),"result":{"ok":true,"kind":"assembled","ticket":ticket.duplicate(true)}}
	return result

func projection(ticket: Dictionary) -> Dictionary:
	var view := _view(ticket)
	return _result("stale") if view.is_empty() else view.duplicate(true)

func _view(ticket: Dictionary) -> Dictionary:
	_purge_obsolete_preparation()
	if not _prepared.is_empty() and ticket == _prepared.ticket and _content_current(ticket.request) and core.layout_operation_owns(ticket.request.core_ticket): return _prepared
	if _committed.is_empty() or ticket != _committed.ticket or registry.content_ticket() != ticket.request.content_ticket or not layouts.classic.ready(): return {}
	var scope: String = _committed.activation_session
	if core.layout_request_current(scope,{}) or (not ticket.request.core_ticket.is_empty() and core.layout_activation_session(ticket.request.core_ticket) == scope): return _committed
	return {}

func readiness(ticket: Dictionary) -> Dictionary:
	var view := _view(ticket)
	if view.is_empty(): return _result("stale")
	return {"ok":true,"ticket":ticket.duplicate(true),"layout":view.layout.duplicate(true),"layout_version":view.layout_version,"geometry_version":view.geometry_version,"environment_version":view.get("environment_version",""),"frame":Frame.FRAME,"assembly_ready":true,"geometry_ready":true,"collision_ready":true,"context_ready":view.get("context_ready",false),"context_version":view.get("context_version",""),"destination_ready":false,"owner_state_ready":false,"placement_committed":false,"activation_version":view.get("activation_version",""),"activated":view.has("activation_session")}

func binding(ticket: Dictionary, placement: String, record: String) -> Dictionary:
	var current := readiness(ticket)
	if not current.ok: return current
	var key := record_key(placement,record)
	var view := _view(ticket)
	if not view.bindings.has(key): return _result("missing","Scoped binding absent.")
	return {"ok":true,"binding":view.bindings[key].duplicate(true)}

func marker_candidate(ticket: Dictionary, route: String, index := 0) -> Dictionary:
	var view := _view(ticket)
	if view.is_empty(): return _result("stale")
	if ticket.request.has("arrival") and route != ticket.request.arrival.route: return _result("route_mismatch","Original named/opening/general route intent cannot be retargeted.")
	var markers: RefCounted = _prepared_markers if _prepared.get("ticket") == ticket else _markers
	if markers == null: return preload("res://scripts/loc/dungeon_markers.gd").failed("missing_route","No qualified arrival declarations for this effective layout.",route)
	var selected: Dictionary = markers.candidate(route,index)
	selected.ticket = ticket.duplicate(true)
	selected.activation_session = view.get("activation_session","")
	selected.layout_version = view.layout_version
	selected.geometry_version = view.geometry_version
	selected.context_version = view.get("context_version","")
	selected.geometry_ready = view.geometry_ready
	selected.context_ready = view.get("context_ready",false)
	selected.owner_state_ready = false
	selected.unknown_action_owner_ready = view.get("unknown_action_owner_ready",false)
	selected.pending_unknown_action_count = view.get("pending_unknown_action_bindings",[]).size()
	selected.action_axis_owner_ready = view.get("action_axis_owner_ready",false)
	selected.pending_action_axis_count = view.get("pending_action_axis_bindings",[]).size()
	selected.native_restore_ready = false
	selected.route_intent_bound = ticket.request.has("arrival")
	selected.events = []
	if selected.ok:
		selected.marker.layout_version = view.layout_version
		selected.marker.marker_version = view.marker_version
	selected.handoff_id = Hash.digest({"ticket":ticket,"activation_session":selected.activation_session,"route":route,"index":index,"marker":selected.get("marker",{}),"return":selected.get("return",{})})
	return selected

func _marker_handoff_current(ticket: Dictionary, route: String, index: int, handoff_id: String) -> bool:
	return marker_candidate(ticket,route,index).get("handoff_id","") == handoff_id

## WORLD chooses the ordered index; LOC never advances to a backup itself.
## Controlled providers qualify this boundary until real WORLD/MOVE arrive.
func check_marker_candidate(ticket: Dictionary, route: String, index: int, access: Callable, placement: Callable) -> Dictionary:
	var selected := marker_candidate(ticket,route,index)
	if selected.get("kind") in ["stale","route_mismatch"]: return selected
	if not selected.get("route_intent_bound",false): return _result("route_intent_pending","Inspection preparation has no original WORLD/CORE arrival intent; placement handoff is unavailable.")
	if not access.is_valid(): return _result("access_provider_unavailable","Access must be rechecked for each authored candidate.")
	var access_result: Variant = access.call(selected.duplicate(true))
	if not _marker_handoff_current(ticket,route,index,selected.handoff_id): return _result("stale")
	if not access_result is Dictionary or not access_result.get("ok",false) or access_result.get("handoff_id") != selected.handoff_id: return _result("access_rejected","Route authorization failed, changed scope or was revoked.")
	if not selected.get("ok",false): return selected
	if not selected.context_ready:
		selected.kind = "context_pending"
		return selected
	if not placement.is_valid():
		selected.kind = "placement_provider_unavailable"
		selected.placement_validated = false
		return selected
	var checked: Variant = placement.call(selected.duplicate(true))
	if not _marker_handoff_current(ticket,route,index,selected.handoff_id): return _result("stale")
	if not checked is Dictionary or checked.get("handoff_id") != selected.handoff_id or checked.get("marker") != selected.marker or checked.get("frame") != Frame.FRAME: return _result("invalid_placement_result","MOVE result must retain exact operation/route/candidate identity and frame.")
	if checked.get("kind") not in ["exact","corrected","rejected","pending"]: return _result("invalid_placement_result","Explicit MOVE outcome required.")
	if checked.kind in ["exact","corrected"]:
		if not checked.get("position") is Vector3 or not Frame.bounded(checked.position) or not checked.get("forward") is Vector3 or not checked.forward.is_finite() or absf(checked.forward.length()-1.0) > 0.000001: return _result("invalid_placement_result","Finite MOVE actor pose and unit facing required.")
		if checked.kind == "corrected" and (not checked.get("provenance") is Dictionary or checked.provenance.is_empty()): return _result("invalid_placement_result","MOVE-owned correction provenance required.")
	var rechecked: Variant = access.call(selected.duplicate(true))
	if not _marker_handoff_current(ticket,route,index,selected.handoff_id): return _result("stale")
	if not rechecked is Dictionary or not rechecked.get("ok",false) or rechecked.get("handoff_id") != selected.handoff_id: return _result("access_rejected","Route authorization revoked or changed scope during placement.")
	selected.placement = checked.duplicate(true)
	selected.placement_validated = checked.kind in ["exact","corrected"]
	selected.kind = "placement_"+checked.kind
	# The provider alone owns active shape/support/correction validation. No actor
	# pose, WORLD state, entry effect or SAVE readiness is committed by this API.
	return selected

func geometry_ray(ticket: Dictionary, from: Vector3, to: Vector3) -> Dictionary:
	var current := readiness(ticket)
	if not current.ok: return current
	if not Frame.bounded(from) or not Frame.bounded(to): return _result("unsupported_geometry","Query outside qualified local precision extent.")
	var query := PhysicsRayQueryParameters3D.create(from,to)
	var viewport: Viewport = _prepared_viewport if _prepared.get("ticket") == ticket else get_viewport()
	var hit := viewport.find_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty(): return {"ok":true,"found":false,"ticket":ticket.duplicate(true)}
	var key := _hit_record(hit.collider,hit.shape)
	var view := _view(ticket)
	var root: Node3D = _prepared_root if _prepared.get("ticket") == ticket else _live
	if not root.is_ancestor_of(hit.collider) or not view.bindings.has(key): return _result("foreign_geometry","Query hit geometry outside this assembly.")
	return {"ok":true,"found":true,"position":hit.position,"normal":hit.normal,"record":view.bindings[key].identity.duplicate(true),"ticket":ticket.duplicate(true)}

func spatial_context(ticket: Dictionary, frame: String, position: Vector3) -> Dictionary:
	var current := readiness(ticket)
	if not current.ok: return current
	if frame != Frame.FRAME: return _result("invalid_frame","Checked local dungeon frame required.")
	var environment: RefCounted = _prepared_environment if _prepared.get("ticket") == ticket else _environment
	if environment == null: return _result("unsupported_context","No qualified environmental extents for this layout.")
	var result: Dictionary = environment.query(position,func(from: Vector3,to: Vector3): return geometry_ray(ticket,from,to))
	result.ticket = ticket.duplicate(true)
	result.context_version = _view(ticket).context_version
	result.environment_version = current.environment_version
	result.pose_authoritative = false
	result.contact_committed = false
	result.events = []
	return result

func environment_projection(ticket: Dictionary) -> Dictionary:
	var current := readiness(ticket)
	if not current.ok: return current
	var environment: RefCounted = _prepared_environment if _prepared.get("ticket") == ticket else _environment
	if environment == null: return _result("unsupported_context","No qualified environmental geometry for this layout.")
	var result: Dictionary = environment.projection()
	result.ticket = ticket.duplicate(true)
	result.frame = Frame.FRAME
	result.context_version = current.context_version
	result.environment_version = current.environment_version
	return result

func activate(ticket: Dictionary) -> Dictionary:
	if not _committed.is_empty() and ticket == _committed.ticket and not _view(ticket).is_empty(): return readiness(ticket)
	if _prepared.is_empty() or ticket != _prepared.ticket or not _current(ticket.request): return _result("stale")
	var scope: String = core.layout_activation_session(ticket.request.core_ticket)
	if scope.is_empty(): return _result("pending","CORE destination initialization has not begun.")
	var prior := _live
	if prior != null: remove_child(prior)
	_live = _prepared_root
	_prepared_viewport.remove_child(_live)
	add_child(_live)
	_prepared_viewport.free()
	_prepared_viewport = null
	_prepared_root = null
	_prepared.activation_session = scope
	_prepared.activation_version = Hash.digest([_prepared.layout_version,scope,ticket.serial])
	_committed = _prepared
	_environment = _prepared_environment
	_markers = _prepared_markers
	_prepared_markers = null
	_prepared_environment = null
	_prepared = {}
	if prior != null: Geometry.release(prior)
	return readiness(ticket)

func _drop_prepared() -> void:
	if _prepared_viewport != null: Geometry.release(_prepared_viewport)
	_prepared_viewport = null
	_prepared_root = null
	_prepared.clear()
	_prepared_environment = null
	_prepared_markers = null

func operation_terminal(result: Dictionary) -> void:
	if not _stage.is_empty() and _stage.ticket.request.core_ticket.get("id","") == result.id: _discard("cancelled")
	if not _prepared.is_empty() and _prepared.ticket.request.core_ticket.get("id","") == result.id: _drop_prepared()

func retire_scope(scope: String) -> void:
	if not _stage.is_empty() and _stage.ticket.request.session == scope and not core.layout_operation_owns(_stage.ticket.request.core_ticket): _discard("cancelled")
	if not _prepared.is_empty() and _prepared.ticket.request.session == scope and not core.layout_operation_owns(_prepared.ticket.request.core_ticket): _drop_prepared()
	if not _committed.is_empty() and _committed.activation_session == scope:
		if _live != null: Geometry.release(_live)
		_live = null
		_committed.clear()
		_environment = null
		_markers = null
		_receipts.clear()

func dispose() -> void:
	if not _stage.is_empty(): _discard("cancelled")
	_drop_prepared()
	if _live != null: Geometry.release(_live)
	_live = null
	_committed.clear()
	_environment = null
	_markers = null
	_receipts.clear()
