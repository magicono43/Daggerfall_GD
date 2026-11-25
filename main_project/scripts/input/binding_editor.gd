extends RefCounted
## Stock controls handlers. Capture has its own context and consumes every event.
const Configuration = preload("res://scripts/input/binding_configuration.gd")
var owner: RefCounted
var input: RefCounted
var shell: RefCounted
var action := "jump"
var capture: Dictionary = {}
var _waiting: Dictionary = {}
var _modifiers: Dictionary = {}
var _modifier_candidate: Dictionary = {}
var _triggers: Dictionary = {}

func feedback(reason: String) -> void:
	if owner.status == reason: return
	owner.status = reason
	shell.schedule_render()

func _init(configuration: RefCounted, action_input: RefCounted, session_shell: RefCounted) -> void:
	owner = configuration
	input = action_input
	shell = session_shell

func dispose() -> void:
	owner = null
	input = null
	shell = null

func start_capture(family: String, slot: int) -> void:
	capture = {"action":action,"family":family,"slot":slot}
	_waiting.clear()
	_modifiers.clear()
	_modifier_candidate.clear()
	for value: Dictionary in input.physical_down():
		if value.kind == "mouse" and value.code in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN,MOUSE_BUTTON_WHEEL_LEFT,MOUSE_BUTTON_WHEEL_RIGHT]: continue
		_waiting[identity(value)] = true
		if value.kind == "trigger": _triggers["%d:%d" % [value.device,value.code]] = true
	input.invalidate("binding capture")
	owner.status = "Release opening input, then press a key/button. Escape / Back cancels; Start returns to controls."
	shell.schedule_render()

static func identity(value: Dictionary) -> String:
	return "%s:%d:%d:%d" % [value.kind,value.code,value.get("location",0),value.get("device",-1)]

func stop_capture() -> void:
	capture.clear()
	_waiting.clear()
	_modifiers.clear()
	_modifier_candidate.clear()
	input.invalidate("capture ended")
	shell.schedule_render()

func event_value(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {"kind":"key","code":event.physical_keycode,"location":event.location,"pressed":event.pressed,"device":-1}
	if event is InputEventMouseButton:
		return {"kind":"mouse","code":event.button_index,"pressed":event.pressed,"device":-1}
	if event is InputEventJoypadButton:
		return {"kind":"button","code":event.button_index,"pressed":event.pressed,"device":event.device}
	if event is InputEventJoypadMotion and event.axis in [JOY_AXIS_TRIGGER_LEFT,JOY_AXIS_TRIGGER_RIGHT]:
		var id := "%d:%d" % [event.device,event.axis]
		var down: bool = _triggers.get(id,false)
		if event.axis_value >= 0.55: down = true
		elif event.axis_value <= 0.45: down = false
		_triggers[id] = down
		return {"kind":"trigger","code":event.axis,"pressed":down,"device":event.device}
	return {}

func route(event: InputEvent) -> bool:
	if capture.is_empty(): return false
	var value := event_value(event)
	if value.is_empty():
		if event is InputEventJoypadMotion and absf(event.axis_value) <= 0.5: return true
		if not event is InputEventMouseMotion:
			feedback("Unsupported discrete input; assign stick axes separately.")
		return true
	if event is InputEventKey and event.echo: return true
	var id := identity(value)
	# Recovery stays reachable even while the opening button is still held.
	if value.pressed and ((value.kind == "key" and value.code == KEY_ESCAPE) or (value.kind == "button" and value.code == JOY_BUTTON_START) or (value.device >= 0 and owner.resolve_ui(value.kind,value.code) == "ui_back")):
		owner.status = "Capture cancelled; slot unchanged."
		stop_capture()
		return true
	if not _waiting.is_empty():
		if not value.pressed: _waiting.erase(id)
		elif not _waiting.has(id): _waiting[id] = true
		return true
	if value.device >= 0 and value.device != input.selected_controller:
		feedback("Select this controller before capturing its inputs.")
		return true
	if value.kind == "key" and value.code in [KEY_SHIFT,KEY_CTRL,KEY_ALT]:
		var modifier := "%d:%d" % [value.code,value.location]
		if value.pressed:
			_modifiers[modifier] = true
			_modifier_candidate = value.duplicate(true)
			return true
		_modifiers.erase(modifier)
		if _modifier_candidate.is_empty(): return true
		value = _modifier_candidate.duplicate(true)
		_modifier_candidate.clear()
	elif not value.pressed: return true
	var binding := value.duplicate(true)
	binding.erase("pressed")
	binding.erase("device")
	if not _modifiers.is_empty():
		if _modifiers.size() != 1:
			feedback("Only one modifier is supported. Release modifiers and try again.")
			_modifier_candidate.clear()
			return true
		binding.modifier = _modifiers.keys()[0]
	var target := capture.duplicate(true)
	var result: Dictionary = owner.propose(target.action,target.family,target.slot,binding)
	if result.ok or not owner.pending().is_empty(): stop_capture()
	shell.schedule_render()
	return true

func render(host: Control) -> void:
	host.label("Controls · staged application preferences",24)
	host.label("Reserved recovery: Escape and controller Menu / Start. Bindings use physical keys; labels follow the keyboard layout.",15)
	for notice: String in owner.notices: host.label(notice,15)
	host.label(owner.status,16)
	if not capture.is_empty():
		host.label("Capturing %s · %s slot %d" % [capture.action,capture.family,capture.slot+1])
		host.button("Cancel Capture",func(): owner.status = "Capture cancelled; slot unchanged."; stop_capture())
		return
	var pending: Dictionary = owner.pending()
	if not pending.is_empty():
		for pair: Dictionary in pending.conflicts:
			host.label("Conflict: %s / %s · %s" % [pair.first.action,pair.second.action,Configuration.label(pair.first.binding)])
		host.button("Replace",func(): owner.resolve_replace(true); shell.schedule_render())
		host.button("Cancel Assignment",func(): owner.resolve_replace(false); shell.schedule_render())
		return
	var selector := OptionButton.new()
	for id: String in Configuration.inventory():
		selector.add_item(id.capitalize().replace("_"," "))
		if id == action: selector.select(selector.item_count-1)
	host.panel.add_child(selector)
	selector.item_selected.connect(func(index: int): action = Configuration.inventory()[index]; shell.schedule_render())
	var draft: Dictionary = owner.draft()
	for family: String in Configuration.FAMILIES:
		if Configuration.context(action) == "ui" and family == "keyboard": continue
		for slot: int in 2:
			var value: Dictionary = draft.actions[action][family][slot]
			var row := HBoxContainer.new()
			host.panel.add_child(row)
			host.button("%s %d · %s" % [family.capitalize(),slot+1,Configuration.label(value)],func(): start_capture(family,slot),row)
			host.button("Clear %s %d" % [family,slot+1],func(): owner.propose(action,family,slot,{}); shell.schedule_render(),row)
	var unbound: Array = []
	for id: String in Configuration.inventory():
		var record: Dictionary = draft.actions[id]
		if (record.keyboard + record.controller).all(func(value: Dictionary): return value.is_empty()): unbound.append(id)
	if not unbound.is_empty(): host.label("Warning · unbound: " + ", ".join(unbound),15)
	var analog: Dictionary = draft.analog
	for field: String in ["movement_pair","look_pair"]:
		var choice := OptionButton.new()
		choice.add_item(field.capitalize().replace("_"," ") + ": Left stick (axes 1/2)")
		choice.add_item(field.capitalize().replace("_"," ") + ": Right stick (axes 4/5)")
		choice.select(analog[field])
		host.panel.add_child(choice)
		# Swapping the pair is one coherent edit, never an invalid intermediate map.
		choice.item_selected.connect(func(index: int): owner.set_analog({field:index,"look_pair" if field == "movement_pair" else "movement_pair":1-index}); shell.schedule_render())
	for field: String in ["movement_deadzone","look_deadzone"]:
		var spin := SpinBox.new()
		spin.min_value = 0.0
		spin.max_value = 0.99
		spin.step = 0.01
		spin.prefix = field.capitalize().replace("_"," ") + " "
		spin.value = analog[field]
		host.panel.add_child(spin)
		spin.value_changed.connect(func(value: float): owner.set_analog({field:value}))
	for field: String in ["movement_invert","look_invert"]:
		var check := CheckBox.new()
		check.text = field.capitalize().replace("_"," ") + " Y"
		check.button_pressed = analog[field]
		host.panel.add_child(check)
		check.toggled.connect(func(value: bool): owner.set_analog({field:value}))
	host.label("View and cursor · live on Apply. Smoothing time is seconds.",16)
	for field: String in Configuration.editable_response():
		if draft.response[field] is String:
			var choice := OptionButton.new()
			choice.name = field
			choice.add_item(field.capitalize().replace("_"," ")+": Hold")
			choice.add_item(field.capitalize().replace("_"," ")+": Toggle")
			choice.selected = 0 if draft.response[field] == "hold" else 1
			host.panel.add_child(choice)
			choice.item_selected.connect(func(index: int): owner.set_response({field:"hold" if index == 0 else "toggle"}))
		elif draft.response[field] is bool:
			var check := CheckBox.new()
			check.name = field
			check.text = field.capitalize().replace("_"," ")
			check.button_pressed = draft.response[field]
			host.panel.add_child(check)
			check.toggled.connect(func(value: bool): owner.set_response({field:value}))
		else:
			var spin := SpinBox.new()
			spin.name = field
			var bounds: Vector2 = Configuration.response_bounds()[field]
			spin.min_value = bounds.x
			spin.max_value = bounds.y
			spin.step = 0.001 if field.begins_with("mouse") or field.ends_with("seconds") else 1.0
			spin.prefix = field.capitalize().replace("_"," ") + " "
			spin.value = draft.response[field]
			host.panel.add_child(spin)
			spin.value_changed.connect(func(value: float): owner.set_response({field:value}))
	host.button("Reset This Action",func(): owner.reset_action(action); shell.schedule_render())
	host.button("Reset All Controls",func(): owner.reset_all(); shell.schedule_render())
	host.button("Apply Controls",func(): owner.apply(); shell.schedule_render())
	host.button("Retry Save Controls",func(): owner.retry_save(); shell.schedule_render())
	host.button("Cancel / Close Controls",shell.close_controls)
	host.button("Quit",shell.request_quit)
