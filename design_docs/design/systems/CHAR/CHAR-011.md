# CHAR-011 — Permanent and live attributes and skills

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Expose lasting character development separately from current bonuses/penalties, with trustworthy gameplay queries, source-specific modifier removal and duplicate-safe restoration.

## Intended player experience

Temporary effects change current capabilities without silently rewriting permanent development. Players can inspect why a value differs from its permanent amount, including caps and opposing modifiers. Saving/loading preserves the same valid character state without accumulating bonuses.

## Confirmed requirements

CHAR-011-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish permanent/live separation, consumer defaults, live attribute clamping, unclamped live skills, source-owned modifiers, inspectable presentation, validated permanent bounds, source-based restore and stable extensible identities.

Earlier creation specifications retain their own budgets/ranges/caps and must be compatible with runtime domains. CHAR-004's mod support does not automatically add attributes; CHAR-009 permits validated added skills. CHAR-006/CORE-012 apply initial permanent changes once and capture progression baseline afterward. DATA-003 configuration locking and CORE readiness/failure rules remain binding.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/DaggerfallStats.cs`: eight permanent attribute fields and temporary mods/maxMods arrays. GetLiveStatValue sums permanent/modifier values and clamps to 0 through FormulaHelper.MaxStatValue plus max modifier. The getter narrows to short despite an int return; intended safe numeric handling does not adopt overflow/wrap behavior. Permanent setters themselves do not enforce 0–100.
- `Game/Entities/DaggerfallSkills.cs`: permanent short skill fields and an int modifier array. GetLiveSkillValue adds and returns a short without an explicit clamp; index overloads can return zero for invalid indices. Intended validation does not treat invalid identity as a successful zero value.
- Both collections' Copy/Clone operations copy permanent values, excluding active modifiers. Skills construction/defaulting consumes random draws; intended querying/copying/restoration must not reroll identity/state by implication.
- `Game/MagicAndEffects/EntityEffectManager.cs`: merges direct contributions and assigns combined attribute/maximum/skill modifiers to the entity. Source effect state also includes modifier arrays. Exact effect stacking is not established solely by collection addition.
- `Game/Entities/DaggerfallEntity.cs#ClearConstantEffects` resets assorted transient effect state. `PlayerEntity.RaiseSkills` reads permanent skills for advancement. `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#UpdatePlayerValues` displays live values and compares with permanent values for coloring.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Complete consumer audits, effect lifecycle ordering and runtime restoration remain verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Permanent state and validation

Keep authoritative permanent values independent of temporary source contributions. Vanilla permanent attributes and skills are integers within inclusive 0–100. Validated definitions may override per-value bounds within supported numeric/consumer domains. Permanent-value bounds, live attribute caps and creation allocation limits are distinct policies requiring compatibility checks, not automatically synchronized settings.

Temporary effects must not directly rewrite permanent values. Permanent rewards, damage, restoration and initialization use explicit owner-controlled mutations with validation. An operation attempting an invalid permanent result fails explicitly without committing that invalid result; do not silently clamp it into a different success. Reward/progression owners may explicitly calculate bounded awards under their approved rules before submitting a valid mutation.

Zero being a valid stored value does not establish that zero causes death, paralysis or another consequence; those outcomes require owner rules. No new damage/restoration mechanic or mastery rule is introduced here. Invalid/unknown IDs and unsupported references return explicit failure, never an invented zero/default stat.

### Live values and consumers

Ordinary gameplay checks use live values by default. Progression thresholds, mastery and earned-development calculations use permanent values unless the responsible feature explicitly specifies otherwise. Document exceptions at consumer boundaries; never assume every source getter call automatically establishes the intended recreation rule.

Live attributes clamp the permanent-plus-modifier total to zero through the effective maximum. Vanilla base maximum is 100; approved maximum-modifying sources can change it. Validate that the effective maximum remains supported and nonnegative before publishing a live state.

Live skills are permanent plus resolved modifiers without a global gameplay clamp. Temporary results below zero or above 100 remain representable within safe numeric ranges. Each consuming rule explicitly defines its own usable minimum, probability clamp or other domain conversion. Do not apply creation/permanent bounds to live skills implicitly or interpret every skill value as a percentage.

### Modifier sources and lifecycle

Track contributions by authoritative owning source, target and contribution identity. MAGIC/ITEM and other owners decide eligibility, duplicate handling, stacking, refresh and precedence. CHAR combines only the contributions those owners have resolved as valid; this does not approve universal duplicate stacking or arbitrary multiplicative effect order.

Expiration, unequipping and source removal clear only that source's contributions, then recompute from permanent values and valid remaining sources. Repeated application/removal callbacks cannot multiply or remove another source's benefit. Cap reduction does not erase permanent values or other modifiers; after a valid cap change, recompute the clamped live attribute from retained inputs.

For example, permanent 95 with +20 value contribution and cap 100 has live value 100. Removing the +20 returns live value 95; it does not subtract 20 from the previously clamped 100 to produce 80. Likewise, temporary penalties cannot permanently destroy progression merely by expiring.

Invalid source targets, unsupported numbers or negative effective caps cannot publish valid state. Reject malformed new contribution/mutation and preserve the prior consistent state where possible. Required restore/source failures follow CORE/SAVE recovery rather than silently dropping contributions and announcing success. Exact multi-source transition batching is an engineering contract, not approval to expose inconsistent intermediate state to consumers.

### Presentation

Show current live values with a clear permanent comparison. Provide an inspectable breakdown of active bonuses, penalties and effective attribute cap changes, including opposing contributions that sum to zero or bonuses hidden by a cap. Coloring alone is insufficient.

Distinguish stored permanent values, resolved raw total and final effective value where relevant. Use the same resolved state as gameplay, with truthful source labels; final layout is UI scope. Display/query operations never consume randomness, grant practice or reapply effects.

## Relevant formulas and parameters

For attribute/skill ID i, let P_i be permanent value and M_i the sum of owner-resolved additive value contributions.

- Permanent validity: Lperm_i≤P_i≤Uperm_i; vanilla 0–100.
- Attribute effective cap C_i=Bcap_i+sum(owner-resolved maximum contributions), with vanilla Bcap_i=100 and C_i≥0.
- Live attribute A_i=clamp(P_i+M_i,0,C_i).
- Live skill S_i=P_i+M_i, without global gameplay clamping.

All intermediate and output numbers must fit supported safe numeric domains. Signed modifier values are allowed; malformed, nonfinite or overflowing contributions fail rather than wrap/narrow silently. Definitions and owners must constrain aggregate extremes as well as individual fields. Exact numeric widths remain implementation choices.

These formulas describe combination after effect-owner stacking resolution. They do not establish universal effect stacking, percentage multipliers, advancement thresholds, skill mastery or derived health/magicka formulas.

## Required data

Stable attribute/skill IDs and classic mappings; permanent values/bounds; base live attribute caps; valid source/contribution/target identity and values; owner-resolved active contributions; recomputed totals/caps/live values; diagnostics/source labels; and authoritative saved source context. Concrete schemas and IDs remain engineering dependencies.

## Inputs, outputs and events

Inputs: validated permanent mutations, source add/update/remove, resolved definitions, queries and restoration. Outputs: validated permanent/live values, source/cap breakdowns or explicit invalid-operation/reference results. Notifications must reflect consistent committed state; exact event/API names and batching are deferred. Reading/recomputing values is not earned advancement or reward application.

## Cross-system interactions

MAGIC/ITEM and other source owners resolve effect eligibility/lifecycle/stacking. CHAR owns permanent/live representation and combination. RULE/COMBAT/MOVE/MAGIC/ECON and other consumers choose live/permanent explicitly and apply local numeric conversions. CHAR-012–015 own practice/advancement; CHAR-004/008/009 own creation legality. UI inspects shared resolved state. DATA-003 and relevant definitions govern stable identity/configuration. SAVE restores permanent/source state; CORE-005/007/013 gate readiness and recovery.

## Edge cases and failure conditions

- Stacked bonuses exceeding a cap must not be lost when the cap changes or one source expires.
- Equal opposing modifiers still appear in breakdowns and remain independently removable.
- Permanent mutation while temporary effects exist changes the underlying value, then recomputes; effects must not overwrite it on expiration.
- Negative/over-100 live skills reach only consumers with explicit domain handling, not unchecked probability/index arithmetic.
- Invalid IDs or missing required mod definitions are distinct from legitimate zero values.
- Duplicate reconstruction/callbacks cannot apply a saved modifier twice. A stale source from an old session cannot change a replacement character.
- Permanent copies are distinct from full runtime snapshots; copying/querying/restore cannot generate fresh skill rolls.
- Restored invalid permanent values cannot silently clamp; migration/recovery must be explicit.

## Configuration and balancing options

Validated mods may define permanent bounds, base live attribute caps and supported modifier targets using stable IDs. Support CHAR-009 added skills with complete schemas/consumer contracts. New attribute types require the broader extension identified in CHAR-004; no automatic extra attributes are authorized.

Check compatibility with creation values, progression and derived formulas. Invalid or impossible definitions follow DATA-003 recovery, not hidden vanilla fallback. No universal live-skill cap, alternate temporary-to-permanent conversion or automatic stacking mode is introduced.

## Save/load considerations

Save permanent values and authoritative effect/equipment source state needed to reconstruct valid contributions. Live totals/cached modifier sums are derived and cannot serve as the underlying permanent state on restore. Any caches saved for engineering reasons must not be reapplied as additional authoritative sources.

Restore/validate definitions, permanent values and source references; reconstruct eligible contributions and consistent live values before dependent gameplay resumes. Required missing sources, invalid permanent values or unsupported references use explicit SAVE failure/migration policy. Do not silently skip an essential source, clamp state or announce readiness with partial values. Owner source restoration cannot replay permanent rewards or fresh-character grants.

Exact source expiry/time, equipment bindings, versioned schema and restore ordering remain MAGIC/ITEM/TIME/SAVE contracts. Preserve gameplay gating while reconstructing; notifications must not expose a half-restored character as ready.

## Technical constraints

Target: Godot 4.7.2. Separate permanent state, authoritative sources, resolved combination and UI views. Use stable IDs, safe arithmetic and explicit result categories; avoid short-narrowing overflow, positional mod-array assumptions or invalid-ID zero fallbacks. Concrete storage/event APIs and optimization strategy remain engineering choices. Reference source/content remain read-only.

## Acceptance criteria

1. Permanent/live values remain distinct; temporary application/removal never rewrites permanent development.
2. Vanilla permanent bounds 0–100 and validated overrides reject invalid mutations/restored values without silent clamping.
3. Live attributes follow the cap formula and valid nonnegative effective maximum; live skills remain unclamped within safe numeric domains.
4. Gameplay/progression consumers select the approved value type and document owner exceptions/local clamps.
5. Source-specific add/update/remove and repeated callbacks recompute correctly without duplicate stacking or loss of other contributions.
6. Capped 95+20 at cap 100 returns to 95 after removal, not 80; opposing/cap modifiers remain explainable and independently removable.
7. UI shows live/permanent comparison and inspectable source/cap breakdowns from actual resolved state.
8. Invalid IDs/targets/numbers fail explicitly; stable added-skill identity survives ordering/localization without automatically adding attributes.
9. Save/load reconstructs modifiers from authoritative sources before readiness, without double bonuses, permanent rewards or fresh random draws.
10. Missing required source/definition and invalid saved permanent state follow explicit failure/migration rather than default substitution or partial success.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001/004/006/008/009/010, relevant DATA-003/008 constraints and CORE lifecycle/restore requirements. No direct contradiction identified. Creation bounds and permanent bounds require compatibility but remain separate. CHAR-009's 0–100 starting values do not clamp temporary live skills. Permanent-based advancement is compatible with CHAR-010's practice scaling. Source reconstruction preserves startup duplicate protection; effect stacking and broader architecture are not approved wholesale.

## Outstanding questions and approval

No further blocking state-policy question is identified. Before implementation is complete: audit consumers/exceptions; define numeric/schema/source identity contracts; establish effect stacking/lifecycle and safe source-transition batches; finalize UI breakdowns, restore order/expiry and SAVE compatibility; validate added-skill consumer support. These dependencies cannot waive source-specific removal, explicit permanent validation or complete reconstruction before readiness.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-011-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented consumer/schema/stacking/UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
