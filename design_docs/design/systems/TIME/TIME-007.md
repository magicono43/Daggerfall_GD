# TIME-007 — Sunlight, day/night and lighting

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-15 with “I approve”. See TIME-007-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Give players a readable day and night cycle and reliable rules for finding shelter. Weather and local lights can change how a scene looks. An actor's exposure follows the world schedule and their location, so a player can plan daylight-sensitive travel and know when an authored shelter protects them.

## Confirmed requirements

[TIME-007-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm fixed base schedules with moddable regional and seasonal overrides, authoritative actor-specific exposure and shelter, smooth ordinary lighting and destination lighting prepared before reveal.

## Daggerfall Unity reference

Static inspection of the local DFU 1.1.1 Release snapshot. Paths are relative to `Assets/Scripts/`. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

- `Utility/DaggerfallDateTime.cs` defines dawn at 06:00, dusk at 18:00, city lights on at 17:00 and off at 08:00. `Internal/WorldTime.cs#RaiseEvents` emits named boundary callbacks from sampled calendar fields.
- `Game/SunlightManager.cs#Update` calculates sun angle and samples a light curve using normalized time from dawn to dusk. `Game/WeatherManager.cs#SetSunlightScale` adjusts the lighting for weather.
- `Game/PlayerEnterExit.cs#Update` sets the player sunlight flag when it is daytime, the player is outdoors and the player is outside prison. This source uses a blanket custody check. The specification models protection through each actor's environment and explicit shelter, including during custody under LAW-owned context rules.

## Schedule and parameters

Compute time of day from the TIME-001 timestamp modulo `86,400,000` game milliseconds. Base daylight is `[06:00, 18:00)`. The base city-light interval wraps midnight and is true at `time ≥ 17:00` or `time < 08:00`. Dawn and lights-on take effect at their boundary. Dusk and lights-off end the corresponding state at their boundary. City-light state applies to fixtures that opt into the schedule. Torches and other local lights use their own rules.

Support validated regional, seasonal and combined region-season schedule overrides through DATA-003. The lookup order is combined override, region override, season override, then global baseline. Resolve region and season from the relevant instant and context. Use distinct in-range on/off and dawn/dusk values. Daylight requires dawn before dusk. City-light intervals can wrap midnight. All-day or no-daylight schedules are outside this v1 contract. Where a change in region or season changes effective schedule state at the current instant, reconcile it immediately from the new context. TIME-003 supplies scheduled markers when a boundary is crossed in the applicable context.

## Gameplay exposure and lighting

- Resolve gameplay sunlight per affected actor from the authoritative daylight schedule and WORLD/LOC exposure context. In daytime, exposed outdoor and authored exposed areas count as sunlight. Enclosed interiors and explicitly authored shelter block it. Stock fog, rain, clouds and rendered shadows do not change exposure. An open courtyard can be exposed while a covered walkway in the same location is sheltered.
- A torch, window view, light shaft or audio cue does not change exposure by itself. Any alternate gameplay exposure policy requires an explicit validated rule under the affected owner. Holy-place exposure is a separate owner input. Use the actor's actual context, including during simulated activities. Custody exposure uses explicit location and shelter context under LAW. An unready or invalid required exposure context is a distinct result and cannot be treated as shelter or exposure by default.
- AV derives lighting from committed time, resolved schedule, weather and local presentation. In ordinary play, vary sun angle and ambient lighting smoothly. Weather dimming uses TIME-006 presentation transitions. City fixtures use their exact scheduled target state and may visually blend under AV. Gameplay exposure changes at exact schedule or context boundaries, independent of the blend.
- After fast travel, covered transitions and native load, derive lighting from the ready destination before reveal. Outdoor lighting uses destination weather and time. Enclosed interiors use their local lighting, with TIME-006 opt-ins for exterior cues. Suppress historical presentation transitions after time jumps.

## Required data, inputs, outputs and events

Inputs include committed timestamp, region and season, resolved schedule, actor/session identity, authoritative location and shelter or exposure data, weather context, fixture eligibility and scene readiness. Outputs include day/night state, scheduled city-light state, actor sunlight exposure or classified unready/invalid result, named boundary schedule inputs for TIME-003, and lighting targets for AV. Publish committed state before notifying consumers. A scope or context update can change exposure without advancing calendar time. Public API and event names remain implementation choices.

## Cross-system interactions

- TIME-001 supplies calendar and season. TIME-002–004 supply advance intervals, boundary discovery and required consequence ordering. TIME-005/006 supply committed weather and local environment. AV owns lighting curves and transitions. WORLD and LOC own region, location and explicit exposure data.
- [MAGIC-028](../MAGIC/MAGIC-028.md) consumes actor exposure for its approved damage cadence and nighttime departure rules. It retains applicable daylight exposure along travel routes. TIME-012–017, WORLD and LAW must provide authoritative route or custody context for intervals they own. A destination sample cannot establish exposure earlier in a trip. CHAR and MAGIC own damage, protection, timing and vulnerability effects.

## Save/load, configuration and technical constraints

- Restore exact clock time and authoritative location, compatible schedule definitions and dynamic shelter state through their owners. Recompute derived daylight, fixture targets, exposure and render state. Preserve MAGIC-008/028 hazard phase through native load. Restoration adds no elapsed time or initial damage tick. SAVE and DATA own compatibility if schedule or context definitions change.
- Validate overrides and required references using DATA-003. Expose schedule and authored context data to supported mods. AV tuning includes ambient and sunlight curves and fixture fade durations. Brightness, shadows, audio and graphics quality cannot change authoritative exposure. Godot 4.7.2 renderer representation and exact baseline lighting curves remain implementation and tuning dependencies.
- Revalidate exposure when an actor crosses a shelter boundary or region, when a resolved schedule changes, and when authoritative location context becomes ready. Ignore stale session or location updates. For gameplay that requires known exposure, use the owner's readiness or recovery contract while context remains unresolved.

## Acceptance criteria

1. The base daylight state changes at 06:00 and 18:00. City-light state changes at 17:00 and 08:00 and stays on across midnight. Validate supported overrides and enforce deterministic lookup.
2. Outdoors at noon, stock rain, fog and a rendered shadow leave an actor exposed. An enclosed room or authored shelter blocks exposure. Local torchlight and exterior window views do not change exposure. An adjacent exposed actor can have a different outcome at the same timestamp.
3. Region or season changes refresh the resolved schedule immediately. A transition to a region where daytime is already active updates exposure even when no local dawn marker was crossed in the move.
4. Ordinary lighting changes smoothly. Covered travel and native load reveal the destination's correct lighting. Changing graphics settings or blend duration does not change the timing of gameplay exposure or the city-light schedule.
5. A night departure that crosses into daylight supplies actual route exposure at applicable due instants. A protected route segment or custody area blocks exposure only where the authoritative context supplies shelter. Unresolved required context cannot silently turn a hazard on or off.
6. Save and load while exposed with an active sunlight vulnerability. Resume the owner's saved phase with no extra tick from the load, and recompute presentation before reveal.

## Consistency review and outstanding dependencies

The specification fits TIME-001–006 clock, boundary and weather rules, MOVE-026 readiness, and MAGIC-028 actor-specific exposure and travel obligations. Concrete world and route exposure data, custody context, stock AV curves and save compatibility remain owner dependencies.
