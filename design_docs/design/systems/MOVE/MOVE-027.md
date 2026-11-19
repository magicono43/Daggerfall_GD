# MOVE-027 — Spawn and placement recovery

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Establish valid intended placement for spawning, arrivals and native restoration without unrelated fallback teleports, erased movement consequences or playable partial worlds. Small corrections remain local, bounded and explainable.

## Confirmed requirements

MOVE-027-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. CORE-011/013 readiness/native restoration and MOVE-004–016/026 movement-history/transition contracts remain binding. Classic/DFU save import remains outside scope.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`:

- `Game/PlayerMotor.cs#FindGroundPosition` casts downward, returning hit point or current player position on no hit. Target explicitly distinguishes no-hit status.
- `FixStanding` casts down and relocates above a hit using controller height*0.65. This is not full active-shape/context validation.
- `Game/PlayerEnterExit.cs#RespawnPlayer`/`Respawner`, `RestorePositionHelper` and `MovePlayerToMarker` reconstruct context or place markers. Source paths use readiness flags, saved doors and terrain-sampler checks, with some fallback/random-marker relocation.

Static inspection only; source unchanged. Source constants/fallbacks do not approve target correction distances or universal ground snapping.

## Detailed rules and behaviors

### Intent and readiness

Explicitly distinguish fresh spawn, doorway/teleport arrival and native restoration. Each request identifies stable required location, pose/facing, supported movement context and permitted correction policy. Restoring a falling/swimming/climbing player cannot silently become a grounded fresh spawn.

Prepare required geometry/collision and owner data before final validation. Airborne/swimming contexts need no universal supporting floor; platform/climb/effect contexts need their own validated relationships. Missing required content/conversion state invokes recovery rather than invented defaults.

### Candidates and local corrections

Try exact requested pose first, then permitted local candidates in declared deterministic order. Validate complete active collision shape, current support/volume/context and route constraints, not just a downward ray. Grounded arrivals may seek nearby valid footing; no-hit is an explicit unavailable-ground result, not a successful point equal to player position.

Corrections stay within the intended immediate area and configured bounded displacement. Do not cross walls, locked barriers or rooms. Collision checks must validate correction route as well as final volume where required to prevent tunneling across an obstruction. Exact candidate generation, bounds and margins require world-scale fixtures and validated moddable policies.

Random markers are permitted only when the original fresh-spawn intent explicitly requests random selection. Missing mapping/invalid saved pose cannot silently choose a random entrance, town or new-character spawn. Authored destination choice and recovery correction are distinct operations.

### Movement state and coordinates

Corrections preserve required velocity, fall history, posture, water/effects and valid platform/climb context under their owner contracts. They cannot erase imminent fall consequences, fabricate attachment or silently terminate required effects. Fresh placement initializes physical state only through its declared intent; doorway reset semantics follow MOVE-026 rather than universal load resets.

If a required mode relationship cannot be validated within permitted correction, fail safely. Detailed shape enlargement, support and fall segment policies remain MOVE-006/008–015 owners. Native load restores committed state rather than reapplying takeoff impulses, costs or grants.

Separate authoritative world/location coordinates from engine-local coordinates using explicit versioned conversion. Floating-origin rebase updates dependent histories/attachments coherently without changing physical pose, fall distance or relative support. Invalid/unsupported conversion requires recovery, not guessed coordinates. Exact scale/precision and migration are WORLD/LOC/SAVE contracts.

### Obstructions and failure

Validate current geometry including solid occupants and moving mechanisms. A blocked marker cannot make actors non-solid or automatically shove them aside. Wait/retry, if supported, is owned and bounded; no indefinite readiness loop or unbounded candidate search.

Return explicit success, corrected success or failure with correction provenance. If no permitted candidate works, retain required readiness suspension and enter CORE recovery. Preserve valid source context when available under MOVE-026; destructive replacement does not promise universal rollback. No silent collision bypass or unrelated fallback relocation.

### Completion, disclosure and saves

Log each correction's reason and bounded displacement under CORE diagnostic/privacy rules. Tiny ordinary valid adjustments need no popup; meaningful recovery discloses what changed through existing recovery UI. Do not label substantive corrected placement as an exact unmodified restore. Exact meaningful-versus-tiny threshold remains UI/LOC tuning.

Placement success requires coherent pose, collision shape and required movement-owner state. Surrounding entry/load operation retains input/simulation gating until all its own readiness requirements complete. Release only owned holds; restored UI or other suspension reasons remain effective.

Unresolved placement blocks saves with clear reason. Retry uses a new identified request after safe cleanup, rejecting stale completions/callbacks. No replay of completed placement/entry rewards, damage or activity from query attempts or corrective transforms.

## Relevant formulas and parameters

Correction displacement must satisfy declared operation/location bounds in authoritative units, with full-shape/context/route validity. Exact maxima, probe margins, candidate counts/order, waits and disclosure thresholds remain tested validated parameters. No generic ten-unit ground snap, 0.65-height offset or random fallback is selected.

## Required data

Request/session identity and placement intent; stable location/marker/door mapping; world/local coordinate version; desired/validated pose/shape/movement state; candidate policy and budget; current collisions/owner relationships; correction provenance/result and owned readiness/save restrictions. Concrete schemas remain engineering dependencies.

## Inputs, outputs and events

Inputs: spawn/arrival/save pose, ready geometry, owner-state validation, current collision/coordinate conversion and cleanup/cancellation. Outputs: exact/corrected success or checked failure, coherent pose/context and diagnostics/recovery. API names unselected. Ground query or async initiation alone is not completed placement.

## Cross-system interactions

CORE-011/013 fresh/native entry and CORE-005/016 scope/suspension; WORLD/LOC/DATA coordinates/content/geometry; MOVE-004 authority and specialized posture/air/fall/platform/climb/water/transport owners; MOVE-026 doorway mapping; MAGIC effects/teleport; SAVE schema/compatibility; UI disclosure and MOD validated correction policies. No new resurrection or unrelated respawn mechanic is implied by reference method names.

## Edge cases and failure conditions

Test low ceilings, sloped floors, wall overlaps, blocked markers/occupants, missing mapped door, changed terrain, airborne/swimming/climbing saves, moving platforms and origin rebase. A valid endpoint beyond a locked wall is not a valid correction. Restoring mode/state cannot invoke entry rewards or clear fall debt. Required missing relationships fail explicitly, not become standing. Stale retries cannot overwrite newer placement.

## Configuration and balancing options

Validated location/intent-specific correction bounds/candidates and compatible modded geometry are supported. Constraints cannot silently weaken native required-state validation or permit barrier crossing. Exact numerical limits and optional recovery destinations require explicit owner/design contracts; no unrestricted recovery teleport is introduced.

## Save/load considerations

Preserve authoritative coordinate semantics and supported physical histories through SAVE versions/migrations. Final physics validation occurs after geometry readiness even when structural preflight succeeded. Save only coherent committed placement; unresolved operations are restricted. Corrected result records enough provenance for disclosure without serializing raw probe/collider references. Exact durable provenance and commit boundaries remain SAVE/LOC scope.

## Technical constraints

Target: Godot 4.7.2. Separate coordinate conversion, pure queries, bounded candidate validation, state commitment and optional disclosure. Use stable identities, checked results and scope-safe cancellation. Concrete physics queries, world-origin representation and numerical tolerances require representative fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Requests distinguish spawn/arrival/native restore and preserve required context without universal grounding.
2. Exact pose is tried first; deterministic local candidates validate full shape/context/route within declared bounds.
3. No-hit ground differs from success; no correction crosses barriers/rooms or chooses unrelated/random fallback.
4. Required velocity/fall/posture/effect/attachment history is preserved or placement fails explicitly; fresh initialization follows intent.
5. Coordinate rebase preserves physical/fall/support relationships; invalid conversion invokes recovery.
6. Current moving/occupied geometry is respected without disabling solidity/shoving; waits/searches are bounded.
7. Corrected success reports/logs provenance appropriately; meaningful recovery is disclosed.
8. Completion requires coherent owner state and retains surrounding readiness/other suspensions; unresolved placement blocks saves.
9. Clean identified retry cannot revive stale callbacks or replay gameplay consequences.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against CORE-013, MOVE-004/006/008–016/026 and recorded restoration constraints. No direct contradiction identified. Full-context validation preserves airborne/water saves and source-specific history; bounded correction does not become unrelated fallback. Doorway impulse reset is intent-specific and cannot erase native flight. Origin conversion preserves fall distance. Readiness success is narrower than surrounding Session Restored release, retaining owner gates.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: numeric correction/search/wait limits and order, per-mode validation, stable coordinates/version migration, moving-object sampling, disclosure threshold, mod policy domains, cleanup/result/save boundaries and representative geometry/native fixtures. These do not waive local bounds, barrier protection or truthful failure.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-027-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, geometry, persistence and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
