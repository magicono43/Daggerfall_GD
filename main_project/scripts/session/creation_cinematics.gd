extends RefCounted
## Creation-only preflight presentation; CORE retains admission and replacement.
## Finishing these optional clips never supplies missing fresh-entry providers.
const TARGETS = ["creation.intro.0","creation.intro.1","creation.intro.2"]
var core: RefCounted
var playback: Control
var settings: RefCounted
var _ticket: Dictionary = {}
var _scope: Dictionary = {}
var _index := 0
var _generation := 0
var outcomes: Array = []

func bind(lifecycle: RefCounted, video: Control, preferences: RefCounted) -> void:
	core = lifecycle
	playback = video
	settings = preferences
	playback.terminal.connect(_terminal)

func start(ticket: Dictionary, intent: Dictionary) -> Dictionary:
	if intent.get("mode") != "new" or intent.get("selection",{}).get("creation",{}).get("schema") != "creation-submission-v1": return unavailable()
	if not _ticket.is_empty(): return {"ok":false,"reason":"Creation presentation already owns an operation."}
	if settings != null and not settings.effective.get("media/creation_videos",true): return unavailable()
	_ticket = ticket.duplicate(true)
	_index = 0
	_generation += 1
	outcomes.clear()
	call_deferred("_advance",_generation)
	return {"pending":true}

static func unavailable() -> Dictionary:
	return {"ok":false,"reason":"Character entry is unavailable in this build. Your creation choices are retained for review."}

func current(scope: Dictionary) -> bool:
	return not _ticket.is_empty() and core.ticket() == _ticket and core.snapshot().phase == "preflight" and scope == _scope

func _advance(generation: int) -> void:
	if generation != _generation or _ticket.is_empty(): return
	if core.ticket() != _ticket or core.snapshot().phase != "preflight": cancel(_ticket); return
	if _index >= TARGETS.size():
		var ticket := _ticket.duplicate(true)
		_ticket.clear(); _scope.clear()
		core.complete_preflight(ticket,unavailable())
		return
	_scope = {"session":_ticket.scope,"operation":_ticket.id,"attempt":"creation-%d-%d" % [_generation,_index]}
	var requested := _scope.duplicate(true)
	var begun: Dictionary = playback.request(TARGETS[_index],_scope,current,"any")
	if _scope != requested or generation != _generation: return # Synchronous terminal already consumed.
	if not begun.ok:
		if playback.owns_scope(requested): return # Cleanup publishes its single terminal.
		# Admission can fail before owning a window, or settle asynchronously after
		# native preparation. Invalidate its scope before proceeding either way.
		outcomes.append({"target":TARGETS[_index],"kind":"Failed","reason":begun.get("reason","")})
		_index += 1
		_scope.clear()
		call_deferred("_advance",generation)

func _terminal(result: Dictionary) -> void:
	if not current(result.get("scope",{})): return
	outcomes.append({"target":TARGETS[_index],"kind":result.kind})
	_index += 1
	_scope.clear()
	call_deferred("_advance",_generation)

func cancel(ticket: Dictionary) -> void:
	if _ticket != ticket: return
	var scope := _scope.duplicate(true)
	_ticket.clear(); _scope.clear(); _generation += 1
	playback.cancel(scope)

func dispose() -> void:
	if not _ticket.is_empty(): cancel(_ticket.duplicate(true))
	if is_instance_valid(playback) and playback.terminal.is_connected(_terminal): playback.terminal.disconnect(_terminal)
	playback = null; core = null; settings = null
