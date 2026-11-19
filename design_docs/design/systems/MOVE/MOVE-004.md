# MOVE-004 — Ground motor and movement arbitration

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose and intended player experience

Coordinate which movement behavior controls the player and how it changes, keeping walking, airborne motion and specialized traversal predictable. Pausing cannot erase a fall, overlapping modes cannot move the player twice accidentally, and invalid placement cannot release gameplay into missing geometry.

## Confirmed requirements

MOVE-004-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. Rules below consolidate those decisions. CORE suspension/readiness, MOVE-001–003 input/view and CHAR-020 activity contracts remain binding. Detailed mechanics of individual movement modes are not approved by implication.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source remains unchanged.

- `Game/PlayerMotor.cs#FixedUpdate` derives grounding from collision flags and tracks grounded duration. Its cancellation branch clears movement, platform attachment and fall-damage tracking, then returns. A freeze countdown also returns early and requests cancellation when it ends.
- It scans head/front geometry, checks rappel then climbing while on foot, and yields ordinary motion if levitation, swimming or climbing is active. Hanging checks are commented out in this dispatcher.
- Ordinary motion invokes speed selection, grounded friction/jump handling or fall/air control, then step scanning, gravity, head collision and moving-platform movement.
- `PlayerMotor.Update` updates environmental flags and posture handling separately. `Game/LevitateMotor.cs#Update` provides a separate frame-driven swimming/levitation path, including paralysis handling; `Game/Player/ClimbingMotor.cs` supplies specialist climbing movement.
- `PlayerMotor.ResetPlayerState` resets levitation context and speed modifiers during session restoration paths. Source freeze comments describe teleport/physics synchronization intent, not an explicit readiness-result contract.

These observations do not establish runtime overlap bugs or classic parity. The target deliberately distinguishes pause from motion reset rather than inheriting cancellation's fall-history clearing.

## Detailed rules and behaviors

### Authority and state dimensions

One coordinator selects active movement behavior each physics step. Specialist motors may calculate motion, probes and candidate transitions, but cannot independently move the player outside the coordinated sequence. One authority does not imply exactly one collision call: ordered platform adhesion or other justified operations can remain within that sequence under their owner contracts.

Keep active mode distinct from posture, transport and restrictions. Crouching is posture, riding transport, paralysis a restriction. Each movement mode explicitly declares supported combinations; separation does not approve every possible combination. Ground and airborne movement are ordinary supported behaviors; swimming, climbing/rappel and levitation supply explicit eligibility/transition rules through their feature owners.

Use validated environment/effect/transport observations and declared transition rules, not incidental motor callback order, to select behavior. Unsupported overlaps cannot silently run two motors or select walking. Exact swimming/levitation/climbing precedence, transport compatibility and conflict resolution remain dependencies to establish in those features before implementation is complete.

### Restrictions versus suspension

Loss of voluntary movement is distinct from freezing physical simulation. Paralysis blocks player-driven movement; gravity, platform carriage and external forces continue unless the effect explicitly defines an exception. MAGIC/CHAR own effect semantics, including any specialized-mode consequences. This rule cannot imply that paralysis cancels an existing levitation effect or permits hovering without one.

Ordinary pause under CORE-016 suspends authoritative movement/world simulation while retaining valid velocity, platform attachment and fall history. Opening inventory cannot zero a fall or confer fall immunity. No paused real time is accumulated for later motion catch-up. MOVE-001 may discard stale input while physical state remains preserved; input cancellation is not a universal physics reset.

### Mode transitions and motion history

Each handoff explicitly defines disposition of velocity, platform attachment and fall history. Transfer only supported state; do not silently retain an obsolete platform or blindly clear all motion. A transition cannot duplicate jump/landing identity, fatigue charges or practice awards. Movement reports outcomes; CHAR owns resource/practice mutations.

Ordinary loss of ground support transitions to airborne motion without error recovery. A specialized mode losing eligibility uses its declared exit transition. Swimming entry, successful climb grabs and levitation must explicitly decide fall-history cancellation and velocity changes in their own specifications. No universal mode-entry fall reset is selected here.

If required data/components fail and no valid transition exists, stop unsafe movement and enter explained CORE recovery. Do not silently teleport, enable walking or bypass collision. Stopping unsafe progression does not authorize clearing fall history or declaring a landing successful. Exact recovery extent follows CORE/owner failure contracts rather than an invented global rollback.

### Placement holds and restoration

Teleport/load placement uses an explicit reset or restoration contract, separate from pause and ordinary mode changes. Required collision geometry and placement checks must be ready before release; an arbitrary elapsed delay alone is insufficient. A hold has an owner and bounded failure/recovery path. Exact readiness checks, time bounds and corrective placement limits belong to MOVE-026/027, WORLD/LOC and CORE/SAVE.

Release only the placement owner's hold. Other menu, focus, initialization or recovery reasons can still prevent gameplay. Restoring swimming/airborne saves cannot require a universal floor or introduce unrelated teleport fallback, consistent with CORE-013. Native restoration cannot inherit old-session motors, input or platform references.

### Activity and output reporting

Report resolved mode, actual voluntary movement and passive platform/external motion separately. Held Run is a request, not evidence of running. Passive platform carriage cannot by itself grant Running practice. CHAR-020 retains its approved fatigue rates, precedence, actual-moving Running requirement and once-per-event accounting; this feature does not invent new costs for riding or passive forces.

Expose enough ordered context for CHAR/TIME to account for the activity actually performed across transitions, rather than extrapolating the final mode over an elapsed interval. Distinguish requested motion from resolved collision-limited results. Exact blocked-motion thresholds and attribution for mixed voluntary/passive displacement need movement/CHAR fixtures; no numerical threshold is selected here.

## Relevant formulas and parameters

Movement may advance only when authoritative simulation/readiness gates permit it and applicable placement holds are clear. Voluntary intent additionally requires eligible input and absence of relevant voluntary-motion restrictions. Physical forces use their own applicable constraints rather than the voluntary-input predicate.

This specification selects no physics frequency, speed, acceleration, diagonal normalization, gravity, slope limit, jump height, mode priority number, movement epsilon or placement timeout. Those remain feature-owner/tuning contracts. One coordinated authority is not a one-collision-call limit.

## Required data

Current mode and eligibility; posture/transport/restrictions; validated ground/head/front/water observations as needed; voluntary intent and resolved movement; velocity; platform identity/attachment; fall history and jump/landing identity; transition reason and declared state transfer; simulation/input gates; placement hold ownership/readiness/failure; session/location scope and ordered activity context. Representation and probe sampling/order remain explicit engineering dependencies.

## Inputs, outputs and events

Inputs: eligible movement intent, environment contacts, effect/transport/posture changes, platform/external motion, suspension/readiness and placement requests. Outputs: selected behavior, coordinated collision/motion sequence, committed pose/motion state, transition outcomes, actual activity context and checked recovery failures. API/signal names remain unselected. Reporting a candidate jump, contact or transition is not itself a second authoritative gameplay event.

## Cross-system interactions

MOVE-001 supplies intent and cancellation; MOVE-002/003 bindings/view cannot override physical authority. MOVE-005–017 define detailed gait, posture, surfaces, jumps/falls, climbing, water, levitation, transport and feedback. MOVE-026/027 coordinate placement. CHAR-012/018/020 own practice/fatigue and consume valid activity; MAGIC/CHAR own restrictions/effects. WORLD/LOC supply geometry/context, TIME eligible duration, CORE-005/013/016/017 lifecycle/readiness/suspension/cadence, and SAVE restoration. AV can smooth presentation without moving the authoritative collider independently.

## Edge cases and failure conditions

Pause mid-fall or on a moving platform preserves state without advancing the frozen world. Resume cannot replay old impulses, erase fall distance or count menu time as movement. Platform removal during an otherwise eligible world change needs explicit detach/exit semantics, not stale attachment.

Paralysis in midair does not freeze gravity by default; on a platform it does not stop carriage. Specialized buoyancy/levitation support remains governed by those modes. Simultaneous climb/water/effect observations require declared precedence before implementation; callback order is insufficient.

Repeated transition/contact callbacks cannot repeat jump/landing consequences. Teleport holds cannot expire into missing geometry. Normal ledge departure is a valid transition, while missing required motor data is a checked failure. Failed recovery cannot disguise collision bypass as successful movement. Mixed external/voluntary displacement must not generate unintended training.

## Configuration and balancing options

No new player-facing arbitration slider or balance constant is approved. Mode support, restrictions and transitions are declared feature contracts; validated customization requires its owning feature's rules. Detailed movement tuning remains with each mode. No universal velocity preservation/reset, generic fall immunity or arbitrary unsupported-mode fallback is introduced.

## Save/load considerations

SAVE/MOVE define native mode/motion state necessary for supported restored activity, including velocity/fall/platform context where applicable; exact persisted fields and restoration policy remain owner dependencies. Reconstruct after required geometry readiness with contextual validation. Never restore stale engine references, old-session holds or queued physical input. Pause preserving runtime state does not automatically specify native serialization. Loading cannot erase required fall consequences merely because a new motor instance was created, but exact fall restoration belongs to fall/SAVE contracts.

## Technical constraints

Target: Godot 4.7.2. One physics-step coordinator owns arbitration and ordered physical operations. Specialist calculations remain separate; no giant combined posture/effect state machine or engine class hierarchy is mandated. Honor CORE gates and explicit checked transitions with scope-safe references. Fixed-step/probe ordering, numerical precision and presentation interpolation require fixtures. MOVE-AR-02 is adopted only to the extent explicitly confirmed here, not approved wholesale. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Each eligible physics step has one movement authority; specialists cannot independently apply uncoordinated motion. Justified multiple collision operations remain ordered.
2. Posture, transport and restrictions are distinct dimensions, with supported combinations explicitly validated.
3. Mode selection uses declared conditions/transitions rather than callback order. Unsupported overlaps cannot run multiple modes or silently select walking.
4. Pause mid-fall/on-platform preserves velocity, attachment and fall history; no movement or paused-duration catch-up occurs, and inventory grants no fall immunity.
5. Paralysis blocks voluntary movement while permitted gravity/platform/external motion continues; effect exceptions must be explicit.
6. Mode changes explicitly transfer/reset applicable motion history without duplicate jumps, landings, fatigue charges or practice.
7. Walking off a ledge enters airborne motion normally. Specialized eligibility loss follows its defined exit; missing required data without a valid exit enters explained recovery.
8. Placement holds require geometry/context readiness and bounded failure handling, not elapsed delay alone. Releasing one hold cannot release other suspension reasons.
9. Reports distinguish voluntary movement, passive carriage/pushes and held requests, preserving CHAR-020 eligibility and ordered time accounting.
10. Native restoration waits for geometry, validates contextual state and rejects stale old-session references; airborne/swimming restoration is not forced onto a floor.
11. Missing motor/context or failed placement cannot silently teleport the player, disable collision, clear consequences or claim successful movement.

These are future verification criteria. No implementation or runtime tests have been performed.

## Consistency review

Reviewed against MOVE-001–003, CHAR-020, CORE-016/017, recorded CORE-013 contextual placement requirements and MOVE catalog/architecture review. No direct contradiction identified. Input cancellation does not clear physical history. Physical paralysis handling does not change ordinary-pause suspension. Activity reporting preserves approved CHAR rates without treating passive carriage as Running. One movement authority allows intentionally ordered collision operations. Explicit placement readiness refines holds without promising rollback or unrelated spawn fallback. Specialized precedence/fall behavior remains unresolved owner scope rather than invented requirements.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified for this coordination feature. Before implementation is complete resolve specialized mode precedence/transport/posture compatibility, eligibility observations/probe order, transition velocity/platform/fall contracts, effect exceptions, blocked/mixed-motion activity attribution, placement readiness/time bounds/recovery, native state schemas and representative physics/integration fixtures. These dependencies do not waive single authority, no pause-induced fall immunity or checked recovery.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under MOVE-004-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
