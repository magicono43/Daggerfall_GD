# QUEST-018 — Prompts, journal and authored dialogue

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-018-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-018-interview-decisions).

## Gameplay purpose and intended player experience

Present quest information and choices in a readable order. Keep current objectives easy to find and preserve a chronological account of what the player learned and did. Players can revisit past entries and see how a quest ended.

## Confirmed requirements

- Present one blocking quest prompt at a time in authored order. Support passive notices and informational acknowledgments. Dismiss a choice prompt only through its authored cancellation or deferral policy.
- Show a current objective summary and chronological earned updates. Keep hidden branches undisclosed. Preserve earned entries and final outcomes in history.
- Mark once-per-quest messages shown after successful presentation. Commit choices once after revalidation. Restore supported pending prompts with the same variant and choice IDs, and apply authored deadline rules before accepting a pending response.

See QUEST-018-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-018-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Quest.cs#ShowMessagePopup` queues popup boxes and supports once-per-quest display. `Actions/Prompt.cs` and `PromptMulti.cs` start authored tasks from button responses. `Quest.cs#AddLogStep` stores a timestamped active entry and replaces any entry for that step ID. `RemoveLogStep` removes it, and completed quests are omitted from the active log. `Actions/JournalNote.cs` supports authored notebook updates. These findings come from static inspection.

## Detailed rules and behaviors

1. QUEST issues a scoped request for a passive notice, blocking informational acknowledgment or blocking choice. UI presents one blocking quest prompt at a time. Preserve authored order and CORE-012 opening presentation rules. Use committed enqueue order to break ties between otherwise independent prompts. Passive notices cannot bypass a required acknowledgment or choice.
2. Bind each choice to its stable ID and authored branch. Revalidate the prompt, session, quest, choice and applicable prerequisites at commitment. Apply deadline and late-branch rules under QUEST-010. A stale response reports unavailability or enters authored recovery. Repeated delivery returns the prior result without dispatching the branch again.
3. Closing an informational prompt records its acknowledgment where required. A choice prompt permits closure only through supported cancellation or deferral. Deferral retains the same pending choice and terms under the owner policy. Cancellation uses its declared outcome. Decline is an explicit response. NPC-023's approved stock and deferred offer lifetime rules govern NPC offers.
4. Record once-per-quest presentation by quest instance and message ID after all required pages are successfully shown. Failed presentation keeps the request recoverable. Apply authorized dialogue reveals separately under NPC-022 and preserve translation and variant semantics under QUEST-007.
5. Maintain a current objective summary using disclosed, authoritative facts. Record earned updates with their original facts, timestamp, message context and readable fallback under QUEST-007. Use committed update order for equal timestamps. Updating or removing a current objective preserves its earned historical entries. Hidden branches remain outside the journal until authorized disclosure.
6. On terminal outcome, move the quest to history with its final status, authored summary and earned entries under QUEST-011. Technical suspension uses the quest's recovery status. Authored topics, greetings and rumors retain their NPC-owned lifetimes.

## Required data, inputs, outputs and events

Inputs include quest, prompt, message, variant, choice and operation IDs, authored order and branch references, dismissal and display policy, retained context, deadline state and authorized disclosures. Journal records include objective identity, committed order, time, historical facts and fallback text. Outputs include a pending or successfully presented message, acknowledgment, canceled or deferred prompt, committed choice or unavailable outcome, and updated journal state.

## Cross-system interactions

QUEST-007 and DATA-013–016 govern localization, retained variants and substitutions. QUEST-009 routes committed responses to tasks, QUEST-010 owns time checks, and QUEST-011 owns finalization and terminal history. CORE-012 governs startup presentation. NPC-021/022/023 own rumor, disclosure and offer lifecycles. UI presents owner state. CORE-013, QUEST-022 and SAVE govern restoration.

## Edge cases and failure conditions

- A missing translation or unusable essential prompt follows fallback and owner recovery. No response commits merely because rendering failed.
- Two quests request blocking prompts together. Preserve authored ordering and break independent ties by enqueue order.
- An objective moves after a clue was written. Update the current summary only after authorized disclosure. The prior entry still describes the original location.
- A deadline passes while a choice is pending. Revalidate the response before committing and use the applicable authored late or unavailable outcome.
- A partial presentation, duplicate button callback or stale callback after load cannot acknowledge unseen content or replay a choice.

## Configuration and balancing

Authors configure prompt type, choices, dismissal and deferral, once-per-quest display, objective updates, earned entries and disclosure. Time restrictions and outcome effects follow their owning features. This feature adds no numeric balance formulas.

## Save/load considerations

Persist journal state, presentation receipts and supported pending prompt and choice state with stable identities and retained variants. Rebuild supported UI from owner state and reject stale session callbacks. Restore queue order and revalidate consequential actions before dispatch. Preserve committed branches and reveals. Unsupported required prompt state uses SAVE recovery.

## Technical constraints

Target Godot 4.7.2. Keep presentation, acknowledgment, branch commitment and journal updates independently addressable. Store durable owner state independently of UI objects. Honor CORE suspension and restoration boundaries.

## Acceptance criteria

1. Blocking prompts appear one at a time in authored order. Passive notices can present information. A pending choice follows its authored closure policy.
2. Once-per-quest display is recorded after successful presentation. Failed display permits recovery. A choice commits at most once after current context and deadline validation.
3. Active summaries reflect disclosed progress. Earned updates retain their historical facts and order. Hidden branches remain undisclosed and terminal quests retain journal history.
4. Supported reload restores pending prompts with the same variant and choice IDs. Reload and duplicate callbacks do not replay choices, reveals or committed journal updates.

## Compatibility review and outstanding questions

The specification follows CORE-012 prompt order, CORE-013 owner-driven UI restore, QUEST-007 retained presentation, QUEST-011 terminal history, and NPC-022/023 disclosure and offer lifetime. Exact UI controls, save boundaries and authored prompt migration remain open.
