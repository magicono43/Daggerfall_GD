extends RefCounted
## Labelled controlled proof UI; ordinary stock input, pause and quit remain.
const Fixtures = preload("res://tests/activity_policy_cases.gd")
var shell: Control
var core: RefCounted
var entry: RefCounted
var provider: RefCounted
var interrupt: RefCounted
var serial := 0
var latest := {}
var terminal := {}
var chronological := {}
var request := {}

func begin(mode: String) -> void:
	serial += 1
	provider = Fixtures.RangeOwner.new()
	provider.id = "range"
	provider.stream = 120
	var first: int = preload("res://scripts/time/calendar.gd").encode(preload("res://scripts/data/calendar_policy.gd").normalized(JSON.parse_string(FileAccess.get_file_as_string("res://content/time/calendar.json")).entries[0].value).opening).timestamp+1
	provider.policy = {"mode":"bulk","proof":"controlled-affine-v1","context":"controlled-route","reasons":["controlled-segment"],"first":first,"period":1,"count":120,"revision":1,"endpoint_effects":false,"selection":"all-equivalent"}
	var declaration := {"id":"range","version":1,"after":[],"interacts":[]}
	if mode != "chronological": declaration.activity_policy = provider.policy.duplicate(true)
	entry.peers = [{"role":"controlled-range-review","owner":"TIME","lifetime":"session","required":true,"ready":true,"provider":provider,"calendar_due_work":true,"calendar_schedule":declaration}]
	interrupt = Fixtures.Owner.new()
	if mode == "interrupt":
		interrupt.id = "interrupt"
		interrupt.offsets = [60]
		interrupt.interrupt_at = 0
		entry.peers.append({"role":"controlled-interrupt","owner":"TIME","lifetime":"session","required":true,"ready":true,"provider":interrupt,"calendar_due_work":true,"calendar_schedule":{"id":"interrupt","version":1,"after":[],"interacts":[]}})
	if mode == "failure": provider.ambiguous = true
	core.request({"id":"activity-review-"+str(serial),"mode":"new","origin":core.snapshot().session,"selection":{"outside_privateers_hold":false}})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)
	for p in [provider,interrupt]:
		p.origin = core.calendar.query().timestamp
		p.scope = core.snapshot().session
	core.gates.acquire(core.calendar.activity_hold_owner("controlled-rest"),core.snapshot().session,["simulation"])
	core.calendar.scheduler.budget = 1
	terminal = {}
	request = {"session":core.snapshot().session,"owner":"controlled-rest","operation":"controlled-review-"+str(serial),"reason":"controlled-segment","context":"controlled-route","duration_ms":121}
	latest = core.advance_calendar_request(entry,request)

func retry() -> void:
	provider.recovery = true
	latest = shell.session_shell.retry_calendar_settlement()

func query_text() -> String:
	var time: int = (405*360+1)*preload("res://scripts/time/calendar.gd").DAY
	var a: Dictionary = core.calendar.regional_holidays("packs/classic#region-24",time)
	var b: Dictionary = core.calendar.regional_holidays("packs/classic#region-00",time)
	return "PURE QUERY · year 405 / day 2 · explicit regions\nregion-24: %s · region-00: %s" % [str(a.get("holidays",[]).map(func(h): return h.id)),str(b.get("holidays",[]).map(func(h): return h.id))]

func run(host: Control, fixture: Dictionary) -> Dictionary:
	shell = host
	core = shell.session_shell.core
	shell.controller.settings.effective["startup/show_setup"] = true
	shell.controller.select_folder(fixture.classic_source)
	shell.controller.continue_to_menu("run")
	shell.session_shell.synchronize_startup()
	entry = preload("res://tests/controlled_calendar_entry.gd").new()
	entry.core = core
	core.provider = entry
	core.calendar.settled.connect(func(result): terminal = result.duplicate(true))
	shell.panel.get_parent().get_parent().add_theme_constant_override("margin_top",425)
	var box := PanelContainer.new()
	box.position = Vector2(30,16)
	box.custom_minimum_size = Vector2(1120,0)
	shell.add_child(box)
	var column := VBoxContainer.new()
	box.add_child(column)
	var title := Label.new()
	title.text = "IMP-014 increment 3 · CONTROLLED ACTIVITY / HOLIDAY QUERIES"
	column.add_child(title)
	var note := Label.new()
	note.text = "Real shell / CORE / DATA / TIME. No real rest, travel, prison, MOVE/CHAR or SAVE proof.\nAssigned increments = 3; no RNG. Ordinary simulation held after completion for review."
	column.add_child(note)
	var readout := Label.new()
	column.add_child(readout)
	var query := Label.new()
	column.add_child(query)
	var buttons := HBoxContainer.new()
	column.add_child(buttons)
	for text in ["Chronological","Bulk","Interrupt","Failure","Reconcile / Retry","Pause / Resume","Quit"]:
		var button := Button.new()
		button.text = text
		buttons.add_child(button)
		var action := func():
			match text:
				"Chronological": begin("chronological")
				"Bulk": begin("bulk")
				"Interrupt": begin("interrupt")
				"Failure": begin("failure")
				"Reconcile / Retry": retry()
				"Pause / Resume":
					if shell.session_shell.windows.top().get("window") == "pause": shell.session_shell.windows.close(shell.session_shell.windows.top().id,true)
					else: shell.session_shell.pause()
				"Quit": shell.session_shell.request_quit()
		button.pressed.connect(action)
	begin("chronological")
	var checks: Array = []
	var smoke: bool = fixture.get("review_smoke",false)
	if smoke: checks.append({"scenario":"activity review pending input gated","expected":false,"actual":core.gates.gameplay_input()})
	var phase := 0
	var frames := 0
	while is_instance_valid(box):
		await shell.get_tree().process_frame
		frames += 1
		if core.calendar.pending(): latest = core.calendar.scheduler.operation.result.duplicate(true)
		elif not terminal.is_empty(): latest = terminal
		var time: Dictionary = core.calendar.query()
		readout.text = "Outcome %s · actual %d / requested 121 ms · settled %s\nState %s · bulk calls %d\nNative %d · fraction %d / 10^12 · gameplay input %s\nChronological reference %s" % [latest.get("kind",""),latest.get("actual_ms",0),str(time.settled),str(provider.state),provider.bulk_calls,time.timestamp,time.fraction,str(core.gates.gameplay_input()),str(chronological)]
		query.text = query_text()
		if not smoke:
			if latest.get("kind") == "completed" and provider.bulk_calls == 0: chronological = provider.state.duplicate(true)
			continue
		if frames > 1600: break
		if phase == 0 and latest.get("kind") == "completed":
			chronological = provider.state.duplicate(true)
			checks.append({"scenario":"activity review chronological endpoint","expected":121,"actual":latest.actual_ms})
			begin("bulk")
			phase = 1
		elif phase == 1 and latest.get("kind") == "completed":
			checks.append({"scenario":"activity review bulk observed equivalence","expected":chronological,"actual":provider.state.duplicate(true)})
			begin("interrupt")
			phase = 2
		elif phase == 2 and latest.get("kind") == "interrupted":
			checks.append({"scenario":"activity review actual interruption","expected":[60,60],"actual":[latest.actual_ms,provider.state.count]})
			begin("failure")
			phase = 3
		elif phase == 3 and latest.get("kind") == "failed":
			checks.append({"scenario":"activity review ambiguous holds","expected":[120,1,false],"actual":[provider.state.count,provider.bulk_calls,core.gates.gameplay_input()]})
			retry()
			phase = 4
		elif phase == 4 and latest.get("kind") == "completed":
			checks.append({"scenario":"activity review recovery no replay","expected":[121,120,1],"actual":[latest.actual_ms,provider.state.count,provider.bulk_calls]})
			var before: Dictionary = core.calendar.query()
			var rng: Dictionary = core.randomness.snapshot()
			query_text()
			checks.append({"scenario":"activity review pure explicit queries","expected":[before,rng],"actual":[core.calendar.query(),core.randomness.snapshot()]})
			await RenderingServer.frame_post_draw
			var image := shell.get_viewport().get_texture().get_image()
			image.save_png(str(fixture.sandbox).path_join("activity-review.png"))
			checks.append({"scenario":"activity review rendered capture","expected":false,"actual":image.is_empty()})
			break
	return {"ok":checks.size() == 8 and checks.all(func(c):return c.expected == c.actual),"checks":checks,"count":checks.size(),"review_smoke":smoke,"human_pass":false,"fixture":fixture.fixture,"engine":Engine.get_version_info(),"display":DisplayServer.get_name()}
