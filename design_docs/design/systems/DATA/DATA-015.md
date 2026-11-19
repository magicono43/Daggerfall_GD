# DATA-015 — Classic text records and formatting tokens

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Expose classic-format messages as structured text with supported formatting, boundaries and variants, integrating localization fallback without transferring interaction authority to text decoding.

## Intended player experience

Messages retain intended meaning, reading order and interaction structure. Missing or unusable translations fall back predictably. Refreshing or translating an already selected message does not silently reroll it. Broken essential prompts lead to usable recovery rather than blank controls or unintended gameplay choices.

## Confirmed requirements

DATA-015-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish structured classic formatting; DATA-013 fallback with explicit classic mappings; owner-controlled variant/random selection; explicit unusable-token/decorative-degradation rules; safe empty-variant handling; and UI/gameplay ownership of interaction identity and validation.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Utility/TextProvider.cs#GetRSCTokens(int)` tries localized runtime RSC text and converts it through DaggerfallStringTableImporter, then lazily opens TEXT.RSC and decodes a numeric record. Missing source bytes can return null. The string-ID overload tries localization without numeric classic fallback.
- `API/TextFile.cs#Formatting` and `ReadTokens` represent text and controls including line/page boundaries, alignment, font/position prefixes, cursor positioning, subrecord separation and end-of-record. The enum also contains custom formatting codes; enum presence alone does not prove every renderer supports them.
- `TextProvider#GetRandomTokens` splits subrecords, then chooses via classic DFRandom or Unity random according to its flag. It assumes non-null tokens and decrements a selected empty-stream index, which can create invalid or unintended selection behavior for edge cases.
- `Utility/FallbackTextProvider.cs` delegates calls to another provider and allows specialized overrides. This extension pattern does not itself establish safe provider ordering, cycle prevention or target fallback semantics.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Token conversion fidelity, original records, renderer coverage and missing/empty fixtures were not tested. Source remains unchanged.

## Detailed rules and behaviors

### Structured records

Preserve supported classic formatting and message boundaries in a structured representation rather than flattening everything to plain text. Retain sufficient source/key context to diagnose conversion failures. Godot presentation may differ while preserving meaning, reading order and required interaction controls.

Distinguish text runs, layout controls, page/record boundaries and authored variant separation. Exact token schema, units, font mapping and supported control inventory remain DATA/UI contracts. Decoding a token is not proof its target presentation supports it. DATA-016 owns dynamic macro/context expansion rather than this feature inventing placeholder meanings.

Use stable DATA-013 message keys and explicit classic numeric mappings. New messages are not limited to original numeric record ranges. Reusable decoded definitions remain separate from mutable UI state, selected variants and gameplay choices. Original text sources remain read-only.

### Lookup and fallback

Follow selected language → declared content base language → explicit source/caller fallback under DATA-013. An explicitly mapped numeric classic message may use TEXT.RSC as source fallback. New string-keyed messages need their own declared fallback; do not guess a numeric record from names or key text.

Each candidate must have usable supported structure before presentation. Missing records, source unavailability, malformed token data and unsupported required controls remain distinguishable diagnostics. Ordinary exhausted lookup uses DATA-013's visible placeholder; essential controls require bundled usable labels and independent recovery. An ordinary placeholder is not enough to certify an essential prompt usable.

DATA-003/014 contribution resolution and structural rejection remain separate from message-usability fallback. Do not silently resurrect an overwritten same-language patch value as an extra fallback tier. TEXT.RSC is an explicitly mapped source fallback, not permission to scan unrelated records or bypass missing required data.

### Unsupported controls and validation

Malformed tokens or unsupported controls affecting meaning or interaction make the message unusable and invoke the approved fallback chain. Do not silently drop required page breaks, input positioning or other essential structure. A purely decorative control may degrade only under an explicit UI-approved rule preserving usability; no universal ignore-unknown-control policy is approved.

Validate operand lengths, boundary structure and supported interpretation under the declared format. Unknown raw fields/bytes must not become invented commands. Exact optional/decorative classification and conversion rules require evidence and renderer contracts before implementation is complete.

### Variants and randomness

Expose authored variants separately from selecting one. The requesting owner chooses a particular variant or requests random selection through an explicitly owned random source. Reading, validating, caching, rerendering or switching language must not silently consume gameplay randomness or reroll an already selected message.

Exclude accidentally empty variants from random selection and diagnose them. Intentional silence requires explicit supported designation under DATA-013 optional suppression; it cannot erase essential controls. If no usable variants remain, use message fallback rather than choosing an adjacent variant or decrementing an index. A missing explicitly requested variant must not silently become a neighboring variant; exact failure/fallback integration is an owner contract.

This feature does not approve uniform weighting, a specific RNG algorithm, classic draw parity or variant-ID alignment across every language. RULE/requesting owners must define selection semantics and DATA/UI must map a retained selection through language refresh without rerolling. Empty filtering may affect probabilities and classic parity, so those consequences require explicit fixtures rather than assumptions.

### Interaction authority

UI or the requesting gameplay owner controls choice/input identity, valid responses and committed outcomes. Tokens describe presentation; they do not independently accept choices, submit input, execute quest actions or change eligibility. Stable option identities must survive text refresh independently of rendered order/wording under their owner contract.

If essential interaction structure cannot be rendered after usable fallback attempts, provide independent usable recovery rather than blank/misleading prompts. Exact recovery depends on the initiating feature; do not interpret inability to display a choice as acceptance, decline or successful completion. CORE-012 popup sequencing and CORE-019 restriction results remain authoritative.

## Relevant formulas and parameters

No gameplay formulas, token coordinate scale, selection weights, RNG algorithm or renderer constants are approved here. Classic token byte values are adapter facts rather than a requirement for identical Godot representation. Usability checks, explicit variant selection and owner-defined randomness determine behavior; exact numeric limits/tolerances remain technical dependencies.

## Required data

Stable message key/collection; applicable classic ID mapping; locale/base/source provenance; structured text/control operands; record/page/variant boundaries; explicit optional-silence designation; usability/format requirements; selected variant context and random-source request where applicable; owner interaction identity separate from presentation. Complete token inventory, mappings and cross-language variant contracts remain dependencies.

## Inputs, outputs and events

Inputs: keyed/numeric-mapped text queries, validated locale/source data, supported token grammar, explicit variant request or owner random-source selection, rendering capability and context for later macro expansion. Outputs: structured usable messages/variant definitions, selected variant result or explicit missing/unavailable/malformed/unsupported failures and fallback outcomes. These are conceptual contracts, not concrete APIs/signals. Successful decoding or display is not choice commitment, quest progression or reward delivery.

## Cross-system interactions

- DATA-001/002 retain source access/readiness/failure rules; DATA-003/014 resolve installed contributions; DATA-013 supplies language fallback, blank/suppression policy and live language selection.
- DATA-016 owns macro/context expansion. UI owns token rendering, pagination, input focus and prompt recovery; AV/font owners define actual resource/glyph support.
- RULE and requesting systems own random streams/selection semantics. This feature does not adopt a global RNG split or generator proposal wholesale.
- NPC/QUEST/ITEM and other consumers own message purpose, variants and gameplay decisions. Rendering text must not replay operations or grant rewards.
- CORE-004/005 provide independent recovery/lifecycle contracts; CORE-012 ordered opening presentation and CORE-019 blocked results remain unchanged. SAVE/owners define durable selected-message/interaction state where supported.

## Edge cases and failure conditions

- Numeric mapping valid but TEXT.RSC record absent: explicit missing source fallback, then ordinary placeholder or essential recovery as appropriate.
- String-keyed message has no declared source fallback: do not invent a numeric match.
- Malformed operand or unsupported required control: candidate unusable; fallback, without dropping structure and claiming success.
- Empty/trailing/leading subrecords: no invalid indexing or neighboring-selection substitution. Accidental empty variants are excluded from random choice with diagnostics.
- All variants unusable: message fallback, not a successful empty message. Explicit optional silence remains distinguishable.
- Locale changes while a variant or choice is displayed: preserve selection/interaction context without random draws or implicit answer acceptance.
- Decorative token unsupported: degradation requires an approved rule, not guesswork. Missing essential structure cannot become a blank prompt.
- Fallback/provider extension exists: DATA-003/MOD must define resolution and lifecycle; decorator call order is not automatically approved precedence.

## Configuration and balancing options

Validated message/variant additions and overrides follow declared schemas and content locks. Supported presentation changes retain meaning and essential structure. No ignore-required-token mode, automatic random reroll on refresh or essential-silence toggle is approved. Variant probabilities and gameplay-facing message policies remain owner decisions.

## Save/load considerations

Decoded text definitions and disposable render caches are content, not mutable character state. SAVE/UI/requesting owners decide which active message/variant/choice state must survive supported saves, using stable references rather than localized text or transient token pointers alone. Loading must not reroll or replay effects merely to reconstruct presentation. Historical text snapshots versus live localization remain owner decisions under DATA-013; no universal snapshot format is selected here.

## Technical constraints

Target engine: Godot 4.7.2. Separate binary decoding, localization resolution, structural validation, variant selection, macro expansion and UI interaction authority. Keep inputs immutable to consumers and sources read-only. Concrete token representation, parser, renderer, provider API, caches and RNG plumbing remain implementation choices; broader architectural proposals are not approved wholesale.

## Acceptance criteria

1. Supported classic text/control structure preserves meaning, reading order and required interaction boundaries without forced plain-text flattening.
2. Localization follows DATA-013; numeric classic fallback requires explicit mapping, while new string keys never guess numeric records.
3. Malformed/unsupported required controls invoke usability fallback; decorative degradation occurs only under approved UI rules.
4. Variants are exposed separately from owner-driven specific/random selection. Read/validation/refresh operations do not silently consume gameplay randomness or reroll messages.
5. Accidental empty variants are excluded from random selection with diagnostics; all-unusable results fall back without negative indexes or adjacent substitution. Intentional silence is explicit and optional only.
6. UI/gameplay owners retain choice/input validation and commitment. Unrenderable essential prompts use usable recovery without invented answers or false success.
7. DATA-014 overwritten same-language values are not silently restored as extra fallback; installed content locks and original-source read-only rules remain intact.
8. Representative token/page/input, missing/malformed, empty-variant, localization and retained-selection refresh fixtures verify behavior before implementation is complete; visual plausibility alone does not prove structural fidelity.

These are future verification criteria. No implementation, original-text fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–014 and approved CORE settings/recovery/presentation/restriction contracts. No contradiction identified. Explicit TEXT.RSC source fallback integrates with DATA-013 without adding silent language tiers. Empty filtering refines variant handling without approving RNG weights/parity. Token interpretation remains separate from CORE-012 popup sequencing and authoritative gameplay outcomes; required interaction fallback does not bypass CORE-019 restrictions.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: full supported token/operand/boundary inventory; classic/stable mappings; UI decorative/required capability rules and prompt recovery; token/markup round-trip fixtures; cross-language variant identity and selection weights; RULE random-source contracts; DATA-016 macro integration; provider lifecycle; active-message save/history policy and representative original records. These deferrals do not waive structural preservation, explicit failures or owner-controlled selection.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-015-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including token/rendering support, variant identity and randomness, prompt recovery and save policies. Approval does not initiate implementation, coding tasks or another feature review.
