# Action input — IMP-011 increments 1, 2 and 3

IMP-012 increment 1 supplies the real [ground/gait consumer](../move/GROUND.md).
Stock Controls applies independent Hold/Toggle Run/Sneak. Crouch remains retained
Toggle with its actual posture consumer pending increment 2. Earlier statements
below that all gait consumers/edits are unavailable are historical.
`continuous_held` narrowly exposes eligible retained Run/Sneak/Backward physical
history without synthesizing discrete presses. Other action delivery is unchanged.

## View and cursor — increment 3

The stock session now composes `view_cursor.gd` and its actual Camera3D. See
[the view/cursor contract](VIEW_CURSOR.md) for response units/bounds, exact
smoothing, source priority, cursor handoffs, scoped gesture/ray/placement interfaces,
compatible preference additions and independent verification. The stock controls
editor applies view response through the same application settings owner as input.
The older increment-1/2 descriptions below describe their delivered source scopes;
statements that view/cursor is unstarted or all response edits are rejected are
superseded by increment 3. Gait/posture consumers remain undelivered.

## Application binding configuration — increment 2

`StartupController.controls` is the application-lifetime `binding_configuration.gd`
owner. It declares `controls/configuration` before settings initialization and
loads the effective configuration before attaching input consumers. `begin`,
`propose`, `reset_action`, `reset_all`, `set_analog`, `resolve_replace`, `apply`,
`cancel` and `retry_save` are validated requests. `draft`, `effective` and `pending`
return detached projections. Character saves never supply these preferences.

The version-1 Dictionary in settings.ini has stable `actions` identities (including
unbound `slide`), two `keyboard` and two `controller` slots per action, separate
`analog`, and retained approved `response` defaults. An empty Dictionary is an
explicit unbound slot. Only an absent action is an upgrade addition. Unknown
actions/fields round-trip but are excluded from compiled runtime catalogs.

Contexts are declared: all gameplay actions overlap each other; `ui_confirm` and
`ui_back` overlap in UI, which is mutually exclusive with gameplay. Keyboard UI
navigation/recovery stays independent; the UI actions expose two controller slots.
Plain/chord reuse has explicit chord precedence at main-down. Identical inputs or
distinct chords on one main input in overlapping contexts require Replace/Cancel;
multiple modifiers could otherwise make both chords eligible. Validation rejects
ambiguity before building the runtime index; insertion order is not resolution.
Replace explicitly clears the displayed victims. Cancel leaves the draft unchanged.
Clear warns through the unbound inventory. Per-action resets require the same
conflict handling; Reset All stages the coherent stock map without applying it.

Supported inputs are physical keys; explicit left/right Shift/Ctrl/Alt; one of
those modifiers plus a key or mouse button; Godot mouse buttons 1–9 including
wheel steps; one controller button; and left/right trigger axes at 0.55/0.45
hysteresis. Controller combinations, arbitrary discrete axes and Escape/Start
assignments are rejected with a reason. Layout labels are queried at rendering,
and a changed current-layout index refreshes the open editor. Headless labels
fall back to physical names because no keyboard-layout display API is available.

Stick assignment is a separate request: left and right pairs must be distinct.
DFU-labelled axes 1/2 and 4/5 map to Godot's LEFT_X/Y and RIGHT_X/Y pairs rather than
copying the DFU numeric identifiers. Independent finite deadzones in [0,1), radial
rescaling, and Y inversion apply to the input intent. Camera/view/cursor, gait,
posture and combat application remain later owners/increment 3. The approved
response/mode defaults are retained, but changing those fields is rejected until
their consumers are implemented; no inactive edit is reported as applied.

`binding_editor.gd` supplies the stock title and Pause → Settings → Controls
handlers. Capture runs after physical observation and before widget/gameplay
dispatch. It waits for existing down inputs to release, ignores pointer motion
and stick drift, distinguishes trigger hysteresis, cancels on Escape/effective
controller Back/focus loss, and exits to controls on any controller Start. A
modifier released alone captures that side; a chord selects on its main press.
Consumed wheel steps are completed without waiting for a nonexistent platform up.
All capture events remain consumed through cancellation. Effective controller UI
Confirm/Back dispatch uses a cached index, prevents held repeats, and suppresses
Godot's old A/B routes when those mappings are cleared. Ordinary navigation and
independent Escape/Start recovery remain available.

Apply validates the entire candidate, prechecks consumers, replaces complete
indexed catalogs synchronously and invalidates pending input through the existing
epoch/cancellation interface. Old physical holds remain quarantined; no synthetic
release or new press is generated. CORE settings acceptance and disk publication
are checked separately. A failed write leaves effective controls in memory with
UNSAVED feedback and Retry Save; reloading before retry gets the previous disk map.
Recreated input consumers attach to the effective application configuration.

CORE-003 extension hooks register before initialization: `declare_upgrade` returns
`{value, resets}` for compatible additions/repair; `declare_format_guard` rejects
unsupported owner versions through existing incompatible/reset/preservation flow.
Invalid action groups reset only affected actions and any connected conflicts to
coherent defaults. Invalid analog/response groups preserve discrete assignments.
Unknown entries remain preserved. Genuinely new defaults are added only if free;
otherwise the new action stays unbound with an identifying notice. Existing
staged-write/verify/backup/replace and required startup failure behavior is reused.

Independent verification uses `-Suite binding-config -Fixture binding-config-v1`
with `verify_headless.ps1` and `verify_rendered.ps1`. Both main and fresh-process
inventories are qualified by stable unique assertion names. The human review
fixture is separate and cannot report human PASS. See the increment-2 execution
and binding-review evidence in `design_docs/development/evidence/`.

## Accepted logical delivery — increment 1

`SessionShell` composes one application-lifetime `action_input.gd` with the actual
CORE lifecycle/gates and UI window stack. `StartupShell._input` observes physical
downs/ups before GUI handling; `_unhandled_input` accepts gameplay presses only
after GUI handling. Text/IME remains Godot/UI-owned. Physical key code and location
are identities; localized/logical key labels never relocate a gameplay binding.

The immutable-by-construction indexed `action_bindings.gd` catalog supplies the
approved `INPUT_DEFAULTS.md` baseline. Its optional constructor catalog is a trusted
composition seam used for overlapping bindings, one-sided modifiers, wheel steps
and trigger tests. It is not an editor, preference store, mod registration API or
an authorization to publish conflicting configuration. BindingConfiguration now validates
and atomically publishes its complete configuration before using this seam.
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
navigation decision. Controller B is the default configurable Back in an existing UI context. GUI and
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
the threshold handles Godot Vector2's float precision. Preference exposure is delivered in
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
providers remain named later integration gates. Increment 2 is implemented above;
increment 3 remains unstarted. Increment-1 keyboard/mouse review and explicit user
acceptance are recorded on 2026-11-23; the earlier open keyboard list is historical
for increment 1, while the new binding editor has its own human review checklist.


Human binding-editor follow-up, 2026-11-23: the user reports all six agreed
keyboard/mouse checks PASS. Increment 2 is ready for acceptance, with formal
acceptance tracked separately. The reviewed build is compacted after preserving
human state/logs. Physical controller/IME qualification stays deferred to later M2.


Acceptance update, 2026-11-23: the user explicitly accepted increment 2 after all
six editor checks passed. The increment-3 handoff is prepared; no view/cursor
implementation begins in this chat. Parent/real-provider gates and physical
controller/IME deferrals remain open.


Human review follow-up, 2026-11-23: the user explicitly reports all six new keyboard/mouse view/cursor checks PASS. Increment 3 is ready for explicit acceptance; formal acceptance remains separate. The bottom-left text visible over Pause/Controls is the review-only diagnostic Label in tests/view_review.gd, outside the stock HUD/panel; this observation is recorded and requires no production change. Physical controller/IME deferrals and parent/real-provider gates remain unchanged.

## Explicit acceptance and next handoff — 2026-11-23

The user explicitly stated: "I accept what you have done in increment 3 and deem
IMP-011 completed". **Increment 3 and IMP-011 are complete and user-accepted.**
All six new keyboard/mouse view/cursor checks are user-reported PASS. This
supersedes earlier acceptance-pending and parent-IMP-011-open statements.
Physical controller/changed-host IME qualification remains explicitly deferred to
later M2. Named real locomotion/activation/COMBAT/AV/SAVE joint checks and M2 remain
open; task acceptance does not claim those providers delivered.

At the user's request, the IMP-061 increment-1 assembly prompt is prepared at
`design_docs/development/handoffs/IMP-061-INCREMENT-1-PROMPT.txt`. Issuing it in the
destination chat authorizes that increment only; no IMP-061 implementation starts
here. Accepted implementation remains uncommitted at preparation (HEAD cff2df7).
Preserve the latest tree. The reviewed diagnostic overlay remains fixture-only.
