# Initial dependency overview

Arrows show the direction of a data or control handoff in the cited path. Paths are relative to `Assets/Scripts/` unless otherwise stated. Each row describes a sampled relationship.

| System path | Observed connection and source |
| --- | --- |
| CORE → UI / CHAR / WORLD | `Game/Utility/StartGameBehaviour.cs` raises start events. `Game/StateManager.cs` subscribes to start-menu and start-game events. `Game/GameManager.cs` locates player and world components and scene parents. |
| DATA → WORLD / LOC | `DaggerfallUnity.SetupArena2Path` initializes access to classic content. `Utility/ContentReader.GetLocation` and `GetBlock` expose records used by terrain streaming and location assembly. See `Terrain/StreamingWorld.cs` and `Utility/RMBLayout.cs`, `Utility/RDBLayout.cs`. |
| MOVE → LOC / LAW | `Game/PlayerEnterExit.TransitionDungeonInterior` enters a location from door context. `Game/PlayerActivate.cs` includes lockpicking and pickpocketing paths that can call `PlayerEntity.SpawnCityGuards`. |
| COMBAT → RULE / CHAR / ITEM / LAW | `Game/WeaponManager.cs` and `Game/EnemyAttack.cs` call `FormulaHelper.CalculateAttackDamage` with attacker, target and weapon. The player path tallies weapon skill and can trigger guards for civilian attacks. |
| MAGIC → CHAR / COMBAT / MOVE | `Game/MagicAndEffects/EntityEffectManager.cs` handles ready spells and applies bundles. Concrete effects such as `Effects/Destruction/DamageHealth.cs` and `Effects/Thaumaturgy/Levitate.cs` bridge effects to other gameplay behavior. |
| ITEM → CHAR / MAGIC | `Game/Items/ItemEquipTable.EquipItem` resolves equip slots on an entity. The enchantment effects directory contains separate implementations for cast-when-held, cast-when-used and cast-when-strikes behavior. |
| FACT / DATA → QUEST → NPC / LOC / FACT | `QuestListsManager.GetGuildQuest` selects using faction/membership inputs. `QuestMachine.ParseQuest` and `Parser.Parse` consume authored scripts. `Place.cs` selects world markers. `Game/TalkManager.cs` includes quest dialogue context, and `GuildManager.QuestMachine_OnQuestEnded` consumes completion events. |
| UI → ECON / LAW / TIME | `Game/UserInterfaceWindows/` contains active trade, court, travel and rest flows. `DaggerfallCourtWindow.ReleaseFromPrison` is an example of world-changing logic in a window. `Game/Utility/TravelTimeCalculator.cs` provides trip-time and trip-cost operations. |
| SAVE → TIME / FACT / QUEST / NPC / WORLD / LOC / MOD | `Game/Serialization/SaveLoadManager.LoadGame` restores time, faction, quest, conversation and world variation data before restoring player position through `PlayerEnterExit.RestorePositionHelper`. The load path also restores registered object state and calls mod save interfaces. |
| MOD → DATA / MOVE / RULE / MAGIC | `Assets/Game/Addons/ModSupport/ModManager.cs` exposes ordered mod enumeration and asset lookup. `PlayerActivate.RegisterCustomActivation`, the override lookup in `FormulaHelper.CalculateAttackDamage`, and `EntityEffectBroker.RegisterEffectTemplate` illustrate distinct extension points. |

## Behavior that needs evidence beyond source

| Input | What inspection establishes | Evidence still needed |
| --- | --- | --- |
| Original ARENA2 data and classic saves | Reader structure and loading paths in `API/`, `API/Save/` and `Utility/ContentReader.cs`. | A representative data set to establish record values, map/marker placement, text, media and imported save behavior. |
| Packaged and optional content | `Assets/StreamingAssets/Tables/QuestList-DFU.txt`, `Tables/QuestList-Classic.txt` and `Factions/FACTION.TXT` are shipped inputs. Quest packs and world replacements have separate loading seams. | Inventory and sample the actual scripts, localization tables and enabled replacement/mod sets to establish effective content and precedence. |
| Unity assets and runtime | Scene, prefab, resource and Addressables roots exist. Gameplay code uses named/tagged objects, components and Unity physics. | Follow serialized references and overrides, then observe timing, collisions, trigger ordering and audiovisual output in the running game. |
| Packages and binaries | The manifest, embedded Post Processing source and plug-in files identify dependencies. Save code delegates serialization, and mods use Unity asset loading. | Verify package and binary behavior where it affects save compatibility, build targets, mod loading or presentation. |

**Inference for the later Godot analysis:** WORLD/LOC, QUEST and SAVE form the main integration cluster because quest resources occupy world markers and loading recreates context before restoring runtime objects. Treat scene reconstruction and content identity as shared investigation topics. Runtime traces are still needed to establish exact ordering and edge cases.
