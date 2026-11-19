# ECON-004 — Purchase settlement

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-004-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-004-interview-decisions).

## Gameplay purpose and intended player experience

Confirming a purchase delivers the exact selected goods for the accepted payment. If terms change, the player reviews them again. If funds, goods or delivery become unavailable, the player sees the reason while their funds and possessions remain intact.

## Confirmed requirements

Ordinary purchases accept carried gold and eligible carried credit. Deliver to carried inventory by default, with an explicit authorized wagon option available to mods. Failed capacity checks return the player to their basket. A successfully committed paid basket awards one stock Mercantile practice point. Modded award policies can use the committed basket value. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-004-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs` checks capacity when adding items and checks funds before presenting the prompt. `ConfirmTrade_OnButtonClick` recalculates the final price, calls `PlayerEntity.DeductGoldAmount`, raises the trade notification, transfers the basket to carried inventory and tallies Mercantile. The handler ignores the unpaid remainder from `Game/Entities/PlayerEntity.cs#DeductGoldAmount`. The missing check and notification order are verified through static inspection.

## Detailed rules and behaviors

1. **Bind the purchase.** Resolve the accepted ECON-003 offer to its exact items, source quantities, provider or authorized shelf route, payment plan and delivery destination. Revalidate current access and eligibility under ECON-001/002.
2. **Validate full tender.** Apply ITEM-009. Spend carried coins alone when sufficient. Otherwise use eligible carried credit first in stable identity order, then carried coins for the remainder. Preserve a partially spent letter's identity and retire it when exhausted. Wagon or bank funding requires explicit service permission and current access. Show the price, debit, credit valuation and any applicable fees or change. A changed price or materially changed tender requires renewed acceptance before settlement.
3. **Validate the complete delivery.** Use carried inventory by default. A mod may explicitly offer an authorized wagon destination, with its identity, ownership, access and capacity checked at commitment. Check the entire admission plan under ITEM-005/007/008, including any change deliverable under ITEM-009. Apply ITEM-008's restriction on positive-weight intake while overweight. If capacity fails, return to the editable basket with a reason and retain the requested quantities. Delivery into a different destination or partial fulfillment requires a newly accepted selection.
4. **Commit once.** Settle the complete debit, stock depletion and delivery as one purchase outcome. Ordinary validation failure changes none of them. Invalidate stale or repeated confirmation callbacks. If a technical failure crosses a mutation boundary, preserve committed facts and the unresolved recovery obligation under ITEM-007/009. Recovery uses those facts to avoid duplicate debit, delivery or stock depletion.
5. **Publish the outcome.** After payment and delivery commit, expose the completed purchase to eligible listeners. Bind the practice award to the purchase outcome so repeated callbacks or recovery cannot grant it twice. Stock awards one point through CHAR-012 for each committed paid basket. Failed, canceled, previewed and unpaid actions award zero stock practice.

## Formulas, parameters and configuration

Use the final accepted RULE-021 basket price and the ITEM-009 tender plan. Validate full coverage and conserve value using the applicable price units, fees, credit valuation and change rules. For stock practice, the award is 1 for a committed paid basket and 0 otherwise. A modded practice policy receives the immutable committed basket value and its unit, expressed as the final price of the goods with fees, tender face value and change available as distinct payment terms. Mods can use that value for thresholds, scaling or another validated CHAR-012 award policy. Separate stock purchases each qualify independently.

## Required data, inputs, outputs and events

Use the accepted offer and revision, stable purchase, source, item, provider and destination identities, exact quantities, validated price and tender plan, and applicable access and capacity context. Return a committed purchase, updated terms requiring confirmation, unchanged rejection with reasons, or an explicit recovery state. The completed purchase exposes its identity, purchased quantities, destination, committed basket value and payment result. Publication and practice use the committed facts. A listener failure cannot create another purchase.

## Cross-system interactions

ECON-001/002 own access, eligibility and stock source rules. ECON-003 owns basket selection and renewed acceptance. RULE-021 owns pricing. ITEM-005/007/008/009 own item admission, checked transfers and tender. ITEM-021 owns retained stock and refresh. CHAR-012 owns practice recording. UI reports actionable outcomes, and CORE/SAVE govern recovery and session invalidation.

## Edge cases and failure conditions

- If funds or letter eligibility change during confirmation, reject insufficient tender or present the materially changed plan for acceptance. Keep the original item selection available for review.
- Check exact-capacity delivery, cumulative weight, changed carried capacity, and loss of access to a modded wagon. An invalid destination cannot silently redirect goods.
- Access loss, stale stock, duplicate callbacks and failure during output delivery cannot produce payment without goods or goods without payment as a successful outcome.
- A modded purchase with a lawful zero price follows its explicit policy. The stock paid-basket practice rule awards zero for it. Test the deliberate stock incentive to split purchases when evaluating modded value-based awards.

## Save/load and technical constraints

Target Godot 4.7.2. Keep the basket and uncommitted acceptance session-only. Save authoritative funds, goods, stock and completed practice. Where a technical recovery can cross load, preserve operation identity, completed mutations and the remaining obligation. Restore without replaying completed payments, deliveries, events or practice. Keep the settlement boundary independent of UI callbacks. Concrete transaction and save representations remain integration details.

## Acceptance criteria

1. An eligible full purchase debits the accepted tender, depletes the exact source quantities, and delivers the entire basket to the selected authorized destination.
2. Carried coins cover the price alone when sufficient. Otherwise eligible carried letters and coins follow ITEM-009's order. Any materially changed tender requires renewed acceptance.
3. Insufficient funds, invalid stock and failed destination admission leave funds and goods unchanged. Capacity failure returns to the editable basket with a reason.
4. Listeners observe a completed exchange after commitment. Repeat confirmation, load and supported recovery cannot duplicate funds, delivery or practice.
5. A paid purchase earns one stock practice point. A mod can calculate practice from the committed basket value and unit. Failed or canceled offers earn no stock practice.

## Compatibility review and outstanding questions

The specification follows ECON-003's exact basket and renewed confirmation, ITEM-009's tender rules, ITEM-008's capacity and wagon limits, ITEM-021's stock retention, and CHAR-012's practice ownership. Exact payment and transfer integration, practice hook representation, event delivery and save recovery fixtures remain open.
