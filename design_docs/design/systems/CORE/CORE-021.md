# CORE-021 — Quit and return-to-setup actions

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Coordinate application shutdown and setup access without silent progress/settings loss, unsafe save interruption or unintended content-source changes.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- In-game Quit and interceptable OS close use one shutdown coordinator. Confirm unsaved-progress loss for a living active session; Cancel preserves it. No automatic character save. Idle main menu/setup needs no character-progress confirmation.
- Reopen setup from main menu without clearing remembered ARENA2. Active gameplay first uses approved confirmed return-to-menu. CORE-004/006 validation/persistence/restart rules remain; opening setup alone does not switch source.
- Normal shutdown safely finishes/resolves conflicting saves, tears down session services, persists accepted unsaved application preferences through CORE-003, then releases application resources/logging/storage ownership. Failed writes must not be reported saved or silently discarded. Failure choices remain to be specified.

Second interview, confirmed by the user on 2026-11-05:

- Failed preference persistence offers Retry or explicit Quit Without Saving Preferences with a warning. Never silently discard accepted changes. Unapplied staged edits remain unapplied; shutdown does not auto-Apply them.
- While conflicting work runs, show responsive finishing-current-operation UI. Preflight may cancel under its existing rules; destructive restoration/committed save publication reaches a safe completion/failure point before normal exit. Retain quit intent separately without general CORE-007 queuing or forced write interruption.
- Forced process kill/power loss/uninterceptable OS termination is outside orderly-shutdown guarantees; promise no final save/flush. No arbitrary automatic kill timeout on normal shutdown. Detected failures expose explicit recovery/exit choices; SAVE owns durability.

Third interview, confirmed by the user on 2026-11-05:

- Cancel is available during confirmation/waiting before session teardown. Release only shutdown-owned suspension, preserving other gates. After teardown begins, explain that cancellation cannot restore the session. Cleanup failure offers Retry Cleanup or Quit under CORE-005.
- Repeated Quit/OS-close input represents the same pending intent; do not stack confirmations, repeat cleanup or interpret repeated clicks as force-termination consent.
- Explicit user-requested restart follows orderly shutdown, then relaunches where supported. Preserve portable markers/remembered paths; only safely persisted pending preferences activate next launch. Relaunch failure explains manual launch is needed rather than claiming success. Preference changes never restart automatically.

## Inherited requirements

CORE-007 owns session-change admission/confirmation/preflight and CORE-005 safe teardown. CORE-008 owns menu return; CORE-004 preserves content path and restart-only source activation. CORE-003/006 distinguish accepted unsaved preferences from unapplied edits and pending activation. CORE-001 storage locks release on exit/crash; CORE-002 file logging is optional with bounded retention. CORE-016 UI remains responsive while shutdown inhibits gameplay. CORE-009 stays deferred and CORE-014 outside scope.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/UserInterfaceWindows/DaggerfallStartWindow.cs` ExitGame and setup wizard exit handler call Application.Quit. `Assets/Scripts/Game/DaggerfallUI.cs`, dfuiExitGame saves settings then quits (or stops editor play). Setup wizard RestartButton_OnMouseClick clears MyDaggerfallPath in memory and reloads startup scene. `Assets/Scripts/Game/ExitGame.cs` quits on Escape; active scene attachment remains unverified.

Baseline: local DFU 1.1.1 Release; exact commit unavailable per repository overview. Static inspection only; source remains unchanged. Original distributed exit calls and path-clearing restart behavior are not approved by implication.

## Detailed shutdown and setup behavior

Route normal in-game Quit and interceptable operating-system close through one logical shutdown coordinator. It owns a single pending quit/restart intent rather than duplicating session operations. Before discarding a living active session, confirm unsaved-progress loss and do not autosave the character. Decline/Cancel preserves that session and releases only shutdown-owned gates. Idle main menu/setup does not require character-loss confirmation; unsaved application-preference failure still has its own explicit choices.

Suspend gameplay appropriately while confirmation/waiting UI remains responsive. Quitting does not release another owner's pause or bypass lifecycle recovery. Deduplicate repeated requests; repeated clicks or OS-close notifications do not imply force exit or additional confirmation. Stop admitting work that would conflict with committed shutdown while preserving necessary UI/recovery and pending owner completion.

When a conflicting save/session operation exists, retain shutdown intent outside CORE-007 and show finishing-current-operation status. Cancel its preflight only through supported CORE-007 rules; destructive restore or committed save publication must reach a safe completion/failure point. Do not forcibly interrupt a write or queue arbitrary replacement operations. Reassess lifecycle/current-session consent before destructive shutdown if waiting changed the active session; an earlier confirmation must not silently authorize discarding a different character.

Allow shutdown Cancel during confirmation/waiting before teardown begins. Cancel stops pending exit intent, not an already committed unrelated save/load operation, and does not promise undoing work that operation performed. Once session teardown begins, no cancellation can restore that session. Apply CORE-005 dependency-safe teardown and reject old-scope work. Detected cleanup failure offers Retry Cleanup or explicit Quit; choosing Quit does not pretend cleanup completed and does not authorize starting another session with unsafe state.

After safe operation resolution and session teardown, persist accepted unsaved application preferences through CORE-003. This is not Apply for staged UI edits: do not silently activate/persist an unaccepted candidate. Failed preference publication offers Retry or explicit warned Quit Without Saving Preferences. Preserve prior valid files/backups under CORE-003; explicit discard means changes may be lost, not that they were saved. No return to a playable torn-down session is promised from this failure screen.

Release remaining application resources in dependency-safe order, keeping error UI/settings/storage usable until their required work is resolved. Close logging and release storage ownership when no dependent file operation still needs them. Log failure remains optional under CORE-002 and cannot turn normal shutdown into a false claim that saves/preferences succeeded. CORE-001 process-owned exclusion releases on exit/crash even if final cleanup cannot run.

Return to Setup is distinct from quit/restart. From main menu, open setup without clearing the remembered ARENA2 path or changing the active content source. From gameplay, use CORE-008's confirmed safe menu-return first; then open setup. Canceling that return leaves gameplay intact. Setup retains CORE-004 error recovery and CORE-006 Apply/Cancel/activation policies. Merely opening setup does not discard accepted preferences or alter portable selection.

Application restart is explicit player intent. Use the same confirmation, conflict resolution, teardown and preference rules, then relaunch through supported platform facilities. CORE-004 requires safely persisted content-path changes before restart is offered; no unsaved pending setting can be advertised as active after relaunch. Preserve portable marker/path configuration, and reevaluate storage/content/settings normally next launch. Choosing Quit Without Saving Preferences does not make unsaved requested changes active; explain that distinction for restart intent.

If automatic relaunch is unavailable/fails, explain that the application must be launched manually using an available surviving UI/platform mechanism. Do not report a successful restart merely because the old process exited. The exact relaunch handoff is platform scope, and this feature does not require automatic process spawning on unsupported platforms.

Uninterceptable process kill, power loss and forced OS termination are outside orderly-shutdown guarantees. Do not promise final save/flush or block platform termination indefinitely through invented assurances. Normal shutdown has no arbitrary auto-kill timeout: detected failures expose the explicit recovery/exit choices above. SAVE's durable publication policies must protect committed data independently of a graceful final callback.

## Relevant formulas and parameters

No gameplay formulas or automatic shutdown deadline apply. At most one pending shutdown/restart intent exists. Living-session discard requires consent; pre-teardown Cancel is allowed. Retry is explicit, not an unlimited hidden loop. No autosave, portable-mode change or arbitrary force-exit timer is introduced.

## Required data

Quit/restart intent identity, originating/current session identity, consent/cancellation eligibility, shutdown phase, conflicting operation/safe-point status, cleanup result, accepted-unsaved versus staged preference state, persistence outcome, explicit discard choice and relaunch capability/result. Runtime ownership/operation data is not character-save state. Application configuration stays under CORE-001/003.

## Inputs, outputs and events

Inputs: Quit, OS-close notification where interceptable, Restart, Return to Setup, confirm/cancel, owner completion/failure, Retry/Retry Cleanup/Quit Without Saving Preferences and relaunch outcomes. Outputs: preserved session on declined early exit, pending/waiting status, safe teardown/persistence, explicit error choices, reopened setup, process termination or truthful restart/manual-launch result. Public APIs/signals remain deferred. Exit request admission is not proof of saved data or successful relaunch.

## Cross-system interactions

CORE-007 handles current session operations, CORE-005 teardown and CORE-008 return-to-menu. SAVE resolves in-progress publication safely and owns crash durability; no new character save is requested automatically. CORE-003 persists accepted preferences and CORE-006 separates staged/effective/pending values. CORE-004 setup/source restart contracts remain. CORE-001 owns storage locks, CORE-002 log lifetime/failure, CORE-015 truthful lifecycle and CORE-016 responsive UI/owned suspension. Platform integration intercepts supported close/relaunch requests without promising control over forced kills. CORE-009 is deferred and CORE-014 outside scope.

## Edge cases and failure conditions

- Repeated close input cannot bypass confirmation or cause duplicate teardown/persistence/relaunch.
- A load completing while quit waits may replace the character. Revalidate consent/current context rather than applying stale consent to a different living session.
- Canceling pending quit does not cancel committed writes/restores outside their own contracts. It cannot release unrelated suspension.
- Incomplete/unsafe teardown blocks new gameplay. Explicit Quit after failure is an exit choice, not a cleanup-success result or rollback guarantee.
- Preference-write failure must retain existing valid files and offer explicit retry/discard. Staged unaccepted edits are never auto-Applied by shutdown.
- Accepted but unsaved restart-dependent changes are not guaranteed next launch. A changed ARENA2 source retains its special save-before-restart offer requirement.
- Error UI/log/storage cannot be destroyed before remaining required persistence/error choices need them. Logging failure does not conceal actual save failure.
- Return to Setup preserves remembered path and does not activate a new source live. Active-session return first honors CORE-008 consent/cleanup.
- Relaunch failure may require manual launch; no false restart success. Platform forced termination may prevent final callbacks; durable saves cannot rely on them.

No death penalties, save deletion, automatic saves or new gameplay persistence format are introduced.

## Configuration and balancing options

Quit/Restart/Return to Setup remain distinct explicit actions. No setting bypasses live-session confirmation or forces application restart merely because an option changed. Exact UI wording/navigation and supported relaunch capability are UI/platform contracts. This feature adds no balance parameters or forced background-exit policy.

## Save/load considerations

Normal quit does not autosave character progress; explicit confirmation accepts losing unsaved gameplay. Finish/resolve existing saves safely before exit. Persist accepted application preferences with actual success/failure reporting, independently of character saves. No source save is overwritten by reopening setup. Shutdown intent/confirmation/raw handles are transient, not character-save data. Crash/OS kill durability remains SAVE responsibility; no final flush guarantee is promised.

## Technical constraints

Target engine: Godot 4.7.2. Intercept normal close where platform supports it and avoid distributed direct quit calls bypassing the coordinator. Keep lifecycle/scope ownership and file dependencies explicit through asynchronous completion. Use platform-appropriate exit/relaunch, preserving configuration and avoiding duplicate processes competing for the same storage root. Concrete Godot close notification/API, safe-point protocol and relaunch mechanism remain implementation dependencies; source remains unchanged.

## Acceptance criteria

1. In-game Quit and interceptable OS close share coordination. Living-session progress loss is confirmed, Cancel preserves it, and no automatic character save occurs. Idle menu/setup has no unnecessary character-loss prompt.
2. Repeated close/quit requests produce one pending intent/confirmation/cleanup, never force-exit consent.
3. Conflicting save/transition work uses responsive waiting and reaches safe completion/failure; preflight cancellation follows existing rules. No destructive write/restore interruption or general queued session operations occurs.
4. Cancel before teardown releases only shutdown intent/suspension. After teardown starts no session restoration is promised; failed cleanup offers Retry Cleanup/Quit and cannot enable unsafe new gameplay.
5. Accepted unsaved application preferences use CORE-003 publication. Failure offers Retry or explicit warned Quit Without Saving Preferences; staged edits are not auto-Applied and failed writes are not reported saved.
6. Application resources/logging/storage release only after dependent normal-shutdown work is resolved; process exit releases exclusive ownership under CORE-001.
7. Return to Setup from menu preserves remembered ARENA2/source/preferences. Gameplay first follows confirmed menu return; setup changes still validate/save and obey restart rules.
8. Explicit Restart uses normal safeguards and platform-supported relaunch, preserves marker/paths and activates only persisted pending settings on new launch. Preference changes never restart automatically.
9. Failed/unavailable relaunch provides truthful manual-launch guidance rather than success; no guarantee of forced-termination final save/flush or arbitrary normal auto-kill timeout is made.
10. Current-session context/consent is rechecked after waiting, recovery UI remains responsive and exit/cancel never releases other owners' gates incorrectly.

These are future verification criteria. No implementation/runtime tests or platform shutdown/relaunch tests have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001–008, CORE-010–013 and CORE-015–020 v1, CORE-009 deferral, CORE-014 exclusion, decision log, CORE catalog and CORE architecture review. All nine interview decisions are represented. No conflict identified: quit consent preserves no-autosave behavior, busy quit intent is separate from CORE-007 queueing, safe teardown remains required and explicit exit after failure does not claim playable recovery. Content restart stays save-before-offer, and staged edits stay unapplied. Platform/SAVE durability mechanisms remain owner scope.

## Outstanding questions and approval

No further blocking exit-policy choice is currently identified. Before implementation is considered complete, owners must define close/relaunch support, safe-operation completion protocol, dependency disposal order, persistence failure UI, staged-edit exit wording and failure guidance mechanism if old process has exited. These dependencies do not waive safeguards or promise forced-close interception.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-021. This document is finalized v1. Approval reference: CORE-021-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented platform, safe-point, disposal and UI implementation dependencies remain open. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
