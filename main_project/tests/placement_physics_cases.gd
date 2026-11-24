extends RefCounted
## Independent metre fixtures: boxes are measured here, not derived from MOVE.
func box(root: Node3D, position: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	root.add_child(body)
	body.position = position
	return body

func run(cases: RefCounted, move: Node3D) -> void:
	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	move.add_child(viewport)
	var geometry := Node3D.new()
	viewport.add_child(geometry)
	box(geometry,Vector3(0,-0.1,0),Vector3(4,0.2,4))
	box(geometry,Vector3(1,1,0),Vector3(0.1,2,4))
	box(geometry,Vector3(0,1.6,1),Vector3(1,0.1,1))
	box(geometry,Vector3(-1,0.5,0),Vector3(0.5,1,0.5))
	var slope := box(geometry,Vector3(6,0,0),Vector3(3,0.1,3))
	slope.rotation.z = deg_to_rad(60)
	await move.get_tree().physics_frame
	await move.get_tree().physics_frame
	var space := viewport.find_world_3d().direct_space_state
	var p: Dictionary = move.baseline_policy()
	var shape := CapsuleShape3D.new()
	shape.height = 1.8
	shape.radius = 0.3
	cases.check("placement independent capsule dimensions",true,absf(shape.height-p.height) < 0.000001 and absf(shape.radius-p.radius) < 0.000001)
	cases.check("placement Jolt exact full volume",true,move._volume(space,shape,Vector3(0,0.91,0),p))
	cases.check("placement Jolt real support",true,move._support(space,shape,Vector3(0,0.91,0),p).ok)
	cases.check("placement Jolt missing ground",false,move._support(space,shape,Vector3(10,0.91,0),p).ok)
	cases.check("placement Jolt steep slope rejected","unsupported_slope",move._support(space,shape,Vector3(6,1.34,0),p).get("reason"))
	cases.check("placement Jolt wall overlap",false,move._volume(space,shape,Vector3(0.9,0.91,0),p))
	cases.check("placement Jolt low ceiling",false,move._volume(space,shape,Vector3(0,0.91,1),p))
	cases.check("placement Jolt occupied anchor",false,move._volume(space,shape,Vector3(-1,0.91,0),p))
	cases.check("placement Jolt clear correction sweep",true,move._route(space,shape,Vector3(0,0.94,0),Vector3(0,0.91,0),p))
	cases.check("placement Jolt blocked correction sweep",false,move._route(space,shape,Vector3(0,0.91,0),Vector3(1.6,0.91,0),p))
	cases.check("placement Jolt overlapping start cannot tunnel",false,move._route(space,shape,Vector3(0.9,0.91,0),Vector3(1.6,0.91,0),p))
	viewport.free()
