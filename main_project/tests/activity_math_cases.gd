extends RefCounted
## Independent numerical expectations; this does not qualify activity intake.
const Math = preload("res://scripts/char/activity_math.gd")
const Policy = preload("res://scripts/data/activity_policy.gd")

func run(suite: RefCounted, registry: RefCounted) -> void:
	var found: Dictionary = registry.query("actor.baseline","activity","player")
	suite.check("activity policy published",true,found.ok)
	if not found.ok: return
	var p: Dictionary = found.record.value
	suite.check("activity loose policy wins",["@loose",20000],[found.record.winner.provider,int(p.practice_cap)])
	suite.check("activity MOD provenance",true,found.record.contributors.any(func(item): return item.provider == "actor.formula"))
	suite.check("activity shipped provenance",true,found.record.contributors.any(func(item): return item.provider == "@shipped/actor-baseline-v1"))
	suite.check("activity policy valid","",Policy.validate(p))
	var c := {"climbing":false,"running":false,"voluntary_motion":false,"passive_motion":false,"swimming":false,"riding":false,"athleticism":false,"improved_athleticism":false}
	var vectors := {"ordinary":[11,9,8],"climbing":[22,19,17],"running":[88,79,70],"swimming-failure":[44,39,35]}
	for name: String in vectors:
		for index in 3:
			var ctx := c.duplicate()
			ctx.athleticism = index > 0
			ctx.improved_athleticism = index == 2
			suite.check("activity rate "+name+" "+str(index),vectors[name][index],Math.adjusted(p.rates[name],ctx,p))
	c.improved_athleticism = true
	suite.check("activity Improved alone",11,Math.adjusted(11,c,p))
	c.running = true
	c.passive_motion = true
	var result := Math.segment(p,c,60000000,1000000,0,0,false)
	suite.check("activity passive held Run",["ordinary",11,0],[result.selected,result.drain,result.running_requested])
	c.voluntary_motion = true
	result = Math.segment(p,c,60000000,1000000,0,0,false)
	suite.check("activity mixed voluntary Run",["running",88,4],[result.selected,result.drain,result.running_requested])
	c.riding = true
	result = Math.segment(p,c,60000000,1000000,0,0,false)
	suite.check("activity riding excludes practice",0,result.running_requested)
	c.riding = false
	c.climbing = true
	c.swimming = true
	suite.check("activity priority climbing","climbing",Math.segment(p,c,0,0,0,0,true).selected)
	c.climbing = false
	suite.check("activity priority moving Run","running",Math.segment(p,c,0,0,0,0,true).selected)
	c.running = false
	suite.check("activity selected failed Swimming",44,Math.segment(p,c,60000000,0,0,0,true).drain)
	c.swimming = false
	c.running = true
	var debt := 0
	var cadence := 0
	var drain := 0
	var practice := 0
	for index in 7:
		result = Math.segment(p,c,8571428 if index < 6 else 8571432,142857 if index < 6 else 142858,debt,cadence,false)
		debt = result.fatigue_remainder
		cadence = result.running_remainder
		drain += result.drain
		practice += result.running_requested
	suite.check("activity partition invariance",[88,0,4,0],[drain,debt,practice,cadence])
	result = Math.segment(p,c,1,1,0,0,false)
	c.running = false
	result = Math.segment(p,c,59999999,0,result.fatigue_remainder,result.running_remainder,false)
	suite.check("activity changed-rate debt retained",[11,77,1],[result.drain,result.fatigue_remainder,result.running_remainder])
	for invalid in [true,1.0,-1,1000000001,INF]:
		suite.check("activity rejects duration "+str(invalid),false,Math.segment(p,c,invalid,0,0,0,false).ok)
	for field: String in p:
		var malformed := p.duplicate(true)
		malformed.erase(field)
		suite.check("activity rejects missing policy "+field,false,Policy.validate(malformed).is_empty())
	var malformed := p.duplicate(true)
	malformed.priority = ["running","running","swimming","ordinary"]
	suite.check("activity rejects duplicate priority",false,Policy.validate(malformed).is_empty())
	malformed = p.duplicate(true)
	malformed.rates.ordinary = true
	suite.check("activity rejects boolean rate",false,Policy.validate(malformed).is_empty())
	suite.check("activity raw practice saturation",{"ok":true,"before":19999,"requested":8,"applied":1,"after":20000,"remainder":7},Math.practice(19999,8,20000))
	suite.check("activity lowered cap preserves practice",20000,Math.practice(20000,1,100).after)
	suite.check("activity rejects boolean practice",false,Math.practice(true,1,20000).ok)
	var modded := p.duplicate(true)
	modded.practice_amounts.running = 3
	c.running = true
	c.voluntary_motion = true
	suite.check("activity moddable raw practice amount",12,Math.segment(modded,c,0,1000000,0,0,false).running_requested)
