# SAVE-013 — Door and action state restore

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

A door or mechanism retains its saved state when loading the same visit. Supported motion resumes from the saved point. Completed changes, such as unlocking a door or triggering a linked effect, remain committed and occur only once.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SerializableStateManager.cs#RestoreActionDoorData` and `#RestoreActionObjectData` look up records by numeric LoadID and skip unmatched IDs. `SerializableActionDoor.cs` records rotation, lock value, action state, failed-pick skill, and available tween progress. `SerializableActionObject.cs` records position, rotation, action state, and available tween progress. Both restore components call `RestartTween` using the saved progress.

## Confirmed requirements inherited from approved specifications

- [LOC-017](../LOC/LOC-017.md) preserves applicable door locks, magical holds, failed-pick skill, first-use state, supported motion, and pending closure within a visit. Ordinary doors regain blocking only after full closure and a clearance check.
- [LOC-015](../LOC/LOC-015.md) and [LOC-020](../LOC/LOC-020.md) preserve supported action progress, timers, and committed outcomes without dispatching fresh triggers.
- [SAVE-004](SAVE-004.md) limits capture to supported states at settled boundaries. [SAVE-008](SAVE-008.md) governs identity matching, migration, and required failure.

## Detailed rules and behaviors

1. Capture authoritative door and mechanism records in the coherent SAVE-006 snapshot. Include settled state, active direction and progress where supported, applicable pending closure and link milestones, timers, and committed effect occurrences. If an in-flight action lacks a supported representation, apply SAVE-004 admission rules.
2. Resolve records through the selected layout, visit, and compatible stable placement identity. Validate motion, links, and relevant owner state against the resolved definition. Apply explicit migration when supported. Missing or ambiguous required bindings fail preflight where detectable. Apply declared optional recovery and SAVE-005 disclosure where eligible.
3. Under restore suspension, apply the saved state and rebuild the matching transform, collision, and interaction state. Restore a supporting mechanism before validating a player pose or attachment that depends on it under SAVE-012. For ordinary doors, open or moving states remain nonblocking. A closed door whose clearance is obstructed retains pending blocking until its owner validates clearance.
4. Reconstruct supported motion and action work at its saved milestone with the remaining applicable work and timer progress. Resume under normal gameplay eligibility. Preserve the original activation and committed effect identities. Reconstruction cannot repeat a lockpick, cost, damage, reward, message, or linked dispatch. A pending link executes only once when its declared milestone and conditions are met.
5. Native loading restores the saved visit. Dungeon reentry resets and ordinary location retention use LOC-013 and SAVE-009. Retiring an activation or replacing a session invalidates its pending callbacks. Keep gameplay suspended until required mechanism state and dependent placement are ready.

## Parameters, required data, and configuration

No new formulas apply. Required inputs include stable location, layout, visit, placement, and activation identities, applicable door and mechanism state, progress, timer and milestone data, and committed outcomes. Use approved motion, clearance, timing, and reset policies. Modded mechanisms use validated definitions and declare supported restore and migration behavior.

## Inputs, outputs, and events

Inputs include coherent owner records, prepared bindings, compatible definitions, and restoration scope. Outputs include reconstructed mechanism state, approved pending work, dependency readiness, or an actionable failure. Gameplay events arise only from legitimate work after restoration or from explicit owner reconciliation.

## Cross-system interactions

LOC owns mechanism rules and visits. MOVE owns collision, support, and placement. MAGIC owns magical holds and sources. QUEST and linked effect owners validate obligations and already committed outcomes. SAVE-005/007/008 coordinate preflight, compatibility, and recovery. CORE-013 governs final readiness.

## Edge cases and failure conditions

- A lift carrying the player restores at its saved progress before placement validates.
- A door saved during closure restores its pending state. Occupancy cannot cause blocking to appear inside the player or fire a link that still requires a blocking door.
- A modified layout with a missing required mechanism uses a validated migration or fails safely. An unrelated nearby object cannot assume its state.
- A completed link with a queued callback cannot repeat its effect after restoration or dungeon reset.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Store authoritative progress and owner records. Rebuild animation and collision from those records through restore-safe operations. A runtime tween, callback, or scene handle cannot stand in for saved progress. Keep the selected committed generation unchanged during load.

## Acceptance criteria

1. A compatible saved door restores its state and relevant lock history. A blocked closure stays pending and follows the approved clearance rule.
2. A supported moving mechanism resumes at the recorded progress and preserves its dependent placement and remaining work.
3. Restoration preserves completed effects and dispatches only eligible pending work. Repeated readiness or stale callbacks cannot repeat a committed effect.
4. Unsupported in-flight work is rejected at capture. A missing required binding uses approved migration or failure. Loading inside a visit creates no reset.

## Outstanding questions and approval

Concrete schemas, per-mechanism progress contracts, and verification fixtures remain follow-on work. The player-facing policies are inherited from approved specifications. See [SAVE-013-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-013-review-decision).
