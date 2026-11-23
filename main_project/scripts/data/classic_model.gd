extends RefCounted
## ARCH3D source-space geometry. No world scale, patches, collision or placement.
const Cursor = preload("res://scripts/data/media_cursor.gd")
const Value = preload("res://scripts/data/decoded_media.gd")
const VERSION = "classic-model-v1"

func _failure(raw: Dictionary, reason: String, position: int) -> Dictionary:
	return {"ok":false,"kind":"malformed_or_unsupported","reason":reason,"source":raw.get("source"),"record":raw.get("record"),"classic_id":raw.get("identity"),"position":position,"converter":VERSION,"provider":"classic"}

func _requires_unverified_uv_unpack(value: int) -> bool:
	return value <= -14336 or value >= 14336 or value == -7168

func decode(raw: Dictionary) -> Dictionary:
	if not raw.get("ok",false):
		var rejected := raw.duplicate(true)
		rejected.converter = VERSION
		rejected.provider = "classic"
		return rejected
	if not raw.get("identity") is int: return _failure(raw,"ARCH3D domain decoding requires a numeric classic ID.",0)
	var bytes: PackedByteArray = raw.bytes
	var source_hash := HashingContext.new()
	source_hash.start(HashingContext.HASH_SHA256)
	source_hash.update(bytes)
	var source_sha256 := source_hash.finish().hex_encode()
	var cursor := Cursor.new(bytes)
	if not cursor.has(64): return _failure(raw,cursor.reason,0)
	var version := cursor.take(4).get_string_from_ascii()
	if version not in ["v2.5","v2.6","v2.7"]: return _failure(raw,"Unsupported ARCH3D version.",0)
	var points := cursor.s32()
	var planes := cursor.s32()
	var radius := cursor.u32()
	cursor.seek(24)
	var plane_data := cursor.s32()
	var object_data := cursor.s32()
	var objects := cursor.s32()
	cursor.seek(48)
	var point_start := cursor.s32()
	var normal_start := cursor.s32()
	cursor.seek(60)
	var plane_start := cursor.s32()
	if points <= 0 or planes <= 0 or points > bytes.size() / 12 or planes > bytes.size() / 12:
		return _failure(raw,"Invalid model point/plane counts.",4)
	if point_start < 64 or normal_start < 64 or plane_start < 64 or point_start + points * 12 > bytes.size() or normal_start + planes * 12 > bytes.size():
		return _failure(raw,"Model table extent is outside the record.",48)
	var source_points: Array = []
	cursor.seek(point_start)
	for unused in points: source_points.append([cursor.s32(),cursor.s32(),cursor.s32()])
	var output: Array = []
	cursor.seek(plane_start)
	for index in planes:
		var at := cursor.position
		if not cursor.has(8): return _failure(raw,cursor.reason,at)
		var count := cursor.u8()
		var unknown := cursor.u8()
		var texture := cursor.u16()
		var flags := cursor.u32()
		if count < 3 or not cursor.has(count * 8): return _failure(raw,"Invalid/truncated model polygon.",at)
		var references: Array[int] = []
		var encoded_uv: Array = []
		var uv: Array[Vector2] = []
		var polygon: Array[Vector3] = []
		for vertex in count:
			var offset := cursor.s32()
			var u := cursor.s16()
			var v := cursor.s16()
			encoded_uv.append([u,v])
			if int(raw.identity) < 905 and vertex < 3:
				if _requires_unverified_uv_unpack(u) or _requires_unverified_uv_unpack(v):
					return _failure(raw,"Older-ID packed UV correction is outside the verified model profile.",cursor.position - 4)
			if version == "v2.5": offset *= 3
			if offset < 0 or offset % 12 != 0 or offset / 12 >= points: return _failure(raw,"Point reference is not an aligned source point.",cursor.position - 8)
			var point_index: int = offset / 12
			references.append(point_index)
			var xyz: Array = source_points[point_index]
			polygon.append(Vector3(xyz[0],xyz[1],xyz[2]))
			uv.append(Vector2(u,v))
		uv[1] += uv[0]
		uv[2] += uv[1]
		var first := polygon[1] - polygon[0]
		var second := polygon[2] - polygon[0]
		var cross := first.cross(second)
		if cross.length_squared() == 0: return _failure(raw,"First three model points do not define a UV plane.",at)
		var denominator := first.dot(first) * second.dot(second) - first.dot(second) * first.dot(second)
		if denominator <= 0: return _failure(raw,"Degenerate model UV basis.",at)
		for vertex in range(3,count):
			var delta := polygon[vertex] - polygon[0]
			var a := (delta.dot(first) * second.dot(second) - delta.dot(second) * first.dot(second)) / denominator
			var b := (delta.dot(second) * first.dot(first) - delta.dot(first) * first.dot(second)) / denominator
			uv[vertex] = uv[0] + a * (uv[1] - uv[0]) + b * (uv[2] - uv[0])
		var projected := PackedVector2Array()
		var axis := cross.abs().max_axis_index()
		for point in polygon:
			projected.append(Vector2(point.y,point.z) if axis == 0 else (Vector2(point.z,point.x) if axis == 1 else Vector2(point.x,point.y)))
		var triangles := Geometry2D.triangulate_polygon(projected)
		if triangles.size() != (count - 2) * 3: return _failure(raw,"Polygon cannot be triangulated without changing topology.",at)
		# Geometry2D emits CCW triangles; retain the original polygon's winding.
		if Geometry2D.is_polygon_clockwise(projected):
			for triangle in range(0,triangles.size(),3):
				var swap := triangles[triangle + 1]
				triangles[triangle + 1] = triangles[triangle + 2]
				triangles[triangle + 2] = swap
		var normals := Cursor.new(bytes,normal_start + index * 12,normal_start + (index + 1) * 12)
		output.append({"source_plane":index,"point_indices":references,"encoded_uv":encoded_uv,"uv_sixteenths":uv,
			"normal_source":[normals.s32(),normals.s32(),normals.s32()],"triangles":triangles,
			"texture_archive":texture >> 7,"texture_record":texture & 127,"unknown":unknown,"flags":flags,"position":at})
	if not cursor.reason.is_empty(): return _failure(raw,cursor.reason,cursor.position)
	return {"ok":true,"kind":"ready","value":Value.new({"schema":Value.SCHEMA,"domain":"model",
		"identity":{"origin":"classic","domain":"model","local_id":"%s/record/%d" % [str(raw.identity),int(raw.get("ordinal",-1))]},
		"provenance":{"provider":"classic","source":raw.source,"record":raw.record,"classic_id":raw.identity,"ordinal":raw.get("ordinal",-1),"offset":raw.offset,"converter":VERSION,"sha256":source_sha256},
		"source_version":version,"source_frame":"arch3d-native","coordinate_units":"signed-int32-1/256-classic-unit",
		"world_conversion":"unavailable","points_source":source_points,"planes":output,"radius_source":radius,
		"plane_data_offset":plane_data,"object_data_offset":object_data,"object_count":objects,"patch_policy":"none"})}
