# ITEM-009 — Gold and credit representation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Represent and settle physical currency and credit without value/weight duplication or implicit access to unavailable funds.

## Intended player experience

Players see which funds a service accepts and what a payment consumes. Physical money retains weight and ownership through pickup/drop. Mods can introduce copper/silver/gold/platinum denominations and issuer-specific regional credit without losing saved funds or creating value through rounding/retries.

## Confirmed requirements

- **ITEM-009-D01:** Physical coins, letters of credit and bank balances remain distinct. Each payment explicitly declares accepted forms and locations. Combined available-funds display does not imply universal interchangeability or wagon/bank access.
- **ITEM-009-D02:** Support convenient carried coin balance and physical container/world coin stacks as representations of the same currency. Checked pickup/drop/wagon conversions conserve value and avoid double-counting value or weight. Credit letters remain distinct item instances.
- **ITEM-009-D03:** Ordinary payments validate the full accepted amount before spending. Insufficient funds reject unchanged. Partial repayment/installments require explicit ECON policy, not generic deduction side effects.
- **ITEM-009-D04:** Currency must support modded denominations, including possible copper/silver/gold/platinum coins. User requested smaller denominations than gold; exact ratios, weights, change-making and representation remain unresolved. These examples do not adopt a universal exchange table or add them to vanilla automatically.
- **ITEM-009-D05:** Vanilla remains gold-only. Mods define stable denomination IDs and positive integer values in a declared smallest accounting unit. Ratios are explicit, not hard-coded to 100. Existing gold-based prices use an explicit conversion mapping; no floating-point monetary arithmetic.
- **ITEM-009-D06:** Track carried counts per denomination behind the convenient balance display. Each coin type has validated weight; equal value need not imply equal weight. Denomination changes are explicit exchanges, not automatic relabeling/weight reduction.
- **ITEM-009-D07:** Payments declare exact-tender or accepted-overpayment-with-change policies. Change must be deliverable, capacity-checked and included in the full settlement plan. No silent donation, invented change supply or automatic denomination conversion unless the service's declared policy permits it.
- **ITEM-009-D08:** Ordinary services accepting coins/credit use carried coins if sufficient for the whole price; otherwise carried credit first then coins. Wagon/bank funds require explicit permission. Mod denominations use declared deterministic tender selection, independent of sorting.
- **ITEM-009-D09:** Credit letters are partially spendable: reduce selected face value while preserving identity; zero value removes/retires the letter. Eligible letters selected by stable identity. ECON owns issuance/redemption/fees/acceptance. Required mod support includes issuer/region/institution-specific letters with location-dependent acceptance/value, such as Wayrest credit valued differently in Sentinel versus Betony; exact valuation/accounting rules remain unresolved.
- **ITEM-009-D10:** Before confirmation show price, selected forms, change/fees and resulting debit. Changed quote or materially changed payment plan requires renewed acceptance. Rejection/cancellation spends nothing except earlier costs explicitly committed under an approved action.
- **ITEM-009-D11:** Letters retain issuer, face-value unit and remaining face amount. Services separately resolve acceptance/local settlement value. Travel or a different local rate cannot itself rewrite remaining face amount.
- **ITEM-009-D12:** Use explicit integer/rational valuation rates and declared rounding. Quote face amount consumed and local value credited including fees/change. Repeated tiny payments cannot manufacture value through rounding; unsupported conversions reject rather than silently approximate.
- **ITEM-009-D13:** Valuation may depend on issuer, receiving institution, region and other explicitly supported context. Revalidate rates at commitment; material changes require renewed acceptance. Unknown issuer/unavailable valuation rejects/errors explicitly, never assumed 1:1 face-to-gold value.
- **ITEM-009-D14:** Vanilla gold coin initial weight is 2.5 g, with validated per-denomination overrides. Letters have their own physical item weight independent of face amount. Bank balances add no carried weight.
- **ITEM-009-D15:** Validate complete debit/output/change/capacity/recipient plan before commitment. Ordinary rejection leaves funds/items unchanged. External partial commitment retains exact facts and explicit recovery; retries cannot mint coins, duplicate letters or charge twice.
- **ITEM-009-D16:** Save denomination counts, letter identity/issuer/face amounts, required valuation metadata and committed facts. Changed definitions/missing issuers require explicit migration/recovery, not silent 1:1 conversion or lost funds. Load cannot reissue credit, replay payment or accept old-session callbacks.

User confirmed D01–D03 with “1. Yes / 2. Yes / 3. Yes” to the first interview, adding: “I'd like this currency system to allow for modding, say if somebody wanted to make smaller denominations than just gold coins, say copper, silver, gold, platinum, that sort of thing if it makes sense.” See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D05–D07 with “1. Yes / 2. Yes / 3. Yes”. These resolve D04's denomination representation/value/change framework without choosing concrete mod ratios or coin weights.

Third interview confirmed D08–D10; the user added issuer/region/institution-specific credit valuation as a required mod capability. This does not select exchange rates or change vanilla credit acceptance automatically.

Fourth interview confirmed D11–D13 with “1. Yes / 2. Yes / 3. Yes”.

Fifth interview confirmed D14–D16 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/PlayerEntity.cs#GetGoldAmount` sums carried numeric gold and carried credit letters. `DeductGoldAmount` spends coins if sufficient alone; otherwise credit letters then coins, potentially spending partial funds and returning unpaid remainder. Partial letters retain reduced value, exhausted letters are removed.
- `Game/Items/ItemCollection.cs#GetCreditAmount` sums matching credit-item values. `Game/Items/ItemBuilder.cs#CreateGoldPieces` constructs coin items.
- `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#DropGoldPopup_OnGotUserInput` validates requested carried coins, may reduce quantity to wagon-fitting amount, inserts a coin item then separately deducts carried balance.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; reference source unchanged.

## Existing approved constraints

ITEM-008 counts physical carried currency weight exactly once, separate from nonphysical balances/wagon contents; supports coherent precision and capacity admission. ITEM-001–007 govern identity/custody, actual state, checked transfers, conservation and no-replay recovery. RULE-021 owns trade price calculations, not payment form/access. ECON owns banking, conversion/service pricing and authorized settlement policies.

## Detailed rules and behaviors

### Currency forms and denomination identity

Keep physical coins, credit instruments and bank accounts distinct. Services declare accepted forms, locations and applicable access. Carried available-funds summaries cannot imply acceptance of every letter or access to wagon/account balances. A nominal total differs from a service's spendable local value; incompatible face units cannot be added without explicit conversion.

Vanilla has gold coins only. Mod profiles define stable denomination IDs, positive integer values in a declared smallest accounting unit, physical weights and explicit mapping from approved gold-priced formulas. Ratios are not hard-coded to 100. Smaller denominations do not automatically reprice existing gold formulas, change RULE-021 minimum prices or introduce extra vanilla coins.

Use integer counts and monetary accounting; rational valuation rates are explicit numerator/denominator mappings, not floating-point balances. Validate supported bounds, units and overflow. Concrete fractional rate/rounding schemas remain owner work; a matching display name or enum position cannot identify a currency.

### Physical coins and weight

Track carried counts per denomination behind a convenient balance display. Physical world/container stacks and carried counts represent the same currency through checked pickup/drop/wagon operations. Conserve denomination counts/value during simple representation changes, count custody/value/weight once, and apply ITEM-005–008 stack/cap/access/transfer admission. A balance entry is not permission to create another physical stack without debit.

Initial vanilla gold weight is 0.0025 kg per coin. Each mod denomination has its own validated weight; equal monetary value does not imply equal weight. Changing denominations requires an explicit exchange, not weight-reducing relabeling. Letters have their own physical weight independent of remaining face amount; nonphysical accounts have no carried weight. ITEM-008 precision and weightless/admission rules apply.

### Payment plan and selection

Payments declare accepted forms, source locations, price unit, fees, tender/change policy and recipient. Ordinary payment validates full accepted funding before spending; insufficient accepted funds reject unchanged. A valid zero-price/free action follows an explicit owner policy rather than a negative/invalid amount fallback. Partial debt repayment/installments need explicit ECON policy.

For ordinary services accepting carried gold and credit, use carried coins if sufficient for the full price; otherwise accepted carried credit letters first, then coins. Eligible letters use stable identity ordering. Mod denominations use an explicit deterministic tender-selection profile, independent of UI sorting. Exact coin subset/change algorithm is a required profile dependency, not an implicit greedy or optimal-value algorithm. Wagon/accounts require explicit service permission and current access.

Support declared exact tender or accepted overpayment with change. Change supply, recipients, denomination conversion permissions, delivery and capacity belong in the complete plan. No silent donation or invented change supply. A service may explicitly authorize conversion or generated change through its approved ECON policy; this feature does not assume merchants have infinite physical reserves.

Show price, selected forms, face amounts consumed, local value credited, fees/change and resulting debit before confirmation. A changed quote or material payment-plan/rate change requires renewed acceptance. Cancellation/rejection spends nothing except a separately approved action's earlier committed cost. Confirmation does not grant permission to bypass access, funds or item output checks.

### Credit letters and local valuation

Letters are distinct instances carrying issuer identity, face-value unit, remaining face amount and required provider/version data. Partially spending preserves identity and deducts the quoted face amount. Exhaustion removes/retires the letter under ITEM-001; do not retain a zero-face live instrument. Issuance, redemption, transfer restrictions, fees and eligibility remain ECON/ITEM owner profiles.

Required mod capability includes region/institution-specific credit: Wayrest-issued credit can have different acceptance/local value in Sentinel and Betony. Keep face amount separate from contextual settlement valuation. Travel, display or rate changes do not rewrite face amount or mint new credit. No particular rates or extra vanilla issuer restrictions are adopted.

Valuation profiles may depend on declared issuer, receiving institution, region and other supported context. Use explicit integer/rational rates and rounding, quoting face debit/local credit/fees/change. Validate conversion domains and prevent value creation by repeated tiny-payment rounding. Concrete conserving rounding/residual mechanisms require an explicit profile; unsupported conversion rejects rather than approximating. Unknown issuer or unavailable provider/rate is an explicit rejection/error, not assumed 1:1 acceptance or empty wallet.

Vanilla gold face values remain expressed in gold units; baseline ordinary accepted credit follows the gold-value payment path, without inventing regional discounts. This does not grant universal service acceptance. Mod adoption of new face units/rates needs explicit compatibility for existing instruments.

### Commitment and recovery

Validate complete debit, outputs, change, recipient access, capacity and item identity before ordinary settlement. Revalidate funds, rate/context and session at commitment. Rejection leaves original funds/items unchanged, including letters and physical denomination counts. Outputs cannot be published as successful if required payment or delivery failed.

Coordinate external item/service/reward operations through their approved contracts. If a boundary partially commits, retain exact completed debits/credits/grants and explicit recovery obligations instead of retrying the whole operation or promising unsupported refunds. Retained operation identity prevents repeated callbacks from charging, minting or issuing twice. No generalized ledger/transaction framework is mandated; truthful conservation and no replay remain required.

## Relevant formulas and parameters

- Physical coin value = sum(count[d] × unitValue[d]) in the declared accounting unit, using checked integer arithmetic.
- Physical coin weight = sum(count[d] × weight[d]); vanilla gold weight = 0.0025 kg.
- Local credit conversion uses an explicitly declared rational rate, e.g. faceDebit × numerator / denominator, interpreted with approved unit conversion/rounding/fees. This expression does not select floor/ceiling or a residual policy.
- For an ordinary completed settlement, accepted local tender equals price plus declared fees plus delivered/credited change, with units explicitly reconciled. Account/credit issuance/redemption obligations follow their owner rules rather than pretending every financial operation conserves physical coin counts.

No mod denomination ratios, regional exchange values, credit fees/weights, tender algorithm or universal residual rule are chosen here. Existing RULE price formulas retain their approved gold meaning through explicit mapping.

## Required data

Stable currency/denomination/issuer/institution/region identities; accounting/face units and gold-formula mapping; denomination counts/weights and authoritative custody; letter ID/remaining face amount/provider/version; accepted form/location policies; valuation rate/rounding/provenance/context; quote/debit/fees/change/recipient plan; account owner references and committed operation/recovery facts. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: pure value/weight/accepted-funds queries; explicit pickup/drop/exchange/payment/credit use requests; owner quote/access/rate/output results; restored state. Outputs: contextual accepted value or distinct error, complete quote, checked committed settlement/conversion, or explicit unchanged rejection/retained recovery. Queries/display do not issue money, redeem letters or change face values. Notifications report committed facts and cannot repeat debits/grants. Concrete APIs/signals remain unselected.

## Cross-system interactions

ITEM-001–007 own identity/custody/state and checked movement/removal; ITEM-008 owns effective weight/precision/capacity and wagon access. RULE-021 and other approved price owners retain pricing semantics distinct from tender/valuation. ECON owns banks, service acceptance/fees, issuance/redemption, accounts, debts and exchange profiles. DATA/MOD validate currency/issuer/provider identity and compatibility. UI shows meaningful denomination/payment information; LAW/QUEST retain provenance/restrictions. SAVE/CORE restore scoped financial state without replay.

## Edge cases and failure conditions

- Nominal wealth sufficient but accepted local funds insufficient: reject unchanged, explain accepted funds rather than total wealth.
- Exact-tender subset unavailable or change cannot be delivered: reject unless explicit alternate policy is accepted.
- Coin pickup/drop representation change: no duplicate count/weight; capacity and custody revalidated.
- Foreign credit revalued by region: keep face amount unchanged until authorized spend/exchange, reaccept materially changed plan.
- Unsupported rate/issuer/overflow: explicit error, never 1:1 fallback or partial unintended deduction.
- Tiny repeated conversions: no positive-value rounding exploit under supported profile.
- Exhausted letter: retire once; partial letter retains identity and remaining face amount.
- Grant/payment partial technical failure: retained recovery without repeated money issuance/spend.

## Configuration and balancing options

Required mod support covers denominations/ratios/weights, explicit gold mapping, accepted forms/locations, issuer/institution/region valuation, tender/change and compatible rounding policies. Concrete profiles must be validated before support is claimed. Gold-only vanilla and approved spending order remain baseline. No universal currency exchange market, bank access, credit forgery/authenticity mechanic, interest rate or merchant reserve model is introduced.

## Save/load considerations

Persist denomination counts, physical currency custody, letter identities/issuers/face amounts/units, required valuation compatibility metadata and committed operation facts. Rate queries may reflect current authorized context; retaining metadata does not freeze all future exchange rates. Material quote changes still require acceptance.

Changed denominations/face units/issuers or missing required providers need explicit migration/recovery; never silently convert 1:1, discard funds or reissue letters. Preserve resource/weight identity and correct gold mapping. Native load cannot replay payments, mint coins, refill face amounts or accept prior-session callbacks. Coherent/pending save boundaries follow ITEM-002/007 and applicable ECON actions; exact schemas/migrations/residual state remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate monetary units/counts, physical representations, contextual acceptance/valuation, pricing and owner settlement. Use checked integer/rational arithmetic and stable domain IDs, not floating-point money/class names/UI order. No universal ledger architecture or particular denomination packing algorithm is mandated. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Gold-only vanilla and mod denomination counts/values/weights remain distinct from credit/account forms with explicit gold-price mapping.
2. Pickup/drop/wagon conversion conserves physical currency and counts value/weight once with admission enforced.
3. Ordinary insufficient payment rejects unchanged; partial repayment requires explicit owner policy.
4. Baseline accepted carried coin/credit order and stable-ID letter selection work; mod tender selection is deterministic and wagon/account sources require permission.
5. Exact-tender/change policies quote and validate complete output/capacity/supply without silent donation or invented conversion.
6. Partial credit use retains identity; exhausted letters retire. Foreign/regional value changes do not alter face amount automatically.
7. Supported issuer/institution/region rates use declared integer/rational conversion/rounding without tiny-payment value creation; unsupported issuers/rates fail explicitly.
8. Confirmation shows price/forms/face debit/local credit/fees/change; material changes require renewed acceptance.
9. Settlement/recovery cannot double-charge, mint/issue twice or lose committed obligations; ordinary rejection leaves original state intact.
10. Native restore preserves funds/instrument identity/units and compatibility without silent conversion/discard/replay or old-session callbacks.

## Contradiction review

Reviewed against approved ITEM-001–008 and RULE-021, with ECON ownership boundaries from the analysis. No direct contradiction identified. Currency exchange is explicit rather than a transfer weight shortcut. Finer denominations map existing gold formulas without silently changing minimum prices. Regional valuation preserves letter face amount/identity, while partial spending retires only exhausted instruments. Acceptance/location access remains owner-defined; generic available-funds display grants no bank/wagon permission. No future ECON feature or broader architecture proposal is approved wholesale.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: currency/unit/gold mappings and numeric bounds; denomination tender/change algorithms and supplies; issuer/face/rate/rounding/residual compatibility schemas and exploit fixtures; credit weight/acceptance/issuance/redemption profiles; account/location access; settlement/output/recovery receipts and native migrations. Concrete mod rates/ratios and unresolved gameplay profiles require explicit owner decisions before support is claimed. These cannot waive conservation, quote acceptance, physical weight or no-replay guarantees.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-009-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented currency/unit mappings, tender/change algorithms, issuer valuation/rounding schemas, credit/service profiles, settlement recovery and native migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
