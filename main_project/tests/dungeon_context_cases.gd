extends "res://tests/dungeon_cases.gd"
const Context = preload("res://scripts/data/dungeon_context_schema.gd")
const Palette = preload("res://scripts/loc/dungeon_palette.gd")
const SpatialEnvironment = preload("res://scripts/loc/dungeon_environment.gd")
class ControlledImageFailure:
	extends RefCounted
	func export_resource(provider: String, key: String, _type: String, _ticket: int) -> Dictionary:
		return {"ok":false,"kind":"controlled_image_failure","reason":"Controlled selected-image read failure; no fallback permitted.","provider":provider,"export":key}

static func context_definition() -> Dictionary:
	var baseline := {"119":119,"120":120,"122":122,"123":123,"124":124,"168":168}
	var pools := {}
	for climate in range(223,233): pools["packs/classic#climate-%d" % climate] = [baseline.duplicate(),{"119":119,"120":123,"122":122,"123":120,"124":124,"168":168}]
	return {"schema":Context.VERSION,"baseline":baseline,"fixed":false,"eligible":true,"climates":pools,"override":{},"water":[],"areas":[],"climate_bindings":Layout.context_annotations().data.layouts["place-00032"].climate_bindings.duplicate(true)}

func publish_synthetic(mods: RefCounted) -> void:
	super.publish_synthetic(mods)
	var path: String = mods.root.path_join("Mods/assembly/layout.json")
	var contribution: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	for entry: Dictionary in contribution.entries:
		if entry.id == "scaling": entry.value.data.context = context_definition()
	for id in ["context","context-fixed","context-fixed-override","context-missing"]:
		var layout := test_layout("corridor",blank_assembly())
		layout.data.context = context_definition()
		layout.data.context.fixed = id in ["context-fixed","context-fixed-override"]
		if id == "context-fixed-override": layout.data.context.override = {"120":123}
		if id == "context-missing": layout.data.context.override = {"120":511}
		layout.data.context.water = [{"id":"pool-a","pool":"continuous","surface":2.0,"bounds":[[-2.0,-4.0,-4.0],[2.0,2.0,4.0]],"priority":0,"source":{"kind":"project-authored-fixture"}}]
		layout.data.context.areas = [{"id":"hall","bounds":[[-2.0,0.0,-4.0],[2.0,1.5,4.0]],"uses":["AV-lighting"],"source":{"kind":"project-authored-fixture"}}]
		contribution.entries.append({"id":id,"value":layout})
	var observation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/dungeon_context_observation.json"))
	for source_name in ["W0000000.RDB","S0000040.RDB","S0000161.RDB"]:
		var source: Dictionary = observation.fixture_blocks[source_name]
		var layout := Layout.value("layout",{"mode":"authored","location":"packs/classic#place-05362","placements":[{"id":"alpha","context":"dungeon","block":"packs/classic#"+source.block,"transform":source_pose()}],"assembly":blank_assembly(),"context":context_definition()})
		var definition: Dictionary = layout.data.context
		definition.fixed = source_name != "W0000000.RDB"
		definition.classic_environment = {"alpha":{"block":"packs/classic#"+source.block,"transform":native_pose(),"sha256":source.sha256,"native_height":source.native_height,"castle":source.castle}}
		if source.native_height != 10000:
			var surface: float = source.water_probe.surface
			definition.water = [{"id":"verified-source-water","pool":"source-water","surface":surface,"bounds":[[0.0,source.bounds[0][1],-51.2],[51.2,surface,0.0]],"anchor":source.water_probe.position.duplicate(),"priority":0,"source":{"placement":"alpha","block":source.block,"sha256":source.sha256,"marker":source.environment_markers[0].id,"profile":"classic-depth-columns-v1"}}]
		if source_name != "W0000000.RDB":
			var role: String = "castle" if source.castle else "treasure-room"
			definition.areas = [{"id":role,"bounds":source.bounds.duplicate(true),"uses":["AV-lighting","AV-music"],"source":{"placement":"alpha","block":source.block,"sha256":source.sha256,"classic_role":role,"coverage":"explicit-source-geometry-bounds-v1"}}]
		contribution.entries.append({"id":"source-"+source.block,"value":layout})
		if source_name == "W0000000.RDB":
			var late := layout.duplicate(true)
			var next: Dictionary = late.data.placements[0].duplicate(true)
			next.id = "beta"
			next.transform = source_pose([2048,0,0])
			late.data.placements.append(next)
			late.data.context.classic_environment.beta = {"block":"packs/classic#"+source.block,"transform":native_pose([51.2,0.0,0.0]),"sha256":"0".repeat(64),"native_height":-496,"castle":false}
			contribution.entries.append({"id":"source-late-environment","value":late})
	var ordinary: Dictionary = contribution.entries.filter(func(entry: Dictionary): return entry.id == "context")[0].value
	var png := ordinary.duplicate(true)
	png.data.context.override = {"120":{"archive":120,"records":{"3":{"provider":"assembly.test","key":"palette-slot","type":"image"}}}}
	contribution.entries.append({"id":"context-png","value":png})
	contribution.entries.append({"id":"context-default","value":ordinary.duplicate(true)})
	var moved := ordinary.duplicate(true)
	moved.data.placements[1].transform.position[2] += 64
	contribution.entries.append({"id":"context-moved","value":moved})
	var bridge_record := model_record("bridge",0)
	bridge_record.erase("model_id")
	bridge_record.resource = {"provider":"assembly.test","key":"bridge","type":"model"}
	contribution.entries.append({"id":"bridge-block","value":block([bridge_record])})
	var bridge := Layout.value("layout",{"mode":"authored","location":"packs/classic#place-00016","placements":[{"id":"alpha","context":"dungeon","block":"packs/assembly.test#bridge-block","transform":source_pose()}],"assembly":blank_assembly(),"context":context_definition()})
	bridge.data.context.water = [{"id":"pool","pool":"bridge-pool","surface":1.0,"bounds":[[-2.0,-2.0,-1.0],[2.0,1.0,1.0]],"priority":0,"source":{"kind":"controlled-native-geometry"}}]
	bridge.data.context.areas = [{"id":"lower-room","bounds":[[-2.0,-2.0,-1.0],[2.0,0.0,1.0]],"uses":["AV-lighting"],"source":{"kind":"controlled-native-geometry"}},{"id":"bridge-deck","bounds":[[-0.5,2.0,-1.0],[0.5,3.0,1.0]],"uses":["AV-music"],"source":{"kind":"controlled-native-geometry"}}]
	contribution.entries.append({"id":"context-bridge","value":bridge})
	var image := Image.create_from_data(2,2,false,Image.FORMAT_RGBA8,png_pixels())
	binary_file(mods.root.path_join("Mods/assembly/palette.png"),image.save_png_to_buffer())
	binary_file(mods.root.path_join("Mods/assembly/bridge.glb"),preload("res://tests/dungeon_fixture_geometry.gd").bridge_and_lower_room())
	var media_path: String = mods.root.path_join("Mods/assembly/media.json")
	var media_contribution: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(media_path))
	media_contribution.entries.append_array([{"id":"palette-slot","value":{"schema":"media-declarations-v1","kind":"export","type":"image","file":"palette.png","profile":"png-v1"}},{"id":"bridge","value":{"schema":"media-declarations-v1","kind":"export","type":"model","file":"bridge.glb","profile":"static-glb-v1"}}])
	write(media_path,JSON.stringify(media_contribution))
	var target := {"scope":"location-layout","location":ordinary.data.location,"layout":"packs/assembly.test#context-default"}
	write(mods.root.path_join("Mods/assembly/variants.json"),JSON.stringify({"domain":"world.variants","path":"packs/assembly.test","operation":"add","entries":[{"id":"palette-selection","value":{"schema":"variant-inputs-v1","kind":"variant","target":target,"alternate":"packs/assembly.test#context-fixed-override","mapping":{}}},{"id":"structural-selection","value":{"schema":"variant-inputs-v1","kind":"variant","target":target,"alternate":"packs/assembly.test#context-moved","mapping":{}}},{"id":"palette-default","value":{"schema":"variant-inputs-v1","kind":"default","target":target,"choice":{"intent":"variant","variant":"packs/assembly.test#palette-selection"}}}]}))
	var manifest_path: String = mods.root.path_join("Mods/assembly/mod.json")
	var pack: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	pack.content.append("variants.json")
	write(manifest_path,JSON.stringify(pack))
	write(path,JSON.stringify(contribution))
	mods.rescan()

static func png_pixels() -> PackedByteArray:
	return PackedByteArray([18,52,86,255,120,154,188,255,32,64,128,0,192,128,64,255])

func binary_file(path: String, bytes: PackedByteArray) -> void:
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()

static func native_pose(position: Array = [0.0,0.0,0.0]) -> Dictionary:
	return {"frame":Frame.FRAME,"position_unit":"metre","rotation_unit":"radian","position":position.duplicate(),"rotation":[0.0,0.0,0.0],"scale":[1,1,1]}

func synthetic_checks(owner: Node, fixture: Dictionary) -> void:
	await super.synthetic_checks(owner,fixture)
	var definition := context_definition()
	check("context complete schema","",Context.reason(definition))
	var site := {"domain":"geography.inputs","package":"@shipped/geography-inputs-v1","local":"packs/classic#place-00032","record":"place-00032"}
	var configuration := {"variation":true,"version":"fixture-v1"}
	var first := Palette.resolve(definition,site,"packs/classic#climate-224",configuration)
	check("context variation resolves",true,first.ok)
	var random := preload("res://scripts/rule/classic_random.gd").create(42)
	for index in 113: random.raw()
	Palette.resolve(definition,site,"packs/classic#climate-229",configuration)
	check("context visit and unrelated RNG stability",first,Palette.resolve(definition,site,"packs/classic#climate-224",configuration))
	check("context does not consume gameplay source",113,random.raw_count)
	definition.fixed = true
	check("context fixed baseline respects variation",definition.baseline,Palette.resolve(definition,site,"packs/classic#climate-224",configuration).slots)
	definition.override = {"120":123}
	var overridden := Palette.resolve(definition,site,"packs/classic#climate-224",configuration)
	check("context deliberate fixed override",123,overridden.slots["120"])
	check("context partial override inherits",124,overridden.slots["124"])
	check("context destination desert binding",74,overridden.material_slots["74"])
	check("context destination woodland binding",374,Palette.resolve(definition,site,"packs/classic#climate-231",configuration).material_slots["74"])
	check("context destination swamp binding",474,Palette.resolve(definition,site,"packs/classic#climate-228",configuration).material_slots["74"])
	var whole := definition.duplicate(true)
	whole.override = {"119":19,"120":20,"122":22,"123":23,"124":24,"168":68}
	check("context complete palette override",whole.override,Palette.resolve(whole,site,"packs/classic#climate-224",configuration).slots)
	definition.override["120"] = -1
	check("context invalid selected override rejects",false,Palette.resolve(definition,site,"packs/classic#climate-224",configuration).ok)
	var request_ := request(owner,"packs/assembly.test#context")
	var result: Dictionary = await assemble(owner,request_)
	check("context production assembly",true,result.ok)
	if not result.ok:
		observations.context_failure = result
		return
	check("context production is checked spatial only",true,result.context_ready and not result.destination_ready)
	var observation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/dungeon_context_observation.json"))
	var visuals := owner.find_children("*","MeshInstance3D",true,false)
	for name: String in observation.sources: check("context source edition "+name,observation.sources[name],FileAccess.get_sha256(str(fixture.classic_source).path_join(name)))
	var first_visual: MeshInstance3D = visuals[0]
	var second_visual: MeshInstance3D = visuals[1]
	var source_keys: Array = []
	for plane: Dictionary in observation.planes:
		var key := "%d/%d" % [plane.archive,plane.record]
		if not source_keys.has(key): source_keys.append(key)
	check("context source material batch count",1,first_visual.mesh.get_surface_count())
	for surface in observation.planes.size():
		var plane: Dictionary = observation.planes[surface]
		var group: int = source_keys.find("%d/%d" % [plane.archive,plane.record])
		var arrays: Array = first_visual.mesh.surface_get_arrays(0)
		var uv_valid := true
		for corner in 3:
			var raw: Array = plane.source_points[corner]
			var position := Vector3(raw[0],-raw[1],-raw[2])*(0.025/256.0)
			var found := false
			for vertex in arrays[Mesh.ARRAY_VERTEX].size():
				if arrays[Mesh.ARRAY_VERTEX][vertex].distance_to(position) < 0.000001:
					var uv := Vector2(plane.uv_sixteenths[corner][0],plane.uv_sixteenths[corner][1])/16.0
					found = found or (arrays[Mesh.ARRAY_TEX_UV][vertex].distance_to(uv) < 0.000001 and int(arrays[Mesh.ARRAY_TEX_UV2][vertex].x) == group)
			uv_valid = uv_valid and found
		check("context independent UV correspondence %02d" % surface,true,uv_valid)
		var material: ShaderMaterial = first_visual.get_surface_override_material(0)
		var key := "%d/%d" % [plane.archive,plane.record]
		var expected: Dictionary = observation.textures[key]
		check("context independent source pixels %02d" % surface,expected.rgba_sha256,Layout.Common.sha256(bound_image(material,group).get_data()))
		check("context original source UV scale %02d" % surface,true,material.get_shader_parameter("source_sizes")[group].distance_to(Vector2(expected.size[0],expected.size[1])) < 0.000001)
	var first_material: ShaderMaterial = first_visual.get_surface_override_material(0)
	var second_material: ShaderMaterial = second_visual.get_surface_override_material(0)
	check("context independent mutable materials",true,first_material != second_material)
	check("context independent mutable textures",true,first_material.get_shader_parameter("albedo_texture") != second_material.get_shader_parameter("albedo_texture"))
	var original_pixels: Image = first_material.get_shader_parameter("albedo_texture").get_image()
	var changed_pixels: Image = original_pixels.duplicate()
	changed_pixels.fill(Color.RED)
	# Replacing this mutable instance binding works in both the real renderer and
	# Godot's dummy headless renderer (which does not implement GPU texture update).
	first_material.set_shader_parameter("albedo_texture",ImageTexture.create_from_image(changed_pixels))
	check("context material mutation changes owned texture",true,Layout.Common.sha256(bound_image(first_material,0).get_data()) != observation.textures["120/3"].rgba_sha256)
	check("context material mutation cannot leak instances",observation.textures["120/3"].rgba_sha256,Layout.Common.sha256(bound_image(second_material,0).get_data()))
	first_material.set_shader_parameter("albedo_texture",ImageTexture.create_from_image(original_pixels))
	var baseline_pixels := PackedByteArray()
	if DisplayServer.get_name() != "headless": baseline_pixels = await capture_palette(owner,fixture,"baseline")
	var query: Dictionary = owner.spatial_context(result.ticket,Frame.FRAME,Vector3(0,1,0))
	check("context production bounded water",true,query.ok and not query.water_absent)
	check("context production declared area uses",["AV-lighting"],query.areas[0].uses.duplicate() if not query.get("areas",[]).is_empty() else [])
	check("context production does not claim committed pose",false,query.pose_authoritative)
	check("context production emits no entry",[],query.events)
	var across: Dictionary = owner.spatial_context(result.ticket,Frame.FRAME,Vector3(0,1,-3.5))
	check("context native pool spans actual placements",true,across.ok and across.water.pool == query.water.pool)
	check("context native area spans actual placements",true,across.ok and across.areas.size() == 1 and across.areas[0].id == query.areas[0].id)
	check("context native area excludes stacked floor",true,owner.spatial_context(result.ticket,Frame.FRAME,Vector3(0,1.75,0)).areas_absent)
	var below: Dictionary = owner.spatial_context(result.ticket,Frame.FRAME,Vector3(0,-1,0))
	check("context intervening dry floor excludes immersion",true,below.ok and below.water_absent)
	var outside: Dictionary = owner.spatial_context(result.ticket,Frame.FRAME,Vector3(20,1,0))
	check("context explicit absence",true,outside.ok and outside.water_absent and outside.areas_absent)
	check("context wrong frame rejects","invalid_frame",owner.spatial_context(result.ticket,"source",Vector3.ZERO).kind)
	query.areas[0].uses.append("LAW-immunity")
	check("context point projection is detached",["AV-lighting"],owner.spatial_context(result.ticket,Frame.FRAME,Vector3(0,1,0)).areas[0].uses)
	var environmental_geometry: Dictionary = owner.environment_projection(result.ticket)
	check("context checked geometry is supplied to consumers",true,environmental_geometry.ok and environmental_geometry.frame == Frame.FRAME and environmental_geometry.water.size() == 1)
	environmental_geometry.water[0].bounds[0][0] = -999.0
	check("context environmental geometry projection is detached",-2.0,owner.environment_projection(result.ticket).water[0].bounds[0][0])
	var missing: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#context-missing"))
	check("context missing required image fails",false,missing.ok)
	check("context late image failure preserves committed context",true,owner.spatial_context(result.ticket,Frame.FRAME,Vector3(0,1,0)).ok)
	var staged: Dictionary = owner.begin(request(owner,"packs/assembly.test#context"))
	check("context staged cancellation","cancelled",owner.cancel(staged.ticket).kind)
	check("context cancellation preserves committed context",true,owner.spatial_context(result.ticket,Frame.FRAME,Vector3(0,1,0)).ok)
	var fixed_request := request(owner,"packs/assembly.test#context-fixed-override")
	fixed_request.presentation = configuration
	var fixed: Dictionary = await assemble(owner,fixed_request)
	check("context fixed override reaches production",true,fixed.ok and fixed.palette.slots["120"] == 123)
	if fixed.ok:
		check("context palette preserves geometry bounds",result.bindings["alpha/floor"].bounds,fixed.bindings["alpha/floor"].bounds)
		check("context palette preserves geometry version",result.geometry_version,fixed.geometry_version)
		check("context palette preserves environmental version",result.environment_version,fixed.environment_version)
		var override_visual: MeshInstance3D = owner.find_children("*","MeshInstance3D",true,false)[0]
		var override_material: ShaderMaterial = override_visual.get_surface_override_material(0)
		check("context substitution binds requested source record",observation.textures["123/3"].rgba_sha256,Layout.Common.sha256(bound_image(override_material,0).get_data()))
		if DisplayServer.get_name() != "headless":
			var override_pixels: PackedByteArray = await capture_palette(owner,fixture,"slot-override")
			check("context rendered palette substitution changes pixels",true,not baseline_pixels.is_empty() and baseline_pixels != override_pixels)
	check("context old assembly query retires","stale",owner.spatial_context(result.ticket,Frame.FRAME,Vector3.ZERO).kind)
	var variation_request := request(owner,"packs/assembly.test#context")
	variation_request.presentation = configuration
	var variation: Dictionary = await assemble(owner,variation_request)
	check("context opt-in variation reaches production",true,variation.ok and variation.palette.selection == "variation")
	check("context variation uses declared destination identity","packs/classic#place-00016",variation.palette.site.local)
	write(str(fixture.sandbox).path_join("context-restart-expectations.json"),JSON.stringify({"palette_version":fixed.palette.version,"context_version":fixed.context_version,"ordinary_version":variation.palette.version,"ordinary_slots":variation.palette.slots,"configuration":configuration,"native_save_qualified":false}))
	observations.context_materials = owner.measurements.duplicate(true)
	var observed := Layout.F.environment([{"id":"environment-only","type":"flat","texture":{"archive":199,"record":10},"sound_index":12,"magnitude":1}])
	check("context classic height independent of arrival",true,observed.ok and observed.native_height == -96 and not observed.arrival_selected)
	check("context classic castle metadata",true,observed.castle)
	check("context classic observation is not extent qualification",false,observed.extents_ready)
	var dry := Layout.F.environment([{"id":"dry","type":"flat","texture":{"archive":199,"record":10},"sound_index":0,"magnitude":0}])
	check("context classic absence sentinel",true,dry.ok and not dry.water_present and dry.native_height == 10000)
	var environment := SpatialEnvironment.new()
	var wet := context_definition()
	var a := {"id":"a","pool":"continuous","surface":2.0,"bounds":[[-2.0,-2.0,-2.0],[0.0,2.0,2.0]],"priority":0,"source":{"kind":"controlled-spatial-definition"}}
	var b := a.duplicate(true)
	b.id = "b"
	b.bounds = [[0.0,-2.0,-2.0],[2.0,2.0,2.0]]
	wet.water = [a,b]
	check("context connected native volumes prepare",true,environment.prepare(wet).ok)
	var clear := func(_from: Vector3,_to: Vector3): return {"ok":true,"found":false}
	check("context connected native volumes qualify",true,environment.qualify(clear).ok)
	check("context cross-volume pool continuity",environment.query(Vector3(-0.1,1,0),clear).water.pool,environment.query(Vector3(0.1,1,0),clear).water.pool)
	check("context seam emits no events",[],environment.query(Vector3(0,1,0),clear).events)
	var offset_a := a.duplicate(true)
	var offset_b := b.duplicate(true)
	offset_a.bounds = [[-4.0,-2.0,-1.0],[0.0,2.0,1.0]]
	offset_b.bounds = [[0.0,-2.0,0.5],[4.0,2.0,4.5]]
	var offset_definition := wet.duplicate(true)
	offset_definition.water = [offset_a,offset_b]
	var inside_witness := func(from: Vector3,to: Vector3):
		for index in range(1,100):
			var point := from.lerp(to,index/100.0)
			if not SpatialEnvironment.contains(SpatialEnvironment.box(offset_a.bounds).grow(0.00001),point) and not SpatialEnvironment.contains(SpatialEnvironment.box(offset_b.bounds).grow(0.00001),point): return {"ok":true,"found":true}
		return {"ok":true,"found":false}
	environment.prepare(offset_definition)
	check("context offset pool witnesses stay inside declared liquid",true,environment.qualify(inside_witness).ok)
	b.bounds = [[4.0,-2.0,-2.0],[6.0,2.0,2.0]]
	environment.prepare(wet)
	check("context disconnected same pool rejects","disconnected_environment",environment.qualify(clear).kind)
	b.pool = "separate"
	environment.prepare(wet)
	environment.qualify(clear)
	check("context equal height pools remain distinct",true,environment.query(Vector3(-1,1,0),clear).water.pool != environment.query(Vector3(5,1,0),clear).water.pool)
	b.bounds = a.bounds.duplicate(true)
	check("context unresolved overlap rejects","ambiguous_environment",environment.prepare(wet).kind)
	b.priority = 1
	b.surface = 1.5
	check("context explicit overlap rule prepares",true,environment.prepare(wet).ok)
	environment.qualify(clear)
	check("context explicit overlap rule applies",1.5,environment.query(Vector3(-1,1,0),clear).water.surface)
	var cap := a.duplicate(true)
	cap.id = "submerged-cell"
	cap.bounds = [[0.0,-2.0,-2.0],[2.0,0.5,2.0]]
	wet.water = [a,cap]
	check("context bounded submerged cell prepares",true,environment.prepare(wet).ok)
	check("context submerged cell connects to free surface",true,environment.qualify(clear).ok)
	check("context submerged cell retains authored surface",2.0,environment.query(Vector3(1,0,0),clear).water.surface)
	cap.bounds = [[0.0,-2.0,-2.0],[2.0,2.0,2.0]]
	a.bounds[0][1] = -4.0
	cap.bounds[0][1] = -4.0
	var divider := func(from: Vector3,to: Vector3): return {"ok":true,"found":minf(from.x,to.x) <= 0 and maxf(from.x,to.x) >= 0 and from.x != to.x and minf(from.y,to.y) >= 0}
	environment.prepare(wet)
	check("context submerged witness cannot bypass divider below floor","disconnected_environment",environment.qualify(divider).kind)
	var broad := a.duplicate(true)
	broad.bounds = [[-2.0,-2.0,-2.0],[2.0,2.0,2.0]]
	broad.anchor = [-1.0,1.9,0.0]
	wet.water = [broad]
	environment.prepare(wet)
	environment.qualify(divider)
	check("context unreachable broad extent is explicit failure","unsupported_environment",environment.query(Vector3(1,1,0),divider).kind)
	var latest_ticket: Dictionary = await asset_variant_checks(owner,fixture,variation.ticket)
	for source_name in ["W0000000.RDB","S0000040.RDB","S0000161.RDB"]:
		var source: Dictionary = observation.fixture_blocks[source_name]
		var prepared: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#source-"+source.block))
		check("context real source preparation "+source_name,true,prepared.ok)
		if not prepared.ok:
			observations["source_failure_"+source_name] = prepared
			continue
		latest_ticket = prepared.ticket
		var decoded: Dictionary = owner.layouts.decode_block(owner.registry,"packs/classic#"+source.block)
		check("context real source metadata "+source_name,true,decoded.ok and decoded.definition.environment_observation.ok)
		check("context real source shape count "+source_name,source.model_sha256.size(),owner.measurements.unique_geometry_builds)
		if source_name == "W0000000.RDB":
			var position := Frame.vector(source.water_probe.position)
			var spatial: Dictionary = owner.spatial_context(prepared.ticket,Frame.FRAME,position)
			check("context real water source height",-496,decoded.definition.environment_observation.native_height)
			check("context real water converted height",12.4,spatial.water.get("surface",-1.0))
			var floor_hit: Dictionary = owner.geometry_ray(prepared.ticket,position,position+Vector3.DOWN)
			check("context independent real water floor",true,floor_hit.ok and floor_hit.found and floor_hit.record.record == source.water_probe.floor_triangle.record)
			check("context real water excludes below-floor space",true,owner.spatial_context(prepared.ticket,Frame.FRAME,position+Vector3.DOWN).water_absent)
			var query_started := Time.get_ticks_usec()
			var queries_ok := true
			for index in 1000:
				var repeated: Dictionary = owner.spatial_context(prepared.ticket,Frame.FRAME,position)
				queries_ok = queries_ok and repeated.ok and not repeated.water_absent
			observations.real_water_queries = {"count":1000,"usec":Time.get_ticks_usec()-query_started}
			check("context real water narrow repeated queries",true,queries_ok)
		else:
			var centre := (Frame.vector(source.bounds[0])+Frame.vector(source.bounds[1]))/2.0
			var spatial: Dictionary = owner.spatial_context(prepared.ticket,Frame.FRAME,centre)
			check("context real bounded area "+source_name,true,spatial.ok and spatial.areas.size() == 1)
			check("context real area vertical absence "+source_name,true,owner.spatial_context(prepared.ticket,Frame.FRAME,centre+Vector3.UP*100).areas_absent)
			check("context real area does not commit owner outcomes "+source_name,[],spatial.events)
			if source_name == "S0000161.RDB":
				var flooded: Dictionary = owner.spatial_context(prepared.ticket,Frame.FRAME,Frame.vector(source.water_probe.position))
				check("context treasure room retains independent water metadata",7.2,flooded.water.get("surface",-1.0) if flooded.ok else -1.0)
				check("context treasure environment does not select arrival",false,decoded.definition.environment_observation.arrival_selected)
	var previous: Dictionary = owner.readiness(latest_ticket)
	var late: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#source-late-environment"))
	check("context late source environment mismatch rejects","incompatible_environment",late.kind)
	check("context late environment fails after an earlier real block",1,late.get("staged_blocks",-1))
	check("context late environment preserves committed scope",true,owner.readiness(previous.ticket).ok)

func asset_variant_checks(owner: Node, fixture: Dictionary, retained: Dictionary) -> Dictionary:
	var image_result: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#context-png"))
	check("context real DATA image slot prepares",true,image_result.ok)
	if image_result.ok:
		retained = image_result.ticket
		var visual: MeshInstance3D = owner.find_children("*","MeshInstance3D",true,false)[0]
		var material: ShaderMaterial = visual.get_surface_override_material(0)
		check("context real DATA image slot pixels",Layout.Common.sha256(png_pixels()),Layout.Common.sha256(bound_image(material,0).get_data()))
		check("context image override retains logical source dimensions",Vector2(64,64),material.get_shader_parameter("source_sizes")[0])
		check("context image replacement retains binary alpha",Image.ALPHA_BIT,bound_image(material,0).detect_alpha())
		var original: Image = material.get_shader_parameter("albedo_texture").get_image()
		var edited: Image = original.duplicate()
		edited.fill(Color.GREEN)
		material.set_shader_parameter("albedo_texture",ImageTexture.create_from_image(edited))
		var decoded: Dictionary = owner.layouts.media.export_resource("assembly.test","palette-slot","image",owner.registry.content_ticket())
		check("context instance mutation cannot alter DATA image",Layout.Common.sha256(png_pixels()),Layout.Common.sha256(decoded.resource.image.get_data()))
		material.set_shader_parameter("albedo_texture",ImageTexture.create_from_image(original))
		var expectation_path := str(fixture.sandbox).path_join("context-restart-expectations.json")
		var expectation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(expectation_path))
		expectation.png_context_version = image_result.context_version
		write(expectation_path,JSON.stringify(expectation))
	var selected: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#context-default"))
	check("context declared DATA default reaches LOC",true,selected.ok)
	if selected.ok:
		retained = selected.ticket
		check("context DATA default applies alternate palette",123,selected.palette.slots["120"])
		check("context DATA default preserves durable layout anchor","context-default",selected.layout.record)
		check("context DATA compatibility receipt retained",1,selected.compatibility_receipts.size())
		check("context DATA proposal is not SAVE migration",false,selected.compatibility_receipts[0].save_compatible)
	var explicit := request(owner,"packs/assembly.test#context-default")
	explicit.variants = {"layout_selection":{"intent":"baseline"},"selections":[],"required":[],"compatibility":[]}
	var baseline: Dictionary = await assemble(owner,explicit)
	check("context explicit baseline overrides DATA default",true,baseline.ok and baseline.palette.slots["120"] == 120)
	if baseline.ok: retained = baseline.ticket
	var variant: Dictionary = owner.registry.query("world.variants","packs/assembly.test","structural-selection")
	explicit = request(owner,"packs/assembly.test#context-default")
	explicit.variants = {"layout_selection":{"intent":"variant","variant":variant.record.identity},"selections":[],"required":[],"compatibility":[]}
	var rejected: Dictionary = owner.begin(explicit)
	check("context structural edit retains real-provider gate","provider_pending",rejected.kind)
	check("context structural rejection retains receipt",1,rejected.compatibility_receipts.size())
	check("context structural rejection preserves scope",true,owner.readiness(retained).ok)
	var bridge: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#context-bridge"))
	check("context actual bridge geometry prepares",true,bridge.ok)
	if bridge.ok:
		retained = bridge.ticket
		var under: Dictionary = owner.spatial_context(retained,Frame.FRAME,Vector3(0,0.5,0))
		var deck: Dictionary = owner.spatial_context(retained,Frame.FRAME,Vector3(0,2.1,0))
		var lower: Dictionary = owner.spatial_context(retained,Frame.FRAME,Vector3(0,-1.9,0))
		check("context water remains valid below dry bridge",true,under.ok and not under.water_absent)
		check("context dry bridge never becomes immersion",true,deck.ok and deck.water_absent and deck.areas[0].id == "bridge-deck")
		check("context solid pool floor protects stacked dry room",true,lower.ok and lower.water_absent and lower.areas[0].id == "lower-room")
		check("context bridge queries emit no gameplay outcomes",[],under.events+deck.events+lower.events)
		if DisplayServer.get_name() != "headless": await capture_environment(owner,fixture)
	var media: RefCounted = owner.layouts.media
	owner.layouts.media = ControlledImageFailure.new()
	var failed: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#context-png"))
	owner.layouts.media = media
	check("context controlled selected-image failure has no fallback","controlled_image_failure",failed.kind)
	check("context controlled image failure preserves committed scope",true,owner.readiness(retained).ok)
	return retained

func capture_palette(owner: Node, fixture: Dictionary, label_: String) -> PackedByteArray:
	var parent: Node = owner.get_parent()
	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	viewport.size = Vector2i(400,400)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	parent.add_child(viewport)
	owner.reparent(viewport)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color.MAGENTA
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = 1.0
	viewport.add_child(world)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.current = true
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.0
	camera.position = Vector3(0,1,0)
	camera.look_at(Vector3(0,-1,0),Vector3.FORWARD)
	await owner.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	check("context rendered capture "+label_,OK,image.save_png(str(fixture.sandbox).path_join("context-"+label_+".png")))
	var colors := {}
	for y in range(0,400,8):
		for x in range(0,400,8): colors[image.get_pixel(x,y).to_rgba32()] = true
	check("context rendered textured geometry visible "+label_,true,colors.size() > 4)
	var pixels := image.get_data()
	owner.reparent(parent)
	await owner.get_tree().physics_frame
	await owner.get_tree().physics_frame
	viewport.free()
	return pixels

func capture_environment(owner: Node, fixture: Dictionary) -> void:
	var parent: Node = owner.get_parent()
	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	viewport.size = Vector2i(600,500)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	parent.add_child(viewport)
	owner.reparent(viewport)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("17212a")
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = 0.9
	viewport.add_child(world)
	var surface := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(4,2)
	surface.mesh = plane
	surface.position.y = 1.0
	surface.material_override = diagnostic_material(Color(0.1,0.5,1.0,0.45))
	viewport.add_child(surface)
	for entry in [[Vector3(0,0.5,0),Color.CYAN],[Vector3(0,2.1,0),Color.ORANGE],[Vector3(0,-1.9,0),Color.GREEN]]:
		var marker := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.08
		sphere.height = 0.16
		sphere.radial_segments = 12
		sphere.rings = 6
		marker.mesh = sphere
		marker.position = entry[0]
		marker.material_override = diagnostic_material(entry[1])
		viewport.add_child(marker)
	var label_ := Label.new()
	label_.position = Vector2(12,12)
	label_.text = "Checked spatial queries (not MOVE contact)\nCyan: wet below dry bridge; orange: dry deck\nGreen: dry lower room, protected by solid pool floor\nBlue: authored surface at 1 m. Floors: -2, 0, 2 m."
	label_.add_theme_font_size_override("font_size",16)
	label_.add_theme_color_override("font_outline_color",Color.BLACK)
	label_.add_theme_constant_override("outline_size",3)
	viewport.add_child(label_)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.current = true
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 7.5
	camera.position = Vector3(5,5,5)
	camera.look_at(Vector3.ZERO)
	await owner.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	check("context rendered water and dry-area review capture",OK,image.save_png(str(fixture.sandbox).path_join("context-water-areas.png")))
	var colors := {}
	for y in range(120,500,8):
		for x in range(0,600,8): colors[image.get_pixel(x,y).to_rgba32()] = true
	check("context rendered water and area geometry visible",true,colors.size() > 6)
	owner.reparent(parent)
	await owner.get_tree().physics_frame
	await owner.get_tree().physics_frame
	preload("res://scripts/loc/dungeon_geometry.gd").release(viewport)

static func diagnostic_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if color.a < 1.0: material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material

static func bound_image(material: ShaderMaterial, binding: int) -> Image:
	var region: Vector4 = material.get_shader_parameter("regions")[binding]
	return material.get_shader_parameter("albedo_texture").get_image().get_region(Rect2i(int(region.x),int(region.y),int(region.z),int(region.w)))
