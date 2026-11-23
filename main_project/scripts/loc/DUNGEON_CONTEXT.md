# Dungeon context — IMP-061 increment 2

LOC prepares palettes and checked environmental geometry with the existing
assembly operation. DATA owns definitions, decoded images and variant proposals;
CORE owns session eligibility and activation. No additional startup adapter or
content registry is introduced. Normal ten-adapter startup declares the pinned
classic image inputs before publication. Default presentation configuration is
`{variation:false, version:"dungeon-presentation-v1"}`; no preference UI is added.

## Palette definitions and instances

`dungeon-context-v1` is optional layout data, validated by
`scripts/data/dungeon_context_schema.gd`. A declared context requires the six
classic source slots 119/120/122/123/124/168, fixed/eligible flags, destination
climate pools, explicit overrides, water and areas. A slot is an archive integer
or `{archive, records}` with exact record-to-DATA-image-export bindings. Partial
overrides inherit the selected palette. `climate_bindings` supplies explicit
additional source-archive mappings (including classic slot 74); LOC does not
encode climate archive arithmetic. DATA/MOD/loose precedence and publication
recovery remain authoritative. Selected missing assets fail preparation.

Variation hashes the complete destination site identity, its validated geography
climate, configuration/version and context definition. It never consults player
GPS or draws/reseeds a gameplay RNG stream. Fixed sites retain their baseline;
deliberate validated overrides apply after that policy. All choices are data.
The SHA-256 selection is an isolated deterministic presentation source, not a
claim to reproduce vanilla or DFU's historic visit/seed algorithms.

Classic UVs are source pixels (`uv_sixteenths / 16`), permuted with the same
0/2/1 triangle winding as geometry. AV applies inverse ORIGINAL source dimensions,
even when a substituted archive or PNG has different dimensions. Classic model
textures use the accepted decoder with opaque palette index zero (`alphaIndex=-1`);
DATA image replacements retain their decoded alpha policy. AV packs an immutable preparation-private atlas per effective model/palette.
Each occurrence receives its own atlas texture and one mutable spatial material.
An immutable mesh has one surface, preserving every triangle/normal/pixel-UV tuple
and adding a per-triangle source-binding index in UV2. The shader repeats within
the selected atlas region using ORIGINAL source dimensions, with nearest sampling
and opaque, binary-cutout or blended alpha as appropriate. Independently owned
per-plane/per-binding materials exhausted the default Windows D3D12 descriptor
heap at 64 blocks; a smaller shader and grouping alone were insufficient. The
single-surface/atlas profile completes that real stress case without raising limits.
Atlases allow 1..128 bindings and at most 8192 pixels per axis; exceeding the
qualified profile fails explicitly. Each occurrence owns mutable materials/textures,
while immutable shaders, meshes and collision prototypes stay
shared. Source images are cached only within the exact preparation. Every teardown
detaches meshes before destroying surface materials, avoiding the Godot dummy
renderer surface-override destruction diagnostic without filtering errors.

LOC consumes applicable DATA default/explicit variant proposals and retains their
compatibility receipts. Only unchanged placed records/assembly plus alternate
root context are accepted here. Structural edits return `provider_pending`;
neither generic DATA compatibility nor visual selection grants SAVE migration.

## Water and areas

DATA scans all classic 199/10 metadata records independently of arrival selection:
nonzero sound gives native height `-8 * sound`, zero is absence sentinel 10000;
nonzero magnitude declares castle context. Conflicting observations fail explicitly.
Native height is transformed through the accepted 0.025 m geometry frame.
Classic annotations guard block identity, source SHA, native height/castle and
placement pose. Changed inputs require matching declarations; no broad automatic
water or special-area membership is inferred from an RDB name or horizontal block.

`bounded-depth-columns-metres-v1` uses authored half-open AABBs in the accepted
local metre frame. Water includes pool identity, surface, explicit priority,
source and optionally a submerged anchor. Connected pools require actual solid-free
submerged witness paths between touching cells, identical surfaces, and at least
one free-surface cell. Clipped submerged cells may end below the global surface.
Qualification checks anchor-to-local-top clearance. Positive point queries check
the vertical column and a submerged path to the qualified anchor. Intervening
floors exclude immersion; physically divided equal-height volumes do not connect
by name alone. Distinct overlapping contexts require explicit unequal priorities.
Complex curved/occluded spaces need smaller visibility cells and anchors; an
unproved wet column returns `unsupported_environment`, never invented absence.
This is a bounded representation, not an arbitrary fluid-volume solver.

Areas have explicit vertical bounds and declared consumer uses. Castle and treasury
source fixtures use source-matched geometry bounds. Native areas can span placements.
Membership supplies facts only; AV, LAW, QUEST and other owners decide outcomes.

`spatial_context(ticket, frame, position)` and `environment_projection(ticket)`
return detached checked data under the original active CORE/content/layout scope.
They reject before readiness and after retirement. Point queries use a prepared
spatial index and existing physics, never copy the catalog or rebuild connectivity.
Layout/content/presentation changes stage atomically; cancellation or late failure
preserves the previous active scope. Geometry version excludes context; environmental
version excludes palette; complete context version includes palette, image pixels,
configuration and retained variant inputs. Transient publication tickets validate
access but do not seed fresh-process versions.

## Qualification boundary

The accepted place-00032 eight-placement/fourteen-connection fixture is unchanged.
Additional isolated source-block layouts deliberately exercise W0000000 (water),
S0000040 (castle) and S0000161 (treasury AND water). They do not certify their full
original dungeon, route, return, actors or arbitrary source-corpus extents.
Independent observations, frozen inventories, rendered comparisons and exact run
results live in the increment-2 execution evidence.

All spatial results state `pose_authoritative:false`, `contact_committed:false`
and `events:[]`. Real MOVE committed contact, swimming/breath, entry/splash,
rebase/SAVE restoration, gameplay owner state, structural migration and QUEST/action
execution remain named provider gates. Fresh-process fixture reconstruction is
not native SAVE. LOC-011 arrival/start/return selection remains increment 3.
