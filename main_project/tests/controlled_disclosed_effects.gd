extends RefCounted
## MAGIC-010 read-model fixture. Hidden gameplay entries never cross this seam.
var revision := 1
var groups: Array = []
var hidden: Array = [{"id":"secret","label":"must-not-disclose"}]
var snapshots := 0
func disclosed_effects_revision(_scope: String, _actor: String) -> int:
	return revision
func binding() -> Dictionary:
	return {"role":"controlled-disclosed-effects","owner":"MAGIC","lifetime":"session","required":true,"ready":true,"provider":self,"disclosed_effects":true}
func disclosed_effects(_scope: String, _actor: String) -> Dictionary:
	snapshots += 1
	return {"schema":"disclosed-effects-v1","revision":revision,"groups":groups.duplicate(true)}
