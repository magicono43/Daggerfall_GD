extends RefCounted
## Source structures only: no FACT state, QUEST grammar, RNG or executable providers.
const Common = preload("res://scripts/data/actor_input_formats.gd")
const Csv = preload("res://scripts/data/text_csv.gd")
const VERSION = "faction-quest-sources-v1"
const NUMBERS = ["type","rep","summon","region","power","flags","ruler","face","race","sgroup","ggroup","minf","maxf","vam","rank"]
const TABLE_SCHEMAS = ["id,*name","*name,p1,p2","*name,p1,p2,p3"]
const LIST_SCHEMA = "*name,group,membership,minReq,flag,notes"

static func fail(kind: String, reason: String, source := "", line := 0, record := "", target: Variant = "") -> Dictionary:
	return {"ok":false,"kind":kind,"reason":reason,"source":source,"line":line,"record":record,"referring":record,"target":target,"schema":VERSION}

static func decode(kind: String, bytes: PackedByteArray, source := "") -> Dictionary:
	if kind not in ["factions","quest","list","table"]: return fail("unsupported","Unknown source format.",source)
	if bytes.size() > 16777216: return fail("malformed","Source exceeds 16 MiB.",source)
	if not Csv.validate_encoding(bytes).ok: return fail("malformed","Source must be complete UTF-8 without NUL.",source)
	# Godot consumes a leading UTF-8 BOM during decoding. Restore it explicitly
	# in the stored text so the retained source is byte-exact.
	var has_bom := bytes.size() >= 3 and bytes.slice(0,3) == PackedByteArray([239,187,191])
	var payload := bytes.slice(3) if has_bom else bytes
	var text := payload.get_string_from_utf8()
	if has_bom: text = String.chr(0xfeff)+text
	if text.to_utf8_buffer() != bytes: return fail("malformed","Source must be complete UTF-8 without NUL.",source)
	if text.strip_edges().is_empty(): return fail("empty","Required source contains no content.",source)
	# Preserve exact text, including BOM and line endings; parsing uses a separate view.
	var view := text.trim_prefix(String.chr(0xfeff)).replace("\r\n","\n").replace("\r","\n")
	if view.strip_edges().is_empty(): return fail("empty","Required source contains no content after encoding marker.",source)
	var result: Dictionary
	if kind == "factions": result = factions(view,source)
	elif kind == "quest": result = {"ok":true,"data":{"text":text,"line_count":view.split("\n").size()}}
	else: result = table(view,kind == "list",source)
	if result.ok:
		result.text = text
		result.sha256 = Common.sha256(bytes)
	return result

static func integer_token(text: String) -> Dictionary:
	if text.is_valid_int() and Common.integer(int(text),-2147483648,2147483647): return {"ok":true,"value":int(text)}
	if text.begins_with("0x") and text.substr(2).is_valid_hex_number(false) and text.length() <= 10: return {"ok":true,"value":text.hex_to_int()}
	return {"ok":false}

static func factions(text: String, source: String) -> Dictionary:
	var records := {}
	var ancestry: Array[String] = []
	var current := ""
	var line_number := 0
	for raw: String in text.split("\n"):
		line_number += 1
		var line := raw.strip_edges()
		if line.is_empty() or line.begins_with(";"): continue
		if line.begins_with("#"):
			var token := line.substr(1)
			if not token.is_valid_int() or int(token) <= 0 or int(token) > 2147483647: return fail("malformed","Invalid positive faction ID.",source,line_number,token)
			current = str(int(token))
			if records.has(current): return fail("ambiguous","Duplicate faction ID.",source,line_number,current)
			var depth := 0
			while depth < raw.length() and raw[depth] == "\t": depth += 1
			if depth > ancestry.size(): return fail("malformed","Skipped hierarchy depth.",source,line_number,current)
			ancestry.resize(depth)
			var parent: String = ancestry.back() if depth > 0 else ""
			records[current] = {"legacy_id":int(current),"parent":parent,"fields":{},"allies":[],"enemies":[],"flats":[],"line":line_number,"field_lines":{},"authored_fields":[]}
			ancestry.append(current)
			continue
		if current.is_empty() or not line.contains(":"): return fail("malformed","Expected faction header or tagged field.",source,line_number,current)
		var tag := line.get_slice(":",0).strip_edges().to_lower()
		var value := line.substr(line.find(":")+1).strip_edges()
		var record: Dictionary = records[current]
		record.authored_fields.append({"tag":tag,"value":value,"line":line_number,"raw":raw})
		if tag not in NUMBERS + ["name","ally","enemy","flat"]: return fail("unsupported","Unknown required faction field: "+tag,source,line_number,current)
		if tag in ["ally","enemy"]:
			var number := integer_token(value)
			if not number.ok or number.value < 0: return fail("malformed","Invalid faction target.",source,line_number,current,value)
			record["allies" if tag == "ally" else "enemies"].append(number.value)
		elif tag == "flat":
			var parts := value.replace("\t"," ").split(" ",false)
			if parts.size() == 1 and value == "-1": record.flats.append([-1])
			elif parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int() and Common.integer(int(parts[0]),0,16777215) and Common.integer(int(parts[1]),0,127): record.flats.append([int(parts[0]),int(parts[1])])
			else: return fail("malformed","Expected -1 or archive/record flat reference.",source,line_number,current,value)
		else:
			if record.fields.has(tag) and tag != "flags": return fail("malformed","Duplicate singleton faction field: "+tag,source,line_number,current)
			if tag == "name":
				if value.is_empty(): return fail("empty","Faction name is empty.",source,line_number,current)
				record.fields[tag] = value
			else:
				var number := integer_token(value)
				if not number.ok: return fail("malformed","Expected signed i32 faction field: "+tag,source,line_number,current)
				record.fields[tag] = int(record.fields.get(tag,0)) | int(number.value) if tag == "flags" else number.value
		if not record.field_lines.has(tag): record.field_lines[tag] = []
		record.field_lines[tag].append(line_number)
	if records.is_empty(): return fail("empty","No faction records.",source)
	for id: String in records:
		if not records[id].fields.has("name") or not records[id].fields.has("type"): return fail("malformed","Faction requires name/type.",source,records[id].line,id)
	return {"ok":true,"records":records}

static func table(text: String, is_list: bool, source: String) -> Dictionary:
	var columns: Array = []
	var primary := -1
	var rows: Array = []
	var index := {}
	var line_number := 0
	for raw: String in text.split("\n"):
		line_number += 1
		var line := raw.strip_edges()
		if line.is_empty() or line.begins_with("-"): continue
		line = line.split("--",true,1)[0].strip_edges()
		if line.begins_with("schema:"):
			if not columns.is_empty(): return fail("malformed","Repeated schema.",source,line_number)
			var tokens: Array = Array(line.substr(7).split(","))
			for i in tokens.size(): tokens[i] = str(tokens[i]).strip_edges()
			var schema := ",".join(tokens)
			if (is_list and schema != LIST_SCHEMA) or (not is_list and schema not in TABLE_SCHEMAS): return fail("unsupported","Unsupported table schema: "+schema,source,line_number)
			for i in tokens.size():
				if tokens[i].begins_with("*"): primary = i
				columns.append(tokens[i].trim_prefix("*"))
			continue
		if columns.is_empty(): return fail("malformed","Data precedes schema.",source,line_number)
		var cells := line.split(",")
		if cells.size() != columns.size(): return fail("malformed","Truncated/trailing table cells.",source,line_number)
		var values := {}
		for i in cells.size():
			var token := cells[i].strip_edges()
			if columns[i] in ["id","p1","p2","p3","minReq"]:
				var number := integer_token(token)
				if not number.ok: return fail("malformed","Expected i32/hex table parameter.",source,line_number,token,columns[i])
				values[columns[i]] = number.value
			else: values[columns[i]] = token
		var key: String = str(values[columns[primary]])
		if key.is_empty(): return fail("empty","Empty primary key.",source,line_number)
		if index.has(key): return fail("ambiguous","Duplicate primary key; duplicate quest entries cannot weight selection.",source,line_number,key)
		if is_list and (values.group.is_empty() or values.membership.length() != 1 or values.flag not in ["0","1","X"]): return fail("malformed","Invalid list metadata.",source,line_number,key)
		index[key] = rows.size()
		rows.append({"key":key,"values":values,"line":line_number})
	if columns.is_empty(): return fail("malformed","Required schema missing.",source)
	# Explicit schema with no rows is a valid empty selection/table, unlike empty bytes.
	return {"ok":true,"data":{"columns":columns,"primary":columns[primary],"rows":rows,"index":index,"empty":rows.is_empty()}}
