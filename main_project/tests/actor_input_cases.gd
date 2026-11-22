extends "res://tests/text_cases.gd"
const Actors = preload("res://scripts/data/actor_inputs.gd")
const Formats = preload("res://scripts/data/actor_input_formats.gd")
const Registry = preload("res://scripts/data/definition_registry.gd")
const SourceReader = preload("res://scripts/data/actor_source_reader.gd")
const Bsa = preload("res://scripts/data/bsa_reader.gd")

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})

func write_bytes(path: String, bytes: PackedByteArray) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()

func missing_actor_fixture() -> String:
	var root := sandbox.path_join("missing-actor-source/ARENA2")
	for name: String in ["ARCH3D.BSA","BLOCKS.BSA","MAPS.BSA","DAGGER.SND"]:
		write_bytes(root.path_join(name),PackedByteArray([1,0,0,2,42,232,3,0,0,1,0,0,0]))
	return root

func envelope(operation: String, entries: Array) -> Dictionary:
	return {"domain":Actors.DOMAIN,"path":"catalog","operation":operation,"entries":entries}

func authored(kind: String, data: Dictionary, references: Array = []) -> Dictionary:
	return {"schema":Actors.VERSION,"kind":kind,"data":data,"references":references}

func at(candidate: Dictionary, id: String) -> Dictionary:
	return candidate.resources[Actors.DOMAIN + ":catalog"].records[id]

func apply_json(registry: RefCounted, base: Dictionary, value: Dictionary) -> Dictionary:
	return registry.apply_contribution(base,JSON.stringify(value).to_utf8_buffer(),{"provider":"actor.test","file":"actors.json","version":"1.0.0","root":sandbox})

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var mods: RefCounted = controller.mods
	controller.settings.effective["startup/show_setup"] = true
	check("actor schema frozen","actor-inputs-v1",Actors.VERSION)
	check("actor source inventory frozen",41,Actors.sources().size())
	check("actor reads unavailable before source selection","before_readiness",controller.providers.classic.read_record("CLASS00.CFG","career").kind)
	controller.select_folder(missing_actor_fixture())
	check("missing actor input source still blocks setup","mandatory_setup",controller.route)
	check("failed actor source attempt publishes no partial readers",false,controller.providers.classic.ready())
	var loose := envelope("patch",[{"id":"class-00","value":{"references":[{"id":"biog00t0","kind":"biography"}]}}])
	write(mods.root.path_join("Overrides/z-actor.json"),JSON.stringify(loose))
	controller.select_folder(fixture.classic_source)
	check("approved BIOG correction allows actual source preparation","optional_setup",controller.route)
	check("real installed source readers activate",true,controller.providers.classic.ready())
	check("known flat conflict no longer rejects file",false,controller.result.get("failures",[]).any(func(f: Dictionary): return f.source.ends_with("FLATS.CFG")))
	check("source-only CLASS18 no longer rejects startup",false,controller.result.get("failures",[]).any(func(f: Dictionary): return f.source.ends_with("CLASS18.CFG")))
	check("CLASS18 uses source-only transport",true,Actors.sources().any(func(s: Dictionary): return s.file == "CLASS18.CFG" and s.format == "career-source-v1"))
	var unused_class := SourceReader.new("career-cfg-v1")
	check("explicit CLASS18 request still rejects unsupported skill","unsupported",unused_class.initialize(fixture.classic_source.path_join("CLASS18.CFG")).kind)
	unused_class.close()
	var city_watch := SourceReader.new("career-source-v1")
	check("real City Watch source initializes without inventing skills",true,city_watch.initialize(fixture.classic_source.path_join("CLASS18.CFG")).ok)
	check("real City Watch unsupported source byte preserved",35,city_watch.read_record("career").value.skills.major[2])
	city_watch.close()
	var original_flats := SourceReader.new("flats-cfg-v1")
	var flats_checked := original_flats.initialize(fixture.classic_source.path_join("FLATS.CFG"))
	check("complete installed flat file now initializes",true,flats_checked.ok)
	check("known flat conflict remains visible",7,flats_checked.warnings.size())
	check("unaffected original flat lookup succeeds",true,original_flats.read_record("22400").ok)
	var conflict := original_flats.read_record("22785")
	check("conflicting original flat lookup remains rejected","ambiguous_mapping",conflict.kind)
	check("both conflicting original captions preserved",["red-cowled man","red-cloaked man"],conflict.candidates.map(func(c: Dictionary): return c.caption))
	conflict.candidates[0].caption = "caller mutation"
	check("conflict rejection views remain independent","red-cowled man",original_flats.read_record("22785").candidates[0].caption)
	original_flats.close()
	check("approved BIOG correction removes source-wide rejection",false,controller.result.get("failures",[]).any(func(f: Dictionary): return f.source.ends_with("BIOG01T0.TXT") and f.record == 217))
	var real_career := SourceReader.new("career-cfg-v1")
	check("representative original class reader initializes",true,real_career.initialize(fixture.classic_source.path_join("CLASS00.CFG")).ok)
	check("representative original class name","Mage",real_career.read_record("career").value.name)
	var original_career: Dictionary = real_career.read_record("career").value
	real_career.close()
	var monster := Bsa.new()
	check("representative original MONSTER source initializes",true,monster.initialize(fixture.classic_source.path_join("MONSTER.BSA")).ok)
	var enemy: Dictionary = monster.read_record("ENEMY000.CFG")
	check("original monster physical identity",12,enemy.ordinal)
	check("original monster source byte offset",4257,enemy.offset)
	var enemy_value: Dictionary = Formats.decode("career-cfg-v1",enemy.bytes).records.career
	check("original monster career name","Rat",enemy_value.name)
	check("original monster supported flags",{"resistance":68,"immunity":0,"low_tolerance":0,"critical_weakness":0,"ability_spell_points":0,"rapid_healing":0,"regeneration":0,"spell_absorption":0,"attack_modifier":0,"forbidden_materials":0,"weapon_armor_shields":0},enemy_value.flags)
	check("original monster supported skills",{"primary":[18,19,16],"major":[31,8,2],"minor":[11,13,30,34,27,6]},enemy_value.skills)
	check("original monster supported attributes",[40,10,70,80,55,50,45,50],enemy_value.attributes)
	check("original monster hit points per level",1,enemy_value.hit_points_per_level)
	check("original monster fixed advancement",75008,enemy_value.advancement_fixed_16_16)
	check("original monster unused fields retained",[0,0,0,0,0,0,0,0],enemy_value.unknown2)
	monster.close()
	for pair in [["PAINT.DAT","paint-dat-v1","0"],["BIO.DAT","bio-dat-v1","0"],["BIOG00T0.TXT","biog-text-v1","biography"]]:
		var reader := SourceReader.new(pair[1])
		check("representative original reader " + pair[0],true,reader.initialize(fixture.classic_source.path_join(pair[0])).ok)
		check("representative original record " + pair[0],true,reader.read_record(pair[2]).ok)
		reader.close()
	var selected: String = fixture.classic_source
	check("actor source selection reaches pre-menu setup","optional_setup",controller.route)
	var candidate: Dictionary = registry.projection()
	check("actor baseline structurally validates",true,candidate.get("ok",false))
	if not candidate.get("ok",false):
		checks.append({"scenario":"baseline diagnostics","expected":"valid","actual":JSON.stringify(controller.result)})
		return terminal(fixture)
	check("actor definitions unavailable before menu","before_readiness",Actors.lookup(registry,"class-00").kind)
	var klass: Dictionary = at(candidate,"class-00")
	var expected_career := original_career.duplicate(true)
	expected_career.erase("kind")
	check("fixture retains all supported original career fields",expected_career,klass.value.data)
	check("classic Mage name","Mage",klass.value.data.name)
	check("classic Mage flags",{"resistance":0,"immunity":0,"low_tolerance":0,"critical_weakness":0,"ability_spell_points":1024,"rapid_healing":0,"regeneration":0,"spell_absorption":0,"attack_modifier":0,"forbidden_materials":0,"weapon_armor_shields":7594},klass.value.data.flags)
	check("classic Mage primary skills",[27,25,26],klass.value.data.skills.primary)
	check("classic Mage major skills",[24,22,23],klass.value.data.skills.major)
	check("classic Mage minor skills",[0,28,32,7,9,20],klass.value.data.skills.minor)
	check("classic Mage attributes",[42,60,65,45,45,50,43,50],klass.value.data.attributes)
	check("classic Mage HP per level",6,klass.value.data.hit_points_per_level)
	check("classic Mage advancement exact fixed value",68096,klass.value.data.advancement_fixed_16_16)
	check("classic Mage unknown byte",0,klass.value.data.unknown1)
	check("classic Mage unknown bytes",[0,0,0,0,0,0,0,0],klass.value.data.unknown2)
	check("classic class mapping","00",klass.value.classic)
	check("classic stable origin","@shipped/actor-inputs-v1",klass.identity.package)
	check("classic stable local key","catalog#class-00",klass.identity.local)
	check("classic class provenance",selected.path_join("CLASS00.CFG"),klass.value.input.source)
	check("classic input transport explicit","selected-arena2",klass.value.input.transport)
	check("explicit class to biography mapping",[{"id":"biog00t0","kind":"biography"}],klass.value.references)
	var flat: Dictionary = at(candidate,"flat-22400").value
	check("classic flat all supported fields",{"archive":175,"record":0,"caption":"beautiful maiden","gender_source":"?2","unknown2":-2,"unknown3":2,"face_index":410},flat.data)
	check("classic flat explicit mapping","22400",flat.classic)
	check("catalog retains explicit conflict marker","flat_conflict",at(candidate,"flat-22785").value.kind)
	check("City Watch source is separate from playable classes","career_source",at(candidate,"career-source-18").value.kind)
	check("CLASS18 does not become a nineteenth playable class",false,candidate.resources[Actors.DOMAIN + ":catalog"].records.has("class-18"))
	var conflict_consumer := authored("appearance",{"resource":"explicit-source-request"},[{"id":"flat-22785","kind":"flat"}])
	var required_conflict := apply_json(registry,candidate.resources,envelope("add",[{"id":"requires-conflicting-flat","value":conflict_consumer}]))
	check("required ambiguous flat reference blocks candidate",true,Actors.new().validate_references(required_conflict.resources).any(func(issue: Dictionary): return issue.get("target") == "flat-22785"))
	check("classic painting stride",40,at(candidate,"painting-0").value.data.bytes.size())
	check("classic painting complete raw metadata digest","a436fa7d9ab5d67497e21734d446194b64c4de0c68e760bafffd548a0c9cdef0",Formats.sha256(PackedByteArray(at(candidate,"painting-0").value.data.bytes)))
	check("classic BIO narrative format distinct","bio-dat-v1",at(candidate,"narrative-0").value.input.format)
	check("classic BIO first narrative","Your parents travelled with a carnival throughout your youth,",at(candidate,"narrative-0").value.data.text)
	var bio: Dictionary = at(candidate,"biog00t0").value
	check("classic BIOG format explicit","biog-text-v1",bio.input.format)
	check("classic BIOG question count",12,bio.data.questions.size())
	check("classic BIOG stable question marker","q1",bio.data.questions[0].id)
	check("classic BIOG stable answer marker","a",bio.data.questions[0].answers[0].id)
	check("classic BIOG first question literal","What school of magic have you been\nstudying the longest?",bio.data.questions[0].text)
	check("classic BIOG first answer literal","Destruction",bio.data.questions[0].answers[0].text)
	check("classic BIOG first answer all declarations",[Formats.effect("#4150").value,Formats.effect("!4156").value,Formats.effect("22 +6").value],bio.data.questions[0].answers[0].effects)
	check("classic BIOG first skill declaration",{"type":"skill_adjustment","target":"classic.skill:22","parameters":{"amount":6},"classic_command":"22 +6","required":true},bio.data.questions[0].answers[0].effects[2])
	check("classic BIOG required class link",[{"id":"class-00","kind":"class"}],bio.references)
	check("classic backstory no guessed class-zero default",null,bio.data.backstory_text_id)
	var annotation_count := 0
	var question_count := 0
	var raw_commands := RegEx.new()
	raw_commands.compile("^(?:[0-9]+\\s+[-+]?[0-9]+|(?:GP|IT|AE|AF|RP|FT|RR|RD|MR|TH|AO)\\b.*|rf?[0-9]+\\s+.*|[#!?][0-9]+)$")
	for class_index in 18:
		var file_name := "BIOG%02dT0.TXT" % class_index
		var set_id := file_name.get_basename().to_lower()
		var biography_data: Dictionary = at(candidate,set_id).value.data
		question_count += biography_data.questions.size()
		annotation_count += biography_data.source_annotations.size()
		var expected_commands: Array = []
		for line: String in FileAccess.get_file_as_string(fixture.classic_source.path_join(file_name)).split("\n"):
			if raw_commands.search(line.strip_edges()) != null: expected_commands.append(line.strip_edges())
		var parsed_commands: Array = []
		for question: Dictionary in biography_data.questions:
			for answer: Dictionary in question.answers:
				for effect: Dictionary in answer.effects: parsed_commands.append(effect.classic_command)
		check("original effect command sequence preserved " + file_name,expected_commands,parsed_commands)
		if Formats.BIOG_AMPERSAND_QUESTIONS.has(file_name):
			var annotation: Dictionary = biography_data.source_annotations[0]
			check("approved correction provenance " + file_name,Formats.BIOG_CORRECTION_PROFILE,annotation.profile)
			check("original marker retained " + file_name,"&",annotation.raw_text.strip_edges())
			var question: Dictionary = biography_data.questions.filter(func(q: Dictionary): return q.id == annotation.question)[0]
			var answer: Dictionary = question.answers.filter(func(a: Dictionary): return a.id == "c")[0]
			check("reaction effect unchanged " + file_name,[{"type":"reaction_modifier","target":"player","parameters":{"amount":-5},"classic_command":"RR -5","required":true}],answer.effects)
	check("all classic biography questions retained",216,question_count)
	check("exactly twelve approved marker corrections",12,annotation_count)
	var correction_example := "12. Question\nc. Getting along with others\n\t&\n\tRR -5\n"
	check("unrecognized BIOG marker source still rejected","unsupported",Formats.decode("biog-text-v1",correction_example.to_utf8_buffer(),"BIOG99T0.TXT").kind)
	check("unrecognized marker context still rejected","unsupported",Formats.decode("biog-text-v1",correction_example.replace("RR -5","RR -6").to_utf8_buffer(),"BIOG01T0.TXT").kind)
	check("other unknown biography commands still rejected","unsupported",Formats.decode("biog-text-v1",correction_example.replace("&","EXEC").to_utf8_buffer(),"BIOG01T0.TXT").kind)
	var corrected_source := SourceReader.new("biog-text-v1")
	corrected_source.initialize(fixture.classic_source.path_join("BIOG01T0.TXT"))
	var detached_annotation: Dictionary = corrected_source.read_record("biography")
	detached_annotation.value.source_annotations[0].raw_text = "caller mutation"
	check("source-correction annotations have read isolation","&",corrected_source.read_record("biography").value.source_annotations[0].raw_text.strip_edges())
	corrected_source.close()
	check("classic monster career decoded",true,candidate.resources[Actors.DOMAIN + ":catalog"].records.has("enemy-000"))
	check("classic monster is incomplete career metadata","encounter_career",at(candidate,"enemy-000").value.kind)
	check("all real monster careers structurally retained",43,candidate.resources[Actors.DOMAIN + ":catalog"].records.values().filter(func(r: Dictionary): return r.value.kind == "encounter_career").size())
	check("ENEMY005 uses the source-only career profile","career-source-v1",at(candidate,"enemy-005").value.input.format)
	var enemy_five: Dictionary = at(candidate,"enemy-005").value.data
	check("ENEMY005 unknown skill byte retained",true,enemy_five.skills.values().any(func(group: Array): return group.has(40.0)))
	check("classic ANC never promoted to gameplay",false,candidate.resources[Actors.DOMAIN + ":catalog"].records.has("ascr0000"))
	check("shipped profile uses virtual resource transport","res://content/actors",at(candidate,"format-profile").winner.root)
	check("classic pack bounds",2147483647,Formats.pack_flat(16777215,127).id)
	var known_conflict := "178 1\nred-cowled man\n1\n24\n14\n361\n\n178 1\nred-cloaked man\n1\n24\n14\n361\n"
	check("approved flat exception accepts reversed source order",true,Formats.decode("flats-cfg-v1",("178 1\nred-cloaked man\n1\n24\n14\n361\n\n178 1\nred-cowled man\n1\n24\n14\n361\n").to_utf8_buffer()).ok)
	check("flat exception cannot admit a third duplicate","malformed",Formats.decode("flats-cfg-v1",(known_conflict + "\n178 1\nred-cloaked man\n1\n24\n14\n361\n").to_utf8_buffer()).kind)
	check("flat exception cannot admit changed source fields","malformed",Formats.decode("flats-cfg-v1",known_conflict.replace("\n24\n","\n25\n").to_utf8_buffer()).kind)
	for pair in [[-1,0],[0,-1],[0,128],[16777216,0],[1.5,0]]: check("invalid packing " + str(pair),false,Formats.pack_flat(pair[0],pair[1]).ok)
	check("truncated career differentiates malformed","malformed",Formats.decode("career-cfg-v1",PackedByteArray([0])).kind)
	check("unknown format differentiates unsupported","unsupported",Formats.decode("future",PackedByteArray()).kind)
	check("painting truncation rejects","malformed",Formats.decode("paint-dat-v1",PackedByteArray([0])).kind)
	check("BIO truncation rejects","malformed",Formats.decode("bio-dat-v1","No terminator".to_utf8_buffer()).kind)
	check("malformed BIOG fails","malformed",Formats.decode("biog-text-v1","a. Answer before question".to_utf8_buffer()).kind)
	check("unsupported required effect rejects","unsupported",Formats.effect("EXEC arbitrary").kind)
	check("malformed required effect rejects","malformed",Formats.effect("IT 2 0").kind)
	check("GP sign spacing preserved",100,Formats.effect("GP + 100").value.parameters.amount)
	check("AE explicit declaration preserves operands",[8,12,3],Formats.effect("AE M 8 12 +3").get("value",{}).get("parameters",{}).get("operands",[]))
	check("unknown ampersand interpretation unavailable","unsupported",Formats.effect("&").kind)
	check("malformed AE operands fail","malformed",Formats.effect("AE M 8 bad +3").kind)
	check("overflow AE operand fails","malformed",Formats.effect("AE M 2147483648 12 +3").kind)
	check("unsupported biography header target fails","unsupported",Formats.decode("biog-text-v1","#65536\n1. Question\na. Answer\n22 +6\n".to_utf8_buffer()).kind)
	for marker in ["0","2147483648"]:
		check("invalid biography question number " + marker,"malformed",Formats.decode("biog-text-v1",(marker + ". Question\na. Answer\n22 +6\n").to_utf8_buffer()).kind)
	check("invalid required effect target fails","unsupported",Formats.effect("35 +6").kind)
	var unknown_career := FileAccess.get_file_as_bytes(selected.path_join("CLASS00.CFG"))
	unknown_career[8] = 255
	unknown_career[44] = 254
	check("unknown unused career byte retained",255,Formats.career(unknown_career).records.career.unknown1)
	check("unknown unused career array retained",254,Formats.career(unknown_career).records.career.unknown2[0])
	# Independent typed source lifecycle, using only disposable authored bytes.
	var reader := SourceReader.new("flats-cfg-v1")
	var path: String = sandbox.path_join("flat-source.cfg")
	var flat_text := "175 0\ncaption\n?2\n-99\n9876\n410\n"
	write(path,flat_text)
	check("checked source initialize",true,reader.initialize(path).ok)
	var first: Dictionary = reader.read_record("22400")
	check("unknown unused flat fields preserved",-99,first.value.unknown2)
	first.value.caption = "mutated"
	check("independent repeated source view","caption",reader.read_record("22400").value.caption)
	check("missing source record distinct","record_not_found",reader.read_record("999").kind)
	write(path,flat_text + "\n" + flat_text)
	check("changed length fails","malformed",reader.read_record("22400").kind)
	check("duplicate flat mapping rejects","malformed",Formats.decode("flats-cfg-v1",(flat_text + "\n" + flat_text).to_utf8_buffer()).kind)
	DirAccess.remove_absolute(path)
	check("removed source unavailable","source_unavailable",reader.read_record("22400").kind)
	reader.close()
	check("retired source cannot read","before_readiness",reader.read_record("22400").kind)
	var adapter := Actors.new()
	var appearance := authored("appearance",{"resource":"added/sprite/500000/200"})
	var actor := authored("actor",{"appearance":"shared","career":"class-00"},[{"id":"shared","kind":"appearance"},{"id":"class-00","kind":"class"}])
	var addition := envelope("add",[{"id":"shared","value":appearance},{"id":"added-one","value":actor},{"id":"added-two","value":actor}])
	var base: Dictionary = candidate.resources.duplicate(true)
	var removed_receipt: Dictionary = at(candidate,"biog01t0").value.data.duplicate(true)
	removed_receipt.erase("source_annotations")
	check("biography correction provenance cannot be stripped",false,apply_json(registry,base,envelope("patch",[{"id":"biog01t0","value":{"data":removed_receipt}}])).ok)
	var applied := apply_json(registry,base,addition)
	check("added IDs beyond flat packing accepted",true,applied.ok)
	check("shared appearance keeps distinct actor identities",false,applied.resources[Actors.DOMAIN + ":catalog"].records["added-one"].identity == applied.resources[Actors.DOMAIN + ":catalog"].records["added-two"].identity)
	check("repeated add rejects duplicate IDs",false,apply_json(registry,applied.resources,addition).ok)
	var bad_actor := actor.duplicate(true)
	bad_actor.references[1].id = "missing-career"
	bad_actor.data.career = "missing-career"
	var missing := apply_json(registry,base,envelope("add",[{"id":"bad-actor","value":bad_actor}]))
	var issues := adapter.validate_references(missing.resources)
	check("required reference carries referring ID",Actors.DOMAIN + ":catalog#bad-actor",issues[1].source)
	check("required reference carries target","missing-career",issues[1].target)
	var duplicate: Dictionary = at(candidate,"flat-22400").value.duplicate(true)
	duplicate.erase("input")
	var ambiguous := apply_json(registry,base,envelope("add",[{"id":"duplicate-flat","value":duplicate}]))
	check("ambiguous mappings fail combined validation",1,adapter.validate_references(ambiguous.resources).size())
	var before := JSON.stringify(base)
	var late := envelope("patch",[{"id":"class-00","value":{"unused":{"label":"valid first entry"}}},{"id":"class-00","value":{"kind":"execute"}}])
	check("late invalid patch rejects complete contribution",false,apply_json(registry,base,late).ok)
	check("late patch changes no base bytes",before,JSON.stringify(base))
	var reordered := bio.duplicate(true)
	reordered.data.questions.reverse()
	reordered.data.questions[0].answers.reverse()
	reordered.data.questions[0].text = "Translated question"
	check("translated reordered biography validates","",adapter.validate_record("translated",reordered))
	check("question marker survives reorder","q12",reordered.data.questions[0].id)
	check("unknown unused metadata accepted","",adapter.validate_record("career",klass.value.merged({"unused":{"future":123}})))
	check("unsupported required field fails",false,adapter.validate_record("career",klass.value.merged({"execute":"bad"})).is_empty())
	check("classic numeric alias cannot create a second class mapping",false,adapter.validate_record("career",klass.value.merged({"classic":"0"},true)).is_empty())
	check("classic numeric negative mapping rejects",false,adapter.validate_record("career",klass.value.merged({"classic":"-1"},true)).is_empty())
	var tampered := bio.duplicate(true)
	tampered.data.questions[0].answers[0].effects[0].target = "text.rsc:missing"
	check("effect target cannot disagree with checked declaration",false,adapter.validate_record("biography",tampered).is_empty())
	var forged := actor.duplicate(true)
	forged.input = {"source":"classic://invented"}
	check("authored source provenance cannot impersonate classic input",false,apply_json(registry,base,envelope("add",[{"id":"forged","value":forged}])).ok)
	# Real folder and ZIP package intake, order, omission and menu commitment.
	var package := manifest("actors.patch")
	package.content = ["patch.json"]
	package.capabilities = ["data.actor-inputs-v1"]
	write(mods.root.path_join("Mods/actors/mod.json"),JSON.stringify(package))
	write(mods.root.path_join("Mods/actors/patch.json"),JSON.stringify(late))
	mods.rescan()
	mods.edit("actors.patch","toggle")
	candidate = registry.prepare(mods)
	check("real invalid package blocks candidate",false,candidate.ok)
	check("real invalid package changes no earlier class",false,at(candidate,"class-00").value.has("unused"))
	check("real rejected contribution explicitly omittable",true,candidate.issues[0].omittable)
	check("real omission accepted",true,registry.omit(candidate.issues[0].token,candidate.ticket,mods).ok)
	check("real omission revalidates",true,registry.prepare(mods).ok)
	var valid_patch := envelope("patch",[{"id":"class-00","value":{"unused":{"provider":"folder"}}}])
	write(mods.root.path_join("Mods/actors/patch.json"),JSON.stringify(valid_patch))
	var zip_manifest := manifest("actors.zip")
	zip_manifest.content = ["add.json"]
	zip_manifest.dependencies = [{"id":"actors.patch"}]
	archive(mods.root.path_join("Mods/actors.zip"),{"mod.json":JSON.stringify(zip_manifest),"add.json":JSON.stringify(addition)})
	mods.rescan()
	mods.edit("actors.zip","toggle")
	candidate = registry.prepare(mods)
	check("real folder and ZIP recovery validate",true,candidate.ok)
	if not candidate.ok:
		checks.append({"scenario":"package diagnostics","expected":"valid","actual":JSON.stringify(candidate)})
		return terminal(fixture)
	check("real folder field provenance","actors.patch",at(candidate,"class-00").fields.unused.provider)
	check("real loose precedence wins last","@loose",at(candidate,"class-00").winner.provider)
	check("replacement retains classic origin","@shipped/actor-inputs-v1",at(candidate,"class-00").identity.package)
	check("real ZIP added origin","actors.zip",at(candidate,"added-one").identity.package)
	# Whole-resource replacement uses the same checked ZIP contribution. Keep all
	# mandatory references/profile, remove just an unreferenced added actor.
	var replacement_entries: Array = []
	for id: String in candidate.resources[Actors.DOMAIN + ":catalog"].records:
		if id != "added-two": replacement_entries.append({"id":id,"value":at(candidate,id).value})
	archive(mods.root.path_join("Mods/actors.zip"),{"mod.json":JSON.stringify(zip_manifest),"add.json":JSON.stringify(envelope("replace",replacement_entries))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("real ZIP replacement validates",true,candidate.ok)
	check("real replacement removes unreferenced record",false,candidate.resources[Actors.DOMAIN + ":catalog"].records.has("added-two"))
	check("real replacement preserves matching class identity",klass.identity,at(candidate,"class-00").identity)
	check("real replacement provider tracked","actors.zip",at(candidate,"class-00").fields.data.provider)
	write(mods.root.path_join("Overrides/z-actor.json"),"invalid changed loose file")
	check("loose intake remains immutable until restart",true,registry.prepare(mods).ok)
	# Replacing the whole record set cannot omit required class/profile references.
	var missing_reference := replacement_entries.duplicate(true)
	missing_reference = missing_reference.filter(func(entry: Dictionary): return entry.id != "class-00")
	archive(mods.root.path_join("Mods/actors.zip"),{"mod.json":JSON.stringify(zip_manifest),"add.json":JSON.stringify(envelope("replace",missing_reference))})
	mods.rescan()
	var rejected: Dictionary = registry.prepare(mods)
	check("real missing required reference blocks candidate",false,rejected.ok)
	check("real mandatory reference cannot be omitted",true,rejected.issues.any(func(issue: Dictionary): return issue.kind == "references" and not issue.omittable and issue.get("target") == "class-00"))
	archive(mods.root.path_join("Mods/actors.zip"),{"mod.json":JSON.stringify(zip_manifest),"add.json":JSON.stringify(envelope("replace",replacement_entries))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("real reference repair retries cleanly",true,candidate.ok)
	var stale: int = candidate.ticket
	registry.prepare(mods)
	check("stale actor candidate rejects","stale",registry.reserve_commit(stale,mods).kind)
	controller.providers.faults.menu = true
	check("menu failure publishes no actors",false,controller.continue_to_menu("run").ok)
	check("menu failure retains no active actor catalog",{},registry.active())
	controller.providers.faults.clear()
	controller.check_content()
	check("normal real menu transaction publishes actors","main_menu",controller.continue_to_menu("run").route)
	var view := Actors.lookup(registry,"class-00")
	check("structural lookup available after menu",true,view.ok)
	check("published flat lookup cannot choose conflict winner","ambiguous_mapping",Actors.lookup_classic(registry,"flat","22785").kind)
	check("City Watch source cannot bypass CHAR validation","semantic_unavailable",Actors.lookup(registry,"career-source-18","construct_actor").kind)
	check("monster unsupported source diagnostic preserved",40,Actors.lookup(registry,"enemy-005").source_diagnostics[0].value)
	check("monster source cannot bypass NPC validation","semantic_unavailable",Actors.lookup(registry,"enemy-005","spawn_actor").kind)
	check("published City Watch unsupported-byte diagnostic preserved",35,Actors.lookup(registry,"career-source-18").source_diagnostics[0].value)
	check("structural lookup cannot claim owner readiness",false,view.semantic_ready)
	check("structural data cannot authorize actor use","semantic_unavailable",Actors.lookup(registry,"class-00","construct_actor").kind)
	check("classic adapter resolves stable identity",view.record.identity,Actors.lookup_classic(registry,"class","00").record.identity)
	check("unmapped class never defaults to zero","record_not_found",Actors.lookup_classic(registry,"class","missing").kind)
	view.record.value.data.name = "caller mutation"
	check("active read isolation","Mage",Actors.lookup(registry,"class-00").record.value.data.name)
	check("menu locks actor rebuild","locked",registry.prepare(mods).kind)
	check("menu locks MOD",true,mods.locked)
	check("late adapter registration rejects",false,controller.providers.enable_actor_inputs().ok)
	var session_before: Dictionary = shell.session_shell.core.snapshot()
	var catalog_before: Dictionary = registry.active()
	Actors.lookup(registry,"class-00")
	Actors.lookup(registry,"biog00t0")
	Actors.lookup(registry,"biog00t0","apply_effects")
	adapter.validate_references(catalog_before.resources)
	adapter.validate_references(catalog_before.resources)
	check("repeated reads and validation leave CORE session unchanged",session_before,shell.session_shell.core.snapshot())
	check("repeated reads and validation leave active definitions unchanged",catalog_before,registry.active())
	controller.open_setup()
	controller.continue_to_menu()
	check("return to menu retains locked actor catalog",catalog_before,registry.active())
	if DisplayServer.get_name() != "headless":
		shell.render()
		await capture(shell,"actor-input-menu")
		check("rendered actor menu remains actual menu","main_menu",controller.route)
	return terminal(fixture)

func terminal(fixture: Dictionary) -> Dictionary:
	var ok := true
	for item: Dictionary in checks: ok = ok and Formats.equal_input(item.expected,item.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs,"source":fixture.classic_source,"downstream":"Structural DATA only; real CHAR/NPC/effect validation, construction, application and SAVE remain unavailable."}
