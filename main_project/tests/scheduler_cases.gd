extends RefCounted
## Controlled owners only. Real CORE/TIME/DATA remain the production composition.
const Crossings = preload("res://scripts/time/calendar_crossings.gd")
const Calendar = preload("res://scripts/time/calendar.gd")
var harness: RefCounted
var core: RefCounted
var source: RefCounted
var entry: RefCounted
var trace: Array = []
var serial := 0
var pending_checks := true
var measurements := {}
class PhysicalProbe extends RefCounted:
	var calls := 0
	func physics_step(_delta: float) -> void: calls += 1

class Owner extends RefCounted:
	var id := ""
	var scope := ""
	var origin := 0
	var offsets: Array = []
	var stream := 0
	var trace: Array = []
	var receipts := {}
	var interrupt_at := -1
	var ambiguous_at := -1
	var fail_before := -1
	var reconciled := false
	var current := true
	var calls := 0
	var projection_revision := 1
	var malformed := false
	var callback: Callable
	func calendar_schedule_current(session: String, version: int) -> bool: return current and session == scope and version == 1
	func calendar_due_current(packet: Dictionary) -> Dictionary:
		return {"kind":"current","revision":projection_revision}
	func calendar_next_due(packet: Dictionary) -> Dictionary:
		var index: int = int(packet.cursor.get("occurrence","-1"))+1
		var count: int = stream if stream > 0 else offsets.size()
		if stream > 0:
			index = maxi(index,maxi(0,packet.start-origin))
		else:
			# Indexed seek excludes historical rules without walking the stream.
			var low := index
			var high := count
			while low < high:
				var middle: int = (low+high)/2
				if offsets[middle] <= packet.start-origin: low = middle+1
				else: high = middle
			index = low
		if index >= count: return {"kind":"none"}
		var due: int = origin+(index+1 if stream > 0 else int(offsets[index]))
		if due > packet.endpoint: return {"kind":"none"}
		return {"kind":"due","timestamp":true if malformed else due,"occurrence":str(index),"revision":1}
	func calendar_apply_due(packet: Dictionary) -> Dictionary:
		calls += 1
		if callback.is_valid(): callback.call(packet)
		if packet.session != scope: return {"kind":"failed"} # Retired owner delivery cannot mutate replacement state.
		var index: int = int(packet.occurrence)
		if index == fail_before and not reconciled: return {"kind":"failed"}
		trace.append(id+":"+packet.occurrence)
		var result := {"kind":"interrupted" if index == interrupt_at else "completed","session":packet.session,"operation":packet.operation,"owner":packet.owner,"timestamp":packet.timestamp,"occurrence":packet.occurrence,"revision":1}
		receipts[packet.session+":"+str(packet.operation)+":"+packet.occurrence] = result
		if index == ambiguous_at and not reconciled: return {"kind":"ambiguous"}
		return result
	func calendar_due_outcome(packet: Dictionary) -> Dictionary:
		if not reconciled: return {"kind":"unknown"}
		return receipts.get(packet.session+":"+str(packet.operation)+":"+packet.occurrence,{"kind":"not-applied","session":packet.session,"operation":packet.operation,"owner":packet.owner,"timestamp":packet.timestamp,"occurrence":packet.occurrence,"revision":packet.revision,"retry_authorized":true})

func check(label: String, expected: Variant, actual: Variant) -> void:
	harness.check("scheduler "+label,expected,actual)

func owner(id: String, offsets: Array, after: Array = [], interacts: Array = []) -> Owner:
	var provider := Owner.new()
	provider.id = id
	provider.offsets = offsets
	provider.trace = trace
	entry.peers.append({"role":"controlled-schedule-"+id,"owner":"TIME","lifetime":"session","required":true,"ready":true,"provider":provider,"calendar_due_work":true,"calendar_schedule":{"id":id,"version":1,"after":after,"interacts":interacts}})
	return provider

func start(budget := 64) -> void:
	harness.enter(core)
	core.calendar.scheduler.budget = budget
	for service: Dictionary in entry.peers:
		if service.has("calendar_schedule"):
			service.provider.origin = core.calendar.query().timestamp
			service.provider.scope = core.snapshot().session

func request(duration: int) -> Dictionary:
	serial += 1
	return harness.explicit(core,"scheduler-"+str(serial),duration)

func drain(result: Dictionary, limit := 100000) -> Dictionary:
	var passes := 0
	while result.kind == "pending-budget" and passes < limit:
		pending_checks = pending_checks and not core.gates.simulation() and not core.gates.gameplay_input() and not core.calendar.capture_snapshot().ok
		result = core.calendar.continue_pending(source,core.calendar.scheduler.ticket())
		passes += 1
	return result

func run(runner: RefCounted, shell: Control) -> Dictionary:
	harness = runner
	core = shell.session_shell.core
	source = shell.session_shell
	entry = core.provider
	entry.peers = []
	var before: Dictionary = core.calendar.query()
	var rng: Dictionary = core.randomness.snapshot()
	check("start excluded end included",1,Crossings.inspect(3600000,7200000,["new_hour"]).count)
	check("zero crossing",0,Crossings.inspect(0,0,["new_hour"]).count)
	check("grouped coincident year",{"timestamp":Calendar.YEAR,"markers":["new_hour","midnight","new_day","new_month","new_year"]},Crossings.inspect(Calendar.YEAR-1,Calendar.YEAR,["new_day","new_year"]).next)
	check("union counts each instant once",360,Crossings.inspect(0,Calendar.YEAR,["new_year","new_day"]).count)
	check("native last partial year safe",0,Crossings.inspect(Calendar.MAX,Calendar.MAX,["new_year"]).count)
	for endpoints in [[true,5],[0,false],[-1,0],[5,4],[0,1.0]]:
		check("invalid crossing "+str(endpoints),false,Crossings.inspect(endpoints[0],endpoints[1],["new_hour"]).ok)
	check("unknown named schedule rejected",false,Crossings.inspect(0,Calendar.DAY,["dawn"]).ok)
	check("query purity",before,core.calendar.query())
	check("query RNG purity",rng,core.randomness.snapshot())
	var a := owner("a",[0,10,20])
	var b := owner("b",[10])
	var c := owner("c",[10],["a"],["a"])
	# Reverse registration; declarations, not arrival order, determine dispatch.
	entry.peers.reverse()
	start(1)
	var initial: int = core.calendar.query().timestamp
	var req := request(20)
	var result: Dictionary = core.calendar.activity(entry,req)
	check("budget one admits retained operation","pending-budget",result.kind)
	entry.hold_preflight = true
	harness.enter(core,"load")
	var loading_waited: bool = core.busy() and not shell.session_shell.advance_calendar(120.0)
	var loading_preserved: bool = core.gates.safe and core.snapshot().ready and core.calendar.pending() and core.calendar.query().timestamp == initial
	core.cancel(core.ticket())
	entry.hold_preflight = false
	check("pending scoped input and simulation hold",[false,false,true,true],[core.gates.simulation(),core.gates.gameplay_input(),loading_waited,loading_preserved])
	check("duplicate returns progress",result,core.calendar.activity(entry,req))
	var changed := req.duplicate(true)
	changed.duration_ms += 1
	check("changed request rejected",false,core.calendar.activity(entry,changed).ok)
	check("competing request busy","busy",core.calendar.activity(entry,request(5)).kind)
	var ticket: Dictionary = core.calendar.scheduler.ticket()
	result = core.calendar.continue_pending(source,ticket)
	check("duplicate pass returns original result",result,core.calendar.continue_pending(source,ticket))
	var hold: int = core.gates.acquire("pause",core.snapshot().session,["simulation","input"])
	result = drain(result,20)
	check("independent pause blocks new segments",["pending-budget",initial,[]],[result.kind,core.calendar.query().timestamp,trace])
	core.gates.release(hold,"pause")
	var same_named_hold: int = core.gates.acquire(core.calendar.SETTLEMENT_OWNER,core.snapshot().session,["simulation"])
	result = drain(result,10)
	check("only exact TIME settlement token is excluded",["pending-budget",initial],[result.kind,core.calendar.query().timestamp])
	core.gates.release(same_named_hold,core.calendar.SETTLEMENT_OWNER)
	result = drain(result)
	check("deterministic dependency trace",["a:1","b:0","c:0","a:2"],trace)
	check("end included and actual duration",["completed",initial+20,20],[result.kind,result.new,result.actual_ms])
	check("retained terminal request",result,core.calendar.activity(entry,req))
	check("completed operation retains old pass",true,core.calendar.continue_pending(source,ticket).ok)
	for field: String in ["operation","pass"]:
		for bad: Variant in [true,1.0,"1"]:
			var malformed_ticket := ticket.duplicate(true)
			malformed_ticket[field] = bad
			check("malformed continuation "+field+" "+str(bad),false,core.calendar.continue_pending(source,malformed_ticket).ok)
	check("settled releases only own gate",true,core.gates.simulation())
	check("enabled profile cannot claim snapshot",false,core.calendar.capture_snapshot().ok)
	hold = core.gates.acquire("capture-review",core.snapshot().session,["simulation"])
	core.calendar._required_work = false
	check("scheduler capture cannot rely on legacy boolean",false,core.calendar.capture_snapshot().ok)
	core.calendar._required_work = true
	core.gates.release(hold,"capture-review")
	var reference := trace.duplicate()
	trace.clear()
	entry.peers.reverse()
	start(64)
	result = drain(core.calendar.activity(entry,request(20)))
	check("budget independent final trace",reference,trace)
	check("budget independent final duration",[20,initial+20,0],[result.actual_ms,result.new,result.fraction])
	# Interruption settles independent/dependent work at its instant.
	trace.clear()
	a.interrupt_at = 1
	start(1)
	result = drain(core.calendar.activity(entry,request(30)))
	check("middle interruption exact endpoint",["interrupted",10,20],[result.kind,result.actual_ms,result.remaining_ms])
	check("same instant settles no future effects",["a:1","b:0","c:0"],trace)
	# Mutation ambiguity may only recover from a retained owner outcome.
	trace.clear()
	a.interrupt_at = -1
	a.ambiguous_at = 2
	start(64)
	result = drain(core.calendar.activity(entry,request(30)))
	check("failure preserves earlier commitments",["failed",20,["a:1","b:0","c:0","a:2"]],[result.kind,result.actual_ms,trace])
	var calls := a.calls
	result = core.calendar.continue_pending(source,core.calendar.scheduler.ticket())
	check("ambiguous lookup cannot replay mutation",["failed",calls],[result.kind,a.calls])
	a.reconciled = true
	result = drain(core.calendar.continue_pending(source,core.calendar.scheduler.ticket()))
	check("reconciled mutation completes once",["completed",calls,4],[result.kind,a.calls,trace.size()])
	# Definite no-commit recovery authorizes one new dispatch.
	a.ambiguous_at = -1
	a.fail_before = 2
	a.reconciled = false
	trace.clear()
	start(64)
	result = drain(core.calendar.activity(entry,request(30)))
	check("definite failed step remains retained","failed",result.kind)
	a.receipts.clear()
	a.reconciled = true
	result = drain(core.calendar.continue_pending(source,core.calendar.scheduler.ticket()))
	check("checked noncommit permits retry",["completed",4],[result.kind,trace.size()])
	# Long stream, lazy next lookup, budget one and no 2880 truncation.
	entry.peers = []
	trace.clear()
	var stream := owner("stream",[])
	stream.stream = 3001
	start(1)
	var started := Time.get_ticks_usec()
	var memory := OS.get_static_memory_usage()
	result = drain(core.calendar.activity(entry,request(3001)))
	measurements.stream_3001_budget_one_usec = Time.get_ticks_usec()-started
	measurements.stream_3001_memory_bytes = OS.get_static_memory_usage()-memory
	check("stream beyond 2880 complete",["completed",3001,3001],[result.kind,result.actual_ms,trace.size()])
	var stream_trace := trace.duplicate()
	trace.clear()
	start(64)
	result = drain(core.calendar.activity(entry,request(3001)))
	check("stream budget equivalence",stream_trace,trace)
	check("all pending passes remain gated",true,pending_checks)
	# Ordinary elapsed/rate multiplication is admitted exactly once.
	stream.stream = 3
	trace.clear()
	start(1)
	var interval: Dictionary = core.calendar_interval(source,1000000001)
	result = core.calendar.ordinary(source,interval)
	var target_fraction: int = result.target_fraction
	check("ordinary admitted target",12000,result.requested_ms)
	var held_before: int = core.calendar.query().timestamp
	check("shell pending stops physical handoff",false,shell.session_shell.advance_calendar(500.0))
	result = drain(core.calendar.scheduler.operation.result)
	check("ordinary rate applied once",[12000,12000000,target_fraction],[result.actual_ms,result.fraction,core.calendar.query().fraction])
	check("held frame does not add delta",held_before+12000,core.calendar.query().timestamp)
	check("ordinary interval terminal retry",result,core.calendar.ordinary(source,interval))
	trace.clear()
	start(1)
	core.gates.intended_rate = 2.0
	result = core.advance_calendar_frame(source,0.5)
	core.gates.intended_rate = 1.0
	result = drain(result)
	check("CORE rate captured once before continuation",[12000,1000000000],[result.actual_ms,result.eligible_ns])
	# A fractional initial balance is consumed at an ordinary whole boundary.
	start(64)
	var tiny: Dictionary = harness.tick(core,source,1)
	check("scheduler tiny ordinary preserves precision",[0,12000000],[tiny.actual_ms,core.calendar.query().fraction])
	stream.interrupt_at = 0
	result = drain(harness.tick(core,source,1000000000))
	check("ordinary interruption reports discarded exact tail",["interrupted",1,11999,0,12000000],[result.kind,result.actual_ms,result.remaining_ms,result.fraction,result.target_fraction])
	stream.interrupt_at = -1
	start(64)
	var settled_notifications: Array = []
	var terminal_callback := func(outcome: Dictionary): settled_notifications.append(outcome)
	core.calendar.settled.connect(terminal_callback)
	var zero_before: Dictionary = core.calendar.query()
	result = harness.tick(core,source,0)
	check("scheduler zero ordinary has no due effects",[0,zero_before.timestamp,0],[result.actual_ms,core.calendar.query().timestamp,settled_notifications.size()])
	req = request(4)
	result = drain(core.calendar.activity(entry,req))
	core.calendar.activity(entry,req)
	check("terminal notification exactly once",1,settled_notifications.size())
	check("terminal notification read only",true,settled_notifications[0].is_read_only())
	core.calendar.settled.disconnect(terminal_callback)
	trace.clear()
	start(64)
	var long_start := Time.get_ticks_usec()
	result = drain(core.calendar.activity(entry,request(Calendar.YEAR*10000)))
	measurements.ten_thousand_years_three_occurrences_usec = Time.get_ticks_usec()-long_start
	check("long range uses lazy owner index",["completed",Calendar.YEAR*10000,3],[result.kind,result.actual_ms,trace.size()])
	# Freshness, reentrancy, and retirement while retained.
	start(64)
	stream.current = false
	result = core.calendar.activity(entry,request(10))
	check("stale provider fails explicitly","failed",result.kind)
	stream.current = true
	start(64)
	req = request(1)
	stream.callback = func(_packet):
		check("callback reentrant continuation busy","busy",core.calendar.continue_pending(source,core.calendar.scheduler.ticket()).kind)
		check("callback reentrant admitted request busy","busy",core.calendar.activity(entry,req).kind)
	result = drain(core.calendar.activity(entry,req))
	check("reentrancy leaves one occurrence","completed",result.kind)
	stream.callback = Callable()
	start(1)
	result = core.calendar.activity(entry,request(10))
	ticket = core.calendar.scheduler.ticket()
	start(64)
	check("retired continuation rejected",false,core.calendar.continue_pending(source,ticket).ok)
	start(1)
	stream.callback = func(_packet):
		stream.callback = Callable()
		start(64)
	result = core.calendar.activity(entry,request(10))
	var retired_scope: String = core.gates.session
	var stopped_frame: bool = not shell.session_shell.advance_calendar(1.0)
	check("new session has no inherited operation",[false,true,true,true,true,true],[core.calendar.pending(),core.gates.safe,core.snapshot().ready,core.gates.session != retired_scope,stopped_frame,core.calendar.query().timestamp == stream.origin])
	# Invalid binding graph cannot be activated.
	var scheduler := preload("res://scripts/time/due_work.gd").new(core.calendar)
	entry.peers = []
	owner("a",[1],["b"])
	owner("b",[1],["a"])
	check("cycle rejected",false,scheduler.bind(entry.peers).ok)
	entry.peers.pop_back()
	check("missing dependency rejected",false,scheduler.bind(entry.peers).ok)
	entry.peers = []
	owner("a",[1],[],["b"])
	owner("b",[1])
	check("interaction requires precedence",false,scheduler.bind(entry.peers).ok)
	# Late work may not insert a predecessor behind its settled dependent.
	entry.peers = []
	trace.clear()
	a = owner("a",[])
	b = owner("b",[10],["a"])
	b.callback = func(_packet): a.offsets = [10]
	start(64)
	result = drain(core.calendar.activity(entry,request(20)))
	check("late predecessor fails without replay",["failed",["b:0"],10],[result.kind,trace,result.actual_ms])
	b.callback = Callable()
	entry.peers = []
	trace.clear()
	a = owner("a",[1])
	start(64)
	a.projection_revision = 2
	initial = core.calendar.query().timestamp
	result = core.calendar.activity(entry,request(10))
	check("stale due revision prevents time commitment",["failed",initial,0],[result.kind,core.calendar.query().timestamp,a.calls])
	a.projection_revision = 1
	start(64)
	a.malformed = true
	result = core.calendar.activity(entry,request(10))
	check("boolean due instant rejected","failed",result.kind)
	a.malformed = false
	start(64)
	for invalid: Variant in [true,0,-1,1.5]:
		core.calendar.scheduler.budget = invalid
		check("invalid budget "+str(invalid),false,core.calendar.activity(entry,request(10)).ok)
	core.calendar.scheduler.budget = 1
	var exact := request(10)
	exact.start = core.calendar.query().timestamp
	exact.endpoint = exact.start+10
	var invalid_request := exact.duplicate(true)
	invalid_request.endpoint = true
	check("boolean native endpoint rejected",false,core.advance_calendar_request(entry,invalid_request).ok)
	invalid_request = exact.duplicate(true)
	invalid_request.endpoint = exact.start-1
	check("reversed native endpoint rejected",false,core.advance_calendar_request(entry,invalid_request).ok)
	invalid_request = exact.duplicate(true)
	invalid_request.start -= 1
	invalid_request.endpoint -= 1
	check("stale native start rejected",false,core.advance_calendar_request(entry,invalid_request).ok)
	result = drain(core.advance_calendar_request(entry,exact))
	check("explicit native endpoints retained",["completed",exact.endpoint],[result.kind,result.new])
	start(64)
	a.callback = func(_packet): entry.authorized = false
	result = drain(core.calendar.activity(entry,request(10)))
	check("requester revalidated before later segments",["failed",1],[result.kind,result.actual_ms])
	entry.authorized = true
	a.callback = Callable()
	# Already committed obligations can settle under pause; further time cannot.
	trace.clear()
	start(1)
	a.callback = func(_packet): core.gates.acquire("nested-focus",core.snapshot().session,["simulation","input"])
	result = core.calendar.activity(entry,request(10))
	result = drain(result,10)
	check("committed obligation settles under hold",["pending-budget",1,["a:0"]],[result.kind,result.actual_ms,trace])
	a.callback = Callable()
	# Retiring clears TIME, leaves application-scoped independent holds intact.
	var application_hold: int = core.gates.acquire("load-independent","",["simulation"])
	entry.peers = []
	start(64)
	check("retirement preserves independent application hold",true,core.gates.blocked("simulation"))
	core.gates.release(application_hold,"load-independent")
	if DisplayServer.get_name() != "headless":
		entry.peers = []
		trace.clear()
		a = owner("rendered",[1,2,3])
		start(1)
		var probe := PhysicalProbe.new()
		var original_ground: RefCounted = shell.session_shell.ground
		shell.session_shell.ground = probe
		req = request(10)
		result = core.calendar.activity(entry,req)
		check("rendered pending presentation independent",true,core.gates.presentation())
		shell.set_physics_process(true)
		for frame in 20: await shell.get_tree().physics_frame
		shell.set_physics_process(false)
		shell.session_shell.ground = original_ground
		result = core.calendar.activity(entry,req)
		check("stock rendered continuation completes",["completed",10,3],[result.kind,result.actual_ms,trace.size()])
		check("stock rendered pending no physical work",0,probe.calls)
		check("stock rendered pending avoids fatal recovery",true,core.gates.safe)
	entry.peers = []
	start(64)
	return measurements
