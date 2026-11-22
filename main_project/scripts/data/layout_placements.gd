extends RefCounted
## MAPS structural inputs. Geographic identity comes from accepted geography.
const F = preload("res://scripts/data/layout_formats.gd")
const Cursor = preload("res://scripts/data/media_cursor.gd")
const PREFIXES = ["TVRN","GENR","RESI","WEAP","ARMR","ALCH","BANK","BOOK","CLOT","FURN","GEMS","LIBR","PAWN","TEMP","TEMP","PALA","FARM","DUNG","CAST","MANR","SHRI","RUIN","SHCK","GRVE","FILL","KRAV","KDRA","KOWL","KMOO","KCAN","KFLA","KHOR","KROS","KWHE","KSCA","KHAW","MAGE","THIE","DARK","FIGH","CUST","WALL","MARK","SHIP","WITC"]

static func element(c: RefCounted) -> Dictionary:
	var count: int = c.u32()
	if not c.has(count*6+112): return {}
	var doors: Array = []
	for i in count: doors.append({"building_index":c.u16(),"raw":c.take(4).hex_encode()})
	var at: int = c.position
	var raw: PackedByteArray = c.take(112)
	return {"doors":doors,"header_raw":raw.hex_encode(),"header_address":at,"location_id":raw.decode_u16(33)}

static func exterior(b: PackedByteArray, offset: int, source: String) -> Dictionary:
	var c := Cursor.new(b,offset)
	var header := element(c)
	if header.is_empty(): return F.fail(c.reason,source,offset)
	if not c.has(7): return F.fail(c.reason,source,offset)
	var count := c.u16()
	var unknown := c.take(5).hex_encode()
	if not c.has(count*26+416): return F.fail(c.reason,source,offset)
	var buildings: Array = []
	for i in count: buildings.append(F.building(c))
	var at: int = c.position
	var raw: PackedByteArray = c.take(416)
	var width: int = raw[40]
	var height: int = raw[41]
	if width < 1 or height < 1 or width*height > 64: return F.fail("Exterior dimensions exceed encoded slots.",source,at)
	var placements: Array = []
	for i in width*height:
		var index: int = raw[49+i]
		var number: int = raw[113+i]
		var character: int = raw[177+i]
		if index >= PREFIXES.size(): return F.fail("Unsupported exterior block prefix.",source,at+49+i,index,"unsupported")
		var letter1 := String.chr(raw[46]) if character & 16 else "A"
		var letter2: String = ["A","L","M","S"][(character & 127)>>5]
		var digits := String.chr((character & 15)+65)+str(number) if index in [13,14] else "%02d" % number
		placements.append({"source_ordinal":i,"context":"exterior","grid":[i%width,i/width],"block_name":PREFIXES[index]+letter1+letter2+digits+".RMB","source_codes":[index,number,character]})
	return {"ok":true,"header":header,"buildings":buildings,"unknown":unknown,"exterior_raw":raw.hex_encode(),"width":width,"height":height,"placements":placements,"end":c.position}

static func dungeon(b: PackedByteArray, location_id: int, source: String) -> Dictionary:
	if b.is_empty(): return {"ok":true,"present":false,"placements":[]}
	var c := Cursor.new(b)
	var count := c.u32()
	if not c.has(count*8): return F.fail(c.reason,source)
	var offset := -1
	for i in count:
		var address := c.u32()
		var is_dungeon := c.u16()
		var exterior_id := c.u16()
		if exterior_id == location_id:
			if offset >= 0: return F.fail("Ambiguous dungeon location mapping.",source,location_id)
			offset = address+4+count*8
			if is_dungeon == 0: return F.fail("Required dungeon directory entry is not a dungeon.",source,location_id)
	if offset < 0: return {"ok":true,"present":false,"placements":[]}
	c.seek(offset)
	var header := element(c)
	if header.is_empty() or not c.has(17): return F.fail(c.reason,source,offset)
	var raw := c.take(10).hex_encode()
	var block_count := c.u16()
	var unknown := c.take(5).hex_encode()
	if not c.has(block_count*4): return F.fail(c.reason,source,offset)
	var placements: Array = []
	for i in block_count:
		var x := c.u8()
		var z := c.u8()
		if x > 127: x -= 256
		if z > 127: z -= 256
		var bits := c.u16()
		var index := bits >> 11
		if index >= 6: return F.fail("Unsupported dungeon block class.",source,i,index,"unsupported")
		placements.append({"source_ordinal":i,"context":"dungeon","grid":[x,z],"starting_block":bool(bits & 1024),"source_bits":bits,"block_name":"%s%07d.RDB" % [["N","W","L","S","B","M"][index],bits & 1023]})
	return {"ok":true,"present":true,"header":header,"raw":raw,"unknown":unknown,"placements":placements,"end":c.position}
