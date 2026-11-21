extends PanelContainer
## Small production editor. Locale refresh updates labels in place, never controls.
var host: Control
var preferences: RefCounted
var presentation: RefCounted
var selected := ""
var box: VBoxContainer
var fields: Dictionary = {}
var captions: Array = []
var state_label: Label
var confirmation: HBoxContainer
var scope := ""
var gate := 0
var closing := false
var layer_id := ""
var window_context := -1
var language_choice: OptionButton

func bind(shell: Control, preferences: RefCounted, text_owner: RefCounted) -> void:
	host = shell
	self.preferences = preferences
	presentation = text_owner
	scope = host.session_shell.core.snapshot().session
	var opened: Dictionary = host.session_shell.windows.open("mod_preferences", scope)
	layer_id = opened.get("id", "")
	window_context = host.session_shell.windows.context_generation
	gate = host.session_shell.core.gates.acquire("mod-preferences", scope, ["simulation", "input", "admission"])
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("17212a")
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		background.set_content_margin(side, 20)
	add_theme_stylebox_override("panel", background)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)
	scroll.add_child(box)
	var title := Label.new()
	title.text = "Mod Preferences · Apply accepts groups; Cancel discards unapplied edits"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title)
	var mods := OptionButton.new()
	var ids: Array = preferences.stores.keys()
	ids.sort()
	for id: String in ids:
		mods.add_item(id)
	box.add_child(mods)
	mods.item_selected.connect(func(index: int): selected = ids[index]; rebuild())
	var language_row := HBoxContainer.new()
	box.add_child(language_row)
	language_choice = OptionButton.new()
	language_choice.custom_minimum_size.x = 160
	language_choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if presentation != null:
		for locale: String in presentation.available():
			language_choice.add_item(locale)
			if locale == presentation.locale:
				language_choice.select(language_choice.item_count - 1)
	language_row.add_child(language_choice)
	button("Apply language (live)", func():
		if language_choice.selected >= 0:
			var result: Dictionary = host.controller.settings.apply({"presentation/locale":language_choice.get_item_text(language_choice.selected)}, presentation.apply)
			refresh_state()
			if not result.get("rejected", []).is_empty():
				state_label.text += "\nLanguage rejected; previous working language retained."
			elif not result.ok:
				state_label.text += "\nLanguage applied, not saved. Retry saving.", language_row)
	button("Retry language save", func():
		var result: Dictionary = host.controller.settings.save_accepted()
		refresh_state()
		state_label.text += "\nLanguage saved." if result.ok else "\nLanguage is still not saved.", language_row)
	if not ids.is_empty():
		selected = ids[0]
	if presentation != null:
		presentation.bind_view(self)
	rebuild()

func localized(ref: Dictionary, locale: String) -> String:
	if presentation == null:
		return "<Missing text %s/%s>" % [ref.collection, ref.key]
	var result: Dictionary = presentation.lookup(ref.collection, ref.key, locale)
	var text := ""
	for token: Dictionary in result.get("tokens", []):
		if token.kind == "record_end":
			continue
		if token.kind not in ["text", "line_break"]:
			return "<Unsupported preference label %s/%s>" % [ref.collection, ref.key]
		text += "\n" if token.kind == "line_break" else token.text
	return result.get("text", "") if text.is_empty() else text

func caption(ref: Dictionary) -> void:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.autowrap_trim_flags = 0
	box.add_child(label)
	captions.append({"label":label,"ref":ref.duplicate(true)})

func button(text: String, action: Callable, parent: Node = null) -> Button:
	var control := Button.new()
	control.text = text
	control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control.custom_minimum_size = Vector2(160, 42)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	(parent if parent != null else box).add_child(control)
	control.pressed.connect(func():
		if action == close or context_current():
			action.call())
	return control

func rebuild() -> void:
	# Only explicit mod selection rebuilds controls. Locale changes never do.
	while box.get_child_count() > 3:
		box.get_child(3).free()
	fields.clear()
	captions.clear()
	if selected.is_empty():
		var empty := Label.new()
		empty.text = "No active package exposes editable preferences. Installed definitions remain locked."
		box.add_child(empty)
	else:
		var definition: Dictionary = preferences.stores[selected].definition
		caption(definition.name)
		caption(definition.description)
		for key: String in definition.settings:
			var spec: Dictionary = definition.settings[key]
			caption(spec.name)
			caption(spec.description)
			var control: Control
			match spec.type:
				"bool":
					control = CheckBox.new()
					control.toggled.connect(func(value: bool): preferences.edit(selected, key, value); refresh_state())
				"int":
					control = SpinBox.new()
					control.min_value = spec.min
					control.max_value = spec.max
					control.step = 1
					control.value_changed.connect(func(value: float): preferences.edit(selected, key, int(value)); refresh_state())
				"string":
					if not spec.get("choices", []).is_empty():
						control = OptionButton.new()
						for choice: String in spec.choices:
							control.add_item(choice)
						control.item_selected.connect(func(index: int): preferences.edit(selected, key, spec.choices[index]); refresh_state())
					else:
						control = LineEdit.new()
						control.max_length = spec.max_length
						control.text_changed.connect(func(value: String): preferences.edit(selected, key, value); refresh_state())
			control.custom_minimum_size = Vector2(220, 42)
			box.add_child(control)
			fields[key] = control
		for id: String in definition.presets:
			caption(definition.presets[id].name)
			caption(definition.presets[id].description)
			button("Stage preset · " + id, func(): preferences.preset(selected, id); update_fields())
		button("Reset to Defaults…", func():
			preferences.request_reset(selected)
			confirmation.visible = true)
		confirmation = HBoxContainer.new()
		box.add_child(confirmation)
		confirmation.visible = preferences.reset_confirmation == selected
		button("Confirm reset (stage only)", func(): preferences.confirm_reset(selected, true); confirmation.hide(); update_fields(), confirmation)
		button("Keep existing edits", func(): preferences.confirm_reset(selected, false); confirmation.hide(), confirmation)
		button("Apply", func(): preferences.apply(selected); update_fields())
		button("Retry saving accepted values", func(): preferences.retry(selected); refresh_state())
	state_label = Label.new()
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(state_label)
	button("Cancel / Close", close)
	update_fields()
	if presentation != null:
		var plan := prepare_locale(presentation.locale)
		if plan.ok:
			commit_locale(plan)

func update_fields() -> void:
	if selected.is_empty():
		return
	var values: Dictionary = preferences.projection(selected).values
	for key: String in fields:
		var control: Control = fields[key]
		var value: Variant = values[key].staged
		if control is CheckBox:
			control.set_pressed_no_signal(value)
		elif control is SpinBox:
			control.set_value_no_signal(value)
		elif control is OptionButton:
			for index in control.item_count:
				if control.get_item_text(index) == value:
					control.select(index)
		else:
			control.text = value
	refresh_state()

func refresh_state() -> void:
	if is_instance_valid(state_label):
		var projection: Dictionary = preferences.projection(selected)
		if projection.is_empty():
			state_label.text = ""
			return
		var lines: Array[String] = []
		for key: String in projection.values:
			var value: Dictionary = projection.values[key]
			lines.append("%s · staged: %s · accepted: %s · saved: %s · effective: %s · %s" % [key, value.staged, value.accepted, value.persisted, value.effective, value.timing.replace("_", " ")])
		lines.append("Accepted changes are not saved. Retry saving." if projection.unsaved else "Accepted values saved.")
		if not projection.pending.is_empty():
			lines.append("Pending activation: " + ", ".join(projection.pending))
		if not projection.status.get("rejected", []).is_empty():
			lines.append("Rejected groups retained their previous values: " + ", ".join(projection.status.rejected))
		if projection.status.get("kind") == "rejected":
			lines.append("Apply rejected: staged values violate the setting/group constraints.")
		if projection.recovery.get("kind") == "recovered":
			lines.append(projection.recovery.detail)
		state_label.text = "\n".join(lines)

func prepare_locale(locale: String) -> Dictionary:
	if not context_current():
		return {"ok":false}
	var labels: Array = []
	for entry: Dictionary in captions:
		labels.append(presentation.literal(localized(entry.ref, locale), "body", locale, "", entry.ref))
	return {"ok":true,"scope":scope,"labels":labels,"font":presentation.font("body", locale)}

func locale_plan_current(plan: Dictionary) -> bool:
	return plan.scope == scope and context_current()

func context_current() -> bool:
	return not closing and host.session_shell.core.snapshot().session == scope and not host.session_shell.core.busy() and host.session_shell.windows.top().get("id", "") == layer_id and host.session_shell.windows.context_generation == window_context

func commit_locale(plan: Dictionary) -> void:
	for index in captions.size():
		captions[index].label.text = plan.labels[index].text
		captions[index].label.add_theme_font_override("font", plan.labels[index].font)
		captions[index].label.tooltip_text = JSON.stringify(plan.labels[index].diagnostics)
	add_theme_font_override("font", plan.font)

func close() -> void:
	if closing:
		return
	closing = true
	for id: String in preferences.stores:
		preferences.cancel(id)
	if presentation != null:
		presentation.unbind_view(self)
	host.session_shell.core.gates.release(gate, "mod-preferences")
	host.session_shell.windows.close(layer_id, true)
	host.preference_view = null
	queue_free()
	host.render()
