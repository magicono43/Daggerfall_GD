# ECON-010 — Letters of credit

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-010-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-010-interview-decisions).

## Gameplay purpose and intended player experience

Players can convert regional bank funds into portable credit and redeem that credit in another region. Before committing, they see the issuance cost or the exact letters and value a bank will redeem.

## Confirmed requirements

Stock issuance requires at least 100 gold in face value and charges a 1% commission rounded down. Authorized stock banks redeem eligible stock letters at their remaining face value, fee-free, into the bank's local account. Stock redemption uses a confirmed Deposit All action. Mods can change issuance terms and redemption acceptance or valuation, and offer selected-letter or partial-face redemption. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-010-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/DaggerfallBankManager.cs#Withdraw_LOC` checks the 100-gold minimum and computes the debit by truncating the requested face value multiplied by 1.01. It debits the regional account before attempting to insert one carried letter. `DepositAll_LOC` removes carried letters and credits their face values to the selected regional account. These findings come from static inspection.

## Detailed rules and behaviors

1. **Issue a letter.** Resolve the current authorized bank and its local account under ECON-001/009. Quote one carried letter with the requested face value, issuance fee and total debit. Validate positive whole units, the minimum, account funds and admission to carried inventory before commitment. Bind the issued instrument to stable identity, issuer, face-value unit and required profile data under ITEM-009. Commit debit and delivery together.
2. **Redeem eligible letters.** Stock Deposit All builds a selection of currently eligible carried letters. Show the selected letters, their remaining face amounts, destination account and total credit before confirmation. Leave ineligible letters with the player. An empty eligible selection produces no transaction. A stock bank accepts eligible stock letters from other regions and credits its own local account.
3. **Revalidate and settle.** Confirm the exact reviewed selection. Recheck branch access, account, instrument identity, custody, remaining face value, eligibility, rate, fees and account admission. Changed selection or material terms require a new confirmation. A stale or invalid line blocks the accepted batch before mutation. Debit the confirmed face amounts and credit the account as one outcome. Retire exhausted letters. Publish completion after both sides commit.
4. **Support modded redemption.** A mod can let players select individual letters or redeem part of a letter. A remaining positive balance keeps the original letter identity. A compatible profile declares issuer and institution or region eligibility, local valuation, units, fees and conserving rounding under ITEM-009. Merchant spending remains governed by the approved tender rules.

## Formulas, parameters and configuration

For stock issuance with face value A in whole gold, require A ≥ 100. Fee = floor(A / 100). Account debit = A + fee. For example, issuing a 199-gold letter debits 200 gold. Stock redemption credits the checked sum of eligible remaining face values, with no fee. The issuance minimum applies to new letters only. Use checked arithmetic and explicit currency units.

Mods can configure issuance minimum, commission and rounding, issuer rules, redemption fee and rate, and redemption selection mode. A modded conversion displays both the face amount consumed and the local credit received. Repeated partial operations must preserve value according to the declared ITEM-009 accounting policy.

## Required data, inputs, outputs and events

Use stable operation, branch, account, instrument and issuer identities, current custody and account balance, face amounts and units, admission state, and the resolved pricing and eligibility profile. Inputs include issuance amount, redemption selection and confirmation. Return quoted terms, revised terms, a rejection reason, a committed conversion or explicit recovery. Quotes and cancellation have no financial effects.

## Cross-system interactions

ECON-001 supplies bank service access. ECON-009 supplies regional account identity and authorization. ITEM-001/007/008/009 own instrument identity, custody, admission and credit accounting. ECON-005 owns sale payout issuance. DATA/MOD validate profiles. CORE/SAVE own session and restoration boundaries.

## Edge cases and failure conditions

- An undeliverable letter, unsupported amount, insufficient account funds or overflowing debit rejects issuance unchanged.
- A carried letter partially spent after preview changes the accepted redemption terms. Reconfirm the current selection and total before consuming any letter.
- A missing required issuer or unsupported rate requires explicit rejection or recovery under ITEM-009. Ineligible letters remain untouched.
- If a technical failure crosses a mutation boundary, retain actual committed facts and the outstanding obligation. A retry cannot mint a second letter, credit redemption twice or double-debit the account.

## Save/load and technical constraints

Target Godot 4.7.2. Persist account balances and authoritative letters with stable identity, issuer, remaining face amount and required profile metadata. Clear pending UI confirmations on load. Preserve supported recovery facts and committed operation identity without replaying issuance or redemption. Resolve incompatible definitions through explicit migration or recovery.

## Acceptance criteria

1. Stock issuance rejects requests below 100 gold. A 199-gold letter costs 200 gold. Failed capacity or funds validation leaves the account unchanged.
2. An authorized stock bank can redeem an eligible stock letter issued in another region at its remaining face value, fee-free, into the local account.
3. Deposit All presents and consumes only the confirmed eligible carried letters. Changes before commitment require fresh acceptance. Ineligible letters remain with the player.
4. A mod can restrict acceptance, change valuation or offer partial redemption. A partially redeemed letter retains identity and a correct remaining amount.
5. Repeated confirmation, supported recovery and load cannot duplicate money, letters or completed conversion events.

## Compatibility review and outstanding questions

The specification follows ECON-009's local account access, ECON-005's credit payout, and ITEM-009's partial spending, issuer metadata and checked conversion rules. Exact issuer and rate profile schemas, confirmation layout and recovery fixtures remain open.
