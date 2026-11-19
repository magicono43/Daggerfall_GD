# ECON-012 — Reminders and default

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-012-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-012-interview-decisions).

## Gameplay purpose and intended player experience

Players can review impending loan deadlines and see what the bank collected, whether a default occurred, and what remains payable. Waiting and traveling use the same loan clock as ordinary play.

## Confirmed requirements

Use six-, three-, and one-month stock reminder thresholds, coalescing missed thresholds per loan and time jump. Keep stock reminders out of the HUD. Check overdue loans on game-date changes. Retain collection and default history, and issue an immediate notice for the first overdue outcome and any later collection that moves funds. Support modded timing and presentation. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-012-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/Entities/PlayerEntity.cs` invokes `Game/LoanChecker.cs#CheckOverdueLoans` when the game date advances. The checker detects reminder threshold crossings from remaining game months and shows one HUD reminder per affected loan per invocation. When current game time exceeds the deadline, `OverdueLoan` attempts collection from the regional account and marks default once if debt remains. These are static source observations.

## Detailed rules and behaviors

1. **Reminders.** On a stock date check, evaluate open loans against their accepted deadline and crossed reminder thresholds. Record one current reminder per loan per check in its banking record. Include issuing region, outstanding amount and due date. Stock reminder delivery uses that record. Mark the crossed thresholds handled so later checks and load cannot repeat them. If the time advance ends after the deadline, process overdue settlement and use its outcome notice.
2. **Timing.** Use authoritative game time. Check on a forward game-date change, including a date crossed by waiting or travel. For one elapsed-time jump, evaluate the loan at the reached time and coalesce its missed reminders. A loan is timely through exact deadline equality. An overdue loan can await its next eligible date check.
3. **Collection and default.** At the first eligible overdue check, collect from the issuing region's account under LAW-006. Determine default from the committed remainder after a valid collection outcome, including valid zero available funds. A banking failure enters recovery before default is evaluated. Full first collection closes the debt and avoids default. If debt remains, apply the LAW-006 default effects once. Later eligible checks may collect newly available funds. Full repayment restores stock borrowing eligibility under ECON-011 and retains default history.
4. **Outcome notices.** Record committed collections and defaults in persistent banking history. Issue one immediate notice for the first overdue outcome, showing the amount collected, remaining debt and default or closure status. Later collections that move funds produce a notice and history entry. Later checks with no movement or status change stay quiet. Publish outcomes after settlement and keep notice delivery independent of monetary and standing mutations.

## Formulas, parameters and configuration

The stock reminder offsets are six, three and one game months before the accepted due time. Use TIME's game-month definition. A threshold becomes eligible when reached or crossed by forward game time while the loan remains within its deadline. Stock overdue collection is `min(outstanding debt, available eligible regional account funds)`. LAW-006 owns the default penalties. Mods may change reminder offsets, checking cadence, notice channels including HUD, and compatible collection and default profiles.

## Required data, inputs, outputs and events

Use stable loan, issuing region, account and evaluation identities, accepted due time, previous and current game time, balance, handled reminder thresholds, committed collection and default progress, and notice history. Inputs include authorized time advance, restore and recovery. Outputs include a banking reminder, committed collection, closure or default record, immediate outcome notice, or explicit recovery. Reading the record does not alter loan state.

## Cross-system interactions

TIME and CORE supply chronological evaluation and recovery boundaries. ECON-009 owns account access and balances. ECON-011 owns debt and repayment. LAW-006 and FACT own default consequences and standing. UI presents banking history and outcome notices. SAVE preserves authoritative facts. DATA/MOD validate policy overrides.

## Edge cases and failure conditions

- A jump crossing several reminder offsets creates one current record per loan. A jump beyond the deadline processes overdue debt without emitting outdated reminders.
- A fully funded first collection closes the loan without default. Partial or zero collection leaves the remainder payable and triggers the approved default result once.
- An authorized payment or account change before collection requires current balances and exact loan identity. A loan issued later in the same region has separate reminder and default history.
- Banking or standing failures preserve actual committed facts for recovery. Presentation failures cannot repeat collection or penalties.

## Save/load and technical constraints

Target Godot 4.7.2. Persist handled reminder thresholds, banking history, loan and collection identity, and default effect progress at supported boundaries. Reconcile due checks through TIME and LAW-006 using restored game time. Restore records without replaying notices already delivered, collections or penalties. Use explicit recovery for interrupted authoritative work.

## Acceptance criteria

1. Stock six-, three-, and one-month reminders appear in the banking record. No stock HUD reminder appears. Multiple thresholds crossed during one jump produce one current reminder per loan.
2. Exact-deadline repayment remains timely. The next eligible stock game-date check after the deadline processes an outstanding loan.
3. First overdue collection reports whether the debt closed or defaulted and records the settled amounts. Later funded collections report once. Later unchanged checks stay quiet.
4. Retry and load preserve loan-specific reminder, collection and default facts without duplicating them.
5. A validated mod can configure reminder timing, cadence and presentation independently of the stock defaults.

## Compatibility review and outstanding questions

The specification follows ECON-011's accepted terms and borrowing eligibility and LAW-006's overdue collection and default sequence. It uses the banking record as the stock reminder destination. Exact banking record layout, immediate outcome presentation, and TIME and SAVE integration fixtures remain open.
