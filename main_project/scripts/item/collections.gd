extends RefCounted
## Owned collaborator; possessions live only in construction_owner._possessions.
## Plans contain detached touched records; no callbacks during owned commitment.
const Policy = preload("res://scripts/data/item_collections.gd")
const IDs = preload("res://scripts/item/identity_allocator.gd")
const N = preload("res://scripts/data/actor_input_formats.gd")
const LIMIT := 2147483647
const MAX_PLAN_ENTRIES := 65536 # Technical staging bound, not a gameplay stack cap.
var _authority: WeakRef
var _containers := {}
var _members := {} # container key -> identity-key set; no second possession store.
var _ordered := {} # Owner-maintained stable order for retrieval; UI cannot reorder.
var _policies := {} # Run-locked DATA lookups, scoped to this session publication.
var _receipts := {}
var _busy := false
var _serial := 0

func _init(authority: RefCounted) -> void:
	_authority = weakref(authority)
func retire() -> void:
	_containers.clear()
	_members.clear()
	_ordered.clear()
	_policies.clear()
	_receipts.clear()
	_busy = false
func request_claimed(key: String) -> bool:
	return _receipts.has(key) or _authority.get_ref().money.request_claimed(key)
func failure(kind: String, reason := "") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason}
func _provider_result(value: Variant) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	if not value is Dictionary or not authority._core.get_ref()._plain_data(value,true) or typeof(value.get("ok")) != TYPE_BOOL: return failure("provider_failure","Malformed provider response.")
	if not value.ok and (not value.get("kind") is String or not Policy.Paths.valid_id(value.kind)): return failure("provider_failure","Failed provider response requires a stable kind.")
	if value.has("reason") and not value.reason is String: return failure("provider_failure","Provider reason must be text.")
	return value.duplicate(true)
func binding_valid(owner: Object, value: Variant) -> bool:
	if not value is Dictionary or value.size() != 2 or not Policy.Paths.valid_id(value.get("provider","")) or not value.get("types") is Array: return false
	for method in ["collection_admit","collection_state","collection_intake","collection_now","collection_revision"]:
		if not owner.has_method(method): return false
		var signature_ok := false
		for declaration: Dictionary in owner.get_method_list():
			if declaration.name != method: continue
			var query: bool = method in ["collection_now","collection_revision"]
			signature_ok = declaration.args.size() == (0 if query else 1) and declaration["return"].type == (TYPE_INT if query else TYPE_DICTIONARY) and declaration.default_args.is_empty() and (int(declaration.flags) & METHOD_FLAG_VARARG) == 0
			if not query and signature_ok: signature_ok = declaration.args[0].type == TYPE_DICTIONARY
		if not signature_ok: return false
	var seen := {}
	for type in value.types:
		if not type is String or seen.has(type): return false
		seen[type] = true
		var read: Dictionary = _authority.get_ref().definitions.query(Policy.DOMAIN,"policies",type)
		if not read.ok or read.record.value.kind != "type" or read.record.value.provider != value.provider or read.record.value.provider.begins_with("pending."): return false
	return true
func _key(id: Dictionary) -> String:
	return str(id.get("category",""))+":"+str(id.get("number",""))
func _valid_id(id: Variant, category := "") -> bool:
	return id is Dictionary and id.size() == 2 and id.get("category") in (["item","stack"] if category.is_empty() else [category]) and IDs.valid(id.get("number"))
func _container(owner: Object, request: Dictionary, id: Variant) -> Dictionary:
	if not _valid_id(id,"container") or not _containers.has(_key(id)): return failure("missing_collection")
	var c: Dictionary = _containers[_key(id)]
	var auth: Dictionary = _authority.get_ref().context(owner,request.merged({"context":c.context},true))
	if not auth.ok: return auth
	if not auth.value.has("collections") or auth.value.custody != c.owner: return failure("unauthorized")
	if auth.value.has("capacity") and auth.value.capacity.kind == "wagon":
		var capacity: RefCounted = _authority.get_ref().capacity
		var spatial: Dictionary = capacity._context(owner,request.merged({"context":c.context},true),auth.value.capacity)
		if not spatial.ok: return spatial
		if not _authority.get_ref().context(owner,request.merged({"context":c.context},true)).ok: return failure("stale_session")
		var accessed: Dictionary = capacity.access(auth.value.capacity,spatial)
		if not accessed.ok: return accessed
	return {"ok":true,"record":c.duplicate(true),"authorization":auth.value}
func access(owner: Object, request: Dictionary, record: Dictionary) -> Dictionary:
	var a: Dictionary = _authority.get_ref().context(owner,request)
	if not a.ok: return a
	if record.custody.owner != a.value.custody or record.custody.context != request.context: return failure("unauthorized")
	if record.custody.has("container"):
		var c := _container(owner,request,record.custody.container)
		if not c.ok: return c
		if not _members[_key(record.custody.container)].has(_key(record.id)): return failure("invalid_membership")
	return {"ok":true}
func _policy(record: Dictionary) -> Dictionary:
	var owner: RefCounted = _authority.get_ref()
	if record.has("money"): return owner.money.policy(record)
	var cache_key: String = str(record.get("stack_type",""))+":"+str(record.get("profile",""))
	if not _policies.has(cache_key):
		var loaded: Dictionary = owner.definitions.query(Policy.DOMAIN,"policies",record.get("stack_type",""))
		if not loaded.ok or loaded.record.value.kind != "type": return failure("missing_definition")
		var type_value: Dictionary = loaded.record.value
		var template_value: Variant = null
		var cap_value: int = int(type_value.cap)
		var specific: Dictionary = owner.definitions.query(Policy.DOMAIN,"policies","template-"+record.profile)
		if specific.ok:
			if specific.record.value.kind != "template" or specific.record.value.type != record.stack_type: return failure("invalid_definition")
			template_value = specific.record.value.eligible
			cap_value = int(specific.record.value.cap)
		_policies[cache_key] = {"contract":type_value.duplicate(true),"override":template_value,"cap":cap_value,"provenance":type_value.provenance.duplicate(true)}
	var resolved: Dictionary = _policies[cache_key]
	var type: Dictionary = resolved.contract
	var reason := Policy.state_reason(record.get("state"),type)
	if not reason.is_empty(): return failure("unsupported_state",reason)
	var s: Dictionary = record.state
	var result: Dictionary = owner._formula("item.eligible",{"default":type.eligible,"template":resolved.override,"restrictions":type.restrictions,"state":{"equipped":s.equipped,"quest":s.quest,"enchanted":s.enchanted,"summoned_nonarrow":s.summoned and record.stack_type != "arrow"}})
	if not result.ok: return result
	return {"ok":true,"eligible":result.value == 1,"reason":"eligible" if result.value == 1 else "policy_or_instance_denied","layers":{"default":type.eligible,"template":resolved.override,"instance":result.value,"restriction_overrides":type.restrictions.duplicate()},"cap":resolved.cap,"contract":type.duplicate(true),"provenance":resolved.provenance.duplicate(true),"provider":result.provider}
func _compatible(a: Dictionary, b: Dictionary) -> Dictionary:
	var ap := _policy(a)
	if not ap.ok: return ap
	var bp := _policy(b)
	if not bp.ok: return bp
	return {"ok":true,"compatible":ap.eligible and bp.eligible and compatibility_key(a,ap.contract) == compatibility_key(b,bp.contract)}
func compatibility_key(record: Dictionary, contract: Dictionary = {}) -> Dictionary:
	# Explicit state key: excludes IDs, revisions, custody and wearer presentation.
	var result := {}
	for field in ["definition","profile","stack_type","kind","category","material","style","dye","condition","maximum_condition","value","weight_kg","weight_nanokg","state"]:
		result[field] = record.get(field)
	result = result.duplicate(true)
	if record.has("money"): result.money = record.money.duplicate(true)
	if contract.get("state_rule") == "set-content-v1":
		for field in contract.contents:
			if contract.contents[field] == "key-set": result.state.contents[field].sort()
	return result
func _now(owner: Object) -> Dictionary:
	var value: Variant = owner.collection_now()
	if not N.integer(value,0,9007199254740991): return failure("provider_failure","Native game milliseconds required.")
	return {"ok":true,"value":int(value)}
func _state_check(owner: Object, request: Dictionary, record: Dictionary, action: String) -> Dictionary:
	if record.has("money"): return _authority.get_ref().money.state_check(owner,request,record,action)
	var p := _policy(record)
	if not p.ok: return p
	var clock := _now(owner)
	if not clock.ok: return clock
	if record.state.expiry != 0 and record.state.expiry <= clock.value: return failure("expired")
	if action == "reference": return p
	if record.state.equipped: return failure("required_equipment_transition","Live equipment owner is not delivered.")
	if p.contract.provider == "builtin.ordinary-v1" and (record.state.quest or record.state.enchanted or not record.state.bindings.is_empty()): return failure("required_provider")
	if p.contract.provider != "builtin.ordinary-v1":
		var auth: Dictionary = _authority.get_ref().context(owner,request)
		if not auth.ok: return auth
		if record.stack_type not in auth.value.collections.types or p.contract.provider != auth.value.collections.provider: return failure("required_provider")
		var result := _provider_result(owner.collection_state({"session":request.session,"operation":request.request,"action":action,"type":record.stack_type,"contract":p.contract.duplicate(true),"record":record.duplicate(true)}))
		if not result.ok: return result.duplicate(true)
	return p
func _records(container: Dictionary, plan: Dictionary = {}) -> Array:
	var owner: RefCounted = _authority.get_ref()
	var result: Array = []
	var ids: Dictionary = _members.get(_key(container),{}).duplicate()
	for key in plan:
		var r: Dictionary = plan[key]
		if not r.is_empty() and r.custody.get("container") == container: ids[key] = true
	for key in ids:
		var r: Dictionary = plan.get(key,owner._possessions.get(key,{}))
		if not r.is_empty() and r.custody.get("container") == container: result.append(r.duplicate(true))
	result.sort_custom(func(a: Dictionary,b: Dictionary):
		if a.id.category != b.id.category: return a.id.category < b.id.category
		var ap: bool = str(a.id.number).begins_with("pending-")
		var bp: bool = str(b.id.number).begins_with("pending-")
		if ap != bp: return not ap
		if ap: return int(str(a.id.number).trim_prefix("pending-")) < int(str(b.id.number).trim_prefix("pending-"))
		return IDs.less(a.id,b.id))
	return result
func projection(owner: Object, request: Dictionary, container: Dictionary) -> Dictionary:
	var auth: Dictionary = _authority.get_ref().context(owner,request)
	if not auth.ok: return auth
	var c := _container(owner,request,container)
	if not c.ok: return c
	return {"ok":true,"collection":c.record,"entries":_records(container)}
func query(owner: Object, request: Dictionary, container: Dictionary, filters: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	if not authority._core.get_ref()._plain_data(filters,true): return failure("invalid_filter")
	for field in filters:
		if field not in ["profile","type","quest","enchanted","summoned_first"]: return failure("invalid_filter")
		if field in ["profile","type"]:
			if not filters[field] is String or not Policy.Paths.valid_id(filters[field]): return failure("invalid_filter")
		elif typeof(filters[field]) != TYPE_BOOL: return failure("invalid_filter")
	if filters.has("profile"):
		var profile: Dictionary = authority.definition(filters.profile)
		if not profile.ok or profile.record.value.kind != "template": return failure("missing_definition")
	if filters.has("type"):
		var type: Dictionary = authority.definitions.query(Policy.DOMAIN,"policies",filters.type)
		if not type.ok or type.record.value.kind != "type": return failure("missing_definition")
	var view := _container(owner,request,container)
	if not view.ok: return view
	if not authority._begin(request): return failure("busy")
	var clock := _now(owner)
	if not clock.ok: return authority._end(clock)
	var candidates: Array = []
	for key: String in _ordered[_key(container)]:
		var r: Dictionary = authority._possessions[key]
		if r.state.expiry != 0 and r.state.expiry <= clock.value: continue
		if filters.has("profile") and filters.profile != r.profile: continue
		if filters.has("type") and filters.type != r.stack_type: continue
		if not filters.get("quest",false) and r.state.quest: continue
		if not filters.get("enchanted",false) and r.state.enchanted: continue
		var valid := _policy(r)
		if not valid.ok: return authority._end(valid)
		candidates.append(r.duplicate(true))
		if not filters.get("summoned_first",false): break
	if filters.get("summoned_first",false):
		candidates.sort_custom(func(a: Dictionary,b: Dictionary):
			if a.state.summoned != b.state.summoned: return a.state.summoned
			if a.state.summoned and a.state.expiry != b.state.expiry: return a.state.expiry < b.state.expiry
			return IDs.less(a.id,b.id))
	if not authority.context(owner,request).ok: return authority._end(failure("stale_session"))
	return authority._end({"ok":true,"kind":"match" if not candidates.is_empty() else "no_match","record":{} if candidates.is_empty() else candidates[0].duplicate(true)})
func eligibility(owner: Object, request: Dictionary, id: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	var found: Dictionary = authority.inspect(request.session,id)
	if not found.ok: return found
	if not authority._begin(request): return failure("busy")
	return authority._end(_policy(found.record))

## Single mutation entry, request-scoped retained outcomes. No import/clear route.
func execute(owner: Object, request: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	if not auth.value.has("collections"): return failure("unauthorized")
	if not Policy.Paths.valid_id(request.get("request","")): return failure("invalid_request")
	var key: String = str(owner.get_instance_id())+":"+request.context+":"+request.request
	if authority._receipts.has(key) or authority._generation.has(key) or authority.money.request_claimed(key): return failure("request_conflict")
	if _receipts.has(key):
		return _receipts[key].outcome.duplicate(true) if _receipts[key].input == request else failure("request_conflict")
	if _busy or not authority._begin(request): return failure("busy")
	_busy = true
	var result := _execute(owner,request,auth.value)
	# Terminal successful/partial results are retained before caller/observer reentry.
	if result.get("committed",false) and authority.context(owner,request).ok:
		_receipts[key] = {"input":request.duplicate(true),"outcome":result.duplicate(true)}
	_busy = false
	return authority._end(result)
func _execute(owner: Object, request: Dictionary, auth: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var action: Variant = request.get("action")
	var allowed := ["session","context","request","action"]
	match action:
		"create": allowed += ["name"]
		"insert","transfer","transfer_fitting": allowed += ["id","quantity","destination","mode","target"]
		"split","consume": allowed += ["id","quantity"]
		"batch": allowed += ["source","destination","batch_mode","mode"]
		"intake": allowed += ["type","profile","state","quantity"]
		_: return failure("unsupported")
	for field in request:
		if field not in allowed: return failure("invalid_request","Unknown field: "+field)
	if action == "create":
		if not Policy.Paths.valid_id(request.get("name","")): return failure("invalid_request")
		for c: Dictionary in _containers.values():
			if auth.has("capacity") and c.context == request.context and c.owner == auth.custody: return failure("duplicate_capacity_storage")
			if c.context == request.context and c.owner == auth.custody and c.name == request.name: return failure("duplicate_collection")
		var allocation: Dictionary = authority._allocator.allocate("container")
		if not allocation.ok: return allocation
		var c := {"id":allocation.id,"owner":auth.custody,"context":request.context,"name":request.name,"revision":1}
		_containers[_key(c.id)] = c
		_members[_key(c.id)] = {}
		_ordered[_key(c.id)] = []
		return {"ok":true,"committed":true,"kind":"created","collection":c.duplicate(true)}
	if action == "intake": return _intake(owner,request,auth)
	if action == "batch": return _batch(owner,request)
	if action == "transfer_fitting":
		var fitted := _maximum_fitting(owner,request)
		if not fitted.ok: return fitted
		if fitted.quantity == 0: return failure("admission_rejected")
		var result := _execute(owner,request.merged({"action":"transfer","quantity":fitted.quantity},true),auth)
		if result.get("committed",false):
			result.fitting = {"profile":"bounded_maximum_whole_v1","quantity":fitted.quantity,"requested":request.quantity}
		return result
	if not _valid_id(request.get("id")) or not N.integer(request.get("quantity"),1,LIMIT): return failure("invalid_quantity_or_identity")
	var found: Dictionary = authority.inspect(request.session,request.id)
	if not found.ok: return found
	var record: Dictionary = found.record
	var access_result := access(owner,request,record)
	if not access_result.ok: return access_result
	if request.quantity > record.quantity: return failure("unavailable_quantity")
	if action in ["split","consume"] and not record.custody.has("container"): return failure("missing_membership")
	var reference_only: bool = (action == "split" and request.quantity == record.quantity) or (action in ["insert","transfer"] and record.custody.get("container") == request.get("destination"))
	var checked := _state_check(owner,request,record,"reference" if reference_only else action)
	if not checked.ok: return checked
	if not authority.context(owner,request).ok: return failure("stale_session")
	if action == "split" and request.quantity == record.quantity: return {"ok":true,"committed":true,"kind":"unchanged","record":record.duplicate(true),"changes":[]}
	var plan := {}
	var categories: Array = []
	if action == "split":
		if not checked.eligible: return failure("unsupported_split")
		if checked.cap != 0 and record.quantity > checked.cap: return failure("requires_migration")
		var separated := record.duplicate(true)
		separated.id = {"category":record.id.category,"number":"pending-0"}
		separated.quantity = int(request.quantity)
		separated.revision = 1
		record.quantity -= int(request.quantity)
		record.revision += 1
		plan[_key(record.id)] = record
		plan[_key(separated.id)] = separated
		categories.append(record.id.category)
	elif action == "consume":
		if request.quantity != 1: return failure("invalid_quantity","One-unit quantity-only consumption.")
		record.quantity -= 1
		record.revision += 1
		plan[_key(record.id)] = record if record.quantity > 0 else {}
	else:
		if request.get("mode") not in ["automatic","target","no_stack"] or (request.mode == "target" and not _valid_id(request.get("target"))): return failure("invalid_mode")
		var destination := _container(owner,request,request.get("destination"))
		if not destination.ok: return destination
		if record.custody.get("container") == request.destination: return {"ok":true,"committed":true,"kind":"same_collection","changes":[]}
		if action == "insert" and record.custody.has("container"): return failure("already_admitted")
		if action == "transfer" and not record.custody.has("container"): return failure("missing_membership")
		var prepared := _move_plan(owner,request,record,destination.record,plan,categories)
		if not prepared.ok: return prepared
	return _commit(owner,request,plan,categories,action)

## Pure fitting query uses the exact same plan/admission interfaces. A bounded
## descending search supports arbitrary declared admission predicates without
## pretending they are monotonic. Exhaustion is explicit, never a false maximum.
func maximum_fitting(owner: Object, request: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	if not auth.value.has("collections"): return failure("unauthorized")
	if not authority._begin(request): return failure("busy")
	return authority._end(_maximum_fitting(owner,request))
func _maximum_fitting(owner: Object, request: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	if not _valid_id(request.get("id")) or not N.integer(request.get("quantity"),1,LIMIT): return failure("invalid_quantity_or_identity")
	var found: Dictionary = authority.inspect(request.session,request.id)
	if not found.ok: return found
	var record: Dictionary = found.record
	var reference_only: bool = record.custody.get("container") == request.get("destination")
	var access_result := access(owner,request,record)
	if not access_result.ok: return access_result
	if not record.custody.has("container"): return failure("missing_membership")
	var checked := _state_check(owner,request,record,"reference" if reference_only else "transfer")
	if not checked.ok: return checked
	var destination := _container(owner,request,request.get("destination"))
	if not destination.ok: return destination
	var quantity: int = mini(request.quantity,record.quantity)
	if request.get("mode") not in ["automatic","target","no_stack"] or (request.mode == "target" and not _valid_id(request.get("target"))): return failure("invalid_mode")
	if reference_only:
		if not authority.context(owner,request).ok: return failure("stale_session")
		return {"ok":true,"quantity":quantity,"profile":"bounded_maximum_whole_v1"}
	var revision: Variant = owner.collection_revision()
	if not N.integer(revision,0,9007199254740991): return failure("provider_failure")
	var capacity_bound := {}
	if destination.authorization.has("capacity"):
		var capacity: Dictionary = authority.capacity.projection(owner,request,request.destination)
		if not capacity.ok: return capacity
		capacity_bound = capacity
		var weight: Dictionary = authority.capacity.unit_weight(record,capacity.accounting)
		if not weight.ok: return weight
		if weight.value > 0: quantity = mini(quantity,maxi(0,capacity.capacity-capacity.load)/int(weight.value))
	var attempts := 0
	while quantity > 0:
		attempts += 1
		if attempts > MAX_PLAN_ENTRIES: return failure("fitting_search_limit")
		var plan := {}
		var categories: Array = []
		var trial: Dictionary = request.merged({"action":"transfer","quantity":quantity},true)
		var prepared := _move_plan(owner,trial,record,destination.record,plan,categories)
		if prepared.ok: prepared = _admit(owner,trial,plan)
		if prepared.ok: prepared = authority.capacity.validate(owner,trial,plan)
		if not authority.context(owner,request).ok: return failure("stale_session")
		if prepared.ok:
			var current_access := access(owner,request,record)
			if not current_access.ok: return current_access
			var current_state := _state_check(owner,request,record,"transfer")
			if not current_state.ok: return current_state
			if not authority.context(owner,request).ok: return failure("stale_session")
			if owner.collection_revision() != revision: return failure("stale_admission")
			if not capacity_bound.is_empty():
				var current: Dictionary = authority.capacity.projection(owner,request,request.destination)
				if current != capacity_bound: return failure("stale_capacity")
			return {"ok":true,"quantity":quantity,"profile":"bounded_maximum_whole_v1"}
		if prepared.get("kind") not in ["admission_rejected","cap_exceeded","unsupported_split","incompatible"]: return prepared
		quantity -= 1
	return {"ok":true,"quantity":0,"profile":"bounded_maximum_whole_v1"}

func _intake(owner: Object, request: Dictionary, auth: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var revision: Variant = owner.collection_revision()
	if not N.integer(revision,0,9007199254740991): return failure("provider_failure")
	if request.get("type") not in auth.collections.types or request.get("profile") not in auth.pool or not N.integer(request.get("quantity"),1,LIMIT): return failure("unauthorized_intake")
	var definition: Dictionary = authority._profile(request.profile)
	if not definition.ok: return definition
	var type: Dictionary = authority.definitions.query(Policy.DOMAIN,"policies",request.type)
	if not type.ok or type.record.value.provider != auth.collections.provider: return failure("required_provider")
	var reason := Policy.state_reason(request.get("state"),type.record.value)
	if not reason.is_empty(): return failure("unsupported_state",reason)
	var supplied := _provider_result(owner.collection_intake(request.duplicate(true)))
	if not supplied.ok: return supplied.duplicate(true)
	var properties: Variant = supplied.get("properties")
	if not properties is Dictionary or properties.size() != 7: return failure("unsupported_properties")
	for field in ["value","weight_microkg","condition","maximum_condition"]:
		if not N.integer(properties.get(field),0,1000000000): return failure("unsupported_properties")
	if properties.condition > properties.maximum_condition: return failure("unsupported_properties")
	for field in ["material","style","dye"]:
		if not properties.get(field) is String or (not properties[field].is_empty() and not Policy.Paths.valid_id(properties[field])): return failure("unsupported_properties")
	# Intake is a declared semantic provider grant, never inference from structural
	# potion/book/gold records. No visuals/currency/effects are fabricated here.
	var record := {"definition":definition.key,"profile":request.profile,"stack_type":request.type,"kind":request.type,"category":"semantic","material":properties.material,"style":properties.style,"dye":properties.dye,"condition":int(properties.condition),"maximum_condition":int(properties.maximum_condition),"value":int(properties.value),"weight_nanokg":int(properties.weight_microkg)*1000,"weight_kg":float(properties.weight_microkg)/1000000.0,"state":request.state.duplicate(true),"quantity":int(request.quantity),"identity_category":"stack","custody":{"owner":auth.custody,"context":request.context},"revision":1,"pending_consumers":["contents-runtime","capacity","tender","save"]}
	var checked := _state_check(owner,request,record,"intake")
	if not checked.ok: return checked
	if request.quantity > 1 and not checked.eligible: return failure("ineligible_quantity")
	if not authority.context(owner,request).ok: return failure("stale_session")
	if owner.collection_revision() != revision: return failure("stale_admission")
	var allocated: Dictionary = authority._allocator.allocate("stack")
	if not allocated.ok: return allocated
	record.id = allocated.id
	authority._possessions[_key(record.id)] = record.duplicate(true)
	return {"ok":true,"committed":true,"kind":"intake","record":record.duplicate(true)}

func _move_plan(owner: Object, request: Dictionary, record: Dictionary, destination: Dictionary, plan: Dictionary, categories: Array) -> Dictionary:
	var p := _policy(record)
	if not p.ok: return p
	var mode: Variant = request.get("mode")
	if mode not in ["automatic","target","no_stack"] or (mode == "target" and not _valid_id(request.get("target"))): return failure("invalid_mode")
	var quantity: int = int(request.quantity)
	if quantity < record.quantity and not p.eligible: return failure("unsupported_split")
	if p.cap != 0 and record.custody.has("container") and record.quantity > p.cap: return failure("requires_migration")
	var remaining := quantity
	var candidates := _records(destination.id,plan)
	if mode == "target":
		candidates = candidates.filter(func(r: Dictionary): return r.id == request.target)
		if candidates.is_empty(): return failure("missing_target")
	if mode != "no_stack":
		for candidate: Dictionary in candidates:
			var match_result := _compatible(record,candidate)
			if not match_result.ok: return match_result
			if not match_result.compatible:
				if mode == "target": return failure("incompatible")
				continue
			var state_result := _state_check(owner,request.merged({"context":destination.context},true),candidate,"merge")
			if not state_result.ok: return state_result
			var available: int = (LIMIT if p.cap == 0 else p.cap)-int(candidate.quantity)
			if p.cap == 0 and remaining > available: return failure("quantity_overflow")
			if mode == "target" and remaining > available: return failure("cap_exceeded")
			var fill := mini(remaining,maxi(0,available))
			if fill == 0: continue
			candidate.quantity += fill
			candidate.revision += 1
			plan[_key(candidate.id)] = candidate
			remaining -= fill
			if remaining == 0: break
	if mode == "target" and remaining > 0: return failure("incompatible")
	var original: Dictionary = record.duplicate(true)
	var full_move: bool = quantity == record.quantity
	if not full_move:
		original.quantity -= quantity
		original.revision += 1
		plan[_key(original.id)] = original
	else: plan[_key(original.id)] = {}
	var first := true
	if p.cap > 0 and (remaining+int(p.cap)-1)/int(p.cap) > MAX_PLAN_ENTRIES: return failure("plan_too_large")
	while remaining > 0:
		var entry := record.duplicate(true)
		entry.quantity = mini(remaining,LIMIT if p.cap == 0 else p.cap)
		if entry.quantity <= 0: return failure("invalid_cap")
		if not full_move or not first:
			entry.id = {"category":record.id.category,"number":"pending-"+str(categories.size())}
			categories.append(record.id.category)
			entry.revision = 1
		else: entry.revision += 1
		entry.custody = {"owner":destination.owner,"context":destination.context,"container":destination.id.duplicate(true)}
		plan[_key(entry.id)] = entry
		remaining -= entry.quantity
		first = false
	return {"ok":true}

func _admit(owner: Object, request: Dictionary, plan: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var affected := {}
	for key in plan:
		var old: Dictionary = authority._possessions.get(key,{})
		for r: Dictionary in [old,plan[key]]:
			if not r.is_empty() and r.custody.has("container"): affected[_key(r.custody.container)] = r.custody.container
	for id: Dictionary in affected.values():
		var c := _container(owner,request,id)
		if not c.ok: return c
		var result := _provider_result(owner.collection_admit({"session":request.session,"operation":request.request,"action":request.action,"collection":c.record.duplicate(true),"before":_records(id),"after":_records(id,plan)}))
		if not result.ok: return result.duplicate(true)
		if not authority.context(owner,request).ok: return failure("stale_session")
	return {"ok":true}
func _commit(owner: Object, request: Dictionary, plan: Dictionary, categories: Array, kind: String, guard := Callable()) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var capacity_before: Dictionary = authority.capacity.validate(owner,request,plan)
	if not capacity_before.ok: return capacity_before
	var revision: Variant = owner.collection_revision()
	if not N.integer(revision,0,9007199254740991): return failure("provider_failure")
	var admitted := _admit(owner,request,plan)
	if not admitted.ok: return admitted
	# Callback reentry is locked. Session, current state/expiry and each touched
	# collection are checked again after all staged provider work, before IDs burn.
	if not authority.context(owner,request).ok: return failure("stale_session")
	for key in plan:
		var r: Dictionary = authority._possessions.get(key,{})
		if not r.is_empty():
			var checked := _state_check(owner,request.merged({"context":r.custody.context},true),r,kind)
			if not checked.ok: return checked
	if not authority.context(owner,request).ok: return failure("stale_session")
	if owner.collection_revision() != revision: return failure("stale_admission")
	if guard.is_valid():
		var guarded := _provider_result(guard.call())
		if not guarded.ok: return guarded
		if not authority.context(owner,request).ok: return failure("stale_session")
	var capacity_after: Dictionary = authority.capacity.validate(owner,request,plan)
	if not capacity_after.ok: return capacity_after
	if capacity_after != capacity_before: return failure("stale_capacity")
	var allocated: Dictionary = authority._allocator.allocate_many(categories)
	if not allocated.ok: return allocated
	var finalized := {}
	for key in plan:
		var r: Dictionary = plan[key]
		if not r.is_empty() and str(r.id.number).begins_with("pending-"):
			r.id = allocated.ids[int(str(r.id.number).trim_prefix("pending-"))]
			finalized[_key(r.id)] = r
		else: finalized[key] = r
	var changes: Array = []
	var affected := {}
	for key in finalized:
		var old: Dictionary = authority._possessions.get(key,{})
		var next: Dictionary = finalized[key]
		if not old.is_empty() and old.custody.has("container"):
			_members[_key(old.custody.container)].erase(key)
			affected[_key(old.custody.container)] = true
		if next.is_empty(): authority._possessions.erase(key)
		else:
			authority._possessions[key] = next.duplicate(true)
			if next.custody.has("container"):
				_members[_key(next.custody.container)][key] = true
				affected[_key(next.custody.container)] = true
		changes.append({"id":old.id if next.is_empty() else next.id,"before":old.get("quantity",0),"after":next.get("quantity",0),"status":"retired" if next.is_empty() else ("new" if old.is_empty() else "surviving"),"custody":next.get("custody",old.get("custody",{})).duplicate(true)})
	for collection_key in affected:
		_containers[collection_key].revision += 1
		var keys: Array = _members[collection_key].keys()
		keys.sort_custom(func(left: String,right: String): return IDs.less(authority._possessions[left].id,authority._possessions[right].id))
		_ordered[collection_key] = keys
	_serial += 1
	return {"ok":true,"committed":true,"kind":kind,"serial":_serial,"changes":changes}

func _batch(owner: Object, request: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var source := _container(owner,request,request.get("source"))
	if not source.ok: return source
	var destination := _container(owner,request,request.get("destination"))
	if not destination.ok: return destination
	if request.get("batch_mode") not in ["atomic","stable_whole_entries_v1"] or request.get("mode") not in ["automatic","no_stack"]: return failure("invalid_batch_mode")
	if request.source == request.destination: return {"ok":true,"committed":true,"kind":"same_collection","changes":[]}
	var plan := {}
	var categories: Array = []
	var moved: Array = []
	var remaining: Array = []
	# Explicit take-what-fits profile: stable typed identity, whole entries only,
	# skip ordinary rejections, stop on technical failure. No partial final item.
	for record: Dictionary in _records(request.source):
		var local_request := request.merged({"context":source.record.context,"id":record.id,"quantity":record.quantity},true)
		var checked := _state_check(owner,local_request,record,"transfer")
		var trial := plan.duplicate(true)
		var trial_categories := categories.duplicate()
		var prepared: Dictionary = checked
		if checked.ok: prepared = _move_plan(owner,local_request,record,destination.record,trial,trial_categories)
		if prepared.ok and trial_categories.size() > MAX_PLAN_ENTRIES: prepared = failure("plan_too_large")
		if prepared.ok and request.batch_mode != "atomic": prepared = _commit(owner,local_request,trial,trial_categories,"transfer")
		if not prepared.ok:
			if request.batch_mode == "atomic": return prepared
			remaining.append({"id":record.id,"quantity":record.quantity,"reason":prepared.get("kind","provider_failure")})
			if prepared.get("kind") not in ["admission_rejected","unsupported_binding","expired","unsupported_split","incompatible","missing_target","cap_exceeded","quantity_overflow","requires_migration","plan_too_large","required_equipment_transition"]:
				# Remaining current source is authoritative; completed moves persist.
				var pending: Array = []
				for entry: Dictionary in _records(request.source):
					pending.append({"id":entry.id,"quantity":entry.quantity,"reason":prepared.kind if entry.id == record.id else "not_attempted"})
				return {"ok":false,"committed":true,"kind":"recovery_required","moved":moved,"remaining":pending,"failure":prepared}
			continue
		moved.append({"id":record.id,"quantity":record.quantity,"changes":prepared.get("changes",[])})
		if request.batch_mode == "atomic":
			plan = trial
			categories = trial_categories
	if request.batch_mode == "atomic":
		var result := _commit(owner,request,plan,categories,"atomic_batch")
		if result.ok: result.moved = moved
		return result
	return {"ok":true,"committed":true,"kind":"partial_batch" if not remaining.is_empty() else "batch_complete","moved":moved,"remaining":remaining}
