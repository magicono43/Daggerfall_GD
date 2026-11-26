extends RefCounted
## Session-scoped provider validation and support-relative history. This helper
## never writes geometry, facing, CHAR or player pose; the coordinator commits.
const Paths = preload("res://scripts/mod/package_library.gd")
var core: RefCounted
var scope := ""
var provider: WeakRef
var source := ""
var policy: Dictionary = {}
var previous: Dictionary = {}
var attachment: Dictionary = {}
var _busy := false
var pending_commit: Dictionary = {}
var reconstruction_required := false

func bind(lifecycle: RefCounted, session: String, owner: RefCounted, identity: String, definition: String) -> Dictionary:
	if _busy or session.is_empty() or not Paths.valid_id(identity) or not lifecycle.activity_owner(session,owner,identity,"motion") or not owner.has_method("mechanism_sample") or not owner.has_method("mechanism_current") or not owner.has_method("mechanism_commit") or not owner.has_method("mechanism_checkpoint") or not owner.has_method("mechanism_checkpoint_current"): return {"ok":false,"reason":"Current bound mechanism provider and state checkpoint contract required."}
	var found: Dictionary = lifecycle.actors.definitions.query("move.mechanism","policy",definition)
	if not found.ok: return found
	core = lifecycle
	scope = session
	provider = weakref(owner)
	source = identity
	policy = found.record.value.duplicate(true)
	previous.clear()
	attachment.clear()
	pending_commit.clear()
	reconstruction_required = false
	return {"ok":true,"native_save_ready":false}

static func transform_valid(value: Variant) -> bool:
	if not value is Transform3D or not value.origin.is_finite() or value.origin.length() > 1000000.0 or not value.basis.is_finite(): return false
	return value.basis.y.distance_to(Vector3.UP) < 0.000001 and absf(value.basis.determinant()-1.0) < 0.000001 and value.basis.is_equal_approx(value.basis.orthonormalized())

static func same_physics_transform(actual: Transform3D, expected: Transform3D) -> bool:
	return actual.origin.distance_to(expected.origin) <= 0.00001 and actual.basis.x.distance_to(expected.basis.x) <= 0.000001 and actual.basis.y.distance_to(expected.basis.y) <= 0.000001 and actual.basis.z.distance_to(expected.basis.z) <= 0.000001

func prepare(sequence: int, serial: int, delta: float) -> Dictionary:
	if _busy: return {"ok":false,"reason":"Mechanism sampling reentrant."}
	if provider == null: return {"ok":true,"sample":{}}
	if not pending_commit.is_empty(): return {"ok":false,"reason":"Mechanism acknowledgment pending; explicit retry required."}
	var owner: RefCounted = provider.get_ref()
	if owner == null or not core.activity_owner(scope,owner,source,"motion"):
		attachment.clear()
		return {"ok":false,"reason":"Mechanism provider retired; support detached."}
	var context := {"session":scope,"source":source,"sequence":sequence,"placement_serial":serial}
	_busy = true
	var value: Variant = owner.mechanism_sample(context.duplicate(true),delta)
	_busy = false
	if not value is Dictionary or value.size() != 8 or value.get("session") != scope or value.get("source") != source or not Paths.valid_id(value.get("support")) or typeof(value.get("revision")) != TYPE_INT or value.revision < 1 or value.revision > 1000000000 or not transform_valid(value.get("from")) or not transform_valid(value.get("to")) or not value.get("geometry") is StaticBody3D or not is_instance_valid(value.geometry) or not value.get("dimensions") is Vector3 or not value.dimensions.is_finite() or value.dimensions.min_axis_index() < 0: return {"ok":false,"reason":"Complete finite upright mechanism sample required."}
	if value.dimensions.x <= 0 or value.dimensions.y <= 0 or value.dimensions.z <= 0 or value.dimensions.length() > 1000: return {"ok":false,"reason":"Finite bounded mechanism dimensions required."}
	var geometry: StaticBody3D = value.geometry
	if not same_physics_transform(PhysicsServer3D.body_get_state(geometry.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM),value.from): return {"ok":false,"reason":"Mechanism collision transform is not synchronized with its sample."}
	var shapes := geometry.find_children("*","CollisionShape3D",false,false)
	if not geometry.is_inside_tree() or geometry.global_transform != value.from or shapes.size() != 1 or not shapes[0].shape is BoxShape3D or shapes[0].disabled or shapes[0].transform != Transform3D.IDENTITY or shapes[0].shape.size != value.dimensions or geometry.collision_layer == 0: return {"ok":false,"reason":"Actual current single upright box collision geometry required."}
	if not previous.is_empty() and (value.support != previous.support or value.revision <= previous.revision or value.from != previous.to): return {"ok":false,"reason":"Stale/replaced/discontinuous mechanism history."}
	var yaw := wrapf(value.to.basis.get_euler().y-value.from.basis.get_euler().y,-PI,PI)
	var linear: Vector3 = (value.to.origin-value.from.origin)/delta
	if linear.length() > 100 or absf(yaw)/delta > TAU*4: return {"ok":false,"reason":"Mechanism motion exceeds qualified finite envelope."}
	_busy = true
	var current: Variant = owner.mechanism_current(value.duplicate(true))
	_busy = false
	if typeof(current) != TYPE_BOOL or not current or not core.activity_owner(scope,owner,source,"motion"): return {"ok":false,"reason":"Mechanism sample attestation failed."}
	return {"ok":true,"sample":value.duplicate(true),"yaw":yaw,"linear":linear,"angular":Vector3.UP*yaw/delta,"policy":policy.duplicate(true)}

func commit(sample: Dictionary) -> Dictionary:
	if _busy or provider == null or sample.is_empty(): return {"ok":false,"reason":"Prepared mechanism required."}
	if reconstruction_required or (not pending_commit.is_empty() and pending_commit != sample): return {"ok":false,"reason":"Original mechanism debt/reconstruction must settle first."}
	var owner: RefCounted = provider.get_ref()
	if owner == null or not core.activity_owner(scope,owner,source,"motion"): return {"ok":false,"reason":"Mechanism provider retired before commitment."}
	_busy = true
	var result: Variant = owner.mechanism_commit(sample.duplicate(true))
	_busy = false
	if core.snapshot().session != scope or provider == null or not core.activity_owner(scope,owner,source,"motion"): return {"ok":false,"retired":true,"reason":"Mechanism lifetime retired during commitment."}
	if not is_instance_valid(sample.geometry) or not same_physics_transform(sample.geometry.global_transform,sample.to) or not same_physics_transform(PhysicsServer3D.body_get_state(sample.geometry.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM),sample.to):
		var changed: bool = not is_instance_valid(sample.geometry) or sample.geometry.global_transform != sample.from
		if changed:
			pending_commit = sample.duplicate(true)
			reconstruction_required = true
		return {"ok":false,"reason":"Mechanism commitment requires retained recovery.","changed":changed}
	previous = sample.duplicate(true)
	if typeof(result) != TYPE_BOOL or not result: pending_commit = sample.duplicate(true)
	elif pending_commit == sample: pending_commit.clear()
	return {"ok":true,"receipt_pending":not pending_commit.is_empty()}

func retry_commit() -> Dictionary:
	if pending_commit.is_empty(): return {"ok":true,"unchanged":true}
	if reconstruction_required: return {"ok":false,"reason":"Changed geometry requires checked owner reconstruction; acknowledgment cannot replay a physical plan."}
	var origin := scope
	var retained := pending_commit.duplicate(true)
	var result := commit(retained)
	if scope != origin or result.get("retired",false): return {"ok":false,"retired":true,"reason":"Mechanism acknowledgment scope retired."}
	return {"ok":result.get("ok",false) and pending_commit.is_empty()}

func detach() -> void:
	attachment.clear()

static func checkpoint_value(value: Variant, depth: int, budget: Array) -> bool:
	budget[0] += 1
	if depth > 8 or budget[0] > 4096: return false
	match typeof(value):
		TYPE_BOOL, TYPE_INT: return true
		TYPE_FLOAT: return is_finite(value)
		TYPE_STRING: return value.length() <= 4096
		TYPE_VECTOR3: return value.is_finite()
		TYPE_TRANSFORM3D: return value.origin.is_finite() and value.basis.is_finite()
		TYPE_DICTIONARY:
			if value.size() > 64: return false
			for key in value:
				if not key is String or key.length() > 128 or not checkpoint_value(value[key],depth+1,budget): return false
			return true
		TYPE_ARRAY:
			for item in value:
				if not checkpoint_value(item,depth+1,budget): return false
			return true
	return false

func checkpoint() -> Dictionary:
	if _busy or provider == null: return {"ok":false,"reason":"Current mechanism checkpoint provider required."}
	var owner: RefCounted = provider.get_ref()
	if owner == null or not core.activity_owner(scope,owner,source,"motion"): return {"ok":false,"reason":"Mechanism checkpoint scope retired."}
	_busy = true
	var state: Variant = owner.mechanism_checkpoint()
	_busy = false
	if not state is Dictionary or state.is_empty() or not checkpoint_value(state,0,[0]) or provider == null or core.snapshot().session != scope: return {"ok":false,"reason":"Bounded finite plain mechanism-owned checkpoint required."}
	return {"ok":true,"source":source,"previous":previous.duplicate(true),"attachment":attachment.duplicate(true),"provider_state":state.duplicate(true)}

func checkpoint_current(value: Dictionary) -> bool:
	if _busy or value.size() != 5 or value.get("ok") != true or value.get("source") != source or value.get("previous") != previous or value.get("attachment") != attachment or not value.get("provider_state") is Dictionary or not checkpoint_value(value.provider_state,0,[0]) or provider == null: return false
	var owner: RefCounted = provider.get_ref()
	if owner == null or not core.activity_owner(scope,owner,source,"motion"): return false
	if not previous.is_empty():
		if not is_instance_valid(previous.geometry) or not previous.geometry.is_inside_tree() or previous.geometry.collision_layer == 0 or not same_physics_transform(previous.geometry.global_transform,previous.to) or not same_physics_transform(PhysicsServer3D.body_get_state(previous.geometry.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM),previous.to): return false
		var shapes: Array = previous.geometry.find_children("*","CollisionShape3D",false,false)
		if shapes.size() != 1 or not shapes[0].shape is BoxShape3D or shapes[0].shape.size != previous.dimensions or shapes[0].disabled or shapes[0].transform != Transform3D.IDENTITY: return false
	_busy = true
	var valid: Variant = owner.mechanism_checkpoint_current(value.provider_state.duplicate(true))
	_busy = false
	return typeof(valid) == TYPE_BOOL and valid and provider != null and core.snapshot().session == scope and core.activity_owner(scope,owner,source,"motion")
