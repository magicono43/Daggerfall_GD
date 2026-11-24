extends RefCounted

func physical() -> Dictionary:
	return {"intent":"doorway","mode":"standing","transport":"foot","effects":[],"fall_history":{},"velocity":Vector3.ZERO,"posture":"standing"}

func run(cases: RefCounted, owner: Node, shell: Control, fixture: Dictionary) -> void:
	var move: Node3D = shell.session_shell.placement
	cases.check("placement normal MOVE composition",true,move != null and move.assembly == owner and move.core == owner.core)
	var policy: Dictionary = move.baseline_policy()
	cases.check("placement profile validates",true,move.policy_valid(policy))
	await preload("res://tests/placement_physics_cases.gd").new().run(cases,move)
	var bad := policy.duplicate(true)
	bad.offsets = [Vector3(100,0,0)]
	cases.check("placement unbounded policy rejects",false,move.policy_valid(bad))
	var precedence: Dictionary = cases.area_request(owner,"packs/location.test#doorways-precedence",{"kind":"exterior"})
	precedence.arrival = {"route":"a-front","kind":"doorway","doorway":"a-front"}
	var published: Dictionary = await cases.assemble(owner,precedence)
	cases.check("placement policy override assembly",true,published.ok)
	if published.ok: cases.check("placement policy loose beats MOD",0.26,owner.marker_candidate(published.ticket,"a-front").placement_policy.radius)
	var observed: Array = []
	for route in ["home-east","home-north","tavern-front","tavern-rear","tavern-courtyard"]:
		var building := "building-0000" if route == "home-east" else "building-0001" if route == "home-north" else "building-0002"
		var input: Dictionary = cases.area_request(owner,"packs/classic#place-00001",{"kind":"interior","placement":"place-00001","building":building,"instance":building+"-interior"})
		input.area.placement = cases.doorway_cases.observation.declaration.interiors[0].placement
		input.arrival = {"route":route,"kind":"doorway","doorway":route}
		var assembled: Dictionary = await cases.assemble(owner,input)
		cases.check("placement classic assembly "+route,true,assembled.ok)
		if not assembled.ok: continue
		await owner.get_tree().physics_frame
		await owner.get_tree().physics_frame
		var value: Dictionary = owner.marker_candidate(assembled.ticket,route)
		var result: Dictionary = move.validate(value,physical())
		observed.append({"route":route,"result":result})
		var expected: Vector3 = {"home-east":Vector3(4.8,0.91,-1.29),"home-north":Vector3(1.29,0.91,4.8),"tavern-front":Vector3(-1.91,0.91,-4.8),"tavern-rear":Vector3(-1.91,0.91,8),"tavern-courtyard":Vector3(-1.91,0.91,8)}[route]
		cases.check("placement independent actor centre "+route,true,result.get("position",Vector3.INF).distance_to(expected) < 0.00001)
		cases.check("placement full shape checked "+route,true,result.kind in ["exact","corrected","rejected"] and result.has("attempts"))
		var unsupported := physical()
		unsupported.mode = "falling"
		cases.check("placement falling unavailable "+route,"physical_owner_unavailable",move.validate(value,unsupported).reason)
		cases.check("placement validation cannot commit "+route,false,move.snapshot().get("placement_committed",false))
		var accepted: Dictionary = owner.check_marker_candidate(assembled.ticket,route,0,func(v: Dictionary): return {"ok":true,"handoff_id":v.handoff_id},func(v: Dictionary): return move.validate(v,physical()))
		cases.check("placement real scoped consumer "+route,true,accepted.kind in ["placement_exact","placement_corrected","placement_rejected"])
		if DisplayServer.get_name() != "headless" and route in ["home-east","tavern-courtyard"] and result.kind in ["exact","corrected"]:
			await capture(cases,owner,shell,fixture,route,value,result)
	cases.observations.placement = observed
	for route in ["a-front","b-front","b-back"]:
		var request: Dictionary = cases.area_request(owner,"packs/location.test#doorways-reordered",{"kind":"exterior"})
		request.arrival = {"route":route,"kind":"doorway","doorway":route}
		var assembly: Dictionary = await cases.assemble(owner,request)
		cases.check("placement authored reordered assembly "+route,true,assembly.ok)
		if not assembly.ok: continue
		await owner.get_tree().physics_frame
		await owner.get_tree().physics_frame
		var value: Dictionary = owner.marker_candidate(assembly.ticket,route)
		var checked: Dictionary = move.validate(value,physical())
		# The authored back facade is at negative local X, outside this fixture's
		# ground tile [0,102.4] X footprint. Rotation must preserve that failure.
		cases.check("placement authored rotated shape "+route,"rejected" if route == "b-back" else "exact",checked.kind)
		if route == "b-back": cases.check("placement rotated missing ground remains explicit","missing_ground",checked.get("attempts",[{}])[0].get("reason"))
		cases.check("placement authored instance identity "+route,route.left(1),value.interior.placement)
	var raised: Dictionary = cases.area_request(owner,"packs/location.test#placement-raised",{"kind":"interior","placement":"a","building":"hall","instance":"a-suite"})
	raised.arrival = {"route":"a-front","kind":"doorway","doorway":"a-front"}
	var assembled: Dictionary = await cases.assemble(owner,raised)
	cases.check("placement raised assembly",true,assembled.ok)
	if assembled.ok:
		await owner.get_tree().physics_frame
		await owner.get_tree().physics_frame
		var value: Dictionary = owner.marker_candidate(assembled.ticket,"a-front")
		var result: Dictionary = move.validate(value,physical())
		cases.observations.placement_corrected = result
		cases.check("placement deterministic corrected success","corrected",result.kind)
		cases.check("placement exact attempted first",0,result.get("attempts",[{}])[0].get("index"))
		if result.kind == "corrected":
			cases.check("placement ordered candidate index",2,result.provenance.candidate)
			cases.check("placement correction displacement",true,result.provenance.displacement.distance_to(Vector3(0,-0.025,0)) < 0.000001)
			cases.check("placement correction preserves intended side",true,move._side(value,result.position,0.305))
		var no_candidates: Dictionary = move.baseline_policy()
		no_candidates.offsets = []
		cases.check("placement exhausted budget checked failure","candidate_budget_exhausted",move.validate(value,physical(),no_candidates).reason)
		var forged: Dictionary = value.duplicate(true)
		forged.position += Vector3(1,0,0)
		cases.check("placement forged anchor rejects","stale",move.validate(forged,physical()).reason)
		if DisplayServer.get_name() != "headless" and result.kind == "corrected": await capture(cases,owner,shell,fixture,"corrected",value,result)
	await commitments(cases,owner,move)

func commitments(cases: RefCounted, owner: Node, move: Node3D) -> void:
	var core: RefCounted = owner.core
	var provider: RefCounted = core.provider
	provider.hold_preflight = true
	provider.hold_readiness = true
	for step in 4:
		var route := "tavern-courtyard" if step == 0 else "tavern-front" if step == 2 else "tavern-rear"
		var entering := step%2 == 0
		var id := "placement-crossing-%d" % step
		cases.check(id+" original request","pending",core.request({"id":id,"mode":"new","origin":core.snapshot().session,"selection":{}}).kind)
		var original: Dictionary = core.ticket()
		var area := {"kind":"interior","placement":"placement-00000","building":"building-0002","instance":"building-0002-interior"} if entering else {"kind":"exterior"}
		var input: Dictionary = cases.area_request(owner,"packs/classic#place-00001",area)
		input.core_ticket = original
		input.session = original.scope
		input.arrival = {"route":route,"kind":"doorway","doorway":route}
		var assembled: Dictionary = await cases.assemble(owner,input)
		cases.check(id+" prepared geometry",true,assembled.ok)
		if not assembled.ok:
			core.cancel(original)
			continue
		var before: Dictionary = owner.marker_candidate(assembled.ticket,route)
		var checked: Dictionary = move.validate(before,physical())
		cases.check(id+" preparation cannot commit","activation_pending_or_stale",move.commit(before,checked,Callable()).reason)
		core.complete_preflight(original,{"ok":true})
		core.confirm(original,true)
		owner.activate(assembled.ticket)
		await owner.get_tree().physics_frame
		await owner.get_tree().physics_frame
		var value: Dictionary = owner.marker_candidate(assembled.ticket,route)
		checked = move.validate(value,physical())
		if checked.kind == "rejected": print("PLACEMENT CROSSING DIAGNOSTIC ",id," ",checked," original=",original," ticket=",value.get("ticket"))
		cases.check(id+" shape outcome","exact" if entering else "corrected",checked.kind)
		var result: Dictionary = move.commit(value,checked,func(v: Dictionary): return {"ok":true,"handoff_id":v.handoff_id})
		cases.check(id+" real pose committed",true,result.get("placement_committed",false))
		var state: Dictionary = move.snapshot()
		cases.check(id+" selected entrance retained",41 if step == 0 else 36 if step == 2 else 46,state.get("entrance",{}).get("plane"))
		cases.check(id+" canonical return retained",36 if step == 2 else 46,state.get("return",{}).get("plane"))
		cases.check(id+" correct movement space","interior" if entering else "exterior",state.get("desired_context",{}).get("doorway_side"))
		cases.check(id+" original CORE still gated",true,core.snapshot().phase == "initializing" and not core.gates.gameplay_input() and core.gates.blocked("save"))
		# Controlled lifecycle only. This is not a claim that WORLD/CHAR/etc exist.
		core.complete_readiness(core.ticket(),{"ok":true,"services":provider.bindings(),"death_authority":provider})
	provider.hold_preflight = false
	provider.hold_readiness = false
	await interruptions(cases,owner,move)

func interruptions(cases: RefCounted, owner: Node, move: Node3D) -> void:
	var core: RefCounted = owner.core
	var provider: RefCounted = core.provider
	provider.hold_preflight = true
	provider.hold_readiness = true
	var saved: Dictionary = move.snapshot()
	core.request({"id":"placement-cancel","mode":"new","origin":core.snapshot().session,"selection":{}})
	var original: Dictionary = core.ticket()
	var input: Dictionary = cases.area_request(owner,"packs/classic#place-00001",{"kind":"exterior"})
	input.core_ticket = original
	input.session = original.scope
	input.arrival = {"route":"tavern-rear","kind":"doorway","doorway":"tavern-rear"}
	var prepared: Dictionary = await cases.assemble(owner,input)
	var value: Dictionary = owner.marker_candidate(prepared.ticket,"tavern-rear")
	core.cancel(original)
	cases.check("placement cancellation preserves source pose",saved,move.snapshot())
	cases.check("placement cancelled handoff rejects","stale",move.validate(value,physical()).reason)
	core.request({"id":"placement-retire-callback","mode":"new","origin":core.snapshot().session,"selection":{}})
	original = core.ticket()
	input = cases.area_request(owner,"packs/classic#place-00001",{"kind":"exterior"})
	input.core_ticket = original
	input.session = original.scope
	input.arrival = {"route":"tavern-rear","kind":"doorway","doorway":"tavern-rear"}
	prepared = await cases.assemble(owner,input)
	core.complete_preflight(original,{"ok":true})
	core.confirm(original,true)
	owner.activate(prepared.ticket)
	await owner.get_tree().physics_frame
	await owner.get_tree().physics_frame
	value = owner.marker_candidate(prepared.ticket,"tavern-rear")
	var checked: Dictionary = move.validate(value,physical())
	var result: Dictionary = move.commit(value,checked,func(v: Dictionary):
		core.complete_readiness(core.ticket(),{"ok":false,"reason":"Placement fixture retires unavailable destination during access callback."})
		return {"ok":true,"handoff_id":v.handoff_id})
	cases.check("placement retirement callback rejects late commit","stale",result.reason)
	cases.check("placement retirement leaves no actor pose",{},move.snapshot())
	cases.check("placement lost source never claims rollback",true,core.snapshot().session.is_empty())
	provider.hold_preflight = false
	provider.hold_readiness = false
	core.request({"id":"placement-post-recovery-fixture","mode":"new","origin":"","selection":{}})

func capture(cases: RefCounted, owner: Node, shell: Control, fixture: Dictionary, label: String, value: Dictionary, result: Dictionary) -> void:
	var overlay := Node3D.new()
	owner.add_child(overlay)
	var actor := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = result.policy.radius
	mesh.height = result.policy.height
	actor.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.1,1,0.4,0.55)
	material.no_depth_test = true
	actor.material_override = material
	overlay.add_child(actor)
	actor.position = result.position
	var text := Label3D.new()
	text.text = "%s: full capsule r=0.30m h=1.80m\n%s side; candidate %d\nanchor conversion %s" % [result.kind,value.desired_context.doorway_side,result.provenance.candidate,str(result.conversion.aperture_adjustment)]
	text.font_size = 28
	text.pixel_size = 0.003
	text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text.no_depth_test = true
	overlay.add_child(text)
	text.position = result.position+Vector3.UP*2.2
	await cases.doorway_cases.capture(cases,owner,shell,fixture,"placement-"+label,[value],result.position+value.exit.normal*4+Vector3.UP*2+value.exit.normal.cross(Vector3.UP)*3,result.position)
	preload("res://scripts/loc/dungeon_geometry.gd").release(overlay)
