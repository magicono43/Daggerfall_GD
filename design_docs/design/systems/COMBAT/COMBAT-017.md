# COMBAT-017 — Enemy ranged and infighting delivery

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Make enemy ranged attacks use deliberate retained intent, finite default ammunition and actual-contact delivery, with shared physical/effect rules for player and nonplayer victims. Support moddable supply/cadence/aim policies without double actions, mutable-target impacts or unconditional infighting escalation.

## Confirmed requirements

COMBAT-017-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews. The complete specification is approved under COMBAT-017-A01. COMBAT-009/014 already own released projectiles/spells, COMBAT-015 the enemy lifecycle, and RULE/COMBAT-010/011 the shared physical/effect pipeline. NPC owns action preference, loadouts and retaliation; MAGIC owns spell costs/recovery.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths relative to reference `Assets/Scripts/`.

- `Game/EnemyMotor.cs#DoRangedAttack` checks distance>EnemyAttack.minRangedDistance (6) and <maxRangedDistance (51.2), sight/detection and capability. ClassicUpdate plus yaw<22.5° leads to bow opportunity 1/32 or ranged spell 1/40 when eligible animation state permits. Its bow-first else branch is not approval of universal NPC preference.
- `Game/EnemyAttack.cs#ShootBow` creates a missile with caster/arrow flags without local ammo removal. `BowDamage` applies player/nonplayer damage using current sensed target/equipment and inserts a generic recovery arrow. Target instead consumes finite ammo by default and uses per-shot payload/actual-contact contracts.
- `Game/DaggerfallMissile.cs#GetAimDirection` uses prediction or last-known position and a player-crouch-specific downward adjustment. `AssignBowDamageToTarget` can require contact with current sensed target. Target uses retained intended identity/current geometry at release and independent actual-contact impacts.
- Source nonplayer attacks route through ApplyDamageToNonPlayer/DecreaseHealth, while player intake/guards differ. Target shares approved rule/phase contracts, retaining explicit legal/prevention/actor policies rather than assuming identical presentation or actor capabilities.

## Detailed rules and behaviors

### Intent selection and start admission

NPC AI selects one bow or ranged-spell intent before admission. Do not independently roll competing routes then start both. Preference, alternate action selection and no-ammo/no-magicka fallback are explicit moddable NPC policies. No universal bow preference, forced charge into melee or infinite replacement ammo is invented here.

Ordinary initial start limits are intended target distance>6 and <51.2 reference units, current detection, clear sight and horizontal facing half-angle<22.5°. Profiles may override by actor/weapon/spell; native geometry/scale verification required. Start admission also checks source capability/resources, COMBAT-015 restriction state and no active attack. These are initiation limits, not a projectile auto-despawn range after release.

While otherwise eligible, selected bow intent gets a 1/32 start opportunity and selected ranged-spell intent 1/40 per 0.0625 eligible seconds. Use unbiased owned RNG representing exact fractions, not rounding them to integer-percent checks. Retain logical opportunity/admission result for technical duplicate handling. No player melee interval/bow cooldown is automatically applied. MAGIC affordability/casting recovery and explicit NPC/mod cadence still constrain spell start.

Only one active enemy attack at a time, including wind-up/animation/recovery; no queued attack from an earlier rejected opportunity. Eligible tick/backlog scheduling follows CORE-017 without simultaneous catch-up bursts or frame-rate-dependent attempts. Cadence is moddable, including explicit extra recovery policies; no new default fixed ranged interval is added.

### Retained target, aiming and release validation

COMBAT-015 retains intended target/source and captured animation timing at attack start. At actual release check retained target exists/is valid and passes required sight, facing and configured range. Failure cancels without retargeting current AI choice or firing at remembered empty space. Mods may explicitly define suppression/blind-fire behavior. A canceled ranged intent does not automatically become melee or a spell in the same operation.

Aim at intended target's current valid position at release using actual target posture/collider geometry. Optional bounded predictive lead may use valid target movement and actual projectile speed. Do not use an arbitrary player-only crouch offset or stale source-space point as authority. Exact aim point, prediction defaults/limits and distance reference are NPC/native profile dependencies.

Released shots fly independently/nonhoming by default. Later AI retarget, source equipment change/death or target movement does not redirect/recall them. COMBAT-009 captures arrow offense/source and selects actual contacted actor; COMBAT-014 captures spell payload/current target applicability. Checked origins/traveled segments/blockers and native persistence follow those approved contracts. Initial target becoming invalid after release does not erase a valid airborne shot.

### Finite ammunition and modded supply

Ordinary enemy archers require finite eligible arrows from their own inventory at start and release, consuming them only on successful release. Do not reserve during wind-up or draw automatically from another inventory. Reuse COMBAT-008 summoned-first/shortest-life priority, quest-arrow exclusion, stable identity ties, actual type selection at release and captured per-arrow payload/properties.

Supply, eligibility, consumption and replenishment policies are explicitly moddable, including generated/unlimited creature ammunition. Generated shots need declared provenance/payload/recovery semantics; unlimited supply is not inferred merely because a prefab can be instantiated. NPC/content must define starting quantity and resource-empty behavior. No default quantity/restock timer is selected.

Release-time missing/invalid ammo cancels without phantom projectile/consumption or successful-release award. Do not import player fatigue/practice accounting into NPCs without a separate declared actor policy. COMBAT-008 multishot/conservation applies where an explicit NPC profile supports it: full configured units unless partial policy declared, per-projectile identity and at most one recovered unit per arrow. Player-specific cost/cooldown remains player-owned.

Prepare/validate before commitment; partial technical failures retain successful projectiles/consumed units and required obligations without replaying volley, refunding blindly or spawning replacements. Same-operation recovery is distinct from a new genuine attempt. No default extra cooldown penalty on failed enemy release is introduced here; completed animation/restriction/recovery and fresh opportunities still govern admission. Melee timer is neither rerolled nor bypassed by treating ranged failure as another melee start.

### Actual impacts and infighting resolution

Enemy attacks against player/nonplayer use shared approved route/material, accuracy/body-part, physical damage and effect/phase contracts under RULE-012–016 and COMBAT-010/011. Actor-specific inputs, prevention, effect eligibility and presentation remain explicit. This does not invent player-only traits for enemies or bypass material rules against allies. Infighting intent/allegiance is NPC policy, not a separate damage formula.

Physical projectile impacts resolve actual eligible actor contacted, even if ally/civilian/other enemy or not current AI target. First blocker stops baseline arrow even on miss/zero damage. Arrow recovery follows COMBAT-008 actual target/summoned/corpse-safe rules. Spell delivery follows COMBAT-014 separate blocking/applicability, area and resistance policies; spell costs/effects are not physical bow calculations.

Player recipients use COMBAT-013 typed intake and CHAR prevention/death. Other recipients use their corresponding authoritative health/prevention/death contract rather than direct caller-declared death. Preserve resolved versus actual health loss and component termination; do not rerun mitigation at intake or directly duplicate recovered arrows in a separate enemy callback.

Report original responsible actor and actual victim with retained source/operation outcome to NPC/LAW/QUEST. Those owners decide retaliation, allegiance, crime and quest reactions. Accidental hit cannot directly make every nearby actor hostile or switch the shooter's target from inside damage delivery. Report attempts/damage/death truthfully under owner-defined incidents, without multiplying attribution on callbacks or revealing hidden actors through optional feedback.

## Relevant formulas and parameters

Initial admission 6<distance<51.2 reference units, yaw<22.5° and detected/clear target. Exact distance/contact references require native fixtures. Opportunity probabilities are exactly 1/32 bow and 1/40 ranged spell per 0.0625 eligible seconds for selected otherwise-eligible intent; at most one active action, no guaranteed firing interval inferred from these random chances.

No default enemy use of COMBAT-015 melee interval or player RULE-015 bow cooldown. Animation timing still captures through COMBAT-015. Arrow speed/lifetime and spell profile dimensions remain COMBAT-009/014, not overridden by admission range. Finite baseline ammo consumption is one per actual arrow; modded volleys/generated supply require explicit policy. No NPC fatigue, leveling-practice or hostility probability is selected.

## Required data

Enemy/session/attack/intent and intended target identity; selected bow/spell capability/profile; current detection/sight/range/facing and target posture/velocity; captured timing/source; opportunity phase/result; own inventory or declared generation policy; release-time ammo count/payload and projectile identities; current MAGIC admission/resource outcome; actual impact victim and stable attribution; partial completion/recovery. Raw current sensed target or mutable last weapon cannot replace per-shot context.

## Inputs, outputs and events

Inputs: selected NPC intent, current target/resource/capability/restriction state, eligible opportunity tick, release marker, projectile preparation and actual impact/owner resolution. Outputs: rejected opportunity/admission, one admitted ranged action, cancellation or committed shot, retained resource outcome, independent released payload and checked attribution. APIs/signals remain unselected. Target queries/previews cannot spend ammo/magicka or create projectiles/hostility.

## Cross-system interactions

COMBAT-015 lifecycle/target/timing, COMBAT-016 alternative melee/contact, COMBAT-008 ammunition, COMBAT-009 arrows, COMBAT-014 spells, COMBAT-010/011 shared effects and COMBAT-013 player intake. RULE routing/accuracy/damage and RULE-003 RNG; ITEM inventory/custom ammo; MAGIC affordability/cast/recovery/stacking; NPC selection/loadouts/prediction/infighting; LAW/QUEST attribution; CHAR vitals/death; AV animation/feedback; CORE/SAVE eligibility/persistence and DATA/MOD validated policies. Guard/civilian escalation details remain COMBAT-018/019 reviews.

## Edge cases and failure conditions

Verify switching AI target during wind-up, target disappearing/moving outside limits, ally interception after release, source death/bow change, crouched/nonplayer/small actors and predictive leading at varied speed. Admission sight/range does not guarantee contact; committed projectile actual collision is authoritative.

Verify finite last-arrow use, quest exclusion, summoned expiry, generated supply, no-ammo selection fallback, simultaneous bow/spell intent and partial multishot release. No resource failure may secretly create free ammo or start another route's action. Required profile/manager failure is technical recovery, not ordinary invalid target or resistance.

Verify NPC-versus-player/nonplayer equivalent rule inputs, zero-damage recovery, lethal corpse transfer, source attribution after removal and duplicate delivery. Shared contracts do not force identical feedback/traits or automatic retaliation. No default actor friendly-fire immunity contradicts COMBAT-009; spell eligibility can differ explicitly under MAGIC.

## Configuration and balancing options

Moddable ammo supply/eligibility/consumption/generation, starting-resource content, action preference/fallback, ranged distances/facing/opportunity rates, explicit cadence/recovery and prediction/blind-fire policies. Initial values retain inspected admission/cadence while replacing implicit infinite ammo/mutable-target delivery. Exact schemas/provider precedence/numeric limits and concrete creature loadouts remain dependencies. No vanilla unlimited resupply, universal retaliation rule or new player setting is approved.

## Save/load considerations

COMBAT-015 load cancels unfinished enemy ranged wind-up/unreleased work, retaining committed facts and requiring fresh eligible AI intent/opportunity. No restored ShootArrow flag can recreate a shot. Own ammo/generation state and completed consumption persist through ITEM/NPC/SAVE; do not replenish finite supplies simply by loading actor state.

COMBAT-009/014 preserve released projectiles/areas in saved location, with captured source/payload and pending impact outcomes. Do not also deliver an old mutable EnemyAttack damage message. Partial release/impact/attribution needs coherent save boundaries or retained completion records, preserving required obligations without duplicating recovery, legal/quest reaction or consumed ammo. Exact opportunity fractional phase/new actor loadout initialization and required mod schemas remain owner contracts.

## Technical constraints

Target Godot 4.7.2. Separate selected intent, opportunity/admission, resource preparation, release, projectile simulation and actual-recipient resolution. Use stable identities, explicit actor policies and retained per-arrow/spell data. No current-target/current-equipment lookup for earlier airborne shots or duplicate independent bow/spell admission. Native cadence, prediction, ammunition and save/failure fixtures required. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Selected bow/spell intent admits at most one active action; preference/resource fallback is explicit and moddable, not callback order.
2. Initial ranged checks enforce 6<distance<51.2, detection/sight/yaw<22.5°; eligible bow/spell opportunities are 1/32 and 1/40 per 0.0625 eligible seconds without catch-up bursts.
3. Release revalidates retained target and required geometry, cancels invalid intent without replacement/blind fire, and uses current target geometry/bounded optional lead.
4. Released shots retain source/payload and actual-contact behavior independent of later target/source changes, without default homing.
5. Finite own-inventory ammo is default, using approved selection/revalidation and consumption once per actual arrow; explicit mods can generate/unlimit supply or configure volleys.
6. Missing ammo cannot yield phantom shots/player fatigue/practice; partial technical release preserves successful facts without duplicate/refund/new volley.
7. Player/nonplayer recipients use shared approved physical/effect rules and authoritative intake, retaining actor-specific eligibility/prevention.
8. Actual victims receive approved arrow recovery/spell delivery; original source attribution reports to owners without universal hostility or direct forced target switch.
9. Native load cancels unreleased intent but preserves inventory/committed shots and required outcomes without replenishment, re-release or duplicate impact/attribution.

## Contradiction review

Reviewed against approved COMBAT-008–016, RULE physical/effect contracts and CORE simulation/load ownership plus source/catalog/architecture. No direct contradiction identified. D02 explicitly settles COMBAT-008's formerly open enemy supply baseline while preserving moddability. Ranged cadence remains separate from melee interval/player cooldown as COMBAT-015 required. Retained intended target at release differs from actual impact recipient consistently with COMBAT-009. Shared resolution does not erase per-actor traits/health/legal policy. Player-only fatigue/practice is not imported into NPC supply. Architecture proposals remain Proposed outside confirmed contracts.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: NPC loadout quantities/action preferences/empty fallback; range reference and aim/prediction profiles; exact opportunity and release tie ordering; generated-ammo provenance; MAGIC recovery integration; actor health/incident adapters; mod schemas and partial-operation/save fixtures. These cannot silently restore infinite default ammo, retarget airborne shots, double-admit bow/spell or directly force universal hostility. COMBAT-018/019 civilian/guard details remain separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-017-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented NPC loadouts/preferences, aiming/cadence ordering, generated supply, actor adapters, mod schemas and save/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
