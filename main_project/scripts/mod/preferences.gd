extends RefCounted
## Application-owned preference state and checked synchronous consumer bindings.
const Definitions = preload("res://scripts/mod/preference_definitions.gd")
const Store = preload("res://scripts/mod/preference_store.gd")
var stores: Dictionary = {}
var staged: Dictionary = {}
var consumers: Dictionary = {}
var authorities: Dictionary = {}
var delivered: Dictionary = {}
var epoch := 0
var status: Dictionary = {}
var reset_confirmation := ""
var _busy := false

func prepare(resources: Dictionary, adapter: StartupStorageAdapter, directory: String) -> Dictionary:
	var prepared: Dictionary = {}
	for id: String in resources.get(Definitions.DOMAIN + ":installed", {}).get("records", {}):
		var record: Dictionary = resources[Definitions.DOMAIN + ":installed"].records[id]
		# A package may define only its own preferences. Shipped adapters are reserved.
		if record.identity.package != id:
			return {"ok":false,"reason":"Preference definition must be owned by its stable package ID: " + id}
		var path := directory.path_join(id)
		var made := adapter.directory(path)
		if not made.ok:
			return made
		var store := Store.new(adapter, path, record.value)
		var initialized: Dictionary = store.initialize()
		if not initialized.ok:
			return initialized
		prepared[id] = store
	return {"ok":true,"stores":prepared}

func commit(prepared: Dictionary) -> void:
	# Assignment only, inside the checked menu commitment interval.
	stores = prepared
	staged = {}
	consumers = {}
	delivered = {}
	epoch += 1

func edit(id: String, key: String, candidate: Variant) -> bool:
	if _busy or not stores.has(id) or not stores[id].definition.settings.has(key):
		return false
	var spec: Dictionary = stores[id].definition.settings[key]
	if not Definitions.valid_value(candidate, spec):
		return false
	if not staged.has(id):
		staged[id] = {}
	staged[id]["values/" + key] = int(candidate) if spec.type == "int" else candidate
	return true

func preset(id: String, preset_id: String) -> bool:
	if _busy or not stores.has(id) or not stores[id].definition.presets.has(preset_id):
		return false
	for key: String in stores[id].definition.presets[preset_id].values:
		edit(id, key, stores[id].definition.presets[preset_id].values[key])
	return true

func request_reset(id: String) -> bool:
	if _busy or not stores.has(id):
		return false
	reset_confirmation = id
	return true

func confirm_reset(id: String, confirmed: bool) -> bool:
	if _busy or reset_confirmation != id:
		return false
	reset_confirmation = ""
	if confirmed:
		for key: String in stores[id].definition.settings:
			edit(id, key, stores[id].definition.settings[key].default)
	return true

func cancel(id: String) -> void:
	if _busy:
		return
	staged.erase(id)
	if reset_confirmation == id:
		reset_confirmation = ""

## Consumer applies an indivisible group, returns true only after success; false
## must retain/restore old working values. Reversion failure uses CORE recovery.
## current(ticket) is a pure, owner-scoped validity predicate checked before/after.
func bind(id: String, group: String, consumer: RefCounted, ticket: Dictionary) -> bool:
	if _busy or not stores.has(id) or not stores[id].groups.has(group) or consumer == null or not consumer.has_method("preferences_current") or not consumer.has_method("apply_preferences") or not consumer.preferences_current(ticket):
		return false
	var values := group_values(stores[id], group, false)
	_busy = true
	var applied: bool = consumer.apply_preferences(values.duplicate(true), ticket.duplicate(true)) and consumer.preferences_current(ticket)
	_busy = false
	if not applied:
		return false
	consumers[id + "/" + group] = {"owner":weakref(consumer),"ticket":ticket.duplicate(true),"epoch":epoch}
	return true

func group_values(store: RefCounted, group: String, requested: bool) -> Dictionary:
	var result: Dictionary = {}
	for member: String in store.groups[group].members:
		result[member] = store.value(store.accepted, member) if requested else store.effective[member]
	return result

func consume(id: String, group: String, values: Dictionary) -> bool:
	var binding: Dictionary = consumers.get(id + "/" + group, {})
	if binding.is_empty() or binding.epoch != epoch:
		return false
	var owner: RefCounted = binding.owner.get_ref()
	if owner == null or not owner.preferences_current(binding.ticket):
		return false
	return owner.apply_preferences(values.duplicate(true), binding.ticket.duplicate(true)) and owner.preferences_current(binding.ticket)

func apply(id: String) -> Dictionary:
	if _busy or not stores.has(id):
		return {"ok":false,"reason":"Unknown mod or preference operation in progress."}
	_busy = true
	var store: RefCounted = stores[id]
	var result: Dictionary = store.apply(staged.get(id, {}), func(values: Dictionary):
		var member: String = values.keys()[0]
		var group: String = store.definition.settings[member.trim_prefix("values/")].group
		return consume(id, group, values))
	# Cancel after Apply cannot undo accepted values; rejected candidates are
	# explicitly retained in result rather than silently becoming accepted edits.
	if result.get("kind") != "rejected":
		staged.erase(id)
	status = result.duplicate(true)
	_busy = false
	return result

func retry(id: String) -> Dictionary:
	if _busy or not stores.has(id):
		return {"ok":false}
	_busy = true
	status = stores[id].save_accepted()
	_busy = false
	return status.duplicate(true)

func save_all() -> bool:
	for id: String in stores:
		if not retry(id).ok:
			return false
	return true

func register_boundary(kind: String, authority: RefCounted) -> bool:
	if kind not in ["next_session", "next_location"] or authority == null or not authority.has_method("preferences_boundary_current"):
		return false
	authorities[kind] = weakref(authority)
	return true

## Authority retains original operation/scope/generation ticket. Duplicate delivery
## returns the retained result; canceled/obsolete tickets cannot activate anything.
func activate(kind: String, authority: RefCounted, ticket: Dictionary) -> Dictionary:
	if _busy or not authorities.has(kind) or authorities[kind].get_ref() != authority or not authority.preferences_boundary_current(ticket):
		return {"ok":false,"kind":"stale_boundary"}
	var identity := kind + "/" + JSON.stringify(ticket)
	if delivered.has(identity):
		return delivered[identity].duplicate(true)
	_busy = true
	var rejected: Array = []
	for id: String in stores:
		var store: RefCounted = stores[id]
		for group: String in store.groups:
			if store.group_timing(group) != kind:
				continue
			var values := group_values(store, group, true)
			if values == group_values(store, group, false):
				continue
			if not authority.preferences_boundary_current(ticket) or not consume(id, group, values) or not authority.preferences_boundary_current(ticket):
				rejected.append(id + "/" + group)
				continue
			for member: String in values:
				store.effective[member] = values[member]
	var result := {"ok":rejected.is_empty(),"rejected":rejected,"boundary":kind}
	delivered[identity] = result.duplicate(true)
	_busy = false
	status = result.duplicate(true)
	return result

func projection(id: String) -> Dictionary:
	if not stores.has(id):
		return {}
	var store: RefCounted = stores[id]
	var values: Dictionary = {}
	for key: String in store.definition.settings:
		var member := "values/" + key
		values[key] = {"staged":staged.get(id, {}).get(member, store.value(store.accepted, member)),"accepted":store.value(store.accepted, member),"persisted":store.value(store.persisted, member),"effective":store.effective[member],"timing":store.group_timing(store.definition.settings[key].group)}
	return {"values":values,"pending":store.pending(),"unsaved":store.accepted.encode_to_text() != store.persisted.encode_to_text(),"status":status.duplicate(true),"recovery":store.last_result.duplicate(true)}
