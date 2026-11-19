# FACT feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Paths are relative to `Assets/Scripts/`. Symbols follow `#`. Complexity estimates review scope. Confidence rates the sampled source trace.

## FACT-001 — Faction identity and hierarchy

- **Parent subsystem** — Faction state
- **Purpose** — Resolve social and organizational records.
- **Existing implementation** — PersistentFactionData exposes ID, name, group and region lookups and parent-group resolution. Base records and custom definitions enter through the faction data layer.
- **Source** — `Game/Player/PersistentFactionData.cs#GetFactionData`, `Game/Player/PersistentFactionData.cs#FindFactions`, `Game/Player/PersistentFactionData.cs#GetParentGroupFaction`, `API/FactionFile.cs#RelinkChildren`
- **Inputs and outputs** — Faction key or filters → record or hierarchy
- **Dependencies** — DATA-009, NPC, MOD
- **Edge cases and interactions** — Check missing IDs, duplicate regional records and malformed parent links.
- **Design questions** — Which faction identifiers and parent relationships must remain stable?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-001 — Faction identity and hierarchy](../../design/systems/FACT/FACT-001.md)

## FACT-002 — Direct faction standing

- **Parent subsystem** — Reputation
- **Purpose** — Read and update player reputation with a faction.
- **Existing implementation** — GetReputation returns zero for missing IDs. SetReputation and direct ChangeReputation clamp stored values and return whether a known faction was updated.
- **Source** — `Game/Player/PersistentFactionData.cs#GetReputation`, `Game/Player/PersistentFactionData.cs#SetReputation`, `Game/Player/PersistentFactionData.cs#ChangeReputation`
- **Inputs and outputs** — Faction ID and new value or delta → standing and success
- **Dependencies** — QUEST, NPC, SAVE
- **Edge cases and interactions** — Unknown faction and neutral standing share the same numeric read result.
- **Design questions** — Should a missing faction be distinguishable from neutrality?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-002 — Direct faction standing](../../design/systems/FACT/FACT-002.md)

## FACT-003 — Propagated faction standing

- **Parent subsystem** — Reputation
- **Purpose** — Spread reputation changes through related factions.
- **Existing implementation** — Propagation applies half delta to ally slots and negative half to enemies, then follows the hierarchy. Root, initiating faction and questor IDs receive full delta in recursive propagation. Knightly orders, deity factions and Dark Brotherhood have special routing.
- **Source** — `Game/Player/PersistentFactionData.cs#ChangeReputation`, `Game/Player/PersistentFactionData.cs#PropagateReputationChange`
- **Inputs and outputs** — Initiator, signed delta and faction graph → standing changes across records
- **Dependencies** — QUEST-019, LAW, NPC
- **Edge cases and interactions** — Integer halves truncate. Check overlapping affiliations and invalid cycles. Generic knightly-order child propagation is a documented DFU divergence.
- **Design questions** — Which relationships should spread reputation, and how should overlap combine?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-003 — Propagated faction standing](../../design/systems/FACT/FACT-003.md)

## FACT-004 — Reputation normalization and legal boundary

- **Parent subsystem** — Reputation
- **Purpose** — Evolve reputation over elapsed time.
- **Existing implementation** — PlayerEntity calls NormalizeReputations from its time update. The method clamps legal reputations and applies one-point changes to eligible faction entries toward zero.
- **Source** — `Game/Entities/PlayerEntity.cs#Update`, `Game/Entities/PlayerEntity.cs#NormalizeReputations`, `Game/Entities/PlayerEntity.cs#ClampLegalReputations`
- **Inputs and outputs** — Time and current standing → normalized values
- **Dependencies** — TIME, LAW, SAVE
- **Edge cases and interactions** — Audit eligible faction types and catch-up after long elapsed intervals. Regional legal penalties remain LAW scope.
- **Design questions** — Which standings should decay, and toward what baseline?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-004 — Reputation normalization and legal boundary](../../design/systems/FACT/FACT-004.md)

## FACT-005 — Social reactions and quest reputation inputs

- **Parent subsystem** — Reputation
- **Purpose** — Feed faction state into interaction outcomes.
- **Existing implementation** — PlayerEntity exposes social-group reaction modifiers. TalkManager resolves reaction from faction context. Quest actions can explicitly change or test reputation, and guild offer selection reads reputation or rank.
- **Source** — `Game/Entities/PlayerEntity.cs#ChangeReactionMod`, `Game/Entities/PlayerEntity.cs#GetReactionMod`, `Game/TalkManager.cs#GetReactionToPlayer`, `Game/Questing/Actions/ChangeReputeWith.cs`, `Game/Questing/Actions/WhenReputeWith.cs`
- **Inputs and outputs** — Social group, faction standing and quest context → reaction or eligibility
- **Dependencies** — NPC-018, QUEST-002, QUEST-019, CHAR-005
- **Edge cases and interactions** — Social modifiers and faction reputation have distinct entry points. Trace combined effects of biography and enchantments.
- **Design questions** — Which reputation values should dialogue and offers share?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-005 — Social reactions and quest reputation inputs](../../design/systems/FACT/FACT-005.md)

## FACT-006 — Alliances, rivalries and war relationships

- **Parent subsystem** — Faction simulation
- **Purpose** — Maintain faction-to-faction relations.
- **Existing implementation** — PersistentFactionData exposes ally/enemy start and end, relation queries and war-specific eligibility or permanence checks. Region simulation consumes these relationships.
- **Source** — `Game/Player/PersistentFactionData.cs#StartFactionAllies`, `Game/Player/PersistentFactionData.cs#EndFactionAllies`, `Game/Player/PersistentFactionData.cs#StartFactionEnemies`, `Game/Player/PersistentFactionData.cs#EndFactionEnemies`, `Game/Player/PersistentFactionData.cs#IsEnemyStatePermanentUntilWarOver`
- **Inputs and outputs** — Faction IDs and relation slots → changed relations or query result
- **Dependencies** — TIME, WORLD, NPC, SAVE
- **Edge cases and interactions** — Test directional links, slot exhaustion and war-end cleanup separately from player standing.
- **Design questions** — Should alliances and rivalries always be reciprocal?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-006 — Alliances, rivalries, and war relationships](../../design/systems/FACT/FACT-006.md)

## FACT-007 — Political power, rulers and war outcomes

- **Parent subsystem** — Faction simulation
- **Purpose** — Evolve faction power and leadership.
- **Existing implementation** — RegionPowerAndConditionsUpdate uses faction power and relationships in simulation branches, including war losses. PersistentFactionData supports power changes and replacement ruler data.
- **Source** — `Game/Entities/PlayerEntity.cs#RegionPowerAndConditionsUpdate`, `Game/Player/PersistentFactionData.cs#ChangePower`, `Game/Player/PersistentFactionData.cs#SetNewRulerData`
- **Inputs and outputs** — Faction power, rulers, region records and RNG → updated political state
- **Dependencies** — TIME, NPC-021, RULE, SAVE
- **Edge cases and interactions** — Large simulation with several thresholds. Verify extreme power, elapsed-time order and ruler rumor generation with fixtures.
- **Design questions** — Which political changes should be visible or affect quests?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-007 — Political power, rulers, and war outcomes](../../design/systems/FACT/FACT-007.md)

## FACT-008 — Regional conditions and market handoff

- **Parent subsystem** — Faction simulation
- **Purpose** — Connect political simulation to world state.
- **Existing implementation** — PlayerEntity initializes regional data and calls power/condition updates. Branches alter regional conditions and faction power. FormulaHelper separately uses regional and merchant faction power for price evolution.
- **Source** — `Game/Entities/PlayerEntity.cs#InitializeRegionData`, `Game/Entities/PlayerEntity.cs#RegionPowerAndConditionsUpdate`, `Game/Entities/PlayerEntity.cs#TurnOnConditionFlag`, `Game/Entities/PlayerEntity.cs#TurnOffConditionFlag`, `Game/Formulas/FormulaHelper.cs#UpdateRegionalPrices`
- **Inputs and outputs** — Regional flags, faction state and elapsed time → conditions and market inputs
- **Dependencies** — TIME, WORLD, RULE-022, ECON, NPC-021
- **Edge cases and interactions** — Trace war, public conditions and price flags independently. Determine which changes are simulation versus quest-driven.
- **Design questions** — Which regional conditions should influence gameplay services and rumors?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-008 — Regional conditions and market handoff](../../design/systems/FACT/FACT-008.md)

## FACT-009 — Guild group and variant resolution

- **Parent subsystem** — Membership
- **Purpose** — Select the matching guild or nonmember context.
- **Existing implementation** — GuildManager maps guild groups to implementations, with temple deity and knightly order variants keyed by building faction. It exposes joined-guild lookup and custom guild registration.
- **Source** — `Game/Guilds/GuildManager.cs#CreateGuildObj`, `Game/Guilds/GuildManager.cs#GetGuild`, `Game/Guilds/GuildManager.cs#RegisterCustomGuild`, `Game/Guilds/NonMemberGuild.cs`
- **Inputs and outputs** — Guild group, building faction and registrations → guild context
- **Dependencies** — LOC, NPC, MOD, ECON
- **Edge cases and interactions** — Verify variant mismatch and custom constructor requirements.
- **Design questions** — Should multiple memberships within a group be allowed?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-009 — Guild group and variant resolution](../../design/systems/FACT/FACT-009.md)

## FACT-010 — Joining and leaving

- **Parent subsystem** — Membership
- **Purpose** — Determine and record ordinary membership.
- **Existing implementation** — Base eligibility checks rank-zero reputation and permanent guild skills, requiring at least one high skill and at least two qualifying skills. Base Join sets rank zero and records the current day. GuildManager maintains membership entries.
- **Source** — `Game/Guilds/Guild.cs#IsEligibleToJoin`, `Game/Guilds/Guild.cs#Join`, `Game/Guilds/GuildManager.cs#AddMembership`, `Game/Guilds/GuildManager.cs#RemoveMembership`
- **Inputs and outputs** — Standing, skills and accepted request → membership state
- **Dependencies** — CHAR-011, UI, NPC
- **Edge cases and interactions** — Distinguish eligibility checking from direct membership calls. Verify guild-specific overrides and repeated joins.
- **Design questions** — Which requirements are universal and which may vary by guild?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-010 — Joining and leaving](../../design/systems/FACT/FACT-010.md)

## FACT-011 — Promotion, demotion and expulsion

- **Parent subsystem** — Membership
- **Purpose** — Reassess guild rank over time.
- **Existing implementation** — UpdateRank allows reassessment at least 28 days after the last rank change. It computes qualifying rank from reputation and permanent skills, emits rank messages and removes expelled members. Negative reputation yields rank minus one in base calculation.
- **Source** — `Game/Guilds/Guild.cs#UpdateRank`, `Game/Guilds/Guild.cs#CalculateNewRank`, `Game/Guilds/Guild.cs#CalculateNumHighLowSkills`, `Game/Guilds/Guild.cs#ImportLastRankChange`
- **Inputs and outputs** — Guild thresholds, skills, reputation and calendar → new rank and feedback
- **Dependencies** — TIME, CHAR, UI, SAVE
- **Edge cases and interactions** — No change leaves the timestamp intact. Verify call timing and overrides for guilds with additional quest requirements.
- **Design questions** — Should rank changes occur on visit, automatically or after a decision?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-011 — Promotion, demotion, and expulsion](../../design/systems/FACT/FACT-011.md)

## FACT-012 — Crime-guild recruitment

- **Parent subsystem** — Membership
- **Purpose** — Use illicit actions and initiation quests to join secret guilds.
- **Existing implementation** — PlayerEntity tallies crime-guild requirements and handles starting recruitment quests. GuildManager observes successful initiation quest completion and adds Thieves Guild or Dark Brotherhood membership.
- **Source** — `Game/Entities/PlayerEntity.cs#TallyCrimeGuildRequirements`, `Game/Entities/PlayerEntity.cs#HandleStartingCrimeGuildQuests`, `Game/Guilds/GuildManager.cs#QuestMachine_OnQuestEnded`, `Game/Guilds/ThievesGuild.cs#Join`, `Game/Guilds/DarkBrotherhood.cs#Join`
- **Inputs and outputs** — Crime tally, recruitment timing and quest success → initiation or membership
- **Dependencies** — LAW, QUEST, TIME, SAVE
- **Edge cases and interactions** — Trace delayed letters, failed initiation and repeated completion notifications. Actual quest scripts supply outcomes.
- **Design questions** — Which actions and signals should begin recruitment?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-012 — Crime-guild recruitment](../../design/systems/FACT/FACT-012.md)

## FACT-013 — Guild quest access and progression requirements

- **Parent subsystem** — Membership
- **Purpose** — Connect membership and rank to work.
- **Existing implementation** — Guild-specific classes expose level-related quest requirement checks. QuestListsManager filters guild offers using membership and rank or reputation. GuildManager maps groups for nonmember quest context.
- **Source** — `Game/Guilds/Guild.cs#IsSatisfyQuestReqByLevel`, `Game/Guilds/MagesGuild.cs#IsSatisfyQuestReqByLevel`, `Game/Guilds/KnightlyOrder.cs#IsSatisfyQuestReqByLevel`, `Game/Guilds/GuildManager.cs#GetGuildFactionId`, `Game/Questing/QuestListsManager.cs#GetGuildQuestPool`
- **Inputs and outputs** — Guild group, rank, membership and offer data → quest access inputs
- **Dependencies** — QUEST-002, CHAR, NPC
- **Edge cases and interactions** — Temple and order variants use different faction IDs. Trace service window enforcement versus pool filters.
- **Design questions** — Should work access depend on rank, level, completed quests or standing?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-013 — Guild quest access and progression requirements](../../design/systems/FACT/FACT-013.md)

## FACT-014 — Service routing and rank gates

- **Parent subsystem** — Services
- **Purpose** — Resolve what a guild representative offers.
- **Existing implementation** — Services maps NPC service identifiers and supports custom registrations. Guild.CanAccessService and overrides in MagesGuild, Temple and crime guilds provide eligibility checks.
- **Source** — `Game/Guilds/Services.cs#GetService`, `Game/Guilds/Services.cs#RegisterGuildService`, `Game/Guilds/Guild.cs#CanAccessService`, `Game/Guilds/MagesGuild.cs#CanAccessService`, `Game/Guilds/Temple.cs#CanAccessService`
- **Inputs and outputs** — NPC service, guild variant and rank → route and eligibility
- **Dependencies** — ECON, NPC, MOD, UI
- **Edge cases and interactions** — Compare nonmember, wrong deity and custom callback paths. Actual transactions belong to ECON.
- **Design questions** — Which services should be visible before the player qualifies?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-014 — Service routing and rank gates](../../design/systems/FACT/FACT-014.md)

## FACT-015 — Hall access, training and member pricing

- **Parent subsystem** — Services
- **Purpose** — Apply everyday membership benefits.
- **Existing implementation** — Guild exposes hall access, rest, training and discount hooks. FightersGuild overrides hall/rest, reward and repair behavior. MagesGuild exposes magicka recharge and library benefits.
- **Source** — `Game/Guilds/Guild.cs#GetTrainingMax`, `Game/Guilds/Guild.cs#GetTrainingPrice`, `Game/Guilds/FightersGuild.cs#CanRest`, `Game/Guilds/FightersGuild.cs#AlterReward`, `Game/Guilds/FightersGuild.cs#ReducedRepairCost`, `Game/Guilds/MagesGuild.cs#FreeMagickaRecharge`
- **Inputs and outputs** — Membership and service context → access, limit or adjusted cost/reward
- **Dependencies** — CHAR-016, ECON, TIME, MOVE-020
- **Edge cases and interactions** — Audit rank thresholds and whether benefits require being at a specific hall.
- **Design questions** — Which privileges should apply outside the guild hall?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-015 — Hall access, training, and member pricing](../../design/systems/FACT/FACT-015.md)

## FACT-016 — Temple deity benefits and blessings

- **Parent subsystem** — Services
- **Purpose** — Apply deity-specific membership privileges.
- **Existing implementation** — Temple maps faction IDs to divines, provides deity-specific rank data and training lists, and implements blessing, healing and cure discounts. GuildManager exposes cross-guild travel, breath and avoid-death queries.
- **Source** — `Game/Guilds/Temple.cs#GetDivine`, `Game/Guilds/Temple.cs#Blessing`, `Game/Guilds/Temple.cs#FreeHealing`, `Game/Guilds/Temple.cs#AvoidDeath`, `Game/Guilds/GuildManager.cs#DeepBreath`, `Game/Guilds/GuildManager.cs#AvoidDeath`
- **Inputs and outputs** — Deity, rank, donation and activity → blessing or conditional benefit
- **Dependencies** — MAGIC, CHAR-023, TIME, ECON, RULE
- **Edge cases and interactions** — Compare each deity and how manager queries combine memberships. Death handling remains CHAR.
- **Design questions** — Should deity benefits stack or be mutually exclusive?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-016 — Temple deity benefits and blessings](../../design/systems/FACT/FACT-016.md)

## FACT-017 — Knightly order rewards

- **Parent subsystem** — Services
- **Purpose** — Grant order-specific rewards and travel benefits.
- **Existing implementation** — KnightlyOrder maps faction to order and exposes armor and house rewards, plus free tavern and ship travel checks.
- **Source** — `Game/Guilds/KnightlyOrder.cs#GetOrder`, `Game/Guilds/KnightlyOrder.cs#ReceiveArmor`, `Game/Guilds/KnightlyOrder.cs#ReceiveHouse`, `Game/Guilds/KnightlyOrder.cs#FreeTavernRooms`, `Game/Guilds/KnightlyOrder.cs#FreeShipTravel`
- **Inputs and outputs** — Order, rank and player state → reward or travel benefit
- **Dependencies** — ITEM, ECON, TIME, SAVE
- **Edge cases and interactions** — Trace one-time collection, unavailable houses and order variants.
- **Design questions** — Which rewards should be claims versus automatic grants?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-017 — Knightly order rewards](../../design/systems/FACT/FACT-017.md)

## FACT-018 — Faction and membership restoration

- **Parent subsystem** — Persistence
- **Purpose** — Preserve standing, membership and rank context.
- **Existing implementation** — PersistentFactionData imports classic reputation and loads custom factions. GuildManager saves, restores and imports membership records with a vampire-state option. Guild converts classic rank-change minutes to days.
- **Source** — `Game/Player/PersistentFactionData.cs#ImportClassicReputation`, `Game/Player/PersistentFactionData.cs#AddCustomFactions`, `Game/Guilds/GuildManager.cs#GetMembershipData`, `Game/Guilds/GuildManager.cs#RestoreMembershipData`, `Game/Guilds/GuildManager.cs#ImportMembershipData`, `Game/Guilds/Guild.cs#ImportLastRankChange`
- **Inputs and outputs** — Native or classic records and current definitions → restored faction and guild state
- **Dependencies** — SAVE, CORE-014, MAGIC-028, MOD
- **Edge cases and interactions** — Verify missing mod IDs, pre/post-vampirism memberships and rank timestamp conversion.
- **Design questions** — What should happen if a saved membership cannot be resolved?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13).

### My Intended Specification

[FACT-018 — Faction and membership restoration](../../design/systems/FACT/FACT-018.md)

## Classic provenance and next review steps

- Compare the packaged faction graph with classic records before attributing identities and relationships to the original game. The reputation source describes propagation as classic-matched and explicitly notes DFU propagation to generic knightly-order children. Classic rank-change time uses minutes and is converted to days on import.
- Start with direct and propagated reputation fixtures covering allies, enemies, temples and knightly orders. Then trace ordinary membership, the 28-day rank gate, secret-guild initiation and deity/service variant resolution. Check political state, faction rumors and market effects across a time jump and reload.
- Scope separates player standing, faction diplomacy, political simulation, membership and benefits. QUEST owns script execution, ECON owns transactions, LAW owns criminal penalties, and NPC owns dialogue presentation. Full per-guild thresholds, simulation branch outcomes, classic content and runtime ordering remain open.
