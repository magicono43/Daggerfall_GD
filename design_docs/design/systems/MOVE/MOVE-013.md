# MOVE-013 — Levitation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Provide responsive effect-authorized three-dimensional hovering, with predictable controls and safe transitions to falling, ground or water. Levitation supports movement without disabling collision, granting water breathing or accidentally replaying movement/costs on restore.

## Confirmed requirements

MOVE-013-D01–D11 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. The following rules consolidate those confirmed choices. MOVE-004 motion authority, MOVE-006 posture, MOVE-010 protection and CORE suspension/readiness contracts remain binding. MAGIC owns spell acquisition, duration, costs and effect stacking.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/LevitateMotor.cs#Update` handles swimming/levitation in a frame-driven motor. Camera-relative input combines with explicit up/down; Jump/FloatUp take precedence over Crouch/FloatDown through an if/else branch. Standard levitation speed is 4.0.
- `AddMovement` shares swimming/water-walking logic with levitation. Combined camera-relative and vertical vectors are added separately, so this code does not establish a full 3D speed cap.
- When stationary, `Update` issues six tiny movements before normal movement to remain responsive to moving geometry. The target requires collision response, not those particular calls.
- `SetLevitating` requests ordinary movement cancellation on entry/exit. `Game/MagicAndEffects/Effects/Thaumaturgy/Levitate.cs` supplies effect-to-motor activation/termination integration. Source cancellation alone does not define the target velocity-transfer contract.

## Detailed rules and behaviors

### Authorization, authority and hover

Valid active levitation sources authorize the mode. Track sources separately: ending one cannot disable hover while another remains. MAGIC declares resolved speed/stacking; do not multiply repeated updates or let incidental callback order choose speed. Exact source priority and duration rules remain MAGIC scope.

MOVE-004 owns coordinated physical operations. While valid levitation takes control, suppress ordinary gravity and provide controlled hover. Voluntary response is immediate, with no voluntary drift after release. External pushes still resolve through collision rules; no collision bypass or blanket crush immunity. External-force persistence/transfer requires its explicit owner contract rather than being silently discarded as voluntary drift.

### Controls and speed

Use camera-relative forward/backward/sideways motion plus world-up/world-down controls. Contextual Jump/Crouch can ascend/descend without ordinary jump/posture effects. Opposing vertical inputs cancel. Ascend/descend operate while held regardless of ordinary Crouch Hold/Toggle preference. Require release and fresh press on entry before previously held Jump/Crouch can cause vertical movement; mode handoff must not manufacture input.

Moddable baseline speed is 4 reference units per second, independent of Speed, Running and gait toggles. Cap the complete combined 3D intent vector to prevent forward/up or other combined-input bonuses while retaining proportional analog magnitude. Test physical pace against Godot world scale. No inherited sprint/Run speed bonus or automatic upward jump impulse applies.

Retain the current valid standing/crouched collision shape at entry. Do not force expansion beneath a ceiling. Vertical controls do not change posture while flying; desired posture remains available for clearance-checked reconciliation on exit. Riding and other incompatible modes need declared transitions rather than overlapping motors.

### Entry, expiry and restrictions

When levitation actually takes movement control, cancel prior voluntary/falling momentum and enter controlled hover. End the existing damaging-fall segment under MOVE-010 only on that actual transition, not a cast request. External-force transfer is separately defined by its owner.

When the last authorizing source ends, select valid ground/swimming support if available. Otherwise begin unsupported falling with zero vertical velocity and current horizontal travel velocity retained. Establish a fresh unprotected fall segment unless another protection applies. Expiry cannot reapply earlier cancelled momentum or blindly clear other effects' protection. Exact speed decomposition and contact ordering require fixtures.

Paralysis blocks voluntary levitation controls while the active effect continues hover and external pushing remains possible. This is an explicit gravity-suppression exception to MOVE-004's ordinary restriction behavior. Expiry resumes ordinary physical rules even if paralysis remains; it cannot leave unsupported permanent hovering.

### Water and collision

Levitation controls movement while active in water, including ascent out of the water. Actual submersion still governs breath and underwater effects; levitation grants neither water breathing nor a changed water surface. Expiry selects swimming/ground/fall from validated context. MOVE-014 owns thresholds and related swim/breath classification; simultaneous-source/mode handoffs cannot repeatedly trigger splashes or grants.

Walls/ceilings constrain motion without accumulating a voluntary impulse that launches the player when freed. Moving objects can push a stationary hovering player. MOVE-008 requires explicit mode-specific lethal compression rules rather than automatic grounded crouch-kill logic. No particular six-move stationary workaround is mandated.

### Activity and customization

Levitation movement alone awards no Running, Jumping or Climbing practice and introduces no extra movement-specific fatigue rate. Continue applicable ordinary CHAR-020 fatigue; MAGIC owns spell/sustained magical costs. Contextual Jump is not a successful ordinary jump and cannot charge its event fatigue/practice.

Support validated modded levitation speeds, restrictions and costs with explicit source/provider semantics. Contributions cannot double-charge ordinary activity or use a presentation update as a new spell cost. Exact hooks, numeric domains, limits and speed/source resolution must be specified before implementation is complete; no general extension framework is approved here.

### Pause and restoration

Pause freezes motion and gameplay-linked effect duration under CORE contracts without catch-up. Retain valid source/posture/motion context for the same session. Focus or menu handoffs obey input-context and fresh-press rules; cursor eligibility does not authorize physics.

Native saves restore valid source effects, posture and necessary movement state after geometry readiness. Do not recast, charge costs again, replay entry cancellation or fabricate fresh input. Hover resumes only while restored sources authorize it. Missing required source data invokes explicit compatibility/recovery rather than silently dropping the effect into a fall or inventing levitation. Exact source/remaining-duration and external-force schemas remain MAGIC/SAVE contracts.

## Relevant formulas and parameters

Conceptually voluntary velocity is resolved levitation speed times the magnitude-capped combined 3D intent, after contextual source arbitration. Baseline speed=4 reference units/second; input neutral gives zero voluntary velocity. Current external motion is separate.

Gravity is suppressed only by valid active mode/effect authority. Last-source unsupported exit sets initial vertical velocity to zero and retains current horizontal travel velocity. Validate finite speeds/ranges and units; exact speed cap, scale conversion and mod domains remain technical dependencies, not approved arbitrary constants.

## Required data

Valid effect-source identity/lifetime and resolved speed; mode eligibility; capped camera/world-relative intent; fresh vertical-input eligibility; voluntary versus external velocity; actual support/water context; actual/desired posture; fall protection; suspension/readiness and restore state. Exact source resolution, velocity decomposition and serialized schemas remain owner dependencies.

## Inputs, outputs and events

Inputs: effect-source start/end, eligible direction/vertical input, paralysis, collisions, water/support changes, suspension and native restore. Outputs: authorized hover/motion, checked mode/velocity/protection handoff, posture reconciliation and actual activity context. API/signal names remain unselected. Source reapplication is not a new entry or cost event.

## Cross-system interactions

MAGIC owns effect eligibility/stacking/costs, MOVE-001/002 inputs/preferences, MOVE-003 view, MOVE-004 authority/restrictions, MOVE-006 shape, MOVE-008 pushes/compression, MOVE-009 gravity/flight exit, MOVE-010 fall history and MOVE-014/015 water/swimming. CHAR owns fatigue/breath integration, WORLD/LOC geometry, CORE pause/load gates and SAVE source/motion restoration. MOD/RULE/DATA own declared validated configuration/hooks.

## Edge cases and failure conditions

Simultaneous Forward/Up cannot boost speed; Up/Down cancel. Held Jump/Crouch on entry cannot unexpectedly move vertically or toggle posture. Run/Sneak cannot alter flight pace. Blocked motion and external pushes require collision-safe behavior without hidden voluntary acceleration.

Paralysis retains authorized hover but cannot preserve it after final expiry. One source ending cannot cancel another. Water submersion remains true when appropriate despite flight control. No forced stand through geometry or inherited riding motor is allowed. Pause/load cannot replay costs, reset valid external state by rerunning entry or expose unsupported geometry. Invalid required source/speed data uses explicit owner recovery rather than silent fallback.

## Configuration and balancing options

Validated speed/restriction/cost extensions are supported. Vanilla baseline is 4, with no gait/stat speed scaling, voluntary inertia or extra levitation practice/fatigue rate. Exact MAGIC source speed selection and optional mod bounds/costs remain integration work. No water breathing, noclip, universal crush immunity or automatic posture expansion is introduced.

## Save/load considerations

Version effect sources/remaining state and required player posture/motion. Restore geometry and source authority before releasing load suspension. Preserve necessary external-force context under owner rules without recasting or treating restore as entry. Application preferences remain separate; no raw held key, old motor reference or discarded-session source may control restored gameplay.

## Technical constraints

Target: Godot 4.7.2. Separate authorization, intent, voluntary velocity, external forces and collision. Coordinate all motion and effect handoffs explicitly, using frame-independent eligible simulation time. Engine gravity flags alone cannot establish valid source ownership or safe restore. Concrete APIs, nodes, speed caps and schemas remain choices to verify. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Camera-relative movement and held world-up/down work with contextual Jump/Crouch, cancelling opposing vertical inputs without ordinary jump/posture effects.
2. Entry requires fresh vertical presses after release; existing Crouch preference does not toggle vertical movement.
3. Baseline pace and complete 3D magnitude cap preserve proportional control without diagonal/vertical/gait bonuses.
4. Valid hover suppresses gravity, responds immediately and has no voluntary release drift; collisions/external pushes remain effective.
5. Entry/last-source exit transfer momentum as selected; valid support/water replaces unsupported falling and protection handoffs remain coherent.
6. Paralysis blocks control while valid hover persists; final expiry restores ordinary physical rules.
7. Actual water submersion/breath effects remain active; levitation can ascend out without granting water breathing.
8. Posture remains valid without forced enlargement; exit reconciles desired posture through clearance checks.
9. Ending one source cannot disable another; speed is resolved explicitly without repeated multiplication/last-callback selection.
10. Flight alone creates no movement practice or extra fatigue rate; MAGIC costs are distinct and not replayed.
11. Pause/native restore preserve supported state without catch-up, recasts, repeated costs or entry resets; required missing source data enters recovery.

These are future verification criteria; no implementation or runtime tests have been performed.

## Consistency review

Reviewed against MOVE-001–012, CHAR-020 and relevant CORE pause/restoration contracts, MOVE catalog/architecture and eleven confirmed decisions. No direct contradiction identified. Paralysis hover is explicitly approved effect support rather than ordinary physics suspension. Water authority is separated from submersion/breath. Entry cancels falling only when control commits, consistent with MOVE-010. Posture preservation resolves compatibility without forced standing. Native restore is not an entry replay; optional source stacking/force persistence remains explicit owner work.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Required dependencies include MAGIC source/speed stacking, external-force persistence/exit decomposition, incompatible-mode transitions, water thresholds, validated speed domains/scale, contextual input arbitration, mod costs/hooks, native schemas and representative collision/source-expiry/save fixtures. These do not waive controlled hover, collision safety or source-authorized restoration.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-013-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
