# ITEM-022 — Container, corpse and dropped item access

Approval status — **Approved and finalized v1 on 2026-11-10**

## Gameplay purpose and intended experience

Players can inspect, loot and deposit items through world inventories, recover items they dropped, and see why an attempted transfer failed. An accepted drop produces a reachable pile. Purchases, theft and quest acquisitions retain the identity and provenance of the items actually moved.

## Confirmed requirements

- **ITEM-022-D01.** Opening a container authorizes the permitted inspection only. Each take or deposit validates current target identity, reach, access, ownership, quest restrictions and capacity before committing.
- **ITEM-022-D02.** LAW and QUEST receive committed acquisition facts with item identity, quantity and provenance. Partial-stack acquisitions count. Rejected and cancelled transfers emit no successful-take event.
- **ITEM-022-D03.** Cleanup follows container type and policy. Persistent storage stays accessible when empty. Empty corpses follow COMBAT-021. Disposable dropped piles may disappear only once they are empty and have no active interaction or pending item, quest or recovery obligations.
- **ITEM-022-D04.** Drop confirmation validates reachable world placement and commits placement and transfer into world custody together. Failed placement leaves the item in inventory. Closing inventory only closes the interaction.
- **ITEM-022-D05.** An ordinary ground drop creates a new pile. An explicit drop onto an existing pile validates that pile's identity, access and admission rules before transfer.
- **ITEM-022-D06.** A pending take or deposit requires a fresh interaction if its original target moves out of reach, unloads or is replaced. The request stays bound to the original target and committed transfers stand.

- **ITEM-022-D07.** Nonempty dropped piles survive ordinary area unloads, revisits and save/load. Explicit location reset or cleanup must specify content disposition and honor protected items and outstanding obligations.
- **ITEM-022-D08.** Direct pickup applies only to the selected item or stack. Exact quantities are all-or-nothing. Explicit take-what-fits can leave a remainder. MOVE-022's arrow-only corpse shortcut retains its maximum-fitting behavior.
- **ITEM-022-D09.** Save container identity, placement, custody, contents and committed transfer facts. Uncommitted selections require fresh interaction after load. Committed transfers and outstanding LAW or QUEST follow-up persist.

The user confirmed D01–D09 on 2026-11-10 across three interviews. See the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Reference behavior

In the local DFU 1.1.1 snapshot, `Game/PlayerActivate.cs#ActivateLootContainer` routes shops, private containers and corpses separately. It can disable an empty corpse's loot collider. `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs` can stage dropped items until closing inventory, then create a world pile. Its shop theft close handler compares collection entry counts, which can miss a partial-stack removal. `Game/EnemyDeath.cs#CompleteDeath` supplies corpse inventory. These findings are from static source inspection.

## Approved dependencies

MOVE-022 governs interaction and property prompts, current access and the capacity-aware arrow-only corpse shortcut. COMBAT-020/021 govern corpse readiness, retained empty markers and cleanup obligations. ITEM-001, ITEM-005–008 and ITEM-020/021 govern custody, checked transfers, capacity and retained stock. LAW and QUEST own their responses to committed facts.

## Detailed behavior

### Inspection and access

Resolve the actual container, corpse or pile through the approved MOVE targeting and reach rules. Keep inspection, transfer authorization, ownership and legal consequences distinct. Apply MOVE-022 shop and private-property prompts. An Info request follows MOVE-022 and neither generates loot nor collects it. Expose corpse contents only after COMBAT-020/021 readiness. A legitimately empty corpse can still be inspected.

Every take or deposit revalidates the original target, current reach and access, actor and item custody, quest restrictions and destination capacity. If the target unloads, leaves reach or is replaced, require a fresh interaction for pending requests. The same applies after load. Completed transfers stand. A different container at the same position cannot inherit a pending request.

### Taking, depositing and dropping

Use ITEM-005–008 to validate the whole requested transfer, preserve item state and reconcile surviving stack identities. Direct pickup is scoped to the selected item or stack. An exact request either moves the requested amount or leaves both sides unchanged. Explicit take-what-fits leaves the remainder at the source. The approved arrow-only corpse shortcut takes the maximum eligible quantity that fits and leaves the remainder with feedback. Mixed corpses do not qualify for that shortcut.

Confirming an ordinary ground drop prepares a new pile with validated reachable placement, then commits world custody together with placement. Failed placement leaves the item in the original inventory. Explicit deposit into an existing pile targets that exact pile and follows its admission rules. Proximity alone does not group piles. Inventory closure releases the UI interaction. Gameplay changes commit through the explicit drop or transfer action.

Send committed acquisition facts to LAW and QUEST with actor, source, item identity or lineage, quantity, provenance and operation identity. Partial-stack acquisition counts regardless of entry count. Rejected or cancelled requests produce no successful-take event. LAW owns legality, including any separate inspection consequences under MOVE-022. QUEST owns reactions to acquisition. Retain completed handoffs and outstanding obligations so retries can resume required work without repeating the transfer or settled consequences.

### Container lifetime

Persistent storage stays accessible when empty, subject to ordinary access rules. COMBAT-021 governs retained empty corpse markers and authorized cleanup. A disposable empty dropped pile may disappear once there is no active interaction or pending item, quest or recovery obligation.

Nonempty dropped piles survive ordinary unloads, revisits and saves. An explicit location reset or cleanup policy may remove a pile only with a defined disposition for its contents and compatible handling of protected possessions and pending obligations. Scene unload alone preserves durable custody. Restoration must reconcile placement and scope using stable world identity.

## Formulas and parameters

Exact transfer quantities are positive whole units under ITEM-005–008. Take-what-fits uses the maximum eligible quantity permitted by the approved capacity calculation and other admission rules. This draft selects no new reach distance, placement radius, pile lifetime, theft chance or cleanup timer.

## Required data

Stable actor, container, location, item and operation identities. Container type, placement and ownership. Authoritative contents and provenance. Reach, readiness, access and capacity results. Committed quantity changes and resulting identities. Interaction state and outstanding LAW, QUEST, placement or cleanup obligations.

## Inputs, outputs and events

Inputs include inspect, take, deposit and drop requests, their explicit quantities and targets, and owner admission and placement results. Outputs include permitted inspection, committed transfer or drop, explicit rejection, remaining quantity and retained recovery facts. Only committed acquisitions emit successful-take facts. UI notifications may report those facts without reapplying them.

## Cross-system interactions

MOVE-022 governs prompts, routing and the arrow shortcut. COMBAT-020/021 own corpse readiness and corpse lifecycle. ITEM-001 and ITEM-005–008 govern identity, custody, quantity and capacity. ITEM-020/021 own generation and stock refresh. LOC and WORLD provide placement, streaming and reset policies. LAW and QUEST consume committed facts. SAVE and CORE own coherent restoration and session boundaries.

## Edge cases and failure conditions

- A closed shop, changed owner or out-of-reach container requires current authorization. An open window is insufficient.
- Failed placement or exact-quantity admission leaves custody and quantities unchanged.
- If a transfer commits before a downstream handoff fails, retain the completed move and resume only the outstanding handoff.
- A pile may be empty while a late quest addition or recovery obligation remains. Cleanup waits until the governing policy can resolve that obligation.
- Missing required placement, ownership or container data needs explicit recovery. An unrelated nearby pile cannot substitute for the original target.

## Configuration and balancing

Container policies may define admission, reset and cleanup within the approved ownership, capacity and protection rules. MOVE-022 retains its moddable arrow shortcut. Concrete placement bounds and nonempty-pile reset dispositions require an explicit owner profile.

## Save and load

Persist stable container identity, placement, world scope, ownership, custody, contents and committed transfer facts with outstanding follow-up. Restore without regenerating loot, replaying transfers, duplicating legal or quest effects, or inheriting an old selection. Resume supported committed recovery against its original identities. Coherent save boundaries and any supported partial-operation serialization follow CORE and SAVE.

## Technical constraints

Target Godot 4.7.2. Keep durable custody and container identity independent of scene nodes, UI windows and collection-entry counts. Publish a drop with its validated placement and custody through one checked operation. Integration needs a coherent failure boundary and recoverable committed facts.

## Acceptance criteria

1. Opening and Info perform only the approved inspection behavior. Every acquisition revalidates access and admission.
2. A rejected exact request preserves both collections. An explicit fitting pickup leaves its remainder. The arrow-only shortcut follows MOVE-022.
3. Partial-stack acquisition produces one committed fact with actual quantity and provenance. Cancellation emits no successful-take event.
4. A valid ground drop creates a reachable new pile. A failed drop leaves the item in inventory. Explicit deposits use the requested existing pile.
5. Target loss or load invalidates uncommitted interaction. Completed moves and outstanding follow-up survive.
6. Empty storage and corpses follow their own policies. Disposable empty piles with active interactions or pending obligations stay intact.
7. Nonempty piles persist across ordinary unloads and save/load. Authorized reset follows an explicit content disposition.

## Consistency review and open dependencies

Reviewed against MOVE-022, COMBAT-020/021 and ITEM-001, ITEM-005–008 and ITEM-020/021. No direct contradiction was identified. Concrete placement bounds, reset dispositions, and the shape of LAW/QUEST receipts and native recovery records remain open integration decisions.

## Approval

The user approved Draft v1 on 2026-11-10 with “I approve”. The specification is finalized as v1 under ITEM-022-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).
