# CORE-008 — Title return and death return

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

End the current session and return to the main menu, distinguishing voluntary exit from confirmed death without leaking old quest/world/presentation state into a later session.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Voluntary return confirms that unsaved progress will be lost, then ends the session and opens the main menu. No automatic save. Cancel leaves the current session unchanged.
- Return after confirmed death does not require living-session discard confirmation. Existing saves remain untouched; do not delete saves or automatically load one. Death presentation and duration belong to CHAR/AV.
- Both routes use shared safe session teardown with distinct Voluntary Return/Death Return reasons for UI/observers. Clear session-owned quests/world objects and transient camera/fade/weapon/audio/input state. Announce session end/menu readiness rather than mislabeling return as new game.

Second interview, confirmed by the user on 2026-11-05:

- Preserve the death cutscene/video before the main menu as the death notification. The proposed separate main-menu death notice is not accepted. Playback/skip/failure rules remain open.
- If teardown succeeds but menu loading fails, keep the session ended and use CORE-004's independent Retry/Return to Setup/Quit UI. Retry menu loading only; do not repeat completed teardown or resurrect the session.
- Reject busy death-return requests under CORE-007 without queuing/preemption. The death handler retains originating session identity and may submit a fresh request after the operation finishes only if that same dead session still needs return. Discard intent if replaced/ended.

Third interview, confirmed by the user on 2026-11-05:

- Use the original ARENA2 death video once per completed death return, not for voluntary return.
- Permit deliberate early skipping. If the video is missing or cannot play, proceed directly to the main menu without any text fallback. Video failure must not trap the player or restore the dead session.
- Track presentation completion/skip so menu-load retries do not replay the video. Menu readiness and successful return require presentation to have completed/skipped (or the approved failure bypass) and a usable menu.

Fourth interview, confirmed by the user on 2026-11-05:

- Consume video-skip input so it cannot activate a menu button; require fresh menu input.
- Death video/menu presentation lives independently of the ended gameplay session. Clear old gameplay audio/fades/input capture without stopping the video's own presentation/audio. Playback/skip never resumes gameplay.
- Repeated requests cannot repeat completed teardown or death playback. Death return belongs to the session whose death was confirmed; discard stale intent or intent with no remaining session without affecting the menu/another character. Voluntary return while already at the menu leaves it in place.

## Inherited approved requirements

CORE-007 coordinates session changes, stable request identities, preflight, consent and busy rejection. CORE-005 controls safe teardown, application/session/location lifetime and stale callback rejection. Unsafe cleanup blocks new sessions with Retry Cleanup/Quit. CORE-004 provides independent menu-transition failure UI. CORE-001–003 application storage/settings/logging remain available per their rules, and CORE-006 preferences remain intact.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/Utility/StartGameBehaviour.cs`, StartTitleMenu and StartTitleMenuFromDeath: raise OnNewGame, pop UI to HUD, clear quests, disable world parents, reset weapon presentation and signal OnStartMenu. Death return resets the death camera, assigns TitleMenu to StartMethod and posts a death-specific initialization message unless overridden. The dispatcher subsequently clears StartMethod on normal return.

`Assets/Scripts/Game/PlayerDeath.cs`, Update: after its presentation delay, requests TitleMenuFromDeath and resets camera. Death timing/presentation are separate from menu-return policy.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per repository overview. Static inspection only; source remains unchanged. Original event names/cleanup mechanics are not approved by implication.

Additional source verification: `Assets/Scripts/Game/DaggerfallUI.cs`, ProcessMessages maps dfuiInitGameFromDeath to InitGame(deathVideo), with deathVideo = ANIM0012.VID. InitGame pushes the start menu, then the video window above it when videos are enabled. Thus the normal visible death return includes a video before the menu is exposed.

## Detailed return behavior

Submit voluntary/death return through CORE-007 with stable originating session identity and an explicit reason. Voluntary return from a living active session requires confirmation of unsaved-progress loss, with no automatic save. Declining leaves the session unchanged. Confirmed death is an ended-session exception to living-session discard confirmation, not a new-game or automatic-load request. CHAR owns the authoritative death decision and CHAR/AV own the preceding death sequence/duration.

Once accepted, use shared CORE-005 teardown: stop gameplay simulation/input, cancel old work, disconnect subscriptions and release session/location resources, including quests/world objects and transient gameplay camera/fade/weapon/audio/input state. Do not delete or rewrite saves. Keep application services/settings and their approved failure handling available. Reject late old-session callbacks and preserve distinction between Voluntary Return and Death Return in notifications.

After confirmed death, play original ARENA2 ANIM0012.VID before exposing a usable main menu. Play it once for this return flow; voluntary return does not play it. Early deliberate skip completes presentation. Missing/failed playback bypasses presentation directly to the normal menu with no text fallback or extra death notice. Failure may be recorded through CORE-002 diagnostics; it must not produce a replacement player-facing death message. This feature introduces no new video-disable preference; any separately approved global video policy must define its interaction explicitly.

Consume the skipping input and require fresh menu input. Video/menu scopes are independent of the ended gameplay session, so old-world cleanup cannot stop video-owned audio, leave an old death fade over the menu or reactivate gameplay input. The menu may be prepared behind the video; it is not ready for player actions until presentation finishes, is skipped or is bypassed on failure.

Publish session-ended after safe teardown, retaining its reason, and menu-ready only when the menu is usable after presentation. These are distinct milestones: no new-game notification is emitted. Return succeeds only when its required teardown/presentation/menu work finishes, following CORE-007's single terminal result. A video failure with the approved bypass is not by itself return-operation failure if the menu becomes usable.

If cleanup fails, CORE-005 Retry Cleanup/Quit takes precedence and new sessions remain blocked. If cleanup completed but menu opening fails, retain the ended state and use CORE-004's independent Retry/Return to Setup/Quit screen. Retry menu loading only, without repeating successful cleanup or replaying completed/skipped/bypassed presentation. Carry flow completion state across that recovery so CORE-007's fresh retry request identity does not reset completed presentation milestones. Do not resurrect the old session.

If a distinct death return is busy-rejected, the death handler retains its intent and originating identity outside the coordinator. After the active operation ends, it may submit a fresh request only if that same dead session still needs return. This is conditional resubmission, not an automatic coordinator queue or preemption policy. Discard stale intent if that session was replaced or ended. Same-identity redelivery follows CORE-007 and never reruns work. An already-menu voluntary return is an unchanged/no-op outcome rather than another teardown.

## Relevant formulas and parameters

No gameplay formulas or balance parameters apply. Return reasons are Voluntary Return and Death Return. Death-video source is original ARENA2 ANIM0012.VID. Completed presentation occurs at most once per death-return flow, even across menu retry. This feature chooses no death-animation delay, playback-speed multiplier or generic video timeout.

## Required data

Originating session identity, return reason, confirmed-death status from CHAR or voluntary consent, coordinator request identity/result, cleanup status, death-presentation completion/skip/failure-bypass state, menu readiness and consumed-skip-input state. These are transient runtime/flow data, not character-save records. Record enough flow provenance to prevent a fresh menu retry from replaying old presentation.

## Inputs, outputs and events

Inputs: voluntary return, confirmation/cancel, authoritative death-sequence completion, coordinator admission/busy outcomes, cleanup results, video complete/skip/failure and menu transition/recovery choices. Outputs: intact session on declined confirmation, ended session with explicit reason, video playback/bypass, usable menu, single terminal return result or independent recovery UI. Event/API names are not selected here. Observers distinguish session-ended, presentation-finished and menu-ready; none implies a new character was created.

## Cross-system interactions

CHAR confirms death and determines when its preceding sequence has completed; AV plays/skips the original video and keeps presentation audio distinct from old gameplay audio. DATA resolves the original video; missing/unplayable video uses silent menu bypass rather than a new mandatory-content block for this flow. UI owns confirmation, skip handoff, menus and independent recovery screens. QUEST/WORLD/LOC/COMBAT and other session owners release their own state under CORE-005. CORE-007 coordinates admission, outcomes and retry identities; CORE-004 retains menu-loading recovery. CORE-001–003 application settings/storage/logging and CORE-006 effective preferences are preserved.

## Edge cases and failure conditions

- Voluntary return must not lose progress before consent. Cancel/decline does not autosave, clear quests or leave old world services disabled.
- Death confirmation is authoritative CHAR state, not a late animation callback that can terminate a newly loaded character.
- A missing/corrupt/unplayable death video cannot trap the player, restore the dead session or display substitute death text. AV must surface failure/completion rather than leaving the return indefinitely awaiting a broken player.
- Skip input must not click a menu action, including mouse/controller interactions. Do not require the full video to finish before allowing deliberate skip.
- Gameplay fade/audio/input cleanup must respect independent video/menu ownership. Returning to menu cannot leave death camera pose, world audio or old gameplay callbacks active.
- Repeated presentation callbacks cannot publish duplicate readiness or return outcomes. Retries after presentation completion/skip/bypass do not play again.
- Failed teardown blocks retry/menu arrival where safety cannot be established. Failed menu loading after teardown does not justify rerunning destructive session cleanup.
- Stale busy-rejected death intent cannot apply to a new session. Voluntary return when already at the menu does not end an unrelated/new session.

There are no numerical balance effects or permadeath rules. Save deletion, death penalties, respawn and automatic loading are not approved by this feature.

## Configuration and balancing options

Shared teardown, explicit return reason, live-session consent, early skip, silent video-failure bypass and no replay on menu retry are fixed behavior. No additional main-menu death notice or fallback text is included. Death-sequence tuning and any broader video preference belong to other feature specifications. This feature does not require application restart when returning to menu.

## Save/load considerations

Both return reasons leave existing saves untouched. Neither creates a save, deletes one, automatically loads one or changes saved character state. Unsaved live-session state is discarded only after the approved voluntary consent or confirmed death flow. Return-operation/presentation milestones are transient and are not written into character saves. A later manual new/load operation begins through CORE-007 with fresh scope ownership; it must not inherit the ended session's quests or presentation state.

## Technical constraints

Target project engine: Godot 4.7.2. Do not depend on Unity-specific HUD/message-stack implementation or reuse a misleading OnNewGame event for teardown. Use scope-safe request/callback context and separate session teardown from video/menu scopes. Error UI works independently of ARENA2 assets as approved in CORE-004; normal original video still depends on DATA/AV decoding support. Exact APIs, video backend, input-consumption mechanism and transient flow-state representation remain implementation details.

## Acceptance criteria

1. Voluntary return from a living session shows unsaved-loss confirmation; declining preserves the session, while accepting ends it and reaches the ordinary menu without autosave.
2. Confirmed death return skips living-session discard confirmation. Saves are untouched and no save is automatically loaded.
3. Both routes safely release session-owned quests/world/transient presentation and input state, retain application services/preferences and report distinct return reasons without new-game events.
4. Death return plays ANIM0012.VID before exposing menu actions; voluntary return does not. Deliberate early skip works.
5. Missing/failed video goes to the ordinary menu without fallback text or an extra death notice; no dead-session resurrection or indefinite wait on detected playback failure occurs.
6. Skip input cannot activate a menu button; a fresh input is required. Old gameplay cleanup does not stop video-owned audio/presentation or resume gameplay.
7. Session-ended follows safe teardown; menu-ready and successful return follow usable menu arrival after presentation completion/skip/failure bypass. Duplicate callbacks do not duplicate terminal results.
8. Unsafe cleanup blocks new sessions with Retry Cleanup/Quit. Menu failure after completed cleanup offers independent Retry/Return to Setup/Quit and retains the ended state.
9. Menu retry does not repeat completed cleanup or replay completed/skipped/bypassed death presentation, including when retry uses a fresh coordinator request identity.
10. Busy death-return requests neither queue nor preempt. Conditional fresh resubmission occurs only for the same still-dead session after the active operation completes; replaced/ended-session intents are discarded.
11. Repeated/stale returns do not affect a replacement character or repeat completed work. Voluntary return while already at the menu leaves it unchanged.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001 through CORE-007 v1, the decision log, CORE catalog and CORE architecture review. All 12 interview decisions are represented, including the user's rejection of a separate death notice/text fallback. No conflict identified: confirmed death explicitly establishes CORE-007's ended-session consent exception, conditional death resubmission preserves no-queue admission, and unsafe cleanup retains CORE-005 precedence. Menu-only retry preserves completed milestones without claiming old-session rollback. Broader CHAR/AV death rules remain open.

## Outstanding questions and approval

No blocking return-policy choice is currently identified. CHAR/AV must define preceding death-sequence duration/completion and concrete video decoding/skip/failure detection. Deferred implementation details include APIs, flow identity/milestone storage, input handoff and menu layout. Any future global video-disable preference must preserve the agreed silent-menu behavior or explicitly revise this specification. These deferrals do not waive acceptance criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-008. This document is finalized v1. Approval reference: CORE-008-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented deferrals remain deferred. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
