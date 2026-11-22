extends RefCounted
## Structural input decoding only. No actor construction or effect evaluation.
const VERSION = "actor-inputs-v1"
const FORMATS = ["flats-cfg-v1", "career-cfg-v1", "paint-dat-v1", "bio-dat-v1", "biog-text-v1", "career-source-v1"]
const FLAT_CONFLICT_PROFILE = "classic-flat-conflicts-v1"
const BIOG_CORRECTION_PROFILE = "biog-dfu-ampersand-v1"
const BIOG_AMPERSAND_QUESTIONS = {"BIOG01T0.TXT":"q12","BIOG02T0.TXT":"q12","BIOG03T0.TXT":"q12","BIOG05T0.TXT":"q12","BIOG06T0.TXT":"q9","BIOG10T0.TXT":"q12","BIOG12T0.TXT":"q7","BIOG13T0.TXT":"q7","BIOG14T0.TXT":"q7","BIOG15T0.TXT":"q7","BIOG16T0.TXT":"q7","BIOG17T0.TXT":"q7"}
const FLAT_CONFLICTS = {
	"22785":["c548c8b4a0f0dfa83ae180b31fa0a02a75b39ce8c73220b6691e713736e67414","73d67959a6c93ef8dfd211396835452c67eea56bf451bbf97f3bb49944622f8b"],
	"22788":["20cd4aeb38c3d706b0d5c6854f70f03b476b40c96ae5d8cd445649c12d350152","ee160fce587ed25dd45412876df72570c4eebacb4b095b4f702ec52ecfcdcf54"],
	"23040":["f4c95f124ec0adeb456d9a86af616d6f80c0d65047d8616261c1158847fdeb5a","44d2606d5a3b8bf48d52518ad1e62cf89ea1cee77af6dfe0d11cbe0f84fa7616"],
	"23342":["1d5bd2890c9c3afef08db2cda12d164edda3ace066ee397d3608b977a60874e8","4ed33589217309a2946f47c32494b9a0d8eb24d234e12aa4125fea019122542a"],
	"23438":["8c6cc5f34af52f20cad5f97991d991ca3e803289d28e1386b4860baf33c23eba","520acb6a117314f495c7251c138dcc4c152e0b50875ebb57630a42a3a5cee58d"],
	"23443":["251ed6b6bd8ce0912017ded43a8baee8b180ac65ae188258b5a7a1b1ad905516","9d7d86a69ecca22cef881fa6a69067fc4ae1c8e9a30b31e40a0bb141bf9102b8"],
	"25488":["3b6d524b5159e3c11f0e77a65714f57d7515ef727f204568836081ca4ca935dd","841a2fe38dc2ac6e59e9d5dcfbbaea5021655f4f155376be9e6fff623e1518a8","570f0c0d03541529af83b46ea054fb1b9bb473dc6cd036c07d28685e5b9f5641"]}

static func known_flat_conflict(alternatives: Array) -> bool:
	if alternatives.is_empty() or not alternatives[0] is Dictionary: return false
	var key: String = str(alternatives[0].get("classic",""))
	if not FLAT_CONFLICTS.has(key) or alternatives.size() != FLAT_CONFLICTS[key].size(): return false
	var signatures: Array = []
	for value in alternatives:
		if not value is Dictionary or value.size() != 9 or value.get("kind") != "flat" or value.get("classic") != key or not value.get("caption") is String or not value.get("gender_source") is String: return false
		for field in ["archive","record","unknown2","unknown3","face_index"]:
			if not integer(value.get(field),-2147483648,2147483647): return false
		var signature: String = ("%d %d\n%s\n%s\n%d\n%d\n%d" % [value.archive,value.record,value.caption,value.gender_source,value.unknown2,value.unknown3,value.face_index]).sha256_text()
		if signature in signatures: return false
		signatures.append(signature)
	signatures.sort()
	var expected: Array = FLAT_CONFLICTS[key].duplicate()
	expected.sort()
	return signatures == expected

static func failure(kind: String, reason: String, source := "", record: Variant = null) -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"source":source,"record":record,"schema":VERSION}

static func pack_flat(archive: Variant, record: Variant) -> Dictionary:
	if not archive is int or not record is int or archive < 0 or archive > 16777215 or record < 0 or record > 127:
		return failure("malformed","Classic flat requires archive 0..16777215 and record 0..127.")
	return {"ok":true,"id":(archive << 7) + record}

static func integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= minimum and value <= maximum

static func equal_input(first: Variant, second: Variant) -> bool:
	# JSON numbers are floats; input integers must compare by exact numeric value.
	if (first is int or first is float) and (second is int or second is float): return first == second
	if typeof(first) != typeof(second): return false
	if first is Dictionary:
		if first.size() != second.size(): return false
		for key in first:
			if not second.has(key) or not equal_input(first[key],second[key]): return false
		return true
	if first is Array:
		if first.size() != second.size(): return false
		for i in first.size():
			if not equal_input(first[i],second[i]): return false
		return true
	return first == second

static func text(bytes: PackedByteArray) -> Dictionary:
	var decoded := bytes.get_string_from_utf8()
	if decoded.to_utf8_buffer() != bytes: return failure("unsupported","Profile requires lossless UTF-8/ASCII text.")
	return {"ok":true,"text":decoded}

static func sha256(bytes: PackedByteArray) -> String:
	var hash_context := HashingContext.new()
	hash_context.start(HashingContext.HASH_SHA256)
	hash_context.update(bytes)
	return hash_context.finish().hex_encode()

static func decode(format_id: String, bytes: PackedByteArray, source := "") -> Dictionary:
	var result: Dictionary
	match format_id:
		"career-cfg-v1": result = career(bytes)
		"career-source-v1": result = career(bytes,true)
		"flats-cfg-v1": result = flats(bytes)
		"paint-dat-v1":
			if bytes.is_empty() or bytes.size() % 40 != 0: result = failure("malformed","PAINT.DAT requires complete 40-byte records.")
			else:
				var records := {}
				for i in bytes.size() / 40: records[str(i)] = {"kind":"painting","bytes":Array(bytes.slice(i * 40,(i + 1) * 40)),"classic":str(i)}
				result = {"ok":true,"records":records}
		"bio-dat-v1":
			if bytes.is_empty() or bytes[-1] != 0: result = failure("malformed","BIO.DAT requires NUL-terminated narrative strings.")
			else:
				var records := {}
				var start := 0
				var index := 0
				for offset in bytes.size():
					if bytes[offset] != 0: continue
					var checked := text(bytes.slice(start,offset))
					if not checked.ok:
						checked.source = source
						checked.record = index
						checked.format = format_id
						return checked
					records[str(index)] = {"kind":"narrative","text":checked.text,"classic":str(index)}
					index += 1
					start = offset + 1
				result = {"ok":true,"records":records}
		"biog-text-v1": result = biography(bytes,source)
		_: result = failure("unsupported","Unknown actor input format.")
	result.source = source
	result.format = format_id
	result.schema = VERSION
	return result

static func career(bytes: PackedByteArray, source_only := false) -> Dictionary:
	if bytes.size() < 74: return failure("malformed","Truncated 74-byte career.")
	if bytes.size() > 74: return failure("unsupported","Career extensions require a new profile.")
	var flags := {}
	var names := ["resistance","immunity","low_tolerance","critical_weakness"]
	for i in 4: flags[names[i]] = int(bytes[i])
	flags.ability_spell_points = bytes.decode_u16(4)
	for pair in [["rapid_healing",6],["regeneration",7],["spell_absorption",9],["attack_modifier",10]]: flags[pair[0]] = int(bytes[pair[1]])
	flags.forbidden_materials = bytes.decode_u16(11)
	flags.weapon_armor_shields = (int(bytes[13]) << 16) | (int(bytes[15]) << 8) | int(bytes[14])
	var skills := {"primary":Array(bytes.slice(16,19)),"major":Array(bytes.slice(19,22)),"minor":Array(bytes.slice(22,28))}
	for group: Array in skills.values():
		for skill in group:
			if skill > 34 and not source_only: return failure("unsupported","Unknown required skill identifier: " + str(skill),"",{"field":"skills","value":skill})
	var name_bytes := bytes.slice(28,44)
	var end := name_bytes.find(0)
	if end >= 0: name_bytes = name_bytes.slice(0,end)
	var name := text(name_bytes)
	if not name.ok: return name
	var attributes: Array = []
	for i in 8: attributes.append(bytes.decode_u16(58 + i * 2))
	var value := {"kind":"career","name":name.text,"flags":flags,"skills":skills,"unknown1":int(bytes[8]),"unknown2":Array(bytes.slice(44,52)),"name_storage":Array(bytes.slice(28,44)),"hit_points_per_level":bytes.decode_u16(52),"advancement_fixed_16_16":bytes.decode_u32(54),"attributes":attributes}
	if source_only: value.kind = "career_source"
	return {"ok":true,"records":{"career":value}}

static func flats(bytes: PackedByteArray) -> Dictionary:
	var decoded := text(bytes)
	if not decoded.ok: return decoded
	var blocks: Array = []
	var block: Array[String] = []
	for line: String in decoded.text.replace("\r","").split("\n"):
		if line.strip_edges().is_empty():
			if not block.is_empty(): blocks.append(block.duplicate())
			block.clear()
		else: block.append(line.strip_edges())
	if not block.is_empty(): blocks.append(block)
	if blocks.is_empty(): return failure("malformed","Empty flat source.")
	var records := {}
	var positions := {}
	var groups := {}
	for index in blocks.size():
		var lines: Array = blocks[index]
		if lines.size() != 6: return failure("malformed","Flat block needs six lines.","",index)
		var pair := str(lines[0]).split(" ",false)
		if pair.size() != 2 or not pair[0].is_valid_int() or not pair[1].is_valid_int(): return failure("malformed","Invalid flat address.","",index)
		var packed := pack_flat(int(pair[0]),int(pair[1]))
		if not packed.ok: return packed
		for field in [3,4,5]:
			if not str(lines[field]).is_valid_int() or not integer(int(lines[field]),-2147483648,2147483647): return failure("malformed","Flat integer is invalid.","",index)
		var key := str(packed.id)
		var value := {"kind":"flat","classic":key,"archive":int(pair[0]),"record":int(pair[1]),"caption":lines[1],"gender_source":lines[2],"unknown2":int(lines[3]),"unknown3":int(lines[4]),"face_index":int(lines[5])}
		if not groups.has(key):
			groups[key] = []
			positions[key] = []
		groups[key].append(value)
		positions[key].append(index)
	for key: String in groups:
		if groups[key].size() == 1: records[key] = groups[key][0]
		elif known_flat_conflict(groups[key]): records[key] = {"kind":"flat_conflict","classic":key,"profile":FLAT_CONFLICT_PROFILE,"alternatives":groups[key],"source_blocks":positions[key]}
		else: return failure("malformed","Duplicate flat mapping outside the approved classic source exceptions.","",key)
	return {"ok":true,"records":records}

static func effect(command: String) -> Dictionary:
	var words := command.replace("\t"," ").split(" ",false)
	if words.is_empty(): return failure("malformed","Empty effect.")
	var op := words[0]
	if op == "&": return failure("unsupported","Required ampersand command has no supported interpretation.")
	if not op.is_valid_int() and not op.begins_with("r") and not op[0] in "#!?" and op not in ["AE","AF","IT","GP","RP","FT","RR","RD","MR","TH"]: return failure("unsupported","Unsupported required effect: " + op)
	var type_id := ""
	var target := "player"
	var params := {}
	if op.begins_with("#") or op.begins_with("!") or op.begins_with("?"):
		if words.size() != 1 or not op.substr(1).is_valid_int(): return failure("malformed","Invalid narrative command.")
		if not integer(int(op.substr(1)),0,65535): return failure("unsupported","Narrative target is outside the supported classic text-ID range.")
		type_id = "narrative_token"
		target = "text.rsc:" + op.substr(1)
		params = {"channel":op[0],"text_id":int(op.substr(1))}
	elif op in ["AE","AF"]:
		if words.size() != 5 or words[1] not in ["M","O","F"]: return failure("malformed","AE/AF requires selector and three integer operands.")
		for word in words.slice(2):
			if not word.is_valid_int() or not integer(int(word),-2147483648,2147483647): return failure("malformed","Invalid AE/AF operand.")
		type_id = "classic_" + op.to_lower() + "_declaration"
		target = "character.effect_owner"
		params = {"selector":words[1],"operands":[int(words[2]),int(words[3]),int(words[4])]}
	elif op == "IT":
		if words.size() != 4: return failure("malformed","IT requires group, index, material.")
		for word in words.slice(1):
			if not word.is_valid_int() or not integer(int(word),0,2147483647): return failure("malformed","Invalid IT parameter.")
		type_id = "item_grant"
		target = "classic.item:%s/%s" % [words[1],words[2]]
		params = {"group":int(words[1]),"index":int(words[2]),"material":int(words[3])}
	else:
		if words.size() == 3 and op == "GP" and words[1] in ["+","-"]: words = PackedStringArray([op,words[1] + words[2]])
		if words.size() != 2 or not words[1].is_valid_int(): return failure("malformed","Effect requires a signed integer amount.")
		params.amount = int(words[1])
		if not integer(params.amount,-2147483648,2147483647): return failure("malformed","Effect amount outside signed 32-bit range.")
		if op.is_valid_int():
			if int(op) < 0 or int(op) > 34: return failure("unsupported","Unsupported skill target.")
			type_id = "skill_adjustment"
			target = "classic.skill:" + str(int(op))
		elif op.begins_with("rf") or op.begins_with("r"):
			var prefix := 2 if op.begins_with("rf") else 1
			if not op.substr(prefix).is_valid_int() or int(op.substr(prefix)) < 0: return failure("malformed","Invalid reputation target.")
			if not integer(int(op.substr(prefix)),0,65535 if prefix == 2 else 4): return failure("unsupported","Unsupported classic reputation target.")
			type_id = "faction_reputation" if prefix == 2 else "social_reputation"
			target = ("classic.faction:" if prefix == 2 else "classic.social:") + str(int(op.substr(prefix)))
		elif op in ["GP","RP","FT","RR","RD","MR","TH"]:
			type_id = {"GP":"gold_adjustment","RP":"poison_modifier","FT":"fatigue_modifier","RR":"reaction_modifier","RD":"disease_modifier","MR":"magic_modifier","TH":"avoid_hit_modifier"}[op]
		else: return failure("unsupported","Unsupported required effect: " + op)
	return {"ok":true,"value":{"type":type_id,"target":target,"parameters":params,"classic_command":command,"required":true}}

static func biography(bytes: PackedByteArray, source := "") -> Dictionary:
	var decoded := text(bytes)
	if not decoded.ok: return decoded
	var questions: Array = []
	var question := {}
	var answer := {}
	var backstory: Variant = null
	var line_number := 0
	var annotations: Array = []
	var lines: PackedStringArray = decoded.text.replace("\r","").split("\n")
	for raw: String in lines:
		line_number += 1
		var line := raw.strip_edges()
		if line.is_empty(): continue
		if questions.is_empty() and question.is_empty() and line.begins_with("#"):
			if backstory != null or not line.substr(1).is_valid_int(): return failure("malformed","Invalid explicit backstory header.","",line_number)
			if not integer(int(line.substr(1)),0,65535): return failure("unsupported","Unsupported explicit backstory text ID.","",line_number)
			backstory = int(line.substr(1))
			continue
		var dot := line.find(".")
		var marker := line.substr(0,dot) if dot > 0 else ""
		if marker.is_valid_int():
			if not integer(int(marker),1,2147483647): return failure("malformed","Question marker must be a positive signed-32-bit source number.","",line_number)
			if not question.is_empty():
				if not answer.is_empty(): question.answers.append(answer)
				questions.append(question)
			question = {"id":"q" + str(int(marker)),"text":line.substr(dot + 1).strip_edges(),"answers":[]}
			answer = {}
		elif marker.length() == 1 and marker >= "a" and marker <= "z":
			if question.is_empty(): return failure("malformed","Answer before question.","",line_number)
			if not answer.is_empty(): question.answers.append(answer)
			answer = {"id":marker,"text":line.substr(dot + 1).strip_edges(),"effects":[]}
		elif answer.is_empty():
			if question.is_empty(): return failure("malformed","Text before question.","",line_number)
			question.text += "\n" + line
		else:
			if line == "&" and BIOG_AMPERSAND_QUESTIONS.get(source.get_file().to_upper(),"") == question.id and answer.id == "c" and answer.text == "Getting along with others" and answer.effects.is_empty() and annotations.is_empty() and line_number < lines.size() and lines[line_number].strip_edges() == "RR -5":
				# Explicitly approved DFU correction, not a generic unknown-effect skip.
				annotations.append({"profile":BIOG_CORRECTION_PROFILE,"source_file":source.get_file().to_upper(),"line":line_number,"raw_text":raw,"question":question.id,"answer":answer.id})
				continue
			var checked := effect(line)
			if not checked.ok:
				checked.record = line_number
				checked.referring = question.id + "/" + answer.id
				return checked
			answer.effects.append(checked.value)
	if not question.is_empty():
		if not answer.is_empty(): question.answers.append(answer)
		questions.append(question)
	if questions.is_empty(): return failure("malformed","No biography questions.")
	var seen := {}
	for q: Dictionary in questions:
		if seen.has(q.id) or q.answers.is_empty(): return failure("malformed","Duplicate question or missing answers.")
		seen[q.id] = true
		var answers := {}
		for a: Dictionary in q.answers:
			if answers.has(a.id): return failure("malformed","Duplicate answer marker.")
			answers[a.id] = true
	return {"ok":true,"records":{"biography":{"kind":"biography","questions":questions,"backstory_text_id":backstory,"source_annotations":annotations}}}
