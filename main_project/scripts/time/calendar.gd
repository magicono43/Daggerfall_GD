extends RefCounted
## TIME numeric calendar. All divisions operate on nonnegative integers.
const MAX := 9223372036854775807
const DAY := 86400000
const YEAR := 31104000000
const CLASSIC_EPOCH := 12566016000000
const CLASSIC_MAX := 4294967295

static func integer(v: Variant, low: int, high: int) -> bool:
	return typeof(v) == TYPE_INT and v >= low and v <= high

static func failure(reason: String) -> Dictionary:
	return {"ok":false,"reason":reason}

static func encode(v: Variant) -> Dictionary:
	var bounds := {"year":[0,MAX/YEAR],"month":[1,12],"day":[1,30],"hour":[0,23],"minute":[0,59],"second":[0,59],"millisecond":[0,999]}
	if not v is Dictionary or v.size() != bounds.size(): return failure("Complete numeric date required.")
	for key in bounds:
		if not integer(v.get(key),bounds[key][0],bounds[key][1]): return failure("Invalid date field: "+key)
	var base: int = v.year*YEAR
	var offset: int = ((v.month-1)*30+v.day-1)*DAY+v.hour*3600000+v.minute*60000+v.second*1000+v.millisecond
	if offset > MAX-base: return failure("Date exceeds signed 64-bit native range.")
	return {"ok":true,"timestamp":base+offset}

static func decode(t: Variant) -> Dictionary:
	if not integer(t,0,MAX): return failure("Nonnegative native integer required.")
	var days: int = t/DAY
	var within: int = t%DAY
	return {"ok":true,"year":days/360,"month":(days%360)/30+1,"day":days%30+1,"day_of_year":days%360+1,"hour":within/3600000,"minute":(within/60000)%60,"second":(within/1000)%60,"millisecond":within%1000}

static func from_classic(m: Variant) -> Dictionary:
	if not integer(m,0,CLASSIC_MAX): return failure("Unsigned 32-bit classic minute required.")
	return {"ok":true,"timestamp":CLASSIC_EPOCH+m*60000}

static func to_classic(t: Variant) -> Dictionary:
	if not integer(t,CLASSIC_EPOCH,MAX): return failure("Instant precedes classic epoch or is invalid.")
	var minute: int = (t-CLASSIC_EPOCH)/60000
	if minute > CLASSIC_MAX: return failure("Instant exceeds classic minute range.")
	return {"ok":true,"minute":minute}

static func context(t: Variant, policy: Dictionary) -> Dictionary:
	var date := decode(t)
	if not date.ok: return date
	date.weekday = (date.day-1)%7
	if policy.weekday.rule == "continuous":
		# Reduce first, avoiding subtraction overflow at the native endpoints.
		date.weekday = posmod((t/DAY)%7-(policy.weekday.anchor_day%7)+policy.weekday.index,7)
	var best_distance := 361
	for season: String in policy.seasons:
		var distance: int = posmod(date.day_of_year-policy.seasons[season],360)
		if distance < best_distance:
			best_distance = distance
			date.season = season
	date.timestamp = t
	date.make_read_only()
	return date
