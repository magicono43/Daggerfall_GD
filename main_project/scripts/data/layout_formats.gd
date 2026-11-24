extends RefCounted
## Structural source decoder only. No scene, physics or gameplay state.
const Cursor = preload("res://scripts/data/media_cursor.gd")
const VERSION = "classic-layout-source-v1"
const RMB_HEADER = 6776
const RDB_ROOTS = 9532
const ACTIONS = [0,1,2,3,4,5,6,7,8,9,11,12,14,16,17,18,20,21,22,23,24,25,26,28,29,30,31,99]

static func fail(reason: String, source := "", record: Variant = null, target: Variant = null, kind := "malformed") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"source":source,"record":record,"target":target,"provider":"classic","schema":VERSION}

static func xyz(c: RefCounted) -> Array:
	return [c.s32(),c.s32(),c.s32()]

static func text(b: PackedByteArray) -> String:
	var end := b.find(0)
	return b.slice(0,end if end >= 0 else b.size()).get_string_from_ascii()

static func transform(position: Array, rotation: Array) -> Dictionary:
	return {"frame":"classic-block-local-v1","position":position,"position_unit":"classic-layout-integer","rotation":rotation,"rotation_unit":"classic-angle-2048","scale":[1,1,1]}

static func flat_texture(bits: int) -> Dictionary:
	return {"archive":bits >> 7,"record":bits & 127,"raw":bits}

static func marker(texture: Dictionary) -> String:
	if texture.archive != 199: return ""
	# Authored JSON numbers are floats after validation; dictionary key lookup
	# must use the checked integral record identity, like the binary decoder.
	return {8:"dungeon-entrance",10:"dungeon-start",11:"quest",18:"quest-item"}.get(int(texture.record),"editor-other")

static func environment(records: Array) -> Dictionary:
	# Metadata observation is independent of arrival role selection. All matching
	# records must agree; enumeration order never chooses environmental meaning.
	var markers: Array = []
	var levels := {}
	var castle := {}
	for record: Dictionary in records:
		if record.get("type") != "flat" or record.get("texture",{}).get("archive") != 199 or record.texture.record != 10: continue
		var sound := int(record.sound_index)
		var native_height := -8*sound if sound != 0 else 10000
		levels[native_height] = true
		castle[int(record.magnitude) != 0] = true
		markers.append({"record":record.get("id",record.get("address")),"sound_index":sound,"magnitude":record.magnitude,"native_height":native_height})
	if levels.size() > 1 or castle.size() > 1: return fail("Conflicting environmental marker metadata requires an explicit validated override.","RDB",markers,null,"ambiguous_environment")
	return {"ok":true,"schema":"classic-rdb-environment-observation-v1","markers":markers,"water_present":not levels.is_empty() and not levels.has(10000),"native_height":levels.keys()[0] if not levels.is_empty() else 10000,"castle":castle.has(true),"extents_ready":false,"arrival_selected":false,"mapping":"dfu-1.1.1-start-metadata-v1"}

static func claim_extent(mask: PackedByteArray, claims: Dictionary, at: int, count: int, kind: String) -> bool:
	if at < 0 or count < 0 or at > mask.size()-count: return false
	if claims.has(at): return claims[at].count == count and claims[at].kind == kind
	for i in count:
		if mask[at+i] != 0: return false
	for i in count: mask[at+i] = 1
	claims[at] = {"count":count,"kind":kind}
	return true

static func building(c: RefCounted) -> Dictionary:
	return {"name_seed":c.u16(),"service_time_limit":c.u32(),"unknown": [c.u16(),c.u16(),c.u32(),c.u32()],"faction_id":c.u16(),"sector":c.s16(),"location_id":c.u16(),"building_type":c.u8(),"quality":c.u8()}

static func rmb_records(c: RefCounted, count: int, kind: String, scope: String) -> Array:
	var records: Array = []
	var stride: int = {"model":66,"flat":17,"section3":16,"person":17,"door":19}[kind]
	if not c.has(count*stride): return records
	for i in count:
		var at: int = c.position
		var r := {"address":at,"scope":scope,"type":kind,"source_ordinal":i}
		match kind:
			"model":
				r.model_parts = [c.s16(),c.u8()]
				r.model_id = r.model_parts[0]*100+r.model_parts[1]
				r.object_type = c.u8()
				r.unknown_prefix = c.take(20).hex_encode()
				r.position1 = xyz(c)
				r.transform = transform(xyz(c),[0,0,0])
				r.null2 = c.u32()
				r.transform.rotation[1] = c.s16()
				r.unknown_suffix = c.take(12).hex_encode()
			"flat", "person":
				r.transform = transform(xyz(c),[0,0,0])
				r.texture = flat_texture(c.u16())
				r.faction_id = c.s16()
				r.flags = c.u8()
				r.marker_purpose = marker(r.texture)
			"section3":
				r.transform = transform(xyz(c),[0,0,0])
				r.uninterpreted = c.take(4).hex_encode()
			"door":
				r.transform = transform(xyz(c),[0,c.s16(),0])
				r.open_rotation = c.s16()
				r.door_model_index = c.u8()
				r.unknown = c.u8()
				r.null_value = c.u8()
		r.raw = c.bytes.slice(at,at+stride).hex_encode()
		records.append(r)
	return records

static func rmb_sub(c: RefCounted, scope: String) -> Dictionary:
	if not c.has(17): return {}
	var counts := [c.u8(),c.u8(),c.u8(),c.u8(),c.u8()]
	var result := {"scope":scope,"counts":counts,"unknown_header":c.take(12).hex_encode(),"records":[]}
	var kinds := ["model","flat","section3","person","door"]
	for i in 5: result.records.append_array(rmb_records(c,counts[i],kinds[i],scope))
	return result

static func rmb(b: PackedByteArray, source: String) -> Dictionary:
	var c := Cursor.new(b)
	if not c.has(RMB_HEADER): return fail(c.reason,source)
	var count := c.u8()
	var misc_models := c.u8()
	var misc_flats := c.u8()
	if count > 32: return fail("RMB building count exceeds fixed slots.",source)
	var positions: Array = []
	for i in 32: positions.append({"unknown":[c.u32(),c.u32()],"x":c.s32(),"z":c.s32(),"y_rotation":c.s32()})
	var buildings: Array = []
	for i in 32: buildings.append(building(c))
	var unknown := c.take(128).hex_encode()
	var sizes: Array = []
	for i in 32: sizes.append(c.s32())
	var ground_header := c.take(8).hex_encode()
	var ground_tiles := c.take(256)
	var ground_scenery := c.take(256)
	var tiles: Array = []
	var scenery: Array = []
	for i in 256:
		var tile: int = ground_tiles[i]
		var item: int = ground_scenery[i]
		tiles.append({"record":tile & 63,"rotated":bool(tile & 64),"flipped":bool(tile & 128),"raw":tile})
		scenery.append({"record":item/4-1 if item < 255 else -1,"unknown":item & 3 if item < 255 else 0,"raw":item})
	var automap := c.take(4096)
	var names := c.take(429).hex_encode()
	var subrecords: Array = []
	var records: Array = []
	for i in count:
		var at: int = c.position
		if sizes[i] < 34 or not c.has(sizes[i]): return fail("Invalid RMB building extent.",source,i)
		var child := Cursor.new(b,at,at+sizes[i])
		var outside := rmb_sub(child,"building/%d/exterior" % i)
		var inside := rmb_sub(child,"building/%d/interior" % i)
		if not child.reason.is_empty(): return fail(child.reason,source,i)
		subrecords.append({"source_ordinal":i,"position":positions[i],"building":buildings[i],"exterior":outside,"interior":inside,"unused_tail":child.take(child.limit-child.position).hex_encode()})
		records.append_array(outside.records)
		records.append_array(inside.records)
		c.seek(at+sizes[i])
	records.append_array(rmb_records(c,misc_models,"model","misc/exterior"))
	records.append_array(rmb_records(c,misc_flats,"flat","misc/exterior"))
	if not c.reason.is_empty(): return fail(c.reason,source)
	if c.position != b.size(): return fail("Unclassified trailing RMB bytes.",source,c.position)
	return {"ok":true,"format":"RMB","source":source,"records":records,"subrecords":subrecords,"positions":positions,"buildings":buildings,"sizes":sizes,"unknown":unknown,"ground":{"header":ground_header,"tiles":ground_tiles,"scenery":ground_scenery,"decoded_tiles":tiles,"decoded_scenery":scenery},"automap":automap,"names_raw":names}

static func rdb(b: PackedByteArray, source: String) -> Dictionary:
	var c := Cursor.new(b)
	if not c.has(RDB_ROOTS): return fail(c.reason,source)
	var header := {"unknown1":c.u32(),"width":c.u32(),"height":c.u32(),"root_offset":c.u32(),"unknown2":c.u32()}
	var available_roots := (b.size()-RDB_ROOTS)/4
	# Bound each factor before multiplication to exclude signed-64 overflow.
	if header.root_offset != RDB_ROOTS or header.width < 1 or header.height < 1 or header.width > available_roots or header.height > available_roots or header.width*header.height > available_roots: return fail("Invalid RDB root table extent.",source)
	var models: Array = []
	for i in 750: models.append({"model_id":text(c.take(5)),"description":text(c.take(3))})
	var model_data := c.take(750*4).hex_encode()
	# Object section header is 512 bytes. Its unused linked-list is retained raw.
	var section := c.take(512).hex_encode()
	if c.position != RDB_ROOTS: return fail("RDB schema root mismatch.",source,c.position)
	var roots: Array = []
	for i in header.width*header.height: roots.append(c.s32())
	var records: Array = []
	var addresses := {}
	var mask := PackedByteArray()
	mask.resize(b.size())
	var claims := {}
	for root in roots.size():
		var next: int = roots[root]
		var visited := {}
		while next >= 0:
			if visited.has(next): return fail("Cycle in object enumeration chain (not action graph).",source,next)
			visited[next] = true
			if addresses.has(next): return fail("Object belongs to multiple roots.",source,next)
			c.seek(next)
			if next < RDB_ROOTS+roots.size()*4 or not c.has(25): return fail("Invalid RDB object extent.",source,next)
			if not claim_extent(mask,claims,next,25,"object"): return fail("Overlapping RDB object headers.",source,next)
			var r := {"address":next,"root":root,"next":c.s32(),"previous":c.s32(),"transform":transform(xyz(c),[0,0,0]),"type_code":c.u8(),"resource_offset":c.u32()}
			addresses[next] = records.size()
			records.append(r)
			next = r.next
	for r: Dictionary in records:
		if r.resource_offset < RDB_ROOTS+roots.size()*4: return fail("Resource points into fixed header/root inventory.",source,r.address,r.resource_offset)
		c.seek(r.resource_offset)
		var size: int = {1:23,2:10,3:11}.get(r.type_code,0)
		if size == 0: return fail("Unsupported required RDB resource type.",source,r.address,r.type_code,"unsupported")
		if not c.has(size): return fail(c.reason,source,r.address,r.resource_offset)
		if not claim_extent(mask,claims,r.resource_offset,size,"resource-%d" % r.type_code): return fail("Overlapping required RDB resource extent.",source,r.address,r.resource_offset)
		r.raw_resource = b.slice(c.position,c.position+size).hex_encode()
		match r.type_code:
			1:
				r.type = "model"
				r.transform.rotation = xyz(c)
				r.model_index = c.u16()
				if r.model_index >= 750: return fail("RDB model reference out of bounds.",source,r.address,r.model_index)
				r.model = models[r.model_index].duplicate(true)
				if not r.model.model_id.is_valid_int(): return fail("Required model ID is not numeric.",source,r.address,r.model)
				r.model_id = int(r.model.model_id)
				r.door_metadata = {"classification":"dfu-rdb-door-tags-v1","description":r.model.description,"candidate":r.model_id != 72100 and r.model.description in ["DOR","DDR","NEW","CAV"]}
				r.trigger_starting_lock = c.u32()
				r.sound_index = c.u8()
				r.action_offset = c.s32()
				if r.action_offset > 0:
					if r.action_offset < RDB_ROOTS+roots.size()*4: return fail("Action points into fixed header/root inventory.",source,r.address,r.action_offset)
					c.seek(r.action_offset)
					if not c.has(10): return fail(c.reason,source,r.address,r.action_offset)
					if not claim_extent(mask,claims,r.action_offset,10,"action"): return fail("Overlapping required RDB action extent.",source,r.address,r.action_offset)
					r.action = {"axis":c.u8(),"duration":c.u16(),"magnitude":c.u16(),"target_address":c.s32(),"kind":c.u8()}
			3:
				r.type = "flat"
				r.texture = flat_texture(c.u16())
				r.flags = c.u16()
				r.magnitude = c.u8()
				r.sound_index = c.u8()
				r.action = {"target_address":c.s32(),"kind":c.u8()}
				r.marker_purpose = marker(r.texture)
			2:
				r.type = "light"
				r.unknown = [c.u32(),c.u32()]
				r.radius = c.u16()
		if r.has("action"):
			if r.action.kind not in ACTIONS:
				# Unknown vanilla bytes are evidence, never executable graph edges.
				# Preserve the complete payload and original target without claiming
				# that a missing destination is required by an unknown operation.
				r.unused_action = {"policy":"classic-unknown-action-metadata-v1","non_executing":true,"gameplay_owner_ready":false,"raw":r.action.duplicate(true)}
				r.erase("action")
				continue
			if r.type == "model" and r.action.kind in [1,8] and r.action.axis > 6:
				# A raw byte outside the axis enum is not structural corruption.
				# DFU RDBLayout accepts it: TRP rotation/13 uses NegativeX, magnitude
				# 400; other unrecognised values leave the motion vector zero.
				# Keep the known action and required graph edges; a future action
				# owner must implement/qualify the documented interpretation.
				var baseline := "rotation-negative-x-magnitude-400" if r.action.kind == 8 and r.action.axis == 13 and r.model.description == "TRP" else "zero-motion-vector"
				r.action_axis_metadata = {"policy":"classic-action-axis-metadata-v1","gameplay_owner_ready":false,"raw":r.action.duplicate(true),"dfu_baseline":baseline}
			var target: int = r.action.target_address
			# Object address zero is the file header. Classic consumers leave it unbound.
			# Teleport explicitly requires a destination; other kinds may terminate here.
			# RDBLayout creates no action component for kind 0. Its outgoing field
			# is retained raw, but is not a required executable graph edge. Such a
			# record can still be the required destination of another action.
			r.action.link_required = r.action.kind != 0 and (target > 0 or r.action.kind == 14)
			r.action.link_classification = "unused-no-action" if r.action.kind == 0 else ("required" if r.action.link_required else "absent")
			if r.action.link_required and not addresses.has(target): return fail("Action target absent from block scope.",source,r.address,target)
	return {"ok":true,"format":"RDB","source":source,"header":header,"models":models,"model_data_raw":model_data,"section_raw":section,"roots":roots,"records":records,"source_bytes":b.hex_encode()}

static func decode(b: PackedByteArray, source: String) -> Dictionary:
	match source.get_extension().to_upper():
		"RMB": return rmb(b,source)
		"RDB": return rdb(b,source)
	return fail("Required block format is unsupported.",source,null,null,"unsupported")
