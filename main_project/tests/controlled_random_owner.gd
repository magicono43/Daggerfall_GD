extends "res://tests/controlled_session_provider.gd"
## Interface fixture, not CHAR/ITEM/QUEST/SAVE implementation. This owner alone
## authorizes fixture reward attempts, retains results and commits their effects.
const Mapping = preload("res://scripts/rule/random_mapping.gd")
var purposes: Array = ["combat", "progression", "loot", "quest"]
var facts: Dictionary = {}
var default_assigned_name := "Assigned fixture name"

func bindings() -> Array:
	return [{"role": "fixture_rewards", "owner": "controlled-random-owner-v1", "lifetime": "session",
		"required": true, "ready": true, "provider": self, "random_purposes": purposes.duplicate()}]

func initialize_baseline(ticket: Dictionary) -> Dictionary:
	facts = {"fixture": "retained-owner-v1", "assigned_name": default_assigned_name, "rewards": {}, "balance": 0, "applications": 0}
	return super.initialize_baseline(ticket)

func initialize(ticket: Dictionary, prepared: Dictionary) -> Dictionary:
	var saved: Dictionary = prepared.get("selection", {}).get("retained_owner", {})
	if not saved.is_empty():
		if saved.get("fixture") != "retained-owner-v1" or not saved.get("rewards") is Dictionary:
			return {"ok": false, "reason": "Unsupported controlled owner snapshot."}
		facts = saved.duplicate(true)
	return super.initialize(ticket, prepared)

func prepare_reward(id: String, source: RefCounted) -> Dictionary:
	if facts.rewards.has(id):
		return facts.rewards[id].resolution.duplicate(true)
	# Fixture semantics: a real new attempt gets one computed-35 percentile.
	var resolution := Mapping.percentile(35, source)
	if resolution.ok:
		facts.rewards[id] = {"resolution": resolution.duplicate(true), "applied": false, "acknowledged": false}
	return resolution

func deliver_reward(id: String, fault: String = "") -> Dictionary:
	if not facts.rewards.has(id):
		return {"ok": false, "error": "reward_not_prepared"}
	var reward: Dictionary = facts.rewards[id]
	if fault == "before_commit":
		return {"ok": false, "error": "delivery_interrupted"}
	if not reward.applied:
		facts.balance += reward.resolution.roll
		facts.applications += 1
		reward.applied = true
	if fault == "after_commit":
		return {"ok": false, "error": "acknowledgment_interrupted"}
	reward.acknowledged = true
	return {"ok": true}

func retained_snapshot() -> Dictionary:
	return facts.duplicate(true)
