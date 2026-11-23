extends RefCounted
## Private preparation index. Exact projected triangle coverage complements the
## independent engine collision queries; no navigation or actor placement owner.
const CELL = 16.0
const TOLERANCE = preload("res://scripts/data/layout_geometry_frame.gd").POSITION_TOLERANCE
var _triangles: Array = []
var _cells := {}
var _wide: Array[int] = []

func add(a: Vector3, b: Vector3, c: Vector3) -> void:
	# Godot clockwise face order; omit downward ceilings and vertical walls.
	var normal := (c-a).cross(b-a)
	if normal.y <= 0.0000001: return
	var low := Vector2(minf(a.x,minf(b.x,c.x)),minf(a.z,minf(b.z,c.z)))
	var high := Vector2(maxf(a.x,maxf(b.x,c.x)),maxf(a.z,maxf(b.z,c.z)))
	var index := _triangles.size()
	_triangles.append([a,b,c])
	if (floori(high.x/CELL)-floori(low.x/CELL)+1)*(floori(high.y/CELL)-floori(low.y/CELL)+1) > 4096:
		_wide.append(index) # Avoid exploding the grid for a very large authored face.
		return
	for x in range(floori(low.x/CELL),floori(high.x/CELL)+1):
		for z in range(floori(low.y/CELL),floori(high.y/CELL)+1):
			var key := Vector2i(x,z)
			if not _cells.has(key): _cells[key] = []
			_cells[key].append(index)

static func weights(point: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var denominator := (b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
	var u := ((b.z-c.z)*(point.x-c.x)+(c.x-b.x)*(point.z-c.z))/denominator
	var v := ((c.z-a.z)*(point.x-c.x)+(a.x-c.x)*(point.z-c.z))/denominator
	return Vector3(u,v,1.0-u-v)

static func clip(interval: Vector2, start: float, end: float) -> Vector2:
	# Clip linear f(t)>=0 to the current [0,1] interval.
	var delta := end-start
	if absf(delta) < 0.0000001: return interval if start >= 0 else Vector2(1,0)
	var crossing := -start/delta
	return Vector2(maxf(interval.x,crossing),interval.y) if delta > 0 else Vector2(interval.x,minf(interval.y,crossing))

func covers(start: Vector3, end: Vector3, depth: float) -> bool:
	var candidates := {}
	for index: int in _wide: candidates[index] = true
	for x in range(floori(minf(start.x,end.x)/CELL),floori(maxf(start.x,end.x)/CELL)+1):
		for z in range(floori(minf(start.z,end.z)/CELL),floori(maxf(start.z,end.z)/CELL)+1):
			for index: int in _cells.get(Vector2i(x,z),[]): candidates[index] = true
	var intervals: Array[Vector2] = []
	for index: int in candidates:
		var triangle: Array = _triangles[index]
		var p := weights(start,triangle[0],triangle[1],triangle[2])
		var q := weights(end,triangle[0],triangle[1],triangle[2])
		var interval := Vector2(0,1)
		for axis in 3: interval = clip(interval,p[axis],q[axis])
		var y := Vector3(triangle[0].y,triangle[1].y,triangle[2].y)
		var start_gap := start.y-p.dot(y)
		var end_gap := end.y-q.dot(y)
		interval = clip(interval,start_gap+TOLERANCE,end_gap+TOLERANCE)
		interval = clip(interval,depth-start_gap,depth-end_gap)
		if interval.x <= interval.y: intervals.append(interval)
	intervals.sort_custom(func(a: Vector2,b: Vector2): return a.x < b.x)
	var reached := 0.0
	var tolerance := TOLERANCE/maxf(TOLERANCE,start.distance_to(end))
	for interval: Vector2 in intervals:
		if interval.x > reached+tolerance: return false
		reached = maxf(reached,interval.y)
		if reached >= 1.0-tolerance: return true
	return false
