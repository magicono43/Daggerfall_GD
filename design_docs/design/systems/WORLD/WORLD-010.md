# WORLD-010 — Tile assignment and water transitions

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Give outdoor terrain coherent materials and shoreline transitions. Keep footing and swimming consistent with the surface or water the actor actually contacts. Let modders change visuals, surface rules and transitions independently.

## Confirmed requirements

- **WORLD-010-D01.** Use stable surface IDs for gameplay queries and presentation. Texture replacement preserves gameplay rules. Mods can explicitly define or assign gameplay surfaces under MOVE-007. Water contact and submersion use water geometry and actor context.
- **WORLD-010-D02.** Use deterministic visual transitions across cell seams. Support direct water-to-grass and water-to-stone transitions where appropriate. Transition rules are moddable.
- **WORLD-010-D03.** Allow independent appearance and gameplay surface edits for settlements and standalone features within authored footprints. Resolve conflicting edits through explicit rules consistent with WORLD-008.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-010-interview-decisions) records these decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to `Assets/Scripts/`.

- `Terrain/TerrainTexturing.cs#ScheduleAssignTilesJob` classifies samples using ocean and beach elevations and weighted world-coordinate noise. The assignment job keeps preassigned tiles and uses a marching-squares lookup for water, dirt, grass and stone. The source documents that direct water-to-grass and water-to-stone transitions are unsupported.
- `DefaultTerrainTexturing.ConvertWaterTiles` opts into conversion of the reserved water tile value. `Terrain/StreamingWorld.cs#UpdatePlayerTerrainTileIndex` samples the tile beneath the player, decoding its base index from the visual variants. Unavailable terrain or tile data leaves the index at its unavailable sentinel.

## Detailed rules and behaviors

1. Derive generated surface and appearance assignments from validated world-space terrain inputs, authored data and the resolved terrain profile. Use stable surface IDs for gameplay classification. AV can map them to stock or replacement materials and can apply independent appearance overrides.
2. Query gameplay surfaces at actual support or contact under MOVE-007. A cosmetic replacement, tile rotation or visual blend cannot change gameplay surface identity. Stock ordinary traction follows MOVE-007. Mods can change traction, gait contribution or sliding through explicit validated rules owned by MOVE.
3. Determine water contact, swimming and submersion from the relevant water geometry and actual actor context under MOVE-014. A shoreline material, blend weight or ground tile cannot by itself start or stop swimming. A bridge above water resolves its own support and remains dry where the actor has no water contact.
4. Evaluate shoreline and inland visual transitions deterministically from resolved world-space inputs. Match transition boundaries across cells regardless of build order or origin shift. Support direct grassy and rocky shorelines as well as beaches. Stock transitions preserve the shoreline and traversal constraints in WORLD-008. Validated mod rules may intentionally alter visual transitions or pair them with separately validated geography changes.
5. Allow location and standalone feature footprints to override appearance and gameplay surfaces separately. Apply declared composition or precedence to conflicts within each affected assignment. Unresolved conflicting edits fail validation. This applies to adjacent towns in one pixel and footprints crossing cell seams.
6. Publish required gameplay classification with the applicable terrain and collision revision under WORLD-004/009. WORLD-001 queries return explicit unavailability when classification data is missing. Optional visual refinements may complete separately where the active world stays coherent.

## Relevant formulas, parameters and configuration

Configure stable surface definitions, appearance mappings, transition combinations and priorities, and footprint overrides. Exact height thresholds, weighting, blend widths, sample resolution and tie rules remain open. DFU threshold constants and its lookup layout are reference values. Movement and water parameters remain with their respective owners.

## Required data

Versioned surface definitions and appearance mappings, generated height and geographical inputs, water geometry and boundaries supplied by the relevant owners, terrain cell and sample identity, authored footprint edits, transition rules and resolved precedence, and matching terrain and collision revision.

## Inputs, outputs and events

- **Inputs** — Validated profile, height and water inputs, appearance and surface overrides, world coordinates and contact observations.
- **Outputs** — Stable surface identity or unavailable result, optional visual material and blend data, and validated inputs for movement and presentation consumers.
- **Events** — Surface availability follows the relevant terrain readiness boundary. MOVE owns actual contact, water entry and submersion outcomes. Public APIs remain open.

## Cross-system interactions

- **WORLD-001/004/008/009** supply geographic classification queries, readiness, terrain and coherent publication across seams. **WORLD-006 and LOC** supply authored exterior footprints.
- **MOVE-007/014** govern surface movement and water state. **AV** owns terrain presentation. **DATA/MOD** resolve definitions, assets and explicit overrides.
- **CORE/SAVE** restore committed gameplay state against validated world and content versions.

## Edge cases and failure conditions

- Test bridges and overhangs above water, shallow banks, rocky shores and adjacent dry and submerged geometry. Use actual support and water observations.
- Test direct water-to-grass and water-to-stone transitions across cell edges and corners built in different orders.
- Test overlapping authored footprints, missing definitions and appearance-only texture replacements. Unsupported required classification uses explicit unavailability or recovery under the owner contract.
- Test differing visual and gameplay assignments in a footprint. Visual blending cannot apply multiple movement modifiers or cause duplicate contacts.

## Save/load considerations

Rebuild derived surface and transition data from the restored world and validated content. Save committed movement and water context through its owners and revalidate it against ready geometry. Required surface identity or profile incompatibility follows owner migration or recovery. Raw texture indices, tile orientation and blend caches are runtime data.

## Technical constraints

Target Godot 4.7.2. Use a consistent world-space sampling frame across seams and rebasing. Validate gameplay queries against the installed collision and terrain revision. Exact grid or material representation, transition rendering and query APIs remain open.

## Acceptance criteria

1. A visual replacement preserves the surface ID and rules. An explicit validated mod surface can supply the allowed MOVE-007 behavior.
2. An actor above water on a dry bridge stays dry. Water contact and submersion follow MOVE-014 and actual geometry.
3. Direct grassy and rocky shorelines render consistently across seams and rebuilds. Validated mod transitions can alter the visuals.
4. Independent appearance and gameplay surface edits apply within authored footprints, including multiple locations in one pixel. Explicit conflicts resolve consistently and unresolved conflicts fail validation.
5. Missing classification returns unavailable, and native load rebuilds compatible terrain state before dependent gameplay resumes.

## Outstanding questions

- Define stock surface IDs, profile formats, transition and seam fixtures, and missing optional material behavior.
- Set gameplay surface sampling and selection at mixed contacts with MOVE-007 and LOC.
- Define the water geometry contract and validate shore and footprint edits against WORLD-008 and MOVE-014.
