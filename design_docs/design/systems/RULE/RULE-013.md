# RULE-013 — Hit chance and body part

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Select weighted body parts and resolve physical attack accuracy with explicit modifier arithmetic, critical results and ordered draws. Provide a supported extension for Critical Strike damage mods without duplicate critical rolls.

## Intended player experience

Skill, selected-part armor and current combat state affect whether attacks hit. Body locations follow a declared probability table rather than implied visual aiming. Vanilla Critical Strike improves accuracy; an early mod may instead multiply damage or enable both. Inspecting chances never rolls the attack.

## Confirmed requirements

RULE-013-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve the moddable accuracy baseline/limits, weighted moddable body table, shared/default and per-component/mod part policies, live Critical Strike checks, safe toward-zero divisions, strict adrenaline thresholds, shared critical-result damage extension, draw order and conditional previews.

RULE-012 already owns route/material eligibility and active monster reflex gates. RULE-001/003 own percentile/source/retry semantics. RULE-005 explicitly separates displayed agility helpers from full hit formulas; RULE-004 owns supported hook validation/selection/recovery.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateSuccessfulHit` rejects null participants, then checks its override. Default adds armor, adrenaline, attacker ChanceToHitModifier, stat differences, skill modifiers and biography/monster/baseline adjustments to supplied chanceToHitMod, clamps 3–97 and calls Dice100.SuccessRoll.
- `CalculateStruckBodyPart` draws uniformly from a 20-entry table. `Game/Items/ItemEnums.cs#BodyParts` maps those IDs to Head/RightArm/LeftArm/Chest/Hands/Legs/Feet. `CalculateAttackDamage` chooses one part before attack branches, shared by monster components.
- `CalculateArmorToHit` adds selected ArmorValues and IncreasedArmorValueModifier/DecreasedArmorValueModifier. Its inspected index condition uses <= length without a negative-index check; intended validation must not reproduce invalid indexing.
- `CalculateAdrenalineRushToHit` uses strict current health<integer max health/8 and +5/+8 attacker bonuses minus corresponding defender bonuses.
- `CalculateStatsToHit` separately divides live Luck and Agility differences by 10. `CalculateSkillsToHit` subtracts target live Dodging/4 and rolls attacker live Critical Strike for a skill/10 accuracy bonus. Integer division truncates toward zero.
- `CalculateAdjustmentsToHit` subtracts player BiographyAvoidHitMod when player is target, adds 40 against enemy monsters, then subtracts 50. Source comments describe departures/uncertainties relative to classic behavior; DOS equivalence is not asserted.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full armor/effect/caller and runtime behavior remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Context and body-part selection

Resolve only an owner-authorized valid physical attack after RULE-012 route/material eligibility. Invalid/missing participants/parts are explicit failures, not random misses. A material-rejected attack does not select a body part or run critical/hit checks.

Vanilla body weights: Head 10%, Right Arm 15%, Left Arm 15%, Chest 20%, Hands 20%, Legs 15%, Feet 5%. Use stable supported part IDs and unbiased weighted selection with nonnegative validated weights and positive finite supported total. Mods may replace the table; added parts require complete equipment/consumer mappings rather than merely a new weight entry.

Default selects one part per attack operation, shared across its monster components. A supported mod policy may select per component. Shared selection occurs before active component reflex gates; per-component selection occurs only after that component's gate passes. Inactive slots never cause additional part draws. An eligible operation with no active components needs explicit NPC/content handling rather than an invented hit; concrete empty-operation policy remains integration scope.

Selection is probabilistic, not automatically the visual contact point or an aimed attack. Owner-authorized queries of table weights are not selections and consume no live draws.

### Accuracy baseline

Begin with supplied resolved attack-route modifier A0. Its weapon/skill/swing/proficiency/racial/backstab inputs belong to their owning reviews; do not add them again here. Add the following in explicit source order:

1. Selected-part armor value plus resolved increased/decreased armor modifiers.
2. Attacker adrenaline bonus minus defender adrenaline bonus.
3. Attacker's resolved ChanceToHitModifier/equivalent enchantment accuracy input.
4. Separate trunc((attacker live Luck−defender live Luck)/10) and trunc((attacker live Agility−defender live Agility)/10).
5. Subtract trunc(defender live Dodging/4), then add the eligible critical accuracy bonus.
6. Subtract player-target biography avoidance, add 40 for enemy-monster target and subtract baseline 50.

These signed armor inputs preserve the inspected baseline; do not assume more positive armor numbers universally mean better protection or add an unapproved armor damage reduction. ITEM/MAGIC own resolved armor/modifier construction and stacking. NPC target classification must be explicit and validated, not an unsafe cast.

Use current valid live stats/skills. Negative/above-100 live skills receive these declared calculations within supported domains without an extra global clamp. Preserve each toward-zero division separately; combining differences before dividing or using floor changes results. Do not also apply RULE-005's displayed agility modifier.

Vanilla final accuracy limits are 3–97. Limits and supported modifier parameters/components are moddable via validated definitions and explicit RULE-004 hooks; integer bounds satisfy 0<=minimum<=maximum<=100, including equal limits/guarantees. Apply resolved bounds once before RULE-001 final hit resolution. Concrete raw-versus-final hook semantics must be documented; no callback implicitly bypasses RULE-012 eligibility.

### Adrenaline

An applicable source qualifies when current health<floor(effective max health/8), strictly. Bonus is 5 normally or 8 when improved. Add attacker contribution and subtract defender contribution independently. Threshold divisor/bonus parameters are moddable; validate positive divisor and safe domains. Equality does not qualify. Small maxima can produce threshold zero; do not force activation by switching to a fractional comparison or minimum-one threshold.

### Critical Strike and damage extension

For every hit resolution reached, resolve one independent RULE-001 critical check using attacker live Critical Strike as vanilla computed percentage. RULE-001 applies its general 0–100 limits, including one logical draw for guarantees. On critical success, vanilla adds trunc(live Critical Strike/10) to accuracy; no automatic hit or damage multiplier is implied. Each active monster component passing its preliminary gate reaches its own critical check and final hit check.

Explicitly support critical mods that replace the accuracy benefit with damage multiplication, or enable both benefits. Preserve one retained critical result in the component/attack context and pass it to RULE-014; never reroll critical status for damage. A failed final hit receives no critical damage. Vanilla remains accuracy-only.

Multiplier values, damage stage, rounding, interaction with other bonuses/minimums and mutation boundaries require an explicit RULE-014 contract before the damage mod is implementable. This is a required extension capability, not a deferred refusal to support damage criticals and not approval of a particular multiplier. Configuration must distinguish accuracy-only, replacement and both behavior; do not silently stack a damage mod with the baseline accuracy benefit.

### Draw and state order

Default ordinary route: select body part, resolve critical check, calculate final branch accuracy and resolve final hit. Monster default: shared part, then each active component's reflex gate; passed gates resolve critical then hit. Modded per-component policy: reflex gate, body part, critical, hit. Hit success alone proceeds to RULE-014 damage.

All draws use explicit owned combat randomness under RULE-003. Retain part/critical/hit results for technical retries without repeated draws or effects. Resolve live inputs coherently per reached hit evaluation; any required rereads after earlier component effects follow COMBAT's declared phases. Body-part reuse does not require freezing all subsequent live state for the whole attack. COMBAT owns invalidation/death/interruption and exactly-once application.

### Preview and diagnostics

Because critical status changes accuracy, a pre-attack query must show conditional critical-absent/present branches or a clearly labelled estimate. It cannot call the random critical resolver. Once resolved, diagnostics may display selected part, critical result, signed modifier breakdown, raw/bounded chance and final result.

Exact player UI visibility/layout is not prescribed beyond truthful conditional/estimate semantics. Inspection cannot advance draws, award practice or apply damage. A displayed hit chance does not promise positive damage or override material eligibility.

## Relevant formulas and parameters

Raw chance = supplied A0 + armor + adrenaline difference + attacker accuracy modifier + trunc(Luck difference/10) + trunc(Agility difference/10) − trunc(target Dodging/4) + applicable critical accuracy − player-target biography avoidance + monster-target 40 −50.

Final chance=clamp(raw,resolved minimum,resolved maximum), vanilla 3–97; final RULE-001 hit succeeds on R<=chance. Critical bonus defaults to trunc(attacker live Critical Strike/10) on its separate success. Adrenaline threshold defaults to floor(max health/8).

Examples: attribute difference −9 contributes 0, −10 contributes −1; do not floor −9/10 to −1. Critical Strike 50 has a 50% preliminary chance to add 5 accuracy, not a 50% automatic-hit chance. At max health 80, adrenaline threshold is 10; current 9 qualifies and 10 does not.

## Required data

Valid attack/component identities, participants and route context; shared/per-component part policy and table; resolved part armor/effects; live stats/skills/health; adrenaline/critical policies; supplied route and signed accuracy inputs; target classification/biography context; configured limits/provider provenance; owned source and retained part/critical/hit results. Damage-critical integration requires captured critical policy/context sufficient for RULE-014 without reroll.

## Inputs, outputs and events

Inputs: eligible attack context, validated weights/modifiers/policies and authorized resolutions or nonrandom previews. Outputs: selected part, retained critical status/policy, raw/final chance and hit result, conditional explanation or explicit error. This calculation does not remove health, wear equipment, poison targets or award practice. COMBAT owns committed events; APIs/signals remain unselected.

## Cross-system interactions

Confirmed projectile refinement: COMBAT-009-D04 captures arrow offensive stats/modifiers at release while reading current defender defenses at impact; target-dependent bonuses use actual contacted target and captured source data. This is an explicit exception to ordinary live offensive-input evaluation, not pre-rolled impact success. See [COMBAT-009](../COMBAT/COMBAT-009.md) for separate approval status and adapter dependencies.

RULE-012 supplies route/material/component gating; RULE-014 consumes successful hit/critical context for damage; RULE-016/COMBAT own effects. CHAR-011 supplies live state and CHAR-018 reconciled health maxima; ITEM/MAGIC supply armor/accuracy/adrenaline source context. NPC supplies valid classifications. RULE-001/003 govern draws/retained results; RULE-004/DATA-003 validate hooks/configuration. CORE/SAVE preserve readiness/operation state; UI/DEV query without mutation.

## Edge cases and failure conditions

- Unknown/out-of-range part IDs, missing armor mappings or invalid weights fail explicitly; do not emulate source index-bound bugs or silently use zero armor.
- Zero-weight parts are valid but never selected; all-zero/negative/unsupported tables fail validation. Table changes cannot rewrite an already retained part.
- Separate toward-zero divisions and negative live skill handling must not overflow or silently clamp inputs into vanilla ranges.
- Critical success with final miss does not multiply damage. Damage mods cannot secretly resolve another critical check or always retain accuracy when configured to replace it.
- Gate failures/inactive components skip downstream draws per RULE-012; ordinary misses continue components unless COMBAT termination applies.
- Failed overrides/partial application require explicit recovery without automatic fallback or whole-attack reroll.

## Configuration and balancing options

Support body weights/policy, accuracy component parameters/limits, adrenaline threshold/bonuses, critical chance/accuracy and explicit critical-damage extension contracts. Concrete parameter domains/hooks require owner-approved schemas. No universal armor damage reduction, aimed-location system, critical multiplier value or visual-contact override is introduced here. Locked selection and retained outcomes remain binding.

## Save/load considerations

Restore authoritative equipment/effects/actor facts and derive future chances. Preserve owner-required in-flight part/critical/hit results without replay; a save containing retained critical status cannot reroll it for damage. General mid-attack save support and application receipts remain COMBAT/SAVE decisions. Future unresolved rolls use fresh streams under RULE-003, without changing locked providers or previously applied consequences. Missing required mappings/policies require explicit compatibility recovery.

## Technical constraints

Target: Godot 4.7.2. Separate weighted selection, conditional nonrandom accuracy calculation, critical resolution, final hit and damage application. Use safe arithmetic/stable IDs and explicit owned draws. Publish critical result/policy as a shared contract rather than hide it inside an accuracy-only helper. Concrete types/interfaces/serialization remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Vanilla table probabilities and shared/default body-part policy match the stated weights; validated per-component policy follows gate-before-selection ordering.
2. Signed baseline modifiers, separate toward-zero divisions, target classification and adrenaline strict boundary match fixtures without double-added agility.
3. Modded integer limits within 0–100 and supported parameters/hooks validate; malformed tables/parts/domains fail explicitly.
4. Every reached hit resolution uses one retained critical check then one final hit check. Failed monster gates/inactive components consume no downstream draws.
5. Critical damage mods can replace accuracy or enable both using the same result; missed attacks get no damage benefit and RULE-014 defines stage/multiplier/rounding before implementation.
6. Nonrandom previews show conditional branches/labelled estimates; diagnostics reuse actual results without drawing or applying consequences.
7. Technical retry/restore preserves retained state without duplicate effects; future unresolved checks respect RULE-003.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-001/003/004/005/012 and CHAR-011/018. Feature limits coexist with general percentile semantics; floor-based displayed helpers are not double-added. Shared/per-component selection order respects inactive-slot skipping and gate-before-hit. Critical damage capability is explicitly required, while its numerical damage contract remains RULE-014 scope. COMBAT lifecycle/effect boundaries are not approved implicitly by source calls.

## Outstanding questions and approval

No blocking policy question remains for hit/body-part behavior. Before implementation: define full supplied-modifier/armor adapters, parameter/hook domains, weighted sampler and part identities, phased live rereads, critical policy/result interface, RULE-014 multiplier/stage/rounding contract, UI estimates and operation persistence. These cannot waive mod support for damage criticals, one retained critical result, explicit draw order or shared preview/gameplay rules.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-013-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering, RULE-014 critical-damage and combat-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
