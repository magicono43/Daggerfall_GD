extends "res://tests/text_cases.gd"
const Inputs = preload("res://scripts/data/item_spell_inputs.gd")
const Formats = preload("res://scripts/data/item_spell_formats.gd")
const Reader = preload("res://scripts/data/item_spell_source_reader.gd")

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})

func envelope(operation: String, entries: Array) -> Dictionary:
	return {"domain":Inputs.DOMAIN,"path":"catalog","operation":operation,"entries":entries}

func at(candidate: Dictionary, id: String) -> Dictionary:
	return candidate.resources[Inputs.DOMAIN+":catalog"].records[id]

func apply_json(registry: RefCounted, base: Dictionary, body: Dictionary) -> Dictionary:
	return registry.apply_contribution(base,JSON.stringify(body).to_utf8_buffer(),{"provider":"items.test","file":"items.json","version":"1.0.0","root":sandbox})

func controlled_owner(stage: String, data: Dictionary) -> Dictionary:
	if stage == "context": return {"ok":true,"value":{"range":data.range,"element":data.element}}
	return {"ok":data.type == 6,"kind":"unsupported","reason":"Controlled effect type unsupported.","value":{"effect":"controlled.holy","parameters":data.duplicate(true)}}

func controlled_magic(request: Dictionary) -> Dictionary:
	if request.stage == "material": return {"ok":request.value == 0,"kind":"unsupported"}
	return {"ok":request.stage != "enchantment" or request.value.type == 26,"kind":"unsupported"}

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	var controller = shell.controller
	var registry: RefCounted = controller.providers.definitions
	var mods: RefCounted = controller.mods
	controller.settings.effective["startup/show_setup"] = true
	var adapter := Inputs.new()
	check("version frozen","item-spell-inputs-v1",Inputs.VERSION)
	check("explicit required source inventory",2,Inputs.sources().size())
	check("read before selection rejected","before_readiness",controller.providers.classic.read_record("SPELLS.STD","0").kind)
	# Loose input is captured before first candidate and wins over all packages.
	write(mods.root.path_join("Overrides/z-items.json"),JSON.stringify(envelope("patch",[{"id":"dfu-item-000","value":{"unused":{"tier":"loose"}}}])))
	controller.select_folder(fixture.classic_source)
	check("whole actual selected inventory prepares","optional_setup",controller.route)
	var candidate: Dictionary = registry.projection()
	check("whole selected baseline resolves",true,candidate.get("ok",false))
	if not candidate.get("ok",false):
		check("baseline diagnostics","valid",JSON.stringify(candidate))
		return terminal(fixture)
	var records: Dictionary = candidate.resources[Inputs.DOMAIN+":catalog"].records
	check("all three actual source families retained",436,records.size())
	check("all packaged item templates retained",288,records.values().filter(func(r: Dictionary): return r.value.kind == "item").size())
	check("all selected spell records retained",89,records.values().filter(func(r: Dictionary): return r.value.kind == "spell_source").size())
	check("all selected magic records retained",59,records.values().filter(func(r: Dictionary): return r.value.kind == "magic_item_source").size())
	var ruby: Dictionary = at(candidate,"dfu-item-000")
	check("independent Ruby supported fields",{"index":0.0,"name":"Ruby","baseWeight":0.25,"hitPoints":1000.0,"capacityOrTarget":0.0,"basePrice":250.0,"enchantmentPoints":1750.0,"rarity":10.0,"variants":12.0,"drawOrderOrEffect":20.0,"isBluntWeapon":false,"isLiquid":false,"isOneHanded":false,"isIngredient":true,"worldTextureArchive":254.0,"worldTextureRecord":0.0,"playerTextureArchive":0.0,"playerTextureRecord":0.0,"dfu_extensions":{}},ruby.value.data)
	check("Ruby explicit classic group mapping",true,ruby.value.mappings.has("group:14:0"))
	check("item baseline explicitly DFU packaged","dfu-packaged-items-v1",ruby.value.input.format)
	check("packaged license hash verified","6e5e22fa760938ab398743150787896bd20fcf4936aad0122704700bad1e669a",FileAccess.get_sha256("res://content/items/DFU_LICENSE.txt"))
	check("deed to gem alias not published",false,ruby.value.mappings.has("group:24:0"))
	check("shipped source uses resource path","res://content/items/dfu-item-templates.json",ruby.value.input.source)
	check("DFU extensions separately retained",true,records.values().any(func(r: Dictionary): return r.value.kind == "item" and r.value.data.dfu_extensions.has("hasNoEncumbrance")))
	var word: Dictionary = at(candidate,"classic-spell-054").value
	var touch: Dictionary = at(candidate,"classic-spell-055").value
	check("independent collision name one","Holy Word",word.data.name)
	check("independent collision name two","Holy Touch",touch.data.name)
	check("collision shares legacy index",[58.0,58.0],[word.data.legacy_index,touch.data.legacy_index])
	check("collision retains distinct range",[3.0,1.0],[word.data.range,touch.data.range])
	check("collision retains source stored costs",[550.0,550.0],[word.data.cost,touch.data.cost])
	check("source element preserved",4,word.data.element)
	check("three source slots retained",3,word.data.effects.size())
	check("unused signed sentinel preserved",-1,word.data.effects[1].type)
	check("unused subtype preserved",-1,word.data.effects[1].subtype)
	check("all duration bytes preserved",[1.0,1.0,1.0],word.data.effects[1].duration)
	check("active effect type subtype",[6.0,1.0],[word.data.effects[0].type,word.data.effects[0].subtype])
	check("active duration raw parameters",[1.0,1.0,1.0],word.data.effects[0].duration)
	check("active chance raw parameters",[10.0,2.0,1.0],word.data.effects[0].chance)
	check("active magnitude raw parameters",[1.0,1.0,1.0,1.0,1.0],word.data.effects[0].magnitude)
	check("unused slot two magnitude untouched",[0.0,1.0,0.0,0.0,0.0],word.data.effects[1].magnitude)
	check("unused slot three magnitude untouched",[0.0,0.0,1.0,0.0,0.0],word.data.effects[2].magnitude)
	check("source spell icon",12,word.data.icon)
	check("all unused format gaps retained",[4,15],[word.data.unused.gap4.size(),word.data.unused.gap15.size()])
	check("known fingerprint bound record identity","selected-installation-2026-11-21-v1",word.input.profile)
	check("physical address kept as provenance",4806,word.data.source_record.offset)
	check("distinct collision definition IDs",false,at(candidate,"classic-spell-054").identity == at(candidate,"classic-spell-055").identity)
	var magic: Dictionary = at(candidate,"classic-magic-000").value
	check("independent magic name","The Masque of Clavicus",magic.data.name)
	check("independent magic base mapping",[25.0,2.0],[magic.data.group,magic.data.group_index])
	check("zero material preserved",0,magic.data.material)
	check("all ten enchantment slots retained",10,magic.data.enchantments.size())
	check("independent artifact source fields",[1.0,1500.0,50000.0],[magic.data.type,magic.data.uses,magic.data.value])
	check("independent special enchantment",{"type":26.0,"parameter":0.0},magic.data.enchantments[0])
	check("no enchantment sentinel retained",{"type":-1.0,"parameter":-1.0},magic.data.enchantments[9])
	check("missing material schema rejected",false,adapter.validate_record("missing-material",Inputs.value("magic_item_source",magic.data.duplicate(true).merged({"material":null},true))).is_empty())
	check("material enchantment production interpretation unavailable","semantic_unavailable",Inputs.validate_magic_interpretation(magic).kind)
	check("controlled complete magic interpretation succeeds",true,Inputs.validate_magic_interpretation(magic,controlled_magic).ok)
	check("controlled magic interpretation cannot certify production",false,Inputs.validate_magic_interpretation(magic,controlled_magic).semantic_ready)
	var unsupported_magic := magic.duplicate(true)
	unsupported_magic.data.enchantments[2].type = 100
	check("unsupported required enchantment rejects whole interpretation",false,Inputs.validate_magic_interpretation(unsupported_magic,controlled_magic).ok)
	check("enchantment interpretation failure retains reference context","enchantment",Inputs.validate_magic_interpretation(unsupported_magic,controlled_magic).reference.stage)
	unsupported_magic = magic.duplicate(true)
	unsupported_magic.data.material = 255
	check("unsupported required material rejects whole interpretation",false,Inputs.validate_magic_interpretation(unsupported_magic,controlled_magic).ok)
	check("material interpretation failure retains reference context","material",Inputs.validate_magic_interpretation(unsupported_magic,controlled_magic).reference.stage)
	var no_enchantment := magic.duplicate(true)
	for slot in 10: no_enchantment.data.enchantments[slot] = {"type":-1,"parameter":-1}
	no_enchantment.data.uses = 0
	no_enchantment.data.value = 0
	check("schema permits zero uses value and no enchantments","",adapter.validate_record("no-enchantment",no_enchantment))
	check("no enchantment does not demand substitute effect",true,Inputs.validate_magic_interpretation(no_enchantment,controlled_magic).ok)
	check("source-only lookup before menu rejected","before_readiness",Inputs.lookup(registry,"dfu-item-000").kind)
	for pair in [["SPELLS.STD","spells-std-v1",89],["MAGIC.DEF","magic-def-v1",59]]:
		var bytes := FileAccess.get_file_as_bytes(fixture.classic_source.path_join(pair[0]))
		check("actual structural count "+pair[0],pair[2],Formats.decode(pair[1],bytes).records.size())
		check("truncated complete file rejects "+pair[0],"malformed",Formats.decode(pair[1],bytes.slice(0,bytes.size()-1)).kind)
		check("trailing byte rejects "+pair[0],"malformed",Formats.decode(pair[1],bytes+PackedByteArray([0])).kind)
		var reader := Reader.new(pair[1])
		check("reader initializes "+pair[0],true,reader.initialize(fixture.classic_source.path_join(pair[0])).ok)
		var detached := reader.read_record("0")
		detached.value.name = "mutation"
		check("reader detached views "+pair[0],false,reader.read_record("0").value.name == "mutation")
		check("missing record distinct "+pair[0],"record_not_found",reader.read_record("99999").kind)
		reader.close()
		check("retired reader rejects "+pair[0],"before_readiness",reader.read_record("0").kind)
	var raw_magic := FileAccess.get_file_as_bytes(fixture.classic_source.path_join("MAGIC.DEF"))
	raw_magic.encode_s32(0,58)
	check("count mismatch rejects entire source","malformed",Formats.decode("magic-def-v1",raw_magic).kind)
	check("unknown format rejected","unsupported",Formats.decode("future",PackedByteArray()).kind)
	check("empty required spell source malformed","malformed",Formats.decode("spells-std-v1",PackedByteArray()).kind)
	check("empty required magic source malformed","malformed",Formats.decode("magic-def-v1",PackedByteArray([0,0,0,0])).kind)
	var vector := PackedByteArray()
	vector.resize(89)
	for slot in 3:
		vector[slot*2] = 255
		vector[slot*2+1] = 255
	var vector_record: Dictionary = Formats.decode("spells-std-v1",vector).records["0"]
	check("schema valid zero cost preserved",0,vector_record.cost)
	check("zero divisor preserved without clamping",0,vector_record.effects[0].duration[2])
	var vector_value := Inputs.value("spell_source",vector_record)
	vector_value.data.erase("kind")
	check("unused only spell input structurally valid","",adapter.validate_record("unused-only",vector_value))
	check("unused only runtime legality remains unavailable","unsupported",Inputs.convert_spell(vector_value,controlled_owner).kind)
	var vector_path := sandbox.path_join("declared-spells.std")
	var file := FileAccess.open(vector_path,FileAccess.WRITE)
	file.store_buffer(vector)
	file.close()
	var lifecycle := Reader.new("spells-std-v1")
	check("synthetic independent source initializes",true,lifecycle.initialize(vector_path).ok)
	vector[10] = 42
	file = FileAccess.open(vector_path,FileAccess.WRITE)
	file.store_buffer(vector)
	file.close()
	check("same length external change requires restart","source_unavailable",lifecycle.read_record("0").kind)
	lifecycle.close()
	DirAccess.remove_absolute(vector_path)
	check("missing declared source differentiated","source_unavailable",lifecycle.initialize(vector_path).kind)
	var unknown := FileAccess.get_file_as_bytes(fixture.classic_source.path_join("SPELLS.STD"))
	unknown[10] = 237
	var unknown_result := Formats.decode("spells-std-v1",unknown)
	check("unknown unused bytes structurally accepted",true,unknown_result.ok)
	check("unknown unused byte preserved",237,unknown_result.records["0"].unused.gap4[0])
	check("unknown edition does not borrow known identity profile",false,unknown_result.profile_known)
	var base: Dictionary = candidate.resources.duplicate(true)
	var added: Dictionary = ruby.value.duplicate(true)
	added.erase("input")
	added.mappings = []
	added.data.index = 500000
	var addition := envelope("add",[{"id":"added-500000","value":added}])
	var applied := apply_json(registry,base,addition)
	check("added item beyond classic limits accepted",true,applied.ok)
	check("addition retains originating package","items.test",at(applied,"added-500000").identity.package)
	check("duplicate definition rejected",false,apply_json(registry,applied.resources,addition).ok)
	check("duplicate IDs within contribution reject",false,apply_json(registry,base,envelope("add",addition.entries+addition.entries)).ok)
	var changed := added.duplicate(true)
	changed.data.name = "New display name"
	changed.data.playerTextureRecord = 99
	var patched := apply_json(registry,applied.resources,envelope("patch",[{"id":"added-500000","value":{"data":changed.data}}]))
	check("name appearance patch retains identity",at(applied,"added-500000").identity,at(patched,"added-500000").identity)
	check("unknown required field rejects",false,adapter.validate_record("bad",added.merged({"execute":"code"})).is_empty())
	var instance_data: Dictionary = added.data.duplicate(true)
	instance_data.quantity = 7
	check("mutable instance quantity rejected in template",false,adapter.validate_record("instance",added.merged({"data":instance_data},true)).is_empty())
	var forged := added.duplicate(true)
	forged.input = {"source":"invented-classic"}
	check("mod cannot invent classic provenance",false,apply_json(registry,base,envelope("add",[{"id":"forged","value":forged}])).ok)
	check("baseline mapping patch cannot remap references",false,apply_json(registry,base,envelope("patch",[{"id":"dfu-item-000","value":{"mappings":["group:14:1"]}}])).ok)
	check("safe unused metadata accepted","",adapter.validate_record("safe",added.merged({"unused":{"future":1}})))
	var special := added.duplicate(true)
	special.behavior = "missing.provider"
	var required := apply_json(registry,base,envelope("add",[{"id":"special","value":special}]))
	check("absent special provider fails required validation",true,adapter.validate_references(required.resources).any(func(i: Dictionary): return i.get("target") == "missing.provider"))
	var removed := base.duplicate(true)
	removed[Inputs.DOMAIN+":catalog"].records.erase("dfu-item-135")
	check("missing required base item fails",true,adapter.validate_references(removed).size() > 0)
	removed = base.duplicate(true)
	removed[Inputs.DOMAIN+":catalog"].records.erase("classic-spell-009")
	check("missing required enchantment spell fails",true,adapter.validate_references(removed).size() > 0)
	var ambiguous := added.duplicate(true)
	ambiguous.mappings = ["group:14:0"]
	check("duplicate item mapping rejected",true,adapter.validate_references(apply_json(registry,base,envelope("add",[{"id":"ambiguous","value":ambiguous}])).resources).size() > 0)
	var bad_reference := added.duplicate(true)
	bad_reference.references = [{"kind":"spell_source","mapping":"spell:58"}]
	var issues := adapter.validate_references(apply_json(registry,base,envelope("add",[{"id":"ambiguous-reference","value":bad_reference}])).resources)
	check("ambiguous required spell reference rejected",true,issues.any(func(i: Dictionary): return i.source.ends_with("#ambiguous-reference") and i.get("candidates",[]).size() == 2))
	var contextual_magic := magic.duplicate(true)
	contextual_magic.data.enchantments[0] = {"type":0,"parameter":58}
	contextual_magic.spell_contexts = {"0":"classic-spell-054"}
	var contextual := apply_json(registry,base,envelope("patch",[{"id":"classic-magic-000","value":{"data":contextual_magic.data,"spell_contexts":contextual_magic.spell_contexts}}]))
	check("explicit magic item spell context resolves collision",0,adapter.validate_references(contextual.resources).size())
	contextual_magic.spell_contexts = {}
	contextual = apply_json(registry,base,envelope("patch",[{"id":"classic-magic-000","value":{"data":contextual_magic.data,"spell_contexts":{}}}]))
	check("magic item collision without context rejects",true,adapter.validate_references(contextual.resources).size() > 0)
	contextual_magic.spell_contexts = {"0":"classic-spell-000"}
	contextual_magic.spell_contexts["0"] = "classic-spell-000"
	contextual = apply_json(registry,base,envelope("patch",[{"id":"classic-magic-000","value":{"data":contextual_magic.data,"spell_contexts":contextual_magic.spell_contexts}}]))
	check("wrong magic item spell context rejects",true,adapter.validate_references(contextual.resources).size() > 0)
	var late := envelope("patch",[{"id":"dfu-item-001","value":{"unused":{"valid":true}}},{"id":"dfu-item-001","value":{"kind":"execute"}}])
	var before := JSON.stringify(base)
	check("late invalid patch rejects whole contribution",false,apply_json(registry,base,late).ok)
	check("late invalid patch leaves prior base unchanged",before,JSON.stringify(base))
	check("ambiguous legacy number cannot target patch",false,apply_json(registry,base,envelope("patch",[{"id":"58","value":{"unused":{}}}])).ok)
	check("MAGIC production converter unavailable","semantic_unavailable",Inputs.convert_spell(word).kind)
	check("empty owner context rejected",false,Inputs.convert_spell(word,func(_stage: String,_data: Dictionary): return {"ok":true}).ok)
	check("empty owner effect settings rejected",false,Inputs.convert_spell(word,func(stage: String,_data: Dictionary): return {"ok":true,"value":{"target":"controlled"}} if stage == "context" else {"ok":true}).ok)
	check("owner rejection without fields remains checked",false,Inputs.convert_spell(word,func(_stage: String,_data: Dictionary): return {}).ok)
	check("complete controlled conversion succeeds",true,Inputs.convert_spell(word,controlled_owner).ok)
	check("controlled conversion cannot claim readiness",false,Inputs.convert_spell(word,controlled_owner).semantic_ready)
	var bundle := word.duplicate(true)
	bundle.data.effects[1].type = 100
	var failed := Inputs.convert_spell(bundle,controlled_owner)
	check("one unsupported active effect rejects whole conversion",false,failed.ok)
	check("conversion failure names effect slot",1,failed.effect)
	check("conversion failure leaks no reduced bundle",false,failed.has("effects"))
	check("conversion leaves input intact",100,bundle.data.effects[1].type)
	var rule := {"id":"controlled-only-v1","approved":true,"approval":"controlled-vector-only","expected":word.data.duplicate(true),"replacement":word.data.merged({"range":1},true)}
	check("conditional correction match",true,Inputs.conditional_correction(word,rule).applied)
	check("conditional correction nonmatch",false,Inputs.conditional_correction(touch,rule).applied)
	check("unapproved correction rejects","unsupported",Inputs.conditional_correction(word,rule.merged({"approved":false},true)).kind)
	var external := word.duplicate(true)
	external.data.cost = 1
	check("externally modified data not overwritten",false,Inputs.conditional_correction(external,rule).applied)
	check("correction source unchanged",550,word.data.cost)
	var corrected := base.duplicate(true)
	corrected[Inputs.DOMAIN+":catalog"].records["classic-spell-054"].value = Inputs.conditional_correction(word,rule).value
	var override_data: Dictionary = word.data.duplicate(true)
	override_data.cost = 0
	var overridden := apply_json(registry,corrected,envelope("patch",[{"id":"classic-spell-054","value":{"data":override_data}}]))
	check("later override wins over controlled baseline correction",0,at(overridden,"classic-spell-054").value.data.cost)
	check("controlled correction retains original receipt",word.data,Inputs.conditional_correction(word,rule).annotation.original)
	check("actual Free Action correction remains disabled",[3.0,2.0],[at(candidate,"classic-spell-009").value.data.effects[0].type,at(candidate,"classic-spell-009").value.data.effects[0].subtype])
	var more_effects := word.duplicate(true)
	more_effects.erase("input")
	more_effects.mappings = []
	more_effects.data.effects = [word.data.effects[0],word.data.effects[0],word.data.effects[0],word.data.effects[0]]
	check("added spell effects exceed classic slot count","",adapter.validate_record("added-spell",more_effects))
	check("all four added active effects convert",4,Inputs.convert_spell(more_effects,controlled_owner).effects.size())
	# Real package intake/recovery uses the actual baseline, never a substitute copy.
	var package := manifest("items.folder")
	package.content = ["patch.json"]
	package.capabilities = ["data."+Inputs.VERSION]
	write(mods.root.path_join("Mods/items/mod.json"),JSON.stringify(package))
	write(mods.root.path_join("Mods/items/patch.json"),JSON.stringify(late))
	mods.rescan()
	mods.edit("items.folder","toggle")
	candidate = registry.prepare(mods)
	check("real invalid folder contribution blocks",false,candidate.ok)
	check("real late patch leaves earlier data unchanged",false,at(candidate,"dfu-item-001").value.has("unused"))
	check("explicit omission accepted",true,registry.omit(candidate.issues[0].token,candidate.ticket,mods).ok)
	check("omission rebuild revalidates",true,registry.prepare(mods).ok)
	write(mods.root.path_join("Mods/items/patch.json"),JSON.stringify(envelope("patch",[{"id":"dfu-item-000","value":{"unused":{"tier":"folder"}}}])))
	var zip_manifest := manifest("items.zip")
	zip_manifest.content = ["add.json"]
	zip_manifest.dependencies = [{"id":"items.folder"}]
	archive(mods.root.path_join("Mods/items.zip"),{"mod.json":JSON.stringify(zip_manifest),"add.json":JSON.stringify(addition)})
	mods.rescan()
	mods.edit("items.zip","toggle")
	candidate = registry.prepare(mods)
	check("real folder ZIP retry succeeds",true,candidate.ok)
	check("real loose override wins","loose",at(candidate,"dfu-item-000").value.unused.tier)
	check("loose winner provenance","@loose",at(candidate,"dfu-item-000").fields.unused.provider)
	check("ZIP addition origin","items.zip",at(candidate,"added-500000").identity.package)
	var replacement: Array = []
	for id: String in candidate.resources[Inputs.DOMAIN+":catalog"].records:
		replacement.append({"id":id,"value":at(candidate,id).value})
	replacement.reverse()
	archive(mods.root.path_join("Mods/items.zip"),{"mod.json":JSON.stringify(zip_manifest),"add.json":JSON.stringify(envelope("replace",replacement))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("real reordered ZIP replacement validates",true,candidate.ok)
	check("replacement retains item identity",ruby.identity,at(candidate,"dfu-item-000").identity)
	check("replacement contributor tracked",true,at(candidate,"dfu-item-001").contributors.any(func(c: Dictionary): return c.provider == "items.zip"))
	var missing_base := replacement.filter(func(entry: Dictionary): return entry.id != "dfu-item-135")
	archive(mods.root.path_join("Mods/items.zip"),{"mod.json":JSON.stringify(zip_manifest),"add.json":JSON.stringify(envelope("replace",missing_base))})
	mods.rescan()
	var blocked: Dictionary = registry.prepare(mods)
	check("real replacement missing base blocks publication",false,blocked.ok)
	check("remaining mandatory reference cannot be omitted",true,blocked.issues.any(func(issue: Dictionary): return issue.kind == "references" and not issue.omittable))
	archive(mods.root.path_join("Mods/items.zip"),{"mod.json":JSON.stringify(zip_manifest),"add.json":JSON.stringify(envelope("replace",replacement))})
	mods.rescan()
	candidate = registry.prepare(mods)
	check("required reference repair retries cleanly",true,candidate.ok)
	var stale: int = candidate.ticket
	registry.prepare(mods)
	check("stale candidate rejects","stale",registry.reserve_commit(stale,mods).kind)
	write(mods.root.path_join("Overrides/z-items.json"),"changed external override")
	check("loose restart rule retained",true,registry.prepare(mods).ok)
	controller.providers.faults.menu = true
	check("interrupted menu publication rejects",false,controller.continue_to_menu("run").ok)
	check("interrupted menu leaves active definitions empty",{},registry.active())
	controller.providers.faults.clear()
	controller.check_content()
	check("normal CORE menu transaction succeeds","main_menu",controller.continue_to_menu("run").route)
	check("published structural lookup succeeds",true,Inputs.lookup(registry,"dfu-item-000").ok)
	check("production item use stays unavailable","semantic_unavailable",Inputs.lookup(registry,"dfu-item-000","construct").kind)
	check("production spell use stays unavailable","semantic_unavailable",Inputs.lookup(registry,"classic-spell-054","cast").kind)
	check("legacy collision remains ambiguous","ambiguous_mapping",Inputs.lookup_classic(registry,"spell_source","spell:58").kind)
	check("explicit Word context resolves","Holy Word",Inputs.lookup_classic(registry,"spell_source","spell:58","classic-spell-054").record.value.data.name)
	check("explicit Touch context resolves","Holy Touch",Inputs.lookup_classic(registry,"spell_source","spell:58","classic-spell-055").record.value.data.name)
	check("missing mapping remains missing","record_not_found",Inputs.lookup_classic(registry,"spell_source","spell:999").kind)
	var view := Inputs.lookup(registry,"dfu-item-000")
	view.record.value.data.name = "caller mutation"
	check("published detached views","Ruby",Inputs.lookup(registry,"dfu-item-000").record.value.data.name)
	check("production readiness remains false",false,Inputs.lookup(registry,"classic-spell-054").semantic_ready)
	check("required missing lookup never returns empty template","missing",Inputs.lookup(registry,"missing-item").kind)
	check("menu locks definitions","locked",registry.prepare(mods).kind)
	check("menu locks MOD",true,mods.locked)
	check("artifact source subset rebuilt coherently",23,Inputs.artifacts(registry).records.size())
	var artifact_view := Inputs.artifacts(registry)
	artifact_view.records[0].value.data.name = "mutation"
	check("artifact projections detached",false,Inputs.artifacts(registry).records[0].value.data.name == "mutation")
	var session_before: Dictionary = shell.session_shell.core.snapshot()
	var catalog_before: Dictionary = registry.active()
	Inputs.lookup(registry,"classic-spell-054")
	Inputs.lookup(registry,"classic-magic-000","construct")
	adapter.validate_references(catalog_before.resources)
	adapter.validate_references(catalog_before.resources)
	check("repeated validation leaves live session unchanged",session_before,shell.session_shell.core.snapshot())
	check("repeated reads leave active definitions unchanged",catalog_before,registry.active())
	controller.open_setup()
	controller.continue_to_menu()
	check("title return preserves run long lock",catalog_before,registry.active())
	if DisplayServer.get_name() != "headless":
		shell.render()
		await capture(shell,"items-spells-main-menu")
		check("rendered actual menu remains reachable",true,find_button(shell.panel,"New Game") != null and controller.menu_entered)
	return terminal(fixture)

func terminal(fixture: Dictionary) -> Dictionary:
	var ok := true
	for item: Dictionary in checks: ok = ok and Inputs.Common.equal_input(item.expected,item.actual)
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":fixture.fixture,"inputs":fixture.inputs,"source":fixture.classic_source,"downstream":"Structural DATA only; real ITEM/MAGIC/SAVE readiness unavailable."}
