extends SceneTree
## Authoring only. Independent pixels/PCM/SMF precede any encoder invocation.
const Fixture = preload("res://tests/native_fixture.gd")
const DIGITS = ["111101101101111","010110010010111","111001111100111","111001111001111","101101111001001","111100111001111","111100111101111","111001001001001","111101111101111","111101111001111"]
var output := ""
var temporary := ""
var encoder := ""

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
		if argument.begins_with("--temporary="): temporary = argument.trim_prefix("--temporary=")
		if argument.begins_with("--encoder="): encoder = argument.trim_prefix("--encoder=")
	if output.is_empty() or temporary.is_empty() or encoder.is_empty():
		push_error("Explicit output, temporary and authoring encoder paths required.")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output)
	DirAccess.make_dir_recursive_absolute(temporary)
	var raw := FileAccess.open(temporary.path_join("source.rgb"),FileAccess.WRITE)
	for frame in 300:
		var image := Image.create(192,144,false,Image.FORMAT_RGB8)
		image.fill_rect(Rect2i(0,0,96,72),Color.RED)
		image.fill_rect(Rect2i(96,0,96,72),Color.GREEN)
		image.fill_rect(Rect2i(0,72,96,72),Color.BLUE)
		image.fill_rect(Rect2i(96,72,96,72),Color.WHITE)
		image.fill_rect(Rect2i(4,4,68,14),Color.BLACK)
		var text := "%02d%03d" % [frame/30,(frame%30)*1000/30]
		for index in text.length():
			var digit: String = DIGITS[int(text[index])]
			for pixel in digit.length():
				if digit[pixel]=="1": image.fill_rect(Rect2i(8+index*10+(pixel%3)*2,6+(pixel/3)*2,2,2),Color.WHITE)
		raw.store_buffer(image.get_data())
	raw.close()
	var pcm := PackedByteArray()
	pcm.resize(480000*2)
	for frame in 480000:
		var offset := frame%48000
		var value := int(round(20000*sin(TAU*1000*offset/48000.0))) if offset<480 else 0
		pcm.encode_s16(frame*2,value)
	var wave := PackedByteArray()
	wave.resize(44)
	for i in 4: wave[i] = "RIFF".to_ascii_buffer()[i]
	wave.encode_u32(4,36+pcm.size())
	for i in 8: wave[8+i] = "WAVEfmt ".to_ascii_buffer()[i]
	wave.encode_u32(16,16)
	wave.encode_u16(20,1)
	wave.encode_u16(22,1)
	wave.encode_u32(24,48000)
	wave.encode_u32(28,96000)
	wave.encode_u16(32,2)
	wave.encode_u16(34,16)
	for i in 4: wave[36+i] = "data".to_ascii_buffer()[i]
	wave.encode_u32(40,pcm.size())
	wave.append_array(pcm)
	write(temporary.path_join("source.wav"),wave)
	var records: Array = []
	for video: String in ["vp8","vp9","h264"]:
		var audios: Array = ["vorbis","opus","none"] if video!="h264" else ["aac","none"]
		for audio: String in audios:
			var container := "webm" if video!="h264" else "mp4"
			var id := video+"-"+audio
			var target := output.path_join(id+".bytes")
			var args := ["-hide_banner","-loglevel","error","-y","-f","rawvideo","-pixel_format","rgb24","-video_size","192x144","-framerate","30","-i",temporary.path_join("source.rgb")]
			if audio!="none": args.append_array(["-i",temporary.path_join("source.wav")])
			args.append_array(["-c:v",{"vp8":"libvpx","vp9":"libvpx-vp9","h264":"libopenh264"}[video],"-b:v","500k","-pix_fmt","yuv420p","-vf","scale=out_color_matrix=bt709","-colorspace","bt709","-color_trc","bt709","-color_primaries","bt709","-color_range","tv","-threads","1"])
			if video in ["vp8","vp9"]: args.append_array(["-deadline","realtime","-cpu-used","4"])
			if audio!="none": args.append_array(["-c:a",{"vorbis":"libvorbis","opus":"libopus","aac":"aac"}[audio],"-ar","48000","-b:a","128k"])
			else: args.append("-an")
			args.append_array(["-t","10","-f",container,target])
			var logs: Array = []
			var exit := OS.execute(encoder,args,logs,true)
			if exit!=0:
				push_error("Fixture encoder failed: "+id+" "+str(logs))
				quit(1)
				return
			records.append({"id":id,"file":id+".bytes","profile":container+"-v1","video":video,"audio":"" if audio=="none" else audio,"sha256":fixture_digest(FileAccess.get_file_as_bytes(target))})
	var manifest := {"schema":"native-fixtures-v1","author":"Project-authored geometric colors, bitmap timestamps and PCM click formula; no classic payloads.","frames":300,"fps":30,"seconds":10,"width":192,"height":144,"aspect":4.0/3.0,"color":"bt709-limited","corners_rgb":[[255,0,0],[0,255,0],[0,0,255],[255,255,255]],"sample_rate":48000,"click_samples":[0,48000,96000,144000,192000,240000,288000,336000,384000,432000],"source_rgb_sha256":fixture_digest(FileAccess.get_file_as_bytes(temporary.path_join("source.rgb"))),"source_wav_sha256":fixture_digest(wave),"clips":records}
	var extra_specs := [
		{"id":"h264-anamorphic","codec":"libopenh264","container":"mp4","video":"h264","audio":"aac","filter":"scale=1280:720:flags=neighbor:out_color_matrix=bt709,setsar=3/4","range":"tv","color":"bt709-limited","width":1280,"height":720,"supported":true},
		{"id":"vp9-full","codec":"libvpx-vp9","container":"webm","video":"vp9","filter":"scale=out_color_matrix=bt709:out_range=full","range":"pc","color":"bt709-full","width":192,"height":144,"supported":true},
		{"id":"unsupported-mpeg4","codec":"mpeg4","container":"mp4","video":"mpeg4","filter":"scale=out_color_matrix=bt709","range":"tv","supported":false},
		{"id":"unsupported-matroska","codec":"libvpx","container":"matroska","video":"vp8","filter":"scale=out_color_matrix=bt709","range":"tv","supported":false}
	]
	manifest.unsupported = []
	for spec: Dictionary in extra_specs:
		var record := extra_clip(spec)
		if record.is_empty():
			quit(1)
			return
		if spec.supported: manifest.clips.append(record)
		else: manifest.unsupported.append(record)
	write(output.path_join("fixtures.json"),JSON.stringify(manifest,"\t").to_utf8_buffer())
	write_declarations(manifest)
	print("Authored native fixtures: ",records.size())
	quit()

func extra_clip(spec: Dictionary) -> Dictionary:
	var target := output.path_join(spec.id+".bytes")
	var args := ["-hide_banner","-loglevel","error","-y","-f","rawvideo","-pixel_format","rgb24","-video_size","192x144","-framerate","30","-i",temporary.path_join("source.rgb")]
	if spec.get("audio","")=="aac": args.append_array(["-i",temporary.path_join("source.wav"),"-c:a","aac","-ar","44100","-b:a","128k"])
	else: args.append("-an")
	args.append_array(["-c:v",spec.codec,"-b:v","2M","-pix_fmt","yuv420p","-vf",spec.filter,"-colorspace","bt709","-color_trc","bt709","-color_primaries","bt709","-color_range",spec.range,"-threads","1"])
	if spec.video in ["vp8","vp9"]: args.append_array(["-deadline","realtime","-cpu-used","4"])
	args.append_array(["-t","10","-f",spec.container,target])
	var logs: Array = []
	if OS.execute(encoder,args,logs,true)!=0:
		push_error("Additional fixture encoding failed: "+spec.id+" "+str(logs))
		return {}
	# Authoring-only reference decode establishes that a deliberately unsupported
	# container/codec fixture is valid; native success still needs independent goldens.
	if not spec.supported and OS.execute(encoder,["-hide_banner","-loglevel","error","-i",target,"-f","null","-"],logs,true)!=0:
		push_error("Unsupported-profile fixture is itself invalid: "+spec.id)
		return {}
	return {"id":spec.id,"file":spec.id+".bytes","profile":"webm-v1" if spec.container in ["webm","matroska"] else "mp4-v1","video":spec.video,"audio":spec.get("audio",""),"color":spec.get("color","bt709-limited"),"width":spec.get("width",192),"height":spec.get("height",144),"sha256":fixture_digest(FileAccess.get_file_as_bytes(target))}

func fixture_digest(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()

func write_declarations(manifest: Dictionary) -> void:
	var exports: Array = []
	var targets: Array = []
	write(output.path_join("sequence.mid.bytes"),Fixture.smf())
	write(output.path_join("sine.sf2.bytes"),Fixture.bank())
	for item in [["native-midi","sequence.mid.bytes","midi-v1","midi"],["native-bank","sine.sf2.bytes","sf2-v1","bank"],["native-recording","clicks.wav.bytes","pcm-wav-v1","audio"]]:
		exports.append(Fixture.Base.export_entry(item[0],item[1],item[2],item[3]))
	targets.append(Fixture.Base.target("asset.native.song","@shipped/media-assets","native-midi","midi"))
	targets.append(Fixture.Base.target("asset.native.recording","@shipped/media-assets","native-recording","audio"))
	for clip: Dictionary in manifest.clips:
		exports.append(Fixture.Base.export_entry("native-"+clip.id,clip.file,clip.profile,"video"))
		targets.append(Fixture.Base.target("asset.native."+clip.id,"@shipped/media-assets","native-"+clip.id,"video"))
	write(output.path_join("a-exports.json"),JSON.stringify(Fixture.Base.envelope("exports","add",exports),"\t").to_utf8_buffer())
	write(output.path_join("b-targets.json"),JSON.stringify(Fixture.Base.envelope("targets","add",targets),"\t").to_utf8_buffer())

func write(path: String, bytes: PackedByteArray) -> void:
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
