extends "res://tests/mod_cases.gd"
## Controlled AV outcomes exercise the real CORE preflight/requester boundary.
class Video extends Control:
	signal terminal(result: Dictionary)
	var targets: Array = []
	var active_scope: Dictionary = {}
	var missing := false
	var cancelled := 0
	func request(target: String, scope: Dictionary, current: Callable, _skip: String) -> Dictionary:
		if not current.call(scope): return {"ok":false,"reason":"stale"}
		targets.append(target)
		if missing: return {"ok":false,"reason":"Controlled optional absence."}
		active_scope = scope.duplicate(true)
		return {"ok":true}
	func owns_scope(scope: Dictionary) -> bool: return active_scope == scope
	func complete(kind: String) -> Dictionary:
		var outcome := {"kind":kind,"scope":active_scope.duplicate(true)}
		active_scope.clear()
		terminal.emit(outcome)
		return outcome
	func cancel(_scope: Dictionary) -> void:
		cancelled += 1
		complete("Cancelled")

class Settings extends RefCounted:
	var effective := {"media/creation_videos":true}

func qualify(shell: Control) -> Array[Dictionary]:
	var core := preload("res://scripts/session/session_lifecycle.gd").new()
	core.startup_route_changed("main_menu")
	var video := Video.new()
	var settings := Settings.new()
	var sequence := preload("res://scripts/session/creation_cinematics.gd").new()
	sequence.bind(core,video,settings)
	core.provider.creation_video = sequence.start
	core.provider.cancel_creation_video = sequence.cancel
	var intent := {"id":"intro-fixture","mode":"new","origin":"","selection":{"creation":{"schema":"creation-submission-v1"}}}
	settings.effective["media/creation_videos"] = false
	check("identity clips disabled fail real entry","Failed",core.request(intent).kind)
	check("identity clips disabled no AV attempt",0,video.targets.size())
	settings.effective["media/creation_videos"] = true
	intent.id = "intro-enabled"
	check("identity clips admitted through CORE","pending",core.request(intent).kind)
	check("identity clips repeated request stays pending","pending",core.request(intent).kind)
	await shell.get_tree().process_frame
	check("identity clips first DFU target","creation.intro.0",video.targets.back())
	var stale := video.complete("Skipped")
	video.terminal.emit(stale)
	await shell.get_tree().process_frame
	check("identity clips duplicate callback advances once",2,video.targets.size())
	check("identity clips second DFU target","creation.intro.1",video.targets.back())
	video.complete("Failed")
	await shell.get_tree().process_frame
	check("identity clips failure continues final target","creation.intro.2",video.targets.back())
	video.complete("Finished")
	await shell.get_tree().process_frame
	check("identity clips presentation cannot certify readiness","Failed",core.request(intent).kind)
	check("identity clips complete retains no session","",core.snapshot().session)
	check("identity clips zero actors",0,core.actors._actors.size())
	video.missing = true; video.targets.clear(); intent.id = "intro-missing"
	core.request(intent)
	for index in 5: await shell.get_tree().process_frame
	check("identity missing clips try all three in order",sequence.TARGETS,video.targets)
	check("identity missing clips do not strand preflight",false,core.busy())
	video.missing = false; video.targets.clear(); intent.id = "intro-cancel"
	core.request(intent)
	await shell.get_tree().process_frame
	var old := video.active_scope.duplicate(true)
	check("identity clip cancellation CORE accepted",true,core.cancel(core.ticket()))
	check("identity clip cancellation releases playback",1,video.cancelled)
	video.terminal.emit({"kind":"Finished","scope":old})
	await shell.get_tree().process_frame
	check("identity clip stale completion cannot continue",1,video.targets.size())
	check("identity clip cancellation terminal retained","Cancelled",core.request(intent).kind)
	sequence.dispose(); core.dispose(); video.free()
	return checks
