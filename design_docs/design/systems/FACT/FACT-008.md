# FACT-008 — Regional conditions and market handoff

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-008-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-008-interview-decisions).

## Gameplay purpose and intended experience

Give regions changing public conditions that players can learn about and that authorized content can act on. Local prices respond to provincial and merchant power as time passes. A notice about plague can appear while inns remain open. An explicitly authored quarantine can restrict specified services.

## Confirmed requirements

- Support war, famine, plague, crime waves, temple persecution, witch burnings, and price bands as regional facts. Publish notable starts and ends as eligible regional rumors and notices. A service restriction or quest consequence requires an explicit rule from its owner.
- A due political update reads the last published price bands and commits its power and condition changes before the daily price step. The price step uses the day's committed merchant and provincial power. The resulting bands feed the next political update. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-008-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Entities/PlayerEntity.cs#RegionPowerAndConditionsUpdate` changes regional flags and faction power. It handles famine and plague phases, crime waves, temple persecution, and witch burnings. The political pass counts high and low prices when adjusting merchant power. War flags are set and cleared alongside war transitions. `Update` calls `Game/Formulas/FormulaHelper.cs#UpdateRegionalPrices` on day changes before scanning the elapsed minutes for political updates. The price routine uses merchant and regional power, loops elapsed days per region, and derives price flags. The approved RULE-022 schedule and mutually exclusive bands define the recreation behavior.

## Detailed rules and behaviors

1. Resolve stable region identities and their political and market mappings. Maintain regional condition state with its kind, region, current phase, source, and relevant subject where applicable. War state and outcome come from FACT-006/007. ECON supplies the price band from published price state. FACT owns the remaining political condition facts.
2. Advance due political work on FACT-007's seven-day and 38-day schedule. For a boundary shared with a daily price step, give due politics precedence and preserve power before diplomacy and conditions. Political feedback reads only price bands already published before that boundary. Give ECON the resulting committed merchant and provincial power for the current day's pricing step. A day with no due political work uses the power already committed at its price boundary.
3. Process elapsed days in chronological order, each across RULE-022's stable region order. Interleave political work at its actual boundary. Publish the day's required prices and bands coherently before proceeding to a later boundary that depends on them. A long jump and equivalent smaller advances use the same sequence when other inputs agree.
4. Publish notable condition starts and ends as committed regional facts for NPC-021. NPC-021 owns channel selection, availability, filtering, and expiry. A price-band change can feed regional news through an authored publication rule. FACT-007 supplies war news so projecting a war onto a region does not publish the same transition a second time.
5. Allow services and quests to check relevant current or recorded conditions through their owner's explicit rules. A condition change alone cannot close a service, cancel accepted work, or deliver a consequence. Apply authorized restrictions only to their declared services, regions, and phases. Consumer owners handle revalidation and established obligations.

## Approved integration defaults

- Represent famine and plague with beginning, ongoing, and ending phases. Represent crime waves, temple persecution, and witch burnings as active or inactive by default. Retain the affected temple identity when persecution is active. Public phase changes and price-band crossings may be authored as notable. Duplicate deliveries and unchanged state produce no additional start or end.
- When required daily market work fails, retain committed political results and resume the unsettled market work using the same boundary and committed inputs. Do not advance a later dependent political step past missing price feedback. Follow RULE-022 readiness and recovery for affected trade.

## Required data, inputs, outputs, and events

Use stable region, faction, condition and event identities, optional affected subject, condition phase and provenance, merchant and province power, prior price bands, calendar boundary and settlement progress. Inputs include committed TIME advances, FACT-007 outcomes, authorized condition rules, and ECON's published bands. Outputs include condition transitions, public facts, and the day's committed political inputs for ECON. Report missing required mappings or incomplete settlement explicitly.

## Formulas, configuration, and balancing

RULE-022 owns the daily price formula and thresholds. FACT-007 owns the political cadence. Validated condition policies define eligibility, transition odds, power effects, and public visibility. Service owners configure scoped restrictions and QUEST defines authored consequences. Exact stock condition probabilities, political feedback coefficients, and additional phase policies remain open balance details.

## Cross-system interactions

TIME orders boundaries. FACT-006/007 provide war state and political power. WORLD and DATA provide regional mappings. ECON owns prices, derived bands, and trade readiness under RULE-022. NPC-021 presents eligible public facts. QUEST and service owners decide their responses. LAW owns crime and legal consequences. SAVE restores coherent progress.

## Edge cases and failure conditions

- Simultaneous conditions can coexist. RULE-022 keeps each region's price band mutually exclusive.
- A missing required merchant or province mapping blocks the affected required step unless a validated alternative pricing policy applies.
- A failed market step cannot make partially updated prices available for trade. An already committed political transition is retained and cannot reroll during recovery.
- A skipped visit during travel does not create a local interaction. A regional event may still occur and can be heard later if its news remains eligible.

## Save/load considerations

Persist current conditions, relevant subjects, committed transition identities, political and market progress, and any supported unfinished handoff state. Restore the political facts and last published market bands before dependent work resumes. Resume unsettled work with its retained inputs. Loading alone does not advance time or repost news.

## Technical constraints and consistency review

Keep market state and political state under their respective owners. Publish coherent outcomes before consumers use them. The draft preserves FACT-007 cadence, RULE-022 daily publication and trade readiness, NPC-021 news lifecycle, and existing quest obligation rules.

## Acceptance criteria

1. A plague can start and generate eligible regional news while an ordinary inn stays open. An explicitly configured quarantine can restrict only its authorized services.
2. At a shared boundary, politics reads prior published bands, commits power, and supplies that power to daily pricing. The resulting bands are visible to later politics.
3. Equivalent long and split advances produce the same political and daily market sequence under the same inputs.
4. A failed required daily market step exposes no partial prices. Recovery uses retained political inputs and does not duplicate political outcomes.
5. Reload preserves regional conditions, applicable subject references, published bands and progress without replaying notices or service effects.

## Outstanding questions

Exact condition odds, political feedback coefficients, schema, and TIME ordering with unrelated work remain integration details.
