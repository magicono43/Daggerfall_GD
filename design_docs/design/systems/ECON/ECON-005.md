# ECON-005 — Sale settlement and credit payout

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-005-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-005-interview-decisions).

## Gameplay purpose and intended player experience

Players know which goods they are selling, what they will receive, and whether the proceeds will arrive as gold or a letter of credit. A completed sale transfers the confirmed basket and delivers the agreed proceeds together.

## Confirmed requirements

Pay the full positive sale amount in carried gold when it fits. Otherwise issue one admissible carried letter of credit for the full amount. If payout fails admission, return to the editable basket with a reason. Show the payout form before confirmation and reconfirm changes. Allow explicitly accepted zero-gold sales without issuing a payout instrument. Every completed stock sale, including a zero-gold sale, awards one Mercantile practice point. Mods can change payout and practice policies and receive the committed sale value for practice calculations. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-005-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#ConfirmTrade_OnButtonClick` recalculates ordinary and magic resale prices, compares carried weight plus the coin payout against capacity, and otherwise creates one carried letter of credit with face value equal to the price. The handler checks coin weight after staging goods and has no equivalent explicit admission check for the letter. It raises the trade event before clearing the staged items, then tallies one Mercantile practice point. These observations come from static inspection.

## Detailed rules and behaviors

1. Bind the accepted offer to the exact merchant, basket, sources, quantities and payout terms. Revalidate current access and item eligibility under ECON-001/002. Carried and wagon items retain their original custody until settlement. Wagon sources require current access.
2. For a positive stock sale, plan the entire amount as carried gold. Evaluate delivery under ITEM-008/009 using the carried load after the authorized removal of the selected carried goods. Removing wagon goods does not lower carried load. If gold cannot be admitted, validate one carried letter whose face amount equals the agreed gold proceeds. Both forms must satisfy applicable weight, entry, issuance and delivery checks. If neither is available, reject the sale and return to the basket with a reason.
3. Show proceeds, payout form and destination before confirmation, including applicable credit terms, fees or splits under a modded policy. Revalidate at settlement. If the final price or material payout terms change, including coin-to-credit or credit-to-coin, show the new terms and obtain renewed acceptance.
4. An eligible basket with zero proceeds may settle after explicit acceptance showing that the player receives 0 gold. Transfer the exact goods to merchant custody and issue neither coins nor a credit letter. Empty or invalid baskets cannot settle.
5. Commit merchant custody and the agreed payout as one sale outcome. Apply ECON-002's disposition rules to sold goods. Ordinary validation failure leaves items and funds unchanged. Publish the sale after both sides commit. Award one stock Mercantile practice point through CHAR-012 per committed sale, including zero proceeds. Bind the award to the operation so retries cannot duplicate it.

## Formulas, parameters and configuration

Use the agreed RULE-021 sale price in its declared currency unit. For positive stock coin proceeds, compute the coin payout's effective weight through ITEM-008/009. The projected carried load for this check is current authoritative carried load less the effective weight of the exact carried goods removed by the sale. Apply the current capacity and all admission rules to that projected state. An exact-capacity fit qualifies. Stock credit face value equals the agreed gold amount. Stock practice is one point per committed sale and zero for any uncommitted offer.

Mods may declare manual payout choice, split payouts, eligible destinations, and payout or practice rules. A modded practice rule receives the committed sale value and currency unit, including zero. Each exposed payout plan must account for the full agreed proceeds under its disclosed terms and satisfy applicable ITEM-008/009 checks.

## Required data, inputs, outputs and events

Use the accepted offer and revision, stable operation, merchant, source, item and destination identities, quantities, price and currency, payout policy, credit issuer where applicable, and current custody, capacity and access. Return a completed sale, changed terms requiring acceptance, an unchanged rejection with reasons, or an explicit recovery state. The committed event exposes the sale identity, transferred quantities, value and payout outcome. A quote, decline or rejection awards no practice and emits no completed sale event.

## Cross-system interactions

ECON-001/002 own route access, seller eligibility and merchant custody. ECON-003 owns editable baskets and renewed acceptance. RULE-021 owns sale valuation. ITEM-007/008/009 own checked transfers, capacity and currency admission. ITEM-021 owns disposition and retained stock. CHAR-012 owns practice recording. UI shows the terms and failures. CORE/SAVE own session and restoration boundaries.

## Edge cases and failure conditions

- A carried item can free room for coin at settlement. The same item in a wagon cannot. Check both paths and exact-capacity cases.
- If full gold fits when quoted but only credit fits at commitment, the player must accept the new form. If credit issuance or receipt also fails, the entire sale is rejected.
- Selling eligible zero-value goods or splitting a selection into separate completed sales can award additional practice. Modded policies can vary awards using committed value.
- Duplicate or stale confirmations cannot transfer goods, pay proceeds or award practice twice. If a technical failure crosses a mutation boundary, retain completed facts and the outstanding recovery obligation.

## Save/load and technical constraints

Target Godot 4.7.2. The uncommitted basket and confirmation are session-only. Persist authoritative custody, currency and credit identity, committed practice and any required recovery facts. Restore without replaying payout, stock transfer or practice. Keep sale validation and publication independent of UI callbacks. Exact operation and persistence schemas remain integration work.

## Acceptance criteria

1. Full carried coin payout succeeds when admissible, including exact capacity. An inadmissible coin plan falls back to one admissible full-value letter. If both fail, nothing transfers.
2. Carried and wagon sources affect the capacity check according to their actual custody, and loss of wagon access blocks the sale.
3. A changed payout form, destination or price requires renewed acceptance. Invalid lines return to the editable basket.
4. An explicitly accepted eligible zero-gold sale transfers the goods, issues no payout, and awards one stock practice point. Coin and credit sales also award one point. The mod policy can receive the exact committed value and currency unit.
5. Listeners observe the completed exchange after commitment. Stale callbacks, load and supported recovery cannot duplicate it or its practice.

## Compatibility review and outstanding questions

The specification follows ECON-002 merchant custody, ECON-003 explicit zero and changed-term acceptance, RULE-021 pricing, ITEM-008 capacity and ITEM-009 credit representation. ECON-004's paid-purchase practice rule remains scoped to purchases. Credit issuer profiles, precise payout and publication interfaces, and save recovery fixtures remain open.
