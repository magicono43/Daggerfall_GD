extends "res://tests/item_construction_cases.gd"
const CollectionsPolicy = preload("res://scripts/data/item_collections.gd")
var collections: RefCounted
var provider: RefCounted
var a: Dictionary
var b: Dictionary
var sequence := 0

class CollectionRequester:
	extends "res://tests/controlled_session_provider.gd"
	var items: RefCounted
	var now := 1000
	var entry_limit := 10000
	var reject_name := ""
	var fail_after := -1
	var admissions := 0
	var reenter := false
	var reentry_result := {}
	var reentry_request := {}
	var expire_on_admit := false
	var revision := 1
	var change_revision := false
	var bad_properties := false
	var malformed_after := -1
	func bindings() -> Array:
		var contexts := []
		for id in ["ammo","weapon"]:
			contexts.append({"id":id,"custody":"collections-inspection","pool":["dfu-item-131","dfu-item-141"] if id == "ammo" else ["dfu-item-113","dfu-item-114"],"worn":true,"copy":true,"collections":{"provider":"controlled.semantic-v1","types":["charged","arrow","tagged"]}})
		return [items.service_binding(),{"role":"collections-requester","owner":"DEV","lifetime":"session","required":true,"ready":true,"provider":self,"item_contexts":contexts}]
	func collection_now() -> int: return now
	func collection_revision() -> int: return revision
	func collection_intake(_request: Dictionary) -> Dictionary:
		return {"ok":true,"properties":{} if bad_properties else {"value":7,"weight_microkg":250000,"condition":3,"maximum_condition":3,"material":"","style":"bottled","dye":"blue"}}
	func collection_state(v: Dictionary) -> Dictionary:
		return {"ok":v.type in ["charged","arrow","tagged"] and v.record.state.bindings.is_empty(),"kind":"unsupported_binding"}
	func collection_admit(v: Dictionary) -> Dictionary:
		admissions += 1
		if malformed_after >= 0 and admissions >= malformed_after: return {"ok":false}
		if reenter:
			reenter = false
			reentry_result = items.collections.execute(self,reentry_request)
		if expire_on_admit: now = 100000
		if change_revision:
			change_revision = false
			revision += 1
		if fail_after >= 0 and admissions >= fail_after: return {"ok":false,"kind":"provider_failure"}
		if v.collection.name == reject_name or v.after.size() > entry_limit: return {"ok":false,"kind":"admission_rejected"}
		return {"ok":true}

class EligibilityReplacement:
	extends RefCounted
	var calls := 0
	var invalid := false
	func eligible(v: Dictionary) -> int:
		calls += 1
		if invalid: return 2
		return preload("res://scripts/rule/item_formulas.gd").new().eligible(v)

func op(action: String, fields: Dictionary = {}, context_id := "ammo") -> Dictionary:
	sequence += 1
	return {"session":scope,"context":context_id,"request":"collection-"+str(sequence),"action":action}.merged(fields,true)
func make(quantity: int, context_id := "ammo") -> Dictionary:
	sequence += 1
	var r := explicit("possession-"+str(sequence),context_id)
	r.quantity = quantity
	return item_owner.construct(provider,r)
func insert(id: Dictionary, quantity: int, destination: Dictionary, mode := "automatic", context_id := "ammo") -> Dictionary:
	return collections.execute(provider,op("insert",{"id":id,"quantity":quantity,"destination":destination,"mode":mode},context_id))
func entries(container: Dictionary) -> Array:
	return collections.projection(provider,{"session":scope,"context":"ammo"},container).entries
func count(container: Dictionary) -> int:
	var total := 0
	for r: Dictionary in entries(container): total += r.quantity
	return total
func amounts(container: Dictionary) -> Array:
	return entries(container).map(func(r: Dictionary): return r.quantity)
func snapshot() -> Dictionary:
	return {"a":entries(a),"b":entries(b),"counters":item_owner.counters(),"randomness":item_owner._core.get_ref().randomness.snapshot()}
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller = shell.controller
	var mods: RefCounted = controller.mods
	check("semantic provider declared before preparation",true,controller.providers.declare_item_collection_semantics("controlled.semantic-v1",["exact-per-unit-v1","set-content-v1"]).ok)
	check("duplicate semantic provider declaration rejects","invalid_provider",controller.providers.declare_item_collection_semantics("controlled.semantic-v1",["exact-per-unit-v1"]).kind)
	var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/items/collections.json"))
	var extension: Dictionary = original.entries[0].value.duplicate(true)
	extension.eligible = true
	extension.contents = {"payload":"key"}
	extension.provider = "controlled.semantic-v1"
	extension.restrictions = ["quest","enchanted","summoned"]
	extension.cap = 0
	var tagged := extension.duplicate(true)
	tagged.contents = {"tags":"key-set"}
	tagged.state_rule = "set-content-v1"
	var package := manifest("collections.test")
	package.content = ["policy.json"]
	package.capabilities = ["data."+CollectionsPolicy.VERSION]
	write(mods.root.path_join("Mods/collections/mod.json"),JSON.stringify(package))
	write(mods.root.path_join("Mods/collections/policy.json"),JSON.stringify({"domain":CollectionsPolicy.DOMAIN,"path":"policies","operation":"add","entries":[{"id":"charged","value":extension},{"id":"tagged","value":tagged},{"id":"template-dfu-item-131","value":{"schema":CollectionsPolicy.VERSION,"kind":"template","type":"arrow","template":"dfu-item-131","eligible":true,"cap":5,"provenance":{"source":"controlled-template-policy"}}},{"id":"template-dfu-item-114","value":{"schema":CollectionsPolicy.VERSION,"kind":"template","type":"weapon","template":"dfu-item-114","eligible":false,"cap":0,"provenance":{"source":"controlled-template-deny"}}}]}))
	write(mods.root.path_join("Overrides/collections.json"),JSON.stringify({"domain":CollectionsPolicy.DOMAIN,"path":"policies","operation":"patch","entries":[{"id":"arrow","value":{"cap":17,"eligible":false,"provider":"controlled.semantic-v1"}},{"id":"weapon","value":{"eligible":true}}]}))
	mods.rescan()
	mods.edit("collections.test","toggle")
	var replacement := EligibilityReplacement.new()
	check("collection RULE replacement stages",true,controller.providers.formulas.stage("collections.test","1.0.0",[{"hook":"item.eligible","contract":ItemFormula.CONTRACT,"callback":replacement.eligible}]).ok)
	var started := Time.get_ticks_usec()
	controller.select_folder(fixture.classic_source)
	observations.complete_preparation_usec = Time.get_ticks_usec()-started
	check("full composition prepares",true,controller.providers.definitions.projection().get("ok",false))
	# Continue performs its required fresh preparation; no redundant Check first.
	check("actual menu publishes",true,controller.continue_to_menu("run").ok)
	check("late semantic provider declaration rejects","registration_closed",controller.providers.declare_item_collection_semantics("late-provider-v1",["exact-per-unit-v1"]).kind)
	var core: SessionLifecycle = shell.session_shell.core
	core.formulas = controller.providers.formulas
	item_owner = core.items
	collections = item_owner.collections
	provider = CollectionRequester.new()
	provider.items = item_owner
	core.provider = provider
	core.startup_route_changed("main_menu")
	check("real CORE requester entry","Succeeded",core.request({"id":"collections-session","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	if not core.snapshot().ready: return terminal(fixture)
	check("no implicit collection grant",0,item_owner.counters().possessions)
	a = collections.execute(provider,op("create",{"name":"left"})).collection.id
	b = collections.execute(provider,op("create",{"name":"right"})).collection.id
	check("typed increasing container identities",[{"category":"container","number":"1"},{"category":"container","number":"2"}],[a,b])
	check("duplicate container claim rejects","duplicate_collection",collections.execute(provider,op("create",{"name":"left"})).kind)
	policy_checks(original,extension)
	var source: Dictionary = make(12).record
	var original_id: Dictionary = source.id.duplicate()
	var request := op("insert",{"id":source.id,"quantity":12,"destination":a,"mode":"automatic"})
	var inserted: Dictionary = collections.execute(provider,request)
	check("capped automatic inserts complete plan",[true,[5,5,2],12],[inserted.ok,amounts(a),count(a)])
	check("first entry retains full incoming identity",original_id,entries(a)[0].id)
	check("capped plan reports fresh identities",2,inserted.changes.filter(func(c: Dictionary): return c.status == "new").size())
	check("exact insertion retry retained",inserted,collections.execute(provider,request))
	check("retry cannot multiply counts",12,count(a))
	check("conflicting request rejects","request_conflict",collections.execute(provider,request.merged({"quantity":1},true)).kind)
	check("same collection no duplicate",[true,12],[insert(original_id,5,a).ok,count(a)])
	var original_request := explicit("possession-4","ammo")
	original_request.quantity = 12
	check("retained construction retry after admission",original_id,item_owner.construct(provider,original_request).record.id)
	var before := snapshot()
	for bad: Variant in [0,-1,1.5,2147483648]:
		check("invalid quantity "+str(bad),false,collections.execute(provider,op("split",{"id":original_id,"quantity":bad})).ok)
	check("invalid amounts preserve state",before,snapshot())
	var full: Dictionary = collections.execute(provider,op("split",{"id":original_id,"quantity":5}))
	check("full split returns original unchanged",["unchanged",original_id,5],[full.kind,full.record.id,full.record.quantity])
	var split: Dictionary = collections.execute(provider,op("split",{"id":original_id,"quantity":2}))
	check("partial split separate and conserved",[true,[3,5,2,2],12],[split.ok,amounts(a),count(a)])
	var new_id: Dictionary = split.changes.filter(func(c: Dictionary): return c.status == "new")[0].id
	check("original references stay with remainder",3,item_owner.inspect(scope,original_id).record.quantity)
	var detached: Dictionary = item_owner.inspect(scope,new_id).record
	detached.state.knowledge["identified"] = true
	check("split projections do not alias",{},item_owner.inspect(scope,original_id).record.state.knowledge)
	var transfer := op("transfer",{"id":new_id,"quantity":2,"destination":b,"mode":"automatic"})
	var moved: Dictionary = collections.execute(provider,transfer)
	check("full transfer preserves identity",[true,new_id,10,2],[moved.ok,entries(b)[0].id,count(a),count(b)])
	check("transfer retry returns retained fact",moved,collections.execute(provider,transfer))
	before = snapshot()
	check("valid same collection no-op","same_collection",collections.execute(provider,op("transfer",{"id":new_id,"quantity":1,"destination":b,"mode":"automatic"})).kind)
	check("same collection preserves all state",before,snapshot())
	var extra: Dictionary = make(2).record
	var merge: Dictionary = insert(extra.id,2,b)
	check("merge retains destination",[4,new_id],[entries(b)[0].quantity,entries(b)[0].id])
	check("fully merged source retires",["retired","missing_or_retired"],[merge.changes.filter(func(c: Dictionary): return c.id == extra.id)[0].status,item_owner.inspect(scope,extra.id).kind])
	check("retired source never aliases survivor","missing_or_retired",collections.execute(provider,op("transfer",{"id":extra.id,"quantity":1,"destination":a,"mode":"automatic"})).kind)
	var incoming: Dictionary = make(4).record
	before = snapshot()
	var targeted: Dictionary = collections.execute(provider,op("insert",{"id":incoming.id,"quantity":4,"destination":b,"mode":"target","target":new_id}))
	check("explicit target all or reject","cap_exceeded",targeted.kind)
	check("target rejection preserves both ends",before,snapshot())
	provider.reject_name = "right"
	check("later admission rejects whole capped plan","admission_rejected",insert(incoming.id,4,b).kind)
	check("tentative fill never published",before,snapshot())
	provider.reject_name = ""
	check("no stack respects caps",true,insert(incoming.id,4,b,"no_stack").ok)
	check("no stack preserves separation",[4,4],amounts(b))
	var consumed_request := op("consume",{"id":incoming.id,"quantity":1})
	var consumed: Dictionary = collections.execute(provider,consumed_request)
	check("one unit consumption only",[true,3],[consumed.ok,item_owner.inspect(scope,incoming.id).record.quantity])
	check("consumption retry retained",consumed,collections.execute(provider,consumed_request))
	check("retry consumes once",3,item_owner.inspect(scope,incoming.id).record.quantity)
	for i in 3: collections.execute(provider,op("consume",{"id":incoming.id,"quantity":1}))
	check("last unit retires no zero stack","missing_or_retired",item_owner.inspect(scope,incoming.id).kind)
	check("no zero live entries",true,entries(b).all(func(r: Dictionary): return r.quantity > 0))
	var partial_move: Dictionary = collections.execute(provider,op("transfer",{"id":original_id,"quantity":1,"destination":b,"mode":"no_stack"}))
	check("partial transfer preserves original remainder",[true,2],[partial_move.ok,item_owner.inspect(scope,original_id).record.quantity])
	check("partial transfer reports fresh entry",1,partial_move.changes.filter(func(c: Dictionary): return c.status == "new").size())
	provider.reenter = true
	provider.reentry_request = op("consume",{"id":original_id,"quantity":1})
	check("outer split survives rejected reentry",true,collections.execute(provider,op("split",{"id":original_id,"quantity":1})).ok)
	check("provider reentry cannot mutate","busy",provider.reentry_result.kind)
	before = snapshot()
	provider.entry_limit = 0
	check("standalone split capacity failure unchanged","admission_rejected",collections.execute(provider,op("split",{"id":entries(a)[1].id,"quantity":1})).kind)
	check("failed split preserves custody and counts",before,snapshot())
	provider.entry_limit = 10000
	low_numeric_order_checks()
	batch_checks()
	semantic_checks()
	construction_checks()
	summoned_checks()
	compatibility_override_checks()
	identity_plan_checks()
	query_checks()
	boundary_checks(controller)
	high_numeric_order_checks()
	started = Time.get_ticks_usec()
	var measure: Dictionary = collections.execute(provider,op("create",{"name":"measurement"})).collection.id
	for i in 500:
		var made: Dictionary = make(1).record
		insert(made.id,1,measure,"no_stack")
	observations.collection_500_insert_usec = Time.get_ticks_usec()-started
	started = Time.get_ticks_usec()
	for i in 100: collections.query(provider,{"session":scope,"context":"ammo"},measure,{"type":"arrow"})
	observations.collection_500_query_100_usec = Time.get_ticks_usec()-started
	check("realistic collection inventory",500,entries(measure).size())
	check("actual selected eligibility provider used",true,replacement.calls > 500)
	observations.eligibility_calls = replacement.calls
	observations.preparation = controller.providers.definitions.timings.duplicate(true)
	if DisplayServer.get_name() != "headless": await rendered_checks(shell)
	exhaustion_checks()
	var before_provider_failure: Dictionary = item_owner.counters()
	replacement.invalid = true
	check("selected eligibility failure no fallback","invalid_result",collections.eligibility(provider,{"session":scope,"context":"ammo"},entries(a)[0].id).kind)
	check("eligibility failure changes no possessions",before_provider_failure,item_owner.counters())
	check("eligibility provider failure enters CORE recovery",false,core.snapshot().ready)
	var old_scope := scope
	core.request({"id":"end-collections","mode":"return","origin":scope})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)
	check("old session mutation rejects","stale_session",collections.execute(provider,request).kind)
	check("old session query rejects","stale_session",collections.query(provider,{"session":old_scope,"context":"ammo"},a,{}).kind)
	check("retirement clears possessions",0,item_owner.counters().possessions)
	return terminal(fixture)

func policy_checks(original: Dictionary, extension: Dictionary) -> void:
	var adapter := CollectionsPolicy.new()
	adapter.declare_provider("controlled.semantic-v1",["exact-per-unit-v1","set-content-v1"])
	for entry: Dictionary in original.entries:
		check("valid default "+entry.id,"",adapter.validate_record(entry.id,entry.value))
		check("default eligibility "+entry.id,entry.id in ["ingredient","potion","book","gold","arrow","oil"],entry.value.eligible)
	var bad := extension.duplicate(true)
	bad.representation = "stack-wide-charges"
	check("finite stack-wide pool rejects",false,adapter.validate_record("bad",bad).is_empty())
	bad = extension.duplicate(true)
	bad.restrictions = ["quest","quest"]
	check("conflicting restriction declarations reject",false,adapter.validate_record("bad",bad).is_empty())
	bad = extension.duplicate(true)
	bad.provider = "builtin.ordinary-v1"
	check("unsafe blanket override rejects",false,adapter.validate_record("bad",bad).is_empty())
	bad = extension.duplicate(true)
	bad.cap = -1
	check("negative cap rejects",false,adapter.validate_record("bad",bad).is_empty())
	bad = extension.duplicate(true)
	bad.provider = "unregistered.provider-v1"
	check("unavailable semantic provider fails publication validation",false,adapter.validate_record("bad",bad).is_empty())
	check("complete supported extension validates","",adapter.validate_record("charged",extension))
	var builtin := ItemFormula.new()
	for flag in ["none","quest","enchanted","equipped","summoned_nonarrow"]:
		var state := {"quest":false,"enchanted":false,"equipped":false,"summoned_nonarrow":false}
		if flag != "none": state[flag] = true
		check("instance restriction "+flag,1 if flag == "none" else 0,builtin.eligible({"default":true,"template":null,"restrictions":[],"state":state}))
	check("template deny is meaningful",0,builtin.eligible({"default":true,"template":false,"restrictions":[],"state":{"quest":false,"enchanted":false,"equipped":false,"summoned_nonarrow":false}}))
	check("template allow is meaningful",1,builtin.eligible({"default":false,"template":true,"restrictions":[],"state":{"quest":false,"enchanted":false,"equipped":false,"summoned_nonarrow":false}}))

func batch_checks() -> void:
	var before := snapshot()
	provider.reject_name = "right"
	check("atomic batch late admission rejects","admission_rejected",collections.execute(provider,op("batch",{"source":a,"destination":b,"batch_mode":"atomic","mode":"automatic"})).kind)
	check("atomic rejection preserves both collections",before,snapshot())
	provider.reject_name = ""
	var total := count(a)+count(b)
	var batch: Dictionary = collections.execute(provider,op("batch",{"source":a,"destination":b,"batch_mode":"atomic","mode":"automatic"}))
	check("atomic batch complete",[true,0,total],[batch.ok,count(a),count(b)])
	for i in 3:
		var r: Dictionary = make(1).record
		insert(r.id,1,a,"no_stack")
	provider.entry_limit = entries(b).size()+1
	var request := op("batch",{"source":a,"destination":b,"batch_mode":"stable_whole_entries_v1","mode":"no_stack"})
	var partial: Dictionary = collections.execute(provider,request)
	check("explicit partial whole-entry profile",["partial_batch",1,2],[partial.kind,partial.moved.size(),partial.remaining.size()])
	check("partial retry retains completed moves",partial,collections.execute(provider,request))
	provider.entry_limit = 10000
	provider.admissions = 0
	provider.fail_after = 3
	request = op("batch",{"source":a,"destination":b,"batch_mode":"stable_whole_entries_v1","mode":"no_stack"})
	var interrupted: Dictionary = collections.execute(provider,request)
	check("partial technical boundary retains first move",["recovery_required",1,1],[interrupted.kind,interrupted.moved.size(),count(a)])
	check("technical retry cannot replay completed move",interrupted,collections.execute(provider,request))
	provider.fail_after = -1
	check("outstanding entry recoverable via new explicit request",true,collections.execute(provider,op("batch",{"source":a,"destination":b,"batch_mode":"atomic","mode":"no_stack"})).ok)
	for i in 2:
		var source: Dictionary = make(1).record
		insert(source.id,1,a,"no_stack")
	provider.admissions = 0
	provider.malformed_after = 3
	var malformed_request := op("batch",{"source":a,"destination":b,"batch_mode":"stable_whole_entries_v1","mode":"no_stack"})
	var malformed_result: Dictionary = collections.execute(provider,malformed_request)
	check("malformed negative provider response stops technically",["recovery_required","provider_failure",1,1],[malformed_result.kind,malformed_result.failure.kind,malformed_result.moved.size(),count(a)])
	check("malformed provider retry preserves completed facts",malformed_result,collections.execute(provider,malformed_request))
	provider.malformed_after = -1
	check("malformed provider recovery moves outstanding only",true,collections.execute(provider,op("batch",{"source":a,"destination":b,"batch_mode":"atomic","mode":"no_stack"})).ok)

func semantic_checks() -> void:
	var state := CollectionsPolicy.ordinary_state()
	state.contents = {"payload":"charged-payload"}
	state.resources = {"charges":3}
	state.knowledge = {"identified":false}
	state.provenance = {"origin":"controlled-owner"}
	state.enchanted = true
	state.quest = true
	var intake := op("intake",{"type":"charged","profile":"dfu-item-141","quantity":6,"state":state})
	var made: Dictionary = collections.execute(provider,intake)
	check("complete semantic extension intake",true,made.ok)
	if not made.ok: return
	check("intake retry no duplicate grant",made,collections.execute(provider,intake))
	var id: Dictionary = made.record.id
	check("special per-unit extension inserts",true,insert(id,6,a).ok)
	var split: Dictionary = collections.execute(provider,op("split",{"id":id,"quantity":2}))
	check("special split qualified",true,split.ok)
	var other: Dictionary = split.changes.filter(func(c: Dictionary): return c.status == "new")[0].id
	check("per unit finite charges conserved",[4,2,3,3],[item_owner.inspect(scope,id).record.quantity,item_owner.inspect(scope,other).record.quantity,item_owner.inspect(scope,id).record.state.resources.charges,item_owner.inspect(scope,other).record.state.resources.charges])
	var altered := state.duplicate(true)
	for field in ["contents","knowledge","resources","provenance"]:
		altered = state.duplicate(true)
		match field:
			"contents": altered.contents.payload = "different"
			"knowledge": altered.knowledge.identified = true
			"resources": altered.resources.charges = 2
			"provenance": altered.provenance.origin = "different"
		var distinct: Dictionary = collections.execute(provider,op("intake",{"type":"charged","profile":"dfu-item-141","quantity":1,"state":altered})).record
		var before := entries(a).size()
		insert(distinct.id,1,a)
		check("state distinction "+field,before+1,entries(a).size())
	var malformed := state.duplicate(true)
	malformed.resources = {"stack_pool":{"total":3}}
	check("stack-wide resources fail without loss","unsupported_state",collections.execute(provider,op("intake",{"type":"charged","profile":"dfu-item-141","quantity":2,"state":malformed})).kind)
	malformed = state.duplicate(true)
	malformed.bindings = {"quest":"required-live-owner"}
	check("missing binding owner fails","unsupported_binding",collections.execute(provider,op("intake",{"type":"charged","profile":"dfu-item-141","quantity":1,"state":malformed})).kind)
	malformed = state.duplicate(true)
	malformed.erase("contents")
	check("missing special state never ordinary","unsupported_state",collections.execute(provider,op("intake",{"type":"charged","profile":"dfu-item-141","quantity":1,"state":malformed})).kind)

func construction_checks() -> void:
	var weapon: Dictionary = make(3,"weapon").record
	check("mod equipment quantity supported without retyping",["item",3],[weapon.id.category,weapon.quantity])
	check("uncapped construction inserts",true,insert(weapon.id,3,a,"automatic","weapon").ok)
	var extra: Dictionary = make(2,"weapon").record
	check("uncapped equipment merge",true,insert(extra.id,2,a,"automatic","weapon").ok)
	check("equipment stable item category survives",["item",5],[item_owner.inspect(scope,weapon.id).record.id.category,item_owner.inspect(scope,weapon.id).record.quantity])
	check("admitted appearance modification",true,item_owner.modify(provider,{"session":scope,"context":"ammo"},weapon.id,{}).ok)
	# Custody context is destination context after transfer/admission.
	check("obsolete initial context denied","unauthorized",item_owner.modify(provider,{"session":scope,"context":"weapon"},weapon.id,{}).kind)
	check("recalculation uses current custody not grant pool",true,item_owner.recalculate(provider,{"session":scope,"context":"ammo"},weapon.id).ok)
	check("admitted copy requires current pool",false,item_owner.copy_possession(provider,{"session":scope,"context":"ammo","request":"copy-admitted"},weapon.id).ok)
	var arrow: Dictionary = make(1).record
	insert(arrow.id,1,a,"no_stack")
	var copied: Dictionary = item_owner.copy_possession(provider,{"session":scope,"context":"ammo","request":"copy-arrow"},arrow.id)
	check("admitted copy is fresh initial-custody grant",[true,false],[copied.ok,copied.record.custody.has("container")])
	check("copy leaves collection source unchanged",1,item_owner.inspect(scope,arrow.id).record.quantity)
	check("admitted recalculation remains pure",true,item_owner.recalculate(provider,{"session":scope,"context":"ammo"},arrow.id).ok)
	check("raw retire cannot bypass collection removal","unsupported",item_owner.retire_identity(provider,{"session":scope,"context":"ammo"},arrow.id).kind)

func identity_plan_checks() -> void:
	var allocator := Allocator.new({"item":"9007199254740992","stack":"18446744073709551614"})
	var before := allocator.projection()
	check("multi-entry exhaustion preflight rejects","identity_exhausted",allocator.allocate_many(["stack","stack"]).kind)
	check("failed plan burns no prefix",before,allocator.projection())
	check("last unsigned identity allocated once","18446744073709551615",allocator.allocate_many(["stack"]).ids[0].number)
	check("exhaustion never wraps","identity_exhausted",allocator.allocate("stack").kind)
	for pair in [["2","10"],["9007199254740993","9007199254740994"],["9999999999999999999","10000000000000000000"]]:
		check("numeric identity order "+pair[0],true,Allocator.less({"category":"stack","number":pair[0]},{"category":"stack","number":pair[1]}))

func query_checks() -> void:
	var before := snapshot()
	check("query no-match distinct","no_match",collections.query(provider,{"session":scope,"context":"ammo"},a,{"profile":"dfu-item-114"}).kind)
	check("query missing definition distinct","missing_definition",collections.query(provider,{"session":scope,"context":"ammo"},a,{"profile":"absent"}).kind)
	check("query invalid filter distinct","invalid_filter",collections.query(provider,{"session":scope,"context":"ammo"},a,{"unknown":true}).kind)
	check("query unavailable distinct","missing_collection",collections.query(provider,{"session":scope,"context":"ammo"},{"category":"container","number":"999"},{}).kind)
	check("query deterministic match","match",collections.query(provider,{"session":scope,"context":"ammo"},a,{"type":"arrow"}).kind)
	check("queries allocate mutate or draw nothing",before,snapshot())
	var view: Dictionary = collections.projection(provider,{"session":scope,"context":"ammo"},a)
	view.entries.clear()
	check("detached collection projection",before.a.size(),entries(a).size())
	var state := CollectionsPolicy.ordinary_state()
	state.contents = {"payload":"summoned"}
	state.summoned = true
	state.expiry = 2000
	var r: Dictionary = collections.execute(provider,op("intake",{"type":"charged","profile":"dfu-item-141","quantity":2,"state":state})).record
	insert(r.id,2,a,"no_stack")
	check("summoned-first shortest expiry",r.id,collections.query(provider,{"session":scope,"context":"ammo"},a,{"type":"charged","summoned_first":true,"quest":true,"enchanted":true}).record.id)
	provider.expire_on_admit = true
	var previous: Dictionary = item_owner.inspect(scope,r.id).record
	check("expiry revalidated after staged admission","expired",collections.execute(provider,op("transfer",{"id":r.id,"quantity":1,"destination":b,"mode":"no_stack"})).kind)
	check("expiry rejection preserves possession",previous,item_owner.inspect(scope,r.id).record)
	check("expired query excludes without cleanup","no_match",collections.query(provider,{"session":scope,"context":"ammo"},a,{"type":"charged","summoned_first":true}).kind)
	provider.expire_on_admit = false
	provider.now = 1000

func rendered_checks(shell: Control) -> void:
	# Let the production session shell finish its queued focus/render work before
	# creating this independent DEV surface. The diagnostic owns its focus after it.
	for frame in 3: await shell.get_tree().process_frame
	var overlay := CanvasLayer.new()
	overlay.layer = 100
	shell.add_child(overlay)
	var backdrop := ColorRect.new()
	backdrop.color = Color("10171d")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(backdrop)
	var panel := PanelContainer.new()
	panel.position = Vector2(32,32)
	panel.size = Vector2(960,600)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("17212a")
	style.content_margin_left = 24
	style.content_margin_top = 24
	style.content_margin_right = 24
	style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel",style)
	overlay.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation",24)
	panel.add_child(rows)
	var title := Label.new()
	title.text = "Collections diagnostic — controlled owners"
	title.add_theme_font_size_override("font_size",26)
	rows.add_child(title)
	var status := Label.new()
	status.add_theme_font_size_override("font_size",22)
	rows.add_child(status)
	var button := Button.new()
	button.text = "Move one arrow to right collection"
	button.custom_minimum_size.y = 48
	rows.add_child(button)
	var notice := Label.new()
	notice.text = "Simulated control activation. Capacity, effects, tender and native SAVE remain pending."
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(notice)
	var selected: Dictionary = collections.query(provider,{"session":scope,"context":"ammo"},a,{"type":"arrow"}).record
	var old_total := count(a)+count(b)
	button.pressed.connect(func():
		var result: Dictionary = collections.execute(provider,op("transfer",{"id":selected.id,"quantity":1,"destination":b,"mode":"automatic"}))
		status.text = "Committed: %s | left %d | right %d | total %d" % [result.ok,count(a),count(b),count(a)+count(b)])
	button.grab_focus()
	button.pressed.emit()
	await capture(shell,"item-collections-transfer")
	check("rendered actual transfer result",true,status.text.begins_with("Committed: true") and status.is_visible_in_tree())
	check("rendered transfer conserves actual quantity",old_total,count(a)+count(b))
	check("rendered diagnostic focus",true,button.has_focus())
	overlay.queue_free()

func boundary_checks(controller: RefCounted) -> void:
	var request := op("split",{"id":entries(a)[0].id,"quantity":entries(a)[0].quantity})
	var result: Dictionary = collections.execute(provider,request)
	var cross_request := explicit(request.request,"ammo")
	check("construction cannot reuse collection request identity","request_conflict",item_owner.construct(provider,cross_request).kind)
	var made_request := explicit("cross-collection-conflict","ammo")
	var made: Dictionary = item_owner.construct(provider,made_request)
	check("collection cannot reuse construction request identity","request_conflict",collections.execute(provider,{"session":scope,"context":"ammo","request":made_request.request,"action":"insert","id":made.record.id,"quantity":1,"destination":a,"mode":"automatic"}).kind)
	var before := snapshot()
	check("invalid same-collection request still rejects","invalid_mode",collections.execute(provider,op("transfer",{"id":entries(a)[0].id,"quantity":1,"destination":a,"mode":"invented"})).kind)
	check("invalid no-op preserves all state",before,snapshot())
	provider.change_revision = true
	check("staged admission revision revalidated","stale_admission",insert(made.record.id,1,a,"no_stack").kind)
	check("stale admission does not mutate",before,snapshot())
	var singleton := explicit("template-denied-singleton","weapon")
	singleton.profile = "dfu-item-114"
	var denied: Dictionary = item_owner.construct(provider,singleton)
	check("template-denied singleton constructs",true,denied.ok)
	check("actual selected template deny",false,collections.eligibility(provider,{"session":scope,"context":"weapon"},denied.record.id).eligible)
	insert(denied.record.id,1,a,"automatic","weapon")
	var full: Dictionary = collections.execute(provider,op("split",{"id":denied.record.id,"quantity":1}))
	check("ineligible singleton full-count returns original",["unchanged",denied.record.id],[full.kind,full.record.id])
	check("actual template allow overrides type deny",true,collections.eligibility(provider,{"session":scope,"context":"ammo"},made.record.id).eligible)
	var sample: Dictionary = make(1).record
	item_owner.modify(provider,{"session":scope,"context":"ammo"},sample.id,{"dye":"red"})
	var target: Dictionary = entries(b).filter(func(r: Dictionary): return r.stack_type == "arrow")[0]
	before = snapshot()
	check("persistent dye prevents explicit merge","incompatible",collections.execute(provider,op("insert",{"id":sample.id,"quantity":1,"destination":b,"mode":"target","target":target.id})).kind)
	check("dye rejection preserves source",before,snapshot())
	var fresh: Dictionary = item_owner.inspect(scope,sample.id).record
	var body := fresh.duplicate(true)
	body.body = "female-elf"
	body.visual.archive = 999
	body.revision += 20
	body.custody = {}
	body.id = {"category":"stack","number":"9007199254740993"}
	check("compatibility excludes wearer identity and transient state",collections.compatibility_key(fresh),collections.compatibility_key(body))
	for field in ["condition","style","dye","material"]:
		var changed := fresh.duplicate(true)
		changed[field] = fresh[field]+1 if field == "condition" else "changed"
		check("explicit compatibility distinction "+field,false,collections.compatibility_key(fresh) == collections.compatibility_key(changed))
	var big: Dictionary = collections.execute(provider,op("create",{"name":"uncapped"},"weapon")).collection.id
	var maximum: Dictionary = make(2147483647,"weapon").record
	check("uncapped numeric maximum accepted",true,insert(maximum.id,maximum.quantity,big,"automatic","weapon").ok)
	var increment: Dictionary = make(1,"weapon").record
	var prior: Dictionary = collections.projection(provider,{"session":scope,"context":"weapon"},big)
	check("uncapped overflow rejects rather than spill","quantity_overflow",insert(increment.id,1,big,"automatic","weapon").kind)
	check("overflow preserves destination",prior,collections.projection(provider,{"session":scope,"context":"weapon"},big))
	check("overflow preserves incoming unit",1,item_owner.inspect(scope,increment.id).record.quantity)
	var enormous: Dictionary = make(2147483647).record
	before = snapshot()
	check("technical staging bound rejects safely","plan_too_large",insert(enormous.id,enormous.quantity,a,"no_stack").kind)
	check("technical bound preserves owned state",before,snapshot())
	check("unbound requester gains no mutation authority","unauthorized",collections.execute(RefCounted.new(),op("consume",{"id":sample.id,"quantity":1})).kind)
	check("stale session request rejects before mutation","stale_session",collections.execute(provider,op("consume",{"id":sample.id,"quantity":1}).merged({"session":"obsolete"},true)).kind)
	check("unsupported import privilege unavailable","unsupported",collections.execute(provider,op("import",{"records":[]})).kind)
	check("arbitrary duplicate record intake unavailable","invalid_request",collections.execute(provider,op("insert",{"id":sample.id,"quantity":1,"destination":a,"mode":"automatic","record":sample})).kind)
	var registry: RefCounted = controller.providers.definitions
	var resources: Dictionary = registry.active().resources
	var bad := {"domain":CollectionsPolicy.DOMAIN,"path":"policies","operation":"patch","entries":[{"id":"arrow","value":{"cap":-1}}]}
	check("malformed policy fails real DATA contribution",false,registry.apply_contribution(resources,JSON.stringify(bad).to_utf8_buffer(),{"provider":"collections.test","file":"bad.json","version":"1.0.0","root":sandbox}).ok)
	check("malformed contribution preserves original type cap",17,resources[CollectionsPolicy.DOMAIN+":policies"].records.arrow.value.cap)
	bad.operation = "add"
	bad.entries = [{"id":"arrow","value":resources[CollectionsPolicy.DOMAIN+":policies"].records.arrow.value}]
	check("duplicate policy identity fails real DATA contribution",false,registry.apply_contribution(resources,JSON.stringify(bad).to_utf8_buffer(),{"provider":"collections.test","file":"duplicate.json","version":"1.0.0","root":sandbox}).ok)
	bad.operation = "patch"
	bad.entries = [{"id":"charged","value":{"provider":"unregistered.provider-v1"}}]
	check("missing provider fails real DATA contribution",false,registry.apply_contribution(resources,JSON.stringify(bad).to_utf8_buffer(),{"provider":"collections.test","file":"missing-provider.json","version":"1.0.0","root":sandbox}).ok)

func exhaustion_checks() -> void:
	# Controlled high-water fixture only, no production reset/import/restore API.
	var incoming: Dictionary = make(11).record
	var empty: Dictionary = collections.execute(provider,op("create",{"name":"exhaustion"})).collection.id
	var counters: Dictionary = item_owner._allocator.projection()
	counters.stack = "18446744073709551614"
	item_owner._allocator = Allocator.new(counters)
	var before := snapshot()
	check("real multi-entry collection plan exhaustion","identity_exhausted",insert(incoming.id,11,empty,"no_stack").kind)
	check("exhausted plan preserves owned state and allocator",before,snapshot())
	check("exhausted plan leaves incoming intact",11,item_owner.inspect(scope,incoming.id).record.quantity)
	check("exhausted plan leaves destination empty",0,entries(empty).size())

func summoned_checks() -> void:
	var container: Dictionary = collections.execute(provider,op("create",{"name":"summoned-arrows"})).collection.id
	var state := CollectionsPolicy.ordinary_state()
	var ordinary: Dictionary = collections.execute(provider,op("intake",{"type":"arrow","profile":"dfu-item-131","quantity":2,"state":state})).record
	insert(ordinary.id,2,container)
	state.summoned = true
	state.expiry = 3000
	state.provenance = {"origin":"controlled-conjurer"}
	var summoned: Dictionary = collections.execute(provider,op("intake",{"type":"arrow","profile":"dfu-item-131","quantity":2,"state":state})).record
	check("summoned arrow exception actual selected RULE",true,collections.eligibility(provider,{"session":scope,"context":"ammo"},summoned.id).eligible)
	check("summoned arrows do not merge with ordinary","incompatible",collections.execute(provider,op("insert",{"id":summoned.id,"quantity":2,"destination":container,"mode":"target","target":ordinary.id})).kind)
	insert(summoned.id,2,container)
	var matching: Dictionary = collections.execute(provider,op("intake",{"type":"arrow","profile":"dfu-item-131","quantity":1,"state":state})).record
	insert(matching.id,1,container)
	check("equal summoned expiry provenance merge",[3,"missing_or_retired"],[item_owner.inspect(scope,summoned.id).record.quantity,item_owner.inspect(scope,matching.id).kind])
	state.expiry = 4000
	var later: Dictionary = collections.execute(provider,op("intake",{"type":"arrow","profile":"dfu-item-131","quantity":1,"state":state})).record
	insert(later.id,1,container)
	check("different summoned expiry separate",3,entries(container).size())
	check("shortest summoned lifetime beats ordinary identity",summoned.id,collections.query(provider,{"session":scope,"context":"ammo"},container,{"summoned_first":true}).record.id)
	for flag in ["quest","enchanted"]:
		var restricted := state.duplicate(true)
		restricted[flag] = true
		var item: Dictionary = collections.execute(provider,op("intake",{"type":"arrow","profile":"dfu-item-131","quantity":1,"state":restricted})).record
		check("summoned arrow retains restriction "+flag,false,collections.eligibility(provider,{"session":scope,"context":"ammo"},item.id).eligible)
	var equipped := state.duplicate(true)
	equipped.equipped = true
	check("missing equipment transition never silently unequips","required_equipment_transition",collections.execute(provider,op("intake",{"type":"arrow","profile":"dfu-item-131","quantity":1,"state":equipped})).kind)

func compatibility_override_checks() -> void:
	var container: Dictionary = collections.execute(provider,op("create",{"name":"set-contents"})).collection.id
	var state := CollectionsPolicy.ordinary_state()
	state.contents = {"tags":["alpha","beta"]}
	var first: Dictionary = collections.execute(provider,op("intake",{"type":"tagged","profile":"dfu-item-141","quantity":2,"state":state})).record
	insert(first.id,2,container)
	state.contents.tags.reverse()
	var reversed: Dictionary = collections.execute(provider,op("intake",{"type":"tagged","profile":"dfu-item-141","quantity":1,"state":state})).record
	check("mod selected set compatibility merges order variants",true,insert(reversed.id,1,container).ok)
	check("set semantics conserve actual contents",[3,["alpha","beta"]],[item_owner.inspect(scope,first.id).record.quantity,item_owner.inspect(scope,first.id).record.state.contents.tags])
	check("set-compatible source retires","missing_or_retired",item_owner.inspect(scope,reversed.id).kind)
	state.contents.tags = ["alpha","gamma"]
	var different: Dictionary = collections.execute(provider,op("intake",{"type":"tagged","profile":"dfu-item-141","quantity":1,"state":state})).record
	insert(different.id,1,container)
	check("different set contents stay separate",2,entries(container).size())
	state.contents.tags = ["alpha","alpha"]
	check("malformed set contents reject before grant","unsupported_state",collections.execute(provider,op("intake",{"type":"tagged","profile":"dfu-item-141","quantity":1,"state":state})).kind)
	state.contents.tags = ["alpha"]
	provider.bad_properties = true
	var before: Dictionary = item_owner.counters()
	check("missing semantic physical provider properties reject","unsupported_properties",collections.execute(provider,op("intake",{"type":"tagged","profile":"dfu-item-141","quantity":1,"state":state})).kind)
	check("failed physical intake allocates nothing",before,item_owner.counters())
	provider.bad_properties = false
	check("semantic properties remain provider supplied",[7,0.25,3],[first.value,first.weight_kg,first.condition])

func low_numeric_order_checks() -> void:
	var target: Dictionary = entries(a).filter(func(r: Dictionary): return r.id.number == "2")[0]
	var container: Dictionary = collections.execute(provider,op("create",{"name":"numeric-low"})).collection.id
	collections.execute(provider,op("transfer",{"id":target.id,"quantity":target.quantity,"destination":container,"mode":"no_stack"}))
	collections.execute(provider,op("consume",{"id":target.id,"quantity":1}))
	# All preceding operations pin the next stack allocation at 9. The placeholder
	# remains legitimate initial custody; the next no-stack destination is ID 10.
	make(1)
	var ten: Dictionary = make(4).record
	check("real low numeric fixture identities",["2","10"],[target.id.number,ten.id.number])
	insert(ten.id,4,container,"no_stack")
	var incoming: Dictionary = make(1).record
	insert(incoming.id,1,container)
	check("real automatic distribution chooses 2 before 10",[5,4],amounts(container))
	check("real retrieval chooses 2 before 10",target.id,collections.query(provider,{"session":scope,"context":"ammo"},container,{}).record.id)

func high_numeric_order_checks() -> void:
	# Fresh controlled allocator with a forward-only high-water jump; no item is
	# renamed and no restoration is claimed. All previous live IDs are lower.
	var counters: Dictionary = item_owner._allocator.projection()
	counters.stack = "9007199254740992"
	item_owner._allocator = Allocator.new(counters)
	var container: Dictionary = collections.execute(provider,op("create",{"name":"numeric-high"})).collection.id
	var first: Dictionary = make(4).record
	var second: Dictionary = make(4).record
	insert(second.id,4,container,"no_stack")
	insert(first.id,4,container,"no_stack")
	check("real high identity components exact",["9007199254740993","9007199254740994"],[first.id.number,second.id.number])
	var incoming: Dictionary = make(1).record
	insert(incoming.id,1,container)
	check("real high numeric automatic survivor order",[5,4],amounts(container))
	check("real high numeric retrieval order",first.id,collections.query(provider,{"session":scope,"context":"ammo"},container,{}).record.id)

func terminal(fixture: Dictionary) -> Dictionary:
	var result := super.terminal(fixture)
	result.downstream = "Collections diagnostic only. Controlled admission/state; live capacity, equipment, effects, quest, settlement and native SAVE remain pending."
	return result
