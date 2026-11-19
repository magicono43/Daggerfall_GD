# WORLD-007 — Loose objects and world cleanup

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Players can return for an ordinary outdoor drop before its cleanup deadline. Unloading an area preserves protected objects and committed changes. Revisiting an area restores eligible objects without duplicating pickups, enemies, rewards or quest progress.

## Confirmed requirements

- **WORLD-007-D01.** Ordinary player-dropped items outdoors survive streaming and native save/load until the item owner's tunable game-time cleanup rule expires them. Honor quest and other explicit protections.
- **WORLD-007-D02.** Object owners declare lifetime and scope. Durable and quest objects retain stable records and reconstruct live representations when needed. Short-lived objects follow owner rules. Mods can declare these policies, including for standalone exterior placements.
- **WORLD-007-D03.** Secure durable state before retiring its live instance. If this fails, defer retirement while safe. If safe continuation cannot be established, use existing recovery.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-007-interview-decisions) records these decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to `Assets/Scripts/`.

- `Terrain/StreamingWorld.cs#TrackLooseObject` tracks a scene object by pixel, with a stateful flag and optional parenting to the streaming target. `CollectLooseObjects` deactivates and schedules destruction of tracked objects on range or full cleanup regardless of the flag. `ClearStatefulLooseObjects` separately destroys flagged objects.
- `CleanupUntrackedObjects` destroys enemies and missiles under the streaming target on new game and start of load. Loot has a separate save and restoration path in `Game/Serialization/SaveLoadManager.cs` via `GetLootContainerData` and `RestoreLootContainerData`.

## Detailed rules and behaviors

1. Bind each live object to an owner and the applicable location, independent placement or exterior spatial scope. Pixel membership helps find residency candidates. Ownership, object identity and authorized cleanup determine which objects can retire. Multiple locations and standalone features can share a pixel under WORLD-006.
2. For an ordinary outdoor drop, retain the item identity, contents, pose and game-time cleanup state through unload and native save/load. The ITEM owner evaluates expiry using authoritative game time and current protections. An expired eligible record cannot reappear when revisited. Protected records follow their owner policy, including when a protection changes or ends.
3. Retire live instances only after resolving conflicting interaction and securing durable state in the authoritative owner record. A committed pickup transfers ownership once and removes or updates the world record accordingly. An unload, expiry or save overlapping that pickup must observe a coherent result. Pending callbacks must validate the active session, instance and operation before applying a change.
4. Reconstruct eligible durable objects after scope, geometry and owner-state validation. Publish one live representation per record where required. Retirement and reactivation alone grant no discovery, rewards or reset. Short-lived entities follow their owner rules, including existing projectile behavior during rebasing, same-location streaming and scope departure.
5. If durable state cannot be secured, keep the instance or its coherent owner state available under safe deferral. Where safe continuation fails, suspend affected activity and invoke CORE recovery. Destructive session replacement and teardown invalidate old callbacks. Preserve the committed state and failure facts required by SAVE and the owner.
6. Permit validated mod content to define ownership, lifetime, and scope for its objects. A change in content cannot silently delete a required durable record. Apply owner migration and recovery rules for unsupported definitions or policies.

## Relevant formulas, parameters and configuration

Ordinary drop expiry uses an ITEM-defined game-time cleanup policy. Duration, the precise time boundary and cleanup cadence remain open. Streaming distance, native loading and real-world time are independent of game-time expiry. Mod policies declare applicable lifetimes and protection behavior. Approved owner rules continue to govern protected property, quests and delivery objects.

## Required data

Stable durable object and definition IDs, owner and scope identifiers, authoritative pose and coordinate version, contents or owner payload, lifetime and relevant game-time state, protection state or references, and active session and live-instance identity. Transient entities need the owner data required for their supported lifetime.

## Inputs, outputs and events

- **Inputs** — Placement or spawn, committed interactions, game-time and protection changes, residency demand, native save/load and session teardown.
- **Outputs** — Active, deferred, retired or expired object state, authoritative durable records and explicit recovery on required failures.
- **Events** — Owners distinguish residency change from gameplay removal, ownership transfer and restoration. Publish committed outcomes once. Concrete API names remain open.

## Cross-system interactions

- **WORLD-001/002/004/005/006 and LOC** supply spatial context, coherent frames, readiness and residency. Terrain slot recycling does not define object identity.
- **ITEM, QUEST, NPC, COMBAT and MAGIC** own object state, protections and gameplay lifetimes. Apply approved property and rental protections where relevant.
- **TIME** supplies game-time advancement. **CORE/SAVE** coordinate coherent capture, scope replacement and recovery. **DATA/MOD** validate content and policy references.

## Edge cases and failure conditions

- Test drops and protected objects from adjacent towns in the same pixel. Unloading one scope leaves other scopes' records and live eligibility intact.
- Test expiry while unloaded, a time jump across expiry, and an applicable protection changing before reactivation. Use the owner's boundary rules.
- Test pickup, expiry, save and retirement contending for the same object. Prevent duplicate delivery and preserve committed ownership.
- Test missing mod definitions, rebase during retirement and a delayed callback after load. Apply validated compatibility or explicit recovery.

## Save/load considerations

Capture committed owner records, protection and cleanup state, and required world poses, including retained drops in unloaded areas. Restore eligibility against the saved game time and rehydrate only when applicable coverage is ready. Persist owner-governed transient state where already approved. Preserve coherent ownership across pickups and unloads. Save admission and any partial-operation recovery follow SAVE and the relevant owner.

## Technical constraints

Target Godot 4.7.2. Scene parenting and terrain slots are runtime details. Scope and stable record identity must remain usable across origin changes and reconstruction. Use a coherent owner-state boundary for retirement and snapshot capture. Exact registration, serialization and cleanup scheduling remain open.

## Acceptance criteria

1. An eligible ordinary outdoor drop survives unloading and native save/load before expiry. Eligible expiry removes it even if its area is unloaded. Approved protections take precedence.
2. Two locations or independent exterior placements in one pixel can retire independently. Mod-authored objects follow their validated declared policies.
3. Protected and durable objects rebuild from retained state with at most one eligible live instance. Reactivation alone produces no gameplay rewards or resets.
4. Overlapping pickup, unload and save preserve one committed ownership outcome. Failed state capture defers while safe or invokes recovery. Obsolete callbacks cannot alter the current session.
5. Projectile and other short-lived object cleanup respects owner rules during rebasing, streaming and scope departure.

## Outstanding questions

- ITEM must set the default outdoor drop duration, expiry boundary and how protection changes affect elapsed cleanup time.
- WORLD/LOC and MOD must define scope membership, supported policy authoring and behavior for moving objects crossing scope boundaries.
- SAVE and owner systems must settle snapshot admission, migration and recovery representation for unsafe retirement.
