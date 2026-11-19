# COMBAT-016 — Enemy melee reach, facing and door bashing

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Make enemy swings connect only with their intended reachable target at commitment, allowing spacing, facing, geometry and body blocking to matter. Support capability-driven deliberate door bashing without turning missed actor attacks into incidental door actions. Preserve separate player cleave behavior and mod extensibility.

## Confirmed requirements

COMBAT-016-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. The complete specification is approved under COMBAT-016-A01. COMBAT-015 supplies lifecycle/cadence/retained target and COMBAT-010/011 supply physical/effect settlement. RULE-012 already forbids default material-triggered unarmed fallback; that decision is preserved.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths relative to reference `Assets/Scripts/`.

- `Game/EnemyAttack.cs#MeleeAnimation` tests sight and yaw<22.5° using last-known target position; distance uses MeleeDistance=2.25, or optional ClassicMeleeDistanceVsAI=1.5 for nonplayer targets. TargetRateOfApproach extends initiation range.
- `MeleeDamage` uses current sensed target/current weapon, can clear weapon for nonplayer material immunity, and tests sight plus either distance<=0.25 or distance<=2.25 and yaw<35.156°. Failed actor eligibility can fall back to LastKnownDoor bash. These source behaviors are not approved default target substitution/route fallback.
- `Game/EnemySenses.cs#TargetIsWithinYawAngle` projects directions horizontally and uses strict angular comparison. Its approach value is a sampled distance difference under enhanced AI, not a frame-independent prediction duration.
- `Game/EnemyMotor.cs#HandleBashing` has a separate Speed/random/timer loop; Bashing selection depends on pursuit/last door/lock state in enhanced AI. Target unifies admission/cadence through COMBAT-015 and explicitly declares actor capability/purpose.

## Detailed rules and behaviors

### Intent and geometry at start/commitment

Enemy AI submits explicit actor-attack or door-bash intent with stable intended identity. COMBAT-015 captures identity/source/timing on admission; subsequent AI retargeting cannot redirect the current operation. A failed actor contact cannot become a door bash; a changed door cannot become an actor attack.

Baseline reach is 2.25 reference units to a valid target contact, against player and other actors alike. Do not retain the source optional 1.5-unit AI-target initiation baseline. Reach and contact geometry are actor/weapon profile data with mod overrides and Godot scale verification. Acquisition thickness cannot extend contact reach.

At commitment recheck current intended-target contact position, reach, horizontal facing and solid obstruction using current actor pose and approved source state. Attack-start sight/range is not guaranteed hit. NPC sight/awareness and capability remain explicit admission contracts, not a stale TargetInSight flag reused as proof that geometry is clear. Invalid/dead/removed target skips/misses under retained outcome handling, without replacement.

### Facing and prediction

Initial horizontal half-angle is 22.5° to start and 35.156° to connect; retain strict less-than source comparison as the baseline directional boundary. No unconditional <=0.25-distance facing bypass. Very close overlapping targets remain eligible if they have a valid in-front contact within reach/facing; targets behind enemy are not automatically struck by proximity. Mods may declare broad/omnidirectional profiles.

AI may begin winding up slightly outside reach through an explicit bounded approach-prediction profile. Actual commitment still requires current valid contact within reach. Prediction cannot deal future-position damage or bypass a wall. Exact look-ahead/default margin, target velocity sampling and clamp remain NPC tuning dependencies; do not copy sampled distance delta as a universal distance bonus.

### Contact paths and intervening actors

Use deterministic checks against authoritative target combat colliders. A reachable exposed portion can qualify despite blocked actor center, provided contact meets reach/facing and obstruction. Include close overlap without cast-origin blind spot; solid floors/walls/closed blocking doors prevent contact. Exact origin, collider authority, angular reference/contact selection and boundary epsilon need native fixtures, not random sampling.

For default single-target enemy melee, another solid actor blocking every valid path to intended target prevents contact. Do not redirect damage to that actor or pass through it by silently treating all actors as irrelevant. An alternate unobstructed valid contact may still qualify. Profile-defined cleave/friendly fire can explicitly change selection/blocking behavior.

Default enemy melee affects one intended target. Explicit creature/mod profiles can enable cleaves/sweeps, declaring candidates, order, obstruction, interruption and practice/effect policies. Player's approved default cleave remains unchanged; its actor-nonblocking rule is not automatically copied to this single-target route. Physical contact does not imply a default visual headshot; RULE-013 selects damage body part.

### Route and committed outcomes

After valid contact, resolve RULE-012 selected route/material, RULE-013 accuracy/body part and RULE-014 damage through COMBAT-010. Do not switch unarmed merely because a chosen weapon cannot affect target material. RULE-012's eligible enemy stronger-natural preference still applies at its proper stage, not as a second attempt after failed material.

Miss, blocked contact, ineffective material, zero damage and technical invalidity remain distinct. Preserve COMBAT-010 component continuation/death rules, COMBAT-011 effects/source breakage and COMBAT-012 feedback. Spacing miss does not reroll interval or refund a new unapproved NPC resource cost. Exact source snapshot versus route-choice field mapping remains COMBAT/NPC/ITEM integration.

### Capability-driven door intent

Door bash selection requires explicit NPC/creature capability plus current pursuit/behavior policy and eligible target door. Not every enemy automatically knows how to bash every door. Capability assignments and door restrictions are moddable NPC/content definitions. AI may remember a door for pursuit, but memory alone does not authorize commitment without fresh identity/reach/obstruction/state validation.

Door-bash start uses the same COMBAT-015 interval, Speed opportunity gate, captured timing and interrupt rules as melee. No separate HandleBashing-style bypass loop. One genuine admitted bash draws interval once; failed bash or door-state change retains remaining interval rather than enabling immediate retries. Player fatigue/skill practice is not imported into NPC bashing; no NPC-specific cost formula is invented here.

At commitment, if intended door is open or moving, skip bash without closing it, queueing another toggle, rerolling interval or substituting actor attack. This intentionally differs from a deliberate player's strike on a stationary open door under COMBAT-006. Movement through an open doorway remains NPC/movement behavior, not automatic teleport/scene transition.

For eligible stationary closed door use applicable shared COMBAT-006 bash contract: ordinary locked interior 20−lock value or declared exterior 25−lock value with RULE-001 limits/check semantics; unlocked closed requests opening without roll; magically held resists ordinary bash; successful ordinary unlock persists and requests applicable opening. Door bashability still governs transition-only doors. NPC capability to operate exterior transitions is not approved just because a formula exists.

Report authoritative bash noise independent of audio options. Do not assign player crime, spawn guards for player or make all enemies hostile merely because an NPC bashed. NPC/LAW owns actual applicable actor incidents/responses. Preserve one explicit door operation and declared authored links, not all matching components. Repeated valid attempts follow COMBAT-006 new-attempt/deduplication and COMBAT-015 cadence; no lock weakening or player-pick retry gate is added.

## Relevant formulas and parameters

Initial contact reach R=2.25 reference units; horizontal start/commit angles <22.5°/<35.156°. Valid target contact distance<=R; exact origin/contact conversion/tolerance require native scale tests. No <=0.25 yaw bypass and no 1.5 AI-target default. Prediction extends only permitted initiation, never actual damaging reach.

Actor and door intents share COMBAT-015 interval/opportunity, including Speed floor 8 and captured timing. Door chance retains COMBAT-006 applicable raw 20−L/25−L with RULE-001 clamp/draw, no roll for open/moving/unlocked/magically-held/non-bashable cases as appropriate. No new enemy fatigue, practice, cleave cap or door-damage formula is added.

## Required data

Attack/session/enemy/source and intended actor/door identity; explicit purpose/capability/profile; current pose/sight/awareness, contact geometry/obstruction/blocking actors; reach/facing and bounded prediction; COMBAT-015 timing/interval/opportunity; route/material/component outcomes; door lock/hold/motion/bashability and retained bash/link/noise result. Durable identity cannot be current sensed target, last-known door transform or enumeration order.

## Inputs, outputs and events

Inputs: explicit AI actor/door intent, current geometry/state/profile, admitted lifecycle marker, source/target mutation and door-owner result. Outputs: rejected admission, reachable/blocked/miss contact, one physical resolution or explicit door-bash operation, skipped changed door, retained noise/link outcome and ordinary feedback. Concrete APIs/signals remain unselected. Sensing/preview cannot bash, roll success, deal damage or reset interval.

## Cross-system interactions

COMBAT-015 cadence/lifecycle/identity, COMBAT-006 door outcomes/composition, COMBAT-010/011 physical/effect phases, COMBAT-012 knockback/feedback and COMBAT-005 distinct player cleave. RULE-012 routes/material and RULE-001/003 chance/retries; NPC pursuit/capabilities/awareness/prediction; ITEM weapons; MAGIC holds/paralysis; MOVE/LOC geometry/doors; LAW noise/incidents; AV presentation; CORE/SAVE consistent operation state and MOD/DATA validated profiles. COMBAT-017 ranged infighting remains separate review.

## Edge cases and failure conditions

Verify near/overlapping targets in front/behind, strict angle boundaries, vertical separation/stairs/floors, large colliders/exposed limbs, bars/gaps, other solid actors and targets moving during wind-up. Native contact strategy must prevent through-floor/through-wall hits while avoiding arbitrary center-only misses. Prediction never authorizes out-of-range commitment.

Verify target dies/retargets/disappears, weapon breaks/material fails and mod cleave with interposing actors. No implicit actor/door/source substitution. Preserve actual current-component commitment under COMBAT-010; source loss stops unfinished future work rather than rolling another route.

Verify closed door opens/moves/relocks/becomes magically held, invalid door capability, authored-action plus door composition, pause/load during bash and duplicate marker. Failed/changed door outcome cannot reset cadence or turn into closing. Technical definition/query/action failure needs explicit recovery retaining completed facts, not a fabricated miss or whole-bash replay.

## Configuration and balancing options

Moddable actor/weapon reach/facing/prediction profiles, explicit enemy cleaves/sweeps/friendly fire, bash capability/door eligibility and enemy-specific bash policies. Vanilla remains single intended actor, explicit door purpose, uniform initial reach and no rear proximity bypass. Exact capability inventory, profile schemas/provider precedence and numeric prediction/contact bounds remain dependencies. No universal enemy door-opening intelligence, NPC player-fatigue cost or automatic material fallback is approved.

## Save/load considerations

COMBAT-015 cancels unfinished enemy wind-up/unreleased components on load while retaining interval and committed facts. Do not restore remembered target/door or animation flags as permission for a fresh hit/bash. New action needs fresh eligible AI intent/opportunity and target validation.

Persist door unlock/state and completed links/noise/incidents through owners without reroll/replay. Partial contact/bash/physical operations need coherent SAVE boundaries or retained completion state; load cannot drop committed obligations or run both a completed actor strike and fallback door operation. Exact stable identity migration and geometry readiness follow CORE/SAVE/LOC, not arbitrary nearest-door replacement.

## Technical constraints

Target Godot 4.7.2. Separate actor/door intent, prediction/admission, current contact geometry and outcome application. Use stable identity, explicit collision/awareness profiles, idempotent marker/owner operations and COMBAT-015 scheduler. Native reach/angle/gap/body-block/door-state/save fixtures required. No exact Unity senses flag, scene-transform hierarchy or duplicate bash loop is mandated. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Enemy commit rechecks captured intended actor's current contact/reach/facing/obstruction; AI retarget cannot redirect or grant automatic hit.
2. Initial reach 2.25 applies against player/AI, with strict start 22.5°/commit 35.156° half-angles and no unconditional close rear-hit bypass.
3. Deterministic valid exposed/close contact can qualify through gaps, while solid world/interposing actor blockers prevent all blocked paths without target redirection.
4. Ordinary enemy melee is single intended target; explicit profiles can enable cleave/sweeps without changing player baseline.
5. Bounded prediction may start early but cannot extend actual commitment reach. Required malformed data uses explicit failure rather than arbitrary fallback.
6. RULE route/material/accuracy/damage remain authoritative; ineffective weapon does not silently become unarmed.
7. Enemy bash requires explicit capability/purpose/door identity, shares melee cadence and never arises as a missed actor swing fallback.
8. Open/moving intended door at commitment skips without closing/queue/interval reset/actor substitution; eligible closed door uses shared lock/hold/persistent-unlock rules.
9. Bash noise is authoritative without automatic player crime/guard spawn/universal hostility. Passage remains movement, not teleport/automatic transition.
10. Duplicate markers, recovery and load cannot reroll/repeat actor damage, door effects/links/noise or bypass saved interval.

## Contradiction review

Reviewed against approved COMBAT-005/006/010–015, RULE-012 and MOVE-021 contracts plus inspected source/catalog/architecture. No direct contradiction identified. Explicit actor/door intent applies COMBAT-015 target retention and removes source fallback. Enemy open-door skip intentionally qualifies shared player open-door bash-close behavior. NPC single-target/body blocking differs from approved player cleave by explicit choice. Material no-fallback retains RULE-012 despite source deviation. Shared bash cadence closes separate-loop bypass without importing player costs. Broader architecture proposals remain Proposed outside confirmed requirements.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: native contact origin/collider/angle reference and vertical/gap fixtures; NPC awareness/capability inventory; prediction defaults/bounds; enemy cleave schemas/order; route/source adapters; door intent/motion/link/noise integration and save/recovery boundaries. These cannot reintroduce rear proximity hits, material fallback, incidental door bash or interval bypass. COMBAT-017 ranged behavior remains separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-016-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented contact geometry, NPC capability/prediction profiles, source adapters, door integration and save/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
