extends RefCounted
## Bounded original questionnaire GFX/CEL assets. Indexed pixels are top-left first.
## Format evidence: pinned DFU GfxFile.cs / FlcFile.cs; no executable behavior.
const Cursor = preload("res://scripts/data/media_cursor.gd")
const Codec = preload("res://scripts/data/classic_image.gd")
var error := ""

func fail(reason: String) -> Dictionary: return {"ok":false,"reason":reason}

func scroll(bytes: PackedByteArray, palette: Dictionary) -> Dictionary:
	if bytes.size() < 14 or bytes.size() > 1048576: return fail("Bounded questionnaire scroll required.")
	var c := Cursor.new(bytes)
	var count := c.u16(); var width := c.u16(); var height := c.u16(); var length := c.u16()
	if count != 8 or width != 320 or height != 80 or length != width*height: return fail("Questionnaire GFX requires eight 320 by 80 frames.")
	var atlas := Image.create(width,height*count,false,Image.FORMAT_RGBA8)
	for frame in count:
		var pixels := PackedByteArray(); pixels.resize(width*height)
		for y in height:
			c.seek(14+(frame*height+y)*4)
			var offset := c.u16(); var encoding := c.u16()
			if offset < 14+count*height*4 or offset >= bytes.size() or encoding not in [0,32768]: return fail("Invalid questionnaire GFX row.")
			c.seek(offset)
			var row := PackedByteArray()
			if encoding == 0: row = c.take(width)
			else:
				if c.u16() != width: return fail("Invalid questionnaire GFX row width.")
				while row.size() < width and c.reason.is_empty():
					var run := c.s16()
					if run == 0 or absi(run) > width-row.size(): return fail("Questionnaire GFX run exceeds row.")
					if run > 0: row.append_array(c.take(run))
					else:
						var pixel := c.u8()
						for unused in -run: row.append(pixel)
			if not c.reason.is_empty() or row.size() != width: return fail("Truncated questionnaire GFX row.")
			for x in width: pixels[y*width+x] = row[x]
		var rgba: Dictionary = Codec.new().rgba({"ok":true,"width":width,"height":height,"indices":pixels},palette,-1)
		if not rgba.ok: return rgba
		atlas.blit_rect(Image.create_from_data(width,height,false,Image.FORMAT_RGBA8,rgba.rgba),Rect2i(0,0,width,height),Vector2i(0,frame*height))
	return {"ok":true,"image":atlas}

func signed_byte(c: RefCounted) -> int:
	var value: int = c.u8(); return value-256 if value >= 128 else value

func cel(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 128 or bytes.size() > 4194304: return fail("Bounded questionnaire CEL required.")
	var c := Cursor.new(bytes)
	var size := c.u32(); var magic := c.u16(); var count := c.u16(); var width := c.u16(); var height := c.u16(); var depth := c.u16()
	if size != bytes.size() or magic != 44818 or count < 1 or count > 128 or width < 1 or width > 320 or height != 119 or depth != 8: return fail("Unsupported questionnaire CEL header.")
	c.seek(16); var delay := c.u32()
	if delay < 1 or delay > 1000: return fail("Invalid questionnaire CEL timing.")
	c.seek(80); var frame_offset := c.u32()
	var palette := PackedByteArray(); palette.resize(768)
	var pixels := PackedByteArray(); pixels.resize(width*height)
	var atlas := Image.create(width,height*count,false,Image.FORMAT_RGBA8)
	for frame in count:
		c.seek(frame_offset)
		var frame_size := c.u32(); var frame_magic := c.u16(); var chunks := c.u16()
		if frame_size < 16 or frame_offset < 128 or frame_offset+frame_size > size or frame_magic != 61946 or chunks > 64: return fail("Malformed questionnaire CEL frame.")
		var chunk_offset := frame_offset+16
		for unused in chunks:
			c.seek(chunk_offset); var chunk_size := c.u32(); var type := c.u16()
			if chunk_size < 6 or chunk_offset+chunk_size > frame_offset+frame_size: return fail("Malformed questionnaire CEL chunk.")
			var body := Cursor.new(bytes,c.position,chunk_offset+chunk_size)
			match type:
				4:
					var packets := body.u16(); var color := 0
					if packets > 256: return fail("Invalid CEL palette packets.")
					for packet in packets:
						color += body.u8(); var changed := body.u8(); changed = 256 if changed == 0 else changed
						if color+changed > 256: return fail("CEL palette exceeds 256 entries.")
						for entry in changed:
							for channel in 3: palette[color*3+channel] = body.u8()
							color += 1
				15:
					for y in height:
						body.u8(); var x := 0
						while x < width and body.reason.is_empty():
							var run := signed_byte(body)
							if run == 0 or absi(run) > width-x: return fail("CEL byte run exceeds row.")
							if run > 0:
								var pixel: int = body.u8()
								for i in run: pixels[y*width+x+i] = pixel
							else:
								for i in -run: pixels[y*width+x+i] = body.u8()
							x += absi(run)
				7:
					var lines := body.u16(); var y := 0
					if lines > height: return fail("CEL delta exceeds height.")
					for line in lines:
						var packets := -1
						var operations := 0
						while packets < 0 and body.reason.is_empty():
							operations += 1
							if operations > height+2: return fail("CEL delta opcode limit exceeded.")
							var opcode := body.u16()
							if (opcode & 49152) == 49152: y += 65536-opcode
							elif (opcode & 49152) == 32768:
								if y >= height: return fail("CEL last pixel outside image.")
								pixels[y*width+width-1] = opcode & 255
							elif opcode < 16384: packets = opcode
							else: return fail("Unsupported CEL delta opcode.")
						if y >= height or packets > width: return fail("CEL delta outside image.")
						var x := 0
						for packet in packets:
							x += body.u8(); var run := signed_byte(body); var length := absi(run)*2
							if x+length > width: return fail("CEL delta run exceeds row.")
							if run >= 0:
								for i in length: pixels[y*width+x+i] = body.u8()
							else:
								var a := body.u8(); var b := body.u8()
								for i in length: pixels[y*width+x+i] = a if i%2 == 0 else b
							x += length
						y += 1
				18: pass # Optional postage-stamp thumbnail; never shown by this UI.
				_: return fail("Unsupported questionnaire CEL chunk: "+str(type))
			if not body.reason.is_empty(): return fail(body.reason)
			chunk_offset += chunk_size
		var rgba: Dictionary = Codec.new().rgba({"ok":true,"width":width,"height":height,"indices":pixels},{"ok":true,"rgb":palette},-1)
		if not rgba.ok: return rgba
		for i in pixels.size():
			if palette[pixels[i]*3] == 0 and palette[pixels[i]*3+1] == 0 and palette[pixels[i]*3+2] == 10: rgba.rgba[i*4+3] = 0
		atlas.blit_rect(Image.create_from_data(width,height,false,Image.FORMAT_RGBA8,rgba.rgba),Rect2i(0,0,width,height),Vector2i(0,frame*height))
		frame_offset += frame_size
	return {"ok":true,"image":atlas,"delay_msec":delay,"frames":count}
