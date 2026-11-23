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
var _serial := 0
var _stage := {}
var _committed := {}
var _receipts := {}
var _live: Node3D
var _prepared := {}
var _prepared_viewport: SubViewport
var _prepared_root: Node3D
var measurements := {}

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
	if request.size() != 7 or not request.get("id") is String or request.id.is_empty() or not request.get("requester") is String or request.requester.is_empty() or not request.get("layout") is String or not request.get("preparation") is String or request.preparation.is_empty() or not request.get("session") is String or not request.get("core_ticket") is Dictionary or not request.get("content_ticket") is int: return _result("invalid","Complete original requester/session/content/preparation identity required.")
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
	var placements: Array = input.data.placements.filter(func(p: Dictionary): return p.context == "dungeon")
	if placements.is_empty(): return _result("missing","No dungeon placements; never substitute a destination.")
	if not input.data.has("assembly"): return _result("unsupported","Required assembly connection declarations unavailable for this layout.")
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
	_stage = {"ticket":ticket,"input":input,"placements":placements,"next":0,"viewport":viewport,"root":root,"cache":{},"blocks":{},"bindings":{},"occurrences":[],"doors":{},"suppressed":{},"triangles":0,"started":started,"resource_decodes":0,"assembly":input.data.assembly.duplicate(true),"finishing":false}
	_stage.support = preload("res://scripts/loc/dungeon_support.gd").new()
	_stage.block_versions = {}
	_stage.resource_versions = {}
	_stage.pending_action_bindings = []
	_stage.geometry_instances = 0
	_stage.geometry_cache = {}
	_stage.body_nodes = {}
	_stage.body_limit = mini(_boot_body_limit,int(ProjectSettings.get_setting(BODY_LIMIT_SETTING,0)))
	return {"ok":true,"kind":"staging","ticket":ticket.duplicate(true),"destination_ready":false}

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
		_stage.viewport.free()
		_stage.clear()
	return result

static func record_key(placement: String, record: String) -> String:
	return placement+"/"+record

func step(ticket: Dictionary) -> Dictionary:
	if not _valid(ticket):
		if not _stage.is_empty() and ticket == _stage.ticket: return _discard("stale")
		return _result("stale")
	if _stage.next >= _stage.placements.size(): return {"ok":true,"kind":"staged"}
	var p: Dictionary = _stage.placements[_stage.next]
	if not _stage.blocks.has(p.block):
		_stage.blocks[p.block] = layouts.decode_block(registry,p.block)
		if _stage.blocks[p.block].ok: _stage.block_versions[p.block] = Hash.digest(_stage.blocks[p.block].definition)
	var block: Dictionary = _stage.blocks[p.block]
	if not block.ok: return _discard(block.get("kind","failed"),block.get("reason","Required block failed."),p.id,block)
	if block.definition.format != "RDB": return _discard("unsupported","Dungeon requires RDB geometry.",p.id)
	var placed := Node3D.new()
	placed.transform = Frame.placement(p)
	_stage.root.add_child(placed)
	var fixed_body: StaticBody3D
	var protected_targets := {}
	for record: Dictionary in block.definition.records:
		if record.get("action",{}).get("kind",0) != 0 and not record.action.target.is_empty(): protected_targets[record.action.target] = true
	var scoped: Array = []
	for record: Dictionary in block.definition.records:
		var key := record_key(p.id,record.id)
		var binding := {"identity":{"layout":_stage.input.identity.duplicate(true),"placement":p.id,"record":record.id},"definition":block.identity.duplicate(true),"record":record.duplicate(true),"transform":placed.transform * Frame.pose(record.transform),"instance":"loc-transient:%d:%d:%s" % [get_instance_id(),_serial,key]}
		binding.state_slot = {"identity":binding.identity.duplicate(true),"owner_state_ready":false}
		if not Frame.bounded(binding.transform.origin): return _discard("unsupported_geometry","Local geometry precision extent exceeded.",binding.identity)
		if record.has("action") and not record.action.target.is_empty(): binding.action_target = record_key(p.id,record.action.target)
		if record.get("action",{}).get("kind",0) != 0: _stage.pending_action_bindings.append(binding.identity.duplicate(true))
		if record.type == "model":
			var resource_key := Hash.digest(record.get("resource",{"model_id":record.get("model_id")}))
			if not _stage.cache.has(resource_key):
				var resource_request := record.duplicate(true)
				resource_request.definition_identity = block.identity.duplicate(true)
				resource_request.content_context = block.content_context.duplicate(true)
				var resource: Dictionary = layouts.classic_resource(resource_request)
				if not resource.ok: return _discard(resource.get("kind","failed"),resource.get("reason","Required geometry unavailable."),binding.identity,resource)
				_stage.cache[resource_key] = resource
				_stage.resource_decodes += 1
			var geometry := Geometry.model(_stage.cache[resource_key],_stage.geometry_cache.get(resource_key,{}))
			if not geometry.ok: return _discard(geometry.kind,geometry.reason,binding.identity)
			_stage.geometry_cache[resource_key] = geometry.prototype
			_stage.resource_versions[resource_key] = geometry.provenance.sha256
			binding.geometry_provenance = geometry.provenance.duplicate(true)
			geometry.node.transform = Frame.pose(record.transform)
			geometry.collision.set_meta("scoped_record",key)
			var separate_body: bool = record.get("door_metadata",{}).get("candidate",false) or record.has("action") or protected_targets.has(record.id)
			if separate_body or fixed_body == null:
				if _stage.body_nodes.size() >= _stage.body_limit:
					geometry.node.free()
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
				geometry.collision.transform = Frame.pose(record.transform)
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
		_stage.bindings[key] = binding
		scoped.append(key)
	_stage.occurrences.append({"placement":p.duplicate(true),"definition":block.identity.duplicate(true),"transform":placed.transform,"records":scoped})
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
	var connections: Array = []
	for connection: Dictionary in _stage.assembly.connections:
		var checked := _connection(connection)
		if not checked.ok: return _discard(checked.kind,checked.reason,connection.id)
		connections.append(checked)
	for required: Dictionary in _stage.assembly.required_bindings:
		if not _stage.bindings.has(required.record): return _discard("missing","Required structural binding absent.",required)
		if required.owner != "LOC-structure": return _discard("provider_pending","Required gameplay binding/state needs its real owner.",required)
	var bindings := {}
	for key: String in _stage.bindings:
		var binding: Dictionary = _stage.bindings[key].duplicate(true)
		binding.erase("node")
		binding.erase("body")
		bindings[key] = binding
	var candidate := {"ok":true,"kind":"assembled","schema":"dungeon-assembly-v1","ticket":ticket.duplicate(true),"layout":_stage.input.identity.duplicate(true),"layout_version":Hash.digest({"layout":_stage.input.data,"blocks":_stage.block_versions,"resources":_stage.resource_versions,"frame":Frame.FRAME}),"block_versions":_stage.block_versions.duplicate(true),"frame":Frame.FRAME,"assembly_ready":true,"geometry_ready":true,"collision_ready":true,"destination_ready":false,"owner_state_ready":false,"placement_committed":false,"save_compatible":false,"occurrences":_stage.occurrences.duplicate(true),"bindings":bindings,"connections":connections,"suppressed":_stage.suppressed.duplicate(true)}
	candidate.required_bindings = _stage.assembly.required_bindings.duplicate(true)
	candidate.pending_action_bindings = _stage.pending_action_bindings.duplicate(true)
	candidate.pending_door_bindings = _stage.doors.keys().duplicate()
	candidate.layout_provenance = {"winner":_stage.input.winner.duplicate(true),"contributors":_stage.input.contributors.duplicate(true),"content_context":_stage.input.content_context.duplicate(true)}
	measurements = {"assembly_usec":Time.get_ticks_usec()-_stage.started,"blocks":_stage.next,"unique_block_decodes":_stage.blocks.size(),"unique_resource_decodes":_stage.resource_decodes,"unique_geometry_builds":_stage.geometry_cache.size(),"geometry_instances":_stage.geometry_instances,"physics_bodies":_stage.body_nodes.size(),"physics_body_limit":_stage.body_limit,"triangles":_stage.triangles}
	# Move coherent geometry out of the isolated staging world in one synchronous
	# publication. No entry/simulation eligibility or gameplay event is emitted.
	if not ticket.request.core_ticket.is_empty():
		# Original preflight work survives outgoing-session retirement, but stays
		# isolated until the same CORE operation reaches destination initialization.
		_prepared = candidate
		_prepared_viewport = _stage.viewport
		_prepared_root = _stage.root
	else:
		var prior := _live
		if prior != null: remove_child(prior)
		_live = _stage.root
		_stage.viewport.remove_child(_live)
		add_child(_live)
		_stage.viewport.free()
		candidate.activation_session = ticket.request.session
		_committed = candidate
		if prior != null: prior.free()
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
	return {"ok":true,"ticket":ticket.duplicate(true),"layout":view.layout.duplicate(true),"layout_version":view.layout_version,"frame":Frame.FRAME,"assembly_ready":true,"geometry_ready":true,"collision_ready":true,"destination_ready":false,"owner_state_ready":false,"placement_committed":false,"activated":view.has("activation_session")}

func binding(ticket: Dictionary, placement: String, record: String) -> Dictionary:
	var current := readiness(ticket)
	if not current.ok: return current
	var key := record_key(placement,record)
	var view := _view(ticket)
	if not view.bindings.has(key): return _result("missing","Scoped binding absent.")
	return {"ok":true,"binding":view.bindings[key].duplicate(true)}

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
	_committed = _prepared
	_prepared = {}
	if prior != null: prior.free()
	return readiness(ticket)

func _drop_prepared() -> void:
	if _prepared_viewport != null: _prepared_viewport.free()
	_prepared_viewport = null
	_prepared_root = null
	_prepared.clear()

func operation_terminal(result: Dictionary) -> void:
	if not _stage.is_empty() and _stage.ticket.request.core_ticket.get("id","") == result.id: _discard("cancelled")
	if not _prepared.is_empty() and _prepared.ticket.request.core_ticket.get("id","") == result.id: _drop_prepared()

func retire_scope(scope: String) -> void:
	if not _stage.is_empty() and _stage.ticket.request.session == scope and not core.layout_operation_owns(_stage.ticket.request.core_ticket): _discard("cancelled")
	if not _prepared.is_empty() and _prepared.ticket.request.session == scope and not core.layout_operation_owns(_prepared.ticket.request.core_ticket): _drop_prepared()
	if not _committed.is_empty() and _committed.activation_session == scope:
		if _live != null: _live.free()
		_live = null
		_committed.clear()
		_receipts.clear()

func dispose() -> void:
	if not _stage.is_empty(): _discard("cancelled")
	_drop_prepared()
	if _live != null: _live.free()
	_live = null
	_committed.clear()
	_receipts.clear()
