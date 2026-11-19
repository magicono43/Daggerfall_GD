# COMBAT-018 — Civilian hits and guard escalation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Retain DFU-style instant killing of ordinary mobile civilians on eligible player physical contact, with explicit moddable exceptions. Preserve civilian/guard identity and truthful attack/death incidents while separating actual combat outcomes from crime classification, detection and enforcement.

## Confirmed requirements

COMBAT-018-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews. User explicitly retained default civilian contact-kill instead of proposed ordinary health/accuracy model, while requiring moddability. The complete specification is approved under COMBAT-018-A01. LAW owns crime/detection/enforcement; NPC/CHAR/content own authoritative actor state and applicable protection; COMBAT-019 guard surrender remains separate review.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete NPC prefab/content/ranged/spell reachability and runtime/classic parity remain unverified. Source unchanged. Paths relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#WeaponDamage` checks MobilePersonNPC before ordinary enemy resolution. Nonguard mobile contact spawns blood, deactivates the civilian, tallies crime-guild requirements with amount 5, sets Murder and calls SpawnCityGuards(true). If an entity exists it sets health zero and invokes racial OnWeaponHitEntity.
- Guard mobile contact sets Assault, calls PlayerEntity.SpawnCityGuard at the mobile pose, obtains new enemy components and deactivates the original mobile. Subsequent normal damage uses the spawned representation. Local code assumes usable spawn/components; safe identity/pending-hit recovery requires explicit target contract.
- `Game/Entities/PlayerEntity.cs#SpawnCityGuards`/`SpawnCityGuard` provide enforcement spawning. Source direct crime/guard/guild side effects are evidence, not approval to bypass LAW attribution/detection or duplicate consequences.
- Target retains selected ordinary civilian physical-contact shortcut but replaces component/representation-driven identity loss and unconditional local legal response with checked owner operations.

## Detailed rules and behaviors

### Valid contact and ordinary civilian shortcut

Eligible player melee/unarmed contact or player arrow contact with an ordinary mobile civilian invokes default contact-kill instead of normal physical accuracy/damage rolls for that civilian. Guards, combat actors and already-dead targets are excluded. Interaction clicks, mere attack start, overlapping broad-phase candidates or a miss that never reaches the civilian do not qualify.

Use COMBAT-005 deliberate central civilian targeting when no reachable combat enemy takes priority; ordinary civilians are not incidental default melee-cleave targets. Arrows use COMBAT-009 actual first-blocker contact and retained player source, not current equipment/target. Shot collision is enough for eligible shortcut; do not first resolve an ordinary civilian accuracy miss then inconsistently count contact as no kill.

Submit an explicit authoritative civilian lethal/death operation with attack/target/source/session identity. Default eligible unprotected outcome is death, but do not declare murder, run a racial kill callback or permanently remove the actor before owner confirms death. A mobile actor lacking ordinary combat stats must still have a valid identity/outcome contract; missing required data is technical recovery, not fabricated success.

Civilian shortcut is moddable: support alternate health/damage, source/target eligibility and explicit protection/prevention policies. Quest/content/mod definitions may exempt a particular civilian or supply prevention; mere quest linkage does not protect every linked actor. If prevention/exemption leaves actor alive, retain actual contact/result without a kill fact. Concrete alternate stats, health/accuracy mapping, protection priorities/costs and death mechanics remain NPC/CHAR/QUEST owner contracts.

### Scope of other damage and abilities

Spells use MAGIC effect applicability/outcomes, not automatic death from magical contact. Harmful effects may kill through their declared policies; healing/benign effects cannot become a civilian murder shortcut. COMBAT-014 governs actual delivery/deduplication independently of effect outcome.

Nonplayer arrows, infighting and hazards do not inherit the player shortcut automatically. Explicit NPC/content damage policies govern their civilian outcomes; preserve true responsible source rather than blaming player. No universal civilian invulnerability or automatic instant death for these routes is invented here.

Civilian contact-kill grants no default weapon/Hand-to-Hand/Critical Strike practice under COMBAT-004. Arrow release practice already granted under player bow rules remains real; do not remove it or add another civilian impact award. Explicit racial contact/kill abilities receive settled truthful outcomes once under COMBAT-011 owner contracts. Failed/prevented/duplicate death cannot grant feeding/confirmed-kill rewards. Enchantment/poison effects on special civilians require explicit compatibility/trigger policies rather than silently running the entire ordinary enemy pipeline in addition to shortcut.

### Peaceful guard combat activation

Valid hostile player weapon/arrow contact activates a peaceful guard's combat representation before ordinary accuracy/damage resolution. Activation may occur even if subsequent roll misses or damage is zero. Benign spell response remains explicit MAGIC/NPC policy; there is no universal any-contact hostility rule.

Retain guard's stable identity and persistent state across representation change: current relevant vital/state, inventory/equipment ownership, faction/quest/legal associations and lifetime scope must map through a declared NPC adapter. Exact field list/model conversion is required engineering/content work, not permission to reset health, grant duplicate loot or replace the actor with an unrelated guard.

Deliver pending damage once to that same identity through COMBAT-010 rules. Future missiles already referring to actor identity must resolve its valid current representation, not old collider or newly assigned arbitrary actor. A representation conversion cannot create two attackable/rewardable guards or apply original contact twice.

If activation/spawn/mapping fails, preserve original actor and pending operation for explicit recovery. Do not deactivate/delete it first, repeatedly spawn a replacement or lose the hit. Exact safe preparation/publication and partial cleanup boundary remains NPC/CORE integration. Conversion is not itself an authoritative assault/murder classification or permission for guard waves; combat/behavior eligibility and LAW response remain distinct owner results.

### Incident facts, classification and enforcement

Report distinct attack-attempt/contact, actual injury and confirmed-kill facts with responsible actor, actual victim and operation identity. Keep shortcut lethal outcome distinguishable from ordinary rolled physical damage; do not invent a numeric damage roll merely to fit reporting. Source location/jurisdiction/time and witness/knowledge context require LAW/NPC schemas, not combat guesses.

LAW decides assault/murder/other classification, detection, suppression/exceptions, charges and enforcement. Combat does not directly set global crime enum, spawn guards or make every nearby actor hostile merely from contact. A confirmed unprotected shortcut kill produces real death evidence, while a blocked/protected/invalid operation cannot fabricate murder. An incident fact is not proof every guard knows it.

NPC/FACT/QUEST and racial/guild reward owners consume appropriate retained facts through explicit checked predicates. Source +5 crime-guild tally is not newly approved here as a universal combat reward amount. Exact witness rules, legal jurisdiction, self-defense exceptions, guild credit and response/spawn policy remain their feature reviews. Required fact delivery must be reliable/idempotent with explicit recovery, not optional UI observation that can lose gameplay consequences.

### Outcome persistence and presentation

Commit actor outcome before optional blood/death feedback and enforcement presentation. Physical injury blood uses actual settled injury/death policy under COMBAT-012, not early contact flash when protection prevented harm. Default civilian kill can show appropriate lethal feedback; no living pain/ordinary knockback after confirmed death. Corpse existence, loot/death displacement and civilian removal timing need NPC/death owner contracts; this feature does not invent civilian corpse inventory contents.

Completed actor death, guard conversion and accepted incident/reward facts cannot repeat through duplicate collider callbacks, transition retry or restore. Preserve independent same-operation stages so technical failure after death does not resurrect/re-kill actor just to retry LAW reporting. Presentation/guard-response failure cannot undo valid death or replay damage/credit.

## Relevant formulas and parameters

Default ordinary civilian shortcut has no physical accuracy/damage roll: valid eligible player contact requests authoritative death, subject to explicit protection/alternative policy. No minimum weapon damage or instant-kill probability is invented. Guards use approved ordinary RULE-012–016/COMBAT-010 resolution after safe activation, not civilian shortcut.

Default civilian impact combat-practice award=0. Existing player arrow release awards remain COMBAT-004/008. Source crime-guild tally 5 and unconditional guard request are reference observations, not adopted LAW/FACT values. No detection probability, guard count/radius, protection chance or generic civilian HP value is selected here.

## Required data

Attack/contact/session/location and stable civilian/guard identity; responsible actor/projectile/source type; ordinary-mobile versus guard/combat/dead classification; valid contact/purpose; explicit shortcut/protection policy and settled death/prevention result; guard representation conversion/state mapping and pending damage completion; typed attempt/injury/kill incident identities/receipts; owner reward/presentation completion. Raw component presence, transform/spawn instance and global crime enum cannot be the whole outcome record.

## Inputs, outputs and events

Inputs: valid actual physical contact or separately authorized spell/hazard outcome, actor/profile state, protection result, safe guard activation and LAW/NPC owner responses. Outputs: confirmed civilian death/protected/alternate outcome, one guard activation/damage route, distinct retained incident facts, eligible owner racial/reward operation and optional feedback/recovery. Concrete APIs/signals remain unselected. Preview/contact acquisition cannot kill, spawn guards, award credit or set charges.

## Cross-system interactions

COMBAT-005 civilian central aim, COMBAT-009 actual projectile/source, COMBAT-010/011 result/ability predicates, COMBAT-012 settled feedback, COMBAT-014 spell delivery, COMBAT-017 nonplayer source/infighting and COMBAT-019 surrender. NPC civilian/guard representations/loadouts/death, LAW detection/crime/enforcement, FACT guild/reputation credit, QUEST actor protection/kill, CHAR/MAGIC racial/protection/effects, ITEM state ownership; CORE/SAVE scoped mutation/restore, AV feedback and DATA/MOD validated policies. No unreviewed LAW subsystem is finalized by this feature.

## Edge cases and failure conditions

Verify unarmed/player arrow versus ordinary mobile, ordinary contact outside reach/through obstruction, living combat actors/guards, already-dead actor and enemy-priority suppression of civilian cleave. No ordinary accuracy roll accidentally suppresses approved shortcut or adds practice.

Verify explicitly protected/essential profile versus merely quest-linked actor, prevention failure/error, benign/harmful magic, enemy/hazard-caused civilian death and original source disappeared. Only authoritative confirmed death can grant kill fact; no automatic player blame or forced murder from contact.

Verify guard activation with unavailable combat prefab/mappings, overlapping arrows, saved inventory/quest state, stale old representation, spawn retry and partially published conversion. Preserve one identity and hit; technical failure must not remove actor or produce extra guards/loot.

Verify LAW unavailable after committed death, duplicate incident delivery, racial/guild callback failure and missing blood/death assets. Required obligations survive without whole-contact replay; optional presentation failure does not change crime truth or authoritative actor state. Exact action/reaction order must be declared before implementation.

## Configuration and balancing options

Explicitly moddable civilian shortcut/source/target eligibility, alternate health/damage and protection/prevention profiles. Guard conversion/response and spell/nonplayer effect compatibility require supported NPC/MAGIC contracts. LAW owns legal exceptions/detection/enforcement and FACT/QUEST rewards; no new universal values are chosen. Exact definition schemas/provider precedence/protection ordering and native mapping validation remain dependencies.

## Save/load considerations

Persist committed civilian death/protection outcomes, guard identity/state conversion and required incident/reward completion through owners. Restore cannot re-kill a hidden/deactivated mobile, spawn duplicate guard, refill/reset inventory or rerun racial/guild credit. Saved world facts and actor IDs require validation/migration, not current-scene name matching.

Use coherent save boundary or retained stages for guard activation/pending physical resolution and actor death/pending LAW facts. COMBAT-001/015 cancel unfinished attack work while preserving committed consequences; COMBAT-009/014 persist already released projectiles and pending impacts. Their restore must not also replay a saved contact record as a fresh kill. Exact save admission/recovery across representation/LAW handoff remains SAVE/NPC integration; current authoritative death cannot be silently abandoned by cleanup.

## Technical constraints

Target Godot 4.7.2. Separate contact qualification, special civilian outcome, guard representation preparation, ordinary damage, legal fact delivery and optional feedback. Use stable actor/operation identity and explicit mutation receipts. No raw component-driven direct global crime/guard spawn or deactivate-before-safe-conversion architecture is mandated. Native actor/protection/guard/incident/save fixtures required. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Valid player melee/unarmed/arrow contact instant-kills ordinary eligible mobile civilians by default without ordinary accuracy/damage rolls; other actor/source categories are not silently included.
2. Modded alternate/protected profiles are supported; mere quest linkage grants no blanket protection, and only confirmed death emits kill fact.
3. Spells/hazards/nonplayer attacks follow explicit owner policies; benign contact is not lethal and responsible source is never automatically changed to player.
4. Civilian impact grants no default combat practice; existing release practice and explicit settled racial predicates remain correct and once-only.
5. Hostile player physical contact safely activates peaceful guard before normal resolution; miss/zero does not undo activation or duplicate guards/damage.
6. Guard identity/persistent state survives conversion; failure preserves actor/pending operation and does not delete/spawn repeatedly or grant duplicate loot.
7. Attempt/contact/injury/confirmed-kill facts report once to LAW with true attribution; combat does not directly force murder/guard waves/universal hostility.
8. Guild/quest/racial credit and enforcement use explicit owner outcomes, not unchecked source +5/spawn calls or contact-only kill assumptions.
9. Optional feedback, retries and native load cannot repeat death, conversion, damage, incidents or rewards; partial obligations use explicit recovery.

## Contradiction review

Reviewed against approved COMBAT-004/005/009–017 and relevant CHAR racial/health, MOVE targeting and LAW ownership established in prior features, plus source/catalog/architecture. No direct contradiction identified. Civilian contact-kill is the explicitly confirmed special route, not an accidental violation of ordinary physical accuracy. Guards remain ordinary combat resolution after identity-preserving activation. No civilian impact practice preserves prior approvals; arrow release practice stays independent. LAW facts do not mandate source unconditional guard spawning or classification. Modded civilian protection is explicit rather than invented for all quests. Broader architecture proposals remain Proposed.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: civilian classification/lethal/alternate profile schema; protection/prevention compatibility; guard state/identity mapping/publication; civilian death/removal/corpse content; LAW witness/jurisdiction/incident receipts; FACT/QUEST credit and racial operations; native save/partial-failure fixtures. These cannot silently replace default contact-kill with ordinary damage, blame player for unrelated death, grant unapproved combat practice or duplicate/remove guards on conversion failure. COMBAT-019 and detailed LAW/FACT/NPC reviews remain separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-018-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented civilian/protection schemas, guard identity mapping, legal/reward contracts and save/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
