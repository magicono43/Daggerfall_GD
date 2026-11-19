# NPC feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Source paths are relative to `Assets/Scripts/` and symbols follow `#`. Complexity estimates review scope. Confidence rates the sampled trace.

## NPC-001 — Outdoor civilian pool

- **Parent subsystem** — Population
- **Purpose** — Populate settlements near the player.
- **Existing implementation** — PopulationManager picks a free pool slot, samples a city nav-grid point, aligns the billboard to ground and schedules activation. Activation requires daytime and permits a custom generator. Distant, stuck or nighttime mobiles are scheduled for recycling.
- **Source** — `Game/Utility/PopulationManager.cs#SpawnAvailableMobile`, `Game/Utility/PopulationManager.cs#UpdateMobiles`, `Game/Utility/PopulationManager.cs#AllowMobileActivationChange`
- **Inputs and outputs** — Location, time, grid and pool → live or recycled civilian
- **Dependencies** — WORLD, TIME, MAGIC, MOD
- **Edge cases and interactions** — Racial override can suppress spawning. Render waits for at least one completed tile move.
- **Design questions** — When should civilians appear or despawn in view?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-10)

### My Intended Specification

[NPC-001 — Outdoor civilian pool](../../design/systems/NPC/NPC-001.md)

## NPC-002 — Civilian identity generation

- **Parent subsystem** — Population
- **Purpose** — Give a pooled mobile an identity for presentation and dialogue.
- **Existing implementation** — Population activation calls the custom generator or RandomiseNPC with a selected race. MobilePersonNPC holds the actor-side data, with name generation available through NameHelper.
- **Source** — `Game/Utility/PopulationManager.cs#UpdateMobiles`, `Game/MobilePersonNPC.cs#RandomiseNPC`, `Game/Utility/NameHelper.cs#FullName`
- **Inputs and outputs** — Population slot, race and generator → mobile identity
- **Dependencies** — DATA-017, MOD, AV
- **Edge cases and interactions** — Verify what identity survives recycling and how reused slots affect conversation identity.
- **Design questions** — Which civilians should retain a stable identity?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-002 — Civilian identity generation](../../design/systems/NPC/NPC-002.md)

## NPC-003 — Civilian navigation and idling

- **Parent subsystem** — Population
- **Purpose** — Move wandering actors through settlement space.
- **Existing implementation** — MobilePersonMotor tracks idle distance, seeks tiles, moves forward and tests whether a candidate direction is clear. It listens for floating-origin updates.
- **Source** — `Game/MobilePersonMotor.cs#SeekingTile`, `Game/MobilePersonMotor.cs#MovingForward`, `Game/MobilePersonMotor.cs#IsDirectionClear`, `Game/MobilePersonMotor.cs#FloatingOrigin_OnPositionUpdate`, `Game/Utility/CityNavigation.cs`
- **Inputs and outputs** — Nav position, surroundings and player distance → route and motor state
- **Dependencies** — WORLD, LOC, AV
- **Edge cases and interactions** — Verify grid edges, blocked paths and origin changes with actual settlements.
- **Design questions** — How should civilians recover from blocked routes?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-003 — Civilian navigation and idling](../../design/systems/NPC/NPC-003.md)

## NPC-004 — Placed NPCs and service identity

- **Parent subsystem** — Population
- **Purpose** — Turn location records into interactive actors.
- **Existing implementation** — StaticNPC accepts exterior, interior/dungeon and quest Person inputs. It resolves runtime faction information, exposes a position hash and can assign quest resource behavior.
- **Source** — `Game/StaticNPC.cs#SetLayoutData`, `Game/StaticNPC.cs#SetRuntimeData`, `Game/StaticNPC.cs#AssignQuestResourceBehaviour`, `Game/StaticNPC.cs#GetPositionHash`
- **Inputs and outputs** — Block record or quest person plus location/faction → actor identity and links
- **Dependencies** — DATA-005, LOC, FACT, QUEST, MOVE-023
- **Edge cases and interactions** — Check collisions, repeated layouts and provenance of faction IDs and portrait variants.
- **Design questions** — Which identity should a placed actor retain across world reconstruction?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-004 — Placed NPCs and service identity](../../design/systems/NPC/NPC-004.md)

## NPC-005 — Enemy archetype setup

- **Parent subsystem** — Encounters
- **Purpose** — Build combat-ready actors from definitions.
- **Existing implementation** — EnemyEntity has distinct career, starting equipment and spell assignment operations. EnemyMotor initializes hostility from mobile reaction settings.
- **Source** — `Game/Entities/EnemyEntity.cs#SetEnemyCareer`, `Game/Entities/EnemyEntity.cs#SetEnemyEquipment`, `Game/Entities/EnemyEntity.cs#SetEnemySpells`, `Game/EnemyMotor.cs#Start`, `Utility/EnemyBasics.cs`
- **Inputs and outputs** — Mobile definition, entity type and equipment variant → stats, gear, spells and initial reaction
- **Dependencies** — CHAR, ITEM, MAGIC, RULE-019, DATA
- **Edge cases and interactions** — Review class versus monster inputs, missing spell records and custom enemy mappings.
- **Design questions** — Which properties should be authored per archetype?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-005 — Enemy archetype setup](../../design/systems/NPC/NPC-005.md)

## NPC-006 — Ambient encounter selection

- **Parent subsystem** — Encounters
- **Purpose** — Choose when to request a roaming foe.
- **Existing implementation** — PlayerEntity has an intermittent spawn path. Shared roll helpers select a spawn signal by context and alert state, and RandomEncounters contains encounter tables.
- **Source** — `Game/Entities/PlayerEntity.cs#IntermittentEnemySpawn`, `Game/Formulas/FormulaHelper.cs#RollRandomSpawn_Dungeon`, `Utility/RandomEncounters.cs`
- **Inputs and outputs** — Time, context, alert and table data → potential encounter
- **Dependencies** — TIME, LOC, CORE-020, RULE-020
- **Edge cases and interactions** — Trace sampling interval, missed time and table selection per context.
- **Design questions** — Should encounter rate depend on time, distance or player activity?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-006 — Ambient encounter selection](../../design/systems/NPC/NPC-006.md)

## NPC-007 — Foe spawn placement and activation

- **Parent subsystem** — Encounters
- **Purpose** — Turn a spawn request into an active enemy.
- **Existing implementation** — FoeSpawner accepts foe objects, provides free placement with distance parameters and finalizes spawned objects. GameManager exposes enemy-spawn notification.
- **Source** — `Game/Utility/FoeSpawner.cs#SetFoeGameObjects`, `Game/Utility/FoeSpawner.cs#PlaceFoeFreely`, `Game/Utility/FoeSpawner.cs#FinalizeFoe`, `Game/GameManager.cs#RaiseOnEnemySpawnEvent`
- **Inputs and outputs** — Foe objects, geometry and parent → placed enemy and notification
- **Dependencies** — QUEST, WORLD, LOC, CORE-020
- **Edge cases and interactions** — Verify failed placement, visibility and quest marker versus free placement.
- **Design questions** — What should happen if no acceptable position is found?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-007 — Foe spawn placement and activation](../../design/systems/NPC/NPC-007.md)

## NPC-008 — Target acquisition and allegiance

- **Parent subsystem** — Senses
- **Purpose** — Choose an eligible actor to pursue.
- **Existing implementation** — EnemySenses has a GetTargets path with target visibility handling. EnemyMotor can become hostile to its attacker and restores a default team when leaving PlayerAlly in that path.
- **Source** — `Game/EnemySenses.cs#GetTargets`, `Game/EnemyMotor.cs#MakeEnemyHostileToAttacker`
- **Inputs and outputs** — Nearby actors, teams and attack events → target or hostility change
- **Dependencies** — COMBAT, QUEST, MAGIC
- **Edge cases and interactions** — Trace priority and infighting with multiple viable actors and quest-modified teams.
- **Design questions** — What should override a current target?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-008 — Target acquisition and allegiance](../../design/systems/NPC/NPC-008.md)

## NPC-009 — Sight, hearing and alternate detection

- **Parent subsystem** — Senses
- **Purpose** — Determine whether an enemy detects a target.
- **Existing implementation** — EnemySenses exposes visibility, hearing and alternate detection callbacks. Unblocked sight or hearing records target position and refreshes the recent-LOS timer.
- **Source** — `Game/EnemySenses.cs#FixedUpdate`, `Game/EnemySenses.cs#CanSeeTarget`, `Game/EnemySenses.cs#CanHearTarget`
- **Inputs and outputs** — Target, geometry and sense callbacks → detected state and position
- **Dependencies** — MOVE, LOC, COMBAT, MOD
- **Edge cases and interactions** — Confirm vision cones, masks and alternate detection against props and doors.
- **Design questions** — Which senses should update position precisely?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-009 — Sight, hearing and alternate detection](../../design/systems/NPC/NPC-009.md)

## NPC-010 — Stealth and illusion checks

- **Parent subsystem** — Senses
- **Purpose** — Let movement and magic obscure targets.
- **Existing implementation** — StealthCheck gates checks by game minute, can retain prior detection and tallies Stealth with a player timestamp. Illusion handling distinguishes enemies that see through invisibility, invisible targets and chance-based blending or shade.
- **Source** — `Game/EnemySenses.cs#StealthCheck`, `Game/EnemySenses.cs#BlockedByIllusionEffect`, `Game/Formulas/FormulaHelper.cs#CalculateStealthChance`
- **Inputs and outputs** — Skill, speed, time, distance and concealment → detection result
- **Dependencies** — RULE-011, MAGIC-025, MOVE, CHAR-012
- **Edge cases and interactions** — Slow movement skips odd-minute checks. Illusion checks repeat on classic updates. Verify interaction with alternate detection.
- **Design questions** — Which actions and senses should defeat each concealment type?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-010 — Stealth and illusion checks](../../design/systems/NPC/NPC-010.md)

## NPC-011 — Pursuit memory, prediction and alert

- **Parent subsystem** — Senses
- **Purpose** — Keep a useful pursuit destination after contact.
- **Existing implementation** — EnemySenses stores last known position, gives recent sight priority over a stealth-derived position and predicts movement when enhanced AI is enabled. A player in sight raises enemy alert.
- **Source** — `Game/EnemySenses.cs#FixedUpdate`, `Game/EnemySenses.cs#PredictNextTargetPos`, `Game/EnemyMotor.cs#GetDestination`, `Game/Entities/PlayerEntity.cs#SetEnemyAlert`
- **Inputs and outputs** — Detection history, movement and AI setting → destination and alert
- **Dependencies** — COMBAT, CORE-019, RULE-020, TIME
- **Edge cases and interactions** — Prediction uses consecutive sight samples. Trace give-up, rest interruption and alert decay independently.
- **Design questions** — How long should enemies search after losing a target?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-011 — Pursuit memory, prediction and alert](../../design/systems/NPC/NPC-011.md)

## NPC-012 — Language pacification

- **Parent subsystem** — Senses
- **Purpose** — Allow an eligible first encounter to become nonhostile.
- **Existing implementation** — On first player detection, nonquest enemies with an applicable language can run the pacification formula. Success clears hostility, shows feedback and tallies three uses. Some failed language checks tally one.
- **Source** — `Game/EnemySenses.cs#FixedUpdate`, `Game/Entities/EnemyEntity.cs#GetLanguageSkill`, `Game/Formulas/FormulaHelper.cs#CalculateEnemyPacification`
- **Inputs and outputs** — First detection, language and actor flags → hostility and practice
- **Dependencies** — RULE-019, CHAR-012, QUEST, UI
- **Edge cases and interactions** — Quest foes skip this branch. Etiquette and Streetwise are excluded from the failure tally. Comment identifies success tally as a DFU increase.
- **Design questions** — Should pacification be automatic and how can it end?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-012 — Language pacification](../../design/systems/NPC/NPC-012.md)

## NPC-013 — Pursuit, detours and hazards

- **Parent subsystem** — Enemy movement
- **Purpose** — Move toward an enemy destination around geometry.
- **Existing implementation** — EnemyMotor resolves destinations and movement, checks obstacles and drops, searches for detours, and has water, flight and gravity paths.
- **Source** — `Game/EnemyMotor.cs#GetDestination`, `Game/EnemyMotor.cs#AttemptMove`, `Game/EnemyMotor.cs#FindDetour`, `Game/EnemyMotor.cs#FallCheck`, `Game/EnemyMotor.cs#WaterMove`, `Game/EnemyMotor.cs#CanFly`
- **Inputs and outputs** — Target position, movement capabilities and geometry → movement or detour
- **Dependencies** — LOC, WORLD, COMBAT, MAGIC
- **Edge cases and interactions** — Trace narrow paths, ledges, blocked detours and vertical targets. Physics fixtures are needed.
- **Design questions** — Which movement constraints should differ by archetype?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-013 — Pursuit, detours and hazards](../../design/systems/NPC/NPC-013.md)

## NPC-014 — Door opening and bashing

- **Parent subsystem** — Enemy movement
- **Purpose** — Negotiate doors during pursuit.
- **Existing implementation** — EnemyMotor has separate opening and bashing logic. EnemyAttack resolves a bash attempt if the target hit check fails and the last known closed door is in melee range.
- **Source** — `Game/EnemyMotor.cs#OpenDoors`, `Game/EnemyMotor.cs#HandleBashing`, `Game/EnemyAttack.cs#MeleeDamage`
- **Inputs and outputs** — Door, enemy capability and pursuit state → opening or bash
- **Dependencies** — LOC, COMBAT-016, MOVE-021
- **Edge cases and interactions** — Verify locks, moving doors and actors that cannot open them.
- **Design questions** — When should enemies give up on a door?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-014 — Door opening and bashing](../../design/systems/NPC/NPC-014.md)

## NPC-015 — Melee positioning and movement interruption

- **Parent subsystem** — Enemy decisions
- **Purpose** — Choose movement near combat and respond to forced states.
- **Existing implementation** — EnemyMotor has strafe and move-in decisions, no-action and paralysis paths, and knockback handling separate from attack execution.
- **Source** — `Game/EnemyMotor.cs#StrafeDecision`, `Game/EnemyMotor.cs#EvaluateMoveInForAttack`, `Game/EnemyMotor.cs#HandleParalysis`, `Game/EnemyMotor.cs#KnockbackMovement`
- **Inputs and outputs** — Range, action state and hit impulse → positioning or interrupted movement
- **Dependencies** — COMBAT-012, COMBAT-015, MAGIC
- **Edge cases and interactions** — The knockback source has a collision-related TODO. Verify state priority when hit during an attack.
- **Design questions** — Which states should cancel versus suspend movement?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-015 — Melee positioning and movement interruption](../../design/systems/NPC/NPC-015.md)

## NPC-016 — Ranged attacks and spell selection

- **Parent subsystem** — Enemy decisions
- **Purpose** — Choose viable bow or spell actions.
- **Existing implementation** — EnemyMotor has bow, ranged spell and touch spell checks, projectile clearance and an active-effect comparison. Enhanced AI considers additional target modes in the sampled spell selection branch.
- **Source** — `Game/EnemyMotor.cs#CanShootBow`, `Game/EnemyMotor.cs#CanCastRangedSpell`, `Game/EnemyMotor.cs#CanCastTouchSpell`, `Game/EnemyMotor.cs#HasClearPathToShootProjectile`, `Game/EnemyMotor.cs#EffectsAlreadyOnTarget`
- **Inputs and outputs** — Target, range, shot space, magicka and spell data → attack choice
- **Dependencies** — MAGIC, COMBAT-017, LOC
- **Edge cases and interactions** — Source flags caster-only selection as TODO in enhanced AI. Check friendly obstruction and repeated effects.
- **Design questions** — Which self, touch and ranged effects should AI know how to use?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-016 — Ranged attacks and spell selection](../../design/systems/NPC/NPC-016.md)

## NPC-017 — Conversation entry and actor context

- **Parent subsystem** — Dialogue
- **Purpose** — Open a conversation with the correct actor state.
- **Existing implementation** — TalkManager has mobile and static entry points and distinct target setup overloads. Session setup resets successful-answer count and uses faction or building context for static actors.
- **Source** — `Game/TalkManager.cs#TalkToMobileNPC`, `Game/TalkManager.cs#TalkToStaticNPC`, `Game/TalkManager.cs#SetTargetNPC`, `Game/TalkManager.cs#StartNewConversation`
- **Inputs and outputs** — Actor and faction context → active conversation state
- **Dependencies** — MOVE-023, FACT, UI
- **Edge cases and interactions** — Verify repeated sessions with the same NPC and service/menu shortcuts.
- **Design questions** — What should carry over between conversations?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-017 — Conversation entry and actor context](../../design/systems/NPC/NPC-017.md)

## NPC-018 — Tone, reaction and greetings

- **Parent subsystem** — Dialogue
- **Purpose** — Resolve NPC disposition and opening text.
- **Existing implementation** — TalkManager resolves reaction and greeting records and uses talk tone for player greeting and follow-up. Quest greetings have a distinct path.
- **Source** — `Game/TalkManager.cs#GetReactionToPlayer`, `Game/TalkManager.cs#GetNPCGreetingRecord`, `Game/TalkManager.cs#GetNPCQuestGreeting`, `Game/TalkManager.cs#GetPCGreetingText`, `Game/TalkManager.cs#GetPCFollowUpText`
- **Inputs and outputs** — Faction, social group, reputation, tone and quest context → greeting and response stance
- **Dependencies** — FACT, DATA-015, QUEST, CHAR, UI
- **Edge cases and interactions** — Source notes DFU changes in reaction values and faction inheritance. Verify refusal thresholds and repeat refusal.
- **Design questions** — Which social skills and prior actions should affect reception?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-018 — Tone, reaction and greetings](../../design/systems/NPC/NPC-018.md)

## NPC-019 — Topic lists and NPC knowledge

- **Parent subsystem** — Dialogue
- **Purpose** — Build available questions and determine what an NPC knows.
- **Existing implementation** — TalkManager assembles Tell Me About, location, person and thing lists, and has topic knowledge and answer methods. It resets cached NPC knowledge through a dedicated operation.
- **Source** — `Game/TalkManager.cs#AssembleTopicLists`, `Game/TalkManager.cs#CheckNPCcanKnowAboutTellMeAboutTopic`, `Game/TalkManager.cs#ResetNPCKnowledge`, `Game/TalkManager.cs#GetAnswerTellMeAboutTopic`
- **Inputs and outputs** — NPC context, region and topics → list and answer availability
- **Dependencies** — DATA, FACT, QUEST, UI
- **Edge cases and interactions** — Source identifies Where Is Thing as unused. Check duplicate names and local versus regional topic visibility.
- **Design questions** — Should knowledge persist per actor, place or conversation?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-019 — Topic lists and NPC knowledge](../../design/systems/NPC/NPC-019.md)

## NPC-020 — Directions and map disclosure

- **Parent subsystem** — Dialogue
- **Purpose** — Give location guidance without always revealing exact position.
- **Existing implementation** — TalkManager provides compass direction, location answers and an explicit map-mark operation for the current subject. Regional buildings use separate lookup.
- **Source** — `Game/TalkManager.cs#GetAnswerWhereIs`, `Game/TalkManager.cs#GetAnswerWhereIsRegionalBuilding`, `Game/TalkManager.cs#GetBuildingCompassDirection`, `Game/TalkManager.cs#MarkKeySubjectLocationOnMap`
- **Inputs and outputs** — Subject, NPC and world location → hint or map mark
- **Dependencies** — WORLD, LOC, QUEST, DATA-016, UI
- **Edge cases and interactions** — Verify NPCs in the subject building, quest residences and missing location records.
- **Design questions** — When should a hint become an exact marker?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-020 — Directions and map disclosure](../../design/systems/NPC/NPC-020.md)

## NPC-021 — Rumor pool and bulletin-board output

- **Parent subsystem** — Dialogue
- **Purpose** — Select relevant news from world and quest inputs.
- **Existing implementation** — TalkManager filters rumor entries and performs weighted selection. It exposes separate conversation and bulletin-board output, classic rumor import and quest rumor add/remove operations.
- **Source** — `Game/TalkManager.cs#GetValidRumors`, `Game/TalkManager.cs#WeightedRandomRumor`, `Game/TalkManager.cs#GetNewsOrRumorsForBulletinBoard`, `Game/TalkManager.cs#ImportClassicRumor`, `Game/TalkManager.cs#RemoveQuestRumorsFromRumorMill`
- **Inputs and outputs** — Rumor records, region, faction and query context → eligible text
- **Dependencies** — QUEST, FACT, TIME, DATA-015, UI
- **Edge cases and interactions** — Check expiry, empty lists and differing board filters. Text and classic rumor values need fixtures.
- **Design questions** — How should rumors spread, expire and avoid repetition?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-021 — Rumor pool and bulletin-board output](../../design/systems/NPC/NPC-021.md)

## NPC-022 — Quest topics, links and post-quest responses

- **Parent subsystem** — Dialogue
- **Purpose** — Expose authored quest clues through conversation.
- **Existing implementation** — TalkManager adds quest topics with info and rumors, links resources, adds dialogue and removes quest-specific topics. It also tracks post-quest messages. Macro expansion belongs to DATA.
- **Source** — `Game/TalkManager.cs#AddQuestTopicWithInfoAndRumors`, `Game/TalkManager.cs#DialogLinkForQuestInfoResource`, `Game/TalkManager.cs#RemoveQuestInfoTopicsForSpecificQuest`, `Game/TalkManager.cs#AddQuestorPostQuestMessage`
- **Inputs and outputs** — Quest, resource and message data → visible topics and responses
- **Dependencies** — QUEST, DATA-016, MOVE-023, UI
- **Edge cases and interactions** — Check hidden links, duplicate resource names and cleanup when a quest ends.
- **Design questions** — Which events should expose or retire a clue?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-022 — Quest topics, links and post-quest responses](../../design/systems/NPC/NPC-022.md)

## NPC-023 — NPC quest-offer identity

- **Parent subsystem** — Dialogue
- **Purpose** — Assign or remember an actor who offers work.
- **Existing implementation** — TalkManager exposes random questor selection, separate castle and ordinary offer checks and removal by name seed.
- **Source** — `Game/TalkManager.cs#SetRandomQuestor`, `Game/TalkManager.cs#IsNpcOfferingQuest`, `Game/TalkManager.cs#IsCastleNpcOfferingQuest`, `Game/TalkManager.cs#RemoveNpcQuestor`
- **Inputs and outputs** — Location and actor identity → quest-offer eligibility
- **Dependencies** — QUEST, FACT, LOC
- **Edge cases and interactions** — Trace reselection, reuse of name seeds and interaction with recycled actors.
- **Design questions** — Should offers follow an actor, building or faction?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-023 — NPC quest-offer identity](../../design/systems/NPC/NPC-023.md)

## NPC-024 — Conversation and actor state restoration

- **Parent subsystem** — Persistence
- **Purpose** — Retain interaction state across saves and transitions.
- **Existing implementation** — TalkManager exports and restores conversation data and subscribes to world transition paths. Enemy state has a separate SerializableEnemy path. Population pooling and actor reconstruction use their own runtime mechanisms.
- **Source** — `Game/TalkManager.cs#GetConversationSaveData`, `Game/TalkManager.cs#RestoreConversationData`, `Game/TalkManager.cs#OnTransitionToExterior`, `Game/Serialization/SerializableEnemy.cs`
- **Inputs and outputs** — Saved dialogue and enemy records plus world context → restored runtime state
- **Dependencies** — SAVE, LOC, QUEST, NPC-001
- **Edge cases and interactions** — Inventory exact fields and ordering. Verify that restored quest clues resolve against the reconstructed actors.
- **Design questions** — Which knowledge and actor states should be durable?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 (2026-11-11)

### My Intended Specification

[NPC-024 — Conversation and actor state restoration](../../design/systems/NPC/NPC-024.md)

## Classic provenance and review sequence

- Source comments identify classic-derived dialogue tables and deliberate changes to reaction thresholds, faction inheritance and language practice. Enemy pursuit includes classic cadence and optional enhanced prediction. Original executable behavior, classic records and localized text need fixtures to establish fidelity.
- Start with a pooled civilian and a placed NPC. Follow both through interaction and identity lookup. Then test sight loss, illusion, pacification, ally retargeting and door traversal with a representative foe. Review rumors, map disclosure and quest links through save/reload.
- Scope separates population, detection, decisions and dialogue. COMBAT owns attack commitment and damage. QUEST owns quest execution and authored actions. LAW owns enforcement. Runtime physics, prefab bindings, mod callback order and classic text or world records remain unverified.
