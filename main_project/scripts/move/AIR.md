# IMP-012 increment 3 — air and landings

This extends the existing SessionShell ground coordinator and placement capsule.
There is one physical authority. `air_history.gd` holds plain MOVE state and never
moves a body, runs an independent controller, or writes CHAR. Increment 2 remains
accepted; supported stairs, ordinary slope limits and the exact 25 DATA-owned
connector grants retain their existing solver and provenance.

## Definitions, scale and RULE

`move.air:policy/player`, adapter `air-motion-v1`, uses ordinary shipped → MOD →
captured loose publication and application content locking. It is resolved once
at coordinator binding, without per-frame catalog preparation. `air.json` records
approved formula provenance and the project-selected trajectory tuning. No new
library or native adapter is introduced.

The frame is `dungeon-geometry-metres-v1`. One reference movement-distance unit
is one engine metre by default; eligible duration is simulated seconds. Classic
geometry's separate conversion remains 0.025 m per classic source unit. Multiply
reference impulse, gravity, terminal speed, steering and explicit boost by
`metres_per_reference_unit`. Divide actual world foot-height drop by that scale.
This is an explicit project baseline, not original-executable trajectory proof.

Baseline jump is `4.5*(1+J/200+A+I+E)*C`: A=.1 for Athleticism, I=.1 only with
both Athleticism and Improved Athleticism, E=.6 for enhanced jumping, and C=.8
for actual crouch (otherwise 1). Gravity is 20 reference units/s². The physical
impulse cap is 20 m/s and downward cap 40 m/s at baseline scale. Enhanced steering
accelerates at 12 m/s² toward an input-proportional target bounded by 8 m/s.
`boost_speed=0` omits vanilla forward boost; a nonzero published value adds that
bounded actual-facing contribution exactly once at takeoff. No held-repeat hook
or arbitrary callback stack exists. `inherit_platform` and
`slow_fall_blocks_jump` are published strict booleans.

Raw numeric policy values must be finite numbers, never booleans. The validator
declares finite per-field bounds; mapped impulse/downward/steering/boost speeds
cannot exceed 100 m/s and mapped steering acceleration/gravity cannot exceed
1,000 m/s². Extended live Jumping is a strict integer 0..1e9. Valid high results
are capped; malformed inputs/results fail rather than being repaired by a cap.

The existing RULE registry declares two `air-formula-v1` Dictionary→float hooks:

* `move.jump-impulse`: exact `{profile,jumping,athleticism,improved_athleticism,
  enhanced,crouched}`; finite positive output ≤1e22 before MOVE's physical cap.
* `move.landing-damage`: exact `{profile,distance}` with finite reference distance
  0..1e6; integral float output 0..1e9. Baseline truncates
  `max(0,damage_per_unit*(distance-safe_distance))`.

MOD provider selection, provenance, pure callback signatures, scoped owner
admission, content locking and no-fallback failure behavior use the existing
registry. Unsupported relative-impact/provider inputs are not fabricated; real
moving-support impact hooks retain their later provider qualification gate.

## Input, takeoff and mandatory ordering

The existing resolved input path delivers Jump to the coordinator. One scoped
logical `started` edge is retained to its next eligible physical delivery.
Invalidation discards it. That delivery consumes the edge whether accepted or
rejected: no coyote time, held repeat, airborne second jump or landing buffer.
Actual support, Foot transport, posture clearance, CHAR eligibility and live
restriction/effect facts govern takeoff. Slow Fall blocks ordinary jumping by
default. Required missing/malformed facts stop unsafe progression.

CHAR's narrow capability projection now includes live Jumping. `quote_jump`
uses CHAR's selected activity-rate policy without mutating resources/practice.
It preserves approved saturating jump drain; positive fatigue below the full
cost is not silently changed to an all-or-nothing payment policy.

All physical/clock/owner preflight precedes takeoff. The existing actor-write
custody protects commitment. `commit_takeoff` commits actual foot-preserving
shape, airborne identity and latched velocity at zero elapsed time, retaining its
input event sequence against duplicate/changed requests. Skill, traits, effects,
actual posture, gait and resolved impulse are captured once. The coordinator
stages a coherent physical/activity result before notifying CHAR observers.

TIME retains the zero-duration event at its current activity cursor through
`capture_ground_event`. The real checked `activity_intake` then charges/awards
the jump once. Only after that receipt settles may the current eligible flight
duration advance. A failed required proof/intake retains the same request and
physical takeoff under recovery; `retry_activity` neither moves nor launches it
again. A jump that saturates the last fatigue unit retains its impulse and +1
practice, advances no post-exhaustion flight time, and stays under CHAR's known
exhaustion hold. This does not deliver that course's real recovery integration.

Ordinary timed activity still captures its performed TIME proof and retains
batched custody under the accepted ground contract. Flight is passive travel,
not moving Running practice. Required landing work settles that activity before
health intake. Receipt/revision exhaustion stops explicitly; no eviction or
counter reset is introduced.

## Motion, contacts and history

Normal flight retains measured horizontal takeoff velocity. Looking, requested
gait, posture and changed ground-speed sources cannot replace it. The takeoff
gait remains latched for flight; the next grounded movement step uses current
requests. Air resize preserves feet and velocity/history with full clearance.

Enhanced steering integrates bounded acceleration over collision substeps,
not instant velocity replacement. Loss of the effect or voluntary restriction
stops further steering, preserving passive momentum and gravity. Already-fast
inherited horizontal velocity above the voluntary limit is retained without
steering amplification or forced deletion. Steering can resume if actual
collision constraints put it within the bound.

Gravity uses swept substeps of at most 1/240 simulated second, split at the apex,
terminal-speed transition and steering-target arrival. Vertical displacement uses
the average endpoint velocity. Full-capsule test/cast queries and qualified clear
prefixes preserve the same query margin before committing pose. Ceiling contact
cancels positive vertical speed; it never reverses ascent into a downward kick.
Actual downward support contacts require the existing full support classification
before landing. A step is still supported surface motion. A real ledge departure
retains its last performed fragment velocity and enters flight; it does not use
a support grace timer or the former unimplemented-air hold.

The unresolved segment tracks maximum actual foot/base height, including apex.
`peak` is in compensated world height: local base Y + retained `origin_y`.
Camera motion, resize, pause and terminal speed cannot erase it. At landing,
`d=max(0,(peak-local_base_y-origin_y)/scale)`. Baseline health damage is
`trunc(max(0,5*(d-5)))`; hard-feedback eligibility is independently `d>2.5`.
Exact 2.5 and 5 thresholds, fractional truncation and zero damage are distinct.
No armor/attribute/skill mitigation or extra landing debuff is added.

Each actual landing retains one distance/protection outcome before required
delivery. A scoped landing hold protects simulation/input/save while the producer
settles timed activity and CHAR health. `move-landings` is an explicit CORE-bound
MOVE consumer limited to health `damage`; CHAR remains the only vital/death owner.
`retry_landing` retains the original request through rejection, lethal prevention
directory failure and acknowledgment failure. Accepted CHAR receipt lookup makes
technical retry idempotent. Final lethal outcomes use the existing CHAR resolver
and actual CORE death boundary; unavailable prevention sources never mean immunity.

Retained outcomes carry session, actor and content identity. Every required TIME/
CHAR delivery rechecks the originating scope before further producer mutation or
notification. Synchronous retirement after a health commit leaves its original
landing request in retired diagnostics and cannot emit an expired movement/failure
notification into a replacement session. Public jump retry remains nonreentrant
even when there is no periodic segment pending.

Only after health settlement is the outcome recorded as committed and emitted
through optional `landed`. Absent/failed feedback cannot undo health or authorize
replay. Broader AV cue integration remains increment 4. Outcomes retain an explicit
4,096 boundary; long-session retirement remains an obligation, not solved here.

## Narrow provider interfaces

Providers must be current CORE-bound MOVE motion services and implement strict
`air_transition_current(detached_request)->bool`. These are controlled interface
qualifications until real specialist/platform/WORLD adapters deliver their facts.

`platform_velocity` accepts exactly `{session,source,support,revision,
placement_serial,linear,angular,point,center}`. Finite vectors use metres, m/s and
rad/s; point motion is `linear + angular.cross(point-center)`, bounded to 1,000
m/s. It must identify the actual current supported feet within the declared
contact tolerance. Revisions cannot regress/change under the same active sample.
A registered support requires a fresh sample for each eligible supported step.
Jump/walk-off captures it once and immediately detaches. Current ground velocity
contains voluntary surface motion, not platform carriage, so the contribution is
not added twice. Integrating future carriage requires a separately measured
voluntary/passive projection and the named MOVE-008 joint check; this increment
does not implement or certify carriage, platform rotation of facing, or crushing.

`protection_transition` accepts exactly `{session,source,revision,kind,active,
success,evidence,placement_serial}` for climb/rappel/levitation/water history.
Only successful actual control/entry protects. Sources retain independent active
reasons and revision tombstones; release removes only that source. Removing the
last reason starts a fresh segment at actual feet. Up to 64 external sources plus
the reserved internal Slow Fall reason are bounded; that reserved key cannot
collide with a legal provider ID. Required vanished providers stop progression.
This interface certifies fall-history transfer, not a delivered specialist motor.

Water evidence is exactly `{entered,solid_first,surface_only,sufficient_depth,
volume}` with strict booleans/stable volume ID. Actual entry and no earlier solid
are mandatory; sufficiently deep water or the approved surface-only exterior
representation may receive the player. Floors/boats/obstructions win. Failed
requests, shallow obstructed water and water merely below a floor do not protect.
The provider owns geometric entry/depth/solid-order evidence; controlled evidence
does not establish real WORLD/MOVE-014 integration.

The existing checked trait supplier can project `air_traits(context)` as exactly
`{ok,revision,enhanced,slow_fall,slow_fall_speed}`. Its revision must match ground
traits and cannot change same-revision facts. Slow Fall supplies a finite positive
descent bound; active protection cancels prior debt, and expiry starts a fresh
segment at actual position. No MAGIC effect implementation is added.

## Pause, placement, origin and restore

CORE suspension/zero intended rate advance no motion, view transition or elapsed
activity, and add no catch-up. Restrictions are separate from suspension.
Same-session doorway placement rejects unresolved airborne/landing state instead
of clearing it. Advanced teleport/native restore transfer remains its owner gate.
The delivered CORE placement operations initialize replacement sessions; they do
not implement live same-session location transit. That future join must preserve
segment/outcome identity and transfer retained history before enabling placement,
rather than replaying initialization's fresh-session reset.

`origin_shift` accepts a current bound provider's `{session,source,revision,
placement_serial,delta}` only while simulation is gated. Geometry must already
have coherently rebased and the new full capsule must be clear. The physical owner
shifts local pose and subtracts delta Y from `origin_y`, retaining absolute peak,
velocity and outcomes. The serial changes and stale support samples expire.
The maintained fixture shifts real geometry/body ±100 m under this interface;
real WORLD residency/rebase composition remains open.

`capture_air_state` / `restore_air_state` implement a settled, gated **in-memory
owner checkpoint**, not native SAVE or arbitrary reconstruction. They retain
velocity, takeoff, unresolved peak/protections and committed outcomes. Current
scope/content, CHAR revision, sequence, serial, physical pose/posture and exact
owner checkpoint must still match; altered debt or newer consequences cannot be
rewound. Load-style input/gait reset cannot rewrite latched flight. Pending required
work rejects capture. Native serialization, cross-session reconstruction and SAVE
commit/load interruption tests remain explicitly open (`native_save_ready=false`).

## Qualification

Air slides retain at most four witnessed contact planes per swept substep. A
projection that would enter an earlier plane is restricted to their shared crease;
further planes must admit that projection. This preserves free vertical descent
at a passage pinch without successive wall projections reintroducing blocked
horizontal momentum. Dot/cross tolerances are numerical. No contact plane survives
the substep. The 0.58 m passage regression retains full capsule dimensions/margins
and verifies repeated blocked jumps, landing and walking away at 30/60/120 Hz and
both published downward-cap profiles; no support timer or unwitnessed normal is used.

Maintained air, consequence and exhaustion cases are included in DEV-014
`ground-movement` / `ground-movement-v1`, including Windows export selections.
Use `-InputSequence air-cap-2` for an independently published 2 m/s downward cap;
the same distance/damage assertions must hold. Source/ordinary stair and connector
checks remain in the full selection. Focused custom development fixtures are not
counted as final maintained selection passes. See the increment-3 execution and
human review evidence for exact final commands/counts and unavailable integrations.
