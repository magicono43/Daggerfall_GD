extends RefCounted
## Preparation-private immutable decoded image cache. AV owns placed materials.
const Inspector = preload("res://scripts/av/classic_media_inspector.gd")
var classic: RefCounted
var media: RefCounted
var ticket := -1
var _palette: RefCounted
var _images := {}
var reads := 0
var _receipts := {}

func image(archive: int, record: int) -> Dictionary:
	var key := "%d/%d" % [archive,record]
	if _images.has(key): return _images[key]
	if _palette == null:
		var colors: Dictionary = classic.read_record("PAL.PAL",{"record":0,"frame":0})
		if not colors.ok: return colors
		_palette = colors.value
	var decoded: Dictionary = classic.read_record("TEXTURE.%03d" % archive,{"record":record,"frame":0})
	if not decoded.ok: return decoded
	var result := Inspector.new().image_resource(decoded.value,_palette,-1)
	if not result.ok: return result
	reads += 1
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(result.image.get_data())
	_receipts[key] = {"source":result.provenance.duplicate(true),"size":[result.image.get_width(),result.image.get_height()],"rgba_sha256":hash.finish().hex_encode()}
	_images[key] = {"ok":true,"image":result.image,"provenance":result.provenance.duplicate(true),"size":result.image.get_size(),"alpha":result.image.detect_alpha()}
	return _images[key]

func bindings(model: Dictionary, slots: Dictionary) -> Dictionary:
	if not model.has("value"): return {"ok":true,"textures":{}}
	var textures := {}
	var source: Dictionary = model.value.projection()
	for plane: Dictionary in source.planes:
		var archive := int(plane.texture_archive)
		var record := int(plane.texture_record)
		var key := "%d/%d" % [archive,record]
		if textures.has(key): continue
		var original := image(archive,record)
		if not original.ok: return original
		var slot: Variant = slots.get(str(archive),archive)
		var selected: Dictionary
		if slot is Dictionary and slot.records.has(str(record)):
			selected = exported_image(slot.records[str(record)])
		else:
			selected = image(int(slot.archive if slot is Dictionary else slot),record)
		if not selected.ok: return selected
		textures[key] = {"image":selected.image,"source_size":original.size,"alpha":selected.alpha,"source":original.provenance.duplicate(true),"effective":selected.provenance.duplicate(true)}
	return preload("res://scripts/av/replacement_instances.gd").dungeon_palette(textures)

func exported_image(asset: Dictionary) -> Dictionary:
	var key: String = "asset:"+asset.provider+"/"+asset.key
	if _images.has(key): return _images[key]
	if media == null: return {"ok":false,"kind":"provider_unavailable","reason":"Required media image provider unavailable."}
	var result: Dictionary = media.export_resource(asset.provider,asset.key,"image",ticket)
	if not result.ok: return result
	if result.provenance.get("generation") != ticket or not result.get("resource",{}).get("image") is Image: return {"ok":false,"kind":"stale","reason":"Exact current DATA image resource required."}
	var pixels: Image = result.resource.image
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(pixels.get_data())
	_receipts[key] = {"source":result.provenance.duplicate(true),"size":[pixels.get_width(),pixels.get_height()],"rgba_sha256":hash.finish().hex_encode()}
	_images[key] = {"ok":true,"image":pixels,"provenance":result.provenance.duplicate(true),"size":pixels.get_size(),"alpha":pixels.detect_alpha()}
	reads += 1
	return _images[key]

func receipts() -> Dictionary:
	return _receipts.duplicate(true)

func asset_version() -> String:
	# Publication tickets and application instances validate access but never seed
	# durable reconstruction. The selected definition plus actual pixels/size do.
	var inputs := {}
	for key: String in _receipts: inputs[key] = {"size":_receipts[key].size,"rgba_sha256":_receipts[key].rgba_sha256}
	return preload("res://scripts/data/variant_resolution.gd").digest(inputs)
