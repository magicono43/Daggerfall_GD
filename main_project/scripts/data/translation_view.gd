extends PanelContainer
## Bounded import/export console, not IMP-056's full authoring workbench.
const Import = preload("res://scripts/data/translation_import.gd")
const Author = preload("res://scripts/data/text_author.gd")
var host: Control
var service: RefCounted
var editor: TextEdit
var state_label: Label
var operations: VBoxContainer
var preview_id := -1
var selections: Dictionary = {}
var workspace: LineEdit
var record: SpinBox
var collection: LineEdit
var locale: LineEdit
var stable_key: LineEdit
var scope := ""
var gate := 0
var sample_context: LineEdit
var sample_variant: SpinBox
var sample_output: VBoxContainer
var layer_id := ""

func bind(shell: Control) -> void:
	host = shell
	scope = host.session_shell.core.snapshot().session
	layer_id = host.session_shell.windows.open("translation_authoring", scope).get("id", "")
	gate = host.session_shell.core.gates.acquire("translation-authoring", scope, ["simulation", "input", "admission"])
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("17212a")
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		background.set_content_margin(side, 20)
	add_theme_stylebox_override("panel", background)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	var title := Label.new()
	title.text = "Translation export / preview / selected commit · workspace is separate from installed content"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title)
	workspace = line(box, "Workspace stable ID (under selected root/Authoring)", "translation-work")
	collection = line(box, "Collection stable ID", "messages")
	locale = line(box, "Exact target locale", "en")
	stable_key = line(box, "Explicit stable key", "message")
	record = SpinBox.new()
	record.min_value = 0
	record.max_value = 65534
	record.value = 25
	box.add_child(record)
	button(box, "Export explicitly mapped TEXT.RSC record to editor", export_record)
	editor = TextEdit.new()
	editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	editor.custom_minimum_size = Vector2(300, 360)
	box.add_child(editor)
	editor.text_changed.connect(invalidate_preview)
	workspace.text_changed.connect(func(_value: String): invalidate_preview())
	button(box, "Load workspace as editable import document", load_workspace)
	button(box, "Preview document", preview_document)
	operations = VBoxContainer.new()
	box.add_child(operations)
	button(box, "Commit selected operations", commit_selected)
	state_label = Label.new()
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(state_label)
	sample_context = line(box, "Explicit literal sample context (JSON object; no providers)", "{}")
	sample_variant = SpinBox.new()
	sample_variant.min_value = 0
	sample_variant.max_value = 4095
	box.add_child(sample_variant)
	button(box, "Render explicit sample variant of first mapped entry", render_sample)
	sample_output = VBoxContainer.new()
	box.add_child(sample_output)
	button(box, "Close", close)

func line(box: VBoxContainer, placeholder: String, initial: String) -> LineEdit:
	var control := LineEdit.new()
	control.placeholder_text = placeholder
	control.tooltip_text = placeholder
	control.text = initial
	box.add_child(control)
	return control

func button(box: VBoxContainer, text: String, action: Callable) -> void:
	var control := Button.new()
	control.text = text
	control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control.custom_minimum_size.y = 42
	box.add_child(control)
	control.pressed.connect(action)

func get_service() -> bool:
	if not preload("res://scripts/mod/package_library.gd").valid_id(workspace.text):
		state_label.text = "Use a stable workspace ID; paths are not accepted."
		return false
	var root: String = host.controller.storage.context.root.path_join("Authoring").path_join(workspace.text)
	if service == null or service.root != root:
		service = Import.new(host.controller.storage.adapter, root)
		preview_id = -1
	return true

func export_record() -> void:
	var source: Dictionary = preload("res://scripts/data/structured_text.gd").read(host.controller.providers.classic, int(record.value))
	if not source.ok:
		state_label.text = JSON.stringify(source)
		return
	var ids: Array = source.variants.map(func(variant: Dictionary): return variant.id)
	var encoded := Author.encode(source.tokens, ids, [], source.source, stable_key.text)
	if not encoded.ok:
		state_label.text = JSON.stringify(encoded)
		return
	editor.text = JSON.stringify({"schema":Import.VERSION,"collection":collection.text,"locale":locale.text,"entries":[{"source_id":"TEXT.RSC:" + str(int(record.value)),"key":stable_key.text,"base":"en","optional":false,"essential":false,"required":[],"operation":"add","source":encoded.text,"translation":encoded.text,"provenance":{"source":source.source,"record":source.record,"offset":source.offset}}]}, "\t")
	state_label.text = "Exported to editor only. Edit literal strings; JSON whitespace is editorial. Percent/braces are literal. Preview before selecting writes."

func load_workspace() -> void:
	if not get_service():
		return
	var active: Dictionary = service.load_active()
	if not active.ok:
		state_label.text = JSON.stringify(active)
		return
	var entries: Array = active.snapshot.entries.values().filter(func(entry: Dictionary): return entry.collection == collection.text and entry.locale == locale.text)
	for entry: Dictionary in entries:
		entry.source = entry.get("current_source", entry.source)
		entry.required = entry.get("current_required", entry.required)
	editor.text = JSON.stringify({"schema":Import.VERSION,"collection":collection.text,"locale":locale.text,"entries":entries}, "\t")
	state_label.text = "Loaded authored work. No runtime state changed."

func preview_document() -> void:
	if not get_service():
		return
	var parser := JSON.new()
	if parser.parse(editor.text) != OK or not parser.data is Dictionary:
		state_label.text = "Invalid import document: " + parser.get_error_message()
		return
	var preview: Dictionary = service.preview(parser.data)
	for child in operations.get_children():
		child.free()
	selections.clear()
	preview_id = -1
	if preview.ok:
		preview_id = preview.id
		for key: String in preview.rows:
			var row: Dictionary = preview.rows[key]
			var select := CheckBox.new()
			select.text = key + " · " + row.kind + " · retain translation / record source review"
			select.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			select.custom_minimum_size.y = 44
			operations.add_child(select)
			select.toggled.connect(func(value: bool):
				if value: selections[key] = "preserve"
				else: selections.erase(key))
			if row.has("replace") and row.has_translation:
				var replace := CheckBox.new()
				replace.text = key + " · explicitly replace translation and mark reviewed"
				replace.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				replace.custom_minimum_size.y = 44
				operations.add_child(replace)
				replace.toggled.connect(func(value: bool):
					if value:
						select.set_pressed_no_signal(false)
						selections[key] = "replace"
					elif selections.get(key) == "replace": selections.erase(key))
				select.toggled.connect(func(value: bool):
					if value: replace.set_pressed_no_signal(false))
			var details := Label.new()
			details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			details.text = "Retained / added text:\n" + describe(row.preserve.translation, row.preserve.required)
			if row.has("replace"):
				details.text += "\nProposed replacement:\n" + describe(row.replace.translation, row.replace.required)
			details.text += "\nReview: " + row.preserve.review
			operations.add_child(details)
	state_label.text = "Preview ready. Select operations explicitly; unchecked entries remain untouched." if preview.ok else JSON.stringify(preview)

func describe(text: String, required: Array) -> String:
	var decoded := Author.decode(text, required)
	if not decoded.ok:
		return JSON.stringify(decoded)
	var result := "Variants: " + str(decoded.variant_ids) + "\n"
	for token: Dictionary in decoded.tokens:
		result += token.text if token.kind == "text" else "[" + token.kind + (" " + str(token.operand) if token.has("operand") else "") + "]"
	return result

func commit_selected() -> void:
	if not get_service() or preview_id < 0:
		state_label.text = "Preview before committing."
		return
	state_label.text = JSON.stringify(service.commit(preview_id, selections), "  ") + "\nAuthoring only: install CSV through normal configuration and restart."

func invalidate_preview() -> void:
	preview_id = -1
	selections.clear()
	if is_instance_valid(operations):
		for child in operations.get_children():
			child.queue_free()

func render_sample() -> void:
	for child in sample_output.get_children():
		child.free()
	var parser := JSON.new()
	if parser.parse(editor.text) != OK or not parser.data is Dictionary or not parser.data.get("entries") is Array or parser.data.entries.is_empty():
		state_label.text = "A valid mapped entry is required for sample rendering."
		return
	var document: Dictionary = parser.data
	var entry: Variant = document.entries[0]
	if not entry is Dictionary or not entry.get("translation") is String or not entry.get("required") is Array:
		state_label.text = "Missing authored translation / required context declaration."
		return
	var decoded := Author.decode(entry.translation, entry.required, str(entry.get("source_id", "")), str(entry.get("key", "")))
	if not decoded.ok:
		state_label.text = JSON.stringify(decoded)
		return
	if parser.parse(sample_context.text) != OK or not parser.data is Dictionary:
		state_label.text = "Sample context must be a literal JSON object."
		return
	var expanded := Author.sample(decoded, parser.data)
	if not expanded.ok:
		state_label.text = JSON.stringify(expanded)
		return
	var ordinal := int(sample_variant.value)
	if ordinal >= decoded.variant_ids.size():
		state_label.text = "Explicit variant unavailable; no neighboring variant selected."
		return
	var selected: Array = []
	var current := 0
	for token: Dictionary in expanded.tokens:
		if token.kind in ["variant_break", "record_end"]:
			if current == ordinal:
				selected.append({"kind":"record_end"})
				break
			current += 1
		elif current == ordinal:
			selected.append(token)
	var presentation: RefCounted = host.controller.providers.presentation
	var layout: Dictionary = preload("res://scripts/session/text_layout.gd").structure(selected, presentation, presentation.locale, maxf(220, size.x - 48))
	if not layout.ok:
		layout.source = entry.get("source_id", "")
		layout.key = entry.get("key", "")
		state_label.text = JSON.stringify(layout)
		return
	for block: Dictionary in layout.blocks:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.autowrap_trim_flags = 0
		if block.kind == "text":
			label.text = block.literal.text
			label.add_theme_font_override("font", block.literal.font)
			label.tooltip_text = JSON.stringify(block.literal.diagnostics)
		else:
			label.text = "[" + block.kind + "]"
		sample_output.add_child(label)
	state_label.text = "Pure sample · explicit authored variant " + str(decoded.variant_ids[ordinal])

func close() -> void:
	host.session_shell.core.gates.release(gate, "translation-authoring")
	host.session_shell.windows.close(layer_id, true)
	host.authoring_view = null
	queue_free()
	host.render()
