# ECON-018 — Travel, summoning and nontrade services

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-018-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-018-interview-decisions).

## Gameplay purpose and intended player experience

Authorized guild and coven providers offer travel, risky summoning, quests, information and rewards. Players can review the destination or cost of an action before committing. Summoning can fail even after payment.

## Confirmed requirements

Stock guild teleportation is free and instantaneous in game time. Preserve stock date and coven selection, weather bonuses and Sheogorath substitution as moddable summoning rules. A disclosed summoning fee pays for the attempt, including a failed roll. Keep eligible coven failure encounters and one quest offer per Daedra. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-018-interview-decisions).

## Existing Daggerfall Unity behavior

In local DFU 1.1.1, `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#DoGuildService` dispatches separate specialized routes. `DaggerfallTeleportPopUp.TeleportAway` moves to the selected map destination without a fare or elapsed travel charge in that path. `DaggerfallQuestPopupWindow.DaedraSummoningService` selects by date or coven. Its confirmation handler charges before substitution and the success roll, may spawn hostile foes on a coven failure, and checks and records prior successful summons before offering a quest. These are static source observations.

## Detailed rules and behaviors

1. **Authorize the service.** Use the exact provider, location, guild or variant and applicable FACT-014 policy. Preserve stock Mages Guild rank 8 for teleportation and rank 6 for summoning. Revalidate at commitment. Quest offers, spymaster information and order rewards dispatch to QUEST, NPC and FACT respectively. Those owners handle access, disclosure and fulfillment. Opening the route grants no reward or quest acceptance.
2. **Teleport.** Confirm the exact eligible map destination. Revalidate the provider, route and arrival readiness through the travel and placement owners. Stock teleportation quotes zero fare and adds zero travel time. Commit only a validated transition. Modded fares, destination restrictions and elapsed time are explicit quoted terms. A failed arrival uses travel-owner recovery.
3. **Select a summoning target.** Ordinary providers use the declared stock date table. Glenmoril uses Hircine as its base selection. Other covens use the retained daily stock selection from the eligible pool. For the stock shared coven selection, retain one result per player and game date across openings, coven visits and load. An ineligible date or unresolved required context yields an explanation. The base selection remains subject to the disclosed substitution rule.
4. **Quote and admit an attempt.** Show the provider, fee, that a failed roll retains payment, and relevant risk and consequences. Use RULE-024 and authorized service context. Revalidate the accepted terms, calendar, target eligibility, provider, weather inputs and full tender before commitment. Material changes require renewed acceptance. An authorized zero-fee attempt still requires confirmation. Commit the fee and retained attempt before resolving its outcomes.
5. **Resolve the attempt.** Use an owned retained substitution draw, then one RULE-024 success check for the resulting target. On failure retain the accepted payment and dispatch the stock hostile encounter only through the eligible coven failure policy. On success consult the actual Daedra's summon history. A first success records the summon and hands off the corresponding quest offer once. A later success uses the repeat outcome. QUEST owns offer availability and acceptance. Keep any unfinished authorized delivery recoverable without a second fee, draw or grant.

## Formulas, parameters and configuration

RULE-024 supplies fee `max(0, 200000 − 1000 × summoner reputation)` and chance `30 + actual Daedra reputation + applicable bonus`, bounded under RULE-001. Use stock Sheogorath substitution of 5%, or 15% when storming. The stock bonus is 30 percentage points when the resolved Daedra's declared rain, thunder or unconditional bonus applies. Evaluate it after substitution. Use checked arithmetic and RULE-003 owned draws. Mods can vary provider eligibility, calendar, coven pools and scope, weather, substitution, compatible failure consequences and teleport policies.

## Required data, inputs, outputs and events

Use stable provider, service, guild, destination, Daedra, offer and operation identities, exact calendar and weather context, reputation, retained daily target, accepted tender and fee, prior successful summons and outcome progress. Inputs include route requests, confirmations and owner continuation. Outputs include eligible routes, actionable denials, changed terms, completed travel, resolved summoning outcomes, owner handoffs or explicit recovery. Quotes have no payment or fulfillment effect.

## Cross-system interactions

ECON-001 and FACT-014 provide authorized routes. RULE-001/003/024 provide formulas and retained result semantics. ITEM-009 owns eligible tender. TIME/LOC/WORLD own calendar, travel and arrival. FACT supplies reputation and order rewards. QUEST and NPC own quest handoff and information. Encounter owners handle authorized coven spawns. CORE/SAVE retain coherent operations, and DATA/MOD validate profiles.

## Edge cases and failure conditions

- Lost rank, changed date or invalid destination can block a stale confirmation before movement or payment.
- Failed payment creates no summoning attempt. A valid failed roll keeps the fee. A technical failure resumes recorded work.
- Sheogorath substitution uses his own reputation, bonus policy and summon history. Reopening a coven service cannot reroll its daily base selection.
- A missing quest mapping or failed encounter placement follows explicit owner recovery. Neither condition authorizes another charge or draw.

## Save/load and technical constraints

Target Godot 4.7.2. Persist daily selections, committed fees, retained draws, successful summon history and required owner continuation facts. Transient confirmation is session-only. Restore settled facts without replaying travel, costs, rolls, quest offers or encounters. Preserve outstanding authorized work at supported save boundaries.

## Acceptance criteria

1. Stock guild teleport validates provider and destination and adds no fare or game travel time. Invalid arrival cannot report success.
2. Stock ordinary providers use their date tables, Glenmoril defaults to Hircine, and other covens retain the shared daily selection across reopening and load.
3. Substitution uses the accepted stock weather odds. The actual target supplies its reputation and applicable bonus for the single success check.
4. An admitted failed attempt retains payment and invokes only eligible coven failure consequences. A first successful summon hands off its quest offer once. Retry cannot repeat payment or draws.
5. Quest, spymaster and reward routes retain their approved owner gates and results. Mods can change the declared travel and summoning policies.

## Compatibility review and outstanding questions

The specification follows FACT-014 gates, RULE-024 terms, ITEM-009 settlement and the approved quest, information and reward contracts. Detailed date and coven pool fixtures, encounter and travel integration, and native recovery schemas remain open.
