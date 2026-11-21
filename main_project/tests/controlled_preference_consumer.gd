extends RefCounted
## Controlled provider only; does not claim a real gameplay/location integration.
var generation := 1
var active := true
var reject := false
var calls := 0
var values: Dictionary = {}

func preferences_current(ticket: Dictionary) -> bool:
	return active and ticket.get("generation") == generation

func preferences_boundary_current(ticket: Dictionary) -> bool:
	return preferences_current(ticket) and ticket.has("scope") and ticket.has("id")

func apply_preferences(candidate: Dictionary, ticket: Dictionary) -> bool:
	if not preferences_current(ticket) or reject:
		return false
	calls += 1
	values = candidate.duplicate(true)
	return true
