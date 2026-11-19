# RULE-022 — Regional price changes

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Initialize and evolve explicit regional price multipliers and mutually exclusive price conditions, supplying coherent current state to trade quotations.

## Intended player experience

Regions have differing prices that evolve with time and political inputs. Rest/travel advances all required daily steps without silently approximating them. Loading preserves established prices. Trade cannot commit using stale/half-updated regional state, and changed quotes require renewed acceptance.

## Confirmed requirements

RULE-022-D01–D08 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve moddable initialization/update formulas, exclusive flags, explicit political mappings, daily stepwise catch-up, day-major ordering, retained persistent progress/rolls, RULE-001 rise checks and coherent publication/trade gating.

RULE-021 consumes explicit merchant-region multiplier and revalidates changed quotes. RULE-003 supplies owned economy randomness/retained retries. RULE-004/DATA-003 govern validated locked configuration. FACT/TIME own political/cadence boundaries rather than implicit global reads.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#RandomizeInitialRegionalPrices` independently draws inclusive 750–1250 into each region PriceAdjustment, in thousandths.
- `UpdateRegionalPrices` requires The_Merchants faction, otherwise returns. For regions with matching regional faction it loops elapsed iterations, calculating integer political/price feedback, then 49/50 or 51/50 movement and clamp 250–4000.
- The outer loop is region-major. Missing regional faction silently skips that region. Price flags clear both only within the normal band; low/high branches set their flag without explicitly clearing the opposite one.
- `Game/Entities/PlayerEntity.cs` calls updates when date changes using daysPast; separate regional/faction-condition processing can alter merchant power based on counts of high/low-price regions and other conditions. Full historical ordering/catch-up semantics remain unverified.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete FACT/TIME routing, runtime feedback and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Region identity and initialization

Use stable region identities with explicit price-state/political mappings, including added regions. Require merchant/regional-power inputs or an explicitly configured alternative pricing policy. Missing required context is an error rather than a completed unchanged update. An intentional no-update alternative must itself be declared/validated; it is not inferred from a failed lookup.

For a newly authorized region state, initialize multiplier V uniformly over inclusive integer 750–1250, where 1000 is neutral. Use owned economy randomness; initialization cannot advance combat/presentation sources. Derive initial flags from V immediately. Initialization ranges/formulas/mappings are moddable and must fit supported bounds. Do not rerandomize an existing region on viewing, entering, loading or quote queries.

Added regions in existing saves need explicit initialization/migration policy and identity mapping. Runtime region-array position is not sufficient identity. Different characters/worlds inherit state only under their approved session/save ownership contracts, not an application-global mutable singleton by implication.

### Step formula

For current multiplier V, merchant power M and regional power P at the declared step boundary, raw rise score C=trunc((M−P)/5)+50−trunc((V−1000)/25). Preserve separate toward-zero divisions; use safe wider arithmetic.

Resolve C through RULE-001's 0–100 effective chance and one logical percentile draw, including guarantees. Rise: Vnext=trunc(51×V/50); fall: Vnext=trunc(49×V/50). Then clamp to inclusive 250–4000. Do not combine several days into one multiplication or clamp only after the whole catch-up batch.

All coefficients/offsets/divisors/factors/bounds and supported policies are moddable under explicit schemas/hooks. Require finite safe domains, positive divisors, valid ordered ranges and supported output state. Configuration should distinguish deliberate calculated saturation from malformed/overflowing input; the latter fails explicitly rather than silently wrapping/narrowing to ushort.

### Price conditions

Derive exactly one semantic condition from each committed multiplier: Low if V<500; High if V>2000; otherwise Normal. Equality at 500/2000 is Normal. Set/clear low/high flags consistently so no contradictory pair persists. Normal can be represented as neither flag; concrete representation is unselected.

Thresholds are moddable and must define a coherent nonoverlapping normal band. Restore/initialization and every committed step rebuild/validate flags from authoritative multiplier rather than treating stale caches as independent truth. FACT consumes the committed derived state at its declared boundary; this does not automatically approve every source faction-power feedback formula.

### Cadence and catch-up

Baseline is one update for each completed game-day boundary, including eligible elapsed rest/travel days. TIME provides exact boundaries; pause/loading/wall-clock duration does not invent game days. Supported cadence overrides must declare unit/step semantics and compatibility rather than grant a full daily adjustment every shorter interval implicitly.

Process pending days chronologically, each day across a declared stable region order. This day-major ordering deliberately replaces DFU's region-major elapsed loop. For each day FACT/TIME supply explicitly defined political inputs, then required region outcomes settle coherently. Exact order of political evolution, price publication and feedback between days remains a joint FACT/TIME contract before implementation; do not assume all missed days use current power or reconstruct fictional historical inputs silently.

Bound work per processing pass and retain all pending steps/progress. Do not drop overdue days or substitute a batched approximation. If processing yields within a day, candidate region results/draws remain unpublished and retained for retry; the next pass resumes rather than rerolls or restarts earlier committed days.

### Publication and trade

Publish each completed day's required multipliers and derived flags coherently and advance its completion boundary only after successful settlement. Invalid/missing definitions or required flag updates cannot mark completion. A technical failure requires explicit owner recovery; partial publication is not successful unchanged prices.

While required catch-up remains pending, affected new trade commitments cannot use stale/half-updated regional prices. Quotes may report updating/not ready and refresh once valid current state is available. Already committed trades remain unchanged. If refreshed final amount differs, RULE-021 requires renewed acceptance. Exact readiness UI and affected-region/service scope belong to ECON/CORE; this is not permission to freeze unrelated presentation or silently wait forever after errors.

Retain each region/day's resolved rise result through retries and saves where continuation is supported. Fresh future economy randomness after successful load under RULE-003 affects only genuinely unresolved steps, not retained outcomes or assigned multipliers. Property/quote/diagnostic queries do not perform simulation draws or complete a day.

## Relevant formulas and parameters

- Initial V~uniform integers [750,1250]; 1000=neutral.
- C=trunc((M−P)/5)+50−trunc((V−1000)/25).
- RULE-001 rise iff roll<=clamp(C,0,100).
- Rise Vnext=clamp(trunc(51×V/50),250,4000); fall uses 49 instead of 51.
- Low V<500; Normal 500<=V<=2000; High V>2000.

Example: M=P,V=1000 gives 50% rise; outcomes 1020 or 980. At V=1001 with equal powers, feedback truncates to zero; outcomes are 1021 or 980. Negative feedback division near neutral also truncates toward zero rather than floor. At bounds, draws still occur and a directional step may clamp to the same value; that is a valid completed step, not a reason to reroll.

## Required data

Stable region/policy/mapping identity; authoritative multiplier; derived flags; last completed boundary; pending day/region progress and retained rolls/results; declared daily political inputs/version context; owned economy source; parameter/provider provenance and pricing readiness. Concrete snapshot/schema/commit mechanics remain dependencies.

## Inputs, outputs and events

Inputs: authorized region initialization, explicit elapsed boundaries/political context and validated policy. Outputs: retained candidate/committed region state, exclusive flags, completed/pending progress/readiness or explicit failure. Quotes consume committed ready state, not mutable candidates. FACT/ECON notifications follow coherent commitment; APIs/signals are unselected.

## Cross-system interactions

ECON owns regional price state and readiness; RULE-021 merchant quotes; FACT political inputs/feedback; TIME chronological steps/catch-up. DATA-003/RULE-004 validate locked mappings/hooks, RULE-001/003 owned checks/results. CORE gates required work/readiness/stale callbacks; SAVE persists progress/facts; UI/DEV inspect state without advancing simulation.

## Edge cases and failure conditions

- Missing faction/region mapping cannot silently skip required steps; explicit alternative policy differs from technical failure.
- Contradictory saved low/high caches rebuild/validate from authoritative multiplier under explicit restore policy rather than influence political feedback unreconciled.
- Large catch-up yields/resumes without reroll/drop, duplicate feedback or unbounded processing burst.
- Calendar rollback/inconsistent boundary state requires TIME/SAVE recovery, not negative updates or phantom days.
- New region definitions cannot inherit another region's state through array insertion/reordering.
- Invalid hooks/overflow enter explicit recovery without automatic fallback, partial day completion or stale trade commitment.

## Configuration and balancing options

Support initial ranges, rise-score parameters, directional factors/bounds, condition thresholds, cadence and explicit political/alternative policies through validated contracts. Stable iteration/feedback semantics and save migration are required for changes. No universal faction-power model, shop-specific scarcity system, player speculation restriction or real-time price update is introduced.

## Save/load considerations

Save committed multipliers/boundaries and owner-required pending step context/results. Restore without reinitializing established regions, replaying completed steps/feedback or using wall-clock elapsed time. Candidate-state serialization/rollback must preserve day coherence and retained draws. Added/changed regions/policies need explicit migration; missing required historical context cannot silently be replaced by current faction power. Pricing stays unready until required restoration/catch-up settles safely.

## Technical constraints

Target: Godot 4.7.2. Use explicit stable identities, safe signed truncation, owned RNG and day-major staged settlement. Separate political input, numeric evolution, derived conditions and quote readiness. Numeric widths, work budgets, event/snapshot APIs and persistence remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Initialization and step formulas match inclusive ranges, rounding/bounds and RULE-001 guarantees without rerolling boundary outcomes.
2. Derived low/normal/high are exclusive at thresholds and coherent with committed multiplier, including initialization/restore.
3. Required political mappings/alternatives validate explicitly; missing data does not complete an unchanged step.
4. Elapsed days process day-major/stable-region order with declared political boundaries, bounded work and no approximation/drop.
5. Retry/restore retains rolls/progress without reinitialization, duplicated feedback or replayed completed days.
6. Daily publication is coherent; affected trade commitments wait for current ready prices and changed quotes need renewed acceptance.
7. Modded ranges/thresholds/cadence/hooks preserve validated state/explicit compatibility and errors do not publish partial prices.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-001/003/004/021 and DATA-003. Owned retained draws coexist with fresh future streams; stagewise updates do not require replay-identical loads. Explicit region readiness complements RULE-021's context/reacceptance rules. Flag exclusivity and day-major catch-up deliberately replace source behavior. FACT political feedback and TIME history/order are dependencies, not source-implied approval.

## Outstanding questions and approval

No blocking shared-price evolution policy question remains. Before implementation: define full political/mapping schemas, FACT/TIME historical boundary/feedback semantics, numeric/work limits, coherent daily commit/candidate save format, affected quote scope/readiness and migrations. These cannot waive explicit required inputs, exclusive flags, retained stepwise evolution or current-price commitment gates.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-022-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented political-boundary, daily-settlement and ECON/FACT/TIME/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
