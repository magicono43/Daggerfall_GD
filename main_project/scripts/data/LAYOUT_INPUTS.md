# Layout structural inputs — v1

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
fingerprinted by `layout_inputs.gd`. It assigns 1,295 block keys, 615,448 reserved
object-record keys, 9,005 building keys and 85,690 placement keys across
15,251 accepted locations. IDs were allocated once during authoring. Runtime
queries consult this table, never reconstruct identity from offsets, coordinates,
names or source order. Unknown source editions fail, requiring curated mappings.
The profile contains metadata, addresses, hashes and identities, not block bytes.
Stricter qualification never retires reserved keys: eight formerly decoded RDBs
are now explicitly unsupported for required unknown rotation/translation axes.
The current decoder supports 920 RMB / 166 RDB and rejects 21 RDB, 187 RDI and
one extensionless entry. Unknown axis corrections and DFU's TRP/LID/WHE runtime
rotation hacks are not adopted. Raw parameters remain evidence, not guessed motion.
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
20–26, 28–31, 99. Unknown researched kinds such as 27/32/50 fail required decode.
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
