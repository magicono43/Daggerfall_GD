extends RefCounted
## Read-only prototypes plus independent placed nodes/materials/shape owners.
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")

static func fail(reason: String) -> Dictionary:
	return {"ok":false,"kind":"unsupported_geometry","reason":reason}

static func prepare(result: Dictionary) -> Dictionary:
	if not result.get("ok",false): return result
	var triangles := PackedVector3Array()
	var mesh: ArrayMesh
	var provenance := {}
	var kind := "classic"
	if result.has("value"):
		var data: Dictionary = result.value.projection()
		provenance = data.provenance.duplicate(true)
		if data.get("domain") != "model": return fail("Required decoded model missing.")
		mesh = ArrayMesh.new()
		for plane: Dictionary in data.planes:
			if Frame.normal(plane.normal_source).length_squared() < 0.9: return fail("Required model plane has no usable normal.")
			var vertices := PackedVector3Array()
			var normals := PackedVector3Array()
			# Frame has positive determinant. Source CCW becomes Godot clockwise.
			for at in range(0,plane.triangles.size(),3):
				for offset in [0,2,1]:
					vertices.append(Frame.model_point(data.points_source[plane.point_indices[plane.triangles[at+offset]]]))
					normals.append(Frame.normal(plane.normal_source))
			triangles.append_array(vertices)
			var arrays := []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = vertices
			arrays[Mesh.ARRAY_NORMAL] = normals
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	elif result.get("resource",{}).has("meshes"):
		kind = "replacement"
		provenance = result.provenance.duplicate(true)
		# static-glb-v1 exports already use Godot metres. Apply declared node chain.
		var data: Dictionary = result.resource
		for index: int in data.included:
			if not data.nodes[index].has("mesh"): continue
			var transform: Transform3D = data.transforms[index]
			var parent: int = data.parents.get(index,-1)
			while parent >= 0:
				transform = data.transforms[parent] * transform
				parent = data.parents.get(parent,-1)
			var source: ArrayMesh = data.meshes[int(data.nodes[index].mesh)]
			var faces := source.get_faces()
			for vertex: Vector3 in faces: triangles.append(transform * vertex)
	else: return fail("Unsupported model resource profile; no empty geometry fallback.")
	if triangles.is_empty(): return fail("Required model has no triangles.")
	for point: Vector3 in triangles:
		if not point.is_finite(): return fail("Required model contains nonfinite geometry.")
	var usable := false
	for at in range(0,triangles.size(),3):
		usable = usable or (triangles[at+1]-triangles[at]).cross(triangles[at+2]-triangles[at]).length_squared() > 0
	if not usable: return fail("Required model contains no nondegenerate geometry.")
	var shape := ConcavePolygonShape3D.new()
	shape.backface_collision = true
	shape.set_faces(triangles)
	var bounds := AABB(triangles[0],Vector3.ZERO)
	for vertex: Vector3 in triangles: bounds = bounds.expand(vertex)
	var normal_probe: Vector3 = mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL][0] if kind == "classic" else (triangles[2]-triangles[0]).cross(triangles[1]-triangles[0]).normalized()
	return {"ok":true,"kind":kind,"mesh":mesh,"shape":shape,"bounds":bounds,"points":triangles,"normal_probe":normal_probe,"provenance":provenance}

static func model(result: Dictionary, prototype: Dictionary = {}) -> Dictionary:
	var reusable := prototype if not prototype.is_empty() else prepare(result)
	if not reusable.ok: return reusable
	var root := Node3D.new()
	if reusable.kind == "replacement":
		var instance := preload("res://scripts/av/replacement_instances.gd").model(result)
		if not instance.ok:
			root.free()
			return instance
		root.add_child(instance.node)
	else:
		var visual := MeshInstance3D.new()
		visual.mesh = reusable.mesh
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.64,0.68,0.72)
		material.roughness = 1.0
		visual.material_override = material
		root.add_child(visual)
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	collision.shape = reusable.shape
	body.add_child(collision)
	root.add_child(body)
	var material_instances: Array = []
	for visual: MeshInstance3D in root.find_children("*","MeshInstance3D",true,false):
		if visual.material_override != null: material_instances.append(visual.material_override.get_instance_id())
		for surface in visual.mesh.get_surface_count():
			var material: Material = visual.get_surface_override_material(surface)
			if material != null: material_instances.append(material.get_instance_id())
	return {"ok":true,"node":root,"body":body,"collision":collision,"triangles":reusable.points.size()/3,"bounds":reusable.bounds,"points":reusable.points,"normal_probe":reusable.normal_probe,"material_instances":material_instances,"provenance":reusable.provenance.duplicate(true),"prototype":reusable}
