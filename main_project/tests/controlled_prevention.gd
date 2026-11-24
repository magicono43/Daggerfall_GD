extends RefCounted
## Labelled benefit-owner qualification, never real FACT/MAGIC/ITEM eligibility.
var ready := false
var sources: Array = [{"id":"controlled-benefit","revision":1,"priority":0}]
var successes := {"controlled-benefit":true}
var evaluations := {}
var costs := {}
var calls: Array = []
var fail_consumption := false
var malformed_evaluation := false
var callback: Callable
var randomness: RefCounted
var catalogs := 0

func binding() -> Dictionary:
	return {"role":"controlled-prevention","owner":"FACT","lifetime":"session","required":true,"ready":true,"provider":self,"death_prevention":"controlled-prevention","random_purposes":["combat"]}

func lethal_sources(_context: Dictionary) -> Dictionary:
	catalogs += 1
	return {"ok":ready,"provider":"controlled-prevention","revision":1,"sources":sources.duplicate(true)}

func key(c: Dictionary) -> String:
	return c.event.session+"/"+c.event.actor+"/"+c.event.caller+"/"+c.event.operation+"/"+c.source.id

func lethal_evaluate(context: Dictionary) -> Dictionary:
	var id := key(context)
	if not evaluations.has(id):
		calls.append(context.source.id)
		var receipt := {"controlled-decision":id}
		var success: bool = successes.get(context.source.id,false)
		if randomness != null:
			var handle: Dictionary = randomness.source(context.event.session,self,"combat")
			if not handle.ok: return {"ok":false}
			var draw: Dictionary = preload("res://scripts/rule/random_mapping.gd").percentile(100 if success else 0,handle.source)
			if not draw.ok: return {"ok":false}
			receipt["draw"] = draw
			success = draw.success
		evaluations[id] = {"ok":true,"source":context.source.id,"revision":context.source.revision,"success":success,"receipt":receipt}
	if callback.is_valid(): callback.call()
	var result: Dictionary = evaluations[id].duplicate(true)
	if malformed_evaluation: result.success = 1
	return result

func lethal_consume(context: Dictionary) -> Dictionary:
	var id := key(context)
	if not costs.has(id): costs[id] = {"ok":true,"source":context.source.id,"revision":context.source.revision,"receipt":{"controlled-cost":id}}
	# Simulates a lost postcommit response. Retry uses the same cost receipt.
	return {"ok":false} if fail_consumption else costs[id].duplicate(true)
