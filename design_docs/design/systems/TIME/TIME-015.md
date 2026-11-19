# TIME-015 — Fast-travel settlement and arrival

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-015-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended experience

Deliver the confirmed journey with one payment, accurate elapsed time and safe arrival. The player sees the destination when it is ready. A hazard may stop the trip at the point it occurs. Cautious travel can restore eligible resources after a successful arrival, and mods can change or disable that benefit.

## Confirmed requirements

[TIME-015-D01 through D03](../../GAMEPLAY_DECISIONS.md) cover cautious recovery and optional quoted waits, interrupted and failed travel, and the conditions for successful arrival.

## Daggerfall Unity reference

Static inspection of local DFU 1.1.1 Release. `Assets/Scripts/Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs#performFastTravel` deducts payment, raises a pre-event, caches the current ship scene when applicable and requests marker-based teleport. It refills eligible cautious-travel vitals before advancing time. It suppresses imminent random spawns and can add time until approximately 07:10 for cautious travel or until the dusk hour for sunlight-sensitive travel. It requests skill advancement and fade, then raises the post-event without awaiting streamed placement. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Departure and progression

1. Consume the confirmed TIME-014 quote and revalidate the current actor, route, tender, destination and restrictions. Preflight known placement and transport prerequisites. Commit the checked fare once under the trip identity. Decline, invalidation or incomplete payment leaves funds, time and position intact. Capture the ship return context through its owner where applicable. Publish a departure milestone only after departure commits.
2. Use TIME-002 to advance over the accepted TIME-013 timeline and settle required consequences through TIME-004. For a complete stock trip, `elapsed = sum(accepted segment durations)`. Mods can add an arrival wait with nonnegative duration and valid shelter or exposure context. Include it in the quote before confirmation and process its elapsed consequences. The base trip has zero added arrival wait.
3. Apply actual per-segment daylight and exposure under TIME-007 and MAGIC-028, along with other approved timed effects, quest deadlines and legal rules. Preparation or loading contributes zero elapsed time. Stock simulated travel skips ordinary ambient encounter catch-up. Authored travel events can run under their owner policies. Preserve unresolved charges in their filing jurisdiction and re-evaluate destination enforcement through LAW-008/016.
4. Stop at an applicable interruption and retain committed elapsed time, fare and consequences. A living interrupted traveler uses a validated safe placement associated with the reached route location. Do not claim arrival at the original destination. Death or transformation hands off to its owning flow where applicable. No automatic fare refund applies to gameplay interruption.

## Arrival and recovery

- Prepare destination geometry and presentation while covered. A preparation milestone may run alongside route settlement if it has no arrival side effects. Commit pose and geographic context through WORLD-003 and MOVE-027 once the route has settled and the valid destination is ready. Use the declared marker policy and its authorized backups. Derive destination weather and light from committed arrival time and context under TIME-006/007 before reveal.
- On successful living cautious arrival, set health and fatigue to their current effective maxima and refill magicka to its current effective maximum where regeneration is permitted. Apply through CHAR and MAGIC with current restrictions. Reckless travel and interrupted travel receive no stock cautious refill. The refill is a completion effect and grants no sleep ticks or Medical practice. Validated mods can disable it, select eligible pools or supply alternative recovery through owner contracts.
- Request one applicable CHAR-013 checkpoint on successful living arrival independent of recovery selection. The default interval and live advancement rules still apply. Settle required arrival effects and publish one successful trip outcome after placement, context and destination presentation are ready. Reveal and return input under CORE readiness and suspension rules. Normal eligible destination encounters and enforcement resume through their owners.
- If placement or required settlement fails technically after payment, retain the trip and completed progress. Keep unsafe or incomplete scenes covered and gate dependent actions. Retry unfinished work or use an authorized WORLD-003 fallback with truthful placement provenance. Resolve ambiguous prior mutations before retry. An unrecoverable failure enters explicit owner recovery and never emits success. Any financial remedy for that technical outcome requires explicit policy and coherent accounting.

## Data, inputs, outputs and configuration

Inputs include session, character and trip identity, accepted quote, fare receipt, timeline and cursor, route context, departure and destination facts, placement intent and results, ready presentation, and settled effect identities. Outputs distinguish committed departure, actual elapsed and route progress, interrupted or pending recovery, and successful arrival with pose and context. Gameplay-relevant actions use checked owner operations. Observer notifications consume committed facts. Mod configuration includes supported recovery, encounter, wait and placement policies through DATA-003. API and signal names remain implementation decisions.

## Cross-system interactions and save/load

- TIME-012/013/014 govern selection, estimation and quote. TIME-002/004 govern elapsed settlement and recovery. WORLD-003 and MOVE-027 govern placement. TIME-017 governs ship return. TIME-006/007 govern environment. CHAR-013/018 and MAGIC govern checkpoint, pool and effect rules. QUEST-010, LAW-008/016 and encounter owners handle their authoritative consequences.
- Use settled save boundaries by default. A supported in-progress or recovery snapshot must retain the accepted quote and route, fare receipt, committed time and route cursor, placement result and completed settlement identities. Restore under SAVE and CORE-013 without adding wall time, charging again, replaying effects or redefining committed route work. A changed destination or profile follows explicit compatibility or recovery. An obsolete callback from another operation or session cannot complete this trip.

## Acceptance criteria

1. A revalidation failure or refused payment commits no departure, movement or time. Valid repeated or stale confirmation cannot duplicate fares.
2. Stock travel advances exactly the accepted timeline on success. A modded quoted wait advances its declared time in valid context, and hazards can interrupt before the planned arrival. An interruption preserves prior consequences and emits no original-destination success or cautious refill.
3. Successful cautious travel refills eligible pools once after valid placement. A no-regeneration pool remains subject to its restriction. Reckless travel and a modded disabled recovery policy produce no refill. Eligible successful travel requests one CHAR-013 checkpoint.
4. Queued or streamed arrival announces success only after required settlement, committed placement and ready destination presentation. Technical placement retry cannot repeat payment, elapsed advancement, recovery or checkpoints.
5. A long stock trip skips ambient encounter catch-up, processes authorized events and retains unresolved regional charges. Destination enforcement and encounter behavior can resume normally once the trip hands off.
6. A supported recovery save or duplicate completion callback cannot replay committed travel work. Required unfinished work must settle before the player acts on the destination.

## Consistency review and outstanding dependencies

The specification fits TIME-002/004, TIME-006/007, TIME-012–014, WORLD-003, CHAR-013, MAGIC-028 and LAW-016. Exact route interruption anchors, ship return details, technical-failure financial remedies and active-save recovery remain owner dependencies.
