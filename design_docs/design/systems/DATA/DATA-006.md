# DATA-006 — Terrain and climate data

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Supply source geography, terrain samples and shared climate definitions for outdoor world construction and its consumers. Preserve the classic geographic baseline while permitting validated mod extensions beyond original map dimensions.

## Intended player experience

Original content retains its source geography and climate assignments. Supported mods can add terrain/map areas with complete required data. Terrain, locations, climate lookup and map/travel systems agree about the loaded world's extent. Invalid data produces truthful failure rather than silently creating flat land, default climate or an unintended destination.

## Confirmed requirements

DATA-006-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm classic source samples/climate as an overridable baseline; WORLD-owned terrain generation; climate separate from weather/season; data-defined extensible world bounds and explicit clamped interpolation; validation of climate codes; shared climate identity with owner-defined effects; complete extension inputs; a shared extent/coordinate contract; and pre-menu resolution followed by a run-long content lock.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `API/WoodsFile.cs#GetHeightMapValue` reads byte height samples from WOODS.WLD and clamps coordinates to its map limits. Range methods build neighborhoods from these samples.
- `WoodsFile#GetLargeMapData` reads a 5×5 source grid for a map pixel, also clamping coordinates. `GetLargeHeightMapValuesRange` extracts a subset and reverses Y ordering. Raw map data and interpreted sample neighborhoods are distinct representations.
- `API/MapsFile.cs#GetClimateIndex` reads CLIMATE.PAK after adding one to map X to align with the height map. `GetWorldClimateSettings` maps classic climate codes to settings including climate category, ground/nature archive and sky inputs; its default branch supplies temperate-style settings for unhandled codes.
- `Terrain/DefaultTerrainSampler.cs` bicubically interpolates coarse/detail samples, adds coordinate-based procedural noise, clamps low elevation to its ocean threshold and normalizes terrain heights. Its constants describe that sampler, not unmodified source heights.
- `Terrain/TerrainTexturing.cs#DefaultTerrainTexturing` derives terrain tiles and transitions from generated heights and thresholds. Runtime terrain and texturing are consumers of DATA, not raw sample identity.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; map-edge, coastline, source-orientation and runtime fixtures have not been tested in this specification phase. Source remains unchanged.

## Detailed rules and behaviors

### Source baseline and generated terrain

Preserve classic source height samples and climate assignments as the original-content baseline, allowing explicit validated overrides. Keep raw/source samples distinct from interpreted neighborhoods and generated runtime heights. This does not require reproducing DFU's exact procedural terrain output or using its scale/noise constants.

WORLD's later specification may choose interpolation, small-scale detail, coastline treatment and location-ground fitting while respecting approved source geography and location placements. WORLD owns generated terrain and continuity; LOC owns location assembly; DATA supplies interpreted source data and explicit conversion context. Terrain algorithms, shoreline rules, sea level, location flattening and surface collision are not selected here.

### Loaded-world extent and expansion

World bounds describe the particularly loaded world's declared data extent, not permanent classic map limits. Support mods adding/extending terrain and maps through validated definitions. Original dimensions and coordinate-derived identifiers remain classic dataset/adapter details; they must not silently cap otherwise supported expanded areas.

Terrain, climate lookup, location placement and map/travel consumers must share the declared world extent and coordinate convention. DATA-004 stable region/location IDs remain separate from classic pixel-ID formulas, and its initial one-location-per-pixel occupancy rule remains intact. This extension policy does not approve multiple locations at one pixel, unlimited practical world size, multiple independent worlds or portals.

Added areas must supply height data and valid climate assignments required by their consumers. Reject incomplete required areas rather than silently filling missing data with flat terrain or a default climate. Missing optional domain content uses only explicitly supported owner fallback. Expansion format, extent representation, coverage validation, overlaps and practical supported limits must be specified with the affected systems before implementation is complete.

### Queries and boundary sampling

Reject out-of-bounds geographic queries by default against the active declared extent. Do not silently turn an invalid destination into an edge destination. Distinguish out-of-bounds input from a valid location without a named settlement, missing required samples, unavailable sources or malformed data.

Provide explicitly clamped sampling for terrain interpolation requiring neighbors beyond the declared map edge. The caller must request that behavior; it does not enlarge the world or create valid travel destinations. Do not treat a missing interior sample within declared coverage as an out-of-bounds neighbor eligible for silent clamping.

Coordinate orientation, sample layout and climate alignment must be explicit in adapters. DFU's one-pixel climate shift and reversed sample grids are reference behaviors to verify, not blanket offsets to apply to every new mod format. Validate intended geographic alignment and edge behavior with fixtures.

### Climate identity and definitions

Climate is authored geographic data, separate from current weather, season and temporary presentation. Expose common climate identity/definitions to terrain, weather and presentation consumers; each owns its resulting effects. DATA does not determine weather probabilities, gameplay modifiers or rendering behavior.

Every used climate code must resolve to a supported climate definition or explicit validated mapping. Unknown required codes fail rather than silently becoming temperate. Mods may introduce climate codes through supported definitions, subject to consumer requirements and reference validation. Merely declaring a code is insufficient if required consumers cannot interpret its definition.

Weather and season do not rewrite the underlying climate definition. Explicit content overrides may change it under the content-resolution/activation rules. Stable climate identity and legacy code mappings need a documented domain schema; the integer representation and full effect vocabulary are not approved here.

### Resolution, activation and failure

Resolve terrain/map extensions during DATA-003's editable pre-menu configuration stage. Continue rebuilds and validates the candidate; failed validation retains recovery rather than entering the actual game main menu. Publish a coherent extent/sample/climate definition set, not an extent that advertises missing required coverage. Follow DATA-003's declared operations, contribution order, whole-contribution rejection and explicit omission choice only when the remainder validates.

Entering the actual game main menu locks the selected content configuration, including world extent, for the application run. Reordering/enabling mods before entry follows DATA-003 without requiring a restart for those data-plan changes. Extent changes after entry and external classic/loose-file edits require application restart. Changes must not leave stale extent/climate/sample caches from earlier candidates. Active classic-reader/source replacement retains DATA-001/002 and CORE-004 restart rules.

Required sources and basic indexes retain DATA-002's before-menu readiness gate. This policy does not mandate decoding every terrain record at startup. Later actual read/decode failures remain explicit and use WORLD/LOC/CORE or other consumer recovery, without synthesizing successful default data. Basic DATA-001 validation alone does not certify full geographic coverage or every sample.

## Relevant formulas and parameters

No new gameplay balance formulas, world dimensions, Godot units, terrain resolution, sea level or noise parameters are approved. DFU source values and sampler constants are observations rather than target requirements. Geographic validity uses the loaded world's declared extent; interpolation clamping is a separately requested operation. Exact coordinate bounds, sample spacing, axis orientation, rounding and conversion tolerances remain technical contracts to verify.

## Required data

Loaded-world extent and coordinate convention; sample coverage/layout and raw height/detail inputs; interpreted sample mappings; climate assignment grid and identity/definition registry; classic climate/coordinate mappings; package/source provenance; validated extension/override plan; failure context; cache source/configuration context. Generated runtime heights, current weather/season and character mutable state remain separately owned. Exact schemas, supported extent limits and climate consumer fields remain dependencies.

## Inputs, outputs and events

Inputs: classic geography/climate files, validated definitions/extensions/overrides, geographic/sample queries, explicit edge-clamp requests and candidate validation. Outputs: source samples, interpreted neighborhoods, climate definitions/assignments, shared extent/conversion context and explicit out-of-bounds/missing/unavailable/invalid outcomes. These are conceptual contracts, not concrete APIs or signals. A climate query does not advance weather, change seasons or publish world readiness by itself.

## Cross-system interactions

- DATA-001/002 retain read-only sources, basic checks, required-reader/index readiness and differentiated failures. DATA-003 owns contribution ordering, pre-menu resolution and run-long lock.
- DATA-004 supplies stable location identity and geographic placement. Extended coordinates must not alias classic coordinate-derived keys or silently violate its occupancy rules.
- WORLD owns generated terrain, streaming, interpolation and geographic runtime context. LOC uses compatible ground/placement context for authored locations and block geometry under DATA-005.
- TIME/weather own current conditions and calendar effects; AV owns visual/audio realization. All use shared climate definitions without independently assuming classic-only dimensions.
- UI/map/travel owners use the same extent/conversion context and retain destination eligibility and presentation policies. This feature does not promise map UI or travel formulas are already designed for expansion.
- SAVE checks compatibility with content/terrain definitions and saved location/pose; stable identity alone cannot validate a changed surface. MOD owns packages, dependencies and executable lifecycle.

## Edge cases and failure conditions

- A mod extends beyond original dimensions: evaluate against the new validated extent and coordinate rules rather than hard-coded classic bounds. All required consumers must support that extension contract.
- The declared extent grows without required height/climate coverage: reject the incomplete candidate; do not generate flat/default filler.
- An interpolation neighborhood crosses an outer edge: explicit clamp may reuse boundary samples. A normal out-of-bounds geographic query still fails.
- An interior required sample is absent or malformed: return an actual data failure, not a clamped sample or zero elevation.
- A used climate code is undefined or lacks a required consumer mapping: report invalid required data rather than applying a silent temperate default.
- Neighbor/sample orientation is reversed or climate shifted incorrectly: alignment verification must catch this; visual plausibility alone is insufficient evidence.
- A pre-menu candidate changes extent/climate: rebuild affected indexes/caches coherently. Returning from gameplay does not unlock the content plan.
- Terrain or climate changes under a stable location ID: SAVE/WORLD/LOC must validate restored pose/layout compatibility; do not automatically move the player or claim compatibility from identity alone.

## Configuration and balancing options

Validated mods may extend terrain/map data and climate definitions before entry. No player-facing option to bypass required coverage or silently accept unknown climate codes is approved. WORLD/AV/weather owners select their future generation, visual and balancing parameters; DATA preserves source inputs and supported extension contracts.

## Save/load considerations

Source definitions and disposable generated caches are separate from character-save state. Saves do not change the locked active extent or climate definitions. SAVE/WORLD/LOC must establish content/generation identity and compatibility for saved locations, poses and terrain changes. Current weather/season and any supported mutable terrain state follow owner save schemas; this feature does not introduce terrain editing or approve a snapshot/migration format. Recreating cached terrain is not proof the resulting surface matches an older save.

## Technical constraints

Target engine: Godot 4.7.2. Keep classic source decoding, extensible world metadata, generated terrain and temporary conditions separate. Use explicit conversions and shared world context; retain read-only original inputs. Classic formulas and byte formats must not become universal bounds/identity constraints for new content. Concrete registry, schema, cache, threading and rendering choices remain deferred. Broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Original source height samples and climate assignments remain the baseline, with explicit validated overrides and separation from generated heights.
2. WORLD can later select terrain algorithms within approved geography/location constraints without being forced to copy DFU procedural output.
3. Climate identity/definitions are shared across consumers; weather/season/temporary visuals remain independent state under their owners.
4. Geographic bounds derive from the loaded world and support validated mod expansion; classic dimensions alone do not reject supported new areas.
5. Required extension height/climate data is complete under the declared schema. Incomplete required coverage fails without flat/default filler.
6. Geographic queries reject out-of-bounds input by default. Explicit interpolation clamping works at outer boundaries without masking missing interior data or changing destinations.
7. Every used climate code resolves through a supported definition/mapping. Unknown required codes fail explicitly; validated new definitions are supported.
8. Terrain, climate, location placement and map/travel consumers agree on extent and coordinate alignment, verified against representative edge/coastline and conversion fixtures.
9. Pre-menu extension resolution validates and publishes coherently, then locks at actual main-menu entry. Later extent/external-file changes require restart.
10. Source readiness and actual data failures remain distinct. Saves require owner compatibility checks for geographic/terrain changes, and original files remain unchanged.

These are future verification criteria. No implementation, original-data fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–005 and approved CORE startup, lifecycle and restoration contracts. Data-defined extent refines DATA-004's deferred coordinate bounds and preserves stable identity. WORLD-006-D04 allows multiple independently identified locations per pixel. Pre-menu candidate rebuild follows DATA-003, and classic-source restart and reader readiness follow DATA-002. WORLD owns procedural terrain and coordinates with DATA-005 placement fidelity and CORE-011 startup placement. SAVE owns compatibility.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: world-extent/extension and coverage schemas; coordinate/sample orientation/alignment fixtures and bounds rules; climate identity/code/consumer definitions; complete override operations; cross-owner expansion support; WORLD terrain/shoreline/ground-fitting choices; cache/generation identity; SAVE compatibility and migration policy. Practical supported size limits must be declared by implementation rather than inferred as infinite from extensibility.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-006-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including expansion schemas, coordinate verification, consumer support and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.
