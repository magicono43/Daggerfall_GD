extends "res://tests/mod_cases.gd"
const Calendar = preload("res://scripts/time/calendar.gd")
const Policy = preload("res://scripts/data/calendar_policy.gd")
const Clock = preload("res://scripts/time/calendar_clock.gd")
const Core = preload("res://scripts/session/session_lifecycle.gd")
const Entry = preload("res://tests/controlled_calendar_entry.gd")
const Controller = preload("res://scripts/startup/startup_controller.gd")
var sequence := 0
var transitions: Array = []
var measurements := {}
class NonBooleanActivity extends RefCounted:
	func calendar_activity_current(_request: Dictionary) -> Variant: return 1

func date(y: int, m: int, d: int, h := 0, minute := 0, second := 0, ms := 0) -> Dictionary:
	return {"year":y,"month":m,"day":d,"hour":h,"minute":minute,"second":second,"millisecond":ms}
func tick(core: RefCounted, source: RefCounted, ns: int) -> Dictionary:
	return core.calendar.ordinary(source,core.calendar_interval(source,ns))
func enter(core: RefCounted, mode := "new", restored: Variant = null, outside := false) -> Dictionary:
	sequence += 1
	core.provider.restored = restored
	var result: Dictionary = core.request({"id":"calendar-entry-"+str(sequence),"mode":mode,"origin":core.snapshot().session,"selection":{"outside_privateers_hold":outside}})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)
	return result
func explicit(core: RefCounted, operation: String, duration: Variant) -> Dictionary:
	return {"session":core.snapshot().session,"owner":"controlled-rest","operation":operation,"reason":"controlled-segment","duration_ms":duration}
func put(path: String, value: Variant) -> void:
	preload("res://tests/publication_fixture.gd").write(path,value)
func contribution(value: Dictionary) -> Dictionary:
	return {"domain":Policy.DOMAIN,"path":"policy","operation":"patch","entries":[{"id":"world","value":value}]}

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	shell.set_physics_process(false) # Scripted exact elapsed input; rendered real frames below.
	var base: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/time/calendar.json")).entries[0].value
	var policy := Policy.normalized(base)
	var opening: int = Calendar.encode(policy.opening).timestamp
	check("opening classic 523530",523530,Calendar.to_classic(opening).minute)
	check("opening exact numeric fields",date(405,1,4,13,30),policy.opening)
	check("base policy validates","",Policy.reason(base))
	for t in [0,1,Calendar.DAY-1,Calendar.YEAR-1,opening,Calendar.MAX]:
		var decoded := Calendar.decode(t)
		decoded.erase("ok")
		decoded.erase("day_of_year")
		check("native roundtrip "+str(t),t,Calendar.encode(decoded).timestamp)
	for month in range(1,13):
		var t: int = Calendar.encode(date(405,month,30,23,59,59,999)).timestamp+1
		var decoded := Calendar.decode(t)
		check("month rollover "+str(month),[406 if month == 12 else 405,1 if month == 12 else month+1,1,0],[decoded.year,decoded.month,decoded.day,decoded.millisecond])
		check("monthly Sundas "+str(month),0,Calendar.context(Calendar.encode(date(405,month,1)).timestamp,policy).weekday)
	for day in range(356,361): check("late-year day "+str(day),day,Calendar.decode(Calendar.encode(date(405,12,day-330)).timestamp).day_of_year)
	for field in policy.opening:
		for bad in [true,false,-1,1.5,"1",null]:
			var value: Dictionary = policy.opening.duplicate(true)
			value[field] = bad
			check("invalid date "+field+" "+str(bad),false,Calendar.encode(value).ok)
	for field in {"month":13,"day":31,"hour":24,"minute":60,"second":60,"millisecond":1000,"year":Calendar.MAX/Calendar.YEAR+1}:
		var value: Dictionary = policy.opening.duplicate(true)
		value[field] = {"month":13,"day":31,"hour":24,"minute":60,"second":60,"millisecond":1000,"year":Calendar.MAX/Calendar.YEAR+1}[field]
		check("date upper bound "+field,false,Calendar.encode(value).ok)
	var maximum := Calendar.decode(Calendar.MAX)
	maximum.erase("ok")
	maximum.erase("day_of_year")
	maximum.millisecond += 1
	check("native last day overflow",false,Calendar.encode(maximum).ok)
	for invalid in [-1,true,1.0,"0",null]: check("invalid native "+str(invalid),false,Calendar.decode(invalid).ok)
	for minute in [0,523530,Calendar.CLASSIC_MAX]: check("classic roundtrip "+str(minute),minute,Calendar.to_classic(Calendar.from_classic(minute).timestamp).minute)
	var last: int = Calendar.from_classic(Calendar.CLASSIC_MAX).timestamp
	check("complete final classic minute",Calendar.CLASSIC_MAX,Calendar.to_classic(last+59999).minute)
	check("first invalid classic minute",false,Calendar.to_classic(last+60000).ok)
	check("before classic epoch",false,Calendar.to_classic(Calendar.CLASSIC_EPOCH-1).ok)
	check("classic precision discarded only",opening,Calendar.from_classic(Calendar.to_classic(opening+59999).minute).timestamp)
	for invalid in [-1,Calendar.CLASSIC_MAX+1,true,1.0]: check("invalid classic "+str(invalid),false,Calendar.from_classic(invalid).ok)
	for season in policy.seasons:
		var t: int = (405*360+policy.seasons[season]-1)*Calendar.DAY
		check("base season boundary "+season,season,Calendar.context(t,policy).season)
		check("base season previous "+season,false,Calendar.context(t-1,policy).season == season)
	for invalid in [0,-1,true,NAN,INF,0.0000001,1.1234567,1000001.0]:
		var p := base.duplicate(true)
		p.rate = invalid
		check("invalid rate "+str(invalid),false,Policy.reason(p).is_empty())
	var invalid_policy := base.duplicate(true)
	invalid_policy.seasons.spring = invalid_policy.seasons.winter
	check("duplicate season rejects",false,Policy.reason(invalid_policy).is_empty())
	invalid_policy = base.duplicate(true)
	invalid_policy.weekday = {"rule":"continuous"}
	check("continuous anchor required",false,Policy.reason(invalid_policy).is_empty())
	# Normal application publication with complete stock composition and real data.
	var controller: RefCounted = shell.controller
	controller.settings.effective["startup/show_setup"] = true
	var started := Time.get_ticks_usec()
	controller.select_folder(fixture.classic_source)
	controller.continue_to_menu("run")
	shell.session_shell.synchronize_startup()
	measurements.complete_startup_usec = Time.get_ticks_usec()-started
	check("actual complete composition menu","main_menu",controller.route)
	var registry: RefCounted = controller.providers.definitions
	var record: Dictionary = registry.query(Policy.DOMAIN,"policy","world").record
	check("shipped stable policy identity",Policy.DOMAIN,record.identity.domain)
	check("shipped policy provenance",true,record.contributors.any(func(source): return source.provider == "@shipped/calendar-clock-v1"))
	check("publication content locked","locked",registry.prepare(controller.mods).kind)
	check("content query detached",12.0,registry.query(Policy.DOMAIN,"policy","world").record.value.rate)
	var core: RefCounted = shell.session_shell.core
	var source: RefCounted = shell.session_shell
	var entry := Entry.new()
	entry.core = core
	var peer := Entry.new()
	var focus_peer := Entry.new()
	var malformed_peer := NonBooleanActivity.new()
	entry.peers = [{"role":"controlled-calendar-peer","owner":"CORE","lifetime":"session","required":true,"ready":true,"provider":peer,"calendar_activity":"controlled-other"},{"role":"controlled-calendar-malformed","owner":"CORE","lifetime":"session","required":true,"ready":true,"provider":malformed_peer,"calendar_activity":"controlled-nonboolean"}]
	entry.peers.append({"role":"controlled-calendar-focus","owner":"CORE","lifetime":"session","required":true,"ready":true,"provider":focus_peer,"calendar_activity":"focus"})
	core.provider = entry
	check("interior start path ready","Succeeded",enter(core).kind)
	check("clock before dependent baseline",opening,entry.baseline_clock.timestamp)
	check("new origin and zero remainder",[opening,0],[core.calendar.query().timestamp,core.calendar.query().fraction])
	core.calendar.committed.connect(func(_result: Dictionary): transitions.append(null))
	var rng_before: Dictionary = core.randomness.snapshot()
	check("five eligible minutes",3600000,tick(core,source,300000000000).actual_ms)
	check("one game hour actual timestamp",opening+3600000,core.calendar.query().timestamp)
	check("ordinary progression leaves RNG unchanged",rng_before,core.randomness.snapshot())
	var observed := []
	var observer := func(outcome: Dictionary): observed.append([outcome.is_read_only(),core.advance_calendar_frame(source,1.0).ok])
	core.calendar.committed.connect(observer)
	tick(core,source,1000000)
	check("read-only observer cannot reenter clock",[[true,false]],observed)
	core.calendar.committed.disconnect(observer)
	tick(core,source,1000000)
	check("retired observer never replays",1,observed.size())
	var replacement := func(outcome: Dictionary): observed.append([outcome.old,outcome.new])
	core.calendar.committed.connect(replacement)
	before_observer(core,source,observed)
	core.calendar.committed.disconnect(replacement)
	var request: Dictionary = core.calendar_interval(source,123456789)
	var result: Dictionary = core.calendar.ordinary(source,request)
	tick(core,source,1) # A later interval must not erase the earlier retry result.
	check("duplicate retained outcome",result,core.calendar.ordinary(source,request))
	var changed := request.duplicate(true)
	changed.elapsed_ns += 1
	check("changed intent rejected",false,core.calendar.ordinary(source,changed).ok)
	check("foreign ordinary provider",false,core.calendar.ordinary(entry,request).ok)
	var forged: Dictionary = core.calendar_interval(source,1000)
	forged.elapsed_ns = 1000000
	check("uncommitted interval forgery rejected",false,core.calendar.ordinary(source,forged).ok)
	var stale: Dictionary = core.calendar_interval(source,1000)
	core.calendar_interval(source,1000)
	check("superseded interval rejected",false,core.calendar.ordinary(source,stale).ok)
	var before: Dictionary = core.calendar.query()
	var count := transitions.size()
	check("tiny positive accepted",true,tick(core,source,1).ok)
	check("tiny fraction retained",before.fraction+12000000,core.calendar.query().fraction)
	check("tiny interval no fabricated transition",count,transitions.size())
	before = core.calendar.query()
	for index in 1000: tick(core,source,1)
	check("repeated tiny intervals retained",before.fraction+12000000000,core.calendar.query().fraction)
	# Exact product fixtures exercise the overflow-safe long-range path.
	var combined := Clock.product(100000000123,12345678,999)
	var split := Clock.product(123,12345678,999)
	var tail := Clock.product(100000000000,12345678,split.fraction)
	check("split equals combined",[combined.whole,combined.fraction],[split.whole+tail.whole,tail.fraction])
	check("full elapsed range product",[110680464442257,309684000000],[Clock.product(Calendar.MAX,12000000,0).whole,Clock.product(Calendar.MAX,12000000,0).fraction])
	check("unrepresentable product rejects",false,Clock.product(Calendar.MAX,2000000000000,0).ok)
	var pending: Dictionary = core.calendar_interval(source,1000000000)
	var hold_a: int = core.gates.acquire("pause-a",core.snapshot().session,["simulation"])
	var hold_b: int = core.gates.acquire("pause-b",core.snapshot().session,["simulation"])
	before = core.calendar.query()
	check("nested pause contributes zero",false,core.advance_calendar_frame(source,600.0).ok)
	core.gates.release(hold_a,"pause-a")
	check("remaining pause blocks",false,core.advance_calendar_frame(source,600.0).ok)
	core.gates.release(hold_b,"pause-b")
	check("pre-pause pending interval stale",false,core.calendar.ordinary(source,pending).ok)
	check("pause preserves exact state",before,core.calendar.query())
	check("resume no catch-up",12,tick(core,source,1000000).actual_ms)
	shell.session_shell.focus_changed(false)
	before = core.calendar.query()
	check("focus loss no time",false,core.advance_calendar_frame(source,60.0).ok)
	shell.session_shell.focus_changed(true)
	check("focus preserves fraction",before,core.calendar.query())
	for invalid in [-1,NAN,INF,true,false,"1",null]: check("invalid frame elapsed "+str(invalid),false,core.advance_calendar_frame(source,invalid).ok)
	check("boolean elapsed rejected",true,core.calendar_interval(source,true).is_empty())
	check("subprecision frame explicitly rejects",false,core.advance_calendar_frame(source,0.0000000000001).ok)
	core.gates.intended_rate = 2.0
	check("CORE intended rate once",24000,core.advance_calendar_frame(source,1.0).actual_ms)
	core.gates.intended_rate = 1.0
	before = core.calendar.query()
	var malformed_authorization := explicit(core,"malformed-authorization",1)
	malformed_authorization.owner = "controlled-nonboolean"
	check("nonboolean activity authorization rejects",false,core.calendar.activity(malformed_peer,malformed_authorization).ok)
	check("nonboolean authorization leaves state",before,core.calendar.query())
	var core_focus: int = core.gates.acquire("focus","",["simulation"])
	var colliding := explicit(core,"core-focus-collision",1)
	colliding.owner = "focus"
	before = core.calendar.query()
	check("activity ID cannot bypass CORE focus",false,core.calendar.activity(focus_peer,colliding).ok)
	check("CORE focus collision leaves exact state",before,core.calendar.query())
	core.gates.release(core_focus,"focus")
	var own_owner := Clock.activity_hold_owner("controlled-rest")
	var global_activity_hold: int = core.gates.acquire(own_owner,"",["simulation"])
	before = core.calendar.query()
	check("application hold is not current activity hold",false,core.calendar.activity(entry,explicit(core,"global-hold",1)).ok)
	check("application hold preserves exact state",before,core.calendar.query())
	core.gates.release(global_activity_hold,own_owner)
	var own: int = core.gates.acquire(own_owner,core.snapshot().session,["simulation"])
	var fraction: int = core.calendar.query().fraction
	var activity := explicit(core,"hour",3600000)
	result = core.calendar.activity(entry,activity)
	check("explicit hour under own hold",3600000,result.actual_ms)
	check("explicit preserves fraction",fraction,core.calendar.query().fraction)
	check("explicit duplicate retained",result,core.calendar.activity(entry,activity))
	activity.duration_ms += 1
	check("explicit changed intent rejects",false,core.calendar.activity(entry,activity).ok)
	for invalid in [0,-1,true,1.0,Calendar.MAX]: check("invalid explicit duration "+str(invalid),false,core.calendar.activity(entry,explicit(core,"bad-"+str(invalid),invalid)).ok)
	var independent: int = core.gates.acquire("focus", "",["simulation"])
	before = core.calendar.query()
	check("explicit independent blocker",false,core.calendar.activity(entry,explicit(core,"blocked",1)).ok)
	core.gates.release(independent,"focus")
	check("blocked activity no mutation",before,core.calendar.query())
	var reentrant := []
	var competing := explicit(core,"competing",1)
	competing.owner = "controlled-other"
	entry.callback = func(): reentrant.append(core.calendar.activity(peer,competing).kind)
	check("authorized checked segment",true,core.calendar.activity(entry,explicit(core,"checked",1)).ok)
	check("reentrant competing busy",["busy"],reentrant)
	entry.callback = Callable()
	var mutating := explicit(core,"mutating-intent",1)
	before = core.calendar.query()
	entry.callback = func(): mutating.duration_ms = Calendar.MAX
	check("callback changed request rejected",false,core.calendar.activity(entry,mutating).ok)
	check("callback changed request leaves state",before,core.calendar.query())
	entry.callback = Callable()
	entry.callback = func(): core.gates.acquire("independent-during-admission",core.snapshot().session,["simulation"])
	before = core.calendar.query()
	check("blocker during authorization rejects",false,core.calendar.activity(entry,explicit(core,"interrupted-admission",1)).ok)
	check("interrupted admission preserves state",before,core.calendar.query())
	entry.callback = Callable()
	# Release only this fixture's newly acquired token; never another owner hold.
	for token in core.gates._holds.keys():
		if core.gates._holds[token].owner == "independent-during-admission": core.gates.release(token,"independent-during-admission")
	entry.authorized = false
	check("stale activity rejects",false,core.calendar.activity(entry,explicit(core,"unauthorized",1)).ok)
	entry.authorized = true
	check("activity does not release own hold",false,core.gates.simulation())
	var saved: Dictionary = core.calendar.capture_snapshot().state
	check("snapshot exact precision",[core.calendar.query().timestamp,fraction],[saved.timestamp,saved.fraction])
	core.gates.release(own,own_owner)
	check("ungated snapshot rejected",false,core.calendar.capture_snapshot().ok)
	for field in saved:
		var malformed := saved.duplicate(true)
		malformed.erase(field)
		check("snapshot required "+field,false,Clock.validate_snapshot(malformed,saved.compatibility).ok)
	var malformed := saved.duplicate(true)
	malformed.timestamp = true
	check("snapshot boolean timestamp rejects",false,Clock.validate_snapshot(malformed,saved.compatibility).ok)
	malformed = saved.duplicate(true)
	malformed.settled = false
	check("in-progress snapshot rejects",false,Clock.validate_snapshot(malformed,saved.compatibility).ok)
	var newer_schema := saved.duplicate(true)
	newer_schema.schema = "calendar-clock-state-v2"
	check("unsupported snapshot version rejects",false,Clock.validate_snapshot(newer_schema,saved.compatibility).ok)
	before = core.calendar.query()
	count = transitions.size()
	check("malformed load preflight fails","Failed",enter(core,"load",malformed).kind)
	check("failed load preserves live state",before,core.calendar.query())
	check("load preflight zero elapsed",count,transitions.size())
	var old_request: Dictionary = core.calendar_interval(source,1000)
	enter(core,"load",saved)
	check("restore exact instant and fraction",[saved.timestamp,saved.fraction],[core.calendar.query().timestamp,core.calendar.query().fraction])
	check("restore emits no advancement",count,transitions.size())
	check("retired interval rejected",false,core.calendar.ordinary(source,old_request).ok)
	check("retired activity rejected",false,core.calendar.activity(entry,activity).ok)
	check("restore initializes dependent tracking",saved.timestamp,entry.baseline_clock.timestamp)
	var loaded: Dictionary = core.calendar.query()
	var expected := Clock.product(7654321,policy.rate_units,loaded.fraction)
	check("restored remainder continuation",expected.whole,tick(core,source,7654321).actual_ms)
	entry.hold_readiness = true
	enter(core,"load",saved)
	check("real load boundary remains initializing","initializing",core.snapshot().phase)
	before = core.calendar.query()
	check("loading ordinary duration rejected",false,core.advance_calendar_frame(source,600.0).ok)
	check("loading explicit segment rejected",false,core.calendar.activity(entry,explicit(core,"during-load",1)).ok)
	check("loading contributes zero exact elapsed",before,core.calendar.query())
	entry.hold_readiness = false
	core.complete_readiness(core.ticket(),{"ok":true,"services":entry.bindings(),"death_authority":entry})
	enter(core,"new",null,true)
	check("exterior start resets exact origin",[opening,0],[core.calendar.query().timestamp,core.calendar.query().fraction])
	var near_limit := saved.duplicate(true)
	near_limit.timestamp = Calendar.MAX-5
	enter(core,"load",near_limit)
	check("full-range native restore exact",Calendar.MAX-5,core.calendar.query().timestamp)
	before = core.calendar.query()
	check("ordinary endpoint overflow rejects",false,tick(core,source,1000000).ok)
	check("ordinary overflow atomic",before,core.calendar.query())
	check("explicit complete endpoint",Calendar.MAX,core.calendar.activity(entry,explicit(core,"last-five",5)).new)
	before = core.calendar.query()
	check("explicit first invalid endpoint",false,core.calendar.activity(entry,explicit(core,"beyond-end",1)).ok)
	check("explicit overflow atomic",before,core.calendar.query())
	shell._physics_process(1.0)
	check("stock clock failure enters CORE recovery",[false,false,"recovery"],[core.snapshot().ready,core.gates.safe,core.snapshot().application])
	check("stock clock failure preserves exact time",before,core.calendar.query())
	enter(core)
	# Invalid candidates and actual three-tier precedence in another isolated app.
	var other := Controller.new()
	other.start({"executable_dir":sandbox.path_join("override/executable"),"per_user_dir":sandbox.path_join("override/user")})
	other.settings.effective["startup/show_setup"] = true
	var package := manifest("calendar.policy")
	package.content = ["calendar.json"]
	package.capabilities = ["data.calendar-clock-v1"]
	put(other.mods.root.path_join("Mods/calendar/mod.json"),package)
	put(other.mods.root.path_join("Mods/calendar/calendar.json"),contribution({"rate":0}))
	other.mods.rescan()
	other.mods.edit("calendar.policy","toggle")
	other.select_folder(fixture.classic_source)
	check("malformed candidate blocks publication","package_recovery",other.route)
	check("malformed candidate cannot publish",false,other.providers.definitions.query(Policy.DOMAIN,"policy","world").ok)
	check("other live publication intact",12.0,registry.query(Policy.DOMAIN,"policy","world").record.value.rate)
	var modded := base.duplicate(true)
	modded.rate = 6.0
	modded.opening.day = 15
	modded.weekday = {"rule":"continuous","anchor_day":0,"index":2}
	modded.seasons = {"winter":355,"spring":80,"summer":160,"fall":250}
	put(other.mods.root.path_join("Mods/calendar/calendar.json"),contribution(modded))
	# Loose intake was already captured on first preparation; restart to admit
	# new loose files, as required by the actual DATA recovery contract.
	put(other.mods.root.path_join("Overrides/calendar.json"),contribution({"rate":3.0}))
	check("override selection persisted for restart",true,other.mods.save_profile().ok)
	var roots: Dictionary = other.launch.duplicate(true)
	other.providers.dispose()
	other.storage.adapter.release()
	other = Controller.new()
	other.start(roots)
	other.settings.effective["startup/show_setup"] = true
	other.select_folder(fixture.classic_source)
	other.continue_to_menu("run")
	check("repaired fresh application publishes","main_menu",other.route)
	var overridden: Dictionary = other.providers.definitions.query(Policy.DOMAIN,"policy","world").record
	check("loose wins mod rate",3.0,overridden.value.rate)
	check("mod opening retained",15,overridden.value.opening.day)
	check("all policy contributor tiers",true,["@shipped/calendar-clock-v1","calendar.policy","@loose"].all(func(id): return overridden.contributors.any(func(p): return p.provider == id)))
	var resolved := Policy.normalized(overridden.value)
	for month in [1,2,12]:
		var t: int = Calendar.encode(date(405,month,30)).timestamp
		check("continuous month wrap "+str(month),posmod(Calendar.context(t,resolved).weekday+1,7),Calendar.context(t+Calendar.DAY,resolved).weekday)
	for season in resolved.seasons:
		var t: int = (405*360+resolved.seasons[season]-1)*Calendar.DAY
		check("modded season start "+season,season,Calendar.context(t,resolved).season)
		check("modded season previous "+season,false,Calendar.context(t-1,resolved).season == season)
	var second := Core.new(shell.fixture_actor_material)
	second.calendar.definitions = other.providers.definitions
	second.bind_calendar_source(self)
	var second_entry := Entry.new()
	second_entry.core = second
	second.provider = second_entry
	second.startup_route_changed("main_menu")
	enter(second)
	check("actual overridden opening",Calendar.encode(resolved.opening).timestamp,second.calendar.query().timestamp)
	check("actual overridden ordinary rate",3000,tick(second,self,1000000000).actual_ms)
	check("explicit hour independent of overridden rate",3600000,second.calendar.activity(second_entry,explicit(second,"other-hour",3600000)).actual_ms)
	check("changed calendar semantics incompatible",false,second.calendar.preflight("load",saved).ok)
	second_entry.due_work = true
	enter(second)
	before = second.calendar.query()
	check("ordinary due work deferred","deferred",tick(second,self,1000000000).kind)
	check("explicit due work deferred","deferred",second.calendar.activity(second_entry,explicit(second,"due-work",1000)).kind)
	check("deferred no clock commitment",before,second.calendar.query())
	second.dispose()
	other.providers.dispose()
	other.storage.adapter.release()
	# A separately published compatible start/rate-only override must keep saved
	# instants, fractions and deadlines while applying the new future rate.
	var compatible_app := Controller.new()
	compatible_app.start({"executable_dir":sandbox.path_join("compatible/executable"),"per_user_dir":sandbox.path_join("compatible/user")})
	compatible_app.settings.effective["startup/show_setup"] = true
	put(compatible_app.mods.root.path_join("Mods/calendar/mod.json"),package)
	put(compatible_app.mods.root.path_join("Mods/calendar/calendar.json"),contribution({"rate":3.0,"opening":date(500,4,20)}))
	compatible_app.mods.rescan()
	compatible_app.mods.edit("calendar.policy","toggle")
	compatible_app.select_folder(fixture.classic_source)
	compatible_app.continue_to_menu("run")
	var compatible_core := Core.new(shell.fixture_actor_material)
	compatible_core.calendar.definitions = compatible_app.providers.definitions
	var first_source := RefCounted.new()
	compatible_core.bind_calendar_source(first_source)
	var compatible_entry := Entry.new()
	compatible_entry.core = compatible_core
	compatible_core.provider = compatible_entry
	compatible_core.startup_route_changed("main_menu")
	enter(compatible_core,"load",saved)
	check("start-only override cannot rewrite restore",[saved.timestamp,saved.fraction],[compatible_core.calendar.query().timestamp,compatible_core.calendar.query().fraction])
	check("compatible restored rate changes future only",3000,tick(compatible_core,first_source,1000000000).actual_ms)
	var retired_provider_interval: Dictionary = compatible_core.calendar_interval(first_source,1000)
	first_source = null
	var recreated_source := RefCounted.new()
	check("ordinary source recreation binds",true,compatible_core.bind_calendar_source(recreated_source))
	check("old provider generation rejected",false,compatible_core.calendar.ordinary(recreated_source,retired_provider_interval).ok)
	check("recreated source progresses current clock",3000,tick(compatible_core,recreated_source,1000000000).actual_ms)
	enter(compatible_core,"load",saved)
	tick(compatible_core,recreated_source,100000000123)
	var combined_state: Dictionary = compatible_core.calendar.query()
	enter(compatible_core,"load",saved)
	tick(compatible_core,recreated_source,123)
	var split_hold: int = compatible_core.gates.acquire("split-capture",compatible_core.snapshot().session,["simulation"])
	var split_state: Dictionary = compatible_core.calendar.capture_snapshot().state
	compatible_core.gates.release(split_hold,"split-capture")
	tick(compatible_core,recreated_source,100000000000)
	check("production split equals combined",[combined_state.timestamp,combined_state.fraction],[compatible_core.calendar.query().timestamp,compatible_core.calendar.query().fraction])
	enter(compatible_core,"load",split_state)
	tick(compatible_core,recreated_source,100000000000)
	check("production restore mid-fraction equivalent",[combined_state.timestamp,combined_state.fraction],[compatible_core.calendar.query().timestamp,compatible_core.calendar.query().fraction])
	enter(compatible_core)
	check("start override applies to new only",Calendar.encode(date(500,4,20)).timestamp,compatible_core.calendar.query().timestamp)
	compatible_core.dispose()
	compatible_app.providers.dispose()
	compatible_app.storage.adapter.release()
	var prepare_serial: int = registry._serial
	var memory_before := OS.get_static_memory_usage()
	var sample_start: int = core.calendar.query().timestamp
	started = Time.get_ticks_usec()
	var all_accounted := true
	for index in 10000:
		all_accounted = core.advance_calendar_frame(source,0.001).ok and all_accounted
	measurements.ten_thousand_accounted_frames_usec = Time.get_ticks_usec()-started
	measurements.accounted_frame_memory_bytes = OS.get_static_memory_usage()-memory_before
	measurements.retained_clock_receipts = core.calendar.receipt_count()
	check("complete composition ten thousand accounted frames",[true,120000],[all_accounted,core.calendar.query().timestamp-sample_start])
	check("point advancement never rebuilds publication",prepare_serial,registry._serial)
	# Pure queries and conversions cannot consume RNG or mutate any owner.
	var inspected: Dictionary = core.randomness.snapshot()
	before = core.calendar.query()
	started = Time.get_ticks_usec()
	for index in 10000:
		Calendar.context(Calendar.MAX-index,policy)
		core.calendar.query()
	measurements.ten_thousand_queries_usec = Time.get_ticks_usec()-started
	check("queries leave exact clock unchanged",before,core.calendar.query())
	check("queries leave RNG unchanged",inspected,core.randomness.snapshot())
	check("calendar never draws gameplay RNG",true,rng_before.sources == inspected.sources)
	measurements.scheduler = await preload("res://tests/scheduler_cases.gd").new().run(self,shell)
	measurements.activity = await preload("res://tests/activity_policy_cases.gd").new().run(self,shell)
	if DisplayServer.get_name() != "headless":
		var start: int = core.calendar.query().timestamp
		shell.set_physics_process(true)
		for frame in 6: await shell.get_tree().physics_frame
		shell.set_physics_process(false)
		check("stock rendered physics advances calendar",true,core.calendar.query().timestamp > start)
		shell.session_shell.pause()
		start = core.calendar.query().timestamp
		shell.set_physics_process(true)
		for frame in 6: await shell.get_tree().physics_frame
		shell.set_physics_process(false)
		check("stock pause freezes rendered clock",start,core.calendar.query().timestamp)
		await RenderingServer.frame_post_draw
		var image := shell.get_viewport().get_texture().get_image()
		check("rendered calendar review available",false,image.is_empty())
		image.save_png(sandbox.path_join("calendar-clock.png"))
	return {"ok":checks.all(func(item): return item.expected == item.actual),"checks":checks,"count":checks.size(),"fixture":fixture.fixture,"scheduler_fixture":"calendar-scheduler-v1","activity_fixture":"calendar-activity-v1","engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"measurements":measurements,"inputs":{"seed":"fixture-material","elapsed":"integer nanoseconds","rate_scale":1000000}}

func before_observer(core: RefCounted, source: RefCounted, observed: Array) -> void:
	var start: int = core.calendar.query().timestamp
	tick(core,source,1000000)
	check("replacement observer sees only new commitment",[start,start+12],observed.back())
