extends "res://tests/structured_text_cases.gd"
const Fonts = preload("res://scripts/data/locale_fonts.gd")
const Layout = preload("res://scripts/session/text_layout.gd")
const Presentation = preload("res://scripts/session/text_presentation.gd")
var responses := 0

func font_value(asset := "sample-mono", fallbacks: Array = ["recovery-sans"]) -> Dictionary:
	return {"schema":Fonts.VERSION,"kind":"font","bundled":asset,"sha256":Fonts.HASHES[asset],"license":"Bundled license under content/fonts","version":"fixture-v1","fallbacks":fallbacks}

func envelope(entries: Array, operation := "add") -> String:
	return JSON.stringify({"domain":Fonts.DOMAIN,"path":"installed","operation":operation,"entries":entries})

func write(path: String, text: String) -> void:
	if path.ends_with("/A/mod.json"):
		var manifest: Dictionary = JSON.parse_string(text)
		manifest.content.append_array(["fonts.json","locale.csv"])
		text = JSON.stringify(manifest)
		super.write(path.get_base_dir().path_join("fonts.json"),envelope([
			{"id":"sample-mono","value":font_value()},
			{"id":"synthetic","value":{"schema":Fonts.VERSION,"kind":"locale","locale":"zz-Test","roles":{"body":"sample-mono","title":"recovery-sans","small-ui":"sample-mono"},"coverage":"Synthetic Latin, combining and Hebrew/Arabic samples only; not a supported language","offer":false}}
		]))
		super.write(path.get_base_dir().path_join("locale.csv"),csv([
			row("prompt","en","  Choose a stable answer. Draft remains literal.  "),
			row("prompt","zz-Test","  Synthetic sample: café אבג سلام. Choose a stable answer; this intentionally long instruction must wrap without clipping.  "),
			row("yes","en","Retain answer A"),row("yes","zz-Test","Synthetic answer A — retain identity"),
			row("no","en","Keep editing"),row("no","zz-Test","Synthetic: keep editing")]))
	super.write(path,text)

func shaped(text: String, font: Font, direction: int) -> Array:
	var line := TextLine.new()
	line.direction = direction
	line.add_string(text,font,24)
	var server := TextServerManager.get_primary_interface()
	var result: Array = []
	for glyph: Dictionary in server.shaped_text_get_glyphs(line.get_rid()):
		result.append({"start":glyph.start,"end":glyph.end,"index":glyph.index,"flags":glyph.flags})
	return result

func prepare_relaunch(fixture: Dictionary) -> void:
	var root: String = sandbox.path_join("relaunch")
	var controller := preload("res://scripts/startup/startup_controller.gd").new()
	controller.providers.register_bundled_text()
	controller.providers.enable_locale_fonts()
	controller.providers.enable_structured_text()
	check("fresh owner starts without source","mandatory_setup",controller.start({"executable_dir":root.path_join("executable"),"per_user_dir":root.path_join("user"),"development":true}).route)
	var initial_notifications := [0]
	controller.providers.presentation.changed.connect(func(): initial_notifications[0] += 1)
	var package: String = controller.mods.root.path_join("Mods/Locale")
	var manifest := manifest("locale.samples")
	manifest.content = ["fonts.json","locale.csv","invalid-cycle.json"]
	write(package.path_join("mod.json"),JSON.stringify(manifest))
	var inline := font_value()
	inline.sfnt = Marshalls.raw_to_base64(Fonts.bytes(inline))
	inline.erase("bundled")
	write(package.path_join("fonts.json"),envelope([
		{"id":"sample-mono","value":inline},
		{"id":"synthetic","value":{"schema":Fonts.VERSION,"kind":"locale","locale":"zz-Test","roles":{"body":"sample-mono","title":"recovery-sans","small-ui":"sample-mono"},"coverage":"Synthetic script samples only","offer":false}}
	]))
	write(package.path_join("locale.csv"),csv([row("relaunch","en","Loaded English"),row("relaunch","zz-Test","Synthetic loaded after real process relaunch")]))
	write(package.path_join("invalid-cycle.json"),envelope([{"id":"cycle","value":font_value("sample-mono",["cycle"])},{"id":"would-leak","value":font_value()}]))
	controller.mods.rescan()
	controller.mods.edit("locale.samples","toggle")
	check("font cycle blocks actual CORE menu","package_recovery",controller.select_folder(fixture.classic_source).route)
	var candidate: Dictionary = controller.providers.definitions.projection()
	check("font cycle publishes nothing",false,controller.providers.definitions.active().get("ready",false))
	check("font failure names contribution",true,candidate.issues[0].source.contains("cycle"))
	check("whole font file explicit omission",true,controller.providers.definitions.omit(candidate.issues[0].token,candidate.ticket,controller.mods).ok)
	controller.check_content()
	check("omission clean rebuild drops all file records",false,controller.providers.definitions.projection().resources[Fonts.DOMAIN + ":installed"].records.has("would-leak"))
	check("real menu saves profile after omission","main_menu",controller.continue_to_menu("save").route)
	check("initial menu font commitment emits no callbacks",0,initial_notifications[0])
	var applied: Dictionary = controller.settings.apply({"presentation/locale":"zz-Test"},controller.providers.presentation.apply)
	check("production nondefault selection saved",true,applied.ok and applied.rejected.is_empty())
	check("production nondefault selection effective","zz-Test",controller.settings.effective["presentation/locale"])
	# Repair the on-disk package for next launch. The active installed run stays locked.
	manifest.content = ["fonts.json","locale.csv"]
	write(package.path_join("mod.json"),JSON.stringify(manifest))
	check("external repair cannot unlock active DATA","locked",controller.providers.definitions.prepare(controller.mods).kind)
	# Simulate a valid prior installation's persisted capability request, then use
	# actual normal startup/menu publication to verify current-build recovery.
	var unavailable: Dictionary = controller.settings.apply({"presentation/locale":"Unavailable"},func(_values: Dictionary): return true)
	check("controlled prior-install request persisted",true,unavailable.ok)
	controller.providers.dispose()
	controller.logger.stop("Isolated font recovery fixture completed")
	controller.storage.adapter.release()
	var restarted := preload("res://scripts/startup/startup_controller.gd").new()
	restarted.providers.register_bundled_text()
	restarted.providers.enable_locale_fonts()
	restarted.providers.enable_structured_text()
	restarted.start({"executable_dir":root.path_join("executable"),"per_user_dir":root.path_join("user"),"development":true})
	check("normal startup unavailable request retained",true,restarted.settings.value(restarted.settings.accepted,"presentation/locale") == "Unavailable" and restarted.settings.value(restarted.settings.persisted,"presentation/locale") == "Unavailable")
	check("normal startup unavailable effective recovery","en",restarted.settings.effective["presentation/locale"])
	check("normal startup unavailable notice actionable",true,restarted.route == "main_menu" and not restarted.providers.presentation.notice.is_empty())
	restarted.settings.apply({"presentation/locale":"zz-Test"},restarted.providers.presentation.apply)
	restarted.providers.dispose()
	restarted.logger.stop("Unavailable locale startup recovery completed")
	restarted.storage.adapter.release()

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var recovery_owner := Presentation.new()
	for key: String in Catalog.RECOVERY:
		var readable: Dictionary = recovery_owner.essential(key)
		check("prepublication independent recovery " + key,true,readable.text == Catalog.RECOVERY[key] and readable.font is FontFile and readable.diagnostics.is_empty())
	recovery_owner.dispose()
	if DisplayServer.get_name() != "headless":
		for frame in range(3):
			await shell.get_tree().process_frame
		var create_profile: Button = find_button(shell.panel,"Create Profile")
		check("rendered recovery MOD controls receive readable width",true,create_profile != null and create_profile.size.x > 100)
	var result: Dictionary = await super.run(shell,fixture)
	var controller = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var owner: RefCounted = controller.providers.presentation
	check("font schema frozen","locale-fonts-v1",Fonts.VERSION)
	check("presentation frozen","text-presentation-v1",Presentation.VERSION)
	check("layout frozen","text-layout-v1",Layout.VERSION)
	check("only English advertised",["en"],owner.available())
	check("synthetic exact loaded selection",["en","zz-Test"],owner.available(true))
	check("first launch en","en",controller.settings.effective["presentation/locale"])
	check("setting declared before initialization",TYPE_STRING,controller.settings.schema["presentation/locale"].type)
	check("locale live timing","live",controller.settings.schema["presentation/locale"].timing)
	for role: String in Fonts.ROLES:
		check("actual font role " + role,true,owner.font(role) is FontFile)
		check("system font disabled " + role,false,owner.font(role).allow_system_fallback)
	for key: String in Catalog.RECOVERY:
		var recovery: Dictionary = owner.essential(key)
		check("readable recovery font " + key,true,recovery.text.to_utf32_buffer().size() > 0 and recovery.font.has_char(82) and recovery.diagnostics.is_empty())
	var font_adapter := Fonts.new()
	var asset := font_value()
	check("valid real asset","",font_adapter.validate_record("sample",asset))
	asset.bundled = "missing"
	check("missing asset rejected",true,not font_adapter.validate_record("sample",asset).is_empty())
	asset = font_value()
	asset.sha256 = "damaged"
	check("damaged asset rejected",true,not font_adapter.validate_record("sample",asset).is_empty())
	var malformed := font_value()
	malformed.erase("bundled")
	malformed.sfnt = "===="
	check("malformed inline font rejects without decoder errors",true,not font_adapter.validate_record("bad-inline",malformed).is_empty())
	var base: Dictionary = registry.active().resources
	var recovery_only := {Fonts.DOMAIN + ":installed":base[Fonts.DOMAIN + ":installed"],Catalog.DOMAIN + ":recovery":base[Catalog.DOMAIN + ":recovery"]}
	var blank_recovery: Array = []
	for key: String in Catalog.RECOVERY:
		blank_recovery.append(row(key,"en","","replace","en","",false,true,false,"recovery"))
	var blank_candidate := Catalog.new().apply_csv(recovery_only,csv(blank_recovery).to_utf8_buffer(),source("blank-recovery.csv"))
	var recovery_plan := Presentation.new()
	check("all unusable catalog labels retain independent English font readiness",true,recovery_plan.prepare(blank_candidate.resources,1).ok)
	recovery_plan.dispose()
	check("font resource path is explicit",false,registry.apply_contribution(base,envelope([]).replace('"installed"','"other"').to_utf8_buffer(),source("other.json")).ok)
	var cycle: Dictionary = registry.apply_contribution(base,envelope([{"id":"sample-mono","value":font_value("sample-mono",["sample-mono"])}],"patch").to_utf8_buffer(),source("cycle.json"))
	check("cycle candidate references reject",true,not font_adapter.validate_references(cycle.resources).is_empty())
	var unresolved: Dictionary = registry.apply_contribution(base,envelope([{"id":"sample-mono","value":font_value("sample-mono",["absent"])}],"patch").to_utf8_buffer(),source("unresolved.json"))
	check("unresolved required fallback rejects",true,not font_adapter.validate_references(unresolved.resources).is_empty())
	var invalid: Dictionary = registry.apply_contribution(base,envelope([{"id":"would-leak","value":font_value()},{"id":"bad","value":asset}]).to_utf8_buffer(),source("bad-fonts.json"))
	check("late malformed font rejects whole file",false,invalid.ok)
	check("input candidate unchanged",false,base[Fonts.DOMAIN + ":installed"].records.has("would-leak"))
	check("loaded primary misses Hebrew",false,Fonts.load_font(font_value()).has_char(0x5d0))
	check("real font fallback supplies Hebrew",true,owner.font("body","zz-Test").has_char(0x5d0))
	var missing: Dictionary = owner.literal("A" + String.chr(0x10ffff) + "B")
	check("exhausted glyph visible marker","A?B",missing.text)
	check("glyph miss diagnostic scalar",0x10ffff,missing.diagnostics[0].scalar)
	check("essential glyph miss uses readable English","Retry",owner.literal(String.chr(0x10ffff),"body","en","retry").text)
	var combining := shaped("é",owner.font(),TextServer.DIRECTION_LTR)
	var rtl := shaped("אבג",owner.font(),TextServer.DIRECTION_RTL)
	var arabic := shaped("سلام",owner.font(),TextServer.DIRECTION_RTL)
	check("combining shapes one cluster",true,combining.size() >= 1 and combining[0].start == 0 and combining[0].end == 2)
	check("Hebrew expected visual source order",[2,1,0],rtl.map(func(g: Dictionary): return g.start))
	check("Arabic contextual ligature fewer than four glyphs",true,arabic.size() < 4 and arabic.size() > 0)
	check("Arabic expected right to left clusters",[3,1,0],arabic.map(func(g: Dictionary): return g.start))
	var whitespace := "  leading and trailing  "
	check("no whitespace normalization",whitespace,owner.literal(whitespace).text)
	var metrics := Layout.measure("Required instructions must wrap. ".repeat(20),owner.font(),18,220)
	check("actual font reflow creates lines",true,metrics.lines.size() > 5)
	check("reflow retains readable size",18,metrics.font_size)
	check("required instructions grow height",true,metrics.height > 100)
	var structure := Layout.structure([{"kind":"text","text":whitespace},{"kind":"line_break"},{"kind":"text","text":"Second"},{"kind":"input_cursor"},{"kind":"page_break"},{"kind":"text","text":"Page two"},{"kind":"record_end"}],owner,"en",220)
	check("supported structure lays out",true,structure.ok)
	check("separate semantic blocks",["text","input_cursor","page_break","text","record_end"],structure.blocks.map(func(b: Dictionary): return b.kind))
	check("meaningful line and spaces retained",whitespace + "\nSecond",structure.blocks[0].source_text)
	check("unknown original font mapping rejected",false,Layout.structure([{"kind":"font","operand":3}],owner,"en",220).ok)
	check("position not silently flattened",false,Layout.structure([{"kind":"position","operand":20}],owner,"en",220).ok)
	check("unselected variant not flattened",false,Layout.structure([{"kind":"variant_break"}],owner,"en",220).ok)
	check("book no guessed physical page",true,not Layout.reading_position("",[]).notice.is_empty())
	check("book verified anchor retained","chapter-a",Layout.reading_position("chapter-a",["chapter-a"]).anchor)
	var session: RefCounted = shell.session_shell
	var core: SessionLifecycle = session.core
	core.randomness.dispose()
	core.randomness = preload("res://scripts/rule/session_randomness.gd").new(core.gates,material)
	var gameplay := Owner.new()
	core.provider = gameplay
	shell.render()
	check("production shell controlled session starts","Succeeded",session.request("new").kind)
	var granted: Dictionary = core.randomness.source(core.snapshot().session,gameplay,"quest")
	gameplay.prepare_reward("pending-font-choice",granted.source)
	var prompt_id: String = session.show_prompt({"kind":"text","operation":"controlled-choice-7","variant":4,"selected_answer":"yes","text_ref":{"collection":"sample","key":"prompt"},"responses":["yes","no","submit"],"labels":{"submit":"Submit draft"},"label_refs":{"yes":{"collection":"sample","key":"yes"},"no":{"collection":"sample","key":"no"}},"draft":"  literal %pcname {draft}  "},func(_response: Dictionary): responses += 1; return {"ok":false})
	shell.render()
	for frame in range(3):
		await shell.get_tree().process_frame
	var prompt: Control
	for child in shell.panel.get_children():
		if child.get_script() == preload("res://scripts/session/session_prompt.gd"):
			prompt = child
	prompt.field.grab_focus()
	prompt.field.caret_column = 7
	var before_window: Dictionary = session.windows.top()
	var before_state: Dictionary = core.snapshot()
	var before_rng: Dictionary = core.randomness.snapshot()
	var before_facts: Dictionary = gameplay.retained_snapshot()
	var before_registry: Dictionary = registry.active()
	var before_plan: Dictionary = controller.mods.planning_input()
	var before_prepare: int = controller.providers.classic_preparations
	var before_formula: Dictionary = controller.providers.formulas.active()
	# Exercise the same staged widget and Apply callback used by normal shell UI.
	shell.locale_editor.add_item("zz-Test (synthetic)")
	shell.locale_editor.set_item_text(shell.locale_editor.item_count - 1,"zz-Test")
	shell.locale_editor.select(shell.locale_editor.item_count - 1)
	check("staging does not apply","en",owner.locale)
	shell.cancel_language()
	check("normal Cancel discards staged selection","en",shell.locale_editor.get_item_text(shell.locale_editor.selected))
	check("Cancel retains effective locale","en",owner.locale)
	shell.locale_editor.select(shell.locale_editor.item_count - 1)
	var applied: Dictionary = shell.apply_language()
	check("production settings Apply accepted",true,applied.ok and applied.rejected.is_empty())
	check("actual locale changed","zz-Test",owner.locale)
	check("visible requested effective status refreshed",true,shell.locale_status.text.contains("Requested: zz-Test; effective: zz-Test"))
	check("pending text refreshed",true,prompt.heading.text.contains("Synthetic sample"))
	check("pending answer text refreshed",true,prompt.answers.yes.text.contains("Synthetic answer"))
	check("matching layout locale","zz-Test",prompt.last_layout.locale)
	check("same active field retained",true,is_instance_valid(prompt.field))
	check("actual focus retained",true,prompt.field.has_focus())
	check("caret retained",7,prompt.field.caret_column)
	check("window identity data draft focus retained",before_window,session.windows.top())
	check("CORE operation session facts unchanged",before_state,core.snapshot())
	check("RNG material draw count unchanged",before_rng,core.randomness.snapshot())
	check("gameplay retained outcomes unchanged",before_facts,gameplay.retained_snapshot())
	check("no response callback on refresh",0,responses)
	check("DATA publication unchanged",before_registry,registry.active())
	check("MOD order unchanged",before_plan,controller.mods.planning_input())
	check("formula registration unchanged",before_formula,controller.providers.formulas.active())
	check("no classic reinitialization",before_prepare,controller.providers.classic_preparations)
	if DisplayServer.get_name() != "headless":
		shell.panel.get_parent().ensure_control_visible(prompt)
		await capture(shell,"locale-pending-choice")
		check("rendered pending field focus",true,prompt.field.has_focus())
		check("rendered matching font measurement",prompt.last_layout.title.metrics.font_size,prompt.heading.get_theme_font_size("font_size"))
		check("rendered long instruction expands height",true,prompt.heading.get_line_count() >= 1 and prompt.heading.size.y >= prompt.heading.get_minimum_size().y)
		check("rendered prompt and actual-font line metrics agree",prompt.heading.get_line_count(),Layout.measure(prompt.heading.text,prompt.heading.get_theme_font("font"),18,prompt.heading.size.x).lines.size())
	check("same locale repeat succeeds",true,owner.switch_locale("zz-Test"))
	prompt.answers.yes.grab_focus()
	var answer_window: Dictionary = session.windows.top()
	check("answer-focus locale Apply",true,controller.settings.apply({"presentation/locale":"en"},owner.apply).ok)
	check("actual answer focus retained",true,prompt.answers.yes.has_focus())
	check("stable answer variant retained",answer_window,session.windows.top())
	check("reverse locale Apply",true,controller.settings.apply({"presentation/locale":"zz-Test"},owner.apply).ok)
	check("answer refresh never accepts",0,responses)
	prompt.field.grab_focus()
	check("unavailable locale rejects",false,owner.switch_locale("zz-Test-Region"))
	check("unavailable switch retains current","zz-Test",owner.locale)
	prompt._composition = true
	check("active composition rejects switch",false,owner.switch_locale("en"))
	prompt._composition = false
	var stale: Dictionary = prompt.prepare_locale("en")
	check("current prompt plan accepted",true,prompt.locale_plan_current(stale))
	var overlay: Dictionary = session.windows.open("message",core.snapshot().session)
	check("interrupted plan rejected",false,prompt.locale_plan_current(stale))
	check("covered view rejects switch",false,owner.switch_locale("en"))
	session.windows.close(overlay.id,true)
	check("navigation context expires the old prompt binding",false,owner.switch_locale("en"))
	# Navigation reconstructs its view normally; a locale refresh must not reuse
	# the old context even when the same window becomes topmost again.
	for frame in range(3):
		await shell.get_tree().process_frame
	for child in shell.panel.get_children():
		if child.get_script() == preload("res://scripts/session/session_prompt.gd"):
			prompt = child
	var rejected: Dictionary = controller.settings.apply({"presentation/locale":"Absent"},owner.apply)
	check("runtime unavailable Apply is rejected",["presentation/locale"],rejected.rejected)
	check("rejected Apply retains accepted", "zz-Test",controller.settings.value(controller.settings.accepted,"presentation/locale"))
	# Write failure retains accepted/effective values, persistence remains old.
	controller.storage.adapter.faults["settings_stage"] = true
	var failed: Dictionary = controller.settings.apply({"presentation/locale":"en"},owner.apply)
	check("write failure reported",false,failed.ok)
	check("write failure keeps effective en","en",controller.settings.effective["presentation/locale"])
	check("write failure keeps accepted en","en",controller.settings.value(controller.settings.accepted,"presentation/locale"))
	check("write failure retains persisted synthetic","zz-Test",controller.settings.value(controller.settings.persisted,"presentation/locale"))
	controller.storage.adapter.faults.erase("settings_stage")
	check("retry saves without refresh",true,controller.settings.save_accepted().ok)
	var restored := preload("res://scripts/startup/settings_owner.gd").new(controller.storage.adapter,controller.storage.context.settings)
	owner.declare_settings(restored)
	check("relaunch settings initialize",true,restored.initialize().ok)
	check("relaunch persisted locale","en",restored.value(restored.accepted,"presentation/locale"))
	check("invalid locale settings rejected","rejected",controller.settings.apply({"presentation/locale":"bad/locale"},owner.apply).kind)
	check("committed DATA stays locked","locked",registry.prepare(controller.mods).kind)
	check("committed MOD stays locked",false,controller.mods.edit("text.a","toggle").ok)
	var retired_plan: Dictionary = prompt.prepare_locale("en")
	var retired_scope: String = core.snapshot().session
	session.request("return")
	if core.snapshot().phase == "confirmation":
		core.confirm(core.ticket(),true)
	check("controlled return retires scope","",core.snapshot().session)
	check("retired prompt refresh rejected",false,prompt.locale_plan_current(retired_plan))
	check("application fonts survive session return","en",owner.locale)
	check("controlled new session after return","Succeeded",session.request("new").kind)
	check("replacement session has distinct scope",true,core.snapshot().session != retired_scope)
	check("DATA stays committed across session replacement",before_registry,registry.active())
	prepare_relaunch(fixture)
	if DisplayServer.get_name() != "headless":
		# Settle real window navigation before constructing the isolated sample board.
		for frame in range(3):
			await shell.get_tree().process_frame
		shell.panel.get_parent().scroll_vertical = 0
		for child in shell.panel.get_children():
			child.free()
		shell.label("Synthetic shaping samples — not supported languages",24)
		for sample in ["  Meaningful spaces  ","café (combining acute)","אבג", "سلام", "Mixed Latin אבג سلام",missing.text]:
			shell.label(sample,24)
		shell.label("Required long labels wrap at the actual rendered width. ".repeat(12))
		await capture(shell,"locale-shaping")
		check("rendered actual supported shaping backend",true,TextServerManager.get_primary_interface().has_feature(TextServer.FEATURE_SHAPING))
		for child in shell.panel.get_children():
			child.free()
		shell.label("Book-shaped reflow fixture — beginning with notice",24)
		shell.label(Layout.reading_position("",[]).notice)
		var page := Label.new()
		page.text = "  An authored line begins with two spaces.\n" + "Readable book-shaped text wraps using its actual font. ".repeat(18) + "  "
		page.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		page.autowrap_trim_flags = 0
		page.custom_minimum_size.x = 440
		page.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		page.add_theme_font_override("font",owner.font())
		page.add_theme_font_size_override("font_size",18)
		shell.panel.add_child(page)
		await capture(shell,"locale-book-reflow")
		check("rendered book wraps many lines",true,page.get_line_count() > 10)
		check("rendered book height is not clipped",true,page.size.y >= page.get_minimum_size().y)
		check("rendered book and actual-font line metrics agree",page.get_line_count(),Layout.measure(page.text,owner.font(),18,page.size.x).lines.size())
	# Restore actual accepted preferences before shutting down the leased process.
	controller.settings.save_accepted()
	result.fixture = "IMP-007-locale-fonts-v1"
	result.fonts = {"assets":Fonts.ASSETS,"hashes":Fonts.HASHES,"combining":combining,"rtl":rtl,"arabic":arabic,"metrics":metrics,"missing":missing.diagnostics}
	result.checks = checks
	result.count = checks.size()
	result.ok = checks.all(func(c: Dictionary): return c.expected == c.actual)
	return result
