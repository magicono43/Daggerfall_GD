# COMBAT-012 — Hit feedback and knockback

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Communicate settled combat outcomes with appropriate sounds, blood and voices, and provide bounded collision-safe physical knockback. Preserve consistent response across strike-enchantment changes, repeated hits, movement modes and save/load without making cosmetic feedback control gameplay.

## Confirmed requirements

COMBAT-012-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. The complete specification is approved under COMBAT-012-A01. COMBAT-010/011 damage accounting, prevention, ordered phases and interruption rules remain binding. This feature chooses different explicit bases for injury feedback and knockback; it does not rewrite earlier effect/wear triggers.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths below are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#WeaponDamage` chooses hit sounds, blood, knockback and optional humanoid 40% pain voice before strike enchantments may change damage. Heavy voice classification uses damage >= MaxHealth/4. Nonpositive results may use parry or swing sounds based on target traits/source.
- `Game/EnemyAttack.cs#ApplyDamageToNonPlayer` has similar target feedback and weight-based knockback; player intake differs. The target does not infer universal player knockback from this enemy motor path.
- `Game/EnemyMotor.cs#KnockbackMovement` caps internal strength, limits actual movement speed, reduces strength on ClassicUpdate, uses swim/fly/ground movement routes and suppresses CanAct. It avoids forcing Hurt over PrimaryAttack and skips handling during Seducer transformation. The target uses explicit eligibility/interrupt policy rather than copying incidental branch precedence or animation flags.
- `Game/EnemyBlood.cs#ShowBloodSplash` spawns a one-shot billboard from blood archive/index at a supplied position. `EnemySounds` owns sound selection. Asset availability and anatomy/material compatibility require AV/content verification.
- `Game/Player/PlayerSpeedChanger.cs` defines classicToUnitySpeedUnitRatio=39.5, described as an estimated conversion. Native speed/decay tuning cannot simply assume that ratio is Godot's final world scale.

## Detailed rules and behaviors

### Settled injury feedback

Physical blood and pain responses use settled physical intake and require actual physical health loss by default. Do not emit injury from original RULE-014 damage merely because it was positive before strike modifiers/prevention. Keep original D0, modified delivered physical amount D, actual physical loss L and separate magical results distinct under COMBAT-010/011.

Miss, zero damage, prevention and separate magical damage use their applicable feedback policies rather than false physical blood. Trigger predicates/feedback are moddable. Actual contact point can position feedback but does not turn RULE-013 probabilistic body-part selection into aimed headshots.

For accuracy miss/zero-damage contact, use declared target parry/deflection sound where supported, otherwise a suitable miss/weapon sound. Ineffective material retains COMBAT-010's distinct nonmodal explanation, once per attack. Parry audio is presentation, not a new active block/shield mechanic. No new generic damage-number display or popup system is introduced.

Lethal physical hits may show eligible blood/impact feedback but no ordinary living-actor pain voice or knockback after confirmed death. Death/corpse displacement is a separate moddable death-presentation policy. CHAR's authoritative prevention/death outcome determines survival; an intermediate zero-health write is not final death.

### Optional pain voices

For surviving eligible humanoid combat actors with L>0, optional pain voice chance is 40%. Heavy injury classification is L >= effective maximum health/4 for the settled intake context; equality qualifies. Preserve the fractional one-quarter comparison or an exact equivalent, not an accidental integer-floor threshold change. Voice chance/classification/predicates are moddable; exact definition/asset mapping remains AV/NPC integration.

Use presentation-only randomness separate from gameplay RNG under RULE-003. Disabling/missing voices cannot change hit/damage, effect activation or knockback. Retain settled notification identity so duplicate callbacks do not reroll/replay voices or blood. Exact sound overlap/rate limiting and missing-asset fallback remain AV contracts; optional feedback failure cannot replay gameplay.

### Knockback eligibility and damage basis

Default attack knockback affects eligible living combat NPCs/enemies. Player knockback is off unless explicit mod/separately approved effect enables it. Actor eligibility/resistance/immunity is moddable and must include valid movement mode/capability. Do not infer immunity solely from whether a Hurt animation exists.

Use final enchantment-modified physical amount D actually delivered to primary intake before health saturation, not original D0, actual loss L or combined magical damage. D>0 and a valid delivered physical intake are required. Skipped intake or D=0 gives no default impulse. Overkill can supply force, but confirmed death suppresses ordinary living knockback. Prevention outcomes revalidate current survival/movement eligibility; no automatic target displacement after relocation/invalidity.

Knockback is authoritative movement and must not depend on blood/audio options or success of cosmetic presentation. Apply each qualifying intake impulse once with stable attack/component/target identity. Independent component hits can each propose impulses under the combination rule; duplicate delivery cannot.

### Strength, repeated hits and direction

Retain the initial DFU damage/target-weight relationship with bounded minimum/maximum strength and time-based decay. Expose coefficients and resistance to mods. Valid weight must be positive and within supported domains; unknown/zero weight needs explicit actor policy or error, not division by zero, an invented mass or accidental infinite force. Exact converted bounds/decay values require Godot-scale tuning before implementation.

When already knocked back, replace remaining strength and direction only if the new validated impulse is stronger. Equal/weaker impulses leave current state unchanged, without refreshing it or adding duration. Combination policy is moddable. No baseline additive stacking that can produce unbounded rapid-hit force.

For grounded targets project incoming attack direction horizontally and normalize the valid result. No upward launch by default. A purely vertical incoming direction has no valid horizontal direction; exact no-horizontal-impulse handling/tolerance requires declared native policy rather than inventing random push direction. Flying/swimming targets may receive full 3D displacement through their movement owner. Direction policies are moddable. Physical contact/movement context determines incoming direction, not the attacker's later facing or current-target lookup.

### Movement, collision and action eligibility

Movement owner resolves displacement through normal collision, stopping/sliding as appropriate. No default wall-impact damage, crush damage, teleportation or forced shoving of other actors. Mods may define explicit collision-damage policies. Crossing a ledge can invoke ordinary mode/fall consequences; this feature grants no fall immunity or new fall formula.

Active knockback suppresses voluntary movement and new attack starts. An already-started attack may finish unless a separate explicit stun/paralysis/interrupt policy cancels it. Hurt visuals alone cannot cancel gameplay. Existing COMBAT-001/010 interruption and source invalidation still apply; this rule does not preserve an attack after genuine death or weapon break.

Modded stagger interruption/resistance must be explicit. Movement should report actual force/state to NPC attack admission rather than setting arbitrary visual animation as authority. Mode transitions, support loss and incompatible actor states require movement/NPC integration, not simultaneous competing motors. Ordinary pause freezes impulse progression/decay; no wall-time catch-up occurs.

## Relevant formulas and parameters

For source physical D>0 and valid classic weight W>0, the inspected formula uses A=((10D−W)×256/(W+10D))×2D, then K=(10D/W)×(2D−A/256)/c, where c=39.5/10 is the source conversion. Algebraically this is K=40D²/((W+10D)×c) for valid exact arithmetic; target numeric order/rounding must be verified rather than silently introducing overflow/cancellation differences.

Source reference parameters are lower initial K=15/c, internal cap 40/c, actual travel speed cap 25/c and decay 5/c per 0.0625-second classic step. They document the inspected model, not independently finalized Godot tuning values. Use validated native-unit equivalents and eligible elapsed time; retain separation of remaining strength from capped movement speed if keeping that model. Do not tie decay to rendered frames or accidentally apply it twice through simulation ticks.

Pain voice P=40% for eligible survivors; heavy iff 4L>=M, where M is valid effective max health for the settled intake context, using safe arithmetic. Feedback predicates, knockback weight relationship/bounds/resistance/combination/direction and voice parameters are moddable. No default magical knockback, new critical multiplier, wall damage or corpse impulse is added.

## Required data

Attack/component/target/session identity; settled D0/D/L and prevention/death result; contact/physical incoming direction; actor class/anatomy/feedback traits; effective max health context; optional voice setting/presentation RNG; valid weight/resistance/eligibility; proposed/current remaining strength/direction/decay state; movement mode/collision authority; completion/notification identities and save restore status. Raw animation/engine callback IDs are not durable authority.

## Inputs, outputs and events

Inputs: settled physical intake, valid actor/source/contact context, feedback settings/profiles, movement/collision state, eligible elapsed time and save/load. Outputs: deduplicated hit/parry/miss/blood/voice presentation, accepted/rejected/replaced impulse, collision-checked displacement, voluntary/new-attack restriction and expiration. Concrete APIs/signals remain unselected. Optional feedback observers cannot independently apply force, health damage, practice or repeated gameplay effects.

## Cross-system interactions

COMBAT-010/011 damage/effect accounting and authoritative prevention; COMBAT-004/005 components/cleave; COMBAT-009 incoming projectile contact; COMBAT-013 and later death/attack features; CHAR health/death; NPC actor/movement/admission; MOVE collision/modes/fall history; ITEM/MAGIC resistance/explicit effects; AV blood/audio/voices; RULE-003 presentation RNG; CORE eligible time; SAVE movement restoration and MOD/DATA profiles. Catalog RULE-019 dependency is not evidence that pacification determines knockback formulas; applicable NPC hostility remains its own owner contract.

## Edge cases and failure conditions

Verify D0>0 but strike reduces D to zero, physical intake skipped after magical payload death, prevention leaving live/relocated defender, overkill, zero actual loss, distinct magical damage and lethal versus surviving feedback. No false physical injury/voice from an obsolete damage estimate.

Verify low/high/invalid mass, clamps, repeated equal/weaker/stronger impulses, multiple attackers/directions, pure vertical shot against grounded actor, flight/swim transitions, narrow corridors, crowds and ledges. Native tests must establish thresholds and movement behavior; query/actor failure cannot be interpreted as random immunity or safe teleport recovery.

Verify started NPC attack during knockback, forbidden new attacks, separate stun, transformation/temporary immunity, source death and component completion. Do not cancel attacks from Hurt visuals or let a restored animation restart them. Duplicate notifications cannot apply/restart force or voice rolls.

## Configuration and balancing options

Moddable injury predicates/material/anatomy feedback, voice chance/heavy threshold, knockback actor eligibility/resistance/immunity, strength coefficients/bounds/decay, combination/direction and explicit stagger/collision/death displacement effects. Default player knockback, upward grounded launch, additive force and wall damage remain off. Exact profile/schema/range/provider contracts and native tuning are dependencies; no new mandatory player-facing sliders are approved here.

## Save/load considerations

Pause freezes remaining knockback progression. Native saves preserve authoritative remaining force/direction and required decay/mode/restriction state so loading cannot erase displacement. Restore through NPC/movement owner only after geometry/placement readiness. Preserve contextual motion/fall obligations and COMBAT-001 unfinished-attack policy; restoring movement must not revive an attack canceled by load.

Do not replay already-played blood, sounds or voices. Save boundaries/completion facts must prevent reapplying an impulse already represented in saved movement. Pending required movement application differs from an optional presentation event; exact schema/migration and coherent intake-to-impulse snapshot boundary remain SAVE/domain contracts. Invalid required movement context uses explicit recovery, not silent force reset or fabricated collision-free placement.

## Technical constraints

Target Godot 4.7.2. Separate authoritative knockback from optional feedback; use stable intake identity, validated native units and eligible time. Movement owner remains collision authority; no direct teleport from a presentation handler. Preserve current-state prevention/death gates, bounded impulse handling and idempotent notifications. Concrete algorithms, scheduler order, native tuning, relative collision and persistence fixtures require engineering verification. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Physical blood/pain requires settled actual physical loss by default; distinct miss/zero/prevention/magic policies avoid false injury.
2. Lethal hits can show blood/impact but not ordinary pain voices/living knockback; final authoritative prevention controls survival.
3. Eligible surviving humanoids use optional 40% pain voice and heavy iff L>=M/4; presentation RNG/options cannot change gameplay.
4. Knockback uses delivered final D before saturation, not D0/L/combined magic; skipped or zero physical intake gives no default impulse.
5. Baseline affects eligible combat NPCs/enemies, not player; valid bounded weight/strength/resistance avoids zero-weight errors and unbounded force.
6. Stronger impulse replaces remaining state/direction; equal/weaker does not refresh/add. Duplicate intake cannot reapply impulse.
7. Grounded displacement is horizontal, flight/swim may be 3D, and movement collision handles walls/crowds/ledges without default wall damage/crush/teleport/shove.
8. Active knockback suppresses voluntary movement/new attacks, while started attacks continue unless explicit independent interruption applies. Visual Hurt does not cancel gameplay.
9. Non-injury sounds follow declared parry/miss policy without adding active blocking. Material explanation remains once per attack.
10. Pause freezes knockback; native restore preserves remaining movement after readiness without replaying force or already-played optional feedback.

## Contradiction review

Reviewed against approved COMBAT-001/004/009/010/011, MOVE-004 motion/suspension ownership and CHAR prevention/death contracts plus source/catalog/architecture. No direct contradiction identified. Knockback's delivered modified physical basis is explicitly different from RULE-016 original-D0 effect/wear basis; neither rewrites the other. Injury feedback uses actual physical loss and avoids DFU's pre-enchantment estimate. Knockback alone is not an interruption, while genuine death/paralysis/source invalidation still cancels under earlier approvals. Persistence retains movement but does not revive unfinished attacks or replay sounds. Architecture proposals remain Proposed beyond confirmed requirements.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: native strength/bounds/decay tuning and valid mass policies; horizontal-degenerate direction; movement-mode/state admission; feedback asset/anatomy mappings and sound concurrency; exact max-health snapshot; coherent intake/impulse/notification ordering; mod schemas and save recovery fixtures. These cannot silently add player knockback, additive stacking, visual-driven attack cancellation or load-time erasure of force. Death/corpse presentation and COMBAT-013 intake review remain separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-012-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented native tuning, actor/movement policies, feedback mappings, ordering, mod schemas and save/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
