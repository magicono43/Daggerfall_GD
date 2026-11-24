extends SceneTree
## Full pinned RDB corpus, independent frozen unknown-action inventory.
const Formats = preload("res://scripts/data/layout_formats.gd")
const Bsa = preload("res://scripts/data/bsa_reader.gd")
var checks: Array = []

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or not args[0].is_absolute_path() or not args[1].is_absolute_path() or FileAccess.file_exists(args[1]):
		quit(2)
		return
	var observation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/classic_unknown_action_observation.json"))
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/profile.json"))
	check("source edition",observation.source_sha256,FileAccess.get_sha256(args[0].path_join("BLOCKS.BSA")))
	check("profile edition",observation.profile_sha256,FileAccess.get_sha256("res://content/layouts/profile.json"))
	var expected := {}
	for record: Dictionary in observation.records:
		if record.qualification == "decoded": expected[str([record.block,int(record.address)])] = record
	var actual := {}
	var archive := Bsa.new()
	if not archive.initialize(args[0].path_join("BLOCKS.BSA")).ok:
		quit(2)
		return
	var decoded_count := 0
	var rejected_count := 0
	for block: Dictionary in profile.blocks:
		if block.format != "RDB": continue
		var payload: Dictionary = archive.read_record({"ordinal":int(block.ordinal)})
		var decoded := Formats.decode(payload.bytes,block.name)
		check("qualification "+block.name,block.qualification == "decoded",decoded.ok)
		if not decoded.ok:
			rejected_count += 1
			check("rejection preserved "+block.name,block.diagnostic.reason,decoded.reason)
			continue
		decoded_count += 1
		for record: Dictionary in decoded.records:
			if not record.has("unused_action"): continue
			var key := str([block.id,record.address])
			check("unknown inventory member "+key,true,expected.has(key) and not actual.has(key))
			actual[key] = true
			if not expected.has(key): continue
			var pin: Dictionary = expected[key]
			check("raw payload retained "+key,true,preload("res://scripts/data/actor_input_formats.gd").equal_input(pin.raw,record.unused_action.raw))
			check("non-executing "+key,true,not record.has("action") and record.unused_action.non_executing and not record.unused_action.gameplay_owner_ready)
			check("stable ID allocated "+key,pin.record,block.records.get(str(record.address)))
	archive.close()
	check("complete qualified unknown inventory",expected.size(),actual.size())
	check("decoded RDB corpus",187,decoded_count)
	check("rejected RDB corpus",0,rejected_count)
	check("all original unknown bytes observed",13,observation.records.size())
	# Every unknown byte value uses the same non-executing boundary; authored
	# unknown actions remain rejected by layout_inputs validation separately.
	var sample: Dictionary = profile.blocks.filter(func(b: Dictionary): return b.name == "B0000000.RDB")[0]
	var source := Bsa.new()
	source.initialize(args[0].path_join("BLOCKS.BSA"))
	var bytes: PackedByteArray = source.read_record({"ordinal":int(sample.ordinal)}).bytes
	source.close()
	var parsed := Formats.decode(bytes,sample.name)
	var flat: Dictionary = parsed.records.filter(func(r: Dictionary): return r.type == "flat")[0]
	for kind in 256:
		if kind in Formats.ACTIONS: continue
		var changed := bytes.duplicate()
		changed[int(flat.resource_offset)+10] = kind
		changed.encode_s32(int(flat.resource_offset)+6,2147483647)
		var result := Formats.decode(changed,sample.name)
		var retained: Array = result.get("records",[]).filter(func(r: Dictionary): return r.address == flat.address)
		check("unknown byte retained without executable target %03d" % kind,true,result.ok and retained.size() == 1 and not retained[0].has("action") and retained[0].unused_action.raw.kind == kind and retained[0].unused_action.raw.target_address == 2147483647)
	var passed := checks.size() == 473
	var ids := {}
	for item: Dictionary in checks:
		passed = passed and not ids.has(item.scenario) and item.expected == item.actual
		ids[item.scenario] = true
	var report := {"schema":"classic-unknown-action-audit-v1","ok":passed,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info().string,"gameplay_ready":false,"observation_sha256":FileAccess.get_sha256("res://tests/classic_unknown_action_observation.json")}
	var file := FileAccess.open(args[1],FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	print("Unknown action corpus: ",checks.size()," checks, passed=",passed)
	quit(0 if passed else 1)
