extends RefCounted
## Human review only. Real shell/CORE/DATA/TIME with labelled controlled owners.
const Fixtures = preload("res://tests/scheduler_cases.gd")
var shell: Control
var core: RefCounted
var entry: RefCounted
var provider: RefCounted
var trace: Array = []
var serial := 0
var latest: Dictionary = {}
var terminal: Dictionary = {}
var initial := 0
var smoke_mode := false
var requested_ms := 4000

func begin(mode: String) -> void:
	serial += 1
	trace.clear()
	provider = Fixtures.Owner.new()
	provider.id = "controlled"
	var count := 3 if smoke_mode else 120
	provider.offsets = []
	for index in count: provider.offsets.append((index+1)*1000)
	requested_ms = (count+1)*1000
	provider.trace = trace
	if mode == "interrupt": provider.interrupt_at = 1 if smoke_mode else 59
	if mode == "recovery": provider.ambiguous_at = 1 if smoke_mode else 59
	entry.peers = [{"role":"controlled-due-review","owner":"TIME","lifetime":"session","required":true,"ready":true,"provider":provider,"calendar_due_work":true,"calendar_schedule":{"id":"controlled","version":1,"after":[],"interacts":[]}}]
	core.request({"id":"scheduler-review-entry-"+str(serial),"mode":"new","origin":core.snapshot().session,"selection":{"outside_privateers_hold":false}})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)
	if not core.snapshot().ready:
		latest = {"kind":"entry-failed"}
		return
	initial = core.calendar.query().timestamp
	provider.origin = initial
	provider.scope = core.snapshot().session
	# Keep the finite review endpoint visible after handoff. This independent
	# activity hold is not TIME's settlement hold and is labelled in the panel.
	core.gates.acquire(core.calendar.activity_hold_owner("controlled-rest"),core.snapshot().session,["simulation"])
	core.calendar.scheduler.budget = 1
	terminal = {}
	latest = core.advance_calendar_request(entry,{"session":core.snapshot().session,"owner":"controlled-rest","operation":"review-"+str(serial),"reason":"controlled-scheduler-review","duration_ms":requested_ms,"start":initial,"endpoint":initial+requested_ms})

func retry() -> void:
	if core.calendar.pending():
		provider.reconciled = true
		latest = shell.session_shell.retry_calendar_settlement()

func run(host: Control, fixture: Dictionary) -> Dictionary:
	shell = host
	smoke_mode = fixture.get("review_smoke",false)
	core = shell.session_shell.core
	shell.controller.settings.effective["startup/show_setup"] = true
	shell.controller.select_folder(fixture.classic_source)
	shell.controller.continue_to_menu("run")
	shell.session_shell.synchronize_startup()
	entry = preload("res://tests/controlled_calendar_entry.gd").new()
	entry.core = core
	core.provider = entry
	core.calendar.settled.connect(func(outcome: Dictionary): terminal = outcome.duplicate(true))
	var margin: MarginContainer = shell.panel.get_parent().get_parent()
	margin.add_theme_constant_override("margin_top",355)
	var box := PanelContainer.new()
	box.position = Vector2(36,20)
	box.custom_minimum_size = Vector2(1080,0)
	shell.add_child(box)
	var column := VBoxContainer.new()
	box.add_child(column)
	var title := Label.new()
	title.text = "IMP-014 · Due-work scheduler · CONTROLLED OWNERS"
	title.add_theme_font_size_override("font_size",24)
	column.add_child(title)
	var note := Label.new()
	note.text = "Real shell / CORE / DATA / TIME. Budget = one work unit per physics pass.\nControlled activity holds ordinary simulation after completion to preserve the endpoint.\nNo real rest, QUEST, MAGIC, MOVE/CHAR interval bridge or native SAVE qualification."
	column.add_child(note)
	var readout := Label.new()
	readout.add_theme_font_size_override("font_size",18)
	column.add_child(readout)
	var buttons := HBoxContainer.new()
	column.add_child(buttons)
	for text: String in ["Run completion","Run interruption","Run failure","Reconcile / Retry","Pause / Resume","Quit"]:
		var button := Button.new()
		button.text = text
		buttons.add_child(button)
		var action := func():
			match text:
				"Run completion": begin("complete")
				"Run interruption": begin("interrupt")
				"Run failure": begin("recovery")
				"Reconcile / Retry": retry()
				"Pause / Resume":
					if shell.session_shell.windows.top().get("window") == "pause": shell.session_shell.windows.close(shell.session_shell.windows.top().id,true)
					else: shell.session_shell.pause()
				"Quit": shell.session_shell.request_quit()
		button.pressed.connect(action)
	begin("complete")
	var checks: Array = []
	var smoke: bool = fixture.get("review_smoke",false)
	if smoke: checks.append({"scenario":"review budget holds consequential input","expected":false,"actual":core.gates.gameplay_input()})
	var phase := 0
	var frames := 0
	while is_instance_valid(box):
		await shell.get_tree().process_frame
		frames += 1
		if core.calendar.pending(): latest = core.calendar.scheduler.operation.result.duplicate(true)
		elif not terminal.is_empty(): latest = terminal
		var time: Dictionary = core.calendar.query()
		readout.text = "Outcome: %s · committed: %d / requested: %d ms\nNative: %d · fraction: %d / 10^12 ms\nGameplay input: %s · simulation: %s · settled: %s\nControlled effects: %d · recent: %s\nFailure requires Reconcile / Retry; completed effects must not repeat." % [latest.get("kind",""),latest.get("actual_ms",0),requested_ms,time.get("timestamp",0),time.get("fraction",0),str(core.gates.gameplay_input()),str(core.gates.simulation()),str(time.get("settled",false)),trace.size(),str(trace.slice(maxi(0,trace.size()-4)))]
		if not smoke: continue
		if phase == 0 and latest.get("kind") == "completed":
			checks.append({"scenario":"review deterministic completion","expected":[4000,["controlled:0","controlled:1","controlled:2"]],"actual":[latest.actual_ms,trace.duplicate()]})
			begin("interrupt")
			phase = 1
		elif phase == 1 and latest.get("kind") == "interrupted":
			checks.append({"scenario":"review middle interruption","expected":[2000,2],"actual":[latest.actual_ms,trace.size()]})
			begin("recovery")
			phase = 2
		elif phase == 2 and latest.get("kind") == "failed":
			checks.append({"scenario":"review ambiguous failure gated","expected":[2000,false,2],"actual":[latest.actual_ms,core.gates.gameplay_input(),trace.size()]})
			retry()
			phase = 3
		elif phase == 3 and latest.get("kind") == "completed":
			checks.append({"scenario":"review reconciled without replay","expected":[4000,3,3],"actual":[latest.actual_ms,trace.size(),provider.calls]})
			await RenderingServer.frame_post_draw
			var image := shell.get_viewport().get_texture().get_image()
			image.save_png(str(fixture.sandbox).path_join("scheduler-review.png"))
			checks.append({"scenario":"review rendered capture","expected":false,"actual":image.is_empty()})
			break
		if frames > 1000: break
	return {"ok":checks.size() == 6 and checks.all(func(check): return check.expected == check.actual),"checks":checks,"count":checks.size(),"review_smoke":smoke,"human_pass":false,"fixture":fixture.fixture,"engine":Engine.get_version_info(),"display":DisplayServer.get_name()}
