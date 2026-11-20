extends RefCounted
## Bounded schema only. No IMP-007–010 production domain schema is invented.
var limited := false

func declaration() -> Dictionary:
	return {"id": "fixture-limited" if limited else "fixture-records", "domain": "fixture.limited" if limited else "fixture.records",
		"operations": ["add"] if limited else ["replace", "add", "patch"], "required_resources": [] if limited else ["items/main.json"],
		"capabilities": ["data.fixture.limited"] if limited else ["data.fixture"],
		"classic_sources": [] if limited else [{"file": "ARCH3D.BSA", "format": "bsa-v1"}]}

func validate_record(_id: String, value: Dictionary) -> String:
	for key: String in value:
		if key not in ["label", "power", "tags", "nested", "nullable", "ref"]:
			return "Unknown fixture field: " + key
	if not value.get("label") is String or typeof(value.get("power")) not in [TYPE_INT, TYPE_FLOAT] or not value.get("tags") is Array:
		return "Fixture record requires label string, numeric power and tags array."
	for tag in value.tags:
		if not tag is String:
			return "Fixture tags must be strings."
	if value.has("nested") and (not value.nested is Dictionary or value.nested.keys() != ["x"] or typeof(value.nested.get("x")) not in [TYPE_INT, TYPE_FLOAT]):
		return "Nested values replace whole objects and require exactly numeric x."
	for field: String in ["nullable", "ref"]:
		if value.has(field) and value[field] != null and not value[field] is String:
			return "Only nullable/ref accept null or strings."
	return ""

func patch_record(previous: Dictionary, fields: Dictionary) -> Dictionary:
	var value := previous.duplicate(true)
	for field: String in fields:
		value[field] = fields[field] # Explicit top-level replacement, no deep/list merge.
	return {"ok": true, "value": value}

func validate_references(resources: Dictionary) -> Array:
	var issues: Array = []
	var main: Dictionary = resources.get("fixture.records:items/main.json", {}).get("records", {})
	for key: String in resources:
		if not key.begins_with(str(declaration().domain) + ":"):
			continue
		for id: String in resources[key].records:
			var value: Dictionary = resources[key].records[id].value
			if value.get("ref") != null and not main.has(value.ref):
				var winner: Dictionary = resources[key].records[id].fields.get("ref", {})
				issues.append({"source": key + "/" + id, "reason": "Required fixture reference cannot resolve: " + str(value.ref),
					"token": winner.get("token", ""), "omittable": not str(winner.get("provider", "@shipped/")).begins_with("@shipped/")})
	return issues
