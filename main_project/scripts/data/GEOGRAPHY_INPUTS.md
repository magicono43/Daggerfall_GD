# Geographic inputs and coordinate handoff — v1

IMP-010 increment 1 / DATA-004/006. Godot 4.7.2, Windows first. This contract
implements GAD-01/07/10, DATA-001/002/003 and PROJECT-DATA-D01. WORLD-006-D04
supersedes all older single-location occupancy wording. Layouts and variants are
not implemented by this geography adapter. Layout structural access is separately
defined in [LAYOUT_INPUTS.md](LAYOUT_INPUTS.md). No geography read establishes opening-content, geometry,
collision, placement, discovery gameplay, weather, SAVE compatibility or M1 readiness.

IMP-061 increment 1 separately consumes dungeon geometry through the named
[LOC geometry frame](../loc/DUNGEON_ASSEMBLY.md). This does not change geography
identity, sampling, world-origin ownership or the remaining WORLD/MOVE gates.

## Registration and publication

Normal startup calls `enable_geography_inputs()` before classic preparation.
`geography_inputs.gd` declares MAPS.BSA (`bsa-v1`), WOODS.WLD
(`woods-source-v1`), CLIMATE.PAK and POLITIC.PAK (`geography-pak-v1`). MAPS shares
the existing application BSA reader. This geography adapter leaves BLOCKS
undecoded; the sibling layout adapter performs its structural decoding on demand.
No installation search, replacement installation or fallback data exists.

The shipped-tier adapter reads its pinned profile with `FileAccess` at
`res://content/geography/profile.json`, including inside exported PCKs. Source
records come from the application classic registry. The profile qualifies one
observed edition, not all possible Daggerfall editions. Structurally valid
unknown editions require an explicit mapping profile and return `unsupported`;
they never receive guessed durable IDs. Basic container/source checks remain
distinct from this required index qualification. Detailed exterior/dungeon
decoding is deferred to later increments. No entire world/layout is constructed.

The existing DATA/MOD/CORE transaction applies shipped → checked ordered folder
and ZIP content → captured loose `Overrides/`. Required resources and final
references validate before actual main-menu publication. Invalid contributions
roll back as whole files; omission is explicit and cannot waive remaining required
references. Candidates rebuild from clean state with new tickets. CORE reserves
the exact candidate, checks the menu, persists profile/history, then publishes
and locks. No new post-durable callback, parallel registry or package execution
exists. External source/loose edits and changes after menu require restart.

Geography retains only derived lookup keys/context under the current candidate
ticket. `finish_candidate` clears them on any candidate failure.
`definition_registry.domain_index` exposes their detached projection only after
that exact ticket is published; search then queries each selected record from
the authoritative registry. Sampling reads just the context and selected tile.
Neither path copies/revalidates every actor/location/quest on each read. Cached
baseline bytes are reused only after rechecking the shipped profile and all four
external source hashes; final contribution resolution and indexes rebuild cleanly.

## Stable identity and geographic indexing

Domain: `geography.inputs`; schema/adapter `geography-inputs-v1`. Logical paths
are `packs/<origin package ID>`; baseline `packs/classic`, loose additions
`packs/loose`. Registry identities contain `domain`, originating `package`,
`local=<logical path>#<ID>` and `record`. IDs are author-assigned strings, with no
global numeric allocation requirement. Explicit replacements retain identity and
track field winners/contributors separately. Baseline `place-NNNNN` IDs were
allocated once in the checked profile; their spelling is not a runtime ordinal
formula. The observer refuses to overwrite a different profile. New editions
require curated mappings preserving existing identities.

Logical definition references use exact `path#ID`, validated against final typed
records. Durable consumer references use the full registry identity via
`resolve_identity`; a different origin at the same path never retargets that
reference. `lookup` reads an exact path/ID; `search` returns arrays for pixel,
exact display name or explicit mapping. Names/localization/order/offsets cannot
select durable identity. Missing lookups never choose nearby pixels or similar
names. Duplicate names are legal. Pixel indexes contain zero or more locations,
with no occupancy cap. Terrain coverage is not a location. Moving a definition
changes current authored geography, preserving original source position and
classic mapping. It does not move a player or certify an old interior/pose.

Mappings are separately scoped strings under `selected-classic-v1/`:

| Kind | Mapping | Meaning |
| --- | --- | --- |
| region | `region/<ordinal>` | Explicit selected-edition region mapping |
| location | `full/<uint32>` | Full encoded map value, not masked or a coordinate |
| location | `pixel/<key>` | Original coordinate key `y*1000+x`; not current position |
| location | `quest/<region ordinal>/<uint16>` | Region-scoped classic quest-location ID |
| climate | `climate/<byte>` | Explicit source code to climate definition |

Quest ID zero is an absent optional mapping, not a missing location. Source
ordinals, MAPS record names/physical offsets, quest-header offsets, full map
values and coordinate keys remain distinct. Duplicate explicit mappings fail
final validation. Added locations may have no classic mapping.

## Binary format inventory

All integers below are little-endian. Source files open READ only. PAK/WOODS
readers bound intake to 64 MiB; they close files after preparation, retain decoded
indexes/coarse grids, reopen for later access, verify source length and return
detached copies. Same-length edits are outside the supported run-long source
contract; the reader is not a concurrent filesystem snapshot. Preparation pins
source hashes before identity assignment. Later unreadable/truncated cell reads
return explicit failures. `close` retires access. No file mutation API exists.

| Format | Fields and bounds | Interpretation / retained unused values |
| --- | --- | --- |
| MAPS BSA | Existing checked named BSA; selected profile 248 entries / 62 region groups | Four records per region: PItem, DItem, table, names. Geographic reader uses names/table and the minimum PItem quest header; no DItem/block assembly |
| Names | u32 count, exactly count × 32 fixed bytes | ASCII printable names, NUL terminated or full-width; no first-name identity selection |
| Table | Exactly count × 17 bytes: full u32 map, packed u32 longitude/type/discovery, packed u32 latitude, u8 dungeon, u32 key | longitude=`(bits & 0x1ffffff)>>8`, latitude=`(lat & 0xffffff)>>8`, type=`(bits>>25)&31`, source discovery bit 30. Entire 17-byte table hex retained, including unused bits/key; codes are structural classifications, not gameplay interpretation |
| PItem geographic header | count u32 relative offsets; record starts after offset directory; u32 door count; skip count × 6 door bytes then 33 bytes to u16 quest ID | Checked byte extents; preserve PItem/header address. Door/marker/action contents are explicitly unsupported here |
| WOODS | 144-byte header; u32 index byte count/width/height, unused/header words, coarse offset at byte 28; 500,000 u32 cell offsets | Selected classic dimensions 1000×500, index bytes 2,000,000. All detail extents checked; coarse grid has 500,000 u8 source samples. Header/unknown words remain raw, without generation rules |
| WOODS cell | 22 unused metadata bytes then 25 u8 detail samples | 5×5 row-major raw source order; preserve metadata and physical offset. Height unit is `classic-height-u8`, **not metres or motor units**, range 0–255, including zero |
| PAK | 500 u32 row offsets, contiguous rows, 1001 output samples each; runs u16 count + u8 value | No zero runs, overruns, gaps, overlaps or truncated rows. Selected CLIMATE ends at the rows; selected POLITIC has an unused attribution trailer recognized only by exact SHA-256 `3da1f0ca3871dbfd542cdd2f1f238e4fcd9f0025674023d7759c94a1108137d9`; other trailing bytes reject |

CLIMATE codes 223–232 map to explicit definitions: Ocean, Desert, Desert2,
Mountain, Rainforest, Swamp, Subtropical, MountainWoods, Woodlands,
HauntedWoodlands. No default-temperate branch exists. POLITIC remains a raw
code: 64 is no region; 128+ordinal is the classic region encoding. Location
authored membership comes from its region definition, not a silent politic
reassignment. Climate categories do not establish weather/AV effect support.

## Authored schemas, operations and extension coverage

Every value has `schema`, `kind`, complete typed `data`, explicit `mappings`, and
an optional verified shipped `input` receipt. Unknown fields/kinds fail.

| Kind | Required data |
| --- | --- |
| region | nonempty `name` |
| location | nonempty `name`, exact region reference, two integral `position` pixels, encoded `type` 0–31 and `dungeon` 0–255, explicit `initial_discovery`; baseline also immutable `raw` and `layout_source` |
| climate | `name`, `interpretation=authored-climate-category-v1`, nonempty category; real consumer interpretation remains unavailable |
| context | `frame`, `unit`, half-open `bounds=[minX,minY,maxX,maxY]`, complete `tiles` references |
| classic_samples | checked classic profile, exact source bounds, ten explicit climate references and raw politic annotation; verified source receipt required |
| samples | half-open bounds, `unit=classic-height-u8`, `layout=row-major-north-down-v1`, full `heights`, `climates` references and 25-byte-per-cell raw `detail` arrays |

`add` requires unused path/ID, in the originating package path. `replace` replaces
the entire resource record set; matching IDs retain identity. `patch` replaces
supplied top-level fields as wholes; omitted fields remain. `data` is a complete
typed object, not a deep merge. Arrays replace wholly. Null and deletion have no
meaning. Patch cannot alter schema/kind/mappings/receipts. Explicit resource
replacement can declare mappings, subject to final uniqueness/reference checks.
Baseline kind/source receipt and raw coordinate/layout facts remain unchanged.
Authored fields including name, position, membership and discovery value may
change. Source changes never overwrite later mod/loose values through a correction.

There is one required context at `packs/classic#extent`; expansion replaces its
data and supplies coverage tiles. This is a versioned single-world contract,
not independent worlds or portals. Bounds are integral, half-open, each coordinate
within ±1,000,000 and area at most 4,000,000 pixels. Tiles must lie inside the
context, not overlap, and sum to its exact area. Their schemas require every
height/detail/climate sample. All location positions must be inside. Missing
interior data, incomplete extensions, unresolved climates/regions/tiles and
ambiguous mappings fail. Classic dimensions/PAK adjustment never apply to
authored tile coordinates. Required future consumers must separately validate
their supported extents and climate semantics before gameplay readiness.

## Coordinate and sampling handoff

Frame `geography-pixel-north-down-v1`, unit `map-pixel`: X east, Y south, integral
pixel queries, active data-defined half-open bounds. Classic adapter bounds are
[0,0,1000,500]. Raw longitude/latitude frame `classic-longitude-latitude-v1`,
unit `classic-map-tile`: X east, latitude north, bounds [0,128000)×[0,64000).
Positive integer division floors: pixel X=longitude/128, Y=499-latitude/128.
`Formats.convert` returns that pixel plus exact `[longitude%128,latitude%128]`
remainder in `classic-map-tile-north-up-v1`; `source_from_pixel` reconstructs the
source exactly (zero tolerance). The remainder is retained separately so a caller
cannot accidentally floor a reversed continuous Y and choose a different pixel.
No Godot scale, axis-to-motor transform, sea level or placement correction is
chosen. Any requested engine/local physics conversion returns
`unsupported_conversion`; real WORLD/LOC/MOVE fixture gates remain unavailable.

`sample(registry,x,y)` rejects ordinary outside queries. Explicit
`clamp_edges=true` is only for interpolation neighbors and reports requested vs
sampled pixel and whether clamped; it cannot retarget a destination. Only outer
bounds clamp. A missing tile/interior sample fails. A successful sample supplies
coarse source byte, raw detail, climate stable reference, frame/units and winning
source. Classic sampling reads CLIMATE/POLITIC at `[x+1,y]`; authored grids use
their declared coordinates with **no** shift. `detail_neighborhood` is explicitly
the classic 3×3 inner extraction: source `[x,4-y]` for x,y=1..3. Raw 5×5 data is
unchanged; this function is not a universal mod grid reversal or terrain algorithm.

The independent source observation pins both edges, nonuniform raw detail and an
actual climate transition with different raw/aligned values. Synthetic vectors
qualify rejection and schema rules, not actual installation availability.

## Discovery and remaining owners

Initial discovery is `{value:bool,policy:source-flag-v1|authored-v1,
classic_behavior_verified:false}`. Source flags are a usable, replaceable baseline,
not verified classic gameplay behavior. DFU `ContentReader.EnumerateMaps` has a
forgotten-graveyard TODO; the selected source contains 583 undiscovered and 191
discovered type-12 graveyards. The TODO's `GraveyardForgotten` enum is absent in
the inspected DFRegion enum; its type 13 is Coven, not a verified forgotten-graveyard
mapping. No executable behavior evidence establishes a further automatic correction,
so none is invented.
Reads/rebuilds do not change character history. Real WORLD/UI discovery policy,
SAVE restoration/new-content handling, physics, terrain generation, layout/door/
marker/action decoding, variants and quest execution remain with later owners.

## Dungeon presentation consumer

IMP-061 increment 2 resolves the declared destination site's validated identity
and position, then samples that destination's climate through this adapter.
Player GPS/current-origin climate never participates in dungeon palette selection.
No geography data or coordinate ownership changes.
