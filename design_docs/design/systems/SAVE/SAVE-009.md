# SAVE-009 — Scene cache and permanent scenes

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Ordinary interior doors retain their open and lock state when the player steps outside and returns within the same map pixel. After leaving that pixel, an ordinary door can return to its authored or currently scheduled state. Property, items, quests, and other retained state follow their own approved rules.

## Existing Daggerfall Unity behavior

In DFU 1.1.1, `Assets/Scripts/Game/PlayerEnterExit.cs` caches building state on exit and restores it on entry. `SerializableStateManager.cs#CacheScene` records action doors and loot containers, with empty entries for enemies and general action objects. `SerializableActionDoor.cs` records changed doors by LoadID, including rotation, action state, lock value, and applicable motion progress. Restore consumes the cache entry. `Internal/PlayerGPS.cs` normally clears nonpermanent caches on a map-pixel change and has an exception for trips involving the owned ship. Partial cache clearing also strips corpse markers from retained scenes.

## Confirmed requirements

- **SAVE-009-D01.** Use the DFU-style same-map-pixel retention and crossing reset for ordinary interior door position and lock state, subject to approved owner rules.
- **SAVE-009-D02.** Configure retention by location context and kind of state. Support validated mod policies for different retention and reset behavior within approved protections.

## Detailed rules and behaviors

1. Retain ordinary interior door position and lock state by stable location and placement identity on departure. On reentry within the same map pixel, restore eligible state before the doors become interactive. An authoritative schedule or explicit owner change can supersede the retained value.
2. On a committed change to a different WORLD map pixel, expire ordinary door records subject to this policy. On a later visit, initialize those doors from authored defaults and current owner rules. A canceled or failed transition, coordinate rebase, or stream unload alone does not trigger expiry. Multiple buildings or towns in one pixel retain distinct records.
3. Determine retention and reset eligibility per state kind and scope. Property and active rental protections apply to the state covered by their owner contracts. Rental expiry releases its protection and ordinary cleanup rules then apply. The default door rule does not clear nonempty dropped piles, protected custody, quest obligations, corpse state, or other records governed by separate owner policies.
4. Preserve the approved dungeon reset boundary. A reset due after committed departure takes effect on successful reentry under LOC-013. Native load inside restores the recorded visit without triggering reentry. Failed destination preparation cannot consume a pending reset or dispose of retained state.
5. Support validated mod policies that choose retention and reset triggers by context and state kind. A policy must identify the applicable owner and preserve required references, custody, and outstanding obligations. Policies affecting other state kinds follow their owner-defined rules.

## Parameters, required data, and configuration

No gameplay formulas or default expiry timer apply. The stock ordinary interior door trigger is a committed change of WORLD map pixel. Required data includes stable location and placement IDs, captured door state, the retention policy and its scope, the saved geographic context, and any required reset or protection state. Exact mod policy schema remains a follow-on choice.

## Inputs, outputs, and events

Inputs include committed departure, geographic context change, scene retirement or readiness, owner state changes, and resolved retention policy. Outputs include retained records, expired ordinary records, applied state at readiness, and owner reset or recovery outcomes. Ignore stale work from retired sessions, locations, or transitions.

## Cross-system interactions

[WORLD-001](../WORLD/WORLD-001.md) owns committed map pixels. [WORLD-006](../WORLD/WORLD-006.md) keeps locations distinct when they share a pixel. [SAVE-008](SAVE-008.md) supplies durable identity and binding rules. [LOC-013](../LOC/LOC-013.md) and [LOC-020](../LOC/LOC-020.md) own dungeon reset and local restoration. [ITEM-022](../ITEM/ITEM-022.md), [COMBAT-021](../COMBAT/COMBAT-021.md), [ECON-013](../ECON/ECON-013.md), [ECON-015](../ECON/ECON-015.md), and [TIME-017](../TIME/TIME-017.md) own applicable custody, corpse, property, rental, and ship policies.

## Edge cases and failure conditions

- Going outside and returning within the same pixel preserves an eligible door's open and lock state. A current owner relock rule still applies.
- Crossing a pixel boundary and returning resets eligible ordinary doors. A shared pixel cannot cause one building to take another's state.
- Loading a save restores its recorded retention context without treating the move from the old session as a pixel crossing. A required unresolved record follows SAVE-008 and CORE-013 recovery.
- Permission to reset a door cannot delete a protected item or clear a quest obligation attached to the location.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Retain door state as owner records independent of scene nodes and reapply those records when compatible placement bindings are ready. This design can use the established world context and state records in Godot. Runtime behavior and performance remain to be verified during implementation. Include eligible retained records, geographic context, and required owner protection and reset facts in the native snapshot. Cache eviction cannot discard state still required by the active retention policy.

## Acceptance criteria

1. Open or unlock an ordinary interior door, exit, and reenter without changing pixels. The door restores its retained state unless a declared owner rule supersedes it.
2. Cross into a different pixel and return. The ordinary door uses its authored and current scheduled state. A rebase, ordinary stream unload, or canceled transition does not cause that reset.
3. Two buildings in the same pixel keep independent door records. Saving and loading preserves the applicable retention context and creates no reset by itself.
4. A validated mod changes a door policy in one supported context while unrelated states continue under their owner rules. Approved dungeon resets and item protections still apply.

## Outstanding questions and approval

The exact mod policy schema, additional stock reset rules for non-door state, and runtime verification remain follow-on work. See [SAVE-009-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-009-interview-decisions).
