# DATA-011 — Classic spell records and patches

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Supply identifiable standard spell records and complete conversion inputs for MAGIC, item, quest and save consumers. Preserve distinct classic content, explicit correction provenance and truthful failure when a spell cannot be represented as authored.

## Intended player experience

Supported original and validated added spells resolve consistently. A spell does not silently lose one of its effects during conversion. Deliberate mod overrides remain authoritative over approved baseline corrections. Renaming does not change identity, and changed content does not silently erase saved spells or active effects.

## Confirmed requirements

DATA-011-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish stable spell identity and explicit legacy disambiguation; complete active-effect conversion; DATA/MAGIC ownership boundaries; preservation of colliding classic records; conditional documented baseline corrections before overrides; and explicit saved-spell/item/active-effect compatibility checks.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Utility/DaggerfallSpellReader.cs#ReadSpellsFile` reads SPELLS.STD in 0x59-byte records. Fields include effect types/subtypes and duration/chance/magnitude inputs, element, range, stored cost, name, icon and byte-sized index. It returns null for missing/load failure and can return accumulated records after parse problems. Its complete-record loop does not itself reject a trailing incomplete record.
- `Game/MagicAndEffects/EntityEffectBroker.cs#RebuildClassicSpellsDict` reads records, merges SpellRecords.json by classic index, then skips later duplicate indexes. A comment identifies Holy Touch and Holy Word as sharing an index with different properties. Actual original/modified fixtures still require verification.
- `ClassicSpellRecordDataToEffectBundleSettings` maps target/element and effects, skips unused slots, and also skips effects that fail mapping. It succeeds if at least one effect converts, so success does not establish preservation of every authored effect.
- That converter contains a targeted Free Action correction for spell index 10/effect zero when its type/subtype match a known faulty pair. It is reference behavior, not an approved individual correction here.
- `ClassicEffectRecordToEffectSettings` translates supported duration/chance/magnitude parameters and clamps some per-level divisors to at least one. Those normalization rules and runtime formulas require MAGIC validation rather than automatic adoption.
- `AllEffectsImplemented` returns true when at least one effect maps, despite its name. It is not sufficient evidence of complete spell support.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Full spell/patch inventory, colliding records and correction fixtures have not been verified. Source remains unchanged; source observations do not approve classic/DFU save import.

## Detailed rules and behaviors

### Identity and legacy collisions

Use stable spell IDs independent of display names, list positions and classic byte-sized indexes. Preserve explicit source/classic mappings and support validated mod additions without imposing legacy index limits on new definitions. Native quest, item and save references use stable IDs. Display text and localization changes do not alone change identity.

Preserve colliding classic source records under distinct stable IDs rather than discarding a later record. Lookup by a shared classic index reports ambiguity unless an explicit contextual mapping identifies the intended spell. Do not silently use first-record order, name guessing or last-write precedence to resolve an insufficient legacy reference.

Record identity assignment and contextual mappings must be documented and fixture-verified. A known one-to-many legacy index is permitted as an explicitly ambiguous mapping, unlike an accidentally ambiguous mapping published as if it were unique. Required references must resolve unambiguously before their consumers are ready. Insufficient context must produce failure/review rather than arbitrary selection.

### Baseline, corrections and patches

Supported classic fields form the initial baseline with explicit validated overrides. DATA reads and converts definitions without casting or mutating shared source records. Retain raw source/provenance separately from corrected/resolved definitions.

Approved classic corrections are documented baseline patches applied before enabled mod and explicit loose overrides. Each correction must match expected faulty data so externally modified content is not accidentally rewritten. Later intentional overrides win under DATA-003. This mechanism does not approve Free Action or any other individual correction; each requires evidence and explicit approval.

DATA-003 governs domain/path identity, declared add/replace/patch operations, deterministic ordering, provenance and whole-contribution rejection. Patch targeting must use a stable or explicitly disambiguated target, not a shared classic index that could affect the wrong record. Explicit replacement is distinct from an invalid duplicate-ID addition. Preserve contributor/field winners so correction and later patch effects remain diagnosable.

### Complete conversion and validation

Separate parsing, resolved definition validation and runtime conversion. A successfully decoded classic record is not proof its effects/target/element are implemented. Validate supported interpretation and required references before declaring the spell usable.

Every authored active effect must have a supported mapping. If any active effect cannot convert, reject the spell's runtime conversion as a whole; do not publish a usable reduced bundle or silently omit that effect. Format-defined unused slots remain valid and are not missing active effects. Exact empty-spell legality is a MAGIC/schema dependency, not a newly approved no-op spell type.

Unknown required types, unsupported required parameters and unresolved targets return explicit failure. Differentiate not found, ambiguous legacy lookup, unavailable source and malformed/unsupported data. Schema-valid zero values and unused sentinels must not be confused with corruption; exact field constraints and normalization remain owner contracts. No automatic per-level divisor fix or target/element substitution is approved here.

Required resolved spell/reference validation follows DATA-002/003 readiness and recovery. This does not require decoding every unrelated asset at startup. An invalid contribution cannot be partially applied; explicit continuation without it is allowed only when remaining required content validates. Required startup spell/grant failure retains CORE-012 behavior. Optional icon/text absence uses only separately approved presentation fallback and cannot hide unsupported active effects.

### MAGIC ownership

MAGIC owns casting costs, scaling, stacking, targeting behavior and execution. DATA preserves source parameters and supported translations rather than selecting new balance formulas or executing effects. Stored classic cost is an input, not approval that it is the final runtime casting cost. Numeric normalizations, ordering semantics and effect-provider support must be established by MAGIC before conversion is considered complete.

Reusable spell definitions remain separate from learned-spell state, crafted/custom spell state and active effect instances. DATA conversion does not grant spells, tick effects or restart timers. Mod effect-provider registration/lifecycle remains MOD/MAGIC-owned; declaring an effect key alone does not make it executable.

### Changes and compatibility

SAVE/MAGIC explicitly validate learned spells, enchanted-item references and active effects after definition changes/removal. ITEM participates where item-owned references/state are involved. Retaining the same spell ID does not authorize replacing saved parameters, restarting effects or dropping unsupported portions.

Unsupported changes require an explicit supported migration or failure outcome. Do not substitute by name, silently remove effects or reapply a spell to make loading succeed. Exact snapshot-versus-definition interpretation and migration rules remain owner dependencies. Stable identity supports lookup but is not proof of semantic compatibility.

Resolve mod data during DATA-003's editable pre-menu configuration stage and lock it at actual main-menu entry. Classic source switching/external edits retain DATA-001/002 restart rules. Rebuild spell mappings/conversions for the appropriate candidate so stale results do not survive a changed patch order.

## Relevant formulas and parameters

Classic record size 0x59 and byte index limits describe the source format, not new-definition constraints. No casting-cost formula, duration/chance/magnitude arithmetic, effect count limit for new formats, normalization constant or correction table is approved here. Supported target/element/effect mapping and unused-slot interpretation must be documented with MAGIC and verified against fixtures.

## Required data

Stable spell IDs; source-record and classic/contextual mappings; names/localization and icon references; active effects and unused-slot markers; source duration/chance/magnitude, range/element and stored cost fields; supported effect keys/parameters; conditional correction rules and approval provenance; resolved contributors/winners; validation/conversion outcomes. Learned/custom/active instance state remains owner-managed. Full schemas and mapping inventories remain dependencies.

## Inputs, outputs and events

Inputs: classic records, approved correction rules, mod/loose contributions, stable/legacy lookup requests with available context and conversion requests. Outputs: resolved definitions, complete converted settings or explicit missing/ambiguous/unavailable/malformed/unsupported failure, with source/effect context. These are conceptual contracts, not concrete APIs/signals. Conversion success is not spell acquisition, casting or effect application.

## Cross-system interactions

- DATA-001/002 provide source/readiness/failure contracts; DATA-003 supplies patch resolution and configuration lock. DATA-010 magic-item references must resolve to stable/disambiguated spell identities rather than silently selecting a classic collision.
- MAGIC owns effect support, formulas and execution; MOD/MAGIC own provider registration/lifecycle. UI/AV/text owners provide approved optional presentation fallback.
- CHAR/CORE-012 apply starting grants through authoritative owners without duplicates. Missing required spell definitions prevent successful entry; legitimate no-spell grants remain valid.
- QUEST and ITEM use stable spell references and validate required content. SAVE/MAGIC/ITEM own restored learned spells, enchanted items and active effects under CORE-013's safe load contracts.

## Edge cases and failure conditions

- Holy Touch/Holy Word-style shared index: preserve separate records; index-only lookup is ambiguous until an explicit mapping resolves it.
- Patch names a colliding legacy index without sufficient context: reject ambiguous targeting rather than patching whichever record was first.
- Two effects convert and one active effect does not: reject the whole conversion, not a two-effect substitute. Unused slots do not count as failures.
- Known-fault correction matches original faulty fields: only an individually approved correction may apply. Modified fields that no longer match are not overwritten; later intentional overrides retain priority.
- Source parses but target/element/provider/parameters are unsupported: no false usable-definition result. Optional icon absence is a separate presentation issue.
- Trailing/truncated or malformed source data: decoder policy must report invalid required content under declared format rules, not claim full integrity from accumulated partial records.
- Candidate rebuild changes patches: mappings, provenance and converted caches reflect the new candidate only.
- Saved active effect uses a changed definition: explicit compatibility/migration or failure, without restarting duration or silently losing an effect.

## Configuration and balancing options

Validated spell additions/replacements/patches follow declared schemas. No partial-conversion toggle, silent collision winner or automatic correction of arbitrary modified spells is approved. MAGIC owns balancing/configuration options. Supported runtime mod settings do not unlock DATA-003's resolved definition plan.

## Save/load considerations

Use stable spell references and owner-defined saved parameters/state. Native saves do not rely solely on ambiguous classic indexes. Loads restore rather than cast/grant/restart spells; content changes require owner compatibility checks. Exact custom-spell schema, effect instance snapshots, versioning, migrations and legacy-import policy remain SAVE/MAGIC dependencies. This feature does not approve classic-save import.

## Technical constraints

Target engine: Godot 4.7.2. Separate source decoding, conditional baseline corrections, patch resolution, complete conversion and execution. Keep raw sources/read-only definitions free from converter mutation. Publish coherent candidates and truthful outcomes. Concrete registries, contextual mapping representation, parser/provider APIs and cache strategy remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable spell identity survives name/list changes and supports additions beyond classic byte-index limits, with explicit legacy mappings.
2. Colliding classic records are preserved separately. Insufficient index-only lookup/patch targeting reports ambiguity rather than dropping or arbitrarily selecting a record.
3. Every active effect converts or the whole conversion fails. Unused slots remain valid; no reduced spell is reported as successful.
4. Supported source fields form the overridable baseline while MAGIC retains costs/scaling/stacking/targeting/execution authority.
5. Only verified/approved documented corrections apply, conditional on expected faulty data and before mod/loose overrides. Later intentional overrides win.
6. Required failures and invalid contributions follow DATA-002/003 and CORE-012 rules; optional presentation fallback does not excuse missing active effects.
7. Conversion does not cast, grant, mutate shared sources or restart effects. Candidate rebuilds do not reuse stale mapping/conversion results.
8. Learned-spell/item/active-effect compatibility uses explicit migration or failure when unsupported, without substitution, saved-parameter reset or silent effect loss.
9. Original sources and content-lock/restart contracts remain intact. Representative collision, modified correction, partial-effect, malformed and changed-save fixtures verify these rules before implementation is complete.

These are future verification criteria. No implementation, original-data fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–010 and approved CORE startup/load contracts, especially CORE-012/013. No contradiction identified. Explicitly represented legacy collisions are not uniquely resolved mappings and cannot satisfy a required unambiguous reference without context. Baseline corrections precede DATA-003 overrides rather than defeating later intentional patches. Complete conversion strengthens truthful required-reference validation and retains MAGIC ownership and SAVE compatibility responsibilities.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: verified source spell/collision inventory; stable source-record identity and contextual mapping rules; complete target/element/effect/parameter schemas; unused/empty/zero/trailing-data validation; individual classic correction evidence/approval; MAGIC formula/provider contracts; optional presentation policy; SAVE compatibility/migrations and representative fixtures. These deferrals do not waive preservation of colliding content, complete conversion or explicit failure.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-011-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including mapping schemas, individual classic correction approval, MAGIC rules and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.
