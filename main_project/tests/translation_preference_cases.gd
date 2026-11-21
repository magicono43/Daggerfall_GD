extends "res://tests/text_cases.gd"
const Author = preload("res://scripts/data/text_author.gd")
const Import = preload("res://scripts/data/translation_import.gd")
const Preferences = preload("res://scripts/mod/preferences.gd")
const Definitions = preload("res://scripts/mod/preference_definitions.gd")
const Consumer = preload("res://tests/controlled_preference_consumer.gd")
const Layout = preload("res://scripts/session/text_layout.gd")

func ref(key := "label") -> Dictionary:
	return {"collection":"prefs","key":key}

func spec(type: String, default_value: Variant, timing: String, group: String) -> Dictionary:
	var result := {"type":type,"default":default_value,"timing":timing,"group":group,"name":ref(),"description":ref()}
	if type == "int":
		result.merge({"min":0,"max":100})
	if type == "string":
		result.max_length = 100
	return result

func definition(id: String) -> Dictionary:
	return {"schema":Definitions.VERSION,"mod_id":id,"version":1,"name":ref(),"description":ref(),"settings":{
		"low":spec("int", 1, "live", "live"),"high":spec("int", 10, "live", "live"),
		"session":spec("bool", false, "next_session", "session"),"location":spec("bool", false, "next_location", "location"),
		"restart":spec("bool", false, "restart", "mixed"),"mixed":spec("bool", false, "live", "mixed"),
		"draft":spec("string", "literal", "live", "draft")},"groups":{
		"live":{"constraints":[["less_equal","low","high"]]},"session":{"constraints":[]},"location":{"constraints":[]},"mixed":{"constraints":[]},"draft":{"constraints":[]}},
		"presets":{"partial":{"name":ref(),"description":ref(),"values":{"low":3}}}}

func mapped(key: String, text: String, source_id: String) -> Dictionary:
	var author := Author.encode([{"kind":"text","text":text},{"kind":"record_end"}], ["stable-variant"])
	return {"key":key,"source_id":source_id,"base":"en","source":author.text,"translation":author.text,"operation":"add","required":[],"optional":false,"essential":false,"provenance":{"source":"synthetic-v1","record":source_id}}

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var core := Core.new(material)
	var gameplay_owner := Owner.new()
	core.provider = gameplay_owner
	core.startup_route_changed("main_menu")
	check("controlled gameplay ready through CORE", "Succeeded", core.request({"id":"authoring-owner","mode":"new","origin":""}).kind)
	var granted: Dictionary = core.randomness.source(core.snapshot().session, gameplay_owner, "quest")
	check("controlled retained gameplay result prepared", true, gameplay_owner.prepare_reward("authoring-retained", granted.source).ok)
	var rng_before: Dictionary = core.randomness.snapshot()
	var facts_before: Dictionary = gameplay_owner.retained_snapshot()
	var controller = shell.controller
	var storage: StartupStorageAdapter = controller.storage.adapter
	var tokens: Array = [{"kind":"text","text":"  \\ {literal} %pcname [markup] café אבג سلام  ","position":7,"absolute_position":107,"length":12},{"kind":"font","operand":255},{"kind":"position","operand":0},{"kind":"input_cursor"},{"kind":"line_break"},{"kind":"page_break"},{"kind":"justify_center"},{"kind":"variant_break"},{"kind":"text","text":"Second variant"},{"kind":"justify_left"},{"kind":"record_end"}]
	var encoded := Author.encode(tokens, ["first", "second"])
	check("author encodes all supported controls", true, encoded.ok)
	var decoded := Author.decode(encoded.text)
	check("explicit variant IDs survive", ["first", "second"], decoded.variant_ids)
	check("literal spaces and syntax survive", tokens[0].text, decoded.tokens[0].text)
	check("source relative position survives", 7, decoded.tokens[0].position)
	check("source absolute position survives", 107, decoded.tokens[0].absolute_position)
	check("font operand survives", 255, decoded.tokens[1].operand)
	check("position zero survives", 0, decoded.tokens[2].operand)
	check("editorial whitespace irrelevant", decoded.tokens, Author.decode(JSON.stringify(JSON.parse_string(encoded.text))).tokens)
	check("required unknown control rejected", false, Author.encode([{"kind":"unknown"}], [0]).ok)
	check("missing record end rejected", false, Author.encode([{"kind":"text","text":"x"}], [0]).ok)
	check("variant inventory mismatch rejected", false, Author.encode(tokens, [0]).ok)
	check("duplicate variant IDs rejected", false, Author.encode(tokens, [0,0]).ok)
	check("font operand range rejected", false, Author.encode([{"kind":"font","operand":256},{"kind":"record_end"}], [0]).ok)
	var placeholder_tokens: Array = [{"kind":"reference","name":"sample","type":"string","format":"plain"},{"kind":"input_cursor"},{"kind":"record_end"}]
	check("undeclared reference rejected", false, Author.encode(placeholder_tokens, [0]).ok)
	var placeholder := Author.encode(placeholder_tokens, [0], ["sample:string:plain"])
	check("typed explicit sample accepted", true, placeholder.ok)
	check("missing sample rejected", false, Author.sample(placeholder, {}).ok)
	check("wrong typed sample rejected", false, Author.sample(placeholder, {"sample":3}).ok)
	var sample := Author.sample(placeholder, {"sample":"  multiline\n%name {x} [font]  "})
	check("sample inserted once as literal", "  multiline\n%name {x} [font]  ", sample.tokens[0].text)
	check("sample input position retained", "input_cursor", sample.tokens[1].kind)
	check("authoring essential label uses decoded literal", "Quit", Catalog.essential_literal({"tokens":[{"kind":"text","text":"Quit"},{"kind":"record_end"}]}, "quit"))
	check("essential unsupported structure recovers complete label", "Quit", Catalog.essential_literal({"tokens":[{"kind":"font","operand":99},{"kind":"text","text":"bad"}]}, "quit"))
	var importer := Import.new(storage, controller.storage.context.root.path_join("Authoring/disposable"))
	var document := {"schema":Import.VERSION,"collection":"messages","locale":"en","entries":[mapped("alpha", "  Original  ", "TEXT.RSC:25"),mapped("beta", "Other", "TEXT.RSC:11")]}
	var preview := importer.preview(document)
	check("real preview additions", "addition", preview.rows.alpha.kind)
	check("preview creates no pointer", false, FileAccess.file_exists(importer.root.path_join("active.ini")))
	check("invalid selected operation publishes zero", false, importer.commit(preview.id, {"alpha":"bad"}).ok)
	check("rejected operation still no pointer", false, FileAccess.file_exists(importer.root.path_join("active.ini")))
	var committed := importer.commit(preview.id, {"alpha":"preserve", "beta":"preserve"})
	check("selected operation durable", true, committed.ok)
	check("committed runtime artifact is actual CSV", true, FileAccess.get_file_as_string(committed.csv).begins_with("schema,codec,collection,"))
	var active := importer.load_active()
	check("reopened complete generation", true, active.ok)
	check("explicit source mapping retained", "TEXT.RSC:25", active.snapshot.entries.alpha.source_id)
	var before := importer.pointer_bytes()
	preview = importer.preview(document)
	check("unchanged import preview", "unchanged", preview.rows.alpha.kind)
	check("unchanged commit zero writes", 0, importer.commit(preview.id, {"alpha":"preserve", "beta":"preserve"}).writes)
	check("unchanged pointer bytes", before, importer.pointer_bytes())
	document.entries.reverse()
	preview = importer.preview(document)
	check("source reorder stable keys", "unchanged", preview.rows.alpha.kind)
	var replaced: Dictionary = document.duplicate(true)
	replaced.entries[1].translation = mapped("alpha", "Replacement", "TEXT.RSC:25").translation
	preview = importer.preview(replaced)
	check("replacement shown before commit", true, preview.rows.alpha.replacement_changes)
	check("unselected replacement preserves work", "unchanged", importer.commit(preview.id, {}).kind)
	check("preserve operation retains original translation", "unchanged", importer.commit(preview.id, {"alpha":"preserve"}).kind)
	check("explicit replacement commits", true, importer.commit(preview.id, {"alpha":"replace"}).ok)
	check("selected replacement visible after reopen", replaced.entries[1].translation, importer.load_active().snapshot.entries.alpha.translation)
	var changed: Dictionary = replaced.duplicate(true)
	changed.entries[1].source = mapped("alpha", "Changed meaning", "TEXT.RSC:25").source
	preview = importer.preview(changed)
	check("changed source review preview", "needs-review", preview.rows.alpha.preserve.review)
	check("changed source commit retains translation", true, importer.commit(preview.id, {"alpha":"preserve"}).ok)
	check("changed source work retained", replaced.entries[1].translation, importer.load_active().snapshot.entries.alpha.translation)
	changed.entries.remove_at(0)
	preview = importer.preview(changed)
	check("removed source orphan preview", "orphan", preview.rows.beta.kind)
	check("orphan retained on commit", true, importer.commit(preview.id, {"beta":"preserve"}).ok)
	check("orphan work remains", true, importer.load_active().snapshot.entries.has("beta"))
	var ambiguous: Dictionary = changed.duplicate(true)
	ambiguous.entries.append(ambiguous.entries[0].duplicate(true))
	check("ambiguous mapping rejected", false, importer.preview(ambiguous).ok)
	ambiguous = changed.duplicate(true)
	ambiguous.entries[0].key = "renamed"
	check("ambiguous rename rejected", false, importer.preview(ambiguous).ok)
	preview = importer.preview(replaced)
	var stale_id: int = preview.id
	var next: Dictionary = replaced.duplicate(true)
	next.entries[1].translation = mapped("alpha", "New translation", "TEXT.RSC:25").translation
	var next_preview := importer.preview(next)
	storage.faults.translation_publish = true
	before = importer.pointer_bytes()
	check("failed pointer publication reports failure", false, importer.commit(next_preview.id, {"alpha":"replace"}).ok)
	check("failed publication preserves pointer", before, importer.pointer_bytes())
	check("interrupted generation not adopted", replaced.entries[1].translation, Import.new(storage, importer.root).load_active().snapshot.entries.alpha.translation)
	storage.faults.clear()
	check("failed generation retry succeeds", true, importer.commit(next_preview.id, {"alpha":"replace"}).ok)
	check("obsolete preview rejected", false, importer.commit(stale_id, {"alpha":"replace"}).ok)
	var invalid: Dictionary = next.duplicate(true)
	invalid.entries[0].translation = "bad grammar"
	var invalid_preview := importer.preview(invalid)
	check("invalid replacement preview conflict", "conflict", invalid_preview.rows.beta.kind)
	check("invalid selected replacement rejects whole operation", false, importer.commit(invalid_preview.id, {"alpha":"preserve", "beta":"replace"}).ok)
	check("invalid preview changes no committed text", next.entries[1].translation, importer.load_active().snapshot.entries.alpha.translation)
	var changed_placeholder: Dictionary = next.duplicate(true)
	changed_placeholder.entries[1].required = ["sample:string:plain"]
	changed_placeholder.entries[1].source = Author.encode([{"kind":"reference","name":"sample","type":"string","format":"plain"},{"kind":"input_cursor"},{"kind":"record_end"}], ["stable-variant"], ["sample:string:plain"]).text
	var review_preview := importer.preview(changed_placeholder)
	check("changed placeholders/structure retain incompatible translation preview", "conflict", review_preview.rows.alpha.kind)
	check("changed placeholders retain work commit", true, importer.commit(review_preview.id, {"alpha":"preserve"}).ok)
	check("changed placeholders mark review", "needs-review", importer.load_active().snapshot.entries.alpha.review)
	check("review state preserves original publication requirements", [], importer.load_active().snapshot.entries.alpha.required)
	var interrupted := Import.new(storage, controller.storage.context.root.path_join("Authoring/interrupted"))
	var initial_document := {"schema":Import.VERSION,"collection":"messages","locale":"en","entries":[mapped("kept", "Keep durable work", "TEXT.RSC:25")]}
	var initial_preview := interrupted.preview(initial_document)
	check("interruption fixture durable baseline", true, interrupted.commit(initial_preview.id, {"kept":"preserve"}).ok)
	initial_document.entries[0].translation = mapped("kept", "Prepared but not published", "TEXT.RSC:25").translation
	initial_preview = interrupted.preview(initial_document)
	storage.faults.translation_publish = true
	check("interrupted publication reports no success", false, interrupted.commit(initial_preview.id, {"kept":"replace"}).ok)
	storage.faults.clear()
	var classic: Dictionary = preload("res://scripts/data/structured_text.gd").read(controller.providers.classic, 25)
	# Actual source readers initialize below through normal source selection.
	# Install data-only fixture packages through real discovery/DATA/menu path.
	for id: String in ["prefs.a", "prefs.b"]:
		var directory: String = controller.mods.root.path_join("Mods").path_join(id)
		var package := manifest(id)
		package.content = ["preferences.json", "labels.csv"]
		write(directory.path_join("mod.json"), JSON.stringify(package))
		var active_definition := definition(id)
		active_definition.settings.low.name = ref("author-label")
		write(directory.path_join("preferences.json"), JSON.stringify({"domain":Definitions.DOMAIN,"path":"installed","operation":"add","entries":[{"id":id,"value":active_definition}]}))
		# Only first package authors the shared labels.
		if id == "prefs.b":
			package.content = ["preferences.json"]
			write(directory.path_join("mod.json"), JSON.stringify(package))
		else:
			package.content.append("fonts.json")
			write(directory.path_join("mod.json"), JSON.stringify(package))
			var author_row := row("author-label", "en", Author.encode([{"kind":"text","text":"  Structural setting label  "},{"kind":"record_end"}], ["label"]).text, "add", "en", "", false, false, false, "prefs")
			author_row[1] = Author.VERSION
			write(directory.path_join("labels.csv"), csv([row("label","en","A long localized preference explanation with meaningful spaces  ","add","en","",false,false,false,"prefs"),row("label","zz-Test","  Synthetic café אבג سلام · a long localized preference explanation that must wrap without clipping the control or changing the stored identity.  ","add","en","",false,false,false,"prefs"), author_row]))
			write(directory.path_join("fonts.json"), JSON.stringify({"domain":"text.fonts","path":"installed","operation":"add","entries":[{"id":"synthetic","value":{"schema":"locale-fonts-v1","kind":"locale","locale":"zz-Test","roles":{"body":"recovery-sans","title":"recovery-sans","small-ui":"recovery-sans"},"coverage":"Synthetic verification only","offer":false}}]}))
	controller.mods.rescan()
	controller.mods.edit("prefs.a", "toggle")
	controller.mods.edit("prefs.b", "toggle")
	check("fixture default profile saved", true, controller.mods.save_profile().ok)
	check("second real profile created", true, controller.mods.manage("duplicate", "Shared preferences").ok)
	check("two profiles in same selected root", 2, controller.mods.committed.profiles.size())
	check("real settings DATA definitions preflight", "main_menu", controller.select_folder(fixture.classic_source).route)
	check("actual menu preference publication", "main_menu", controller.continue_to_menu("save").route)
	var published_author: Dictionary = Catalog.lookup(controller.providers.definitions, "prefs", "author-label", "en")
	check("author codec publishes through actual runtime CSV/menu", "  Structural setting label  ", published_author.tokens[0].text)
	check("runtime author variant identity survives lookup", ["label"], published_author.variant_ids)
	classic = preload("res://scripts/data/structured_text.gd").read(controller.providers.classic, 25)
	check("real classic source record read", true, classic.ok)
	var real_author := Author.encode(classic.tokens, classic.variants.map(func(v: Dictionary): return v.id), [], classic.source, "record25")
	check("real classic authoring conversion", true, real_author.ok)
	check("real classic authoring binary round trip", true, Tokens.encode_classic(Author.decode(real_author.text).tokens, classic.source, 25).ok)
	var real_bytes := Tokens.encode_classic(classic.tokens, classic.source, 25)
	check("real classic bytes preserved", real_bytes.bytes, Tokens.encode_classic(Author.decode(real_author.text).tokens, classic.source, 25).bytes)
	var preferences: RefCounted = controller.providers.preferences
	check("two active preference definitions", 2, preferences.stores.size())
	check("MOD plan remains locked", true, controller.mods.locked)
	var consumers: Dictionary = {}
	for id: String in preferences.stores:
		for group: String in preferences.stores[id].groups:
			var consumer := Consumer.new()
			consumers[id + "/" + group] = consumer
			check("checked consumer binding " + id + "/" + group, true, preferences.bind(id, group, consumer, {"generation":1,"scope":"controlled"}))
	check("valid staged edit", true, preferences.edit("prefs.a", "high", 20))
	check("partial preset accepted", true, preferences.preset("prefs.a", "partial"))
	check("partial preset omitted setting retained", 20, preferences.projection("prefs.a").values.high.staged)
	check("preset changes declared setting", 3, preferences.projection("prefs.a").values.low.staged)
	preferences.cancel("prefs.a")
	check("Cancel discards preset", 1, preferences.projection("prefs.a").values.low.staged)
	preferences.edit("prefs.a", "low", 4)
	preferences.request_reset("prefs.a")
	preferences.confirm_reset("prefs.a", false)
	check("cancel reset retains edits", 4, preferences.projection("prefs.a").values.low.staged)
	preferences.request_reset("prefs.a")
	preferences.confirm_reset("prefs.a", true)
	check("confirmed reset stages complete defaults", 7, preferences.staged["prefs.a"].size())
	check("reset is not Apply", 1, preferences.projection("prefs.a").values.low.accepted)
	check("two mod reset isolated", false, preferences.staged.has("prefs.b"))
	preferences.cancel("prefs.a")
	check("Cancel discards unapplied reset", false, preferences.staged.has("prefs.a"))
	preferences.edit("prefs.a", "low", 30)
	check("whole group incompatible rejected", false, preferences.apply("prefs.a").ok)
	check("group rejection retains accepted", 1, preferences.projection("prefs.a").values.low.accepted)
	preferences.cancel("prefs.a")
	preferences.edit("prefs.a", "low", 4)
	consumers["prefs.a/live"].reject = true
	check("consumer rejects group", 2, preferences.apply("prefs.a").rejected.size())
	check("failed consumer previous effective", 1, preferences.projection("prefs.a").values.low.effective)
	consumers["prefs.a/live"].reject = false
	preferences.edit("prefs.a", "low", 4)
	preferences.edit("prefs.a", "mixed", true)
	preferences.edit("prefs.a", "session", true)
	preferences.edit("prefs.a", "location", true)
	storage.faults.settings_publish = true
	check("live success write failure reported", false, preferences.apply("prefs.a").ok)
	check("failed write retains active accepted", 4, preferences.projection("prefs.a").values.low.effective)
	check("failed write retains prior persisted", 1, preferences.projection("prefs.a").values.low.persisted)
	check("unsaved shown", true, preferences.projection("prefs.a").unsaved)
	check("restart member defers entire group", false, preferences.projection("prefs.a").values.mixed.effective)
	check("mixed group actual timing", "restart", preferences.projection("prefs.a").values.mixed.timing)
	preferences.cancel("prefs.a")
	check("Cancel cannot undo accepted live", 4, preferences.projection("prefs.a").values.low.accepted)
	storage.faults.clear()
	var calls: int = consumers["prefs.a/live"].calls
	check("save retry succeeds", true, preferences.retry("prefs.a").ok)
	check("save retry no consumer replay", calls, consumers["prefs.a/live"].calls)
	check("saved state truthful", false, preferences.projection("prefs.a").unsaved)
	var authority := Consumer.new()
	var ticket := {"generation":1,"scope":"controlled-session","id":"boundary-1"}
	preferences.register_boundary("next_session", authority)
	preferences.register_boundary("next_location", authority)
	check("next session activation", true, preferences.activate("next_session", authority, ticket).ok)
	check("session pending becomes effective", true, preferences.projection("prefs.a").values.session.effective)
	check("session boundary leaves location pending", false, preferences.projection("prefs.a").values.location.effective)
	calls = consumers["prefs.a/session"].calls
	check("repeated boundary retained success", true, preferences.activate("next_session", authority, ticket).ok)
	check("repeated boundary no callback replay", calls, consumers["prefs.a/session"].calls)
	authority.generation += 1
	check("obsolete boundary rejected", false, preferences.activate("next_location", authority, ticket).ok)
	ticket = {"generation":2,"scope":"controlled-location","id":"boundary-2"}
	check("actual declared location boundary", true, preferences.activate("next_location", authority, ticket).ok)
	check("location becomes effective", true, preferences.projection("prefs.a").values.location.effective)
	var recreated := Consumer.new()
	check("recreated consumer binding", true, preferences.bind("prefs.a", "mixed", recreated, {"generation":1}))
	check("recreated consumer gets effective not saved", false, recreated.values["values/mixed"])
	check("definition lock rejects rebuild", "locked", controller.providers.definitions.prepare(controller.mods).kind)
	# Two profiles share the same application store; no save/character API exists.
	check("preference path excludes profile", true, preferences.stores["prefs.a"].path.ends_with("settings/mod_preferences/prefs.a/settings.ini"))
	var independent_storage := Storage.new()
	independent_storage.resolve({"executable_dir":sandbox.path_join("independent/executable"),"per_user_dir":sandbox.path_join("independent/user"),"development":true})
	var independent := preload("res://scripts/mod/preference_store.gd").new(independent_storage.adapter, independent_storage.context.root.path_join("settings/mod_preferences/prefs.a"), definition("prefs.a"))
	independent_storage.adapter.directory(independent.path.get_base_dir())
	check("independent root initializes", true, independent.initialize().ok)
	check("independent root default preserved", 1, independent.effective["values/low"])
	var reloaded := preload("res://scripts/mod/preference_store.gd").new(storage, preferences.stores["prefs.a"].path.get_base_dir(), definition("prefs.a"))
	check("persisted preferences reopen", true, reloaded.initialize().ok)
	check("restart adopted on actual new owner", true, reloaded.effective["values/mixed"])
	check("live persisted value reload", 4, reloaded.effective["values/low"])
	# Reopen the real profile owner independently (no preference owner is scoped
	# to its selected identity). Both selections resolve the very same file.
	var profiles := Configuration.new(storage, controller.mods.root)
	check("second profile owner initialized", true, profiles.initialize().ok)
	check("select default independent profile", true, profiles.select_profile("default").ok)
	var profile_default := preload("res://scripts/mod/preference_store.gd").new(storage, controller.mods.root.path_join("settings/mod_preferences/prefs.a"), definition("prefs.a"))
	check("default profile reads shared preferences", true, profile_default.initialize().ok)
	check("default profile sees accepted persisted value", 4, profile_default.effective["values/low"])
	check("select alternate independent profile", true, profiles.select_profile("profile-1").ok)
	var profile_other := preload("res://scripts/mod/preference_store.gd").new(storage, controller.mods.root.path_join("settings/mod_preferences/prefs.a"), definition("prefs.a"))
	check("other profile reads shared preferences", true, profile_other.initialize().ok)
	check("other profile sees same value", 4, profile_other.effective["values/low"])
	var bad_definition: Dictionary = definition("prefs.a")
	bad_definition.settings.low.default = 101
	check("invalid active defaults rejected", true, not Definitions.new().validate_record("prefs.a", bad_definition).is_empty())
	bad_definition = definition("prefs.a")
	bad_definition.settings.low.timing = "next_launch"
	check("next_launch never relabeled session", true, not Definitions.new().validate_record("prefs.a", bad_definition).is_empty())
	# Unknown compatible entries are retained; incompatible versions are untouched.
	var unknown := reloaded.clone(reloaded.accepted)
	unknown.set_value("unknown-extension", "future", "retained")
	check("compatible unknown data published", true, reloaded.publish(unknown, reloaded.persisted).ok)
	check("compatible unknown data reloaded", true, profile_other.initialize().ok)
	check("unknown data retained", "retained", profile_other.accepted.get_value("unknown-extension", "future"))
	var incompatible := profile_other.clone(profile_other.accepted)
	incompatible.set_value("mod", "version", 999)
	var incompatible_path: String = sandbox.path_join("incompatible/prefs.a")
	storage.directory(incompatible_path)
	write(incompatible_path.path_join("settings.ini"), incompatible.encode_to_text())
	var incompatible_owner := preload("res://scripts/mod/preference_store.gd").new(storage, incompatible_path, definition("prefs.a"))
	check("incompatible mod schema blocks safely", "incompatible", incompatible_owner.initialize().kind)
	check("incompatible mod store retained", incompatible.encode_to_text(), FileAccess.get_file_as_string(incompatible_owner.path))
	preferences.edit("prefs.a", "session", false)
	preferences.apply("prefs.a")
	var boundary_core := Core.new(material)
	var boundary_owner := Owner.new()
	boundary_core.provider = boundary_owner
	boundary_core.preferences = preferences
	preferences.register_boundary("next_session", boundary_core)
	boundary_core.startup_route_changed("main_menu")
	check("actual CORE next-session readiness activates group", "Succeeded", boundary_core.request({"id":"preferences-new","mode":"new","origin":""}).kind)
	check("actual CORE boundary effective value", false, preferences.projection("prefs.a").values.session.effective)
	boundary_core.request({"id":"preferences-load","mode":"load","origin":boundary_core.snapshot().session,"selection":{"retained_owner":boundary_owner.retained_snapshot()}})
	if boundary_core.snapshot().phase == "confirmation":
		boundary_core.confirm(boundary_core.ticket(), true)
	check("controlled load preserves application preferences", 4, preferences.projection("prefs.a").values.low.effective)
	check("controlled load reaches ready", true, boundary_core.snapshot().ready)
	boundary_core.dispose()
	independent_storage.adapter.release()
	var staged_before: Dictionary = controller.providers.definitions.active()
	var presentation: RefCounted = controller.providers.presentation
	check("unsupported renderer control not flattened", false, Layout.structure(decoded.tokens, presentation, "en", 300).ok)
	check("literal sample layout is pure", true, Layout.structure(sample.tokens, presentation, "en", 300).ok)
	var rendered := DisplayServer.get_name() != "headless"
	if rendered:
		shell.open_preferences()
		var view: Control = shell.preference_view
		check("production editor shows active mod", "prefs.a", view.selected)
		view.fields.draft.text = "pending %name {literal}"
		view.fields.draft.text_changed.emit(view.fields.draft.text)
		view.fields.draft.grab_focus()
		view.fields.draft.caret_column = 7
		preferences.request_reset("prefs.a")
		view.confirmation.show()
		var plan: Dictionary = view.prepare_locale("en")
		check("editor locale plan current", true, view.locale_plan_current(plan))
		check("real live locale Apply with staged preferences", true, controller.settings.apply({"presentation/locale":"zz-Test"}, presentation.apply).rejected.is_empty())
		check("locale retains pending draft", "pending %name {literal}", view.fields.draft.text)
		check("locale retains caret", 7, view.fields.draft.caret_column)
		check("locale retains focused input", true, view.fields.draft.has_focus())
		check("locale retains confirmation", true, view.confirmation.visible)
		await capture(shell, "translation-preferences-editor")
		view.box.get_parent().ensure_control_visible(view.confirmation)
		await capture(shell, "translation-preferences-reset")
		check("reset confirmation buttons have usable widths", true, view.confirmation.get_child(0).size.x >= 160 and view.confirmation.get_child(1).size.x >= 160)
		view.close()
		shell.open_authoring()
		var tool: Control = shell.authoring_view
		tool.export_record()
		check("production export produces editable document", true, tool.editor.text.contains(Import.VERSION))
		tool.preview_document()
		check("production preview usable", true, tool.preview_id >= 0)
		tool.operations.get_child(0).button_pressed = true
		tool.commit_selected()
		check("production selected commit durable", true, tool.service.load_active().ok and not tool.service.load_active().snapshot.entries.is_empty())
		tool.render_sample()
		check("production sample truthfully rendered or rejects required control", true, tool.state_label.text.begins_with("Pure sample") or tool.state_label.text.contains("unsupported_required_control"))
		await shell.get_tree().process_frame
		await shell.get_tree().process_frame
		tool.operations.get_parent().get_parent().ensure_control_visible(tool.operations)
		await capture(shell, "translation-import-preview")
		tool.close()
		controller.settings.apply({"presentation/locale":"en"}, presentation.apply)
	check("authoring preserves locked DATA", staged_before, controller.providers.definitions.active())
	check("authoring consumes no gameplay RNG", rng_before, core.randomness.snapshot())
	check("authoring replays no owner mutation", facts_before, gameplay_owner.retained_snapshot())
	core.dispose()
	var result := {"ok":checks.all(func(item: Dictionary): return item.expected == item.actual),"count":checks.size(),"checks":checks,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":"IMP-007-translation-preferences-v1"}
	return result
