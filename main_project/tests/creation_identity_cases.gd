extends "res://tests/mod_cases.gd"
const Stock = preload("res://scripts/char/creation_identity_inputs.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")
const Name = preload("res://scripts/ui/character_name.gd")
const Reflex = preload("res://scripts/char/reflex_parameters.gd")
var name_calls := 0
var measurements: Dictionary = {}

func material() -> Dictionary:
	name_calls += 1
	var bytes := PackedByteArray(); bytes.resize(32); bytes.fill(name_calls%256)
	return {"ok":true,"material":bytes}

func qualify(shell: Control, fixture: Dictionary) -> Array[Dictionary]:
	sandbox = fixture.sandbox
	var provider := Stock.new()
	provider.definitions = shell.controller.providers.definitions
	provider.content = provider.definitions.content_ticket()
	provider.art = shell.controller.providers.creation_art
	var preparation_started := Time.get_ticks_usec()
	check("identity production preparation",true,provider.prepare().ok)
	measurements.preparation_usec = Time.get_ticks_usec()-preparation_started
	if provider.identity.is_empty(): return checks
	var schema := preload("res://scripts/data/creation_identity.gd").new()
	check("identity DATA schema","",schema.validate_record("stock",provider.identity))
	for pair in [["A",1],["e\u0301",1],["👩‍👩‍👧‍👦",1],["🇨🇦",1],["क्‍ष",1],["[b]A[/b]",8],["名 前",3]]:
		var checked := Name.validate(pair[0])
		check("identity grapheme "+str(pair[0]),pair[1],checked.get("count",-1))
	check("identity Unicode surrounding trim","Zoë",Name.validate("\u2003Zoë\u3000").get("value"))
	for text in [""," \u2003 ","a".repeat(32),"a\nb","a\tb","a\u202eb"]: check("identity invalid name "+text,false,Name.validate(text).ok)
	for grapheme in ["x","e\u0301","👩‍👩‍👧‍👦","🇨🇦"]:
		check("identity boundary 31 "+grapheme,true,Name.validate(grapheme.repeat(31)).ok)
		check("identity boundary 32 "+grapheme,false,Name.validate(grapheme.repeat(32)).ok)
	for index in Reflex.IDS.size():
		var id: String = Reflex.IDS[index]
		var p: Dictionary = provider.identity.reflexes[id]
		check("identity reflex table "+id,[index,450*(index-2),50-10*(index-2),65536-(index-2)*8192],[p.classic,p.timer_adjustment,p.component_percent,p.practice_q16])
		check("identity practice eight "+id,10-index,Reflex.effective_practice(8,p).value)
		check("identity practice rounding "+id,(3*p.practice_q16)>>16,Reflex.effective_practice(3,p).value)
		check("identity timer zero floor "+id,0.0,Reflex.melee_seconds(1500,1000,p).value)
	check("identity practice overflow rejected",false,Reflex.effective_practice(4398046511104,provider.identity.reflexes.average).ok)
	var tiny: Dictionary = provider.identity.reflexes.average.duplicate(true); tiny.practice_q16 = 1
	check("identity smallest positive practice description",true,Reflex.explanation(tiny).contains("0.000015"))
	var invalid := provider.identity.duplicate(true)
	invalid.reflexes.average.component_percent = 101
	check("identity invalid probability DATA rejection",true,not schema.validate_record("stock",invalid).is_empty())
	invalid = provider.identity.duplicate(true); invalid.reflexes.erase("average")
	check("identity missing reflex DATA rejection",true,not schema.validate_record("stock",invalid).is_empty())
	var owner := Draft.new()
	owner.bind(provider.content,provider.bindings()); owner.start(); provider.initialize_draft(owner)
	check("identity fresh Average default","average",owner.projection().selections.reflexes)
	check("identity default semantic provider",true,owner.section_status("reflexes").ok)
	for id in Reflex.IDS: check("identity owner reflex "+id,true,owner.edit("reflexes",owner.token(),id).ok)
	var before := owner.projection()
	check("identity invalid reflex rejected",false,owner.edit("reflexes",owner.token(),"missing").ok)
	check("identity invalid reflex preserves draft",before,owner.projection())
	provider.name_material = material
	var session_random: Dictionary = shell.session_shell.core.randomness.snapshot()
	for race in provider.policy.races:
		owner.edit("race",owner.token(),race)
		for gender in ["male","female"]:
			owner.edit("gender",owner.token(),gender)
			var prefix: String = race+"/"+gender
			var set := provider.face_set(owner.projection().selections)
			check("identity classic portrait count "+prefix,10,set.faces.size())
			for index in set.faces.size():
				check("identity portrait select "+prefix+"/"+str(index),true,provider.cycle_face(owner,owner.token(),1).ok)
				check("identity classic portrait mapping "+prefix+"/"+str(index),index,owner.projection().validated.face.provenance.definition.classic)
			check("identity portrait next wrap "+prefix,true,provider.cycle_face(owner,owner.token(),1).ok)
			check("identity portrait wrapped first "+prefix,"classic-00",owner.projection().selections.face.id)
			provider.cycle_face(owner,owner.token(),-1)
			check("identity portrait previous wrap "+prefix,"classic-09",owner.projection().selections.face.id)
			check("identity random deliberate "+prefix,true,provider.random_name(owner,owner.token()).ok)
			check("identity random valid "+prefix,true,Name.validate(owner.projection().selections.get("name")).ok)
			check("identity random explicit culture "+prefix,provider.identity.mappings[prefix].bank,owner.projection().retained.name.get("generation",{}).get("bank"))
	var retained := owner.projection()
	var calls := name_calls
	for index in 20: owner.section_status("name"); owner.section_status("face"); owner.section_status("reflexes")
	check("identity revalidation draws nothing",calls,name_calls)
	check("identity revalidation retains draft",retained,owner.projection())
	provider.identity.mappings["argonian/female"].bank = "missing-culture"
	check("identity missing culture generation rejected",false,provider.random_name(owner,owner.token()).ok)
	check("identity missing culture preserves assigned name",retained,owner.projection())
	provider.identity.mappings["argonian/female"].bank = "Imperial"
	provider.name_material = func(): return {"ok":false}
	check("identity random entropy failure",false,provider.random_name(owner,owner.token()).ok)
	check("identity random failure preserves draft",retained,owner.projection())
	var reentrant: Array = []
	provider.name_material = func():
		reentrant.append(provider.random_name(owner,owner.token()))
		return {"ok":false}
	provider.random_name(owner,owner.token())
	check("identity reentrant name generation rejected busy","busy",reentrant[0].kind)
	check("identity naming leaves session streams unchanged",session_random,shell.session_shell.core.randomness.snapshot())
	var cost: Dictionary = provider.art.measurements.duplicate(true)
	var queries_started := Time.get_ticks_usec()
	var queried_face: Dictionary = owner.projection().selections.face
	for index in 1000: provider.portrait(queried_face)
	measurements.thousand_portrait_queries_usec = Time.get_ticks_usec()-queries_started
	check("identity repeated portrait queries do not decode",cost.baseline_decodes,provider.art.measurements.baseline_decodes)
	check("identity repeated portrait queries do not create textures",cost.textures,provider.art.measurements.textures)
	measurements.classic_portrait_sources = shell.controller.providers.classic._portrait_files.size()
	measurements.static_memory_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
	check("identity manual name after generation failure",true,owner.edit("name",owner.token(),"  [b]Zoë[/b]  ").ok)
	check("identity owner trimmed literal name","[b]Zoë[/b]",owner.projection().selections.name)
	var selection: Dictionary = owner.projection().selections.face
	var set_id: String = selection.set
	provider.identity.portraits[set_id].reverse()
	check("identity reorder preserves selected ID",true,owner.section_status("face").ok)
	provider.identity.portraits[set_id].append({"id":"mod-added","classic":-1,"target":provider.identity.portraits[set_id][0].target})
	check("identity mod expanded portrait schema","",schema.validate_record("stock",provider.identity))
	check("identity mod explicit new portrait",true,owner.edit("face",owner.token(),{"set":set_id,"id":"mod-added"}).ok)
	provider.identity.portraits[set_id].pop_back()
	check("identity missing selected portrait blocks completion",false,owner.section_status("face").ok)
	check("identity missing portrait explicit replacement",true,provider.cycle_face(owner,owner.token(),1).ok)
	provider.identity.mappings["argonian/male"].portraits = set_id
	var compatible: Dictionary = owner.projection().selections.face
	owner.edit("gender",owner.token(),"male")
	check("identity explicitly compatible upstream choice retains face",compatible,owner.projection().selections.get("face"))
	owner.edit("race",owner.token(),"breton")
	check("identity incompatible upstream choice clears face",false,owner.projection().selections.has("face"))
	owner.start(); provider.initialize_draft(owner)
	owner.edit("race",owner.token(),"breton"); owner.edit("gender",owner.token(),"female")
	var recovery_set := provider.face_set(owner.projection().selections)
	var broken_target: String = recovery_set.faces[0].target
	var original_image: Dictionary = provider.art._textures[broken_target]
	provider.art._textures[broken_target] = {"ok":false,"reason":"Controlled required portrait image failure."}
	check("identity explicit browse skips unavailable initial image",true,provider.cycle_face(owner,owner.token(),1).ok)
	check("identity unavailable first portrait cannot trap selector",recovery_set.faces[1].id,owner.projection().selections.face.id)
	provider.art._textures[broken_target] = original_image
	var stale := owner.token(); owner.discard(); owner.start(); provider.initialize_draft(owner)
	check("identity retired random operation",false,provider.random_name(owner,stale).ok)
	check("identity Restart default restored","average",owner.projection().selections.reflexes)
	owner.dispose()
	provider.name_material = Callable()
	return checks
