# WORLD feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Source paths are relative to `Assets/Scripts/`. Symbols follow `#`. Confidence rates the static trace.

## WORLD-001 — World position synchronization

- **Parent subsystem** — Coordinates
- **Purpose** — Track geographic position during local motion.
- **Existing implementation** — StreamingWorld integrates scene X/Z deltas using SceneMapRatio, writes integer coordinates to PlayerGPS and samples the terrain tile beneath the player. Dungeon context returns before coordinate integration.
- **Source** — `Terrain/StreamingWorld.cs#Update`, `Terrain/StreamingWorld.cs#UpdatePlayerTerrainTileIndex`, `API/MapsFile.cs#WorldCoordToMapPixel`
- **Inputs and outputs** — Scene pose and context → world coordinates and tile index
- **Dependencies** — DATA-004, MOVE, LOC
- **Edge cases and interactions** — Test fractional movement, boundary crossing and return from a dungeon spanning multiple pixels.
- **Design questions** — Which coordinate frame should own player position?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-001 — World position synchronization](../../design/systems/WORLD/WORLD-001.md)

## WORLD-002 — Floating origin shifts

- **Parent subsystem** — Coordinates
- **Purpose** — Keep active geometry near the scene origin.
- **Existing implementation** — FixedUpdate checks map pixel change and vertical threshold, offsets the player controller and streaming target children, adjusts enemy last-grounded height and raises a position event. It skips world initialization.
- **Source** — `Utility/FloatingOrigin.cs#FixedUpdate`, `Utility/FloatingOrigin.cs#OffsetChildren`, `Utility/FloatingOrigin.cs#RaiseOnPositionUpdateEvent`
- **Inputs and outputs** — Map pixel change or vertical threshold → scene offset and subscriber event
- **Dependencies** — MOVE, NPC, SAVE
- **Edge cases and interactions** — Verify unparented objects, velocity and in-flight projectiles during rebase.
- **Design questions** — Which state must transform atomically during origin shifts?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-002 — Floating origin shifts](../../design/systems/WORLD/WORLD-002.md)

## WORLD-003 — Teleport and arrival placement

- **Parent subsystem** — Coordinates
- **Purpose** — Recenter streaming around a requested destination.
- **Existing implementation** — Coordinate and world-coordinate teleport APIs lead to map-pixel teleport. The update processes pending reposition modes including origin, offset, marker and dungeon entrance after terrain work is no longer running.
- **Source** — `Terrain/StreamingWorld.cs#TeleportToCoordinates`, `Terrain/StreamingWorld.cs#TeleportToWorldCoordinates`, `Terrain/StreamingWorld.cs#TeleportToMapPixel`, `Terrain/StreamingWorld.cs#PositionPlayerToLocation`, `Terrain/StreamingWorld.cs#PositionPlayerToDungeonExit`
- **Inputs and outputs** — Destination, offset and mode → streaming request and arrival pose
- **Dependencies** — MOVE-026, MOVE-027, TIME, SAVE, LOC
- **Edge cases and interactions** — Verify location availability and marker fallbacks after asynchronous rebuild.
- **Design questions** — What should happen when the requested arrival marker is unavailable?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-003 — Teleport and arrival placement](../../design/systems/WORLD/WORLD-003.md)

## WORLD-004 — World initialization and pixel transitions

- **Parent subsystem** — Streaming
- **Purpose** — Trigger work when entering a new map pixel.
- **Existing implementation** — Update waits for readiness, records previous and current pixel, calls world update, initializes player terrain and starts the terrain coroutine. Location updates are deferred while terrain is running.
- **Source** — `Terrain/StreamingWorld.cs#ReadyCheck`, `Terrain/StreamingWorld.cs#Update`, `Terrain/StreamingWorld.cs#InitWorld`, `Terrain/StreamingWorld.cs#InitPlayerTerrain`
- **Inputs and outputs** — GPS pixel and readiness → terrain and location work
- **Dependencies** — CORE-011, LOC, WORLD-001
- **Edge cases and interactions** — Check rapid crossings, load and teleport while jobs are pending.
- **Design questions** — Which content must be present before control resumes?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-004 — World initialization and pixel transitions](../../design/systems/WORLD/WORLD-004.md)

## WORLD-005 — Terrain window and recycling

- **Parent subsystem** — Streaming
- **Purpose** — Keep a bounded set of exterior terrain cells active.
- **Existing implementation** — StreamingWorld places terrains, finds reusable entries, collects terrain and sets neighbors. UpdateTerrains manages the terrain update pass. TerrainDistance is applied by startup settings.
- **Source** — `Terrain/StreamingWorld.cs#UpdateTerrains`, `Terrain/StreamingWorld.cs#PlaceTerrain`, `Terrain/StreamingWorld.cs#CollectTerrains`, `Terrain/StreamingWorld.cs#UpdateNeighbours`, `Game/Utility/StartGameBehaviour.cs#ApplyStartSettings`
- **Inputs and outputs** — Current pixel and distance settings → loaded terrain neighborhood
- **Dependencies** — CORE-006, AV, WORLD-004
- **Edge cases and interactions** — Inspect pool limits and seam behavior when cells are reused. Runtime scheduling remains open.
- **Design questions** — How far should terrain stream and when should cells retire?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-005 — Terrain window and recycling](../../design/systems/WORLD/WORLD-005.md)

## WORLD-006 — Exterior location activation

- **Parent subsystem** — Streaming
- **Purpose** — Attach settlements and other exterior locations to streamed cells.
- **Existing implementation** — After terrain work, StreamingWorld runs location updates, creates location objects and exposes creation/update/availability events. Building directory and city navigation can be queried for the current location.
- **Source** — `Terrain/StreamingWorld.cs#UpdateLocations`, `Terrain/StreamingWorld.cs#UpdateLocation`, `Terrain/StreamingWorld.cs#CreateLocationGameObject`, `Terrain/StreamingWorld.cs#GetCurrentBuildingDirectory`, `Terrain/StreamingWorld.cs#GetCurrentCityNavigation`
- **Inputs and outputs** — Loaded terrain and classic location records → active exterior and consumer lookup
- **Dependencies** — LOC, DATA-004, NPC-001, QUEST
- **Edge cases and interactions** — Verify when consumers can safely read the directory versus the availability event. Detailed block assembly belongs to LOC.
- **Design questions** — When should a location become available for interaction?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-006 — Exterior location activation](../../design/systems/WORLD/WORLD-006.md)

## WORLD-007 — Loose objects and world cleanup

- **Parent subsystem** — Streaming
- **Purpose** — Track exterior objects across streaming boundaries.
- **Existing implementation** — StreamingWorld exposes tracking by pixel with optional parenting and stateful designation. Collection and clear paths handle loose objects, stateful objects and world teardown separately.
- **Source** — `Terrain/StreamingWorld.cs#TrackLooseObject`, `Terrain/StreamingWorld.cs#CollectLooseObjects`, `Terrain/StreamingWorld.cs#ClearStatefulLooseObjects`, `Terrain/StreamingWorld.cs#ClearStreamingWorld`
- **Inputs and outputs** — Object, map pixel and stateful flags → ownership and cleanup
- **Dependencies** — SAVE, ITEM, NPC, MOD
- **Edge cases and interactions** — Verify dropped items, quest objects and mod objects when leaving range or starting a load.
- **Design questions** — Which objects should persist after their cell unloads?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-007 — Loose objects and world cleanup](../../design/systems/WORLD/WORLD-007.md)

## WORLD-008 — Height sampling and detail

- **Parent subsystem** — Terrain
- **Purpose** — Build traversable terrain from classic map inputs.
- **Existing implementation** — DefaultTerrainSampler generates samples from classic-scale data, interpolates large height data and adds small-scale noise using map-relative coordinates. It provides a scheduled sampling job.
- **Source** — `Terrain/DefaultTerrainSampler.cs#GenerateSamples`, `Terrain/DefaultTerrainSampler.cs#ScheduleGenerateSamplesJob`, `Terrain/TerrainHelper.cs`, `API/WoodsFile.cs`
- **Inputs and outputs** — Map pixel and height data → terrain height samples
- **Dependencies** — DATA-006, WORLD-005, AV
- **Edge cases and interactions** — Compare edges, coastline and location grading with data fixtures. DFU interpolation/noise is visible in code.
- **Design questions** — Which heights need reference parity and which can be generated?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-008 — Height sampling and detail](../../design/systems/WORLD/WORLD-008.md)

## WORLD-009 — Terrain update jobs and neighbor seams

- **Parent subsystem** — Terrain
- **Purpose** — Apply sampled terrain data to the streamed cell.
- **Existing implementation** — StreamingWorld schedules and completes terrain data work and updates neighbor links. DaggerfallTerrain represents the Unity terrain integration point.
- **Source** — `Terrain/StreamingWorld.cs#UpdateTerrainData`, `Terrain/StreamingWorld.cs#CompleteUpdateTerrainDataJobs`, `Terrain/StreamingWorld.cs#UpdateTerrainDataCoroutine`, `Terrain/StreamingWorld.cs#UpdateNeighbours`, `Terrain/DaggerfallTerrain.cs`
- **Inputs and outputs** — Terrain descriptor and job completion → updated terrain and neighbors
- **Dependencies** — WORLD-005, WORLD-008, AV
- **Edge cases and interactions** — Verify teardown while jobs are pending and movement on a seam before neighbors are linked.
- **Design questions** — What consistency is required while nearby cells update?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-009 — Terrain update jobs and neighbor seams](../../design/systems/WORLD/WORLD-009.md)

## WORLD-010 — Tile assignment and water transitions

- **Parent subsystem** — Terrain
- **Purpose** — Assign surface records used by rendering and movement.
- **Existing implementation** — Default terrain texturing schedules tile assignment, uses a fixed seed for continuity, preserves designated location textures and uses a basic marching-squares transition set for water, dirt, grass and stone.
- **Source** — `Terrain/TerrainTexturing.cs#ScheduleAssignTilesJob`, `Terrain/TerrainTexturing.cs#ConvertWaterTiles`, `Terrain/StreamingWorld.cs#UpdatePlayerTerrainTileIndex`
- **Inputs and outputs** — Height, location rect and world noise → surface tile records
- **Dependencies** — MOVE-007, MOVE-014, LOC, AV
- **Edge cases and interactions** — Source says water-to-grass and water-to-stone transitions are unsupported by the simple algorithm. Check tile IDs after mod replacement.
- **Design questions** — Which surface IDs should affect gameplay as well as visuals?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-010 — Tile assignment and water transitions](../../design/systems/WORLD/WORLD-010.md)

## WORLD-011 — Nature placement

- **Parent subsystem** — Terrain
- **Purpose** — Populate exterior cells with vegetation and scenery.
- **Existing implementation** — TerrainNature lays out nature for a terrain and billboard batch. The default path rejects placement in an expanded location rect and near water.
- **Source** — `Terrain/TerrainNature.cs#LayoutNature`, `Terrain/StreamingWorld.cs#UpdateTerrainNature`, `Utility/AssetInjection/MeshReplacement.cs#ImportNatureGameObject`
- **Inputs and outputs** — Terrain, scale, distance and exclusion areas → exterior nature objects
- **Dependencies** — AV, LOC, MOD
- **Edge cases and interactions** — Verify deterministic placement, custom replacements and interaction/collision assumptions.
- **Design questions** — Should generated scenery remain stable across restreaming?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-011 — Nature placement](../../design/systems/WORLD/WORLD-011.md)

## WORLD-012 — Climate, political and location context

- **Parent subsystem** — Geography
- **Purpose** — Publish current geographic state to other systems.
- **Existing implementation** — PlayerGPS updates world information for the current coordinates and exposes change events for map pixel, region, climate and political index. It can resolve regional faction, race and naming context.
- **Source** — `Internal/PlayerGPS.cs#UpdateWorldInfo`, `Internal/PlayerGPS.cs#RaiseEvents`, `Internal/PlayerGPS.cs#GetCurrentRegionFaction`, `Internal/PlayerGPS.cs#GetRaceOfCurrentRegion`
- **Inputs and outputs** — Map position and content data → geographic context and events
- **Dependencies** — DATA-004, FACT, NPC, TIME
- **Edge cases and interactions** — Verify transition order when multiple indices change and where no location exists.
- **Design questions** — Which geographic changes should be exposed to consumers?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-012 — Climate, political and location context](../../design/systems/WORLD/WORLD-012.md)

## WORLD-013 — Location bounds and entry events

- **Parent subsystem** — Geography
- **Purpose** — Distinguish being near a location from being within its gameplay area.
- **Existing implementation** — PlayerGPS computes a world location rectangle and expands checks by 4096 classic units. Entering triggers discovery before the entry event. Leaving or losing the current location can emit exit.
- **Source** — `Internal/PlayerGPS.cs#CalculateWorldLocationRect`, `Internal/PlayerGPS.cs#PlayerLocationRectCheck`, `Internal/PlayerGPS.cs#IsPlayerInTown`
- **Inputs and outputs** — World position, loaded location and bounds → presence flag and events
- **Dependencies** — LAW-016, NPC, QUEST, LOC
- **Edge cases and interactions** — A map pixel can contain a location while the player is outside the rectangle. The margin is described as a classic approximation.
- **Design questions** — Where should town rules start and end?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-013 — Location bounds and entry events](../../design/systems/WORLD/WORLD-013.md)

## WORLD-014 — Location discovery

- **Parent subsystem** — Exploration
- **Purpose** — Record explored or revealed places.
- **Existing implementation** — PlayerGPS adds current loaded locations to discovery keyed by map pixel ID. It also supports named and random discovery paths used by other systems.
- **Source** — `Internal/PlayerGPS.cs#DiscoverCurrentLocation`, `Internal/PlayerGPS.cs#DiscoverLocation`, `Internal/PlayerGPS.cs#DiscoverRandomLocation`, `Internal/PlayerGPS.cs#HasDiscoveredLocation`
- **Inputs and outputs** — Location record or discovery request → discovered location state
- **Dependencies** — QUEST-014, ITEM-016, UI, SAVE
- **Edge cases and interactions** — Verify default-discovered locations, duplicates and records sharing coordinates.
- **Design questions** — Which events should reveal a location?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-014 — Location discovery](../../design/systems/WORLD/WORLD-014.md)

## WORLD-015 — Building discovery and custom names

- **Parent subsystem** — Exploration
- **Purpose** — Track what the player knows about individual buildings.
- **Existing implementation** — PlayerGPS exposes discover, undiscover, custom-name and name-refresh operations. Discovery data also exposes per-building lockpick history.
- **Source** — `Internal/PlayerGPS.cs#DiscoverBuilding`, `Internal/PlayerGPS.cs#UndiscoverBuilding`, `Internal/PlayerGPS.cs#SetDiscoveredBuildingCustomName`, `Internal/PlayerGPS.cs#SetLastLockpickAttempt`
- **Inputs and outputs** — Building key, name and interaction → per-building discovery state
- **Dependencies** — LOC, NPC-020, MOVE-020, SAVE
- **Edge cases and interactions** — Verify renamed quest residences, temporary hints and reused building keys across locations.
- **Design questions** — Which building facts should remain after the quest or visit?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-015 — Building discovery and custom names](../../design/systems/WORLD/WORLD-015.md)

## WORLD-016 — Exterior map layout and labels

- **Parent subsystem** — Exploration
- **Purpose** — Display settlement geometry and the player position.
- **Existing implementation** — ExteriorAutomap builds layout textures, supports original/extra/all views, creates building nameplates and computes their offsets. It refreshes player markers and handles location and transition events.
- **Source** — `Game/ExteriorAutomap.cs#CreateExteriorLayoutTexture`, `Game/ExteriorAutomap.cs#CreateBuildingNameplates`, `Game/ExteriorAutomap.cs#ComputeNameplateOffsets`, `Game/ExteriorAutomap.cs#UpdatePlayerMarker`, `Game/ExteriorAutomap.cs#OnMapPixelChanged`
- **Inputs and outputs** — Location, discovery and view settings → map image and labels
- **Dependencies** — UI, LOC, AV, WORLD-015
- **Edge cases and interactions** — Check label overlaps and what each mode reveals. Dungeon automap is separate LOC scope.
- **Design questions** — Which building information should each map mode reveal?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-016 — Exterior map layout and labels](../../design/systems/WORLD/WORLD-016.md)

## WORLD-017 — Nearby object queries

- **Parent subsystem** — Exploration
- **Purpose** — Expose local actor and loot context.
- **Existing implementation** — PlayerGPS updates nearby objects and classifies entities and loot. Callers can query flags, range and active hierarchy filtering.
- **Source** — `Internal/PlayerGPS.cs#UpdateNearbyObjects`, `Internal/PlayerGPS.cs#GetNearbyObjects`, `Internal/PlayerGPS.cs#GetEntityFlags`, `Internal/PlayerGPS.cs#GetLootFlags`
- **Inputs and outputs** — Active objects, position and flags → nearby results
- **Dependencies** — NPC, ITEM, MAGIC, LOC
- **Edge cases and interactions** — Verify update cadence, range boundaries and stale entries after streaming cleanup.
- **Design questions** — Which discovery effects should use this query?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-017 — Nearby object queries](../../design/systems/WORLD/WORLD-017.md)

## WORLD-018 — World and discovery restore

- **Parent subsystem** — Persistence
- **Purpose** — Reconstruct geography and exploration state.
- **Existing implementation** — PlayerGPS exports and restores discovery records. SaveLoadManager restores world compensation and discovery and then hands saved position to PlayerEnterExit. ExteriorAutomap has separate load refresh.
- **Source** — `Internal/PlayerGPS.cs#GetDiscoverySaveData`, `Internal/PlayerGPS.cs#RestoreDiscoveryData`, `Terrain/StreamingWorld.cs#RestoreWorldCompensationHeight`, `Game/Serialization/SaveLoadManager.cs#LoadGame`, `Game/ExteriorAutomap.cs#SetExteriorAutomapStateFromLoadGame`
- **Inputs and outputs** — Save data, map IDs and position → restored world and map knowledge
- **Dependencies** — SAVE, MOVE-027, LOC, DATA-024
- **Edge cases and interactions** — Verify replaced locations, old saves and arrival pose after origin shifts.
- **Design questions** — What should happen when a saved map key no longer exists?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14.

### My Intended Specification

[WORLD-018 — World and discovery restore](../../design/systems/WORLD/WORLD-018.md)

## Classic provenance and next review steps

- Classic data supplies geography, height and location records. DFU implements terrain interpolation, noise, streaming jobs and scene rebasing. PlayerGPS explicitly describes its expanded location rectangle as an approximation of classic behavior.
- Start by tracing a map-pixel crossing and a teleport, including a rebase and save/reload. Then review neighboring terrain at a coastline and settlement edge. Follow a quest reveal and a building discovery through map display and restoration.
- Scope separates geographic data from runtime terrain, streaming and exploration. LOC owns block assembly and dungeon automap. TIME owns trip selection and time advance. Unity job timing, terrain and collision assets, effective mods and original-game parity remain open.
