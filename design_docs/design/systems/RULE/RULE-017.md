# RULE-017 — Saving throws

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Resolve cancellation and retained payload percentage for incoming effects, with explicit immunity/tolerance order, effect-owned interpretation and retained results.

## Intended player experience

Resistance can cancel, reduce or leave an effect unchanged. Combined strengths/weaknesses have understandable results rather than immunity always overriding every weakness. Inspecting resistance never rolls it. One effect application reuses its resolved save across relevant fields and retries.

## Confirmed requirements

RULE-017-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve moddable source baseline/order, pre-Willpower immunity, explicit numeric/binary interpretation, once-per-kind tolerance composition, initial granted cancellation, per-effect retained saves, safe truncation/no minimum and truthful previews.

CHAR-002 retains racial abilities while leaving detailed resistance/stacking to owners. RULE-005 supplies live-Willpower MagicResist; RULE-001/003 govern random checks/results. RULE-004/DATA-003 govern supported validated hooks/configuration. RULE-016 retains poison attempt/consumption and payload ownership without duplicating saves.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#SavingThrow` first checks granted elemental resistance; successful Dice100 cancellation returns retained percentage zero. Otherwise base score 50 receives racial, career tolerance, biography and caller adjustments. Score>=100 returns zero before target.MagicResist is added.
- Matching career tolerances are OR-collected and each tolerance kind applied once. Source comments explicitly contrast this mixed policy with classic immunity/critical-weakness dominance.
- After MagicResist, score clamps 5–95. Roll is 1–100; failure retains 100. Success within the 20-point margin uses 100−5×(score−roll); deeper success returns zero. Equal roll/score retains 100.
- `SpellHasFlags`, `GetEffectFlags`, `GetElementType` map element/effect/race matches. `GetResistanceModifier` includes a nonplayer paralysis modifier. Complete effect classification requires owner verification.
- `ModifyEffectAmount` calls SavingThrow and scales amount via float then integer cast. Missing effect/bundle returns unchanged amount in this source path. `InflictPoison`/`InflictDisease` can instead treat any nonzero retained value as allowing their full status path. These caller policies are not universally approved for all effects.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete effect mappings, runtime call frequency and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Valid application context

MAGIC supplies valid target, effect/element classifications, caller adjustment and explicit interpretation policy. Missing required context is an error, not a silent full-payload bypass or successful zero-resistance default. Nonresistible/bypassed effects require explicit owner rules and are not inferred from null source data.

Use resolved current live race/Willpower and owner-supplied career/biography/effect context at application resolution. Stable effect identities/classifications must support validated content without relying on unsafe casts. Matching element/compound flags must be declared by MAGIC adapters; preserve source baseline where supported, not a guessed all-effects category.

### Ordered resistance resolution

First, if applicable granted magical elemental resistance exists, resolve one RULE-001 cancellation check using its owner-resolved chance. Success returns retained percentage R=0 and stops; failure proceeds. Its source stacking/chance calculation is MAGIC-owned. No applicable resistance means no initial cancellation draw.

Start score C=50. Apply matching racial contributions in order: resistance +30; immunity sets C=100; low tolerance −25; critical weakness −50. Then collect career tolerance kinds matching the incoming flags and apply each distinct kind once: Immune +50, Critical Weakness −50, Low Tolerance −25, Resistant +25. Repeated matching categories of the same career tolerance kind do not multiply its bonus. Add matched biography contributions and explicit caller modifier.

If this pre-Willpower score C>=100, return R=0 without a main save draw. Otherwise add live-Willpower resistance modifier floor(W/10), then clamp to resolved main-score limits, vanilla 5–95. Only then resolve one main 1–100 roll. Willpower alone does not grant perfect baseline immunity because its contribution occurs after the early threshold and before the 95 cap.

Mixed weaknesses can offset an immunity contribution before early cancellation. This is deliberate and moddable, not a bug to silently repair into absolute immunity. Player descriptions must reflect resolved composition. Racial applicability/transformations and career tolerance provenance remain owner contracts.

### Retained percentage

Let final score P and main roll U. If U>P, retain 100. Otherwise margin m=P−U: baseline retained percentage R=clamp(100−5×m,0,100), equivalent to full cancellation for margins>=20. At m=0, retain 100 despite nominal check success; m=1 retains 95, m=19 retains 5, m=20 retains zero.

R is retained payload percentage, not chance to resist, damage amount or boolean success. Main roll uses explicit owned randomness and RULE-001 roll boundaries; do not reroll through separate success/failure queries. Guaranteed initial checks still follow RULE-001's one-draw rule, whereas direct early score immunity is a rule-based cancellation without a main draw.

### Per-effect interpretation and lifetime

Resolve once per effect application and retain percentage, reasons and relevant draws/context. Use the same R for its numeric damage/duration fields, diagnostics and technical retries; do not independently save each getter/field. Separate effects in one spell may have separate saves. Repeated-tick saves require an explicit MAGIC policy, with defined identity/cadence; no continuous reroll is introduced.

Numeric amount A scales to trunc(A×R/100) with safe arithmetic, toward zero. No automatic minimum one applies; nonzero R can still yield zero for small A. Supported amount domains/sign semantics and owner-specific minima must be declared, not inferred from numeric scaling.

Binary effects require a declared cancel/apply interpretation. A supported legacy-style policy may cancel only at R=0 and otherwise permit a full status attempt, but this review does not automatically assign that to every poison/disease/paralysis effect. Do not create partial statuses, duplicate saving throws or a new random binary check without owner approval. RULE-016 poison consumption/attempt settlement remains binding.

### Modding and presentation

Support validated parameters/composition and explicit RULE-004 hooks for the baseline score, racial/tolerance values/order, early threshold, main limits/margin scaling and payload interpretation where the owner exposes them. Schemas must specify safe domains and coherent retained output 0–100. Main integer-percent bounds require valid ordered limits within 0–100; positive divisors/margin widths and finite safe arithmetic are mandatory where configured. Exact supported fields/alternative models remain owner schema dependencies, not a generic formula interpreter.

Provide inspectable cancellation/partial/full reasons, nonrandom previews and optional detailed percentages. Distinguish initial cancellation chance, pre-Willpower immunity, main resistance score and retained payload. Estimates/conditional outcomes must be labelled rather than rolling a preview. Diagnostics reuse actual draws/margins. Optional logging/querying cannot apply effects or advance sources.

## Relevant formulas and parameters

- C starts at 50; racial order: +30, set 100, −25, −50 when matching.
- Career kinds applied once: +50 immune, −50 critical weakness, −25 low tolerance, +25 resistant; add biography/caller inputs.
- If C>=100, R=0. Otherwise P=clamp(C+floor(live Willpower/10),5,95).
- U uniform 1–100. If U>P, R=100; else R=clamp(100−5×(P−U),0,100).
- Numeric adjusted amount=trunc(A×R/100), without implicit minimum.

Example: P=60,U=60 retains 100; U=59 retains 95; U=40 retains zero; U=61 retains 100. A=3,R=5 scales to zero. C=95 plus Willpower modifier 10 still clamps main score to 95 rather than early cancellation; C=100 cancels before Willpower/main roll.

## Required data

Stable effect/application/target identity; valid element/effect flags and payload policy; resolved granted resistance/race/career/biography/caller/Willpower inputs; parameter/hook provenance; retained percentage/reasons/draws and owner application state. Concrete mapping/version/schema/source purposes remain dependencies.

## Inputs, outputs and events

Inputs: authorized valid effect application or nonrandom query. Outputs: retained percentage, explanation/context or explicit failure. Numeric conversion is separate from authoritative status/pool application. MAGIC/CHAR own committed consequences and events; API names/signals remain unselected.

## Cross-system interactions

MAGIC owns classifications, stacking, binary/scalable payloads and repeated-tick policy. CHAR-002/011 supply resolved racial/live state and RULE-005 Willpower modifier. COMBAT/ITEM/RULE-016 supply effect origin/poison settlement where applicable. RULE-001/003 supply ordered draws/results, RULE-004/DATA-003 validated locked overrides. CORE/SAVE gate coherent application/restoration; UI/DEV explain without mutation.

## Edge cases and failure conditions

- Compound flags deduplicate career tolerance kinds, not necessarily distinct biography fields; mapping/biography matching must be explicit.
- Early immunity skips main draw; failed granted cancellation proceeds, never recursively restarts itself.
- Exact score boundary retains full payload; margins and small amount truncation require tests rather than intuitive boolean interpretation.
- Missing source/bundle/classification is not full-payload success. Unknown IDs, overflow/nonfinite parameters or failed hooks require explicit recovery without vanilla fallback.
- Multiple field queries/retries cannot reroll; repeated effect ticks need explicit policy and cannot become accidental double saves.

## Configuration and balancing options

Baseline cancellation/scaling/composition is moddable through supported schemas/hooks, including explicit alternatives to mixed tolerance. No universal status-duration minimum, absolute immunity dominance, poison stacking policy or automatic new race rule is introduced. Invalid contributions use DATA-003/RULE-004 recovery; retained applications cannot silently change after provider/configuration changes.

## Save/load considerations

Persist authoritative effect/source state and retained save results needed by ongoing applications. Restore without rerolling saved R, rescaling already-scaled values again or replaying status/pool application. Future new applications use fresh RULE-003 randomness; supported repeated ticks follow their owner's persisted cadence. Mapping/configuration changes require explicit compatibility/migration rather than silent bypass or cancellation. Concrete mid-application persistence remains MAGIC/SAVE scope.

## Technical constraints

Target: Godot 4.7.2. Separate valid context mapping, ordered random resolution, retained result, numeric/binary interpretation and mutation. Use safe integer percentage scaling/toward-zero conversion rather than avoidable float errors. Concrete types/interfaces/versioning remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Granted cancellation precedes score evaluation; successful cancellation and pre-Willpower C>=100 skip main draw.
2. Racial order/career deduplication/biography inputs and later Willpower cap match approved baseline, including offset immunity cases.
3. Main margins produce exact retained percentages at failure/equality/1/19/20 boundaries.
4. One application shares retained R across fields/diagnostics/retries; new effects/repeated ticks use explicit owner identity/policy.
5. Numeric scaling truncates safely without minimum; binary interpretation is declared rather than guessed or rerolled.
6. Mod schemas/hooks validate inputs/output domains; missing required context/unsafe arithmetic fail explicitly instead of bypassing resistance.
7. Previews distinguish chance from retained amount without draws; restore cannot reroll, double-scale or replay application.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-002/011 and RULE-001/003/004/005/016. Detailed mixed tolerance refines previously deferred racial resolution; Willpower helper remains a modifier rather than standalone immunity chance. Poison settlement is separate from retained-percent interpretation. RULE-001 guaranteed checks differ from direct nonrandom early cancellation. Source repeated calls/missing-context bypasses are not automatically adopted.

## Outstanding questions and approval

No blocking saving-throw policy question remains. Before implementation: finalize element/compound mappings, biography/caller adapters, binary/scalable effect contracts, supported numeric/mod domains, source/application/tick identity and SAVE handling. These cannot waive immunity order, per-kind tolerance application, retained percentage semantics or one save per application.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-017-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering, effect-mapping and MAGIC/SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
