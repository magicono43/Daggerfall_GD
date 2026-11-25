extends RefCounted
## Explicit, replaceable DATA list. LOC alone binds it to checked collision faces.
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")

static func reason(value: Variant) -> String:
	if not value is Array or value.size() > 4096: return "Bounded connector source list required."
	var seen := {}
	for row: Variant in value:
		if not row is Dictionary or row.size() != 9: return "Complete connector source match required."
		for field in ["block","record"]:
			if not row.get(field) is String or not preload("res://scripts/mod/package_library.gd").valid_id(row[field]): return "Invalid connector source identity."
		for field in ["block_sha256","model_sha256"]:
			if not row.get(field) is String or row[field].length() != 64 or not row[field].is_valid_hex_number(false): return "Invalid connector source hash."
		for field in ["source_address","model","floor_plane"]:
			var n: Variant = row.get(field)
			if not (n is int or n is float) or not is_finite(float(n)) or n < 0 or n > 4294967295 or n != floor(n): return "Invalid connector source index."
		for field in ["position_source","rotation_source"]:
			if not row.get(field) is Array or row[field].size() != 3: return "Complete connector source pose required."
			for n: Variant in row[field]:
				if not (n is int or n is float) or not is_finite(float(n)) or absf(n) > 2147483647 or n != floor(n): return "Invalid connector source pose."
		if row.rotation_source[0] != 0 or row.rotation_source[2] != 0: return "Tilted source connectors require separate qualification."
		var key: String = row.block+"/"+row.record
		if seen.has(key): return "Duplicate connector source record."
		seen[key] = true
	return ""

static func index(rows: Array) -> Dictionary:
	var result := {}
	for row: Dictionary in rows: result[row.block+"/"+row.record] = row.duplicate(true)
	return result

static func match_source(rows: Dictionary, block: Dictionary, record: Dictionary, prototype: Dictionary) -> Dictionary:
	var identity: Dictionary = block.get("identity",{})
	var row: Dictionary = rows.get(str(identity.get("record",""))+"/"+str(record.get("id","")),{})
	if row.is_empty() or identity.get("local") != "packs/classic#"+row.block: return {}
	if record.has("action") or record.has("unused_action") or record.has("resource"): return {}
	if block.get("definition",{}).get("environment_observation",{}).get("source_input",{}).get("payload_sha256") != row.block_sha256: return {}
	if record.get("address",-1) != row.source_address or record.get("model_id",-1) != row.model: return {}
	var expected := preload("res://scripts/data/layout_formats.gd").transform(row.position_source,row.rotation_source)
	if not preload("res://scripts/data/actor_input_formats.gd").equal_input(record.get("transform",{}),expected): return {}
	if prototype.get("kind") != "classic" or prototype.get("provenance",{}).get("sha256") != row.model_sha256: return {}
	if not prototype.get("triangle_planes",PackedInt32Array()).has(int(row.floor_plane)): return {}
	return row

static func attach(collision: CollisionShape3D, prototype: Dictionary, row: Dictionary, world_pose: Transform3D) -> void:
	if row.is_empty(): return
	if world_pose.basis.y.distance_to(Vector3.UP) > 0.000001 or absf(world_pose.basis.determinant()-1.0) > 0.000001: return
	for axis in 3:
		if absf(world_pose.basis[axis].length()-1.0) > 0.000001: return
	# Only the source floor triangles receive permission. The shape is otherwise
	# unchanged; editing a shared immutable shape invalidates every attached grant.
	var floor_points := PackedVector3Array()
	for index in prototype.triangle_planes.size():
		if prototype.triangle_planes[index] == int(row.floor_plane): floor_points.append_array(prototype.points.slice(index*3,index*3+3))
	collision.set_meta("ground_connector",{"shape":collision.shape,"pose":world_pose,"planes":prototype.triangle_planes,"floor":int(row.floor_plane),"points":floor_points,"source":row.duplicate(true)})
	var weak_collision: WeakRef = weakref(collision)
	collision.shape.changed.connect(func():
		var node: Object = weak_collision.get_ref()
		if is_instance_valid(node) and node.has_meta("ground_connector"): node.remove_meta("ground_connector")
	)

static func permits(collision: CollisionShape3D, face: int, normal: Vector3, position: Vector3) -> bool:
	if collision == null or not collision.has_meta("ground_connector"): return false
	var bound: Dictionary = collision.get_meta("ground_connector")
	if collision.shape != bound.shape or collision.global_transform.origin.distance_to(bound.pose.origin) > Frame.POSITION_TOLERANCE: return false
	for axis in 3:
		if collision.global_transform.basis[axis].distance_to(bound.pose.basis[axis]) > 0.000001: return false
	if face >= 0 and (face >= bound.planes.size() or bound.planes[face] != bound.floor): return false
	# The list never changes which side is ground or makes an inverted placement
	# walkable. Actual contact normals, not the source's lighting normals, govern.
	if not position.is_finite() or not normal.is_finite() or normal.y <= 0.01 or absf(normal.length()-1.0) >= 0.001: return false
	# Jolt may omit ray face indices. Resolve only the selected, immutable source
	# triangles by local point containment plus geometric normal, never an AABB
	# or model-wide grant. This also checks an engine-provided face index.
	var local: Vector3 = bound.pose.affine_inverse()*position
	for at in range(0,bound.points.size(),3):
		var a: Vector3 = bound.points[at]
		var ab: Vector3 = bound.points[at+1]-a
		var ac: Vector3 = bound.points[at+2]-a
		var geometric := ac.cross(ab).normalized()
		if (bound.pose.basis*geometric).normalized().dot(normal) < 0.9999 or absf((local-a).dot(geometric)) > 0.001: continue
		var denominator: float = ab.dot(ab)*ac.dot(ac)-ab.dot(ac)*ab.dot(ac)
		if denominator <= 1e-12: continue
		var u: float = (ac.dot(ac)*(local-a).dot(ab)-ab.dot(ac)*(local-a).dot(ac))/denominator
		var v: float = (ab.dot(ab)*(local-a).dot(ac)-ab.dot(ac)*(local-a).dot(ab))/denominator
		if u >= 0 and v >= 0 and u+v <= 1: return true
		# A fixed metre tolerance handles float32 world contacts at the qualified
		# local extent; barycentric epsilons would grow with triangle dimensions.
		for edge: Array in [[a,a+ab],[a+ab,a+ac],[a+ac,a]]:
			var delta: Vector3 = edge[1]-edge[0]
			var closest: Vector3 = edge[0]+delta*clampf((local-edge[0]).dot(delta)/maxf(1e-20,delta.length_squared()),0,1)
			if local.distance_squared_to(closest) <= Frame.POSITION_TOLERANCE*Frame.POSITION_TOLERANCE: return true
	return false
