extends RefCounted
## Controlled geometry only. No locomotion, world interaction or SAVE provider.
static func geometry(host: Node) -> Node3D:
	var world := Node3D.new()
	world.name = "ControlledViewGeometry"
	host.add_child(world)
	for index: int in 4:
		var angle := float(index) * PI/2.0
		var wall := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(6,5,0.3)
		wall.mesh = box
		wall.position = Vector3(sin(angle)*8.0,0,-cos(angle)*8.0)
		wall.rotation.y = -angle
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = [Color("b44739"),Color("3c8d69"),Color("426eb3"),Color("b49c3a")][index]
		wall.material_override = material
		world.add_child(wall)
		var label := Label3D.new()
		label.text = ["NORTH · 0°","EAST · 90°","SOUTH · 180°","WEST · 270°"][index]
		label.position = wall.position + Vector3(0,1,0) - wall.position.normalized()*0.3
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 64
		world.add_child(label)
	var floor_mesh := MeshInstance3D.new()
	var floor_box := BoxMesh.new()
	floor_box.size = Vector3(24,0.2,24)
	floor_mesh.mesh = floor_box
	floor_mesh.position.y = -2.0
	world.add_child(floor_mesh)
	return world

func run(shell: Control, _fixture: Dictionary) -> Dictionary:
	var stock: RefCounted = shell.session_shell
	shell.controller.route = "main_menu"
	stock.core.provider = preload("res://tests/controlled_session_provider.gd").new()
	stock.synchronize_startup()
	stock.request("new")
	geometry(shell)
	var readout := Label.new()
	readout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	readout.position = Vector2(36,480)
	readout.add_theme_font_size_override("font_size",16)
	shell.add_child(readout)
	shell.render()
	while shell.is_inside_tree():
		readout.text = "VIEW REVIEW · controlled geometry, no movement provider\nYaw %.2f° · Pitch %.2f° · Cursor %s\nMouse / arrows / Insert / Delete · Home center · Enter cursor · Escape menu\nPause → Settings → Controls: view preferences, Apply / Cancel / Retry" % [stock.view.facing.x,stock.view.facing.y,str(stock.view.cursor_mode)]
		await shell.get_tree().process_frame
	return {"ok":false,"reason":"Human review has no automatic PASS."}
