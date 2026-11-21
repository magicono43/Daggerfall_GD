extends RefCounted
const Provider = preload("res://scripts/startup/provider_boundary.gd")
const Images = preload("res://scripts/data/classic_image.gd")
const Inspector = preload("res://scripts/av/classic_media_inspector.gd")
const Hmi = preload("res://scripts/data/classic_hmi.gd")
const Model = preload("res://scripts/data/classic_model.gd")
const Vid = preload("res://scripts/data/classic_vid.gd")
var checks: Array[Dictionary] = []
var observations: Dictionary = {}

func check(id: String, expected: Variant, actual: Variant) -> void:
	print("MEDIA1: ",id)
	if expected is Dictionary or expected is Array or expected is PackedInt32Array:
		expected = JSON.stringify(expected)
		actual = JSON.stringify(actual)
	checks.append({"scenario":"MEDIA1/" + id,"expected":expected,"actual":actual})

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var provider := Provider.new()
	var access: RefCounted = provider.classic
	var sources := [{"file":"MIDI.BSA","format":"bsa-v1"},
		{"file":"TEXTURE.002","format":"classic-texture-v1"},
		{"file":"TEXTURE.024","format":"classic-texture-v1"},
		{"file":"TEXTURE.321","format":"classic-texture-v1"},
		{"file":"INVE00I0.IMG","format":"classic-img-v1"},
		{"file":"APAINT.CIF","format":"classic-cif-v1"},
		{"file":"BUTTONS.RCI","format":"classic-rci-v1"},
		{"file":"ART_PAL.COL","format":"classic-palette-v1"},
		{"file":"ANIM0011.VID","format":"classic-vid-v1"}]
	check("early sound", "before_readiness",access.decode_sound(3).kind)
	check("register and enable",true,provider.enable_classic_media(sources))
	var prepared: Dictionary = access.prepare(fixture.classic_source)
	observations.prepared = prepared
	check("prepare",true,prepared.ok)
	if not prepared.ok:
		provider.dispose()
		return result(fixture)
	check("early model","before_readiness",access.decode_model(44005).kind)
	check("publish",true,access.activate(prepared).ok)
	var sound: Dictionary = access.decode_sound({"ordinal":0})
	check("sound decode",true,sound.ok)
	if sound.ok:
		var value: Dictionary = sound.value.projection()
		check("sound id",3,value.provenance.classic_id)
		check("sound frames",39363,value.frame_count)
		check("sound rate",11025,value.sample_rate_hz)
		check("sound channels",1,value.channels)
		check("sound first",0,value.samples[0])
		check("sound sample18",-1,value.samples[18])
		value.samples[0] = 127
		check("sound detached",0,sound.value.projection().samples[0])
	var model: Dictionary = access.decode_model(44005)
	observations.model = _summary(model)
	check("model decode",true,model.ok)
	if model.ok:
		var value: Dictionary = model.value.projection()
		check("model points",48,value.points_source.size())
		check("model planes",34,value.planes.size())
		check("model first coordinate",[14336,-24576,-8192],value.points_source[0])
		check("model first normal",[-154,205,0],value.planes[0].normal_source)
		check("model first texture",24,value.planes[0].texture_archive)
		check("model source space","unavailable",value.world_conversion)
		check("model plane references",[2,1,0,3],value.planes[0].point_indices)
		check("model triangles",[3,0,1,1,2,3],Array(value.planes[0].triangles))
		check("model first UV",Vector2(112,512),value.planes[0].uv_sixteenths[0])
		check("model derived UV",Vector2.ZERO,value.planes[0].uv_sixteenths[3])
	var decoded_images := {}
	for name: String in ["TEXTURE.002","INVE00I0.IMG","APAINT.CIF","BUTTONS.RCI","ART_PAL.COL","ANIM0011.VID"]:
		var decoded: Dictionary = access.read_record(name,{"record":0,"frame":0})
		check("decode " + name,true,decoded.ok)
		observations[name] = _summary(decoded)
		decoded_images[name] = decoded
	var golden := {"TEXTURE.002":[64,64,104,104,103,103],"INVE00I0.IMG":[320,200,63,118,123,124],"APAINT.CIF":[80,60,121,121,122,43],"BUTTONS.RCI":[32,16,121,112,220,121]}
	for name: String in golden:
		if decoded_images[name].ok:
			var value: Dictionary = decoded_images[name].value.projection()
			var indices: PackedByteArray = value.indices
			check("golden dimensions/corners " + name,golden[name],[value.width,value.height,indices[0],indices[value.width - 1],indices[(value.height - 1) * value.width],indices[-1]])
			check("bad frame " + name,"record_not_found",access.read_record(name,{"record":0,"frame":999}).kind)
	if decoded_images["ART_PAL.COL"].ok:
		var value: Dictionary = decoded_images["ART_PAL.COL"].value.projection()
		check("palette entry1",[255,229,129],Array(value.rgb.slice(3,6)))
	if decoded_images["ANIM0011.VID"].ok:
		var value: Dictionary = decoded_images["ANIM0011.VID"].value.projection()
		check("VID dimensions/count",[320,200,35],[value.width,value.height,value.frame_count])
		check("VID first block",[4490,3,15,5],[value.position,value.block_type,value.frame_delay_source,value.global_delay_source])
		check("VID audio timeline",[0,3700,11025],[value.audio_start_sample,value.audio_end_sample,value.sample_rate_hz])
		check("VID first source run",[0,0],[value.indices[0],value.indices[126]])
		var later: Dictionary = access.read_record("ANIM0011.VID",{"record":0,"frame":10})
		var last: Dictionary = access.read_record("ANIM0011.VID",{"record":0,"frame":34})
		check("VID later frame",true,later.ok)
		check("VID last frame",true,last.ok)
		if later.ok:
			decoded_images["VID-preview"] = later
			observations["VID-preview"] = _summary(later)
	var sequence: Dictionary = access.decode_sequence("D1.HMI")
	check("sequence decode",true,sequence.ok)
	observations.sequence = _summary(sequence)
	if sequence.ok:
		var value: Dictionary = sequence.value.projection()
		check("HMI tracks",4,value.tracks.size())
		check("HMI positions",[420,603],[value.tracks[0].position,value.tracks[0].data_position])
		check("HMI initial event",[176,105,1],Array(value.tracks[0].events[0].midi))
		check("HMI converter timing",[192,1605631],[value.ticks_per_quarter,value.initial_tempo_us])
		check("HMI no synthesis",false,value.synthesis_ready)
		check("HMI repeat stable",value.smf,access.decode_sequence("D1.HMI").value.projection().smf)
	_synthetic(fixture)
	var second: Dictionary = access.prepare(fixture.classic_source)
	check("active preparation retains readers",0,second.ticket)
	check("late adapter rejection",false,access.register_adapter("late",sources))
	check("late capability rejection",false,access.enable_capability("late"))
	check("sound absent","record_not_found",access.decode_sound(4294967295).kind)
	check("model absent","record_not_found",access.decode_model(4294967295).kind)
	check("wrong media address","malformed_or_unsupported",access.read_record("BUTTONS.RCI",0).kind)
	if DisplayServer.get_name() != "headless" and sound.ok and model.ok:
		await _rendered(shell,fixture,access,sound,model,decoded_images)
	provider.dispose()
	check("disposed",false,access.ready())
	return result(fixture)

func _synthetic(fixture: Dictionary) -> void:
	var decoder := Images.new()
	# Hand-authored 2x2 IMG, four corners and signed source offsets; no encoder.
	var tiny := PackedByteArray([254,255,3,0,2,0,2,0,0,0,4,0,0,1,2,3])
	var image := decoder.decode(tiny,"TINY.IMG",0,0)
	check("golden IMG",[0,1,2,3],Array(image.indices))
	check("golden offsets",[-2,3],[image.offset_x,image.offset_y])
	var colors := PackedByteArray()
	colors.resize(768)
	colors[3] = 255
	colors[7] = 255
	colors[11] = 255
	var rgba := decoder.rgba(image,decoder.palette(colors),0)
	check("palette alpha corners",[0,0,0,0,255,0,0,255,0,255,0,255,0,0,255,255],Array(rgba.rgba))
	var rle := PackedByteArray([0,0,0,0,2,0,2,0,2,0,4,0,129,8,129,9])
	check("CIF RLE",[8,8,9,9],Array(decoder.decode(rle,"TINY.CIF",0,0).indices))
	# Two hand-authored row-table frames: mixed repeated and raw rows.
	var texture := PackedByteArray([1,0])
	texture.resize(26)
	texture.append_array(PackedByteArray([0,0,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]))
	texture.append_array(PackedByteArray([0,0,0,0,2,0,2,0,8,1,58,0,0,0,28,0,0,0,1,0,2,0,0,0,0,0,0,0]))
	texture.append_array(PackedByteArray([44,0,0,128,49,0,0,0,51,0,0,128,56,0,0,0,2,0,254,255,8,9,10,2,0,254,255,11,12,13]))
	for compression in [0x108,0x1108]:
		texture[55] = compression >> 8
		check("texture RLE %x frame0" % compression,[8,8,9,10],Array(decoder.decode(texture,"TEXTURE.999",0,0).indices))
		check("texture RLE %x frame1" % compression,[11,11,12,13],Array(decoder.decode(texture,"TEXTURE.999",0,1).indices))
	texture[77] = 64
	check("texture unsupported row",false,decoder.decode(texture,"TEXTURE.999",0,0).ok)
	texture[77] = 128
	texture[92] = 253
	check("texture oversized row run",false,decoder.decode(texture,"TEXTURE.999",0,0).ok)
	# Logical size32 does not bound shared storage; data begins at relative40.
	var shared_rows := texture.slice(0,74)
	shared_rows.resize(344)
	shared_rows[54] = 0
	shared_rows[55] = 0
	shared_rows[56] = 32
	shared_rows[60] = 40
	shared_rows[66] = 1
	shared_rows[86] = 1
	shared_rows[87] = 2
	shared_rows[342] = 3
	shared_rows[343] = 4
	var raw_profile := decoder.decode(shared_rows,"TEXTURE.999",0,0)
	shared_rows[55] = 9
	var flagged_profile := decoder.decode(shared_rows,"TEXTURE.999",0,0)
	check("texture logical versus physical extent",[[1,2,3,4],[1,2,3,4]],[Array(raw_profile.indices) if raw_profile.ok else raw_profile,Array(flagged_profile.indices) if flagged_profile.ok else flagged_profile])
	var mesh := PackedByteArray()
	mesh.resize(144)
	mesh[4] = 3
	mesh[8] = 1
	mesh[48] = 64
	mesh[52] = 100
	mesh[60] = 112
	mesh[77] = 1
	mesh[93] = 1
	mesh[109] = 1
	mesh[112] = 3
	mesh[132] = 16
	mesh[140] = 240
	mesh[141] = 255
	mesh[142] = 16
	for version: String in ["v2.5","v2.6","v2.7"]:
		var encoded := version.to_ascii_buffer()
		for index in 4: mesh[index] = encoded[index]
		mesh[128] = 4 if version == "v2.5" else 12
		mesh[136] = 8 if version == "v2.5" else 24
		var decoded: Dictionary = Model.new().decode({"ok":true,"bytes":mesh,"source":"golden","record":1000,"identity":1000,"offset":0})
		check("model golden " + version,[[0,0,0],[256,0,0],[0,256,0]],decoded.value.projection().points_source if decoded.ok else decoded)
	check("model named ID rejected",false,Model.new().decode({"ok":true,"bytes":mesh,"source":"golden","record":"1000","identity":"1000","offset":0}).ok)
	mesh[125] = 144
	check("model unverified UV correction rejected",false,Model.new().decode({"ok":true,"bytes":mesh,"source":"golden","record":100,"identity":100,"offset":0}).ok)
	for length in [0,1,11,12,15]: check("IMG truncate %d" % length,false,decoder.decode(tiny.slice(0,length),"TINY.IMG",0,0).ok)
	var unsupported := tiny.duplicate()
	unsupported[8] = 3
	check("IMG unsupported",false,decoder.decode(unsupported,"TINY.IMG",0,0).ok)
	rle[12] = 255
	check("CIF oversized run",false,decoder.decode(rle,"TINY.CIF",0,0).ok)
	check("RCI unknown",false,decoder.decode(tiny,"UNKNOWN.RCI",0,0).ok)
	check("RCI partial",false,decoder.decode(tiny,"BUTTONS.RCI",0,0).ok)
	check("palette truncate",false,decoder.palette(colors.slice(0,767)).ok)
	check("palette unsupported alpha",false,decoder.rgba(image,decoder.palette(colors),256).ok)
	var cursor := preload("res://scripts/data/media_cursor.gd").new(PackedByteArray([1]))
	check("bounded cursor",0,cursor.u32())
	check("bounded cursor position",0,cursor.position)
	check("truncated model",false,Model.new().decode({"ok":true,"bytes":tiny,"source":"golden","record":1,"identity":1,"offset":0}).ok)
	check("truncated VID",false,Vid.new().decode(tiny,0).ok)
	check("truncated HMI",false,Hmi.new().decode({"ok":true,"bytes":tiny,"source":"golden","record":"TINY.HMI","identity":"TINY.HMI","offset":0}).ok)
	var video := PackedByteArray([86,73,68,0,2,3,0,2,0,2,0,5,0,14,0,2])
	video.resize(784)
	video.append_array(PackedByteArray([124,0,0,166,3,0,0,128,255,3,1,0,4,0,1,2,3,1,2,0,130,2,5,6,4,3,0,1,0,2,7,8,20]))
	check("VID literal pixels",[0,1,2,3],Array(Vid.new().decode(video,0).indices))
	check("VID delta pixels",[0,1,5,6],Array(Vid.new().decode(video,1).indices))
	check("VID row pixels",[0,1,7,8],Array(Vid.new().decode(video,2).indices))
	check("VID repeat independent",[0,1,2,3],Array(Vid.new().decode(video,0).indices))
	check("VID exact audio",[0,128,255],Array(Vid.new().decode(video,0).audio))
	check("VID no timing floor",3,Vid.new().decode(video,0).audio_end_sample)
	var bad_video := video.duplicate()
	bad_video[787] = 165
	check("VID bad audio rate",false,Vid.new().decode(bad_video,0).ok)
	check("VID truncated run",false,Vid.new().decode(video.slice(0,797),0).ok)
	check("VID out of range","record_not_found",Vid.new().decode(video,3).kind)
	var with_audio_tail := video.slice(0,793)
	with_audio_tail.append_array(PackedByteArray([125,2,0,64,192]))
	with_audio_tail.append_array(video.slice(793,video.size() - 1))
	with_audio_tail.append_array(PackedByteArray([125,2,0,1,2,20]))
	var audio_tail := Vid.new().decode(with_audio_tail,2)
	check("VID consecutive and tail audio",[[0,3,[0,128,255]],[3,5,[64,192]],[5,7,[1,2]]],audio_tail.audio_chunks.map(func(chunk: Dictionary) -> Array: return [chunk.start_sample,chunk.end_sample,Array(chunk.pcm_u8)]) if audio_tail.ok else audio_tail)
	var hmi := PackedByteArray()
	hmi.resize(465)
	var signature := "HMI-MIDISONG061595".to_ascii_buffer()
	for index in signature.size(): hmi[index] = signature[index]
	hmi[228] = 1
	hmi[370] = 118
	hmi[371] = 1
	signature = "HMI-MIDITRACK".to_ascii_buffer()
	for index in signature.size(): hmi[374 + index] = signature[index]
	hmi[461] = 91
	hmi.append_array(PackedByteArray([0,144,60,100,96,96,255,81,3,7,161,32,96,255,47,0]))
	var raw := {"ok":true,"bytes":hmi,"source":"golden","record":"TINY.HMI","identity":"TINY.HMI","offset":0}
	var sequence: Dictionary = Hmi.new().decode(raw)
	check("HMI golden sequence",true,sequence.ok)
	if sequence.ok:
		var value: Dictionary = sequence.value.projection()
		check("HMI golden release",[144,60,0],Array(value.tracks[0].events[1].midi))
		check("HMI golden release tick",96,value.tracks[0].events[1].tick)
		check("HMI tempo change",[255,81,3,7,161,32],Array(value.tracks[0].events[2].midi))
		check("HMI tempo integration",202140576,value.duration_us_numerator)
		check("HMI terminal timing",[192,[96,255,47,0]],[value.duration_us_denominator,Array(value.smf.slice(value.smf.size() - 4))])
	var broken := hmi.duplicate()
	broken[466] = 247
	raw.bytes = broken
	check("HMI unsupported system",false,Hmi.new().decode(raw).ok)
	raw.bytes = hmi.slice(0,hmi.size() - 1)
	check("HMI missing terminal",false,Hmi.new().decode(raw).ok)
	var cases := preload("res://tests/classic_cases.gd").new()
	cases.sandbox = fixture.sandbox
	var root: String = cases.fixture_root("media-disposable")
	cases.write_bytes(root.path_join("TINY.IMG"),tiny)
	var access := preload("res://scripts/data/classic_access.gd").new()
	check("synthetic registration",true,access.register_adapter("image-test",[{"file":"TINY.IMG","format":"classic-img-v1"}]))
	check("synthetic enable",true,access.enable_capability("image-test"))
	var old: Dictionary = access.prepare(root)
	var current: Dictionary = access.prepare(root)
	check("stale ticket","before_readiness",access.activate(old).kind)
	access.discard_prepared()
	check("cancel clears readers",0,access.prepared_count())
	check("cancelled ticket","before_readiness",access.activate(current).kind)
	var fresh: Dictionary = access.prepare(root)
	check("retry activation",true,access.activate(fresh).ok)
	check("late-source removal",OK,DirAccess.remove_absolute(root.path_join("TINY.IMG")))
	check("late-source failure","source_unavailable",access.read_record("TINY.IMG",{"record":0,"frame":0}).kind)
	access.dispose()
	check("required missing preparation",false,access.prepare(root).ok)
	check("failed preparation cleanup",0,access.prepared_count())
	access.dispose()

func _rendered(shell: Control, fixture: Dictionary, access: RefCounted, sound: Dictionary, model: Dictionary, images: Dictionary) -> void:
	shell.clear()
	var inspector := Inspector.new()
	var colors: RefCounted = images["ART_PAL.COL"].value
	var textures := {}
	for plane: Dictionary in model.value.projection().planes:
		var key := "%d/%d" % [plane.texture_archive,plane.texture_record]
		if textures.has(key): continue
		var decoded: Dictionary = access.read_record("TEXTURE.%03d" % plane.texture_archive,{"record":plane.texture_record,"frame":0})
		if not decoded.ok:
			observations.required_texture_failure = decoded
			check("required model texture " + key,true,false)
			return
		var made := inspector.image_resource(decoded.value,colors,-1)
		textures[key] = made.texture
	var first := inspector.model_resource(model.value,textures)
	var second := inspector.model_resource(model.value,textures)
	check("AV mesh construction",true,first.ok and second.ok)
	if not first.ok or not second.ok: return
	check("AV independent material",false,first.materials[0] == second.materials[0])
	check("AV independent texture",false,first.materials[0].albedo_texture == second.materials[0].albedo_texture)
	first.materials[0].albedo_color = Color.RED
	check("AV material mutation isolated",Color.WHITE,second.materials[0].albedo_color)
	first.materials[0].albedo_color = Color.WHITE
	check("AV engine winding",[3,1,0,1,3,2],Array(first.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX]))
	var before: Color = second.materials[0].albedo_texture.get_image().get_pixel(0,0)
	var changed: Image = first.materials[0].albedo_texture.get_image()
	changed.fill(Color.RED)
	first.materials[0].albedo_texture.update(changed)
	check("AV nested texture mutation isolated",before,second.materials[0].albedo_texture.get_image().get_pixel(0,0))
	check("AV source texture retained",before,textures["24/0"].get_image().get_pixel(0,0))
	first.materials[0].albedo_texture.update(textures["24/0"].get_image())
	var viewport := SubViewport.new()
	viewport.size = Vector2i(640,480)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	shell.add_child(viewport)
	var instance := MeshInstance3D.new()
	instance.mesh = first.mesh
	viewport.add_child(instance)
	var bounds: AABB = first.mesh.get_aabb()
	var center := bounds.get_center()
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.position = center + Vector3(1,-0.6,1).normalized() * bounds.size.length() * 1.5
	camera.look_at(center,Vector3.UP)
	camera.current = true
	var canvas := TextureRect.new()
	canvas.texture = viewport.get_texture()
	canvas.position = Vector2(20,20)
	canvas.size = Vector2(640,480)
	shell.add_child(canvas)
	var panel := HBoxContainer.new()
	panel.position = Vector2(20,510)
	shell.add_child(panel)
	for name: String in ["TEXTURE.002","INVE00I0.IMG","APAINT.CIF","BUTTONS.RCI"]:
		var image := inspector.image_resource(images[name].value,colors,-1)
		var rect := TextureRect.new()
		rect.texture = image.texture
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.custom_minimum_size = Vector2(160,120)
		rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		panel.add_child(rect)
	if images.has("VID-preview"):
		var image := inspector.video_frame_resource(images["VID-preview"].value)
		check("AV VID frame",true,image.ok)
		check("saved VID frame",OK,image.image.save_png(str(fixture.sandbox).path_join("classic-vid-frame10.png")))
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var captured := viewport.get_texture().get_image()
	check("rendered mesh image",false,captured.is_empty())
	check("saved mesh image",OK,captured.save_png(str(fixture.sandbox).path_join("classic-model.png")))
	check("saved media contact sheet",OK,shell.get_viewport().get_texture().get_image().save_png(str(fixture.sandbox).path_join("classic-images.png")))
	var resource_a := inspector.sound_resource(sound.value)
	var resource_b := inspector.sound_resource(sound.value)
	resource_a.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	resource_a.stream.loop_end = sound.value.projection().frame_count
	check("audio loop isolated",AudioStreamWAV.LOOP_DISABLED,resource_b.stream.loop_mode)
	var a := AudioStreamPlayer.new()
	var b := AudioStreamPlayer.new()
	a.stream = resource_a.stream
	b.stream = resource_b.stream
	shell.add_child(a)
	shell.add_child(b)
	a.play()
	b.play()
	await shell.get_tree().create_timer(0.12).timeout
	check("audio two cursors",true,a.playing and b.playing)
	a.seek(0.5)
	a.stop()
	check("audio stop isolated",true,b.playing and not a.playing)
	check("audio cursor isolated",true,b.get_playback_position() < 0.5)
	check("saved decoded clip",OK,resource_a.stream.save_to_wav(str(fixture.sandbox).path_join("classic-sound.wav")))
	b.stop()
	a.queue_free()
	b.queue_free()
	panel.queue_free()
	canvas.queue_free()
	viewport.queue_free()
	await shell.get_tree().process_frame

func _summary(decoded: Dictionary) -> Dictionary:
	if not decoded.ok: return decoded
	var value: Dictionary = decoded.value.projection()
	for key in ["indices","samples","palette_rgb","rgb","audio","smf"]:
		if value.has(key):
			value[key + "_size"] = value[key].size()
			value.erase(key)
	if value.has("planes"): value.planes = value.planes.slice(0,1)
	if value.has("points_source"): value.points_source = value.points_source.slice(0,3)
	if value.has("events"): value.events = value.events.slice(0,5)
	if value.has("audio_chunks"):
		value.audio_chunks = value.audio_chunks.map(func(chunk: Dictionary) -> Dictionary: return {"position":chunk.position,"start_sample":chunk.start_sample,"end_sample":chunk.end_sample,"samples":chunk.pcm_u8.size()})
	if value.has("tracks"):
		var tracks: Array = value.tracks
		value.tracks = tracks.map(func(track: Dictionary) -> Dictionary: return {"track":track.track,"position":track.position,"data_position":track.data_position,"end_tick":track.end_tick,"event_count":track.events.size(),"markers":track.markers})
	return value

func result(fixture: Dictionary) -> Dictionary:
	var ok := true
	for item: Dictionary in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"count":checks.size(),"checks":checks,"fixture":fixture.fixture,"inputs":fixture.inputs,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"observations":observations}
