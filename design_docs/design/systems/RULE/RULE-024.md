# RULE-024 — Credit and other service formulas

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Calculate explicit loan terms, room base fees and summoning fee/chance without conflating calculation with eligibility or settlement. Record incomplete blessing behavior without inventing a finished mechanic.

## Intended player experience

Loan/service terms are understandable and moddable. Holidays are counted correctly across rental dates/year boundaries. High reputation cannot reverse a summoning payment through a negative price. Quotes do not borrow money, rent rooms or summon anything by themselves.

## Confirmed requirements

RULE-024-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve baseline loan/summoning formulas, safe exact repayment rounding, explicit rental calendar slots/free days, summoning boundaries and explicit deferral of temple blessing mechanics.

RULE-001 supplies summoning probability semantics, RULE-003 retained draws and RULE-004/DATA-003 validated locked extensions. RULE-021 provides applicable service quote/reacceptance conventions; service-specific free exceptions remain explicit.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateMaxBankLoan` uses player Level×DaggerfallBankManager.loanMaxPerLevel; `Game/DaggerfallBankManager.cs` sets that parameter to 50,000. `CalculateBankLoanRepayment` adds 10% using a floating expression and ignores its region argument. Bank caller accumulates returned repayment in loan records.
- `CalculateRoomCost` charges 7×days, subtracting one day under a narrow day-46 crossing comparison, and shows free-room UI inside the formula. Intended counting/preview separation differs.
- `CalculateDaedraSummoningCost` returns 200,000−1,000×npcRep; `CalculateDaedraSummoningChance` returns 30+daedraRep+bonus.
- `Game/UserInterfaceWindows/DaggerfallQuestPopupWindow.cs` handles payment, weather/Sheogorath substitutions, supplied bonus, success roll and failure consequences. Those broader summoning mechanics are not approved here.
- `CalculateTempleBlessing` returns constant 1 with a TODO; `Game/Guilds/Temple.cs#Blessing` includes unfinished/log-only application branches. Neither establishes completed blessing benefits.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full deadlines/bank eligibility/calendar/summoning and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Loans

Baseline cap C=L×50,000 gold using actual claimed player level L, not earned/unclaimed target. Validate supported positive level/multiplier and safe currency range; cap is an input to bank eligibility, not automatic permission to borrow C in every region or open unlimited simultaneous loans.

For validated positive principal A and nonnegative rate r, repayment R=A+trunc(A×r), default r=1/10 exactly. Use safe exact decimal/rational representation and final toward-zero interest truncation, not binary-float rounding artifacts. Baseline rate does not vary by region; explicit regional rate mods require declared context/policy.

Loan cap/rate/approved formula parameters and hooks are moddable. ECON/LAW own minimum loan, outstanding balances, eligibility, deadlines, partial repayment, interest timing, default and legal consequences. This feature does not approve daily compounding or automatic repricing of existing debt. Owner commitment must capture agreed principal/rate/repayment and enforce its existing-term policy.

### Rental base fees

For n>=1 supported integer days, evaluate n consecutive calendar-day slots beginning with the declared rental date, across month/year boundaries. Base fee=7×number of nonfree slots. Applicable free-day rule includes the retained Heart's Day policy, resolved through explicit calendar/service context rather than copying numeric day-46 arithmetic. Rate and holiday eligibility are moddable.

Count each slot once; multiple covered holidays in longer rentals can each be free. TIME must supply validated calendar dates and bounded iteration/holiday-query support. Unknown calendar/region eligibility is an error rather than silently paid/free. Zero/negative rental days fail rather than creating free entitlement.

All-free base rentals remain free through applicable later bargaining/minimum handling. Mixed rentals charge nonfree slots before owner-declared later pricing; do not add back a charge for free slots. Guild/free-service policies and exact quote stages must be declared by ECON/FACT. Checkout time, room access, extensions, custody and entitlement duration are separate ECON/TIME rules, not inferred from slot accounting.

### Summoning inputs

Baseline raw fee F=200,000−1,000×summoner reputation; normalize valid negative F to zero. Baseline raw chance P=30+selected Daedra reputation+explicit bonus. Use RULE-001 effective 0–100 chance and one owned draw for an authorized attempt, including guarantees. Definitions may provide validated alternative limits/coefficients/hooks; no hidden live reputation clamp is introduced here.

Summoner reputation differs from selected Daedra reputation. Caller must explicitly supply both contexts and bonus provenance. Weather, substitution, date, faction membership, prior summons, selection and source eligibility remain MAGIC/FACT/QUEST policies. Missing context is not reputation zero or a free service.

Zero fee does not bypass eligibility or authorize repeated summons. Payment on a failed attempt, hostile-spawn consequences, cinematic/quest delivery and atomic acceptance are owner rules. Retain any resolved chance for technical retries under RULE-003 rather than rerolling or charging twice.

### Temple blessing boundary

Record source constant 1 as incomplete evidence only. Do not enable a generic +1 stat/reputation benefit, duration or blessing entitlement from it. FACT/MAGIC must approve actual eligibility, donation relationship, effect/target/amount/duration and application lifecycle before that service is implemented. A supported future formula should be moddable under the same validation framework. Explicit deferral is part of this feature's scope, not a fabricated no-blessing gameplay rule.

### Quotes and configuration

Keep formulas pure: no donation, transfer, loan mutation, room-access grant, UI popup or summon occurs during inspection. Use explicit valid actor/service/region/date/purpose context and expose calculation breakdown/provenance through owner UI/diagnostics. Revalidate before commitment; changed final quotes require renewed acceptance under applicable RULE-021 conventions.

Support explicit RULE-004 hooks for declared loan/room/summoning calculations and future approved blessing formulas. DATA-003 locks configuration. Validate finite safe coefficients/rates, currency/count/time domains and output semantics before use; malformed/overflowing values fail explicitly rather than become freebies or silent vanilla defaults.

## Relevant formulas and parameters

- Loan cap=L×50,000; repayment=A+trunc(A/10) by baseline.
- Rental base=7×nonfree calendar-day slots from n>=1 consecutive slots.
- Summoning fee=max(0,200,000−1,000×summoner rep).
- Summoning effective chance=clamp(30+Daedra rep+bonus,0,100), subject to approved mod limits.
- Temple blessing: no complete target formula approved here.

Examples: level 3 cap=150,000; principal 101 repayment=111. Three rental slots with one eligible holiday cost base 14. Summoner reputation 250 computes a negative fee normalized to zero, without authorizing the service. Daedra rep 10/bonus 30 yields 70% before any other owner policy.

## Required data

Actual level; principal/rate/region policy; explicit service/date/calendar/holiday context; rental count/rate; separate summoner/Daedra reputations and bonus provenance; validated parameters/provider identity; owner quote/accepted terms and retained attempt/result state. Concrete schemas/term receipts remain dependencies.

## Inputs, outputs and events

Inputs: valid explicit quotation or authorized probability request. Outputs: cap/repayment/rental fee/summoning fee/chance/result or explicit failure. Blessing returns no invented gameplay quote/application until owner design exists. ECON/LAW/MAGIC/FACT own committed events; APIs/signals are unselected.

## Cross-system interactions

ECON owns banks/rooms/service settlement; LAW debt/default; TIME calendar/entitlements; FACT reputations/benefits; MAGIC/QUEST summoning and blessing design. CHAR supplies actual level. RULE-001/003 govern chance/results, RULE-004/DATA-003 validated locks and RULE-021 applicable pricing conventions. CORE/SAVE protect coherent commitments/restoration; UI/DEV observe without mutation.

## Edge cases and failure conditions

- Pending levels cannot enlarge loan cap; invalid/overflowing principal/cap/rate fails without wrapped debt.
- Year-crossing/multiple-holiday rentals use explicit slots; no-service/invalid duration differs from a valid all-free rental.
- Negative valid summoning fee normalizes, but malformed/missing inputs are errors, not free eligibility.
- Failed or duplicated service delivery cannot repeat fees, loans, entitlements or summon rolls. Recovery belongs to owner transaction contracts.
- Placeholder blessing behavior cannot silently become a permanent stat bonus or substitute for missing approved content.

## Configuration and balancing options

Moddable loan level scale/rates/formulas, room daily rate/free-day rules and summoning fee/chance coefficients/limits are supported through declared schemas/hooks. Regional/affiliation alternatives require explicit inputs. No new compounding rule, legal default policy, summoning failure penalty or donation-to-blessing curve is introduced.

## Save/load considerations

Preserve authoritative accepted loan/rental/summoning facts and owner-required terms/results. Loading cannot recalculate agreed debt from current rates, rerent rooms, replay payment or reroll retained summon attempts. Future quotes use valid restored context. Calendar/policy changes require explicit compatibility/migration; blessing persistence cannot be specified until its owner approves the mechanic. General partial-service recovery remains ECON/MAGIC/SAVE scope.

## Technical constraints

Target: Godot 4.7.2. Use exact safe arithmetic, explicit game calendar slots and separate pure quotations from owner-authoritative actions. Numeric domains/interfaces/serialization remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Loan cap uses actual level and exact repayment truncation with valid domains; no automatic eligibility/compound rule is inferred.
2. Rental counting handles n>=1, year boundaries/multiple free days and preserves explicit all-free outcomes through later pricing.
3. Summoning preserves distinct reputation inputs, normalizes valid negative fee and resolves chance under RULE-001 without bypassing eligibility.
4. Modded parameters/hooks validate explicit purpose/units/domains; missing/unsafe inputs fail instead of granting free services.
5. Queries spend/create nothing, changed quotes require acceptance and owner retries cannot duplicate commitment/results.
6. Blessing placeholder is explicitly deferred with no invented +1 benefit; future formula remains moddable.
7. Restore retains accepted facts/terms/results without payment/entitlement/reroll replay.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-001/003/004/021/023 and DATA-003. Explicit free services remain distinct from ordinary minima; quote calculation does not override eligibility. Half-finished source blessing code is not approved as gameplay. Exact calendar slots replace the narrow source holiday check while entitlement/deadline design remains with TIME/ECON.

## Outstanding questions and approval

No blocking shared-formula policy question remains within this scope. Before implementation: define numeric/mod domains, bank/room/summoning adapters, calendar/holiday/benefit rules, accepted-term transaction/SAVE contracts and MAGIC/FACT blessing specification. Blessing is intentionally deferred; approval cannot authorize its implementation from a placeholder. These dependencies cannot waive safe rates, explicit slots, valid free boundaries or retained accepted facts.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-024-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented service/calendar/transaction integration dependencies and the explicit FACT/MAGIC temple-blessing deferral remain open. Approval does not initiate implementation, coding tasks or another feature review.
