extends RefCounted
## Uses the normal shell and actual creation controls; never enables gameplay.
func run(shell: Control, fixture: Dictionary) -> Dictionary:
	shell.controller.settings.effective["startup/show_setup"] = true
	shell.controller.select_folder(fixture.classic_source)
	shell.controller.continue_to_menu("run")
	shell.session_shell.synchronize_startup()
	shell.session_shell.open_creation()
	var view: RefCounted = shell.session_shell.creation_view
	view.exit()
	var provider := preload("res://tests/controlled_creation_inputs.gd").new()
	view.open(provider)
	view.notice = "CONTROLLED REVIEW: choose the assigned choices on each page. Enter any valid fixture name. Both class routes and both biography methods use explicit assigned outcomes; Begin Game reaches the real stock unavailable-entry response. No playable character or grants are created."
	shell.session_shell.render()
	if not fixture.get("review_smoke",false):
		# Keep the ordinary event loop and window-manager/Pause/Quit handlers alive.
		while true: await shell.get_tree().process_frame
	var checks: Array = []
	checks.append({"scenario":"review opens real creation window","expected":"creation","actual":shell.session_shell.windows.top().get("window")})
	checks.append({"scenario":"review explicit controlled label","expected":true,"actual":view.controlled})
	checks.append({"scenario":"review real entry still unavailable","expected":false,"actual":shell.session_shell.core.provider.prepare({},{}).ok})
	await shell.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := shell.get_viewport().get_texture().get_image()
	image.save_png(str(fixture.sandbox).path_join("creation-review.png"))
	checks.append({"scenario":"review rendered image","expected":false,"actual":image.is_empty()})
	return {"ok":checks.all(func(c):return c.expected == c.actual),"checks":checks,"count":checks.size(),"review_smoke":true,"human_pass":false,"fixture":fixture.fixture,"engine":Engine.get_version_info(),"display":DisplayServer.get_name()}
