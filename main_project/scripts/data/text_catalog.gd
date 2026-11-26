extends RefCounted
## Production DATA schema and lookup projection; publication belongs to registry/CORE.
const Csv = preload("res://scripts/data/text_csv.gd")
const Tokens = preload("res://scripts/data/text_tokens.gd")
const Paths = preload("res://scripts/mod/package_library.gd")
const Author = preload("res://scripts/data/text_author.gd")
const SCHEMA := "text-catalog-v1"
const DOMAIN := "text.catalogs"
const HEADER := ["schema","codec","collection","locale","key","operation","base","optional","essential","placeholders","suppress","value"]
const RECOVERY := {"retry":"Retry", "quit":"Quit", "choose_folder":"Choose Folder", "continue":"Continue", "cancel":"Cancel", "return_setup":"Return to Setup", "standard_storage":"Use standard storage for this launch", "reset_settings":"Preserve original and reset to defaults", "save_continue":"Save and Continue", "run_continue":"Continue for This Run", "retry_save":"Retry saving preferences"}
var extra_bundled: Array[String] = [] # Trusted enabled consumers only, before registration.

func declaration() -> Dictionary:
	return {"id":"text.catalogs.v1", "domain":DOMAIN,"reference_domains":[DOMAIN], "operations":["add","replace"], "formats":[Csv.VERSION], "json_envelopes":false, "required_resources":["recovery"], "capabilities":["text-catalog-v1"]}

func bundled_contributions() -> Array:
	var result: Array = [{"file":"recovery.csv", "bytes":FileAccess.get_file_as_bytes("res://content/text/recovery.csv")}]
	for file: String in extra_bundled: result.append({"file":file,"bytes":FileAccess.get_file_as_bytes("res://content/text/"+file)})
	return result

func validate_record(_id: String, _value: Dictionary) -> String:
	return "Text catalogs require text-csv-v1, not a JSON envelope."

func patch_record(_previous: Dictionary, _fields: Dictionary) -> Dictionary:
	return {"ok":false, "reason":"Text catalogs support explicit locale add/replace only."}

func validate_references(resources: Dictionary) -> Array:
	var records: Dictionary = resources.get(DOMAIN + ":recovery", {}).get("records", {})
	var issues: Array = []
	for key: String in RECOVERY:
		if not records.has(key) or not records[key].value.essential or records[key].value.base != "en" or not records[key].value.entries.has("en"):
			issues.append({"source":"recovery/" + key, "reason":"Required bundled English recovery label is unavailable."})
	return issues

static func locale_id(value: String) -> bool:
	if value.is_empty() or value.length() > 64 or not value[0] in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ":
		return false
	for character in value:
		if not character in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-":
			return false
	return true

## Recovery buttons are literal label consumers, not general structured renderers.
## Unsupported required controls recover the complete independent English label.
static func essential_literal(resolved: Dictionary, key: String) -> String:
	var text := ""
	for token: Dictionary in resolved.get("tokens", []):
		if token.kind == "text":
			text += token.text
		elif token.kind == "line_break":
			text += "\n"
		elif token.kind != "record_end":
			return RECOVERY.get(key, "<Missing essential label>")
	return text if not text.strip_edges().is_empty() else RECOVERY.get(key, "<Missing essential label>")

func reject(reason: String, source: Dictionary, row: int, line: int) -> Dictionary:
	return {"ok":false,"kind":"invalid_catalog","source":source.duplicate(true),"row":row,"line":line,"reason":"Row %d (line %d): %s" % [row,line,reason]}

func apply_csv(base: Dictionary, bytes: PackedByteArray, source: Dictionary) -> Dictionary:
	var parsed := Csv.parse(bytes)
	if not parsed.ok:
		parsed.reason = "Line %d column %d: %s" % [parsed.line,parsed.column,parsed.reason]
		return parsed
	if parsed.rows[0].fields != HEADER or parsed.rows.size() < 2:
		return reject("Exact versioned header and at least one data row required.",source,1,1)
	var working := base.duplicate(true)
	var seen := {}
	for index in range(1,parsed.rows.size()):
		var row: Dictionary = parsed.rows[index]
		if row.fields.size() != HEADER.size():
			return reject("Wrong column count.",source,index + 1,row.line)
		var entry := {}
		for column in HEADER.size():
			entry[HEADER[column]] = row.fields[column]
		if entry.schema != SCHEMA or entry.codec not in [Tokens.VERSION, Author.VERSION] or not Paths.valid_id(entry.collection) or not Tokens.identifier(entry.key) or not locale_id(entry.locale) or not locale_id(entry.base) or entry.operation not in ["add","replace"] or entry.optional not in ["true","false"] or entry.essential not in ["true","false"] or entry.suppress not in ["true","false"]:
			return reject("Unsupported schema/codec, identity, boolean or operation.",source,index + 1,row.line)
		var target: String = entry.collection + "/" + entry.locale + "/" + entry.key
		if seen.has(target):
			return reject("Duplicate complete target: " + target,source,index + 1,row.line)
		seen[target] = true
		var required: Array = []
		if not entry.placeholders.is_empty():
			for reference: String in entry.placeholders.split("|"):
				if not Tokens.signature(reference) or required.has(reference):
					return reject("Invalid or duplicate placeholder declaration.",source,index + 1,row.line)
				required.append(reference)
		required.sort()
		var optional: bool = entry.optional == "true"
		var essential: bool = entry.essential == "true"
		var suppression: bool = entry.suppress == "true"
		if (optional and essential) or (suppression and (not optional or essential or not entry.value.is_empty())):
			return reject("Suppression requires optional nonessential empty text.",source,index + 1,row.line)
		var resource_key: String = DOMAIN + ":" + entry.collection
		var resource: Dictionary = working.get(resource_key,{"domain":DOMAIN,"path":entry.collection,"records":{},"contributors":[],"winner":{}})
		var prior: Dictionary = resource.records.get(entry.key,{})
		var exists: bool = prior.get("value",{}).get("entries",{}).has(entry.locale)
		if (entry.operation == "add" and exists) or (entry.operation == "replace" and not exists):
			return reject("Add-existing or replace-missing locale target: " + target,source,index + 1,row.line)
		var provenance := source.duplicate(true)
		provenance.merge({"row":index + 1,"line":row.line,"collection":entry.collection,"locale":entry.locale,"key":entry.key})
		if prior.is_empty():
			prior = {"identity":{"domain":DOMAIN,"collection":entry.collection,"key":entry.key,"package":source.provider,"local":entry.collection + "#" + entry.key,"record":entry.key},"origin":provenance.duplicate(true),"contributors":[],"winner":{},"value":{"base":entry.base,"optional":optional,"essential":essential,"required":required,"entries":{}}}
		elif prior.value.base != entry.base or prior.value.optional != optional or prior.value.essential != essential or prior.value.required != required:
			return reject("Original key base/requirements/classification are immutable.",source,index + 1,row.line)
		var syntax: Dictionary = Author.decode(entry.value,required,JSON.stringify(source),entry.key) if entry.codec == Author.VERSION else Tokens.parse(entry.value,required)
		var usable: bool = suppression or (not entry.value.strip_edges().is_empty() and syntax.ok)
		var diagnosis: String = "" if usable else "Blank entry." if entry.value.strip_edges().is_empty() else syntax.reason
		var contributions: Array = prior.value.entries.get(entry.locale,{}).get("contributors",[]).duplicate(true)
		contributions.append(provenance)
		prior.value.entries[entry.locale] = {"text":entry.value,"suppressed":suppression,"usable":usable,"diagnostic":diagnosis,"position":syntax.get("position",-1),"tokens":syntax.get("tokens",[]),"variant_ids":syntax.get("variant_ids",[]),"winner":provenance,"contributors":contributions}
		prior.contributors.append(provenance)
		prior.winner = provenance
		resource.records[entry.key] = prior
		resource.contributors.append(provenance)
		resource.winner = provenance
		working[resource_key] = resource
	return {"ok":true,"resources":working}

static func lookup(registry: RefCounted, collection: String, key: String, selected := "en", fallback := "", required_controls: Variant = null) -> Dictionary:
	var query: Dictionary = registry.query(DOMAIN,collection,key) if registry != null else {"ok":false,"kind":"before_readiness","source":"bundled recovery"}
	var context := {"collection":collection,"key":key,"locale":selected,"source":{},"attempts":[],"diagnostics":[]}
	var required: Array = []
	if query.ok:
		var record: Dictionary = query.record
		context.identity = record.identity
		context.origin = record.origin
		context.source = record.winner
		context.contributors = record.contributors.duplicate(true)
		required = record.value.required
		for locale: String in [selected,record.value.base]:
			if context.attempts.has(locale):
				continue
			context.attempts.append(locale)
			var entry: Dictionary = record.value.entries.get(locale,{})
			if entry.get("usable",false) and required_controls is Array and not Tokens.require_structure(entry.tokens,required_controls).ok:
				context.diagnostics.append({"locale":locale,"source":entry.winner,"reason":"Required ordered structure is absent or incompatible.","position":0,"kind":"required_structure"})
				continue
			if entry.get("usable",false):
				context.merge({"kind":"suppressed" if entry.suppressed else "selected" if locale == selected else "base","text":entry.text,"tokens":entry.tokens.duplicate(true),"variant_ids":entry.get("variant_ids", []).duplicate(true),"winner":entry.winner.duplicate(true),"entry_contributors":entry.contributors.duplicate(true),"resolved_locale":locale,"ok":true})
				return context
			context.diagnostics.append({"locale":locale,"source":entry.get("winner",{}),"reason":entry.get("diagnostic","Locale entry missing."),"position":entry.get("position",-1)})
	else:
		context.diagnostics.append(query.duplicate(true))
	if not fallback.strip_edges().is_empty():
		var syntax := Tokens.parse(fallback,required)
		if syntax.ok and (not required_controls is Array or Tokens.require_structure(syntax.tokens,required_controls).ok):
			context.merge({"ok":true,"kind":"source","text":fallback,"tokens":syntax.tokens})
			return context
		context.diagnostics.append(Tokens.require_structure(syntax.tokens,required_controls) if syntax.ok and required_controls is Array else syntax)
	if collection == "recovery" and RECOVERY.has(key):
		context.merge({"ok":true,"kind":"essential_fallback","text":RECOVERY[key],"tokens":[{"kind":"text","text":RECOVERY[key]}]})
	else:
		context.merge({"ok":false,"kind":"missing","text":"<Missing text %s/%s locale=%s source=%s>" % [collection,key,selected,JSON.stringify(context.source)],"tokens":[]})
	return context
