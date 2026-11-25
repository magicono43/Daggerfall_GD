**Acceptance update, 2026-11-25:** The user approved the improved angled/wall-adjacent stair behavior and explicitly accepted increment 2. See [acceptance](../../../design_docs/development/evidence/IMP-012-INCREMENT-2-ACCEPTANCE-2026-11-25.md). Earlier pending wording below records the preceding checkpoint; later integrations remain open.

# IMP-012 increment 2 — posture and surfaces

This extends the existing GROUND/PLACEMENT authority. Earlier increment-1
standing/flat-only boundary descriptions are historical. There is still one
SessionShell, CORE, resolved input/view owner, MOVE capsule and CHAR activity
owner. Entry, LOC ticket/readiness, TIME, traits and restrictions remain controlled
in the course. No air, platform, native SAVE or story-entry readiness is implied.

## Input and ordered commitment

The stock Controls `crouch_mode` OptionButton uses the same staged Apply,
consumer validation, failed-save and Retry Save path as Run/Sneak. Left Ctrl /
Toggle remains the default. Continuous Hold Crouch uses the input owner's
eligible retained physical history; GUI-refused presses have no admitted action.
Multiple contributors create one logical start. Gait consumes each scoped sequence
once, independently of physics delivery, and preserves Crouch across ordinary
menus/focus invalidation while cancelling Autorun. Crouch grants no stealth or
practice, and is independent of Run/Sneak preferences.

`prepare_ground_posture(owner, session, desired, tuning)` is detached and read-only.
It requires current LOC readiness, validates the complete current capsule against
all solid layers (excluding only this actor), and checks the complete intended
capsule at its foot-preserving centre. Shrinking cannot conceal an initial overlap.
Expansion failure retains actual crouch and a desired standing/pending request.
Fresh crouch intent cancels that request; every eligible step retries clearance.
Because both upright capsules share radius/base, the target capsule contains the
entire expansion route. No thin centre ray certifies volume clearance.

The coordinator selects the approved checked RULE speed using the proposed actual
posture. All external traits, restrictions, formula, source and TIME callbacks,
clock/schema checks, current capability checks and CHAR custody reservation precede
irreversible shape/travel commitment. The physical request includes the exact
posture proposal; MOVE repeats it and rejects changed geometry/pose/intent before
commitment. Actual shape/posture, base, physical velocity, pose and retained activity
are coherent before observers. Duplicate requests return the retained result;
changed, stale, reentrant, suspended and retired requests reject. No actor ledger
is copied and no fatigue is calculated in MOVE.

The approved crouched Walk baseline is `(Speed+crouch_add)/divisor`; Run multiplies
that baseline by its own Running factor; Sneak divides that unmodified Walk
baseline and subtracts its own term. Each gait's source factors apply once through
the existing revision/lifetime checked source interface. Standing formulas remain
unchanged. Actual posture supplies speed immediately, independently of camera
animation. Invalid/nonfinite/nonpositive raw definitions and RULE results reject.

## Coordinates and replaceable tuning

All distances are engine metres under `dungeon-geometry-metres-v1`; durations are
eligible simulated seconds and angles are degrees from world up. Standing radius
0.30 m / height 1.80 m remain placement-owned. `move.ground:policy/player` now
requires `crouch_add` and the complete `surface` dictionary through the same
shipped → MOD → captured loose pipeline, provenance, publication and content lock.
Whole-record replacements must supply the complete extended schema. There is no
parallel tuning/formula registry or file read during a movement point query.

| Field | Baseline | Valid envelope |
| --- | ---: | --- |
| crouch_add | 50 | >0..1,000,000, also positive Sneak over the supported stat domain |
| crouch_height | 0.90 m | 0.2..2; at least capsule diameter and below standing height |
| standing_eye / crouched_eye | 1.60 / 0.75 m above capsule base | 0.1..3 / 0.1..2; eye plus clearance sphere must fit the posture and sphere radius must be smaller than body radius |
| posture_seconds / stair_seconds | 0.18 / 0.12 s | 0.01..1 each |
| walk_degrees / support_degrees | 45 / 80 | 0..70 / 1..85, support >= walk |
| step_up / step_down | 0.50 / 0.50 m | 0.001..0.5 independently |
| contact_gap | 0.010 m | 0.002..0.02, greater than motion margin |
| motion_margin | 0.001 m | 0.001..0.02 |
| probe_stride | 0.050 m | 0.005..0.1; runtime also caps at radius/4 |
| camera_radius | 0.100 m | 0.03..0.15 |

Posture dimensions, timings and slope values are project-authored engineering
tuning, not original-executable measurements. The user selected DFU's 0.50 m
step-up example on 2026-11-25; matching downward ground following is an explicit
project interpretation, not a separate DFU setting. Half-height crouch
fits a useful 1.2 m passage while retaining the existing radius; eye offsets leave
room for the enclosing near-plane sphere. Baseline gait provenance remains the
approved MOVE-005 / DFU MIT-derived formula with its retained license. No library,
toolchain, source asset, reference material or external classic data is modified.

## Physical support, surfaces and steps

The real capsule sweep establishes collision/support. Measured centre/footprint
rays disambiguate floor/wall seams and require a capsule-radius support footprint,
rather than an isolated rim or distant floor. Ray observations do not establish
body clearance. Capsule-cap geometry is included in inclined-plane support
distance. Support's 80-degree criterion is distinct from 45-degree uphill
walkability. Genuine steep support remains stationary without automatic sliding;
uphill components are removed before normalization, including diagonal attempts.
There is no downhill propulsion, material penalty or enabled slide mechanic.

Voluntary intent is projected onto measured support and normalized to a bounded
surface-distance budget. Ordered fragments are at most 0.05 m by default. Wall
contact travel is backed off along its original route to preserve the volume-query
margin; it cannot add an unrelated displacement axis. Subsequent wall-slide
fragments independently qualify support. The body's collision mask and shape
queries cover all solid layers. No horizontal-plus-free-vertical incline speed is
introduced. `surface_distance` excludes explicit stair/contact height correction;
`stair_correction` reports that physical vertical correction separately. Full
physical displacement/velocity still reflects the actual committed pose.

The owner commits the qualified across/follow fragments after their full shape
sweeps, rather than replacing that route with a diagonal collision response.
Parallel tread normals may belong to different heights; real capsule clearance
governs bounded support distance. The terrain support-angle limit is checked by
floor rays. A nearly horizontal rounded-cap contact at a stair edge additionally
requires a lower-hemisphere point within the margin tolerance and an upward tread
witness at that edge; a wall-side contact alone grants no support. If a proposed
descent crosses a preceding lip, at most twelve bisections find a clear prefix,
which must independently regain nearby support before any commitment. Larger
drops keep their existing handoff; no air owner or forced slide is introduced.

For angled steps, the top ray looks across the measured obstacle normal while
the full swept across route retains the intended direction. Enclosing walls are
observed above the maximum legal riser, and constraints project original input
with at most four redirects; repeated rounded normals cannot reverse the input.
A reachable blocked approach prefix is retained before resolving a pure wall.

If an outer footprint ray lands in a tread/wall seam, a vertical wall witness
must oppose that direction within the capsule radius plus at most a quarter
radius (or contact-gap/margin tolerance). A real floor is then sampled half a
radius inside the wall. Full capsule clearance/contact, centre support, the other
footprints and floor-span limits still apply. Open edges have no wall witness and
receive no fallback. This is not a smaller collider or a support grace timer.

Step-up requires a measured obstacle top within the configured bound, full-capsule
up/across/down route clearance and a valid destination. The obstacle-top check
prevents a tall obstacle becoming repeated fresh small steps through rounded-cap
contacts. Raised staging probes are distinct from actual grounded support; their
bounded downward route cannot establish an arbitrary floor catch. Downward
following checks the measured support-level change against its separate bound,
as well as full-shape route/destination clearance. It cannot gradually reinterpret
a larger drop as many tiny contacts. Missing support or an excessive drop yields
a checked increment-3 boundary with the unsupported remainder. Already-performed
travel/activity remains retained and retry never moves it again. No jump,
landing, new practice event, gravity, fall-history reset or fall damage is invented.

## View origin and lifecycle

After physical commitment, the existing camera receives a legitimate eye-origin
change. Linear eligible-time posture interpolation and bounded exponential stair-offset
convergence (the stair duration is a time constant) are separate from facing and later AV bob. Continuous slope height is
followed directly; only stair/contact correction creates a stair offset. Both
directions are bounded by the configured step distances. An enclosing sphere is
swept from the validated actual eye to the visual proposal. Unsafe interpolation snaps to the actual eye. Open-room crouching may keep its
visual eye above the shortened capsule while that full sphere route remains clear. The camera's actual
near-plane corner radius must fit the configured clearance envelope before any
physical commitment; unsupported projection changes fail checked. Aim tickets now
expire when the actual displayed origin/direction changes, as well as on facing,
cursor or input-context changes.

CORE suspension and zero intended rate advance neither physical nor camera
transitions and accumulate no catch-up. Voluntary restrictions remain separate;
they do not masquerade as pause, geometry readiness or support. Doorway placement
resets interpolation independently from ordinary suspension. Retirement clears
scope/request handles, retaining unsettled diagnostic debt under the original
scope. Source changes cannot invalidate the original performed activity proof.

Future native SAVE must retain actual posture, desired posture and consistent
pending stand, physical pose/velocity/fall/support history and versioned dimensions.
After geometry readiness it must validate actual shape and full-volume clearance,
reconcile Hold from current eligible input, clear old presses, and snap the camera
to the restored actual eye. Camera interpolation is not durable authority.
`reset_after_load` remains a gated, settled runtime handoff and explicitly reports
`native_save_ready=false`; this increment implements no native reconstruction.
Air resizing must retain the base, velocity, takeoff gait and fall history with no
boost; real combinations require increment 3. Water, climb, levitation and riding
must supply named shape/compatibility owners. No DFU forced standing is imported.

## Special steep connectors

The user selected an explicit reviewed list and then confirmed the three original
corridor designs should be traversable. The complete 187-block scan identifies
model 61030 plane 1, 67027 plane 6 and 67029 plane 6 in 25 exact source records.
See [source list and diagrams](../../../design_docs/development/evidence/IMP-012-STEEP-RAMP-LIST-2026-11-24.md)
and [implementation/qualification](../../../design_docs/development/evidence/IMP-012-steep-connectors-2026-11-25.md).
Earlier Cyeghtan-only angle candidates are historical investigation evidence.

The existing DATA ground definition has 16 fields, including `connectors`: a
bounded array (0..4096) of nine-field source matches. A row contains `block`,
`record`, `block_sha256`, `model_sha256`, `source_address`, `model`, `floor_plane`,
`position_source` and `rotation_source`. Hashes are 64 hex digits; indices are
finite nonnegative integral values up to uint32; pose arrays contain three finite
signed-32-range integers. Duplicate block/record rows and source pitch/roll are
rejected. The current shipped list has 25 rows. Ordinary DATA/MOD/loose precedence
applies; an empty list removes grants. Gait/RULE keeps its fixed 15-field projection
without this source catalog, prepared once at coordinator bind.

LOC matches unchanged classic block bytes, stable source identity, source record
pose/address and model bytes before binding selected source triangles to a shape.
Replacement geometry and tilted/scaled/inverted placements receive no inherited
grant. Checked world poses use the existing 0.001 m origin tolerance and 1e-6
basis-axis tolerance. Editing the shared collision shape invalidates attached
grants. A narrow current-ticket query verifies physical shape ownership and
source-triangle containment/geometric normal, including when Jolt omits a face
index. It never grants the whole model, dungeon, bounds or nearby wall. The
resolved list is included in LOC's geometry compatibility fingerprint.

MOVE uses actual full-capsule contacts and bounded footprint observations through
these slopes and their rounded-cap lips. Optional last-contact depth hints only
reduce rediscovery work; bounded physical-floor retries handle a missing hint.
Support observations use actual contact/plane normals independently of source
permission, including unlisted 55/69-degree standing/crouched support. They neither
grant uphill permission nor replace a full-shape support sweep.
The floor-span and separate contact-depth bounds still reject distant support.
A short-fragment margin sweep can supply a contact missed by `test_move`. Its
approach and redirected segments share one gait budget. Connector following is
voluntary surface travel; physical distance and CHAR activity stay bounded, with
no free stair lift, collision bypass or automatic posture change.

Real-source coverage includes all 25 bindings/interior capsule routes, all three
designs in both postures and all gaits, ordinary-source negatives, changed inputs,
replacement/pose/shape invalidation and current ticket checks. The neighbouring
0.30 m staircases now use the user-authorized ordinary 0.50 m up/down allowance.
Whole assembled-location reachability, water/actions/actors, real entry providers
and native SAVE retain their separate gates. The changed ordinary stair/return behavior has separate human review:
[playable instructions](../../../design_docs/development/evidence/IMP-012-ORDINARY-STAIRS-REVIEW-2026-11-25.md).

## Qualification course

The same real SessionShell body/CHAR course adds 0.17, 0.50, 0.51 and 0.80 m up-step
cases, 0.17/0.50 m downward following and a 0.51 m checked handoff, low-ceiling deliberate crouch, 0.64/0.58 m
passages, an off-centre overhang, invalid initial overlap, 30/55-degree slopes and
an elevated tangent-plane fixture for stable steep support and support loss.
Expected shape/base and gait vectors are independently declared in the maintained
cases. Ordinary travel tolerance remains 0.0001 m; contact fixture height tolerance
is 0.002 m. A step's partial contact fragment may spend budget against an obstacle;
its horizontal round-trip tolerance is one 0.05 m fragment, never a speed bonus.
Fixed interactive counterparts live in `ground_course.build_surfaces()`.

Run independent DEV-014 ground headless/rendered selections, affected input,
binding, view, placement/CHAR/session/RULE/composition regressions and independent
Windows debug/release headless/rendered exports. The maintained review launcher
waits for the real engine, retains stderr/exit failures and supports an actual-entry
smoke. The three reviewed ramp designs and 25 exact source records passed machine
qualification. The user passed checks 1-5 on all three designs and confirms the
source-block ramp works. The new 0.50 m ordinary stair/return behavior passed
machine qualification and awaits its three human checks; assembled-route checks
remain open.
Full story, real TIME/threat/restriction integrations, native SAVE,
increments 3–4, parent IMP-012 and M2 remain open. Accepted
CHAR collapse/safe-hour recovery exists with controlled suppliers; this course
lacks the real recovery handoffs. Its exhaustion hold is not an ordinary resumable
pause. CHAR's 4096-receipt ceiling remains checked, with no reset/eviction or
assumption that another increment automatically solves long-session retention.
