# Increment-3 locomotion extension

Increment 4 adds ordered mechanism/air collision operations to this same physical
authority, not a second controller. Full-shape crush/posture evidence and safe
cosmetic routes are described in [PLATFORMS_FEEDBACK.md](PLATFORMS_FEEDBACK.md).

The same capsule now owns checked takeoff and swept flight; see [AIR.md](AIR.md).
Same-session doorway requests cannot clear unresolved flight/landing consequences.
Gated coherent-origin shifts retain absolute foot-height debt. Settled in-memory
owner checkpoints are supported; arbitrary/native reconstruction remains unavailable.
Earlier no-air wording below records the doorway-only implementation checkpoint.

# Increment-2 locomotion extension

Ground locomotion resizes this existing capsule through detached preparation and
coordinated revalidation/commitment. Standing dimensions remain placement-owned.
See [POSTURE_SURFACES.md](POSTURE_SURFACES.md). Doorway placement keeps its accepted
standing/reset contract; this does not enable native restoration or special modes.

# MOVE placement — IMP-013 increment 3

IMP-012 increment 1 extends this same body through the checked
[`advance_ground` motor interface](GROUND.md). Placement validation/commit and
camera reset remain separate from locomotion. No competing collider is created.

`session_shell.placement` is the composed `placement_authority.gd` node. It owns
one `CharacterBody3D`, its active capsule, local pose and supported placement
state. LOC retains layouts, stable bindings and staged geometry; CORE retains
the original operation and its separate activation session. This is placement
engineering, not delivered locomotion, WORLD residency, access or SAVE.

`validate(handoff, physical, policy={})` consumes the real LOC marker handoff.
It returns `exact`, `corrected` or `rejected`, echoes marker/frame/handoff identity,
and never moves an actor. The complete handoff must still equal LOC's current
projection. Inspection, stale content/layout/activation and altered anchors fail.
The borrowed `LOC.placement_space(ticket)` selects the isolated preparation space
or the active viewport; MOVE performs the actual Jolt queries there. Queries
include all solid collision layers, including occupants and mechanisms, excluding
only this authority's existing actor.

The supported physical request is explicitly doorway, standing posture/mode,
Foot transport, zero velocity, empty fall history and no effect relationships.
Other requests fail `physical_owner_unavailable`; native reconstruction cannot
replay doorway initialization. Empty effect input does not certify MAGIC or
other owner readiness. No falling/swimming/climbing/platform/levitation/native
restore readiness, origin rebasing or full traversal is inferred.

## Definition and conversion

DATA validates `content/layouts/placement.json`. Layout declarations may replace
the complete `location_assembly.placement_policy` through the existing shipped →
MOD → captured loose pipeline. LOC captures/resolves this small definition once
per preparation and fingerprints it in each handoff. Point queries never reread
the file or copy a catalog. `scripts/data/placement_policy.gd` is the shared
validator; trusted direct policy arguments use the same envelope. No new registry,
session lifetime or startup adapter is added.

The project-authored baseline is a 0.30 m radius, 1.80 m height upright capsule,
0.005 m query margin, 0.08 m support depth, maximum 45 degree support slope and
0.60 m correction bound. The independent classic aperture is 1.25 × 2.25 m;
the 0.025 m correction step corresponds to one classic source unit. These are
replaceable engineering choices, not copied DFU controller offsets or verified
original-executable policy. Validation envelopes permit radius 0.05..1 m, height
up to 3 m, margin 0.001..0.02 m, support depth up to 0.20 m, correction distance
up to 1 m and at most 32 declared offsets. Unsupported door tilt/facing fails.

Source anchors are not actor centres. `door-aperture-clearance` preserves the
marker's inward depth and sole height, fitting only its lateral coordinate into
the bound aperture's span with radius plus twice margin clearance. The adjustment
is bounded and retained in conversion provenance. Exterior authored anchors
instead derive sole height from the minimum Y of their actual door points,
preserving their explicit horizontal outside offset. Half capsule height plus
twice margin gives the requested centre. `sole` policy omits aperture fitting.
Neither conversion changes source records or chooses another marker/room/link.
Tilted doors are unavailable rather than assigned guessed upright geometry.

The converted requested actor pose is tested first: complete capsule intersection,
bound doorway side (entire capsule radius), and full capsule downward sweep with
an independently successful support contact/normal. No-hit is explicit. A ray,
marker or geometry-ready flag cannot qualify placement. The declared baseline
offset order is up 0.025 m, down 0.025 m, inward 0.10 m, inward 0.25 m, inward
0.50 m, after exact. Corrections preserve facing and bound space/door intent.
Every correction requires a clear full-capsule sweep from the requested centre.
Initially overlapping starts fail conservatively, even if an endpoint is clear;
this implementation does not certify penetration-escape routes. Exhaustion is a
checked failure, with each attempted pose/reason retained. No random fallback,
solid disabling, actor shoving or background unbounded retry exists.

## Commitment and gates

`commit(handoff, validated, access)` requires the active original CORE operation,
an activated handoff, a current access response and fresh physical validation.
It rejects changed physical results and rechecks scope after the callback. A
reentrant commit rejects while the outer commit is pending. The successful
receipt is retained before `pose_committed`; duplicate calls cannot move twice.
MOVE publishes shape, position, facing, physical state and original door/return
intent coherently. The shell uses the existing view owner's `place_facing`,
clears pending look input and resets camera physics interpolation. Doorway-only
zero transient velocity cannot clear another mode's fall or native history.

CORE's existing operation hold now includes `save` alongside simulation/input.
Validation under an original operation registers its exact LOC ticket through
`CORE.require_placement`. CORE's checked completion revalidates that ticket's
committed MOVE shape/pose against current geometry before accepting readiness.
An unresolved or stale required placement leaves initialization gated. MOVE
never completes CORE readiness or releases its holds. Missing real access,
WORLD, CHAR, MAGIC, gameplay reactions and other required providers still prevent
stock entry. The stock session provider remains unavailable; fixture lifecycle
and access providers are labelled controlled. Physical commitment does not imply
destination readiness, WORLD arrival, native SAVE or IMP-013/M2 acceptance.

Before activation, failure/cancellation discards prepared geometry and leaves the
valid source pose/context. Activation can retire the source; later failure uses
CORE cleanup/recovery, without promising source rollback. Retired callbacks cannot
publish a pose into a replacement session. No clock advance, fatigue, effect debt,
entry rewards or gameplay reaction is produced by probes or pose commitment.
