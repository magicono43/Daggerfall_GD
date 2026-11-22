extends SceneTree
## One-time explicit edition mapping authoring. Never replace an existing profile.
const Bsa = preload("res://scripts/data/bsa_reader.gd")
const F = preload("res://scripts/data/layout_formats.gd")
const P = preload("res://scripts/data/layout_placements.gd")
const Common = preload("res://scripts/data/actor_input_formats.gd")
const Inputs = preload("res://scripts/data/layout_inputs.gd")
const INITIAL_EDITION = {"BLOCKS.BSA":"6f5a4c8d9401c1b00ef83eaac9b0c6c32f53cef6eaa4c7d7027deb739bde4795","MAPS.BSA":"8b5550bfcac03b6f605842568fdbfb7cc6bbed7ace5999c33c900ad286fc24be"}

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or FileAccess.file_exists(args[1]):
		push_error("Explicit classic source and NEW output profile required.")
		quit(2)
		return
	for name: String in INITIAL_EDITION:
		if FileAccess.get_sha256(args[0].path_join(name)) != INITIAL_EDITION[name]:
			push_error("Initial identity allocation is limited to the observed edition; unknown editions need curated mappings preserving existing keys.")
			quit(2)
			return
	var blocks := Bsa.new()
	var maps := Bsa.new()
	for pair in [[blocks,"BLOCKS.BSA"],[maps,"MAPS.BSA"]]:
		var checked: Dictionary = pair[0].initialize(args[0].path_join(pair[1]))
		if not checked.ok:
			print(checked)
			quit(2)
			return
	var profile := {"schema":"classic-layout-profile-v1","files":{},"blocks":[],"locations":[],"rmb_door_models":{"0":9000,"1":9001,"2":9002,"3":9003,"4":9004}}
	var ledger := {}
	if FileAccess.file_exists(Inputs.ROOT+"profile.json"):
		if FileAccess.get_sha256(Inputs.ROOT+"profile.json") != Inputs.PROFILE_HASH:
			push_error("Existing identity ledger differs from the pinned edition profile.")
			quit(2)
			return
		ledger = JSON.parse_string(FileAccess.get_file_as_string(Inputs.ROOT+"profile.json"))
	for name in ["BLOCKS.BSA","MAPS.BSA"]: profile.files[name] = FileAccess.get_sha256(args[0].path_join(name))
	for i in blocks.inventory().count:
		var raw: Dictionary = blocks.read_record({"ordinal":i})
		var decoded := F.decode(raw.bytes,raw.identity)
		var entry := {"id":"block-%04d" % i,"name":raw.identity,"ordinal":i,"offset":raw.offset,"size":raw.bytes.size(),"sha256":Common.sha256(raw.bytes),"format":str(raw.identity).get_extension().to_upper(),"records":{}}
		var prior: Dictionary = ledger.get("blocks",[])[i] if ledger.has("blocks") else {}
		if not prior.is_empty():
			if prior.ordinal != i or prior.name != raw.identity or prior.sha256 != entry.sha256:
				push_error("Edition ledger source address changed; curated mapping required.")
				quit(2)
				return
			entry.id = prior.id
			# A stricter decoder must not retire or reallocate reserved identities.
			entry.records = prior.records.duplicate(true)
		if decoded.ok:
			for j in decoded.records.size():
				var address := str(decoded.records[j].address)
				if not prior.is_empty() and not prior.records.has(address):
					push_error("Record address lacks an explicit existing identity.")
					quit(2)
					return
				entry.records[address] = prior.records[address] if not prior.is_empty() else "record-%05d" % j
			if decoded.format == "RMB":
				entry.buildings = {}
				for j in decoded.subrecords.size(): entry.buildings[str(j)] = prior.get("buildings",{}).get(str(j),"building-%04d" % j)
			entry.qualification = "decoded"
		else:
			entry.qualification = decoded.kind
			entry.diagnostic = decoded
		profile.blocks.append(entry)
	var geography: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/geography/profile.json"))
	var regions := {}
	for region: Dictionary in geography.regions: regions[region.id] = region
	var current_region := -1
	var pitem := PackedByteArray()
	var ditem := PackedByteArray()
	for location: Dictionary in geography.locations:
		var region: Dictionary = regions[location.region]
		if current_region != int(region.ordinal):
			current_region = int(region.ordinal)
			pitem = maps.read_record({"ordinal":current_region*4}).bytes
			ditem = maps.read_record({"ordinal":current_region*4+1}).bytes
		var offset: int = int(region.count)*4+pitem.decode_u32(int(location.ordinal)*4)
		var exterior := P.exterior(pitem,offset,"MAPS.BSA region %d" % current_region)
		if not exterior.ok:
			print(location.id,exterior)
			quit(2)
			return
		var dungeon := P.dungeon(ditem,exterior.header.location_id,"MAPS.BSA region %d" % current_region)
		if not dungeon.ok:
			print(location.id,dungeon)
			quit(2)
			return
		var placements := {}
		for context in ["exterior","dungeon"]:
			var decoded: Dictionary = exterior if context == "exterior" else dungeon
			for i in decoded.placements.size(): placements["%s/%d" % [context,i]] = "placement-%05d" % placements.size()
		profile.locations.append({"id":location.id,"region":current_region,"ordinal":int(location.ordinal),"count":int(region.count),"pitem_offset":offset,"location_id":exterior.header.location_id,"placements":placements})
	for name: String in profile.files:
		if FileAccess.get_sha256(args[0].path_join(name)) != profile.files[name]:
			push_error("Required source changed during profile authoring.")
			quit(2)
			return
	var file := FileAccess.open(args[1],FileAccess.WRITE)
	file.store_string(JSON.stringify(profile))
	file.close()
	print("Profile: ",profile.blocks.size()," blocks, ",profile.locations.size()," locations; sha256 ",FileAccess.get_sha256(args[1]))
	quit()
