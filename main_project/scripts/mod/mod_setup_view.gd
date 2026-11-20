extends RefCounted
## UI submits MOD requests; it does not infer readiness from saved selections.
var shell: Control
var owner: RefCounted

func _init(startup_shell: Control, configuration: RefCounted) -> void:
	shell = startup_shell
	owner = configuration

func run(action: Callable) -> void:
	owner.status = action.call()
	shell.render()

func show() -> void:
	shell.label("Mods · Discovery and selection", 24)
	if owner.committed.is_empty():
		shell.label(str(owner.status.get("reason", "Mod profiles are unavailable.")))
		shell.button("Retry mod profiles", func():
			var result: Dictionary = owner.initialize()
			if result.ok:
				owner.rescan()
			shell.render())
		return
	if not owner.status.is_empty():
		shell.label(str(owner.status.get("reason", owner.status.get("detail", ""))), 16)
	shell.label("Profiles and pending edits are separate. Switching profiles retains each draft. Save Profile can save an unfinished setup.", 16)
	var profiles := OptionButton.new()
	var ids: Array = owner.committed.profiles.keys()
	ids.sort()
	for id: String in ids:
		profiles.add_item(owner.committed.profiles[id].name)
		if id == owner.selected:
			profiles.select(profiles.item_count - 1)
	profiles.item_selected.connect(func(index: int): run(func(): return owner.select_profile(ids[index])))
	shell.panel.add_child(profiles)
	shell.label("Pending profile: %s%s" % [owner.pending().name, " · unsaved edits" if owner.dirty() else " · saved"], 18)
	var name := LineEdit.new()
	name.placeholder_text = "Profile name"
	name.max_length = 80
	shell.panel.add_child(name)
	var management := HBoxContainer.new()
	shell.panel.add_child(management)
	for action: String in ["create", "rename", "duplicate"]:
		shell.button(action.capitalize() + " Profile", func(): run(func(): return owner.manage(action, name.text)), management)
	shell.button("Delete Profile…", func():
		var selected: String = owner.selected
		var dialog := ConfirmationDialog.new()
		dialog.dialog_text = "Delete profile '%s' and its pending edits?" % owner.pending().name
		dialog.confirmed.connect(func():
			if owner.selected == selected:
				run(func(): return owner.manage("delete", "", true))
			dialog.queue_free())
		dialog.canceled.connect(func(): dialog.queue_free())
		shell.add_child(dialog)
		dialog.popup_centered())
	shell.button("Save Profile", func(): run(owner.save_profile))
	shell.button("Rescan Mods", func(): run(owner.rescan))
	if not owner.discovery.get("ok", false) and not owner.without_mods:
		shell.label("%s\n%s" % [owner.discovery.get("path", ""), owner.discovery.get("reason", "Discovery has not completed.")])
		shell.button("Retry Mods", func(): run(owner.rescan))
		shell.button("Continue without mods for this run", func(): run(owner.continue_without_mods))
	else:
		if owner.without_mods:
			shell.label("Installed library omitted for this run. Saved profiles remain intact.")
		for diagnostic: Dictionary in owner.discovery.get("diagnostics", []):
			shell.label("%s\n%s" % [diagnostic.path, diagnostic.reason], 16)
		var groups: Dictionary = owner.grouped()
		for id: String in groups:
			if groups[id].size() < 2:
				continue
			shell.label(("Choice required: " if owner.unresolved().has(id) else "Duplicate decision recorded: ") + id)
			var copies: Array = groups[id]
			var expected: Array = owner.fingerprint(copies)
			for copy: Dictionary in copies:
				shell.label(copy.path, 15)
				shell.button("Use %s %s · %s" % [copy.name, copy.version, copy.format], func(): run(func(): return owner.choose_copy(id, copy.path, expected)))
			shell.button("Skip duplicate ID " + id, func(): run(func(): return owner.choose_copy(id, "", expected)))
		for row: Dictionary in owner.rows():
			var eligible: Dictionary = owner.available()
			var detail := "unavailable / unresolved"
			if eligible.has(row.id):
				var copy: Dictionary = eligible[row.id]
				detail = "%s %s · %s · %s" % [copy.name, copy.version, copy.format, copy.path]
			shell.label("%s · %s%s\n%s" % [row.id, "enabled" if row.enabled else "disabled", " · skipped for this run" if row.skipped else "", detail], 16)
			var actions := HBoxContainer.new()
			shell.panel.add_child(actions)
			for action: String in ["toggle", "up", "down", "remove", "restore" if row.skipped else "skip"]:
				var text: String = {"toggle": "Disable" if row.enabled else "Enable", "up": "Move up", "down": "Move down", "remove": "Remove from pending profile", "skip": "Skip for this run", "restore": "Restore for this run"}[action]
				shell.button(text + " · " + row.id, func(): run(func(): return owner.edit(row.id, action)), actions)
	show_dependencies()
	shell.label("Definition publication is unavailable in this increment. A valid dependency plan or saved profile cannot enter the main menu.", 16)

func show_dependencies() -> void:
	var plan: Dictionary = owner.validate_dependencies()
	shell.label("Dependencies · " + ("valid pending plan" if plan.ok else "needs attention"), 24)
	for issue: Dictionary in plan.errors:
		shell.label("%s → %s: %s" % [issue.dependent, issue.provider, issue.reason], 16)
		if issue.has("declaration"):
			shell.label("Installed: %s · requested: %s" % [issue.installed_version, JSON.stringify(issue.declaration)], 15)
		if issue.get("can_enable", false):
			shell.button("Enable required provider " + issue.provider, func(): run(func(): return owner.enable_dependency(issue.key, plan.revision)))
	for issue: Dictionary in plan.warnings:
		shell.label("Warning · %s → %s: %s · installed %s · %s" % [issue.dependent, issue.provider, issue.reason, issue.installed_version, JSON.stringify(issue.declaration)], 16)
	for integration: Dictionary in plan.integrations:
		if integration.optional and not integration.active:
			shell.label("Inactive integration %s → %s: %s" % [integration.dependent, integration.provider, integration.reason], 16)
		if plan.suppressible.has(integration.key):
			shell.button("Suppress optional integration " + integration.key + " for this run", func(): run(func(): return owner.suppress_optional(integration.key, plan.revision)))
		if integration.reason == "suppressed_for_run":
			shell.button("Restore optional integration " + integration.key, func(): run(func(): return owner.restore_optional(integration.key)))
	shell.button("Preview Auto-sort", func(): run(owner.request_sort_preview))
	if not owner.sort_preview.is_empty():
		var preview: Dictionary = owner.sort_preview.duplicate(true)
		shell.label("Sort preview · " + " → ".join(preview.order), 20)
		shell.button("Accept Sort Preview", func(): run(func(): return owner.accept_sort_preview(preview.id)))
		shell.button("Dismiss Sort Preview", func(): run(func(): return owner.dismiss_sort_preview(preview.id)))
	shell.button("Validate and Continue", func(): shell.controller.check_content(); shell.render())
