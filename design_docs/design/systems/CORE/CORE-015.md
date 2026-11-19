# CORE-015 — Session state and notifications

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Expose consistent committed lifecycle state and truthful notifications without confusing open UI, pause reasons, new-character creation, restoration and menu return.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Track application/session lifecycle separately from windows and pause reasons. Inventory does not replace the underlying session state; closing it must not restore obsolete load/death state from one previous-state field.
- Commit complete state before notifying observers. Notifications carry previous/current lifecycle state, reason and relevant operation/session identity. State queries and notification values agree on the committed transition.
- Distinguish new-session readiness, restored-session readiness, confirmed death, session end and menu readiness, alongside general state changes. Emit each actual milestone once. Do not call load/cleanup/menu return new game.

Second interview, confirmed by the user on 2026-11-05:

- One lifecycle owner accepts validated transition requests from startup/session coordination/authoritative death handling. Other systems observe or request operations rather than directly assigning lifecycle fields.
- Reject invalid or stale phase/session transitions with diagnostics rather than forcing them. Same committed state is a no-op without duplicate milestones. Required transition failure reaches its owning operation's recovery path.
- Subscriptions belong to an owner scope and disconnect at scope end. New observers obtain the current committed snapshot without replaying historical start/death/reward events. Session observers must not leak into later characters.

Third interview, confirmed by the user on 2026-11-05:

- Publish committed general state change before associated milestones. Finish that notification batch before processing another lifecycle transition requested by an observer. CORE-007 busy rejection still governs operation requests; notification serialization does not introduce an operation queue.
- Isolate notification-handler failures: diagnose, continue other observers and do not undo committed state. Required initialization uses explicit checked operations before readiness, not observer success. Required-service loss still invokes CORE-005 recovery.
- Expose distinct application phase, session identity/status, operation phase and readiness fields. Represent setup/menu/start-load/established session/death/teardown/recovery without conflating windows with lifecycle. Exact enum names remain implementation details.

## Inherited requirements and scope

CORE-005 readiness follows completed required initialization and does not itself release suspension. CORE-007 owns operation phases/results and consistent identity. CORE-008 distinguishes return reasons/session end/menu readiness and gates death-video presentation. CORE-010 baseline-ready is an intermediate notification. CORE-011/012 gate new-character control through required initialization/immediate opening presentation. CORE-013 emits Session Restored only after actual restore readiness, possibly retaining restored modal suspension. CORE-009 is deferred and CORE-014 outside current scope. Detailed pause/input rules remain CORE-016 scope.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/StateManager.cs`: one StateTypes enum mixes None/Setup/Start/Game/Death/UI/Paused. ChangeState assigns LastState/CurrentState, emits OnStateChange, then updates GameInProgress only for Start/Game. New/load both emit OnStartNewGame before changing to Game. Window changes can restore LastState or None. Constructor subscribes to static start/load/death and UI events; no unsubscribe lifecycle is shown in this class.

Baseline: local DFU 1.1.1 Release; exact commit unavailable per repository overview. Static inspection only; source remains unchanged. No original enum or event name is adopted by implication.

## Detailed lifecycle and notification rules

Maintain one authoritative committed lifecycle snapshot. Application phase, session identity/status, active operation context/phase and readiness are separate dimensions. Their valid combinations must be defined by the lifecycle owner and checked together. UI overlay state, pause reasons and actual simulation/input eligibility are related policies, not interchangeable lifecycle enum values. Do not restore an obsolete lifecycle by popping a window and assigning one previous-state slot.

Responsible startup/session/death owners request transitions through the lifecycle authority with relevant context. Validate current phase, originating identity and prerequisites. Reject stale/invalid requests without mutating state or emitting success. Required transition rejection reaches its owning operation's failure/recovery path; optional/no-op observations may simply diagnose. Repeating an identical snapshot causes no state-change event. A real change in another field (for example session identity or readiness) is not a no-op just because its phase label matches.

Commit all snapshot fields and related derived lifecycle flags before publication. A transition notification carries the prior/new snapshots, reason and relevant session/operation identity. Snapshot queries during that notification must agree with the committed new values. Finish the general state-change notification, then associated meaningful milestones, before committing another observer-requested transition. Serialize transition requests at that notification boundary; do not reinterpret this as queuing session-changing operations rejected as busy by CORE-007. Revalidate deferred transition intent against current authority/context before applying it.

Distinguish new-session ready, Session Restored, authoritative confirmed death, session-ended and menu-ready milestones. Emit each once per actual occurrence, not once globally: a later legitimate new character or later successful restoration has its own occurrence identity. Intermediate baseline/location readiness remains distinct from full session readiness. Keep transition state publication separate from CORE-007 admission and terminal operation outcomes while carrying enough context to correlate them.

Milestones obey existing prerequisites: CORE-010 baseline readiness follows baseline initialization; CORE-011/012 new-session playable readiness follows required placement/grants/immediate opening presentation; CORE-013 restored readiness follows actual required reconstruction/UI readiness and may retain modal suspension. CORE-008 session-ended follows safe teardown, while menu-ready waits for usable menu arrival after death presentation completion/skip/failure bypass. Confirmed death comes from CHAR authority, not an unvalidated stale animation callback. Load, cleanup and menu return never emit new-game creation events.

Essential actions occur through explicit checked owner operations before the readiness they establish. Notification observers may update derived presentation/diagnostics, but required gameplay correctness cannot depend on unspecified handler order or successful execution of an observer. A throwing handler is diagnosed without preventing later handlers or rolling back committed state. If it also reveals a genuine required-service loss, request the applicable recovery transition after the current batch; CORE-005 safety gating still applies. Do not delay necessary simulation/input protection merely to preserve event ordering.

Subscriptions have declared owner lifetimes and disconnect at teardown. Late observers can obtain the current committed snapshot without historical milestone replay. State-read/subscription handoff must not miss a concurrent transition or fabricate duplicate history; concrete subscription/version mechanism is deferred. Ended-scope callbacks cannot modify the next session, and an observer removed with its scope must not receive subsequent session notifications accidentally.

## Relevant formulas and parameters

No gameplay formulas or balance values apply. One authority commits lifecycle changes. One committed change produces one general change notification and any applicable once-per-occurrence milestones, in that order. Snapshot consistency and identity/context define correctness, not exact enum names. No global chronological replay, persistent event ledger or generic notification queue limit is selected here.

## Required data

Committed application phase; session identity/status; operation identity/phase; readiness; prior/new snapshots; transition reason; occurrence identity for milestones; subscription ownership and notification-batch status. Derived lifecycle flags must agree with the same snapshot. Exact representation/version token and enum/ID widths are implementation details. Pause reasons and UI focus remain separately owned.

## Inputs, outputs and events

Inputs: validated owner transition requests, completed initialization/restoration/teardown, authoritative death, menu arrival, operation failures and scope subscription changes. Outputs: committed snapshot queries, general state change, distinct milestones, invalid/stale-request results and diagnostics. Public APIs/signal names are deferred. Each notification batch uses a stable snapshot; observer-requested transitions cannot replace it halfway through the batch.

## Cross-system interactions

CORE-004 startup/menu routing, CORE-005 scope readiness and CORE-007 operations supply authoritative lifecycle facts. CORE-008 return, CORE-010 baseline, CORE-011/012 new-character entry and CORE-013 restoration retain their existing milestone prerequisites. CHAR owns death authority. UI observes lifecycle and separately manages overlays/input. CORE-016 will define suspension/input/HUD, and CORE-017 active-gameplay processing; this feature does not approve their detailed behavior. CORE-002 diagnostic failure cannot prevent state consistency. CORE-009 remains deferred and CORE-014 outside scope.

## Edge cases and failure conditions

- Popping nested windows cannot resurrect loading, death or an old session; lifecycle remains under its owner while overlays change independently.
- Same phase with different session identity/readiness is a meaningful snapshot change. Exact no-op redelivery does not duplicate events.
- A readiness callback submitting another transition cannot make later subscribers see mismatched query/event state. Commit subsequent transitions only after current notification batch, with fresh validation.
- A subscriber throwing does not prevent later observers or roll back state. Required initialization failure must have been an explicit operation result before readiness, not hidden as an optional listener failure.
- Death/service-loss safety gating cannot wait for an observer batch to finish before protecting gameplay; state notifications remain serialized while authoritative safety owners inhibit unsafe work.
- Stale requests/callbacks from replaced scopes reject without affecting the current character. A required transition rejection is routed to operation recovery rather than disappearing as a mere log message.
- A restored modal may leave a ready session suspended. Ready, session-present and simulation-running are distinct meanings; no single GameInProgress boolean replaces them all.
- Current snapshot access is not historical event replay. Late subscribers must not receive old new-game/death events that could repeat rewards or cleanup.
- Cleanup can be failed/blocked after an operation has terminated. Snapshot fields must represent that recovery condition rather than implying a usable menu or new-session admission.

There are no direct balance effects. The main risks are inconsistent observer views, duplicate side effects, stale-scope transitions and unintended gameplay resumption.

## Configuration and balancing options

Lifecycle ownership, committed publication, separate overlays and distinct milestones are fixed contracts. Exact phase vocabulary and subscription mechanism are engineering choices; consumers must use documented snapshot meanings rather than infer activity from an enum name. No player-facing toggle disables state validation or replays history.

## Save/load considerations

Lifecycle service instances, transient operation phases, notification delivery and subscriptions are reconstructed runtime state, not character-save history to replay. Loading restores authoritative domain state under CORE-013, then emits restored readiness once. It must not replay new-game/grant events from saved lifecycle fields. Supported saved activities/UI reconstruct their own domain state and may retain suspension; CORE-015 observes resulting committed readiness without making every modal resumable by implication.

## Technical constraints

Project target: Godot 4.7.2. Use explicit transition authority and scope-safe listeners with complete snapshot commit before callbacks. No Unity enum/static-event architecture or broad event framework is required. Integrate synchronous/async transitions without recursive mutation during notification. Diagnostics must tolerate unavailable file logging and follow privacy rules. Exact snapshot storage, signal APIs, sequence tokens and failure-isolation mechanisms remain implementation details.

## Acceptance criteria

1. Lifecycle state remains distinct from UI overlays/pause reasons. Open/close inventory or nested dialogs cannot restore obsolete load/death/session context.
2. One authority validates phase/context/identity and commits complete snapshots. Direct observer mutation is not permitted; stale/invalid transitions reject without success events.
3. Notification previous/new values, reason and relevant identities agree with state queries throughout the batch, including derived lifecycle flags.
4. General state change precedes associated milestones. Observer-requested lifecycle transitions commit only after batch completion; session-operation admission still follows CORE-007 busy rejection.
5. Identical snapshot repeats are no-ops, while real identity/readiness changes publish even if phase labels match. Each actual milestone occurs once for its originating occurrence.
6. New-session ready, restored ready, confirmed death, session end and menu ready remain distinct and follow their approved prerequisites. Loads/cleanup/menu return do not announce new game.
7. Observer failure diagnoses and permits remaining notifications without rollback. Required initialization is checked explicitly before readiness; actual service loss still triggers safe gating/recovery.
8. Subscriptions end with their scope; late observers obtain current snapshot without historical milestone replay or cross-character leakage. Subscription/snapshot handoff does not miss transitions.
9. Application phase, session identity/status, operation phase and readiness can distinguish setup/menu/entry/established/death/teardown/recovery without equating readiness to resumed gameplay.
10. Loading reconstructs runtime lifecycle and emits Session Restored after actual success without replaying saved creation events. Cleanup/recovery gates remain visible independently of terminal operation/busy state.

These are future verification criteria. No implementation or runtime tests have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001–008 and CORE-010–013 v1, CORE-009 deferral, CORE-014 exclusion, decision log, CORE catalog and CORE architecture review. All nine CORE-015 interview decisions are represented. No conflict identified: current-batch serialization applies to lifecycle requests, not a new session-operation queue; safety gating and operation recovery remain independently authoritative. Readiness never implies all suspension is released. Detailed CORE-016/017 policies remain open.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation, define valid snapshot combinations/transition table, exact milestone prerequisites from owner contracts, subscription handoff/sequence mechanism and reentry/error isolation. CORE-016/017 will define pause/input/processing. These implementation dependencies do not waive consistency or safety criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-015. This document is finalized v1. Approval reference: CORE-015-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented owner contracts and implementation deferrals remain open; detailed CORE-016/017 policies are not approved by implication. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
