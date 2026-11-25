extends RefCounted
## All 25 original records in real LOC blocks, independent source-plane samples.
const Layout = preload("res://scripts/data/layout_inputs.gd")
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")
const Policy = preload("res://scripts/data/steep_connector_policy.gd")

static func publish(t: RefCounted, controller: RefCounted) -> void:
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/connector_source_observation.json"))
	var blocks := {}
	for row: Dictionary in source.source_occurrences: blocks[row.block] = true
	var placements := []
	for id: String in blocks:
		var index := placements.size()
		placements.append({"id":id,"context":"dungeon","block":"packs/classic#"+id,"transform":preload("res://scripts/data/layout_formats.gd").transform([40000+(index%4)*2560,0,(index/4)*2560],[0,0,0])})
	var value := Layout.value("layout",{"mode":"authored","location":"packs/classic#place-00032","placements":placements,"assembly":{"schema":"dungeon-assembly-declarations-v1","connections":[],"door_relationships":[],"required_bindings":[]}})
	t.write(controller.mods.root.path_join("Mods/Ground/connector-layout.json"),JSON.stringify({"domain":Layout.DOMAIN,"path":"packs/ground.tuning","operation":"add","entries":[{"id":"source-connectors","value":value}]}))

func run(t: RefCounted) -> void:
	var owner: Node = t.shell_ref.session_shell.dungeon_assembly
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/connector_source_observation.json"))
	var request := {"id":"connector-source-blocks","requester":"connector-fixture","layout":"packs/ground.tuning#source-connectors","preparation":"connector-source-blocks","session":t.scope,"core_ticket":{},"content_ticket":owner.registry.content_ticket()}
	var begin: Dictionary = owner.begin(request)
	t.check("connector real LOC source request admitted",true,begin.get("ok",false))
	if not begin.get("ok",false): return
	var progress := {"ok":true,"kind":"staging"}
	while progress.kind == "staging":
		progress = owner.step(begin.ticket)
		if not progress.ok: break
	var assembled: Dictionary = await owner.finish(begin.ticket) if progress.ok else progress
	t.check("connector all sixteen source blocks assemble",true,assembled.get("ok",false))
	if not assembled.get("ok",false):
		print("CONNECTOR ASSEMBLY ",assembled)
		return
	await owner.get_tree().physics_frame
	await owner.get_tree().physics_frame
	t.shell_ref.session_shell.focus_changed(true)
	var space: PhysicsDirectSpaceState3D = owner.placement_space(begin.ticket)
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.8
	var measurements := []
	var endpoint_count := 0
	var all_bound := true
	var all_clear := true
	var all_swept := true
	var all_other_faces_restricted := true
	var all_review_spawns_clear := true
	var blocked_endpoints := []
	var all_endpoints_supported := true
	var first_hit := {}
	var observed_entrance_steps := []
	var entrance_step_heights_match := true
	for row: Dictionary in source.source_occurrences:
		var binding: Dictionary = owner.binding(begin.ticket,row.block,row.record).binding
		var model: Dictionary = source.candidates.filter(func(v: Dictionary): return v.model == row.model)[0]
		var face: Dictionary = model.geometry[int(row.floor_plane)]
		var pose: Transform3D = binding.transform
		var points: Array[Vector3] = []
		for p: Array in face.points_source_metres: points.append(Frame.AXES*Frame.vector(p))
		var low := points[0]
		var high := points[0]
		for p: Vector3 in points:
			if p.y < low.y: low = p
			if p.y > high.y: high = p
		low.x = 0
		high.x = 0
		# Cross product from actual independently decoded vertices, rather than
		# rounded original lighting normals or the runtime triangle-plane table.
		var normal := (points[1]-points[0]).cross(points[2]-points[0]).normalized()
		if normal.y < 0: normal = -normal
		normal = pose.basis*normal
		var row_bound := true
		var row_clear := true
		var row_swept := true
		var prior := Vector3.ZERO
		for index in 11:
			var point: Vector3 = pose*low.lerp(high,0.02+index*0.096)
			var ray := PhysicsRayQueryParameters3D.create(point+normal*0.03,point-normal*0.03)
			var hit := space.intersect_ray(ray)
			if first_hit.is_empty() and not hit.is_empty(): first_hit = hit.duplicate()
			row_bound = row_bound and not hit.is_empty() and owner.ground_surface(begin.ticket,hit)
			var centre: Vector3 = point+normal*0.31+Vector3.UP*0.6
			var query := PhysicsShapeQueryParameters3D.new()
			query.shape = capsule
			query.margin = 0.001
			query.transform.origin = centre
			row_clear = row_clear and space.intersect_shape(query,1).is_empty()
			if index > 0:
				query.transform.origin = prior
				query.motion = centre-prior
				row_swept = row_swept and space.cast_motion(query)[0] >= 1.0
			prior = centre
		var other: Dictionary = model.geometry[0]
		var other_point := Vector3.ZERO
		for p: Array in other.points_source_metres: other_point += Frame.AXES*Frame.vector(p)/other.points_source_metres.size()
		var other_normal: Vector3 = pose.basis*Frame.normal(other.normal_source)
		var other_hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(pose*other_point+other_normal*0.03,pose*other_point-other_normal*0.03))
		all_other_faces_restricted = all_other_faces_restricted and not other_hit.is_empty() and not owner.ground_surface(begin.ticket,other_hit)
		all_bound = all_bound and row_bound
		all_clear = all_clear and row_clear
		all_swept = all_swept and row_swept
		var outer_z := low.z
		for polygon: Dictionary in model.geometry:
			for p: Array in polygon.points_source_metres: outer_z = maxf(outer_z,-float(p[2]))
		var endpoints := []
		var endpoint_index := 0
		var spawn_query := PhysicsShapeQueryParameters3D.new()
		spawn_query.shape = capsule
		spawn_query.margin = 0.001
		spawn_query.transform.origin = pose*Vector3(0,low.y,low.z+1.0)+Vector3.UP*0.91
		var review_spawn_clear := space.intersect_shape(spawn_query,1).is_empty()
		all_review_spawns_clear = all_review_spawns_clear and review_spawn_clear
		for local: Vector3 in [Vector3(0,low.y,outer_z+0.4),high+Vector3.FORWARD*0.4]:
			var sole: Vector3 = pose*local
			var endpoint_hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(sole+Vector3.UP*0.3,sole+Vector3.DOWN*3.0))
			var query := PhysicsShapeQueryParameters3D.new()
			query.shape = capsule
			query.margin = 0.001
			var fitted: Vector3 = sole+Vector3.UP*0.91
			var seam_change: Variant = "missing within 3m"
			if not endpoint_hit.is_empty() and endpoint_hit.normal.y > 0:
				fitted.y = endpoint_hit.position.y+0.6+0.301/endpoint_hit.normal.y+0.009
				var port: Vector3 = pose*(Vector3(0,low.y,outer_z) if endpoint_index == 0 else high)
				seam_change = endpoint_hit.position.y-(endpoint_hit.normal.x*(port.x-endpoint_hit.position.x)+endpoint_hit.normal.z*(port.z-endpoint_hit.position.z))/endpoint_hit.normal.y-port.y
			query.transform.origin = fitted
			if (seam_change is float or seam_change is int) and absf(seam_change) > Frame.POSITION_TOLERANCE:
				observed_entrance_steps.append(row.block+"/"+row.record+"/"+str(endpoint_index))
				entrance_step_heights_match = entrance_step_heights_match and absf(float(seam_change)+0.3) <= Frame.POSITION_TOLERANCE
			var overlaps := space.intersect_shape(query,16)
			var clear := overlaps.is_empty()
			var obstructions := []
			for overlap: Dictionary in overlaps:
				var key: String = owner._hit_record(overlap.collider,overlap.shape)
				var parts := key.split("/")
				if parts.size() == 2:
					var obstruction: Dictionary = owner.binding(begin.ticket,parts[0],parts[1])
					obstructions.append({"key":key,"record":obstruction.get("binding",{}).get("record",{}),"model_sha256":obstruction.get("binding",{}).get("geometry_provenance",{}).get("sha256","")})
			var crouched := CapsuleShape3D.new()
			crouched.radius = 0.3
			crouched.height = 0.9
			query.shape = crouched
			query.transform.origin = fitted-Vector3.UP*0.45
			var crouched_clear := space.intersect_shape(query,1).is_empty()
			if not clear:
				var keys := []
				var models := []
				var hashes := []
				for obstruction: Dictionary in obstructions:
					if not keys.has(obstruction.key): keys.append(obstruction.key)
					if not models.has(obstruction.record.get("model_id",-1)): models.append(obstruction.record.get("model_id",-1))
					if not hashes.has(obstruction.model_sha256): hashes.append(obstruction.model_sha256)
				blocked_endpoints.append({"source":row.block+"/"+row.record,"end":endpoint_index,"obstructions":keys,"models":models,"model_hashes":hashes,"crouched_clear":crouched_clear})
			all_endpoints_supported = all_endpoints_supported and not endpoint_hit.is_empty() and endpoint_hit.normal.y >= cos(deg_to_rad(80))
			endpoints.append({"sole":str(sole),"fitted_body_centre":str(fitted),"clear":clear,"crouched_clear":crouched_clear,"obstructions":obstructions,"support_found":not endpoint_hit.is_empty(),"seam_height_change":seam_change,"support_height_difference":endpoint_hit.position.y-sole.y if not endpoint_hit.is_empty() else "missing within 3m","support_normal":str(endpoint_hit.get("normal",Vector3.ZERO)),"support_binding":owner.geometry_ray(begin.ticket,sole+Vector3.UP*0.3,sole+Vector3.DOWN*3.0).get("record",{})})
			endpoint_count += 1
			endpoint_index += 1
		measurements.append({"block":row.block,"record":row.record,"model":row.model,"samples":11,"bound":row_bound,"clear":row_clear,"swept":row_swept,"review_spawn_clear":review_spawn_clear,"endpoints":endpoints})
	t.check("connector all 25 physical floor face bindings",true,all_bound)
	t.check("connector all 25 full standing capsule interiors clear",true,all_clear)
	t.check("connector all 25 full capsule interior routes clear",true,all_swept)
	t.check("connector same models walls remain restricted",true,all_other_faces_restricted)
	t.check("connector stale ticket cannot qualify",false,owner.ground_surface({},{}))
	var malformed_hit := first_hit.duplicate()
	malformed_hit.shape = 2147483647
	t.check("connector malformed physical shape index rejects",false,owner.ground_surface(begin.ticket,malformed_hit))
	malformed_hit = first_hit.duplicate()
	malformed_hit.normal = "up"
	t.check("connector malformed physical normal rejects",false,owner.ground_surface(begin.ticket,malformed_hit))
	t.check("connector all fifty entrance and exit surroundings inspected",50,endpoint_count)
	t.check("connector all 25 source review spawn volumes clear",true,all_review_spawns_clear)
	t.check("connector known adjacent ordinary stair obstruction retained",true,Layout.Common.equal_input(source.known_endpoint_obstructions,blocked_endpoints))
	t.check("connector all fifty endpoint support surfaces found",true,all_endpoints_supported)
	t.check("connector four original 0.30m entrance steps retained",true,observed_entrance_steps == source.known_entrance_steps and entrance_step_heights_match)
	t.measurements.append({"case":"all connector source block interiors","placements":measurements,"assembly":owner.measurements.duplicate(true),"assembled_location_routes_qualified":false})
	t.shell_ref.session_shell.focus_changed(true)
