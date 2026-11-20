extends RefCounted
const U = preload("res://scripts/rule/unsigned64.gd")
const PCG = preload("res://scripts/rule/pcg32.gd")
const Seeds = preload("res://scripts/rule/seed_derivation.gd")
const Mapping = preload("res://scripts/rule/random_mapping.gd")
const Classic = preload("res://scripts/rule/classic_random.gd")
var checks: Array[Dictionary] = []
class Controlled:
	extends "res://scripts/rule/random_source.gd"
	var values: Array = []
	func raw() -> Dictionary:
		if raw_count >= values.size():
			return {"ok": false}
		var value: Variant = values[raw_count]
		raw_count += 1
		return {"ok": true, "value": value}
	func bounded(bound: Variant) -> Dictionary:
		return Mapping.bounded(self, bound)

class InvalidBounded:
	extends "res://scripts/rule/random_source.gd"
	func bounded(_bound: Variant) -> Dictionary:
		return {"ok": true, "value": 100}

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario": id, "expected": expected, "actual": actual})

func raws(source: RefCounted) -> Array:
	var values := []
	for i in 6:
		values.append("%08x" % source.raw().value)
	return values

func run(_shell: Control, fixture: Dictionary) -> Dictionary:
	var source = PCG.create(U.from_int(42), U.from_int(54))
	check("upstream raw 42/54", ["a15c02b7","7b47f409","ba1d3330","83d2f293","bfa4784b","cbed606e"], raws(source))
	check("upstream raw count", 6, source.raw_count)
	source = PCG.create(U.from_int(42), U.from_int(54))
	var percentiles := []
	for i in 6:
		percentiles.append(Mapping.percentile(35, source).roll)
	check("upstream percentiles", [84,98,25,56,56,67], percentiles)
	check("percentile raw/logical", [6,6], [source.raw_count,source.logical_count])
	var material := PackedByteArray()
	material.resize(32)
	var vectors := [
		["2039abc61c3ee2dd","01c2283509471122",["863b652e","78d434fe","4231b50f","9bde62af","1404fe92","56575055"]],
		["be16b5af20eec12f","46fe8ea4d1103224",["ff0b25f6","8e983a84","62fc69c9","0e66c3a5","dbd3a6dd","92396db2"]],
		["2a2fbaee860b4fab","6825f3e0b47b0bf3",["75503fb1","6e1b6c39","32e421f2","c05d3b04","e8e299bf","596e4412"]],
		["c200bbe304e500f1","17bd7651824d7846",["ed178ad9","b2f009c0","2c2b9c5f","610284ca","018b5f81","9709605b"]]]
	for i in 4:
		var derived := Seeds.derive(material, Seeds.PURPOSES[i])
		check("purpose seed " + Seeds.PURPOSES[i], [vectors[i][0],vectors[i][1]], [hex64(derived.initstate),hex64(derived.initseq)])
		check("derivation consumes zero draws " + Seeds.PURPOSES[i], [0,0], [derived.source.raw_count,derived.source.logical_count])
		check("purpose vector " + Seeds.PURPOSES[i], vectors[i][2], raws(derived.source))
	for invalid in [null, PackedByteArray(), PackedByteArray([0]), "00"]:
		check("malformed material", false, Seeds.validate_material(invalid).ok)
	check("unknown purpose", false, Seeds.derive(material, "Combat").ok)
	check("OS entropy length", true, Seeds.material_from_os().ok)
	var controlled := Controlled.new()
	controlled.values = [0,95,96,199]
	check("rejection 0/95 then 96", {"ok":true,"value":96,"raw_requests":3}, controlled.bounded(100))
	check("next bounded 199", {"ok":true,"value":99,"raw_requests":1}, controlled.bounded(100))
	check("rejection counts", [4,2], [controlled.raw_count,controlled.logical_count])
	for bound in [0,-1,4294967296,1.5,null]:
		check("invalid bound", false, source.bounded(bound).ok)
	check("invalid bound nonconsumption", [6,6], [source.raw_count,source.logical_count])
	check("bound one", 0, source.bounded(1).value)
	check("bound one consumes", [7,7], [source.raw_count,source.logical_count])
	controlled = Controlled.new()
	controlled.values = [0,4294967295]
	check("maximum bound rejects zero", {"ok":true,"value":0,"raw_requests":2}, controlled.bounded(4294967295))
	for chance in [-9223372036854775807-1,0,35,100,9223372036854775807]:
		for roll in [1,35,36,100]:
			controlled = Controlled.new()
			# All raw inputs exceed the rejection threshold and map to roll-1.
			controlled.values = [100 + roll - 1]
			var result := Mapping.percentile(chance, controlled)
			check("percentile %s/%s" % [chance,roll], [clampi(chance,0,100),roll,roll <= clampi(chance,0,100),roll > clampi(chance,0,100),1,1], [result.effective_chance,result.roll,result.success,result.failure,controlled.raw_count,controlled.logical_count])
	check("invalid percentile source", false, Mapping.percentile(35,null).ok)
	controlled = Controlled.new()
	controlled.values = [-1]
	check("invalid raw fails", false, Mapping.percentile(35,controlled).ok)
	for seed in [-1,4294967296,null,1.0]:
		check("classic invalid seed", null, Classic.create(seed))
	for seed in [0,1,4294967295]:
		var classic = Classic.create(seed)
		var actual := []
		for i in 6:
			actual.append(classic.raw().value)
		var expected: Array = {0:[0,21468,9988,22117,3498,16927],1:[16838,5758,10113,17515,31051,5627],4294967295:[15929,4409,9862,26718,8713,28226]}[seed]
		check("classic seed %s" % seed, expected, actual)
		check("classic count", 6, classic.raw_count)
	var classic = Classic.create(1)
	for request in [[1,1,false],[2,1,true],[-2147483649,0,false],[-2147483648,2147483647,false],[0,2147483647,true],[0,2147483648,false]]:
		check("classic invalid range", false, classic.range_value(request[0],request[1],request[2]).ok)
	check("classic rejection nonconsumption", 0, classic.raw_count)
	check("classic singleton", 2147483647, classic.range_value(2147483647,2147483647,true).value)
	check("classic singleton consumes", 1, classic.raw_count)
	check("classic exclusive endpoint", -2147477890, classic.range_value(-2147483648,-1).value)
	check("classic inclusive endpoint", 10113, classic.range_value(0,32767,true).value)
	var independent = Classic.create(1)
	check("classic independent operation", 16838, independent.raw().value)
	check("classic existing operation continues", 17515, classic.raw().value)
	var extra: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/randomness_vectors.json"))
	for vector in extra.derivations:
		var derived := Seeds.derive(str(vector.material).hex_decode(), vector.purpose)
		check("additional material seed " + vector.purpose, [vector.state,vector.sequence], [hex64(derived.initstate),hex64(derived.initseq)])
		check("additional material outputs " + vector.purpose, vector.outputs, raws(derived.source))
	for vector in extra.boundaries:
		check("unsigned seed boundary " + vector.state + "/" + vector.sequence, vector.outputs, raws(PCG.create(limbs_from_hex(vector.state), limbs_from_hex(vector.sequence))))
	check("out-of-contract bounded source", false, Mapping.percentile(35,InvalidBounded.new()).ok)
	check("invalid computed fractional chance", false, Mapping.percentile(35.5,source).ok)
	check("uninitialized PCG", false, PCG.new().raw().ok)
	check("uninitialized classic", false, Classic.new().raw().ok)
	check("invalid PCG limb", null, PCG.create([0,0,0,65536],[0,0,0,0]))
	for length in [31,33]:
		var malformed := PackedByteArray()
		malformed.resize(length)
		check("material length %s" % length,false,Seeds.derive(malformed,"combat").ok)
	var exhaustive := []
	for roll in range(1,101):
		controlled = Controlled.new()
		controlled.values = [100+roll-1]
		var resolved := Mapping.percentile(35,controlled)
		if resolved.success != (roll <= 35) or resolved.failure == resolved.success or controlled.logical_count != 1:
			exhaustive.append(roll)
	check("all 100 percentile endpoints", [], exhaustive)
	check("classic minimum singleton", -2147483648, Classic.create(0).range_value(-2147483648,-2147483648,true).value)
	check("classic maximum supported width", 16838, Classic.create(1).range_value(0,2147483647).value)
	var ok := true
	for item in checks:
		ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":"IMP-006-numeric-v1","algorithms":[PCG.VERSION,Seeds.VERSION,Classic.VERSION],"material_hex":material.hex_encode(),"upstream_seed":[42,54],"context":{"session":"none","operation":"independent numeric fixtures","purpose":Seeds.PURPOSES},"inputs":fixture.inputs}

func hex64(limbs: Array) -> String:
	return "%04x%04x%04x%04x" % [limbs[3],limbs[2],limbs[1],limbs[0]]



func limbs_from_hex(value: String) -> Array:
	return [value.substr(12,4).hex_to_int(),value.substr(8,4).hex_to_int(),value.substr(4,4).hex_to_int(),value.substr(0,4).hex_to_int()]

