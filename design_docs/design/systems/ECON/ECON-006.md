# ECON-006 — Shop theft alternative

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-006-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-006-interview-decisions).

## Gameplay purpose and intended player experience

Players can attempt to steal a selected basket from an open shop. They see the risk of detection before committing. If caught, the shop keeps the goods and LAW applies the permitted legal response. If undetected, the player receives the selected goods.

## Confirmed requirements

Require stock confirmation before Steal and make confirmation behavior moddable. Count each distinct selected source stack once and weigh only its selected units. Validate the full basket before rolling and flag stale selections for correction. Close the trade window on detection or successful delivery. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-006-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#DoSteal` acts immediately from the Steal button or shortcut when the buy mode has positive staged cost. It uses truncated total weight plus basket entry count and grants one Pickpocket practice point. Undetected attempts transfer goods and award guild credit. Detected attempts register Theft and request guards. Both close the trade window. The handler raises the trade notification before goods transfer on success. `Game/Formulas/FormulaHelper.cs#CalculateShopliftingChance` supplies the detection chance. These are static source observations.

## Detailed rules and behaviors

1. Offer explicit Steal for eligible open-shop shelf selections under ECON-001/002 and LAW-004. Resolve the selected source identities and quantities without changing ownership, stock or funds. Closed and unauthorized shelves continue through MOVE-022 and LAW-004.
2. Show a confirmation identifying the selected goods, quantities and labelled detection risk. Follow RULE-010 qualitative feedback by default and allow the exact percentage setting. The button and shortcut use the same route. No or Back returns to the editable basket. Clear or leaving discards the selection under ECON-003.
3. Before admitting the attempt, revalidate the original shop route, source identities, quantities, item eligibility and capacity for the full delivery. Flag affected lines if the basket is invalid. Explain a lost route or capacity failure and retain the basket for correction while the interaction remains available. Empty, blocked and cancelled attempts consume no draw and award no practice. A selection change invalidates its confirmation. Evaluate risk from the current validated inputs and keep the presented risk current through the confirmation boundary.
4. Resolve one retained LAW-004 detection result for the admitted basket. Detection prevents all delivery. LAW applies the permitted Theft filing and guard response. An undetected result transfers the entire validated basket through ITEM, depletes the original sources and publishes committed acquisition facts. Qualifying guild credit follows actual committed transfer. No payment is involved.
5. Award one stock raw Pickpocket practice point per resolved attempt under LAW-004 and CHAR-012 on either result. Close the shop window after detection or committed delivery. Retain a resolved result if delivery fails technically and use owner recovery without another roll, duplicate practice or premature guild credit.

## Formulas, parameters and configuration

Use RULE-010's stock detection percentage `clamp(100 − S + Q + trunc(W) + N, 5, 95)`, with live Pickpocket skill `S`, validated shop quality `Q`, total effective weight of selected units `W`, and distinct selected source stack or item entry count `N`. Sum selection weight before truncation. Multiple rows referencing one source stack count once. Separate source stacks count separately, including in a combined view. Destination stacking and UI sorting do not change risk. Mods may alter confirmation and use approved RULE-010 and LAW-004 configuration for risk and consequences. A modded immediate action still requires explicit Steal and the same admission checks.

## Required data, inputs, outputs and events

Use stable attempt, session, shop, route, source, item and destination identities, selected quantities, current access and admission context, evaluated weight, entry count, detection input and policy provenance, and retained outcome and completion facts. Inputs are preview, confirmation, cancellation or an explicitly configured immediate attempt. Outputs include labelled risk, actionable rejection, detected result, committed acquisition or explicit recovery. Detection and acquisition outcomes go to their respective owner contracts.

## Cross-system interactions

ECON-001/002 own access and stock source bindings. ECON-003 supplies selection and cancellation semantics. MOVE-022 routes closed or unauthorized shelf interactions. ITEM-007/008/021/022 own transfer, capacity, stock and acquisition facts. RULE-001/003/010 own detection resolution. LAW-004 owns theft consequences and practice policy, CHAR-012 records practice, and FACT-012 consumes qualifying settled deeds. QUEST observes committed acquisitions through ITEM.

## Edge cases and failure conditions

- Three arrows selected from one stack count as one entry and contribute the weight of three arrows. Dividing the same selection across menu rows cannot change either input.
- If stock, capacity or access changes during confirmation, deny an invalid attempt before drawing. Closing time cannot silently redirect the pending attempt to after-hours shelf theft.
- A partial-stack theft can succeed for the entire selected quantity and leave unselected units in the source. An invalid line cannot convert the basket into a smaller attempt.
- Listener, delivery or guard deployment failures preserve already resolved facts and use owner recovery. Repeated callbacks cannot duplicate resolution or its consequences.

## Save/load and technical constraints

Target Godot 4.7.2. Unconfirmed selections and confirmation UI are session-only. Preserve resolved attempt and owner completion facts where an allowed save can interrupt recovery. If coherence requires deferring a save, use the owning save contract. Restore without rerolling detection, repeating transfers or duplicating practice, guild credit, charges or guard requests.

## Acceptance criteria

1. Stock Steal opens a confirmation with labelled detection risk. Cancellation retains the basket and consumes no draw. A validated mod can use immediate Steal.
2. Preview and resolution use the same source-entry counting and selected-weight rules. Split UI rows cannot alter the count.
3. Empty, stale, inaccessible and overweight baskets fail before a roll. Stale lines are flagged and selected quantities remain available for review.
4. One detected attempt leaves all goods with the shop and requests the permitted LAW response. One undetected attempt delivers the full basket and credits eligible committed theft. Either result grants one stock practice point and closes the trade window after resolution.
5. Retry or supported load preserves the resolved result and cannot duplicate consequences.

## Compatibility review and outstanding questions

The specification follows LAW-004's distinct theft routes and outcome timing, RULE-010's risk model, ECON-003's transient selection and ITEM-021's retained stock. Exact risk presentation and refresh timing, effective weight fixtures, mod confirmation profiles and recovery integration remain open.
