extends RefCounted
## Pure bounded catalog grammar. No expansion, callbacks, markup execution or RNG.
const VERSION := "text-token-v1"
const CLASSIC_PROFILE := "classic-controls-v1"
const CLASSIC_CONTROLS := {0:"line_break",246:"page_break",248:"input_cursor",249:"font",251:"position",252:"justify_left",253:"justify_center",254:"record_end",255:"variant_break"}

static func classic_failure(kind: String, source: String, record: int, position: int, offset: int, reason: String) -> Dictionary:
	return {"ok":false,"kind":kind,"source":source,"record":record,"position":position,"absolute_position":offset + position,"reason":reason,"codec":VERSION,"profile":CLASSIC_PROFILE}

static func encoding_failure(kind: String, source: String, record: int, token_position: int, reason: String) -> Dictionary:
	return {"ok":false,"kind":kind,"source":source,"record":record,"token_position":token_position,"reason":reason,"codec":VERSION,"profile":CLASSIC_PROFILE}

## Positions are record-relative byte offsets, plus the absolute file offset.
## Percent macros and braces in classic literal runs remain literal, never executed.
static func decode_classic(bytes: PackedByteArray, source: String, record: int, offset := 0) -> Dictionary:
	var tokens: Array = []
	var variants: Array = []
	var diagnostics: Array = []
	var current: Array = []
	var position := 0
	var meaningful := false
	var terminated := false
	while position < bytes.size():
		var start := position
		var code := int(bytes[position])
		var token := {"kind":"","position":start,"absolute_position":offset + start}
		if code >= 32 and code <= 126:
			while position < bytes.size() and bytes[position] >= 32 and bytes[position] <= 126:
				position += 1
			var text := bytes.slice(start,position).get_string_from_ascii()
			token.kind = "text"
			token.text = text
			meaningful = meaningful or not text.strip_edges().is_empty()
		else:
			if not CLASSIC_CONTROLS.has(code):
				return classic_failure("unsupported_required_control",source,record,start,offset,"Unsupported classic byte 0x%02x; no degradation policy." % code)
			token.kind = CLASSIC_CONTROLS[code]
			position += 1
			if code in [249,251]:
				if position >= bytes.size():
					return classic_failure("malformed_text",source,record,start,offset,"Missing unsigned byte control operand.")
				token.operand = int(bytes[position])
				position += 1
			if code == 248:
				meaningful = true
			if code in [254,255]:
				var id := variants.size()
				variants.append({"id":id,"usable":meaningful,"tokens":current.duplicate(true)})
				if not meaningful:
					diagnostics.append({"kind":"empty_variant","source":source,"record":record,"variant":id,"position":start,"absolute_position":offset + start})
				current = []
				meaningful = false
				if code == 254:
					if position != bytes.size():
						return classic_failure("malformed_text",source,record,position,offset,"Bytes after record termination.")
					terminated = true
		token.length = position - start
		tokens.append(token)
		if code not in [254,255]:
			current.append(token.duplicate(true))
	if not terminated:
		return classic_failure("malformed_text",source,record,position,offset,"Missing record terminator within indexed extent.")
	var usable: Array = variants.filter(func(v: Dictionary): return v.usable)
	if usable.is_empty():
		return classic_failure("empty_variants",source,record,0,offset,"No usable authored variants.")
	return {"ok":true,"codec":VERSION,"profile":CLASSIC_PROFILE,"source":source,"record":record,"offset":offset,"tokens":tokens,"variants":variants,"diagnostics":diagnostics}

static func select_classic(decoded: Dictionary, variant: int) -> Dictionary:
	if not decoded.get("ok",false):
		return decoded.duplicate(true)
	if variant < 0 or variant >= decoded.variants.size() or not decoded.variants[variant].usable:
		return {"ok":false,"kind":"variant_unavailable","source":decoded.source,"record":decoded.record,"variant":variant,"reason":"Requested authored variant unavailable; no selection or reroll performed."}
	return {"ok":true,"source":decoded.source,"record":decoded.record,"variant":variant,"tokens":decoded.variants[variant].tokens.duplicate(true)}

## Requester declares required presentation structure independently of wording.
## Record-end is implicit for catalog strings; all other controls stay distinct.
static func require_structure(tokens: Array, required: Array) -> Dictionary:
	var actual: Array = []
	for token: Dictionary in tokens:
		if token.kind in ["text","reference","record_end"]:
			continue
		var control := {"kind":token.kind}
		if token.has("operand"):
			control.operand = token.operand
		actual.append(control)
	if actual != required:
		return {"ok":false,"kind":"required_structure","position":0,"reason":"Required ordered controls/operands differ.","expected":required.duplicate(true),"actual":actual}
	return {"ok":true}

## Structural source codec only. Not editable translation markup/import.
static func encode_classic(tokens: Array, source: String, record: int) -> Dictionary:
	var bytes := PackedByteArray()
	for index in tokens.size():
		var token: Dictionary = tokens[index]
		var kind: String = token.get("kind","")
		var allowed := ["kind","position","absolute_position","length"]
		if kind == "text":
			allowed.append("text")
		elif kind in ["font","position"]:
			allowed.append("operand")
		for field: String in token:
			if not allowed.has(field):
				return encoding_failure("malformed_text",source,record,index,"Unsupported token field/operand: " + field)
		if kind == "text":
			if not token.get("text") is String or token.text.is_empty():
				return encoding_failure("malformed_text",source,record,index,"Nonempty literal run required.")
			for character: String in token.text:
				var code := character.unicode_at(0)
				if code < 32 or code > 126:
					return encoding_failure("malformed_text",source,record,index,"Classic source literals require printable ASCII; catalog Unicode is separate.")
				bytes.append(code)
		else:
			var code: Variant = CLASSIC_CONTROLS.find_key(kind)
			if code == null:
				return encoding_failure("unsupported_required_control",source,record,index,"Unsupported structured control.")
			bytes.append(code)
			if code in [249,251]:
				if not token.get("operand") is int or token.operand < 0 or token.operand > 255:
					return encoding_failure("malformed_text",source,record,index,"Unsigned byte operand required.")
				bytes.append(token.operand)
	var checked := decode_classic(bytes,source,record)
	if not checked.ok:
		return checked
	return {"ok":true,"bytes":bytes,"codec":VERSION,"profile":CLASSIC_PROFILE}

static func signature(value: String) -> bool:
	var parts := value.split(":")
	return parts.size() == 3 and identifier(parts[0]) and ((parts[1] == "string" and parts[2] == "plain") or (parts[1] == "int" and parts[2] == "d"))

static func identifier(value: String) -> bool:
	if value.is_empty() or value.length() > 128:
		return false
	for character in value:
		if not character in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.-":
			return false
	return true

static func parse(text: String, required: Array) -> Dictionary:
	var tokens: Array = []
	var found := {}
	var literal := ""
	var index := 0
	while index < text.length():
		var character := text[index]
		if character in ["{", "}"] and index + 1 < text.length() and text[index + 1] == character:
			literal += character
			index += 2
			continue
		if character == "{" or character == "\n":
			if not literal.is_empty():
				tokens.append({"kind":"text", "text":literal})
				literal = ""
			if character == "\n":
				tokens.append({"kind":"line_break"})
			else:
				var end := text.find("}", index + 1)
				var reference := text.substr(index + 1, end - index - 1) if end >= 0 else ""
				if not signature(reference) or not required.has(reference):
					return {"ok":false, "position":index, "reason":"Unknown, malformed or incompatible required reference."}
				found[reference] = true
				var parts := reference.split(":")
				tokens.append({"kind":"reference", "name":parts[0], "type":parts[1], "format":parts[2]})
				index = end
		elif character == "}" or (text.unicode_at(index) < 32 and character != "\t"):
			return {"ok":false, "position":index, "reason":"Unescaped brace or unsupported control."}
		else:
			literal += character
		index += 1
	if not literal.is_empty():
		tokens.append({"kind":"text", "text":literal})
	for reference: String in required:
		if not found.has(reference):
			return {"ok":false, "position":text.length(), "reason":"Missing required reference: " + reference}
	return {"ok":true, "tokens":tokens}
