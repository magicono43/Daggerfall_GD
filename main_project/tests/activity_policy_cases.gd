extends "res://tests/scheduler_cases.gd"
## Controlled fixed-recurrence proof: no RNG or per-tick public notifications.
## Interactions observe assigned state only at declared external boundaries.
const Policies = preload("res://scripts/time/activity_policies.gd")
const Holiday = preload("res://scripts/data/holiday_definitions.gd")
class RangeOwner extends Owner:
	var policy := {}
	var state := {"balance":0,"weighted":0,"last":-1,"count":0}
	var gain := 3
	var enabled := true
	var bulk_calls := 0
	var ambiguous := false
	var recovery := false
	var malformed_range := false
	var malformed_extra := false
	var ranges: Array = []
	var selected: Array = []
	var approval := true
	var range_callback: Callable
	var fail_before_range := false
	func calendar_next_due(packet: Dictionary) -> Dictionary:
		if not enabled: return {"kind":"none"}
		return super.calendar_next_due(packet)
	func calendar_apply_due(packet: Dictionary) -> Dictionary:
		var index := int(packet.occurrence)
		state.balance += gain
		state.weighted += (index+1)*gain
		state.count += 1
		state.last = index
		return super.calendar_apply_due(packet)
	func calendar_range_current(_packet: Dictionary) -> Dictionary:
		return {"kind":"current","policy":policy} if approval else {"kind":"chronological"}
	func calendar_apply_range(packet: Dictionary) -> Dictionary:
		bulk_calls += 1
		if range_callback.is_valid(): range_callback.call(packet)
		if packet.session != scope: return {"kind":"retired"}
		if fail_before_range and not recovery: return {"kind":"failed"}
		if not ranges.is_empty() and packet.coverage.range_start < ranges[-1].range_end: return {"kind":"overlap"}
		var c: Dictionary = packet.coverage
		if policy.mode == "bulk":
			# Closed form for identical assigned increments. No per-occurrence loop.
			state.balance += c.count*gain
			state.weighted += c.count*(c.first_index+c.last_index+2)/2*gain
			state.count += c.count
			state.last = c.last_index
		else:
			selected.append_array(c.selected)
		ranges.append(c.duplicate(true))
		var result := packet.duplicate(true)
		result.kind = "completed"
		receipts[str(packet.operation)+":"+str(packet.segment)] = result.duplicate(true)
		if malformed_range: result.coverage.count = float(result.coverage.count)
		if malformed_extra: result.retry_authorized = true
		return {"kind":"ambiguous"} if ambiguous else result
	func calendar_range_outcome(packet: Dictionary) -> Dictionary:
		if not recovery: return {"kind":"unknown"}
		if fail_before_range and receipts.is_empty():
			var authorized := packet.duplicate(true)
			authorized.kind = "not-applied"
			authorized.retry_authorized = true
			return authorized
		return receipts.get(str(packet.operation)+":"+str(packet.segment),{"kind":"unknown"})

func ranged(mode: String, count: int) -> RangeOwner:
	var p := RangeOwner.new()
	p.id = "range"
	p.stream = count
	p.trace = trace
	var first: int = Calendar.encode(preload("res://scripts/data/calendar_policy.gd").normalized(JSON.parse_string(FileAccess.get_file_as_string("res://content/time/calendar.json")).entries[0].value).opening).timestamp+1
	p.policy = {"mode":mode,"proof":"controlled-affine-v1","context":"controlled-route","reasons":["controlled-segment"],"first":first,"period":1,"count":count,"revision":1,"endpoint_effects":false,"selection":{"bulk":"all-equivalent","coalesced":"latest-missed-and-exact","skipped":"exact-only","endpoint":"destination-only"}[mode]}
	entry.peers.append({"role":"controlled-range","owner":"TIME","lifetime":"session","required":true,"ready":true,"provider":p,"calendar_due_work":true,"calendar_schedule":{"id":p.id,"version":1,"after":[],"interacts":[],"activity_policy":p.policy.duplicate(true)}})
	return p

func activity_request(duration: int) -> Dictionary:
	var req := request(duration)
	req.context = "controlled-route"
	return req

func check(label: String, expected: Variant, actual: Variant) -> void:
	harness.check("activity "+label,expected,actual)

func run(runner: RefCounted, shell: Control) -> Dictionary:
	harness = runner
	core = shell.session_shell.core
	source = shell.session_shell
	entry = core.provider
	var evidence := {}
	for budget in [1,64]:
		var reference := {}
		for bulk in [false,true]:
			entry.peers = []
			trace.clear()
			var p := ranged("bulk",3001)
			if not bulk: entry.peers[-1].calendar_schedule.erase("activity_policy")
			var observations: Array = []
			var interaction := owner("change",[1500],["range"],["range"])
			interaction.callback = func(_packet):
				observations.append(p.state.duplicate(true))
				p.gain = 7
			start(budget)
			var before_rng: Dictionary = core.randomness.snapshot()
			var started := Time.get_ticks_usec()
			var memory := OS.get_static_memory_usage()
			var req := activity_request(3001)
			var result := drain(core.advance_calendar_request(entry,req))
			var actual := {"state":p.state.duplicate(true),"observations":observations,"actual":result.actual_ms,"fraction":result.fraction,"kind":result.kind}
			if not bulk: reference = actual
			else:
				check("equivalent observed state budget "+str(budget),reference,actual)
				check("bounded bulk calls budget "+str(budget),true,p.bulk_calls <= 2)
				check("bulk exact coverage budget "+str(budget),3000,p.ranges.reduce(func(total,c): return total+c.count,0))
			check("RNG neutral "+str(budget)+" "+str(bulk),before_rng,core.randomness.snapshot())
			check("request retry "+str(budget)+" "+str(bulk),result,core.advance_calendar_request(entry,req))
			evidence[str(budget)+"-"+str(bulk)] = {"usec":Time.get_ticks_usec()-started,"memory_bytes":OS.get_static_memory_usage()-memory,"bulk_calls":p.bulk_calls,"state":actual}
	var combined := {}
	for split in [false,true]:
		entry.peers = []
		var p := ranged("bulk",201)
		start(1)
		harness.tick(core,source,1)
		var fraction: int = core.calendar.query().fraction
		if split: drain(core.advance_calendar_request(entry,activity_request(99)))
		var result := drain(core.advance_calendar_request(entry,activity_request(102 if split else 201)))
		var state := {"owner":p.state.duplicate(true),"time":core.calendar.query().timestamp,"fraction":result.fraction}
		if not split: combined = state
		else: check("split range equivalent exact fraction",combined,state)
		check("explicit range preserves fraction "+str(split),fraction,result.fraction)
	# A newly created same-instant rule and eligibility change force replanning.
	var changed_reference := {}
	for bulk in [false,true]:
		entry.peers = []
		trace.clear()
		var p := ranged("bulk",100)
		if not bulk: entry.peers[-1].calendar_schedule.erase("activity_policy")
		var fresh := owner("new",[],["change"],["change"])
		var change := owner("change",[50],["range"],["range"])
		change.callback = func(_packet):
			p.enabled = false
			fresh.offsets = [50,60]
		start(1)
		var result := drain(core.advance_calendar_request(entry,activity_request(100)))
		var state := {"state":p.state.duplicate(true),"created":trace.filter(func(s): return s.begins_with("new:")),"actual":result.actual_ms}
		if not bulk: changed_reference = state
		else: check("new rule eligibility equivalence",changed_reference,state)
	entry.peers = []
	var interruptible := ranged("bulk",100)
	interruptible.approval = false
	interruptible.interrupt_at = 49
	start(1)
	var interrupted := drain(core.advance_calendar_request(entry,activity_request(100)))
	check("internal interruption requires chronology",["interrupted",50,50,0],[interrupted.kind,interrupted.actual_ms,interruptible.state.count,interruptible.bulk_calls])
	# External interruption prevents future range effects; deferred selection uses
	# actual endpoint and separates missed recurrence from exact destination.
	for mode in ["bulk","coalesced","skipped","endpoint"]:
		entry.peers = []
		var p := ranged(mode,10000)
		var interrupt := owner("interrupt",[50])
		interrupt.interrupt_at = 0
		start(1)
		var req := activity_request(10000)
		var result := drain(core.advance_calendar_request(entry,req))
		check(mode+" actual interrupted destination",["interrupted",50],[result.kind,result.actual_ms])
		if mode == "bulk": check("bulk no future effects",50,p.state.count)
		else:
			check(mode+" full native covered interval",50,p.ranges[0].range_end-p.ranges[0].range_start)
			check(mode+" selected identities",{"coalesced":[48,49],"skipped":[49],"endpoint":[]}[mode],p.selected)
		var calls := p.bulk_calls
		core.advance_calendar_request(entry,req)
		check(mode+" no replay",calls,p.bulk_calls)
	for mode in ["coalesced","skipped","endpoint"]:
		entry.peers = []
		var selected_owner := ranged(mode,1000)
		selected_owner.policy.period = 2
		entry.peers[-1].calendar_schedule.activity_policy = selected_owner.policy.duplicate(true)
		var stop := owner("interrupt",[50])
		stop.interrupt_at = 0
		start(1)
		var selected_result := drain(core.advance_calendar_request(entry,activity_request(100)))
		check(mode+" between recurrence destination",["interrupted",[24] if mode == "coalesced" else []],[selected_result.kind,selected_owner.selected.duplicate()])
		stop.offsets = []
		selected_result = drain(core.advance_calendar_request(entry,activity_request(50)))
		check(mode+" suppressed range cannot replay",[24,49] if mode == "coalesced" else [],selected_owner.selected)
	# Uncertain mutation is never repeated by diagnostics or failed reconciliation.
	entry.peers = []
	var p := ranged("bulk",10000)
	p.ambiguous = true
	start(1)
	var req := activity_request(10000)
	var result := drain(core.advance_calendar_request(entry,req))
	check("ambiguous holds settlement",["failed",10000,1,false],[result.kind,p.state.count,p.bulk_calls,core.gates.simulation()])
	var ticket: Dictionary = core.calendar.scheduler.ticket()
	result = core.calendar.continue_pending(source,ticket)
	check("unknown reconciliation no replay",["failed",1],[result.kind,p.bulk_calls])
	p.recovery = true
	result = drain(core.calendar.continue_pending(source,core.calendar.scheduler.ticket()))
	check("retained range reconciles once",["completed",10000,1],[result.kind,p.state.count,p.bulk_calls])
	check("old continuation duplicate exact",true,core.calendar.continue_pending(source,ticket).kind == "failed")
	# Malformed echoed native values fail even when numeric equality would match.
	entry.peers = []
	p = ranged("bulk",10)
	p.malformed_range = true
	start()
	result = drain(core.advance_calendar_request(entry,activity_request(10)))
	check("float range echo rejected",["failed",1],[result.kind,p.bulk_calls])
	entry.peers = []
	p = ranged("bulk",10)
	p.malformed_extra = true
	start(1)
	result = drain(core.advance_calendar_request(entry,activity_request(10)))
	check("extra completed range receipt fields rejected",["failed",1],[result.kind,p.bulk_calls])
	# During an actual range callback, both competing and same-operation entry
	# remain busy; pure queries cannot reenter a mutator.
	entry.peers = []
	p = ranged("bulk",10)
	start(1)
	var nested: Array = []
	p.range_callback = func(_packet):
		nested.append(core.advance_calendar_request(entry,activity_request(1)).kind)
		nested.append(core.calendar.continue_pending(source,core.calendar.scheduler.ticket()).kind)
		core.calendar.query()
	result = drain(core.advance_calendar_request(entry,activity_request(10)))
	check("range callbacks reject reentrancy",["busy","busy"],nested)
	check("range callback executes once",["completed",1,10],[result.kind,p.bulk_calls,p.state.count])
	entry.peers = []
	p = ranged("bulk",10)
	start(1)
	req = activity_request(10)
	result = core.advance_calendar_request(entry,req)
	var unchanged: Dictionary = core.calendar.query()
	var hold_a: int = core.gates.acquire("range-pause-a",core.snapshot().session,["simulation"])
	var hold_b: int = core.gates.acquire("range-pause-b",core.snapshot().session,["simulation"])
	for attempt in 3: result = core.calendar.continue_pending(source,core.calendar.scheduler.ticket())
	check("independent range holds prevent commitment",[unchanged.timestamp,0],[core.calendar.query().timestamp,p.bulk_calls])
	core.gates.release(hold_a,"range-pause-a")
	result = core.calendar.continue_pending(source,core.calendar.scheduler.ticket())
	check("nested range hold retained",0,p.bulk_calls)
	core.gates.release(hold_b,"range-pause-b")
	check("competing range request busy","busy",core.advance_calendar_request(entry,activity_request(1)).kind)
	check("changed range intent rejected","rejected",core.advance_calendar_request(entry,req.merged({"context":"another-context"},true)).kind)
	result = drain(core.calendar.continue_pending(source,core.calendar.scheduler.ticket()))
	check("range resumes same interval",["completed",10,1],[result.kind,result.actual_ms,p.bulk_calls])
	entry.peers = []
	p = ranged("bulk",10)
	start(1)
	p.policy.revision = 2
	var origin: int = core.calendar.query().timestamp
	result = drain(core.advance_calendar_request(entry,activity_request(10)))
	check("stale range declaration no commitment",["failed",origin,0],[result.kind,core.calendar.query().timestamp,p.bulk_calls])
	entry.peers = []
	p = ranged("bulk",10)
	p.fail_before_range = true
	start(1)
	result = drain(core.advance_calendar_request(entry,activity_request(10)))
	check("range failed before mutation retained",["failed",0,1],[result.kind,p.state.count,p.bulk_calls])
	p.recovery = true
	result = drain(core.calendar.continue_pending(source,core.calendar.scheduler.ticket()))
	check("checked noncommit authorizes range retry",["completed",10,2],[result.kind,p.state.count,p.bulk_calls])
	entry.peers = []
	p = ranged("bulk",10)
	start(1)
	var retiring := p
	p.range_callback = func(_packet):
		entry.peers = []
		harness.enter(core)
		retiring.scope = ""
	result = drain(core.advance_calendar_request(entry,activity_request(10)))
	check("retirement inside range cannot affect replacement",["rejected",0,true,true],[result.kind,p.state.count,core.gates.safe,core.calendar.query().settled])
	p.range_callback = Callable() # Release the intentional self-capture used above.
	entry.peers = []
	p = ranged("bulk",10)
	p.approval = false
	start()
	result = drain(core.advance_calendar_request(entry,activity_request(10)))
	check("unproved equivalence falls back",["completed",10,0],[result.kind,p.state.count,p.bulk_calls])
	entry.peers = []
	p = ranged("bulk",3)
	p.stream = 0
	p.offsets = [1,1,2]
	p.approval = false
	owner("external",[1],["range"],["range"])
	start(1)
	result = drain(core.advance_calendar_request(entry,activity_request(3)))
	check("coincident fallback with no bulk horizon",["completed",3,0],[result.kind,p.state.count,p.bulk_calls])
	for field in ["first","period","count","revision"]:
		for invalid in [true,1.0,-1]:
			var bad := p.policy.duplicate(true)
			bad[field] = invalid
			check("invalid policy "+field+" "+str(invalid),false,Policies.reason(bad).is_empty())
	check("overflow recurrence rejected",false,Policies.reason(p.policy.merged({"first":Calendar.MAX,"count":2},true)).is_empty())
	check("zero coverage",0,Policies.coverage(p.policy,p.policy.first,p.policy.first).count)
	var extreme := p.policy.merged({"first":0,"period":1,"count":Calendar.MAX},true)
	check("coverage at int64 last instant",[true,0],[Policies.coverage(extreme,Calendar.MAX,Calendar.MAX).ok,Policies.coverage(extreme,Calendar.MAX,Calendar.MAX).count])
	for endpoints in [[true,5],[0,1.0],[5,4],[-1,1]]:
		check("invalid range coverage "+str(endpoints),false,Policies.coverage(p.policy,endpoints[0],endpoints[1]).ok)
	# Long range has constant-size coverage and no occurrence cap.
	entry.peers = []
	p = ranged("bulk",1000000)
	start(1)
	result = drain(core.advance_calendar_request(entry,activity_request(1000000)))
	check("million occurrences one bounded owner call",["completed",1000000,1],[result.kind,p.state.count,p.bulk_calls])
	evidence.million_ranges = p.ranges.duplicate(true)
	entry.peers = []
	p = ranged("bulk",1000000)
	start(1)
	var elapsed: int = Calendar.MAX-core.calendar.query().timestamp
	result = drain(core.advance_calendar_request(entry,activity_request(elapsed)))
	check("full native long range no silent cap",["completed",elapsed,Calendar.MAX,1000000,1],[result.kind,result.actual_ms,core.calendar.query().timestamp,p.state.count,p.bulk_calls])
	entry.peers = []
	start()
	holiday_checks(shell,evidence)
	holiday_publication(shell,evidence)
	return evidence

func holiday_checks(shell: Control, evidence: Dictionary) -> void:
	var definitions: RefCounted = shell.controller.providers.definitions
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/time/holidays.json"))
	check("complete shipped holiday count",53,baseline.entries.size())
	for record: Dictionary in baseline.entries:
		var v: Dictionary = record.value
		var region: String = "packs/classic#region-00" if v.regions == ["*"] else v.regions[0]
		var result: Dictionary = core.calendar.regional_holidays(region,(405*360+int(v.day)-1)*Calendar.DAY)
		check("baseline holiday "+record.id,true,result.ok and result.holidays.any(func(h): return h.id == record.id and h.classic_id == int(v.classic_id)))
	var timestamp: int = (405*360+1)*Calendar.DAY
	check("explicit regional scour day",["scour-day"],core.calendar.regional_holidays("packs/classic#region-24",timestamp).holidays.map(func(h):return h.id))
	check("valid other region empty",[],core.calendar.regional_holidays("packs/classic#region-00",timestamp).holidays)
	for region in [null,"",0,"Daggerfall","packs/classic#region-99"]:
		check("invalid region "+str(region),"invalid_region",core.calendar.regional_holidays(region,timestamp).kind)
	for invalid in [true,0.0,-1,null]: check("invalid query timestamp "+str(invalid),"invalid_date",core.calendar.regional_holidays("packs/classic#region-00",invalid).kind)
	var before: Dictionary = core.calendar.query()
	var rng: Dictionary = core.randomness.snapshot()
	var gates: Array = core.gates._holds.values().duplicate(true)
	var started := Time.get_ticks_usec()
	var memory := OS.get_static_memory_usage()
	for query in 10000: core.calendar.regional_holidays("packs/classic#region-00",405*Calendar.YEAR)
	evidence.holiday_queries = {"count":10000,"usec":Time.get_ticks_usec()-started,"memory_bytes":OS.get_static_memory_usage()-memory}
	check("holiday reads clock fraction neutral",before,core.calendar.query())
	check("holiday reads RNG neutral",rng,core.randomness.snapshot())
	check("holiday reads gates neutral",gates,core.gates._holds.values())
	var detached: Dictionary = core.calendar.regional_holidays("packs/classic#region-00",405*Calendar.YEAR)
	detached.holidays.clear()
	check("holiday results detached",1,core.calendar.regional_holidays("packs/classic#region-00",405*Calendar.YEAR).holidays.size())

func holiday_publication(shell: Control, evidence: Dictionary) -> void:
	var Controller = preload("res://scripts/startup/startup_controller.gd")
	var app := Controller.new()
	var roots := {"executable_dir":harness.sandbox.path_join("holiday/executable"),"per_user_dir":harness.sandbox.path_join("holiday/user")}
	app.providers.enable_geography_inputs()
	app.start(roots)
	app.settings.effective["startup/show_setup"] = true
	var package: Dictionary = harness.manifest("holiday.policy")
	package.content = ["holidays.json","regions.json"]
	package.capabilities = ["data.regional-holidays-v1","data.geography-inputs-v1"]
	var folder: String = app.mods.root.path_join("Mods/holiday")
	harness.put(folder.path_join("mod.json"),package)
	var entries: Array = JSON.parse_string(FileAccess.get_file_as_string("res://content/time/holidays.json")).entries
	var v: Dictionary = entries[0].value.duplicate(true)
	v.day = 361
	v.classic_id = 0
	v.regions = ["packs/holiday.policy#added-region"]
	var holiday_data := {"domain":Holiday.DOMAIN,"path":"annual","operation":"add","entries":[{"id":"z-added","value":v.duplicate(true)}]}
	harness.put(folder.path_join("holidays.json"),holiday_data)
	harness.put(folder.path_join("regions.json"),{"domain":"geography.inputs","path":"packs/holiday.policy","operation":"add","entries":[{"id":"added-region","value":{"schema":"geography-inputs-v1","kind":"region","data":{"name":"Controlled added region"},"mappings":[]}}]})
	app.mods.rescan()
	app.mods.edit("holiday.policy","toggle")
	app.select_folder(shell.fixture.classic_source)
	check("malformed holiday publication recovery","package_recovery",app.route)
	check("malformed holiday no partial publication",false,app.providers.definitions.point_query(Holiday.DOMAIN,{"region":"packs/classic#region-00","day":1}).ok)
	v.day = 360
	v.priority = 100
	holiday_data.entries = [{"id":"z-added","value":v.duplicate(true)},{"id":"a-added","value":v.duplicate(true)}]
	holiday_data.entries.reverse()
	harness.put(folder.path_join("holidays.json"),holiday_data)
	var loose := {"domain":Holiday.DOMAIN,"path":"annual","operation":"patch","entries":[{"id":"new-life","value":{"day":360,"priority":200}}]}
	harness.put(app.mods.root.path_join("Overrides/holidays.json"),loose)
	app.mods.save_profile()
	app.providers.dispose()
	app.storage.adapter.release()
	app = Controller.new()
	app.providers.enable_geography_inputs()
	app.start(roots)
	app.settings.effective["startup/show_setup"] = true
	var started := Time.get_ticks_usec()
	app.select_folder(shell.fixture.classic_source)
	app.continue_to_menu("run")
	evidence.holiday_publication_usec = Time.get_ticks_usec()-started
	check("repaired holiday actual publication","main_menu",app.route)
	if app.route != "main_menu":
		harness.put(harness.sandbox.path_join("holiday-publication-failure.json"),app.result)
		app.providers.dispose()
		app.storage.adapter.release()
		return
	var registry: RefCounted = app.providers.definitions
	var lookup = preload("res://scripts/rule/regional_holidays.gd")
	var timestamp: int = (406*360-1)*Calendar.DAY
	var matches: Dictionary = lookup.query(registry,"packs/holiday.policy#added-region",timestamp)
	check("added region overlaps deterministic order",["new-life","a-added","z-added"],matches.holidays.map(func(h): return h.id))
	check("all-region added region applies",true,matches.holidays[0].regions == ["*"])
	check("day 360 native query",360,matches.day)
	check("year rollover annual query",[],lookup.query(registry,"packs/holiday.policy#added-region",timestamp+Calendar.DAY).holidays)
	var published: Dictionary = registry.query(Holiday.DOMAIN,"annual","new-life").record
	check("holiday loose provenance","@loose",published.fields.day.provider)
	check("holiday stable shipped identity","@shipped/regional-holidays-v1",published.identity.package)
	check("holiday added mod provenance","holiday.policy",registry.query(Holiday.DOMAIN,"annual","a-added").record.identity.package)
	harness.put(app.mods.root.path_join("Overrides/holidays.json"),loose.merged({"entries":[{"id":"new-life","value":{"day":1}}]},true))
	check("run long holiday publication lock","locked",registry.prepare(app.mods).kind)
	check("live loose edit not adopted",["new-life","a-added","z-added"],lookup.query(registry,"packs/holiday.policy#added-region",timestamp).holidays.map(func(h): return h.id))
	# Reference validation and ordering independent of insertion order.
	var adapter := Holiday.new()
	var source_records := {}
	for record: Dictionary in holiday_data.entries: source_records[record.id] = {"value":record.value,"fields":{},"identity":{"record":record.id}}
	var resources := {Holiday.DOMAIN+":annual":{"records":source_records},"geography.inputs:packs/holiday.policy":{"records":{"added-region":{"value":{"kind":"region"}}}}}
	adapter.begin_candidate(null,1,null)
	check("added holiday references valid",[],adapter.validate_references(resources))
	adapter.finish_candidate(resources,true)
	check("stable tie ordering reversed registration",["a-added","z-added"],adapter.point_query(1,{"region":"packs/holiday.policy#added-region","day":360}).holidays.map(func(h): return h.id))
	resources.erase("geography.inputs:packs/holiday.policy")
	adapter.begin_candidate(null,2,null)
	check("unknown holiday reference rejects",2,adapter.validate_references(resources).size())
	adapter.finish_candidate(resources,false)
	check("invalid candidate index unreadable",false,adapter.point_query(2,{"region":"packs/holiday.policy#added-region","day":360}).ok)
	app.providers.dispose()
	app.storage.adapter.release()
