extends RefCounted
## Classic binary interpretation only. Never generated terrain or physics units.
const Common = preload("res://scripts/data/actor_input_formats.gd")
const FORMATS = ["woods-source-v1", "geography-pak-v1"]
const FRAME = "geography-pixel-north-down-v1"

static func fail(kind: String, reason: String, source := "", record: Variant = null) -> Dictionary:
	return {"ok":false,"schema":"geography-source-diagnostic-v1","kind":kind,"reason":reason,"source":source,"record":record}

static func decode(format: String, bytes: PackedByteArray, source := "") -> Dictionary:
	if format == "geography-pak-v1": return pak(bytes,source)
	if format == "woods-source-v1": return woods(bytes,source)
	return fail("unsupported","Unknown geographic format.",source)

static func pak(b: PackedByteArray, source := "") -> Dictionary:
	if b.size() < 2000: return fail("malformed","Truncated PAK row directory.",source)
	var samples := PackedByteArray()
	var expected := 2000
	for y in 500:
		var offset := b.decode_u32(y*4)
		if offset != expected: return fail("malformed","PAK row offset/gap/overlap is invalid.",source,y)
		var count := 0
		while count < 1001:
			if offset+3 > b.size(): return fail("malformed","Truncated PAK run.",source,y)
			var run := b.decode_u16(offset)
			if run == 0 or count+run > 1001: return fail("malformed","Zero/overflow PAK run.",source,y)
			for i in run: samples.append(b[offset+2])
			count += run
			offset += 3
		expected = offset
	# Selected POLITIC contains an unused tool attribution, not another row.
	if expected != b.size() and Common.sha256(b.slice(expected)) != "3da1f0ca3871dbfd542cdd2f1f238e4fcd9f0025674023d7759c94a1108137d9": return fail("malformed","Unrecognized trailing PAK data.",source)
	return {"ok":true,"samples":samples,"width":1001,"height":500,"unit":"classic-code-u8"}

static func woods(b: PackedByteArray, source := "") -> Dictionary:
	if b.size() < 2000144: return fail("malformed","Truncated WOODS header/index.",source)
	if b.decode_u32(0) != 2000000 or b.decode_u32(4) != 1000 or b.decode_u32(8) != 500: return fail("unsupported","Unsupported WOODS dimensions/index size.",source)
	var start := b.decode_u32(28)
	if start < 2000144 or start+500000 > b.size(): return fail("malformed","Invalid coarse sample extent.",source)
	var offsets := PackedInt64Array()
	for i in 500000:
		var offset := b.decode_u32(144+i*4)
		if offset < start+500000 or offset+47 > b.size(): return fail("malformed","Missing required detail cell extent.",source,i)
		offsets.append(offset)
	# Unknown header/cell metadata is retained, never interpreted as terrain rules.
	return {"ok":true,"samples":b.slice(start,start+500000),"offsets":offsets,"header":b.slice(0,144),"width":1000,"height":500,"unit":"classic-height-u8"}

static func region(names: PackedByteArray, table: PackedByteArray, pitem: PackedByteArray, source := "") -> Dictionary:
	if names.is_empty() and table.is_empty() and pitem.is_empty(): return {"ok":true,"locations":[]}
	if names.size() < 4: return fail("malformed","Truncated region count.",source)
	var count := names.decode_u32(0)
	if count > 100000 or names.size() != 4+32*count or table.size() != 17*count or pitem.size() < 4*count: return fail("malformed","Region names/table/offset count mismatch or trailing bytes.",source)
	var result: Array = []
	for i in count:
		var name_bytes := names.slice(4+i*32,4+(i+1)*32)
		var end := name_bytes.find(0)
		if end < 0: end = 32 # Full fixed-width name has no terminator.
		if end == 0: return fail("malformed","Empty classic location name.",source,i)
		for c in name_bytes.slice(0,end):
			if c < 32 or c > 126: return fail("unsupported","Unsupported classic name encoding.",source,i)
		var offset := count*4+pitem.decode_u32(i*4)
		if offset < count*4 or offset+4 > pitem.size(): return fail("malformed","Invalid exterior geographic header offset.",source,i)
		var quest_offset := offset+4+pitem.decode_u32(offset)*6+33
		if quest_offset+2 > pitem.size(): return fail("malformed","Truncated exterior quest mapping.",source,i)
		var bits := table.decode_u32(i*17+4)
		var lon := (bits & 0x1ffffff) >> 8
		var lat := (table.decode_u32(i*17+8) & 0xffffff) >> 8
		var x := lon/128
		var y := 499-lat/128
		if x < 0 or x >= 1000 or y < 0 or y >= 500: return fail("malformed","Classic location outside source frame.",source,i)
		result.append({"name":name_bytes.slice(0,end).get_string_from_ascii(),"pixel":[x,y],"longitude":lon,"latitude":lat,"full_map":table.decode_u32(i*17),"map_key":y*1000+x,"quest_id":pitem.decode_u16(quest_offset),"type":(bits>>25)&31,"dungeon":table[i*17+12],"source_discovered":bool(bits & 0x40000000),"key":table.decode_u32(i*17+13),"ordinal":i,"pitem_offset":offset,"quest_offset":quest_offset,"raw_table":table.slice(i*17,(i+1)*17).hex_encode()})
	return {"ok":true,"locations":result}

static func convert(frame: String, unit: String, coordinates: Array, target: String) -> Dictionary:
	if frame != "classic-longitude-latitude-v1" or unit != "classic-map-tile" or target != FRAME: return fail("unsupported_conversion","WORLD/LOC/MOVE geometry conversion is unavailable.")
	if coordinates.size() != 2 or not Common.integer(coordinates[0],0,127999) or not Common.integer(coordinates[1],0,63999): return fail("out_of_bounds","Coordinate outside declared classic source frame.")
	var longitude := int(coordinates[0])
	var latitude := int(coordinates[1])
	return {"ok":true,"frame":FRAME,"unit":"map-pixel","coordinates":[longitude/128,499-latitude/128],"subtile":[longitude%128,latitude%128],"subtile_frame":"classic-map-tile-north-up-v1","rounding":"floor nonnegative source axes; retain exact remainder separately","tolerance":0,"physics_ready":false}

static func source_from_pixel(pixel: Array, subtile: Array) -> Dictionary:
	if pixel.size() != 2 or subtile.size() != 2 or not Common.integer(pixel[0],0,999) or not Common.integer(pixel[1],0,499) or not Common.integer(subtile[0],0,127) or not Common.integer(subtile[1],0,127): return fail("out_of_bounds","Invalid classic pixel/subtile coordinate.")
	return {"ok":true,"frame":"classic-longitude-latitude-v1","unit":"classic-map-tile","coordinates":[int(pixel[0])*128+int(subtile[0]),(499-int(pixel[1]))*128+int(subtile[1])],"tolerance":0,"physics_ready":false}

