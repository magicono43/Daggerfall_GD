# CHAR-009 — Starting skill allocation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Generate starting skill baselines and allocate class-tier bonuses while integrating biography effects transparently and exactly once.

## Intended player experience

Distribute separate Primary, Major and Minor pools, inspect how rolls and biography affect every skill, and revise allocations without losing points or rerolling through navigation. Validated added skills participate through the same rules.

## Confirmed requirements

CHAR-009-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish vanilla uniform ranges, independent tier pools, retained draft rolls, no skill-reroll controls, separate biography disclosure, final 0–100 limits, validated mod overrides/added skills and every-outcome allocation feasibility.

CHAR-004 retains exactly 3 Primary, 3 Major and 6 Minor distinct skills. CHAR-006 owns retained answers/effects and random biography outcomes. CHAR-001 permits summary allocation edits and preserves navigation state. CORE-012 applies biography before starting grants and captures progression baseline after all starting skill changes.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/DaggerfallSkills.cs#SetDefaults` rolls each skill uniformly with Unity integer Random.Range(3,7).
- `Game/UserInterface/SkillsRollout.cs#Reroll` initially sets defaults, then replaces selected-tier values with Primary 28+Random.Range(0,4), Major 18+Random.Range(0,4), Minor 13+Random.Range(0,4). Each of three allocation spinners receives six points.
- `AddSkillPoint` spends one point from the associated tier; `RemoveSkillPoint` refunds down to the rolled baseline. The inspected addition handler has no explicit upper-cap check. Labels add biography SkillBonuses to working values rather than baking them into those values.
- `Game/UserInterfaceWindows/CreateCharAddBonusSkills.cs#SetCharacterDocument` either generates or restores values and supplies `BiogFile.GetSkillEffects`. Explicit OK blocks positive remaining pools. No player-facing Reroll or Save/Load Roll controls are defined on this screen.
- `DaggerfallStartNewGameWizard.cs` uses skillsNeedReroll; returning through biography selection can mark skills for reroll. Intended retention through biography edits explicitly differs. Summary handlers copy allocations/pools back to previous screens.
- `API/BiogFile.cs#ApplyEffects` applies biography skill changes during `Game/Utility/StartGameBehaviour.cs#StartNewCharacter` startup.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Runtime navigation, full effect values and mod combinations remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Generation and identity

Roll each skill's starting baseline independently and uniformly over the resolved inclusive integer range. Vanilla ranges: Primary 28–31, Major 18–21, Minor 13–16 and other skills 3–6. Generate once for the compatible creation draft; store actual results by stable skill ID rather than localized name or array order.

Keep the twelve chosen class-tier skills distinct. Validated added skills may occupy tier slots under CHAR-004 or remain other skills, in which case they use resolved other-skill generation rules. Extensibility does not change the fixed 3/3/6 counts. Required skill definitions must provide supported rule/effect/UI/persistence contracts; adding a label alone is insufficient.

No dedicated skill Reroll or Save/Load Roll control is introduced. Backtracking, biography edits, preview updates and CHAR-008 attribute rerolls cannot regenerate skills by implication. An incompatible class/tier change cannot silently reuse values against different rules; integration must follow approved class-change/navigation policies and explicit validation. Exact invalidation mechanics remain deferred rather than authorizing a navigation reroll exploit.

### Allocation

Give six points separately to Primary, Major and Minor tiers by default. Spend one point per increase, only within the corresponding tier. Refund allocated points to that same pool, never below the rolled baseline. Do not transfer points across tiers or allocate these pools to other skills.

Require all three original pools to be fully allocated before accepting this stage or completing creation. Validate actual allocations and original budgets, not spinner labels alone; negative pools or inconsistent totals cannot pass. Summary edits use the same constraints.

### Biography and final values

Keep baseline, allocated increase, biography adjustment and resulting starting value separately inspectable. Include other skills affected by biography, even though they have no tier-allocation controls. Apply the same validated owner rules to previews and startup. UI can summarize differences, but must not imply raw working values already contain applied biography effects.

Vanilla final starting skills must be within inclusive 0–100 after allocation and biography. Validated mods may override these creation limits. These limits are an explicit intended addition beyond the inspected uncapped allocation handler, not a claim of source parity or an approval of later mastery/runtime limits.

Changing answers recomputes biography effects against retained skill rolls and allocations. Revalidate the result; do not reroll skills, silently clamp values, discard bonus points or change the answer automatically. A result requiring correction remains visibly invalid until corrected by legal allocation or biography edits. If no legal allocation exists, report the incompatible combination and require correction/content recovery.

At entry, commit allocated baselines and apply biography effects once under CORE-012; previewed adjustments must not be added twice. Capture progression baseline after all initial changes so starting skills are not counted as earned advancement. Exact startup representation and effect arithmetic remain owner contracts, preserving the approved supported classic baseline.

## Relevant formulas and parameters

For each skill i, let s_i be rolled baseline, a_i its nonnegative allocated increase, beta_i the biography adjustment and f_i=s_i+a_i+beta_i the final starting value for supported additive skill effects. Working pre-biography value is s_i+a_i. Non-additive future extensions require an explicit owner contract, not automatic use of this formula.

For tier g with original pool P_g, remaining R_g=P_g−sum(a_i for i in g). Require 0≤R_g≤P_g during valid allocation and R_g=0 at completion. For other skills a_i=0. Final limits L_i≤f_i≤U_i default to 0 and 100.

For a fixed rolled/biography context, legal allocation bounds are a_min_i=max(0,L_i−s_i−beta_i) and a_max_i=U_i−s_i−beta_i. Each a_max_i must be at least a_min_i; each tier must satisfy sum(a_min_i)≤P_g≤sum(a_max_i). Other skills must already fit final limits without allocations. Thus negative biography effects can require some points while high effects can reduce capacity.

Resolved ranges/pools/limits must use supported integers, ordered bounds and nonnegative pool sizes. Validate feasibility for every supported random outcome, including relevant supported biography outcomes, without selectively redrawing/clamping. A changed incompatible answer/context produces explicit correction, not a new skill draw. Exact range-analysis and domain compatibility checks remain technical dependencies; every-outcome coverage cannot be waived by sampling a few fortunate rolls.

## Required data

Stable supported skill IDs and tier membership; resolved tier/other ranges, pool sizes and creation limits; retained rolled baselines; original pools/allocations/remaining balances; current validated biography adjustments; final values and context-aware feasibility results. Definition provenance and compatibility/version context are needed for owner diagnostics; concrete schemas remain deferred.

## Inputs, outputs and events

Inputs: completed career tiers, validated skill definitions/configuration, initial random inputs, allocations/refunds, biography changes, navigation and acceptance. Outputs: retained candidate values, tier balances, transparent previews or actionable incompatibility, and validated starting-skill intent. These are conceptual contracts, not approved API/signal names. Editing is not a live practice/advancement event.

## Cross-system interactions

CHAR-001 owns flow/summary/discard; CHAR-003/004 provide tiers; CHAR-006 supplies biography and retained random outcomes; CHAR-008's attribute rerolls are separate. DATA-003/008 and skill-definition owners resolve content. CHAR-011/012–015 own permanent/live skill semantics and later progression. CORE-007/011/012 validate/apply entry and progression baseline. UI displays all affected skills; SAVE preserves completed character skills/identity.

## Edge cases and failure conditions

- Missing/duplicate tier IDs, malformed ranges, negative pools and unsupported added skills cannot publish a valid candidate.
- A biography bonus can exceed a limit even before allocation; a penalty can require allocation or make an other skill invalid. Report the actual issue without hidden correction.
- Full legal capacity must suffice for all pool points; do not strand the player or permit cross-tier transfers to conceal an invalid configuration.
- Refunds restore only allocated points, never biography/rolled points. Repeated input cannot duplicate funds or values.
- Re-entering biography/skill/summary screens does not reroll or repeatedly apply effects. Attribute rerolls cannot become a skill reroll route.
- Translation/reordering/added skills cannot remap saved values by positional coincidence.
- Restart/exit clear retained skill state; another character cannot inherit it.

## Configuration and balancing options

Validated mods may override starting ranges, per-tier pool sizes and creation limits and add supported skills. Preserve uniform generation, fixed 3/3/6 counts, tier isolation and full allocation. Content configuration remains locked under DATA-003. No dedicated reroll, unrestricted point-buy or pool-transfer mode is introduced.

## Save/load considerations

Unfinished rolls/allocations are transient under CHAR-001. Completed saves preserve actual skill values and stable identities under SAVE/CHAR-011, without rerolling or reapplying biography. Captured entry intent preserves values through safe CORE-007 retry. Removed/reordered/modded skills require explicit compatibility/migration; do not silently map an old array index to a different skill or clamp saved values to new creation rules.

## Technical constraints

Target: Godot 4.7.2. Separate generation, allocation, biography evaluation, validation and display. Use stable IDs and safe arithmetic, with authoritative total/limit checks on every completion path. Preserve explicit random context and retained outcomes. APIs, schema/versioning, RNG streams and UI layout remain implementation choices. Reference source/content remain read-only.

## Acceptance criteria

1. Vanilla skills use independent uniform inclusive ranges 28–31/18–21/13–16/3–6 according to tier membership.
2. Three separate six-point pools spend/refund at one point per increase, stay within their tiers, never reduce below baseline and require full allocation.
3. Draft navigation, biography edits and attribute rerolls preserve skill rolls; no player-facing skill-reroll controls are introduced.
4. All affected skills expose baseline/allocation/biography/result separately; biography is committed only once at startup.
5. Final values satisfy vanilla 0–100 or resolved validated mod limits. Invalid combinations require correction, without clamping, point loss or redraw.
6. Added supported skills use stable IDs, resolved other-skill rules when untiered and fixed 3/3/6 counts when tiered.
7. Every supported random outcome is feasible for full pools under the validated compatible context; malformed/impossible content fails truthfully.
8. Summary/alternate input paths enforce actual pool/limit invariants; repeated input cannot multiply points/effects.
9. Starting changes precede progression baseline; entry retry/load does not regenerate skills or duplicate biography effects.
10. Restart/exit discard unfinished state; completed saves preserve stable skill identity and values under explicit compatibility rules.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001/003/004/006/008, DATA-003/008 and CORE-007/011/012. No direct contradiction identified. CHAR-008 deliberate attribute rerolls do not imply skill rerolls. Final 0–100 skill limits are explicitly approved new behavior. Biography-answer revision retains rolls and can require correction without contradicting fixed outcome retention. Fixed counts coexist with extensible skill IDs; preview separation prevents duplicate startup effects.

## Outstanding questions and approval

No further blocking starting-skill policy question is identified. Before implementation is complete: verify original skill/biography fixtures; define supported skill schemas/numeric domains and all-outcome feasibility; finalize incompatible tier/rules-context handling under creation navigation; integrate previews/application with progression and SAVE compatibility; verify RNG streams. These dependencies cannot permit navigation rerolls, pool transfers, hidden clamping or duplicate effects.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-009-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented feasibility/schema, owner-integration and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
