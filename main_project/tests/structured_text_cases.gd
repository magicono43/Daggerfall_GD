extends "res://tests/text_cases.gd"
const Structured = preload("res://scripts/data/structured_text.gd")
const Access = preload("res://scripts/data/classic_access.gd")
const Reader = preload("res://scripts/data/text_rsc_reader.gd")

func bytes_file(path: String, bytes: PackedByteArray) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()

func rsc(records: Dictionary) -> PackedByteArray:
	var header := (records.size() + 1) * 6
	var result := PackedByteArray()
	result.resize(header + 2)
	result.encode_u16(0,header)
	var ordinal := 0
	for id: int in records:
		result.encode_u16(2 + ordinal * 6,id)
		result.encode_u32(4 + ordinal * 6,result.size())
		result.append_array(records[id])
		ordinal += 1
	result.encode_u16(2 + ordinal * 6,65535)
	result.encode_u32(4 + ordinal * 6,result.size())
	return result

func composition(root: String) -> RefCounted:
	for file: String in ["ARCH3D.BSA","BLOCKS.BSA","MAPS.BSA","DAGGER.SND"]:
		bytes_file(root.path_join(file),PackedByteArray([1,0,0,2,42,232,3,0,0,1,0,0,0]))
	var access := Access.new()
	check("register real text reader " + root.get_base_dir().get_file(),true,access.register_adapter("fixture-text",[{"file":"TEXT.RSC","format":Reader.VERSION}]))
	check("enable text capability " + root.get_base_dir().get_file(),true,access.enable_capability("fixture-text"))
	return access

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var missing_root: String = sandbox.path_join("missing-text/ARENA2")
	for file: String in ["ARCH3D.BSA","BLOCKS.BSA","MAPS.BSA","DAGGER.SND"]:
		bytes_file(missing_root.path_join(file),PackedByteArray([1,0,0,2,42,232,3,0,0,1,0,0,0]))
	var accepted: ConfigFile = shell.controller.settings.clone(shell.controller.settings.accepted)
	shell.controller.select_folder(missing_root)
	check("normal source selection requires real TEXT.RSC","mandatory_setup",shell.controller.route)
	check("normal missing text publishes no readers",false,shell.controller.providers.classic.ready())
	check("normal missing text retains no candidate readers",0,shell.controller.providers.classic.prepared_count())
	check("normal missing text leaves accepted settings unchanged",accepted.encode_to_text(),shell.controller.settings.accepted.encode_to_text())
	check("normal missing text never enters menu",false,shell.controller.menu_entered)
	shell.render()
	var result: Dictionary = await super.run(shell,fixture)
	var classic: RefCounted = shell.controller.providers.classic
	check("real required text in production manifest",true,classic.manifest().entries.any(func(e: Dictionary): return e.file == "TEXT.RSC" and e.format == Reader.VERSION))
	check("real source reader inventory",5,classic.inventory().size())
	check("reader frozen","text-rsc-v1",Reader.VERSION)
	check("classic token profile frozen","classic-controls-v1",Tokens.CLASSIC_PROFILE)
	var conflicting := Access.new()
	check("first source format registers",true,conflicting.register_adapter("one",[{"file":"TEXT.RSC","format":Reader.VERSION}]))
	conflicting.enable_capability("one")
	check("second declared source format registers",true,conflicting.register_adapter("two",[{"file":"TEXT.RSC","format":"bsa-v1"}]))
	conflicting.enable_capability("two")
	check("conflicting composed formats reject","capability_unavailable",conflicting.manifest().kind)
	conflicting.dispose()
	var raw: Dictionary = classic.read_record("TEXT.RSC",25)
	var known := Structured.read(classic,25)
	check("known real input record decodes",true,known.ok)
	check("real input literal and macro retained","You have %gii gold pieces. How many",known.tokens[0].text)
	check("real exact token order",["text","justify_center","text","justify_center","text","input_cursor","text","justify_center","record_end"],known.tokens.map(func(t: Dictionary): return t.kind))
	check("real cursor byte position",raw.bytes.find(248),known.tokens[5].position)
	check("real absolute source position",raw.offset + raw.bytes.find(248),known.tokens[5].absolute_position)
	check("real record mapping",25,known.record)
	check("real source mapping",raw.source,known.source)
	var variants := Structured.read(classic,11)
	check("real authored variant count",5,variants.variants.size())
	check("real first variant","I have no idea.",Tokens.select_classic(variants,0).tokens[0].text)
	check("real retained selected variant","You tell me.",Tokens.select_classic(variants,4).tokens[0].text)
	check("no implicit real selection",false,variants.has("variant"))
	check("absent explicit variant rejected","variant_unavailable",Tokens.select_classic(variants,5).kind)
	check("negative explicit variant rejected","variant_unavailable",Tokens.select_classic(variants,-1).kind)
	check("missing real record distinct","record_not_found",Structured.read(classic,65534).kind)
	var literal := "  {literal} \\ %pcname  ".to_ascii_buffer()
	var synthetic := literal.duplicate()
	synthetic.append_array(PackedByteArray([0,251,20,249,3,248,246,252,253,255,66,32,254]))
	var decoded := Tokens.decode_classic(synthetic,"synthetic",42,100)
	check("synthetic controls decode",true,decoded.ok)
	var encoded := Tokens.encode_classic(decoded.tokens,"synthetic",42)
	check("structural source codec encodes",true,encoded.ok)
	check("structural source codec exact bytes",synthetic.hex_encode(),encoded.bytes.hex_encode())
	check("source codec deterministic second decode",decoded.tokens.map(func(t: Dictionary): return t.kind),Tokens.decode_classic(encoded.bytes,"synthetic",42).tokens.map(func(t: Dictionary): return t.kind))
	check("real source codec exact bytes",raw.bytes.hex_encode(),Tokens.encode_classic(known.tokens,raw.source,25).bytes.hex_encode())
	check("unknown structured kind rejects","unsupported_required_control",Tokens.encode_classic([{"kind":"execute"}],"bad",4).kind)
	check("unknown structured field rejects","malformed_text",Tokens.encode_classic([{"kind":"input_cursor","operand":1}],"bad",4).kind)
	check("unknown literal field rejects","malformed_text",Tokens.encode_classic([{"kind":"text","text":"A","action":"accept"}],"bad",4).kind)
	check("invalid structured operand rejects","malformed_text",Tokens.encode_classic([{"kind":"position","operand":256}],"bad",4).kind)
	check("nonASCII source literal rejects","malformed_text",Tokens.encode_classic([{"kind":"text","text":"é"}],"bad",4).kind)
	check("operand accepts complete byte domain",255,Tokens.decode_classic(PackedByteArray([251,255,65,254]),"operand",4).tokens[0].operand)
	check("real directory alias IDs share explicit address",Structured.read(classic,1200).offset,Structured.read(classic,1201).offset)
	check("real alias retains queried ID",1201,Structured.read(classic,1201).record)
	check("meaningful literal spaces and escapes",literal.get_string_from_ascii(),decoded.tokens[0].text)
	check("exact supported token order",["text","line_break","position","font","input_cursor","page_break","justify_left","justify_center","variant_break","text","record_end"],decoded.tokens.map(func(t: Dictionary): return t.kind))
	check("position operand retained",20,decoded.tokens[2].operand)
	check("font operand retained",3,decoded.tokens[3].operand)
	check("operand length retained",2,decoded.tokens[2].length)
	check("synthetic authored variants",2,decoded.variants.size())
	check("second variant trailing space retained","B ",Tokens.select_classic(decoded,1).tokens[0].text)
	check("line and page remain distinct",true,decoded.tokens[1].kind != decoded.tokens[5].kind)
	var malformed_cases := [[251],[249],[251,254],[249,255],[65],[65,254,66]]
	var failure_positions := [0,0,2,2,1,2]
	for case_index in malformed_cases.size():
		var sample: Array = malformed_cases[case_index]
		var failed := Tokens.decode_classic(PackedByteArray(sample),"bad-source",7,200)
		check("malformed record rejects " + str(sample),"malformed_text",failed.kind)
		check("malformed source identity " + str(sample),"bad-source",failed.source)
		check("malformed record identity " + str(sample),7,failed.record)
		check("malformed position present " + str(sample),true,failed.position >= 0 and failed.absolute_position == failed.position + 200)
		check("malformed exact byte position " + str(sample),failure_positions[case_index],failed.position)
	for code: int in [1,2,127,128,250]:
		var failed := Tokens.decode_classic(PackedByteArray([65,code,254]),"unsupported",8,10)
		check("unknown required byte rejects " + str(code),"unsupported_required_control",failed.kind)
		check("unknown required byte position " + str(code),1,failed.position)
	var empty := Tokens.decode_classic(PackedByteArray([255,65,255,254]),"empty",9)
	check("empty variants diagnosed",2,empty.diagnostics.size())
	check("empty variant diagnostic positions",[0,3],empty.diagnostics.map(func(d: Dictionary): return d.position))
	check("empty variant diagnostic authored IDs",[0,2],empty.diagnostics.map(func(d: Dictionary): return d.variant))
	check("empty variant IDs not renumbered",[0,1,2],empty.variants.map(func(v: Dictionary): return v.id))
	check("empty variant explicitly rejected","variant_unavailable",Tokens.select_classic(empty,0).kind)
	check("usable authored identity retained",1,Tokens.select_classic(empty,1).variant)
	check("all empty fails","empty_variants",Tokens.decode_classic(PackedByteArray([255,254]),"empty",9).kind)
	var root: String = sandbox.path_join("rsc-lifetime/ARENA2")
	var access := composition(root)
	check("missing required text blocks preparation",false,access.prepare(root).ok)
	check("missing source cleanup",0,access.prepared_count())
	check("missing source never ready",false,access.ready())
	var source_bytes := rsc({42:synthetic,43:PackedByteArray([65,254]),44:PackedByteArray([65,251]),45:PackedByteArray([250,254]),46:PackedByteArray([255,254])})
	bytes_file(root.path_join("TEXT.RSC"),source_bytes)
	var validated: Dictionary = access.validate(root)
	DirAccess.rename_absolute(root.path_join("TEXT.RSC"),root.path_join("held.rsc"))
	check("loss after validation fails initialization",false,access.initialize_readers(validated).ok)
	check("partial reader initialization cleaned",0,access.prepared_count())
	DirAccess.rename_absolute(root.path_join("held.rsc"),root.path_join("TEXT.RSC"))
	var prepared: Dictionary = access.prepare(root)
	check("real reader retry prepares",true,prepared.ok)
	check("initialized readers unpublished",5,access.prepared_count())
	check("unpublished text access rejects","before_readiness",Structured.read(access,42).kind)
	access.discard_prepared()
	check("interrupted reader set cleared",0,access.prepared_count())
	check("interrupted ticket cannot activate",false,access.activate(prepared).ok)
	prepared = access.prepare(root)
	check("repeated preparation succeeds",true,prepared.ok)
	check("activate complete set",true,access.activate(prepared).ok)
	check("spent initialization ticket rejected",false,access.activate(prepared).ok)
	check("repeat active preparation idempotent",true,access.activate(access.prepare(root)).ok)
	var identity: Array = access.inventory()
	check("indexed synthetic matches direct decoder",decoded.tokens.map(func(t: Dictionary): return t.kind),Structured.read(access,42).tokens.map(func(t: Dictionary): return t.kind))
	check("indexed malformed payload fails","malformed_text",Structured.read(access,44).kind)
	check("indexed unsupported payload fails","unsupported_required_control",Structured.read(access,45).kind)
	check("indexed empty payload fails","empty_variants",Structured.read(access,46).kind)
	check("missing ID never scans neighbor","record_not_found",Structured.read(access,41).kind)
	check("reader ID stable on repeated read",identity,access.inventory())
	DirAccess.rename_absolute(root.path_join("TEXT.RSC"),root.path_join("retained.rsc"))
	check("source loss distinct","source_unavailable",Structured.read(access,42).kind)
	DirAccess.rename_absolute(root.path_join("retained.rsc"),root.path_join("TEXT.RSC"))
	check("restored source readable",true,Structured.read(access,42).ok)
	var changed := source_bytes.duplicate()
	changed.append(0)
	bytes_file(root.path_join("TEXT.RSC"),changed)
	check("active source length loss distinguished","malformed_text",Structured.read(access,42).kind)
	bytes_file(root.path_join("TEXT.RSC"),source_bytes)
	check("restored source length readable",true,Structured.read(access,42).ok)
	var other: String = sandbox.path_join("rsc-other/ARENA2")
	var other_access := composition(other)
	other_access.dispose()
	bytes_file(other.path_join("TEXT.RSC"),source_bytes)
	var replacement: Dictionary = access.prepare(other)
	check("replacement source initializes",true,replacement.ok)
	check("active source replacement requires restart","restart_required",access.activate(replacement).kind)
	check("rejected replacement cleaned",0,access.prepared_count())
	check("rejected replacement retains active identity",identity,access.inventory())
	check("late text capability registration rejects",false,access.register_adapter("late",[{"file":"TEXT.RSC","format":Reader.VERSION}]))
	access.dispose()
	check("disposed text unreadable","before_readiness",Structured.read(access,42).kind)
	var good := rsc({42:PackedByteArray([65,254])})
	var corruptions: Array = [PackedByteArray(),PackedByteArray([1,0]),good.slice(0,8)]
	var bad := good.duplicate()
	bad.encode_u32(4,1)
	corruptions.append(bad)
	bad = good.duplicate()
	bad.encode_u16(8,42)
	corruptions.append(bad)
	for index in corruptions.size():
		bytes_file(root.path_join("TEXT.RSC"),corruptions[index])
		var reader := Reader.new()
		check("malformed directory rejects " + str(index),"malformed_text",reader.initialize(root.path_join("TEXT.RSC")).kind)
		check("failed directory retains no reader " + str(index),0,reader.inventory().count)
	var reordered := rsc({42:PackedByteArray([65,254]),43:PackedByteArray([66,254])})
	var first := reordered.slice(2,8)
	for byte in 6:
		reordered[2 + byte] = reordered[8 + byte]
		reordered[8 + byte] = first[byte]
	bytes_file(root.path_join("TEXT.RSC"),reordered)
	var reordered_reader := Reader.new()
	check("directory enumeration may differ from physical order",true,reordered_reader.initialize(root.path_join("TEXT.RSC")).ok)
	check("reordered directory preserves explicit first ID","41fe",reordered_reader.read_record(42).bytes.hex_encode())
	check("reordered directory preserves explicit second ID","42fe",reordered_reader.read_record(43).bytes.hex_encode())
	reordered_reader.close()
	var registry: RefCounted = shell.controller.providers.definitions
	var maps := {"sample/absent":25,"sample/greeting":25,"sample/order":25,"sample/broken":25,"new/unbounded.key":11,"sample/no-record":65534}
	check("selected translation precedes classic","selected",Structured.lookup(registry,classic,"sample","greeting","zz-Test",maps).kind)
	check("base precedes mapped classic","base",Structured.lookup(registry,classic,"sample","broken","zz-Test",maps).kind)
	check("explicit mapped source fallback",25,Structured.lookup(registry,classic,"sample","absent","zz-Test",maps).record)
	check("new key explicitly mapped",11,Structured.lookup(registry,classic,"new","unbounded.key","en",maps).record)
	check("unmapped key has no numeric inference","missing",Structured.lookup(registry,classic,"sample","25","en",maps).kind)
	check("missing mapped record remains failure","missing",Structured.lookup(registry,classic,"sample","no-record","en",maps).kind)
	check("independent essential recovery precedes classic","essential_fallback",Structured.lookup(null,classic,"recovery","retry","en",{"recovery/retry":25}).kind)
	var required := [{"kind":"justify_center"},{"kind":"justify_center"},{"kind":"input_cursor"},{"kind":"justify_center"}]
	check("interaction structure cannot flatten to catalog","source",Structured.lookup(registry,classic,"sample","greeting","zz-Test",maps,required).kind)
	check("incompatible required source structure fails","missing",Structured.lookup(registry,classic,"sample","absent","en",maps,[{"kind":"page_break"}]).kind)
	check("required ordered operands checked",false,Tokens.require_structure(decoded.tokens,[{"kind":"position","operand":21}]).ok)
	check("catalog structural failure still allows base","base",Catalog.lookup(registry,"sample","blank","zz-Test","",[]).kind)
	check("invalid mapping rejects","missing",Structured.lookup(registry,classic,"unknown","bad","en",{"unknown/bad":65535}).kind)
	var core := Core.new(material)
	var owner := Owner.new()
	core.provider = owner
	core.startup_route_changed("main_menu")
	check("structured owner admission","Succeeded",core.request({"id":"structured-owner","mode":"new","origin":""}).kind)
	var before: Dictionary = core.randomness.snapshot()
	var facts: Dictionary = owner.retained_snapshot()
	var active: Dictionary = registry.active()
	var plan: Dictionary = shell.controller.mods.planning_input()
	for iteration in 3:
		Structured.lookup(registry,classic,"sample","absent","en",maps)
		Tokens.select_classic(Structured.read(classic,11),4)
	check("reads and repeated refresh zero gameplay draws",before,core.randomness.snapshot())
	check("reads never mutate owner",facts,owner.retained_snapshot())
	check("reads never rebuild DATA",active,registry.active())
	check("reads never unlock MOD",plan,shell.controller.mods.planning_input())
	check("actual menu remains committed",true,shell.controller.menu_entered)
	# Explicit isolated sample context; this is not the DATA-016 macro registry.
	var sample_context := {"gold":"42 {literal} %pcname"}
	var sample: Array = known.tokens.duplicate(true)
	for token: Dictionary in sample:
		if token.kind == "text":
			token.text = token.text.replace("%gii",sample_context.gold)
	check("sample literal insertion no recursion","You have 42 {literal} %pcname gold pieces. How many",sample[0].text)
	check("sample leaves template untouched","You have %gii gold pieces. How many",known.tokens[0].text)
	check("sample context consumes no gameplay RNG",before,core.randomness.snapshot())
	check("sample context mutates no owner",facts,owner.retained_snapshot())
	if DisplayServer.get_name() != "headless":
		for child in shell.panel.get_children():
			child.free()
		shell.label("Structured classic text — isolated sample",26)
		shell.label("TEXT.RSC / 25; explicit sample gold = 42. No input is submitted.")
		var line := ""
		for token: Dictionary in sample:
			if token.kind == "text":
				line += token.text
			elif token.kind in ["justify_center","justify_left","line_break"]:
				shell.label(line)
				line = ""
			elif token.kind == "input_cursor":
				line += "[input cursor]"
		shell.label("Synthetic structure: line / position(20) / font(3) / input / page / left / center / variant(1)",16)
		shell.label("Literal run: " + literal.get_string_from_ascii())
		shell.label("Selected authored variant 1: [B ] — trailing space retained",16)
		shell.panel.get_parent().scroll_vertical = 0
		await capture(shell,"structured-sample")
		check("sample frame retains selected identity",1,Tokens.select_classic(decoded,1).variant)
		check("sample frame no RNG draws",before,core.randomness.snapshot())
		check("sample frame no owner mutation",facts,owner.retained_snapshot())
	core.dispose()
	result.fixture = "IMP-007-structured-v1"
	result.reader = Reader.VERSION
	result.profile = Tokens.CLASSIC_PROFILE
	result.real_record = known
	result.real_variants = variants
	result.synthetic = decoded
	result.sample_context = sample_context
	result.sample_tokens = sample
	result.classic_sha256 = FileAccess.get_sha256(fixture.classic_source.path_join("TEXT.RSC"))
	result.checks = checks
	result.count = checks.size()
	result.ok = checks.all(func(c: Dictionary): return c.expected == c.actual)
	return result
