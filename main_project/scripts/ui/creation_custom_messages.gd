extends RefCounted
## Select presentation for an owner-rejected completion; never grants readiness.
static func rejected_exit(view: RefCounted, failure: Dictionary) -> String:
	var evaluation: Dictionary = view.owner.projection().validated.get("custom",{}).get("provenance",{}).get("evaluation",{})
	var errors: Array = evaluation.get("errors",[])
	if failure.get("kind") != "incomplete" or errors.is_empty(): return str(failure.get("reason","Custom class could not be completed."))
	# DFU presents the first category in this order, independently of error order.
	if "Enter a nonblank custom-class name." in errors:
		return view.translated("prompt.custom-name-required","Name your character class before exiting.")
	if errors.any(func(error): return str(error).begins_with("Fill every ")):
		return view.translated("prompt.custom-skills-required","Three primary, three major, and six minor skills\nmust be selected before exiting.")
	if evaluation.get("attribute_remaining",0) != 0:
		return view.translated("prompt.custom-attributes-unbalanced","Attribute arrow must equal zero before exiting.")
	if "Difficulty is outside the legal range." in errors:
		return view.translated("prompt.custom-difficulty-invalid","The difficulty of advancing dagger cannot be\nin the red. Select more advantages to move it\nup, or more disadvantages to move it down.")
	if evaluation.get("reputation_remaining",0) != 0:
		return view.translated("prompt.reputation-balance","Reputation balance must equal zero before exiting.")
	return " ".join(errors)
