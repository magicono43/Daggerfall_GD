extends Node
## A held allocation gesture survives repaint, but not navigation or selection.
const INTERVAL_MSEC = 150
var _view: WeakRef
var _hook := ""
var _section := ""
var _id := ""
var _button := ""
var _draft := ""
var _direction := 0
var _pointer := Vector2.ZERO
var _next := 0

func _ready() -> void: set_process(false)

func begin(view: RefCounted, section: String, id: String, direction: int, button: String, pointer: Vector2) -> void:
	_view = weakref(view); _hook = view.navigation.step().hook; _section = section
	_id = id; _direction = direction; _button = button; _pointer = pointer; _draft = str(view.owner.token().id)
	_step(); _next = Time.get_ticks_msec()+INTERVAL_MSEC; set_process(_direction != 0)

func stop() -> void:
	_direction = 0; _view = null; set_process(false)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: _pointer = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed: stop()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_CLOSE_REQUEST]: stop()

func _current(view: RefCounted) -> bool:
	return view != null and view.active() and not view.shell.core.busy() and str(view.owner.token().id) == _draft and view.navigation.step().hook == _hook and view._capture.is_empty()

func _process(_delta: float) -> void:
	var view: RefCounted = _view.get_ref() if _view != null else null
	if not _current(view): stop(); return
	var control: Control = view._buttons.get(_button)
	if not is_instance_valid(control) or control.disabled: stop(); return
	if not Rect2(Vector2.ZERO,control.size).has_point(control.get_global_transform_with_canvas().affine_inverse()*_pointer): stop(); return
	if Time.get_ticks_msec() >= _next: _step(); _next = Time.get_ticks_msec()+INTERVAL_MSEC

func _step() -> void:
	var view: RefCounted = _view.get_ref() if _view != null else null
	if not _current(view) or not view.starting_view.change(view,_section,_id,_direction).ok: stop()
