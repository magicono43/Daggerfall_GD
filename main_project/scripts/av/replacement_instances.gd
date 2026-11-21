extends RefCounted
## Bounded real AV resource consumers. Returned nodes belong to the caller.

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
