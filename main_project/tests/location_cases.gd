extends "res://tests/dungeon_cases.gd"
const Location = preload("res://scripts/loc/location_assembly.gd")
var source := {}
var doorway_cases := preload("res://tests/location_doorway_cases.gd").new()

func declarations() -> Dictionary:
	return {"schema":"location-assembly-declarations-v1","ground_archive":2,"required_bindings":[],"hit_rules":[]}

func publish_location(mods: RefCounted) -> void:
	var layout := Layout.value("layout",{"mode":"authored","location":"packs/classic#place-00001","placements":[],"location_assembly":declarations()})
	for index in 2:
		var p := {"id":"copy-%d" % index,"context":"exterior","block":"packs/classic#"+source.block,"transform":source_pose([index*8192,0,0],[0,index*512,0]),"placement_mode":"snapped","snap":{"position_step":4096,"rotation_step":512}}
		if index == 1:
			p.transform = {"frame":Frame.FRAME,"position_unit":"metre","rotation_unit":"radian","position":[220.25,0.0,13.75],"rotation":[0.0,0.37,0.0],"scale":[1,1,1]}
			p.placement_mode = "free"
			p.erase("snap")
		layout.data.placements.append(p)
	var reordered := layout.duplicate(true)
	reordered.data.placements.reverse()
	var bad := layout.duplicate(true)
	bad.data.location_assembly.required_bindings = [{"record":"copy-1/absent","owner":"LOC-structure"}]
	var selector := layout.duplicate(true)
	selector.data.location_assembly.hit_rules = [{"candidates":["missing/a","missing/b"],"selected":"missing/a"}]
	var required_owner := layout.duplicate(true)
	required_owner.data.location_assembly.required_bindings = [{"record":"copy-0/"+source.records[0].id,"owner":"SAVE"}]
	var header := "00".repeat(8)
	var ground := {"header":header,"tiles":"00".repeat(256),"scenery":"ff".repeat(256)}
	var broken := Layout.value("block",{"mode":"authored","format":"RMB","records":[{"id":"bad","type":"model","model_id":4294967295,"object_type":0,"transform":source_pose()}],"structure":{"ground":ground,"automap":"00".repeat(4096),"buildings":[],"misc":["bad"]}})
	var late := layout.duplicate(true)
	late.data.placements[1].block = "packs/location.test#broken"
	var pack := manifest("location.test")
	pack.content = ["layout.json","z-classic-replacement.json","z-doorway-patch.json"]
	write(mods.root.path_join("Mods/location/mod.json"),JSON.stringify(pack))
	var entries := [{"id":"native","value":layout},{"id":"reordered","value":reordered},{"id":"missing-binding","value":bad},{"id":"missing-selector","value":selector},{"id":"required-owner","value":required_owner},{"id":"broken","value":broken},{"id":"late-failure","value":late}]
	var shared := broken.duplicate(true)
	shared.data.records = []
	for id in ["facade-a","facade-b"]: shared.data.records.append({"id":id,"type":"model","model_id":549,"object_type":0,"transform":source_pose()})
	shared.data.structure.misc = []
	shared.data.records.append({"id":"room","type":"model","model_id":11004,"object_type":3,"transform":{"frame":Frame.FRAME,"position_unit":"metre","rotation_unit":"radian","position":[0.0,1.25,0.0],"rotation":[0.0,0.0,0.0],"scale":[1,1,1]}})
	shared.data.records.append({"id":"dual-marker","type":"flat","texture":{"archive":199,"record":4},"marker_purpose":"editor-other","marker_roles":["rest","quest"],"flags":0,"faction_id":0,"transform":source_pose()})
	var metadata := {"name_seed":0,"service_time_limit":0,"unknown":[0,0,0,0],"faction_id":0,"sector":0,"location_id":0,"building_type":0,"quality":0}
	shared.data.structure.buildings = [{"id":"hall","transform":source_pose(),"metadata":metadata,"exterior":["facade-a","facade-b"],"interior":["room","dual-marker"]}]
	entries.append({"id":"shared-block","value":shared})
	var shared_layout := layout.duplicate(true)
	shared_layout.data.placements = [{"id":"shared","context":"exterior","block":"packs/location.test#shared-block","transform":source_pose()}]
	entries.append({"id":"shared","value":shared_layout})
	var first_door: Dictionary = source.records[0].doors[0]
	var selected_layout := shared_layout.duplicate(true)
	selected_layout.data.location_assembly.hit_rules = [{"candidates":["shared/facade-a/plane-%d" % first_door.plane,"shared/facade-b/plane-%d" % first_door.plane],"selected":"shared/facade-a/plane-%d" % first_door.plane}]
	entries.append({"id":"selected","value":selected_layout})
	var interior_placed := shared_layout.duplicate(true)
	interior_placed.data.placements[0].context = "interior"
	interior_placed.data.placements[0].transform = {"frame":Frame.FRAME,"position_unit":"metre","rotation_unit":"radian","position":[7.25,2.0,13.75],"rotation":[0.0,PI/2.0,0.0],"scale":[1,1,1]}
	interior_placed.data.placements[0].placement_mode = "free"
	entries.append({"id":"interior-placed","value":interior_placed})
	var scaling := layout.duplicate(true)
	scaling.data.placements = []
	for index in 64:
		scaling.data.placements.append({"id":"scale-%02d" % index,"context":"exterior","block":"packs/classic#"+source.block,"transform":source_pose([(index%8)*6144,0,(index/8)*6144]),"placement_mode":"snapped","snap":{"position_step":6144,"rotation_step":512}})
	entries.append({"id":"scaling","value":scaling})
	var other_town := layout.duplicate(true)
	other_town.data.location = "packs/classic#place-00002"
	entries.append({"id":"other-town","value":other_town})
	doorway_cases.publish(self,entries,mods)
	write(mods.root.path_join("Mods/location/layout.json"),JSON.stringify({"domain":Layout.DOMAIN,"path":"packs/location.test","operation":"add","entries":entries}))
	mods.rescan()
	mods.edit("location.test","toggle")

func area_request(owner: Node, layout: String, area: Dictionary) -> Dictionary:
	var input := request(owner,layout)
	input.area = area.duplicate(true)
	return input

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	source = JSON.parse_string(FileAccess.get_file_as_string("res://tests/location_source_observation.json"))
	var reload: bool = fixture.mode.ends_with("_reload")
	for name: String in source.sources: check("source hash "+name,source.sources[name],FileAccess.get_sha256(str(fixture.classic_source).path_join(name)))
	check("profile source hash",source.profile_sha256,FileAccess.get_sha256("res://content/layouts/profile.json"))
	var invalid := declarations()
	invalid.hit_rules = [{"candidates":["same","same"],"selected":"same"}]
	check("duplicate hit selector rejects",true,not preload("res://scripts/data/location_assembly_schema.gd").reason(invalid).is_empty())
	publish_location(shell.controller.mods)
	shell.controller.settings.apply({"startup/show_setup":true})
	shell.controller.settings.effective["startup/show_setup"] = true
	var selected: Dictionary = shell.controller.select_folder(fixture.classic_source)
	check("complete adapter composition prepares",true,shell.controller.prepared_content.get("ok",false))
	if not shell.controller.prepared_content.get("ok",false):
		observations.failure = selected
		return terminal(fixture)
	observations.publication = shell.controller.providers.definitions.timings.duplicate(true)
	check("normal content publication",true,shell.controller.continue_to_menu("run").ok)
	await shell.get_tree().process_frame
	shell.session_shell.synchronize_startup()
	var owner: Node = shell.session_shell.dungeon_assembly
	check("normal shell uses shared location owner",true,owner is Location)
	# Definition access is explicitly tested before any live session/geometry.
	var layout := "packs/classic#"+str(source.location)
	var building: String = source.buildings[0].id
	var definition: Dictionary = owner.building_definition(layout,source.placement,building)
	check("building definition before activation",true,definition.ok)
	if not definition.ok:
		observations.failure = definition
		return terminal(fixture)
	check("service association remains pending",false,definition.record.service_binding_ready)
	check("native interior definition before activation",true,owner.building_definition("packs/location.test#interior-placed","shared","hall").ok)
	var candidates: Dictionary = owner.building_candidates(layout,"type",definition.record.metadata.building_type)
	check("type candidates contain exact building",true,candidates.records.any(func(r: Dictionary): return r.identity.building == building))
	definition.record.metadata.quality = -1
	check("definition projections are detached",true,owner.building_definition(layout,source.placement,building).record.metadata.quality >= 0)
	var faction: Dictionary = owner.building_candidates(layout,"faction",definition.record.metadata.faction_id)
	check("faction candidates contain exact building",true,faction.records.any(func(r: Dictionary): return r.identity.building == building))
	check("directory candidate order deterministic",candidates.records,owner.building_candidates(layout,"type",definition.record.metadata.building_type).records)
	var repeated_a: Dictionary = owner.building_definition("packs/location.test#native","copy-0",building)
	var repeated_b: Dictionary = owner.building_definition("packs/location.test#native","copy-1",building)
	check("repeated definition occurrences independent",true,repeated_a.ok and repeated_b.ok and repeated_a.record.identity != repeated_b.record.identity)
	var other: Dictionary = owner.building_definition("packs/location.test#other-town","copy-0",building)
	check("same local building in another location",true,other.ok and repeated_a.record.identity.location != other.record.identity.location)
	var started := Time.get_ticks_usec()
	for i in 1000: owner.building_definition(layout,source.placement,building)
	observations.directory_query_usec = Time.get_ticks_usec()-started
	owner.core.provider = preload("res://tests/controlled_session_provider.gd").new()
	check("controlled CORE seam","Succeeded",owner.core.request({"id":"location-session","mode":"new","origin":"","selection":{}}).kind)
	for model: String in source.uv_vectors:
		var decoded: Dictionary = owner.layouts.classic.decode_model(int(model))
		check("packed UV required model "+model,true,decoded.ok)
		if not decoded.ok: continue
		var data: Dictionary = decoded.value.projection()
		for vector: Dictionary in source.uv_vectors[model]:
			var plane: Dictionary = data.planes[int(vector.plane)]
			for index in 3:
				check("packed UV encoded %s/%d/%d" % [model,vector.plane,index],[int(vector.encoded[index][0]),int(vector.encoded[index][1])],plane.encoded_uv[index])
				check("packed UV independent %s/%d/%d" % [model,vector.plane,index],Vector2(vector.effective[index][0],vector.effective[index][1]),plane.uv_sixteenths[index])
	var exterior_request := area_request(owner,layout,{"kind":"exterior"})
	var exterior: Dictionary = await assemble(owner,exterior_request)
	check("classic exterior geometry assembles",true,exterior.ok)
	if not exterior.ok:
		observations.failure = exterior
		return terminal(fixture)
	observations.exterior = owner.measurements.duplicate(true)
	last_live_ticket = exterior.ticket
	check("classic exterior collision ready",true,exterior.collision_ready)
	check("classic exterior context resolved",true,exterior.context_ready)
	check("classic exterior destination stays gated",false,exterior.destination_ready)
	check("classic exterior owner state stays gated",false,exterior.owner_state_ready)
	check("classic exterior building count",source.buildings.size(),exterior.buildings.size())
	await vectors(owner,exterior,"exterior","")
	await owner.get_tree().physics_frame
	await owner.get_tree().physics_frame
	var ground: Dictionary = owner.geometry_ray(exterior.ticket,Vector3(1,1,-1),Vector3(1,-1,-1))
	check("RMB ground has real Jolt collision",true,ground.ok and ground.found and absf(ground.position.y-float(source.ground.height_metres)) <= Frame.POSITION_TOLERANCE)
	check("RMB ground hit identity","@ground",ground.get("record",{}).get("record",""))
	var ground_binding: Dictionary = owner.binding(exterior.ticket,source.placement,"@ground").binding
	# Independent DFU shader matrices, composed with BaseImageFile.GetColor32's
	# bottom-up upload. Our DATA images stay top-left-first. First triangle 0,2,1.
	var expected_ground_uv := [
		PackedVector2Array([Vector2(0,1),Vector2(1,0),Vector2(1,1)]),
		PackedVector2Array([Vector2(0,0),Vector2(1,1),Vector2(0,1)]),
		PackedVector2Array([Vector2(1,0),Vector2(0,1),Vector2(0,0)]),
		PackedVector2Array([Vector2(1,1),Vector2(0,0),Vector2(1,0)])]
	for slot in 256:
		var probe: Dictionary = ground_binding.probes[slot]
		check("ground encoded tile %d" % slot,int(source.ground.tiles[slot]),probe.encoded)
		var expected := Vector3((slot%16)*6.4,-0.025,-(15-slot/16)*6.4)
		check("ground independent tile origin %d" % slot,true,probe.triangle[0].distance_to(expected) <= Frame.POSITION_TOLERANCE)
		check("ground independent image orientation %d" % slot,expected_ground_uv[int(source.ground.tiles[slot]) >> 6],probe.uv)
	if DisplayServer.get_name() != "headless": await location_capture(owner,shell,fixture,"exterior",Vector3(123,105,23),Vector3(51,0,-51))
	var version: String = exterior.geometry_version
	var interior_area := {"kind":"interior","placement":source.placement,"building":building,"instance":"suite-alpha"}
	var interior: Dictionary = await assemble(owner,area_request(owner,layout,interior_area))
	check("classic building interior assembles",true,interior.ok)
	if not interior.ok:
		observations.failure = interior
		return terminal(fixture)
	observations.interior = owner.measurements.duplicate(true)
	last_live_ticket = interior.ticket
	await vectors(owner,interior,"interior",building)
	check("interior instance retained","suite-alpha",interior.area.instance)
	check("doorway unrelated inspection instance stays unbound",false,interior.doors.values().any(func(door: Dictionary): return door.binding_ready))
	var action_count: int = source.records.filter(func(r: Dictionary): return r.context == "interior" and r.building == building and r.type == "door").size()
	check("independent action-door inventory",action_count,interior.action_doors.size())
	check("action doors retain pending owner",true,interior.action_doors.values().all(func(r: Dictionary): return not r.gameplay_owner_ready))
	for marker: Dictionary in source.markers:
		if marker.context != "interior" or marker.building != building: continue
		if marker.role not in ["rest","entry"]: continue
		var records: Dictionary = owner.marker_candidates(interior.ticket,"suite-alpha",marker.role)
		var found: Array = records.records.filter(func(r: Dictionary): return r.identity.record == marker.id)
		check("interior scoped marker role "+str(marker.id),1,found.size())
		if not found.is_empty():
			check("interior independent marker position "+str(marker.id),true,found[0].transform.origin.distance_to(Vector3(marker.position[0],marker.position[1],marker.position[2])) <= Frame.POSITION_TOLERANCE)
			check("source marker role inventory "+str(marker.id),[str(marker.role)],found[0].roles)
	check("wrong interior marker query rejects","missing",owner.marker_candidates(interior.ticket,"other-suite","rest").kind)
	check("interior has no exterior ground",false,interior.bindings.has(str(source.placement)+"/@ground"))
	check("interior placement independent of exterior",Transform3D.IDENTITY,interior.occurrences[0].transform)
	check("exterior receipt becomes stale",false,owner.readiness(exterior.ticket).ok)
	if DisplayServer.get_name() != "headless":
		var bounds := AABB()
		var first := true
		for value: Dictionary in interior.bindings.values():
			if not value.has("bounds"): continue
			bounds = value.bounds if first else bounds.merge(value.bounds)
			first = false
		await location_capture(owner,shell,fixture,"interior",bounds.get_center()+Vector3(15,14,19),bounds.get_center())
	if reload:
		var stored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(str(fixture.sandbox).path_join("location-reconstruction.json")))
		check("fresh-process geometry version",stored.exterior,version)
		check("fresh-process interior geometry version",stored.interior,interior.geometry_version)
		check("reconstruction grants no SAVE",false,interior.save_compatible)
		await doorway_cases.run(self,owner,true,fixture,shell)
		return terminal(fixture)
	write(str(fixture.sandbox).path_join("location-reconstruction.json"),JSON.stringify({"exterior":version,"interior":interior.geometry_version}))
	await doorway_cases.run(self,owner,false,fixture,shell)
	if DisplayServer.get_name() != "headless": await tavern_visuals(owner,shell,fixture)
	await native_and_failures(owner,layout,interior_area)
	await exterior_scaling(owner)
	await operation_checks(owner,layout)
	await source_checks(owner,shell.controller.providers,fixture,layout)
	return terminal(fixture)

func vectors(owner: Node, result: Dictionary, context: String, building: String) -> void:
	await owner.get_tree().physics_frame
	await owner.get_tree().physics_frame
	var expected_doors := 0
	for record: Dictionary in source.records:
		if record.context != context or (context == "interior" and record.building != building): continue
		var id: String = record.id
		var binding: Dictionary = owner.binding(result.ticket,source.placement,id)
		check(context+" model binding "+id,true,binding.ok)
		if not binding.ok: continue
		check(context+" model source hash "+id,record.model_sha256,binding.binding.geometry_provenance.sha256)
		var bounds: AABB = binding.binding.bounds
		check(context+" independent min "+id,true,bounds.position.distance_to(Vector3(record.bounds[0][0],record.bounds[0][1],record.bounds[0][2])) <= Frame.POSITION_TOLERANCE)
		check(context+" independent max "+id,true,bounds.end.distance_to(Vector3(record.bounds[1][0],record.bounds[1][1],record.bounds[1][2])) <= Frame.POSITION_TOLERANCE)
		expected_doors += record.doors.size()
		for plane: Dictionary in record.doors:
			var key := "%s/%s/plane-%d" % [source.placement,id,plane.plane]
			check(context+" static plane retained "+key,true,result.doors.has(key))
			if not result.doors.has(key): continue
			var a := Vector3(plane.points[0][0],plane.points[0][1],plane.points[0][2])
			var b := Vector3(plane.points[1][0],plane.points[1][1],plane.points[1][2])
			var c := Vector3(plane.points[2][0],plane.points[2][1],plane.points[2][2])
			var point := (a+b+c)/3.0
			var normal := (b-a).cross(c-a).normalized()
			var hit: Dictionary = owner.geometry_ray(result.ticket,point+normal*0.01,point-normal*0.01)
			check(context+" independent static-plane collision "+key,true,hit.ok and hit.found and hit.position.distance_to(point) <= Frame.POSITION_TOLERANCE)
			check(context+" exact hit region "+key,true,hit.get("candidates",[]).has(key))
			check(context+" unresolved door never dispatches "+key,false,hit.get("door_action",true))
	check(context+" independent door inventory",expected_doors,result.doors.size())

func tavern_visuals(owner: Node, shell: Control, fixture: Dictionary) -> void:
	var layout := "packs/classic#"+str(source.location)
	var exterior: Dictionary = await assemble(owner,area_request(owner,layout,{"kind":"exterior"}))
	check("tavern inspection exterior",true,exterior.ok)
	if not exterior.ok: return
	for plane in [36,41,46]:
		var door: Dictionary = exterior.doors["%s/record-00150/plane-%d" % [source.placement,plane]]
		var centre := Vector3.ZERO
		for point: Vector3 in door.triangles: centre += point
		centre /= door.triangles.size()
		await location_capture(owner,shell,fixture,"tavern-exterior-%d" % plane,centre+door.normal*3+Vector3.UP*0.3,centre)
	var interior: Dictionary = await assemble(owner,area_request(owner,layout,{"kind":"interior","placement":source.placement,"building":"building-0002","instance":"tavern-inspection"}))
	check("tavern inspection interior",true,interior.ok)
	if not interior.ok: return
	check("tavern inspection never grants binding readiness",false,interior.binding_ready)
	for id in ["record-00200","record-00203"]:
		var door: Dictionary = interior.doors["%s/%s/plane-2" % [source.placement,id]]
		var centre := Vector3.ZERO
		for point: Vector3 in door.triangles: centre += point
		centre /= door.triangles.size()
		await location_capture(owner,shell,fixture,"tavern-interior-"+id,centre+door.normal*3+Vector3.UP*0.3,centre)
	await location_capture(owner,shell,fixture,"tavern-interior-courtyard-wall",Vector3(2.225,1.5,6),Vector3(2.225,1.175,3.35))
	last_live_ticket = interior.ticket

func native_and_failures(owner: Node, layout: String, interior_area: Dictionary) -> void:
	var native_request := area_request(owner,"packs/location.test#native",{"kind":"exterior"})
	var native: Dictionary = await assemble(owner,native_request)
	check("native snapped free repeated assembly",true,native.ok)
	if not native.ok:
		observations.native_failure = native
		return
	last_live_ticket = native.ticket
	observations.native = owner.measurements.duplicate(true)
	check("repeated source decoded once",1,owner.measurements.unique_block_decodes)
	check("repeated independent building count",source.buildings.size()*2,native.buildings.size())
	await owner.get_tree().physics_frame
	await owner.get_tree().physics_frame
	for id: String in native.doors:
		var door: Dictionary = native.doors[id]
		var point: Vector3 = (door.triangles[0]+door.triangles[1]+door.triangles[2])/3.0
		var hit: Dictionary = owner.geometry_ray(native.ticket,point+door.normal*0.01,point-door.normal*0.01)
		check("native transformed static-plane hit "+id,true,hit.ok and hit.found and hit.get("candidates",[]).has(id))
	for selection in ["shared","selected"]:
		var shared: Dictionary = await assemble(owner,area_request(owner,"packs/location.test#"+selection,{"kind":"exterior"}))
		check(selection+" geometry assembles",true,shared.ok)
		if not shared.ok: continue
		last_live_ticket = shared.ticket
		await owner.get_tree().physics_frame
		await owner.get_tree().physics_frame
		var door: Dictionary = shared.doors.values()[0]
		var point: Vector3 = (door.triangles[0]+door.triangles[1]+door.triangles[2])/3.0
		var hit: Dictionary = owner.geometry_ray(shared.ticket,point+door.normal*0.01,point-door.normal*0.01)
		check(selection+" coincident candidate inventory",2,hit.get("candidates",[]).size())
		check(selection+" explicit hit outcome","ambiguous" if selection == "shared" else "entrance",hit.get("hit_kind",""))
		check(selection+" no traversal dispatch",false,hit.get("door_action",true))
		if selection == "selected": check("authored selector retains exact facade","facade-a",hit.entrance.identity.record)
	var scoped := {"kind":"interior","placement":"shared","building":"hall","instance":"authored-suite"}
	var authored: Dictionary = await assemble(owner,area_request(owner,"packs/location.test#shared",scoped))
	check("authored marker interior assembles",true,authored.ok)
	if authored.ok:
		last_live_ticket = authored.ticket
		check("authored type-three metre pose remains literal",true,owner.binding(authored.ticket,"shared","room").binding.transform.origin.distance_to(Vector3(0,1.25,0)) < Frame.POSITION_TOLERANCE)
		for role in ["rest","quest"]:
			var markers: Dictionary = owner.marker_candidates(authored.ticket,"authored-suite",role)
			check("authored multiple role "+role,1,markers.records.size())
			check("authored marker at origin "+role,Vector3.ZERO,markers.records[0].transform.origin)
		check("authored marker instance identity","authored-suite",owner.binding(authored.ticket,"shared","dual-marker").binding.identity.interior)
	var placed_interior: Dictionary = await assemble(owner,area_request(owner,"packs/location.test#interior-placed",scoped))
	check("native interior free occurrence assembles",true,placed_interior.ok)
	if placed_interior.ok:
		last_live_ticket = placed_interior.ticket
		check("placed native type-three metre pose remains literal",true,owner.binding(placed_interior.ticket,"shared","room").binding.transform.origin.distance_to(Vector3(7.25,3.25,13.75)) < Frame.POSITION_TOLERANCE)
		var marker: Dictionary = owner.marker_candidates(placed_interior.ticket,"authored-suite","rest").records[0]
		check("native interior authored marker translation",true,marker.transform.origin.distance_to(Vector3(7.25,2,13.75)) < Frame.POSITION_TOLERANCE)
		check("native interior authored marker rotation",true,(marker.transform.basis*Vector3.RIGHT).distance_to(Vector3.FORWARD) < Frame.POSITION_TOLERANCE)
	var reordered: Dictionary = await assemble(owner,area_request(owner,"packs/location.test#reordered",{"kind":"exterior"}))
	check("reordered placements assemble",true,reordered.ok)
	if reordered.ok:
		last_live_ticket = reordered.ticket
		for id: String in native.buildings:
			check("reordered stable building "+id,native.buildings[id].identity.placement,reordered.buildings[id].identity.placement)
	for bad in ["missing-binding","missing-selector","required-owner","late-failure"]:
		var failure: Dictionary = await assemble(owner,area_request(owner,"packs/location.test#"+bad,{"kind":"exterior"}))
		check("reject "+bad,false,failure.ok)
		check("preserve geometry "+bad,true,owner.readiness(last_live_ticket).ok)
		check("release staging "+bad,true,owner._stage.is_empty())
		if bad == "late-failure": check("resource fails after earlier placement",1,failure.staged_blocks)
	var pending: Dictionary = owner.begin(area_request(owner,"packs/location.test#native",{"kind":"exterior"}))
	check("cancellable request admitted",true,pending.ok)
	owner.step(pending.ticket)
	var wrong: Dictionary = pending.ticket.duplicate(true)
	wrong.serial += 1
	check("foreign cancellation rejects","stale",owner.cancel(wrong).kind)
	check("cancel partial assembly","cancelled",owner.cancel(pending.ticket).kind)
	check("late step rejects","stale",owner.step(pending.ticket).kind)
	check("cancel preserves geometry",true,owner.readiness(last_live_ticket).ok)
	var retry: Dictionary = await assemble(owner,area_request(owner,layout,interior_area))
	check("retry production assembly",true,retry.ok)
	if retry.ok: last_live_ticket = retry.ticket
	interior_area.instance = "suite-beta"
	var independent: Dictionary = await assemble(owner,area_request(owner,layout,interior_area))
	check("independent interior template assembles",true,independent.ok)
	if independent.ok:
		check("independent interior identity","suite-beta",independent.area.instance)
		last_live_ticket = independent.ticket
	check("superseded request retains no geometry","retained",owner.begin(native_request).kind)
	var pending_retire: Dictionary = owner.begin(area_request(owner,layout,{"kind":"exterior"}))
	owner.step(pending_retire.ticket)
	owner.core.request({"id":"retire-location","mode":"new","origin":owner.core.snapshot().session,"selection":{}})
	owner.core.confirm(owner.core.ticket(),true)
	check("retirement rejects late result","stale",owner.step(pending_retire.ticket).kind)
	check("retirement clears live receipt",false,owner.readiness(last_live_ticket).ok)

func location_capture(owner: Node, shell: Control, fixture: Dictionary, label: String, eye: Vector3, target: Vector3) -> void:
	var parent := owner.get_parent()
	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	viewport.size = Vector2i(1200,800)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	shell.add_child(viewport)
	owner.reparent(viewport)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(0.07,0.09,0.12)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.85
	viewport.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45,-30,0)
	viewport.add_child(light)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.position = eye
	camera.look_at(target)
	camera.current = true
	camera.far = 600
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	check("render capture "+label,OK,image.save_png(str(fixture.sandbox).path_join("location-"+label+".png")))
	owner.reparent(parent)
	viewport.free()

func operation_checks(owner: Node, layout: String) -> void:
	var core: RefCounted = owner.core
	var provider: RefCounted = core.provider
	provider.hold_preflight = true
	check("original operation preflight","pending",core.request({"id":"location-operation","mode":"new","origin":core.snapshot().session,"selection":{}}).kind)
	var original: Dictionary = core.ticket()
	var input := area_request(owner,layout,{"kind":"exterior"})
	input.core_ticket = original
	input.session = original.scope
	input.arrival = {"route":"home-east","kind":"doorway","doorway":"home-east"}
	var prepared: Dictionary = await assemble(owner,input)
	check("isolated original-ticket geometry",true,prepared.ok)
	if not prepared.ok:
		observations.operation_failure = prepared
		core.cancel(original)
		return
	check("original ticket retains admission scope",original,prepared.ticket.request.core_ticket)
	var marker: Dictionary = owner.marker_candidate(prepared.ticket,"home-east")
	check("preflight activation rejects","pending",owner.activate(prepared.ticket).kind)
	provider.hold_readiness = true
	core.complete_preflight(original,{"ok":true})
	core.confirm(original,true)
	check("original operation reaches initialization","initializing",core.snapshot().phase)
	check("prepared survives outgoing retirement",true,owner.readiness(prepared.ticket).ok)
	check("activation under original operation",true,owner.activate(prepared.ticket).ok)
	check("activation epoch separate from admission",true,owner.projection(prepared.ticket).activation_session != original.scope)
	check("doorway activation invalidates prepared handoff",false,owner._marker_handoff_current(prepared.ticket,"home-east",0,marker.handoff_id))
	var allowed := func(value: Dictionary): return {"ok":true,"handoff_id":value.handoff_id}
	var late := func(_value: Dictionary): return {"kind":"pending","handoff_id":marker.handoff_id,"marker":marker.marker,"frame":Frame.FRAME}
	check("doorway late preactivation provider rejects","invalid_placement_result",owner.check_marker_candidate(prepared.ticket,"home-east",0,allowed,late).kind)
	check("activation retry idempotent",true,owner.activate(prepared.ticket).ok)
	check("activated geometry cannot release destination",false,owner.readiness(prepared.ticket).destination_ready)
	core.complete_readiness(core.ticket(),{"ok":true,"services":provider.bindings(),"death_authority":provider})
	check("post-terminal activated receipt valid",true,owner.readiness(prepared.ticket).ok)
	last_live_ticket = prepared.ticket
	provider.hold_preflight = false
	provider.hold_readiness = false

func source_checks(owner: Node, providers: RefCounted, fixture: Dictionary, layout: String) -> void:
	var input := area_request(owner,layout,{"kind":"exterior"})
	var staged: Dictionary = owner.begin(input)
	owner.step(staged.ticket)
	owner.call_deferred("cancel",staged.ticket)
	check("cancel during physics await","stale",(await owner.finish(staged.ticket)).kind)
	check("physics cancellation keeps committed geometry",true,owner.readiness(last_live_ticket).ok)
	staged = owner.begin(area_request(owner,layout,{"kind":"exterior"}))
	owner.step(staged.ticket)
	providers.classic.dispose()
	check("withdrawn source invalidates staging","stale",owner.step(staged.ticket).kind)
	check("withdrawn source invalidates directory","stale",owner.building_definition(layout,source.placement,source.buildings[0].id).kind)
	var recovered: Dictionary = providers.check_classic(fixture.classic_source)
	check("explicit source recovery prepares",true,recovered.ok)
	check("explicit source recovery activates",true,providers.activate_classic(recovered).ok)
	var retry: Dictionary = await assemble(owner,area_request(owner,layout,{"kind":"exterior"}))
	check("source recovery assembly",true,retry.ok)
	staged = owner.begin(area_request(owner,layout,{"kind":"exterior"}))
	owner.step(staged.ticket)
	providers.definitions.dispose()
	check("content retirement invalidates staged result","stale",owner.step(staged.ticket).kind)
	check("content retirement invalidates committed result","stale",owner.readiness(retry.ticket).kind)
	check("doorway content retirement invalidates handoff","stale",owner.marker_candidate(retry.ticket,"home-east").kind)

func exterior_scaling(owner: Node) -> void:
	var result: Dictionary = await assemble(owner,area_request(owner,"packs/location.test#scaling",{"kind":"exterior"}))
	check("64-block exterior assembles",true,result.ok)
	if not result.ok:
		observations.scaling_failure = result
		return
	last_live_ticket = result.ticket
	observations.scaling = owner.measurements.duplicate(true)
	observations.scaling.memory_static_bytes = OS.get_static_memory_usage()
	observations.scaling.memory_peak_bytes = OS.get_static_memory_peak_usage()
	check("64-block exterior source decode reuse",1,owner.measurements.unique_block_decodes)
	check("64-block exterior model instances",576,owner.measurements.geometry_instances)
	check("64-block exterior real collision bodies",128,owner.measurements.physics_bodies)
	check("64-block exterior independent buildings",192,result.buildings.size())
	var started := Time.get_ticks_usec()
	var valid := true
	for i in 1000: valid = valid and owner.binding(result.ticket,"scale-63","record-00000").ok
	observations.scaling.query_usec = Time.get_ticks_usec()-started
	check("64-block exterior indexed binding queries",true,valid)
	await owner.get_tree().physics_frame
	await owner.get_tree().physics_frame
	var hit: Dictionary = owner.geometry_ray(result.ticket,Vector3(1076.2,1,-1076.2),Vector3(1076.2,-1,-1076.2))
	check("64-block exterior last ground collision",true,hit.ok and hit.found and hit.record.placement == "scale-63" and hit.record.record == "@ground")
