extends Control
## DFU CreateCharCustomClass: stationary snapshots, one-second unscaled fade.
const LINGER_MSEC = 1000
var texture: Texture2D
var current_y := 115.0
var trails: Array = []

static func gauge_y(points: int, policy: Dictionary) -> float:
	var y := 115.0
	if points >= 0: y -= 37.0*points/maxf(1.0,float(policy.max))
	else: y += 41.0*(-points)/maxf(1.0,-float(policy.min))
	return clampf(floorf(y),46,186)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	trails = trails.filter(func(trail): return now-int(trail.started) < LINGER_MSEC)
	queue_redraw()
	if trails.is_empty(): set_process(false)

func _draw() -> void:
	if texture == null: return
	var now := Time.get_ticks_msec()
	for trail: Dictionary in trails:
		var alpha := clampf(1.0-float(now-int(trail.started))/LINGER_MSEC,0,1)
		if alpha > 0: draw_texture_rect(texture,Rect2(220,trail.y,24,9),false,Color(1,1,1,alpha))
	draw_texture_rect(texture,Rect2(220,current_y,24,9),false)
