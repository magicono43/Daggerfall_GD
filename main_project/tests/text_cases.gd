extends "res://tests/mod_cases.gd"
const Catalog = preload("res://scripts/data/text_catalog.gd")
const Csv = preload("res://scripts/data/text_csv.gd")
const Tokens = preload("res://scripts/data/text_tokens.gd")
const Core = preload("res://scripts/session/session_lifecycle.gd")
const Owner = preload("res://tests/controlled_random_owner.gd")
const Seeds = preload("res://scripts/rule/seed_derivation.gd")

func material(_ticket: Dictionary, _mode: String) -> Dictionary:
	var bytes := PackedByteArray()
	bytes.resize(32)
	return Seeds.validate_material(bytes)

func capture(shell: Control, name: String) -> void:
	# Settle container layout and explicitly draw the current viewport before
	# synchronous readback in the isolated rendered fixture.
	for frame in range(3):
		await shell.get_tree().process_frame
	RenderingServer.force_draw(false)
	var image := shell.get_viewport().get_texture().get_image()
	check(name + " frame available",false,image.is_empty())
	image.save_png(sandbox.path_join(name + ".png"))

func row(key: String, locale: String, value: String, operation := "add", base := "en", required := "", optional := false, essential := false, suppress := false, collection := "sample") -> Array:
	return [Catalog.SCHEMA,Tokens.VERSION,collection,locale,key,operation,base,str(optional),str(essential),required,str(suppress),value]

func csv(rows: Array, ending := "\n") -> String:
	var lines: Array[String] = []
	for fields: Array in [Catalog.HEADER] + rows:
		var escaped: Array[String] = []
		for field in fields:
			escaped.append('"' + str(field).replace('"','""') + '"')
		lines.append(",".join(escaped))
	return ending.join(lines) + ending

func source(name := "fixture.csv") -> Dictionary:
	return {"provider":"test.provider","file":name,"root":sandbox,"version":"1.0.0","token":name}

func apply(adapter: RefCounted, base: Dictionary, rows: Array, name := "fixture.csv") -> Dictionary:
	return adapter.apply_csv(base,csv(rows).to_utf8_buffer(),source(name))

func entry(resources: Dictionary, key: String, locale := "en") -> Dictionary:
	return resources[Catalog.DOMAIN + ":sample"].records[key].value.entries[locale]

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	sandbox = fixture.sandbox
	if DisplayServer.get_name() != "headless":
		await capture(shell,"text-independent-recovery")
		check("recovery controls without classic or optional catalogs",true,find_button(shell.panel,"Retry") != null and find_button(shell.panel,"Choose Folder") != null and find_button(shell.panel,"Quit") != null)
		shell.panel.get_parent().ensure_control_visible(find_button(shell.panel,"Quit"))
		await capture(shell,"text-independent-quit")
	var adapter := Catalog.new()
	check("schema frozen","text-catalog-v1",Catalog.SCHEMA)
	check("CSV frozen","text-csv-v1",Csv.VERSION)
	check("codec frozen","text-token-v1",Tokens.VERSION)
	var raw := "  comma, quote \"x\"\n second line  "
	for ending in ["\n","\r\n"]:
		var parsed := Csv.parse(csv([row("spaces","en",raw)],ending).to_utf8_buffer())
		check("complete quoting and whitespace " + str(ending.length()),raw,parsed.rows[1].fields[11])
	check("BOM accepted",true,Csv.parse((String.chr(0xfeff) + csv([row("x","en","X")])).to_utf8_buffer()).ok)
	check("final record without terminator",true,Csv.parse(csv([row("x","en","X")]).trim_suffix("\n").to_utf8_buffer()).ok)
	for invalid: String in ['a,b\n"unterminated','a,b\n"closed"junk,x','a,b\nquo"te,x',"a,b\rx,y",""]:
		check("CSV rejects complete malformed input " + str(checks.size()),false,Csv.parse(invalid.to_utf8_buffer()).ok)
	check("NUL bytes rejected",false,Csv.parse(PackedByteArray([97,0,98])).ok)
	check("invalid UTF8 rejected",false,Csv.parse(PackedByteArray([0xff])).ok)
	check("trailing empty field preserved",["a",""],Csv.parse("a,".to_utf8_buffer()).rows[0].fields)
	check("blank physical row retained",[""],Csv.parse("a\n\n".to_utf8_buffer()).rows[1].fields)
	check("physical multiline next-row position",4,Csv.parse('a,b\n"x\ny",z\nq,r'.to_utf8_buffer()).rows[2].line)
	check("literal escapes",[{"kind":"text","text":"{literal} %pcname"}],Tokens.parse("{{literal}} %pcname",[]).tokens)
	check("distinct line token",[{"kind":"text","text":" a "},{"kind":"line_break"},{"kind":"text","text":" b "}],Tokens.parse(" a \n b ",[]).tokens)
	var baseline := apply(adapter,{},[
		row("greeting","en","Hello {name:string:plain}, {count:int:d}","add","en","name:string:plain|count:int:d"),
		row("greeting","zz-Test","{count:int:d}: {name:string:plain}","add","en","count:int:d|name:string:plain"),
		row("blank","en","Base blank"),row("blank","zz-Test","  \t "),
		row("missing","en","Base missing"),row("broken","en","Base {count:int:d}","add","en","count:int:d"),
		row("broken","zz-Test","Old {count:int:d}","add","en","count:int:d"),
		row("foreign","zz-Test","Original","add","zz-Test"),row("foreign","en","English translation","add","zz-Test"),
		row("empty","en",""),row("optional","en","Show","add","en","",true),
		row("optional","zz-Test","","add","en","",true,false,true),row("spaces","en",raw)])
	check("valid sparse catalog",true,baseline.ok)
	var replaced := apply(adapter,baseline.resources,[row("broken","zz-Test","Wrong {count:string:plain}","replace","en","count:int:d"),row("foreign","en","New English","replace","zz-Test")],"replacement.csv")
	check("malformed placeholder is structural success",true,replaced.ok)
	check("malformed placeholder remains winning text","Wrong {count:string:plain}",entry(replaced.resources,"broken","zz-Test").text)
	check("malformed placeholder unusable",false,entry(replaced.resources,"broken","zz-Test").usable)
	check("winning provenance","replacement.csv",entry(replaced.resources,"broken","zz-Test").winner.file)
	check("ordered contribution provenance",2,entry(replaced.resources,"broken","zz-Test").contributors.size())
	check("original base retained","zz-Test",replaced.resources[Catalog.DOMAIN + ":sample"].records.foreign.value.base)
	check("original key identity retained",baseline.resources[Catalog.DOMAIN + ":sample"].records.foreign.identity,replaced.resources[Catalog.DOMAIN + ":sample"].records.foreign.identity)
	check("original key provenance retained",baseline.resources[Catalog.DOMAIN + ":sample"].records.foreign.origin,replaced.resources[Catalog.DOMAIN + ":sample"].records.foreign.origin)
	var original: Dictionary = baseline.resources.duplicate(true)
	var empty_json := JSON.stringify({"domain":Catalog.DOMAIN,"path":"sample","operation":"replace","entries":[]}).to_utf8_buffer()
	check("JSON cannot erase CSV collection through empty replacement",false,shell.controller.providers.definitions.apply_contribution(baseline.resources,empty_json,source("attempt.json")).ok)
	var failures := [
		[row("new","en","Would leak"),row("missing","en","Collision")],
		[row("new","en","Would leak"),row("absent","zz-Test","Missing","replace")],
		[row("new","en","First"),row("new","en","First")],
		[row("new","en","Good"),row("late","en","Bad","upsert")],
		[row("foreign","en","Wrong base","replace","en")],
		[row("not-optional","en","","add","en","",false,false,true)],
		[row("essential","en","","add","en","",true,true,true)],
		[row("new","en","Good"),["malformed"]]]
	for rows: Array in failures:
		var rejected := apply(adapter,baseline.resources,rows)
		check("whole file rejects " + str(checks.size()),false,rejected.ok)
		check("input immutable after rejected file " + str(checks.size()),original,baseline.resources)
	check("add translation uses locale presence",true,apply(adapter,baseline.resources,[row("missing","zz-Test","New translation")]).ok)
	check("replace requires target locale presence",false,apply(adapter,baseline.resources,[row("missing","zz-Test","No translation","replace")]).ok)
	var malformed := csv([row("new","en","Good")]) + '"unterminated'
	check("malformed final CSV row rejects whole contribution",false,adapter.apply_csv(baseline.resources,malformed.to_utf8_buffer(),source()).ok)
	check("malformed CSV has zero mutations",original,baseline.resources)
	check("collection normalization explicit",false,apply(adapter,{},[row("x","en","X","add","en","",false,false,false,"Mixed")]).ok)
	check("keys never trim whitespace",false,apply(adapter,{},[row(" x","en","X")]).ok)
	check("locale whitespace invalid",false,apply(adapter,{},[row("x"," en","X")]).ok)
	check("unsupported codec rejects whole contribution",false,adapter.apply_csv({},csv([row("x","en","X")]).replace("text-token-v1","text-token-v2").to_utf8_buffer(),source()).ok)
	check("changed type unusable",false,Tokens.parse("{count:string:plain}",["count:int:d"]).ok)
	check("missing reference unusable",false,Tokens.parse("No value",["count:int:d"]).ok)
	check("unsupported format unusable",false,Tokens.parse("{count:int:x}",["count:int:d"]).ok)
	# Candidate/lock behavior through actual MOD, classic readers and CORE menu entry.
	var controller: RefCounted = shell.controller
	var mods: RefCounted = controller.mods
	var registry: RefCounted = controller.providers.definitions
	controller.settings.apply({"startup/show_setup":true})
	controller.settings.effective["startup/show_setup"] = true
	var root: String = mods.root.path_join("Mods")
	var a := manifest("text.a")
	a.content = ["z.csv","a.csv"]
	write(root.path_join("A/mod.json"),JSON.stringify(a))
	write(root.path_join("A/a.csv"),csv([
		row("greeting","en","Hello {name:string:plain}, {count:int:d}","add","en","name:string:plain|count:int:d"),
		row("greeting","zz-Test","{count:int:d}: {name:string:plain}","add","en","name:string:plain|count:int:d"),
		row("blank","en","Base blank"),row("blank","zz-Test","  "),row("missing","en","Base missing"),
		row("broken","en","Base {count:int:d}","add","en","count:int:d"),row("broken","zz-Test","Old {count:int:d}","add","en","count:int:d"),
		row("foreign","zz-Test","Original","add","zz-Test"),row("foreign","en","English","add","zz-Test"),
		row("empty","en",""),row("optional","en","Show","add","en","",true),row("optional","zz-Test","","add","en","",true,false,true),
		row("order","en","A first")]))
	write(root.path_join("A/z.csv"),csv([row("order","en","A last","replace")]))
	var b := manifest("text.b")
	b.dependencies = [{"id":"text.a"}]
	b.content = ["patch.csv","bad.csv"]
	write(root.path_join("B/mod.json"),JSON.stringify(b))
	write(root.path_join("B/patch.csv"),csv([row("order","en","B","replace"),row("foreign","en","New English","replace","zz-Test"),row("broken","zz-Test","Bad {count:string:plain}","replace","en","count:int:d"),row("retry","en","","replace","en","",false,true,false,"recovery")]))
	write(root.path_join("B/bad.csv"),csv([row("leak","en","Would leak"),row("late","en","Invalid","delete")]))
	# Use the application's original registry, composed by the normal shell before
	# source preparation. Duplicate registration cannot replace that domain owner.
	check("duplicate text schema registration rejected",false,controller.providers.register_bundled_text().ok)
	write(mods.root.path_join("Overrides/final.csv"),csv([row("order","en","Loose","replace")]))
	mods.rescan()
	mods.edit("text.a","toggle")
	mods.edit("text.b","toggle")
	controller.select_folder(fixture.classic_source)
	check("actual dependency order",["text.a","text.b"],mods.validate_dependencies().order)
	check("invalid file blocks real menu","package_recovery",controller.route)
	check("no invalid candidate publication","before_readiness",registry.query(Catalog.DOMAIN,"sample","order").kind)
	var candidate: Dictionary = registry.projection()
	check("zero partial mutation",false,candidate.resources[Catalog.DOMAIN + ":sample"].records.has("leak"))
	check("loose tier wins failed diagnostic candidate","Loose",entry(candidate.resources,"order").text)
	check("contribution order",["text.a","text.a","text.b","@loose"],candidate.resources[Catalog.DOMAIN + ":sample"].records.order.contributors.map(func(p: Dictionary): return p.provider))
	check("failed menu entry stays failed","package_recovery",controller.continue_to_menu("run").route)
	candidate = registry.projection()
	check("explicit omission accepts file",true,registry.omit(candidate.issues[0].token,candidate.ticket,mods).ok)
	controller.check_content()
	check("clean omission rebuild validates",true,registry.projection().ok)
	check("omitted whole file retained",1,registry.projection().omitted.size())
	var resources: Dictionary = registry.projection().resources
	controller.check_content()
	check("repeat clean candidate deterministic",resources,registry.projection().resources)
	check("actual menu entry", "main_menu",controller.continue_to_menu("run").route)
	check("published resource locked",true,registry.active().ready)
	var core := Core.new(material)
	var owner := Owner.new()
	core.provider = owner
	core.startup_route_changed("main_menu")
	check("controlled ready owner with real CORE/RULE","Succeeded",core.request({"id":"text-owner","mode":"new","origin":""}).kind)
	var granted: Dictionary = core.randomness.source(core.snapshot().session,owner,"quest")
	check("explicit bound source ready",true,granted.ok)
	check("owner creates one retained result",true,owner.prepare_reward("text-retained",granted.source).ok)
	var before: Dictionary = core.randomness.snapshot()
	var facts: Dictionary = owner.retained_snapshot()
	var active: Dictionary = registry.active()
	var plan: Dictionary = mods.planning_input()
	var selected := Catalog.lookup(registry,"sample","greeting","zz-Test")
	check("selected reordered references","{count:int:d}: {name:string:plain}",selected.text)
	check("selected status","selected",selected.kind)
	check("missing selected uses base","Base missing",Catalog.lookup(registry,"sample","missing","zz-Test").text)
	check("blank selected uses base","Base blank",Catalog.lookup(registry,"sample","blank","zz-Test").text)
	var broken := Catalog.lookup(registry,"sample","broken","zz-Test")
	check("bad winner falls to base never old translation","Base {count:int:d}",broken.text)
	check("invalid winner diagnosed","text.b",broken.diagnostics[0].source.provider)
	check("invalid winner position retained",true,broken.diagnostics[0].position >= 0)
	check("nonEnglish base","Original",Catalog.lookup(registry,"sample","foreign","absent").text)
	check("translation replacement retains original base","zz-Test",registry.query(Catalog.DOMAIN,"sample","foreign").record.value.base)
	check("optional suppression","suppressed",Catalog.lookup(registry,"sample","optional","zz-Test").kind)
	check("explicit source fallback","Caller",Catalog.lookup(registry,"sample","empty","zz-Test","Caller").text)
	check("unusable source rejected","missing",Catalog.lookup(registry,"sample","empty","absent","{count:int:x}").kind)
	check("redundant locale attempt skipped",["en"],Catalog.lookup(registry,"sample","empty","en").attempts)
	check("no regional inference","base",Catalog.lookup(registry,"sample","greeting","zz-Test-Region").kind)
	check("no cross collection search","missing",Catalog.lookup(registry,"other","greeting","zz-Test").kind)
	var exhausted := Catalog.lookup(registry,"sample","absent","zz-Test")
	check("ordinary visible placeholder",true,exhausted.text.contains("sample/absent locale=zz-Test source="))
	check("missing diagnostics retain query source",true,exhausted.diagnostics.size() > 0)
	for key: String in Catalog.RECOVERY:
		check("bundled recovery " + key,Catalog.RECOVERY[key],Catalog.lookup(registry,"recovery",key,"zz-Test").text)
		check("no classic or catalog recovery " + key,Catalog.RECOVERY[key],Catalog.lookup(null,"recovery",key,"zz-Test").text)
	check("blank essential base uses independent bundled label","essential_fallback",Catalog.lookup(registry,"recovery","retry","zz-Test").kind)
	check("lookup never advances sources",before,core.randomness.snapshot())
	check("lookup never commits retained result",facts,owner.retained_snapshot())
	check("lookup never mutates owners",active,registry.active())
	check("lookup never changes MOD plan",plan,mods.planning_input())
	check("prepare rejects locked resources","locked",registry.prepare(mods).kind)
	check("late schema registration rejected",false,registry.register_adapter(Catalog.new(),"",[]).ok)
	check("MOD order edit locked",false,mods.edit("text.a","toggle").ok)
	var copy: Dictionary = registry.query(Catalog.DOMAIN,"sample","order")
	copy.record.value.entries.en.text = "mutated"
	check("read projection copy","Loose",Catalog.lookup(registry,"sample","order").text)
	if DisplayServer.get_name() != "headless":
		shell.render()
		shell.panel.get_parent().scroll_vertical = 0
		await capture(shell,"text-main-menu")
		check("rendered essential Quit reachable",true,find_button(shell.panel,"Quit") != null)
		check("rendered actual menu identity",true,find_button(shell.panel,"New Game") != null and controller.menu_entered)
	var ok := true
	for item: Dictionary in checks:
		ok = ok and item.expected == item.actual
	var after: Dictionary = core.randomness.snapshot()
	core.dispose()
	return {"ok":ok,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info(),"display":DisplayServer.get_name(),"fixture":"IMP-007-catalog-v1","schema":Catalog.SCHEMA,"codec":Tokens.VERSION,"resource":{"path":"res://content/text/recovery.csv","sha256":FileAccess.get_sha256("res://content/text/recovery.csv")},"inputs":fixture.inputs,"source":fixture.classic_source,"lookup":broken,"publication":registry.active(),"rng_before":before,"rng_after":after,"retained_before":facts,"retained_after":owner.retained_snapshot()}
