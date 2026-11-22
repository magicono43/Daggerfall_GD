extends "res://tests/text_cases.gd"
const Layout = preload("res://scripts/data/layout_inputs.gd")
const LF = preload("res://scripts/data/layout_formats.gd")
var resource_calls := 0
var retiring_source: RefCounted

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})
	if checks.size()%20 == 0: print("Layout assertion ",checks.size(),": ",id)

func envelope(operation: String, entries: Array, path := "packs/test.pack") -> Dictionary:
	return {"domain":Layout.DOMAIN,"path":path,"operation":operation,"entries":entries}

func checked_resources(_record: Dictionary) -> Dictionary:
	return {"ok":true,"qualification":"controlled interface only"}

func unavailable_resources(_record: Dictionary) -> Dictionary:
	return {"ok":false,"kind":"provider_unavailable","reason":"Controlled missing resource."}

func later_failure(record: Dictionary) -> Dictionary:
	resource_calls += 1
	return unavailable_resources(record) if resource_calls == 3 else checked_resources(record)

func later_source_failure(record: Dictionary) -> Dictionary:
	resource_calls += 1
	if resource_calls == 2: retiring_source.dispose()
	return checked_resources(record)

func animated_texture() -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(106)
	bytes.encode_s16(0,1)
	bytes.encode_s32(28,46)
	bytes.encode_s16(50,3)
	bytes.encode_s16(52,2)
	bytes.encode_u16(54,0x900)
	bytes.encode_u32(56,60)
	bytes.encode_u32(60,28)
	bytes.encode_u16(66,2)
	bytes.encode_s32(74,8)
	bytes.encode_s32(78,21)
	var frames := PackedByteArray([3,0,2,0,0,3,1,2,3,1,2,4,5,3,0,2,0,3,0,0,3,6,7,8])
	for i in frames.size(): bytes[82+i] = frames[i]
	return bytes

func texture_negatives() -> void:
	var decoder := preload("res://scripts/data/classic_image.gd").new()
	var bytes := animated_texture()
	for compression in [0,0x900]:
		bytes.encode_u16(54,compression)
		check("transparent-run profile %d first pixels" % compression,[1,2,3,0,4,5],Array(decoder.decode(bytes,"TEXTURE.999",0,0).indices))
		check("transparent-run profile %d last pixels" % compression,[0,0,0,6,7,8],Array(decoder.decode(bytes,"TEXTURE.999",0,1).indices))
	var bad := bytes.duplicate()
	bad.encode_s32(74,21)
	bad.encode_s32(78,8)
	check("frame offset reorder follows explicit frame address",[0,0,0,6,7,8],Array(decoder.decode(bad,"TEXTURE.999",0,0).indices))
	bad = bytes.duplicate()
	bad.encode_s32(78,8)
	var shared_first := decoder.decode(bad,"TEXTURE.999",0,0)
	var shared_second := decoder.decode(bad,"TEXTURE.999",0,1)
	shared_first.indices[0] = 255
	check("shared frame addresses have detached outputs",1,shared_second.indices[0])
	check("shared frame unused bytes explicitly retained",22,shared_second.unused_frame_tail.length())
	var vectors: Array = []
	bad = bytes.duplicate(); bad.encode_s32(74,-1); vectors.append(["negative frame offset",bad])
	bad = bytes.duplicate(); bad.encode_s32(74,0); vectors.append(["zero is not an absent frame address",bad])
	bad = bytes.duplicate(); bad.encode_s32(78,10000); vectors.append(["overflow frame offset",bad])
	bad = bytes.duplicate(); bad.encode_u16(66,65535); vectors.append(["frame table count exceeds extent",bad])
	bad = bytes.duplicate(); bad.encode_s16(82,4); vectors.append(["unsupported frame dimensions",bad])
	bad = bytes.duplicate(); bad[86] = 4; bad[87] = 0; vectors.append(["transparent run exceeds row",bad])
	bad = bytes.duplicate(); bad[86] = 0; bad[87] = 0; vectors.append(["zero progress run",bad])
	bad = bytes.slice(0,105); vectors.append(["truncated declared record",bad])
	bad = bytes.duplicate(); bad.encode_u16(54,0x7fff); vectors.append(["unknown required compression",bad])
	bad = bytes.duplicate(); bad.encode_u16(66,0); vectors.append(["zero frames has no fabricated image",bad])
	for vector: Array in vectors:
		var rejected := decoder.decode(vector[1],"TEXTURE.999",0,0)
		check("animated texture rejects "+vector[0],false,rejected.ok)
		check("animated texture no partial pixels "+vector[0],false,rejected.has("indices"))
	check("animated texture absent frame","record_not_found",decoder.decode(bytes,"TEXTURE.999",0,2).kind)
	bad = bytes.slice(0,105)
	bad.encode_u32(56,59)
	check("earlier frame succeeds before later failure",true,decoder.decode(bad,"TEXTURE.999",0,0).ok)
	check("later required frame fails",false,decoder.decode(bad,"TEXTURE.999",0,1).ok)
	check("later required frame no partial image",false,decoder.decode(bad,"TEXTURE.999",0,1).has("indices"))
	bad = bytes.duplicate()
	bad.encode_s16(68,123)
	check("unused animated metadata preserved",123,decoder.decode(bad,"TEXTURE.999",0,0).unknown)

func schema_negatives(adapter: RefCounted, block: Dictionary, layout: Dictionary) -> void:
	check("complete authored block schema","",adapter.validate_record("block",block))
	var reordered := block.duplicate(true)
	reordered.data.records.reverse()
	check("record reorder preserves explicit references","",adapter.validate_record("block",reordered))
	var vectors: Array = []
	var bad := block.duplicate(true); bad.data.records[1].id = "quest-marker"; vectors.append(["duplicate record identity",bad])
	bad = block.duplicate(true); bad.data.records[1].action.target = "absent"; vectors.append(["missing action target",bad])
	bad = block.duplicate(true); bad.data.records[1].action.kind = 27; vectors.append(["unsupported required action",bad])
	bad = block.duplicate(true); bad.data.records[1].action.erase("axis"); vectors.append(["missing action parameter",bad])
	bad = block.duplicate(true); bad.data.records[1].action["execute_now"] = true; vectors.append(["unknown required action parameter",bad])
	bad = block.duplicate(true); bad.data.records[0].resource["fallback"] = true; vectors.append(["unknown resource fallback",bad])
	bad = block.duplicate(true); bad.data.records[0].texture = {"archive":199,"record":11}; vectors.append(["ambiguous resource providers",bad])
	bad = block.duplicate(true); bad.data.records[0].marker_purpose = "new-character-start"; vectors.append(["unapproved opening purpose",bad])
	bad = block.duplicate(true); bad.data.records[0].transform.position[1] = 1.25; vectors.append(["fractional source pose",bad])
	bad = block.duplicate(true); bad.data.records[0].transform.scale = [2,2,2]; vectors.append(["unsupported source scaling",bad])
	bad = block.duplicate(true); bad.data.structure.roots[0].append("absent"); vectors.append(["missing root record",bad])
	bad = block.duplicate(true); bad.data.structure.roots[0].append("quest-marker"); vectors.append(["multiply scoped record",bad])
	bad = block.duplicate(true); bad.data.structure.width = 4294967295; vectors.append(["root dimensions overflow",bad])
	bad = block.duplicate(true); bad.data.structure.erase("model_references"); vectors.append(["incomplete structural replacement",bad])
	bad = block.duplicate(true); bad.compatibility.remap = {"old":"absent"}; vectors.append(["missing compatibility target",bad])
	bad = block.duplicate(true); bad.compatibility.remap = {"old-a":"quest-marker","old-b":"quest-marker"}; vectors.append(["ambiguous compatibility mapping",bad])
	for vector: Array in vectors: check("authored schema rejects "+vector[0],true,not adapter.validate_record("block",vector[1]).is_empty())
	var preserved := Layout.check_record_mapping(["old"],["new"],{"old":"new"},["old"])
	check("explicit record mapping validates",true,preserved.ok)
	check("record mapping does not claim SAVE",false,preserved.save_compatible)
	check("missing required mapping rejects",false,Layout.check_record_mapping(["old"],["new"],{},["old"]).ok)
	check("unknown previous record mapping rejects",false,Layout.check_record_mapping(["old"],["new"],{"other":"new"},[]).ok)
	check("ambiguous mapping rejects",false,Layout.check_record_mapping(["a","b"],["new"],{"a":"new","b":"new"},["a","b"]).ok)
	check("duplicate old inventory rejects",false,Layout.check_record_mapping(["old","old"],["new"],{"old":"new"},[]).ok)
	check("duplicate current inventory rejects",false,Layout.check_record_mapping(["old"],["new","new"],{"old":"new"},[]).ok)
	var placement_bad := layout.duplicate(true)
	placement_bad.compatibility.remap = {"old":"missing-placement"}
	check("missing placement mapping rejects",true,not adapter.validate_record("layout",placement_bad).is_empty())

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var mods: RefCounted = controller.mods
	var adapter: RefCounted = controller.providers.layouts
	controller.settings.apply({"startup/show_setup":true})
	controller.settings.effective["startup/show_setup"] = true
	check("layout unavailable before publication","before_readiness",Layout.lookup(registry,"packs/classic#block-0000").kind)
	var placement := {"id":"first","context":"exterior","block":"packs/classic#block-0000","transform":LF.transform([0,0,0],[0,0,0])}
	var second := placement.duplicate(true)
	second.id = "second"
	second.transform.position = [100,0,0]
	var layout := Layout.value("layout",{"mode":"authored","location":"packs/classic#place-00000","placements":[placement,second]})
	var content := envelope("add",[{"id":"repeated","value":layout}])
	var custom_record := {"id":"quest-marker","type":"flat","transform":LF.transform([10,20,30],[0,0,0]),"flags":0,"marker_purpose":"quest","resource":{"provider":"test.pack","key":"marker","type":"image"},"magnitude":0,"sound_index":0,"action":{"kind":30,"target":"action-door"}}
	# Authored door tags are explicit fixture data, never inferred from appearance.
	var custom_door := {"id":"action-door","type":"model","model_id":44005,"description":"DOR","transform":LF.transform([40,50,60],[0,512,0]),"trigger_starting_lock":0,"sound_index":0,"action":{"kind":30,"target":"quest-marker","axis":0,"duration":0,"magnitude":0}}
	var custom_block := Layout.value("block",{"mode":"authored","format":"RDB","records":[custom_record,custom_door],"structure":{"width":1,"height":1,"model_references":[],"roots":[["quest-marker","action-door"]]}})
	var custom_placement := {"id":"marker-room","context":"dungeon","block":"packs/test.pack#custom-block","transform":LF.transform([0,0,0],[0,0,0])}
	var custom_second := custom_placement.duplicate(true)
	custom_second.id = "other-room"
	custom_second.transform.position = [256,0,0]
	var custom_layout := Layout.value("layout",{"mode":"authored","location":"packs/classic#place-00000","placements":[custom_placement,custom_second]})
	content.entries.append({"id":"custom-block","value":custom_block})
	content.entries.append({"id":"custom-resources","value":custom_layout})
	schema_negatives(adapter,custom_block,custom_layout)
	texture_negatives()
	var pack := manifest("test.pack")
	pack.content = ["layout.json","media.json"]
	write(mods.root.path_join("Mods/layout/mod.json"),JSON.stringify(pack))
	write(mods.root.path_join("Mods/layout/layout.json"),JSON.stringify(content))
	var image := Image.create(2,2,false,Image.FORMAT_RGBA8)
	image.fill(Color(1,0,0,1))
	image.set_pixel(1,1,Color(0,0,1,1))
	check("authored resource fixture writes",OK,image.save_png(mods.root.path_join("Mods/layout/marker.png")))
	write(mods.root.path_join("Mods/layout/media.json"),JSON.stringify({"domain":"media.assets","path":"exports","operation":"add","entries":[{"id":"marker","value":{"schema":"media-declarations-v1","kind":"export","type":"image","file":"marker.png","profile":"png-v1"}}]}))
	# Loose bytes are captured at initial intake. The complete layout field keeps
	# placement IDs while changing authored order, independent of source ordinals.
	var reordered := layout.duplicate(true)
	reordered.data.placements.reverse()
	write(mods.root.path_join("Overrides/layout.json"),JSON.stringify(envelope("patch",[{"id":"repeated","value":{"data":reordered.data}}])))
	mods.rescan()
	mods.edit("test.pack","toggle")
	var selected: Dictionary = controller.select_folder(fixture.classic_source)
	var candidate: Dictionary = registry.projection()
	check("actual geography and layout candidate",true,candidate.get("ok",false))
	if not candidate.get("ok",false):
		check("layout diagnoses","none",JSON.stringify(candidate.get("issues",selected)))
		return terminal(fixture)
	check("baseline layout inventory",16546,candidate.resources[Layout.DOMAIN+":packs/classic"].records.size())
	check("layout shipped PCK profile hash",Layout.PROFILE_HASH,FileAccess.get_sha256(Layout.ROOT+"profile.json"))
	check("layout license included","6e5e22fa760938ab398743150787896bd20fcf4936aad0122704700bad1e669a",FileAccess.get_sha256(Layout.ROOT+"DFU_LICENSE.txt"))
	mods.rescan()
	check("folder selected",true,mods.rescan().ok)
	candidate = registry.prepare(mods)
	check("real folder authored layout",true,candidate.ok)
	if not candidate.ok:
		print("Layout candidate issues: ",candidate.get("issues"))
		return terminal(fixture)
	var key := Layout.DOMAIN+":packs/test.pack"
	var retained: Dictionary = candidate.resources[key].records.repeated
	check("actual loose highest precedence","@loose",retained.winner.provider)
	check("placement reorder retains explicit IDs","second",retained.value.data.placements[0].id)
	var zip_pack := manifest("other.pack")
	zip_pack.content = ["patch.json"]
	var replacement: Array = content.entries.duplicate(true)
	replacement.reverse()
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_pack),"patch.json":JSON.stringify(envelope("replace",replacement))})
	mods.rescan()
	mods.edit("other.pack","toggle")
	candidate = registry.prepare(mods)
	check("actual ZIP and loose preparation",true,candidate.ok)
	check("ZIP tracks contributor",true,candidate.resources[key].records.repeated.contributors.any(func(c: Dictionary): return c.provider == "other.pack"))
	check("replacement keeps original package","test.pack",candidate.resources[key].records.repeated.identity.package)
	check("loose wins over ZIP","@loose",candidate.resources[key].records.repeated.winner.provider)
	write(mods.root.path_join("Mods/layout/layout.json"),JSON.stringify(envelope("add",content.entries+[{"id":"bad","value":{"schema":"future"}}])))
	mods.rescan()
	candidate = registry.prepare(mods)
	check("late invalid contribution rejects",false,candidate.ok)
	check("whole invalid contribution absent",false,candidate.resources.has(key))
	var omissions: Array = candidate.issues.filter(func(issue: Dictionary): return issue.omittable and issue.source.contains("layout.json"))
	check("invalid layout contribution identified",true,omissions.size() > 0)
	if omissions.is_empty(): return terminal(fixture)
	check("explicit current omission",true,registry.omit(omissions[0].token,candidate.ticket,mods).ok)
	candidate = registry.prepare(mods)
	check("remaining ZIP and loose references cannot bypass omission",false,candidate.ok)
	write(mods.root.path_join("Mods/layout/layout.json"),JSON.stringify(content))
	mods.rescan()
	candidate = registry.prepare(mods)
	check("repair retries complete candidate",true,candidate.ok)
	var invalid_blocks: Array = replacement.duplicate(true)
	for entry: Dictionary in invalid_blocks:
		if entry.id == "custom-resources": entry.value.data.placements[0].block = "packs/test.pack#absent-block"
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_pack),"patch.json":JSON.stringify(envelope("replace",invalid_blocks))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("required missing block rejects final candidate",false,candidate.ok)
	check("required missing block exact diagnostic",true,candidate.issues.any(func(issue: Dictionary): return issue.get("target") == "packs/test.pack#absent-block" and issue.get("record") == "marker-room" and issue.get("provider",{}).get("provider") == "other.pack"))
	var invalid_media: Array = replacement.duplicate(true)
	for entry: Dictionary in invalid_media:
		if entry.id == "custom-block": entry.value.data.records[0].resource.key = "absent-export"
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_pack),"patch.json":JSON.stringify(envelope("replace",invalid_media))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("required missing media export rejects final candidate",false,candidate.ok)
	check("required missing media export exact diagnostic",true,candidate.issues.any(func(issue: Dictionary): return issue.get("target") is Dictionary and issue.target.get("key") == "absent-export" and issue.get("record") == "quest-marker"))
	archive(mods.root.path_join("Mods/other.zip"),{"mod.json":JSON.stringify(zip_pack),"patch.json":JSON.stringify(envelope("replace",replacement))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("required block and media repairs rebuild indexes",true,candidate.ok)
	write(mods.root.path_join("Overrides/layout.json"),"External edit requires restart")
	check("loose changes require restart",true,registry.prepare(mods).ok)
	var pure_base := {key:candidate.resources[key].duplicate(true)}
	var pure_source := {"provider":"review.pack","root":sandbox,"file":"review.json","version":"1.0.0"}
	var base_hash := JSON.stringify(pure_base).sha256_text()
	var incomplete: Dictionary = registry.apply_contribution(pure_base,JSON.stringify(envelope("replace",replacement.slice(0,2))).to_utf8_buffer(),pure_source)
	check("whole-namespace replace cannot implicitly delete IDs",false,incomplete.ok)
	check("rejected replacement leaves input intact",base_hash,JSON.stringify(pure_base).sha256_text())
	var replaced: Dictionary = registry.apply_contribution(pure_base,JSON.stringify(envelope("replace",replacement)).to_utf8_buffer(),pure_source)
	check("complete explicit namespace replacement validates",true,replaced.ok)
	check("explicit replacement retains origin",pure_base[key].records.repeated.identity,replaced.resources[key].records.repeated.identity)
	check("explicit replacement tracks winner","review.pack",replaced.resources[key].records.repeated.winner.provider)
	replaced.resources[key].records["custom-block"].value.data.records[0].transform.position[0] = 999
	check("public replacement projections detach",base_hash,JSON.stringify(pure_base).sha256_text())
	var stale: int = candidate.ticket
	registry.prepare(mods)
	check("layout stale candidate rejected","stale",registry.reserve_commit(stale,mods).kind)
	controller.providers.faults.menu = true
	check("layout interrupted menu rejects",false,controller.continue_to_menu("run").ok)
	check("layout interrupted no publication",{},registry.active())
	controller.providers.faults.clear()
	controller.check_content()
	check("layout actual CORE publication","main_menu",controller.continue_to_menu("save").route)
	var block: Dictionary = adapter.decode_block(registry,"packs/classic#block-0000")
	check("actual RMB definition decoded",true,block.ok)
	if not block.ok: return terminal(fixture)
	check("RMB type","RMB",block.definition.format)
	check("RMB ground tiles retained",256,block.definition.ground.tiles.size())
	check("RMB automap retained",4096,block.definition.automap.size())
	check("RMB interior retained",true,block.definition.subrecords.size() > 0)
	var observed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/layout_source_observation.json"))
	check("independent RMB source",observed.rmb_pin.name,block.definition.source)
	check("independent RMB building count",observed.rmb_pin.buildings,block.definition.subrecords.size())
	var index: Dictionary = registry.domain_index(Layout.DOMAIN)
	var interior: Dictionary = adapter.decode_block(registry,index.names[observed.interior_pin.name])
	check("actual building interior decodes",true,interior.ok)
	check("independent interior counts",observed.interior_pin.counts,interior.definition.subrecords[0].interior.counts)
	var interior_model: Dictionary = interior.definition.subrecords[0].interior.records[0]
	check("independent interior model identity",observed.interior_pin.first_model_id,interior_model.model_id)
	check("independent interior source position",observed.interior_pin.first_model_position,interior_model.transform.position)
	check("independent interior source rotation",observed.interior_pin.first_model_y_rotation,interior_model.transform.rotation[1])
	var actual_location: Dictionary = adapter.location_inputs(registry,"packs/classic#place-00000")
	check("actual containing location inputs",true,actual_location.ok)
	check("independent location building count",observed.locations[0].building_count,actual_location.data.exterior.buildings.size())
	check("independent location doors",observed.locations[0].door_count,actual_location.data.exterior.header.doors.size())
	check("independent containing placement codes",observed.locations[0].first_block_codes,actual_location.data.placements[0].source_codes)
	var first_id: String = block.definition.records[0].id
	var before: Dictionary = block.definition.records[0].duplicate(true)
	block.definition.records[0].transform.position[0] = 2147483647
	check("block definitions detached",before,adapter.decode_block(registry,"packs/classic#block-0000").definition.records[0])
	var repeated: Dictionary = adapter.prepare_location(registry,"packs/test.pack#repeated",checked_resources)
	check("controlled resource preparation",true,repeated.ok)
	if not repeated.ok:
		check("controlled preparation diagnostics","none",repeated)
		return terminal(fixture)
	check("two placements",2,repeated.occurrences.size())
	check("shared immutable definition",repeated.occurrences[0].definition,repeated.occurrences[1].definition)
	check("different occurrence identities",false,repeated.occurrences[0].identity == repeated.occurrences[1].identity)
	check("different record identities",false,repeated.occurrences[0].records[0].identity == repeated.occurrences[1].records[0].identity)
	check("same stable record key",first_id,repeated.occurrences[1].records[0].identity.record)
	check("source building has explicit stable key","building-0000",block.definition.subrecords[0].id)
	check("two building occurrences differ",false,repeated.occurrences[0].buildings[0].identity == repeated.occurrences[1].buildings[0].identity)
	check("source interior context retained",true,repeated.occurrences[0].records.any(func(r: Dictionary): return r.context == "interior" and r.placement_context == "exterior"))
	var source_base := {Layout.DOMAIN+":packs/classic":{"domain":Layout.DOMAIN,"path":"packs/classic","records":{"block-0000":Layout.lookup(registry,"packs/classic#block-0000").record},"contributors":[],"winner":{}}}
	var bad_source_mapping := {"domain":Layout.DOMAIN,"path":"packs/classic","operation":"patch","entries":[{"id":"block-0000","value":{"compatibility":{"status":"unverified","remap":{"old":"absent-record"}}}}]}
	check("source mapping missing target rejects",false,registry.apply_contribution(source_base,JSON.stringify(bad_source_mapping).to_utf8_buffer(),pure_source).ok)
	bad_source_mapping.entries[0].value.compatibility.remap = {"old-building":"building-0000"}
	check("source building mapping validates structurally",true,registry.apply_contribution(source_base,JSON.stringify(bad_source_mapping).to_utf8_buffer(),pure_source).ok)
	check("source parent transform handoff retained",3,repeated.occurrences[0].records[0].coordinate_handoff.parents.size())
	check("parent composition not declared ready","provider_unavailable",repeated.occurrences[0].records[0].coordinate_handoff.composition_status)
	repeated.occurrences[0].records[0].record.transform.position[0] = 100000
	check("second occurrence detached",before.transform.position,repeated.occurrences[1].records[0].record.transform.position)
	check("shared block remains unchanged",before,adapter.decode_block(registry,"packs/classic#block-0000").definition.records[0])
	check("no live location readiness",false,repeated.location_ready)
	check("no physics readiness",false,repeated.physics_ready)
	check("no saved compatibility",false,repeated.save_compatible)
	var real_resources: Dictionary = adapter.prepare_location(registry,"packs/test.pack#repeated",adapter.classic_resource)
	check("actual classic model and animated-flat resources",true,real_resources.ok)
	if not real_resources.ok: print("Actual layout resource failure: ",real_resources)
	check("actual resources do not establish geometry",false,real_resources.get("location_ready",false))
	var door_request := {"id":"source-door-zero-probe","type":"door","door_model_index":0,"content_context":real_resources.content_context.duplicate(true)}
	var door_resource: Dictionary = adapter.classic_resource(door_request)
	check("RMB zero door style is a real resource",true,door_resource.ok)
	check("RMB door style maps numeric model ID",9000,door_resource.value.projection().provenance.classic_id if door_resource.ok else door_resource.get("reason","unavailable"))
	door_request.door_model_index = 5
	check("RMB invalid door style has no modulo fallback","unsupported",adapter.classic_resource(door_request).kind)
	var custom: Dictionary = adapter.prepare_location(registry,"packs/test.pack#custom-resources",adapter.classic_resource,[{"placement":"marker-room","record":"quest-marker","type":"flat","purpose":"quest","context":"dungeon"},{"placement":"marker-room","record":"action-door","type":"door","purpose":"","context":"dungeon"}])
	check("actual media export resource binding",true,custom.ok)
	check("authored resources need no numeric range","quest-marker",custom.occurrences[0].records[0].identity.record)
	check("actual media still does not qualify geometry",false,custom.location_ready)
	check("two door occurrences differ",false,custom.occurrences[0].records[1].identity == custom.occurrences[1].records[1].identity)
	check("two action targets are occurrence scoped",false,custom.occurrences[0].records[0].action_target == custom.occurrences[1].records[0].action_target)
	check("authored cycle retained","quest-marker",custom.occurrences[0].records[1].action_target.record)
	var wrong_context: Dictionary = adapter.prepare_location(registry,"packs/test.pack#custom-resources",adapter.classic_resource,[{"placement":"marker-room","record":"quest-marker","type":"flat","purpose":"quest","context":"interior"}])
	check("marker wrong placement context rejects",false,wrong_context.ok)
	var absent_door: Dictionary = adapter.prepare_location(registry,"packs/test.pack#custom-resources",adapter.classic_resource,[{"placement":"marker-room","record":"absent-door","type":"door","purpose":""}])
	check("required missing door never substitutes another",false,absent_door.ok)
	check("required missing door diagnostic",{"placement":"marker-room","record":"absent-door","type":"door","purpose":""},absent_door.target)
	var absent_marker: Dictionary = adapter.prepare_location(registry,"packs/test.pack#custom-resources",adapter.classic_resource,[{"placement":"marker-room","record":"absent-marker","type":"flat","purpose":"quest"}])
	check("required missing marker never chooses first",false,absent_marker.ok)
	var media_request: Dictionary = custom_record.duplicate(true)
	media_request.content_context = custom.content_context.duplicate(true)
	check("current media generation binds",true,adapter.classic_resource(media_request).ok)
	var exported: Dictionary = adapter.classic_resource(media_request)
	check("actual media export pixels",[255,0,0,255],Array(exported.resource.rgba.slice(0,4)))
	check("actual media export opposite corner",[0,0,255,255],Array(exported.resource.rgba.slice(12,16)))
	media_request.content_context.ticket -= 1
	check("obsolete media context rejects","stale",adapter.classic_resource(media_request).kind)
	check("animated texture full record inventory",30,observed.texture210.record_count)
	check("animated texture full frame inventory",83,observed.texture210.frame_count)
	for texture: Dictionary in observed.texture210.records:
		var first: Dictionary = controller.providers.classic.read_record("TEXTURE.210",{"record":int(texture.record),"frame":0})
		check("texture210 record %d metadata" % int(texture.record),[texture.width,texture.height,texture.frames,texture.compression],[first.value.projection().width,first.value.projection().height,first.value.projection().frame_count,first.value.projection().compression])
		for pin: Dictionary in texture.pins:
			var decoded: Dictionary = controller.providers.classic.read_record("TEXTURE.210",{"record":int(texture.record),"frame":int(pin.frame)})
			var pixels: Dictionary = decoded.value.projection()
			check("texture210 record %d frame %d independent pixels" % [int(texture.record),int(pin.frame)],pin.sha256,Layout.Common.sha256(pixels.indices))
			if pin.extent != null: check("texture210 record %d frame %d encoded extent" % [int(texture.record),int(pin.frame)],pin.extent,pixels.frame_source_extent)
	var missing: Dictionary = adapter.prepare_location(registry,"packs/test.pack#repeated",unavailable_resources)
	check("missing resources fail",false,missing.ok)
	check("failed preparation no partial occurrences",false,missing.has("occurrences"))
	check("failure referring context",true,missing.has("placement") and missing.has("referring"))
	resource_calls = 0
	var later: Dictionary = adapter.prepare_location(registry,"packs/test.pack#repeated",later_failure)
	check("later resource failure after earlier successes",3,resource_calls)
	check("later failure rejects whole preparation",false,later.ok)
	check("later failure retains no holes",false,later.has("occurrences"))
	var wrong: Dictionary = adapter.prepare_location(registry,"packs/test.pack#repeated",checked_resources,[{"placement":"first","record":first_id,"type":"model","purpose":"dungeon-start","referring":"opening-probe"}])
	check("wrong purpose marker rejects",false,wrong.ok)
	check("wrong marker retains requesting context","opening-probe",wrong.record)
	check("engine conversion unavailable","unsupported_conversion",Layout.convert({"source_frame":"classic-block-local-v1","target_frame":"godot-motor","transform":LF.transform([1,2,3],[0,512,0])}).kind)
	check("source identity roundtrip",LF.transform([1,2,3],[0,512,0]),Layout.convert({"source_frame":"classic-block-local-v1","target_frame":"classic-block-local-v1","transform":LF.transform([1,2,3],[0,512,0])}).transform)
	var raw: Dictionary = controller.providers.classic.read_record("BLOCKS.BSA","B0000000.RDB")
	var rdb := LF.decode(raw.bytes,raw.identity)
	check("actual dungeon definition",true,rdb.ok)
	check("dungeon typed records present",true,rdb.records.size() > 0)
	check("independent RDB roots",observed.rdb_pin.roots,rdb.roots)
	check("independent RDB record count",observed.rdb_pin.objects.size(),rdb.records.size())
	check("independent RDB first position",observed.rdb_pin.objects[0].position,rdb.records[0].transform.position)
	var flats: Array = rdb.records.filter(func(r: Dictionary): return r.type == "flat")
	var cycle_bytes: PackedByteArray = raw.bytes.duplicate()
	var a: Dictionary = flats[0]
	cycle_bytes.encode_s32(a.resource_offset+6,a.address)
	cycle_bytes[a.resource_offset+10] = 30
	var cycle := LF.decode(cycle_bytes,raw.identity)
	check("intentional action cycle preserved",true,cycle.ok)
	check("self target remains source address",a.address,cycle.records.filter(func(r: Dictionary): return r.address == a.address)[0].action.target_address)
	cycle_bytes.encode_s32(a.resource_offset+6,2147483647)
	check("broken required action target rejects",false,LF.decode(cycle_bytes,raw.identity).ok)
	cycle_bytes.encode_s32(a.resource_offset+6,-1)
	check("negative action target is absent",true,LF.decode(cycle_bytes,raw.identity).ok)
	cycle_bytes.encode_s32(a.resource_offset+6,0)
	cycle_bytes[a.resource_offset+10] = 14
	check("teleport requires real destination",false,LF.decode(cycle_bytes,raw.identity).ok)
	cycle_bytes[a.resource_offset+10] = 27
	check("unsupported required action rejects",false,LF.decode(cycle_bytes,raw.identity).ok)
	cycle_bytes[a.resource_offset+10] = 0
	cycle_bytes.encode_s32(a.resource_offset+6,2147483647)
	var unused_link := LF.decode(cycle_bytes,raw.identity)
	check("unused no-action target does not reject block",true,unused_link.ok)
	check("unused no-action target retained",2147483647,unused_link.records.filter(func(r: Dictionary): return r.address == a.address)[0].action.target_address)
	var bad_root: PackedByteArray = raw.bytes.duplicate()
	bad_root.encode_s32(LF.RDB_ROOTS,0)
	check("root zero is not absent",false,LF.decode(bad_root,raw.identity).ok)
	check("required RDI rejects","unsupported",LF.decode(PackedByteArray(),"required.RDI").kind)
	var invalid := layout.duplicate(true)
	invalid.data.placements[1].id = "first"
	check("duplicate placement ID rejects",true,not adapter.validate_record("invalid",invalid).is_empty())
	invalid = layout.duplicate(true)
	invalid.data.placements[0].transform.position[0] = 1.5
	check("fractional source transform rejects",true,not adapter.validate_record("invalid",invalid).is_empty())
	check("locked candidate preserves content","locked",registry.prepare(mods).kind)
	check("late adapter registration rejects",false,controller.providers.enable_layout_inputs().ok)
	# Edits after locking are adopted only by a genuinely fresh application.
	reordered.data.placements[0].transform.position[0] = 512
	write(mods.root.path_join("Overrides/layout.json"),JSON.stringify(envelope("patch",[{"id":"repeated","value":{"data":reordered.data}}])))
	image.set_pixel(1,1,Color(0,1,0,1))
	image.save_png(mods.root.path_join("Mods/layout/marker.png"))
	media_request.content_context = custom.content_context.duplicate(true)
	check("locked media bytes retained until restart",[0,0,255,255],Array(adapter.classic_resource(media_request).resource.rgba.slice(12,16)))
	check("locked layout retained until restart",100,Layout.lookup(registry,"packs/test.pack#repeated").record.value.data.placements[0].transform.position[0])
	write(sandbox.path_join("layout-restart-receipt.json"),JSON.stringify({"old_media_sha256":exported.provenance.sha256,"profile":Layout.PROFILE_HASH}))
	if DisplayServer.get_name() != "headless":
		shell.render()
		var inspector := Label.new()
		inspector.text = "Structural DATA inspection only — no live location or physics\nRMB: %s; interior model %s at %s\nPlacements: first / second — separate record identities\nQuest/action-door cycle: marker-room and other-room\nTEXTURE.210: 30 records / 83 independently checked frames\nResource, door and marker failures retain no partial location" % [observed.interior_pin.name,str(interior_model.model_id),str(interior_model.transform.position)]
		inspector.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		shell.panel.add_child(inspector)
		var previews := HBoxContainer.new()
		var colors := PackedByteArray()
		colors.resize(768)
		for i in 256:
			for channel in 3: colors[i*3+channel] = i
		# Diagnostic index grayscale and explicit zero alpha, not original colors
		# or an animation scheduler. Both frames use the real source-reader API.
		for frame in [0,3]:
			var raw_image: Dictionary = controller.providers.classic.read_record("TEXTURE.210",{"record":0,"frame":frame}).value.projection()
			raw_image.ok = true
			var rgba := preload("res://scripts/data/classic_image.gd").new().rgba(raw_image,{"ok":true,"rgb":colors},0)
			var rect := TextureRect.new()
			rect.texture = ImageTexture.create_from_image(Image.create_from_data(rgba.width,rgba.height,false,Image.FORMAT_RGBA8,rgba.rgba))
			rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			rect.custom_minimum_size = Vector2(80,104)
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			previews.add_child(rect)
		shell.panel.add_child(previews)
		await capture(shell,"layout-structural-menu")
		var viewport_height: float = shell.get_viewport_rect().size.y
		check("rendered structural inspector visible",true,inspector.is_visible_in_tree() and inspector.get_global_rect().position.y >= 0 and inspector.get_global_rect().end.y <= viewport_height)
		check("rendered texture frame probes",true,previews.get_child_count() == 2 and previews.get_global_rect().position.y >= 0 and previews.get_global_rect().end.y <= viewport_height)
	retiring_source = controller.providers.classic
	resource_calls = 0
	var lost_block: Dictionary = adapter.prepare_location(registry,"packs/test.pack#repeated",later_source_failure)
	check("earlier block resource requests succeeded",true,resource_calls > 2)
	check("later required block read fails",false,lost_block.ok)
	check("later required block no partial location",false,lost_block.has("occurrences"))
	check("later block exact failed placement","first",lost_block.placement)
	check("later block retains definition provider",true,lost_block.has("provider") and lost_block.has("definition") and lost_block.has("input"))
	check("retired source cannot reuse decoded blocks",false,adapter.decode_block(registry,"packs/classic#block-0000").ok)
	return terminal(fixture)

func terminal(fixture: Dictionary) -> Dictionary:
	var ok := true
	for item: Dictionary in checks: ok = ok and Layout.Common.equal_input(item.expected,item.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs,"source":fixture.classic_source,"downstream":"Structural probe only; LOC/WORLD/MOVE/action/QUEST/SAVE/CORE-opening and M1 unavailable."}
