extends RefCounted
## Bounded AV consumer for decoded DATA values. No WORLD pose or gameplay calls.
const Images = preload("res://scripts/data/classic_image.gd")

func video_frame_resource(value: RefCounted) -> Dictionary:
	var frame: Dictionary = value.projection()
	if frame.domain != "video_frame": return {"ok":false,"reason":"Decoded VID frame required."}
	frame.ok = true
	var result := Images.new().rgba(frame,{"ok":true,"rgb":frame.palette_rgb},-1)
	if not result.ok: return result
	var pixels := Image.create_from_data(result.width,result.height,false,Image.FORMAT_RGBA8,result.rgba)
	return {"ok":true,"image":pixels,"texture":ImageTexture.create_from_image(pixels)}

func image_resource(value: RefCounted, palette: RefCounted, alpha_index: int) -> Dictionary:
	var image: Dictionary = value.projection()
	var colors: Dictionary = palette.projection()
	if image.domain != "image" or colors.domain != "palette": return {"ok":false,"reason":"Image and palette DATA values required."}
	image.ok = true
	colors.ok = true
	if image.has("embedded_palette"): colors = image.embedded_palette
	var result := Images.new().rgba(image,colors,alpha_index)
	if not result.ok: return result
	var pixels := Image.create_from_data(result.width,result.height,false,Image.FORMAT_RGBA8,result.rgba)
	return {"ok":true,"image":pixels,"texture":ImageTexture.create_from_image(pixels),"provenance":image.provenance.duplicate(true)}

func sound_resource(value: RefCounted) -> Dictionary:
	var sound: Dictionary = value.projection()
	if sound.domain != "audio" or sound.encoding != "pcm-u8" or sound.channels != 1 or sound.sample_rate_hz != 11025:
		return {"ok":false,"reason":"Unsupported decoded inspection audio profile."}
	# Godot's FORMAT_8_BITS data uses signed samples; classic bytes are unsigned.
	var bytes := PackedByteArray()
	bytes.resize(sound.samples.size())
	for index in bytes.size(): bytes[index] = int(sound.samples[index]) & 255
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sound.sample_rate_hz
	stream.stereo = false
	stream.data = bytes
	return {"ok":true,"stream":stream,"provenance":sound.provenance.duplicate(true)}

func model_resource(value: RefCounted, textures: Dictionary) -> Dictionary:
	var model: Dictionary = value.projection()
	if model.domain != "model": return {"ok":false,"reason":"Decoded model DATA required."}
	var mesh := ArrayMesh.new()
	var materials: Array[StandardMaterial3D] = []
	for plane: Dictionary in model.planes:
		var key := "%d/%d" % [plane.texture_archive,plane.texture_record]
		if not textures.has(key): return {"ok":false,"reason":"Required model surface texture absent: " + key,"provenance":model.provenance}
		var texture: Texture2D = textures[key]
		var vertices := PackedVector3Array()
		var uv := PackedVector2Array()
		var normals := PackedVector3Array()
		for index in plane.point_indices.size():
			var point: Array = model.points_source[plane.point_indices[index]]
			vertices.append(Vector3(point[0],point[1],point[2]) / 256.0)
			uv.append(plane.uv_sixteenths[index] / Vector2(texture.get_width() * 16,texture.get_height() * 16))
			var normal: Array = plane.normal_source
			normals.append(Vector3(normal[0],normal[1],normal[2]).normalized())
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_TEX_UV] = uv
		var engine_triangles: PackedInt32Array = plane.triangles.duplicate()
		# Source polygons follow their cross-product normal; Godot's front face
		# is clockwise. This AV conversion is independent of world coordinates.
		for triangle in range(0,engine_triangles.size(),3):
			var swap := engine_triangles[triangle + 1]
			engine_triangles[triangle + 1] = engine_triangles[triangle + 2]
			engine_triangles[triangle + 2] = swap
		arrays[Mesh.ARRAY_INDEX] = engine_triangles
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		var material := StandardMaterial3D.new()
		material.albedo_texture = ImageTexture.create_from_image(texture.get_image())
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh.surface_set_material(mesh.get_surface_count() - 1,material)
		materials.append(material)
	return {"ok":true,"mesh":mesh,"materials":materials,"frame":"inspection-source-axes","units":"classic-unit","provenance":model.provenance.duplicate(true)}
