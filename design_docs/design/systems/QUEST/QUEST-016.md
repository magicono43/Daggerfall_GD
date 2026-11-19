# QUEST-016 — Quest item state and ownership

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-016-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-016-interview-decisions).

## Gameplay purpose and intended player experience

Let players retrieve, carry, use and deliver quest objects while preserving the identity of unique items. A sealed letter can require the original object, while a request for flowers can accept several kinds. Players can review which qualifying ordinary items they will give away. Lost items can lead to recovery, replacement, a different objective or authored failure.

## Confirmed requirements

- Possession checks default to carried items, including equipped items. Authors can include accessible wagon or storage custody explicitly. Checks are read-only, and hand-in revalidates actual access and transfer eligibility.
- Unique quest objects require the exact linked instance. For ordinary exact-definition or category requests, let the player review and select qualifying units. Default to full delivery, with partial delivery available when authored. An item can satisfy several read-only checks but each unit can be transferred or consumed only once.
- Distinguish recoverable custody from confirmed destruction or unavailability. Support authored retrieval, replacement, alternative objectives and failure. Unloaded or unresolved items retain protection and follow ITEM-023 recovery.

See QUEST-016-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-016-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Item.cs` links a concrete item to the quest UID and resource symbol, supports permanent conversion, and saves the item and flags including use watching, drop permission, player drop and permanence. Script actions place, give, take and check items. `Actions/TotingItemAndClickedNpc.cs` checks the linked item in conjunction with a click on the specified person. These findings come from static inspection.

## Detailed rules and behaviors

1. Declare the match contract. A linked-resource objective resolves its exact physical item identity under ITEM-023. An ordinary objective matches a stable definition ID or validated category or tag and counts qualifying units under QUEST-006. Matching an ordinary item leaves its existing identity and permissions in force. It does not create a quest link.
2. Evaluate possession using current authoritative custody. Count carried items, including equipped items, by default. Include additional wagon or storage scopes only as authored and when accessible under ITEM rules. Count each unit once per check. A check does not reserve, move, consume or grant an item. Presence in a qualifying scope is separate from permission to deliver, use or drop it.
3. For a hand-in, resolve the authorized recipient and authored destination or consumption policy. Use the exact instance for a unique requirement. For ordinary matches, show the proposed item units and quantities and let the player choose among qualifying alternatives before committing. At confirmation, revalidate the selected units, quantity, current custody, transfer permissions and objective and recipient state. Return stale selections for fresh review without substituting other items.
4. Require the full outstanding quantity by default. Commit the entire full hand-in together, including when it spans several stacks. Authored partial hand-ins can commit eligible amounts up to the outstanding quantity. Retain the settled quantities and advance completion when the authored total is met. A read-only check can qualify the same unit for two objectives. Once transferred or consumed, that unit cannot satisfy a second delivery from its previous custody. Concurrent attempts revalidate against current custody.
5. Use committed ITEM outcomes for quest progress. Transfer or consumption records identify the actual units, quantities and destination. If quest advancement needs recovery after delivery commits, retain the delivery and resume only the outstanding progress update. Use ITEM-015/023 for use, drop and recovery. A custody change satisfies a drop objective only if it meets the authored placement rule. Permanent conversion and quest-end dispositions follow ITEM-023.
6. If a required item is missing from eligible custody, determine what the owners know. Known recoverable custody can support retrieval. Unloaded storage or an unresolved link preserves the protected item and uses recovery. Confirmed destruction or authored unavailability can lead to a replacement, alternate objective or failure. A replacement is an explicit operation with a new item identity and an updated role binding. Only the currently bound item qualifies for the unique role.

## Required data, inputs, outputs and events

Inputs include stable quest, objective, resource, item, actor and operation IDs, match selector and quantity, eligible custody, actual selected units, recipient and disposition, partial progress, and loss policy. Outputs include a possession result, reviewed hand-in proposal, committed delivery facts, outstanding quantity, or explicit rejection or recovery. Only committed owner events drive consequential objective progress.

## Cross-system interactions

QUEST-006 defines matching conditions and separates checks from hand-in. QUEST-009 consumes committed facts once, QUEST-010 governs deadline and late delivery, and QUEST-011 governs finalization. ITEM-005–007 govern quantity and transfers, ITEM-013 governs destruction compatibility, ITEM-015 governs use, and ITEM-022/023 govern custody, linked item policy and cleanup. MOVE-022 governs world pickup, and QUEST-015 and MOVE-023 govern recipient interaction. QUEST-022 and SAVE coordinate restoration.

## Edge cases and failure conditions

- An equipped item can satisfy possession while still requiring owner approval for removal. A stored item outside the authored accessible scope cannot qualify for immediate delivery.
- A selected stack changes before confirmation. Revalidate the actual selection and report unavailability if the required units are gone. No settled quantity is credited for a rejected delivery.
- An ordinary request for three flowers can accept mixed qualifying types. An exact linked letter cannot be replaced by another item of the same definition through ordinary matching.
- A completed delivery followed by an objective-update fault preserves the committed transfer and pending advancement. Reopening or loading cannot take the items again.
- A missing runtime object in an unloaded area does not establish destruction. Apply the owner's custody and recovery rules. A legitimately destroyed item can trigger an authored outcome.

## Configuration and balancing

Authors configure linked or ordinary matches, positive quantities, accessible custody scopes, destinations, partial delivery, qualifying use and placement, and loss outcomes. Quest rules can allow recovery or alternatives without making a replacement automatic. ITEM owners retain access, movement, protection and disposition rules.

## Save/load considerations

Persist role bindings, accepted deliveries and remaining quantities, supported pending progress and recovery, and committed replacement state. Restore authoritative custody and item links before resolving outstanding work. Revalidate uncommitted proposals through their owners. Preserve completed transfers and do not duplicate credit on restore.

## Technical constraints

Target Godot 4.7.2. Use stable item, custody and operation identities. Separate read-only matching, player confirmation, ITEM mutation and quest progress. Preserve coherent quantity and custody facts when a delivery or recovery is interrupted.

## Acceptance criteria

1. Carried and equipped items qualify by default. Accessible wagon or storage custody qualifies only when authored. Queries never change custody or progress.
2. A unique objective delivers its exact instance. An ordinary quantity objective allows review and selection of eligible units. A stale confirmation cannot take substitute items.
3. Full delivery commits the outstanding quantity or leaves it unsettled. Authorized partial deliveries accumulate committed quantities. Competing deliveries cannot consume a unit twice.
4. Known recoverable custody, unloaded or unresolved custody, and confirmed loss produce distinct outcomes. An authorized replacement preserves a single valid identity for the unique role.
5. Duplicate callbacks, faults and reload preserve committed deliveries and resume only unfinished quest work.

## Compatibility review and outstanding questions

The specification follows ITEM-023 linked item protections and dispositions, QUEST-006 exact and category matching, and QUEST-009 and QUEST-011 committed progress and recovery. Exact accessible storage rules, stack allocation and UI ordering, transfer commit mechanics and save schemas remain open.
