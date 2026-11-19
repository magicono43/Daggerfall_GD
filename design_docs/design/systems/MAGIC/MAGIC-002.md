# MAGIC-002 — Classic spell conversion

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Translate resolved original-game spell records into complete supported native spell settings without silently changing their authored effects, targeting or parameters.

## Intended player experience

Supported classic spells retain their intended composition. Unsupported or malformed spells report a meaningful conversion failure rather than becoming weaker, different or empty usable spells. Conversion prepares definitions; it does not teach, cast or apply spells.

## Confirmed requirements

MAGIC-002-D01–D06 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm initial classic target/element mappings, rejection of unsupported combinations, preservation of effect order/repetition, rejection of empty usable spells, component-aware parameter translation, explicit invalid-parameter failure and externally approved corrections. The complete specification is approved under MAGIC-002-A01.

Inherited approved requirements: DATA-011 establishes stable spell identity, disambiguated legacy references, complete conversion, correction provenance and save compatibility. MAGIC-001 establishes stable effect/variant identity, supported providers, side-effect-free inspection and a locked resolved registry. RULE-018 establishes explicit cost validation and separates empty drafts from valid spells.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; classic-data fixtures and runtime parity unverified. Reference source remains unchanged. Symbols below are in reference `Assets/Scripts/Game/MagicAndEffects/EntityEffectBroker.cs`.

- `ClassicSpellRecordDataToEffectBundleSettings` assigns bundle version/type, target/element, localized name, icons and classic index. It processes slots in order, skips type=-1 slots, skips failed effect conversions and succeeds if at least one effect converts.
- The converter changes spell index 10, slot 0, type=3/subtype=2 to type=26/subtype=-1 as a Free Action correction. This is source evidence, not approval of that correction.
- `ClassicEffectRecordToEffectEntry` resolves the effect template and translates supported duration/chance/magnitude components. `ClassicEffectRecordToEffectSettings` clamps their per-level divisors to at least one.
- `ClassicTargetIndexToTargetType` and `ClassicElementIndexToElementType` implement the mappings below; unknown indexes throw exceptions.
- `GetEffectTemplateFromClassicEffectRecordData` treats type=-1 as unused, converts negative subtypes to 255 and builds a byte-based classic key. Native validation must distinguish documented sentinels from invalid values rather than assume every negative subtype or truncating byte cast is valid.
- `AllEffectsImplemented` returns true when any effect maps, rather than requiring every active effect. It is not an adequate complete-support test.

## Detailed rules and behaviors

### Inputs, identity and ownership

Consume DATA's resolved spell record after approved baseline corrections and applicable mod/loose overrides. Preserve raw source/provenance separately. Conversion must not mutate shared source records, apply hidden corrections or change the locked content plan.

Use DATA-011 stable spell IDs and MAGIC-001 stable effect/variant IDs. Resolve classic type/subtype references through explicit validated mappings. Ambiguous classic spell indexes require contextual disambiguation under DATA-011; first-record order, names and numeric narrowing cannot silently select another spell/effect. Classic effect slot type=-1 is unused; complete supported subtype/sentinel domains require fixture verification.

### Target and element mappings

| Classic target index | Native interpretation |
| --- | --- |
| 0 | Caster only |
| 1 | By touch |
| 2 | Single target at range |
| 3 | Area around caster |
| 4 | Area at range |

| Classic element index | Native interpretation |
| --- | --- |
| 0 | Fire |
| 1 | Cold |
| 2 | Poison |
| 3 | Shock |
| 4 | Magic |

These are initial classic conversion mappings, not a limit on future native definitions. Unknown values or unsupported effect/target/element combinations fail conversion explicitly. Do not substitute self, magic or another supported combination. Detailed ranges, collision, area selection, delivery and resistance remain their owner features.

### Complete composition

Preserve authored active-effect order and repeated entries. Skip only format-defined unused slots; do not sort, merge or deduplicate active entries. Runtime admission and stacking remain MAGIC-006/009 responsibilities. Preserving repeated entries does not guarantee that their runtime effects stack.

Every authored active effect must map to a supported provider and supported parameters. If any fails, fail the whole runtime conversion without publishing a usable partial bundle. Support validation must check all active effects and relevant target/element/parameter constraints; finding one supported effect is insufficient.

Records with null/no effect data or only unused slots cannot become usable spells. Retain raw records for diagnostics under DATA ownership. A valid effect without duration/chance/magnitude components still counts as active; absence of scalable components does not make it empty, free or unsupported. RULE-018 owns its explicit fixed-cost contract.

### Component translation and validation

For each supported component, retain authored values through the following semantic translation. Native field names are illustrative rather than an approved API.

| Component | Classic inputs | Native meaning |
| --- | --- | --- |
| Duration | durationBase, durationMod, durationPerLevel | Base, increase, per-level divisor |
| Chance | chanceBase, chanceMod, chancePerLevel | Base, increase, per-level divisor |
| Magnitude | magnitudeBaseLow/High, magnitudeLevelBase/High, magnitudePerLevel | Base minimum/maximum, increase minimum/maximum, per-level divisor |

Copy these values only for components supported by the resolved effect definition. Preserve unused component fields in raw source without allowing them to affect execution or costs. Unused-component fields do not become active parameters merely because they contain nonzero data.

Invalid supported parameters fail conversion explicitly. Do not clamp a zero/negative scaling divisor to one, reverse endpoints, clamp values or supply guessed defaults to make conversion succeed. Positive divisors are required for supported scaling components under RULE-018. Other numeric ranges and endpoint constraints follow documented effect schemas; fixture-verify them before implementation. Valid zero duration, chance or magnitude remains legal wherever effect rules permit. Zero alone is not evidence of corruption.

Conversion preserves scaling inputs rather than evaluating them for the current player, rolling magnitude, computing final costs or starting duration. Runtime formulas, caster context and cost models remain their authoritative owners. No new normalization is approved by this specification.

### Corrections and failure reporting

Consume only documented individually approved corrections applied before mod overrides under DATA-011. No corrections are hidden inside conversion. The source Free Action patch and every other individual correction remain unapproved pending separate evidence/review. This draft approves no correction table.

Failures distinguish missing/ambiguous identity, unavailable provider, unsupported mapping/combination, malformed supported parameters and empty unusable records. Identify the spell/source, affected slot/effect and offending field or dependency where available. Diagnostic partial information may be retained, but it is not a usable reduced spell.

Use DATA-003 whole-contribution rejection and existing required-content recovery. This specification does not require eager decoding of every unrelated asset. A required starting grant or native-save dependency cannot bypass CORE-012/013 failure rules merely because the original record parsed successfully. Optional icon/text failure follows separately approved presentation policy, without concealing gameplay conversion failure.

## Relevant formulas and parameters

Mapping tables and component translation above define this adapter's parameters. Positive supported scaling divisors are validated, not silently normalized. No duration/chance/magnitude evaluation formula, random distribution, cast cost, universal native effect-count limit or baseline correction is approved here. Classic fixed slots are a source-format property, not a new native spell limit.

## Required data

Resolved stable spell ID; source record identity/provenance; explicit classic effect mappings and stable effect/variant IDs; slot order/unused markers; target/element indexes; supported-component metadata; authored parameter values; provider support; resolved corrections/overrides and diagnostics. Preserve source name/icon/stored-cost information under DATA contracts; display names do not define identity and stored cost is not automatically the runtime casting cost. Exact native bundle schema and presentation mapping remain dependencies.

## Inputs, outputs and events

Inputs: resolved classic record, explicit intended bundle context where required, validated effect registry and conversion/support requests. Outputs: a complete supported native definition or explicit failure with context. Conversion/support inspection has no gameplay side effects and must agree on whether a record is completely representable. It does not grant spells, consume resources, instantiate active timers or publish cast/application events. Exact APIs and signal names remain technical choices.

## Cross-system interactions

- DATA-011 owns source records, stable spell identity, classic collisions, corrections/overrides and raw provenance; DATA-003 governs contribution resolution and candidate rebuilds.
- MAGIC-001 supplies stable effect support/mappings and locked provider definitions. Rebuilt pre-menu candidates cannot reuse stale conversions from different resolved definitions.
- MAGIC-003–009 own readiness, casting, delivery, admission, evaluated effects and stacking. MAGIC-011–016 and ITEM consume valid definitions for offers/crafting/enchantments without bypassing their eligibility rules.
- RULE-018 owns costs and component-cost validation. CHAR supplies runtime caster attributes/skills under the relevant execution contracts; conversion does not silently use player state.
- CORE-012 gates required starting grants. SAVE/MAGIC/ITEM and CORE-013 validate learned-spell/item/active-effect compatibility for native restore. UI/AV own separately approved display fallback.

## Edge cases and failure conditions

- Two valid effects plus one unsupported active effect: fail the whole conversion, not a two-effect substitute.
- Unused slot between active effects: omit the unused slot while retaining active relative order and repeated entries.
- All unused slots: not a usable spell. A valid no-component effect: active and subject to its explicit cost/execution rules.
- Unknown target/element or valid indexes paired with an unsupported effect combination: explicit failure, no substitute.
- Zero divisor in a supported scaling component: failure; zero in raw unused-component data does not activate that component.
- Valid zero magnitude/chance/duration: preserve according to the effect schema rather than blanket rejection or repair.
- Unknown negative subtype/out-of-domain type: validate the documented format; do not alias another effect through permissive sentinel conversion or byte truncation.
- Changed mod order/provider definition before lock: rebuild/validate against the current candidate without stale mappings or corrected-source mutations.
- Original-data correction does not match approved faulty fields, or later override intentionally changes them: DATA-011 conditional correction/override rules remain authoritative.

## Configuration and balancing options

Supported classic fields form the resolved baseline under DATA-011. Mod additions/overrides require supported mappings and validated parameters. No player switch for partial conversion, hidden numeric repairs or guessed fallback effects is approved. Component balance, runtime scaling and crafting eligibility remain owner decisions; this adapter does not modernize or rebalance spells automatically.

## Save/load considerations

This feature converts definitions, not classic or DFU save files. Native learned/custom spell and active-effect state remains separate. Same spell/effect ID is not proof of semantic compatibility and does not authorize overwriting saved settings, restarting timers or dropping effects. Follow DATA-011, MAGIC-001 and CORE-013 compatibility/migration/failure requirements. Exact snapshots, versioning and migration representation remain SAVE/MAGIC dependencies.

## Technical constraints

Target Godot v4.7.2 without requiring Unity-specific broker classes or exceptions as public failure results. Keep parsing, resolved-content validation and conversion distinct. Preserve deterministic output for equivalent resolved inputs and mappings; conversion does not use random rolls or mutable player context. Reference source remains read-only. Exact schemas, caching, error types and numeric representations remain technical dependencies.

## Acceptance criteria

1. Every listed target/element index maps as specified; unknown or unsupported combinations fail without substitution.
2. Conversion preserves active-effect order/repetition and omits only documented unused slots.
3. Any required active effect/provider/parameter failure prevents usable output for the entire spell; the support check reaches the same complete-support conclusion.
4. Empty/all-unused records are unusable while a valid no-component effect remains active.
5. Supported component values translate as authored; unused component data remains nonoperative and available in raw source.
6. Invalid supported divisors fail without repair. Schema-valid zeros are preserved where permitted.
7. Conversion neither mutates shared raw/resolved records nor casts, rolls, grants, spends resources or advances timers.
8. Only individually approved pre-override corrections influence input; no Free Action correction is introduced implicitly.
9. Diagnostics identify failed spell/slot/field/provider where known without publishing a partial usable bundle.
10. Pre-menu candidate rebuilds invalidate affected conversion results; native load preserves approved compatibility and required-dependency safeguards.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved DATA-011, MAGIC-001 and RULE-018 specifications, inherited DATA-003/CORE-012/013 boundaries and MAGIC-002-D01–D06. No direct contradiction identified. Whole-spell rejection preserves DATA-011; component validation agrees with RULE-018 positive divisors and valid no-component costs. An empty authoring draft may have a zero quote under RULE-018 but remains uncastable; that does not make an empty classic record a usable converted spell. Identity, configuration lock and native save compatibility remain intact. Architecture recommendations remain proposals beyond explicitly confirmed decisions.

## Outstanding questions

No further blocking player-policy choice is identified for this conversion scope. Before implementation is complete, document and fixture-verify the full classic type/subtype/variant/sentinel mapping inventory, per-effect supported combinations/numeric domains, native schemas/context metadata, presentation references, provider compatibility and migration representation. Individual baseline corrections still need separate verification and approval. These dependencies do not permit silent repairs, dropped effects or guessed mappings.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-002-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented mapping/validation fixtures, schemas, provider compatibility and migration dependencies remain open. Individual baseline corrections still require separate verification and approval. Approval does not initiate implementation, coding tasks or another feature review automatically.
