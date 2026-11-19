# SAVE feature catalog

Static analysis of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Source paths are relative to `Assets/Scripts/Game/Serialization/`. Symbols follow `#`. Confidence rates the sampled trace.

## SAVE-001 — Save path and slot enumeration

- **Parent subsystem** — Slots
- **Purpose** — Locate named saves.
- **Existing implementation** — Enumeration scans numbered folders matching the save prefix and requires a save-info file. Name lookup and most-recent selection use the enumerated catalog.
- **Source** — `SaveLoadManager.cs#EnumerateSaveFolders`, `SaveLoadManager.cs#FindSaveFolderByNames`, `SaveLoadManager.cs#FindMostRecentSave`
- **Inputs and outputs** — Save root and metadata → indexed slots
- **Dependencies** — CORE-001, UI-010
- **Edge cases and interactions** — Metadata presence alone does not establish a loadable payload.
- **Design questions** — Which incomplete slots should be visible?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-001 — Save path and slot enumeration](../../design/systems/SAVE/SAVE-001.md)

## SAVE-002 — Slot metadata and preview

- **Parent subsystem** — Slots
- **Purpose** — Identify and preview a save.
- **Existing implementation** — SaveGame captures character name, slot name, game time, save version and DFU version, and captures a screen image after two end-of-frame yields.
- **Source** — `SaveLoadManager.cs#SaveGame`, `SaveLoadManager.cs#GetSaveInfo`, `SaveLoadManager.cs#GetSaveScreenshot`
- **Inputs and outputs** — Snapshot and screen → metadata and preview
- **Dependencies** — UI-010, AV
- **Edge cases and interactions** — Screenshot timing differs from state capture and UI hiding is TODO.
- **Design questions** — Should previews reflect the scene at the instant of capture?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-002 — Slot metadata and preview](../../design/systems/SAVE/SAVE-002.md)

## SAVE-003 — Rename, deletion and backup

- **Parent subsystem** — Slots
- **Purpose** — Maintain existing slots.
- **Existing implementation** — SaveLoadManager exposes rename and deletion operations and a deleted-folder backup path.
- **Source** — `SaveLoadManager.cs#Rename`, `SaveLoadManager.cs#DeleteSaveFolder`, `SaveLoadManager.cs#TryBackupDeletedSaveFolder`
- **Inputs and outputs** — Slot key and action → metadata or folder changes
- **Dependencies** — UI-010, CORE-001
- **Edge cases and interactions** — Trace collision, backup failure and filesystem recovery before design review.
- **Design questions** — How should deleted slots be recovered?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-003 — Rename, deletion and backup](../../design/systems/SAVE/SAVE-003.md)

## SAVE-004 — Save gating and quicksave

- **Parent subsystem** — Entry
- **Purpose** — Expose manual and quick save requests.
- **Existing implementation** — Save and QuickSave are separate entry methods, and the manager allows registered predicates to prevent saving. GameManager checks the gate for the shortcut.
- **Source** — `SaveLoadManager.cs#Save`, `SaveLoadManager.cs#QuickSave`, `SaveLoadManager.cs#RegisterPreventSaveCondition`, `../GameManager.cs#Update`
- **Inputs and outputs** — Save request and prevention conditions → save or denial
- **Dependencies** — CORE-018, UI, MOD
- **Edge cases and interactions** — Check consistency between shortcut, UI and direct callers.
- **Design questions** — Which runtime states should block saving?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-004 — Save gating and quicksave](../../design/systems/SAVE/SAVE-004.md)

## SAVE-005 — Load selection and quickload confirmation

- **Parent subsystem** — Entry
- **Purpose** — Select and start a native load.
- **Existing implementation** — Load accepts a key or character/name. Quickload has presence and confirmation helpers. The key path starts the load coroutine.
- **Source** — `SaveLoadManager.cs#Load`, `SaveLoadManager.cs#QuickLoad`, `SaveLoadManager.cs#HasQuickSave`, `SaveLoadManager.cs#PromptLoadGame`
- **Inputs and outputs** — Slot and confirmation → load request
- **Dependencies** — UI-010, CORE-013, CORE-018
- **Edge cases and interactions** — Verify missing slot and concurrent request handling.
- **Design questions** — Should different load entry points share confirmation?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized from Draft v2 on 2026-11-17

### My Intended Specification

[SAVE-005 — Load selection and quickload confirmation](../../design/systems/SAVE/SAVE-005.md)

## SAVE-006 — Snapshot and multi-file writing

- **Parent subsystem** — Format
- **Purpose** — Persist core and subsystem state.
- **Existing implementation** — SaveGame builds core data and separate JSON for factions, quests, discovery, conversation, notebook and variants. It writes files sequentially using File.WriteAllText and has a separate quest-exception file.
- **Source** — `SaveLoadManager.cs#SaveGame`, `SaveLoadManager.cs#WriteSaveFile`, `SerializableGameObject.cs`
- **Inputs and outputs** — Runtime records → slot files
- **Dependencies** — QUEST, FACT, WORLD, NPC, MOD
- **Edge cases and interactions** — No atomic multi-file commit is visible in this write path. Check partial overwrite and disk failure.
- **Design questions** — What recovery should interrupted writes support?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-006 — Snapshot and multi-file writing](../../design/systems/SAVE/SAVE-006.md)

## SAVE-007 — Serialization and compatibility

- **Parent subsystem** — Format
- **Purpose** — Read typed records and support older shapes.
- **Existing implementation** — Manager uses FullSerializer helpers with an assert-success option. Core and subsystem records have versioned types. Player restoration includes compatibility checks for old regional and progression data.
- **Source** — `SaveLoadManager.cs#Serialize`, `SaveLoadManager.cs#Deserialize`, `SerializableGameObject.cs`, `SerializablePlayer.cs`
- **Inputs and outputs** — Typed records or JSON → saved or restored data
- **Dependencies** — DATA, CHAR-017, MOD
- **Edge cases and interactions** — Audit migrations individually. Save version metadata and record type suffixes are separate evidence.
- **Design questions** — Which old formats should remain loadable?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-007 — Serialization and compatibility](../../design/systems/SAVE/SAVE-007.md)

## SAVE-008 — Stateful object registration and identity

- **Parent subsystem** — World state
- **Purpose** — Associate runtime objects with saved records.
- **Existing implementation** — SaveLoadManager forwards registration to SerializableStateManager, which groups stateful objects by type. Door, action, enemy and loot restoration use their own paths.
- **Source** — `SaveLoadManager.cs#RegisterSerializableGameObject`, `SaveLoadManager.cs#DeregisterAllSerializableGameObjects`, `SerializableStateManager.cs#RegisterStatefulGameObject`, `SerializableGameObject.cs`
- **Inputs and outputs** — Component and load identity → restorable registry entry
- **Dependencies** — LOC, ITEM, NPC
- **Edge cases and interactions** — Verify duplicate IDs, timing of registration and removal on teardown.
- **Design questions** — How should stable load IDs be assigned and validated?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-008 — Stateful object registration and identity](../../design/systems/SAVE/SAVE-008.md)

## SAVE-009 — Scene cache and permanent scenes

- **Parent subsystem** — World state
- **Purpose** — Preserve selected state across local revisits.
- **Existing implementation** — CacheScene stores loot and action-door records, with empty enemy/action-object entries. Restore removes the consumed cache entry. Partial clear keeps permanent scene caches and strips corpse markers.
- **Source** — `SerializableStateManager.cs#CacheScene`, `SerializableStateManager.cs#RestoreCachedScene`, `SerializableStateManager.cs#ClearSceneCache`, `SerializableStateManager.cs#AddPermanentScene`
- **Inputs and outputs** — Scene name, registered state and permanence → cached or restored scene data
- **Dependencies** — LOC-020, ECON-013, ECON-015, ITEM
- **Edge cases and interactions** — Scene cache scope differs from a full save. Verify repeated visits and expiry.
- **Design questions** — Which local changes survive leaving and returning?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-009 — Scene cache and permanent scenes](../../design/systems/SAVE/SAVE-009.md)

## SAVE-010 — Player snapshot and inventory references

- **Parent subsystem** — World state
- **Purpose** — Reconstruct character-owned state.
- **Existing implementation** — SerializablePlayer captures and restores character state. Item collections restore records and equipment resolves saved slot UIDs against restored items.
- **Source** — `SerializablePlayer.cs`, `../Items/ItemCollection.cs#DeserializeItems`, `../Items/ItemEquipTable.cs#DeserializeEquipTable`
- **Inputs and outputs** — Player, item and equipment records → live character
- **Dependencies** — CHAR-017, ITEM-025, MAGIC-010, LAW-016
- **Edge cases and interactions** — Check restore order for effects, equipped items and missing custom types.
- **Design questions** — Which derived values should be rebuilt?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-010 — Player snapshot and inventory references](../../design/systems/SAVE/SAVE-010.md)

## SAVE-011 — Reset and early contextual restore

- **Parent subsystem** — Load sequence
- **Purpose** — Prepare the correct world before spawning.
- **Existing implementation** — LoadGame clears death presentation, input, quest state, scene cache and player state. It raises OnStartLoad, restores time early for season, sets interior compensation height and restores or clears discovery. Interior layout also has early context restoration.
- **Source** — `SaveLoadManager.cs#LoadGame`, `SaveLoadManager.cs#RestoreDateTimeData`, `SaveLoadManager.cs#RaiseOnStartLoadEvent`
- **Inputs and outputs** — Save payload and current session → reset state and early world inputs
- **Dependencies** — TIME-018, WORLD-018, CORE, FACT
- **Edge cases and interactions** — Reset precedes some file reads and prerequisite checks. Verify recovery on parse failure or missing components.
- **Design questions** — When should a load replace the active session?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-011 — Reset and early contextual restore](../../design/systems/SAVE/SAVE-011.md)

## SAVE-012 — World placement and registration wait

- **Parent subsystem** — Load sequence
- **Purpose** — Rebuild location before applying object state.
- **Existing implementation** — LoadGame calls RestorePositionHelper, restores travel map and climbing settings, waits for respawn completion and yields one more frame for registration before RestoreSaveData.
- **Source** — `SaveLoadManager.cs#LoadGame`, `SaveLoadManager.cs#RestoreSaveData`, `../PlayerEnterExit.cs#RestorePositionHelper`
- **Inputs and outputs** — Position, context and registration state → reconstructed scene ready for restore
- **Dependencies** — MOVE-027, WORLD-003, LOC-020
- **Edge cases and interactions** — Verify incomplete respawn and late registration. The sampled wait loop has no local timeout.
- **Design questions** — What readiness criteria should a load enforce?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-012 — World placement and registration wait](../../design/systems/SAVE/SAVE-012.md)

## SAVE-013 — Door and action state restore

- **Parent subsystem** — World state
- **Purpose** — Reapply local mechanism changes.
- **Existing implementation** — SerializableStateManager exposes separate door and action-object restoration paths. Dedicated components carry object-specific state.
- **Source** — `SerializableStateManager.cs#RestoreActionDoorData`, `SerializableStateManager.cs#RestoreActionObjectData`, `SerializableActionDoor.cs`, `SerializableActionObject.cs`
- **Inputs and outputs** — Saved mechanism and matching scene identity → restored mechanism
- **Dependencies** — LOC-015, LOC-017
- **Edge cases and interactions** — Check moved or missing doors and interrupted tweens.
- **Design questions** — Which transient mechanism states should resume?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-013 — Door and action state restore](../../design/systems/SAVE/SAVE-013.md)

## SAVE-014 — Enemy and loot reconstruction

- **Parent subsystem** — World state
- **Purpose** — Restore actors and containers after scene assembly.
- **Existing implementation** — Enemy restore instantiates prefab, sets load ID, restores state and emits spawn event. Loot restore updates existing matching objects or recreates missing custom drops.
- **Source** — `SerializableStateManager.cs#RestoreEnemyData`, `SerializableStateManager.cs#RestoreLootContainerData`, `SerializableEnemy.cs`, `SerializableLootContainer.cs`
- **Inputs and outputs** — Enemy and container records → reconstructed entities and contents
- **Dependencies** — NPC-024, ITEM-022, COMBAT-021
- **Edge cases and interactions** — Verify dead foes, quest drops and missing non-custom scene containers.
- **Design questions** — Which objects may be recreated when scene identity is missing?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-014 — Enemy and loot reconstruction](../../design/systems/SAVE/SAVE-014.md)

## SAVE-015 — Quest, faction and exploration sidecars

- **Parent subsystem** — Load sequence
- **Purpose** — Rehydrate state that crosses scene boundaries.
- **Existing implementation** — LoadGame reads separate faction, quest, conversation, notebook, discovery and variant files. World variant restoration precedes position restore. Automap is restored after object state, with a logged failure path.
- **Source** — `SaveLoadManager.cs#LoadGame`, `../Questing/QuestMachine.cs#RestoreSaveData`, `../TalkManager.cs#RestoreConversationData`, `../Automap.cs#SetState`
- **Inputs and outputs** — Optional subsystem payloads → reconstructed cross-system state
- **Dependencies** — QUEST-022, FACT-018, NPC-024, WORLD-018, LOC-018
- **Edge cases and interactions** — Fallback differs by file. Verify stale state, corrupt sidecars and changed content.
- **Design questions** — Which sidecars are required for a usable load?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-015 — Quest, faction and exploration sidecars](../../design/systems/SAVE/SAVE-015.md)

## SAVE-016 — Post-load cleanup and completion

- **Parent subsystem** — Load sequence
- **Purpose** — Signal when play can resume.
- **Existing implementation** — After object and automap restoration, load removes orphaned quest items, restores mods, clamps legal reputation, clears loadInProgress, requests fade and raises OnLoad.
- **Source** — `SaveLoadManager.cs#LoadGame`, `SaveLoadManager.cs#RemoveAllOrphanedItems`, `SaveLoadManager.cs#RaiseOnLoadEvent`
- **Inputs and outputs** — Reconstructed state → cleanup and completion notification
- **Dependencies** — QUEST, LAW, CORE-015, UI
- **Edge cases and interactions** — Verify subscriber assumptions and partial-load branches that exit before completion.
- **Design questions** — What should OnLoad guarantee?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-016 — Post-load cleanup and completion](../../design/systems/SAVE/SAVE-016.md)

## SAVE-017 — Mod save payloads

- **Parent subsystem** — Extensions
- **Purpose** — Persist mod-owned state independently.
- **Existing implementation** — The manager names separate mod files. Load enumerates mods with save interfaces, deserializes existing files or calls NewSaveData, then calls RestoreSaveData. A per-mod exception logs and shows feedback.
- **Source** — `SaveLoadManager.cs#SaveGame`, `SaveLoadManager.cs#GetModDataFilename`, `SaveLoadManager.cs#LoadGame`
- **Inputs and outputs** — Enabled mod, save type and file → restored or default mod state
- **Dependencies** — MOD, DATA
- **Edge cases and interactions** — Verify renamed, disabled or incompatible mods and preservation of their data after resaving.
- **Design questions** — How should mod state migrate when its schema changes?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17

### My Intended Specification

[SAVE-017 — Mod save payloads](../../design/systems/SAVE/SAVE-017.md)

## SAVE-018 — Classic save import

- **Parent subsystem** — Compatibility
- **Purpose** — Translate legacy game state into a DFU session.
- **Existing implementation** — StartFromClassicSave reads the classic save tree and variables through API readers. It assigns character, items, faction, region and banking state before resuming. CORE-014 describes conversion boundaries.
- **Source** — `../Utility/StartGameBehaviour.cs#StartFromClassicSave`, `../../API/Save/SaveGames.cs`, `../../API/Save/SaveTree.cs`, `../../API/Save/SaveVars.cs`
- **Inputs and outputs** — Classic slot and records → imported session
- **Dependencies** — CORE-014, CHAR, DATA, FACT, ECON
- **Edge cases and interactions** — Representative legacy fixtures are needed to establish unsupported records and outcome parity.
- **Design questions** — Which legacy fields must survive import?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Outside current scope under approved CORE-013. Reviewed 2026-11-17.

### My Intended Specification

[SAVE-018 — Classic save import scope record](../../design/systems/SAVE/SAVE-018.md)

## Classic provenance and next review steps

Classic save records are an import source. Native JSON, scene caching and mod save hooks are DFU paths. Compare original fixtures for classic field semantics and unsupported records.

Trace a native interior save with an action door, quest foe and dropped item through reconstruction. Then test missing or corrupt sidecars, an interrupted overwrite, and older saves with absent fields. Include an enabled mod whose restore throws. Scene assets, full field-level migration coverage and runtime failure recovery remain unverified.
