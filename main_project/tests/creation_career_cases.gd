extends "res://tests/mod_cases.gd"
## Increment-2 production DATA/CHAR/UI boundary qualification, independent of
## assigned later-stage providers. Names join the maintained creation inventory.
const Stock = preload("res://scripts/char/creation_inputs.gd")
const Custom = preload("res://scripts/char/custom_career.gd")
const Policy = preload("res://scripts/data/creation_career.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")
var owner: RefCounted
var provider: RefCounted

func control(shell: Control, text: String, activate := false) -> bool:
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	var found := await click(shell,text)
	if found and activate:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true; event.double_click = true
		find_button(shell.panel,text).gui_input.emit(event)
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	return found

func edit(section: String, value: Variant) -> Dictionary:
	return owner.edit(section,owner.token(),value)

func start(method := "list") -> void:
	owner.start()
	edit("race","breton")
	edit("gender","female")
	edit("class_method",method)

func valid_custom() -> Dictionary:
	var value := Custom.initial(provider.policy,owner.token().id+"/custom")
	value.name = "Étoile 流浪者"
	var index := 0
	for tier in Custom.COUNTS:
		for slot in Custom.COUNTS[tier]:
			value.tiers[tier][slot] = provider.policy.skills.keys()[index]
			index += 1
	return value

func qualify(shell: Control, fixture: Dictionary) -> Array[Dictionary]:
	sandbox = fixture.sandbox
	provider = Stock.new()
	provider.definitions = shell.controller.providers.definitions
	provider.content = provider.definitions.content_ticket()
	provider.options = provider.definitions.query("char.creation","flows","stock").record.value.choices
	check("career stock DATA preparation",true,provider.prepare().ok)
	check("career policy schema", "",Policy.policy_reason(provider.policy))
	check("career source schema","",Policy.source_reason(provider.sources))
	check("career unused fractional metadata preserved",0.5,Stock.exact_numbers({"unused":0.5}).unused)
	check("career original questionnaire ready",true,provider.sources.questionnaire.ok)
	check("career original picker ready",true,provider.sources.picker.ok)
	if not provider.sources.questionnaire.ok: print("CAREER QUESTIONNAIRE ",provider.sources.questionnaire)
	owner = Draft.new()
	owner.bind(provider.content,provider.bindings())
	owner.questionnaire_material = func():
		var material := PackedByteArray(); material.resize(32); material.fill(5)
		return {"ok":true,"material":material}
	start()
	for id in provider.policy.races:
		check("career race "+id,true,edit("race",id).ok)
		check("career race semantic "+id,true,owner.section_status("race").semantic_ready)
		check("career original race description "+id,true,provider.description(id).ok)
		for gender in ["male","female"]:
			check("career appearance "+id+"/"+gender,true,edit("gender",gender).ok)
			check("career appearance mapping "+id+"/"+gender,provider.policy.races[id].appearance[gender],owner.projection().validated.gender.provenance.appearance)
		var pixel: int = provider.sources.picker.indices.find(provider.policy.races[id].picker)
		check("career home province "+id,id,provider.race_at(Vector2(pixel%320,pixel/320)))
	for point in [Vector2(-1,0),Vector2(320,0),Vector2(0,200)]: check("career unsupported map "+str(point),"",provider.race_at(point))
	edit("race","breton"); edit("gender","male"); edit("race","argonian")
	check("career gender receipt follows retained birth race",provider.policy.races.argonian.appearance.male,owner.section_status("gender").validation.provenance.appearance)
	for index in 18:
		var id := "class-%02d" % index
		var read: Dictionary = provider.preset(id)
		check("career resolved preset "+id,true,read.ok)
		if not read.ok: print("CAREER PRESET ",id," ",read)
		check("career original preset description "+id,true,provider.description(id).ok)
		check("career preset acceptance "+id,true,edit("class",id).ok)
		check("career preset semantics "+id,true,owner.section_status("class").get("semantic_ready",false))
	start("questionnaire")
	check("career deliberate generation",true,owner.generate_questionnaire(owner.token()).ok)
	var questionnaire: Dictionary = owner.projection().selections.questionnaire
	check("career ten retained questions",10,questionnaire.questions.size())
	var unique := {}
	for id in questionnaire.questions: unique[id] = true
	check("career distinct retained questions",10,unique.size())
	# Independently calculated with Python unsigned integer PCG32 arithmetic.
	# Raw bounded indices: 38,27,30,7,7,24,34,7,1,3. Collision advance changes
	# the repeated 7s to 8 and 9 without consuming additional draws.
	check("career independent collision advance vector",["question-38","question-27","question-30","question-07","question-08","question-24","question-34","question-09","question-01","question-03"],questionnaire.questions)
	check("career generation logical count",10,owner.projection().validated.questionnaire.provenance.generation.logical_draws)
	check("career partial blocks recommendation",false,provider.suggestion(questionnaire).ok)
	for index in 10: questionnaire.answers[questionnaire.questions[index]] = index%3
	check("career complete answers",true,edit("questionnaire",questionnaire).ok)
	var first: Dictionary = provider.suggestion(questionnaire)
	check("career completed mapping",true,first.ok)
	questionnaire.answers[questionnaire.questions[0]] = 1
	check("career answer replacement",true,edit("questionnaire",questionnaire).ok)
	var revised: Dictionary = provider.suggestion(questionnaire)
	check("career replacement total remains ten",10,revised.scores[0]+revised.scores[1]+revised.scores[2])
	var before: Dictionary = owner.projection()
	owner.section_status("questionnaire")
	check("career validation cannot redraw",before,owner.projection())
	check("career repeated generation retained",true,owner.generate_questionnaire(owner.token()).ok)
	check("career repeated generation same facts",questionnaire,owner.projection().selections.questionnaire)
	var forged := questionnaire.duplicate(true)
	forged.questions.reverse()
	check("career forged question order rejects",false,edit("questionnaire",forged).ok)
	check("career questionnaire accepted suggestion",true,edit("class",revised.id).ok)
	questionnaire.answers[questionnaire.questions[1]] = 2
	edit("questionnaire",questionnaire)
	check("career answer invalidates accepted class",false,owner.projection().selections.has("class"))
	var mapping: Dictionary = provider.sources.questionnaire.results
	for mage in 11:
		for rogue in range(11-mage): check("career complete mapping %d/%d/%d" % [mage,rogue,10-mage-rogue],true,mapping.has("%d/%d/%d" % [mage,rogue,10-mage-rogue]))
	start("custom")
	var custom := valid_custom()
	check("career Unicode custom complete",true,edit("custom",custom).ok and owner.section_status("custom").ok)
	check("career custom stable identity",owner.token().id+"/custom",owner.projection().selections.custom.id)
	var candidate := custom.duplicate(true)
	candidate.name = " \t\n "
	check("career whitespace edit allowed",true,edit("custom",candidate).ok)
	check("career whitespace completion blocks",false,owner.section_status("custom").ok)
	check("career Unicode whitespace blocks",false,Custom.nonblank("\u00a0\u2003\u3000"))
	for key in Custom.ATTRIBUTES:
		for number in [9,10,75,76]:
			candidate = custom.duplicate(true); candidate.attributes[key] = number
			var evaluated: Dictionary = Custom.evaluate(candidate,provider.policy,custom.id)
			check("career attribute boundary %s/%d" % [key,number],true,evaluated.ok)
			check("career actual budget %s/%d" % [key,number],50-number,evaluated.attribute_remaining)
	candidate = custom.duplicate(true)
	candidate.attributes.strength = 51
	edit("custom",candidate)
	check("career temporary budget imbalance retained",51,owner.projection().selections.custom.attributes.strength)
	check("career actual budget completion blocks",false,owner.section_status("custom").ok)
	candidate = custom.duplicate(true); candidate.attributes.strength = 9; candidate.attributes.intelligence = 75; candidate.attributes.endurance = 66
	var bounded: Dictionary = Custom.evaluate(candidate,provider.policy,custom.id)
	check("career forged balanced attributes actual zero",0,bounded.attribute_remaining)
	check("career forged balanced attributes still reject bounds",false,bounded.errors.is_empty())
	candidate = custom.duplicate(true); candidate.reputation.merchants = 11; candidate.reputation.commoners = -11
	bounded = Custom.evaluate(candidate,provider.policy,custom.id)
	check("career forged balanced reputation actual zero",0,bounded.reputation_remaining)
	check("career forged balanced reputation still rejects bounds",false,bounded.errors.is_empty())
	candidate = custom.duplicate(true); candidate.tiers.major[0] = candidate.tiers.primary[0]
	before = owner.projection()
	check("career duplicate skill rejects",false,edit("custom",candidate).ok)
	check("career duplicate rejection atomic",before,owner.projection())
	candidate = custom.duplicate(true); candidate.tiers.primary[0] = provider.policy.skills.keys()[20]
	check("career replacement skill valid",true,edit("custom",candidate).ok)
	candidate.tiers.major[0] = custom.tiers.primary[0]
	check("career prior skill released",true,edit("custom",candidate).ok)
	check("career replacement no automatic swap",custom.tiers.primary[0],owner.projection().selections.custom.tiers.major[0])
	for id in provider.policy.traits:
		candidate = custom.duplicate(true); candidate.traits = [id]
		var evaluated: Dictionary = Custom.evaluate(candidate,provider.policy,custom.id)
		check("career supported option "+id,true,evaluated.ok)
		check("career option cost "+id,int(provider.policy.traits[id].cost),evaluated.difficulty)
	for pair in [["bonus_to_hit/animals","phobia/animals"],["expertise/axe","forbidden_weaponry/axe"],["immunity/fire","resistance/fire"],["resistance/fire","low_tolerance/fire"],["low_tolerance/fire","critical_weakness/fire"],["increased_magery/1","increased_magery/2"],["darkness_powered_magery/lower_daylight","darkness_powered_magery/unable_daylight"],["light_powered_magery/lower_darkness","light_powered_magery/unable_darkness"]]:
		candidate = custom.duplicate(true); candidate.traits = [pair[0]]; edit("custom",candidate)
		before = owner.projection(); candidate.traits.append(pair[1])
		check("career conflict rejects "+pair[1],false,edit("custom",candidate).ok)
		check("career conflict preserves "+pair[0],before,owner.projection())
	candidate = custom.duplicate(true); candidate.traits = ["increased_magery/3"]; edit("custom",candidate)
	candidate.traits.clear(); edit("custom",candidate)
	check("career removal clears effects",{},owner.projection().validated.custom.provenance.evaluation.effects)
	check("career removal clears charge",0,owner.projection().validated.custom.provenance.evaluation.difficulty)
	for difficulty_case in [[-13,["critical_weakness/fire","acute_hearing"]],[-12,["critical_weakness/fire","expertise/axe"]],[40,["immunity/fire","immunity/frost","immunity/shock","increased_magery/3"]],[41,["immunity/fire","immunity/frost","immunity/shock","increased_magery/3","acute_hearing"]]]:
		candidate = custom.duplicate(true); candidate.traits = difficulty_case[1]
		var evaluated: Dictionary = Custom.evaluate(candidate,provider.policy,custom.id)
		check("career actual difficulty endpoint "+str(difficulty_case[0]),difficulty_case[0],evaluated.difficulty)
		check("career legal difficulty endpoint "+str(difficulty_case[0]),difficulty_case[0] in [-12,40],evaluated.errors.is_empty())
		if difficulty_case[0] in [-12,40]: check("career advancement endpoint "+str(difficulty_case[0]),300 if difficulty_case[0] == -12 else 3000,int(1000*evaluated.advancement.numerator/evaluated.advancement.denominator))
	candidate = custom.duplicate(true); candidate.traits = ["acute_hearing","adrenaline_rush","athleticism","bonus_to_hit/animals","bonus_to_hit/daedra","bonus_to_hit/humanoid","bonus_to_hit/undead"]
	check("career seven advantages editable",true,Custom.evaluate(candidate,provider.policy,custom.id).ok)
	candidate.traits.append("expertise/axe")
	check("career eighth advantage rejects",false,Custom.evaluate(candidate,provider.policy,custom.id).ok)
	candidate = custom.duplicate(true); candidate.traits = ["forbidden_material/iron","forbidden_material/steel","forbidden_material/silver","forbidden_material/elven","forbidden_material/dwarven","forbidden_material/mithril","forbidden_material/adamantium"]
	check("career seven disadvantages editable",true,Custom.evaluate(candidate,provider.policy,custom.id).ok)
	candidate.traits.append("forbidden_material/ebony")
	check("career eighth disadvantage rejects",false,Custom.evaluate(candidate,provider.policy,custom.id).ok)
	candidate = custom.duplicate(true); candidate.traits = ["rapid_healing/general","rapid_healing/light","resistance/fire","low_tolerance/frost"]
	check("career distinct environments and targets coexist",true,Custom.evaluate(candidate,provider.policy,custom.id).ok)
	for hp in [4,7,8,9,30]:
		candidate = custom.duplicate(true); candidate.hit_points_per_level = hp
		var evaluated: Dictionary = Custom.evaluate(candidate,provider.policy,custom.id)
		check("career HP slope "+str(hp),hp-8 if hp >= 8 else -2*(8-hp),evaluated.hp_contribution)
	for group in Custom.GROUPS:
		for number in [-11,-10,10,11]:
			candidate = custom.duplicate(true); candidate.reputation[group] = number
			var evaluated: Dictionary = Custom.evaluate(candidate,provider.policy,custom.id)
			check("career reputation actual balance %s/%d" % [group,number],-number,evaluated.reputation_remaining)
			check("career reputation incomplete %s/%d" % [group,number],false,evaluated.errors.is_empty())
	var modified: Dictionary = provider.policy.duplicate(true)
	modified.attribute_total = 401; modified.difficulty.low_milli = 500; modified.difficulty.high_milli = 500
	check("career valid moddable parameters","",Policy.policy_reason(modified))
	modified.limits.advantage = 8; modified.limits.disadvantage = 9
	check("career mod count limit expands","",Policy.policy_reason(modified))
	var expanded := custom.duplicate(true)
	expanded.attributes.strength = 51 # Modified total is 401.
	expanded.traits = ["expertise/axe","expertise/blunt","expertise/hand_to_hand","expertise/long_blade","expertise/missile","expertise/short_blade","acute_hearing","athleticism"]
	check("career mod eighth advantage accepted",true,Custom.evaluate(expanded,modified,custom.id).errors.is_empty())
	modified.attribute_total = 100000
	check("career impossible mod budget rejects",false,Policy.policy_reason(modified).is_empty())
	modified = provider.policy.duplicate(true); modified.difficulty.max = modified.difficulty.min
	check("career equal difficulty rejects",false,Policy.policy_reason(modified).is_empty())
	modified = provider.policy.duplicate(true); modified.traits["immunity/fire"].conflict = ""
	check("career mod conflict override validates","",Policy.policy_reason(modified))
	var relaxed := custom.duplicate(true); relaxed.traits = ["immunity/fire","low_tolerance/fire"]
	check("career mod conflict override applies",true,Custom.evaluate(relaxed,modified,custom.id).ok)
	modified.traits["immunity/fire"].conflict = "bad/group"
	check("career malformed conflict group rejects",false,Policy.policy_reason(modified).is_empty())
	modified = provider.policy.duplicate(true); modified.difficulty.min = 30; modified.difficulty.max = 40
	modified.tradeoff_witness = {"hit_points_per_level":30,"traits":["increased_magery/3"]}
	check("career mod trait-required reachability","",Policy.policy_reason(modified))
	modified.tradeoff_witness.traits.clear()
	check("career impossible witness rejects",false,Policy.policy_reason(modified).is_empty())
	modified = provider.policy.duplicate(true); modified.skills.medical.label = "Même nom"; modified.skills.etiquette.label = "Même nom"
	check("career localized duplicate labels preserve identity",true,Custom.evaluate(custom,modified,custom.id).errors.is_empty())
	modified.skills.medical.classic = 33; modified.skills.archery.classic = 0
	check("career skill renumbering rejects",false,Policy.policy_reason(modified).is_empty())
	var wrong: Dictionary = provider.sources.duplicate(true); wrong.questionnaire.results.erase("0/0/10")
	check("career incomplete mapping rejects",false,Policy.source_reason(wrong).is_empty())
	wrong = provider.sources.duplicate(true); wrong.questionnaire = {"ok":false}
	check("career malformed source failure rejects",false,Policy.source_reason(wrong).is_empty())
	wrong = provider.sources.duplicate(true); wrong.picker.indices.fill(0)
	check("career missing home province coverage rejects",false,Policy.source_reason(wrong).is_empty())
	edit("custom",custom)
	before = owner.projection()
	owner.section_status("custom")
	check("career inspect custom unchanged",before,owner.projection())
	owner.discard()
	check("career discard clears all",{},owner.projection())
	start("questionnaire")
	owner.questionnaire_material = func(): return {"ok":false}
	check("career entropy failure explicit",false,owner.generate_questionnaire(owner.token()).ok)
	check("career entropy failure no invented set",false,owner.projection().selections.has("questionnaire"))
	owner.questionnaire_material = func():
		owner.discard()
		var material := PackedByteArray(); material.resize(32)
		return {"ok":true,"material":material}
	check("career interrupted generation stale",false,owner.generate_questionnaire(owner.token()).ok)
	check("career interrupted generation remains discarded",{},owner.projection())
	owner.questionnaire_material = Callable()
	owner.discard()
	qualify_captures(shell)
	await stock_controls(shell,fixture)
	return checks

func qualify_captures(shell: Control) -> void:
	var hybrid := preload("res://tests/creation_career_review_inputs.gd").new()
	hybrid.definitions = provider.definitions
	hybrid.content = provider.content
	hybrid.options = provider.options
	hybrid.prepare()
	var flow: Dictionary = provider.definitions.query("char.creation","flows","stock").record
	for method in ["list","questionnaire","custom"]:
		owner = Draft.new()
		owner.bind(hybrid.content,hybrid.bindings())
		owner.questionnaire_material = func(): var material := PackedByteArray(); material.resize(32); material.fill(5); return {"ok":true,"material":material}
		var nav := preload("res://scripts/char/creation_navigation.gd").new()
		nav.bind(owner,flow); nav.start()
		var safety := 20
		while nav.step().hook != "summary" and safety > 0:
			safety -= 1
			var hook: String = nav.step().hook
			var value: Variant
			match hook:
				"race": value = "breton"
				"gender": value = "male"
				"class_method":
					# Revisit race after gender, retain the same gender fact, and
					# continue through normal navigation. The old edit-time receipt
					# still names Breton; final capture must freshly name Argonian.
					nav.back(nav.context()); nav.back(nav.context())
					nav.edit(nav.context(),"argonian")
					nav.next(nav.context()); nav.next(nav.context())
					value = method
				"class": value = hybrid.suggestion(owner.projection().selections.questionnaire).id if method == "questionnaire" else "class-16"
				"questionnaire":
					owner.generate_questionnaire(owner.token())
					value = owner.projection().selections.questionnaire.duplicate(true)
					for id in value.questions: value.answers[id] = 0
				"custom": value = valid_custom()
				"biography_method": value = "manual"
				_: value = hybrid.later.fixture.preset[hook]
			check("career hybrid "+method+" edit "+hook,true,nav.edit(nav.context(),value).ok)
			check("career hybrid "+method+" next "+hook,true,nav.next(nav.context()).ok)
		var captured: Dictionary = nav.capture(nav.context())
		check("career hybrid "+method+" complete capture",true,captured.ok)
		if captured.ok:
			check("career hybrid "+method+" current gender receipt",hybrid.policy.races.argonian.appearance.male,captured.capture.draft.validated.gender.provenance.appearance)
			check("career hybrid "+method+" immutable repeated capture",captured.capture,nav.capture(nav.context()).capture)
			check("career hybrid "+method+" later provider explicitly assigned",true,captured.capture.draft.validated.biography.provider.begins_with("controlled."))
			check("career hybrid "+method+" summary upstream restricted",false,nav.summary_edit(nav.context(),"class").ok)
		owner.questionnaire_material = Callable()
		nav.discard(); owner.dispose()

func stock_controls(shell: Control, fixture: Dictionary) -> void:
	var view: RefCounted = shell.session_shell.creation_view
	if view != null and view.active(): view.exit()
	shell.render()
	check("career stock New Game handler",true,await control(shell,"New Game"))
	view = shell.session_shell.creation_view
	check("career stock race picker button",true,await control(shell,"Breton"))
	check("career candidate is uncommitted",false,view.owner.projection().selections.has("race"))
	await capture(shell,"creation-race-confirmation.png")
	var popup_label: Label
	for label: Label in view._page.find_children("*","Label",true,false):
		if label.get_meta("creation_popup_text",false): popup_label = label
	check("popup original race text retained",view.inputs.description("breton").text,popup_label.text)
	check("popup classic yellow text",Color8(243,239,44),popup_label.get_theme_color("font_color"))
	var popup_font: Font = popup_label.get_theme_font("font")
	check("popup real classic bitmap glyph",true,popup_font.has_char(65) and popup_font.get_font_name() == "Daggerfall FONT0003")
	check("popup actual sprite button",true,view._buttons["confirm/yes"].get_theme_stylebox("normal") is StyleBoxTexture)
	check("popup semantic Yes label retained","Yes",view._buttons["confirm/yes"].text)
	check("popup redundant Next hidden",false,view._buttons.next.visible)
	check("popup stock text fits without clipping",true,popup_label.get_minimum_size().y <= popup_label.get_parent().size.y)
	check("popup sprite retains native aspect",Vector2(32,16),view._buttons["confirm/yes"].size)
	var font_bytes := FileAccess.get_file_as_bytes(str(fixture.classic_source).path_join("FONT0003.FNT"))
	var font_codec = preload("res://scripts/data/classic_font.gd")
	check("popup malformed font length rejected",false,font_codec.decode(font_bytes.slice(0,100)).ok)
	font_bytes.encode_u16(4,65535)
	check("popup invalid glyph offset rejected",false,font_codec.decode(font_bytes).ok)
	var late_yes: Callable = find_button(shell.panel,"Yes").get_signal_connection_list("pressed")[0].callable
	shell.session_shell.options()
	check("career race cancel retains draft",true,view.active())
	late_yes.call()
	check("career cancelled race late Yes ignored",false,view.owner.projection().selections.has("race"))
	check("career cancelled narration stopped",true,view.career_view._audio == null)
	await control(shell,"Breton")
	check("career race No handler",true,await control(shell,"No"))
	check("career race rejection uncommitted",false,view.owner.projection().selections.has("race"))
	for race in [["Nord","nord"],["Dark Elf","dark-elf"]]:
		check("popup "+race[1]+" opens",true,await control(shell,race[0]))
		await capture(shell,"creation-popup-"+race[1]+".png")
		check("popup "+race[1]+" No returns to picker",true,await control(shell,"No"))
	await control(shell,"Breton")
	check("career race Yes handler",true,await control(shell,"Yes"))
	check("career race confirms then gender","gender",view.navigation.step().hook)
	await control(shell,"Female")
	await control(shell,"Choose from a list")
	check("career stock preset list","class",view.navigation.step().hook)
	await control(shell,"Warrior",true)
	check("career direct candidate uncommitted",false,view.owner.projection().selections.has("class"))
	await capture(shell,"creation-preset-confirmation.png")
	check("career direct No handler",true,await control(shell,"No"))
	await control(shell,"Warrior",true)
	check("career preset Yes handler",true,await control(shell,"Yes"))
	check("career later biography stays separate","biography_method",view.navigation.step().hook)
	check("career zero premature actor",0,shell.session_shell.core.actors._actors.size())
	check("career zero premature session readiness",false,shell.session_shell.core.gates.ready)
	view.restart()
	view.action("edit",view.navigation.context(),"breton"); view.action("next",view.navigation.context())
	view.action("edit",view.navigation.context(),"male"); view.action("next",view.navigation.context())
	view.action("edit",view.navigation.context(),"questionnaire"); view.action("next",view.navigation.context())
	check("career questionnaire start handler",true,await control(shell,"Start questionnaire"))
	var original_set: Array = view.owner.projection().selections.questionnaire.questions.duplicate()
	await capture(shell,"creation-class-questionnaire.png")
	for index in 10:
		var question: String = original_set[index]
		var answer: String = view.inputs.sources.questionnaire.questions[question].answers[index%3]
		check("career stock answer handler "+str(index),true,await control(shell,answer))
		if index < 9: check("career stock next question "+str(index),true,await control(shell,"Next question"))
	check("career UI preserves assigned set",original_set,view.owner.projection().selections.questionnaire.questions)
	check("career questionnaire review next handler",true,await control(shell,"Next"))
	view.navigation._summary_seen = true # Focused UI permission seam; complete hybrid routes are qualified above.
	check("career read-only questionnaire confirmation permits exit",false,view.cancel_nested())
	view.navigation._summary_seen = false
	check("career questionnaire suggestion No handler",true,await control(shell,"No"))
	check("career decline opens direct including Custom",true,find_button(shell.panel,"Custom") != null)
	check("career decline switches method","list",view.owner.projection().selections.class_method)
	view.action("back",view.navigation.context())
	view.action("edit",view.navigation.context(),"questionnaire"); view.action("next",view.navigation.context())
	var saved_source: Dictionary = view.inputs.sources.questionnaire
	view.inputs.sources.questionnaire = {"ok":false,"reason":"Controlled missing questionnaire. Choose direct selection."}
	shell.render()
	check("career unavailable questionnaire offers direct",true,await control(shell,"Choose directly"))
	check("career unavailable questionnaire invents no career",false,view.owner.projection().selections.has("class"))
	view.inputs.sources.questionnaire = saved_source
	view.restart()
	view.action("edit",view.navigation.context(),"breton"); view.action("next",view.navigation.context())
	view.action("edit",view.navigation.context(),"male"); view.action("next",view.navigation.context())
	view.action("edit",view.navigation.context(),"custom"); view.action("next",view.navigation.context())
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career custom opens directly",true,view._editors.has("custom/name-field") and not view._buttons.has("start-custom"))
	var class_name_field: LineEdit = view._editors["custom/name-field"]
	class_name_field.text = "Étoile 流浪者"
	class_name_field.text_changed.emit(class_name_field.text)
	await control(shell,"Help")
	view.cancel_nested()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career pending name survives nested editor","Étoile 流浪者",view._editors["custom/name-field"].text)
	check("career custom name stock handler",true,await control(shell,"Use name"))
	check("career custom Unicode name owner receives","Étoile 流浪者",view.owner.projection().selections.custom.name)
	check("career custom missing glyph diagnostic retained",true,view.glyph_diagnostics.any(func(d): return d.kind == "missing_glyph" and d.context.get("field") == "custom.name"))
	view._buttons["attribute/strength"].pressed.emit()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	view._buttons["attribute/up"].pressed.emit()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career attribute stock handler",51,view.owner.projection().selections.custom.attributes.strength)
	check("career attribute stock budget",-1,view.owner.projection().validated.custom.provenance.evaluation.attribute_remaining)
	view._buttons["attribute/down"].pressed.emit()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	await select_skill(view,"skill/primary/0","medical")
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career skill stock handler","medical",view.owner.projection().selections.custom.tiers.primary[0])
	view._buttons["skill/primary/1"].pressed.emit()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career stock duplicate skill unavailable",false,view._buttons.has("custom/skill/medical"))
	view.cancel_nested()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	await select_skill(view,"skill/primary/1","etiquette")
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	await select_skill(view,"skill/primary/0","streetwise")
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	view._buttons["skill/primary/1"].pressed.emit()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career stock replacement releases old",true,view._buttons.has("custom/skill/medical"))
	view.cancel_nested()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career stock replacement no swap","etiquette",view.owner.projection().selections.custom.tiers.primary[1])
	view._buttons["hp/up"].pressed.emit()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career HP stock handler",9,view.owner.projection().selections.custom.hit_points_per_level)
	check("career HP stock contribution",1,view.owner.projection().validated.custom.provenance.evaluation.hp_contribution)
	check("career custom incomplete Next blocked",false,view.action("next",view.navigation.context()).ok)
	view.cancel_nested()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	class_name_field = view._editors["custom/name-field"]
	class_name_field.text = "Étoile 流浪者 2"
	class_name_field.text_changed.emit(class_name_field.text)
	view.action("next",view.navigation.context())
	check("career Next commits visible pending name","Étoile 流浪者 2",view.owner.projection().selections.custom.name)
	check("career custom advantage panel handler",true,await control(shell,"Advantages"))
	await control(shell,"Add advantage")
	check("career primary picker opens","category",view.career_view.trait_stage)
	view.cancel_nested()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career cancelled picker no charge",[],view.owner.projection().selections.custom.traits)
	await control(shell,"Add advantage")
	var picker: Control
	for child in view._page.get_children():
		if child.get_meta("custom_trait_picker",false): picker = child
	picker.item_activated.emit(0)
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	check("career trait add owner receives",["acute_hearing"],view.owner.projection().selections.custom.traits)
	await capture(shell,"creation-traits.png")
	check("career trait removal stock handler",true,await control(shell,"Remove Acute Hearing"))
	check("career trait removal owner clear",[],view.owner.projection().selections.custom.traits)
	await control(shell,"Return to career")
	check("career custom reputation panel handler",true,await control(shell,"Reputation"))
	var reputation_click := InputEventMouseButton.new()
	reputation_click.button_index = MOUSE_BUTTON_LEFT; reputation_click.pressed = true
	reputation_click.position = Vector2(10,47) # Native y=71 maps to +1.
	view._buttons["reputation/merchants"].gui_input.emit(reputation_click)
	await shell.get_tree().process_frame
	await shell.get_tree().process_frame
	check("career reputation stock handler",1,view.owner.projection().selections.custom.reputation.merchants)
	check("career nested imbalance completion blocks",false,view.action("next",view.navigation.context()).ok)
	await control(shell,"Return to career")
	check("career unbalanced reputation Exit warns",true,view.career_view.reputation_warning)
	view.cancel_nested()
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	reputation_click.position = Vector2(10,52) # Restore zero before leaving.
	view._buttons["reputation/merchants"].gui_input.emit(reputation_click)
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	await control(shell,"Return to career")
	await shell.get_tree().process_frame; await shell.get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await shell.get_tree().process_frame
		await RenderingServer.frame_post_draw
		shell.get_viewport().get_texture().get_image().save_png(str(fixture.sandbox).path_join("creation-custom-career.png"))
		check("career rendered custom visible",true,view._page.is_visible_in_tree())
	view.exit()

func metadata(node: Node, id: String) -> Control:
	if node.get_meta("creation_action","") == id: return node as Control
	for child in node.get_children():
		var found := metadata(child,id)
		if found != null: return found
	return null

func option_index(picker: OptionButton, id: String) -> int:
	for index in picker.item_count:
		if picker.get_item_metadata(index) == id: return index
	return -1

func select_skill(view: RefCounted, action: String, skill: String) -> void:
	view._buttons[action].pressed.emit()
	await view.shell.host.get_tree().process_frame; await view.shell.host.get_tree().process_frame
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true; event.double_click = true
	view._buttons["custom/skill/"+skill].gui_input.emit(event)
	await view.shell.host.get_tree().process_frame; await view.shell.host.get_tree().process_frame

func capture(shell: Control, name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	shell.panel.get_parent().scroll_vertical = 0
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	shell.get_viewport().get_texture().get_image().save_png(sandbox.path_join(name))
