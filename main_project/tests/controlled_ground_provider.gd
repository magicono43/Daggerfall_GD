extends "res://tests/controlled_activity_provider.gd"
## Controlled TIME/traits/restrictions only; physical motion and CHAR are real.
var game := 0
var simulated := 0
var serial := 0
var fractional := 0.0
var proposed: Dictionary = {}
var voluntary := true
var run_policy := "allow"
var reject_activity := false
var athleticism := false
var improved := false
var argonian := false
var source_request: Dictionary = {}
var trait_snapshots: Dictionary = {}
var capture_revisions: Dictionary = {}
func ground_source_current(request: Dictionary) -> bool: return valid and request == source_request

func ground_interval(_context: Dictionary, delta: float) -> Dictionary:
	if gates == null or not gates.simulation(): return {"ok":false}
	var duration := int(round(delta*1000000.0+fractional))
	proposed = {"duration":duration,"fractional":delta*1000000.0+fractional-duration}
	return {"ok":true,"provider":{"id":id,"revision":revision},"clock":{"domain":"eligible-activity","interval":"ground-interval-"+str(serial+1),"start_game":game,"end_game":game+duration*12,"start_sim":simulated,"end_sim":simulated+duration,"game_unit":"game-microsecond","simulation_unit":"simulated-microsecond","numerator":12,"denominator":1,"ownership":"ordinary"}}
func capture_ground(r: Dictionary) -> bool:
	if not gates.simulation(): return false
	var previous: Dictionary = committed.get(r.operation,{})
	if previous.is_empty():
		if r.clock.start_game != game or r.clock.start_sim != simulated: return false
	else:
		if previous.context != r.context or previous.providers != r.providers or previous.clock.end_game != game or previous.clock.end_sim != simulated or previous.clock.start_game != r.clock.start_game or previous.clock.start_sim != r.clock.start_sim: return false
	if r.clock.end_sim != simulated+proposed.duration or r.clock.end_game != game+proposed.duration*12: return false
	committed[r.operation] = r.duplicate(true)
	if not capture_revisions.has(r.operation): capture_revisions[r.operation] = []
	if r.revision not in capture_revisions[r.operation]: capture_revisions[r.operation].append(r.revision)
	game = r.clock.end_game
	simulated = r.clock.end_sim
	fractional = proposed.fractional
	serial += 1
	return true
func ground_traits(_context: Dictionary) -> Dictionary:
	var snapshot := {"ok":true,"revision":revision,"athleticism":athleticism,"improved_athleticism":improved,"argonian":argonian}
	if trait_snapshots.has(revision) and trait_snapshots[revision] != snapshot: return {"ok":false}
	trait_snapshots[revision] = snapshot.duplicate(true)
	return snapshot
func ground_restrictions(_context: Dictionary) -> Dictionary:
	return {"ok":true,"revision":revision,"voluntary":voluntary,"run":run_policy}
func activity_current(r: Dictionary) -> bool:
	if reject_activity: return false
	if callback.is_valid(): callback.call()
	if not valid: return false
	if "interval" in roles:
		var original: Dictionary = committed.get(r.operation,{}).duplicate(true)
		if original.is_empty(): return false
		# Actor admission revision can be assigned after an earlier performed segment
		# settles; original physical revision in committed remains immutable.
		original.revision = r.revision
		return original == r
	var snapshot: Dictionary = trait_snapshots.get(r.providers.get("traits",{}).get("revision"),{})
	return not snapshot.is_empty() and r.providers.traits.id == id and r.context.motion.athleticism == snapshot.athleticism and r.context.motion.improved_athleticism == snapshot.improved_athleticism and r.context.argonian == snapshot.argonian
