# DATA-017 — Name-bank selection

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Provide validated name banks, composition patterns and explicit selection mappings for character, NPC, place and quest consumers without conflating generated names with durable identity.

## Intended player experience

Supported classic naming content and validated additions produce names appropriate to explicitly selected context. Assigned persistent names survive saves and language changes, even after bank edits. Missing data fails clearly rather than silently selecting an unrelated culture. Previewing names does not change future gameplay generation.

## Confirmed requirements

DATA-017-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish extensible stable bank IDs/mappings; persistent assigned names and independent entity identity; supported classic composition with owned generation; validated required components and meaningful text preservation; future-only bank-change effects; and isolated previews with contextual diagnostics.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Utility/NameHelper.cs#LoadNameGenData` reads packaged Resources/NameGen, optionally replaced by StreamingAssets/Text/NameGen.txt, and deserializes a bank dictionary. Exact source provenance/content fidelity remains to verify.
- `NameHelper#BankTypes`, `NameBank` and `NameSet` represent fixed enum banks and component arrays. FirstName/Surname/FullName use bank-specific composition. Many banks combine two first-name parts and surname parts; Redguard composition differs, and FullName omits an empty surname.
- Component selection uses DFRandom. Monster-name selection additionally draws a bank using UnityEngine.Random. Null bank data can return empty names, while some dictionary/component accesses assume valid populated inputs.
- `API/MapsFile.cs#GetNameBankOfRegion` maps region data to banks and defaults negative region input to Breton. `Utility/MacroHelper.cs#GetNameBank` maps races, including Argonian to Imperial, with Breton as default. These are reference rules, not approved target mappings.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Complete bank provenance, seeded parity and consumer-specific persistence were not verified. Source remains unchanged.

## Detailed rules and behaviors

### Bank identity and selection

Use stable name-bank IDs with explicit mappings from race, stable region identity or caller purpose. Mods may add banks and supported patterns without extending a classic-only enum. Preserve classic mappings in adapters where supported, but do not assume every observed race/region association is approved gameplay policy.

Missing mappings require an explicitly declared fallback or explicit failure, not automatic Breton selection or an unrelated current-region lookup. Do not silently retry another culture's bank. Owners must define selection precedence when multiple contextual mappings could apply. DATA supplies mappings and validation without inventing demographic distributions or selection weights.

Apply DATA-003's declared operations, ordering, provenance, whole-contribution validation/recovery and pre-menu lock. Additions require unused domain identity; replacements target explicitly. Actual main-menu entry locks installed bank data/mappings under the content plan. External edits and source changes retain approved restart rules.

### Supported composition and validation

Supported classic name parts and composition patterns form the overridable baseline. Exact race/region mapping, gender-conditioned pattern interpretation, generation probabilities and classic parity remain owner review rather than automatic importer approval.

Validate required component sets, supported rules and mapping references before publishing usable banks. Intentionally absent surname is valid when the pattern declares it. An accidentally empty required set is invalid rather than an empty successful name or a modulo-zero hazard. Unsupported required pattern behavior fails explicitly.

Preserve authored Unicode, punctuation and spacing under the pattern's rules. Do not universally split names on a single space or assume every culture has a first name plus surname. Exact component joining, normalization and display/glyph support must be documented and verified. Composition patterns are supported data contracts, not permission to execute arbitrary code.

Report bank, pattern and missing component/mapping context on failure. DATA-002's missing/unavailable/malformed distinctions and DATA-003 contribution recovery remain binding. Required actor/quest naming failure uses the requesting owner's recovery; optional unnamed behavior is permitted only by an explicit owner contract.

### Generation and previews

Generation uses an explicitly owned random source or deterministic identity rule. Reading banks, displaying assigned names or refreshing language does not reseed or consume shared gameplay randomness. This does not choose a universal RNG algorithm, seed allocation scheme or deterministic replay requirement for every consumer.

Author previews use isolated test seeds/random sources. Repeated preview must not alter future gameplay names or other simulation outcomes. Preview output is not an assigned live identity; owner commitment establishes assignment.

### Persistent assignment and bank changes

Retain a generated name for its owning persistent person, place or quest resource across saves and locale changes. Stable entity identity is separate from the name; duplicate names are allowed. No uniqueness reroll is implied. Localization can change presentation only through an explicit supported policy without regenerating identity or rerolling components.

Bank edits affect future generation while preserving names already assigned to persistent entities. If seeds reconstruct names, SAVE/domain owners must retain results or enough versioned algorithm/bank data to prevent silent renaming after a change. Seed alone is not sufficient when bank order/content or generator behavior changes.

DATA-016 message expansion reuses prepared assigned/retained values rather than generating a new persistent name during rendering. Ownership and lifetime must distinguish a persistent actor name, a temporary message value and an uncommitted author/character-creation preview. Exact nonpersistent regeneration rules remain owner contracts.

## Relevant formulas and parameters

No generation weights, uniqueness constraints, gender distribution, race mapping table, RNG algorithm or numeric seed/ID width is approved here. Classic component-combination patterns are baseline content to verify, not a requirement to duplicate shared random-state coupling. Supported patterns must declare required/optional components and joining behavior.

## Required data

Stable bank/pattern identity; component sets and optionality; composition/join rules; explicit race/region/purpose mappings and fallback; source/package provenance; validation results; generation source/context; assigned name and owning identity; versioned reconstruction information where chosen. Exact schema, algorithm versions and persistence representation remain dependencies.

## Inputs, outputs and events

Inputs: validated bank contributions/mappings, explicit caller context, requested pattern/category and owned generation/test source. Outputs: selected bank/pattern, generated components/name or explicit missing/unavailable/invalid/unsupported failure with provenance. Assignment is owner-controlled and distinct from generation. These are conceptual contracts, not concrete APIs/signals. A name request does not spawn an actor, create a quest resource or replace an existing assigned name.

## Cross-system interactions

- DATA-003 controls content resolution and activation. DATA-004 region identity and DATA-006 expanded-world support prevent classic region arrays from becoming universal new-content limits.
- CHAR/NPC/QUEST and place owners choose context, assign/retain names and define requiredness. FACT/ruler systems retain their own identity/change policy; a new ruler is not merely a text-refresh reroll.
- RULE/owners define random/deterministic generation contracts. DATA-016 consumes prepared names without rendering-driven generation or shared reseeding.
- DATA-013/UI/AV/font owners define optional localized presentation and glyph coverage without changing identity. SAVE/domain owners preserve assigned names and compatibility under CORE load contracts.
- MOD owns executable extensions; supported data patterns do not imply arbitrary script execution.

## Edge cases and failure conditions

- New mod bank/expanded region: explicit stable mappings work without classic enum/region-index limits.
- Missing mapping: declared fallback or failure; no unrequested Breton/cross-culture retry.
- Pattern intentionally omits surname: valid single-component/full-name result. Required component empty: invalid bank, not successful empty output.
- Same generated name for distinct entities: allowed; identity remains distinct and no automatic uniqueness reroll occurs.
- Bank/component ordering changes: future generation may differ but persistent assigned names remain stable.
- Locale changes: no reroll or identity replacement; optional presentation changes require an explicit policy.
- Repeated author preview/message rendering: isolated previews and retained assigned values leave gameplay randomness unchanged.
- Seeded restoration under changed bank/generator: validate versioned reconstruction or retained result; do not silently regenerate a different name.

## Configuration and balancing options

Validated bank/pattern additions and explicit mappings are supported. Owners review generation distributions and selection options. No automatic missing-bank fallback toggle, universal uniqueness policy or live bank-reload setting is approved. Supported runtime settings retain their contracts without unlocking installed definitions.

## Save/load considerations

Preserve assigned persistent names independently of changed bank data and localized display. Save retained results or sufficient versioned reconstruction data under owner schemas; seed-only restoration must not rename entities after content changes. Loads must not consume unrelated gameplay random draws to repair missing data. Custom/player-entered name validation and historical presentation policies remain CHAR/UI/SAVE contracts rather than new requirements here.

## Technical constraints

Target engine: Godot 4.7.2. Separate reusable banks, explicit selection, owned generation, previews and persistent assignment. Keep original inputs read-only and candidate rebuilds coherent. Concrete IDs, schemas, RNG plumbing, Unicode normalization, caches and save representation remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable extensible bank IDs/mappings support validated additions without classic-only enum or region limits.
2. Missing mapping uses declared fallback or failure, with bank/pattern/context diagnostics rather than silent cultural substitution.
3. Required sets/rules/references validate before publication; intentionally absent surname is valid and empty required sets fail.
4. Supported classic content remains the overridable baseline, preserving authored Unicode/punctuation/spacing under explicit patterns without implicitly approving mappings/probabilities.
5. Owned random/deterministic generation and isolated previews leave shared gameplay randomness unchanged during reads/display/refresh.
6. Persistent assigned names survive saves, locale and bank edits; duplicate names do not merge identities or trigger an implicit uniqueness reroll.
7. Reconstruction retains results/versioned data sufficient to prevent changed banks silently renaming existing entities.
8. DATA-016 rendering reuses retained context rather than assigning new persistent names; content lock and read-only source rules remain intact.
9. Representative missing/empty/optional-component, Unicode, extended-bank, isolated-preview and changed-bank save fixtures verify contracts before implementation is complete.

These are future verification criteria. No implementation, source-bank fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–016 and approved CORE lifecycle/load contracts. No contradiction identified. Persistent names remain separate from DATA-004/007 entity identities; extension support does not impose classic numeric ranges. Retention complements DATA-016's message-lifetime values without claiming every transient message is a persistent entity. Live locale presentation does not reload bank definitions or reroll generation. SAVE retains explicit compatibility responsibility.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: verified bank provenance/content; stable ID and pattern schema; contextual mapping/precedence/fallback rules; category/gender/join semantics; generation weights/RNG/parity; assignment lifetimes; localized presentation/glyph rules; versioned reconstruction/save migration and representative fixtures. These deferrals do not waive explicit selection, isolated previews or retention of assigned persistent names.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-017-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including naming patterns/mappings, randomness, localized presentation and versioned persistence. Approval does not initiate implementation, coding tasks or another feature review.
