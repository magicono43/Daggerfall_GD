# MAGIC-007 — Absorption, reflection and resistance

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Intercept incoming effects through absorption, reflection and Spell Resistance with independent recipient outcomes, bounded return chains and explicit magicka accounting.

## Intended player experience

Mixed spells can be partly absorbed, reflected or resisted without replaying unrelated effects. Absorption turns eligible magic into magicka only when its capacity/budget rules allow. Reflection returns the intercepted effect without another explosion. Defenses, scaling and refund policies are moddable while preserving once-only outcomes and finite reflection.

## Confirmed requirements

MAGIC-007-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm defense order, per-effect scope, finite independent reflection chains, absorption eligibility/capacity/value, shared original-caster refund cap, direct return, independent permissions, defense scaling, absorption-source order and immediate refund. The complete specification is approved under MAGIC-007-A01.

MAGIC-006 authored-order admission, MAGIC-005 captured offense/current defenses, RULE-001 retained percentile checks, RULE-017 effect saves, RULE-018 explicit normal-cost valuation and CHAR-018 authoritative resource operations remain binding.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime mixed-target/mod/save behavior unverified. Source unchanged. Symbols below are in reference `Assets/Scripts/Game/MagicAndEffects/`.

- `EntityEffectManager.cs#AssignBundle` attempts absorption, reflection and Spell Resistance within each effect loop for caster-backed spell bundles. Saving-throw bypass gates the latter two, not absorption. Refund is accumulated and applied after the loop.
- `TryAbsorption` accepts Destruction effects, prices each using recipient skills, requires full free magicka capacity, then tries effect-based, career and persistent absorption. `GetEffectCastingCost` applies target multiplier and minimum five. `TryEffectBasedAbsorption` scales with defender level. Career light/dark checks use player interior context and world day/night.
- `TryReflection` checks a shared bundle reflection counter, excludes return onto the same caster, rolls defensive chance and directly assigns the entire original bundle back to its caster. Because called per effect, it mismatches effect-level interception with bundle-wide return and shared multi-recipient state.
- `TryResistance` rolls the active SpellResistance effect and exempts caster-only mode. This is separate from FormulaHelper.SavingThrow/RULE-017.
- `Effects/Restoration/SpellAbsorption.cs` and `Effects/Thaumaturgy/SpellReflection.cs`, `SpellResistance.cs` use duration/custom-chance incumbent effects; same-kind recasts add duration in these classes. Exact target merging is MAGIC-009 scope, not approved merely by inspection.

## Detailed rules and behaviors

### Scope, ordering and outcomes

Resolve defenses per effect entry/per recipient within MAGIC-006's authored sequence. Baseline order is absorption → reflection → Spell Resistance; validated ordering overrides are supported. Stop processing that entry at that recipient on successful interception. A failed defense proceeds; if none succeeds, continue on-cast chance and applicable RULE-017 save before effect startup.

Do not redirect/reapply the entire spell when one entry reflects. Distinct authored entries and original area recipients have distinct delivery-chain identities. Ordinary defense outcomes are independent; technical missing-context/provider failures require explicit recovery rather than silent immunity or whole-area replay.

Retain applicable checks/results and committed interception/refund/return state. Retry, logs and restoration cannot reroll a completed defense or emit another return/refund. Direct rule-based capability/eligibility tests do not invent percentile draws; actual chance checks use RULE-001 including its boundary semantics.

### Eligibility and separate permissions

Baseline absorption covers Destruction-school spell effects. Eligibility is moddable by effect, school and source, including explicit self-cast inclusion/exclusion. Destruction is a baseline school filter, not a universal harmful/beneficial classification. Nonspell origins, missing-caster behavior and item/innate exceptions require explicit source contracts rather than a generic defense bypass or guessed caster context.

Absorption, reflection and Spell Resistance each have separate eligibility/bypass permission, independent of chance bypass, effect-save bypass and hard-immunity exceptions. Free casting alone grants none. Baseline reflection does not return to the same sender/recipient. Caster-only target mode bypasses Spell Resistance; own-caster ranged explosions are not caster-only. Explicit validated exceptions are supported without weakening mandatory content validity or finite reflection limits.

MAGIC-006 applicability/hard-immunity checks precede these stages; this draft does not refund an effect already excluded by that earlier gate. Exact defense eligibility/classification inventories must be validated with effect/source owners.

### Absorption valuation, capacity and sources

Compute individual effect absorption value V through explicit normal-cost valuation using recipient current relevant skills, incoming target multiplier and configured effect minimum (DFU baseline five). RULE-018 cost-purpose rules apply: do not inherit a discounted/forced-minimum cast-payment mode accidentally. Actual caster debit is a separate fact. Support validated alternative valuation; exact cost mappings/schema require fixtures.

Baseline requires unused capacity MaxMagicka−CurrentMagicka≥V for the entire value before attempting absorption. Insufficient capacity fails this defense and proceeds to the next defense. Do not cancel for a partial/zero refill by default. Validated alternative profiles may allow partial refill or interception at full magicka, with explicit numeric and refund rules.

Try absorption sources in baseline order: applicable effect-based absorption, career condition, active persistent absorption capability. Stop on first success rather than awarding multiple refunds. Effect-based chance uses the defending recipient's current level, baseline B+I×floor(Ldef/D), D>0, with RULE-001 clamping/draw semantics. This is an explicit live-defense exception to ordinary captured effect power; source schema must state it.

Career Always/light/dark conditions and active capabilities use authoritative current defender context. Darkness baseline corresponds to interiors or outside at night; light to outside during day, consistent with source intent. Do not borrow player location for another actor. Exact TIME phase/environment mappings and transformation/career eligibility require owner adapters; no renderer brightness threshold is invented.

Composition/source ordering and chance scaling are moddable. Same-family effect merge/chance retention/stacking is MAGIC-009 scope; do not automatically stack many independent incumbent rolls merely because multiple records exist.

On success cancel the entry and commit its authorized magicka recovery immediately through CHAR, before the next authored entry. Re-evaluate capacity and budgets for every later entry. No deferred accumulated refund may let several entries independently reserve the same free capacity. Keep recovery and retained outcome coherent across technical failure.

### Original-caster refund budget

For the original caster's own cast, including effects reflected back, total absorption magicka gained by that caster across all entries/return paths is at most actual magicka spent on that cast. Track one cast-wide budget independently of per-recipient reflection chains. Free cast debit zero means zero self-refund budget.

Baseline requires remaining budget≥full V in addition to capacity; otherwise absorption fails and later defenses may act. Successful self-refund decreases remaining budget once. Refunds to other recipients do not consume this original-caster budget; those recipients use their own capacity/valuation. No per-entry minimum may multiply the original caster's refundable payment.

The cap is independently moddable. Partial/zero-refill interception requires explicit profiles; no implicit exception arises from free abilities, reflected effects or a changed spell selection. Retain original cast payment/budget identity after source scene removal and during native restore. This rule does not select other MAGICKA recovery, cost or damage formulas.

### Reflection and bounded return

Default one reflection per effect delivery chain; support a validated finite limit. Each original area recipient starts an independent chain, so one reflection does not disable another's defense. Increment/retain count on committed reflection; at limit, reflection is unavailable and later defenses/admission proceed normally. No recursive unbounded volley is permitted.

Directly return only the intercepted effect to its immediately preceding sender without another projectile, area explosion, cost or casting practice/history update. Preserve original offensive snapshot/attribution and separately record reflector, previous sender, return recipient and chain history. Subsequent mod-permitted bounces return to the previous sender, not arbitrarily always to the original caster.

The destination may absorb, reflect within remaining limit, resist or admit under current defenses and applicability. The original caster-only mode/exemptions cannot be changed implicitly by constructing a return bundle; exact reflected eligibility and target-mode metadata require explicit adapters consistent with the above rules. A valid return is a delivery, not a new player selection/cast.

Missing/no-longer-valid return recipient dissipates the reflected effect without substituting another actor or reviving a dead source. A valid entity with a missing required effect manager/provider is a technical failure, not ordinary recipient absence. Direct return is not a newly traveling line-of-sight projectile; mods may declare physical return projectile profiles with explicit geometry/lifetime/persistence, without spawning a new area by accident.

Reflection chance uses power captured when the defensive effect was applied, not the incoming caster's level or current defender level by default. Explicit validated scaling policies may differ. Retain the actual check result and chosen defensive source context so retries cannot choose another reflection outcome.

### Spell Resistance and ordinary saves

Spell Resistance is a distinct chance-based interception stage that cancels the current effect on success; it is not RULE-017's retained-percentage save. Use defensive power captured at that defense's application by default, with validated alternative scaling. Failed Spell Resistance continues to MAGIC-006 chance/save, without starting the effect early.

Caster-only mode bypasses this stage by baseline rule; other modes may be resisted even when their recipient is their original caster. Do not interpret saving-throw bypass as Spell Resistance bypass or multiply either check through diagnostics. Same-kind resistance/reflector stacking remains MAGIC-009.

## Relevant formulas and parameters

Baseline defense percentile chance Q=B+I×floor(L/D), P=clamp(Q,0,100), success U≤P for RULE-001 U in 1–100. L is current defending level for effect absorption and captured defense-power level for reflection/Spell Resistance. D must be positive; unsupported/missing context fails explicitly.

Baseline absorption admission needs capacity≥V and, for original caster, remaining cast refund budget≥V. Recovery V and budget decrement happen once on success. Initial self budget=actual cast debit. Default reflection limit=1; supported overrides remain finite. No default partial refund percentage, new chance stacking formula or universal alternate cost model is selected.

## Required data

Cast/effect/original-recipient/chain/current-recipient identities; original caster/source snapshot and actual debit; shared self-budget/spent amount; current magicka/capacity; resolved defense effects/career/capabilities and environment; separate permissions; valuation purpose/value/provenance; retained chance/source result; original attribution plus reflector/previous sender/count/limit; refund/return commitment and partial-failure obligations. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: valid MAGIC-006 entry, current defense/target/environment/resource context, captured offensive/defensive context, resolved policies and return results. Outputs: failed/unavailable stage, absorbed entry plus once-only recovery, reflected entry plus bounded return, Spell Resistance cancellation, or continuation to ordinary admission. Optional feedback reports committed outcomes; it cannot reroll or refund. Concrete APIs/signals are not selected.

## Cross-system interactions

MAGIC-006 supplies authored per-entry admission; MAGIC-004 supplies original cast payment/practice/history; MAGIC-005/COMBAT-014 supply captured offense, current recipients and delivery identity. RULE-001/003 retain checks, RULE-017 follows as distinct effect saving, RULE-018 supplies explicit normal valuation, CHAR-018 owns recovery. MAGIC-008–010 own defensive effect lifetime/merge/restore. NPC/TIME provide actual defender environment; DATA/MOD validate locked policy order/permissions. SAVE/CORE-013 preserve chains/budgets and required content; LAW/QUEST attribution consumes explicit original/reflector context under its own future policies.

## Edge cases and failure conditions

- Multi-effect/area spell: independent interception chains, no whole-bundle return or duplicate unrelated effect.
- Refund fills capacity: next effect checks reduced free room immediately rather than deferred batch capacity.
- Free/self-discounted/underfunded original cast: use actual debit budget, normal valuation; insufficient budget fails baseline absorption.
- Many reflected returns reach original caster: share one self budget while maintaining separate finite chains.
- Two reflecting actors at configured limit: skip further reflection, allow later defenses/admission; no infinite recursion.
- Source disappears after release: keep captured power/attribution; invalid return destination dissipates, but missing required provider is explicit technical recovery.
- Career light/dark or defender level changes: use actual current absorption context; reflection/resistance retain applied-defense power unless explicit profile differs.
- Bypass chance/save/free cast: no unintended interception bypass. Mod changes must name the defense being changed.
- Partial refund/return mutation failure: recover same retained interception, no reroll/double recovery/new projectile.

## Configuration and balancing options

Validated mods may change defense/source ordering/composition, absorption eligibility/self inclusion, valuation/capacity behavior, self-refund cap, finite reflection limit/return profiles, separate permissions and live/captured chance scaling. Defaults remain the confirmed policies above. Exact schemas, selector precedence, safe bounds and permitted alternate models require owner contracts; no unlimited recursion or blanket bypass API is approved. Stronger same-family stacking is not inferred from broad moddability.

## Save/load considerations

Persist committed defense results/refunds/return progress, shared original-caster payment budget and each independent chain count/context when needed for active delivery. Restore without reroll, another refund, another reflected delivery or another cast/practice/history event. Fresh RNG applies only to genuinely unresolved new checks under RULE-001.

Use coherent snapshots or supported partial-operation recovery. Missing required identity/provider/budget state follows CORE-013 failure/migration rather than zeroed counters or reset budgets. Physical return profiles and outstanding delivery objects follow COMBAT-014/MAGIC save/location contracts; cleanup cannot discard committed unresolved obligations. Exact mid-chain save admission and migration schema remain SAVE/MAGIC dependencies. Classic/DFU import is outside scope.

## Technical constraints

Target Godot v4.7.2. Maintain separate cast-wide budget and recipient-local chain state rather than shared mutable last-spell/bundle counters. Bounded direct-return work, deterministic retained stage order and explicit failure results must preserve source attribution and once-only owner changes. Exact scheduling/work limits, mod API, profile adapters and save representation remain technical dependencies. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Baseline stages run absorption/reflection/Spell Resistance before on-cast chance/save and stop intercepted entry only; valid mod order works explicitly.
2. Each entry/recipient has independent retained results; reflecting one cannot replay a bundle or disable another area's reflection.
3. Absorption default eligibility/value/capacity and source order are honored, with actual defender context and immediate refill before later entries.
4. Original-caster refunds across entries/returns never exceed shared actual debit by default; free cast refunds zero, insufficient full budget/capacity proceeds to next defense.
5. Reflection returns one effect to previous sender without explosion/new cast costs/practice, respects finite chain limit and preserves separate original/reflector attribution.
6. Invalid return recipient dissipates without substitution; technical provider/context failure does not masquerade as absence.
7. Defense chance scaling and independent permissions are correct; failed checks continue and retained checks never reroll on retry/restore.
8. Spell Resistance is distinct from RULE-017, caster-only exemption remains mode-based, and no-cost/save bypass has no accidental defense permission.
9. Mod partial-refill, cap, ordering and physical-return profiles declare complete validated semantics without implicit stacking/unbounded recursion.
10. Native save restores budgets/chains/completed refunds/deliveries without repeated payment/refund/checks or history/practice changes.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-004–006, RULE-001/017/018, CHAR-018 and COMBAT-014 delivery/persistence contracts plus D01–D12. No direct contradiction identified. Normal valuation remains separate from payment exemptions; self-budget uses actual debit. Immediate defense refund is an accepted interception outcome, not rejected-effect startup mutation under MAGIC-006. Per-entry returns preserve independent outcomes and captured offense/current defenses. Explicit live-level absorption is the declared specialized defense exception allowed by MAGIC-005. Separate bypass permissions preserve MAGIC-006. LAW attribution details, same-family stacking and native mid-operation representation remain owner dependencies rather than assumed resolved.

## Outstanding questions

No further blocking defense player-policy choice is identified. Before implementation is complete: fixture-verify valuation/minimum mappings and defense chance/context inventories; define reflected metadata/applicability adapters, career environment mapping, source selector/override precedence and MAGIC-009 stacking; specify bounded chain scheduling, typed failure recovery, budget/chain persistence and physical-return profiles. These deferrals cannot authorize whole-bundle replay, implicit self-refund budget reset, hidden bypass or rerolled completed interception.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-007-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented valuation/context fixtures, reflected metadata, source-policy schemas, stacking, bounded scheduling and native persistence/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
