extends RefCounted
## Project-authored synthetic geometry, generated deterministically through GLB intake.
## Eight 0.5 m treads, 0.25 m rise; no source-game bytes or native dependency.
static func stairs() -> PackedByteArray:
	var points: Array[Vector3] = []
	var normals: Array[Vector3] = []
	var indices: Array[int] = []
	for step in 8:
		var left := -2.0+step*0.5
		var right := left+0.5
		var low := step*0.25
		var high := low+0.25
		var quads := [[Vector3(left,high,-1),Vector3(left,high,1),Vector3(right,high,1),Vector3(right,high,-1)],[Vector3(left,low,-1),Vector3(left,low,1),Vector3(left,high,1),Vector3(left,high,-1)]]
		for q in 2:
			var start := points.size()
			for point: Vector3 in quads[q]:
				points.append(point)
				normals.append(Vector3.UP if q == 0 else Vector3.LEFT)
			for index in [0,1,2,0,2,3]: indices.append(start+index)
	return encode(points,normals,indices)

static func gap_floor() -> PackedByteArray:
	# A 10 mm slit between x=.023 and .033 lies between 0.1 m ray probes.
	var points: Array[Vector3] = []
	var normals: Array[Vector3] = []
	var indices: Array[int] = []
	for extent in [[-2.0,0.023],[0.033,2.0]]:
		var start := points.size()
		for point in [Vector3(extent[0],0,-1),Vector3(extent[0],0,1),Vector3(extent[1],0,1),Vector3(extent[1],0,-1)]:
			points.append(point)
			normals.append(Vector3.UP)
		for index in [0,1,2,0,2,3]: indices.append(start+index)
	return encode(points,normals,indices)

static func encode(points: Array[Vector3], normals: Array[Vector3], indices: Array[int]) -> PackedByteArray:
	var binary := PackedByteArray()
	var views: Array = []
	var accessors: Array = []
	for field in 4:
		var at := binary.size()
		var components: int = [3,3,2,1][field]
		var count: int = indices.size() if field == 3 else points.size()
		binary.resize(at+count*components*4)
		for i in count:
			for component in components:
				if field == 3: binary.encode_u32(at+i*4,indices[i])
				else: binary.encode_float(at+(i*components+component)*4,points[i][component] if field == 0 else normals[i][component] if field == 1 else 0.0)
		views.append({"buffer":0,"byteOffset":at,"byteLength":binary.size()-at})
		accessors.append({"bufferView":field,"componentType":5125 if field == 3 else 5126,"count":count,"type":"VEC3" if field < 2 else "VEC2" if field == 2 else "SCALAR"})
	var document := {"asset":{"version":"2.0"},"scene":0,"scenes":[{"nodes":[0]}],"nodes":[{"mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"NORMAL":1,"TEXCOORD_0":2},"indices":3}]}],"buffers":[{"byteLength":binary.size()}],"bufferViews":views,"accessors":accessors}
	var json := JSON.stringify(document).to_utf8_buffer()
	while json.size()%4 != 0: json.append(32)
	var result := PackedByteArray()
	result.resize(20)
	result.encode_u32(0,0x46546c67)
	result.encode_u32(4,2)
	result.encode_u32(8,28+json.size()+binary.size())
	result.encode_u32(12,json.size())
	result.encode_u32(16,0x4e4f534a)
	result.append_array(json)
	var header := PackedByteArray()
	header.resize(8)
	header.encode_u32(0,binary.size())
	header.encode_u32(4,0x004e4942)
	result.append_array(header)
	result.append_array(binary)
	return result
