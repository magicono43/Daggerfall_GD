class_name StartupStorageAdapter
extends RefCounted
## One instance owns one process lease. Never substitute lock-file presence.
var native: RefCounted
var root := ""
# Controlled fault seams, set by task-local fixtures, never by player settings.
var faults: Dictionary = {}
# Task-local process interruption checkpoint; unset in ordinary launches.
var before_replace := Callable()

func _init() -> void:
	if ClassDB.class_exists("WindowsStorageLease"):
		native = ClassDB.instantiate("WindowsStorageLease")

func failure(operation: String, path: String, detail: String = "") -> Dictionary:
	return {"ok": false, "kind": "io", "operation": operation, "path": path, "detail": detail}

func platform(operation: String, path := "", destination := "") -> Dictionary:
	if native == null:
		return failure(operation, path, "The Windows storage component is unavailable. Repair the installation and restart.")
	var reply: String = native.call("invoke", operation, path, destination)
	var parts := reply.split("|", true, 1)
	return {"ok": parts[0] == "ok", "kind": parts[0], "operation": operation,
		"path": path, "detail": parts[1] if parts.size() > 1 else ""}

func per_user_root(development: bool) -> Dictionary:
	var result := platform("per_user")
	if result.ok:
		result.path = result.detail.path_join("Daggerfall GD Development" if development else "Daggerfall GD")
	return result

func acquire(path: String) -> Dictionary:
	var created := directory(path)
	if not created.ok:
		return created
	var result := platform("acquire", path)
	if result.ok:
		root = result.detail.replace("\\", "/")
	return result

func release() -> void:
	if native != null:
		platform("release")
	root = ""

func directory(path: String) -> Dictionary:
	if faults.has("mkdir") or faults.has(path):
		return failure("mkdir", path, "controlled failure")
	var error := DirAccess.make_dir_recursive_absolute(path)
	return {"ok": true} if error == OK else failure("mkdir", path, error_string(error))

func probe(path: String) -> Dictionary:
	var made := directory(path)
	if not made.ok:
		return made
	var temporary := path.path_join(".probe-%s-%s" % [OS.get_process_id(), Time.get_ticks_usec()])
	var bytes := "startup storage probe".to_utf8_buffer()
	var result := write_bytes(temporary, bytes, "probe_write")
	if not result.ok:
		return result
	if faults.has("probe_read") or FileAccess.get_file_as_bytes(temporary) != bytes:
		return failure("probe_read", temporary)
	if faults.has("probe_remove") or DirAccess.remove_absolute(temporary) != OK:
		return failure("probe_remove", temporary)
	return {"ok": true}

func write_bytes(path: String, bytes: PackedByteArray, operation: String) -> Dictionary:
	if faults.has(operation):
		return failure(operation, path, "controlled failure")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return failure(operation, path, error_string(FileAccess.get_open_error()))
	file.store_buffer(bytes)
	file.flush()
	var error := file.get_error()
	file.close()
	return {"ok": true} if error == OK else failure(operation, path, error_string(error))

func replace(staged: String, destination: String, operation: String) -> Dictionary:
	if faults.has(operation):
		return failure(operation, destination, "controlled failure")
	if before_replace.is_valid():
		before_replace.call(operation)
	var result := platform("replace", staged, destination)
	result.operation = operation
	result.path = destination
	return result

func publish_bytes(path: String, bytes: PackedByteArray, operation: String) -> Dictionary:
	var stage := path + ".staged"
	var result := write_bytes(stage, bytes, operation + "_stage")
	if not result.ok:
		return result
	if FileAccess.get_file_as_bytes(stage) != bytes:
		return failure(operation + "_verify", stage)
	return replace(stage, path, operation)
