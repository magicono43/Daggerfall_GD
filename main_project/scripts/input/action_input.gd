extends RefCounted
## MOVE captures physical intent; CORE owns eligibility. Consumers own effects.
signal cancelled(report: Dictionary)
signal failure(report: Dictionary)
signal controller_changed
signal invalidated(reason: String)
signal mouse_motion(event: InputEventMouseMotion)
const Bindings = preload("res://scripts/input/action_bindings.gd")
const CAPACITY := 256 # Ordered logical edges, not physical events or physics frames.
const DISCONNECT_OWNER := "action-input-disconnect"
var core: SessionLifecycle
var windows: SessionWindowStack
var bindings: RefCounted
var selected_controller := -1
var last_device := ""
var movement_deadzone := 0.15
var look_deadzone := 0.10
var _analog := {"movement_pair":0,"look_pair":1,"movement_invert":false,"look_invert":false}

func can_configure(candidate: Dictionary) -> bool:
	return preload("res://scripts/input/binding_configuration.gd").valid(candidate)

func configure(candidate: Dictionary) -> bool:
	if not can_configure(candidate): return false
	var replacement := Bindings.new(preload("res://scripts/input/binding_configuration.gd").entries(candidate))
	invalidate("controls changed")
	bindings = replacement
	_analog = candidate.analog.duplicate(true)
	movement_deadzone = _analog.movement_deadzone
	look_deadzone = _analog.look_deadzone
	# A held direction from an old binding must not retain a stale action.
	for physical: Dictionary in _physical.values(): physical.action = ""
	_accepted_axes.clear()
	return true

func physical_down() -> Array:
	return _physical.values().duplicate(true)
var _connected: Dictionary = {}
var _physical: Dictionary = {}
var _logical: Dictionary = {}
var _delivered_holds: Dictionary = {}
var _queue: Array[Dictionary] = []
var _axes: Dictionary = {}
var _accepted_axes: Dictionary = {}
var _trigger_down: Dictionary = {}
var _epoch := 0
var _serial := 0
var _edge_serial := 0
var _context := ""
var _disconnect_hold := 0
var _delivering := false
var delivered_edges := 0

func _init(lifecycle: SessionLifecycle, stack: SessionWindowStack, catalog: RefCounted = null) -> void:
	core = lifecycle
	windows = stack
	bindings = Bindings.new() if catalog == null else catalog
	for device: int in Input.get_connected_joypads(): _connected[device] = true
	_context = _context_key()
	core.gates.changed.connect(_synchronize)
	core.state_changed.connect(_state_changed)
	core.retiring.connect(_retire)
	windows.changed.connect(_synchronize)

func dispose() -> void:
	invalidate("disposed")
	core.gates.changed.disconnect(_synchronize)
	core.state_changed.disconnect(_state_changed)
	core.retiring.disconnect(_retire)
	windows.changed.disconnect(_synchronize)
	_release_disconnect()
	for event: Signal in [cancelled,failure,controller_changed]:
		for connection: Dictionary in event.get_connections(): event.disconnect(connection.callable)

func _context_key() -> String:
	return "%s:%d:%s" % [core.gates.session, windows.context_generation, core.gates.gameplay_input()]

func _state_changed(_old: Dictionary, _new: Dictionary, _reason: String) -> void:
	_synchronize()

func _synchronize() -> void:
	var current := _context_key()
	if current != _context:
		_context = current
		invalidate("context invalidated")

func _retire(_scope: String) -> void:
	invalidate("session retired")
	_release_disconnect()
	last_device = ""

func invalidate(reason: String) -> void:
	_epoch += 1
	_accepted_axes.clear()
	invalidated.emit(reason)
	var pending := _queue.duplicate(true)
	var delivered := _delivered_holds.values().duplicate(true)
	_queue.clear()
	_logical.clear()
	_delivered_holds.clear()
	# Physical down identities remain quarantined until release. No synthetic up.
	if not pending.is_empty() or not delivered.is_empty():
		cancelled.emit({"reason":reason, "pending":pending, "delivered_unfinished":delivered})

func _identity(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {"kind":"key", "code":event.physical_keycode, "location":event.location, "device":-1, "pressed":event.pressed, "echo":event.echo}
	if event is InputEventMouseButton:
		return {"kind":"mouse", "code":event.button_index, "location":0, "device":-1, "pressed":event.pressed, "echo":false}
	if event is InputEventJoypadButton and event.device == selected_controller and _connected.has(event.device):
		return {"kind":"button", "code":event.button_index, "location":0, "device":event.device, "pressed":event.pressed, "echo":false}
	return {}

func _id(value: Dictionary) -> String:
	return "%s:%d:%d:%d" % [value.kind,value.code,value.location,value.device]

func observe(event: InputEvent) -> void:
	_synchronize()
	if event is InputEventJoypadMotion:
		if event.device != selected_controller or not _connected.has(event.device): return
		_axes[event.axis] = event.axis_value
		if event.axis in [JOY_AXIS_TRIGGER_LEFT,JOY_AXIS_TRIGGER_RIGHT]:
			var down: bool = _trigger_down.get(event.axis,false)
			if (not down and event.axis_value >= 0.55) or (down and event.axis_value <= 0.45):
				_trigger_down[event.axis] = not down
				_observe_value({"kind":"trigger","code":event.axis,"location":0,"device":event.device,"pressed":not down,"echo":false})
		elif core.gates.gameplay_input():
			_accepted_axes[event.axis] = false # GUI gets first refusal.
		return
	var value := _identity(event)
	if not value.is_empty():
		if value.kind == "mouse" and value.code in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN,MOUSE_BUTTON_WHEEL_LEFT,MOUSE_BUTTON_WHEEL_RIGHT]:
			_release(_id(value)) # A previous GUI-consumed wheel step has no platform up.
		_observe_value(value)

func finish_consumed(event: InputEvent) -> void:
	# Capture owns these complete impulses, including when GUI never dispatches
	# an unhandled event. No gameplay contributor was admitted for this press.
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN,MOUSE_BUTTON_WHEEL_LEFT,MOUSE_BUTTON_WHEEL_RIGHT]:
		_release(_id(_identity(event)))

func _observe_value(value: Dictionary) -> void:
	var id := _id(value)
	if not value.pressed:
		_release(id)
	elif not value.echo and not _physical.has(id):
		value.epoch = _epoch
		value.accepted = false
		value.action = ""
		_physical[id] = value

func accept(event: InputEvent) -> bool:
	_synchronize()
	if event is InputEventMouseMotion:
		if core.gates.gameplay_input() and not event.relative.is_zero_approx(): last_device = "keyboard_mouse"
		if core.gates.gameplay_input(): mouse_motion.emit(event)
		return false
	if event is InputEventJoypadMotion:
		if event.device != selected_controller or not _connected.has(event.device): return false
		if event.axis not in [JOY_AXIS_TRIGGER_LEFT,JOY_AXIS_TRIGGER_RIGHT]:
			if core.gates.gameplay_input():
				_accepted_axes[event.axis] = true
				var accepted_movement := not _keyboard_movement_held() and not stick(false).is_zero_approx()
				if accepted_movement or not stick(true).is_zero_approx(): last_device = "controller"
			return false
		if not _trigger_down.get(event.axis,false): return false
		return _accept_value({"kind":"trigger","code":event.axis,"location":0,"device":event.device})
	var value := _identity(event)
	if value.is_empty() or not value.pressed or value.echo: return false
	var accepted := _accept_value(value)
	if value.kind == "mouse" and value.code in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN,MOUSE_BUTTON_WHEEL_LEFT,MOUSE_BUTTON_WHEEL_RIGHT]:
		_release(_id(value)) # Wheel steps are complete taps; no platform up required.
	return accepted

func _accept_value(value: Dictionary) -> bool:
	var id := _id(value)
	if not _physical.has(id): return false
	var physical: Dictionary = _physical[id]
	if physical.accepted or physical.epoch != _epoch: return false
	physical.accepted = true # GUI-consumed presses never reach this boundary.
	if not core.gates.gameplay_input(): return false
	var modifiers: Array = []
	for held: Dictionary in _physical.values():
		if held.kind == "key" and held.code in [KEY_SHIFT,KEY_CTRL,KEY_ALT]:
			modifiers.append("%d:%d" % [held.code,held.location])
	var action: String = bindings.resolve(value.kind,value.code,value.location,modifiers)
	if action.is_empty(): return false
	physical.action = action
	last_device = "controller" if value.device >= 0 else "keyboard_mouse"
	if not _logical.has(action):
		_serial += 1
		_logical[action] = {"contributors":{}, "hold":_serial}
		if not _append(action,"started",_serial,value.device): return true
	_logical[action].contributors[id] = true
	return true

func _release(id: String) -> void:
	if not _physical.has(id): return
	var physical: Dictionary = _physical[id]
	_physical.erase(id)
	var action: String = physical.action
	if not _logical.has(action): return
	_logical[action].contributors.erase(id)
	if _logical[action].contributors.is_empty():
		var hold: int = _logical[action].hold
		_logical.erase(action)
		_append(action,"released",hold,physical.device)

func _append(action: String, kind: String, hold: int, device: int) -> bool:
	if _queue.size() == CAPACITY:
		var report := {"reason":"Logical input overflow; unfinished input cancelled. Release and press again.", "capacity":CAPACITY, "pending_edges":_queue.size(), "delivered_edges":delivered_edges, "rejected_edge":{"action":action,"kind":kind,"hold":hold}}
		invalidate("overflow")
		failure.emit(report)
		return false
	_edge_serial += 1
	_queue.append({"action":action,"kind":kind,"hold":hold,"device":device,"sequence":_edge_serial,"session":core.gates.session,"context":windows.context_generation,"epoch":_epoch})
	return true

func pending_count() -> int:
	return _queue.size()

func context_current(edge: Dictionary) -> bool:
	_synchronize()
	return core.gates.gameplay_input() and edge.get("session") == core.gates.session and edge.get("context") == windows.context_generation and edge.get("epoch") == _epoch

func context_ticket() -> Dictionary:
	_synchronize()
	return {"session":core.gates.session,"context":windows.context_generation,"epoch":_epoch}

func held(action: String) -> bool:
	return core.gates.gameplay_input() and _logical.has(action)

## Continuous Hold gait resumes under the same context rules as directions;
## discrete Toggle edges remain quarantined after cancellation.
func continuous_held(action: String) -> bool:
	if action not in ["run","sneak","backward"] or not core.gates.gameplay_input(): return false
	for value: Dictionary in _physical.values():
		if value.action == action and (value.device == -1 or (value.device == selected_controller and not disconnect_pending())): return true
	return false

func deliver(consumer: Callable) -> Array[Dictionary]:
	_synchronize()
	var outcomes: Array[Dictionary] = []
	if _delivering or not core.gates.gameplay_input(): return outcomes
	_delivering = true
	# Bound the batch at entry. Reentrant capture belongs to the next update.
	var remaining := _queue.size()
	var batch_epoch := _epoch
	var cutoff := -1 if _queue.is_empty() else int(_queue.back().sequence)
	while remaining > 0 and not _queue.is_empty() and core.gates.gameplay_input() and batch_epoch == _epoch and _queue.front().sequence <= cutoff:
		remaining -= 1
		var edge: Dictionary = _queue.pop_front()
		if edge.epoch != _epoch: break
		if edge.kind == "started": _delivered_holds[edge.hold] = edge.duplicate(true)
		else: _delivered_holds.erase(edge.hold)
		delivered_edges += 1
		var result: Variant = consumer.call(edge.duplicate(true))
		outcomes.append({"edge":edge,"result":result})
		_synchronize() # A consumer may open a window or retire the session.
	_delivering = false
	return outcomes

static func radial(value: Vector2, deadzone: float) -> Vector2:
	var magnitude := minf(value.length(),1.0)
	if magnitude <= deadzone or is_equal_approx(magnitude,deadzone): return Vector2.ZERO
	return value.normalized() * ((magnitude-deadzone)/(1.0-deadzone))

func stick(look: bool) -> Vector2:
	if not core.gates.gameplay_input(): return Vector2.ZERO
	var pair: int = _analog.look_pair if look else _analog.movement_pair
	var x := JOY_AXIS_LEFT_X if pair == 0 else JOY_AXIS_RIGHT_X
	var y := JOY_AXIS_LEFT_Y if pair == 0 else JOY_AXIS_RIGHT_Y
	var value := Vector2(_axes.get(x,0.0) if _accepted_axes.get(x,false) else 0.0,_axes.get(y,0.0) if _accepted_axes.get(y,false) else 0.0)
	if _analog.look_invert if look else _analog.movement_invert: value.y = -value.y
	return radial(value,look_deadzone if look else movement_deadzone)

func movement() -> Vector2:
	if not core.gates.gameplay_input(): return Vector2.ZERO
	# Continuous movement can resume from still-held physical directions without
	# regenerating a discrete started edge in the replacement context.
	var directions: Dictionary = {}
	for value: Dictionary in _physical.values():
		if value.device == -1 and value.action in ["forward","backward","strafe_left","strafe_right"]:
			directions[value.action] = true
	if not directions.is_empty():
		return Vector2(int(directions.has("strafe_right"))-int(directions.has("strafe_left")),int(directions.has("backward"))-int(directions.has("forward"))).limit_length()
	return stick(false)

func keyboard_look() -> Dictionary:
	var directions := {}
	if core.gates.gameplay_input():
		for value: Dictionary in _physical.values():
			if value.device == -1 and value.accepted and value.epoch == _epoch and value.action in ["turn_left","turn_right","look_up","look_down"]:
				directions[value.action] = true
	return {"held":not directions.is_empty(), "value":Vector2(int(directions.has("turn_right"))-int(directions.has("turn_left")),int(directions.has("look_down"))-int(directions.has("look_up")))}

func _keyboard_movement_held() -> bool:
	for value: Dictionary in _physical.values():
		if value.device == -1 and value.action in ["forward","backward","strafe_left","strafe_right"]: return true
	return false

func controllers() -> Array:
	return _connected.keys().duplicate()

func select_controller(device: int) -> bool:
	if device != -1 and not _connected.has(device): return false
	if device == selected_controller: return true
	invalidate("controller selection changed")
	_clear_controller()
	# Activity belongs to the outgoing controller, not a newly selected idle one.
	if last_device == "controller": last_device = ""
	selected_controller = device
	_prime_controller()
	controller_changed.emit()
	return true

func _clear_controller() -> void:
	_axes.clear()
	_accepted_axes.clear()
	_trigger_down.clear()
	for id: String in _physical.keys():
		if _physical[id].device >= 0: _physical.erase(id)

func connection_changed(device: int, connected: bool) -> void:
	if connected:
		_connected[device] = true
		if device == selected_controller: _prime_controller()
	else:
		_connected.erase(device)
		if device == selected_controller:
			_cancel_controller()
			_clear_controller()
			if last_device == "controller" and _disconnect_hold == 0 and not core.gates.session.is_empty():
				_disconnect_hold = core.gates.acquire(DISCONNECT_OWNER,core.gates.session,["simulation","input"])
	controller_changed.emit()

func _cancel_controller() -> void:
	var affected: Dictionary = {}
	for edge: Dictionary in _queue:
		if edge.device >= 0: affected[edge.hold] = true
	for physical: Dictionary in _physical.values():
		if physical.device >= 0 and _logical.has(physical.action):
			affected[_logical[physical.action].hold] = true
	var pending: Array = []
	var delivered: Array = []
	for index in range(_queue.size()-1,-1,-1):
		if affected.has(_queue[index].hold): pending.push_front(_queue.pop_at(index))
	for hold: int in affected:
		if _delivered_holds.has(hold):
			delivered.append(_delivered_holds[hold])
			_delivered_holds.erase(hold)
	for action: String in _logical.keys():
		if affected.has(_logical[action].hold): _logical.erase(action)
	if not pending.is_empty() or not delivered.is_empty():
		cancelled.emit({"reason":"selected controller disconnected","pending":pending,"delivered_unfinished":delivered})

func _prime_controller() -> void:
	# Quarantine hardware buttons already down at explicit selection/reconnection.
	# No synthetic gameplay start, even if the backend emits no new down event.
	if not Input.get_connected_joypads().has(selected_controller): return
	for button in JOY_BUTTON_MAX:
		if Input.is_joy_button_pressed(selected_controller,button):
			_observe_value({"kind":"button","code":button,"location":0,"device":selected_controller,"pressed":true,"echo":false})
	for axis: int in [JOY_AXIS_TRIGGER_LEFT,JOY_AXIS_TRIGGER_RIGHT]:
		var down := Input.get_joy_axis(selected_controller,axis) > 0.45
		_trigger_down[axis] = down
		if down: _observe_value({"kind":"trigger","code":axis,"location":0,"device":selected_controller,"pressed":true,"echo":false})
	# Even when selection is already eligible these observed holds are not fresh.
	for value: Dictionary in _physical.values():
		if value.device >= 0: value.accepted = true

func reconcile_focus_return() -> void:
	# A backend may omit ups while unfocused. Remove physically released
	# quarantined identities without manufacturing a logical release.
	for id: String in _physical.keys():
		var value: Dictionary = _physical[id]
		var down := true
		match value.kind:
			"key": down = Input.is_physical_key_pressed(value.code)
			"mouse": down = Input.is_mouse_button_pressed(value.code)
			"button": down = Input.is_joy_button_pressed(value.device,value.code)
			"trigger": down = Input.get_joy_axis(value.device,value.code) > 0.45
		if not down: _physical.erase(id)
	_prime_controller()

func disconnect_pending() -> bool:
	return _disconnect_hold != 0

func continue_controller() -> bool:
	if not _connected.has(selected_controller) or _disconnect_hold == 0: return false
	invalidate("explicit controller continuation")
	_release_disconnect()
	return true

func continue_keyboard() -> void:
	select_controller(-1)
	last_device = "keyboard_mouse"
	_release_disconnect()

func _release_disconnect() -> void:
	if _disconnect_hold == 0: return
	var token := _disconnect_hold
	_disconnect_hold = 0
	core.gates.release(token,DISCONNECT_OWNER)
	controller_changed.emit()
