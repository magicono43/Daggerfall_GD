extends RefCounted
## Maintained scenarios invoked by the normal complete-composition LOC fixture.
const Frame = preload("res://scripts/data/layout_geometry_frame.gd")
var observation := {}

class ChangedDoorways extends RefCounted:
	## Rejection-only seam. This never supplies geometry or readiness.
	var input := {}
	func assembly_choices(_registry: RefCounted, _baseline: Dictionary) -> Dictionary:
		return {"ok":true,"needed":true,"root":{},"context":{}}
	func assembly_inputs(_registry: RefCounted, _query: Dictionary) -> Dictionary:
		return {"ok":true,"layout_inputs":input,"compatibility":[],"proposals":[],"blocks":{}}

func publish(cases: RefCounted, entries: Array, mods: RefCounted) -> void:
	observation = JSON.parse_string(FileAccess.get_file_as_string("res://tests/location_doorway_observation.json"))
	for variant in ["reordered","bad-guard","wrong-building"]:
		var classic: Dictionary = preload("res://scripts/data/layout_inputs.gd").value("layout",{"mode":"authored","location":"packs/classic#place-00001","placements":[{"id":observation.declaration.interiors[0].placement,"context":"exterior","block":"packs/classic#"+observation.block,"transform":cases.source_pose()}],"location_assembly":cases.declarations()})
		classic.data.location_assembly.doorways = observation.declaration.duplicate(true)
		var alias: Dictionary = classic.data.location_assembly.doorways.links[-1]
		if variant == "reordered": classic.data.location_assembly.doorways.links.reverse()
		if variant == "bad-guard": alias.exterior.guard.model_sha256 = "0".repeat(64)
		if variant == "wrong-building": alias.entry_alias_of = "home-east"
		entries.append({"id":"tavern-alias-"+variant,"value":classic})
	var block := preload("res://scripts/data/layout_inputs.gd").value("block",{"mode":"authored","format":"RMB","records":[],"structure":{"ground":{"header":"00".repeat(8),"tiles":"00".repeat(256),"scenery":"ff".repeat(256)},"automap":"00".repeat(4096),"buildings":[],"misc":[]}})
	var records: Array = block.data.records
	for side in ["front","back"]:
		var back: bool = side == "back"
		records.append({"id":"facade-"+side,"type":"model","model_id":549,"object_type":0,"transform":cases.source_pose([0,0,512 if back else 0],[0,1024 if back else 0,0])})
		records.append({"id":"exit-"+side,"type":"model","model_id":31021,"object_type":0,"transform":cases.source_pose([-189,-63,448] if back else [189,-63,64],[0,1024 if back else 0,0])})
		records.append({"id":"marker-"+side,"type":"flat","texture":{"archive":199,"record":4 if back else 8},"marker_purpose":"editor-other" if back else "dungeon-entrance","flags":0,"faction_id":0,"transform":cases.source_pose([-192,0,448] if back else [192,0,64])})
	var metadata := {"name_seed":0,"service_time_limit":0,"unknown":[0,0,0,0],"faction_id":0,"sector":0,"location_id":0,"building_type":0,"quality":0}
	block.data.structure.buildings = [{"id":"hall","transform":cases.source_pose(),"metadata":metadata,"exterior":["facade-front","facade-back"],"interior":["exit-front","exit-back","marker-front","marker-back"]}]
	entries.append({"id":"doorway-block","value":block})
	var declarations: Dictionary = cases.declarations()
	declarations.doorways = {"schema":"location-doorways-v1","interiors":[],"links":[]}
	var layout := preload("res://scripts/data/layout_inputs.gd").value("layout",{"mode":"authored","location":"packs/classic#place-00001","placements":[],"location_assembly":declarations})
	for copy in ["a","b"]:
		layout.data.placements.append({"id":copy,"context":"exterior","block":"packs/location.test#doorway-block","transform":cases.source_pose([8192 if copy == "b" else 0,0,0],[0,512 if copy == "b" else 0,0])})
		declarations.doorways.interiors.append({"id":copy+"-suite","placement":copy,"building":"hall","parent":cases.source_pose(),"provenance":{"fixture":"explicit-authored-template-reuse"}})
		for side in ["front","back"]:
			var back: bool = side == "back"
			var source: Dictionary = observation.declaration.links[0]
			var link: Dictionary = source.duplicate(true)
			link.id = copy+"-"+side
			link.interior = copy+"-suite"
			for field in ["exterior","exit"]:
				link[field].placement = copy
				link[field].record = ("facade-" if field == "exterior" else "exit-")+side
				link[field].guard.payload_sha256 = ""
				link[field].guard.transform = records.filter(func(r: Dictionary): return r.id == link[field].record)[0].transform.duplicate(true)
			link.landing.record = "marker-"+side
			link.landing.guard.payload_sha256 = ""
			link.landing.guard.transform = records.filter(func(r: Dictionary): return r.id == link.landing.record)[0].transform.duplicate(true)
			link.landing.guard.texture.record = 4 if back else 8
			link.landing.forward = [1,0,0] if back else [-1,0,0]
			link.landing.additional_entry = back
			link.outside_offset = [-1,0,0] if back else [1,0,0]
			link.provenance = {"fixture":"authored-opposite-door-plane-sides-v1","rest_entry":"back rest marker explicitly qualified by matching exit geometry"}
			declarations.doorways.links.append(link)
	# value() copies inputs, so publish the completed declaration explicitly.
	layout.data.location_assembly = declarations.duplicate(true)
	entries.append({"id":"doorways","value":layout})
	# Patch a different shipped RMB's complete authored data, preserving DATA's
	# genuine immutable source receipt. Fabricated receipts must never qualify.
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/profile.json"))
	var replaced_source: Dictionary = profile.blocks.filter(func(b: Dictionary): return str(b.name).ends_with(".RMB") and b.id != observation.block)[0]
	cases.write(mods.root.path_join("Mods/location/z-classic-replacement.json"),JSON.stringify({"domain":"layout.inputs","path":"packs/classic","operation":"patch","entries":[{"id":replaced_source.id,"value":{"data":block.data.duplicate(true)}}]}))
	for kind in ["authored","guard"]:
		var replacement: Dictionary = layout.duplicate(true)
		for p: Dictionary in replacement.data.placements: p.block = "packs/classic#"+str(replaced_source.id)
		if kind == "guard":
			for link: Dictionary in replacement.data.location_assembly.doorways.links:
				for field in ["exterior","exit","landing"]: link[field].guard.payload_sha256 = replaced_source.sha256
		entries.append({"id":"doorways-replaced-"+kind,"value":replacement})
	entries.append({"id":"doorways-precedence","value":layout.duplicate(true)})
	var mod_declaration: Dictionary = declarations.duplicate(true)
	mod_declaration.doorways.links[0].outside_offset = [1.5,0,0]
	var mod_data: Dictionary = layout.data.duplicate(true)
	mod_data.location_assembly = mod_declaration
	var patch := {"domain":"layout.inputs","path":"packs/location.test","operation":"patch","entries":[{"id":"doorways-precedence","value":{"data":mod_data}}]}
	cases.write(mods.root.path_join("Mods/location/z-doorway-patch.json"),JSON.stringify(patch))
	var loose: Dictionary = patch.duplicate(true)
	loose.entries[0].value.data.location_assembly.doorways.links[0].outside_offset = [2.5,0,0]
	cases.write(mods.root.path_join("Overrides/doorway-patch.json"),JSON.stringify(loose))
	var scaling: Dictionary = layout.duplicate(true)
	scaling.data.placements = []
	scaling.data.location_assembly.doorways = {"schema":"location-doorways-v1","interiors":[],"links":[]}
	for index in 64:
		var id := "scale-%02d" % index
		scaling.data.placements.append({"id":id,"context":"exterior","block":"packs/location.test#doorway-block","transform":cases.source_pose([(index%8)*8192,0,(index/8)*8192],[0,(index%4)*512,0])})
		var interior: Dictionary = declarations.doorways.interiors[0].duplicate(true)
		interior.id = id+"-suite"
		interior.placement = id
		scaling.data.location_assembly.doorways.interiors.append(interior)
		for original: Dictionary in declarations.doorways.links.slice(0,2):
			var link: Dictionary = original.duplicate(true)
			link.id = id+"-"+original.id.trim_prefix("a-")
			link.interior = interior.id
			link.exterior.placement = id
			link.exit.placement = id
			scaling.data.location_assembly.doorways.links.append(link)
	entries.append({"id":"doorways-scaling","value":scaling})
	var unbound: Dictionary = scaling.duplicate(true)
	unbound.data.location_assembly.erase("doorways")
	entries.append({"id":"doorways-unbound-scaling","value":unbound})
	var coincident_block: Dictionary = block.duplicate(true)
	var shadow: Dictionary = records[0].duplicate(true)
	shadow.id = "facade-shadow"
	coincident_block.data.records.append(shadow)
	coincident_block.data.structure.buildings[0].exterior.append(shadow.id)
	entries.append({"id":"doorway-coincident-block","value":coincident_block})
	for selection in ["coincident","selected"]:
		var changed: Dictionary = layout.duplicate(true)
		for p: Dictionary in changed.data.placements: p.block = "packs/location.test#doorway-coincident-block"
		if selection == "selected":
			for copy in ["a","b"]:
				changed.data.location_assembly.hit_rules.append({"candidates":[copy+"/facade-front/plane-0",copy+"/facade-shadow/plane-0"],"selected":copy+"/facade-front/plane-0"})
		entries.append({"id":"doorways-"+selection,"value":changed})
	for variant in ["missing","missing-exit","incompatible","wrong-side","out-of-frame","reordered","override","authored-facing"]:
		var changed: Dictionary = layout.duplicate(true)
		var links: Array = changed.data.location_assembly.doorways.links
		match variant:
			"missing": links[0].landing.record = "absent"
			"missing-exit": links.remove_at(1)
			"incompatible": links[0].exterior.guard.model_sha256 = "0".repeat(64)
			"wrong-side": links[0].outside_offset = [-1,0,0]
			"out-of-frame": links[0].outside_offset = [8192,0,0]
			"authored-facing": links[0].landing.forward = [0,0,1]
			"reordered":
				changed.data.placements.reverse()
				links.reverse()
			"override":
				links[0].outside_offset = [2,0,0]
				links[0].provenance = {"fixture":"validated-explicit-override"}
		entries.append({"id":"doorways-"+variant,"value":changed})

func run(cases: RefCounted, owner: Node, reload: bool, fixture: Dictionary, shell: Control) -> void:
	observation = JSON.parse_string(FileAccess.get_file_as_string("res://tests/location_doorway_observation.json"))
	for vector: Dictionary in observation.vectors:
		var input: Dictionary = cases.area_request(owner,"packs/classic#place-00001",{"kind":"interior","placement":"placement-00000","building":vector.building,"instance":vector.instance})
		# The stable source placement is declared, never inferred from enumeration.
		input.area.placement = observation.declaration.interiors.filter(func(i: Dictionary): return i.id == vector.instance)[0].placement
		input.arrival = {"route":vector.id,"kind":"doorway","doorway":vector.id}
		var result: Dictionary = await cases.assemble(owner,input)
		cases.check("doorway classic assembly "+vector.id,true,result.ok)
		if not result.ok:
			cases.observations.doorway_failure = result
			continue
		var selected: Dictionary = owner.marker_candidate(result.ticket,vector.id)
		cases.check("doorway classic explicit marker "+vector.id,vector.marker.id,selected.marker.record)
		cases.check("doorway classic source anchor "+vector.id,true,selected.position.distance_to(Frame.vector(vector.marker.position)) < Frame.POSITION_TOLERANCE and selected.exit.position.distance_to(Frame.vector(vector.doors[1].centre)) < Frame.POSITION_TOLERANCE and selected.entrance.position.distance_to(Frame.vector(vector.doors[0].centre)) < Frame.POSITION_TOLERANCE)
		cases.check("doorway classic facing "+vector.id,true,selected.forward.distance_to(Frame.vector(vector.facing)) < Frame.NORMAL_TOLERANCE)
		cases.check("doorway classic target identity "+vector.id,true,selected["return"].record == vector.doors[0].record and selected.template.building == vector.building and selected.template.block.record == observation.block)
		cases.check("doorway classic real readiness gated "+vector.id,false,selected.destination_ready or selected.owner_state_ready or selected.placement_committed)
		if DisplayServer.get_name() != "headless":
			await capture(cases,owner,shell,fixture,"doorway-"+vector.id,[selected],selected.position+selected.forward*3+Vector3.UP*2+selected.forward.cross(Vector3.UP)*3,selected.exit.position)
	var tavern_area := {"kind":"interior","placement":observation.declaration.interiors[2].placement,"building":"building-0002","instance":"building-0002-interior"}
	var alias_input: Dictionary = cases.area_request(owner,"packs/classic#place-00001",tavern_area)
	alias_input.arrival = {"route":"tavern-courtyard","kind":"doorway","doorway":"tavern-courtyard"}
	var alias_result: Dictionary = await cases.assemble(owner,alias_input)
	cases.check("doorway tavern alias assembly",true,alias_result.ok)
	if not alias_result.ok: return
	var alias_selected: Dictionary = owner.marker_candidate(alias_result.ticket,"tavern-courtyard")
	cases.check("doorway tavern alias retains selected entrance",41,alias_selected.entrance.plane)
	cases.check("doorway tavern alias names canonical entry","tavern-rear",alias_selected.entry_alias_of)
	cases.check("doorway tavern alias selects rear marker","record-00271",alias_selected.marker.record)
	cases.check("doorway tavern alias selects actual rear exit","record-00203",alias_selected.exit.record)
	cases.check("doorway tavern alias returns to rear exterior",46,alias_selected["return"].plane)
	cases.check("doorway tavern alias whole interior bound",true,owner.readiness(alias_result.ticket).binding_ready)
	cases.check("doorway tavern alias cannot retarget","route_mismatch",owner.marker_candidate(alias_result.ticket,"tavern-front").kind)
	var alias_handoff: Dictionary = owner.check_marker_candidate(alias_result.ticket,"tavern-courtyard",0,func(value: Dictionary): return {"ok":true,"handoff_id":value.handoff_id},func(value: Dictionary): return {"kind":"pending","handoff_id":value.handoff_id,"marker":value.marker,"frame":value.frame})
	cases.check("doorway tavern alias actual consumer pending","placement_pending",alias_handoff.kind)
	cases.check("doorway tavern alias consumer retains redirect",true,alias_handoff.entrance.plane == 41 and alias_handoff["return"].plane == 46 and not alias_handoff.placement_committed)
	var tavern_view: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/classic#place-00001",tavern_area))
	var rear: Dictionary = owner.marker_candidate(tavern_view.ticket,"tavern-rear")
	var courtyard: Dictionary = owner.marker_candidate(tavern_view.ticket,"tavern-courtyard")
	cases.check("doorway tavern alias shares rear landing",true,rear.interior == courtyard.interior and rear.marker == courtyard.marker and rear.position == courtyard.position and rear.forward == courtyard.forward)
	cases.check("doorway tavern exits retain canonical links",true,tavern_view.doors[rear.exit.id].link == "tavern-rear" and tavern_view.doors[owner.marker_candidate(tavern_view.ticket,"tavern-front").exit.id].link == "tavern-front")
	var tavern_entries: Array = owner.marker_candidates(tavern_view.ticket,"building-0002-interior","entry").records
	cases.check("doorway tavern original entry inventory",4,tavern_entries.size())
	cases.check("doorway tavern unused markers remain unbound",true,tavern_entries.filter(func(m: Dictionary): return m.identity.record in ["record-00272","record-00273"] and not m.get("binding_ready",false)).size() == 2)
	cases.check("doorway tavern rest roles unchanged",5,owner.marker_candidates(tavern_view.ticket,"building-0002-interior","rest").records.size())
	var return_input: Dictionary = cases.area_request(owner,"packs/classic#place-00001",{"kind":"exterior"})
	return_input.arrival = {"route":"tavern-courtyard","kind":"doorway","doorway":"tavern-courtyard"}
	var invalid_return: Dictionary = await cases.assemble(owner,return_input)
	cases.check("doorway tavern alias cannot be exit","entry_only",invalid_return.kind)
	cases.check("doorway tavern alias failure retains interior",true,owner.readiness(tavern_view.ticket).ok and owner._stage.is_empty())
	return_input = cases.area_request(owner,"packs/classic#place-00001",{"kind":"exterior"})
	return_input.arrival = {"route":"tavern-rear","kind":"doorway","doorway":"tavern-rear"}
	var rear_return: Dictionary = await cases.assemble(owner,return_input)
	cases.check("doorway tavern rear return assembly",true,rear_return.ok)
	cases.check("doorway tavern exit ignores last entrance",46,owner.marker_candidate(rear_return.ticket,"tavern-rear").marker.plane)
	cases.check("doorway tavern exterior all five doors bound",true,rear_return.binding_ready and rear_return.pending_static_door_bindings.is_empty() and rear_return.doors.size() == 5)
	cases.check("doorway tavern exterior cannot retarget","route_mismatch",owner.marker_candidate(rear_return.ticket,"tavern-courtyard").kind)
	var exterior_inspect: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/classic#place-00001",{"kind":"exterior"}))
	cases.check("doorway tavern exterior alias query rejects","entry_only",owner.marker_candidate(exterior_inspect.ticket,"tavern-courtyard").kind)
	var input: Dictionary = cases.area_request(owner,"packs/location.test#doorways",{"kind":"interior","placement":"a","building":"hall","instance":"a-suite"})
	input.arrival = {"route":"a-front","kind":"doorway","doorway":"a-front"}
	var result: Dictionary = await cases.assemble(owner,input)
	cases.check("doorway native shared interior assembly",true,result.ok)
	if not result.ok:
		cases.observations.native_doorway_failure = result
		return
	cases.last_live_ticket = result.ticket
	var front: Dictionary = owner.marker_candidate(result.ticket,"a-front")
	if DisplayServer.get_name() != "headless":
		var back_link: Dictionary = result.doorway_links["a-back"]
		var visual_back := {"position":back_link.landing.position,"forward":back_link.landing.forward,"exit":back_link.exit,"marker":back_link.landing.marker}
		await capture(cases,owner,shell,fixture,"doorway-native-front",[front],front.position+front.forward*3+Vector3.UP*2+front.forward.cross(Vector3.UP)*3,front.exit.position)
		await capture(cases,owner,shell,fixture,"doorway-native-back",[visual_back],visual_back.position+visual_back.forward*3+Vector3.UP*2+visual_back.forward.cross(Vector3.UP)*3,visual_back.exit.position)
	cases.check("doorway selected original entrance","facade-front",front.entrance.record)
	cases.check("doorway route cannot retarget","route_mismatch",owner.marker_candidate(result.ticket,"a-back").kind)
	cases.check("doorway bound geometry readiness",true,owner.readiness(result.ticket).binding_ready)
	cases.check("doorway inspection cannot become arrival","route_mismatch",owner.marker_candidate(result.ticket,"b-front").kind)
	var reconstruction := {"source_observation_sha256":FileAccess.get_sha256("res://tests/location_doorway_observation.json"),"marker":front.marker,"position":[front.position.x,front.position.y,front.position.z],"forward":[front.forward.x,front.forward.y,front.forward.z]}
	var path: String = str(fixture.sandbox).path_join("doorway-reconstruction.json")
	if reload:
		var stored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		cases.check("doorway fresh-process reconstruction",true,stored.source_observation_sha256 == reconstruction.source_observation_sha256 and stored.marker == reconstruction.marker and Frame.vector(stored.position).distance_to(front.position) < Frame.POSITION_TOLERANCE and Frame.vector(stored.forward).distance_to(front.forward) < Frame.NORMAL_TOLERANCE)
		return
	cases.write(path,JSON.stringify(reconstruction))
	var reordered_alias: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#tavern-alias-reordered",tavern_area))
	cases.check("doorway forward alias prepares",true,reordered_alias.ok)
	var reordered_selection: Dictionary = owner.marker_candidate(reordered_alias.ticket,"tavern-courtyard")
	cases.check("doorway forward alias stable destination",true,reordered_selection.marker.record == "record-00271" and reordered_selection["return"].plane == 46 and reordered_alias.doors[reordered_selection.exit.id].link == "tavern-rear")
	var invalid_alias: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#tavern-alias-bad-guard",{"kind":"exterior"}))
	cases.check("doorway alias resource guard rejects",false,invalid_alias.ok)
	cases.check("doorway alias guard failure retains context",true,owner.readiness(reordered_alias.ticket).ok and owner._stage.is_empty())
	invalid_alias = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#tavern-alias-wrong-building",{"kind":"exterior"}))
	cases.check("doorway alias cannot cross building",false,invalid_alias.ok)
	cases.check("doorway alias building failure retains context",true,owner.readiness(reordered_alias.ticket).ok and owner._stage.is_empty())
	# Resume the original selected arrival for the inherited consumer/lifetime cases.
	input = cases.area_request(owner,"packs/location.test#doorways",input.area)
	input.arrival = {"route":"a-front","kind":"doorway","doorway":"a-front"}
	result = await cases.assemble(owner,input)
	front = owner.marker_candidate(result.ticket,"a-front")
	var allowed := func(value: Dictionary): return {"ok":true,"handoff_id":value.handoff_id}
	var pending := func(value: Dictionary): return {"kind":"pending","handoff_id":value.handoff_id,"marker":value.marker,"frame":value.frame}
	var checked: Dictionary = owner.check_marker_candidate(result.ticket,"a-front",0,allowed,pending)
	cases.check("doorway actual marker consumer interface","placement_pending",checked.kind)
	cases.check("doorway checked selection independent of MOVE",front.marker,checked.marker)
	cases.check("doorway provider cannot commit pose",false,checked.placement_committed)
	cases.check("doorway unavailable MOVE","placement_provider_unavailable",owner.check_marker_candidate(result.ticket,"a-front",0,allowed,Callable()).kind)
	cases.check("doorway access rejection","access_rejected",owner.check_marker_candidate(result.ticket,"a-front",0,func(_value: Dictionary): return {"ok":false},pending).kind)
	cases.check("doorway duplicate request",result.ticket,owner.begin(input).ticket)
	var retargeted: Dictionary = input.duplicate(true)
	retargeted.arrival = {"route":"a-back","kind":"doorway","doorway":"a-back"}
	cases.check("doorway reused request cannot change selection","invalid",owner.begin(retargeted).kind)
	var back_request: Dictionary = cases.area_request(owner,"packs/location.test#doorways",input.area)
	back_request.arrival = {"route":"a-back","kind":"doorway","doorway":"a-back"}
	var back_arrival: Dictionary = await cases.assemble(owner,back_request)
	var back_selected: Dictionary = owner.marker_candidate(back_arrival.ticket,"a-back")
	cases.check("doorway entry through back retains shared instance",front.interior,back_selected.interior)
	cases.check("doorway entry through back selects own marker",true,back_selected.marker.record == "marker-back" and back_selected.position.distance_to(Vector3(-4.8,0,-11.2)) < Frame.POSITION_TOLERANCE and back_selected.forward.distance_to(Vector3.RIGHT) < Frame.NORMAL_TOLERANCE)
	var exit_request: Dictionary = cases.area_request(owner,"packs/location.test#doorways",{"kind":"exterior"})
	exit_request.arrival = {"route":"a-back","kind":"doorway","doorway":"a-back"}
	var exit_result: Dictionary = await cases.assemble(owner,exit_request)
	var exit_selected: Dictionary = owner.marker_candidate(exit_result.ticket,"a-back")
	cases.check("doorway exit through back selects own exterior",true,exit_selected.marker.record == "facade-back" and exit_selected.position.distance_to(Vector3(-7.4,1.125,-11.825)) < Frame.POSITION_TOLERANCE)
	cases.check("doorway exit preserves intended side","exterior",exit_selected.desired_context.doorway_side)
	input = cases.area_request(owner,"packs/location.test#doorways",{"kind":"interior","placement":"a","building":"hall","instance":"a-suite"})
	result = await cases.assemble(owner,input)
	front = owner.marker_candidate(result.ticket,"a-front")
	var back: Dictionary = owner.marker_candidate(result.ticket,"a-back")
	cases.check("doorway front back share instance",front.interior,back.interior)
	cases.check("doorway independent exit destinations",true,front["return"].record != back["return"].record)
	cases.check("doorway verified rest retains original role",true,owner.marker_candidates(result.ticket,"a-suite","rest").records[0].roles.has("rest"))
	cases.check("doorway verified rest gains entry role",2,owner.marker_candidates(result.ticket,"a-suite","entry").records.size())
	cases.check("doorway inspection handoff rejected","route_intent_pending",owner.check_marker_candidate(result.ticket,"a-front",0,allowed,pending).kind)
	cases.check("doorway other instance rejects","incompatible_binding",owner.marker_candidate(result.ticket,"b-front").kind)
	var saved_ticket: Dictionary = result.ticket
	for variant in ["missing","missing-exit","incompatible","wrong-side","out-of-frame","coincident","replaced-guard"]:
		var failed: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-"+variant,{"kind":"exterior"}))
		cases.check("doorway reject "+variant,false,failed.ok)
		cases.check("doorway rollback "+variant,true,owner.readiness(saved_ticket).ok and owner._stage.is_empty())
		cases.check("doorway failure diagnostic "+variant,true,failed.reason.contains("Doorway") and failed.reason.contains("->"))
	var selected: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-selected",{"kind":"exterior"}))
	cases.check("doorway explicit coincident selector qualifies",true,selected.ok)
	var authored_replacement: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-replaced-authored",{"kind":"exterior"}))
	cases.check("doorway authored guard ignores retained classic provenance",true,authored_replacement.ok)
	var duplicate: Dictionary = observation.declaration.duplicate(true)
	duplicate.links.append(duplicate.links[0].duplicate(true))
	cases.check("doorway ambiguous declarations reject publication",true,not preload("res://scripts/data/location_doorway_schema.gd").reason(duplicate).is_empty())
	var alias_schema = preload("res://scripts/data/location_doorway_schema.gd")
	var aliases: Dictionary = observation.declaration.duplicate(true)
	aliases.links.reverse()
	cases.check("doorway forward alias schema valid","",alias_schema.reason(aliases))
	aliases.links[0].entry_alias_of = "absent"
	cases.check("doorway missing alias target rejects",true,not alias_schema.reason(aliases).is_empty())
	aliases.links[0].entry_alias_of = aliases.links[0].id
	cases.check("doorway self alias rejects",true,not alias_schema.reason(aliases).is_empty())
	aliases = observation.declaration.duplicate(true)
	var chained: Dictionary = aliases.links[-1].duplicate(true)
	chained.id = "chained-entry"
	chained.exterior.plane = 0
	chained.entry_alias_of = "tavern-courtyard"
	aliases.links.append(chained)
	cases.check("doorway chained alias rejects",true,not alias_schema.reason(aliases).is_empty())
	aliases.links[-2].entry_alias_of = "chained-entry"
	cases.check("doorway cyclic aliases reject",true,not alias_schema.reason(aliases).is_empty())
	var real_variants: RefCounted = owner.variants
	var changed_variant := ChangedDoorways.new()
	changed_variant.input = owner.layouts.location_inputs(owner.registry,"packs/location.test#doorways")
	changed_variant.input.data.location_assembly.doorways.links[0].outside_offset = [3,0,0]
	owner.variants = changed_variant
	var rejected_variant: Dictionary = owner.begin(cases.area_request(owner,"packs/location.test#doorways",{"kind":"exterior"}))
	owner.variants = real_variants
	cases.check("doorway changed variant binding remains gated","provider_pending",rejected_variant.kind)
	var other: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways",{"kind":"interior","placement":"b","building":"hall","instance":"b-suite"}))
	var other_front: Dictionary = owner.marker_candidate(other.ticket,"b-front")
	cases.check("doorway independent instance shared template",true,other_front.template == front.template and other_front.interior != front.interior)
	cases.check("doorway stale layout handoff","stale",owner.marker_candidate(saved_ticket,"a-front").kind)
	var exterior: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways",{"kind":"exterior"}))
	var before: Dictionary = owner.marker_candidate(exterior.ticket,"b-front")
	cases.check("doorway rotated exterior side",true,before.forward.distance_to(Vector3.FORWARD) < Frame.NORMAL_TOLERANCE and before.position.distance_to(Vector3(203.825,1.125,-7.4)) < Frame.POSITION_TOLERANCE)
	var reordered: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-reordered",{"kind":"exterior"}))
	var after: Dictionary = owner.marker_candidate(reordered.ticket,"b-front")
	cases.check("doorway reordered stable destination",before.position,after.position)
	var changed: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-override",{"kind":"exterior"}))
	var replaced: Dictionary = owner.marker_candidate(changed.ticket,"a-front")
	cases.check("doorway explicit override applied",true,absf(replaced.position.x-8.4) < Frame.POSITION_TOLERANCE)
	var precedence: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-precedence",{"kind":"exterior"}))
	var winner: Dictionary = preload("res://scripts/data/layout_inputs.gd").lookup(owner.registry,"packs/location.test#doorways-precedence")
	cases.check("doorway loose highest precedence","@loose",winner.record.winner.provider)
	cases.check("doorway mod contribution retained",true,winner.record.contributors.any(func(contributor: Dictionary): return contributor.provider == "location.test"))
	cases.check("doorway resolved loose binding reaches owner",true,absf(owner.marker_candidate(precedence.ticket,"a-front").position.x-8.9) < Frame.POSITION_TOLERANCE)
	var facing: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-authored-facing",{"kind":"interior","placement":"a","building":"hall","instance":"a-suite"}))
	cases.check("doorway authored facing remains independent",Vector3.BACK,owner.marker_candidate(facing.ticket,"a-front").forward)
	# Restore an exterior before the rollback/cancellation scenarios.
	precedence = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-precedence",{"kind":"exterior"}))
	changed = precedence
	cases.last_live_ticket = changed.ticket
	var cancelled: Dictionary = owner.begin(cases.area_request(owner,"packs/location.test#doorways",{"kind":"exterior"}))
	owner.step(cancelled.ticket)
	owner.cancel(cancelled.ticket)
	cases.check("doorway cancellation rejects late result","stale",(await owner.finish(cancelled.ticket)).kind)
	cases.check("doorway cancellation retains valid exterior",true,owner.readiness(changed.ticket).ok)
	var retire_request: Dictionary = cases.area_request(owner,"packs/location.test#doorways",{"kind":"exterior"})
	retire_request.arrival = {"route":"a-front","kind":"doorway","doorway":"a-front"}
	var retiring: Dictionary = await cases.assemble(owner,retire_request)
	var late_provider := func(value: Dictionary):
		owner.core.request({"id":"doorway-callback-retirement","mode":"new","origin":owner.core.snapshot().session,"selection":{}})
		owner.core.confirm(owner.core.ticket(),true)
		return {"kind":"pending","handoff_id":value.handoff_id,"marker":value.marker,"frame":value.frame}
	cases.check("doorway retirement during provider rejects late result","stale",owner.check_marker_candidate(retiring.ticket,"a-front",0,allowed,late_provider).kind)
	var unbound: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-unbound-scaling",{"kind":"exterior"}))
	cases.check("doorway scaling unbound preparation",true,unbound.ok)
	cases.observations.doorway_unbound_scaling = owner.measurements.duplicate(true)
	var scaling: Dictionary = await cases.assemble(owner,cases.area_request(owner,"packs/location.test#doorways-scaling",{"kind":"exterior"}))
	cases.check("doorway scaling bound preparation",true,scaling.ok)
	if scaling.ok:
		cases.observations.doorway_bound_scaling = owner.measurements.duplicate(true)
		cases.observations.doorway_bound_scaling.doorway_prepare_usec = scaling.doorway_prepare_usec
		cases.check("doorway scaling independent links",128,scaling.doorway_links.size())
		cases.check("doorway scaling block decode reuse",1,owner.measurements.unique_block_decodes)
		var started := Time.get_ticks_usec()
		var valid := true
		for index in 1000: valid = valid and owner.marker_candidate(scaling.ticket,"scale-63-back").ok
		cases.observations.doorway_bound_scaling.query_1000_usec = Time.get_ticks_usec()-started
		cases.check("doorway scaling indexed point queries",true,valid)
		cases.last_live_ticket = scaling.ticket

func capture(cases: RefCounted, owner: Node, shell: Control, fixture: Dictionary, label: String, selections: Array, eye: Vector3, target: Vector3) -> void:
	var overlay := Node3D.new()
	owner.add_child(overlay)
	for selected: Dictionary in selections:
		var mesh := ImmediateMesh.new()
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color(1,0.7,0.1)
		material.no_depth_test = true
		mesh.surface_begin(Mesh.PRIMITIVE_LINES,material)
		var points: PackedVector3Array = selected.exit.points
		for index in points.size():
			mesh.surface_add_vertex(points[index])
			mesh.surface_add_vertex(points[(index+1)%points.size()])
		mesh.surface_add_vertex(selected.position)
		mesh.surface_add_vertex(selected.position+selected.forward)
		mesh.surface_end()
		var visual := MeshInstance3D.new()
		visual.mesh = mesh
		overlay.add_child(visual)
		var sphere := MeshInstance3D.new()
		sphere.mesh = SphereMesh.new()
		sphere.mesh.radius = 0.1
		sphere.mesh.height = 0.2
		sphere.material_override = material
		overlay.add_child(sphere)
		sphere.position = selected.position
		var marker_label := Label3D.new()
		marker_label.text = "ENTRY: "+str(selected.marker.record)+"\nsource anchor / facing"
		marker_label.font_size = 38
		marker_label.pixel_size = 0.004
		marker_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker_label.no_depth_test = true
		overlay.add_child(marker_label)
		marker_label.position = selected.position+Vector3.UP*0.7
		var door_label := Label3D.new()
		door_label.text = "EXIT: "+str(selected.exit.record)+" / plane "+str(selected.exit.plane)
		door_label.font_size = 34
		door_label.pixel_size = 0.004
		door_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		door_label.no_depth_test = true
		overlay.add_child(door_label)
		door_label.position = selected.exit.position+Vector3.UP*1.8
	await cases.location_capture(owner,shell,fixture,label,eye,target)
	preload("res://scripts/loc/dungeon_geometry.gd").release(overlay)
