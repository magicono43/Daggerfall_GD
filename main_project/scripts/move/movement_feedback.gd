extends RefCounted
## Committed distance/event projection. No health, activity, input or body writes.
## This seam is independent of audible delivery and future NPC hearing policy.
signal cue(value: Dictionary)
signal noise_distance(value: Dictionary)
const Policy = preload("res://scripts/data/movement_feedback_policy.gd")
var policy: Dictionary = {}
var scope := ""
var actor := ""
var serial := -1
var sequence := 0
var phase := 0.0 # Fraction of the current gait stride, retained across seams/gaits.
var steps := 0
var cue_sequence := 0
var _landings: Dictionary = {}
var _water: Dictionary = {}
var _water_contacts: Dictionary = {}
var _solid_contacts: Dictionary = {}
var _busy := false

func bind(session: String, definition: Dictionary, player := "player") -> bool:
	if _busy or session.is_empty() or not Policy.Paths.valid_id(player) or not Policy.reason(definition).is_empty(): return false
	policy = definition.duplicate(true)
	actor = player
	reset(session,-1)
	return true

func reset(session: String, placement_serial: int, after_sequence := 0) -> void:
	if scope != session:
		_landings.clear()
		_water.clear()
		_water_contacts.clear()
		_solid_contacts.clear()
		cue_sequence = 0
	scope = session
	serial = placement_serial
	sequence = after_sequence
	phase = 0.0
	steps = 0

func movement(m: Dictionary, category: String, eligible: bool) -> Dictionary:
	if _busy or scope.is_empty() or m.get("session") != scope or typeof(m.get("sequence")) != TYPE_INT or not Policy.Paths.valid_id(category) or typeof(eligible) != TYPE_BOOL: return {"ok":false,"reason":"Current ordered committed feedback context required."}
	var distance: Variant = m.get("surface_distance",0.0)
	var gait: Variant = m.get("gait",{}).get("gait")
	if not Policy.finite(distance,0,100.0) or not policy.strides.has(gait): return {"ok":false,"reason":"Finite supported voluntary distance/gait required."}
	if typeof(m.get("placement_serial")) != TYPE_INT or m.placement_serial < 1 or m.placement_serial < serial: return {"ok":false,"reason":"Retired movement placement cannot reset a newer feedback baseline."}
	if serial != m.get("placement_serial"):
		reset(scope,m.placement_serial)
	if m.sequence <= sequence: return {"ok":false,"reason":"Repeated/stale committed feedback sequence."}
	sequence = m.sequence
	_busy = true
	var origin := scope
	# Ground surface_distance already excludes passive displacement and corrections.
	var actual: float = distance if eligible else 0.0
	var total: float = phase+actual/policy.strides[gait]
	var count := int(floor(total))
	phase = total-count
	var first := steps+1
	steps += count
	var projection := {"session":scope,"actor":actor,"id":"travel-"+str(serial)+"-"+str(sequence),"sequence":sequence,"metres":actual,"category":category,"gait":gait,"steps":count,"first_step":first,"phase":phase}
	# A compact range preserves every crossed step for a future gameplay consumer;
	# AV may omit obsolete sounds without changing this authoritative projection.
	noise_distance.emit(projection.duplicate(true))
	if scope != origin:
		_busy = false
		return {"ok":false,"retired":true}
	if count > 0 and not _water_contacts.has(str(serial)+"/"+str(m.get("contact",""))) and (m.get("landing",{}).is_empty() or m.get("separate_step_contact",false)):
		var clips: Array = policy.surfaces.get(category,[])
		_emit_cue({"session":scope,"actor":actor,"placement_serial":serial,"id":"step-"+str(serial)+"-"+str(sequence)+"-"+str(steps),"kind":"step","category":category,"ordinal":int(clips[(steps-1)%clips.size()]) if not clips.is_empty() else -1,"omitted_steps":count-1,"sequence":sequence})
	_busy = false
	return {"ok":true,"projection":projection}

func landing(outcome: Dictionary, movement_sequence := -1) -> bool:
	if _busy or scope.is_empty() or outcome.get("session") != scope or outcome.get("phase") != "committed" or not outcome.get("id") is String or typeof(outcome.get("hard")) != TYPE_BOOL: return false
	if outcome.get("placement_serial",serial) != serial: return false
	var key: String = str(serial)+"/"+outcome.id
	if _landings.has(key): return _landings[key] == outcome
	if _landings.size() >= 4096: return false
	_landings[key] = outcome.duplicate(true)
	_solid_contacts[str(serial)+"/"+str(outcome.get("contact",outcome.id))] = true
	if outcome.hard and not _water_contacts.has(str(serial)+"/"+str(outcome.get("contact",outcome.id))):
		_busy = true
		_emit_cue({"session":scope,"actor":actor,"placement_serial":serial,"id":"landing-"+str(serial)+"-"+outcome.id,"kind":"landing","ordinal":int(policy.damage_clip if outcome.get("damage",0) > 0 else policy.hard_clip),"sequence":movement_sequence if movement_sequence >= 0 else sequence})
		_busy = false
	return true

## Presentation-only receipt seam for future MOVE-014. Controlled qualification
## does not enter water, protect a fall, change posture or establish water gameplay.
func water_entry(outcome: Dictionary) -> bool:
	if _busy or scope.is_empty() or outcome.size() != 9 or outcome.get("session") != scope or outcome.get("actor") != actor or outcome.get("phase") != "committed" or not outcome.get("id") is String or outcome.id.is_empty() or outcome.id.length() > 512 or not Policy.Paths.valid_id(outcome.get("volume")) or not Policy.Paths.valid_id(outcome.get("contact")) or typeof(outcome.get("solid_first")) != TYPE_BOOL or outcome.solid_first or outcome.get("placement_serial") != serial or typeof(outcome.get("sequence")) != TYPE_INT or outcome.sequence < sequence: return false
	var key: String = str(serial)+"/"+outcome.id
	if _water.has(key): return _water[key] == outcome
	if _water.size() >= 4096 or _water_contacts.size() >= 4096: return false
	var contact: String = str(serial)+"/"+outcome.contact
	# A previously committed solid impact wins; the water owner must resolve
	# solid/volume ordering before dispatching a new combined contact.
	if not _water_contacts.has(contact) and _solid_contacts.has(contact): return false
	_water[key] = outcome.duplicate(true)
	if _water_contacts.has(contact): return true
	_water_contacts[contact] = true
	_busy = true
	_emit_cue({"session":scope,"actor":actor,"placement_serial":serial,"id":"splash-"+key,"kind":"splash","ordinal":int(policy.splash_clip),"sequence":outcome.sequence})
	_busy = false
	return true

func _emit_cue(value: Dictionary) -> void:
	cue_sequence += 1
	value.cue_sequence = cue_sequence
	cue.emit(value)
