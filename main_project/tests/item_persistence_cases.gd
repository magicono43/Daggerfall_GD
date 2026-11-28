extends "res://tests/item_capacity_tender_cases.gd"

var saved := {}
var load_token := -1
var old_scope := ""
var links := RestoreLinks.new()
var original_actor := {}
var original_clock := {}
var retained_request := {}
var retained_record := {}
var pending_request := {}
var durable_references: Array = []
var generation_request := {}
var reentry_result := {}
var exhausted_letter_id := {}

## Compare complete records, but keep reports compact at realistic volume. The
## typed checkpoint remains the reproducible input; hashes cover every field.
func check(id: String, expected: Variant, actual: Variant) -> void:
	if (expected is Dictionary or expected is Array) and (actual is Dictionary or actual is Array):
		super.check(id,JSON.stringify(expected,"",true,true).sha256_text(),JSON.stringify(actual,"",true,true).sha256_text())
	else:
		super.check(id,expected,actual)

class DurableParticipant extends Participant:
	var economic_credits := 0
	var semantic_intakes := 0
	func bindings() -> Array:
		var services: Array = super.bindings()
		services[-1].item_contexts.append({"id":"semantic","custody":"controlled-money-owner","pool":["dfu-item-141"],"worn":false,"copy":false,"collections":{"provider":"controlled.persist-semantic-v1","types":["charged"]}})
		return services
	func collection_intake(v: Dictionary) -> Dictionary:
		if v.context != "semantic": return super.collection_intake(v)
		semantic_intakes += 1
		return {"ok":true,"properties":{"value":7,"weight_microkg":250000,"condition":3,"maximum_condition":3,"material":"","style":"bottled","dye":"blue"}}
	func collection_state(v: Dictionary) -> Dictionary:
		if v.type != "charged": return super.collection_state(v)
		return {"ok":v.record.state.bindings.is_empty(),"kind":"unsupported_binding"}
	func item_capacity_context(v: Dictionary) -> Dictionary:
		var result := super.item_capacity_context(v)
		if v.binding.wagon == "physical-wagon": result.wagon.wagon = "physical-wagon"
		return result
	func money_complete(v: Dictionary) -> Dictionary:
		acknowledge_calls += 1
		if not acknowledgments.has(v.quote.id):
			acknowledgments[v.quote.id] = v.face_debits.duplicate(true)
			economic_credits += int(v.quote.price)+int(v.quote.fees)
		# Model a lost response AFTER the controlled ECON owner committed its fact.
		if fail_ack: return {"ok":false,"kind":"provider_failure"}
		return {"ok":true,"acknowledged":true}

class RestoreLinks:
	extends RefCounted
	var reject := false
	var mutate := Callable()
	var calls := 0
	func item_restore_links(_input: Dictionary) -> Dictionary:
		calls += 1
		if mutate.is_valid(): mutate.call()
		for ref: Dictionary in _input.references:
			if not _input.possessions.any(func(record: Dictionary): return record.id == ref.item and record.custody == ref.custody): return {"ok":false}
		return {"ok":not reject,"clock_ready":true,"references_ready":true,"sources_ready":true}

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller: RefCounted = shell.controller
	check("money provider declared early",true,controller.providers.declare_item_money_provider("controlled.money-v1",["intake-v1","quote-v1","valuation-v1","recovery-v1"]).ok)
	check("duplicate money provider rejects",false,controller.providers.declare_item_money_provider("controlled.money-v1",["intake-v1"]).ok)
	check("persistence semantic provider declared",true,controller.providers.declare_item_collection_semantics("controlled.persist-semantic-v1",["exact-per-unit-v1"]).ok)
	var package := manifest("capacity.tender")
	package.content = ["profiles.json","semantics.json"]
	package.capabilities = ["data."+CT.VERSION,"data.item-collections-v1"]
	var semantics: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/items/collections.json")).entries[0].value.duplicate(true)
	semantics.merge({"eligible":true,"cap":0,"contents":{"payload":"key"},"provider":"controlled.persist-semantic-v1","restrictions":[],"provenance":{"source":"controlled-persistence-semantic"}},true)
	var semantic_entries: Array = [{"id":"charged","value":semantics},{"id":"template-dfu-item-131","value":{"schema":"item-collections-v1","kind":"template","type":"arrow","template":"dfu-item-131","eligible":true,"cap":0,"provenance":{"source":"controlled-persistence-policy"}}}]
	write(controller.mods.root.path_join("Mods/Capacity/semantics.json"),JSON.stringify({"domain":"item.collections","path":"policies","operation":"add","entries":semantic_entries}))
	var additions: Array = [publish_record("odd","denomination",{"unit":"gold","value":3,"nanokg":150000000}),publish_record("controlled-money","money",{"unit":"gold","order":["odd","gold"],"algorithm":"bounded-exact-search-v1","search_limit":100000,"gold_value":7}),publish_record("letter","letter",{"issuer":"wayrest","unit":"gold-face","provider":"controlled.money-v1","nanokg":100000000}),publish_record("sentinel-rate","rate",{"issuer":"wayrest","institution":"shop","region":"sentinel","face_unit":"gold-face","local_unit":"gold","provider":"controlled.money-v1","numerator":1,"denominator":1,"rounding":"exact-lots-v1"}),publish_record("betony-rate","rate",{"issuer":"wayrest","institution":"shop","region":"betony","face_unit":"gold-face","local_unit":"gold","provider":"controlled.money-v1","numerator":1,"denominator":2,"rounding":"exact-lots-v1"}),publish_record("fine","accounting",{"quantum_nanokg":100000,"display_places":4,"rounding":"nearest-even-v1"}),publish_record("physical-access","access",{"algorithm":"physical-reach-v1","distance_mm":5000,"interior":false,"metric":"euclidean-feet-to-exit-anchor-inclusive-v1"})]
	write(controller.mods.root.path_join("Mods/Capacity/mod.json"),JSON.stringify(package))
	additions.append(publish_record("fine-capacity","capacity",{"carried":"char-selected-v1","wagon_kg":2,"accounting":"fine"}))
	additions.append(publish_record("weight-dfu-item-141","weight",{"profile":"dfu-item-141","exempt":false,"nanokg":100000000}))
	write(controller.mods.root.path_join("Mods/Capacity/profiles.json"),JSON.stringify({"domain":CT.DOMAIN,"path":"profiles","operation":"add","entries":additions}))
	controller.mods.rescan()
	if not controller.mods.rows().any(func(row: Dictionary): return row.id == "capacity.tender" and row.enabled): controller.mods.edit("capacity.tender","toggle")
	check("selected capacity replacement staged",true,controller.providers.formulas.stage("capacity.tender","1.0.0",[{"hook":"char.capacity","contract":"actor-rational-v1","callback":callback.capacity}]).ok)
	var invalid_profiles: Array = additions.duplicate(true)
	invalid_profiles[0].value.value = 0
	write(controller.mods.root.path_join("Mods/Capacity/profiles.json"),JSON.stringify({"domain":CT.DOMAIN,"path":"profiles","operation":"add","entries":invalid_profiles}))
	var started := Time.get_ticks_usec()
	controller.select_folder(fixture.classic_source)
	observations.invalid_publication_usec = Time.get_ticks_usec()-started
	check("actual malformed MOD publication rejects",false,controller.prepared_content.ok)
	check("failed candidate publishes no DATA",-1,controller.providers.definitions.content_ticket())
	write(controller.mods.root.path_join("Mods/Capacity/profiles.json"),JSON.stringify({"domain":CT.DOMAIN,"path":"profiles","operation":"add","entries":additions}))
	controller.mods.rescan()
	started = Time.get_ticks_usec()
	# Continue performs the required fresh preparation and publication. Do not
	# prepare an unchanged repaired candidate again merely for a Check button.
	var published: Dictionary = controller.continue_to_menu("run")
	observations.complete_preparation_usec = Time.get_ticks_usec()-started
	check("capacity tender full composition prepares",true,published.ok)
	if not published.ok: return terminal(fixture)
	check("normal DATA publication",true,controller.providers.definitions.active().get("ok",false))
	core = shell.session_shell.core
	core.formulas = controller.providers.formulas
	item_owner = core.items
	controlled = DurableParticipant.new()
	controlled.items = item_owner
	controlled.actors = core.actors
	core.provider = controlled
	core.startup_route_changed("main_menu")
	check("controlled baseline pending","pending",core.request({"id":"capacity-session","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	actor_ticket = core.ticket()
	var capture: Dictionary = preload("res://tests/actor_state_cases.gd").new().captured("player")
	capture.skills.erase("added-skill")
	capture.attributes.strength = 10
	check("real CHAR actor initialized",true,core.actors.fresh(scope,actor_ticket,capture,{"provider":"controlled-clock-v1","unit":"game-millisecond","instant":0},[{"id":"controlled-source","provider":actor_source}]).ok)
	var wounded: Dictionary = core.actors.projection(scope,"player").record
	wounded.current.health = 17
	check("real CHAR nonfull saved pools initialized",true,core.actors.reconstruct(scope,actor_ticket,wounded,[{"id":"controlled-source","provider":actor_source}]).ok)
	core.complete_baseline(core.ticket(),{"ok":true,"services":controlled.bindings()})
	check("real CORE money requester ready",true,core.snapshot().ready)
	if not core.snapshot().ready: return terminal(fixture)
	for id in ["carry","wagon","physical","merchant","stash","volume","semantic"]:
		storage[id] = item_owner.collections.execute(controlled,operation("create",{"name":id},id)).collection.id
	check("late money provider rejects",false,controller.providers.declare_item_money_provider("late.money-v1",["intake-v1"]).ok)
	if fixture.mode.ends_with("_reload"):
		reload_checks(str(fixture.get("restore_from",sandbox.path_join("item-checkpoint.json"))))
	else:
		persistence_checks()
	if DisplayServer.get_name() != "headless": await restore_diagnostic(shell)
	return terminal(fixture)

func snapshot_items(refs: Array = []) -> Dictionary:
	return item_owner.persistence.capture(controlled,scope,durable_references if refs.is_empty() else refs)

func persistence_checks() -> void:
	# Actual operations create all durable facts. No constructor is called to load.
	item_owner._allocator = Allocator.new({"item":"9007199254740992","stack":"18446744073709550000","container":"80"})
	retained_request = {"session":scope,"context":"stash","request":"durable-construction","profile":"dfu-item-131","body":"male-human","category":"neutral","quantity":5}
	retained_record = item_owner.construct(controlled,retained_request).record
	check("construct identity above JSON exact integer range",true,retained_record.id.number.length() >= 16)
	move(retained_record,"stash")
	var equal: Dictionary = item_owner.construct(controlled,retained_request.merged({"request":"second-equal-stack"},true)).record
	move(equal,"stash")
	var equipment_request := req("carry").merged({"profile":"dfu-item-141","body":"male-human","category":"neutral","quantity":1},true)
	var equipped: Dictionary = item_owner.construct(controlled,equipment_request).record
	check("controlled referenced equipment admitted once",true,move(equipped,"carry").ok)
	var linked: Dictionary = live(equipped.id).record
	durable_references = [{"kind":"equipment","owner":"player","slot":"primary","item":linked.id,"custody":linked.custody},{"kind":"equipment","owner":"player","slot":"secondary","item":linked.id,"custody":linked.custody},{"kind":"effect","owner":"controlled-effects","slot":"continuous","item":linked.id,"custody":linked.custody},{"kind":"service","owner":"controlled-service","slot":"reserved","item":linked.id,"custody":linked.custody}]
	var retired: Dictionary = item_owner.construct(controlled,retained_request.merged({"request":"retired-result"},true)).record
	check("retired grant retained",true,item_owner.retire_identity(controlled,req("stash"),retired.id).ok)
	var coins := minted("gold",20,"carry")
	var credit := minted("letter",1,"carry",30)
	var exhausted_credit := minted("letter",1,"stash",7)
	exhausted_letter_id = exhausted_credit.id
	controlled.quote = terms(7,[storage.stash])
	var exhausted_request := req("stash")
	var exhausted_plan: Dictionary = item_owner.money.prepare(controlled,exhausted_request)
	check("actual exhausted letter tender commits",true,item_owner.money.commit(controlled,exhausted_request,exhausted_plan).ok)
	check("actual exhausted letter is retired","missing_or_retired",live(exhausted_letter_id).kind)
	controlled.quote = terms(25)
	pending_request = req()
	var accepted: Dictionary = item_owner.money.prepare(controlled,pending_request)
	check("pending tender fully prepared",true,accepted.ok)
	controlled.fail_ack = true
	check("pending tender commits before technical ECON failure","recovery_required",item_owner.money.commit(controlled,pending_request,accepted).kind)
	check("partial letter identity retained",true,live(credit.id).ok)
	check("partial letter face remains exact",5,live(credit.id).record.money.remaining)
	generation_request = {"session":scope,"context":"construct-only","request":"durable-generation","body":"male-human","level":10}
	check("completed generation retained before capture",true,item_owner.generate(controlled,generation_request).ok)
	minted("gold",200,"carry")
	minted("gold",3,"wagon")
	controlled.modifiers = [{"source":"controlled-load-reduction","kg":-15}]
	controlled.wagon.available = false
	var overweight: Dictionary = load_view()
	check("supported contents become overweight through source change",true,overweight.ok and overweight.load > overweight.capacity)
	var volume_started := Time.get_ticks_usec()
	var volume_ok := true
	for i in 500:
		var request: Dictionary = retained_request.merged({"request":"volume-"+str(i),"quantity":1},true)
		var result: Dictionary = item_owner.construct(controlled,request)
		volume_ok = volume_ok and result.ok
		if result.ok: volume_ok = volume_ok and move(result.record,"volume").ok
	observations.volume_construction_transfer_usec = Time.get_ticks_usec()-volume_started
	check("realistic 500 entry inventory built through owners",true,volume_ok and entries("volume").size() == 500)
	volume_started = Time.get_ticks_usec()
	var queries_ok := true
	for i in 100:
		queries_ok = queries_ok and item_owner.collections.query(controlled,req("volume"),storage.volume,{"profile":"dfu-item-131"}).ok
	observations.query_500_entries_100_usec = Time.get_ticks_usec()-volume_started
	check("realistic volume point queries remain valid",true,queries_ok)
	volume_started = Time.get_ticks_usec()
	var transfers_ok := true
	for i in 10:
		var selected: Dictionary = item_owner.collections.query(controlled,req("volume"),storage.volume,{"profile":"dfu-item-131"}).record
		transfers_ok = transfers_ok and move(selected,"stash").ok and move(live(selected.id).record,"volume").ok
	observations.transfer_500_entries_20_usec = Time.get_ticks_usec()-volume_started
	check("realistic volume transfers conserve entries",true,transfers_ok and entries("volume").size() == 500 and entries("stash").size() == 2)
	volume_started = Time.get_ticks_usec()
	var tenders_ok := true
	for i in 20: tenders_ok = tenders_ok and item_owner.money.prepare(controlled,req()).ok
	observations.tender_prepare_full_composition_20_usec = Time.get_ticks_usec()-volume_started
	check("realistic full composition tender queries remain valid",true,tenders_ok)
	var original_wagon: Dictionary = controlled.wagon.duplicate(true)
	var before_malformed_provider: Dictionary = item_owner._possessions.duplicate(true)
	controlled.wagon.feet_mm = [0,"invalid",0]
	check("malformed wagon provider gates capture",false,snapshot_items().ok)
	check("malformed provider capture preserves ITEM",before_malformed_provider,item_owner._possessions)
	controlled.wagon = original_wagon
	var original_modifiers: Array = controlled.modifiers.duplicate(true)
	controlled.modifiers = [{"source":"controlled-invalid-capacity","kg":30000000000000}]
	check("invalid capacity precision gates capture",false,snapshot_items().ok)
	check("invalid capacity capture preserves ITEM",before_malformed_provider,item_owner._possessions)
	controlled.modifiers = original_modifiers
	volume_started = Time.get_ticks_usec()
	var semantic_state := preload("res://scripts/data/item_collections.gd").ordinary_state()
	semantic_state.contents = {"payload":"mod-reagent"}
	semantic_state.resources = {"charges":4}
	semantic_state.knowledge = {"identified":false}
	semantic_state.provenance = {"source":"controlled-custom"}
	var semantic_grant: Dictionary = item_owner.collections.execute(controlled,operation("intake",{"type":"charged","profile":"dfu-item-141","quantity":3,"state":semantic_state},"semantic"))
	check("custom semantic intake succeeds",true,semantic_grant.ok)
	if not semantic_grant.ok:
		observations.semantic_grant_failure = semantic_grant
		return
	check("custom semantic grant admitted",true,move(semantic_grant.record,"semantic").ok)
	var captured := snapshot_items()
	observations.capture_500_usec = Time.get_ticks_usec()-volume_started
	check("versioned settled capture succeeds",true,captured.ok)
	if not captured.ok:
		observations.capture_failure = captured
		return
	saved = captured.payload
	var detached: Dictionary = saved.duplicate(true)
	detached.possessions[0].quantity = 999
	check("captured possession is detached",false,item_owner._possessions.values()[0].quantity == 999)
	check("distinct equal stacks captured separately",2,saved.possessions.filter(func(r: Dictionary): return r.custody.context == "stash").size())
	check("repeat capture grants nothing",saved,snapshot_items().payload)
	check("all denomination counts remain physical",20,live(coins.id).record.quantity)
	check("retired high water preserved",item_owner.counters().identities,saved.counters)
	check("capture has durable requester keys",true,saved.construction.has("controlled-money-owner:stash:durable-construction"))
	original_actor = core.actors.projection(scope,"player").record
	var hold: int = core.gates.acquire("item-persistence-test",scope,["simulation"])
	original_clock = core.calendar.capture_snapshot().state
	core.gates.release(hold,"item-persistence-test")
	write(sandbox.path_join("item-checkpoint.json"),JSON.stringify({"items":saved,"actor":original_actor,"clock":original_clock,"storage":storage,"construction":retained_request,"record":retained_record,"pending":pending_request,"generation":generation_request,"modifiers":controlled.modifiers,"wagon":controlled.wagon,"exhausted_letter":exhausted_letter_id,"econ_acknowledgments":controlled.acknowledgments,"economic_credits":controlled.economic_credits},"",true,true))
	old_scope = scope
	controlled.hold_preflight = true
	check("real CORE load preflight admitted","pending",core.request({"id":"item-restore","mode":"load","origin":scope}).kind)
	var before: Dictionary = item_owner._possessions.duplicate(true)
	var bad := saved.duplicate(true)
	bad.possessions.append(bad.possessions[0].duplicate(true))
	reject_payload("duplicate possession",bad)
	bad = saved.duplicate(true)
	bad.containers.append(bad.containers[0].duplicate(true))
	reject_payload("duplicate container",bad)
	for number in ["01","-1","18446744073709551616","1e4","0"]:
		bad = saved.duplicate(true)
		bad.possessions[0].id.number = number
		reject_payload("decimal "+number,bad)
	bad = saved.duplicate(true)
	bad.counters.stack = "1"
	reject_payload("counter below retained claims",bad)
	bad = saved.duplicate(true)
	bad.possessions[0].quantity = 0
	reject_payload("invalid quantity",bad)
	bad = saved.duplicate(true)
	bad.possessions[0].erase("body")
	reject_payload("missing required appearance state",bad)
	bad = saved.duplicate(true)
	bad.possessions[0].visual.provider = "missing-appearance-provider"
	reject_payload("corrupt appearance projection",bad)
	bad = saved.duplicate(true)
	bad.possessions[0].material = "missing-material"
	reject_payload("unresolved material reference",bad)
	bad = saved.duplicate(true)
	bad.possessions[0].category = "semantic"
	bad.possessions[0].material = "missing-material"
	bad.possessions[0].erase("visual")
	bad.possessions[0].erase("body")
	reject_payload("constructed record disguised as semantic",bad)
	var semantic_index: int = saved.possessions.find(saved.possessions.filter(func(r: Dictionary): return r.stack_type == "charged")[0])
	for variant in ["kind","identity","appearance","property-range","weight-precision","property-key","policy-kind"]:
		bad = saved.duplicate(true)
		var record: Dictionary = bad.possessions[semantic_index]
		match variant:
			"kind": record.kind = "ammo"
			"identity":
				record.id = exhausted_letter_id.duplicate(true)
				record.identity_category = "item"
			"appearance": record.visual = {}
			"property-range": record.value = 1000000001
			"weight-precision":
				record.weight_nanokg += 1
				record.weight_kg = float(record.weight_nanokg)/1000000000.0
			"property-key": record.style = "invalid key"
			"policy-kind":
				record.kind = "template-dfu-item-131"
				record.stack_type = record.kind
		reject_payload("semantic "+variant,bad)
	bad = saved.duplicate(true)
	bad.schema = "item-state-v0"
	reject_payload("unsupported version",bad)
	bad = saved.duplicate(true)
	bad.compatibility.resources.clear()
	reject_payload("missing compatible provider",bad)
	bad = saved.duplicate(true)
	bad.possessions[0].custody.container = {"category":"container","number":"999"}
	reject_payload("missing custody",bad)
	bad = saved.duplicate(true)
	bad.possessions[0].weight_nanokg = -1
	reject_payload("invalid physical units",bad)
	bad = saved.duplicate(true)
	bad.references = [{"kind":"equipment","owner":"player","slot":"hand","item":retired.id,"custody":retired.custody}]
	reject_payload("missing equipment reference",bad)
	bad = saved.duplicate(true)
	for r: Dictionary in bad.possessions:
		if r.has("money") and r.money.form == "letter": r.money.remaining = 0
	reject_payload("exhausted live letter",bad)
	bad = saved.duplicate(true)
	bad.counters.item = "00"
	reject_payload("noncanonical counter",bad)
	bad = saved.duplicate(true)
	bad.possessions[0].id.category = "container"
	reject_payload("wrong identity category",bad)
	bad = saved.duplicate(true)
	bad.quotes.clear()
	reject_payload("missing committed quote claim",bad)
	bad = saved.duplicate(true)
	for receipt: Dictionary in bad.money.values():
		if receipt.has("recovery"): receipt.outcome.face_debits[0].local += 1
	reject_payload("nonconserving retained settlement",bad)
	bad = saved.duplicate(true)
	for receipt: Dictionary in bad.money.values():
		if receipt.has("recovery"): receipt.outcome.quote.sources = "malformed"
	reject_payload("malformed retained quote envelope",bad)
	bad = saved.duplicate(true)
	for receipt: Dictionary in bad.money.values():
		if receipt.has("recovery"): receipt.outcome.face_debits[0].rate.provenance.source = "unknown-valuation"
	reject_payload("unresolved retained valuation definition",bad)
	bad = saved.duplicate(true)
	bad.generation.values()[0].terminal.clear()
	reject_payload("unsupported pending generation",bad)
	check("all rejected preflights preserve live ITEM",before,item_owner._possessions)
	check("all rejected preflights preserve outgoing scope",old_scope,core.snapshot().session)
	var started := Time.get_ticks_usec()
	var prepared: Dictionary = item_owner.persistence.prepare(controlled,core.ticket(),saved)
	observations.preflight_usec = Time.get_ticks_usec()-started
	check("detached preflight succeeds",true,prepared.ok)
	if not prepared.ok: return
	load_token = prepared.candidate
	check("preflight does not mutate source",saved,captured.payload)
	check("publication outside replacement phase rejects",false,item_owner.persistence.publish(controlled,core.ticket(),load_token,links).ok)
	core.complete_preflight(core.ticket(),{"ok":true,"calendar_state":original_clock})
	check("real CORE replacement requires confirmation","confirmation",core.snapshot().phase)
	core.confirm(core.ticket(),true)
	scope = core.snapshot().session
	check("replacement creates a new scope",true,scope != old_scope)
	original_actor.session = scope
	original_actor.content = item_owner.definitions.content_ticket()
	check("real CHAR reconstruction preserves saved pools",true,core.actors.reconstruct(scope,core.ticket(),original_actor,[{"id":"controlled-source","provider":actor_source}]).ok)
	controlled.hold_readiness = true
	core.complete_baseline(core.ticket(),{"ok":true,"services":controlled.bindings()})
	check("replacement remains gated for ITEM","initializing",core.snapshot().phase)
	check("CORE binds restore requesters before hydration",true,core.bind_item_restore_participants(core.ticket(),controlled.bindings()).ok)
	check("CORE refuses admission before ITEM publication",false,core.complete_readiness(core.ticket(),{"ok":true,"services":controlled.bindings()}))
	var empty_store: Dictionary = item_owner._possessions.duplicate(true)
	links.reject = true
	check("required participant failure prevents ITEM publication",false,item_owner.persistence.publish(controlled,core.ticket(),load_token,links).ok)
	check("failed participant leaves ITEM unchanged",empty_store,item_owner._possessions)
	check("failed candidate cannot be reused",false,item_owner.persistence.publish(controlled,core.ticket(),load_token,links).ok)
	core.complete_readiness(core.ticket(),{"ok":false,"reason":"Controlled required link failure"})
	check("failed load never admits gameplay",false,core.snapshot().ready)
	links.reject = false
	check("retry prepares new exact load",true,retry_load("retry-item-links"))
	links.mutate = func(): reentry_result.merge(item_owner.persistence.publish(controlled,core.ticket(),load_token,links),true)
	started = Time.get_ticks_usec()
	var restored: Dictionary = item_owner.persistence.publish(controlled,core.ticket(),load_token,links)
	observations.hydration_link_rebuild_usec = Time.get_ticks_usec()-started
	check("atomic hydration succeeds",true,restored.ok)
	check("reentrant candidate publication rejects","busy",reentry_result.get("kind"))
	links.mutate = Callable()
	if not restored.ok:
		observations.restore_failure = restored
		return
	check("single use candidate rejects",false,item_owner.persistence.publish(controlled,core.ticket(),load_token,links).ok)
	core.complete_readiness(core.ticket(),{"ok":false,"reason":"Controlled later participant failure after ITEM publication"})
	check("later participant failure retires published ITEM",0,item_owner.counters().possessions)
	check("later participant failure emits no ready session",false,core.snapshot().ready)
	check("retry after published participant cleanup prepares",true,retry_load("retry-later-participant"))
	check("retry after published participant cleanup hydrates",true,item_owner.persistence.publish(controlled,core.ticket(),load_token,links).ok)
	core.complete_readiness(core.ticket(),{"ok":true,"services":controlled.bindings()})
	check("controlled coordinator admits restored participants",true,core.snapshot().ready)
	check("same possession records after restore",saved.possessions,item_owner._possessions.values())
	var semantic_expected: Dictionary = saved.possessions.filter(func(r: Dictionary): return r.stack_type == "charged")[0]
	check("custom semantic state survives hydration",semantic_expected,live(semantic_expected.id).record)
	check("custom semantic hydration does not repeat intake",1,controlled.semantic_intakes)
	check("multiple references preserve single possession",4,saved.references.size())
	check("references linked by controlled participants",true,links.calls >= 3)
	check("same allocator high water after restore",saved.counters,item_owner.counters().identities)
	check("same current vitals without refill",original_actor.current,core.actors.projection(scope,"player").record.current)
	check("stale old scope inspect rejects",false,item_owner.inspect(old_scope,retained_record.id).ok)
	retained_request.session = scope
	var random_before: Dictionary = core.randomness.snapshot()
	check("completed construction retry does not regrant",true,item_owner.construct(controlled,retained_request).ok)
	check("completed construction preserves count",saved.possessions.size(),item_owner.counters().possessions)
	generation_request.session = scope
	check("completed generation retries without reconstruction",true,item_owner.generate(controlled,generation_request).ok)
	check("retired result cannot be regranted","missing_or_retired",item_owner.construct(controlled,retained_request.merged({"request":"retired-result"},true)).kind)
	pending_request.session = scope
	controlled.fail_ack = false
	check("recover only outstanding ECON acknowledgment",true,item_owner.persistence.recover_money(controlled,pending_request).ok)
	var calls: int = controlled.acknowledge_calls
	check("repeat recovery has no repeated acknowledgment",true,item_owner.persistence.recover_money(controlled,pending_request).ok)
	check("acknowledgment delivered once",calls,controlled.acknowledge_calls)
	check("lost ECON response never credits twice",32,controlled.economic_credits)
	var replay := {"session":scope,"context":"carry","request":"attempt-replay-quote"}
	var replay_plan: Dictionary = item_owner.money.prepare(controlled,replay)
	check("new request cannot repeat committed quote","quote_already_committed",item_owner.money.commit(controlled,replay,replay_plan).kind)
	check("no replay of payment or delivery",saved.possessions,item_owner._possessions.values())
	check("restore and retry consume no RNG",random_before,core.randomness.snapshot())
	check("derived carried load rebuilt",true,load_view().ok)
	var rebuilt: Dictionary = load_view()
	check("overweight contents remain overweight after hydration",true,rebuilt.load > rebuilt.capacity)
	check("equipment references and money count physical weight once",300,rebuilt.load)
	check("unavailable wagon is an access error","wagon_unavailable",item_owner.collections.projection(controlled,req("wagon"),storage.wagon).kind)
	check("unavailable wagon retains actual contents",1,item_owner.collections._members[item_owner._id_key(storage.wagon)].size())
	check("separate equal stacks not merged by hydration",2,entries("stash").size())
	var high: String = item_owner._allocator.allocate("stack").id.number
	check("next allocation exceeds restored high water",true,high > saved.counters.stack)
	var exhausted := Allocator.new({"item":Allocator.MAXIMUM})
	check("restored exhausted counter never wraps","identity_exhausted",exhausted.allocate("item").kind)

func retry_load(operation_id: String) -> bool:
	core.startup_route_changed("main_menu")
	core.request({"id":operation_id,"mode":"load","origin":core.snapshot().session})
	var prepared: Dictionary = item_owner.persistence.prepare(controlled,core.ticket(),saved)
	if not prepared.ok: return false
	load_token = prepared.candidate
	core.complete_preflight(core.ticket(),{"ok":true,"calendar_state":original_clock})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)
	scope = core.snapshot().session
	original_actor.session = scope
	original_actor.content = item_owner.definitions.content_ticket()
	var actor: Dictionary = core.actors.reconstruct(scope,core.ticket(),original_actor,[{"id":"controlled-source","provider":actor_source}])
	if not actor.ok: return false
	core.complete_baseline(core.ticket(),{"ok":true,"services":controlled.bindings()})
	return core.snapshot().phase == "initializing" and core.bind_item_restore_participants(core.ticket(),controlled.bindings()).ok

func _numbers(v: Variant) -> Variant:
	if v is Dictionary:
		var result := {}
		for key in v: result[key] = _numbers(v[key])
		return result
	if v is Array:
		var result: Array = []
		for value in v: result.append(_numbers(value))
		return result
	if v is float and v == floor(v) and absf(v) <= Accounting.MAX: return int(v)
	return v

func reload_checks(checkpoint_path: String) -> void:
	var file := FileAccess.open(checkpoint_path,FileAccess.READ)
	check("fresh process bounded checkpoint exists",true,file != null and file.get_length() <= 16777216)
	if file == null: return
	var input: Dictionary = _numbers(JSON.parse_string(file.get_as_text()))
	file.close()
	saved = input.items
	storage = input.storage
	original_actor = input.actor
	original_clock = input.clock
	retained_request = input.construction
	retained_record = input.record
	pending_request = input.pending
	generation_request = input.generation
	controlled.modifiers = input.modifiers
	controlled.wagon = input.wagon
	exhausted_letter_id = input.exhausted_letter
	controlled.acknowledgments = input.econ_acknowledgments
	controlled.economic_credits = input.economic_credits
	controlled.hold_preflight = true
	check("fresh process real CORE load admitted","pending",core.request({"id":"fresh-item-restore","mode":"load","origin":scope}).kind)
	var result: Dictionary = item_owner.persistence.prepare(controlled,core.ticket(),saved)
	check("fresh process content compatible",true,result.ok)
	if not result.ok:
		observations.fresh_preflight_failure = result
		return
	load_token = result.candidate
	core.complete_preflight(core.ticket(),{"ok":true,"calendar_state":original_clock})
	core.confirm(core.ticket(),true)
	scope = core.snapshot().session
	original_actor.session = scope
	original_actor.content = item_owner.definitions.content_ticket()
	check("fresh process real CHAR reconstructed",true,core.actors.reconstruct(scope,core.ticket(),original_actor,[{"id":"controlled-source","provider":actor_source}]).ok)
	controlled.hold_readiness = true
	core.complete_baseline(core.ticket(),{"ok":true,"services":controlled.bindings()})
	check("fresh process CORE binds required ITEM participants",true,core.bind_item_restore_participants(core.ticket(),controlled.bindings()).ok)
	check("fresh process ITEM hydration succeeds",true,item_owner.persistence.publish(controlled,core.ticket(),load_token,links).ok)
	core.complete_readiness(core.ticket(),{"ok":true,"services":controlled.bindings()})
	check("fresh process current requester bound",true,core.snapshot().ready)
	check("fresh process exact possessions",saved.possessions,item_owner._possessions.values())
	var semantic_expected: Dictionary = saved.possessions.filter(func(r: Dictionary): return r.stack_type == "charged")[0]
	check("fresh process custom semantic state retained",semantic_expected,live(semantic_expected.id).record)
	check("fresh process semantic intake not replayed",0,controlled.semantic_intakes)
	check("fresh process retired high water preserved",saved.counters,item_owner.counters().identities)
	check("fresh process distinct stacks preserved",2,entries("stash").size())
	check("fresh process vitals never refilled",original_actor.current,core.actors.projection(scope,"player").record.current)
	retained_request.session = scope
	pending_request.session = scope
	var before: Dictionary = core.randomness.snapshot()
	check("fresh process construction retained",true,item_owner.construct(controlled,retained_request).ok)
	generation_request.session = scope
	check("fresh process generation terminal retained",true,item_owner.generate(controlled,generation_request).ok)
	check("fresh process pending ECON acknowledgment recovers",true,item_owner.persistence.recover_money(controlled,pending_request).ok)
	check("fresh process repeated acknowledgment retained",true,item_owner.persistence.recover_money(controlled,pending_request).ok)
	check("fresh process acknowledgment once",1,controlled.acknowledge_calls)
	check("fresh process lost response never repeats ECON credit",32,controlled.economic_credits)
	controlled.quote = saved.money["controlled-money-owner:carry:"+pending_request.request].outcome.quote.duplicate(true)
	var replay := {"session":scope,"context":"carry","request":"fresh-attempt-replay-quote"}
	var replay_plan: Dictionary = item_owner.money.prepare(controlled,replay)
	check("fresh process committed quote rejects new request","quote_already_committed",item_owner.money.commit(controlled,replay,replay_plan).kind)
	check("fresh process exhausted letter stays retired","missing_or_retired",live(exhausted_letter_id).kind)
	check("fresh process no debit delivery or reissue",saved.possessions,item_owner._possessions.values())
	check("fresh process no RNG replay",before,core.randomness.snapshot())
	check("fresh process load index rebuild",true,load_view().ok)
	check("fresh process overweight storage retained",true,load_view().load > load_view().capacity)
	check("fresh process wagon remains unavailable","wagon_unavailable",item_owner.collections.projection(controlled,req("wagon"),storage.wagon).kind)

func reject_payload(label: String, payload: Dictionary) -> void:
	var before: Dictionary = payload.duplicate(true)
	check("reject "+label,false,item_owner.persistence.prepare(controlled,core.ticket(),payload).ok)
	check("preserve input "+label,before,payload)

func restore_diagnostic(shell: Control) -> void:
	# Let CORE's deferred stock-shell refresh/focus restoration settle first.
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var layer := CanvasLayer.new()
	layer.layer = 100
	shell.add_child(layer)
	var backdrop := ColorRect.new()
	backdrop.color = Color("171e29")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(backdrop)
	var panel := PanelContainer.new()
	panel.position = Vector2(40,40)
	panel.size = Vector2(960,260)
	layer.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var label := Label.new()
	label.text = "ITEM persistence v1 — controlled SAVE / ECON / reference owners\nReal CORE / ITEM / DATA / RULE / CHAR\nRestored scope: %s | possessions: %s\nSeparate stacks preserved. Current vitals retained. No grants/payment replay.\nLive equipment, native SAVE and playable-room acceptance remain open." % [scope,item_owner.counters().possessions]
	box.add_child(label)
	var button := Button.new()
	button.text = "Inspect restored inventory"
	box.add_child(button)
	var detail := Label.new()
	box.add_child(detail)
	button.pressed.connect(func(): detail.text = "Actual restored stash entries: %s | carried load: %s" % [entries("stash").size(),load_view().get("load","unavailable")])
	button.grab_focus()
	await shell.get_tree().process_frame
	check("restore diagnostic focused",true,button.has_focus())
	button.pressed.emit()
	check("restore diagnostic uses owner query",true,detail.text.begins_with("Actual restored stash entries: 2"))
	await capture(shell,"item-persistence")
	check("restore diagnostic focus retained",true,button.has_focus())
