extends RefCounted
const ROOT = "res://content/media/verification"
const DOMAIN = "media.assets"
const VERSION = "media-declarations-v1"

static func envelope(path: String, operation: String, entries: Array) -> Dictionary:
	return {"domain":DOMAIN,"path":path,"operation":operation,"entries":entries}

static func export_entry(id: String, file: String, profile := "png-v1", type := "image") -> Dictionary:
	return {"id":id,"value":{"schema":VERSION,"kind":"export","type":type,"file":file,"profile":profile}}

static func target(id: String, provider: String, key: String, type := "image") -> Dictionary:
	return {"id":id,"value":{"schema":VERSION,"kind":"target","type":type,"asset":{"provider":provider,"key":key}}}

static func configure(shell: Control) -> void:
	var media: RefCounted = shell.controller.providers.media
	media.shipped_sources = [{"root":ROOT,"file":"a-exports.json"},{"root":ROOT,"file":"b-targets.json"}]
	media.register_target("classic.sound.3","audio",["sound.3"],func(): return shell.controller.providers.classic.decode_sound(3))
	media.register_target("classic.model.44005","model",["model.44005"],func(): return shell.controller.providers.classic.decode_model(44005))
	media.register_target("classic.texture.2.0.0","image",["texture.2.0.0"],Callable())
