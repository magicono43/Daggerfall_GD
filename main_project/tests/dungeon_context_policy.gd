extends SceneTree
## Supplementary pure presentation policy checks; no session/MOVE/SAVE claim.
const Palette = preload("res://scripts/loc/dungeon_palette.gd")
var checks: Array = []

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})

func _initialize() -> void:
	var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/dungeon_context.json")).layouts["place-00032"]
	var site := {"domain":"geography.inputs","package":"@shipped/geography-inputs-v1","local":"packs/classic#place-00032","record":"place-00032"}
	var configuration := {"variation":true,"version":"policy-fixture-v1"}
	var first := Palette.resolve(definition,site,"packs/classic#climate-224",configuration)
	check("policy actual shipped declaration resolves",true,first.ok)
	var changed := configuration.duplicate(true)
	changed.version = "policy-fixture-v2"
	check("policy configuration version invalidates fingerprint",true,first.version != Palette.resolve(definition,site,"packs/classic#climate-224",changed).version)
	changed = configuration.duplicate(true)
	changed.variation = false
	check("policy opt-in input invalidates fingerprint",true,first.version != Palette.resolve(definition,site,"packs/classic#climate-224",changed).version)
	check("policy destination climate invalidates fingerprint",true,first.version != Palette.resolve(definition,site,"packs/classic#climate-231",configuration).version)
	var other_site := site.duplicate(true)
	other_site.local = "packs/classic#place-00016"
	other_site.record = "place-00016"
	check("policy complete destination identity participates",true,first.version != Palette.resolve(definition,other_site,"packs/classic#climate-224",configuration).version)
	var missing := definition.duplicate(true)
	missing.climates.erase("packs/classic#climate-224")
	check("policy selected missing climate has no fallback","missing_palette",Palette.resolve(missing,site,"packs/classic#climate-224",configuration).kind)
	check("policy malformed configuration rejects","invalid_configuration",Palette.resolve(definition,site,"packs/classic#climate-224",{"variation":true}).kind)
	check("policy earlier configuration reconstructs after changes",first,Palette.resolve(definition,site,"packs/classic#climate-224",configuration))
	var environment := preload("res://scripts/loc/dungeon_environment.gd").new()
	var native := {"water":[{"id":"low","pool":"low","surface":2.0,"bounds":[[-2.0,-2.0,-2.0],[2.0,2.0,2.0]],"anchor":[1.0,1.9,0.0],"priority":0,"source":{}},{"id":"high","pool":"high","surface":2.0,"bounds":[[-2.0,-2.0,-2.0],[2.0,2.0,2.0]],"anchor":[-1.0,1.9,0.0],"priority":1,"source":{}}],"areas":[]}
	environment.prepare(native)
	var divider := func(from: Vector3,to: Vector3): return {"ok":true,"found":from.x*to.x < 0}
	check("policy priority fixture qualifies anchors",true,environment.qualify(divider).ok)
	check("policy unproved selected water never falls back","unsupported_environment",environment.query(Vector3(1,1,0),divider).kind)
	var ids := {}
	var passed := checks.size() == 10
	for item: Dictionary in checks:
		passed = passed and not ids.has(item.scenario) and item.expected == item.actual
		ids[item.scenario] = true
	var report := {"schema":"dungeon-context-policy-v1","count":checks.size(),"ok":passed,"checks":checks,"engine":Engine.get_version_info().string,"source_sha256":FileAccess.get_sha256("res://content/layouts/dungeon_context.json"),"session_qualified":false}
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 1 or not arguments[0].is_absolute_path() or FileAccess.file_exists(arguments[0]):
		push_error("One NEW absolute report path required.")
		quit(2)
		return
	var file := FileAccess.open(arguments[0],FileAccess.WRITE)
	if file == null:
		quit(2)
		return
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	print("Dungeon context policy: ",checks.size()," checks, passed=",passed)
	quit(0 if passed else 1)
