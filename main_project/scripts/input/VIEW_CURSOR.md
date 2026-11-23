# View and cursor contract — IMP-011 increment 3

`SessionShell.view` is the application-composed MOVE view/cursor owner. Its
`ResolvedLookCamera` is the actual current Camera3D. Startup's normal unhandled
input route admits mouse motion after GUI refusal; the existing action owner
supplies scoped keyboard/controller intent. Physics delivers discrete Center and
Cursor Toggle once; presentation consumes accumulated mouse displacement once in
`advance(eligible_seconds)`. No physics catch-up can replay a mouse displacement.
The shell no longer competes to assign mouse mode. The owner checks the engine
mode after context changes and retries a differing backend result each update;
headless has no native capture capability and qualifies requests only.

## Facing and response

Facing is resolved yaw/pitch in degrees, positive yaw right and pitch down.
Yaw wraps to [-180,180) for numeric stability without restricting repeated turns;
pitch clamps to [-89,89]. The owned camera receives that resolved rotation with
zero roll. External presentation owners must not write its rotation or substitute
a cosmetic rotation for MOVE facing. Cosmetic scene objects/effects remain
separate from this resolved-look camera; no head-bob or recoil feature is supplied.

Mouse wins when any nonzero reported motion arrived, including accumulated
opposing motion whose sum is zero. Otherwise any eligible held keyboard look
wins, even opposing keys; otherwise the selected look stick applies. The separate
keyboard-over-stick movement arbitration is unchanged. Mouse units are angular
displacement, without elapsed-time multiplication. Keyboard/controller units are
degrees per eligible second. The input owner applies analog Y inversion once;
the view applies its independently requested device vertical inversion once.

Smoothing is independently enabled per device family, default off, with a separate
time constant in seconds (default 0.08; valid 0.001–1). Larger times respond more
slowly. Mouse impulses use an exponential remaining-displacement tail. For rates,
the exact integral of `dv/dt=(requested_rate-v)/tau` produces angular displacement
over each supplied interval. Constant eligible input over equal elapsed time is
tested at 30/60/144 updates per second. Changing active sources discards the prior
source's tail; an unopposed mouse tail can settle while no competing rate exists.
Pitch clamping discards its remaining vertical tail/velocity, avoiding overshoot
debt. These are engineering response choices, not copied DFU smoothing constants.

Editable ranges: mouse axes 0.001–10 degrees/reported unit; controller axes and
keyboard rate 1–1440 degrees/second; controller cursor 1–5000 reference pixels/
second. Nonfinite/out-of-range values reject, rather than clamp configuration.
Pitch/trigger and gait/posture retained defaults cannot be edited here.

## Cursor and handoffs

Gameplay cursor mode preserves CORE simulation and movement eligibility. Entry
centers in the active viewport; leaving preserves facing. Cursor positions use
viewport UI coordinates, with controller speed expressed in a 1280-wide reference
space and scaled by viewport width (the same normalized distance at two sizes).
The input owner's linear radial look mapping supplies proportional stick response.
The viewport handles native coordinate transforms/warps. Native mouse motion
supplies absolute UI position in cursor mode; mouse/stick cursor movement never
rotates facing. Real GUI widgets consume their clicks before unhandled world
input; blank space retains the existing gameplay route.

The current UI layer temporarily owns visible/hidden cursor policy; gameplay
selection survives ordinary menus/focus holds. Return to cursor gameplay centers
again. Native-load placement explicitly chooses captured mode; capture is still
subject to CORE readiness/focus and window context. Every action-input invalidation
clears accumulated motion, smoothing and scoped gesture reservations, including
when there were no unfinished logical edges. Cursor changes and explicit facing
placement additionally invalidate unfinished gameplay input without synthesizing
deliberate releases. A handoff fence drops motion until the first eligible
presentation update, suppressing queued warp/recapture/focus-return deltas. There
is no real-time pause catch-up or fixed post-text-entry delay.

## Provider interfaces and remaining integrations

- `capture_facing(session)` returns detached `{ok,version:1,yaw,pitch}`.
- `place_facing(session, value, native_load=false)` validates current nonempty
  scope, finite numbers, schema and pitch, then immediately resets actual camera
  facing and pending response. It can operate while readiness is gated. Physical
  placement remains MOVE's later motor/provider contract.
- `ray_context(session)` returns a checked detached sample: actual displayed
  facing, center/cursor point, Camera3D ray origin/direction and action-context
  ticket. `ray_context_current(sample)` rejects context/epoch/facing/cursor changes.
  Consumers recheck at commitment and own distance, obstruction, legality and
  outcomes. This supplies neither activation nor COMBAT execution.
- `reserve_mouse(requester,session,eligible_gesture)` issues a detached scoped
  token only in eligible gameplay for an explicitly eligible gesture. It clears
  pending response immediately. Only an exact matching token can release that
  reservation; independent tokens remain. Ordinary attacks do not reserve view.
  Gesture motion is discarded, never replayed; release creates no logical edges.
  COMBAT must decide gesture eligibility and end/cancel its own activity.

Native SAVE is not delivered. Its future provider captures/restores only actual
yaw/pitch through the placement interface after establishing the correct session;
cursor selection/position, response tails, tokens and pending motion are not save
state. Real locomotion, activation, COMBAT gestures, AV cosmetics and native SAVE
remain named joint checks. Injected controllers do not qualify physical hardware.

## Preferences and verification

Controls remain version 1 with compatible additions of three smoothing-time
fields. Upgrade adds missing fields quietly, preserving supported existing values,
explicitly unbound bindings and unknown entries. Existing group repair and
unsupported-format preservation still apply. `BindingConfiguration.set_response`
validates a private draft; stock SpinBox/CheckBox handlers stage these live settings.
Apply prechecks both input and view before synchronous publication, then reports
disk outcome independently. Failed writes retain effective view settings with
UNSAVED/Retry; Cancel does not undo accepted values. Recreated views attach to the
application's effective map. Gait/posture settings remain retained and unapplied.

Independent commands: `verify_headless.ps1` and `verify_rendered.ps1`, each with
`-Suite view-cursor -Fixture view-cursor-v1`. A frozen unique-ID JSON inventory
qualifies main and fresh-process results. The fresh process checks the preserved
pre-retry disk snapshot and the final retried file independently. Rendered-only
checks include real GUI dispatch, backend capture and controlled geometry pixels.
`view_review.gd` is an explicitly controlled human fixture using the same stock
owners; no automated result claims human acceptance.
