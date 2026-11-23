extends SceneTree
## Real AV atlas sampling/alpha boundary, with controlled project-authored pixels.
const AV = preload("res://scripts/av/replacement_instances.gd")
const Geometry = preload("res://scripts/loc/dungeon_geometry.gd")
var checks: Array = []
var samples := {}

func _initialize() -> void:
	run.call_deferred()

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if DisplayServer.get_name() == "headless" or args.size() != 1 or not args[0].is_absolute_path() or FileAccess.file_exists(args[0]):
		push_error("Real renderer and one NEW absolute report path required.")
		quit(2)
		return
	for mode in ["opaque","cutout","blend"]:
		var viewport := SubViewport.new()
		viewport.own_world_3d = true
		viewport.size = Vector2i(128,128)
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var world := WorldEnvironment.new()
		world.environment = Environment.new()
		world.environment.background_mode = Environment.BG_COLOR
		world.environment.background_color = Color.MAGENTA
		world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		world.environment.ambient_light_color = Color.WHITE
		world.environment.ambient_light_energy = 1.0
		viewport.add_child(world)
		var pixels := Image.create(2,2,false,Image.FORMAT_RGBA8)
		pixels.fill(Color.GREEN)
		pixels.set_pixel(0,0,Color(0,1,0,0))
		if mode == "blend": pixels.set_pixel(1,0,Color(0,1,0,0.5))
		# A differently sized neighbouring atlas region catches cross-region sampling.
		var neighbour := Image.create(3,2,false,Image.FORMAT_RGBA8)
		neighbour.fill(Color.RED)
		var alpha: int = {"opaque":Image.ALPHA_NONE,"cutout":Image.ALPHA_BIT,"blend":Image.ALPHA_BLEND}[mode]
		var palette := AV.dungeon_palette({"first":{"image":pixels,"source_size":Vector2i(64,64),"alpha":alpha},"neighbour":{"image":neighbour,"source_size":Vector2i(32,32),"alpha":Image.ALPHA_NONE}})
		var instance := AV.dungeon_material(palette)
		if not instance.ok:
			push_error("Required real AV material failed: "+str(instance))
			quit(2)
			return
		var arrays := PlaneMesh.new().surface_get_arrays(0)
		var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		var indices := PackedVector2Array()
		for index in uv.size():
			uv[index] *= 64.0
			indices.append(Vector2.ZERO)
		arrays[Mesh.ARRAY_TEX_UV] = uv
		arrays[Mesh.ARRAY_TEX_UV2] = indices
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		mesh.surface_set_material(0,instance.material)
		var visual := MeshInstance3D.new()
		visual.mesh = mesh
		viewport.add_child(visual)
		var camera := Camera3D.new()
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 2.0
		camera.position = Vector3(0,2,0)
		viewport.add_child(camera)
		camera.look_at(Vector3.ZERO,Vector3.BACK)
		camera.current = true
		for frame in 4: await process_frame
		await RenderingServer.frame_post_draw
		var rendered := viewport.get_texture().get_image()
		var colours: Array = []
		var counts := {"green":0,"background":0,"mixed":0,"other":0}
		for y in [32,96]:
			for x in [32,96]:
				var colour := rendered.get_pixel(x,y)
				colours.append([colour.r,colour.g,colour.b,colour.a])
				if colour.g > colour.r+0.2 and colour.g > colour.b+0.2: counts.green += 1
				elif colour.r > 0.8 and colour.b > 0.8 and colour.g < 0.15: counts.background += 1
				elif colour.r > 0.15 and colour.g > 0.15 and colour.b > 0.15: counts.mixed += 1
				else: counts.other += 1
		samples[mode] = colours
		var expected: Dictionary = {"opaque":{"green":4,"background":0,"mixed":0,"other":0},"cutout":{"green":3,"background":1,"mixed":0,"other":0},"blend":{"green":2,"background":1,"mixed":1,"other":0}}[mode]
		check("atlas raster "+mode,expected,counts)
		var capture: String = args[0].get_basename()+"-"+mode+".png"
		check("atlas capture "+mode,OK,rendered.save_png(capture) if not FileAccess.file_exists(capture) else ERR_ALREADY_EXISTS)
		if mode == "opaque":
			# Exercise actual GPU mutation: the dummy headless renderer cannot
			# implement texture.update. A sibling is made from the SAME cached atlas.
			var sibling := AV.dungeon_material(palette)
			var changed: Image = palette.image.duplicate()
			changed.fill(Color.RED)
			instance.texture.update(changed)
			for frame in 4: await process_frame
			check("atlas real GPU texture update applies",changed.get_data(),instance.texture.get_image().get_data())
			check("atlas real GPU texture update cannot leak",palette.image.get_data(),sibling.texture.get_image().get_data())
		Geometry.release(viewport)
	var passed := checks.size() == 8
	var ids := {}
	for item: Dictionary in checks:
		passed = passed and not ids.has(item.scenario) and item.expected == item.actual
		ids[item.scenario] = true
	var file := FileAccess.open(args[0],FileAccess.WRITE)
	if file == null:
		quit(2)
		return
	file.store_string(JSON.stringify({"schema":"dungeon-surface-raster-v1","count":checks.size(),"ok":passed,"checks":checks,"samples":samples,"engine":Engine.get_version_info().string,"display":DisplayServer.get_name(),"profile":AV.DUNGEON_SURFACE_PROFILE,"data_session_qualified":false},"\t"))
	file.close()
	print("Dungeon atlas raster: ",checks.size()," checks, passed=",passed)
	quit(0 if passed else 1)
