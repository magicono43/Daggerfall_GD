# Layout structural inputs — v1

IMP-013 increment 3 permits optional complete
`location_assembly.placement_policy`, validated by `placement_policy.gd` through
the existing DATA/MOD/loose transaction. The default is project-authored
`content/layouts/placement.json`; LOC captures its resolved small projection once
per preparation. See [MOVE placement](../move/PLACEMENT.md) for units, envelopes,
anchor conversion and ownership. This definition qualifies no physical pose.

IMP-013 increment 2 adds optional validated `location_assembly.doorways` using
`location-doorways-v1`. Complete interior/link declarations and source guards use
the existing publication/MOD/loose precedence and source locks. See
[LOCATION_DOORWAYS.md](../loc/LOCATION_DOORWAYS.md) for exact fields, qualified
classic pairs, source transforms, preparation failures and scoped handoffs.
DATA validation establishes declarations, not live LOC bindings, actor pose or SAVE.

IMP-010 increment 2, DATA-005. Qualification evidence is recorded separately;
this contract does not establish user acceptance. Increment-3 variant definitions
and pure scoped proposals are specified separately in [VARIANT_INPUTS.md](VARIANT_INPUTS.md).

The variant resolver reuses `location_inputs`, `decode_block`, declared occurrence
metadata and `prepare_structural_inputs`; these retain the same resource, marker,
door, link and coordinate checks. Trusted resolved inputs do not publish definitions
or create live LOC objects. Required variant failure leaves no usable occurrences.

`layout-inputs-v1` is a trusted adapter in the existing DATA/MOD/CORE transaction,
not another registry. `enable_layout_inputs(required_resource_sources)` registers
BLOCKS/MAPS BSA sources and any explicitly declared consumer media sources before
preparation. The normal shell enables the adapter. The independent `layout-inputs`
fixture enables the same adapter, geography and real media export provider, plus
only the source textures actually consumed by its representative resource probes.
Future real LOC consumers must declare their resource dependencies before preparation.

## Source edition and identity

`content/layouts/profile.json` is explicit `classic-layout-profile-v1` metadata,
fingerprinted by `layout_inputs.gd`. It assigns 1,295 block keys, 618,798 reserved
object-record keys, 9,005 building keys and 85,690 placement keys across
15,251 accepted locations. IDs were allocated once during authoring. Runtime
queries consult this table, never reconstruct identity from offsets, coordinates,
names or source order. Unknown source editions fail, requiring curated mappings.
The profile contains metadata, addresses, hashes and identities, not block bytes.
Qualification never retires reserved keys. The current decoder structurally
supports all 920 RMB / 187 RDB blocks in the pinned edition. The 187 RDI entries
(unknown auxiliary data, also ignored for layout geometry by DFU) and one
extensionless archive entry are not decoded as layouts.
Exceptional motion axes retain known actions and required graph links, with
`action_axis_metadata` recording raw parameters, DFU interpretation and pending
gameplay-owner readiness. DFU rotates TRP/axis-13 using NegativeX and magnitude
400; its generic unknown-axis branch leaves a zero motion vector. No motion is
executed by DATA, and no generic bitmask correction is inferred. Authored model
motion axes remain restricted to the explicitly supported enum.
The authoring tool accepts only the observed edition, reuses the pinned ledger,
checks source hashes before/after, refuses an existing output, and preserves
all prior keys even when a stricter decoder rejects their source block.

Definition keys use domain `layout.inputs`, originating package and local
`packs/<package>#<record>`. Shipped mappings use `packs/classic`. Classic block
names are separately scoped source addresses. An explicit replacement retains
origin and classic mapping while tracking the winner/contributors. Durable
`resolve_identity` rejects an origin mismatch. Occurrence references contain the
complete layout definition identity, explicit placement key and record key.
They contain no live door, action, loot, enemy or character state.
Buildings have separate stable record keys within each placed block. Source
subrecord ordinals remain addresses in an explicit edition map. Exterior/interior
record context, parent building identity and raw parent transform remain separate
from the layout's block-placement context.

## Binary inventory

All integers are little endian. Counts/extents are checked before cursor access.
Source addresses remain diagnostics/mapping inputs, never public durable IDs.

| Format | Encoding and retained fields |
| --- | --- |
| RMB fixed header | 6,776 bytes: three u8 counts; 32 × 20-byte positions (two u32 unknowns, s32 X/Z/yaw); 32 × 26-byte buildings; 128 unknown bytes; 32 s32 building extents; 8-byte ground header; 256 tile + 256 scenery bytes; 4,096 automap bytes; 33 × 13-byte names |
| Building metadata | u16 seed, u32 service limit, two u16 + two u32 unknowns, u16 faction, s16 sector, u16 location ID, u8 type/quality |
| RMB building | Declared extent encloses exterior then interior. Each has five u8 counts and 12 unknown header bytes. Any remaining building tail is explicitly retained, not interpreted |
| RMB models | 66 bytes: s16 × 100 + u8 classic model identity; u8 object type; unknown/null prefix; two s32 XYZ positions; u32 null; s16 yaw; retained suffix. ARCH3D numeric IDs are not ordinals |
| RMB flats/people | 17 bytes: s32 XYZ, u16 texture bitfield, s16 faction, u8 flags. Archive = bits >> 7; record = bits & 127 |
| RMB section 3 | 16 bytes: s32 XYZ + four uninterpreted bytes. No gameplay meaning is invented |
| RMB doors | 19 bytes: s32 XYZ, s16 yaw/open rotation, u8 door-model index, unknown and null bytes. The explicit profile maps styles 0–4 to classic model IDs 9000–9004 (DFU DaggerfallInterior.AddActionDoors). Zero is valid. Other styles fail resource preparation; DFU's modulo fallback is deliberately excluded. Authored doors may instead name an explicit media model export |
| RMB ground | 16 × 16 row-major bytes. Tiles: low six bits record, bit 6 rotated, bit 7 flipped. Scenery: byte/4−1 record and low two unknown bits; 255 has absent record −1. Environment archive selection remains a consumer input |
| RDB header | 20 bytes: u32 unknown, width, height, root address, unknown. 750 × (5-byte model ID + 3-byte description), 750 u32 unknowns, 512-byte object section header. Root table begins at 9,532; width × height s32 roots |
| RDB object | 25 bytes: s32 next/previous, s32 XYZ, u8 type, u32 resource address. Supported type 1 model, 2 light, 3 flat |
| RDB model | 23 bytes: s32 XYZ rotations, u16 model-table index, u32 trigger/starting lock, u8 sound, s32 action address |
| RDB model action | 10 bytes: u8 axis, u16 duration/magnitude, s32 target object address, u8 kind |
| RDB flat | 11 bytes: u16 texture, u16 flags, u8 magnitude/sound (also raw faction/mobile input), s32 target, u8 action |
| RDB light | 10 bytes: two unknown u32 values, u16 radius |
| RDB unused input | Model data, object-section header and complete source bytes remain retained. Unknown linked-list semantics and unused gaps are not gameplay interpretation |
| RDI/extensionless FOO | Inventory only, never supported preparation. A required reference fails explicitly |

RDB action kinds currently recognized structurally: 0–9, 11, 12, 14, 16–18,
20–26, 28–31, 99. Unknown classic kinds remain explicitly non-executing metadata
under user-authorized PROJECT-DATA-D02; they do not fail structural import solely
because their behavior is unknown. All raw code/parameters/target addresses remain
in `unused_action`, with no executable outgoing edge. The pinned corpus contains
13 such records: 27×6,32×4,100×2,50×1. Twelve are in supported blocks; N0000007
still fails an independent required-axis gate. Gameplay-owner readiness remains
pending. Unknown authored executable actions remain rejected. Known actions keep
all required-link checks, and malformed extents/unsupported axes still reject.
Recognition supplies parameters/links only; it does not execute actions or prove
the corresponding gameplay owner available. Door tags DOR/DDR/NEW/CAV and the
72100 red-brick exclusion are DFU structural classification evidence, not an
engine door factory or placement correction.

Negative root/next addresses terminate object enumeration. Zero is not an absent
root: it addresses the fixed header and rejects. Model action addresses <= 0
mean no action payload. Negative action targets are absent. Target zero addresses
no object in the fixed header and remains unbound for optional links; teleport
requires a real destination. Positive action targets bind within the whole block
(RDBLayout's action dictionary), and acquire occurrence placement context later.
Cycles and repeated action targets remain intact. An enumeration-list cycle is
malformed rather than a gameplay action cycle. No action execution cap exists.
Kind 0 has no action component in the source consumer: its outgoing address is
retained as `unused-no-action`, not validated as an executable edge. It can still
be the destination of another required action. Model axes beyond 0–6 reject for
translation/rotation; raw axis bytes for other actions are retained unused.
Duration/magnitude/sound-index fields remain encoded action inputs, not seconds,
engine angles, audio ordinals or validated gameplay spell/quest semantics.

## MAPS handoff

Accepted geography provides stable location identity and raw region/ordinal/
PITEM addresses. Layout interpretation does not alter name, current authored
position, discovery qualifications, climate alignment or pixel occupancy.
Each location element has u32 door count, 6-byte doors and a 112-byte header.
Exterior input follows with u16 building count + five unknown bytes, 26-byte
buildings, then a 416-byte exterior structure. Width/height bound 64 source slots;
three 64-byte code arrays resolve exact classic RMB names using the documented
prefix/character table. These names select explicit edition mappings, not IDs.

DITEM contains u32 count, then 8-byte directory entries (u32 relative address,
u16 dungeon flag and exterior location ID). A matching location element is
followed by a 17-byte dungeon header and 4-byte placements: signed-byte X/Z and
u16 number/start/class bitfield. Class letters N/W/L/S/B/M are checked. Missing
and ambiguous required mappings never select another location or block. No
Orsinium position correction or smaller-dungeon generation is adopted here.
MAPS building pools and legacy door elements remain separate source inputs.
The only DFU references to LocationDoorElement.BuildingDataIndex are its API
declaration/reader; no active consumer binding is invented. RMB building metadata
is not silently overwritten by DFU's later type/order-based named-building pool
distribution. Real LOC/service consumers must qualify that association explicitly;
these source arrays do not establish usable names, factions or services.

## Publication and preparation

Add/replace/patch use actual checked folder/ZIP/loose transport. Patches replace
complete top-level `data` or `compatibility`; there is no deep merge or deletion.
The registry's optional `validate_replace` hook lets this adapter require the
complete previous namespace ID set for a `replace`. Omitted IDs reject rather
than implicitly deleting sibling definitions. A complete body explicitly replaces
its record arrays; its own required links/scopes/remapping must remain valid.
The adapter checks complete record kinds, identities, transforms and links;
final cross-domain validation checks containing geography and authored block
references. Each candidate rebuilds indexes under its exact ticket. Cached
serialized shipped input is reused only after checking profile/source hashes.
On-demand blocks are decoded anew; no obsolete decoded override cache exists.

`location_inputs` returns structural MAPS inputs. `decode_block` returns detached
block data plus identity, contributor/winner and committed content context.
`prepare_location` binds all required records/resources before returning an
occurrence projection. Failure returns diagnostics without an `occurrences`
success payload, even after earlier resource checks succeeded. Resource callbacks
receive detached records and exact definition/content context. `classic_resource`
uses actual application model/texture readers; texture dependencies must have
been declared before preparation. It does not search for another installation.
Authored records can instead reference `{provider,key,type}` exports in the real
`media.assets` domain. Final candidate validation checks exact typed exports;
on demand the real media service checks the same generation. No global numeric
range, basename alias, extra registry or separate package reader is introduced.
Classic source resource validation is the accepted decoded-media interface, not
qualification of climate-dependent model materials or real AV/LOC presentation.

Required record requests specify placement, stable record, type, purpose and
optional placement context. Wrong-purpose markers never satisfy a request.
The optional request context addresses record context (including an RMB building
interior); parent block placement context is retained separately. Source records
expose `layout-coordinate-handoff-v1` parent chains including building projections.
The stages retain the original block grid/placement, stable building identity
and source transform, then the record transform. A source building has no encoded
Y offset, so its parent plane is zero; this selects no terrain floor or engine pose.
Archive 199 records 8/10/11/18 retain entrance/dungeon-start/quest/quest-item
purposes. A dungeon-start marker cannot establish new-character opening content.

Source coordinates remain signed encoded XYZ in `classic-block-local-v1`, with
`classic-layout-integer` position units and `classic-angle-2048` rotations. Unity
axis changes, MeshReader scale and motor units are not adopted. Source-to-same-
source conversion is exact, tolerance zero and no rounding. IMP-061 increment 1
adds the explicitly named `dungeon-geometry-metres-v1` geometry consumer through
the shared `layout_geometry_frame.gd` boundary. See
[DUNGEON_ASSEMBLY.md](../loc/DUNGEON_ASSEMBLY.md) for units, axis/angle composition,
normal/winding and precision fixtures. `convert` also accepts explicitly declared
native poses in that frame. Other conversions still reject. DATA results retain
`physics_ready=false`; motor scale, actor placement and WORLD origin/rebase
qualification are not inferred from LOC geometry checks.

Layouts may additionally publish complete versioned `data.assembly` declarations.
Source mapping/receipts remain protected when these annotations are overridden.
The hash-pinned shipped annotation covers only `place-00032` under its exact
MAPS/BLOCKS/model edition guards. Unqualified classic layouts cannot silently
acquire connections. Native authored transforms may use explicit metre/radian
poses, plus checked `placement_mode`/`snap` declarations. Publication validates
their structure; LOC owns actual geometry, instances and traversal validation.
Location queries now retain detached content/winner/contributor provenance.

Structural explicit remapping rejects absent/ambiguous destinations. All results
retain `save_compatible=false`; unchanged IDs or checked mappings do not establish
real SAVE/LOC/QUEST compatibility. Variant resolution and migration are excluded.

## Qualification and owner gates

The independent source observer and offline corpus probe are separate from startup.
The frozen scenario inventories are 369 headless / 372 rendered and 15 genuinely
fresh-process checks. The same source-reading paths are selected in actual Windows
debug/release exports. See execution evidence for completed commands and any open
checks; a versioned contract alone does not establish verification. Real LOC/WORLD/
MOVE/action/QUEST/SAVE/CORE-opening and M1 gates remain unavailable throughout this
increment. Those historical DATA-only tests do not qualify LOC geometry. Source
metadata pool pairing, model-material climate substitution and SAVE compatibility
still require their real providers. IMP-061 increment-1 evidence separately
qualifies its named geometry/instance source scope; actual MOVE/QUEST/action/SAVE
and other named joint checks remain open. No controlled fixture closes them.

## IMP-061 increment-2 context extension

Validated `dungeon-context-v1` layout data supplies moddable palettes, explicit
climate bindings, bounded water and special areas. Source-import annotations are
SHA-pinned in `content/layouts/dungeon_context.json` and input-matched per placed
block/pose. `environment_observation` scans all 199/10 records without selecting
an arrival. Invalid/conflicting required metadata fails explicitly. The optional
LOC-only deferred-resource preparation still validates typed references and
retains all records; LOC must then validate/stage every required resource before
readiness. Ordinary structural-input preparation retains its existing checks.
See [dungeon context contract](../loc/DUNGEON_CONTEXT.md).

## IMP-013 increment-1 geometry consumer

The normal session composition now uses the shared LOC
[location assembly owner](../loc/LOCATION_ASSEMBLY.md) for RMB exteriors and
building interiors as well as accepted dungeon requests. DATA preserves its
original raw poses and separate building/record contexts. LOC applies source RMB
parent/miscellaneous conventions, 4096-unit exterior grid and the existing named
metre frame; the RDB grid remains unchanged. This does not change DATA's structural
readiness into physical or gameplay readiness.

Layouts may publish complete `location_assembly` declarations through the same
add/replace/patch/loose validation paths. Shipped annotations are source/hash guarded
and cover only `place-00001` / `TVRNBS04.RMB`. The normal composition declares the
annotation's required texture sources before preparation. `ground_archive` is an
explicit baseline input; terrain, climate/season integration and route readiness
remain pending. Optional authored RMB flat `marker_roles` is a nonempty set of
distinct validated role IDs. It does not automatically bind an entrance or promote
rest to entry. Classic identity/profile hashes and unknown-action/axis policies
remain unchanged. MAPS named-building and door-pool associations remain unqualified.

Doorway declarations also support guarded entry-only aliases with exactly `id`,
`exterior`, `entry_alias_of` and `provenance`. They target a canonical link directly
in the same building occurrence; missing targets, chains, cycles, duplicate exterior
planes and changed source guards reject. LOC resolves aliases after canonical links
and preserves the alias entrance separately from the canonical exit/return. The
TVRNBS04 courtyard alias is a documented DFU-observed baseline; it changes no source
geometry or original marker role/position. See `loc/LOCATION_DOORWAYS.md`.
