# DEV feature catalog

Static analysis of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Paths are relative to the source snapshot root, with symbols after `#`. Confidence rates the sampled trace.

## DEV-001 — Startup log retention

- **Parent subsystem** — Diagnostics
- **Purpose** — Capture failures across launches.
- **Existing implementation** — The application installs a custom log handler in its player startup path. It rotates Player.log to Player-prev.log and auto-flushes the new log.
- **Source** — `Assets/Scripts/DaggerfallUnityApplication.cs#InitLog`, `Assets/Scripts/DaggerfallUnityApplication.cs#LogHandler`
- **Inputs and outputs** — Runtime events and persistent path → current and prior log
- **Dependencies** — CORE-001, CORE-002
- **Edge cases and interactions** — Rotation and file creation have different failure handling. Platform permissions remain untested.
- **Design questions** — Which log history and context should bug reports retain?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-001, approved v1](../../design/systems/DEV/DEV-001.md). [CORE-002](../../design/systems/CORE/CORE-002.md) governs startup log retention and acceptance criteria. Approval is recorded as DEV-001-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-002 — Environment report

- **Parent subsystem** — Diagnostics
- **Purpose** — Collect configuration for troubleshooting.
- **Existing implementation** — PrintInfo builds DFTFU_Environment.log from settings properties, system and culture details and directory information. Classic data setup calls it on a successful runtime path.
- **Source** — `Assets/Scripts/GenerateDiagLog.cs#PrintInfo`, `Assets/Scripts/DaggerfallUnity.cs#SetupArena2Path`
- **Inputs and outputs** — Data path and runtime settings → diagnostic report
- **Dependencies** — DATA-001, CORE-003
- **Edge cases and interactions** — Review paths and settings present in reports before sharing. Verify output on different installs.
- **Design questions** — Which configuration fields belong in a report?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-002, approved v1](../../design/systems/DEV/DEV-002.md) for on-demand previews, approved report fields, privacy rules and local export behavior. Approval is recorded as DEV-002-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-003 — Runtime console and command registry

- **Parent subsystem** — Diagnostics
- **Purpose** — Invoke diagnostics and state inspection in play.
- **Existing implementation** — The registry exposes command registration, lookup, sorted enumeration and dispatch. Command providers include guild, automap and climbing tools.
- **Source** — `Assets/Game/Addons/UnityConsole/Console/Scripts/ConsoleCommandsDatabase.cs#ExecuteCommand`, `Assets/Game/Addons/UnityConsole/Console/Scripts/ConsoleCommandsDatabase.cs#RegisterCommand`, `Assets/Scripts/Game/Guilds/GuildManager.cs#RegisterCommands`, `Assets/Scripts/Game/Automap.cs`
- **Inputs and outputs** — Command name and arguments → callback result
- **Dependencies** — UI, MOD, FACT, LOC
- **Edge cases and interactions** — Commands can mutate state. Audit duplicate names, input capture and build availability.
- **Design questions** — Which commands should be available in player builds?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-003, approved v1](../../design/systems/DEV/DEV-003.md) for player access, pause and live modes, command eligibility, save behavior and mod registration. Approval is recorded as DEV-003-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-004 — Quest debugger and exception records

- **Parent subsystem** — Diagnostics
- **Purpose** — Inspect quest execution during play.
- **Existing implementation** — HUDQuestDebugger exposes an updating HUD and state cycling. QuestMachine stores exceptions and provides logging. Save writes quest exception records separately.
- **Source** — `Assets/Scripts/Game/UserInterface/HUDQuestDebugger.cs#Update`, `Assets/Scripts/Game/UserInterface/HUDQuestDebugger.cs#NextState`, `Assets/Scripts/Game/Questing/QuestMachine.cs#StoreQuestException`, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#SaveGame`
- **Inputs and outputs** — Quest state and exceptions → display and persistent diagnostics
- **Dependencies** — QUEST-023, SAVE, UI
- **Edge cases and interactions** — Verify visibility of protected-quest errors and usefulness of logged source context.
- **Design questions** — Which task, resource and action data should the debugger expose?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-004, approved v1](../../design/systems/DEV/DEV-004.md) for console access, read-only inspection, isolated test controls, bounded traces and local export. [QUEST-023](../../design/systems/QUEST/QUEST-023.md) governs player notices and durable recovery. Approval is recorded as DEV-004-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-005 — Screenshots and debug evidence

- **Parent subsystem** — Diagnostics
- **Purpose** — Capture the current player view.
- **Existing implementation** — PrintScreenManager updates a screenshot action and refreshes its binding. Save previews use a separate capture path.
- **Source** — `Assets/Scripts/Game/Serialization/PrintScreenManager.cs#Update`, `Assets/Scripts/Game/Serialization/PrintScreenManager.cs#GetPrintScreenKeyBind`, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#SaveGame`
- **Inputs and outputs** — Input and frame → screenshot
- **Dependencies** — MOVE-002, SAVE-002, AV
- **Edge cases and interactions** — Check custom directories, capture timing and whether overlays are visible.
- **Design questions** — What UI should appear in diagnostic screenshots?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-005, approved v1](../../design/systems/DEV/DEV-005.md) for full-view PNG captures, the HUD toggle, default and custom destinations, and capture feedback. Approval is recorded as DEV-005-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-006 — Configurable enemy fixture

- **Parent subsystem** — Manual fixtures
- **Purpose** — Set up enemies for repeatable inspection.
- **Existing implementation** — SetupDemoEnemy applies enemy type or career, reaction, gender and optional alliance settings. It exposes grounding alignment and has a paired editor inspector.
- **Source** — `Assets/Scripts/Game/SetupDemoEnemy.cs#ApplyEnemySettings`, `Assets/Scripts/Game/SetupDemoEnemy.cs#AlignToGround`, `Assets/Scripts/Editor/SetupDemoEnemyEditor.cs`
- **Inputs and outputs** — Fixture archetype and settings → configured enemy actor
- **Dependencies** — NPC-005, COMBAT, LOC
- **Edge cases and interactions** — Scene wiring and repeatability need verification. This is a fixture mechanism without an automated assertion in the sampled path.
- **Design questions** — Which enemy scenarios should have reusable fixtures?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-006, approved v1](../../design/systems/DEV/DEV-006.md) for spawning registered enemies and controlling targeted or session-wide enemy AI through the console. Test arenas can be assembled as needed using normal game systems. Approval is recorded as DEV-006-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-007 — Worldless and demo entry points

- **Parent subsystem** — Manual fixtures
- **Purpose** — Isolate game or UI behavior for manual review.
- **Existing implementation** — StartGameBehaviour supports Void and NoWorld entry. Demo windows and a quest demo action exist in source, with independent entry paths to verify.
- **Source** — `Assets/Scripts/Game/Utility/StartGameBehaviour.cs#StartVoid`, `Assets/Scripts/Game/UserInterfaceWindows/DemoFLCWindow.cs`, `Assets/Scripts/Game/UserInterfaceWindows/DemoClassQuestionsWindow.cs`, `Assets/Scripts/Game/Questing/Actions/Demo/JuggleAction.cs`
- **Inputs and outputs** — Startup mode or demo invocation → isolated runtime or demonstration
- **Dependencies** — CORE-009, UI, QUEST
- **Edge cases and interactions** — Confirm actual exposure in the shipped scenes and builds.
- **Design questions** — Which systems should be usable without loading the world?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Deferred by user decision on 2026-11-18.

### My Intended Specification

See the [DEV-007 deferral record](../../design/systems/DEV/DEV-007.md). Reopen when there is a concrete need for a standalone preview or worldless test. Decision DEV-007-D01 is in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-008 — Classic save inspection

- **Parent subsystem** — Authoring
- **Purpose** — Inspect legacy records without importing a live session.
- **Existing implementation** — SaveExplorerWindow exposes an editor menu and GUI for legacy save exploration. The legacy reader API is shared with classic import.
- **Source** — `Assets/Scripts/Editor/SaveExplorerWindow.cs#OnGUI`, `Assets/Scripts/API/Save/SaveGames.cs`, `Assets/Scripts/API/Save/SaveTree.cs`
- **Inputs and outputs** — Classic save files → inspected records
- **Dependencies** — SAVE-018, DATA, Unity Editor
- **Edge cases and interactions** — Test unsupported or malformed saves in an isolated fixture. Field coverage needs inspection.
- **Design questions** — Which records should be available to compare during migration?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Deferred by user decision on 2026-11-18.

### My Intended Specification

See the [DEV-008 deferral record](../../design/systems/DEV/DEV-008.md). Decision DEV-008-D01 is in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-009 — Text, definition and asset inspection/export

- **Parent subsystem** — Authoring
- **Purpose** — Inspect source content and produce authoring inputs.
- **Existing implementation** — Editor tools include a text record viewer, JSON exporter, career viewer, and font/atlas utilities. DATA owns runtime interpretation of those formats.
- **Source** — `Assets/Scripts/Editor/TextRecordViewerWindow.cs#OnGUI`, `Assets/Scripts/Editor/JSONExporterWindow.cs#OnGUI`, `Assets/Scripts/Editor/DaggerfallCareerViewerWindow.cs`, `Assets/Scripts/Editor/FontExporterWindow.cs`, `Assets/Scripts/Editor/AtlasEditorWindow.cs`
- **Inputs and outputs** — Classic files or Unity assets → preview or export
- **Dependencies** — DATA-008, DATA-015, AV, Unity Editor
- **Edge cases and interactions** — Inventory export options and compare round trips before using outputs as fixtures.
- **Design questions** — Which exports need lossless round trips?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-009, approved v1](../../design/systems/DEV/DEV-009.md) for source inspection, schema-preserving editable exports and 3D model viewing with supported mesh and texture exports. Approval is recorded as DEV-009-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-010 — Location and terrain inspectors

- **Parent subsystem** — Authoring
- **Purpose** — Preview and configure scene layout inputs.
- **Existing implementation** — Dedicated Unity editor inspectors exist for locations, interiors, dungeons and StreamingWorld. StreamingWorld exposes editor find and GPS synchronization methods.
- **Source** — `Assets/Scripts/Editor/DaggerfallLocationEditor.cs`, `Assets/Scripts/Editor/DaggerfallInteriorEditor.cs`, `Assets/Scripts/Editor/DaggerfallDungeonEditor.cs`, `Assets/Scripts/Editor/StreamingWorldEditor.cs`, `Assets/Scripts/Terrain/StreamingWorld.cs#__EditorApplyToPlayerGPS`
- **Inputs and outputs** — Scene component and location choice → editor preview or component changes
- **Dependencies** — LOC, WORLD, Unity Editor
- **Edge cases and interactions** — Confirm preview differences from runtime layout and which operations modify scene assets.
- **Design questions** — Which controls should preview versus edit persistent data?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-010, approved v1](../../design/systems/DEV/DEV-010.md) for read-only 3D previews, placement details, optional overlays and validation diagnostics. Approval is recorded as DEV-010-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-011 — RMB block editing

- **Parent subsystem** — Authoring
- **Purpose** — Edit exterior block content and export results.
- **Existing implementation** — RMB Block Editor exposes load/save, object-group import and selection export. Separate editors cover ground, building and scenery content.
- **Source** — `Assets/Game/Addons/RmbBlockEditor/Editor/RmbBlockEditorWindow.cs#LoadFile`, `Assets/Game/Addons/RmbBlockEditor/Editor/RmbBlockEditorWindow.cs#SaveFile`, `Assets/Game/Addons/RmbBlockEditor/Editor/RmbBlockEditorWindow.cs#ExportSelection`
- **Inputs and outputs** — Block or object group and edits → saved or exported content
- **Dependencies** — LOC-001, DATA-005, MOD
- **Edge cases and interactions** — Verify destination and compatibility of authored files without modifying source fixtures.
- **Design questions** — Which edits should be validated before export?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-011, approved v1](../../design/systems/DEV/DEV-011.md) for exterior block editing, reusable object groups, workspace drafts and export validation. Approval is recorded as DEV-011-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-012 — World data editing

- **Parent subsystem** — Authoring
- **Purpose** — Author world replacement object data.
- **Existing implementation** — WorldData Editor exposes position, rotation, scale, faction and action-record controls. Separate helpers address dungeon and building objects.
- **Source** — `Assets/Game/Addons/WorldDataEditor/Editor/WorldDataEditor.cs#GUIElementPosition`, `Assets/Game/Addons/WorldDataEditor/Editor/WorldDataEditor.cs#GUIElementModelActionRecord`, `Assets/Game/Addons/WorldDataEditor/Editor/WorldDataEditorDungeonHelper.cs`, `Assets/Game/Addons/WorldDataEditor/Editor/WorldDataEditorBuildingHelper.cs`
- **Inputs and outputs** — Object and placement edits → world authoring data
- **Dependencies** — MOD-009, LOC, DATA-024
- **Edge cases and interactions** — Verify export identity, replacement precedence and marker stability.
- **Design questions** — How should edits preserve save-compatible identifiers?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-012, approved v1](../../design/systems/DEV/DEV-012.md) for existing and new location authoring, terrain shaping, scoped variants, export validation and save compatibility. Approval is recorded as DEV-012-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-013 — Localization and mod packaging tools

- **Parent subsystem** — Authoring
- **Purpose** — Prepare content for consumption by the runtime.
- **Existing implementation** — Localization importer copies classic records into string tables. Mod editor tools cover metadata, assemblies and dependencies. Runtime lookup and loading are covered by DATA and MOD.
- **Source** — `Assets/Scripts/Localization/DaggerfallStringTableImporter.cs#CopyTextRSCToStringTable`, `Assets/Game/Addons/ModSupport/Editor/CreateModEditorWindow.cs`, `Assets/Game/Addons/ModSupport/Editor/ModAssemblyBuilder.cs`
- **Inputs and outputs** — Classic text, mod sources and manifest → authoring output
- **Dependencies** — DATA-020, MOD-016
- **Edge cases and interactions** — Check serialized settings, target selection and generated artifact validity in Unity.
- **Design questions** — Which packaging checks should be automated?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-013, approved v1](../../design/systems/DEV/DEV-013.md) for localization import previews, selective updates and automated packaging checks. Approval is recorded as DEV-013-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## DEV-014 — Embedded package tests and coverage boundary

- **Parent subsystem** — Tests
- **Purpose** — Identify automated tests visible in the snapshot.
- **Existing implementation** — The embedded Post Processing package contains editor and runtime test assemblies. Runtime tests exercise profile Add, Has, Get, TryGet and Remove settings. The sampled Test attribute search found package tests rather than gameplay fixtures.
- **Source** — `Packages/com.unity.postprocessing/Tests/Runtime/PostProcessingRuntimeTests.cs#Profile_AddSettings`, `Packages/com.unity.postprocessing/Tests/Editor/PostProcessEditorTests.cs`, `Packages/manifest.json`
- **Inputs and outputs** — Package tests and Unity Test Framework → executable test definitions
- **Dependencies** — AV, Unity Editor
- **Edge cases and interactions** — No tests were run. External CI, additional test conventions and gameplay coverage remain unverified. The visible GitHub issue template is not test automation.
- **Design questions** — Which game systems need their own repeatable verification fixtures?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

See [DEV-014, approved v1](../../design/systems/DEV/DEV-014.md) for initial integration coverage, headless and separate rendered suites, isolated fixtures and reproduction reporting. Approval is recorded as DEV-014-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md).

## Classic provenance and next review steps

Classic archives, text and save records are inputs to inspection and authoring. The console, HUD debugger, Unity editor tooling and embedded package tests are DFU or Unity tooling. Compare original data fixtures where a tool claims to expose or export classic records.

Start by tracing one startup diagnostic and one quest failure, then verify an enemy fixture and a world-data export in an isolated copy. Separately establish which Unity tests are discoverable and which gameplay behaviors need fixture coverage. This pass used static inspection. Editor operation, emitted artifacts, runtime availability and external test infrastructure remain open.
