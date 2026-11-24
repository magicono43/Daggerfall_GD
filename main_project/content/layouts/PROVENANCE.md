# Layout metadata provenance — IMP-010 increment 2

Selected source: explicit `C:/Games/Daggerfall/arena2` BLOCKS.BSA and MAPS.BSA.
Source lengths/hashes, complete archive directories and independent structural
pins are in `tests/layout_source_observation.json`. No classic block/map payload
is shipped or modified. `profile.json` contains explicit edition identities,
source addresses/hashes and qualification metadata, generated once by the
GDScript authoring tool, which refuses an existing output. Unknown editions do
not receive inferred mappings. This profile was user-accepted with increment 2 at `e324d54` on 2026-11-22.
The increment-2 profile SHA-256 was
`a2e629e5d085b3d0ed58f3c17958f4accec4910e9204b6967203ab55af717b75`.
It preserves all 1,295 initial block, 615,448 reserved object-record and 85,690
placement keys, adds 9,005 explicit building keys, and records stricter unsupported
axis qualification without deleting their reserved keys. Deterministic rebuilding
uses the existing pinned identity ledger rather than reallocating by source order.

Format and consumer evidence: read-only DFU 1.1.1 snapshot API/BlocksFile.cs,
DFBlock.cs, MapsFile.cs, DFLocation.cs, Utility/RMBLayout.cs, RDBLayout.cs,
Internal/DaggerfallInterior.cs (door-resource IDs) and API/TextureFile.cs
(transparent/literal-run frame encoding).
DFU's MIT license is included as DFU_LICENSE.txt. Code is a separate GDScript
implementation. PROJECT-DATA-D01 authorizes this source choice. No source
correction, Unity motor scale, door placement offset, Orsinium overlap adjustment,
smaller-dungeon generation, action execution or runtime state is adopted.

Recognized structural door tags follow DFU's explicit tags and 72100 exception.
RMB door styles 0–4 map explicitly to model IDs 9000–9004; invalid styles reject
instead of using DFU's modulo fallback. No model-origin correction is adopted.
Unresearched required action kinds reject; unsupported RDI/FOO entries remain
inventory records. Raw unused fields are retained instead of guessed gameplay.
Unknown required action axes also reject; DFU's special TRP/LID/WHE runtime
rotation hacks are not applied. MAPS named-building pools remain separate raw
inputs, not automatically assigned by type/enumeration order to durable buildings.

The user explicitly authorized the required media decoder extension on 2026-11-22.
`classic-texture-transparent-runs-v1` is qualified against TEXTURE.210's 30 records /
83 frames using independent pixel hashes/extents. Raw offsets, dimensions, flags,
scale and unused bytes remain preserved. No classic texture image is shipped;
only source metadata/hash/numeric observations and project-authored PNG fixtures
are used. The rendered index-grayscale preview is diagnostic, not original color
or animation timing qualification. See scripts/data/LAYOUT_INPUTS.md and
MEDIA_DECODERS.md for format boundaries and named real-owner gates.

## IMP-061 increment-1 geometry annotations

`dungeon_assembly.json` is project-authored structural metadata for the exact
observed `place-00032` (Ruins of Cyeghtan Manor) edition. It contains fourteen
explicit connection declarations and input guards, not classic geometry bytes.
`tests/dungeon_source_observation.json` records source file/block/model hashes,
stable placements/records and independently computed transformed dimensions and
plane vectors. The read-only observer is `tools/observe_dungeon_assembly.py`.
Source edition is identified by hashes, not an unverified retail-version claim.

The shared geometry scale is now deliberately 0.025 metre per source layout unit,
with explicit Godot frame/angle/winding rules in `scripts/loc/DUNGEON_ASSEMBLY.md`.
This supersedes the earlier DATA-only absence of engine conversion; it adopts no
motor size, placement correction, world rebase threshold or source-file mutation.
DFU's MIT-licensed `RDBLayout.GetModelMatrix`/`MeshReader` remain behavioral evidence;
the included DFU license is retained. No new third-party code/library is introduced.

All source doors in the fixture remain present. No DFU 1.4-unit or enumeration
order duplicate rule is adopted. Synthetic authored duplicate relationships and
project-authored GLB stair geometry qualify owner interfaces, not a universal
classic correction. Actual action/QUEST/SAVE state and actor placement remain
unavailable. Initial candidate `place-00016` was explicitly rejected for a solid
proposed seam; its failed evidence is retained rather than substituted at runtime.

## IMP-061 increment-2 palette/environment annotations

`dungeon_context.json` is project-authored, source-guarded metadata for the same
place-00032 edition. Baseline slots 119/120/122/123/124/168 and explicit climate
archive groups follow DFU DaggerfallDungeon/DungeonTextureTables/MapsFile (MIT;
DFU_LICENSE.txt retained). Slot 74 climate bindings are explicit data. Default
classic six-slot mapping is retained; opt-in selection deliberately uses stable
SHA-256 of destination identity/climate/configuration/definition, rather than
DFU's historic site seed algorithm or exact vanilla values. Pools and overrides
remain replaceable through normal layout contributions. No source file changes
or classic pixel payloads are shipped.

`tests/observe_dungeon_context.gd` independently reads raw source bytes for
model67019 UVs/planes, texture120/123 record3 RGBA hashes, PAL.PAL and complete
file hashes, source environmental markers and transformed geometry/probes.
Flat199/10 sound/magnitude interpretation follows DFU DaggerfallBillboard.Start;
source sound zero is absence10000, otherwise native height=-8*sound. Treasury
role S0000161 follows DFU PlayerEnterExit.SpecialAreaCheck and is guarded by exact
block SHA. Its metadata also declares water7.2m; W0000000 declares12.4m.
S0000040 declares castle and dry sentinel. These are deliberately isolated
supported real-block test layouts, not automatic extents for the full corpus.
Native extents/anchors/consumer-use declarations and test PNG/bridge are project
authored. Classic UV pixel units and opaque model palette-index-zero handling
follow DFU MeshReader/DaggerfallMesh. No new library or copied implementation
source is introduced. See the increment-2 evidence for editions and limits.

## IMP-061 increment-3 marker and unknown-action metadata

User-authorized PROJECT-DATA-D02 preserves all unknown vanilla action bytes as
non-executing `unused_action` metadata, with pending gameplay-owner readiness.
The full independent corpus observes 13 records: 27x6,32x4,100x2,50x1. No behavior
is guessed and no source payload is changed. Known actions retain required-link
validation; malformed extents, required axes and resource failures still reject.
The DFU enum names these Unknown27/32/50/100 and its inspected dispatcher has no
handlers for them. Existing retained DFU MIT licensing applies to that read-only
source evidence; implementation is separate GDScript.

The first unknown-action extension's layout profile SHA-256 was
`fd562348b60af17df54ddbe33b393fcd239aeb3e9b6e2bd1d1aaa844ac9ff00f`.
All previous identities/buildings/placements are unchanged. Twelve newly supported
blocks receive 3,350 explicit new record keys (618,798 total reserved object keys).
The one-time authoring flag `--allocate-newly-supported-actions` permits allocation
only for previously empty ledgers rejected for unknown action interpretation,
under the exact pinned source edition; other missing identities still reject.
At that stage qualification was 920 RMB/178 RDB, with nine RDB axis rejections.
The following user-authorized axis extension supersedes those rejections.

### Exceptional motion axes — 2026-11-23 follow-up

All 187 original RDB blocks now structurally decode. Independent source inventory
finds 11 exceptional rotation/translation axes across the nine formerly rejected
blocks. DFU `RDBLayout.GetRotationActionVector` special-cases TRP/axis-13 to
NegativeX, magnitude 400 (raw magnitude 392 retained); both generic vector helpers
leave unrecognized axes at zero motion. These are interpretation annotations,
not running actions. Known action kinds/links remain intact and gameplay-owner
readiness remains pending. No blanket axis masking or invented motion is used.
The same retained DFU MIT license covers source evidence; recreation code is
separate GDScript. Source data is unchanged and annotations follow the resolved
classic definition; externally replaced authored records retain their own rules.

Current profile SHA-256:
`1856fd83d96f96505091b540e9c3d78ffb9e5be8b9fa96a670860770f1f86b23`.
All 618,798 prior object keys and all building/location/placement identities are
preserved. Only N0000007's formerly empty ledger receives 307 new record keys
(619,105 total). `--allocate-newly-supported-axes` permits this only for an empty
ledger whose prior diagnostic was the specific unsupported-axis rejection, under
the exact source hashes. Eight other blocks already had reserved record keys.
Qualification is now 920 RMB/187 RDB; RDI auxiliary entries and the extensionless
entry remain non-layout data. Full RDB corpus coverage is maintained by
`classic_action_axes_audit.gd` and `classic_unknown_action_audit.gd`.

`dungeon_arrivals.json` contains explicit project-authored, replaceable route,
landing/facing and exterior-context annotations for Cyeghtan and Privateer's Hold.
It ships numeric metadata, IDs/hashes and provenance, not classic payload bytes.
The existing 0.025-metre frame is reused. Independent complete marker observations,
Privateer's Hold's five original placements/365 model bounds and cave model60200
floor witness qualify the source geometry inspection. They do not certify full
story connections, actor clearance, exterior geometry or gameplay entry.

Privateer's Hold's cave anchor is source199/8 at [510,-25,1672] in S0000999.RDB,
placement-00001/record-00216, converted [12.75,0.625,-41.8]. The user specifically
allowed DFU north-facing as a documented baseline difference. No original-executable
facing/behavior verification is claimed; source flats contain no orientation.
Ordinary baseline north-facing is explicit authored policy. Exterior mappings
currently resolve only the verified MAPS exterior layout/placement context;
static-door association/geometry/traversal remain pending IMP-013/025.
