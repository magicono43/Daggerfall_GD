extends Node3D
## Measured flat course. Controlled LOC ticket/readiness, real Jolt geometry.
## No production import or ordinary gameplay entry bypass is installed.
var candidate: Dictionary = {}
var collision_ready := true
func marker_candidate(ticket: Dictionary, route: String, _index := 0) -> Dictionary:
	return candidate.duplicate(true) if collision_ready and candidate.get("ticket") == ticket and candidate.get("route") == route else {}
func readiness(_ticket: Dictionary) -> Dictionary: return {"ok":collision_ready}
func placement_space(_ticket: Dictionary) -> PhysicsDirectSpaceState3D:
	return get_world_3d().direct_space_state if collision_ready else null
func box(position_metres: Vector3, dimensions_metres: Vector3, color: Color, collides := true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = 1 if collides else 0
	var shape := BoxShape3D.new()
	shape.size = dimensions_metres
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = dimensions_metres
	mesh.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	body.add_child(mesh)
	add_child(body)
	body.position = position_metres
	return body
func ramp(position_metres: Vector3, degrees: float, length_metres := 5.0) -> StaticBody3D:
	var height := tan(deg_to_rad(degrees))*length_metres
	var points := PackedVector3Array()
	for x in [-2.0,2.0]:
		points.append(Vector3(x,-0.2,0))
		points.append(Vector3(x,0,0))
		points.append(Vector3(x,-0.2,-length_metres))
		points.append(Vector3(x,height,-length_metres))
	var shape := ConvexPolygonShape3D.new()
	shape.points = points
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	var mesh := MeshInstance3D.new()
	mesh.mesh = shape.get_debug_mesh()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.GOLDENROD
	mesh.material_override = material
	body.add_child(mesh)
	add_child(body)
	body.position = position_metres
	return body

func label_at(text: String, at: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = at
	label.font_size = 48
	label.pixel_size = 0.006
	add_child(label)

func build_surfaces() -> void:
	box(Vector3(-6,1.35,-6),Vector3(4,0.3,6),Color.ORANGE)
	label_at("CROUCH: ceiling 1.20 m",Vector3(-6,2,-2.5))
	box(Vector3(-11.76,1.45,-4),Vector3(0.1,0.2,2),Color.ORANGE)
	label_at("Off-centre overhang",Vector3(-12,2,-3))
	for index in 3:
		var height := (index+1)*0.17
		box(Vector3(6,height*0.5,-3-index),Vector3(3,height,1),Color.CORNFLOWER_BLUE)
	label_at("Stairs: 0.17 m rises",Vector3(6,2,-2))
	box(Vector3(12,0.4,-4),Vector3(3,0.8,3),Color.FIREBRICK)
	label_at("Jump/climb: 0.80 m",Vector3(12,2,-2))
	ramp(Vector3(-10,0,-11),30.0)
	label_at("30 degree slope",Vector3(-10,2,-10))
	ramp(Vector3(10,0,-11),55.0,3.0)
	label_at("55 degree slope: uphill blocked",Vector3(10,2,-10))
	for width in [0.64,0.58]:
		var z := -11.0 if width > 0.6 else -16.0
		for side in [-1,1]: box(Vector3(side*(width*0.5+0.1),1.2,z),Vector3(0.2,2.4,2),Color.DARK_GREEN)
		label_at("Passage %.2f m" % width,Vector3(0,2.8,z+1))
func build() -> void:
	box(Vector3(0,-0.1,0),Vector3(80,0.2,80),Color(0.2,0.3,0.25))
	box(Vector3(0,2,-20),Vector3(80,4,0.2),Color(0.5,0.2,0.1))
	for index in 10:
		box(Vector3(-3,0.01,-float(index)*2),Vector3(0.5,0.02,0.1),Color.WHITE,false)
	var light := DirectionalLight3D.new()
	add_child(light)
	light.rotation_degrees = Vector3(-60,-30,0)
