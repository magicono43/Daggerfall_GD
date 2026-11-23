class_name StartupProviderBoundary
extends RefCounted
## DATA access has application lifetime; IMP-005 publication remains independent.
var classic := preload("res://scripts/data/classic_access.gd").new()
var definitions := preload("res://scripts/data/definition_registry.gd").new()
var formulas := preload("res://scripts/rule/formula_registry.gd").new()
var faults: Dictionary = {} # Controlled failure-only fixture seam.
var before_menu := Callable()
var classic_preparations := 0 # Diagnostic count of explicit source preparation requests.
var presentation: RefCounted # Explicitly enabled; legacy compositions keep their inventory.
var preferences: RefCounted
var media: RefCounted
var media_preferences: RefCounted
var _preference_stores: Dictionary = {}
var layouts: RefCounted
var variants: RefCounted
var geography: RefCounted

func enable_variant_inputs() -> Dictionary:
	if layouts == null: return {"ok":false,"reason":"Register layout provider before variants."}
	var candidate := preload("res://scripts/data/variant_inputs.gd").new()
	candidate.layouts = layouts
	var registered := register_content_adapter(candidate,"",[])
	if registered.ok: variants = candidate
	return registered

func enable_layout_inputs(required_resource_sources: Array = []) -> Dictionary:
	var candidate := preload("res://scripts/data/layout_inputs.gd").new()
	candidate.classic = classic
	candidate.resource_sources = required_resource_sources.duplicate(true)
	candidate.media = media
	var registered := register_content_adapter(candidate,"",[])
	if registered.ok: layouts = candidate
	return registered

func enable_geography_inputs() -> Dictionary:
	var candidate := preload("res://scripts/data/geography_inputs.gd").new()
	candidate.classic = classic
	var registered := register_content_adapter(candidate,"",[])
	if registered.ok: geography = candidate
	return registered

func enable_faction_quest_inputs() -> Dictionary:
	return register_content_adapter(preload("res://scripts/data/faction_quest_inputs.gd").new(),"",[])

func enable_item_spell_inputs() -> Dictionary:
	var candidate := preload("res://scripts/data/item_spell_inputs.gd").new()
	candidate.classic = classic
	return register_content_adapter(candidate,"",[])

func enable_actor_inputs() -> Dictionary:
	var candidate := preload("res://scripts/data/actor_inputs.gd").new()
	candidate.classic = classic
	return register_content_adapter(candidate,"",[])

func enable_media_replacements() -> Dictionary:
	var candidate := preload("res://scripts/data/media_replacements.gd").new()
	var registered := register_content_adapter(candidate,"",[])
	if registered.ok:
		media = candidate
		if layouts != null: layouts.media = candidate
		media_preferences = preload("res://scripts/av/media_preferences.gd").new()
		media_preferences.media = candidate
	return registered

func enable_classic_media(required_sources: Array) -> bool:
	# Required sources are an explicit consumer declaration, never directory discovery.
	# Optional startup videos are not declared here by the normal shell.
	return classic.register_adapter("classic-media-v1",required_sources) and classic.enable_capability("classic-media-v1")

func enable_mod_preferences() -> Dictionary:
	var registered := register_content_adapter(preload("res://scripts/mod/preference_definitions.gd").new(), "", [])
	if registered.ok:
		preferences = preload("res://scripts/mod/preferences.gd").new()
	return registered

func enable_locale_fonts() -> Dictionary:
	var registered := register_content_adapter(preload("res://scripts/data/locale_fonts.gd").new(),"",[])
	if registered.ok:
		presentation = preload("res://scripts/session/text_presentation.gd").new()
	return registered

func enable_structured_text() -> bool:
	return classic.register_adapter("classic-text-v1", [{"file":"TEXT.RSC","format":"text-rsc-v1"}]) and classic.enable_capability("classic-text-v1")

func register_bundled_text() -> Dictionary:
	# Catalogs need no classic source; bundled intake also works from an exported PCK.
	return register_content_adapter(preload("res://scripts/data/text_catalog.gd").new(), "", [])

func uses_definition_pipeline() -> bool:
	return true

func register_content_adapter(adapter: RefCounted, root: String, files: Array) -> Dictionary:
	if classic.ready() or classic.prepared_count() > 0:
		return {"ok": false, "reason": "Content adapters and required classic sources must register before reader preparation."}
	var checked := definitions.validate_adapter(adapter)
	if not checked.ok:
		return checked
	var declaration: Dictionary = adapter.declaration()
	var sources: Array = declaration.get("classic_sources", [])
	if not sources.is_empty():
		var capability: String = "content-" + str(declaration.id)
		if not classic.register_adapter(capability, sources) or not classic.enable_capability(capability):
			return {"ok": false, "reason": "Required classic-source declaration cannot be satisfied by the registered reader contract."}
	return definitions.register_adapter(adapter, root, files)

func prepare_content(mods: RefCounted) -> Dictionary:
	var hooks: Dictionary = formulas.prepare(mods)
	var content: Dictionary = definitions.prepare(mods)
	if not content.ok:
		return content
	if not hooks.ok:
		return {"ok":false,"kind":"formula_preflight","source":"formula_hooks","reason":"Repair or explicitly omit invalid formula contributions before entry.","formulas":hooks}
	if presentation != null:
		var fonts: Dictionary = presentation.prepare(content.resources,content.ticket)
		if not fonts.ok:
			return fonts
	content.formula_ticket = hooks.ticket
	if media_preferences != null and media.has_midi_exports():
		var bank: Dictionary = media_preferences.capture(content.ticket)
		if not bank.ok: return {"ok":false,"kind":bank.kind,"source":"midi-bank","reason":bank.reason}
	if preferences != null:
		var prepared: Dictionary = preferences.prepare(content.resources, mods.adapter, mods.root.path_join("settings/mod_preferences"))
		if not prepared.ok:
			return prepared
		_preference_stores = prepared.stores
	content.formulas = hooks
	return content

func commit_preferences() -> void:
	if preferences != null:
		preferences.commit(_preference_stores)
		_preference_stores = {}

func check_classic(candidate: String) -> Dictionary:
	classic_preparations += 1
	return classic.prepare(candidate)

func activate_classic(checked: Dictionary) -> Dictionary:
	return classic.activate(checked)

func discard_classic_candidate() -> void:
	classic.discard_prepared()

func dispose() -> void:
	before_menu = Callable()
	if media != null: media.dispose()
	if media_preferences != null: media_preferences.dispose()
	if presentation != null:
		presentation.dispose()
	definitions.dispose()
	formulas.dispose()
	classic.dispose()

func publish_packages(_classic: Dictionary) -> Dictionary:
	return {"ok": false, "source": "packages", "kind": "commit_required", "reason": "Direct publication is unavailable. Prepare definitions with a validated MOD plan and commit through actual menu entry."}

func open_menu() -> Dictionary:
	if before_menu.is_valid():
		before_menu.call()
	if faults.has("menu"):
		return {"ok": false, "reason": "Controlled menu creation failure."}
	return {"ok": true}
