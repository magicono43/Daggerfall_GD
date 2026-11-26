extends RefCounted
## Application Controls consumer. Configuration performs no foreign notification;
## it participates in the stock validate-all / publish-all preference boundary.
const Configuration = preload("res://scripts/input/binding_configuration.gd")
var _response := {"movement_audio_percent":100.0}
var _player: WeakRef

func can_configure(candidate: Dictionary) -> bool:
	return Configuration.valid(candidate)

func configure(candidate: Dictionary) -> bool:
	if not can_configure(candidate): return false
	_response = {"movement_audio_percent":candidate.response.movement_audio_percent}
	_apply()
	return true

func attach(player: AudioStreamPlayer) -> bool:
	if not is_instance_valid(player) or not player.has_method("configure_response"): return false
	_player = weakref(player)
	_apply()
	return true

func _apply() -> void:
	if _player != null and is_instance_valid(_player.get_ref()): _player.get_ref().configure_response(_response)

func dispose() -> void:
	_player = null
