# LOC feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Source paths are relative to `Assets/Scripts/`. Symbols follow `#`. Complexity estimates review scope. Confidence rates the sampled trace.

## LOC-001 — Location layout and block placement

- **Parent subsystem** — Exterior
- **Purpose** — Assemble a settlement from its location records.
- **Existing implementation** — DaggerfallLocation sets and lays out a location. RMBLayout builds each block at layout coordinates and adds models, ground, flats and lights.
- **Source** — `Internal/DaggerfallLocation.cs#SetLocation`, `Internal/DaggerfallLocation.cs#LayoutLocation`, `Utility/RMBLayout.cs#CreateBaseGameObject`, `Utility/RMBLayout.cs#AddGroundPlane`
- **Inputs and outputs** — Location and RMB records → assembled exterior
- **Dependencies** — WORLD-006, DATA-005, AV
- **Edge cases and interactions** — Test missing blocks, clone reuse and placement orientation.
- **Design questions** — Which aspects of exterior layout must match original records?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-001 specification](../../design/systems/LOC/LOC-001.md)

## LOC-002 — Building identity and directory

- **Parent subsystem** — Exterior
- **Purpose** — Index buildings for access, discovery and services.
- **Existing implementation** — BuildingDirectory builds from location blocks, provides type/faction searches and encodes the block layout coordinates and record index in a building key.
- **Source** — `Game/BuildingDirectory.cs#SetLocation`, `Game/BuildingDirectory.cs#MakeBuildingKey`, `Game/BuildingDirectory.cs#GetBuildingsOfFaction`, `Utility/RMBLayout.cs#GetBuildingData`
- **Inputs and outputs** — Block records and layout coordinates → building summaries and keys
- **Dependencies** — WORLD-015, ECON, NPC, QUEST
- **Edge cases and interactions** — Verify key stability after block replacements and distinguish location-local keys.
- **Design questions** — What should identify a building across edits and saves?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-002 specification](../../design/systems/LOC/LOC-002.md)

## LOC-003 — Doorway and building hit metadata

- **Parent subsystem** — Exterior
- **Purpose** — Associate exterior models with usable entrances.
- **Existing implementation** — RMBLayout attaches static door and building data to exterior objects. PlayerActivate queries those objects and uses building summaries before attempting access.
- **Source** — `Utility/RMBLayout.cs#AddStaticDoors`, `Utility/RMBLayout.cs#AddStaticBuildings`, `Internal/DaggerfallStaticDoors.cs`, `Game/PlayerActivate.cs#ActivateStaticDoor`
- **Inputs and outputs** — Model records and hit context → doorway and building metadata
- **Dependencies** — MOVE-020, MOVE-026, WORLD-006
- **Edge cases and interactions** — Test multiple doors on one model and collider/transform ownership.
- **Design questions** — Which door identity should be passed to an interior?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-003 specification](../../design/systems/LOC/LOC-003.md)

## LOC-004 — City gates and exterior arrival markers

- **Parent subsystem** — Exterior
- **Purpose** — Expose settlement access geometry and arrival positions.
- **Existing implementation** — RMBLayout recognizes gate models. DaggerfallCityGate exposes open/toggle behavior. DaggerfallLocation enumerates start markers used by world arrival paths.
- **Source** — `Utility/RMBLayout.cs#IsCityGate`, `Internal/DaggerfallCityGate.cs#SetOpen`, `Internal/DaggerfallLocation.cs#EnumerateStartMarkers`, `Terrain/StreamingWorld.cs#PositionPlayerToLocation`
- **Inputs and outputs** — Gate and marker records plus requested state → movable gate or arrival candidates
- **Dependencies** — TIME, WORLD-003, MOVE
- **Edge cases and interactions** — Verify automatic scheduling and fallback when markers are absent.
- **Design questions** — Which gates and markers should control entry?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-004 specification](../../design/systems/LOC/LOC-004.md)

## LOC-005 — Interior reconstruction from a door

- **Parent subsystem** — Interiors
- **Purpose** — Load the interior attached to an exterior entrance.
- **Existing implementation** — DaggerfallInterior assigns block data from a StaticDoor and lays out models, flats and other interior objects. Scene naming accepts map and building keys. Automap has a separate layout path.
- **Source** — `Internal/DaggerfallInterior.cs#DoLayout`, `Internal/DaggerfallInterior.cs#AssignBlockData`, `Internal/DaggerfallInterior.cs#GetSceneName`, `Internal/DaggerfallInterior.cs#DoLayoutAutomap`
- **Inputs and outputs** — Door owner, door record, building and climate → interior and scene identity
- **Dependencies** — DATA-005, MOVE-026, SAVE, WORLD
- **Edge cases and interactions** — Trace missing records and multi-entrance consistency.
- **Design questions** — Which records determine whether entrances share one interior?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-005 specification](../../design/systems/LOC/LOC-005.md)

## LOC-006 — Interior markers and exit matching

- **Parent subsystem** — Interiors
- **Purpose** — Locate entrances, beds and spawn positions.
- **Existing implementation** — Interior exposes closest door and enter marker queries, lowest outer door and typed marker lookup. Consumers use these for arrival, guards and room allocation.
- **Source** — `Internal/DaggerfallInterior.cs#FindClosestInteriorDoor`, `Internal/DaggerfallInterior.cs#FindClosestEnterMarker`, `Internal/DaggerfallInterior.cs#FindLowestOuterInteriorDoor`, `Internal/DaggerfallInterior.cs#FindMarkers`
- **Inputs and outputs** — Layout, marker type and player position → matching position or failure
- **Dependencies** — MOVE-027, LAW-007, ECON-015, QUEST
- **Edge cases and interactions** — Check ties, missing markers and unstable marker ordering.
- **Design questions** — Which marker roles need dedicated authored IDs?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-006 specification](../../design/systems/LOC/LOC-006.md)

## LOC-007 — Interior people and service placement

- **Parent subsystem** — Interiors
- **Purpose** — Populate a room with contextual actors.
- **Existing implementation** — Interior has AddPeople and UpdateNpcPresence paths. People assembly reads building guild membership context. StaticNPC provides the actor data boundary.
- **Source** — `Internal/DaggerfallInterior.cs#AddPeople`, `Internal/DaggerfallInterior.cs#UpdateNpcPresence`, `Game/StaticNPC.cs#SetLayoutData`
- **Inputs and outputs** — Building records, faction context and presence rules → placed actors
- **Dependencies** — NPC-004, FACT-014, ECON, QUEST
- **Edge cases and interactions** — Verify conditional actors and quest substitutions across revisits.
- **Design questions** — Which NPC presence should change dynamically inside a loaded room?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-007 specification](../../design/systems/LOC/LOC-007.md)

## LOC-008 — Furniture and property containers

- **Parent subsystem** — Interiors
- **Purpose** — Turn interior models into functional props.
- **Existing implementation** — Interior creates furniture actions and can make house containers from model records with a load ID. Activation and loot handling consume the constructed objects.
- **Source** — `Internal/DaggerfallInterior.cs#AddFurnitureAction`, `Internal/DaggerfallInterior.cs#MakeHouseContainer`, `Game/PlayerActivate.cs#ActivateLaddersAndShelves`, `Internal/DaggerfallLoot.cs`
- **Inputs and outputs** — Model, building context and load ID → fixture or container
- **Dependencies** — ITEM-022, ECON-013, MOVE-021, SAVE
- **Edge cases and interactions** — Test ownership changes, replaced furniture and stable container IDs.
- **Design questions** — Which props should keep state across reconstruction?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-008 specification](../../design/systems/LOC/LOC-008.md)

## LOC-009 — Dungeon block assembly

- **Parent subsystem** — Dungeons
- **Purpose** — Build a dungeon from its declared RDB blocks.
- **Existing implementation** — SetDungeon validates loaded data, dungeon presence and one-time setup. LayoutDungeon instantiates blocks at X/Z offsets and removes overlapping doors afterward.
- **Source** — `Internal/DaggerfallDungeon.cs#SetDungeon`, `Internal/DaggerfallDungeon.cs#LayoutDungeon`, `Internal/DaggerfallDungeon.cs#RemoveOverlappingDoors`, `Utility/RDBLayout.cs#CreateBaseGameObject`
- **Inputs and outputs** — Location and block coordinates → assembled dungeon
- **Dependencies** — DATA-005, MOVE-026, AV, SAVE
- **Edge cases and interactions** — Duplicate-door culling uses proximity. Check intentional pairs and malformed blocks.
- **Design questions** — How should overlapping objects be resolved?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-009 specification](../../design/systems/LOC/LOC-009.md)

## LOC-010 — Dungeon textures and story variants

- **Parent subsystem** — Dungeons
- **Purpose** — Select visual archives for block materials.
- **Existing implementation** — Dungeon exposes default reset, randomization and location-based texture table selection with a main-story check. Location texture mode is labeled partially implemented in code.
- **Source** — `Internal/DaggerfallDungeon.cs#ResetDungeonTextureTable`, `Internal/DaggerfallDungeon.cs#RandomiseDungeonTextureTable`, `Internal/DaggerfallDungeon.cs#UseLocationDungeonTextureTable`, `Internal/DaggerfallDungeon.cs#IsMainStoryDungeon`, `DungeonTextureTables.cs`
- **Inputs and outputs** — Dungeon identity and texture mode → block texture table
- **Dependencies** — AV, DATA-022, MOD
- **Edge cases and interactions** — Compare archive mapping across story and ordinary dungeons. Partial support needs explicit coverage.
- **Design questions** — Which dungeons require fixed visual identity?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-010 specification](../../design/systems/LOC/LOC-010.md)

## LOC-011 — Start and enter marker resolution

- **Parent subsystem** — Dungeons
- **Purpose** — Identify dungeon arrival landmarks.
- **Existing implementation** — Layout calls FindMarkers per block. Starting blocks assign dungeon start and enter references. If a block supplies multiple markers of a kind, code logs and uses the first.
- **Source** — `Internal/DaggerfallDungeon.cs#FindMarkers`, `Game/PlayerEnterExit.cs#StartDungeonInterior`, `Game/PlayerEnterExit.cs#MovePlayerToDungeonStart`
- **Inputs and outputs** — RDB marker lists and starting-block flag → arrival references
- **Dependencies** — MOVE-027, WORLD-003, QUEST
- **Edge cases and interactions** — Test missing start/enter markers and which transition path prefers each.
- **Design questions** — Which marker should win on entry or recovery?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-011 specification](../../design/systems/LOC/LOC-011.md)

## LOC-012 — Water and special block context

- **Parent subsystem** — Dungeons
- **Purpose** — Build water and expose block-specific gameplay state.
- **Existing implementation** — The first start marker supplies water level and castle flag. No start marker sets water level to 10000. Layout adds water per block. PlayerEnterExit reads current block data for water and special-area context.
- **Source** — `Internal/DaggerfallDungeon.cs#FindMarkers`, `Internal/DaggerfallDungeon.cs#GetPlayerBlockIndex`, `Utility/RDBLayout.cs#AddWater`, `Game/PlayerEnterExit.cs#Update`
- **Inputs and outputs** — Block markers and player position → water geometry and context flags
- **Dependencies** — MOVE-014, AV, CHAR, DATA
- **Edge cases and interactions** — Check transitions between blocks with different heights and no valid block.
- **Design questions** — How should water and special area state transition at block boundaries?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-012 specification](../../design/systems/LOC/LOC-012.md)

## LOC-013 — Fixed and random enemy placement

- **Parent subsystem** — Dungeons
- **Purpose** — Populate dungeon encounters from block records.
- **Existing implementation** — RDBLayout has distinct fixed and random enemy passes and a classic random path. Dungeon layout supplies importEnemies, variance, level-scaled monster power and a tick-derived seed input.
- **Source** — `Internal/DaggerfallDungeon.cs#LayoutDungeon`, `Utility/RDBLayout.cs#AddFixedEnemies`, `Utility/RDBLayout.cs#AddRandomEnemies`, `Utility/RDBLayout.cs#AddRandomRDBEnemyClassic`
- **Inputs and outputs** — Block records, dungeon type, level, seed and import flag → placed foes
- **Dependencies** — NPC-005, NPC-007, RULE, SAVE
- **Edge cases and interactions** — Check when seed is consumed, reload determinism and quest foe coexistence.
- **Design questions** — Which enemy placements should remain fixed across visits?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-013 specification](../../design/systems/LOC/LOC-013.md)

## LOC-014 — Treasure and quest placement surfaces

- **Parent subsystem** — Dungeons
- **Purpose** — Expose authored loot and usable quest markers.
- **Existing implementation** — RDBLayout has fixed treasure assignment and flat processing. Quest Place enumerates dungeon/building markers and binds resources separately from layout.
- **Source** — `Utility/RDBLayout.cs#AssignFixedTreasure`, `Utility/RDBLayout.cs#AddFlats`, `Game/Questing/Place.cs#EnumerateDungeonQuestMarkers`, `Game/Questing/Place.cs#AssignQuestResource`
- **Inputs and outputs** — Block treasure or marker records → loot location or quest binding surface
- **Dependencies** — ITEM-020, QUEST-013, SAVE
- **Edge cases and interactions** — Verify occupied markers and replacement block identity. Loot contents belong to ITEM.
- **Design questions** — Which markers can support multiple resource types?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-014 specification](../../design/systems/LOC/LOC-014.md)

## LOC-015 — Action trigger acceptance and chaining

- **Parent subsystem** — Mechanisms
- **Purpose** — Execute authored dungeon mechanisms.
- **Existing implementation** — Receive rejects disabled or playing objects and filters external triggers by classic action flag. ActionObject links bypass that filter. RDBLayout links nodes and DaggerfallAction can activate the next node.
- **Source** — `Internal/DaggerfallAction.cs#Receive`, `Internal/DaggerfallAction.cs#ActivateNext`, `Utility/RDBLayout.cs#LinkActionNodes`, `Internal/DaggerfallActionCollision.cs`
- **Inputs and outputs** — Trigger, action state and link graph → activation or rejection
- **Dependencies** — MOVE-021, COMBAT-006, QUEST, SAVE
- **Edge cases and interactions** — Test cycles, missing links and concurrent trigger types. Castle Daggerfall has a targeted door override.
- **Design questions** — How should chained actions behave when a node is busy or missing?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-015 specification](../../design/systems/LOC/LOC-015.md)

## LOC-016 — Moving geometry, traps and puzzles

- **Parent subsystem** — Mechanisms
- **Purpose** — Apply action payloads in the location.
- **Existing implementation** — Action handlers cover movement, text/input, teleport, spell casts and health/magicka drain or poison. These are separate payloads on the trigger system.
- **Source** — `Internal/DaggerfallAction.cs#Move`, `Internal/DaggerfallAction.cs#ShowTextWithInput`, `Internal/DaggerfallAction.cs#Teleport`, `Internal/DaggerfallAction.cs#CastSpell`, `Internal/DaggerfallAction.cs#DrainHealth`, `Internal/DaggerfallAction.cs#Poison`
- **Inputs and outputs** — Action data and actor context → mechanism, puzzle or hazard result
- **Dependencies** — CHAR, MAGIC, MOVE, UI, AV
- **Edge cases and interactions** — Representative handlers sampled. Trace individual flags, state transitions and collision before reviewing each puzzle family.
- **Design questions** — Which payloads should be reusable and which should be location-specific?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-016 specification](../../design/systems/LOC/LOC-016.md)

## LOC-017 — Action door locks and motion

- **Parent subsystem** — Mechanisms
- **Purpose** — Run local door behavior after activation.
- **Existing implementation** — ActionDoor exposes lockpicking, bashing, toggle and tween control. Separate sounds are assigned for interiors and dungeons. Toggle can execute a linked action.
- **Source** — `Internal/DaggerfallActionDoor.cs#ToggleDoor`, `Internal/DaggerfallActionDoor.cs#AttemptLockpicking`, `Internal/DaggerfallActionDoor.cs#AttemptBash`, `Internal/DaggerfallActionDoor.cs#RestartTween`, `Internal/DaggerfallActionDoor.cs#ExecuteActionOnToggle`
- **Inputs and outputs** — Door, lock state and trigger → opening, closing, failure or action
- **Dependencies** — MOVE-021, RULE-009, NPC-014, SAVE
- **Edge cases and interactions** — Source marks failed lockpicking skill persistence as TODO. Verify reactivation mid-tween and collider changes.
- **Design questions** — What door state and failed attempts should survive reload?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-017 specification](../../design/systems/LOC/LOC-017.md)

## LOC-018 — Interior and dungeon automap discovery

- **Parent subsystem** — Mapping
- **Purpose** — Reveal geometry as the player explores.
- **Existing implementation** — Automap tracks discovered and visited-in-run segment states, exposes separate interior/dungeon state save and restore paths and can inject mesh/material properties.
- **Source** — `Game/Automap.cs#SaveStateAutomapInterior`, `Game/Automap.cs#SaveStateAutomapDungeon`, `Game/Automap.cs#RestoreStateAutomapDungeon`, `Game/Automap.cs#SetState`
- **Inputs and outputs** — Geometry and visits → discovered state and map presentation
- **Dependencies** — UI, AV, SAVE
- **Edge cases and interactions** — Verify visibility criteria, previous-visit styling and retention limits. Exterior automap is WORLD-016.
- **Design questions** — Which geometry should be revealed by proximity or direct sight?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-018 specification](../../design/systems/LOC/LOC-018.md)

## LOC-019 — Notes and teleporter markers

- **Parent subsystem** — Mapping
- **Purpose** — Annotate explored spaces.
- **Existing implementation** — Automap provides adding/editing and removing user notes on dungeon segments and a separate teleporter marker path.
- **Source** — `Game/Automap.cs#TryToAddOrEditUserNoteMarkerOnDungeonSegmentAtScreenPosition`, `Game/Automap.cs#TryToRemoveUserNoteMarkerOnDungeonSegmentAtScreenPosition`, `Game/Automap.cs#AddTeleporterMarkerOnMap`
- **Inputs and outputs** — Map hit, note text or teleport pair → annotation
- **Dependencies** — UI, SAVE, LOC-016
- **Edge cases and interactions** — Check notes and teleport associations after changing geometry or loading an older save.
- **Design questions** — What annotations should persist across visits?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-019 specification](../../design/systems/LOC/LOC-019.md)

## LOC-020 — Local scene reconstruction and state

- **Parent subsystem** — Persistence
- **Purpose** — Restore mutable objects after rebuilding location geometry.
- **Existing implementation** — Interior scene identity uses map/building keys and dungeon has its own scene name. Action objects, doors and loot have dedicated serializable components. Save loading restores player position and scene state through separate stages.
- **Source** — `Internal/DaggerfallInterior.cs#GetSceneName`, `Internal/DaggerfallDungeon.cs#GetSceneName`, `Game/Serialization/SerializableActionDoor.cs`, `Game/Serialization/SerializableActionObject.cs`, `Game/Serialization/SerializableLootContainer.cs`, `Game/Serialization/SaveLoadManager.cs#LoadGame`
- **Inputs and outputs** — Scene keys, load IDs and saved records → restored local state
- **Dependencies** — SAVE, MOVE-027, DATA-024, QUEST
- **Edge cases and interactions** — Verify missing IDs, replacement data and interrupted actions. Exact restore ordering belongs to SAVE.
- **Design questions** — Which local mutations must be durable?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

[Approved LOC-020 specification](../../design/systems/LOC/LOC-020.md)

## Classic provenance and review sequence

- Classic RMB/RDB records provide geometry references, markers, actions and dungeon composition. DFU implements Unity assembly, overlap culling, the Castle Daggerfall door override and runtime state wiring. Compare actual block files and original behavior before claiming parity.
- Start with one settlement and one multi-entrance interior, then trace a multi-block dungeon with water, an action chain and a quest marker. Save mid-visit and verify doors, loot, automap and arrival markers after reconstruction.
- Scope separates layout and mutable location objects from WORLD streaming, MOVE activation/placement, QUEST binding, and SAVE orchestration. Full action flag coverage, world replacements, serialized Unity assets and runtime geometry remain open.
