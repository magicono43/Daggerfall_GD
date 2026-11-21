extends "res://tests/mod_cases.gd"
const Fixture = preload("res://tests/replacement_fixture.gd")
const Instances = preload("res://scripts/av/replacement_instances.gd")
const Codec = preload("res://scripts/data/replacement_codec.gd")
var media: RefCounted
var data: RefCounted
var mods: RefCounted
var controller: RefCounted
var observations := {}

func put_bytes(path: String, bytes: PackedByteArray) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()

func zip_bytes(path: String, entries: Dictionary) -> void:
	var zip := ZIPPacker.new()
	zip.open(path)
	for file: String in entries:
		zip.start_file(file)
		zip.write_file(entries[file] if entries[file] is PackedByteArray else str(entries[file]).to_utf8_buffer())
		zip.close_file()
	zip.close()

func rebuild() -> Dictionary:
	return controller.providers.prepare_content(mods)

func pixels(result: Dictionary) -> Array:
	return Array(result.resource.rgba) if result.ok else []

func changed_glb(change: Callable) -> PackedByteArray:
	var bytes := FileAccess.get_file_as_bytes(Fixture.ROOT+"/triangle.glb.bytes")
	var size := bytes.decode_u32(12)
	var document: Dictionary = JSON.parse_string(bytes.slice(20,20+size).get_string_from_utf8())
	change.call(document)
	var encoded := JSON.stringify(document).to_utf8_buffer()
	while encoded.size() % 4 != 0: encoded.append(32)
	var binary := bytes.slice(20+size)
	var result := PackedByteArray()
	result.resize(20)
	result.encode_u32(0,0x46546c67)
	result.encode_u32(4,2)
	result.encode_u32(8,20+encoded.size()+binary.size())
	result.encode_u32(12,encoded.size())
	result.encode_u32(16,0x4e4f534a)
	result.append_array(encoded)
	result.append_array(binary)
	return result

func pack(folder_name: String, id: String, entries: Array, file := "content.json") -> String:
	var path: String = mods.root.path_join("Mods").path_join(folder_name)
	var metadata := manifest(id)
	metadata.content = [file]
	metadata.capabilities = ["data.media-v1"]
	write(path.path_join("mod.json"),JSON.stringify(metadata))
	write(path.path_join(file),JSON.stringify(Fixture.envelope("targets","patch",entries)))
	return path

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	controller = shell.controller
	mods = controller.mods
	data = controller.providers.definitions
	media = controller.providers.media
	controller.settings.apply({"startup/show_setup":true})
	controller.settings.effective["startup/show_setup"] = true
	# Loose payloads must be in the initial immutable-for-this-run intake.
	var loose_root: String = mods.root.path_join("Overrides")
	put_bytes(loose_root.path_join("media/corners.png"),FileAccess.get_file_as_bytes(Fixture.ROOT+"/corners.png.bytes"))
	write(loose_root.path_join("a-exports.json"),JSON.stringify(Fixture.envelope("exports","add",[Fixture.export_entry("corners","MeDiA/CoRnErS.PnG")])))
	write(loose_root.path_join("b-targets.json"),JSON.stringify(Fixture.envelope("targets","add",[Fixture.target("classic.texture.2.0.0","@loose","corners") ])))
	controller.select_folder(fixture.classic_source)
	check("setup remains editable","optional_setup",controller.route)
	var candidate := rebuild()
	check("shipped PCK and loose bytes validate",true,candidate.ok)
	check("no early publication","before_readiness",media.export_resource("@shipped/media-assets","corners","image").kind)
	check("owner alias collision rejected",false,media.register_target("sound.3","audio",[],Callable()).ok)
	var image: Dictionary = media.export_resource("@shipped/media-assets","corners","image",candidate.ticket)
	check("PNG corner bytes",[255,0,0,255,0,255,0,128,0,0,255,255,255,255,255,0],pixels(image))
	check("PNG palette alpha",pixels(image),pixels(media.export_resource("@shipped/media-assets","palette","image",candidate.ticket)))
	check("PNG RGB opaque colors",[255,0,0,255,0,255,0,255,0,0,255,255,255,255,255,255],pixels(media.export_resource("@shipped/media-assets","rgb","image",candidate.ticket)))
	check("PNG source frame","png-top-left-v1",image.resource.frame)
	check("qualified missing provider","missing_provider",media.export_resource("absent","corners","image",candidate.ticket).kind)
	check("qualified wrong type","wrong_type",media.export_resource("@shipped/media-assets","corners","audio",candidate.ticket).kind)
	var baseline: Dictionary = media.resolve("model.44005","model",candidate.ticket)
	check("real classic baseline when absent",true,baseline.ok)
	check("real baseline decoded frames",48,baseline.value.projection().points_source.size())
	check("unknown alias explicit","unknown_target",media.resolve("sound.999999","audio",candidate.ticket).kind)
	for bits: int in [8,16]:
		for channels: int in [1,2]:
			for rate: int in [22050,44100,48000]:
				var id := "pcm-%d-%d-%d" % [bits,channels,rate]
				var audio: Dictionary = media.export_resource("@shipped/media-assets",id,"audio",candidate.ticket)
				check(id+" decoded",true,audio.ok)
				check(id+" metadata",[bits,channels,rate,4],[audio.resource.bits,audio.resource.channels,audio.resource.sample_rate_hz,audio.resource.frames])
				var expected: Array = [0,128,255,64] if bits == 8 else [-32768,0,32767,-16384]
				if channels == 2:
					expected = [0,64,128,255,255,128,64,0] if bits == 8 else [-32768,-16384,0,32767,32767,0,-16384,-32768]
				var actual: Array = []
				for i in expected.size(): actual.append(audio.resource.samples[i] if bits == 8 else audio.resource.samples.decode_s16(i*2))
				check(id+" exact samples",expected,actual)
				check(id+" engine first sample",128 if bits == 8 else 0,audio.resource.stream.data[0])
	var model: Dictionary = media.export_resource("@shipped/media-assets","triangle","model",candidate.ticket)
	check("GLB runtime decoded",true,model.ok)
	var mesh: ArrayMesh = model.resource.meshes[0]
	var arrays: Array = mesh.surface_get_arrays(0)
	check("GLB source positions",[Vector3.ZERO,Vector3.RIGHT,Vector3.UP],Array(arrays[Mesh.ARRAY_VERTEX]))
	check("GLB clockwise indices",[0,2,1],Array(arrays[Mesh.ARRAY_INDEX]))
	check("GLB detached source winding",[0,1,2],Array(model.resource.geometry_source[0][0].indices_ccw))
	check("GLB normals",true,arrays[Mesh.ARRAY_NORMAL][0].distance_to(Vector3.BACK) < 0.0001 and arrays[Mesh.ARRAY_NORMAL][1].distance_to(Vector3.BACK) < 0.0001 and arrays[Mesh.ARRAY_NORMAL][2].distance_to(Vector3.BACK) < 0.0001)
	check("GLB UV orientation",[Vector2.ZERO,Vector2.RIGHT,Vector2.DOWN],Array(arrays[Mesh.ARRAY_TEX_UV]))
	check("GLB source translation",Vector3(2,3,4),model.resource.transforms[0].origin)
	check("GLB source scale",Vector3(2,1,1),model.resource.transforms[0].basis.get_scale())
	var rotated := Codec.decode(changed_glb(func(doc: Dictionary): doc.nodes[0].rotation = [0,0,sqrt(0.5),sqrt(0.5)]),"static-glb-v1","model")
	check("GLB rotation local scale order",true,rotated.transforms[0].basis.x.distance_to(Vector3(0,2,0)) < 0.00001 and rotated.transforms[0].basis.y.distance_to(Vector3(-1,0,0)) < 0.00001)
	check("GLB embedded PNG",true,mesh.surface_get_material(0).albedo_texture.get_image().get_pixel(0,0).is_equal_approx(Color.RED))
	var first := Instances.model_resources(model)
	var second := Instances.model_resources(model)
	check("GLB visual mesh shared",true,first.meshes[0].mesh == second.meshes[0].mesh)
	first.meshes[0].materials[0].albedo_color = Color.BLUE
	check("GLB material consumer isolated",Color.WHITE,second.meshes[0].materials[0].albedo_color)
	check("GLB material source unchanged",Color.WHITE,mesh.surface_get_material(0).albedo_color)
	var mat_a := Instances.image_material(image)
	var mat_b := Instances.image_material(image)
	mat_a.material.next_pass.albedo_color = Color.RED
	check("nested material isolation",Color.WHITE,mat_b.material.next_pass.albedo_color)
	check("independent nested resources",false,mat_a.material.next_pass == mat_b.material.next_pass)
	var blue := Image.create(2,2,false,Image.FORMAT_RGBA8)
	blue.fill(Color.BLUE)
	first.meshes[0].materials[0].albedo_texture.set_image(blue)
	check("nested GLB texture isolated",Color.RED,second.meshes[0].materials[0].albedo_texture.get_image().get_pixel(0,0))
	check("cached GLB nested source unchanged",Color.RED,mesh.surface_get_material(0).albedo_texture.get_image().get_pixel(0,0))
	var ogg: Dictionary = media.export_resource("@shipped/media-assets","tone","audio",candidate.ticket)
	check("Vorbis codec identity","vorbis",ogg.resource.codec)
	check("Vorbis finite duration",true,abs(ogg.resource.seconds-0.5) < 0.001)
	check("Vorbis granule metadata",[44100,1,22050],[ogg.resource.sample_rate_hz,ogg.resource.channels,ogg.resource.frames])
	var player_a := Instances.audio(ogg,true).player as AudioStreamPlayer
	var player_b := Instances.audio(ogg,false).player as AudioStreamPlayer
	shell.add_child(player_a)
	shell.add_child(player_b)
	check("audio resources independent",false,player_a.stream == player_b.stream)
	check("audio loop independent",[true,false],[player_a.stream.loop,player_b.stream.loop])
	player_a.play()
	player_b.play()
	await shell.get_tree().create_timer(0.08).timeout
	player_a.seek(0.25)
	check("audio seek isolated",true,abs(player_b.get_playback_position()-player_a.get_playback_position()) > 0.1)
	player_a.stop()
	check("audio stop isolated",true,player_b.playing)
	await shell.get_tree().create_timer(0.6).timeout
	var finite: AudioStreamPlayback = ogg.resource.stream.instantiate_playback()
	finite.start(0)
	var mixed := finite.mix_audio(1.0,44100)
	var peak := 0.0
	for sample: Vector2 in mixed: peak = max(peak,abs(sample.x))
	check("Vorbis decoded tone amplitude",true,peak > 0.15 and peak < 0.25)
	check("Vorbis finite playback end",false,finite.is_playing())
	player_a.queue_free()
	player_b.queue_free()
	await shell.get_tree().process_frame
	check("audio consumers cleanup",false,is_instance_valid(player_a))
	var root_a := pack("A","media.a",[Fixture.target("classic.sound.3","media.a","clip","audio")])
	write(root_a.path_join("a-exports.json"),JSON.stringify(Fixture.envelope("exports","add",[Fixture.export_entry("clip","clip.wav","pcm-wav-v1","audio")])))
	var metadata := manifest("media.a")
	metadata.content = ["a-exports.json","b-extra.json","content.json"]
	metadata.capabilities = ["data.media-v1"]
	write(root_a.path_join("mod.json"),JSON.stringify(metadata))
	put_bytes(root_a.path_join("clip.wav"),FileAccess.get_file_as_bytes(Fixture.ROOT+"/pcm-16-2-44100.wav.bytes"))
	var zip_path: String = mods.root.path_join("Mods/B.zip")
	var bm := manifest("media.b")
	bm.content = ["a-exports.json","content.json"]
	bm.capabilities = ["data.media-v1"]
	var zip_entries := {"mod.json":JSON.stringify(bm),"a-exports.json":JSON.stringify(Fixture.envelope("exports","add",[Fixture.export_entry("clip","clip.wav","pcm-wav-v1","audio")])),"content.json":JSON.stringify(Fixture.envelope("targets","patch",[Fixture.target("sound.3","media.b","clip","audio") ])),"clip.wav":FileAccess.get_file_as_bytes(Fixture.ROOT+"/pcm-8-1-22050.wav.bytes")}
	# The separately added mod target retains its originating provider identity.
	write(root_a.path_join("b-extra.json"),JSON.stringify(Fixture.envelope("targets","add",[Fixture.target("asset.media.a.extra","media.a","clip","audio")])))
	zip_bytes(zip_path,zip_entries)
	mods.rescan()
	mods.edit("media.a","toggle")
	mods.edit("media.b","toggle")
	candidate = rebuild()
	check("folder ZIP replacements validate",true,candidate.ok)
	var selected: Dictionary = media.resolve("sound.3","audio",candidate.ticket)
	check("equivalent aliases canonical","classic.sound.3",selected.target)
	check("later valid winner","media.b",selected.target_record.winner.provider)
	check("origin key retained","@shipped/media-assets",selected.target_record.identity.package)
	check("target contributors",3,selected.target_record.contributors.size())
	check("target field winner","media.b",selected.target_record.fields.asset.provider)
	check("direct provider isolation",44100,media.export_resource("media.a","clip","audio",candidate.ticket).resource.sample_rate_hz)
	check("logical selected type",22050,selected.resource.sample_rate_hz)
	check("mod-added logical target",true,media.resolve("asset.media.a.extra","audio",candidate.ticket).ok)
	check("loose target winner","@loose",media.resolve("texture.2.0.0","image",candidate.ticket).target_record.winner.provider)
	var retained: Dictionary = selected
	var old_ticket: int = candidate.ticket
	mods.edit("media.b","up")
	check("edited preview stale","before_readiness",media.resolve("sound.3","audio",old_ticket).kind)
	# Both patch the declared owner target; order changes the actual winner.
	candidate = rebuild()
	check("reorder candidate valid",true,candidate.ok)
	check("reorder changes winner","media.a",media.resolve("sound.3","audio",candidate.ticket).target_record.winner.provider)
	check("rejected candidate preserves retained resource",22050,retained.resource.sample_rate_hz)
	mods.edit("media.b","down")
	candidate = rebuild()
	check("clean retry valid",true,candidate.ok)
	check("generation changes cache identity",false,retained.request_key == media.resolve("sound.3","audio",candidate.ticket).request_key)
	# Invalid selected export never silently falls back, even with a later valid target.
	zip_entries["clip.wav"] = PackedByteArray([1,2,3])
	zip_bytes(zip_path,zip_entries)
	mods.rescan()
	candidate = rebuild()
	check("truncated selected export rejects",false,candidate.ok)
	check("invalid selected cannot resolve baseline","before_readiness",media.resolve("sound.3","audio",candidate.ticket).kind)
	check("invalid export attribution",true,candidate.issues[0].reason.contains("media.b/clip"))
	if DisplayServer.get_name() != "headless":
		controller.check_content()
		candidate = data.projection() # Recovery rebuilt; omission must use its new ticket.
		shell.render()
		await shell.get_tree().process_frame
		for child in shell.panel.get_children():
			if child is Label and child.text.begins_with("Definitions ·"):
				shell.panel.get_parent().scroll_vertical = int(child.position.y)
				break
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var recovery_capture := shell.get_viewport().get_texture().get_image()
		check("invalid replacement recovery rendered",false,recovery_capture.is_empty())
		recovery_capture.save_png(sandbox.path_join("replacement-recovery.png"))
	var bad_ticket: int = candidate.ticket
	var token: String = candidate.issues[0].token
	check("stale omission denied",false,data.omit(token,bad_ticket-1,mods).ok)
	check("current omission admitted",true,data.omit(token,bad_ticket,mods).ok)
	candidate = rebuild()
	check("omission cannot bypass required export",false,candidate.ok)
	var reference: Dictionary = candidate.issues[-1]
	check("omit dependent contribution admitted",true,data.omit(reference.token,candidate.ticket,mods).ok)
	candidate = rebuild()
	check("omitted configuration revalidated",true,candidate.ok)
	check("explicit omission exposes A","media.a",media.resolve("sound.3","audio",candidate.ticket).target_record.winner.provider)
	zip_entries["clip.wav"] = FileAccess.get_file_as_bytes(Fixture.ROOT+"/pcm-8-1-22050.wav.bytes")
	zip_bytes(zip_path,zip_entries)
	mods.rescan()
	candidate = rebuild()
	check("rescan clears run omissions",0,candidate.omitted.size())
	check("repaired candidate winner","media.b",media.resolve("sound.3","audio",candidate.ticket).target_record.winner.provider)
	var good_a := FileAccess.get_file_as_bytes(root_a.path_join("clip.wav"))
	put_bytes(root_a.path_join("clip.wav"),PackedByteArray([0]))
	mods.rescan()
	candidate = rebuild()
	check("invalid earlier selected contribution blocks later valid winner",false,candidate.ok)
	check("earlier invalid provider attribution",true,candidate.issues[0].reason.contains("media.a/clip"))
	put_bytes(root_a.path_join("clip.wav"),good_a)
	mods.rescan()
	DirAccess.remove_absolute(root_a.path_join("clip.wav"))
	candidate = rebuild()
	check("late read failure classified","missing",candidate.issues[0].kind)
	put_bytes(root_a.path_join("clip.wav"),good_a)
	mods.rescan()
	candidate = rebuild()
	check("late read repair clean",true,candidate.ok)
	var old_export: String = zip_entries["a-exports.json"]
	zip_entries["a-exports.json"] = JSON.stringify(Fixture.envelope("exports","add",[Fixture.export_entry("clip","clip.wav","pcm-wav-v1","audio"),Fixture.export_entry("clip","clip.wav","pcm-wav-v1","audio")]))
	zip_bytes(zip_path,zip_entries)
	mods.rescan()
	check("duplicate provider export rejected",false,rebuild().ok)
	zip_entries["a-exports.json"] = old_export
	var old_target: String = zip_entries["content.json"]
	zip_entries["content.json"] = JSON.stringify(Fixture.envelope("targets","patch",[Fixture.target("sound.3","media.b","missing","audio")]))
	zip_bytes(zip_path,zip_entries)
	mods.rescan()
	candidate = rebuild()
	check("unmet exact required export rejected",false,candidate.ok)
	check("required export failure context",true,candidate.issues[-1].reason.contains("media.b"))
	zip_entries["content.json"] = JSON.stringify(Fixture.envelope("targets","patch",[Fixture.target("sound.3","media.b","clip","image")]))
	zip_bytes(zip_path,zip_entries)
	mods.rescan()
	check("unsupported target type rejected",false,rebuild().ok)
	zip_entries["content.json"] = old_target
	zip_bytes(zip_path,zip_entries)
	mods.rescan()
	candidate = rebuild()
	check("all rejected edits leave clean retry",true,candidate.ok)
	var profile_key: String = media.resolve("sound.3","audio",candidate.ticket).request_key
	check("profile duplication admitted",true,mods.manage("duplicate","Media alternate").ok)
	controller.settings.effective["startup/show_setup"] = false
	preload("res://scripts/mod/content_diagnostics.gd").inspect(controller)
	check("diagnostics never enters clean-profile menu",false,controller.menu_entered)
	controller.settings.effective["startup/show_setup"] = true
	mods.edit("media.b","toggle")
	candidate = rebuild()
	check("profile changes logical winner","media.a",media.resolve("sound.3","audio",candidate.ticket).target_record.winner.provider)
	check("profile changes cache identity",false,profile_key == media.resolve("sound.3","audio",candidate.ticket).request_key)
	mods.select_profile("default")
	candidate = rebuild()
	check("original profile draft retained","media.b",media.resolve("sound.3","audio",candidate.ticket).target_record.winner.provider)
	put_bytes(loose_root.path_join("media/corners.png"),PackedByteArray([0]))
	check("loose bytes retained until restart",true,rebuild().ok)
	for profile: String in ["midi-v1","sf2-v1","webm-v1","mp4-v1"]:
		check(profile+" backend unavailable","backend_unavailable",Codec.decode(PackedByteArray([1]),profile,"video").kind)
	check("wrong media type explicit","wrong_type",Codec.decode(FileAccess.get_file_as_bytes(Fixture.ROOT+"/corners.png.bytes"),"png-v1","audio").kind)
	check("truncated WAV rejected",false,Codec.wav(FileAccess.get_file_as_bytes(Fixture.ROOT+"/pcm-16-2-44100.wav.bytes").slice(0,30)).ok)
	check("truncated GLB rejected",false,Codec.decode(FileAccess.get_file_as_bytes(Fixture.ROOT+"/triangle.glb.bytes").slice(0,80),"static-glb-v1","model").ok)
	check("truncated Ogg rejected",false,Codec.vorbis(FileAccess.get_file_as_bytes(Fixture.ROOT+"/tone.ogg.bytes").slice(0,80)).ok)
	check("truncated PNG rejected",false,Codec.png(FileAccess.get_file_as_bytes(Fixture.ROOT+"/corners.png.bytes").slice(0,40)).ok)
	var unlit_profile := changed_glb(func(doc: Dictionary):
		doc.extensionsRequired = ["KHR_materials_unlit"]
		doc.extensionsUsed = ["KHR_materials_unlit"]
		doc.materials[0].extensions = {"KHR_materials_unlit":{}})
	check("GLB required extension unsupported","unsupported",Codec.decode(unlit_profile,"static-glb-v1","model").kind)
	check("GLB external dependency unsupported","unsupported",Codec.decode(changed_glb(func(doc: Dictionary): doc.buffers[0].uri = "external.bin"),"static-glb-v1","model").kind)
	var matrix_profile := changed_glb(func(doc: Dictionary):
		doc.nodes[0].erase("translation")
		doc.nodes[0].erase("scale")
		doc.nodes[0].matrix = [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1])
	check("GLB transform unsupported","unsupported",Codec.decode(matrix_profile,"static-glb-v1","model").kind)
	check("GLB accessor out of range","invalid",Codec.decode(changed_glb(func(doc: Dictionary): doc.accessors[0].byteOffset = 999999),"static-glb-v1","model").kind)
	check("GLB wrong field type","invalid",Codec.decode(changed_glb(func(doc: Dictionary): doc.nodes[0].children = "wrong"),"static-glb-v1","model").kind)
	var unsupported_wav := FileAccess.get_file_as_bytes(Fixture.ROOT+"/float.wav.bytes")
	check("WAV unsupported encoding","unsupported",Codec.wav(unsupported_wav).kind)
	check("PNG unsupported valid 16 bit","unsupported",Codec.png(FileAccess.get_file_as_bytes(Fixture.ROOT+"/gray16.png.bytes")).kind)
	var bad_alignment := FileAccess.get_file_as_bytes(Fixture.ROOT+"/pcm-16-2-44100.wav.bytes")
	bad_alignment.encode_u16(32,3)
	check("WAV bad alignment invalid","invalid",Codec.wav(bad_alignment).kind)
	var diagnostic := preload("res://scripts/mod/content_diagnostics.gd").inspect(controller)
	check("diagnostics current revision",mods.revision,diagnostic.revision)
	check("diagnostics actual ticket",data.projection().ticket,diagnostic.ticket)
	check("diagnostics actual winner","media.b",diagnostic.resources["media.assets:targets"].records["classic.sound.3"].winner.provider)
	observations.measurements = media.measurements.duplicate(true)
	observations.goldens = JSON.parse_string(FileAccess.get_file_as_string(Fixture.ROOT+"/goldens.json"))
	var hashes_match := true
	for file: String in observations.goldens.sha256:
		var hash := HashingContext.new()
		hash.start(HashingContext.HASH_SHA256)
		hash.update(FileAccess.get_file_as_bytes(Fixture.ROOT.path_join(file)))
		hashes_match = hashes_match and hash.finish().hex_encode() == observations.goldens.sha256[file]
	check("versioned golden byte hashes",true,hashes_match)
	if DisplayServer.get_name() != "headless":
		var viewport := SubViewport.new()
		viewport.size = Vector2i(320,240)
		viewport.own_world_3d = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		shell.add_child(viewport)
		var visual := Instances.model(model)
		viewport.add_child(visual.node)
		var camera := Camera3D.new()
		viewport.add_child(camera)
		camera.position = Vector3(2.5,3.5,8)
		camera.look_at(Vector3(2.5,3.5,4)) # Inspection-only camera, never WORLD/MOVE conversion.
		var light := DirectionalLight3D.new()
		viewport.add_child(light)
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var model_capture := viewport.get_texture().get_image()
		check("GLB visual consumer rendered",false,model_capture.is_empty())
		model_capture.save_png(sandbox.path_join("replacement-model.png"))
		viewport.queue_free()
		shell.render()
		check("diagnostics opened through setup",true,await click(shell,"Content Diagnostics"))
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var capture := shell.get_viewport().get_texture().get_image()
		check("diagnostics rendered",false,capture.is_empty())
		capture.save_png(sandbox.path_join("content-diagnostics.png"))
		for child in shell.get_children():
			if child is AcceptDialog: child.queue_free()
		var preview := TextureRect.new()
		preview.texture = ImageTexture.create_from_image(image.resource.image)
		preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		preview.custom_minimum_size = Vector2(256,256)
		preview.position = Vector2(400,100)
		shell.add_child(preview)
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		capture = shell.get_viewport().get_texture().get_image()
		check("replacement rendered",false,capture.is_empty())
		capture.save_png(sandbox.path_join("replacement-preview.png"))
		preview.queue_free()
	# Restore loose fixture on disk for fresh-process proof; original run used cached bytes.
	put_bytes(loose_root.path_join("media/corners.png"),FileAccess.get_file_as_bytes(Fixture.ROOT+"/palette.png.bytes"))
	check("unsaved choice required","unsaved_profile",controller.continue_to_menu().kind)
	var saved: Dictionary = mods.committed.duplicate(true)
	controller.storage.adapter.faults.mod_profiles_publish = true
	check("durable failure blocks entry",false,controller.continue_to_menu("save").ok)
	check("durable failure preserves history",saved,mods.committed)
	check("durable failure no publication",{},data.active())
	check("durable failure no lock",false,mods.locked)
	controller.storage.adapter.faults.clear()
	controller.providers.faults.menu = true
	check("interrupted menu entry rejects",false,controller.continue_to_menu("save").ok)
	check("interrupted entry publishes nothing",{},data.active())
	controller.providers.faults.clear()
	var reentrant: Array = []
	controller.providers.before_menu = func():
		reentrant.append(rebuild().get("kind"))
		reentrant.append(preload("res://scripts/mod/content_diagnostics.gd").inspect(controller).get("kind"))
	check("clean save entry",true,controller.continue_to_menu("save").ok)
	check("reserved media rebuild rejected",["busy","busy"],reentrant)
	controller.providers.before_menu = Callable()
	check("actual main menu","main_menu",controller.route)
	check("committed media usable",true,media.resolve("sound.3","audio").ok)
	check("configuration locked",true,mods.locked)
	check("post-menu edit rejected",false,mods.edit("media.b","toggle").ok)
	check("post-menu rebuild rejected","locked",rebuild().kind)
	check("retained committed media survives rejected rebuild",true,media.resolve("sound.3","audio").ok)
	check("post-menu diagnostics rejected",false,preload("res://scripts/mod/content_diagnostics.gd").inspect(controller).ok)
	check("saved successful profile","default",mods.committed.last_successful)
	var ok := true
	for item: Dictionary in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"count":checks.size(),"checks":checks,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs,"observations":observations}
