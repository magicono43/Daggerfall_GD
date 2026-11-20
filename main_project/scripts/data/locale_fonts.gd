extends RefCounted
## DATA font definitions. Inline SFNT bytes keep package/ZIP transport inside DATA;
## bundled references are a closed application inventory, never filesystem paths.
const VERSION := "locale-fonts-v1"
const DOMAIN := "text.fonts"
const ROLES := ["body", "title", "small-ui"]
const ASSETS := {"recovery-sans":"res://content/fonts/DejaVuSans.ttf", "sample-mono":"res://content/fonts/Inconsolata-Regular.ttf"}
const HASHES := {"recovery-sans":"7da195a74c55bef988d0d48f9508bd5d849425c1770dba5d7bfc6ce9ed848954", "sample-mono":"127875d255d4c5973ca57267a43bb9d1c04397e6c7d236984a595b6cdcb12b7c"}

func declaration() -> Dictionary:
	return {"id":"text.fonts.v1", "domain":DOMAIN, "operations":["add","replace","patch"], "required_resources":["installed"], "capabilities":[VERSION]}

func validate_resource_path(path: String) -> String:
	return "" if path == "installed" else "Font definitions require the installed logical resource."

func bundled_contributions() -> Array:
	return [{"file":"fonts.json", "root":"res://content/fonts", "version":VERSION, "bytes":JSON.stringify({"domain":DOMAIN,"path":"installed","operation":"add","entries":[
		{"id":"recovery-sans","value":{"schema":VERSION,"kind":"font","bundled":"recovery-sans","sha256":HASHES["recovery-sans"],"license":"Bitstream Vera / Arev; DejaVu public domain changes","version":"2.37","fallbacks":[]}},
		{"id":"english","value":{"schema":VERSION,"kind":"locale","locale":"en","roles":{"body":"recovery-sans","title":"recovery-sans","small-ui":"recovery-sans"},"coverage":"English Latin; sample capability is not a language roster","offer":true}}
	]}).to_utf8_buffer()}]

static func bytes(value: Dictionary) -> PackedByteArray:
	if ASSETS.has(value.get("bundled", "")):
		# Godot exports imported fonts as .fontdata with a resource remap. Read the
		# original SFNT data from that real resource, not a nonexistent raw PCK file.
		if not ResourceLoader.exists(ASSETS[value.bundled],"FontFile"):
			return PackedByteArray()
		var resource: FontFile = load(ASSETS[value.bundled])
		return resource.data if resource != null else PackedByteArray()
	var encoded: Variant = value.get("sfnt", "")
	if not encoded is String or encoded.length() > 11184812 or encoded.length() % 4 != 0:
		return PackedByteArray()
	var padding := 2 if encoded.ends_with("==") else 1 if encoded.ends_with("=") else 0
	if encoded.length() < 4:
		return PackedByteArray()
	for index in encoded.length() - padding:
		if not encoded[index] in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/":
			return PackedByteArray()
	var decoded := Marshalls.base64_to_raw(encoded)
	return decoded if Marshalls.raw_to_base64(decoded) == encoded else PackedByteArray()

static func load_font(value: Dictionary) -> FontFile:
	var data := bytes(value)
	if data.size() < 12 or data.size() > 8388608:
		return null
	# Bounded single-face TrueType/OpenType SFNT only, before entering FreeType.
	if data.slice(0,4) != PackedByteArray([0,1,0,0]) and data.slice(0,4).get_string_from_ascii() != "OTTO":
		return null
	var tables := (int(data[4]) << 8) | int(data[5])
	if tables == 0 or tables > 128 or 12 + tables * 16 > data.size():
		return null
	for index in tables:
		var offset := 0
		var length := 0
		for byte in range(4):
			offset = (offset << 8) | int(data[20 + index * 16 + byte])
			length = (length << 8) | int(data[24 + index * 16 + byte])
		if offset + length > data.size():
			return null
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(data)
	if hash.finish().hex_encode() != value.get("sha256", ""):
		return null
	# Never allow OS fallback to make a deterministic resource claim pass.
	var font := FontFile.new()
	font.allow_system_fallback = false
	font.data = data
	if font.get_rids().is_empty() or not font.has_char(63) or font.get_height(18) <= 0:
		return null
	return font

func validate_record(_id: String, value: Dictionary) -> String:
	if value.get("schema") != VERSION:
		return "Expected " + VERSION
	if value.get("kind") == "font":
		for key: String in value:
			if key not in ["schema","kind","bundled","sfnt","sha256","license","version","fallbacks"]:
				return "Unknown font field: " + key
		if value.has("bundled") == value.has("sfnt") or not value.get("sha256") is String or not value.get("license") is String or value.license.is_empty() or not value.get("version") is String or not value.get("fallbacks") is Array:
			return "Font needs exactly one bundled/inline asset, digest, license, version and ordered fallback IDs."
		if value.has("bundled") and not ASSETS.has(value.bundled):
			return "Unresolved bundled font asset."
		for id in value.fallbacks:
			if not id is String or not preload("res://scripts/mod/package_library.gd").valid_id(id):
				return "Invalid fallback resource identity."
		if load_font(value) == null:
			return "Missing, damaged or unusable font asset/digest."
		return ""
	if value.get("kind") == "locale":
		for key: String in value:
			if key not in ["schema","kind","locale","roles","coverage","offer"]:
				return "Unknown locale font field: " + key
		if not value.get("locale") is String or not preload("res://scripts/data/text_catalog.gd").locale_id(value.locale) or not value.get("roles") is Dictionary or not value.get("coverage") is String or value.coverage.is_empty() or not value.get("offer") is bool:
			return "Locale needs exact identity, role map, coverage contract and offer flag."
		if value.roles.size() != ROLES.size():
			return "All body/title/small-ui roles are required."
		for role: String in ROLES:
			if not value.roles.get(role) is String:
				return "Unresolved role: " + role
		# No unverified real-language advertising or synthetic language promise.
		if value.offer and value.locale != "en":
			return "This build has accepted offered-language coverage for English only."
		return ""
	return "Unknown font definition kind."

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	value.merge(fields, true)
	return {"ok":true,"value":value}

static func walk(id: String, records: Dictionary, visiting: Array, complete: Array) -> String:
	if visiting.size() >= 64:
		return "Font fallback chain exceeds 64 resources."
	if visiting.has(id):
		return "Cyclic font fallback: " + str(visiting + [id])
	if complete.has(id):
		return ""
	if not records.has(id) or records[id].value.kind != "font":
		return "Unresolved required font: " + id
	for fallback: String in records[id].value.fallbacks:
		var reason := walk(fallback,records,visiting + [id],complete)
		if not reason.is_empty():
			return reason
	complete.append(id)
	return ""

func validate_references(resources: Dictionary) -> Array:
	var records: Dictionary = resources.get(DOMAIN + ":installed",{}).get("records",{})
	var issues: Array = []
	var locales: Array = []
	for id: String in records:
		var record: Dictionary = records[id]
		var value: Dictionary = record.value
		var reason := ""
		if value.kind == "font":
			reason = walk(id,records,[],[])
		else:
			if locales.has(value.locale):
				reason = "Duplicate exact locale mapping."
			locales.append(value.locale)
			for role: String in ROLES:
				var failure := walk(value.roles[role],records,[],[])
				if not failure.is_empty():
					reason = failure
		if not reason.is_empty():
			var source: Dictionary = record.winner
			issues.append({"source":DOMAIN + "/" + id,"reason":reason,"token":source.get("token",""),"omittable":not str(source.get("provider", "@shipped/")).begins_with("@shipped/")})
	if not locales.has("en"):
		issues.append({"source":DOMAIN,"reason":"Required English mapping unavailable."})
	return issues
