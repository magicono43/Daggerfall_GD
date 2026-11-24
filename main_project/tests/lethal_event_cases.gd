extends RefCounted
const Consumer = preload("res://tests/controlled_vital_consumer.gd")
const Prevention = preload("res://tests/controlled_prevention.gd")
const Policy = preload("res://scripts/data/death_policy.gd")
var suite: RefCounted
var core: SessionLifecycle
var actors: RefCounted
var scope := ""
var combat := Consumer.new()
var prevention := Prevention.new()
var serial := 0
var effects := preload("res://tests/controlled_disclosed_effects.gd").new()

func check(label: String, expected: Variant, actual: Variant) -> void:
	suite.check("lethal "+label,expected,actual)

func request(actor := "death-player") -> Dictionary:
	serial += 1
	var v: Dictionary = actors.vital_projection(scope,actor)
	return {"schema":"vital-intake-v1","session":scope,"actor":actor,"caller":"lethal-combat","operation":"event-"+str(serial),"content":v.content,"revision":v.revision,"action":"damage","pool":"health","unit":"points","amount":1000000000,"attribution":{"source":"controlled-lethal","cause":"damage","component":"strike"}}

func apply(r: Dictionary) -> Dictionary:
	combat.active = r.duplicate(true)
	return actors.vital_intake(combat,r)

func run(test_suite: RefCounted, shell: Control, fixture: Dictionary) -> Dictionary:
	suite = test_suite
	core = shell.session_shell.core
	actors = core.actors
	prevention.randomness = core.randomness
	check("entry","pending",core.request({"id":"lethal-scope","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	var ticket := core.ticket()
	var clock := {"provider":"controlled-clock-v1","unit":"game-millisecond","instant":0}
	var small_source := preload("res://tests/controlled_actor_source.gd").new()
	small_source.contributions = [{"id":"small-health","kind":"health-limiter","target":"health","value":1}]
	for id in ["death-player","death-empty","death-small","death-pending","death-volume","death-breath","death-recovery"]:
		var captured: Dictionary = suite.captured(id)
		if id == "death-small":
			for stat in ["strength","endurance","intelligence"]: captured.attributes[stat] = 0
		check("construct "+id,true,actors.fresh(scope,ticket,captured,clock,[{"id":"small-limit","provider":small_source}] if id == "death-small" else []).ok)
	actors.activity.prepare()
	var capped_record: Dictionary = actors.projection(scope,"death-player").record
	capped_record.actor = "death-cap"
	capped_record.revision = 999999993
	check("construct revision boundary actor",true,actors.reconstruct(scope,ticket,capped_record,[]).ok)
	var bad_activity: Dictionary = actors.projection(scope,"death-player").record
	bad_activity.schema = "actor-state-v4"
	bad_activity["lethal"] = preload("res://scripts/char/lethal_events.gd").empty()
	bad_activity["activity"] = actors.activity.empty(bad_activity)
	check("activity without vital ledger rejects raw headers",false,actors.reconstruct(scope,ticket,bad_activity,[]).ok)
	bad_activity["vitals"] = preload("res://scripts/char/vital_records.gd").empty()
	bad_activity.progression = true
	check("malformed progression rejects before cross-ledger validation",false,actors.reconstruct(scope,ticket,bad_activity,[]).ok)
	var captured_restore: Dictionary = actors.projection(scope,"death-small").record
	captured_restore.actor = "restore-capture"
	small_source.callback = func(): captured_restore.current.health = 0
	check("restore captures request before source callbacks",true,actors.reconstruct(scope,ticket,captured_restore,[{"id":"small-limit","provider":small_source}]).ok)
	small_source.callback = Callable()
	check("caller mutation cannot change hydrated health",1,actors.vital_projection(scope,"restore-capture").current.health)
	if fixture.has("restore_from"):
		var file := FileAccess.open(str(fixture.restore_from).get_base_dir().path_join("lethal-checkpoint.bin"),FileAccess.READ)
		check("checkpoint input present",true,file != null)
		if file == null: return {"ok":false,"kind":"missing_checkpoint"}
		var checkpoints: Dictionary = file.get_var(false)
		file.close()
		var observed: Array = []
		var observer := func(value: Dictionary): observed.append(value)
		actors.lethal_committed.connect(observer)
		for id: String in checkpoints:
			check("reconstruct "+id,true,actors.reconstruct(scope,ticket,checkpoints[id],[]).ok)
			check("reconstruction exact "+id,checkpoints[id],actors.projection(scope,id).record)
		actors.lethal_committed.disconnect(observer)
		check("reconstruction no death notice",[],observed)
		check("reconstruction no prevention calls",[],prevention.calls)
		check("reconstruction no source charges",{},prevention.costs)
		check("reconstruction never starts initial presentation","idle",shell.session_shell.death_view.phase)
		check("reconstructed conditions remain save gated",true,core.gates.blocked("save"))
		core.complete_baseline(ticket,{"ok":false})
		return {"source":"diagnostic same-scope lethal reconstruction; no native SAVE qualification"}
	actors.activity.prepare()
	var holding_record: Dictionary = actors.projection(scope,"death-breath").record
	holding_record.schema = "actor-state-v3"
	holding_record["vitals"] = preload("res://scripts/char/vital_records.gd").empty()
	holding_record["activity"] = actors.activity.empty(holding_record)
	holding_record.activity.breath.holding = true
	holding_record.breath = {"state":"owner-pending","reserve":0,"policy":holding_record.activity.policy.recovery.breath.duplicate(true)}
	check("controlled zero holding checkpoint",true,actors.reconstruct(scope,ticket,holding_record,[]).ok)
	var recovery_record: Dictionary = actors.projection(scope,"death-recovery").record
	recovery_record.breath = {"state":"owner-pending","reserve":5,"policy":{"mode":"gradual","rate":1,"delay_usec":0,"unit":"simulated-microsecond"}}
	recovery_record.obligations = [{"source":"controlled-breath-presentation","state":"owner-pending"}]
	check("controlled legacy recovery checkpoint",true,actors.reconstruct(scope,ticket,recovery_record,[]).ok)
	var binding: Dictionary = actors.service_binding(scope)
	binding.player_actor = "death-player"
	var services := [binding,combat.binding("lethal-combat","COMBAT"),prevention.binding(),effects.binding()]
	core.complete_baseline(ticket,{"ok":true,"services":services})
	core.complete_readiness(ticket,{"ok":true,"services":services})
	var initial_rng: Dictionary = core.randomness.snapshot()
	var pending_actor := request("death-pending")
	check("missing readiness pending actor","sources",apply(pending_actor).phase)
	var r := request()
	var pending := apply(r)
	check("unavailable retains pending",[false,"sources",31,true],[pending.ok,pending.phase,actors.vital_projection(scope,"death-player").current.health,core.gates.blocked("save")])
	check("pending reports no committed debit",[0,1000000000,31,0],[pending.applied,pending.remainder,pending.after,pending.restored])
	check("pending repeat stable",pending,apply(r))
	var changed := r.duplicate(true)
	changed.amount -= 1
	check("changed intent rejected","identity_conflict",apply(changed).kind)
	check("interleaved event blocked","busy",apply(request()).kind)
	check("pending raw schema valid",true,actors.lethal.valid(actors.projection(scope,"death-player").record))
	check("pending blocks source reconciliation","busy",actors.reconcile(scope,{},"death-player",actors.vital_projection(scope,"death-player").revision,r.content).kind)
	var corrupt: Dictionary = actors.projection(scope,"death-player").record
	corrupt.lethal.count = true
	check("raw boolean count rejected",false,actors.lethal.valid(corrupt))
	corrupt = actors.projection(scope,"death-player").record
	corrupt.current.health = 0
	check("pending cannot reconstruct provisional death",false,actors.lethal.valid(corrupt))
	prevention.sources = [{"id":"z","revision":1,"priority":2},{"id":"b","revision":1,"priority":1},{"id":"a","revision":1,"priority":1}]
	prevention.successes = {"a":false,"b":true,"z":true}
	prevention.ready = true
	prevention.malformed_evaluation = true
	var malformed := apply(r)
	check("malformed evaluation preserves pending health",[false,"evaluation",31],[malformed.ok,malformed.phase,actors.vital_projection(scope,"death-player").current.health])
	check("required malformed source stops later evaluation",["a"],prevention.calls)
	prevention.malformed_evaluation = false
	prevention.fail_consumption = true
	var prefix := apply(r)
	check("postcommit consumption remains pending",[false,"evaluation",31],[prefix.ok,prefix.phase,actors.vital_projection(scope,"death-player").current.health])
	check("priority and identity ties",["a","b"],prevention.calls)
	check("only success cost committed",1,prevention.costs.size())
	check("retained prefix retry no evaluations",prefix,apply(r))
	check("prefix no repeated charge",[2,1],[prevention.calls.size(),prevention.costs.size()])
	prevention.fail_consumption = false
	var survived := apply(r)
	check("survival minimum fraction and actual debit",[true,"prevented",31,3,3,999999969],[survived.ok,survived.phase,survived.applied,survived.after,survived.restored,survived.remainder])
	check("coherent current survival",3,actors.vital_projection(scope,"death-player").current.health)
	check("retained final result",survived,apply(r))
	check("success valid schema",true,actors.lethal.valid(actors.projection(scope,"death-player").record))
	check("success acknowledgment",true,actors.acknowledge_vital(combat,r).ok)
	check("ack cannot alter retained result",survived,apply(r))
	check("once only gameplay draws",initial_rng.sources.combat.logical_count+2,core.randomness.snapshot().sources.combat.logical_count)
	var p: Dictionary = actors.definitions.query("actor.baseline","death","player").record.value
	check("death policy captured loose precedence","@loose",actors.definitions.query("actor.baseline","death","player").record.winner.provider)
	check("view policy captured loose precedence","@loose",actors.definitions.query("actor.baseline","vitals","player").record.winner.provider)
	for field in ["numerator","denominator","minimum","fade_seconds","return_seconds"]:
		var invalid := p.duplicate(true)
		invalid[field] = true
		check("policy boolean rejected "+field,false,Policy.validate(invalid).is_empty())
	var invalid_duration := p.duplicate(true)
	invalid_duration.fade_seconds = INF
	check("nonfinite duration rejected",false,Policy.validate(invalid_duration).is_empty())
	for maximum in [1,2,9,10,19,20,31]:
		check("positive health boundary "+str(maximum),{1:1,2:1,9:1,10:1,19:1,20:2,31:3}[maximum],Policy.health(maximum,p))
	var next := request()
	var reentrant: Array = []
	prevention.callback = func(): reentrant.append(actors.vital_intake(combat,next).kind)
	var second := apply(next)
	prevention.callback = Callable()
	check("distinct event evaluates again",["prevented",4,2],[second.phase,prevention.calls.size(),prevention.costs.size()])
	check("reentrant mutations remain busy",["busy","busy"],reentrant)
	var detached_result := second.duplicate(true)
	detached_result.after = 0
	check("caller cannot mutate retained result",second,apply(next))
	prevention.randomness = null
	prevention.sources = [{"id":"b","revision":1,"priority":0}]
	var small := apply(request("death-small"))
	check("actual one-health prevention with zero fatigue",["prevented",1,0],[small.phase,small.after,actors.vital_projection(scope,"death-small").current.fatigue])
	var capped_first := request("death-cap")
	check("first capped prevention","prevented",apply(capped_first).phase)
	var capped_second := request("death-cap")
	check("second capped prevention","prevented",apply(capped_second).phase)
	var capped_pending := request("death-cap")
	prevention.ready = false
	check("capped pending reserves final revision","sources",apply(capped_pending).phase)
	check("older prevention can acknowledge before reserve",true,actors.acknowledge_vital(combat,capped_first).ok)
	check("older prevention cannot spend pending reserve",["overflow",999999999],[actors.acknowledge_vital(combat,capped_second).get("kind",""),actors.vital_projection(scope,"death-cap").revision])
	prevention.ready = true
	check("pending settles at final valid revision",["prevented",1000000000],[apply(capped_pending).phase,actors.vital_projection(scope,"death-cap").revision])
	check("final revision record remains valid",true,actors.lethal.valid(actors.projection(scope,"death-cap").record))
	check("ack duplicate consumes no revision",true,actors.acknowledge_vital(combat,capped_first).ok)
	var first_volume: Dictionary = {}
	var volume_ok := true
	var prepare_serial: int = shell.controller.providers.definitions.timings.prepare_serial
	var started := Time.get_ticks_usec()
	for index in 4096:
		var event := request("death-volume")
		if index == 0: first_volume = event.duplicate(true)
		volume_ok = apply(event).get("phase") == "prevented" and volume_ok
	var volume_usec := Time.get_ticks_usec()-started
	check("full lethal retention commits",true,volume_ok)
	check("retention overflow rejects new identity","overflow",apply(request("death-volume")).kind)
	var catalog_count := prevention.catalogs
	var decision_count := prevention.evaluations.size()
	started = Time.get_ticks_usec()
	for index in 2000: volume_ok = apply(first_volume).get("phase") == "prevented" and volume_ok
	var lookup_usec := Time.get_ticks_usec()-started
	check("full retention preserves old identity",true,volume_ok)
	check("lookups never repeat preparation",[prepare_serial,catalog_count,decision_count],[shell.controller.providers.definitions.timings.prepare_serial,prevention.catalogs,prevention.evaluations.size()])
	var ui: Control = shell.session_shell.vitals_view
	check("zero maximum UI bind",true,ui.bind(scope,"death-small"))
	check("zero maximum controls empty",[0.0,0.0],[ui._bars.fatigue.value,ui._bars.magicka.value])
	check("zero maximum exact status",["Fatigue  0 / 0","Magicka  0 / 0"],[ui._labels.fatigue.text,ui._labels.magicka.text])
	ui.bind(scope,"death-breath")
	check("holding zero reserve remains visible",[true,0.0],[ui._bars.breath.visible,ui._bars.breath.value])
	ui.bind(scope,"death-recovery")
	check("gradual recovery reserve visible",[true,5],[ui._bars.breath.visible,ui.projection().vitals.breath.reserve])
	var recovery_before: Dictionary = actors.projection(scope,"death-recovery").record
	core.gates.hud_preference = false
	ui.refresh()
	check("HUD hide effective",false,ui.visible)
	core.gates.hud_preference = true
	ui.refresh()
	check("HUD reveal preserves breath owner state",[true,recovery_before],[ui.visible,actors.projection(scope,"death-recovery").record])
	check("actual view bind",true,ui.bind(scope,"death-player"))
	check("explicit empty disclosed model ready",true,ui.projection().effects_available)
	check("targeted published width applied",320.0,ui.size.x)
	ui.refresh()
	check("visible full and partial stock pools",[true,true,true],[ui._labels.health.visible,ui._labels.fatigue.visible,ui._labels.magicka.visible])
	check("actual health control ratio",float(3)/31*100,ui._bars.health.value)
	for index in 12:
		var id := "g%02d" % index
		effects.groups.append({"id":id,"label":"Effect "+id,"icon":"missing-icon","compact":true,"components":[{"id":"part","label":"Contribution "+id,"lifetime":"2 owner rounds" if index == 2 else "source-bound","effective":index != 3,"suppressed":index == 3,"warning":index in [2,3,10]}]})
	effects.revision += 1
	ui.refresh()
	check("warned effective groups first",["g02","g10","g00","g01","g03","g04","g05","g06","g07","g08","g09","g11"],ui.projection().order)
	check("disclosed overflow excludes hidden",4,ui.projection().overflow)
	check("actual overflow control reachable","+4",ui._effects.get_child(8).text)
	check("fallback icon marker",true,ui._effects.get_child(0).text.begins_with("◆"))
	check("suppressed-only warning not prioritized",false,ui.warned(effects.groups[3]))
	effects.groups.reverse()
	effects.revision += 1
	var stable_order: Array = ui.projection().order
	ui.refresh()
	check("source enumeration cannot reshuffle visible groups",stable_order,ui.projection().order)
	var detached: Dictionary = ui.projection()
	detached.effects.groups.clear()
	check("effect projections detached",12,ui.projection().effects.groups.size())
	var effect_snapshots: int = effects.snapshots
	for index in 100: ui.refresh()
	check("unchanged UI avoids effect snapshot copies",effect_snapshots,effects.snapshots)
	var effect_rebuilds: int = ui.effect_rebuilds
	var ordinary := request()
	ordinary.amount = 1
	check("ordinary damage actual debit",1,apply(ordinary).applied)
	ui.refresh()
	check("pool updates preserve effect preparation",[effect_snapshots,effect_rebuilds],[effects.snapshots,ui.effect_rebuilds])
	var effective: Variant = effects.groups[0].components[0].effective
	effects.groups[0].components[0].effective = 1
	effects.revision += 1
	ui.refresh()
	check("malformed disclosure is unavailable rather than empty",false,ui.projection().effects_available)
	effects.groups[0].components[0].effective = effective
	effects.revision += 1
	ui.refresh()
	var before: Dictionary = actors.projection(scope,"death-player").record
	var rng: Dictionary = core.randomness.snapshot()
	ui._status.pressed.emit()
	ui.refresh()
	check("status read has no gameplay effects",[before,rng],[actors.projection(scope,"death-player").record,core.randomness.snapshot()])
	check("actual details opens",true,ui._details_scroll.visible)
	if DisplayServer.get_name() != "headless":
		await suite.capture(shell,"death-vitals-status")
		var image := shell.get_viewport().get_texture().get_image()
		var point := Vector2i(ui._bars.fatigue.get_global_rect().get_center())
		var painted := false
		if Rect2i(Vector2i.ZERO,image.get_size()).has_point(point):
			var pixel := image.get_pixelv(point)
			painted = pixel.g > 0.5 and pixel.r < 0.3
		check("rendered fatigue actually paints inside viewport",true,painted)
		var old_size := shell.get_window().size
		var old_theme: Theme = ui.theme
		var enlarged := Theme.new()
		enlarged.default_font = ui.get_theme_font("font")
		enlarged.default_font_size = 24
		ui.theme = enlarged
		shell.get_window().size = Vector2i(800,600)
		await suite.capture(shell,"death-vitals-narrow-enlarged")
		check("narrow enlarged required control in viewport",true,Rect2(Vector2.ZERO,shell.get_viewport_rect().size).encloses(ui._status.get_global_rect()))
		check("narrow enlarged details in viewport",true,Rect2(Vector2.ZERO,shell.get_viewport_rect().size).encloses(ui._details_scroll.get_global_rect()))
		ui.theme = old_theme
		shell.get_window().size = old_size
		check("render layout never mutates gameplay",[before,rng],[actors.projection(scope,"death-player").record,core.randomness.snapshot()])
	ui._status.pressed.emit()
	prevention.sources = []
	var dead_request := request("death-empty")
	var dead := apply(dead_request)
	var checkpoints := {}
	for id in ["death-player","death-pending","death-empty"]: checkpoints[id] = actors.projection(scope,id).record
	var checkpoint_file := FileAccess.open(str(fixture.sandbox).path_join("lethal-checkpoint.bin"),FileAccess.WRITE)
	checkpoint_file.store_var(checkpoints)
	checkpoint_file.close()
	check("ready empty commits death",[true,"dead",0,"dead",false],[dead.ok,dead.phase,dead.after,core.snapshot().status,core.gates.gameplay_input()])
	check("dead repeat retained",dead,apply(dead_request))
	check("death save gated",true,core.gates.blocked("save"))
	check("dead cannot acknowledge","unavailable",actors.acknowledge_vital(combat,dead_request).kind)
	var late := request("death-player")
	check("late damage rejected","stale",apply(late).kind)
	check("dead schema coherent",true,actors.lethal.valid(actors.projection(scope,"death-empty").record))
	check("initial presentation observed","initial",shell.session_shell.death_view.phase)
	check("actual death audio submitted","submitted",shell.session_shell.death_view.audio.outcome)
	var held := InputEventKey.new()
	held.physical_keycode = KEY_SPACE
	held.keycode = KEY_SPACE
	held.pressed = true
	Input.parse_input_event(held.duplicate())
	check("initial input cannot skip","initial",shell.session_shell.death_view.phase)
	var videos_before: int = core.provider.videos
	check("presentation initial alpha",true,shell.session_shell.death_view.color.a < 0.2)
	var initial_camera: Vector3 = shell.session_shell.view_camera.position
	var start := Time.get_ticks_msec()
	await shell.get_tree().create_timer(1.1).timeout
	check("frozen gameplay independent fade",true,shell.session_shell.death_view.color.a > 0.3 and not core.gates.simulation())
	check("camera lowers through view owner",true,shell.session_shell.view_camera.position.y < initial_camera.y)
	if DisplayServer.get_name() != "headless": await suite.capture(shell,"death-initial-fade")
	shell.session_shell.view_camera.free() # Optional camera disappears during the sequence.
	core.provider.hold_preflight = true
	check("competing operation admitted","pending",core.request({"id":"competing-dead-preflight","mode":"load","origin":scope}).kind)
	var competing := core.ticket()
	await shell.get_tree().create_timer(2.1).timeout
	check("return intent waits without preemption",[scope,true,"return",videos_before],[core.snapshot().session,core.busy(),shell.session_shell.death_view.phase,core.provider.videos])
	check("busy return exposes independent recovery UI",false,shell.session_shell.death_view.visible)
	if DisplayServer.get_name() != "headless": await suite.capture(shell,"death-return-busy")
	check("competing operation keeps original ticket",competing,core.ticket())
	core.cancel(competing)
	core.provider.hold_preflight = false
	var return_deadline := Time.get_ticks_msec()+1000
	while not core.snapshot().session.is_empty() and Time.get_ticks_msec() < return_deadline: await shell.get_tree().process_frame
	check("three second return usable menu",["",false],[core.snapshot().session,core.busy()])
	check("one controlled movie attempt",videos_before+1,core.provider.videos)
	check("initial cleanup retired",["idle",false],[shell.session_shell.death_view.phase,shell.session_shell.death_view.visible])
	check("retired HUD hidden",false,ui.visible)
	check("camera loss cannot trap return","",core.snapshot().session)
	held.pressed = false
	Input.parse_input_event(held.duplicate())
	check("late retired damage rejected","stale",apply(late).kind)
	var movie := await real_movie(shell)
	missing_provider(shell)
	return {"source":"real CHAR/CORE/DATA/UI/view, controlled benefit owner and cinematic lifecycle","elapsed_msec":Time.get_ticks_msec()-start,"survived":survived,"dead":dead,"4096_lethal_events_usec":volume_usec,"2000_point_retries_usec":lookup_usec,"real_movie":movie}

func real_movie(shell: Control) -> Dictionary:
	var provider := preload("res://tests/controlled_death_entry.gd").new()
	provider.death_video = shell.session_shell.death_movie
	core.provider = provider
	check("real movie entry","pending",core.request({"id":"real-death-entry","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	var ticket := core.ticket()
	check("real movie actor",true,actors.fresh(scope,ticket,suite.captured("death-original"),{"provider":"controlled-clock-v1","unit":"game-millisecond","instant":0},[]).ok)
	var services := [actors.service_binding(scope),combat.binding("lethal-combat","COMBAT"),prevention.binding()]
	core.complete_baseline(ticket,{"ok":true,"services":services})
	core.complete_readiness(ticket,{"ok":true,"services":services})
	provider.menu_ok = false
	var video: Control = shell.session_shell.video_playback
	var before_frames: int = video.measurements.frames
	var terminals: Array = []
	var observer := func(result: Dictionary): terminals.append(result.duplicate(true))
	video.terminal.connect(observer)
	var held := InputEventKey.new()
	held.physical_keycode = KEY_SPACE
	held.keycode = KEY_SPACE
	held.pressed = true
	check("real movie committed death","dead",apply(request("death-original")).phase)
	Input.parse_input_event(held.duplicate())
	await shell.get_tree().create_timer(3.15).timeout
	var deadline := Time.get_ticks_msec()+8000
	while Time.get_ticks_msec() < deadline and video.measurements.frames == before_frames and core.busy(): await shell.get_tree().process_frame
	check("original ANIM0012 real decoded frame",true,video.measurements.frames > before_frames)
	check("original movie handoff pending","presentation",core.snapshot().phase)
	Input.parse_input_event(held.duplicate())
	await shell.get_tree().process_frame
	check("initial held input cannot skip movie",[],terminals)
	# The original movie opens on black. Review a later source frame as well as
	# decoder admission; this clock is AV presentation time, never gameplay time.
	deadline = Time.get_ticks_msec()+8000
	while Time.get_ticks_msec() < deadline and video._clock < 3.0 and terminals.is_empty(): await shell.get_tree().process_frame
	if DisplayServer.get_name() != "headless": await suite.capture(shell,"original-death-movie")
	held.pressed = false
	Input.parse_input_event(held.duplicate())
	await shell.get_tree().process_frame
	held.pressed = true
	Input.parse_input_event(held.duplicate())
	deadline = Time.get_ticks_msec()+3000
	while Time.get_ticks_msec() < deadline and terminals.is_empty(): await shell.get_tree().process_frame
	check("fresh deliberate movie skip",["Skipped"],terminals.map(func(result: Dictionary): return result.kind))
	check("real movie attempted once",1,provider.videos)
	check("menu failure retains recovery","recovery",core.snapshot().application)
	provider.menu_ok = true
	check("menu retry succeeds",true,core.recover_menu())
	check("menu retry does not replay movie",[1,"menu","idle"],[provider.videos,core.snapshot().application,shell.session_shell.death_view.phase])
	await shell.get_tree().process_frame
	held.echo = true
	Input.parse_input_event(held.duplicate())
	check("skip input cannot start session",["",false,1],[core.snapshot().session,core.busy(),provider.prepares])
	held.pressed = false
	held.echo = false
	Input.parse_input_event(held.duplicate())
	await shell.get_tree().process_frame
	video.terminal.disconnect(observer)
	check("release clears death and movie input fences",[0,0],[shell.session_shell.death_view._held.size(),video._handoff_keys.size()])
	return {"source":"real classic ANIM0012.VID decoder/audio/video backend; controlled creation and menu failure","terminals":terminals,"frames":video.measurements.frames-before_frames}

func missing_provider(shell: Control) -> void:
	check("missing provider entry","pending",core.request({"id":"missing-provider-entry","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	var ticket := core.ticket()
	check("missing provider actor",true,actors.fresh(scope,ticket,suite.captured("missing-benefit"),{"provider":"controlled-clock-v1","unit":"game-millisecond","instant":0},[]).ok)
	var services := [actors.service_binding(scope),combat.binding("lethal-combat","COMBAT")]
	core.complete_baseline(ticket,{"ok":true,"services":services})
	core.complete_readiness(ticket,{"ok":true,"services":services})
	check("missing binding stays pending","sources",apply(request("missing-benefit")).phase)
	check("missing binding never means empty eligible set",31,actors.vital_projection(scope,"missing-benefit").current.health)
	check("missing binding keeps save gate",true,core.gates.blocked("save"))
	check("UI cannot confirm uncommitted death",false,core.confirm_actor_death(scope,actors,"missing-benefit",{"caller":"lethal-combat","operation":"not-a-death"}))
	check("missing provider does not start presentation","idle",shell.session_shell.death_view.phase)
	core.request({"id":"missing-provider-retire","mode":"return","origin":scope})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)
	check("missing provider scope retires safely","",core.snapshot().session)
