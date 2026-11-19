# TIME-005 — Climate and seasonal weather selection

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-15 with “I approve”. See TIME-005-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Make weather reflect the world's geography and season. In the base game, weather remains consistent within a climate group for the game day. Travel can reveal different conditions in another group. Returning or loading in the same interval preserves the selected weather. Mods can introduce new conditions and vary how long they last.

## Confirmed requirements

[TIME-005-D01 through D05](../../GAMEPLAY_DECISIONS.md) confirm the DFU baseline weights and climate mapping, shared daily weather, configurable profiles and weather types, retained outcomes, and mod schedules with variable durations.

## Daggerfall Unity reference

Static inspection of the local DFU 1.1.1 Release snapshot. Paths are relative to `Assets/`. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

- `Resources/WeatherTable.json` contains seasonal weights for Desert, Mountains, Jungle, Swamp, Subtropical and Woodlands. `Scripts/Game/Weather/Weather.cs#CompileOdds` normalizes weights and `GetWeather` samples seven weather types.
- `Scripts/Game/WeatherManager.cs#SetClimateWeathers` generates six group results. `Scripts/Game/Utility/StartGameBehaviour.cs` initializes them and `Scripts/Game/Entities/PlayerEntity.cs#Update` refreshes them when it detects a different day. `SetWeatherFromWeatherClimateArray` uses `TravelTimeCalculator.climateIndices` to select the entry for a ready climate context.
- DFU's two mapping paths differ. The climate-array path maps Ocean to Desert and MountainWoods to Woodlands. The direct `WeatherTable.GetWeather` lookup used for polling maps them to Swamp and Mountains respectively. Ordinary polling is commented out. A forced poll remains reachable from the respawn handler.

## Definitions and weighted selection

Use authored climate identity from DATA-006 and a validated climate-to-weather-group mapping. The approved baseline follows DFU's shared climate-array path.

| Weather group | Authored climates |
| --- | --- |
| Desert | Ocean, Desert, Desert2 |
| Mountains | Mountain |
| Jungle | Rainforest |
| Swamp | Swamp |
| Subtropical | Subtropical |
| Woodlands | MountainWoods, Woodlands, HauntedWoodlands |

Ship the seasonal rows from `WeatherTable.json` as baseline content. The base outcomes are Sunny, Cloudy, Overcast, Fog, Rain, Snow and Thunder. For a row with positive total `W`, the probability of outcome `i` is `weight[i] / W`. Select over a stable ordering of weather IDs with half-open cumulative ranges over `[0, W)`. Omitted outcomes have weight zero. Validate a finite positive total and finite nonnegative weights. Zero-weight outcomes are ineligible.

Mods can override mappings and seasonal rows, define weather groups and profiles, and add stable weather IDs for use in compatible rows. Weather IDs can reference validated presentation profiles for TIME-006 and AV. A weather type's gameplay behavior uses approved hooks from the affected owner. A visual property alone supplies no gameplay modifier. DATA-003 governs contribution resolution, validation and locking.

## Base daily schedule

- A group has one result for a calendar date, valid from its midnight inclusive until the next midnight exclusive. On selection use the TIME-001 season at that date. A season boundary at midnight applies to the incoming day. Initialize weather for the starting date even if a character enters mid-day.
- Key retained selections by weather group and date under the resolved profile. Establish the day's group selections as part of simulation or resolve them on first need through the TIME owner. A presentation read or doorway transition cannot replace a result. Travel queries the destination's group for the relevant committed date. Indoors, the underlying outdoor schedule remains eligible to advance with committed world time.
- For a skipped interval, resolve the destination day directly when no applicable gameplay consumer needs intermediate weather. Where an approved consumer needs it, use TIME-004 to supply weather at the required instants. Do not publish retrospective presentation transitions for skipped time. The approved owner rules determine which consequences settle during an advance.

## Mod variable-duration schedule

- Support per-weather duration ranges defined in game hours for eligible weather types. Use validated positive durations representable at native millisecond precision. The default is a uniform choice over the supported whole-millisecond interval, with equal endpoints giving a fixed duration. Validate conversion and the resulting endpoint against the supported clock range.
- Initialize a variable-duration group's first interval at the new character's committed start instant. Select using the active season there. Retain the selected weather and exclusive end instant. At that instant, select the next type using the season then active. Each committed interval begins at the previous interval's end. Calendar day or season changes within an interval leave its committed type and end intact.
- Leaving the group or loading cannot restart the interval. When establishing weather at a later instant, process the elapsed sequence from the retained position, or use a shortcut equivalent to that sequence and any required consequences. Use bounded work under TIME-004. Catch-up covers committed game time only. No weather accrues from wall-clock absence.

## Required data, inputs, outputs and events

Inputs include validated climate identity, committed or due TIME instant, resolved season, climate mapping, profile and schedule data, applicable operation context and a weather-owned random source. Outputs are a retained selection with group, weather ID, profile provenance and validity interval, or an explicit validation or resolution failure. Selection updates are available after commitment. TIME-006 owns how they are applied and presented. Queries and developer inspection do not draw randomness or change retained state. Use RULE-003 purpose separation so observing weather does not consume unrelated gameplay draws.

## Save/load, edge cases and technical constraints

- Preserve selected weather and its interval for retained groups, including those away from the player. Restore those facts before resolving outdoor weather for the restored scene. A compatible load resumes current intervals without rerolling. Unresolved future draws follow RULE-003. TIME-018 and SAVE own restoration sequencing, compatibility and recovery when an active profile or weather ID is removed or changed.
- Missing climate resolution while geography is loading is a pending context. An invalid mapping, missing required seasonal row, unknown weather ID, all-zero row or invalid duration is a classified failure. Validate known required references through DATA-003. Never publish an arbitrary new weather selection to cover unresolved context.
- Consecutive intervals may legitimately choose the same type. The validity interval still advances. TIME-006 decides whether a visible transition is needed. A jump interrupted before an interval boundary cannot commit future weather effects. Use committed clock time for selection and suppress duplicate commitments on retry.
- Keep climate grouping independent of the travel calculator and keep schedule advancement independent of rendering, frame rate and opening or closing windows. Godot representation, exact RNG and serialization remain integration details.

## Acceptance criteria

1. Baseline climate mapping matches the table above. Baseline rows match the shipped JSON, including Desert Summer at 85 sunny and 15 cloudy. A zero-weight entry is never selected. Invalid rows fail validation.
2. Two locations in one group share the daily result. Re-entry and native load preserve it. A climate crossing selects from the destination group without replacing already committed weather for either group.
3. Midnight advances the daily interval once and uses the incoming season. A multi-day jump can resolve the destination day without generating presentation events for skipped days, while required gameplay consumers receive the historical weather they need.
4. A mod can define a new weather ID, reference it in a seasonal row, and associate it with a presentation profile. Its visibility or other gameplay effects require the relevant approved owner hook.
5. A modded interval spanning midnight keeps its selected end. The next interval uses the season at that end. Leaving, returning and loading preserve the active type and end. An optimized catch-up matches the interval sequence's outcome and mandatory consequences.
6. A cancelled advance, unready climate context, visual refresh or duplicate callback cannot reroll a retained result or commit future weather outside the actual elapsed interval.

## Consistency review and outstanding dependencies

The specification follows DATA-006 climate ownership, TIME-001 season rules, TIME-002 commitment, TIME-003 presentation refresh, TIME-004 catch-up and RULE-003 retention and random-source isolation. Exact presentation, gameplay exposure and restore recovery belong to TIME-006/007/018 and their affected owners. Remaining integration details include mod schema and recovery metadata, validation of all baseline row fixtures, RNG representation and owner-declared weather-dependent consequences.
