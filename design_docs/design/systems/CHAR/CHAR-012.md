# CHAR-012 — Skill use tracking

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Record meaningful practice independently of permanent skill increases, safely retaining owner-reported use for later advancement evaluation.

## Intended player experience

Qualifying activities accumulate practice without immediate skill gains or raw-counter UI clutter. Legitimate repeated actions count under their own cadence; duplicate callbacks, loading and previews cannot create or erase progress.

## Confirmed requirements

CHAR-012-D01–D08 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish zero-initialized raw counters, safe 20,000 saturation and mod caps, separate advancement conversion, owner-defined sources, nonnegative reports, duplicate protection, diagnostics-only visibility, valid living-session context and explicit save migration.

CHAR-010 reflex scaling remains an advancement-check rule, not a tally multiplier. CHAR-011 separates permanent/live skills and source modifiers from practice. CHAR-006/009 and CORE-012 initial skills/biography are starting state rather than earned use. CHAR-013 owns consumption/reset timing and conversion; this feature does not finalize those policies.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/PlayerEntity.cs#TallySkill` indexes a short[] by skill enum, adds a signed short amount and then clamps to 0–20,000, logging caught exceptions. Compound assignment narrows before the clamp, allowing overflow to turn a large positive accumulation negative and then zero. Intended safe saturation excludes that behavior.
- `PlayerEntity.RaiseSkills` later scales recorded uses by reflex setting and compares against advancement requirements; qualifying counters reset there. This is source behavior, not approval of CHAR-013 reset/carryover rules.
- Caller search identified movement/recovery, combat, magic, social/crime/economy and training paths listed below. A call's presence does not prove its full eligibility conditions or cadence without branch inspection.
- `Game/Serialization/SerializablePlayer.cs` stores/restores SkillUses and supplies a zero array for null data. Intended stable-ID validation/migration is explicit rather than blanket null/array-position fallback.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete branch eligibility, runtime duplicate delivery and timing remain owner verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Counters and reports

Maintain an integer raw-practice counter per supported stable skill ID. Fresh characters start at zero; initial skill grants do not count as earned practice. Vanilla maximum is 20,000 inclusive, with validated mod-configurable caps. Counters are independent of current permanent/live skill values.

Ordinary practice reports carry a valid skill, nonnegative integer amount and sufficient originating activity/session context. Zero is a valid no-op. Negative amounts, unknown IDs, unsupported numeric inputs and invalid contexts fail explicitly without changing counters. Deliberate deductions, consumption or resets use separate authorized progression operations, not negative practice reports.

Use safe saturating arithmetic: a sufficiently large valid addition reaches the cap rather than wrapping. Reaching the cap means further accepted practice may contribute zero until authorized progression changes the counter. Saturation is an approved tracking rule, distinct from forbidden silent repair of invalid saved data.

### Separation from advancement

Record raw amounts without reflex, career advancement or temporary-skill multipliers. Tallying does not immediately increase a skill, evaluate level eligibility or trigger mastery. CHAR-013 applies relevant scaling/thresholds and determines consumption/carryover/reset policy. Do not reset simply because a skill is currently capped unless the later approved progression rule requires it.

Permanent/live skill changes from effects or initialization do not themselves imply practice. Source owners can explicitly report qualifying activity, but mere stat assignment, previewing or restoring state cannot generate a report.

### Practice sources and owner contracts

Retain inspected DFU categories as baseline. Each owner must specify qualifying trigger, skill, amount, success/failure eligibility, cadence and unique action/tick boundary. Do not impose universal successful-actions-only eligibility or universal anti-grinding penalties.

| Category | Inspected source anchors and reported skills |
| --- | --- |
| Movement/recovery | PlayerEntity running/swimming/jumping and Medical paths; Player/ClimbingMotor and RappelMotor for Climbing; DaggerfallRestWindow Medical |
| Combat | WeaponManager weapon/Hand-to-Hand and Critical Strike; EnemyAttack Dodging; FormulaHelper Backstabbing |
| Magic | MagicAndEffects/EntityEffectManager reports the effect's declared magic skill |
| Perception/social | EnemySenses language/Stealth; TalkManager and DaggerfallCourtWindow Etiquette/Streetwise |
| Interaction/crime/economy | Internal/DaggerfallActionDoor and PlayerActivate Lockpicking; PlayerActivate, inventory/trade windows Pickpocket; DaggerfallTradeWindow Mercantile |
| Training/quest instruction | DaggerfallGuildServiceTraining and Questing/Actions/TrainPc report configured training amounts |

Many inspected call sites pass 1; EnemySenses passes 3 for successful language pacification and 1 for another result. These are source evidence, not a complete approved per-action rate table. Paid training semantics, repeated attempts, recovery cadence, missed attacks and failed interactions remain owner specifications. Validated data overrides may configure supported amounts/cadence where the owning feature declares them; this does not authorize arbitrary new executable practice events.

### Duplicate protection and simulation context

Count each qualifying action or scheduled practice tick once despite repeated callback delivery. Distinguish a true repeated action/tick from redelivery of the same one; do not collapse all similar actions into one. Activity owners provide reliable completion/cadence identity and CHAR ensures their accepted contribution is not duplicated. Concrete IDs/deduplication storage are engineering choices, not a requirement for unbounded global event history.

Accept reports only for the current living character from valid gameplay or explicitly approved simulated activity, including eligible training/time-advanced recovery. Ignore stale callbacks from old sessions/activities; reject preview/load/initialization and already-dead-character reports. Paused UI alone does not establish qualification: owners declare which paused or time-advanced activities legitimately simulate practice.

No blanket cooldown, diminishing returns, enemy-threat requirement or anti-grinding tax is added here. Owner-specific eligibility must still prevent accidental per-frame repetition where one action was intended.

### Visibility and diagnostics

Keep raw counters out of the ordinary character sheet initially. Developer diagnostics can inspect skill identity, current counter/cap and report results, including rejection, duplicate suppression and saturation where useful. Follow CORE-002 logging/privacy rules; this does not require logging every gameplay event. Skill-increase notifications remain CHAR-013 scope.

## Relevant formulas and parameters

For current counter C, validated nonnegative addition a and configured cap K≥0: Cnew=min(K,C+a), with 0≤C≤K before mutation. Compute safely, for example comparing a with K−C before addition. No signed-short narrowing/wrap is permitted.

Vanilla K=20,000. Effective added practice is Cnew−C and can be less than a due to saturation. Reflex/class factors are absent here. Authorized progression deductions/resets and exact activity rates are separate contracts.

## Required data

Stable skill identity/classic mapping; validated cap definitions; counter values; active character/session and originating activity/tick context; accepted-report duplicate-protection state where needed; and explicit restore/migration metadata. Concrete schemas and deduplication lifetime remain owner/SAVE dependencies.

## Inputs, outputs and events

Inputs: validated practice reports, authorized progression counter operations, fresh-character initialization and restore/migration results. Outputs: updated/raw counter and accepted/no-op/saturated/duplicate/rejected result as appropriate. These are conceptual contracts, not API/signal names. Queries/diagnostics do not replay reports or trigger advancement.

## Cross-system interactions

MOVE/COMBAT/MAGIC/NPC/UI interaction, LAW/ECON/QUEST and recovery owners define qualifying activity. CHAR-013 consumes counters; CHAR-010 supplies later reflex scaling and CHAR-005 career advancement remains separate. CHAR-011 supplies stable skill definitions/permanent-live separation. DATA-003 resolves mod rules; CORE-005/007 scope/readiness prevents stale activity; SAVE restores authoritative counters without replay; DEV/UI provide diagnostics.

## Edge cases and failure conditions

- Huge positive additions saturate safely; negatives cannot erase practice. Missing arrays/IDs are explicit invalid state, not silent successful zeros.
- Duplicate ticks do not double count, while actual repeated actions remain eligible by their owner cadence.
- Full counters retain K rather than wrapping to zero; capped skills do not automatically discard counters in this feature.
- Dead/old-session callbacks, previews, scene reconstruction and effect reapplication cannot award use.
- Approved simulated recovery/training can qualify despite UI pause; ordinary menu time cannot generate practice by implication.
- Loading and retry must not replay past activity or duplicate already-saved practice.
- Modded cap reductions cannot silently truncate saved values; added skills cannot inherit positional counters from another skill.

## Configuration and balancing options

Validated mods may override supported counter caps and owner-declared practice amounts/cadence. Use stable skill IDs including supported added skills under CHAR-009/011. Caps must be nonnegative supported integers and compatible with advancement/numeric domains; invalid definitions follow DATA-003 recovery rather than hidden fallback. No generic decay, cross-skill pool, negative-use mechanism or universal anti-grinding rule is introduced.

## Save/load considerations

Save/restore counter values exactly by stable skill ID, without replaying practice events or applying reflex scaling. Validate all required references, bounds and required fields. Invalid, missing-required or over-cap saved data—including a lowered mod cap—requires explicit SAVE migration/recovery rather than silent zeroing/truncation. New skills begin at zero only through a declared compatible migration; unknown legacy arrays need explicit classic-ID mapping.

Activity/resume and duplicate-protection state must be sufficient to avoid replay when supported operations resume, but no arbitrary event-history format is selected. CORE/SAVE must gate gameplay until required counter/activity restoration is consistent. Fresh-character zero initialization is distinct from load-time missing-data recovery.

## Technical constraints

Target: Godot 4.7.2. Separate raw counters, report validation, activity eligibility and advancement. Use stable IDs, bounded safe arithmetic and session-scoped stale-work protection; do not rely on exceptions and array indices as normal validation. API names, event identities, serialization and optimizations remain engineering choices. Reference source/content remain read-only.

## Acceptance criteria

1. Fresh supported skills start at zero; ordinary reports safely saturate at vanilla 20,000 or valid resolved caps.
2. Negative/invalid-ID/context reports leave state unchanged; large valid additions cannot wrap or destroy progress.
3. Reports remain unscaled and cannot directly increase skills/levels. Counter consumption/reset follows separately approved CHAR-013 rules.
4. Owner-defined source eligibility/rates/cadence distinguish actual repeated activity from duplicate delivery without universal anti-grinding penalties.
5. Current living gameplay and approved simulated activity qualify; previews, initialization, loading, dead characters and stale callbacks do not.
6. Raw counters remain outside ordinary character-sheet UI and are inspectable in developer diagnostics.
7. Save/load retains exact counters by stable ID without event replay/scaling; invalid/missing-required/over-cap data requires explicit recovery/migration.
8. Added skills start at zero only through declared migration; cap changes cannot silently truncate saved practice.
9. Supported mod caps/source parameters remain validated and compatible with numeric/advancement domains.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-006/009/010/011, DATA-003 and relevant CORE lifecycle/startup/restore requirements. No direct contradiction identified. Raw practice is distinct from permanent/live skills and later reflex scaling. Saturation on valid reports does not authorize silent save repair. Nonnegative reports do not preselect CHAR-013 reset/carryover behavior. Initial biography/training-related inputs must distinguish fresh grants from separately approved simulated practice. Full source behavior remains owner-reviewed rather than inferred from call presence.

## Outstanding questions and approval

No further blocking raw-tracking policy question is identified. Before implementation is complete: verify complete caller/eligibility/rate inventory; define source tick/action identities and resumed-activity deduplication; establish advancement counter-operation contracts; validate mod schemas/numeric compatibility; finalize diagnostics and SAVE migrations. These dependencies cannot waive safe saturation, valid context, duplicate protection or exact restoration.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-012-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented eligibility/cadence, advancement, deduplication and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
