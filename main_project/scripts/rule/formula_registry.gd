extends RefCounted
## Bounded pure integer replacement hooks. MOD attests identity/order; CORE owns
## publication and session/operation admission. No executable package code loader.
const Monitor = preload("res://scripts/rule/formula_error_monitor.gd")
const CONTRACT := "integer-formula-v1"
var _hooks: Dictionary = {}
var _contracts: Dictionary = {}
var _builtin_owners: Dictionary = {} # Callable itself does not retain RefCounted.
var _contributions: Array = []
var _candidate: Dictionary = {}
var _active: Dictionary = {}
var _omissions: Dictionary = {}
var _omission_input := ""
var _revision := 0
var _serial := 0
var _reserved := -1
var _invoking := false
var _last_failure: Dictionary = {}
var _disposed := false

func _editable() -> bool:
	return not _disposed and _active.is_empty() and _reserved < 0

func failure(kind: String, reason: String, provider := "", hook := "") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"provider":provider,"hook":hook,"source":"formula_hooks"}

func signature(callback: Variant, contract: String = CONTRACT) -> bool:
	if not callback is Callable or not callback.is_valid() or not callback.is_standard() or callback.get_bound_arguments_count() != 0 or callback.get_unbound_arguments_count() != 0:
		return false
	var object: Object = callback.get_object()
	if not object is RefCounted:
		return false
	for method: Dictionary in object.get_method_list():
		if method.name == callback.get_method():
			return method.args.size() == 1 and method.args[0].type == (TYPE_INT if contract == CONTRACT else TYPE_DICTIONARY) and method["return"].type == (TYPE_FLOAT if contract in ["ground-speed-v1","air-formula-v1"] else TYPE_INT) and method.default_args.is_empty() and (int(method.flags) & METHOD_FLAG_VARARG) == 0
	return false

func declare_integer_hook(id: String, builtin: Callable) -> Dictionary:
	if not _editable() or not _contributions.is_empty() or not _candidate.is_empty():
		return failure("registration_closed","Declare hooks before staging contributions.")
	if not preload("res://scripts/mod/package_library.gd").valid_id(id) or _hooks.has(id) or not signature(builtin):
		return failure("invalid_declaration","Hook identity/built-in signature invalid or duplicated.","@builtin",id)
	_hooks[id] = builtin
	_contracts[id] = CONTRACT
	_builtin_owners[id] = builtin.get_object()
	_revision += 1
	return {"ok":true}

func declare_actor_hook(id: String, builtin: Callable) -> Dictionary:
	var contract: String = preload("res://scripts/rule/actor_formulas.gd").CONTRACT
	if not _editable() or not _contributions.is_empty() or not _candidate.is_empty():
		return failure("registration_closed","Declare before preparation.")
	if id not in preload("res://scripts/rule/actor_formulas.gd").HOOKS or _hooks.has(id) or not signature(builtin,contract):
		return failure("invalid_declaration","Expected declared actor hook and (Dictionary) -> int.","@builtin",id)
	_hooks[id] = builtin
	_contracts[id] = contract
	_builtin_owners[id] = builtin.get_object()
	_revision += 1
	return {"ok":true}

func declare_ground_hook(builtin: Callable) -> Dictionary:
	var ground = preload("res://scripts/rule/ground_formulas.gd")
	if not _editable() or not _contributions.is_empty() or not _candidate.is_empty(): return failure("registration_closed","Declare before preparation.")
	if _hooks.has(ground.HOOK) or not signature(builtin,ground.CONTRACT): return failure("invalid_declaration","Expected pure ground (Dictionary) -> float hook.")
	_hooks[ground.HOOK] = builtin
	_contracts[ground.HOOK] = ground.CONTRACT
	_builtin_owners[ground.HOOK] = builtin.get_object()
	_revision += 1
	return {"ok":true}

func declare_air_hook(id: String, builtin: Callable) -> Dictionary:
	var air = preload("res://scripts/rule/air_formulas.gd")
	if not _editable() or not _contributions.is_empty() or not _candidate.is_empty(): return failure("registration_closed","Declare before preparation.")
	if id not in air.HOOKS or _hooks.has(id) or not signature(builtin,air.CONTRACT): return failure("invalid_declaration","Expected pure air (Dictionary) -> float hook.")
	_hooks[id] = builtin
	_contracts[id] = air.CONTRACT
	_builtin_owners[id] = builtin.get_object()
	_revision += 1
	return {"ok":true}

func declare_item_hook(id: String, builtin: Callable) -> Dictionary:
	var item = preload("res://scripts/rule/item_formulas.gd")
	if not _editable() or not _contributions.is_empty() or not _candidate.is_empty(): return failure("registration_closed","Declare before preparation.")
	if id not in item.HOOKS or _hooks.has(id) or not signature(builtin,item.CONTRACT): return failure("invalid_declaration","Expected pure item (Dictionary) -> int hook.")
	_hooks[id] = builtin
	_contracts[id] = item.CONTRACT
	_builtin_owners[id] = builtin.get_object()
	_revision += 1
	return {"ok":true}

func stage(provider: String, version: String, entries: Array, integration := "") -> Dictionary:
	if not _editable():
		return failure("locked","Formula registrations are reserved or locked until restart.",provider)
	# Staging is not validation/publication. Retain invalid input for explicit recovery.
	_contributions.append({"provider":provider,"version":version,"integration":integration,"entries":entries.duplicate(true)})
	_revision += 1
	_candidate.clear()
	_omissions.clear()
	return {"ok":true,"stage":"unvalidated"}

func declare_activity_hook(id: String, builtin: Callable) -> Dictionary:
	var activity = preload("res://scripts/rule/activity_formulas.gd")
	if not _editable() or not _contributions.is_empty() or not _candidate.is_empty(): return failure("registration_closed","Declare before preparation.")
	if id not in activity.HOOKS or _hooks.has(id) or not signature(builtin,activity.CONTRACT): return failure("invalid_declaration","Expected focused activity hook.")
	_hooks[id] = builtin
	_contracts[id] = activity.CONTRACT
	_builtin_owners[id] = builtin.get_object()
	_revision += 1
	return {"ok":true}

func replace_stage(provider: String, version: String, entries: Array, integration := "") -> Dictionary:
	if not _editable(): return failure("locked","Repair requires an editable application candidate.",provider)
	_contributions = _contributions.filter(func(c: Dictionary): return c.provider != provider)
	return stage(provider,version,entries,integration)

func _input(mods: RefCounted) -> String:
	return JSON.stringify({"revision":mods.revision,"planning":mods.planning_input(),"registrations":_revision})

func prepare(mods: RefCounted) -> Dictionary:
	if not _editable():
		return failure("locked","Formula configuration is reserved or locked.")
	_candidate.clear()
	_serial += 1
	var plan: Dictionary = mods.validate_dependencies()
	if not plan.ok:
		return failure("dependencies","A validated MOD plan is required.")
	var input := _input(mods)
	if input != _omission_input:
		_omissions.clear()
		_omission_input = input
	var issues: Array = []
	var registrations: Dictionary = {}
	var seen: Dictionary = {}
	var provenance: Array = []
	for contribution: Dictionary in _contributions:
		var provider: String = contribution.provider
		if _omissions.has(provider):
			continue
		var eligible: Dictionary = mods.formula_provider(provider,contribution.version,contribution.integration)
		if not eligible.ok:
			issues.append(failure("provider_ineligible",eligible.reason,provider))
		# Empty/malformed contributions are blocking rather than silently ignored.
		if contribution.entries.is_empty():
			issues.append(failure("invalid_registration","Empty formula contribution.",provider))
		for entry: Variant in contribution.entries:
			var hook: String = str(entry.get("hook","")) if entry is Dictionary else ""
			if not entry is Dictionary or not _hooks.has(hook):
				issues.append(failure("unknown_hook","Unknown or malformed hook registration.",provider,hook))
				continue
			var key := provider + ":" + hook
			if seen.has(key):
				issues.append(failure("duplicate_registration","Same-provider replacement duplicate.",provider,hook))
			seen[key] = true
			if entry.get("contract") != _contracts[hook] or not signature(entry.get("callback"),_contracts[hook]):
				issues.append(failure("signature","Expected unbound synchronous method for " + _contracts[hook] + ".",provider,hook))
				continue
			if eligible.ok:
				if not registrations.has(hook):
					registrations[hook] = {}
				registrations[hook][provider] = entry.callback
				provenance.append({"hook":hook,"provider":provider,"package":eligible.package.duplicate(true)})
	var winners: Dictionary = {}
	# Never retain/select partial winners if any contribution is invalid.
	if issues.is_empty():
		for hook: String in _hooks:
			winners[hook] = {"provider":"@builtin","callback":_hooks[hook]}
			for provider: String in plan.order:
				if registrations.get(hook,{}).has(provider):
					winners[hook] = {"provider":provider,"callback":registrations[hook][provider]}
	_candidate = {"ok":issues.is_empty(),"ticket":_serial,"input":input,"revision":mods.revision,
		"winners":winners,"issues":issues,"omissions":_omissions.keys(),"provenance":provenance,"plan":plan.duplicate(true)}
	return projection()

func projection() -> Dictionary:
	if _candidate.is_empty():
		return {}
	var result: Dictionary = _candidate.duplicate(true)
	result.erase("winners")
	result.winners = {}
	for hook: String in _candidate.winners:
		result.winners[hook] = _candidate.winners[hook].provider
	result.contract = CONTRACT
	result.hook_contracts = _contracts.duplicate(true)
	return result

func discard_candidate() -> void:
	if _editable():
		_candidate.clear()

func omit(provider: String, ticket: int, mods: RefCounted) -> Dictionary:
	if not _editable() or _candidate.get("ok",true) or ticket != _candidate.get("ticket") or _candidate.get("input") != _input(mods):
		return failure("stale","Omission requires the current failed formula candidate.",provider)
	var found := false
	for issue: Dictionary in _candidate.issues:
		found = found or issue.provider == provider
	if not found or provider.is_empty():
		return failure("invalid_omission","No invalid contribution belongs to this provider.",provider)
	_omissions[provider] = true
	_candidate.clear()
	return {"ok":true,"reason":"Formula contribution omitted; rebuild and revalidate MOD/declarations before entry."}

func reserve_commit(ticket: int, mods: RefCounted) -> Dictionary:
	if not _editable() or not _candidate.get("ok",false) or _candidate.ticket != ticket or _candidate.input != _input(mods):
		return failure("stale","Formula candidate is invalid or obsolete.")
	_reserved = ticket
	return {"ok":true}

func release_commit() -> void:
	_reserved = -1

func commit(ticket: int) -> Dictionary:
	# CORE reserves before menu/persistence callbacks. This assignment cannot fail.
	assert(_reserved == ticket)
	_active = _candidate
	_candidate = {}
	_reserved = -1
	return active()

func active() -> Dictionary:
	var result := {"locked":not _active.is_empty(),"contract":CONTRACT,"winners":{},"provenance":[],"last_failure":_last_failure.duplicate(true)}
	result.hook_contracts = _contracts.duplicate(true)
	if not _active.is_empty():
		result.ticket = _active.ticket
		result.provenance = _active.provenance.duplicate(true)
		for hook: String in _active.winners:
			result.winners[hook] = _active.winners[hook].provider
	return result

## Snapshot metadata only; callbacks and transient publication tickets stay here.
func item_persistence_compatibility() -> Dictionary:
	if _active.is_empty(): return {"ok":false,"kind":"before_readiness"}
	var result := {}
	for hook: String in _active.winners:
		if not hook.begins_with("item.") and hook != "char.capacity": continue
		var provider: String = _active.winners[hook].provider
		var version := "builtin-v1"
		for registration: Dictionary in _active.provenance:
			if registration.hook == hook and registration.provider == provider: version = str(registration.package.get("version",""))
		result[hook] = {"provider":provider,"version":version,"contract":_contracts[hook]}
	return {"ok":true,"hooks":result}

func _context(core: SessionLifecycle, owner: Object, hook: String, scope: String, operation: Dictionary) -> bool:
	return is_instance_valid(core) and core.formulas == self and (core.formula_owner_valid(scope,owner,hook) or core.actor_formula_valid(scope,owner,hook,operation) or core.creation_formula_valid(owner,hook,operation)) and core._plain_data(operation) and owner.formula_operation_current(operation.duplicate(true)) == true

func invoke(hook: String, value: Variant, core: SessionLifecycle, owner: Object, scope: String, operation: Dictionary) -> Dictionary:
	if _disposed or _active.is_empty() or not _active.winners.has(hook):
		return failure("before_readiness","No published formula hook.","",hook)
	var captured := operation.duplicate(true)
	if _invoking or not _context(core,owner,hook,scope,captured):
		return failure("stale_context","Current bound owner operation required.","",hook)
	var actor_contract: bool = _contracts[hook] != CONTRACT
	var valid: bool = preload("res://scripts/rule/activity_formulas.gd").valid_input(hook,value) if _contracts[hook] == "activity-formula-v1" else (preload("res://scripts/rule/actor_formulas.gd").valid_input(value) if actor_contract else typeof(value) == TYPE_INT and value >= -1000 and value <= 1000)
	var ground_contract: bool = _contracts[hook] == "ground-speed-v1"
	if ground_contract: valid = preload("res://scripts/rule/ground_formulas.gd").valid_input(value)
	var air_contract: bool = _contracts[hook] == "air-formula-v1"
	if air_contract: valid = preload("res://scripts/rule/air_formulas.gd").valid_input(hook,value)
	var item_contract: bool = _contracts[hook] == "item-formula-v1"
	if item_contract: valid = preload("res://scripts/rule/item_formulas.gd").valid_input(hook,value)
	if not valid:
		return failure("invalid_input","Input violates the published " + _contracts[hook] + " domain.","",hook)
	var selected: Dictionary = _active.winners[hook]
	if not selected.callback.is_valid():
		_last_failure = failure("callback_unavailable","Selected provider retired; no fallback.",selected.provider,hook)
		core.required_service_lost(scope,"formula:" + hook)
		return _last_failure.duplicate(true)
	var monitor := Monitor.new()
	_invoking = true
	OS.add_logger(monitor)
	var output: Variant = selected.callback.call(value.duplicate(true) if actor_contract else value)
	OS.remove_logger(monitor)
	_invoking = false
	var problem := ""
	if not monitor.errors.is_empty():
		problem = "callback_error"
	elif ((ground_contract or air_contract) and (typeof(output) != TYPE_FLOAT or not is_finite(output) or (output < 0.0 if hook == "move.landing-damage" else output <= 0.0) or output > (1000000000.0 if hook == "move.landing-damage" else 1e22) or (hook == "move.landing-damage" and output != floor(output)))) or (not ground_contract and not air_contract and (typeof(output) != TYPE_INT or output < (-1000000000000000 if actor_contract else -1000000) or output > (1000000000000000 if actor_contract else 1000000))):
		problem = "invalid_result"
	elif _disposed or not _context(core,owner,hook,scope,captured):
		problem = "stale_context"
	if problem.is_empty() and item_contract and not preload("res://scripts/rule/item_formulas.gd").valid_output(hook,value,output): problem = "invalid_result"
	if not problem.is_empty():
		_last_failure = failure(problem,"Selected formula failed; stop operation and recover without fallback.",selected.provider,hook)
		_last_failure.merge({"session":scope,"operation":captured.duplicate(true),"callback_errors":monitor.errors.duplicate(true),
			"output_type":typeof(output),"integer_output":output if typeof(output) == TYPE_INT else null})
		core.required_service_lost(scope,"formula:" + hook)
		return _last_failure.duplicate(true)
	return {"ok":true,"value":output,"provider":selected.provider,"hook":hook,"session":scope,"operation":captured.duplicate(true)}

func dispose() -> void:
	_disposed = true
	_hooks.clear()
	_builtin_owners.clear()
	_contracts.clear()
	_contributions.clear()
	_candidate.clear()
	_active.clear()
	_omissions.clear()
