extends "res://tests/mod_cases.gd"
const Layout = preload("res://scripts/data/layout_inputs.gd")
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")
var observations := {}
var serial := 0
var last_live_ticket := {}
var source_layout_version := ""

func blank_assembly() -> Dictionary:
	return {"schema":"dungeon-assembly-declarations-v1","connections":[],"door_relationships":[],"required_bindings":[]}

func source_pose(position := [0,0,0], rotation := [0,0,0]) -> Dictionary:
	return preload("res://scripts/data/layout_formats.gd").transform(position,rotation)

func model_record(id: String, model: int, position := [0,0,0], door := false) -> Dictionary:
	return {"id":id,"type":"model","model_id":model,"transform":source_pose(position),"trigger_starting_lock":0,"sound_index":0,"description":"DOR" if door else ""}

func block(records: Array) -> Dictionary:
	return Layout.value("block",{"mode":"authored","format":"RDB","records":records,"structure":{"width":1,"height":1,"model_references":[],"roots":[records.map(func(r: Dictionary): return r.id)]}})

func test_layout(block_id: String, assembly: Dictionary, rotated := false) -> Dictionary:
	var a := {"id":"alpha","context":"dungeon","block":"packs/assembly.test#"+block_id,"transform":source_pose([0,0,0],[0,512 if rotated else 0,0])}
	var b := {"id":"beta","context":"dungeon","block":"packs/assembly.test#"+block_id,"transform":source_pose([256,0,0] if rotated else [0,0,256],[0,512 if rotated else 0,0])}
	if rotated:
		a.placement_mode = "snapped"
		a.snap = {"position_step":64,"rotation_step":512}
		b.transform = {"frame":Frame.FRAME,"position_unit":"metre","rotation_unit":"radian","position":[-6.4,0.0,0.0],"rotation":[0.0,PI/2.0,0.0],"scale":[1,1,1]}
		b.placement_mode = "free"
	return Layout.value("layout",{"mode":"authored","location":"packs/classic#place-00016","placements":[a,b],"assembly":assembly.duplicate(true)})

func straight_connection() -> Dictionary:
	return {"id":"seam","kind":"passage","a":{"placement":"alpha","normal":[0,0,1],"path":[[0,0,64],[0,0,128]]},"b":{"placement":"beta","normal":[0,0,-1],"path":[[0,0,-64],[0,0,-128]]},"clearance":[12,48,12],"support_depth":8,"conditions":[]}

func publish_synthetic(mods: RefCounted) -> void:
	var observation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/dungeon_source_observation.json"))
	var entries: Array = [{"id":"corridor","value":block([model_record("floor",67019)])},{"id":"missing-model","value":block([model_record("missing",4294967295)])},{"id":"no-support","value":block([model_record("far-decoration",41317,[10000,0,0])])}]
	var declared := blank_assembly()
	declared.connections = [straight_connection()]
	for rotated in [false,true]: entries.append({"id":"rotated" if rotated else "straight","value":test_layout("corridor",declared,rotated)})
	var broken := test_layout("corridor",declared)
	broken.data.placements[1].transform.position[2] += 8
	entries.append({"id":"broken","value":broken})
	var missing := test_layout("corridor",declared)
	missing.data.assembly.connections[0].b.placement = "absent"
	entries.append({"id":"missing-connector","value":missing})
	var unsupported := test_layout("corridor",declared)
	unsupported.data.placements[1].block = "packs/assembly.test#missing-model"
	entries.append({"id":"late-resource","value":unsupported})
	var unsupported_axis := test_layout("corridor",declared)
	unsupported_axis.data.placements[1].block = "packs/classic#"+observation.unsupported_axis.block
	entries.append({"id":"unsupported-axis","value":unsupported_axis})
	var hole := test_layout("corridor",declared)
	hole.data.placements[1].block = "packs/assembly.test#no-support"
	entries.append({"id":"missing-support","value":hole})
	var owner_state := test_layout("corridor",declared)
	owner_state.data.assembly.required_bindings = [{"record":"alpha/floor","owner":"SAVE"}]
	entries.append({"id":"required-state","value":owner_state})
	for kind in ["intentional-pair","duplicate","conflict","required-reference"]:
		var records := [model_record("floor",67019),model_record("door-a",55000,[0,0,64],true),model_record("door-b",55000,[0 if kind != "intentional-pair" else 16,0,64],true)]
		entries.append({"id":"doors-"+kind,"value":block(records)})
		var rules := declared.duplicate(true)
		rules.connections[0].conditions = ["alpha/door-a","beta/door-a"]
		if kind == "intentional-pair": rules.connections[0].conditions.append_array(["alpha/door-b","beta/door-b"])
		if kind != "conflict":
			for placement in ["alpha","beta"]:
				var relation := {"kind":"intentional-pair" if kind == "intentional-pair" else "duplicate","a":placement+"/door-a","b":placement+"/door-b"}
				if relation.kind == "duplicate": relation.retained = placement+"/door-a"
				rules.door_relationships.append(relation)
		if kind == "required-reference": rules.required_bindings = [{"record":"alpha/door-b","owner":"QUEST"}]
		entries.append({"id":kind,"value":test_layout("doors-"+kind,rules)})
	var action_records := [model_record("floor",67019),model_record("door-a",55000,[0,0,64],true),model_record("door-b",55000,[0,0,64],true),model_record("switch",41317,[1000,0,1000])]
	action_records[-1].action = {"kind":30,"target":"door-b","axis":0,"duration":0,"magnitude":0}
	entries.append({"id":"action-reference-block","value":block(action_records)})
	var duplicate_rules := declared.duplicate(true)
	duplicate_rules.connections[0].conditions = ["alpha/door-a","beta/door-a"]
	for placement in ["alpha","beta"]: duplicate_rules.door_relationships.append({"kind":"duplicate","a":placement+"/door-a","b":placement+"/door-b","retained":placement+"/door-a"})
	entries.append({"id":"required-action","value":test_layout("action-reference-block",duplicate_rules)})
	var save_rules := duplicate_rules.duplicate(true)
	save_rules.required_bindings = [{"record":"alpha/door-b","owner":"SAVE"}]
	entries.append({"id":"required-save","value":test_layout("doors-duplicate",save_rules)})
	var structural_rules := duplicate_rules.duplicate(true)
	structural_rules.required_bindings = [{"record":"alpha/door-a","owner":"LOC-structure"}]
	entries.append({"id":"retained-reference","value":test_layout("doors-duplicate",structural_rules)})
	var missing_rules := declared.duplicate(true)
	missing_rules.required_bindings = [{"record":"alpha/absent","owner":"LOC-structure"}]
	entries.append({"id":"missing-binding","value":test_layout("corridor",missing_rules)})
	var mechanism_rules := declared.duplicate(true)
	mechanism_rules.connections[0].conditions = ["alpha/floor"]
	entries.append({"id":"unsupported-mechanism","value":test_layout("corridor",mechanism_rules)})
	var pack := manifest("assembly.test")
	var stair_record := model_record("stairs",0)
	stair_record.erase("model_id")
	stair_record.resource = {"provider":"assembly.test","key":"stairs","type":"model"}
	entries.append({"id":"stairs-block","value":block([stair_record])})
	var stairs := test_layout("stairs-block",blank_assembly())
	stairs.data.placements[1].transform = source_pose([160,-80,0])
	stairs.data.assembly.connections = [{"id":"vertical-stair-seam","kind":"stairs","frame":Frame.FRAME,"a":{"placement":"alpha","normal":[1,0,0],"path":[[1,2.15,0],[2,2.4,0]]},"b":{"placement":"beta","normal":[-1,0,0],"path":[[-1,0.9,0],[-2,0.4,0]]},"clearance":[0.2,1.2,0.2],"support_depth":0.6,"conditions":[]}]
	entries.append({"id":"vertical","value":stairs})
	var gap_record := stair_record.duplicate(true)
	gap_record.resource.key = "gap-floor"
	entries.append({"id":"gap-block","value":block([gap_record])})
	var gap := test_layout("gap-block",blank_assembly())
	gap.data.placements[1].transform = source_pose([160,0,0])
	gap.data.assembly.connections = [{"id":"narrow-gap","kind":"passage","frame":Frame.FRAME,"a":{"placement":"alpha","normal":[1,0,0],"path":[[-1,0.025,0],[2,0.025,0]]},"b":{"placement":"beta","normal":[-1,0,0],"path":[[-1,0.025,0],[-2,0.025,0]]},"clearance":[0.2,1.2,0.2],"support_depth":0.2,"conditions":[]}]
	entries.append({"id":"narrow-support-gap","value":gap})
	var scaling := Layout.value("layout",{"mode":"authored","location":"packs/classic#place-00032","placements":[],"assembly":blank_assembly()})
	for index in 64:
		scaling.data.placements.append({"id":"scale-%02d" % index,"context":"dungeon","block":"packs/classic#"+observation.placements[2].block,"transform":source_pose([(index%8)*2560,0,(index/8)*2560]),"placement_mode":"snapped","snap":{"position_step":2560,"rotation_step":512}})
	entries.append({"id":"scaling","value":scaling})
	pack.content = ["layout.json","media.json"]
	write(mods.root.path_join("Mods/assembly/mod.json"),JSON.stringify(pack))
	var bytes := preload("res://tests/dungeon_fixture_geometry.gd").stairs()
	var file := FileAccess.open(mods.root.path_join("Mods/assembly/stairs.glb"),FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
	file = FileAccess.open(mods.root.path_join("Mods/assembly/gap.glb"),FileAccess.WRITE)
	file.store_buffer(preload("res://tests/dungeon_fixture_geometry.gd").gap_floor())
	file.close()
	write(mods.root.path_join("Mods/assembly/media.json"),JSON.stringify({"domain":"media.assets","path":"exports","operation":"add","entries":[{"id":"stairs","value":{"schema":"media-declarations-v1","kind":"export","type":"model","file":"stairs.glb","profile":"static-glb-v1"}},{"id":"gap-floor","value":{"schema":"media-declarations-v1","kind":"export","type":"model","file":"gap.glb","profile":"static-glb-v1"}}]}))
	write(mods.root.path_join("Mods/assembly/layout.json"),JSON.stringify({"domain":Layout.DOMAIN,"path":"packs/assembly.test","operation":"add","entries":entries}))
	mods.rescan()
	mods.edit("assembly.test","toggle")

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})
	if expected != actual: print("ASSEMBLY FAIL ",id,": ",actual)

func declaration() -> Dictionary:
	var annotations: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/dungeon_assembly.json"))
	return annotations.layouts["place-00032"].assembly.duplicate(true)

func request(owner: Node, layout: String) -> Dictionary:
	serial += 1
	return {"id":"assembly-%d" % serial,"requester":"dungeon-fixture","layout":layout,"preparation":"fixture-preparation-%d" % serial,"session":owner.core.snapshot().session,"core_ticket":{},"content_ticket":owner.registry.content_ticket()}

func assemble(owner: Node, input: Dictionary) -> Dictionary:
	var started: Dictionary = owner.begin(input)
	if not started.ok or not started.has("ticket"): return started
	var progress: Dictionary = {"kind":"staging"}
	while progress.kind == "staging":
		progress = owner.step(started.ticket)
		if not progress.ok: return progress
		await owner.get_tree().process_frame
	return await owner.finish(started.ticket)

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var controller: RefCounted = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var mods: RefCounted = controller.mods
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/dungeon_source_observation.json"))
	for name: String in source.sources: check("source edition "+name,source.sources[name],FileAccess.get_sha256(str(fixture.classic_source).path_join(name)))
	var assembly := declaration()
	var native := test_layout("corridor",{"schema":"dungeon-assembly-declarations-v1","connections":[straight_connection()],"door_relationships":[],"required_bindings":[]},true)
	check("native snapped/free schema","",controller.providers.layouts.validate_record("native",native))
	var off_grid := native.duplicate(true)
	off_grid.data.placements[0].transform.position[0] = 1
	check("off-grid snapped pose rejects",true,not controller.providers.layouts.validate_record("native",off_grid).is_empty())
	var scaled := native.duplicate(true)
	scaled.data.placements[1].transform.scale = [2,1,1]
	check("unsupported native scale rejects",true,not controller.providers.layouts.validate_record("native",scaled).is_empty())
	var wrong_frame := assembly.duplicate(true)
	wrong_frame.connections[0].frame = "unity"
	check("undeclared connector frame rejects",true,not Layout.AssemblySchema.reason(wrong_frame).is_empty())
	var empty_normal := assembly.duplicate(true)
	empty_normal.connections[0].a.normal = [0,0,0]
	check("zero connector normal rejects",true,not Layout.AssemblySchema.reason(empty_normal).is_empty())
	publish_synthetic(mods)
	check("assembly declaration schema","",Layout.AssemblySchema.reason(assembly))
	var data := {"mode":"classic-source","location":"packs/classic#"+source.location,"mapping":source.location,"assembly":assembly}
	data.context = Layout.context_annotations().data.layouts[source.location].duplicate(true)
	write(mods.root.path_join("Overrides/assembly.json"),JSON.stringify({"domain":Layout.DOMAIN,"path":"packs/classic","operation":"patch","entries":[{"id":source.location,"value":{"data":data}}]}))
	controller.settings.apply({"startup/show_setup":true})
	controller.settings.effective["startup/show_setup"] = true
	var selected: Dictionary = controller.select_folder(fixture.classic_source)
	check("complete composition prepares",true,controller.prepared_content.get("ok",false))
	if not controller.prepared_content.get("ok",false):
		observations.failure = {"reason":selected.get("reason"),"issues":selected.get("issues",[])}
		return terminal(fixture)
	check("actual content publication",true,controller.continue_to_menu("save" if fixture.fixture == "dungeon-context-v1" else "run").ok)
	await shell.get_tree().process_frame
	shell.session_shell.synchronize_startup()
	observations.publication = registry.timings.duplicate(true)
	observations.initial_startup_usec = shell.startup_elapsed_usec
	var core: RefCounted = shell.session_shell.core
	core.provider = preload("res://tests/controlled_session_provider.gd").new()
	check("controlled session lifecycle seam","Succeeded",core.request({"id":"assembly-session","mode":"new","origin":"","selection":{}}).kind)
	var owner: Node = shell.session_shell.dungeon_assembly
	check("normal shell composes LOC owner",true,owner != null)
	var input := request(owner,"packs/classic#"+source.location)
	var started: Dictionary = owner.begin(input)
	check("production request admitted",true,started.ok)
	if not started.ok:
		observations.failure = started
		return terminal(fixture)
	check("no partial projection",false,owner.projection(started.ticket).ok)
	var progress := {"ok":true,"kind":"staging"}
	while progress.kind == "staging":
		progress = owner.step(started.ticket)
		if not progress.ok: break
	check("all real required models stage",true,progress.ok)
	if not progress.ok:
		observations.failure = progress
		return terminal(fixture)
	var result: Dictionary = await owner.finish(started.ticket)
	check("real assembly succeeds",true,result.ok)
	if not result.ok:
		observations.failure = result
		return terminal(fixture)
	observations.assembly = owner.measurements.duplicate(true)
	source_layout_version = result.layout_version
	check("loose assembly annotation provenance","@loose",result.layout_provenance.winner.provider)
	check("source unused actions stay non-executable",0,result.pending_action_bindings.size())
	check("real door owner bindings remain pending",true,not result.pending_door_bindings.is_empty() and not result.owner_state_ready)
	check("real placed block count",source.placements.size(),result.occurrences.size())
	for p: Dictionary in source.placements:
		var occurrence: Array = result.occurrences.filter(func(o: Dictionary): return o.placement.id == p.id)
		check("source placement "+p.id,true,occurrence.size() == 1 and Layout.Common.equal_input(occurrence[0].placement.grid,p.grid))
		check("source block definition "+p.id,p.block,occurrence[0].definition.record)
		var expected_records: Array = p.records.map(func(r: Dictionary): return p.id+"/"+r.id)
		expected_records.sort()
		var actual_records: Array = occurrence[0].records.duplicate()
		actual_records.sort()
		check("source scoped record inventory "+p.id,true,Layout.Common.equal_input(expected_records,actual_records))
		var addresses := {}
		for r: Dictionary in p.records: addresses[int(r.address)] = r.id
		for record: Dictionary in p.records:
			if record.has("action") and record.action.kind != 0 and record.action.target > 0:
				check("source action binding "+p.id+"/"+record.id,p.id+"/"+addresses[int(record.action.target)],result.bindings[p.id+"/"+record.id].get("action_target",""))
			if not record.has("expected_bounds"): continue
			var actual: AABB = result.bindings[p.id+"/"+record.id].bounds
			check("independent model payload "+p.id+"/"+record.id,record.model_sha256,result.bindings[p.id+"/"+record.id].geometry_provenance.sha256)
			var lower := Frame.vector(record.expected_bounds[0])
			var upper := Frame.vector(record.expected_bounds[1])
			check("independent model bounds "+p.id+"/"+record.id,true,actual.position.distance_to(lower) < Frame.POSITION_TOLERANCE and actual.end.distance_to(upper) < Frame.POSITION_TOLERANCE)
			var probe: Dictionary = result.bindings[p.id+"/"+record.id].geometry_probe
			var normal: Vector3 = Frame.vector(record.first_plane_normal)
			observations.normal_error_max = maxf(observations.get("normal_error_max",0.0),normal.distance_to(probe.normal))
			var points_match := true
			for point: Vector3 in probe.triangle:
				points_match = points_match and record.first_plane_points.any(func(v: Array): return point.distance_to(Frame.vector(v)) < Frame.POSITION_TOLERANCE)
			if not observations.has("normal_probe") and normal.distance_to(probe.normal) >= 0.00001: observations.normal_probe = {"expected":normal,"actual":probe.normal,"error":normal.distance_to(probe.normal),"points_match":points_match,"cross_dot_normal":(probe.triangle[1]-probe.triangle[0]).cross(probe.triangle[2]-probe.triangle[0]).dot(normal)}
			check("independent model winding/normal "+p.id+"/"+record.id,true,points_match and normal.distance_to(probe.normal) < Frame.NORMAL_TOLERANCE and (probe.triangle[1]-probe.triangle[0]).cross(probe.triangle[2]-probe.triangle[0]).dot(normal) < 0)
	check("assembly does not certify destination",false,result.destination_ready)
	check("assembly does not certify owner state",false,result.owner_state_ready)
	check("assembly does not commit placement",false,result.placement_committed)
	check("assembly does not certify SAVE",false,result.save_compatible)
	await shell.get_tree().physics_frame
	await shell.get_tree().physics_frame
	var hit: Dictionary = owner.geometry_ray(result.ticket,Vector3(50,33,-16),Vector3(50,31,-16))
	check("committed production collision query",true,hit.ok and hit.found and absf(hit.position.y-32.0) < Frame.POSITION_TOLERANCE)
	check("collision query retains scoped record",true,hit.get("record",{}).get("placement") == "placement-00003")
	var query_started := Time.get_ticks_usec()
	var point_reads_ok := true
	for i in 1000:
		point_reads_ok = point_reads_ok and owner.readiness(result.ticket).ok and owner.binding(result.ticket,"placement-00003","record-00001").ok
	observations.point_queries = {"pairs":1000,"usec":Time.get_ticks_usec()-query_started}
	check("narrow readiness and binding queries",true,point_reads_ok)
	var detached: Dictionary = owner.binding(result.ticket,"placement-00003","record-00001")
	detached.binding.record.transform.position[0] = 999999
	check("narrow binding is detached",true,owner.binding(result.ticket,"placement-00003","record-00001").binding.record.transform.position[0] != 999999)
	check("declared source connection count",14,result.connections.size())
	if DisplayServer.get_name() != "headless": await render_review(owner,shell,fixture)
	var repeated: Dictionary = owner.begin(input)
	check("same request retains outcome",true,repeated.ok and repeated.kind == "assembled")
	await synthetic_checks(owner,fixture)
	await scaling_checks(owner,source)
	await lifecycle_checks(owner)
	await invalidation_checks(owner,controller.providers,fixture)
	write(str(fixture.sandbox).path_join("assembly-restart-expectations.json"),JSON.stringify({"layout_version":source_layout_version,"native_save_qualified":false}))
	check("remove loose annotation for clean restart",OK,DirAccess.remove_absolute(mods.root.path_join("Overrides/assembly.json")))
	owner.dispose()
	return terminal(fixture)

func synthetic_checks(owner: Node, _fixture: Dictionary) -> void:
	check("source point axis/scale",Vector3(1,-2,-3),Frame.point([40,80,120]))
	check("model fractional scale",true,Frame.model_point([256,512,768]).distance_to(Vector3(0.025,-0.05,-0.075)) < 0.000001)
	check("normal conversion",Vector3.UP,Frame.normal([0,-256,0]))
	check("independent quarter yaw",true,(Frame.pose(source_pose([0,0,0],[0,512,0])) * Vector3.RIGHT).distance_to(Vector3.FORWARD) < 0.000001)
	var original_request := request(owner,"packs/assembly.test#straight")
	var straight: Dictionary = await assemble(owner,original_request)
	check("native straight collision connection",true,straight.ok)
	if not straight.ok:
		observations.synthetic_failure = straight
		return
	var first: Dictionary = straight.bindings["alpha/floor"]
	var second: Dictionary = straight.bindings["beta/floor"]
	check("repeated definition retained",true,first.definition == second.definition)
	check("repeated record identities distinct",true,first.identity != second.identity)
	check("repeated live handles distinct",true,first.instance != second.instance)
	check("repeated material resources distinct",true,not first.geometry_probe.material_instances.is_empty() and first.geometry_probe.material_instances != second.geometry_probe.material_instances)
	check("repeated immutable geometry is shared",first.geometry_probe.immutable_shape,second.geometry_probe.immutable_shape)
	check("repeated owner state slots distinct",true,first.state_slot.identity != second.state_slot.identity)
	var definition: Dictionary = owner.layouts.decode_block(owner.registry,"packs/assembly.test#corridor")
	check("shared DATA definition remains unchanged",0,definition.definition.records[0].transform.position[0])
	var completed: Dictionary = await owner.finish(straight.ticket)
	check("repeat finish retains successful assembly",true,completed.ok and completed.bindings["alpha/floor"].instance == first.instance)
	straight.bindings["alpha/floor"].record.transform.position[0] = 999
	check("detached projection cannot mutate owner",0,owner.projection(straight.ticket).bindings["alpha/floor"].record.transform.position[0])
	check("detached repeated record independent",0,second.record.transform.position[0])
	var changed := original_request.duplicate(true)
	changed.layout = "packs/assembly.test#rotated"
	check("request identity cannot retarget","invalid",owner.begin(changed).kind)
	var rotated: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#rotated"))
	check("quarter rotated native seam",true,rotated.ok)
	if not rotated.ok: observations.rotated_failure = rotated
	var retained_ticket: Dictionary = rotated.ticket if rotated.ok else straight.ticket
	var vertical: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#vertical"))
	check("vertical stair collision seam",true,vertical.ok)
	if not vertical.ok: observations.vertical_failure = vertical
	else: retained_ticket = vertical.ticket
	for vector in [["broken","broken_connection"],["missing-connector","missing"],["late-resource","record_not_found"],["unsupported-axis","unsupported"],["missing-support","unsupported_connection"],["narrow-support-gap","unsupported_connection"],["required-state","provider_pending"],["conflict","door_conflict"],["required-reference","provider_pending"],["required-action","provider_pending"],["required-save","provider_pending"],["missing-binding","missing"],["unsupported-mechanism","unsupported_connection"]]:
		var failed: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#"+vector[0]))
		check("reject "+vector[0],false,failed.ok)
		check("classify "+vector[0],vector[1],failed.kind)
		check("preserve destination after "+vector[0],true,owner.projection(retained_ticket).ok)
		check("release staging resources after "+vector[0],1,owner.get_child_count())
		if vector[0] in ["late-resource","unsupported-axis"]: check("earlier block staged before "+vector[0],1,failed.get("staged_blocks",-1))
	for kind in ["intentional-pair","duplicate"]:
		var doors: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#"+kind))
		check("door relationship "+kind,true,doors.ok)
		if doors.ok:
			check("suppressed count "+kind,2 if kind == "duplicate" else 0,doors.suppressed.size())
			await owner.get_tree().physics_frame
			await owner.get_tree().physics_frame
			var door_hit: Dictionary = owner.geometry_ray(doors.ticket,Vector3(0.6,1,-1),Vector3(0.6,1,-2))
			check("retained door collision "+kind,true,door_hit.ok and door_hit.found and door_hit.record.record in ["door-a","door-b"])
			retained_ticket = doors.ticket
	var retained: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#retained-reference"))
	check("retained structural reference validates",true,retained.ok)
	if retained.ok: retained_ticket = retained.ticket
	for reason in ["cancel","stale-session","stale-content"]:
		var input := request(owner,"packs/assembly.test#straight")
		if reason == "stale-content": input.content_ticket += 1
		if reason == "stale-session": input.session = "obsolete"
		var staged: Dictionary = owner.begin(input)
		if reason == "cancel":
			check("first block stages before cancel",true,owner.step(staged.ticket).ok)
			check("cancel discards staged world","cancelled",owner.cancel(staged.ticket).kind)
			check("late completion after cancel","stale",(await owner.finish(staged.ticket)).kind)
		else: check("reject "+reason,"stale",staged.kind)
		check("preserve destination after "+reason,true,owner.projection(retained_ticket).ok)
	var retry: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#straight"))
	check("retry after failures succeeds",true,retry.ok)
	if retry.ok: last_live_ticket = retry.ticket.duplicate(true)
	check("superseded success has retained outcome","retained",owner.begin(original_request).kind)
	check("unqualified real location is not substituted","unsupported",owner.begin(request(owner,"packs/classic#place-00016")).kind)
	var scoped: Dictionary = owner.begin(request(owner,"packs/assembly.test#straight"))
	owner.step(scoped.ticket)
	var wrong_ticket: Dictionary = scoped.ticket.duplicate(true)
	wrong_ticket.serial -= 1
	check("wrong-ticket cancellation rejects","stale",owner.cancel(wrong_ticket).kind)
	check("valid staging survives wrong-ticket cancellation",true,owner.step(scoped.ticket).ok)
	owner.cancel(scoped.ticket)
	var late: Dictionary = owner.begin(request(owner,"packs/assembly.test#straight"))
	owner.step(late.ticket)
	owner.step(late.ticket)
	owner.call_deferred("cancel",late.ticket)
	check("cancellation during physics validation","stale",(await owner.finish(late.ticket)).kind)
	check("late cancellation retains current destination",true,owner.readiness(last_live_ticket).ok)
	check("late cancellation releases staging world",1,owner.get_child_count())

func capacity_checks(owner: Node) -> void:
	# Run this late: Jolt caches settings while creating spaces. A fresh process
	# independently verifies the unchanged normal configuration afterward.
	var body_limit: int = int(ProjectSettings.get_setting(owner.BODY_LIMIT_SETTING))
	ProjectSettings.set_setting(owner.BODY_LIMIT_SETTING,4)
	var capacity: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#intentional-pair"))
	ProjectSettings.set_setting(owner.BODY_LIMIT_SETTING,body_limit)
	check("physics capacity rejects required late body","physics_capacity",capacity.kind)
	check("physics capacity failure occurs after earlier block",1,capacity.get("staged_blocks",-1))
	check("physics capacity reports configured limit",4,capacity.get("physics_body_limit",-1))
	check("physics capacity reports admitted bodies",4,capacity.get("physics_bodies",-1))
	check("physics capacity preserves current destination",true,owner.readiness(last_live_ticket).ok)
	check("physics capacity releases staged bodies",1,owner.get_child_count())

func render_review(owner: Node, shell: Control, fixture: Dictionary) -> void:
	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	viewport.size = Vector2i(1200,800)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	shell.add_child(viewport)
	owner.reparent(viewport)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(0.055,0.075,0.10)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.7
	viewport.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45,-30,0)
	viewport.add_child(light)
	var camera := Camera3D.new()
	camera.far = 600
	viewport.add_child(camera)
	camera.current = true
	for view in [["overview",Vector3(180,180,150),Vector3(50,20,-25)],["seam-lower",Vector3(48,33.4,-16),Vector3(54,33.4,-16)],["seam-upper",Vector3(48,14.2,-35.2),Vector3(54,14.2,-35.2)]]:
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL if view[0] == "overview" else Camera3D.PROJECTION_PERSPECTIVE
		camera.size = 190
		camera.position = view[1]
		camera.look_at(view[2])
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := viewport.get_texture().get_image()
		var path := str(fixture.sandbox).path_join("assembly-"+view[0]+".png")
		check("rendered capture "+view[0],OK,image.save_png(path))
		var colors := {}
		for y in range(0,image.get_height(),20):
			for x in range(0,image.get_width(),20): colors[image.get_pixel(x,y).to_rgba32()] = true
		check("rendered geometry visible "+view[0],true,colors.size() > 4)
	owner.reparent(shell)
	viewport.free()

func lifecycle_checks(owner: Node) -> void:
	var core: RefCounted = owner.core
	var provider: RefCounted = core.provider
	var source_scope: String = core.snapshot().session
	var original_live := last_live_ticket.duplicate(true)
	provider.hold_preflight = true
	check("CORE controlled cancellable preflight","pending",core.request({"id":"assembly-preflight-cancel","mode":"new","origin":source_scope,"selection":{}}).kind)
	var core_ticket: Dictionary = core.ticket()
	var input := request(owner,"packs/assembly.test#straight")
	input.core_ticket = core_ticket
	input.session = core_ticket.scope
	var prepared: Dictionary = await assemble(owner,input)
	check("CORE preflight assembles isolated geometry",true,prepared.ok)
	if not prepared.ok:
		observations.lifecycle_failure = prepared
		core.cancel(core_ticket)
		return
	check("preflight geometry is not activated",false,owner.readiness(prepared.ticket).activated)
	check("preflight cannot activate destination","pending",owner.activate(prepared.ticket).kind)
	check("explicit prepared cancellation releases geometry","cancelled",owner.cancel(prepared.ticket).kind)
	input = request(owner,"packs/assembly.test#straight")
	input.core_ticket = core_ticket
	input.session = core_ticket.scope
	prepared = await assemble(owner,input)
	check("CORE preparation retries without leaked geometry",true,prepared.ok and owner.get_child_count() == 2)
	check("CORE cancellation accepted",true,core.cancel(core_ticket))
	check("cancelled preparation cannot publish","stale",owner.projection(prepared.ticket).kind)
	check("cancel preserves previous geometry",true,owner.projection(original_live).ok)
	check("cancel releases preparation viewport",1,owner.get_child_count())
	check("CORE controlled replacement preflight","pending",core.request({"id":"assembly-preflight-activate","mode":"new","origin":source_scope,"selection":{}}).kind)
	core_ticket = core.ticket()
	input = request(owner,"packs/assembly.test#rotated")
	input.core_ticket = core_ticket
	input.session = core_ticket.scope
	prepared = await assemble(owner,input)
	check("replacement preparation assembled",true,prepared.ok)
	provider.hold_readiness = true
	core.complete_preflight(core_ticket,{"ok":true})
	check("CORE retains discard confirmation","confirmation",core.snapshot().phase)
	check("prepared geometry remains scoped during confirmation",true,owner.readiness(prepared.ticket).ok)
	core.confirm(core_ticket,true)
	check("CORE reaches initialization","initializing",core.snapshot().phase)
	check("prepared geometry survives source retirement",true,owner.projection(prepared.ticket).ok)
	check("original CORE ticket activates geometry",true,owner.activate(prepared.ticket).ok)
	check("geometry activation retry is idempotent",true,owner.activate(prepared.ticket).ok and owner.get_child_count() == 1)
	check("activation still cannot certify destination",false,owner.readiness(prepared.ticket).destination_ready)
	core.complete_readiness(core.ticket(),{"ok":true,"services":provider.bindings(),"death_authority":provider})
	check("geometry remains scoped after CORE terminal",true,owner.readiness(prepared.ticket).ok)
	check("previous scope cannot query new geometry","stale",owner.readiness(original_live).kind)
	var return_intent := {"id":"assembly-return","mode":"return","origin":core.snapshot().session}
	check("CORE controlled return confirmation","pending",core.request(return_intent).kind)
	core.confirm(core.ticket(),true)
	check("CORE controlled return","Succeeded",core.request(return_intent).kind)
	check("retired geometry is unavailable","stale",owner.readiness(prepared.ticket).kind)
	check("retirement releases every assembly node",0,owner.get_child_count())
	observations.memory_static_bytes = OS.get_static_memory_usage()
	observations.memory_peak_bytes = OS.get_static_memory_peak_usage()

func invalidation_checks(owner: Node, providers: RefCounted, fixture: Dictionary) -> void:
	owner.core.provider.hold_preflight = false
	owner.core.provider.hold_readiness = false
	check("controlled session for withdrawal checks","Succeeded",owner.core.request({"id":"assembly-withdrawal-session","mode":"new","origin":"","selection":{}}).kind)
	var staged: Dictionary = owner.begin(request(owner,"packs/assembly.test#straight"))
	check("real source withdrawal stages earlier block",true,owner.step(staged.ticket).ok)
	providers.classic.dispose()
	check("real provider withdrawal rejects late block","stale",owner.step(staged.ticket).kind)
	check("real provider withdrawal releases staging",0,owner.get_child_count())
	var prepared: Dictionary = providers.check_classic(fixture.classic_source)
	check("explicit same-source recovery prepares",true,prepared.ok)
	check("explicit same-source recovery activates",true,providers.activate_classic(prepared).ok)
	var recovered: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#straight"))
	check("source recovery retry assembles",true,recovered.ok)
	if recovered.ok: last_live_ticket = recovered.ticket.duplicate(true)
	await capacity_checks(owner)
	staged = owner.begin(request(owner,"packs/assembly.test#straight"))
	owner.step(staged.ticket)
	providers.definitions.dispose()
	check("actual publication retirement rejects staging","stale",owner.step(staged.ticket).kind)
	check("retired content cannot project readiness","stale",owner.readiness(recovered.ticket).kind)
	check("content withdrawal discards only staged nodes",1,owner.get_child_count())

func scaling_checks(owner: Node, source: Dictionary) -> void:
	# Performance-only disconnected authored spaces; no traversal/entry claim.
	var scaled: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#scaling"))
	check("scaled real-block composition assembles",true,scaled.ok)
	if not scaled.ok:
		observations.scaling_failure = scaled
		return
	last_live_ticket = scaled.ticket.duplicate(true)
	observations.scaling = owner.measurements.duplicate(true)
	observations.scaling.memory_static_bytes = OS.get_static_memory_usage()
	observations.scaling.memory_peak_bytes = OS.get_static_memory_peak_usage()
	check("scaled placed occurrence count",64,scaled.occurrences.size())
	check("scaled reusable block decodes once",1,owner.measurements.unique_block_decodes)
	var model_ids := {}
	var model_count := 0
	for record: Dictionary in source.placements[2].records:
		if int(record.kind) == 1:
			model_ids[int(record.model)] = true
			model_count += 1
	check("scaled resource decodes match unique source models",model_ids.size(),owner.measurements.unique_resource_decodes)
	check("scaled geometry builds match unique source models",model_ids.size(),owner.measurements.unique_geometry_builds)
	check("scaled repeated model instances match source count",model_count*64,owner.measurements.geometry_instances)
	var started := Time.get_ticks_usec()
	var valid := true
	for i in 1000: valid = valid and owner.readiness(scaled.ticket).ok and owner.binding(scaled.ticket,"scale-63","record-00001").ok
	observations.scaling.query_pairs = 1000
	observations.scaling.query_usec = Time.get_ticks_usec()-started
	check("scaled narrow queries remain available",true,valid)
	check("scaled binding stays placement scoped","scale-63",owner.binding(scaled.ticket,"scale-63","record-00001").binding.identity.placement)
	check("scaled composition remains geometry only",false,scaled.destination_ready)
	await owner.get_tree().physics_frame
	await owner.get_tree().physics_frame
	var physical: Dictionary = owner.geometry_ray(scaled.ticket,Vector3(498,33,-464),Vector3(498,31,-464))
	check("scaled last occurrence has real collision",true,physical.ok and physical.found and physical.record.placement == "scale-63" and absf(physical.position.y-32.0) < Frame.POSITION_TOLERANCE)

func terminal(fixture: Dictionary) -> Dictionary:
	var ok := checks.all(func(c: Dictionary): return c.expected == c.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"fixture":fixture.fixture,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"inputs":fixture.inputs,"observations":observations}
