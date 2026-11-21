extends RefCounted
## Editable array grammar, deliberately separate from the frozen brace grammar.
const VERSION := "text-author-v1"
const Tokens = preload("res://scripts/data/text_tokens.gd")
const CONTROLS := ["line_break", "page_break", "input_cursor", "justify_left", "justify_center", "record_end", "variant_break"]
const MAX_CHARS := 1048576

static func failure(reason: String, source: String, key: String, position: int) -> Dictionary:
	return {"ok":false,"kind":"invalid_author_text","reason":reason,"source":source,"key":key,"token_position":position,"codec":VERSION}

## Array form avoids duplicate object keys. JSON whitespace is editorial only;
## displayed spaces/newlines exist exclusively inside escaped literal strings.
static func encode(tokens: Array, variant_ids: Array, required: Array = [], source := "", key := "") -> Dictionary:
	var rows: Array = [VERSION, variant_ids.duplicate(true)]
	for token: Dictionary in tokens:
		var kind: String = token.get("kind", "")
		var allowed := ["kind", "position", "absolute_position", "length"]
		if kind == "text": allowed.append("text")
		elif kind in ["font", "position"]: allowed.append("operand")
		elif kind == "reference": allowed.append_array(["name", "type", "format"])
		for field: String in token:
			if not allowed.has(field):
				return failure("Unsupported required token field: " + field, source, key, rows.size() - 2)
		var row: Array = [kind]
		if kind == "text":
			row.append(token.get("text"))
		elif kind in ["font", "position"]:
			row.append(token.get("operand"))
		elif kind == "reference":
			row.append("%s:%s:%s" % [token.get("name", ""), token.get("type", ""), token.get("format", "")])
		elif kind not in CONTROLS:
			return failure("Unsupported required control: " + kind, source, key, rows.size() - 2)
		var position: Array = []
		for field: String in ["position", "absolute_position", "length"]:
			position.append(token.get(field, -1))
		row.append(position)
		rows.append(row)
	var text := JSON.stringify(rows, "\t", false)
	var checked := decode(text, required, source, key)
	if checked.ok:
		checked.text = text
	return checked

static func decode(text: String, required: Array = [], source := "", key := "") -> Dictionary:
	if text.length() > MAX_CHARS:
		return failure("Author text exceeds 1 Mi characters.", source, key, 0)
	var parser := JSON.new()
	# The parser returns diagnostics as data; never call parse_string on untrusted text.
	if parser.parse(text) != OK or not parser.data is Array:
		return failure("Expected escaped JSON array grammar: " + parser.get_error_message(), source, key, 0)
	var rows: Array = parser.data
	if rows.size() < 3 or rows[0] != VERSION or not rows[1] is Array:
		return failure("Version and explicit authored variant IDs required.", source, key, 0)
	var ids: Array = rows[1]
	var seen_ids: Array = []
	for id in ids:
		if (not id is String and not id is float and not id is int) or (id is String and not Tokens.identifier(id)) or ((id is float or id is int) and (id != int(id) or id < 0)) or seen_ids.has(id):
			return failure("Invalid or duplicate explicit variant identity.", source, key, 0)
		seen_ids.append(id)
	var tokens: Array = []
	var found: Array = []
	var endings := 0
	for index in range(2, rows.size()):
		var row: Variant = rows[index]
		if not row is Array or row.size() < 2 or not row[0] is String or not row[-1] is Array or row[-1].size() != 3:
			return failure("Token needs kind, typed value where applicable and three source coordinates.", source, key, index - 2)
		var kind: String = row[0]
		var valued: bool = kind in ["text", "font", "position", "reference"]
		if row.size() != (3 if valued else 2) or (not valued and kind not in CONTROLS):
			return failure("Unsupported required control or token arity: " + kind, source, key, index - 2)
		var token := {"kind":kind}
		for coordinate in range(3):
			var number: Variant = row[-1][coordinate]
			if (not number is int and not number is float) or number != int(number) or number < -1 or number > 2147483647:
				return failure("Invalid source coordinate.", source, key, index - 2)
			token[["position", "absolute_position", "length"][coordinate]] = int(number)
		if kind == "text":
			if not row[1] is String or row[1].is_empty():
				return failure("Nonempty literal string without NUL required.", source, key, index - 2)
			for character: String in row[1]:
				if character.unicode_at(0) == 0:
					return failure("NUL literal is unsupported.", source, key, index - 2)
			token.text = row[1]
		elif kind in ["font", "position"]:
			if (not row[1] is int and not row[1] is float) or row[1] != int(row[1]) or row[1] < 0 or row[1] > 255:
				return failure("Unsigned byte operand required.", source, key, index - 2)
			token.operand = int(row[1])
		elif kind == "reference":
			if not row[1] is String or not Tokens.signature(row[1]) or not required.has(row[1]):
				return failure("Undeclared or incompatible sample reference.", source, key, index - 2)
			var parts: PackedStringArray = row[1].split(":")
			token.merge({"name":parts[0],"type":parts[1],"format":parts[2]})
			found.append(row[1])
		if kind in ["variant_break", "record_end"]:
			endings += 1
		if kind == "record_end" and index != rows.size() - 1:
			return failure("Record end must be final.", source, key, index - 2)
		tokens.append(token)
	if endings != ids.size() or tokens[-1].kind != "record_end":
		return failure("Every explicit variant must end at a retained variant/record boundary.", source, key, tokens.size())
	for signature in required:
		if not signature is String or not Tokens.signature(signature) or not found.has(signature):
			return failure("Missing required typed reference: " + str(signature), source, key, tokens.size())
	return {"ok":true,"codec":VERSION,"tokens":tokens,"variant_ids":ids.duplicate(true)}

## Explicit sample values only. Inserted braces/percent/markup remain one literal
## run; no recursive parsing, providers, selection or runtime macro registry.
static func sample(decoded: Dictionary, context: Dictionary) -> Dictionary:
	if not decoded.get("ok", false):
		return decoded.duplicate(true)
	var result: Array = []
	for token: Dictionary in decoded.tokens:
		if token.kind != "reference":
			result.append(token.duplicate(true))
			continue
		var candidate: Variant = context.get(token.name)
		# Godot JSON numbers are doubles. Admit only exact, safely representable
		# integral JSON values for a declared integer sample, never arbitrary floats.
		if token.type == "int" and candidate is float and is_finite(candidate) and abs(candidate) <= 9007199254740991.0 and candidate == floor(candidate):
			candidate = int(candidate)
		if not context.has(token.name) or (token.type == "string" and not candidate is String) or (token.type == "int" and not candidate is int):
			return failure("Missing or incorrectly typed explicit sample context.", "sample", token.name, result.size())
		result.append({"kind":"text","text":str(candidate)})
	return {"ok":true,"tokens":result,"variant_ids":decoded.variant_ids.duplicate(true)}
