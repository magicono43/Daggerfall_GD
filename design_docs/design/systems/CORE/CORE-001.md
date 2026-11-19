# CORE-001 — Persistent storage mode

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05. System: CORE — Runtime coordination.

## Gameplay purpose and intended player experience

Provide predictable writable storage for player data. Standard installations use per-user storage; portable installations carry their data with them. Storage failures identify the affected location and provide recovery choices. Development runs keep normal player data separate by default.

## Confirmed requirements: detailed rules and behaviors

The user confirmed these requirements over five interview rounds and approved the assembled specification. See CORE-001-D01 through D15 and CORE-001-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md).

1. Use standard per-user storage by default, with optional portable storage.
2. A Portable.txt marker beside the executable selects PortableAppdata beside that executable. Defer the standard directory's final name until the game has a name.
3. Select mode at launch. Changing modes requires restart. Explicit startup fallback is permitted before gameplay; never switch roots automatically or during gameplay.
4. Saves, settings, logs, writable mod data and disposable caches follow the selected root. Installed game assets remain separate.
5. Switching modes does not copy or move data. Explain that each location exposes its own data and switching does not move saves. Migration tooling and arbitrary custom paths are outside initial scope.
6. Editor/development runs use separate storage by default. Testing against normal player storage requires an explicit choice and respects exclusive-use protection.
7. Before gameplay, check required directory creation and temporary file write, read and removal. Passing this check does not guarantee future writes.
8. For an unwritable portable root, identify the failed path and offer Retry, explicit use of standard storage, and Quit. Never silently fall back.
9. Standard-storage fallback lasts for this launch only. Preserve the marker and attempt portable storage next launch if it remains present. Do not migrate data on fallback.
10. If standard storage is unavailable, show the failed path with Retry and Quit. Block gameplay until required storage is usable.
11. Failures confined to logs or disposable caches permit play. Warn if file logging is unavailable; recreate disposable caches when possible. Required save, settings or mod-data storage failures block startup.
12. On storage failure during gameplay, retain the session in memory, clearly report failed saves and allow retry. Do not automatically pause or switch roots. Never report failed saves as successful. Continued play risks losing progress if storage cannot be restored before exit.
13. Only one running instance may use a particular root. A second instance explains that the directory is in use and offers Retry or Quit. Instances using separate roots may run concurrently.
14. Exclusive-use protection belongs to the process and releases on exit or crash. A leftover lock file alone must never permanently block the player.

## Relevant formulas and parameters

No gameplay formulas, random rolls or balance values apply. Fixed portable names are Portable.txt and PortableAppdata. Required categories are saves, settings and writable mod data; optional categories are logs and disposable caches. No disk-space threshold or automatic retry interval has been agreed.

## Required data

Launch context includes normal versus editor/development, executable location, standard per-user location, marker presence and explicit development-storage choice. Runtime storage context includes selected mode/root, current-launch fallback, exclusive-use ownership, readiness and failure details identifying the affected path and operation. Mode/fallback are launch state, not character-save state.

## Inputs, outputs and events

Inputs: launch context, filesystem and lock results, and player recovery choices. Outputs: a usable selected root, blocked startup or quit, and actionable failure information. Consumers need readiness, loss-of-availability and recovery outcomes. These are conceptual outcomes; public API and event names remain implementation details.

## Cross-system interactions

CORE selects/validates the root and coordinates startup recovery. SAVE uses it and reports actual save/load outcomes; SAVE retains file format, durability and backup responsibilities. Settings and MOD consumers use it for writable data. DEV logging/cache consumers tolerate optional failures. UI presents paths, recovery choices and the explanation that roots have separate data. Installed content paths remain outside this feature.

## Edge cases and failure conditions

Read-only installs, full disks, missing directories and disconnected portable drives can cause required operations to fail. Apply the startup or runtime policy above. A successful probe does not validate existing file contents, prove all existing files are writable or guarantee future capacity; consumers must report actual operation results.

Distinguish isolated optional-category failure from required-root failure. Startup probes must not overwrite existing user files. Required saves/settings/mod state must not be treated as disposable caches.

Concurrent launches must not both acquire one root. Different supported path aliases referring to the same directory must not bypass exclusion. Crash recovery must permit later acquisition without manual deletion of a stale marker. Process locking and drive disconnection behavior require validation on supported platforms.

Changing mode can reveal a different save collection; this is not deletion and must not trigger automatic migration. There are no numerical balance effects; the principal corruption risk is competing writers bypassing exclusive use.

## Configuration and balancing options

Player choices are marker presence between launches and explicit startup fallback. Normal-storage testing requires an explicit development choice. No live mode switching, custom-root selector, automatic migration or balance tuning is included.

## Save/load considerations

Discover and write saves under the current launch's root. Loading a character must not select another root. Fallback exposes standard data without importing portable data. Preserve live state on runtime failure and allow retry without claiming persistence succeeded. Save atomicity, schema migrations, backups and partial-write recovery remain SAVE responsibilities; they are not implicitly approved here.

## Technical constraints

Project target: Godot 4.7.2. Implementation can differ from DFU while preserving these behaviors. Select storage before persistent consumers start. Use process-owned exclusion rather than lock-file presence alone. Recovery UI must work without file logging. Temporary probes must not overwrite user data. This specification selects no Godot API, locking library or save-write mechanism.

## Acceptance criteria

1. Normal launch without a marker uses standard storage; with a marker it uses PortableAppdata beside the executable.
2. Marker changes during a launch do not switch roots; restart reevaluates selection.
3. All agreed writable categories follow the root, installed assets remain separate, and switching modes leaves existing data in place.
4. Development/editor runs default to separate storage; explicit normal-storage access respects exclusive use.
5. Required startup checks exercise directory creation and temporary write/read/removal without overwriting user data. Required failures block gameplay and identify the failed path.
6. Portable failure offers Retry, standard storage and Quit. Standard failure offers Retry and Quit. No silent fallback occurs.
7. Explicit fallback neither moves saves nor changes the marker; next launch attempts portable mode again while the marker remains.
8. Optional log/cache failure permits play, warns about unavailable file logging and allows disposable cache recreation when possible.
9. Runtime save failure retains live state, reports failure and permits retry without automatic pause or root switch. Failed saves are never reported as successful.
10. Two processes cannot use the same root concurrently, including through supported aliases. A blocked instance offers Retry/Quit; separate roots work concurrently.
11. Normal exit and forced termination release exclusive use. Leftover lock-file presence alone does not block later use.

These are future verification requirements. No implementation or runtime tests were performed during specification.

## Existing Daggerfall Unity behavior — reference only

Source: [DaggerfallUnityApplication.cs](../../../../reference_material/daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/DaggerfallUnityApplication.cs), IsPortableInstall, InitializePersistentPath, SubsystemInit and LogHandler. Outside the editor, Portable.txt selects PortableAppdata; otherwise Unity supplies its persistent directory. Mode/path are cached. Portable directory creation has no local recovery. The optional separate editor-path definition is commented out. SettingsManager, SaveLoadManager and mod-data consumers use the root. Other DFU policies are not adopted by implication.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable, as recorded in [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source code remains unchanged.

## Consistency review

Reviewed on 2026-11-05 against the decision log, CORE catalog, CORE architecture review and architectural decision register. No other approved feature specifications were found under docs/design. All 15 confirmed decisions are represented. No contradictions with approved requirements were identified. CORE-AR-01 and the GAD proposals remain Proposed; approving this feature does not approve unrelated settings durability, log retention or save architecture.

## Outstanding questions and deferred details

No blocking gameplay questions remain. Deferred details: final application name/standard directory, supported-platform path conventions and locking validation, exact development-storage selector, child-directory names and public API signatures. These deferrals do not waive acceptance criteria. Logging retention and save-write durability belong to separate specifications.

## Approval

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-001. This document is finalized v1. Deferred details above remain deferred. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
