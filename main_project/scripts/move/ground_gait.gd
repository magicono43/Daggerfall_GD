extends RefCounted
## Requests are independent of actual physical travel and application settings.
const Configuration = preload("res://scripts/input/binding_configuration.gd")
const Policy = preload("res://scripts/data/ground_policy.gd")
var run_mode := "hold"
var sneak_mode := "hold"
var run_selected := false
var sneak_selected := false
var autorun := false
var _sequence := 0
var _scope := ""
var _sources: Dictionary = {}
var _source_owners: Dictionary = {}
var _updating := false
var formula: Callable

func can_configure(candidate: Dictionary) -> bool:
	return Configuration.valid(candidate)
func configure(candidate: Dictionary) -> bool:
	if not can_configure(candidate): return false
	run_mode = candidate.response.run_mode
	sneak_mode = candidate.response.sneak_mode
	return true
func reset(scope: String) -> void:
	_scope = scope
	_sequence = 0
	run_selected = false
	sneak_selected = false
	autorun = false
	_sources.clear()
	_source_owners.clear()
func interrupt(_reason: String) -> void:
	autorun = false
func edge(value: Dictionary, input: RefCounted) -> bool:
	if value.get("action") not in ["run","sneak","autorun"]: return false
	if not input.context_current(value) or value.get("session") != _scope or typeof(value.get("sequence")) != TYPE_INT or value.sequence <= _sequence: return true
	_sequence = value.sequence
	if value.get("kind") != "started": return true
	match value.action:
		"autorun": autorun = not autorun
		"run":
			if run_mode == "toggle": run_selected = not run_selected
		"sneak":
			if sneak_mode == "toggle": sneak_selected = not sneak_selected
	return true

## Revisioned source replacement is atomic; empty factors remove only this source.
## Retain tombstones so stale removal/re-addition cannot resurrect old values.
func source(owner: RefCounted, raw: Variant) -> Dictionary:
	if _updating or owner == null or not owner.has_method("ground_source_current"): return {"ok":false,"reason":"Bound nonreentrant speed source owner required."}
	if not raw is Dictionary or raw.size() != 5 or not preload("res://scripts/mod/package_library.gd").valid_id(raw.get("source")) or raw.get("session") != _scope or typeof(raw.get("revision")) != TYPE_INT or raw.revision < 1 or raw.revision > 1000000000 or raw.get("lifetime") != "session" or not raw.get("factors") is Dictionary: return {"ok":false,"reason":"Complete scoped speed source required."}
	for gait in raw.factors:
		var n: Variant = raw.factors[gait]
		if not gait is String or gait not in ["walk","run","sneak"] or not (n is int or n is float) or not is_finite(float(n)) or n < 0.000001 or n > 1000000: return {"ok":false,"reason":"Finite positive gait factors in 1e-6..1e6 required."}
	var old: Dictionary = _sources.get(raw.source,{})
	if not old.is_empty() and _source_owners[raw.source].get_ref() != owner: return {"ok":false,"reason":"Speed source belongs to another owner."}
	if not old.is_empty() and (raw.revision < old.revision or (raw.revision == old.revision and raw != old)): return {"ok":false,"reason":"Stale or changed source revision."}
	if old.is_empty() and _sources.size() >= 64: return {"ok":false,"reason":"Speed source retention exhausted."}
	_updating = true
	var attested: Variant = owner.ground_source_current(raw.duplicate(true))
	_updating = false
	if typeof(attested) != TYPE_BOOL or not attested or raw.session != _scope: return {"ok":false,"reason":"Speed source attestation failed or retired."}
	_sources[raw.source] = raw.duplicate(true)
	_source_owners[raw.source] = weakref(owner)
	return {"ok":true}

func resolve(input: RefCounted, capability: Dictionary, profile: Dictionary, forced_gait := "") -> Dictionary:
	if not Policy.reason(profile).is_empty(): return {"ok":false,"reason":"Ground profile unavailable."}
	for field in ["speed","running"]:
		if typeof(capability.get(field)) != TYPE_INT or capability[field] < 0 or capability[field] > 1000000000: return {"ok":false,"reason":"Unsupported live ground capability: "+field}
	var direction: Vector2 = input.movement()
	if not direction.is_finite(): return {"ok":false,"reason":"Nonfinite movement intent."}
	if direction.y > 0 or input.continuous_held("backward"): autorun = false
	if autorun: direction.y = -1.0
	direction = direction.limit_length()
	var running: bool = autorun or (input.continuous_held("run") if run_mode == "hold" else run_selected)
	var sneaking: bool = input.continuous_held("sneak") if sneak_mode == "hold" else sneak_selected
	if running:
		sneak_selected = false
		sneaking = false
	var gait := "run" if running else ("sneak" if sneaking else "walk")
	if not forced_gait.is_empty(): gait = forced_gait
	if not formula.is_valid(): return {"ok":false,"reason":"Required gait RULE provider unavailable."}
	var resolved: Variant = formula.call({"gait":gait,"profile":profile.duplicate(true),"speed":capability.speed,"running":capability.running})
	if not resolved is Dictionary or not resolved.get("ok",false): return {"ok":false,"reason":"Selected gait RULE provider failed; no fallback."}
	var speed: float = resolved.value
	if not is_finite(speed) or speed <= 0: return {"ok":false,"reason":"Selected gait formula is nonpositive or nonfinite."}
	var ids := _sources.keys()
	ids.sort()
	# Log-domain multiplication keeps all 64 validated factors representable
	# until the final cap, including opposing large/small contributions.
	var log_speed := log(speed)+log(float(profile.metres_per_speed_unit))
	for id in ids:
		if not _sources[id].factors.is_empty() and _source_owners[id].get_ref() == null: return {"ok":false,"reason":"Required speed source owner retired."}
		if not _sources[id].factors.is_empty():
			var captured: Dictionary = _sources[id].duplicate(true)
			_updating = true
			var current: Variant = _source_owners[id].get_ref().ground_source_current(captured.duplicate(true))
			_updating = false
			if typeof(current) != TYPE_BOOL or not current or captured.session != _scope: return {"ok":false,"reason":"Required speed source no longer current."}
		log_speed += log(float(_sources[id].factors.get(gait,1.0)))
	speed = exp(minf(log_speed,log(float(profile.maximum))))
	if not is_finite(speed) or speed <= 0: return {"ok":false,"reason":"World-speed mapping exceeded supported domain."}
	var revisions := {}
	for id in ids: revisions[id] = _sources[id].revision
	return {"ok":true,"gait":gait,"direction":direction,"target_metres_per_second":minf(speed,profile.maximum),"autorun":autorun,"source_revisions":revisions}
