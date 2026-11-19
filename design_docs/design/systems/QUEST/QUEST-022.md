# QUEST-022 — Quest runtime restoration

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-13 with “I approve”. See QUEST-022-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-022-interview-decisions).

## Gameplay purpose and intended player experience

Resume quests from their saved progress, including choices and transactions that were underway. Loading preserves the people, places, items and outcomes already resolved. If required content is incompatible, explain what needs recovery before replacing the current session.

## Confirmed requirements

- Restore against compatible versioned definitions and commands or explicit supported migrations. Block load when required quest state or obligations cannot be restored. An explicitly optional record can remain inactive through disclosed, owner-supported recovery when its obligations can be preserved safely.
- Restore authoritative state and required logical links before tasks can run. Valid unloaded targets can attach when their area becomes ready. Removed or incompatible targets need explicit recovery or a compatible mapping.
- Persist supported pending choices, starts, hand-ins, rewards and cleanup with stable identities and committed progress. Resume only outstanding work. When a coherent snapshot is temporarily unavailable, explain that the save is deferred until a safe boundary.

See QUEST-022-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-022-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/QuestMachine.cs#GetSaveData` exports quests and site links. `Quest.cs#RestoreSaveData` restores quest records, tasks and localized messages. `Task.cs#RestoreSaveData` reconstructs actions through constructors on saved implementation types. The machine adds a restored quest to its registry before legacy marker reassignment. An exception at that step can leave the quest registered despite a load warning. Stale links whose quests are absent are pruned later. These findings come from static inspection.

## Detailed rules and behaviors

1. Preflight the native save under CORE-013 before replacing the current session. Check required quest records, definition and command compatibility, owner references, and support for pending activity state. A stable definition ID identifies the quest. Compatibility also requires that the resolved definition and commands can interpret the saved state and bindings.
2. Apply explicit supported migrations to candidate records and validate their result before accepting them. Report blocking failures with affected quest and dependency identities and the reason. Retain optional inactive records with their original IDs, provenance and unresolved obligations. Continue only through disclosed owner recovery and only when those obligations are safe. Required state uses compatible restoration or blocks load.
3. Reconstruct authoritative quest and owner records before linking them for use. Resolve required logical bindings and reconcile custody, claims, outcomes and pending operations. A valid unloaded actor, corpse or marker retains its binding and waits for scene readiness. A missing target needs explicit mapping or recovery. Publish the active quest only after its required logical state is coherent. Withhold task dispatch and consequential interactions until the applicable session readiness gate opens.
4. Restore pending operations with their original identity, settled context, and completed owner receipts. A restored prompt uses its retained variant and choice IDs and revalidates at response. A pending start keeps its original context and queue order. If a hand-in transferred items before an objective update, resume the update. Pending rewards and cleanup retain exact custody and completed effects.
5. Rebuild derived state and supported UI from authoritative records. Restore quest clocks against saved world time and keep resolved randomness and placement. Restoration cannot rerun activation, emit a fresh start, consume another item, reroll an offer, or repeat an earned reveal or outcome.
6. Coordinate snapshot admission with SAVE. If an operation is between coherent boundaries, defer the save with a reason and complete it at the next eligible boundary. Revalidate the save request's session scope before committing a deferred save. An unsupported required state uses explicit SAVE failure or recovery.

## Required data, inputs, outputs and events

Inputs include the native save generation, content plan and version metadata, stable quest and action identities, task and clock state, flags and history, resource and site links, retained presentation context, and pending operation records and receipts. Outputs include validated restore, deferred scene binding, safely inactive optional record, or a diagnostic failure. Publish restored availability with restoration origin through the applicable owner contract.

## Cross-system interactions

CORE-007/013 and SAVE own session replacement, coherent saves and readiness. DATA-012, MOD and QUEST-005/006 supply compatible definitions, commands and migrations. QUEST-004 and QUEST-008–021 supply the durable state specified by each feature. NPC-024, ITEM-023, COMBAT-020/021 and LOC/WORLD restore actor, custody, corpse and placement references. QUEST-023 owns diagnostic presentation and recovery tooling.

## Edge cases and failure conditions

- A required custom command is missing. Preflight explains the dependency and leaves the running session intact if compatible recovery is unavailable.
- An unloaded dungeon retains a valid logical binding. Its scene representation attaches when ready. A removed marker cannot be recovered by choosing a nearby one implicitly.
- An optional inactive record retains unresolved protected items in authoritative custody. If that custody or another obligation cannot be preserved safely, the proposed optional recovery cannot proceed.
- A duplicate restoration callback or an old-session callback cannot reopen a committed choice, start a second quest or replay a delivery.

## Configuration and balancing

Owners declare version compatibility, supported migrations, required and optional state, and permitted resume or recovery policies. This feature adds no balance formulas, migration timeout or fixed snapshot interval.

## Save/load considerations

Save one coherent generation across quest and relevant owner state. Preserve active progress and durable history independently of disposable indexes and UI. Restore validated state in dependency order, attach ready representations, then allow supported pending work to resume. A supported migration preserves committed facts and outstanding obligations.

## Technical constraints

Target Godot 4.7.2. Use native versioned records and stable identifiers. Keep candidate validation, logical restoration, scene attachment and runtime publication separate. Reconstruct windows from owner state. Coordinate idempotent restore and resume with SAVE and operation owners.

## Acceptance criteria

1. Compatible definitions and commands resume progress. Supported migrations are validated before replacement. Incompatible required state blocks load with actionable context.
2. Optional inactive recovery is disclosed and preserves provenance and unresolved obligations. Valid unloaded targets attach later without blocking logical restoration.
3. Tasks cannot run before required logical bindings and session readiness are established. Failed binding cannot publish a partly restored active quest.
4. Supported pending prompts, starts, hand-ins, rewards and cleanup resume with their saved context. A completed transfer followed by a pending objective update resumes only the update.
5. A temporarily unsafe save boundary reports deferral and saves at a coherent boundary. Restore preserves clocks, resolved placements, one-time history and committed effects.

## Compatibility review and outstanding questions

The specification follows CORE-013 required-state preflight and owner-driven UI restore, DATA-012 compatibility, QUEST-006 command identity, NPC-024 unloaded bindings and ITEM-023 custody recovery. Exact save schema, requiredness declarations, migration format and supported snapshot boundaries remain open.
