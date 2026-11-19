# Master systems catalog

IDs are stable top-level reference keys. The subsystem lists define the current scope under each key. Source anchors are relative to `Assets/Scripts/` unless they start with `Assets/` or `Packages/`. An extensionless source anchor denotes a C# file, with a trailing slash for directories. A dot after the filename identifies a member.

Dependencies include data inputs, services and important runtime collaborators. Mutual dependencies are expected in this overview. Complexity estimates reflect the depth of a later analysis. High confidence means the system and its main boundaries are clear from the inspected code. Medium means the owner or behavior is distributed, or the evidence sampled covers fewer paths. These ratings apply to discovery coverage.

## CORE — Runtime coordination

Bootstraps and coordinates gameplay scenes and shared services.

Detailed decomposition covers 21 features in the [CORE feature catalog](systems/CORE_FEATURE_CATALOG.md).

- **Subsystems** — Bootstrap and persistent paths, configuration, session entry and new-character initialization, play gating, shared gameplay coordination.
- **Source anchors** — `DaggerfallUnityApplication`, `Game/GameManager`, `Game/StateManager`, `Game/Utility/StartGameBehaviour`, `SettingsManager`.
- **Dependencies** — DATA, UI, SAVE, WORLD.
- **Analysis complexity** — High. **Coverage confidence** — High.

## DATA — Content and localization

Resolves classic records and packaged resources into runtime definitions.

Detailed decomposition covers 24 features in the [DATA feature catalog](systems/DATA_FEATURE_CATALOG.md).

- **Subsystems** — Source selection and precedence, world and gameplay definitions, localization and text, media conversion and caches.
- **Source anchors** — `DaggerfallUnity.SetupArena2Path`, `Utility/ContentReader.GetLocation`, `API/MapsFile`, `API/BlocksFile`, `API/Arch3dFile`, `Game/TextManager`, `Localization/DaggerfallStringTableImporter`.
- **Dependencies** — CORE, MOD.
- **Analysis complexity** — High. **Coverage confidence** — High.

## CHAR — Character and progression

Owns player identity, capabilities and long-term advancement.

Detailed decomposition covers 23 features in the [CHAR feature catalog](systems/CHAR_FEATURE_CATALOG.md).

- **Subsystems** — Race/class/biography and allocation, attributes and skills, use tallies and leveling, vitals, recovery and death.
- **Source anchors** — `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard (StartNewGameWizard)`, `Game/Player/CharacterDocument`, `Game/Entities/PlayerEntity.TallySkill`, `Game/Entities/DaggerfallEntity`, `Game/Entities/DaggerfallStats`, `Game/Entities/DaggerfallSkills`, `Game/PlayerDeath`.
- **Dependencies** — DATA, RULE, ITEM, MAGIC, TIME, UI.
- **Analysis complexity** — High. **Coverage confidence** — High.

## RULE — Shared formulas and randomness

Centralizes calculations and exposes formula overrides.

Detailed decomposition covers 28 features in the [RULE feature catalog](systems/RULE_FEATURE_CATALOG.md).

- **Subsystems** — Random sources and override registration, character and interaction math, combat and magic math, encounter rolls, economy and item math, regional lookups.
- **Source anchors** — `Game/Formulas/FormulaHelper.CalculateAttackDamage`, `Game/Utility/Dice100`, `API/DFRandom`.
- **Dependencies** — CHAR, ITEM, MOD.
- **Analysis complexity** — High. **Coverage confidence** — High.

## MOVE — Player movement and interaction

Translates player controls into locomotion and world actions.

Detailed decomposition covers 27 features in the [MOVE feature catalog](systems/MOVE_FEATURE_CATALOG.md).

- **Subsystems** — Input bindings, look and collision, ground/air/water movement, climbing/rappelling/levitation, activation, doors and locks, pickpocketing.
- **Source anchors** — `Game/InputManager`, `Game/PlayerMotor`, `Game/Player/ClimbingMotor`, `Game/Player/RappelMotor`, `Game/LevitateMotor`, `Game/PlayerActivate.RegisterCustomActivation`, `Game/PlayerEnterExit`.
- **Dependencies** — WORLD, LOC, CHAR, MAGIC, LAW, NPC, QUEST, UI.
- **Analysis complexity** — High. **Coverage confidence** — High.

## COMBAT — Combat and damage

Resolves physical attacks and routes damage and death.

Detailed decomposition covers 21 features in the [COMBAT feature catalog](systems/COMBAT_FEATURE_CATALOG.md).

- **Subsystems** — First-person weapon handling, melee/ranged attacks, defense and hit/damage calculation, enemy attack, death/loot handoff.
- **Source anchors** — `Game/WeaponManager`, `Game/FPSWeapon`, `Game/EnemyAttack`, `Game/EnemyDeath`, `Game/DaggerfallMissile`, `Game/Formulas/FormulaHelper.CalculateAttackDamage`.
- **Dependencies** — CHAR, ITEM, RULE, MAGIC, NPC, LAW, AV.
- **Analysis complexity** — High. **Coverage confidence** — High.

## MAGIC — Magic and effects

Defines, casts and tracks spells and other active or passive effects.

Detailed decomposition covers 30 features in the [MAGIC feature catalog](systems/MAGIC_FEATURE_CATALOG.md).

- **Subsystems** — Effect templates/bundles, spell targeting and cost, spellmaking, potions and enchantments, diseases/poisons, transformations, magical movement.
- **Source anchors** — `Game/MagicAndEffects/EntityEffectBroker.RegisterEffectTemplate`, `Game/MagicAndEffects/EntityEffectManager.AssignBundle`, `Game/MagicAndEffects/Effects/`, `Game/FPSSpellCasting`, `Utility/DaggerfallSpellReader`.
- **Dependencies** — CHAR, RULE, DATA, ITEM, MOVE, COMBAT, TIME, UI.
- **Analysis complexity** — High. **Coverage confidence** — High.

## ITEM — Items and equipment

Builds items and tracks ownership, placement and equipment.

Detailed decomposition covers 25 features in the [ITEM feature catalog](systems/ITEM_FEATURE_CATALOG.md).

- **Subsystems** — Templates and construction, stackable collections, equipment conflicts, condition and repair, loot and containers.
- **Source anchors** — `Game/Items/DaggerfallUnityItem`, `Game/Items/ItemBuilder`, `Game/Items/ItemCollection`, `Game/Items/ItemEquipTable.EquipItem`, `Game/Items/LootTables`, `Internal/DaggerfallLoot`.
- **Dependencies** — DATA, CHAR, MAGIC, RULE, LOC.
- **Analysis complexity** — High. **Coverage confidence** — High.

## NPC — Population, AI and dialogue

Represents civilians and enemies and supplies interaction and conversation.

Detailed decomposition covers 24 features in the [NPC feature catalog](systems/NPC_FEATURE_CATALOG.md).

- **Subsystems** — Civilian population pooling, static service/quest NPCs, sensing and movement, conversation topics and rumors, enemy spawning and encounters.
- **Source anchors** — `Game/Utility/PopulationManager`, `Game/MobilePersonMotor`, `Game/StaticNPC`, `Game/EnemySenses`, `Game/EnemyMotor`, `Game/TalkManager`, `Game/Utility/FoeSpawner`, `Utility/RandomEncounters`.
- **Dependencies** — WORLD, LOC, COMBAT, QUEST, FACT, DATA, UI.
- **Analysis complexity** — High. **Coverage confidence** — Medium.

## QUEST — Quest execution and selection

Selects authored quests and instantiates script-defined objectives and resources.

Detailed decomposition covers 23 features in the [QUEST feature catalog](systems/QUEST_FEATURE_CATALOG.md).

- **Subsystems** — Quest lists and packs, parser, task/action execution, timers, randomized site and marker selection, dialogue hooks and journal.
- **Source anchors** — `Game/Questing/QuestListsManager.GetGuildQuest`, `Game/Questing/QuestMachine.ParseQuest`, `Game/Questing/QuestMachine.Tick`, `Game/Questing/Parser.Parse`, `Game/Questing/Place`, `Game/Questing/Actions/`.
- **Dependencies** — DATA, TIME, LOC, NPC, FACT, ITEM, MAGIC, LAW, UI.
- **Analysis complexity** — High. **Coverage confidence** — High.

## FACT — Factions, guilds and reputation

Tracks faction relationships and guild participation.

Detailed decomposition covers 18 features in the [FACT feature catalog](systems/FACT_FEATURE_CATALOG.md).

- **Subsystems** — Faction identity and diplomacy, reputation propagation, regional politics, guild membership and rank, service benefits and restoration.
- **Source anchors** — `API/FactionFile`, `Game/Player/PersistentFactionData.GetReputation`, `Game/Guilds/IGuild`, `Game/Guilds/GuildManager.QuestMachine_OnQuestEnded`, `Game/Questing/Actions/ChangeReputeWith`.
- **Dependencies** — DATA, CHAR, QUEST, ECON, SAVE.
- **Analysis complexity** — High. **Coverage confidence** — High.

## LAW — Crime and legal response

Tracks regional legal standing and applies enforcement and court consequences.

Detailed decomposition covers 16 features in the [LAW feature catalog](systems/LAW_FEATURE_CATALOG.md).

- **Subsystems** — Crime triggers, guard spawning, court and prison, legal reputation and quest hooks.
- **Source anchors** — `Game/PlayerActivate`, `Game/WeaponManager`, `Game/Entities/PlayerEntity.SpawnCityGuards`, `Game/Entities/PlayerEntity.ClampLegalReputations`, `Game/UserInterfaceWindows/DaggerfallCourtWindow.ReleaseFromPrison`, `Game/Questing/Actions/LegalRepute`.
- **Dependencies** — CHAR, NPC, LOC, TIME, UI, QUEST, SAVE.
- **Analysis complexity** — High. **Coverage confidence** — Medium.

## ECON — Economy and services

Handles transactions and service eligibility.

Detailed decomposition covers 19 features in the [ECON feature catalog](systems/ECON_FEATURE_CATALOG.md).

- **Subsystems** — Trade, merchant stock and repair, banking and loans, houses and ships, inns and guild services.
- **Source anchors** — `Game/UserInterfaceWindows/DaggerfallTradeWindow`, `Game/DaggerfallBankManager.GetHousePrice`, `Game/LoanChecker`, `Game/Guilds/Services`, `Game/UserInterfaceWindows/DaggerfallTavernWindow`, `Game/UserInterfaceWindows/DaggerfallMerchantRepairPopupWindow`.
- **Dependencies** — ITEM, CHAR, RULE, LOC, FACT, TIME, SAVE.
- **Analysis complexity** — High. **Coverage confidence** — Medium.

## WORLD — Overworld streaming and exploration

Builds and streams the exterior around map coordinates.

Detailed decomposition covers 18 features in the [WORLD feature catalog](systems/WORLD_FEATURE_CATALOG.md).

- **Subsystems** — Terrain sampling/texturing/nature, floating origin, geographic lookup/discovery, exterior map.
- **Source anchors** — `Terrain/StreamingWorld.TeleportToCoordinates`, `Terrain/DefaultTerrainSampler`, `Terrain/TerrainTexturing`, `Terrain/TerrainNature`, `Utility/FloatingOrigin`, `Internal/PlayerGPS`, `Game/ExteriorAutomap`.
- **Dependencies** — DATA, LOC, MOVE, TIME, AV, SAVE.
- **Analysis complexity** — High. **Coverage confidence** — High.

## LOC — Locations, interiors and dungeons

Assembles record-defined sites and handles transitions and fixtures.

Detailed decomposition covers 20 features in the [LOC feature catalog](systems/LOC_FEATURE_CATALOG.md).

- **Subsystems** — Exterior and dungeon blocks, interiors, doors/actions, markers/loot, building lookup and dungeon automap.
- **Source anchors** — `Internal/DaggerfallLocation`, `Internal/DaggerfallInterior`, `Internal/DaggerfallDungeon`, `Utility/RMBLayout`, `Utility/RDBLayout`, `Internal/DaggerfallAction`, `Game/PlayerEnterExit.TransitionDungeonInterior`, `Game/Automap`.
- **Dependencies** — DATA, WORLD, MOVE, NPC, ITEM, QUEST, SAVE.
- **Analysis complexity** — High. **Coverage confidence** — High.

## TIME — Time, environment and travel

Advances the calendar and drives environmental and journey state.

Detailed decomposition covers 18 features in the [TIME feature catalog](systems/TIME_FEATURE_CATALOG.md).

- **Subsystems** — Calendar events, weather/climate, sunlight and city lights, resting, travel cost/time, mount and ship transport.
- **Source anchors** — `Internal/WorldTime.OnNewDayEventHandler`, `Utility/DaggerfallDateTime`, `Game/WeatherManager`, `Game/SunlightManager`, `Game/Utility/TravelTimeCalculator.CalculateTravelTime`, `Game/UserInterfaceWindows/DaggerfallRestWindow`, `Game/TransportManager`.
- **Dependencies** — WORLD, LOC, CHAR, ECON, QUEST, MAGIC, AV.
- **Analysis complexity** — High. **Coverage confidence** — High.

## UI — Interface and player-facing flows

Presents state and routes window-level commands.

Detailed decomposition covers 21 features in the [UI feature catalog](systems/UI_FEATURE_CATALOG.md).

- **Subsystems** — Window stack/messages, HUD and vitals, creation/inventory/spellbook, maps and journal, setup and controls.
- **Source anchors** — `Game/DaggerfallUI`, `Game/UserInterface/UserInterfaceManager.PushWindow`, `Game/UserInterface/UserInterfaceManager.PostMessage`, `Game/UserInterfaceWindows/UIWindowFactory`, `Game/UserInterfaceWindows/DaggerfallHUD`.
- **Dependencies** — CORE, DATA, MOVE and feature owners.
- **Analysis complexity** — High. **Coverage confidence** — High.

## AV — Rendering, audio and presentation

Presents world and gameplay feedback through Unity assets and runtime media.

Detailed decomposition covers 13 features in the [AV feature catalog](systems/AV_FEATURE_CATALOG.md).

- **Subsystems** — Meshes/materials/billboards, sky/fog/lighting, music and ambient sound, MIDI synthesis, retro rendering.
- **Source anchors** — `MeshReader`, `MaterialReader`, `Internal/DaggerfallBillboardBatch`, `Internal/DaggerfallSky`, `Internal/DaggerfallSongPlayer`, `Game/SongManager`, `AudioSynthesis/`, `Utility/RetroRenderer`.
- **Dependencies** — DATA, WORLD, LOC, TIME, MOD.
- **Analysis complexity** — High. **Coverage confidence** — Medium.

## SAVE — Saving, loading and persistence

Captures runtime state and restores player and world context.

Detailed decomposition covers 18 features in the [SAVE feature catalog](systems/SAVE_FEATURE_CATALOG.md).

- **Subsystems** — Serializable object registration, versioned data records, state restoration and quicksave/load, classic save import, mod state.
- **Source anchors** — `Game/Serialization/SaveLoadManager.RegisterSerializableGameObject`, `Game/Serialization/SaveLoadManager.LoadGame`, `Game/Serialization/SerializableGameObject (ISerializableGameObject)`, `Game/Serialization/SerializablePlayer`, `API/Save/SaveGames`, `Game/Utility/StartGameBehaviour`.
- **Dependencies** — CORE, CHAR, WORLD, LOC, ITEM, MAGIC, QUEST, NPC, FACT, LAW, ECON, TIME, MOD.
- **Analysis complexity** — High. **Coverage confidence** — High.

## MOD — Modding and extensibility

Loads optional content and exposes feature registration and replacement seams.

Detailed decomposition covers 16 features in the [MOD feature catalog](systems/MOD_FEATURE_CATALOG.md).

- **Subsystems** — Mod discovery/order and asset lookup, asset injection, custom activation/effects/formulas/guilds, mod save hooks.
- **Source anchors** — `Assets/Game/Addons/ModSupport/ModManager.TryGetAsset`, `Utility/AssetInjection/WorldDataReplacement`, `Utility/AssetInjection/WorldDataVariants`, `Game/PlayerActivate.RegisterCustomActivation`, `Game/Guilds/GuildManager.RegisterCustomGuild`.
- **Dependencies** — CORE, DATA, SAVE, Unity asset and scripting facilities.
- **Analysis complexity** — High. **Coverage confidence** — Medium.

## DEV — Diagnostics, authoring and tests

Supports runtime diagnosis, content inspection and editor tooling.

Detailed decomposition covers 14 features in the [DEV feature catalog](systems/DEV_FEATURE_CATALOG.md).

- **Subsystems** — Console and diagnostic logs, quest debugger and demos, save/content inspectors and world editors, package test infrastructure.
- **Source anchors** — `Assets/Game/Addons/UnityConsole/Console/Scripts/ConsoleCommandsDatabase`, `GenerateDiagLog`, `Game/UserInterface/HUDQuestDebugger`, `Editor/SaveExplorerWindow`, `Game/SetupDemoEnemy`, `Packages/com.unity.postprocessing/Tests/`.
- **Dependencies** — CORE, DATA, QUEST, SAVE, Unity Editor/test framework.
- **Analysis complexity** — Medium. **Coverage confidence** — Medium.

