extends RefCounted
## Application preference; each admission captures its own validated bank bytes.
const Native = preload("res://scripts/data/native_media.gd")
const SETTING = "media/midi_bank"
const SKIP_SETTING = "media/video_skip"
var settings: RefCounted
var media: RefCounted
var _default: Dictionary = {}
var last_issue := ""

func declare_settings(owner: RefCounted) -> void:
	settings = owner
	owner.declare(SETTING,"",TYPE_STRING,"live",valid_reference)
	owner.declare(SKIP_SETTING,"authored",TYPE_STRING,"live",func(value: String): return value in ["authored","any","skip","back"])

func valid_reference(value: String) -> bool:
	if value.is_empty(): return true
	var reference: Variant = JSON.parse_string(value)
	return reference is Dictionary and reference.size()==2 and reference.get("provider") is String and reference.get("key") is String and not str(reference.provider).is_empty() and not str(reference.key).is_empty()

func capture(ticket := -1) -> Dictionary:
	last_issue = ""
	var selected := str(settings.effective.get(SETTING,"")) if settings != null else ""
	if not selected.is_empty():
		var reference: Dictionary = JSON.parse_string(selected)
		var resolved: Dictionary = media.export_resource(reference.provider,reference.key,"bank",ticket)
		if resolved.ok:
			return {"ok":true,"bytes":resolved.resource.bytes,"presets":resolved.resource.presets,"identity":resolved.provenance.duplicate(true)}
		if resolved.kind not in ["missing_provider","missing_export"]: return resolved
		last_issue = "Optional saved MIDI bank is missing; using validated GeneralUser GS 2.0.3. "+resolved.reason
	if _default.is_empty() or not _default.get("ok",false): _default = Native.default_bank()
	var result := _default.duplicate(true)
	result.preference_issue = last_issue
	return result

func select_bank(provider: String, key: String) -> Dictionary:
	var value := ""
	if not provider.is_empty() or not key.is_empty():
		var resolved: Dictionary = media.export_resource(provider,key,"bank")
		if not resolved.ok: return resolved
		value = JSON.stringify({"provider":provider,"key":key})
	return settings.apply({SETTING:value},func(_values: Dictionary): return true)

func choices() -> Array:
	var result: Array = [{"label":"GeneralUser GS 2.0.3 (default)","provider":"","key":""}]
	if media != null:
		for row: Dictionary in media.bank_exports(): result.append(row)
	return result

func dispose() -> void:
	_default.clear()
	settings = null
	media = null
