extends RefCounted
## Labelled interface fixtures. This implements no real MOVE/TIME/NPC gameplay.
var id := ""
var domain := ""
var roles: Array = []
var revision := 1
var active: Dictionary = {}
var valid := true
var callback := Callable()
var swimming := false
var threat := false
var fail_query := false
var malformed := false
var elapsed := 3600000000
var time_phase := "completed"
var events: Array = [true,true,true]
var health_allowed := true
var fatigue_allowed := true
var magicka_allowed := true
var no_magicka := false
var rapid := "none"
var environment := "darkness"
var calls := {}
var gates: SessionGates
var committed: Dictionary = {}

func capture_eligible(request: Dictionary) -> bool:
	if gates == null or not gates.simulation(): return false
	committed[request.operation] = request.duplicate(true)
	return true

func _init(identity: String, owner_domain: String, owned_roles: Array) -> void:
	id = identity
	domain = owner_domain
	roles = owned_roles
func binding() -> Dictionary:
	return {"role":id,"owner":domain,"lifetime":"session","required":true,"ready":true,"provider":self,"actor_activity":{"id":id,"roles":roles.duplicate()}}
func activity_current(r: Dictionary) -> bool:
	if callback.is_valid(): callback.call()
	if not valid or r != active: return false
	if gates != null and "interval" in roles and r.kind != "exhaustion" and r.clock.ownership == "ordinary" and not gates.simulation() and committed.get(r.operation,{}) != r: return false
	for role: String in roles:
		if r.providers.has(role) and r.providers[role] != {"id":id,"revision":revision}: return false
	return true
func activity_snapshot(_r: Dictionary) -> Dictionary:
	if fail_query: return {"ok":false}
	if malformed and "threat" in roles: return {"ok":1,"revision":revision,"purpose":"exhaustion","threat":true}
	if malformed and "resolution" in roles: return {"ok":true,"revision":float(revision),"resolved":1}
	if "motion" in roles: return {"ok":true,"revision":revision,"swimming":swimming}
	if "threat" in roles: return {"ok":true,"revision":revision,"purpose":"exhaustion","threat":threat}
	if "resolution" in roles: return {"ok":true,"revision":revision,"resolved":true}
	if "lethal" in roles: return {"ok":true,"revision":revision,"episode":_r.context.transition,"phase":"prevented"}
	return {"ok":true,"revision":revision,"rapid":rapid,"environment":environment,"health_allowed":health_allowed,"fatigue_allowed":fatigue_allowed,"magicka_allowed":magicka_allowed,"no_magicka":no_magicka}
func activity_execute(r: Dictionary) -> Dictionary:
	var key: String = r.actor+"/"+r.continuation.episode+"/"+r.continuation.step
	calls[key] = calls.get(key,0)+1
	if fail_query: return {"ok":false}
	if r.continuation.step == "stop": return {"ok":true,"revision":revision,"stopped":true}
	return {"ok":true,"revision":revision,"elapsed_usec":elapsed,"phase":time_phase,"events":events.duplicate()}
