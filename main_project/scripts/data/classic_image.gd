extends RefCounted
## Indexed, top-left-first classic imagery; palette/alpha interpretation is explicit.
const Cursor = preload("res://scripts/data/media_cursor.gd")
const VERSION = "classic-image-v1"
const RCI_SIZES = {"FACES.CIF": Vector2i(64,64), "CHLD00I0.RCI": Vector2i(64,64),
	"TFAC00I0.RCI": Vector2i(64,64), "BUTTONS.RCI": Vector2i(32,16),
	"MPOP.RCI": Vector2i(17,17), "NOTE.RCI": Vector2i(44,9), "SPOP.RCI": Vector2i(22,22)}
const EMBEDDED = ["CHGN00I0.IMG", "DIE_00I0.IMG", "PICK02I0.IMG", "PICK03I0.IMG", "PRIS00I0.IMG", "TITL00I0.IMG"]
const HEADERLESS = {289: Vector2i(17,17), 441: Vector2i(49,9), 512: Vector2i(32,16),
	720: Vector2i(9,80), 990: Vector2i(45,22), 1720: Vector2i(43,40), 2140: Vector2i(107,20),
	2916: Vector2i(81,36), 3200: Vector2i(40,80), 3938: Vector2i(179,22), 4280: Vector2i(107,40),
	4508: Vector2i(322,14), 20480: Vector2i(320,64), 26496: Vector2i(184,144),
	64000: Vector2i(320,200), 64768: Vector2i(320,200), 68800: Vector2i(320,215), 112128: Vector2i(512,219)}

func failure(reason: String, offset := 0, kind := "malformed_or_unsupported") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"position":offset,"converter":VERSION}

func palette(bytes: PackedByteArray, six_bit := false) -> Dictionary:
	if bytes.size() not in [768,776]: return failure("Palette must contain 768 RGB bytes, optionally with an 8-byte COL header.")
	var rgb := bytes.slice(bytes.size() - 768)
	if six_bit:
		for index in rgb.size():
			if rgb[index] > 63: return failure("Six-bit palette component exceeds 63.",index)
			rgb[index] *= 4
	return {"ok":true,"domain":"palette","rgb":rgb,"entries":256,"component_encoding":"rgb-u8"}

func rgba(image: Dictionary, colors: Dictionary, alpha_index: int) -> Dictionary:
	if not image.get("ok",false) or not colors.get("ok",false): return failure("Decoded image and palette required.")
	if alpha_index < -1 or alpha_index > 255: return failure("Alpha index must be -1 (opaque) or a palette index.")
	var indices: PackedByteArray = image.indices
	var rgb: PackedByteArray = colors.rgb
	if rgb.size() != 768: return failure("Invalid decoded palette.")
	var output := PackedByteArray()
	output.resize(indices.size() * 4)
	for index in indices.size():
		var entry := int(indices[index])
		for channel in 3: output[index * 4 + channel] = rgb[entry * 3 + channel]
		output[index * 4 + 3] = 0 if entry == alpha_index else 255
	return {"ok":true,"rgba":output,"width":image.width,"height":image.height,"alpha_index":alpha_index}

func _header(cursor: RefCounted) -> Dictionary:
	var at: int = cursor.position
	if not cursor.has(12): return {}
	return {"offset":at,"x":cursor.s16(),"y":cursor.s16(),"width":cursor.s16(),"height":cursor.s16(),
		"compression":cursor.u16(),"length":cursor.u16(),"data":cursor.position,"frames":1}

func _valid_size(width: int, height: int, bytes: int) -> bool:
	# Encoded dimensions are signed 16-bit. The input bounds allocation for supported data.
	return width > 0 and height > 0 and width <= 32767 and height <= 32767 and width * height <= bytes * 129

func _rle(cursor: RefCounted, length: int) -> PackedByteArray:
	var output := PackedByteArray()
	while output.size() < length and cursor.has(1):
		var code: int = cursor.u8()
		var count: int = code - 127 if code > 127 else code + 1
		if count > length - output.size():
			cursor.reason = "RLE run exceeds decoded extent."
			break
		if code > 127:
			if not cursor.has(1): break
			var pixel: int = cursor.u8()
			for unused in count: output.append(pixel)
		else:
			output.append_array(cursor.take(count))
	return output

func decode(bytes: PackedByteArray, name: String, record: int, frame: int) -> Dictionary:
	name = name.to_upper()
	if record < 0 or frame < 0: return failure("Negative record/frame.",0,"record_not_found")
	if name.begins_with("TEXTURE."): return _texture(bytes,record,frame)
	if RCI_SIZES.has(name):
		var size: Vector2i = RCI_SIZES[name]
		var stride := size.x * size.y
		if bytes.is_empty() or bytes.size() % stride != 0: return failure("RCI length is not an exact record multiple.")
		if frame != 0 or record >= bytes.size() / stride: return failure("RCI record/frame absent.",0,"record_not_found")
		return _image(size.x,size.y,0,0,record,frame,1,bytes.size() / stride,record * stride,bytes.slice(record * stride,(record + 1) * stride))
	if name.ends_with(".RCI"): return failure("Unsupported RCI filename/dimension mapping.")
	if name.contains("WEAPO"): return failure("Weapon animation CIF is not in the v1 decoded inventory.")
	if not name.ends_with(".IMG") and not name.ends_with(".CIF"): return failure("Unsupported image family.")
	var cursor := Cursor.new(bytes)
	var headers: Array[Dictionary] = []
	if name.ends_with(".IMG") and HEADERLESS.has(bytes.size()):
		var size: Vector2i = HEADERLESS[bytes.size()]
		headers.append({"offset":0,"data":0,"width":size.x,"height":size.y,"x":0,"y":0,"length":size.x * size.y,"compression":0,"frames":1})
	else:
		while cursor.position < cursor.limit and cursor.reason.is_empty():
			var header := _header(cursor)
			if header.is_empty(): break
			if header.length == 0 or not _valid_size(header.width,header.height,bytes.size()): return failure("Invalid image dimensions or encoded length.",header.offset)
			headers.append(header)
			cursor.seek(header.data + header.length)
			if name.ends_with(".IMG"): break
	if not cursor.reason.is_empty(): return failure(cursor.reason,cursor.position)
	if record >= headers.size() or frame != 0: return failure("Image record/frame absent.",0,"record_not_found")
	var selected: Dictionary = headers[record]
	cursor = Cursor.new(bytes,selected.data,selected.data + selected.length)
	var count: int = selected.width * selected.height
	var indices := PackedByteArray()
	if selected.compression == 0:
		if selected.length != count: return failure("Uncompressed image length differs from dimensions.",selected.offset)
		indices = cursor.take(count)
	elif selected.compression == 2 and name.ends_with(".CIF"):
		indices = _rle(cursor,count)
	else: return failure("Unsupported IMG/CIF compression %d." % selected.compression,selected.offset)
	if not cursor.reason.is_empty() or indices.size() != count: return failure(cursor.reason,cursor.position)
	if cursor.position != cursor.limit: return failure("Unexplained trailing encoded image bytes.",cursor.position)
	var result := _image(selected.width,selected.height,selected.x,selected.y,record,frame,1,headers.size(),selected.data,indices)
	if name in EMBEDDED:
		var end: int = selected.data + selected.length
		if end + 768 != bytes.size(): return failure("Embedded palette extent differs from file length.",end)
		var colors := palette(bytes.slice(end),true)
		if not colors.ok: return colors
		result.embedded_palette = colors
	elif name.ends_with(".IMG") and selected.data + selected.length != bytes.size():
		return failure("Unexplained trailing IMG data.",selected.data + selected.length)
	return result

func _image(width: int, height: int, x: int, y: int, record: int, frame: int, frames: int, records: int, position: int, indices: PackedByteArray) -> Dictionary:
	return {"ok":true,"domain":"image","width":width,"height":height,"offset_x":x,"offset_y":y,
		"record":record,"frame":frame,"frame_count":frames,"record_count":records,"position":position,
		"indices":indices,"orientation":"row-major-top-left","palette_policy":"explicit","converter":VERSION}

func _texture(bytes: PackedByteArray, record: int, frame: int) -> Dictionary:
	var cursor := Cursor.new(bytes)
	var records := cursor.s16()
	if records < 0 or records > (bytes.size() - 26) / 20: return failure("Invalid texture directory count.")
	if record >= records: return failure("Texture record absent.",0,"record_not_found")
	cursor.seek(26 + record * 20 + 2)
	var start := cursor.s32()
	if start < 26 + records * 20 or start > bytes.size() - 28: return failure("Texture record header outside payload.",start)
	cursor.seek(start)
	var x := cursor.s16()
	var y := cursor.s16()
	var width := cursor.s16()
	var height := cursor.s16()
	var compression := cursor.u16()
	var length := cursor.u32()
	var data := cursor.u32()
	var normal := cursor.s16()
	var frames := cursor.u16()
	var unknown := cursor.s16()
	var scale_x := cursor.s16()
	var scale_y := cursor.s16()
	if not cursor.reason.is_empty() or length < 28 or data < 28 or data >= bytes.size() - start or not _valid_size(width,height,bytes.size()):
		return failure("Invalid texture record extent/dimensions.",start)
	if frame >= frames or frames == 0: return failure("Texture frame absent.",start,"record_not_found")
	var indices := PackedByteArray()
	if compression in [0,0x900] and frames == 1:
		if width > 256: return failure("Uncompressed texture width exceeds row stride.",start)
		# RecordSize is logical size, not a physical extent: terrain records share
		# an interleaved 256-byte row store following contiguous record headers.
		cursor = Cursor.new(bytes,start + data,bytes.size())
		for row in height:
			cursor.seek(start + data + row * 256)
			indices.append_array(cursor.take(width))
	elif compression in [0x108,0x1108]:
		var table := start + data + height * frame * 4
		var headers := Cursor.new(bytes,table,bytes.size())
		for row in height:
			var offset := headers.s16()
			var encoding := headers.u16()
			if not headers.reason.is_empty() or offset < 28: return failure("Invalid texture row table.",headers.position)
			cursor = Cursor.new(bytes,start + offset,bytes.size())
			if encoding == 0:
				indices.append_array(cursor.take(width))
			elif encoding == 0x8000:
				if cursor.u16() != width: return failure("RLE row width differs from image.",cursor.position)
				var written := 0
				while written < width and cursor.has(2):
					var run := cursor.s16()
					if run == 0 or absi(run) > width - written: return failure("Invalid texture RLE run.",cursor.position)
					if run < 0:
						var pixel := cursor.u8()
						for unused in -run: indices.append(pixel)
					else: indices.append_array(cursor.take(run))
					written += absi(run)
			else: return failure("Unsupported row encoding.",cursor.position)
			if not cursor.reason.is_empty(): return failure(cursor.reason,cursor.position)
	else: return failure("Unsupported texture compression/animation profile.",start)
	if not cursor.reason.is_empty() or indices.size() != width * height: return failure("Truncated texture pixels: " + cursor.reason,cursor.position)
	var result := _image(width,height,x,y,record,frame,frames,records,start,indices)
	result.merge({"scale_x":scale_x,"scale_y":scale_y,"normal_flag":normal,"unknown":unknown,"compression":compression,"logical_record_size":length,"data_offset":data})
	return result
