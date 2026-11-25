extends RefCounted
## Plain owner state; this helper never moves a body or mutates CHAR.
var airborne := false
var velocity := Vector3.ZERO
var takeoff: Dictionary = {}
var peak := 0.0
var origin_y := 0.0
var segment := 0
var protections: Dictionary = {}
var outcomes: Dictionary = {}
var pending: Dictionary = {}

func begin(base_y: float, initial_velocity: Vector3, captured: Dictionary) -> void:
	airborne = true
	velocity = initial_velocity
	takeoff = captured.duplicate(true)
	segment += 1
	peak = base_y+origin_y

func observe(base_y: float) -> void:
	if protections.is_empty(): peak = maxf(peak,base_y+origin_y)
	else: peak = base_y+origin_y

func protection(source: String, active: bool, base_y: float) -> void:
	var previously := not protections.is_empty()
	if active: protections[source] = true
	else: protections.erase(source)
	if previously != not protections.is_empty():
		peak = base_y+origin_y
		if not active: segment += 1

func land(base_y: float, scale: float) -> Dictionary:
	var distance := maxf(0.0,(peak-base_y-origin_y)/scale) if protections.is_empty() else 0.0
	airborne = false
	velocity = Vector3.ZERO
	pending = {"id":"landing-"+str(segment),"segment":segment,"distance":distance,"protected":not protections.is_empty(),"protections":protections.keys(),"takeoff":takeoff.duplicate(true),"phase":"resolved-distance"}
	return pending.duplicate(true)

func snapshot() -> Dictionary:
	return {"schema":"move-air-state-v1","airborne":airborne,"velocity":velocity,"takeoff":takeoff.duplicate(true),"peak":peak,"origin_y":origin_y,"segment":segment,"protections":protections.duplicate(true),"outcomes":outcomes.duplicate(true),"pending":pending.duplicate(true)}

static func valid(s: Variant) -> bool:
	if not s is Dictionary or s.size() != 10 or s.get("schema") != "move-air-state-v1" or typeof(s.get("airborne")) != TYPE_BOOL or not s.get("velocity") is Vector3 or not s.velocity.is_finite() or s.velocity.length() > 2000.0: return false
	for field in ["peak","origin_y"]:
		if not s.get(field) is float or not is_finite(s[field]) or absf(s[field]) > 1e12: return false
	if typeof(s.get("segment")) != TYPE_INT or s.segment < 0 or s.segment > 1000000000: return false
	for field in ["takeoff","protections","outcomes","pending"]:
		if not s.get(field) is Dictionary: return false
	return s.protections.size() <= 65 and s.outcomes.size() <= 4096

func restore(s: Dictionary) -> void:
	airborne = s.airborne
	velocity = s.velocity
	takeoff = s.takeoff.duplicate(true)
	peak = s.peak
	origin_y = s.origin_y
	segment = s.segment
	protections = s.protections.duplicate(true)
	outcomes = s.outcomes.duplicate(true)
	pending = s.pending.duplicate(true)
