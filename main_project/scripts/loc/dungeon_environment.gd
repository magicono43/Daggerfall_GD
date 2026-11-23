extends RefCounted
## Checked local spatial queries only. No pose commitment, contact events or breath.
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")
var _water: Array = []
var _areas: Array = []
var _cells := {}
var _wide: Array = []
var _prepared := false
var _qualified := false
const CELL = 16.0
const PROFILE = "bounded-depth-columns-metres-v1"

static func box(value: Array) -> AABB:
	return AABB(Frame.vector(value[0]),Frame.vector(value[1])-Frame.vector(value[0]))

static func contains(bounds_: AABB, point: Vector3) -> bool:
	# Half-open authored bounds avoid double area claims on adjacent floors.
	return point.x >= bounds_.position.x and point.y >= bounds_.position.y and point.z >= bounds_.position.z and point.x < bounds_.end.x and point.y < bounds_.end.y and point.z < bounds_.end.z

func prepare(definition: Dictionary) -> Dictionary:
	_prepared = false
	_qualified = false
	_water = definition.water.duplicate(true)
	_areas = definition.areas.duplicate(true)
	_cells.clear()
	_wide.clear()
	for volume: Dictionary in _water:
		volume.box = box(volume.bounds)
		volume.ceiling = minf(volume.surface,volume.box.end.y)
		var anchor: Vector3 = volume.box.get_center()
		anchor.y = volume.ceiling-minf(0.1,(volume.ceiling-volume.box.position.y)/2.0)
		volume.anchor_point = Frame.vector(volume.anchor) if volume.has("anchor") else anchor
	for area: Dictionary in _areas: area.box = box(area.bounds)
	for a in _water.size():
		for b in range(a+1,_water.size()):
			var first: Dictionary = _water[a]
			var second: Dictionary = _water[b]
			if first.box.intersects(second.box) and first.priority == second.priority and (first.pool != second.pool or first.surface != second.surface): return {"ok":false,"kind":"ambiguous_environment","reason":"Overlapping distinct water contexts need distinct explicit priorities.","volumes":[first.id,second.id]}
			if first.pool == second.pool and first.surface != second.surface: return {"ok":false,"kind":"invalid_environment","reason":"One continuous pool cannot have differing surfaces."}
	for kind in ["water","area"]:
		var values: Array = _water if kind == "water" else _areas
		for index in values.size():
			var bounds_: AABB = values[index].box
			var low := Vector3i(floori(bounds_.position.x/CELL),floori(bounds_.position.y/CELL),floori(bounds_.position.z/CELL))
			var high := Vector3i(floori(bounds_.end.x/CELL),floori(bounds_.end.y/CELL),floori(bounds_.end.z/CELL))
			var entry := {"kind":kind,"index":index}
			if (high.x-low.x+1)*(high.y-low.y+1)*(high.z-low.z+1) > 4096:
				_wide.append(entry)
				continue
			for x in range(low.x,high.x+1):
				for y in range(low.y,high.y+1):
					for z in range(low.z,high.z+1):
						var cell := Vector3i(x,y,z)
						if not _cells.has(cell): _cells[cell] = []
						_cells[cell].append(entry)
	_prepared = true
	return {"ok":true}

func qualify(solid_between: Callable) -> Dictionary:
	_qualified = false
	if not _prepared or not solid_between.is_valid(): return {"ok":false,"kind":"before_readiness","reason":"Valid prepared environmental definitions and a checked geometry provider required."}
	# Reusing a pool name is insufficient evidence of connectivity. This bounded
	# profile requires a straight submerged witness through each joining pair.
	# Curved connections require smaller authored volumes along the real channel.
	var groups := {}
	for index in _water.size():
		var volume: Dictionary = _water[index]
		var checked := ray(solid_between,volume.anchor_point,Vector3(volume.anchor_point.x,volume.ceiling,volume.anchor_point.z))
		if not checked.ok: return checked
		if checked.found: return {"ok":false,"kind":"invalid_environment","reason":"Water anchor is separated from the declared local liquid top by solid geometry.","volume":volume.id}
		var pool: String = _water[index].pool
		if not groups.has(pool): groups[pool] = []
		groups[pool].append(index)
	for pool: String in groups:
		var members: Array = groups[pool]
		if not members.any(func(index: int): return _water[index].box.end.y >= _water[index].surface-Frame.POSITION_TOLERANCE): return {"ok":false,"kind":"invalid_environment","reason":"A submerged pool needs a connected declared free-surface volume.","pool":pool}
		var reached := {members[0]:true}
		var pending: Array = [members[0]]
		while not pending.is_empty():
			var current: int = pending.pop_back()
			var a: Dictionary = _water[current]
			for other: int in members:
				if reached.has(other): continue
				var b: Dictionary = _water[other]
				if not a.box.grow(Frame.POSITION_TOLERANCE).intersects(b.box): continue
				var bottom := maxf(a.box.position.y,b.box.position.y)
				var top := minf(a.ceiling,b.ceiling)
				if bottom >= top-Frame.POSITION_TOLERANCE: continue
				var from: Vector3 = a.anchor_point
				var to: Vector3 = b.anchor_point
				from.y = top-minf(0.1,(top-bottom)/2.0)
				to.y = from.y
				var from_surface: Dictionary = ray(solid_between,from,a.anchor_point)
				var to_surface: Dictionary = ray(solid_between,to,b.anchor_point)
				if not from_surface.ok: return from_surface
				if not to_surface.ok: return to_surface
				if from_surface.found or to_surface.found: continue
				# Route through the shared face/overlap. A direct diagonal between
				# anchors can leave the union of two offset boxes through dry space.
				var portal := Vector3((maxf(a.box.position.x,b.box.position.x)+minf(a.box.end.x,b.box.end.x))/2.0,from.y,(maxf(a.box.position.z,b.box.position.z)+minf(a.box.end.z,b.box.end.z))/2.0)
				var first_leg := ray(solid_between,from,portal)
				var second_leg := ray(solid_between,portal,to)
				if not first_leg.ok: return first_leg
				if not second_leg.ok: return second_leg
				if first_leg.found or second_leg.found: continue
				reached[other] = true
				pending.append(other)
		if reached.size() != members.size(): return {"ok":false,"kind":"disconnected_environment","reason":"Declared continuous pool lacks checked submerged connections.","pool":pool}
	_qualified = true
	return {"ok":true}

static func ray(provider: Callable, from: Vector3, to: Vector3) -> Dictionary:
	return {"ok":true,"found":false} if from == to else provider.call(from,to)

func query(point: Vector3, solid_between: Callable) -> Dictionary:
	if not _qualified: return {"ok":false,"kind":"before_readiness","reason":"Environmental geometry has not passed preparation checks."}
	if not Frame.bounded(point): return {"ok":false,"kind":"unsupported_geometry","reason":"Environmental query exceeds qualified local frame."}
	var candidates: Array = _wide + _cells.get(Vector3i(floori(point.x/CELL),floori(point.y/CELL),floori(point.z/CELL)),[])
	var water := {}
	var areas: Array = []
	var unproved_priority := -2147483649
	for entry: Dictionary in candidates:
		var value: Dictionary = (_water if entry.kind == "water" else _areas)[entry.index]
		if not contains(value.box,point): continue
		if entry.kind == "area":
			areas.append({"id":value.id,"uses":value.uses.duplicate(),"source":value.source.duplicate(true)})
			continue
		if point.y >= value.surface: continue
		# A bridge/floor between the checked sample and this surface excludes that
		# column. This bounded vertical-column profile does not infer lateral flow.
		var checked: Dictionary = ray(solid_between,point,Vector3(point.x,value.ceiling,point.z))
		if not checked.ok: return checked
		if checked.found: continue
		# Every positive membership has a submerged path to its checked component
		# anchor. One broad extent or a matching surface cannot join isolated pools.
		var height := maxf(point.y,value.ceiling-minf(0.1,(value.ceiling-value.box.position.y)/2.0))
		var local := Vector3(point.x,height,point.z)
		var anchor := Vector3(value.anchor_point.x,height,value.anchor_point.z)
		var path_a := ray(solid_between,value.anchor_point,anchor)
		var path_b := ray(solid_between,local,anchor)
		if not path_a.ok: return path_a
		if not path_b.ok: return path_b
		if path_a.found or path_b.found:
			unproved_priority = maxi(unproved_priority,value.priority)
			continue
		if water.is_empty() or value.priority > water.priority:
			water = {"id":value.id,"pool":value.pool,"surface":value.surface,"bounds":value.bounds.duplicate(true),"depth_below_surface":value.surface-point.y,"priority":value.priority,"source":value.source.duplicate(true)}
	areas.sort_custom(func(a: Dictionary,b: Dictionary): return a.id < b.id)
	if unproved_priority != -2147483649 and (water.is_empty() or unproved_priority >= water.priority): return {"ok":false,"kind":"unsupported_environment","reason":"Selected wet column has no checked path to a declared pool anchor; refine required extent/anchor coverage rather than falling back to a lower priority."}
	return {"ok":true,"water":water,"areas":areas,"water_absent":water.is_empty(),"areas_absent":areas.is_empty(),"pose_authoritative":false,"contact_committed":false,"events":[]}

func projection() -> Dictionary:
	if not _qualified: return {"ok":false,"kind":"before_readiness","reason":"Environmental geometry has not passed preparation checks."}
	var water := _water.duplicate(true)
	var areas := _areas.duplicate(true)
	for definition: Dictionary in water:
		definition.checked_anchor = [definition.anchor_point.x,definition.anchor_point.y,definition.anchor_point.z]
		definition.local_top = definition.ceiling
		definition.erase("anchor_point")
		definition.erase("ceiling")
	for definition: Dictionary in water+areas: definition.erase("box")
	return {"ok":true,"schema":"checked-dungeon-environment-v1","profile":PROFILE,"water":water,"areas":areas,"pose_authoritative":false,"contact_committed":false,"events":[]}
