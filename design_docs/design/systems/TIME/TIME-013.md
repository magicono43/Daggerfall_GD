# TIME-013 — Route time estimation

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-013-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Show how terrain and travel options affect journey time. A land-only trip detours around water if a valid route exists. The estimate gives later travel systems a timeline for weather, exposure and due gameplay events. Quest authors can choose the travel assumptions behind a deadline.

## Confirmed requirements

[TIME-013-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm a moddable DFU timing baseline, endpoint-correct traversal, quest-selectable assumptions, valid land detours, and a timed route result.

## Daggerfall Unity reference

Static inspection of local DFU 1.1.1 Release. `Assets/Scripts/Game/Utility/TravelTimeCalculator.cs#GetPlayerTravelPosition` uses the current map pixel or the ship boarding position. `CalculateTravelTime` walks the major axis, samples climate at stepped cells, and uses integer modifiers for transport, accommodation and pace. Its strict `>` comparison on the shorter axis can leave the final sample short, including at equal nonzero axes. Ocean steps use 51 minutes with ship travel enabled and 255 without it. `CalculateTripCost` reads the accumulated ocean count. The actual placement path is separate. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Route selection

- Use explicit validated origin and destination identities and map positions, selected travel options, transport capabilities, and a resolved route policy. WORLD and the transport owner supply origin context, including an applicable ship boarding origin. The estimator does not infer the origin from whichever scene happens to be active.
- The base route first uses deterministic, endpoint-correct grid traversal. Exclude the origin cell and include the destination cell for an intercell route. A diagonal step is one sample, as in the major-axis source approach. Require each step to be traversable under the resolved geographic and travel-mode rules, including any applicable diagonal crossing restrictions. The route may mix allowed land and ocean segments when ship travel is selected. TIME-014 and transport owners validate embarkation, entitlement and fare rules.
- Where the direct route is invalid, the fallback searches the eligible grid for the least estimated travel-time route, with deterministic tie-breaking. With ship travel off, ocean steps are ineligible. A connected valid land detour is allowed, and no eligible path returns unavailable. Missing geography or a search that cannot establish the answer returns an explicit failure, distinct from a proven absence of routes. Mod policies can replace route selection or timing through validated interfaces.
- A same-cell trip has zero intercell duration and ocean samples. Retain distinct endpoint identities, including different sites sharing a cell. Any same-cell travel admission, local approach time or placement is owned by later travel features or an explicit mod profile.

## Base timing formulas

Use whole nonnegative game minutes for stock step arithmetic, with checked wide intermediates. For a land sample, use `floor(floor(102 × T / 256) × (512 − M) / 256)`. The resolved land transport factor `T` is 128 for horse, 192 for cart, or 256 on foot. If both are applicable, the base rule uses the horse factor. Transport eligibility is supplied by its owner.

| Terrain grouping | Base `M` |
| --- | ---: |
| Desert and Desert2 | 240 |
| Mountain | 220 |
| Rainforest | 200 |
| Swamp | 200 |
| Subtropical | 230 |
| MountainWoods, Woodlands and HauntedWoodlands | 250 |

An eligible ocean step uses 51 minutes. Apply the camping modifier as `floor(300 × step minutes / 256)` when inns are not selected, including eligible ocean steps, preserving the source arithmetic. Sum the resulting steps. Cautious duration equals the sum, and reckless duration equals `floor(sum / 2)`. For reckless travel, halve cumulative step totals and take successive differences for segment durations. This keeps segment sums equal to the quote without discarding a minute at every odd step. Convert the resulting durations to checked native milliseconds with `60,000 ms` per minute. Mod profiles may replace the factors, rates and rounding through explicit validated policies.

## Route timeline and quest assumptions

- Return a stable ordered timeline with step or segment endpoints, terrain, land or ocean mode, duration and elapsed offset. Include ocean sample count and elapsed ocean duration from that route. Adjacent segments may merge if doing so preserves needed timing, geographic and exposure resolution.
- For consumers requiring exposure, supply authoritative region and travel exposure context from WORLD/LOC and the transport policy. Resolve daylight at the applicable timestamp under TIME-007. Split or annotate the timeline where relevant context changes. Covered lodging or shipboard protection requires an explicit owner rule. Missing required exposure cannot be treated as shelter or guessed from the destination. Later travel features own extra arrival waits, completion effects and how a journey stops after an interruption.
- Let quest scripts select a validated estimation profile and supply an authored origin, destination and assumptions such as pace, inn or camp, land transport and ship allowance. Support the stock assumptions and modded profiles. Quest calculations use the authored assumptions even if the player chooses differently. Return duration or an explicit calculation failure to QUEST-010, which owns the multiplier, minimum allowance, and deadline fixed at clock start. An estimate grants no transport or location rights and does not reveal undisclosed route details to the player.

## Data, inputs, outputs and events

Use geographic revision or compatibility context, endpoint IDs and coordinates, climate and traversability data, explicit travel options and capability facts, profile identity, and required timeline context. The result includes a total, ordered duration and exposure data where applicable, ocean statistics, assumptions or a classified failure. Identical valid inputs yield the same result. Estimation has no spending, clock, placement, discovery or random side effects. API and mod schema names remain implementation decisions.

## Cross-system interactions, edge cases and save/load

- TIME-012 supplies the selected disclosed destination. TIME-014 consumes duration and ocean statistics for quote and departure, and TIME-015 consumes the accepted timeline for progression and arrival. TIME-007 and MAGIC-028 use authoritative exposure, and TIME-002/004 coordinate committed time and interruption. WORLD and DATA-006 own geographic inputs. Keep route timing groups independent of weather selection data. QUEST-010 consumes the estimate under the authored assumptions.
- Validate bounds, coordinate arithmetic, unknown terrain and unsupported options, including sea-only destinations with ship disabled. Preserve deterministic ties and bounded search work. A preview does not authorize spending or time. Later owners revalidate route assumptions before commitment when context changes.
- An unconfirmed preview can be rebuilt from valid current inputs. QUEST-010 retains the resolved running deadline across native load and route changes. A supported in-progress travel save needs the accepted route or an equivalent compatible snapshot and its committed cursor. Restore adds zero elapsed time and cannot silently replan a committed interval. TIME-015 and SAVE own compatibility and recovery.

## Acceptance criteria

1. Horizontal, vertical and equal-axis routes include the destination sample. A same-cell calculation returns zero intercell time and still distinguishes the selected site IDs.
2. Base formula fixtures cover each terrain group, horse/cart precedence, ocean cost, camping and cautious/reckless rounding. The sum of reported segment times always equals the estimate, including odd reckless step totals.
3. A route crossing ocean with ship off finds a valid land detour when one exists and otherwise reports unavailable. A ship-allowed route uses only geography and transitions permitted by its policy and reports ocean statistics for the same route.
4. A quest script can choose an authored estimation profile independent of current transport options. Regenerating a map preview or changing transport does not recalculate an already running deadline.
5. A route crossing dawn supplies time-specific authoritative exposure where required. An unavailable required context fails explicitly. Estimation never advances time, spends funds or launches travel.

## Consistency review and outstanding dependencies

The specification fits TIME-012 preview and disclosure, TIME-002/004 advancement, TIME-007 and MAGIC-028 exposure, and QUEST-010 retained deadlines. Detailed grid connectivity, authorized sea transitions, quote adjustments, exact route exposure data and partial-travel compatibility remain owner dependencies.
