extends RefCounted
## Resolved ITEM/MAGIC boundary only; no eligibility/stacking claim.
var revision := 1
var contributions: Array = []
var available := true
var status: Variant = true
var callback := Callable()
func resolve_actor_contributions(_context: Dictionary) -> Dictionary:
	if callback.is_valid(): callback.call()
	return {"ok":status,"revision":revision,"contributions":contributions.duplicate(true)} if available else {"ok":false}
