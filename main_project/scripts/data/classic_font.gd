extends RefCounted
## Read-only FONT000*.FNT bitfields, evidenced by DFU FntFile.cs (MIT).
## Only proven ASCII mapping is exposed; other Unicode uses the locale fallback.
static func decode(bytes: PackedByteArray, source := "FONT0003.FNT") -> Dictionary:
	if bytes.size() != 8644: return {"ok":false,"reason":"Classic font requires 240 bounded glyphs."}
	var width := bytes.decode_u16(0)
	var height := bytes.decode_u16(2)
	if width < 1 or width > 16 or height < 1 or height > 16: return {"ok":false,"reason":"Unsupported classic font metrics."}
	var atlas := Image.create(256,256,false,Image.FORMAT_RGBA8)
	var widths: Array[int] = []
	for index in 240:
		var offset := bytes.decode_u16(4+index*4)
		var advance := bytes.decode_u16(6+index*4)
		if offset < 964 or offset+32 > bytes.size() or advance > 16: return {"ok":false,"reason":"Classic glyph lies outside its source."}
		widths.append(advance)
		for y in height:
			var bits := bytes.decode_u16(offset+y*2)
			for x in advance:
				if bits & (1 << (15-x)): atlas.set_pixel((index%16)*16+x,(index/16)*16+y,Color.WHITE)
	return {"ok":true,"image":atlas,"width":width,"height":height,"widths":widths,"provenance":{"source":source,"sha256":preload("res://scripts/data/actor_input_formats.gd").sha256(bytes),"mapping":"ASCII 33..126; synthetic space = fixed width - 1; DFU spacing = 1"}}
