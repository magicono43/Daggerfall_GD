extends SceneTree
## Complete vanilla RDB qualification against an independent scalar inventory.
const Formats = preload("res://scripts/data/layout_formats.gd")
const Common = preload("res://scripts/data/actor_input_formats.gd")
const Bsa = preload("res://scripts/data/bsa_reader.gd")
var checks: Array = []

func check(id: String, expected: Variant, actual: Variant) -> void:
	checks.append({"scenario":id,"expected":expected,"actual":actual})

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or not args[0].is_absolute_path() or not args[1].is_absolute_path() or FileAccess.file_exists(args[1]):
		quit(2)
		return
	var pin: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/classic_action_axes_observation.json"))
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/profile.json"))
	check("source edition",pin.source_sha256,FileAccess.get_sha256(args[0].path_join("BLOCKS.BSA")))
	var archive := Bsa.new()
	if not archive.initialize(args[0].path_join("BLOCKS.BSA")).ok:
		quit(2)
		return
	var actual := 0
	for block: Dictionary in pin.blocks:
		var mapping: Dictionary = profile.blocks.filter(func(b: Dictionary): return b.name == block.name)[0]
		var payload: Dictionary = archive.read_record({"ordinal":int(mapping.ordinal)})
		var decoded := Formats.decode(payload.bytes,block.name)
		check("decoded "+block.name,true,decoded.ok)
		check("record count "+block.name,block.records,decoded.get("records",[]).size())
		check("source hash "+block.name,block.sha256,Common.sha256(payload.bytes))
		check("complete stable IDs "+block.name,true,decoded.ok and decoded.records.all(func(r: Dictionary): return mapping.records.has(str(r.address))))
		for record: Dictionary in decoded.get("records",[]):
			if not record.has("action_axis_metadata"): continue
			actual += 1
			var matches: Array = pin.records.filter(func(r: Dictionary): return r.name == block.name and r.address == record.address)
			check("unique axis member %s/%d" % [block.name,record.address],1,matches.size())
			if matches.size() != 1: continue
			var expected: Dictionary = matches[0]
			check("raw axis payload %s/%d" % [block.name,record.address],true,Common.equal_input(expected.raw,record.action_axis_metadata.raw))
			check("model tag %s/%d" % [block.name,record.address],expected.description,record.model.description)
			check("known graph retained %s/%d" % [block.name,record.address],true,record.has("action") and record.action.kind == expected.raw.kind and record.action.target_address == expected.raw.target_address and not record.has("unused_action"))
			var baseline := "rotation-negative-x-magnitude-400" if expected.raw.kind == 8 and expected.raw.axis == 13 and expected.description == "TRP" else "zero-motion-vector"
			check("pending interpretation %s/%d" % [block.name,record.address],true,not record.action_axis_metadata.gameplay_owner_ready and record.action_axis_metadata.dfu_baseline == baseline)
	check("complete axis inventory",11,actual)
	check("complete block inventory",187,pin.blocks.size())
	# Accepting an exceptional axis must not relax a known action's graph.
	for kind in [1,8]:
		var sample: Dictionary = pin.records.filter(func(r: Dictionary): return r.raw.kind == kind)[0]
		var mapping: Dictionary = profile.blocks.filter(func(b: Dictionary): return b.name == sample.name)[0]
		var bytes: PackedByteArray = archive.read_record({"ordinal":int(mapping.ordinal)}).bytes
		bytes.encode_s32(int(sample.action_offset)+5,2147483647)
		var invalid := Formats.decode(bytes,sample.name)
		check("exceptional axis still requires known target %d" % kind,true,not invalid.ok and invalid.reason == "Action target absent from block scope.")
	archive.close()
	var passed := checks.size() == 808
	var ids := {}
	for item: Dictionary in checks:
		passed = passed and not ids.has(item.scenario) and item.expected == item.actual
		ids[item.scenario] = true
	var report := {"schema":"classic-action-axes-audit-v1","ok":passed,"checks":checks,"count":checks.size(),"engine":Engine.get_version_info().string,"gameplay_ready":false,"observation_sha256":FileAccess.get_sha256("res://tests/classic_action_axes_observation.json")}
	var output := FileAccess.open(args[1],FileAccess.WRITE)
	output.store_string(JSON.stringify(report,"\t"))
	output.close()
	print("Action axis corpus: ",checks.size()," checks, passed=",passed)
	quit(0 if passed else 1)
