extends RefCounted
## Application-lifetime optional UI resources. One decode/texture per target,
## including cached missing results. DATA/MOD own selection and content locking.
const FILES = {"creation.race":"TMAP00I0.IMG","creation.questionnaire":"CHGN00I0.IMG","creation.custom":"CUST00I0.IMG","creation.name":"CHAR00I0.IMG","creation.face":"CHAR01I0.IMG","creation.attributes":"CHAR02I0.IMG","creation.skills":"CHAR03I0.IMG","creation.summary":"CHAR04I0.IMG","creation.reflexes":"CHAR05I0.IMG"}
var classic: RefCounted
var media: RefCounted
var _textures: Dictionary = {}
var _baselines: Dictionary = {}
var measurements := {"requests":0,"baseline_decodes":0,"textures":0,"decode_usec":0,"rgba_bytes":0}

func declare(providers: RefCounted) -> Dictionary:
	classic = providers.classic
	media = providers.media
	if media == null: return {"ok":false,"reason":"Creation art requires the existing media resolver."}
	for target: String in FILES:
		var checked: Dictionary = media.register_target(target,"image",[],_baseline.bind(target))
		if not checked.ok: return checked
	return {"ok":true}

func _baseline(target: String) -> Dictionary:
	if not _baselines.has(target):
		var started := Time.get_ticks_usec()
		_baselines[target] = classic.creation_image(FILES[target])
		measurements.baseline_decodes += 1
		measurements.decode_usec += Time.get_ticks_usec()-started
	return _baselines[target].duplicate()

func resolve(target: String) -> Dictionary:
	measurements.requests += 1
	if target.is_empty(): return {"ok":false,"reason":"This step uses a readable untextured dialog."}
	if _textures.has(target): return _textures[target].duplicate()
	var selected: Dictionary = media.resolve(target,"image")
	if not selected.ok:
		_textures[target] = selected
		return selected.duplicate()
	if not selected.get("image") is Image or selected.image.is_empty(): return {"ok":false,"reason":"Selected interface image is unavailable."}
	var texture := ImageTexture.create_from_image(selected.image)
	measurements.textures += 1
	measurements.rgba_bytes += selected.image.get_width()*selected.image.get_height()*4
	_textures[target] = {"ok":true,"texture":texture,"provenance":selected.get("provenance",{}).duplicate(true),"target":target,"resolution":selected.get("resolution","replacement")}
	return _textures[target].duplicate()

func dispose() -> void:
	_textures.clear()
	_baselines.clear()
	classic = null
	media = null
