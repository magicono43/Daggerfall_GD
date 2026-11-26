# Increment-4 extension

The same coordinator/capsule now has coordinated mechanism motion, separate
passive attribution, retained crush delivery and committed feedback. See
[PLATFORMS_FEEDBACK.md](PLATFORMS_FEEDBACK.md) for the current contract and
qualification boundaries. Earlier increment-only exclusions below are historical.
Parent IMP-012/M2 and the named real-provider/native SAVE gates remain open.

# Increment-3 extension

Air, zero-time takeoff billing, gravity, landings and retained health outcomes now
extend this same coordinator/body. See [AIR.md](AIR.md) for current interfaces,
scale, tuning, recovery, controlled-provider and in-memory snapshot limits.
Historical ground-only/unimplemented-air statements below describe earlier
increments. Platform carriage/crushing, broad AV feedback and native SAVE remain open.

# Increment-2 extension

Posture and surfaces now extend this same coordinator/body; see
[POSTURE_SURFACES.md](POSTURE_SURFACES.md) for the current shape, control, speed,
support, stair, camera and future-owner contracts. Earlier standing/flat-only
boundaries below describe the accepted increment-1 build.

The current surface motor commits full-capsule-qualified route fragments under
the same MOVE authority. The increment-1 `move_and_collide` description below is
historical; the ordinary-stair follow-up preserves across/follow fragments rather
than sending their diagonal chord through a second collision recovery.

# Ground motor and gait — IMP-012 increment 1

`SessionShell.ground` is the session coordinator. The stock physics handler first
delivers the existing once-only input batch, then calls `physics_step(delta)`.
The coordinator uses `action_input.movement()`, the view owner's actual yaw,
CHAR's narrow `ground_capabilities`, and the already committed MOVE capsule.
`placement_authority.advance_ground` is the only physical writer. It sweeps that
body with `move_and_collide`, with at most four ordered sliding operations; it
does not replay placement validation/commit or assign positions to simulate travel.
The body publishes its actual pose before the coordinator's scoped `committed`
notification. Requested gait, capped target speed, requested displacement,
collision-limited voluntary displacement and passive displacement remain distinct.
The shell follows the committed body position without resetting view aim each step.

## Supported physical profile and units

This increment supports standing, ordinary foot movement on measured flat static
ground. The accepted placement capsule remains radius 0.3 m, height 1.8 m, centre
0.91 m above the fixture floor. The active coordinate contract remains
`dungeon-geometry-metres-v1`: classic source positions were already converted at
0.025 m/source unit. Physical velocities and displacement are metres/second and
metres. No second source-point conversion is applied to gait speed or world pose.

The checked `move.ground:policy#player` definition comes through the ordinary
DATA/MOD/captured-loose precedence, provenance, candidate commit and content lock.
`content/move/ground.json` records the approved standing constants, maximum
100 m/s, mapping one gait-speed unit/second to one engine metre/second, and actual
moving threshold 0.0001 m/s. The cap is tuning, not a malformed-number fallback.
The selected `move.ground-speed` RULE hook (`ground-speed-v1`) takes exactly
`{gait,profile,speed,running}` and returns a finite positive float at most 1e22.
It is declared before publication, admitted by CORE's actual formula consumer
binding, and uses the existing signature/error/no-fallback machinery. The
approved DFU-derived formulas are MIT; the existing RULE DFU notice applies.

Live Speed and Running are strict integers 0..1e9. Signed/out-of-domain Running
requires a compatible consumer profile rather than silent clamping. Source
factors are finite 1e-6..1e6, separately keyed Walk/Run/Sneak, up to 64 retained
source identities. Sorted log-domain combination avoids intermediate overflow
and applies the final cap after all contributions and world mapping. Tiny valid
products that underflow the positive output domain reject. Sneak begins from
unmodified standing Walk; it does not inherit Walk source factors.

`gait.source(actual_owner, {session,source,revision,lifetime:"session",factors})`
requires an actual trusted provider implementing
`ground_source_current(detached_request)->bool`. Revisions are integer 1..1e9;
same-revision changed intent, decreasing revisions and another provider claiming
the identity reject. An empty factor map removes only that source and retains
its tombstone. Required active provider loss/staleness rejects. This qualifies
the source seam, not real ITEM/MAGIC effect/encumbrance composition or executable
mod loading. Vanilla supplies no encumbrance slowdown or separate sprint resource.

## Input and lifecycle

Stock Controls now edits `run_mode` and `sneak_mode` independently through its
real OptionButton handlers and existing apply/save/retry owner. Defaults remain
Hold/Hold; crouch stays retained Toggle and has no enabled posture consumer.
Toggle state belongs to gait, not saved preferences. Run clears Sneak; eligible
Hold Sneak can resume after Run. Selected-device/deadzone/keyboard priority stay
in the existing input owner. Direction magnitude is capped, retaining analog
Run magnitude. No private physical map or second edge consumer exists.

Autorun supplies synthetic forward plus Run; backward (including an opposing
held Backward key), retoggle, menus, focus/context loss and controller recovery
cancel it. Ordinary menus preserve gait toggles. Held gait evaluation uses the
same retained eligible physical history as continuous directions; it creates no
new discrete edge. Gait scope reset clears toggles/autorun/source handles without
clearing physical input history. Placement resets operation sequence separately
from aim reset. Loading must use the existing placement/load handoff and reset
gait scope; native SAVE motion restoration remains undelivered.

CORE suspension returns without physical advancement, velocity reset or accumulated
wall-time catch-up. Eligible delta uses CORE's current intended rate, including
changes made while held; zero intended rate advances nothing. The scaled physics
step must fit (0,0.1] simulated seconds or returns explained recovery. This adds
no player-facing rate feature or slow-consumer cadence. Restrictions instead
disable voluntary direction. The required
restriction supplier returns exactly `{ok:bool,revision:int,voluntary:bool,
run:"allow"|"walk"|"stop"}`. A rejected Run uses only that explicit fallback.
It cannot freeze gravity or passive motion. This increment does not own those
later physical modes: existing nonzero vertical velocity, nonstanding posture,
unready geometry, nonflat support or an unsupported ground exit fail explained
and preserve history under a requester-owned recovery hold. Flat support rays
are observations only; actual clearance/collision uses the real capsule sweep.
Slopes, steps, full posture clearance, airborne/landing/platform/external-force
semantics and AV feedback remain increments 2–4 or the named specialist owner.

## Activity, suppliers and performed-work custody

`bind(session,actor,time,traits,restrictions)` requires explicit supplier Objects
and the currently published profile. It grants no entry/readiness itself.
CORE must independently bind the actual motion, interval, traits and formula
services. The stock full story provider remains unavailable. Controlled entry,
LOC readiness, TIME, effective traits and restrictions qualify these interfaces
in the bounded course; they do not deliver full TIME, NPC threat or mod resources.

TIME supplies `ground_interval(context,delta)` returning exactly
`{ok,provider:{id,revision},clock:<actor-activity-v1 clock>}`. It proposes an
eligible interval without advancing it. Its simulated duration must match the
physics delta within one microsecond and its game/simulated mapping must be exact.
Starts match CHAR's ordered cursor. The controlled clock retains fractional
microseconds and uses the approved nominal 12/1 mapping; this is explicitly not
a production TIME implementation or slow-consumer scheduler. No wall/UI time or
frame-count charging is used.

The trait supplier returns exactly `{ok,revision,athleticism,
improved_athleticism,argonian}` with strict booleans; no display-name inference.
After real physical commitment MOVE captures actual motion under its original
scope/content/capability/provider revisions. TIME's `capture_ground(request)`
retains that original performed eligibility proof before delivery to real CHAR.
TIME/traits implement the accepted `activity_current` attestations. Consecutive
compatible performed steps grow a segment before its first delivery. A segment
ends at one eligible simulated second, a changed actual motion/trait/source/clock
context, a flush request, or suspension. The size boundary may be exceeded only
by the current bounded physics step. Actual speed above the declared threshold
and resolved Run are both required for moving Running. Stationary/blocked Run
reports ordinary activity. No Stealth practice or gait-local fatigue is added.

Before moving, CHAR grants the actual bound motion owner short actor-write
custody at the exact captured capability revision. New source reconciliation,
vital mutation and acknowledgment wait while performed activity is unsettled;
ordinary accepted vital retries remain retained lookups. The matching activity
request alone may settle under that custody. This prevents a callback or later
source change invalidating already-performed debt. Call `retry_activity()` to
flush a pending boundary before an external actor mutation; a source request
while custody is held returns checked busy and must retry with a fresh actor
revision after settlement. Success releases custody when all queued work settles.
Failure retains the original request/proof and acquires MOVE's scoped
simulation/input/save hold. `retry_activity()` submits the same request without
moving again, even under a subsequent independent hold. It releases only MOVE's
own hold after success. Actor retirement clears custody; retired producer debt
is retained separately for diagnostics and cannot enter a replacement scope.
At a collision/context boundary the just-performed new segment may already exist
when the preceding segment commits. At most two segments are pending. The new
segment receives its first CHAR admission revision after the preceding receipt;
its original physical capability revisions remain in MOVE's captured provenance
and TIME's original proof. No request changes after its first intake attempt.
CHAR renews the same owner's custody without a writable gap between segments.
TIME attests retained clocks/motion/source facts independently of that first
admission revision. Traits retain captured revision facts. This is runtime
coordination, not native SAVE or durable-ID qualification.

CHAR's narrow `preview_ground_activity` uses its selected rate hook, captured
traits, current pool and retained numerator remainder without writing a receipt,
pool, practice, clock or RNG state. It forces settlement on the physics step
whose accumulated performed debt reaches exhaustion, preserving per-step stopping
while allowing ordinary compatible intervals to batch. This supports ordinary
flat ground only; no Swimming preview or substitute clock owner is introduced.

The accepted CHAR ceiling remains 4096 distinct settled intervals. A sustained
5,000-step / 83⅓-second check uses 84 new intervals including its partial flush,
so the former one-receipt-per-frame / 68-second limit is removed. Rapid genuine
context changes still require separate records. At retention exhaustion the motor
stops before new travel; it never evicts receipts or resets CHAR. A production
TIME/SAVE checkpoint policy remains a named real-owner integration, rather than
an unlimited-history claim.

## Qualification and human review

Maintained commands are `verify_headless.ps1` / `verify_rendered.ps1` with
`-Suite ground-movement -Fixture ground-movement-v1 -ClassicSource <ARENA2>`.
`ground_inventory.json` declares exact inventories including the fresh-process
preference check. `verify_startup_export.ps1 -GroundMovement` runs the same cases
in Windows exports; debug/release and headless/rendered remain independent.
`verify_ground_matrix.ps1` serializes the focused matrix and records raw reports.

The controlled course is 80×80 m with floor top Y=0, a 0.2 m thick north wall
centred Z=-20 m, height 4 m, and white 2 m spacing marks. Independent expected
Speed=50/Running=10 values: Walk 175/39.5 m/s; Run 280/39.5 m/s; Sneak 86.5/39.5
m/s. Travel tolerance is 0.0001 m (analog cases 0.00001 m). Capsule wall clearance
is independently checked near centre Z=-19.6 m. Multiple step durations, diagonal,
analog, facing, actual collisions, CHAR practice/fatigue/depletion, custody/retry,
source stacking and production preference application/persistence are asserted.
The fixture does not redefine approved formulas or certify the original executable.

Run `tools/review_ground.ps1` for a fresh verified interactive review build. It
uses the same stock input/view/body/CHAR/Controls, marks its full build active,
and reports no automatic human PASS. Close the engine before cleanup; the marker's
expiry is completion of that review. Physical-controller/changed-host IME checks
remain user-deferred to later M2. Full story entry, real TIME/traits/restriction/
ITEM/MAGIC/NPC combinations, native SAVE, later increments, parent IMP-012 and M2
remain named integrations/acceptance gates.
# IMP-014 calendar integration boundary

The stock handler now accounts the [native calendar](../time/README.md) once
through CORE before MOVE. The accepted controlled MOVE/CHAR microsecond proof
provider remains unchanged and never advances native calendar time. Maintained
ground checks also select published `calendar-rate-3`, preserving measured Walk
speed and physical pose while qualifying independent native calendar accounting.
This does not close the real TIME/CHAR scheduler/activity joint gate.

# IMP-014 increment 2 qualification boundary

The [native TIME scheduler](../time/SCHEDULER.md) does not replace accepted MOVE/
CHAR controlled interval proofs. Stock pending/final continuation frames stop
before physical work; scheduler profiles declaring real MOVE activity reject
activation until native partial-interval reconciliation is qualified. No MOVE,
AV or cadence rate change is introduced. Native SAVE and real-owner gates remain.
