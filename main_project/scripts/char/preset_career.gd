extends RefCounted
## Decode actual resolved CLASS fields for disclosure; never label source-reader
## availability semantic readiness without validating supported career semantics.
static func resolve(data: Dictionary, policy: Dictionary, numeric: Dictionary) -> Dictionary:
	var tiers := {}
	var by_number := {}
	for id in policy.skills: by_number[int(policy.skills[id].classic)] = id
	var seen: Array = []
	for tier in ["primary","major","minor"]:
		var group: Variant = data.get("skills",{}).get(tier)
		if not group is Array or group.size() != (6 if tier == "minor" else 3): return {"ok":false,"reason":"Incomplete preset skill tiers."}
		tiers[tier] = []
		for number in group:
			if not by_number.has(int(number)) or int(number) in seen: return {"ok":false,"reason":"Preset skills must be supported and distinct."}
			seen.append(int(number)); tiers[tier].append(by_number[int(number)])
	var flags: Dictionary = data.flags
	for key in ["resistance","immunity","low_tolerance","critical_weakness"]:
		if int(flags[key]) & ~127: return {"ok":false,"reason":"Unsupported preset tolerance bits: "+key}
	for pair in [["ability_spell_points",0x1fff],["weapon_armor_shields",0x3f1fff],["forbidden_materials",1023],["rapid_healing",7],["regeneration",15],["spell_absorption",7]]:
		if int(flags[pair[0]]) & ~int(pair[1]): return {"ok":false,"reason":"Unsupported preset career bits: "+str(pair[0])}
	var selected: Array = []
	var tolerances := {"paralysis":1,"magic":2,"poison":4,"fire":8,"frost":16,"shock":32,"disease":64}
	for target in tolerances:
		var active := 0
		for category in ["resistance","immunity","low_tolerance","critical_weakness"]:
			if int(flags[category]) & int(tolerances[target]): selected.append(category+"/"+target); active += 1
		if active > 1: return {"ok":false,"reason":"Preset has unresolved overlapping tolerance flags."}
	var packed: int = int(flags.weapon_armor_shields)
	for pair in [["short_blade",1],["long_blade",2],["hand_to_hand",4],["axe",8],["blunt",16],["missile",32]]:
		if packed & int(pair[1]): selected.append("forbidden_weaponry/"+pair[0])
		if (packed >> 16) & int(pair[1]): selected.append("expertise/"+pair[0])
	for pair in [["leather",1],["chain",2],["plate",4]]:
		if (packed >> 6) & int(pair[1]): selected.append("forbidden_armor/"+pair[0])
	for pair in [["buckler",1],["round",2],["kite",4],["tower",8]]:
		if (packed >> 9) & int(pair[1]): selected.append("forbidden_shield/"+pair[0])
	for pair in [["iron",1],["steel",2],["silver",4],["elven",8],["dwarven",16],["mithril",32],["adamantium",64],["ebony",128],["orcish",256],["daedric",512]]:
		if int(flags.forbidden_materials) & int(pair[1]): selected.append("forbidden_material/"+pair[0])
	for pair in [["undead",1],["daedra",2],["humanoid",4],["animals",8]]:
		if int(flags.attack_modifier) & int(pair[1]): selected.append("bonus_to_hit/"+pair[0])
		if int(flags.attack_modifier) & (int(pair[1]) << 4): selected.append("phobia/"+pair[0])
	var ability: int = int(flags.ability_spell_points)
	for pair in [["acute_hearing",1],["athleticism",2],["adrenaline_rush",4],["no_spell_point_regeneration",8],["damage/sunlight",16],["damage/holy_places",32]]:
		if ability & int(pair[1]): selected.append(pair[0])
	var magery := (ability & 0x1c00) >> 8
	var variants := {0:"3",4:"2",8:"1.75",12:"1.5",16:"1"}
	if magery != 20 and not variants.has(magery): return {"ok":false,"reason":"Unsupported preset magery variant."}
	var spell_points := multiplier(numeric,str((ability & 0x1c00) >> 10))
	if not spell_points.ok: return spell_points
	if magery != 20: selected.append("increased_magery/"+variants[magery])
	for pair in [["darkness_powered_magery",(ability >> 8)&3,"unable_daylight","lower_daylight"],["light_powered_magery",(ability >> 6)&3,"unable_darkness","lower_darkness"]]:
		if pair[1] == 3: return {"ok":false,"reason":"Unsupported preset environmental magery flags."}
		if pair[1] > 0: selected.append(pair[0]+"/"+pair[2 if pair[1] == 1 else 3])
	for pair in [["rapid_healing","rapid_healing",[["light",1],["darkness",2],["general",4]]],["regenerate_health","regeneration",[["light",1],["darkness",2],["immersed",4],["general",8]]],["spell_absorption","spell_absorption",[["light",1],["darkness",2],["general",4]]]]:
		for variant in pair[2]:
			if int(flags[pair[1]]) & int(variant[1]): selected.append(pair[0]+"/"+variant[0])
	var checked: Array = []
	for id in selected:
		if not policy.traits.has(id): return {"ok":false,"reason":"Preset requires an unavailable trait: "+id}
		var conflict := preload("res://scripts/char/custom_career.gd").conflict(policy,checked,id)
		if not conflict.is_empty(): return {"ok":false,"reason":"Preset conflict: "+conflict}
		checked.append(id)
	if int(data.hit_points_per_level) < 1 or int(data.advancement_fixed_16_16) < 1: return {"ok":false,"reason":"Positive preset HP/advancement required."}
	return {"ok":true,"name":data.name,"tiers":tiers,"traits":selected,"hit_points_per_level":int(data.hit_points_per_level),"advancement":{"numerator":int(data.advancement_fixed_16_16),"denominator":65536},"spell_point_multiplier":"%.4f" % (float(spell_points.numerator)/spell_points.denominator),"spell_points":{"numerator":spell_points.numerator,"denominator":spell_points.denominator},"attributes":data.attributes.duplicate(),"runtime_effects":"Deferred owner resolution/stacking; selection grants no live effects."}

static func multiplier(numeric: Dictionary, key: String) -> Dictionary:
	var ratio: Variant = numeric.get("multipliers",{}).get(key)
	var formats = preload("res://scripts/data/actor_input_formats.gd")
	if not ratio is Dictionary or not formats.integer(ratio.get("numerator"),0,1000000) or not formats.integer(ratio.get("denominator"),1,1000000): return {"ok":false,"reason":"Required CHAR numeric spell-point policy unavailable."}
	return {"ok":true,"numerator":int(ratio.numerator),"denominator":int(ratio.denominator)}

static func custom_multiplier(value: Dictionary, numeric: Dictionary) -> Dictionary:
	var key := "5" # Encoded career case without Increased Magery; value is DATA-owned.
	const KEYS = {"increased_magery/3":"0","increased_magery/2":"1","increased_magery/1.75":"2","increased_magery/1.5":"3","increased_magery/1":"4"}
	for id in value.get("traits",[]):
		if KEYS.has(id): key = KEYS[id]
	return multiplier(numeric,key)
