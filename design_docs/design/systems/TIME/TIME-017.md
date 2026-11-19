# TIME-017 — Ship access and return context

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-017-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended experience

An owned ship provides a persistent offshore location and storage. Boarding and returning take no game travel time. The player can leave possessions aboard, save during a settled visit, and return safely even if their original position needs an authorized fallback.

## Confirmed requirements

[TIME-017-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm checked return and fallback, use of the boarding location for fast travel, independent ship and visit persistence, and moddable recovery.

## Daggerfall Unity reference

Static inspection of local DFU 1.1.1 Release. `Assets/Scripts/Game/TransportManager.cs#IsOnShip` combines recorded boarding data with owned ship map coordinates. `UpdateMode` captures position, caches scene data and teleports to an owned ship. On return it restores the boarding position and can request a random start marker if the terrain sampler changed. `Game/Utility/TravelTimeCalculator.cs#GetPlayerTravelPosition` uses the boarding position as the fast-travel origin while aboard. `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs#performFastTravel` caches the ship scene before fast-travel departure. Paths after `Assets/Scripts/` use that root. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Boarding and disembarkation

- Require current entitlement to the exact ship under ECON-014 and the applicable access and location rules. A passage fare waiver never authorizes boarding an owned ship. Base boarding is a zero-duration teleport to the static offshore destination under MOVE-016. Time spent loading or fading adds zero elapsed time. There is no stock steering or sailing operation.
- Before boarding, record a candidate return anchor with stable location and geographic identity, relevant pose and movement context, and content compatibility data. Validate the origin and ship destination. Commit the aboard visit and return record with validated ship placement through WORLD-003 and MOVE-027. A failed boarding attempt cannot replace a committed visit or publish boarding success.
- On return, first try the recorded location and pose under current access, collision, movement and content checks, including permitted placement correction. If it is unusable, try a declared and validated fallback in that departure location. Do not select an unrelated or random marker. Commit return and close the visit only after safe placement and coherent context are established. If no return candidate is usable, keep the existing visit. Keep or recover the player to a safe aboard state where possible and present the applicable retry or recovery outcome.
- Derive aboard status from the committed exact ship and visit context. A shared map pixel alone is insufficient. Do not retain Ship as a locomotion mode. Persist the current valid movement context through its owner. Retry and stale callbacks cannot duplicate boarding or consume the return anchor early.

## Fast travel from aboard

- Use the validated boarding location as the TIME-013 route origin for the stock owned-ship visit. Recheck applicable origin restrictions, including any access or legal gate that would also apply when departing from that location. An unavailable origin blocks travel or requires explicit recovery. Route, fare, exposure, and payment still follow TIME-013–015. Paid or waived sea passage does not create a ship visit or a return anchor.
- Retain the active visit and return anchor throughout pending travel. Preserve authoritative ship contents before releasing ship residency. When valid placement ashore commits at the destination or an authorized interruption location, close the visit. If failed placement or interruption leaves the actor aboard, keep the return record and apply TIME-015 recovery for already committed fare and time. Death or transformation follows the appropriate owner handoff and reconciles the ship visit with the resulting committed location.

## Persistence, data and events

- Persist authoritative interior and exterior state for the exact owned ship through ECON, LOC and ITEM. Stored and dropped possessions remain attached to that property across visits and native saves. The return record is scoped to a specific visit. Closing it does not clear ship contents, and a later boarding establishes a fresh record.
- A settled native save aboard retains exact ship and deed identity, visit identity, the current valid aboard pose and context, return anchor, and compatibility metadata. Revalidate these before enabling ship actions. Restore does not replay boarding, advance time or transfer possessions. Pending transitions use settled save boundaries by default. A supported recovery snapshot retains completed placement and unpaid or unfinished work where applicable under the governing owner contract.
- Inputs include session, actor, ship and deed IDs, visit and transition IDs, entitlement, committed location and return context, destination and fallback policies, and placement and readiness results. Outputs distinguish validated return or travel origin, committed boarding or ashore placement, and explicit unavailability or recovery. Notify observers after owner commitment. Public APIs and mod schemas remain implementation decisions.

## Configuration, cross-system rules and failures

- Support validated mod profiles for boarding access, return points, ship behavior and recovery. Alternate moving or sailing profiles require applicable movement, content, time and save contracts. The base boarding and disembarkation duration is zero. TIME-013–015 own scheduled travel duration and fares.
- ECON-014 owns exact deed entitlement and blocks stock sale while aboard, during pending boarding or return, or with player possessions aboard. A pending away trip that retains the aboard visit does not make the ship sale-eligible. ITEM protects belongings and WORLD-003, MOVE-016/027 and LOC own placement and geography. CORE and SAVE govern covered transition, compatibility and recovery. DATA-003 governs mod validation.
- If a script or incompatible profile invalidates access while aboard, gate ordinary actions that require valid entitlement. Preserve belongings and return facts and use an explicitly authorized, safe ashore recovery when needed. Never silently choose another owner's ship, delete possessions or strand the player through an invalid teleport. If no safe placement can be verified, keep the recovery state and report the actionable problem.

## Acceptance criteria

1. Valid ownership boards the exact static ship with zero elapsed time. A fare waiver alone cannot board it. A failed boarding leaves origin and visit state coherent.
2. Returning tries the recorded pose first. If blocked, a valid same-location fallback succeeds. With neither candidate valid, no return commits and the visit remains available for recovery.
3. From aboard, the travel estimator uses the validated departure location. Its restrictions still apply. Successful or interrupted travel closes the visit only on authorized ashore placement. Failure that leaves the player aboard preserves the return anchor.
4. Stored or dropped possessions survive leaving, revisiting and native load. Loading aboard restores the exact visit without repeating boarding or granting new ownership. Sale follows existing aboard, transition and belongings checks.
5. A mod can supply a compatible alternate return point. Invalidated entitlement or incompatible content enters explicit recovery, preserves contents, and prevents duplicate placement or effects on retry.

## Consistency review and outstanding dependencies

The specification fits MOVE-016, WORLD-003, ECON-014, FACT-017 and TIME-013–015. Exact fallback anchors, ship scene compatibility, mod profile contracts, and supported recovery snapshots remain owner dependencies.
