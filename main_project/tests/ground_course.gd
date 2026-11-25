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
func box(position_metres: Vector3, dimensions_metres: Vector3, color: Color, collides := true) -> void:
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
func build() -> void:
	box(Vector3(0,-0.1,0),Vector3(80,0.2,80),Color(0.2,0.3,0.25))
	box(Vector3(0,2,-20),Vector3(80,4,0.2),Color(0.5,0.2,0.1))
	for index in 10:
		box(Vector3(-3,0.01,-float(index)*2),Vector3(0.5,0.02,0.1),Color.WHITE,false)
	var light := DirectionalLight3D.new()
	add_child(light)
	light.rotation_degrees = Vector3(-60,-30,0)
