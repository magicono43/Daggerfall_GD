extends RefCounted
## Pure bounded catalog grammar. No expansion, callbacks, markup execution or RNG.
const VERSION := "text-token-v1"

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
