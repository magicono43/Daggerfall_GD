extends "res://tests/mod_cases.gd"
const Native = preload("res://scripts/data/native_media.gd")
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var caps := Native.capabilities()
	var expected: Dictionary = fixture.native_fault
	var prefix: String = expected.id+"/"
	check(prefix+"actual independent capabilities",[expected.midi,expected.video],[caps.get("midi"),caps.get("video")])
	var reason: String = caps.get("midi_reason","") if expected.stack=="midi" else caps.get("video_reason","")
	if expected.get("bank",false): reason = Native.default_bank().get("reason","")
	check(prefix+"attributable dependency failure",true,reason.contains(expected.reason))
	shell.controller.settings.apply({"startup/show_setup":true})
	shell.controller.settings.effective["startup/show_setup"] = true
	shell.controller.select_folder(fixture.classic_source)
	check(prefix+"recording-only real menu admission",true,shell.controller.continue_to_menu("save").ok)
	shell.render()
	var music: Node = shell.session_shell.music_playback
	var scope := {"attempt":expected.id,"session":"","operation":"library-fault-recording"}
	var request: Dictionary = music.request("asset.native.recording","audio",scope)
	check(prefix+"recording production request independent",true,request.ok)
	await shell.get_tree().create_timer(0.06).timeout
	check(prefix+"recording actual game audio active",true,request.ok and music.projection().has(request.get("id","")))
	var failed: Dictionary = music.request("asset.native.unavailable-midi","midi",scope) if expected.stack=="midi" else media_failure(shell.controller.providers.media)
	check(prefix+"native request classified unavailable",expected.get("failure_kind","backend_unavailable"),failed.get("kind",""))
	if request.ok: music.retire(request.id)
	check(prefix+"recording cleanup independent",{},music.projection())
	check(prefix+"no native workers leaked",0,Native.adapter().invoke("workers").active)
	var ok := true
	for item: Dictionary in checks: ok = ok and item.expected==item.actual
	return {"ok":ok,"count":checks.size(),"checks":checks,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs,"capabilities":caps}
func media_failure(media: RefCounted) -> Dictionary:
	return media.resolve("asset.native.unavailable-video","video")
