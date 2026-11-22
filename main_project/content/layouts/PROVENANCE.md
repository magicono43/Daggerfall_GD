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
