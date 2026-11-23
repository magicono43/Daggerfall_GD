extends RefCounted
## Stateless resolution. There is deliberately no last location or selection cache.
const L = preload("res://scripts/data/layout_inputs.gd")
const C = preload("res://scripts/data/actor_input_formats.gd")
const F = preload("res://scripts/data/layout_formats.gd")
const DOMAIN = "world.variants"
const VERSION = "variant-query-v1"
var _block_reads := {} # One synchronous, exact-content resolution only.

func block_input(adapter: RefCounted, registry: RefCounted, ref_: String) -> Dictionary:
	if not _block_reads.has(ref_): _block_reads[ref_] = adapter.layouts.decode_block(registry,ref_)
	return _block_reads[ref_].duplicate(true)

static func target_key(target: Dictionary) -> String:
	var parts: Array = []
	for field in ["scope","location","layout","block","placement","building"]: parts.append(target.get(field,null))
	return JSON.stringify(parts)

static func digest(value: Variant) -> String:
	# Godot Dictionary insertion order must not affect compatibility fingerprints.
	return JSON.stringify(canonical(value)).sha256_text()

static func canonical(value: Variant) -> Variant:
	if value is Dictionary:
		var result := {}
		var keys: Array = value.keys()
		keys.sort()
		for key in keys: result[key] = canonical(value[key])
		return result
	if value is Array:
		var result: Array = []
		for entry in value: result.append(canonical(entry))
		return result
	return value

static func reject(reason: String, request: Dictionary, target: Variant = null, kind := "incompatible") -> Dictionary:
	var context: Variant = request.get("content_context",{})
	var layout: Variant = request.get("layout",{})
	return F.fail(reason,DOMAIN,request.get("owner"),target,kind).merged({"schema":"variant-resolution-v1","provider":DOMAIN,"request_context":context.duplicate(true) if context is Dictionary else context,"layout":layout.duplicate(true) if layout is Dictionary else layout,"selection_committed":false,"transition_complete":false})

func choose(index: Dictionary, target: Dictionary, selection: Dictionary, broader: Array, request: Dictionary) -> Dictionary:
	if selection.get("intent") not in ["baseline","variant","default","reset-baseline","reset-default"]: return reject("Explicit selection intent required.",request,target,"invalid")
	var reset: bool = str(selection.intent).begins_with("reset-")
	var intent: String = str(selection.intent).trim_prefix("reset-")
	if intent == "variant":
		if selection.size() != 2 or not selection.get("variant") is Dictionary: return reject("Selected variant requires complete originating identity.",request,target,"invalid")
	elif selection.size() != 1: return reject("Baseline/default/reset has no variant or hidden state.",request,target,"invalid")
	var default_ref := ""
	if intent == "default":
		var candidates: Array = []
		for t: Dictionary in [target]+broader:
			var key := target_key(t)
			if index.defaults.has(key): candidates.append(index.defaults[key])
		if candidates.size() != 1: return reject("Declared default absent or ambiguous; explicit baseline/variant required.",request,candidates,"missing" if candidates.is_empty() else "incompatible")
		default_ref = candidates[0]
		var choice: Dictionary = index.variants[default_ref].value.choice
		intent = choice.intent
		if intent == "variant": selection = {"intent":"variant","variant":index.variants[choice.variant].identity}
	if intent == "baseline": return {"ok":true,"intent":"baseline","reset_proposal":reset,"default":default_ref}
	var identity: Dictionary = selection.variant
	if identity.get("domain") != DOMAIN or not identity.get("local") is String or not index.variants.has(identity.local): return reject("Required selected variant/package absent.",request,identity,"missing")
	var record: Dictionary = index.variants[identity.local]
	if record.value.kind != "variant" or not C.equal_input(record.identity,identity): return reject("Required selected identity is invalid or has another origin.",request,identity,"missing")
	var applies := false
	for t: Dictionary in [target]+broader:
		if C.equal_input(record.value.target,t): applies = true
	if not applies: return reject("Variant does not apply to explicit occurrence scope.",request,record.value.target)
	return {"ok":true,"intent":"variant","variant":record.duplicate(true),"reset_proposal":reset,"default":default_ref}

static func inventory(read: Dictionary, layout: bool) -> Dictionary:
	var result := {}
	for item: Dictionary in (read.data.placements if layout else read.definition.records): result[item.id] = item
	return result

func check_mapping(source: Dictionary, target: Dictionary, selected: Dictionary, is_layout: bool, request: Dictionary) -> Dictionary:
	var old := inventory(source,is_layout)
	var current := inventory(target,is_layout)
	if selected.value.target.scope == "building":
		var building: String = selected.value.target.building
		for id: String in old.keys():
			if old[id].get("building_id","") != building: old.erase(id)
		for id: String in current.keys():
			if current[id].get("building_id","") != building: current.erase(id)
	var mapping: Dictionary = selected.value.mapping
	var destinations := {}
	for id: String in old:
		if current.has(id) and not mapping.has(id): destinations[id] = id
	for id: String in mapping:
		var to: String = mapping[id]
		if not old.has(id) or not current.has(to) or destinations.has(to): return reject("Mapping source/target missing or collides with retained identity.",request,{"source":id,"target":to,"variant":selected.identity})
		destinations[to] = id
	var changed: Array = []
	for id: String in old:
		var to: String = mapping.get(id,id)
		if not current.has(to): continue
		var a: Dictionary = old[id]
		var b: Dictionary = current[to]
		for field in (["context"] if is_layout else ["type","marker_purpose","building_id","record_context"]):
			if a.get(field,"") != b.get(field,""): return reject("Retained/mapped record changes type, purpose or parent scope.",request,{"source":id,"target":to,"field":field,"variant":selected.identity})
		if not is_layout and a.get("door_metadata",{}).get("candidate",false) != b.get("door_metadata",{}).get("candidate",false): return reject("Retained/mapped record changes its explicit door role.",request,{"source":id,"target":to,"variant":selected.identity})
		if digest(a) != digest(b): changed.append({"source":id,"target":to})
	return {"ok":true,"variant":selected.identity.duplicate(true),"source":source.identity.duplicate(true),"target":target.identity.duplicate(true),"source_sha256":digest(source.data if is_layout else source.definition),"target_sha256":digest(target.data if is_layout else target.definition),"mapping":mapping.duplicate(true),"retained":old.keys().filter(func(id: String): return current.has(id) and not mapping.has(id)),"changed_payloads":changed,"provider":selected.winner.duplicate(true),"structural_only":true,"save_compatible":false,"loc_compatible":false,"quest_compatible":false}

func alternative(adapter: RefCounted, registry: RefCounted, source: Dictionary, selection: Dictionary, is_layout: bool, request: Dictionary, receipts: Array, scope: Dictionary) -> Dictionary:
	if selection.intent == "baseline": return source
	var record: Dictionary = selection.variant
	var target: Dictionary = adapter.layouts.location_inputs(registry,record.value.alternate) if is_layout else block_input(adapter,registry,record.value.alternate)
	if not target.ok: return target.merged({"variant":record.identity,"referring":request.owner,"provider":record.winner},true)
	var mapping := check_mapping(source,target,record,is_layout,request)
	if not mapping.ok: return mapping
	mapping.scope = scope.duplicate(true)
	# Retain the input publication receipts separately from the selected variant's
	# provider. The alternative block/layout may have a different winning package.
	for pair in [["source",source.identity.local],["target",record.value.alternate]]:
		var published := L.lookup(registry,pair[1])
		if not published.ok: return published
		var input: Dictionary = published.record
		mapping[pair[0]+"_provenance"] = {"winner":input.winner.duplicate(true),"contributors":input.contributors.duplicate(true),"input":input.value.get("input",{}).duplicate(true),"value_sha256":digest(input.value)}
	receipts.append(mapping)
	# Alternate definition is distinct; retained occurrence IDs stay anchored to the
	# originally requested layout. Block definition provenance remains the alternate.
	if is_layout: target.identity = source.identity.duplicate(true)
	return target

static func building_envelope(block: Dictionary, building: String) -> Dictionary:
	var definition: Dictionary = block.definition
	var outside := {}
	for r: Dictionary in definition.records:
		if r.get("building_id","") != building: outside[r.id] = r
	var parents: Dictionary = definition.get("building_inputs",{}).duplicate(true)
	parents.erase(building)
	# Building-only edits may not change the block ground, automap or root structure.
	var shell: Dictionary = definition.get("structure",{}).duplicate(true)
	shell.erase("buildings")
	return {"format":definition.format,"outside":outside,"parents":parents,"shell":shell,"ground":definition.get("ground"),"automap":definition.get("automap")}

func resolve(adapter: RefCounted, registry: RefCounted, request: Dictionary, resource_provider: Callable, loc_inputs := false) -> Dictionary:
	var index: Dictionary = registry.domain_index(DOMAIN)
	if not index.ok: return index
	if request.get("schema") != VERSION or request.size() != 8 or not request.get("owner") is String or str(request.owner).is_empty() or not request.get("layout") is Dictionary or not request.get("layout_selection") is Dictionary or not request.get("selections") is Array or not request.get("required") is Array or not request.get("compatibility") is Array: return reject("Complete versioned explicit query required.",request,null,"invalid")
	if not C.equal_input(request.get("content_context"),index.context): return reject("Exact committed application/content context required.",request,null,"stale")
	for required in request.required:
		if not required is Dictionary or not required.get("placement") is String or not required.get("record") is String or not required.get("type") is String or not required.get("purpose") is String: return reject("Complete typed required occurrence reference expected.",request,required,"invalid")
	var resolved := L.resolve_identity(registry,request.layout)
	if not resolved.ok: return resolved
	var source: Dictionary = adapter.layouts.location_inputs(registry,request.layout.local)
	if not source.ok: return source
	var location: String = source.data.location
	var root := {"scope":"location-layout","location":location,"layout":request.layout.local}
	var root_choice := choose(index,root,request.layout_selection,[],request)
	if not root_choice.ok: return root_choice
	var receipts: Array = []
	var layout := alternative(adapter,registry,source,root_choice,true,request,receipts,root)
	if not layout.ok: return layout
	for default_ref: String in index.defaults.values():
		var target: Dictionary = index.variants[default_ref].value.target
		if target.scope != "placement" or target.layout != request.layout.local or target.location != location: continue
		if not layout.data.placements.any(func(p: Dictionary): return p.id == target.placement and p.block == target.block): return reject("Required declared placement default is incompatible with containing layout.",request,target)
	var selections := {}
	for entry in request.selections:
		if not entry is Dictionary or entry.size() != 2 or not entry.get("target") is Dictionary or not entry.get("selection") is Dictionary or entry.target.get("scope") not in ["placement","building"] or not adapter.target_reason(entry.target).is_empty(): return reject("Exact placement/building selection entry required.",request,entry,"invalid")
		var key := target_key(entry.target)
		if selections.has(key): return reject("Duplicate/ambiguous caller selections.",request,entry.target)
		selections[key] = entry
	var consumed := {}
	var blocks := {}
	var proposals: Array = [{"target":root,"resolution":root_choice}]
	for p: Dictionary in layout.data.placements:
		if loc_inputs and p.context != "dungeon": continue
		var source_block: Dictionary = block_input(adapter,registry,p.block)
		if not source_block.ok: return source_block.merged({"placement":p.id,"referring":request.owner,"variant":root_choice.get("variant",{})},true)
		var t := {"scope":"placement","location":location,"layout":request.layout.local,"block":p.block,"placement":p.id}
		var key := target_key(t)
		var broader := [{"scope":"location-block","location":location,"layout":request.layout.local,"block":p.block},{"scope":"global-block","block":p.block}]
		var has_default: bool = index.defaults.has(key)
		for b: Dictionary in broader: has_default = has_default or index.defaults.has(target_key(b))
		# No installed default is a declared baseline outcome of this schema. Missing
		# explicit required selections never enter this branch.
		var choice := choose(index,t,selections[key].selection if selections.has(key) else {"intent":"default" if has_default else "baseline"},broader,request)
		if not choice.ok: return choice
		if selections.has(key): consumed[key] = true
		var block := alternative(adapter,registry,source_block,choice,false,request,receipts,t)
		if not block.ok: return block
		proposals.append({"target":t,"resolution":choice})
		var building_keys: Array = selections.keys()
		building_keys.sort()
		for building_key: String in building_keys:
			var entry: Dictionary = selections[building_key]
			if entry.target.scope != "building" or entry.target.layout != request.layout.local or entry.target.location != location or entry.target.placement != p.id: continue
			var bt: Dictionary = entry.target
			if bt.block != p.block or not block.definition.get("building_inputs",{}).has(bt.building): return reject("Building target disappeared or containing variant is incompatible.",request,bt)
			# Building declarations target the current complete containing definition.
			if block.identity.local != bt.block: return reject("Building/containing block combination requires a matching declaration.",request,bt)
			var bc := choose(index,bt,entry.selection,[],request)
			if not bc.ok: return bc
			var alternate := alternative(adapter,registry,block,bc,false,request,receipts,bt)
			if not alternate.ok: return alternate
			if not alternate.definition.get("building_inputs",{}).has(bt.building) or not C.equal_input(building_envelope(block,bt.building),building_envelope(alternate,bt.building)): return reject("Building variant changes records outside its declared building.",request,bt)
			block = alternate
			consumed[building_key] = true
			proposals.append({"target":bt,"resolution":bc})
		blocks[p.id] = block
	if consumed.size() != selections.size(): return reject("Required selection target absent after containing variant.",request,selections.keys().filter(func(k: String): return not consumed.has(k)))
	for check in request.compatibility:
		if not check is Dictionary or check.size() != 7 or not check.get("variant") is Dictionary or not check.get("required") is Array or not check.get("scope") is Dictionary: return reject("Complete revision-scoped structural compatibility request required.",request,check,"invalid")
		var found := false
		for receipt: Dictionary in receipts:
			if not C.equal_input(receipt.variant,check.variant) or not C.equal_input(receipt.scope,check.scope): continue
			if check.get("source_sha256") != receipt.source_sha256 or check.get("target_sha256") != receipt.target_sha256 or not C.equal_input(check.get("source"),receipt.source) or not C.equal_input(check.get("target"),receipt.target): continue
			found = true
			for id in check.required:
				if not receipt.mapping.has(id): return reject("Required explicit record mapping absent.",request,{"record":id,"variant":receipt.variant})
		if not found: return reject("Compatibility inputs obsolete or variant not selected.",request,check)
	var scoped_layout: Dictionary = layout
	if loc_inputs:
		scoped_layout = layout.duplicate(true)
		scoped_layout.data.placements = scoped_layout.data.placements.filter(func(p: Dictionary): return p.context == "dungeon")
	var result: Dictionary = adapter.layouts.prepare_structural_inputs(registry,request.layout.local,scoped_layout,blocks,resource_provider,request.required,loc_inputs)
	if not result.ok: return result.merged({"variant_proposals":proposals,"referring_owner":request.owner},true)
	# Recheck after trusted resource callbacks: a disposed provider or obsolete
	# candidate must not return a current successful result.
	var current: Dictionary = adapter.context(registry)
	if not current.ok or not C.equal_input(current.context,request.content_context): return reject("Content retired during resolution.",request,null,"stale")
	result.variant_context = index.context.duplicate(true)
	result.schema = "variant-resolution-v1"
	result.proposals = proposals.duplicate(true)
	result.compatibility = receipts.duplicate(true)
	result.selection_committed = false
	result.transition_complete = false
	if loc_inputs:
		result.schema = "variant-assembly-inputs-v1"
		result.layout_inputs = layout.duplicate(true)
		result.blocks = blocks.duplicate(true)
	return result
