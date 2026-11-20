extends RefCounted
## UI layout in logical pixels, using the same Font/size/width as Label rendering.
## Semantic breaks/inputs survive; editorial wraps are metrics, never source edits.
const VERSION := "text-layout-v1"

static func measure(text: String, font: Font, size: int, width: float, direction := TextServer.DIRECTION_AUTO) -> Dictionary:
	var paragraph := TextParagraph.new()
	paragraph.direction = direction
	paragraph.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
	paragraph.width = maxf(width,1.0)
	paragraph.add_string(text,font,size)
	var lines: Array = []
	for index in paragraph.get_line_count():
		lines.append({"range":paragraph.get_line_range(index),"size":paragraph.get_line_size(index)})
	return {"width":width,"font_size":size,"height":paragraph.get_size().y,"size":paragraph.get_size(),"lines":lines,"natural_width":font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x}

static func structure(tokens: Array, presentation: RefCounted, locale: String, width: float, size := 18, classic_roles: Dictionary = {}) -> Dictionary:
	var blocks: Array = []
	var text := ""
	var role := "body"
	var alignment := HORIZONTAL_ALIGNMENT_LEFT
	for token: Dictionary in tokens:
		var kind: String = token.get("kind", "")
		if kind == "text":
			text += token.text
		elif kind == "line_break":
			text += "\n"
		elif kind in ["page_break","input_cursor","record_end","justify_left","justify_center","font"]:
			if not text.is_empty():
				var literal: Dictionary = presentation.literal(text,role,locale)
				blocks.append({"kind":"text","literal":literal,"metrics":measure(literal.text,literal.font,size,width),"alignment":alignment,"source_text":text,"role":role})
				text = ""
			if kind == "font":
				if not classic_roles.has(token.operand) or classic_roles[token.operand] not in ["body","title","small-ui"]:
					return {"ok":false,"kind":"unsupported_required_control","token":token.duplicate(true)}
				role = classic_roles[token.operand]
			elif kind in ["justify_left","justify_center"]:
				alignment = HORIZONTAL_ALIGNMENT_LEFT if kind == "justify_left" else HORIZONTAL_ALIGNMENT_CENTER
			else:
				blocks.append({"kind":kind})
		else:
			# Position, variants and unexpanded references require an explicit owner.
			return {"ok":false,"kind":"unsupported_required_control","token":token.duplicate(true)}
	if not text.is_empty():
		var literal: Dictionary = presentation.literal(text,role,locale)
		blocks.append({"kind":"text","literal":literal,"metrics":measure(literal.text,literal.font,size,width),"alignment":alignment,"source_text":text,"role":role})
	return {"ok":true,"blocks":blocks,"width":width,"locale":locale}

static func reading_position(verified_anchor: String, available_anchors: Array) -> Dictionary:
	if not verified_anchor.is_empty() and available_anchors.has(verified_anchor):
		return {"anchor":verified_anchor,"notice":""}
	return {"anchor":"","notice":"Layout changed; reopened at the beginning because no corresponding anchor was verified."}
