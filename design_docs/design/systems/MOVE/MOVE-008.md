# MOVE-008 — Moving platforms and collision consequences

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Carry players predictably on moving geometry, allow collision-valid pushing and escape, and distinguish genuine crush hazards from ordinary contact. Preserve mechanism-specific behavior rather than making every elevator lethal. Collision and posture consequences remain coordinated and safe across pause and restoration.

## Confirmed requirements

MOVE-008-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews. The user's elevator qualification is binding: representative mechanism testing may establish exceptions and require a later explicit design revision. Possible pass-through elevator behavior is reported uncertainty, not verified universal behavior or approval to disable collision globally.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/Player/PlayerGroundMotor.cs#MoveWithMovingPlatform` transforms a stored local attachment point to carry the player, then applies platform rotation corrected to preserve upright orientation. It performs platform adhesion and ordinary controller movement as separate ordered operations and rebuilds attachment observations.
- `ClearActivePlatform` removes the reference. A commented platform-velocity field does not establish inherited takeoff momentum.
- `Game/PlayerMotor.cs#OnControllerColliderHit` identifies supporting platform transforms and excludes enemies from attachment to avoid unstable camera behavior; this does not prove enemies are unstandable.
- `Game/PlayerCrush.cs#Update` excludes pause/dead/swimming/levitating contexts and checks overhead distance. Static geometry, non-action objects, stationary actions and a model-description `BOX` exception are excluded. Qualifying objects force crouch, then can set health to zero for grounded crouched players when the sampled gap decreases.
- `Game/PlayerCollisionHandler.cs#OnCharacterCollided` is an empty virtual extension method in the inspected base class; it does not itself implement damage or guarantee routing to concrete handlers.

Target behavior replaces probe-only crushing with validated compression and explicit mechanism policies. Runtime elevator behavior, scene wiring and exception coverage remain unverified.

## Detailed rules and behaviors

### Support and platform carriage

Supported players follow platform translation and horizontal rotation while remaining upright. Horizontal facing changes consistently with platform turning; carriage introduces no camera pitch or roll. Players retain voluntary movement relative to the platform, subject to ordinary gait, collision and restrictions.

Resolve platform motion and player motion through MOVE-004's coordinated physics sequence. Several justified collision operations may be ordered within it; specialists cannot independently move the player outside that sequence. Platform facing changes must update MOVE-003 actual facing coherently, not leave a stale look target that snaps the view back.

Detach on jumping, walking off or losing valid support. No lingering attachment may pull the player back. Platform-velocity inheritance is deliberately unresolved until MOVE-009. Detachment alone cannot erase fall history or generate duplicate jump/landing events.

Passive carriage remains distinct from voluntary movement and cannot by itself grant Running practice. Ordinary pause preserves valid attachment/motion history while suspending platform/player simulation without catch-up, under CORE-016/MOVE-004.

### Mechanism policies and collision

Declare carrying, pushing and crushing behavior explicitly in validated mechanism definitions. Exceptions are scoped to those definitions and established through representative content/runtime fixtures, not solely model-name inference. No universal elevator pass-through behavior is selected.

A moving object pushes the player where collision permits escape. Being supported by an elevator, touching moving geometry or brushing a stationary ceiling is not by itself a crush. Crushing requires a crush-enabled mechanism actively compressing the player against another obstruction. Stationary geometry can be the opposing obstruction; it is not independently a moving crush hazard.

If testing establishes elevators that pass through or permit escape/reboarding, encode their validated exception semantics and return material gameplay rule changes for explicit design review. Do not improvise broad collision disabling or silently classify every moving action as lethal.

### Forced crouch and lethal compression

For supported grounded compression, attempt forced crouch first through coordinated posture/shape commitment. Preserve the player's desired posture independently of the temporary forced crouch. Once compression clears, fulfill desired standing only when the full shape fits; someone who desired crouch stays crouched. Eligible later posture input continues to use MOVE-006 rules.

Lethal crushing occurs when a crush-enabled mechanism continues compressing a grounded player and the validated crouched shape can no longer fit. No arbitrary grace timer is introduced. A camera probe, ordinary contact or attempted stand alone cannot authorize death. Validate actual mechanism motion, opposing obstruction and body-volume compression; exact tolerances and ordering require fixtures.

Route the authoritative lethal result through the health/death owner once. Duplicate contacts, callbacks or multiple collision operations cannot replay death consequences. This specification selects lethality rather than a damage-over-time formula; resistance/immunity/effect interactions, where applicable, require explicit CHAR/COMBAT contracts rather than inferred source bypasses.

### Specialized modes

Swimming and levitation grant no blanket immunity to moving geometry. Their validated shapes and movement rules determine collision pushing and escape. Lethal compression in those modes requires an explicitly supported mode-specific rule; do not automatically apply the grounded crouch-based kill rule. Mode-specific rules must be resolved before claiming complete crush coverage.

Other unsupported posture/transport/movement combinations likewise require their declared compatibility under MOVE-004/006. Crush handling cannot force standing through a ceiling, collapse the collider to an invented tiny shape or bypass checked mode transitions.

### Restore and missing support

Save stable mechanism identity and player-relative attachment context alongside authoritative platform state. Restore mechanism/geometry before validating player support and relative placement. Reconstruction cannot replay elapsed platform travel, crush events or damage.

Missing or incompatible support follows placement/SAVE recovery rather than attaching to another nearby object. Exact mechanism state, trajectory phase, identity scope and permitted contextual correction remain LOC/SAVE/MOVE-027 contracts. No unrelated teleport or universal floor requirement is approved.

## Relevant formulas and parameters

Platform carriage conceptually compares successive world positions of a valid platform-local attachment point; its horizontal rotation updates actual facing while preserving upright orientation. Resolved displacement still passes collision checks. Concrete transform/rotation decomposition and detach velocity are implementation dependencies.

Crush eligibility requires validated crush-enabled policy, continuing motion/compression, opposing obstruction and applicable mode conditions. Grounded lethal resolution additionally requires failure of the validated crouched shape to fit after the forced-crouch attempt. No numeric compression tolerance, speed threshold, grace duration or generic damage rate is selected.

## Required data

Stable mechanism identity/policy and authoritative state; valid support/contact identity; relative attachment point/orientation; platform motion; actual facing/posture and desired posture; temporary forced-crouch reason; body-clearance/compression evidence; opposing obstruction; mode eligibility; once-only lethal outcome identity and lifecycle gates. Raw engine transform references are not durable save identity.

## Inputs, outputs and events

Inputs: validated support/collision observations, platform/mechanism motion, voluntary movement, jump/detach, posture requests, mode changes, suspension and native restoration. Outputs: coordinated carried/pushed displacement, facing updates, attachment/detachment, forced-posture request/release, checked lethal outcome and recovery result. API/signal names remain unselected. Raw contact reports are observations, not independent damage events.

## Cross-system interactions

MOVE-004 owns motion authority, restrictions/history and checked recovery; MOVE-003 actual facing; MOVE-005 gait/activity; MOVE-006 shape/desired posture; MOVE-009/010 detach momentum and falls; MOVE-013–016 specialized/transport rules; MOVE-026/027 placement. LOC/WORLD/DATA own mechanisms/geometry/identity. CHAR/COMBAT own health/death and effect semantics; CORE-008/016 death/suspension flow; SAVE native restoration; MOD/RULE supported policy overrides. Platform motion cannot train movement skills merely by carrying the player.

## Edge cases and failure conditions

Test translating/rotating platforms, elevators beneath ceilings, side pushes, corners, disappearing supports, jumps and rapid reboarding. Collision resolution cannot double carriage, turn passive movement into voluntary practice or preserve attachment after support loss. Platform yaw must not fight mouse-look state.

Ordinary contact and stationary mechanisms cannot produce crush death. A stationary ceiling opposing a rising crush-enabled platform can participate in actual compression. Forced crouch must commit safely before evaluating failure of crouched fit. No crouch-camera delay may act as an arbitrary death timer. Lost/inconclusive required compression evidence cannot be treated as proof of death; checked failure handling remains CORE/owner scope.

Elevator exceptions require evidence; broad model-name or all-elevator assumptions are insufficient. Pause halts mechanism and collision consequences. Reconstruction must not resume from stale last-frame deltas or replay lethal contacts. Missing required mechanism state requires explicit recovery, not invented attachment or phase.

## Configuration and balancing options

Carry/push/crush policy, validated exceptions, compression thresholds and supported mode rules must be moddable through declared contracts. Vanilla retains forced crouch then lethal grounded compression for qualifying mechanisms, subject to representative testing/review. No default damage-over-time, universal pass-through, blanket mode immunity or stop-on-player mechanism behavior is introduced. Exact mod priority/provider/failure semantics remain MOD/RULE integration dependencies.

## Save/load considerations

Persist stable mechanism state and relative attachment context, reconstruct after readiness and validate support. Preserve required player physical history under SAVE/MOVE contracts, not stale scene pointers. Temporary forced-crouch state must reconcile with actual restored compression and desired posture without replaying damage. Exact serialization of constraint reasons, trajectory phase and optional mod state remains a versioned owner dependency. No offline travel advancement is inferred.

## Technical constraints

Target: Godot 4.7.2. Use ordered collision operations, scope-safe support references, coherent platform/look orientation and full-shape compression evidence. Verify representative mechanisms before asserting classic/DFU parity. Concrete nodes, casts, collision layers, transform math, damage APIs and persistence schemas remain choices to validate. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Supported players follow platform translation/yaw, remain upright and can move relative to the platform without duplicate displacement.
2. Platform yaw updates actual view coherently without stale-look snapback, pitch or roll.
3. Jump/support loss/walking off detach without lingering pullback; momentum inheritance remains explicitly MOVE-009-owned.
4. Passive carriage does not grant Running practice; pause preserves valid attachment/history without movement or catch-up.
5. Explicit validated policies distinguish carry/push/crush and mechanism exceptions; ordinary contact cannot authorize crush death.
6. A crush-enabled moving mechanism with real opposing compression attempts forced crouch, preserving desired posture.
7. Continued grounded compression that cannot fit validated crouched shape resolves lethally once, without arbitrary timer/probe-only kills.
8. Clearing forced crouch restores desired posture only with clearance; deliberate crouch remains crouch.
9. Swimming/levitation use declared collision rules without blanket immunity or automatic grounded kill logic.
10. Mechanism/support state restores before player validation without replayed travel/damage or unrelated attachment fallback.
11. Representative elevator/trap fixtures establish exceptions; unresolved behavior is returned for review rather than hidden by universal pass-through or lethality assumptions.

These are future verification criteria; no runtime/physics tests or implementation have been performed.

## Consistency review

Reviewed against MOVE-001–007, relevant CORE pause/placement/death contracts, MOVE catalog/architecture and nine confirmed interview decisions. No direct contradiction identified. Multiple ordered collision calls remain compatible with one movement authority. Forced crouch is explicit hazard policy rather than automatic doorway shrinking and preserves desired posture. Crush attempts do not reset falls, grant passive practice or bypass context gates. Stable support alone does not make a platform a crush hazard. Elevator uncertainty remains an explicit verification/review dependency; specialized lethal rules and jump momentum are not invented.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation is complete resolve mechanism classification/exception evidence, platform rotation/contact order, detach momentum via MOVE-009, compression tolerances/full-shape evidence, mode-specific crush behavior, health/effect interactions, mod policy selection, native mechanism/constraint schemas and representative moving-geometry fixtures. Testing may justify revisiting the baseline under explicit design review, as requested by the user.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-008-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented mechanism-testing, tuning, engineering and cross-owner dependencies remain open, including possible explicit revision after elevator testing. Approval does not initiate implementation, coding tasks or another feature review.
