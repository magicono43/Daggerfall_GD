extends RefCounted
## One geometry boundary for source model points, layout poses and collision.
## Does not qualify MOVE's motor dimensions or placement corrections.
const FRAME = "dungeon-geometry-metres-v1"
const CLASSIC_METRES = 0.025
const MODEL_FRACTION = 256.0
const GRID_SIDE = 2048
const MAX_SUPPORT_DEPTH = GRID_SIDE * CLASSIC_METRES
const POSITION_TOLERANCE = 0.001
const NORMAL_TOLERANCE = 0.0001 # ArrayMesh octahedral normal packing plus float32.
const MAX_LOCAL_METRES = 8192.0
const AXES = Basis(Vector3.RIGHT,Vector3.DOWN,Vector3.FORWARD)

static func vector(value: Array) -> Vector3:
	return Vector3(float(value[0]),float(value[1]),float(value[2]))

static func point(value: Array) -> Vector3:
	return AXES * vector(value) * CLASSIC_METRES

static func model_point(value: Array) -> Vector3:
	return point(value) / MODEL_FRACTION

static func normal(value: Array) -> Vector3:
	return (AXES * vector(value)).normalized()

static func pose(value: Dictionary) -> Transform3D:
	if value.frame == FRAME:
		var radians := Vector3(fmod(float(value.rotation[0]),TAU),fmod(float(value.rotation[1]),TAU),fmod(float(value.rotation[2]),TAU))
		return Transform3D(Basis(Vector3.BACK,radians.z) * Basis(Vector3.RIGHT,radians.x) * Basis(Vector3.UP,radians.y),vector(value.position))
	var angles := Vector3(int(value.rotation[0])%2048,int(value.rotation[1])%2048,int(value.rotation[2])%2048) * (TAU / 2048.0)
	var source := Basis(Vector3.BACK,angles.z) * Basis(Vector3.RIGHT,angles.x) * Basis(Vector3.UP,-angles.y)
	return Transform3D(AXES * source * AXES.inverse(),point(value.position))

static func valid_native(value: Variant) -> bool:
	if not value is Dictionary or value.size() != 6 or value.get("frame") != FRAME or value.get("position_unit") != "metre" or value.get("rotation_unit") != "radian" or not value.get("scale") is Array or value.scale.size() != 3: return false
	for n in value.scale:
		if not (n is int or n is float) or float(n) != 1.0: return false
	for field in ["position","rotation"]:
		if not value.get(field) is Array or value[field].size() != 3: return false
		for n in value[field]:
			if not (n is int or n is float) or not is_finite(float(n)): return false
	for n in value.position:
		if absf(float(n)) > MAX_LOCAL_METRES: return false
	return true

static func bounded(value: Vector3) -> bool:
	return value.is_finite() and maxf(absf(value.x),maxf(absf(value.y),absf(value.z))) <= MAX_LOCAL_METRES

static func snap_reason(placement_: Dictionary) -> String:
	var mode: Variant = placement_.get("placement_mode","free")
	if mode not in ["snapped","free"]: return "Explicit snapped/free declaration required."
	if mode == "free": return "Free placement cannot also declare snapping." if placement_.has("snap") else ""
	var snap: Variant = placement_.get("snap")
	if not snap is Dictionary or snap.size() != 2: return "Snapped placement declares position_step and rotation_step in its transform units."
	for field in ["position","rotation"]:
		var step: Variant = snap.get(field+"_step")
		if not (step is int or step is float) or not is_finite(float(step)) or step <= 0: return "Positive finite snap steps required."
		for n in placement_.transform[field]:
			var residual := absf(float(n)-roundf(float(n)/float(step))*float(step))
			var tolerance := (POSITION_TOLERANCE if field == "position" else 0.000001) if placement_.transform.frame == FRAME else 0.0
			if residual > tolerance: return "Declared snapped pose is off its authored grid; no runtime rounding."
	return ""

static func placement(value: Dictionary) -> Transform3D:
	if value.has("transform"): return pose(value.transform)
	return Transform3D(Basis.IDENTITY,point([int(value.grid[0])*GRID_SIDE,0,int(value.grid[1])*GRID_SIDE]))
