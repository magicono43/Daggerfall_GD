# MOVE-011 — Wall climb entry and movement

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Make ordinary environment walls traversable through deliberate approach and character skill, with controlled sideways/downward movement, meaningful slipping and validated exits. Successful grabs recover falls; failed requests, input release and restoration cannot fabricate a secure grip or extra practice.

## Confirmed requirements

MOVE-011-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews, each confirmed with three “Yes” answers. Rules below consolidate those choices. RULE-011 probability, CHAR-020 fatigue/practice and MOVE-004/006/009/010 authority, posture, airborne and fall-protection contracts remain binding. Rappelling itself remains MOVE-012.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/Player/ClimbingMotor.cs#ClimbingCheck` evaluates wall contact/intent and entry/continuation timers, including advanced airborne grabs. Advanced controls differ from classic forward-held climbing; releasing movement can clear slipping at a continuation evaluation.
- `CalcFrequencyAndToleranceOfWallChecks` uses ordinary entry 14 and advanced airborne entry 5 times `PlayerMotor.systemTimerUpdatesDivisor` (0.0549254); continuation uses 15 and slipping recovery 5. Source threshold/update ordering affects effective runtime timing.
- `ClimbingSkillCheck` tallies Climbing, handles perfect/override bypasses, calls `FormulaHelper.CalculateClimbingChance` and can suppress failure near water. Owner base chances are start 70, continue 50, grab 40 and recovery 20.
- `IsClimable` excludes moving action objects and enemies. `GetClimbedWallInfo`/`ClimbMovement` probe walls/corners and apply climbing motion. `PlayerSpeedChanger.GetClimbingSpeed` returns supplied base speed/3, doubled under enhanced climbing.
- `GetSaveData`/`RestoreSaveData` retain selected advanced-climbing state and timers; restore forces temporary contact and a motor freeze. This does not establish the target's validated-geometry restore contract.

Target behavior uses unified controls, explicit eligibility and secure-versus-slipping state rather than copying source bypasses, direct motor moves or forced-contact restoration.

## Detailed rules and behaviors

### Entry and eligible geometry

Holding Forward deliberately against eligible geometry for a configurable short delay attempts ordinary entry. No separate Climb button is required initially. Failed eligible attempts retry only at the declared cadence while intent, contact and clearance remain valid.

Airborne grabs require directional intent toward the wall, eligible contact and a successful grab check. Wall contact alone cannot cancel a fall. Exclude enemies and currently moving mechanisms in vanilla. Ordinary stationary solid environment geometry needs no individually placed climb marker, but its shape/contact and body clearance must support the action. Allow explicit validated surface exceptions/mod overrides; exact wall-angle/contact criteria require representative geometry fixtures.

Ordinary climbing requires the standing shape. A crouched player enters only if that full shape fits; never force upright through an obstruction. Preserve desired crouch state for clearance-checked restoration after exit. Riding, swimming, levitation and other mode overlap use declared MOVE-004 compatibility; this feature does not authorize arbitrary simultaneous motors.

### Controls, speed and collision

Use one scheme: Forward up, Backward down, Left/Right sideways, no directional input holds position with a secure grip. Allow inside/outside corner traversal only with valid continued contact and full-body clearance. No separate classic/advanced control modes are introduced.

Moddable speed baseline is ordinary standing Walk speed/3, doubled by enhanced climbing. Run/Sneak requests do not increase it. Cap combined directional magnitude to avoid diagonal bonuses and preserve proportional controller input. Exact interaction with source-owned Walk versus climb-specific modifiers must be explicit before implementation; no unrestricted inherited gait stacking is approved.

All motion and shape changes occur through MOVE-004 authority. Wall adhesion must not add unintended traversal speed, bypass collisions or independently move the collider. Camera facing alone cannot fabricate wall-relative movement or support.

### Checks, timing and consequences

Use owner base chances B: start 70, continue 50, airborne grab 40, regain hold 20. RULE-011 resolves approved live Climbing/racial/enhancement/Luck arithmetic and RULE-001 final probability. A passing roll cannot bypass geometry eligibility.

Nominal moddable intervals are approximately 0.77 eligible simulation seconds for ordinary entry/retry, 0.82 for continuation and 0.27 for airborne grab/recovery. Exact serialized precision is a tuning dependency; source frame overshoot/reset drift is not required parity. Count eligible simulation time, not frames or paused real time. Preserve timer phase and bound scheduling work without manufacturing multiple checks from repeated callbacks.

A secure stationary hold makes no continuation checks but still incurs CHAR-020 climbing fatigue. Movement continuation checks can fail into slipping. Slipping uses recovery checks even if movement input is released; input release cannot restore grip automatically. A successful recovery restores secure support; valid ground support can end slipping normally. Slipping remains unprotected airborne descent under MOVE-010 until actual recovery; exact acceleration/contact retention is a physics integration dependency.

Genuine authorized checks award CHAR-020 qualifying Climbing practice once, including failures, with explicit identity. No per-frame rerolls or practice from rendering/blocked requests. Technical retries retain RULE-003/011 outcomes rather than drawing again. Secure idle holding is not a source of check practice.

### Water exits and fall history

Protect a validated swimming-to-climbing exit from skill failure preventing escape. Require eligible wall contact, standing-body clearance and a valid exit route. This is not a general underwater success override. Guaranteed water-exit bypasses consume no random draw and award no check practice; ordinary climbing activity fatigue remains under CHAR.

Successful supported attachment or recovered grip ends the current damaging-fall segment under MOVE-010. Failed grabs or mere requests do not. Release/slip/support loss starts a new unprotected segment unless another valid protection remains. Exact water-exit detection and protection handoff require MOVE-014 integration, not a copied coordinate threshold.

### Exits and top-out

Fresh Crouch releases the wall and is consumed without also toggling posture. Fresh Jump invokes a deliberate bounded wall-exit push through an explicit moddable rule; exact impulse/direction and jump-cost classification require MOVE-009/CHAR integration. Neither voluntary exit allows immediate same-wall auto-grab until Forward has been released and the player deliberately approaches again. The gate must work for analog intent, not only keyboard events.

Top out automatically only when a supported destination and full-body route are validated. Do not teleport through lips or ceilings. If blocked while grip is valid, remain attached; if support is genuinely lost, use the actual movement-state transition. Reaching ground exits through coordinated support transition without duplicate landing/practice consequences.

### Pause and restoration

Pause preserves secure/slipping state and remaining check timers, suspending physical motion and eligible activity time without catch-up. Native saves retain stable wall identity/contact context, grip/slipping state and timer phase, together with required player motion/fall state.

Restore only after geometry readiness and validated contact/shape. Do not roll entry again, repeat practice or fabricate attachment to hide unavailable geometry. Missing/incompatible wall data follows placement recovery under CORE-013/MOVE-027, not unrelated teleport or forced contact for an arbitrary duration. Save boundary and in-flight check retention need explicit SAVE/RULE contracts.

## Relevant formulas and parameters

Speed baseline: v_climb=v_standing_walk/3 × enhancement, where enhancement is 2 when enhanced climbing applies, otherwise 1. Direction magnitude is capped while retaining analog strength. Distinct support/clearance constraints remain mandatory.

Check bases and approximate cadence are listed above. RULE-011 owns final probability and modifier order; do not add duplicate Khajiit/enhanced bonuses or a new final 95% cap. Exact climb-speed bounds, wall-exit impulse, domains, angle/contact tolerances and timer precision remain validated tuning dependencies.

## Required data

Stable wall/surface/contact identity, actual standing-shape clearance, entry intent/elapsed timer, secure/slipping state, continuation/recovery phase, wall-relative directions/corner context, desired posture, same-wall regrab gate, check identity/result, live RULE inputs and actual activity history. Raw scene references are not durable native identity.

## Inputs, outputs and events

Inputs: eligible directional/Crouch/Jump intent, wall/support observations, mode/effect changes, timer progression, protection handoffs and restore. Outputs: authorized check/result, validated attachment/motion/slip/recovery/exit, posture requests, once-only practice context and checked failure. Public APIs/signals remain unselected. Successful check and successful physical attachment are distinct outcomes.

## Cross-system interactions

RULE-001/003/011 own probability/randomness/result retention; CHAR-002/011 racial/live context and CHAR-020 activity. MOVE-001/002 own input/bindings; MOVE-004 authority/compatibility; MOVE-005 speed inputs; MOVE-006 shape; MOVE-007 surface boundaries; MOVE-009 wall-exit flight; MOVE-010 fall protection; MOVE-012 rappel; MOVE-014 water exit. LOC/WORLD/DATA supply geometry/identity, CORE suspension/readiness, SAVE state and MOD/RULE validated extensions. UI may explain chances under RULE-011 without mandatory check popups.

## Edge cases and failure conditions

Input release during slipping cannot create a free recovery. Idle secure holds incur fatigue without rolling practice. Same-wall voluntary exit cannot loop immediately into automatic protection. Airborne contact and failed checks do not erase falls. Corners, moving mechanisms, overhangs and low ceilings require full-shape validation rather than optimistic attachment.

Water protection requires an actual validated route; underwater location alone is insufficient. Top-out obstruction preserves valid grip rather than clipping through geometry. Motion-invalid states use explicit transitions/recovery; missing required wall/check data cannot silently pass. Restoring a timer or technical retry cannot duplicate rolls/practice.

## Configuration and balancing options

Validated base chances, cadences, entry delay/contact tolerances, climb speed, wall-exit impulse and supported surface eligibility are moddable. RULE-011 probability contracts remain authoritative. No perfect-climbing gameplay bypass, separate stamina meter, ceiling-hanging mode or blanket underwater success is approved. Debug bypass behavior requires DEV's own contract and cannot implicitly award practice.

## Save/load considerations

Persist stable wall/contact context, secure/slip state and timer phase, plus necessary velocity/fall and pending check completion information. Rebuild geometry before restoring grip and desired posture. Do not replay entry/practice or restore transient collider pointers. Retain valid in-flight outcomes under RULE-003/011; missing required compatibility invokes explicit recovery. Exact serialization/commit boundaries remain SAVE scope.

## Technical constraints

Target: Godot 4.7.2. Keep intent, geometry eligibility, chance resolution and physical attachment distinct. One coordinator owns collision/shape operations; timed checks must be frame-independent and identifiable. Concrete probes, corner math, timer storage and mod hooks remain implementation choices requiring fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Deliberate Forward starts eligible attempts at configured entry cadence; airborne grabs require toward-wall intent and success.
2. Valid stationary environment needs no per-wall marker; enemies/moving mechanisms are excluded unless explicitly overridden.
3. Standing shape must fit before entry; desired crouch survives climb override and restores only safely.
4. Unified up/down/sideways controls and secure idle hold work with proportional analog input and no diagonal/Run/Sneak bonus.
5. Correct owner base chances feed RULE-011 once per genuine check at simulation-time cadences.
6. Secure idle has fatigue but no continuation/practice checks; slip recovery cannot occur merely by releasing movement.
7. Successful recovery/attachment protects falls; failed contact/checks do not. Genuine check practice occurs once, including failures.
8. Valid water-exit bypass has no draw/check practice and cannot bypass route/shape eligibility.
9. Crouch releases without posture toggle, Jump performs bounded exit, and same-wall regrab requires released Forward/new approach.
10. Corners/top-out require valid full-body routes; blocked top-out preserves grip where valid rather than clipping.
11. Pause/restore preserve state/timer phase without catch-up or rerolls/practice; missing wall geometry uses placement recovery.

These are future verification criteria; no implementation or runtime tests have been performed.

## Consistency review

Reviewed against RULE-011, CHAR-020, MOVE-001–010, relevant CORE pause/restore contracts, MOVE catalog/architecture and twelve confirmed decisions. No direct contradiction identified. Water bypass practice is explicitly separate from qualifying rolled checks. Standing-shape override preserves desired crouch, while voluntary release consumes the Crouch press. Wall Jump is an explicit specialized transition requiring its own impulse/cost integration, not an exception that replays ordinary jump events. Slip/recovery obey approved fall protection. Exact modifier/timer/resource integration remains open without approving duplicate bonuses or callbacks.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation is complete resolve wall-angle/contact/corner fixtures, exact cadence precision, speed modifier/bound contracts, slipping physics, wall-exit impulse/cost classification, analog same-wall gate, mode priority, water-exit detection, surface override schemas and native/in-flight-check restoration. These dependencies do not waive actual geometry eligibility, secure-grip validation or no input-release recovery exploit.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-011-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
