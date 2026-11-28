extends RefCounted
## ITEM authority: construction and owned collection collaborator. No native restore.
const Data = preload("res://scripts/data/item_construction.gd")
const Formula = preload("res://scripts/rule/item_formulas.gd")
const IDs = preload("res://scripts/item/identity_allocator.gd")
const N = preload("res://scripts/data/actor_input_formats.gd")
var definitions: RefCounted
var _core: WeakRef
var _allocator := IDs.new()
var _possessions: Dictionary = {}
var _receipts: Dictionary = {}
var _contexts: Dictionary = {}
var _operation: Dictionary = {}
var _scope := ""
var _serial := 0
var collections: RefCounted

func _init(core: SessionLifecycle) -> void:
	_core = weakref(core)
	collections = preload("res://scripts/item/collections.gd").new(self)

func service_binding() -> Dictionary:
	return {"role":"item-construction","owner":"ITEM","lifetime":"session","required":true,"ready":true,"provider":self,"formula_hooks":Formula.HOOKS.duplicate(),"random_purposes":["loot"]}

func bind_services(scope: String, services: Array) -> Dictionary:
	var pending := {}
	var custody_claims := {}
	var own_service := false
	for service: Dictionary in services:
		if service.get("provider") == self: own_service = service == service_binding()
		if not service.has("item_contexts"): continue
		if service.lifetime != "session" or service.get("ready") != true or not is_instance_valid(service.get("provider")) or not service.item_contexts is Array: return fail("Malformed item requester binding.")
		var owner: Object = service.provider
		if pending.has(owner.get_instance_id()): return fail("Duplicate requester binding.")
		var contexts := {}
		for raw: Variant in service.item_contexts:
			if not raw is Dictionary or raw.size() not in [5,6] or not Data.Paths.valid_id(raw.get("id","")) or not Data.Paths.valid_id(raw.get("custody","")) or not Data.keys(raw.get("pool")) or typeof(raw.get("worn")) != TYPE_BOOL or typeof(raw.get("copy")) != TYPE_BOOL or contexts.has(raw.id): return fail("Complete unique context/custody/pool/worn/copy declaration required.")
			if raw.size() == 6:
				if not raw.has("collections") or not collections.binding_valid(owner,raw.collections): return fail("Complete collection provider contract required.")
			var claim: String = raw.custody+":"+raw.id
			if custody_claims.has(claim): return fail("Conflicting initial custody authority.")
			custody_claims[claim] = true
			for profile in raw.pool:
				var read := definition(profile)
				if not read.ok or read.record.value.kind != "template": return fail("Unsupported explicit generation pool.")
			contexts[raw.id] = raw.duplicate(true)
		pending[owner.get_instance_id()] = {"owner":weakref(owner),"contexts":contexts}
	if not pending.is_empty() and not own_service: return fail("Requesters require composed ITEM service.")
	_contexts = pending
	_scope = scope
	return {"ok":true}

func fail(reason: String, kind := "invalid_construction") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason}

func definition(id: String) -> Dictionary:
	return definitions.query(Data.DOMAIN,"profiles",id) if definitions != null else fail("Definitions unavailable.")

func context(owner: Object, request: Dictionary) -> Dictionary:
	var core: SessionLifecycle = _core.get_ref()
	if core != null and not core._plain_data(request,true): return fail("Plain detached request values required.")
	if core == null or not is_instance_valid(owner) or request.get("session") != _scope or _scope.is_empty() or not core.formula_owner_valid(_scope,self,"item.value"): return fail("Current ready ITEM session required.","stale_session")
	var binding: Dictionary = _contexts.get(owner.get_instance_id(),{})
	if binding.is_empty() or binding.owner.get_ref() != owner or not binding.contexts.has(request.get("context")): return fail("Explicit owner context required.","unauthorized")
	return {"ok":true,"value":binding.contexts[request.context].duplicate(true)}

func formula_operation_current(value: Dictionary) -> bool:
	return not _operation.is_empty() and value == _operation and value.session == _scope

func _begin(request: Dictionary) -> bool:
	if not _operation.is_empty(): return false
	_serial += 1
	_operation = {"session":_scope,"serial":_serial,"request":request.get("request","")}
	return true

func _end(result: Dictionary) -> Dictionary:
	_operation.clear()
	return result

func _formula(hook: String, value: Dictionary) -> Dictionary:
	var core: SessionLifecycle = _core.get_ref()
	return core.formulas.invoke(hook,value,core,self,_scope,_operation)

func _profile(id: String) -> Dictionary:
	var read := definition(id)
	if not read.ok or read.record.value.kind != "template": return fail("Required construction profile unavailable.")
	var base: Dictionary = definitions.query("item-spell.inputs","catalog",read.record.value.template)
	if not base.ok: return base
	return {"ok":true,"profile":read.record.value,"key":base.record.identity,"base":base.record.value.data}

func _calculate(request: Dictionary, authorization: Dictionary) -> Dictionary:
	for field in request:
		if field not in ["session","context","request","profile","body","category","material","style","dye","quantity","condition"]: return fail("Unknown construction field: "+field)
	if request.get("profile") not in authorization.pool: return fail("Profile outside authorized pool.","unauthorized")
	var loaded := _profile(request.profile)
	if not loaded.ok: return loaded
	var p: Dictionary = loaded.profile
	var policy_read := definition("policy")
	if not policy_read.ok: return policy_read
	var policy: Dictionary = policy_read.record.value
	var category: Variant = request.get("category")
	var body: Variant = request.get("body")
	if body not in p.bodies or not category is String or not p.styles.has(category): return fail("Unsupported body/category.")
	if (p.type == "weapon" and category != "weapon") or (p.type in ["clothing","ammo"] and category != "neutral"): return fail("Incompatible category.")
	var mode: String = "material" if category == "weapon" else str(policy.categories.get(category,{}).get("mode","neutral"))
	var coefficients := {"value":1,"weight":4,"condition":4}
	var dye: String = p.default_dye
	if mode == "material":
		var material_id: Variant = request.get("material")
		if not material_id is String or material_id not in p.materials: return fail("Explicit compatible material required.")
		var material := definition(material_id)
		if not material.ok or material.record.value.kind != "material": return fail("Unsupported material/provider.")
		coefficients = material.record.value.coefficients
		dye = material.record.value.dye
	elif request.has("material"): return fail("Material incompatible with neutral/category profile.")
	elif p.type == "armor": dye = policy.categories[category].dye
	var style: Variant = request.get("style","default")
	var ordered_styles: Array = p.styles[category].keys()
	ordered_styles.sort()
	if style == "default": style = ordered_styles[0]
	if not style is String or not p.styles[category].has(style): return fail("Unsupported explicit style.")
	if request.has("dye") and not request.dye is String: return fail("Typed dye required.")
	dye = request.get("dye",dye)
	if dye not in p.dyes: return fail("Unsupported explicit dye.")
	var quantity: Variant = request.get("quantity")
	if not N.integer(quantity,1,2147483647): return fail("Explicit supported quantity required.")
	var calculated := {}
	for field in ["value","weight","condition"]:
		var base: int = int(loaded.base.basePrice) if field == "value" else (int(round(float(loaded.base.baseWeight)*1000000)) if field == "weight" else int(loaded.base.hitPoints))
		var result := _formula("item."+field,{"base":base,"mode":mode,"coefficients":coefficients})
		if not result.ok: return result
		calculated[field] = result.value
	var condition: Variant = request.get("condition",calculated.condition)
	if not N.integer(condition,0,calculated.condition) or (request.has("condition") and not authorization.worn): return fail("Unauthorized/invalid worn condition.")
	var appearance := {"provider":p.visual.provider,"archive":int(p.visual.archives[body]),"record":int(p.visual.record)+int(p.styles[category][style]),"variant":int(p.styles[category][style]),"dye_adapter":policy.dye_adapters[dye].duplicate(true)}
	var record := {"definition":loaded.key,"profile":request.profile,"kind":p.type,"category":category,"material":request.get("material",""),"body":body,"style":style,"dye":dye,"quantity":int(quantity),"condition":int(condition),"maximum_condition":calculated.condition,"value":calculated.value,"weight_kg":float(calculated.weight)/1000000.0,"visual":appearance,"identity_category":p.identity,"pending_consumers":["combat","equipment","save"],"state":preload("res://scripts/data/item_collections.gd").ordinary_state(),"stack_type":"arrow" if p.type == "ammo" else p.type}
	if quantity > 1:
		var eligibility: Dictionary = collections._policy(record)
		if not eligibility.ok: return eligibility
		if not eligibility.eligible: return fail("Ineligible multiple quantity.")
	return {"ok":true,"record":record}

func preview(owner: Object, request: Dictionary) -> Dictionary:
	var auth := context(owner,request)
	if not auth.ok: return auth
	if not _begin(request): return fail("Operation busy.","busy")
	return _end(_calculate(request,auth.value))

func construct(owner: Object, request: Dictionary) -> Dictionary:
	var auth := context(owner,request)
	if not auth.ok: return auth
	if not Data.Paths.valid_id(request.get("request","")): return fail("Stable construction request required.")
	var key: String = str(owner.get_instance_id())+":"+request.context+":"+request.request
	if collections.request_claimed(key): return fail("Conflicting collection operation identity.","request_conflict")
	if _receipts.has(key):
		if _receipts[key].input != request: return fail("Request identity reused with changed inputs.","request_conflict")
		if not _possessions.has(_id_key(_receipts[key].outcome.record.id)): return fail("Committed possession has retired; no regrant.","missing_or_retired")
		return _receipts[key].outcome.duplicate(true)
	if not _begin(request): return fail("Operation busy.","busy")
	var calculated := _calculate(request,auth.value)
	if not calculated.ok: return _end(calculated)
	# Recheck after selected callbacks. No publication or allocation on stale scope.
	if not context(owner,request).ok: return _end(fail("Obsolete construction.","stale_session"))
	var allocated := _allocator.allocate(calculated.record.identity_category)
	if not allocated.ok: return _end(allocated)
	var record: Dictionary = calculated.record
	record.state = preload("res://scripts/data/item_collections.gd").ordinary_state()
	record.stack_type = "arrow" if record.kind == "ammo" else record.kind
	record.id = allocated.id
	record.custody = {"owner":auth.value.custody,"context":request.context}
	record.revision = 1
	_possessions[_id_key(record.id)] = record
	var outcome := {"ok":true,"record":record.duplicate(true),"request":request.request,"session":_scope}
	_receipts[key] = {"input":request.duplicate(true),"outcome":outcome.duplicate(true)}
	return _end(outcome)

static func _id_key(id: Dictionary) -> String:
	return str(id.get("category",""))+":"+str(id.get("number",""))

func inspect(scope: String, id: Dictionary) -> Dictionary:
	if scope != _scope or scope.is_empty(): return fail("Stale item scope.","stale_session")
	if id.size() != 2 or id.get("category") not in ["item","stack"] or not IDs.valid(id.get("number")): return fail("Invalid typed identity.")
	return {"ok":true,"record":_possessions[_id_key(id)].duplicate(true)} if _possessions.has(_id_key(id)) else fail("Missing or retired possession.","missing_or_retired")

func modify(owner: Object, request: Dictionary, id: Dictionary, changes: Dictionary) -> Dictionary:
	if not _operation.is_empty(): return fail("Operation busy.","busy")
	var auth := context(owner,request)
	if not auth.ok: return auth
	var found := inspect(request.session,id)
	if not found.ok: return found
	if not collections.access(owner,request,found.record).ok: return fail("Foreign custody.","unauthorized")
	var record: Dictionary = found.record
	if record.category == "semantic" or record.state != preload("res://scripts/data/item_collections.gd").ordinary_state(): return fail("Special-state appearance owner required.","unsupported")
	var loaded := _profile(record.profile)
	if not loaded.ok: return loaded
	for field in changes:
		if field not in ["body","style","dye"]: return fail("Only supported appearance modifications; material transformation is unavailable.")
	var candidate := record.merged(changes,true)
	if candidate.body not in loaded.profile.bodies or candidate.dye not in loaded.profile.dyes or not loaded.profile.styles[record.category].has(candidate.style): return fail("Unsupported appearance.")
	if candidate == record: return {"ok":true,"record":record.duplicate(true)}
	var policy := definition("policy")
	if not policy.ok: return policy
	candidate.visual = {"provider":loaded.profile.visual.provider,"archive":int(loaded.profile.visual.archives[candidate.body]),"variant":int(loaded.profile.styles[record.category][candidate.style]),"record":int(loaded.profile.visual.record)+int(loaded.profile.styles[record.category][candidate.style]),"dye_adapter":policy.record.value.dye_adapters[candidate.dye].duplicate(true)}
	candidate.revision += 1
	_possessions[_id_key(id)] = candidate.duplicate(true)
	return {"ok":true,"record":candidate.duplicate(true)}

func copy_possession(owner: Object, request: Dictionary, id: Dictionary) -> Dictionary:
	if not _operation.is_empty(): return fail("Operation busy.","busy")
	var auth := context(owner,request)
	if not auth.ok: return auth
	if not auth.value.copy or not Data.Paths.valid_id(request.get("request","")): return fail("Copy authorization and request required.","unauthorized")
	var key: String = str(owner.get_instance_id())+":"+request.context+":"+request.request
	var input := request.duplicate(true).merged({"source":id.duplicate(true)})
	if collections.request_claimed(key): return fail("Conflicting collection operation identity.","request_conflict")
	if _receipts.has(key):
		if _receipts[key].input != input: return fail("Conflicting copy identity.","request_conflict")
		if not _possessions.has(_id_key(_receipts[key].outcome.record.id)): return fail("Copied possession has retired.","missing_or_retired")
		return _receipts[key].outcome.duplicate(true)
	var found := inspect(request.session,id)
	if not found.ok: return found
	var record: Dictionary = found.record
	if not collections.access(owner,request,record).ok or record.profile not in auth.value.pool: return fail("Copy outside authorized custody/pool.","unauthorized")
	if record.category == "semantic" or record.get("state",{}) != preload("res://scripts/data/item_collections.gd").ordinary_state(): return fail("Special-state copy grant unavailable.","unsupported")
	var allocated := _allocator.allocate(record.identity_category)
	if not allocated.ok: return allocated
	record.id = allocated.id
	record.revision = 1
	record.custody = {"owner":auth.value.custody,"context":request.context}
	_possessions[_id_key(record.id)] = record.duplicate(true)
	var outcome := {"ok":true,"record":record.duplicate(true),"session":_scope,"request":request.request}
	_receipts[key] = {"input":input,"outcome":outcome.duplicate(true)}
	return outcome

## Initial construction custody only. Collection removal/consumption follows in
## increment 2; this identity endpoint cannot transfer or insert anything.
func retire_identity(owner: Object, request: Dictionary, id: Dictionary) -> Dictionary:
	if not _operation.is_empty(): return fail("Operation busy.","busy")
	var auth := context(owner,request)
	if not auth.ok: return auth
	var found := inspect(request.session,id)
	if not found.ok: return found
	if not collections.access(owner,request,found.record).ok: return fail("Foreign custody.","unauthorized")
	if found.record.custody.has("container") or found.record.category == "semantic" or found.record.state != preload("res://scripts/data/item_collections.gd").ordinary_state(): return fail("Use checked collection removal.","unsupported")
	_possessions.erase(_id_key(id))
	return {"ok":true,"retired":id.duplicate(true)}

func recalculate(owner: Object, request: Dictionary, id: Dictionary) -> Dictionary:
	var auth := context(owner,request)
	if not auth.ok: return auth
	var found := inspect(request.session,id)
	if not found.ok: return found
	var record: Dictionary = found.record
	if record.category == "semantic": return fail("Semantic property provider required.","unsupported")
	if not collections.access(owner,request,record).ok: return fail("Foreign custody.","unauthorized")
	if not _begin(request): return fail("Operation busy.","busy")
	var input := {"session":request.session,"context":request.context,"request":request.get("request",""),"profile":record.profile,"body":record.body,"category":record.category,"style":record.style,"dye":record.dye,"quantity":record.quantity,"condition":record.condition}
	if not record.material.is_empty(): input.material = record.material
	# Recalculation of an accessible existing possession is a query, not a new
	# construction grant. A transfer may place it outside this context's grant pool.
	var query_authorization: Dictionary = auth.value.duplicate(true)
	query_authorization.worn = true
	if record.profile not in query_authorization.pool: query_authorization.pool.append(record.profile)
	var calculated := _calculate(input,query_authorization)
	if not calculated.ok: return _end(calculated)
	# Query only. Reconstruct from original DATA bases while retaining every owned
	# fact, including current condition. Never replace the item with its template.
	for key in ["value","weight_kg","maximum_condition","visual"]: record[key] = calculated.record[key]
	return _end({"ok":true,"record":record.duplicate(true)})

func retire_scope(scope: String) -> void:
	if _scope != scope: return
	_scope = ""
	_possessions.clear()
	_receipts.clear()
	_contexts.clear()
	_operation.clear()
	_generation.clear()
	collections.retire()
	_allocator = IDs.new() # New native branch only; restore integration remains pending.

func dispose() -> void:
	retire_scope(_scope)
	definitions = null

func counters() -> Dictionary:
	return {"identities":_allocator.projection(),"possessions":_possessions.size(),"receipts":_receipts.size(),"generations":_generation.size()}

var _generation: Dictionary = {}

func generation_projection(owner: Object, request: Dictionary) -> Dictionary:
	var auth := context(owner,request)
	if not auth.ok: return auth
	var key: String = str(owner.get_instance_id())+":"+request.context+":"+str(request.get("request",""))
	return {"ok":true,"generation":_generation.get(key,{}).duplicate(true)}

func generate(owner: Object, request: Dictionary) -> Dictionary:
	var auth := context(owner,request)
	if not auth.ok: return auth
	if request.size() != 5 or not Data.Paths.valid_id(request.get("request","")) or not N.integer(request.get("level"),-1000000,1000000) or not request.get("body") is String: return fail("Explicit bounded level/body/context/request required.")
	var key: String = str(owner.get_instance_id())+":"+request.context+":"+request.request
	if collections.request_claimed(key): return fail("Conflicting collection operation identity.","request_conflict")
	if _generation.has(key) and _generation[key].input != request: return fail("Conflicting generation request.","request_conflict")
	if not _begin(request): return fail("Operation busy.","busy")
	if not _generation.has(key): _generation[key] = {"input":request.duplicate(true),"decisions":{},"draws":{},"terminal":{}}
	var state: Dictionary = _generation[key]
	if not state.terminal.is_empty(): return _end(state.terminal.duplicate(true))
	var core: SessionLifecycle = _core.get_ref()
	var lease: Dictionary = core.randomness.source(_scope,self,"loot")
	if not lease.ok: return _end(lease)
	var selected: Dictionary = state.decisions
	if not selected.has("profile"):
		var draw := _draw(state,"template",auth.value.pool.size(),lease.source)
		if not draw.ok: return _end(draw)
		selected.profile = auth.value.pool[draw.value]
	var loaded := _profile(selected.profile)
	if not loaded.ok: return _end(loaded)
	var p: Dictionary = loaded.profile
	if request.body not in p.bodies: return _end(fail("Selected template does not support requested body; no resampling."))
	var policy_read := definition("policy")
	if not policy_read.ok: return _end(policy_read)
	var policy: Dictionary = policy_read.record.value
	if not selected.has("category"):
		if p.type == "armor":
			var draw := _draw(state,"category",100,lease.source)
			if not draw.ok: return _end(draw)
			var index := _formula("item.category",{"raw":draw.value,"level":int(request.level),"policy":policy.selector})
			if not index.ok: return _end(index)
			if index.value < 0 or index.value >= policy.selector.categories.size(): return _end(fail("Selected category mapping invalid."))
			selected.category = policy.selector.categories[index.value]
		else: selected.category = "weapon" if p.type == "weapon" else "neutral"
	if not p.styles.has(selected.category): return _end(fail("Unsupported generated category; no resampling."))
	var material_mode: bool = selected.category == "weapon" or policy.categories.get(selected.category,{}).get("mode") == "material"
	if material_mode and not selected.has("material"):
		var draw := _draw(state,"material",256,lease.source)
		if not draw.ok: return _end(draw)
		var index := _formula("item.material",{"raw":draw.value,"level":int(request.level),"policy":policy.selector})
		if not index.ok: return _end(index)
		if index.value < 0 or index.value >= policy.selector.materials.size(): return _end(fail("Selected material mapping invalid."))
		selected.material = policy.selector.materials[index.value]
	if not selected.has("style"):
		var styles: Array = p.styles[selected.category].keys()
		styles.sort()
		var draw := _draw(state,"style",styles.size(),lease.source)
		if not draw.ok: return _end(draw)
		selected.style = styles[draw.value]
	if p.type == "clothing" and not selected.has("dye"):
		var draw := _draw(state,"dye",policy.clothing_dyes.size(),lease.source)
		if not draw.ok: return _end(draw)
		selected.dye = policy.clothing_dyes[draw.value]
	if not selected.has("quantity"):
		if p.type == "ammo":
			var draw := _draw(state,"quantity",int(policy.generation.ammo_max)-int(policy.generation.ammo_min)+1,lease.source)
			if not draw.ok: return _end(draw)
			selected.quantity = draw.value+int(policy.generation.ammo_min)
		else: selected.quantity = 1
	var explicit := selected.duplicate(true).merged({"session":request.session,"context":request.context,"request":request.request,"body":request.body})
	_operation.clear()
	var result := construct(owner,explicit)
	if result.ok: state.terminal = result.duplicate(true)
	return result

func _draw(state: Dictionary, field: String, bound: int, source: RefCounted) -> Dictionary:
	if state.draws.has(field): return {"ok":true,"value":state.draws[field]}
	# Single supported choice needs no entropy. Later retries reuse every raw draw.
	var draw: Dictionary = {"ok":true,"value":0} if bound == 1 else source.bounded(bound)
	if draw.get("ok",false): state.draws[field] = draw.value
	return draw

func distribution(owner: Object, request: Dictionary, level: int) -> Dictionary:
	var auth := context(owner,request)
	if not auth.ok: return auth
	if level < -1000000 or level > 1000000: return fail("Unsupported generation level.")
	if not _begin(request): return fail("Operation busy.","busy")
	var read := definition("policy")
	if not read.ok: return _end(read)
	var policy: Dictionary = read.record.value.selector
	var materials := {}
	var categories := {}
	for raw in 256:
		var result := _formula("item.material",{"raw":raw,"level":level,"policy":policy})
		if not result.ok: return _end(result)
		if result.value < 0 or result.value >= policy.materials.size(): return _end(fail("Unmapped material selector output."))
		var id: String = policy.materials[result.value]
		materials[id] = int(materials.get(id,0))+1
	for raw in 100:
		var result := _formula("item.category",{"raw":raw,"level":level,"policy":policy})
		if not result.ok: return _end(result)
		if result.value < 0 or result.value >= policy.categories.size(): return _end(fail("Unmapped category selector output."))
		var id: String = policy.categories[result.value]
		categories[id] = int(categories.get(id,0))+1
	return _end({"ok":true,"materials":materials,"material_denominator":256,"categories":categories,"category_denominator":100,"mode":"enumerated-selected-hooks"})
