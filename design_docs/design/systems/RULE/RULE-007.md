# RULE-007 — Skill threshold and level conversion

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Provide shared skill-practice requirements and level-threshold calculations, keeping authoritative advancement/eligibility and their explanations consistent.

## Intended player experience

Permanent development determines practice requirements and earned level eligibility. Pending levels do not increase practice requirements until claimed. Players can inspect the contributing rules; level progress does not disagree with gameplay or conceal pending rewards. Loading preserves development rather than generating it again.

## Confirmed requirements

RULE-007-D01–D03 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish actual claimed level as the captured exponent input, vanilla T=1 at zero skill, and inspectable progression breakdowns without placing raw counters in the ordinary character-sheet view.

CHAR-013 already approves the skill formula, reflex comparison/raw carryover rounding, immutable check context and advancement policies. CHAR-014 already approves contribution ranking, preserved initial baseline/earned target, mathematical-floor candidate conversion and shared progress calculation. CHAR-012 governs raw counter visibility and ownership. This feature consolidates those requirements rather than reopening them.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateSkillUsesForAdvancement` computes floor(skill × skill factor × career factor × 1.04^level × 2/5 + 1), with a formula replacement hook.
- `CalculatePlayerLevel` computes `(currentSum−startingSum+28)/15` with integer division before Mathf.Floor. The outer floor therefore does not correct truncation toward zero for negative numerators. Intended mathematical floor follows approved CHAR-014 instead.
- `Game/Entities/PlayerEntity.cs#RaiseSkills` supplies permanent skills and player Level for requirements and compares against reflex-scaled tallies. Exact source consumption/mastery ordering differs from approved snapshot/carryover alternatives under CHAR-013.
- `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#LevelButton_OnMouseClick` separately calculates float progress rather than sharing the resolved level override. The intended shared calculation follows CHAR-014.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full runtime/override parity and supported numeric extremes remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Skill requirement and practice conversion

For permanent skill S, positive skill factor k, positive career factor c and actual claimed level L, use vanilla requirement T=floor(S×k×c×1.04^L×2/5+1). Capture L and other global check inputs at advancement-check start. Highest earned/unclaimed level does not substitute for L, and a reward cannot change L partway through that check.

Use permanent skill rather than temporary live value. Vanilla S=0 gives T=1; no additional minimum practice rule is introduced. Valid requirements must be positive supported integers, with finite safe intermediate arithmetic. Invalid inputs/overflow fail explicitly rather than becoming a threshold of zero, a wrapped value or a silent default.

For raw practice U and fixed positive reflex multiplier r, scaled practice E=floor(U×r); qualification is E>=T. In approved carryover mode, raw cost is Q=ceil(T/r), at least 1. The floor/ceil operations must agree at boundaries. The formula itself does not mutate U or grant skills.

CHAR-013 owns reset/carryover, blocked consumption, mastery/caps, finite multipoint gain limits, check cadence and actual permanent mutations. In multipoint carryover, recompute T for each staged increased S while retaining the check-start global context, including L. Do not subtract scaled units from raw counters or invent another advancement route through UI queries.

Use the approved skill-specific factors and resolved career/reflex inputs from their owners. Validate factor mappings for supported added skills. Requirements above available scaled counter capacity must be reported/validated under CHAR-013 rather than silently clamped to make progression possible.

### Contributions and level candidate

Vanilla contributing sum V is all three permanent Primary values plus the two highest permanent Major values plus the highest permanent Minor value. Re-rank on relevant permanent changes. Ties cannot change the numeric result. Supported mod contribution policies follow CHAR-014; this specification does not add tier slots or arbitrary grant exclusions.

Preserve initial sum V0 captured after all approved initial skill changes. Vanilla offset O=28 and step P=15 give candidate F=floor((V−V0+O)/P), using mathematical floor even for negative numerators. This explicitly differs from DFU integer truncation in those cases.

CHAR-014 owns highest earned target K=max(previous K,actual level A,F) and pending count N=K−A. Skill loss cannot lower K/A or revoke backlog; regaining lost territory cannot award the same levels again. Candidate F is an input, not a command to set actual level or grant health/points. CHAR-015 alone claims rewards under its atomic commitment rules.

### Shared progress and explanations

Use the same resolved contribution policy, offset, step and threshold semantics for gameplay and UI. A replacement hook/configuration must supply enough consistent threshold information for truthful display; a standalone candidate override that leaves vanilla progress visible is not sufficient. Concrete extension contracts remain RULE-004/owner dependencies.

For target j, vanilla/general offset-step threshold is Vreq(j)=V0+P×j−O. Show actual A, pending N and progress toward the next unearned level K+1. The progress fraction is q=clamp((V−Vreq(K))/P,0,1), with the clamp affecting display only. Show remaining contributing points where useful, particularly for the vanilla early threshold. Exact precision/layout remains UI scope.

Provide inspectable skill requirement, relevant permanent skill/factors/actual level/reflex scaling and raw practice required to qualify. Raw requirement Q is distinct from current raw counter U; preserve CHAR-012's exclusion of raw counters from ordinary character-sheet view. Current counters remain available in appropriate developer diagnostics; no new mandatory player-facing counter display is authorized. Breakdowns and next-level information must use shared resolved data without mutation, draws or reward claims.

## Relevant formulas and parameters

- T=floor(S×k×c×1.04^L×2/5+1).
- E=floor(U×r); qualification E>=T; carryover raw cost Q=ceil(T/r).
- V=sum(Primary)+sum(top two Major)+max(Minor), using permanent values.
- F=floor((V−V0+28)/15), with configurable supported O/P under CHAR-014.
- Vreq(j)=V0+P×j−O; next-unearned display q=clamp((V−Vreq(K))/P,0,1).

At ordinary level-1 initialization V=V0 gives F=1. Level 2 requires +2 contributing sum points; later thresholds are 15 points apart. Initial q=13/15, approximately 86.7%, as already approved in CHAR-014. A lower-ranked Major/Minor increase may not change V. For numerator −1 and P=15, F=−1 rather than truncation's zero; CHAR-014's retained target prevents deleveling.

For S=0 and valid factors, T=1. At r=0.75, Q=2; at r=1.25, Q=1. These are threshold/cost examples, not changes to the approved reflex selection or practice cadence.

## Required data

Stable skill/tier IDs; permanent values and factor mappings; current career/reflex factors; actual/check-start level; raw counters owned by CHAR-012; resolved threshold configuration/provenance; contribution policy and ranked sum; preserved V0/A/K; and shared requirement/threshold/progress breakdown. Concrete schemas, version metadata and caches remain engineering/SAVE dependencies.

## Inputs, outputs and events

Inputs: validated immutable advancement-check context, approved contribution/formula configuration and committed permanent skill/claim changes. Outputs: positive requirement, scaled comparison/raw cost, contribution sum/candidate/threshold/progress or explicit invalid-state result. These are conceptual contracts, not selected APIs/signals. CHAR-013/014 own mutations and notifications; queries cannot independently award gains or levels.

## Cross-system interactions

CHAR-005 supplies career factor; CHAR-010 reflex scaling; CHAR-011 permanent state; CHAR-012 raw counters; CHAR-013 check policy/gains; CHAR-014 baseline/earned target/progress; CHAR-015 actual level claims. DATA-003 validates locked definitions and RULE-004 validates supported hooks/selection/failure handling. UI/DEV consume shared explanations. CORE/SAVE coordinate readiness, consistent restoration and stale-work rejection. No randomness is required by these pure calculations.

## Edge cases and failure conditions

- Zero skill yields T=1; temporary skill boosts cannot reduce threshold or create mastery.
- Pending unclaimed levels do not raise L; later checks after a committed claim use the new actual level.
- Multipoint staging changes S per point without changing check-start L or introducing order-dependent global mastery behavior.
- Nonfinite factors/exponentiation, overflowing sums/products, unsupported levels and nonpositive step/requirements fail explicitly. Validate intermediates as well as final values.
- Negative contribution differences require floor, while legitimate retained K/backlog prevents level loss.
- Missing skill IDs/factors, impossible ranking policies and invalid baseline are errors rather than successful zero/estimated baseline.
- Formula overrides cannot leave UI explaining a different threshold. If compatible progress cannot be derived, reject the unsupported contract through explicit validation/recovery.
- Changed policy cannot reinterpret saved baseline/earned eligibility silently. Duplicate evaluation and UI refresh cannot grant another reward.

## Configuration and balancing options

Retain CHAR-013's validated skill factors/threshold growth and scale parameters and CHAR-014's supported contribution/offset/step customization. Career/reflex settings remain their owners' inputs. Require finite compatible domains, positive supported requirements/step, complete identities and achievable/explicitly validated counter relationships. No new player slider, automatic balancing, arbitrary formula interpreter or independent raw-counter cap is introduced. Explicit hooks follow RULE-004 and must honor shared threshold/display contracts.

## Save/load considerations

Preserve permanent skills, raw counters, actual level, fixed character progression policies and CHAR-014 baseline/earned target under their owner contracts. Rebuild derived sums/thresholds/progress without granting gains, estimating a replacement baseline or claiming levels. Saved caches are not extra authority. Configuration/version changes require explicit migration/recovery; loading cannot silently switch policy or use current UI defaults. Capture incomplete checks/claims consistently under CHAR/SAVE rather than retrying half-applied mutations.

## Technical constraints

Target: Godot 4.7.2. Use pure explicit-input calculations, safe sums/products/exponentiation and numerically consistent mathematical floor/ceil. Do not copy integer-before-floor behavior or independent UI expressions. Concrete numeric representation, API/hook design, caching and serialization remain dependencies. No implementation, coding tasks or runtime tests are authorized by this draft.

## Acceptance criteria

1. Vanilla T matches the approved formula at representative boundaries, including S=0 yielding 1, with actual claimed check-start level rather than earned target.
2. Reflex qualification and Q agree at integer boundaries; multipoint staging recomputes S-dependent T without changing global check context.
3. Vanilla contribution ranking and floor conversion yield +2 sum for level 2, then +15 steps; negative numerators use mathematical floor.
4. Skill losses cannot revoke earned levels/backlog or let regained skills duplicate eligibility; queries never apply rewards.
5. Gameplay/UI share resolved rules and show actual/pending/next-unearned progress, including initial 13/15 behavior.
6. Inspectable requirements expose relevant factors/raw cost without adding raw counters to ordinary character-sheet view or consuming randomness.
7. Invalid/overflowing inputs, missing definitions or incompatible overrides fail explicitly without clamping/fallback/estimated baseline.
8. Save/load retains authoritative development/configuration and rebuilds derived values without replay or duplicate gains/claims.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-012/013/014/015 and RULE-004. Actual-level snapshots refine CHAR-013's level input without changing its approved cadence/consumption/mastery rules. Shared progress and mathematical floor preserve CHAR-014's explicit choices, including the unusual early first threshold. Inspectable raw requirement is not a player-facing raw counter, preserving CHAR-012. This feature does not alter previously approved constants or authorize arbitrary overrides of retained eligibility.

## Outstanding questions and approval

No blocking gameplay policy question remains. Before implementation: complete factor/consumer mappings, supported numeric domains and reliable exponent/floor/ceil representation, shared override/progress contracts, UI placement and coherent CHAR/SAVE integration. These cannot waive actual-level input, T=1 vanilla zero-skill behavior, shared display rules or preserved baseline/backlog.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-007-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
