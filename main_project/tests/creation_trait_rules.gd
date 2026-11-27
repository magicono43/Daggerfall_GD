extends SceneTree
## Independent owner/policy checks for the trait-menu rule boundary.
const Policy = preload("res://scripts/data/creation_career.gd")
const Custom = preload("res://scripts/char/custom_career.gd")
var checks: Array = []

func check(label: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":label,"expected":expected,"actual":actual})

func _initialize() -> void:
	var policy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/char/career.json")).entries[0].value
	check("baseline policy validates","",Policy.policy_reason(policy))
	var pairs := [["bonus_to_hit","phobia",["animals","daedra","humanoid","undead"]],["expertise","forbidden_weaponry",["axe","blunt","hand_to_hand","long_blade","missile","short_blade"]]]
	var tolerance := ["immunity","resistance","low_tolerance","critical_weakness"]
	for first in tolerance.size():
		for second in range(first+1,tolerance.size()): pairs.append([tolerance[first],tolerance[second],["disease","fire","frost","magic","paralysis","poison","shock"]])
	for pair: Array in pairs:
		for target: String in pair[2]:
			var first: String = pair[0]+"/"+target
			var second: String = pair[1]+"/"+target
			check("DFU conflict "+first+" / "+second,true,not Custom.conflict(policy,[first],second).is_empty())
			check("DFU reverse conflict "+second,true,not Custom.conflict(policy,[second],first).is_empty())
			var different: String = pair[1]+"/"+pair[2][(pair[2].find(target)+1)%pair[2].size()]
			check("different target allowed "+first+" / "+different,"",Custom.conflict(policy,[first],different))
	for id: String in policy.traits: check("duplicate rejected "+id,true,not Custom.conflict(policy,[id],id).is_empty())
	for group: Array in [["increased_magery","1.5","3"],["darkness_powered_magery","lower_daylight","unable_daylight"],["light_powered_magery","lower_darkness","unable_darkness"]]:
		check("baseline singleton "+group[0],true,not Custom.conflict(policy,[group[0]+"/"+group[1]],group[0]+"/"+group[2]).is_empty())
	var modified := policy.duplicate(true)
	modified.traits["immunity/fire"].conflict = ""
	check("mod can disable conflict policy","",Policy.policy_reason(modified))
	check("mod conflict disable applies","",Custom.conflict(modified,["low_tolerance/fire"],"immunity/fire"))
	check("mod conflict disable reverse applies","",Custom.conflict(modified,["immunity/fire"],"low_tolerance/fire"))
	modified.traits["immunity/fire"].conflict = "bad/path"
	check("invalid group rejected",true,not Policy.policy_reason(modified).is_empty())
	modified = policy.duplicate(true)
	for id: String in modified.traits:
		if modified.traits[id].category == "increased_magery": modified.traits[id].singleton = false
	check("mod singleton override validates","",Policy.policy_reason(modified))
	check("mod singleton override applies","",Custom.conflict(modified,["increased_magery/1.5"],"increased_magery/3"))
	var value := Custom.initial(policy,"test/custom")
	for side: String in ["advantage","disadvantage"]:
		check("baseline seven "+side,7,int(policy.limits[side]))
		value.traits = ["acute_hearing","adrenaline_rush","athleticism","bonus_to_hit/animals","bonus_to_hit/daedra","bonus_to_hit/humanoid","bonus_to_hit/undead","expertise/axe"] if side == "advantage" else ["forbidden_material/iron","forbidden_material/steel","forbidden_material/silver","forbidden_material/elven","forbidden_material/dwarven","forbidden_material/mithril","forbidden_material/adamantium","forbidden_material/ebony"]
		check("eighth rejected "+side,false,Custom.evaluate(value,policy,value.id).ok)
		modified = policy.duplicate(true); modified.limits[side] = 8
		check("mod expanded limit validates "+side,"",Policy.policy_reason(modified))
		check("mod eighth accepted "+side,true,Custom.evaluate(value,modified,value.id).ok)
	var result := {"ok":checks.all(func(c): return c.expected == c.actual),"count":checks.size(),"checks":checks}
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--result="):
			var output := FileAccess.open(argument.trim_prefix("--result="),FileAccess.WRITE)
			output.store_string(JSON.stringify(result,"\t")); output.close()
	print("Trait owner/policy checks: ",checks.size(),"; passed: ",result.ok)
	quit(0 if result.ok else 1)
