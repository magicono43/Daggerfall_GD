extends "res://tests/dungeon_context_cases.gd"
const MarkerSchema = preload("res://scripts/data/dungeon_marker_schema.gd")
const MarkerIndex = preload("res://scripts/loc/dungeon_markers.gd")

static func marker_record(id: String, purpose: String, position: Array) -> Dictionary:
	return {"id":id,"type":"flat","transform":Layout.F.transform(position,[0,0,0]),"texture":{"archive":199,"record":10 if purpose == "dungeon-start" else 8},"marker_purpose":purpose,"flags":0,"magnitude":0,"sound_index":0,"action":{"kind":0,"target":""}}

func marker_definition() -> Dictionary:
	var landings: Array = []
	for item in [["a","alpha","start","dungeon-start",[0,0,0]],["b","beta","enter","dungeon-entrance",[0,0,32]],["missing","alpha","absent","dungeon-start",[0,0,0]]]:
		landings.append({"id":item[0],"placement":item[1],"record":item[2],"purpose":item[3],"frame":"classic-block-local-v1","forward":[0,0,1],"guard":{"block":"packs/assembly.test#markers","transform":source_pose(item[4])},"provenance":{"kind":"authored-interface-fixture"}})
	var routes: Array = []
	for item in [["general","general","a",["b"],""],["missing-default","general","missing",["a","b"],""],["door-a","doorway","a",[],"door-a"],["door-shared","doorway","a",[],"door-shared"],["door-b","doorway","b",[],"door-b"],["opening","opening","b",[],""]]:
		routes.append({"id":item[0],"kind":item[1],"default":item[2],"backups":item[3],"doorway":item[4],"selection":"authored-order","return":{"id":"return-"+item[0],"location":"packs/classic#place-00016","layout":"packs/classic#place-00016","placement":"placement-00000","record":"","provenance":{"kind":"explicit-exterior-context-only-fixture"}}})
	return {"schema":MarkerSchema.VERSION,"landings":landings,"routes":routes}

func publish_synthetic(mods: RefCounted) -> void:
	super.publish_synthetic(mods)
	var path: String = mods.root.path_join("Mods/assembly/layout.json")
	var contribution: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	for entry: Dictionary in contribution.entries:
		if entry.id != "scaling": continue
		var declarations: Dictionary = Layout.arrival_annotations().data.layouts["place-00032"].duplicate(true)
		declarations.landings = [declarations.landings[0]]
		declarations.landings[0].placement = "scale-63"
		declarations.routes[0].backups = []
		entry.value.data.arrivals = declarations
	var records: Array = [model_record("floor",67019),marker_record("start","dungeon-start",[0,0,0]),marker_record("enter","dungeon-entrance",[0,0,32])]
	contribution.entries.append({"id":"markers","value":block(records)})
	var reordered_records: Array = records.duplicate(true)
	reordered_records.reverse()
	contribution.entries.append({"id":"markers-reordered","value":block(reordered_records)})
	var layout := test_layout("markers",blank_assembly())
	layout.data.context = context_definition()
	layout.data.arrivals = marker_definition()
	contribution.entries.append({"id":"marker-layout","value":layout})
	var reordered := layout.duplicate(true)
	for placement: Dictionary in reordered.data.placements: placement.block = "packs/assembly.test#markers-reordered"
	for landing: Dictionary in reordered.data.arrivals.landings: landing.guard.block = "packs/assembly.test#markers-reordered"
	contribution.entries.append({"id":"marker-reordered-layout","value":reordered})
	var palette_alternate := layout.duplicate(true)
	palette_alternate.data.context.override = {"120":123}
	contribution.entries.append({"id":"marker-palette-layout","value":palette_alternate})
	var route_alternate := layout.duplicate(true)
	route_alternate.data.arrivals.routes[0].default = "b"
	route_alternate.data.arrivals.routes[0].backups = ["a"]
	contribution.entries.append({"id":"marker-route-layout","value":route_alternate})
	var missing := layout.duplicate(true)
	missing.data.arrivals.routes[2].default = "missing"
	contribution.entries.append({"id":"marker-required-missing","value":missing})
	var bad_role := layout.duplicate(true)
	bad_role.data.arrivals.landings[0].purpose = "dungeon-entrance"
	contribution.entries.append({"id":"marker-wrong-role","value":bad_role})
	var bad_pose := layout.duplicate(true)
	bad_pose.data.arrivals.landings[0].guard.transform.position[0] = 1
	contribution.entries.append({"id":"marker-wrong-pose","value":bad_pose})
	var observed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/dungeon_marker_resolved_observation.json")).locations["place-04310"]
	var placements: Array = []
	for placed: Dictionary in observed.placements:
		placements.append({"id":placed.id,"context":"dungeon","block":"packs/classic#"+placed.block,"transform":source_pose([int(placed.grid[0])*2048,0,int(placed.grid[1])*2048])})
	# All original occurrence transforms are retained. Empty connection declarations
	# qualify source geometry inspection only, never full story traversal readiness.
	var opening := Layout.value("layout",{"mode":"authored","location":"packs/classic#place-04310","placements":placements,"assembly":blank_assembly(),"arrivals":Layout.arrival_annotations().data.layouts["place-04310"].duplicate(true)})
	contribution.entries.append({"id":"opening-source-inspection","value":opening})
	var axis_inspection := Layout.value("layout",{"mode":"authored","location":"packs/classic#place-00016","placements":[{"id":"axis-block","context":"dungeon","block":"packs/classic#block-0930","transform":source_pose([0,0,0])}],"assembly":blank_assembly()})
	contribution.entries.append({"id":"axis-source-inspection","value":axis_inspection})
	write(path,JSON.stringify(contribution))
	var variants_path: String = mods.root.path_join("Mods/assembly/variants.json")
	var variants: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(variants_path))
	for choice in ["palette","route"]:
		variants.entries.append({"id":"marker-"+choice,"value":{"schema":"variant-inputs-v1","kind":"variant","target":{"scope":"location-layout","location":"packs/classic#place-00016","layout":"packs/assembly.test#marker-layout"},"alternate":"packs/assembly.test#marker-"+choice+"-layout","mapping":{}}})
	write(variants_path,JSON.stringify(variants))
	mods.rescan()

func synthetic_checks(owner: Node, fixture: Dictionary) -> void:
	await super.synthetic_checks(owner,fixture)
	var definition := marker_definition()
	check("markers complete declaration schema","",MarkerSchema.reason(definition))
	var malformed := definition.duplicate(true)
	malformed.landings.append(malformed.landings[0].duplicate(true))
	check("markers ambiguous landing declarations reject",true,not MarkerSchema.reason(malformed).is_empty())
	malformed = definition.duplicate(true)
	malformed.routes[2].backups = ["b"]
	check("markers specific backups reject",true,not MarkerSchema.reason(malformed).is_empty())
	malformed = definition.duplicate(true)
	malformed.routes[0].selection = "nearest"
	check("markers absent approach and tie policy never guessed",true,not MarkerSchema.reason(malformed).is_empty())
	malformed = definition.duplicate(true)
	malformed.landings[0].frame = "unity"
	check("markers wrong frame rejects",true,not MarkerSchema.reason(malformed).is_empty())
	malformed = definition.duplicate(true)
	malformed.landings[0].forward = [0,0,0]
	check("markers invalid facing rejects",true,not MarkerSchema.reason(malformed).is_empty())
	malformed = definition.duplicate(true)
	malformed.schema = "obsolete-marker-schema"
	check("markers obsolete declaration version rejects",true,not MarkerSchema.reason(malformed).is_empty())
	var input := request(owner,"packs/assembly.test#marker-layout")
	var result: Dictionary = await assemble(owner,input)
	check("markers real publication and production assembly",true,result.ok)
	if not result.ok:
		observations.marker_failure = result
		return
	last_live_ticket = result.ticket.duplicate(true)
	var ticket: Dictionary = result.ticket
	var first: Dictionary = owner.marker_candidate(ticket,"door-a")
	var other: Dictionary = owner.marker_candidate(ticket,"door-b")
	var shared: Dictionary = owner.marker_candidate(ticket,"door-shared")
	check("markers distinct doorway landings",true,first.ok and other.ok and first.marker != other.marker)
	check("markers explicitly shared landing retains marker",first.marker,shared.marker)
	check("markers shared landing keeps doorway distinct",true,first.doorway != shared.doorway)
	check("markers shared landing keeps return distinct",true,first["return"].id != shared["return"].id)
	check("markers source anchor uses accepted frame",Vector3.ZERO,first.position)
	check("markers source facing uses accepted frame",Vector3.FORWARD,first.forward)
	check("markers repeated block occurrence transform",true,other.position.distance_to(Vector3(0,0,-7.2)) < Frame.POSITION_TOLERANCE)
	check("markers effective layout version retained",result.layout_version,first.marker.layout_version)
	check("markers original CORE request retained",ticket,first.ticket)
	check("markers return context is resolved only",true,first["return"].context_resolved and first["return"].doorway_binding_pending and not first["return"].geometry_ready and not first["return"].traversal_ready and not first["return"].geography_committed)
	check("markers no owner placement SAVE or entry readiness",true,not first.owner_state_ready and not first.placement_validated and not first.placement_committed and not first.destination_ready and not first.save_compatible)
	first.provenance.changed = true
	check("markers handoff is detached",false,owner.marker_candidate(ticket,"door-a").provenance.has("changed"))
	check("markers missing default stays explicit","missing_marker",owner.marker_candidate(ticket,"missing-default",0).kind)
	check("markers eligible ordered backup identity",first.marker,owner.marker_candidate(ticket,"missing-default",1).marker)
	check("markers general second authored backup",other.marker,owner.marker_candidate(ticket,"missing-default",2).marker)
	check("markers exhaustion never expands destination","exhausted",owner.marker_candidate(ticket,"general",2).kind)
	check("markers named target never switches","exhausted",owner.marker_candidate(ticket,"door-a",1).kind)
	check("markers opening target never switches","exhausted",owner.marker_candidate(ticket,"opening",1).kind)
	await controlled_candidate_checks(owner,ticket)
	input = request(owner,"packs/assembly.test#marker-layout")
	result = await assemble(owner,input)
	check("markers inspection reconstruction after controlled handoffs",true,result.ok)
	if not result.ok: return
	ticket = result.ticket
	last_live_ticket = ticket.duplicate(true)
	var started := Time.get_ticks_usec()
	var queries_ok := true
	for index in 1000: queries_ok = queries_ok and owner.marker_candidate(ticket,"door-a").ok
	observations.marker_point_queries = {"count":1000,"usec":Time.get_ticks_usec()-started}
	check("markers prepared point index is reusable",true,queries_ok)
	for invalid in [["marker-required-missing","missing_marker"],["marker-wrong-role","incompatible_marker"],["marker-wrong-pose","incompatible_marker"]]:
		var failed: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#"+invalid[0]))
		check("markers late failure "+invalid[0],invalid[1],failed.kind)
		check("markers prior context preserved "+invalid[0],true,owner.marker_candidate(ticket,"door-a").ok)
	var pending: Dictionary = owner.begin(request(owner,"packs/assembly.test#marker-layout"))
	var wrong: Dictionary = pending.ticket.duplicate(true)
	wrong.serial += 1
	check("markers wrong-ticket cancellation is isolated","stale",owner.cancel(wrong).kind)
	check("markers original preparation survives wrong cancel",true,owner.step(pending.ticket).ok)
	check("markers valid cancellation releases only staging","cancelled",owner.cancel(pending.ticket).kind)
	check("markers cancellation preserves previous binding",true,owner.marker_candidate(ticket,"door-a").ok)
	check("markers duplicate request retains version",result.marker_version,owner.begin(input).marker_version)
	await marker_preparation_checks(owner,ticket)
	write(str(fixture.sandbox).path_join("marker-restart-expectations.json"),JSON.stringify({"version":result.marker_version,"marker":first.marker,"position":[0,0,0],"native_save_qualified":false}))
	if DisplayServer.get_name() != "headless": await marker_review(owner,ticket,fixture)
	await marker_variant_checks(owner,ticket,result)
	await action_axis_checks(owner)
	await opening_source_checks(owner,fixture)

func action_axis_checks(owner: Node) -> void:
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/profile.json"))
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/classic_action_axes_observation.json"))
	var names := {}
	for record: Dictionary in source.records: names[record.name] = true
	for name: String in names:
		var block: Dictionary = profile.blocks.filter(func(b: Dictionary): return b.name == name)[0]
		var decoded: Dictionary = owner.layouts.decode_block(owner.registry,"packs/classic#"+block.id)
		check("axes production DATA imports "+name,true,decoded.ok)
		var expected: int = source.records.filter(func(r: Dictionary): return r.name == name).size()
		check("axes production DATA keeps owner pending "+name,true,decoded.ok and not decoded.action_axis_owner_ready and decoded.pending_action_axis_records.size() == expected)
	var assembled: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#axis-source-inspection"))
	check("axes production LOC retains N0000007 geometry",true,assembled.ok)
	check("axes production LOC keeps action and unknown metadata pending",true,assembled.ok and not assembled.action_axis_owner_ready and assembled.pending_action_axis_bindings.size() == 1 and not assembled.unknown_action_owner_ready and assembled.pending_unknown_action_bindings.size() == 1 and not assembled.owner_state_ready)

func bound_preparation(owner: Node, route: String, kind: String, doorway := "") -> Dictionary:
	var input := request(owner,"packs/assembly.test#marker-layout")
	input.arrival = {"route":route,"kind":kind,"doorway":doorway}
	return await assemble(owner,input)

func controlled_candidate_checks(owner: Node, inspection_ticket: Dictionary) -> void:
	check("markers inspection cannot become an arrival operation","route_intent_pending",owner.check_marker_candidate(inspection_ticket,"general",0,Callable(),Callable()).kind)
	var another_route: Dictionary = owner.marker_candidate(inspection_ticket,"door-shared")
	var prepared: Dictionary = await bound_preparation(owner,"general","general")
	check("markers original general route intent prepares",true,prepared.ok)
	if not prepared.ok: return
	var ticket: Dictionary = prepared.ticket
	var allowed := func(candidate: Dictionary): return {"ok":true,"handoff_id":candidate.handoff_id}
	var rejected := func(_candidate: Dictionary): return {"ok":false}
	var move_exact := func(candidate: Dictionary): return {"handoff_id":candidate.handoff_id,"marker":candidate.marker,"frame":Frame.FRAME,"kind":"exact","position":candidate.position,"forward":candidate.forward,"qualification":"controlled MOVE interface only"}
	var move_rejected := func(candidate: Dictionary): return {"handoff_id":candidate.handoff_id,"marker":candidate.marker,"frame":Frame.FRAME,"kind":"rejected","reason":"Controlled active-shape rejection"}
	var move_corrected := func(candidate: Dictionary): return {"handoff_id":candidate.handoff_id,"marker":candidate.marker,"frame":Frame.FRAME,"kind":"corrected","position":candidate.position+Vector3(0,0.01,0),"forward":candidate.forward,"provenance":{"policy":"controlled MOVE-owned correction, not a LOC radius"}}
	check("markers access provider required","access_provider_unavailable",owner.check_marker_candidate(ticket,"general",0,Callable(),move_exact).kind)
	check("markers access rejection cannot use a backup","access_rejected",owner.check_marker_candidate(ticket,"general",1,rejected,move_exact).kind)
	check("markers actual MOVE is unavailable","placement_provider_unavailable",owner.check_marker_candidate(ticket,"general",0,allowed,Callable()).kind)
	check("markers controlled exact handoff","placement_exact",owner.check_marker_candidate(ticket,"general",0,allowed,move_exact).kind)
	check("markers rejected general default permits only authored next",true,owner.check_marker_candidate(ticket,"general",0,allowed,move_rejected).kind == "placement_rejected" and owner.check_marker_candidate(ticket,"general",1,allowed,move_exact).kind == "placement_exact")
	var attempts := [0]
	var revoked := func(candidate: Dictionary): attempts[0] += 1; return {"ok":attempts[0] == 1,"handoff_id":candidate.handoff_id}
	check("markers access revocation rechecked","access_rejected",owner.check_marker_candidate(ticket,"general",0,revoked,move_exact).kind)
	prepared = await bound_preparation(owner,"door-a","doorway","door-a")
	check("markers original named doorway intent prepares",true,prepared.ok)
	if not prepared.ok: return
	ticket = prepared.ticket
	check("markers named original intent cannot query opening","route_mismatch",owner.marker_candidate(ticket,"opening").kind)
	check("markers controlled corrected handoff","placement_corrected",owner.check_marker_candidate(ticket,"door-a",0,allowed,move_corrected).kind)
	var borrowed := func(_candidate: Dictionary): return {"handoff_id":another_route.handoff_id,"marker":another_route.marker,"frame":Frame.FRAME,"kind":"exact","position":another_route.position,"forward":another_route.forward}
	check("markers same landing wrong doorway result rejects","invalid_placement_result",owner.check_marker_candidate(ticket,"door-a",0,allowed,borrowed).kind)
	check("markers bound named route cannot use backups","exhausted",owner.check_marker_candidate(ticket,"door-a",1,allowed,move_exact).kind)
	prepared = await bound_preparation(owner,"opening","opening")
	check("markers original opening intent prepares",true,prepared.ok)
	if not prepared.ok: return
	check("markers controlled rejection retains target","placement_rejected",owner.check_marker_candidate(prepared.ticket,"opening",0,allowed,move_rejected).kind)
	check("markers bound opening cannot retarget doorway","route_mismatch",owner.check_marker_candidate(prepared.ticket,"door-a",0,allowed,move_exact).kind)
	var wrong := request(owner,"packs/assembly.test#marker-layout")
	wrong.arrival = {"route":"general","kind":"opening","doorway":""}
	check("markers mismatched original route kind fails preparation","invalid_route_intent",(await assemble(owner,wrong)).kind)
	check("markers intent failure retains active opening",true,owner.marker_candidate(prepared.ticket,"opening").ok)

func marker_variant_checks(owner: Node, ticket: Dictionary, previous: Dictionary) -> void:
	var variant: Dictionary = owner.registry.query("world.variants","packs/assembly.test","marker-palette")
	var input := request(owner,"packs/assembly.test#marker-layout")
	input.variants = {"layout_selection":{"intent":"variant","variant":variant.record.identity},"selections":[],"required":[],"compatibility":[]}
	var result: Dictionary = await assemble(owner,input)
	check("markers compatible visual variant reaches production",true,result.ok)
	if result.ok:
		last_live_ticket = result.ticket.duplicate(true)
		var selected: Dictionary = owner.marker_candidate(result.ticket,"door-a")
		check("markers visual variant retains marker binding version",previous.marker_version,result.marker_version)
		check("markers visual variant retains geometry version",previous.geometry_version,result.geometry_version)
		check("markers visual variant retains scoped record",["alpha","start"],[selected.marker.placement,selected.marker.record])
		check("markers superseded preparation cannot answer callbacks","stale",owner.marker_candidate(ticket,"door-a").kind)
		variant = owner.registry.query("world.variants","packs/assembly.test","marker-route")
		input = request(owner,"packs/assembly.test#marker-layout")
		input.variants = {"layout_selection":{"intent":"variant","variant":variant.record.identity},"selections":[],"required":[],"compatibility":[]}
		check("markers structural route edits keep compatibility gate","provider_pending",owner.begin(input).kind)
		check("markers route rejection preserves visual context",true,owner.marker_candidate(result.ticket,"door-a").ok)
	var reordered: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#marker-reordered-layout"))
	check("markers reordered records and validated mapping override",true,reordered.ok)
	if reordered.ok:
		var selected: Dictionary = owner.marker_candidate(reordered.ticket,"door-a")
		check("markers reordered array does not select Enter first",true,selected.marker.record == "start" and selected.position == Vector3.ZERO)
		check("markers reordered repeated block keeps placed identity","beta",owner.marker_candidate(reordered.ticket,"door-b").marker.placement)

func scaling_checks(owner: Node, source: Dictionary) -> void:
	await super.scaling_checks(owner,source)
	var started := Time.get_ticks_usec()
	var passed := true
	for index in 1000: passed = passed and owner.marker_candidate(last_live_ticket,"general").ok
	observations.scaling.marker_queries = 1000
	observations.scaling.marker_query_usec = Time.get_ticks_usec()-started
	check("markers full 64-block prepared point queries",true,passed)
	var selected: Dictionary = owner.marker_candidate(last_live_ticket,"general")
	check("markers full stress selects last placed occurrence",true,selected.ok and selected.marker.placement == "scale-63" and selected.position.distance_to(Vector3(490,32.6,-483.4)) < Frame.POSITION_TOLERANCE)

func lifecycle_checks(owner: Node) -> void:
	await super.lifecycle_checks(owner)
	var core: RefCounted = owner.core
	var provider: RefCounted = core.provider
	provider.hold_preflight = false
	provider.hold_readiness = false
	check("markers activation source controlled session","Succeeded",core.request({"id":"marker-activation-source","mode":"new","origin":"","selection":{}}).kind)
	var live: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#marker-layout"))
	check("markers activation source geometry",true,live.ok)
	if not live.ok: return
	provider.hold_preflight = true
	check("markers replacement original operation admitted","pending",core.request({"id":"marker-activation-replace","mode":"new","origin":core.snapshot().session,"selection":{}}).kind)
	var original: Dictionary = core.ticket()
	var input := request(owner,"packs/assembly.test#marker-layout")
	input.core_ticket = original
	input.session = original.scope
	input.arrival = {"route":"door-a","kind":"doorway","doorway":"door-a"}
	var prepared: Dictionary = await assemble(owner,input)
	check("markers replacement prepared before source retirement",true,prepared.ok)
	if not prepared.ok:
		core.cancel(original)
		return
	provider.hold_readiness = true
	core.complete_preflight(original,{"ok":true})
	core.confirm(core.ticket(),true)
	check("markers CORE reaches destination initialization","initializing",core.snapshot().phase)
	var before_activation: Dictionary = owner.marker_candidate(prepared.ticket,"door-a")
	check("markers original ticket activates same index",true,owner.activate(prepared.ticket).ok)
	var selected: Dictionary = owner.marker_candidate(prepared.ticket,"door-a")
	var allowed := func(candidate: Dictionary): return {"ok":true,"handoff_id":candidate.handoff_id}
	var old_placement := func(_candidate: Dictionary): return {"handoff_id":before_activation.handoff_id,"marker":before_activation.marker,"frame":Frame.FRAME,"kind":"exact","position":before_activation.position,"forward":before_activation.forward}
	check("markers activation retains original request identity",true,selected.ticket.request.core_ticket == original and selected.activation_session == core.snapshot().session and selected.handoff_id != before_activation.handoff_id and owner.check_marker_candidate(prepared.ticket,"door-a",0,allowed,old_placement).kind == "invalid_placement_result")
	check("markers activation retires previous source query","stale",owner.marker_candidate(live.ticket,"door-a").kind)
	core.complete_readiness(core.ticket(),{"ok":true,"services":provider.bindings(),"death_authority":provider})
	check("markers index survives CORE operation terminal",true,owner.marker_candidate(prepared.ticket,"door-a").ok)
	check("markers repeated activation is idempotent",true,owner.activate(prepared.ticket).ok and owner.get_child_count() == 1)
	var intent := {"id":"marker-activation-return","mode":"return","origin":core.snapshot().session}
	core.request(intent)
	core.confirm(core.ticket(),true)
	check("markers retired-session callbacks cannot query index","stale",owner.marker_candidate(prepared.ticket,"door-a").kind)
	check("markers retired-session releases geometry and index",0,owner.get_child_count())

func marker_preparation_checks(owner: Node, live_ticket: Dictionary) -> void:
	var core: RefCounted = owner.core
	var provider: RefCounted = core.provider
	provider.hold_preflight = true
	check("markers CORE preparation admission","pending",core.request({"id":"marker-preflight","mode":"new","origin":core.snapshot().session,"selection":{}}).kind)
	var original: Dictionary = core.ticket()
	var input := request(owner,"packs/assembly.test#marker-layout")
	input.core_ticket = original
	input.session = original.scope
	var prepared: Dictionary = await assemble(owner,input)
	check("markers isolated CORE preparation",true,prepared.ok)
	if prepared.ok:
		var selected: Dictionary = owner.marker_candidate(prepared.ticket,"opening")
		check("markers original operation identity survives preparation",original,selected.ticket.request.core_ticket)
		check("markers preflight cannot activate early","pending",owner.activate(prepared.ticket).kind)
		check("markers isolated preparation leaves live context",2,owner.get_child_count())
		check("markers outgoing query remains CORE-gated","stale",owner.marker_candidate(live_ticket,"door-a").kind)
		check("markers CORE cancellation accepted",true,core.cancel(original))
		check("markers cancelled original callback is stale","stale",owner.marker_candidate(prepared.ticket,"opening").kind)
		check("markers cancellation retains original live marker",true,owner.marker_candidate(live_ticket,"door-a").ok)
	else:
		observations.marker_preparation_failure = prepared
		core.cancel(original)
	provider.hold_preflight = false

func opening_source_checks(owner: Node, fixture: Dictionary) -> void:
	var result: Dictionary = await assemble(owner,request(owner,"packs/assembly.test#opening-source-inspection"))
	check("markers Privateers Hold real source geometry inspection",true,result.ok)
	if not result.ok:
		observations.opening_failure = result
		return
	last_live_ticket = result.ticket.duplicate(true)
	check("markers Privateers Hold five original occurrences",5,result.occurrences.size())
	var candidate: Dictionary = owner.marker_candidate(result.ticket,"new-game-opening")
	var entrance: Dictionary = owner.marker_candidate(result.ticket,"general")
	check("markers deep cave source anchor independently pinned",true,candidate.ok and candidate.position.distance_to(Vector3(12.75,0.625,-41.8)) < Frame.POSITION_TOLERANCE)
	check("markers ordinary entrance remains separate",true,entrance.ok and entrance.position.distance_to(Vector3(28.375,38.975,-12.4)) < Frame.POSITION_TOLERANCE and entrance.marker != candidate.marker)
	check("markers authorized DFU north facing",Vector3.FORWARD,candidate.forward)
	check("markers original executable facing is not claimed",false,candidate.provenance.original_facing_verified)
	check("markers deep cave exact placed source identity",["placement-00001","record-00216"],[candidate.marker.placement,candidate.marker.record])
	check("markers unknown action stays pending in LOC",true,not result.unknown_action_owner_ready and result.pending_unknown_action_bindings.size() == 1)
	var floor_pin: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/dungeon_opening_floor_observation.json"))
	var floor_hit: Dictionary = owner.geometry_ray(result.ticket,candidate.position,candidate.position+Vector3.DOWN*2)
	check("markers cave source floor independently intersects",true,floor_hit.ok and floor_hit.found and absf(floor_hit.position.y-float(floor_pin.nearest_floor)) < Frame.POSITION_TOLERANCE)
	check("markers cave source floor retains original record",[floor_pin.placement,floor_pin.record],[floor_hit.record.placement,floor_hit.record.record])
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/dungeon_opening_geometry_observation.json"))
	var model_checks := 0
	for placed: Dictionary in source.placements:
		for record: Dictionary in placed.records:
			if not record.has("model"): continue
			var binding: Dictionary = owner.binding(result.ticket,placed.id,record.id)
			var bounds: Array = record.expected_bounds
			check("markers opening independent source bounds "+placed.id+"/"+record.id,true,binding.ok and binding.binding.bounds.position.distance_to(Vector3(bounds[0][0],bounds[0][1],bounds[0][2])) < Frame.POSITION_TOLERANCE and binding.binding.bounds.end.distance_to(Vector3(bounds[1][0],bounds[1][1],bounds[1][2])) < Frame.POSITION_TOLERANCE)
			model_checks += 1
	observations.opening_source = {"location":"place-04310","scope":"all-five-original-occurrences-geometry-inspection-only","independent_model_bounds":model_checks,"opening_marker":candidate.marker,"position":candidate.position,"forward":candidate.forward,"full_story_connections_qualified":false,"actor_shape_clearance_qualified":false,"original_executable_facing_verified":false,"original_executable_opening_verified":false}
	check("markers opening inspection grants no story entry",false,candidate.destination_ready)
	check("markers original unqualified layout still fails closed","unsupported",owner.begin(request(owner,"packs/classic#place-04310")).kind)
	if DisplayServer.get_name() != "headless": await marker_review(owner,result.ticket,fixture,["new-game-opening"],"opening-source-anchor")

func marker_review(owner: Node, ticket: Dictionary, fixture: Dictionary, routes: Array = ["door-a","door-b"], capture := "marker-anchors") -> void:
	# Review aid uses actual handed-off anchors. Arrows are diagnostics, not actors.
	var parent := owner.get_parent()
	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	viewport.size = Vector2i(1000,700)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	parent.add_child(viewport)
	owner.reparent(viewport)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60,-25,0)
	viewport.add_child(light)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.7
	viewport.add_child(environment)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	var center := Vector3.ZERO
	for route: String in routes: center += owner.marker_candidate(ticket,route).position/float(routes.size())
	camera.position = center+(Vector3(3,2,4) if routes.size() == 1 else Vector3(9,13,12))
	camera.look_at(center)
	camera.current = true
	var legend := "MARKER ANCHORS / FACING — geometry inspection; no actor clearance or entry\n"
	for route: String in routes:
		var candidate: Dictionary = owner.marker_candidate(ticket,route)
		var color := Color.YELLOW if routes.find(route) == 0 else Color.CYAN
		legend += "%s: %s -> %s/%s  anchor %s  forward %s\nreturn %s: exterior context resolved; doorway/geometry pending\n" % ["Yellow" if color == Color.YELLOW else "Cyan",route,candidate.marker.placement,candidate.marker.record,str(candidate.position),str(candidate.forward),candidate["return"].id]
		var label := Label3D.new()
		label.text = route+" / "+candidate.landing+"\n"+candidate["return"].id+" (exterior doorway pending)"
		label.position = candidate.position+Vector3.UP
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		viewport.add_child(label)
		var arrow := MeshInstance3D.new()
		var mesh := ImmediateMesh.new()
		mesh.surface_begin(Mesh.PRIMITIVE_LINES,diagnostic_material(color))
		mesh.surface_add_vertex(candidate.position+Vector3.UP*0.1)
		mesh.surface_add_vertex(candidate.position+Vector3.UP*0.1+candidate.forward*2)
		for side in [-1,1]:
			mesh.surface_add_vertex(candidate.position+Vector3.UP*0.1+candidate.forward*2)
			mesh.surface_add_vertex(candidate.position+Vector3.UP*0.1+candidate.forward*1.6+candidate.forward.cross(Vector3.UP)*0.3*side)
		mesh.surface_end()
		arrow.mesh = mesh
		viewport.add_child(arrow)
	if routes.size() == 1: legend += "Privateer's Hold source cave / adopted DFU north-facing baseline; original facing unverified"
	var panel := Panel.new()
	panel.position = Vector2(8,8)
	panel.size = Vector2(984,196)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025,0.03,0.04,1)
	panel.add_theme_stylebox_override("panel",style)
	viewport.add_child(panel)
	var readable := Label.new()
	readable.position = Vector2(10,8)
	readable.size = Vector2(964,180)
	readable.text = legend
	readable.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	readable.add_theme_font_size_override("font_size",17)
	readable.add_theme_color_override("font_color",Color.WHITE)
	panel.add_child(readable)
	await owner.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	var readable_pixels := 0
	for y in range(20,160,2):
		for x in range(20,960,2):
			var pixel := image.get_pixel(x,y)
			if minf(pixel.r,minf(pixel.g,pixel.b)) > 0.9: readable_pixels += 1
	# Check actual glyph rasterization, so a saved but unlabelled capture fails.
	check("markers rendered labelled anchors and facing capture "+capture,OK,image.save_png(str(fixture.sandbox).path_join(capture+".png")) if readable_pixels > 50 else ERR_INVALID_DATA)
	owner.reparent(parent)
	preload("res://scripts/loc/dungeon_geometry.gd").release(viewport)
