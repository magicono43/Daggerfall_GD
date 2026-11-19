# CORE-004 — Startup setup routing

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose

Route startup through required setup or to the main menu, with predictable access to configuration and original-game content validation.

## Intended player experience

First launch guides the player to required original Daggerfall content. Later launches reach the main menu without unnecessary setup. Missing content and startup failures explain how to recover. Optional configuration remains easy to reopen without incidental keyboard input changing launch behavior.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Original Daggerfall ARENA2 content is required as external game data. This is distinct from writable application storage.
- Successful normal launch opens the main menu. Setup appears only when required or explicitly requested; do not automatically start or load a character.
- Provide a clearly labeled Settings/Setup entry on the main menu and an optional Show setup at startup preference. Do not use DFU's any-key-during-startup trigger.

Second interview, confirmed by the user on 2026-11-05:

- Accept either ARENA2 itself or its immediate parent Daggerfall folder. Show the resolved ARENA2 path and remember it after successful validation.
- Missing/invalid data shows what failed with Choose Folder, Retry and Quit. Block the normal main menu until required data validates. Error UI must work without ARENA2 assets.
- Require data selection when no valid location is known. Display, audio and control setup remain optional with usable defaults. Show setup at startup defaults off; players can enable it or reopen setup from the main menu.

Third interview, confirmed by the user on 2026-11-05:

- On every launch, recheck the remembered location for required files and basic readability. Detailed content-format requirements belong to DATA; startup checks do not guarantee every asset is intact.
- In portable mode, store the ARENA2 path relative to the executable when the data lies inside the portable installation folder. Keep external content paths absolute. This does not change CORE-001 writable storage selection.
- Allow changing the data folder from main-menu setup. Validate the candidate before replacing the remembered path; safely persist it before offering restart. A changed source requires application restart, with the current source retained until then. In-session settings must not switch data sources.

Fourth interview, confirmed by the user on 2026-11-05:

- Use only the remembered content path or an explicitly selected folder. Do not scan drives or silently select another ARENA2 copy.
- Optional setup may return to the main menu when required checks have passed. Canceling the folder picker leaves the current selection unchanged. Mandatory setup cancellation returns to the setup/error screen; Quit remains available.
- If opening the main menu fails, show an error screen independent of ARENA2 assets with Retry, Return to Setup and Quit. Do not report a failed transition as successful. Ignore repeated Continue clicks while a transition is underway.

## Inherited approved requirements

CORE-001 selects storage and blocks gameplay when required storage is unavailable; explicit startup fallback follows its rules. CORE-002 file logging is optional and failure warns without blocking play. CORE-003 initializes/validates settings, handles recovery and blocks startup when settings cannot safely be persisted. These requirements are not waived by startup routing. No approved setting application behavior beyond these features is inferred.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/Utility/SceneControl.cs`, Start: apply resolution/fullscreen, then open the setup wizard if IsPathValidated is false, ShowOptionsAtStart is true or Input.anyKey is true; otherwise load game scene index 1. Startup scene index is 0.

`Assets/Scripts/DaggerfallUnity.cs`, SetupArena2Path: resolve and validate original data sources. `Assets/Scripts/Game/UserInterfaceWindows/DaggerfallUnitySetupGameWizard.cs`: validated data plus options/input can skip to options; Browser_OnPathChanged validates candidates and disables confirmation on invalid content; Browser_OnConfirmPath saves the selected path then changes the active source. Wizard stages eventually load the game scene.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per repository overview. Source remains unchanged. These observations are not intended requirements unless explicitly accepted.

## Detailed routing and dependency rules

Resolve usable writable storage through CORE-001, initialize optional logging through CORE-002 when the root is available, and obtain validated/persisted settings through CORE-003 before relying on the remembered content path or startup preference. Logging failure alone must not prevent routing. Storage/settings recovery retains its own required screens and explicit choices.

Validate the remembered ARENA2 location on every launch. If no valid location is available, enter mandatory data setup rather than the normal main menu. Accept ARENA2 or its immediate parent, resolve the actual ARENA2 directory and show it. Validate a selected candidate and safely persist the accepted path through CORE-003 before proceeding. An invalid candidate or failed save is not a successful setup completion.

When required checks pass, open optional setup if explicitly requested or Show setup at startup is enabled; otherwise open the main menu. Optional display/audio/control pages do not become mandatory merely because data selection was required. Continue from completed setup opens the main menu without starting/loading a character. Canceling optional setup returns to the menu when required checks remain satisfied.

At first setup, successful validation and persistence permit initial activation of the selected source. A later change made from main-menu setup is pending until application restart: retain the running source, save the new path before offering restart, and reevaluate it at the next launch. Returning to the current menu does not activate the pending source. In-session settings must not switch source. If activation fails on the next launch, show mandatory data recovery rather than silently returning to another copy.

For portable installs, encode internal content paths relative to the executable directory; resolve against that directory, not a variable working directory. External content paths remain absolute. This is content-location configuration, not permission to change writable roots. Do not copy, repair or migrate original data automatically as part of routing.

## Relevant formulas and parameters

No gameplay formulas or balance parameters apply. Show setup at startup is a boolean defaulting to false. Source selection accepts the selected directory itself or its immediate ARENA2 child, not a recursive search. Main-menu eligibility requires successful mandatory storage/settings/content checks. Optional setup selection is explicit request or startup preference; arbitrary key state is not a trigger.

## Required data

Remembered content path and its absolute/executable-relative interpretation; resolved ARENA2 location; content validation result with failure details; startup preference; required storage/settings readiness; setup context (mandatory or optional); candidate path and pending-restart status; transition-in-progress and result. The path and preference persist via CORE-003; transient navigation and busy state do not belong to character saves.

DATA must supply the required-file/readability criteria and detailed validation rules. This specification does not invent the exact ARENA2 file manifest or guarantee every asset's integrity. A remembered path is not proof of current availability.

## Inputs, outputs and events

Inputs: launch readiness, settings, content validation, explicit setup request, folder selection/cancellation, Continue/Retry/Return to Setup/Quit and scene-loading outcomes. Outputs: mandatory setup, optional setup, main menu, failure screen or quit; accepted persisted path; pending-restart indication; transition completion/failure. These are conceptual outcomes rather than approved API or signal names. Serialize routing transitions so repeated Continue cannot create duplicate menu loads.

## Cross-system interactions

CORE-001 owns root choice and storage recovery; CORE-002 owns optional diagnostics; CORE-003 owns settings validation, safe persistence and recovery. DATA validates external ARENA2 and reports actionable failures. UI supplies startup/error screens that do not depend on ARENA2 assets. CORE-005 will define scene/service lifetime, and CORE-006 will define display and other preference application. Session entry features own new/load operations after reaching the main menu. This feature does not approve numeric scene indexes, singleton design or display-test behavior.

## Edge cases and failure conditions

- Moved, disconnected or unreadable remembered content returns to mandatory setup, with Choose Folder, Retry and Quit. Do not scan for replacements.
- Invalid selected content shows validation details; cancellation leaves the committed selection unchanged. An explicit incompatible reset or settings-storage failure follows CORE-003 rather than bypassing it.
- The source may disappear after a successful check. Do not claim every later content operation is safe; actual failures must be surfaced. Runtime content-loss recovery beyond startup/menu loading remains DATA/session scope.
- A candidate may validate but fail persistence. Do not announce successful completion or offer restart until the required save succeeds. Keep the existing active source in a running application.
- Moving a portable installation with internal ARENA2 should preserve executable-relative resolution; moving only the executable away from its data may require selecting again. External absolute paths are not automatically rewritten.
- If a main-menu transition fails, retain a usable independent error UI with Retry/Return to Setup/Quit. Retry means another transition attempt, not an unbounded automatic loop.
- Concurrent/repeated Continue actions must not produce duplicate transitions. Any key held during launch must not independently open optional setup.
- Show setup at startup does not bypass required validation, and canceling mandatory setup never reaches the normal main menu without satisfying required checks.

No numerical balance effects apply. The main risks are bypassing validation, silently selecting different content, and committing a candidate without persistence. Original external content is a read-only input for this feature; write access is not a validation requirement.

## Configuration and balancing options

Players configure the remembered ARENA2 location and Show setup at startup. Main-menu Settings/Setup provides explicit access. Display/audio/control editing is optional; exact defaults and application rules belong to those features. No arbitrary-key launch trigger, drive scan, silent source fallback or automatic character start/load is included.

## Save/load considerations

Content location and startup preference are application settings under the selected CORE-001 root, not character-save fields. Character loads do not change source or clear a pending restart. Save-to-content compatibility checks remain SAVE/DATA responsibilities; selecting a valid directory does not prove a particular save is compatible. Switching writable storage roots does not migrate settings or content paths automatically.

## Technical constraints

Target project engine: Godot 4.7.2. Use startup and error UI that can render before original content is available. Keep routing outcomes distinct from scene-load initiation and only report successful arrival after the main menu is ready. Concrete scene resources, state implementation, signal names and content-reader APIs are deferred. Reuse approved storage/settings contracts; source-path restart rules do not authorize live source replacement.

## Acceptance criteria

1. Original ARENA2 is required. A fresh install without a valid remembered path enters mandatory data setup rather than the normal main menu.
2. Folder selection accepts ARENA2 itself or its immediate parent, displays the resolved location, validates it and safely saves the accepted path before proceeding.
3. Each launch rechecks required files/basic readability. Invalid or unavailable data shows failure details with Choose Folder/Retry/Quit, using UI independent of ARENA2 assets.
4. No drive scan or silent selection of another content copy occurs. Folder-picker cancellation does not alter the committed selection.
5. With required checks satisfied and the startup preference off, launch opens the main menu without starting or loading a character.
6. Show setup at startup defaults off; enabling it opens optional setup after required checks. Explicit main-menu Settings/Setup access works; incidental startup key input does not trigger setup.
7. Display/audio/control configuration is optional. Optional cancellation returns to the menu; mandatory cancellation returns to setup/error, with Quit available and no validation bypass.
8. Internal portable content uses executable-relative paths and survives moving the complete installation; external paths remain absolute and writable-root policy stays unchanged.
9. A main-menu source change validates and saves before restart is offered. The old source remains active until application restart; in-session settings do not switch sources. Next launch validates the pending path.
10. Main-menu transition failure shows Retry/Return to Setup/Quit, does not report success and does not leave only a broken content-dependent UI. Repeated Continue clicks cause at most one active transition.
11. Required storage/settings failures retain CORE-001/003 recovery and block entry as specified. File-logging failure alone does not block launch. Failed path persistence is not treated as successful setup.

These are future verification criteria. No implementation/runtime tests have been performed in this design phase.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001, CORE-002 and CORE-003 v1, the decision log, CORE catalog and CORE architecture review. All 12 interview decisions are represented. No conflict identified: external read-only content selection is distinct from writable-root selection, settings persist through CORE-003, and logging stays optional. CORE-005/006 and broader CORE architecture proposals remain open; this document does not implicitly approve them.

## Outstanding questions and approval

No blocking player-policy choice is currently identified. DATA must define the precise required-file and validation contract before implementation of content checks can be considered complete. Deferred details also include platform path normalization, folder-picker/UI wording, scene resources, transition API and optional settings-page layout. These deferrals do not waive the acceptance criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-004. This document is finalized v1. Approval reference: CORE-004-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented deferrals, including DATA's precise validation contract, remain deferred. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
