extends RefCounted
const Native = preload("res://scripts/ui/creation_native_controls.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")

static func render(biography: RefCounted, view: RefCounted, expected: Dictionary, value: Dictionary) -> void:
	var generation: int = view._render_generation
	preload("res://scripts/ui/creation_popup.gd").notice(view,"Reputation",func():
		if generation == view._render_generation and Draft.same_value(expected,view.navigation.context()) and biography.report:
			Native.click(view); biography.dismiss_report(view),"biography-reputation")
	var panel: Panel
	for child in view._page.get_children():
		if child.get_meta("creation_popup",false): panel = child
	for child: Control in panel.get_children(): child.hide()
	panel.size = Vector2(220,88); panel.position = (Vector2(640,400)-panel.size*2)/2
	panel.set_meta("biography_reputation_report",true)
	Native.text(view,panel,view.translated("biography.reputation-heading","Your reputation have changed as follows:"),Rect2(10,12,200,9),"biography.reputation.heading",true)
	var changes: Dictionary = value.intent.social_additions
	var groups := ["Commoners","Merchants","Scholars","Nobility","Underworld"]
	for index in 5:
		var amount: int = changes.get("classic.social:"+str(index),0)
		var direction := "Higher" if amount > 0 else "Lower" if amount < 0 else "Unchanged"
		Native.text(view,panel,view.translated("biography.social."+str(index),groups[index])+":",Rect2(14,27+7*index,72,7),"biography.reputation.group")
		var label := Native.text(view,panel,view.translated("biography.reputation."+direction.to_lower(),direction),Rect2(85,27+7*index,120,7),"biography.reputation.direction")
		label.set_meta("biography_social_direction",index)
