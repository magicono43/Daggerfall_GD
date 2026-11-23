# Layout metadata provenance — IMP-010 increment 2

Selected source: explicit `C:/Games/Daggerfall/arena2` BLOCKS.BSA and MAPS.BSA.
Source lengths/hashes, complete archive directories and independent structural
pins are in `tests/layout_source_observation.json`. No classic block/map payload
is shipped or modified. `profile.json` contains explicit edition identities,
source addresses/hashes and qualification metadata, generated once by the
GDScript authoring tool, which refuses an existing output. Unknown editions do
not receive inferred mappings. This profile was user-accepted with increment 2 at `e324d54` on 2026-11-22.
The current profile SHA-256 is
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
