# WORLD-004 — World initialization and pixel transitions

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Make ordinary exploration continuous wherever the world is ready. After a spawn, load or teleport, let the player act when the immediate area supports safe play. Briefly explain any wait at a streaming boundary and preserve the player's movement state.

## Confirmed requirements

- **WORLD-004-D01.** The current readiness gate requires collision and gameplay-critical content for placement and the immediate playable surroundings. Distant scenery and optional decoration may finish afterward. This gate remains open to future design revision if experience or testing shows a change is needed.
- **WORLD-004-D02.** Prefetch during ordinary travel and continue movement in ready space. Before an unsafe step into unready space, hold at the last safe position, indicate loading, and preserve movement state. Required-content failure uses explicit recovery.
- **WORLD-004-D03.** Prioritize the latest required area and reuse relevant work. Safe caching of obsolete results is allowed. Obsolete work cannot activate content or mark a superseded destination ready. Publish geographic crossings for movement that actually occurred.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-004-interview-decisions) records the interview decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to `Assets/Scripts/`.

- `Terrain/StreamingWorld.cs#Update` consults `ReadyCheck`, detects a change from the recorded pixel or initial build, places the terrain neighborhood, calls `InitPlayerTerrain`, starts `UpdateTerrains` and clears the initialization flag. Broader location updates wait for the terrain pass.
- `InitWorld` clears the streaming world, establishes the origin from GPS and raises initialization events before final placement. `InitPlayerTerrain` handles central terrain data and nature first and starts the central location update.
- `UpdateTerrains` updates terrain neighbors before publishing terrain-pass completion. `UpdateLocations` starts location coroutines for active terrain with locations. Neither milestone establishes all requirements for player control.

## Detailed rules and behaviors

1. For initialization or destination replacement, derive the required area from the placement intent and supported movement context. Prepare terrain and seams reachable immediately, relevant location collision and gameplay-critical actors, volumes and triggers. Validate the needed state with its owners. Build optional materials and distant presentation in the background where supported.
2. Publish world geometry readiness for the current request once its required area is coherent. MOVE validates placement, WORLD-003 commits arrivals, and CORE coordinates control release with additional entry/load requirements. New-character opening work and restored owner state retain their own gates.
3. During ordinary movement, anticipate the next required area using the committed pose and movement reach. Continue normal movement when its swept path is supported by coherent collision and any required gameplay content. An ordinary map seam within ready space requires no pause. WORLD-001 derives and publishes committed crossings, and WORLD-002 governs any concurrent origin shift.
4. When the next step would query or enter unready space, keep the player at the last safe pose for that step and hold affected simulation as needed to preserve support, momentum, fall history and pending movement consequences. Avoid synthetic impacts, movement awards or forced relocation. Give brief loading feedback while held. Resume once the current frame and required path are ready. Required-content failure or lack of safe continuation invokes explicit CORE recovery.
5. Reprioritize streaming when movement, placement or world replacement changes the required area. Reuse compatible results for current demand. Retire obsolete activation work and validate session, request, content and frame applicability before using asynchronous results. Safe caching does not activate gameplay or advance readiness.
6. Keep geometry and gameplay dependencies available while needed by committed movement, placement or in-flight rules. WORLD-005/006 govern residency, retirement and activation details. Coordinate with projectile and delivery owners when their valid simulation paths need collision beyond the player's immediate area.

## Relevant formulas, parameters and configuration

No fixed readiness radius or timeout is selected. Required coverage must account for the supported movement mode, collision shape and reachable sweep at the point control is granted. Prefetch reach, feedback timing, retry policy and background budgets require testing with representative movement, terrain seams and content. Future changes to the readiness gate can be reviewed as experience or testing warrants.

## Required data

Committed player pose and frame, geographic pixel, placement intent, required area and owner dependencies, content and session versions, cell/task identity, readiness and failure state, and the last safe movement pose with its owner state.

## Inputs, outputs and events

- **Inputs** — Initialization and placement requests, committed movement and anticipated reach, residency and collision results, owner readiness and failure results, and context replacement.
- **Outputs** — Prioritized area demand, required geometry ready, continued movement or a streaming hold, and actionable failure/recovery.
- **Events** — Distinguish geometry readiness, presentation progress and the enclosing entry or arrival outcome. Attribute readiness to its active request and area. Geographic crossings remain WORLD-001 outputs.

## Cross-system interactions

- **CORE-005/011/013** own session readiness, startup/load gates, suspension and recovery. **WORLD-003 and MOVE-026/027** own arrival commitment, pose validation and correction.
- **WORLD-001/002** own coherent geography and rebasing. **WORLD-005/006 and LOC** own terrain residency, location activation and layout state.
- **MOVE, NPC, COMBAT and MAGIC** own active simulation and swept collision requirements. **AV/UI** own optional scenery and player-facing feedback. **DATA/MOD and SAVE** supply validated content and restore dependencies.

## Edge cases and failure conditions

- Test rapid seam crossings, reversals, fast movement and approaching an unready seam while falling or riding a platform. A hold cannot manufacture or erase a landing, impact or distance moved.
- Test initialization with ready central terrain but a missing neighboring seam, collision volume, location trigger or required actor. Optional decoration may finish later.
- Test teleport, load, rebasing or session teardown while earlier jobs remain pending. Results must match the active context before activation.
- Failed required content must produce an explicit failure and recovery path. Partial visual coverage alone cannot imply collision or placement readiness.

## Save/load considerations

Capture committed world, pose and domain state through SAVE. Apply existing save restrictions during unresolved initialization or arrival. For an ordinary streaming hold, SAVE and the affected owners determine whether a coherent committed snapshot is available. Rebuild streaming demand and required readiness from the restored context before gameplay resumes. Preserve committed crossing and arrival facts without replaying their consequences.

## Technical constraints

Target Godot 4.7.2. Validate readiness against the active operation and coherent physics frame. Test scene activation and collision availability before exposing a playable area. Concrete job scheduling, coverage metrics, retention budgets and physics synchronization remain open.

## Acceptance criteria

1. Spawn, load and teleport wait for required immediate gameplay coverage and their enclosing owner gates. Optional scenery may finish after control returns.
2. Crossing a ready seam continues normally. A step toward unready space holds safely with feedback, preserves movement consequences, and resumes when ready or enters explicit recovery on failure.
3. Rapid crossings and replacement requests prioritize current demand. Compatible work is reused and obsolete callbacks cannot activate content or report readiness for the wrong destination.
4. Geographic crossings correspond to actual committed movement. Loading, reprioritizing and pure origin shifts produce no synthetic crossings.
5. Native load reconstructs required readiness around the restored pose without replaying crossing or arrival effects.

## Outstanding questions

- Calibrate immediate coverage, lookahead and feedback timing across movement modes and world scales.
- Define precise hold behavior for moving supports and independent projectiles, with MOVE and collision owners. Verify Godot behavior at activation and rebase boundaries.
- WORLD-005/006 must define retention and reuse budgets. CORE and SAVE must resolve applicable contention, recovery timing and coherent save admission during an ordinary streaming hold.
