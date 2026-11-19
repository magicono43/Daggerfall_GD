# WORLD-003 — Teleport and arrival placement

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Arrive at the destination promised by the travel action, with valid placement and consistent location and geographic context. A route can express the character of the journey through its arrival marker. When arrival is blocked, the player gets a truthful outcome and a safe way forward.

## Confirmed requirements

- **WORLD-003-D01.** Each route declares its arrival intent. Resolve exact coordinates, Recall anchors and named doors to their specified targets. A general location route uses an authored default marker and may explicitly choose approach-side selection.
- **WORLD-003-D02.** Allow ordered, authored backup markers only for general location routes. A specific target allows the target and its permitted local corrections. General location backups stay within the destination and pass the same access checks.
- **WORLD-003-D03.** Use one arrival contract for ready and streamed destinations. A ready destination may complete immediately after validation. Streamed arrival remains pending until geometry, placement and context are ready. Publish one committed outcome.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-003-interview-decisions) records the interview decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to `Assets/Scripts/`.

- `Terrain/StreamingWorld.cs#TeleportToCoordinates` and `TeleportToWorldCoordinates` resolve map pixel and offset inputs. `TeleportToMapPixel` updates GPS, starts world initialization, clears fall damage and raises the teleport event before final placement.
- `StreamingWorld.Update` processes pending placement after terrain work and location updates. Placement modes include pixel origin, offset, location marker and dungeon entrance.
- `PositionPlayerToLocation` can use approach direction to weight randomized side selection and falls back to terrain origin when the location object is missing. `PositionPlayerToDungeonExit` looks for the lowest dungeon entrance and uses the pixel origin for some missing-door cases.

## Detailed rules and behaviors

1. The requesting route identifies its destination, arrival policy and movement handoff. Validate applicable access, stable destination references and supported coordinate or layout versions. An explicitly targeted map coordinate, anchor or door retains its identity throughout preparation and retry. General location requests identify the location plus its marker selection policy.
2. Resolve the intended candidate. For general locations, use the authored default or the route's declared approach-side policy. Pass each candidate through MOVE-027 for exact placement and any permitted bounded local correction. For a general location only, proceed through its declared backup order when the preceding candidate is missing or fails placement. All backups must satisfy the original route's destination, access and placement constraints. If the route is no longer authorized, fail the request.
3. Prepare required destination content and geometry under WORLD-004 and LOC. Validate with the current collision shape, destination movement context and applicable access before commitment. If already ready, these checks can complete in the same operation step. During streamed preparation the request remains pending, with CORE/MOVE gating input and simulation as required.
4. Commit the accepted pose, context and geographic state coherently. Publish exact or corrected success with placement provenance under MOVE-027. Report when an authored backup supplied the arrival. Allow source owners to apply their completion effects once. Arrival cannot turn a stale callback, terrain-ready signal or duplicate input into a second commitment.
5. On failure or authorized cancellation, retain the valid source context where available and release only operation-owned holds after safe cleanup. If replacement has invalidated the source, retain suspension and use CORE recovery. Corrected placement follows MOVE-027 and cannot cross barriers or silently change a promised specific target.
6. Route owners control access, cost, elapsed game time, movement handoff and reward or consumption rules. Stock guild teleport remains free and adds no game travel time. Recall applies its approved fresh movement placement and consumes the anchor only after successful arrival. A failed arrival retains the anchor and does not automatically refund an already committed cast.

## Relevant formulas, parameters and configuration

The arrival contract introduces no shared fare, time, marker weighting or movement formula. Configure the route's destination mode, allowed marker roles, authored default and ordered backups, optional approach selection, and correction policy within MOVE-027 bounds. Approach selection should yield a defined result for missing approach data or ties through the route's authored policy. Exact placement metrics and approach classification remain technical dependencies. Validate modded route and marker data through DATA/MOD and the relevant route owner.

## Required data

Session and request identity, source context, route identity and access requirements, destination ID or versioned pose, applicable marker or door IDs, optional approach input, facing and movement handoff, and permitted corrections. Keep candidate, readiness, validation and terminal outcomes available to the owners that coordinate commitment and recovery.

## Inputs, outputs and events

- **Inputs** — Authorized request, validated destination and marker data, streaming and collision readiness, current access and placement results, and operation cancellation or recovery inputs.
- **Outputs** — Pending, committed exact or corrected arrival with candidate provenance, or explicit failure or cancellation. Keep unavailable targets and technical failures distinguishable.
- **Events** — Accept or prepare, geometry ready, and terminal outcome are distinguishable. Publish committed pose and geographic context before arrival-success consumers run. One request receives one terminal outcome. Public event names and exact owner ordering remain open.

## Cross-system interactions

- **WORLD-001/002/004 and LOC** own geographic publication, coherent origin, streaming readiness and location layout/marker resolution.
- **MOVE-026/027** own transition and placement checks, correction bounds, movement context and safe recovery. Native restore continues to use CORE-013 and its own pose rules.
- **MAGIC-024, ECON-018 and TIME** supply source-specific route intake, costs, time and completion consequences. **CORE/SAVE** coordinate holds, operation conflicts, recovery and coherent persistence.
- **DATA/MOD** supply stable validated definitions and route options. **UI** presents pending placement, unavailable destinations and meaningful recovery.

## Edge cases and failure conditions

- Test missing or occupied named targets, missing default or backup data, multiple dungeon entrances, and an approach hint unavailable at arrival. Check that a specific target stays specific.
- Check a locked gate, access revoked during streaming, or a backup on the far side of a restricted barrier. A backup cannot bypass the original route's checks.
- Check same-location and streamed arrival into water, air or moving geometry with the applicable movement policy. Collision readiness and a valid destination pose are required before success.
- Test rapid repeat input, a competing load or doorway request, late callbacks, and failure after source teardown. Reject stale results and preserve committed charges, anchors and other owner state according to their specs.

## Save/load considerations

Ordinary saves require a coherent committed state. An unresolved arrival follows the applicable save restriction and exposes a clear reason. Save the committed pose, geographic/location context and route-owner facts. Restore through native-load rules without replaying travel time, costs, entry effects or anchor consumption. Any owner-supported recovery record must describe the actual committed outcome and unfinished work.

## Technical constraints

Target Godot 4.7.2. Treat streamed readiness, placement validity and committed arrival as distinct outcomes. Serialize conflicting context operations through their owners. Bind callbacks to the originating session and request, including immediate paths. Preserve WORLD-002's coherent frame when a request coincides with rebasing. Concrete APIs, staging and frame scheduling remain open.

## Acceptance criteria

1. Specific coordinate, door and Recall requests reach their intended target or a permitted local correction. Missing or blocked targets report failure when no permitted correction works.
2. A general location uses its declared default or approach policy and authorized backups in order. No backup bypasses restricted access or falls back to an unrelated origin.
3. Already-ready and streamed arrivals use the same validation and commit rules. Streamed preparation can expose readiness without publishing destination geography or success.
4. A successful arrival publishes one coherent result. Duplicate and obsolete callbacks cannot repeat placement, charges, anchor consumption or entry effects.
5. Failure retains a valid source when available or suspends safely for recovery. Stock guild teleport adds zero fare and game travel time. A failed Recall retains its anchor under MAGIC-024.
6. A committed save restores the established context without replaying arrival. An unresolved transition observes the applicable save restriction.

## Outstanding questions

- LOC must define marker roles, stable IDs and content validation. Route owners must define approach classification or fallback where they opt into approach-based arrival.
- WORLD-004 and CORE must settle readiness, conflicting request priorities and cancellation boundaries. MOVE-027 owns correction tuning and meaningful disclosure thresholds.
- SAVE and route owners must define any supported native representation of unresolved recovery and verify once-only completion.
