# SAVE-014 — Enemy and loot reconstruction

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Loading preserves who is alive, which enemies were defeated, what was looted, and where remaining possessions are held. Returning to the saved visit preserves its established population and quest outcomes.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SerializableStateManager.cs#RestoreEnemyData` instantiates an enemy prefab for each saved enemy record, assigns its LoadID, restores its data, and raises an enemy-spawn event. `#RestoreLootContainerData` updates registered containers by LoadID and recreates missing containers flagged as custom drops, including dropped loot and corpse markers. Unmatched records without that flag are skipped in this path.

## Confirmed requirements inherited from approved specifications

- [SAVE-008](SAVE-008.md) defines stable bindings, explicit migration, and required identity validation.
- [LOC-020](../LOC/LOC-020.md) restores the saved visit and resolves quest claims before ordinary population. [LOC-013](../LOC/LOC-013.md) governs dungeon reset on successful reentry.
- [NPC-024](../NPC/NPC-024.md) preserves actor state and history. [CORE-020](../CORE/CORE-020.md) identifies restored actor availability by its restoration origin.
- [ITEM-022](../ITEM/ITEM-022.md), [ITEM-025](../ITEM/ITEM-025.md), and [COMBAT-021](../COMBAT/COMBAT-021.md) preserve custody, drops, corpses, and outstanding obligations through their owners.

## Detailed rules and behaviors

1. Capture authoritative actor, population and defeat records, active quest claims, and container and item custody at the coherent SAVE-006 boundary. Persist each item once in its actual custody. Preserve committed loot outcomes and any explicitly supported remaining work.
2. Resolve saved layout, visit and placement identities against active content. Apply saved quest claims, assignments and defeat records before resolving ordinary population. Bind an authored actor or container through its compatible placement identity or an explicit migration. If its compatible placement exists and the owner expects a live representation, the owner can build it with that identity.
3. Recreate a runtime-created enemy, dropped pile, or corpse when its durable record and applicable owner policy authorize reconstruction. Use the saved instance ID, compatible definition, placement, and state. A missing authored placement requires validation or migration under SAVE-008. It cannot be substituted with a nearby container or a generic drop. Keep valid offscreen records dormant until their scope needs a representation.
4. Restore actor state and bind quest, effect, equipment, and custody references in their owner-defined order. Preserve approved AI history, rebuild live navigation and observations, and apply the combat owner's rules for unfinished actions. Restore remaining container contents, provenance and access. Already-looted containers and defeated enemies cannot regenerate loot or rewards through reconstruction.
5. Publish applicable actor availability with restoration origin after required setup. Gate gameplay and interaction on required readiness under SAVE-012 and CORE-013. A required binding or placement failure uses approved recovery. Preserve eligible optional unresolved records inactive under the applicable owner policy and disclose player-visible consequences under SAVE-005.

## Parameters, required data, and configuration

No new formulas apply. Required data includes stable session, location, layout, visit, placement and instance references, actor and container definitions, saved pose and owner state, settled population and defeat facts, quest claims, item custody and committed outcomes. Validated mod definitions and migrations follow SAVE-007 and SAVE-008.

## Inputs, outputs, and events

Inputs include prepared owner records, resolved layout and geometry, compatible actor and container definitions, migrations, and ready binding results. Outputs include reconstructed or bound instances, retained inactive records where authorized, scoped restoration availability, and readiness or failure. Reconstruction emits no fresh encounter, acquisition, death, or reward event.

## Cross-system interactions

LOC and QUEST resolve placement and population claims. NPC owns actor state and AI reconstruction. COMBAT owns defeat, corpse readiness and unfinished combat behavior. ITEM owns item records, custody, and container lifecycle. MAGIC links supported effects. SAVE and CORE coordinate preflight, scope, and readiness.

## Edge cases and failure conditions

- A defeated enemy with outstanding corpse contents restores its defeat and eligible corpse records without reviving the enemy or rerolling loot.
- An authored container fully looted before saving stays empty. Its persistent identity remains subject to the owner's access and cleanup rules.
- A missing required quest actor or container placement needs explicit mapping or approved recovery, or the load fails safely. A dormant reference to a valid unloaded scope does not by itself indicate missing content.
- Duplicate IDs, wrong-scope callbacks, or retry after a partial build cannot create a second actor or duplicate custody.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Persist durable records independently of scene nodes. Validate detectable compatibility failures before replacing the session. Scope reconstruction to the current request and location. A native load restores the saved visit without consuming a pending reentry reset.

## Acceptance criteria

1. Loading restores a living enemy's saved identity and approved state, with restoration-origin availability and no fresh encounter rewards.
2. A defeated enemy remains defeated. Its retained corpse and a player's dropped pile restore once with the exact remaining custody. A looted authored container remains looted.
3. A quest claim takes precedence over ordinary population under LOC-020. A missing required authored placement triggers approved migration or failure.
4. Records for unloaded areas remain available for later binding. Partial reconstruction, stale callbacks, and retry cannot duplicate objects or items.

## Outstanding questions and approval

Exact record schemas and owner-specific reconstruction interfaces remain follow-on work. The player-facing rules are inherited from approved specifications. See [SAVE-014-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-014-review-decision).
