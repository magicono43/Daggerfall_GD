# COMBAT-010 — Attack eligibility and physical roll

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Coordinate physical attack eligibility, accuracy/damage and ordered component settlement without conflating misses, ineffective weapons, harmless hits or technical failures. Let current combat state and prevention matter between components while retaining committed results and predictable feedback.

## Confirmed requirements

COMBAT-010-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. The complete specification is approved under COMBAT-010-A01. RULE-012–016 already define route/material, hit/body-part, damage and effect/wear baseline formulas; this feature orchestrates them rather than replacing approved calculations. COMBAT-009's captured projectile offense remains binding.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths below are relative to reference `Assets/Scripts/`.

- `Game/Formulas/FormulaHelper.cs#CalculateAttackDamage` returns zero for null participants or ineffective material and uses shared weapon/unarmed/natural routing. Its top-level override returns directly, replacing built-in behavior. Zero alone does not preserve rejection/miss/zero-hit reason.
- Natural monster components accumulate numeric damage in a local total while OnMonsterHit can mutate state during individual components. Weapon poison and equipment callbacks also occur within broader calculation. Outer `WeaponManager.WeaponDamage` and `EnemyAttack.ApplyDamageToPlayer/ApplyDamageToNonPlayer` perform additional effects/health handling.
- CalculateSuccessfulHit, CalculateStruckBodyPart and damage helpers provide detailed calculations analyzed in approved RULE-012–016. Target deliberately adds explicit outcomes and ordered owner phases rather than copying a scalar-return calculation with hidden mutations.

## Detailed rules and behaviors

### Authorization, routes and explicit outcomes

Resolve only an authorized physical contact/component with valid session, participants, source model and required definitions. Legitimate unarmed source differs from missing required weapon data. COMBAT-001/005/009 establish attack/contact eligibility; previews and stale callbacks cannot authorize effects.

Distinguish at least invalid context, ineffective material, failed natural-component gate, accuracy miss, successful hit with zero resolved physical damage and positive resolved physical damage. Also retain termination/technical failure and owner application/prevention outcomes, rather than collapsing all to zero. A result can include completed components plus interrupted remainder; its summary must not conceal partial commitment.

Use RULE-012 route selection before material gating. Eligible enemy natural preference uses its approved strict first-natural-average comparison; ties retain weapon. A selected ineffective weapon fails distinctly with no automatic unarmed fallback. Player attack source remains the selected COMBAT-002 source, not enemy preference logic. Unarmed material bypass and explicit mod overrides remain RULE-012-owned.

For material rejection, do not run downstream part/critical/hit/damage draws. Distinguish ordinary eligibility rejection from malformed definitions/missing references, which require explicit error/recovery. A supported hook cannot implicitly bypass other owner's validation or trigger side effects twice.

### Per-target and per-component resolution

Each cleaved enemy receives independent material, body-part, critical/hit and damage resolution, with COMBAT-005's initial ordering/revalidation and COMBAT-004 practice rules. No body part or critical result is accidentally shared across different targets. Accuracy miss/zero damage/material failure on one target does not automatically cancel later targets; actual interruption/weapon break follows COMBAT-001/004/005.

Within one target operation, default natural components share one RULE-013 selected part; modded per-component selection remains supported. Retain RULE-012 authored active component order, skipping inactive slots without draws and processing reflex gate→critical/hit→damage as approved. Ordinary gate failure/miss/zero damage proceeds to the next active component, subject to validity checks. No additional hit attempt or damage roll occurs for a component whose prior gate failed.

Fully settle each natural component's applicable phases before the next component begins. Use RULE-016 baseline sequence: numeric resolution; eligible poison/monster payloads; equipment wear; primary health damage; eligible reactive payloads. Domain owners apply their mutations. Do not calculate all components from stale state then apply aggregate health loss. Any displayed total is a summary only and cannot apply damage/effects again.

Before each subsequent melee/natural component, read current valid stats/defenses/effects after earlier settlement, retaining selected shared part and prior resolved outcomes. Revalidate phase applicability where earlier effects alter state. For arrows use COMBAT-009 release-captured offense and current defender state, not this ordinary live-offense path. Exact field/hook adapters and coherent read/mutation boundaries remain engineering contracts.

### Termination, death and prevention

Stop remaining components when target dies/becomes invalid or attacker is killed/paralyzed/otherwise interrupted. Retain completed effects/results and never retarget another actor or restart the sequence. Independent already-released projectiles continue under COMBAT-009. Mere accuracy failure/zero damage is not interruption.

If an early on-hit payload kills/invalidates the defender before primary physical health damage, keep completed effects and skip remaining phases requiring a living valid defender, stopping later components. Retain already resolved numeric damage even when actual primary physical health loss is zero. This is not permission to repeat payloads, finish wear on unrelated items or blindly damage a dead target.

If death prevention leaves defender alive and valid after the earlier phase, revalidate and continue against its authoritative resulting state. CHAR owns prevention/final death; an intermediate zero-health write is not already a completed kill. Prevention that also relocates/suspends/invalidates combat may stop through its resulting owner state. Do not infer full validity merely from positive health.

Weapon break during a cleaved target retains that target's committed outcome and stops remaining strikes as explicitly approved in COMBAT-004; cancellation of future attack work is distinct from undoing the component currently committing. Exact current-component phase boundary and owner interruption ordering must preserve that contract. Per-target effects/wear/other reactions remain their explicit owners, not a universal end-of-attack aggregate.

### Result accounting and downstream triggers

Retain per-component route/material/gate/part/critical/hit/numeric damage, application progress and termination. Separate resolved physical damage from actual health lost and prevention outcome. Overkill or prevention does not retroactively change RULE-016's positive resolved-damage basis for eligible poison/effects/wear. Actual health loss comes from CHAR authoritative intake, not simply min(resolved damage, an earlier health snapshot) when other effects/prevention intervene.

Practice, arrow recovery, poison, wear and enchantments use explicit owner predicates, not one generic hit-succeeded flag. COMBAT-004 melee practice and COMBAT-008 recovery may qualify on valid contact even when accuracy fails; RULE-016 default poison/wear requires positive resolved physical damage before health saturation. COMBAT-011 will finalize additional strike/enchantment composition. Contact alone does not imply every effect fires.

CHAR practice remains for valid qualifying living-character context; COMBAT-004 attack-fatigue exhaustion ordering remains its approved exception/handoff. Summaries/notifications cannot repeat mutation or invent practice for skipped components. Retain random outcomes through technical retries under RULE-003.

### Technical failure and communication

Malformed rule output, failed required hook or partial application error stops the affected operation for explicit recovery with completed phases/random results retained. Do not call another provider/built-in fallback after failure, reroll or replay the whole attack. Legitimate resisted payload/miss/zero damage is not technical failure. Exact operation recovery scopes, timeout and required obligations remain CORE/domain integration, not a promise of universal rollback.

Ineffective material gets a distinct nonmodal explanation, at most once per attack across cleaved targets/components. Feedback is moddable. No new generic miss/zero-damage popups or damage-number display is introduced. Technical errors need truthful recovery feedback; optional presentation failure cannot replay effects or turn into another hit.

## Relevant formulas and parameters

Retain RULE-012 route/material/reflex gates, RULE-013 body table/accuracy/critical/draw order, RULE-014 damage/backstab/minimum and RULE-016 trigger/scaling formulas without duplicating them here. Default final hit limits remain 3–97 under RULE-013, distinct from route/material authorization. Natural component gate failure consumes no downstream hit/damage draws; successful hit can legitimately resolve zero damage under RULE-014's default minimum zero.

Per-target/per-component resolved and applied amounts are separate records. A diagnostic total may sum completed component amounts with safe arithmetic but never drives a second health mutation or additional effects. No new damage formula, target cap, practice amount, component cooldown or prevention charge is selected.

## Required data

Attack/target/component/session identity; source model/route/weapon and configured policy provenance; valid material/rank inputs; ordered active components; retained part/reflex/critical/hit/damage results; coherent current or projectile-captured stats; phase completion/selected mutation identities; resolved damage/actual physical health loss; prevention/final validity/interruption; explicit failure/recovery and deduplicated material feedback status. Exact schemas and supported bounds remain owner dependencies.

## Inputs, outputs and events

Inputs: authorized contact/component, validated RULE context, live/current or captured projectile data, owner payload/wear/health/prevention results and interruption. Outputs: structured per-component resolution, committed phase/application outcomes, termination/retained remainder, actual intake results and optional feedback/diagnostic summaries. Concrete API/signal names remain unselected. Numeric queries/previews are effect-free and cannot consume gameplay randomness, mutate inventory/health or grant practice.

## Cross-system interactions

Confirmed extension: COMBAT-011-D04–D06 insert weapon strike enchantments after poison/monster payloads and wear, before primary physical health damage. Earlier/default triggers retain original RULE-014 damage; strike modifiers track a separate pending amount and declared order/basis. See [COMBAT-011](COMBAT-011.md) for separate approval status, source-breakage/projectile exceptions and effect/recovery dependencies.

RULE-012–016 supply formulas, phase triggers and validation; RULE-001/003/004 chance/source/retry/hook behavior. COMBAT-001 interruptions, COMBAT-002 source identity, COMBAT-004 commitment/fatigue/practice/cleave, COMBAT-005 acquisition/order, COMBAT-008/009 projectile payload/recovery/snapshot, COMBAT-011 on-hit integration and later intake/death features. ITEM equipment/poison/wear, MAGIC payload/prevention effects, CHAR health/practice/death, NPC models and LAW/QUEST attribution, CORE/SAVE coherent operations and AV/UI result feedback. No adjacent unreviewed combat feature is approved wholesale.

## Edge cases and failure conditions

Verify missing required weapon versus legitimate unarmed, material failure without hit draws, cleaved targets with different defenses, shared-part natural components, inactive slots and true repeated attacks versus callback redelivery. Retained critical results must not reroll for damage multipliers.

Verify payload-caused death before primary damage, prevention that restores/relocates, source paralysis/death from reaction, weapon break, and zero damage that still grants contact-based practice/recovery. Revalidate actual owner state, not temporary flags. A positive numeric damage result is not automatically actual loss or death.

Verify partial hook/effect failure with previous components completed; retries reuse outcomes and do not retarget new equipment/actors. Summed diagnostics cannot cause aggregate wear/reflection or health application on top of per-component settlement. Missing required phase contracts must be resolved explicitly before integration rather than hidden as ordinary failure-to-hit.

## Configuration and balancing options

Use approved moddable RULE route/material/component, accuracy/part/critical, damage and payload/wear policies. Distinct outcome semantics, per-target identity and no-duplicate guarantees remain explicit contracts. Material feedback is moddable. Added phases/aggregation or alternate continuation rules need declared supported policies; no implicit executable callback expansion, automatic fallback or new UI chance display is authorized.

## Save/load considerations

Preserve committed costs/results, retained random outcomes and required phase/application obligations through owner save contracts. COMBAT-001 cancels unfinished attacks while retaining completed facts; COMBAT-009 preserves already-released projectiles with their captured offense/pending-impact state. These rules cannot be implemented by replaying input or recomputing completed hit rolls.

Exact mid-component save admission must use coherent boundaries or sufficient phase completion records. Pending prevention/death, payload, wear, health, practice and attribution cannot be silently abandoned or repeated. A saved aggregate damage number alone is insufficient to distinguish completed versus pending mutations. Native schemas/migration and partial-operation recovery remain SAVE/domain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate rule evaluation, retained outcomes, ordered owner mutations and presentation. Explicitly identify each target/component/phase, capture coherent inputs at approved boundaries, and publish authoritative prevention/death results before continuation. Avoid hidden side effects in preview calculations or scalar zero as an error protocol. Concrete scheduler, atomicity/recovery representation, adapters and native fixtures remain engineering work. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Distinct invalid/material/gate/miss/zero-hit/positive-damage outcomes are observable without guessing from zero damage.
2. Approved route-before-material/no-fallback and RULE draw order are preserved; rejected material/inactive slots do not consume downstream draws.
3. Every cleaved target resolves independently; natural components share default body part only within that target operation.
4. Each natural component settles eligible numeric/payload/wear/health/reactive phases before next; totals never apply effects/health again.
5. Subsequent ordinary components reread current valid state; arrows retain captured offense/current-defense exception.
6. Target death/invalidity or attacker death/paralysis/interruption stops remaining unreleased components without retargeting/undo. Ordinary miss/zero damage does not stop a still-valid sequence.
7. Early payload death skips living-target-required later phases; successful prevention revalidates and continues only if resulting state permits.
8. Results retain resolved damage, actual physical loss, prevention/termination and completion separately. Owner-specific practice/recovery/effect triggers remain independent.
9. Required technical failure invokes explicit recovery without reroll/fallback or replay of completed work.
10. Material feedback is nonmodal and once per attack; no generic miss/zero-hit popups or new damage-number display appears.
11. Pause/save/load/duplicate callbacks preserve committed facts and phase obligations without duplicate health, effects, wear, practice or random draws.

## Contradiction review

Reviewed against approved RULE-012–016, COMBAT-001–009 and relevant CHAR-012/018/022/023 ownership plus source/catalog/architecture. No direct contradiction identified. Component-by-component settlement resolves RULE-016's formerly open batching/termination contract; it does not repeat aggregate effects. Early payload death skips inapplicable later work while retaining resolved-damage trigger basis. Prevention uses authoritative CHAR results. Contact-based practice/recovery remains independent of physical accuracy/damage. COMBAT-009 remains the explicit projectile offensive snapshot exception. Broader architectural proposals remain Proposed.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: complete source/model adapters, exact phase read/mutation/notification order and current-component breakage boundary, source/target validity contracts, structured result schemas/bounds, effect/enchantment integration, recovery scopes and save/prevention fixtures. These cannot collapse distinct outcomes, aggregate damage a second time, continue against invalid actors or bypass confirmed projectile snapshots. COMBAT-011 and later intake/death reviews remain separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-010-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented adapters, phase ordering, breakage boundaries, result schemas, effects integration, recovery and save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
