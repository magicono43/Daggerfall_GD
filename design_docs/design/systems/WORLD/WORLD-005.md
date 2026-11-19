# WORLD-005 — Terrain window and recycling

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Keep terrain continuous around the player, including when they reverse course across a seam. Reuse nearby terrain to limit rebuilds and keep the memory cost predictable. Under capacity pressure, preserve safe movement and placement while allowing distant coverage to shrink.

## Confirmed requirements

- **WORLD-005-D01.** Start with a configurable square terrain window centered on the player's map pixel. Required gameplay coverage under WORLD-004 takes precedence. Set the default distance through world-scale, visibility and performance testing.
- **WORLD-005-D02.** Keep a bounded inactive cache of recently departed cells. Retain active collision for valid movement, arrival or projectile paths that still depend on it. Clear old bindings before reassigning a slot and validate the new cell and its seams before gameplay can use it.
- **WORLD-005-D03.** Under capacity pressure, reclaim inactive cached cells first, then reduce optional distant coverage. If required terrain remains unavailable, use WORLD-004's safe hold and recovery.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-005-interview-decisions) records the interview decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Source paths are relative to `Assets/Scripts/`.

- `Terrain/StreamingWorld.cs#UpdateWorld` requests a square centered on the player pixel. `PlaceTerrain` clips requests to the supported map bounds and can reactivate an inactive terrain and its billboard batch for the same pixel.
- `CollectTerrains` deactivates out-of-range terrain and billboards. `FindNextAvailableTerrain` selects an unused slot or an inactive out-of-range slot, removing the recycled pixel's index entry before reuse. If no slot is available, the code logs a diagnostic and breaks in the editor or quits outside it.
- `UpdateNeighbours` updates the four cardinal terrain links and clears links for inactive terrain. `Game/Utility/StartGameBehaviour.cs#ApplyStartSettings` applies the configured terrain distance.

## Detailed rules and behaviors

1. Derive the requested window from the committed player pixel and configured distance. Clip to validated world coverage. Combine window demand with required coverage for current play and admitted placement. Reprioritize against current demand under WORLD-004.
2. Terrain remains active while required by a current gameplay dependency. Recheck dependencies when movement, placement, projectiles or context change. Once eligible for retirement, disable active participation and keep reusable data in the bounded inactive cache when budget permits. Terrain residency changes coordinate with WORLD-006 and other owners to preserve their durable state.
3. Reactivate cached terrain only if its cell identity, data version, current frame placement and required seams validate. Rebind collision and neighbor links before reporting affected paths ready. Rebuild incompatible portions or request a fresh build.
4. When reassigning storage, remove old cell mappings and detach scene, collision and neighbor references. A slot can publish only results that match its current assignment and active request. Discard obsolete completion for that slot or cache its result separately when WORLD-004 permits.
5. Protect required coverage under pressure. Reclaim eligible inactive entries first, then shed optional distant coverage. If required coverage still cannot become ready, hold or recover under WORLD-004. A capacity decision cannot expose a hole along a supported path or signal false readiness.

## Relevant formulas, parameters and configuration

For window distance `r` in cells, the nominal window is `(2r + 1) × (2r + 1)` before clipping and any required coverage outside the window. Configure `r`, the inactive cache budget and the terrain resource budget. Default values, eviction ordering within eligible inactive entries, and any optional coverage restoration delay require representative testing.

## Required data

Committed player pixel, valid map bounds, terrain cell identity and content version, active and inactive assignments, frame and request identity, current gameplay dependencies, compatible cached resources, neighbor readiness and capacity accounting.

## Inputs, outputs and events

- **Inputs** — Current pixel, coverage requirements, settings, terrain build results, updated frame and available capacity.
- **Outputs** — Active, cached or retired terrain assignments, validated seam readiness, and capacity failure when required coverage cannot be satisfied.
- **Events** — Publish readiness only for current validated coverage. Terrain activation and retirement alone cause no location arrival or geographic crossing effects. Concrete API names remain open.

## Cross-system interactions

- **WORLD-001/002/004** supply committed geography, frame changes, required coverage and hold/recovery rules.
- **WORLD-006/007 and LOC** coordinate exterior activation, loose objects and durable state. **WORLD-008–011** supply terrain generation and presentation.
- **MOVE, COMBAT and MAGIC** identify valid collision dependencies for movement, arrival and projectiles. **AV/UI** own presentation and loading feedback. **CORE/SAVE** own session recovery and persistent capture.

## Edge cases and failure conditions

- Test quick reversals, diagonal steps and world edges. Cached terrain must reactivate at the correct position without stale collision or a seam gap.
- Test fast movement and arrival with overlapping demand under limited capacity. Required terrain remains protected until its dependencies are released.
- Test slot reassignment while terrain work is pending, rebase while a cell is inactive, and repeated loading of the same destination. Obsolete results cannot install resources or link the wrong neighbors.
- Test pressure across inactive cache, optional active coverage and required coverage. Persistent required failure invokes explicit recovery.

## Save/load considerations

Save committed world and domain state through their owners. Terrain slots, cache membership and neighbor links are runtime state rebuilt from the restored pose, active content and settings. Load validates required coverage through WORLD-004 before control resumes. Repeated loads cannot reuse stale resources from an incompatible session or content version.

## Technical constraints

Target Godot 4.7.2. Measure working-set cost and activation spikes, including render and collision resources. Neighbor and collision updates must become coherent before readiness. Exact pool or cache representation, generation identity and resource budgets remain open.

## Acceptance criteria

1. The configurable square follows committed player pixels and clips at world bounds. Required coverage takes priority regardless of window size.
2. A quick reversal can reuse a compatible cached cell. Required collision stays active while valid dependencies remain, and reactivated seams pass readiness checks.
3. Reassigning a slot removes old bindings. A stale completion cannot repopulate it or publish readiness.
4. Under pressure, reclaim eligible inactive cells before reducing optional active coverage. Required shortages follow the WORLD-004 hold and recovery rules.
5. Native load builds ready terrain around the restored context without replaying crossings or leaking prior assignments.

## Outstanding questions

- Calibrate window defaults and budgets, and choose how to measure capacity and order eligible evictions.
- Define how gameplay owners declare and release collision dependencies. Verify neighbor readiness, resource reuse and rebase behavior with representative Godot scenes.
- Set the conditions for restoring optional coverage after pressure subsides and coordinate the presentation with AV.
