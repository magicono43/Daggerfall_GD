extends "res://tests/ground_course.gd"
## Isolated original corridor mesh, production DATA decoder and LOC geometry.
const Geometry = preload("res://scripts/loc/dungeon_geometry.gd")
const Connector = preload("res://scripts/data/steep_connector_policy.gd")
var model_id := 0
var rise := 0.0
var run_metres := 0.0
var ramp_node: Node3D
var ramp_collision: CollisionShape3D
var prepared := {}
var source_row := {}
var source_block := {}
var source_record := {}
var full_block := false
var spawn_sole := Vector3.ZERO
var _other_models: Array = []
var _rows: Array = []

func prepare(layouts: RefCounted, registry: RefCounted, model: int, rows: Array, source_key := "") -> bool:
	model_id = model
	var matches := rows.filter(func(row: Dictionary): return int(row.model) == model)
	if not source_key.is_empty(): matches = matches.filter(func(row: Dictionary): return row.block+"/"+row.record == source_key)
	if matches.is_empty(): return false
	source_row = matches[0]
	source_block = layouts.decode_block(registry,"packs/classic#"+source_row.block)
	if not source_block.get("ok",false): return false
	var records: Array = source_block.definition.records.filter(func(record: Dictionary): return record.id == source_row.record)
	if records.size() != 1: return false
	source_record = records[0].duplicate(true)
	var request := source_record.duplicate(true)
	request.definition_identity = source_block.identity.duplicate(true)
	request.content_context = source_block.content_context.duplicate(true)
	var resource: Dictionary = layouts.classic_resource(request)
	prepared = Geometry.model(resource)
	var matched: bool = prepared.get("ok",false) and not Connector.match_source(Connector.index(rows),source_block,source_record,prepared.prototype).is_empty()
	if not matched:
		print("CONNECTOR SOURCE MATCH FAILED ",source_block.identity," / ",source_block.definition.get("environment_observation",{}).get("source_input",{})," / ",source_record," / ",prepared.get("prototype",{}).get("provenance",{}))
		if prepared.get("ok",false): Geometry.release(prepared.node)
	if matched and full_block:
		_rows = rows.duplicate(true)
		spawn_sole = Vector3(0,0,-1)
		for record: Dictionary in source_block.definition.records:
			if record.type != "model" or record.id == source_record.id: continue
			var other_request := record.duplicate(true)
			other_request.definition_identity = source_block.identity.duplicate(true)
			other_request.content_context = source_block.content_context.duplicate(true)
			var other: Dictionary = Geometry.model(layouts.classic_resource(other_request))
			if not other.get("ok",false):
				Geometry.release(prepared.node)
				for pending: Dictionary in _other_models: Geometry.release(pending.geometry.node)
				return false
			_other_models.append({"record":record.duplicate(true),"geometry":other})
	return matched

func build() -> void:
	if not full_block:
		super.build()
	else:
		var light := DirectionalLight3D.new()
		add_child(light)
		light.rotation_degrees = Vector3(-60,-30,0)
	var prototype: Dictionary = prepared.prototype
	var vertices := PackedVector3Array()
	for i in prototype.triangle_planes.size():
		if prototype.triangle_planes[i] == int(source_row.floor_plane): vertices.append_array(prototype.points.slice(i*3,i*3+3))
	var low: Vector3 = vertices[0]
	var high: Vector3 = vertices[0]
	for point: Vector3 in vertices:
		if point.y < low.y: low = point
		if point.y > high.y: high = point
	rise = high.y-low.y
	run_metres = absf(high.z-low.z)
	ramp_node = prepared.node
	ramp_node.position = Vector3(0,-low.y,-2.0-low.z)
	add_child(ramp_node)
	ramp_collision = prepared.collision
	Connector.attach(ramp_collision,prototype,source_row,ramp_collision.global_transform)
	var highlighted := PackedVector3Array()
	for at in range(0,vertices.size(),3):
		var normal := (vertices[at+2]-vertices[at]).cross(vertices[at+1]-vertices[at]).normalized()
		for offset in 3: highlighted.append(vertices[at+offset]+normal*0.002)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = highlighted
	var floor_mesh := ArrayMesh.new()
	floor_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var floor_visual := MeshInstance3D.new()
	floor_visual.mesh = floor_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.GOLDENROD
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	floor_visual.material_override = material
	ramp_node.add_child(floor_visual) # Review highlight only; original collision unchanged.
	if full_block:
		var source_base: Transform3D = ramp_node.transform*preload("res://scripts/data/layout_geometry_frame.gd").pose(source_record.transform).affine_inverse()
		var rows := Connector.index(_rows)
		for other: Dictionary in _other_models:
			var geometry: Dictionary = other.geometry
			geometry.node.transform = source_base*preload("res://scripts/data/layout_geometry_frame.gd").pose(other.record.transform)
			add_child(geometry.node)
			Connector.attach(geometry.collision,geometry.prototype,Connector.match_source(rows,source_block,other.record,geometry.prototype),geometry.collision.global_transform)
	else:
		box(Vector3(0,rise-0.1,-2.0-run_metres-2.0),Vector3(3.2,0.2,4.0),Color.CORNFLOWER_BLUE)
	# The review HUD identifies the course. Keep 3D labels out of the corridor
	# and landing, where close text would obscure the original geometry.

func ground_surface(_ticket: Dictionary, hit: Dictionary) -> bool:
	if not collision_ready or not hit.get("collider") is CollisionObject3D: return false
	var body: CollisionObject3D = hit.collider
	if not is_ancestor_of(body): return false
	var owner: Object = body.shape_owner_get_owner(body.shape_find_owner(int(hit.get("shape",-1))))
	return owner is CollisionShape3D and Connector.permits(owner,int(hit.get("face_index",-1)),hit.get("normal",Vector3.ZERO),hit.get("position",Vector3.INF))
