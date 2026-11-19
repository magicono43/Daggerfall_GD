# QUEST-019 — Rewards and reputation changes

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-019-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-019-interview-decisions).

## Gameplay purpose and intended player experience

Let quest authors give several rewards for one milestone or outcome. A quest can pay gold, give multiple items and improve standing with a faction. Other branches can charge the player, reduce a reward, or change legal standing. If an item cannot be received immediately, the player can see what remains pending and how to claim it.

## Confirmed requirements

- A milestone or outcome can specify multiple rewards, including several items and gold together, plus faction or legal standing changes. Branches can also specify costs or penalties. Guild policies can award membership for initiation and declare how their effects combine with quest effects.
- Declare the target of each standing change. Supported targets include the issuing faction, a bound person's faction, a specified faction, or a declared jurisdiction. Supported DFU imports can retain execution-time current-region behavior.
- Preserve the exact item when delivery is blocked and use an authorized claim route. Required delivery holds finalization open. An authored post-quest claim can remain available after the outcome. Retry and reload preserve settled components and pending items.

See QUEST-019-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-019-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Actions/GetItem.cs` can add gold. `PayMoney.cs` deducts money and selects a branch based on payment. `GivePc.cs` delivers items and can delay some deliveries until qualifying outdoor town conditions. `ChangeReputeWith.cs` changes reputation with a quest person's faction. `LegalRepute.cs` changes legal standing in the current region and clamps the result. `Game/Guilds/GuildManager.cs#QuestMachine_OnQuestEnded` grants membership for successful named initiation quests. These findings come from static inspection of DFU. The original game's per-quest reward limits were not verified.

## Detailed rules and behaviors

1. A branch declares an ordered list of consequence entries. Entries can grant currency, grant one or more item units, require payment, adjust faction or legal standing, or request a supported guild membership award. Allow multiple entries of the same type. Use declared order and an independent commit record for each entry. A legitimate authored repeat uses a new run identity under QUEST-009.
2. Route mutations through ECON, ITEM, FACT or LAW. A payment checks funds and uses the declared branch if the player cannot pay. Standing changes use explicit target references and signed amounts. Resolve a contextual target at its declared boundary and retain the resolved ID for retry. A legacy current-region command captures the region when the action first executes. Missing required targets use explicit failure or recovery.
3. A guild consequence declares the qualifying quest and outcome and its relationship to authored effects. Reject ambiguous overlaps during validation where detectable. If two effects intentionally stack, each has its own identity. A required guild award participates in closing work before the outcome commits. A technical fault does not invoke an authored failure penalty by itself.
4. Resolve and retain any selected reward items before delivery. If admission or access fails, preserve the exact units and their state in authorized custody. Present the pending claim and its authorized recipient or destination. A required delivery must settle before finalization. An authored post-quest claim can outlive the active quest and uses its own retained authorization and custody record.
5. Report actual applied amounts, delivered items and pending claims separately. An interrupted bundle retains all committed effects and resumes its outstanding work only. Continue independent entries when an item is pending and wait on explicitly dependent entries. Required closing work still gates the final outcome under QUEST-011.

## Formulas and parameters

Currency amounts, item quantities, signed standing changes and claim policies are authored. ITEM validates quantity and admission. FACT and LAW apply their own bounds and propagation rules. Display the actual applied change where the owner exposes it. This feature adds no universal payout, reputation cap or reward scaling formula.

## Required data, inputs, outputs and events

Inputs include stable quest, branch, run and consequence IDs, ordered entries, amounts and item definitions, resolved recipients and standing targets, requiredness and dependencies, and claim and custody policy. Outputs include committed owner effects, payment unavailable, pending claim, and explicit failure or recovery. Report settled and outstanding work to quest finalization and presentation.

## Cross-system interactions

QUEST-009 owns task runs and effect retention. QUEST-010 supplies late outcomes. QUEST-011 gates terminal commitment on required closing work. QUEST-016 governs quest item identity and hand-in. QUEST-018 presents settled or pending outcomes. ECON owns currency, ITEM owns custody and admission, FACT owns faction standing and guild membership, and LAW owns jurisdiction and legal standing. QUEST-022 and SAVE restore pending consequences and receipts.

## Edge cases and failure conditions

- A reward bundle grants gold and two items. If the second item cannot be delivered, keep that item pending and preserve the committed gold and first item.
- A quest changes legal standing in its declared jurisdiction even when the player turns it in elsewhere. A legacy current-region effect keeps its captured target across retry.
- A queued item claim loses access to its destination. Preserve custody and use explicit recovery or an authored alternative.
- A duplicate callback, content refresh or reload cannot issue the same consequence again or reroll the retained item.

## Configuration and balancing

Authors configure multiple rewards and penalties per branch, effect order and dependencies, target and amount, and immediate or deferred delivery. Claim availability and any expiry require an authored policy compatible with outstanding obligations. Supported guild policies declare membership and any intentional overlap with quest effects.

## Save/load considerations

Persist consequence and run identities, resolved targets and items, settled owner outcomes, claim authorization and current custody, and supported unfinished work. Restore authoritative state before processing claims. A terminal quest can retain its post-quest claim record independently of active runtime state. Apply explicit compatibility or recovery for missing targets and preserve committed effects.

## Technical constraints

Target Godot 4.7.2. Separate authored consequence plans, owner mutations and presentation. Identify each effect and item delivery independently. Keep resolved reward and target facts stable across retries. Use explicit owner receipts for progress and finalization.

## Acceptance criteria

1. One branch can grant gold and multiple distinct items together and apply explicit standing changes. Two intentionally authored effects can stack once each.
2. A signed standing change reaches the declared faction or jurisdiction. A resumed action cannot redirect it after the player moves.
3. Insufficient funds follows the declared payment outcome. Failed item admission retains the exact pending item and leaves previously settled components intact.
4. Required delivery holds finalization open. An authorized deferred claim remains available after quest cleanup and can settle once.
5. Retry and load preserve delivered quantities, applied standing, membership and pending claims without duplicate effects.

## Compatibility review and outstanding questions

The specification follows QUEST-009 committed task work, QUEST-010 alternate outcomes, QUEST-011 finalization, and ITEM-023 custody and disposition. Exact reward claim custody, eligible destinations, guild overlap validation, standing propagation, and save schemas remain owner integration decisions.
