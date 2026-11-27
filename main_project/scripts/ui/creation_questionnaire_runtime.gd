extends Node
## Presentation clock only. Answers and category weights remain CHAR-owned.
const Draft = preload("res://scripts/char/creation_draft.gd")
var _view: WeakRef
var _context: Dictionary = {}
var canvas: WeakRef
var playing := false
var category := 0
var started := 0
var duration_msec := 0
var answer_submissions := 0
var ignite_submissions := 0

func _ready() -> void: set_process(false)

func current(view: RefCounted) -> bool:
	return view != null and view.active() and not view.shell.core.busy() and view.navigation.step().get("hook") == "questionnaire" and Draft.same_value(_context,view.navigation.context())

func start(view: RefCounted, selected_category: int, frames: int, delay: int) -> void:
	_view = weakref(view); _context = view.navigation.context().duplicate(true)
	category = selected_category; started = Time.get_ticks_msec(); duration_msec = frames*delay
	playing = true; answer_submissions += 1; set_process(true)

func stop() -> void:
	playing = false; _view = null; canvas = null; _context.clear(); set_process(false)

func _process(_delta: float) -> void:
	var view: RefCounted = _view.get_ref() if _view != null else null
	if not current(view): stop(); return
	var control: Control = canvas.get_ref() if canvas != null else null
	if is_instance_valid(control): control.update_animation(Time.get_ticks_msec()-started)
	if Time.get_ticks_msec()-started < duration_msec: return
	playing = false; set_process(false)
	var questionnaire: Dictionary = view.owner.projection().selections.questionnaire
	if questionnaire.answers.size() == questionnaire.questions.size(): view.action("next",view.navigation.context())
	else:
		view.career_view.question_position = mini(9,view.career_view.question_position+1)
		view.career_view.refresh(view)
