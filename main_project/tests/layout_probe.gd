extends SceneTree
## Exploratory production-reader probe; not the frozen increment acceptance suite.
const Access = preload("res://scripts/data/classic_access.gd")
const Layouts = preload("res://scripts/data/layout_inputs.gd")
const F = preload("res://scripts/data/layout_formats.gd")
const P = preload("res://scripts/data/layout_placements.gd")
var checks: Array = []

func check(name: String, expected: Variant, actual: Variant) -> void:
	checks.append({"name":name,"expected":expected,"actual":actual})
	if expected != actual: print("FAIL ",name,": ",actual)

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		quit(2)
		return
	var access := Access.new()
	var prepared := access.prepare(args[0])
	check("foundation prepares",true,prepared.ok)
	if not prepared.ok:
		print(prepared)
		quit(2)
		return
	check("foundation commits",true,access.activate(prepared).ok)
	var adapter := Layouts.new()
	adapter.classic = access
	var bundle := adapter.bundled_contributions()
	check("profile intake",true,bundle[0].has("bytes"))
	if not bundle[0].has("bytes"):
		print(bundle)
		quit(2)
		return
	var baseline: Dictionary = JSON.parse_string(bundle[0].bytes.get_string_from_utf8())
	check("baseline inventory",16546,baseline.entries.size())
	for e: Dictionary in baseline.entries:
		var reason := adapter.validate_record(e.id,e.value)
		if not reason.is_empty():
			check("baseline schema "+e.id,"",reason)
			break
	check("baseline validation completed",true,true)
	var raw := access.read_record("BLOCKS.BSA",{"ordinal":0})
	var rmb := F.decode(raw.bytes,raw.identity)
	check("actual first RMB",true,rmb.ok)
	check("truncated RMB header",false,F.decode(raw.bytes.slice(0,6775),raw.identity).ok)
	check("trailing RMB",false,F.decode(raw.bytes+PackedByteArray([0]),raw.identity).ok)
	var bad: PackedByteArray = raw.bytes.duplicate()
	bad[0] = 33
	check("RMB fixed slot bound",false,F.decode(bad,raw.identity).ok)
	var actual := access.read_record("BLOCKS.BSA","B0000000.RDB")
	var rdb := F.decode(actual.bytes,actual.identity)
	check("actual RDB",true,rdb.ok)
	check("unsupported required RDI",false,F.decode(PackedByteArray(),"x.RDI").ok)
	var source_map: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/profile.json"))
	var map_count := 0
	for region in 62:
		var bytes: PackedByteArray = access.read_record("MAPS.BSA",{"ordinal":region*4}).bytes
		var dungeon_bytes: PackedByteArray = access.read_record("MAPS.BSA",{"ordinal":region*4+1}).bytes
		for m: Dictionary in source_map.locations:
			if int(m.region) != region: continue
			var ext := P.exterior(bytes,int(m.pitem_offset),"MAPS.BSA")
			if not ext.ok:
				check("actual exterior "+m.id,true,ext)
				continue
			var dungeon := P.dungeon(dungeon_bytes,int(m.location_id),"MAPS.BSA")
			if not dungeon.ok:
				check("actual dungeon "+m.id,true,dungeon)
				continue
			map_count += 1
	check("all actual MAPS layouts decode",15251,map_count)
	access.dispose()
	var ok := checks.all(func(c: Dictionary): return c.expected == c.actual)
	var out := FileAccess.open(args[1],FileAccess.WRITE)
	out.store_string(JSON.stringify({"schema":"layout-exploratory-probe-v1","ok":ok,"checks":checks,"engine":Engine.get_version_info()},"\t"))
	out.close()
	quit(0 if ok else 1)
