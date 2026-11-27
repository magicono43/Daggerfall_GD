extends RefCounted
## Application-owned registry. Validation, prepared readers and active access differ.
const BsaReader = preload("res://scripts/data/bsa_reader.gd")
const TextReader = preload("res://scripts/data/text_rsc_reader.gd")
const MediaReader = preload("res://scripts/data/classic_media_source.gd")
const SoundDecoder = preload("res://scripts/data/classic_sound.gd")
const ModelDecoder = preload("res://scripts/data/classic_model.gd")
const HmiDecoder = preload("res://scripts/data/classic_hmi.gd")
const ActorFormats = preload("res://scripts/data/actor_input_formats.gd")
const ActorReader = preload("res://scripts/data/actor_source_reader.gd")
const ItemSpellFormats = preload("res://scripts/data/item_spell_formats.gd")
const ItemSpellReader = preload("res://scripts/data/item_spell_source_reader.gd")
const GeographyFormats = preload("res://scripts/data/geography_formats.gd")
const GeographyReader = preload("res://scripts/data/geography_source_reader.gd")
var _declarations: Dictionary = {}
var _enabled: Array[String] = ["classic-containers-v1"]
var _active: Dictionary = {}
var _prepared: Dictionary = {}
var _active_source := ""
var _prepared_source := ""
var _serial := 0
var _prepared_ticket := 0
var _portrait_source := ""
var _portrait_files: Dictionary = {}
var _portrait_palette: Dictionary = {}

func same_source(first: String, second: String) -> bool:
	return first.to_lower() == second.to_lower() if OS.get_name() == "Windows" else first == second

func _init() -> void:
	register_adapter("classic-containers-v1", [
		{"file": "ARCH3D.BSA", "format": "bsa-v1"}, {"file": "BLOCKS.BSA", "format": "bsa-v1"},
		{"file": "MAPS.BSA", "format": "bsa-v1"}, {"file": "DAGGER.SND", "format": "bsa-v1"}])

func register_adapter(id: String, sources: Array) -> bool:
	if not _active.is_empty() or not _prepared.is_empty() or _declarations.has(id) or id.is_empty() or sources.is_empty():
		return false
	for entry: Dictionary in sources:
		var file := str(entry.get("file", ""))
		if file.is_empty() or file.get_file() != file or file.contains("\\") or (entry.get("format") not in ["bsa-v1", TextReader.VERSION] and entry.get("format") not in MediaReader.FORMATS and entry.get("format") not in ActorFormats.FORMATS and entry.get("format") not in ItemSpellFormats.FORMATS and entry.get("format") not in GeographyFormats.FORMATS):
			return false # Other formats require their actual owner implementation.
	_declarations[id] = sources.duplicate(true)
	return true

func enable_capability(id: String) -> bool:
	if not _active.is_empty() or not _prepared.is_empty():
		return false
	if not _enabled.has(id):
		_enabled.append(id) # Missing declarations fail closed in manifest composition.
	return true

func manifest() -> Dictionary:
	var entries := {}
	for id: String in _enabled:
		if not _declarations.has(id):
			return {"ok": false, "reason": "Required capability has no registered adapter: " + id, "kind": "capability_unavailable"}
		for entry: Dictionary in _declarations[id]:
			var name := str(entry.file).to_upper()
			if not entries.has(name):
				entries[name] = {"file": name, "format": entry.format, "adapters": []}
			elif entries[name].format != entry.format:
				return {"ok":false,"kind":"capability_unavailable","reason":"Conflicting reader formats for required source: " + name}
			entries[name].adapters.append(id)
	return {"ok": true, "entries": entries.values()}

func _reader(format_id: String) -> RefCounted:
	if format_id == "bsa-v1": return BsaReader.new()
	if format_id == TextReader.VERSION: return TextReader.new()
	if format_id in MediaReader.FORMATS: return MediaReader.new(format_id)
	if format_id in ActorFormats.FORMATS: return ActorReader.new(format_id)
	if format_id in ItemSpellFormats.FORMATS: return ItemSpellReader.new(format_id)
	if format_id in GeographyFormats.FORMATS: return GeographyReader.new(format_id)
	return null

func resolve(candidate: String) -> Dictionary:
	var path := candidate.replace("\\", "/").simplify_path().trim_suffix("/")
	if candidate.is_empty() or not path.is_absolute_path():
		return _failure(path, [{"source": path, "kind": "source_unavailable", "reason": "Select an absolute ARENA2 folder or its immediate parent."}])
	var directory := DirAccess.open(path)
	if directory == null:
		return _failure(path, [{"source": path, "kind": "source_unavailable", "reason": "Cannot access selected root: " + error_string(DirAccess.get_open_error())}])
	if path.get_file().to_upper() == "ARENA2":
		return {"ok": true, "source": path}
	if directory.list_dir_begin() != OK:
		return _failure(path, [{"source": path, "kind": "source_unavailable", "reason": "Cannot enumerate selected root."}])
	var children: Array[String] = []
	var name := directory.get_next()
	while not name.is_empty():
		if name.to_upper() == "ARENA2" and directory.current_is_dir():
			children.append(name)
		name = directory.get_next()
	directory.list_dir_end()
	if children.size() != 1:
		return _failure(path, [{"source": path, "kind": "source_unavailable", "reason": "Expected one immediate ARENA2 child; found %d. No discovery fallback." % children.size()}])
	return {"ok": true, "source": path.path_join(children[0])}

func _failure(source: String, failures: Array) -> Dictionary:
	var lines: Array[String] = []
	for item: Dictionary in failures:
		lines.append("%s: %s" % [item.source, item.reason])
	return {"ok": false, "source": source, "reason": "\n".join(lines), "failures": failures, "ready": false}

func validate(candidate: String) -> Dictionary:
	var resolved := resolve(candidate)
	if not resolved.ok:
		return resolved
	var declared := manifest()
	if not declared.ok:
		return _failure(resolved.source, [{"source": resolved.source, "kind": declared.kind, "reason": declared.reason}])
	# Verify root enumeration first; never claim individual inspection on root failure.
	var directory := DirAccess.open(resolved.source)
	if directory == null or directory.list_dir_begin() != OK:
		return _failure(resolved.source, [{"source": resolved.source, "kind": "source_unavailable", "reason": "Cannot enumerate resolved root; files were not inspected."}])
	directory.list_dir_end()
	var failures: Array = []
	var checks: Array = []
	for entry: Dictionary in declared.entries:
		var reader := _reader(entry.format)
		var checked: Dictionary = reader.initialize(str(resolved.source).path_join(entry.file))
		reader.close()
		checked.manifest_entry = entry.duplicate(true)
		checks.append(checked)
		if not checked.ok:
			failures.append(checked)
	if not failures.is_empty():
		return _failure(resolved.source, failures)
	return {"ok": true, "source": resolved.source, "checks": checks, "manifest": declared.entries, "ready": false, "stage": "validated"}

func prepare(candidate: String) -> Dictionary:
	discard_prepared()
	var checked := validate(candidate)
	if not checked.ok:
		return checked
	return initialize_readers(checked)

func initialize_readers(validated: Dictionary) -> Dictionary:
	# Reread every index: validation is time-local evidence, never readiness.
	discard_prepared()
	if not validated.get("ok", false) or validated.get("stage") != "validated":
		return {"ok": false, "kind": "before_readiness", "reason": "Validated source required."}
	var checked := validated.duplicate(true)
	var declared := manifest()
	if not declared.ok:
		return declared
	checked.manifest = declared.entries
	if same_source(checked.source, _active_source) and ready():
		return {"ok": true, "source": _active_source, "ready": true, "ticket": 0, "stage": "active"}
	var failures: Array = []
	for entry: Dictionary in checked.manifest:
		var reader := _reader(entry.format)
		var initialized: Dictionary = reader.initialize(str(checked.source).path_join(entry.file))
		if initialized.ok:
			_prepared[entry.file] = reader
		else:
			initialized.manifest_entry = entry
			failures.append(initialized)
	if not failures.is_empty():
		discard_prepared()
		return _failure(checked.source, failures)
	_serial += 1
	_prepared_ticket = _serial
	_prepared_source = checked.source
	checked.ticket = _prepared_ticket
	checked.stage = "initialized_unpublished"
	return checked

func activate(checked: Dictionary) -> Dictionary:
	if checked.get("ticket", -1) == 0 and checked.get("source") == _active_source and ready():
		return {"ok": true, "source": _active_source, "ready": true}
	if _prepared.is_empty() or checked.get("ticket") != _prepared_ticket or checked.get("source") != _prepared_source:
		return {"ok": false, "reason": "No matching initialized reader set.", "kind": "before_readiness"}
	if ready():
		discard_prepared()
		return {"ok": false, "reason": "Source change requires application restart.", "kind": "restart_required"}
	_active = _prepared
	_active_source = _prepared_source
	_prepared = {}
	_prepared_source = ""
	_prepared_ticket = 0
	return {"ok": true, "source": _active_source, "ready": true}

func discard_prepared() -> void:
	for reader: RefCounted in _prepared.values():
		reader.close()
	_prepared.clear()
	_prepared_source = ""
	_prepared_ticket = 0

func ready() -> bool:
	return not _active.is_empty()

func prepared_count() -> int:
	return _prepared.size()

func inventory() -> Array:
	var view: Array = []
	for reader: RefCounted in _active.values():
		view.append(reader.inventory())
	return view

func read_record(file: String, record: Variant) -> Dictionary:
	var path := (_active_source if ready() else _prepared_source).path_join(file)
	if not ready():
		return {"ok": false, "kind": "before_readiness", "source": path, "record": record, "reason": "Required readers are not published."}
	if not _active.has(file.to_upper()):
		return {"ok": false, "kind": "source_unavailable", "source": path, "record": record, "reason": "Source has no active required reader."}
	return _active[file.to_upper()].read_record(record)

func decode_sound(record: Variant) -> Dictionary:
	# Container identity and physical ordinal remain distinct in the returned provenance.
	return SoundDecoder.new().decode(read_record("DAGGER.SND",record))

func decode_model(record: Variant) -> Dictionary:
	return ModelDecoder.new().decode(read_record("ARCH3D.BSA",record))

func decode_sequence(record: Variant) -> Dictionary:
	return HmiDecoder.new().decode(read_record("MIDI.BSA",record))

func video_source(file: String) -> Dictionary:
	if not ready() or not _active.has(file.to_upper()) or not _active[file.to_upper()].has_method("video_source"):
		return {"ok":false,"kind":"source_unavailable","reason":"An active, explicitly declared VID source is required."}
	return _active[file.to_upper()].video_source()

func death_video_source() -> Dictionary:
	# CORE-008 explicitly consumes this optional original after teardown. It is
	# not a required startup manifest entry and cannot make missing videos block
	# source/menu readiness. No directory discovery or alternate movie fallback.
	if not ready(): return {"ok":false,"kind":"before_readiness","reason":"Published classic source required for death video."}
	var reader := MediaReader.new("classic-vid-v1")
	var checked: Dictionary = reader.initialize(_active_source.path_join("ANIM0012.VID"))
	if not checked.ok: return checked
	var source: Dictionary = reader.video_source()
	reader.close()
	return source

func creation_video_source(index: int) -> Dictionary:
	const FILES = ["ANIM0000.VID","ANIM0011.VID","DAG2.VID"]
	if not ready() or index < 0 or index >= FILES.size(): return {"ok":false,"reason":"Published creation clip mapping required."}
	var reader := MediaReader.new("classic-vid-v1")
	var checked: Dictionary = reader.initialize(_active_source.path_join(FILES[index]))
	if not checked.ok: return checked
	var source: Dictionary = reader.video_source()
	reader.close()
	return source

func creation_image(file: String) -> Dictionary:
	# Optional interface originals, requested only through the active DATA source.
	# This bounded owner table is not a wildcard path/format interface. Absence or
	# malformed optional art does not invalidate required startup or gameplay data.
	const NAMES = ["CHAR00I0.IMG","CHAR01I0.IMG","CHAR02I0.IMG","CHAR03I0.IMG","CHAR04I0.IMG","CHAR05I0.IMG","CHAR03I1.IMG","CHAR05I1.IMG","TMAP00I0.IMG","CUST00I0.IMG","CUST08I0.IMG","CHGN00I0.IMG","BIOG00I0.IMG"]
	if not ready() or (file not in NAMES and file not in ["BUTN01I0.IMG","BUTN02I0.IMG","PICK00I0.IMG","CHAR02I1.IMG","CUST03I0.IMG","CUST01I0.IMG","CUST02I0.IMG"]): return {"ok":false,"reason":"Published creation-art source binding unavailable."}
	var reader := MediaReader.new("classic-img-v1")
	var checked: Dictionary = reader.initialize(_active_source.path_join(file))
	if not checked.ok: return checked
	var decoded: Dictionary = reader.read_record({"record":0,"frame":0})
	reader.close()
	if not decoded.ok: return decoded
	var data: Dictionary = decoded.value.projection()
	var palette_name := "MAP.PAL" if file == "TMAP00I0.IMG" else "ART_PAL.COL"
	if data.has("embedded_palette"):
		data.ok = true
		var embedded := preload("res://scripts/data/classic_image.gd").new().rgba(data,data.embedded_palette,-1)
		if not embedded.ok: return embedded
		return {"ok":true,"image":Image.create_from_data(embedded.width,embedded.height,false,Image.FORMAT_RGBA8,embedded.rgba),"provenance":{"image":data.provenance,"palette":"embedded six-bit RGB","alpha_index":-1,"sampling":"nearest","source_identity":data.identity}}
	reader = MediaReader.new("classic-palette-v1")
	checked = reader.initialize(_active_source.path_join(palette_name))
	if not checked.ok: return checked
	var colors: Dictionary = reader.read_record({"record":0,"frame":0})
	reader.close()
	if not colors.ok: return colors
	var palette_data: Dictionary = colors.value.projection()
	data.ok = true
	palette_data.ok = true
	var rgba := preload("res://scripts/data/classic_image.gd").new().rgba(data,palette_data,0 if file in ["CUST08I0.IMG","CHAR02I1.IMG"] else -1)
	if not rgba.ok: return rgba
	return {"ok":true,"image":Image.create_from_data(rgba.width,rgba.height,false,Image.FORMAT_RGBA8,rgba.rgba),"provenance":{"image":data.provenance,"palette":palette_data.provenance,"alpha_index":0 if file in ["CUST08I0.IMG","CHAR02I1.IMG"] else -1,"sampling":"nearest","source_identity":data.identity}}

func creation_parchment() -> Dictionary:
	if not ready(): return {"ok":false,"reason":"Published classic source required."}
	var bytes := FileAccess.get_file_as_bytes(_active_source.path_join("SPOP.RCI"))
	if bytes.size() != 9*22*22: return {"ok":false,"reason":"Optional classic parchment requires nine 22×22 tiles."}
	var codec := preload("res://scripts/data/classic_image.gd").new()
	var palette_bytes := FileAccess.get_file_as_bytes(_active_source.path_join("ART_PAL.COL"))
	var palette := codec.palette(palette_bytes)
	var atlas := Image.create(66,66,false,Image.FORMAT_RGBA8)
	for record in 9:
		var rgba := codec.rgba(codec.decode(bytes,"SPOP.RCI",record,0),palette,0)
		if not rgba.ok: return rgba
		var tile := Image.create_from_data(22,22,false,Image.FORMAT_RGBA8,rgba.rgba)
		atlas.blit_rect(tile,Rect2i(0,0,22,22),Vector2i((record%3)*22,(record/3)*22))
	return {"ok":true,"image":atlas,"provenance":{"source":"SPOP.RCI","sha256":ActorFormats.sha256(bytes),"palette":"ART_PAL.COL","palette_sha256":ActorFormats.sha256(palette_bytes),"layout":"DFU SetBorderTextures row-major nine tiles","alpha_index":0}}

func creation_questionnaire_asset(id: String) -> Dictionary:
	if not ready() or id not in ["scroll","mask","rogue","mage","warrior"]: return {"ok":false,"reason":"Known published questionnaire asset required."}
	var codec := preload("res://scripts/data/creation_questionnaire_images.gd").new()
	if id in ["scroll","mask"]:
		var background_bytes := _questionnaire_bytes("CHGN00I0.IMG",1048576)
		var background: Dictionary = preload("res://scripts/data/classic_image.gd").new().decode(background_bytes,"CHGN00I0.IMG",0,0)
		if not background.ok or not background.has("embedded_palette") or background.width != 320 or background.height != 200: return {"ok":false,"reason":"Questionnaire palette or 320 by 200 background unavailable."}
		if id == "mask":
			var image := Image.create(320,200,false,Image.FORMAT_RGBA8)
			for i in background.indices.size():
				var color: int = background.indices[i]
				if color in [160,128,192]: image.set_pixel(i%320,i/320,Color(1 if color == 160 else 0,1 if color == 128 else 0,1 if color == 192 else 0,1))
			return {"ok":true,"image":image,"provenance":{"source":"CHGN00I0.IMG","sha256":ActorFormats.sha256(background_bytes),"interpretation":"DFU palette entries rogue=160 mage=128 warrior=192"}}
		var atlas := Image.create(320,1280,false,Image.FORMAT_RGBA8)
		var hashes := {}
		for index in 2:
			var name := "SCRL0"+str(index)+"I0.GFX"
			var bytes := _questionnaire_bytes(name,1048576)
			var result: Dictionary = codec.scroll(bytes,background.embedded_palette)
			if not result.ok: return result
			atlas.blit_rect(result.image,Rect2i(0,0,320,640),Vector2i(0,index*640)); hashes[name] = ActorFormats.sha256(bytes)
		return {"ok":true,"image":atlas,"provenance":{"sources":hashes,"palette_sha256":ActorFormats.sha256(background_bytes),"layout":"sixteen vertical 320 by 80 GFX frames"}}
	var name := id.to_upper()+".CEL"
	var bytes := _questionnaire_bytes(name,4194304)
	var decoded: Dictionary = codec.cel(bytes)
	if decoded.ok: decoded.provenance = {"source":name,"sha256":ActorFormats.sha256(bytes),"frames":decoded.frames,"delay_msec":decoded.delay_msec,"transparency":"RGB 0,0,10; DFU questionnaire","ring_frame":"excluded"}
	return decoded

func _questionnaire_bytes(name: String, limit: int) -> PackedByteArray:
	var file := FileAccess.open(_active_source.path_join(name),FileAccess.READ)
	if file == null: return PackedByteArray()
	if file.get_length() > limit: file.close(); return PackedByteArray()
	var result := file.get_buffer(file.get_length()); file.close(); return result

func creation_popup_font(small := false) -> Dictionary:
	if not ready(): return {"ok":false,"reason":"Published classic source required."}
	var file := "FONT0002.FNT" if small else "FONT0003.FNT"
	return preload("res://scripts/data/classic_font.gd").decode(FileAccess.get_file_as_bytes(_active_source.path_join(file)),file)

func creation_dialog_button(record: int) -> Dictionary:
	if not ready() or record not in [3,4,6,7]: return {"ok":false,"reason":"Known classic confirmation button required."}
	var codec := preload("res://scripts/data/classic_image.gd").new()
	var bytes := FileAccess.get_file_as_bytes(_active_source.path_join("BUTTONS.RCI"))
	var palette_bytes := FileAccess.get_file_as_bytes(_active_source.path_join("ART_PAL.COL"))
	var rgba := codec.rgba(codec.decode(bytes,"BUTTONS.RCI",record,0),codec.palette(palette_bytes),0)
	if not rgba.ok: return rgba
	return {"ok":true,"image":Image.create_from_data(rgba.width,rgba.height,false,Image.FORMAT_RGBA8,rgba.rgba),"provenance":{"source":"BUTTONS.RCI","record":record,"sha256":ActorFormats.sha256(bytes),"palette_sha256":ActorFormats.sha256(palette_bytes)}}

func creation_source(file: String) -> Dictionary:
	# Bounded read-only source capability, not an arbitrary path reader. Original
	# map/result bytes are interpreted by the creation DATA adapter before publish.
	if not ready() or file not in ["CLASSES.DAT","TAMRIEL2.IMG"]: return {"ok":false,"reason":"Creation source unavailable."}
	var stream := FileAccess.open(_active_source.path_join(file),FileAccess.READ)
	if stream == null: return {"ok":false,"reason":"Required creation source missing: "+file}
	var length := stream.get_length()
	if length < 1 or length > 131072: stream.close(); return {"ok":false,"reason":"Unsupported creation source length: "+file}
	var bytes := stream.get_buffer(length)
	stream.close()
	if bytes.size() != length: return {"ok":false,"reason":"Incomplete creation source read: "+file}
	return {"ok":true,"bytes":bytes,"source":_active_source.path_join(file),"sha256":ActorFormats.sha256(bytes)}

func creation_book(id: int) -> Dictionary:
	# Narrow read-only qualification for retained biography book intent. Rendering,
	# book UI, possession construction and SAVE stay with their later owners.
	if not ready() or id < 0 or id > 255: return {"ok":false,"reason":"Unsupported classic biography book ID."}
	var relative := "BOOKS/BOK%05d.TXT" % id
	var file := FileAccess.open(_active_source.path_join(relative),FileAccess.READ)
	if file == null: return {"ok":false,"reason":"Required biography book source missing: "+relative}
	var length := file.get_length()
	if length < 236 or length > 2097152: file.close(); return {"ok":false,"reason":"Malformed biography book length: "+relative}
	var bytes := file.get_buffer(length); file.close()
	if bytes.size() != length: return {"ok":false,"reason":"Incomplete biography book read: "+relative}
	var count := bytes.decode_u16(234)
	if count < 1 or 236+count*4 > length: return {"ok":false,"reason":"Malformed biography book page directory: "+relative}
	for page in count:
		var offset := bytes.decode_u32(236+page*4)
		if offset < 236+count*4 or offset >= length: return {"ok":false,"reason":"Invalid biography book page offset: "+relative}
	return {"ok":true,"id":id,"source":relative,"sha256":ActorFormats.sha256(bytes),"price_seed":bytes.decode_u32(0),"page_count":count,"qualification":"Read-only header/page-address metadata; no runtime book reader or possession grant."}

func creation_portrait(file: String, record: int) -> Dictionary:
	var allowed: Array[String] = []
	for race in 8:
		for gender in 2: allowed.append("FACE%d%dI0.CIF" % [gender,race])
	if not ready() or file not in allowed or record < 0 or record > 9: return {"ok":false,"reason":"Unsupported classic portrait mapping."}
	if _portrait_source != _active_source:
		_portrait_source = _active_source
		_portrait_files.clear(); _portrait_palette.clear()
	var codec := preload("res://scripts/data/classic_image.gd").new()
	if not _portrait_files.has(file):
		var stream := FileAccess.open(_active_source.path_join(file),FileAccess.READ)
		if stream == null: return {"ok":false,"reason":"Required portrait source missing: "+file}
		var length := stream.get_length()
		if length < 1 or length > 2097152: stream.close(); return {"ok":false,"reason":"Portrait source extent is unsupported."}
		var bytes := stream.get_buffer(length); stream.close()
		if bytes.size() != length: return {"ok":false,"reason":"Portrait source read incomplete."}
		_portrait_files[file] = {"bytes":bytes,"sha256":ActorFormats.sha256(bytes)}
	if _portrait_palette.is_empty():
		var palette_bytes := FileAccess.get_file_as_bytes(_active_source.path_join("ART_PAL.COL"))
		_portrait_palette = codec.palette(palette_bytes)
		_portrait_palette.sha256 = ActorFormats.sha256(palette_bytes)
	var bytes: PackedByteArray = _portrait_files[file].bytes
	var decoded := codec.decode(bytes,file,record,0)
	if not decoded.ok: return decoded
	var rgba := codec.rgba(decoded,_portrait_palette,0)
	if not rgba.ok: return rgba
	return {"ok":true,"image":Image.create_from_data(rgba.width,rgba.height,false,Image.FORMAT_RGBA8,rgba.rgba),"provenance":{"source":file,"record":record,"frame":0,"sha256":_portrait_files[file].sha256,"palette":"ART_PAL.COL","palette_sha256":_portrait_palette.sha256,"alpha_index":0}}

func creation_appearance(file: String) -> Dictionary:
	# Fixed supported source namespace; no wildcard filesystem discovery. Checking
	# first frame certifies the mapping only, not the later portrait-selection owner.
	var allowed: Array[String] = []
	for race in 8:
		allowed.append("SCBG%02dI0.IMG" % race)
		for gender in 2:
			allowed.append("FACE%d%dI0.CIF" % [gender,race])
			for clothed in 2: allowed.append("BODY%d%dI%d.IMG" % [gender,race,clothed])
	if not ready() or file not in allowed: return {"ok":false,"reason":"Unsupported appearance source mapping."}
	var path := _active_source.path_join(file)
	var stream := FileAccess.open(path,FileAccess.READ)
	if stream == null: return {"ok":false,"reason":"Required appearance source missing: "+file}
	var length := stream.get_length()
	if length < 1 or length > 2097152: stream.close(); return {"ok":false,"reason":"Unsupported appearance source extent: "+file}
	var bytes := stream.get_buffer(length)
	stream.close()
	var decoded := preload("res://scripts/data/classic_image.gd").new().decode(bytes,file,0,0)
	if not decoded.ok: return {"ok":false,"reason":"Invalid appearance source: "+file+": "+str(decoded.reason)}
	return {"ok":true,"source":file,"sha256":ActorFormats.sha256(bytes),"first_frame":{"width":decoded.width,"height":decoded.height},"scope":"Mapping and first frame; full face selection remains CHAR-007."}

func dispose() -> void:
	_portrait_files.clear(); _portrait_palette.clear(); _portrait_source = ""
	discard_prepared()
	for reader: RefCounted in _active.values():
		reader.close()
	_active.clear()
	_active_source = ""
