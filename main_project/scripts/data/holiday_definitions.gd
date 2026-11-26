extends RefCounted
## DATA builds this index once per candidate. RULE reads narrow detached matches.
const DOMAIN := "rule.holidays"
const VERSION := "regional-holidays-v1"
const Geography = preload("res://scripts/data/geography_inputs.gd")
const Numbers = preload("res://scripts/data/calendar_policy.gd")
var _ticket := -1
var _valid := false
var _regions := {}
var _days := {}

func declaration() -> Dictionary:
	return {"id":VERSION,"domain":DOMAIN,"reference_domains":[DOMAIN,Geography.DOMAIN],"operations":["add","replace","patch"],"required_resources":["annual"],"capabilities":["data."+VERSION]}

func validate_resource_path(path: String) -> String:
	return "" if path == "annual" else "Use annual holiday resource."

func bundled_contributions() -> Array:
	return [{"root":"res://content/time","file":"holidays.json","version":VERSION,"bytes":FileAccess.get_file_as_bytes("res://content/time/holidays.json")}]

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var result := previous.duplicate(true)
	for field in fields: result[field] = fields[field]
	return {"ok":true,"value":result}

func validate_record(_id: String, value: Dictionary) -> String:
	if value.size() != 8 or value.get("schema") != VERSION or value.get("recurrence") != "annual-fixed-360" or not value.get("label") is String or value.label.is_empty() or not value.get("provenance") is Dictionary or value.provenance.is_empty(): return "Complete annual holiday definition/provenance required."
	if not Numbers.json_integer(value.get("day"),1,360) or not Numbers.json_integer(value.get("priority"),-1000000,1000000): return "Integral valid day/declared priority required."
	if not value.get("regions") is Array or value.regions.is_empty(): return "Explicit all-regions or region references required."
	var seen := {}
	for region in value.regions:
		if not region is String or seen.has(region) or (region != "*" and not Geography.valid_ref(region)) or (region == "*" and value.regions.size() != 1): return "Invalid/duplicate regional applicability."
		seen[region] = true
	if not Numbers.json_integer(value.get("classic_id"),0,53): return "Explicit classic adapter ID (zero for additions) required."
	return ""

func begin_candidate(_mods: RefCounted, ticket: int, _registry: RefCounted) -> void:
	_ticket = ticket
	_valid = false
	_regions.clear()
	_days.clear()

func validate_references(resources: Dictionary) -> Array:
	var issues: Array = []
	for key: String in resources:
		if key.begins_with(Geography.DOMAIN+":"):
			for id: String in resources[key].records:
				if resources[key].records[id].value.kind == "region": _regions[key.trim_prefix(Geography.DOMAIN+":")+"#"+id] = true
	var classic := {}
	for id: String in resources.get(DOMAIN+":annual",{}).get("records",{}):
		var record: Dictionary = resources[DOMAIN+":annual"].records[id]
		var v: Dictionary = record.value
		for region: String in v.regions:
			if region != "*" and not _regions.has(region): issues.append({"source":id,"reason":"Unknown holiday region: "+region})
		if int(v.classic_id) != 0:
			if classic.has(int(v.classic_id)): issues.append({"source":id,"reason":"Ambiguous classic holiday mapping."})
			classic[int(v.classic_id)] = id
		var day := int(v.day)
		if not _days.has(day): _days[day] = []
		_days[day].append({"id":id,"day":day,"priority":int(v.priority),"label":v.label,"regions":v.regions.duplicate(),"classic_id":int(v.classic_id),"provenance":v.provenance.duplicate(true),"fields":record.fields.duplicate(true),"identity":record.identity.duplicate(true)})
	for day: int in _days:
		_days[day].sort_custom(func(a: Dictionary,b: Dictionary): return a.priority > b.priority if a.priority != b.priority else a.id < b.id)
	return issues

func finish_candidate(_resources: Dictionary, valid: bool) -> void:
	_valid = valid
	if not valid:
		_regions.clear()
		_days.clear()

func point_query(ticket: int, context: Dictionary) -> Dictionary:
	if not _valid or ticket != _ticket: return {"ok":false,"kind":"before_readiness","reason":"Exact published holiday index required."}
	var region: Variant = context.get("region")
	var day: Variant = context.get("day")
	if not region is String or not _regions.has(region): return {"ok":false,"kind":"invalid_region","reason":"Explicit resolved geography region reference required."}
	if not preload("res://scripts/time/calendar.gd").integer(day,1,360): return {"ok":false,"kind":"invalid_date","reason":"Valid native calendar day required."}
	var matches: Array = []
	for holiday: Dictionary in _days.get(day,[]):
		if "*" in holiday.regions or region in holiday.regions: matches.append(holiday.duplicate(true))
	return {"ok":true,"region":region,"day":day,"holidays":matches,"ordering":"priority-descending-id-ascending-v1","content_ticket":ticket}
