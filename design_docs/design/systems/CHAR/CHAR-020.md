# CHAR-020 — Activity fatigue and practice

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Apply fatigue and raw skill practice for actual movement/activity over explicit time intervals, independent of rendering speed and without double-charging scripted time advances.

## Intended player experience

Running, climbing, swimming and jumping consume fatigue at predictable rates and award appropriate practice. Standing with a run input held does not train Running. Slow frames, loading and switching activity cannot create free time or repeated action rewards.

## Confirmed requirements

CHAR-020-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish vanilla activity costs/priority, Athleticism rules, actual-context elapsed accounting, frame-independent moving Running cadence, once-per-jump/qualifying-climb practice and bounded Swimming checks/racial behavior.

CHAR-012 owns raw practice/context/deduplication; CHAR-013 advancement; CHAR-018 fatigue mutation/units/depletion; CHAR-019 effective racial inheritance. CHAR-016 owns training intervals/costs and CHAR-021 rest recovery. MOVE owns actual motion/check validity; TIME supplies consistent clocks. This feature does not finalize exhaustion outcomes, movement success or breath consumption.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/PlayerEntity.cs#Update`: changed-game-minute branch chooses ordinary 11, climbing 22, moving-running 88, or swimming 44 on non-Argonian failed check; swimming otherwise retains ordinary 11. Climbing precedes running precedes swimming. Rest suppresses periodic fatigue deduction. The branch charges once for a changed clock rather than each skipped minute.
- Athleticism branch uses 0.9, or 0.8 with ImprovedAthleticism, only when career.Athleticism is true, truncating computed costs to int. These values are source approximations, now explicitly accepted as recreation baseline.
- Jump detection charges 11 times multiplier and tallies Jumping once until the jump state resets. Intended actual-jump identity avoids repeated callbacks.
- FixedUpdate tallies Running every fourth classic tick for IsRunning and not riding, without an explicit standing-still gate. Intended practice requires movement.
- `Game/GameManager.cs` declares classicUpdateInterval=0.0625 seconds (1/16), but resets its timer on crossing the interval; source real cadence varies with frame scheduling. Intended nominal 0.25 simulated-second Running cadence is explicit rather than exact runtime parity.
- `Game/Player/ClimbingMotor.cs#ClimbingSkillCheck` tallies before success evaluation. `RappelMotor.cs` tallies during its swooping update branch; intended owner-defined cadence replaces per-frame awards.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Runtime movement classification, scheduling, practice eligibility and time-skip propagation remain verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Periodic activity costs

Use internal fatigue units, with CHAR-018's 64 internal units per displayed unit. Vanilla rates per game minute: ordinary activity/standing 11; climbing 22; moving while running 88; swimming 11 normally or 44 after qualifying failure. These are replacement periodic rates, not additional costs stacked on ordinary drain.

Default priority: climbing, moving running, swimming, ordinary. Activity context must come from actual MOVE/owner state, not held keys alone or final state sampled after a long time jump. Riding and specialized motion require explicit MOVE classification; excluding riding from Running practice does not invent a separate riding-fatigue formula here.

Swimming applies its check/practice only when selected as periodic activity. Use the live Swimming value in a bounded 0–100 probability check, with explicit endpoint semantics: 0 always fails and 100 always succeeds. Failure for a non-Argonian selects rate 44; success selects 11. Argonian effective racial eligibility bypasses the higher-cost failure penalty, retaining 11, without bypassing normal costs or practice. Trait inheritance/suppression follows CHAR-019, not display-name matching.

### Athleticism and jump costs

Default multiplier m=1. If the class has Athleticism, m=0.9; with both class Athleticism and Improved Athleticism, m=0.8. Improved Athleticism alone does not activate the reduction under this baseline. Apply truncation to nonnegative activity rates/costs after the resolved multiplier, not repeated arbitrary frame fractions. The source applies this factor to ordinary activity as well as strenuous rates; retain that accepted baseline.

For reference, ordinary 11 becomes 9 or 8; climbing 22 becomes 19 or 17; running 88 becomes 79 or 70; high swimming 44 becomes 39 or 35. Jump's additional base 11 becomes 9 or 8. Supported overrides must update calculation/presentation consistently.

Charge the jump cost once per actual qualifying jump, in addition to periodic fatigue. Award +1 Jumping raw practice for the same jump. Duplicate start/animation/contact callbacks cannot charge or award again; MOVE defines the actual jump boundary and completion/reset, not a transient UI or render flag.

Fatigue drain uses CHAR-018 saturating drain rather than treating insufficient fatigue as a free action. Reaching zero emits the approved transition; CHAR-022/other owners decide exhaustion consequences and any action restrictions. Do not award simulated post-collapse activity without valid owner context.

### Time accounting and interval ownership

Account for every eligible elapsed interval under the activity actually performed. Do not charge once merely because game-minute value changed, or extrapolate the last movement state across missed time. Preserve ordered context segments or equivalent sufficient owner data for correct integration. Exact subminute boundaries and rounding/accumulator representation require a TIME/MOVE contract; frame or activity switching cannot erase unpaid eligible duration.

Keep game-minute fatigue timing distinct from short simulated-second practice cadence. Pause/readiness/loading gates prevent ordinary activity time/practice; no catch-up from wall-clock time spent in menus. A load establishes restored baselines rather than replaying activity since an old engine frame timestamp.

Rest owns its recovery interval and suppresses ordinary periodic fatigue. Training owns its declared elapsed fatigue/time; travel owns its simulation policy. Each interval has an authoritative activity owner so generic movement drain/practice does not charge the same period again. Supported interruptible training transfers context at the declared event boundary. This feature does not assume running during an entire travel skip or grant Swimming because the final pose is in water.

### Practice cadence

- Running: +1 raw use per 0.25 seconds of qualifying simulated running by default, requiring actual movement and not riding. Use accumulated eligible simulation duration, not frame count. Pauses/ineligible frames add no duration; accounting cannot discard already-earned time simply because frame boundaries vary.
- Swimming: +1 raw use per eligible game-minute swimming tick when swimming is selected periodic activity, including failed checks and Argonian exemption from the higher cost.
- Jumping: +1 once per actual jump, matching the one-time fatigue charge.
- Climbing: +1 per qualifying movement-owned climbing check, including failed checks. Repeated callback delivery is not a new check.
- Rappelling: explicit MOVE-owned qualifying practice cadence; do not award once per render/update. Exact baseline cadence must be established by its movement specification before implementation is complete.

Apply CHAR-012 validation, saturation and source identity to reports, without reflex/career scaling or direct permanent gains. CHAR-013 handles live/default advancement appropriately. Holding run while stationary, recreating a panel, restoring an effect or reloading cannot generate movement practice.

## Relevant formulas and parameters

For selected base periodic rate r and Athleticism multiplier m, resolved rate R=trunc(r×m) internal units/game minute. Integrated fatigue corresponds to eligible activity duration at R with an explicit consistent fractional/rounding accumulator contract; independent render slicing must not change total cost.

Jump cost J=trunc(11×m), once per qualifying jump. Running practice count derives from accumulated qualifying simulated duration divided by 0.25 seconds, retaining unspent cadence remainder under the approved context/save contract. Swimming check probability p=clamp(live Swimming,0,100).

All parameters/counters/durations require safe numeric ranges. Explicit final probability/rate rounding is gameplay behavior, not permission to repair malformed definitions or saved state silently. No new Athletics skill or fatigue recovery formula is introduced.

## Configuration and balancing options

Validated mods may override supported activity rates/priority, Athleticism factors and practice cadences/amounts through owner definitions. Priority rules must be deterministic and complete; invalid/ambiguous rules fail validation. Use nonnegative supported costs, positive finite cadences and compatible unit conversions. Race-condition overrides remain CHAR-019/MOVE-owned.

DATA-003 precedence/locking applies. Additional executable activity types, partial-time random-check schemes or unrelated survival mechanics require explicit owner support. No universal anti-grinding penalty or default practice-per-frame mode is introduced.

## Required data

Validated rates/priority/modifiers; authoritative motion/activity/race/live-skill context; consistent game/simulation clock mapping; eligible duration segments and fractional/cadence remainders; actual jump/check/tick identities; interval ownership and session context; mutation/practice results. Concrete schemas and integration representation remain technical dependencies.

## Inputs, outputs and events

Inputs: activity transitions, elapsed eligible time, jump/climbing checks, modifier/race changes, pause/readiness and restore context. Outputs: validated once-only fatigue drains, raw practice reports, current activity diagnostics or explicit invalid-context/configuration results. Conceptual contracts do not prescribe APIs/signals. Exhaustion/death/recovery outcomes remain owner-controlled.

## Cross-system interactions

MOVE classifies motion and checks; TIME integrates clocks/owned intervals; CHAR-011 supplies live stats, CHAR-019 racial inheritance and MAGIC/ITEM resolved Athleticism effects. CHAR-018 drains fatigue, CHAR-012 tracks practice and CHAR-013 advances. CHAR-016 training, CHAR-021 rest and travel owners prevent double simulation. CHAR-022/023 respond to depletion. UI/DEV inspect state; DATA/MOD validate configuration and CORE/SAVE scope/restore it.

## Edge cases and failure conditions

- Several elapsed minutes cannot become one minute's cost; final activity cannot represent an unrelated earlier interval.
- A one-minute interval cannot be billed by both training/rest/travel and ordinary activity logic.
- Standing run input yields no Running practice; actual repeated jumps/checks count once each despite duplicate callbacks.
- Failed Swimming still earns qualifying practice; Argonian exemption affects cost, not all fatigue or unrelated racial rules.
- High/negative live Swimming uses explicit probability bounds rather than unsafe arithmetic.
- Pause/load/startup and dead/invalid activity cannot accumulate wall-clock practice or drain phantom minutes.
- Zero fatigue hands off once to exhaustion; no negative pool or post-collapse practice from stale state.
- Frame rate, activity toggling and save/load cannot reset cadence/debt to farm practice or avoid cost.

## Save/load considerations

Preserve authoritative ongoing activity/time context and required integration/cadence remainders where needed to prevent free refill/repeated practice. Restore under CHAR-017 without replaying elapsed intervals or jump/check events. Raw counters remain CHAR-012 state and must not be reconstructed by replaying motion.

SAVE/TIME/MOVE define exact fractional representation, paused/activity boundaries and supported ongoing-action restoration. Missing/inconsistent required context uses explicit migration/recovery rather than assuming the loaded pose applied to an entire time gap. Rule changes require compatible locked configuration/migration, not silent debt truncation.

## Technical constraints

Target: Godot 4.7.2. Separate activity classification, time integration, mutation and practice reporting. Use explicit units, safe arithmetic, reproducible event boundaries and authoritative interval ownership; do not use rendering cadence as gameplay rate. Exact timers, event APIs, schemas and accumulators remain engineering decisions. Reference source/content remain read-only.

## Acceptance criteria

1. Vanilla periodic rates/priority and additive jump costs match the approved values in explicit internal units.
2. Athleticism uses agreed eligibility/factors/truncation; Improved alone does not activate reduction by default.
3. Every eligible duration is charged using actual context without single-change undercharging or final-state extrapolation.
4. Owned rest/training/travel intervals do not double-charge ordinary activity or invent movement practice.
5. Moving, nonriding Running earns +1 per 0.25 simulated seconds independent of frame rate; stationary run input does not.
6. Jump charges/+1 practice occur once per actual jump; qualifying Climbing includes failures and rappelling has explicit owner cadence.
7. Selected Swimming awards +1/minute, uses bounded live-skill probability and applicable Argonian ordinary-cost exemption.
8. Pause/load/reconstruction/stale callbacks cannot accumulate phantom drain/practice; exhaustion uses CHAR-018/022 handoff.
9. Validated mod rates/priority/cadence remain deterministic and compatible; saved timing/remainders cannot create double awards or free interval loss.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-002/005/011/012/013/016/017/018/019 and relevant CORE timing/readiness and DATA-003 constraints. No direct contradiction identified. Source rate approximations are explicitly retained while clock-change/frame-dependent accounting is deliberately corrected. Raw practice remains unscaled. Training/rest own time skips, and fatigue drain differs from an insufficient-resource action cost. Racial identity follows declared inheritance rather than display labels. Breath/outcome policies remain their separate owners.

## Outstanding questions and approval

No further blocking activity-policy question is identified. Before implementation is complete: finalize TIME/MOVE subminute integration, random Swimming tick boundaries and pause clock mapping; establish rappelling cadence and qualifying check/jump identity; define riding/special-movement classification and supported mod schemas; verify interval transfer, fractional/save restoration and exhaustion interaction. Dependencies cannot waive every-interval accounting, frame-independent practice or no-double-charge ownership.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-020-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented TIME/MOVE cadence/integration, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
