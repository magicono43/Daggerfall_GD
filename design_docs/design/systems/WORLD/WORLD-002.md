# WORLD-002 — Floating origin shifts

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Keep the active simulation close enough to its local origin for reliable movement, collision and rendering as the player travels. A shift is invisible to the player. Riding a platform, falling, crossing a map boundary and firing a projectile behave as they would over the same movement without a shift.

## Confirmed requirements

- **WORLD-002-D01.** Use separate configurable horizontal and vertical distance thresholds. Choose values through world-scale and physics testing. Map pixel changes update geography and streaming independently.
- **WORLD-002-D02.** Commit one coherent shift at a physics boundary for the entire active simulation space. Resolve gameplay positions, geometry, attachments and queries in the committed frame before simulation resumes. Presentation caches may rebuild before the next visible frame.
- **WORLD-002-D03.** If a required system cannot apply the shift, defer while the current origin remains within a verified safe range. Suspend affected simulation and invoke existing recovery when safe continuation cannot be established.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-002-interview-decisions) records the interview decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to `Assets/Scripts/` in the reference source.

- `Utility/FloatingOrigin.cs#FixedUpdate` skips streaming initialization, recenters horizontally by the difference in map pixels scaled to terrain size, and recenters vertically when local Y lies outside ±500 Unity units.
- `OffsetPlayerController` clears active platform tracking, adjusts fall start height and offsets the player and world compensation. `OffsetChildren` offsets the streaming target's immediate children. Active enemy ground-height caches receive the vertical offset, and `OnPositionUpdate` broadcasts the local delta.
- `Terrain/StreamingWorld.cs#OffsetWorldCompensation` adjusts the last player position used for geographic integration. `Utility/PositionUpdate.cs` and `Game/MobilePersonMotor.cs` subscribe to the local shift event.

## Detailed rules and behaviors

1. WORLD evaluates the active player's local horizontal distance and vertical displacement at a safe physics boundary. A crossed threshold requests a shift to an eligible origin that places the active simulation back within its operating range. Horizontal and vertical corrections due at that boundary share one local translation. The trigger and the verified limit for deferring a shift are separate parameters.
2. Apply the shift to the active simulation space as one observable commit. Prepare the new origin and required state updates before exposing the change. Translate local positions for geometry, active actors, dynamic bodies, attachments, projectiles and gameplay caches that use the old frame. Every position receives the equivalent change exactly once, including through parent transforms. Location-local or geographic records use their own frames and retain their values.
3. Preserve relative positions, orientation, linear and angular motion, fall history, valid support or climb attachments, and pending collision or impact obligations. Buffered queries and asynchronous results must be converted coherently, recomputed safely or rejected as stale. Resume queries and simulation only once they can use one consistent frame.
4. Publish the origin and its local translation once the new frame is coherent. WORLD-001 derives geographic changes from real movement in the matching frame. A coincident real crossing is processed normally and once. Camera interpolation and other visible caches consume the shift before presenting the next frame.
5. If preparation cannot complete, continue on the intact old frame only within the validated range. Reevaluate pending work at later safe boundaries and discard work superseded by context replacement. If an application failure leaves an uncertain or partially updated state, suspend affected simulation immediately. Use CORE recovery and resume only after the required state is coherent and validated.

## Relevant formulas, parameters and configuration

For a point stored in the old local frame, new local position = old local position + shift delta. WORLD updates the matching origin so the geographic conversion of that point is invariant. For aligned equal-scale axes, the origin moves by the opposite translation.

Configure horizontal and vertical trigger distances and define safe deferral limits with enough margin for supported speeds, the active simulation extent and the validated physics precision. Recenter far enough inside the trigger to prevent repeated shifts around a threshold. Exact units, values, distance metric and origin alignment require world-scale fixtures. DFU constants are reference values.

## Required data

Active session and simulation context identity, matching origin and pose, coordinate conversion version, shift identity and delta, validated thresholds and safe limits, and ownership of frame-dependent transforms, queries and histories. Keep enough frame identity to recognize stale inputs and duplicate application.

## Inputs, outputs and events

- **Inputs** — Committed pose and origin, settings, world and placement lifecycle, and required participant readiness.
- **Outputs** — Committed origin and translated state, safe deferral on the intact frame, or a suspended failure routed to recovery.
- **Events** — One committed origin-shift notification with old and new frame identity and local delta. Rebase itself generates no gameplay movement, entry or geography events. Public API names remain open.

## Cross-system interactions

- **WORLD-001/003/004 and LOC** coordinate geographic position, placement, streaming and active simulation scope. Initialization or replacement establishes its own coherent frame before gameplay resumes.
- **MOVE-010/027, NPC, COMBAT-009/014 and MAGIC-005** preserve fall measurement, support and motion state, relative collision and in-flight delivery. WORLD supplies the frame change and each domain owns its dependent state.
- **AV/UI** synchronize interpolation, cameras and local presentation caches. **CORE/SAVE** own simulation holds, coherent capture and recovery.

## Edge cases and failure conditions

- Check a moving platform and rider, active climbing or falling, and projectile flight or impact at the shift boundary. Detect phantom contacts, doubled hits, dropped arrows and fall-distance resets.
- Check simultaneous horizontal and vertical thresholds, a real map crossing on the same step, and a large movement that exceeds the safe range before a normal shift can commit.
- Check roots outside streamed geometry, nested transforms, objects becoming active during streaming, and callbacks carrying an obsolete frame. Each required position must be correct exactly once.
- A deferred shift can coexist with the intact old frame while it is safe. A partial shift or exhausted deferral margin requires suspension and explicit recovery. Do not treat missing collision readiness as empty space.

## Save/load considerations

Capture a coherent before- or after-shift frame consistent with WORLD-001 and SAVE. A shift in progress cannot supply a partially translated snapshot. Restore authoritative geographic or location positions and supported domain state into a coherent origin before resuming gameplay. Preserve in-flight state according to its owner and avoid replay of committed collisions, impacts or crossings. Pending runtime rebase work belongs to the active frame lifecycle.

## Technical constraints

Target Godot 4.7.2. Validate physics, collision queries and visible interpolation at the commit boundary using representative world extents. The implementation must cover required participants regardless of scene hierarchy. Exact physics-server synchronization, scheduling, spatial registration and native save representation remain open.

## Acceptance criteria

1. A pixel crossing within the distance thresholds updates geography and streaming without requesting a shift. Exceeding a distance threshold can shift even within the same pixel.
2. A combined shift changes all required local positions coherently while the player's geographic position and relative geometry remain invariant. A real crossing on the same step publishes once.
3. Riders, falling actors and in-flight projectiles retain their movement, support and pending outcomes. Shifting produces no extra impact, practice award or movement consequence.
4. A missing participant defers while the intact frame is safe. Exhausted safety margin or partial application suspends gameplay and invokes recovery without exposing a mixed frame to simulation.
5. Saving and loading preserves committed position and owner state. A stale request or callback cannot mutate a reconstructed frame.

## Outstanding questions

- Calibrate distance metrics, trigger values, safe limits and recenter targets using representative world-scale, motion and collision scenarios.
- WORLD/LOC need to identify which independent simulation spaces can require rebasing, including large interiors. Define participation and ordering during residency changes with WORLD-003/004.
- Validate Godot physics and presentation behavior at the commit boundary, including how interpolation avoids a visible jump. SAVE owns final capture and migration details.
