extends RefCounted
## ITEM monetary instruments and scoped tender participant. ECON quotes/accepts
## terms and acknowledges local credits; it never acquires a second coin store.
const A = preload("res://scripts/item/accounting.gd")
const Data = preload("res://scripts/data/item_capacity_tender.gd")
const IDs = preload("res://scripts/item/identity_allocator.gd")
var _authority: WeakRef
var _receipts := {}
var _committed_quotes := {}
func _init(authority: RefCounted) -> void:
	_authority = weakref(authority)
func retire() -> void:
	_receipts.clear()
	_committed_quotes.clear()
func request_claimed(key: String) -> bool:
	return _receipts.has(key)
func binding_valid(owner: Object, value: Variant) -> bool:
	if not value is Dictionary or value.size() != 4 or not Data.Paths.valid_id(value.get("provider","")) or not Data.Paths.valid_id(value.get("profile","")) or not Data.keys(value.get("coins")) or not Data.keys(value.get("letters")): return false
	var authority: RefCounted = _authority.get_ref()
	var adapter: RefCounted = authority.definitions._adapters.get(Data.DOMAIN,{}).get("adapter")
	if adapter == null or not adapter.supports(value.provider,"intake-v1") or not adapter.supports(value.provider,"quote-v1"): return false
	if not authority.capacity.policy(value.get("profile",""),"money").ok: return false
	for method in ["money_intake","money_quote","money_complete","money_revision"]:
		if not A.signature(owner,method,0 if method == "money_revision" else 1,TYPE_INT if method == "money_revision" else TYPE_DICTIONARY): return false
	for id in value.coins:
		if not authority.capacity.policy(id,"denomination").ok: return false
	for id in value.letters:
		var p: Dictionary = authority.capacity.policy(id,"letter")
		if not p.ok or p.value.provider != value.provider: return false
	return true
func _key(owner: Object, request: Dictionary) -> String:
	return str(owner.get_instance_id())+":"+request.context+":"+request.request
func _response(owner: Object, method: String, request: Dictionary) -> Dictionary:
	return _authority.get_ref().collections._provider_result(owner.call(method,request.duplicate(true)))
func policy(record: Dictionary) -> Dictionary:
	var m: Dictionary = record.get("money",{})
	if m.get("form") not in ["coin","letter"]: return A.fail("invalid_money")
	return {"ok":true,"eligible":m.form == "coin","cap":0,"contract":{"provider":"builtin.money-v1","state_rule":"exact-per-unit-v1","contents":{}},"provenance":m.provenance.duplicate(true)}
func state_check(owner: Object, request: Dictionary, record: Dictionary, action: String) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	if not auth.value.has("money"): return A.fail("unauthorized")
	var m: Dictionary = record.money
	if m.profile not in auth.value.money["coins" if m.form == "coin" else "letters"]: return A.fail("unauthorized")
	if action in ["consume","intake"]: return A.fail("required_money_participant")
	if m.form == "letter" and action in ["split","merge"]: return A.fail("unsupported_split")
	return policy(record)
func intake(owner: Object, request: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	if not auth.value.has("money") or not Data.Paths.valid_id(request.get("request","")): return A.fail("unauthorized")
	for field in request:
		if field not in ["session","context","request","profile","quantity","face"]: return A.fail("invalid_request")
	var key := _key(owner,request)
	if authority._receipts.has(key) or authority._generation.has(key) or authority.collections._receipts.has(key): return A.fail("request_conflict")
	if _receipts.has(key): return _receipts[key].outcome.duplicate(true) if _receipts[key].input == request else A.fail("request_conflict")
	if not authority._begin(request): return A.fail("busy")
	var result := _intake(owner,request,auth.value)
	if result.get("committed",false): _receipts[key] = {"input":request.duplicate(true),"outcome":result.duplicate(true)}
	return authority._end(result)
func _intake(owner: Object, request: Dictionary, auth: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var form: String = "coin" if request.get("profile") in auth.money.coins else "letter"
	if request.get("profile") not in auth.money["coins" if form == "coin" else "letters"] or not A.integer(request.get("quantity"),1,2147483647): return A.fail("unauthorized_intake")
	if form == "letter" and (request.quantity != 1 or not A.integer(request.get("face"),1)): return A.fail("invalid_letter")
	if form == "coin" and request.has("face"): return A.fail("invalid_request")
	var p: Dictionary = authority.capacity.policy(request.profile,"denomination" if form == "coin" else "letter")
	if not p.ok: return p
	var revision: Variant = owner.money_revision()
	if not A.integer(revision): return A.fail("provider_failure")
	var authorized := _response(owner,"money_intake",request)
	if not authorized.ok: return authorized
	if authorized != {"ok":true,"authorized":true}: return A.fail("provider_failure")
	if not authority.context(owner,request).ok: return A.fail("stale_session")
	if owner.money_revision() != revision: return A.fail("stale_admission")
	var allocated: Dictionary = authority._allocator.allocate("stack" if form == "coin" else "item")
	if not allocated.ok: return allocated
	var monetary := {"form":form,"profile":request.profile,"unit":p.value.unit,"provenance":p.value.provenance.duplicate(true)}
	if form == "coin": monetary.value = p.value.value
	else: monetary.merge({"issuer":p.value.issuer,"remaining":request.face,"provider":p.value.provider,"version":Data.VERSION})
	var record := {"id":allocated.id,"definition":p.identity.duplicate(true),"profile":request.profile,"kind":"money","category":"semantic","stack_type":"money","material":"","style":"","dye":"","condition":0,"maximum_condition":0,"value":0,"weight_nanokg":p.value.nanokg,"weight_kg":float(p.value.nanokg)/1000000000.0,"quantity":request.quantity,"revision":1,"state":preload("res://scripts/data/item_collections.gd").ordinary_state(),"money":monetary,"custody":{"owner":auth.custody,"context":request.context},"identity_category":allocated.id.category,"pending_consumers":["save"]}
	authority._possessions[authority._id_key(record.id)] = record
	return {"ok":true,"committed":true,"kind":"money_intake","record":record.duplicate(true)}

## A summary projects counts from the only possession store. Bank balances have
## no entry here and cannot become a source merely by appearing in a quote.
func wallet(owner: Object, request: Dictionary, container: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var found: Dictionary = authority.collections.projection(owner,request,container)
	if not found.ok: return found
	var counts := {}
	var letters: Array = []
	for r: Dictionary in found.entries:
		if not r.has("money"): continue
		if r.money.form == "letter": letters.append({"id":r.id,"instrument":r.money.duplicate(true)})
		else:
			var sum := A.add(counts.get(r.profile,0),r.quantity)
			if not sum.ok: return sum
			counts[r.profile] = sum.value
	return {"ok":true,"counts":counts,"letters":letters}

func gold_formula_amount(owner: Object, request: Dictionary, gold: Variant) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	if not auth.value.has("money") or not A.integer(gold): return A.fail("invalid_money")
	var profile: Dictionary = authority.capacity.policy(auth.value.money.profile,"money")
	if not profile.ok: return profile
	var mapped := A.multiply(gold,profile.value.gold_value)
	if mapped.ok: mapped.unit = profile.value.unit
	return mapped

func _quote(owner: Object, request: Dictionary, auth: Dictionary) -> Dictionary:
	var result := _response(owner,"money_quote",request)
	if not result.ok: return result
	var q: Variant = result.get("quote")
	if result.size() != 2 or not q is Dictionary or q.size() != 17: return A.fail("provider_failure")
	for field in ["id","unit","region","institution","provider"]:
		if not Data.Paths.valid_id(q.get(field,"")): return A.fail("provider_failure")
	if q.provider != auth.money.provider or not A.integer(q.get("revision")) or not A.integer(q.get("price")) or not A.integer(q.get("fees")) or not A.integer(q.get("coin_offer")) or q.get("tender") not in ["exact","change"] or typeof(q.get("wagon")) != TYPE_BOOL or not Data.keys(q.get("rates")): return A.fail("provider_failure")
	for field in ["sources","outputs","change"]:
		if not q.get(field) is Array: return A.fail("provider_failure")
	for field in ["recipient","destination"]:
		if not q.get(field) is Dictionary: return A.fail("provider_failure")
	return {"ok":true,"quote":q}
func _source(owner: Object, request: Dictionary, id: Variant, wagon_allowed: bool) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var c: Dictionary = authority.collections._container(owner,request,id)
	if not c.ok: return c
	if c.authorization.get("capacity",{}).get("kind") == "wagon" and not wagon_allowed: return A.fail("wagon_funds_denied")
	return {"ok":true,"collection":c.record,"records":authority.collections._records(id)}
func _subset(denominations: Array, counts: Dictionary, values: Dictionary, target: int, limit: int) -> Dictionary:
	# Explicit deterministic depth-first subset search. Earlier profile denominations
	# take the largest count first; no hidden greedy fallback or optimal packing.
	var stack: Array = [{"index":0,"remaining":target,"selected":{}}]
	var steps := 0
	while not stack.is_empty():
		steps += 1
		if steps > limit: return A.fail("tender_search_limit")
		var node: Dictionary = stack.pop_back()
		if node.remaining == 0: return {"ok":true,"selected":node.selected}
		if node.index >= denominations.size(): continue
		var id: String = denominations[node.index]
		var maximum: int = mini(counts.get(id,0),node.remaining/int(values[id]))
		if node.index == denominations.size()-1:
			if node.remaining%int(values[id]) == 0 and node.remaining/int(values[id]) <= maximum:
				var selected: Dictionary = node.selected.duplicate()
				selected[id] = node.remaining/int(values[id])
				return {"ok":true,"selected":selected}
			continue
		if maximum > limit-stack.size(): return A.fail("tender_search_limit")
		for n in maximum+1:
			var selected: Dictionary = node.selected.duplicate()
			selected[id] = n
			stack.append({"index":node.index+1,"remaining":node.remaining-n*int(values[id]),"selected":selected})
	return A.fail("exact_tender_unavailable")
func _move(owner: Object, request: Dictionary, record: Dictionary, quantity: int, destination: Dictionary, plan: Dictionary, categories: Array) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var local: Dictionary = request.merged({"context":record.custody.context,"action":"transfer","id":record.id,"quantity":quantity,"destination":destination,"mode":"no_stack"},true)
	var access: Dictionary = authority.collections.access(owner,local,record)
	if not access.ok: return access
	var checked: Dictionary = authority.collections._state_check(owner,local,record,"transfer")
	if not checked.ok: return checked
	var dest: Dictionary = authority.collections._container(owner,request,destination)
	if not dest.ok: return dest
	return authority.collections._move_plan(owner,local,record,dest.record,plan,categories)
func prepare(owner: Object, request: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	if not auth.value.has("money") or not Data.Paths.valid_id(request.get("request","")): return A.fail("unauthorized")
	if request.size() != 3: return A.fail("invalid_request")
	if not authority._begin(request): return A.fail("busy")
	return authority._end(_prepare(owner,request,auth.value))
func _prepare(owner: Object, request: Dictionary, auth: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var quoted := _quote(owner,request,auth)
	if not quoted.ok: return quoted
	var q: Dictionary = quoted.quote
	var money: Dictionary = authority.capacity.policy(auth.money.profile,"money")
	if not money.ok: return money
	if money.value.unit != q.unit: return A.fail("unsupported_unit")
	var total := A.add(q.price,q.fees)
	if not total.ok: return total
	var remaining: int = total.value
	var records: Array = []
	var seen := {}
	var facts := {}
	for source in q.sources:
		var found := _source(owner,request,source,q.wagon)
		if not found.ok: return found
		var key: String = authority.collections._key(source)
		if seen.has(key) or source == q.recipient: return A.fail("invalid_sources")
		seen[key] = true
		facts[key] = found.collection.revision
		records.append_array(found.records)
	records.sort_custom(func(a: Dictionary,b: Dictionary): return IDs.less(a.id,b.id))
	var values := {}
	var counts := {}
	var coin_value := 0
	for denomination in money.value.order:
		var d: Dictionary = authority.capacity.policy(denomination,"denomination")
		if not d.ok: return d
		values[denomination] = int(d.value.value)
		counts[denomination] = 0
	for r: Dictionary in records:
		if not r.has("money") or r.money.form != "coin": continue
		if not values.has(r.profile): continue
		var sum := A.add(counts[r.profile],r.quantity)
		if not sum.ok: return sum
		counts[r.profile] = sum.value
		var product := A.multiply(r.quantity,values[r.profile])
		if not product.ok: return product
		var added := A.add(coin_value,product.value)
		if not added.ok: return added
		coin_value = added.value
	var plan := {}
	var categories: Array = []
	var face_debits: Array = []
	if coin_value < remaining:
		for r: Dictionary in records:
			if remaining == 0: break
			if not r.has("money") or r.money.form != "letter": continue
			var instrument: Dictionary = r.money
			var rate := {}
			for rate_id in q.rates:
				var read: Dictionary = authority.capacity.policy(rate_id,"rate")
				if not read.ok: return read
				var v: Dictionary = read.value
				if v.issuer == instrument.issuer and v.institution == q.institution and v.region == q.region and v.face_unit == instrument.unit and v.local_unit == q.unit and v.provider == q.provider:
					if not rate.is_empty(): return A.fail("conflicting_rate")
					rate = v
			if rate.is_empty(): return A.fail("unsupported_rate")
			# Exact lots leave no unowned rounding residual. Tiny unrepresentable
			# payments fail or use coins; travel/display never edits face amount.
			var lots: int = mini(int(instrument.remaining)/int(rate.denominator),remaining/int(rate.numerator))
			if lots == 0: continue
			var debit: int = lots*int(rate.denominator)
			var credit: int = lots*int(rate.numerator)
			var changed: Dictionary = r.duplicate(true)
			changed.money.remaining -= debit
			changed.revision += 1
			plan[authority._id_key(r.id)] = changed if changed.money.remaining > 0 else {}
			remaining -= credit
			face_debits.append({"id":r.id.duplicate(),"face_unit":instrument.unit,"face":debit,"local_unit":q.unit,"local":credit,"rate":rate.duplicate(true)})
	var offered: int = remaining if q.tender == "exact" else q.coin_offer
	if offered < remaining: return A.fail("insufficient_funds")
	var selected := _subset(money.value.order,counts,values,offered,money.value.search_limit)
	if not selected.ok: return selected
	var recipient := _source(owner,request,q.recipient,true)
	if not recipient.ok: return recipient
	for r: Dictionary in records:
		if not r.has("money") or r.money.form != "coin": continue
		var quantity: int = mini(r.quantity,selected.selected.get(r.profile,0))
		if quantity == 0: continue
		var moved := _move(owner,request,r,quantity,q.recipient,plan,categories)
		if not moved.ok: return moved
		selected.selected[r.profile] -= quantity
	var change_value := 0
	var output_seen := {}
	for group in ["outputs","change"]:
		for output in q[group]:
			if not output is Dictionary or output.size() != 2 or not A.integer(output.get("quantity"),1,2147483647) or not authority.collections._valid_id(output.get("id")): return A.fail("invalid_output")
			var key: String = authority._id_key(output.id)
			if output_seen.has(key) or plan.has(key): return A.fail("conflicting_output")
			output_seen[key] = true
			var found: Dictionary = authority.inspect(request.session,output.id)
			if not found.ok or found.record.custody.get("container") != q.recipient or output.quantity > found.record.quantity: return A.fail("missing_output_supply")
			if group == "change":
				if not found.record.has("money") or found.record.money.form != "coin" or found.record.money.unit != q.unit or not values.has(found.record.profile): return A.fail("invalid_change")
				var product := A.multiply(output.quantity,values[found.record.profile])
				if not product.ok: return product
				var sum := A.add(change_value,product.value)
				if not sum.ok: return sum
				change_value = sum.value
			var moved := _move(owner,request,found.record,output.quantity,q.destination,plan,categories)
			if not moved.ok: return moved
	if change_value != offered-remaining: return A.fail("change_mismatch")
	var admitted: Dictionary = authority.collections._admit(owner,request.merged({"action":"tender"},true),plan)
	if not admitted.ok: return admitted
	var capacity: Dictionary = authority.capacity.validate(owner,request,plan)
	if not capacity.ok: return capacity
	if not authority.context(owner,request).ok: return A.fail("stale_session")
	return {"ok":true,"quote":q.duplicate(true),"plan":plan,"categories":categories,"face_debits":face_debits,"coin_debit":offered,"change_value":change_value,"capacity":capacity,"source_revisions":facts,"money_revision":owner.money_revision(),"collection_revision":owner.collection_revision()}

func commit(owner: Object, request: Dictionary, accepted: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	if not auth.value.has("money") or not Data.Paths.valid_id(request.get("request","")): return A.fail("unauthorized")
	var key := _key(owner,request)
	if authority._receipts.has(key) or authority._generation.has(key) or authority.collections._receipts.has(key): return A.fail("request_conflict")
	if not authority._begin(request): return A.fail("busy")
	if _receipts.has(key):
		var previous: Dictionary = _receipts[key]
		if previous.input != request or previous.accepted != accepted: return authority._end(A.fail("request_conflict"))
		return authority._end(_acknowledge(owner,key))
	var prepared := _prepare(owner,request,auth.value)
	if not prepared.ok: return authority._end(prepared)
	if prepared != accepted: return authority._end({"ok":false,"kind":"renewed_acceptance_required","prepared":prepared})
	var quote_key: String = auth.value.money.provider+":"+prepared.quote.id
	if _committed_quotes.has(quote_key): return authority._end(A.fail("quote_already_committed"))
	var result: Dictionary = authority.collections._commit(owner,request.merged({"action":"tender"},true),prepared.plan,prepared.categories,"tender",_guard.bind(owner,request,prepared))
	if not result.ok: return authority._end(result)
	result.quote = prepared.quote.duplicate(true)
	result.face_debits = prepared.face_debits.duplicate(true)
	result.coin_debit = prepared.coin_debit
	result.change_value = prepared.change_value
	result.obligations = ["econ-acknowledgment"]
	_receipts[key] = {"input":request.duplicate(true),"accepted":accepted.duplicate(true),"outcome":result.duplicate(true)}
	_committed_quotes[quote_key] = key
	return authority._end(_acknowledge(owner,key))
func _guard(owner: Object, request: Dictionary, accepted: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var auth: Dictionary = authority.context(owner,request)
	if not auth.ok: return auth
	var current := _quote(owner,request,auth.value)
	if not current.ok: return current
	if current.quote != accepted.quote or owner.money_revision() != accepted.money_revision or owner.collection_revision() != accepted.collection_revision: return A.fail("renewed_acceptance_required")
	return {"ok":true}
func _acknowledge(owner: Object, key: String) -> Dictionary:
	var receipt: Dictionary = _receipts[key]
	if not receipt.outcome.obligations.is_empty():
		var response := _response(owner,"money_complete",receipt.outcome)
		if response == {"ok":true,"acknowledged":true}: receipt.outcome.obligations.clear()
		else:
			var recovery: Dictionary = receipt.outcome.duplicate(true)
			recovery.ok = false
			recovery.kind = "recovery_required"
			return recovery
	return receipt.outcome.duplicate(true)
