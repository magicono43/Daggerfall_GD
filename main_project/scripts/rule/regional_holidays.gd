extends RefCounted
## RULE-028 pure lookup; no service benefits, clan assignment or notice history.
const Calendar = preload("res://scripts/time/calendar.gd")
const Domain = preload("res://scripts/data/holiday_definitions.gd")
static func query(definitions: RefCounted, region: Variant, timestamp: Variant) -> Dictionary:
	var date := Calendar.decode(timestamp)
	if not date.ok: return {"ok":false,"kind":"invalid_date","reason":"Valid native timestamp required."}
	if definitions == null: return {"ok":false,"kind":"unavailable","reason":"Resolved DATA required."}
	var result: Dictionary = definitions.point_query(Domain.DOMAIN,{"region":region,"day":date.day_of_year})
	if result.ok:
		result.year = date.year
		result.timestamp = timestamp
	return result
