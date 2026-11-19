# RULE-014 — Damage amount and bonuses

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Resolve numeric damage after authorized hits using route-specific rolls/bonuses, explicit creature weapon/material policies and retained critical context. Keep health/equipment/poison/enchantment mutations separate.

## Intended player experience

Weapon, skill and situational bonuses produce explainable damage. Hits may deal zero by default. Creature strengths/weaknesses can distinguish weapon categories/materials and be expanded by mods. An optional critical damage mod multiplies numeric damage without rolling critical status again or duplicating effects.

## Confirmed requirements

RULE-014-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm moddable route baselines/order, zero/default and moddable successful-hit minimum, optional configurable critical multiplication with ×2 preset, safe hand-to-hand bounds, moddable backstab, nonnegative independent monster components, minimum-after-multipliers, extensible creature weapon/material policies and nonrandom previews.

RULE-012 owns route/material gates/components; RULE-013 supplies selected part, successful hit and retained critical status/mode. RULE-005 supplies live Strength damage modifier. RULE-001/003 govern unbiased owned draws/results; RULE-004/DATA-003 govern validated locked extensions and recovery.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateWeaponAttackDamage` rolls inclusive weapon base range plus supplied damage modifiers; applies skeletal-warrior flag-based edged halving then silver doubling; adds live Strength/material bonuses; sets values below 1 to zero; adds enemy-type adjustment; calls AdjustWeaponAttackDamage.
- `CalculateHandToHandMinDamage/MaxDamage` use integer skill/10+1 and skill/5+1. `CalculateHandToHandAttackDamage` rolls that range, adds supplied modifiers, adds Strength for player only, then enemy-type adjustment.
- `CalculateAttackDamage` invokes backstab for successful weapon/humanoid hand-to-hand routes. Monster slots roll authored ranges, invoke monster effects and add enemy-type adjustments to the aggregate on positive hits. Final aggregate clamps nonnegative.
- `CalculateSwingModifiers` supplies signed swing bonuses; `CalculateProficiencyModifiers` grants level/3+1 damage for applicable proficiency, including hand-to-hand; `CalculateRacialModifiers` supplies weapon-conditioned racial bonuses.
- `CalculateBackstabChance` returns live Backstabbing and tallies practice when facing context qualifies. `CalculateBackstabDamage` separately rolls when skill>1 and triples damage on success.
- `GetBonusOrPenaltyByEnemyType` applies signed attacker-level career bonuses/phobias using target category, including vampire-player undead classification. Full trait/group semantics remain owner validation dependencies.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete material/trait/caller/effect behavior and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Shared rules

Resolve damage only after a valid route/material gate and actual hit. Failed gates, misses, ineffective materials and invalid attacks do not receive damage rolls or a positive minimum. Use explicit owned combat randomness and inclusive uniform integer base rolls. Retain resolved rolls for technical retries; do not reroll them during display or repeat effects.

Preserve route-specific calculations rather than automatically giving every route all bonuses. Supplied damage modifiers must have explicit provenance so swing/proficiency/racial contributions are not counted twice. Use actual claimed level where those approved baselines depend on player level; NPC level/trait adapters remain explicit owner inputs.

### Weapon route

Baseline order:

1. Roll weapon base minimum..maximum inclusive, add supplied swing/proficiency/racial damage modifier.
2. Apply applicable creature weapon/material adjustment policy. Skeletal-warrior baseline halves edged damage with division toward zero, then doubles silver damage.
3. Add RULE-005 live Strength modifier and validated weapon material damage modifier.
4. Set values below 1 to zero, preserving the source's intermediate clamp.
5. Add applicable enemy-type bonus/penalty, then explicit weapon-damage adjustment hook.
6. Apply eligible successful backstab multiplier, then nonnegative normalization, optional retained-critical multiplication and final successful-hit minimum below.

Material damage bonus is distinct from RULE-012 material eligibility and RULE-013 material accuracy. Passing eligibility does not imply positive damage; a damage policy cannot silently override a failed material gate.

### Humanoid hand-to-hand route

For valid live Hand-to-Hand S, default raw endpoints are trunc(S/10)+1 and trunc(S/5)+1. Limit each endpoint to at least 1 before rolling. Validate ordered supported endpoints after configuration; do not swap malformed ranges. This explicitly supports negative live skills without negative/reversed damage rolls. Parameters are moddable.

Roll inclusive range; add supplied bonuses; add live Strength damage modifier for the player only under the baseline; add applicable enemy-type adjustment; apply eligible backstab and common postprocessing. Humanoid enemy hand-to-hand does not silently acquire the player-only Strength bonus. Later penalties can still yield zero final damage.

### Monster natural route

For each RULE-012 component that passes gate and hit, roll its authored valid positive inclusive range and apply applicable ordinary component/enemy-type modifiers. Clamp that component nonnegative before critical multiplication and final minimum. Sum completed component results safely; a component's penalty cannot subtract damage already produced by an earlier one. This deliberately differs from DFU aggregate penalty placement.

Do not automatically add player Strength, swing/proficiency/racial or backstab bonuses to natural components merely because other routes use them. Supported mod policies must explicitly declare their route applicability. COMBAT owns whether later components continue after actual effects/death/interruption; numeric summation is not permission to precompute stale effect outcomes.

### Backstab

Owner-qualified backstab uses live Backstabbing as its baseline accuracy contribution under the supplied RULE-013 route context. After a successful eligible weapon/humanoid hit, resolve a separate RULE-001 backstab check only when skill>1. On success multiply then-current route damage by 3. Threshold, contribution and multiplier are moddable.

Facing, authorization and practice eligibility/amount/cadence belong to COMBAT/CHAR. Pure chance/damage queries cannot tally practice. The retained critical check has already occurred before hit under RULE-013; backstab resolves later during successful damage. No backstab roll occurs for misses. Baseline qualifying zero-damage hits still follow the declared backstab check rather than silently adding a positive-damage gate.

### Critical extension and final minimum

Vanilla Critical Strike is accuracy-only. Explicitly support a mod that replaces accuracy with damage, or enables both, reusing RULE-013's retained critical result. When that policy enables damage and the component both critically qualifies and hits, multiply its nonnegative damage after ordinary bonuses/backstab by validated multiplier m; floor the product. Provide ×2 as the default optional damage-mod preset, not a vanilla change.

Then apply configured final successful-hit minimum K, default 0, per hit/component. Thus result=max(K,floor(max(0,ordinary/backstab damage)×m)) when critical damage applies, otherwise max(K,max(0,ordinary/backstab damage)). Require nonnegative supported integer K and finite supported nonnegative m; reject overflow. Zero scaling cannot be interpreted as a material eligibility bypass, and K can raise a successful zero-damage hit when explicitly configured.

Backstab ×3 and enabled critical ×2 compose to ×6 before final minimum. A critical miss has no damage benefit. Multiplication changes numeric damage only; it never repeats poison, enchantment, monster-hit, equipment-wear or notification callbacks. RULE-016/COMBAT/ITEM/MAGIC determine those effects' amount bases and timing explicitly.

### Creature weapon/material policy extension

Mods must be able to add creature-specific strengths/weaknesses for supported weapon types/categories and materials, beyond the skeletal-warrior example. Use stable creature/category/material identities and validated tags rather than unexplained bit flags.

Each policy declares target matching, weapon/material conditions, route applicability, adjustment stage, factor/operation, rounding and ordering/composition. The skeletal baseline uses edged halving then silver doubling at the pre-Strength/material-addition stage. Additional policies cannot rely on registration order or accidental repeated application; overlapping rules require a declared supported composition/conflict contract before use. Concrete schema, defaults for new overlaps and supported operations remain owner dependencies, not permission for arbitrary effect code.

These damage strengths/weaknesses differ from material immunity/eligibility. Unknown required tags/ranks/targets are validation errors, not silent no-op matches. Nonstandard creature anatomy or new weapon classes need complete consumer mappings.

### Presentation

Damage previews expose ranges and conditional backstab/critical branches without consuming randomness, granting practice or applying effects. Show actual roll/stage breakdown after resolution in diagnostics. Label assumptions and relevant target policies rather than promise a fixed amount from a range. UI/DEV layout and visibility remain owner scope.

## Relevant formulas and parameters

- Strength modifier=floor((live Strength−50)/5), under RULE-005.
- Hand-to-hand endpoints=max(1,trunc(S/10)+1), max(1,trunc(S/5)+1).
- Backstab baseline: eligible skill>1, probability from live skill, multiplier 3 on success.
- Critical optional preset m=2; vanilla damage multiplication disabled.
- Final successful-hit minimum K=0 by default, after nonnegative normalization/backstab/critical; monster total is sum of finalized successful components.

Example: positive damage 7 with successful ×3 backstab and enabled ×2 critical becomes 42 before minimum. A half operation on 5 yields 2 toward zero, then silver doubles to 4 before Strength/material addition. A natural component with roll 2 and penalty −5 produces zero by default, without reducing an earlier component's damage. A missed component remains zero even if configured K=1.

## Required data

Valid route/hit/component context; selected weapon/authored ranges; live skill/Strength and supplied signed modifiers; target category/creature tags and matched policies; material modifiers; backstab eligibility/skill/result; retained critical result/mode/multiplier; final minimum; provider provenance; owned source and retained roll/application context. Concrete schemas and policy receipts remain dependencies.

## Inputs, outputs and events

Inputs: authorized successful-hit context and validated damage policies, or nonrandom previews. Outputs: retained base/backstab results, staged numeric damage/breakdown or explicit failure. Calculating damage does not itself remove health or apply poison/wear/effects. COMBAT publishes committed changes through their owners; API/event names remain unselected.

## Cross-system interactions

Confirmed projectile refinement: COMBAT-009-D04 captures arrow offensive stats/modifiers at release while reading current defender defenses at impact; target-dependent bonuses use actual contacted target and captured source data. Later shooter buffs/debuffs/death do not rewrite the shot. This explicitly qualifies ordinary live offensive-input evaluation. See [COMBAT-009](../COMBAT/COMBAT-009.md) for separate approval status and field/hook adapter dependencies.

RULE-012 supplies routes/material/components; RULE-013 supplies body part/hit/critical; RULE-005 Strength; ITEM weapon/material data; CHAR/NPC racial/career/category context. RULE-016 and COMBAT/MAGIC/ITEM own side effects. RULE-001/003 govern draws/retries and RULE-004/DATA-003 validated hooks/locking. CHAR-018 owns health mutation; CORE/SAVE retain readiness/results; UI/DEV observe without draws.

## Edge cases and failure conditions

- Valid negative live hand-to-hand yields bounded endpoints, while malformed/overflowing configured ranges fail explicitly.
- Signed penalties cannot create healing or subtract earlier component damage; misses cannot acquire minimum damage.
- Fractional multipliers round at declared stages, not with an undocumented combined rational operation. Unsafe values/hooks fail without fallback or reroll.
- Zero-damage hits remain distinguishable from misses; whether they trigger effects is RULE-016/owner scope, not inferred from numeric minimum.
- Duplicate creature rules, unknown tags and unsupported composition fail validation rather than applying arbitrary order or repeated factors.

## Configuration and balancing options

Support validated route/base/bonus parameters, special-target policies, backstab parameters, optional critical modes/multiplier and final minimum through explicit schemas/hooks. Weapon base tables/material coefficients and career/racial effects require complete owner data contracts. No universal armor reduction, extra damage type, automatic critical effect duplication or arbitrary combat interpreter is introduced.

## Save/load considerations

Retain owner-required resolved hit/critical/backstab/base-roll results and application state. Restoration cannot draw again for damage or replay health/equipment/effects. Future unresolved attacks use fresh RULE-003 sources while previously retained results remain fixed. General mid-attack save support and partial mutation recovery belong to COMBAT/SAVE. Changed policy definitions require explicit compatibility/migration, not silent recomputation of committed outcomes.

## Technical constraints

Target: Godot 4.7.2. Use explicit staged calculations, unbiased inclusive draws, safe signed arithmetic and declared rounding. Expose retained critical context and creature-policy stages without mixing numeric queries with mutations. Concrete numeric domains/interfaces/serialization remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Weapon/humanoid/natural baselines follow their distinct order; modifiers are neither double-counted nor silently shared across routes.
2. Hand-to-hand endpoints handle negative valid skills safely; configured range errors fail before draws.
3. Backstab uses owner eligibility, threshold>1, separate retained skill check and moddable ×3 baseline after hit.
4. Optional critical ×2/validated alternatives reuse retained critical status after backstab, floor once at that stage and support replace-accuracy/both modes.
5. Final minimum applies per successful component after multipliers; misses/gates/material failures remain zero and component penalties cannot reduce earlier results.
6. Skeletal adjustments use explicit tags/ordered halving then silver doubling before additions. Mods can add validated creature weapon/material policies with declared conflict/composition semantics.
7. Previews make no draws/effects; retries/restore do not reroll or duplicate numeric/effect application.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-001/003/004/005/012/013. Critical damage integration now declares multiplier preset, stage, rounding and multiplicative backstab stacking while vanilla stays accuracy-only. Material eligibility remains prior and distinct. Independent natural clamping deliberately replaces aggregate penalty coupling. Effect timing/amount bases remain RULE-016/COMBAT scope rather than implicit duplication from multipliers.

## Outstanding questions and approval

No blocking policy question remains for these damage calculations. Before implementation: finalize full base/material/trait adapters, parameter domains, creature-policy overlap schema, hook/stage interfaces, critical-result integration, phased component effects, UI assumptions and SAVE/application recovery. These cannot waive mod-extensible creature strengths/weaknesses, retained critical status, per-hit minimum order or route-specific arithmetic.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-014-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering, creature-policy composition and combat-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
