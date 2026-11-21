extends RefCounted
## Application presentation owner; synchronous staging and commit expose matching
## text/fonts/layout in one event-loop turn. No gameplay callback belongs here.
signal changed
const Fonts = preload("res://scripts/data/locale_fonts.gd")
const Catalog = preload("res://scripts/data/text_catalog.gd")
const VERSION := "text-presentation-v1"
var locale := "en"
var generation := 0
var _loaded: Dictionary = {}
var _staged: Dictionary = {}
var _ticket := -1
var _registry: RefCounted
var _views: Array = []
var _busy := false
var recovery: FontFile
var notice := ""

func _init() -> void:
	recovery = Fonts.load_font({"bundled":"recovery-sans","sha256":Fonts.HASHES["recovery-sans"]})

func declare_settings(settings: StartupSettingsOwner) -> void:
	# Availability is a runtime capability, not malformed persisted configuration.
	settings.declare("presentation/locale", "en", TYPE_STRING, "live", Catalog.locale_id)

func prepare(resources: Dictionary, ticket: int) -> Dictionary:
	_staged.clear()
	_ticket = -1
	var records: Dictionary = resources.get(Fonts.DOMAIN + ":installed",{}).get("records",{})
	if records.is_empty():
		return {"ok":false,"reason":"Font definitions unavailable."}
	var fonts := {}
	for id: String in records:
		if records[id].value.kind == "font":
			fonts[id] = Fonts.load_font(records[id].value)
			if fonts[id] == null:
				return {"ok":false,"reason":"Font unavailable during staging: " + id}
	for id: String in fonts:
		var fallbacks: Array[Font] = []
		for fallback: String in records[id].value.fallbacks:
			fallbacks.append(fonts[fallback])
		fonts[id].fallbacks = fallbacks
	for record: Dictionary in records.values():
		var value: Dictionary = record.value
		if value.kind != "locale":
			continue
		# Bundled English essential constants remain a coherent catalog when every
		# installed recovery entry is unusable. Do not turn accepted text fallback
		# into a new font/readiness restriction.
		var catalog: bool = value.locale == "en"
		for resource: Dictionary in resources.values():
			if resource.domain != Catalog.DOMAIN:
				continue
			for text: Dictionary in resource.records.values():
				catalog = catalog or text.value.entries.get(value.locale,{}).get("usable",false)
		if not catalog:
			continue # Font-only installation is not a coherent selectable language.
		var roles := {}
		for role: String in Fonts.ROLES:
			roles[role] = fonts[value.roles[role]]
		_staged[value.locale] = {"roles":roles,"offer":value.offer,"coverage":value.coverage}
	if not _staged.has("en") or recovery == null:
		return {"ok":false,"reason":"Readable bundled English recovery unavailable."}
	_ticket = ticket
	return {"ok":true}

func commit(ticket: int, registry: RefCounted, settings: StartupSettingsOwner) -> void:
	assert(ticket == _ticket)
	_loaded = _staged
	_staged = {}
	_registry = registry
	_ticket = -1
	# Initial publication is assignment-only: no live views or signal callbacks
	# may enter CORE's durable-profile-to-menu commitment interval.
	var requested: String = settings.value(settings.accepted,"presentation/locale")
	locale = requested if _loaded.has(requested) else "en"
	notice = "" if locale == requested else "Requested language %s unavailable; effective language en. Install/repair packs and restart." % requested
	settings.effective["presentation/locale"] = locale

func available(include_synthetic := false) -> Array:
	var result: Array = []
	for id: String in _loaded:
		if _loaded[id].offer or include_synthetic:
			result.append(id)
	result.sort()
	return result

func font(role := "body", selected := "") -> Font:
	var id := locale if selected.is_empty() else selected
	return _loaded.get(id,{}).get("roles",{}).get(role,recovery)

func bind_view(view: Control) -> void:
	_views.append(weakref(view))

func unbind_view(view: Control) -> void:
	_views = _views.filter(func(reference: WeakRef): return reference.get_ref() != null and reference.get_ref() != view)

func apply(values: Dictionary) -> bool:
	return values.size() == 1 and values.has("presentation/locale") and switch_locale(values["presentation/locale"])

func switch_locale(selected: String) -> bool:
	if _busy or not _loaded.has(selected):
		return false
	if selected == locale:
		return true
	_busy = true
	var plans: Array = []
	_views = _views.filter(func(reference: WeakRef): return reference.get_ref() != null)
	for reference: WeakRef in _views:
		var view: Control = reference.get_ref()
		var plan: Dictionary = view.prepare_locale(selected)
		if not plan.get("ok",false):
			_busy = false
			return false
		plans.append({"view":view,"plan":plan})
	# Recheck scoped windows after all preparation; no stale/canceled view commits.
	for item: Dictionary in plans:
		if not item.view.locale_plan_current(item.plan):
			_busy = false
			return false
	locale = selected
	generation += 1
	for item: Dictionary in plans:
		item.view.commit_locale(item.plan)
	_busy = false
	notice = ""
	changed.emit()
	return true

func literal(text: String, role := "body", selected := "", essential_key := "", context: Dictionary = {}) -> Dictionary:
	var actual := font(role,selected)
	var display := ""
	var diagnostics: Array = []
	for index in text.length():
		var code := text.unicode_at(index)
		# Formatting controls stay literal to the shaping engine. No normalization.
		if code in [9,10,13,0x200c,0x200d,0x200e,0x200f,0x202a,0x202b,0x202c,0x202d,0x202e,0x2066,0x2067,0x2068,0x2069] or actual.has_char(code):
			display += text[index]
		else:
			display += "?" # Guaranteed by every validated font resource.
			diagnostics.append({"kind":"missing_glyph","scalar":code,"position":index,"locale":locale if selected.is_empty() else selected,"role":role,"context":context.duplicate(true)})
	if not diagnostics.is_empty() and Catalog.RECOVERY.has(essential_key):
		display = Catalog.RECOVERY[essential_key]
		actual = recovery
	return {"text":display,"font":actual,"diagnostics":diagnostics}

func essential(key: String) -> Dictionary:
	var resolved := Catalog.lookup(_registry,"recovery",key,locale)
	var result := literal(Catalog.essential_literal(resolved,key),"body","",key,{"collection":"recovery","key":key,"source":resolved.source})
	result.lookup = resolved
	return result

func lookup(collection: String, key: String, selected: String, required_controls: Variant = null) -> Dictionary:
	return Catalog.lookup(_registry,collection,key,selected,"",required_controls)

func dispose() -> void:
	_views.clear()
	_loaded.clear()
	_staged.clear()
	_registry = null
