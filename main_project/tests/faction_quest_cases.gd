extends "res://tests/text_cases.gd"
const Inputs = preload("res://scripts/data/faction_quest_inputs.gd")
const Formats = preload("res://scripts/data/faction_quest_formats.gd")
const Reader = preload("res://scripts/data/faction_quest_source_reader.gd")

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})

func envelope(operation: String, entries: Array, path := Inputs.BASE_PATH) -> Dictionary:
	return {"domain":Inputs.DOMAIN,"path":path,"operation":operation,"entries":entries}

func at(candidate: Dictionary, id: String, path := Inputs.BASE_PATH) -> Dictionary:
	return candidate.resources[Inputs.DOMAIN+":"+path].records[id]

func apply_json(registry: RefCounted, base: Dictionary, body: Dictionary, provider := "test.pack") -> Dictionary:
	return registry.apply_contribution(base,JSON.stringify(body).to_utf8_buffer(),{"provider":provider,"root":sandbox,"file":"input.json","version":"1.0.0"})

func controlled(request: Dictionary) -> Dictionary:
	var record: Dictionary = request.record
	var lines: Array = []
	if record.kind == "quest":
		var text_lines := str(record.data.text).replace("\r\n","\n").replace("\r","\n").split("\n")
		for i in text_lines.size():
			if text_lines[i] == "unknown required command": return {"ok":false,"line":i+1,"target":"unknown","reason":"Unsupported command."}
			lines.append({"line":i+1,"text":text_lines[i],"disposition":"executable","supported":true,"command":"controlled.fixture"})
	return {"ok":true,"static_valid":true,"runtime_checks":["live world binding remains deferred"],"unsupported":[],"lines":lines,"checked":request.required_checks,"references":[]}

func incomplete(_request: Dictionary) -> Dictionary:
	return {"ok":true,"static_valid":true,"runtime_checks":[],"unsupported":[],"lines":[]}

func required_reference(request: Dictionary) -> Dictionary:
	var response := controlled(request)
	response.references = [{"referring":"test-script:1","target":Inputs.ref(Inputs.BASE_PATH,"absent"),"kind":"quest"}]
	return response

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var mods: RefCounted = controller.mods
	var adapter := Inputs.new()
	controller.settings.effective["startup/show_setup"] = true
	check("version frozen","faction-quest-inputs-v1",Inputs.VERSION)
	check("before menu unavailable","before_readiness",Inputs.lookup(registry,Inputs.BASE_PATH,"faction-17").kind)
	var loose_data := {"metadata":{"name":"Loose name","type":2},"defaults":{"rep":0},"parent":{},"allies":[],"enemies":[],"flats":[],"line":0,"field_lines":{}}
	write(mods.root.path_join("Overrides/z-faction.json"),JSON.stringify(envelope("patch",[{"id":"faction-17","value":{"data":loose_data}}])))
	controller.select_folder(fixture.classic_source)
	var candidate: Dictionary = registry.projection()
	check("complete actual source baseline prepares",true,candidate.get("ok",false))
	if not candidate.get("ok",false):
		check("baseline diagnostics","valid",JSON.stringify(candidate.get("issues",[])))
		return terminal(fixture)
	check("normal pre-menu setup reachable","optional_setup",controller.route)
	var records: Dictionary = candidate.resources[Inputs.DOMAIN+":"+Inputs.BASE_PATH].records
	check("complete catalog count",643,records.size())
	for pair in [["faction",366],["quest",265],["list",2],["table",10]]:
		check("complete source family "+pair[0],pair[1],records.values().filter(func(r: Dictionary): return r.value.kind == pair[0]).size())
	check("actor baseline retained",true,candidate.resources.has("actor.inputs:catalog"))
	check("item spell baseline retained",436,candidate.resources["item-spell.inputs:catalog"].records.size())
	check("PCK profile intake hash",Inputs.PROFILE_HASH,FileAccess.get_sha256(Inputs.ROOT+"profile.json"))
	check("PCK license intake hash","6e5e22fa760938ab398743150787896bd20fcf4936aad0122704700bad1e669a",FileAccess.get_sha256(Inputs.ROOT+"DFU_LICENSE.txt"))
	var faction: Dictionary = at(candidate,"faction-3").value
	check("independent faction metadata",{"type":0,"name":"Molag Bal","summon":-1,"region":-1,"power":50,"flags":1,"face":-1,"race":-1,"sgroup":6,"ggroup":2,"minf":25,"maxf":70},faction.data.metadata)
	check("starting reputation separate",{"rep":0},faction.data.defaults)
	check("explicit classic faction mapping",["faction:3"],faction.mappings)
	check("explicit parent reference",Inputs.ref(Inputs.BASE_PATH,"faction-17"),faction.data.parent)
	check("directional ally source",[Inputs.ref(Inputs.BASE_PATH,"faction-16")],faction.data.allies)
	check("directional enemies source",[Inputs.ref(Inputs.BASE_PATH,"faction-25"),Inputs.ref(Inputs.BASE_PATH,"faction-15")],faction.data.enemies)
	check("appearance source units preserved",[[175,9]],faction.data.flats)
	check("region source one based retained",60,at(candidate,"faction-194").value.data.metadata.region)
	check("optional rank not invented",false,faction.data.defaults.has("rank"))
	check("original faction receipt retained","365cb347fa3e93b99c1646e06009955dc9510fc4143eeca447f5f835bce00cb5",faction.input.sha256)
	var custom: Dictionary = at(candidate,"quest-088").value
	check("complete independent quest source hash","0c96ddb4d3dfa71004cf76ebf800d33c3f791aef6d1fc156d8e23484343331dc",Inputs.Common.sha256(custom.data.text.to_utf8_buffer()))
	check("quest explicit classic source mapping",["quest:CUSTOM01"],custom.mappings)
	check("quest text preserves authored metadata",true,custom.data.text.contains("DisplayName: From Dusk Till Dead"))
	check("classic list complete entries",187,at(candidate,"questlist-classic").value.data.rows.size())
	var list: Dictionary = at(candidate,"questlist-dfu").value
	check("DFU list independently pinned",{"name":"CUSTOM01","group":"FightersGuild","membership":"M","minReq":40,"flag":"0","notes":"New quest exclusive to Daggerfall Unity"},list.data.rows[0].values)
	check("list target explicit identity",Inputs.ref(Inputs.BASE_PATH,"quest-088"),list.data.targets.CUSTOM01)
	var counts := {"quests-diseases":17,"quests-factions":428,"quests-foes":62,"quests-globalvars":66,"quests-items":120,"quests-places":130,"quests-sounds":295,"quests-spells":89,"quests-staticmessages":17,"spells-entity":46}
	for id: String in counts: check("complete shared table "+id,counts[id],at(candidate,id).value.data.rows.size())
	check("hex place source parameters",{"name":"AlcaireCoven","p1":50010,"p2":1,"p3":-1},at(candidate,"quests-places").value.data.rows[0].values)
	check("non-primary aliases retained",[1006,1006],[at(candidate,"quests-staticmessages").value.data.rows[7].values.id,at(candidate,"quests-staticmessages").value.data.rows[8].values.id])
	var raw := FileAccess.get_file_as_bytes(Inputs.ROOT+"Factions/FACTION.TXT")
	check("full faction raw decode",366,Formats.decode("factions",raw).records.size())
	for pair in [["empty","quest",PackedByteArray(),"empty"],["invalid utf8","quest",PackedByteArray([255]),"malformed"],["nul","quest",PackedByteArray([97,0]),"malformed"],["unknown format","future",raw,"unsupported"],["unknown field","factions","#1\nname: A\ntype: 2\nfuture: 7".to_utf8_buffer(),"unsupported"],["duplicate faction","factions","#1\nname: A\ntype: 2\n#1\nname: B\ntype: 2".to_utf8_buffer(),"ambiguous"],["skipped indentation","factions","\t#1\nname: A\ntype: 2".to_utf8_buffer(),"malformed"],["truncated table","table","schema: id,*name\n1".to_utf8_buffer(),"malformed"],["trailing table","table","schema: id,*name\n1,a,extra".to_utf8_buffer(),"malformed"],["schema missing","table","1,a".to_utf8_buffer(),"malformed"],["duplicate primary","table","schema: id,*name\n1,a\n2,a".to_utf8_buffer(),"ambiguous"],["duplicate list","list",("schema: "+Formats.LIST_SCHEMA+"\nx,FightersGuild,M,0,0,\nx,FightersGuild,M,0,0,").to_utf8_buffer(),"ambiguous"]]:
		check("checked source rejects "+pair[0],pair[3],Formats.decode(pair[1],pair[2],"vector").kind)
	check("schema permits explicitly empty list",true,Formats.decode("list",("schema: "+Formats.LIST_SCHEMA).to_utf8_buffer()).data.empty)
	check("BOM alone is empty source","empty",Formats.decode("quest",PackedByteArray([239,187,191])).kind)
	check("zero faction target retained as source sentinel",[0],Formats.decode("factions","#1\nname: A\ntype: 2\nally: 0".to_utf8_buffer()).records["1"].allies)
	var reader := Reader.new("factions")
	check("PCK reader initializes",true,reader.initialize(Inputs.ROOT+"Factions/FACTION.TXT").ok)
	var detached := reader.read_record("3")
	detached.value.fields.name = "mutation"
	check("reader detached views","Molag Bal",reader.read_record("3").value.fields.name)
	check("reader absent record distinct","missing",reader.read_record("999999").kind)
	reader.close()
	check("reader retirement enforced","before_readiness",reader.read_record().kind)
	var path := sandbox.path_join("source.txt")
	write(path,"complete source")
	reader = Reader.new("quest")
	reader.initialize(path)
	write(path,"changed source!")
	check("same length changed source rejected","source_unavailable",reader.read_record().kind)
	check("missing source distinct","missing",reader.initialize(sandbox.path_join("absent.txt")).kind)
	check("unreadable source distinct","unavailable",reader.initialize(sandbox).kind)
	check("real owner unavailable","semantic_unavailable",Inputs.validate_handoff(custom).kind)
	check("controlled complete handoff succeeds",true,Inputs.validate_handoff(custom,controlled).ok)
	check("controlled handoff cannot certify production",false,Inputs.validate_handoff(custom,controlled).semantic_ready)
	check("reduced script never succeeds",false,Inputs.validate_handoff(custom,incomplete).ok)
	check("owner required static reference fails with target","absent",Inputs.validate_handoff(custom,required_reference).target.id)
	var unknown: Dictionary = Inputs.from_text("quest","unknown required command").value
	check("unsupported executable retained verbatim","unknown required command",unknown.data.text)
	check("unsupported executable fails usable validation",false,Inputs.validate_handoff(unknown,controlled).ok)
	check("faction controlled static handoff",true,Inputs.validate_handoff(faction,controlled).ok)
	check("faction real interpretation unavailable","semantic_unavailable",Inputs.validate_handoff(faction).kind)
	# Pure adapter vectors need only this domain; real startup below still rebuilds
	# the complete actor/item/faction composition through production preparation.
	var base: Dictionary = {Inputs.DOMAIN+":"+Inputs.BASE_PATH:candidate.resources[Inputs.DOMAIN+":"+Inputs.BASE_PATH].duplicate(true)}
	var root_value := Inputs.value("faction",loose_data)
	var addition := envelope("add",[{"id":"same-basename","value":Inputs.from_text("quest","Quest: SAME\nQRC:\nQBN:\n").value},{"id":"new-faction","value":root_value}],"packs/test.pack")
	var added := apply_json(registry,base,addition)
	check("package additions need no numeric ranges",true,added.ok)
	var second := apply_json(registry,added.resources,envelope("add",[{"id":"same-basename","value":Inputs.from_text("quest","Quest: SAME\nQRC:\nQBN:\n").value}],"packs/other.pack"),"other.pack")
	check("different pack same basename remains independent",true,second.ok)
	check("same pack duplicate ID rejected",false,apply_json(registry,added.resources,addition).ok)
	var renamed := root_value.duplicate(true)
	renamed.data.metadata.name = "Renamed duplicate display name"
	var rename := apply_json(registry,added.resources,envelope("patch",[{"id":"new-faction","value":{"data":renamed.data}}],"packs/test.pack"))
	check("renaming preserves originating identity",at(added,"new-faction","packs/test.pack").identity,at(rename,"new-faction","packs/test.pack").identity)
	check("new record cannot take another package path",false,apply_json(registry,base,addition,"other.pack").ok)
	var duplicate_mapping := root_value.duplicate(true)
	duplicate_mapping.mappings = ["faction:3"]
	var dup := apply_json(registry,base,envelope("add",[{"id":"dup","value":duplicate_mapping}],"packs/test.pack"))
	check("duplicate classic mapping rejected",false,Inputs.graph(dup.resources).ok)
	var self_parent: Dictionary = faction.data.duplicate(true)
	self_parent.parent = Inputs.ref(Inputs.BASE_PATH,"faction-3")
	var self_cycle := apply_json(registry,base,envelope("patch",[{"id":"faction-3","value":{"data":self_parent}}]))
	check("self parent rejected",false,Inputs.graph(self_cycle.resources).ok)
	var cycle_data := loose_data.duplicate(true)
	cycle_data.parent = Inputs.ref(Inputs.BASE_PATH,"faction-3")
	var cycle := apply_json(registry,base,envelope("patch",[{"id":"faction-17","value":{"data":cycle_data}}]))
	check("complete parent cycle path",true,Inputs.graph(cycle.resources).issues.any(func(issue: Dictionary): return issue.get("cycle",[]) == ["packs/dfu#faction-17","packs/dfu#faction-3","packs/dfu#faction-17"]))
	var orphan: Dictionary = faction.data.duplicate(true)
	orphan.parent = Inputs.ref(Inputs.BASE_PATH,"absent")
	var missing := apply_json(registry,base,envelope("patch",[{"id":"faction-3","value":{"data":orphan}}]))
	check("missing parent fails required reference",true,Inputs.graph(missing.resources).issues.any(func(issue: Dictionary): return issue.target == "packs/dfu#absent"))
	var reparent: Dictionary = faction.data.duplicate(true)
	reparent.parent = {}
	var changed := apply_json(registry,base,envelope("patch",[{"id":"faction-3","value":{"data":reparent}}]))
	check("reparent removes obsolete edge",false,Inputs.graph(changed.resources).children["packs/dfu#faction-17"].has("packs/dfu#faction-3"))
	check("children rebuild idempotent",Inputs.graph(changed.resources).children,Inputs.graph(changed.resources).children)
	var directional := Inputs.value("faction",loose_data.duplicate(true))
	directional.data.allies = [Inputs.ref("packs/test.pack","new-faction")]
	var relations := apply_json(registry,added.resources,envelope("add",[{"id":"directional","value":directional}],"packs/test.pack"))
	check("directional relation does not synthesize reciprocity",[],at(relations,"new-faction","packs/test.pack").value.data.allies)
	var reciprocal := root_value.duplicate(true)
	reciprocal.data.allies = [Inputs.ref("packs/test.pack","directional")]
	var relation_cycle := apply_json(registry,relations.resources,envelope("patch",[{"id":"new-faction","value":{"data":reciprocal.data}}],"packs/test.pack"))
	check("relationship cycle is not a parent cycle",true,Inputs.graph(relation_cycle.resources).ok)
	var duplicate_list: Dictionary = Inputs.from_text("list","schema: "+Formats.LIST_SCHEMA+"\nfirst,FightersGuild,M,0,0,\nsecond,FightersGuild,M,0,0,").value
	duplicate_list.data.targets = {"first":Inputs.ref(Inputs.BASE_PATH,"quest-088"),"second":Inputs.ref(Inputs.BASE_PATH,"quest-088")}
	check("same quest aliased twice within list rejected",false,adapter.validate_record("aliases",duplicate_list).is_empty())
	var other_list := list.duplicate(true)
	other_list.erase("input")
	other_list.mappings = []
	check("same quest in separate list valid",true,apply_json(registry,base,envelope("add",[{"id":"separate-list","value":other_list}],"packs/test.pack")).ok)
	var bad_list := list.duplicate(true)
	bad_list.data.targets.CUSTOM01 = Inputs.ref(Inputs.BASE_PATH,"absent")
	var missing_quest := apply_json(registry,base,envelope("patch",[{"id":"questlist-dfu","value":bad_list}]))
	check("missing quest list target blocks",false,Inputs.graph(missing_quest.resources).ok)
	var late := envelope("patch",[{"id":"faction-3","value":{"data":reparent}},{"id":"absent","value":{"data":reparent}}])
	check("late invalid whole contribution rejected",false,apply_json(registry,base,late).ok)
	check("rejected contribution preserves input base",faction.data,base[Inputs.DOMAIN+":"+Inputs.BASE_PATH].records["faction-3"].value.data)
	check("arbitrary executable line merging rejected",false,apply_json(registry,base,envelope("patch",[{"id":"quest-088","value":{"append_lines":["grant reward"]}}])).ok)
	var package := manifest("test.pack")
	package.content = ["patch.json"]
	package.capabilities = ["data."+Inputs.VERSION]
	write(mods.root.path_join("Mods/test/mod.json"),JSON.stringify(package))
	write(mods.root.path_join("Mods/test/patch.json"),JSON.stringify(late))
	mods.rescan()
	mods.edit("test.pack","toggle")
	candidate = registry.prepare(mods)
	check("real folder invalid late entry blocks",false,candidate.ok)
	check("real invalid late entry rolls back",faction.data,at(candidate,"faction-3").value.data)
	check("explicit omission accepted",true,registry.omit(candidate.issues[0].token,candidate.ticket,mods).ok)
	check("omission rebuild validates remainder",true,registry.prepare(mods).ok)
	write(mods.root.path_join("Mods/test/patch.json"),JSON.stringify(addition))
	var zip_manifest := manifest("other.pack")
	zip_manifest.dependencies = [{"id":"test.pack"}]
	zip_manifest.content = ["patch.json"]
	var zip_body := envelope("add",[{"id":"same-basename","value":Inputs.from_text("quest","Other unrelated source").value}],"packs/other.pack")
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_manifest),"patch.json":JSON.stringify(zip_body)})
	mods.rescan()
	mods.edit("other.pack","toggle")
	candidate = registry.prepare(mods)
	check("real folder ZIP repair validates",true,candidate.ok)
	check("real folder addition origin","test.pack",at(candidate,"same-basename","packs/test.pack").identity.package)
	check("real ZIP basename isolation origin","other.pack",at(candidate,"same-basename","packs/other.pack").identity.package)
	check("real loose precedence wins","Loose name",at(candidate,"faction-17").value.data.metadata.name)
	check("real loose field winner","@loose",at(candidate,"faction-17").fields.data.provider)
	# Omission cannot make a still-required source disappear successfully.
	var required_list := other_list.duplicate(true)
	required_list.data.targets.CUSTOM01 = Inputs.ref("packs/test.pack","required-source")
	var require_body := envelope("add",[{"id":"same-basename","value":Inputs.from_text("quest","Other unrelated source").value},{"id":"requires-folder-source","value":required_list}],"packs/other.pack")
	package.content = ["patch.json","z-required.json"]
	write(mods.root.path_join("Mods/test/mod.json"),JSON.stringify(package))
	var required_entry := {"id":"required-source","value":Inputs.from_text("quest","Required raw source").value}
	write(mods.root.path_join("Mods/test/z-required.json"),JSON.stringify(envelope("add",[required_entry,required_entry],"packs/test.pack")))
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_manifest),"patch.json":JSON.stringify(require_body)})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("late invalid addition leaves required target unresolved",false,candidate.ok)
	var omittable: Array = candidate.issues.filter(func(issue: Dictionary): return issue.omittable)
	check("omit invalid required provider accepted",true,registry.omit(omittable[0].token,candidate.ticket,mods).ok)
	candidate = registry.prepare(mods)
	check("omission cannot bypass remaining mandatory reference",false,candidate.ok)
	check("remaining reference identifies required target",true,candidate.issues.any(func(issue: Dictionary): return issue.get("target") == "packs/test.pack#required-source" and not issue.omittable))
	write(mods.root.path_join("Mods/test/z-required.json"),JSON.stringify(envelope("add",[required_entry],"packs/test.pack")))
	mods.rescan()
	check("required provider repair revalidates",true,registry.prepare(mods).ok)
	var replacement: Array = []
	for id: String in candidate.resources[Inputs.DOMAIN+":"+Inputs.BASE_PATH].records: replacement.append({"id":id,"value":at(candidate,id).value})
	replacement.reverse()
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_manifest),"patch.json":JSON.stringify(envelope("replace",replacement))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("real reordered replacement succeeds",true,candidate.ok)
	check("replacement preserves originating identity",at({"resources":base},"faction-3").identity,at(candidate,"faction-3").identity)
	check("replacement tracks contributor",true,at(candidate,"faction-3").contributors.any(func(c: Dictionary): return c.provider == "other.pack"))
	var removed := replacement.filter(func(entry: Dictionary): return entry.id != "quest-088")
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_manifest),"patch.json":JSON.stringify(envelope("replace",removed))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("remaining mandatory quest reference blocks",false,candidate.ok)
	check("reference cannot be omitted",true,candidate.issues.any(func(issue: Dictionary): return issue.kind == "references" and not issue.omittable and issue.target == "packs/dfu#quest-088"))
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_manifest),"patch.json":JSON.stringify(envelope("replace",replacement))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("required reference repair succeeds",true,candidate.ok)
	var stale: int = candidate.ticket
	registry.prepare(mods)
	check("stale candidate cannot commit","stale",registry.reserve_commit(stale,mods).kind)
	write(mods.root.path_join("Overrides/z-faction.json"),"external edits require restart")
	check("loose source captured until restart",true,registry.prepare(mods).ok)
	controller.providers.faults.menu = true
	check("interrupted CORE commitment rejects",false,controller.continue_to_menu("run").ok)
	check("interrupted commitment leaves no active data",{},registry.active())
	controller.providers.faults.clear()
	controller.check_content()
	check("actual CORE publication reaches menu","main_menu",controller.continue_to_menu("run").route)
	check("published faction structural lookup",true,Inputs.lookup(registry,Inputs.BASE_PATH,"faction-3").ok)
	check("published source cannot execute","semantic_unavailable",Inputs.lookup(registry,Inputs.BASE_PATH,"quest-088","execute").kind)
	check("published faction cannot change standing","semantic_unavailable",Inputs.lookup(registry,Inputs.BASE_PATH,"faction-3","standing").kind)
	check("classic mapping uses stable explicit assignment","quest-088",Inputs.lookup_mapping(registry,"quest:CUSTOM01").record.identity.record)
	check("missing mapping distinct","missing",Inputs.lookup_mapping(registry,"quest:ABSENT").kind)
	check("shared table primary key projection",1006,Inputs.table_row(registry,Inputs.BASE_PATH,"quests-staticmessages","RumorsPostFailure").row.values.id)
	check("non-primary table value never guesses identity","missing",Inputs.table_row(registry,Inputs.BASE_PATH,"quests-staticmessages","1006").kind)
	check("children projection contains authored child",true,Inputs.children(registry,Inputs.BASE_PATH,"faction-17").children.has("packs/dfu#faction-3"))
	var read := Inputs.lookup(registry,Inputs.BASE_PATH,"faction-3")
	read.record.value.data.metadata.name = "caller mutation"
	check("published detached views","Molag Bal",Inputs.lookup(registry,Inputs.BASE_PATH,"faction-3").record.value.data.metadata.name)
	check("production semantic readiness remains false",false,Inputs.lookup(registry,Inputs.BASE_PATH,"quest-088").semantic_ready)
	check("menu locks definitions","locked",registry.prepare(mods).kind)
	check("menu locks mods",true,mods.locked)
	var session_hash := JSON.stringify(shell.session_shell.core.snapshot()).sha256_text()
	var catalog_hash := JSON.stringify(registry.active()).sha256_text()
	for repeat in 2:
		Inputs.lookup(registry,Inputs.BASE_PATH,"quest-088")
		Inputs.validate_handoff(custom,controlled)
		adapter.validate_references(registry.active().resources)
	check("reads validation leave live session unchanged",session_hash,JSON.stringify(shell.session_shell.core.snapshot()).sha256_text())
	check("reads validation leave published sources unchanged",catalog_hash,JSON.stringify(registry.active()).sha256_text())
	controller.open_setup()
	controller.continue_to_menu()
	check("title return retains run long lock",catalog_hash,JSON.stringify(registry.active()).sha256_text())
	if DisplayServer.get_name() != "headless":
		shell.render()
		await capture(shell,"faction-quest-main-menu")
		check("rendered actual menu reachable",true,find_button(shell.panel,"New Game") != null and controller.menu_entered)
	return terminal(fixture)

func terminal(fixture: Dictionary) -> Dictionary:
	var ok := true
	for item: Dictionary in checks: ok = ok and Inputs.Common.equal_input(item.expected,item.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs,"source":fixture.classic_source,"downstream":"DATA source-only. FACT/QUEST/SAVE/CORE-012 real gates remain open."}
