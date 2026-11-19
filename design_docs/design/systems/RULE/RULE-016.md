# RULE-016 — Physical-hit mutations

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Coordinate secondary physical-hit consequences through explicit phases, ownership, eligibility and exactly-once settlement rather than hiding mutations inside damage calculations.

## Intended player experience

Eligible hits can spend poison, activate creature effects, wear equipment and trigger reactive artifacts predictably. Mods can control effect frequency independently of ordinary attacks. Critical multipliers can change declared damage-based amounts without duplicating effect attempts. Inspection, loading and technical retries cannot create extra consequences.

## Confirmed requirements

RULE-016-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve mutation-free numeric queries, positive-resolved-damage triggers, coherent poison consumption, moddable shield/armor wear routing and wear arithmetic, creature-effect definitions/frequency controls, safe artifact contracts and explicit phase order.

RULE-012/013/014 supply route, selected body part, hit/critical and final component damage. RULE-003 supplies retained-result retries/owned randomness; RULE-004/DATA-003 supply explicit hook/configuration validation and recovery. CHAR-018 owns authoritative pool mutations and CHAR-023 death/prevention.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateAttackDamage` calls monster-hit effects on positive natural damage, attempts weapon poison and clears the coating on positive weapon damage, calls DamageEquipment and dispatches Ring of Namira before returning the numeric damage to its caller.
- `DamageEquipment` wears a damaging weapon and a covering shield instead of armor, otherwise the selected-part armor. `ApplyConditionDamageThroughPhysicalHit` uses integer (10×damage+50)/100 and a 20% one-point fallback when zero. Player enchanted-item condition changes have distinct ITEM handling.
- `OnMonsterHit` contains creature-specific disease/paralysis/infection/fatigue behavior. Its raw damage argument precedes some later numeric adjustments. `InflictPoison` and `InflictDisease` contain additional resistance/target/level rules. Observed details do not automatically approve their complete MAGIC/NPC semantics.
- `FatigueDamage` uses twice source damage scaled by 64 internal units for its nymph/lamia path; exact creature parameters remain owner review.
- `Game/MagicAndEffects/Effects/Special/RingOfNamiraEffect.cs#EnchantmentPayloadCallback` scales reflection by enemy team and returns durability loss. The attack dispatcher checks rings but passes a null local source item and assumes AIAttacker; the effect casts its target to EnemyEntity. These assumptions require explicit validation rather than reproduction.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete outer attack/effect/durability callback behavior and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Explicit phases and trigger basis

COMBAT coordinates an authorized operation in baseline order: resolve numeric damage; settle applicable poison/monster payloads; apply equipment wear; apply primary health damage; dispatch eligible reactive payloads. ITEM/MAGIC/CHAR apply their own authoritative mutations. Numeric queries/previews do not execute these phases.

Default weapon poison, monster on-hit effects and wear require positive final resolved physical damage before current-health saturation. Overkill therefore uses resolved damage rather than the smaller actual health loss. Misses, failed gates, ineffective materials and zero-damage hits do not qualify by default. Triggers are moddable through explicit supported contracts; the probability/minimum helpers cannot bypass eligibility.

Use the final RULE-014 component amount, including applicable ordinary bonuses/backstab/critical/minimum, as the baseline source for damage-scaled payloads and wear. This intentionally avoids DFU's earlier raw monster-damage basis. Scaling amounts does not multiply callback counts.

At each phase, validate live target/source/application state. Earlier effects may change health, equipment, immunity or validity; do not assume a fully precomputed list remains applicable. COMBAT must define termination/continuation when a payload kills or invalidates a participant before primary damage. This phase order does not authorize blindly damaging dead/invalid targets or imply rollback occurred after failure.

For multiple components, COMBAT must explicitly integrate this order with component progress/aggregation and death checks. Retain per-component damage/effect identities and define any operation-level aggregation before use; do not accidentally apply aggregate wear/reflection once per component or both aggregate and per-component. Exact batching remains a required owner contract rather than an implicit source-call convention.

### Weapon poison

For an eligible positive weapon hit with coating, process one poison attempt. Consume that coating once when the attempt settles, including valid immunity/resistance rejection. Missing target/effect service, invalid data or technical failure is not successful rejection and cannot silently spend it.

ITEM/MAGIC must settle attempt/result/coating consumption coherently with retained identity, so retry cannot reapply poison or clear a new/different coating. Concrete transaction/recovery mechanisms are unselected. Consumption/trigger policies are moddable; poison types, resistance, bypass rules and durations remain MAGIC/ITEM contracts.

### Equipment wear

Default positive weapon hits wear the weapon and one eligible defensive item. A shield is selected only if its declared coverage includes the chosen body part; it takes defensive wear instead of that part's armor. Otherwise select mapped armor if present. A legitimate uncovered part has no defensive item to wear; missing required mappings are errors rather than fabricated armor. Unarmed/natural attacks cause no baseline equipment wear; routing is moddable.

For each affected item independently, compute a=trunc((10×D+50)/100) from valid nonnegative resolved source damage D. If a=0, resolve one RULE-001 20% check to set a=1; otherwise no fallback draw. Apply condition loss once through ITEM. Coefficients/fallback chance are moddable and safely validated. Critical/backstab may increase D/a but cannot repeat wear application.

Breakage, enchanted-item disappearance, repair permissions and equipment-state changes remain ITEM contracts. Do not infer them merely from source LowerCondition overloads. Retain fallback outcomes and selected item identity through technical retries, rather than reselecting a newly equipped item.

### Creature payloads and frequency

Use explicit moddable creature-effect definitions with target eligibility, trigger, activation policy, effect identity and damage-basis declaration. Attempt each applicable effect at most once per qualifying positive component unless a future explicit owner contract changes the unit. Critical/backstab does not duplicate infection/paralysis/disease rolls.

Support per-creature/effect activation probability, cooldown and/or every-Nth eligible-hit policies. Definitions must explicitly state combination order/meaning, eligible counting unit, counter/cooldown ownership, start/reset rules, chance draw timing, whether blocked/resisted attempts spend an opportunity and what starts a cooldown. A failed activation gate differs from a resisted payload. No universal values or silent combination defaults are approved here; required policies must be complete before exposure.

Default frequency counting unit is an eligible positive-damage component. NPC may separately select a special attack before contact; that selector is not automatically provided by the on-hit frequency controls. Neither constant physical attacks nor possessing an effect definition requires a special payload attempt on every hit.

MAGIC/NPC retain disease lists, infection probabilities, paralysis lifecycle, target/level immunities and resistance. Fractional-percent effects need an explicitly supported probability representation; do not round them silently into RULE-001 integer chances. Effect activation/payload random draws use declared owned sources/results under RULE-003.

### Reactive artifacts

Ring of Namira and similar artifacts use explicit moddable trigger, valid attacker/target classes, source-item identity, scaling and condition/charge cost contracts. This ring defaults to positive resolved incoming physical damage rather than every zero-damage attack result. Pass the actual valid attacker and equipped source item; null source/unsafe enemy casts are not target behavior.

Exact team factors, multiple-ring selection/stacking and cost settlement remain MAGIC/ITEM reviews. Unsupported attackers use explicit eligibility outcomes rather than invented team classification. Reflection runs after primary health phase only if its declared current-state policy remains eligible; death/prevention interactions need COMBAT/MAGIC contracts.

Reactive damage must not recursively trigger itself without an explicitly bounded rule. Carry sufficient origin/chain context to enforce that rule. Do not implement an unbounded reflection loop or duplicate primary equipment/poison phases simply because reactive damage exists.

### Overrides, queries and failure

Trigger/routing/phase changes are explicitly supported policies/hooks with declared ownership and side effects, not incidental callback order. RULE-004 governs preflight identity/signatures/provider selection, run-long locks and runtime failure without automatic fallback. A phase error enters owner/CORE recovery; never retry the whole operation after partial mutations without retained settlement knowledge.

Display/diagnostic queries can explain eligible consequences and source damage without applying them, consuming draws/practice/coatings or lowering condition. Actual committed phase results may be inspected without invoking the callback again.

## Relevant formulas and parameters

- Default eligibility for poison/monster/wear: authorized hit with resolved D>0 before current-health saturation.
- Wear a=trunc((10×D+50)/100); if a=0, independent 20% chance of one per affected item.
- Baseline defensive wear: covering shield, otherwise selected-part armor; never both for the same wear application.
- Frequency controls: declared chance/cooldown/every-Nth positive-component policy, with explicit combination semantics.

At D=4, baseline wear rounds to zero and uses its fallback check; D=5 yields one directly. Weapon/shield fallback checks are independent. Overkill damage 20 against remaining health 3 uses D=20 for these baseline calculations, without authorizing repeated effects or assuming actual loss 20.

## Required data

Stable attack/component/phase/attempt identity; retained hit/part/resolved damage and source policy; valid actor/weapon/coating/defensive-item references; effect definitions and activation state; owned source/results; artifact source/cost/chain context; and settlement/application receipts. Concrete schemas and atomicity boundaries remain owner/SAVE dependencies.

## Inputs, outputs and events

Inputs: authorized resolved hit and current validated source/target/configuration state. Outputs: committed/rejected/resisted/activation-skipped phase results, coating/condition/status/pool changes or explicit technical failure. Distinguish legitimate no-effect from invalid state. COMBAT/ITEM/MAGIC/CHAR own events after coherent settlement; exact APIs/signals are unselected.

## Cross-system interactions

Confirmed extension: COMBAT-011-D04–D06 insert weapon strike effects after poison/monster payloads and wear, before primary physical intake, preserving original RULE-014 resolved damage for existing triggers/scaling. D11/D12 require a living eligible defender after primary prevention for default reactions, and prohibit reflection-on-reflection by default; explicit mods may add death retaliation/bounded chains. See [COMBAT-011](../COMBAT/COMBAT-011.md) for separate approval status and artifact/cost integration dependencies.

Confirmed combat integration: COMBAT-010-D04–D09 settle each natural component's applicable phases before the next, reread current valid state, and terminate remaining components on actual death/invalidation/interruption. Early payload death skips living-target-required later phases; successful prevention revalidates/continues only when authoritative state permits. Retain completed outcomes and resolved-damage bases without aggregate reapplication. See [COMBAT-010](../COMBAT/COMBAT-010.md) for separate approval status and exact phase/recovery dependencies.

RULE-012/013/014 provide route/part/result/D; COMBAT coordinates phase/component termination. ITEM owns coating, equipment/coverage/condition; MAGIC owns payloads/resistance/reactive artifacts; NPC owns creature definitions/attack selection. CHAR-018/022/023 own health/fatigue/depletion/death. RULE-001/003 govern applicable checks/source/retries, RULE-004/DATA-003 validated locked policies. CORE/SAVE protect readiness/phase state; UI/DEV observe.

## Edge cases and failure conditions

- Zero-damage hits differ from misses but have no default poison/wear/monster trigger; modded trigger changes must be explicit.
- Valid immunity rejection consumes coating by default; technical failure cannot masquerade as resistance.
- Item breakage or actor death during early phases requires live checks before later phases; generic rollback is not assumed.
- Frequency counters/cooldowns cannot double-advance on duplicate delivery or reset through ordinary scene changes unless owner-approved lifecycle rules say so.
- Missing required effect services/data, invalid coverage or unsafe numeric domains fail explicitly rather than skipping required effects silently.
- Critical amount changes cannot multiply opportunities or recursively invoke reflection. Overlapping artifacts/effects require declared composition.

## Configuration and balancing options

Support declared effect triggers/phases, poison consumption, wear routing/coefficients/fallback chance, creature payload/frequency policies and reactive artifact contracts. Numeric/count/time/probability domains require explicit schemas and safe bounds; cadence controls must be finite and compatible with TIME. No universal disease/poison immunity rule, arbitrary effect interpreter or unbounded callback chain is introduced.

## Save/load considerations

Persist authoritative coatings/condition/status/pools and required activation counters/cooldown timestamps/phase receipts under owner contracts. Restore without replaying damage/payloads/wear or resetting frequency for free. Retained chance/result/cost settlement must distinguish completed/resisted/skipped/failed phases; supported partial-attack restoration requires explicit COMBAT/SAVE integration. Fresh future randomness under RULE-003 does not erase committed facts or retained phase results. Missing required state uses migration/recovery rather than silent consumption or omitted obligations.

## Technical constraints

Target: Godot 4.7.2. Separate pure calculations from owner mutations, use stable identities/current-state checks and explicit units/probabilities. Preserve exactly-once results/application progress without relying on UI callbacks. Concrete schemas, staging, event delivery and recovery mechanisms remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Baseline phases execute in declared order outside numeric previews; failed/zero hits trigger no default poison/wear/monster effects.
2. Positive resolved rather than saturated health loss controls baseline source amount; critical/backstab changes amount without repeated attempts.
3. Coating consumption settles once with valid attempt outcomes including resistance, not on invalid/technical failure.
4. Weapon plus covering-shield-or-armor wear uses safe declared arithmetic/independent fallback results; unarmed/natural wear requires explicit override.
5. Creature effects support validated chance/cooldown/every-Nth controls with complete semantics, rather than mandatory every-hit payloads.
6. Reactive artifacts validate actual attacker/source item/cost and bounded chain behavior, without unsafe casts or self-recursive reflection.
7. Phase errors/invalidation invoke explicit recovery; retries/restore cannot duplicate effects, spend new coatings, reset frequency or repeat condition loss.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-001/003/004/012/013/014 and CHAR-018/023. Damage multipliers affect declared numeric amounts, not callback counts. Pure previews and retained technical retries remain binding. Positive resolved damage need not equal actual health loss. Phase ordering, reaction eligibility and per-component aggregation require explicit COMBAT integration; this review does not approve complete MAGIC disease/artifact policies or ITEM breakage by implication.

## Outstanding questions and approval

No blocking shared-effect policy question remains. Before implementation: define exact component/operation phase aggregation, early-death continuation, poison transaction recovery, creature frequency schemas/defaults/reset/attempt semantics, fractional probabilities, artifact stacking/factors/costs and effect/condition/save contracts. These cannot waive configurable frequency, coherent coating settlement, declared trigger basis, phase order or exactly-once effects.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-016-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering, frequency-policy and COMBAT/ITEM/MAGIC dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
