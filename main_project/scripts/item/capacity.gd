extends RefCounted
## ITEM load/admission collaborator. CHAR remains the live base-capacity owner.
const Data = preload("res://scripts/data/item_capacity_tender.gd")
const A = preload("res://scripts/item/accounting.gd")
var _authority: WeakRef
var _cache := {}
var _loads := {} # Collection revision + locked quantum; no copied possessions.
var _weights := {} # Locked template overrides, including explicit absence.
func _init(authority: RefCounted) -> void:
	_authority = weakref(authority)
func retire() -> void:
	_cache.clear()
	_loads.clear()
	_weights.clear()
func policy(id: String, kind: String) -> Dictionary:
	if not _cache.has(id):
		var found: Dictionary = _authority.get_ref().definitions.query(Data.DOMAIN,"profiles",id)
		if not found.ok: return A.fail("missing_definition")
		_cache[id] = found.record.duplicate(true)
	return {"ok":true,"value":_cache[id].value.duplicate(true),"identity":_cache[id].identity.duplicate(true),"winner":_cache[id].winner.duplicate(true)} if _cache[id].value.kind == kind else A.fail("invalid_definition")
func binding_valid(owner: Object, value: Variant) -> bool:
	if not value is Dictionary or value.size() != 6 or value.get("kind") not in ["carried","wagon"]: return false
	for field in ["profile","actor","access","wagon","exit"]:
		if not value.get(field) is String: return false
	if value.kind == "carried" and not Data.Paths.valid_id(value.actor): return false
	if value.kind == "wagon" and (not Data.Paths.valid_id(value.wagon) or not Data.Paths.valid_id(value.exit)): return false
	return A.signature(owner,"item_capacity_context",1,TYPE_DICTIONARY) and policy(value.profile,"capacity").ok and policy(value.access,"access").ok
func _context(owner: Object, request: Dictionary, binding: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var result: Dictionary = authority.collections._provider_result(owner.item_capacity_context({"session":request.session,"context":request.context,"binding":binding.duplicate(true)}))
	if not result.ok: return result
	if result.size() != 4 or not A.integer(result.get("revision")) or not result.get("modifiers") is Array or not result.get("wagon") is Dictionary: return A.fail("provider_failure")
	var seen := {}
	var bonus := 0
	for source in result.modifiers:
		if not source is Dictionary or source.size() != 2 or not Data.Paths.valid_id(source.get("source","")) or seen.has(source.source) or not A.integer(source.get("kg"),-A.MAX): return A.fail("provider_failure")
		seen[source.source] = true
		var sum := A.signed_add(bonus,source.kg)
		if not sum.ok: return sum
		bonus = sum.value
	result.bonus = bonus
	return result
static func _position(value: Variant) -> bool:
	if not value is Array or value.size() != 3: return false
	for coordinate in value:
		if not A.integer(coordinate,-1000000000,1000000000): return false
	return true
static func _near(a: Array, b: Array, distance: int) -> bool:
	var squared := 0
	for i in 3:
		var delta: int = absi(a[i]-b[i])
		if delta > distance: return false
		squared += delta*delta
	return squared <= distance*distance
func access(binding: Dictionary, snapshot: Dictionary) -> Dictionary:
	var loaded := policy(binding.access,"access")
	if not loaded.ok: return loaded
	var p: Dictionary = loaded.value
	var w: Dictionary = snapshot.wagon
	if w.size() != 11 or typeof(w.get("owned")) != TYPE_BOOL or typeof(w.get("available")) != TYPE_BOOL or typeof(w.get("valid_exit")) != TYPE_BOOL or not A.integer(w.get("reach_mm"),0,1000000): return A.fail("provider_failure")
	for field in ["feet_mm","anchor_mm","location_mm"]:
		if not _position(w.get(field)): return A.fail("provider_failure")
	if w.get("wagon") != binding.wagon or w.get("exit") != binding.exit or not w.get("context_id") is String or w.get("context") not in ["exterior","interior","dungeon"]: return A.fail("wagon_identity_changed")
	if not w.owned or not w.available: return A.fail("wagon_unavailable")
	if p.algorithm == "physical-reach-v1" and not _near(w.feet_mm,w.location_mm,w.reach_mm): return A.fail("wagon_out_of_reach")
	if w.context == "interior" and not p.interior: return A.fail("wagon_interior_denied")
	if w.context == "dungeon" and (not w.valid_exit or not _near(w.feet_mm,w.anchor_mm,p.distance_mm)): return A.fail("wagon_exit_unavailable")
	return {"ok":true}
func unit_weight(record: Dictionary, accounting: Dictionary) -> Dictionary:
	var nanokg: Variant = record.get("weight_nanokg")
	if nanokg == null:
		var kg: Variant = record.get("weight_kg")
		if typeof(kg) not in [TYPE_FLOAT,TYPE_INT] or not is_finite(float(kg)) or kg < 0 or kg > 9007199: return A.fail()
		# Legacy construction publishes microkg; recover that exact declared boundary.
		nanokg = int(round(float(kg)*1000000))*1000
		if kg > 0 and nanokg == 0: return A.fail("incompatible_precision")
	var exempt := false
	var override_id: String = "weight-"+record.profile
	if not _weights.has(override_id):
		var read: Dictionary = _authority.get_ref().definitions.query(Data.DOMAIN,"profiles",override_id)
		_weights[override_id] = read.record.value.duplicate(true) if read.ok else {}
	if not _weights[override_id].is_empty():
		var v: Dictionary = _weights[override_id]
		if v.kind != "weight" or v.profile != record.profile: return A.fail("invalid_definition")
		exempt = v.exempt
		if v.nanokg != null: nanokg = v.nanokg
	return A.weight(nanokg,accounting.quantum_nanokg,exempt)
func total_load(entries: Array, accounting: Dictionary) -> Dictionary:
	var total := 0
	for record: Dictionary in entries:
		if not A.integer(record.get("quantity"),1,2147483647): return A.fail()
		var unit := unit_weight(record,accounting)
		if not unit.ok: return unit
		var product := A.multiply(unit.value,record.quantity)
		if not product.ok: return product
		var sum := A.add(total,product.value)
		if not sum.ok: return sum
		total = sum.value
	return {"ok":true,"value":total}
func display_weight(units: Variant, accounting: Dictionary) -> Dictionary:
	if not A.integer(units) or not A.integer(accounting.get("quantum_nanokg"),1,1000000000) or not A.integer(accounting.get("display_places"),0,9): return A.fail()
	var per_kg: int = 1000000000/int(accounting.quantum_nanokg)
	var scale: int = int(pow(10,int(accounting.display_places)))
	if 1000000000%int(accounting.quantum_nanokg) != 0 or scale%per_kg != 0: return A.fail("incompatible_precision")
	var whole: int = int(units)/per_kg
	# remainder < 1e9 and decimal scale <= 1e9: intermediary < 1e18,
	# within signed int64 even for the largest admitted accounting value.
	var fraction: int = (int(units)%per_kg)*scale/per_kg
	var digits: int = int(accounting.display_places)
	return {"ok":true,"text":str(whole)+("."+str(fraction).pad_zeros(digits) if digits > 0 else "")+" kg"}
func planned_load(container: Dictionary, plan: Dictionary, accounting: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var collection_key: String = authority.collections._key(container)
	var revision: int = authority.collections._containers[collection_key].revision
	var cache_key: String = collection_key+":"+str(accounting.quantum_nanokg)
	if not _loads.has(cache_key) or _loads[cache_key].revision != revision:
		var total := 0
		for key in authority.collections._members[collection_key]:
			var record: Dictionary = authority._possessions[key]
			var weight := unit_weight(record,accounting)
			if not weight.ok: return weight
			var product := A.multiply(weight.value,record.quantity)
			if not product.ok: return product
			var sum := A.add(total,product.value)
			if not sum.ok: return sum
			total = sum.value
		_loads[cache_key] = {"revision":revision,"value":total}
	var result: int = _loads[cache_key].value
	# Remove all old contributions before adding new ones. Checked arithmetic
	# never transiently overflows because Dictionary iteration chose intake first.
	for key in plan:
		var old: Dictionary = authority._possessions.get(key,{})
		if old.is_empty() or old.custody.get("container") != container: continue
		var weight := unit_weight(old,accounting)
		if not weight.ok: return weight
		var product := A.multiply(weight.value,old.quantity)
		if not product.ok: return product
		result -= product.value
		if result < 0: return A.fail("invalid_membership")
	for key in plan:
		var next: Dictionary = plan[key]
		if next.is_empty() or next.custody.get("container") != container: continue
		var weight := unit_weight(next,accounting)
		if not weight.ok: return weight
		var product := A.multiply(weight.value,next.quantity)
		if not product.ok: return product
		var sum := A.add(result,product.value)
		if not sum.ok: return sum
		result = sum.value
	return {"ok":true,"value":result}
func projection(owner: Object, request: Dictionary, container: Dictionary, plan: Dictionary = {}) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var found: Dictionary = authority.collections._container(owner,request,container)
	if not found.ok: return found
	var binding: Dictionary = found.authorization.get("capacity",{})
	if binding.is_empty(): return A.fail("capacity_unbound")
	var local: Dictionary = request.merged({"context":found.record.context},true)
	var p := policy(binding.profile,"capacity")
	if not p.ok: return p
	var accounting := policy(p.value.accounting,"accounting")
	if not accounting.ok: return accounting
	var snapshot := _context(owner,local,binding)
	if not snapshot.ok: return snapshot
	if not authority.context(owner,local).ok: return A.fail("stale_session")
	var kg: Variant = p.value.wagon_kg
	var actor := {}
	if binding.kind == "carried":
		actor = authority._core.get_ref().actors.capacity_projection(request.session,binding.actor)
		if not actor.ok: return actor
		var combined := A.signed_add(actor.kg,snapshot.bonus)
		if not combined.ok: return combined
		if combined.value < 0: return A.fail("invalid_capacity")
		kg = combined.value
	else:
		var accessed := access(binding,snapshot)
		if not accessed.ok: return accessed
	var scaled := A.multiply(kg,1000000000/int(accounting.value.quantum_nanokg))
	if not scaled.ok: return scaled
	var loaded := planned_load(container,plan,accounting.value)
	if not loaded.ok: return loaded
	return {"ok":true,"load":loaded.value,"capacity":scaled.value,"accounting":accounting.value,"snapshot":snapshot,"actor":actor,"binding":binding,"collection_revision":found.record.revision}
func validate(owner: Object, request: Dictionary, plan: Dictionary) -> Dictionary:
	var authority: RefCounted = _authority.get_ref()
	var touched := {}
	for key in plan:
		for r: Dictionary in [authority._possessions.get(key,{}),plan[key]]:
			if not r.is_empty() and r.custody.has("container"): touched[authority.collections._key(r.custody.container)] = r.custody.container
	var facts := {}
	for key in touched:
		var c: Dictionary = authority.collections._container(owner,request,touched[key])
		if not c.ok: return c
		if not c.authorization.has("capacity"): continue
		var before := projection(owner,request,touched[key])
		if not before.ok: return before
		var after := planned_load(touched[key],plan,before.accounting)
		if not after.ok: return after
		var positive_intake := false
		for item_key in plan:
			var next: Dictionary = plan[item_key]
			if next.is_empty() or next.custody.get("container") != touched[key]: continue
			var old: Dictionary = authority._possessions.get(item_key,{})
			if not old.is_empty() and old.custody.get("container") == touched[key] and next.quantity <= old.quantity: continue
			var weight := unit_weight(next,before.accounting)
			if not weight.ok: return weight
			positive_intake = positive_intake or weight.value > 0
		# A same-storage split changes references, not physical intake. External
		# swaps/tender still inspect each incoming positive contribution separately.
		if request.get("action") == "split" and after.value == before.load: positive_intake = false
		if positive_intake and (before.load > before.capacity or after.value > before.capacity): return A.fail("admission_rejected")
		facts[key] = before
	return {"ok":true,"facts":facts}
