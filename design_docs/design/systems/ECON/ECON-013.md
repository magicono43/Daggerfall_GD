# ECON-013 — House deeds and ownership

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-013-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-013-interview-decisions).

## Gameplay purpose and intended player experience

Players can buy a local home, use its persistent storage, and later sell it through a local bank. Offers remain consistent across repeat visits within the same listing period. The bank explains when possessions must be removed before a sale can proceed.

## Confirmed requirements

Stock ownership is limited to one house per region. Buy and sell through a bank in the property's settlement. Keep explicit listings and a retained monthly selection of eligible residences. Use DFU's radius-based purchase price and 85% resale, with eligible carried funds before local account funds for purchases and local account credit for sales. Purchase grants the home and fixtures. Sale requires removal of stored and dropped player possessions. Mods can vary these policies and offer disclosed relocation or storage. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-013-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/BuildingDirectory.cs#GetHousesForSale` keeps explicit listings and uses the current month in its seed for supplemental residences. `Game/DaggerfallBankManager.cs#GetHousePrice` uses mesh radius. `PurchaseHouse` combines carried and local account funds, and `AllocateHouseToPlayer` records the house, discovers it, retains its interior and adds a deed note. `SellHouse` credits the local account and removes permanent interior registration without an explicit possession check. `Game/Guilds/KnightlyOrder.cs#ReceiveHouse` uses the shared house allocation path. These are static observations.

## Detailed rules and behaviors

1. **List homes.** Resolve the authorized branch and settlement. Retain authored listings and one supplemental sample for each settlement and game-calendar month using stable identity and owned randomness. Reopening or loading keeps that sample. Revalidate actual sale eligibility for every offer and at settlement, including ownership and quest restrictions. An invalidated home cannot silently be replaced in an accepted offer.
2. **Buy a deed.** Check the selected property, current branch, regional ownership limit, full payment and the ownership and storage plan. Quote the property, price and tender. Apply ITEM-009 within the eligible carried portion, then use the issuing region's local account for the remainder. Reconfirm material changes. Commit payment and ownership together, including the property-specific access and persistent storage facts. Discovery and deed presentation reflect committed ownership.
3. **Allocate a reward.** Use the same property eligibility and ownership boundary for a FACT-017 award. FACT supplies rank, selection and claim eligibility. Coordinate the durable claim with exact-property allocation, with no purchase debit. Insufficient eligible inventory leaves the claim available. Selling the home preserves used claim history.
4. **Handle contents.** The deed grants the property and fixtures. Resolve existing household stock and protected items through ITEM-021, QUEST and their applicable provenance. Player-owned storage stays persistent without automatic household stocking. Before a stock sale, check authoritative property contents, including stored and dropped player possessions. Explain any block and preserve the items. A modded relocation or storage plan must disclose and validate the receiving custody and any terms before commitment.
5. **Sell a deed.** Require the exact owned house, current authorization, a valid disposition plan and the accepted resale quote. Credit the regional account and release ownership, access and owner storage rights together. Preserve protected records and apply the approved contents disposition. Failed validation leaves ownership, funds and contents intact. Publish results only after commitment.

## Formulas, parameters and configuration

Stock purchase price is trunc(validated DFU-equivalent model radius × 1,280) in whole gold. Preserve the radius units used for valuation across asset import and scene scaling. Stock sale price is floor(purchase valuation × 85 / 100). For supplemental listings, use the DFU target of min(floor(building count / 10), 20), filling remaining slots after explicit listings from eligible ordinary residences without replacement. Explicit listings can exceed the target. Mods can vary listing selection and cadence, ownership limits, bank permissions, valuation, tender and contents disposition.

## Required data, inputs, outputs and events

Use stable player, region, branch, settlement, building, container, deed and operation identities, listing period and retained selection, property eligibility, valuation inputs, current ownership, accepted tender or award context, and contents disposition. Inputs include listing query, accepted purchase or sale and authorized reward allocation. Outputs include quotes, actionable rejection, committed ownership change and explicit recovery. Opening a listing spends nothing and grants no access.

## Cross-system interactions

ECON-001/009 supply branch access and accounts. LOC/WORLD supply property identity and valuation context. MOVE-020/022 consume current ownership for access and storage. ITEM-007/009/021 govern custody, tender and storage. QUEST validates protected items and locations. FACT-017 owns reward eligibility and claim history. TIME and RULE-003 supply monthly boundaries and retained draws. CORE/SAVE coordinate recovery, and DATA/MOD validate profiles.

## Edge cases and failure conditions

- A reused building key in another settlement cannot identify the player's house. Stale listing, missing valuation or incompatible contents block the affected trade.
- An unloaded interior must use authoritative persisted contents for the sale check. Unavailable contents require recovery or explicit unavailability.
- An item placed inside after the sale quote blocks commitment. Rejected sale retains access and records.
- An interrupted purchase, sale or reward retains actual completed facts and remaining obligations. Repeated callbacks cannot duplicate payment, ownership, claim use or proceeds.

## Save/load and technical constraints

Target Godot 4.7.2. Persist stable ownership, retained monthly listings, persistent interior contents, award claims and required recovery facts. Discard transient offers on load. Restore access and presentation from authoritative facts without reissuing deeds, payments or rewards. Changed property identities or missing content require explicit compatibility or recovery.

## Acceptance criteria

1. A stock bank offers eligible homes in its settlement. Reopening and loading within the same month preserve the supplemental sample. A player can own one house per region.
2. A purchase uses checked radius pricing and eligible carried funds before the local account. A sale credits the accepted 85% resale amount to that account.
3. Buying grants access and persistent storage for the exact property. Protected and household contents follow their owner policies.
4. Stored or dropped player possessions block stock sale. The player can retrieve them and try again. A supported mod can explicitly relocate them.
5. A FACT-017 award uses the same ownership boundary. Sale and reload preserve the used claim. Stale or repeated operations cannot duplicate funds or ownership.

## Compatibility review and outstanding questions

The specification follows regional account access, specific property identity, ITEM-021 contents provenance and FACT-017 claim history. Exact eligible listing data, imported radius fixtures, ownership-transition disposition profiles and settlement recovery remain open.
