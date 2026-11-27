extends Control
## Local scroll motion never rebuilds the owner/view or draws randomness.
var valid: Callable
var answer: Callable
var body: Control
var scroll_atlas: AtlasTexture
var effect_atlas: AtlasTexture
var effect: TextureRect
var effect_frames := 0
var effect_delay := 71
var scroll_offset := 0.0
var max_scroll := 0.0
var held := 0
var _pointer := Vector2.ZERO
var _fraction := 0.0
var scroll_frame := 0

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_CLOSE_REQUEST]: held = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: _pointer = event.position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed: held = 0
	if not valid.is_valid() or not valid.call(): held = 0; return
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
		var local: Vector2 = get_global_transform_with_canvas().affine_inverse()*event.position
		if Rect2(0,0,320,200).has_point(local): scroll_by(-1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1); get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
	if not valid.is_valid() or not valid.call() or not event is InputEventKey or not event.pressed or event.echo: return
	var choice: int = [KEY_A,KEY_B,KEY_C].find(event.keycode)
	if choice >= 0: answer.call(choice); get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if held == 0: return
	if not valid.is_valid() or not valid.call(): held = 0; return
	var local := get_global_transform_with_canvas().affine_inverse()*_pointer
	if not Rect2(0,120 if held < 0 else 184,320,16).has_point(local): held = 0; return
	_fraction += minf(delta,0.1)*60
	while _fraction >= 1: scroll_by(held); _fraction -= 1

func scroll_by(direction: int) -> void:
	var next := clampf(scroll_offset+direction,0,max_scroll)
	if next == scroll_offset: return
	scroll_offset = next; body.position.y = -scroll_offset
	scroll_frame = posmod(scroll_frame+direction,16)
	if scroll_atlas != null: scroll_atlas.region = Rect2(0,scroll_frame*80,320,80)

func update_animation(elapsed: int) -> void:
	if effect == null or effect_atlas == null or effect_frames <= 0: return
	var frame := mini(effect_frames-1,elapsed/maxi(1,effect_delay))
	effect_atlas.region = Rect2(0,frame*119,effect_atlas.atlas.get_width(),119)
