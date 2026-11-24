extends Control
## UI-006 read-only owner projection. A view never advances gameplay time.
const F = preload("res://scripts/rule/actor_formulas.gd")
var core: SessionLifecycle
var windows: RefCounted
var media: RefCounted
var scope := ""
var actor := ""
var _rows: VBoxContainer
var _details: VBoxContainer
var _status: Button
var _bars := {}
var _labels := {}
var _effects: HFlowContainer
var _order: Array = []
var _model: Dictionary = {}
var _last: Dictionary = {}
var _refreshing := false
var capacity := 8
var _configuration: Dictionary = {}
var _details_scroll: ScrollContainer
var _details_window := ""
var _effects_revision := -2
var _effects_cache: Dictionary = {}
var _rendered_effects_revision := -2
var _rendered_capacity := -1
var effect_rebuilds := 0
var _effects_available := false

func toggle_details() -> void:
	if _details_window.is_empty(): open_details()
	else: close_details()

func open_details() -> void:
	if windows == null or not _details_window.is_empty() or scope != core.snapshot().session or not core.snapshot().ready or not windows.top().is_empty(): return
	var opened: Dictionary = windows.open("vitals_details",scope,{"cursor":"visible"})
	if opened.kind != "applied": return
	_details_window = opened.id
	_details_scroll.visible = true
	_details_scroll.grab_focus()

func close_details() -> void:
	if _details_window.is_empty(): return
	var result: Dictionary = windows.close(_details_window)
	if result.kind in ["applied","stale"]:
		_details_window = ""
		_details_scroll.visible = false

func _ready() -> void:
	name = "VitalsEffects"
	z_index = 20
	resized.connect(queue_redraw)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	position = Vector2(18,0)
	custom_minimum_size = Vector2(280,0)
	size = custom_minimum_size
	_rows = VBoxContainer.new()
	_rows.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_rows)
	for id in ["health","fatigue","magicka","breath"]:
		var label := Label.new()
		label.name = id+"-label"
		label.text = id.capitalize()
		label.clip_text = true
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		_rows.add_child(label)
		_labels[id] = label
		var bar := ProgressBar.new()
		bar.name = id
		bar.show_percentage = false
		bar.step = 0.0
		bar.custom_minimum_size = Vector2(0,12)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color.WHITE # Replaced from checked DATA before the view is revealed.
		bar.add_theme_stylebox_override("fill",fill)
		_rows.add_child(bar)
		_bars[id] = bar
	_effects = HFlowContainer.new()
	_rows.add_child(_effects)
	_status = Button.new()
	_status.text = "Vitals and effects details"
	_status.clip_text = true
	_status.pressed.connect(toggle_details)
	_rows.add_child(_status)
	_details_scroll = ScrollContainer.new()
	_details_scroll.position = Vector2(300,-180)
	_details_scroll.size = Vector2(360,400)
	_details_scroll.visible = false
	_details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_details_scroll.focus_mode = Control.FOCUS_ALL
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.035,0.04,0.055,0.98)
	background.content_margin_left = 12
	background.content_margin_right = 12
	_details_scroll.add_theme_stylebox_override("panel",background)
	add_child(_details_scroll)
	_details = VBoxContainer.new()
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_scroll.add_child(_details)
	visible = false

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.025,0.035,0.055,0.98))

func bind(session: String, identity: String) -> bool:
	if core == null or not core.actors.vital_projection(session,identity).ok: return false
	if not _details_window.is_empty() and windows != null: windows.retire_layer(_details_window,scope)
	scope = session
	actor = identity
	core.gates.hud_bound = true
	var config: Dictionary = core.actors.definitions.query("actor.baseline","vitals","player")
	if not config.ok: return false
	_configuration = config.record.value.duplicate(true)
	capacity = int(_configuration.capacity)
	custom_minimum_size.x = _configuration.width
	size.x = _configuration.width
	if _configuration.anchor == "right":
		set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		position = Vector2(-size.x-18,-230)
		_details_scroll.position.x = -380
	for id: String in _configuration.order:
		var target: Dictionary = _configuration.targets[id]
		var color: Array = target.color
		_bars[id].get_theme_stylebox("fill").bg_color = Color(color[0],color[1],color[2],color[3])
		_bars[id].custom_minimum_size.y = target.height
		_rows.move_child(_labels[id],_rows.get_child_count()-1)
		_rows.move_child(_bars[id],_rows.get_child_count()-1)
	_rows.move_child(_effects,_rows.get_child_count()-1)
	_rows.move_child(_status,_rows.get_child_count()-1)
	_order.clear()
	_last.clear()
	_effects_revision = -2
	_rendered_effects_revision = -2
	_rendered_capacity = -1
	_effects_cache.clear()
	_details_scroll.visible = false
	_details_window = ""
	refresh()
	return true

func retire(session: String) -> void:
	if scope != session: return
	scope = ""
	actor = ""
	_order.clear()
	_model.clear()
	_last.clear()
	visible = false
	_details_scroll.visible = false
	_details_window = ""
	_effects_cache.clear()
	_effects_revision = -2
	for child in _effects.get_children(): child.queue_free()
	for child in _details.get_children(): child.queue_free()

static func groups_valid(value: Variant) -> bool:
	if not value is Dictionary or value.size() != 3 or value.get("schema") != "disclosed-effects-v1" or not F.integer(value.get("revision"),0,1000000000) or not value.get("groups") is Array or value.groups.size() > 4096: return false
	var seen := {}
	for group: Variant in value.groups:
		if not group is Dictionary or group.size() != 5 or not group.get("id") is String or group.id.is_empty() or group.id.length() > 128 or seen.has(group.id) or not group.get("label") is String or group.label.length() > 256 or not group.get("icon") is String or group.icon.length() > 1024 or typeof(group.get("compact")) != TYPE_BOOL or not group.get("components") is Array or group.components.size() > 256: return false
		seen[group.id] = true
		var ids := {}
		for c: Variant in group.components:
			if not c is Dictionary or c.size() != 6 or not c.get("id") is String or c.id.is_empty() or c.id.length() > 128 or ids.has(c.id) or not c.get("label") is String or c.label.length() > 256 or not c.get("lifetime") is String or c.lifetime.length() > 512 or typeof(c.get("effective")) != TYPE_BOOL or typeof(c.get("suppressed")) != TYPE_BOOL or typeof(c.get("warning")) != TYPE_BOOL or (c.effective and c.suppressed): return false
			ids[c.id] = true
	return true

static func warned(group: Dictionary) -> bool:
	for c: Dictionary in group.components:
		if c.effective and not c.suppressed and c.warning: return true
	return false

func refresh() -> void:
	if _refreshing or core == null or scope.is_empty(): return
	_refreshing = true
	var projection: Dictionary = core.actors.presentation_projection(scope,actor)
	if not projection.ok:
		retire(scope)
		_refreshing = false
		return
	visible = core.gates.hud_visible()
	_rows.visible = visible
	if windows != null:
		var top: Dictionary = windows.top()
		if not _details_window.is_empty() and not windows.layers().any(func(layer: Dictionary): return layer.id == _details_window): _details_window = ""
		_details_scroll.visible = not _details_window.is_empty() and top.get("id") == _details_window
		visible = visible or _details_scroll.visible
		_status.disabled = not core.snapshot().ready or (not top.is_empty() and top.get("id") != _details_window)
		for button: Button in _effects.get_children(): button.disabled = _status.disabled
	var area := get_viewport_rect().size
	var height := minf(area.y-36,maxf(180,_rows.get_combined_minimum_size().y))
	size.y = height
	position.y = area.y-height-18
	position.x = area.x-size.x-18 if _configuration.get("anchor") == "right" else 18.0
	_details_scroll.size = Vector2(minf(360,area.x-36),minf(400,area.y-36))
	_details_scroll.global_position = Vector2(clampf(global_position.x+size.x+18,18,maxf(18,area.x-_details_scroll.size.x-18)),maxf(18,area.y-_details_scroll.size.y-18))
	var revision := core.disclosed_effects_revision(scope,actor)
	if revision != _effects_revision:
		var disclosed: Dictionary = core.disclosed_effects(scope,actor) if revision >= 0 else {}
		_effects_available = groups_valid(disclosed) and disclosed.revision == revision
		if _effects_available:
			_effects_cache = disclosed
			_effects_revision = revision
		else:
			_effects_cache = {"schema":"disclosed-effects-v1","revision":0,"groups":[]}
			_effects_revision = revision
	var disclosed: Dictionary = _effects_cache
	if scope != core.snapshot().session:
		retire(scope)
		_refreshing = false
		return
	var state := {"current":projection.current,"maximum":projection.maximum,"breath":projection.breath,"effects_revision":_effects_revision,"viewport":area,"control_height":_status.get_combined_minimum_size().y}
	if state == _last:
		_model.vitals = projection.duplicate(true)
		_refreshing = false
		return
	_last = state.duplicate(true)
	for id: String in _bars:
		var maximum: int = projection.maximum[id]
		var amount: int = projection.current.get(id,0) if id != "breath" else projection.breath.reserve
		_bars[id].value = clampf(float(amount)/maximum,0,1)*100 if maximum > 0 else 0.0
		var target: Dictionary = _configuration.targets[id]
		_labels[id].text = "%s  %d / %d" % [target.label,amount,maximum]
		_labels[id].tooltip_text = _labels[id].text
		var shown: bool = target.visible and (id != "breath" or projection.breath.visible)
		_bars[id].visible = shown and _configuration.view == "stock-bars" and target.format == "bar"
		_labels[id].visible = shown
	var fixed_height: float = _status.get_combined_minimum_size().y+36
	for id: String in _bars:
		if _labels[id].visible: fixed_height += _labels[id].get_combined_minimum_size().y+4
		if _bars[id].visible: fixed_height += _bars[id].get_combined_minimum_size().y+4
	var row_height := maxf(28,_status.get_combined_minimum_size().y)+4
	var rows := maxi(0,int(floor((area.y-fixed_height)/row_height)))
	var columns := maxi(1,int(floor((size.x+4)/144)))
	var display_capacity := mini(capacity,maxi(0,rows*columns-1))
	_effects.visible = _configuration.effects_visible and rows > 0
	if not _effects.visible: display_capacity = 0
	_status.text = "Vitals and effects details" if _effects.visible or not _effects_available else "+%d  Vitals and effects details" % _order.size()
	if _rendered_effects_revision == _effects_revision and _rendered_capacity == display_capacity:
		for index in 4: _details.get_child(index).text = _labels[["health","fatigue","magicka","breath"][index]].text
		_model.vitals = projection.duplicate(true)
		_refreshing = false
		return
	_rendered_effects_revision = _effects_revision
	_rendered_capacity = display_capacity
	effect_rebuilds += 1
	var groups: Dictionary = {}
	for group: Dictionary in disclosed.groups:
		if group.compact: groups[group.id] = group
	var stable: Array = []
	var known := {}
	for id: String in _order:
		if groups.has(id):
			stable.append(id)
			known[id] = true
	var added: Array = []
	for id: String in groups:
		if not known.has(id): added.append(id)
	added.sort()
	stable.append_array(added)
	_order = []
	for warning: bool in [true,false]:
		for id: String in stable:
			if warned(groups[id]) == warning: _order.append(id)
	for child in _effects.get_children():
		_effects.remove_child(child)
		child.queue_free()
	for index in mini(display_capacity,_order.size()):
		var group: Dictionary = groups[_order[index]]
		var button := Button.new()
		button.text = ("! " if warned(group) else "")+group.label
		button.clip_text = true
		button.expand_icon = true
		button.custom_minimum_size = Vector2(minf(140,size.x),28)
		button.tooltip_text = group.label
		# Missing cosmetic artwork has a generated generic marker, no asset load.
		button.text = "◆ "+button.text
		if group.icon.begins_with("res://") and group.icon.get_extension().to_lower() in ["png","webp","jpg","svg"] and ResourceLoader.exists(group.icon,"Texture2D"):
			button.icon = load(group.icon) as Texture2D
		elif media != null and not group.icon.is_empty():
			var resolved: Dictionary = media.resolve(group.icon,"image")
			if resolved.get("ok",false) and resolved.get("resource",{}).get("image") is Image:
				button.icon = ImageTexture.create_from_image(resolved.resource.image)
		button.pressed.connect(open_details)
		_effects.add_child(button)
	if _order.size() > display_capacity:
		var overflow := Button.new()
		overflow.text = "+"+str(_order.size()-display_capacity)
		overflow.pressed.connect(open_details)
		_effects.add_child(overflow)
	_status.text = "Vitals and effects details" if _effects.visible or not _effects_available else "+%d  Vitals and effects details" % _order.size()
	for child in _details.get_children():
		_details.remove_child(child)
		child.queue_free()
	for id: String in ["health","fatigue","magicka","breath"]:
		var label := Label.new()
		label.text = _labels[id].text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_details.add_child(label)
	if not _effects_available:
		var unavailable := Label.new()
		unavailable.text = "Effects projection unavailable"
		_details.add_child(unavailable)
	for group: Dictionary in disclosed.groups:
		var label := Label.new()
		label.text = group.label
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_details.add_child(label)
		for c: Dictionary in group.components:
			var detail := Label.new()
			detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			detail.text = "%s: %s (%s)%s" % [c.label,c.lifetime,"suppressed" if c.suppressed else ("effective" if c.effective else "inactive")," — expiry warning" if c.effective and c.warning else ""]
			_details.add_child(detail)
	_model = {"order":_order.duplicate(),"overflow":maxi(0,_order.size()-display_capacity),"vitals":projection.duplicate(true),"effects":disclosed,"effects_available":_effects_available}
	_refreshing = false

func projection() -> Dictionary:
	return _model.duplicate(true)
