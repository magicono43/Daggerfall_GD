extends RefCounted
## Isolated deterministic presentation selection: no gameplay source or global RNG.
const Hash = preload("res://scripts/data/variant_resolution.gd")
const Schema = preload("res://scripts/data/dungeon_context_schema.gd")
const Geography = preload("res://scripts/data/geography_inputs.gd")
const VERSION = "dungeon-presentation-sha256-v1"

static func resolve(definition: Dictionary, site: Dictionary, climate: String, configuration: Dictionary) -> Dictionary:
	var invalid := Schema.reason(definition)
	if not invalid.is_empty(): return {"ok":false,"kind":"invalid_context","reason":invalid}
	if site.get("domain") != Geography.DOMAIN or not site.get("local") is String or not site.get("package") is String or not site.get("record") is String or not Geography.valid_ref(climate): return {"ok":false,"kind":"invalid_context","reason":"Complete validated destination site and climate required."}
	if configuration.size() != 2 or not configuration.get("variation") is bool or not configuration.get("version") is String or configuration.version.is_empty(): return {"ok":false,"kind":"invalid_configuration","reason":"Explicit variation preference and compatible configuration version required."}
	var selected: Dictionary = definition.baseline.duplicate(true)
	var selection := "baseline"
	var fingerprint := Hash.digest({"algorithm":VERSION,"site":site,"climate":climate,"configuration":configuration,"definition":definition})
	if configuration.variation and definition.eligible and not definition.fixed:
		if not definition.climates.has(climate): return {"ok":false,"kind":"missing_palette","reason":"Eligible destination climate has no validated palette pool."}
		var pool: Array = definition.climates[climate]
		# Content/configuration-bound 32-bit SHA prefix, interpreted unsigned.
		selected = pool[fingerprint.substr(0,8).hex_to_int() % pool.size()].duplicate(true)
		selection = "variation"
	var material_slots: Dictionary = selected.duplicate(true)
	if definition.has("climate_bindings"):
		if not definition.climate_bindings.has(climate): return {"ok":false,"kind":"missing_palette","reason":"Destination climate lacks required material bindings."}
		material_slots.merge(definition.climate_bindings[climate].duplicate(true),true)
	for slot: String in definition.override:
		var value: Variant = definition.override[slot].duplicate(true) if definition.override[slot] is Dictionary else definition.override[slot]
		material_slots[slot] = value
		if selected.has(slot): selected[slot] = value
	return {"ok":true,"slots":selected,"material_slots":material_slots,"selection":selection,"fixed":definition.fixed,"override":definition.override.duplicate(true),"site":site.duplicate(true),"climate":climate,"configuration":configuration.duplicate(true),"version":fingerprint,"algorithm":VERSION,"gameplay_draws":0}
