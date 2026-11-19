# RULE-015 — Timing and adjustment hooks

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Calculate bounded player melee-frame timing and bow cooldown, and expose explicit weapon accuracy/damage adjustment stages with captured attack timing context.

## Intended player experience

Live Speed affects newly started attacks predictably. Extreme modded Speed cannot produce zero-duration schedules. An attack retains its timing through buffs/equipment changes, while pauses/loading add no attack elapsed time. Mods may use explicit timing inputs without introducing new vanilla timing-based damage or accuracy bonuses.

## Confirmed requirements

RULE-015-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve moddable baseline helpers/hooks, separate positive minima (1/60 second melee frame; 0.1 second bow cooldown), pass-through adjustment stages, attack-start timing snapshots and gameplay-time elapsed accounting.

RULE-013 owns final accuracy; RULE-014 owns weapon damage stages/backstab/critical. RULE-004 owns hook validation/selection/failure. CORE-015/016/017 eligibility and pause rules remain binding; COMBAT/AV own attack lifecycle and animation phases.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#GetMeleeWeaponAnimTime` returns 3×(115−live Speed)/980. Weapon type/hands are available to its override but unused by default. `classicFrameUpdate` is 980.
- `GetBowCooldownTime` returns (10×(100−live Speed)+800)/980. Neither default helper enforces the intended positive minima.
- `Game/FPSWeapon.cs#GetAnimTickTime` uses the melee helper for non-bow animation ticks; bow timing uses a different classic-update interval. Thus the melee result is a frame interval, not total swing time or every weapon's universal cadence.
- `Game/WeaponManager.cs#Update` sets a bow cooldown deadline after an attack finishes. The inspected damage path converts ScreenWeapon.GetAnimTime to milliseconds.
- `FormulaHelper#AdjustWeaponHitChanceMod` and `AdjustWeaponAttackDamage` receive attacker/target/current value/elapsed animation milliseconds/weapon and return their input unchanged by default. The former is called after weapon material accuracy contribution and before CalculateSuccessfulHit; the latter follows weapon enemy-type damage adjustment and precedes backstab.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full animation/clock/caller timing and runtime parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Baseline durations and minima

For captured valid live Speed S, melee frame interval is Tm=max(Mm,3×(115−S)/980) seconds. Bow cooldown is Tb=max(Mb,(10×(100−S)+800)/980) seconds. Vanilla Mm=1/60 second and Mb=0.1 second; both minima and supported formula parameters are moddable.

The melee helper returns time per authored animation frame, not whole-swing duration, contact time or a fixed physics step. Bow cooldown is a separate duration, not bow draw time or bow animation-frame interval. Default melee timing does not differ by weapon type/hands, but explicit hooks can use those inputs. NPC attack cadence is not automatically converted to these player helpers.

Validate positive finite supported minima and safe formula arithmetic. A finite formula value below its minimum, including a negative result at valid extended Speed, saturates to the configured minimum by policy. Nonfinite/overflowing values and invalid configuration are errors, not hidden minimum/default successes. Supported duration overrides must obey the declared output/minimum contract; they cannot bypass safeguards accidentally.

At Speed 100, Tm=45/980≈0.045918 seconds and Tb=800/980≈0.816327 seconds, above the minima. The 1/60-second minimum does not establish a 60 Hz simulation requirement or guarantee any rendering rate. COMBAT/AV must handle scheduling/overload without duplicate contact or unbounded zero-time loops.

### Attack-start capture

At owner-defined attack start, capture live Speed, weapon identity/type/hands, resolved timing configuration/provider context and resulting durations. Keep that attack's frame interval and resulting cooldown fixed. Later buffs, debuffs or equipment changes affect later attacks, not the captured schedule. This does not itself forbid equipment switching or choose its interruption policy; COMBAT/ITEM own that behavior.

COMBAT must define the exact begin boundary and when bow cooldown starts, including cancellation/interruption cases. Those rules cannot silently recalculate this attack's cooldown from later Speed. Do not apply a bow cooldown to unrelated melee frames merely because both durations were calculated by shared code.

Captured timing is not a global freeze of damage, target state or all modifiers. RULE-013/014 and COMBAT continue to define coherent resolution snapshots/live rereads. Projectile source/equipment capture and in-flight changes require explicit COMBAT contracts rather than a mutable last-weapon lookup.

### Elapsed time and hook units

Measure elapsed attack time from authorized gameplay intervals within the declared attack phase. Exclude pause/loading/ineligible intervals; do not substitute wall-clock time, rendered frame count or UI delay. Explicitly authorized attack/timing progression still follows CORE eligibility, not window appearance alone.

Convert nonnegative finite gameplay seconds to hook milliseconds through a documented supported numeric contract. For a source-compatible integer adapter, truncate toward zero after multiplying by 1000; preserve higher-resolution authoritative elapsed time separately if needed rather than repeatedly rounding accumulated intervals. Exact broader hook representation can differ if declared/versioned. Overflow is an explicit error.

Bow draw/release/hold phases and any input-dependent timing bonuses remain COMBAT-owned. This feature does not introduce a charge damage curve, minimum draw, maximum hold or cancelled-shot penalty from an elapsed-time argument alone.

### Adjustment stages

Weapon hit adjustment takes the resolved route modifier after weapon material accuracy and before RULE-013's body/defense/critical/final chance calculation. It is not a second hit roll or automatically a post-clamp probability replacement. Weapon damage adjustment runs at RULE-014's weapon stage after enemy-type adjustment, before backstab/critical/final successful-hit minimum. Its name must not imply it runs after every multiplier.

Built-in adjustment behavior passes through unchanged. Supported mods may use explicit attacker/target/weapon/timing context to adjust the value under a declared contract. Do not grant a timing-based bonus in vanilla or duplicate RULE-014's critical-damage policy here.

RULE-004 governs stable IDs, signatures, resolved-order provider selection, run-long lock and runtime failure without automatic fallback. These numeric adjustment contracts do not authorize health/equipment mutation, practice awards or diagnostic-triggered random draws. Any additional owner-authorized random behavior requires an explicit RULE-003 source/result contract rather than implicit global RNG. Queries cannot resolve attacks.

## Relevant formulas and parameters

- Tm=max(Mm,3×(115−S)/980), seconds per melee frame.
- Tb=max(Mb,(10×(100−S)+800)/980), seconds of bow cooldown.
- Mm=1/60 second; Mb=0.1 second, independently moddable.
- Eligible elapsed E is accumulated authorized gameplay duration, with no pause/load contribution.
- Source-compatible integer hook milliseconds=trunc(1000×E), subject to supported range.
- Default hit/damage adjustments return their input unchanged.

Speed 115 gives raw melee interval zero and therefore Mm. Speed 180 gives raw bow cooldown zero and therefore Mb, if those extended values are valid under the resolved character domain. Invalid Speed/definitions must not be repaired silently to reach these examples.

## Required data

Stable attack/session identity; captured Speed/weapon context/provider/timing parameters and durations; explicit attack-phase origin/eligible elapsed state; adjustment input values; selected hook provenance; owner-defined lifecycle/commit state. Concrete timing-phase IDs, deadlines and serialization remain dependencies.

## Inputs, outputs and events

Inputs: authorized attack-start context, validated timing definitions and numeric adjustment requests with declared elapsed units. Outputs: captured bounded durations, adjusted values or explicit error. This feature does not create contact, release arrows, award practice or remove health. COMBAT/AV own scheduling and committed events; APIs/signals remain unselected.

## Cross-system interactions

CHAR-011 supplies live Speed; ITEM supplies valid weapon identity/type/hands; COMBAT/AV define attack phases/frames/contact/cooldown; CORE-015/016/017 gate time and ordering. RULE-013/014 own adjustment consumers and final limits/damage. RULE-004/DATA-003 validate locked hooks/parameters; RULE-003 governs any explicitly supported randomness. SAVE restores supported attack phases without free time/replay; UI/DEV explain captured timing.

## Edge cases and failure conditions

- Extended Speed cannot produce zero/negative committed durations; nonfinite/overflowing overrides fail explicitly rather than being clamped as ordinary computed values.
- Buff removal or weapon changes mid-attack cannot rewrite captured schedule; COMBAT can still explicitly interrupt/cancel.
- Pause/resume/loading do not improve timing-based outcomes, and fractional eligible elapsed time is not lost by per-frame integer conversion.
- Duplicate callbacks cannot restart cooldown or deliver another hit. Source helper invocation does not authorize an attack.
- Missing required weapon/session/timing context, stale work and failed hooks use owner/CORE recovery without silent pass-through fallback after failure.

## Configuration and balancing options

Support validated timing coefficients/denominator/minima, weapon-type/handedness timing hooks and explicit hit/damage adjustment hooks. Denominators/minima must be finite positive supported values; parameter sets and outputs must fit safe duration/numeric domains. No player attack-speed slider, NPC cadence rewrite, automatic bow charge bonus or generic animation scheduler is introduced.

## Save/load considerations

General mid-attack saves are not approved by this feature. Where COMBAT/SAVE supports resumption, retain captured durations/phase/eligible elapsed and commitment state sufficient to avoid recalculation, free cooldown completion or repeated hits. Do not advance wall-clock pause/load duration or recapture later Speed. If the owner instead cancels an attack on load, its explicit policy must define cooldown/commit consequences. Invalid required state uses migration/recovery, not zero-duration readiness.

## Technical constraints

Target: Godot 4.7.2. Keep units explicit and separate frame interval, total animation time, cooldown and damage-stage timing. Use finite safe arithmetic, immutable attack timing context and gameplay-time eligibility. Concrete scheduler/frame representation/hooks/schema remain engineering dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Vanilla formulas match representative Speed 0–100 values and interpret melee result per frame, bow result as cooldown.
2. Valid extended Speed/overrides respect independently configurable positive minima; malformed/nonfinite/overflowing definitions fail explicitly.
3. Attack-start captures survive later Speed/equipment changes without silently recalculating the current schedule/cooldown.
4. Pause/loading/ineligible time adds no elapsed; conversion preserves fractional authoritative time and declared milliseconds semantics.
5. Hit/damage hooks default pass-through and execute only at their declared RULE-013/014 stages, without new vanilla timing bonuses.
6. Queries/duplicate delivery do not commit hits, effects or cooldown resets; failed hooks follow explicit recovery without automatic fallback.
7. Supported restore respects captured timing/commitment without wall-clock catch-up or replay, under explicit COMBAT/SAVE policy.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-011, CORE-015/016/017 and RULE-003/004/013/014. Attack timing capture is distinct from later hit-state rereads. Positive minima explicitly extend the baseline to safe extended-Speed behavior without selecting simulation frequency. Damage hook remains before backstab/critical, preserving RULE-014. Pause exclusion and locked provider selection remain binding; COMBAT phase/commitment rules are not inferred from DFU animation code.

## Outstanding questions and approval

No blocking timing policy question remains. Before implementation: finalize parameter/output domains, attack-start/bow-cooldown/cancellation phases, elapsed adapter representation, captured projectile context, scheduler/contact handling and SAVE resumption policy. These cannot waive separate positive minima, captured schedules, pause exclusion or approved adjustment stages.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-015-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering, COMBAT/AV timing-phase and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
