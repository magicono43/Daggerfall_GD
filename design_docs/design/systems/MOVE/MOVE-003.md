# MOVE-003 — View and cursor control

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose and intended player experience

Provide responsive, predictable first-person view control and an optional gameplay cursor for world/HUD interaction. The view and aiming direction agree, device preferences remain independent, and context changes cannot cause camera jumps or delayed motion.

## Confirmed requirements

MOVE-003-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews, each confirmed with three “Yes” answers. The following target rules consolidate those requirements. Approved MOVE-001/002 and CORE settings, suspension, context and placement requirements remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; no runtime verification or source changes.

- `Game/PlayerMouseLook.cs#ApplyLook` scales mouse deltas by sensitivity and controller input by elapsed time, updates target facing, wraps yaw and clamps pitch. `Pitch` further limits facing close to +/-90 degrees.
- `ApplySmoothing` approaches target facing with frame-scaled smoothing and enforces a minimum controller smoothing of 0.5. Target behavior below permits fully disabling controller smoothing instead.
- `Update` toggles gameplay cursor mode, releases/shows cursor in that mode and returns before normal look processing. Ordinary pause disables mouse look. Gesture-driven non-bow melee can suppress look and call `SetFacing` to stop pending drift.
- `SetFacing` updates facing and synchronizes target/current look state through `Init`.
- `Game/PlayerActivate.cs#Update` selects a cursor-position ray in gameplay cursor mode and camera-forward ray otherwise; it excludes scene activation over the large HUD in its inspected path.
- `Game/Utility/StartGameBehaviour.cs#ApplyStartSettings` applies look sensitivity, smoothing, inversion and controller cursor settings.

The source's post-text-entry delay, Unity cursor APIs and smoothing constants are implementation observations, not automatically approved target rules.

## Detailed rules and behaviors

### Facing and look sources

Allow unrestricted horizontal turning and vertical look just short of straight up/down. Ordinary look input produces no roll. Exact pitch limit remains tuning to verify; do not copy a source constant by implication.

Resolve look input in this priority: mouse movement first; otherwise held keyboard look; otherwise controller look outside its deadzone. Do not add sources together for extra rotation. Rebindable keyboard actions turn left/right and look up/down at an adjustable rate. Opposing keyboard directions cancel on each look axis; the held-key priority still suppresses controller look for that update. This extends MOVE-001 mouse-over-controller priority without changing movement arbitration.

No automatic pitch leveling occurs during ordinary movement. Rebindable Center view immediately sets pitch to level, preserves yaw and clears pending smoothing motion. Explicit placement/facing changes can set orientation under their owners' rules.

### Sensitivity and smoothing

Provide independent mouse and controller horizontal/vertical sensitivity and vertical inversion. Provide separately adjustable mouse/controller smoothing, including fully off for either. Mouse smoothing defaults off; controller default strength requires testing. Keyboard turning rate is separately adjustable; exact keyboard smoothing treatment remains a declared tuning/integration dependency, not an implied controller minimum.

Mouse delta must not be multiplied by elapsed time a second time as if it were stick velocity. Controller/keyboard angular-rate input must produce consistent rotation over equal elapsed eligible time across frame rates. Smoothing must likewise behave consistently across frame rates. Exact algorithms/curves remain implementation choices verified against the intended response, not a requirement to reproduce DFU's formula.

Activation and aiming use the actually displayed camera facing, including selected look smoothing, rather than an unseen future target. Head bob and other cosmetic offsets cannot independently redirect gameplay aim. AV/COMBAT must distinguish resolved look facing from cosmetic effects so visual treatment cannot silently alter aim. Spread, projectile origin, obstruction, reach and target validation remain COMBAT/MOVE activation-owner rules.

### Gameplay cursor mode

Provide a rebindable toggle between captured look and a visible gameplay cursor. Enter cursor mode with cursor at screen center; mouse or controller cursor movement does not rotate view. Activation targets the cursor position in this mode and screen center in captured look. Controller cursor response/speed and device-specific cursor implementation remain UI/input integration dependencies.

Gameplay cursor mode allows movement and does not itself pause world simulation. HUD controls consume their clicks so objects behind them cannot activate from that same click. World interaction distance, availability and action effects remain their owning features' rules.

Leaving cursor mode preserves facing; do not turn toward the cursor. Suppress recapture-motion jumps. Consume the toggle input so it cannot also activate another action. Cursor capture still requires focused eligible gameplay under CORE-016; leaving a mode does not bypass a menu/load/recovery gate.

### Menus, focus and explicit facing changes

Opening a menu, losing focus, entering gameplay cursor mode or accepting an explicit facing change clears pending look motion and smoothing drift. Resume from actual facing without replaying old device movement. No menu-close click, cursor warp or focus-return delta can turn the camera or fire gameplay actions accidentally.

Ordinary menus temporarily own cursor/text input while preserving the selected gameplay cursor mode. On return, restore that mode only when gameplay is eligible. Returning to gameplay cursor mode follows the center-on-entry rule; menu cursor position is not gameplay aim. Focus return cannot recapture while another context owns cursor or suspension persists.

Explicit teleport/load placement facing resets smoothing state to that actual facing rather than interpolating from the previous location. CORE/MOVE placement owners determine when facing can be published. This feature does not invent a teleport animation or override intentional cinematic camera ownership.

### Attacks and gesture ownership

Normal attacks permit looking. Only an attack mode explicitly using mouse-motion swing gestures reserves that motion for the swing and suppresses corresponding look. Stop pending camera smoothing immediately to prevent drift. COMBAT defines gesture modes, their eligibility and activity outcomes; this is not blanket approval of gesture combat or every attack locking the camera. Input context/cancellation rules prevent interrupted gestures becoming release-triggered attacks.

## Relevant formulas and parameters

Yaw is unrestricted in accumulated turning; internal wrapping is an implementation detail. Pitch is bounded within (-90, +90) degrees by a validated exact limit to choose. Center view sets pitch = 0 while retaining yaw. Ordinary look roll = 0.

Conceptually mouse angular displacement is device delta scaled by its axis sensitivity/inversion; rate-based keyboard/controller displacement also uses eligible elapsed time. Smoothing off applies the resolved look without deferred target drift. No numeric sensitivity range, keyboard turn rate, controller smoothing default, pitch epsilon or cursor speed is approved. Separate movement/look deadzones remain approved under MOVE-001, with tested defaults/curves unresolved.

## Required data

Actual yaw/pitch; valid pitch limits; selected gameplay cursor mode; effective context/focus/capture owner; resolved look source; pending input and smoothing state; independent device/axis sensitivity and vertical inversion; per-device smoothing; keyboard turn rate; cursor position and supported response settings. Stable action IDs for cursor toggle/keyboard look/Center view use MOVE-002 binding contracts. Exact representation and schema remain implementation dependencies.

## Inputs, outputs and events

Inputs: eligible mouse/keyboard/controller look, cursor toggle and movement, Center view, settings changes, focus/context changes, explicit placement facing and COMBAT gesture ownership. Outputs: resolved actual facing, cursor mode/capture requests, camera and activation ray context, reset/cancellation of stale look, and effective preference presentation. API/signal names are not selected. Cursor/view ownership cannot bypass authoritative action eligibility.

## Cross-system interactions

MOVE-001 supplies ordered eligible input, device arbitration/deadzones and cancellation. MOVE-002 supplies rebinding, reserved recovery and staged application. CORE-003/006 supply validated preferences, safe persistence and reapplication to recreated consumers. CORE-016 owns focus, contexts, pause and cursor/text ownership; CORE-011–013 retain entry/load gates. SAVE/MOVE placement own restored pose timing. UI owns cursor/HUD hit routing; AV owns cosmetic effects without changing aim; COMBAT owns gestures and final attack resolution. These choices do not approve broader MOVE architecture proposals wholesale.

## Edge cases and failure conditions

Opposing keyboard look keys cancel without allowing a stick contribution to boost/override them. Simultaneous mouse/stick input obeys priority. Cursor movement during gameplay, menus or focus loss cannot accumulate future look. Repeated yaw turns and pitch-limit input cannot flip view or build hidden overshoot that must later be unwound.

Changing sensitivity/smoothing or camera recreation must respect CORE-006 effective-state application without stale offsets or mixed preference groups. Exact device-source switches require testing for jumps/retained smoothing tails. Gesture entry stops drift and gesture exit cannot replay reserved mouse motion. HUD clicks cannot activate through UI. Independent menu/load/disconnect reasons prevent premature recapture.

Invalid required settings follow CORE-003 validation/recovery rather than invented fallback constants. Unsupported cursor/backend behavior must use explicit owner recovery, not falsely claim capture. No physical collision or gameplay state may be inferred from cosmetic camera bob.

## Configuration and balancing options

Independent per-axis mouse/controller sensitivities, per-device vertical inversion/smoothing, keyboard turn rate and inherited separate deadzone adjustments are confirmed. Mouse smoothing defaults off; controller smoothing can also be fully disabled. Cursor mode and Center view are rebindable. Exact numeric defaults, response curves, controller cursor settings and supported presentation effects remain dependencies. No automatic leveling, mandatory controller smoothing, aim assist or combined-input rotation bonus is introduced.

## Save/load considerations

Native saves retain actual yaw/pitch, not an unseen smoothing target. Do not save cursor position or smoothing history. Loading starts captured-look mode only after placement/readiness and active input context permit gameplay; a restored modal can still own cursor and suspension. No load-time immediate capture bypass is permitted. Independent application preferences remain shared across characters under CORE settings contracts. Ordinary menu open/close preserves selected gameplay cursor mode; native-load reset intentionally differs from that temporary handoff.

## Technical constraints

Target: Godot 4.7.2. Separate device intent, resolved actual facing, cosmetic presentation and context-controlled cursor ownership. Verify frame-rate behavior and cursor recapture using real input/backend behavior; copying Unity APIs or a frame-dependent interpolation factor is not proof. Use consistent authoritative aim and view sampling without hidden future facing. Concrete engine nodes, signals, timing, smoothing algorithm and save schema remain implementation choices. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Repeated horizontal turns remain unrestricted; pitch stops just short of +/-90 degrees without flipping/overshoot debt. Ordinary look introduces no roll.
2. Mouse/controller sensitivities and vertical inversion are independent per confirmed axis/device settings.
3. Mouse/controller smoothing can each be fully disabled; mouse defaults off. Response is consistent across tested frame rates with appropriate mouse-delta versus rate handling.
4. Mouse overrides held keyboard look, which overrides stick look; opposing keyboard directions cancel and sources cannot add rotation.
5. Cursor toggle enters centered visible-cursor mode without rotating view; movement/world simulation continue unless another owner suspends them.
6. Cursor-mode activation uses cursor position, captured-look activation uses center. HUD clicks cannot also activate the world behind them.
7. Leaving cursor mode preserves facing without recapture jumps or toggle fall-through.
8. Menu/focus/cursor-entry and explicit facing changes discard stale look/smoothing motion. Return cannot apply old mouse input or bypass context/readiness gates.
9. Ordinary menus preserve selected cursor mode. Native load restores actual yaw/pitch, clears smoothing history and selects captured look only when gameplay is eligible.
10. Aim uses actual displayed look facing, not a future target; cosmetic bob does not independently redirect aim.
11. Normal attacks allow looking; explicitly gesture-driven mouse attacks reserve their motion and stop camera drift, without replaying gesture movement afterward.
12. Rebindable Center view immediately levels pitch while preserving yaw and clearing smoothing. Ordinary movement never automatically levels the view.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against MOVE-001/002, CORE-003/006/016 and relevant entry/load gates, MOVE catalog/architecture review and twelve confirmed interview decisions. No direct contradiction identified. Keyboard look priority extends the existing mouse/controller rule; it does not change movement priority. Gameplay cursor mode is distinct from paused UI. Native-load captured mode is explicitly different from ordinary-menu mode preservation. Actually displayed facing means resolved look orientation, with cosmetic effects excluded from gameplay aim. Reserved Escape/Menu recovery remains intact; cursor toggle is separately rebindable. COMBAT gesture selection, AV effects and engine tuning are not approved wholesale.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: exact pitch/sensitivity/rate limits and defaults; controller smoothing and cursor response tuning; deadzone curves; keyboard smoothing policy; mouse-delta/frame-rate/backend validation; device-source transition behavior; aim/cosmetic sampling and gesture contracts; cursor/HUD context integration; native pose schema and restoration verification. These deferrals do not waive no-drift handoffs, proportional eligible controls or visible-facing aim consistency.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under MOVE-003-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
