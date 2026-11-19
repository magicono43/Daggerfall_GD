# CORE-018 — Gameplay shortcuts and quick actions

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Route configurable gameplay shortcuts and quick actions predictably through context and owner validation, without bypassing restrictions or giving false save/load feedback.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Retain the general DFU action set: options, character sheet, inventory, travel, rest, transport, quest journal/notebook, spellbook, magic-item use, status and automap. Support configurable keyboard/controller bindings. Exact defaults and window behavior remain input/UI scope; shortcuts invoke owners rather than duplicate gameplay rules.
- Gameplay shortcuts require eligible gameplay-input context. Menus/text/loading/confirmation use their own bindings while they own input. Never bypass rest, save or other owner restrictions.
- Quicksave uses SAVE validation/safe-write and reports success only after persistence. Quickload uses CORE-007/013 coordination and the [SAVE-005](../SAVE/SAVE-005.md) preflight and confirmation policy. Missing current-character quicksave gives brief non-blocking feedback.

Second interview, confirmed by the user on 2026-11-05:

- Admit at most one window-opening/quick action per input dispatch, with documented priority and Escape/options first. Simultaneous quicksave+quickload rejects both with brief conflict feedback; no guessed overwrite/load choice. Exact remaining priorities belong to input/UI.
- Activate once per deliberate press, without automatic window/quick-action repeat. A key held across menu close must not reopen or trigger the newly active context.
- SAVE owns a designated quicksave target per stable character identity, not display name. Capture quickload target save identity at invocation and revalidate before replacement; rename/selection changes cannot redirect it. Rotation/backups remain SAVE scope.

Third interview, confirmed by the user on 2026-11-05:

- Warn on binding conflicts and require explicit resolution before Apply when actions can coexist in one context. Reuse across mutually exclusive contexts is allowed. Required menu navigation remains reachable; controller disconnect must not trap the player.
- Reject conflicting quick actions while operations are busy, with brief feedback rather than queueing. SAVE defines conflicts involving saves; CORE-007 governs session changes. Recheck eligibility at execution, not only press time.
- Brief non-blocking feedback covers actual success, missing quicksave, busy/conflicting input and ordinary restrictions, using owner-specific reasons when available. Actual write/load failures use established recovery UI. Submission alone never establishes success.

## Inherited requirements

CORE-016 context handoff consumes input, requires fresh discrete gameplay actions and retains independently owned suspension. CORE-007 serializes session changes with stable request data, discard confirmation and busy outcomes. CORE-013 native loading excludes DFU/classic compatibility and separates restored state from new-character grants. CORE-003 settings persistence and CORE-006 application contracts govern bindings as later classified. CORE-015 lifecycle remains separate from windows; CORE-017 simulation eligibility is not interchangeable with gameplay input. CORE-009 stays deferred and CORE-014 outside scope.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/GameManager.cs`, Update/IsPlayingGame: options/status/automap have independent completed-action checks, common windows use an else-if priority chain, and quick actions use action-start checks with quicksave before quickload. Prevented quicksave shows cannotSaveNow. Quickload checks current-name quicksave existence before prompting. SAVE owns actual quick operations and confirmation helpers.

Baseline: local DFU 1.1.1 Release; exact commit unavailable per repository overview. Static inspection only; source remains unchanged. Original priority/default keys/name-based save lookup are not approved by implication.

## Detailed routing rules

The supported action family includes options, character sheet, inventory, travel map, rest, transport, quest journal, notebook, spellbook, magic-item selection/use entry, status, automap, quicksave and quickload. Invocation does not approve every owner's detailed feature behavior, spell execution or rest eligibility. Keyboard/controller bindings are configurable through validated settings; exact defaults/chords and controller mappings remain input/UI decisions.

Collect deliberate shortcut activations only from the eligible input context. Text/menu/loading/confirmation contexts handle their own actions, not gameplay shortcut fallthrough. Consume handoff actions under CORE-016. One deliberate press produces at most one shortcut activation; held/repeated input cannot reopen a window after close or trigger a newly active context. Owner-specific continuous controls are separate from these discrete shortcuts.

Arbitrate window-opening and quick actions from one dispatch before mutating UI or submitting operations. Escape/options has documented first priority for normal selection, and the full remaining order must be explicit rather than incidental code order. If quicksave and quickload are both candidates, reject both with brief conflict feedback regardless of their priority positions. Other eligible candidates remain subject to the one-action limit and declared order. Do not dispatch suppressed shortcut actions later as a hidden queue. Exact grouping of raw device events into an input dispatch is an input-system contract to define.

Binding validation prevents accidental same-context dual eligibility before Apply; runtime arbitration still protects simultaneous presses on different keys and configurations changed by supported loading paths. Mutually exclusive contexts may reuse a key. Menu navigation must remain reachable if the controller disconnects; input/UI must define a recovery path without inventing a new device requirement here. Invalid configuration recovery follows CORE-003, while accepted binding changes follow CORE-006's declared activation contract.

Route the winning action to UI or the authoritative owner, with current session/context identity. Recheck context and feature eligibility at execution because queued presentation or asynchronous owner work may observe changed state. Rest, travel, casting, item use and saving restrictions are not bypassed by shortcuts. If a winner is rejected, report its reason rather than silently cascading into a different action the player also pressed. Opening a window does not itself perform a transaction or begin a dangerous activity unless its owning feature defines that behavior.

Quicksave resolves SAVE's designated target for the current stable character identity and uses normal validation, coherent snapshot/publication and recovery. SAVE defines whether quicksave replaces/rotates generations and how first quicksave creates its target. This document approves neither number of backups nor overwrite-format mechanics. Success appears only after actual persistence; busy/restriction is a rejection, not a save failure or false success.

Quickload resolves only the current character's designated quick target, captures its stable save identity and submits through CORE-007/013. Under the 2026-11-17 SAVE-005 amendment, preflight prepares and validates consistent input before the default living-session discard prompt. Validated mod policy can suppress the prompt. Applicable recovery disclosure remains required before replacement. A rename or changed UI row cannot redirect the target. A missing quicksave gives brief non-blocking feedback. Changed or missing selected input follows CORE-007/013 safe failure.

Conflicting save/transition work rejects as busy rather than queueing, using SAVE conflict rules and CORE-007 operation admission. This does not require rejecting every harmless window action while any background work exists; context/owner policies decide eligibility. No quick action may bypass cleanup/recovery gates. Stale result callbacks cannot show current-character success for a replaced session.

Present brief non-blocking messages for confirmed success and ordinary rejection (restrictions, missing target, busy or input conflict). Use the authoritative owner's reason where available. Actual I/O/load failures retain CORE-001/007/013 and SAVE recovery paths; do not downgrade them to a disappearing success-style popup. No duplicate success popup should be generated separately by dispatcher and owner for the same result. Localization, durations and exact wording remain UI scope.

## Relevant formulas and parameters

No gameplay formulas or balance values apply. At most one window-opening/quick action is dispatched per input batch; simultaneous quicksave/quickload rejects both. Each deliberate press activates once. Exact full priority table, dispatch-batch boundary, binding defaults, message duration and quicksave retention are deferred owner contracts, not invented constants.

## Required data

Action identifiers, configurable device bindings/context eligibility, conflict validation, fresh-press/consumption state, explicit priority table, originating session/character identity and owner restriction results. Quick actions additionally require SAVE-owned target identity, operation/busy status and actual completion/failure result. Names and UI list positions are presentation data, not durable target identity.

## Inputs, outputs and events

Inputs: eligible discrete actions, binding edits/Apply, context/device changes, lifecycle/session changes and owner results. Outputs: one selected UI/owner request, rejected/suppressed candidate outcomes, validation feedback and truthful non-blocking/recovery presentation. API names are deferred. Distinguish activation, admission, execution and completion; dispatch acceptance is not persistence/restoration success.

## Cross-system interactions

Input/UI own bindings, contexts, navigation and priority behavior; CORE-016 owns handoff/focus/fresh-press rules. CORE-003/006 govern validation/persistence/application of preferences. CORE-015/017 expose distinct lifecycle/simulation/input conditions. UI/CHAR/ITEM/MAGIC/TIME/WORLD owners validate feature operations. SAVE owns save eligibility, quick targets, publication/retention and save conflicts; CORE-007/013 govern coordinated quickload. CORE-002 diagnostics remain optional/privacy-safe. CORE-009 is deferred and CORE-014 outside scope.

## Edge cases and failure conditions

- Multiple distinct presses can arrive together even with conflict-free bindings. Use explicit arbitration; separate independent checks must not open multiple windows in the same dispatch.
- Escape competing with other actions uses declared priority, but never makes simultaneous quicksave/quickload a guessed overwrite/restore choice.
- Held keys across context handoff and controller reconnect cannot generate fresh discrete actions or bypass the active modal. Menu navigation remains recoverable on device loss.
- Bindings that conflict only in mutually exclusive contexts are allowed; same-context ambiguity must be resolved before Apply. Exact aliases/chord overlap detection belongs to input validation.
- A context may change after initial press. Revalidate before owner mutation rather than applying stale input to another session/window.
- Current character rename must not lose or redirect its quick target. Two characters sharing a display name must not share a target accidentally.
- Missing or changed quicksave after confirmation fails safely. Do not re-resolve to an unrelated save or skip preflight just because the target existed at press time.
- Busy saves/loads reject conflicting actions without deferred surprise execution. Actual persistence failure cannot claim success; actual restore failure follows safe cleanup.
- Owner rejection cannot silently cause a lower-priority shortcut to execute. Duplicate/late completion messages cannot suggest a new character was saved/restored by old work.

No automatic save-on-shortcut-menu, cross-character quickload, hidden input queue or new gameplay restriction is introduced. Main risks are accidental overwrite/load, modal input leakage, wrong-character targets and misleading feedback.

## Configuration and balancing options

Support configurable keyboard/controller action bindings with same-context validation and accessible menu navigation. Default keys, chords, exact priority beyond the agreed rules, per-window toggle behavior and feedback timing remain input/UI scope. SAVE owns quick-slot rotation/backups. These are operational preferences, not new balance mechanics; owner gameplay eligibility remains authoritative.

## Save/load considerations

Bindings are application settings, not character-save pose/history. Quick targets use stable character/save identities and never a display-name lookup contract. SAVE must define target creation/retention and safe writes; no new serializer format is chosen here. Quickload restores saved state under CORE-013 without rerunning grants or changing application preferences/source root. Press/dispatch state and raw UI handles are transient and must not be replayed after load.

## Technical constraints

Project target: Godot 4.7.2. Use explicit action/context routing and owner operations rather than copying DFU's independent message checks. Preserve fresh-press semantics across device/context changes, validate bindings and arbitrate before side effects. Carry stable origin/target context through asynchronous work. Engine input APIs, binding schema, dispatch-batch mechanics and UI implementation are deferred; no direct SAVE bypass is approved.

## Acceptance criteria

1. General approved action family is routable with configurable keyboard/controller bindings; exact owner behavior is not duplicated in shortcut code.
2. Gameplay context gates shortcuts; menus/text/loading/confirmation own input independently. Owner restrictions are checked again at execution.
3. One window/quick action at most occurs per dispatch, using documented priority with Escape/options first. Simultaneous quicksave/quickload rejects both with conflict feedback, without hidden later dispatch.
4. One deliberate press activates once. Held keys or autorepeat cannot reopen/activate across context handoff; opening/closing actions do not leak to gameplay.
5. Same-context binding conflicts require resolution before Apply; mutually exclusive reuse works. Menu navigation remains reachable after controller disconnect.
6. Quicksave uses SAVE validation/safe persistence, then truthful success feedback. Restriction/busy is explained; actual write failure invokes recovery rather than success.
7. Quickload captures a SAVE-owned current-character target by stable identity, always runs preflight and follows the SAVE-005 prompt and disclosure policy. Rename or selection changes cannot redirect it.
8. Missing quicksave explains briefly, with no silent no-op/cross-character fallback. Changed/disappeared target after invocation fails safely rather than substituting a save.
9. Conflicting actions during save/transition reject with busy feedback instead of queueing; CORE-005/007 cleanup gates remain respected.
10. Owner-specific ordinary rejection/success uses brief non-blocking feedback; actual failure uses established recovery UI. Submission alone never produces success, and duplicate/stale results cannot misreport current-session state.

These are future verification criteria. No implementation/runtime tests have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001–008, CORE-010–013 and CORE-015–017 v1, CORE-009 deferral, CORE-014 exclusion, decision log, CORE catalog and CORE architecture review. All nine interview decisions are represented. No conflict identified: quickload retains living-session confirmation/preflight, context eligibility is distinct from simulation, safe persistence remains SAVE-owned and no hidden operation queue is added. Binding activation timing remains governed by CORE-006 and owner definitions.

## Outstanding questions and approval

No further blocking shortcut-policy choice is currently identified. Input/UI must define full priority table, raw-event batch boundary, binding defaults/chord conflicts, context action availability and device-loss navigation. SAVE must define quick-target creation, conflicts and generation retention. Feedback timing/wording and APIs remain deferred. These dependencies do not waive arbitration, identity or recovery criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-018. This document is finalized v1. Approval reference: CORE-018-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Exact bindings, remaining priorities, dispatch mechanics and SAVE target/retention contracts remain open as documented. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
