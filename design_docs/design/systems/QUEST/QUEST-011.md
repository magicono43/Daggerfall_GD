# QUEST-011 — Completion, tombstones and fault handling

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-011-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-011-interview-decisions).

## Gameplay purpose and intended player experience

Give quests a clear ending and preserve the player's record of what happened. Complete authored closing work before presenting a final outcome. If a technical fault interrupts progress, show that the quest needs recovery and preserve the work already done.

## Confirmed requirements

- Keep final status, an authored outcome summary and earned entries in journal history after runtime cleanup. Follow-up greetings and rumors use their own retention rules.
- Use explicit finalization for authored closing work, then commit one outcome, retire active interactions and clean up through the responsible owners. Resume only unfinished cleanup. Preserve supported imported ending-delay behavior where required.
- Suspend a technically faulted quest and preserve committed progress. Use supported retry or repair to resume. Ordinary quests can be explicitly abandoned where their rules permit. Protected story quests remain recoverable with tasks suspended.

See QUEST-011-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-011-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Quest.cs#EndQuest` sets a two-tick countdown intended to give newly started final tasks time to run. Completed quests are omitted from the active log. `QuestMachine.cs#TombstoneQuest` disposes the quest, records the tombstone, removes site links and emits the end event. `Quest.cs#TombstoneQuest` registers authored outcome follow-ups and removes active topics and other temporary quest links. `QuestMachine.cs#Tick` removes tombstones after more than one in-game week. It records update exceptions, schedules ordinary faulty quests for removal, and leaves protected quests eligible for later ticks. These findings come from static inspection.

## Detailed rules and behaviors

1. Accept an authorized ending request with the intended outcome and closing steps. Outcomes can include success, authored failure or authorized abandonment. A late branch under QUEST-010 stays active until an authored terminal condition applies. A technical fault enters recovery instead of automatically selecting an authored outcome.
2. During finalization, admit declared closing work, such as a final choice, reward, or reputation change. Close admission to ordinary objectives while this work runs. Keep required prompts and actions available until their owner outcomes settle. Imported quests can use supported end-delay semantics where needed for legacy ordering. Native quests declare the closing work explicitly.
3. When required closing work succeeds, commit the outcome once with its quest instance, ending time, summary and earned journal references. Preserve applicable one-time history. Publish a committed end notification with a stable outcome identity. Required owner work uses explicit operations. The end notification is available to observers after the outcome commits.
4. Retire active interactions and stale choices at the terminal boundary, then run owner cleanup. NPC-022 governs active topics and follow-ups. ITEM-023 governs explicit item disposition, including unloaded custody. Release temporary reservations and world links under their owners. Keep earned discoveries and authorized permanent rewards under their respective rules. Cleanup may retain a compact runtime record while outstanding work or scoped follow-ups still need it.
5. If a runtime fault occurs before outcome commit, suspend the affected quest's tasks and preserve committed effects, context and the interrupted phase. Expose an actionable recovery status and record diagnostics for QUEST-023. Retry or repair revalidates the suspended state and resumes only supported outstanding work. Authorize ordinary abandonment through its own outcome and disposition rules. Protected quests remain available for supported recovery. Other quests can continue under their own runtime rules.
6. If cleanup faults after the terminal outcome commits, preserve the outcome and journal record. Record the affected cleanup operation and recover only the unfinished work. Repeated callbacks, observer faults or reload cannot replay settled rewards, penalties, follow-ups or cleanup.

## Required data, inputs, outputs and events

Inputs include quest instance and definition IDs, ending request ID, outcome and closing requirements, authored summary, journal references, owner effect results, cleanup dispositions, protection policy and fault context. Outputs include finalizing, committed terminal outcome, suspended for recovery, and pending or completed cleanup. A committed end notification carries outcome identity and status. Journal and diagnostics are derived from the applicable retained records.

## Cross-system interactions

QUEST-004 owns durable one-time history. QUEST-009 supplies action progress and receipts, QUEST-010 supplies deadline branches, and QUEST-018 owns journal presentation. QUEST-007 preserves historical journal facts for retranslation. QUEST-019 and FACT own applicable rewards and reputation effects. NPC-021/022 govern rumors, greetings and topic retirement. ITEM-023 owns item disposition. LOC/WORLD own temporary site cleanup. QUEST-022, QUEST-023 and SAVE own restoration, diagnostics and recovery integration.

## Edge cases and failure conditions

- A final choice is still pending when an ending request arrives. Keep the declared closing choice valid and revalidate it at dispatch. Unrelated stale choices cannot advance the ending quest.
- A required reward commits and a subsequent closing action fails. Retain its receipt and suspend the remaining finalization work. Recovery cannot issue the reward twice.
- A linked quest item is in unloaded storage or has become permanent. Apply ITEM-023 to its authoritative custody and disposition. Unresolved items remain protected during recovery.
- A protected quest hits a repeated technical fault. Suspend task updates and retain recovery context. Routine ticks do not retry it.
- Follow-up retention ends after runtime cleanup. Journal history remains subject to its own retention rules and keeps readable historical context.

## Configuration and balancing

Authors configure terminal branches, closing work, outcome summaries, allowed abandonment, explicit cleanup dispositions and supported protection or recovery policy. Follow-up retention comes from its owner. No universal one-week removal policy or new reward formula applies. Supported legacy ending delays remain import behavior.

## Save/load considerations

Persist committed outcomes and journal history independently of disposable runtime state. Preserve supported finalization, suspension and cleanup progress with stable operation identities and committed owner receipts. Restore context before resuming work. Reload must preserve the final outcome and cannot replay completed effects. Unsupported pending states use SAVE's save boundary or recovery rules.

## Technical constraints

Target Godot 4.7.2. Use explicit finalization, terminal outcome and cleanup boundaries. Preserve stable identity and authored closing order. Keep journal records, active runtime state and recovery diagnostics independently addressable. Technical faults use checked recovery and do not select a narrative branch implicitly.

## Acceptance criteria

1. Success, authored failure or authorized abandonment commits once and leaves readable journal history after runtime cleanup.
2. Required closing steps can finish before the outcome commits. A supported imported ending delay preserves the relevant final task behavior.
3. Terminal interactions retire while authorized follow-ups remain governed by NPC rules. Item and site cleanup resumes outstanding work after interruption and preserves unrelated assets.
4. A technical fault suspends tasks and retains committed progress. A protected quest stays recoverable without retrying every tick. Ordinary abandonment requires authorization.
5. A fault after outcome commit leaves the outcome intact. Reload and duplicate delivery cannot replay rewards, penalties, follow-ups or completed cleanup.

## Compatibility review and outstanding questions

The specification follows QUEST-004 one-time history, QUEST-007 journal retranslation, QUEST-009 effect retention, QUEST-010 late branches, NPC-022 disclosure and follow-up rules, and ITEM-023 disposition. Exact protection authoring rules, retry and repair UI, imported ending-delay fixtures, journal organization and save schemas remain open.
