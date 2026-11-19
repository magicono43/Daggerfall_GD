# FACT-011 — Promotion, demotion, and expulsion

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-011-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-011-interview-decisions).

## Gameplay purpose and intended experience

Guilds recognize improved skills and standing with promotions and can demote or expel members who fall short. Players learn about the decision during a guild visit and see the resulting access to work and benefits. Custom guilds can define their own advancement and expulsion rules.

## Confirmed requirements

- Stock rank review occurs on an authorized guild service visit, before new offers or benefits, once 28 game days have elapsed since joining or the last actual rank change. Use the DFU table and allow multi-rank changes. Rank requirements must be moddable, including for custom guilds.
- Under the ordinary stock policy, failure to qualify for rank 0 at a due review causes expulsion. The Thieves Guild and Dark Brotherhood retain a rank-zero floor. Expulsion rules must be moddable. Explain expulsion, end future member access for that membership, and let accepted quests follow their authored rules. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-011-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Guilds/Guild.cs#UpdateRank` checks whether the current world day is at least 28 days after the last rank change. `CalculateNewRank` returns −1 for negative reputation and otherwise checks the rank rows in order until the first failure. It returns the last passed rank, or −1 if rank 0 fails. `UpdateRank` removes an expelled membership and produces localized feedback. A review with no rank change leaves the timestamp intact. `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#OnPush` calls the review before checking free healing. `Game/Guilds/ThievesGuild.cs` and `DarkBrotherhood.cs` floor the base result at 0.

## Stock rank requirements

Each row requires at least the listed committed standing, one permanent guild skill at or above the high threshold, and a second distinct permanent guild skill at or above the low threshold. Two skills at the high threshold qualify. Equality passes.

| Rank | Standing | High skill | Second skill |
| --- | ---: | ---: | ---: |
| 0 | 0 | 22 | 4 |
| 1 | 10 | 23 | 5 |
| 2 | 20 | 31 | 9 |
| 3 | 30 | 39 | 13 |
| 4 | 40 | 47 | 17 |
| 5 | 50 | 55 | 21 |
| 6 | 60 | 63 | 25 |
| 7 | 70 | 71 | 29 |
| 8 | 80 | 79 | 33 |
| 9 | 90 | 87 | 37 |

## Detailed rules and behaviors

1. Resolve the exact provider, variant and membership set under FACT-009. Review only that active membership. For stock policy, review is due when `worldDay >= lastRankChangeDay + 28`. Joining sets the initial day under FACT-010. A valid nonmember context has no rank to review.
2. Read current committed standing and permanent skills. Apply the configured ordered rank requirements. Stock chooses the highest contiguous passing rank, allowing a promotion or demotion across several ranks at once. Failure at rank 0 invokes the guild's retention or expulsion policy. The stock ordinary policy expels, and the two stock crime guilds retain rank 0. Missing required data produces an unavailable review.
3. Commit any change before new offers or benefits use the resulting rank or membership state. Update the last change day on promotion or demotion. Expulsion removes the exact active membership and records the cause. An unchanged rank leaves the day intact. Feedback describes the committed outcome and never substitutes for applying it.
4. Revalidate access for new member actions using the current membership and rank. Existing quest bindings and committed effects remain governed by QUEST. A quest can explicitly declare how it responds to an expulsion or rank change.

## Approved policy and integration defaults

- Guild definitions may specify rank count and titles, qualifying permanent skills, rank-by-rank thresholds, validated additional requirements such as quest milestones, review interval, and a retention or expulsion rule. Custom guilds may define their own tables and retention rules without editing stock guilds. Policies may specify a supported rank floor or an explicit expulsion predicate. An omitted setting uses the applicable stock policy when the guild declares that policy as its base.
- Validate policy references, unique rank and skill identities, threshold ranges, and ordered requirements. A custom policy with alternate advancement semantics must declare its rank selection rule. Admission remains independently governed by FACT-010 and content must define how admitted members enter the rank table.
- Deduplicate committed rank transitions and their feedback by membership and operation identity. If required review inputs are unavailable, surface the failure before granting new rank-dependent access. A delayed request for an old membership cannot modify a later rejoin.

## Required data, inputs, outputs, and events

Use stable membership, guild, variant and policy identities, current rank, last change day, world day, standing target, qualifying skill values and any declared prerequisite facts. Return not due, unchanged, promoted, demoted, expelled, or an explicit unavailable result. Committed change events include the affected membership, previous and resulting rank or membership status, day and reason.

## Cross-system interactions

FACT-009 resolves membership and provider. FACT-010 initializes ordinary rank and dates. FACT-002 supplies standing, CHAR-011 supplies permanent skills, and TIME supplies the world day. QUEST-002 consumes rank and audience for new offers. Quest conditions may provide prerequisite facts. Service owners consume current entitlements, while FACT-012 handles crime-guild recruitment and FACT-018 handles restoration. UI presents rank outcomes.

## Edge cases and failure conditions

- Day 27 is too early and day 28 qualifies. A late visit reviews current inputs once. An unchanged review leaves a later visit eligible for immediate reevaluation.
- A member can skip intermediate ranks when all intervening requirements pass. At negative standing, a stock ordinary member is expelled and a stock crime-guild member remains at or falls to rank 0.
- A temporary skill bonus or live reaction bonus cannot qualify as permanent skill or committed standing. A missing required standing reference cannot be treated as neutral or as an expulsion trigger.
- An expelled member's open offer or service prompt must pass the consumer's revalidation before any new commitment. Existing accepted work follows its own quest contract.

## Save/load considerations

Persist rank, last change day, exact membership identity, and required transition outcomes. Restore them through FACT-018. Loading does not initiate a review or replay committed membership effects. Incompatible policy changes or removed rank definitions need explicit migration or recovery.

## Technical constraints and consistency review

Separate qualification, committing the transition, and presenting feedback. Preserve FACT-009 variant isolation, FACT-010 fresh rank-zero ordinary admission, and QUEST-002 use of the committed rank. Provider queries without a review trigger remain read-only.

## Acceptance criteria

1. An authorized visit before day 28 leaves rank unchanged. At day 28, exact thresholds qualify. A review with no change does not restart the gate.
2. A qualifying member can advance several ranks. New offers and services see the committed rank. Repeated delivery does not duplicate effects or feedback.
3. At a due review, a stock ordinary member who fails rank 0 loses membership. The stock Thieves Guild and Dark Brotherhood keep the member at rank 0. Accepted quests follow their authored rules.
4. A custom guild can set different rank and skill requirements and choose a different expulsion or retention policy independently of the stock guilds.
5. Save and reload preserve rank, review dates and settled transitions without reevaluating membership during load.

## Outstanding questions

Exact content schema, supported custom predicates and migration format remain integration details.
