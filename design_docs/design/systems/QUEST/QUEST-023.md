# QUEST-023 — Quest faults and debugger visibility

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-13 with “I approve”. See QUEST-023-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-023-interview-decisions).

## Gameplay purpose and intended experience

Show players when a quest needs technical recovery and what they can do next. Let authors test a specific quest in the game world and trace its conditions, bindings, and committed effects.

## Confirmed requirements

- Notify the player once when a quest enters technical recovery and keep its status, reason and available actions visible in the journal. Keep authored failure distinct. Pre-offer failures stay in diagnostics unless they block progress or require player action.
- Provide a searchable inspector for tasks, timers, flags, resource bindings and recent outcomes. Support launching a quest by stable ID in the approved isolated in-world workflow. Inspection is read-only, and test controls that change state operate within the isolated context.
- Save the fault summary and recovery state needed for safe resumption. Keep a bounded detailed trace with optional export and aggregate repeated reports of the same fault.

See QUEST-023-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-023-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/QuestMachine.cs#StoreQuestException` retains up to 100 exceptions in its runtime list with the quest name and stack trace. Parsing exceptions use a separate logging path. `Assets/Scripts/Game/UserInterface/HUDQuestDebugger.cs` shows task status, timers and global variables for selected quests. These findings come from static inspection.

## Detailed rules and behaviors

1. Identify whether a diagnostic concerns validation, generation, activation, execution, cleanup or restoration. Preserve the owner's outcome and identify the affected quest and operation. Use QUEST-011 suspension for technical faults, retaining committed facts and any supported unfinished work.
2. Show one notice on entry to a recovery episode and retain a journal status until the owner resolves it. Show an actionable reason and only recovery actions available in the current context. A blocked load reports its reason through the load flow under CORE-013. A failed candidate handled during offer generation can stay in diagnostics. If it requires player action or blocks progress, present the relevant reason through the requesting owner.
3. Offer a searchable author view of resolved definitions and live quest instances. Show task state, timers, flags, bindings, command and provider identity, recent condition results and operation outcomes, including committed and pending work. Include source provenance and line information where available. Read-only views and previews do not rerun conditions, consume randomness or reveal hidden information in ordinary play.
4. Allow authors to select a specific quest by stable ID and exercise it in the actual game world under QUEST-005. Use normal validation, generation and runtime contracts. Time advancement and action triggers operate within isolated test context and respect owner boundaries. The exact in-game or external interface remains open.
5. Keep detailed traces bounded. Aggregate reports by quest instance or definition, fault phase, affected action or operation, and reason identifier. Retain occurrence count and recent context. Author-initiated export includes available quest, provider version, source, failed action and relevant outcomes. Treat the detailed trace as disposable diagnostic data. Eviction cannot erase the durable fault summary or recovery facts.

## Required data, inputs, outputs and events

Inputs include stable quest, task, action, operation and recovery IDs, content and provider provenance, source spans, condition and owner outcomes, fault phase and recovery status. Outputs include scoped player notice, retained journal status, author trace and optional export. Recovery actions request an outcome from the responsible owner.

## Cross-system interactions

QUEST-005 owns in-world author testing, QUEST-006 command provenance, QUEST-007 previews, QUEST-011 suspension and cleanup, and QUEST-022 save and recovery state. CORE-013 and SAVE own load compatibility and session readiness. DEV and MOD own tooling and provider lifecycle. UI presents scoped diagnostics and recovery actions.

## Edge cases and failure conditions

- Repeated reporting or reloading a notified recovery episode preserves its journal status without replaying its entry notice.
- An authored failed deadline shows its narrative outcome. A technical fault while applying that outcome preserves committed work and reports the technical issue.
- A trace may have no source line for a failure in an external owner. Report available operation and provider context.
- If a retry is no longer authorized, refresh the available actions and preserve committed effects.

## Configuration and balancing

Support bounded trace retention and author filtering by quest, phase and outcome. Exact trace limits and retention settings remain DEV decisions. This feature adds no balance formulas and does not change quest behavior when inspection is enabled.

## Save/load considerations

Persist fault summaries, notice state and the owner records needed for supported recovery. Restore the recovery status without resuming suspended work implicitly. A detailed trace can be absent after reload. Its absence does not affect recovery or committed operation records.

## Technical constraints

Target Godot 4.7.2. Keep player status, durable recovery state and detailed traces independently addressable. Scope diagnostic access and test mutations to their authorized contexts. Route retries through the original owner.

## Acceptance criteria

1. A technical fault shows one notice and a persistent journal status with available recovery actions. Authored failure and ordinary handled pre-offer failure follow their own paths.
2. An author can find and launch a quest by stable ID in an isolated in-world test, then inspect why a condition matched and which actions or effects committed.
3. Repeated reports aggregate within a bounded trace. An optional export identifies available source, provider and outcome context.
4. Reload preserves the fault summary and recovery progress even without the detailed trace. Retry resumes only supported outstanding work.

## Compatibility review and outstanding questions

The specification follows QUEST-005 isolated testing, QUEST-011 suspension and QUEST-022 durable recovery. Inspector interface, export format, trace limits and owner-specific repair controls remain open.
