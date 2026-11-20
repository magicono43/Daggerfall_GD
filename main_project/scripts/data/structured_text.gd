extends RefCounted
## Application DATA projection. No callbacks, selection, expansion or mutable cache.
const Tokens = preload("res://scripts/data/text_tokens.gd")
const Catalog = preload("res://scripts/data/text_catalog.gd")
const VERSION := "structured-text-v1"

static func read(classic: RefCounted, record: int) -> Dictionary:
	var raw: Dictionary = classic.read_record("TEXT.RSC",record)
	if not raw.ok:
		return raw
	return Tokens.decode_classic(raw.bytes,raw.source,record,raw.offset)

## Mapping is an explicit caller-owned declaration, never inferred from key wording.
## Normal catalog fallback completes first; mapped classic source is tried only
## for exhausted ordinary text. Independent essential recovery always wins.
static func lookup(registry: RefCounted, classic: RefCounted, collection: String, key: String, locale: String, mappings: Dictionary, required_controls: Variant = null) -> Dictionary:
	var result := Catalog.lookup(registry,collection,key,locale,"",required_controls)
	if result.ok:
		return result
	var target := collection + "/" + key
	if mappings.has(target):
		if not mappings[target] is int or mappings[target] < 0 or mappings[target] >= 65535:
			result.diagnostics.append({"kind":"invalid_mapping","source":target,"reason":"Explicit TEXT.RSC ID must be an unsigned 16-bit integer."})
		else:
			var decoded := read(classic,mappings[target])
			if decoded.ok and required_controls is Array:
				var structure := Tokens.require_structure(decoded.tokens,required_controls)
				if not structure.ok:
					structure.source = decoded.source
					structure.record = decoded.record
					decoded = structure
			if decoded.ok:
				decoded.kind = "source"
				decoded.collection = collection
				decoded.key = key
				decoded.locale = locale
				decoded.diagnostics.append_array(result.diagnostics)
				return decoded
			result.diagnostics.append(decoded)
	return result
