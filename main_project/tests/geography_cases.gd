extends "res://tests/text_cases.gd"
const Inputs = preload("res://scripts/data/geography_inputs.gd")
const Formats = preload("res://scripts/data/geography_formats.gd")
const Reader = preload("res://scripts/data/geography_source_reader.gd")

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})
	if checks.size()%20 == 0: print("Geography assertion ",checks.size(),": ",id)

func envelope(operation: String, entries: Array, path := Inputs.BASE_PATH) -> Dictionary:
	return {"domain":Inputs.DOMAIN,"path":path,"operation":operation,"entries":entries}

func at(candidate: Dictionary, id: String, path := Inputs.BASE_PATH) -> Dictionary:
	return candidate.resources[Inputs.DOMAIN+":"+path].records[id]

func apply_json(registry: RefCounted, base: Dictionary, body: Dictionary, provider := "test.pack") -> Dictionary:
	return registry.apply_contribution(base,JSON.stringify(body).to_utf8_buffer(),{"provider":provider,"root":sandbox,"file":"input.json","version":"1.0.0"})

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var mods: RefCounted = controller.mods
	var adapter := Inputs.new()
	adapter.classic = controller.providers.classic
	controller.settings.effective["startup/show_setup"] = true
	check("before menu unavailable","before_readiness",Inputs.lookup(registry,Inputs.BASE_PATH,"place-00000").kind)
	# Loose patch of a region gives a smaller complete object, and the ZIP below
	# patches the same region to prove actual loose precedence.
	write(mods.root.path_join("Overrides/geography.json"),JSON.stringify(envelope("patch",[{"id":"region-00","value":{"data":{"name":"Loose region"}}}])))
	var selected: Dictionary = controller.select_folder(fixture.classic_source)
	var candidate: Dictionary = registry.projection()
	check("complete actual geographic inventory prepares",true,candidate.get("ok",false))
	if not candidate.get("ok",false):
		check("source diagnoses","none",JSON.stringify(candidate.get("issues",selected.get("failures",[]))))
		return terminal(fixture)
	var records: Dictionary = candidate.resources[Inputs.DOMAIN+":"+Inputs.BASE_PATH].records
	check("baseline complete record count",15325,records.size())
	for pair in [["region",62],["location",15251],["climate",10],["context",1],["classic_samples",1]]:
		check("complete family "+pair[0],pair[1],records.values().filter(func(r: Dictionary): return r.value.kind == pair[0]).size())
	check("accepted faction catalog composed",643,candidate.resources["faction-quest.inputs:packs/dfu"].records.size())
	check("profile PCK intake",Inputs.PROFILE_HASH,FileAccess.get_sha256(Inputs.ROOT+"profile.json"))
	check("DFU license PCK intake","6e5e22fa760938ab398743150787896bd20fcf4936aad0122704700bad1e669a",FileAccess.get_sha256(Inputs.ROOT+"DFU_LICENSE.txt"))
	var observation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/geography_source_observation.json"))
	for pin: Dictionary in observation.location_pins:
		var record: Dictionary = records[pin.id]
		for field in ["name","longitude","latitude","type","dungeon","full_map","map_key","quest_id","ordinal","pitem_offset"]:
			check("independent "+pin.id+" "+field,pin[field],record.value.data.raw[field])
		check("independent "+pin.id+" position",pin.pixel,record.value.data.position)
		check("independent "+pin.id+" membership",Inputs.ref(pin.region),record.value.data.region)
	check("classic discovery copied with unresolved behavior",{"value":false,"policy":"source-flag-v1","classic_behavior_verified":false},records["place-00100"].value.data.initial_discovery)
	check("map identity and position differ",true,records["place-00001"].value.data.raw.full_map != records["place-00001"].value.data.raw.map_key)
	# Pure negative vectors keep only the required catalog slice. Full production
	# inventory qualification above and real MOD/CORE rebuilds below remain intact.
	var small: Dictionary = candidate.resources[Inputs.DOMAIN+":"+Inputs.BASE_PATH].duplicate(false)
	small.records = {}
	for id: String in records:
		if id in ["place-00000","region-00","extent","classic-samples"] or id.begins_with("climate-"): small.records[id] = records[id].duplicate(true)
	var base: Dictionary = {Inputs.DOMAIN+":"+Inputs.BASE_PATH:small}
	var original: Dictionary = records["place-00000"]
	var moved: Dictionary = original.value.data.duplicate(true)
	moved.name = "Duplicate name"
	moved.position = [1,1]
	var changed := apply_json(registry,base,envelope("patch",[{"id":"place-00000","value":{"data":moved}}]))
	check("rename and valid move accepted",true,changed.ok)
	check("move preserves identity",original.identity,at(changed,"place-00000").identity)
	check("move preserves raw position",original.value.data.raw,at(changed,"place-00000").value.data.raw)
	check("move preserves classic mappings",original.value.mappings,at(changed,"place-00000").value.mappings)
	check("move tracks winning provider","test.pack",at(changed,"place-00000").winner.provider)
	var added := Inputs.value("location",{"name":"Duplicate name","region":Inputs.ref("region-00"),"position":[1,1],"type":0,"dungeon":255,"initial_discovery":{"value":false,"policy":"authored-v1","classic_behavior_verified":false}})
	var contribution := envelope("add",[{"id":"new-place","value":added}],"packs/test.pack")
	var parent_resources: Dictionary = changed.resources
	changed = apply_json(registry,changed.resources,contribution)
	check("location without classic quest ID valid",true,changed.ok)
	at(changed,"climate-223").value.data.name = "Caller mutation of untouched resource"
	check("public candidate detaches untouched resources","Ocean",parent_resources[Inputs.DOMAIN+":"+Inputs.BASE_PATH].records["climate-223"].value.data.name)
	var indexes := Inputs.indexes(changed.resources)
	check("same pixel locations allowed",2,indexes.pixels["1,1"].size())
	check("same names remain candidates",2,indexes.names["Duplicate name"].size())
	check("added location no fabricated classic mapping",[],at(changed,"new-place","packs/test.pack").value.mappings)
	check("duplicate stable ID rejects",false,apply_json(registry,changed.resources,contribution).ok)
	var reorder_input := apply_json(registry,changed.resources,envelope("add",[{"id":"sibling","value":added}],"packs/test.pack"))
	var reordered := apply_json(registry,reorder_input.resources,envelope("replace",[{"id":"sibling","value":added},{"id":"new-place","value":added}],"packs/test.pack"),"other.pack")
	check("explicit replacement retains originating identity",at(changed,"new-place","packs/test.pack").identity,at(reordered,"new-place","packs/test.pack").identity)
	check("explicit replacement tracks winner","other.pack",at(reordered,"new-place","packs/test.pack").winner.provider)
	var duplicate_mapping := added.duplicate(true)
	duplicate_mapping.mappings = original.value.mappings
	var conflict := apply_json(registry,base,envelope("add",[{"id":"conflict","value":duplicate_mapping}],"packs/test.pack"))
	check("ambiguous classic mapping invalidates index",false,Inputs.indexes(conflict.resources).ok)
	var missing_region := added.duplicate(true)
	missing_region.data.region = "packs/test.pack#absent"
	var absent := apply_json(registry,base,envelope("add",[{"id":"absent","value":missing_region}],"packs/test.pack"))
	check("missing region never substitutes",false,Inputs.indexes(absent.resources).ok)
	var bad_move := moved.duplicate(true)
	bad_move.position = [1000,0]
	var outside := apply_json(registry,base,envelope("patch",[{"id":"place-00000","value":{"data":bad_move}}]))
	check("authored position outside extent fails",false,Inputs.indexes(outside.resources).ok)
	var late := apply_json(registry,base,envelope("add",[{"id":"new-place","value":added},{"id":"bad","value":{"schema":"future"}}],"packs/test.pack"))
	check("late invalid contribution rejects atomically",false,late.ok)
	check("rejected add did not mutate input",false,base.has(Inputs.DOMAIN+":packs/test.pack"))
	var context: Dictionary = records.extent.value.data.duplicate(true)
	context.bounds = [0,0,1001,500]
	var expanded := apply_json(registry,base,envelope("patch",[{"id":"extent","value":{"data":context}}]))
	check("incomplete expansion rejected",false,Inputs.indexes(expanded.resources).ok)
	var tile := Inputs.value("samples",{"bounds":[1000,0,1001,500],"unit":"classic-height-u8","layout":"row-major-north-down-v1","heights":[],"climates":[],"detail":[]})
	for i in 500:
		tile.data.heights.append(27)
		tile.data.climates.append(Inputs.ref("climate-231"))
		tile.data.detail.append([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25])
	context.tiles.append("packs/test.pack#expansion")
	expanded = apply_json(registry,base,envelope("patch",[{"id":"extent","value":{"data":context}}]))
	expanded = apply_json(registry,expanded.resources,envelope("add",[{"id":"expansion","value":tile}],"packs/test.pack"))
	check("complete expansion beyond classic allowed",true,Inputs.indexes(expanded.resources).ok)
	var incomplete := tile.duplicate(true)
	incomplete.data.heights.pop_back()
	check("missing interior sample fails schema",false,adapter.validate_record("tile",incomplete).is_empty())
	var unknown := tile.duplicate(true)
	unknown.data.climates[0] = "packs/test.pack#unknown-climate"
	var unknown_result := apply_json(registry,base,envelope("add",[{"id":"unknown","value":unknown}],"packs/test.pack"))
	check("unknown climate never becomes temperate",false,Inputs.indexes(unknown_result.resources).ok)
	var roundtrip := Formats.convert("classic-longitude-latitude-v1","classic-map-tile",[78504,15016],Formats.FRAME)
	check("checked source pixel conversion",[613,382],roundtrip.coordinates)
	check("subpixel remainder retained",[40,40],roundtrip.subtile)
	check("source frame exact round trip",[78504,15016],Formats.source_from_pixel(roundtrip.coordinates,roundtrip.subtile).coordinates)
	check("physics conversion unavailable","unsupported_conversion",Formats.convert(Formats.FRAME,"map-pixel",[1,1],"godot-motor").kind)
	check("source bounds reject negatives","out_of_bounds",Formats.convert("classic-longitude-latitude-v1","classic-map-tile",[-1,0],Formats.FRAME).kind)
	var sequence: Array = []
	for i in 25: sequence.append(i)
	check("classic detail explicit reversal",[16,17,18,11,12,13,6,7,8],Inputs.detail_neighborhood(sequence).samples)
	for pair in [["PAK truncated", "geography-pak-v1",PackedByteArray()],["WOODS truncated","woods-source-v1",PackedByteArray()]]:
		check(pair[0],"malformed",Formats.decode(pair[1],pair[2]).kind)
	var pak := FileAccess.get_file_as_bytes(str(fixture.classic_source).path_join("CLIMATE.PAK"))
	check("PAK actual full inventory",500500,Formats.pak(pak).samples.size())
	var trailing := pak.duplicate()
	trailing.append(0)
	check("PAK trailing rejected","malformed",Formats.pak(trailing).kind)
	var zero := pak.duplicate()
	zero.encode_u16(2000,0)
	check("PAK zero run rejected","malformed",Formats.pak(zero).kind)
	var bad_offset := pak.duplicate()
	bad_offset.encode_u32(0,1999)
	check("PAK offset rejected","malformed",Formats.pak(bad_offset).kind)
	var overflow := pak.duplicate()
	overflow.encode_u16(2000,1002)
	check("PAK run overflows row rejected","malformed",Formats.pak(overflow).kind)
	check("PAK final run truncation rejected","malformed",Formats.pak(pak.slice(0,pak.size()-1)).kind)
	check("unsupported format explicit","unsupported",Formats.decode("future",pak).kind)
	var reader := Reader.new("geography-pak-v1")
	check("retired reader not empty success","before_readiness",reader.read_record([0,0]).kind)
	check("missing required source explicit","source_unavailable",reader.initialize(sandbox.path_join("absent.pak")).kind)
	var copied := sandbox.path_join("source.pak")
	var copy_file := FileAccess.open(copied,FileAccess.WRITE)
	copy_file.store_buffer(pak)
	copy_file.close()
	check("read only source preparation",true,reader.initialize(copied).ok)
	check("reader open mode retained","READ",reader.inventory().open_mode)
	check("raw PAK outside rejects","out_of_bounds",reader.read_record([1001,0]).kind)
	check("raw PAK row zero valid",true,reader.read_record([0,0]).ok)
	write(copied,"truncated")
	check("later truncated source explicit","source_unavailable",reader.read_record([0,0]).kind)
	reader.close()
	check("reader disposal enforced","before_readiness",reader.read_record([0,0]).kind)
	var names := PackedByteArray()
	names.resize(36)
	names.encode_u32(0,1)
	for i in 4: names[4+i] = "Root".unicode_at(i)
	var table := PackedByteArray()
	table.resize(17)
	var pitem := PackedByteArray()
	pitem.resize(43)
	var root := Formats.region(names,table,pitem)
	check("zero map value preserved",0,root.locations[0].full_map)
	check("zero quest ID source preserved",0,root.locations[0].quest_id)
	check("zero source latitude uses north down frame",[0,499],root.locations[0].pixel)
	pitem.encode_u32(4,4294967295)
	check("invalid door skip extent rejected","malformed",Formats.region(names,table,pitem).kind)
	check("trailing map table rejected","malformed",Formats.region(names,table+PackedByteArray([0]),pitem).kind)
	check("invalid names/table rejected","malformed",Formats.region(PackedByteArray([1,0,0,0]),PackedByteArray(),PackedByteArray()).kind)
	# Real checked folder / ZIP / loose path and transaction lifecycle.
	var package := manifest("test.pack")
	package.content = ["add.json"]
	write(mods.root.path_join("Mods/test/mod.json"),JSON.stringify(package))
	write(mods.root.path_join("Mods/test/add.json"),JSON.stringify(contribution))
	var zip_manifest := manifest("other.pack")
	zip_manifest.content = ["patch.json"]
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_manifest),"patch.json":JSON.stringify(envelope("patch",[{"id":"place-00000","value":{"data":moved}}]))})
	mods.rescan()
	mods.edit("test.pack","toggle")
	mods.edit("other.pack","toggle")
	candidate = registry.prepare(mods)
	check("real folder ZIP prepare",true,candidate.ok)
	check("folder addition origin","test.pack",at(candidate,"new-place","packs/test.pack").identity.package)
	check("ZIP replacement winner","other.pack",at(candidate,"place-00000").winner.provider)
	check("real loose intake highest tier","@loose",at(candidate,"region-00").winner.provider)
	check("real loose value retained","Loose region",at(candidate,"region-00").value.data.name)
	write(mods.root.path_join("Overrides/geography.json"),"external edit requires restart")
	check("loose edits not adopted live",true,registry.prepare(mods).ok)
	write(mods.root.path_join("Mods/test/add.json"),JSON.stringify(envelope("add",[{"id":"new-place","value":added},{"id":"bad","value":{"schema":"future"}}],"packs/test.pack")))
	mods.rescan()
	candidate = registry.prepare(mods)
	check("real late invalid contribution blocks",false,candidate.ok)
	check("real late invalid leaves no partial pack",false,candidate.resources.has(Inputs.DOMAIN+":packs/test.pack"))
	var omittable: Array = candidate.issues.filter(func(issue: Dictionary): return issue.omittable)
	check("explicit omission accepted",true,registry.omit(omittable[0].token,candidate.ticket,mods).ok)
	check("omission clean rebuild",true,registry.prepare(mods).ok)
	write(mods.root.path_join("Mods/test/add.json"),JSON.stringify(contribution))
	mods.rescan()
	candidate = registry.prepare(mods)
	check("repair retry succeeds",true,candidate.ok)
	var required := added.duplicate(true)
	required.data.region = "packs/test.pack#provider-region"
	zip_manifest.content = ["patch.json","required.json"]
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_manifest),"patch.json":JSON.stringify(envelope("patch",[{"id":"place-00000","value":{"data":moved}},{"id":"region-00","value":{"data":{"name":"ZIP region"}}} ])),"required.json":JSON.stringify(envelope("add",[{"id":"requires-region","value":required}],"packs/other.pack"))})
	var provider := {"id":"provider-region","value":Inputs.value("region",{"name":"Provider region"})}
	write(mods.root.path_join("Mods/test/add.json"),JSON.stringify(envelope("add",contribution.entries+[provider,provider],"packs/test.pack")))
	mods.rescan()
	candidate = registry.prepare(mods)
	check("invalid required provider blocks",false,candidate.ok)
	omittable = candidate.issues.filter(func(issue: Dictionary): return issue.omittable)
	check("required provider explicit omission accepted",true,registry.omit(omittable[0].token,candidate.ticket,mods).ok)
	candidate = registry.prepare(mods)
	check("omission cannot bypass remaining region reference",false,candidate.ok)
	check("remaining reference reports exact target",true,candidate.issues.any(func(issue: Dictionary): return issue.get("target") == "packs/test.pack#provider-region" and not issue.omittable))
	write(mods.root.path_join("Mods/test/add.json"),JSON.stringify(envelope("add",contribution.entries+[provider],"packs/test.pack")))
	mods.rescan()
	candidate = registry.prepare(mods)
	check("required provider repair validates",true,candidate.ok)
	check("loose wins over actual ZIP region patch","Loose region",at(candidate,"region-00").value.data.name)
	write(mods.root.path_join("Mods/test/add.json"),JSON.stringify(envelope("add",contribution.entries+[provider,{"id":"expansion","value":tile}],"packs/test.pack")))
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_manifest),"patch.json":JSON.stringify(envelope("patch",[{"id":"place-00000","value":{"data":moved}},{"id":"region-00","value":{"data":{"name":"ZIP region"}}},{"id":"extent","value":{"data":context}}])),"required.json":JSON.stringify(envelope("add",[{"id":"requires-region","value":required}],"packs/other.pack"))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("real folder ZIP expansion qualifies",true,candidate.ok)
	var stale: int = candidate.ticket
	registry.prepare(mods)
	check("stale ticket rejects","stale",registry.reserve_commit(stale,mods).kind)
	controller.providers.faults.menu = true
	check("interrupted menu rejects",false,controller.continue_to_menu("run").ok)
	check("interrupted menu no publication",{},registry.active())
	controller.providers.faults.clear()
	controller.check_content()
	check("actual CORE menu publication","main_menu",controller.continue_to_menu("run").route)
	for pin: Dictionary in observation.pins:
		var sample := adapter.sample(registry,int(pin.pixel[0]),int(pin.pixel[1]))
		check("independent coarse "+str(pin.pixel),pin.coarse,sample.value)
		check("independent detail "+str(pin.pixel),pin.detail,sample.detail)
		check("independent interpreted detail "+str(pin.pixel),pin.inner_reversed,Inputs.detail_neighborhood(sample.detail).samples)
		check("independent aligned climate "+str(pin.pixel),pin.climate_aligned,sample.climate_raw_code)
		check("independent politic "+str(pin.pixel),pin.politic_aligned,sample.politic_raw_code)
	check("published expanded pixel samples authored height",27,adapter.sample(registry,1000,0).value)
	check("authored climate receives no classic X shift",Inputs.ref("climate-231"),adapter.sample(registry,1000,0).climate)
	check("expanded outer bound rejects ordinarily","out_of_bounds",adapter.sample(registry,1001,0).kind)
	check("expanded explicit clamp uses new boundary",[1000,499],adapter.sample(registry,1001,500,true).pixel)
	var detached_sample := adapter.sample(registry,999,499)
	detached_sample.detail[0] = 255
	check("sample view detached",82,adapter.sample(registry,999,499).detail[0])
	check("ordinary outside query rejects",["out_of_bounds","malformed"],[adapter.sample(registry,-1,0).kind,adapter.sample(registry,1.5,0).kind])
	check("explicit edge clamp reuses boundary",[0,0],adapter.sample(registry,-1,-1,true).pixel)
	check("clamp recorded",true,adapter.sample(registry,-1,-1,true).clamped)
	check("ordinary location outside rejects","out_of_bounds",Inputs.search(registry,[-1,0]).kind)
	check("valid pixel no locations",[],Inputs.search(registry,[0,0]).records)
	check("pixel returns independently identified places",4,Inputs.search(registry,[1,1]).records.size())
	check("duplicate names search all",3,Inputs.search(registry,"Duplicate name","name").records.size())
	check("explicit classic quest mapping resolves","place-00000",Inputs.search(registry,"selected-classic-v1/quest/0/26052","mapping").records[0].identity.record)
	check("missing mapping no nearby substitution","missing",Inputs.search(registry,"selected-classic-v1/quest/0/0","mapping").kind)
	var detached := Inputs.lookup(registry,Inputs.BASE_PATH,"place-00000")
	detached.record.value.data.name = "mutation"
	check("detached record views","Duplicate name",Inputs.lookup(registry,Inputs.BASE_PATH,"place-00000").record.value.data.name)
	check("physics remains unavailable",false,Inputs.lookup(registry,Inputs.BASE_PATH,"place-00000").physics_ready)
	check("save compatibility remains unavailable",false,Inputs.lookup(registry,Inputs.BASE_PATH,"place-00000").save_compatible)
	check("durable identity resolves after move",true,Inputs.resolve_identity(registry,original.identity).ok)
	var wrong_origin: Dictionary = original.identity.duplicate(true)
	wrong_origin.package = "other.pack"
	check("durable origin cannot silently remap","missing",Inputs.resolve_identity(registry,wrong_origin).kind)
	check("menu locks DATA","locked",registry.prepare(mods).kind)
	check("menu locks MOD",true,mods.locked)
	var session_hash := JSON.stringify(shell.session_shell.core.snapshot()).sha256_text()
	adapter.sample(registry,1,1)
	Inputs.search(registry,[1,1])
	check("reads leave live session unchanged",session_hash,JSON.stringify(shell.session_shell.core.snapshot()).sha256_text())
	check("repeat Continue idempotent","main_menu",controller.continue_to_menu("run").route)
	controller.open_setup()
	controller.continue_to_menu()
	check("title setup return retains expanded context",27,adapter.sample(registry,1000,0).value)
	if DisplayServer.get_name() != "headless":
		shell.render()
		await capture(shell,"geography-main-menu")
		check("rendered actual menu",true,find_button(shell.panel,"New Game") != null and controller.menu_entered)
	return terminal(fixture)

func terminal(fixture: Dictionary) -> Dictionary:
	var ok := true
	for item: Dictionary in checks: ok = ok and Inputs.Common.equal_input(item.expected,item.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs,"source":fixture.classic_source,"downstream":"Geographic source records only; real WORLD/LOC/MOVE/SAVE and discovery behavior gates open."}
