extends RefCounted
## MOD discovery. No extraction, ResourceLoader, script loading or activation.
const MANIFEST_LIMIT = 1048576
var adapter: StartupStorageAdapter
var candidates: Array[Dictionary] = []
var diagnostics: Array[Dictionary] = []

func _init(storage: StartupStorageAdapter) -> void:
	adapter = storage

func issue(path: String, reason: String) -> void:
	diagnostics.append({"path": path, "reason": reason})

func scan(root: String) -> Dictionary:
	candidates.clear()
	diagnostics.clear()
	var state := adapter.platform("inspect", root)
	if not state.ok:
		return root_failure(root, state.detail)
	if state.detail == "missing":
		return projection(root)
	if state.detail != "directory":
		return root_failure(root, "Mods root must be a readable ordinary directory (links are excluded).")
	var opened := DirAccess.open(root)
	if opened == null or opened.list_dir_begin() != OK:
		return root_failure(root, "Mods root cannot be read.")
	opened.list_dir_end()
	walk(root)
	return projection(root)

func root_failure(root: String, reason: String) -> Dictionary:
	return {"ok": false, "kind": "root_unreadable", "path": root, "reason": reason,
		"candidates": [], "diagnostics": [], "choices": ["Retry", "Continue without mods for this run", "Quit"]}

func projection(root: String) -> Dictionary:
	return {"ok": true, "path": root, "candidates": candidates.duplicate(true), "diagnostics": diagnostics.duplicate(true)}

func entries(path: String) -> Array[String]:
	var result: Array[String] = []
	var directory := DirAccess.open(path)
	if directory == null or directory.list_dir_begin() != OK:
		issue(path, "Directory cannot be enumerated; its descendants were not inspected.")
		return result
	var name := directory.get_next()
	while not name.is_empty():
		result.append(name)
		name = directory.get_next()
	directory.list_dir_end()
	result.sort()
	return result

func walk(path: String) -> void:
	var names := entries(path)
	# Windows case aliases still establish a boundary, but require canonical spelling.
	for name in names:
		if name.to_lower() == "mod.json":
			folder(path, names, name)
			return
	for name in names:
		var child := path.path_join(name)
		var state := adapter.platform("inspect", child)
		if not state.ok:
			issue(child, state.detail)
		elif state.detail == "link":
			issue(child, "Filesystem link skipped; installed packages cannot traverse links.")
		elif state.detail == "directory":
			walk(child)
		elif name.get_extension().to_lower() == "zip":
			archive(child)
		else:
			issue(child, "Unsupported package format; install a ZIP or a folder with root mod.json.")

func folder(path: String, _names: Array[String], manifest_name: String) -> void:
	if manifest_name != "mod.json":
		issue(path, "Manifest must be named mod.json at the package root.")
		return
	if not check_tree(path):
		return
	var file := FileAccess.open(path.path_join("mod.json"), FileAccess.READ)
	if file == null:
		issue(path, "Root mod.json cannot be read.")
		return
	if file.get_length() > MANIFEST_LIMIT:
		issue(path, "Manifest exceeds 1 MiB.")
		return
	var bytes := file.get_buffer(file.get_length())
	file.close()
	accept(path, "folder", bytes)

func check_tree(path: String) -> bool:
	var count := diagnostics.size()
	var names := entries(path)
	if diagnostics.size() != count:
		return false
	for name in names:
		var child := path.path_join(name)
		var state := adapter.platform("inspect", child)
		if not state.ok or state.detail in ["link", "missing"]:
			issue(child, "Installed package contains a link or inaccessible entry.")
			return false
		if not relative_path(name).ok:
			issue(child, "Unsupported Windows package path.")
			return false
		if state.detail == "directory" and not check_tree(child):
			return false
	return true

static func relative_path(path: String) -> Dictionary:
	var normalized := path.replace("\\", "/").trim_suffix("/")
	if normalized.is_empty() or normalized.begins_with("/"):
		return {"ok": false}
	for part in normalized.split("/"):
		if part in ["", ".", ".."] or part.ends_with(".") or part.ends_with(" "):
			return {"ok": false}
		for character in part:
			if character.unicode_at(0) < 32 or character in [":", "*", "?", "\"", "<", ">", "|"]:
				return {"ok": false}
		var stem := part.get_slice(".", 0).to_upper()
		if stem in ["CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"]:
			return {"ok": false}
	return {"ok": true, "path": normalized.to_lower()}

func archive(path: String) -> void:
	# Inspect central-directory attributes as ZIPReader does not expose link modes.
	var structure := zip_structure(path)
	if not structure.ok:
		issue(path, structure.reason)
		return
	var zip := ZIPReader.new()
	if zip.open(path) != OK:
		issue(path, "ZIP cannot be opened or uses an unsupported format.")
		return
	var files := zip.get_files()
	if not files.has("mod.json"):
		issue(path, "Required mod.json belongs at the ZIP root; wrapper folders are not packages.")
		zip.close()
		return
	var bytes := zip.read_file("mod.json", true)
	zip.close()
	if not valid_payload(bytes, structure.entries["mod.json"]):
		issue(path, "Root mod.json ZIP payload is incomplete or has an invalid CRC.")
		return
	accept(path, "zip", bytes)

func zip_structure(path: String) -> Dictionary:
	var bad := {"ok": false, "reason": "Malformed or unsupported ZIP central directory (ZIP64/multidisk/encryption unsupported)."}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "reason": "ZIP cannot be read."}
	var length := file.get_length()
	if length < 22:
		return bad
	file.seek(maxi(0, length - 65557))
	var tail := file.get_buffer(length - file.get_position())
	var end := tail.size() - 22
	while end >= 0:
		if tail.decode_u32(end) == 0x06054b50 and end + 22 + tail.decode_u16(end + 20) == tail.size():
			break
		end -= 1
	if end < 0 or tail.decode_u32(end + 4) != 0:
		return bad
	var count := tail.decode_u16(end + 10)
	var offset := tail.decode_u32(end + 16)
	var size := tail.decode_u32(end + 12)
	if count == 65535 or count != tail.decode_u16(end + 8) or offset + size != length - tail.size() + end:
		return bad
	file.seek(offset)
	var seen := {}
	for index in count:
		var header := file.get_buffer(46)
		if header.size() != 46 or header.decode_u32(0) != 0x02014b50:
			return bad
		var name_bytes := file.get_buffer(header.decode_u16(28))
		var name := name_bytes.get_string_from_utf8()
		var normalized := relative_path(name)
		if name.to_utf8_buffer() != name_bytes or not normalized.ok:
			return {"ok": false, "reason": "Escaping or unsupported ZIP path: " + name}
		if seen.has(normalized.path):
			return {"ok": false, "reason": "Ambiguous normalized ZIP path: " + name}
		seen[normalized.path] = {"length": header.decode_u32(24), "crc": header.decode_u32(16)}
		var mode := header.decode_u32(38) >> 16
		if mode & 0xf000 == 0xa000:
			return {"ok": false, "reason": "ZIP link rejected: " + name}
		if header.decode_u16(8) & 1 or header.decode_u16(34) != 0 or header.decode_u32(24) == 0xffffffff:
			return bad
		if normalized.path == "mod.json" and header.decode_u32(24) > MANIFEST_LIMIT:
			return {"ok": false, "reason": "Manifest exceeds 1 MiB."}
		var next := file.get_position() + header.decode_u16(30) + header.decode_u16(32)
		var local_offset := header.decode_u32(42)
		if local_offset + 30 > offset or header.decode_u16(10) not in [0, 8]:
			return bad
		file.seek(local_offset)
		var local := file.get_buffer(30)
		if local.size() != 30 or local.decode_u32(0) != 0x04034b50 or local.decode_u16(6) != header.decode_u16(8) or local.decode_u16(8) != header.decode_u16(10):
			return bad
		if file.get_buffer(local.decode_u16(26)) != name_bytes or file.get_position() + local.decode_u16(28) + header.decode_u32(20) > offset:
			return bad
		file.seek(next)
	if file.get_position() != offset + size:
		return bad
	return {"ok": true, "entries": seen}

static func valid_payload(bytes: PackedByteArray, entry: Dictionary) -> bool:
	if bytes.size() != entry.length:
		return false
	var table: Array[int] = []
	for value in 256:
		var remainder := value
		for bit in 8:
			remainder = (remainder >> 1) ^ (0xedb88320 if remainder & 1 else 0)
		table.append(remainder)
	var crc := 0xffffffff
	for byte in bytes:
		crc = table[(crc ^ byte) & 255] ^ (crc >> 8)
	return (crc ^ 0xffffffff) == entry.crc

func read_bytes(candidate: Dictionary, relative: String) -> Dictionary:
	var normalized := relative_path(relative)
	if not normalized.ok:
		return {"ok": false, "reason": "Package-relative path escapes or uses unsupported components."}
	var path: String = candidate.path
	var state := adapter.platform("inspect", path)
	if not state.ok or state.detail != ("file" if candidate.format == "zip" else "directory"):
		return {"ok": false, "path": path, "reason": "Installed package disappeared or became a link."}
	if candidate.format == "zip":
		var checked := zip_structure(path)
		if not checked.ok:
			return checked
		var zip := ZIPReader.new()
		if zip.open(path) != OK:
			return {"ok": false, "reason": "Package cannot be read.", "path": path}
		for name in zip.get_files():
			if relative_path(name).path == normalized.path and not name.ends_with("/"):
				var bytes := zip.read_file(name, true)
				zip.close()
				if not valid_payload(bytes, checked.entries[normalized.path]):
					return {"ok": false, "path": path, "reason": "ZIP payload is incomplete or has an invalid CRC."}
				return {"ok": true, "bytes": bytes, "source": candidate.source.duplicate(true), "relative_path": normalized.path}
		zip.close()
	else:
		# Resolve each component case-insensitively, never traverse a filesystem link.
		for component in str(normalized.path).split("/"):
			var matches: Array[String] = []
			for name in entries(path):
				if name.to_lower() == component:
					matches.append(name)
			if matches.size() != 1:
				return {"ok": false, "path": path, "reason": "Package path is missing or ambiguous."}
			path = path.path_join(matches[0])
			state = adapter.platform("inspect", path)
			if not state.ok or state.detail in ["link", "missing"]:
				return {"ok": false, "path": path, "reason": "Package path became inaccessible or a link."}
		var file := FileAccess.open(path, FileAccess.READ)
		if file != null:
			var bytes := file.get_buffer(file.get_length())
			var error := file.get_error()
			file.close()
			if error == OK:
				return {"ok": true, "bytes": bytes, "source": candidate.source.duplicate(true), "relative_path": normalized.path}
	return {"ok": false, "path": path, "reason": "Package file is missing or unreadable."}

static func valid_id(value: Variant) -> bool:
	if not value is String or value.is_empty() or value.length() > 128:
		return false
	var regex := RegEx.new()
	regex.compile("^[a-z0-9][a-z0-9._-]*$")
	return regex.search(value) != null

static func valid_version(value: Variant) -> bool:
	if not value is String or value.length() > 128:
		return false
	var regex := RegEx.new()
	regex.compile("^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$")
	return regex.search(value) != null

func accept(path: String, format: String, bytes: PackedByteArray) -> void:
	var text := bytes.get_string_from_utf8()
	if text.to_utf8_buffer() != bytes or (not text.is_empty() and text.unicode_at(0) == 0xfeff):
		issue(path, "mod.json must be UTF-8 without BOM.")
		return
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		issue(path, "mod.json must be a JSON object: " + parser.get_error_message())
		return
	var manifest: Dictionary = parser.data
	var reason := validate_manifest(manifest)
	if not reason.is_empty():
		issue(path, reason)
		return
	candidates.append({"id": manifest.id, "name": manifest.name, "version": manifest.version, "format": format,
		"path": path.replace("\\", "/"), "source": {"owner": "MOD", "path": path.replace("\\", "/"), "format": format},
		"dependencies": manifest.get("dependencies", []).duplicate(true), "capabilities": manifest.get("capabilities", []).duplicate(),
		"manifest": manifest.duplicate(true)})

static func validate_manifest(manifest: Dictionary) -> String:
	if typeof(manifest.get("manifest_version")) not in [TYPE_INT, TYPE_FLOAT] or manifest.manifest_version != 1:
		return "manifest_version must be the supported integer 1."
	if not valid_id(manifest.get("id")):
		return "id must be 1–128 lowercase ASCII letters/digits/dot/underscore/hyphen, starting with a letter or digit."
	if not manifest.get("name") is String or manifest.name.strip_edges().is_empty() or manifest.name.length() > 200:
		return "name must be nonblank text of at most 200 characters."
	for character in manifest.name:
		if character.unicode_at(0) < 32:
			return "name must not contain control characters."
	if not valid_version(manifest.get("version")):
		return "version must be a three-component semantic release version."
	if not manifest.get("capabilities", []) is Array or not manifest.get("dependencies", []) is Array:
		return "capabilities and dependencies must be arrays."
	for capability in manifest.get("capabilities", []):
		if not valid_id(capability):
			return "Each capability must be a stable identifier. Discovery does not activate capabilities."
	for dependency in manifest.get("dependencies", []):
		if not dependency is Dictionary or not valid_id(dependency.get("id")):
			return "Each dependency requires a valid provider id."
		if not dependency.get("optional", false) is bool or dependency.get("order", "provider_first") not in ["provider_first", "presence_only"]:
			return "Dependency optional must be boolean and order provider_first or presence_only."
		for bound in ["min", "max"]:
			if dependency.has(bound) and not valid_version(dependency[bound]):
				return "Dependency " + bound + " must be a semantic version."
	return ""
