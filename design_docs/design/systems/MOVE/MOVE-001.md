# MOVE-001 — Action polling

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose and intended player experience

Translate keyboard, mouse and controller input into reliable gameplay actions and movement/look intent. Switching devices during play needs no restart. Brief taps survive until their appropriate gameplay update without duplicate delivery, unintended attacks on returning from menus, or combined-device speed increases.

## Confirmed requirements

MOVE-001-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews, each answered “Yes” to all three recommendations. The rules below consolidate those confirmed choices. CORE-016 input-context, suspension, focus and fresh-press requirements remain authoritative; CORE-017 keeps gameplay-input eligibility separate from simulation eligibility.

## Existing Daggerfall Unity behavior — reference only

Source baseline: local `daggerfall-unity-1.1.1-cve-2025`, DFU 1.1.1 Release. Exact commit unavailable; see [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; source remains unchanged.

Source paths below are relative to that directory's `Assets/Scripts/`:

- `Game/InputManager.cs#Update` copies current actions to previous actions, clears current actions and polls devices each frame. It resets look fields, updates controller cursor handling, then gates ordinary gameplay processing on pause and a short post-pause delay.
- `PollInput` samples keys and sends key-down/up notifications to UI even before the ordinary gameplay pause gate.
- `HasAction`, `ActionStarted` and `ActionComplete` query current membership and differences from previous-frame membership. These queries do not themselves consume an action or establish once-only physics delivery.
- `FindKeyboardActions` and `FindInputAxisActions` populate gameplay actions and apply movement input; controller movement uses configured thresholds/deadzone. `Update` collects mouse/controller look; `UpdateControllerCursorPosition` handles controller cursor input.
- `ClearAllActions` clears action lists and movement/look fields.

The target rules below supersede source behavior where explicitly selected. Runtime missed/repeated inputs and classic parity have not been demonstrated.

## Detailed rules and behaviors

### Logical actions and reliable delivery

Expose logical held, started and released state, plus cancellation distinct from deliberate release. Multiple physical inputs holding the same action form one logical hold. A second overlapping input does not create another start; ordinary release occurs only after all contributors release. This aggregation applies to action identity; movement/look arbitration below controls resolved axes.

Retain a brief eligible discrete press until the next appropriate gameplay update, even if both press and release occur between physics steps. Preserve separate eligible taps in order and deliver each once. Multiple physics updates cannot replay the same press. The receiving feature validates each press at delivery; rejection expires it rather than retaining it until a cooldown ends. Input retention does not guarantee action execution or introduce a combat queue. Press/release ordering must remain available so a completed brief tap cannot become a stuck hold.

Menu entry, focus loss, loading or session changes invalidate pending gameplay presses from the old context. Cancel affected unfinished input rather than synthesize deliberate release. A charge or other release-triggered action cannot fire merely because its input was cancelled. COMBAT and other receiving owners define disposition of their interrupted activity.

### Context and focus handoff

Route input to the eligible focused context under CORE-016. UI remains responsive while ordinary gameplay is suspended. Consume window-open/close and other handoff input so it cannot activate gameplay or another context. Return to gameplay requires fresh discrete presses; currently held movement may resume. A held attack trigger cannot become a new attack solely because a gate cleared.

Simulation readiness does not alone grant gameplay input. Loading, initialization, focus loss and independently owned suspension reasons remain binding. Context invalidation and ending-session cleanup must prevent stale input from reaching a replacement session.

### Movement arbitration

While any keyboard movement direction is held, use keyboard movement alone. Opposing keyboard directions cancel per axis. Holding both Forward and Backward therefore produces no forward/backward intent and still suppresses controller movement. When no keyboard movement direction is held, use controller movement outside its deadzone.

Keyboard priority explicitly resolves the earlier cross-device cancellation wording in D04: keyboard Forward plus controller Backward moves forward. Do not combine devices to increase speed. Actual gait, diagonal speed policy, collision movement and physical speed remain MOVE-004/005 and related movement-owner contracts.

### Look arbitration and analog input

When the mouse moves, use mouse look for that update without adding controller look. Otherwise eligible controller look can apply. Camera sensitivity, smoothing, keyboard look behavior and final view application remain MOVE-003 scope; this feature does not approve their numerical tuning.

Provide separately adjustable movement and look deadzones. Input within the applicable deadzone is neutral; outside it, retain proportional analog control. Exact defaults, shape, response curves and rescaling require controller testing under MOVE-002/003. Deadzone noise cannot count as accepted controller movement/look for active-device tracking.

### Device disconnection and return

Track the device that last supplied accepted gameplay input. Controller disconnection immediately removes its held contributions and cancels affected unfinished release-triggered actions rather than firing them. Another connected input's hold must not become a new start merely because a contributor disappeared. Consumer-specific handling of an interrupted activity remains explicit.

If the disconnected controller was the active gameplay device, acquire a disconnect-prompt suspension reason and offer reconnection or keyboard/mouse continuation. Disconnecting an idle controller while keyboard/mouse is active does not pause. Reconnection alone does not dismiss the prompt. Explicit Continue after reconnection or choosing keyboard/mouse releases only the prompt's suspension reason; other suspension/readiness gates remain effective. Fresh discrete presses are required after return.

## Relevant formulas and parameters

For an ordinarily eligible action, held means at least one contributing physical input is held. Started is the transition from no contributors to one or more; ordinary release is the transition back to none through deliberate release. Cancellation is a separate outcome, not an ordinary release edge.

Movement source is keyboard if any keyboard movement direction is held, otherwise eligible controller movement. Look source is mouse when it moves, otherwise eligible controller look. No combined-device speed or rotation bonus applies.

Movement/look deadzones are separate validated settings. No numerical defaults, input-buffer duration, universal cooldown, repeat rate, simulation frequency or camera curve is selected. Discrete retention lasts until the next appropriate eligible delivery or context invalidation, not until an otherwise illegal action becomes legal.

## Required data

Stable action identities and resolved bindings; per-device contributors; logical action state; ordered pending discrete input with its valid context/session; cancellation versus release; eligible context/focus/simulation gates; movement/look samples and deadzone settings; last accepted gameplay device; connection state and disconnect-prompt ownership. Representation, event IDs, queue capacity and tie-breaking for simultaneous device activity remain engineering contracts.

## Inputs, outputs and events

Inputs: device samples/events, binding resolution, focus/context/lifecycle changes, device connection changes and explicit disconnect-prompt choices. Outputs: resolved movement/look intent, held actions, ordered once-delivered start/release information, explicit cancellations and owner-scoped disconnect suspension/prompt requests. API and signal names are unselected. Input reports intent; domain owners authorize gameplay effects.

## Cross-system interactions

- CORE-016 owns suspension, cursor/text context, focus and coherent handoffs; disconnect recovery cannot release another owner's reason.
- CORE-017 separates simulation eligibility from input eligibility. Smooth movement and input are not forced onto slow cadence.
- CORE-005/011–013/015 provide scope disposal, entry/load and lifecycle gating. Restored modals may retain suspension.
- MOVE-002 owns binding profiles and supported settings; MOVE-003 owns view/cursor behavior and camera tuning. MOVE-004/005 and alternate motors consume resolved intent.
- UI owns context precedence, prompts and accessible input presentation. COMBAT/MAGIC/interaction owners define press/release/cancel consequences and reject illegal deliveries without delayed execution.
- SAVE separates character state from application input preferences and transient physical input.

## Edge cases and failure conditions

Quick press/release between physics steps must remain a tap, not disappear or remain held. Several taps remain distinct; catch-up updates cannot multiply them. Overlapping bindings produce one start and no early ordinary release. Direction keys cancelling each other still suppress the stick. Mouse and stick cannot add rotation.

Opening or closing UI, alt-tabbing, loading and disconnecting cannot fire a charged action or replay old presses. Controller noise inside deadzones cannot steal active-device status. Disconnecting the active controller while another pause reason exists must add independent ownership, and continuing must leave the other reason intact. Reconnection and context return cannot reinterpret a held discrete trigger as fresh input.

Bounded storage/overload handling must preserve approved ordering and no-duplicate semantics; silent loss or an unbounded catch-up burst is not an established solution. Exact capacity and failure policy require engineering resolution before delivery guarantees can be claimed. Simultaneous-device ties and supported multiple-controller topology also require explicit implementation contracts rather than incidental callback order.

## Configuration and balancing options

Keyboard/mouse and controller support are required. Separate movement/look deadzone adjustment is confirmed. Binding conflicts, defaults, response curves, camera settings, hold/toggle gaits and repeat behavior belong to their feature owners. No combat-buffer setting or input-based speed advantage is introduced.

## Save/load considerations

Pending physical presses, held-device state and runtime context/suspension ownership are transient and cannot replay into loaded gameplay. Loading invalidates prior pending gameplay input. Reconstruct eligible context under CORE/SAVE/UI before returning control, requiring fresh discrete input. Input preferences remain separate from character state; exact persistence schema belongs to MOVE-002/CORE settings. Interrupted gameplay activities are persisted or reconstructed only under their owning feature's approved rules, never by restoring a held trigger.

## Technical constraints

Target: Godot 4.7.2. Capture input independently of authoritative delivery timing, preserve appropriate ordered edges and prevent repeated delivery across physics steps. Engine action queries alone are not proof that brief taps, cancellation or overlapping devices satisfy this contract. Public APIs, node ownership, polling/event mix, input-storage bounds and device identifiers are implementation choices to verify. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Keyboard/mouse and controller work and switch during play without restart.
2. A brief eligible tap entirely between physics steps reaches the appropriate gameplay consumer once, with ordered press/release information and no stuck hold.
3. Multiple distinct taps retain order; several physics steps do not duplicate them. Illegal presses expire rather than firing after cooldown.
4. Two overlapping inputs for one action create one start; releasing one leaves it held, and final deliberate release ends it once.
5. Keyboard Forward defeats controller Backward. Opposing keyboard keys cancel and suppress stick movement while held. Releasing all keyboard direction keys permits controller movement.
6. Mouse movement excludes controller look for that update. Combined devices cannot increase speed/rotation.
7. Movement/look deadzones are independently adjustable; inside input is neutral and outside proportional control remains available under the declared tested curve.
8. Menu/focus/load/session invalidation clears stale pending presses and reports affected unfinished input as cancelled. No attack or activation results solely from cancellation or context return.
9. UI handoff input is consumed; held direction may resume, while held discrete triggers require fresh presses. Other CORE readiness/suspension gates remain effective.
10. Controller disconnection clears affected contributions immediately, cannot fire release-triggered actions, and pauses only when that controller was the last accepted gameplay device.
11. Reconnection alone cannot resume; explicit continuation releases only the disconnect prompt's reason. Idle-controller removal during keyboard/mouse play does not pause.
12. Native load/session replacement cannot restore or deliver old device input. Scope teardown rejects stale deliveries.

These are future verification criteria. No runtime tests or implementation have been performed.

## Consistency review

Reviewed against the MOVE feature catalog/architecture review, confirmed interview decisions and approved CORE-016/017 contracts, with CORE lifecycle/load dependencies retained. No direct contradiction identified. D07 explicitly clarifies D04/D05 instead of retaining incompatible cross-device cancellation and keyboard-priority rules. Once-delivered input does not guarantee once-executed gameplay effects or introduce cooldown buffering. Disconnect suspension adds an owner reason without changing CORE pause ownership. MOVE-AR-01 remains Proposed beyond these explicitly confirmed input requirements; broader architecture proposals are not approved wholesale.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Engineering and cross-owner dependencies remain: action/consumer inventory and delivery boundaries; finite queue capacity/overload policy; simultaneous-device tie-breaking and multiple-controller support; precise deadzone/default/curve validation; UI context/prompt details; release/cancellation consequences per activity; binding/preferences persistence and input integration verification. These deferrals do not waive ordered taps, cancellation safety or owner-scoped suspension.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under MOVE-001-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
