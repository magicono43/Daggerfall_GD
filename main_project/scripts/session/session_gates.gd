class_name SessionGates
extends RefCounted
## CORE-owned requester tokens. Empty scope is application lifetime.
signal changed
var _holds: Dictionary = {}
var _next := 0
var session := ""
var ready := false
var safe := true
var intended_rate := 1.0
var hud_preference := true
var hud_bound := false

func acquire(owner: String, scope: String, channels: Array) -> int:
	_next += 1
	_holds[_next] = {"owner": owner, "scope": scope, "channels": channels.duplicate()}
	changed.emit()
	return _next

func release(token: int, owner: String) -> bool:
	if not _holds.has(token) or _holds[token].owner != owner:
		return false
	_holds.erase(token)
	changed.emit()
	return true

func retire(scope: String) -> void:
	for token in _holds.keys():
		if _holds[token].scope == scope:
			_holds.erase(token)
	changed.emit()

func blocked(channel: String) -> bool:
	for hold: Dictionary in _holds.values():
		if (hold.scope.is_empty() or hold.scope == session) and hold.channels.has(channel):
			return true
	return false

func simulation() -> bool:
	return ready and safe and not session.is_empty() and not blocked("simulation")

func blocked_except(channel: String, owner: String, owner_scope: Variant = null) -> bool:
	# TIME supplies an exact current session; legacy two-argument consumers keep
	# their existing requester contract. An application hold is not that session.
	for hold: Dictionary in _holds.values():
		if (hold.scope.is_empty() or hold.scope == session) and channel in hold.channels:
			if hold.owner != owner or (owner_scope != null and hold.scope != owner_scope): return true
	return false

func gameplay_input() -> bool:
	return ready and safe and not session.is_empty() and not blocked("input")

func blocked_except_scoped(channel: String, owners: Array, scope: String, exact_tokens: Dictionary = {}) -> bool:
	# Multiple exact-session exclusions are needed for TIME settlement under an
	# activity's own hold. The legacy two-argument method remains unchanged.
	for token: int in _holds:
		var hold: Dictionary = _holds[token]
		if (hold.scope.is_empty() or hold.scope == session) and channel in hold.channels:
			if hold.scope != scope or hold.owner not in owners: return true
			if exact_tokens.has(hold.owner) and token != exact_tokens[hold.owner]: return true
	return false

func presentation() -> bool:
	return not blocked("presentation")

func hud_visible() -> bool:
	return hud_preference and hud_bound and not session.is_empty() and not blocked("hud")

func effective_rate() -> float:
	return intended_rate if simulation() else 0.0
