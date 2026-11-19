# CORE feature catalog

CORE coordinates application startup, configuration, session entry and shared runtime state. See [master catalog](../01_MASTER_SYSTEMS_CATALOG.md) and [dependency overview](../02_INITIAL_DEPENDENCY_OVERVIEW.md). The baseline is the local 1.1.1 Release snapshot described in the [repository overview](../00_REPOSITORY_OVERVIEW.md).

Source paths are relative to `Assets/Scripts/` except `ProjectSettings/`. Implementation describes static code observations. Edge cases distinguish visible branches from follow-up checks. Complexity estimates the review and design scope. Confidence rates the source trace. Design questions are open. Feature IDs are stable within CORE.

## CORE-001 — Persistent storage mode

- **Parent subsystem** — Bootstrap
- **Purpose** — Select the application data root.
- **Existing implementation** — Outside the editor, Portable.txt beside the application selects PortableAppdata under the executable base directory. Otherwise Unity supplies the persistent directory. The decision and path are cached. A conditional editor-only branch can use a separate .devenv directory.
- **Source** — DaggerfallUnityApplication.cs — IsPortableInstall, InitializePersistentPath, SubsystemInit
- **Inputs and outputs** — Marker file, editor context and platform path → persistent root for settings and other consumers.
- **Dependencies** — SAVE, MOD, DEV
- **Edge cases and interactions** — Portable directory creation has no local recovery in InitializePersistentPath. Verify platform permissions and whether the compile-time development branch is enabled in a given build.
- **Design questions** — Should storage mode be fixed at launch? How should an unwritable root be surfaced?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-001 — approved specification](../../design/systems/CORE/CORE-001.md). Storage mode is selected at launch, with explicit startup recovery and no automatic root switching. Approval reference: CORE-001-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical source-analysis questions above are resolved for intended behavior by this specification.

## CORE-002 — Startup log retention

- **Parent subsystem** — Bootstrap
- **Purpose** — Keep startup diagnostics across launches.
- **Existing implementation** — SubsystemInit installs a custom Unity log handler under its play/install-mode guard. The handler replaces Player-prev.log with the old Player.log when present and opens a new auto-flushing log.
- **Source** — DaggerfallUnityApplication.cs — SubsystemInit, InitLog, LogHandler
- **Inputs and outputs** — Persistent root and Unity log events → current log and up to one previous log.
- **Dependencies** — CORE-001, DEV
- **Edge cases and interactions** — Rotation exceptions are written to the new log if it can be created. File creation occurs outside that catch. Verify behavior for concurrent launches.
- **Design questions** — How much history and what failure feedback should be retained?
- **Complexity** — Small
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-002 — approved specification](../../design/systems/CORE/CORE-002.md). Retain the current and one previous launch, capped at 200 MiB per file, with non-blocking failure warnings. Approval reference: CORE-002-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification.

## CORE-003 — Settings initialization and recovery

- **Parent subsystem** — Configuration
- **Purpose** — Supply a usable settings profile at boot.
- **Existing implementation** — Creates a missing user INI from the defaults resource. A parse exception leads to backup, then to recreated defaults if backup also fails. Writes a backup after parsing and then synchronizes the key/section structure against defaults. Portable mode has path conversion on save.
- **Source** — SettingsManager.cs — LoadSettings, SaveSettings, ReadSettingsFile, WriteSettingsFile, SyncIniData
- **Inputs and outputs** — Defaults TextAsset, user profile and backup → typed settings and persisted INI.
- **Dependencies** — CORE-001, DATA, INIFileParser
- **Edge cases and interactions** — Backup is written before synchronization. Write exceptions are logged. Verify malformed values, migration of unknown keys and failures creating the initial file.
- **Design questions** — Which settings survive version changes, and how should recovery be communicated?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-003 — approved specification](../../design/systems/CORE/CORE-003.md). Preserve valid preferences, validate defaults and settings, use protected writes and explicit version migrations, and recover through validated backup or defaults while preserving damaged input. Approval reference: CORE-003-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification.

## CORE-004 — Startup setup routing

- **Parent subsystem** — Bootstrap
- **Purpose** — Choose setup or the game scene.
- **Existing implementation** — Applies display mode, then opens the setup wizard if ARENA2 validation fails, startup options are enabled or Unity reports any key at that check. Otherwise loads scene index 1. The setup wizard also has paths to load game and startup scenes.
- **Source** — Game/Utility/SceneControl.cs — Start, StartupSceneIndex, GameSceneIndex; DaggerfallUnity.cs — SetupArena2Path, IsPathValidated; Game/UserInterfaceWindows/DaggerfallUnitySetupGameWizard.cs — SceneManager.LoadScene call sites
- **Inputs and outputs** — Validation flag, startup setting, key state and display settings → setup message or scene transition.
- **Dependencies** — DATA, UI, CORE-003; ProjectSettings/EditorBuildSettings.asset
- **Edge cases and interactions** — The check uses input state at Start. The routing constants depend on build order. Inspect scene wiring and test the setup flow with missing or invalid data.
- **Design questions** — What should trigger setup, and how should players reopen it?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-004 — approved specification](../../design/systems/CORE/CORE-004.md). Require validated external ARENA2, route successful normal launches to the main menu, provide explicit setup access and recover failed transitions without bypassing startup checks. Approval reference: CORE-004-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification; detailed content validation remains a DATA dependency.

## CORE-005 — Scene services and manager lifetime

- **Parent subsystem** — Bootstrap
- **Purpose** — Give gameplay coordination access to scene components and shared services.
- **Existing implementation** — GameManager installs a persistent singleton, rejects duplicates in play, and caches services from component, object-name or tag lookups. Start records shadow distance and pauses the game.
- **Source** — Game/GameManager.cs — Awake, Start, SetupSingleton, GetMonoBehaviour, GetGameObjectWithTag, GetGameObjectWithName
- **Inputs and outputs** — Scene components and tags → service references and a paused initial runtime.
- **Dependencies** — UI, MOVE, WORLD, SAVE, AV
- **Edge cases and interactions** — Missing or duplicate objects affect lookup. C# describes the expected scene contract, while prefab and scene bindings need inspection. Verify lookup after scene reload.
- **Design questions** — What should be guaranteed before the session can start, and how should missing services be reported?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-005 — approved specification](../../design/systems/CORE/CORE-005.md). Explicitly own and bind application/session/location services, validate readiness before gameplay, and safely tear down scopes while rejecting stale callbacks. Approval reference: CORE-005-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification.

## CORE-006 — Applying runtime preferences

- **Parent subsystem** — Configuration
- **Purpose** — Apply configuration to the running game.
- **Existing implementation** — StartGameBehaviour applies resolution, camera and controller settings, effect settings, background behavior, VSync, textures, HUD and weapon preferences, sneak toggle and terrain range. It assigns target frame rate only with VSync off and a value of at least 30.
- **Source** — Game/Utility/StartGameBehaviour.cs — ApplyStartSettings, DeployCoreGameEffectSettings; Game/GameManager.cs — UpdateShadowResolution, UpdateShadowDistance
- **Inputs and outputs** — Settings and startup flags → Unity runtime properties and feature component settings.
- **Dependencies** — CORE-003, CORE-005, MOVE, UI, AV, WORLD, COMBAT
- **Edge cases and interactions** — Camera and HUD updates are conditional on objects being present. Handedness branch sets horizontal flip for value 1. The target-rate branch has no reset for other values. Verify live reapplication.
- **Design questions** — Which preferences apply live, and which require a reload?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-006 — approved specification](../../design/systems/CORE/CORE-006.md). Stage changes with Apply/Cancel, declare activation timing, confirm display tests within 15 real-time seconds, and distinguish effective, pending and unsaved values. Approval reference: CORE-006-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification; individual setting contracts remain feature-owned.

## CORE-007 — Session start dispatch

- **Parent subsystem** — Session entry
- **Purpose** — Route a requested start to its mode-specific path.
- **Existing implementation** — Update checks the StartMethod field, pauses, dispatches after disabling world parents, and clears the request after dispatch returns. Dispatch clears SaveIndex on normal completion. LastStartMethod is set in individual paths.
- **Source** — Game/Utility/StartGameBehaviour.cs — Update, InvokeStartMethod, StartMethods, SaveIndex, LastStartMethod
- **Inputs and outputs** — Requested mode and optional save index → selected session-entry operation.
- **Dependencies** — CORE-008 through CORE-014, LOC, UI
- **Edge cases and interactions** — There is one request slot. An exception before cleanup can bypass field reset. Disabling parents happens even before a load path validates its index.
- **Design questions** — What request and recovery semantics should apply if entry fails or two requests arrive close together?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-007 — approved specification](../../design/systems/CORE/CORE-007.md). Coordinate one session-changing operation at a time, validate consistent input before destructive replacement, confirm live-session discard, and publish truthful terminal outcomes with safe cleanup/retry. Approval reference: CORE-007-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification; individual entry-mode behavior remains separately reviewed.

## CORE-008 — Title return and death return

- **Parent subsystem** — Session entry
- **Purpose** — Return to the menu and reset transient presentation and quest state.
- **Existing implementation** — Both title paths raise OnNewGame, return UI to HUD, clear quests, disable world parents, reset weapon presentation and signal OnStartMenu. Death return resets the death camera and posts the death-specific UI message unless PostStartMessage overrides it.
- **Source** — Game/Utility/StartGameBehaviour.cs — StartTitleMenu, StartTitleMenuFromDeath, ResetWeaponManager; Game/PlayerDeath.cs — TitleMenuFromDeath assignment
- **Inputs and outputs** — Title/death request and optional message → menu transition, reset and state notification.
- **Dependencies** — CORE-007, CORE-015, CHAR, QUEST, COMBAT, UI
- **Edge cases and interactions** — OnNewGame also fires for title and void modes. The death handler writes TitleMenu into StartMethod, but the dispatcher then clears the field in the same Update.
- **Design questions** — Which session state should be discarded on death versus voluntary return?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-008 — approved specification](../../design/systems/CORE/CORE-008.md). Use shared safe teardown with distinct voluntary/death reasons. Death return plays the original skippable video, silently bypasses playback failure and does not replay completed presentation on menu retry. Approval reference: CORE-008-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification.

## CORE-009 — Worldless startup

- **Parent subsystem** — Session entry
- **Purpose** — Allow a session entry that suppresses normal world parents.
- **Existing implementation** — StartVoid raises OnNewGame, returns to HUD, clears quests, disables parents, resets weapon state, sets NoWorld and posts a default or overridden initialization message.
- **Source** — Game/Utility/StartGameBehaviour.cs — StartVoid, NoWorld, PostStartMessage
- **Inputs and outputs** — Void request and optional UI message → disabled world parents and initialization message.
- **Dependencies** — CORE-007, DEV, UI, QUEST, LOC
- **Edge cases and interactions** — The method sets NoWorld without clearing it and has no explicit OnStartMenu or OnStartGame dispatch. Verify intended scene and tool consumers.
- **Design questions** — Is a worldless mode needed for authoring or testing, and when should it end?
- **Follow-up verification (2026-11-05)** — The setup castle backdrop is a separate path: Game/UserInterfaceWindows/DaggerfallUnitySetupGameWizard.cs, CreateBackdrop creates CUSTAA06.RMB and clears the temporary background texture; ShowResolutionPanel/ShowOptionsPanel invoke it. DaggerfallUnityStartup.unity binds SceneControl and has no direct StartGameBehaviour script GUID reference. DaggerfallUnityGame.unity binds StartGameBehaviour with StartMethod 2 (TitleMenu) and NoWorld 0. This supports distinguishing setup-backdrop rendering from StartVoid; it does not establish StartVoid's original intended use. No CORE-009 requirements have been approved.
- **Complexity** — Small
- **Analysis confidence** — High
- **Review status** — Deferred — user decision on 2026-11-05; revisit when a clear purpose emerges. No gameplay specification approved.

### My Intended Specification

See [CORE-009 — deferral record](../../design/systems/CORE/CORE-009.md), decision CORE-009-D01. Earlier development-mode suggestions remain unapproved. The setup castle backdrop is a separate path and does not justify specifying worldless startup.

## CORE-010 — Fresh-session reset

- **Parent subsystem** — New-character initialization
- **Purpose** — Clear shared state before replacing the character context.
- **Existing implementation** — NewCharacterCleanup resets UID generation, quests, UI stack, save scene cache, guild memberships, map discovery and ship state. It raises OnNewGame before resetting the weapon manager. New character and classic import share this reset.
- **Source** — Game/Utility/StartGameBehaviour.cs — NewCharacterCleanup, RaiseOnNewGameEvent; DaggerfallUnity.cs — ResetUID
- **Inputs and outputs** — New-character or classic-import request → cleared shared state and reset event.
- **Dependencies** — QUEST, UI, SAVE, FACT, WORLD, ECON, COMBAT
- **Edge cases and interactions** — Classic import invokes cleanup before validating the index or opening the save. Subscriber side effects and event ordering need a separate inventory.
- **Design questions** — At what point should a new session replace the old state?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-010 — approved specification](../../design/systems/CORE/CORE-010.md). Establish an ordered clean baseline once per replacement session, preserve restored identities/state, separate starting grants and retain only caches without previous-character state. Approval reference: CORE-010-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification.

## CORE-011 — New-character placement

- **Parent subsystem** — New-character initialization
- **Purpose** — Choose the initial playable context.
- **Existing implementation** — Assigns the supplied CharacterDocument or creates a default, sets classic start time and player minute tracking, then looks up the configured map cell. Enters a dungeon only when the setting is enabled and a dungeon is found. Otherwise enables exterior and requests origin reposition. NoWorld bypasses placement.
- **Source** — Game/Utility/StartGameBehaviour.cs — StartNewCharacter; Game/Player/CharacterDocument.cs; Utility/ContentReader.cs — HasLocation, GetLocation
- **Inputs and outputs** — Character document, StartCellX/Y, StartInDungeon, NoWorld and location records → initial character, clock and world context.
- **Dependencies** — CORE-010, CHAR, DATA, TIME, WORLD, LOC
- **Edge cases and interactions** — Failed location lookup falls back to exterior. StreamingWorld checks guard coordinate changes. Starting content and markers depend on external records.
- **Design questions** — What should determine starting location, and what fallback should apply when content is unavailable?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-011 — approved specification](../../design/systems/CORE/CORE-011.md). Default to Privateer's Hold's original deep-cave new-game spawn, retain an explicit exterior-start preference, validate safe placement and keep entry gated until required initialization completes. Approval reference: CORE-011-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification; exact original marker/facing and calendar values remain verification dependencies.

## CORE-012 — Starting grants and opening quests

- **Parent subsystem** — New-character initialization
- **Purpose** — Finalize starting resources and activate opening content.
- **Existing implementation** — Applies biography effects, invokes replaceable starting gear and spell delegates, captures the skill baseline, initializes bank/houses/region/weather, unpauses and fades from black. Starts _TUTOR__ and _BRISIEN, consumes an optional LaunchQuest, runs quest-list startup entries and raises OnStartGame.
- **Source** — Game/Utility/StartGameBehaviour.cs — Awake, StartNewCharacter, SetStartingSpells, AssignStartingEquipment, AssignStartingSpells; Game/Questing/QuestListsManager.cs — InitAtGameStartQuests
- **Inputs and outputs** — Biography, grant delegates, quest identifiers and lists → initialized player and world state, running quests and start event.
- **Dependencies** — CORE-011, CHAR, ITEM, MAGIC, ECON, TIME, QUEST, MOD, UI
- **Edge cases and interactions** — Quest startup follows unpause in source order. Exact starting grants and quest behavior belong to feature owners and loaded content.
- **Design questions** — Which grants and opening quests are mandatory, optional or selected by character origin?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-012 — approved specification](../../design/systems/CORE/CORE-012.md). Preserve class/biography starting-resource baseline and optional tutorial participation; prepare required startup state, present immediate opening popups sequentially before player control, and prevent duplicate grants/quests. Approval reference: CORE-012-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification; exact balance tables, visible popup order and exterior tutorial adaptation remain owner dependencies.

## CORE-013 — Native save session entry

- **Parent subsystem** — Session entry
- **Purpose** — Hand off a selected native save and re-enter play on load notification.
- **Existing implementation** — The dispatch path skips index -1, otherwise enumerates saves and calls SaveLoadManager.Load. StateManager responds to OnLoad by firing OnStartNewGame and selecting Game. StartGameBehaviour can consume LaunchQuest on the same load event.
- **Source** — Game/Utility/StartGameBehaviour.cs — LoadDaggerfallUnitySave, SaveLoadManager_OnLoad; Game/StateManager.cs — SaveLoadManager_OnLoadHandler; Game/Serialization/SaveLoadManager.cs — Load, OnLoad
- **Inputs and outputs** — SaveIndex or external load request, optional LaunchQuest → SAVE handoff and successful-load event effects.
- **Dependencies** — CORE-007, CORE-015, SAVE, QUEST
- **Edge cases and interactions** — Index -1 returns after dispatch has already paused and disabled world parents. Verify which UI entry paths use the dispatcher versus direct SAVE calls and how load failure recovers.
- **Design questions** — When should control return on load failure, and should load and new game publish distinct notifications?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-013 — approved specification](../../design/systems/CORE/CORE-013.md). Load this Godot implementation's own saves with consistent preflight validation, clean scoped restoration, contextual pose/activity readiness and one truthful Session Restored outcome. DFU/classic compatibility is outside current scope. Approval reference: CORE-013-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification; detailed SAVE/domain contracts remain dependencies.

## CORE-014 — Classic save session entry

- **Parent subsystem** — Session entry
- **Purpose** — Translate classic state into a playable DFU session.
- **Existing implementation** — Accepts slots 0–5, opens classic save files and uses saved world coordinates, view and clock. Imports character, items/spells, factions/globals, memberships, banking, regional legal and weather state, among other fields. Recreates transformation effects through DFU bundles, then resumes play and raises OnStartGame.
- **Source** — Game/Utility/StartGameBehaviour.cs — StartFromClassicSave, RestoreOldClassSpecials; API/Save/SaveGames.cs; API/Save/CharacterRecord.cs; API/Save/SaveVars.cs
- **Inputs and outputs** — Classic save records and NoWorld → reconstructed session state.
- **Dependencies** — CORE-010, SAVE, DATA, WORLD, CHAR, ITEM, MAGIC, FACT, ECON, TIME, LAW
- **Edge cases and interactions** — Invalid slot or unopened save root throws. Failure opening a slot posts a message and returns. Import strips the classic weather fog flag and swaps weather codes 5 and 6. Classic save fixtures are needed to establish coverage.
- **Design questions** — Which classic states should import faithfully, degrade with a message, or be unsupported?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Outside current scope — per approved CORE-013-D01 / CORE-013-A01; recorded for CORE-014 on 2026-11-05. No import specification approved.

### My Intended Specification

See [CORE-014 — scope record](../../design/systems/CORE/CORE-014.md). Focus remains this Godot implementation's own saves. Retain classic-import analysis for possible future reconsideration; do not infer import requirements from the historical questions above. Original ARENA2 content loading remains in scope independently.

## CORE-015 — Session state and notifications

- **Parent subsystem** — Play gating
- **Purpose** — Track lifecycle state for systems observing session events.
- **Existing implementation** — Starts in Setup for startup scene or Start otherwise. Menu, start/load, window changes and death drive state transitions. ChangeState stores LastState, emits OnStateChange, then updates GameInProgress when entering Start or Game.
- **Source** — Game/StateManager.cs — StateTypes, ChangeState, UIManager_OnWindowChangeHandler, StartGameBehaviour_OnStartGameHandler, SaveLoadManager_OnLoadHandler
- **Inputs and outputs** — Lifecycle and window events → current/previous state and GameInProgress flag.
- **Dependencies** — CORE-008, CORE-012 through CORE-014, CORE-016, UI, CHAR, SAVE
- **Edge cases and interactions** — Callbacks see GameInProgress before the transition updates it. Empty stack restores LastState if unpaused, otherwise selects None. Window changes are ignored outside an in-progress game.
- **Design questions** — Which state transitions should subscribers observe and at what point?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-015 — approved specification](../../design/systems/CORE/CORE-015.md). Separate lifecycle from overlays/suspension, commit consistent snapshots before ordered notifications, distinguish milestones and enforce scope-safe observation/transition authority. Approval reference: CORE-015-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification; detailed pause/input policies remain CORE-016 scope.

## CORE-016 — Pause, input and HUD coordination

- **Parent subsystem** — Play gating
- **Purpose** — Suspend scaled gameplay and restore the previous play context.
- **Existing implementation** — PauseGame stores and zeros time scale, pauses input and optionally hides HUD. Resume restores saved scale/input and a HUD hidden by that call, with IME recovery. The UI stack also pauses or resumes based on window policy.
- **Source** — Game/GameManager.cs — PauseGame; Game/UserInterface/UserInterfaceManager.cs — PushWindow, PopWindow, ChangeWindow
- **Inputs and outputs** — Pause request, current scale and window policy → time scale, input gate, HUD and IME state.
- **Dependencies** — CORE-015, MOVE, UI, TIME
- **Edge cases and interactions** — Repeated pause calls do not acquire separate ownership or apply a new hideHUD request. Verify nested windows and startup/load pause interactions.
- **Design questions** — Who owns pause when several conditions overlap? Which clocks should continue?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-016 — approved specification](../../design/systems/CORE/CORE-016.md). Use independent suspension ownership, separate HUD/input/audio policies, focus-loss suspension and coherent nested-window handoff; resume only when reasons and lifecycle permit. Approval reference: CORE-016-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification; detailed cadence and TIME/AV contracts remain owner dependencies.

## CORE-017 — Active gameplay and classic cadence

- **Parent subsystem** — Play gating
- **Purpose** — Gate gameplay-level processing and provide a classic-style tick signal.
- **Existing implementation** — IsPlayingGame checks explicit pause, save-manager availability/loading, and whether the top window requests pause. FixedUpdate clears the signal when inactive, otherwise accumulates delta time and sets the signal at 0.0625 seconds, resetting the accumulator to zero.
- **Source** — Game/GameManager.cs — IsPlayingGame, FixedUpdate, classicUpdateInterval
- **Inputs and outputs** — Pause/load/UI state and fixed-step time → gameplay gate and classicUpdate pulse.
- **Dependencies** — CORE-016, UI, SAVE, TIME
- **Edge cases and interactions** — Accumulator remainder is discarded at threshold and the inactive branch does not reset the timer. This is explicitly a DFU approximation of the original loop. Verify consumers and timing in play.
- **Design questions** — Which systems require original-like cadence, and what timing drift is acceptable?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-017 — approved specification](../../design/systems/CORE/CORE-017.md). Share authoritative simulation eligibility, deliver ordered explicit slow steps, retain fractional time/backlog and bound catch-up without paused-time debt or duplicate continuation work. Approval reference: CORE-017-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Frequency, workload allowance, prolonged-overload policy, exact ordering and save-phase behavior remain explicit owner decisions.

## CORE-018 — Gameplay shortcuts and quick actions

- **Parent subsystem** — Play gating
- **Purpose** — Route player shortcuts during active gameplay.
- **Existing implementation** — Update dispatches completed actions as UI messages for options, common windows, status and automap. Quick actions use action-start events. Prevented quicksave shows a localized message. Quickload prompts only if the current character has a quicksave.
- **Source** — Game/GameManager.cs — Update, IsPlayingGame; Game/InputManager.cs — Actions; Game/Serialization/SaveLoadManager.cs — IsSavingPrevented, HasQuickSave, PromptQuickLoadGame
- **Inputs and outputs** — Input actions and save eligibility → UI messages, save request or load confirmation.
- **Dependencies** — CORE-017, UI, MOVE, SAVE, DATA
- **Edge cases and interactions** — Window shortcuts in the else-if chain have priority by order. Escape, status and automap have independent checks. Quicksave precedes quickload if both start together.
- **Design questions** — Which actions may coexist and which require confirmation or feedback?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-018 — approved specification](../../design/systems/CORE/CORE-018.md). Route configurable context-aware shortcuts through explicit arbitration and owner validation; use stable current-character quick targets, safe save/load paths and truthful feedback. Approval reference: CORE-018-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Historical design questions above are resolved by this specification; exact bindings/priorities and SAVE target retention remain owner dependencies.

## CORE-019 — Rest interruption and nearby threat query

- **Parent subsystem** — Shared gameplay coordination
- **Purpose** — Expose a shared rest veto and proximity signal.
- **Existing implementation** — Registered callbacks can return a blocking message. The threat query checks active enemies, sight, classic spawn eligibility and hostility, plus nearby foe spawners. When resting, an enemy unaware of the player is excluded beyond 12 Unity units before the other checks.
- **Source** — Game/GameManager.cs — GetPreventedRestMessage, RegisterPreventRestCondition, UnregisterPreventRestCondition, AreEnemiesNearby; ActiveGameObjectDatabase.cs; Game/EnemySenses.cs
- **Inputs and outputs** — Rest callbacks and enemy/spawner state → veto message or nearby-threat flag.
- **Dependencies** — TIME, NPC, COMBAT, MOD
- **Edge cases and interactions** — Null veto messages become empty strings. Default query excludes pacified/player-allied enemies through the hostility/team condition. Spawners use a separate distance test. Rest flow and all query callers remain separate review topics.
- **Design questions** — Which threats and other conditions should prevent starting or continuing rest?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-019 — approved specification](../../design/systems/CORE/CORE-019.md). Use purpose-specific threat data, structured scoped rest restrictions and fresh boundary checks; interrupt without undoing committed time or auto-restarting, with player-safe explanations. Approval reference: CORE-019-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Exact thresholds, boundary order and eligible-spawner policy remain owner decisions.

## CORE-020 — Encounter coordination hooks

- **Parent subsystem** — Shared gameplay coordination
- **Purpose** — Expose encounter notifications and bulk enemy operations.
- **Existing implementation** — GameManager publishes encounter and enemy-spawn events and provides enemy counting, clearing and hostility operations using active enemy state.
- **Source** — Game/GameManager.cs — RaiseOnEncounterEvent, RaiseOnEnemySpawnEvent, HowManyEnemiesOfType, ClearEnemies, MakeEnemiesHostile; ActiveGameObjectDatabase.cs
- **Inputs and outputs** — Enemy registry and caller requests → counts, state changes or event notifications.
- **Dependencies** — NPC, COMBAT, QUEST, MOD
- **Edge cases and interactions** — Active registry scope and caller/subscriber sets require follow-up. Encounter selection and spawn rules belong to NPC and QUEST.
- **Design questions** — Which callers need bulk enemy operations or spawn notifications, and what should qualify as active?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-020 — approved specification](../../design/systems/CORE/CORE-020.md). Distinguish committed encounter activation/actor availability and origins, scope queries and owner-validated bulk mutations, report partial results and protect against duplicate/stale work and unauthorized hostility overrides. Approval reference: CORE-020-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Exact count semantics and domain consequences remain owner dependencies.

## CORE-021 — Quit and return-to-setup actions

- **Parent subsystem** — Bootstrap
- **Purpose** — End the application or reopen setup through runtime UI entry points.
- **Existing implementation** — Title and setup windows can call Application.Quit. The setup wizard has a startup-scene reload path. DaggerfallUI also handles a quit message. ExitGame has an Escape-to-quit component implementation.
- **Source** — Game/UserInterfaceWindows/DaggerfallStartWindow.cs; Game/UserInterfaceWindows/DaggerfallUnitySetupGameWizard.cs; Game/DaggerfallUI.cs; Game/ExitGame.cs — Update
- **Inputs and outputs** — UI action, quit message or component input → application quit or scene reload.
- **Dependencies** — CORE-004, UI, SAVE
- **Edge cases and interactions** — ExitGame scene attachment has not been verified. Unity platform and editor behavior govern the quit call; inspect confirmation and unsaved-state handling at each entry point.
- **Design questions** — Which exits require confirmation and which preserve an active session?
- **Complexity** — Small
- **Analysis confidence** — Medium
- **Review status** — Approved — specification finalized v1 on 2026-11-05.

### My Intended Specification

See [CORE-021 — approved specification](../../design/systems/CORE/CORE-021.md). Coordinate quit/OS close and explicit restart with progress confirmation, safe operation completion/teardown, truthful preference recovery and preserved setup paths. Approval reference: CORE-021-A01 in the [decision log](../../design/GAMEPLAY_DECISIONS.md). Platform relaunch and detailed owner implementation contracts remain dependencies.

## Classic inheritance and unresolved evidence

- CORE-011 explicitly uses the classic start-time helper. CORE-014 interprets original save values through DFU conversions. Original clock, camera, weather and save semantics need classic fixtures or direct comparison.
- CORE-017 explicitly approximates original update timing. CORE-019 uses a DFU classic spawn-eligibility predicate. Source establishes the compatibility intent. Matching original timing or threat behavior requires observation.
- CORE-012 uses specific quest identifiers and configurable grants. Original-game provenance and effective quest behavior require inspecting the scripts, tables and active data sources. Scene assignments and prefab overrides may change which start options are used.
- Prioritize CORE-007/010/013/014 failure paths, CORE-015/016/017 event ordering across menus and save loads, and CORE-004/005/009/021 scene binding checks. Trace classic import with representative fixtures after the native session lifecycle is understood.
- World assembly, save schema, rest mechanics, quest grammar, dialogue, and rendering algorithms remain with their respective catalog systems. This pass samples CORE handoffs into those systems.

