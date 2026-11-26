extends RefCounted
## Pure structural queries. Nested epoch-aligned periods permit union counting
## without enumerating records, even at the last partial native year.
const Calendar = preload("res://scripts/time/calendar.gd")
const PERIODS := {"new_hour":3600000,"midnight":Calendar.DAY,"new_day":Calendar.DAY,"new_month":30*Calendar.DAY,"new_year":Calendar.YEAR}

static func selected(markers: Variant) -> bool:
	if not markers is Array or markers.is_empty(): return false
	var seen := {}
	for marker: Variant in markers:
		if not marker is String or not PERIODS.has(marker) or seen.has(marker): return false
		seen[marker] = true
	return true

static func inspect(a: Variant, b: Variant, markers: Variant) -> Dictionary:
	if not Calendar.integer(a,0,Calendar.MAX) or not Calendar.integer(b,0,Calendar.MAX) or b < a or not selected(markers): return Calendar.failure("Checked forward endpoints and unique structural markers required.")
	var period: int = Calendar.YEAR
	for marker: String in markers: period = mini(period,PERIODS[marker])
	var count: int = b/period-a/period
	if count == 0: return {"ok":true,"count":0,"next":null}
	# count > 0 establishes representability before addition/multiplication.
	var t: int = a+(period-a%period)
	var matched: Array = []
	for marker: String in PERIODS:
		if t%int(PERIODS[marker]) == 0: matched.append(marker)
	return {"ok":true,"count":count,"next":{"timestamp":t,"markers":matched}}
