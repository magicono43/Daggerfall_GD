extends PanelContainer
## Read-only development surface. Never a source of clocks, activity or settlement.
var _owner: WeakRef
var _scope := ""
var _actor := ""
var _episode := ""
var _body := Label.new()
var observed: Dictionary = {}

func _init() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06,0.08,0.10,1.0)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	add_theme_stylebox_override("panel",style)
	var layout := VBoxContainer.new()
	add_child(layout)
	var heading := Label.new()
	heading.text = "CHAR activity / exhaustion diagnostic"
	layout.add_child(heading)
	layout.add_child(_body)
	custom_minimum_size = Vector2(700,320)

func bind(owner: RefCounted, scope: String, actor: String, episode: String) -> void:
	_owner = weakref(owner)
	_scope = scope
	_actor = actor
	_episode = episode
	refresh()

func refresh() -> void:
	var owner: RefCounted = _owner.get_ref() if _owner != null else null
	if owner == null:
		_body.text = "Actor owner unavailable"
		return
	observed = owner.activity_projection(_scope,_actor,"","",_episode)
	if not observed.ok:
		_body.text = "Actor context retired"
		return
	var e: Dictionary = observed.episode
	_body.text = "Actor: %s\nFatigue: %d internal-64; health: %d; magicka: %d\nFatigue remainder: %d /60000000\nEpisode: %s\nPhase: %s\nCommitted game minutes: %s\nUnresolved transitions: %d\nRaw Medical: %d; Running: %d\nReason: %s\nReal MOVE / TIME / threat producers remain integration gates." % [_actor,observed.current.fatigue,observed.current.health,observed.current.magicka,observed.fatigue_remainder,_episode,e.get("phase","none"),str(float(e.get("elapsed",0))/60000000.0),observed.unresolved,observed.practice.medical,observed.practice.running,e.get("reason","none")]
