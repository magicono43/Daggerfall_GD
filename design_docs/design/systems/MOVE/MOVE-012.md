# MOVE-012 — Rappel and edge transitions

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Allow deliberate backward ledge departure to become a controlled wall attachment, then ordinary climbing. Reliable eligible transitions remain collision-safe; failed routes cannot provide fall immunity or repeated practice. Rappel here is an edge maneuver, not a newly introduced rope item system.

## Confirmed requirements

MOVE-012-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. Rules below consolidate those choices. MOVE-004/006/010/011 authority, clearance, fall and climbing contracts and CHAR-020 activity rules remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/Player/RappelMotor.cs#InitialSetRappelType` requires advanced climbing and backward intent, falling without a jump, and other eligibility flags. It selects adjacent surfaces behind the player.
- `RappelChecks` advances Activated, Swooping and Grappling stages; active positioning can directly assign the controller transform along a curve, then use ground-motor movement toward a wall. It tallies Climbing during swooping updates.
- `CurlDown`/`CurlOver` have reference duration 0.7 seconds and vertical displacement 1.60; direction-specific constants differ. Ceiling-related paths include commented branches, not evidence of a complete target hanging feature.
- `Start` registers an active-stage save restriction. `ResetRappelState` clears stage/direction/timer. `PlayerMotor.FixedUpdate` invokes rappel checks before climbing while on foot.

Target behavior replaces unchecked positioning and frame-based practice with coordinated collision motion and one success award. Source constants and all source eligibility shortcuts are not adopted automatically.

## Detailed rules and behaviors

### Scope and entry

Deliberately backing over an eligible ledge initiates positioning toward a validated reachable wall. No separate Rappel button initially. Require a full-body route and standing-shape attachment clearance under MOVE-006/011. Backward departure at an unsuitable edge remains a fall, not an automatic rescue.

Initial scope is ledge-to-wall attachment and handoff to MOVE-011. Ceiling hanging and underside traversal chains are excluded. Exact ledge detection, reach, small-drop exclusion and mode compatibility require geometry fixtures; no universal reach or source curve dimensions are approved.

### Positioning and grip

Move through a collision-checked route under MOVE-004 authority. Do not assign unchecked curve positions or clip through lips/ceilings. Exact route and timing are validated moddable tuning. Keep path eligibility current as geometry changes.

Releasing Backward after entry does not cancel the short sequence. Fresh Crouch explicitly aborts and is consumed without toggling posture. Jump-based wall exit is available after established grip via MOVE-011; no separate positioning jump behavior is introduced.

A validated transition guarantees initial grip only once actual wall contact and full standing-shape clearance are established. No random draw is consumed for that grip. Normal climbing continuation/recovery checks follow MOVE-011 afterward. Positioning alone grants no fall protection: retain the existing airborne segment until actual supported attachment ends it under MOVE-010. Initial grip must not trigger a second ordinary entry roll.

### Failure and bounds

Use validated maximum positioning duration and travel distance. Lost wall eligibility, blockage or exceeded bounds ends the attempt. Select actual valid supported movement if support exists, otherwise ordinary falling from actual pose with existing fall history. No snapback to the ledge, fabricated landing, collision bypass or fall reset.

Renewed deliberate approach is required before retrying the same failed attempt; holding Backward cannot generate an immediate failure/re-entry loop. Exact gate must support analog intent. Missing required components/data use CORE/MOVE checked recovery rather than pretending a normal geometry rejection succeeded.

### Activity accounting

Active positioning counts as climbing activity for CHAR-020 fatigue, including duration spent on attempts later cancelled/failed. No additional one-time fatigue charge. Report actual ordered activity time; transition completion cannot double-charge an interval already reported as climbing.

Award one Climbing practice use per successfully completed ledge-to-wall transition. Failed/cancelled positioning awards none. This is a distinct traversal award, not a fabricated skill check: guaranteed grip adds no second practice award or random draw. Subsequent genuine MOVE-011 checks retain their own once-only practice. Repeated contact/animation/handoff callbacks cannot repeat the transition award.

### Pause, save availability and handoff

Pause retains stage/progress and physical history while suspending positioning, eligible timers and fatigue without catch-up. Retain valid save-restriction ownership through pause.

Prevent saves during positioning with a clear reason. After attachment or exit, release only this feature's restriction; other save restrictions remain binding. Unfinished-transition serialization is outside initial scope. Successful grip hands state to MOVE-011's supported native save contract, with no replayed practice. Teardown cleans up restriction ownership without making an unready session saveable.

## Relevant formulas and parameters

Positioning elapsed time and traveled distance must remain within validated configured bounds. Exact measurement definition, duration, reach, curve and speed require scale/collision fixtures; do not assume DFU's 0.7 seconds/1.60 displacement as target defaults.

Practice is one raw Climbing use per successful transition, zero for failure/cancellation; fatigue uses CHAR-020 climbing rate and applicable trait resolution. No entry probability is required for guaranteed validated grip; geometry eligibility remains mandatory.

## Required data

Transition identity/stage, source ledge and target wall identity/contact context, actual shape/posture, route validity, actual position/motion/fall history, elapsed eligible time/travel, bounds, cancellation/re-entry gate, success/practice completion state and owned save restriction. Concrete stage representation and surface IDs remain engineering dependencies.

## Inputs, outputs and events

Inputs: backward approach, eligible edge/wall observations, Crouch abort, collision/geometry changes, timer/travel progression and suspension/teardown. Outputs: checked positioning motion, supported grip/handoff or exit, actual activity duration, once-only success award and save-availability reason. API/signal names remain unselected; input or path activation alone is not a successful grip.

## Cross-system interactions

MOVE-001/002 own intent/bindings, MOVE-004 physical authority/mode arbitration, MOVE-006 shape clearance, MOVE-007 small steps/drop boundary, MOVE-009 airborne motion, MOVE-010 fall history and MOVE-011 grip/controls/restoration. CHAR-012/020 own practice/fatigue, WORLD/LOC/DATA geometry identity, CORE suspension/readiness/scope cleanup, SAVE availability and MOD validated traversal tuning. No rope inventory or new hanging system is introduced.

## Edge cases and failure conditions

Low ledges and unsuitable walls remain normal support/fall transitions rather than forced rappels. Blocking lips, overhangs, corner routes and moving targets need full-shape checks. A stationary mechanism becoming moving revalidates target eligibility under MOVE-011.

Abort/failure retains actual motion/history without teleporting to the start. Pause cannot expire bounds or accumulate activity. A successful handoff cannot double-roll entry, double-award practice or briefly expose an uncoordinated motor. Failed attempts cannot loop practice or protection. Ending/replacing session invalidates stale path callbacks and save-restriction references.

## Configuration and balancing options

Route geometry, timing and validated duration/distance limits are moddable through supported contracts. Vanilla uses backward ledge entry, guaranteed eligible attachment and explicit Crouch abort. Exact override/provider semantics and allowed domains remain MOD/DATA integration work. No ceiling chains, arbitrary pass-through, per-frame practice or unfinished-transition saves are introduced.

## Save/load considerations

No native saves during active positioning. Present the reason and restore availability only when this transition ends, respecting other restrictions. Do not silently queue a save for later without SAVE's policy. Supported post-attachment saves use MOVE-011 wall/grip validation; completed transition practice remains completed. Loaded sessions cannot inherit stale active positioning or save locks from the discarded session.

## Technical constraints

Target: Godot 4.7.2. Coordinate route/collision and checked handoff through one physical authority, with bounded eligible-time/distance progress and scope-safe ownership. Concrete probes, path solver, restriction tokens and activity identity are implementation choices to verify. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Deliberate backward ledge departure starts only a reachable full-body route; unsuitable edges fall normally.
2. Initial scope excludes ceiling hanging/underside chains and needs no separate Rappel button.
3. All route motion is collision-checked; blockage cannot teleport/clip through geometry.
4. Released Backward does not abort; fresh Crouch aborts once without posture-toggle fall-through.
5. Grip requires actual contact/standing clearance, consumes no draw and hands off without a duplicate climb-entry check.
6. Positioning grants no fall protection; only actual supported attachment ends damaging fall history.
7. Failure/bounds exit from actual pose without snapback/history reset; held input cannot immediately repeat the same failure.
8. Positioning duration uses existing climbing fatigue; only successful completion awards one practice use, without duplicate grip award.
9. Pause preserves stage without motion/time/fatigue catch-up. Saves are clearly blocked during positioning and only this restriction is released on exit.
10. Successful climbing handoff and session cleanup cannot replay activity or retain stale path/save-lock ownership.

These are future verification criteria; no implementation or runtime tests have been performed.

## Consistency review

Reviewed against MOVE-004/006/009–011, CHAR-020, relevant CORE suspension/save ownership, MOVE catalog/architecture and nine confirmed decisions. No direct contradiction identified. Success-only traversal practice resolves CHAR-020's open rappel cadence without pretending guaranteed grip is a rolled check. Fatigue applies to actual positioning regardless of success. Fall protection begins only on real attachment. Save restriction intentionally differs from supported stationary climbing saves; pause preserves runtime progress without promising unfinished serialization.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation is complete resolve ledge/reach/small-drop criteria, route/shape fixtures, exact timing/travel bounds, motion handoff on abort/failure, mode compatibility, analog retry gate, mod schemas and save/activity identity integration. These dependencies do not waive collision safety, bounded attempts or once-only success practice.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-012-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented geometry, tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
