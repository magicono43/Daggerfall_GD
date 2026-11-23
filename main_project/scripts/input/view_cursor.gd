extends RefCounted
## MOVE resolved facing; UI context owns eligibility. Degrees, seconds and UI pixels.
const Configuration = preload("res://scripts/input/binding_configuration.gd")
var input: RefCounted
var viewport: Viewport
var camera: Camera3D
var cursor_mode := false
var requested_mouse_mode := Input.MOUSE_MODE_VISIBLE
var cursor := Vector2.ZERO
var facing := Vector2.ZERO # yaw, pitch; positive pitch looks down.
var _response := Configuration.response_defaults()
var _motion := Vector2.ZERO
var _mouse_received := false
var _tail := Vector2.ZERO
var _velocity := Vector2.ZERO
var _source := ""
var _eligible := false
var _fence := true
var _scope := ""
var _serial := 0
var _gestures := {}

func _init(actions: RefCounted, target: Viewport, presentation: Camera3D) -> void:
	input = actions
	viewport = target
	camera = presentation
	input.invalidated.connect(_invalidated)
	input.mouse_motion.connect(_mouse)
	input.core.retiring.connect(_retire)
	_sync()

func dispose() -> void:
	input.invalidated.disconnect(_invalidated)
	input.mouse_motion.disconnect(_mouse)
	input.core.retiring.disconnect(_retire)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func can_configure(candidate: Dictionary) -> bool:
	return Configuration.valid(candidate)

func configure(candidate: Dictionary) -> bool:
	if not can_configure(candidate): return false
	_response = candidate.response.duplicate(true)
	clear_pending()
	return true

func clear_pending() -> void:
	_motion = Vector2.ZERO
	_mouse_received = false
	_tail = Vector2.ZERO
	_velocity = Vector2.ZERO
	_source = ""
	_fence = true

func _invalidated(_reason: String) -> void:
	clear_pending()
	_gestures.clear()
	_sync()

func _retire(_old_scope: String) -> void:
	cursor_mode = false
	_scope = ""
	facing = Vector2.ZERO
	clear_pending()
	_gestures.clear()
	_present()

func _sync() -> void:
	var scope: String = input.core.gates.session
	if scope != _scope:
		_scope = scope
		cursor_mode = false
		clear_pending()
	var eligible: bool = input.core.gates.gameplay_input() and input.windows.top().is_empty()
	if eligible != _eligible:
		_eligible = eligible
		clear_pending()
		if eligible and cursor_mode: _center_cursor()
	var mode := Input.MOUSE_MODE_CAPTURED if eligible and not cursor_mode else Input.MOUSE_MODE_VISIBLE
	if not eligible and input.windows.top().get("data",{}).get("cursor") == "hidden": mode = Input.MOUSE_MODE_HIDDEN
	requested_mouse_mode = mode
	if Input.mouse_mode != mode: Input.mouse_mode = mode

func _center_cursor() -> void:
	cursor = viewport.get_visible_rect().get_center()
	if DisplayServer.get_name() != "headless": viewport.warp_mouse(cursor)

func _mouse(event: InputEventMouseMotion) -> void:
	_sync()
	if not _eligible or _fence: return
	if cursor_mode:
		cursor = _clamp_cursor(event.position)
	elif _gestures.is_empty():
		_motion += event.relative
		_mouse_received = not event.relative.is_zero_approx() or _mouse_received

func toggle() -> bool:
	_sync()
	if not _eligible: return false
	cursor_mode = not cursor_mode
	input.invalidate("gameplay cursor changed")
	clear_pending()
	if cursor_mode: _center_cursor()
	_sync()
	return true

func center() -> void:
	facing.y = 0.0
	clear_pending()
	_present()

func capture_facing(scope: String) -> Dictionary:
	if scope.is_empty() or scope != input.core.gates.session: return {"ok":false}
	return {"ok":true,"version":1,"yaw":facing.x,"pitch":facing.y}

func place_facing(scope: String, value: Dictionary, native_load := false) -> bool:
	if scope.is_empty() or scope != input.core.gates.session or value.get("version") != 1: return false
	for field: String in ["yaw","pitch"]:
		if typeof(value.get(field)) not in [TYPE_FLOAT,TYPE_INT] or not is_finite(float(value[field])): return false
	if absf(value.pitch) > 89.0: return false
	facing = Vector2(wrapf(value.yaw,-180.0,180.0),value.pitch)
	input.invalidate("explicit facing changed")
	clear_pending()
	_gestures.clear()
	if native_load: cursor_mode = false
	_present()
	_sync()
	return true

func reserve_mouse(requester: String, scope: String, eligible_gesture: bool) -> Dictionary:
	_sync()
	if requester.is_empty() or scope != _scope or not _eligible or not eligible_gesture: return {}
	_serial += 1
	var token := {"id":_serial,"requester":requester,"scope":scope}
	_gestures[_serial] = token.duplicate(true)
	clear_pending()
	return token

func release_mouse(token: Dictionary) -> bool:
	if not _gestures.has(token.get("id")) or _gestures[token.id] != token: return false
	_gestures.erase(token.id)
	clear_pending()
	return true

func _clamp_cursor(value: Vector2) -> Vector2:
	var rect := viewport.get_visible_rect()
	return value.clamp(rect.position,rect.end)

func advance(delta: float) -> void:
	_sync()
	if not is_finite(delta) or delta < 0.0: return
	if not _eligible:
		clear_pending()
		return
	if _fence:
		_fence = false
		_motion = Vector2.ZERO
		return
	if cursor_mode:
		# UI reference space is 1280 wide; viewport stretch maps it to the screen.
		var scale := viewport.get_visible_rect().size.x / 1280.0
		var move: Vector2 = input.stick(true) * _response.cursor_speed * delta * scale
		cursor = _clamp_cursor(cursor + move)
		if not move.is_zero_approx() and DisplayServer.get_name() != "headless": viewport.warp_mouse(cursor)
		return
	var keyboard: Dictionary = input.keyboard_look()
	var source := "mouse" if _mouse_received else ("keyboard" if keyboard.held else "controller")
	var rate := Vector2.ZERO
	var impulse := Vector2.ZERO
	if source == "mouse":
		impulse = _motion * Vector2(_response.mouse_x,_response.mouse_y)
		if _response.mouse_invert: impulse.y = -impulse.y
	elif source == "keyboard": rate = keyboard.value * _response.keyboard_look
	else:
		rate = input.stick(true) * Vector2(_response.controller_x,_response.controller_y)
		if _response.controller_invert: rate.y = -rate.y
	_motion = Vector2.ZERO
	_mouse_received = false
	if source != _source:
		# A mouse impulse's tail remains eligible while there is no competing input.
		if _source == "mouse" and source == "controller" and rate.is_zero_approx() and not keyboard.held:
			source = "mouse"
		else:
			_tail = Vector2.ZERO
			_velocity = Vector2.ZERO
		_source = source
	var smoothing: bool = _response[source + "_smoothing"]
	var change := impulse if source == "mouse" else rate * delta
	if smoothing:
		var tau: float = _response[source + "_smoothing_seconds"]
		var decay := exp(-delta/tau)
		if source == "mouse":
			_tail += impulse
			change = _tail * (1.0-decay)
			_tail *= decay
		else:
			# Exact integral of dv/dt=(rate-v)/tau for a constant eligible rate.
			change = rate * delta + (_velocity-rate) * tau * (1.0-decay)
			_velocity = rate + (_velocity-rate) * decay
	else:
		_tail = Vector2.ZERO
		_velocity = Vector2.ZERO
	facing.x = wrapf(facing.x + change.x,-180.0,180.0)
	facing.y = clampf(facing.y + change.y,-89.0,89.0)
	if absf(facing.y) >= 89.0:
		_tail.y = 0.0
		_velocity.y = 0.0
	_present()

func _present() -> void:
	if is_instance_valid(camera): camera.rotation = Vector3(deg_to_rad(-facing.y),deg_to_rad(-facing.x),0.0)

func ray_context(scope: String) -> Dictionary:
	_sync()
	if scope != _scope or scope.is_empty() or not _eligible or not is_instance_valid(camera) or not camera.is_inside_tree(): return {"ok":false}
	var point := cursor if cursor_mode else viewport.get_visible_rect().get_center()
	return {"ok":true,"scope":scope,"ticket":input.context_ticket(),"cursor_mode":cursor_mode,"point":point,"origin":camera.project_ray_origin(point),"direction":camera.project_ray_normal(point),"yaw":facing.x,"pitch":facing.y}

func ray_context_current(value: Dictionary) -> bool:
	var point := cursor if cursor_mode else viewport.get_visible_rect().get_center()
	return value.get("ok",false) and input.context_current(value.get("ticket",{})) and value.get("yaw") == facing.x and value.get("pitch") == facing.y and value.get("point") == point and value.get("cursor_mode") == cursor_mode
