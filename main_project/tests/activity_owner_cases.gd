extends RefCounted
const Provider = preload("res://tests/controlled_activity_provider.gd")
const Consumer = preload("res://tests/controlled_vital_consumer.gd")
var suite: RefCounted
var core: SessionLifecycle
var actors: RefCounted
var scope := ""
var serial := 0
var owners: Dictionary = {}
var motion := Provider.new("controlled-motion","MOVE",["motion"])
var clock := Provider.new("controlled-interval","TIME",["interval","time"])
var traits := Provider.new("controlled-traits","CHAR",["traits"])
var threat := Provider.new("controlled-threat","NPC",["threat"])
var recovery := Provider.new("controlled-recovery","CHAR",["recovery"])
var resolution := Provider.new("controlled-resolution","CHAR",["resolution"])
var lethal := Provider.new("controlled-lethal-continuation","CHAR",["lethal"])
var vital := Consumer.new()
var dense_calls: Array = [0]
var collapse_source := preload("res://tests/controlled_actor_source.gd").new()

func check(label: String, expected: Variant, actual: Variant) -> void:
	suite.check("activity owner "+label,expected,actual)
func view(actor := "active") -> Dictionary:
	return actors.activity_projection(scope,actor)
func context() -> Dictionary:
	return {"motion":{"climbing":false,"running":false,"voluntary_motion":false,"passive_motion":false,"swimming":false,"riding":false,"athleticism":false,"improved_athleticism":false},"argonian":false,"event":"event","success":true,"breath":{"holding":false,"breathable":false}}
func request(actor := "active", kind := "segment", game := 60000000, sim := 5000000) -> Dictionary:
	serial += 1
	var v := view(actor)
	var game_start: int = v.game if v.game != null else 0
	var sim_start: int = v.simulation if v.simulation != null else 0
	var op := "activity-"+str(serial)
	var ctx := context()
	ctx.event = op
	var providers := {}
	for role: String in owners:
		providers[role] = {"id":owners[role].id,"revision":owners[role].revision}
	return {"schema":"actor-activity-v1","session":scope,"actor":actor,"caller":clock.id,"operation":op,"content":v.content,"revision":v.revision,"kind":kind,"context":ctx,"clock":{"domain":"eligible-activity","interval":op,"start_game":game_start,"end_game":game_start+game,"start_sim":sim_start,"end_sim":sim_start+sim,"game_unit":"game-microsecond","simulation_unit":"simulated-microsecond","numerator":12,"denominator":1,"ownership":"ordinary"},"providers":providers,"source":{"source":"controlled-move","cause":"actual-activity","component":op}}
func apply(r: Dictionary) -> Dictionary:
	for provider: RefCounted in owners.values(): provider.active = r.duplicate(true)
	return actors.activity_intake(owners,r)
func drain(actor: String, amount: int) -> Dictionary:
	serial += 1
	var v := view(actor)
	var r := {"schema":"vital-intake-v1","session":scope,"actor":actor,"caller":"activity-vitals","operation":"drain-"+str(serial),"content":v.content,"revision":v.revision,"action":"drain","pool":"fatigue","unit":"internal-64","amount":amount,"attribution":{"source":"controlled-fatigue","cause":"exhaustion","component":"fatigue"}}
	vital.active = r.duplicate(true)
	var result: Dictionary = actors.vital_intake(vital,r)
	return {"request":r,"result":result}
func episode(actor: String, transition := "1", action := "advance") -> Dictionary:
	var r := request(actor,"exhaustion",0,0)
	r.context = {"transition":transition,"action":action}
	r.clock = {}
	return apply(r)
func retire() -> void:
	core.request({"id":"activity-return","mode":"return","origin":scope})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)

func run(test_suite: RefCounted, shell: Control, fixture: Dictionary) -> Dictionary:
	suite = test_suite
	core = shell.session_shell.core
	actors = core.actors
	clock.gates = core.gates
	owners = {"motion":motion,"interval":clock,"time":clock,"traits":traits,"threat":threat,"recovery":recovery,"resolution":resolution,"lethal":lethal}
	check("fresh scope","pending",core.request({"id":"activity-scope","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	var ticket := core.ticket()
	var baseline_clock := {"provider":"controlled-clock-v1","unit":"game-millisecond","instant":0}
	var dense := preload("res://tests/controlled_actor_source.gd").new()
	dense.callback = func(): dense_calls[0] += 1
	for index in 256: dense.contributions.append({"id":"dense-"+str(index),"kind":"skill","target":"medical","value":0})
	var dense_bindings: Array = []
	for index in 16: dense_bindings.append({"id":"dense-source-"+str(index),"provider":dense})
	for id in ["active","split","swimmer","argonian","jump","safe","partial","danger","water","unrecoverable","breath","reentrant","swim-zero","swim-hundred","practice-cap","interrupted","event-failure","point-dense","source-collapse","activity-edge","rapid-general","rapid-light-miss","rapid-darkness","queued"]:
		var capture: Dictionary = suite.captured(id)
		if id == "swim-zero": capture.skills.swimming = 0
		if id == "swim-hundred": capture.skills.swimming = 100
		var sources: Array = dense_bindings if id == "point-dense" else ([{"id":"source-collapse","provider":collapse_source}] if id == "source-collapse" else [])
		check("create "+id,true,actors.fresh(scope,ticket,capture,baseline_clock,sources).ok)
	var cap_record: Dictionary = actors.projection(scope,"practice-cap").record
	cap_record.progression.practice.running = 19999
	check("practice cap reconstruction",true,actors.reconstruct(scope,ticket,cap_record,[]).ok)
	var edge_record: Dictionary = actors.projection(scope,"activity-edge").record
	edge_record.revision = 1000000000
	check("revision edge reconstruction",true,actors.reconstruct(scope,ticket,edge_record,[]).ok)
	var restored := {}
	if fixture.has("restore_from"):
		var input := FileAccess.open(str(fixture.restore_from),FileAccess.READ)
		restored = input.get_var(false)
		input.close()
		var notices: Array = []
		var observe := func(event: Dictionary): notices.append(event)
		actors.vital_transition.connect(observe)
		for id: String in restored:
			check("restore complete record "+id,true,actors.reconstruct(scope,ticket,restored[id],[]).ok)
			check("restore exact state "+id,restored[id],actors.projection(scope,id).record)
		actors.vital_transition.disconnect(observe)
		check("restore emits no depletion",[],notices)
	var services: Array = [actors.service_binding(scope),vital.binding("activity-vitals","CHAR")]
	for provider in [motion,clock,traits,threat,recovery,resolution,lethal]: services.append(provider.binding())
	core.complete_baseline(ticket,{"ok":true,"services":services})
	core.complete_readiness(ticket,{"ok":true,"services":services})
	check("real composed ready",true,core.snapshot().ready)
	check("focused activity MOD hook selected","actor.formula",core.formulas.active().winners["char.activity-rate"])
	if fixture.has("restore_from"):
		var before: Dictionary = core.randomness.snapshot()
		for id: String in restored:
			var record: Dictionary = restored[id]
			var matches := true
			for caller: String in record.activity.receipts:
				for operation: String in record.activity.receipts[caller]:
					var receipt: Dictionary = record.activity.receipts[caller][operation]
					matches = matches and receipt.result == apply(receipt.request)
			check("restore retained retries "+id,true,matches)
		check("restore query retry consumes no RNG",before,core.randomness.snapshot())
		check("restore resolved Medical once",1,view("safe").practice.medical)
		check("restore pending incapacitation",1,view("unrecoverable").unresolved)
		check("restore pending water health",31,view("water").current.health)
		check("restore pending gates",true,core.gates.blocked("save"))
		retire()
		return {"source":"fresh process owner reconstruction, real composed CHAR; not native SAVE"}
	var preparation_before: int = actors.definitions.timings.prepare_serial
	var calls_before_activity: int = dense_calls[0]
	var started := Time.get_ticks_usec()
	var last_request := {}
	var last_result := {}
	for index in 1000:
		last_request = request("point-dense","segment",0,0)
		last_result = apply(last_request)
	var integration_usec := Time.get_ticks_usec()-started
	check("dense indexed activity volume",1000,actors._actors["point-dense"].record.activity.count)
	check("point writes skip source preparation",calls_before_activity,dense_calls[0])
	check("point writes skip DATA preparation",preparation_before,actors.definitions.timings.prepare_serial)
	started = Time.get_ticks_usec()
	var retries := true
	for index in 2000: retries = retries and last_result == apply(last_request)
	var lookup_usec := Time.get_ticks_usec()-started
	check("indexed retained activity volume",true,retries)
	check("revision exhaustion rejects unchanged","overflow",apply(request("activity-edge","segment",0,0)).kind)
	for index in 3096: apply(request("point-dense","segment",0,0))
	check("retention exhaustion rejects new identity","overflow",apply(request("point-dense","segment",0,0)).kind)
	check("exhausted retention preserves original retry",last_result,apply(last_request))
	for identity in ["swim-zero","swim-hundred"]:
		var endpoint := request(identity)
		endpoint.context.motion.swimming = true
		check("Swimming endpoint "+identity,44 if identity == "swim-zero" else 11,apply(endpoint).applied)
		check("Swimming endpoint practice "+identity,1,view(identity).practice.swimming)
	var cap_request := request("practice-cap")
	cap_request.context.motion.running = true
	cap_request.context.motion.voluntary_motion = true
	var cap_result := apply(cap_request)
	check("actual raw practice saturation",[20,1,20000],[cap_result.practice.running.requested,cap_result.practice.running.applied,view("practice-cap").practice.running])
	var r := request()
	r.context.motion.running = true
	var result := apply(r)
	check("stationary Run actual drain",[true,11,0],[result.ok,result.applied,view().practice.running])
	var retained := result.duplicate(true)
	check("exact retry",retained,apply(r))
	r.context.motion.voluntary_motion = true
	check("changed intent rejected","identity_conflict",apply(r).kind)
	r = request()
	r.context.motion.running = true
	r.context.motion.voluntary_motion = true
	r.context.motion.passive_motion = true
	result = apply(r)
	check("mixed moving Run",[88,20],[result.applied,view().practice.running])
	var copied := view()
	copied.practice.running = 999
	check("detached point projection",20,view().practice.running)
	r = request()
	r.context.motion.running = true
	r.context.motion.voluntary_motion = true
	r.context.motion.riding = true
	result = apply(r)
	check("riding no Running practice",20,view().practice.running)
	var queued := request("queued","segment",12000000,1000000)
	queued.context.motion.running = true
	queued.context.motion.voluntary_motion = true
	check("TIME captures performed eligibility",true,clock.capture_eligible(queued))
	var queued_hold := core.gates.acquire("controlled-queued-debt",scope,["simulation","input","save"])
	var queued_result := apply(queued)
	check("performed debt settles under later hold",[true,17,4],[queued_result.ok,queued_result.get("applied",-1),view("queued").practice.running])
	check("held new interval cannot manufacture time","unavailable",apply(request("queued","segment",12000000,1000000)).kind)
	check("queued retry cannot repeat cost",queued_result,apply(queued))
	check("queued settlement preserves producer hold",true,core.gates._holds.has(queued_hold))
	core.gates.release(queued_hold,"controlled-queued-debt")
	for index in 7:
		r = request("split","segment",8571420 if index < 6 else 8571480,714285 if index < 6 else 714290)
		r.context.motion.running = true
		r.context.motion.voluntary_motion = true
		check("split commit "+str(index),true,apply(r).ok)
	check("partition totals",[9192,20,0,0],[view("split").current.fatigue,view("split").practice.running,view("split").fatigue_remainder,view("split").running_remainder])
	r = request("jump","jump",0,0)
	r.context.event = "actual-jump"
	result = apply(r)
	check("jump charge and practice",[11,1],[result.applied,view("jump").practice.jumping])
	check("jump exact retry",result,apply(r))
	var repeated := request("jump","jump",0,0)
	repeated.context.event = "actual-jump"
	check("cross operation jump identity","identity_conflict",apply(repeated).kind)
	r = request("jump","climb-check",0,0)
	r.context.success = false
	check("failed climb check commits",true,apply(r).ok)
	check("failed climb awards",1,view("jump").practice.climbing)
	r = request("jump","rappel-complete",0,0)
	r.context.success = false
	apply(r)
	check("cancelled rappel no award",1,view("jump").practice.climbing)
	r = request("jump","rappel-complete",0,0)
	apply(r)
	check("successful rappel one award",2,view("jump").practice.climbing)
	var rng: Dictionary = core.randomness.snapshot()
	r = request("swimmer")
	r.context.motion.swimming = true
	var swimming_result := apply(r)
	check("selected Swimming commits",true,swimming_result.ok)
	check("Swimming minute practice",1,view("swimmer").practice.swimming)
	var after_swim: Dictionary = core.randomness.snapshot()
	check("Swimming exact retry",swimming_result,apply(r))
	check("Swimming retry no reroll",after_swim,core.randomness.snapshot())
	check("Swimming consumed approved stream",false,rng == after_swim)
	r = request("argonian")
	r.context.motion.swimming = true
	r.context.argonian = true
	check("effective Argonian ordinary cost",11,apply(r).applied)
	for ownership in ["rest","training","travel","paused"]:
		r = request("active","segment",0 if ownership == "paused" else 60000000,0)
		r.clock.ownership = ownership
		r.context.motion.running = true
		r.context.motion.voluntary_motion = true
		result = apply(r)
		check("excluded "+ownership,[true,0,20],[result.ok,result.applied,view().practice.running])
	for field in ["schema","actor","clock","providers","source"]:
		r = request()
		r.erase(field)
		check("reject missing "+field,false,actors.activity_intake(owners,r).ok)
	r = request()
	r.clock.start_game -= 1
	check("overlap rejected","stale",apply(r).kind)
	r = request()
	r.clock.end_sim += 1
	check("clock mapping rejected","stale",apply(r).kind)
	r = request()
	r.clock.end_game = true
	check("boolean duration rejected",false,apply(r).ok)
	r = request()
	r.content -= 1
	check("stale content rejected","stale",apply(r).kind)
	r = request()
	r.providers.traits.revision += 1
	check("stale traits unavailable","unavailable",apply(r).kind)
	r = request("reentrant")
	var nested: Array = []
	motion.callback = func(): nested.append(actors.activity_intake(owners,r).kind)
	check("outer activity survives reentry",true,apply(r).ok)
	motion.callback = Callable()
	check("reentry blocked",true,nested.all(func(value): return value == "busy"))
	r = request("breath","breath",0,0)
	r.context.breath.holding = true
	check("breath explicit entry",true,apply(r).ok)
	check("breath initialized only by activity",25,view("breath").breath.reserve)
	r = request("breath")
	r.context.breath.holding = true
	check("unsupported consumption unavailable","unavailable",apply(r).kind)
	r = request("breath","breath",0,0)
	r.context.breath.breathable = true
	check("supported instant breathing",true,apply(r).ok)
	for pool in ["health","magicka"]:
		var injury: Dictionary = drain("safe",0).request
		injury.operation += "-"+pool
		injury.revision = view("safe").revision
		injury.pool = pool
		injury.unit = "points"
		injury.amount = 6 if pool == "health" else 21
		injury.attribution.cause = "controlled-injury"
		injury.attribution.component = pool
		vital.active = injury.duplicate(true)
		actors.vital_intake(vital,injury)
	var original_depletion := drain("safe",1000000000)
	check("real transition gates",true,core.gates.blocked("save"))
	check("pending intake cannot ack",false,actors.acknowledge_vital(vital,original_depletion.request).ok)
	var unrelated := core.gates.acquire("activity-review",scope,["input","save"])
	var safe := episode("safe")
	check("safe collapse resolved",[true,"resolved",3600000000],[safe.ok,safe.phase,safe.elapsed])
	check("safe current recovery",[1160,1],[view("safe").current.fatigue,view("safe").practice.medical])
	check("shared recovery actual three pools",{"health":27,"fatigue":1160,"magicka":93},view("safe").current)
	if DisplayServer.get_name() != "headless":
		var panel := PanelContainer.new()
		panel.position = Vector2(24,24)
		var diagnostic := preload("res://scripts/char/activity_diagnostics.gd").new()
		panel.add_child(diagnostic)
		shell.add_child(panel)
		diagnostic.bind(actors,scope,"safe","1")
		check("rendered diagnostic reads resolved episode","resolved",diagnostic.observed.episode.phase)
		await suite.capture(shell,"activity-collapse-resolved")
		panel.queue_free()
	check("safe leaves unrelated hold",true,core.gates._holds.has(unrelated))
	check("historical intake unchanged",original_depletion.result,actors.vital_intake(vital,original_depletion.request))
	check("checked settled intake acknowledgment",true,actors.acknowledge_vital(vital,original_depletion.request).ok)
	var safe_state: Dictionary = actors.projection(scope,"safe").record
	check("resolved record validates",true,actors.activity.valid(safe_state))
	check("resolved vital record validates",true,actors.Vital.valid(safe_state))
	var calls_before: Dictionary = clock.calls.duplicate()
	check("episode repeat no hour","resolved",episode("safe").phase)
	check("episode repeat no time callback",calls_before,clock.calls)
	check("episode repeat no Medical",1,view("safe").practice.medical)
	core.gates.release(unrelated,"activity-review")
	check("only own holds released",false,core.gates.blocked("save"))
	drain("partial",1000000000)
	clock.elapsed = 1800000000
	clock.time_phase = "in-progress"
	clock.events = [true,false,false]
	check("partial retains phase","time-pending",episode("partial").phase)
	check("partial no recovery or Medical",[0,0],[view("partial").current.fatigue,view("partial").practice.medical])
	if DisplayServer.get_name() != "headless":
		var panel := PanelContainer.new()
		panel.position = Vector2(24,24)
		var diagnostic := preload("res://scripts/char/activity_diagnostics.gd").new()
		panel.add_child(diagnostic)
		shell.add_child(panel)
		diagnostic.bind(actors,scope,"partial","1")
		check("rendered diagnostic reads pending elapsed",1800000000,diagnostic.observed.episode.elapsed)
		await suite.capture(shell,"activity-collapse-pending")
		panel.queue_free()
	clock.elapsed = 3600000000
	clock.time_phase = "completed"
	clock.events = [true,true,true]
	check("resume settles hour","resolved",episode("partial").phase)
	check("resume once Medical",1,view("partial").practice.medical)
	drain("event-failure",1000000000)
	clock.events = [true,false,false]
	check("completed time pending required event","time-pending",episode("event-failure").phase)
	check("unsettled event no benefit",[0,0],[view("event-failure").current.fatigue,view("event-failure").practice.medical])
	clock.events = [true,true,true]
	recovery.fail_query = true
	check("failed recovery query retains hour","time-pending",episode("event-failure").phase)
	var settled_time_calls: Dictionary = clock.calls.duplicate()
	recovery.fail_query = false
	check("retry only unfinished recovery","resolved",episode("event-failure").phase)
	check("settled time not called again",settled_time_calls,clock.calls)
	drain("interrupted",1000000000)
	clock.elapsed = 1800000000
	clock.time_phase = "interrupted"
	check("interrupted default incapacitated","incapacitated",episode("interrupted").phase)
	check("unfinished hour zero benefit",[0,0],[view("interrupted").current.fatigue,view("interrupted").practice.medical])
	var fill_request: Dictionary = drain("interrupted",0).request
	fill_request.operation += "-fill"
	fill_request.revision = view("interrupted").revision
	fill_request.action = "fill"
	fill_request.amount = 0
	vital.active = fill_request.duplicate(true)
	check("supported fill before explicit resolution",true,actors.vital_intake(vital,fill_request).ok)
	check("fill cannot erase episode",1,view("interrupted").unresolved)
	resolution.malformed = true
	check("malformed resolution preserves obligation",["incapacitated",1],[episode("interrupted","1","resolve").phase,view("interrupted").unresolved])
	resolution.malformed = false
	check("explicit checked resolution","resolved",episode("interrupted","1","resolve").phase)
	check("resolution clears only settled obligation",0,view("interrupted").unresolved)
	clock.elapsed = 3600000000
	clock.time_phase = "completed"
	collapse_source.revision += 1
	collapse_source.contributions = [{"id":"strength-zero","kind":"attribute","target":"strength","value":-95},{"id":"endurance-zero","kind":"attribute","target":"endurance","value":-50}]
	check("source maximum depletion",true,actors.reconcile(scope,{},"source-collapse",view("source-collapse").revision,view("source-collapse").content).ok)
	check("zero maximum collapse incapacitated","incapacitated",episode("source-collapse").phase)
	check("zero maximum no fictitious fatigue",[0,1],[view("source-collapse").current.fatigue,view("source-collapse").practice.medical])
	collapse_source.revision += 1
	collapse_source.contributions = []
	check("source restoration no refill",true,actors.reconcile(scope,{},"source-collapse",view("source-collapse").revision,view("source-collapse").content).ok)
	check("source restoration keeps zero",0,view("source-collapse").current.fatigue)
	var source_fill: Dictionary = drain("source-collapse",0).request
	source_fill.operation += "-fill"
	source_fill.revision = view("source-collapse").revision
	source_fill.action = "fill"
	vital.active = source_fill.duplicate(true)
	actors.vital_intake(vital,source_fill)
	check("source episode explicit resolution","resolved",episode("source-collapse","1","resolve").phase)
	check("source episode never repeats hour",1,view("source-collapse").practice.medical)
	for variant in [{"id":"rapid-general","rapid":"general","expected":3},{"id":"rapid-light-miss","rapid":"light","expected":2},{"id":"rapid-darkness","rapid":"darkness","expected":3}]:
		recovery.rapid = variant.rapid
		recovery.environment = "darkness"
		recovery.no_magicka = true
		drain(variant.id,1000000000)
		episode(variant.id)
		check("Rapid Healing "+variant.id,variant.expected,actors.activity_projection(scope,variant.id,"","","1").episode.recovery.rates.health)
	check("no magicka regeneration restriction",0,actors.activity_projection(scope,"rapid-general","","","1").episode.recovery.rates.magicka)
	recovery.rapid = "none"
	recovery.no_magicka = false
	drain("unrecoverable",1000000000)
	recovery.fatigue_allowed = false
	check("blocked recovery incapacitated","incapacitated",episode("unrecoverable").phase)
	check("incapacitated no loop","incapacitated",episode("unrecoverable").phase)
	check("incapacitated only one Medical",1,view("unrecoverable").practice.medical)
	recovery.fatigue_allowed = true
	drain("danger",1000000000)
	threat.fail_query = true
	check("failed query unresolved","admitted",episode("danger").phase)
	threat.fail_query = false
	threat.malformed = true
	check("malformed threat stays unresolved","admitted",episode("danger").phase)
	threat.malformed = false
	threat.threat = true
	check("threat lethal unavailable","lethal-unavailable",episode("danger").phase)
	check("threat health unchanged",31,view("danger").current.health)
	threat.threat = false
	drain("water",1000000000)
	motion.swimming = true
	check("surface swimming lethal unavailable","lethal-unavailable",episode("water").phase)
	check("water no safe hour",0,view("water").practice.medical)
	check("controlled prevention-zero continuation","incapacitated",episode("water","1","prevention-continuation").phase)
	check("prevention zero cannot replay lethal","incapacitated",episode("water").phase)
	check("prevention zero no safe fallback",0,view("water").practice.medical)
	check("unresolved gate remains",true,core.gates.blocked("save"))
	var snapshot: Dictionary = actors.projection(scope,"active").record
	check("activity record validates",true,actors.activity.valid(snapshot))
	var bad: Dictionary = snapshot.duplicate(true)
	bad.activity.fatigue_remainder = true
	check("invalid saved remainder rejected",false,actors.activity.valid(bad))
	bad = snapshot.duplicate(true)
	bad.activity.fatigue_remainder = 1
	check("in-range saved debt corruption rejected",false,actors.activity.valid(bad))
	bad = safe_state.duplicate(true)
	bad.activity.episodes["1"].recovery.context.fatigue_allowed = 1
	check("saved recovery raw types rejected",false,actors.activity.valid(bad))
	bad = safe_state.duplicate(true)
	bad.activity.episodes["1"].phase = "incapacitated"
	bad.activity.episodes["1"].resolution = {}
	bad.activity.episodes["1"].time.events = [true,false,false]
	bad.activity.resolved_count = 0
	bad.activity.active = "1"
	check("saved unresolved events cannot resolve",false,actors.activity.valid(bad))
	var checkpoint_records := {}
	for id in ["active","safe","partial","unrecoverable","water","swimmer","breath"]: checkpoint_records[id] = actors.projection(scope,id).record
	var checkpoint_file := FileAccess.open(str(fixture.sandbox).path_join("activity-checkpoint.bin"),FileAccess.WRITE)
	checkpoint_file.store_var(checkpoint_records)
	checkpoint_file.close()
	retire()
	check("retired activity rejected","stale",apply(r).kind)
	return {"source":"controlled MOVE/TIME/traits/threat/restrictions; real composed CHAR/CORE/DATA/RULE/RNG","safe_record":safe_state,"activity_record":snapshot,"dense_activity_1000_usec":integration_usec,"retained_activity_2000_usec":lookup_usec,"dense_sources":16,"contributions_per_source":256}

