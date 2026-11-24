extends "res://tests/text_cases.gd"
const Baseline = preload("res://scripts/data/actor_baseline.gd")
const ActorEntry = preload("res://tests/controlled_actor_entry.gd")
const ActorSource = preload("res://tests/controlled_actor_source.gd")
var actors: RefCounted
var actor_core: SessionLifecycle
var scope := ""
var original := {}
var bindings: Array = []
var source_a := ActorSource.new()
var source_b := ActorSource.new()
var observations := {}

func adapter_names(registry: RefCounted) -> Array:
	var names: Array = registry._adapters.keys()
	names.sort()
	return names

func captured(id: String) -> Dictionary:
	var attributes := {}
	var skills := {}
	for key in Baseline.ATTRIBUTES: attributes[key] = 50
	for key in Baseline.SKILLS: skills[key] = 10
	skills["added-skill"] = 10
	attributes.strength = 95
	attributes.intelligence = 51
	return {"schema":"captured-actor-v1","actor":id,"level":1,"career":"class-00","identity":{"name":"Controlled capture","race":"breton","gender":"female","portrait":"fixture-portrait","reflexes":"average","biography":"biog00t0","creation_receipt":"controlled-capture-v1"},"choices":{"template":"fixture","answers":[],"outcomes":[],"custom_career":{}},"attributes":attributes,"skills":skills,"policy":{"schema":"captured-progression-policy-v1","mode":"vanilla-ranked-v1"},"initialization":{"skills_finalized":true,"grants":"external-owner-pending"}}

func c(id: String, kind: String, target: String, value: Variant) -> Dictionary:
	return {"id":id,"kind":kind,"target":target,"value":value}
func current(id := "player") -> Dictionary:
	return actors.projection(scope,id)
func update() -> Dictionary:
	var view := current()
	return actors.reconcile(scope,original,"player",view.record.revision,view.record.content)
func save_record() -> Dictionary:
	return current().record

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller: RefCounted = shell.controller
	var registry: RefCounted = controller.providers.definitions
	actor_core = shell.session_shell.core
	actors = actor_core.actors
	check("normal CHAR composed",true,actors != null and actors.definitions == registry)
	check("unpublished actor rejected",false,actors.fresh("absent",{},captured("early"),{},[]).ok)
	controller.settings.effective["startup/show_setup"] = true
	# Checked data-only MOD tier followed by captured loose policy. No semantic
	# actor-input readiness flag is changed to qualify the focused owner subset.
	var callbacks := preload("res://tests/actor_formula_callbacks.gd").new()
	var policy_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/actors/baseline.json")).entries[0].value
	var packaged := manifest("actor.formula")
	packaged.content = ["actor-policy.json"]
	packaged.capabilities = ["data.actor-baseline-v1"]
	write(controller.mods.root.path_join("Mods/Actor/mod.json"),JSON.stringify(packaged))
	policy_data.attributes.strength.max = 150
	write(controller.mods.root.path_join("Mods/Actor/actor-policy.json"),JSON.stringify({"domain":Baseline.DOMAIN,"path":"policy","operation":"patch","entries":[{"id":"player","value":policy_data}]}))
	controller.mods.rescan()
	controller.mods.edit("actor.formula","toggle")
	policy_data.attributes.strength.max = 200
	policy_data.skills["added-skill"] = {"min":0,"max":200}
	write(controller.mods.root.path_join("Overrides/actor-policy.json"),JSON.stringify({"domain":Baseline.DOMAIN,"path":"policy","operation":"patch","entries":[{"id":"player","value":policy_data}]}))
	controller.providers.formulas.stage("actor.formula","1.0.0",[{"hook":"char.damage","contract":"integer-formula-v1","callback":callbacks.integer}])
	var started := Time.get_ticks_usec()
	controller.select_folder(fixture.classic_source)
	observations.selection_usec = Time.get_ticks_usec()-started
	observations.publication_phases = registry.timings.duplicate(true)
	check("incompatible actor formula candidate rejected",false,controller.prepared_content.ok)
	check("rejected candidate leaves DATA unpublished",-1,registry.content_ticket())
	var failed_hooks: Dictionary = controller.providers.formulas.projection()
	check("invalid hook cannot publish winners",{},failed_hooks.winners)
	check("explicit invalid provider omission",true,controller.providers.formulas.omit("actor.formula",failed_hooks.ticket,controller.mods).ok)
	controller.check_content()
	check("recovered builtin candidate",true,controller.prepared_content.ok)
	var valid_data_ticket: int = controller.prepared_content.ticket
	var prepare_serial: int = registry.timings.prepare_serial
	controller.providers.formulas.replace_stage("actor.formula","1.0.0",[{"hook":"char.damage","contract":"integer-formula-v1","callback":callbacks.integer}])
	started = Time.get_ticks_usec()
	controller.check_content()
	observations.invalid_hook_recheck_usec = Time.get_ticks_usec()-started
	check("invalid hook recheck skips unchanged DATA",prepare_serial,registry.timings.prepare_serial)
	check("invalid hook preserves prior DATA candidate",true,registry.check_commit(valid_data_ticket,controller.mods).ok)
	# Repair the declaration through the production pre-lock interface.
	controller.providers.formulas.replace_stage("actor.formula","1.0.0",[{"hook":"char.damage","contract":"actor-rational-v1","callback":callbacks.damage}])
	controller.check_content()
	check("full candidate validates",true,controller.prepared_content.ok)
	check("ordinary adapters retained",["actor.baseline","actor.inputs","faction-quest.inputs","geography.inputs","item-spell.inputs","layout.inputs","media.assets","mod.preferences","text.catalogs","text.fonts","world.variants"],adapter_names(registry))
	check("actual menu publication",true,controller.continue_to_menu("run").ok)
	observations.final_publication_phases = registry.timings.duplicate(true)
	check("typed gameplay provider selected","actor.formula",controller.providers.formulas.active().winners["char.damage"])
	check("typed gameplay signature locked","actor-rational-v1",controller.providers.formulas.active().hook_contracts["char.damage"])
	var published_policy: Dictionary = registry.query(Baseline.DOMAIN,"policy","player").record
	check("numeric loose policy wins last",["@loose",200],[published_policy.winner.provider,int(published_policy.value.attributes.strength.max)])
	check("numeric MOD provenance retained",true,published_policy.contributors.any(func(p): return p.provider == "actor.formula"))
	check("numeric shipped provenance retained",true,published_policy.contributors.any(func(p): return p.provider == "@shipped/actor-baseline-v1"))
	shell.render() # Stock synchronization admits the actual checked menu route.
	check("stock missing entry remains unavailable","Failed",actor_core.request({"id":"missing-entry","mode":"new","origin":""}).kind)
	var provider := ActorEntry.new()
	actor_core.provider = provider
	var unrelated: int = actor_core.gates.acquire("unrelated-review","",["simulation"])
	check("controlled entry holds baseline","pending",actor_core.request({"id":"actor-baseline","mode":"new","origin":""}).kind)
	scope = actor_core.snapshot().session
	original = actor_core.ticket()
	check("baseline still gated",["baseline",false],[actor_core.snapshot().phase,actor_core.snapshot().ready])
	bindings = [{"id":"item-resolved","provider":source_a},{"id":"magic-resolved","provider":source_b}]
	var clock := {"provider":"controlled-clock-v1","unit":"game-millisecond","instant":0}
	var bad_actor := captured("bad-actor")
	bad_actor.actor = true
	var bad_clock := clock.duplicate(true)
	bad_clock.unit = &"game-millisecond"
	var bad_receipt := captured("bad-receipt")
	bad_receipt.initialization.skills_finalized = 1
	check("strict actor identity clock and receipt types",[false,false,false],[actors.fresh(scope,original,bad_actor,clock,[]).ok,actors.fresh(scope,original,captured("bad-clock"),bad_clock,[]).ok,actors.fresh(scope,original,bad_receipt,clock,[]).ok])
	var draft := captured("player")
	var rng_before: Dictionary = actor_core.randomness.snapshot()
	var created: Dictionary = actors.fresh(scope,original,draft,clock,bindings)
	check("fresh construction accepted",true,created.ok)
	if not created.ok: return {"ok":false,"checks":checks,"count":checks.size(),"fixture":"IMP-016-actor-state-v1","engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"failure":created}
	check("fresh base health",31,current().record.base_health)
	check("source structural readiness remains false",false,registry.query("actor.inputs","catalog","format-profile").record.value.data.semantic_ready)
	var pinned: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/actor_state_observation.json"))
	for career_source in pinned.classes:
		check("pinned classic input "+career_source.id,career_source.sha256,registry.query("actor.inputs","catalog",career_source.id).record.value.input.sha256)
	check("fresh maxima and units",[{"health":31,"fatigue":9280,"magicka":102,"breath":25},"internal-64"],[current().derived.limits,current().derived.units.fatigue])
	check("fresh full three pools",{"health":31,"fatigue":9280,"magicka":102},current().record.current)
	check("breath remains activity pending",{"state":"uninitialized","reserve":null,"policy":"activity-owner-pending"},current().record.breath)
	check("ranked S0 after final skills",60,current().record.progression.s0)
	check("actual earned initialized",[1,1],[current().record.progression.actual_level,current().record.progression.earned_target])
	check("practice initialized zero",true,current().record.progression.practice.values().all(func(v): return v == 0))
	check("zero clock distinct from never trained",[clock,{"state":"never"}],[current().record.progression.last_advancement,current().record.progression.training])
	check("baseline is not entry readiness",[false,false],[current().entry_ready,actor_core.snapshot().ready])
	check("initial retry retained",created,actors.fresh(scope,original,draft,clock,bindings))
	var frozen := current()
	draft.attributes.strength = 0
	draft.choices.answers.append("external mutation")
	var copy := current()
	copy.record.attributes.strength = 0
	copy.derived.sources.clear()
	check("draft and projection isolation",frozen,current())
	check("second query is pure",current(),current())
	check("second actor independent",true,actors.fresh(scope,original,captured("other"),clock,[]).ok)
	source_a.contributions = [c("buff","attribute","strength",20)]
	source_a.revision += 1
	check("capped source accepted",true,update().ok)
	check("capped hidden raw retained",[95,115,100],[current().derived.attributes.strength.permanent,current().derived.attributes.strength.raw,current().derived.attributes.strength.live])
	check("shared template actor unchanged",95,current("other").derived.attributes.strength.live)
	source_a.contributions = []
	source_a.revision += 1
	check("remove source accepted",true,update().ok)
	check("95 plus20 removal returns95",95,current().derived.attributes.strength.live)
	source_a.contributions = [c("buff","attribute","strength",20),c("cap","cap","strength",50),c("penalty","skill","medical",-50)]
	source_b.contributions = [c("opposing","attribute","strength",-20),c("limiter","health-limiter","health",10),c("magicka","magicka","magicka",-1000)]
	source_a.revision += 1
	source_b.revision += 1
	check("coherent opposing batch accepted",true,update().ok)
	check("opposing sources preserved",[95,150,2],[current().derived.attributes.strength.live,current().derived.attributes.strength.cap,current().derived.sources.size()])
	check("signed live skills unclamped",-40,current().derived.skills.medical.live)
	check("limiter clamps only current above maximum",[31,10,10,0],[current().record.base_health,current().derived.limits.health,current().record.current.health,current().record.current.magicka])
	source_b.contributions = []
	source_b.revision += 1
	check("one source replacement accepted",true,update().ok)
	check("other source retained after replacement",[115,-40],[current().derived.attributes.strength.live,current().derived.skills.medical.live])
	check("increases never refill",[31,10,102,0],[current().derived.limits.health,current().record.current.health,current().derived.limits.magicka,current().record.current.magicka])
	var duplicate := current()
	check("duplicate source delivery unchanged",true,update().get("unchanged",false))
	source_a.contributions.reverse()
	check("reordered contribution delivery unchanged",true,update().get("unchanged",false))
	check("duplicate delivery no publication",duplicate,current())
	for bad in [c("bad","attribute","absent",1),c("bad","cap","strength",-1000),c("bad","skill","absent",1),c("bad","magicka","health",1),c("bad","health-limiter","health",0),c("bad","attribute","strength",1.5),c("bad","attribute","strength",INF),c("bad","attribute","strength",9223372036854775807),c("bad","attribute","strength",1000000000)]:
		var before := current()
		source_a.revision += 1
		source_a.contributions = [bad]
		var label: String = bad.kind+":"+bad.target+":"+str(bad.value)
		check("bad source rejected "+label,false,update().ok)
		check("bad source coherent "+label,before,current())
	source_a.contributions = [c("one","attribute","strength",1),c("one","attribute","strength",2)]
	source_a.revision += 1
	check("duplicate contribution identity rejected",false,update().ok)
	var status_before := JSON.stringify(current()).sha256_text()
	source_a.contributions = []
	source_a.revision += 1
	source_a.status = 1
	check("nonboolean source status rejected coherently",[false,status_before],[update().ok,JSON.stringify(current()).sha256_text()])
	source_a.status = true
	source_a.available = false
	check("required source unavailable",false,update().ok)
	source_a.available = true
	source_a.contributions = []
	source_a.revision = 0
	check("stale source revision rejected",false,update().ok)
	source_a.revision = 100
	check("source recovers with new revision",true,update().ok)
	var valid := current()
	source_a.contributions = [c("changed","attribute","strength",2)]
	check("changed same revision rejected",false,update().ok)
	check("same revision rejection preserves actor",valid,current())
	source_a.contributions = []
	check("stale actor revision",false,actors.reconcile(scope,original,"player",0,registry.content_ticket()).ok)
	check("stale content ticket",false,actors.reconcile(scope,original,"player",valid.record.revision,-1).ok)
	check("stale session ticket",false,actors.reconcile("old",original,"player",valid.record.revision,registry.content_ticket()).ok)
	check("stale operation ticket",false,actors.reconcile(scope,{"id":"old"},"player",valid.record.revision,registry.content_ticket()).ok)
	check("unknown actor explicit failure",false,actors.projection(scope,"absent").ok)
	for bad_field in ["attributes","skills","identity","policy","initialization","choices"]:
		var bad := captured("missing-"+bad_field)
		bad.erase(bad_field)
		check("missing creation "+bad_field,false,actors.fresh(scope,original,bad,clock,[]).ok)
	for bad_value in [-1,201,1.5,INF,9223372036854775807]:
		var bad := captured("invalid-permanent")
		bad.attributes.strength = bad_value
		check("invalid permanent "+str(bad_value),false,actors.fresh(scope,original,bad,clock,[]).ok)
	for bad_career in ["class-18","career-source-18","enemy-000","absent"]:
		var bad := captured("invalid-career")
		bad.career = bad_career
		check("unsupported career "+bad_career,false,actors.fresh(scope,original,bad,clock,[]).ok)
	var vanilla_bound := captured("vanilla-bound")
	vanilla_bound.attributes.endurance = 101
	check("vanilla attribute bounds still enforced",false,actors.fresh(scope,original,vanilla_bound,clock,[]).ok)
	vanilla_bound = captured("vanilla-skill-bound")
	vanilla_bound.skills.medical = 101
	check("vanilla skill bounds still enforced",false,actors.fresh(scope,original,vanilla_bound,clock,[]).ok)
	var bad_identity := captured("unknown-attribute")
	bad_identity.attributes.erase("luck")
	bad_identity.attributes["unapproved"] = 50
	check("unknown permanent identity rejected",false,actors.fresh(scope,original,bad_identity,clock,[]).ok)
	check("uninitialized clock rejected",false,actors.fresh(scope,original,captured("missing-clock"),{},[]).ok)
	var high_start := captured("higher-level")
	high_start.level = 2
	check("higher start needs explicit contract",false,actors.fresh(scope,original,high_start,clock,[]).ok)
	var policy: Dictionary = registry.query(Baseline.DOMAIN,"policy","player").record.value
	var adapter := Baseline.new()
	var extended := policy.duplicate(true)
	extended.attributes.strength.max = 200
	extended.attributes.strength.cap = 200
	extended.skills["added-skill"] = {"min":0,"max":200}
	check("extended permanent skill policy validates","",adapter.validate_record("player",extended))
	extended.attributes["extra-attribute"] = {"min":0,"max":100,"cap":100}
	check("extra attributes remain unsupported",false,adapter.validate_record("player",extended).is_empty())
	for career_case in [{"id":"class-01","magicka":76,"health":37,"numerator":3,"denominator":2},{"id":"class-02","magicka":89,"health":35,"numerator":7,"denominator":4}]:
		var fractional := captured("fractional-"+career_case.id)
		fractional.career = career_case.id
		check("fractional construction "+career_case.id,true,actors.fresh(scope,original,fractional,clock,[]).ok)
		check("fractional exact floor "+career_case.id,[career_case.magicka,career_case.numerator,career_case.denominator],[current(fractional.actor).derived.limits.magicka,current(fractional.actor).derived.career.multiplier.numerator,current(fractional.actor).derived.career.multiplier.denominator])
		check("career HP baseline "+career_case.id,career_case.health,current(fractional.actor).record.base_health)
	var over := captured("extended-permanent")
	over.attributes.strength = 150
	var over_source := ActorSource.new()
	over_source.contributions = [c("extended-cap","cap","strength",100),c("added","skill","added-skill",150)]
	check("supported extended permanent construction",true,actors.fresh(scope,original,over,clock,[{"id":"extended-source","provider":over_source}]).ok)
	check("above100 live values and added identity",[150,20,225,160],[current(over.actor).derived.attributes.strength.live,current(over.actor).derived.formulas.damage.value,current(over.actor).derived.formulas.capacity.value,current(over.actor).derived.skills["added-skill"].live])
	var saved := save_record()
	saved.current = {"health":3,"fatigue":0,"magicka":1}
	saved.progression.s0 = 0
	saved.progression.last_advancement.instant = 123
	saved.progression.training = {"state":"trained","at":{"provider":"controlled-clock-v1","unit":"game-millisecond","instant":0}}
	saved.progression.pending = [{"id":"pending-allocation","resolved_health":7,"applied":false}]
	saved.progression.retained_outcomes = [{"id":"retained-roll","value":7}]
	saved.obligations = [{"owner":"activity","id":"collapse-pending","payload":{"phase":"pending"}}]
	saved.breath = {"state":"owner-pending","reserve":0,"policy":{"schema":"controlled-activity-v1","state":"holding","last":123}}
	check("quiescent hydration accepted",true,actors.reconstruct(scope,original,saved,bindings).ok)
	check("saved current pools preserved",saved.current,current().record.current)
	check("zero S0 and timestamps preserved",saved.progression,current().record.progression)
	check("pending activity preserved",[saved.breath,saved.obligations],[current().record.breath,current().record.obligations])
	check("zero condition remains explicitly gated",[true,true,false],[current().pending_conditions.zero_fatigue,current().pending_conditions.obligations,current().entry_ready])
	for field in ["progression","base_health","current","breath","required_sources","obligations"]:
		var missing := saved.duplicate(true)
		missing.erase(field)
		var before := current()
		check("missing hydration "+field,false,actors.reconstruct(scope,original,missing,bindings).ok)
		check("hydration coherent "+field,before,current())
	check("missing required hydration source",false,actors.reconstruct(scope,original,saved,[]).ok)
	var wrong_receipt := saved.duplicate(true)
	wrong_receipt.required_sources["item-resolved"].revision += 1
	check("mismatched source receipt rejected",false,actors.reconstruct(scope,original,wrong_receipt,bindings).ok)
	check("hydration outside quiescent CORE rejected",false,actors.reconstruct(scope,{},saved,bindings).ok)
	var negative := saved.duplicate(true)
	negative.current.health = -1
	check("invalid saved vital rejected",false,actors.reconstruct(scope,original,negative,bindings).ok)
	var missing_reserve := saved.duplicate(true)
	missing_reserve.breath.erase("reserve")
	missing_reserve.breath["unrecognized"] = null
	check("missing breath reserve differs from null",false,actors.reconstruct(scope,original,missing_reserve,bindings).ok)
	var nonfinite_pending := saved.duplicate(true)
	nonfinite_pending.progression.pending.append({"unqualified":INF})
	var before_metadata := current()
	check("nonfinite pending metadata rejected",false,actors.reconstruct(scope,original,nonfinite_pending,bindings).ok)
	var cyclic := captured("cyclic-capture")
	cyclic.choices.custom_career["cycle"] = cyclic.choices.custom_career
	check("cyclic creation metadata rejected",false,actors.fresh(scope,original,cyclic,clock,[]).ok)
	cyclic.choices.custom_career.clear()
	check("metadata rejection preserves actor",before_metadata,current())
	check("repeated reconstruction does not refill",true,actors.reconstruct(scope,original,saved,bindings).ok)
	check("repeat retains current and pending",saved,current().record)
	var reordered: Array = bindings.duplicate(true)
	reordered.reverse()
	check("reordered source reconstruction accepted",true,actors.reconstruct(scope,original,saved,reordered).ok)
	check("reordered source reconstruction retained",saved,current().record)
	var edge := saved.duplicate(true)
	edge.actor = "revision-edge"
	edge.revision = 1000000000
	var edge_result: Dictionary = actors.reconstruct(scope,original,edge,bindings)
	check("maximum supported revision reconstructs",true,edge_result.ok)
	source_a.revision += 1
	check("revision exhaustion rejects publication","overflow",actors.reconcile(scope,original,edge.actor,edge.revision,registry.content_ticket()).get("kind"))
	check("revision exhaustion preserves authoritative record",edge,actors.projection(scope,edge.actor).record)
	source_a.contributions = [c("limit-a","health-limiter","health",7)]
	source_b.contributions = [c("limit-b","health-limiter","health",10)]
	source_a.revision += 1
	source_b.revision += 1
	check("independent limiters accepted",true,update().ok)
	check("lowest limiter wins",7,current().derived.limits.health)
	source_a.contributions = []
	source_a.revision += 1
	check("remove lowest limiter",true,update().ok)
	check("remaining limiter retained",[10,3],[current().derived.limits.health,current().record.current.health])
	source_b.contributions = []
	source_b.revision += 1
	check("remove last limiter",true,update().ok)
	check("limiter removal no refill",[31,3],[current().derived.limits.health,current().record.current.health])
	check("temporary Endurance batch",true,apply_endurance().ok)
	check("temporary Endurance preserves earned health",[31,0,7],[current().record.base_health,current().derived.formulas.growth.value,current().record.progression.pending[0].resolved_health])
	# Independent expectations for real published RULE built-ins at numerical boundaries.
	for vector in [{"value":0,"damage":-10,"capacity":0,"agility":-5,"resistance":0,"healing":-5,"magicka":0},{"value":49,"damage":-1,"capacity":73,"agility":-1,"resistance":4,"healing":-1,"magicka":98},{"value":50,"damage":0,"capacity":75,"agility":0,"resistance":5,"healing":0,"magicka":100},{"value":51,"damage":0,"capacity":76,"agility":0,"resistance":5,"healing":0,"magicka":102}]:
		var input := captured("numeric-"+str(vector.value))
		for key in input.attributes: input.attributes[key] = vector.value
		check("numeric actor "+str(vector.value),true,actors.fresh(scope,original,input,clock,[]).ok)
		var view := current(input.actor)
		for key in ["damage","capacity","agility","resistance","healing","magicka"]: check("formula "+str(vector.value)+" "+key,vector[key],view.derived.formulas[key].value)
		check("growth permanent "+str(vector.value),vector.healing,view.derived.formulas.growth.value)
	check("queries consume no randomness",rng_before,actor_core.randomness.snapshot())
	var snapshot := current()
	started = Time.get_ticks_usec()
	for query in 2000: actors.projection(scope,"player")
	observations.actor_projection_2000_usec = Time.get_ticks_usec()-started
	check("real volume queries preserve actor",snapshot,current())
	var crowd_sources: Array = []
	for owner in 16:
		var source := ActorSource.new()
		for contribution in 16: source.contributions.append(c("skill-"+str(contribution),"skill","medical",1))
		crowd_sources.append({"id":"crowd-source-"+str(owner),"provider":source})
	started = Time.get_ticks_usec()
	var crowd_ok := true
	for index in 128: crowd_ok = actors.fresh(scope,original,captured("crowd-"+str(index)),clock,crowd_sources).ok and crowd_ok
	observations.construct_128_actors_16_sources_256_contributions_usec = Time.get_ticks_usec()-started
	check("realistic crowd construction",true,crowd_ok)
	check("crowd source arithmetic",266,current("crowd-127").derived.skills.medical.live)
	started = Time.get_ticks_usec()
	for query in 1000: actors.projection(scope,"crowd-127")
	observations.crowd_projection_1000_usec = Time.get_ticks_usec()-started
	observations.source_count_per_crowd_actor = 16
	observations.actor_count = 138
	observations.catalog_records = 0
	for resource in registry.active().resources.values(): observations.catalog_records += resource.records.size()
	check("CHAR never announces ready",false,actor_core.snapshot().ready)
	check("unrelated hold retained",true,actor_core.gates.blocked("simulation"))
	if DisplayServer.get_name() != "headless":
		var review := current()
		# A separate review layer survives legitimate deferred stock-shell refreshes.
		var review_layer := CanvasLayer.new()
		review_layer.layer = 100
		shell.add_child(review_layer)
		var background := ColorRect.new()
		background.color = Color("#101820")
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		review_layer.add_child(background)
		var rows := VBoxContainer.new()
		rows.position = Vector2(36,36)
		rows.size = Vector2(1060,500)
		rows.add_theme_constant_override("separation",20)
		review_layer.add_child(rows)
		for text in ["IMP-016 / actual composed CHAR projection", "Controlled capture, clock and source providers; real CHAR / RULE", "Permanent Strength %s | live %s | base health %s" % [review.record.attributes.strength,review.derived.attributes.strength.live,review.record.base_health], "Current health / fatigue / magicka: %s" % review.record.current, "Maximum pools: %s" % review.derived.limits, "S0=%s retained | pending obligations=%s | entry ready=%s" % [review.record.progression.s0,review.pending_conditions.obligations,review.entry_ready], "Fatigue uses internal-64 units. Breath remains activity-owner pending."]:
			var label := Label.new()
			label.text = text
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.add_theme_font_size_override("font_size",24)
			rows.add_child(label)
		await capture(shell,"actor-state-review")
		var pixel: Color = shell.get_viewport().get_texture().get_image().get_pixel(8,8)
		check("rendered projection uses composed authority",true,actors == shell.session_shell.core.actors and absf(pixel.r-background.color.r) < 0.01 and absf(pixel.g-background.color.g) < 0.01 and absf(pixel.b-background.color.b) < 0.01)
		check("rendered pending pools",saved.current,current().record.current)
		review_layer.free()
	# Retirement inside a synchronous source callback must prevent late commit.
	source_a.revision += 1
	source_a.callback = func(): actor_core.request({"id":"retirement-during-baseline","mode":"shutdown","origin":scope})
	var result := update()
	# CORE rejects a competing request while its operation is active. Complete the
	# current entry as failed through its original ticket to perform real retirement.
	source_a.callback = retire_missing_provider
	result = update()
	check("retirement callback rejects publication",false,result.ok)
	check("retired actor cannot be queried",false,actors.projection(scope,"player").ok)
	check("missing real provider blocks complete entry",false,actor_core.snapshot().ready)
	check("unrelated hold survives entry failure",true,actor_core.gates.blocked("simulation"))
	check("late original work cannot revive",false,actors.fresh(scope,original,captured("late"),clock,[]).ok)
	source_a.callback = Callable() # Break the controlled callback/suite cycle.
	check("new controlled scope after retirement","pending",actor_core.request({"id":"formula-error-scope","mode":"new","origin":""}).kind)
	scope = actor_core.snapshot().session
	original = actor_core.ticket()
	check("formula failure fixture baseline",true,actors.fresh(scope,original,captured("player"),clock,bindings).ok)
	var prior := current()
	var call_count: int = callbacks.calls
	callbacks.mode = "runtime-error"
	source_a.revision += 1
	check("selected typed runtime error fails","callback_error",update().get("kind"))
	check("selected runtime provider invoked once",call_count+1,callbacks.calls)
	check("runtime error leaves actor coherent",prior,current())
	check("runtime error gates CORE",[false,false],[actor_core.snapshot().ready,actor_core.gates.safe])
	var monitored: Dictionary = controller.providers.formulas.active().last_failure
	check("runtime failure provider has no fallback","actor.formula",monitored.provider)
	check("runtime failure captured once",1,monitored.callback_errors.size())
	check("failed context retry does not invoke provider",false,update().ok)
	check("retry callback count unchanged",call_count+1,callbacks.calls)
	actor_core.complete_baseline(original,{"ok":false})
	callbacks.mode = "baseline"
	check("invalid result controlled scope","pending",actor_core.request({"id":"formula-invalid-scope","mode":"new","origin":""}).kind)
	scope = actor_core.snapshot().session
	original = actor_core.ticket()
	check("invalid result fixture baseline",true,actors.fresh(scope,original,captured("player"),clock,bindings).ok)
	prior = current()
	call_count = callbacks.calls
	callbacks.mode = "invalid"
	source_a.revision += 1
	check("invalid typed result rejected","invalid_result",update().get("kind"))
	check("invalid result no fallback",call_count+1,callbacks.calls)
	check("invalid result actor unchanged",prior,current())
	actor_core.complete_baseline(original,{"ok":false})
	callbacks.mode = "baseline"
	actor_core.gates.release(unrelated,"unrelated-review")
	observations.vital_mutations = await preload("res://tests/vital_mutation_cases.gd").new().run(self,shell)
	var ok := true
	for item in checks: ok = ok and item.expected == item.actual
	return {"ok":ok,"checks":checks,"count":checks.size(),"fixture":"IMP-016-actor-state-v1","engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"observations":observations,"review_projection":snapshot,"rng_before":rng_before,"checked_callback_errors":monitored.callback_errors,"source":"controlled creation/clock/source providers; real DATA/RULE/CHAR/CORE","inputs":fixture.get("inputs",{})}

func apply_endurance() -> Dictionary:
	source_a.contributions = [c("temporary-endurance","attribute","endurance",20)]
	source_a.revision += 1
	return update()

func retire_missing_provider() -> void:
	actor_core.complete_baseline(original,{"ok":true,"services":[actors.service_binding(scope)]})
	actor_core.complete_readiness(original,{"ok":true,"services":[actors.service_binding(scope),{"role":"magic","owner":"MAGIC","lifetime":"session","required":true,"ready":false,"provider":null}]})
