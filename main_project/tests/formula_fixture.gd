extends RefCounted
const HOOK := "fixture.integer"
const Callbacks = preload("res://tests/formula_case_callbacks.gd")
const Content = preload("res://tests/publication_fixture.gd")
const Schema = preload("res://tests/fixture_definition_adapter.gd")

static func configure_controller(controller: RefCounted, root: String) -> Dictionary:
	Content.write(root.path_join("a-main.json"),Content.contribution("items/main.json","replace",[Content.record("sword",1)]))
	var adapter: Dictionary = controller.providers.register_content_adapter(Schema.new(),root,["a-main.json"])
	var callbacks := {"builtin":Callbacks.new(),"a":Callbacks.new(),"b":Callbacks.new()}
	var declaration: Dictionary = controller.providers.formulas.declare_integer_hook(HOOK,callbacks.builtin.builtin)
	if not adapter.ok or not declaration.ok:
		push_error("Formula fixture setup failed.")
	return callbacks

static func configure(shell: Control, fixture: Dictionary) -> void:
	shell.set_meta("formula_callbacks",configure_controller(shell.controller,str(fixture.sandbox).path_join("shipped")))

static func entry(callback: Callable, hook: String = HOOK) -> Dictionary:
	return {"hook":hook,"contract":"integer-formula-v1","callback":callback}
