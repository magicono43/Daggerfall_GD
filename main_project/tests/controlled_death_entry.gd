extends "res://tests/controlled_actor_entry.gd"
## Controlled creation/readiness with the real shell AV death-video handoff.
func death_presentation(value: Dictionary) -> Dictionary:
	videos += 1
	return death_video.call(value)
