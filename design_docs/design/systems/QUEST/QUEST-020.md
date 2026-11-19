# QUEST-020 — Global flags and quest chaining

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-020-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-020-interview-decisions).

## Gameplay purpose and intended player experience

Let later quests respond to earlier choices and outcomes. A late delivery can unlock a different follow-up, and an independent quest can continue after its parent ends. Repeatable chains can offer new work when a genuine new trigger occurs.

## Confirmed requirements

- Allow quests to read committed outcomes and explicitly declared package-scoped story flags. Keep ordinary task state private and support mapped DFU globals for imports.
- Support independent follow-ups and linked children. A linked child reports its outcome and follows an authored continue or authorized cancellation policy when its parent ends first. Technical faults use recovery.
- Reject circular waits and automatic chains that can start indefinitely without a new trigger. Allow deliberate repetition gated by a fresh interaction, world event or declared cooldown. Retry retains the existing result and consumed one-time quests use the authored unavailable branch.

See QUEST-020-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-020-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Parser.cs#IsGlobalReference` recognizes symbols in the global table. `Task.cs#GetTriggerValue` and `SetTriggerValue` can read and write player-side persistent globals. `Actions/StartQuest.cs` resolves and queues a quest. `Actions/RunQuest.cs` queues and retains the child's UID, branches on completion or missing child, and can tombstone a referenced unfinished child on disposal. These findings come from static inspection.

## Detailed rules and behaviors

1. Expose committed quest outcomes through stable identities and explicitly declared story flags through package-qualified keys. Store flags per character with a declared type, initial value and write authority. Cross-package readers declare the dependency. Preserve supported legacy shared-global behavior through explicit mappings. Ordinary task IDs and state stay private to their instances.
2. Commit flag writes through the authoritative owner with stable operation identity. Evaluate reads against committed state. A missing or incompatible required flag is a validation or recovery outcome. An authored query of a repeatable quest's outcome specifies the instance or outcome history, including a declared selection rule where applicable.
3. A chain request identifies its source action or trigger, target definition, context and link mode. Schedule starts from task processing through QUEST-008. Independent follow-ups continue under their own lifecycle once activated. Linked children report their committed outcome to the parent through the specific child instance. Commit the applicable parent continuation once. Failed activation and technical recovery remain distinguishable from a child's authored failure.
4. A linked child declares what happens if the parent ends first. Continuing releases the parent's wait and leaves the child active. Cancellation is a checked request under the child's lifecycle rules. If cancellation cannot commit, use the declared recovery rather than silently ending the child. Retain the linked outcome until the waiting parent settles its continuation or releases the wait.
5. Reject statically identifiable circular waits and unbounded automatic start cycles. Check dynamic links before admitting them and report a blocked chain when a cycle or missing repeat gate is detected. An authored repeat must use a distinct qualifying event or cooldown occurrence. A repeated delivery of the same trigger reuses its recorded result. A consumed one-time definition reports unavailability under QUEST-004 without starting again.

## Required data, inputs, outputs and events

Inputs include stable package, flag, character, quest, instance, chain request and trigger IDs, outcome selectors, link mode, parent-end policy and repeat gate. Outputs include committed flag values, queued or activated children, linked terminal outcomes, unavailable starts, and explicit validation or recovery results. A committed child outcome carries the instance identity used to dispatch its parent continuation.

## Cross-system interactions

QUEST-004 owns one-time history. QUEST-005 and DATA-012 validate definitions and dependencies. QUEST-008 owns scheduled starts, QUEST-009 owns task runs, QUEST-010 owns cooldown timing, and QUEST-011 owns terminal outcomes and cancellation. MOD owns package dependencies. QUEST-022 and SAVE coordinate durable flag and chain state.

## Edge cases and failure conditions

- Two packs use the same short flag name. Package qualification keeps them distinct. A cross-package consumer uses its declared reference.
- Two instances of a repeatable child exist. A waiting parent receives the outcome of its own linked instance.
- A child faults or its reference becomes incompatible on load. Preserve any committed work and use recovery. No narrative failure is inferred from a missing runtime representation.
- Two quests would wait on each other, or an automatic start loop has no qualifying repeat gate. Reject the invalid dependency without spinning the quest queue.

## Configuration and balancing

Authors configure flag definitions and access, outcome prerequisites, independent or linked starts, parent-end policy, and repeat gates. Cooldown duration is authored and follows QUEST-010 and TIME. No universal cooldown or chain length is set here.

## Save/load considerations

Persist committed flags, outcome facts used by declared dependencies, supported pending starts, parent and child links, repeat-gate state and continuation receipts. Restore references and validate compatibility before resuming waits. A restored child is not started again, and a restored outcome cannot repeat its continuation.

## Technical constraints

Target Godot 4.7.2. Use explicit durable identities and authorized operations. Keep dependency validation, activation, and outcome delivery distinct. Validate fixed dependencies before publication and dynamically resolved links before admission.

## Acceptance criteria

1. A follow-up can read an authorized story flag or committed outcome. A cross-package reference requires a declared dependency. Local task state remains private.
2. Independent children continue after parent completion. Linked children deliver their own outcomes once and apply the authored parent-end policy.
3. Circular waits and ungated automatic start cycles are rejected. An authored repeat can proceed after a fresh qualifying trigger. Duplicate delivery and consumed one-time targets cannot start again.
4. Save/load retains flags, links and pending continuations. Technical faults use recovery without replaying starts or selecting an authored failure branch implicitly.

## Compatibility review and outstanding questions

The specification follows QUEST-004 one-time eligibility, QUEST-008 scheduled activation, QUEST-009 task runs, and QUEST-011 terminal and recovery rules. Exact legacy global mappings, flag schema, cycle analysis and save representation remain open.
