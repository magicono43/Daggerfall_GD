extends "res://tests/item_construction_cases.gd"
const Accounting = preload("res://scripts/item/accounting.gd")
const CT = preload("res://scripts/data/item_capacity_tender.gd")
var core: SessionLifecycle
var controlled: RefCounted
var storage := {}
var sequence := 0
var actor_ticket := {}
var actor_source := preload("res://tests/controlled_actor_source.gd").new()
var callback := CapacityHook.new()

class CapacityHook:
	extends RefCounted
	var invalid := false
	func capacity(v: Dictionary) -> int:
		if invalid: return -1
		if v.value == 2: return 5
		if v.value == 3: return 1500000000
		if v.value == 4: return 1000000000000000
		return preload("res://scripts/rule/actor_formulas.gd").new().capacity(v)

class Participant:
	extends "res://tests/controlled_session_provider.gd"
	var items: RefCounted
	var actors: RefCounted
	var revision := 1
	var spatial_revision := 1
	var monetary_revision := 1
	var modifiers: Array = []
	var quote := {}
	var reject := false
	var bad_admit := false
	var fail_ack := false
	var malformed_quote := false
	var acknowledge_calls := 0
	var acknowledgments := {}
	var mutate := Callable()
	var capacity_mutate := Callable()
	var reentry := Callable()
	var reentry_result := {}
	var wagon := {"owned":true,"available":true,"valid_exit":true,"reach_mm":5000,"feet_mm":[0,0,0],"anchor_mm":[0,0,0],"location_mm":[0,0,0],"wagon":"original-wagon","exit":"original-exit","context_id":"original-dungeon","context":"exterior"}
	func initialize_baseline(_ticket: Dictionary) -> Dictionary: return {"pending":true}
	func bindings() -> Array:
		var contexts: Array = []
		for id in ["carry","wagon","physical","merchant","stash","volume"]:
			var v := {"id":id,"custody":"controlled-money-owner","pool":["dfu-item-131","dfu-item-141"],"worn":true,"copy":true,"collections":{"provider":"builtin.ordinary-v1","types":[]},"money":{"profile":"controlled-money","provider":"controlled.money-v1","coins":["gold","odd"],"letters":["letter"]}}
			if id in ["carry","wagon","physical"]: v.capacity = {"kind":"carried" if id == "carry" else "wagon","actor":"player","profile":"fine-capacity" if id == "physical" else "baseline-capacity","access":"physical-access" if id == "physical" else "baseline-access","wagon":"physical-wagon" if id == "physical" else "original-wagon","exit":"original-exit"}
			contexts.append(v)
		contexts.append({"id":"construct-only","custody":"controlled-money-owner","pool":["dfu-item-131"],"worn":true,"copy":true})
		return [items.service_binding(),actors.service_binding(items._scope if not items._scope.is_empty() else actors._actors.player.record.session),{"role":"controlled-money","owner":"DEV","lifetime":"session","required":true,"ready":true,"provider":self,"item_contexts":contexts}]
	func collection_now() -> int: return 0
	func collection_revision() -> int: return revision
	func collection_intake(_v: Dictionary) -> Dictionary: return {"ok":false,"kind":"unsupported"}
	func collection_state(_v: Dictionary) -> Dictionary: return {"ok":true}
	func collection_admit(_v: Dictionary) -> Dictionary:
		if reentry.is_valid():
			var call := reentry
			reentry = Callable()
			reentry_result = call.call()
		if mutate.is_valid():
			var call := mutate
			mutate = Callable()
			call.call()
		if bad_admit: return {"ok":false}
		return {"ok":false,"kind":"admission_rejected"} if reject else {"ok":true}
	func item_capacity_context(_v: Dictionary) -> Dictionary:
		if capacity_mutate.is_valid():
			var call := capacity_mutate
			capacity_mutate = Callable()
			call.call()
		return {"ok":true,"revision":spatial_revision,"modifiers":modifiers.duplicate(true),"wagon":wagon.duplicate(true)}
	func money_revision() -> int: return monetary_revision
	func money_intake(_v: Dictionary) -> Dictionary: return {"ok":true,"authorized":true}
	func money_quote(_v: Dictionary) -> Dictionary: return {"ok":true} if malformed_quote else {"ok":true,"quote":quote.duplicate(true)}
	func money_complete(v: Dictionary) -> Dictionary:
		acknowledge_calls += 1
		if fail_ack: return {"ok":false,"kind":"provider_failure"}
		acknowledgments[v.quote.id] = v.face_debits.duplicate(true)
		return {"ok":true,"acknowledged":true}

func req(context_id := "carry") -> Dictionary:
	sequence += 1
	return {"session":scope,"context":context_id,"request":"capacity-tender-"+str(sequence)}
func operation(action: String, fields: Dictionary, context_id := "carry") -> Dictionary:
	return req(context_id).merged({"action":action},true).merged(fields,true)
func entries(context_id: String) -> Array:
	return item_owner.collections._records(storage[context_id])
func grant(profile: String, quantity: int, context_id := "stash", face := 0) -> Dictionary:
	var request := req(context_id).merged({"profile":profile,"quantity":quantity},true)
	if face > 0: request.face = face
	return item_owner.money.intake(controlled,request)
func move(record: Dictionary, destination: String, quantity := -1, fitting := false) -> Dictionary:
	return item_owner.collections.execute(controlled,operation("transfer_fitting" if fitting else ("transfer" if record.custody.has("container") else "insert"),{"id":record.id,"quantity":record.quantity if quantity < 0 else quantity,"destination":storage[destination],"mode":"no_stack"},record.custody.context))
func minted(profile: String, quantity: int, destination: String, face := 0) -> Dictionary:
	var record: Dictionary = grant(profile,quantity,destination,face).record
	move(record,destination)
	return item_owner.inspect(scope,record.id).record
func live(id: Dictionary) -> Dictionary:
	return item_owner.inspect(scope,id)
func load_view(context_id := "carry") -> Dictionary:
	return item_owner.capacity.projection(controlled,req(context_id),storage[context_id])
func reconcile() -> Dictionary:
	var actor: Dictionary = core.actors.capacity_projection(scope,"player")
	return core.actors.reconcile(scope,{},"player",actor.revision,actor.content)
func terms(price: int, sources: Array = []) -> Dictionary:
	return {"id":"quote-"+str(sequence),"revision":1,"price":price,"fees":0,"unit":"gold","region":"sentinel","institution":"shop","provider":"controlled.money-v1","coin_offer":0,"tender":"exact","wagon":false,"rates":["sentinel-rate"],"sources":[storage.carry] if sources.is_empty() else sources,"recipient":storage.merchant,"destination":storage.carry,"outputs":[],"change":[]}
func publish_record(id: String, kind: String, fields: Dictionary) -> Dictionary:
	return {"id":id,"value":{"schema":CT.VERSION,"kind":kind,"provenance":{"source":"controlled-increment-3-fixture","license":"project-authored"}}.merged(fields,true)}

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller: RefCounted = shell.controller
	check("money provider declared early",true,controller.providers.declare_item_money_provider("controlled.money-v1",["intake-v1","quote-v1","valuation-v1"]).ok)
	check("duplicate money provider rejects",false,controller.providers.declare_item_money_provider("controlled.money-v1",["intake-v1"]).ok)
	var package := manifest("capacity.tender")
	package.content = ["profiles.json"]
	package.capabilities = ["data."+CT.VERSION]
	var additions: Array = [publish_record("odd","denomination",{"unit":"gold","value":3,"nanokg":150000000}),publish_record("controlled-money","money",{"unit":"gold","order":["odd","gold"],"algorithm":"bounded-exact-search-v1","search_limit":100000,"gold_value":7}),publish_record("letter","letter",{"issuer":"wayrest","unit":"gold-face","provider":"controlled.money-v1","nanokg":100000000}),publish_record("sentinel-rate","rate",{"issuer":"wayrest","institution":"shop","region":"sentinel","face_unit":"gold-face","local_unit":"gold","provider":"controlled.money-v1","numerator":1,"denominator":1,"rounding":"exact-lots-v1"}),publish_record("betony-rate","rate",{"issuer":"wayrest","institution":"shop","region":"betony","face_unit":"gold-face","local_unit":"gold","provider":"controlled.money-v1","numerator":1,"denominator":2,"rounding":"exact-lots-v1"}),publish_record("fine","accounting",{"quantum_nanokg":100000,"display_places":4,"rounding":"nearest-even-v1"}),publish_record("physical-access","access",{"algorithm":"physical-reach-v1","distance_mm":5000,"interior":false,"metric":"euclidean-feet-to-exit-anchor-inclusive-v1"})]
	write(controller.mods.root.path_join("Mods/Capacity/mod.json"),JSON.stringify(package))
	additions.append(publish_record("fine-capacity","capacity",{"carried":"char-selected-v1","wagon_kg":2,"accounting":"fine"}))
	additions.append(publish_record("weight-dfu-item-141","weight",{"profile":"dfu-item-141","exempt":false,"nanokg":100000000}))
	write(controller.mods.root.path_join("Mods/Capacity/profiles.json"),JSON.stringify({"domain":CT.DOMAIN,"path":"profiles","operation":"add","entries":additions}))
	controller.mods.rescan()
	controller.mods.edit("capacity.tender","toggle")
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
	controlled = Participant.new()
	controlled.items = item_owner
	controlled.actors = core.actors
	core.provider = controlled
	core.startup_route_changed("main_menu")
	check("controlled baseline pending","pending",core.request({"id":"capacity-session","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	actor_ticket = core.ticket()
	var capture: Dictionary = preload("res://tests/actor_state_cases.gd").new().captured("player")
	capture.skills.erase("added-skill")
	capture.attributes.strength = 1
	check("real CHAR actor initialized",true,core.actors.fresh(scope,actor_ticket,capture,{"provider":"controlled-clock-v1","unit":"game-millisecond","instant":0},[{"id":"controlled-source","provider":actor_source}]).ok)
	core.complete_baseline(core.ticket(),{"ok":true,"services":controlled.bindings()})
	check("real CORE money requester ready",true,core.snapshot().ready)
	if not core.snapshot().ready: return terminal(fixture)
	for id in ["carry","wagon","physical","merchant","stash","volume"]:
		storage[id] = item_owner.collections.execute(controlled,operation("create",{"name":id},id)).collection.id
	check("late money provider rejects",false,controller.providers.declare_item_money_provider("late.money-v1",["intake-v1"]).ok)
	accounting_checks(additions)
	capacity_checks()
	wagon_checks()
	tender_checks()
	edge_checks()
	performance_checks()
	if DisplayServer.get_name() != "headless": await diagnostic(shell)
	var before_retirement: Dictionary = item_owner._possessions.duplicate(true)
	var before_randomness: Dictionary = core.randomness.snapshot()
	controlled.capacity_mutate = func(): core.required_service_lost(scope,"controlled-capacity-provider")
	check("capacity query rejects scope loss during callback","stale_session",load_view().kind)
	check("stale capacity query preserves possessions",before_retirement,item_owner._possessions)
	check("stale capacity query draws no randomness",before_randomness,core.randomness.snapshot())
	var result := terminal(fixture)
	result.downstream = "Real ITEM/CHAR/CORE/DATA/RULE; controlled ECON, spatial ownership and modifier provider. No native SAVE or live merchant acceptance."
	return result

func accounting_checks(additions: Array) -> void:
	check("exact 0.1 kg baseline",40,Accounting.weight(100000000,2500000).value)
	check("exact 0.15 kg baseline",60,Accounting.weight(150000000,2500000).value)
	var baseline: Dictionary = item_owner.capacity.policy("baseline-accounting","accounting").value
	check("display exact tenth kilogram","0.1000 kg",item_owner.capacity.display_weight(40,baseline).text)
	check("display exact fifteen hundredths kilogram","0.1500 kg",item_owner.capacity.display_weight(60,baseline).text)
	check("display distinguishes individual gold weight","0.0025 kg",item_owner.capacity.display_weight(1,baseline).text)
	check("nearest even down",2,Accounting.round_even(5,2).value)
	check("nearest even up",4,Accounting.round_even(7,2).value)
	check("positive weight cannot disappear","incompatible_precision",Accounting.weight(100000,2500000).kind)
	check("finer profile retains small weight",1,Accounting.weight(100000,100000).value)
	check("genuine zero valid",0,Accounting.weight(0,2500000).value)
	check("negative weight rejects",false,Accounting.weight(-1,2500000).ok)
	check("nonfinite weight rejects",false,Accounting.weight(INF,2500000).ok)
	check("fractional accounting input rejects",false,Accounting.weight(1.5,2500000).ok)
	check("checked addition overflow",false,Accounting.add(Accounting.MAX,1).ok)
	check("checked multiplication overflow",false,Accounting.multiply(Accounting.MAX,2).ok)
	var schema := CT.new()
	for record: Dictionary in additions:
		if record.value.kind in ["rate","letter"]: continue
		check("complete mod schema "+record.id,"",schema.validate_record(record.id,record.value))
	var malformed: Dictionary = additions[0].value.duplicate(true)
	malformed.value = 0
	check("zero denomination value rejects",false,schema.validate_record("bad",malformed).is_empty())
	malformed = additions[3].value.duplicate(true)
	check("undeclared valuation provider rejects",false,schema.validate_record("bad-rate",malformed).is_empty())
	check("actual finer DATA profile",100000,item_owner.capacity.policy("fine","accounting").value.quantum_nanokg)
	check("actual mod denomination value",3,item_owner.capacity.policy("odd","denomination").value.value)
	var construction_request := explicit("mod-weight","clothing")
	construction_request.context = "stash"
	var clothing: Dictionary = item_owner.construct(controlled,construction_request).record
	check("actual MOD weight replacement applies",40,item_owner.capacity.unit_weight(clothing,load_view().accounting).value)
	var equipped := clothing.duplicate(true)
	equipped.state.equipped = true
	check("equipped possession contributes once",40,item_owner.capacity.total_load([equipped],load_view().accounting).value)

func capacity_checks() -> void:
	check("actual CHAR selected capacity kg",1,core.actors.capacity_projection(scope,"player").kg)
	check("baseline capacity accounting",400,load_view().capacity)
	check("baseline wagon capacity",300000,load_view("wagon").capacity)
	var gold: Dictionary = minted("gold",400,"stash")
	check("exact capacity fill succeeds",true,move(gold,"carry").ok)
	check("physical gold counted once",400,load_view().load)
	check("wallet is count projection",{"gold":400},item_owner.money.wallet(controlled,req(),storage.carry).counts)
	var extra: Dictionary = minted("gold",5,"stash")
	check("explicit quantity rejects atomically",false,move(extra,"carry",1).ok)
	check("rejected source unchanged",5,live(extra.id).record.quantity)
	actor_source.contributions = [{"id":"strength-loss","kind":"attribute","target":"strength","value":-1}]
	actor_source.revision += 1
	check("real CHAR strength loss reconciles",true,reconcile().ok)
	check("zero capacity retains overweight load",[0,400],[load_view().capacity,load_view().load])
	var same_request := operation("transfer_fitting",{"id":gold.id,"quantity":400,"destination":storage.carry,"mode":"no_stack"})
	check("same collection fitting is not intake",400,item_owner.collections.maximum_fitting(controlled,same_request).quantity)
	check("same collection fitting retained no op",true,item_owner.collections.execute(controlled,same_request).ok)
	check("overweight split of retained contents allowed",true,item_owner.collections.execute(controlled,operation("split",{"id":gold.id,"quantity":1})).ok)
	check("overweight split cannot compress weight",400,load_view().load)
	check("overweight positive intake denied",false,move(extra,"carry",1).ok)
	var arrow_request := explicit("weightless","ammo")
	arrow_request.context = "stash"
	var arrow: Dictionary = item_owner.construct(controlled,arrow_request).record
	check("verified explicit arrow exemption",0,item_owner.capacity.unit_weight(arrow,load_view().accounting).value)
	check("weightless admission while overweight",true,move(arrow,"carry").ok)
	check("overweight removal permitted",true,move(live(gold.id).record,"stash",300).ok)
	check("removal retains remaining load",100,load_view().load)
	controlled.modifiers = [{"source":"controlled-capacity","kg":1}]
	controlled.spatial_revision += 1
	check("source bonus applied once",400,load_view().capacity)
	check("source rebuild does not duplicate",400,load_view().capacity)
	controlled.modifiers = []
	controlled.spatial_revision += 1
	check("source removal restores zero",0,load_view().capacity)
	actor_source.contributions = []
	actor_source.revision += 1
	check("strength source removal reconciles",true,reconcile().ok)
	var available_request := operation("transfer_fitting",{"id":extra.id,"quantity":99,"destination":storage.carry,"mode":"no_stack"},"stash")
	check("maximum fitting capped by actual availability",5,item_owner.collections.maximum_fitting(controlled,available_request).quantity)
	controlled.mutate = func(): controlled.revision += 1
	check("fitting query revalidates admission revision","stale_admission",item_owner.collections.maximum_fitting(controlled,available_request).kind)
	check("fitting query requires collection authorization","unauthorized",item_owner.collections.maximum_fitting(controlled,req("construct-only").merged({"id":extra.id,"quantity":1,"destination":storage.carry,"mode":"no_stack"},true)).kind)
	var many: Dictionary = minted("gold",500,"stash")
	var fitting_request := operation("transfer_fitting",{"id":many.id,"quantity":500,"destination":storage.carry,"mode":"no_stack"},"stash")
	check("maximum fitting bounded by actual free load",300,item_owner.collections.maximum_fitting(controlled,fitting_request).quantity)
	var fitted: Dictionary = item_owner.collections.execute(controlled,fitting_request)
	check("explicit fitting transfer partial succeeds",[true,300],[fitted.ok,fitted.fitting.quantity])
	check("partial source keeps identity remainder",200,live(many.id).record.quantity)
	check("partial retry retains exact outcome",fitted,item_owner.collections.execute(controlled,fitting_request))
	check("explicit fitting fills exactly",400,load_view().load)
	controlled.reject = true
	check("fitting respects other admission",0,item_owner.collections.maximum_fitting(controlled,fitting_request).quantity)
	controlled.reject = false
	var before: Array = entries("carry")
	controlled.mutate = func(): controlled.spatial_revision += 1
	check("staged capacity revision rejects",false,move(live(gold.id).record,"stash",1).ok)
	check("stale capacity leaves contents",before,entries("carry"))
	controlled.modifiers = [{"source":"duplicate","kg":1},{"source":"duplicate","kg":1}]
	check("duplicate source contribution rejects",false,load_view().ok)
	controlled.modifiers = []
	# Clear carried coins through real transfers, retaining the exempt arrow.
	for r: Dictionary in entries("carry"):
		if r.has("money"): move(r,"stash")

func wagon_checks() -> void:
	controlled.wagon.context = "interior"
	check("ordinary interior denies wagon",false,load_view("wagon").ok)
	controlled.wagon.context = "dungeon"
	controlled.wagon.feet_mm = [3000,4000,0]
	check("inclusive Euclidean five metre boundary",true,load_view("wagon").ok)
	controlled.wagon.feet_mm = [3001,4000,0]
	check("outside five metre boundary denies",false,load_view("wagon").ok)
	controlled.wagon.feet_mm = [0,0,0]
	controlled.wagon.exit = "replacement-exit"
	check("original exit cannot retarget",false,load_view("wagon").ok)
	controlled.wagon.exit = "original-exit"
	controlled.wagon.owned = false
	check("lost cart ownership denies",false,load_view("wagon").ok)
	controlled.wagon.owned = true
	controlled.wagon.context = "exterior"
	var coin: Dictionary = minted("gold",7,"stash")
	check("checked wagon deposit",true,move(coin,"wagon").ok)
	check("wagon weight separate from carry",[7,0],[load_view("wagon").load,load_view().load])
	controlled.wagon.available = false
	check("unavailable wagon not empty projection",false,item_owner.collections.projection(controlled,req("wagon"),storage.wagon).ok)
	controlled.wagon.available = true
	check("contents survive lost access",7,item_owner.money.wallet(controlled,req("wagon"),storage.wagon).counts.gold)
	controlled.mutate = func(): controlled.wagon.owned = false
	check("ownership rechecked after staged callback",false,move(live(coin.id).record,"stash").ok)
	controlled.wagon.owned = true
	check("wagon withdrawal conserves counts",true,move(live(coin.id).record,"stash").ok)
	controlled.wagon.wagon = "physical-wagon"
	controlled.wagon.location_mm = [6000,0,0]
	check("physical wagon reach extension denies",false,load_view("physical").ok)
	controlled.wagon.location_mm = [5000,0,0]
	check("physical wagon equality permits",true,load_view("physical").ok)
	check("actual finer storage and mod capacity",[100000,20000],[load_view("physical").accounting.quantum_nanokg,load_view("physical").capacity])
	controlled.wagon.available = false
	check("unavailable physical provider fails",false,load_view("physical").ok)
	controlled.wagon.available = true
	controlled.wagon.wagon = "original-wagon"

func tender_checks() -> void:
	var coins: Dictionary = minted("gold",10,"carry")
	var letter: Dictionary = minted("letter",1,"carry",20)
	check("credit physical weight independent of face",40,item_owner.capacity.unit_weight(letter,load_view().accounting).value)
	controlled.quote = terms(5)
	var request := req()
	var prepared: Dictionary = item_owner.money.prepare(controlled,request)
	check("coin sufficient avoids letters",[true,[],5],[prepared.ok,prepared.face_debits,prepared.coin_debit])
	var paid: Dictionary = item_owner.money.commit(controlled,request,prepared)
	check("full coin tender commits",true,paid.ok)
	check("letter untouched by coin payment",20,live(letter.id).record.money.remaining)
	check("coin recipient conserves physical count",5,item_owner.money.wallet(controlled,req("merchant"),storage.merchant).counts.gold)
	check("tender retry no repeated debit",paid,item_owner.money.commit(controlled,request,prepared))
	var alternate_request := req()
	check("accepted quote cannot spend under another request","quote_already_committed",item_owner.money.commit(controlled,alternate_request,item_owner.money.prepare(controlled,alternate_request)).kind)
	controlled.quote = terms(12)
	request = req()
	prepared = item_owner.money.prepare(controlled,request)
	check("insufficient coins select credit first",[12,0],[prepared.face_debits[0].face,prepared.coin_debit])
	check("credit spend commits",true,item_owner.money.commit(controlled,request,prepared).ok)
	check("partial letter preserves identity",[letter.id,8],[live(letter.id).record.id,live(letter.id).record.money.remaining])
	controlled.quote = terms(50)
	var before: Array = entries("carry")
	check("insufficient accepted funds reject",false,item_owner.money.prepare(controlled,req()).ok)
	check("insufficient funding preserves actual records",before,entries("carry"))
	controlled.quote = terms(7)
	request = req()
	prepared = item_owner.money.prepare(controlled,request)
	controlled.quote.revision += 1
	check("changed quote needs renewed acceptance","renewed_acceptance_required",item_owner.money.commit(controlled,request,prepared).kind)
	check("changed quote does not debit",before,entries("carry"))
	controlled.quote = terms(8)
	request = req()
	prepared = item_owner.money.prepare(controlled,request)
	check("exhausted letter commits once",true,item_owner.money.commit(controlled,request,prepared).ok)
	check("exhausted instrument retires","missing_or_retired",live(letter.id).kind)
	var second: Dictionary = minted("letter",1,"carry",10)
	controlled.quote = terms(3)
	controlled.quote.region = "betony"
	controlled.quote.rates = ["betony-rate"]
	# Coins still suffice, so use a price above the five carried coins.
	controlled.quote.price = 6
	request = req()
	prepared = item_owner.money.prepare(controlled,request)
	check("regional rate consumes face separately",[10,5,1],[prepared.face_debits[0].face,prepared.face_debits[0].local,prepared.coin_debit])
	check("valuation query leaves face unchanged",10,live(second.id).record.money.remaining)
	controlled.quote.region = "sentinel"
	controlled.quote.rates = ["sentinel-rate"]
	check("travel rate change renews acceptance","renewed_acceptance_required",item_owner.money.commit(controlled,request,prepared).kind)
	controlled.quote.rates = []
	check("unknown rate no one to one fallback",false,item_owner.money.prepare(controlled,req()).ok)
	controlled.quote = terms(6)
	request = req()
	prepared = item_owner.money.prepare(controlled,request)
	controlled.fail_ack = true
	paid = item_owner.money.commit(controlled,request,prepared)
	check("after commit failure retains recovery",[false,true,"recovery_required"],[paid.ok,paid.committed,paid.kind])
	check("committed face retained through acknowledgment failure",4,live(second.id).record.money.remaining)
	controlled.fail_ack = false
	check("recovery acknowledges only outstanding obligation",true,item_owner.money.commit(controlled,request,prepared).ok)
	check("recovery never repeats face debit",4,live(second.id).record.money.remaining)
	controlled.quote = terms(1)
	request = req()
	prepared = item_owner.money.prepare(controlled,request)
	controlled.mutate = func(): controlled.quote.revision += 1
	before = entries("carry")
	check("post callback quote revision rejects",false,item_owner.money.commit(controlled,request,prepared).ok)
	check("post callback rejection preserves funds",before,entries("carry"))
	controlled.quote = terms(1)
	request = req()
	prepared = item_owner.money.prepare(controlled,request)
	controlled.reentry = func(): return item_owner.money.commit(controlled,request,prepared)
	check("outer tender survives rejected reentry",true,item_owner.money.commit(controlled,request,prepared).ok)
	check("nested tender rejected busy","busy",controlled.reentry_result.kind)
	var donor: Dictionary = minted("gold",20,"merchant")
	controlled.quote = terms(2)
	controlled.quote.tender = "change"
	controlled.quote.coin_offer = 3
	controlled.quote.change = [{"id":donor.id,"quantity":1}]
	request = req()
	prepared = item_owner.money.prepare(controlled,request)
	check("real change supply quoted",[true,3,1],[prepared.ok,prepared.coin_debit,prepared.change_value])
	check("change full plan commits",true,item_owner.money.commit(controlled,request,prepared).ok)
	controlled.quote = terms(1)
	controlled.quote.tender = "change"
	controlled.quote.coin_offer = 2
	check("no implicit donation or invented change","change_mismatch",item_owner.money.prepare(controlled,req()).kind)
	controlled.quote = terms(1,[storage.wagon])
	check("wagon funds need explicit permission","wagon_funds_denied",item_owner.money.prepare(controlled,req()).kind)
	var wagon_coin: Dictionary = minted("gold",2,"wagon")
	controlled.quote.wagon = true
	request = req()
	prepared = item_owner.money.prepare(controlled,request)
	check("explicit permitted wagon funds prepare",true,prepared.ok)
	controlled.wagon.owned = false
	check("wagon source access loss blocks accepted tender",false,item_owner.money.commit(controlled,request,prepared).ok)
	controlled.wagon.owned = true
	check("restored access can commit unchanged accepted funds",true,item_owner.money.commit(controlled,request,prepared).ok)
	check("wagon physical debit conserved",1,live(wagon_coin.id).record.quantity)
	controlled.quote.sources = [{"category":"bank","number":"1"}]
	check("bank facts cannot become physical funds",false,item_owner.money.prepare(controlled,req()).ok)
	controlled.quote = terms(1)
	controlled.bad_admit = true
	check("malformed admission fails explicitly","provider_failure",item_owner.money.prepare(controlled,req()).kind)
	controlled.bad_admit = false
	controlled.malformed_quote = true
	check("malformed quote callback rejects","provider_failure",item_owner.money.prepare(controlled,req()).kind)
	controlled.malformed_quote = false
	controlled.quote.price = Accounting.MAX
	controlled.quote.fees = 1
	check("monetary total overflow rejects","overflow",item_owner.money.prepare(controlled,req()).kind)
	check("old session tender rejected","stale_session",item_owner.money.prepare(controlled,{"session":"old","context":"carry","request":"old"}).kind)

func clear_carried_money() -> void:
	for record: Dictionary in entries("carry"):
		if record.has("money"): move(record,"stash")
func edge_checks() -> void:
	clear_carried_money()
	check("explicit gold formula mapping",[21,"gold"],[item_owner.money.gold_formula_amount(controlled,req(),3).value,item_owner.money.gold_formula_amount(controlled,req(),3).unit])
	var intake_request := req("stash").merged({"profile":"gold","quantity":4},true)
	var authorized: Dictionary = item_owner.money.intake(controlled,intake_request)
	check("authorized money intake retry retained",authorized,item_owner.money.intake(controlled,intake_request))
	check("money intake changed request conflicts","request_conflict",item_owner.money.intake(controlled,intake_request.merged({"quantity":5},true)).kind)
	check("money request cannot alias construction","request_conflict",item_owner.construct(controlled,intake_request).kind)
	var coin: Dictionary = minted("odd",3,"carry")
	controlled.quote = terms(2)
	check("explicit denomination subset cannot invent exact tender","exact_tender_unavailable",item_owner.money.prepare(controlled,req()).kind)
	check("equal value denomination keeps own weight",180,load_view().load)
	clear_carried_money()
	var high_water: Dictionary = item_owner._allocator.projection()
	high_water.item = "9007199254740992"
	item_owner._allocator = Allocator.new(high_water)
	var first: Dictionary = minted("letter",1,"carry",3)
	var second: Dictionary = minted("letter",1,"carry",10)
	check("credit IDs preserve full decimal precision",["9007199254740993","9007199254740994"],[first.id.number,second.id.number])
	controlled.quote = terms(4)
	var request := req()
	var prepared: Dictionary = item_owner.money.prepare(controlled,request)
	check("credit selection numeric identity order",[first.id,second.id],[prepared.face_debits[0].id,prepared.face_debits[1].id])
	check("multi letter full funding commits",true,item_owner.money.commit(controlled,request,prepared).ok)
	check("first high letter exhausted once","missing_or_retired",live(first.id).kind)
	check("second high letter retains partial face",9,live(second.id).record.money.remaining)
	check("credit homogeneous consume forbidden","required_money_participant",item_owner.collections.execute(controlled,operation("consume",{"id":second.id,"quantity":1})).kind)
	check("credit copy grant forbidden",false,item_owner.copy_possession(controlled,req(),second.id).ok)
	controlled.quote = terms(1)
	controlled.quote.region = "betony"
	controlled.quote.rates = ["betony-rate"]
	for i in 3:
		controlled.quote.id = "tiny-payment-"+str(i)
		request = req()
		prepared = item_owner.money.prepare(controlled,request)
		check("tiny exact rational lot quote "+str(i),[2,1],[prepared.face_debits[0].face,prepared.face_debits[0].local])
		check("tiny exact rational lot commits "+str(i),true,item_owner.money.commit(controlled,request,prepared).ok)
	check("repeated tiny payments conserve face",3,live(second.id).record.money.remaining)
	controlled.quote.price = 2
	check("fractional residual never creates funding",false,item_owner.money.prepare(controlled,req()).ok)
	clear_carried_money()
	var physical_first: Dictionary = minted("gold",3,"volume")
	var physical_second: Dictionary = grant("gold",2,"volume").record
	check("physical currency merge uses real collection path",true,item_owner.collections.execute(controlled,operation("insert",{"id":physical_second.id,"quantity":2,"destination":storage.volume,"mode":"automatic"},"volume")).ok)
	check("coin merge conserves denomination counts",5,item_owner.money.wallet(controlled,req("volume"),storage.volume).counts.gold)
	check("coin merge retires source once","missing_or_retired",live(physical_second.id).kind)
	move(live(physical_first.id).record,"stash")
	var a: Dictionary = minted("gold",300,"volume")
	var b: Dictionary = minted("gold",200,"volume")
	var batch := operation("batch",{"source":storage.volume,"destination":storage.carry,"mode":"no_stack","batch_mode":"atomic"},"volume")
	check("cumulative batch capacity rejects",false,item_owner.collections.execute(controlled,batch).ok)
	check("atomic batch preserves both source entries",[300,200],entries("volume").map(func(r: Dictionary): return r.quantity))
	batch = operation("batch",{"source":storage.volume,"destination":storage.carry,"mode":"no_stack","batch_mode":"stable_whole_entries_v1"},"volume")
	check("whole entry profile still succeeds partially",true,item_owner.collections.execute(controlled,batch).ok)
	check("whole entry profile never partially takes final entry",[300,200],[load_view().load,entries("volume")[0].quantity])
	clear_carried_money()
	move(live(b.id).record,"stash")
	var massive: Dictionary = minted("gold",500,"carry")
	# An oversized insert above rejects; create a legal fill then reduce capacity.
	if not live(massive.id).record.custody.has("container"): move(massive,"stash")
	var fill: Dictionary = minted("gold",400,"carry")
	actor_source.contributions = [{"id":"loss","kind":"attribute","target":"strength","value":-1}]
	actor_source.revision += 1
	check("compound overweight fixture capacity loss",true,reconcile().ok)
	var incoming: Dictionary = minted("gold",1,"stash")
	var destination: Dictionary = item_owner.collections._containers[item_owner.collections._key(storage.carry)]
	var plan := {}
	var categories: Array = []
	var outgoing: Dictionary = live(fill.id).record
	var removal_request := operation("transfer",{"quantity":400,"mode":"no_stack"})
	item_owner.collections._move_plan(controlled,removal_request,outgoing,item_owner.collections._containers[item_owner.collections._key(storage.stash)],plan,categories)
	item_owner.collections._move_plan(controlled,removal_request.merged({"quantity":1},true),incoming,destination,plan,categories)
	check("overweight net reducing swap still rejects","admission_rejected",item_owner.capacity.validate(controlled,req(),plan).kind)
	controlled.quote = terms(399)
	var supply: Dictionary = entries("merchant").filter(func(r: Dictionary): return r.has("money") and r.money.form == "coin" and r.profile == "gold")[0]
	controlled.quote.outputs = [{"id":supply.id,"quantity":1}]
	check("real tender net reducing intake while overweight rejects","admission_rejected",item_owner.money.prepare(controlled,req()).kind)
	actor_source.contributions = []
	actor_source.revision += 1
	check("compound test restores source coherently",true,reconcile().ok)
	clear_carried_money()
	controlled.modifiers = [{"source":"negative","kg":-2}]
	check("negative effective capacity rejects explicitly","invalid_capacity",load_view().kind)
	controlled.modifiers = []
	# Selected callback failure is checked last: it must preserve the real actor.
	var before_actor: Dictionary = core.actors.capacity_projection(scope,"player")
	callback.invalid = true
	actor_source.contributions = [{"id":"change","kind":"attribute","target":"strength","value":1}]
	actor_source.revision += 1
	check("selected capacity failure has no fallback",false,reconcile().ok)
	check("selected failure preserves previous actor revision",before_actor.revision,core.actors.capacity_projection(scope,"player").revision)
	callback.invalid = false
	actor_source.contributions = [{"id":"change","kind":"attribute","target":"strength","value":1}]
	actor_source.revision += 1
	check("selected formula repair reconciles",true,reconcile().ok)
	check("selected capacity mod changes actual result",5,core.actors.capacity_projection(scope,"player").kg)
	actor_source.contributions = []
	actor_source.revision += 1
	check("selected source removal reconciles",true,reconcile().ok)
	actor_source.contributions = [{"id":"extended-capacity","kind":"attribute","target":"strength","value":2}]
	actor_source.revision += 1
	check("extended selected capacity reconciles",true,reconcile().ok)
	check("capacity projection preserves selected numeric domain",1500000000,core.actors.capacity_projection(scope,"player").kg)
	check("extended capacity checked accounting",600000000000,load_view().capacity)
	actor_source.contributions[0].value = 3
	actor_source.revision += 1
	check("large selected capacity remains CHAR valid",true,reconcile().ok)
	check("actual capacity aggregation overflow rejects","overflow",load_view().kind)
	actor_source.contributions = []
	actor_source.revision += 1
	check("extended source removal reconciles",true,reconcile().ok)

func performance_checks() -> void:
	# Normal full adapter composition and real possessions, no synthetic load cache.
	var started := Time.get_ticks_usec()
	for i in 500: minted("gold",1,"volume")
	observations.inventory_500_insert_usec = Time.get_ticks_usec()-started
	controlled.modifiers = [{"source":"scale-fixture","kg":10}]
	var batch := operation("batch",{"source":storage.volume,"destination":storage.carry,"mode":"no_stack","batch_mode":"atomic"},"volume")
	started = Time.get_ticks_usec()
	check("realistic 500 entry cumulative admission",true,item_owner.collections.execute(controlled,batch).ok)
	observations.inventory_500_batch_usec = Time.get_ticks_usec()-started
	controlled.quote = terms(1)
	started = Time.get_ticks_usec()
	var all_ok := true
	for i in 100: all_ok = item_owner.money.prepare(controlled,req()).ok and all_ok
	observations.tender_100_queries_500_entries_usec = Time.get_ticks_usec()-started
	check("repeated realistic tender queries succeed",true,all_ok)
	check("queries preserve physical counts",500,item_owner.money.wallet(controlled,req(),storage.carry).counts.gold)
	controlled.quote = terms(500)
	started = Time.get_ticks_usec()
	var full: Dictionary = item_owner.money.prepare(controlled,req())
	observations.tender_full_500_prepare_usec = Time.get_ticks_usec()-started
	check("full realistic tender prepares every debit",[true,500],[full.ok,full.coin_debit])

func diagnostic(shell: Control) -> void:
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var layer := CanvasLayer.new()
	layer.layer = 100
	shell.add_child(layer)
	var backdrop := ColorRect.new()
	backdrop.color = Color("171e29")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(backdrop)
	var box := VBoxContainer.new()
	box.position = Vector2(45,45)
	box.size = Vector2(860,500)
	backdrop.add_child(box)
	var label := Label.new()
	label.text = "IMP-017 Capacity / Tender — controlled ECON and wagon context\nReal ITEM / CHAR / CORE / DATA / RULE"
	box.add_child(label)
	controlled.quote = terms(1)
	var request := req()
	var prepared: Dictionary = item_owner.money.prepare(controlled,request)
	var detail := Label.new()
	detail.text = "Price %s %s | fees %s | coins %s | change %s\nRecipient %s | region %s | quote revision %s\nLoad %s / %s accounting units (2.5 g)" % [prepared.quote.price,prepared.quote.unit,prepared.quote.fees,prepared.coin_debit,prepared.change_value,str(prepared.quote.recipient),prepared.quote.region,prepared.quote.revision,load_view().load,load_view().capacity]
	detail.text += "\nFace debits / local credits / rates: "+JSON.stringify(prepared.face_debits)+"\nSources: "+JSON.stringify(prepared.quote.sources)+"\nDestination: "+JSON.stringify(prepared.quote.destination)+"\nGoods: "+JSON.stringify(prepared.quote.outputs)+" | supplied change: "+JSON.stringify(prepared.quote.change)
	detail.text += "\nExact load: "+item_owner.capacity.display_weight(load_view().load,load_view().accounting).text+" / "+item_owner.capacity.display_weight(load_view().capacity,load_view().accounting).text
	box.add_child(detail)
	var button := Button.new()
	button.text = "Confirm accepted ITEM tender"
	box.add_child(button)
	var result_label := Label.new()
	box.add_child(result_label)
	var outcome := {}
	button.pressed.connect(func():
		var committed: Dictionary = item_owner.money.commit(controlled,request,prepared)
		outcome.merge(committed,true)
		result_label.text = "Committed: %s | outstanding ECON obligations: %s\nCarried counts: %s" % [committed.get("committed",false),str(committed.get("obligations",[])),str(item_owner.money.wallet(controlled,req(),storage.carry).counts)])
	button.grab_focus()
	await shell.get_tree().process_frame
	check("diagnostic confirmation focused",true,button.has_focus())
	button.pressed.emit()
	check("diagnostic uses actual tender commitment",true,outcome.get("committed",false))
	check("diagnostic shows actual committed result",true,result_label.text.contains("Committed: true"))
	await capture(shell,"item-capacity-tender")
	check("diagnostic focus retained",true,button.has_focus())
