extends RefCounted
## Shared UI text policy used by CHAR acceptance, generated suggestions and fields.
## Segmentation is the active Godot Advanced TextServer's composite boundaries.
const LIMIT = 31

static func forbidden(code: int) -> bool:
	return code < 32 or (code >= 127 and code <= 159) or code in [1564,8206,8207,8232,8233,65279] or (code >= 8234 and code <= 8238) or (code >= 8294 and code <= 8297)

static func whitespace(code: int) -> bool:
	return code in [9,10,11,12,13,32,133,160,5760,8232,8233,8239,8287,12288] or (code >= 8192 and code <= 8202)

static func validate(value: Variant) -> Dictionary:
	if not value is String: return {"ok":false,"reason":"Enter a Unicode name."}
	for index in value.length():
		if forbidden(value.unicode_at(index)): return {"ok":false,"reason":"Names cannot contain control characters, line breaks or bidirectional formatting controls."}
	var first := 0
	var last: int = value.length()
	while first < last and whitespace(value.unicode_at(first)): first += 1
	while last > first and whitespace(value.unicode_at(last-1)): last -= 1
	var text: String = value.substr(first,last-first)
	if text.is_empty(): return {"ok":false,"reason":"Enter a nonblank name."}
	# Preserve ZWJ/ZWNJ and variation selectors for scripts/emoji. Reject controls,
	# bidi formatting and line separators in this single-line display-name field.
	var server := TextServerManager.get_primary_interface()
	if server == null or not server.has_feature(TextServer.FEATURE_BREAK_ITERATORS): return {"ok":false,"reason":"Unicode character segmentation is unavailable; name acceptance is blocked."}
	var count := server.string_get_character_breaks(text,"en").size()
	if count < 1: return {"ok":false,"reason":"Unicode segmentation failed; your text is retained."}
	if count > LIMIT: return {"ok":false,"reason":"Use at most 31 grapheme clusters; your text has been retained for editing.","count":count}
	return {"ok":true,"value":text,"count":count,"policy":"character-name-v1/Godot-Advanced-composite-boundaries","text_server":server.get_name(),"engine":Engine.get_version_info().string}
