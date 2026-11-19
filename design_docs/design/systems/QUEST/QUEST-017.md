# QUEST-017 — Quest foes and death signals

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-017-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-017-interview-decisions).

## Gameplay purpose and intended player experience

Let quests track specific enemies or groups and recognize a qualifying death even if the objective appears later. Authors can distinguish ensuring that a target dies from requiring the player to kill it. Required evidence is available when the corpse first becomes lootable, and later quest actions can refer to the same remains.

## Confirmed requirements

- Record confirmed deaths while the actor is bound to the quest. By default an objective can use deaths recorded before it became active. Count each bound actor once. Authors can require a death after a specified milestone.
- Support explicit any-confirmed-death and player-credit conditions. Use authoritative combat attribution. Scripted removal, escape and unloading do not count as death.
- Retain the death record and actual corpse association while quest work needs them. Required original drops settle before first loot access. Authorized later grants use the same corpse. If it is gone, use an authored alternative or recover any outstanding obligation.

See QUEST-017-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-017-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Foe.cs` stores injury and kill state. Script actions create, place, restrain and remove foes. `Components/QuestResourceBehaviour.cs` processes first injury before recording death and increments the resource's kill count. `Actions/KilledFoe.cs` compares the recorded count to the required count, so a death can qualify before the condition first evaluates. These findings come from static inspection.

## Detailed rules and behaviors

1. Bind each participating actor to a stable quest instance and foe resource. A resource may track one actor or a group with distinct member identities. QUEST-013 governs authored placement and enemy-slot replacement. Scene detachment and reattachment preserve the binding and actor state.
2. Receive one authoritative death fact from COMBAT-020 with actor, death, source attribution and applicable quest binding. Process any applicable first-injury reaction before the killed-foe reaction, including when one hit both first injures and kills. Physical death is already definitive. Retain committed reactions and resume only outstanding work on retry.
3. Count qualifying distinct actor IDs against the authored positive whole-number target. By default, eligibility begins when the actor's binding commits. For a milestone-gated objective, use committed outcome order to require the death to follow the milestone, including when their world timestamps match. Evaluate any-confirmed-death or player-credit predicates against the recorded fact. A scripted action that actually commits a death follows the same attribution rules. Removal without a death fact, escape and unloading never increment the count.
4. Deaths with ineligible attribution can lead to an authored alternative or failure. A temporarily unavailable living foe retains its binding. Preserve the recorded death and any combat or loot outcomes independently of the objective's credit decision.
5. Submit required original death work through COMBAT-020 and COMBAT-021. Commit required item placement before initial loot readiness or retain the obligation through the approved recovery boundary. Keep the stable actor, death and corpse association for outstanding work. A later authorized grant targets that corpse using its own operation identity and preserves previously looted inventory. If the remains are permanently unavailable, use an authored alternative or explicit recovery for required work. Unloaded remains retain their association and use supported deferred work.

## Required data, inputs, outputs and events

Inputs include quest, resource, actor, death and corpse IDs, binding and milestone order, source attribution, objective credit policy and count, and original or later grant declarations. Outputs include recorded injury or death reactions, qualifying progress, original death acknowledgment, committed corpse grant, and explicit pending or failed recovery. COMBAT owns physical death and corpse readiness. QUEST owns objective credit and authored branches.

## Cross-system interactions

QUEST-013 owns placement and slot claims. QUEST-009 governs task execution and committed effects. QUEST-011 governs fault and terminal recovery. COMBAT-020 owns death finality, attribution and required acknowledgment. COMBAT-021 owns corpse readiness, custody and later grants. NPC-007 and LOC/WORLD support placement and streaming. ITEM-022/023 govern custody and quest-linked items. QUEST-022 and SAVE coordinate restoration.

## Edge cases and failure conditions

- A bound foe dies before its objective appears. The retained death qualifies when the objective activates unless an authored milestone or attribution requirement excludes it.
- An ally or hazard kills the target. An any-death objective can count it. A player-credit objective follows the recorded attribution and may need an alternative or failure branch.
- Several group members die in one encounter. Each qualifying actor contributes once, even if the same death fact is delivered again.
- A required drop fails to settle. Keep the same death and pending obligation under COMBAT recovery. A later grant cannot create a second corpse or substitute unrelated remains.

## Configuration and balancing

Authors configure foe roles, group size, required kill count, attribution mode, milestone, original drops, later grants and unavailable-target alternatives. COMBAT owns attribution mechanics, enemy balance and corpse lifetime. No new damage, loot or reward formula is introduced.

## Save/load considerations

Persist bound actor membership, qualifying death facts and attribution, milestone progress, counted actors, the actor–corpse association and original or later grant receipts. Restore owner state before resuming reactions. A restored dead actor stays dead. A resolved grant cannot replay or restore already looted items. Unresolved bindings and required grants follow explicit recovery.

## Technical constraints

Target Godot 4.7.2. Keep physical death, quest credit and corpse readiness distinct. Use stable identities and checked owner acknowledgments. Preserve committed order and pending work through stream-out, duplicate delivery and load.

## Acceptance criteria

1. A bound actor's early death counts when an eligible objective activates. An authored milestone can exclude earlier deaths. A group counts each qualifying actor once.
2. Any-death and player-credit objectives differ when attribution calls for it. Escape, removal and unloading produce no death credit.
3. On a lethal first hit, applicable injury work precedes killed-foe work while the actor remains physically dead. Retry does not repeat committed reactions.
4. Required original drops settle under the corpse readiness contract. A later grant uses the retained corpse and preserves prior loot state. Missing remains use the authored alternative or recovery.
5. Reload preserves actor bindings, progress, defeat, corpse links and committed grants without duplicate kills or loot.

## Compatibility review and outstanding questions

The specification follows QUEST-013 placement, QUEST-009 effect retention, and COMBAT-020/021 death and custody boundaries. Exact group membership lifecycle, attribution modes beyond the approved pair, death acknowledgment budgets, and recovery and save schemas remain open.
