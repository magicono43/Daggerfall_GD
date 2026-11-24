extends RefCounted
const Consumer = preload("res://tests/controlled_vital_consumer.gd")
const Records = preload("res://scripts/char/vital_records.gd")
var suite: RefCounted
var core: SessionLifecycle
var actors: RefCounted
var magic := Consumer.new()
var combat := Consumer.new()
var item := Consumer.new()
var scope := ""
var serial := 0
var observed: Array = []
var prevention := preload("res://tests/controlled_prevention.gd").new()

func view(actor := "vital-player") -> Dictionary:
	return actors.projection(scope,actor)
func request(action: String, pool: String, amount: Variant, actor := "vital-player", caller := "magic-intake") -> Dictionary:
	serial += 1
	var r: Dictionary = actors.vital_projection(scope,actor)
	return {"schema":"vital-intake-v1","session":scope,"actor":actor,"caller":caller,"operation":"operation-"+str(serial),"content":r.content,"revision":r.revision,"action":action,"pool":pool,"unit":Records.UNITS.get(pool,"activity-reserve"),"amount":amount,"attribution":{"source":"controlled-source","cause":"controlled-intake","component":"component-1"}}
func apply(r: Dictionary, owner: RefCounted = magic) -> Dictionary:
	owner.active = r.duplicate(true)
	return actors.vital_intake(owner,r)
func check(label: String, expected: Variant, actual: Variant) -> void:
	suite.check("vital "+label,expected,actual)
func retire(id: String) -> void:
	core.request({"id":id,"mode":"return","origin":scope})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)

func run(test_suite: RefCounted, shell: Control) -> Dictionary:
	suite = test_suite
	core = shell.session_shell.core
	actors = core.actors
	check("controlled fresh scope","pending",core.request({"id":"vital-scope","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	var original := core.ticket()
	var clock := {"provider":"controlled-clock-v1","unit":"game-millisecond","instant":0}
	var changing_source := preload("res://tests/controlled_actor_source.gd").new()
	var transition_notices: Array = []
	var transition_observer := func(event: Dictionary):
		transition_notices.append(event.duplicate(true))
		event.pending = false
	actors.vital_transition.connect(transition_observer)
	for id in ["vital-player","vital-zero","vital-exhaustion","vital-reconcile","vital-retire","vital-edge"]:
		var capture: Dictionary = suite.captured(id)
		if id == "vital-zero":
			capture.attributes.intelligence = 0
			capture.attributes.strength = 0
			capture.attributes.endurance = 0
		check("create "+id,true,actors.fresh(scope,original,capture,clock,[{"id":"changing-source","provider":changing_source}] if id == "vital-reconcile" else []).ok)
	var edge: Dictionary = view("vital-edge").record
	edge.revision = 1000000000
	check("edge hydration",true,actors.reconstruct(scope,original,edge,[]).ok)
	# Independently authored checkpoint vectors, inside the existing CORE gate.
	# The receipt's 102 ->100 debit is already committed and must never replay.
	var checkpoint: Dictionary = view().record.duplicate(true)
	checkpoint.actor = "vital-restored"
	checkpoint.schema = "actor-state-v2"
	checkpoint.revision = 2
	checkpoint.current.magicka = 100
	checkpoint["vitals"] = Records.empty()
	var saved_request := {"schema":"vital-intake-v1","session":scope,"actor":"vital-restored","caller":"magic-intake","operation":"saved-operation","content":checkpoint.content,"revision":1,"action":"spend","pool":"magicka","unit":"points","amount":2,"attribution":{"source":"saved-source","cause":"saved-intake","component":"component-1"}}
	var saved_result := {"schema":"applied-vital-v1","ok":true,"kind":"applied","phase":"committed","session":scope,"actor":"vital-restored","caller":"magic-intake","operation":"saved-operation","action":"spend","pool":"magicka","unit":"points","requested":2,"before":102,"after":100,"maximum":102,"applied":2,"remainder":0,"revision":2,"attribution":saved_request.attribution.duplicate(),"transition_pending":false,"continuation_allowed":true}
	checkpoint.vitals.receipts = {"magic-intake":{"saved-operation":{"request":saved_request,"result":saved_result,"acknowledged":false}}}
	checkpoint.vitals.receipt_count = 1
	check("completed checkpoint reconstruction",true,actors.reconstruct(scope,original,checkpoint,[]).ok)
	check("completed checkpoint exact no refill",checkpoint,view("vital-restored").record)
	check("repeated checkpoint no replay",true,actors.reconstruct(scope,original,checkpoint,[]).ok)
	var ack_edge := checkpoint.duplicate(true)
	ack_edge.actor = "vital-ack-edge"
	ack_edge.revision = 1000000000
	ack_edge.vitals.receipts["magic-intake"]["saved-operation"].request.actor = ack_edge.actor
	ack_edge.vitals.receipts["magic-intake"]["saved-operation"].result.actor = ack_edge.actor
	var ack_edge_request: Dictionary = ack_edge.vitals.receipts["magic-intake"]["saved-operation"].request.duplicate(true)
	check("ack revision edge reconstructs",true,actors.reconstruct(scope,original,ack_edge,[]).ok)
	var pending_checkpoint: Dictionary = view("vital-exhaustion").record.duplicate(true)
	pending_checkpoint.schema = "actor-state-v2"
	pending_checkpoint.current.fatigue = 0
	pending_checkpoint["vitals"] = Records.empty()
	pending_checkpoint.vitals.next_transition = 1
	pending_checkpoint.vitals.pending_count = 1
	pending_checkpoint.vitals.transitions = {"1":{"pool":"fatigue","before":9280,"after":0,"context":{"kind":"source-reconciliation","sources":{}},"pending":true,"outcome":"owner-unavailable"}}
	check("pending checkpoint reconstruction",true,actors.reconstruct(scope,original,pending_checkpoint,[]).ok)
	check("pending checkpoint retained no replay",pending_checkpoint,view("vital-exhaustion").record)
	var unsupported_lethal := pending_checkpoint.duplicate(true)
	unsupported_lethal.actor = "unsupported-lethal"
	unsupported_lethal.vitals.transitions["1"].pool = "health"
	unsupported_lethal.vitals.transitions["1"].before = 31
	check("unsupported staged lethal reconstruction rejected",false,actors.reconstruct(scope,original,unsupported_lethal,[]).ok)
	var zero_health: Dictionary = view().record.duplicate(true)
	zero_health.actor = "vital-zero-health"
	zero_health.current.health = 0
	check("existing zero health reconstruction",true,actors.reconstruct(scope,original,zero_health,[]).ok)
	var zero_recover: Dictionary = view().record.duplicate(true)
	zero_recover.actor = "vital-zero-recover"
	zero_recover.current.fatigue = 0
	check("zero condition checkpoint reconstructs",true,actors.reconstruct(scope,original,zero_recover,[]).ok)
	# Restore the separate test actor using a fresh handle: never erase this hold.
	check("fresh exhaustion actor",true,actors.fresh(scope,original,suite.captured("vital-exhaustion-new"),clock,[]).ok)
	var crowd_sources: Array = []
	for source in 16:
		var contributor := preload("res://tests/controlled_actor_source.gd").new()
		for contribution in 16: contributor.contributions.append(suite.c("skill-"+str(contribution),"skill","medical",1))
		crowd_sources.append({"id":"crowd-source-"+str(source),"provider":contributor})
	var crowd_ok := true
	for actor in 128: crowd_ok = actors.fresh(scope,original,suite.captured("vital-crowd-"+str(actor)),clock,crowd_sources).ok and crowd_ok
	check("dense actor composition",true,crowd_ok)
	check("reconstruction never replays transition notification",0,transition_notices.size())
	var source_calls := [0]
	for binding in crowd_sources: binding.provider.callback = func(): source_calls[0] += 1
	var services := [actors.service_binding(scope),magic.binding("magic-intake","MAGIC"),combat.binding("combat-intake","COMBAT"),item.binding("item-intake","ITEM"),prevention.binding()]
	check("UI authority declaration rejected",false,core._validate_vital_bindings([magic.binding("ui","UI")]).ok)
	check("duplicate consumer binding rejected",false,core._validate_vital_bindings([magic.binding("a","MAGIC"),magic.binding("b","MAGIC")]).ok)
	core.complete_baseline(original,{"ok":true,"services":services})
	core.complete_readiness(original,{"ok":true,"services":services})
	check("controlled readiness real CHAR",true,core.snapshot().ready)
	check("reconstructed technical redelivery",saved_result,actors.vital_intake(magic,saved_request))
	check("ack revision exhaustion","overflow",actors.acknowledge_vital(magic,ack_edge_request).kind)
	check("zero health cannot heal","unavailable",apply(request("heal","health",1,"vital-zero-health")).kind)
	check("zero health cannot fill","unavailable",apply(request("fill","health",0,"vital-zero-health","item-intake"),item).kind)
	var zero_recovered := apply(request("recover","fatigue",1,"vital-zero-recover"))
	check("recovery clears zero condition",[true,0,1],[zero_recovered.ok,zero_recovered.before,zero_recovered.after])
	check("zero-only hold released after recovery",false,actors._vital_holds.has("vital-zero-recover"))
	check("other pending actor holds preserved",true,core.gates.blocked("save"))
	var rng: Dictionary = core.randomness.snapshot()
	var initial: Dictionary = view().record.current
	var r := request("spend","magicka",0)
	var first_request := r.duplicate(true)
	var zero := apply(r)
	check("zero spend authoritative",[true,102,102,0,0],[zero.ok,zero.before,zero.after,zero.applied,zero.remainder])
	r = request("spend","magicka",102)
	var exact := apply(r)
	check("exact spend to zero",[true,102,0,102,false],[exact.ok,exact.before,exact.after,exact.applied,exact.transition_pending])
	check("retained retry after revision",exact,actors.vital_intake(magic,r))
	magic.active.clear()
	check("retained retry after operation ended",exact,actors.vital_intake(magic,r))
	var changed := r.duplicate(true)
	changed.amount = 1
	check("changed intent conflict","identity_conflict",actors.vital_intake(magic,changed).kind)
	var p := view()
	p.record.current.health = 0
	p.record.vitals.receipts.clear()
	check("copies detached",31,view().record.current.health)
	var insufficient_request := request("spend","magicka",1)
	var insufficient := apply(insufficient_request)
	check("insufficient unchanged",[false,"insufficient",0,0],[insufficient.ok,insufficient.kind,insufficient.applied,view().record.current.magicka])
	check("insufficient cannot continue","unavailable",actors.acknowledge_vital(magic,insufficient_request).kind)
	r = request("heal","magicka",1000000000)
	var healed := apply(r)
	check("overheal actual gain",[0,102,102,999999898],[healed.before,healed.after,healed.applied,healed.remainder])
	check("insufficient retry after recovery",insufficient,actors.vital_intake(magic,insufficient_request))
	check("later consumer failure leaves debit",102,exact.applied)
	check("continuation ack",true,actors.acknowledge_vital(magic,r).ok)
	var after_ack: int = view().record.revision
	check("ack redelivery no revision",[true,after_ack],[actors.acknowledge_vital(magic,r).ok,view().record.revision])
	check("retained result immutable after ack",healed,actors.vital_intake(magic,r))
	var stale := request("spend","magicka",1)
	apply(request("spend","magicka",2))
	check("distinct stale revision rejected","stale",apply(stale).kind)
	r = request("damage","health",7,"vital-player","combat-intake")
	var consumer_hold: int = core.gates.acquire("controlled-COMBAT:continuation",scope,["simulation","input","save"])
	var physical_request := r.duplicate(true)
	var physical := apply(r,combat)
	check("physical actual loss",[31,24,7],[physical.before,physical.after,physical.applied])
	var magical := apply(request("damage","health",3))
	check("separate magical loss",[24,21,3,"magic-intake"],[magical.before,magical.after,magical.applied,magical.caller])
	var lethal_before := view()
	var lethal_request := request("damage","health",1000000000,"vital-player","combat-intake")
	var lethal := apply(lethal_request,combat)
	check("lethal unavailable unchanged",["sources",21,true],[lethal.phase,view().record.current.health,core.gates.blocked("save")])
	var ordered_components := {"physical":physical,"magical":magical,"remainder":lethal}
	check("ordered components preserve earlier settlement",[7,3,"lethal",21],[ordered_components.physical.applied,ordered_components.magical.applied,ordered_components.remainder.kind,view().record.current.health])
	prevention.ready = true
	var prevented := apply(lethal_request,combat)
	check("pending lethal resumes to positive survival",["prevented",21,3,3],[prevented.phase,prevented.applied,prevented.after,view().record.current.health])
	check("failed continuation leaves acknowledgment pending",false,view().record.vitals.receipts["combat-intake"][physical_request.operation].acknowledged)
	check("component retry cannot repeat earlier loss",physical,actors.vital_intake(combat,physical_request))
	check("failed remainder retains consumer safety hold",true,core.gates._holds.has(consumer_hold) and core.gates._holds[consumer_hold].owner == "controlled-COMBAT:continuation")
	check("ordered consumer acknowledges settled component",true,actors.acknowledge_vital(combat,physical_request).ok)
	check("partial acknowledgment retains remainder hold",true,core.gates._holds.has(consumer_hold))
	check("physical and magical attribution retained",["combat-intake","magic-intake"],[physical.caller,magical.caller])
	var ineligible := apply(request("heal","health",1,"vital-player","combat-intake"),combat)
	check("combat healing ineligible","ineligible",ineligible.kind)
	r = request("fill","health",0,"vital-player","item-intake")
	var fill := apply(r,item)
	check("eligible health fill",[3,31,28,0],[fill.before,fill.after,fill.applied,fill.remainder])
	for pool in ["health","fatigue","magicka"]:
		var full := apply(request("fill",pool,0,"vital-player","item-intake"),item)
		check("full fill "+pool,[true,2 if pool == "magicka" else 0,0],[full.ok,full.applied,full.remainder])
	for action in ["damage","drain","heal","recover","spend"]:
		for pool in ["health","fatigue","magicka"]:
			var result := apply(request(action,pool,0))
			check("supported action "+action+" "+pool,[true,0],[result.ok,result.applied])
	for amount in [-1,true,1.5,INF,NAN,9223372036854775807]:
		var before := view()
		var invalid := apply(request("heal","health",amount))
		check("invalid amount "+str(amount),[false,before],[invalid.ok,view()])
	for field in ["schema","session","actor","caller","operation","content","revision","action","pool","unit","amount","attribution"]:
		var missing := request("heal","health",1)
		missing.erase(field)
		check("missing "+field,false,actors.vital_intake(magic,missing).ok)
	for field in ["session","actor","caller","operation","content","revision","action","pool","unit","attribution"]:
		var invalid := request("heal","health",1)
		invalid[field] = true
		check("raw type "+field,false,actors.vital_intake(magic,invalid).ok)
	for pair in [["pool","breath"],["unit","points-64"],["action","revive"],["actor","unknown"],["session","session-old"],["caller","ui"],["content",0],["revision",0]]:
		var invalid := request("heal","fatigue",1)
		invalid[pair[0]] = pair[1]
		check("unsupported "+str(pair[0])+" "+str(pair[1]),false,apply(invalid).ok)
	var unbound := Consumer.new()
	check("unbound owner rejected",false,apply(request("heal","health",0),unbound).ok)
	var attribution := request("heal","health",0)
	attribution.attribution.source = ""
	check("invalid attribution",false,apply(attribution).ok)
	check("fill amount must be zero",false,apply(request("fill","health",1,"vital-player","item-intake"),item).ok)
	check("revision exhaustion unchanged",["overflow",edge],[apply(request("spend","magicka",1,"vital-edge")).kind,view("vital-edge").record])
	var absent_definitions: RefCounted = actors.definitions
	actors.definitions = null
	check("missing DATA rejected",false,apply(request("spend","magicka",0)).ok)
	actors.definitions = absent_definitions
	var empty_pool := apply(request("drain","magicka",1000000000,"vital-zero"))
	check("zero maximum no transition",[true,0,0],[empty_pool.ok,empty_pool.applied,view("vital-zero").record.vitals.transitions.size()])
	var drained := apply(request("drain","magicka",1000000000))
	check("overdrain saturation",[true,102,0,999999898],[drained.ok,drained.applied,drained.after,drained.remainder])
	var transitions: int = view().record.vitals.transitions.size()
	apply(request("drain","magicka",1))
	check("repeated zero no transition",transitions,view().record.vitals.transitions.size())
	apply(request("recover","magicka",1))
	apply(request("drain","magicka",1))
	check("rearmed after recovery",transitions+1,view().record.vitals.transitions.size())
	changing_source.contributions = [suite.c("zero-strength","attribute","strength",-95),suite.c("zero-endurance","attribute","endurance",-50)]
	changing_source.revision += 1
	var source_view := view("vital-reconcile")
	check("source maximum clamps to zero",true,actors.reconcile(scope,{},"vital-reconcile",source_view.record.revision,source_view.record.content).ok)
	check("source transition counted",[0,0,1],[view("vital-reconcile").record.current.fatigue,view("vital-reconcile").derived.limits.fatigue,view("vital-reconcile").record.vitals.transitions.size()])
	changing_source.contributions = []
	changing_source.revision += 1
	source_view = view("vital-reconcile")
	check("source removal recomputes",true,actors.reconcile(scope,{},"vital-reconcile",source_view.record.revision,source_view.record.content).ok)
	check("source maximum increase no refill",[0,9280,1],[view("vital-reconcile").record.current.fatigue,view("vital-reconcile").derived.limits.fatigue,view("vital-reconcile").record.vitals.transitions.size()])
	check("source clamp notifies once",4,transition_notices.size())
	check("generic fill excludes breath",false,apply(request("fill","breath",0,"vital-player","item-intake"),item).ok)
	var coherent := request("heal","health",0)
	magic.callback = func(): observed.append(actors.vital_intake(magic,coherent).kind)
	check("reentrant admission outer succeeds",true,apply(coherent).ok)
	magic.callback = Callable()
	check("reentrant intake busy",["busy"],observed)
	var technical_before := view()
	magic.status = 1
	check("technical precommit failure",["technical_failure",technical_before],[apply(request("spend","magicka",0)).kind,view()])
	magic.status = true
	magic.active.clear()
	check("stale owner operation",false,actors.vital_intake(magic,request("heal","health",0)).ok)
	var notices: Array = []
	var observer := func(outcome: Dictionary):
		notices.append([view().record.current.health,outcome.after,actors.vital_intake(magic,coherent).kind])
		outcome.after = -1
	actors.vital_committed.connect(observer)
	var notice_result := apply(request("heal","health",0))
	actors.vital_committed.disconnect(observer)
	check("notifications committed coherent detached",[[31,31,"busy"]],notices)
	check("observer mutation cannot alter receipt",31,notice_result.after)
	var mutable_request := request("heal","health",0)
	magic.callback = func(): mutable_request.attribution.source = "mutated-caller"
	var copied_request := apply(mutable_request)
	magic.callback = Callable()
	check("caller mutation detached during callback","controlled-source",copied_request.attribution.source)
	var narrow: Dictionary = actors.vital_projection(scope,"vital-player")
	narrow.current.health = 0
	check("narrow projection detached",31,actors.vital_projection(scope,"vital-player").current.health)
	var unrelated: int = core.gates.acquire("vital-unrelated","",["save"])
	var exhaustion_request := request("spend","fatigue",9280,"vital-exhaustion-new")
	var exhausted := apply(exhaustion_request)
	check("fatigue depletion pending outcome",[true,9280,true,false],[exhausted.ok,exhausted.applied,exhausted.transition_pending,exhausted.continuation_allowed])
	check("transition notifications once per crossing",5,transition_notices.size())
	check("notification cannot alter pending receipt",true,view("vital-exhaustion-new").record.vitals.transitions["1"].pending)
	check("fatigue pending safety and save holds",[true,true,true],[core.gates.blocked("simulation"),core.gates.blocked("input"),core.gates.blocked("save")])
	check("pending cannot acknowledge","unavailable",actors.acknowledge_vital(magic,exhaustion_request).kind)
	var pending: Dictionary = view("vital-exhaustion-new").record
	check("completed record validator",true,Records.valid(view().record))
	check("pending record validator",true,Records.valid(pending))
	for field in ["revision","content","actor","session"]:
		var raw_context := pending.duplicate(true)
		raw_context[field] = true
		check("record context raw type "+field,false,Records.valid(raw_context))
		raw_context.erase(field)
		check("record context missing "+field,false,Records.valid(raw_context))
	check("retained record plain string keys",true,actors._plain(pending))
	var corrupted := pending.duplicate(true)
	corrupted.vitals.receipts["magic-intake"][exhaustion_request.operation].result.applied = 0
	check("corrupted retained result rejected",false,Records.valid(corrupted))
	corrupted = pending.duplicate(true)
	corrupted.vitals.transitions["1"].outcome = "dead"
	check("unsupported pending outcome rejected",false,Records.valid(corrupted))
	corrupted = pending.duplicate(true)
	corrupted.vitals.transitions.clear()
	corrupted.vitals.next_transition = 0
	corrupted.vitals.pending_count = 0
	check("missing depletion obligation rejected",false,Records.valid(corrupted))
	corrupted = pending.duplicate(true)
	var duplicate_receipt: Dictionary = corrupted.vitals.receipts["magic-intake"][exhaustion_request.operation].duplicate(true)
	duplicate_receipt.request.caller = "other-intake"
	duplicate_receipt.result.caller = "other-intake"
	corrupted.vitals.receipts["other-intake"] = {exhaustion_request.operation:duplicate_receipt}
	corrupted.vitals.receipt_count += 1
	check("duplicate receipt revision rejected",false,Records.valid(corrupted))
	check("randomness unchanged",rng,core.randomness.snapshot())
	if DisplayServer.get_name() != "headless":
		var layer := CanvasLayer.new()
		layer.layer = 110
		shell.add_child(layer)
		var background := ColorRect.new()
		background.color = Color("#12212b")
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		layer.add_child(background)
		var rows := VBoxContainer.new()
		rows.position = Vector2(36,36)
		rows.size = Vector2(1060,600)
		rows.add_theme_constant_override("separation",18)
		layer.add_child(rows)
		var review: Dictionary = actors.vital_projection(scope,"vital-player")
		for text in ["IMP-016 / Vital intake / Composed CHAR authority", "Controlled COMBAT and MAGIC consumers; production CORE / CHAR / DATA / RULE", "Health: %s / %s | Magicka: %s / %s" % [review.current.health,review.maximum.health,review.current.magicka,review.maximum.magicka], "Physical loss 7; separate magical loss 3; lethal remainder rejected unchanged.", "Exact payment: 102 requested / 102 applied. Redelivery retains one outcome.", "Fatigue 9280 -> 0: transition retained, collapse owner unavailable.", "Simulation / input / save gated. Prevention, death, breath and native SAVE remain open."]:
			var label := Label.new()
			label.text = text
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.add_theme_font_size_override("font_size",23)
			rows.add_child(label)
		await suite.capture(shell,"vital-intake-review")
		var pixel: Color = shell.get_viewport().get_texture().get_image().get_pixel(8,8)
		check("rendered composed surface",true,absf(pixel.r-background.color.r) < 0.01 and absf(pixel.g-background.color.g) < 0.01)
		check("rendered query preserves outcome",physical,actors.vital_intake(combat,physical_request))
		layer.free()
	var started := Time.get_ticks_usec()
	for index in 1000: apply(request("heal","health",0))
	var mutation_usec := Time.get_ticks_usec()-started
	started = Time.get_ticks_usec()
	for index in 2000: actors.vital_intake(magic,coherent)
	var lookup_usec := Time.get_ticks_usec()-started
	check("indexed retained volume",true,view().record.vitals.receipt_count >= 1000)
	check("retained volume remains valid",true,Records.valid(view().record))
	started = Time.get_ticks_usec()
	for index in 1000: apply(request("recover","magicka",0,"vital-crowd-127"))
	var dense_mutation_usec := Time.get_ticks_usec()-started
	check("dense mutation does not resolve sources",266,view("vital-crowd-127").derived.skills.medical.live)
	check("dense mutations never call source providers",0,source_calls[0])
	var remaining: int = 4096-view().record.vitals.receipt_count
	for index in remaining: apply(request("heal","health",0))
	var exhausted_hash: String = JSON.stringify(view().record).sha256_text()
	check("retention exhaustion rejects unchanged",["overflow",exhausted_hash],[apply(request("heal","health",0)).kind,JSON.stringify(view().record).sha256_text()])
	check("exhausted index retains original",zero,actors.vital_intake(magic,first_request))
	check("volume mutations and retries preserve RNG",rng,core.randomness.snapshot())
	actors.vital_transition.disconnect(transition_observer)
	core.gates.release(unrelated,"vital-unrelated")
	check("CHAR hold survives unrelated release",true,core.gates.blocked("save"))
	var precommit_request := request("spend","magicka",1,"vital-retire")
	magic.callback = func(): retire("vital-return")
	var precommit := apply(precommit_request)
	magic.callback = Callable()
	check("retirement precommit rejects","stale",precommit.kind)
	check("retired lookup rejected","stale",actors.vital_intake(magic,coherent).kind)
	check("retirement releases CHAR hold",false,core.gates.blocked("save"))
	check("retirement clears controlled remainder hold",false,core.gates._holds.has(consumer_hold))
	# Same application/scope checked checkpoint: no native SAVE or new identity.
	check("checkpoint controlled scope","pending",core.request({"id":"vital-checkpoint","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	original = core.ticket()
	# Cross-scope remapping is intentionally unsupported; qualify rejection.
	check("cross scope checkpoint rejected",false,actors.reconstruct(scope,original,pending,[]).ok)
	check("postcommit actor construction",true,actors.fresh(scope,original,suite.captured("vital-player"),clock,[]).ok)
	core.complete_baseline(original,{"ok":true,"services":services})
	core.complete_readiness(original,{"ok":true,"services":services})
	var postcommit_request := request("spend","magicka",2)
	var retirement_observer := func(_outcome: Dictionary): retire("postcommit-return")
	actors.vital_committed.connect(retirement_observer)
	var postcommit := apply(postcommit_request)
	actors.vital_committed.disconnect(retirement_observer)
	check("retirement after commit retains actual result",[true,102,100,2],[postcommit.ok,postcommit.before,postcommit.after,postcommit.applied])
	check("retired acknowledgment rejected","stale",actors.acknowledge_vital(magic,postcommit_request).kind)
	magic.callback = Callable()
	return {"mutation_1000_usec":mutation_usec,"dense_mutation_1000_usec":dense_mutation_usec,"retained_lookup_2000_usec":lookup_usec,"initial":initial,"pending_record":pending,"source":"controlled intake consumers; real CHAR/CORE/DATA/RULE"}
