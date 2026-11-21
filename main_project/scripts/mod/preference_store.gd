extends "res://scripts/startup/settings_owner.gd"
## CORE ConfigFile recovery/publication reused per stable mod ID, independent of
## profile and character. Timings below are real owner boundaries, not next_launch.
const Definitions = preload("res://scripts/mod/preference_definitions.gd")
var definition: Dictionary

func _init(storage: StartupStorageAdapter, directory: String, active: Dictionary) -> void:
	super(storage, directory)
	definition = active.duplicate(true)
	defaults_path = "res://config/mod_preferences.ini"
	schema.clear()
	for key: String in definition.settings:
		var spec: Dictionary = definition.settings[key]
		var type: int = {"bool":TYPE_BOOL,"int":TYPE_INT,"string":TYPE_STRING}[spec.type]
		var default_value: Variant = int(spec.default) if type == TYPE_INT else spec.default
		# The shared owner accepts only its original timing inventory. This scoped
		# owner declares its own inventory without changing existing callers.
		schema["values/" + key] = {"default":default_value,"type":type,"timing":spec.timing,"validate":func(value: Variant): return Definitions.valid_value(value, spec)}
	for id: String in definition.groups:
		var members: Array = []
		for key: String in definition.settings:
			if definition.settings[key].group == id:
				members.append("values/" + key)
		var constraints: Array = definition.groups[id].constraints.duplicate(true)
		declare_group(id, members, func(config: ConfigFile):
			for constraint: Array in constraints:
				if config.get_value("values", constraint[1]) > config.get_value("values", constraint[2]):
					return false
			return true)

func load_config(source: String) -> ConfigFile:
	var config := super.load_config(source)
	if config != null and source == defaults_path:
		config.set_value("mod", "id", definition.mod_id)
		config.set_value("mod", "version", int(definition.version))
	return config

func supported(config: ConfigFile) -> bool:
	return super.supported(config) and config.get_value("mod", "id", "") == definition.mod_id and config.get_value("mod", "version", 0) == int(definition.version)

func group_timing(id: String) -> String:
	var timing := "live"
	for member: String in groups[id].members:
		var declared: String = schema[member].timing
		if declared == "restart":
			return "restart"
		if declared != "live":
			timing = declared
	return timing
