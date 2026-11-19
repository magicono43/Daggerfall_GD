# COMBAT feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Paths are relative to `Assets/Scripts/` and symbols follow `#`. Complexity estimates review scope. Confidence rates the static trace.

## COMBAT-001 — Readying and attack interruptions

- **Parent subsystem** — Player weapon control
- **Purpose** — Control weapon availability.
- **Existing implementation** — WeaponManager refreshes hands and blocks processing during bow cooldown, paralysis or climbing. Ready spells and casting animations interact with weapon visibility. Ready Weapon can abort a ready spell.
- **Source** — `Game/WeaponManager.cs#Update`, `Game/WeaponManager.cs#ToggleSheath`, `Game/WeaponManager.cs#SheathWeapons`
- **Inputs and outputs** — Input, cooldown, movement and spell state → readiness and visibility
- **Dependencies** — MOVE, MAGIC, ITEM, UI
- **Edge cases and interactions** — Check ordering when the spell and weapon inputs overlap or an attack is already active.
- **Design questions** — When should drawing a weapon cancel a spell?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-001 specification](../../design/systems/COMBAT/COMBAT-001.md), finalized v1 under COMBAT-001-A01. No implementation is authorized.

## COMBAT-002 — Equipped hand and attack presentation

- **Parent subsystem** — Player weapon control
- **Purpose** — Choose the active hand and matching weapon presentation.
- **Existing implementation** — UpdateHands tracks equipped items. ToggleHand and ApplyWeapon select the weapon presentation, with separate unarmed and item setup paths.
- **Source** — `Game/WeaponManager.cs#UpdateHands`, `Game/WeaponManager.cs#ToggleHand`, `Game/WeaponManager.cs#ApplyWeapon`, `Game/WeaponManager.cs#SetMelee`
- **Inputs and outputs** — Equipped items and hand selection → active attack item and sprite state
- **Dependencies** — ITEM, AV, CHAR
- **Edge cases and interactions** — Verify shields, two-handed items and equipment changes mid-animation.
- **Design questions** — Which equipment changes should interrupt a swing?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-002 specification](../../design/systems/COMBAT/COMBAT-002.md), finalized v1 under COMBAT-002-A01. No implementation is authorized.

## COMBAT-003 — Attack gesture and click input

- **Parent subsystem** — Player weapon control
- **Purpose** — Translate attack input into a swing direction.
- **Existing implementation** — WeaponManager tracks gestures for non-bow attacks and selects a random attack direction for click attacks. FPSWeapon maps attack direction to weapon state.
- **Source** — `Game/WeaponManager.cs#Update`, `Game/WeaponManager.cs#ExecuteAttacks`, `Game/FPSWeapon.cs#OnAttackDirection`
- **Inputs and outputs** — Mouse/controller input or click → attack direction and animation
- **Dependencies** — MOVE, RULE, AV
- **Edge cases and interactions** — Check threshold behavior, analog reset and direction availability per weapon.
- **Design questions** — Which directions should players control explicitly?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-003 specification](../../design/systems/COMBAT/COMBAT-003.md), finalized v1 under COMBAT-003-A01. No implementation is authorized.

## COMBAT-004 — Attack frames, fatigue and practice

- **Parent subsystem** — Player weapon control
- **Purpose** — Commit an attack at its animation hit frame.
- **Existing implementation** — WeaponManager uses the sprite hit frame and an isDamageFinished guard. At that point it dispatches melee or bow and deducts fatigue. Enemy contact and bow paths can tally weapon and Critical Strike practice.
- **Source** — `Game/WeaponManager.cs#Update`, `Game/FPSWeapon.cs#GetHitFrame`, `Game/FPSWeapon.cs#GetCurrentFrame`
- **Inputs and outputs** — Animation state, active item and hit result → attack, fatigue cost and usage tallies
- **Dependencies** — CHAR-012, CHAR-020, AV
- **Edge cases and interactions** — Enemy-contact return value can be true even when formula damage is zero. Verify timing under dropped frames.
- **Design questions** — Should practice and fatigue depend on attack commitment, contact or damage?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-004 specification](../../design/systems/COMBAT/COMBAT-004.md), finalized v1 under COMBAT-004-A01, including default cleave, once-per-swing fatigue and per-enemy contact practice. Cleave geometry/order remains COMBAT-005 scope. No implementation is authorized.

## COMBAT-005 — Player reach and collision

Design dependency from approved COMBAT-004: default moddable cleaving, independent per-target resolution and per-enemy contact practice with once-per-swing fatigue. Approved COMBAT-005 defines the intended targeting contract below without changing the single-contact DFU evidence.

- **Parent subsystem** — Melee
- **Purpose** — Choose a melee contact in front of the player.
- **Existing implementation** — MeleeDamage spherecasts from the camera using weapon reach and player mask. It tries environment damage first and can fall back to a ray after a handled environment hit. Enemy handling then receives the selected transform.
- **Source** — `Game/WeaponManager.cs#MeleeDamage`, `Game/WeaponManager.cs#WeaponEnvDamage`
- **Inputs and outputs** — View, weapon reach and physics layers → environmental or actor hit
- **Dependencies** — MOVE, LOC, ITEM
- **Edge cases and interactions** — No simple ray is attempted when the spherecast misses. Narrow gaps and collider hierarchies need scene fixtures.
- **Design questions** — How forgiving should reach and narrow openings be?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-005 specification](../../design/systems/COMBAT/COMBAT-005.md), finalized v1 under COMBAT-005-A01, including forward-volume cleave, per-target obstruction, nearest-first order, enemy-first dispatch and optional modded wall-stop sweeps. No implementation is authorized.

## COMBAT-006 — Environmental strikes and door bashing

- **Parent subsystem** — Melee
- **Purpose** — Let attacks affect authored geometry.
- **Existing implementation** — An action component can receive an Attack trigger. An action door attempts bash, followed by a separate exterior-door bash path for other hits. Static geometry can play an impact sound.
- **Source** — `Game/WeaponManager.cs#WeaponEnvDamage`, `Game/PlayerActivate.cs#AttemptExteriorDoorBash`, `Internal/DaggerfallAction.cs`
- **Inputs and outputs** — Ray hit and striking item → action, bash or impact feedback
- **Dependencies** — MOVE-020, MOVE-021, LOC, AV, LAW
- **Edge cases and interactions** — Attack action can run before bash on the same object. Source explicitly identifies wall sounds as a DFU addition.
- **Design questions** — Which objects should react to strikes and how should overlap resolve?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-006 specification](../../design/systems/COMBAT/COMBAT-006.md), finalized v1 under COMBAT-006-A01, including deliberate bash/action composition, persistent unlocks, separate exterior entry and authoritative noise/legal reporting. No implementation is authorized.

## COMBAT-007 — Bow draw, release and cooldown

- **Parent subsystem** — Ranged
- **Purpose** — Control when a bow attack fires.
- **Existing implementation** — Optional BowDrawback holds the bow at frame 3. Releasing SwingWeapon advances the release path. Center activation or hold timeout returns to idle. When bow animation ends, the manager sets a cooldown using FormulaHelper.
- **Source** — `Game/WeaponManager.cs#Update`, `Game/Formulas/FormulaHelper.cs#GetBowCooldownTime`, `Game/FPSWeapon.cs#ChangeWeaponState`
- **Inputs and outputs** — Draw setting, input, animation and player stats → release, cancel or cooldown
- **Dependencies** — RULE-015, MOVE, AV
- **Edge cases and interactions** — Check behavior on equipment changes, long holds and canceled draws.
- **Design questions** — Should cancellation, release and recovery have distinct timing?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-007 specification](../../design/systems/COMBAT/COMBAT-007.md), finalized v1 under COMBAT-007-A01, including press-to-fire default, optional holding/early release, explicit cancellation/timeout and captured post-animation cooldown. No implementation is authorized.

## COMBAT-008 — Arrow use and recovery

- **Parent subsystem** — Ranged
- **Purpose** — Consume ammo and track recoverable shots.
- **Existing implementation** — At the hit frame the player creates an arrow missile, chooses ammo with summoned priority and quest items disallowed, removes one and records summoned status. Actor hit handling inserts a recoverable arrow for nonsummoned shots on enemies.
- **Source** — `Game/WeaponManager.cs#Update`, `Game/WeaponManager.cs#WeaponDamage`, `Game/EnemyAttack.cs#BowDamage`
- **Inputs and outputs** — Arrow stack and shot/impact context → ammo removal and possible target inventory item
- **Dependencies** — ITEM, MAGIC, NPC
- **Edge cases and interactions** — Recoverable ammo insertion follows contact even if damage is zero. Verify inventory changes between draw and release.
- **Design questions** — Which arrows should be recoverable and when?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-008 specification](../../design/systems/COMBAT/COMBAT-008.md), finalized v1 under COMBAT-008-A01, including custom ammunition preservation, contact-based recovery and optional multishot conservation/practice policies. No implementation is authorized.

## COMBAT-009 — Arrow collision and attack attribution

- **Parent subsystem** — Ranged
- **Purpose** — Route projectile contact to the damage owner.
- **Existing implementation** — The missile registers entity contact, uses trigger-based arrow dispatch and destroys its arrow model on impact. Player damage uses WeaponManager.LastBowUsed at impact. Enemy bow dispatch requires contact with the caster's current sensed target.
- **Source** — `Game/DaggerfallMissile.cs#DoCollision`, `Game/DaggerfallMissile.cs#AssignBowDamageToTarget`, `Game/EnemyAttack.cs#BowDamage`
- **Inputs and outputs** — Caster, arrow flags, collision and current target/bow → damage dispatch or no actor damage
- **Dependencies** — ITEM, NPC, MAGIC, AV
- **Edge cases and interactions** — Check in-flight bow swaps, overlapping projectiles, target changes and blockers. The player dispatch reads manager state shared across shots.
- **Design questions** — Which attack inputs should be captured at launch versus impact?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-009 specification](../../design/systems/COMBAT/COMBAT-009.md), finalized v1 under COMBAT-009-A01, including captured offense/source, current defender resolution, actual-contact targeting, swept collision and same-location projectile persistence. No implementation is authorized.

## COMBAT-010 — Attack eligibility and physical roll

- **Parent subsystem** — Damage resolution
- **Purpose** — Resolve baseline physical damage before applying it.
- **Existing implementation** — WeaponManager and EnemyAttack call the shared damage formula. Weapon material, attack route, hit chance, body part and modifiers are covered by RULE-012 through RULE-014.
- **Source** — `Game/WeaponManager.cs#WeaponDamage`, `Game/EnemyAttack.cs#ApplyDamageToPlayer`, `Game/EnemyAttack.cs#ApplyDamageToNonPlayer`, `Game/Formulas/FormulaHelper.cs#CalculateAttackDamage`
- **Inputs and outputs** — Attacker, defender, weapon and circumstances → damage and formula-side effects
- **Dependencies** — RULE-012, RULE-013, RULE-014, ITEM, CHAR
- **Edge cases and interactions** — Zero damage can represent several outcomes. Enemy route choice differs from classic per the source comment.
- **Design questions** — Should the damage result distinguish misses, ineffective material and zero damage?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-010 specification](../../design/systems/COMBAT/COMBAT-010.md), finalized v1 under COMBAT-010-A01, including structured outcomes, independent per-target resolution, sequential component phases and explicit death/prevention/technical-failure handling. No implementation is authorized.

## COMBAT-011 — On-hit side effects and strike enchantments

- **Parent subsystem** — Damage resolution
- **Purpose** — Apply secondary effects in damage order.
- **Existing implementation** — The physical formula can damage equipment, consume poison and invoke monster or item effects. Player weapon strike enchantments run before DecreaseHealth and can change damage. Weapon strike events and racial callbacks provide additional extension paths.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateAttackDamage`, `Game/Formulas/FormulaHelper.cs#DamageEquipment`, `Game/WeaponManager.cs#WeaponDamage`, `Game/MagicAndEffects/EntityEffectManager.cs#DoItemEnchantmentPayloads`
- **Inputs and outputs** — Contact, item, rolled damage and effects → wear, status, final damage and notifications
- **Dependencies** — RULE-016, ITEM, MAGIC, CHAR-019
- **Edge cases and interactions** — Presentation can use pre-enchantment damage. Check event order for misses, lethal damage and reentrant effects.
- **Design questions** — Which effects require contact, positive physical damage or actual health loss?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-011 specification](../../design/systems/COMBAT/COMBAT-011.md), finalized v1 under COMBAT-011-A01, including positive-physical strike eligibility, explicit phase/basis ordering, captured projectile continuity and bounded reactive defaults. No implementation is authorized.

## COMBAT-012 — Hit feedback and knockback

- **Parent subsystem** — Damage resolution
- **Purpose** — Communicate combat outcomes and displace targets.
- **Existing implementation** — Player WeaponDamage selects hit or parry/miss feedback, blood and optional voices. Enemy knockback uses damage, target weight and direction. This happens before strike enchantment can modify damage.
- **Source** — `Game/WeaponManager.cs#WeaponDamage`, `Game/EnemyBlood.cs`, `Game/EnemySounds.cs`, `Game/EnemyMotor.cs`
- **Inputs and outputs** — Contact, baseline damage and target traits → feedback and movement response
- **Dependencies** — AV, NPC, MOVE, RULE-019
- **Edge cases and interactions** — Check knockback branch precedence for class enemies versus weighted monsters. Assets and motion require runtime fixtures.
- **Design questions** — Should feedback represent baseline or final damage?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented native tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-012 specification](../../design/systems/COMBAT/COMBAT-012.md), finalized v1 under COMBAT-012-A01, including settled-intake injury feedback, delivered-physical knockback, bounded impulse combination and persistent movement. No implementation is authorized.

## COMBAT-013 — Player damage intake and death handoff

- **Parent subsystem** — Damage resolution
- **Purpose** — Deliver damage to the player's vital state.
- **Existing implementation** — EnemyAttack sends RemoveHealth to the player and selects weapon/weaponless hit messages. PlayerHealth has a damage receiver, while fall damage is a separate input. CHAR owns lethal handling and death flow.
- **Source** — `Game/EnemyAttack.cs#SendDamageToPlayer`, `Game/PlayerHealth.cs#RemoveHealth`, `Game/PlayerHealth.cs#ApplyPlayerFallDamage`, `Game/Entities/PlayerEntity.cs#SetHealth`
- **Inputs and outputs** — Enemy attack damage or separate hazard input → player health and feedback
- **Dependencies** — CHAR-018, CHAR-023, MOVE-010, AV
- **Edge cases and interactions** — Trace message receivers in the active prefab. Guard and damage feedback paths may diverge.
- **Design questions** — Which damage sources need identical intake and reporting?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-013 specification](../../design/systems/COMBAT/COMBAT-013.md), finalized v1 under COMBAT-013-A01, including shared single-pass intake, ordered prevention/death settlement, actual-loss injury feedback and optional player pain voices off by default. No implementation is authorized.

## COMBAT-014 — Magical contact and payload delivery

- **Parent subsystem** — Damage resolution
- **Purpose** — Hand spell contact to the effect system.
- **Existing implementation** — DaggerfallMissile supports touch, ranged and area targeting. Collision can add entity targets and trigger an area query. Payload assignment is distinct from arrow damage.
- **Source** — `Game/DaggerfallMissile.cs#GetEntityTargetInTouchRange`, `Game/DaggerfallMissile.cs#DoAreaOfEffect`, `Game/DaggerfallMissile.cs#AssignPayloadToTargets`
- **Inputs and outputs** — Cast target type, geometry and effect payload → target delivery
- **Dependencies** — MAGIC, MOVE-018, RULE-017, AV
- **Edge cases and interactions** — Check caster exclusion, line of sight and projectile collisions per targeting mode in MAGIC.
- **Design questions** — Which blockers and targets should spells respect?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-014 specification](../../design/systems/COMBAT/COMBAT-014.md), finalized v1 under COMBAT-014-A01, including multi-target area delivery deduplicated per actor, obstruction/eligibility policies, payload capture, modded lingering areas and native delivery persistence. No implementation is authorized.

## COMBAT-015 — Enemy attack cadence and animation commitment

- **Parent subsystem** — Enemy attacks
- **Purpose** — Choose when an enemy can begin and resolve attacks.
- **Existing implementation** — FixedUpdate checks disabled AI, paralysis and blocking one-shots, counts down the melee timer and gates attempts on ClassicUpdate, speed and a random test. Update consumes damage or shoot flags from animation.
- **Source** — `Game/EnemyAttack.cs#FixedUpdate`, `Game/EnemyAttack.cs#Update`, `Game/EnemyAttack.cs#ResetMeleeTimer`, `Game/EnemyAttack.cs#MeleeAnimation`
- **Inputs and outputs** — AI, speed, timer and animation flags → attempted or committed attack
- **Dependencies** — NPC, CORE-017, MAGIC, AV
- **Edge cases and interactions** — Speed floors at eight. Source says the speed comparison is reversed from classic. Update's guard differs from the initiation guard.
- **Design questions** — Which states should cancel a committed enemy attack?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-015 specification](../../design/systems/COMBAT/COMBAT-015.md), finalized v1 under COMBAT-015-A01, including explicit lifecycle, retained target/timing, melee cadence, restriction clocks and load cancellation with retained interval. No implementation is authorized.

## COMBAT-016 — Enemy melee reach, facing and door bashing

- **Parent subsystem** — Enemy attacks
- **Purpose** — Determine what an enemy swing connects with.
- **Existing implementation** — Melee damage checks sight and either very close distance or melee range plus yaw. A nonplayer target resistant to the equipped material can trigger fallback to unarmed. When the target check fails, an eligible enemy may bash its last known closed door.
- **Source** — `Game/EnemyAttack.cs#MeleeDamage`, `Game/EnemyAttack.cs#ApplyDamageToPlayer`, `Game/EnemyAttack.cs#ApplyDamageToNonPlayer`
- **Inputs and outputs** — Target, sight, distance, facing and door state → hit attempt, bash or miss
- **Dependencies** — NPC, LOC, RULE-012, ITEM
- **Edge cases and interactions** — Code comments describe classic-style melee detection. Confirm exact geometry, retargeting and threshold behavior.
- **Design questions** — What should make a swing miss after it starts?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-016 specification](../../design/systems/COMBAT/COMBAT-016.md), finalized v1 under COMBAT-016-A01, including commitment-time geometry, single-target body blocking, explicit capability-driven door intent and shared melee cadence. No implementation is authorized.

## COMBAT-017 — Enemy ranged and infighting delivery

- **Parent subsystem** — Enemy attacks
- **Purpose** — Route enemy damage by target type.
- **Existing implementation** — ShootBow handles the animation shoot flag. BowDamage and melee route to player or nonplayer damage paths. Nonplayer delivery calls DecreaseHealth on the target entity.
- **Source** — `Game/EnemyAttack.cs#ShootBow`, `Game/EnemyAttack.cs#BowDamage`, `Game/EnemyAttack.cs#ApplyDamageToNonPlayer`, `Game/DaggerfallMissile.cs#AssignBowDamageToTarget`
- **Inputs and outputs** — Attack mode and sensed target → projectile or actor damage
- **Dependencies** — NPC, CHAR, ITEM, COMBAT-009
- **Edge cases and interactions** — Target allegiance and target acquisition belong to NPC. Check retargets and projectiles hitting bystanders.
- **Design questions** — Should enemy shots affect any actor they physically hit?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-017 specification](../../design/systems/COMBAT/COMBAT-017.md), finalized v1 under COMBAT-017-A01, including finite moddable enemy supply, ranged admission/cadence, retained release intent and shared actual-recipient resolution. No implementation is authorized.

## COMBAT-018 — Civilian hits and guard escalation

- **Parent subsystem** — Combat consequences
- **Purpose** — Translate attacks on mobile people into legal consequences.
- **Existing implementation** — WeaponDamage handles non-guard mobile NPCs as murder, deactivates the civilian and spawns guards. The guard branch sets assault, spawns a guard enemy and routes subsequent processing through its components.
- **Source** — `Game/WeaponManager.cs#WeaponDamage`, `Game/Entities/PlayerEntity.cs#SpawnCityGuards`, `Game/Entities/PlayerEntity.cs#SpawnCityGuard`
- **Inputs and outputs** — Civilian or guard contact → actor state change, crime and enforcement
- **Dependencies** — LAW, NPC, FACT, MAGIC
- **Edge cases and interactions** — Verify guard spawn failure, ranged hits and mod NPC component assumptions.
- **Design questions** — Should civil consequences depend on contact, damage or witnesses?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-018 specification](../../design/systems/COMBAT/COMBAT-018.md), finalized v1 under COMBAT-018-A01, retaining moddable civilian contact-kill, identity-preserving guard activation and owner-governed incident classification/enforcement. No implementation is authorized.

## COMBAT-019 — Guard surrender during combat

- **Parent subsystem** — Combat consequences
- **Purpose** — Expose surrender as a combat-to-court handoff.
- **Existing implementation** — EnemyAttack contains a surrender dialogue callback. PlayerEntity implements SurrenderToCityGuards and the court entry path.
- **Source** — `Game/EnemyAttack.cs#SurrenderToGuardsDialogue_OnButtonClick`, `Game/Entities/PlayerEntity.cs#SurrenderToCityGuards`, `Game/Entities/PlayerEntity.cs#CourtWindow`
- **Inputs and outputs** — Guard attack context and response → surrender or continued combat
- **Dependencies** — LAW, UI, NPC
- **Edge cases and interactions** — Check prompt eligibility, refusal and whether damage is deferred. Sentencing belongs to LAW.
- **Design questions** — When should surrender be offered during an attack?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-019 specification](../../design/systems/COMBAT/COMBAT-019.md), finalized v1 under COMBAT-019-A01, including LAW-authorized owned prompt, retained deferred hit, episode suppression, forced surrender and success-only arrest health. No implementation is authorized.

## COMBAT-020 — Enemy death and quest synchronization

- **Parent subsystem** — Combat consequences
- **Purpose** — Finalize an enemy death when dependent quest processing allows it.
- **Existing implementation** — The death event sets a pending flag. CompleteDeath waits for a quest foe to report dead, deactivates the enemy for persistence, optionally shows a death message, clears alert when relevant and emits OnEnemyDeath.
- **Source** — `Game/EnemyDeath.cs#EnemyEntity_OnDeath`, `Game/EnemyDeath.cs#CompleteDeath`, `Game/Questing/Components/QuestResourceBehaviour.cs`
- **Inputs and outputs** — Death event, quest state and settings → finalized death and event
- **Dependencies** — QUEST, SAVE, NPC, UI
- **Edge cases and interactions** — Quest ownership can defer finalization. Other active enemies can raise alert again.
- **Design questions** — Which systems must acknowledge death before cleanup?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-020 specification](../../design/systems/COMBAT/COMBAT-020.md), finalized v1 under COMBAT-020-A01, including immediate death, explicit quest synchronization, separate readiness, bounded recovery and coherent pending-death saves. No implementation is authorized.

## COMBAT-021 — Corpse creation and item transfer

- **Parent subsystem** — Combat consequences
- **Purpose** — Create a persistent lootable result of enemy death.
- **Existing implementation** — CompleteDeath chooses corpse art including a female override, creates a corpse marker with UID, tags quest ownership, unequips worn slots and transfers entity items to the corpse collection.
- **Source** — `Game/EnemyDeath.cs#CompleteDeath`, `Utility/GameObjectHelper.cs#CreateLootableCorpseMarker`, `Internal/DaggerfallLoot.cs`
- **Inputs and outputs** — Enemy definition, equipment and inventory → corpse marker and loot
- **Dependencies** — ITEM, LOC, QUEST, SAVE, AV, COMBAT-020
- **Edge cases and interactions** — Verify saved dead entities, quest rewards and interaction with normal loot generation. Loot selection and pickup belong to ITEM and MOVE.
- **Design questions** — Which equipment and quest items should be recoverable?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved COMBAT-021 specification](../../design/systems/COMBAT/COMBAT-021.md), finalized v1 under COMBAT-021-A01, including preserved item ownership/contents, once-only corpse transfer, bounded placement, cosmetic fallback and explicit persistence/cleanup. No implementation is authorized.

## Classic provenance and review sequence

- Source comments identify classic-style enemy melee geometry and the classic update cadence, alongside explicit DFU differences in enemy speed comparison, natural attack selection and wall-hit sounds. Classic visual/audio data, enemy definitions and weapon data need representative fixtures. Source comments establish intent and do not verify parity.
- Review one player melee strike and one bow release first, including cancellation, zero damage and ammo return. Then trace enemy attack commitment, guard surrender, strike effects and quest-bound death. Check weapon or target changes during projectile flight and verify damage ordering before reviewing feedback.
- Scope separates input, hit geometry, damage math, mutation and death cleanup. RULE owns formula details. CHAR owns player death and vitals. NPC owns target acquisition and allegiance. Unity animation assets, physics masks, prefab bindings, classic fixture values and runtime ordering remain unverified.
