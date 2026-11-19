# SAVE-010 — Player snapshot and inventory references

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Loading returns the character with the same possessions, equipment, progression, vitals, and ongoing effects. The character is ready to play once the contributions from those records agree. Any approved player-visible recovery is disclosed before replacement.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 source, `Assets/Scripts/Game/Serialization/SerializablePlayer.cs#RestoreSaveData` restores character fields and carried, wagon, and other item collections, resolves the equipment table against the carried collection, and rebuilds armor from equipped items. `Game/Items/ItemCollection.cs#DeserializeItems` restores items without merging stacks and falls back to a base item when a saved custom class is unavailable. `Game/Items/ItemEquipTable.cs#DeserializeEquipTable` binds matching UIDs and leaves unmatched slots empty after clearing a valid-shaped table.

## Confirmed requirements inherited from approved specifications

- [CHAR-017](../CHAR/CHAR-017.md) preserves authoritative character and progression records and rebuilds derived values without replaying gameplay.
- [ITEM-025](../ITEM/ITEM-025.md) restores authoritative custody before linking equipment, active lights, quest resources, and service references. Missing required bindings use explicit migration, approved recovery, or failure.
- [MAGIC-010](../MAGIC/MAGIC-010.md) preserves effect timing, resolved power, suppression, and sources. Restore contributions before reconciling vital caps.
- [SAVE-006](SAVE-006.md), [SAVE-007](SAVE-007.md), and [SAVE-008](SAVE-008.md) establish coherent capture, versioned migration, durable identity, and required-reference validation.

## Detailed rules and behaviors

1. Capture authoritative character fields, current resource pools, durable progression and conditions, owned item records, equipment assignments, and supported committed or resumable activity state at the same boundary. Inventory links use durable item identities. Store each item once in its actual custody. Preserve distinct stacks, quantities, condition, and other owner-defined item state.
2. During preflight, validate or migrate required character fields, item definitions, unique item identities, custody, and required references where detectable. A reference must resolve to a compatible instance in eligible custody. A matching label or template does not establish identity. Clear a binding only through a declared owner lifecycle or approved recovery. Required failures preserve the current session when detected during preflight.
3. In the prepared replacement session, establish the saved clock and restore character baselines and authoritative custody. Link equipment, active lights, quest and service references, and item-dependent sources in dependency order. Preserve multi-slot reservations for one item and apply eligible owner reconciliation such as COMBAT-002 bow layout policy. Pending operations resume only their approved outstanding steps.
4. Restore required effects and their saved progress. Rebuild armor, effective load, modifiers, capabilities, and presentation from validated sources. Reconcile saved current vitals after the final applicable caps and contributions are available, under CHAR and MAGIC rules. Time-dependent item eligibility uses the restored clock.
5. Complete player readiness only after required state and references agree. Reconstruction does not replay equipment or use events, recast effects, reroll prior outcomes, repeat grants or charges, or confer healing from a transient cap change. Approved recovery uses SAVE-005 disclosure. A required failure after session replacement starts uses CORE-013 recovery.

## Parameters, required data, and configuration

This feature adds no formulas. Required data includes stable character, item, custodian, equipment-slot and effect-source references, authoritative character and item values, saved clock, and applicable activity and operation progress. Armor, effective load, modifier totals, and resource caps use their approved owner rules. Compatible mod schemas and migrations follow SAVE-007.

## Inputs, outputs, and events

Inputs include settled owner snapshots, selected generation, prepared compatibility results, and required binding and rebuild results. Outputs include coherent saved records, validated player state and readiness, approved recovery details, or a failure identifying the affected owner and reference. CORE-013 publishes Session Restored after overall readiness.

## Cross-system interactions

CHAR owns the player baseline and vitals. ITEM owns custody, equipment and item lifecycle. MAGIC owns ongoing effects and source constraints. TIME supplies the restored clock. QUEST and service owners resolve references to the same item records. LAW restores its durable state through its owner contract. UI consumes derived presentation after the required state is coherent.

## Edge cases and failure conditions

- Two identical items with different identities remain distinct and equipment binds to the recorded instance.
- A duplicate identity, conflicting custody, missing required mod item, or invalid required equipment binding triggers approved migration or recovery, or blocks restoration.
- A legitimately expired active-light or summoned-item source follows its approved lifecycle. Confirmed missing required data follows the failure policy.
- A save during a supported transfer preserves committed custody and outstanding steps without repeating charges, grants, or consumption.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Capture isolated owner data under SAVE-006 and rebuild runtime references after restoration. Keep gameplay suspended until required binding, derived contribution rebuilding, and vital reconciliation complete. Preflight must leave the source save unchanged.

## Acceptance criteria

1. A restored character retains recorded possessions, distinct stacks, custody, equipment assignments, and durable character state.
2. Equipment, active lights, and effects resolve to the exact compatible instances. Required reference failures receive actionable recovery or fail preflight with the current session intact.
3. Armor, effective load, modifiers, caps, and presentation rebuild from validated sources. Saved current vitals reconcile once under approved owner rules without free healing or duplicate effects.
4. Restore respects saved time and supported lifecycle progress. Repeated restore attempts do not duplicate items, costs, effects, or grants.

## Outstanding questions and approval

Exact native fields and per-owner migration and readiness details remain follow-on work. The approved owner specifications supply the player-facing policy. See [SAVE-010-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-010-review-decision).
