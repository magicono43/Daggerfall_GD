# SAVE architecture review

Covers SAVE-001 through SAVE-018 in the [feature catalog](../systems/SAVE_FEATURE_CATALOG.md). Static inspection uses the local DFU 1.1.1 Release snapshot. Exact commit is unavailable in the [repository overview](../00_REPOSITORY_OVERVIEW.md). Paths below are relative to Assets/Scripts.

## Existing architecture

### Slot catalog, previews and entry policy · SAVE-001–005

Game/Serialization/SaveLoadManager.cs enumerates prefixed slot directories, indexes save metadata and resolves named and most recent saves. Metadata and screenshot have separate reads. This lets UI browse without reconstructing game state. Rename rewrites metadata, while DeleteSaveFolder and TryBackupDeletedSaveFolder handle deletion and recovery paths. Keep metadata and preview separate from authoritative game state. Verify discovery with malformed metadata, missing previews and backup failure.

GameManager, save windows and quick actions reach SaveLoadManager through several entry points. QuickSave checks registered vetoes, while Save checks readiness and LoadInProgress without consulting that veto directly. This can support distinct caller policies but requires a clear distinction between mandatory safety gates and optional UI restrictions. Load prevents a second load while busy. Save starts a coroutine and shows no corresponding in-progress guard at its public entry. Overlapping saves or a load during a save are possible concerns when callers bypass normal UI sequencing. Preserve quickload confirmation and keep success notifications tied to actual completion.

### Snapshot, publication and compatibility · SAVE-006–007, 017

SaveGame captures and serializes core data, metadata and several sidecars, then yields twice for screenshot capture. It writes required files sequentially via File.WriteAllText, with additional automap, mod and screenshot writes. An interrupted overwrite can therefore leave files from different generations. No slot-wide commit boundary is visible in this write path. Separate files help inspection and optional recovery, but this requires distinguishing mandatory state from replaceable previews and optional extension data. Capturing some auxiliary data after yielding also raises a snapshot consistency question. Measure capture, JSON allocation and full-screen image costs before optimizing.

Serialize and Deserialize centralize FullSerializer and apply different warning policies. ReadSaveFile catches exceptions and returns an empty string. Missing, unreadable and truly empty files can thus reach the same downstream branch, despite requiring different recovery decisions. Versioned records and localized compatibility handling in individual serializers are useful. Define required sections, migrations and error categories at the save boundary.

Mods provide their own payload types, capture and restore callbacks. GetModDataFilename derives a sidecar name from the mod filename. Save catches individual mod failures and continues, while load can request NewSaveData for a missing sidecar. This limits failure propagation. On an overwrite, failure before replacing a mod file can leave the earlier payload beside newer core state. Document whether optional payload failure drops, retains or invalidates it. Renamed or unavailable packages need a stable identity and an explicit fallback.

### Runtime identity, scene cache and reconstruction · SAVE-008–010, 013–014

ISerializableGameObject exposes LoadID, ShouldSave and state capture/restore. SerializableStateManager maintains registrations and data by object category. Objects register/deregister through lifecycle hooks, while scene builders assign IDs for generated objects. This keeps per-type fields with their owners and supports reconstruction by reference. Zero and colliding IDs affect eligibility. Some components repair collisions by incrementing IDs, which can depend on registration order. Use scoped stable identities where layout changes and mod combinations are supported. See the [LOC review](LOC_ARCHITECTURE_REVIEW.md) for door examples.

CacheScene stores loot and action doors, with empty entries for action objects and enemies. RestoreCachedScene reapplies the supported types and removes the cached entry. Permanent scene tracking controls retention across transitions. This is distinct from native persistence, where SerializableStateManager applies doors/actions to registered scene objects, instantiates enemy records, restores existing loot or creates custom drop containers, and emits spawn notifications on reconstructed enemies. Preserve the distinction between a new spawn and reconstruction. Specify which state is intended to survive leaving a scene.

SerializablePlayer maps player state and item collections, then links equipment by UID. ItemCollection restores distinct records without merging them. This is a useful ownership model. Missing item definitions, duplicate UIDs, missing equipment references and effect sources need explicit compatibility decisions. See the [ITEM](ITEM_ARCHITECTURE_REVIEW.md) and [MAGIC](MAGIC_ARCHITECTURE_REVIEW.md) reviews.

### Native loading and completion · SAVE-011–012, 015–016

LoadGame clears movement/actions, quests, scene cache and player state before reading and decoding save files. It restores time, discovery, factions, quests, dialogue, notebook and variants in phases. House and other interior context can be needed before rebuilding geometry. RestorePositionHelper requests placement, and the coroutine waits for IsRespawning plus an extra registration frame before RestoreSaveData. This ordering acknowledges real dependencies. It also makes readiness depend on polling and frame timing. Separate preflight from destructive changes and define which sidecars can safely fail after reconstruction starts.

Load(int) sets loadInProgress and starts the coroutine. Missing SerializablePlayer or PlayerEnterExit can yield break before the normal flag clear. The unbalanced branches are confirmed. The gameplay gate and subsequent loads observe that flag. The load popup is issued at initiation, while OnLoad follows core restoration, optional automap/mod work, orphan cleanup and legal standing clamping. Preserve a completion boundary after committed gameplay state, with explicit failure and cleanup on every path. See the [CORE review](CORE_ARCHITECTURE_REVIEW.md).

### Classic import · SAVE-018

Game/Utility/StartGameBehaviour.cs StartFromClassicSave uses API/Save/SaveGames.cs, SaveTree and SaveVars to translate legacy character, location, time, factions and other records. It shares new-character cleanup and applies conversion-specific rules. This is a useful compatibility adapter boundary. Cleanup before slot/file validation can discard current state on an invalid import. Validate source and supported records before replacing a session. Preserve classic fixtures separately from native schema migrations.

## Proposed recommendations

| ID and features | Existing evidence and assessment | Proposed architecture and benefit | Alternatives and trade-offs | Complexity, impact, timing, priority, confidence and status |
| --- | --- | --- | --- | --- |
| SAVE-AR-01 · SAVE-001–006, 017 | SaveGame writes files in place across several steps. Save has no visible save-busy guard. Required files and optional preview/mod data can diverge. | Serialize one accepted snapshot per operation. Publish a staged generation with a manifest or single committed bundle. Keep a last usable generation and expose committed/failed outcomes. Treat previews as optional and serialize competing slot operations. | A single file simplifies publication but reduces independent inspection. A staged directory retains sidecars and needs a platform-safe publish/recovery scheme. Test interruption and permissions rather than assuming filesystem guarantees. | Large · CORE, UI, MOD, DATA, DEV · establish before public save format · Critical · high static confidence · Proposed |
| SAVE-AR-02 · SAVE-005, 011–016, 018 | LoadGame resets before validation and has early exits that leave busy set. Readiness relies on respawn and a frame wait. Classic import also cleans before validation. | Preflight and migrate required data before session replacement. Apply early context, reconstruct world, wait for explicit registration readiness, restore owners, reconcile optional data and publish completion once. Clear operation state on all failures and define fallback if reconstruction has started. | Full rollback is costly for scene and quest state. Preflight plus a usable menu fallback is simpler. A coroutine can remain the implementation if phase outcomes are explicit. | Large · CORE, WORLD, MOVE, LOC, CHAR, QUEST, UI, TIME · establish early · Critical · high source confidence · Proposed |
| SAVE-AR-03 · SAVE-008–010, 013–016 | Registries and per-type serializers preserve ownership. IDs can derive from layout or collision repair. Scene cache covers fewer categories than native saves. | Use stable scoped IDs and explicit policies for matching, creating or skipping records. Preserve separate transition cache and durable state contracts. Resolve inventory and world references after their owners register, and tag reconstruction events. | Fixed layout indices work with unchanged content and can remain in compatibility adapters. Full scene snapshots improve continuity for dynamic geometry but increase size and make updates harder. | Large · LOC, ITEM, WORLD, NPC, MAGIC, QUEST, MOD · define identity early · Critical · high structural confidence · Proposed |
| SAVE-AR-04 · SAVE-002, 006–007, 010, 015, 017–018 | Versioned records coexist with owner-specific fallbacks, string-empty read failures and mod filename payloads. | Define required and optional sections, explicit versions and stable mod keys. Validate and migrate before applying. Report absent, malformed and incompatible payloads separately, with explicit per-owner recovery. Keep classic input as an adapter. | Per-section migration supports independent evolution but adds coordination. A single schema version is enough until sections actually need independent compatibility. Retaining unknown mod data costs space and is useful only if reattachment is supported. | Medium to large · DATA, MOD, CHAR, QUEST, FACT, UI, DEV · define policy early, add migrations as needed · Recommended · high structural confidence · Proposed |

## Comparison

| Concern | DFU | Proposed Godot design |
| --- | --- | --- |
| Slot publication | Sequential writes to metadata, state and sidecars | Staged generation with a single publication outcome |
| Loading | Reset, decode and frame-based reconstruction | Preflight and explicit restore phases with guaranteed cleanup |
| Object identity | Type registries, LoadIDs and scene cache | Scoped IDs and documented reconstruction policies |
| Compatibility | Versioned records and owner-specific fallback | Validated section migrations and explicit optional-data recovery |

Verify overlapping requests, interrupted writes, corrupt metadata and required/optional payloads, missing components, restore ordering, object ID collisions, cached scenes, mod removal and representative classic slots. Profile snapshot, screenshot and reconstruction costs before optimizing. No runtime, profiling or classic parity tests were performed.
