extends SceneTree
## Independent READ-only byte observations. No runtime decoder or LOC imports.
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or not args[0].is_absolute_path() or FileAccess.file_exists(args[1]):
		push_error("Explicit classic root and NEW output required.")
		quit(1)
		return
	var root := args[0]
	var model_archive := FileAccess.get_file_as_bytes(root.path_join("ARCH3D.BSA"))
	var count := model_archive.decode_u16(0)
	var offset := 4
	var model := PackedByteArray()
	for index in count:
		var directory := model_archive.size()-count*8+index*8
		var size := model_archive.decode_u32(directory+4)
		if model_archive.decode_u32(directory) == 67019: model = model_archive.slice(offset,offset+size)
		offset += size
	assert(not model.is_empty())
	var point_start := model.decode_s32(48)
	var normal_start := model.decode_s32(52)
	var face := model.decode_s32(60)
	var planes: Array = []
	var textures := {}
	var palette := FileAccess.get_file_as_bytes(root.path_join("PAL.PAL"))
	for plane in model.decode_s32(8):
		var vertices := int(model[face])
		var bits := model.decode_u16(face+2)
		var archive := bits >> 7
		var record := bits & 127
		var key := "%d/%d" % [archive,record]
		var source_points: Array = []
		var uv: Array = []
		for vertex in 3:
			var at := face+8+vertex*8
			var address := point_start+model.decode_s32(at)
			source_points.append([model.decode_s32(address),model.decode_s32(address+4),model.decode_s32(address+8)])
			uv.append([model.decode_s16(at+4),model.decode_s16(at+6)])
			if vertex > 0:
				uv[vertex][0] += uv[vertex-1][0]
				uv[vertex][1] += uv[vertex-1][1]
		planes.append({"archive":archive,"record":record,"source_points":source_points,"uv_sixteenths":uv,"normal":[model.decode_s32(normal_start+plane*12),model.decode_s32(normal_start+plane*12+4),model.decode_s32(normal_start+plane*12+8)]})
		for target in [archive,123 if archive == 120 else archive]:
			var texture_key := "%d/%d" % [target,record]
			if textures.has(texture_key): continue
			var bytes := FileAccess.get_file_as_bytes(root.path_join("TEXTURE.%03d" % target))
			var start := bytes.decode_s32(28+record*20)
			var width := bytes.decode_s16(start+4)
			var height := bytes.decode_s16(start+6)
			var data := start+bytes.decode_u32(start+14)
			assert(bytes.decode_u16(start+8) == 0x900 and bytes.decode_u16(start+20) == 1)
			var rgba := PackedByteArray()
			for y in height:
				for x in width:
					var color := int(bytes[data+y*256+x])
					for component in 3: rgba.append(palette[palette.size()-768+color*3+component])
					rgba.append(255)
			textures[texture_key] = {"size":[width,height],"source_sha256":FileAccess.get_sha256(root.path_join("TEXTURE.%03d" % target)),"rgba_sha256":sha(rgba),"first_pixel":[rgba[0],rgba[1],rgba[2],rgba[3]]}
		face += 8+vertices*8
	var block_archive := FileAccess.get_file_as_bytes(root.path_join("BLOCKS.BSA"))
	var blocks := block_archive.decode_u16(0)
	var payloads := {}
	offset = 4
	for index in blocks:
		var at := block_archive.size()-blocks*18+index*18
		var name_bytes := block_archive.slice(at,at+14)
		var terminator := name_bytes.find(0)
		var name := name_bytes.slice(0,terminator if terminator >= 0 else name_bytes.size()).get_string_from_ascii()
		var size := block_archive.decode_u32(at+14)
		payloads[name] = block_archive.slice(offset,offset+size)
		offset += size
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/profile.json"))
	var observations: Array = []
	for mapping: Dictionary in profile.blocks:
		if mapping.format != "RDB": continue
		var bytes: PackedByteArray = payloads[mapping.name]
		var markers: Array = []
		for address: String in mapping.records:
			var at := int(address)
			if bytes[at+20] != 3: continue
			var resource := bytes.decode_u32(at+21)
			if bytes.decode_u16(resource) != (199 << 7)+10: continue
			var sound := int(bytes[resource+5])
			markers.append({"id":mapping.records[address],"address":at,"sound_index":sound,"magnitude":int(bytes[resource+4]),"native_height":-8*sound if sound != 0 else 10000})
		if not markers.is_empty(): observations.append({"block":mapping.id,"name":mapping.name,"source_sha256":sha(bytes),"markers":markers})
	var sources := {}
	for name in ["ARCH3D.BSA","BLOCKS.BSA","MAPS.BSA","PAL.PAL","TEXTURE.000","TEXTURE.001","TEXTURE.174","TEXTURE.374","TEXTURE.474"]: sources[name] = FileAccess.get_sha256(root.path_join(name))
	for texture: String in textures:
		var archive := int(texture.get_slice("/",0))
		sources["TEXTURE.%03d" % archive] = textures[texture].source_sha256
	var fixture_blocks := {}
	for mapping: Dictionary in profile.blocks:
		if mapping.name not in ["W0000000.RDB","S0000040.RDB","S0000161.RDB"]: continue
		fixture_blocks[mapping.name] = geometry_observation(mapping,payloads[mapping.name],model_archive)
	for fixture: Dictionary in fixture_blocks.values():
		for texture: int in fixture.texture_archives:
			var name := "TEXTURE.%03d" % texture
			sources[name] = FileAccess.get_sha256(root.path_join(name))
	var file := FileAccess.open(args[1],FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema":"dungeon-context-independent-observation-v1","sources":sources,"model_id":67019,"model_sha256":sha(model),"planes":planes,"textures":textures,"environment_blocks":observations,"fixture_blocks":fixture_blocks},"\t")+"\n")
	file.close()
	quit()

func sha(bytes: PackedByteArray) -> String:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	return hash.finish().hex_encode()

func geometry_observation(mapping: Dictionary, block: PackedByteArray, archive: PackedByteArray) -> Dictionary:
	var models := {}
	var count := archive.decode_u16(0)
	var offset := 4
	for index in count:
		var at := archive.size()-count*8+index*8
		var id := archive.decode_u32(at)
		var size := archive.decode_u32(at+4)
		models[id] = [offset,size]
		offset += size
	var triangles: Array = []
	var bounds_: AABB
	var first := true
	var textures := {}
	var receipts := {}
	var levels := {}
	var castle := {}
	var markers: Array = []
	for address: String in mapping.records:
		var at := int(address)
		if block[at+20] != 3: continue
		var resource := block.decode_u32(at+21)
		if block.decode_u16(resource) != (199 << 7)+10: continue
		var sound := int(block[resource+5])
		var height := -8*sound if sound != 0 else 10000
		levels[height] = true
		castle[int(block[resource+4]) != 0] = true
		markers.append({"id":mapping.records[address],"position":[block.decode_s32(at+8)*0.025,-block.decode_s32(at+12)*0.025,-block.decode_s32(at+16)*0.025]})
	assert(levels.size() <= 1 and castle.size() <= 1)
	var native_height: int = levels.keys()[0] if not levels.is_empty() else 10000
	var surface := -native_height*0.025 if native_height != 10000 else 0.0
	for address: String in mapping.records:
		var at := int(address)
		if block[at+20] != 1: continue
		var resource := block.decode_u32(at+21)
		var reference := block.decode_u16(resource+12)
		var name_bytes := block.slice(20+reference*8,25+reference*8)
		var end := name_bytes.find(0)
		var id := int(name_bytes.slice(0,end if end >= 0 else name_bytes.size()).get_string_from_ascii())
		var model: PackedByteArray = archive.slice(models[id][0],models[id][0]+models[id][1])
		receipts[str(id)] = sha(model)
		var translation := Vector3(block.decode_s32(at+8),block.decode_s32(at+12),block.decode_s32(at+16))
		var angles := Vector3(block.decode_s32(resource),block.decode_s32(resource+4),block.decode_s32(resource+8))*TAU/2048.0
		var point_start := model.decode_s32(48)
		var face := model.decode_s32(60)
		for plane in model.decode_s32(8):
			var bits := model.decode_u16(face+2)
			textures[bits >> 7] = true
			var polygon: Array[Vector3] = []
			for vertex in int(model[face]):
				var point_offset := model.decode_s32(face+8+vertex*8)
				if model.slice(0,4).get_string_from_ascii() == "v2.5": point_offset *= 3
				var point_at := point_start+point_offset
				var point := Vector3(model.decode_s32(point_at),model.decode_s32(point_at+4),model.decode_s32(point_at+8))/256.0
				# Independent scalar source Ry -> Rx -> Rz, then source translation.
				var x := cos(-angles.y)*point.x+sin(-angles.y)*point.z
				var z := -sin(-angles.y)*point.x+cos(-angles.y)*point.z
				point.x = x
				point.z = z
				var y := cos(angles.x)*point.y-sin(angles.x)*point.z
				point.z = sin(angles.x)*point.y+cos(angles.x)*point.z
				point.y = y
				x = cos(angles.z)*point.x-sin(angles.z)*point.y
				point.y = sin(angles.z)*point.x+cos(angles.z)*point.y
				point.x = x
				point += translation
				point = Vector3(point.x,-point.y,-point.z)*0.025
				polygon.append(point)
				bounds_ = AABB(point,Vector3.ZERO) if first else bounds_.expand(point)
				first = false
			for vertex in range(1,polygon.size()-1): triangles.append({"points":[polygon[0],polygon[vertex],polygon[vertex+1]],"record":mapping.records[address],"model":id,"plane":plane})
			face += 8+int(model[face])*8
	var probe := {}
	if surface > 0:
		for triangle: Dictionary in triangles:
			var points: Array = triangle.points
			var position: Vector3 = (points[0]+points[1]+points[2])/3.0
			if position.y < bounds_.position.y or position.y >= surface-0.2 or position.x < 0.5 or position.x > 50.7 or position.z < -50.7 or position.z > -0.5: continue
			if (points[1]-points[0]).cross(points[2]-points[0]).y <= 0.0001: continue
			position.y += 0.1
			var blocked := false
			for obstruction: Dictionary in triangles:
				var q: Array = obstruction.points
				if Geometry3D.segment_intersects_triangle(position,Vector3(position.x,surface,position.z),q[0],q[1],q[2]) != null:
					blocked = true
					break
			if not blocked:
				probe = {"position":[position.x,position.y,position.z],"surface":surface,"floor_triangle":triangle}
				# JSON vectors must be explicit triples for independent consumers.
				probe.floor_triangle = {"record":triangle.record,"model":triangle.model,"plane":triangle.plane,"points":points.map(func(p: Vector3): return [p.x,p.y,p.z])}
				break
	var archives: Array = textures.keys()
	archives.sort()
	return {"block":mapping.id,"name":mapping.name,"sha256":sha(block),"model_sha256":receipts,"texture_archives":archives,"bounds":[[bounds_.position.x,bounds_.position.y,bounds_.position.z],[bounds_.end.x,bounds_.end.y,bounds_.end.z]],"native_height":native_height,"castle":castle.has(true),"environment_markers":markers,"water_probe":probe,"scope":"single-source-block-context-fixture; not complete original dungeon"}
