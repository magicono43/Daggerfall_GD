# DATA-005 — Exterior and dungeon block records

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Supply structural definitions used to assemble exterior, building-interior and dungeon locations while preserving supported object placement, building information, markers and action relationships. Give quests and saves unambiguous references to records within repeated block placements.

## Intended player experience

Classic locations retain their intended supported layout and gameplay-relevant structure. Doors, quest placements and actions belong to the correct placed objects. Repeated uses of a block do not share live gameplay state. Invalid required content fails preparation explicitly rather than producing holes or an unrelated replacement.

## Confirmed requirements

DATA-005-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish classic structural fidelity with explicit overrides; separate definitions and live instances; scoped definition/placement/record identity; required-block failure; preserved and validated action links; explicit replacement compatibility; purpose-specific markers; safe handling of unknown versus unsupported required content; and representative structural/conversion verification.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `API/DFBlock.cs` represents typed block records with archive name/index/position. RMB contains exterior/interior subrecords, miscellaneous models/flats, building information, ground data and automap data. RDB contains dungeon object/resource structures. The enum documents RDI as unsupported and to be ignored; that comment does not establish a supported runtime RDI layout.
- `API/BlocksFile.cs#Load` loads `BLOCKS.BSA` and allocates its record array. `GetBlockType` identifies extensions; `GetRdbType` derives categories from names, noting that the Start category requires map context. `GetBlockIndex` resolves names, including new-block replacements. `LoadBlock` decodes on demand and discards a failed record.
- `Utility/ContentReader.cs#GetBlock` rejects an unknown returned block type. This does not establish validation of every downstream gameplay reference.
- `Utility/RMBLayout.cs` consumes block records to assemble runtime objects and derives building keys using placement coordinates and record index. `Utility/RDBLayout.cs` assembles dungeon objects, markers and action objects with link context. These consumers demonstrate why record and placement context matters beyond visual geometry.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static source inspection only. Representative classic blocks, fixtures and rendered runtime behavior have not been tested in this specification phase. Source remains unchanged.

## Detailed rules and behaviors

### Supported structural content

Use supported classic block placement, object references, building metadata, markers and action-link relationships as the baseline. Allow explicit validated content overrides under DATA-003 and the applicable block-content schema. Godot representation may differ, but conversion must not silently simplify gameplay-relevant content.

Decode supported exterior/interior RMB and dungeon RDB structures into typed definitions for consumers. This feature does not declare all historic fields or actions understood, or authorize implementing RDI. Unknown fields may remain uninterpreted only when they can safely be retained or skipped without changing supported behavior. Unused differences in modified classic records alone are not grounds for rejection. Unsupported required block types or gameplay actions fail explicitly; they must not be treated as harmless unknown padding.

DATA supplies interpreted source structure. LOC/WORLD own assembly, residency and local runtime context; gameplay owners execute actions and instantiate state. Mesh conversion, collision, rendering and presentation lifetimes remain their respective owner contracts.

### Definition, placement and record identity

Distinguish reusable block definition identity, a placement of that definition within a stable location, and an individual record within that placement. Retain explicit classic name/index/record mappings where required for source interpretation. Archive byte offsets or transient scene handles alone are not durable references.

Repeated placements can share authored definitions and reusable resources but have independent live doors, enemies, loot and triggered actions under LOC and gameplay ownership. Character/session mutations must not modify shared definitions or contaminate another placement or character.

Concrete ID encoding and legacy record addressing remain technical dependencies. Preserve sufficient source context to resolve original relationships; this is not approval to renumber classic records arbitrarily or infer identity from model appearance. Definition replacement follows explicit content-operation rules and does not itself prove saved-record compatibility.

### Markers and action links

Preserve marker types, placement and source identity explicitly. Consumers select by intended purpose and required location context rather than first-marker enumeration. Entrance, quest placement and new-character start are distinct purposes even where encoded through related source structures. CORE-011's original deep-cave opening cannot be replaced by an arbitrary entrance/start marker merely because it appears first.

Preserve authored action-link relationships and validate their targets within the format's permitted scope. Repeated block placements must resolve links to the intended placement context. Do not automatically remove cycles or repeated links; they may be intentional. LOC/action owners define safe execution, including how supported cycles behave, before runtime behavior is considered complete.

Broken required links invalidate the affected block. This does not require treating every unused sentinel or format-defined absent link as broken: exact requiredness and sentinel rules must be established per format/action. DATA validates structural references; it does not invent universal action ordering, recursion limits or trigger rules.

### Validation and failure

Keep DATA-001's basic source checks and DATA-002's required-reader/index gate separate from individual block decoding. Record decoding may remain on demand. Failures discovered during configuration validation follow DATA-002/003 recovery; do not require exhaustive classic block decoding at startup merely to satisfy this feature.

A missing, malformed or unsupported block required by a location fails that location's preparation. Do not leave holes, substitute another block or report location readiness after failed required preparation. LOC/CORE retain cleanup, player-control gating and recovery ownership. DATA returns differentiated missing, source-unavailable or malformed/unsupported outcomes with source/block/record context where available.

Apply DATA-003's whole-contribution rejection and explicit continuation rules where its resolver handles a block contribution. Exact block-specific replacement/patch schemas remain to be defined; generic text field-patching semantics do not alone establish safe structural block edits. No invalid partial definition becomes published as usable.

### Replacements and compatibility

Unchanged block identity is insufficient proof of compatibility. If replacement removes or changes records referenced by saved state or quests, require explicit mapping/migration or an incompatibility outcome under SAVE/LOC/QUEST. Do not guess identity by nearby coordinates or similar models. Compatible unchanged references may remain usable, but the validation contract must establish that rather than assume it.

Classic source changes require restart under DATA-001/002; block definitions from mod resolution respect DATA-003's editable pre-menu stage and subsequent lock. Rebuilding a candidate must not retain old block/link caches as if they belonged to the new resolved definition set. Loading a save does not change the active content configuration.

### Conversion verification

Before declaring the importer complete, verify positions, rotations, scale and link targets against representative exterior and dungeon records. Include building interiors, repeated block placements, quest/action markers and supported action relationships. Use source/structural assertions and appropriate rendered inspection; approximate visual resemblance alone is insufficient. Specific fixtures, tolerances and engine-space conventions must be documented and verified, not invented here.

## Relevant formulas and parameters

No gameplay balance formulas or new Godot scale values are approved. DFBlock's RMB tile count and the existing layout classes' classic scaling constants are source references, not independent authorization for the target engine's units. Coordinate axes, orientation conversion, transform composition, numeric tolerances and block dimensions require verified DATA/WORLD/LOC contracts. No generic cycle cap or action timeout is selected here.

## Required data

Block definition ID/type and provenance; classic name/archive/record mappings; location and block-placement context; scoped record identities; model/flat and other supported resource references; positions/orientations/scales; building/interior/ground/automap data required by supported consumers; marker type/purpose inputs; action types, parameters and link targets; supported/unknown-field classification; conversion and compatibility metadata where needed. Live state belongs to placed instances and its authoritative owners. Exact schema, reference scope and migration representation remain dependencies.

## Inputs, outputs and events

Inputs: classic block records, resolved supported overrides, block queries, placement context and reference validation. Outputs: usable typed definitions or explicit missing/unavailable/malformed/unsupported failures; scoped record/marker/link information; validation context for assembly and compatibility. These are conceptual contracts, not approved APIs/signals. Successful decode does not announce location readiness, spawn enemies or execute an action by itself.

## Cross-system interactions

- DATA-001/002 own source checks, access/readiness and failure distinctions. DATA-003 owns applicable contribution ordering, staging/rejection and configuration lock. DATA-004 supplies stable containing-location identity.
- LOC owns block assembly, interiors/dungeons, placement-specific state and supported actions; WORLD supplies geographic/runtime coordinate context. Neither may mistake a failed required block for a valid empty layout.
- QUEST consumes purpose-specific markers and scoped placement/record references, validating persisted bindings when content changes. CORE-011 retains the verified special opening-location requirement.
- AV owns conversion and presentation resources; MOVE owns actor placement/physics. Their detailed collision, movement and rendering behavior is not specified by structural fidelity alone.
- NPC/COMBAT/ITEM and other gameplay owners instantiate their own live state from authored inputs; repeated block definitions do not share mutable instances.
- SAVE/LOC/QUEST validate restored records and migrations. CORE-005/007/013 retain lifecycle, readiness and loading failure rules. MOD owns executable/content package lifecycle outside these data contracts.

## Edge cases and failure conditions

- One definition appears twice: object state and link resolution remain placement-specific rather than using one shared mutable record instance.
- An unknown unused field differs in an otherwise supported modified block: safely retain/skip it under a documented format rule. Unsupported required behavior cannot use that exemption.
- Missing model/object references, malformed transforms or missing action targets must be evaluated against actual format and consumer requiredness; no silent deletion of required content is authorized.
- Cycles/repeated links remain represented; safe action execution requires its owner contract and must not be replaced by automatic graph simplification.
- A marker exists but is for the wrong purpose: do not claim placement success by choosing it arbitrarily. Consumer-specific fallback must be explicitly approved.
- A required block fails after earlier blocks decode: location preparation remains failed; LOC cleans up partial assembly rather than exposing a usable location with holes.
- Replacement preserves a block name/ID while changing record layout: saved/quest references require explicit compatibility validation or mapping, not proximity matching.
- Source/configuration changes must not reuse stale decoded/link results from a different resolved definition set.

## Configuration and balancing options

Explicit validated block overrides are supported through declared domain schemas. No player-facing option for silently skipping required blocks, simplifying links or bypassing compatibility is approved. Enemy/loot/action balance and behavior remain owner specifications rather than DATA import policy.

## Save/load considerations

Persist instance state through scoped location/placement/record references and owner schemas, not shared definition mutations or scene handles. Loading reconstructs definitions/resources and restores instance state under SAVE/LOC coordination. Definition identity alone does not certify compatibility after replacement. Migration mappings, missing-record policy and content version identity remain owner dependencies; no automatic teleport, reset or substitute block is introduced here.

## Technical constraints

Target engine: Godot 4.7.2. Separate classic decoding, reusable definitions, engine resource conversion and per-placement live state. Keep external inputs read-only. Maintain explicit source and placement context through reference conversion. Publish complete valid definitions and truthful failures; concrete caches, APIs, ID widths, coordinate scale and decoder libraries remain implementation choices. This feature does not approve broader architecture proposals wholesale.

## Acceptance criteria

1. Supported original RMB/RDB structures preserve gameplay-relevant placement, references, building metadata, markers and action relationships, with explicit validated overrides permitted.
2. Repeated uses share reusable authored content while retaining independent live state and correctly scoped references.
3. Definition, placement and record identity are distinguishable; durable references do not rely solely on scene handles or archive byte offsets.
4. Missing/malformed/unsupported required blocks fail location preparation with explicit context rather than holes, substitutions or false readiness. Startup/index and contribution recovery retain DATA-002/003 rules.
5. Required action targets validate within permitted scope. Cycles/repeated links are preserved, with execution safety verified by the action owner.
6. Marker selection uses purpose and location context, preserving CORE-011's special start requirement rather than first-marker selection.
7. Unknown unused fields can be safely retained/skipped without exact-original-value enforcement; unsupported required types/actions fail explicitly.
8. Replaced-block save/quest references use verified compatibility or explicit mappings/migrations; incompatible changes produce truthful failure without guessed matches.
9. Representative exterior/dungeon/interior/repeated-placement fixtures verify transforms and marker/link targets; rendered similarity alone does not establish completion.
10. Source files remain unchanged, shared definitions exclude instance mutation, and source/configuration restart/lock rules remain intact.

These are future verification criteria. No implementation, original-data fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–004 and approved CORE lifecycle/readiness/start/load contracts, including CORE-005, CORE-007, CORE-011 and CORE-013. No contradiction identified. On-demand block decode preserves basic startup validation; required-location failures do not bypass readiness gates. Scoped identities refine DATA-004 location identity without assuming automatic save compatibility. Unknown unused fields remain compatible with acceptance of modified data while required unsupported behavior still fails. No implementation or coding tasks are authorized.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: supported block/action inventory; complete structural schemas and safe unknown-field rules; stable definition/placement/record ID mapping; permitted action-link scope/sentinels and execution safety; marker-purpose interpretation; coordinate conversion fixtures/tolerances; block-specific override schemas; missing resource requiredness; SAVE/LOC/QUEST compatibility/migrations. These deferrals do not waive preservation, explicit failure or verification criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-005-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including format coverage, marker/action interpretation, conversion fixtures and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.
