class_name StartupProviderBoundary
extends RefCounted
## DATA access has application lifetime; IMP-005 publication remains independent.
var classic := preload("res://scripts/data/classic_access.gd").new()
var definitions := preload("res://scripts/data/definition_registry.gd").new()
var formulas := preload("res://scripts/rule/formula_registry.gd").new()
var faults: Dictionary = {} # Controlled failure-only fixture seam.
var before_menu := Callable()
var classic_preparations := 0 # Diagnostic count of explicit source preparation requests.

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
	content.formula_ticket = hooks.ticket
	content.formulas = hooks
	return content

func check_classic(candidate: String) -> Dictionary:
	classic_preparations += 1
	return classic.prepare(candidate)

func activate_classic(checked: Dictionary) -> Dictionary:
	return classic.activate(checked)

func discard_classic_candidate() -> void:
	classic.discard_prepared()

func dispose() -> void:
	before_menu = Callable()
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
