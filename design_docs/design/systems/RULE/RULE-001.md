# RULE-001 — Percentile checks

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Provide a shared, exact integer-percent chance check for uncertain gameplay outcomes. Calling features own chance formulas, action eligibility and consequences.

## Intended player experience

Checks follow their stated probabilities without hidden streak correction. Reloading a save allows another attempt with fresh randomness, without guaranteeing a different or favorable outcome. Previously retained results remain retained under their owning specifications.

## Confirmed requirements

RULE-001-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm integer percentages, saturated computed chances, once-only resolution, one draw even for guarantees, explicitly supplied isolated gameplay randomness, fresh randomness after successful loads, independent checks and observational diagnostics.

## Existing Daggerfall Unity behavior — reference only

Source: `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/Game/Utility/Dice100.cs`, symbols `Roll`, `SuccessRoll`, `FailedRoll`.

- Roll draws an integer 1–100. SuccessRoll draws 0–99 and tests draw < chance; FailedRoll independently draws 0–99 and tests draw >= chance.
- Computed chances outside 0–100 yield guaranteed failure/success without explicit clamping. Guaranteed checks still draw. Calling success and failure methods separately consumes two draws, rather than inspecting one result.
- The helper uses UnityEngine.Random's shared source. It does not implement streak protection or ordinary player-facing roll presentation.
- `Game/Formulas/FormulaHelper.cs#CalculateSuccessfulHit`, and the Dice100 call sites for backstabbing and critical strikes, illustrate consumers. Complete consumer eligibility, formulas and side effects remain owner scope.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; DFU save/load random continuation and original-game parity are not asserted. Source remains unchanged.

## Detailed rules and behaviors

### Resolution

Accept an integer computed chance C and an explicitly supplied gameplay random source. Determine effective chance P by limiting C to 0–100. Obtain one uniformly distributed integer R in inclusive range 1–100. Succeed exactly when R <= P; otherwise fail. Success and failure are complementary views of this same resolved check, never separate draws.

Every resolved check obtains one percentile draw, including P=0 and P=100. This counts logical percentile draws; an unbiased range-mapping implementation may internally require more generator operations. Do not add universal critical success/failure, minimum uncertainty or hidden probability corrections.

Checks are independent by default: prior success/failure does not secretly alter P or force subsequent outcomes. Feature-specific limits or explicit streak mechanics require approval by that owner. They are not supplied automatically by this helper.

### Ownership and observation

Callers resolve a genuine check once and reuse the result for its consequences and diagnostics. Repeated viewing, rendering, logging or reading success/failure cannot draw again. Distinct owner-authorized attempts can each resolve a new check. The calling feature defines when another attempt is permitted; this specification does not define global action IDs or retry cooldowns.

Presentation and previews cannot consume or reseed the gameplay source. Developer simulation of hypothetical checks must use isolated test randomness. Ordinary player visibility of chances or rolls belongs to the calling feature; no universal dice display is introduced.

### Fresh randomness after load

On every successful load, initialize gameplay randomness afresh before new gameplay checks can resolve. Do not restore an old percentile sequence in a way that forces identical subsequent rolls. Repeated loads of the same save can therefore support deliberate reload-to-reroll play. Fresh initialization is not a promise of unique seeds, unique rolls, improved luck or a changed binary result.

This policy applies to newly resolved gameplay checks, not replacement of saved outcomes. Already applied consequences, assigned persistent identities and explicitly retained creation/progression results remain saved facts. Loading must not replay committed checks, regenerate retained rewards or duplicate their effects. Exact random stream layout and initialization mechanics remain RULE-003/SAVE contracts.

## Relevant formulas and parameters

- P = min(100, max(0, C)), for integer C.
- R is uniform over {1, ..., 100}; success = (R <= P).
- Success probability is P/100; failure probability is (100-P)/100.
- C<=0 always fails; C>=100 always succeeds, while consuming one draw.
- At C=35, R=35 succeeds and R=36 fails. R=1 fails at P=0; R=100 succeeds at P=100.

Fractional input conversion is outside this integer helper and requires an explicit caller rule; no silent rounding policy is introduced.

## Required data

Integer original/effective chances, supplied gameplay random source, resolved roll and boolean result. Retain enough owner context to reuse a result when its lifecycle requires it. Exact RNG algorithm, seed representation, stream identities and diagnostic schema remain engineering/cross-owner dependencies.

## Inputs, outputs and events

Input: integer chance and valid owned random source for an authorized check. Output: one resolved result containing original chance, effective chance, roll and success/failure, available to developer diagnostics. This is a conceptual contract, not a selected API or signal name. The helper itself does not apply damage, award practice, change inventory or emit mandatory global gameplay events.

## Cross-system interactions

COMBAT/MAGIC/NPC and other consumers own chance formulas, eligibility, ordering and effects. RULE-002 owns classic sequence compatibility where needed; RULE-003 owns stream division and initialization mechanics. CORE gates readiness, simulation eligibility and stale callbacks; CORE-017's stable consumer ordering remains binding without requiring replay-identical rolls after load. SAVE coordinates fresh random initialization and restoration of retained outcomes. DATA-003 validates supported authored/mod rules. UI/AV/DEV observe results without perturbing gameplay randomness.

## Edge cases and failure conditions

- Extreme supported integer chances saturate using safe comparisons; no arithmetic overflow is needed to clamp.
- Invalid authored parameters are diagnosed under the owning definition's validation rules. Saturating a valid computed result does not authorize silently repairing malformed definitions.
- A missing/invalid random source or out-of-contract draw cannot produce a fabricated successful result; integrate explicit failure with owner/CORE recovery. Exact error interface remains engineering scope.
- Duplicate callbacks or diagnostic refreshes cannot resolve the same committed attempt again. Legitimate repeated attempts use their owner's rules.
- Long failure/success streaks and coincidental repeated results after load are valid. Do not correct them invisibly.
- Fresh load initialization cannot reset persistent names, prepared rewards or applied consequences. Loading/reconstruction itself does not replay gameplay checks.

## Configuration and balancing options

Calling features can define approved chance formulas, bonuses, limits and explicit exceptions through supported validated content/mod contracts. Integer percent semantics and this baseline's absence of hidden streak protection remain fixed. No player RNG setting, global luck modifier, configurable algorithm or universal mod hook is approved here.

## Save/load considerations

Persist owner-required resolved facts and retained outcomes; do not require percentile RNG continuation state for replay-identical loading. Successful loads establish fresh gameplay randomness before gameplay resumes. A failed/cancelled load does not authorize publishing a partial session or mutating the surviving session's random source; CORE/SAVE safe handoff applies. Do not reconstruct resolved effects by rolling again. Concrete serialization and random-source lifecycle remain integration dependencies.

## Technical constraints

Target: Godot 4.7.2. Supply randomness explicitly, use unbiased inclusive 1–100 range mapping, and keep result observation separate from resolution. Do not couple gameplay draws to frame counts, rendering or diagnostic reads. Seed allocation, RNG algorithm and stream topology remain unselected. No game implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. With controlled rolls, 35 succeeds on 1–35 and fails on 36–100; 0 always fails and 100 always succeeds.
2. Computed chances below/above bounds behave as 0/100, including supported extreme integers; invalid authored definitions are separately diagnosed.
3. Every resolved check obtains exactly one logical percentile draw, including guaranteed outcomes. Success/failure queries and diagnostics obtain none.
4. Results expose original/effective chance, rolled number and outcome, with no mandatory ordinary player-facing display.
5. Gameplay sources are explicit; presentation, previews and logging cannot advance or reseed them.
6. The baseline has no history-dependent chance adjustment or forced outcome. Range mapping provides uniform percentile draws without modulo bias.
7. Every successful load initializes fresh gameplay randomness, permitting new attempts without guaranteeing changed results. Verification must inspect initialization behavior rather than require two random outcomes to differ.
8. Loading retains saved effects, persistent assigned names and explicitly retained rewards; it neither replays checks nor reapplies their effects.
9. Missing/invalid sources cannot fabricate outcomes; lifecycle failures follow explicit recovery and cannot publish partial random state.

These are future verification criteria. No implementation/runtime tests have been performed or authorized.

## Consistency review

No direct contradiction identified with reviewed approved rules: DATA-015/016/017 isolate text/presentation randomness and retain assigned values; CHAR-006/008 preserve retained creation outcomes; CHAR-015 retains prepared reward rolls across loads; CORE-017 orders consumers without prescribing replay determinism. Fresh gameplay randomness changes future checks, not those retained results. RULE-AR-01/GAD-06 are architecture proposals and do not override the user's chosen load policy. No RNG algorithm or full stream topology is approved by this feature.

## Outstanding questions and approval

No blocking gameplay policy question remains for this shared percentile helper. Before implementation: define owned streams/load initialization under RULE-003 and SAVE, supported integer domains, unbiased RNG adapter, error/result interfaces, diagnostics integration and owner attempt lifetimes. These dependencies cannot waive the confirmed probability, isolation, fresh-load or retained-outcome rules.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-001-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). The documented engineering and cross-owner dependencies remain open. Approval does not authorize implementation, coding tasks or another feature review.
