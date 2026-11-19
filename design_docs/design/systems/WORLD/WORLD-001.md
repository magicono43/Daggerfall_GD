# WORLD-001 — World position synchronization

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Keep the player's geographic position consistent with physical movement so maps, streaming and geographic rules agree. Slow movement crosses boundaries at the same place as fast movement. Origin shifts are invisible to geography. Interior exploration keeps the location's geographic context, and an exit places the player in the geography of the actual destination.

## Confirmed requirements

- **WORLD-001-D01.** MOVE owns the local physics pose. Outdoors, WORLD owns the continuous geographic position computed from that pose and an explicit origin. Map pixel is derived from that position.
- **WORLD-001-D02.** Buildings and dungeons report the geographic anchor of their current location while MOVE tracks the actual interior pose. Preserve the entry door separately as a return reference. Publish the actual exit geography on successful exit, including across map pixels or regions.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-001-interview-decisions) records the two interview decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to the reference source's `Assets/Scripts/`.

- `Terrain/StreamingWorld.cs#Update` adds scene X/Z deltas scaled by inverse mesh scale to double accumulators, then casts them to integers for `PlayerGPS`. It skips geographic integration in a dungeon. `ResyncWorldCoordinates` recomputes the accumulators from map pixel origin and scene position after explicit repositioning.
- `Internal/PlayerGPS.cs#CurrentMapPixel` derives the pixel through `API/MapsFile.cs#WorldCoordToMapPixel`. The classic mapping uses integer division by 32,768 and reverses the north/south index using `499 - worldZ / 32768`.
- `Terrain/StreamingWorld.cs#UpdatePlayerTerrainTileIndex` samples the terrain tile beneath the pose and uses `-1` when the terrain or its tilemap is unavailable.
- `Game/Serialization/SerializablePlayer.cs#GetPlayerPositionData` captures the scene pose, world compensation, geographic integers and world context.

## Detailed rules and behaviors

1. Outdoors, resolve the committed MOVE pose through the matching WORLD origin and coordinate transform. Recompute geographic position from these inputs at the synchronization boundary. Retain subpixel precision. Derive map pixel and region from the same geographic position using validated geography.
2. An origin shift changes the origin and local pose coherently. The shift itself produces zero geographic displacement and zero geographic boundary events. If physical movement crosses a boundary on the same update, publish the crossing from the coherent post-movement position.
3. In a building or dungeon, report the current location's validated WORLD anchor. Interior movement updates the MOVE pose within the LOC layout. Resolve return and exit placement using stable door and destination references under MOVE-026/027.
4. Treat destination preparation as provisional. Until placement and context commit, consumers may see the last committed context with a transition in progress. Gameplay respects the transition gate. On exit or other relocation, resolve geography from the accepted destination pose and publish it with the committed context. Failed placement follows MOVE/CORE recovery without publishing destination-derived gameplay effects.
5. Outdoor terrain classification is a derived query. Missing tile data yields an unavailable result without changing a valid geographic position. The terrain and movement owners determine which checks need terrain data and when gameplay is ready.

## Formulas, parameters and configuration

Conceptual outdoor conversion: geographic horizontal position = geographic origin + transformed horizontal offset from the matching local origin. The transform supplies scale and axis mapping. Map pixel and region use the validated map conversion and indexes. Local height, facing and movement state remain with the pose.

DATA-004's classic geography baseline and validated override rules apply. Axis, scale, precision, edge inclusion and rounding are shared coordinate contract parameters. This draft selects no gameplay tuning values. Validate content anchors and conversions before use so all consumers resolve a boundary consistently.

## Required data

Matching origin and committed pose samples, coordinate conversion version, current exterior or interior context, validated map coverage and region lookup, stable interior location ID and anchor, and relevant door and placement references. Terrain data is needed for terrain classification. Explicit transition identity is needed for staged placement.

## Inputs, outputs and events

- **Inputs** — Committed MOVE poses, coherent origin shifts, validated DATA geography and LOC anchors, placement outcomes, and restored coordinate state.
- **Outputs** — Committed geographic position with derived map pixel and region, current context, and terrain classification or an explicit unavailable result.
- **Events** — Publish pixel and region changes only when the corresponding committed value changes. Subscribers must be able to read the complete new geographic context when notified. Preparation and restore readiness remain distinguishable from live crossings. Public signal names and scheduling remain open.

## Cross-system interactions

- **DATA-004 and LOC** supply geographic definitions, stable identities, anchors and local layout context. A pixel can index multiple locations under WORLD-006-D04. Resolve a specific location by its stable identity or an explicit owner selection rule.
- **MOVE-026/027** own door mapping, pose acceptance, local correction and preservation of movement state. **WORLD-002–004** own rebase mechanics, arrival orchestration and streaming readiness.
- **CORE-013 and SAVE** coordinate preflight, reconstruction and readiness. **UI, QUEST, LAW and other geographic consumers** use committed geographic context and retain their own rules for reactions.

## Edge cases and failure conditions

- Test slow subpixel movement, exact seams approached from either side, and movement concurrent with an origin shift. The same physical position should resolve consistently.
- Test an interior layout that extends beyond an overworld pixel and exits through a different region. Only the committed destination may trigger destination reactions.
- Reject stale origin, pose or placement data from a superseded context. Missing anchors, unsupported conversions and positions outside the supported coordinate domain need explicit validation or recovery. Boundary enforcement is a separate WORLD policy.
- Staged reloads and duplicate completion callbacks must avoid false crossings and repeated regional or quest reactions. Missing terrain classification must remain distinguishable from an actual terrain type.

## Save/load considerations

Capture committed geographic and pose context together. Outdoors, restore the geographic position and MOVE pose state through a compatible conversion. Indoors, preserve stable location identity, the local pose and the return reference when required. Reconstruct origin and derived geography before gameplay resumes. SAVE owns the exact schema and compatibility policy for moved anchors or conversion revisions.

Apply CORE-013 preflight and MOVE-026/027 readiness and save restrictions. Unsupported required coordinate data needs validated migration or explicit recovery. Native restoration rebuilds geographic context without replaying ordinary boundary or doorway consequences.

## Technical constraints

Target Godot 4.7.2. Keep versioned geographic conversion separate from engine-local transforms. WORLD and MOVE must synchronize matching pose and origin state before publishing results, including when rebasing and placement occur near a boundary. Exact numeric representation, origin mechanics and public API are open.

## Acceptance criteria

1. Fractional outdoor movement changes continuous position and produces one pixel transition when the position crosses the seam. A region transition occurs only if the resolved region changes.
2. A pure origin shift leaves geographic position, map pixel and region unchanged. A concurrent real crossing publishes the same geographic result as movement without a shift.
3. Walking anywhere inside a building or dungeon leaves its reported anchor unchanged. An exit into another pixel or region publishes the actual destination only after successful commitment.
4. Failed or superseded placement cannot publish destination geography or trigger destination rules. Missing terrain yields unavailable classification while valid geography is retained.
5. Native save/load restores geographic context and supported movement state across a reconstructed origin without replaying crossing consequences. Incompatible required data follows the approved recovery flow.

## Outstanding questions

- Which precision, scale, axes and exact seam rules satisfy DATA-004's classic mapping and supported content? Verify with coordinate fixtures.
- How are anchors represented and validated for special interiors without an ordinary map location, such as owned ships? Resolve with LOC and the relevant ownership and transition specs.
- WORLD-002–004, LOC and SAVE still need to define same-step publication mechanics, placement and residency lifecycle, and migration rules for moved anchors or revised conversions.
