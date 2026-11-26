extends RefCounted
## Review-only shell composition. Entry/activity authorization is controlled;
## policy publication, lifecycle gates, clock, snapshots and stock Quit are real.
var core: RefCounted
var entry: RefCounted
var serial := 0
var saved: Dictionary = {}
var report := ""
var shell_host: Control
func request(mode: String) -> void:
	serial += 1
	entry.restored = saved
	var result: Dictionary = core.request({"id":"review-calendar-"+str(serial),"mode":mode,"origin":core.snapshot().session,"selection":{"outside_privateers_hold":false}})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)
	if mode == "load" and core.snapshot().ready: shell_host.session_shell.pause()
	report = "Restored exact captured clock (zero elapsed)." if mode == "load" and core.snapshot().ready else str(result.kind)
func capture_clock() -> void:
	var hold: int = core.gates.acquire("calendar-review-capture",core.snapshot().session,["simulation"])
	var captured: Dictionary = core.calendar.capture_snapshot()
	core.gates.release(hold,"calendar-review-capture")
	if captured.ok:
		saved = captured.state
		report = "Captured %d ms; fraction %d / 10^12 ms." % [saved.timestamp,saved.fraction]
	else: report = captured.reason
func add_hour() -> void:
	serial += 1
	var holder: String = core.calendar.activity_hold_owner("controlled-rest")
	var hold: int = core.gates.acquire(holder,core.snapshot().session,["simulation"])
	var result: Dictionary = core.calendar.activity(entry,{"session":core.snapshot().session,"owner":"controlled-rest","operation":"review-hour-"+str(serial),"reason":"controlled-review-hour","duration_ms":3600000})
	core.gates.release(hold,holder)
	report = "Controlled explicit hour committed." if result.ok else result.reason
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	shell_host = shell
	core = shell.session_shell.core
	shell.controller.settings.effective["startup/show_setup"] = true
	shell.controller.select_folder(fixture.classic_source)
	shell.controller.continue_to_menu("run")
	shell.session_shell.synchronize_startup()
	entry = preload("res://tests/controlled_calendar_entry.gd").new()
	entry.core = core
	core.provider = entry
	request("new")
	if not core.snapshot().ready: return {"ok":false,"checks":[],"count":0,"reason":"Controlled review entry failed."}
	# Reserve a review-only top area; the actual stock menus keep their handlers
	# and their scroll container below it, including Quit/discard confirmation.
	var stock_margin: MarginContainer = shell.panel.get_parent().get_parent()
	stock_margin.add_theme_constant_override("margin_top",370)
	var box := PanelContainer.new()
	box.position = Vector2(36,20)
	box.custom_minimum_size = Vector2(1080,0)
	shell.add_child(box)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",10)
	box.add_child(column)
	var heading := Label.new()
	heading.text = "IMP-014 · Calendar and clock review"
	heading.add_theme_font_size_override("font_size",24)
	column.add_child(heading)
	var labels := Label.new()
	labels.text = "Real CORE / DATA / TIME. Controlled entry and explicit activity.\nNo quest, effect, rest, travel or SAVE scheduler qualification."
	column.add_child(labels)
	var readout := Label.new()
	readout.add_theme_font_size_override("font_size",20)
	column.add_child(readout)
	var actions := {}
	var buttons := GridContainer.new()
	buttons.columns = 3
	column.add_child(buttons)
	for text in ["Pause / Resume","Capture exact clock","Restore captured clock","Controlled explicit +1 hour","New character clock","Quit"]:
		var button := Button.new()
		button.text = text
		buttons.add_child(button)
		actions[text] = button
		var action := func():
			match text:
				"Pause / Resume":
					if shell.session_shell.windows.top().get("window") == "pause": shell.session_shell.windows.close(shell.session_shell.windows.top().id,true)
					else: shell.session_shell.pause()
				"Capture exact clock": capture_clock()
				"Restore captured clock":
					if not saved.is_empty(): request("load")
				"Controlled explicit +1 hour": add_hour()
				"New character clock": request("new")
				"Quit": shell.session_shell.request_quit()
		button.pressed.connect(action)
	var smoke: bool = fixture.get("review_smoke",false)
	var checks: Array = []
	for frame in range(1,1000000000):
		await shell.get_tree().process_frame
		if not is_instance_valid(box): break
		var view: Dictionary = core.calendar.query()
		if view.ok:
			var d: Dictionary = view.calendar
			readout.text = "Year %d · Month %02d · Day %02d · %02d:%02d:%02d.%03d\nWeekday index %d · %s · Day of year %d\nNative %d ms · fraction %d / 10^12 ms\n%s · calendar rate %.6f×\n%s" % [d.year,d.month,d.day,d.hour,d.minute,d.second,d.millisecond,d.weekday,d.season,d.day_of_year,view.timestamp,view.fraction,"Running" if core.gates.simulation() else "Suspended",float(view.rate_units)/view.rate_scale,report]
		if smoke and frame == 8:
			actions["Pause / Resume"].pressed.emit()
			actions["Capture exact clock"].pressed.emit()
			checks.append({"scenario":"review actual pause and capture","expected":true,"actual":not core.gates.simulation() and not saved.is_empty()})
		if smoke and frame == 12:
			checks.append({"scenario":"review paused clock unchanged","expected":saved.timestamp,"actual":core.calendar.query().timestamp})
			actions["Pause / Resume"].pressed.emit()
			actions["Controlled explicit +1 hour"].pressed.emit()
			checks.append({"scenario":"review controlled explicit hour","expected":saved.timestamp+3600000,"actual":core.calendar.query().timestamp})
		if smoke and frame == 13:
			shell.session_shell.pause()
			actions["Restore captured clock"].pressed.emit()
			checks.append({"scenario":"review actual restore","expected":saved.timestamp,"actual":core.calendar.query().timestamp})
		if smoke and frame == 18:
			checks.append({"scenario":"review numeric readout formatted","expected":true,"actual":readout.text.begins_with("Year 405") and not "%" in readout.text})
			await RenderingServer.frame_post_draw
			var image := shell.get_viewport().get_texture().get_image()
			image.save_png(str(fixture.sandbox).path_join("calendar-review.png"))
			checks.append({"scenario":"review rendered capture","expected":false,"actual":image.is_empty()})
			break
	return {"ok":checks.all(func(c): return c.expected == c.actual),"checks":checks,"count":checks.size(),"review_smoke":smoke,"human_pass":false,"fixture":fixture.fixture,"engine":Engine.get_version_info(),"display":DisplayServer.get_name()}
