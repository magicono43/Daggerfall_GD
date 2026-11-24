extends "res://tests/replacement_cases.gd"
const Native = preload("res://scripts/data/native_media.gd")
const NativeFixture = preload("res://tests/native_fixture.gd")
var outcomes: Array = []
var active_scopes := {}
class CurrentOwner extends Node:
	func current(_scope: Dictionary) -> bool:
		return is_inside_tree()

func check(id: String, expected: Variant, actual: Variant) -> void:
	print("NATIVE: ",id)
	if typeof(expected)!=typeof(actual) or (typeof(expected)==typeof(actual) and expected!=actual): print("NATIVE VALUE: ",str(expected)," / ",str(actual))
	super.check(id,expected,actual)

func current(scope: Dictionary) -> bool:
	return active_scopes.has(scope.attempt) and active_scopes[scope.attempt]==scope

func scope(id: String) -> Dictionary:
	var value := {"attempt":id,"session":"","operation":"native-operation-"+id}
	active_scopes[id] = value
	return value

func energy(bytes: PackedByteArray) -> float:
	var total := 0.0
	for sample: float in bytes.to_float32_array(): total += absf(sample)
	return total

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	controller = shell.controller
	mods = controller.mods
	data = controller.providers.definitions
	media = controller.providers.media
	controller.settings.apply({"startup/show_setup":true})
	controller.settings.effective["startup/show_setup"] = true
	var loose_root: String = mods.root.path_join("Overrides")
	put_bytes(loose_root.path_join("media/score.mid"),NativeFixture.smf(0))
	write(loose_root.path_join("native-exports.json"),JSON.stringify(Fixture.envelope("exports","add",[Fixture.export_entry("loose-native-midi","MeDiA/ScOrE.MiD","midi-v1","midi")])))
	controller.select_folder(fixture.classic_source)
	check("native editable setup","optional_setup",controller.route)
	var caps := Native.capabilities()
	observations.capabilities = caps
	observations.memory_before = Native.adapter().invoke("memory")
	check("FluidSynth actual capability",true,caps.get("midi",false))
	check("FFmpeg actual capability",true,caps.get("video",false))
	check("FluidSynth pinned version","2.4.7",caps.get("fluid_version",""))
	check("FFmpeg dynamic LGPL",true,str(caps.get("ffmpeg_license","")).begins_with("LGPL"))
	check("FFmpeg excludes GPL/nonfree",false,str(caps.get("ffmpeg_configuration","")).contains("--enable-gpl") or str(caps.get("ffmpeg_configuration","")).contains("--enable-nonfree"))
	for type in [0,1]:
		var decoded := Native.midi(NativeFixture.smf(type))
		check("SMF type%d validated"%type,true,decoded.ok)
		check("SMF type%d rational end sample"%type,72000,decoded.get("sample_frames",-1))
		var notes: Array = []
		for event: Dictionary in decoded.get("events",[]):
			if event.status==144: notes.append([int(event.data[0]),event.sample])
		check("SMF type%d note sample positions"%type,[[60,0],[67,0],[64,24000]],notes)
	var wrong := NativeFixture.smf()
	wrong[9] = 2
	check("SMF type2 explicitly unsupported","unsupported",Native.midi(wrong).kind)
	wrong = NativeFixture.smf()
	wrong[12] = 128
	check("SMF SMPTE explicitly unsupported","unsupported",Native.midi(wrong).kind)
	check("SMF wrong bytes","wrong_type",Native.midi(PackedByteArray([1,2])).kind)
	check("SMF truncated track",false,Native.midi(NativeFixture.smf().slice(0,-1)).ok)
	var bank := Native.default_bank()
	check("real default bank validates",true,bank.ok)
	check("real default bank digest",Native.BANK_HASH,bank.get("sha256",""))
	var all_programs := true
	for program in 128: all_programs = all_programs and str(bank.get("presets","")).contains("0:%d,"%program)
	check("default covers all GM melodic programs",true,all_programs)
	check("default covers GM percussion",true,str(bank.get("presets","")).contains("128:0,"))
	var alternate := Native.bank(NativeFixture.bank())
	check("alternate project bank actual synthesis admission",true,alternate.ok)
	check("alternate bank distinct identity",true,alternate.get("sha256")==Native.digest(NativeFixture.bank()) and alternate.get("sha256")!=Native.BANK_HASH)
	check("malformed SF2 rejected",false,Native.bank(NativeFixture.bank().slice(0,-2)).ok)
	check("wrong SF2 type rejected","wrong_type",Native.bank(NativeFixture.smf()).kind)
	var synth := Native.adapter()
	check("real SMF sequencer starts",true,synth.invoke("midi",NativeFixture.smf(),bank.bytes,0).ok)
	var first: Dictionary = synth.invoke("render",24000)
	var second: Dictionary = synth.invoke("render",24000)
	check("sample clock starts at zero",0,first.get("first_sample",-1))
	check("sample clock continues exactly",[24000,48000],[second.get("first_sample",-1),second.get("sample_cursor",-1)])
	check("real synthesis nonzero",true,energy(first.get("pcm",PackedByteArray()))>1)
	check("tempo change tick position",true,abs(int(second.get("tick",-10000))-720)<=4)
	var event_bytes: PackedByteArray = first.get("note_events",PackedByteArray())
	event_bytes.append_array(second.get("note_events",PackedByteArray()))
	var native_notes: Array = []
	for offset in range(0,event_bytes.size(),24):
		if event_bytes.decode_s32(offset+8)==144 and event_bytes.decode_s32(offset+20)>0:
			native_notes.append([event_bytes.decode_s32(offset+16),event_bytes.decode_u64(offset)])
	observations.native_note_samples = native_notes
	check("native sample callback three note events",3,native_notes.size())
	var event_timing := native_notes.size()==3
	if event_timing:
		for index in 3:
			event_timing = event_timing and native_notes[index][0]==[60,67,64][index] and absi(native_notes[index][1]-[0,0,24000][index])<=int(first.get("sample_block",0))
	check("native sample callback timing within synth block",true,event_timing)
	var independent := Native.adapter()
	check("independent synth starts",true,independent.invoke("midi",NativeFixture.smf(0),alternate.bytes,1).ok)
	check("independent cursor",1024,independent.invoke("render",1024).get("sample_cursor",-1))
	check("first cursor unaffected",48001,synth.invoke("render",1).get("sample_cursor",-1))
	synth.invoke("close")
	check("retired synth rejects rendering",false,synth.invoke("render",1).ok)
	var retained_cursor: int = independent.invoke("render",1024).get("sample_cursor",-1)
	var loop_note_samples: Array = []
	for unused in 2:
		var rendered: Dictionary = independent.invoke("render",48000)
		var trace: PackedByteArray = rendered.get("note_events",PackedByteArray())
		for offset in range(0,trace.size(),24):
			if trace.decode_s32(offset+8)==144 and trace.decode_s32(offset+16)==60 and trace.decode_s32(offset+20)>0:
				loop_note_samples.append(trace.decode_u64(offset))
	observations.native_loop_note_samples = loop_note_samples
	var loop_timed := loop_note_samples.size()==1 and absi(int(loop_note_samples[0])-72000)<=64
	check("second survives first retirement",[2048,true],[retained_cursor,loop_timed])
	independent.invoke("close")
	var stock: Dictionary = controller.providers.classic.decode_sequence("D1.HMI")
	check("real stock HMI conversion",true,stock.ok)
	var stock_bytes: PackedByteArray = stock.value.projection().smf if stock.ok else PackedByteArray()
	check("stock converted SMF admitted",true,Native.midi(stock_bytes).ok)
	check("stock default-bank sequencer starts",true,synth.invoke("midi",stock_bytes,bank.bytes,0).ok)
	var stock_pcm: Dictionary = synth.invoke("render",48000)
	check("stock default-bank synthesis audible samples",true,energy(stock_pcm.get("pcm",PackedByteArray()))>1)
	var listening_pcm: PackedByteArray = stock_pcm.get("pcm",PackedByteArray())
	for unused in 4: listening_pcm.append_array(synth.invoke("render",48000).get("pcm",PackedByteArray()))
	write_wave(sandbox.path_join("stock-d1-default.wav"),listening_pcm)
	synth.invoke("close")
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NativeFixture.ROOT+"/fixtures.json"))
	for clip: Dictionary in manifest.clips:
		var bytes := FileAccess.get_file_as_bytes(NativeFixture.ROOT+"/"+clip.file)
		check(clip.id+" fixture identity",clip.sha256,Native.digest(bytes))
		var decoded := Native.video(bytes,clip.profile)
		check(clip.id+" actual full decode",true,decoded.ok)
		check(clip.id+" declared codecs",[clip.video,clip.audio],[decoded.get("video_codec"),decoded.get("audio_codec")])
		check(clip.id+" exact 300 source frames",300,decoded.get("decoded_video",-1))
		check(clip.id+" authored aspect",true,absf(float(decoded.get("aspect",0))-4.0/3.0)<0.000001)
		check(clip.id+" declared colors",clip.get("color","bt709-limited"),decoded.get("color",""))
		await decode_packets(shell,clip,bytes)
	for clip: Dictionary in manifest.get("unsupported",[]):
		var bytes := FileAccess.get_file_as_bytes(NativeFixture.ROOT+"/"+clip.file)
		check(clip.id+" valid unsupported fixture identity",clip.sha256,Native.digest(bytes))
		check(clip.id+" explicitly unsupported","unsupported",Native.video(bytes,clip.profile).kind)
	check("video wrong type rejected","wrong_type",Native.video(NativeFixture.smf(),"mp4-v1").kind)
	var valid := FileAccess.get_file_as_bytes(NativeFixture.ROOT+"/vp8-none.bytes")
	check("truncated video fails",false,Native.video(valid.slice(0,valid.size()/2),"webm-v1").ok)
	await concurrent_workers(shell,valid)
	var candidate := rebuild()
	check("native shipped exports pre-menu valid",true,candidate.ok)
	observations.preparation = media.measurements.duplicate(true)
	check("native preview not committed","before_readiness",media.resolve("asset.native.song","midi").kind)
	check("native exact preview export",true,media.export_resource("@shipped/media-assets","native-midi","midi",candidate.ticket).ok)
	check("native mixed-case loose source admitted",0,media.export_resource("@loose","loose-native-midi","midi",candidate.ticket).resource.smf_type)
	put_bytes(loose_root.path_join("media/score.mid"),NativeFixture.smf(1))
	candidate = rebuild()
	check("native loose edits remain restart-only",0,media.export_resource("@loose","loose-native-midi","midi",candidate.ticket).resource.smf_type)
	await source_recovery_cases(shell)
	candidate = rebuild()
	check("native wrong provider isolation","missing_provider",media.export_resource("other.bank","native-bank","bank",candidate.ticket).kind)
	controller.storage.adapter.faults.mod_profiles_publish = true
	check("native durable failure blocks publication",false,controller.continue_to_menu("save").ok)
	check("native failed candidate retains unlocked plan",false,mods.locked)
	controller.storage.adapter.faults.clear()
	check("native real menu commitment",true,controller.continue_to_menu("save").ok)
	shell.render()
	check("native actual menu lock",true,mods.locked)
	check("native committed MIDI resolves",true,media.resolve("asset.native.song","midi").ok)
	var locked_preparation := [data.timings.prepare_serial,controller.providers.formulas._serial]
	check("native post-menu rebuild rejects","locked",rebuild().kind)
	check("native locked rebuild never prepares",locked_preparation,[data.timings.prepare_serial,controller.providers.formulas._serial])
	var preferences: RefCounted = controller.providers.media_preferences
	var music: Node = shell.session_shell.music_playback
	var music_events: Array = []
	music.boundary.connect(func(event: Dictionary): music_events.append(event))
	var stock_track: Dictionary = music.request("song.d1","midi",scope("stock-midi"))
	check("production classic HMI consumer request",true,stock_track.ok)
	await shell.get_tree().create_timer(0.2).timeout
	check("production classic synth feeds game audio",true,music.projection().get(stock_track.get("id",""),{}).get("submitted",0)>0)
	if stock_track.ok: music.retire(stock_track.id)
	var first_track: Dictionary = music.request("asset.native.song","midi",scope("first-midi"),true)
	check("production MIDI request prepared",true,first_track.ok)
	check("production captured default bank",Native.BANK_HASH,first_track.get("bank",{}).get("sha256",""))
	music.handoff(first_track.get("id",""),0)
	await shell.get_tree().create_timer(1.7).timeout
	var loop_events: Array = music_events.filter(func(event: Dictionary): return event.get("id")==first_track.get("id") and event.kind=="LoopBoundary")
	check("eligible MIDI loop boundary emitted",true,not loop_events.is_empty())
	var unique := {}
	for event: Dictionary in loop_events: unique[event.sequence] = true
	check("eligible loop boundaries unique",loop_events.size(),unique.size())
	check("application bank preference accepted",true,preferences.select_bank("@shipped/media-assets","native-bank").ok)
	var next_track: Dictionary = music.request("asset.native.song","midi",scope("next-midi"))
	check("next request captures alternate bank",Native.digest(NativeFixture.bank()),next_track.get("bank",{}).get("sha256",""))
	check("existing request keeps default bank",Native.BANK_HASH,music.projection().get(first_track.get("id",""),{}).get("bank",{}).get("sha256",""))
	check("same backend handoff",true,music.handoff(next_track.get("id",""),0.1).ok)
	await shell.get_tree().create_timer(0.04).timeout
	var audible: float = music.projection().get(next_track.get("id",""),{}).get("gain",-1.0)
	check("interrupted fade can retarget",true,music.handoff(next_track.get("id",""),0.1).ok)
	var paused_cursor: int = music.projection().get(next_track.get("id",""),{}).get("submitted",-1)
	music.set_music_gain(0.5)
	music.pause(next_track.get("id",""),true)
	await shell.get_tree().create_timer(0.06).timeout
	var paused: Dictionary = music.projection().get(next_track.get("id",""),{})
	var actual_db: float = music._instances[next_track.id].player.volume_db
	check("retarget retains current audible gain",[audible,paused_cursor,true,true],[paused.get("gain",-2.0),paused.get("submitted",-2),paused.get("paused",false),absf(actual_db-linear_to_db(audible*0.5))<0.001])
	music.pause(next_track.get("id",""),false)
	music.set_music_gain(1.0)
	await shell.get_tree().create_timer(0.2).timeout
	check("outgoing instance retired after fade",false,music.projection().has(first_track.get("id","")))
	Native.force_unavailable = true
	var recorded: Dictionary = music.request("asset.native.recording","audio",scope("recording"))
	check("recording independent of unavailable synthesis",true,recorded.ok)
	var rejected: Dictionary = music.request("asset.native.song","midi",scope("unavailable-midi"))
	check("missing synthesis produces classified failure",false,rejected.ok)
	check("failed incoming preserves outgoing",true,music.projection().has(next_track.get("id","")))
	Native.force_unavailable = false
	check("cross backend handoff",true,music.handoff(recorded.get("id",""),0).ok)
	check("MIDI outgoing retired after cross handoff",false,music.projection().has(next_track.get("id","")))
	for id: String in music.projection(): music.retire(id)
	var natural: Dictionary = music.request("asset.native.song","midi",scope("natural-midi"))
	check("finite MIDI request prepared",true,natural.ok)
	check("live MIDI gain applies",true,music.gain(natural.get("id",""),0.25))
	var natural_deadline := Time.get_ticks_msec()+8000
	while music.projection().has(natural.get("id","")) and Time.get_ticks_msec()<natural_deadline: await shell.get_tree().process_frame
	check("finite MIDI naturally retires",false,music.projection().has(natural.get("id","")))
	await music.settle()
	var finite_events: Array = music_events.filter(func(event: Dictionary): return event.get("id")==natural.get("id") and event.kind=="Finished")
	check("finite MIDI natural boundary exactly once",1,finite_events.size())
	var ends_before := music_events.size()
	music._natural_end(natural.get("id",""))
	check("stale MIDI end cannot choose another track",ends_before,music_events.size())
	if music.projection().has(natural.get("id","")): music.retire(natural.id)
	check("bank preference persists for fresh process",true,controller.settings.save_accepted().ok)
	var missing_reference := JSON.stringify({"provider":"absent.optional","key":"bank"})
	check("missing optional preference saved",true,controller.settings.apply({preferences.SETTING:missing_reference},func(_values: Dictionary): return true).ok)
	var fallback: Dictionary = preferences.capture()
	check("missing optional bank uses validated default",Native.BANK_HASH,fallback.get("identity",{}).get("sha256",""))
	check("missing optional bank reports issue",true,not str(fallback.get("preference_issue","")).is_empty())
	preferences.select_bank("@shipped/media-assets","native-bank")
	var video: Control = shell.session_shell.video_playback
	video.terminal.connect(func(result: Dictionary): outcomes.append(result))
	for clip: Dictionary in manifest.clips:
		await present_clip(shell,video,clip)
	var cancelled_scope := scope("cancel-preparing")
	check("prepare cancellable request",true,video.request("asset.native.vp8-none",cancelled_scope,current).ok)
	check("cancel during preparation",true,video.cancel(cancelled_scope))
	check("duplicate cancellation rejected",false,video.cancel(cancelled_scope))
	check("cancel preparation terminal once","Cancelled",outcomes.back().kind)
	var stalled_scope := scope("preparation-deadline")
	var before_deadline := outcomes.size()
	video.request("asset.native.vp8-none",stalled_scope,current)
	# Controlled monotonic-time failure: the real decoder still owns the attempt
	# and must be cancelled/joined before publishing its deadline result.
	video._attempt.preparation_started_msec = Time.get_ticks_msec()-video.PROGRESS_BUDGET_MSEC-1
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	check("preparation deadline terminal exactly once",before_deadline+1,outcomes.size())
	check("preparation deadline fails and joins",["Failed",true,0],[outcomes.back().kind,str(outcomes.back().reason).contains("5000 ms"),Native.adapter().invoke("workers").active])
	var skip_scope := scope("skip")
	video.request("asset.native.vp8-none",skip_scope,current)
	var press := InputEventKey.new()
	press.keycode = KEY_SPACE
	press.physical_keycode = KEY_SPACE
	press.pressed = true
	press.echo = true
	var before := outcomes.size()
	video._input(press)
	check("repeat key cannot skip",before,outcomes.size())
	press.echo = false
	press.pressed = false
	video._input(press)
	press.pressed = true
	video._input(press)
	check("fresh key skips","Skipped",outcomes.back().kind)
	check("skip cleanup releases owned window",false,shell.session_shell.windows.top().get("window")=="cinematic")
	var stale_scope := scope("stale")
	video.request("asset.native.vp9-none",stale_scope,current)
	active_scopes.erase(stale_scope.attempt)
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var obsolete_kind: String = outcomes.back().kind
	var owner := CurrentOwner.new()
	shell.add_child(owner)
	video.request("asset.native.vp8-none",scope("freed-requester"),owner.current)
	owner.free()
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	check("obsolete operation cancels",["Cancelled","Cancelled",0],[obsolete_kind,outcomes.back().kind,Native.adapter().invoke("workers").active])
	await input_and_owner_cases(shell,video)
	var failed_scope := scope("decode-failure")
	before = outcomes.size()
	check("malformed worker attempt admitted for negative check",true,video.admit({"bytes":valid.slice(0,valid.size()/2),"profile":"webm-v1"},failed_scope,current).ok)
	var failure_deadline := Time.get_ticks_msec()+8000
	while outcomes.size()==before and Time.get_ticks_msec()<failure_deadline: await shell.get_tree().process_frame
	check("mid-decode failure terminal once",before+1,outcomes.size())
	check("mid-decode classified failure","Failed",outcomes.back().kind if outcomes.size()>before else "timeout")
	if outcomes.size()==before: video.cancel(failed_scope)
	check("failed worker joined before terminal",0,Native.adapter().invoke("workers").active)
	var classic_scope := scope("classic-vid")
	# The bounded fixture explicitly requests the uncorrected source pixel aspect.
	# Caller-level aspect correction remains separately identified in observations.
	var classic_started: Dictionary = video.request_classic(controller.providers.classic,"ANIM0011.VID",classic_scope,current,1.6)
	check("real classic VID playback starts",true,classic_started.ok)
	var deadline := Time.get_ticks_msec()+60000
	before = outcomes.size()
	var classic_capture := DisplayServer.get_name()=="headless"
	while outcomes.size()==before and Time.get_ticks_msec()<deadline:
		await shell.get_tree().process_frame
		if not classic_capture and video._rect.texture!=null and Time.get_ticks_msec()>=deadline-58000:
			await RenderingServer.frame_post_draw
			classic_capture = shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join("classic-vid-presented.png"))==OK
	var classic_aspect: float = video._rect.size.x/video._rect.size.y
	observations.classic_display_aspect = classic_aspect
	check("real classic VID finite finish",true,outcomes.size()>before and outcomes.back().kind=="Finished" and classic_capture and absf(classic_aspect-1.6)<0.001)
	var lifecycle: RefCounted = shell.session_shell.core
	lifecycle.provider = preload("res://tests/controlled_session_provider.gd").new()
	check("controlled owner uses real CORE admission","Succeeded",lifecycle.request({"id":"native-session-a","mode":"new","origin":"","selection":{"stable_id":"native-fixture","revision":1}}).kind)
	var session_scope := scope("session-video")
	session_scope.session = lifecycle.snapshot().session
	active_scopes[session_scope.attempt] = session_scope
	check("session-scoped video starts",true,video.request("asset.native.vp8-none",session_scope,current).ok)
	await shell.get_tree().create_timer(0.1).timeout
	before = outcomes.size()
	var old_session: String = lifecycle.snapshot().session
	check("real CORE replacement awaits discard consent","pending",lifecycle.request({"id":"native-session-b","mode":"new","origin":old_session,"selection":{"stable_id":"native-fixture-b","revision":1}}).kind)
	check("real CORE replacement consent",true,lifecycle.confirm(lifecycle.ticket(),true))
	check("real CORE replacement commits",true,lifecycle.snapshot().ready and lifecycle.snapshot().session!=old_session)
	check("retirement releases worker before new readiness",0,Native.adapter().invoke("workers").active)
	check("retired session video terminal once",before+1,outcomes.size())
	check("retired session video cancelled","Cancelled",outcomes.back().kind)
	# Real CORE consumes an actual unavailable native presentation result. The
	# controlled CHAR/provider authority keeps the later real-owner gate open.
	var death_confirmed: bool = lifecycle.confirm_death(lifecycle.snapshot().session,lifecycle.provider)
	lifecycle.provider.hold_video = true
	var death_request: Dictionary = lifecycle.request({"id":"native-death","mode":"death","origin":lifecycle.snapshot().session,"selection":{}})
	var presentation_ticket: Dictionary = lifecycle.ticket()
	Native.force_unavailable = true
	var death_failure: Dictionary = video.request("asset.native.vp8-none",scope("death-unavailable"),current,"any","death")
	Native.force_unavailable = false
	lifecycle.provider.menu_ok = false
	var presentation_settled: bool = lifecycle.complete_presentation(presentation_ticket,death_failure)
	var recovery_application: String = lifecycle.snapshot().application
	var presentation_count: int = lifecycle.provider.videos
	lifecycle.provider.menu_ok = true
	var menu_retried: bool = lifecycle.recover_menu()
	observations.death_presentation_failure = death_failure.get("kind","")
	observations.video = video.measurements.duplicate(true)
	observations.music = music.measurements.duplicate(true)
	observations.memory_after = Native.adapter().invoke("memory")
	observations.default_bank = {"sha256":bank.get("sha256"),"presets":bank.get("presets")}
	check("all music instances released",{},music.projection())
	check("no cinematic input hold remains",[false,true,"pending","unavailable",true,"recovery",true,"menu",true],[shell.session_shell.windows.top().get("window")=="cinematic",death_confirmed,death_request.kind,death_failure.get("kind",""),presentation_settled,recovery_application,menu_retried,lifecycle.snapshot().application,presentation_count==lifecycle.provider.videos])
	check("native decoder workers all joined",0,Native.adapter().invoke("workers").active)
	var ok := true
	for item: Dictionary in checks:
		var numeric: bool = typeof(item.expected) in [TYPE_INT,TYPE_FLOAT] and typeof(item.actual) in [TYPE_INT,TYPE_FLOAT]
		ok = ok and ((numeric or typeof(item.expected)==typeof(item.actual)) and item.expected==item.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs,"observations":observations}

func source_recovery_cases(shell: Control) -> void:
	var root := pack("NativeFolder","native.folder",[Fixture.target("asset.native.song","native.folder","score","midi")])
	var metadata := manifest("native.folder")
	metadata.content = ["a-exports.json","b-required.json","content.json"]
	metadata.capabilities = ["data.media-v1"]
	write(root.path_join("mod.json"),JSON.stringify(metadata))
	write(root.path_join("b-required.json"),JSON.stringify(Fixture.envelope("targets","add",[Fixture.target("asset.native.required","native.folder","score","midi")])))
	write(root.path_join("a-exports.json"),JSON.stringify(Fixture.envelope("exports","add",[Fixture.export_entry("score","score.mid","midi-v1","midi"),Fixture.export_entry("bank","bank.sf2","sf2-v1","bank")])))
	put_bytes(root.path_join("score.mid"),NativeFixture.smf(1))
	put_bytes(root.path_join("bank.sf2"),NativeFixture.bank())
	var zip_path: String = mods.root.path_join("Mods/NativeZip.zip")
	var zip_manifest := manifest("native.zip")
	zip_manifest.content = ["a-exports.json","content.json"]
	zip_manifest.capabilities = ["data.media-v1"]
	var entries := {"mod.json":JSON.stringify(zip_manifest),"a-exports.json":JSON.stringify(Fixture.envelope("exports","add",[Fixture.export_entry("score","score.mid","midi-v1","midi")])),"content.json":JSON.stringify(Fixture.envelope("targets","patch",[Fixture.target("asset.native.song","native.zip","score","midi")])),"score.mid":NativeFixture.smf(0)}
	zip_bytes(zip_path,entries)
	mods.rescan()
	mods.edit("native.folder","toggle")
	mods.edit("native.zip","toggle")
	var candidate := rebuild()
	check("native folder and ZIP real byte admission",true,candidate.ok)
	if not candidate.ok:
		print("NATIVE SOURCE ISSUES: ",JSON.stringify(candidate.get("issues",[]))," ",candidate.get("reason",""))
		return
	check("native later ZIP target winner","native.zip",media.resolve("asset.native.song","midi",candidate.ticket).target_record.winner.provider)
	check("native folder direct provider isolated",1,media.export_resource("native.folder","score","midi",candidate.ticket).resource.smf_type)
	var retained: Dictionary = media.resolve("asset.native.song","midi",candidate.ticket)
	mods.edit("native.zip","up")
	candidate = rebuild()
	check("native reorder rebuild valid",true,candidate.ok)
	check("native reorder changes winner","native.folder",media.resolve("asset.native.song","midi",candidate.ticket).target_record.winner.provider)
	check("native generation cache changed",false,retained.request_key==media.resolve("asset.native.song","midi",candidate.ticket).request_key)
	check("native retained resource survives rebuild",0,retained.resource.smf_type)
	mods.edit("native.zip","down")
	put_bytes(root.path_join("score.mid"),PackedByteArray([1,2,3]))
	candidate = rebuild()
	check("native ordinary plan edit keeps package snapshot",true,candidate.ok)
	mods.rescan()
	candidate = rebuild()
	check("native hidden invalid earlier contribution rejects",false,candidate.ok)
	check("native invalid contribution source context",true,candidate.issues[0].reason.contains("native.folder/score"))
	check("native invalid selection cannot fall through","before_readiness",media.resolve("asset.native.song","midi",candidate.ticket).kind)
	check("native stale omission rejected",false,data.omit(candidate.issues[0].token,candidate.ticket-1,mods).ok)
	check("native current omission accepted",true,data.omit(candidate.issues[0].token,candidate.ticket,mods).ok)
	candidate = rebuild()
	check("native omission rechecks remaining required export",false,candidate.ok)
	check("native dependent contribution explicit omission",true,data.omit(candidate.issues[-1].token,candidate.ticket,mods).ok)
	candidate = rebuild()
	check("native omission clean remainder valid",true,candidate.ok)
	put_bytes(root.path_join("score.mid"),NativeFixture.smf(1))
	mods.rescan()
	candidate = rebuild()
	check("native repaired source explicitly rescanned",true,candidate.ok)
	put_bytes(root.path_join("bank.sf2"),NativeFixture.bank().slice(0,-2))
	mods.rescan()
	candidate = rebuild()
	check("native malformed selected bank uses content recovery",false,candidate.ok)
	check("native malformed bank attributable",true,candidate.issues[0].reason.contains("native.folder/bank"))
	put_bytes(root.path_join("bank.sf2"),NativeFixture.bank())
	mods.rescan()
	candidate = rebuild()
	check("native bank repair clean retry",true,candidate.ok)
	controller.settings.effective["startup/show_setup"] = false
	var diagnostic := preload("res://scripts/mod/content_diagnostics.gd").inspect(controller)
	check("native diagnostics current candidate",true,diagnostic.ok and diagnostic.valid)
	check("native diagnostics do not auto-enter menu",false,controller.menu_entered)
	controller.settings.effective["startup/show_setup"] = true
	var reserved: Array = []
	controller.providers.before_menu = func(): reserved.append(preload("res://scripts/mod/content_diagnostics.gd").inspect(controller).get("kind"))
	controller.providers.faults.menu = true
	check("native fallible menu preparation rejects",false,controller.continue_to_menu("save").ok)
	check("native reserved diagnostics cannot replace candidate",["busy"],reserved)
	controller.providers.faults.clear()
	controller.providers.before_menu = Callable()

func input_and_owner_cases(shell: Control, video: Control) -> void:
	for device: String in ["mouse","controller"]:
		var attempt := scope("fresh-"+device)
		video.request("asset.native.vp8-none",attempt,current)
		var event: InputEvent = InputEventMouseButton.new() if device=="mouse" else InputEventJoypadButton.new()
		event.button_index = MOUSE_BUTTON_LEFT if device=="mouse" else JOY_BUTTON_A
		event.pressed = true
		Input.parse_input_event(event.duplicate())
		await shell.get_tree().process_frame
		check("fresh "+device+" digital skip","Skipped",outcomes.back().kind)
		event.pressed = false
		Input.parse_input_event(event.duplicate())
	var press := InputEventKey.new()
	press.keycode = KEY_SPACE
	press.physical_keycode = KEY_SPACE
	press.pressed = true
	Input.parse_input_event(press.duplicate())
	await shell.get_tree().process_frame
	var held_scope := scope("held-activation")
	video.request("asset.native.vp8-none",held_scope,current)
	var before := outcomes.size()
	Input.parse_input_event(press.duplicate())
	var motion := InputEventJoypadMotion.new()
	motion.axis = JOY_AXIS_LEFT_X
	motion.axis_value = 0.8
	Input.parse_input_event(motion.duplicate())
	Input.parse_input_event(InputEventMouseMotion.new())
	await shell.get_tree().process_frame
	check("held activation and analog motion do not skip",before,outcomes.size())
	press.pressed = false
	Input.parse_input_event(press.duplicate())
	press.pressed = true
	Input.parse_input_event(press.duplicate())
	await shell.get_tree().process_frame
	check("released then fresh activation skips","Skipped",outcomes.back().kind)
	press.pressed = false
	Input.parse_input_event(press.duplicate())
	var preferences: RefCounted = controller.providers.media_preferences
	controller.settings.apply({preferences.SKIP_SETTING:"back"},func(_values: Dictionary): return true)
	var back_scope := scope("dedicated-back")
	video.request("asset.native.vp8-none",back_scope,current)
	before = outcomes.size()
	press.pressed = true
	Input.parse_input_event(press.duplicate())
	await shell.get_tree().process_frame
	check("dedicated Back ignores unrelated key",before,outcomes.size())
	press.pressed = false
	Input.parse_input_event(press.duplicate())
	var back := InputEventKey.new()
	back.keycode = KEY_ESCAPE
	back.physical_keycode = KEY_ESCAPE
	back.pressed = true
	Input.parse_input_event(back.duplicate())
	await shell.get_tree().process_frame
	check("dedicated Back fresh skip","Skipped",outcomes.back().kind)
	check("skip activation consumed before underlying menu",false,shell.session_shell.windows.top().get("window")=="pause")
	back.pressed = false
	Input.parse_input_event(back.duplicate())
	var mandatory := scope("startup-rule")
	video.request("asset.native.vp8-none",mandatory,current,"none","startup")
	press.pressed = true
	Input.parse_input_event(press.duplicate())
	await shell.get_tree().process_frame
	var startup_kind: String = outcomes.back().kind
	press.pressed = false
	Input.parse_input_event(press.duplicate())
	var before_absence := outcomes.size()
	var absent: Dictionary = video.request("asset.native.optional_startup",scope("startup-absent"),current,"any","startup")
	var absence_safe: bool = absent.get("kind")=="missing" and outcomes.size()==before_absence and shell.session_shell.windows.top().get("window")!="cinematic"
	video.request("asset.native.vp8-none",scope("death-rule"),current,"none","death")
	press.pressed = true
	Input.parse_input_event(press.duplicate())
	await shell.get_tree().process_frame
	check("startup owner any-button rule overrides preference",["Skipped","Skipped",true],[startup_kind,outcomes.back().kind,absence_safe])
	press.pressed = false
	Input.parse_input_event(press.duplicate())
	controller.settings.apply({preferences.SKIP_SETTING:"authored"},func(_values: Dictionary): return true)
	var ambience: RefCounted = shell.session_shell.ambience_requests
	var other: int = ambience.acquire("other-audio-owner","",0.5)
	var covered := scope("external-window")
	video.request("asset.native.vp8-none",covered,current)
	check("cinematic default suppresses ambience",0.0,ambience.effective(""))
	var independent: Dictionary = shell.session_shell.windows.open("message","",{"text":"Independent owner"})
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	check("external replacement classified cancellation","Cancelled",outcomes.back().kind)
	check("newer independent window retained",independent.id,shell.session_shell.windows.top().get("id"))
	check("other ambience request retained",0.5,ambience.effective(""))
	shell.session_shell.windows.close(independent.id)
	ambience.release(other,"other-audio-owner")

func write_wave(path: String, pcm: PackedByteArray) -> void:
	var floats := pcm.to_float32_array()
	var samples := PackedByteArray()
	samples.resize(floats.size()*2)
	for index in floats.size(): samples.encode_s16(index*2,int(clampf(floats[index],-1,1)*32767))
	var wave := PackedByteArray()
	wave.resize(44)
	for index in 4: wave[index] = "RIFF".to_ascii_buffer()[index]
	wave.encode_u32(4,36+samples.size())
	for index in 8: wave[8+index] = "WAVEfmt ".to_ascii_buffer()[index]
	wave.encode_u32(16,16)
	wave.encode_u16(20,1)
	wave.encode_u16(22,2)
	wave.encode_u32(24,48000)
	wave.encode_u32(28,192000)
	wave.encode_u16(32,4)
	wave.encode_u16(34,16)
	for index in 4: wave[36+index] = "data".to_ascii_buffer()[index]
	wave.encode_u32(40,samples.size())
	wave.append_array(samples)
	put_bytes(path,wave)

func concurrent_workers(shell: Control, bytes: PackedByteArray) -> void:
	var first := Native.adapter()
	var second := Native.adapter()
	check("simultaneous first video worker starts",true,first.invoke("video",bytes,"webm-v1",16).ok)
	check("simultaneous second video worker starts",true,second.invoke("video",bytes,"webm-v1",16).ok)
	await shell.get_tree().process_frame
	first.invoke("close")
	check("cancelled first worker cannot pop",false,first.invoke("picture").ok)
	var frames := 0
	var done := false
	var deadline := Time.get_ticks_msec()+5000
	while not done and Time.get_ticks_msec()<deadline:
		var frame: Dictionary = second.invoke("picture")
		if not frame.ok: break
		if frame.has("bytes"): frames+=1
		done = frame.drained
		if not frame.has("bytes"): await shell.get_tree().process_frame
	check("second independent decoder survives first cancellation",300,frames)
	check("second independent decoder finite end",true,done)
	second.invoke("close")
	check("concurrent decoder workers joined",0,Native.adapter().invoke("workers").active)

func decode_packets(shell: Control, clip: Dictionary, bytes: PackedByteArray) -> void:
	var native := Native.adapter()
	check(clip.id+" independent worker starts",true,native.invoke("video",bytes,clip.profile,16).ok)
	var frames := 0
	var audio := PackedByteArray()
	var first_image := PackedByteArray()
	var timestamps: Array = []
	var done := false
	var ok := true
	var deadline := Time.get_ticks_msec()+10000
	var peak := 0
	while not done and Time.get_ticks_msec()<deadline:
		var picture: Dictionary = native.invoke("picture")
		var sound: Dictionary = native.invoke("sound")
		ok = ok and picture.ok and sound.ok
		peak = maxi(peak,int(picture.peak_video_queue))
		if picture.has("bytes"):
			frames += 1
			timestamps.append(picture.pts)
			if first_image.is_empty(): first_image = picture.bytes
		if sound.has("bytes"): audio.append_array(sound.bytes)
		done = picture.drained and sound.drained
		if not picture.has("bytes") and not sound.has("bytes"): await shell.get_tree().process_frame
	check(clip.id+" queues drain without failure",true,done and ok)
	check(clip.id+" streamed frame count",300,frames)
	check(clip.id+" bounded measured queue",true,peak<=16)
	var timing := timestamps.size()==300
	for index in timestamps.size(): timing = timing and absf(timestamps[index]-float(index)/30)<=0.01
	check(clip.id+" independent frame timestamps",true,timing)
	var colors := true
	var width: int = clip.get("width",192)
	var height: int = clip.get("height",144)
	if first_image.size()==width*height*4:
		var expected := [[255,0,0],[0,255,0],[0,0,255],[255,255,255]]
		var locations := [Vector2i(width/4,height/3),Vector2i(width*3/4,height/3),Vector2i(width/4,height*3/4),Vector2i(width*3/4,height*3/4)]
		for index in 4:
			var at: int = (locations[index].y*width+locations[index].x)*4
			for channel in 3: colors = colors and absi(int(first_image[at+channel])-expected[index][channel])<=8
	else: colors = false
	check(clip.id+" independent decoded colors",true,colors)
	if not clip.audio.is_empty():
		var samples := audio.to_float32_array()
		var clicks: Array = []
		for second in 10:
			var peak_sample := -1
			var loudest := 0.0
			for index in range(maxi(0,second*48000-3200),mini(samples.size()/2,second*48000+3200)):
				if absf(samples[index*2])>loudest:
					loudest = absf(samples[index*2])
					peak_sample = index
			clicks.append(peak_sample>=0 and absf(float(peak_sample)/48000-second)<=2.0/30.0 and loudest>0.05)
		check(clip.id+" independent PCM click markers",[true,true,true,true,true,true,true,true,true,true],clicks)
		write_wave(sandbox.path_join(clip.id+"-decoded.wav"),audio)
	else: check(clip.id+" video-only has no audio",0,audio.size())
	if not observations.has("decoders"): observations.decoders = {}
	observations.decoders[clip.id] = native.invoke("video_status")
	native.invoke("close")
	check(clip.id+" retired worker rejects pop",false,native.invoke("picture").ok)

func present_clip(shell: Control, video: Control, clip: Dictionary) -> void:
	var attempt := scope("present-"+clip.id)
	var before := outcomes.size()
	var first_marker: int = 0 # The consumer resets its bounded diagnostic trace per attempt.
	check(clip.id+" production committed video request",true,video.request("asset.native."+clip.id,attempt,current).ok)
	var deadline := Time.get_ticks_msec()+14000
	var capture := false
	while outcomes.size()==before and Time.get_ticks_msec()<deadline:
		await shell.get_tree().process_frame
		if not capture and Time.get_ticks_msec()+11000>deadline and DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			var image := shell.get_viewport().get_texture().get_image()
			check(clip.id+" rendered capture",OK,image.save_png(sandbox.path_join(clip.id+"-presented.png")))
			var rect: Rect2 = video._rect.get_global_rect()
			check(clip.id+" rendered fit rectangle",true,absf(rect.size.x/rect.size.y-4.0/3.0)<0.001 and rect.size.x<=video.size.x+1 and rect.size.y<=video.size.y+1)
			var colors := true
			for index in 4:
				var uv: Vector2 = [Vector2(0.25,0.3),Vector2(0.75,0.3),Vector2(0.25,0.75),Vector2(0.75,0.75)][index]
				var expected: Color = [Color.RED,Color.GREEN,Color.BLUE,Color.WHITE][index]
				var at := Vector2i(rect.position+rect.size*uv)
				var actual := image.get_pixel(at.x,at.y)
				colors = colors and absf(actual.r-expected.r)<0.05 and absf(actual.g-expected.g)<0.05 and absf(actual.b-expected.b)<0.05
			check(clip.id+" rendered corner presentation",true,colors)
			capture = true
	check(clip.id+" natural terminal once",before+1,outcomes.size())
	check(clip.id+" natural classified finish","Finished",outcomes.back().kind if outcomes.size()>before else "timeout")
	if outcomes.size()==before: video.cancel(attempt)
	var synchronized: bool = video.measurements.presented_markers.size()>first_marker
	for marker: Dictionary in video.measurements.presented_markers.slice(first_marker): synchronized = synchronized and absf(marker.source_pts-marker.presentation_clock)<=2.0/30.0
	check(clip.id+" presented sync within two frames",true,synchronized)
	check(clip.id+" completed scope cannot cancel again",false,video.cancel(attempt))
