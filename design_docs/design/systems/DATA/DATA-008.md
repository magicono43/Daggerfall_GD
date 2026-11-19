# DATA-008 — Class and biography data

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Supply supported class/career and biography definitions for character creation and new-character initialization. Preserve clear identity and validated effect inputs without coupling data reads to mutations of a live player.

## Intended player experience

Choose from supported classic or validated added class/biography content. Revisiting answers does not multiply rewards. Translation and content reordering do not change the identity of choices. Missing required effects produce a useful failure rather than a partially initialized character; preview and final application use consistent rules without promising disclosure of every randomized outcome.

## Confirmed requirements

DATA-008-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm DATA-owned decoding/validation with owner-applied effects; stable IDs and extensible question sets; supported classic baseline with owner-reviewed balance; explicit CHAR-owned custom-class biography selection; invalid required-effect rejection before mutation; and consistent isolated preview/final rule evaluation.

Inherited CORE-012 requirements remain binding: biography effects precede starting grants; progression baseline capture follows initial skill changes; required biography/effect failure prevents entry; successful startup steps must not duplicate rewards; failed-entry retry uses clean replacement; save loading restores state without rerunning fresh grants.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `API/ClassFile.cs#Load` reads CLASS*.CFG files or a BinaryReader positioned at career data, including enemy-career records. Its reader decodes resistance/ability flags, equipment restrictions, skill groups, class name, hit points per level, advancement multiplier and attributes into `API/DFCareer.cs` structures. Some source fields remain unknown.
- `API/BiogFile.cs` loads packaged `StreamingAssets/BIOGs/BIOG{classIndex:D2}T{biographyIndex}.TXT` using the character document. It parses a fixed question set, answers and string effect commands; it also supports a backstory-string-ID header and accumulates narrative/reputation inputs.
- `BiogFile#ApplyEffects` dispatches effects to a live PlayerEntity. `GetSkillEffects` separately extracts skill changes. Parsing, preview-related evaluation, narrative construction and live application are therefore not wholly separated in this source class.
- `BiogFile#GetClassAffinityIndex` scores overlap with classic class skill lists. Its initial selection is index zero; strict greater-than comparison keeps the earliest winner on ties and leaves zero selected if no score exceeds zero. That is reference behavior, not approved custom-class policy.
- `Game/Utility/StartGameBehaviour.cs#StartNewCharacter` invokes biography application during startup. CORE-012's approved intended order is authoritative for the recreation rather than adoption of every source branch.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete effect inventory, content values and original biography fixtures have not been verified here. Source remains unchanged.

## Detailed rules and behaviors

### Definitions and owner boundaries

DATA decodes and validates class/career and biography definitions. CHAR and other authoritative effect owners calculate and apply consequences. Reading content, displaying questions or previewing answers must not mutate a live character. Keep reusable definitions separate from a character's candidate selections, generated narrative inputs and applied state.

Preserve supported classic class fields, biography choices and effects as the initial baseline with explicit validated overrides. Importing a field does not approve its final balance value or complete behavior. Exact class legality, effect stacking, grant quantities and progression formulas remain CHAR/ITEM/MAGIC and other owner specifications. Source fields shared with enemy careers may reuse decoding without implying identical player/enemy runtime rules.

### Identity and extensibility

Use stable IDs for classes, biography sets, questions and answers, with explicit supported effect types and target IDs. Preserve mappings from classic identifiers and content locations. Translation, display-name changes or reordering do not change choice identity. Do not use display text or a transient array position as the sole durable choice reference.

Allow validated added content beyond classic filenames and fixed question counts. This does not automatically authorize arbitrary executable effects, every conceivable question UI or unconstrained schema extensions. Domain schemas and consumers must define supported structures and required fields.

Apply DATA-003's domain/path identity, declared add/replace/patch operations, precedence, provenance and validation. Stable choice identity does not make semantic changes to an existing choice automatically compatible with old characters. Definition additions require unused identities; explicit replacements retain their intended identity while remaining subject to reference and compatibility checks.

### Biography selection

CHAR owns an explicit selection rule that returns a biography-set ID, including custom-class selection. DATA provides declared class-to-biography mappings and lookup results. Do not silently choose the first classic class when no match exists. Whether to retain skill-affinity selection, and its weighting/tie/no-match handling, remain CHAR decisions. Missing required selection/mapping is a failure for the appropriate character-creation/entry owner, not permission to substitute an unrelated biography.

### Effects and validation

Represent supported effects with explicit type, target and required parameters, preserving classic-command mapping in the adapter. Validate malformed commands, unsupported required types and missing required targets before character mutation. Do not silently ignore a required effect or apply only the valid portion of an answer and announce success.

Reject invalid contributions as a whole under DATA-003; required missing biography/effects follow CORE-012 entry failure. An explicitly omitted contribution is permissible only through DATA-003 recovery when the remainder satisfies all required references and owner contracts. This does not authorize bypassing mandatory effects.

Actual effect application remains owner-controlled and respects CORE-012 ordering and duplicate protection. Prevalidation does not guarantee every later owner operation succeeds; actual failure must use safe-entry cleanup/retry rather than leave a playable partial character. This feature does not select a universal transaction engine or promise restoration of arbitrary live-state mutations.

### Preview and final evaluation

Preview and final application use the same validated effect definitions and owner rules. Changing answers recomputes a separate candidate result rather than repeatedly applying deltas to the live player or accumulating grants. Derived previews and candidate selections are distinct from committed startup effects.

CHAR must define any randomized outcome, random-stream handling, when outcomes are committed, and which information previews disclose. This specification does not require exact preview/final numerical equality where approved rules intentionally hide or randomize outcomes. It requires consistent definitions and rule interpretation, without introducing a reroll policy by implication.

### Narrative and presentation

Biography question/answer text, narrative references and effect inputs remain distinguishable. Translation or text-only changes do not change identity or mechanically apply effects. Backstory generation, presentation sequence, skip/automatic-answer routes and narrative persistence are owner dependencies rather than invented importer rules. Do not adopt DFU's specific malformed-header fallback or effect command behavior without owner validation.

## Relevant formulas and parameters

No new attribute values, skill bonuses, advancement multipliers, class-affinity weights, fixed question counts or reward quantities are approved here. Classic source values are content to preserve/verify as the baseline and review under domain balance rules. Exact effect arithmetic, stacking, limits, tie-breaking and randomness are CHAR/other-owner contracts.

## Required data

Stable class/biography/question/answer IDs and classic mappings; supported career fields; text/localization and narrative references; declared class-to-biography mappings; effect type/target/parameters; schema/requiredness and source provenance; validation outcomes. Candidate selection references and owner-evaluation results are character-creation data, separate from reusable definitions. Complete schemas, supported effect vocabulary and custom-class rule contracts remain dependencies.

## Inputs, outputs and events

Inputs: classic/packaged/mod definitions, class/custom-class selection context, biography-set lookup, selected answer IDs and preview/final evaluation requests to owners. Outputs: validated definitions, explicit mappings/effect inputs and missing/unavailable/invalid/unsupported outcomes. These are conceptual contracts, not concrete APIs/signals. DATA reads do not emit grant-complete or new-character-ready notifications; CORE/owners publish truthful committed outcomes.

## Cross-system interactions

- DATA-001/002 retain external input/access and readiness policies. Biography definitions may be packaged rather than original ARENA2 data; requiredness follows actual consumers.
- DATA-003 owns applicable content contribution resolution and pre-menu lock. DATA-007's shared career decoder context does not transfer combat/NPC behavior ownership to player biography data.
- CHAR owns creation legality, biography selection, effect semantics, preview/random policy and progression baseline. ITEM/MAGIC/FACT/ECON and other effect targets retain their authoritative operations and validation.
- UI presents definitions and isolated candidate evaluation without committing gameplay changes. Localization changes text rather than stable identity.
- CORE-010/011/012 own clean session preparation, placement and ordered/idempotent startup. CORE-007/013 retain failure/load coordination. SAVE restores mutable results without rerunning new-character biography rewards.
- MOD owns package/code lifecycle; a data effect type cannot implicitly become arbitrary executable code. SAVE/domain owners define compatibility and migration of changed/removed definitions.

## Edge cases and failure conditions

- A custom class has no resolved biography set: report missing required mapping; do not default to classic class zero.
- A question/answer is reordered or translated: stable identity persists. A selected answer ID absent from the active definition set is explicit invalid/missing input, not another answer at the same position.
- One answer contains several effects and one required effect is invalid: reject before application rather than applying only successful entries.
- The player revisits questions repeatedly: candidate results are recomputed without repeated rewards or live mutations.
- Required target disappears or application fails after prevalidation: preserve CORE-012/007 safe-entry failure instead of false completion.
- A class legitimately has no starting spell grant: preserve CORE-012's valid no-spell outcome; absence is not automatically a broken reference.
- Random effects exist: owner policy must prevent accidental resampling/disclosure behavior; no policy is inferred here.
- Unknown source fields exist: document uncertainty and verify supported decoding; do not assign invented gameplay effects. Required unsupported interpretation remains explicit failure under DATA contracts.
- A save uses changed/removed biography definitions: pass explicit context to SAVE/CHAR; do not re-award rewards, silently remap by question text or automatically recompute the character.

## Configuration and balancing options

Validated additions and overrides use declared schemas. Supported in-game settings retain owner contracts without unlocking DATA-003's content plan. No player-facing strictness bypass, new randomization option, custom-class balance rule or automatic biography fallback is introduced here.

## Save/load considerations

Character loads restore applied state without rerunning fresh-character effects/grants. SAVE/CHAR must decide which stable selections, provenance, generated narrative, effect results and custom-career fields require persistence and how changed definitions are handled. Stable choice IDs support reference integrity but do not alone certify semantic compatibility. No migration, automatic recomputation or source-snapshot format is approved here. Definition reads remain side-effect-free during load and reconstruction.

## Technical constraints

Target engine: Godot 4.7.2. Separate classic parsing, validated reusable definitions, candidate evaluation and owner-controlled application. Keep original sources read-only and reject invalid required inputs truthfully. Avoid tying effect interpretation to UI enumeration or live PlayerEntity mutation inside readers. Concrete schemas, parser/effect APIs, namespace encoding and cache design remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Supported classic class/biography definitions remain the overridable baseline without implicitly approving all balance rules.
2. Definition reading and answer previews never mutate a live character; authoritative effects are applied by their owners.
3. Stable class/set/question/answer IDs survive translation/reordering, with classic mappings and validated additions beyond classic filename/count limits.
4. CHAR resolves custom-class biography selection explicitly; missing selection never silently becomes the first classic class.
5. Malformed commands, unsupported required types and missing required targets are rejected before mutation, with whole-contribution/required-entry recovery preserved.
6. Preview/final use consistent validated definitions and owner rules. Repeated answer changes do not accumulate rewards; randomness follows an explicit CHAR policy.
7. Biography effects precede grants and skill baseline capture follows initial skill changes. Repeated callbacks do not duplicate effects; failed retry uses clean replacement.
8. Save loading restores outcomes without fresh rewards or implicit recomputation from altered definitions.
9. Required failures remain explicit, legitimate no-grant outcomes remain valid, and original source files are unchanged.
10. Representative class/biography, reordered/translated, custom-class, invalid-effect and preview-isolation fixtures verify owner contracts before implementation is complete.

These are future verification criteria. No implementation, original-data fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–007 and approved CORE character-entry/load contracts, especially CORE-010–013. No contradiction identified. DATA validates effect inputs without taking CHAR/ITEM/MAGIC authority. Stable IDs and whole-contribution recovery extend DATA-003 patterns. Preview isolation reinforces startup duplicate protection, while explicit selection avoids adopting DFU's class-zero/tie behavior without approval. CORE-012 ordering and mandatory-effect failure remain unchanged.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: complete career/biography/effect schema and source inventory; stable ID/classic mappings; exact balance/stacking/legality under owners; custom-class biography selection/ties/no-match behavior; randomized preview/commit/disclosure policy; narrative and optional/automatic-answer routes; required target validation and application contracts; SAVE persistence/compatibility/migrations; representative content fixtures. These deferrals do not waive side-effect isolation, explicit failures or approved startup ordering.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-008-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including effect schemas, balance/randomization policies, biography selection, narrative and save contracts. Approval does not initiate implementation, coding tasks or another feature review.
