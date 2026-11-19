# QUEST-021 — Cross-system action side effects

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-13 with “I approve”. See QUEST-021-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-021-interview-decisions).

## Gameplay purpose and intended player experience

Let quests respond to gameplay and cause authored changes beyond their own tasks. A quest might react to a spell cast, train the player, transport them to a destination, or arrange an encounter. The quest advances when the required gameplay outcome actually happens.

## Confirmed requirements

- Support weather and spell checks and explicit requests for teleportation, scripted crime and training. Support a broader range of quest actions and allow mods to add operations that the responsible gameplay systems expose.
- Require explicit, owner-supported exceptions to ordinary prerequisites. Each exception declares the rule it changes.
- Wait for the required outcome before advancing dependent branches. Handle rejection and faults through authored alternatives or recovery. Training commits from an explicit choice or authored trigger. Closing or restoring a popup cannot repeat it.

See QUEST-021-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-021-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Actions/Weather.cs` checks weather. `CastSpellDo.cs` listens to ready and cast events, matches spell effects, and starts a task. `TeleportPc.cs` starts a transition and finishes placement after respawn processing. `SetPlayerCrime.cs` assigns the player's current crime field. `TrainPc.cs` applies free training after a completion popup closes, advancing world time by three hours, reducing fatigue and adding skill progress. These findings come from static inspection.

## Detailed rules and behaviors

1. Use QUEST-006 command declarations to distinguish read-only conditions, observers of committed events, and operations that request changes. A weather condition reads the declared area's current state. A cast observer matches the declared spell or effects and the permitted source. A scripted cast counts only where the objective's source policy admits it.
2. Resolve the stable targets and authority for each operation. The responsible system validates the request and commits the result. An authored exception names the prerequisite it alters. Free training can waive payment while applying authored time and fatigue. Scripted transport can waive spell costs while requiring a valid arrival. A scripted accusation uses a supported LAW operation with its declared jurisdiction and attribution.
3. Extend the supported repertoire through existing owner contracts, including item placement and delivery, actor placement and encounter activation, faction and legal standing changes, location discovery, and supported world interactions such as changing a specific door's lock state. Owner-supported weather changes and scripted casts are extension candidates. Each operation has its own target, permissions, allowed exceptions and outcomes. The exact stock and mod command inventory remains open.
4. Keep required operations pending until the owner reports the required milestone. For transport, that milestone includes committed arrival and placement. An unavailable destination can lead to an authored alternative or recovery. A rejected request cannot produce the success branch. A technical fault preserves committed work for recovery.
5. Distinguish requested, pending, committed, rejected and recovery-required outcomes with stable operation identity. Duplicate requests or callbacks reuse the existing result. For training, present terms where applicable and commit from the declared choice or trigger. Reopening, dismissing or restoring presentation cannot dispatch the grant again. Training time uses TIME boundaries and can affect applicable quest clocks.

## Formulas, parameters and configuration

Authors declare the operation, target, trigger, required milestone, allowed exceptions and failure branch. Training amount, time and fatigue follow validated owner parameters. Weather scope and duration, spell attribution, legal effects and placement constraints follow their owners. The DFU training values are reference behavior. Exact native defaults remain open.

## Required data, inputs, outputs and events

Inputs include quest, task run, action, operation and session IDs, typed arguments, stable target references, allowed exceptions, attribution, and relevant owner state. Outputs include condition results, matched committed facts, operation results and supported pending or recovery records. Quest continuations consume the required committed outcome once.

## Cross-system interactions

QUEST-005/006 validate declarations. QUEST-009 owns task runs and effect retention, QUEST-010 handles time advancement, QUEST-011 owns finalization and recovery, and QUEST-018 owns prompts. MOVE/LOC/WORLD own arrival and world interactions. TIME owns weather and committed time. MAGIC owns casting and effects. LAW, CHAR, NPC, FACT and ITEM own their respective operations. QUEST-022 and SAVE coordinate restoration.

## Edge cases and failure conditions

- A spell is readied and canceled. A cast observer requiring a committed cast stays unsatisfied.
- An arrival is still loading or its target becomes invalid. The dependent branch waits for the required milestone or follows the reported failure.
- A training operation advances time and crosses a deadline. TIME and QUEST-010 reconcile the advance and expiry through their owner contracts.
- An operation faults after one step commits. Retain the settled result and recover the outstanding work. Stale callbacks from an earlier session cannot affect the restored quest.

## Save/load considerations

Persist supported pending operations with resolved target, origin and owner progress. Restore the relevant owner before resuming a dependent branch. Reuse committed operation records. Unsupported in-flight states use the applicable SAVE boundary or recovery.

## Technical constraints

Target Godot 4.7.2. Keep observations, owner mutation and presentation separate. Validate fixed references and supported exceptions before publication, then revalidate runtime context at commitment. Mod extensions use the same command and owner contracts.

## Acceptance criteria

1. Weather and cast observations advance only on matching conditions or committed events. A registered extension can request an additional owner-supported operation.
2. A scripted exception changes only its declared rule. Free training still applies authored time and fatigue, and scripted transport still validates arrival.
3. A pending required operation holds its dependent branch. Success advances once, and rejection or fault follows the applicable alternative or recovery.
4. Closing or restoring a popup cannot repeat training. Retry and load preserve committed effects and resume only supported outstanding work.

## Compatibility review and outstanding questions

The specification follows QUEST-006 owner-routed commands, QUEST-009 retained effects, QUEST-010 deadlines, QUEST-019 consequences and MOVE-026/027 transition boundaries. Exact stock command coverage, exception policies, training defaults, owner-specific commit boundaries and save schemas remain open.
