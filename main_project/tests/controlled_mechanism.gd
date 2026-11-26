extends "res://tests/controlled_ground_provider.gd"
## Controlled LOC/mechanism owner, actual static collision box. No player writes.
var geometry: StaticBody3D
var velocity := Vector3.ZERO # metres / eligible simulated second
var turn := 0.0 # radians / eligible simulated second
var support := "controlled-platform"
var motion_revision := 0
var sample: Dictionary = {}
var fail_commit := false
var lose_ack := false
var fail_sample := false
var commit_count := 0
var on_commit: Callable
var on_sample: Callable
var sample_edits: Dictionary = {}
var limits: Dictionary = {} # Authored trajectory endpoints, independent of player.

func mechanism_checkpoint() -> Dictionary:
	if not is_instance_valid(geometry): return {}
	return {"schema":"controlled-mechanism-state-v1","source":id,"support":support,"revision":motion_revision,"transform":geometry.global_transform,"velocity":velocity,"turn":turn,"limits":limits.duplicate(true)}

func mechanism_checkpoint_current(state: Dictionary) -> bool:
	return valid and velocity.is_finite() and velocity.length() <= 100.0 and is_finite(turn) and absf(turn) <= TAU*4 and state == mechanism_checkpoint()

func mechanism_sample(context: Dictionary, delta: float) -> Dictionary:
	if fail_sample or not is_instance_valid(geometry): return {}
	var start := geometry.global_transform
	var target := Transform3D((Basis(Vector3.UP,turn*delta)*start.basis).orthonormalized(),start.origin+velocity*delta)
	if not limits.is_empty(): target.origin = target.origin.clamp(limits.minimum,limits.maximum)
	var collision: CollisionShape3D = geometry.get_child(0)
	sample = {"session":context.session,"source":id,"support":support,"revision":motion_revision+1,"from":start,"to":target,"geometry":geometry,"dimensions":collision.shape.size}
	for field in sample_edits: sample[field] = sample_edits[field]
	if on_sample.is_valid(): on_sample.call()
	return sample.duplicate(true)

func mechanism_current(value: Dictionary) -> bool:
	return valid and value == sample and is_instance_valid(geometry) and geometry.global_transform == value.from

func mechanism_commit(value: Dictionary) -> bool:
	if fail_commit or not valid or not is_instance_valid(geometry): return false
	if value == sample and geometry.global_transform == value.to and motion_revision == value.revision: return not lose_ack
	if value != sample or geometry.global_transform != value.from or value.revision != motion_revision+1: return false
	geometry.global_transform = value.to
	geometry.force_update_transform()
	motion_revision = value.revision
	commit_count += 1
	if on_commit.is_valid(): on_commit.call()
	return not lose_ack
