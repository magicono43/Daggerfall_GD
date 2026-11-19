# ECON-008 — Paid identification

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-008-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-008-interview-decisions).

## Gameplay purpose and intended player experience

Players can ask an authorized appraiser to identify several possessions at once. They see the price and types of information covered before paying. The appraiser immediately reveals the agreed properties while the items stay with the player.

## Confirmed requirements

Use one confirmation and full settlement for the selected batch, with carried gold and eligible carried credit. Flag invalid entries for correction. Charge once per compatible stack under the stock policy and support modded per-unit pricing. Award one Mercantile point per completed order, including eligible free orders. Modded practice can use the committed fee and currency unit. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-008-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs` opens the merchant Identify route. `DaggerfallTradeWindow.UpdateCostAndGold` adds one fee per selected unidentified entry with no stack-count multiplier in that branch. `ConfirmTrade_OnButtonClick` deducts the price, ignores the deduction helper's unpaid remainder, invokes `IdentifyItem` for the entries, notifies trade listeners and tallies one Mercantile point. These are static source observations.

## Detailed rules and behaviors

1. Resolve the authorized service and bind the selection to its exact items or whole compatible stacks. Check current ownership, access, compatible knowledge and appraisable properties under ITEM-019. An entry with no remaining eligible disclosure needs no service. An eligible zero-fee appraisal can still reveal knowledge.
2. Quote line fees, the full total, accepted tender and the categories of information the service covers. Keep the preview knowledge-safe. Ordinary appraisal covers the service's declared scope. Secret properties follow their own disclosure policies.
3. Validate current provider and FACT entitlement, identities, quantities, eligible disclosure, price and full tender before commitment. Use ITEM-009's stock order of carried coins alone when sufficient, otherwise eligible carried credit first and then coins. An invalid line returns the player to the editable selection with a reason. A materially changed scope, fee or tender requires renewed acceptance. Validation failures spend nothing and reveal nothing.
4. Settle full payment and immediate guaranteed disclosure as one operation. Apply observer-specific knowledge to the accepted property scope across each selected compatible stack. Preserve item ownership, condition, charges, powers and contents. Use ITEM-019 for knowledge continuity on splits and merges. Publish committed knowledge and service completion through their owners after settlement.
5. Award one stock Mercantile point through CHAR-012 for each order that settles and reveals eligible information, including a free order. Quotes, cancellations, rejected orders and already-known scope award nothing. A modded practice rule can read the committed total fee and currency unit, including zero. Bind practice to the order so retries cannot repeat it.

## Formulas, parameters and configuration

Apply RULE-023 to each eligible selected entry using its approved base item value. The applicable Witches Festival policy makes the fee zero. Otherwise start at `trunc(25 × V / 256)` and apply the declared guild reduction. Preserve valid zero fees without a purchase minimum or extra bargaining. Charge once for a compatible stack and sum the resulting line fees with checked arithmetic. Mods can declare per-unit pricing, supported fee and tender profiles, disclosure scope, and practice policy.

## Required data, inputs, outputs and events

Use stable order, character, service, provider, item and stack identities, accepted quantities, property and knowledge versions, disclosure policy, applicable guild and calendar context, fees, units and tender. Quote and confirmation can return a blocked outcome, updated terms or a committed identification result. The committed result exposes newly disclosed information through ITEM-019 and the committed fee and unit through the service outcome. Preview has no mutation or practice event.

## Cross-system interactions

ECON-001 and FACT-014 supply service access and applicable entitlement. ECON-003 supplies editable selection and confirmation conventions. ITEM-019 owns property knowledge and disclosure. ITEM-005 governs stack compatibility. RULE-023 owns fees, TIME supplies the calendar, ITEM-009 owns tender, and CHAR-012 records practice. MAGIC-027 owns spell identification.

## Edge cases and failure conditions

- A selected entry learned elsewhere before commitment becomes stale if its accepted disclosure changes. Flag entries that no longer need service and request renewed acceptance for changed terms on eligible entries.
- A stack split, merge, quantity change or custody change cannot redirect a stale confirmation. Different property or knowledge state requires separately eligible entries under ITEM rules.
- Insufficient funds or failed validation prevents the whole batch from settling. If a technical failure crosses a mutation boundary, retain actual completed facts and use explicit recovery without charging or revealing twice.
- Holiday or guild status changes can alter the quote. Revalidate the applicable calendar and entitlement context before payment and disclosure.

## Save/load and technical constraints

Target Godot 4.7.2. Preserve committed character knowledge, payment and practice through their authoritative owners. Discard transient selections and confirmations on load. Supported recovery retains operation identity and completed facts so it cannot replay payment, disclosure or practice. Keep pricing, authorization, disclosure and presentation independently verifiable.

## Acceptance criteria

1. An eligible batch settles under one confirmation. An invalid line or insufficient tender prevents all charges and disclosures.
2. A compatible stack of ten items costs the same to appraise as one equivalent item under stock rules. A mod can apply per-unit pricing.
3. Changed fees, disclosure scope or tender require renewed acceptance. Preview reveals only permitted scope information.
4. A settled paid or free order reveals the agreed eligible properties immediately and awards one point. Already-known scope produces no charge or practice. A mod can read the committed fee and currency unit.
5. Appraisal preserves item custody and mechanics. Load and repeated callbacks cannot duplicate payment or practice or grant additional knowledge.

## Compatibility review and outstanding questions

The specification follows ITEM-019's scoped disclosure, RULE-023's fee and free-service rules, ITEM-009's tender contract and ECON-003's transient selection conventions. Exact disclosure profiles, stack valuation adapters and settlement recovery interfaces remain open.
