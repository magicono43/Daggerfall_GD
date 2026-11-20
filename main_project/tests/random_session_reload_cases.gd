extends RefCounted
const Cases = preload("res://tests/random_session_cases.gd")
const Core = preload("res://scripts/session/session_lifecycle.gd")
const Owner = preload("res://tests/controlled_random_owner.gd")

func run(shell: Control, fixture: Dictionary) -> Dictionary:
	var test := Cases.new()
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(str(fixture.sandbox).path_join("retained-owner.json")))
	var factory := Cases.MaterialProvider.new()
	factory.queue = [test.material(255)]
	var core := Core.new(factory.supply)
	var owner := Owner.new()
	core.provider = owner
	core.startup_route_changed("main_menu")
	test.check("fresh process retains leased fixture storage",true,shell.controller.storage.context.root.begins_with(str(fixture.sandbox)+"/"))
	test.check("fresh process load succeeds","Succeeded",test.start(core,"load",{"retained_owner":saved}).kind)
	test.check("fresh process initializes exactly once",1,factory.calls.size())
	test.check("fresh process restores exact owner facts",saved,owner.retained_snapshot())
	test.check("fresh process sources start at zero",test.zero_counts(),test.active(core).sources)
	test.check("fresh process uses new explicit material",test.material(255).hex_encode(),test.active(core).material_hex)
	test.check("fresh process assigned identity retained","Assigned fixture name",owner.facts.assigned_name)
	var selected: Dictionary = core.randomness.source(core.snapshot().session,owner,"progression")
	test.check("fresh process source is bound",true,selected.ok)
	var before: Dictionary = test.active(core)
	test.check("restored pending result does not reroll",saved.rewards["saved-pending"].resolution,owner.prepare_reward("saved-pending",selected.source))
	test.check("restored pending reward can apply",true,owner.deliver_reward("saved-pending").ok)
	test.check("restored pending reward commits once",[saved.applications+1,saved.balance+saved.rewards["saved-pending"].resolution.roll],[owner.facts.applications,owner.facts.balance])
	owner.deliver_reward("saved-pending")
	test.check("restored redelivery cannot duplicate",[saved.applications+1,saved.balance+saved.rewards["saved-pending"].resolution.roll],[owner.facts.applications,owner.facts.balance])
	owner.deliver_reward("pending")
	test.check("already committed reward cannot replay",[saved.applications+1,saved.balance+saved.rewards["saved-pending"].resolution.roll],[owner.facts.applications,owner.facts.balance])
	owner.deliver_reward("ack-saved")
	test.check("restored postcommit acknowledgment is once-only",[saved.applications+1,saved.balance+saved.rewards["saved-pending"].resolution.roll,true],[owner.facts.applications,owner.facts.balance,owner.facts.rewards["ack-saved"].acknowledged])
	test.check("all restoration and retry draws stay zero",before,test.active(core))
	var result := test.result(fixture)
	result.fixture = "IMP-006-session-restore-v1"
	core.dispose()
	return result
