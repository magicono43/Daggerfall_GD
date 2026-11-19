# COMBAT-011 — On-hit side effects and strike enchantments

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Apply secondary attack effects with explicit triggers, ordering, source/cost ownership and retained outcomes. Make strike enchantments consistent for player/enemy attacks, preserve separate magical and physical damage, support cleave/projectile payloads and prevent duplicate effects or unlimited reflection loops.

## Confirmed requirements

COMBAT-011-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. D04 adds a strike-enchantment phase after existing poison/monster payload and wear but before primary physical health damage. D10 explicitly distinguishes captured arrow payloads from live melee-source breakage. The complete specification is approved under COMBAT-011-A01. RULE-016 and COMBAT-010 phase validation, resolved-damage triggers and death/prevention/recovery rules remain binding.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths below are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#WeaponDamage` breaks ordinary concealment on positive formula damage, handles feedback/recovery, then invokes enchanted weapon Strikes payloads before DecreaseHealth. It calls RaiseOnWeaponStrikeEvent and a racial OnWeaponHitEntity callback in this outer route. Player Strikes invocation does not locally require positive damage.
- `Game/EnemyAttack.cs#ApplyDamageToPlayer` requires positive damage for weapon Strikes; its nonplayer path has further caller-specific ordering. These source differences do not establish a desired player-only enchantment-on-miss advantage.
- `Game/MagicAndEffects/EntityEffectManager.cs#DoItemEnchantmentPayloads` iterates combined enchantments, adds StrikeWithItem return adjustments to damageOut and clamps the result nonnegative. StrikeWithItem can lower condition via a returned durability loss. Each source callback receives original damageIn, illustrating why target basis/order and costs must be explicit.
- `Game/Formulas/FormulaHelper.cs#CalculateAttackDamage` also applies poison/monster effects/wear. Approved RULE-016/COMBAT-010 separate these owner phases instead of duplicating source caller side effects.

## Detailed rules and behaviors

### Eligibility and retained amounts

Default weapon strike enchantments require original positive resolved RULE-014 physical damage before current-health saturation, equally for player/enemy sources. Ordinary misses, ineffective material and zero physical damage do not trigger by default. Mods may declare contact, successful-accuracy, zero-damage or actual-health-loss triggers through supported policies with appropriate phase placement; a future actual-loss trigger cannot be read as already known in a pre-health phase.

Retain original resolved physical amount D0, current pending physical amount Dp, separate magical damage/effects and actual physical health loss distinctly. Poison, ordinary wear and default strike eligibility retain D0 as their approved basis. Later strike changes cannot undo poison, recalculate wear, restart earlier phases or change a miss into a successful accuracy roll. Preserve overkill/prevention distinctions under COMBAT-010.

Separate magical damage uses its own declared damage type, resistance, source and intake contract. An effect explicitly modifying Dp is different from a new magical-damage operation. Do not combine all enchantment contributions into an unexplained number that bypasses resistance or duplicates critical/backstab/effect triggers. Concrete MAGIC payload definitions and numeric modifier semantics remain their owner contracts.

### Phase sequence and multiple enchantments

Per reached component/target, integrate baseline phases as follows:

1. RULE numeric physical resolution, retaining D0.
2. Eligible poison/monster payload settlement under RULE-016.
3. Equipment wear under RULE-016/ITEM.
4. Eligible weapon strike enchantments, including declared separate magical effects or Dp modifiers.
5. Primary physical health damage through CHAR using resulting valid Dp.
6. Eligible reactive payloads under current-state/chain rules.

Revalidate source/target/phase applicability after earlier mutations under COMBAT-010. Early payload/strike death or invalidation skips living-target-required later work; authoritative prevention that leaves valid combat state permits continuation. No universal rollback is implied. Settle a natural component's phases before the next, preserving the approved shared-part and live-state policies.

Applicable strike enchantments execute in explicit stable declared order. Each declares whether its supported numeric basis is D0 or current modified Dp. Missing required order/basis data is invalid, not registration-order behavior or a guessed default. Keep earlier effect results/costs if later effect fails, and enter explicit recovery without replaying the list. Exact signed/additive/multiplicative domains, rounding and final physical amount validation require ITEM/MAGIC schemas; malformed negative/overflow/nonfinite outputs cannot silently become successful hits.

### Per-target attempts and source costs

Each eligible enemy reached by cleave gets its own strike attempt at most once per applicable attack component/target. Multiple colliders/redelivery cannot multiply attempts. Activation chances, cooldowns, frequency and charge policies are moddable and must explicitly state counting unit, eligibility, spend/reset boundary and whether resistance/failure consumes an opportunity. No implicit free cleave charges or once-per-swing charging policy is approved.

ITEM/MAGIC own charge/condition/coating mutations through stable original source identity and retained operation results. Never charge a newly equipped item or clear a later replacement coating. Cost/payload settlement needs explicit recoverable boundaries; technical failure is not ordinary immunity and cannot silently spend resources or reroll.

If ordinary wear breaks/removes the live melee source before strike phase, skip its remaining strike enchantments, retaining current target's committed physical outcome. Later cleave strikes remain canceled under COMBAT-004. Mods may declare explicit Breaks payloads through supported policies, not treat a broken item as still usable by default. Mid-list break/cost exhaustion requires revalidation against the declared source/effect policy rather than continuing every callback automatically.

For already-released arrows, offensive payloads captured on the shot remain even if bow later breaks/disappears. This is the explicit COMBAT-009 projectile exception to live source use. An effect requiring a charge/condition spend must declare when committed and how an absent original source is handled. Until that contract exists, it is not safe to execute that cost-bearing payload by inventing a refund/free effect or charging another bow. Do not recall or rewrite the arrow's captured offense. COMBAT-008 payload conservation and remaining-property recovery remain binding.

### Concealment, racial abilities and observation

Positive D0 breaks the attacker's ordinary break-on-hit concealment even if later strike modifiers reduce Dp to zero. Trigger policy is moddable; stronger/protected concealment and source stacking remain MAGIC-owned. Exact placement within the committed positive-hit phases must be explicit before implementation; it cannot run in previews or repeat through per-effect callbacks.

Gameplay weapon/racial callbacks declare trigger predicates such as contact, positive physical damage, actual health loss or kill, and receive retained truthful outcomes/source identities. Racial feeding and similar abilities use explicit owner-validated gameplay operations, not arbitrary observer mutation. Their detailed eligibility, amounts and corpse/death interactions remain CHAR/MAGIC contracts.

Ordinary observation notifications run after their applicable result settles. Observing cannot authorize a second strike, repeat payloads or mutate original phase history. Required gameplay reactions must be explicit ordered owner work; optional UI/audio observers cannot replay committed operations on failure. A kill trigger relies on authoritative final death, not intermediate zero health or mere positive damage.

### Reactions and reflection

Default reactive damage/reflection runs after primary health/prevention settlement only if defender is still alive and otherwise eligible. Mods may explicitly define death-trigger retaliation. Current eligibility includes valid reactive source/attacker context under RULE-016; positive health alone does not guarantee every artifact remains available.

Use the approved D0 resolved-damage basis where RULE-016 specifies it, not unapproved aggregate magical/physical damage or actual health loss. Artifact-specific scaling/team/charge/stacking details remain MAGIC/ITEM contracts.

Reactive/reflected damage cannot trigger further reflection by default. Carry origin, parent and chain context; do not route reaction back through an entire primary weapon attack with duplicated poison/wear/strikes. Mods may enable explicitly bounded chains with validated depth/budget/visited-operation rules and declared predicates. No unbounded recursion or incidental callback-order chain behavior is allowed. Reacted-to source death/prevention then affects remaining primary components under COMBAT-010, without recalling independent released projectiles.

## Relevant formulas and parameters

Default strike gate: D0>0 for a valid qualifying physical hit. Initial Dp=D0; each declared modifier uses its stated original/current basis and supported arithmetic. Keep magical damage separate and apply current resistance/intake under MAGIC/CHAR. No universal strike bonus, charge cost, activation chance or reflection factor is introduced.

RULE-016 retains original resolved physical D0 for default poison/wear/reactive eligibility/scaling. COMBAT-004 fatigue/practice and COMBAT-008 release/recovery are independent; strike attempts cannot award extra practice merely by callback count. Reflection-on-reflection defaults false. Modded chain limits and numeric domains remain explicit schema dependencies.

## Required data

Attack/component/target/payload and session identities; original source item/actor or projectile-captured payload; D0/Dp/separate magical results/actual loss; declared trigger/basis/order; activation/random result/cooldown/frequency; charge/condition cost and completion; source/target validity/prevention/death; concealment source/outcome; gameplay versus observation role; origin/chain context and retained phase results. Concrete schemas must support stable identity and bounded scoped completion tracking.

## Inputs, outputs and events

Inputs: qualifying retained contact/hit/damage results, source/target state, declared effect policies, ITEM/MAGIC/CHAR results and reactive eligibility. Outputs: attempted/skipped/resisted/committed effects and costs, Dp modifications, separate typed damage, concealment change, validated racial operations, bounded reactions and settled notifications. APIs/signal names remain unselected. Queries/previews explain eligibility without draws, charges, condition loss, effects or practice.

## Cross-system interactions

RULE-016 trigger/wear/payload/reactive bases, RULE-004 hooks/failure, RULE-003 retained randomness; COMBAT-010 structured outcomes/phase settlement/death, COMBAT-004/005 cleave and source breakage, COMBAT-008/009 ammo payload/recovery/projectile snapshot. ITEM enchantment definitions/cost/source validity; MAGIC resistance/concealment/payload/retaliation; CHAR-019 racial inheritance and CHAR-018/023 health/prevention; NPC/LAW/QUEST attribution; AV/UI observation; CORE/SAVE required operation settlement and MOD/DATA provider/schema validation. COMBAT-012 feedback/knockback remains separate review.

## Edge cases and failure conditions

Verify misses/zero damage/material failure versus positive D0 later reduced to zero, mixed physical/magical payloads, multiple enchantments with different bases and explicit ordering, resistant targets, actual-loss and kill predicates and prevented death. Do not retroactively trigger pre-health effects from information only available after intake.

Verify cleave with source breakage/limited charges, duplicates/multiple colliders, per-component monster effects, shot fired before bow removal and recovered poisoned/enchanted arrows. Snapshot continuity is not authority to mutate nonexistent/replacement item state. A cost failure after earlier payload completion preserves those facts and uses recovery rather than replay.

Verify reflection after lethal/prevented physical damage, reflected attacker death, bounded mod chains and observer reentry. Default dead defender does not retaliate; explicit death effects must have independent valid contracts. Optional feedback failure cannot suppress required damage/costs or cause another callback run.

## Configuration and balancing options

Explicit moddable trigger predicates, ordered damage bases, activation/frequency/charge rules, concealment policy, break payloads, death retaliation and bounded reaction chains. Vanilla positive-D0 eligibility is uniform across player/enemy; no implicit enchantment-on-miss privilege. Detailed enchantment/racial/artifact values remain ITEM/MAGIC-owned. Exact schemas/provider precedence/limits are required before exposing options; no general all-callback executable ordering is approved.

## Save/load considerations

Persist completed costs/effects, payload properties and required pending phase obligations through owners; do not replay strikes, concealment breaks or racial/reaction callbacks on field restoration. COMBAT-001 cancels unfinished attack work while preserving committed facts; COMBAT-009 retains flying/pending-impact shot payloads. COMBAT-008 recovered arrows retain spent properties without replenishing charges/poison.

Mid-effect/cost/reaction saves require coherent boundaries or sufficient phase/chain completion facts. Preserve pending prevention/death obligations without restoring a fresh unbounded reflection chain. Exact eligibility/schema/migration and partial-failure recovery remain SAVE/domain contracts. Notifications alone are not durable gameplay state and cannot reapply their underlying operation after load.

## Technical constraints

Target Godot 4.7.2. Keep evaluation, typed damage, resource settlement, owner mutations and observation distinct. Use explicit phase/trigger/source identities and bounded chain context, with checked source/target revalidation. No damage mutation through presentation refresh or incidental callback order. Concrete APIs, atomicity/recovery, profile adapters and native tests remain dependencies. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Default player/enemy strikes require D0>0; alternate contact/zero-hit/actual-loss predicates are explicit supported policies with correct phase access.
2. Separate magical damage and Dp modification remain distinct; poison/wear/default eligibility retain D0 without retroactive replay.
3. Strike phase follows poison/monster effects and wear, precedes physical intake, and revalidates under COMBAT-010.
4. Multiple payloads execute declared stable order/basis; invalid required contracts fail validation rather than registration-order fallback.
5. Each reached eligible cleave target/component gets at most one attempt with explicit cost/activation policy; duplicates cannot multiply attempts/costs.
6. Broken live melee source skips remaining strikes while retaining current physical outcome and canceling later cleave; captured arrow payload persists without charging replacement bows.
7. Positive D0 breaks eligible ordinary concealment despite later Dp zero. Stronger concealment and racial gameplay operations require their owner predicates.
8. Settled observers cannot duplicate gameplay; death triggers use authoritative outcomes and technical failures retain completed effects/costs for explicit recovery.
9. Default reactions require living eligible defender after primary prevention; reflected damage cannot reflect again unless explicitly bounded mod policy permits it.
10. Save/load/retries preserve committed charges, payload state and phase/chain outcomes without repeated damage, practice, concealment or recovery items.

## Contradiction review

Reviewed against approved RULE-016, COMBAT-004/008/009/010, CHAR racial/health ownership and source/catalog/architecture. No direct contradiction identified. D04 explicitly inserts strike phase within COMBAT-010's owner pipeline, retaining D0 for earlier bases. D10 distinguishes independent captured projectiles from live melee breakage. Reactive living-state and no-reflection-chain defaults resolve previously open RULE-016 eligibility/chain details without inventing artifact factors or costs. Actual-loss/kill triggers require later-phase policies rather than reading future results. Architecture proposals remain Proposed outside confirmed contracts.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: enchantment inventory/order/basis schemas; exact modifier domains/rounding; activation/charge policy per effect; missing-source cost handling; concealment phase placement; racial/kill predicates; artifact stacking/factors; bounded mod-chain contracts; source breakage/current-target phases and save/recovery fixtures. These cannot silently trigger default strikes on misses, restore spent charges, rewrite airborne offense or enable unbounded retaliation. Remaining MAGIC/ITEM definitions and COMBAT-012 review are separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-011-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented effect/order schemas, charge policies, source mutations, racial/artifact contracts, reaction bounds and save/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
