extends RefCounted
const D = preload("res://scripts/data/actor_input_formats.gd")
static func validate(v: Variant) -> String:
	if not v is Dictionary or v.size() != 8 or v.get("schema") != "vitals-view-v1" or v.get("view") not in ["stock-bars","numbers"] or v.get("anchor") not in ["left","right"] or not D.integer(v.get("capacity"),1,32) or not D.integer(v.get("width"),220,600): return "Complete supported vitals view required."
	if not v.get("order") is Array or v.order.size() != 4 or not v.get("targets") is Dictionary or v.targets.size() != 4 or typeof(v.get("effects_visible")) != TYPE_BOOL: return "Complete named view targets required."
	var seen := {}
	for id: Variant in v.order:
		if not id is String or id not in ["health","fatigue","magicka","breath"] or seen.has(id): return "Each vital target must occur once."
		seen[id] = true
		var target: Variant = v.targets.get(id)
		if not target is Dictionary or target.size() != 5 or not target.get("label") is String or target.label.is_empty() or target.label.length() > 64 or typeof(target.get("visible")) != TYPE_BOOL or target.get("format") not in ["bar","numbers"] or not D.integer(target.get("height"),8,64) or not target.get("color") is Array or target.color.size() != 4: return "Invalid named target label/visibility/format/geometry/color."
		for value: Variant in target.color:
			if typeof(value) not in [TYPE_FLOAT,TYPE_INT] or not is_finite(float(value)) or value < 0 or value > 1: return "Finite target RGBA components in 0..1 required."
	return ""
