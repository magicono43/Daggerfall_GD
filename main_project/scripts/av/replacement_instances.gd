extends RefCounted
## Bounded real AV resource consumers. Returned nodes belong to the caller.
const DUNGEON_SURFACE_PROFILE = "dungeon-atlas-pixel-uv-v1"
static var _surface_shaders := {}

static func dungeon_palette(textures: Dictionary) -> Dictionary:
	if textures.is_empty() or textures.size() > 128: return {"ok":false,"kind":"unsupported_image","reason":"Dungeon material requires 1..128 checked source bindings."}
	var keys: Array = textures.keys()
	var area := 0
	var widest := 1
	for key: String in keys:
		var image: Image = textures[key].image
		if image == null or image.is_empty() or image.get_format() != Image.FORMAT_RGBA8: return {"ok":false,"kind":"invalid_image","reason":"RGBA8 required surface image unavailable."}
		area += image.get_width()*image.get_height()
		widest = maxi(widest,image.get_width())
	var width := nearest_po2(maxi(widest,ceili(sqrt(float(area)))))
	var regions := PackedVector4Array()
	var sizes := PackedVector2Array()
	var modes := PackedInt32Array()
	var x := 0
	var y := 0
	var row_height := 0
	var blended := false
	for key: String in keys:
		var binding: Dictionary = textures[key]
		var image: Image = binding.image
		if x+image.get_width() > width:
			x = 0
			y += row_height
			row_height = 0
		regions.append(Vector4(x,y,image.get_width(),image.get_height()))
		sizes.append(Vector2(binding.source_size))
		modes.append(binding.alpha)
		blended = blended or binding.alpha == Image.ALPHA_BLEND
		x += image.get_width()
		row_height = maxi(row_height,image.get_height())
	var height := y+row_height
	if width > 8192 or height > 8192: return {"ok":false,"kind":"unsupported_image","reason":"Required dungeon atlas exceeds the qualified 8192-pixel extent."}
	var atlas := Image.create(width,height,false,Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for index in keys.size():
		var image: Image = textures[keys[index]].image
		atlas.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),Vector2i(regions[index].x,regions[index].y))
	# Fixed-size shader arrays; unused slots are never indexed by validated meshes.
	regions.resize(128)
	sizes.resize(128)
	modes.resize(128)
	return {"ok":true,"keys":keys,"image":atlas,"regions":regions,"source_sizes":sizes,"alpha_modes":modes,"blended":blended,"profile":DUNGEON_SURFACE_PROFILE}

static func dungeon_material(palette: Dictionary) -> Dictionary:
	if not palette.get("ok",false) or palette.get("profile") != DUNGEON_SURFACE_PROFILE: return {"ok":false,"kind":"invalid_image","reason":"Checked dungeon palette required."}
	var texture := ImageTexture.create_from_image(palette.image)
	if texture == null or texture.get_size() != Vector2(palette.image.get_size()): return {"ok":false,"kind":"texture_unavailable","reason":"Required independent atlas creation failed; no fallback."}
	var blended: bool = palette.blended
	if not _surface_shaders.has(blended):
		var shader := Shader.new()
		var alpha_code := "ALPHA = (alpha_modes[binding_index] == 2) ? sampled.a : 1.0;" if blended else ""
		shader.code = "shader_type spatial; uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_disable; uniform vec4 regions[128]; uniform vec2 source_sizes[128]; uniform int alpha_modes[128]; varying flat int binding_index; void vertex() { binding_index = int(UV2.x + 0.5); } void fragment() { vec4 region = regions[binding_index]; vec2 pixel = region.xy + fract(UV / source_sizes[binding_index]) * region.zw; vec4 sampled = texture(albedo_texture, pixel / vec2(textureSize(albedo_texture, 0))); if (alpha_modes[binding_index] == 1 && sampled.a < 0.5) { discard; } ALBEDO = sampled.rgb; ROUGHNESS = 1.0; "+alpha_code+" }"
		_surface_shaders[blended] = shader
	var material := ShaderMaterial.new()
	material.shader = _surface_shaders[blended]
	material.set_shader_parameter("albedo_texture",texture)
	material.set_shader_parameter("regions",palette.regions)
	material.set_shader_parameter("source_sizes",palette.source_sizes)
	material.set_shader_parameter("alpha_modes",palette.alpha_modes)
	return {"ok":true,"material":material,"texture":texture}

static func image_material(result: Dictionary) -> Dictionary:
	if not result.get("ok",false) or not result.get("resource",{}).get("image") is Image:
		return {"ok":false,"reason":"A decoded replacement image is required."}
	var material := StandardMaterial3D.new()
	material.albedo_texture = ImageTexture.create_from_image(result.resource.image)
	# A nested mutable resource demonstrates the same ownership rule as materials.
	material.next_pass = StandardMaterial3D.new()
	return {"ok":true,"material":material,"provenance":result.provenance.duplicate(true)}

static func model_resources(result: Dictionary) -> Dictionary:
	if not result.get("ok",false) or not result.get("resource",{}).has("meshes"):
		return {"ok":false,"reason":"A decoded replacement model is required."}
	var meshes: Array = []
	for mesh: ArrayMesh in result.resource.meshes:
		var materials: Array = []
		for surface in mesh.get_surface_count():
			var material := mesh.surface_get_material(surface)
			materials.append(material.duplicate(true) if material != null else null)
		meshes.append({"mesh":mesh,"materials":materials})
	return {"ok":true,"meshes":meshes,"provenance":result.provenance.duplicate(true)}

static func model(result: Dictionary) -> Dictionary:
	var editable := model_resources(result)
	if not editable.ok: return editable
	var resource: Dictionary = result.resource
	var root := Node3D.new()
	root.name = "VisualReplacement"
	var nodes := {}
	for index: int in resource.included:
		var definition: Dictionary = resource.nodes[index]
		var node := Node3D.new()
		node.transform = resource.transforms[index]
		if definition.has("mesh"):
			var visual := MeshInstance3D.new()
			visual.mesh = editable.meshes[int(definition.mesh)].mesh
			for surface in visual.mesh.get_surface_count():
				var material: Material = editable.meshes[int(definition.mesh)].materials[surface]
				# Deep duplication isolates next_pass, shader parameters and textures too.
				if material != null: visual.set_surface_override_material(surface,material)
			node.add_child(visual)
		nodes[index] = node
	for index: int in nodes:
		if resource.parents.has(index) and nodes.has(resource.parents[index]): nodes[resource.parents[index]].add_child(nodes[index])
		else: root.add_child(nodes[index])
	return {"ok":true,"node":root,"provenance":result.provenance.duplicate(true)}

static func audio(result: Dictionary, loop := false) -> Dictionary:
	if not result.get("ok",false) or not result.get("resource",{}).get("stream") is AudioStream:
		return {"ok":false,"reason":"A decoded replacement audio stream is required."}
	var stream: AudioStream = result.resource.stream.duplicate(true)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
		stream.loop_begin = 0
		stream.loop_end = result.resource.frames
	elif stream is AudioStreamOggVorbis:
		stream.loop = loop
	var player := AudioStreamPlayer.new()
	player.stream = stream
	return {"ok":true,"player":player,"provenance":result.provenance.duplicate(true)}
