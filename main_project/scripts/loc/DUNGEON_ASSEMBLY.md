# Dungeon assembly — IMP-061 increment 1

`dungeon-assembly-v1` is the LOC geometry/structural owner. It is composed by the
ordinary session shell with the application's existing DATA layout, media and
definition providers and CORE lifecycle. It does not replace the stock unavailable
gameplay session provider. No actor, SAVE restore, action executor, population,
water, palette selection, arrival marker selection or entry outcome is fabricated.

## Requests, publication and lifetime

`begin` requires `id`, `requester`, `preparation`, `session`, `core_ticket`,
`content_ticket` and `layout`. Optional `presentation`/`variants` retain their
context contracts; optional `arrival={route,kind,doorway}` binds the original
arrival intent under the [marker contract](DUNGEON_MARKERS.md). Omission is
inspection/reconstruction, never authorization to place an actor.
`layout` is a published `layout.inputs` reference.
The content ticket is obtained through DATA's constant-cost `content_ticket()`;
an unpublished candidate cannot prepare a dungeon. `session` and `core_ticket`
are checked by CORE, not supplied by an independent LOC session registry.

For an existing session, `core_ticket={}` requires the actual live session.
For preflight/initialization, retain the original CORE operation ticket, including
its admission scope. CORE validates its operation ID, generation and original or
current scope. This LOC-specific preparation check does not relax the exact
phase tickets required by CORE's `complete_*` callbacks.

`step(original_ticket)` builds one complete placed block in an isolated
SubViewport/World3D. `finish(original_ticket)` checks all blocks, structural
references, door relationships, continuous floor coverage and actual Jolt queries.
It waits independently for physics registration and rechecks freshness afterward.
No staging nodes, cached decoded resources or usable partial projection escape.
Wrong tickets do not cancel another request. Explicit cancellation, invalidated
content/source/session and late required failures release staged resources.

A checked live-session assembly replaces its previous geometry coherently. CORE
preflight geometry remains in its isolated world, preserving the outgoing scene.
It survives retirement of the outgoing session **only while CORE still owns the
same operation**. `activate(original_ticket)` is available only in that operation's
destination initialization phase. It records the new activation session separately
from the original request identity. Cancellation/terminal failure drops unactivated
preparation; session retirement disposes its activated geometry. `dispose` releases
all remaining nodes and preparation data.

Success is retained by requester/request identity without reconstructing instances.
Reusing an ID with changed input rejects. A superseded success returns a compact
retained outcome with no current geometry readiness. Receipts retain no scene
objects. Layout, content, block revision, placed occurrence, scoped record and
transient live instance identities remain separate. State slots are scoped
structural reservations with `owner_state_ready=false`, not action/SAVE state.

`readiness(ticket)` is a small detached projection; `binding(ticket,placement,id)`
copies only the selected binding. `projection(ticket)` is the explicit full
inspection projection. `geometry_ray` checks the same ticket and returns detached
geometry/record results, not RIDs or mutable nodes. It also works against isolated
prepared geometry. None reports full destination readiness, owner-state readiness,
placement commitment or SAVE compatibility. Future MOVE/CORE must require their
real providers before entry; assembly success cannot release that gate.

## One geometry conversion

Implementation: DATA's `layout_geometry_frame.gd`, exposed by
`layout_inputs.convert`. Named engine frame: **`dungeon-geometry-metres-v1`**.
Godot's right-handed frame uses +X right, +Y up, and -Z for classic +Z.

* A classic layout unit is **0.025 metre**. A block grid side is 2,048 source
  units / 51.2 m. ARCH3D signed point components have 1/256 source-unit granularity.
* Let `F=diag(1,-1,-1)`. Points use `0.025 F p`; model points additionally divide
  by 256. Normals use normalized `F n`. No Unity vector is passed to Godot.
* Classic encoded angles have 2,048 units per revolution. Source pose composition
  is `F Rz(z) Rx(x) Ry(-y) F^-1`, followed by converted translation. Placement
  composes before record pose. Integer angles reduce modulo 2,048 before float
  conversion. The yaw sign is independently checked against source door offsets
  and DFU's `RDBLayout.GetModelMatrix`, including its Y-reflected model convention.
* Native poses explicitly name this frame, `position_unit=metre`,
  `rotation_unit=radian`, finite position/rotation triples and unit scale. Native
  engine rotations compose `Rz Rx Ry`; no import-axis conversion applies.
* Source triangles retain their decoded polygon topology; reverse the last two
  indices for Godot clockwise front faces. `F` has positive determinant. Normals,
  render vertices, collision triangles, block transforms and connection probes use
  this same boundary. Static GLB exports already converted by the accepted media
  codec are not converted a second time.
* Local geometry/query extent is bounded to ±8,192 m per component. The pinned
  seam/position tolerance is **0.001 m**. Normal comparison tolerance is **0.0001**
  after ArrayMesh packing. The observed packed axis-normal error is about
  `1.5259e-5`; exact int/source-to-same-source conversion still has tolerance zero.
  These are geometry qualification parameters, not actor/motor dimensions or
  WORLD rebase thresholds.

Authored placements can retain `placement_mode=free` or `snapped`. Snapped poses
also declare `snap={position_step,rotation_step}` in their transform units. Both
steps must be positive and finite; off-grid declarations reject rather than being
rounded. Free poses cannot carry snap settings. Legacy four-field placements keep
their exact pose. Classic grid records remain original signed X/Z placements.

Classic geometry uses neutral independent inspection materials in this increment;
it does not select LOC-010 palettes. Actual GLB resources use the existing AV
instance factory and its independent mutable material/texture ownership. Geometry
is not silently replaced by an empty success when a model is unsupported.

## Supported connection declarations

Published layout `data.assembly` is a complete
`dungeon-assembly-declarations-v1` dictionary with `connections`,
`door_relationships`, and `required_bindings`. There is no second content registry.
Existing checked add/replace/whole-data patch and loose precedence apply.

Each connection declares `id`, `kind` (`passage` or `stairs`), `a`, `b`,
`clearance`, `support_depth` and `conditions`. An endpoint contains `placement`,
`normal` and an ordered local `path` of at least two points, interior first and
seam last. Endpoints meet within 1 mm and transformed normals oppose with dot
product ≤ -0.9999. Concatenate the paths through that checked seam.

The default frame is `classic-block-local-v1`: paths, clearance and depth use
source units and integer components. An explicit connection
`frame=dungeon-geometry-metres-v1` instead uses finite local metre triples,
engine-axis normals and metre clearance/depth. Supported depth is positive and
at most one source block side (51.2 m); it is authored geometry support depth,
not an allowed actor fall/step. Clearance is an axis-aligned geometric box, not
an actor capsule or motor/gait/posture selection.

Required support is checked continuously along every path segment by clipping
against actual upward-facing transformed triangles and unioning supported
parameter intervals within the declared depth. A private 16 m spatial index is
built once during preparation; very large faces use a non-expanding wide-face
list. A missing interval larger than the numerical seam tolerance fails. Door
geometry never supplies floor support.

Independently, actual Jolt box overlap/sweep queries check clearance and actual
ray queries check support. Physics probes are at most 0.1 m apart or half the
smaller horizontal envelope dimension, whichever is less. A ray exactly on a
shared triangle edge may use only the pinned 1 mm horizontal numerical tolerance;
the continuous coverage test still checks the entire segment. More than 4,096
support probes is an explicit unsupported-profile failure. AABBs and origin
distances do not certify connections.

`conditions` names retained scoped DOR/DDR/NEW/CAV door records. Their collision
is excluded **only for conditional connection validation**, representing that
declared door-open condition. Live doors remain present and closed; no opening,
locking or action outcome executes. Other required mechanism conditions reject
explicitly in v1. Full destination readiness stays false until real gameplay
owners establish the required condition/state and MOVE validates placement.

## Doors and required bindings

All source doors are retained by default. Overlapping candidate door bounds
require an explicit relationship; conservative unresolved candidates fail closed.
`intentional-pair` names `a` and `b` and preserves both instances/colliders.
`duplicate` additionally names `retained`; chained/conflicting relations reject.
No origin-distance, enumeration-order or DFU 1.4-unit suppression rule is adopted.

Suppression hides/disables only the named redundant live door. Its stable binding
and explicit retained relationship remain visible. A required incoming action,
an action-bearing suppressed door, or required QUEST/SAVE reference cannot be
silently retargeted: it reports `provider_pending`. Explicit structural bindings
use `owner=LOC-structure` and must resolve to retained records. Other required
owner bindings/state remain pending; this increment provides no migration or
fabricated restoration. Missing scoped records fail.

## Source scope, provenance and reuse

The shipped, hash-pinned `content/layouts/dungeon_assembly.json` annotates only
**`place-00032`, Ruins of Cyeghtan Manor** in the observed source edition.
It declares eight original placements, fourteen lower/upper required connections
across seven central/border adjacencies, and deliberate non-joining of undeclared
border-to-border adjacency. `tests/dungeon_source_observation.json` records every
block/record ID, source placement, payload hash, expected transformed model bounds,
first-plane vectors/normals and an unsupported-axis counterexample. Its observer
reads source bytes independently of the runtime importer/converter.

Annotations check the accepted MAPS/BLOCKS profile and model source hash before
being attached to the shipped layout. A different ARCH3D edition leaves this
annotation unavailable; it is not guessed onto another model set. The baseline
cache rechecks this guard before reuse. Mods can explicitly replace complete
assembly declarations through normal publication; source receipts/addresses stay
protected. Every selected block/resource is still validated in the effective
layout, so an incompatible replacement cannot inherit false readiness.

Other classic layouts without qualified connection declarations fail assembly
explicitly. The initial candidate `place-00016` was rejected during qualification:
its proposed seam crossed solid model 58051. That failed observation remains
evidence; no alternate location is substituted at request time.

LOC reuses decoded blocks and model resources only inside the exact preparation,
with current DATA/CORE/source identity checks. It does not decode BSA/RDB/ARCH3D
bytes. Model payload SHA-256 now accompanies DATA's decoded model provenance;
layout versions include effective block and resource hashes and the frame profile.
Immutable render-mesh/collision-shape prototypes are built once per effective
model in that preparation. Placed materials and shape-owner transforms remain
independent. Fixed geometry shares one compound static body per placed block;
doors, action-bearing records and action targets keep separate bodies. Physics
hits resolve through the hit shape owner to the original scoped record. Capacity
is checked against the lower of boot/current Jolt body limits before attachment;
the owner does not raise engine limits. The caller can advance one staged block
per frame so rendering can flush allocations and cancellation remains observable.
No point query decodes resources or rebuilds the support graph. Transient instance
and material IDs in inspection projections are diagnostics, never durable IDs.

## Remaining real integrations

Increment 2 adds LOC-010/012 palette/story, water and special-area preparation;
see [DUNGEON_CONTEXT.md](DUNGEON_CONTEXT.md) for its bounded spatial contract.
Increment 3 adds [LOC-011 marker/return handoff](DUNGEON_MARKERS.md). Actual placement and
entry require IMP-013/MOVE; exterior return IMP-025; swimming IMP-040; edited
variant qualification IMP-055. Native SAVE, QUEST/action restoration and other
required gameplay providers must pass their named joint checks. Controlled CORE
fixtures qualify cancellation/activation seams only. They close none of these
gates and do not complete IMP-061 or M2.

## IMP-013 shared owner extension

The normal shell instantiates `location_assembly.gd`, a specialization of this
owner. Source-selection/pose/metadata hooks reuse this same staging, atomic
publication, CORE operation, retirement and activation implementation. Requests
without `area` preserve the dungeon interface and its environment/marker consumers.
The additive activation version distinguishes committed activation from preparation.
See [LOCATION_ASSEMBLY.md](LOCATION_ASSEMBLY.md) for RMB-specific contracts and
task evidence for the shared-hook dungeon regressions and subsequent RMB-only guard. Existing source policies,
readiness boundaries and full-story/real-owner obligations remain intact.
