extends "res://scripts/loc/dungeon_assembly.gd"
## RMB and dungeon assembly share one transactional LOC owner. No MOVE pose.
const RMB_SIDE = 4096
const PROFILE = "rmb-assembly-metres-v1"
const GROUND_UV_PROFILE = "rmb-ground-top-left-uv-v1"
var _directories := {}

func _request_extra(request: Dictionary) -> int:
	return int(request.has("area"))

func _select_placements(input: Dictionary, request: Dictionary) -> Dictionary:
	if not request.has("area"): return super._select_placements(input,request)
	var area: Variant = request.area
	if not area is Dictionary or area.get("kind") not in ["exterior","interior"]: return _result("invalid","Explicit exterior or scoped interior area required.")
	if area.kind == "exterior" and area.size() != 1: return _result("invalid","Exterior area has only kind.")
	if area.kind == "interior":
		if area.size() != 4: return _result("invalid","Interior requires placement, building and independent instance identity.")
		for field in ["placement","building","instance"]:
			if not preload("res://scripts/mod/package_library.gd").valid_id(area.get(field)): return _result("invalid","Stable scoped interior identity required.")
	var selected: Array = input.data.placements.filter(func(p: Dictionary): return p.context == "exterior" or (p.context == "interior" and area.kind == "interior"))
	if area.kind == "interior": selected = selected.filter(func(p: Dictionary): return p.id == area.placement)
	if selected.is_empty(): return _result("missing","Requested RMB placement is absent; no substitute destination.")
	if not input.data.has("location_assembly"): return _result("unsupported","Required RMB assembly profile unavailable.")
	# Dungeon context/arrival declarations never qualify an exterior/interior.
	input.data.erase("context")
	input.data.erase("arrivals")
	return {"ok":true,"placements":selected,"assembly":{"schema":"dungeon-assembly-declarations-v1","connections":[],"door_relationships":[],"required_bindings":input.data.location_assembly.required_bindings.duplicate(true)}}

func _rmb() -> bool:
	return not _stage.is_empty() and _stage.ticket.request.has("area")

func _stage_block(block: Dictionary, p: Dictionary) -> Dictionary:
	if not _rmb(): return super._stage_block(block,p)
	if block.definition.format != "RMB": return _result("unsupported","RMB area requires RMB inputs.")
	var area: Dictionary = _stage.ticket.request.area
	if area.kind == "interior" and not block.definition.building_inputs.has(area.building): return _result("missing","Required interior building absent.")
	if not _stage.has("location_doors"):
		_stage.location_doors = {}
		_stage.location_action_doors = {}
		_stage.location_buildings = {}
		_stage.location_markers = {}
		_stage.palette = {"material_slots":{}}
	return {"ok":true}

func _placement_pose(p: Dictionary) -> Transform3D:
	if not _rmb(): return super._placement_pose(p)
	# An exterior occurrence locates the building in the settlement, never its
	# interior. Authored interior occurrences instead place pieces in that space.
	if _stage.ticket.request.area.kind == "interior" and p.context == "exterior": return Transform3D.IDENTITY
	if p.has("transform"): return Frame.pose(p.transform)
	return Transform3D(Basis.IDENTITY,Frame.point([int(p.grid[0])*RMB_SIDE,0,int(p.grid[1])*RMB_SIDE]))

static func building_pose(building: Dictionary, classic_source: bool) -> Transform3D:
	var pose: Dictionary = building.transform.duplicate(true)
	if classic_source: pose.position[2] = RMB_SIDE-int(pose.position[2])
	return Frame.pose(pose)

func _records(block: Dictionary, p: Dictionary) -> Array:
	if not _rmb(): return super._records(block,p)
	var area: Dictionary = _stage.ticket.request.area
	return block.definition.records.filter(func(r: Dictionary): return r.get("record_context","exterior") == area.kind and (area.kind == "exterior" or r.get("building_id","") == area.building))

func _record_pose(record: Dictionary, block: Dictionary, p: Dictionary, resource: Dictionary = {}) -> Transform3D:
	if not _rmb(): return super._record_pose(record,block,p,resource)
	var result := Frame.pose(record.transform)
	var area: Dictionary = _stage.ticket.request.area
	if area.kind == "exterior" and block.definition.get("mode") != "authored" and not record.has("building_id"):
		# RMBLayout.AddProps uses a different block-local origin from building
		# models. The -4 source-unit prop offset is a documented DFU baseline.
		result.origin += Vector3(0,-4*Frame.CLASSIC_METRES,-RMB_SIDE*Frame.CLASSIC_METRES)
	if area.kind == "exterior" and record.has("building_id"):
		var parent := building_pose(block.definition.building_inputs[record.building_id],block.definition.get("mode") != "authored")
		if block.definition.get("mode") != "authored" and record.type in ["flat","person"]:
			# Source exterior flat coordinates already encode their orientation;
			# RMBLayout.AddBlockFlats adds the parent translation without yaw.
			result.origin += parent.origin
		else: result = parent * result
	# DFU Interior.AddModels: type-3 props use encoded positive Y, bottom aligned.
	if area.kind == "interior" and block.definition.get("mode") != "authored" and record.type == "model" and record.get("object_type",0) == 3 and resource.has("value"):
		var source: Dictionary = resource.value.projection()
		var bottom := INF
		for point: Array in source.points_source: bottom = minf(bottom,Frame.model_point(point).y)
		result.origin.y = float(record.transform.position[1])*Frame.CLASSIC_METRES-bottom
	return result

func _geometry_record(record: Dictionary) -> bool:
	return record.type in ["model","door"] if _rmb() else super._geometry_record(record)

func _binding_identity(p: Dictionary, record: Dictionary) -> Dictionary:
	var identity := super._binding_identity(p,record)
	if _rmb():
		identity.building = record.get("building_id","")
		identity.interior = _stage.ticket.request.area.get("instance","")
	return identity

func _after_record(binding: Dictionary, resource: Dictionary, p: Dictionary) -> Dictionary:
	if not _rmb(): return super._after_record(binding,resource,p)
	var r: Dictionary = binding.record
	binding.area = _stage.ticket.request.area.duplicate(true)
	binding.composition_profile = PROFILE
	binding.building = r.get("building_id","")
	if r.type == "door":
		_stage.location_action_doors[record_key(p.id,r.id)] = {"identity":binding.identity.duplicate(true),"record":r.duplicate(true),"transform":binding.transform,"gameplay_owner_ready":false}
	if not resource.has("value"): return {"ok":true} # Replacement needs explicit qualified regions.
	var source: Dictionary = resource.value.projection()
	for plane: Dictionary in source.planes:
		var archive := int(plane.texture_archive)
		var base_archive := archive % 100 if archive > 100 and archive not in [331,156] else archive
		if base_archive not in [74,56,95] and not (archive == 331 and plane.texture_record > 0): continue
		var id := "%s/%s/plane-%d" % [p.id,r.id,plane.source_plane]
		var triangles := PackedVector3Array()
		for at: int in plane.triangles:
			triangles.append(binding.transform * Frame.model_point(source.points_source[plane.point_indices[at]]))
		_stage.location_doors[id] = {"id":id,"identity":{"layout":_stage.input.identity.duplicate(true),"placement":p.id,"building":binding.building,"record":r.id,"plane":int(plane.source_plane),"interior":_stage.ticket.request.area.get("instance","")},"triangles":triangles,"normal":(binding.transform.basis*Frame.normal(plane.normal_source)).normalized(),"binding_ready":false,"destination_ready":false,"provenance":{"model":source.provenance.duplicate(true),"plane":plane.position,"classification":"dfu-static-door-texture-v1"}}
	return {"ok":true}

func _after_block(block: Dictionary, p: Dictionary, placed: Node3D) -> Dictionary:
	if not _rmb(): return super._after_block(block,p,placed)
	var area: Dictionary = _stage.ticket.request.area
	for building: Dictionary in block.definition.building_inputs.values():
		if area.kind == "interior" and building.id != area.building: continue
		var key := record_key(p.id,building.id)
		_stage.location_buildings[key] = {"id":key,"identity":{"location":_stage.input.data.location,"layout":_stage.input.identity.duplicate(true),"placement":p.id,"building":building.id},"template":{"block":block.identity.duplicate(true),"building":building.id},"metadata":building.metadata.duplicate(true),"transform":placed.transform*building_pose(building,block.definition.get("mode") != "authored"),"interior_instance":area.get("instance",""),"service_binding_ready":false,"provenance":{"definition":block.identity.duplicate(true),"winner":block.winner.duplicate(true),"contributors":block.contributors.duplicate(true)}}
		_stage.location_buildings[key].exterior_parent_transform = _stage.location_buildings[key].transform
		if area.kind == "interior": _stage.location_buildings[key].transform = placed.transform
	for r: Dictionary in _records(block,p):
		if not r.get("marker_purpose","").is_empty() or r.has("marker_roles"):
			var key := record_key(p.id,r.id)
			_stage.location_markers[key] = {"identity":_stage.bindings[key].identity.duplicate(true),"interior":area.get("instance",""),"building":r.get("building_id",""),"roles":_marker_roles(r,area.kind),"transform":_stage.bindings[key].transform,"binding_ready":false,"record":r.duplicate(true)}
	if area.kind == "interior":
		if not _records(block,p).any(func(r: Dictionary): return r.type == "model"): return _result("missing","Interior has no required models.")
		return {"ok":true}
	return _ground(block,p,placed)

static func _marker_roles(record: Dictionary, context: String) -> Array:
	if record.has("marker_roles"): return record.marker_roles.duplicate()
	if record.get("texture",{}).get("archive",-1) == 199:
		var code := int(record.texture.record)
		if context == "interior":
			if code == 4: return ["rest"]
			if code == 8: return ["entry"]
		elif code == 8: return ["exterior-arrival"]
	return [record.get("marker_purpose","editor-other")]

func _ground(block: Dictionary, p: Dictionary, placed: Node3D) -> Dictionary:
	var ground: Dictionary = block.definition.get("ground",block.definition.get("structure",{}).get("ground",{}))
	var raw: PackedByteArray = ground.tiles if ground.get("tiles") is PackedByteArray else str(ground.get("tiles","")).hex_decode()
	if raw.size() != 256: return _result("missing","Required complete RMB ground tiles absent.")
	if _stage.body_nodes.size() >= _stage.body_limit: return _result("physics_capacity","Required ground exceeds Jolt body capacity.")
	if not _stage.has("ground_cache"): _stage.ground_cache = {}
	var archive: int = _stage.input.data.location_assembly.ground_archive
	var cache_key := Hash.digest([raw,archive])
	if not _stage.ground_cache.has(cache_key):
		var groups := {}
		var probes: Array = []
		var points := PackedVector3Array()
		for z in 16:
			for x in 16:
				var tile := int(raw[z*16+x])
				var record := tile&63
				if record >= 56: record = 2 # DFU editor-marker grass baseline.
				if not groups.has(record): groups[record] = {"vertices":PackedVector3Array(),"uv":PackedVector2Array()}
				var vertices := PackedVector3Array()
				var uv := PackedVector2Array()
				var corners := [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)]
				for index in [0,2,1,0,3,2]:
					var corner: Vector2 = corners[index]
					vertices.append(Vector3((x+corner.x)*256.0*Frame.CLASSIC_METRES,-Frame.CLASSIC_METRES,-(15-z+corner.y)*256.0*Frame.CLASSIC_METRES))
					# DFU TextureReader: rotate 90 degrees, flipped is 180
					# degrees; combined variant rotates the flipped image.
					if tile&64: corner = Vector2(corner.y,1.0-corner.x)
					if tile&128: corner = Vector2.ONE-corner
					# DFU uploads bottom-up image rows. DATA/Godot images retain
					# top-left-first rows, so invert the final sampled V coordinate.
					corner.y = 1.0-corner.y
					uv.append(corner)
				points.append_array(vertices)
				groups[record].vertices.append_array(vertices)
				groups[record].uv.append_array(uv)
				probes.append({"slot":z*16+x,"record":record,"encoded":tile,"triangle":vertices.slice(0,3),"uv":uv.slice(0,3)})
		var mesh := ArrayMesh.new()
		var keys: Array = groups.keys()
		keys.sort()
		var textures: Array = []
		for record: int in keys:
			var image: Dictionary = _stage.materials.image(archive,record)
			if not image.ok: return image
			textures.append(ImageTexture.create_from_image(image.image))
			var arrays := []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = groups[record].vertices
			var normals := PackedVector3Array()
			normals.resize(groups[record].vertices.size())
			normals.fill(Vector3.UP)
			arrays[Mesh.ARRAY_NORMAL] = normals
			arrays[Mesh.ARRAY_TEX_UV] = groups[record].uv
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		var shape := ConcavePolygonShape3D.new()
		shape.backface_collision = true
		shape.set_faces(points)
		_stage.ground_cache[cache_key] = {"mesh":mesh,"shape":shape,"textures":textures,"probes":probes,"points":points}
	var cached: Dictionary = _stage.ground_cache[cache_key]
	for point: Vector3 in cached.points:
		if not Frame.bounded(placed.transform*point): return _result("unsupported_geometry","Required ground exceeds qualified local precision extent.")
	var visual := MeshInstance3D.new()
	visual.mesh = cached.mesh
	for index in cached.textures.size():
		var material := StandardMaterial3D.new()
		material.albedo_texture = cached.textures[index]
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		visual.set_surface_override_material(index,material)
	placed.add_child(visual)
	var body := StaticBody3D.new()
	placed.add_child(body)
	_stage.body_nodes[body.get_instance_id()] = body
	var collision := CollisionShape3D.new()
	collision.shape = cached.shape
	var key := record_key(p.id,"@ground")
	collision.set_meta("scoped_record",key)
	body.add_child(collision)
	_stage.bindings[key] = {"identity":{"layout":_stage.input.identity.duplicate(true),"placement":p.id,"record":"@ground"},"record":{"type":"ground","source":ground.duplicate(true)},"transform":placed.transform,"probes":cached.probes.duplicate(true),"provenance":{"profile":PROFILE,"uv_profile":GROUND_UV_PROFILE,"ground_archive":archive}}
	_stage.triangles += 512
	return {"ok":true}

func _doors() -> Dictionary:
	# Static regions are selected against actual hit triangles. Ambiguity is a
	# checked no-action result, never enumeration-order selection.
	if not _rmb(): return super._doors()
	for rule: Dictionary in _stage.input.data.location_assembly.hit_rules:
		for id: String in rule.candidates:
			if not _stage.location_doors.has(id): return _result("missing","Declared hit selector region absent: "+id)
	return {"ok":true}

func _candidate_extension(candidate: Dictionary) -> void:
	if not _rmb(): return
	candidate.schema = "location-assembly-v1"
	candidate.area = _stage.ticket.request.area.duplicate(true)
	candidate.buildings = _stage.location_buildings.duplicate(true)
	candidate.doors = _stage.location_doors.duplicate(true)
	candidate.action_doors = _stage.location_action_doors.duplicate(true)
	candidate.pending_door_bindings = candidate.doors.keys()+candidate.action_doors.keys()
	candidate.markers = _stage.location_markers.duplicate(true)
	candidate.context_ready = true
	candidate.context_version = Hash.digest({"area":candidate.area,"layout":candidate.layout_version,"profile":PROFILE})
	candidate.binding_ready = false
	candidate.pending_providers = ["WORLD-terrain","WORLD-routes","MOVE-placement","entrance-exit-bindings","gameplay-owner-state"]
	candidate.geometry_version = Hash.digest([candidate.geometry_version,PROFILE,_stage.materials.asset_version()])
	if candidate.area.kind == "exterior":
		candidate.ground_uv_profile = GROUND_UV_PROFILE
		candidate.geometry_version = Hash.digest([candidate.geometry_version,GROUND_UV_PROFILE])
	candidate.hit_rules = _stage.input.data.location_assembly.hit_rules.duplicate(true)
	candidate.door_index = {}
	for key: String in candidate.bindings:
		var binding: Dictionary = candidate.bindings[key]
		if not binding.has("bounds"): continue
		var candidates: Array = []
		for id: String in candidate.doors:
			var door: Dictionary = candidate.doors[id]
			var bounds := AABB(door.triangles[0],Vector3.ZERO)
			for point: Vector3 in door.triangles: bounds = bounds.expand(point)
			if binding.bounds.grow(Frame.POSITION_TOLERANCE).intersects(bounds.grow(Frame.POSITION_TOLERANCE)): candidates.append(id)
		candidate.door_index[key] = candidates
	# A declared selector must refer to actual regions in this exact preparation.
	# Validation happens before publication through _doors().

func _directory(layout: String) -> Dictionary:
	if registry == null or layouts == null or not layouts.classic.ready(): return _result("stale")
	var ticket: int = registry.content_ticket()
	if _directories.get("ticket",-1) != ticket: _directories = {"ticket":ticket,"layouts":{}}
	if _directories.layouts.has(layout): return _directories.layouts[layout]
	var input: Dictionary = layouts.location_inputs(registry,layout)
	if not input.ok: return input
	var blocks := {}
	var records := {}
	var types := {}
	var factions := {}
	var versions := {}
	for p: Dictionary in input.data.placements:
		if p.context == "dungeon": continue
		if not blocks.has(p.block): blocks[p.block] = layouts.decode_block(registry,p.block)
		var block: Dictionary = blocks[p.block]
		if not block.ok: return block
		versions[p.block] = Hash.digest(block.definition)
		for building: Dictionary in block.definition.get("building_inputs",{}).values():
			var key := record_key(p.id,building.id)
			if records.has(key): return _result("ambiguous","Duplicate scoped building: "+key)
			var record := {"identity":{"location":input.data.location,"layout":input.identity.duplicate(true),"placement":p.id,"building":building.id},"template":{"block":block.identity.duplicate(true),"building":building.id},"metadata":building.metadata.duplicate(true),"service_binding_ready":false,"geometry_ready":false,"provenance":{"winner":block.winner.duplicate(true),"contributors":block.contributors.duplicate(true)}}
			records[key] = record
			for pair in [[types,building.metadata.building_type],[factions,building.metadata.faction_id]]:
				if not pair[0].has(pair[1]): pair[0][pair[1]] = []
				pair[0][pair[1]].append(key)
	for index: Dictionary in [types,factions]:
		for keys: Array in index.values(): keys.sort()
	var result := {"ok":true,"records":records,"types":types,"factions":factions,"content_ticket":ticket,"layout":input.identity.duplicate(true),"version":Hash.digest({"layout":input.data,"blocks":versions}),"provenance":{"winner":input.winner.duplicate(true),"contributors":input.contributors.duplicate(true),"content_context":input.content_context.duplicate(true)}}
	_directories.layouts[layout] = result
	return result

func building_definition(layout: String, placement: String, building: String) -> Dictionary:
	var directory := _directory(layout)
	if not directory.ok: return directory
	var key := record_key(placement,building)
	if not directory.records.has(key): return _result("missing","Scoped building absent.")
	return {"ok":true,"record":directory.records[key].duplicate(true),"content_ticket":directory.content_ticket,"layout_version":directory.version,"provenance":directory.provenance.duplicate(true)}

func building_candidates(layout: String, field: String, value: int) -> Dictionary:
	if field not in ["type","faction"]: return _result("invalid","Supported definition classification required.")
	var directory := _directory(layout)
	if not directory.ok: return directory
	var keys: Array = directory["types" if field == "type" else "factions"].get(value,[])
	var records: Array = []
	for key: String in keys: records.append(directory.records[key].duplicate(true))
	return {"ok":true,"records":records,"content_ticket":directory.content_ticket,"layout_version":directory.version,"provenance":directory.provenance.duplicate(true)}

static func _on_triangle(point: Vector3, a: Vector3, b: Vector3, c: Vector3) -> bool:
	var normal := (b-a).cross(c-a)
	if normal.length_squared() < 0.00000001: return false
	if absf(normal.normalized().dot(point-a)) > Frame.POSITION_TOLERANCE: return false
	var u := b-a
	var v := c-a
	var w := point-a
	var denominator := u.dot(u)*v.dot(v)-u.dot(v)*u.dot(v)
	var s := (v.dot(v)*w.dot(u)-u.dot(v)*w.dot(v))/denominator
	var t := (u.dot(u)*w.dot(v)-u.dot(v)*w.dot(u))/denominator
	return s >= 0.0 and t >= 0.0 and s+t <= 1.0

func geometry_ray(ticket: Dictionary, from: Vector3, to: Vector3) -> Dictionary:
	var hit := super.geometry_ray(ticket,from,to)
	var view := _view(ticket)
	if not hit.get("found",false) or view.get("schema") != "location-assembly-v1": return hit
	var candidates: Array = []
	for id: String in view.door_index.get(record_key(hit.record.placement,hit.record.record),[]):
		var door: Dictionary = view.doors[id]
		for at in range(0,door.triangles.size(),3):
			if _on_triangle(hit.position,door.triangles[at],door.triangles[at+1],door.triangles[at+2]):
				candidates.append(id)
				break
	candidates.sort()
	var selected := ""
	if candidates.size() == 1: selected = candidates[0]
	elif candidates.size() > 1:
		for rule: Dictionary in view.hit_rules:
			var declared: Array = rule.candidates.duplicate()
			declared.sort()
			if declared == candidates: selected = rule.selected
	hit.entrance = view.doors[selected].duplicate(true) if not selected.is_empty() else {}
	hit.hit_kind = "entrance" if not selected.is_empty() else ("ambiguous" if candidates.size() > 1 else "geometry")
	hit.candidates = candidates
	hit.door_action = false # Access/traversal consumers and links remain pending.
	hit.layout_version = view.layout_version
	hit.activation = view.get("activation_session","")
	return hit

func binding(ticket: Dictionary, placement: String, record: String) -> Dictionary:
	var result := super.binding(ticket,placement,record)
	if result.ok:
		var view := _view(ticket)
		result.layout_version = view.layout_version
		result.content_ticket = ticket.request.content_ticket
		result.activation = view.get("activation_session","")
		result.activation_version = view.get("activation_version","")
	return result

func marker_candidates(ticket: Dictionary, interior: String, role: String) -> Dictionary:
	var view := _view(ticket)
	if view.is_empty(): return _result("stale")
	if view.get("schema") != "location-assembly-v1" or view.area.get("instance","") != interior: return _result("missing","Exact interior instance required.")
	var records: Array = []
	var keys: Array = view.markers.keys()
	keys.sort()
	for key: String in keys:
		if view.markers[key].roles.has(role): records.append(view.markers[key].duplicate(true))
	return {"ok":true,"records":records,"layout_version":view.layout_version,"content_ticket":ticket.request.content_ticket,"activation":view.get("activation_session",""),"binding_ready":false,"placement_committed":false}
