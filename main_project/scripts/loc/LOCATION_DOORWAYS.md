# Location doorway bindings — IMP-013 increments 2/3

Increment 3 supplies the composed [MOVE placement authority](../move/PLACEMENT.md)
through this unchanged scoped consumer interface. Handoffs additionally capture
the validated resolved DATA placement policy in their fingerprint. Queries
remain non-committing; MOVE owns its separate checked commitment. Real access,
WORLD, gameplay reactions and native SAVE retain their named integration gates.

The normal `location_assembly.gd` owner prepares these indexes inside its inherited
staging transaction. DATA supplies optional `location_assembly.doorways` using
`location-doorways-v1`, through the existing shipped → MOD → captured loose
publication path. There is no second registry, actor owner or session lifetime.
Declarations are complete replacements under the existing shallow DATA patch
contract; a patch replacing `data` must supply complete layout data.

## Definitions and source guards

The declaration has `schema`, `interiors`, `links`. Each interior has a stable
`id`, `placement`, `building`, exact `parent` transform and `provenance`. The
resolved instance identity contains location/layout/placement/building/local ID.
Its block/building template identity and provenance are separate fields. Entrances, exits,
markers, instance IDs, reusable templates and transient scene handles never stand
in for one another. Independent authored instance IDs may reuse one template.

Each link contains `id`, `interior`, `exterior`, `exit`, `landing`,
`outside_offset`, `provenance`. Each doorway names its exact placement, local
model record and original plane, plus `guard={transform,payload_sha256,
model_sha256}`. A landing names its local marker, unit engine-local interior
`forward`, `additional_entry` and `guard={transform,payload_sha256,texture}`.
Classic payload guards must match the effective published block's source hash;
authored replacements must use an empty payload hash even if a shallow override
retained the old record's `input` provenance. Exact parent/record guards
and model hashes prevent a baseline annotation from qualifying modified inputs.
All endpoints resolve in the declared building/context, and source plane texture
classification must still identify a static door. Action-door panels cannot
substitute for traversal exits. Every static model exit in a declared supported
interior requires an independent exterior link. Missing endpoints, unmatched
guards, duplicate declarations and unqualified replacement topology fail closed.

An entry-only alias instead contains exactly `id`, `exterior`, `entry_alias_of`
and `provenance`. Its exterior has the same exact source guards. The target must
be a canonical link in this declaration; forward references work, while missing
targets, chains and cycles reject. The alias must belong to that same building
occurrence. It inherits the canonical interior, landing, exit and return exterior,
while retaining its own selected entrance identity. It cannot supply an additional
interior exit or overwrite an exit's canonical link. An exterior arrival selecting
an alias fails `entry_only`; leaving requires a new request for an actual exit.

Preparation uses actual resource points/normals with the accepted common frame:
0.025 metres/source unit, model points /256, source Y/Z reflection, RMB grid
4096 units/102.4 m and unchanged RDB grid 2048/51.2 m. Interior records remain in
their instance frame. Exterior occurrences compose the source building parent
and model pose. Native poses retain their literal semantics, including type 3.

The landing must lie on the inward side of its named exit (signed separation
greater than the existing 0.001 m geometry tolerance), and its perpendicular
projection must hit the actual door aperture under the existing triangle test.
Explicit authored unit facing remains independent of this geometric side check;
no forced normal alignment or angular gameplay policy is introduced. The
explicit exterior offset is in metres in its occurrence frame, rotated with the
occurrence, and must lie on the outward side. Both marker and exterior desired
anchors must remain within the existing qualified 8192 m local extent. These are binding/side checks,
not an actor shape, floor/support test, recovery radius or correction budget.
Coincident prepared regions require an exact DATA `hit_rules` candidate set and
selected identity. Selectors for the other space are checked against actual
source topology without instantiating that space. Missing selectors still fail.

## Qualified classic scope and intentional differences

`observe_location_doorways.py` reads source bytes independently of runtime
decoders/converters and records `location_doorway_observation.json`. Explicit
pairs in TVRNBS04.RMB / place-00001 are:

| Link | Building | Exterior plane | Interior exit | Original entry marker |
| --- | --- | --- | --- | --- |
| home-east | building-0000 | record-00000 / 0, model 549 | record-00004 / 16, model 31021 | record-00033, 199/8 |
| home-north | building-0001 | record-00088 / 0, model 546 | record-00089 / 4, model 31419 | record-00116, 199/8 |
| tavern-front | building-0002 | record-00150 / 36, model 626 | record-00200 / 2, model 31529 | record-00274, 199/8 |
| tavern-rear | building-0002 | record-00150 / 46, model 626 | record-00203 / 2, model 31530 | record-00271, 199/8 |

Door dimensions independently measure 1.25 m wide by 2.25 m high. For the two
houses, subtracting the building parent gives centres `[6.4,1.125,-0.975]` and `[0.975,1.125,6.4]`;
interior centres are `[6.25,1.125,-0.975]` and `[0.975,1.125,6.25]`.
Each house pair has opposite normals and 0.15 m plane separation, with matching
vertical/tangential extents. This is the observed wall-panel separation, not an
actor clearance allowance or a global matching tolerance. Source entry anchors
are `[4.8,0,-1.6]` and `[1.6,0,4.8]`. Their projections lie on the door edges;
the existing 0.001 m aperture tolerance accommodates float conversion only.

Facing into each room follows its inward plane normal as a documented authored
baseline, consistent with DFU placing arrivals on that side. Neither original
executable facing nor actor clearance is claimed. The exterior return anchor is
explicitly one metre along the outward normal from the door centre, at centre
height. It is a desired anchor for later MOVE qualification, not a committed
actor pose or the DFU controller-radius/height rule.

DFU evidence is read-only `DaggerfallInterior.AssignBlockData`,
`FindClosestEnterMarker`, `FindClosestInteriorDoor`, `PlayerEnterExit`'s building
transform and `TransitionInterior`, and `DaggerfallStaticDoors`. Existing DFU MIT
licensing applies. Its nearest-entry/rest/door fallback is deliberately not used
as evidence of an intended link. Archive199/4 remains rest; archive199/8 remains
entry. An explicit verified mapping can add entry while retaining rest, with
provenance; ECON/LAW still select their own eligible candidates.

The tavern has three exterior doors but two static interior exits. Its canonical
front/rear planes have opposite normals and an exact source centre difference
`[0,0.05,0.15]` metres after parent conversion (the exterior is 0.05 m higher).
The original landing markers are `[-1.6,0,-4.8]` and `[-1.6,0,8]`.
`tavern-courtyard` names plane41 (#2) as an entry alias of `tavern-rear`:
entering #2 selects marker00271 / exit00203, whose return is plane46 (#3).
This explicit compatibility baseline follows the user's DFU test on 2026-11-24,
including immediate exit at #3. It is not an original-executable behavior claim
or a runtime nearest-marker rule. No geometry or marker is moved or added;
entry markers00272/00273 remain retained and unbound, and all five rest markers
retain their roles. No MAPS name/building pool association is invented.
Other unannotated classic locations
retain their existing unsupported assembly status. A required request for an
undeclared link fails; inspection can retain geometry with unresolved bindings.

## Handoff and readiness

Arrival requests retain the original seven fields and CORE ticket, with
`area` plus `arrival={route:<link ID>,kind:"doorway",doorway:<same link ID>}`.
An interior arrival must name the declared placement/building/instance. An exterior
arrival is the selected exit's return operation. Reusing an ID with different
inputs rejects. Entry through front does not rewrite the stored back-exit link;
leaving through back submits a new operation explicitly selecting back.

`marker_candidate(ticket,link,0)` returns only the selected detached link, exact
marker, template/instance/entrance/exit identities, source anchor/facing,
`desired_context={space,doorway_side,movement_owner_pending}`, original ticket,
content/layout/geometry/binding context and separate activation session/version.
There are no fallback indices. A request with arrival intent cannot be retargeted.
Inspection can inspect bindings, but `check_marker_candidate` returns
`route_intent_pending`; it cannot promote inspection to arrival.

The inherited IMP-061 `check_marker_candidate` rechecks access, the exact handoff
fingerprint before/after callbacks and the MOVE response's echoed marker/frame.
It rejects preactivation receipts after activation, stale content/layout/tickets,
retirement and late callbacks. The RDB scoped marker implementation and its
general/doorway/opening selection semantics remain unchanged. Controlled pending
consumers test this interface without claiming real access or MOVE readiness.

`declared_bindings_ready` means the declared graph passed preparation.
`binding_ready` on the assembly additionally requires the active instance and all
its static traversal doors to be bound; unresolved static regions are retained in
`pending_static_door_bindings`. Each selected handoff/door exposes its own binding
readiness independently. Geometry/collision readiness describes the staged active
space only. Counterpart metadata has `geometry_ready=false`; resolving its source
topology does not instantiate or certify that space's collisions. Gameplay-owner
state, destination readiness, committed placement and SAVE remain false.

Any required binding failure discards partial staging and retains the prior live
exterior/context. Indexes are built once per preparation with block/resource
reuse and are published atomically with geometry. Point queries never copy a
catalog, decode a block or rebuild the graph.

Changed location assembly/doorway meaning also remains behind the existing
structural variant compatibility gate; a controlled rejection-only proposal
tests that boundary without qualifying a new variant provider. Fresh-process
reconstruction checks
stable definitions/identities and tolerant source anchor/facing values; it is not
SAVE restoration. Increment 3 retains full active-shape validation, bounded local
corrections, physical pose commitment and transition completion. WORLD, gameplay
state, native SAVE, full story entry and parent IMP-013/M2 gates remain open.
