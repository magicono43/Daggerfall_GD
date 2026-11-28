extends "res://tests/mod_cases.gd"
const Factions = preload("res://scripts/data/faction_quest_inputs.gd")
var observations := {}
const DOMAINS = ["actor.baseline","actor.inputs","char.biography","char.career","char.creation","char.identity","char.starting","faction-quest.inputs","geography.inputs","item-spell.inputs","item.construction","layout.inputs","media.assets","mod.preferences","move.air","move.feedback","move.ground","move.mechanism","rule.holidays","text.catalogs","text.fonts","time.calendar","world.variants"]

func domains(registry: RefCounted) -> Array:
	var names: Array = registry._adapters.keys()
	names.sort()
	return names

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var controller: RefCounted = shell.controller
	var registry: RefCounted = controller.providers.definitions
	observations.initial_startup_usec = shell.startup_elapsed_usec
	var reload: bool = fixture.mode.ends_with("_reload")
	if reload:
		check("remembered source enters menu","main_menu",controller.route)
		check("remembered source ready",true,controller.providers.classic.ready())
		check("fresh process published",true,controller.menu_entered)
		check("fresh process locked",true,controller.mods.locked)
		check("relaunched effective skip","back",controller.settings.effective["media/video_skip"])
		check("relaunched accepted skip","back",controller.settings.value(controller.settings.accepted,"media/video_skip"))
		check("remembered candidate valid",true,controller.prepared_content.ok)
		check("automatic startup prepares once",1,registry.timings.prepare_serial)
		observations.automatic_publication_phases = registry.timings.duplicate(true)
		check("remembered menu publication",true,controller.continue_to_menu("run").ok)
		check("remembered content locked",true,controller.mods.locked)
		check("remembered all domains",DOMAINS,domains(registry))
		shell.clear()
		shell.session_shell.render_settings({"data":{},"id":"composition-settings"})
		var options: Array = shell.panel.get_children().filter(func(child: Node): return child is OptionButton)
		check("relaunched stock skip selection",3,options[-1].selected)
	else:
		check("clean startup requires source","mandatory_setup",controller.route)
		check("clean startup unpublished",true,registry.active().is_empty())
		controller.select_folder("")
		check("cancel keeps mandatory recovery","mandatory_setup",controller.route)
		controller.select_folder(fixture.unreadable_root)
		check("unreadable required source blocks entry",[false,false,true],[controller.result.ok,controller.menu_entered,registry.active().is_empty()])
		controller.select_folder(str(fixture.sandbox).path_join("absent/ARENA2"))
		check("invalid required source rejected",false,controller.result.ok)
		check("invalid source leaves unpublished",true,registry.active().is_empty())
		controller.settings.apply({"startup/show_setup":true})
		# Control this launch routing as existing publication fixtures do; the saved
		# next-launch preference is independently exercised by the relaunch leg.
		controller.settings.effective["startup/show_setup"] = true
		var started := Time.get_ticks_usec()
		controller.select_folder(fixture.classic_source)
		observations.selection_usec = Time.get_ticks_usec()-started
		observations.selection_phases = registry.timings.duplicate(true)
		check("valid source recovers to setup","optional_setup",controller.route)
		check("combined candidate valid",true,controller.prepared_content.ok)
		check("candidate remains unpublished",true,registry.active().is_empty())
		check("faction candidate index unpublished","before_readiness",registry.domain_index(Factions.DOMAIN).kind)
		check("all ordinary domains",DOMAINS,domains(registry))
		registry.faults.publish = true
		check("combined publication rejection",false,controller.continue_to_menu("run").ok)
		check("rejected publication remains atomic",[true,false,false],[registry.active().is_empty(),controller.menu_entered,controller.mods.locked])
		check("rejected faction index unpublished","before_readiness",registry.domain_index(Factions.DOMAIN).kind)
		registry.faults.clear()
		started = Time.get_ticks_usec()
		check("combined menu publication",true,controller.continue_to_menu("run").ok)
		observations.commit_usec = Time.get_ticks_usec()-started
		observations.commit_phases = registry.timings.duplicate(true)
		check("combined menu entered",true,controller.menu_entered)
		check("combined configuration locked",true,controller.mods.locked)
		var active: Dictionary = registry.active()
		active.resources.clear()
		check("public catalog projection detached",true,registry.query(Factions.DOMAIN,"packs/dfu","faction-17").ok)
		check("repeat menu entry retained",controller.published.ticket,controller.continue_to_menu("run").configuration_id)
		check("locked MOD rejects rescan",false,controller.mods.rescan().ok)
		check("publication prevents rebuild","locked",registry.prepare(controller.mods).kind)
		started = Time.get_ticks_usec()
		var children: Dictionary = Factions.children(registry,"packs/dfu","faction-17")
		observations.faction_query_usec = Time.get_ticks_usec()-started
		check("faction query available",true,children.ok)
		var expected: Array = children.children.duplicate(true)
		children.children.append("external mutation")
		check("faction projection detached",expected,Factions.children(registry,"packs/dfu","faction-17").children)
		apply_skip(shell,3)
		check("stock skip effective","back",controller.settings.effective["media/video_skip"])
		check("stock skip accepted","back",controller.settings.value(controller.settings.accepted,"media/video_skip"))
		var disk := ConfigFile.new()
		check("stock skip disk reopened",OK,disk.load(controller.settings.path))
		check("stock skip persisted","back",disk.get_value("media","video_skip"))
		check("stock skip truthful success","Cinematic skip preference saved.",shell.session_shell.message)
		var rejected: Dictionary = controller.settings.apply({"media/video_skip":"any"},func(_values: Dictionary): return false)
		check("rejected application despite persistence",[true,"partial_or_rejected","back"],[rejected.ok,rejected.application,controller.settings.effective["media/video_skip"]])
		check("rejection message truthful",true,controller.providers.media_preferences.skip_message(rejected).contains("rejected"))
		controller.storage.adapter.faults.settings_publish = true
		apply_skip(shell,1)
		check("stock unsaved application truthful",["any","any","Cinematic skip preference applied, not saved; Retry Save."],[controller.settings.effective["media/video_skip"],controller.settings.value(controller.settings.accepted,"media/video_skip"),shell.session_shell.message])
		controller.storage.adapter.faults.clear()
		apply_skip(shell,3)
		check("stock preference reverse applied","back",controller.settings.effective["media/video_skip"])
		check("remember automatic startup persisted",true,controller.settings.apply({"startup/show_setup":false}).ok)
	observations.memory_static_bytes = OS.get_static_memory_usage()
	observations.memory_peak_bytes = OS.get_static_memory_peak_usage()
	if DisplayServer.get_name() != "headless":
		shell.render()
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := shell.get_viewport().get_texture().get_image()
		check("combined rendered frame",false,image.is_empty())
		image.save_png(str(fixture.sandbox).path_join("composition.png"))
	var ok := true
	for item: Dictionary in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs,"observations":observations}

func apply_skip(shell: Control, selected: int) -> void:
	shell.clear()
	shell.session_shell.render_settings({"data":{},"id":"composition-settings"})
	var options: Array = shell.panel.get_children().filter(func(child: Node): return child is OptionButton)
	options[-1].select(selected)
	var button: Button = shell.panel.get_children().filter(func(child: Node): return child is Button and child.text == "Apply Cinematic Skip")[0]
	button.pressed.emit()
