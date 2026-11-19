# ITEM-025 — Inventory and equipment persistence

Approval status — **Approved and finalized v1 on 2026-11-10**

## Gameplay purpose and intended experience

Native saves preserve possessions, their current custody, and equipment arrangements across sessions. A restored player sees the same durable item state with any approved adjustments explained. Interrupted operations resume only the work still owed.

## Confirmed requirements

- **ITEM-025-D01.** Reconstruct item records and authoritative custody first, then resolve equipment, active lights, quest links and service references. Rebuild dependent protection and continuous effects after linking. Preserve saved preparation, suppression and other durable state.
- **ITEM-025-D02.** Missing or conflicting required bindings need approved migration, owner-specific recovery or load failure. Clear a binding only when an approved lifecycle accounts for its absence, such as expiry of the item providing a light. Preserve surviving items in their recorded custody.
- **ITEM-025-D03.** Validate migrated state before gameplay admission and preserve the original save for retry. Apply COMBAT-002 bow-layout reconciliation within its approved scope.

- **ITEM-025-D04.** Native saves cover every supported custodian, including unloaded containers, corpses, dropped piles and repair services. Save each item once in authoritative custody and represent equipment, active lights and quest links as references to that record.
- **ITEM-025-D05.** Save pending item operations only when their owner supports resuming outstanding steps from saved records. Preserve completed facts to prevent repeated charges, consumption or grants. Uncommitted UI selections follow existing reopen or fresh-interaction rules.
- **ITEM-025-D06.** Rebuild armor, effective load and continuous contributions from restored records, bindings and saved modifiers. Preserve durable fuel progress and remaining preparation. Rebuilding cached totals does not replay equip, use or break events.

- **ITEM-025-D07.** Capture a consistent view of custody across collections. Save at a coherent transfer boundary or use an owner-supported record of committed steps and outstanding work.
- **ITEM-025-D08.** Reconcile eligibility against restored game time before exposing inventories. Overdue summoned items become unusable and due repairs become ready once under their approved rules. Time outside the game grants no progress.
- **ITEM-025-D09.** Explain applied player-visible corrections and unresolved obligations that limit access. Use the existing load-failure flow when required state cannot be restored safely.

The user confirmed D01–D09 on 2026-11-10 across three interviews. See the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Reference behavior

In the local DFU 1.1.1 snapshot, `Game/Items/ItemCollection.cs#DeserializeItems` restores entries without merging and falls back to a base item if a saved custom class is unavailable. `Game/Items/ItemEquipTable.cs#DeserializeEquipTable` resolves slot UIDs against the restored collection and leaves unmatched slots empty. `Game/Serialization/SerializablePlayer.cs#RestoreSaveData` restores carried, wagon and other collections, resolves equipment and active light references, and rebuilds armor. Enemy and loot serializers also restore item records. These findings come from static source inspection.

## Approved dependencies

CORE-013 governs native save validation, suspension and recovery. ITEM-001 and ITEM-005 preserve item identity, authoritative custody and distinct stacks. ITEM-010–012 govern equipment and effect reconstruction. COMBAT-002 governs supported bow reconciliation. ITEM-014, ITEM-018 and ITEM-021–024 govern durable service, light and world item lifecycles.

## Detailed behavior

### Capture authoritative state

Capture all supported custodians, including unloaded containers, corpse and drop records, wagon storage and repair services. Store one authoritative record for each item in its actual custody. Equipment reservations, active lights, quest resources and service jobs refer to that record by identity. A multi-slot item remains one possession. Preserve saved IDs, quantities and distinct stack entries under ITEM-001/005.

Capture a consistent custody snapshot across both ends of each transfer. If a move is in progress, use a coherent boundary or the owner's supported recovery record. Such a record retains completed effects and remaining obligations so a load cannot repeat charges, consumption, grants or movement. Apply CORE and SAVE admission rules when the pending state lacks a supported representation. Uncommitted UI selections follow the owning interaction's existing reopen or fresh-interaction rules.

### Validate and link

Under CORE-013, validate native versions and supported migrations before replacing the current session where detectable. Preserve the original save for retry and validate migrated results before gameplay. Distinct item records sharing an identity fail compatibility validation under ITEM-001. Multiple valid references to one item are allowed. Preserve allocation guarantees for saved and retired identities within the save branch.

Reconstruct item records and authoritative custody before resolving equipment, light, quest and service references. Resolve references against stable item and owner identities with current definition and provider compatibility. Required missing or conflicting bindings need approved migration, owner-specific recovery or load failure. Clear a binding only when an approved lifecycle explains the absence, as with expiry of an active light. Surviving items retain their recorded custody unless an explicitly approved reconciliation changes it. Apply COMBAT-002 bow-layout reconciliation only within its approved scope. Apply ITEM-023 recovery to unresolved quest items.

### Reconcile lifecycle and rebuild

Restore the authoritative game clock and reconcile overdue eligibility before granting inventory access. Apply ITEM-024 to overdue summoned items, including unusability while cleanup remains pending. Apply ITEM-014 to due repairs, retaining service custody until collection and settling completion once. Retain original deadlines and accepted terms. Closed-game elapsed time supplies no progress.

After linking, rebuild armor, effective load and continuous contributions from restored item records, bindings and saved modifiers. Preserve preparation, suppression, condition, charges, fuel progress, knowledge and other durable owner state. Rebuild cached totals without replaying equip, use or break events. Apply owner recovery only to unfinished supported phases and reject stale callbacks from prior sessions.

### Admit and report

Keep gameplay suspended until required linking, reconciliation and derived-state rebuilding are coherent. Explain player-visible corrections, including a supported bow-layout adjustment, and any unresolved obligation that limits access. If required state cannot be restored safely, use CORE-013's load-failure flow. The owner of a recoverable obligation defines the affected scope and access restriction.

## Formulas and parameters

Use the restored game clock and the owning feature's saved deadlines and formulas. ITEM-024 governs exact expiry eligibility and ITEM-014 governs repair readiness. Derived values follow their existing owner formulas. No new balance constants are selected.

## Required data

Stable item, custodian, actor, slot, provider, quest, service and operation identities. Native record versions and required definition compatibility. Authoritative contents, quantities, provenance and item state. Durable bindings, timers and modifiers. Completed and pending operation facts, and applied migration or recovery results.

## Inputs, outputs and events

Inputs include coherent save capture, versioned native records, supported migration results, restored game time and owner reconciliation results. Outputs include validated item records, resolved bindings, rebuilt state, supported recovery obligations or a load failure. CORE owns the session-restored notification. Rebuilding views or caches emits no new item-use or acquisition commitment.

## Cross-system interactions

CORE-013 and SAVE own native load orchestration and admission. ITEM-001/005–007 govern identity, distinct stacks and custody. ITEM-008 and ITEM-010–012 govern load and equipment-derived state. COMBAT-002 supplies the approved bow adjustment. ITEM-014/018/021–024 govern repair, lights, stock, world items, quest links and expiry. MAGIC owns item effects and suppression. DATA and MOD supply compatible definitions and providers.

## Edge cases and failure conditions

- A save request crosses a custody change. Capture one coherent state or retain supported transfer progress with each item owned once.
- A saved slot points to a missing item or the wrong custodian. Use the approved lifecycle, migration or recovery path, or fail load.
- A due repair or expired item is in an unloaded custodian. Reconcile eligibility before exposure and settle outstanding work through the owner.
- A saved custom definition is unavailable. Required incompatibility uses explicit recovery or failure under existing identity and provider rules.
- A prior-session callback arrives after restore. It cannot apply work to a restored item with the same saved ID.

## Configuration and balancing

Supported providers may define versioned migrations and owner-specific recovery within approved identity, custody and load rules. Balance and lifecycle settings remain governed by their respective features.

## Save and load scope

This specification applies to native Godot saves under CORE-013. DFU and classic save formats remain outside that approved scope. Snapshot layout, native versioning details and owner recovery records are integration decisions.

## Technical constraints

Target Godot 4.7.2. Resolve records independently of scene presence, UI selection and runtime class names. Maintain a consistent capture boundary and a gated restore sequence. Validate required references and compatibility before exposing restored state.

## Acceptance criteria

1. Save/load preserves identity, custody, quantities and separate stacks across carried and unloaded inventories.
2. Capture during a move produces one coherent custody state or a supported record that resumes only unfinished steps.
3. Equipment, light, quest and service bindings resolve after item reconstruction. Invalid required bindings follow approved recovery or fail load.
4. Supported migrations preserve the original save and pass validation. The bow adjustment stays within COMBAT-002's scope.
5. Overdue summoned items are unusable before access and due repairs become ready once against restored game time.
6. Rebuilt armor, load and contributions reflect restored bindings and modifiers while fuel, preparation and suppression retain their saved state. Rebuilding causes no action replay.
7. Player-visible corrections and access-limiting obligations are explained. Unsafe required restoration follows the existing load-failure flow.

## Consistency review and open dependencies

Reviewed against CORE-013, COMBAT-002 and approved item identity, equipment and lifecycle specifications. No direct conflict was identified. Exact snapshot coordination, migration schemas and owner recovery records remain open integration work.

## Approval

The user approved Draft v1 on 2026-11-10 with “I approve”. The specification is finalized as v1 under ITEM-025-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).
