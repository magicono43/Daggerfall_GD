extends Logger
## Scoped synchronous invocation observer; does not suppress the engine diagnostic.
var errors: Array[Dictionary] = []
var _mutex := Mutex.new()

func _log_error(function: String, source: String, line: int, code: String, rationale: String,
		_notify: bool, kind: int, _backtraces: Array[ScriptBacktrace]) -> void:
	if kind == Logger.ERROR_TYPE_WARNING:
		return
	_mutex.lock()
	errors.append({"function":function,"source":source,"line":line,"code":code,"rationale":rationale,"kind":kind})
	_mutex.unlock()
