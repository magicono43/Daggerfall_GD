# Variant definitions and scoped proposals — v1

IMP-010 increment 3 implements DATA-024's DATA boundary. `variant_inputs.gd`
registers `world.variants` in the existing application-lifetime definition registry
before classic preparation. `variant_resolution.gd` is stateless. Neither stores
selections, starts transitions, imports saves, or certifies a playable location.
Qualification and user acceptance are recorded separately in increment-3 evidence.

IMP-061 increment 1 adds a LOC geometry consumer of published layouts, not active
story/palette/environment selection. Geometry frame and optional assembly/snap
declarations are specified in [DUNGEON_ASSEMBLY.md](../loc/DUNGEON_ASSEMBLY.md).
Variant selection/edited-variant geometry integration remains increment 2 /
IMP-055 as applicable; the existing pure proposals do not become entry readiness.

## Installed schema

Logical paths are `packs/<originating package>`. The registry supplies complete
`{domain,package,local,record}` identities, preserving origin on replacement and
recording winning/contributing providers separately. Local references below are
explicit stable `packs/<origin>#<record>` addresses in the appropriate domain;
they never mean filenames, names, pixels, ordinals or model appearance. Classic
references require the accepted explicit edition ledgers. Mods allocate their
own local keys without numeric-range coordination.

Every definition is a complete dictionary with exactly these fields:

| kind | fields |
| --- | --- |
| variant | `schema=variant-inputs-v1`, `kind=variant`, `target`, `alternate` (layout.inputs reference), `mapping` (explicit source record key to target key) |
| default | `schema=variant-inputs-v1`, `kind=default`, `target`, `choice` |

`choice` is exactly `{intent:baseline}` or `{intent:variant,variant:<local ref>}`.
The selected definition must be a variant with the **same declared target**.
Null, empty-string selection, deletion and reset sentinels have no meaning.

| target scope | exact additional fields | supported alternate |
| --- | --- | --- |
| location-layout | location (geography.inputs), layout (layout.inputs) | Complete layout for the same stable geographic location |
| global-block | block | Complete block, applicable independently to occurrences of that block |
| location-block | location, layout, block | Complete block in this explicit containing location/layout |
| placement | location, layout, block, placement | Complete block at this explicit authored placement |
| building | location, layout, block, placement, building | Complete RMB block whose changes stay inside this one building |

Building defaults are unsupported; building selections are explicit. No broader
location-layout hierarchy, global-building scheme, cross-location merge, or
inferred selection is implemented. Whole-layout and block alternatives compose
only where explicit target/context remains valid. A building selection requires
its declared containing definition, building key and unchanged outside-building
envelope; another selected containing block is incompatible even if it happens
to contain a similar building. Multiple building alternatives in one placement
are unsupported; a caller can author one complete block alternative instead.
Separate placements/building contexts can resolve independently.
Edited building alternatives in v1 use complete authored RMB source/target
definitions with identical outside-building envelopes. Classic-source to authored
building-local edits are unsupported; classic blocks can use complete placement
alternatives. This restriction is distinct from the accepted classic building
decoder and its reserved identities.

`add` requires unused IDs. `replace` supplies a complete resource and retains all
previous IDs, preventing implicit removal of required declarations/defaults.
Matching replacement IDs also retain kind and target, preventing a disguised
default removal or retarget under the same declaration identity.
`patch` replaces complete `alternate`, `mapping` or `choice` fields; all omitted
fields remain. It cannot retarget or change kind. There is no deep merge, list
splice, deletion or universal null policy. To remove a default's variant effect,
replace its choice explicitly with baseline; this does not expose another
default or clear live owner state. Unsupported deletion/exposure policies remain
owner work. Use a new explicit declaration when changing targeting semantics.

## Publication and supported validation timing

Shipped, folder, ZIP and captured loose contributions use the existing checked
package transport and DATA-003 order. Whole-file schema rejection, clean rebuild,
explicit omission, final remaining-reference validation, exact tickets, menu
reservation, durable profile ordering and run-long lock are unchanged. There is
no new loader or registry and no added work after the durable commitment.

The exact final candidate validates typed geography/layout/block/alternate
references, containing-location agreement, authored placement/block pairs,
explicit classic placement/building ledger keys, building existence, format
agreement, default target uniqueness and default-to-variant references. Layout's
own validator checks complete alternate structures, action links and typed media
exports. Required missing references cannot be waived through omission.

Preparation validates selected source/alternate records, explicit remapping,
retained record type/purpose/parent context, containing combinations, required
markers/doors and actual resources. Classic metadata/index readiness does not
promise usable source payloads. Alternates are decoded only when required; the
whole world and every alternative are not eagerly built at startup. Invalid or
later unavailable required payloads/resources fail the affected preparation
without usable occurrences or fallback. Source/provider/placement/variant and
requesting-owner context accompany the affected failure.

All derived variant/default indexes clear at candidate start/failure, rebuild
against final resources, and are readable only with the published ticket. Public
reads detach. No per-session cache exists. The query content token includes the
committed ticket and a random application-instance nonce; it is transient request
context, not a persisted identity, content hash or gameplay RNG stream. Payload
fingerprints provide separate structural revision evidence.

## Query/result schema

`context(registry)` returns the exact committed variant context or a readiness
failure. `resolve(registry,request,resource_provider)` takes exactly eight fields:

```text
schema: variant-query-v1
owner: explicit nonempty requesting-owner diagnostic
content_context: exact context returned by this application's committed adapter
layout: complete originating layout.inputs identity
layout_selection: explicit selection intent
selections: [{target: exact placement/building target, selection: intent}, ...]
required: [{placement,record,type,purpose, optional context/referring}, ...]
compatibility: [explicit structural mapping requirements, ...]
```

An intent is exactly `{intent:baseline|default|reset-baseline|reset-default}` or
`{intent:variant,variant:<complete world.variants identity>}`. The root selection
is mandatory. Absence/unknown content in an explicitly supplied selection fails;
it never becomes baseline. Absent placement entries request the schema's declared
default if one applies, otherwise its explicit baseline outcome. Missing required
selection data must be represented as a required entry with invalid/missing intent
and rejects. DATA does not decide which saved owner entries are optional.

An explicit placement selection takes precedence over all applicable defaults.
Default lookup considers an exact placement default, location-block default and
global-block default. Exactly one may apply; multiple applicable defaults fail
as ambiguous. There is deliberately no invented location-versus-global hierarchy.
An explicit placement baseline or applicable variant disambiguates that request.
Definition winning-provider precedence is independent of this selection rule.

Success is `variant-resolution-v1`, containing detached structural occurrences,
original durable layout anchor, distinct alternate block definitions, proposals,
compatibility receipts and exact `variant_context`. The accepted raw coordinate
frames, parent transform chains and purpose-specific links are preserved. Source
conversion remains `layout-coordinate-handoff-v1`; engine/physics conversion is
unsupported. `selection_committed`, `transition_complete`, `location_ready`,
`physics_ready` and `save_compatible` are false. Reset proposals are labeled and
validated just like selections; they do not apply an owner transition.
Each reset applies only to its explicit target; it does not cascade through
other caller selections or erase broader defaults.

Failures distinguish missing/readiness, invalid, incompatible, stale, unsupported
and actual source/provider/resource failure. No partial usable occurrences return.
Reading A, B, then A is equivalent to reading A twice with the same explicit inputs.
Caller inputs and reusable definitions remain unchanged.

## Structural compatibility, not migration

Each selected alternative checks its declared baseline source against its target.
Mapping keys must exist in that source and target, be injective, and not collide
with a retained target identity. Retained and mapped records must keep structural
type, marker purpose, parent building and exterior/interior context. Legal action
cycles and explicit door roles stay intact. Building mappings are restricted to
that building's source/target records. Payload changes under retained IDs are reported independently;
unchanged ID strings never imply unchanged payloads or real owner compatibility.

Receipts retain source/target definition identities, selected variant identity,
actual applied occurrence scope, canonical source/target SHA-256 fingerprints,
explicit mappings, retained IDs, changed payloads, variant provider provenance,
and independent source/target winning providers, contributors, input receipts
and published-value hashes. Canonical
dictionary keys are sorted before fingerprinting; record arrays remain encoded
content, with explicit keys supplying identity independently of array order.

An optional required mapping check contains exactly `variant`, `scope`, `source`,
`target`, `source_sha256`, `target_sha256`, and `required` source record IDs. It
must match the actually selected receipt and request content revision/context.
Every required ID must have an explicit mapping, even an identity mapping. A
retained-ID edit and an explicit mapping are independently checked. Obsolete,
wrong-scope, wrong-purpose/type, missing and colliding mappings reject. Baseline-
to-selected structural checking is supported; arbitrary historical revision or
variant-to-variant migration is not. No SAVE migration or durable state is created.

## Reference evidence and owner handoffs

Static read-only inspection of DFU 1.1.1's `WorldDataReplacement.cs` observed
region/index/filename variant suffix keys, replacement caches, loose-before-mod
lookup and new-location fallback to a nonvariant cache key on failed load.
`WorldDataVariants.cs` holds mutable dictionaries and `lastLocationKey`, uses
empty string and -8 sentinels, and clears `RMBLayout`'s location cache in setters.
The location setter's boolean contradicts its documented new-entry convention.
RMB/RDB consumers get block data by name before geometry construction; RMB's
cache and offsets do not establish target identity or scale. `SaveLoadManager`
restores world variations before position restoration, but its exception path
attempts continuation without variants. These were source observations, not DFU
runtime/geometry tests or imported save behavior. No classic variant catalog was
observed or claimed. No DFU source payload, cache policy, reset sentinel, fallback,
motor constant or runtime mutation protocol is adopted here.

WORLD/LOC must supply actual selection storage, request/session/operation identity,
transition preflight/replacement/cancellation/recovery and cache invalidation for
live assembly. CORE gates reconstruction and rejects late outcomes. MOVE validates
geometry/collision/player placement. QUEST/action and persistent-object owners
validate their bindings. SAVE defines required selection presence, versioned
snapshots/migrations, restore ordering, compatibility and save-during-transition
timing. Controlled sequential-session/restore-order probes show only that DATA
resolution can run before reconstruction and cannot inherit hidden selection.
They do not qualify these real providers, opening gameplay, parent IMP-010 or M1.
