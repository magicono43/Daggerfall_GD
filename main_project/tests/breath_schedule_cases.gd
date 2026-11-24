extends RefCounted
const Breath = preload("res://scripts/char/breath_schedule.gd")
func run(suite: RefCounted) -> void:
	var p := {"mode":"gradual","rate":3,"delay_usec":200000,"unit":"simulated-microsecond"}
	var state := {"holding":false,"breathable":false,"delay":0,"remainder":0}
	var reserve := {"state":"owner-pending","reserve":10,"policy":p.duplicate(true)}
	var result := Breath.resolve(p,state,reserve,{"holding":true,"breathable":false},0,25)
	suite.check("breath gradual reentry preserves reserve",10,result.breath.reserve)
	result = Breath.resolve(p,result.state,result.breath,{"holding":false,"breathable":true},100000,25)
	suite.check("breath gradual delay retained",[10,100000],[result.breath.reserve,result.state.delay])
	result = Breath.resolve(p,result.state,result.breath,{"holding":false,"breathable":true},150000,25)
	suite.check("breath gradual fraction retained",[10,150000],[result.breath.reserve,result.state.remainder])
	var saved := result.duplicate(true)
	result = Breath.resolve(p,result.state,result.breath,{"holding":false,"breathable":true},850000,25)
	suite.check("breath gradual exact recovery",[12,700000],[result.breath.reserve,result.state.remainder])
	suite.check("breath restore schedules without refill",result,Breath.resolve(p,saved.state,saved.breath,{"holding":false,"breathable":true},850000,25))
	var toggled := Breath.resolve(p,saved.state,saved.breath,{"holding":true,"breathable":false},0,25)
	suite.check("breath toggle does not bypass delay",[10,200000],[toggled.breath.reserve,toggled.state.delay])
	suite.check("breath consumption explicitly unavailable",false,Breath.resolve(p,state,reserve,{"holding":true,"breathable":false},1,25).ok)
	suite.check("breath rejects boolean elapsed",false,Breath.resolve(p,state,reserve,{"holding":false,"breathable":true},true,25).ok)
