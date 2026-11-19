# SAVE-012 — World placement and registration wait

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

The player returns to the saved location and movement context with the required world state in place. Loading coverage stays up until the reconstructed session is ready.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#LoadGame` calls `PlayerEnterExit.cs#RestorePositionHelper`, restores travel map and climbing state, covers the view, and waits while `IsRespawning` is true. It then yields one additional frame to allow registration before applying saved state. The sampled wait has no local timeout. These are static findings.

## Confirmed requirements inherited from approved specifications

- [SAVE-011](SAVE-011.md) establishes the saved world and early owner context for reconstruction.
- [SAVE-008](SAVE-008.md) requires valid durable bindings and resolved required references.
- [MOVE-027](../MOVE/MOVE-027.md) defines contextual native placement, permitted bounded corrections, and explicit placement outcomes.
- [LOC-020](../LOC/LOC-020.md) requires the selected layout, required local state, and placement to agree. [CORE-013](../CORE/CORE-013.md) keeps gameplay suspended until overall restoration is ready.

## Detailed rules and behaviors

1. Scope reconstruction to the active load request, replacement session, and saved destination and visit. Build the required location layout and geometry from prepared SAVE-011 context. Wait for explicit owner results that the relevant geometry and collision are ready for placement and restoration.
2. Establish required object identities and bindings as their owners become ready. Match authored records and reconstruct persistent instances under SAVE-008. Use owner-defined dependencies so required supporting mechanisms are restored before final placement validation, and quest claims are applied before ordinary population where LOC-020 requires it. Registration may arrive in any order consistent with those dependencies.
3. Request native placement using the saved pose, orientation, and supported movement context. Apply MOVE-027 validation and permitted local correction. Preserve required motion, posture, and contextual relationships. Report corrected placement with its provenance. If valid placement cannot be established, fail through CORE recovery.
4. Keep simulation and gameplay input suspended while required bindings, local state, placement, and other restoration work are outstanding. Advance phases on explicit readiness or failure results. Frame count and elapsed time alone cannot establish readiness. Provide responsive phase feedback and use the CORE-007 cancellation boundary and failure policy.
5. Once location and placement dependencies are settled, pass their confirmed results to the remaining restoration phases. CORE-013 governs reveal and Session Restored after overall readiness. Ignore results from obsolete requests or scopes.

## Parameters, required data, and configuration

No new gameplay formulas, correction distances, or generic timeout apply. Required data includes the load and session identity, saved location, layout and visit, pose and movement context, required geometry and binding dependencies, correction policy, and owner phase results. Placement parameters belong to MOVE and LOC.

## Inputs, outputs, and events

Inputs include prepared saved context, geometry and collision readiness, registration and binding outcomes, supporting state results, and the movement placement result. Outputs include scoped reconstruction phase progress, validated placement or corrected placement, and explicit readiness or failure for dependent restore phases.

## Cross-system interactions

WORLD and LOC build the destination from SAVE-011 context. SAVE-008 validates identities. MOVE-027 validates placement against prepared collision and applicable owner state. QUEST and local state owners resolve claims and population. CORE-005/007/013 coordinate suspension, cleanup, terminal outcomes, and reveal.

## Edge cases and failure conditions

- Geometry may be ready while a required platform or its saved state is still pending. Wait for the applicable dependency before finalizing the pose.
- An airborne or swimming pose uses its own MOVE-027 conditions. A missing floor alone cannot force a correction.
- Late, duplicate, or wrong-scope registration cannot satisfy the active request. A confirmed required failure behind the replacement boundary uses CORE recovery.
- A long build keeps responsive phase feedback. Only actual dependency failure or an applicable owner-defined failure criterion ends the wait as a failure.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Store durable placement context and required references. Rebuild runtime handles and readiness state on load. Maintain request-scoped readiness and owner dependency results. Preserve the source generation and restore no transient input from the previous session.

## Acceptance criteria

1. Delayed geometry, collision, or required registration keeps gameplay suspended and resumes dependent restoration only after the required owner result.
2. A saved pose supported by a moving mechanism validates against its restored state. Airborne and swimming saves follow their own placement rules.
3. A stale callback, wrong-scope registration, or duplicate readiness signal cannot advance the active load or repeat completion.
4. An invalid required placement or registration fails into approved recovery. A successful load reveals the world and publishes Session Restored only after overall readiness.

## Outstanding questions and approval

Concrete readiness interfaces, owner dependency declarations, and placement validation fixtures remain follow-on work. The player-facing rules are inherited from approved specifications. See [SAVE-012-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-012-review-decision).
