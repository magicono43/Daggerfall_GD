extends SceneTree
## Source dependency audit only. Does not qualify LOC markers or entry.
const Formats = preload("res://scripts/data/layout_formats.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or not args[0].is_absolute_path() or not args[1].is_absolute_path() or FileAccess.file_exists(args[1]):
		push_error("Explicit classic source and NEW absolute report path required.")
		quit(2)
		return
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/profile.json"))
	var observation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/dungeon_marker_resolved_observation.json"))
	var checks: Array = []
	for name: String in observation.sources:
		checks.append({"id":"source "+name,"expected":observation.sources[name],"actual":FileAccess.get_sha256(args[0].path_join(name))})
	for location: String in observation.locations:
		var value: Dictionary = observation.locations[location]
		var ids := {}
		for placement: Dictionary in value.placements:
			for marker: Dictionary in placement.markers:
				var key := str([placement.id,marker.address])
				assert(not ids.has(key))
				ids[key] = true
		checks.append({"id":"unique source marker inventory "+location,"expected":value.unique_editor_markers,"actual":ids.size()})
	var block: Dictionary = profile.blocks.filter(func(b: Dictionary): return b.name == "S0000999.RDB")[0]
	var source := FileAccess.open(args[0].path_join("BLOCKS.BSA"),FileAccess.READ)
	if source == null:
		quit(2)
		return
	source.seek(int(block.offset))
	var bytes := source.get_buffer(int(block.size))
	source.close()
	var digest := HashingContext.new()
	digest.start(HashingContext.HASH_SHA256)
	digest.update(bytes)
	checks.append({"id":"central block payload hash","expected":block.sha256,"actual":digest.finish().hex_encode()})
	var decoded := Formats.decode(bytes,block.name)
	checks.append({"id":"actual DATA decoder retains central block","expected":true,"actual":decoded.ok})
	var retained: Array = decoded.get("records",[]).filter(func(r: Dictionary): return r.address == 19568)
	checks.append({"id":"actual DATA retained record","expected":1,"actual":retained.size()})
	checks.append({"id":"actual DATA non-executing action","expected":true,"actual":retained.size() == 1 and not retained[0].has("action") and retained[0].get("unused_action",{}).get("raw",{}).get("kind") == 27})
	var passed := checks.size() == 9
	for check: Dictionary in checks: passed = passed and check.expected == check.actual
	var report := {"schema":"dungeon-marker-source-dependency-audit-v2","ok":passed,"count":checks.size(),"checks":checks,"engine":Engine.get_version_info().string,"observation_sha256":FileAccess.get_sha256("res://tests/dungeon_marker_resolved_observation.json"),"marker_implementation_qualified":false,"opening_ready":false}
	var output := FileAccess.open(args[1],FileAccess.WRITE)
	if output == null:
		quit(2)
		return
	output.store_string(JSON.stringify(report,"\t"))
	output.close()
	print("Marker source dependency audit: ",checks.size()," checks, passed=",passed)
	quit(0 if passed else 1)
