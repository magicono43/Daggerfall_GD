# QUEST-008 — Immediate and scheduled starts

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-008-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-008-interview-decisions).

## Gameplay purpose and intended player experience

Start quests through a predictable boundary whether they come from a player choice, a new-character opening, or a scripted chain. The quest starts with its intended giver and faction. A queued start can wait for declared readiness, and a failed start reports a truthful outcome.

## Confirmed requirements

- Capture giver and faction context from the authorized request. Revalidate it at activation and publish the active quest, required logical bindings, and applicable one-time history before notifying observers. A valid logical binding can refer to an unloaded NPC. Giverless starts require authored support.
- Process scheduled starts in request order at the beginning of the next eligible quest tick. Quests activated in that phase can update later in the same tick. Requests issued during task processing wait until the next eligible tick. Immediate starts outside task processing can commit immediately, with tasks beginning on the next eligible update.
- Persist supported pending starts with original context and stable identity. Revalidate at activation. Report invalid required context, preserve one-time eligibility on failure, and permit only explicitly supported readiness waits. Duplicate delivery reuses its recorded outcome.

See QUEST-008-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-008-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/QuestMachine.cs#StartQuest` calls `Quest.Start`, adds dialogue topics, registers the quest, emits `OnQuestStarted`, and then attempts to bind the last-clicked NPC. `Quest.cs#Start` captures world time and a smaller-dungeons setting. `ScheduleQuest` appends a quest to the start queue. `Tick` drains that queue before updating active quests and emits a second start notification after each successful queued `StartQuest` call. These observations come from static inspection.

## Detailed rules and behaviors

### Start request and commit

1. Record the request identity, origin, quest definition or prepared instance, and session scope. Capture the intended giver, faction context, and any offer or prerequisite references from the requesting owner. An automatic or chained start can be giverless when its authored contract allows that context.
2. Revalidate authorization, scope, required references and one-time eligibility at activation. A stable logical binding is enough for a valid unloaded NPC when the quest supports deferred scene attachment. Missing or invalid required context fails unless an explicitly supported readiness policy can still resolve it. Preserve the original target throughout the wait.
3. Commit the quest instance, actual activation time, required logical bindings and applicable one-time history together under QUEST-004. Stage required owner work before making the quest observable as active. Apply NPC-022 disclosure rules to any registered dialogue resources. A failed start cannot leave an active quest, consumed history or visible quest links from partial work.
4. Emit one committed start notification after successful activation. Required registration and bindings belong to the commit. Observer failures are diagnosed under CORE rules and do not undo activation or permit a second start. Acceptance confirmation and immediate opening presentation follow their existing owner boundaries.

### Scheduling and first update

1. An eligible tick respects the applicable simulation and startup gates. At its beginning, fix the eligible request set and process it in recorded order. Requests created by activation or its observers wait for the next eligible tick.
2. A request in an approved readiness wait keeps its identity. Later independent requests can proceed while an earlier request waits. Explicit dependencies, including QUEST-004 startup dependencies, continue to govern when dependent requests may activate.
3. Successfully activated scheduled quests can enter the active update phase later that tick. During task processing, new start requests enter the next eligible tick's queue. An immediate request outside task processing can commit at a safe boundary and first runs tasks on the next eligible update. Starts issued while draining the queue follow the queue boundary in rule 1.
4. Measure quest age from committed activation time. The rules for task ordering, clocks, termination and failure after activation remain with QUEST-009 through QUEST-011 and QUEST-023.

## Required data, inputs, outputs and events

Inputs include stable request, session, quest definition and instance IDs, origin, scheduling order, optional offer and giver IDs, faction context, prerequisites, readiness policy and world time. Outputs include queued, waiting, committed, failed, or the recorded result of an earlier delivery. The committed start notification carries the activation identity and origin. Pending requests are excluded from the active quest set.

## Cross-system interactions

QUEST-004 owns one-time history and startup dependencies. QUEST-003 owns fallback before a social offer settles. NPC-023 and MOVE-023 own provider identity and offer authorization. NPC-022 owns disclosure. CORE-005/015 govern scope and notifications. CORE-012 owns startup presentation and control release. QUEST-012 through QUEST-017 own resource binding. QUEST-022 and SAVE own restoration and recovery.

## Edge cases and failure conditions

- Another NPC is clicked while a start waits. The request retains its authorized giver. If that giver is now invalid, activation fails or waits under the declared policy.
- A queued offer expires or another offer consumes the same one-time definition. The queued start fails with the applicable outcome and commits no additional history.
- A valid giver exists in an unloaded area. The stable logical binding can commit and scene attachment follows resource readiness. A missing required giver uses recovery.
- A quest chains another quest during its task update. The child waits for the next eligible tick. A repeatable definition can start from separate authorized requests, while redelivery of one request returns its recorded outcome.

## Configuration and balancing

Quest definitions can declare required context, giverless support and supported readiness conditions. Scheduling uses deterministic request order. No fixed tick interval, wait timeout or balance formula is introduced here.

## Save/load considerations

Persist supported pending requests with request identity, relative order, original context, and readiness or prerequisite state needed to resume. Restore request and activation records coherently with history and active instances. Resume pending requests only after owner state is ready. Loading an active instance does not emit another start. Unsupported pending states use the applicable SAVE recovery or save boundary. The exact schema and supported wait types remain integration decisions.

## Technical constraints

Target Godot 4.7.2. Use one authoritative activation operation for immediate and scheduled routes. Scope requests to the correct session and use stable context references. Keep queue processing, activation commit and task update phases distinct.

## Acceptance criteria

1. Immediate and scheduled starts use the same activation contract and emit one notification each after the quest, bindings and history are visible.
2. A scheduled quest can update later in its activation tick. A start requested during task processing first runs at the next eligible tick. Requests added while draining the queue wait for the next eligible tick.
3. Scheduled requests retain their giver and faction. Unloaded valid bindings can activate under their policy. Invalid required context produces failure without consuming one-time eligibility.
4. Readiness waits retain request identity and do not block independent ready starts. Declared dependencies still apply. Duplicate deliveries cannot activate a second instance.
5. Save/load preserves supported pending requests and their order, revalidates them against restored state, and does not start already active quests again.

## Compatibility review and outstanding questions

The specification follows QUEST-004's shared activation and history commit, NPC-022 disclosure, NPC-023 offer continuity and CORE-012 startup gates. Exact eligible-tick gates, required binding sets, wait types, and save boundaries remain owner integration decisions.
