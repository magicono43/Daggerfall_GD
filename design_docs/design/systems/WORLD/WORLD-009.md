# WORLD-009 — Terrain update jobs and neighbor seams

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Keep traversal, placement and projectile collision consistent while terrain streams or rebuilds. Players can use ready ground and cross ready seams without phantom edges, gaps or abrupt changes caused by partially applied terrain.

## Confirmed requirements

- **WORLD-009-D01.** Publish readiness by area and seam. A cell interior can become playable once its ground surface and collision agree and its WORLD-004 dependencies are ready. A crossing also requires compatible collision on both sides and at any corner the path touches.
- **WORLD-009-D02.** Keep the last valid terrain active during replacement while it remains compatible with the current context. Switch affected surfaces and collision together at a safe simulation boundary. If the old terrain is invalid, use the WORLD-004 hold until readiness is restored.
- **WORLD-009-D03.** Cancel obsolete work where practical and validate completed results before applying them. Cache compatible results when safe. Rebuild a current seam mismatch from resolved inputs. If the mismatch persists, leave the seam unavailable and invoke recovery when gameplay requires it.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-009-interview-decisions) records these decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to `Assets/Scripts/`.

- `Terrain/DaggerfallTerrain.cs#BeginMapPixelDataUpdate` schedules height sampling, optional location height blending, tile assignment and tilemap work.
- `Terrain/StreamingWorld.cs#UpdateTerrainDataCoroutine` waits for the job handle. `CompleteUpdateTerrainDataJobs` completes the work, applies the map data and climate material, promotes the terrain and reactivates its scene object. A synchronous path shares the completion method.
- `StreamingWorld.UpdateTerrains` updates neighbor links before publishing terrain-pass completion. Job completion, terrain activation and neighbor linkage are separate milestones. Runtime traversal between these milestones was not tested.

## Detailed rules and behaviors

1. Build candidate terrain against validated WORLD-008 inputs. Keep the generated result provisional until matched to the current cell assignment, content revision and applicable request. At installation, resolve placement in the current WORLD-002 frame. A rebase may leave world-coordinate samples reusable, while their old scene bindings require validation or replacement.
2. Prepare the ground surface and active collision from compatible terrain data. A cell interior may become ready independently where its coverage and required gameplay dependencies are coherent. For a path touching a seam or corner, validate shared samples and active collision across every touched cell, including any required neighbor bindings. Use compatible staged results for the affected coverage. Optional presentation details may complete separately under WORLD-004.
3. Keep the last valid coverage active during a rebuild while its collision and dependencies remain valid. Commit replacement surfaces and collision together at a safe simulation boundary. Update affected seam readiness against the committed coverage and retire old bindings when their users have released them. If compatible coverage is unavailable, WORLD-004 governs holds and recovery.
4. Cancel superseded work when practical. Validate completions against session, cell, assignment and dependency identity before publication. An obsolete result can be cached only if resource ownership and input compatibility are established. It cannot alter scene bindings, release a hold or publish readiness for a different request. Cleanup releases job-owned resources after their users finish.
5. When current seam validation fails, rebuild the affected terrain from the resolved inputs, including WORLD-008 boundary edits. If validation still fails, identify the seam and treat it as unavailable. Required paths use WORLD-004 recovery. Keep unaffected ready coverage available where safe.

## Relevant formulas, parameters and configuration

Compare shared height samples in authoritative coordinates using verified tolerances. Also validate the resulting collision coverage along the seam and at shared corners. Numeric tolerances, scheduling budgets, resource limits and rebuild timing require fixtures. WORLD-005 capacity priorities apply when old and replacement resources coexist.

## Required data

World cell and seam identities, required coverage, resolved terrain and edit versions, cell assignment and job identities, sample and collision results, readiness and dependency state, active coordinate frame, and ownership of pending and retired resources.

## Inputs, outputs and events

- **Inputs** — Area demand, resolved terrain data, current residency assignments, geometry and collision results, frame changes, cancellation and teardown.
- **Outputs** — Provisional build results, coherent playable areas and seams, retained compatible coverage, or explicit unavailability and failure.
- **Events** — Job completion, area readiness and seam readiness are distinct. Publish readiness only after coherent installation and validation for the active demand. Concrete API names remain open.

## Cross-system interactions

- **WORLD-008** defines height inputs and shared samples. **WORLD-004/005** own demand, residency and capacity, holds and recovery. **WORLD-002** supplies coherent frame changes.
- **WORLD-003/006 and MOVE-027** consume readiness for arrival, exterior activation and placement. **MOVE, COMBAT and MAGIC** depend on compatible collision along active paths.
- **AV and WORLD-010/011** consume terrain presentation and may finish optional details separately. **CORE/SAVE** own teardown, coherent restoration and recovery.

## Edge cases and failure conditions

- Test diagonal movement and high-speed sweeps through shared corners. A ready cell interior cannot authorize a path through an unready seam.
- Test a footprint edit spanning adjacent cells built in reverse order. Detect sample disagreement, collider gaps and phantom contacts even when the visual seam appears closed.
- Test a compatible rebuild under a moving actor and a rebuild after the old surface becomes invalid. Use coherent replacement or the WORLD-004 hold as appropriate.
- Test late jobs after slot recycle, rebase, teleport and session teardown. Verify both publication checks and resource cleanup.

## Save/load considerations

Save committed gameplay state and compatible world context through their owners. Rebuild derived terrain and readiness from the restored context. Pending jobs, scene bindings and neighbor links are runtime state. CORE-013 and MOVE-027 govern required terrain compatibility and pose validation before gameplay resumes.

## Technical constraints

Target Godot 4.7.2. Verify that updated surfaces, neighbor bindings and colliders are actually usable at the chosen simulation boundary before publishing readiness. Exact scheduling, thread and resource ownership, collider synchronization, and cache format remain open.

## Acceptance criteria

1. Ready cell interiors remain usable with unfinished neighbors. A crossing becomes available only when all touched edges and corners have compatible active collision and required coverage.
2. A valid old surface remains usable during preparation. The replacement becomes playable with matching surface and collision. Invalid old coverage invokes the WORLD-004 hold.
3. Obsolete work cannot overwrite recycled slots or activate a superseded destination. Compatible cache reuse preserves current identity and readiness checks.
4. A current seam mismatch triggers a rebuild from resolved data. Persistent mismatch gates that seam and invokes recovery when needed for required gameplay.
5. Teardown, rebasing and native restoration cannot publish stale collision or readiness.

## Outstanding questions

- Validate seam and corner tolerances, collider synchronization, and representative movement and projectile sweeps in Godot.
- Define the resource and scheduling budgets for overlapping terrain revisions and cancellation cleanup.
- Determine diagnostic detail and rebuild timing with WORLD-004/005 and the terrain owners.
