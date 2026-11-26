extends RefCounted
## Producer boundaries plus actual SessionShell view/player application.
func run(t: RefCounted) -> void:
	var definition: Dictionary = t.actors.definitions.query("move.feedback","policy","player").record.value
	var producer := preload("res://scripts/move/movement_feedback.gd").new()
	t.check("feedback validated producer binds",true,producer.bind("feedback-fixture",definition))
	var cues: Array = []
	var ranges: Array = []
	producer.cue.connect(func(value): cues.append(value))
	producer.noise_distance.connect(func(value): ranges.append(value))
	var m := {"session":"feedback-fixture","sequence":1,"placement_serial":1,"surface_distance":1.0,"gait":{"gait":"walk"}}
	producer.movement(m,"stone",true)
	t.near("feedback fractional stride",0.4,producer.phase,0.000001)
	m.sequence += 1
	m.surface_distance = 0.16
	m.gait.gait = "sneak"
	producer.movement(m,"snow",true)
	t.near("feedback gait seam retains fraction",0.5,producer.phase,0.000001)
	m.sequence += 1
	m.surface_distance = 0.8
	producer.movement(m,"shallow-water",true)
	t.check("feedback mapped seam one step",[1,334],[cues.size(),cues[0].ordinal])
	var count := cues.size()
	t.check("feedback repeated delivery rejects",false,producer.movement(m,"shallow-water",true).ok)
	t.check("feedback repeat never replays",count,cues.size())
	m.sequence += 1
	m.surface_distance = 100.0
	producer.movement(m,"ground",false)
	t.check("feedback passive-only no steps",count,cues.size())
	m.sequence += 1
	m.surface_distance = 16.0
	producer.movement(m,"swimming",true) # Controlled context only, no water owner.
	t.check("feedback bounded stall one cosmetic cue",count+1,cues.size())
	t.check("feedback stall retains every gameplay step",10,ranges[-1].steps)
	t.check("feedback stall marks omitted cosmetics",9,cues[-1].omitted_steps)
	var landed := {"session":"feedback-fixture","placement_serial":1,"id":"landing-test","phase":"committed","hard":true,"damage":0}
	t.check("feedback independent hard zero damage cue",true,producer.landing(landed) and cues[-1].ordinal == 92)
	count = cues.size()
	t.check("feedback landing duplicate idempotent",true,producer.landing(landed) and cues.size() == count)
	var changed := landed.duplicate(true)
	changed.damage = 10
	t.check("feedback changed outcome rejects",false,producer.landing(changed))
	m.sequence += 1
	m.surface_distance = 1.6
	m.landing = landed
	producer.movement(m,"stone",true)
	t.check("feedback same contact impact wins step",count,cues.size())
	producer.reset("feedback-fixture",2)
	t.check("feedback relocation resets phase",[0,0.0],[producer.steps,producer.phase])
	count = cues.size()
	t.check("feedback relocation rejects old landing",true,not producer.landing(landed) and cues.size() == count)
	t.check("feedback stale placement cannot roll baseline back",false,producer.movement(m,"stone",true).get("ok",true))
	producer.reset("feedback-fixture",2,100)
	m.placement_serial = 2
	m.sequence = 99
	t.check("feedback restore rejects old physical sequence",false,producer.movement(m,"stone",true).get("ok",true))
	var water := {"session":"feedback-fixture","actor":"player","id":"controlled-water-entry","contact":"water-contact-1","volume":"controlled-water","phase":"committed","solid_first":false,"sequence":101,"placement_serial":2}
	t.check("feedback controlled water entry cue",true,producer.water_entry(water) and cues[-1].ordinal == 342)
	count = cues.size()
	t.check("feedback water receipt deduplicates",true,producer.water_entry(water) and cues.size() == count)
	var water_landing := {"session":"feedback-fixture","placement_serial":2,"id":"water-landing","contact":"water-contact-1","phase":"committed","hard":true,"damage":10}
	t.check("feedback splash wins same contact impact only",true,producer.landing(water_landing) and cues.size() == count)
	m.sequence = 102
	m.erase("landing")
	m.contact = "water-contact-1"
	m.surface_distance = 1.6
	producer.movement(m,"stone",true)
	t.check("feedback splash suppresses duplicate contact step",count,cues.size())
	t.check("feedback cue priority retains complete noise range",1,ranges[-1].steps)
	var separate := water_landing.duplicate(true)
	separate.id = "separate-landing"
	separate.contact = "solid-contact-2"
	t.check("feedback separate legitimate impact retained",true,producer.landing(separate) and cues.size() == count+1 and cues[-1].ordinal == 91)
	var obstructed := water.duplicate(true)
	obstructed.id = "blocked-water"
	obstructed.contact = "solid-contact-2"
	obstructed.sequence = 103
	obstructed.solid_first = true
	t.check("feedback earlier solid rejects water cue",false,producer.water_entry(obstructed))
	obstructed.solid_first = false
	t.check("feedback committed solid cannot become late splash",false,producer.water_entry(obstructed))
	m.sequence = 103
	m.contact = "new-step-contact"
	producer.movement(m,"unmapped-mud",true)
	t.check("feedback optional unmapped category declares silence",-1,cues[-1].ordinal)
	t.check("feedback missing optional cue retains noise",1,ranges[-1].steps)
	var bad := definition.duplicate(true)
	bad.strides.run = true
	t.check("feedback boolean stride rejects",false,preload("res://scripts/data/movement_feedback_policy.gd").reason(bad).is_empty())
	bad = definition.duplicate(true)
	bad.surfaces["modded-mud"] = [309]
	t.check("feedback modded category validates",true,preload("res://scripts/data/movement_feedback_policy.gd").reason(bad).is_empty())
	for event: Signal in [producer.cue,producer.noise_distance]:
		for connection: Dictionary in event.get_connections(): event.disconnect(connection.callable)
