# DATA-007 — Flat and encounter definition lookup

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Resolve supported classic object and monster metadata into definitions and explicit references for placement, NPC, presentation and other consumers. Keep source lookup separate from deciding encounters, executing behavior or creating mutable instances.

## Intended player experience

Original supported metadata provides the baseline, and validated mods can add definitions or replace appearances without accidentally changing unrelated gameplay. Missing required definitions produce clear failures; optional presentation gaps use only explicitly approved fallbacks. Reusing a sprite does not make characters share identity or state.

## Confirmed requirements

DATA-007-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm supported classic metadata with owner-separated gameplay rules; stable domain IDs and explicit legacy mappings; explicit appearance/gameplay links; required-versus-optional failure distinctions; unambiguous mappings with explicit replacements; and safe handling of unknown fields without invented meanings.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Utility/ContentReader.cs#SetupReaders` creates FlatsFile, MonsterFile and PaintFile alongside other readers. Facade construction does not establish every record's completeness or gameplay authority.
- `API/FlatsFile.cs` parses FLATS.CFG into archive, record, caption, gender, two unknown fields and faceIndex. `GetFlatID` computes `(archive << 7) + record`; `ReverseFlatID` uses a seven-bit record mask. This is a legacy representation, not an approved restriction on new definitions. Parsing keeps the first duplicate key; lookup overloads differ between a boolean result and direct dictionary indexing.
- `Game/StaticNPC.cs#SetLayoutData` uses flat metadata to correct exterior NPC gender information. `Game/TalkManager.cs` resolves portraits from faction-associated flats and then more specific target billboard metadata, with a default portrait in that flow. These are consumer-specific behaviors, not universal fallback requirements.
- `API/MonsterFile.cs` opens MONSTER.BSA, exposes raw records and decodes ENEMYxxx.CFG career records through ClassFile. The reader explicitly states it is incomplete; its animation-related MonsterANC structure is empty and its meaning not established there. This does not prove all enemy runtime properties originate in MONSTER.BSA.
- `API/PaintFile.cs#Read` returns fixed 40-byte PAINT.DAT records. `Game/Items/DaggerfallUnityItemMCP.cs#InitPaintingInfo` consumes them for painting descriptions and includes a targeted in-memory correction for one known record. Painting content is not encounter selection; that correction and description-generation algorithm are not automatically adopted here.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete enemy-property provenance, original fixtures and runtime behavior have not been verified. Source remains unchanged.

## Detailed rules and behaviors

### Definition scope and ownership

Preserve supported classic metadata and references as the original-content baseline. Incomplete readers and undocumented fields do not constitute a complete gameplay specification. NPC behavior, encounter selection, spawning, combat balance and painting-description generation remain with their owners. DATA exposes supported records and provenance without inventing missing rules.

Keep reusable definitions separate from live NPC/monster/item instances and their mutable state. DATA-005's placement/record context identifies where a definition is used; definition lookup alone does not spawn an entity, award loot, assign a new faction or execute AI.

### Stable identity and appearance

Use stable, domain-scoped definition IDs with explicit mappings from applicable classic archive/record pairs and monster identifiers. Treat packed flat IDs as legacy adapter values rather than universal identity limits. Mods may add definitions beyond that packing scheme through supported schemas. Exact key encoding, namespaces and allocation remain technical dependencies.

Changing a portrait or sprite alone does not change NPC/monster definition identity. Link appearance definitions and gameplay definitions explicitly. Multiple gameplay definitions may deliberately share one appearance without sharing faction, stats, behavior or live state. Conversely, appearance sharing must not introduce ambiguous legacy lookup; an appearance lookup cannot arbitrarily choose among several gameplay definitions.

Reject ambiguous classic-ID mappings and duplicate definition IDs. Explicit valid replacement retains the applicable identity under DATA-003; an add collision remains invalid. Keep domain identities distinct so identical raw values in different domains do not silently alias.

### Resolution and validation

Apply DATA-003's declared content operations, deterministic precedence, provenance, whole-contribution rejection and explicit invalid-contribution recovery to applicable definitions. Resolve required definitions/mappings coherently before normal entry as required by DATA-002/003, without requiring every record or media asset to be decoded eagerly. Runtime lookup retains DATA-002's distinctions between not found, source unavailable and malformed/unsupported data.

Validate references against the definition type and consumer contract. A newly declared creature ID is insufficient if its required gameplay definition or supported interpretation is missing. Visual replacements must not implicitly overwrite unrelated gameplay fields; intentional gameplay patches require their declared domain operation.

Unknown classic fields may be preserved or safely skipped only where supported behavior is unaffected. Required unsupported semantics fail explicitly. Document uncertainty and source fields rather than assigning guessed meanings. A modified unused field alone is not grounds for rejecting otherwise supported data under DATA-001's policy.

### Required data and optional presentation

Classify requiredness through the consuming feature's contract. Missing required monster/gameplay definitions fail the affected spawn or preparation; DATA must not synthesize stats, gender, faction or behavior to claim success. Startup reader failure and later record/preparation failure retain their distinct recovery boundaries.

Missing optional presentation metadata may use an explicitly approved NPC/UI/AV fallback. No fallback portrait, assumed gender, generic actor or automatic enemy omission is approved by this specification. A missing record can be legitimate for an optional query without becoming a malformed record. Consumers must receive the distinction and apply their own policy.

Painting-record access remains an ancillary data source in this catalog scope. ITEM/text owners must define description interpretation, known-data correction policy and fallback independently; this feature neither turns painting data into encounter content nor requires copying DFU's targeted correction.

## Relevant formulas and parameters

Legacy flat conversion: `flatID = (archive << 7) + record`; reverse uses `archive = flatID >> 7` and `record = flatID & 0x7f`. Adapter validity/range checks must prevent invalid inputs from aliasing other pairs. New definition IDs are not constrained by this packing. PAINT.DAT's observed 40-byte record size belongs to its classic format, not all new content. No encounter weights, combat values, spawn counts or fallback constants are approved here.

## Required data

Domain definition IDs; appearance IDs/resource references; explicit appearance/gameplay links; scoped classic mappings; supported flat captions/portrait and other metadata; supported monster-career source fields; ancillary painting record identity/data; source/package provenance; reference validation and differentiated lookup outcomes. Full schemas, code-defined enemy-property provenance, optionality and supported format inventories remain dependencies. Live entity identity and state remain owner-managed.

## Inputs, outputs and events

Inputs: classic files/record requests, validated definitions and overrides, stable or legacy lookup keys and consumer context. Outputs: typed supported metadata/definitions, explicit appearance/gameplay references, provenance and missing/unavailable/invalid/unsupported failures. These are conceptual contracts, not concrete API or signal names. Successful definition lookup is not an encounter/spawn notification or actor-ready event.

## Cross-system interactions

- DATA-001/002 retain source validation, read-only access, reader readiness and failure reporting. DATA-003 controls applicable definition resolution, pre-menu rebuild and run-long content lock.
- DATA-004/005 supply location and placement/record context without conflating those references with shared definition identity.
- NPC owns identity interpretation, behavior and NPC-required metadata; COMBAT/CHAR and other relevant owners define enemy statistics/careers and their source composition.
- LOC/WORLD and encounter owners select/place instances using explicit definitions. Spawn probability, level scaling, encounter eligibility and actor initialization are outside this feature.
- AV/UI use appearance/portrait references and only approved fallback rules. Appearance does not authoritatively establish faction, stats or behavior.
- ITEM/text owners interpret painting descriptions. SAVE/domain owners restore mutable state and validate replaced/missing definitions; stable identity alone does not prove save compatibility. MOD owns package/executable lifecycle.

## Edge cases and failure conditions

- Different gameplay definitions share a sprite: preserve distinct gameplay IDs/state and unambiguous legacy mappings.
- A sprite/portrait is replaced while gameplay identity remains stable: update only the explicitly targeted presentation fields; do not infer faction or stat changes.
- Invalid classic archive/record input would collide through packing: reject invalid adapter input rather than mapping it to another definition. New supported IDs need not fit classic packing.
- Duplicate IDs or ambiguous mappings arise: reject invalid configuration/contribution under DATA-002/003 rather than first-entry/last-entry dictionary accident. Explicit replacements remain valid operations.
- Optional portrait metadata is absent: report absence and let an approved owner fallback apply. Required monster data absent/unsupported: fail affected work without silently inventing a generic actor.
- Unknown unused fields differ in modified data: safely retain/skip under documented format rules; unsupported required interpretation still fails.
- Original record decoding succeeds but required supplemented gameplay fields are unavailable: do not claim the actor definition is complete. Domain validation must establish readiness.
- Old saves reference removed/replaced definitions: report identity/reference context to SAVE and owners; do not guess matches from appearance or name.

## Configuration and balancing options

Validated definitions can be added/replaced/patched under declared domain schemas and DATA-003 activation rules. Supported in-game mod settings retain their own contracts without unlocking the definition plan. This feature introduces no balancing settings, encounter frequencies or automatic fallback toggle.

## Save/load considerations

Persist stable domain references and owner-defined mutable instance state, not shared-definition mutations or sprite-only identity. Loading does not change the locked content plan. Presentation changes alone do not create new gameplay identities, but required-field or semantic changes still need owner compatibility validation. SAVE/NPC/COMBAT/ITEM must define missing-definition recovery and migrations; this feature approves neither automatic actor replacement nor stat reset.

## Technical constraints

Target engine: Godot 4.7.2. Separate classic parsing, reusable definitions, appearance resources and gameplay instances. Keep source inputs read-only and outcomes truthful. Expose validated data without requiring mutable public dictionaries or coupling content decode to save restoration. Concrete schemas, APIs, namespace format, caches and decoder libraries remain implementation choices. Broader architectural proposals are not approved wholesale.

## Acceptance criteria

1. Supported classic metadata/references form the baseline, with uncertainty documented rather than incomplete readers treated as complete behavior.
2. Stable domain IDs and explicit classic mappings support mod definitions beyond classic flat packing, without ambiguous/invalid adapter aliasing.
3. Appearance changes alone preserve NPC/monster definition identity; shared appearance does not merge behavior, faction, stats or live state.
4. Duplicate IDs and ambiguous legacy mappings fail validation; explicit replacements and intentional appearance sharing follow declared operations.
5. Lookup distinguishes missing, unavailable and malformed/unsupported outcomes. Required gameplay definition failure prevents affected spawn/preparation without invented defaults.
6. Optional presentation absence uses only an approved owner fallback; DATA does not invent portrait/gender/faction/stat policies.
7. Unknown fields are retained/skipped safely only when supported behavior is unaffected; required unsupported semantics fail explicitly.
8. Definition access remains distinct from encounter selection, AI, spawning, combat balancing and painting-description generation.
9. Source/readiness and content-resolution/lock rules remain intact, original files remain unchanged, and reusable definitions do not contain instance mutations.
10. Representative original, modified, duplicate/missing and unsupported-definition fixtures verify mappings and owner-required references before implementation is complete.

These are future verification criteria. No implementation, original-data fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–006 and approved CORE lifecycle/spawn/load contracts, particularly CORE-005, CORE-013 and CORE-020. No contradiction identified. Domain definitions refine placement references without replacing them; lookup does not become a fresh-spawn event. Modified-data acceptance preserves truthful unsupported-data failure. Optional fallback remains owner-approved, and DATA-003 replacements do not excuse ambiguous mappings or add collisions.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: complete consumer/source inventory; source versus code-defined enemy-property provenance; supported metadata schemas and unknown-field rules; namespace/classic-key validity/mappings; requiredness and optional fallback under owners; appearance/gameplay reference validation; painting correction/interpretation policy; representative format fixtures; save compatibility/migrations. These deferrals do not waive explicit identity, ownership or failure criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-007-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including consumer coverage, enemy-property provenance, metadata schemas and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.
