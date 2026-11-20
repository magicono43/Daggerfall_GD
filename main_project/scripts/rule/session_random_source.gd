extends "res://scripts/rule/random_source.gd"
## A source capability bound to one current consumer, purpose and session epoch.
var _owner: RefCounted
var _consumer: WeakRef
var _scope: String
var _purpose: String
var _epoch: int

func _init(owner: RefCounted, scope: String, consumer: Object, purpose: String, epoch: int) -> void:
	_owner = owner
	_consumer = weakref(consumer)
	_scope = scope
	_purpose = purpose
	_epoch = epoch

func raw() -> Dictionary:
	var result: Dictionary = _owner.draw(_scope, _consumer.get_ref(), _purpose, _epoch, false)
	if result.ok:
		raw_count += 1
	return result

func bounded(bound: Variant) -> Dictionary:
	var result: Dictionary = _owner.draw(_scope, _consumer.get_ref(), _purpose, _epoch, true, bound)
	if result.ok:
		raw_count += result.raw_requests
		logical_count += 1
	return result
