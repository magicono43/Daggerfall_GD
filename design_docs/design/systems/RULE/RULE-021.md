# RULE-021 — Trade price

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Calculate staged purchase/resale quotes from base values, explicit merchant region/quality and live bargaining inputs, with moddable policies and safe monetary boundaries.

## Intended player experience

Prices follow explainable regional/shop/character factors. Condition does not affect default trade valuation but can through a declared mod policy. Ordinary purchases cost at least one gold, while zero resale is explicit. Changed quotes require renewed acceptance; inspecting prices spends nothing.

## Confirmed requirements

RULE-021-D01–D08 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve staged moddable fixed-point baselines, default condition independence, live inputs/nonnegative outputs, independent minima, explicit region/neutral context, basket order, extended-stat normalization and revalidated transparent quotes.

CHAR-011 owns live values. RULE-022 owns evolving regional state; RULE-004/DATA-003 own validated locked extensions. ECON owns item eligibility, currencies, stock and atomic transaction commitment; this feature calculates prices rather than executing trades.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateCost` sets input below 1 to 1, calls ApplyRegionalPriceAdjustment and returns 2×(regional cost+integer regional cost×(quality−10)/100). Default condition argument is unused.
- `ApplyRegionalPriceAdjustment` uses current location region's PriceAdjustment in thousandths, clamps adjusted cost to at least 1, or returns unchanged cost when no current location exists.
- `CalculateTradePrice` uses merchant Mercantile/Personality equivalents 5×(quality−10)+50 and separate buy/sell fixed-point formulas with live player Mercantile/Personality. It returns the computed integer without intended final safe minima.
- `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs` values items/quantities into a basket total before GetTradePrice applies buy/sell bargaining. Some repair/service callers also use bargaining; their service-specific base calculation remains separate.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full caller/quantity/condition/currency behavior and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Context and base valuation

Require an eligible explicit purchase/resale purpose, validated item/service base values and merchant quality/region context. Empty or invalid baskets do not become ordinary one-gold purchases through minimum enforcement. Explicit free-service/gift policies are separate and cannot be inferred from a negative price.

For a valid ordinary unit base value V, baseline stage B0=max(1,V). For explicit regional multiplier r in thousandths, B1=max(1,trunc(B0×r/1000)). Then B2=2×(B1+trunc(B1×(Q−10)/100)), using merchant quality Q. Preserve the division stage, including signed toward-zero behavior.

Use the merchant's declared region, including remote merchants, or an explicitly authorized neutral multiplier r=1000. Missing required region/state fails rather than silently returning unadjusted cost. RULE-022 supplies current valid regional multiplier; quoting does not advance regional simulation or draw randomness.

Condition is ignored by the default trade base model. Supported mod condition pricing must define applicable item types, condition inputs, adjustment stage and rounding before use. Repair calculation is separate; an accepted condition parameter alone does not change price. Negative source values and permitted zero-value items require explicit valid owner domains; the baseline minimum is not permission to repair malformed definitions silently.

### Basket order

Calculate valid per-unit base valuation, multiply by selected quantity, sum the evaluated basket, apply one direction-specific bargaining operation and then the final minimum. Quantity, unit identity and canonical stack treatment belong to ITEM/ECON; previews and confirmation must evaluate the same basket.

Splitting one basket into separate transactions can change rounding/minimum totals. Preserve this documented arithmetic rather than silently swapping per-item and basket bargaining. No general anti-arbitrage rule, stock policy or forced stack normalization is introduced here.

### Fixed-point bargaining

Use live Mercantile S and live Personality P, with merchant equivalents M=5×(Q−10)+50 and N=M by baseline. Preserve fixed-point stages exactly with safe wider arithmetic. Define div(x,d)=trunc(x/d), and shr(x,k)=floor(x/2^k), matching signed arithmetic-right-shift behavior without overflow. Do not replace all stages with one approximate floating percentage.

For selling:

- dm=shr((div((100−M)×256,200)+128)×(div(S×256,200)+128),8).
- dp=shr((div((100−N)×256,200)+128)×(div(P×256,200)+128),8).
- raw=shr((shr(179×dm,8)+shr(51×dp,8))×basketBase,8).

For buying:

- dm=shr((div(M×256,200)+128)×(div((100−S)×256,200)+128),8).
- dp=shr((div(N×256,200)+128)×(div((100−P)×256,200)+128),8)×64.
- raw=shr((shr(192×dm,8)+shr(dp,8))×basketBase,8).

These are resolved baseline formulas, not approval of undefined numeric extremes. Use supported live values without hidden 0–100 stat/skill caps; normalize a valid negative computed raw quote to zero before final minima. Malformed parameters/nonfinite values/overflow fail explicitly rather than use normalization as silent repair. Modded curves/coefficients/hooks require declared domains and rounding.

### Final boundaries and quotes

For an eligible nonempty ordinary purchase, final=max(buyMinimum,max(0,raw)), vanilla buyMinimum=1 gold. Resale final=max(sellMinimum,max(0,raw)), vanilla sellMinimum=0. Minima are independently moddable nonnegative supported integers. Show zero resale explicitly before confirmation; do not silently treat it as an accepted donation or invent practice/rewards for it.

The baselines do not automatically guarantee a particular spread for all extended inputs or ban buying/reselling across merchants. ECON must review deliberate arbitrage, empty/zero-value transactions, stock and eligibility independently. Quotes cannot reverse payment direction via negative amounts.

Provide an inspectable breakdown of base, regional, shop-quality, quantity, bargaining, condition-policy and minimum contributions with selected provider/provenance where relevant. Pure queries neither spend/transfer resources nor award Mercantile practice.

Revalidate current inputs and basket before commitment. If final amount changes, show a new quote and require renewed acceptance rather than silently charging/paying a different amount. ECON owns consistent quote identity/transaction snapshots and atomic currency/item exchange; matching numeric amounts do not waive other eligibility validation.

### Modding

Support validated base/regional/quality/bargaining parameters, condition policy and independent final minima, with explicit RULE-004 hooks. Contracts declare purpose/stage/inputs/output domains; a unit-valuation replacement differs from final basket quote replacement. DATA-003 locks resolved configuration; runtime failures follow explicit recovery without automatic vanilla fallback or partial payment.

## Relevant formulas and parameters

Baseline stages: B0=max(1,V); B1=max(1,trunc(B0×r/1000)); B2=2×(B1+trunc(B1×(Q−10)/100)); quantity/basket aggregation; fixed-point buy/sell; max(0,raw); direction minimum.

Baseline neutral r=1000; merchant M=N=5×(Q−10)+50. Divisions truncate toward zero while arithmetic shifts floor. Exact baseline quote fixtures must verify those distinctions, including extended live inputs.

Example: V=100,r=1000,Q=10 gives unit base 200. At live S=P=50 and Q=10, both dm values are 144; the fixed-point formulas give buy 112 and resale 100 for a one-unit basket. Empty basket still is not an eligible one-gold purchase. Condition changes alone leave default base valuation unchanged.

## Required data

Stable item/service/merchant/region identities; validated base/condition/quantity and evaluated basket; regional multiplier/quality; live Mercantile/Personality; direction/minima and provider provenance; quoted final amount and owner acceptance/commit context. Exact schemas, currency domains and quote lifetime remain dependencies.

## Inputs, outputs and events

Inputs: valid explicit quote context and current definitions/state. Outputs: staged nonnegative quote/breakdown or explicit invalid/empty/context result. This helper does not transfer inventory/currency or award practice. ECON owns committed transaction events and retries; APIs/signals are unselected.

## Cross-system interactions

ITEM provides value/condition/quantity, ECON merchant/basket/settlement, RULE-022 region multiplier, CHAR-011 live bargaining inputs. Service owners supply their explicit base prices rather than assume every service uses item valuation. RULE-004/DATA-003 validate hooks/definitions; CORE/SAVE protect restored transaction facts; UI/DEV expose shared current quotes.

## Edge cases and failure conditions

- Missing merchant region differs from authorized neutral context; unknown quality/domain data cannot silently become Q=10.
- Condition policy must not run twice or leak repair pricing into resale by argument presence.
- Huge baskets/extended stats require safe products/shifts; valid negative raw output normalizes, overflow errors do not.
- Zero resale needs explicit acceptance; invalid/empty baskets cannot gain minimum charges or free resources/practice.
- Quote changes during a popup/transaction require revalidation; retries cannot repeat payment or transfer.

## Configuration and balancing options

Both buy/sell paths, regional/quality stages, condition policy and minima are moddable within explicit schemas/hooks. Shop-quality range and currency/quantity limits must be verified/declared before implementation. No new haggle minigame, faction discount, merchant wealth limit, auto-donation or global spread clamp is introduced.

## Save/load considerations

Restore authoritative inventory/currency/merchant/region state without replaying trades. Rebuild quotes from valid current restored inputs; saved price caches are not payment authority. Pending acceptance/transactions require ECON/SAVE compatibility and exactly-once handling; changed quotes need renewed acceptance. Locked providers cannot change on character load; invalid definitions use explicit migration/recovery rather than reinterpreting completed payments.

## Technical constraints

Target: Godot 4.7.2. Separate pure staged quotation, acceptance and atomic exchange. Use safe signed integer division/shift equivalents and explicit monetary units/contexts rather than global current-player/location lookup. Interfaces/numeric widths/caching/serialization remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Baseline unit/region/quality/basket/bargaining order matches fixtures, including buy 112/resale 100 example and signed rounding boundaries.
2. Default condition independence and explicit modded condition stage are distinguishable; no double adjustment occurs.
3. Live extended inputs remain uncapped by hidden 100 limits; negative valid raw prices normalize before independent minima while unsafe arithmetic fails.
4. Empty/invalid baskets receive no minimum transaction; zero resale is explicit and negative prices never reverse payments.
5. Explicit merchant region or authorized neutral context is required; quoting never evolves region state or draws randomness.
6. Shared breakdown/query spends nothing; changed final quotes require renewed acceptance and ECON atomic exchange.
7. Hooks/restore/retries follow locked configuration and cannot silently fallback, double-pay or replay inventory transfer.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-011, RULE-004/018 and DATA-003. Consumer-specific price safety does not globally clamp live skills. Spell gold bases/service bases remain separate from final trade pricing. Region evolution remains RULE-022 and atomic settlement ECON; source default region bypass is intentionally replaced by explicit context. No new economy behavior is approved merely from observed callers.

## Outstanding questions and approval

No blocking quotation policy question remains. Before implementation: verify full rounding/caller fixtures and domains, define condition schema/hook stages, merchant-region/service adapters, coherent basket/quote identities and atomic ECON/SAVE handling. Exploit/stock/practice policies require ECON review. These cannot waive staged arithmetic, both-direction moddability, explicit context or renewed acceptance on price change.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-021-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented rounding/domain, regional-state and ECON/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
