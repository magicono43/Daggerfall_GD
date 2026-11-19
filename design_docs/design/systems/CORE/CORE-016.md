# CORE-016 — Pause, input and HUD coordination

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Coordinate independently owned gameplay suspension, responsive UI and HUD visibility without premature resume or lost player preferences.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Requesters acquire/release their own suspension reasons. Resume only after all applicable reasons are gone and lifecycle readiness permits it. Duplicate release is harmless; ending an owner scope releases its reasons safely.
- Ordinary pause stops world simulation/gameplay-time advancement, including movement, AI, combat and effect timers. UI/active-window input, loading work and real-time presentation timers continue. Explicit rest/travel calendar advancement is a separate TIME operation.
- HUD visibility is separate from simulation suspension. Pause alone leaves HUD visible; screens/cinematics can explicitly hide it. Closing a screen releases only its visibility request while respecting other requests and player preference.

Second interview, confirmed by the user on 2026-11-05:

- Route input to active UI context while gameplay is suspended. Consume window-open/close actions so they cannot also attack/interact/activate another button. Require fresh presses for discrete gameplay actions after closing; movement may resume from currently held direction.
- Focus loss acquires its own suspension reason. Focus return releases only that reason, preserving inventory/load/other suspension. Background rendering/loading may continue but ordinary world simulation remains suspended while unfocused.
- Separate intended gameplay rate from effective suspension. Pause makes effective advancement zero; final resume uses currently intended rate, not a stale rate saved at first pause. This permits later rate-control features without approving them now.

Third interview, confirmed by the user on 2026-11-05:

- Pause gameplay-linked sounds with the world; music/UI sounds and explicitly independent cinematics/videos may continue. Resume paused sounds where supported without replaying completed effects. AV defines categories; focus-loss muting remains a separate audio-preference decision.
- Active input context owns cursor and text entry. Menus may show/release cursor and enable text input; gameplay recaptures only when gameplay input is eligible and the application focused. Closing text input cleans composition state without interrupting another active text field.
- Change pause/HUD/input ownership coherently. Replacing paused windows must not briefly resume simulation, flash HUD or leak gameplay input. Teardown removes only ending-scope requests and cannot override lifecycle/recovery gating.

## Inherited requirements

CORE-005 scope teardown/readiness and CORE-015 committed lifecycle remain authoritative; readiness alone never resumes gameplay. CORE-007 entry/preflight owns its suspension and only releases its own reason. CORE-008 skip input cannot activate menu actions. CORE-006 display confirmation uses 15 real-time seconds despite pause/focus loss. CORE-011/012 initialization and opening presentation remain gated; CORE-013 restored modals may retain suspension. CORE-009 remains deferred and CORE-014 outside scope.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/GameManager.cs`, PauseGame stores/zeros time scale, sets one pause/input flag and optionally hides HUD. Resume restores stored scale/input and HUD hidden by that call; it also performs IME recovery. Repeated pauses do not acquire separate ownership. `Assets/Scripts/Game/UserInterface/UserInterfaceManager.cs`, AddWindow uses PauseWhileOpen; RemoveWindow can resume near HUD/empty stack and sets activation click delay. RunInBackground is applied separately by StartGameBehaviour.

Baseline: local DFU 1.1.1 Release; exact commit unavailable per repository overview. Static inspection only; source remains unchanged. No Unity time-scale/IME implementation is approved by implication.

## Detailed coordination rules

Use owner-scoped suspension requests rather than one writable global pause flag. Each applicable request retains its identity/lifetime until its owner releases it or safely ends. Nested acquisitions must not accidentally collapse distinct active reasons; exact token/key representation is deferred. Duplicate release is harmless. Ending a scope releases only that scope's requests, and CORE-005 lifecycle/cleanup gates still prevent unsafe resume.

Derive simulation eligibility from lifecycle readiness/safety plus applicable suspension reasons. Ordinary suspension inhibits authoritative movement/physics progression, AI, combat, gameplay effects and automatic calendar advancement. Input to menus/error UI remains responsive. Loading/construction tasks and necessary non-gameplay queries can continue without simulating an exposed partial scene. TIME may perform explicit rest/travel/calendar operations under its own contract; this is not ordinary paused-frame advancement.

UI, display confirmation and independent presentation use appropriate real-time clocks. In particular CORE-006's 15-second display timeout runs despite pause/focus loss. Pause must not accumulate elapsed real time for later gameplay catch-up: resuming does not instantly advance world/calendar/effect timers for the paused duration. Detailed active simulation cadence remains CORE-017/TIME scope.

Keep intended gameplay rate separately from suspension. Suspension makes effective advancement zero, without overwriting intent. When all relevant reasons clear and lifecycle permits, apply current intended rate, not a stale captured scale. This does not approve slow-motion/debug controls or let a nonzero intended rate bypass readiness.

Focus loss owns a suspension reason independently of UI/operations. Focus return releases only that reason; open dialogs, load work or recovery can keep gameplay suspended. Background rendering/loading may continue under platform/resource policy, but ordinary gameplay does not advance unfocused. Do not synthesize gameplay actions from keys pressed while another context had focus.

Input context determines eligible actions, cursor capture and text composition independently of the simulation clock. While suspended, eligible UI/presentation input remains available and authoritative gameplay actions are blocked. Consume window open/close, video skip and other handoff input so it cannot activate another context. Require fresh discrete gameplay presses (attack/interact/etc.) after return; currently held movement direction may resume when gameplay becomes eligible. A held trigger must not become an unintended fresh attack solely because pause cleared.

Only the eligible focused gameplay context may recapture the cursor. A menu/text context can request visible/unconfined cursor and composition. Releasing one text owner must not reset composition belonging to another active field. Exact context precedence is an explicit UI/input contract, not incidental callback order. Scope/focus changes reject stale input requests.

HUD visibility is a separate derived presentation policy: respect player preference, valid current HUD scope and outstanding explicit hide requests. Ordinary pause alone does not hide it. Removing one hide reason cannot override another or enable a HUD the player disabled. Recreated HUD consumers receive effective preferences and active visibility requests, without inheriting stale old-session references.

Pause gameplay-linked sounds together with their simulation context. Music, UI audio and expressly independent cinematics/videos may continue; this does not grant every sound an exemption. AV owns category definitions and feasible playback-resume behavior. Do not restart completed sound effects as if new gameplay happened on resume. Old-session audio teardown remains separate from independent death-video/menu audio under CORE-008. No focus-loss mute toggle/default is approved here.

Commit window/context handoffs coherently before the next simulation/input/presentation evaluation. Replacing nested paused windows must not create a visible/interactable resumed frame or transient HUD flash. These ownership changes do not replace CORE-015 lifecycle with UI states. Publish any relevant derived gate/view changes consistently; no new broad event API is selected here.

## Relevant formulas and parameters

Conceptually, simulation may advance only when lifecycle is ready/safe and no applicable suspension reason remains. Effective gameplay rate is zero while inhibited, otherwise the current intended rate. HUD may display only when its scope/player preference permit and no explicit hide request applies. Gameplay input additionally requires focus and an eligible input context. These are separate predicates, not one interchangeable paused flag.

No new numerical balance parameters apply. No paused-time catch-up, automatic save or global audio mute is introduced. Existing display confirmation remains 15 real-time seconds.

## Required data

Owner/scope identities, active suspension reasons, lifecycle/safety eligibility, intended rate, focus state, active input context/cursor/text ownership, input-consumption/fresh-press state, HUD preference/scope/hide requests and AV category pause state. Exact schema, context priority and request representation remain implementation details. Requests tied to a dead session cannot control a replacement.

## Inputs, outputs and events

Inputs: acquire/release suspension or HUD hide, UI/context push/pop/replace, focus change, lifecycle/readiness/cleanup changes, intended-rate updates and scope teardown. Outputs: consistent simulation eligibility/effective rate, eligible UI/gameplay input, cursor/composition state, HUD visibility and AV pause requests. API/signal names are deferred. Querying ready does not release requests, and requests cannot be released by unrelated observers.

## Cross-system interactions

CORE-015 supplies committed lifecycle separate from overlays. CORE-005 disposes owner scopes and preserves safety gates; CORE-007 operations release only their own suspension. CORE-006 display confirmation/preferences retain real-time and effective-value rules. CORE-008 independent death presentation/audio and skip-input consumption remain intact. CORE-011/012 initialization and opening UI cannot enable gameplay prematurely; CORE-013 restored modals may keep it suspended. UI/input own contexts/HUD/text, MOVE/NPC/COMBAT/MAGIC honor simulation eligibility, TIME distinguishes automatic and explicit advancement, AV owns audio/presentation categories. CORE-017 will define active cadence; CORE-009 stays deferred and CORE-014 outside scope.

## Edge cases and failure conditions

- Overlapping inventory, load, focus loss and recovery reasons cannot release one another. Returning focus does not close a menu or finish load.
- Duplicate release and safe scope teardown cannot cause underflow/premature resume. A leaked/unresolved active reason must be diagnosable rather than bypassed by forcing a global resume.
- Window replacement must not expose even one simulation/input frame between reasons. HUD preference/hide requests persist correctly across recreation.
- UI/presentation can run while gameplay is frozen; this cannot advance effect timers or authoritative physics. Explicit TIME operations have separate owner rules.
- Paused real time cannot become a catch-up spike. Background/OS suspension may delay execution, but gameplay still must not advance for that paused interval on return.
- Cursor recapture while unfocused or while text input owns context is prohibited. Ending one composition context does not disable another.
- Open/close input cannot attack/interact, and video skip cannot select the menu. Held movement resumption is intentional; discrete actions require fresh input.
- Independent music/video continuation does not authorize world SFX loops continuing as if simulation ran. AV validates category behavior without replaying completed effects.
- Ready lifecycle does not imply gameplay input is eligible; restored modal state may legitimately block. Logging failure alone does not justify pause/recovery beyond its approved warning policy.

There are no new balance values. The main risks are world advancement under menus, accidental attacks, premature resume, visibility flicker and cross-session request leakage.

## Configuration and balancing options

Player HUD preference remains respected. Focus-loss suspension is required; a background-render/loading option cannot enable background world simulation under this policy. Intended-rate controls, audio-category tuning, focus mute and exact window pause policies require their owners' specifications. No player setting bypasses required entry/recovery gates or consumes another owner's reason.

## Save/load considerations

Runtime pause/hide tokens, cursor ownership and raw UI objects are not durable character state. Restored supported activities/UI reconstruct their owned reasons from authoritative state under SAVE/UI contracts before releasing load suspension. Preserve application preferences separately. Saving is not automatically permitted by pause and pausing does not trigger autosave. Loads must not restore stale ownership IDs that affect a later session.

## Technical constraints

Target engine: Godot 4.7.2. Engine scene pause/time scale alone is insufficient evidence that all agreed gameplay clocks/input are gated; each owner must honor the contract. Use real-time presentation clocks and explicit scope-safe ownership. Coordinate input/HUD/AV changes without exposing intermediate eligibility. Exact Godot process modes, request token mechanics, cursor/IME APIs and audio backend remain implementation details to verify.

## Acceptance criteria

1. Multiple requesters independently hold/release suspension. Releasing one or twice cannot resume while others or lifecycle safety still block; teardown removes only ending-owner requests.
2. Ordinary pause stops movement/AI/combat/effects/automatic calendar advancement while UI, active-window input, loading and independent real-time presentation remain responsive.
3. Pause creates no gameplay-time catch-up on resume. Explicit rest/travel TIME operations remain separately governed; display timeout runs in real time as already approved.
4. Effective rate is zero while inhibited, then current intended rate on eligible resume, without restoring stale first-pause values.
5. Pause alone does not hide HUD. Explicit hide requests combine with player preference/scope and survive nested ownership/recreation correctly.
6. Active UI receives appropriate input; open/close/skip actions cannot leak to another context. Fresh discrete presses are required on gameplay return; held movement may resume.
7. Focus loss suspends world simulation independently. Focus return releases only its reason; background loading/rendering does not advance ordinary gameplay.
8. Cursor capture requires focused eligible gameplay. Text composition cleanup respects another active text owner and cannot leave gameplay blocked by stale composition state.
9. Gameplay-linked audio pauses; independent music/UI/video may continue under AV classification. Resume does not replay completed effects, and gameplay cleanup cannot stop independent death-video audio.
10. Nested window replacement changes simulation/HUD/input ownership coherently without a resumed frame, HUD flash or input leakage. Recovery gates persist after ending scopes release requests.
11. Supported load-restored UI reconstructs required reasons before release; readiness alone cannot resume. Old-session tokens/callbacks do not affect replacement sessions.

These are future verification criteria. No implementation or runtime tests have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001–008, CORE-010–013 and CORE-015 v1, CORE-009 deferral, CORE-014 exclusion, decision log, CORE catalog and CORE architecture review. All nine interview decisions are represented. No conflict identified: display timeout stays real-time, entry/load/cleanup gates remain owner-specific, death presentation stays independent, and lifecycle is separate from overlays. Detailed cadence, explicit time advancement and AV category contracts remain owner scope.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Owners must define input-context precedence, per-window policies, TIME advancement contracts, AV pause categories, scope-release mechanics and engine processing modes. Focus-loss muting/intended-rate features are not approved by implication. These dependencies do not waive ownership, clock or handoff criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-016. This document is finalized v1. Approval reference: CORE-016-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented owner contracts and implementation deferrals remain open; detailed CORE-017 cadence, TIME advancement and AV category contracts are not approved by implication. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
