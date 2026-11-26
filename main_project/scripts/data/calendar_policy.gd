extends RefCounted
const Calendar = preload("res://scripts/time/calendar.gd")
const DOMAIN := "time.calendar"
const VERSION := "calendar-clock-v1"
const RATE_SCALE := 1000000
func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN],"operations":["add","replace","patch"],"required_resources":["policy"],"capabilities":["data."+VERSION]}
func validate_resource_path(path: String) -> String:
	return "" if path == "policy" else "Only calendar policy supported."
func bundled_contributions() -> Array:
	return [{"root":"res://content/time","file":"calendar.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/time/calendar.json")}]
func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var result := previous.duplicate(true)
	for field in fields: result[field] = fields[field]
	return {"ok":true,"value":result}
static func json_integer(v: Variant, low: int, high: int) -> bool:
	return (v is int or v is float) and is_finite(float(v)) and v >= low and v <= high and float(v) == floor(float(v))
static func normalized(v: Dictionary) -> Dictionary:
	var result := v.duplicate(true)
	for field in result.opening: result.opening[field] = int(result.opening[field])
	for field in result.seasons: result.seasons[field] = int(result.seasons[field])
	for field in ["anchor_day","index"]:
		if result.weekday.has(field): result.weekday[field] = int(result.weekday[field])
	result.rate_units = int(round(result.rate*RATE_SCALE))
	return result
static func reason(v: Variant) -> String:
	if not v is Dictionary or v.size() != 6 or v.get("schema") != VERSION or not v.get("provenance") is Dictionary or v.provenance.is_empty(): return "Complete calendar policy/provenance required."
	if not v.get("opening") is Dictionary or v.opening.size() != 7: return "Complete opening date required."
	var bounds := {"year":[0,Calendar.MAX/Calendar.YEAR],"month":[1,12],"day":[1,30],"hour":[0,23],"minute":[0,59],"second":[0,59],"millisecond":[0,999]}
	var opening := {}
	for field in bounds:
		if not json_integer(v.opening.get(field),bounds[field][0],bounds[field][1]): return "Invalid opening: "+field
		opening[field] = int(v.opening[field])
	if not Calendar.encode(opening).ok: return "Opening exceeds native range."
	var rate: Variant = v.get("rate")
	if not (rate is int or rate is float) or not is_finite(float(rate)) or rate < 0.000001 or rate > 1000000.0: return "Rate requires finite 0.000001..1000000."
	if absf(rate*RATE_SCALE-round(rate*RATE_SCALE)) > 0.00001: return "Rate supports six decimal places."
	if not v.get("weekday") is Dictionary: return "Weekday policy required."
	var w: Dictionary = v.weekday
	if w.get("rule") == "monthly":
		if w.size() != 1: return "Monthly rule has no anchor."
	elif w.get("rule") == "continuous":
		if w.size() != 3 or not json_integer(w.get("anchor_day"),0,Calendar.MAX/Calendar.DAY) or not json_integer(w.get("index"),0,6): return "Continuous rule requires explicit absolute day anchor and index."
	else: return "Unsupported weekday rule."
	if not v.get("seasons") is Dictionary or v.seasons.size() != 4: return "Four season boundaries required."
	var seen := []
	for season in ["winter","spring","summer","fall"]:
		var day: Variant = v.seasons.get(season)
		if not json_integer(day,1,360) or int(day) in seen: return "Distinct season days 1..360 required."
		seen.append(int(day))
	return ""
func validate_record(id: String, value: Dictionary) -> String:
	return reason(value) if id == "world" else "Only world calendar policy supported."
func validate_references(resources: Dictionary) -> Array:
	return [] if resources.get(DOMAIN+":policy",{}).get("records",{}).has("world") else [{"source":DOMAIN,"reason":"Calendar policy missing."}]
