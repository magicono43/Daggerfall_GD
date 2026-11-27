extends RefCounted
const Custom = preload("res://scripts/char/custom_career.gd")
const Draft = preload("res://scripts/char/creation_draft.gd")
const Sheet = preload("res://scripts/ui/creation_custom_sheet.gd")
const ClassicPopup = preload("res://scripts/ui/creation_popup.gd")
const GREEN = Color(0.388,0.549,0.223)
const RED = Color(0.580,0.031,0.0)

static func request_close(career: RefCounted, view: RefCounted) -> void:
	if not view.active() or view.shell.core.busy() or view.navigation.summary_locked() or view.navigation.step().get("hook") != "custom" or career.custom_tab != 3: return
	var reputation: Dictionary = view.owner.projection().selections.custom.reputation
	var balance: int = view.inputs.policy.reputation_total
	for group in Custom.GROUPS: balance -= int(reputation[group])
	career.reputation_warning = balance != 0
	if balance == 0: career.custom_tab = 0
	career.refresh(view)

static func clicked_value(y: float, limits: Dictionary) -> int:
	# DFU rounds integer pixel heights upward only at remainder four of five.
	var distance := mini(50,int(absf(76-y)))
	var units := distance/5
	if distance%5 > 3: units += 1
	var limit: int = limits.max if y < 76 else -int(limits.min)
	var value := roundi(float(units)*limit/10.0)*(1 if y < 76 else -1)
	return clampi(value,int(limits.min),int(limits.max))

static func render(career: RefCounted, view: RefCounted, expected: Dictionary, value: Dictionary) -> void:
	var art: RefCounted = view.shell.host.controller.providers.creation_art
	var image: Dictionary = art.resolve("creation.reputation")
	var font: Font = art.popup_font(ThemeDB.fallback_font)
	if view._presentation != null: font = view._presentation.creation_popup_font(font)
	var root := Control.new(); root.size = Vector2(168,189); root.scale = Vector2(2,2)
	root.position = (Vector2(640,400)-root.size*2)/2
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.set_meta("custom_reputation",true)
	view._page.add_child(root)
	if image.ok:
		var background := TextureRect.new(); background.texture = image.texture
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(background)
	else:
		var background := ColorRect.new(); background.color = Color("4b4b48"); background.size = root.size
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(background)
		Sheet.label(root,"Reputations",Rect2(0,5,168,8),font,true)
		Sheet.label(root,"Liked",Rect2(0,18,168,7),font,true)
		Sheet.label(root,"Disliked",Rect2(0,133,168,7),font,true)
	var generation: int = view._render_generation
	var current := func(): return generation == view._render_generation and view.active() and not view.shell.core.busy() and Draft.same_value(expected,view.navigation.context()) and career.custom_tab == 3 and not view.navigation.summary_locked()
	var locked: bool = view.navigation.summary_locked() or career.reputation_warning
	var balance: int = view.inputs.policy.reputation_total
	for index in Custom.GROUPS.size():
		var group: String = Custom.GROUPS[index]
		var number: int = value.reputation[group]
		var limits: Dictionary = view.inputs.policy.reputation[group]
		if not image.ok:
			var heading := Sheet.label(root,group.capitalize(),Rect2(12+33*index,120,100,7),font)
			heading.rotation = -PI/2
		balance -= number
		var extent := float(limits.max) if number > 0 else -float(limits.min)
		var height := clampf(absf(number)/maxf(1.0,extent)*50,0,50)
		if number != 0:
			var bar := ColorRect.new(); bar.color = GREEN if number > 0 else RED
			bar.position = Vector2(3+33*index,76-height if number > 0 else 77)
			bar.size = Vector2(5,height); bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bar.set_meta("reputation_bar",group); root.add_child(bar)
		Sheet.label(root,str(number),Rect2(18+32*index,143,28,7),font)
		var left := 0 if index == 0 else 2+33*index
		var width := 35 if index == 0 else 33 if index < 4 else 34
		var control := Sheet.button(view,root,"reputation/"+group,group.capitalize()+" reputation",Rect2(left,24,width,104),func(): pass,locked)
		var control_ref: WeakRef = weakref(control)
		var update := func(incoming: int):
			if not current.call() or career.reputation_warning: return
			var revised := value.duplicate(true)
			revised.reputation[group] = clampi(incoming,int(limits.min),int(limits.max))
			var result: Dictionary = view.action("edit",expected,revised)
			if result.ok: art.play_dialog_click(view.shell.host)
		control.gui_input.connect(func(event: InputEvent):
			if locked or not current.call(): return
			var target: Control = control_ref.get_ref()
			if not is_instance_valid(target): return
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				update.call(clicked_value(event.position.y+24,limits)); target.accept_event()
			elif event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_UP,KEY_DOWN,KEY_HOME,KEY_END]:
				var next := number+(1 if event.keycode == KEY_UP else -1)
				if event.keycode == KEY_HOME: next = int(limits.max)
				elif event.keycode == KEY_END: next = int(limits.min)
				update.call(next); target.accept_event())
	var total := Sheet.label(root,str(balance),Rect2(64,173,32,7),font)
	total.set_meta("reputation_remaining",true)
	Sheet.button(view,root,"custom/close-panel","Return to career",Rect2(129,165,33,14),func():
		art.play_dialog_click(view.shell.host)
		request_close(career,view),locked)
	if career.reputation_warning:
		ClassicPopup.notice(view,view.translated("prompt.reputation-balance","Reputation balance must equal zero before exiting."),func():
			if current.call(): career.reputation_warning = false; career.refresh(view))
