# Logical delivery — IMP-011 increment 1

`SessionShell` composes one application-lifetime `action_input.gd` with the actual
CORE lifecycle/gates and UI window stack. `StartupShell._input` observes physical
downs/ups before GUI handling; `_unhandled_input` accepts gameplay presses only
after GUI handling. Text/IME remains Godot/UI-owned. Physical key code and location
are identities; localized/logical key labels never relocate a gameplay binding.

The immutable-by-construction indexed `action_bindings.gd` catalog supplies the
approved `INPUT_DEFAULTS.md` baseline. Its optional constructor catalog is a trusted
composition seam used for overlapping bindings, one-sided modifiers, wheel steps
and trigger tests. It is not an editor, preference store, mod registration API or
an authorization to publish conflicting configuration. Increment 2 must validate
and atomically publish its complete configuration before using this seam.
One matching modifier chord wins over a plain binding; resolution is locked on
the main down, so changing modifiers cannot start/switch that hold. Catalog order
breaks ties between matching chords (there are none in the stock catalog); the
binding editor must reject ambiguous same-context candidates rather than rely on
that defensive ordering. Modifier identities include explicit left/right location.

## Capture, delivery and cancellation

- Physical contributors aggregate by action. One logical hold ID produces one
  `started` and one final deliberate `released`; each queued edge also has a
  monotonically increasing sequence, original session, UI context and input epoch.
  Godot's serialized event-arrival order breaks ties between otherwise simultaneous
  physical events; shortcut candidates use the fixed UI priority below.
- Capacity is **256 logical edges**, including ups. A completed tap occupies two
  slots. The 257th edge invalidates all unfinished input and emits `failure` with
  the rejected edge, capacity, pending count and cumulative delivered edge count.
  Down identities remain quarantined until release; no synthetic up or new start
  follows cancellation. A future explicit press can recover immediately.
- `deliver(consumer)` consumes at most the batch present at entry. It rechecks
  CORE eligibility, context and epoch between callbacks. Reentrant input waits
  for the next update, including when targeted cancellation removes old edges.
  `StartupShell._physics_process` calls the stock `SessionShell.deliver_input`.
- The consumer's return is retained in the returned batch outcomes alongside the
  already-delivered edge. Rejection expires that edge; it does not queue a retry
  until gameplay becomes legal. This is intent delivery, not action execution.
  There is no long-lived outcome history or combat queue in MOVE. Owners retain
  their own committed consequences; callers retain returned batch results.
- Gate eligibility changes, UI context changes and CORE retirement synchronously
  invalidate pending input. `cancelled` separately reports the discarded pending
  edges and delivered-but-unfinished holds. Fully delivered start/up pairs are
  absent from this cancellation list. A queued up that is cancelled is never
  sent through the ordinary release consumer.
- Owners can observe stock `gameplay_edge` and `gameplay_cancelled` signals. Edge
  projections are read-only and include original scope/context/hold identity.
  `context_current(edge)` rechecks scope, UI context, input epoch and eligibility
  (including focus out/in without a window change). Consumers recheck it before
  owner mutation, validate effects, handle cancellation explicitly and
  disconnect scoped subscriptions on retirement. No CHAR/MAGIC/COMBAT/SAVE or
  interaction consumer is supplied here. A signal observation claims no effect.

Each physics delivery is one shortcut batch. `SessionWindowStack.dispatch_actions`
reuses its existing priority: options, character, inventory, travel, rest,
transport, journal, notebook, spellbook, magic item, status, automap, quicksave,
quickload. Both quick candidates are removed on conflict before choosing at most
one winner. Suppressed candidates are not retained. Unsupported stock winners
report unavailable; opening the spellbook never casts a spell. F7 changes only
CORE's existing HUD preference. Other feature intent has no invented consumer.

Reserved Escape and controller Start use the existing UI options dispatcher, with
physical contributor aggregation. A requester-owned input hold bridges capture
to that dispatch, so pending gameplay cannot run in an intervening physics step.
Options remains usable during suspension; its hold releases only after the
navigation decision. Controller B handles Back in an existing UI context. GUI and
IME get first refusal; releases are still observed if GUI consumes them. The
stock shell releases GUI focus when eligible gameplay has no window, so Space,
Enter and controller Confirm cannot remain armed on its placeholder Pause button.
Menu/title/prompt/disconnect contexts retain their ordinary UI focus handling.
CORE gate changes schedule the same coalesced refresh, so an independently owned
hold can expire without leaving a menu button armed in resumed gameplay. Blank
stock shell space bubbles pointer input (root PASS, decorative background IGNORE);
actual widgets still consume their clicks before gameplay acceptance.

## Controller and continuous intent

Selection is explicit through stock controller buttons; connection never selects
a controller or continues a suspended session. Only the selected device supplies
gameplay intent. Start remains an independent recovery route from any controller.
Changing selection clears the outgoing controller's activity identity, so removing
the newly selected controller before it supplies input is an idle disconnect.
Device-numbered defaults 0/3/2 supply activate/attack/autorun; B is UI Back. Default
movement/look pairs use Godot left/right stick semantic axes corresponding to the
approved DFU axis pairs. Raw hardware mappings/labels still require device checks.

Only accepted unhandled gameplay input updates the active device. Mouse motion
updates device identity but stores no camera delta in this increment. Deadzone
noise and keyboard-suppressed controller movement cannot mark a controller active.
Selected-device removal cancels affected
pending/delivered unfinished holds, quarantining an overlapping other contributor
without creating another start. Unrelated keyboard input survives an idle-device
removal. Removing the active device acquires the session-scoped
`action-input-disconnect` CORE hold on simulation/input. Reconnect alone cannot
release it. Explicit Continue Controller requires that selected device to be
connected; Continue Keyboard deselects it. Both release only that requester's
token. Other focus, window, operation and readiness holds remain effective.

Buttons/triggers already held at actual hardware selection/reconnection are
quarantined by polling current state. Focus return reconciles missing physical ups
without creating logical releases. Backend/device behavior remains a manual gate.
Trigger down/up thresholds are 0.55/0.45. A wheel event is a complete tap even if
the backend supplies no up. Movement/look radial deadzones are separately 0.15 and
0.10, with linear rescaling and unit magnitude clamping. Approximate equality at
the threshold handles Godot Vector2's float precision. Preference exposure is
increment 2; view/cursor/smoothing/rate application is increment 3.

`movement()` is a detached intent value, not a MOVE motor. Any held keyboard
direction suppresses controller movement, including opposing keys. Still-held
directions may resume after UI handoff without new discrete edges. GUI-consumed
analog events cannot become accepted gameplay input. No camera, collision,
posture toggle, screenshot, console or gameplay save implementation is implied.

## Verification and open gates

On 2026-11-23 the user deferred physical controller and changed-host IME manual
qualification to later M2. They remain untested and tracked, but do not block
increment-1 acceptance after keyboard/mouse/focus review. The disposable review
package and latest verification are recorded in the IMP-011 execution evidence.

Run independently from the repository root:

```powershell
./main_project/tools/verify_headless.ps1 -Suite action-input -Fixture action-input-v1
./main_project/tools/verify_rendered.ps1 -Suite action-input -Fixture action-input-v1
```

The fixture uses production capture/delivery, actual CORE/window gates, stock
dispatch and an engine-routed tap across a real physics boundary. Injected joypad
events/connection notifications verify interfaces, not a physical device. The
rendered result includes a stock frame. Full M1 composition/session/UI regressions
are independent selections; measured startup is not a newly approved budget.

Open manual checks: physical keyboard/mouse quick taps and overlapping buttons;
Alt-Tab held inputs and releases while unfocused; multiple physical controllers,
explicit selection, selected/idle unplug, held reconnect, explicit Continue with
another pause owner, Start/Back recovery and backend axis/trigger identities.
The prior accepted Japanese IME results apply to M1; rerun physical composition
against this changed input host when qualifying this increment. Automated stock
prompt regressions do not establish physical IME acceptance for the new build.
Real movement/combat/release-triggered gameplay, save/load and gameplay window
providers remain named later integration gates. Increments 2/3 remain unstarted.
