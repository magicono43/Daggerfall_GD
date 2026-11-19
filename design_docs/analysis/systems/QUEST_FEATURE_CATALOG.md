# QUEST feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Paths are relative to `Assets/Scripts/Game/Questing/`. Symbols follow `#`. Complexity estimates review scope. Confidence rates the sampled source trace.

## QUEST-001 — Quest lists and packs

- **Parent subsystem** — Selection
- **Purpose** — Discover authored quest offers.
- **Existing implementation** — QuestListsManager discovers pack lists, loads quest tables and parses list rows. Direct script and table lookups are separate DATA paths.
- **Source** — `QuestListsManager.cs#DiscoverQuestPackLists`, `QuestListsManager.cs#LoadQuestLists`, `QuestListsManager.cs#ParseQuestList`
- **Inputs and outputs** — Pack paths and tables → indexed quest definitions
- **Dependencies** — DATA-012, MOD
- **Edge cases and interactions** — Verify duplicate rows, file precedence and editor reload behavior.
- **Design questions** — How should packs replace or extend lists?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-11)

### My Intended Specification

[QUEST-001 — Quest lists and packs](../../design/systems/QUEST/QUEST-001.md)

## QUEST-002 — Guild offer eligibility

- **Parent subsystem** — Selection
- **Purpose** — Filter available guild work.
- **Existing implementation** — Guild pools filter membership, rank or reputation and accepted one-time quests. Holy Order has a dual-membership adjustment. Adult entries are gated by PlayerNudity.
- **Source** — `QuestListsManager.cs#GetGuildQuestPool`, `QuestListsManager.cs#GetGuildQuest`
- **Inputs and outputs** — Guild, membership, rank and reputation → eligible pool
- **Dependencies** — FACT, NPC, UI
- **Edge cases and interactions** — Requirement values below 10 use rank in the sampled guild branch, while 10 and above use reputation. Verify nonmember boundary cases.
- **Design questions** — Which eligibility rules should be visible to players?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-002 — Guild offer eligibility](../../design/systems/QUEST/QUEST-002.md)

## QUEST-003 — Social offer eligibility

- **Parent subsystem** — Selection
- **Purpose** — Filter work by social context.
- **Existing implementation** — Social pools use group, gender code, level or reputation and the adult/one-time gates. A random entry is selected and loaded from a nonempty pool.
- **Source** — `QuestListsManager.cs#GetSocialQuest`, `QuestListsManager.cs#SelectQuest`, `QuestListsManager.cs#LoadQuest`
- **Inputs and outputs** — Social group, character context and RNG → offer or null
- **Dependencies** — NPC-023, FACT, CHAR, RULE
- **Edge cases and interactions** — Selection attempts one chosen entry. Parse failure can yield no offer even with other candidates.
- **Design questions** — Should a failed candidate be retried or surfaced?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-003 — Social offer eligibility](../../design/systems/QUEST/QUEST-003.md)

## QUEST-004 — Automatic starts and one-time tracking

- **Parent subsystem** — Selection
- **Purpose** — Start configured opening quests and remember accepted offers.
- **Existing implementation** — InitAtGameStartQuests handles list-driven startup entries. CORE also starts named opening quests. QuestListsManager observes quest-start events and maintains accepted one-time state.
- **Source** — `QuestListsManager.cs#InitAtGameStartQuests`, `QuestListsManager.cs#QuestMachine_OnQuestStarted`, `../Utility/StartGameBehaviour.cs#StartNewCharacter`
- **Inputs and outputs** — Startup lists and quest-start notifications → active quests and acceptance tracking
- **Dependencies** — CORE-012, SAVE, NPC
- **Edge cases and interactions** — Trace repeat startup, start-event duplication and persistence of accepted entries.
- **Design questions** — When does a one-time offer become consumed?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-004 — Automatic starts and one-time tracking](../../design/systems/QUEST/QUEST-004.md)

## QUEST-005 — Script grammar and resources

- **Parent subsystem** — Parsing
- **Purpose** — Compile authored text into quest state.
- **Existing implementation** — Parser parses QRC messages and QBN runtime definitions. Resource and task lines become quest objects. Partial parsing supports inspection and is documented as unsuitable for instantiation.
- **Source** — `Parser.cs#Parse`, `Parser.cs#ParseQRC`, `Parser.cs#ParseQBN`, `QuestListsManager.cs#LoadQuest`
- **Inputs and outputs** — Script lines and faction context → quest, tasks, messages and resources
- **Dependencies** — DATA-012, MOD
- **Edge cases and interactions** — ParseQuest logs exceptions and returns null. It reseeds Unity RNG before parsing, including failed parses.
- **Design questions** — Which script errors should block the entire quest?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-005 — Script grammar and resources](../../design/systems/QUEST/QUEST-005.md)

## QUEST-006 — Action grammar registration

- **Parent subsystem** — Parsing
- **Purpose** — Extend recognized quest operations.
- **Existing implementation** — QuestMachine registers IQuestAction templates. Task reads script lines into action instances. Actions contain trigger and update behavior rather than placing every rule in the parser.
- **Source** — `QuestMachine.cs#RegisterAction`, `Task.cs#ReadTaskLines`, `QuestAction.cs`
- **Inputs and outputs** — Action template and script line → runnable quest operation
- **Dependencies** — MOD, DATA, DEV
- **Edge cases and interactions** — Audit ambiguous action matches, unsupported syntax and custom action restore compatibility.
- **Design questions** — How should new verbs be validated and versioned?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-006 — Action grammar registration](../../design/systems/QUEST/QUEST-006.md)

## QUEST-007 — Localized messages and macro expansion

- **Parent subsystem** — Parsing
- **Purpose** — Present authored quest content with context.
- **Existing implementation** — ParseQuest loads localized quest text when present and assigns the display name. The machine can restore localized messages separately. QuestMacroHelper expands resource symbols for display.
- **Source** — `QuestMachine.cs#ParseQuest`, `QuestMachine.cs#RestoreLocalizedQuestMessages`, `Parser.cs#ParseLocalized`, `../../Utility/QuestMacroHelper.cs#ExpandQuestMessage`
- **Inputs and outputs** — Quest source, translation and resource context → display name and message
- **Dependencies** — DATA-016, UI, NPC
- **Edge cases and interactions** — Verify missing translated IDs and dialogue links that become visible on expansion.
- **Design questions** — How should translations fall back while preserving resource references?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-007 — Localized messages and macro expansion](../../design/systems/QUEST/QUEST-007.md)

## QUEST-008 — Immediate and scheduled starts

- **Parent subsystem** — Runtime
- **Purpose** — Activate parsed quests and attach questor context.
- **Existing implementation** — StartQuest calls Quest.Start, adds dialogue topics and inserts the quest by UID, emits the start event and updates the last clicked NPC binding. ScheduleQuest queues for the next tick.
- **Source** — `QuestMachine.cs#StartQuest`, `QuestMachine.cs#ScheduleQuest`, `QuestMachine.cs#Tick`, `Quest.cs#Start`
- **Inputs and outputs** — Parsed quest, optional NPC and start route → active quest and event
- **Dependencies** — NPC-022, CORE, SAVE
- **Edge cases and interactions** — Tick also emits the start event after calling StartQuest on the queued path. Check listeners for duplicate effects.
- **Design questions** — When should start become observable to other systems?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-008 — Immediate and scheduled starts](../../design/systems/QUEST/QUEST-008.md)

## QUEST-009 — Task triggers, ordering and rearming

- **Parent subsystem** — Runtime
- **Purpose** — Drive scripted state transitions.
- **Existing implementation** — Task.Update skips completed actions. Ordinary triggers can set inactive tasks. First always-on trigger can start or stop a task, later ones can only start it. PersistUntil runs actions before checking its terminating target, and can rearm actions.
- **Source** — `Task.cs#Update`, `Task.cs#SetTriggerValue`, `Quest.cs#StartTask`, `Quest.cs#ScheduleClickRearm`
- **Inputs and outputs** — Task flags, actions and trigger outcomes → executed or rearmed actions
- **Dependencies** — TIME, NPC, LOC, QUEST-006
- **Edge cases and interactions** — Ordering is significant. QuestBreak exits the action loop. Test multiple always-on triggers and click reuse.
- **Design questions** — Which triggers should be edge-triggered or continuously evaluated?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-009 — Task triggers, ordering and rearming](../../design/systems/QUEST/QUEST-009.md)

## QUEST-010 — Quest clocks and deadlines

- **Parent subsystem** — Runtime
- **Purpose** — Evaluate time-based scripted tasks.
- **Existing implementation** — Clock is a quest resource with start, tick, task-trigger and save operations. Script actions can start/stop timers and test time conditions.
- **Source** — `Clock.cs#StartTimer`, `Clock.cs#Tick`, `Clock.cs#TriggerTask`, `Actions/StartStopTimer.cs`, `Actions/DailyFrom.cs`
- **Inputs and outputs** — Clock settings and game time → timer state and task trigger
- **Dependencies** — TIME, SAVE, QUEST-009
- **Edge cases and interactions** — Test travel, prison, paused time and exact deadline boundaries.
- **Design questions** — Which time jumps should execute missed triggers?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-010 — Quest clocks and deadlines](../../design/systems/QUEST/QUEST-010.md)

## QUEST-011 — Completion, tombstones and fault handling

- **Parent subsystem** — Runtime
- **Purpose** — Finalize quests and isolate runtime exceptions.
- **Existing implementation** — Tick updates incomplete quests and tombstones completed ones. Tombstones expire after more than one game week. Update exceptions are stored, with protected quests logged and ordinary faulty quests scheduled for removal.
- **Source** — `QuestMachine.cs#Tick`, `QuestMachine.cs#IsProtectedQuest`, `QuestMachine.cs#StoreQuestException`, `Quest.cs#EndQuest`
- **Inputs and outputs** — Quest state, error and clock → continued, tombstoned or removed quest
- **Dependencies** — SAVE, DEV, NPC, FACT
- **Edge cases and interactions** — Inspect end-event ordering and cleanup after partial action side effects. Protected quests may encounter the same error again.
- **Design questions** — What state should remain visible after failure or completion?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-011 — Completion, tombstones and fault handling](../../design/systems/QUEST/QUEST-011.md)

## QUEST-012 — Local, fixed and remote site selection

- **Parent subsystem** — World binding
- **Purpose** — Bind quest places to existing world data.
- **Existing implementation** — Place handles local, fixed and remote site setup and distinct remote town, dungeon and exterior selection paths. It checks already-assigned sites and building constraints.
- **Source** — `Place.cs#SetupLocalSite`, `Place.cs#SetupFixedLocation`, `Place.cs#SelectRemoteTownSite`, `Place.cs#SelectRemoteDungeonSite`, `Place.cs#SelectRemoteLocationExteriorSite`
- **Inputs and outputs** — Place declaration, location data and current assignments → chosen site
- **Dependencies** — WORLD, LOC, DATA-004, RULE
- **Edge cases and interactions** — Results depend on available compatible records. Test exhaustion of valid sites and multiple simultaneous quests.
- **Design questions** — Which world constraints must site selection respect?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-012 — Local, fixed and remote site selection](../../design/systems/QUEST/QUEST-012.md)

## QUEST-013 — Marker selection and site links

- **Parent subsystem** — World binding
- **Purpose** — Reserve placement targets for quest resources.
- **Existing implementation** — Place enumerates building and dungeon markers, chooses markers using preferences and assigns resource symbols. QuestMachine indexes links by site type and location keys and can cull prior targets.
- **Source** — `Place.cs#GetSiteMarker`, `Place.cs#AssignQuestResource`, `Place.cs#EnumerateDungeonQuestMarkers`, `QuestMachine.cs#CreateSiteLink`, `QuestMachine.cs#GetSiteLinks`, `QuestMachine.cs#CullResourceTarget`
- **Inputs and outputs** — Site, marker preference and symbol → placement association
- **Dependencies** — LOC, WORLD, DATA-005, SAVE
- **Edge cases and interactions** — Validate missing markers, occupied markers and world variants. Legacy markers have a reassignment path.
- **Design questions** — How should marker identity survive location changes?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-013 — Marker selection and site links](../../design/systems/QUEST/QUEST-013.md)

## QUEST-014 — Location predicates and discovery

- **Parent subsystem** — World binding
- **Purpose** — Use movement and discovery as quest inputs.
- **Existing implementation** — Place evaluates whether the player is at its site or a required building/dungeon type. Quest actions include entry/exit checks and location reveal.
- **Source** — `Place.cs#IsPlayerHere`, `Place.cs#IsPlayerAtBuildingType`, `Place.cs#IsPlayerAtDungeonType`, `Actions/WhenPcEntersExits.cs`, `Actions/RevealLocation.cs`
- **Inputs and outputs** — Player context and scripted location requirements → condition or discovery change
- **Dependencies** — MOVE-026, WORLD, LOC
- **Edge cases and interactions** — Check equivalent entrances, nested interiors and hidden location states.
- **Design questions** — What counts as reaching a quest destination?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-014 — Location predicates and discovery](../../design/systems/QUEST/QUEST-014.md)

## QUEST-015 — Quest people and interaction binding

- **Parent subsystem** — Resources
- **Purpose** — Place or identify a quest actor.
- **Existing implementation** — Person tracks home, dialogue and assigned place. QuestResourceBehaviour implements clicks and can address individual NPCs. Place/Hide/Mute actions drive authored presence.
- **Source** — `Person.cs#PlaceAtHome`, `Person.cs#GetDialogPlace`, `Components/QuestResourceBehaviour.cs#DoClick`, `Actions/PlaceNpc.cs`, `Actions/HideNpc.cs`, `Actions/MuteNpc.cs`
- **Inputs and outputs** — Person symbol, site and actor click → placement or interaction state
- **Dependencies** — NPC-004, NPC-022, MOVE-023, LOC
- **Edge cases and interactions** — Test questor reuse, multiple matching faction NPCs and hidden or muted actors.
- **Design questions** — When should a quest role replace an existing actor?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-015 — Quest people and interaction binding](../../design/systems/QUEST/QUEST-015.md)

## QUEST-016 — Quest item state and ownership

- **Parent subsystem** — Resources
- **Purpose** — Track quest objects through placement and use.
- **Existing implementation** — Item is a resource with custom saved state. Script actions place, give, take and test items. Inventory tracks quest UID and symbol, with a make-permanent path.
- **Source** — `Item.cs#GetSaveData`, `Actions/PlaceItem.cs`, `Actions/GiveItem.cs`, `Actions/HaveItem.cs`, `Actions/ItemUsedDo.cs`, `Actions/MakePermanent.cs`
- **Inputs and outputs** — Item symbol and action → world/inventory state or task trigger
- **Dependencies** — ITEM-023, MOVE-022, SAVE
- **Edge cases and interactions** — Test transfer, duplicates, orphaned links and consumption by nonquest paths.
- **Design questions** — What should happen if the player loses a required item?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-016 — Quest item state and ownership](../../design/systems/QUEST/QUEST-016.md)

## QUEST-017 — Quest foes and death signals

- **Parent subsystem** — Resources
- **Purpose** — Bind spawned combat actors to scripted objectives.
- **Existing implementation** — Foe has versioned save data. Script actions create, place, restrain or detect killed foes. QuestResourceBehaviour bridges actor state to quest logic. COMBAT defers corpse finalization until the quest foe reports death.
- **Source** — `Foe.cs#GetSaveData`, `Actions/CreateFoe.cs`, `Actions/PlaceFoe.cs`, `Actions/RestrainFoe.cs`, `Actions/KilledFoe.cs`, `Components/QuestResourceBehaviour.cs`
- **Inputs and outputs** — Foe declaration, location and actor state → spawn or task signal
- **Dependencies** — NPC-007, COMBAT-020, LOC, SAVE
- **Edge cases and interactions** — Verify kills before watcher activation, multiple actors per resource and item placement before corpse creation.
- **Design questions** — What must remain available after a quest foe dies?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-017 — Quest foes and death signals](../../design/systems/QUEST/QUEST-017.md)

## QUEST-018 — Prompts, journal and authored dialogue

- **Parent subsystem** — Outcomes
- **Purpose** — Present progress and collect choices.
- **Existing implementation** — Quest exposes popup messages and journal steps. Prompt and PromptMulti handle scripted choices. Journal and log actions update entries. TalkManager owns wider rumor and topic presentation.
- **Source** — `Quest.cs#ShowMessagePopup`, `Quest.cs#AddLogStep`, `Quest.cs#RemoveLogStep`, `Actions/Prompt.cs`, `Actions/PromptMulti.cs`, `Actions/JournalNote.cs`
- **Inputs and outputs** — Message ID, task and player response → popup, branch or journal state
- **Dependencies** — UI, NPC-021, NPC-022, DATA-016
- **Edge cases and interactions** — Check queued prompts, once-per-quest messages and journal retention after completion.
- **Design questions** — Which information should remain in the journal?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-018 — Prompts, journal and authored dialogue](../../design/systems/QUEST/QUEST-018.md)

## QUEST-019 — Rewards and reputation changes

- **Parent subsystem** — Outcomes
- **Purpose** — Apply scripted completion consequences.
- **Existing implementation** — Quest actions include payment, item grants, faction reputation and legal standing changes. GuildManager observes quest end separately from these explicit script actions.
- **Source** — `Actions/PayMoney.cs`, `Actions/GivePc.cs`, `Actions/ChangeReputeWith.cs`, `Actions/LegalRepute.cs`, `../Guilds/GuildManager.cs#QuestMachine_OnQuestEnded`
- **Inputs and outputs** — Scripted reward and faction context → currency, items or reputation
- **Dependencies** — ECON, ITEM, FACT, LAW
- **Edge cases and interactions** — Trace repeated action execution and the distinction between scripted rewards and guild end handling.
- **Design questions** — Which rewards must be applied exactly once?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-019 — Rewards and reputation changes](../../design/systems/QUEST/QUEST-019.md)

## QUEST-020 — Global flags and quest chaining

- **Parent subsystem** — Outcomes
- **Purpose** — Coordinate progression across quests.
- **Existing implementation** — Parser recognizes global references. Quest actions can start or run quests and set/clear task state. PersistentGlobalVars is the player-side global state boundary.
- **Source** — `Parser.cs#IsGlobalReference`, `Actions/StartQuest.cs`, `Actions/RunQuest.cs`, `Actions/ClearTask.cs`, `../Player/PersistentGlobalVars.cs`
- **Inputs and outputs** — Flag, task or quest name → state change or follow-up quest
- **Dependencies** — CHAR, SAVE, CORE
- **Edge cases and interactions** — Verify duplicate starts, cycle handling and differences between local and global task references.
- **Design questions** — What state should later quests be allowed to depend on?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-12)

### My Intended Specification

[QUEST-020 — Global flags and quest chaining](../../design/systems/QUEST/QUEST-020.md)

## QUEST-021 — Cross-system action side effects

- **Parent subsystem** — Outcomes
- **Purpose** — Expose selected world and character operations to scripts.
- **Existing implementation** — Dedicated action classes request changes such as weather, teleport, spell casting, crime and training. Their target systems execute the domain behavior.
- **Source** — `Actions/Weather.cs`, `Actions/TeleportPc.cs`, `Actions/CastSpellDo.cs`, `Actions/SetPlayerCrime.cs`, `Actions/TrainPc.cs`
- **Inputs and outputs** — Scripted arguments and current context → domain action request
- **Dependencies** — TIME, MOVE, MAGIC, LAW, CHAR
- **Edge cases and interactions** — Audit action-specific restrictions and restore/retry semantics. These verbs are representative, with deeper action inventories still open.
- **Design questions** — Which domain actions may scripts invoke directly?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13)

### My Intended Specification

[QUEST-021 — Cross-system action side effects](../../design/systems/QUEST/QUEST-021.md)

## QUEST-022 — Quest runtime restoration

- **Parent subsystem** — Persistence
- **Purpose** — Recreate active scripts and resource state on load.
- **Existing implementation** — QuestMachine and Quest export runtime save records. Tasks, clocks and resource behaviors have their own restore paths. Localized messages and legacy site markers have explicit restore or reassignment seams.
- **Source** — `QuestMachine.cs#GetSaveData`, `QuestMachine.cs#RestoreSaveData`, `Quest.cs#RestoreSaveData`, `Task.cs#RestoreSaveData`, `Components/QuestResourceBehaviour.cs#RestoreSaveData`, `Place.cs#ReassignSiteDetailsLegacyMarkers`
- **Inputs and outputs** — Quest, action, resource and site state → resumed runtime
- **Dependencies** — SAVE, LOC, NPC, MOD
- **Edge cases and interactions** — Test changed or missing scripts, mid-prompt saves, world reconstruction and restored clocks.
- **Design questions** — Which runtime state must survive content updates?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13)

### My Intended Specification

[QUEST-022 — Quest runtime restoration](../../design/systems/QUEST/QUEST-022.md)

## QUEST-023 — Quest faults and debugger visibility

- **Parent subsystem** — Diagnostics
- **Purpose** — Make script failures observable.
- **Existing implementation** — QuestMachine stores quest exceptions and provides logging. HUDQuestDebugger exposes an in-game diagnostic surface. Parse and runtime failures have different paths.
- **Source** — `QuestMachine.cs#StoreQuestException`, `QuestMachine.cs#GetStoredExceptions`, `QuestMachine.cs#LogFormat`, `../UserInterface/HUDQuestDebugger.cs`
- **Inputs and outputs** — Quest state and exception → stored error or debugger display
- **Dependencies** — DEV, UI, SAVE
- **Edge cases and interactions** — Check what diagnostics survive save/load and whether reports include enough source context.
- **Design questions** — What should authors and players see when a quest fails?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-13)

### My Intended Specification

[QUEST-023 — Quest faults and debugger visibility](../../design/systems/QUEST/QUEST-023.md)

## Classic provenance and next review steps

- The interpreter consumes authored quest scripts and tables. Runtime variety includes pool selection and site/marker assignment. Review original scripts alongside the shipped lists and packs to establish provenance and actual outcomes.
- Task.Update comments cite classic quest examples for always-on and PersistUntil ordering. These establish the compatibility cases DFU intends to handle. Original executable parity and behavior for the full script corpus remain open.
- Trace one direct-start story quest and one repeatable offer through parsing, triggers, clock, placement, dialogue, reward and save/reload. Include a failed candidate, a queued start and a quest foe with a scripted drop. Then inventory all action verbs by family and test changed packs and missing sites.
- Review scope separates authored selection, interpreter semantics, world/resource bindings and outcomes. World assembly, combat, dialogue presentation and domain rules stay with their respective systems. Action-family entries sample the source. Individual verb behavior and runtime fixtures remain open.
