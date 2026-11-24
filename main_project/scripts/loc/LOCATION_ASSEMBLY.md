# Location assembly — IMP-013 increment 1

`location_assembly.gd` specializes the existing dungeon assembly owner. The normal
session shell composes one instance with the existing DATA/media/geography/variant
providers and CORE. Requests without `area` retain the accepted dungeon interface,
environment and marker handoffs. The stock unavailable gameplay provider remains
unavailable. Geometry assembly never completes a transition or releases CORE gates.

## Requests and identities

The original seven-field request and CORE ticket remain unchanged. An optional
`area={kind:"exterior"}` selects exterior RMB occurrences. An interior uses
`area={kind:"interior",placement,building,instance}`. The explicit instance is
independent of reusable block/building template, entrance and transient nodes.
Inspection/reconstruction is not an arrival request. Entrance/exit binding and
physical actor placement remain increments 2/3.

The inherited `begin/step/finish/cancel/activate` interface stages in an isolated
physics world, checks original CORE/content scope across physics registration,
and publishes coherently. Failure discards staging and preserves previous valid
geometry. CORE preflight results remain isolated until the original operation
reaches initialization. Activation records a separate session and activation
version; it does not rewrite the admission ticket. Retired/superseded tickets
cannot query current geometry. Repeated IDs with changed inputs reject.

Bindings retain layout/placement/record, building and interior-instance identity.
Definition/directory queries require no live geometry or session:

- `building_definition(layout,placement,building)` returns one detached record.
- `building_candidates(layout,"type"|"faction",value)` uses cached sorted indexes.
- `binding(ticket,placement,record)` returns only the requested detached binding,
  with layout/content/activation context.
- `marker_candidates(ticket,interior,role)` returns scoped role candidates. It
  grants no access, rental, guard spawning or placement result.

Directory caches are tied to the exact published content ticket and require an
active classic provider. Buildings use stable placement/building mappings,
including repeated occurrences. RMB metadata is retained directly. Unqualified
MAPS named-building/door-pool pairing is not guessed; `service_binding_ready=false`.
Names, ordinals and coordinates are not substitute building identities.

## Source composition and surfaces

All geometry uses DATA's `dungeon-geometry-metres-v1` conversion: 0.025 m per
classic unit, model points divided by 256, source angle revolution 2048, transformed
normals and clockwise Godot triangles. RMB grid side is **4096 units / 102.4 m**;
the accepted RDB side remains **2048 / 51.2 m**. They are separate source contexts.

For classic RMB building exteriors, the parent uses encoded X, zero source Y,
`4096 - encoded Z`, and encoded yaw. Models compose parent then record. Exterior
flats use parent translation without yaw, following DFU `RMBLayout.AddBlockFlats`.
Miscellaneous source props use their own `+4096` source-Z origin and DFU's
`-4` engine-up source-unit offset. Authored transforms do not inherit these source
special cases. Interior records remain local to their instance, independent of
exterior placement and building parent. Classic type-3 interior props use encoded positive
Y and bottom alignment, as documented in DFU `DaggerfallInterior.AddModels`.
Authored native poses remain literal in their declared units, including type-3
models in metre frames; the classic bottom/axis interpretation cannot rewrite them.

All selected model and action-door resources are real IMP-008 outputs. Required
model surfaces use their original archive/record textures through the existing
AV material factory; missing resources fail. Closed action-door geometry is
retained with explicitly pending gameplay state. No door is silently omitted.

Exterior assembly includes all 256 RMB ground tiles: 16 by 16, each 256 source
units / 6.4 m, at **-0.025 m**. Source row order is reflected as in DFU MeshReader.
The tile's rotation flag selects a 90-degree variant; its flip flag selects a
180-degree variant, including the combined case. DFU uploads image rows bottom-up;
DATA/Godot images are top-left-first, so the final sampled V coordinate is
inverted after the flag transform. `rmb-ground-top-left-uv-v1` is retained in
ground provenance and exterior geometry versions. Editor tile records >=56 use
the documented DFU grass record 2. Meshes group by texture, with preparation-local
prototype reuse and independent placed materials. One collision body per ground
occurrence is registered with Jolt. Raw tiles and detached triangle/UV probes
remain inspectable through the synthetic scoped `@ground` surface binding.

The replaceable DATA `location_assembly` declaration contains schema
`location-assembly-declarations-v1`, `ground_archive`, `required_bindings` and
`hit_rules`. It uses existing complete publication/override precedence. The
shipped source-guarded annotation qualifies `place-00001` / `TVRNBS04.RMB` and
explicitly selects desert ground archive 2. This is an inspection baseline,
not WORLD terrain, seasonal/climate substitution or full exterior traversal.
Unannotated classic RMB locations remain explicitly unsupported for assembly.

## Door and marker metadata

Classic static door planes are derived from actual decoded model topology and
DFU's texture classification (base archives 74/56/95; positive records of 331,
with the 156/331 archive exceptions). Region identity retains the owning scoped
record and original model plane. It is separate from an RMB action-door record.
All source model hashes, plane addresses and original records remain available.

`geometry_ray` resolves the actual Jolt shape owner and transformed hit point.
A preparation-built index limits candidate regions to those overlapping that
geometry. The point must lie on a real triangle. A facade hit alone grants no
door action. Several matching regions return `ambiguous` and no entrance unless
one exact validated `hit_rules={candidates,selected}` declaration resolves that
set. Missing/conflicting selectors fail preparation; enumeration order never
selects an entrance. All traversal/access dispatch remains unavailable here.

Source interior 199/4 exposes `rest`; 199/8 exposes `entry`. Original raw purpose
metadata remains intact. Rest is never silently promoted to entry. Authored RMB
flat `marker_roles` supports explicit distinct multiple roles through DATA
validation. Required owner state and entry/exit associations remain pending.

## Qualification and remaining gates

The independent Python observer reads source bytes without runtime importers or
conversion helpers. It pins source/build hashes, 161 model/action-door vectors,
building parents, marker roles/poses, UV correction vectors and ground tile
inventory. The production fixture qualifies the complete one-block exterior,
one representative building interior, repeated/reordered snapped/free/rotated
occurrences, coincident hit ambiguity/selectors, and a 64-occurrence exterior
scaling case. Numerical position tolerance remains **0.001 m**, with the accepted
**8192 m** local precision extent and configured Jolt capacity. These are geometry
limits, not actor clearance, correction budgets or WORLD coordinates.

Geometry/collision/context readiness are independent of bindings and gameplay.
`destination_ready`, `owner_state_ready`, `placement_committed` and
`save_compatible` remain false. Terrain, routes, gate schedules/occupancy, access,
MOVE shape/pose commitment, NPC/loot/action/QUEST owners, native SAVE, full story
entry and WORLD membership/streaming retain their named providers. Fresh-process
reconstruction verifies geometry compatibility only. See task execution evidence
for actual commands, counts, captures, failures and acceptance status.
