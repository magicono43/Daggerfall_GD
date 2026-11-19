# ECON-003 — Basket and price quotation

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-003-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-003-interview-decisions).

## Gameplay purpose and intended experience

Players assemble a purchase or sale, review the selected quantities and total, and explicitly accept the offer. They can return from confirmation to edit their selections. If availability or terms change, they can review what changed before making a new choice.

## Confirmed requirements

No or Back from confirmation keeps the editable basket. Clear or leaving trade discards it. The basket records selections and quantities. Settlement changes ownership and balances. Invalid lines remain visible for player review without automatic removal or quantity reduction. Baskets and confirmations are session-only. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-003-interview-decisions).

## Existing Daggerfall Unity behavior

In the local 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs` stages items in temporary collections and `ClearSelectedItems` returns uncommitted items to their collections. `UpdateCostAndGold` builds cost and `GetTradePrice` applies mode-specific pricing, including `FormulaHelper.CalculateTradePrice` for ordinary purchases and sales. `ShowTradePopup` checks purchase affordability and presents a Yes/No prompt when eligible. The Yes handler calls `GetTradePrice` again and proceeds at the resulting price. These are static source observations.

## Detailed rules and behaviors

1. Bind each selection to its direction, stable item or stack identity, original source, and requested quantity. Bind the basket to its authorized merchant and route context. A combined shop menu can select from multiple authorized sources under ECON-001/002. Use canonical ITEM quantities for stacks. Selecting, editing and clearing a line have no item, payment or skill effects. ITEM-021's refresh deferral protects live selections from scheduled replacement.
2. Calculate the current quote for the entire eligible basket through RULE-021. Show the lines, quantities, purchase cost or sale proceeds, and any known barrier to proceeding. Provide the RULE-021 breakdown for inspection. Opening confirmation binds the exact basket revision, source and provider context, direction, and presented terms. Editing the basket invalidates its prior confirmation.
3. No or Back closes confirmation and returns to the editable basket. Clear removes the selections. Leaving the trade interaction discards the basket and invalidates callbacks for it. End or edit the selection using the applicable ITEM-021 refresh boundary.
4. On attempted commitment, revalidate the original route, provider and sources, selected quantities, ownership and eligibility, current pricing context and applicable settlement prerequisites. If a line is invalid, return to the basket with a reason on the affected line. Keep the requested quantity for review. The player decides whether to edit or remove it. No subset settles implicitly. If the entire route is unavailable, explain why and deny commitment.
5. If the basket remains eligible and its final amount changes in either direction, show the updated quote and request renewed acceptance. If the amount is unchanged, authorization and other binding terms still require validation. Pass an accepted, current offer to ECON-004 or ECON-005 for settlement. Settle against precisely the validated selection and terms, with commitment-time checks guarding changes between revalidation and mutation.

## Formulas, parameters and configuration

RULE-021 owns validated unit valuation, regional and quality stages, quantity multiplication, basket summation, direction-specific bargaining and final minima in that order. Use explicit merchant region or approved neutral context and live bargaining inputs. Apply bargaining once to the full basket. Display zero proceeds explicitly and require acceptance. Empty or invalid baskets produce no executable quote. Supported mods may alter pricing through RULE-021 and expose stock through ECON-001/002 without bypassing eligibility or confirmation.

## Required data, inputs, outputs and events

Inputs include stable source, item, merchant and route identities, direction, selected quantities, basket revision and current eligibility, pricing and settlement context. Output a quote bound to the evaluated selection and terms, or a blocked outcome with reasons. Confirmation submits that exact offer for revalidation. A quote, refusal, cancellation or invalidated request emits no trade event or Mercantile practice. Settlement owners publish completed outcomes.

## Cross-system interactions

ECON-001/002 supply current route access, stock sources and eligibility. RULE-021 owns price arithmetic and changed-price acceptance. CHAR and RULE-022 supply bargaining and regional state. ITEM supplies quantity, ownership and retention. ECON-004/005 own final exchange, affordability, capacity and payout policy. UI presents the basket, quote and actionable errors. CORE/SAVE govern session lifecycle and restored state.

## Edge cases and failure conditions

- If five selected potions become three, flag the line and keep the original request visible until the player chooses a revision.
- A provider change, closed route, missing required pricing context or unsupported arithmetic blocks commitment. A coincidentally equal amount cannot authorize a substituted item or provider.
- A callback for an edited or closed basket cannot commit. Repeated confirmation uses the settlement owner's protection against duplicate exchange.
- If an authorized refresh becomes due during a live selection, apply ITEM-021 deferral and revalidation. Canceling a prompt to edit can keep the selection active. Clearing or leaving releases the affected selection.

## Save/load and technical constraints

Target Godot 4.7.2. Baskets, quotes and unresolved confirmations are transient. Loading restores authoritative inventory, balances, stock and committed trade facts, then clears the pre-load interaction and invalidates its callbacks. Durable settlement or recovery state belongs to the transaction owner. Keep quotation side-effect free. Use stable identities and current state checks across UI and any other supported entry points.

## Acceptance criteria

1. No or Back retains the same editable basket. Clear or exit discards it with no payment or inventory movement.
2. Invalid lines display a reason and keep the requested quantity for review. No automatic substitution, partial settlement or quantity reduction occurs.
3. A price increase or decrease requires fresh acceptance. Unchanged price still requires valid source, provider, eligibility and exact terms.
4. Empty and invalid baskets cannot settle. Zero proceeds are explicit before acceptance. Preview and confirmation evaluate the same quantities under RULE-021.
5. Load preserves committed changes and stock depletion, clears the basket, and prevents any old confirmation from settling.

## Compatibility review and outstanding questions

The specification follows the approved RULE-021 arithmetic, ECON-001/002 source and authorization rules, and ITEM-021 refresh deferral. Exact UI presentation, quote identity representation, and settlement integration for funds, capacity, payout and retry remain open for their owners.
