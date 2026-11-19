# ECON-011 — Loan issue and repayment

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-011-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-011-interview-decisions).

## Gameplay purpose and intended player experience

Players can borrow from a regional bank with a clear principal, repayment total and deadline. They can repay in installments or pay off the full balance. After paying off a defaulted loan, they can borrow again if otherwise eligible.

## Confirmed requirements

Stock loans have a 100-gold minimum, one outstanding loan per region, and one game year to repay. Credit the principal to the issuing region's account. Manual repayment at that region's bank uses eligible carried funds before local account funds, supports installments, and caps overpayment before checking affordability. Full repayment restores stock borrowing eligibility while retaining default history and standing effects. These policies support validated mod overrides. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-011-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/DaggerfallBankManager.cs#BorrowLoan` checks the minimum and level-based cap, credits principal, records the repayment amount and sets a one-game-year deadline. `RepayLoan` supports account-only collection and manual repayment using carried funds before account funds. It checks affordability before capping overpayment and clears the due date when repaid. `Game/UserInterfaceWindows/DaggerfallBankingWindow.cs#LoanBorrowButton_OnMouseClick` blocks issuance after regional default or while a loan is outstanding. These observations come from static inspection.

## Detailed rules and behaviors

1. **Quote and issue.** Resolve the authorized bank, issuing region and local account under ECON-001/009. Check the stock regional outstanding-loan limit, positive whole principal, and RULE-024 cap using actual claimed level. Present principal, interest, total due, destination account and the one-game-year term before confirmation. Revalidate eligibility and material terms. Commit the account credit and a distinct loan obligation together. Record the accepted terms and deadline from the commitment time.
2. **Repay manually.** At an authorized bank in the issuing region, accept a positive whole request and cap it at the outstanding debt before planning tender. Show any cap, the exact carried and account debits, and the resulting debt. Apply ITEM-009's spending order within the eligible carried portion. Draw from the issuing region account only for the remainder. Validate the complete accepted payment and recheck exact loan identity, debt, funding and access before commitment. Reconfirm material changes. An insufficient plan leaves funds and debt unchanged.
3. **Apply the deadline.** Partial repayment reduces the outstanding amount and preserves the accepted deadline and rate. Full repayment closes the debt and clears its active deadline. Repayment through the exact deadline is timely. After the deadline, preserve the approved LAW-006 order for account collection and default evaluation. Later manual payments or authorized account collection can reduce defaulted debt. Each payment applies once against the current outstanding amount.
4. **Borrow after default.** An outstanding loan blocks another stock loan in its region, including while defaulted. Full repayment removes that loan's block. Retain historical default facts and leave standing recovery to LAW/FACT. A later loan has its own identity and can independently default. Mods may impose a borrowing restriction based on default history without rewriting the old debt or penalties.
5. **Publish committed outcomes.** Publish issuance, repayment and closure after both the account or tender changes and debt state commit. A failed or canceled request has no settlement effects. Preserve exact committed facts and any unresolved obligation if a technical failure crosses a mutation boundary.

## Formulas, parameters and configuration

Stock principal A is at least 100 gold and at most actual claimed level × 50,000 gold. Total repayment is A + floor(A / 10) under RULE-024. The stock due time is commitment time plus one game year using TIME's game clock. For a positive manual request R and outstanding debt D, settlement amount is min(R, D). Use checked integer currency and time arithmetic. Accepted loans retain their original terms. Mods can vary principal rules, rate, term, eligibility, borrowing scope and repayment tender through compatible profiles.

## Required data, inputs, outputs and events

Use stable player, branch, region, account, loan and operation identities, accepted principal, currency, repayment total, due time, outstanding balance, current tender plan and default history. Inputs include issuance, manual repayment and authorized overdue collection. Outputs include quoted or revised terms, actionable rejection, a committed loan or repayment, closure, or explicit recovery. Preview does not mutate funds or debt.

## Cross-system interactions

ECON-001 supplies service access. ECON-009 supplies regional accounts. ITEM-009 owns carried tender and credit accounting. RULE-024 supplies loan terms. TIME supplies game time and overdue evaluation boundaries. LAW-006 and FACT own default and standing effects. CORE/SAVE govern session and recovery. DATA/MOD validate policy profiles.

## Edge cases and failure conditions

- Invalid amounts, insufficient funds, overflow, unauthorized accounts and stale loan identities reject unchanged.
- A request above the debt can settle at the disclosed capped amount if that full amount is affordable.
- If another settlement or overdue collection changes the debt before acceptance commits, revalidate and present changed terms. A stale request cannot pay a later loan in the same region.
- An account or tender failure cannot yield a successful issuance or repayment with only one side committed. Retries preserve actual completed facts.

## Save/load and technical constraints

Target Godot 4.7.2. Persist accepted terms, issuing account, debt balance, due time, history and required recovery phases. Discard transient confirmations. Restore without repricing, restarting deadlines or replaying credits, debits or default effects. Reconcile overdue work under LAW-006 and TIME.

## Acceptance criteria

1. A valid stock loan credits principal and records its exact repayment and one-year deadline. A second outstanding loan in that region is blocked. An independently eligible region can issue its own loan.
2. A partial payment uses eligible carried funds before the local account and leaves the original deadline intact. Overpayment is capped before affordability and shown before commitment.
3. An exact-deadline payment remains timely. Overdue balances follow LAW-006 collection and default ordering.
4. Paying off a defaulted loan permits a new stock loan in the same region while preserving history and standing effects. Mods can impose stricter eligibility.
5. Rejection, repeated callback and load cannot duplicate principal, payment or loan closure.

## Compatibility review and outstanding questions

The specification follows RULE-024's accepted terms, ITEM-009's tender rules, ECON-009's local accounts and LAW-006's overdue sequence. Exact mod profile schemas, banking UI and durable settlement fixtures remain open.
