extends RefCounted
# Trusted in-process numeric interface; consumers must pass an explicit source.
var raw_count := 0
var logical_count := 0
func raw() -> Dictionary:
	return {"ok": false, "error": "source_unavailable"}
func bounded(bound: Variant) -> Dictionary:
	return {"ok": false, "error": "source_unavailable", "bound": bound}


