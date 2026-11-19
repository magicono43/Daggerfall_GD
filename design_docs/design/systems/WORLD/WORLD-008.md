# WORLD-008 — Height sampling and detail

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Provide consistent, traversable terrain with recognizable stock landforms and coastlines. Revisiting an unchanged area yields the same ground. Settlements, approaches and standalone terrain features fit their surroundings. Mods can author a different geography and terrain detail.

## Confirmed requirements

- **WORLD-008-D01.** Preserve the broad stock geography implied by the classic source samples. Use deterministic world-coordinate interpolation and detail without requiring exact DFU output. Let mods supply altered geography, height data and terrain detail through validated content.
- **WORLD-008-D02.** Support authored footprints and blend margins for settlements and standalone features. Allow independent edits within one map pixel and require an explicit composition or override rule for conflicting edits.
- **WORLD-008-D03.** Constrain stock detail around shorelines, entrances and authored approaches to preserve intended traversal. Allow mods to reshape those areas intentionally through validated overrides.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-008-interview-decisions) records these decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to `Assets/Scripts/`.

- `API/WoodsFile.cs` supplies coarse heights and local height neighborhoods. `Terrain/DefaultTerrainSampler.cs#ScheduleGenerateSamplesJob` reads both neighborhoods and schedules per-sample generation.
- `DefaultTerrainSampler.GenerateSamplesJob.Execute` uses cubic interpolation in both axes, combines scaled coarse and local heights, adds the product of two coordinate-based noise samples, clamps low heights to its ocean elevation and normalizes the output.
- `Terrain/DaggerfallTerrain.cs` schedules a location blending pass when the sampler has not already blended the terrain. `Terrain/TerrainHelper.cs#ScheduleBlendLocationTerrainJob` flattens a location footprint and blends it into surrounding terrain.

## Detailed rules and behaviors

1. Resolve validated geography and terrain sources through DATA-006 and MOD. Stock content uses the classic source samples. A mod can override or extend the geographic baseline, supply different heights and specify different detail inputs through supported terrain definitions. Keep source data, interpreted samples and generated heights distinct.
2. Sample the resolved terrain in a stable world-coordinate frame. Identical inputs and generation versions yield equivalent gameplay heights across build order, streaming, origin shifts and native load. Resolve shared sample positions consistently at cell edges and corners. Use DATA-006's explicit clamped sampling only where supported at the declared world edge. Missing required interior samples follow validation or recovery.
3. Allow a settlement or standalone feature to preserve existing ground or declare a height edit with its own authored footprint and blend margin. Support multiple edits within the same pixel and across seams. Evaluate affected terrain against the same resolved edit set. Overlap must have an explicit composition or override rule. Reject unresolved conflicts rather than deriving precedence from job completion or scene activation order.
4. Limit stock procedural detail where it would change intended shoreline connections, obstruct an authored approach or invalidate an entrance. Preserve the intended ground and water relationship under their owner rules. Validated overrides can deliberately alter those relationships, with associated route and placement dependencies revalidated.
5. Expose generated heights and compatible collision for the same terrain revision. WORLD-004 governs readiness and recovery, and WORLD-009 governs job and seam publication. Incomplete or incompatible required terrain cannot supply playable coverage.

## Relevant formulas, parameters and configuration

Conceptual evaluation starts from interpolated resolved source heights, applies deterministic detail subject to terrain constraints, and resolves declared height edits and blends. Concrete interpolation, scale, detail amplitude, shoreline constraints, blend functions, precedence representation and sample tolerances remain open. DFU constants are reference values. Mods may configure supported geography, height and detail inputs and author intentional footprint or shoreline edits.

## Required data

Validated world extent and coordinate conversion, coarse and local height inputs, terrain profile and generation version, deterministic detail inputs, water and protected approach constraints where required, authored footprints and blend margins, overlap and override information, and content provenance.

## Inputs, outputs and events

- **Inputs** — Resolved geographic samples, terrain profile, sample coordinates, applicable edits and constraints, and request and content identity.
- **Outputs** — Terrain heights and source/version provenance, or an explicit invalid, unavailable or conflicting input result.
- **Events** — Generation completion is distinct from collision and area readiness. WORLD-009 and WORLD-004 own publication timing. Public APIs remain open.

## Cross-system interactions

- **DATA-006 and MOD** resolve geography, samples, extents and valid overrides. **WORLD-001/002** supply coherent geographic conversion across engine-local origin changes.
- **WORLD-004/005/009** consume terrain data for coverage, residency and coherent seam activation. **WORLD-010/011 and AV** consume heights for terrain presentation.
- **WORLD-006, LOC and MOVE-027** supply exterior footprints and placement constraints. Water and movement owners validate resulting traversal. **CORE/SAVE** coordinate compatibility and recovery.

## Edge cases and failure conditions

- Test shared edges and corners built in different orders, including a footprint or blend margin crossing the boundary.
- Test nearby settlements and a standalone terrain feature in one pixel. Unresolved overlapping edits must produce a validation result. Declared composition must yield the same height regardless of load order.
- Test stock shoreline connectivity, approach clearance and entrance placement with procedural detail enabled. Test an intentional modded change with its dependent routes and placements.
- Test expanded map extents, missing interior samples and an obsolete generation result after content or context replacement.

## Save/load considerations

Rebuild generated heights from compatible terrain inputs and versions. Treat generated cells as runtime data. Native load validates compatibility of required terrain and saved location/pose semantics through CORE-013 and MOVE-027. Changed geography may require validated migration or explicit recovery. A new terrain revision cannot silently reinterpret the saved placement.

## Technical constraints

Target Godot 4.7.2. Evaluate terrain in world coordinates independently of engine-local origin. Validate height agreement for rendering, collision and position queries. Exact numeric representation, sampling and seam tolerances, terrain authoring formats and job scheduling remain open.

## Acceptance criteria

1. Stock terrain preserves broad source landforms and coastline. Unchanged terrain rebuilds consistently across streaming, rebasing and native load.
2. A validated mod can override stock geography and detail or extend the map with complete required terrain data.
3. Independent same-pixel and cross-pixel edits work. Explicit overlaps resolve deterministically, and unresolved conflicts fail validation.
4. Stock detail preserves intended shoreline connectivity and authored access. Intentional mod edits are validated with affected dependencies.
5. Shared edges agree within the verified gameplay tolerance, and incompatible or incomplete required terrain cannot report readiness.

## Outstanding questions

- Define stock interpolation and detail profiles, representative geography fixtures and measurable coastline and seam tolerances.
- DATA/MOD and LOC need terrain edit formats, composition rules, footprint authoring and diagnostic details.
- Define water and approach constraints with the relevant owners and validate native pose compatibility when terrain changes.
