# SAVE-008 — Stateful object registration and identity

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Saved changes return to the intended objects when a location is rebuilt or a save is loaded. A looted chest stays looted and a quest reference continues to identify its target even if scene construction order or compatible content changes.

## Existing Daggerfall Unity behavior

In DFU 1.1.1, `Assets/Scripts/Game/Serialization/SerializableStateManager.cs#RegisterStatefulGameObject` registers by category and numeric LoadID, rejects zero, and logs duplicates while leaving the second registration out. `SerializableActionDoor.cs` and `SerializableEnemy.cs` can increment colliding IDs. Restoration matches doors and action objects by ID and recreates enemies using saved IDs. These findings come from static source inspection.

## Confirmed requirements

- **SAVE-008-D01.** Use stable scoped placement IDs for authored stateful objects and durable instance IDs for persistent objects created during play. Carry saved state forward through a matching identity or an explicit migration.
- **SAVE-008-D02.** Block the affected save or load when required identity is ambiguous or unresolved. An optional record may be omitted only under an approved owner recovery policy. Disclose player-visible recovery before load replacement under SAVE-005.

## Detailed rules and behaviors

1. Authored placement identity uses the owner's declared scope, including resolved layout and visit identity where applicable under LOC-020. A compatible update that moves or renames the same placement preserves its ID. If a replacement needs to inherit old state, its owner supplies an explicit migration. Position, display name, and scene registration order cannot select a saved record.
2. Allocate a durable instance identity when an object created during play becomes persistent. Keep it through capture, reconstruction, and supported ownership or location changes. Preserve definition keys separately so the owner can find the correct definition when reconstructing the instance. Do not reissue an identity to an unrelated instance while durable references can still resolve to it.
3. Bind registered runtime objects to durable identities within the relevant session and scope. Register when ready to receive applicable state. Remove only the matching binding on retirement. Reject late callbacks from retired scopes. Unloading an object from a scene does not itself delete its saved state.
4. Validate uniqueness in the applicable scope and check object kind and owner compatibility before applying records. Resolve required references before publishing restoration readiness. Owners distinguish matching an authored object, reconstructing a persistent instance, and applying a recorded removal. Restore binding and reconstruction do not replay a fresh spawn or its gameplay consequences.
5. Reject missing, invalid, incompatible, or duplicate identities when they affect required state. An optional record is eligible for omission only under a declared owner policy and when required references and outcomes remain valid. Report the relevant reason. On load, perform detectable checks during preflight and use CORE-013 recovery if a required binding fails after replacement starts. On save, leave the previous committed generation usable under SAVE-006.

## Parameters, required data, and configuration

No gameplay formulas apply. Required data includes durable identity and its declared scope, record category and owner, applicable definition keys, required references, and schema or migration context. Runtime bindings carry enough scope and lifetime information to validate registration and retirement. Owners declare required records and supported optional recovery. The exact ID encoding and allocation mechanism remain technical choices.

## Inputs, outputs, and events

Inputs include registration and retirement requests, owner save records, resolved layouts and definitions, and explicit migrations. Outputs include a validated binding, a diagnostic on an identity conflict, a matching or reconstruction result, or a required failure or declared optional recovery result. Emit restoration readiness only when required bindings and references are resolved.

## Cross-system interactions

[LOC-020](../LOC/LOC-020.md) supplies resolved layout and visit scope. [SAVE-007](SAVE-007.md) coordinates migrations and preserves durable references. [SAVE-006](SAVE-006.md) owns coherent publication. [SAVE-005](SAVE-005.md) and [CORE-013](../CORE/CORE-013.md) own preflight, recovery disclosure, and native restore readiness. ITEM, NPC, QUEST, and location owners define object lifetime and which references are required. DATA and MOD supply definition and package identity.

## Edge cases and failure conditions

- Two locations may use the same local placement ID if their declared scopes differ. Competing bindings for one required identity within a scope fail instead of choosing a winner.
- A stale deregistration cannot remove a newer binding. A required reference cannot be satisfied by an object from a previous session or a different visit.
- If content removes a referenced placement, use a validated migration or applicable owner recovery. Required unresolved state blocks load.
- An optional record referenced by required gameplay state cannot be omitted when doing so would leave the required reference unresolved.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Persist durable IDs and owner records. Rebuild runtime bindings during restoration and coordinate readiness with the owners. Preserve state across scene retirement where the owner requires persistence. Validate migrations and restored bindings before releasing gameplay.

## Acceptance criteria

1. Reordering scene construction or renaming or moving an authored object with the same compatible ID preserves its correct saved state.
2. A persistent object created during play restores with its durable ID and resolves supported references. A fresh spawn's effects are not replayed on reconstruction.
3. Duplicate or unresolved required identities prevent capture or fail detectable preflight while preserving the previous committed save or current session as applicable.
4. An optional omission follows a declared policy, keeps required references valid, and discloses player-visible consequences before replacement.
5. An explicit migration carries state to its validated target. Retirement and stale callbacks cannot remove or change another scope's binding.

## Outstanding questions and approval

Exact ID formats, scope composition, registration APIs, and owner-specific migration and recovery rules remain follow-on decisions. See [SAVE-008-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-008-interview-decisions).
