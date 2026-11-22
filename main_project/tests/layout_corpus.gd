extends SceneTree
const Formats = preload("res://scripts/data/layout_formats.gd")
const Bsa = preload("res://scripts/data/bsa_reader.gd")
const Placements = preload("res://scripts/data/layout_placements.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		push_error("Explicit classic folder and output required.")
		quit(2)
		return
	var bsa := Bsa.new()
	var opened := bsa.initialize(args[0].path_join("BLOCKS.BSA"))
	if not opened.ok:
		print(opened)
		quit(2)
		return
	var inventory: Array = []
	var totals := {}
	var classifications := {}
	for i in bsa.inventory().count:
		var raw := bsa.read_record({"ordinal":i})
		if not raw.ok:
			print(raw)
			quit(2)
			return
		var result := Formats.decode(raw.bytes,raw.identity)
		var status: String = "decoded" if result.ok else result.kind
		var entry := {"ordinal":i,"name":raw.identity,"offset":raw.offset,"size":raw.bytes.size(),"sha256":preload("res://scripts/data/actor_input_formats.gd").sha256(raw.bytes),"status":status}
		if result.ok:
			entry.records = result.records.size()
		else:
			entry.diagnostic = result
		inventory.append(entry)
		classifications[raw.identity] = status
		totals[status] = totals.get(status,0)+1
	var maps := Bsa.new()
	var map_open := maps.initialize(args[0].path_join("MAPS.BSA"))
	if not map_open.ok:
		print(map_open)
		quit(2)
		return
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/layouts/profile.json"))
	var mapped := 0
	var required_unsupported := 0
	var absent := 0
	var issues: Array = []
	var pitem := PackedByteArray()
	var ditem := PackedByteArray()
	var region := -1
	for m: Dictionary in profile.locations:
		if region != int(m.region):
			region = int(m.region)
			pitem = maps.read_record({"ordinal":region*4}).bytes
			ditem = maps.read_record({"ordinal":region*4+1}).bytes
		var exterior := Placements.exterior(pitem,int(m.pitem_offset),"MAPS.BSA region %d" % region)
		if not exterior.ok:
			issues.append(exterior)
			continue
		var dungeon := Placements.dungeon(ditem,int(m.location_id),"MAPS.BSA region %d" % region)
		if not dungeon.ok:
			issues.append(dungeon)
			continue
		mapped += 1
		var unsupported := false
		for p: Dictionary in exterior.placements+dungeon.placements:
			if not classifications.has(p.block_name):
				absent += 1
				issues.append({"source":m.id,"target":p.block_name,"kind":"missing"})
			elif classifications[p.block_name] != "decoded": unsupported = true
		if unsupported: required_unsupported += 1
	var file := FileAccess.open(args[1],FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema":"layout-corpus-v1","inventory":inventory,"totals":totals,"maps":{"decoded":mapped,"layouts_with_required_unsupported_blocks":required_unsupported,"missing_block_references":absent,"issues":issues},"resources_qualified":false,"location_ready":false},"\t"))
	file.close()
	print(totals)
	quit()
