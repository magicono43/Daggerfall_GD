# ECON-007 — Repair payment and collection

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-007-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-007-interview-decisions).

## Gameplay purpose and intended player experience

Players can submit several possessions in one repair order and see the total fee, what will be repaired, and when each item can be collected. Accepted jobs keep their terms. Players who enable Instant Repairs receive the agreed work immediately.

## Confirmed requirements

Settle the stock repair batch in full under one confirmation with carried gold and eligible carried credit. Use independent per-item schedules for timed work. Include Instant Repairs as a stock option, with timed repair as the default, and support modded repair policies. Award one Mercantile practice point when an eligible order settles, including a free order. Modded practice can use the committed fee and its currency unit. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-007-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#ConfirmTrade_OnButtonClick` deducts the repair fee, ignores the unpaid remainder, and either restores condition immediately under Instant Repairs or calls `UpdateRepairTimes` to start timed work. That scheduler can extend an existing job. Collection and interruption use `TakeItemFromRepair`, which attempts transfer and calls `ItemRepairData.Collect` without an explicit success check. The shared confirmation handler tallies one Mercantile point. These are static source observations.

## Detailed rules and behaviors

1. **Quote the order.** Resolve the authorized repair service and exact item identities. Check ITEM-013/014 repair and custody eligibility. Use RULE-023 for the applicable repair fee and duration. Show scope, item-level fees and completion estimates, total fee, tender, collection and cancellation terms. Full-condition items need no service. An explicitly eligible free repair remains free. Browsing and selection leave items and money untouched.
2. **Settle the whole batch.** Revalidate the original service, item eligibility, accepted terms, full payment and handoff or immediate restoration plan. For stock paid orders, use ITEM-009's carried coins when sufficient, otherwise eligible carried credit first and then coins. Show materially changed terms or tender for renewed acceptance. Flag invalid selections and allow edits. An invalid line or insufficient accepted funds prevents the whole batch from settling.
3. **Timed repair.** Commit payment, custody of the original items and durable job records as one order outcome. Each job retains its own accepted start, duration, scope, fee and completion time. Complete it once through ITEM-014 using game-world time, including authorized wait or travel. New orders leave existing schedules intact. Ready items remain held indefinitely under the stock policy.
4. **Instant Repairs.** This stock option defaults to off. When enabled, quote immediate completion for new eligible orders. Commit full payment and agreed restoration together, leaving the original items with the player without an outstanding collection obligation. Apply normal repairability, scope and lifecycle checks. A setting or policy change during confirmation requires acceptance of the changed timing. Previously accepted timed jobs keep their terms. Mods can supply compatible repair timing and service profiles.
5. **Collection and cancellation.** Use the original stable service and current access. Validate the entire chosen return, including destination admission, before clearing custody. Completed returns carry no additional repair fee and leave the repaired condition intact. Before completion, stock cancellation returns submitted condition without refund after disclosing those terms and validating return. At completion equality, use ready collection. Capacity or temporary closure leaves the item in service custody. Alternate destinations and refund or storage policies require declared compatible profiles under ITEM-014.
6. **Publish and award practice.** Publish acceptance after payment and custody commit, or after immediate restoration and payment commit. Award one stock Mercantile practice point per accepted order, including an eligible free order. Completion, collection and cancellation award no additional practice. A modded award policy can read the final committed total fee and currency unit, including zero. Tie practice to the order so retries cannot duplicate it.

## Formulas, parameters and configuration

RULE-023 owns fee calculation and timed duration for each item. The order total is the checked sum of evaluated fees under the declared repair pricing policy. Timed completion is accepted game time plus the agreed per-item duration under ITEM-014. Instant Repairs quotes immediate completion. Default practice is one point per settled order. Supported mods can configure repair profiles, timing, tender, quoted cancellation and collection terms, and practice through the applicable owner contracts.

## Required data, inputs, outputs and events

Use stable service, location, item, order and job identities, submitted condition, accepted scope and terms, current eligibility and custody, fee and tender plan, completion time and destination admission. Inputs include quote, acceptance, collection, cancellation and game-time progression. Outputs include an actionable rejection, changed quote, committed order, ready job, returned item or explicit recovery. Publish each committed fact through its owner after the corresponding state change.

## Cross-system interactions

ECON-001 supplies authorized service access, including applicable FACT-014 gates. ECON-003 supplies transient selection and confirmation conventions. RULE-023 owns pricing and duration. ITEM-009 owns tender, ITEM-007/008 own return and admission, and ITEM-013/014 own condition, custody and job lifecycle. TIME supplies the clock. CHAR-012 records practice. CORE/SAVE own session and recovery boundaries.

## Edge cases and failure conditions

- An ineligible or stale item blocks submission without charging for other lines. Free eligible work still follows eligibility and acceptance checks.
- Insufficient tender, failed handoff or failed immediate restoration cannot produce a successful order with incomplete fulfillment. Preserve completed facts and explicit recovery obligations if a technical failure crosses a mutation boundary.
- A full destination or closed shop leaves the held item and obligation intact. Permanent loss of the service requires owner-supported recovery preserving the original item.
- Repeated callbacks cannot pay, repair, return, refund or award practice again.

## Save/load and technical constraints

Target Godot 4.7.2. Restore authoritative custody, original identity, accepted terms, tender, progress and committed practice. Reconcile due work through the game clock without repricing, restarting jobs or applying repair twice. Discard transient selections and stale callbacks. Persist required recovery facts at supported save boundaries. ITEM-014 governs temporary save deferral when coherence requires it.

## Acceptance criteria

1. A valid batch settles in full. One invalid line or insufficient tender leaves money, items and jobs unchanged.
2. Timed jobs complete independently and retain accepted terms across travel, settings changes and load.
3. Enabling Instant Repairs quotes immediate restoration for new orders. Successful settlement restores the agreed condition and leaves no collection obligation.
4. Failed collection or cancellation preserves custody. An authorized ready return charges no second fee. Early stock cancellation returns submitted condition without a refund.
5. Each committed paid or free repair order awards one stock Mercantile point. A mod can read its committed fee and currency unit. Subsequent lifecycle steps and retries cannot duplicate the award.

## Compatibility review and outstanding questions

The specification follows ITEM-014's custody and timed repair contract, RULE-023's fee and free-service rules, and ITEM-009's full-tender and renewed-acceptance requirements. Instant Repairs is an explicit immediate service mode for new orders. Exact option scope and persistence, profile interfaces, batch fee fixtures and recovery integration remain open.
