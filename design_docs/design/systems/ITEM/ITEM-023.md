# ITEM-023 — Quest items and orphan cleanup

Approval status — **Approved and finalized v1 on 2026-11-10**

## Gameplay purpose and intended experience

Players can carry, use and hand in quest items according to the quest's rules. Permanent rewards retain the state of the possession they earned. Quest cleanup works across loaded and unloaded storage while preserving unrelated possessions and unresolved obligations.

## Confirmed requirements

- **ITEM-023-D01.** Link the physical item to a stable quest instance and resource while preserving its own identity and current custody. Authorized moves preserve the link. Drop, stash, sale and hand-in check the relevant quest permissions.
- **ITEM-023-D02.** An explicit quest action makes the existing item permanent in place. It ends quest-specific restrictions and quest cleanup eligibility while preserving identity, custody, condition, enchantments and learned properties.
- **ITEM-023-D03.** Quest-end cleanup requires an explicit disposition for each linked item. An unresolved quest or resource requires recovery with the item preserved in its current custody, including unloaded containers.
- **ITEM-023-D04.** Linked items stay separate from ordinary stacks by default. Voluntary drop, sale, ordinary consumption and unrelated storage require explicit quest permission. Authorized hand-ins and scripted moves use their declared rules.
- **ITEM-023-D05.** Hand-in validates the exact linked item, quantity and destination before moving or consuming it. Lookup is read-only. Record the committed hand-in once so retry cannot remove another item or advance the quest twice.
- **ITEM-023-D06.** Uncommitted item actions revalidate quest state and disposition before proceeding. Preserve completed moves and resolve outstanding work against current authoritative custody, including unloaded containers.

- **ITEM-023-D07.** Authorized use, drop and recovery report the actual item and location once the relevant action commits. Authored drop objectives distinguish qualifying placement from wagon deposits and other custody changes.
- **ITEM-023-D08.** Reclaim only the exact linked items covered by an accepted quest-end disposition. Preserve unrelated contents. Corpse or container removal follows its own cleanup policy.
- **ITEM-023-D09.** Persist quest links, permanent conversions and pending or completed hand-in and cleanup steps. Reconcile links after custody and quest state are restored. Resume outstanding work only. Keep unresolved items protected in their current custody.

The user confirmed D01–D09 on 2026-11-10 across three interviews. See the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Reference behavior

In the local DFU 1.1.1 snapshot, `Game/Items/DaggerfallUnityItem.cs#LinkQuestItem` stores a quest UID and resource symbol. `MakePermanent` clears them on the existing item. `Game/Questing/Item.cs#MakePermanent` also marks the quest resource permanent. `Game/Items/ItemCollection.cs#ExportQuestItems` returns matching references without removing items. `RemoveOrphanedItems` removes linked items whose quest is missing or tombstoned. The inspected `Game/Serialization/SaveLoadManager.cs` path invokes cleanup for carried, wagon and other player item collections. These findings come from static source inspection.

## Approved dependencies

ITEM-001 and ITEM-005–007 govern item identity, custody, stacking and checked movement. ITEM-015 governs explicit quest interception and use outcomes. ITEM-022 governs committed transfer facts and cleanup obligations. COMBAT-021 preserves corpse custody and outstanding quest grants. QUEST owns resource resolution and authorized disposition.

## Detailed behavior

### Link and permissions

Bind an existing item to the stable quest instance and authored resource identity. Keep item identity, custody and ownership independently resolvable. An authorized move carries the link with the item. Evaluate current quest rules and the applicable ITEM access, admission, protection and transfer rules at commitment. By default, keep linked items separate from ordinary stacks and require explicit quest permission for voluntary drop, sale, ordinary consumption and unrelated storage. Any supported stacking exception must preserve links, state and quantities under ITEM-005/006.

Lookup by quest and resource returns matching references without moving items or advancing objectives. Hand-in validates the selected item, link, requested quantity, actor and accepted destination or consumption policy. Record the actual disposition and committed quantity. When quest advancement needs separate settlement, retain the completed hand-in and resume only the outstanding quest work.

### Quest events and state changes

Use ITEM-015 for quest interception, including its explicit block, consume, pending and continuation outcomes. Report authorized committed use, drop and recovery with item identity, quest/resource link, actual location and operation identity. An authored drop objective evaluates the committed placement against its own target conditions. A wagon deposit is a custody change and does not by itself satisfy a world placement objective. Selection, preview and rejected actions emit no committed quest event.

Revalidate uncommitted actions if quest status, permissions or accepted disposition changes. Preserve completed moves and locate outstanding work through current authoritative custody, including unloaded containers. Retries use the original committed facts and cannot consume a replacement, emit a duplicate event or advance the quest twice.

### Permanent conversion and cleanup

An authorized permanent conversion updates the link and corresponding quest resource state on the existing item in place. Quest-specific restrictions and reclamation eligibility end. Identity, custody, quantity, condition, enchantments and valid learned properties persist. Other ownership, legal and gameplay restrictions still apply.

Quest-end reclamation requires an explicit accepted disposition for each affected linked item. Validate scope, current custody and outstanding hand-in or recovery work. Preserve unrelated items, even in the same container or corpse. Container removal is a separate ITEM-022 or COMBAT-021 operation. If a link cannot be resolved, retain the protected item in its current custody and report the recovery obligation. Scene unload and missing runtime references cannot authorize removal or conversion.

## Formulas and parameters

Quantities follow ITEM-005–007 and the authored hand-in requirement. Each committed action settles its declared quantity once. Quest policies define authorized actions, destinations and end dispositions. This draft selects no global cleanup timer or default quest-end disposition.

## Required data

Stable item, quest instance, resource, actor, custodian, location and operation identities. Active link and permanent-conversion state. Quest permission and accepted disposition. Requested and committed quantities, transfer or consumption facts, and pending quest, cleanup or recovery work.

## Inputs, outputs and events

Inputs include authorized link or permanent conversion, read-only lookup, use, hand-in, movement, quest-end disposition and restore. Outputs include a matched reference, committed action facts, permanent conversion, reclaimed item, rejection or explicit recovery. QUEST consumes committed facts using their operation identity.

## Cross-system interactions

QUEST owns resource resolution, authored permissions and objective outcomes. ITEM-001 and ITEM-005–007 own identity, quantities and movement. ITEM-013/014 govern breakage and repair compatibility. ITEM-015 routes quest use. ITEM-022 and COMBAT-021 preserve world or corpse custody and outstanding obligations. SAVE and CORE coordinate restoration and session boundaries.

## Edge cases and failure conditions

- Wrong item, quantity, destination or changed permission rejects the uncommitted action.
- A committed hand-in followed by a quest update failure retains the settled item disposition and pending quest work.
- An unloaded or unresolved owner requires recovery against stable identity. The item remains protected.
- A cleanup request that encounters a completed permanent conversion cannot reclaim the permanent item through its former link.
- Reclaiming a corpse item preserves unrelated loot, the corpse lifecycle and any outstanding late grants.

## Configuration and balancing

Authored quest policies define permitted actions, qualifying placement, hand-in disposition and quest-end disposition. Supported extensions preserve the same custody, validation and once-only guarantees.

## Save and load

Persist links, permanent conversions, authoritative custody, and pending and completed hand-in and cleanup facts. Restore item custody and quest state before link reconciliation. Resume only outstanding supported work and retain unresolved protected items. Apply existing CORE and SAVE rules to pending operations and stale session callbacks.

## Technical constraints

Target Godot 4.7.2. Resolve links by stable identities rather than display names, scene nodes or current inventory alone. Use committed operation records to coordinate item disposition and quest advancement. Exact persistence schema and recovery interfaces remain integration work.

## Acceptance criteria

1. Authorized movement preserves item identity and quest link. Default restricted actions require permission and ordinary stacks remain separate.
2. Lookup is read-only. Hand-in validates item, quantity and disposition and settles once across retries.
3. Committed use, drop and recovery report the actual item and location once. Ordinary storage cannot satisfy a placement objective merely by changing custody.
4. Permanent conversion preserves the same item and ends quest restrictions and reclamation eligibility.
5. Quest state changes invalidate incompatible uncommitted actions while preserving completed moves.
6. Reclamation affects only items covered by its accepted disposition and preserves unrelated contents and container obligations.
7. Restoration reconciles links after custody and quest state are available. Unresolved items stay protected and completed phases do not replay.

## Consistency review and open dependencies

Reviewed against ITEM-001, ITEM-005–007, ITEM-013–015, ITEM-022 and COMBAT-021. No direct conflict was identified. Concrete quest disposition profiles, unloaded-custody resolution, and native quest hand-in and cleanup records remain integration dependencies.

## Approval

The user approved Draft v1 on 2026-11-10 with “I approve”. The specification is finalized as v1 under ITEM-023-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).
