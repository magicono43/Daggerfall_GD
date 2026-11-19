# TIME-014 — Trip quote and departure checks

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-014-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Let players understand a trip's duration, price, payment requirements and known risks before they depart. A player can revise the route or decline a warning without paying. If a material term changes, the player sees the new terms and decides again.

## Confirmed requirements

[TIME-014-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm route-based fees and tender, moddable departure restrictions and warnings, and commitment-time revalidation with fresh confirmation for material changes.

## Daggerfall Unity reference

Static inspection of the local DFU 1.1.1 Release snapshot. `Assets/Scripts/Game/Utility/TravelTimeCalculator.cs#CalculateTripCost` rounds total travel minutes up to hours, uses ocean pixel count in the lodging and ship calculations, adds at least one paid inn stay when applicable, and applies guild or ship waivers. `Assets/Scripts/Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs` applies a guild duration modifier, refreshes the quote at Begin, prompts for disease or poison, checks combined funds and carried coin separately, and schedules execution. Its deduction path uses carried gold for inns and ignores the unpaid remainder returned by the generic deduction for the rest. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Quote and base fare parameters

- Use the TIME-012 stable destination and TIME-013 timed route under resolved options. Quote the estimated game duration, lodging and sea portions, charges, eligible waivers, required tender, and departure status. If an approved effect changes duration for pricing or settlement, use the adjusted timeline consistently. Later travel features own any additional arrival waiting and recovery rules.
- **Inns.** The base policy uses one virtual lodging charge at the start of the first positive land leg and one at each additional 24 completed cumulative land hours strictly before the end of land travel. A positive land duration `L` therefore yields `ceil(L / 24h)` lodging slots when inns are selected. Camp, zero land time and sea-only travel yield zero inn slots. Use the region of the priced slot on the timed route, taking the next land leg's region when the slot falls exactly between land legs. Each nonwaived slot costs 5 gold in carried coin. Apply FACT-017 room waivers per priced region. Virtual lodging charges do not create a room booking or confer access. If a profile requires an actual lodging provider, validate it separately.
- **Ship.** The base policy charges `25 × ceil(S / 24h)` gold for positive cumulative sea duration `S` when there is an eligible paid passage. Zero sea time yields zero fare. Waive applicable fare for eligible owned passage or FACT-017 ship privileges. Ownership, route access and boarding remain separate facts. Use eligible carried coin or credit under ITEM-009. The quoted sea portion is derived from the same timeline as the duration. Partial days round upward, with exact multiples charged once per full day. Mods may provide valid alternate units, fee formulas, slot placement and benefit policies.
- Reserve the lodging coin requirement conceptually before evaluating ship tender so the same carried coin cannot fund both lines. Apply ITEM-009 tender selection within the remaining eligible carried funds. Use checked arithmetic and explicit valuation of eligible credit. Bank or wagon funds require explicit authorization. A valid zero fee remains zero. Quoting and previewing hold no funds and perform no payment.

## Departure decision and warning policy

1. Verify the current living actor and session, origin, active exact disclosure at the destination, route and transport eligibility, availability of required context, and applicable owner restrictions. A valid known destination can still be unavailable for fast travel. Failure gives a player-safe actionable reason and does not spend or advance time.
2. Apply MAGIC-028's stock block on ordinary daytime vampire departure. A night departure supplies no immunity from later route exposure. Where the timeline supports it, disclose foreseeable exposure relevant to the character's known vulnerability. Do not disclose hidden conditions or their derived risk. Continue to process applicable effects through TIME-004 and the relevant owners after commitment.
3. Require affirmative confirmation for player-known disease or poison before departure. The warning conveys that the condition can progress in transit. Declining or closing it cancels the attempt without payment. Continue to apply existing hard blocks. A warning acknowledgment covers the relevant disclosed risk facts for that quote.
4. Allow validated mods to define departure restrictions, exceptions, warning rules and text. A mod can use a stable equipment capability and an approved MAGIC/ITEM rule to allow affected actors to attempt daytime travel while wearing qualifying clothing. Departure permission and protection during travel are separate owner decisions. Revalidate the equipment at commitment, and use authoritative exposure and protection rules throughout the trip. Graphics and appearance alone confer no capability.

## Confirmation and commitment handoff

- Present duration, charges and waiver breakdown, required tender and known warnings before final confirmation. Use a stable quote and attempt identity bound to the actor, origin, destination, options, route policy and relevant terms. The rule treats a change to a disclosed duration, route or risk, payable charge, required tender or waiver as material. Refresh and require fresh consent. A hard block prevents commitment even if an earlier warning was accepted.
- Immediately before handing off departure, revalidate the quote terms, warnings, location disclosure, eligibility and payment coverage in the current committed context. Confirm and settle payment through a checked owner operation as part of TIME-015 departure. A failed or incomplete payment leaves all quoted tender and travel state intact. Repeated confirmation or retry must resolve the same attempt without another charge. TIME-015 owns what happens after payment and departure commit, including any applicable recovery or refund rules.

## Data, inputs, outputs and events

Inputs include current session and actor, selected stable destination, route timeline and options, calendar and travel context, benefit and transport facts, eligible tender, owner restriction results and disclosed warnings. Outputs include a quote with itemized costs and tender, material-change or blocked outcomes, consent records and a checked departure handoff. Validation distinguishes an invalid or unavailable quote from a free trip. Queries emit no purchase, discovery or time-advance effects. API and mod schema names remain implementation decisions.

## Cross-system interactions, edge cases and save/load

- TIME-012 supplies exact disclosure and preview, TIME-013 supplies duration and route context, TIME-007 supplies daylight and exposure, and TIME-015 owns execution and arrival. FACT-017 supplies lodging and fare waivers. ITEM-009 and ECON own tender and payment. RULE-021 supplies applicable changed-quote policy. MAGIC, LAW and transport owners supply their applicable restrictions. DATA-003 validates and locks resolved mod definitions.
- Zero-cost quotes still require eligibility and confirmation. Same-cell selection does not establish trip admission. A retired destination, changed route, expired permission, unequipped protective gear, repriced credit or newly known condition requires current validation. No quote can authorize negative charges, duplicate waiver credit or partial spending on a rejected departure.
- Quotes and uncommitted warning UI are transient by default. Restoring a supported preview requires fresh validation and cannot commit payment or travel. Persist any committed departure and payment facts through TIME-015 and SAVE under their supported boundaries. Loading adds zero elapsed time and cannot repeat a debit or warning side effect.

## Acceptance criteria

1. A 24-hour land portion with inns selected yields one base 5-gold slot, and a portion just over 24 hours yields two. A sea-only route creates no inn slots. A 24-hour paid sea portion costs 25 gold, and a portion just over 24 hours costs 50. Verify valid zero fees and no overflow or negative fee.
2. On a route with lodging slots in different regions, apply only each slot's eligible FACT waiver. A ship fare waiver neither creates ownership nor satisfies a missing boarding requirement.
3. A traveler with enough combined funds but insufficient carried inn coin is blocked. A valid mixed-tender payment satisfies lodging and sea charges without double-counting coin. Failed payment leaves all tender and travel state unchanged.
4. Known disease or poison requires consent. Hidden conditions remain undisclosed. Stock daytime vampire departure is blocked, and eligible nighttime departure can warn of route exposure. A modded clothing exception admits only an authorized protected attempt and does not silently remove later hazard checks.
5. Changes to a material term invalidate old confirmation. Lost disclosure or an owner veto blocks departure. Declining a refreshed quote, stale callback or repeated confirmation cannot spend or advance time twice.

## Consistency review and outstanding dependencies

The specification fits TIME-007/012/013, MAGIC-028, FACT-017, ITEM-009 and applicable quote rules. Concrete provider placement, transformed timelines, legal and transport admission details, payment receipts and postdeparture handling remain owner dependencies.
