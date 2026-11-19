# RULE-006 — Health growth and bonus pool

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Compute initial player base health and ordinary level-reward amounts, with predictable distributions and retained outcomes. CHAR owns reward eligibility, allocation and commitment.

## Intended player experience

Earn a random attribute pool and health increase when claiming a level. See the prepared health gain and why it has that value. Endurance invested now benefits later rewards rather than changing the current prepared gain. Loading/reopening cannot reroll a prepared reward or erase earned health.

## Confirmed requirements

RULE-006-D01–D03 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm independent pool/health draws in that order, explanatory allocation presentation and one logical draw for each valid singleton range.

Previously approved requirements remain authoritative: CHAR-015 defines uniform reward ranges, preparation timing, retained rolls, acquisition-order processing, atomic confirmation, unchanged current health and distinct artifact rewards. CHAR-017 defines ordinary level-1 initial health and no historical reward replay on restore. CHAR-005 defines career HP parameters; RULE-005 defines permanent-Endurance growth modifier. RULE-003 defines advancing purpose-owned randomness without frame reseeding and retained technical retries.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#BonusPool` reseeds Unity randomness from frame count and draws inclusive 4–6.
- `CalculateHitPointsPerLevelUp` reseeds DFRandom from rendered-frame count, draws inclusive integer class HP/2 through class HP, adds `HitPointsModifier` of permanent Endurance and clamps gain to at least 1. For valid positive class HP, integer division gives floor(H/2).
- `RollMaxHealth` starts at 25+class HP and invokes the gain function for each additional level. Repeated same-frame reseeding can repeat first draws; this behavior is not approved for the recreation.
- `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#UpdatePlayerValues` rolls ordinary rewards and changes level/maximum health before allocation completes. Oghma uses a separate 30-point branch. The approved CHAR-015 atomic-confirmation behavior deliberately differs from this split commit.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime distributions, original-game parity and complete caller behavior remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Initial health

Ordinary fresh characters start at actual level 1 with base maximum health B=25+H, where H is the validated career HP-per-level parameter. This calculation is deterministic: no ordinary level-reward draws and no Endurance growth bonus are added at level 1. CHAR-017 fills initial vitals only after consistent initialization.

CHAR-005's vanilla custom-class H defaults to 8 within inclusive 4–30; use the selected validated career's parameter rather than silently substituting 8 for every class. Modded higher starting levels/different starting formulas require an explicit compatible starting-state contract. Do not automatically replay level gains or create a backlog to implement such starts.

### Ordinary reward preparation

CHAR-015 authorizes preparation only when that reward's allocation begins. Capture the validated career/formula parameters and permanent Endurance before allocation. Validate both random ranges, numeric domains and compatibility before consuming either draw.

First draw the attribute pool uniformly over inclusive integers 4–6. Then draw health component h uniformly over inclusive integers floor(H/2)..H. Use the declared progression source under RULE-003, advancing it normally. These draws are independent: no balancing rule makes a high attribute pool reduce health or vice versa. Independence does not require separate sources for the two components.

Compute G=max(1,h+floor(E/10)−5) from captured permanent Endurance E. Retain the pool, h, captured inputs and resulting G as one prepared reward under CHAR-015. Do not redraw on presentation refresh, reopening, loading or technical retry. No frame/action reseeding or automatic classic sequence requirement is introduced.

For valid singleton configured ranges, consume one logical draw for that component and return the sole value. This preserves pool-then-health ordering. Logical draws may internally require different raw generator operations to provide unbiased range mapping. Invalid ranges cannot become singleton ranges through silent clamping or swapping.

### Endurance timing and reward commitment

Spending points on Endurance within this allocation does not change captured E or G. After the current reward commits, later rewards prepared in CHAR-015 acquisition order can use the resulting permanent Endurance. Do not prepare an entire backlog against the same stale attributes or recalculate historical health after later Endurance changes.

Preparing values does not grant a level, attributes or health. CHAR-015 confirms a valid complete allocation and atomically commits its level/attribute/base-maximum-health changes and completion identity. Add G exactly once to base maximum health; leave current health unchanged, without healing or percentage preservation. CHAR-018 owns effective limiters and current-pool reconciliation.

Display the prepared health gain, captured Endurance contribution and explanation that new Endurance affects future rewards. Do not imply that allocation edits reroll or improve the current reward. Exact layout and feedback remain UI scope. Other hidden creation/biography outcomes retain their existing disclosure policies.

### Artifact distinction

Oghma's approved baseline is a fixed 30 attribute points, no ordinary level increase and no ordinary health grant. It does not request the ordinary pool/health pair or consume ordinary level-health draws. Other artifact rewards require their own explicit contracts. Their creation, item consumption, allocation and commitment remain CHAR-015/ITEM/MAGIC responsibilities.

## Relevant formulas and parameters

- Initial level-1 base maximum health: B=25+H.
- Ordinary pool P is uniform over inclusive integer [4,6].
- Health roll h is uniform over inclusive integer [floor(H/2),H].
- Endurance contribution m=floor(E/10)−5, using captured permanent E.
- Ordinary maximum-health gain G=max(1,h+m).
- Ordinary level increment: 1 per valid distinct claim; Oghma level increment/health grant: 0.

Example: H=8, E=50 gives h=4..8 and G=4..8. At E=60 it gives G=5..9 for a subsequently prepared reward. Raising E to 60 inside an already prepared E=50 allocation does not alter that reward. Low Endurance can cause several distinct h values to yield G=1: h is uniform, but the minimum-clamped G distribution need not be uniform. Do not redistribute it to make final gains uniform.

Configured bounds and supported formula parameters follow CHAR-015/005 and RULE-005 validation. Preserve positive growth semantics and safe integer arithmetic; the minimum of 1 cannot hide invalid/overflowing inputs.

## Required data

Reward identity/type/acquisition order and preparation status; validated career H and parameter/provider version context; permanent E captured before allocation; pool/health range bounds; resolved P/h/m/G; and owner-managed allocation/commit state. Exact schema and duplicate-protection receipts belong to CHAR/SAVE. Stored earned base maximum health remains authoritative rather than reconstructed from current inputs.

## Inputs, outputs and events

Inputs: authorized fresh initialization or ordinary reward preparation, captured valid character/configuration inputs and progression random source. Outputs: initial base health or retained prepared amounts, or explicit failure. Pure queries of prepared values do not draw or grant benefits. CHAR-015 owns committed changes and notifications; concrete API/event names are unselected.

## Cross-system interactions

CHAR-005 provides career parameters; CHAR-011 resolves permanent attributes; CHAR-014 provides eligibility; CHAR-015 owns preparation/allocation/ordering/commit; CHAR-017 separates fresh creation from restoration; CHAR-018 owns health state. RULE-005 supplies growth modifier, RULE-003 supplies source ownership, and RULE-004 governs explicit replacement hooks. DATA-003 validates/locks configuration. SAVE preserves prepared/committed rewards and authoritative health. CORE/UI coordinate safe readiness and allocation suspension.

## Edge cases and failure conditions

- Odd positive H uses floor(H/2); both random endpoints are inclusive. Singleton bounds consume their draws in order.
- High/low valid permanent E uses RULE-005 domains and mathematical floor. Temporary Endurance never enters earned growth.
- Invalid ranges, unsupported/overflowing arithmetic or missing sources fail explicitly rather than publishing a partly prepared reward or silently using vanilla defaults.
- If preparation fails after a draw, retain sufficient partial-result/recovery context to avoid rerolling a resolved component on technical retry. Exact staging mechanics remain CHAR/SAVE; do not commit partial benefits or blindly restart preparation.
- All attributes at cap still follow CHAR-015 explicit unusable-point confirmation; this cannot suppress/repeat the ordinary health reward or convert points into health.
- Several pending rewards remain separate and ordered; applying one cannot overwrite another or grant the same level twice.
- Save/load preserves already prepared results even though future unresolved gameplay streams initialize afresh. Invalid saved reward data requires explicit migration/recovery.

## Configuration and balancing options

Retain CHAR-015's approved validated overrides for ordinary pool bounds, supported health formula parameters and artifact points, plus CHAR-005 career H settings. Random configured ranges remain uniform integer distributions. Exact schemas, numeric domains and supported hooks are implementation dependencies under DATA-003/RULE-004; no arbitrary formula interpreter or new reward behavior is approved here. New overrides cannot silently recalculate retained rewards or past health.

## Save/load considerations

Save authoritative base health and owner-required queued/prepared/committed reward state. Retain captured parameters and resolved results sufficient to validate/explain an existing prepared reward. Restore without running RollMaxHealth-style historical loops, rerolling amounts, healing or reapplying rewards. Save/recovery boundaries must prevent partial level/health/attribute commits. A save before preparation can permit fresh future rolls under RULE-003; a save with prepared values retains them. Changed definitions use explicit compatibility/migration rules, not silent reward replacement.

## Technical constraints

Target: Godot 4.7.2. Use explicit valid inputs, unbiased inclusive integer draws, safe arithmetic and mathematical floor. Separate initial health calculation, reward preparation and authoritative commit. No frame-based reseeding, implicit global RNG or historical growth replay. Concrete APIs, staging/serialization and hook contracts remain owner/engineering choices. No game implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Ordinary level-1 health is exactly 25+validated H without ordinary reward draws; no unsupported higher-start replay occurs.
2. Ordinary preparation draws uniform P then h using the specified inclusive ranges, without hidden coupling or reseeding.
3. Valid singleton components consume one logical draw each; malformed ranges fail before either draw.
4. Boundary cases verify odd H, permanent E floor behavior and minimum-clamped G, without assuming G itself is uniform.
5. Allocation explains captured health/Endurance; editing Endurance does not change the prepared gain and can affect later ordered preparation.
6. Loading, refreshing and technical retries retain resolved amounts and cannot duplicate benefits. Partial preparation uses explicit retained-result recovery.
7. CHAR-015 confirmation commits exactly one reward and leaves current health unchanged; artifact branches do not consume ordinary health draws.
8. Configuration/save failures use explicit recovery, never silent reroll, overflow, fallback or historical health reconstruction.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-005/011/014/015/017/018 and RULE-003/004/005. This consolidates previously approved reward formulas rather than reopening them. Independent ordered draws and explanatory presentation supplement CHAR-015. Fresh future randomness coexists with retained prepared amounts, and derived recomputation does not rewrite earned health. Full reward transaction, save and artifact mechanics remain their owners' contracts.

## Outstanding questions and approval

No blocking gameplay policy question remains for these calculations. Before implementation: finalize numeric/override domains, unbiased range adapter, reward preparation/partial-failure retention, source binding, UI explanations and atomic SAVE/commit integration. Higher modded starting levels require a separate supported initialization contract. These dependencies cannot waive retained results, pool-first ordering, captured permanent Endurance or unchanged current health.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-006-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
