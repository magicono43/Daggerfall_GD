extends "res://tests/layout_reload_cases.gd"
const V = preload("res://scripts/data/variant_inputs.gd")
const R = preload("res://scripts/data/variant_resolution.gd")

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var result: Dictionary = await super.run(shell,fixture)
	var provider = shell.controller.providers
	var registry: RefCounted = provider.definitions
	var adapter: RefCounted = provider.variants
	var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(str(fixture.sandbox).path_join("variant-restart-receipt.json")))
	var request := {"schema":R.VERSION,"owner":"controlled new-session restore-order probe","content_context":adapter.context(registry).context,"layout":Layout.lookup(registry,"packs/test.pack#custom-resources").record.identity,"layout_selection":{"intent":"baseline"},"selections":[],"required":[],"compatibility":[]}
	var fresh: Dictionary = adapter.resolve(registry,request,provider.layouts.classic_resource)
	check("variants fresh process baseline has no inherited selection",[10,20,30],fresh.occurrences[0].records[0].record.transform.position)
	check("variants fresh process has new content context",false,Layout.Common.equal_input(request.content_context,old.old_context))
	request.content_context = old.old_context
	check("variants fresh process rejects previous context",false,adapter.resolve(registry,request,provider.layouts.classic_resource).ok)
	request.content_context = adapter.context(registry).context
	request.layout_selection = {}
	check("variants fresh missing required selection fails",false,adapter.resolve(registry,request,provider.layouts.classic_resource).ok)
	check("variants fresh definitions locked",true,shell.controller.mods.locked)
	check("variants fresh real restore remains unavailable",false,fresh.save_compatible)
	result.checks = checks
	result.count = checks.size()
	result.ok = checks.all(func(c: Dictionary): return Layout.Common.equal_input(c.expected,c.actual))
	return result
