class_name StartupLaunchLogger
extends Logger
const CAP_BYTES := 209715200
const LIMIT_NOTICE := "[WARNING] File log limit reached; logging stopped for this launch.\n"
const TRUNCATION := " [message truncated]\n"
var adapter: StartupStorageAdapter
var file: FileAccess
var warning := ""
var bytes_written := 0
var cap_bytes := CAP_BYTES
var initialized := false
var user_home := ""
var mutex := Mutex.new()

# Godot may invoke these on worker threads. Never log recursively through the
# engine sink and never capture variables/save payloads in exception traces.
func _log_message(text: String, error: bool) -> void:
	message("ERROR" if error else "INFO", text)

func _log_error(function: String, source: String, line: int, code: String,
		rationale: String, _editor_notify: bool, error_type: int,
		backtraces: Array[ScriptBacktrace]) -> void:
	var trace := "%s:%s in %s" % [source, line, function]
	for backtrace in backtraces:
		trace += "\n" + backtrace.format()
	var description := code + (": " + rationale if not rationale.is_empty() else "")
	if source.ends_with("config_file.cpp"):
		description = "Settings INI read/parse failure; input contents omitted."
	message("WARNING" if error_type == Logger.ERROR_TYPE_WARNING else "EXCEPTION", description, trace)

func start(storage: StartupStorageAdapter, context: Dictionary) -> void:
	if initialized:
		return # Launch scope: session/scene changes cannot rotate.
	initialized = true
	adapter = storage
	user_home = OS.get_environment("USERPROFILE").replace("\\", "/")
	var current := str(context.logs).path_join("Player.log")
	var previous := str(context.logs).path_join("Player-prev.log")
	if FileAccess.file_exists(current):
		var rotated := adapter.replace(current, previous, "log_rotate")
		if not rotated.ok:
			stop("File logging unavailable: previous launch could not be preserved.")
			return
	if adapter.faults.has("log_open"):
		stop("File logging unavailable: controlled open failure.")
		return
	file = FileAccess.open(current, FileAccess.WRITE)
	if file == null:
		stop("File logging unavailable: current log could not be opened.")
		return
	message("INFO", "Build IMP-001; Godot %s; OS %s; storage %s; enabled mods not yet established" % [Engine.get_version_info().string, OS.get_name(), context.mode])

func stop(reason: String) -> void:
	mutex.lock()
	_stop(reason)
	mutex.unlock()

func _stop(reason: String) -> void:
	if warning.is_empty():
		warning = reason
	if file != null:
		file.close()
		file = null

func filtered(text: String) -> String:
	var result := text.replace("\\", "/")
	if not user_home.is_empty():
		# Windows home path matching is case-insensitive. Do not collect usernames.
		var at := result.to_lower().find(user_home.to_lower())
		while at >= 0:
			result = result.substr(0, at) + "<user-home>" + result.substr(at + user_home.length())
			at = result.to_lower().find(user_home.to_lower())
	return result

func write(bytes: PackedByteArray) -> bool:
	if adapter.faults.has("log_write"):
		_stop("File logging stopped: write or flush failed.")
		return false
	file.store_buffer(bytes)
	file.flush()
	if file.get_error() != OK:
		_stop("File logging stopped: write or flush failed.")
		return false
	bytes_written += bytes.size()
	return true

func message(severity: String, text: String, trace := "") -> void:
	mutex.lock()
	_message(severity, text, trace)
	mutex.unlock()

func _message(severity: String, text: String, trace: String) -> void:
	if file == null or severity not in ["INFO", "WARNING", "ERROR", "EXCEPTION"]:
		return
	var line := "%s [%s] %s%s\n" % [Time.get_datetime_string_from_system(true), severity, filtered(text), "\n" + filtered(trace) if not trace.is_empty() else ""]
	var bytes := line.to_utf8_buffer()
	var limit := (Time.get_datetime_string_from_system(true) + " " + LIMIT_NOTICE).to_utf8_buffer()
	var available := cap_bytes - bytes_written - limit.size()
	if bytes.size() <= available:
		write(bytes)
		return
	var budget := available - TRUNCATION.to_utf8_buffer().size()
	if budget >= 0:
		# Cut on a UTF-8 boundary; never leave half of a multibyte character.
		var end := mini(budget, bytes.size())
		while end > 0 and end < bytes.size() and (bytes[end] & 0xC0) == 0x80:
			end -= 1
		if not write(bytes.slice(0, end) + TRUNCATION.to_utf8_buffer()):
			return
	if file != null and write(limit):
		_stop("File log limit reached. Later diagnostics will not be recorded this launch.")

func mods_established(mods: Array) -> void:
	# Callers provide only public IDs and versions, never credentials/save payloads.
	var identifiers: Array = []
	for mod: Dictionary in mods:
		identifiers.append({"id": mod.get("id", ""), "version": mod.get("version", "")})
	message("INFO", "Enabled mod IDs/versions: %s" % JSON.stringify(identifiers))
