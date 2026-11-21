extends RefCounted
## Deliberately bounded static glTF 2 profile; creates only visual engine resources.
const VERSION = "static-glb-v1"
const Codec = preload("res://scripts/data/replacement_codec.gd")

static func reject(reason: String, kind := "invalid") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"converter":VERSION}

static func allowed(value: Dictionary, keys: Array) -> bool:
	for key in value:
		if key not in keys: return false
	return true

static func numbers(value: Variant, count: int) -> bool:
	if not value is Array or value.size() != count: return false
	for number in value:
		if (not number is float and not number is int) or not is_finite(float(number)): return false
	return true

static func integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= 0 and value <= 2147483647 and value == int(value)

static func structure(document: Dictionary) -> String:
	for array: String in ["scenes","nodes","meshes","accessors","bufferViews","buffers","materials","textures","images","samplers"]:
		if not document.get(array,[]) is Array: return "Expected object array: " + array
		for item in document.get(array,[]):
			if not item is Dictionary: return "Expected object in " + array
			for key: String in ["buffer","bufferView","byteOffset","byteLength","byteStride","componentType","count","mesh","source","sampler","target"]:
				if item.has(key) and not integer(item[key]): return "Invalid integer field: " + array + "/" + key
			for key: String in ["children","nodes"]:
				if item.has(key):
					if not item[key] is Array: return "Expected index array."
					for index in item[key]:
						if not integer(index): return "Invalid node index."
			if array == "materials":
				if not item.get("pbrMetallicRoughness",{}) is Dictionary: return "Expected PBR material object."
				var pbr: Dictionary = item.get("pbrMetallicRoughness",{})
				for scalar: String in ["metallicFactor","roughnessFactor"]:
					if pbr.has(scalar) and (not numbers([pbr[scalar]],1) or pbr[scalar] < 0 or pbr[scalar] > 1): return "Invalid PBR scalar."
				if item.has("doubleSided") and not item.doubleSided is bool: return "Expected doubleSided boolean."
				if item.has("alphaCutoff") and (not numbers([item.alphaCutoff],1) or item.alphaCutoff < 0): return "Invalid alpha cutoff."
				if pbr.has("baseColorTexture"):
					if not pbr.baseColorTexture is Dictionary or not integer(pbr.baseColorTexture.get("index")) or not integer(pbr.baseColorTexture.get("texCoord",0)): return "Invalid texture reference."
			if array == "meshes":
				if not item.get("primitives") is Array: return "Expected primitive array."
				for primitive in item.primitives:
					if not primitive is Dictionary or not primitive.get("attributes") is Dictionary: return "Expected primitive/attributes object."
					for key: String in ["indices","material","mode"]:
						if primitive.has(key) and not integer(primitive[key]): return "Invalid primitive integer."
					for index in primitive.attributes.values():
						if not integer(index): return "Invalid attribute accessor index."
	if not integer(document.get("scene",0)): return "Invalid default scene index."
	for key: String in ["extensionsUsed","extensionsRequired"]:
		if not document.get(key,[]) is Array: return "Expected extension array."
	return ""

static func accessor(document: Dictionary, binary: PackedByteArray, index: Variant, type: String) -> Dictionary:
	if not index is float and not index is int: return reject("Accessor index must be integer.")
	if int(index) != index or index < 0 or index >= document.get("accessors",[]).size(): return reject("Accessor index out of range.")
	var item: Dictionary = document.accessors[int(index)]
	if not allowed(item,["bufferView","byteOffset","componentType","count","type","min","max","name"]) or item.get("type") != type: return reject("Unsupported accessor type/features.","unsupported")
	var component := int(item.get("componentType",0))
	if (type != "SCALAR" and component != 5126) or (type == "SCALAR" and component not in [5121,5123,5125]): return reject("Unsupported accessor component type.","unsupported")
	var view_index := int(item.get("bufferView",-1))
	if view_index < 0 or view_index >= document.get("bufferViews",[]).size(): return reject("Missing buffer view.")
	var view: Dictionary = document.bufferViews[view_index]
	if not allowed(view,["buffer","byteOffset","byteLength","byteStride","target","name"]) or view.get("buffer") != 0: return reject("Unsupported buffer view/dependency.","unsupported")
	var width: int = {"SCALAR":1,"VEC2":2,"VEC3":3}[type]
	var size: int = {5121:1,5123:2,5125:4,5126:4}[component]
	var stride := int(view.get("byteStride",size*width))
	var count := int(item.get("count",0))
	var offset := int(item.get("byteOffset",0))
	var start := int(view.get("byteOffset",0))
	var length := int(view.get("byteLength",0))
	if count <= 0 or offset < 0 or start < 0 or length <= 0 or stride < width*size or stride % size != 0 or offset % size != 0 or start+length > binary.size() or offset+(count-1)*stride+width*size > length: return reject("Accessor extent/alignment/count is invalid.")
	var values: Array = []
	for i in count:
		var row: Array = []
		for c in width:
			var at := start+offset+i*stride+c*size
			var number: float = binary.decode_float(at) if component == 5126 else binary.decode_u32(at) if size == 4 else binary.decode_u16(at) if size == 2 else binary[at]
			if not is_finite(number): return reject("Nonfinite geometry component.")
			row.append(number)
		values.append(row)
	return {"ok":true,"values":values}

static func decode(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 28 or bytes.decode_u32(0) != 0x46546c67: return Codec.fail("wrong_type","Expected binary glTF signature.")
	if bytes.decode_u32(4) != 2 or bytes.decode_u32(8) != bytes.size(): return reject("GLB version/extent mismatch.")
	var json_length := bytes.decode_u32(12)
	if bytes.decode_u32(16) != 0x4e4f534a or json_length % 4 != 0 or 20+json_length+8 > bytes.size(): return reject("Invalid GLB JSON chunk.")
	var parsed: Variant = JSON.parse_string(bytes.slice(20,20+json_length).get_string_from_utf8())
	if not parsed is Dictionary: return reject("GLB JSON object required.")
	var document: Dictionary = parsed
	var structural_reason := structure(document)
	if not structural_reason.is_empty(): return reject(structural_reason)
	var at := 20+json_length
	if bytes.decode_u32(at+4) != 0x004e4942 or at+8+bytes.decode_u32(at) != bytes.size(): return reject("Exactly one embedded BIN chunk is required.")
	var binary := bytes.slice(at+8)
	if not allowed(document,["asset","scene","scenes","nodes","meshes","accessors","bufferViews","buffers","materials","textures","images","samplers","extensionsUsed","extensionsRequired"]) or not document.get("asset") is Dictionary or document.asset.get("version") != "2.0": return reject("Unsupported glTF version/top-level features.","unsupported")
	if document.asset.get("minVersion","2.0") != "2.0": return reject("Unsupported required glTF minimum version.","unsupported")
	if not document.get("extensionsRequired",[]).is_empty() or not document.get("extensionsUsed",[]).is_empty(): return reject("glTF extensions are outside static-glb-v1.","unsupported")
	var buffers: Array = document.get("buffers",[])
	if buffers.size() != 1 or not buffers[0] is Dictionary or buffers[0].has("uri") or int(buffers[0].get("byteLength",-1)) > binary.size() or binary.size()-int(buffers[0].get("byteLength",-1)) > 3: return reject("Only checked embedded buffer dependencies are supported.","unsupported")
	binary = binary.slice(0,int(buffers[0].byteLength))
	for key in ["scenes","nodes","meshes","accessors","bufferViews","materials","textures","images","samplers"]:
		if not document.get(key,[]) is Array: return reject("Expected glTF array: " + key)
		for item in document.get(key,[]):
			if not item is Dictionary: return reject("Expected glTF object in " + key)
	var textures: Array[Texture2D] = []
	for image: Dictionary in document.get("images",[]):
		if not allowed(image,["bufferView","mimeType","name"]) or image.get("mimeType") != "image/png": return reject("Only embedded base-color PNG dependencies are supported.","unsupported")
		var vi := int(image.get("bufferView",-1))
		if vi < 0 or vi >= document.bufferViews.size(): return reject("Image dependency view missing.")
		var view: Dictionary = document.bufferViews[vi]
		var begin := int(view.get("byteOffset",0))
		var length := int(view.get("byteLength",0))
		if view.get("buffer") != 0 or begin < 0 or length <= 0 or begin+length > binary.size(): return reject("Image dependency extent invalid.")
		var decoded := Codec.png(binary.slice(begin,begin+length))
		if not decoded.ok: return decoded
		textures.append(ImageTexture.create_from_image(decoded.image))
	var materials: Array[StandardMaterial3D] = []
	for material: Dictionary in document.get("materials",[]):
		if not allowed(material,["name","pbrMetallicRoughness","doubleSided","alphaMode","alphaCutoff"]): return reject("Unsupported material feature.","unsupported")
		var pbr: Dictionary = material.get("pbrMetallicRoughness",{})
		if not allowed(pbr,["baseColorFactor","baseColorTexture","metallicFactor","roughnessFactor"]): return reject("Only base-color materials are supported.","unsupported")
		var factor: Variant = pbr.get("baseColorFactor",[1,1,1,1])
		if not numbers(factor,4): return reject("Invalid base-color factor.")
		for component in factor:
			if component < 0 or component > 1: return reject("Base-color components must be in [0,1].")
		var engine_material := StandardMaterial3D.new()
		engine_material.albedo_color = Color(factor[0],factor[1],factor[2],factor[3])
		engine_material.metallic = float(pbr.get("metallicFactor",1))
		engine_material.roughness = float(pbr.get("roughnessFactor",1))
		engine_material.cull_mode = BaseMaterial3D.CULL_DISABLED if material.get("doubleSided",false) else BaseMaterial3D.CULL_BACK
		var alpha: String = material.get("alphaMode","OPAQUE")
		if alpha not in ["OPAQUE","MASK","BLEND"]: return reject("Unsupported alpha mode.")
		engine_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR if alpha == "MASK" else BaseMaterial3D.TRANSPARENCY_ALPHA if alpha == "BLEND" else BaseMaterial3D.TRANSPARENCY_DISABLED
		engine_material.alpha_scissor_threshold = float(material.get("alphaCutoff",0.5))
		if pbr.has("baseColorTexture"):
			if not pbr.baseColorTexture is Dictionary or not allowed(pbr.baseColorTexture,["index","texCoord"]) or pbr.baseColorTexture.get("texCoord",0) != 0: return reject("Only UV0 base color is supported.","unsupported")
			var ti := int(pbr.baseColorTexture.get("index",-1))
			if ti < 0 or ti >= document.get("textures",[]).size(): return reject("Missing texture dependency.")
			var texture: Dictionary = document.textures[ti]
			if not allowed(texture,["source","name"]) or int(texture.get("source",-1)) < 0 or int(texture.source) >= textures.size(): return reject("Unsupported sampler or missing image dependency.","unsupported")
			engine_material.albedo_texture = textures[int(texture.source)]
		materials.append(engine_material)
	var meshes: Array[ArrayMesh] = []
	var source_geometry: Array = []
	for mesh: Dictionary in document.get("meshes",[]):
		if not allowed(mesh,["name","primitives"]) or not mesh.get("primitives") is Array or mesh.primitives.is_empty(): return reject("Static triangle primitives required.","unsupported")
		var result := ArrayMesh.new()
		var source_primitives: Array = []
		for primitive in mesh.primitives:
			if not primitive is Dictionary or not allowed(primitive,["attributes","indices","material","mode"]) or primitive.get("mode",4) != 4 or not primitive.get("attributes") is Dictionary: return reject("Only static triangle lists are supported.","unsupported")
			var attributes: Dictionary = primitive.attributes
			if not allowed(attributes,["POSITION","NORMAL","TEXCOORD_0"]) or attributes.size() != 3: return reject("POSITION/NORMAL/UV0 required; other attributes unsupported.","unsupported")
			var positions := accessor(document,binary,attributes.POSITION,"VEC3")
			var normals := accessor(document,binary,attributes.NORMAL,"VEC3")
			var uvs := accessor(document,binary,attributes.TEXCOORD_0,"VEC2")
			var indices := accessor(document,binary,primitive.get("indices",-1),"SCALAR")
			for checked: Dictionary in [positions,normals,uvs,indices]:
				if not checked.ok: return checked
			if positions.values.size() != normals.values.size() or positions.values.size() != uvs.values.size() or indices.values.size() % 3 != 0: return reject("Geometry counts mismatch.")
			var vertices := PackedVector3Array()
			var normal_array := PackedVector3Array()
			var uv_array := PackedVector2Array()
			var index_array := PackedInt32Array()
			for i in positions.values.size():
				var p: Array = positions.values[i]
				var n: Array = normals.values[i]
				if not is_equal_approx(Vector3(n[0],n[1],n[2]).length(),1): return reject("Unit vertex normals required.")
				vertices.append(Vector3(p[0],p[1],p[2]))
				normal_array.append(Vector3(n[0],n[1],n[2]))
				uv_array.append(Vector2(uvs.values[i][0],uvs.values[i][1]))
			for row: Array in indices.values:
				if row[0] < 0 or row[0] >= vertices.size(): return reject("Index out of range.")
				index_array.append(int(row[0]))
			source_primitives.append({"positions":vertices.duplicate(),"normals":normal_array.duplicate(),"uv0":uv_array.duplicate(),"indices_ccw":index_array.duplicate(),"material":primitive.get("material",-1)})
			# glTF CCW front -> Godot clockwise front, without a spatial scale/pose patch.
			for i in range(0,index_array.size(),3):
				var swap := index_array[i+1]
				index_array[i+1] = index_array[i+2]
				index_array[i+2] = swap
			var arrays: Array = []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = vertices
			arrays[Mesh.ARRAY_NORMAL] = normal_array
			arrays[Mesh.ARRAY_TEX_UV] = uv_array
			arrays[Mesh.ARRAY_INDEX] = index_array
			result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
			if primitive.has("material"):
				var mi := int(primitive.material)
				if mi < 0 or mi >= materials.size(): return reject("Material index out of range.")
				result.surface_set_material(result.get_surface_count()-1,materials[mi])
		meshes.append(result)
		source_geometry.append(source_primitives)
	if meshes.is_empty(): return reject("Static model requires triangle mesh geometry.")
	var transforms: Array[Transform3D] = []
	var parents := {}
	for i in document.get("nodes",[]).size():
		var node: Dictionary = document.nodes[i]
		if not allowed(node,["name","mesh","children","translation","rotation","scale"]): return reject("Only static TRS visual nodes are supported; no matrix, scripts or gameplay.","unsupported")
		var t: Variant = node.get("translation",[0,0,0])
		var r: Variant = node.get("rotation",[0,0,0,1])
		var s: Variant = node.get("scale",[1,1,1])
		if not numbers(t,3) or not numbers(r,4) or not numbers(s,3) or s[0] <= 0 or s[1] <= 0 or s[2] <= 0: return reject("Finite TRS with positive scales required.")
		var rotation := Quaternion(r[0],r[1],r[2],r[3])
		if not is_equal_approx(rotation.length(),1): return reject("Unit quaternion required.")
		transforms.append(Transform3D(Basis(rotation)*Basis.from_scale(Vector3(s[0],s[1],s[2])),Vector3(t[0],t[1],t[2])))
		if node.has("mesh") and (int(node.mesh) < 0 or int(node.mesh) >= meshes.size()): return reject("Node mesh index invalid.")
		for child in node.get("children",[]):
			if int(child) < 0 or int(child) >= document.nodes.size() or parents.has(int(child)): return reject("Invalid/repeated node parent.")
			parents[int(child)] = i
	for i in transforms.size():
		var seen := {}
		var cursor := i
		while parents.has(cursor):
			if seen.has(cursor): return reject("Cyclic node hierarchy.")
			seen[cursor] = true
			cursor = parents[cursor]
	var scenes: Array = document.get("scenes",[])
	var scene := int(document.get("scene",0))
	if scene < 0 or scene >= scenes.size() or not allowed(scenes[scene],["name","nodes"]): return reject("Default visual scene required.")
	var roots: Array = scenes[scene].get("nodes",[])
	var included := {}
	var queue: Array = roots.duplicate()
	for root in roots:
		if int(root) < 0 or int(root) >= transforms.size() or parents.has(int(root)): return reject("Invalid scene root.")
	while not queue.is_empty():
		var index := int(queue.pop_front())
		if included.has(index): return reject("Repeated scene node.")
		included[index] = true
		queue.append_array(document.nodes[index].get("children",[]))
	if included.is_empty(): return reject("Empty visual scene.")
	var visible_mesh := false
	for index: int in included: visible_mesh = visible_mesh or document.nodes[index].has("mesh")
	if not visible_mesh: return reject("Selected scene contains no static model geometry.")
	return {"ok":true,"geometry_source":source_geometry,"materials_source":document.get("materials",[]).duplicate(true),"meshes":meshes,"nodes":document.nodes.duplicate(true),"transforms":transforms,"included":included,"parents":parents,"roots":roots.duplicate(),"frame":"gltf-rh-y-up-meters-to-godot-rh-y-up-v1","converter":VERSION}
