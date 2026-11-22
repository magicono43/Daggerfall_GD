extends SceneTree
## Initial-edition metadata augmentation only. Existing keys are never reallocated.
const Bsa = preload("res://scripts/data/bsa_reader.gd")
const Common = preload("res://scripts/data/actor_input_formats.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or FileAccess.file_exists(args[1]):
		push_error("Explicit classic root and NEW output required.")
		quit(2)
		return
	var original := FileAccess.get_file_as_bytes("res://content/layouts/profile.json")
	if Common.sha256(original) != "acc4d9695375c25981a5718030d53ecb2b6364a9600154be00ea462ab2ecf7c9":
		push_error("This one-time augmentation requires the original observed profile.")
		quit(2)
		return
	var profile: Dictionary = JSON.parse_string(original.get_string_from_utf8())
	if FileAccess.get_sha256(args[0].path_join("BLOCKS.BSA")) != profile.files["BLOCKS.BSA"]:
		quit(2)
		return
	var bsa := Bsa.new()
	if not bsa.initialize(args[0].path_join("BLOCKS.BSA")).ok:
		quit(2)
		return
	var total := 0
	for block: Dictionary in profile.blocks:
		if block.format != "RMB": continue
		var raw: Dictionary = bsa.read_record({"ordinal":int(block.ordinal)})
		if not raw.ok or Common.sha256(raw.bytes) != block.sha256:
			quit(2)
			return
		block.buildings = {}
		for i in raw.bytes[0]:
			block.buildings[str(i)] = "building-%04d" % i
			total += 1
	profile.rmb_door_models = {"0":9000,"1":9001,"2":9002,"3":9003,"4":9004}
	var file := FileAccess.open(args[1],FileAccess.WRITE)
	file.store_string(JSON.stringify(profile))
	file.close()
	print("Added ",total," explicit building keys; prior block/record/placement mappings preserved. Profile SHA-256 ",FileAccess.get_sha256(args[1]))
	quit()
