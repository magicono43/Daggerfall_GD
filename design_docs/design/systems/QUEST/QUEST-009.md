# QUEST-009 — Task triggers, ordering and rearming

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-009-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-009-interview-decisions).

## Gameplay purpose and intended player experience

Advance scripted objectives in a predictable order. One conversation can advance several objectives when they are authored to observe the same event. When a conversation gives the player a chest, the follow-up that asks whether they opened it can wait for a fresh interaction. Recurring effects repeat under their authored rules and preserve completed work across reload.

## Confirmed requirements

- Preserve supported DFU task and action ordering for imported quests, including primary and secondary always-on trigger behavior and the post-action `PersistUntil` stop check. Native quests declare their trigger modes explicitly.
- The first eligible consuming task in an authorized interaction claims the input. Multiple authored objectives can observe a shared event. If competing quests can consume an interaction and the owner is ambiguous, offer the player a choice.
- An authored reset, new qualifying event, or recurring rule can start another task run. Save trigger state and committed effects so reload, duplicate event delivery and interruption preserve completed work.

See QUEST-009-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-009-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Quest.cs#Update` ticks resources before traversing tasks, skips dropped tasks, and flushes task messages and pending click rearms after each task. `Task.cs#Update` walks conditions and actions in script order and skips completed actions. An ordinary trigger can activate an inactive task. The first evaluated always-on trigger can set or clear the task, and subsequent always-on triggers can set it. `PersistUntil` checks its target after the action pass and rearms actions if the target remains unset. `QuestBreak` can exit the action pass early. `Task.cs#GetTriggerValue` can read a linked player global. These findings come from static inspection.

## Detailed rules and behaviors

### Order and trigger evaluation

1. Respect QUEST-008 tick eligibility and activation boundaries. Update resources and visit tasks in stable authored order. Preserve condition and action interleaving for supported legacy scripts, including the ability of later tasks to see earlier committed changes in that pass. Dropped tasks are skipped. An authored break or terminal state stops further processing for that pass under the applicable runtime rules.
2. For imported tasks, preserve ordinary activation, the first evaluated always-on condition's ability to set or clear, and later always-on conditions' ability to set. Preserve `PersistUntil` checking after its action pass and its supported rearm behavior. In particular, an eligible monitoring pass can run actions before stopping on a target that is already set. Preserve meaningful early exit and message order in compatibility fixtures.
3. Native definitions declare explicit modes. An event trigger requires a new qualifying event. A rising-edge trigger starts on a false-to-true transition. A continuous trigger keeps the task eligible while its predicate is true. Continued truth alone does not rearm completed effects. An initially true rising-edge predicate fires once from an initial false baseline. A restored task uses its saved baseline.
4. Read or change a linked global through its authoritative owner when the supported legacy mapping requires it. Preserve the order of committed changes. QUEST-020 owns the broader shared-global and quest chaining rules.

### Interaction ownership

1. Use a stable interaction identity and authorized target scope from MOVE/NPC. Within the chosen scope, the first eligible consuming task in authored order claims the interaction once. A later consuming task needs another authorized input. Keep the claim across an interrupted pass.
2. An explicitly authored observer can react to the same event without claiming the interaction. Observers process the event under their own trigger and effect rules. When multiple quests offer competing consuming actions and owner routing cannot determine a unique scope, use a scoped player choice and revalidate before dispatch. If the choice closes without dispatch, leave the competing task actions unexecuted.

### Rearming and committed effects

1. Track a distinct run for each legitimate activation or repetition. An authored reset, fresh qualifying event or declared recurrence can rearm the applicable effects. Skip committed effects during retries of the same run. Recurrence can use a declared condition or schedule and follows TIME and QUEST-010 for elapsed time.
2. Preserve completed effects and the state needed to resume supported outstanding steps if processing breaks or pauses. An unavailable or ambiguous operation outcome uses the responsible owner's recovery. Task rearm does not erase a completed reward receipt or authorize redelivery of a consumed input.

## Required data, inputs, outputs and events

Inputs include the quest and task IDs, ordered declarations, trigger mode, condition and prior value, scoped event ID and target, run ID, action completion and owner outcomes, and any linked global or recurrence state. Outputs include task activation, continuation, stop, rearm, interaction claim, and committed operation outcomes. Events are routed through their owners and retain stable identity.

## Cross-system interactions

QUEST-005 and QUEST-006 define validated commands and meaningful source order. QUEST-008 governs activation and tick boundaries. QUEST-010 owns clocks and recurrence timing. QUEST-011 and QUEST-023 own termination and runtime error recovery. QUEST-018 owns task message presentation. MOVE-023 and NPC govern authorized interaction routing. CORE-015 governs committed notifications. QUEST-022 and SAVE coordinate restoration.

## Edge cases and failure conditions

- Two tasks compete for one merchant click. The first eligible consuming task claims it. A later task can react only as an explicit observer or to a later eligible input.
- A native continuous condition stays true across several ticks. An effect committed for its current run stays committed until an authored repeat or new activation permits another run.
- A task breaks after a reward commits and before a later action. Resume only supported outstanding work. A repeated event or stale choice cannot repeat the reward.
- A dropped or retired task cannot claim new interactions. Stale callbacks revalidate under the scope owner.

## Configuration and balancing

Authors declare trigger mode, condition combinations, event observation or consumption, recurrence and reset rules. Legacy import supplies its supported compatibility semantics. No global tick rate, recurrence interval or reward frequency is defined here.

## Save/load considerations

Persist the current trigger and prior edge state, run identity, committed action outcomes, and supported pending interaction or recurrence state. Restore these alongside authoritative owner state before tasks resume. Resuming a task does not create a new rising edge or replay a consumed input. Exact snapshot boundaries and unsupported pending-state recovery remain QUEST-022 and SAVE decisions.

## Technical constraints

Target Godot 4.7.2. Keep authored ordering deterministic and separate trigger evaluation, interaction claims and owner effect commits. Do not rely on quest registration order to resolve an ambiguous interaction between quests.

## Acceptance criteria

1. Imported tasks preserve authored order, primary and secondary always-on behavior, and the post-action `PersistUntil` check.
2. Native event, rising-edge and continuous modes exhibit distinct behavior. A continuous true condition cannot repeat a committed effect without a legitimate new run.
3. One scoped click advances only its first eligible consuming task. Explicit observers can react. Ambiguous competition across quests prompts a choice before dispatch.
4. Repeated callbacks, task interruption and reload preserve claims and committed effects. An authored reset, fresh qualifying event or recurring rule can permit another run.
5. Loading a task with a previously true rising-edge predicate does not manufacture another edge.

## Compatibility review and outstanding questions

The specification follows QUEST-005 and QUEST-006 command contracts, QUEST-008 tick boundaries and MOVE-023 scoped choices. Exact native condition syntax, cross-quest update ordering outside routed interactions, compatibility fixtures and save schemas remain open.
