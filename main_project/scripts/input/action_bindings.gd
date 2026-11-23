extends RefCounted
## Physical identities. Application editing/persistence is staged for increment 2.
var _index: Dictionary = {}

func _init(entries: Array = defaults()) -> void:
	for entry: Dictionary in entries:
		var key := "%s:%d" % [entry.kind, entry.code]
		if not _index.has(key): _index[key] = []
		_index[key].append(entry.duplicate(true))

func resolve(kind: String, code: int, location: int, modifiers: Array) -> String:
	var plain := ""
	for entry: Dictionary in _index.get("%s:%d" % [kind, code], []):
		if entry.get("location", 0) != 0 and entry.location != location: continue
		var modifier: String = entry.get("modifier", "")
		if not modifier.is_empty():
			if modifiers.has(modifier): return entry.action
		else: plain = entry.action
	return plain

static func defaults() -> Array:
	var entries: Array = []
	var keys := {
		KEY_W:"forward", KEY_S:"backward", KEY_A:"strafe_left", KEY_D:"strafe_right",
		KEY_LEFT:"turn_left", KEY_RIGHT:"turn_right", KEY_INSERT:"look_up", KEY_DELETE:"look_down",
		KEY_HOME:"center_view", KEY_PAGEUP:"float_up", KEY_PAGEDOWN:"float_down", KEY_SPACE:"jump",
		KEY_ENTER:"cursor_toggle", KEY_X:"ready_weapon", KEY_Z:"switch_hand", KEY_F:"spellbook",
		KEY_Q:"recast", KEY_C:"abort_spell", KEY_G:"magic_item", KEY_R:"rest", KEY_T:"transport",
		KEY_1:"steal_mode", KEY_2:"grab_mode", KEY_3:"info_mode", KEY_4:"talk_mode",
		KEY_N:"character", KEY_B:"inventory", KEY_H:"status", KEY_K:"journal", KEY_J:"notebook",
		KEY_V:"automap", KEY_M:"travel", KEY_F8:"screenshot", KEY_F9:"quicksave", KEY_F11:"quickload",
		KEY_QUOTELEFT:"console", KEY_F7:"hud_toggle"}
	for code: int in keys: entries.append({"kind":"key", "code":code, "action":keys[code]})
	for pair: Array in [[KEY_CTRL,"crouch"],[KEY_SHIFT,"run"],[KEY_ALT,"sneak"]]:
		entries.append({"kind":"key", "code":pair[0], "location":KEY_LOCATION_LEFT, "action":pair[1]})
	for pair: Array in [[MOUSE_BUTTON_LEFT,"activate"],[MOUSE_BUTTON_RIGHT,"attack"],[MOUSE_BUTTON_MIDDLE,"autorun"]]:
		entries.append({"kind":"mouse", "code":pair[0], "action":pair[1]})
	# DFU numbered button baseline, not additional proposed gameplay buttons.
	for pair: Array in [[0,"activate"],[3,"attack"],[2,"autorun"]]:
		entries.append({"kind":"button", "code":pair[0], "action":pair[1]})
	return entries
