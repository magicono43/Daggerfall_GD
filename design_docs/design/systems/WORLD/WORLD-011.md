# WORLD-011 — Nature placement

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Give landscapes recognizable vegetation that remains where players expect it across visits, origin shifts and loads. Seasonal presentation can change while familiar paths and landmarks remain consistent. Mod authors can add plants and change how they are placed.

## Confirmed requirements

- **WORLD-011-D01.** Generate stable placements from world coordinates and the resolved nature profile. Stock seasons change appearance while keeping placements fixed. Mods can add or change plant placement behavior, including intentional seasonal changes to which plants appear.
- **WORLD-011-D02.** Support moddable climate, terrain and water eligibility, density rules and authored clearances. Evaluate all applicable footprints, including multiple locations and standalone features in a pixel. Keep stock land vegetation clear of water and required routes. Mods may define suitable shoreline and aquatic vegetation.
- **WORLD-011-D03.** Generated vegetation is decorative by default. Stock or mod content can explicitly declare collision, harvesting or other gameplay under the relevant owner. Representation changes preserve placement and gameplay state. Required gameplay dependencies participate in WORLD-004 readiness.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-011-interview-decisions) records the interview decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to `Assets/Scripts/`.

- `Terrain/TerrainNature.cs#LayoutNature` seeds random placement from the pixel key. It adjusts density by elevation, desert climate and tile type, applies location clearance, rejects low candidates near water and places accepted scenery against the terrain height.
- `Terrain/StreamingWorld.cs#UpdateTerrainNature` selects a climate and season nature archive. `LayoutNature` attempts a mesh replacement for nearby cells and uses billboards otherwise. `Utility/AssetInjection/MeshReplacement.cs#ImportNatureGameObject` handles imported nature representations.

## Detailed rules and behaviors

1. Resolve plant definitions and placement rules from validated stock and mod content. Mods can add plant types and placement rules, alter existing rules or supply replacement placement behavior through a supported contract. Resolve rule precedence explicitly. Identical resolved inputs produce equivalent placements regardless of streaming order, scene origin or visual settings.
2. Evaluate candidates in authoritative world coordinates using resolved climate, terrain, water and authored exclusions. Apply every relevant location and feature footprint. Keep required entrances, roads and approaches clear under stock policy. Use validated eligibility for modded shoreline and aquatic plants.
3. Anchor accepted placements to the applicable terrain or water reference and give gameplay-bearing placements stable identity. Coordinate edge ownership so neighboring cells do not instantiate the same placement twice. Terrain edits and conflicting placement changes follow the relevant content validation rules.
4. Stock vegetation keeps its placement across seasons. Seasonal art and distance-based representation may change. Mods can explicitly make season or another declared profile input affect placement or eligibility. Reevaluate those changes at a coherent boundary and reconcile dependent gameplay through the owner before making the change live.
5. Allow decorative scenery to finish independently of gameplay readiness. Gameplay-bearing vegetation has explicit collision or interaction data owned by the relevant system. Representation swaps and visual quality changes preserve its placement and gameplay state. Activate required collision and interaction dependencies before reporting affected coverage ready under WORLD-004.
6. Retire and rebuild live representations under WORLD-005/006/007. Rehydrate durable owner state before exposing the corresponding interaction. Streaming and visual swaps cannot restore a harvested plant or grant outcomes outside the owner's authorized rules.

## Relevant formulas, parameters and configuration

Configurable inputs include plant pools, weights and density, climate and surface eligibility, elevation, slope, water conditions, authored clearances, variation and seasonal rules. Mod placement behavior must provide the declared inputs and satisfy validation and continuity requirements. Exact formulas, numeric defaults and extension interfaces remain open.

## Required data

World coordinates and coverage, terrain and water revision, climate and relevant surface data, resolved nature profiles and versions, authored exclusions and mod provenance, declared seasonal inputs, visual assets, gameplay ownership and stable placement data where gameplay depends on it.

## Inputs, outputs and events

- **Inputs** — Validated placement profiles, active coverage, terrain and water data, authored footprints, season and presentation settings, and owner state.
- **Outputs** — Deterministic placements, presentation representations and validated gameplay resources where applicable.
- **Events** — Distinguish decorative completion, gameplay readiness and owner-governed changes. Restreaming alone produces no gameplay event or reward. Public APIs remain open.

## Cross-system interactions

- **DATA-006 and MOD** supply climate, validated plant content and placement rules. **WORLD-008/009/010** supply terrain and surface inputs and coherent revision boundaries.
- **WORLD-004/005/006/007 and LOC** govern readiness, residency, authored clearance and durable lifecycle. **WORLD-001/002** supply world coordinates and coherent rebasing.
- **TIME and AV** supply season and representation. **MOVE and interaction owners** validate explicit gameplay effects. **SAVE** restores durable state and validates compatibility.

## Edge cases and failure conditions

- Test several same-pixel locations and cross-cell clearances, including an authored road or entrance near a shoreline.
- Test overlapping mod placement rules, unsupported inputs and missing optional art. Required invalid gameplay content uses explicit validation or recovery.
- Test neighboring cells generated in either order, origin shifts and billboard or mesh swaps. Detect duplicate placements and mismatched collision.
- Test a harvested or otherwise changed plant through streaming and native load. Test a modded season change while an actor or interaction depends on the plant.

## Save/load considerations

Regenerate unchanged decorative placements from compatible inputs. Save durable plant and interaction state through the owner, including stable placement references where required. Validate changes to placement profiles or identities before restoring dependent state. Restore from authoritative gameplay and season context without replaying rewards or treating a representation rebuild as regrowth.

## Technical constraints

Target Godot 4.7.2. Use world-coordinate placement with reproducible profile inputs. Decorative representation and gameplay state must synchronize where they refer to the same placement. Exact authoring formats, generation strategy, identity mapping and performance budgets remain open.

## Acceptance criteria

1. Stock placements agree across different build orders, rebasing, streaming and native load. Stock seasonal art changes preserve placement.
2. A validated mod can add plants, alter or add placement behavior and define seasonal changes to placement or eligibility.
3. All applicable authored clearances are respected. Stock land vegetation stays clear of water and required routes, and eligible modded aquatic or shoreline vegetation can appear.
4. Decorative scenery can finish later. Explicit gameplay-bearing plants meet required readiness, preserve state across representation changes and restore without duplicate effects.

## Outstanding questions

- Define placement profile inputs, rule precedence and the extension contract for mod-supplied placement behavior.
- Calibrate stock density, clearance and variation through representative world fixtures.
- Define stable placement identity and compatibility for gameplay-bearing vegetation, including removal and seasonal replacement.
