# ITEM-010 — Slot selection and hand conflicts

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Resolve equipment placement and conflicts without losing possessions, corrupting item state or repeating lifecycle transitions.

## Intended player experience

Equipping predictably replaces only permitted conflicting equipment. Failed requests leave possessions and powers intact. Repeated clicks and loading cannot duplicate effects or bypass preparation; custom layouts can extend the same rules.

## Confirmed requirements

- **ITEM-010-D01:** Validate the complete slot/hand-conflict/split/displacement plan before mutation. Rejected equip preserves equipment, quantities, powers and preparation state. Successful changes coordinate each required lifecycle transition once.
- **ITEM-010-D02:** Displaced items remain in the actor's inventory with identity, condition, contents and applicable recovery state preserved. No silent dropping, destruction or transfer elsewhere. Unsupported complete arrangements reject unchanged.
- **ITEM-010-D03:** Honor explicit requested slots only when compatible. Automatic paired slots prefer declared first open then second; both occupied targets declared first only with replacement permission. Slot ordering is explicit, stable and moddable, independent of UI position.
- **ITEM-010-D04:** Requests explicitly allow/forbid displacement across every affected slot, including indirect hand conflicts. Ordinary player equip may permit replacement; scripts declare intent.
- **ITEM-010-D05:** Equip exactly one unit using type-aware split rules and the actual actor's inventory. Reject before splitting if equip/state separation is unsupported. Ammunition is outside ordinary hand-slot equipping unless an explicit supported equipment profile permits it.
- **ITEM-010-D06:** Validated profiles support custom slots and multi-slot items with explicit compatibility/conflict/automatic-selection rules. Baseline hands retain COMBAT-002; extra hands, dual attacks and shield bash require compatible combat policies.
- **ITEM-010-D07:** Already equipped in the requested valid arrangement returns an explicit no-op without split, fresh preparation, power activation, sound or reward. Moving to another compatible slot is a genuine validated/timed change.
- **ITEM-010-D08:** Explicit unequip validates the item/all occupied slots and releases the whole arrangement once, retaining inventory custody. Owner restrictions/cleanup apply; rejection preserves arrangement. Multi-slot items cannot remain partially equipped.
- **ITEM-010-D09:** Save stable item-slot bindings, layout compatibility and required preparation/recovery. Load reconstructs occupancy/continuous powers without replaying equip costs/rewards/sounds/initial hand selection. Invalid layouts need explicit recovery; COMBAT-002 bow reconciliation remains supported.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Source relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`: `Game/Items/ItemEquipTable.cs`.

- `GetEquipSlot` checks item custom slot then category mappings. `GetFirstSlot` prefers first open, then second, else first.
- `EquipItem` resolves slot, may split one unit using global player inventory, clears conflicting hands for two-handed/shield cases, then checks occupied-slot replacement permission. Arrows are rejected on its weapon path. Some mutation thus precedes final refusal checks.
- Successful equip starts item powers; `UnequipItem(slot, list)` calls the slot overload and then StopEquippedItem again, creating duplicate cleanup dispatch. Runtime consequences depend on effect behavior.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Runtime/parity unverified; source unchanged.

## Existing approved constraints

COMBAT-002 owns hand selection/attack source, handedness/bow policies, preparation delays and supported load reconciliation; COMBAT-001 owns cancellation/retained commitments. ITEM-001–007 preserve identity/custody, custom contents/resources and checked split/transfer boundaries. MAGIC-016 owns once-only source lifecycle and no-replay reconstruction. ITEM-011/012 remain detailed restriction/lifecycle owner dependencies, not finalized by this interview.

## Detailed rules and behaviors

### Slot resolution and admission

Requests identify actor, inventory item, explicit slot or automatic placement, displacement permission and current session context. Resolve the actual actor's authoritative item/custody, never global player inventory. Validate supported layout, item slot/hand requirements, access and relevant owner restrictions before mutation. ITEM-011 supplies detailed equip eligibility; appearance alone adds no race/gender restriction under ITEM-003.

An explicit incompatible slot rejects rather than retargeting. Automatic paired placement prefers the declared first open slot, then second; if both occupied, declared-first replacement requires permission. Profile-defined ordering is stable and independent of UI sorting. Custom item slot declarations remain validated against the actor's layout rather than bypassing it.

Resolve the entire occupancy/conflict plan, including indirect hand conflicts and displaced multi-slot arrangements. Forbid-displacement protects every affected slot. Ordinary player equip may allow replacement; scripted requests explicitly declare intent. No hidden always-equip hand cleanup before permission validation.

### Identity, stacks and displaced items

Equip exactly one unit. Partial separation uses ITEM-006 type-aware state/resource allocation and fresh split identity, with the original remainder/references retained. Validate equip, separation and entry admission before splitting; unsupported special state rejects unchanged. Default ammunition does not equip into ordinary hand slots, with explicit compatible equipment-profile extensions supported.

Equipment is a binding to inventory-owned possessions, not another custody copy. Displaced items remain in the same actor inventory with identity, condition, actual contents, knowledge, provenance and applicable preparation/recovery preserved. No silent dropping, destruction or transfer. Unsupported complete arrangements reject without mutation; capacity loss from removing an effect follows ITEM-008 overweight retention rather than forced disposal.

### Hands and custom layouts

COMBAT-002 governs baseline one-/two-handed weapons, shields, bow setting, selected attack source and load reconciliation. Apply its full hand conflicts as part of the plan; equipment occupancy, selected attack hand and presentation are distinct. Shield equip's initial opposite-hand selection is a genuine transition only, not a refresh/load/no-op event. This feature creates no new dual attack or shield-bash baseline.

Support validated custom slots and multi-slot occupancy with explicit item compatibility, conflict and selection rules. Additional hands/dual-wield/bash require compatible COMBAT policies, timing, attribution and presentation before integrated support. Slot IDs/native layouts must not depend on classic array positions. Detailed baseline slot inventories and custom schemas remain validation dependencies.

### Commitment, repeated requests and unequip

Validate the complete split/displacement/binding and required owner-transition plan before mutation. Rejected equip leaves quantities, occupancy, powers and preparation state unchanged. Successful commitment coordinates actual outgoing/incoming transitions once, retaining explicit completion facts for safe retry. Concrete owner commit/recovery machinery must satisfy these guarantees; no generalized transaction framework is mandated.

Already in the requested valid arrangement is an explicit no-op: no fresh split, timer, power activation, sound or reward. Moving the item to another compatible slot is a real change, with normal validation and applicable timing. Deferred/repeated requests revalidate current item/layout/session and cannot repeat committed lifecycle work.

Explicit unequip releases all occupied slots of an item together after owner validation, retaining inventory custody. Never remove only one reservation of a multi-slot item. Rejection preserves the arrangement; restrictions cannot be bypassed by targeting another occupied slot. Owner-triggered break/expiry/form removal follows its approved lifecycle rather than inventing a universal voluntary-unequip veto.

COMBAT-001/002 retain attack cancellation, committed costs/projectiles and preparation provenance. MAGIC-016/ITEM-012 own continuous source transitions and once-only cleanup; removing one item cannot clear another source or recast an independently released effect. Coherent transitions must not replay powers or create transient modifier loss through duplicate cleanup. Exact nonweapon durations and callback ordering remain integration dependencies, not arbitrary weapon-table lookups.

## Relevant formulas and parameters

No new slot counts, equip costs, shield/nonweapon preparation durations or combat formulas are selected. Ordinary changed-hand preparation follows COMBAT-002: retain prior remaining delay and add applicable outgoing/incoming durations once. Valid no-op/load reconstruction adds no new delay; approved bow reconciliation preserves its special rules. Physical item quantity remains unchanged by equip except redistribution into a single-unit equipped entry plus remainder; occupancy does not duplicate weight.

## Required data

Stable actor/item/inventory/session/operation and slot/layout IDs; item slot/hand requirements; explicit/automatic selection order; replacement permission; complete occupancy/conflict/displacement/split plan; owner eligibility/cleanup results; retained contents/custody and preparation/recovery provenance; committed transition facts and layout compatibility version. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: authorized equip/unequip request, explicit slot/automatic choice, displacement intent, actor inventory/layout, owner restriction/timing/power context and native restore. Outputs: admitted committed arrangement, displaced identities, valid no-op or explicit rejection/recovery with relevant split/count/binding facts. Notifications report completed changes, never independently repeat lifecycle mutations. Concrete APIs/signals remain unselected.

## Cross-system interactions

ITEM-001–007 provide custody/identity/state and checked splitting/transfers; ITEM-008 retains overweight possessions on capacity loss. ITEM-011 owns detailed restrictions/UI and ITEM-012 armor/power lifecycle. COMBAT-001/002 own readiness/cancellation/hand selection and preparation. MAGIC-016/029 and other approved effects/forms retain source lifecycle and forced transition rules. DATA/MOD validate layouts/providers; UI/presentation reflect committed arrangements; SAVE/CORE validate/reconstruct before gameplay.

## Edge cases and failure conditions

- Invalid explicit slot, missing required provider/layout or forbidden displacement: reject before split/cleanup.
- Shield/two-handed conflict despite target slot open: replacement permission covers all indirect conflicts.
- Stack equip lacking safe state allocation or entry admission: original stack/equipment unchanged.
- Repeated equip/no-op: no effects, sounds, costs or timer reset.
- Multi-slot unequip/displacement: release complete arrangement, never partial occupancy.
- Source lost/changed during deferred request: revalidate identity/session, no silent substitution.
- Capacity effect removed: retain overweight inventory under ITEM-008, no automatic item disposal.
- Retry/load: no duplicate source contribution, cleanup, initial shield selection or delay bypass.

## Configuration and balancing options

Validated slot layouts, custom multi-slot items, stable automatic ordering and explicit replacement policies are supported. Hand behavior/preparation extensions remain COMBAT-002's supported contracts. No vanilla extra hands, dual attack, shield bash, new equip fee or automatic dropping is introduced. Provider registration timing cannot bypass layout validation.

## Save/load considerations

Persist stable item-slot bindings, required layout compatibility and preparation/recovery facts. Validate inventory identity, occupancy/conflicts and required providers before readiness. Reconstruct occupancy and continuous sources without equip rewards/costs/sounds, initial hand selection or attack replay. Preserve selected hand/delays under COMBAT-002.

Invalid layouts require explicit migration/recovery without item loss or arbitrary slot swapping. COMBAT-002's supported bow-setting reconciliation preserves items/recovery, selects relocated bow hand and adds no new delay; it is not a universal conflict-repair rule. Pending/partial operation boundaries follow ITEM-002/CORE/SAVE contracts, retaining completed facts and rejecting old-session callbacks. Exact native schemas and fixtures remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate layout planning, authoritative binding, inventory custody, combat readiness, power lifecycle and presentation. No implicit global-player split, destructive preliminary hand cleanup or duplicate lifecycle dispatch. Stable IDs replace dependence on engine handles/class names/classic slot indexes. No implementation/coding tasks authorized; reference source unchanged.

## Acceptance criteria

1. Explicit compatible placement and stable paired automatic order resolve predictably; incompatible requests do not retarget.
2. Replacement permission covers every direct/indirect conflict; rejected plans leave quantities/equipment/powers/preparation unchanged.
3. Stack equip separates exactly one unit in the correct actor inventory with complete state/resource preservation or rejects before mutation.
4. Displaced items retain inventory custody/identity/contents/recovery without drop/destruction/transfer or duplicate weight.
5. Baseline hand/selection/preparation rules remain COMBAT-002 compliant; custom/multi-slot layouts require complete validated policies.
6. Valid repeated equip is a no-op without effects/sounds/rewards/timer changes; slot relocation follows genuine transition rules.
7. Unequip/displacement releases all slots of a multi-slot item once, with required owner restrictions/cleanup and no partial arrangement.
8. Lifecycle/source effects and combat transitions commit once, preserving independent contributions and committed action facts.
9. Restore validates bindings/layouts, preserves recovery and reconstructs without replay; bow reconciliation follows its approved exception without item loss.

## Contradiction review

Reviewed against approved ITEM-001–009, COMBAT-001/002 and MAGIC-016, with ITEM-011/012 analysis boundaries. No direct contradiction identified. Inventory-owned equipment explains displaced custody without double-counting load. Whole-plan rejection prevents reference source pre-refusal mutation. Custom layouts do not introduce unapproved extra-hand combat. Once-only source reconstruction preserves existing spell lifetimes, timing and bow reconciliation; no-op does not repeat shield initial selection. Future equip restrictions/lifecycle features remain owner dependencies.

## Outstanding questions

No further blocking player-policy choice identified. Before implementation is complete: baseline/custom slot and occupancy schemas; item restrictions and full conflict plans; type-aware split/admission; owner transition/once-only recovery receipts; nonweapon preparation and displaced recovery provenance; native layout migration/bow reconciliation and lifecycle fixtures. These cannot waive item preservation, all-slot replacement permission, no-op safety or once-only source transitions.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-010-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented slot/occupancy schemas, restrictions/conflict plans, split/admission, owner transition/recovery receipts, preparation provenance and native layout migration/reconciliation dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
