# MOVE-006 — Crouch and clearance

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Let players deliberately lower their posture to traverse low spaces, with predictable controls and safe standing. Collider posture is authoritative; camera animation follows without delaying clearance or permitting views through geometry. Posture changes cannot boost jumps or erase falls.

## Confirmed requirements

MOVE-006-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. The rules below consolidate those decisions. MOVE-001–005 and CORE input/suspension/load contracts remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/Player/PlayerHeightChanger.cs#DecideHeightAction` uses a Crouch start edge to toggle posture, alongside riding, water, climbing and levitation conditions. Those specialized conditions can force posture/height transitions.
- Reference controller heights are 1.8 standing and 0.9 crouched, with distinct riding/swim heights. Camera eye offset and 0.10/0.25/0.4-second transition constants are also present. These are source facts, not approved target values.
- `DoCrouch` lowers the camera before shrinking the controller and setting crouched state. `DoStand` changes controller/posture first, then raises the camera. `ControllerHeightChange` shifts the controller center by half the height difference.
- `CanStand` performs an upward sphere cast. `Update` pauses height actions while the game is paused. `SaveLoadManager_OnStartLoad` selects posture actions from saved crouch state.
- `Game/Player/FrictionMotor.cs#HeadDipHandling` applies temporary standing-height adjustments to assist certain door/ramp clearances; `PlayerMoveScanner.FindHeadHit` supplies a separate overhead observation.

Target rules below replace camera-first crouch commitment and do not automatically preserve forced posture changes or automatic doorway shrinking.

## Detailed rules and behaviors

### Controls and requested posture

Offer independently selectable Hold or Toggle Crouch, separate from Run/Sneak preferences. Crouch changes posture, not stealth guarantees. MOVE-005 retains independent Sneak and its actual-posture speed formulas.

Maintain actual posture separately from desired standing/crouching state. Releasing Hold requests standing. If the full standing collider cannot fit, remain crouched with the standing request pending. Automatically stand when clearance becomes available. A new crouch request cancels the pending stand. Repeated physics evaluations cannot reinterpret one input edge as repeated toggles.

Pending standing does not count as actual standing for speed or collision. Never force expansion through an obstruction. Exact UI indication for blocked standing remains UI scope; no per-frame warning or popup is selected.

### Physical commitment and clearance

Commit collision shape and authoritative posture together in MOVE-004's coordinated physics step. Preserve the physical foot/base position while resizing; moving the collider center to maintain its base is not an upward propulsion impulse. Crouched gait speed becomes eligible when posture commits, not when camera animation completes. Airborne gait selection remains governed by MOVE-005.

Validate the full intended expanded shape against current relevant geometry before standing or another height enlargement. A thin center ray alone cannot establish full-body fit. Exact shape query, margins, layer policy and update ordering require physics fixtures; engine implementation is unselected. Shrinking must also leave a valid resulting shape/pose rather than conceal an existing invalid overlap.

Allow airborne posture changes with the same foot-position preservation and clearance checks. Resizing cannot add upward motion, reset fall history or instantly switch takeoff gait before landing. MOVE-009 owns jumping/air control; this feature grants no crouch-jump boost.

Require deliberate crouching for genuinely low passages. Small traversal tolerances may assist contacts, but cannot silently reduce standing shape enough to bypass crouch requirements. MOVE-007 owns slope/step tolerances and must preserve this boundary.

### Camera height

After posture commits, smoothly move the camera toward the validated posture height. Camera motion does not drive the collider or delay physical clearance. Keep the visual transition within safe geometry; shorten or snap it when needed to prevent seeing through walls/ceilings. Such correction cannot change facing, move the collider or clear fall history.

Use configurable validated standing/crouched heights, eye positions and transition durations, tested against world scale and clearance. No exact numeric dimensions or timing are approved here. Camera collision/near-plane treatment and interrupted-transition interpolation require rendered fixtures. Preserve MOVE-003 resolved facing and aim consistency; posture height is a legitimate view-origin change, not permission for cosmetic bob to redirect aim.

### Suspension and restoration

Menus and focus loss preserve actual posture and Toggle selection. Posture and camera-height transitions pause with ordinary gameplay; paused duration creates no catch-up. Hold controls follow current eligible input on return; release requests clearance-checked standing. Context changes cannot manufacture a new discrete Crouch press. Physical fall/velocity/platform history retains MOVE-004 pause rules.

Native saves retain actual posture and desired standing/crouching state, including a blocked stand request. Restore collision posture only after required geometry readiness, validating clearance before returning control. Set camera directly to validated posture height without replaying old animation. Restored desired state is distinct from a physical key hold; Hold controls reconcile with eligible current input on return. Save schema and exact reconciliation sequencing must preserve no invented input presses.

Changed/incompatible geometry uses placement/SAVE recovery and bounded contextual corrections under CORE-013/MOVE-027. No unrelated teleport, universal floor requirement or silent collision bypass is introduced. Runtime physics state preservation does not require saving camera interpolation history.

### Specialized movement and transport

Swimming, climbing, levitation and riding explicitly declare required collision shapes and whether voluntary crouching is supported. Submit changes through MOVE-004 coordination and validate clearance before enlargement. An effect/mode cannot force standing through a ceiling.

Exact mode compatibility, forced-shape priority and behavior when a required enlargement is blocked remain owner contracts for those feature reviews. Do not copy DFU forced-standing/forced-swim-crouch behavior as implicit requirements. Unsupported combinations use checked transitions/recovery rather than running independent resize paths.

## Relevant formulas and parameters

For a vertically centered shape whose base remains fixed, center-height adjustment is half the height change; concrete Godot transform conventions must be verified. This is geometric preservation, not added velocity. Standing requires the full validated standing volume to fit. Actual posture changes only with successful coordinated shape commitment.

Exact heights, radius, eye offsets, collision margins, transition duration, interpolation curve and permissible small traversal tolerances remain validated tuning dependencies. Source values 1.8/0.9 are not selected target defaults. MOVE-005 crouched formulas remain authoritative, subject to its airborne gait rule.

## Required data

Actual and desired posture; Hold/Toggle preference; pending stand request; current/target shape and base position; validated overhead/full-volume clearance; current/target camera height and transition progress; simulation/input eligibility; active mode/transport shape requirements; native restored posture and placement readiness. Exact schema/query representation remains engineering scope.

## Inputs, outputs and events

Inputs: eligible Crouch actions, Hold state, clearance observations, mode/transport shape requests, suspension and native restoration. Outputs: checked shape/posture commitment or blocked standing, camera-height target/safe presentation, actual-posture context for gait and placement failures where required. Public API/event names remain unselected. Blocked requests are not successful posture transitions or new practice events.

## Cross-system interactions

MOVE-001/002 own eligible inputs, rebinding and preferences. MOVE-003 owns facing/cursor/aim; MOVE-004 owns ordered physical changes/history and mode arbitration. MOVE-005 owns actual-posture speed and takeoff gait, MOVE-007/009 surfaces/air motion, MOVE-011–016 specialized shape compatibility and MOVE-026/027 placement. CORE-003/006 own validated settings/application; CORE-013/016 geometry restoration and suspension. UI/AV own accessible controls and safe camera presentation, SAVE native state. CHAR/NPC stealth outcomes do not follow from crouch input alone.

## Edge cases and failure conditions

Hold release under a ceiling retains actual crouch until standing fits; moving into clearance fulfills the pending request once. Renewed crouch cancels it. Rapid toggles and reversing camera transitions cannot desynchronize actual collider/posture or duplicate input.

Airborne resizing preserves base/velocity/fall history. Standing beside sloped/overhanging geometry must validate the complete shape, not only center clearance. Moving ceilings/platforms require same-step observations/order; being crouched does not grant immunity to crush/collision rules, which remain their owners' scope.

Menus freeze camera/posture progress. Save/load cannot replay old animation or bypass invalid geometry. Specialized-mode requests cannot force expansion. Camera obstruction may shorten animation without moving physics or exposing through-wall information. Malformed required shape/settings use approved validation/recovery; no invented tiny-collider fallback is permitted.

## Configuration and balancing options

Players independently choose Hold/Toggle Crouch and rebind it. Heights/eye positions/durations are configurable validated tuning with geometry compatibility, not unrestricted collision-bypass sliders. Exact player-facing presentation options and default Hold/Toggle selection remain to be chosen. No automatic full crouch for doorways, automatic stealth bonus or new posture resource cost is introduced.

## Save/load considerations

Persist actual/desired posture including blocked stand intent; preferences remain application state. Rebuild against ready geometry and validated shapes, then set camera to restored actual posture. Do not restore old physics references, raw key state or camera animation history as authoritative input. Hold reconciliation, versioned shape changes and missing required geometry need explicit SAVE/MOVE contracts; fallback cannot violate approved pose/placement constraints.

## Technical constraints

Target: Godot 4.7.2. Coordinate posture/collider publication in physics and separate camera presentation without stale shape queries. Verify foot preservation, full-volume expansion, moving geometry and near-plane safety. Concrete shape casts, nodes, numerical margins and camera interpolation remain implementation choices. No code implementation or coding tasks are authorized.

## Acceptance criteria

1. Hold/Toggle Crouch operates independently from Run/Sneak; releasing Hold requests standing without bypassing geometry.
2. Blocked standing retains crouch and desired stand, automatically completing once clear; renewed crouch cancels it.
3. Collider and actual posture commit together in coordinated physics; foot/base position is preserved and speed observes actual posture.
4. Camera animation cannot delay shrinking/clearance or publish a conflicting collider state. Interrupted transitions remain coherent.
5. Airborne posture changes add no upward impulse, reset no falls and do not change takeoff gait before landing.
6. Full expanded shape is checked before enlargement, including mode-driven changes. No forced standing through ceilings occurs.
7. Low passages require deliberate crouch; small step/contact tolerances cannot silently bypass that requirement.
8. Camera transitions remain inside safe geometry, shortening/snapping if required without changing collider/facing/fall state.
9. Menus/focus preserve actual posture and Toggle selection, freeze transitions without catch-up and reconcile Hold from eligible input.
10. Native restoration retains actual/desired posture, waits for geometry, validates clearance and sets camera directly without replaying old transition.
11. Specialized modes declare shape/crouch support through MOVE-004; missing compatibility or invalid restoration follows explicit owner recovery rather than collision bypass.

These are future verification criteria; no implementation or runtime tests have been performed.

## Consistency review

Reviewed against MOVE-001–005, relevant CORE-013/016 restoration/suspension requirements, MOVE catalog/architecture and all nine interview decisions. No direct contradiction identified. Independent crouch leaves Sneak unchanged. Actual crouch affects grounded gait immediately while MOVE-005 takeoff gait remains latched in air. Foot preservation does not imply stable engine collider center. Camera-height animation does not change facing or replay stale input. Native saved posture differs intentionally from cleared Run/Sneak toggle requests; Hold reconciliation still requires eligible current input. Specialized dimensions/forced transitions remain unresolved rather than implicitly copied from DFU.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation is complete resolve shape/eye-height values and domains, Hold/Toggle default, interpolation/camera obstruction policy, full-volume clearance margins/layers/order, traversal tolerance limits, specialized-mode compatibility/blocked enlargement, Hold restore sequencing, native schema and moving-geometry/rendered fixtures. These deferrals do not waive deliberate crouching, foot preservation, clearance safety or actual-posture authority.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-006-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
