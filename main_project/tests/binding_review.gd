extends RefCounted
## Human review only: production shell/editor and explicit controlled CORE provider.
func run(shell: Control, _fixture: Dictionary) -> Dictionary:
	var stock: RefCounted = shell.session_shell
	shell.controller.route = "main_menu"
	stock.core.provider = preload("res://tests/controlled_session_provider.gd").new()
	stock.synchronize_startup()
	stock.request("new")
	stock.open_controls()
	shell.render()
	# Ordinary UI remains active. Quit uses the stock shutdown/storage path.
	while shell.is_inside_tree(): await shell.get_tree().process_frame
	return {"ok":false,"reason":"Human review has no automatic PASS."}
