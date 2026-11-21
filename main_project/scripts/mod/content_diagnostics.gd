extends RefCounted
## On-demand current DATA candidate, never a stale synthetic published plan.
static func inspect(controller: RefCounted) -> Dictionary:
	if controller.transition_busy or controller.mods.entry_busy: return {"ok":false,"kind":"busy","reason":"Menu entry owns the prepared candidate."}
	if controller.mods.locked: return {"ok":false,"reason":"Content Diagnostics is available before main-menu entry."}
	if not controller.providers.classic.ready(): return {"ok":false,"reason":"Select and validate the required classic source before diagnosing content."}
	# This is inspection, not CORE routing: check_content can automatically enter
	# the menu for a clean profile when the optional setup preference is disabled.
	controller.prepared_content = controller.providers.prepare_content(controller.mods)
	var candidate: Dictionary = controller.providers.definitions.projection()
	if candidate.is_empty(): return {"ok":false,"reason":controller.prepared_content.get("reason","Candidate unavailable.")}
	if not controller.prepared_content.ok and candidate.ok:
		candidate.ok = false
		candidate.issues.append({"source":controller.prepared_content.get("source","preparation"),"kind":controller.prepared_content.get("kind","preparation_failed"),"reason":controller.prepared_content.reason})
	return {"ok":true,"ticket":candidate.ticket,"revision":candidate.revision,"profile":candidate.profile,"valid":candidate.ok,"resources":candidate.resources.duplicate(true),"issues":candidate.issues.duplicate(true),"omitted":candidate.omitted.duplicate(true),"media":controller.providers.media.diagnostics() if controller.providers.media != null else {},"measurements":controller.providers.media.measurements.duplicate(true) if controller.providers.media != null else {}}

static func line(parent: Control, text: String, size := 16) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",size)
	parent.add_child(label)

static func source_label(source: Dictionary) -> String:
	return "%s · %s" % [source.get("provider","unavailable"),source.get("file","")]

static func show(shell: Control) -> void:
	var report := inspect(shell.controller)
	var dialog := AcceptDialog.new()
	dialog.title = "Content Diagnostics"
	dialog.size = Vector2i(1000,650)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(940,550)
	dialog.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.custom_minimum_size.x = 900
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(rows)
	if not report.ok:
		line(rows,report.reason)
	else:
		line(rows,"Profile %s · candidate %d · revision %d · %s" % [report.profile,report.ticket,report.revision,"valid" if report.valid else "needs attention"],22)
		if shell.controller.providers.media != null:
			var caps := preload("res://scripts/data/native_media.gd").capabilities()
			line(rows,"Native MIDI: %s · video: %s" % [str(caps.get("midi",false)),str(caps.get("video",false))])
			line(rows,"FluidSynth %s · FFmpeg %s\n%s\n%s" % [caps.get("fluid_version","unavailable"),caps.get("ffmpeg_build","unavailable"),caps.get("midi_reason",""),caps.get("video_reason","")])
			line(rows,"Bundled default bank pin: GeneralUser GS 2.0.3 · "+preload("res://scripts/data/native_media.gd").BANK_HASH)
			var banks: RefCounted = shell.controller.providers.media_preferences
			var bank: Dictionary = banks.capture(report.ticket)
			line(rows,"MIDI bank ready: "+JSON.stringify(bank.get("identity",{})) if bank.ok else "MIDI bank unavailable: "+bank.get("reason",""))
			if not banks.last_issue.is_empty(): line(rows,banks.last_issue)
		for issue: Dictionary in report.issues: line(rows,"%s\n%s: %s" % [issue.source,issue.kind,issue.reason])
		for resource: Dictionary in report.resources.values():
			line(rows,resource.domain+" / "+resource.path,20)
			for id: String in resource.records:
				var record: Dictionary = resource.records[id]
				line(rows,id+"\nWinner: "+source_label(record.winner),18)
				var contributors: Array = []
				for source: Dictionary in record.contributors: contributors.append(source_label(source))
				line(rows,"Contributors: "+" → ".join(contributors))
				for field: String in record.fields: line(rows,"  "+field+": "+source_label(record.fields[field]))
				var context: Dictionary = report.media.get(resource.path+"#"+id,{}) if resource.domain == "media.assets" else {}
				if not context.is_empty():
					var physical: Dictionary = context.source
					if physical.is_empty(): line(rows,context.reason)
					else:
						line(rows,"Physical source: %s · %s" % [physical.provider,str(physical.source.root).path_join(physical.file)])
						line(rows,"Profile: %s · converter: %s · generation: %d\nSHA-256: %s" % [physical.profile,physical.converter,context.generation,physical.sha256])
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	shell.add_child(dialog)
	dialog.popup_centered()
