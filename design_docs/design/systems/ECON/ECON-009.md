# ECON-009 — Regional coin deposits and withdrawals

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-009-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-009-interview-decisions).

## Gameplay purpose and intended player experience

Players can store heavy coin in a regional bank account and retrieve it from an authorized branch in that region. Before committing, players see which funds will move, the amount the account will gain or lose, and how much coin they can currently withdraw.

## Confirmed requirements

Stock branches share the player's account for their own region. Coin transfers are fee-free. Deposits use carried gold first and draw any remainder from an eligible wagon. Withdrawals deliver to carried inventory and show the maximum currently allowed. Mods can authorize shared or cross-region banking, fees and alternate destinations such as an accessible wagon. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-009-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallBankingWindow.cs` binds the bank window to the current player region. `Game/DaggerfallBankManager.cs#DepositGold` credits the regional balance and debits carried gold before wagon gold. `WithdrawGold` checks the regional balance and carried capacity before giving the requested coins. An exact-capacity withdrawal succeeds. `MakeTransaction` checks region index and emits a transaction result. The direct coin methods lack their own positive-amount checks. These are static source observations.

## Detailed rules and behaviors

1. Bind the operation to the player, authorized branch and stable account identity. In stock profiles, branches within a region resolve the same player account, and branches in another region resolve their own local account. Validate current access at selection and settlement. Any modded remote or shared account route must declare the accounts it can access. Regional loan obligations retain their existing account bindings.
2. Accept positive whole amounts in declared coin units. Validate supported bounds, currency, account and source or destination before mutation. Coin operations use physical coin and account balances under ITEM-009. Letter issuance and redemption belong to ECON-010.
3. For a deposit, plan carried coins first, then the exact outstanding amount from the eligible wagon. Show the amounts drawn from each source and the account credit. If the plan uses the wagon, revalidate the original wagon's identity, ownership, bank access and funds. If the full amount cannot be covered, let the player revise it.
4. For a withdrawal, show the maximum supported by current account funds and admission to carried inventory. Check the full requested delivery again at settlement. If it exceeds capacity or available funds, explain the limit and let the player revise the request. Do not silently reduce the amount or switch destinations. A declared modded wagon route validates its exact destination, access and capacity.
5. Show the account, amount, source or destination and any applicable modded fees before commitment. If confirmed terms materially change, present the new terms for acceptance. Commit coin movement and the corresponding balance change together. An ordinary rejection or cancellation leaves both sides unchanged. Publish a completed transfer only after both sides commit.

## Formulas, parameters and configuration

For a valid stock deposit amount A and available carried gold C, carried debit is min(A, C), wagon debit is A minus carried debit, and account credit is A. The stock withdrawal maximum is the lower of available account gold and the maximum whole coin quantity admitted by ITEM-008/009. The stock account debit and carried credit equal the accepted withdrawal amount. Exact-capacity fills are allowed. Use checked integer accounting and ITEM-009's physical coin weight, initially 2.5 g for stock gold. Account balances carry no weight.

Mods can declare account networks, branch permissions, denomination profiles, source priority, alternate destinations and fees. Quotes must identify the actual account and each accepted debit, delivery and fee. Loan collection remains governed by its owning rules.

## Required data, inputs, outputs and events

Use stable operation, player, branch, region and account identities, current balance and currency, exact amount, source or destination identities, access and limits, and any configured fees. Accept deposit or withdrawal requests and return a preview, revised terms, actionable rejection, completed transfer or explicit recovery. Completed notifications report the committed amount and account. Balance and capacity queries are read-only.

## Cross-system interactions

ECON-001 and NPC-004 supply authorized banking access. ITEM-007/008/009 own checked coin movement, capacity and representation. ECON-010 owns letter conversion. ECON-011 and LAW-006 consume the applicable regional account and own their debt operations. UI shows available funds and limits. DATA/MOD validate profiles, and CORE/SAVE protect session and restoration boundaries.

## Edge cases and failure conditions

- Zero, negative, fractional, overflowing or unsupported inputs fail at the operation boundary, including calls outside the bank UI.
- Stale branch, account or wagon access blocks settlement. An unavailable wagon cannot contribute funds to an accepted plan.
- If a loan collection or another operation changes the balance before commitment, recheck the full amount against the current account.
- A failed delivery cannot leave a successful debit. Duplicate callbacks cannot move funds twice. Technical failures across a mutation boundary retain actual completed facts and an explicit recovery obligation.

## Save/load and technical constraints

Target Godot 4.7.2. Persist regional balances under stable account identities and retain authoritative physical coin counts under ITEM-009. Pending UI requests are transient. Preserve any required recovery state at permitted save boundaries and restore without replaying completed debits, credits or deliveries. Account or region definition changes require explicit migration where applicable.

## Acceptance criteria

1. Two branches in one region access the same stock player balance. A different region accesses its own balance unless an authorized mod policy provides another route.
2. A deposit uses carried gold before eligible wagon gold, shows the planned split, and leaves funds unchanged if the full plan fails.
3. A stock withdrawal delivers the exact amount to carried inventory with no fee. Exact capacity succeeds. Over-capacity or insufficient funds yield a reason and allow revision without partial payout.
4. An authorized mod can offer wagon withdrawal or wider account access and must revalidate the exact destination or account.
5. Invalid amounts, stale requests, retries and load cannot duplicate money or publish a completed transfer without both sides committing.

## Compatibility review and outstanding questions

The specification follows ITEM-008/009's admission and currency contracts, ECON-001's service access rules and LAW-006's regional debt collection. Exact bank-to-wagon access criteria, account and mod network schemas, UI confirmation details and settlement recovery fixtures remain open.
