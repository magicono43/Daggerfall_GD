extends "res://tests/layout_cases.gd"
const V = preload("res://scripts/data/variant_inputs.gd")
const R = preload("res://scripts/data/variant_resolution.gd")
var authored_variants: Array = []
var bad_resource_calls := 0
var retirement_query := {}

func check(id: String, expected: Variant, actual: Variant) -> void:
	# Assertions retain observations, even when a later probe intentionally mutates
	# a detached result to verify isolation.
	checks.append({"scenario":id,"expected":expected.duplicate(true) if expected is Dictionary or expected is Array else expected,"actual":actual.duplicate(true) if actual is Dictionary or actual is Array else actual})
	if checks.size()%20 == 0: print("Variant assertion ",checks.size(),": ",id)

func variant_content_files() -> Array:
	return ["variants.json","default.json"]

func variant_envelope(entries: Array, operation := "add", path := "packs/test.pack") -> Dictionary:
	return {"domain":V.DOMAIN,"path":path,"operation":operation,"entries":entries}

func declaration(target: Dictionary, alternate: String, mapping := {}) -> Dictionary:
	return {"schema":V.VERSION,"kind":"variant","target":target,"alternate":alternate,"mapping":mapping}

func extend_fixture_content(content: Dictionary, mods: RefCounted) -> void:
	var base: Dictionary = content.entries.filter(func(e: Dictionary): return e.id == "custom-block")[0].value
	var shifted := base.duplicate(true)
	shifted.data.records[0].transform.position = [110,220,330]
	var mapped := shifted.duplicate(true)
	mapped.data.records[0].id = "mapped-marker"
	mapped.data.records[1].action.target = "mapped-marker"
	mapped.data.structure.roots = [["mapped-marker","action-door"]]
	var removed := shifted.duplicate(true)
	removed.data.records.remove_at(0)
	removed.data.records[0].action.target = ""
	removed.data.structure.roots = [["action-door"]]
	content.entries.append_array([{"id":"shifted","value":shifted},{"id":"mapped","value":mapped},{"id":"removed","value":removed}])
	var wrong_purpose := shifted.duplicate(true)
	wrong_purpose.data.records[0].marker_purpose = "dungeon-start"
	content.entries.append({"id":"wrong-purpose","value":wrong_purpose})
	var wrong_type := shifted.duplicate(true)
	wrong_type.data.records[0] = shifted.data.records[1].duplicate(true)
	wrong_type.data.records[0].id = "quest-marker"
	wrong_type.data.records[0].action.target = "action-door"
	content.entries.append({"id":"wrong-type","value":wrong_type})
	var wrong_door := shifted.duplicate(true)
	wrong_door.data.records[1].description = ""
	content.entries.append({"id":"wrong-door","value":wrong_door})
	var root := {"scope":"location-layout","location":"packs/classic#place-00000","layout":"packs/test.pack#custom-resources"}
	var alt_layout: Dictionary = content.entries.filter(func(e: Dictionary): return e.id == "custom-resources")[0].value.duplicate(true)
	alt_layout.data.placements.reverse()
	alt_layout.data.placements[0].transform.position[0] = 1024
	content.entries.append({"id":"alternate-layout","value":alt_layout})
	var t := {"scope":"placement","location":root.location,"layout":root.layout,"block":"packs/test.pack#custom-block","placement":"marker-room"}
	authored_variants = [{"id":"shift","value":declaration(t,"packs/test.pack#shifted")},{"id":"map","value":declaration(t,"packs/test.pack#mapped",{"quest-marker":"mapped-marker"})},{"id":"remove","value":declaration(t,"packs/test.pack#removed")},{"id":"layout","value":declaration(root,"packs/test.pack#alternate-layout")}]
	var location_default := {"scope":"location-block","location":root.location,"layout":root.layout,"block":t.block}
	authored_variants.append({"id":"location-choice","value":{"schema":V.VERSION,"kind":"default","target":location_default,"choice":{"intent":"baseline"}}})
	# Building fixture: complete project-authored RMB, not classic payload or inferred
	# numeric identity. Its model is resolved by the accepted classic media reader.
	var model := {"id":"inside","type":"model","model_id":8007,"object_type":0,"transform":LF.transform([64,-63,-189],[0,0,0])}
	var metadata := {"name_seed":1,"service_time_limit":0,"unknown":[0,0,0,0],"faction_id":0,"sector":0,"location_id":0,"building_type":0,"quality":0}
	var building := {"id":"house","metadata":metadata,"transform":LF.transform([100,0,200],[0,512,0]),"exterior":[],"interior":["inside"]}
	var rmb := Layout.value("block",{"mode":"authored","format":"RMB","records":[model],"structure":{"ground":{"header":"00".repeat(8),"tiles":"00".repeat(256),"scenery":"00".repeat(256)},"automap":"00".repeat(4096),"misc":[],"buildings":[building]}})
	var other := rmb.duplicate(true)
	other.data.records[0].transform.position[0] = 65
	var building_layout := Layout.value("layout",{"mode":"authored","location":root.location,"placements":[{"id":"house-one","context":"interior","block":"packs/test.pack#house-block","transform":LF.transform([0,0,0],[0,0,0])},{"id":"house-two","context":"interior","block":"packs/test.pack#house-block","transform":LF.transform([256,0,0],[0,0,0])}]})
	content.entries.append_array([{"id":"house-block","value":rmb},{"id":"house-alternate","value":other},{"id":"houses","value":building_layout}])
	var bt := {"scope":"building","location":root.location,"layout":"packs/test.pack#houses","block":"packs/test.pack#house-block","placement":"house-one","building":"house"}
	authored_variants.append({"id":"house","value":declaration(bt,"packs/test.pack#house-alternate")})
	var outside := other.duplicate(true)
	outside.data.structure.ground.tiles = "01"+"00".repeat(255)
	content.entries.append({"id":"house-outside","value":outside})
	authored_variants.append({"id":"outside-house","value":declaration(bt,"packs/test.pack#house-outside")})
	var house_placement := bt.duplicate(true)
	house_placement.erase("building")
	house_placement.scope = "placement"
	authored_variants.append({"id":"house-containing","value":declaration(house_placement,"packs/test.pack#house-alternate")})
	authored_variants.append({"id":"wrong-map","value":declaration(t,"packs/test.pack#shifted",{"absent":"quest-marker"})})
	authored_variants.append({"id":"colliding-map","value":declaration(t,"packs/test.pack#shifted",{"quest-marker":"action-door"})})
	authored_variants.append({"id":"wrong-purpose","value":declaration(t,"packs/test.pack#wrong-purpose")})
	authored_variants.append({"id":"wrong-type","value":declaration(t,"packs/test.pack#wrong-type")})
	authored_variants.append({"id":"wrong-door","value":declaration(t,"packs/test.pack#wrong-door")})
	var global := {"scope":"global-block","block":"packs/test.pack#custom-block"}
	authored_variants.append({"id":"global-shift","value":declaration(global,"packs/test.pack#shifted")})
	# Ambiguous defaults are installed but apply to a distinct probe layout. DATA
	# never chooses an undocumented location-versus-global priority.
	var ambiguous_layout := alt_layout.duplicate(true)
	content.entries.append({"id":"ambiguous-layout","value":ambiguous_layout})
	var ambiguous_scope := {"scope":"location-block","location":root.location,"layout":"packs/test.pack#ambiguous-layout","block":t.block}
	authored_variants.append({"id":"ambiguous-location-default","value":{"schema":V.VERSION,"kind":"default","target":ambiguous_scope,"choice":{"intent":"baseline"}}})
	# A separate block identity isolates this ambiguity from the ordinary fixture.
	var ambiguous_block := shifted.duplicate(true)
	content.entries.append({"id":"ambiguous-block","value":ambiguous_block})
	ambiguous_layout.data.placements[0].block = "packs/test.pack#ambiguous-block"
	ambiguous_layout.data.placements[1].block = "packs/test.pack#ambiguous-block"
	ambiguous_scope.block = "packs/test.pack#ambiguous-block"
	authored_variants.append({"id":"ambiguous-global-default","value":{"schema":V.VERSION,"kind":"default","target":{"scope":"global-block","block":ambiguous_scope.block},"choice":{"intent":"baseline"}}})
	var shipped_patch := variant_envelope([{"id":"sample-block-baseline","value":{"choice":{"intent":"baseline"}}}],"patch","packs/project")
	# One folder file may contain one envelope; use a separate declared contribution.
	write(mods.root.path_join("Mods/layout/variants.json"),JSON.stringify(variant_envelope(authored_variants)))
	write(mods.root.path_join("Mods/layout/default.json"),JSON.stringify(shipped_patch))
	write(mods.root.path_join("Overrides/variant-default.json"),JSON.stringify(shipped_patch))

func archive(path: String, entries: Dictionary) -> void:
	var modified := entries.duplicate(true)
	if modified.has("mod.json"):
		var pack: Dictionary = JSON.parse_string(modified["mod.json"])
		if pack.id == "other.pack":
			pack.content.append("variants.json")
			pack.content.append("default.json")
			modified["mod.json"] = JSON.stringify(pack)
			modified["variants.json"] = JSON.stringify(variant_envelope([{"id":"shift","value":{"alternate":"packs/test.pack#shifted"}}],"patch"))
			modified["default.json"] = JSON.stringify(variant_envelope([{"id":"sample-block-baseline","value":{"schema":V.VERSION,"kind":"default","target":{"scope":"global-block","block":"packs/classic#block-0000"},"choice":{"intent":"baseline"}}}],"replace","packs/project"))
	super.archive(path,modified)

func identity(registry: RefCounted, id: String) -> Dictionary:
	return registry.query(V.DOMAIN,"packs/test.pack",id).record.identity

func query(registry: RefCounted, adapter: RefCounted, layout := "custom-resources") -> Dictionary:
	return {"schema":R.VERSION,"owner":"controlled LOC pre-reconstruction probe","content_context":adapter.context(registry).context,"layout":Layout.lookup(registry,"packs/test.pack#"+layout).record.identity,"layout_selection":{"intent":"baseline"},"selections":[],"required":[],"compatibility":[]}

func selected(registry: RefCounted, id: String, placement := "marker-room") -> Dictionary:
	var record: Dictionary = registry.query(V.DOMAIN,"packs/test.pack",id).record
	var target: Dictionary = record.value.target.duplicate(true)
	if target.has("placement"): target.placement = placement
	return {"target":target,"selection":{"intent":"variant","variant":record.identity}}

func late_resource_failure(_record: Dictionary) -> Dictionary:
	bad_resource_calls += 1
	return {"ok":bad_resource_calls < 3,"kind":"provider_unavailable","reason":"Controlled later resource failure."}

func validate_variant_candidate(shell: Control, _fixture: Dictionary) -> void:
	var mods: RefCounted = shell.controller.mods
	var registry: RefCounted = shell.controller.providers.definitions
	var adapter: RefCounted = shell.controller.providers.variants
	var path: String = mods.root.path_join("Mods/layout/variants.json")
	var valid := variant_envelope(authored_variants)
	var failures: Array = []
	var overwritten := valid.duplicate(true)
	overwritten.entries[0].value.alternate = "packs/absent.pack#block"
	write(path,JSON.stringify(overwritten))
	mods.rescan()
	check("variants exact final ZIP winner repairs earlier unresolved alternate",true,registry.prepare(mods).ok)
	var bad := valid.duplicate(true); bad.entries[1].value.alternate = "packs/absent.pack#block"; failures.append(["missing alternate",bad])
	bad = valid.duplicate(true); bad.entries[0].value.target.location = "packs/classic#place-00001"; failures.append(["wrong containing location",bad])
	bad = valid.duplicate(true); bad.entries[0].value.target.block = "packs/test.pack#houses"; failures.append(["wrong typed block",bad])
	bad = valid.duplicate(true); bad.entries.append({"id":"ambiguous","value":bad.entries[4].value.duplicate(true)}); failures.append(["overlapping defaults",bad])
	bad = valid.duplicate(true); bad.entries[4].value.choice = {"intent":"variant","variant":"packs/test.pack#absent"}; failures.append(["missing default variant",bad])
	bad = valid.duplicate(true); bad.entries[4].value.choice = {"intent":"variant","variant":"packs/test.pack#shift"}; failures.append(["default variant wrong scope",bad])
	for vector: Array in failures:
		write(path,JSON.stringify(vector[1]))
		mods.rescan()
		var candidate: Dictionary = registry.prepare(mods)
		check("variants publication rejects "+vector[0],false,candidate.ok)
		check("variants publication still unreadable "+vector[0],"before_readiness",adapter.context(registry).kind)
	write(path,JSON.stringify(variant_envelope(authored_variants+[{"id":"invalid-late","value":{"schema":"future"}}])))
	mods.rescan()
	var rejected: Dictionary = registry.prepare(mods)
	check("variants invalid late entry rejects whole file",false,rejected.resources.has(V.DOMAIN+":packs/test.pack"))
	var omissions: Array = rejected.issues.filter(func(i: Dictionary): return i.omittable and i.source.contains("variants.json") and i.source.contains("test.pack"))
	check("variants invalid contribution offers explicit omission",true,not omissions.is_empty())
	if not omissions.is_empty():
		check("variants exact current omission accepted",true,registry.omit(omissions[0].token,rejected.ticket,mods).ok)
		check("variants omission revalidates remaining ZIP reference",false,registry.prepare(mods).ok)
	valid.entries.reverse()
	write(path,JSON.stringify(valid))
	mods.rescan()
	var repaired: Dictionary = registry.prepare(mods)
	check("variants repair rebuilds complete candidate",true,repaired.ok)
	check("variants preparation cannot publish",{},registry.active())
	# Pure schema rejections are independent of final cross-contribution checks.
	var schema_failures: Array = []
	var value: Dictionary = authored_variants[0].value.duplicate(true)
	value.mapping = {"a":"same","b":"same"}; schema_failures.append(["colliding mapping",value])
	value = authored_variants[0].value.duplicate(true); value.target["pixel"] = [1,2]; schema_failures.append(["identity by pixel",value])
	value = authored_variants[0].value.duplicate(true); value.target.scope = "universal-merge"; schema_failures.append(["unsupported scope",value])
	value = authored_variants[4].value.duplicate(true); value.choice = {}; schema_failures.append(["implicit default deletion",value])
	value = authored_variants[4].value.duplicate(true); value.choice = {"intent":"baseline","variant":""}; schema_failures.append(["empty reset sentinel",value])
	for vector: Array in schema_failures: check("variants schema rejects "+vector[0],true,not adapter.validate_record("probe",vector[1]).is_empty())
	var previous := {"records":{"kept":{"value":authored_variants[4].value}}}
	check("variants replace rejects implicit default removal",{"deletion":false,"kind_change":false},{"deletion":adapter.validate_replace(previous,[]).ok,"kind_change":adapter.validate_replace(previous,[{"id":"kept","value":authored_variants[0].value}]).ok})
	check("variants malformed replacement rejects",false,adapter.validate_replace(previous,[7]).ok)
	check("variants patch cannot retarget stable declaration",false,adapter.patch_record(authored_variants[0].value,{"target":{}}).ok)
	check("variants resolve before publication rejects","before_readiness",adapter.resolve(registry,{},Callable()).kind)

func verify_variant_retirement(shell: Control, _fixture: Dictionary) -> void:
	var adapter: RefCounted = shell.controller.providers.variants
	var result: Dictionary = adapter.resolve(shell.controller.providers.definitions,retirement_query,shell.controller.providers.layouts.classic_resource)
	check("variants retired source rejects later preparation",false,result.ok)
	check("variants retired source retains no partial output",false,result.has("occurrences"))

func verify_variants(shell: Control, fixture: Dictionary) -> void:
	var controller = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var adapter: RefCounted = controller.providers.variants
	var resources: Callable = controller.providers.layouts.classic_resource
	check("variants PCK shipped default present",true,registry.query(V.DOMAIN,"packs/project","sample-block-baseline").ok)
	var published_default: Dictionary = registry.query(V.DOMAIN,"packs/project","sample-block-baseline").record
	check("variants loose default precedence",{"winner":"@loose","order":["@shipped/variant-inputs-v1","test.pack","other.pack","@loose"]},{"winner":published_default.winner.provider,"order":published_default.contributors.map(func(c: Dictionary): return c.provider)})
	check("variants ZIP definition winner","other.pack",registry.query(V.DOMAIN,"packs/test.pack","shift").record.winner.provider)
	check("variants ZIP preserves originating identity","test.pack",identity(registry,"shift").package)
	check("variants PCK license available",true,FileAccess.file_exists(V.ROOT+"LICENSE.txt"))
	check("variants PCK declaration hash","794d0e2caff7b177d13717064c32f027dd2e79b7803ee42c8571aaf832a542a9",FileAccess.get_sha256(V.ROOT+"baseline.json"))
	check("variants PCK license hash","7ae5a80e35dd22168f113ad5e1111869f2ecb1609d869734e459932c9f57f4a2",FileAccess.get_sha256(V.ROOT+"LICENSE.txt"))
	var request := query(registry,adapter)
	var baseline: Dictionary = adapter.resolve(registry,request,resources)
	check("variants explicit baseline resolves",true,baseline.ok)
	if not baseline.ok:
		print("Variant baseline failure: ",baseline)
		return
	var initial_context: Dictionary = adapter.context(registry)
	request.selections = [selected(registry,"shift")]
	var shifted: Dictionary = adapter.resolve(registry,request,resources)
	check("variants placement alternative resolves",true,shifted.ok)
	if not shifted.ok:
		print("Variant shift failure: ",shifted)
		return
	check("variants first placement independent",[110,220,330],shifted.occurrences[0].records[0].record.transform.position)
	check("variants second placement baseline",[10,20,30],shifted.occurrences[1].records[0].record.transform.position)
	check("variants retained record occurrence identity",baseline.occurrences[0].records[0].identity,shifted.occurrences[0].records[0].identity)
	check("variants alternate definition remains distinct",false,baseline.occurrences[0].definition == shifted.occurrences[0].definition)
	# Independent Python canonical-JSON reconstruction of the authored logical RDB
	# fixture pins its complete payload, not a hash derived by the tested reader.
	check("variants changed payload receipt",{"changed":true,"payload_sha256":"241166ac20d009a0238559913e3fb15603c0c4f43660194be80e55c37dc6f1d4","source_provider":"other.pack","target_provider":"other.pack"},{"changed":shifted.compatibility[0].changed_payloads.size() > 0,"payload_sha256":R.digest(Layout.lookup(registry,"packs/test.pack#shifted").record.value.data),"source_provider":shifted.compatibility[0].source_provenance.winner.provider,"target_provider":shifted.compatibility[0].target_provenance.winner.provider})
	check("variants payload fingerprints differ",false,shifted.compatibility[0].source_sha256 == shifted.compatibility[0].target_sha256)
	check("variants do not commit selection",false,shifted.selection_committed)
	check("variants do not complete transition",false,shifted.transition_complete)
	check("variants no geometry readiness",false,shifted.location_ready)
	check("variants no SAVE compatibility",false,shifted.compatibility[0].save_compatible)
	var detached := shifted.duplicate(true)
	shifted.occurrences[0].records[0].record.transform.position[0] = 999
	shifted.proposals.clear()
	check("variants detached repeated reads",110,adapter.resolve(registry,request,resources).occurrences[0].records[0].record.transform.position[0])
	var different := query(registry,adapter,"repeated")
	check("variants interleaved location query",true,adapter.resolve(registry,different,resources).ok)
	check("variants query A after B stable",detached.occurrences,adapter.resolve(registry,request,resources).occurrences)
	check("variants context unchanged by reads",initial_context,adapter.context(registry))
	var explicit_global := query(registry,adapter)
	explicit_global.selections = [{"target":request.selections[0].target,"selection":{"intent":"variant","variant":identity(registry,"global-shift")}}]
	check("variants explicit placement can select applicable global definition",true,adapter.resolve(registry,explicit_global,resources).ok)
	var ambiguous := query(registry,adapter,"ambiguous-layout")
	check("variants location versus global default ambiguity rejects",false,adapter.resolve(registry,ambiguous,resources).ok)
	ambiguous.selections = []
	for p in ["other-room","marker-room"]:
		ambiguous.selections.append({"target":{"scope":"placement","location":"packs/classic#place-00000","layout":ambiguous.layout.local,"block":"packs/test.pack#ambiguous-block","placement":p},"selection":{"intent":"baseline"}})
	check("variants explicit placements override ambiguous broader defaults",true,adapter.resolve(registry,ambiguous,resources).ok)
	var reset := request.duplicate(true)
	reset.selections[0].selection = {"intent":"reset-baseline"}
	var reset_result: Dictionary = adapter.resolve(registry,reset,resources)
	check("variants reset baseline proposal validates",true,reset_result.ok)
	check("variants reset returns baseline payload",[10,20,30],reset_result.occurrences[0].records[0].record.transform.position)
	check("variants reset proposal labeled",true,reset_result.proposals[1].resolution.reset_proposal)
	reset.selections[0].selection = {"intent":"reset-default"}
	check("variants reset declared location default",true,adapter.resolve(registry,reset,resources).ok)
	check("variants reset never clears caller selection","variant",request.selections[0].selection.intent)
	var layout_query := query(registry,adapter)
	layout_query.layout_selection = {"intent":"variant","variant":identity(registry,"layout")}
	var layout_result: Dictionary = adapter.resolve(registry,layout_query,resources)
	check("variants containing layout alternate",true,layout_result.ok)
	check("variants reordered placements retain IDs","other-room",layout_result.occurrences[0].identity.placement)
	check("variants containing layout durable anchor",request.layout,layout_result.layout)
	check("variants authored placement transform",1024,layout_result.occurrences[0].placement.transform.position[0])
	var mapped := query(registry,adapter)
	mapped.selections = [selected(registry,"map")]
	var mapped_result: Dictionary = adapter.resolve(registry,mapped,resources)
	check("variants explicit record remapping resolves",true,mapped_result.ok)
	check("variants mapped target scoped","mapped-marker",mapped_result.occurrences[0].records[1].action_target.record)
	check("variants legal action cycle retained","action-door",mapped_result.occurrences[0].records[0].action_target.record)
	var receipt: Dictionary = mapped_result.compatibility[0]
	mapped.compatibility = [{"variant":receipt.variant,"scope":receipt.scope,"source":receipt.source,"target":receipt.target,"source_sha256":receipt.source_sha256,"target_sha256":receipt.target_sha256,"required":["quest-marker"]}]
	check("variants required explicit mapping validates",true,adapter.resolve(registry,mapped,resources).ok)
	mapped.compatibility[0].required = ["absent"]
	check("variants missing required mapping rejects",false,adapter.resolve(registry,mapped,resources).ok)
	mapped.compatibility[0].required = ["quest-marker"]
	mapped.compatibility[0].source_sha256 = "obsolete"
	check("variants obsolete mapping inputs reject",false,adapter.resolve(registry,mapped,resources).ok)
	mapped.compatibility[0].source_sha256 = receipt.source_sha256
	mapped.compatibility[0].scope.placement = "other-room"
	check("variants wrong occurrence mapping rejects",false,adapter.resolve(registry,mapped,resources).ok)
	var houses := query(registry,adapter,"houses")
	houses.selections = [selected(registry,"house","house-one")]
	var house_result: Dictionary = adapter.resolve(registry,houses,resources)
	check("variants building alternative resolves",true,house_result.ok)
	if house_result.ok:
		check("variants first building changed",65,house_result.occurrences[0].records[0].record.transform.position[0])
		check("variants second building independent",64,house_result.occurrences[1].records[0].record.transform.position[0])
		check("variants building parent chain retained",3,house_result.occurrences[0].records[0].coordinate_handoff.parents.size())
	var failures: Array = []
	var bad := request.duplicate(true); bad.content_context.ticket -= 1; failures.append(["stale content context",bad])
	bad = request.duplicate(true); bad.content_context.application = "prior-process"; failures.append(["prior session application context",bad])
	bad = request.duplicate(true); bad.layout_selection = {}; failures.append(["absent required root selection",bad])
	bad = request.duplicate(true); bad.layout_selection = {"intent":""}; failures.append(["empty string is not reset",bad])
	bad = request.duplicate(true); bad.selections[0].selection.variant.local = "packs/missing.pack#missing"; failures.append(["package disappearance",bad])
	bad = request.duplicate(true); bad.selections[0].selection.variant.package = "wrong.pack"; failures.append(["wrong originating package",bad])
	bad = request.duplicate(true); bad.selections.append(bad.selections[0].duplicate(true)); failures.append(["ambiguous caller scopes",bad])
	bad = request.duplicate(true); bad.selections[0].target.placement = "removed-placement"; failures.append(["removed required placement",bad])
	bad = request.duplicate(true); bad.selections[0].selection = {"intent":"default","variant":identity(registry,"shift")}; failures.append(["invalid absence semantics",bad])
	bad = request.duplicate(true); bad.selections[0].selection = {"intent":"variant","variant":identity(registry,"house")}; failures.append(["incompatible variant target",bad])
	bad = request.duplicate(true); bad.required = [{"placement":"marker-room","record":"quest-marker","type":"flat","purpose":"dungeon-start"}]; failures.append(["wrong purpose required marker",bad])
	bad = request.duplicate(true); bad.required = [{"placement":"marker-room","record":"absent-door","type":"door","purpose":""}]; failures.append(["removed required door",bad])
	bad = query(registry,adapter); bad.selections = [selected(registry,"remove")]; bad.required = [{"placement":"marker-room","record":"quest-marker","type":"flat","purpose":"quest"}]; failures.append(["removed required marker",bad])
	bad = houses.duplicate(true); bad.selections[0].target.building = "disappeared-house"; failures.append(["disappeared building target",bad])
	bad = houses.duplicate(true); bad.selections.append(selected(registry,"house-containing","house-one")); failures.append(["containing building combination",bad])
	bad = houses.duplicate(true); bad.selections = [selected(registry,"outside-house","house-one")]; failures.append(["building edit outside declared scope",bad])
	bad = query(registry,adapter); bad.selections = [selected(registry,"wrong-map")]; failures.append(["mapping absent source",bad])
	bad = query(registry,adapter); bad.selections = [selected(registry,"colliding-map")]; failures.append(["mapping collision with retained identity",bad])
	bad = query(registry,adapter); bad.selections = [selected(registry,"wrong-purpose")]; failures.append(["retained marker purpose changed",bad])
	bad = query(registry,adapter); bad.selections = [selected(registry,"wrong-type")]; failures.append(["retained mapping record type changed",bad])
	bad = query(registry,adapter); bad.selections = [selected(registry,"wrong-door")]; failures.append(["retained mapping door role changed",bad])
	for vector: Array in failures:
		var failed: Dictionary = adapter.resolve(registry,vector[1],resources)
		check("variants rejects "+vector[0],false,failed.ok)
		check("variants no partial output "+vector[0],false,failed.has("occurrences"))
	bad_resource_calls = 0
	var failed_later: Dictionary = adapter.resolve(registry,request,late_resource_failure)
	check("variants later required resource failure",false,failed_later.ok)
	check("variants later read after successful resources",3,bad_resource_calls)
	check("variants later failure no partial output",false,failed_later.has("occurrences"))
	check("variants required failure owner context",request.owner,failed_later.referring_owner)
	check("variants fresh caller baseline isolation",baseline.occurrences,adapter.resolve(registry,query(registry,adapter),resources).occurrences)
	check("variants controlled restore order first resolves DATA",true,adapter.resolve(registry,request,resources).ok)
	check("variants real reconstruction remains unavailable",false,detached.location_ready)
	check("variants resolution cannot unlock content",true,controller.mods.locked)
	check("variants late registration rejects",false,controller.providers.enable_variant_inputs().ok)
	check("variants context remains exact after failures",initial_context,adapter.context(registry))
	retirement_query = request.duplicate(true)
	# Persist only a disposable test receipt, never a DATA-owned session selection.
	write(str(fixture.sandbox).path_join("variant-restart-receipt.json"),JSON.stringify({"old_context":initial_context.context}))
	if DisplayServer.get_name() != "headless":
		shell.render()
		var diagnostic := Label.new()
		diagnostic.text = "DATA variant proposals — no live reconstruction\nmarker-room: [110, 220, 330]; other-room: [10, 20, 30]\nhouse-one: 65; house-two: 64 — independent scoped records\nExplicit mapping / baseline reset; required missing content fails\nWORLD / LOC / SAVE / QUEST / MOVE integrations unavailable"
		shell.panel.add_child(diagnostic)
		await capture(shell,"variant-proposals")
		check("variants rendered diagnostic visible",true,diagnostic.is_visible_in_tree())
		check("variants rendered content remains locked",true,controller.mods.locked)
