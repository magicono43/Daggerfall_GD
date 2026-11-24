extends RefCounted
## Plain-value intake/record contract, independent of presentation and formulas.
const LIMIT := 1000000000
const Paths = preload("res://scripts/mod/package_library.gd")
const F = preload("res://scripts/rule/actor_formulas.gd")
const UNITS := {"health":"points","fatigue":"internal-64","magicka":"points"}
const ACTIONS := ["spend","damage","drain","heal","recover","fill"]

static func empty() -> Dictionary:
	return {"schema":"vital-retention-v1","receipts":{},"receipt_count":0,"transitions":{},"next_transition":0,"pending_count":0}

static func request_valid(r: Variant) -> bool:
	if not r is Dictionary or r.size() != 12 or not r.get("schema") is String or r.schema != "vital-intake-v1": return false
	for field in ["session","actor","caller","operation"]:
		if not r.get(field) is String or not Paths.valid_id(r[field]): return false
	if not F.integer(r.get("content"),0,LIMIT) or not F.integer(r.get("revision"),1,LIMIT) or not F.integer(r.get("amount"),0,LIMIT): return false
	if not r.get("pool") is String or not UNITS.has(r.pool) or not r.get("unit") is String or r.unit != UNITS[r.pool] or not r.get("action") is String or r.action not in ACTIONS: return false
	if r.action == "fill" and r.amount != 0: return false
	var a: Variant = r.get("attribution")
	if not a is Dictionary or a.size() != 3: return false
	for field in ["source","cause","component"]:
		if not a.get(field) is String or not Paths.valid_id(a[field]): return false
	return true

static func eligible(domain: String, action: String, pool: String) -> bool:
	match domain:
		"COMBAT": return action == "damage" and pool == "health"
		"MAGIC": return action in ["spend","damage","drain","heal","recover"]
		"ITEM": return action in ["heal","recover","fill"]
		"CHAR": return action in ["spend","drain","recover","fill"]
	return false

static func hash_valid(value: Variant) -> bool:
	if not value is String or value.length() != 64: return false
	for character in value:
		if not character in "0123456789abcdef": return false
	return true

static func valid(record: Dictionary) -> bool:
	# Check outer context before typed bounds or direct nested record access.
	if not F.integer(record.get("revision"),1,LIMIT) or not F.integer(record.get("content"),0,LIMIT): return false
	for field in ["actor","session"]:
		if not Paths.valid_id(record.get(field)): return false
	var s: Variant = record.get("vitals")
	if not s is Dictionary or s.size() != 6 or s.get("schema") != "vital-retention-v1" or not s.get("receipts") is Dictionary or not s.get("transitions") is Dictionary or not F.integer(s.get("receipt_count"),0,4096) or not F.integer(s.get("next_transition"),0,LIMIT) or not F.integer(s.get("pending_count"),0,4096) or s.transitions.size() > 4096: return false
	var count := 0
	var revisions := {}
	var required_transitions := {}
	for caller in s.receipts:
		if not caller is String or not Paths.valid_id(caller) or not s.receipts[caller] is Dictionary or s.receipts[caller].is_empty(): return false
		for operation in s.receipts[caller]:
			count += 1
			var receipt: Variant = s.receipts[caller][operation]
			if not receipt is Dictionary or receipt.size() != 3 or typeof(receipt.get("acknowledged")) != TYPE_BOOL or not request_valid(receipt.get("request")) or not receipt.get("result") is Dictionary: return false
			var r: Dictionary = receipt.request
			var out: Dictionary = receipt.result
			if r.caller != caller or r.operation != operation or r.actor != record.actor or r.session != record.session or r.content != record.content or out.size() != 21: return false
			for field in ["session","actor","caller","operation","action","pool","unit","attribution"]:
				if out.get(field) != r[field]: return false
			if out.get("schema") != "applied-vital-v1" or not F.integer(out.get("requested"),0,LIMIT) or out.requested != r.amount or not F.integer(out.get("revision"),2,record.revision) or out.revision != r.revision+1: return false
			if revisions.has(out.revision): return false
			revisions[out.revision] = true
			for field in ["before","after","maximum","applied","remainder"]:
				if not F.integer(out.get(field),0,LIMIT): return false
			if out.before > out.maximum or out.after > out.maximum: return false
			if out.revision == record.revision and (not record.get("current") is Dictionary or record.current.get(r.pool) != out.after): return false
			var after: int = out.before
			var sufficient: bool = r.action != "spend" or out.before >= r.amount
			match r.action:
				"spend":
					if sufficient: after -= r.amount
				"damage", "drain": after = maxi(0,after-r.amount)
				"heal", "recover": after = mini(out.maximum,after+r.amount)
				"fill": after = out.maximum
			var pending: bool = out.before > 0 and after == 0 and r.pool == "fatigue"
			if r.pool == "health" and out.before > 0 and after == 0: return false
			if out.before > 0 and after == 0: required_transitions[r.caller+"/"+r.operation] = false
			if out.after != after or out.applied != absi(after-out.before) or out.remainder != (out.maximum-after if r.action == "fill" else r.amount-out.applied): return false
			if typeof(out.get("ok")) != TYPE_BOOL or out.ok != sufficient or out.get("kind") != ("applied" if sufficient else "insufficient") or out.get("phase") != ("committed" if sufficient else "rejected") or typeof(out.get("transition_pending")) != TYPE_BOOL or out.transition_pending != pending or typeof(out.get("continuation_allowed")) != TYPE_BOOL or out.continuation_allowed != (sufficient and not pending): return false
			if receipt.acknowledged and not out.continuation_allowed and not (out.ok and preload("res://scripts/char/activity_owner.gd").settled(record,caller,operation)): return false
	if count != s.receipt_count or s.transitions.size() != s.next_transition: return false
	var pending_count := 0
	for id in s.transitions:
		if not id is String or not id.is_valid_int() or str(int(id)) != id or not F.integer(int(id),1,s.next_transition): return false
		var t: Variant = s.transitions[id]
		if not t is Dictionary or t.size() != 6 or not t.get("pool") is String or not UNITS.has(t.pool) or t.pool == "health" or not F.integer(t.get("before"),1,LIMIT) or t.get("after") != 0 or typeof(t.after) != TYPE_INT or typeof(t.get("pending")) != TYPE_BOOL or t.pending != (t.pool in ["health","fatigue"]) or t.get("outcome") != ("owner-unavailable" if t.pending else "notification"): return false
		if t.pending: pending_count += 1
		var context: Variant = t.get("context")
		if not context is Dictionary: return false
		if context.get("kind") == "vital-intake":
			if context.size() != 4 or not s.receipts.has(context.get("caller")) or not s.receipts[context.caller].has(context.get("operation")): return false
			var receipt: Dictionary = s.receipts[context.caller][context.operation]
			if receipt.request.attribution != context.get("attribution") or receipt.request.pool != t.pool or receipt.result.before != t.before or receipt.result.after != 0: return false
			var key: String = context.caller+"/"+context.operation
			if not required_transitions.has(key) or required_transitions[key]: return false
			required_transitions[key] = true
		elif context.get("kind") == "source-reconciliation":
			if context.size() != 2 or not context.get("sources") is Dictionary: return false
			for source in context.sources:
				var source_receipt: Variant = context.sources[source]
				if not Paths.valid_id(source) or not source_receipt is Dictionary or source_receipt.size() != 2 or not F.integer(source_receipt.get("revision"),0,LIMIT) or not hash_valid(source_receipt.get("sha256")): return false
		elif context.get("kind") == "activity":
			var receipt: Dictionary = record.get("activity",{}).get("receipts",{}).get(context.get("caller"),{}).get(context.get("operation"),{})
			if context.size() != 4 or receipt.is_empty() or context.get("attribution") != receipt.request.source or t.pool != "fatigue" or receipt.result.before != t.before or receipt.result.after != 0: return false
		else: return false
	return pending_count == s.pending_count and required_transitions.values().all(func(found): return found)
