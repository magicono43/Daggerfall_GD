extends RefCounted
## ITEM participant only. SAVE owns transport and multi-owner coordination.
const VERSION := "item-state-v1"
const IDs = preload("res://scripts/item/identity_allocator.gd")
const A = preload("res://scripts/item/accounting.gd")
const State = preload("res://scripts/data/item_collections.gd")
var _authority: WeakRef
var _candidate := {}
var _serial := 0
var _busy := false
var _published := {}

func restore_ready(ticket: Dictionary) -> bool:
	return not _published.is_empty() and _published == ticket

func _init(authority: RefCounted) -> void:
	_authority = weakref(authority)

func failure(kind: String, reason: String) -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason}

func _bad_path(v: Variant, path := "", depth := 0) -> String:
	if depth > 32: return path+":depth"
	if v is Dictionary:
		for key in v:
			if not key is String: return path+":key-type="+str(typeof(key))
			if not _plain(v[key],0,[],[0]): return _bad_path(v[key],path+"/"+key,depth+1)
	elif v is Array:
		for i in v.size():
			if not _plain(v[i],0,[],[0]): return _bad_path(v[i],path+"/"+str(i),depth+1)
	return path+":type="+str(typeof(v))+":value="+str(v).left(200)

## Bounded JSON-compatible tree; reject cycles, opaque objects and unsafe numbers.
## JSON decoding itself remains transport-owned and must be bounded before use.
func _plain(v: Variant, depth := 0, parents: Array = [], budget: Array = [0], native_names := false) -> bool:
	budget[0] += 1
	if depth > 32 or budget[0] > 4000000: return false
	if v is Dictionary or v is Array:
		if v.size() > 65536: return false
		for parent in parents:
			if is_same(parent,v): return false
		var next := parents.duplicate()
		next.append(v)
		if v is Dictionary:
			for key in v:
				if (not key is String and not (native_names and key is StringName)) or str(key).length() > 1024 or not _plain(v[key],depth+1,next,budget,native_names): return false
		else:
			for entry in v:
				if not _plain(entry,depth+1,next,budget,native_names): return false
		return true
	match typeof(v):
		TYPE_NIL,TYPE_BOOL: return true
		TYPE_STRING: return v.length() <= 65536
		TYPE_STRING_NAME: return native_names and str(v).length() <= 65536
		TYPE_INT,TYPE_FLOAT: return is_finite(float(v)) and absf(float(v)) <= A.MAX
	return false

func _contexts() -> Dictionary:
	var result := {}
	for binding: Dictionary in _authority.get_ref()._contexts.values():
		if binding.owner.get_ref() == null: return {}
		for context: Dictionary in binding.contexts.values():
			result[context.custody+":"+context.id] = context.duplicate(true)
	return result

func _coordinator(owner: Object) -> bool:
	var authority: RefCounted = _authority.get_ref()
	var core: SessionLifecycle = authority._core.get_ref()
	return core != null and is_instance_valid(owner) and owner == core.provider

func _compatibility() -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var value: Dictionary = authority.definitions.item_persistence_compatibility()
	value.rules = authority._core.get_ref().formulas.item_persistence_compatibility()
	var adapter: RefCounted = authority.definitions._adapters.get(preload("res://scripts/data/item_capacity_tender.gd").DOMAIN,{}).get("adapter")
	value.money_providers = adapter.persistence_providers() if adapter != null else {}
	return _encoded(value)

## Runtime scope is normalized only in explicit participant envelope fields. No
## Object ID, WeakRef, callback or request capability crosses this boundary.
func _encoded(v: Variant) -> Variant:
	if v is Dictionary:
		var result := {}
		for key in v:
			var encoded_key: Variant = str(key) if typeof(key) in [TYPE_STRING,TYPE_STRING_NAME] else key
			result[encoded_key] = _encoded(v[key])
		return result
	if v is Array:
		var result: Array = []
		for entry in v: result.append(_encoded(entry))
		return result
	return str(v) if v is StringName else v

func _scope_values(receipts: Dictionary, scope: String) -> Dictionary:
	var result: Dictionary = _encoded(receipts)
	for receipt: Dictionary in result.values():
		if receipt.get("input") is Dictionary and receipt.input.has("session"): receipt.input.session = scope
		for field in ["outcome","terminal"]:
			if receipt.get(field) is Dictionary and receipt[field].has("session"): receipt[field].session = scope
	return result

func _money_records() -> Dictionary:
	var records: Dictionary = _scope_values(_authority.get_ref().money._receipts,"")
	for receipt: Dictionary in records.values():
		if receipt.has("accepted"):
			receipt.erase("accepted") # UI plan, pending placeholders and load caches.
			receipt.recovery = "econ-ack-v1"
	return records

func capture(owner: Object, scope: String, references: Array = []) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var core: SessionLifecycle = authority._core.get_ref()
	if not _coordinator(owner) or not core.formula_owner_valid(scope,authority,"item.value"): return failure("unauthorized","Capture requires the current composed coordinator and ready ITEM scope.")
	if _busy or not authority._operation.is_empty() or authority.collections._busy: return failure("busy","Capture requires a settled ITEM boundary.")
	if not _plain(references,0,[],[0],true): return failure("invalid_reference","Bounded plain reference records required.")
	_busy = true
	authority._begin({"session":scope,"request":"item-capture"})
	var sources := _source_context(scope)
	var still_current := core.formula_owner_valid(scope,authority,"item.value")
	authority._end({})
	_busy = false
	if not sources.ok: return sources
	if not still_current: return failure("stale_session","Scope retired during capture context callbacks.")
	var payload := {"schema":VERSION,"compatibility":_compatibility(),"units":{"weight":"nanokg","identity":"uint64-decimal"},"counters":authority._allocator.projection(),"contexts":_contexts(),"source_context":sources.value,"possessions":authority._possessions.values().duplicate(true),"containers":authority.collections._containers.values().duplicate(true),"construction":_scope_values(authority._receipts,""),"generation":_scope_values(authority._generation,""),"collections":_scope_values(authority.collections._receipts,""),"money":_money_records(),"quotes":authority.money._committed_quotes.duplicate(true),"collection_serial":authority.collections._serial,"references":references.duplicate(true)}
	payload = _encoded(payload)
	var checked := _validate(payload)
	if not checked.ok:
		checked.fields = payload.size()
		checked.non_plain = []
		for field in payload:
			if not _plain(payload[field],0,[],[0]): checked.non_plain.append(_bad_path(payload[field],field))
		return checked
	return {"ok":true,"payload":payload}

func _source_context(scope: String) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var result := {}
	for binding: Dictionary in authority._contexts.values():
		var owner: Object = binding.owner.get_ref()
		if owner == null: return failure("missing_provider","A required requester retired.")
		for context: Dictionary in binding.contexts.values():
			var value := {}
			if context.has("collections"):
				var now: Variant = owner.collection_now()
				if not A.integer(now): return failure("invalid_clock","Authoritative restored game-millisecond context required.")
				value.instant = now
			if context.has("capacity") and context.capacity.kind == "wagon":
				var spatial: Dictionary = authority.capacity._context(owner,{"session":scope,"context":context.id},context.capacity)
				if not spatial.ok: return spatial
				var w: Dictionary = spatial.wagon
				if w.get("wagon") != context.capacity.wagon or w.get("exit") != context.capacity.exit or not w.get("context_id") is String: return failure("wagon_identity_changed","Original wagon/exit/context must remain bound.")
				var accessed: Dictionary = authority.capacity.access(context.capacity,spatial)
				if not accessed.ok and accessed.get("kind") not in ["wagon_unavailable","wagon_out_of_reach","wagon_interior_denied","wagon_exit_unavailable"]: return accessed
				value.wagon = {"wagon":w.wagon,"exit":w.exit,"context_id":w.context_id}
			elif context.has("capacity"):
				var actor: Dictionary = authority._core.get_ref().actors.capacity_projection(scope,context.capacity.actor)
				if not actor.ok: return failure("required_sources_failed","Reconstruct required CHAR sources before ITEM derived readiness.")
				var current: Dictionary = authority.capacity._context(owner,{"session":scope,"context":context.id},context.capacity)
				if not current.ok: return current
				var capacity := A.signed_add(actor.kg,current.bonus)
				if not capacity.ok or capacity.value < 0: return failure("invalid_capacity","Selected capacity/modifiers are invalid.")
				var policy: Dictionary = authority.capacity.policy(context.capacity.profile,"capacity")
				if not policy.ok: return policy
				var accounting: Dictionary = authority.capacity.policy(policy.value.accounting,"accounting")
				if not accounting.ok: return accounting
				if not A.multiply(capacity.value,1000000000/int(accounting.value.quantum_nanokg)).ok: return failure("invalid_capacity","Selected capacity exceeds its declared accounting precision.")
			result[context.custody+":"+context.id] = value
	return {"ok":true,"value":result}

func _id(id: Variant, category: String, counters: Dictionary) -> bool:
	if not id is Dictionary or id.size() != 2 or id.get("category") not in (["item","stack"] if category.is_empty() else [category]) or not IDs.valid(id.get("number")): return false
	var high: String = counters[id.category]
	return id.number.length() < high.length() or (id.number.length() == high.length() and id.number <= high)

func _custody(v: Variant, contexts: Dictionary) -> bool:
	return v is Dictionary and v.get("owner") is String and v.get("context") is String and contexts.has(v.owner+":"+v.context)

func _claims(v: Variant, counters: Dictionary) -> bool:
	if v is Dictionary:
		if v.has("category") and v.has("number"):
			return _id(v,"container" if v.category == "container" else "",counters)
		for key in v:
			# These are definition/property payloads, never persistent-ID claims.
			# Mod content may legitimately use fields named category and number.
			if key in ["state","provenance","visual","definition","compatibility"]: continue
			if not _claims(v[key],counters): return false
	elif v is Array:
		for entry in v:
			if not _claims(entry,counters): return false
	return true

func _record(r: Variant, p: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	if not r is Dictionary or not _id(r.get("id"),"",p.counters) or r.get("identity_category") != r.id.category: return failure("invalid_identity","Possession requires a typed identity at or below its high-water mark.")
	for field in ["quantity","revision","condition","maximum_condition","value","weight_nanokg"]:
		if not A.integer(r.get(field),1 if field in ["quantity","revision"] else 0,2147483647 if field == "quantity" else A.MAX): return failure("invalid_record","Invalid possession field: "+field)
	if r.condition > r.maximum_condition or not _custody(r.get("custody"),p.contexts) or r.custody.size() not in [2,3]: return failure("invalid_custody","Condition or custody is invalid.")
	for field in r.custody:
		if field not in ["owner","context","container"]: return failure("invalid_custody","Unknown custody authority field.")
	if not r.get("weight_kg") is float and not r.get("weight_kg") is int: return failure("invalid_units","Explicit kg projection required.")
	if absf(float(r.weight_kg)-float(r.weight_nanokg)/1000000000.0) > 0.0000000005: return failure("invalid_units","Physical weight projections disagree.")
	for field in ["profile","kind","category","stack_type","material","style","dye"]:
		if not r.get(field) is String: return failure("invalid_record","Missing typed field: "+field)
	if not r.get("state") is Dictionary: return failure("invalid_state","Explicit durable per-unit state required.")
	if not r.get("pending_consumers") is Array: return failure("invalid_record","Explicit consumer diagnostic state required.")
	if r.has("money"):
		var m: Variant = r.money
		if not m is Dictionary or m.get("form") not in ["coin","letter"]: return failure("invalid_money","Unsupported monetary instrument.")
		var policy: Dictionary = authority.capacity.policy(r.profile,"denomination" if m.form == "coin" else "letter")
		if not policy.ok or r.get("definition") != policy.identity or m.get("profile") != r.profile or m.get("unit") != policy.value.unit or m.get("provenance") != policy.value.provenance or r.weight_nanokg != policy.value.nanokg: return failure("incompatible_money","Required denomination/issuer/weight definition differs.")
		if r.state != State.ordinary_state() or r.kind != "money" or r.stack_type != "money" or r.category != "semantic": return failure("invalid_money","Monetary state requires its supported owner representation.")
		if m.form == "coin":
			if m.size() != 5 or r.id.category != "stack" or m.get("value") != policy.value.value: return failure("invalid_money","Invalid denomination count/value.")
		else:
			if m.size() != 8 or r.id.category != "item" or r.quantity != 1 or not A.integer(m.get("remaining"),1) or m.get("issuer") != policy.value.issuer or m.get("provider") != policy.value.provider or m.get("version") != preload("res://scripts/data/item_capacity_tender.gd").VERSION: return failure("invalid_money","Invalid letter identity/issuer/face/provider version.")
	else:
		var profile: Dictionary = authority._profile(r.profile)
		if not profile.ok or r.get("definition") != profile.key: return failure("missing_definition","Required original definition identity is unavailable: "+r.profile)
		if r.category == "semantic":
			# The category sentinel alone is not a representation contract. Match the
			# actual semantic intake shape before omitting construction references.
			if r.kind != r.stack_type or r.identity_category != "stack" or r.has("body") or r.has("visual"): return failure("invalid_record","Conflicting semantic kind/type/identity or construction appearance.")
			if int(r.weight_nanokg)%1000 != 0: return failure("invalid_units","Semantic weight must retain its exact microkg intake boundary.")
			var properties := {"value":r.value,"weight_microkg":int(r.weight_nanokg)/1000,"condition":r.condition,"maximum_condition":r.maximum_condition,"material":r.material,"style":r.style,"dye":r.dye}
			var property_reason := State.semantic_properties_reason(properties)
			if not property_reason.is_empty(): return failure("invalid_record",property_reason)
		else:
			var template: Dictionary = profile.profile
			if not r.get("body") is String or r.body not in template.bodies or r.kind != template.type or not template.styles.has(r.category) or not template.styles[r.category].has(r.style) or r.dye not in template.dyes or not r.get("visual") is Dictionary: return failure("invalid_reference","Required body/style/visual definition is missing or incompatible.")
			if r.identity_category != template.identity or r.stack_type != ("arrow" if r.kind == "ammo" else r.kind): return failure("invalid_reference","Required template identity/stack category differs.")
			var appearance: Dictionary = authority.definition("policy")
			if not appearance.ok or not appearance.record.value.dye_adapters.has(r.dye): return failure("missing_definition","Required dye projection unavailable.")
			var material_mode: bool = r.category == "weapon" or appearance.record.value.categories.get(r.category,{}).get("mode") == "material"
			if material_mode:
				var material: Dictionary = authority.definition(r.material)
				if r.material not in template.materials or not material.ok or material.record.value.kind != "material": return failure("missing_definition","Required compatible material definition unavailable.")
			elif not r.material.is_empty(): return failure("invalid_reference","Neutral construction cannot retain a material binding.")
			var variant: int = int(template.styles[r.category][r.style])
			var visual := {"provider":template.visual.provider,"archive":int(template.visual.archives[r.body]),"record":int(template.visual.record)+variant,"variant":variant,"dye_adapter":appearance.record.value.dye_adapters[r.dye]}
			if not preload("res://scripts/data/actor_input_formats.gd").equal_input(r.visual,visual): return failure("invalid_reference","Visual projection differs from authoritative body/style/dye definitions.")
		var policy: Dictionary = authority.definitions.query(State.DOMAIN,"policies",r.stack_type)
		if not policy.ok or policy.record.value.kind != "type": return failure("missing_provider","Required stack/state type provider unavailable.")
		var reason := State.state_reason(r.state,policy.record.value)
		if not reason.is_empty(): return failure("invalid_state",reason)
	return {"ok":true}

func _validate(p: Variant) -> Dictionary:
	if not _plain(p,0,[],[0]) or not p is Dictionary or p.size() != 15 or p.get("schema") != VERSION: return failure("unsupported_schema","Bounded complete item-state-v1 required; no legacy migration is registered.")
	var authority: RefCounted = _authority.get_ref()
	if p.get("compatibility") != _compatibility(): return failure("incompatible_content","Required ITEM definitions/providers differ; an explicit migration is required.")
	if p.get("units") != {"weight":"nanokg","identity":"uint64-decimal"}: return failure("invalid_units","Unsupported physical/identity units.")
	if not p.get("counters") is Dictionary or p.counters.size() != 3: return failure("invalid_identity","All three high-water counters required.")
	for category in ["item","stack","container"]:
		if not IDs.valid(p.counters.get(category),true): return failure("invalid_identity","Counter must be canonical unsigned decimal: "+category)
	for field in ["contexts","source_context","construction","generation","collections","money","quotes"]:
		if not p.get(field) is Dictionary: return failure("invalid_payload","Missing explicit dictionary: "+field)
	for field in ["possessions","containers","references"]:
		if not p.get(field) is Array: return failure("invalid_payload","Missing explicit records: "+field)
	if not _claims(p,p.counters): return failure("invalid_identity","Live or retired retained identity exceeds its category counter.")
	if not A.integer(p.get("collection_serial")): return failure("invalid_payload","Collection serial required.")
	for key in p.contexts:
		var context: Variant = p.contexts[key]
		if not context is Dictionary or not State.Paths.valid_id(context.get("id","")) or not State.Paths.valid_id(context.get("custody","")) or key != context.custody+":"+context.id: return failure("invalid_custody","Malformed durable requester claim.")
		if context.size() not in [5,6,7,8] or not context.get("pool") is Array or typeof(context.get("worn")) != TYPE_BOOL or typeof(context.get("copy")) != TYPE_BOOL: return failure("invalid_custody","Complete typed requester declaration required.")
		for field in context:
			if field not in ["id","custody","pool","worn","copy","collections","capacity","money"]: return failure("invalid_custody","Unknown requester declaration field.")
		if context.has("collections") and (not context.collections is Dictionary or context.collections.size() != 2 or not State.Paths.valid_id(context.collections.get("provider","")) or not context.collections.get("types") is Array): return failure("invalid_custody","Complete collection provider declaration required.")
		if context.has("money"):
			if not context.has("collections") or not context.money is Dictionary or context.money.size() != 4 or not State.Paths.valid_id(context.money.get("provider","")) or not State.Paths.valid_id(context.money.get("profile","")) or not context.money.get("coins") is Array or not context.money.get("letters") is Array: return failure("invalid_money","Complete money provider declaration required.")
		if context.has("capacity"):
			if not context.has("collections") or not context.capacity is Dictionary or context.capacity.size() != 6 or context.capacity.get("kind") not in ["carried","wagon"]: return failure("invalid_custody","Typed capacity identity declaration required.")
			for field in ["profile","actor","access","wagon","exit"]:
				if not context.capacity.get(field) is String: return failure("invalid_custody","Typed capacity identity declaration required.")
		var source: Variant = p.source_context.get(key)
		if not source is Dictionary or (context.has("collections") and not A.integer(source.get("instant"))): return failure("invalid_clock","Saved provider game-time context required.")
		if context.has("capacity") and context.capacity.kind == "wagon" and (not source.get("wagon") is Dictionary or source.wagon.get("wagon") != context.capacity.wagon or source.wagon.get("exit") != context.capacity.exit or not source.wagon.get("context_id") is String): return failure("wagon_identity_changed","Saved original wagon/context binding required.")
	var containers := {}
	var storage_claims := {}
	for c in p.containers:
		if not c is Dictionary or c.size() != 5 or not _id(c.get("id"),"container",p.counters) or not _custody(c,p.contexts) or not State.Paths.valid_id(c.get("name","")) or not A.integer(c.get("revision"),1): return failure("invalid_custody","Invalid container identity/custodian.")
		var key: String = authority._id_key(c.id)
		if containers.has(key): return failure("duplicate_identity","Duplicate container claim: "+key)
		var claim: String = c.owner+":"+c.context
		var name_claim: String = claim+":"+c.name
		if storage_claims.has(name_claim) or (p.contexts[claim].has("capacity") and storage_claims.has(claim)): return failure("invalid_custody","Conflicting collection name or authoritative capacity storage.")
		storage_claims[claim] = true
		storage_claims[name_claim] = true
		containers[key] = c
	var possessions := {}
	var loads := {}
	for r in p.possessions:
		var checked := _record(r,p)
		if not checked.ok: return checked
		var key: String = authority._id_key(r.id)
		if possessions.has(key): return failure("duplicate_identity","Duplicate possession claim: "+key)
		possessions[key] = r
		if r.custody.has("container"):
			if not _id(r.custody.container,"container",p.counters): return failure("invalid_custody","Invalid container reference.")
			var c: Dictionary = containers.get(authority._id_key(r.custody.container),{})
			if c.is_empty() or c.owner != r.custody.owner or c.context != r.custody.context: return failure("invalid_custody","Missing/conflicting authoritative membership.")
			var collection_key: String = authority._id_key(c.id)
			if not loads.has(collection_key): loads[collection_key] = []
			loads[collection_key].append(r)
	for key in containers:
		var c: Dictionary = containers[key]
		var context: Dictionary = p.contexts[c.owner+":"+c.context]
		if not context.has("capacity"): continue
		var policy: Dictionary = authority.capacity.policy(context.capacity.profile,"capacity")
		if not policy.ok: return policy
		var accounting: Dictionary = authority.capacity.policy(policy.value.accounting,"accounting")
		if not accounting.ok: return accounting
		var load: Dictionary = authority.capacity.total_load(loads.get(key,[]),accounting.value)
		if not load.ok: return failure(load.get("kind","invalid_units"),"Saved physical load is incompatible with its declared precision/accounting.")
	var operations := {}
	for field in ["construction","generation","collections","money"]:
		for key in p[field]:
			var receipt: Variant = p[field][key]
			if not receipt is Dictionary or not receipt.get("input") is Dictionary: return failure("invalid_operation","Malformed retained operation.")
			if operations.has(key) and not (field == "generation" and p.construction.has(key) and receipt.get("terminal") == p.construction[key].outcome): return failure("invalid_operation","Conflicting retained operation identity.")
			operations[key] = true
			var input: Dictionary = receipt.input
			var claim: String = key.get_slice(":",0)+":"+key.get_slice(":",1)
			if not p.contexts.has(claim) or input.get("session") != "" or input.get("context") != key.get_slice(":",1) or not State.Paths.valid_id(input.get("request","")) or key != claim+":"+input.request: return failure("invalid_operation","Durable request does not match its custody/context identity.")
			if field == "generation":
				if not receipt.get("terminal") is Dictionary or receipt.terminal.is_empty(): return failure("unsupported_pending","Pending generation cannot capture until its owner reaches a retained terminal result.")
				if receipt.size() != 4 or not receipt.get("decisions") is Dictionary or not receipt.get("draws") is Dictionary: return failure("invalid_operation","Complete retained generation decisions/draws required.")
				if not p.construction.has(key) or receipt.terminal != p.construction[key].outcome: return failure("invalid_operation","Completed generation must retain its original construction fact.")
			else:
				if not receipt.get("outcome") is Dictionary: return failure("invalid_operation","Retained committed outcome required.")
				if receipt.outcome.has("serial") and not A.integer(receipt.outcome.serial,1,int(p.collection_serial)): return failure("invalid_operation","Collection high water is below a retained commitment serial.")
				if receipt.outcome.get("kind") == "recovery_required" and field != "money": return failure("unsupported_pending","Collection recovery requires its unavailable continuation owner.")
				if receipt.size() != (3 if field == "money" and receipt.has("recovery") else 2): return failure("invalid_operation","Unsupported durable receipt fields; transient plans are not accepted.")
				if field in ["construction","money"] and not receipt.has("recovery"):
					var checked := _record(receipt.outcome.get("record"),p)
					if not checked.ok: return checked
				if field == "collections" and (receipt.outcome.get("committed") != true or not receipt.outcome.get("kind") is String): return failure("invalid_operation","Committed collection outcome required.")
	for quote in p.quotes:
		var receipt: Dictionary = p.money.get(p.quotes[quote],{})
		if receipt.is_empty() or receipt.get("recovery") != "econ-ack-v1" or not receipt.outcome.get("quote") is Dictionary or quote != receipt.outcome.quote.get("provider","")+":"+receipt.outcome.quote.get("id",""): return failure("invalid_money","Committed quote is missing its exact retained settlement.")
	for receipt: Dictionary in p.money.values():
		if receipt.has("recovery"):
			if receipt.recovery != "econ-ack-v1": return failure("unsupported_pending","Unsupported recovery participant version.")
			if not receipt.outcome.get("obligations") is Array or receipt.outcome.obligations not in [[],["econ-acknowledgment"]]: return failure("unsupported_pending","Unsupported monetary recovery phase.")
			var q: Variant = receipt.outcome.get("quote")
			if not q is Dictionary or not p.quotes.has(str(q.get("provider",""))+":"+str(q.get("id",""))): return failure("invalid_money","Missing committed quote claim.")
			var adapter: RefCounted = authority.definitions._adapters.get(preload("res://scripts/data/item_capacity_tender.gd").DOMAIN,{}).get("adapter")
			if not receipt.outcome.obligations.is_empty() and (adapter == null or not adapter.supports(q.provider,"recovery-v1")): return failure("unsupported_pending","ECON provider must declare durable idempotent recovery-v1 acknowledgment support.")
			var checked := _settlement(receipt,p)
			if not checked.ok: return checked
	var refs := {}
	var linked_claims := {}
	for ref in p.references:
		if not ref is Dictionary or ref.size() != 5 or ref.get("kind") not in ["equipment","light","quest","service","effect"] or not State.Paths.valid_id(ref.get("owner","")) or not State.Paths.valid_id(ref.get("slot","")) or not _id(ref.get("item"),"",p.counters) or not ref.get("custody") is Dictionary: return failure("invalid_reference","Typed owner/slot/item/custody reference required.")
		var r: Dictionary = possessions.get(authority._id_key(ref.item),{})
		var key: String = ref.kind+":"+ref.owner+":"+ref.slot
		if r.is_empty() or r.custody != ref.custody or refs.has(key): return failure("invalid_reference","Required reference is missing, conflicts or names foreign custody.")
		refs[key] = true
		linked_claims[authority._id_key(ref.item)+":"+ref.kind] = true
		linked_claims[authority._id_key(ref.item)+":"+ref.kind+":"+ref.owner] = true
	for r: Dictionary in p.possessions:
		var item_key: String = authority._id_key(r.id)
		if r.state.get("equipped",false) and not linked_claims.has(item_key+":equipment"): return failure("invalid_reference","Equipped possession requires its equipment participant reference.")
		for kind in r.state.bindings:
			if kind not in ["equipment","light","quest","service","effect"] or not linked_claims.has(item_key+":"+kind+":"+r.state.bindings[kind]): return failure("invalid_reference","Required durable binding needs its explicit supported owner reference: "+kind)
	return {"ok":true}

func _settlement(receipt: Dictionary, p: Dictionary) -> Dictionary:
	var outcome: Dictionary = receipt.outcome
	var q: Dictionary = outcome.quote
	var operation: Variant = outcome.get("operation")
	if not operation is Dictionary or not State.Paths.valid_id(operation.get("custody","")): return failure("invalid_money","Stable settlement custody required.")
	var context: Dictionary = p.contexts.get(operation.custody+":"+receipt.input.context,{})
	if not context.get("money") is Dictionary or operation != {"schema":"item-tender-operation-v1","custody":context.custody,"context":receipt.input.context,"request":receipt.input.request,"provider":context.money.provider}: return failure("invalid_money","Exact durable settlement identity/provider required.")
	if not _authority.get_ref().money.quote_valid(q,context.money.provider): return failure("invalid_money","Complete original committed quote required.")
	for field in ["recipient","destination"]:
		if not _id(q[field],"container",p.counters): return failure("invalid_money","Typed retained settlement container required.")
	for source in q.sources:
		if not _id(source,"container",p.counters): return failure("invalid_money","Typed retained tender source required.")
	var outputs := {}
	for group in ["outputs","change"]:
		for output in q[group]:
			if not output is Dictionary or output.size() != 2 or not _id(output.get("id"),"",p.counters) or not A.integer(output.get("quantity"),1,2147483647): return failure("invalid_money","Typed retained delivery/change entry required.")
			var key: String = _authority.get_ref()._id_key(output.id)
			if outputs.has(key): return failure("invalid_money","Conflicting retained delivery/change claim.")
			outputs[key] = true
	for field in ["id","provider","region","institution","unit"]:
		if not State.Paths.valid_id(q.get(field,"")): return failure("invalid_money","Invalid quote identity/unit.")
	for field in ["price","fees","revision","coin_offer"]:
		if not A.integer(q.get(field)): return failure("invalid_money","Invalid quote amount/revision.")
	if not A.integer(outcome.get("coin_debit")) or not A.integer(outcome.get("change_value")) or not outcome.get("face_debits") is Array or not q.get("rates") is Array: return failure("invalid_money","Exact committed debit/change facts required.")
	var retained_rates: Array = []
	if not outcome.face_debits.is_empty():
		for rate_id: String in q.rates:
			var resolved: Dictionary = _authority.get_ref().capacity.policy(rate_id,"rate")
			if not resolved.ok: return failure("missing_definition","Required retained valuation definition is unavailable.")
			retained_rates.append(resolved.value)
	var local: int = int(outcome.coin_debit)
	for debit in outcome.face_debits:
		if not debit is Dictionary or debit.size() != 6 or not _id(debit.get("id"),"item",p.counters) or not A.integer(debit.get("face"),1) or not A.integer(debit.get("local"),1) or debit.get("local_unit") != q.unit or not debit.get("rate") is Dictionary: return failure("invalid_money","Invalid retained face debit/local credit.")
		var rate: Dictionary = debit.rate
		if not retained_rates.any(func(value: Dictionary): return preload("res://scripts/data/actor_input_formats.gd").equal_input(value,rate)): return failure("invalid_money","Retained valuation provenance differs from its required definition.")
		if rate.get("local_unit") != q.unit or rate.get("face_unit") != debit.get("face_unit") or rate.get("provider") != q.provider or not A.integer(rate.get("numerator"),1) or not A.integer(rate.get("denominator"),1): return failure("invalid_money","Retained rate/unit/provider mismatch.")
		var face := A.multiply(int(debit.face),int(rate.numerator))
		var credit := A.multiply(int(debit.local),int(rate.denominator))
		if not face.ok or not credit.ok or face.value != credit.value: return failure("invalid_money","Retained exact rational valuation does not conserve value.")
		var sum := A.add(local,int(debit.local))
		if not sum.ok: return sum
		local = sum.value
	var required := A.add(int(q.price),int(q.fees))
	if not required.ok: return required
	required = A.add(required.value,int(outcome.change_value))
	if not required.ok or local != required.value: return failure("invalid_money","Committed tender does not conserve price/fees/change.")
	return {"ok":true}

## Called during real CORE load preflight, before outgoing scope retirement.
func prepare(owner: Object, ticket: Dictionary, payload: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var core: SessionLifecycle = authority._core.get_ref()
	if not _coordinator(owner) or ticket != core.ticket() or core.snapshot().phase != "preflight" or core.last_intent.get("mode") != "load": return failure("stale_session","Exact active CORE load preflight required.")
	if _busy: return failure("busy","Participant is busy.")
	var checked := _validate(payload)
	if not checked.ok: return checked
	_serial += 1
	_candidate = {"token":_serial,"ticket":ticket.duplicate(true),"content":authority.definitions.content_ticket(),"payload":payload.duplicate(true),"owner":weakref(owner)}
	return {"ok":true,"candidate":_serial}

## Register detached records, link and validate all participant results first.
## One callback-free publication replaces ITEM only; CORE owns failure recovery.
func publish(owner: Object, ticket: Dictionary, token: int, links: Object) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var core: SessionLifecycle = authority._core.get_ref()
	if _busy: return failure("busy","Participant publication is not reentrant.")
	if _candidate.is_empty() or token != _candidate.token or not _coordinator(owner) or _candidate.owner.get_ref() != owner or ticket != core.ticket() or core.snapshot().phase != "initializing" or ticket.id != _candidate.ticket.id or ticket.generation != _candidate.ticket.generation or authority.definitions.content_ticket() != _candidate.content or authority._scope != ticket.scope: return failure("stale_candidate","Prepared ITEM input no longer belongs to this content/load/scope.")
	var p: Dictionary = _candidate.payload
	_candidate = {} # Single use even when required participant linking fails.
	if p.contexts != _contexts(): return failure("missing_provider","Replacement requester/capacity/provider declarations do not match saved custody.")
	if not is_instance_valid(links) or not A.signature(links,"item_restore_links",1,TYPE_DICTIONARY): return failure("missing_provider","Explicit required link/clock/source participant required.")
	_busy = true
	var result := _publish(p,ticket,links)
	_busy = false
	return result

func _publish(p: Dictionary, ticket: Dictionary, links: Object) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var core: SessionLifecycle = authority._core.get_ref()
	var possessions := {}
	var containers := {}
	var members := {}
	var ordered := {}
	for c: Dictionary in p.containers:
		var key: String = authority._id_key(c.id)
		containers[key] = c.duplicate(true)
		members[key] = {}
		ordered[key] = []
	for r: Dictionary in p.possessions:
		var key: String = authority._id_key(r.id)
		possessions[key] = r.duplicate(true)
		if r.custody.has("container"): members[authority._id_key(r.custody.container)][key] = true
	for key in members:
		ordered[key] = members[key].keys()
		ordered[key].sort_custom(func(a: String,b: String): return IDs.less(possessions[a].id,possessions[b].id))
	var response: Variant = links.item_restore_links({"session":ticket.scope,"references":p.references.duplicate(true),"possessions":p.possessions.duplicate(true),"contexts":p.contexts.duplicate(true)})
	if not _plain(response,0,[],[0],true) or response != {"ok":true,"clock_ready":true,"references_ready":true,"sources_ready":true}: return failure("required_links_failed","Clock, reference and derived-source participants must report complete readiness.")
	var sources := _source_context(ticket.scope)
	if not sources.ok: return sources
	if sources.value != p.source_context: return failure("source_context_changed","Restore original authoritative clock/wagon context before ITEM readiness.")
	if ticket != core.ticket() or core.snapshot().phase != "initializing" or authority._scope != ticket.scope: return failure("stale_session","Load was retired during participant linking.")
	# No callbacks, admission, grants, RNG, equip/use or payment below this point.
	authority._possessions = possessions
	authority._allocator = IDs.new(p.counters)
	authority._receipts = _scope_values(p.construction,ticket.scope)
	authority._generation = _scope_values(p.generation,ticket.scope)
	authority.collections._containers = containers
	authority.collections._members = members
	authority.collections._ordered = ordered
	authority.collections._receipts = _scope_values(p.collections,ticket.scope)
	authority.collections._serial = int(p.collection_serial)
	authority.collections._policies.clear()
	authority.capacity.retire()
	authority.money._receipts = _scope_values(p.money,ticket.scope)
	authority.money._committed_quotes = p.quotes.duplicate(true)
	_published = ticket.duplicate(true)
	return {"ok":true,"schema":VERSION,"possessions":possessions.size(),"containers":containers.size(),"references":p.references.size()}

## Recovery retries only ECON acknowledgment of an already committed ITEM plan.
func recover_money(owner: Object, request: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	var key: String = authority.operation_key(owner,request)
	if not authority.money._receipts.has(key) or (not authority.money._receipts[key].has("accepted") and authority.money._receipts[key].get("recovery") != "econ-ack-v1"): return failure("missing_operation","No retained committed tender for this authorized requester.")
	var receipt: Dictionary = authority.money._receipts[key]
	if receipt.input != request or not auth.value.has("money") or receipt.outcome.quote.provider != auth.value.money.provider: return failure("request_conflict","Recovery must rebind the original request and ECON provider.")
	if not authority._begin(request): return failure("busy","Another ITEM operation is active.")
	return authority._end(authority.money._acknowledge(owner,key))
