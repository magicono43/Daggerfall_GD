extends RefCounted
## Presentation-only topics. Catalog overrides precede the mapped classic text;
## the small locale cache expires with the creation draft.
const TOPICS = [
	["attributes","Attributes",2402], ["class-name","Class Name",2401],
	["general","General",2400], ["reputations","Reputations",2406],
	["skill-advancement","Skill Advancement",2407], ["skills","Skills",2403],
	["advantages","Special Advantages",2404], ["disadvantages","Special Disadvantages",2405]]
const Text = preload("res://scripts/data/structured_text.gd")
const Source = preload("res://scripts/data/creation_career.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")

static func content(view: RefCounted, career: RefCounted, topic: Array) -> Dictionary:
	var locale: String = view._presentation.locale if view._presentation != null else "en"
	var cache_key: String = topic[0]+"/"+locale
	if career.help_cache.has(cache_key): return career.help_cache[cache_key].duplicate(true)
	var providers: RefCounted = view.shell.host.controller.providers
	var key: String = "help.custom."+topic[0]
	var read: Dictionary = Text.lookup(providers.definitions,providers.classic,"creation",key,locale,{"creation/"+key:topic[2]})
	var title: String = "Help - "+view.translated("help.topic."+topic[0],topic[1])
	var body := "Help text is unavailable for this topic."
	if read.ok:
		var lines := Source.literal(read).split("\n")
		if lines.size() > 1:
			title = lines[0]; lines.remove_at(0)
		# The classic records contain indentation for the original text renderer.
		# Let our left-aligned label own positioning rather than wrapping that padding.
		for index in lines.size(): lines[index] = lines[index].strip_edges()
		body = "\n".join(lines).strip_edges()
	var result := {"title":title,"body":body,"ok":read.ok,"record":topic[2]}
	career.help_cache[cache_key] = result
	return result.duplicate(true)

static func render(career: RefCounted, view: RefCounted, expected: Dictionary) -> void:
	var generation: int = view._render_generation
	var current := func(): return generation == view._render_generation and view.active() and not view.shell.core.busy() and Draft.same_value(expected,view.navigation.context()) and career.custom_tab == 4
	if not career.help_topic.is_empty():
		for topic: Array in TOPICS:
			if topic[0] != career.help_topic: continue
			var read := content(view,career,topic)
			preload("res://scripts/ui/creation_popup.gd").notice(view,read.body,func():
				if current.call(): career.custom_tab = 0; career.help_topic = ""; career.refresh(view),"custom-help",read.title)
		return
	var art: RefCounted = view.shell.host.controller.providers.creation_art
	var image: Dictionary = art.resolve("creation.list-picker")
	var thumb: Dictionary = art.resolve("creation.scrollbar-thumb")
	var font: Font = art.popup_font(ThemeDB.fallback_font)
	if view._presentation != null: font = view._presentation.creation_popup_font(font)
	var picker := preload("res://scripts/ui/classic_list_picker.gd").new()
	picker.position = Vector2(120,72); picker.scale = Vector2(2,2)
	picker.set_meta("custom_help_picker",true); view._page.add_child(picker)
	var labels: Array = []
	for topic: Array in TOPICS: labels.append(view.translated("help.topic."+topic[0],topic[1]))
	picker.configure(labels,font,image.texture if image.ok else null,view.navigation.summary_locked(),0,0,thumb.texture if thumb.ok else null)
	for index in TOPICS.size(): view._buttons["help/"+TOPICS[index][0]] = picker.buttons[index]
	picker.item_activated.connect(func(index: int):
		if not current.call() or view.navigation.summary_locked(): return
		career.help_topic = TOPICS[index][0]; career.refresh(view))
