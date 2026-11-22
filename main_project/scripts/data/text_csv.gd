extends RefCounted
## Complete UTF-8 CSV reader; positions are one-based physical line/column.
const VERSION := "text-csv-v1"
const MAX_BYTES := 16777216
const MAX_ROWS := 100000
const MAX_FIELD := 262144

static func failure(reason: String, line: int, column: int) -> Dictionary:
	return {"ok":false, "kind":"invalid_csv", "reason":reason, "line":line, "column":column}

static func validate_encoding(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() > MAX_BYTES:
		return failure("CSV exceeds 16 MiB.", 1, 1)
	if bytes.size() >= 3 and bytes.slice(0,3) == PackedByteArray([239,187,191]):
		bytes = bytes.slice(3)
	# Validate before engine decoding, which otherwise logs/replaces malformed bytes.
	var cursor := 0
	while cursor < bytes.size():
		var first := int(bytes[cursor])
		var width := 1 if first < 128 else 2 if first >= 194 and first <= 223 else 3 if first >= 224 and first <= 239 else 4 if first >= 240 and first <= 244 else 0
		if first == 0 or width == 0 or cursor + width > bytes.size():
			return failure("Invalid UTF-8 or NUL at byte %d." % cursor, 1, 1)
		for offset in range(1,width):
			if bytes[cursor + offset] < 128 or bytes[cursor + offset] > 191:
				return failure("Invalid UTF-8 continuation at byte %d." % (cursor + offset), 1, 1)
		if (width == 3 and ((first == 224 and bytes[cursor + 1] < 160) or (first == 237 and bytes[cursor + 1] >= 160))) or (width == 4 and ((first == 240 and bytes[cursor + 1] < 144) or (first == 244 and bytes[cursor + 1] >= 144))):
			return failure("Invalid UTF-8 scalar at byte %d." % cursor, 1, 1)
		cursor += width
	return {"ok":true}

static func parse(bytes: PackedByteArray) -> Dictionary:
	var encoding := validate_encoding(bytes)
	if not encoding.ok: return encoding
	if bytes.size() >= 3 and bytes.slice(0,3) == PackedByteArray([239,187,191]):
		bytes = bytes.slice(3)
	var text := bytes.get_string_from_utf8()
	if text.to_utf8_buffer() != bytes:
		return failure("CSV must be complete UTF-8.", 1, 1)
	if text.begins_with(String.chr(0xfeff)):
		text = text.substr(1)
	var rows: Array = []
	var fields: Array = []
	var value := ""
	var state := "start"
	var line := 1
	var column := 1
	var row_line := 1
	var index := 0
	var pending := false
	while index < text.length():
		var character := text[index]
		var newline := character == "\n" or character == "\r"
		if character == "\r" and (index + 1 >= text.length() or text[index + 1] != "\n"):
			return failure("Bare CR is unsupported; use LF or CRLF.", line, column)
		if character.unicode_at(0) == 0:
			return failure("NUL is unsupported.", line, column)
		pending = true
		if state == "quoted":
			if character == '"':
				state = "closed"
			else:
				value += "\n" if newline else character
		elif state == "closed" and character == '"':
			value += '"'
			state = "quoted"
		elif character == "," or newline:
			fields.append(value)
			if fields.size() > 32:
				return failure("CSV column limit exceeded.", line, column)
			value = ""
			state = "start"
			if newline:
				rows.append({"fields":fields, "line":row_line})
				if rows.size() > MAX_ROWS:
					return failure("CSV row limit exceeded.", line, column)
				fields = []
				row_line = line + 1
				pending = false
		elif state == "closed":
			return failure("Only delimiter or newline may follow a quoted field.", line, column)
		elif character == '"':
			if state != "start":
				return failure("Quote inside an unquoted field.", line, column)
			state = "quoted"
		else:
			state = "unquoted"
			value += character
		if value.length() > MAX_FIELD or fields.size() > 32:
			return failure("CSV field/column limit exceeded.", line, column)
		if newline:
			if character == "\r":
				index += 1
			line += 1
			column = 1
		else:
			column += 1
		index += 1
	if state == "quoted":
		return failure("Unterminated quoted field.", line, column)
	if pending:
		fields.append(value)
		if fields.size() > 32:
			return failure("CSV column limit exceeded.", line, column)
		rows.append({"fields":fields, "line":row_line})
	if rows.is_empty() or rows.size() > MAX_ROWS:
		return failure("Empty CSV or row limit exceeded.", line, column)
	return {"ok":true, "rows":rows}
