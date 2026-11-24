extends RefCounted
## Pure bounded rational arithmetic. No random draws or gameplay consequences.
const CONTRACT := "actor-rational-v1"
const HOOKS := ["char.damage","char.capacity","char.magicka","char.resistance","char.agility","char.growth","char.healing","char.initial-health"]
const LIMIT := 1000000000

static func integer(value: Variant, low: int, high: int) -> bool:
	return typeof(value) == TYPE_INT and value >= low and value <= high

static func floor_ratio(numerator: int, denominator: int) -> int:
	@warning_ignore("integer_division")
	var quotient: int = numerator / denominator
	return quotient - 1 if numerator < 0 and numerator % denominator != 0 else quotient

static func valid_input(value: Variant) -> bool:
	return value is Dictionary and value.size() == 3 and integer(value.get("value"),-LIMIT,LIMIT) and integer(value.get("numerator"),0,1000000) and integer(value.get("denominator"),1,1000000)

func declare(registry: RefCounted) -> Dictionary:
	for hook: String in HOOKS:
		var result: Dictionary = registry.declare_actor_hook(hook,Callable(self,hook.trim_prefix("char.").replace("-","_")))
		if not result.ok: return result
	return {"ok":true}

func damage(input: Dictionary) -> int:
	return floor_ratio(input.value - 50,5)
func capacity(input: Dictionary) -> int:
	return floor_ratio(input.value * 3,2)
func magicka(input: Dictionary) -> int:
	return floor_ratio(input.value * input.numerator,input.denominator)
func resistance(input: Dictionary) -> int:
	return floor_ratio(input.value,10)
func agility(input: Dictionary) -> int:
	return floor_ratio(input.value,10) - 5
func growth(input: Dictionary) -> int:
	return floor_ratio(input.value,10) - 5
func healing(input: Dictionary) -> int:
	return floor_ratio(input.value,10) - 5
func initial_health(input: Dictionary) -> int:
	return 25 + input.value
