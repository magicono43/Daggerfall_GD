extends RefCounted
const Core = preload("res://scripts/session/session_lifecycle.gd")
const Provider = preload("res://tests/controlled_session_provider.gd")
const Windows = preload("res://scripts/session/window_stack.gd")
const Cadence = preload("res://scripts/session/session_cadence.gd")
var checks: Array[Dictionary] = []
var sequence := 0

func check(name: String, passed: bool) -> void:
	checks.append({"scenario": name, "expected": "pass", "actual": "pass" if passed else "FAIL"})
	if not passed:
		push_error("IMP-002: " + name)

func intent(core: SessionLifecycle, mode := "new") -> Dictionary:
	sequence += 1
	return {"id": "case-%d" % sequence, "mode": mode, "origin": core.snapshot().session, "selection": {"stable_id": "fixture-draft-1", "revision": 1}}

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	check("normal entry has isolated startup storage", shell.controller.storage.context.root.begins_with(str(fixture.sandbox)))
	check("real DATA absence remains explicit", shell.controller.route == "mandatory_setup")
	check("CORE projects the checked startup setup route", shell.session_shell.core.snapshot().application == "setup")
	var core := Core.new()
	var provider := Provider.new()
	core.provider = provider
	check("CORE rejects entry before checked startup readiness", core.request(intent(core)).kind == "unavailable")
	core.startup_route_changed("main_menu")
	var results: Array[Dictionary] = []
	var milestones: Array[String] = []
	var notifications: Array[String] = []
	core.terminal.connect(func(result: Dictionary): results.append(result))
	core.milestone.connect(func(name: String, _context: Dictionary): milestones.append(name))
	core.state_changed.connect(func(_old: Dictionary, current: Dictionary, _reason: String):
		notifications.append(current.phase)
		check("notification sees committed snapshot", core.snapshot() == current and core.gates.ready == current.ready))
	var first := intent(core)
	check("new request reaches actual readiness", core.request(first).kind == "Succeeded" and core.gates.gameplay_input())
	var original: String = core.snapshot().session
	check("baseline precedes new readiness", milestones == ["baseline_ready", "new_session_ready"])
	check("same identity cannot initialize twice", core.request(first).kind == "Succeeded" and provider.initializations == 1)
	var changed := first.duplicate(true)
	changed.selection.revision = 2
	check("identity cannot change payload", core.request(changed).kind == "invalid")
	changed.id = "runtime-object"
	changed.selection = provider
	check("runtime references rejected from immutable intent", core.request(changed).kind == "invalid")
	provider.hold_preflight = true
	var a := intent(core)
	check("A preflight pending", core.request(a).kind == "pending")
	var old_ticket := core.ticket()
	check("B immediately busy", core.request(intent(core)).kind == "busy" and provider.prepares == 2)
	check("preflight retains but suspends old session", core.snapshot().session == original and not core.gates.simulation())
	var own_a := core.gates.acquire("owner-a", original, ["simulation", "input"])
	var own_b := core.gates.acquire("owner-b", original, ["simulation", "input", "hud"])
	check("cancel preflight accepted", core.cancel(old_ticket))
	check("cancel emits one terminal and preserves session", results.size() == 2 and results.back().kind == "Cancelled" and core.snapshot().session == original)
	check("stale preflight cannot complete", not core.complete_preflight(old_ticket, {"ok": true}) and results.size() == 2)
	check("foreign requester cannot release hold", not core.gates.release(own_a, "owner-b"))
	core.gates.release(own_a, "owner-a")
	check("closing one owner retains other hold", not core.gates.simulation())
	core.gates.release(own_b, "owner-b")
	check("all own holds released", core.gates.simulation())
	provider.hold_preflight = false
	provider.hold_readiness = true
	core.request(intent(core))
	check("living discard requires confirmation", core.snapshot().phase == "confirmation")
	check("declining consent preserves session", core.confirm(core.ticket(), false) and core.snapshot().session == original)
	core.request(intent(core))
	core.confirm(core.ticket(), true)
	var failed_ticket := core.ticket()
	check("replacement readiness pending remains gated", core.snapshot().phase == "initializing" and not core.gates.gameplay_input())
	check("post boundary cancellation refused", not core.cancel(failed_ticket))
	core.complete_readiness(failed_ticket, {"ok": false})
	check("readiness failure safely cleans and recovers", core.snapshot().session.is_empty() and core.snapshot().application == "recovery" and results.back().kind == "Failed" and not core.cleanup_blocked())
	check("duplicate readiness is stale", not core.complete_readiness(failed_ticket, {"ok": true, "services": provider.bindings()}))
	provider.hold_readiness = false
	core.request(intent(core))
	var second: String = core.snapshot().session
	check("retry obtains fresh session", second != original and core.gates.simulation())
	check("obsolete outgoing callbacks cannot reopen current input", not core.complete_preflight(old_ticket, {"ok": true}) and core.snapshot().session == second)
	provider.cleanup_ok = false
	core.request(intent(core, "return"))
	core.confirm(core.ticket(), true)
	var count := results.size()
	check("cleanup failure clears busy but blocks admission", not core.busy() and core.cleanup_blocked() and not core.gates.gameplay_input() and core.request(intent(core)).kind == "busy")
	var failed_cleanup: Dictionary = core._cleanup.ticket.duplicate(true)
	check("late success from completed failed cleanup is rejected", not core.complete_cleanup(failed_cleanup, {"ok": true}) and core.cleanup_blocked())
	var retained_ticket: Dictionary = provider.last_cleanup_ticket
	provider.hold_cleanup = true
	core.retry_cleanup()
	check("retry cannot mutate provider-retained old cleanup ticket", retained_ticket != provider.last_cleanup_ticket and not core.complete_cleanup(retained_ticket, {"ok": true}) and core.cleanup_blocked())
	core.complete_cleanup(provider.last_cleanup_ticket, {"ok": false})
	check("failed cleanup retry does not duplicate terminal", results.size() == count and core.cleanup_blocked())
	provider.hold_cleanup = false
	provider.cleanup_ok = true
	core.retry_cleanup()
	check("safe cleanup retry keeps old session retired", not core.cleanup_blocked() and core.snapshot().session.is_empty() and results.size() == count)
	core.recover_menu()
	check("recovery opens usable menu", core.snapshot().application == "menu" and milestones.back() == "menu_ready")
	var cleanup_count: int = provider.cleanups
	check("already menu return is unchanged no-op", core.request(intent(core, "return")).kind == "Succeeded" and provider.cleanups == cleanup_count)
	check("missing service inventory rejects readiness", not core.validate_bindings([]).ok)
	var services := provider.bindings()
	services.append(services[0].duplicate())
	check("duplicate required service rejected", not core.validate_bindings(services).ok)
	services = provider.bindings()
	services[0].provider = null
	check("missing required provider rejected", not core.validate_bindings(services).ok)
	services = provider.bindings()
	services.append({"role": "optional", "owner": "fixture", "lifetime": "session", "required": false, "ready": false, "fallback": "capability disabled"})
	check("declared optional fallback is allowed", core.validate_bindings(services).ok)
	core.request(intent(core))
	window_cases(core, provider)
	cadence_cases(core, provider)
	death_cases(core, provider, milestones)
	core.request(intent(core))
	var before_load: String = core.snapshot().session
	provider.prepare_ok = false
	check("failed native preparation preserves outgoing session", core.request(intent(core, "load")).kind == "Failed" and core.snapshot().session == before_load and core.gates.simulation())
	provider.prepare_ok = true
	core.request(intent(core, "load"))
	core.confirm(core.ticket(), true)
	check("load publishes restored rather than new character milestone", milestones.back() == "session_restored" and core.snapshot().session != before_load)
	await shell_cases(shell, fixture)
	reentrant_cases()
	core.dispose()
	var ok := checks.all(func(item: Dictionary): return item.actual == "pass")
	return {"ok": ok, "count": checks.size(), "fixture": "IMP-002-session-v1", "engine": Engine.get_version_info(), "display": DisplayServer.get_name(), "clock": "explicit eligible deltas; no wall-time simulation", "seed": "no RNG consumers", "checks": checks}

func reentrant_cases() -> void:
	var core := Core.new()
	core.provider = Provider.new()
	core.startup_route_changed("main_menu")
	core.request(intent(core))
	var batches: Array[String] = []
	core.state_changed.connect(func(_old: Dictionary, current: Dictionary, _reason: String):
		batches.append("state:" + current.phase)
		if current.phase == "confirmation":
			core.confirm(core.ticket(), true))
	core.milestone.connect(func(name: String, _context: Dictionary): batches.append("milestone:" + name))
	check("lifecycle snapshot is a read-only projection", core.snapshot().is_read_only())
	check("observer transition is deferred through notification boundary", core.request(intent(core)).kind == "Succeeded" and core.gates.simulation() and batches.has("milestone:new_session_ready"))
	core.dispose()
	core = Core.new()
	core.startup_route_changed("main_menu")
	var provider := Provider.new()
	core.provider = provider
	core.state_changed.connect(func(_old: Dictionary, current: Dictionary, _reason: String):
		if current.phase == "preflight":
			core.cancel(core.ticket()))
	var outgoing := intent(core)
	var admission: Array[String] = []
	var redelivery: Array[String] = []
	core.gates.changed.connect(func():
		if core._finishing:
			admission.append(core.request(intent(core)).kind)
			redelivery.append(core.request(outgoing).kind))
	check("observer cancellation prevents late preparation dispatch", core.request(outgoing).kind == "Cancelled" and provider.prepares == 0 and not core.busy())
	check("gate publication cannot admit into partially finished state", not admission.is_empty() and admission.all(func(kind: String): return kind == "busy"))
	check("same identity retains outcome during terminal publication", not redelivery.is_empty() and redelivery.all(func(kind: String): return kind == "Cancelled"))
	core.dispose()

func window_cases(core: SessionLifecycle, provider: RefCounted) -> void:
	var windows := Windows.new(core)
	var scope: String = core.snapshot().session
	core.gates.hud_bound = true
	var pause := windows.open("pause", scope)
	windows.remember_focus(pause.id, "Resume")
	var modal := windows.open("choice", scope, {"required_choice": true, "responses": ["cancel", "accept"]})
	check("covered pause retains own gate and HUD", not core.gates.simulation() and core.gates.hud_visible())
	check("close identifies target rather than next layer", windows.close(pause.id).kind == "stale")
	check("required choice blocks back", windows.close(modal.id).kind == "blocked")
	check("return to game honors required decisions", windows.return_to_game(scope).kind == "blocked" and windows.layers().size() == 2)
	var effects := [0]
	var owner := func(_response: String, _data: Dictionary) -> Dictionary:
		effects[0] += 1
		return {"ok": true}
	windows.respond(modal.id, "accept", owner)
	check("modal close restores pause focus and retains gate", windows.top().focus == "Resume" and not core.gates.gameplay_input())
	check("duplicate prompt response stale", windows.respond(modal.id, "accept", owner).kind == "stale" and effects[0] == 1)
	check("failed replacement preserves prior view and focus", windows.replace(pause.id, "replacement", func(_opening: Dictionary) -> Dictionary: return {"ok": false}).get("ok") == false and windows.top().focus == "Resume" and not core.gates.simulation())
	check("successful replacement retains suspension without handoff gap", windows.replace(pause.id, "pause", func(_opening: Dictionary) -> Dictionary: return {"ok": true, "data": {}}).kind == "applied" and not core.gates.simulation())
	windows.close(pause.id)
	check("pause close returns eligible gameplay without HUD anchor", core.gates.gameplay_input())
	core.gates.hud_bound = false
	windows.open("pause", scope)
	windows.open("child", scope)
	check("return to gameplay does not depend on HUD existence", windows.return_to_game(scope).kind == "applied" and core.gates.gameplay_input())
	core.gates.hud_bound = true
	var focus := core.gates.acquire("focus", "", ["simulation", "input"])
	var one := windows.open("pause", scope)
	windows.close(one.id)
	check("focus loss independently holds suspension", not core.gates.simulation())
	core.gates.release(focus, "focus")
	windows.no_ui_pause = true
	one = windows.open("live_inventory", scope)
	check("no UI pause separates simulation and input", core.gates.simulation() and not core.gates.gameplay_input())
	windows.close(one.id)
	one = windows.open("pending-choice", scope, {"responses": ["accept"]})
	var generation: int = windows.context_generation
	check("owner response may stay pending", windows.respond(one.id, "accept", func(_choice: String, _data: Dictionary) -> Dictionary: return {"pending": true}).pending)
	check("pending response rejects duplicates as busy", windows.respond(one.id, "accept", owner).kind == "busy")
	check("response completion is generation scoped", windows.complete_response(one.id, generation - 1, true).kind == "stale")
	check("current pending response closes once", windows.complete_response(one.id, generation, true).kind == "applied" and windows.complete_response(one.id, generation, true).kind == "stale")
	var hide_a := core.gates.acquire("a", scope, ["hud"])
	var hide_b := core.gates.acquire("b", scope, ["hud"])
	core.gates.release(hide_a, "a")
	check("HUD independent hide reasons", not core.gates.hud_visible())
	core.gates.release(hide_b, "b")
	core.gates.hud_preference = false
	check("HUD player preference survives gate release", not core.gates.hud_visible())
	core.gates.hud_preference = true
	windows.capture("inventory", true)
	windows.capture("inventory", false)
	windows.capture("options", true)
	check("brief tap captured; options wins one dispatch", windows.dispatch().action == "options" and windows.dispatch().kind == "none")
	windows.capture("options", true)
	check("held discrete input cannot repeat", windows.dispatch().kind == "none")
	windows.capture("options", false)
	windows.capture("quicksave", true)
	windows.capture("quickload", true)
	windows.capture("inventory", true)
	check("quick pair conflict removed before priority", windows.dispatch().action == "inventory" and not windows.last_feedback.is_empty())
	for action: String in Windows.PRIORITY:
		windows.capture(action, false)
		windows.capture(action, true)
		windows.capture(action, false)
		check("supported shortcut routes " + action, windows.dispatch().action == action)
	one = windows.open("modal", scope)
	windows.capture("inventory", true)
	check("modal does not fall through to gameplay shortcuts", windows.dispatch().kind == "blocked")
	var before: String = core.snapshot().session
	provider.hold_preflight = true
	core.request(intent(core))
	var stale := core.ticket()
	core.complete_preflight(stale, {"ok": true})
	core.confirm(core.ticket(), true)
	check("session retirement disposes windows and old holds", windows.top().is_empty() and core.snapshot().session != before and not core.gates.blocked("hud"))
	check("late old completion cannot alter new focus", not core.complete_preflight(stale, {"ok": true}) and windows.top().is_empty())
	provider.hold_preflight = false
	core.retiring.disconnect(windows.retire)

func cadence_cases(core: SessionLifecycle, _provider: RefCounted) -> void:
	var cadence := Cadence.new(core)
	var delivered: Array[String] = []
	var suspend := [0]
	var first := func(context: Dictionary) -> Dictionary:
		delivered.append("a:%d" % context.step)
		if context.step == 0:
			suspend[0] = core.gates.acquire("cadence-test", core.snapshot().session, ["simulation"])
		return {"ok": true}
	var second := func(context: Dictionary) -> Dictionary:
		delivered.append("b:%d" % context.step)
		return {"ok": true}
	check("cadence rejects invalid configuration", not cadence.configure(core.snapshot().session, 0.0, 2, []))
	check("fixture explicitly configures cadence and dependency order", cadence.configure(core.snapshot().session, 0.1, 2, [{"id": "a", "callback": first}, {"id": "b", "after": ["a"], "callback": second}]))
	cadence.advance(0.06)
	cadence.advance(0.07)
	check("midstep suspension preserves consumer cursor", delivered == ["a:0"] and cadence.cursor == 1 and is_equal_approx(cadence.accumulated, 0.13))
	cadence.advance(100.0)
	check("paused duration adds no simulation debt", is_equal_approx(cadence.accumulated, 0.13))
	core.gates.release(suspend[0], "cadence-test")
	cadence.advance(0.0)
	check("resume delivers remaining consumer once and retains fraction", delivered == ["a:0", "b:0"] and is_equal_approx(cadence.accumulated, 0.03))
	cadence.advance(1.0)
	check("bounded work retains active backlog", delivered.size() == 4 and is_equal_approx(cadence.accumulated, 0.93))
	check("running-session cadence cannot change", not cadence.configure(core.snapshot().session, 0.2, 2, []))
	core.request(intent(core, "return"))
	core.confirm(core.ticket(), true)
	check("session retirement clears cadence remainder and callbacks", cadence.scope.is_empty() and cadence.consumers.is_empty() and cadence.accumulated == 0.0)
	core.request(intent(core))
	var failed := Cadence.new(core)
	var attempts := [0]
	failed.configure(core.snapshot().session, 0.1, 2, [{"id": "failure", "callback": func(_context: Dictionary) -> Dictionary: attempts[0] += 1; return {"ok": false}}])
	failed.advance(0.1)
	failed.advance(0.1)
	check("required cadence failure gates and never blindly retries", not core.gates.simulation() and attempts[0] == 1)
	core.request(intent(core, "return"))
	core.confirm(core.ticket(), true)
	core.request(intent(core))

func death_cases(core: SessionLifecycle, provider: RefCounted, milestones: Array[String]) -> void:
	check("stale death rejected", not core.confirm_death("old", provider))
	check("confirmed death enters ended gameplay state", core.confirm_death(core.snapshot().session, provider) and not core.gates.gameplay_input())
	provider.hold_video = true
	core.request(intent(core, "death"))
	var video_ticket := core.ticket()
	check("death menu unusable until independent presentation finishes", core.snapshot().phase == "presentation" and milestones.back() == "session_ended")
	provider.menu_ok = false
	core.complete_presentation(video_ticket, {"outcome": "Skipped"})
	check("menu failure retains ended scope", core.snapshot().session.is_empty() and core.snapshot().application == "recovery")
	provider.menu_ok = true
	core.recover_menu()
	check("menu retry does not replay completed death presentation", provider.videos == 1 and milestones.back() == "menu_ready")
	check("duplicate skip cannot reopen menu", not core.complete_presentation(video_ticket, {"outcome": "Skipped"}))
	provider.hold_video = false

func find_button(shell: Control, text: String) -> Button:
	for child in shell.panel.get_children():
		if child is Button and child.text == text:
			return child
	return null

func click(shell: Control, text: String) -> void:
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var control := find_button(shell, text)
	check("reachable stock control " + text, control != null)
	if control == null:
		return
	if DisplayServer.get_name() == "headless":
		control.pressed.emit()
	else:
		control.grab_focus()
		var event := InputEventKey.new()
		event.keycode = KEY_ENTER
		event.pressed = true
		Input.parse_input_event(event)
		await shell.get_tree().process_frame
		event = InputEventKey.new()
		event.keycode = KEY_ENTER
		Input.parse_input_event(event)
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame

func shell_cases(shell: Control, fixture: Dictionary) -> void:
	var startup_provider = preload("res://tests/controlled_startup_provider.gd").new()
	startup_provider.resolved_source = str(fixture.sandbox).path_join("controlled-classic")
	shell.controller.providers = startup_provider
	shell.controller.check_content()
	var ui: RefCounted = shell.session_shell
	# This asset-independent legacy fixture replaces DATA with a deliberately
	# non-DATA startup provider. It cannot qualify a resolved calendar. Keep that
	# absent dependency explicit; calendar-clock tests the real composed boundary.
	ui.core.calendar.definitions = null
	var provider := Provider.new()
	ui.core.provider = provider
	ui.focus_changed(true)
	shell.render()
	var storage: RefCounted = shell.controller.storage.adapter
	var log_owner: Logger = shell.registered_logger
	await click(shell, "New Game")
	check("normal title routes to CORE provider and readiness", ui.core.snapshot().ready and provider.initializations == 1)
	await click(shell, "Pause")
	await click(shell, "Settings")
	check("nested settings remain suspended", ui.windows.layers().size() == 2 and not ui.core.gates.simulation())
	var accepted_before: bool = shell.controller.settings.value(shell.controller.settings.accepted, "startup/show_setup")
	for child in shell.panel.get_children():
		if child is CheckBox:
			child.button_pressed = not child.button_pressed
	ui.options()
	await click(shell, "Keep Editing")
	check("dirty settings retain draft through child decision", ui.windows.top().data.get("draft") == not accepted_before)
	ui.options()
	await click(shell, "Discard")
	check("discard settings returns pause without applying", ui.windows.top().window == "pause" and shell.controller.settings.value(shell.controller.settings.accepted, "startup/show_setup") == accepted_before)
	await click(shell, "Settings")
	await click(shell, "Cancel / Back")
	check("settings close restores pause layer", ui.windows.top().window == "pause")
	if DisplayServer.get_name() != "headless":
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		shell.get_viewport().get_texture().get_image().save_png(str(fixture.sandbox).path_join("pause.png"))
	await click(shell, "Resume")
	check("normal Resume releases pause gate", ui.core.gates.simulation())
	await click(shell, "Pause")
	await click(shell, "Return to Title")
	check("normal return requires discard consent", ui.core.snapshot().phase == "confirmation")
	await click(shell, "Keep Playing")
	check("declining retains pause and session", ui.core.snapshot().ready and ui.windows.top().window == "pause")
	await click(shell, "Return to Title")
	await click(shell, "Discard and Continue")
	check("normal title return tears down windows", ui.core.snapshot().session.is_empty() and ui.windows.top().is_empty())
	check("application lease/settings/logger retained across session change", shell.controller.storage.adapter == storage and shell.registered_logger == log_owner and shell.controller.logger.initialized and shell.controller.settings != null)
	await click(shell, "New Game")
	ui.request_quit()
	check("quit prompts for live session and deduplicates", ui.quit_phase == "confirmation")
	check("pending shutdown blocks conflicting admission", ui.request("new").kind == "busy")
	var token: int = ui._quit_hold
	ui.request_quit()
	check("repeated quit retains one intent", token == ui._quit_hold)
	ui.cancel_quit()
	check("cancel quit preserves live session", ui.quit_phase.is_empty() and ui.core.gates.gameplay_input())
	var submissions := [0]
	var prompt_id: String = ui.show_prompt({"kind": "text", "text": "Fixture name", "responses": ["submit", "cancel"], "safe_response": "cancel"}, func(result: Dictionary) -> Dictionary:
		submissions[0] += 1
		return {"ok": result.response == "cancel" or result.text == "Accepted", "reason": "Enter Accepted"})
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var prompt: Control
	for child in shell.panel.get_children():
		if child.get_script() == preload("res://scripts/session/session_prompt.gd"):
			prompt = child
	check("stock text prompt rendered", prompt != null)
	if prompt != null:
		prompt.field.grab_focus()
		await shell.get_tree().process_frame
		if DisplayServer.get_name() != "headless":
			# Exercise local LineEdit focus with another actual native window owning
			# OS focus. This checks safe polling, not physical IME qualification.
			var main_window: Window = shell.get_window()
			var embedded_before: bool = main_window.gui_embed_subwindows
			main_window.gui_embed_subwindows = false
			var focus_peer := Window.new()
			focus_peer.title = "Controlled native focus fixture"
			focus_peer.size = Vector2i(64,64)
			focus_peer.position = Vector2i(-32000,-32000)
			main_window.add_child(focus_peer)
			focus_peer.show()
			focus_peer.grab_focus()
			await shell.get_tree().process_frame
			await shell.get_tree().process_frame
			var composition_before: bool = prompt._composition
			var composition_frame_before: int = prompt._composition_end_frame
			# Controlled pending composition must not end from another window's
			# empty IME buffer. No physical IME input is being certified here.
			prompt._composition = true
			prompt._process(0.0)
			check("rendered unfocused prompt preserves modal and draft",not main_window.has_focus() and prompt.field.has_focus() and prompt._composition and prompt._composition_end_frame == composition_frame_before and ui.windows.top().id == prompt_id and submissions[0] == 0)
			prompt._composition = composition_before
			prompt._composition_end_frame = composition_frame_before
			focus_peer.queue_free()
			await shell.get_tree().process_frame
			main_window.gui_embed_subwindows = embedded_before
			main_window.grab_focus()
			prompt.field.grab_focus()
		ui.windows.update_data(prompt_id, {"draft": "Rejected"})
		prompt.field.text = "Rejected"
		prompt.submit("submit")
		check("text rejection preserves prompt and draft", ui.windows.top().id == prompt_id and prompt.field.text == "Rejected" and prompt.reason.text == "Enter Accepted")
		ui.windows.update_data(prompt_id, {"draft": "Accepted"})
		prompt.field.text = "Accepted"
		prompt.submit("submit")
		check("accepted text closes prompt once", ui.windows.top().is_empty() and submissions[0] == 2)
		check("retired prompt cannot submit again", prompt.submit("submit").kind == "stale" and submissions[0] == 2)
	ui.show_prompt({"kind": "choice", "text": "Cancel fixture", "responses": ["accept", "cancel"], "safe_response": "cancel"}, func(result: Dictionary) -> Dictionary:
		submissions[0] += 1
		return {"ok": result.response == "cancel"})
	ui.options()
	check("Back reports prompt cancellation once to owner", ui.windows.top().is_empty() and submissions[0] == 3)
	if DisplayServer.get_name() != "headless":
		ui.pause()
		shell.get_window().size = Vector2i(800, 600)
		await shell.get_tree().process_frame
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var resume := find_button(shell, "Resume")
		check("rendered reflow retains reachable hit regions", resume != null and resume.get_global_rect().end.x <= shell.get_viewport_rect().end.x)
		shell.get_viewport().get_texture().get_image().save_png(str(fixture.sandbox).path_join("pause-small.png"))
	var settings: StartupSettingsOwner = shell.controller.settings
	var committed := FileAccess.get_file_as_string(settings.path)
	shell.controller.storage.adapter.faults.settings_stage = true
	settings.apply({"startup/show_setup": not settings.value(settings.accepted, "startup/show_setup")})
	shell.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	check("OS close uses the same shutdown consent", ui.quit_phase == "confirmation")
	ui.quit_consent_scope = ui.core.snapshot().session
	ui.advance_shutdown()
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	check("shutdown tears down session before preference publication", ui.core.snapshot().session.is_empty() and ui.windows.top().is_empty() and ui.quit_phase == "preferences")
	check("failed exit preferences preserve committed file and lease", FileAccess.get_file_as_string(settings.path) == committed and shell.controller.storage.adapter == storage)
	check("failed publication offers explicit retry and discard", find_button(shell, "Retry") != null and find_button(shell, "Quit Without Saving Preferences") != null)
	ui.advance_shutdown()
	check("retrying failed shutdown publication stays in recovery", ui.quit_phase == "preferences")
	# Keep injected failure until the runner publishes its report and exits. Ordinary
	# shutdown would only exit after Retry succeeds or explicit discard is selected.


