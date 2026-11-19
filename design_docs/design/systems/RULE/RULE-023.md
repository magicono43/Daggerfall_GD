# RULE-023 — Repair and identification

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Quote repair/identification fees and per-item repair duration with explicit service context, free-service rules and retained accepted terms.

## Intended player experience

Players can review fee/duration and applicable benefits before accepting. Items needing no service incur no job/payment. Holiday/guild freebies remain free, and accepted repair terms do not silently change as the world economy or affiliation changes.

## Confirmed requirements

RULE-023-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve moddable distinct formulas/order, optional condition pricing, no-service-needed outcomes, explicit context, zero/free exceptions, raw condition duration and retained accepted terms.

RULE-021 supplies valuation/bargaining/quote reacceptance; RULE-022 current regional readiness. FACT/TIME own benefit/calendar interpretation; ITEM/ECON eligibility, payment/jobs/collection. DATA-003/RULE-004 govern validated locked extensions.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateItemRepairCost` returns zero when current=max; otherwise truncates 10% of value, minimum 1, applies CalculateCost then guild.ReducedRepairCost. Default fee does not scale with missing condition beyond the full-item check.
- `CalculateItemRepairTime` returns max(trunc((max−current)×SecondsPerDay/1000),SecondsPerDay), even when directly called on a full item.
- `CalculateItemIdentifyCost` returns zero on applicable Witches Festival; otherwise (25×base value)>>8 followed by guild.ReduceIdentifyCost-equivalent call (`ReducedIdentifyCost`).
- `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs` applies buying bargaining to repair totals but not identification. `UpdateRepairTimes` has separate batch/longest-job adjustments and prevents some existing times decreasing. These caller rules do not automatically approve a target batch scheduler.
- `Game/Guilds/Guild.cs#ReducedRepairCost`/`ReducedIdentifyCost` default pass through; concrete guild benefits require FACT/service review.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete benefit/calendar/collection/caller behavior and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Eligibility and context

Require valid item identity/value, condition or identification state, merchant/service identity and applicable guild/calendar context. For condition, maximum X>0 and 0<=current C<=X. Unknown/malformed required data fails rather than silently repairs/identifies for free.

Full-condition repair returns no-service-needed, fee zero and duration zero. Already-identified requests likewise produce no service/payment/job. These outcomes are distinct from valid free service on an item that still needs work. Broken-item/enchantment eligibility and identification prerequisites remain ITEM/ECON policies; these helpers do not promise every item is serviceable.

Supply explicit merchant region/quality when regional valuation participates, or authorized neutral context under RULE-021. Required RULE-022 catch-up/readiness gates apply. Intentional no guild benefit differs from missing required entitlement data. Calendar uses declared service region/time, not an incidental current-location lookup.

### Repair fee

For eligible damaged items, baseline repair seed F0=max(1,trunc(10×V/100)), with valid nonnegative item value V. Apply RULE-021 base regional/shop valuation to F0, then the applicable guild repair reduction. Aggregate service quantities/basket under ECON's declared rules, then apply purchase bargaining for a paid repair and its ordinary minimum.

Explicit guild/policy free repair remains free and bypasses the ordinary purchase minimum. Do not infer automatic free status from invalid negative output or accidentally turn a free quote into one gold. Supported guild free outcomes must carry enough provenance to distinguish them from malformed fees. Paid calculations remain nonnegative/safe under RULE-021.

Default fee is independent of damage amount except no-service-needed at full condition. Support an explicit moddable condition-dependent fee with declared stage/input units/rounding. Repair uses its own seed/policy, not an implicit adoption of trade condition pricing simply because both receive condition.

### Repair duration and accepted jobs

For eligible damage D=X−C, baseline duration T=max(SecondsPerDay,trunc(D×SecondsPerDay/1000)), in game seconds. Use raw missing condition units, not percent damage. Full items return zero before this rule. Validate safe arithmetic/positive day conversion and supported duration domains.

Formula coefficients and damaged-item minimum are moddable through declared safe schemas. A supported instant/different-duration policy must be explicit, not an accidental negative/overflowed duration. TIME supplies game units; wall-clock pauses/loading do not advance a job.

This is per-item duration. Batch workload, service queue, returned-item timing and repair completion/collection are ECON/ITEM contracts. Once accepted, retain agreed price and scheduled completion terms. Later regional prices, guild rank or settings do not automatically recalculate them. New work affecting existing schedules requires an explicit supported owner policy and cannot silently rewrite terms; changed quotes need renewed acceptance.

### Identification fee

For an eligible unidentified item, the baseline applicable Witches Festival policy gives fee zero. Otherwise F=trunc(25×V/256) for nonnegative valid V, then apply guild identification reduction. Preserve zero when small values round down. No ordinary purchase minimum or further bargaining is added by baseline.

Holiday/guild eligibility, coefficient and supported adjustment policies are moddable. Explicit free service and computed zero fee remain valid services only if otherwise eligible. Whether identification is immediate, what it reveals and any nonmerchant identification source/cost are ITEM/MAGIC/ECON rules rather than inferred here.

### Quotes, hooks and commitment

Present fee/duration and relevant value/condition, regional/quality, bargaining, guild/holiday and rounding/minimum reasons through shared calculation. Inspection spends nothing, starts no job and cannot repair/identify or award practice.

Revalidate current inputs/context before acceptance/commitment. Changed final amount or proposed completion terms require an updated quote and renewed acceptance. Commit payment/item custody/job state or identification coherently through owners; this helper does not define transaction failure costs or item transfer.

Support explicit RULE-004 hooks for fee/duration/benefit policies with declared stages and side-effect contracts. DATA-003 locks configuration. Invalid definitions, unavailable required context and callback failure require explicit recovery without silent vanilla fallback or partially paid jobs.

## Relevant formulas and parameters

- Damaged repair seed=max(1,trunc(10×V/100)); then regional/shop valuation, guild reduction and paid-repair bargaining/minimum.
- D=X−C; T=max(one game day,trunc(D×seconds/day/1000)); full repair T=0/no service.
- Identification F=trunc(25×V/256), then guild reduction, unless applicable holiday makes it free.
- Identification zero and explicit free repair bypass ordinary purchase minimum; not eligibility.

Example: V=100 gives repair seed 10 before shop/region/guild/bargaining and identification base 9. Missing 500 raw condition gives half-day raw duration but one-day default result; missing 2000 gives two days. Full condition gives zero/no job, not one day. V=10 identification rounds to zero.

## Required data

Stable item/service/guild/region identities; valid value/current/max/identified state and quantity; regional/quality/bargaining inputs where applicable; resolved benefit/holiday context/provenance; fee/duration policy; quote/acceptance identity and committed price/completion terms. Concrete job/transaction schemas remain dependencies.

## Inputs, outputs and events

Inputs: valid explicit service query and owner-authorized acceptance. Outputs: no-service-needed, valid paid/free quote with duration, or explicit error. ITEM/ECON own payment/custody/identification/job/collection mutation and notifications; APIs/signals are unselected. A quote alone is not a committed job.

## Cross-system interactions

ITEM owns condition/item eligibility/identification/repair data; ECON quotes/transactions/jobs; FACT benefits; TIME/holiday owner calendar/game seconds; RULE-021 valuation/bargaining and RULE-022 readiness. RULE-004/DATA-003 validate hooks/configuration. CORE/SAVE protect coherent restoration/commit; UI/DEV observe without mutation.

## Edge cases and failure conditions

- Full/already-identified items cannot gain free jobs or minimum charges; invalid condition cannot masquerade as complete.
- Zero identification/explicit free repair remains zero despite paid-purchase minima.
- Required calendar/benefit lookups fail explicitly rather than grant or deny a holiday silently.
- Huge values/conditions cannot overflow fee/time; negative/nonfinite hook output is invalid rather than a refund.
- Existing jobs cannot be restarted/repriced by refresh, removing another item, load or duplicate callback without an explicit owner policy.

## Configuration and balancing options

Support separate fee coefficients, condition-dependent repair policy, region/quality/bargaining applicability through declared models, guild/holiday rules, duration coefficients/minimum and supported hooks. New policies must identify explicit free outcomes and units. No universal magic-item repair permission, queue model, instant-identification guarantee or item custody rule is introduced.

## Save/load considerations

Persist committed job/item/payment facts and agreed price/completion terms through ITEM/ECON/SAVE. Restore without repricing from current guild/calendar, replaying payments or granting completion through wall-clock time. Fresh quotes use current valid context and changed terms require reacceptance. Missing required job state/definitions use explicit migration/recovery, not free repair, lost item or silent job reset. General batch/cancellation/collection persistence remains owner scope.

## Technical constraints

Target: Godot 4.7.2. Separate no-service/paid/free outcomes, pure fee/duration calculations, accepted terms and mutations. Use safe nonnegative integer arithmetic/explicit game units. Numeric widths/interfaces/schemas remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Damaged repair fee order and identification formula/holiday/guild behavior match baseline with declared mod overrides.
2. Full/already-identified requests produce no payment/job; full duration zero precedes damaged minimum.
3. Condition domains and raw-unit duration match boundaries, with safe arithmetic and no percent substitution.
4. Explicit free repair and zero identification bypass ordinary purchase minimum without bypassing eligibility.
5. Quotes share current explicit region/benefit/calendar context, respect price readiness and spend nothing during queries.
6. Accepted price/completion terms persist; changed proposals require renewed acceptance and owner-atomic commitment.
7. Hook/restore/retry failures cannot fallback silently, reprice/restart jobs or duplicate payment/identification.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-004/021/022 and DATA-003. Free-service exceptions use RULE-021's explicit policy distinction rather than weaken ordinary purchase minima. Regional readiness applies only where the service actually uses regional pricing. Per-item duration does not approve DFU batch rewrites; retained terms and atomic settlement remain owner integration requirements.

## Outstanding questions and approval

No blocking shared-service calculation question remains. Before implementation: finalize benefit/holiday adapters, numeric/mod/hook domains, free-outcome provenance, quantity/batch/job policy, custody/payment/completion/collection and SAVE integration. These cannot waive zero/no-service distinction, raw-condition time, explicit free exceptions or retained accepted terms.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-023-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented guild/holiday, batch/job and ECON/ITEM/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
