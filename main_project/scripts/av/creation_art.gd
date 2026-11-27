extends RefCounted
## Application-lifetime optional UI resources. One decode/texture per target,
## including cached missing results. DATA/MOD own selection and content locking.
const FILES = {"creation.biography":"BIOG00I0.IMG","creation.race":"TMAP00I0.IMG","creation.questionnaire":"CHGN00I0.IMG","creation.custom":"CUST00I0.IMG","creation.dagger":"CUST08I0.IMG","creation.name":"CHAR00I0.IMG","creation.face":"CHAR01I0.IMG","creation.attributes":"CHAR02I0.IMG","creation.skills":"CHAR03I0.IMG","creation.summary":"CHAR04I0.IMG","creation.reflexes":"CHAR05I0.IMG"}
var classic: RefCounted
var media: RefCounted
var definitions: RefCounted
var _textures: Dictionary = {}
var _baselines: Dictionary = {}
var _narrations: Dictionary = {}
var _click: Dictionary = {}
var _class_jingle: Dictionary = {}
var _click_player: AudioStreamPlayer
var click_submissions := 0
var _small_font: FontFile
var _small_font_prepared := false
var _popup_font: FontFile
var _popup_font_prepared := false
const NARRATIONS = ["breton","redguard","nord","dark-elf","high-elf","wood-elf","khajiit","argonian"]
var measurements := {"requests":0,"baseline_decodes":0,"textures":0,"decode_usec":0,"rgba_bytes":0}

func declare(providers: RefCounted) -> Dictionary:
	classic = providers.classic
	media = providers.media
	definitions = providers.definitions
	if media == null: return {"ok":false,"reason":"Creation art requires the existing media resolver."}
	var parchment: Dictionary = media.register_target("creation.parchment","image",[],_parchment_baseline)
	if not parchment.ok: return parchment
	var method: Dictionary = media.register_target("creation.class-method","image",[],_decode_once.bind("creation.class-method",classic.creation_image.bind("BUTN01I0.IMG")))
	if not method.ok: return method
	var spinner: Dictionary = media.register_target("creation.stat-spinner","image",[],_decode_once.bind("creation.stat-spinner",classic.creation_image.bind("CHAR02I1.IMG")))
	if not spinner.ok: return spinner
	var reputation: Dictionary = media.register_target("creation.reputation","image",[],_decode_once.bind("creation.reputation",classic.creation_image.bind("CUST03I0.IMG")))
	if not reputation.ok: return reputation
	for item in [["creation.traits","CUST01I0.IMG"],["creation.traits-advantages","CUST02I0.IMG"],["creation.list-picker","PICK00I0.IMG"],["creation.biography-method","BUTN02I0.IMG"]]:
		var result: Dictionary = media.register_target(item[0],"image",[],_decode_once.bind(item[0],classic.creation_image.bind(item[1])))
		if not result.ok: return result
	var click: Dictionary = media.register_target("creation.dialog.click","audio",[],_sound_baseline.bind({"ordinal":360}))
	if not click.ok: return click
	var drums: Dictionary = media.register_target("creation.class-drums","audio",[],_sound_baseline.bind({"ordinal":374}))
	if not drums.ok: return drums
	var thumb: Dictionary = media.register_target("creation.scrollbar-thumb","image",[],_scrollbar_thumb_baseline)
	if not thumb.ok: return thumb
	for item in [["yes",3],["no",4],["male",6],["female",7]]:
		var button: Dictionary = media.register_target("creation.dialog."+item[0],"image",[],_dialog_button_baseline.bind(item[1]))
		if not button.ok: return button
	for target: String in FILES:
		var checked: Dictionary = media.register_target(target,"image",[],_baseline.bind(target))
		if not checked.ok: return checked
	for race: String in NARRATIONS:
		var checked: Dictionary = media.register_target("creation.narration."+race,"audio",[],_narration_baseline.bind(race))
		if not checked.ok: return checked
	for race_index in NARRATIONS.size():
		for gender_index in 2:
			for face in 10:
				var target := "creation.portrait.%s.%s.%02d" % [NARRATIONS[race_index],"male" if gender_index == 0 else "female",face]
				var checked: Dictionary = media.register_target(target,"image",[],_portrait_baseline.bind("FACE%d%dI0.CIF" % [gender_index,race_index],face))
				if not checked.ok: return checked
	for index in 3:
		var checked: Dictionary = media.register_target("creation.intro."+str(index),"video",[],_intro_baseline.bind(index))
		if not checked.ok: return checked
	return {"ok":true}

func _intro_baseline(index: int) -> Dictionary:
	var source: Dictionary = classic.creation_video_source(index)
	if not source.ok: return source
	return {"ok":true,"resource":{"classic_source":source,"aspect":1.6},"provenance":{"source":source.source,"order":index}}

func parchment_style() -> StyleBoxTexture:
	var selected := resolve("creation.parchment")
	if not selected.ok: return null
	var style := StyleBoxTexture.new()
	style.texture = selected.texture
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_texture_margin(side,22)
		style.set_content_margin(side,18)
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	return style

func _portrait_baseline(file: String, record: int) -> Dictionary:
	return _decode_once(file+"/"+str(record),classic.creation_portrait.bind(file,record))

func _dialog_button_baseline(record: int) -> Dictionary:
	return _decode_once("BUTTONS.RCI/"+str(record),classic.creation_dialog_button.bind(record))

func popup_font(fallback: Font) -> Font:
	if not _popup_font_prepared:
		_popup_font_prepared = true
		var source: Dictionary = classic.creation_popup_font()
		if source.ok:
			_popup_font = FontFile.new()
			_popup_font.font_name = "Daggerfall FONT0003"
			_popup_font.allow_system_fallback = false
			_popup_font.fixed_size = source.height
			_popup_font.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_ENABLED
			_popup_font.set_meta("provenance",source.provenance)
			# Setting the family name can leave an empty default-size cache first.
			# Godot's has_char() consults that first cache. Start with only our atlas.
			_popup_font.clear_size_cache(0)
			var cache_size := Vector2i(source.height,0)
			_popup_font.set_texture_image(0,cache_size,0,source.image)
			_popup_font.set_cache_ascent(0,source.height,source.height)
			_popup_font.set_cache_descent(0,source.height,0)
			for code in range(32,127):
				var index: int = code-33
				var width: int = source.width-1 if code == 32 else source.widths[index]
				_popup_font.set_glyph_advance(0,source.height,code,Vector2(width+1,0))
				_popup_font.set_glyph_offset(0,cache_size,code,Vector2(0,-source.height))
				_popup_font.set_glyph_size(0,cache_size,code,Vector2(width,source.height) if code != 32 else Vector2.ZERO)
				_popup_font.set_glyph_uv_rect(0,cache_size,code,Rect2((index%16)*16,(index/16)*16,width,source.height) if code != 32 else Rect2())
				_popup_font.set_glyph_texture_idx(0,cache_size,code,0)
	if _popup_font == null: return fallback
	return _popup_font

func small_font(fallback: Font) -> Font:
	if not _small_font_prepared:
		_small_font_prepared = true
		var source: Dictionary = classic.creation_popup_font(true)
		if source.ok:
			_small_font = FontFile.new()
			_small_font.font_name = "Daggerfall FONT0002"
			_small_font.allow_system_fallback = false
			_small_font.fixed_size = source.height
			_small_font.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_ENABLED
			_small_font.set_meta("provenance",source.provenance)
			# Setting the family name can leave an empty default-size cache first.
			# Godot's has_char() consults that first cache. Start with only our atlas.
			_small_font.clear_size_cache(0)
			var cache_size := Vector2i(source.height,0)
			_small_font.set_texture_image(0,cache_size,0,source.image)
			_small_font.set_cache_ascent(0,source.height,source.height)
			_small_font.set_cache_descent(0,source.height,0)
			for code in range(32,127):
				var index: int = code-33
				var width: int = source.width-1 if code == 32 else source.widths[index]
				_small_font.set_glyph_advance(0,source.height,code,Vector2(width+1,0))
				_small_font.set_glyph_offset(0,cache_size,code,Vector2(0,-source.height))
				_small_font.set_glyph_size(0,cache_size,code,Vector2(width,source.height) if code != 32 else Vector2.ZERO)
				_small_font.set_glyph_uv_rect(0,cache_size,code,Rect2((index%16)*16,(index/16)*16,width,source.height) if code != 32 else Rect2())
				_small_font.set_glyph_texture_idx(0,cache_size,code,0)
	if _small_font == null: return fallback
	return _small_font

func _parchment_baseline() -> Dictionary:
	return _decode_once("creation.parchment",classic.creation_parchment)

func _decode_once(key: String, reader: Callable) -> Dictionary:
	if not _baselines.has(key):
		var started := Time.get_ticks_usec()
		_baselines[key] = reader.call()
		measurements.baseline_decodes += 1
		measurements.decode_usec += Time.get_ticks_usec()-started
	return _baselines[key].duplicate()

func _narration_baseline(race: String) -> Dictionary:
	var read: Dictionary = definitions.query("char.career","policy","stock")
	if not read.ok: return read
	return _sound_baseline(int(read.record.value.races[race].narration))

func _sound_baseline(selector: Variant) -> Dictionary:
	var decoded: Dictionary = classic.decode_sound(selector)
	if not decoded.ok: return decoded
	var data: Dictionary = decoded.value.projection()
	var samples := PackedByteArray()
	samples.resize(data.samples.size())
	for index in data.samples.size(): samples[index] = int(data.samples[index]) & 255
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = int(data.sample_rate_hz)
	stream.stereo = false
	stream.data = samples
	return {"ok":true,"resource":{"stream":stream,"frames":data.frame_count},"provenance":data.provenance}

func play_dialog_click(host: Node) -> void:
	# DFU SoundClips.ButtonClick = archive ordinal 360, not numeric record ID 360.
	# Resolve once through normal mod precedence.
	# Host ownership keeps the short sound alive across the immediate page handoff.
	if _click.is_empty(): _click = media.resolve("creation.dialog.click","audio")
	if not is_instance_valid(_click_player):
		var instance: Dictionary = preload("res://scripts/av/replacement_instances.gd").audio(_click)
		if not instance.ok: return
		_click_player = instance.player
		host.add_child(_click_player)
	_click_player.play()
	click_submissions += 1

func class_jingle() -> Dictionary:
	if _class_jingle.is_empty(): _class_jingle = media.resolve("creation.class-drums","audio")
	return _class_jingle.duplicate()

func _scrollbar_thumb_baseline() -> Dictionary:
	# Pinned DFU MIT resources: retain the original five-pixel sliced bevel.
	var atlas := Image.create(5,3,false,Image.FORMAT_RGBA8)
	for index in 3:
		var file: String = "res://content/ui/classic/VScrollThumb"+["Top","Body","Bottom"][index]+".png"
		var texture: Texture2D = load(file)
		if texture == null: return {"ok":false,"reason":"Optional scrollbar thumb unavailable."}
		var bitmap := texture.get_image()
		if bitmap.get_size() != Vector2i(5,1): return {"ok":false,"reason":"Pinned scrollbar slice must be 5 by 1."}
		bitmap.convert(Image.FORMAT_RGBA8)
		atlas.blit_rect(bitmap,Rect2i(0,0,5,1),Vector2i(0,index))
	return {"ok":true,"image":atlas,"provenance":{"source":"DFU 1.1.1 Assets/Resources/VScrollThumb{Top,Body,Bottom}.png","license":"MIT","sampling":"nearest"}}

func narration(race: String) -> Dictionary:
	if race not in NARRATIONS: return {"ok":false,"reason":"Unsupported race narration."}
	if not _narrations.has(race): _narrations[race] = media.resolve("creation.narration."+race,"audio")
	return _narrations[race].duplicate()

func _baseline(target: String) -> Dictionary:
	return _decode_once(target,classic.creation_image.bind(FILES[target]))

func resolve(target: String) -> Dictionary:
	measurements.requests += 1
	if target.is_empty(): return {"ok":false,"reason":"This step uses a readable untextured dialog."}
	if _textures.has(target): return _textures[target].duplicate()
	var selected: Dictionary = media.resolve(target,"image")
	if not selected.ok:
		_textures[target] = selected
		return selected.duplicate()
	# Existing media replacements return detached RGBA resources, while the
	# classic baseline returns Image. Both use this one realization cache.
	var bitmap: Image = selected.get("image")
	if bitmap == null and selected.get("resource",{}).has("rgba"):
		var resource: Dictionary = selected.resource
		bitmap = Image.create_from_data(resource.width,resource.height,false,Image.FORMAT_RGBA8,resource.rgba)
	if bitmap == null or bitmap.is_empty(): return {"ok":false,"reason":"Selected interface image is unavailable."}
	var texture := ImageTexture.create_from_image(bitmap)
	measurements.textures += 1
	measurements.rgba_bytes += bitmap.get_width()*bitmap.get_height()*4
	_textures[target] = {"ok":true,"texture":texture,"pixel_hash":preload("res://scripts/data/actor_input_formats.gd").sha256(bitmap.get_data()),"pixel_size":bitmap.get_size(),"provenance":selected.get("provenance",{}).duplicate(true),"target":target,"resolution":selected.get("resolution","replacement")}
	return _textures[target].duplicate()

func dispose() -> void:
	if is_instance_valid(_click_player):
		_click_player.stop()
		_click_player.queue_free()
	_click_player = null
	_click.clear()
	_class_jingle.clear()
	_small_font = null
	_small_font_prepared = false
	_popup_font = null
	_popup_font_prepared = false
	_textures.clear()
	_baselines.clear()
	_narrations.clear()
	classic = null
	media = null
	definitions = null
