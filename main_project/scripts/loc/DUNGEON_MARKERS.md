# Dungeon marker handoff — IMP-061 increment 3

IMP-013 increment 3 now composes a real [MOVE placement authority](../move/PLACEMENT.md)
using this consumer boundary for qualified RMB doorway handoffs. RDB marker
selection is unchanged; this slice requires doorway aperture/physical context,
so it does not qualify RDB arrival execution, ordinary Privateer's Hold assembly,
WORLD geography, native SAVE or full story entry. Stock access and required
gameplay providers remain unavailable.

IMP-013 increment 2 now reuses this scoped `marker_candidate` /
`check_marker_candidate` consumer boundary for qualified RMB doorway links in
the single composed LOC owner. See [LOCATION_DOORWAYS.md](LOCATION_DOORWAYS.md).
RDB selection/return semantics below remain unchanged. Real access/MOVE providers,
RDB exterior static-door association, physical pose and SAVE remain open; a
controlled pending callback does not qualify those providers.

`dungeon-arrivals-v1` is optional immutable `layout.inputs` layout data. It uses
the existing shipped → checked MOD → captured loose publication path. There is
no new registry or startup adapter. DATA validates complete declarations, typed
return-layout/site references and the existing publication/source locks. LOC
checks effective records and returns while staging, before atomic publication.

## Declarations and source matching

The complete dictionary has `schema`, `landings` and `routes`. A landing has
`id`, `placement`, `record`, `purpose`, `frame`, `forward`, `guard`, `provenance`.
Supported purposes are `dungeon-start` and `dungeon-entrance`; these source roles
are separate from the route's general/doorway/opening intent. All records retain
their existing stable placement/local-record identities, including repeated blocks.
Duplicate landing/route IDs reject. Required missing specific targets fail whole
preparation. Missing general candidates remain explicit; at least one declared
candidate must resolve. A wrong role/frame/guard is invalid data, never a backup
selection policy.

`guard` supplies the exact effective `block` reference and record `transform`.
Classic records additionally require their `payload_sha256`. An authored block
cannot inherit a classic source guard. Changed inputs need a matching validated
override; an annotation never overwrites externally edited data. Forward is a
finite unit vector in the declared record-local frame. Source positions, record
rotations, placed occurrence transforms and forward all use the existing
`layout_geometry_frame.gd` boundary (0.025 metre/classic unit). No second DFU/Unity
coordinate frame, floor snap, actor dimensions or correction radius is introduced.

A route has `id`, `kind`, `doorway`, `default`, `backups`, `selection`, `return`.
Kinds are `general`, `doorway`, `opening`; `selection=authored-order` is the
supported policy. Approach weighting is unsupported rather than supplied with
invented absent-approach/tie behavior. Only general routes have ordered backups.
Specific routes retain exactly one landing. Two doorway routes may explicitly
name the same landing while keeping distinct doorway and return identities.

Return declarations contain `id`, `location`, `layout`, `placement`, `record`,
`provenance`. The exterior layout must belong to the same declared destination
site and its explicit placement must have exterior context. Nonempty record IDs
must resolve within that exterior context. An empty record explicitly reports
`doorway_binding_pending=true`: the available mapping resolves only the exterior
layout/placement context. It does not claim an exact exterior doorway or geometry.
Even a resolved exterior record remains `doorway_binding_pending`: record
existence does not qualify a static doorway association. Return projections keep
`geometry_ready`, `traversal_ready` and
`geography_committed` false until the actual IMP-025/WORLD providers exist.

## Owner API and lifetime

`marker_candidate(original_ticket,route,index=0)` returns a detached source marker
anchor, facing, original request/CORE/session/content/preparation ticket, effective
layout/geometry/context/marker versions, route/door/return context and provenance.
The durable marker includes layout identity, placed occurrence and local record;
versions qualify compatibility. A narrow prepared index supplies the selected
record. Point queries never copy the content catalog, decode blocks or rebuild a
graph. Distinct return layouts/blocks are resolved once within exact preparation.

An arrival preparation additionally supplies original request
`arrival={route,kind,doorway}`. LOC checks these fields against the effective route
before publication and rejects requests/results that retarget it. General backup
indices remain within that bound route. An omitted arrival field permits geometry
inspection/reconstruction only; `check_marker_candidate` returns
`route_intent_pending` and cannot turn inspection into a placement operation.

`check_marker_candidate(ticket,route,index,access,placement)` is a checked consumer
boundary, not a WORLD route coordinator. WORLD chooses the authored index and
decides whether a rejected/missing general candidate permits its next backup.
Access is checked separately for every candidate and again after placement.
Revocation fails the route; it cannot be interpreted as permission to skip to a
less restricted landing. Named/opening out-of-range indices return exhaustion.
Missing real providers remain explicitly unavailable. Geometry without qualified
context returns `context_pending` before placement.

Each owner response must echo the selected `handoff_id`, a fingerprint of the
original ticket, current activation session, route/index and exact marker/return
identities. `activation_session` is separate from the original request session;
it is empty during isolated preparation. Each owner callback rechecks the exact
handoff, so a prepared result becomes obsolete when activation changes even though
the original operation ticket is retained. MOVE also echoes
the marker and frame and reports `exact`, `corrected`, `rejected` or `pending`.
Successful claims require finite actor position/unit facing; corrected claims
require MOVE provenance. LOC neither generates nor validates a correction route,
active collision shape, support, motor state or correction bounds. A marker anchor
and a MOVE-reported actor pose remain separate fields. Controlled fixtures label
their responses; they do not qualify a real MOVE provider.

`ok` describes marker resolution/request handling, not entry. A resolved marker
can carry pending or rejected placement; consumers must inspect the explicit
placement state and all real-owner gates, never treat `ok` as committed success.

The existing assembly stage owns its index. Failed/cancelled preparation discards
it with staged geometry and preserves the previous live context. CORE retains
outgoing geometry while gating its queries during preflight. Only the original
operation may activate prepared geometry/indexes. Wrong-ticket cancellation,
obsolete callbacks and retired sessions cannot expose another operation's data.
Completed intake receipts retain their existing idempotent/superseded semantics.
Compatible visual variants retain arrival meaning; changed arrival declarations
remain behind the structural compatibility gate.

No query commits destination, geography, physical pose, entry effects, owner state
or SAVE readiness. Actual IMP-013/WORLD/MOVE consumers remain unavailable in the
stock session provider. The existing composed LOC interface is exercised through
normal DATA and CORE session preparation with precisely labelled controlled
access/placement consumers.

## Native restoration

SAVE/MOVE restore the authoritative saved pose and movement histories. They use
stable `binding` references for reconstruction and must not select a new arrival,
replay doorway effects or reset breath. Preparing a derived marker index does not
select an arrival or emit events. Fresh-process fixtures verify compatible index
and reference reconstruction only; `native_restore_ready`/`save_compatible` remain
false. No native SAVE implementation or migration contract is invented here.

## Pinned source scope

`content/layouts/dungeon_arrivals.json` supplies source-matched authored bindings
for place-00032 and place-04310, guarded by the accepted source edition. Cyeghtan's
explicit default is placement-00003/record-00220; its authored backup is
placement-00006/record-00005. Selection does not scan for the first Start marker.
Environmental Start metadata remains independent under LOC-012.

Privateer's Hold is place-04310. Its cave marker is placement-00001 /
S0000999.RDB / record-00216, source address32814, archive199/record8, source
XYZ `[510,-25,1672]`, converted anchor `[12.75,0.625,-41.8]`. Its ordinary
Start anchor is record-00118 at `[28.375,38.975,-12.4]`. Independent observations
pin all five source placements, 56 editor markers, 365 transformed model bounds
and a floor witness in cave model60200 at height0. These qualify source geometry
inspection and the explicit cave binding, not full actor clearance/story traversal.
The original layout still lacks qualified connection declarations and fails closed
for ordinary assembly; the source inspection fixture is explicitly separate.

The user authorized DFU's north-facing baseline on 2026-11-23. Classic north +Z
converts to Godot -Z. RDB flat records encode no orientation: neither original
executable facing nor original executable behavior is claimed verified. Ordinary
baseline facing is explicitly authored north, not a nearest-door inference.
Return mappings currently qualify exterior layout/placement context only; exact
classic static-door association and traversal remain IMP-013/025 work.

Unknown vanilla action bytes use `classic-unknown-action-metadata-v1`: preserve
their code/parameters/target address as `unused_action`, with no executable outgoing
edge. LOC exposes their pending owner bindings and never claims gameplay readiness.
This policy is explicitly user-authorized and recorded in repository AGENTS.md.

Exceptional known motion axes are a separate case: DATA retains `action` and its
required graph edges, with `action_axis_metadata` documenting the raw parameters
and DFU interpretation. LOC exposes `pending_action_axis_bindings` and
`action_axis_owner_ready`; marker handoffs carry the corresponding readiness and
count. Structural/geometry preparation does not execute or qualify these actions.
