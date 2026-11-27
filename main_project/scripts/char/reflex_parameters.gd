extends RefCounted
## Coupled character parameters. Pure queries never draw RNG or award practice.
const IDS = ["very-high","high","average","low","very-low"]

static func integer(value: Variant, low: int, high: int) -> bool:
	return value is int and value >= low and value <= high

static func reason(value: Variant) -> String:
	if not value is Dictionary or value.size() != IDS.size(): return "All five reflex definitions are required."
	for index in IDS.size():
		var p: Variant = value.get(IDS[index])
		if not p is Dictionary or p.size() != 5 or not p.get("label") is String or p.label.strip_edges().is_empty() or not integer(p.get("classic"),index,index): return "Reflex labels and explicit classic identities are required."
		if not integer(p.get("timer_adjustment"),-1000000,1000000) or not integer(p.get("component_percent"),0,100): return "Reflex timer/probability is outside the supported range."
		if not integer(p.get("practice_q16"),1,1048576): return "Reflex practice must be a positive Q16 multiplier at most 16."
	return ""

static func effective_practice(uses: Variant, parameters: Dictionary) -> Dictionary:
	# 2^42-1 uses times at most 2^20 fits signed 64-bit arithmetic.
	if not integer(uses,0,4398046511103) or not integer(parameters.get("practice_q16"),1,1048576): return {"ok":false,"reason":"Practice or multiplier is outside the safe integer domain."}
	return {"ok":true,"value":(uses * parameters.practice_q16) >> 16}

static func melee_seconds(draw: Variant, level: Variant, parameters: Dictionary) -> Dictionary:
	if not integer(draw,1500,3000) or not integer(level,1,1000000) or not integer(parameters.get("timer_adjustment"),-1000000,1000000): return {"ok":false,"reason":"Validated timer draw, level and reflex parameters required."}
	return {"ok":true,"value":float(maxi(0,draw-50*(level-10)+parameters.timer_adjustment))/980.0}

static func explanation(p: Dictionary) -> String:
	return "Enemy melee timer contribution: %+d before the zero floor and division by 980. Monster attack-component gate: %d%%, followed by normal hit and damage checks. Recorded practice counts at %s×, rounded down for advancement comparison. This grants no immediate skill gains and does not change your movement or input speed." % [p.timer_adjustment,p.component_percent,String.num(float(p.practice_q16)/65536.0,6)]
