# CHAR-008 — Starting attribute rolls and allocation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Convert class base attributes into rolled starting values and a player-directed bonus allocation, supporting deliberate rerolls and comparison without navigation-based rerolls or point loss.

## Intended player experience

Roll a character's attributes, distribute bonus points, see resulting mechanical previews and optionally keep one candidate while trying others. Revisiting screens preserves the current result. Modded ranges remain valid for every possible roll.

## Confirmed requirements

CHAR-008-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm uniform independent bonuses, full-pool allocation/refunds, caps, unlimited deliberate rerolls, one temporary complete-state slot, live derived previews and every-outcome mod feasibility.

Inherited CHAR-004 class bases are distinct from these later bonuses. CHAR-001 preserves navigation results, permits attribute editing in final summary and clears unfinished drafts on Restart/exit. CHAR-006 biography outcomes and CORE-012 startup effects must remain distinct from preview values. DATA-003 governs resolved mod configuration and its lock.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterface/StatsRollout.cs#Reroll` reads class base stats, adds a separate Unity integer Random.Range(0,11) per attribute and rolls Random.Range(6,15) for the allocation pool. SetStats copies rolled and working values separately.
- Spinner handlers spend/refund one point. Ordinary mode stops decreases at rolled starting values and increases at FormulaHelper.MaxStatValue or an empty pool. Custom-class free-edit mode is separate and is not the CHAR-008 allocation rule.
- `Game/Formulas/FormulaHelper.cs#MaxStatValue` defaults to 100, with an override hook.
- `Game/UserInterfaceWindows/CreateCharAddBonusStats.cs`: Reroll, SaveRoll, LoadRoll handlers and derived labels. Save stores rolled values, working values and remaining pool; Load restores them. Explicit OK tests for positive remaining points, so intended authoritative validation is stricter than that isolated UI guard.
- `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs`, SetAddBonusStatsWindow/AddBonusStatsWindow_OnClose: rolls on initialization/career-reference changes, copies rolled/working stats and restores values on certain backtracking paths. `CreateCharSummary.cs` edits allocations further.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; statistical behavior, mod combinations and runtime navigation have not been tested. Source remains unchanged.

## Detailed rules and behaviors

### Generation and allocation

For each of the eight attributes, independently draw an integer bonus uniformly from 0–10 inclusive and add it to the selected class base. Separately draw an integer allocation pool uniformly from 6–14 inclusive. Keep class base, rolled baseline, pool originally awarded, current allocated values and remaining points distinguishable.

Each manual increase costs one point; each decrease refunds one previously allocated point. Never reduce below the rolled baseline or increase above the resolved creation cap, vanilla 100. Do not exchange rolled baseline points between attributes. Completion requires the entire original pool allocated legally, not simply a displayed zero balance. Negative, forged or inconsistent pool/value states fail validation.

Class bases are CHAR-003/004 inputs, not overwritten shared definitions. This feature does not add race/gender attribute adjustments or change later progression caps. Downstream owner compatibility must hold for configured creation values.

### Reroll and temporary slot

Allow unlimited deliberate Reroll. A reroll replaces all eight rolled bonuses, current allocations and the allocation pool together. It does not reroll biography rewards, name suggestions or skills by implication. Mere navigation, summary visits or preview updates consume no attribute-generation randomness.

Provide one temporary Save Roll/Load Roll slot within the creation draft. Save replaces its prior contents with rolled baselines, original pool, current allocation, remaining points and relevant class/rules context. Partial allocation is valid to save. Reroll leaves this slot intact. Load restores the complete saved state and updates previews without consuming randomness or merging allocations. Empty Load is disabled.

Do not restore saved values against different class bases or resolved allocation rules. Compare actual relevant identity/values/configuration, not only a class display name or UI object reference. An incompatible slot cannot be loaded; report the reason rather than reinterpret, clamp or merge it. Exact invalidation/cache representation remains technical scope.

Ordinary navigation preserves current roll/allocation and compatible slot, including final-summary allocation edits. Restart/exit discard all of them under CHAR-001 without discard confirmation. This temporary slot is not a persistent character save or cross-launch draft.

### Derived previews

Show and immediately update damage modifier, maximum encumbrance, spell points, magic resistance, to-hit modifier, HP modifier and healing-rate modifier when allocation, reroll or Load changes values. Use the same responsible formulas/context as gameplay rather than duplicate independent UI approximations.

Clearly label previews that exclude later effects. An attribute-derived magic-resistance or HP modifier is not a promise of final total resistance/maximum health. Class magery and other required context must be supplied truthfully; exact formulas and biography/racial interactions remain owner rules. Previewing never mutates the live character or grants effects.

## Relevant formulas and parameters

Let b_i be class base, r_i the rolled bonus, s_i=b_i+r_i the rolled baseline, c_i the creation cap, x_i the working value, P the original bonus pool and R remaining points.

- Vanilla r_i ~ uniform integers [0,10], independently for eight attributes; P ~ uniform integers [6,14], drawn separately.
- Allocation invariant: x_i≥s_i, x_i≤c_i, R=P−sum(x_i−s_i), and 0≤R≤P.
- Completion requires R=0 and all invariants valid. Vanilla c_i=100.

Validated mods may override bonus ranges, pool range and creation caps. For configured bonus bounds l_i≤u_i, require supported integer arithmetic, valid class/attribute values and b_i+u_i≤c_i for every i. With nonnegative pool bounds Pmin≤Pmax, require sum(c_i−(b_i+u_i))≥Pmax. Together with valid lower baseline/domain limits, these checks ensure even the highest simultaneous attribute roll leaves capacity for the largest pool. Validate downstream owner compatibility as well as these numerical conditions.

Reject invalid configurations before generating a usable roll. Do not redraw selectively, clamp results, shrink the pool or discard points; those approaches would change approved distributions or rewards. Exact supported numeric ranges/lower-domain limits remain CHAR-011/DATA contracts. No shared RNG algorithm or reproducible-seed UI is selected here.

## Required data

Selected class/base identity and values; resolved per-attribute bonus bounds/caps and pool bounds; current rolled baselines, original/remaining pool and working values; temporary slot snapshot/context; validation results; and gameplay formula inputs for previews. Concrete versioned schema and random-stream allocation remain engineering dependencies.

## Inputs, outputs and events

Inputs: valid class/configuration, initial generation, Reroll, point adjustments, Save/Load Roll, navigation, acceptance and preview-owner results. Outputs: isolated draft attributes, updated balance/previews, compatible snapshot or actionable validation error. These conceptual contracts do not approve API/signal names. A completed allocation is not live-player mutation or entry success.

## Cross-system interactions

CHAR-003/004 supply bases; CHAR-001 owns draft/navigation/summary; CHAR-006 supplies retained biography context without duplicate grants. CHAR-011 and relevant RULE/COMBAT/MAGIC/ITEM/movement/recovery owners supply stat domains, formulas and derived context. DATA-003 resolves validated mod overrides. CORE-007/011/012 validate/apply completed entry. SAVE persists completed character state, not the temporary roll slot.

## Edge cases and failure conditions

- Every legal random outcome must be allocatable; a modded high base/cap combination cannot strand the player with surplus points.
- Full caps prevent further increases, but refunds remain possible down to baseline. Values cannot go below baseline through summary or alternate input paths.
- Repeated Save overwrites one slot; empty/incompatible Load cannot consume randomness, partially restore or corrupt the current roll.
- Loading a saved roll replaces current allocations/pool together, preventing point duplication or merging best values from separate rolls.
- Navigation and summary editing preserve outcomes. Deliberate reroll is distinct from entry retry and cannot reroll unrelated biography outcomes.
- Preview failures cannot be disguised as truthful zero/default totals; report owner/data errors and do not accept invalid required state.
- Restart/exit remove current and saved values so another character cannot inherit them.

## Configuration and balancing options

Vanilla ranges/cap remain defaults. Validated mod overrides are scoped to bonus ranges, pool range and creation caps, respecting DATA-003 locking and CHAR-004 base compatibility. Every-outcome feasibility and uniform sampling remain mandatory. No point-buy alternative, reroll fee/limit, multiple saved slots or automatic best-roll selection is introduced.

## Save/load considerations

Current roll/slot are transient unfinished-creation state and cannot resume across application launches. Completed saves preserve actual accepted permanent attributes under SAVE/CHAR-011, without rerunning generation or allocation. Captured new-character intent under CORE-007 preserves accepted values through safe retry. Later mod changes do not authorize silently clamping saved attributes; compatibility belongs to SAVE/DATA owners.

## Technical constraints

Target: Godot 4.7.2. Separate class definitions, random generation, allocation validation, snapshot state and presentation. Validate actual totals/bounds using safe arithmetic; do not trust widgets or pool labels. Use explicit generation context and stable rules/base compatibility. Precision, schemas, RNG APIs and UI details remain implementation choices. Reference source/content remain read-only.

## Acceptance criteria

1. Vanilla generation independently samples eight uniform integer 0–10 bonuses and a separate uniform 6–14 pool without modifying shared class bases.
2. Allocation spends/refunds one point, never crosses baseline/cap and requires the full pool spent under authoritative invariants, including summary paths.
3. Unlimited deliberate Reroll replaces the entire current roll/allocation/pool while preserving the temporary slot and unrelated draft outcomes.
4. Save replaces one complete snapshot; Load restores it exactly without randomness/merging. Empty or incompatible Load cannot succeed.
5. Normal navigation preserves current state and compatible slot; Restart/exit clear both without confirmation.
6. All seven previews update on changes using owner rules and clearly identify excluded later effects.
7. Valid mod parameters remain uniform and feasible for every possible roll and maximum pool; invalid configurations fail rather than clamp, redraw selectively or lose points.
8. Preview/allocation actions never mutate live player state or grant effects. Completed saves/entry retry use accepted values rather than regenerate them.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001, CHAR-003–007 and relevant DATA-003/008 and CORE-007/011/012 constraints. No direct contradiction identified. CHAR-004's 400-point base budget remains separate from later random bonuses. Deliberate unlimited rerolls are an explicit CHAR-008 rule, distinct from CHAR-006's retained hidden reward outcomes. The single temporary slot does not create persistent draft saving. Preview labels preserve owner boundaries rather than imply final total effects.

## Outstanding questions and approval

No further blocking allocation-policy question is identified. Before implementation is complete: define compatible stat domains/numeric ranges, mod schemas and snapshot identity; verify owner preview formulas/context and later-effect labels; establish RNG stream/sampling verification and navigation integration; finalize SAVE compatibility. These dependencies cannot waive uniform distributions, every-roll feasibility or complete-state restoration.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-008-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented numeric/schema/RNG, preview and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
