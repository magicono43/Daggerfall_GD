extends "res://tests/text_cases.gd"
const Construction = preload("res://scripts/data/item_construction.gd")
const ItemFormula = preload("res://scripts/rule/item_formulas.gd")
const Allocator = preload("res://scripts/item/identity_allocator.gd")
var item_owner: RefCounted
var requester: RefCounted
var scope := ""
var observations := {}

class Requester:
	extends "res://tests/controlled_session_provider.gd"
	var items: RefCounted
	func bindings() -> Array:
		var contexts := []
		for pair in [["weapon","dfu-item-113"],["armor","dfu-item-102"],["clothing","dfu-item-141"],["ammo","dfu-item-131"]]:
			contexts.append({"id":pair[0],"custody":"inspection-owner","pool":[pair[1]],"worn":true,"copy":true})
		contexts.append({"id":"new-only","custody":"inspection-owner","pool":["dfu-item-113"],"worn":false,"copy":false})
		contexts.append({"id":"weapons-pool","custody":"inspection-owner","pool":["dfu-item-113","dfu-item-114"],"worn":false,"copy":false})
		return [items.service_binding(),{"role":"inspection-requester","owner":"DEV","lifetime":"session","required":true,"ready":true,"provider":self,"item_contexts":contexts}]

class Replacement:
	extends RefCounted
	var builtin := ItemFormula.new()
	var core: SessionLifecycle
	var interrupt := false
	var invalid_value := false
	var category_calls := 0
	func value(v: Dictionary) -> int:
		if invalid_value: return -1
		return builtin.value(v)+(7 if v.coefficients.value == 9 else 0)
	func category(v: Dictionary) -> int:
		category_calls += 1
		if v.level == 778: return v.policy.categories.find("plate")
		if interrupt:
			# Deliberately adversarial callback: suspend the source after resolving
			# category to exercise the real retained partial-generation boundary.
			core.randomness.suspend_operation(true)
			return 2
		return builtin.category(v)
	func material(v: Dictionary) -> int:
		return v.policy.materials.find("bronze") if v.level in [777,778] else builtin.material(v)

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})
	print("ITEM check: ",id," — ","PASS" if Construction.N.equal_input(expected,actual) else "FAIL")

func envelope(operation: String, entries: Array) -> Dictionary:
	return {"domain":Construction.DOMAIN,"path":"profiles","operation":operation,"entries":entries}

func explicit(id: String, kind := "weapon") -> Dictionary:
	var r := {"session":scope,"context":kind,"request":id,"profile":{"weapon":"dfu-item-113","armor":"dfu-item-102","ammo":"dfu-item-131","clothing":"dfu-item-141","new-only":"dfu-item-113"}[kind],"body":"male-human","category":{"weapon":"weapon","armor":"plate","ammo":"neutral","clothing":"neutral","new-only":"weapon"}[kind],"style":"default","quantity":1}
	if kind in ["weapon","armor","new-only"]: r.material = "steel"
	return r

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var mods: RefCounted = controller.mods
	var adapter := Construction.new()
	check("unpublished semantic query rejects","before_readiness",registry.query(Construction.DOMAIN,"profiles","policy").kind)
	var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/items/construction.json"))
	var material: Dictionary = original.entries.filter(func(e: Dictionary): return e.id == "steel")[0].value.duplicate(true)
	material.coefficients = {"value":9,"weight":4,"condition":8}
	material.dye = "steel"
	var package := manifest("construction.test")
	package.content = ["profiles.json","compatibility.json","policy.json"]
	package.capabilities = ["data."+Construction.VERSION]
	write(mods.root.path_join("Mods/construction/mod.json"),JSON.stringify(package))
	write(mods.root.path_join("Mods/construction/profiles.json"),JSON.stringify(envelope("add",[{"id":"bronze","value":material}])))
	var supported_materials: Array = original.entries[0].value.selector.materials.duplicate()
	supported_materials.append("bronze")
	write(mods.root.path_join("Mods/construction/compatibility.json"),JSON.stringify(envelope("patch",[{"id":"dfu-item-113","value":{"materials":supported_materials,"styles":{"weapon":{"0":0,"ceremonial":0}}}}])))
	var selector: Dictionary = original.entries[0].value.selector.duplicate(true)
	selector.materials.append("bronze")
	selector.entries.append(0)
	var categories: Dictionary = original.entries[0].value.categories.duplicate(true)
	categories["custom-plate"] = {"mode":"material","dye":"steel"}
	var armor_styles: Dictionary = original.entries.filter(func(e: Dictionary): return e.id == "dfu-item-102")[0].value.styles.duplicate(true)
	armor_styles["custom-plate"] = armor_styles.plate.duplicate(true)
	var valid_policy := envelope("patch",[{"id":"policy","value":{"selector":selector,"categories":categories}},{"id":"dfu-item-102","value":{"styles":armor_styles}}])
	var invalid_policy: Dictionary = valid_policy.duplicate(true)
	invalid_policy.entries[0].value.categories.semantic = {"mode":"material","dye":"steel"}
	write(mods.root.path_join("Mods/construction/policy.json"),JSON.stringify(invalid_policy))
	mods.rescan()
	mods.edit("construction.test","toggle")
	var replacement := Replacement.new()
	check("RULE contribution stages",true,controller.providers.formulas.stage("construction.test","1.0.0",[{"hook":"item.value","contract":ItemFormula.CONTRACT,"callback":replacement.value},{"hook":"item.category","contract":ItemFormula.CONTRACT,"callback":replacement.category},{"hook":"item.material","contract":ItemFormula.CONTRACT,"callback":replacement.material}]).ok)
	# Override the new material via actual captured loose precedence.
	write(mods.root.path_join("Overrides/construction.json"),JSON.stringify(envelope("patch",[{"id":"bronze","value":{"coefficients":{"value":9,"weight":3,"condition":8}}}])))
	var started := Time.get_ticks_usec()
	controller.select_folder(fixture.classic_source)
	check("reserved category blocks real MOD preparation",false,registry.projection().get("ok",false))
	check("reserved category publishes no DATA",-1,registry.content_ticket())
	check("reserved category diagnosed",true,registry.projection().issues.any(func(issue: Dictionary): return "reserved" in issue.get("reason","")))
	write(mods.root.path_join("Mods/construction/policy.json"),JSON.stringify(valid_policy))
	mods.rescan()
	controller.check_content()
	observations.complete_preparation_usec = Time.get_ticks_usec()-started
	var candidate: Dictionary = registry.projection()
	check("complete adapter composition prepares",true,candidate.get("ok",false))
	if not candidate.get("ok",false):
		observations.failure = candidate.get("issues",[])
		return terminal(fixture)
	observations.preparation = registry.timings.duplicate(true)
	var profiles: Dictionary = candidate.resources[Construction.DOMAIN+":profiles"].records
	check("baseline semantic profile inventory",106,profiles.values().filter(func(r: Dictionary): return r.value.kind == "template").size())
	check("accepted structural inventory remains",436,candidate.resources["item-spell.inputs:catalog"].records.size())
	check("added material originating identity","construction.test",profiles.bronze.identity.package)
	check("loose material override winner","@loose",profiles.bronze.fields.coefficients.provider)
	var malformed := material.duplicate(true)
	malformed.coefficients.weight = -1
	check("negative coefficient rejects",false,adapter.validate_record("bad",malformed).is_empty())
	malformed = material.duplicate(true)
	malformed.provider = "unavailable"
	check("unknown property provider rejects",false,adapter.validate_record("bad",malformed).is_empty())
	var bad_policy: Dictionary = profiles.policy.value.duplicate(true)
	bad_policy.selector.entries = [1]
	check("incomplete selector rejects",false,adapter.validate_record("policy",bad_policy).is_empty())
	bad_policy = profiles.policy.value.duplicate(true)
	bad_policy.selector.chances = [70,20,11]
	check("conflicting category coverage rejects",false,adapter.validate_record("policy",bad_policy).is_empty())
	var missing: Dictionary = {Construction.DOMAIN+":profiles":candidate.resources[Construction.DOMAIN+":profiles"].duplicate(true),"item-spell.inputs:catalog":candidate.resources["item-spell.inputs:catalog"].duplicate(true)}
	missing[Construction.DOMAIN+":profiles"].records.erase("iron")
	check("required material mapping rejects",true,adapter.validate_references(missing).size() > 0)
	var bad_template: Dictionary = profiles["dfu-item-102"].value.duplicate(true)
	bad_template.visual.archives.erase("male-human")
	check("incomplete body visuals reject",false,adapter.validate_record("bad",bad_template).is_empty())
	var reserved_styles: Dictionary = profiles["dfu-item-102"].value.styles.duplicate(true)
	reserved_styles.semantic = reserved_styles.plate.duplicate(true)
	var reserved_contribution: Dictionary = registry.apply_contribution(candidate.resources,JSON.stringify(envelope("patch",[{"id":"dfu-item-102","value":{"styles":reserved_styles}}])).to_utf8_buffer(),{"provider":"construction.test","file":"reserved.json","version":"1.0.0","root":sandbox})
	check("reserved template category contribution rejects",false,reserved_contribution.ok)
	check("reserved template rejection preserves source",false,candidate.resources[Construction.DOMAIN+":profiles"].records["dfu-item-102"].value.styles.has("semantic"))
	var conflict: Dictionary = registry.apply_contribution(missing,JSON.stringify(envelope("add",[{"id":"steel","value":material}])).to_utf8_buffer(),{"provider":"construction.test","file":"duplicate.json","version":"1.0.0","root":sandbox})
	check("duplicate material identity rejects",false,conflict.ok)
	var malformed_publication: Dictionary = registry.apply_contribution(missing,JSON.stringify(envelope("patch",[{"id":"steel","value":{"provider":"unavailable"}}])).to_utf8_buffer(),{"provider":"construction.test","file":"bad.json","version":"1.0.0","root":sandbox})
	check("malformed provider contribution rejects atomically",false,malformed_publication.ok)
	check("failed contribution preserves source profile","builtin.properties-v1",missing[Construction.DOMAIN+":profiles"].records.steel.value.provider)
	controller.providers.faults.menu = true
	check("menu interruption publishes nothing",false,controller.continue_to_menu("run").ok)
	check("no partial semantic publication",-1,registry.content_ticket())
	controller.providers.faults.clear()
	controller.check_content()
	check("actual menu publication succeeds",true,controller.continue_to_menu("run").ok)
	check("selected formula override published","construction.test",controller.providers.formulas.active().winners["item.value"])
	var core: SessionLifecycle = shell.session_shell.core
	replacement.core = core
	core.formulas = controller.providers.formulas
	item_owner = core.items
	requester = Requester.new()
	requester.items = item_owner
	core.provider = requester
	core.startup_route_changed("main_menu")
	var entry := core.request({"id":"construction-session","mode":"new","origin":""})
	check("production CORE scoped entry","Succeeded",entry.kind)
	scope = core.snapshot().session
	if not core.snapshot().ready: return terminal(fixture)
	check("entry grants no possessions",0,item_owner.counters().possessions)
	check("explicit sources start untouched",0,core.randomness.snapshot().sources.loot.logical_count)
	identity_checks()
	var before: Dictionary = item_owner.counters()
	var source_before: Dictionary = core.randomness.snapshot()
	var preview: Dictionary = item_owner.preview(requester,explicit("preview"))
	check("preview computes without possession",true,preview.ok)
	if not preview.ok:
		observations.preview_failure = preview
		return terminal(fixture)
	check("preview does not allocate",before,item_owner.counters())
	check("preview draws no randomness",source_before,core.randomness.snapshot())
	var request := explicit("worn")
	request.condition = 5
	var made: Dictionary = item_owner.construct(requester,request)
	check("worn authorized construction",true,made.ok)
	check("steel exact properties",[preview.record.value,0.5,75,5],[made.record.value,made.record.weight_kg,made.record.maximum_condition,made.record.condition])
	check("typed first item identity",{"category":"item","number":"1"},made.record.id)
	check("initial custody explicit",{"owner":"inspection-owner","context":"weapon"},made.record.custody)
	check("construction retries retain outcome",made,item_owner.construct(requester,request))
	check("retry creates no second possession",1,item_owner.counters().possessions)
	check("request input conflict rejects","request_conflict",item_owner.construct(requester,request.merged({"dye":"red"},true)).kind)
	var new_item: Dictionary = item_owner.construct(requester,explicit("new"))
	check("new possession gets fresh identity",false,new_item.record.id == made.record.id)
	check("ordinary new condition is full",75,new_item.record.condition)
	var copy_request := {"session":scope,"context":"weapon","request":"copy"}
	var copied: Dictionary = item_owner.copy_possession(requester,copy_request,made.record.id)
	check("genuine copy receives fresh identity",false,copied.record.id == made.record.id)
	check("copy retains worn state",5,copied.record.condition)
	check("copy retry no duplicate",copied,item_owner.copy_possession(requester,copy_request,made.record.id))
	var changed: Dictionary = item_owner.modify(requester,request,made.record.id,{"dye":"red","body":"female-elf"})
	check("appearance modification preserves identity",made.record.id,changed.record.id)
	check("appearance preserves condition mechanics",[5,75,made.record.value,0.5],[changed.record.condition,changed.record.maximum_condition,changed.record.value,changed.record.weight_kg])
	check("female weapon archive mapping",233,changed.record.visual.archive)
	check("appearance isolation",made.record.dye,item_owner.inspect(scope,copied.record.id).record.dye)
	changed.record.visual.archive = 99
	check("defensive item projections",233,item_owner.inspect(scope,made.record.id).record.visual.archive)
	check("recalculation does not compound or repair",item_owner.inspect(scope,made.record.id).record,item_owner.recalculate(requester,request,made.record.id).record)
	check("repeated recalculation preserves facts",item_owner.inspect(scope,made.record.id).record,item_owner.recalculate(requester,request,made.record.id).record)
	check("mechanical reset not supported",false,item_owner.modify(requester,request,made.record.id,{"material":"iron"}).ok)
	check("unknown identity rejects","missing_or_retired",item_owner.inspect(scope,{"category":"item","number":"999999"}).kind)
	var failures := []
	before = item_owner.counters()
	for invalid in [{"body":"unmapped"},{"style":"999"},{"dye":"unmapped"},{"material":"unmapped"},{"quantity":0},{"quantity":2},{"condition":1000},{"profile":"unmapped"},{"category":"chain"},{"provider":"unmapped"}]:
		failures.append(item_owner.construct(requester,request.merged(invalid,true).merged({"request":"invalid-"+str(failures.size())},true)).ok)
	check("invalid complete requests all reject",[false,false,false,false,false,false,false,false,false,false],failures)
	check("failures preserve all facts",before,item_owner.counters())
	var custom_request := explicit("custom-category","armor").merged({"category":"custom-plate"},true)
	var custom: Dictionary = item_owner.construct(requester,custom_request)
	check("published custom category constructs",true,custom.ok)
	if not custom.ok: return terminal(fixture)
	check("custom category recalculates",custom.record,item_owner.recalculate(requester,custom_request,custom.record.id).record)
	check("custom category appearance accepted",true,item_owner.modify(requester,custom_request,custom.record.id,{"dye":"steel"}).ok)
	check("custom category copy accepted",true,item_owner.copy_possession(requester,custom_request.merged({"request":"custom-category-copy"},true),custom.record.id).ok)
	check("unbound requester rejects","unauthorized",item_owner.construct(RefCounted.new(),explicit("foreign")).kind)
	check("worn context required",false,item_owner.construct(requester,explicit("worn-denied","new-only").merged({"condition":1},true)).ok)
	check("copy context required",false,item_owner.copy_possession(requester,{"session":scope,"context":"new-only","request":"denied"},made.record.id).ok)
	var retirement_request := explicit("retire-target")
	var retired: Dictionary = item_owner.construct(requester,retirement_request)
	check("identity retirement succeeds",true,item_owner.retire_identity(requester,retirement_request,retired.record.id).ok)
	check("retired identity does not resolve","missing_or_retired",item_owner.inspect(scope,retired.record.id).kind)
	check("retired request does not regrant","missing_or_retired",item_owner.construct(requester,retirement_request).kind)
	check("retired copy source rejects","missing_or_retired",item_owner.copy_possession(requester,{"session":scope,"context":"weapon","request":"retired-copy"},retired.record.id).kind)
	var after_retirement: Dictionary = item_owner.construct(requester,explicit("after-retirement"))
	check("retirement never reuses identity",false,after_retirement.record.id == retired.record.id)
	property_checks(profiles)
	var bronze: Dictionary = item_owner.construct(requester,explicit("bronze").merged({"material":"bronze"},true))
	var dagger: Dictionary = candidate.resources["item-spell.inputs:catalog"].records["dfu-item-113"].value.data
	check("added material DATA and RULE override",[int(dagger.basePrice)*9+7,0.5,100],[bronze.record.value,bronze.record.weight_kg,bronze.record.maximum_condition])
	check("later consumer readiness stays pending",["combat","equipment","save"],bronze.record.pending_consumers)
	check("added named style mapping",0,item_owner.preview(requester,explicit("named-style").merged({"style":"ceremonial"},true)).record.visual.variant)
	var ammo_request := explicit("arrows","ammo").merged({"quantity":37},true)
	var ammo: Dictionary = item_owner.construct(requester,ammo_request)
	check("explicit ammo count identity material",[37,"stack",""],[ammo.record.quantity,ammo.record.id.category,ammo.record.material])
	check("explicit ammo material not ignored",false,item_owner.construct(requester,ammo_request.merged({"request":"bad-arrows","material":"iron"},true)).ok)
	check("ammo numeric maximum is explicit",2147483647,item_owner.preview(requester,ammo_request.merged({"quantity":2147483647},true)).record.quantity)
	check("ammo overflow rejects",false,item_owner.preview(requester,ammo_request.merged({"quantity":2147483648},true)).ok)
	var clothes: Dictionary = item_owner.construct(requester,explicit("clothing","clothing").merged({"dye":"aquamarine"},true))
	check("clothing explicit palette and morphology",["aquamarine","male-human"],[clothes.record.dye,clothes.record.body])
	check("clothing unsupported body rejects",false,item_owner.modify(requester,explicit("clothing","clothing"),clothes.record.id,{"body":"female-human"}).ok)
	check("explicit construction copy modification draw nothing",0,core.randomness.snapshot().sources.loot.logical_count)
	source_before = core.randomness.snapshot()
	var distribution: Dictionary = item_owner.distribution(requester,request,10)
	check("live exact distribution counts",[65,128,69,20,11],[distribution.materials.iron,distribution.materials.steel,distribution.categories.leather,distribution.categories.chain,distribution.categories.plate])
	check("inspection isolated from live source",source_before,core.randomness.snapshot())
	check("low level actual distribution",101,item_owner.distribution(requester,request,1).materials.iron)
	var alternative: Dictionary = item_owner.distribution(requester,request,777)
	check("selected mod material distribution",{"bronze":256},alternative.materials)
	check("mod distribution also draws nothing",source_before,core.randomness.snapshot())
	var generated_bronze: Dictionary = item_owner.generate(requester,{"session":scope,"context":"weapon","request":"mod-generated-bronze","level":777,"body":"male-human"})
	check("complete added material generation through published hook","bronze",generated_bronze.record.material)
	var unsupported_request := {"session":scope,"context":"armor","request":"unsupported-generated-material","level":778,"body":"male-human"}
	var count_before: int = item_owner.counters().possessions
	check("unsupported generated material fails explicitly",false,item_owner.generate(requester,unsupported_request).ok)
	var retained_source: Dictionary = core.randomness.snapshot()
	check("unsupported generation retry does not substitute",false,item_owner.generate(requester,unsupported_request).ok)
	check("unsupported generation never resamples",retained_source,core.randomness.snapshot())
	check("unsupported generation publishes no item",count_before,item_owner.counters().possessions)
	selector_checks(profiles.policy.value.selector)
	generation_checks(core)
	var partial_request := {"session":scope,"context":"armor","request":"partial-generation","level":10,"body":"male-human"}
	replacement.interrupt = true
	var category_calls: int = replacement.category_calls
	source_before = core.randomness.snapshot()
	var interrupted: Dictionary = item_owner.generate(requester,partial_request)
	check("partial generation source outage rejects",false,interrupted.ok)
	var partial: Dictionary = item_owner.generation_projection(requester,partial_request).generation
	check("partial category retained without material",["plate",true,false],[partial.decisions.category,partial.draws.has("category"),partial.draws.has("material")])
	check("partial category raw drawn once",int(source_before.sources.loot.logical_count)+1,core.randomness.snapshot().sources.loot.logical_count)
	replacement.interrupt = false
	core.randomness.suspend_operation(false)
	var recovered: Dictionary = item_owner.generate(requester,partial_request)
	check("partial retry completes retained category",true,recovered.ok and recovered.record.category == "plate")
	check("partial retry does not invoke category again",category_calls+1,replacement.category_calls)
	started = Time.get_ticks_usec()
	for i in 200: item_owner.preview(requester,explicit("measurement"))
	observations.preview_200_usec = Time.get_ticks_usec()-started
	started = Time.get_ticks_usec()
	for i in 200: item_owner.construct(requester,explicit("measure-"+str(i)))
	observations.construction_200_usec = Time.get_ticks_usec()-started
	check("measured batch constructed",true,item_owner.counters().possessions >= 207)
	if DisplayServer.get_name() != "headless":
		# A separate DEV layer cannot be overwritten by deferred stock shell renders.
		var original_view: Dictionary = item_owner.inspect(scope,made.record.id).record
		var copy_view: Dictionary = item_owner.inspect(scope,copied.record.id).record
		var overlay := inspection(shell,original_view,copy_view)
		await capture(shell,"item-construction-isolation")
		var texts: Array = overlay.get_node("Inspection/Rows").get_children().map(func(label: Label): return label.text)
		check("rendered diagnostic composition",true,overlay.get_node("Inspection").is_visible_in_tree() and appearance_text("Original",original_view) in texts and appearance_text("Copy",copy_view) in texts)
		overlay.queue_free()
	before = item_owner.counters()
	replacement.invalid_value = true
	var failed_provider: Dictionary = item_owner.construct(requester,explicit("failed-provider"))
	check("invalid selected provider stops without fallback","invalid_result",failed_provider.kind)
	check("provider failure allocates nothing",before,item_owner.counters())
	check("provider failure enters CORE recovery",[false,false],[core.snapshot().ready,core.gates.safe])
	check("failed provider stays selected","construction.test",controller.providers.formulas.active().winners["item.value"])
	var stale_scope := scope
	core.request({"id":"end-construction-session","mode":"return","origin":scope})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)
	check("ended session cannot construct","stale_session",item_owner.construct(requester,request).kind)
	check("ended session cannot inspect","stale_session",item_owner.inspect(stale_scope,made.record.id).kind)
	check("retirement clears owned facts",0,item_owner.counters().possessions)
	replacement.invalid_value = false
	check("new CORE scope starts independently","Succeeded",core.request({"id":"second-construction-session","mode":"new","origin":""}).kind)
	scope = core.snapshot().session
	var second: Dictionary = item_owner.construct(requester,explicit("second-branch-first"))
	check("new branch may repeat numeric identity",made.record.id,second.record.id)
	check("old session request rejects despite matching identity","stale_session",item_owner.modify(requester,request,made.record.id,{"dye":"red"}).kind)
	check("old scope cannot inspect new matching identity","stale_session",item_owner.inspect(stale_scope,made.record.id).kind)
	check("stale callback preserves new branch item",second.record,item_owner.inspect(scope,second.record.id).record)
	core.request({"id":"end-second-session","mode":"return","origin":scope})
	if core.snapshot().phase == "confirmation": core.confirm(core.ticket(),true)
	replacement.core = null
	return terminal(fixture)

func appearance_text(prefix: String, record: Dictionary) -> String:
	return "%s: %s:%s | %s / %s / %s | condition %d/%d | archive %d record %d" % [prefix,record.id.category,record.id.number,record.material,record.dye,record.body,record.condition,record.maximum_condition,record.visual.archive,record.visual.record]

func inspection(shell: Control, original: Dictionary, copied: Dictionary) -> CanvasLayer:
	var overlay := CanvasLayer.new()
	overlay.layer = 100
	shell.add_child(overlay)
	var panel := PanelContainer.new()
	panel.name = "Inspection"
	overlay.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 36
	panel.offset_top = 36
	panel.offset_right = -36
	panel.offset_bottom = -36
	var style := StyleBoxFlat.new()
	style.bg_color = Color("17212a")
	style.content_margin_left = 24
	style.content_margin_top = 24
	style.content_margin_right = 24
	style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel",style)
	var rows := VBoxContainer.new()
	rows.name = "Rows"
	rows.add_theme_constant_override("separation",24)
	panel.add_child(rows)
	for text in ["ITEM construction inspection — controlled requester",appearance_text("Original",original),appearance_text("Copy",copied),"Armor categories: 69 / 20 / 11. Preview creates no possession and consumes no draws.","Construction only. Collections, equipment, combat and SAVE integration remain pending."]:
		var label := Label.new()
		label.text = text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size",22)
		rows.add_child(label)
	return overlay

func identity_checks() -> void:
	var allocator := Allocator.new({"item":"9007199254740992","stack":"18446744073709551614"})
	check("decimal above float exact boundary","9007199254740993",allocator.allocate("item").id.number)
	check("full unsigned 64 bit final allocation","18446744073709551615",allocator.allocate("stack").id.number)
	check("exhaustion explicit no wrap","identity_exhausted",allocator.allocate("stack").kind)
	check("exhaustion repeated no reuse","identity_exhausted",allocator.allocate("stack").kind)
	var bad := []
	for value in ["0","00","01","-1","+1","1.0","1e3"," 1","18446744073709551616",9007199254740992.0,null,""]:
		bad.append(Allocator.valid(value))
	check("canonical decimal parsing rejects invalid",[false,false,false,false,false,false,false,false,false,false,false,false],bad)
	check("zero high water only",[true,false],[Allocator.valid("0",true),Allocator.valid("0")])
	var burned: Dictionary = allocator.allocate("item")
	check("unused allocation never reused","9007199254740995",allocator.allocate("item").id.number)
	check("decimal serialization round trip",burned.id,JSON.parse_string(JSON.stringify(burned.id)))
	check("invalid high water fails without assertions","invalid_identity_state",Allocator.new({"item":"18446744073709551616"}).allocate("item").kind)

func property_checks(profiles: Dictionary) -> void:
	var table := [["iron",3,4,4],["steel",6,5,6],["silver",12,4,6],["elven",24,4,8],["dwarven",48,3,12],["mithril",96,4,16],["adamantium",192,4,20],["ebony",384,2,24],["orcish",768,4,28],["daedric",1536,5,32]]
	var actual := []
	var expected := []
	for row in table:
		var request := explicit("table-"+row[0]).merged({"material":row[0]},true)
		var result: Dictionary = item_owner.preview(requester,request)
		var base: Dictionary = item_owner.definitions.query("item-spell.inputs","catalog","dfu-item-113").record.value.data
		var coeff: Dictionary = profiles[row[0]].value.coefficients
		actual.append([coeff.value,coeff.weight,coeff.condition,result.record.value,result.record.maximum_condition])
		expected.append([row[1],row[2],row[3],int(base.basePrice)*int(row[1]),50*int(row[3])/4])
	check("all exact baseline material coefficients and properties",expected,actual)
	var formula := ItemFormula.new()
	var weights := []
	for base in [500000,1500000,625000,1999999]:
		weights.append(formula.weight({"base":base,"mode":"material","coefficients":{"value":6,"weight":5,"condition":6}}))
	check("nearest even midpoint and base truncation",[500000,2000000,500000,2250000],weights)
	check("maximum condition truncates fractional result",7,formula.condition({"base":5,"mode":"material","coefficients":{"value":6,"weight":5,"condition":6}}))
	var leather := explicit("leather","armor")
	leather.erase("material")
	leather.category = "leather"
	var chain := leather.merged({"request":"chain","category":"chain"},true)
	var a: Dictionary = item_owner.preview(requester,leather)
	var b: Dictionary = item_owner.preview(requester,chain)
	var c: Dictionary = item_owner.preview(requester,explicit("plate","armor"))
	check("leather chain plate exact body properties",[6.25,12.5,15.5,0,4,1],[a.record.weight_kg,b.record.weight_kg,c.record.weight_kg,a.record.visual.variant,b.record.visual.variant,c.record.visual.variant])
	var base: Dictionary = item_owner.definitions.query("item-spell.inputs","catalog","dfu-item-102").record.value.data
	check("leather chain plate exact base value",[int(base.basePrice),int(base.basePrice)*2,int(base.basePrice)*6],[a.record.value,b.record.value,c.record.value])

func selector_checks(policy: Dictionary) -> void:
	var formula := ItemFormula.new()
	var actual := []
	var expected := []
	# Independent reference interval ends from the approved strict table.
	var ends := [64,192,202,223,236,244,249,252,254,259]
	for level in [-1000000,1,9,10,11,50,1000000]:
		var offset: int = (level-10)*(4 if level < 10 else 2)
		for raw in 256:
			var x: int = clampi(raw+offset,0,256)
			var reference := 0
			while x > ends[reference]: reference += 1
			expected.append(reference)
			actual.append(formula.material({"raw":raw,"level":level,"policy":policy}))
	check("enumerated 1792 raw level clamp mappings",expected,actual)
	actual = []
	for raw in [0,64,65,192,193,255]: actual.append(formula.material({"raw":raw,"level":10,"policy":policy}))
	check("strict traversal equality endpoints",[0,0,1,1,2,9],actual)
	actual = []
	for raw in [0,68,69,88,89,99]: actual.append(formula.category({"raw":raw,"level":10,"policy":policy}))
	check("exact armor category interval boundaries",[0,0,1,1,2,2],actual)

func generation_checks(core: SessionLifecycle) -> void:
	var selected: Dictionary = {}
	var retained := true
	var no_plate := true
	for i in 100:
		var request := {"session":scope,"context":"armor","request":"generated-"+str(i),"level":10,"body":"male-human"}
		var before: Dictionary = core.randomness.snapshot()
		var result: Dictionary = item_owner.generate(requester,request)
		if not result.ok:
			check("generation all supported results",true,result)
			return
		selected[result.record.category] = true
		var after: Dictionary = core.randomness.snapshot()
		var state: Dictionary = item_owner.generation_projection(requester,request).generation
		if result.record.category != "plate": no_plate = no_plate and not state.draws.has("material")
		retained = retained and item_owner.generate(requester,request) == result and core.randomness.snapshot() == after
		if selected.size() == 3: break
	check("generated category coverage",3,selected.size())
	check("leather chain skip plate material draws",true,no_plate)
	check("generation retry retains every decision no redraw",true,retained)
	var arrows := {"session":scope,"context":"ammo","request":"generated-arrows","level":1,"body":"male-human"}
	var ammo: Dictionary = item_owner.generate(requester,arrows)
	check("declared random ammo inclusive range",true,ammo.ok and ammo.record.quantity >= 1 and ammo.record.quantity <= 20 and ammo.record.material == "")
	var clothes := {"session":scope,"context":"clothing","request":"generated-clothes","level":1,"body":"male-human"}
	var clothing: Dictionary = item_owner.generate(requester,clothes)
	check("declared clothing generation retains supported dye",true,clothing.ok and clothing.record.dye in ["blue","grey","red","dark-brown","purple","light-brown","white","aquamarine","yellow","green"])
	var projection: Dictionary = item_owner.generation_projection(requester,clothes)
	projection.generation.decisions.dye = "foreign"
	check("generation projection detached",false,item_owner.generation_projection(requester,clothes).generation.decisions.dye == "foreign")
	var before_retry: Dictionary = core.randomness.snapshot()
	check("clothing dye style retry retains outcome",clothing,item_owner.generate(requester,clothes))
	check("arrow quantity retry retains outcome",ammo,item_owner.generate(requester,arrows))
	check("clothing arrow retries do not redraw",before_retry,core.randomness.snapshot())
	var pool_request := {"session":scope,"context":"weapons-pool","request":"explicit-template-pool","level":10,"body":"male-human"}
	var pooled: Dictionary = item_owner.generate(requester,pool_request)
	check("explicit multi template pool resolves",true,pooled.ok and pooled.record.profile in ["dfu-item-113","dfu-item-114"])
	var pool_state: Dictionary = item_owner.generation_projection(requester,pool_request).generation
	check("template draw retained",true,pool_state.draws.has("template"))
	before_retry = core.randomness.snapshot()
	check("template retry retains assigned possession",pooled,item_owner.generate(requester,pool_request))
	check("template retry does not redraw",before_retry,core.randomness.snapshot())

func terminal(fixture: Dictionary) -> Dictionary:
	var ok := true
	for entry in checks: ok = ok and Construction.N.equal_input(entry.expected,entry.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"fixture":fixture.fixture,"inputs":fixture.inputs,"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"observations":observations,"downstream":"Construction only; collections/equipment/combat/SAVE pending."}
