extends RefCounted
## Application lifetime. Only detached values cross the editor/settings boundary.
const Catalog = preload("res://scripts/input/action_bindings.gd")
const SETTING := "controls/configuration"
const FAMILIES := ["keyboard", "controller"]
var settings: StartupSettingsOwner
var _effective: Dictionary = {}
var _draft: Dictionary = {}
var _pending: Dictionary = {}
var _consumers: Array = []
var notices: Array[String] = []
var status := ""
var _recovered: Array[String] = []
var _ui_bindings: RefCounted

# Stable supported action identities, including actions with no stock binding.
const ACTIONS := ["forward", "backward", "strafe_left", "strafe_right", "turn_left", "turn_right", "look_up", "look_down", "center_view", "float_up", "float_down", "jump", "cursor_toggle", "ready_weapon", "switch_hand", "spellbook", "recast", "abort_spell", "magic_item", "rest", "transport", "steal_mode", "grab_mode", "info_mode", "talk_mode", "character", "inventory", "status", "journal", "notebook", "automap", "travel", "screenshot", "quicksave", "quickload", "console", "hud_toggle", "crouch", "run", "sneak", "activate", "attack", "autorun", "slide", "ui_confirm", "ui_back"]

static func inventory() -> Array:
	return ACTIONS.duplicate()

static func context(action: String) -> String:
	return "ui" if action.begins_with("ui_") else "gameplay"

static func defaults() -> Dictionary:
	var actions := {}
	for action: String in inventory(): actions[action] = {"keyboard":[{},{}], "controller":[{},{}]}
	for entry: Dictionary in Catalog.defaults():
		var value := entry.duplicate(true)
		value.erase("action")
		actions[entry.action]["controller" if entry.kind == "button" else "keyboard"][0] = value
	actions.ui_confirm.controller[0] = {"kind":"button", "code":JOY_BUTTON_A}
	actions.ui_back.controller[0] = {"kind":"button", "code":JOY_BUTTON_B}
	return {"version":1, "actions":actions, "analog":{"movement_pair":0, "look_pair":1, "movement_deadzone":0.15, "look_deadzone":0.10, "movement_invert":false, "look_invert":false}, "response":response_defaults()}

static func response_defaults() -> Dictionary:
	# Live view response; gait/posture remain retained until their owners exist.
	return {"mouse_smoothing_seconds":0.08,"controller_smoothing_seconds":0.08,"keyboard_smoothing_seconds":0.08,"mouse_x":0.10,"mouse_y":0.10,"mouse_invert":false,"mouse_smoothing":false,"controller_x":180.0,"controller_y":120.0,"controller_invert":false,"controller_smoothing":false,"keyboard_look":90.0,"keyboard_smoothing":false,"pitch_limit":89.0,"cursor_speed":800.0,"trigger_press":0.55,"trigger_release":0.45,"run_mode":"hold","sneak_mode":"hold","crouch_mode":"toggle","gait_bob_percent":50.0,"mounted_bob_percent":50.0,"landing_camera_percent":0.0,"movement_audio_percent":100.0}

static func response_bounds() -> Dictionary:
	return {"mouse_x":Vector2(0.001,10.0),"mouse_y":Vector2(0.001,10.0),"controller_x":Vector2(1.0,1440.0),"controller_y":Vector2(1.0,1440.0),"keyboard_look":Vector2(1.0,1440.0),"cursor_speed":Vector2(1.0,5000.0),"mouse_smoothing_seconds":Vector2(0.001,1.0),"controller_smoothing_seconds":Vector2(0.001,1.0),"keyboard_smoothing_seconds":Vector2(0.001,1.0),"gait_bob_percent":Vector2(0,100),"mounted_bob_percent":Vector2(0,100),"landing_camera_percent":Vector2(0,100),"movement_audio_percent":Vector2(0,100)}

static func editable_response() -> Array:
	return response_bounds().keys() + ["mouse_invert","controller_invert","mouse_smoothing","controller_smoothing","keyboard_smoothing","run_mode","sneak_mode","crouch_mode"]

func declare_settings(owner: StartupSettingsOwner) -> void:
	settings = owner
	owner.declare(SETTING, defaults(), TYPE_DICTIONARY, "live", valid)
	owner.declare_upgrade(SETTING, upgrade_settings)
	owner.declare_format_guard(SETTING, compatible_format)

static func compatible_format(value: Variant) -> bool:
	return not (value is Dictionary and value.get("version") is int and value.version != 1)

func upgrade_settings(value: Variant) -> Dictionary:
	_recovered.clear()
	var result: Variant = upgrade(value)
	return {"value":result,"resets":_recovered.duplicate()}

func load_effective() -> void:
	_effective = settings.effective[SETTING].duplicate(true)
	_ui_bindings = Catalog.new(entries(_effective,"ui"))
	for consumer in _consumers: consumer.configure(_effective)

func attach(consumer: RefCounted) -> bool:
	if _consumers.has(consumer): return true
	if not _effective.is_empty() and not consumer.configure(_effective): return false
	_consumers.append(consumer)
	return true

func detach(consumer: RefCounted) -> void:
	_consumers.erase(consumer)

func dispose() -> void:
	_consumers.clear()
	settings = null

func effective() -> Dictionary: return _effective.duplicate(true)
func resolve_ui(kind: String, code: int) -> String:
	return "" if _ui_bindings == null else _ui_bindings.resolve(kind,code,0,[])
func draft() -> Dictionary: return _draft.duplicate(true)
func pending() -> Dictionary: return _pending.duplicate(true)
func begin() -> void:
	_draft = effective()
	_pending.clear()
	status = "Edits are staged. Escape and controller Start always recover controls."
func cancel() -> void:
	_draft.clear()
	_pending.clear()
	status = "Draft discarded."

static func input_error(value: Variant, family: String) -> String:
	if not value is Dictionary: return "A binding must be a dictionary."
	if value.is_empty(): return ""
	for key: Variant in value:
		if key not in ["kind","code","location","modifier"]: return "Unsupported binding field: " + str(key)
	if not value.get("kind") is String or not value.get("code") is int: return "Input kind and integer identity are required."
	var kind: String = value.kind
	var code: int = value.code
	if family == "keyboard":
		if kind not in ["key","mouse"]: return "Choose a physical key or mouse button."
		if kind == "key" and (code <= 0 or OS.get_keycode_string(code).is_empty()): return "Unsupported physical key."
		if kind == "key" and code == KEY_ESCAPE: return "Escape is reserved for recovery."
		if kind == "mouse" and (code < MOUSE_BUTTON_LEFT or code > MOUSE_BUTTON_XBUTTON2): return "Unsupported mouse button."
	else:
		if kind not in ["button","trigger"]: return "Choose one controller button or trigger."
		if kind == "button" and (code < 0 or code >= JOY_BUTTON_MAX): return "Unsupported controller button."
		if kind == "button" and code == JOY_BUTTON_START: return "Start is reserved for recovery."
		if kind == "trigger" and code not in [JOY_AXIS_TRIGGER_LEFT,JOY_AXIS_TRIGGER_RIGHT]: return "Only the two triggers are discrete axes."
	var location: Variant = value.get("location",0)
	if not location is int or location not in [0,KEY_LOCATION_LEFT,KEY_LOCATION_RIGHT]: return "Invalid key side."
	if kind == "key" and code in [KEY_SHIFT,KEY_CTRL,KEY_ALT]:
		if location == 0: return "Choose explicitly left or right modifier."
	elif location != 0: return "Only modifier keys have a side."
	var modifier: Variant = value.get("modifier", "")
	if not modifier is String: return "Unsupported modifier."
	if not modifier.is_empty():
		if family != "keyboard" or modifier not in modifier_inventory(): return "Choose one left/right Shift, Ctrl or Alt modifier."
		if kind == "key" and code in [KEY_SHIFT,KEY_CTRL,KEY_ALT]: return "A modifier cannot also be the main key of a chord."
	return ""

static func modifier_inventory() -> Array:
	var result: Array = []
	for code: int in [KEY_SHIFT,KEY_CTRL,KEY_ALT]:
		for side: int in [KEY_LOCATION_LEFT,KEY_LOCATION_RIGHT]: result.append("%d:%d" % [code,side])
	return result

static func collides(a: Dictionary, b: Dictionary) -> bool:
	if a.is_empty() or b.is_empty(): return false
	if a.kind != b.kind or a.code != b.code: return false
	if a.get("location",0) != b.get("location",0): return false
	var am: String = a.get("modifier", "")
	var bm: String = b.get("modifier", "")
	# Plain + chord is intentional precedence. Distinct chords can both be held,
	# so they are ambiguous and must be resolved explicitly.
	return am == bm or (not am.is_empty() and not bm.is_empty())

static func conflicts(candidate: Dictionary) -> Array:
	var used: Array = []
	var result: Array = []
	for action: String in inventory():
		for family: String in FAMILIES:
			for slot: int in 2:
				var value: Dictionary = candidate.actions[action][family][slot]
				var current := {"action":action,"family":family,"slot":slot,"binding":value}
				for prior: Dictionary in used:
					if prior.family == family and context(prior.action) == context(action) and collides(prior.binding,value):
						result.append({"first":prior,"second":current})
				used.append(current)
	return result

static func validate(candidate: Variant) -> Dictionary:
	if not candidate is Dictionary or not candidate.get("version") is int or candidate.version != 1 or not candidate.get("actions") is Dictionary or not candidate.get("analog") is Dictionary:
		return {"ok":false,"reason":"Unsupported controls configuration."}
	for action: String in inventory():
		var record: Variant = candidate.actions.get(action)
		if not record is Dictionary: return {"ok":false,"reason":"Missing action: " + action}
		for family: String in FAMILIES:
			var slots: Variant = record.get(family)
			if not slots is Array or slots.size() != 2: return {"ok":false,"reason":"Two slots required: " + action}
			for value: Variant in slots:
				if context(action) == "ui" and family == "keyboard" and value is Dictionary and not value.is_empty(): return {"ok":false,"reason":"UI keyboard recovery/navigation is independent; edit controller UI slots only."}
				var reason := input_error(value, family)
				if not reason.is_empty(): return {"ok":false,"reason":action + ": " + reason}
	var analog: Dictionary = candidate.analog
	for field: String in ["movement_pair","look_pair"]:
		if not analog.get(field) is int or analog[field] not in [0,1]: return {"ok":false,"reason":"Choose left or right stick axis pair."}
	if analog.movement_pair == analog.look_pair: return {"ok":false,"reason":"Movement and look must use distinct axis pairs."}
	for field: String in ["movement_deadzone","look_deadzone"]:
		if typeof(analog.get(field)) not in [TYPE_FLOAT,TYPE_INT] or not is_finite(float(analog[field])) or analog[field] < 0.0 or analog[field] >= 1.0: return {"ok":false,"reason":"Deadzones must be finite and in [0, 1)."}
	for field: String in ["movement_invert","look_invert"]:
		if not analog.get(field) is bool: return {"ok":false,"reason":"Axis inversion must be boolean."}
	if not candidate.get("response") is Dictionary: return {"ok":false,"reason":"Missing retained response preferences."}
	var responses := response_defaults()
	for field: String in responses:
		var baseline: Variant = responses[field]
		var value: Variant = candidate.response.get(field)
		if typeof(value) != typeof(baseline): return {"ok":false,"reason":"Invalid response preference: " + field}
		if value is float and (not is_finite(value) or value < 0.0 or (value == 0.0 and not field.ends_with("_percent"))): return {"ok":false,"reason":"Invalid response rate: " + field}
		if value is String and value not in ["hold","toggle"]: return {"ok":false,"reason":"Unsupported input mode: " + field}
		if field in editable_response():
			if response_bounds().has(field):
				var bounds: Vector2 = response_bounds()[field]
				if value < bounds.x or value > bounds.y: return {"ok":false,"reason":"Response out of range: " + field}
		elif value != baseline: return {"ok":false,"reason":"Response/mode editing awaits its consuming increment: " + field}
	if candidate.response.pitch_limit >= 90.0 or candidate.response.trigger_press > 1.0 or candidate.response.trigger_release >= candidate.response.trigger_press: return {"ok":false,"reason":"Invalid pitch or trigger thresholds."}
	var overlap := conflicts(candidate)
	return {"ok":overlap.is_empty(),"reason":"Resolve overlapping input assignments with Replace or Cancel." if not overlap.is_empty() else "", "conflicts":overlap}

static func valid(candidate: Variant) -> bool: return validate(candidate).ok

func upgrade(value: Variant) -> Variant:
	# Unknown actions/fields round-trip, never enter the runtime catalog. Empty
	# slots are explicit choices; only missing action identities receive defaults.
	if not value is Dictionary or value.get("version") != 1 or not value.get("actions") is Dictionary: return value
	var result: Dictionary = value.duplicate(true)
	var baseline := defaults()
	if not result.has("response"): result.response = response_defaults()
	if result.response is Dictionary:
		for field: String in baseline.response:
			if not result.response.has(field): result.response[field] = baseline.response[field]
	var response_probe := baseline.duplicate(true)
	response_probe.response = result.response
	if not valid(response_probe):
		if not result.response is Dictionary: result.response = {}
		for field: String in baseline.response: result.response[field] = baseline.response[field]
		_recovered.append("controls/response")
	var missing: Array = []
	var damaged: Array = []
	for action: String in inventory():
		if not result.actions.has(action):
			result.actions[action] = {"keyboard":[{},{}],"controller":[{},{}]}
			missing.append(action)
		else:
			var record: Variant = result.actions[action]
			var usable := record is Dictionary
			if usable:
				for family: String in FAMILIES:
					var slots: Variant = record.get(family)
					if not slots is Array or slots.size() != 2:
						usable = false
						continue
					for binding: Variant in slots:
						if not input_error(binding,family).is_empty() or (context(action) == "ui" and family == "keyboard" and binding is Dictionary and not binding.is_empty()): usable = false
			if not usable:
				result.actions[action] = baseline.actions[action].duplicate(true)
				damaged.append(action)
	# Analog settings form a separate compatible group from discrete assignments.
	var probe := baseline.duplicate(true)
	probe.analog = result.get("analog")
	if not valid(probe):
		result.analog = baseline.analog.duplicate(true)
		_recovered.append("controls/analog")
	# Expand the incompatible binding group until its defaults are coherent. All
	# unrelated valid custom actions remain intact; unknown actions are untouched.
	var overlap := conflicts(result)
	while not overlap.is_empty():
		for pair: Dictionary in overlap:
			for entry: Dictionary in [pair.first,pair.second]:
				if not damaged.has(entry.action): damaged.append(entry.action)
		for action: String in damaged: result.actions[action] = baseline.actions[action].duplicate(true)
		overlap = conflicts(result)
	for action: String in damaged: _recovered.append("controls/" + action)
	for action: String in missing:
		result.actions[action] = baseline.actions[action].duplicate(true)
		if not conflicts(result).is_empty():
			result.actions[action] = {"keyboard":[{},{}],"controller":[{},{}]}
			var notice := "New action %s left unbound because its default conflicts." % action
			if not notices.has(notice): notices.append(notice)
	return result

func propose(action: String, family: String, slot: int, value: Dictionary) -> Dictionary:
	if _draft.is_empty() or action not in inventory() or family not in FAMILIES or slot not in [0,1]: return {"ok":false,"reason":"Invalid binding target."}
	var reason := input_error(value,family)
	if not reason.is_empty():
		status = reason
		return {"ok":false,"reason":reason}
	var candidate := draft()
	candidate.actions[action][family][slot] = value.duplicate(true)
	return _stage(candidate)

func _stage(candidate: Dictionary) -> Dictionary:
	_pending.clear()
	var checked := validate(candidate)
	if not checked.ok:
		if not checked.get("conflicts",[]).is_empty():
			_pending = {"candidate":candidate.duplicate(true),"conflicts":checked.conflicts.duplicate(true)}
		status = checked.reason
		return checked
	_draft = candidate.duplicate(true)
	status = "Staged. Unbound actions remain available for assignment."
	return {"ok":true}

func resolve_replace(replace: bool) -> Dictionary:
	if _pending.is_empty(): return {"ok":false,"reason":"No pending conflict."}
	if not replace:
		_pending.clear()
		status = "Assignment cancelled; draft unchanged."
		return {"ok":true}
	var candidate: Dictionary = _pending.candidate.duplicate(true)
	# Keep changed assignments; explicitly clear the old assignments they replace.
	# A reset can have multiple collisions, all shown before this operation.
	for pair: Dictionary in _pending.conflicts:
		var a: Dictionary = pair.first
		var b: Dictionary = pair.second
		var a_changed: bool = candidate.actions[a.action][a.family][a.slot] != _draft.actions[a.action][a.family][a.slot]
		var victim: Dictionary = b if a_changed else a
		candidate.actions[victim.action][victim.family][victim.slot] = {}
	return _stage(candidate)

func reset_action(action: String) -> Dictionary:
	if _draft.is_empty() or action not in inventory(): return {"ok":false}
	var candidate := draft()
	for family: String in FAMILIES: candidate.actions[action][family] = defaults().actions[action][family].duplicate(true)
	return _stage(candidate)

func reset_all() -> Dictionary:
	var candidate := draft()
	var baseline := defaults()
	for action: String in inventory():
		for family: String in FAMILIES: candidate.actions[action][family] = baseline.actions[action][family].duplicate(true)
	for field: String in baseline.analog: candidate.analog[field] = baseline.analog[field]
	for field: String in baseline.response: candidate.response[field] = baseline.response[field]
	return _stage(candidate)

func set_analog(edits: Dictionary) -> Dictionary:
	var candidate := draft()
	if candidate.is_empty(): return {"ok":false}
	for field: String in edits:
		if not candidate.analog.has(field): return {"ok":false,"reason":"Unknown analog preference."}
		candidate.analog[field] = edits[field]
	return _stage(candidate)

func set_response(edits: Dictionary) -> Dictionary:
	var candidate := draft()
	if candidate.is_empty(): return {"ok":false}
	for field: String in edits:
		if field not in editable_response(): return {"ok":false,"reason":"No current response consumer: " + field}
		candidate.response[field] = edits[field]
	return _stage(candidate)

func _publish(values: Dictionary) -> bool:
	var candidate: Dictionary = values[SETTING].duplicate(true)
	if not valid(candidate): return false
	# Consumers implement validate-before-mutation configure. Validate every one
	# before changing any; publication is synchronous and emits no mixed-map event.
	for consumer in _consumers:
		if not consumer.can_configure(candidate): return false
	for consumer in _consumers: consumer.configure(candidate)
	_effective = candidate
	_ui_bindings = Catalog.new(entries(candidate,"ui"))
	return true

func apply() -> Dictionary:
	var checked := validate(_draft)
	if not checked.ok or not _pending.is_empty():
		status = checked.reason if not checked.ok else "Resolve pending conflict first."
		return {"ok":false,"application":"rejected","reason":status}
	var result := settings.apply({SETTING:draft()},_publish)
	var applied: bool = result.get("application") == "accepted" and settings.effective.get(SETTING) == _draft and _effective == _draft
	result.applied = applied
	status = ("Controls applied and saved." if result.ok else "Controls applied in memory but UNSAVED. Retry Save.") if applied else "Controls rejected; previous effective controls retained."
	return result

func retry_save() -> Dictionary:
	var result := settings.save_accepted()
	status = "Effective controls saved." if result.ok else "Effective controls remain UNSAVED. Retry Save."
	return result

static func entries(configuration: Dictionary, which_context := "gameplay") -> Array:
	var result: Array = []
	for action: String in inventory():
		if context(action) != which_context: continue
		for family: String in FAMILIES:
			for value: Dictionary in configuration.actions[action][family]:
				if value.is_empty(): continue
				var entry := value.duplicate(true)
				entry.action = action
				result.append(entry)
	return result

static func label(value: Dictionary) -> String:
	if value.is_empty(): return "Unbound"
	var result := ""
	if value.kind == "key":
		var displayed: int = value.code if DisplayServer.get_name() == "headless" else DisplayServer.keyboard_get_keycode_from_physical(value.code)
		result = OS.get_keycode_string(displayed)
		if value.code in [KEY_SHIFT,KEY_CTRL,KEY_ALT]: result = ("Left " if value.get("location") == KEY_LOCATION_LEFT else "Right ") + result
	else: result = "%s %d" % [str(value.kind).capitalize(),value.code]
	if not value.get("modifier", "").is_empty():
		var parts: PackedStringArray = value.modifier.split(":")
		result = ("Left " if int(parts[1]) == KEY_LOCATION_LEFT else "Right ") + OS.get_keycode_string(int(parts[0])) + " + " + result
	return result
