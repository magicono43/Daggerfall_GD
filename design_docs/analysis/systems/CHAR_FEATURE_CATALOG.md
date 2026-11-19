# CHAR feature catalog

Static decomposition of the local Daggerfall Unity 1.1.1 snapshot. See the [repository overview](../00_REPOSITORY_OVERVIEW.md) and [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Paths are relative to `Assets/Scripts/`. A symbol follows `#` where cited. Complexity estimates review scope. Confidence rates the source trace. Design questions are open.

## CHAR-001 — Creation flow and handoff

- **Parent subsystem** — Creation
- **Purpose** — Guide the player through character creation.
- **Existing implementation** — The wizard advances through close handlers, copies choices into CharacterDocument, and can return to earlier panels. On confirmation it passes the document to StartGameBehaviour and starts immediately or after the final introductory video callback.
- **Source** — `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#StartNewGame`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#TriggerGame`, `Game/Player/CharacterDocument.cs`
- **Inputs and outputs** — Wizard decisions and enableVideos → document and NewCharacter request.
- **Dependencies** — CORE-011, CORE-012, UI, AV
- **Edge cases and interactions** — Check cancellation, restart, skipped videos and missing-media paths in play.
- **Design questions** — Which choices persist when backing up or restarting?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-001-A01. Documented individual-choice and integration dependencies remain open.

### My Intended Specification

[CHAR-001 — Approved specification v1](../../design/systems/CHAR/CHAR-001.md). Retained creation flow, limited summary edits, full draft discard without confirmation, captured validated handoff and optional skippable cinematics. Individual creation mechanics and UI/media/entry integration remain owner dependencies.

## CHAR-002 — Race and gender selection

- **Parent subsystem** — Creation
- **Purpose** — Choose the initial identity and race template.
- **Existing implementation** — The race and gender panels feed the character document before class and appearance. PlayerEntity assigns the document's gender and race template, and runtime race access uses a live template.
- **Source** — `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#RaceSelectWindow_OnClose`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#GenderSelectWindow_OnClose`, `Game/Entities/PlayerEntity.cs#AssignCharacter`, `Game/Entities/PlayerEntity.cs#GetLiveRaceTemplate`
- **Inputs and outputs** — Race and gender choices → initial player identity and template.
- **Dependencies** — DATA, UI, MAGIC, CHAR-019
- **Edge cases and interactions** — Template-defined bonuses and gender-dependent assets need a per-race fixture inventory.
- **Design questions** — Which traits should follow race, and which should remain independent appearance choices?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-002-A01. Documented owner-resolution, resource and persistence dependencies remain open.

### My Intended Specification

[CHAR-002 — Approved specification v1](../../design/systems/CHAR/CHAR-002.md). Eight-race map selection, description/narration/confirmation, Male/Female appearance sets, retained racial abilities and separate birth/effective race. Owner-resolution, resource and persistence contracts remain dependencies.

## CHAR-003 — Preset class and questionnaire

- **Parent subsystem** — Creation
- **Purpose** — Choose a career directly or derive it from answers.
- **Existing implementation** — The wizard branches between direct selection and class questions. A successful questionnaire result loads CLASSnn.CFG from ARENA2. A no-class result falls back to the list. Selecting a null preset enters custom class creation.
- **Source** — `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#CreateCharClassQuestions_OnClose`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#ClassSelectWindow_OnClose`, `Game/UserInterfaceWindows/CreateCharClassQuestions.cs`, `API/ClassFile.cs`
- **Inputs and outputs** — Preset choice or questionnaire class index, classic CFG → career or custom-class entry.
- **Dependencies** — DATA-008, UI
- **Edge cases and interactions** — The questionnaire branch checks files for null and indexes the first result. An empty result has no local fallback. Verify scoring and ties with original inputs.
- **Design questions** — Should a questionnaire recommend a class, choose it automatically, or allow both?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-003-A01. Documented content-fixture, sampler, UI/media and persistence dependencies remain open.

### My Intended Specification

[CHAR-003 — Approved specification v1](../../design/systems/CHAR/CHAR-003.md). Retained preset/questionnaire/Custom routes, classic ten-of-forty scoring/mapping, revisable answers, informed Yes/No confirmation and explicit invalid-data recovery. Content fixtures, sampler, UI/media and save contracts remain dependencies.

## CHAR-004 — Custom career attributes and skill tiers

- **Parent subsystem** — Creation
- **Purpose** — Define a custom class chassis.
- **Existing implementation** — The custom class window builds a DFCareer and validates allocation before acceptance. The wizard transfers working attributes and chooses the most similar preset class for biography selection.
- **Source** — `Game/UserInterfaceWindows/CreateCharCustomClass.cs`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#CreateCharCustomClassWindow_OnClose`, `API/DFCareer.cs`, `API/BiogFile.cs#GetClassAffinityIndex`
- **Inputs and outputs** — Class name, attributes and skill-tier assignments → custom career and biography affinity index.
- **Dependencies** — DATA-008, UI, CHAR-005, CHAR-006
- **Edge cases and interactions** — Verify duplicate skill handling, cancel/re-entry and affinity ties. Class-tier composition feeds the leveling calculation.
- **Design questions** — Which allocations and skill-tier combinations should the class maker allow?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-004-A01. Documented CHAR-005/006, schema/UI and save-compatibility dependencies remain open.

### My Intended Specification

[CHAR-004 — Approved specification v1](../../design/systems/CHAR/CHAR-004.md). Vanilla 400-point attributes with validated mod-configurable starts/limits/budget; distinct 3/3/6 skills; nonblank Unicode name and retained draft. CHAR-005/006, schema/UI and save compatibility remain dependencies.

## CHAR-005 — Custom advantages and advancement tradeoffs

- **Parent subsystem** — Creation
- **Purpose** — Configure the cost of custom class benefits.
- **Existing implementation** — Custom class difficulty combines hit-points-per-level adjustments and special advantage/disadvantage adjustments. The configured difficulty bounds are -12 to 40. The advancement multiplier interpolates from 0.3 to 3.0 over that range. Custom reputation adjustments are copied into the document.
- **Source** — `Game/UserInterfaceWindows/CreateCharCustomClass.cs#HitPointsUpButton_OnMouseClick`, `Game/UserInterfaceWindows/CreateCharCustomClass.cs#HitPointsDownButton_OnMouseClick`, `Game/UserInterfaceWindows/CreateCharSpecialAdvantageWindow.cs`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#CreateCharCustomClassWindow_OnClose`
- **Inputs and outputs** — HP choice, special selections and reputation adjustments → career parameters and social modifiers.
- **Dependencies** — RULE, FACT, MAGIC, COMBAT, CHAR-004, CHAR-013
- **Edge cases and interactions** — Individual special restrictions and downstream enforcement need a separate matrix. Check boundary values and mutually exclusive choices.
- **Design questions** — Which tradeoffs should affect advancement, and how should their long-term effects be shown?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-005-A01. Documented runtime-effect/stacking, schema, owner-contract and save-compatibility dependencies remain open.

### My Intended Specification

[CHAR-005 — Approved specification v1](../../design/systems/CHAR/CHAR-005.md). Retained HP/trait costs and advancement formula, explicit conflicts/count limits, independent reputation allocation, live explanation and validated mod parameters. Runtime effects/stacking, schema and save compatibility remain dependencies.

## CHAR-006 — Biography selection and outcomes

- **Parent subsystem** — Creation
- **Purpose** — Turn answers into history and starting modifiers.
- **Existing implementation** — The wizard randomly selects a matching biography template for the chosen class affinity. Manual answers or randomly selected answers produce effects and backstory. The automatic branch digests and displays reputation changes. Session startup applies saved biography effects.
- **Source** — `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#CreateCharChooseBioWindow_OnClose`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#CreateCharBiographyWindow_OnClose`, `API/BiogFile.cs#ApplyEffects`, `API/BiogFile.cs#GenerateBackstory`
- **Inputs and outputs** — Class affinity, BIOG files and answers → backstory and effect list.
- **Dependencies** — DATA-008, FACT, CORE-012, UI
- **Edge cases and interactions** — Template selection assumes at least one matching file. Exact effects, granted content and reputation changes depend on the loaded biography.
- **Design questions** — Which effects should be visible before confirming an answer, and should players select a template?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-006-A01. Documented effect/content/RNG, UI and SAVE dependencies remain open.

### My Intended Specification

[CHAR-006 — Approved specification v1](../../design/systems/CHAR/CHAR-006.md). Manual/automatic answers, retained random template, deterministic custom affinity, known-effect disclosure, cached hidden random outcomes and persistent readable history. Effect/content/RNG, UI and SAVE contracts remain dependencies.

## CHAR-007 — Name and portrait

- **Parent subsystem** — Creation
- **Purpose** — Set the character's name and face.
- **Existing implementation** — The name and face panels write choices to the character document. AssignCharacter copies the face index and trims the player name. Portrait presentation is separate from stored identity.
- **Source** — `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#NameSelectWindow_OnClose`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#FaceSelectWindow_OnClose`, `Game/Entities/PlayerEntity.cs#AssignCharacter`, `Game/UserInterface/FacePicker.cs`
- **Inputs and outputs** — Name and selected face index → player identity and portrait selection.
- **Dependencies** — UI, DATA-017, SAVE
- **Edge cases and interactions** — Validate blank names, localized characters and portrait availability for each race/gender combination.
- **Design questions** — Which names and portrait changes should be available after creation?
- **Complexity** — Small
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-007-A01. Documented Unicode/resource/UI and SAVE dependencies remain open.

### My Intended Specification

[CHAR-007 — Approved specification v1](../../design/systems/CHAR/CHAR-007.md). Unicode 31-grapheme names, isolated mapped random suggestions, free rename, extensible stable portraits and explicit missing-portrait recovery. Unicode/resource/UI and SAVE contracts remain dependencies.

## CHAR-008 — Starting attribute rolls and allocation

- **Parent subsystem** — Creation
- **Purpose** — Create the final starting attributes from class and player choices.
- **Existing implementation** — The bonus stat window rerolls from the career, exposes a working allocation and shows derived previews such as spell points and HP modifier. The wizard copies both starting and working stats on acceptance.
- **Source** — `Game/UserInterfaceWindows/CreateCharAddBonusStats.cs#Reroll`, `Game/UserInterface/StatsRollout.cs`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#AddBonusStatsWindow_OnClose`
- **Inputs and outputs** — Career, rolls and point allocation → starting and working attribute sets.
- **Dependencies** — UI, RULE, CHAR-004, CHAR-011
- **Edge cases and interactions** — Verify reroll bounds, point exhaustion and what survives returning from later panels.
- **Design questions** — Should rolls, previews and allocation be separate choices?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-008-A01. Documented numeric/schema/RNG, preview and SAVE dependencies remain open.

### My Intended Specification

[CHAR-008 — Approved specification v1](../../design/systems/CHAR/CHAR-008.md). Uniform attribute bonuses/pool, full allocation, deliberate rerolls, one compatible complete-state slot, owner previews and every-outcome mod feasibility. Numeric/schema/RNG, preview and SAVE contracts remain dependencies.

## CHAR-009 — Starting skill allocation

- **Parent subsystem** — Creation
- **Purpose** — Distribute starting skill bonuses by career tier.
- **Existing implementation** — The skill window maintains separate primary, major and minor pools and blocks acceptance while any remains. The wizard copies starting and working skills and tracks whether a reroll is needed on return.
- **Source** — `Game/UserInterfaceWindows/CreateCharAddBonusSkills.cs#SetBonusSkillPoints`, `Game/UserInterface/SkillsRollout.cs`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#AddBonusSkillsWindow_OnClose`
- **Inputs and outputs** — Career tiers, starting values, tier pools and player allocation → working skill set.
- **Dependencies** — UI, CHAR-004, CHAR-014
- **Edge cases and interactions** — Verify per-skill bounds and whether backtracking or changing class invalidates allocations.
- **Design questions** — Should points transfer across tiers or be reserved for each tier?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-009-A01. Documented feasibility/schema, owner-integration and SAVE dependencies remain open.

### My Intended Specification

[CHAR-009 — Approved specification v1](../../design/systems/CHAR/CHAR-009.md). Retained uniform skill ranges, isolated tier pools, retained rolls, transparent biography effects, explicit final limits and validated mod/skill extensibility. Feasibility/schema, owner integration and SAVE contracts remain dependencies.

## CHAR-010 — Reflex difficulty selection

- **Parent subsystem** — Creation
- **Purpose** — Store a difficulty choice with progression consequences.
- **Existing implementation** — The reflex panel supplies PlayerReflexes, which is stored on the document and assigned to the player. RaiseSkills scales use tallies by reflex setting when checking advancement.
- **Source** — `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#ReflexSelectWindow_OnClose`, `Game/UserInterfaceWindows/CreateCharReflexSelect.cs`, `Game/Entities/PlayerEntity.cs#RaiseSkills`
- **Inputs and outputs** — Reflex choice → saved player setting and effective advancement tally.
- **Dependencies** — COMBAT, RULE, UI, CHAR-013
- **Edge cases and interactions** — Audit combat consumers before establishing the full effect of each choice. Advancement checks use integer arithmetic.
- **Design questions** — Should action difficulty and advancement speed share a setting?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-010-A01. Documented combat/progression scope, mod-schema and SAVE dependencies remain open.

### My Intended Specification

[CHAR-010 — Approved specification v1](../../design/systems/CHAR/CHAR-010.md). Five retained creation options couple combat pressure/practice scaling, stay fixed in play and support validated parameter overrides. Combat/progression scope, mod schemas and SAVE compatibility remain dependencies.

## CHAR-011 — Permanent and live attributes and skills

- **Parent subsystem** — Character state
- **Purpose** — Expose stable progression values and modified values to gameplay.
- **Existing implementation** — DaggerfallStats and DaggerfallSkills calculate live values from permanent values and modifiers. The character sheet uses live values and compares them against permanent values for stat coloring. Advancement uses permanent skills.
- **Source** — `Game/Entities/DaggerfallStats.cs#GetLiveStatValue`, `Game/Entities/DaggerfallSkills.cs#GetLiveSkillValue`, `Game/Entities/DaggerfallEntity.cs#ClearConstantEffects`, `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#UpdatePlayerValues`
- **Inputs and outputs** — Permanent stats/skills and active modifiers → live values and UI indicators.
- **Dependencies** — MAGIC, ITEM, RULE, UI, SAVE
- **Edge cases and interactions** — Trace clamping and modifier reset/reapplication when stacking effects or reloading. Consumers can deliberately use different value types.
- **Design questions** — Which rules should use permanent values, and which should see temporary bonuses?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-011-A01. Documented consumer/schema/stacking/UI and SAVE dependencies remain open.

### My Intended Specification

[CHAR-011 — Approved specification v1](../../design/systems/CHAR/CHAR-011.md). Distinct permanent/live values, capped live attributes, unclamped live skills, source-owned modifiers, inspectable breakdowns and source-based restore. Consumer/schema/stacking/UI and SAVE contracts remain dependencies.

## CHAR-012 — Skill use tracking

- **Parent subsystem** — Progression
- **Purpose** — Record practice independently of permanent increases.
- **Existing implementation** — TallySkill adds a signed amount to the per-skill tally, clamps to 0–20000 and logs exceptions. Movement, attacks, magic and other features submit tallies. Save state retains progression data.
- **Source** — `Game/Entities/PlayerEntity.cs#TallySkill`, `Game/WeaponManager.cs`, `Game/MagicAndEffects/EntityEffectManager.cs`, `Game/Serialization/SerializablePlayer.cs`
- **Inputs and outputs** — Skill enum and signed count → bounded usage tally.
- **Dependencies** — MOVE, COMBAT, MAGIC, SAVE, CHAR-013
- **Edge cases and interactions** — A complete caller inventory is open. Verify invalid indices and large inputs, including arithmetic before clamping.
- **Design questions** — What events count as meaningful practice, and should the player see the tally?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-012-A01. Documented eligibility/cadence, advancement, deduplication and SAVE dependencies remain open.

### My Intended Specification

[CHAR-012 — Approved specification v1](../../design/systems/CHAR/CHAR-012.md). Raw stable-ID practice, safe saturation, owner-defined qualifying events, duplicate/context validation and exact restored counters. Eligibility/cadence, advancement, deduplication and SAVE contracts remain dependencies.

## CHAR-013 — Periodic skill increases and mastery

- **Parent subsystem** — Progression
- **Purpose** — Convert accumulated practice into permanent improvement.
- **Existing implementation** — RaiseSkills exits during death or when at most 360 classic minutes have elapsed since the last check. It uses skill/career multipliers, level and reflex-scaled usage. A qualifying tally resets and can yield one point. Once a primary is at 100, other skills at 95 or above cannot rise through this path. Primary mastery can trigger a message and sound.
- **Source** — `Game/Entities/PlayerEntity.cs#RaiseSkills`, `Game/Entities/PlayerEntity.cs#AlreadyMasteredASkill`, `Game/Formulas/FormulaHelper.cs#CalculateSkillUsesForAdvancement`, `Game/UserInterfaceWindows/DaggerfallRestWindow.cs`, `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs`
- **Inputs and outputs** — Tallies, time, permanent skills and progression parameters → skill gains, recent markers and notifications.
- **Dependencies** — RULE, TIME, UI, CHAR-010, CHAR-012
- **Edge cases and interactions** — Rest and fast-travel paths call the check. Eligible tallies reset even if a cap prevents a gain. Multiple threshold equivalents do not grant multiple points in this loop.
- **Design questions** — Should practice carry forward, and when should mastery restrict other skills?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-013-A01. Documented time/schema/numeric, batching/UI and SAVE dependencies remain open.

### My Intended Specification

[CHAR-013 — Approved specification v1](../../design/systems/CHAR/CHAR-013.md). Default rest/travel conversion plus optional fixed live mode, validated gain/consumption policies, precise carryover and snapshot mastery. Time/schema/numeric, batching/UI and SAVE contracts remain dependencies.

## CHAR-014 — Level eligibility and progress

- **Parent subsystem** — Progression
- **Purpose** — Compute when skill growth qualifies for another level.
- **Existing implementation** — Current sum includes all primary skills, major skills excluding the lowest, and the highest minor skill. The default formula uses current minus starting sum plus 28, divided by 15. CheckForLevelUp sets ReadyToLevelUp when calculated level exceeds actual level.
- **Source** — `Game/Entities/PlayerEntity.cs#SetCurrentLevelUpSkillSum`, `Game/Entities/PlayerEntity.cs#CheckForLevelUp`, `Game/Formulas/FormulaHelper.cs#CalculatePlayerLevel`, `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#LevelButton_OnMouseClick`
- **Inputs and outputs** — Permanent career skills, starting baseline and actual level → eligibility and displayed progress.
- **Dependencies** — RULE, CORE-012, SAVE, UI, CHAR-015
- **Edge cases and interactions** — The sheet's progress display uses its own floating-point expression. Check behavior under formula overrides and large gains crossing multiple thresholds.
- **Design questions** — Which skill tiers should count, and how should multi-level eligibility surface?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-014-A01. Documented mod-schema, claim-integration and SAVE dependencies remain open.

### My Intended Specification

[CHAR-014 — Approved specification v1](../../design/systems/CHAR/CHAR-014.md). Ranked permanent skill contribution, retained baseline/formula, nonrevocable eligible target/backlog and shared progress UI. Mod-schema, claim integration and SAVE contracts remain dependencies.

## CHAR-015 — Level rewards and allocation

- **Parent subsystem** — Progression
- **Purpose** — Apply a pending level and distribute earned attributes.
- **Existing implementation** — The character sheet consumes the ready flag. Ordinary leveling adds one level and formula-based maximum HP, then offers a bonus pool. Oghma uses its own pool without the ordinary level/HP increment. Closing is blocked with unused points unless every stat is at maximum, then working stats are committed.
- **Source** — `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#UpdatePlayerValues`, `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#CheckIfDoneLeveling`, `Game/Formulas/FormulaHelper.cs#CalculateHitPointsPerLevelUp`, `Game/MagicAndEffects/Effects/Special/OghmaInfiniumEffect.cs`
- **Inputs and outputs** — Pending level or artifact flag → level/HP changes and attribute allocation.
- **Dependencies** — UI, RULE, MAGIC, CHAR-014, SAVE
- **Edge cases and interactions** — Ordinary level and HP are changed before allocation commits. Verify transitions if another event or save/load intervenes.
- **Design questions** — When should leveling become effective, and how should special bonus pools behave?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-015-A01. Documented transaction/UI/vital, mod-schema and SAVE dependencies remain open.

### My Intended Specification

[CHAR-015 — Approved specification v1](../../design/systems/CHAR/CHAR-015.md). Ordered separate rewards, retained rolls, atomic level/HP/attribute confirmation, mandatory vanilla allocation, explicit capped remainder and optional mod deferral. Transaction/UI/vital, mod-schema and SAVE contracts remain dependencies.

## CHAR-016 — Paid skill training

- **Parent subsystem** — Progression
- **Purpose** — Convert guild services into practice credit.
- **Existing implementation** — Training checks a 720 classic-minute cooldown, money and the service's available skills. Skills strictly above the guild maximum are rejected. Successful training timestamps the session and tallies a random 10–20 multiplied by the skill advancement multiplier.
- **Source** — `Game/UserInterfaceWindows/DaggerfallGuildServiceTraining.cs#TrainingService`, `Game/UserInterfaceWindows/DaggerfallGuildServiceTraining.cs#TrainingSkill_OnItemPicked`, `Game/UserInterfaceWindows/DaggerfallGuildServiceTraining.cs#GetTrainingSkills`
- **Inputs and outputs** — Guild service, skill, permanent value, gold and clock → eligibility, payment and practice credit.
- **Dependencies** — FACT, ECON, TIME, CHAR-012, CHAR-013
- **Edge cases and interactions** — Equality with the training maximum passes this check. Quest-granted training is a separate entry path to trace.
- **Design questions** — Should training grant practice, direct increases, or a separate reward?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-016-A01. Documented service/time/vital, MOD and SAVE dependencies remain open.

### My Intended Specification

[CHAR-016 — Approved specification v1](../../design/systems/CHAR/CHAR-016.md). Paid raw practice with quoted eligibility, start-based cooldown, full-counter purchasing and protected default activity; validated mod stages/interruptions with explicit settlement. Service/time/vital, MOD and SAVE contracts remain dependencies.

## CHAR-017 — Character initialization and progression restoration

- **Parent subsystem** — Character state
- **Purpose** — Populate or reconstruct the live character from stored state.
- **Existing implementation** — AssignCharacter copies the document, trims names, chooses supplied or rolled HP and optionally fills vitals. Reset clears character-owned state on OnNewGame. SerializablePlayer restores level sums and recalculates or estimates older missing values.
- **Source** — `Game/Entities/PlayerEntity.cs#AssignCharacter`, `Game/Entities/PlayerEntity.cs#Reset`, `Game/Entities/PlayerEntity.cs#EstimateStartingLevelUpSkillSum`, `Game/Serialization/SerializablePlayer.cs`, `Game/Player/CharacterDocument.cs`
- **Inputs and outputs** — Document, optional level/HP and save data → live character and progression baseline.
- **Dependencies** — CORE-010, CORE-011, CORE-014, SAVE, DATA
- **Edge cases and interactions** — Fresh start, native restore and classic import have different ordering. Test missing baseline values and timestamp alignment.
- **Design questions** — Which starting and progression values must be serialized versus recomputed?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-017-A01. Documented schema/clock/vital, owner/UI and SAVE dependencies remain open.

### My Intended Specification

[CHAR-017 — Approved specification v1](../../design/systems/CHAR/CHAR-017.md). Separate fresh/restore routes, isolated state, ordinary start/full vitals, authoritative progression restoration and quiescent derived rebuild. Schema/clock/vital, owner/UI and SAVE contracts remain dependencies.

## CHAR-018 — Vital pools and derived limits

- **Parent subsystem** — Character state
- **Purpose** — Track health, fatigue, magicka and breath.
- **Existing implementation** — The entity exposes current and maximum vitals, fill operations and setter paths. The player setters override god mode for health, fatigue and magicka. Ordinary player health clamps, while restore mode assigns the supplied health directly before lethal checks.
- **Source** — `Game/Entities/DaggerfallEntity.cs#FillVitalSigns`, `Game/Entities/DaggerfallEntity.cs#SetBreath`, `Game/Entities/PlayerEntity.cs#SetHealth`, `Game/Entities/PlayerEntity.cs#SetFatigue`, `Game/Entities/PlayerEntity.cs#SetMagicka`
- **Inputs and outputs** — Career, attributes, effects, restore mode and vital changes → pool values and depletion events.
- **Dependencies** — RULE, MAGIC, MOVE, COMBAT, SAVE, UI
- **Edge cases and interactions** — Verify max-pool changes, restore inputs and underwater breath behavior with MOVE. Lethal consequences are CHAR-023.
- **Design questions** — How should current values respond when their maximum changes?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-018-A01. Documented source/outcome/schema and SAVE/TIME dependencies remain open.

### My Intended Specification

[CHAR-018 — Approved specification v1](../../design/systems/CHAR/CHAR-018.md). Explicit vital formulas/units, no-refill max changes, cost/damage semantics, transition depletion and moddable instant/gradual breath recovery. Source/outcome/schema and SAVE/TIME contracts remain dependencies.

## CHAR-019 — Live race and transformation grants

- **Parent subsystem** — Character state
- **Purpose** — Expose altered identity and associated character grants.
- **Existing implementation** — The live race accessor distinguishes effective race from the stored template. PlayerEntity has explicit vampire-clan and lycanthropy spell grant operations. Classic import can reconstitute transformation effects through the effect manager.
- **Source** — `Game/Entities/PlayerEntity.cs#GetLiveRaceTemplate`, `Game/Entities/PlayerEntity.cs#AssignPlayerVampireSpells`, `Game/Entities/PlayerEntity.cs#AssignPlayerLycanthropySpell`, `Game/Utility/StartGameBehaviour.cs#StartFromClassicSave`
- **Inputs and outputs** — Base template, active transformation and clan → effective identity and transformation spells.
- **Dependencies** — MAGIC, FACT, QUEST, CORE-014, CHAR-002
- **Edge cases and interactions** — Trace cure cleanup, spell tags and races that modify swimming or other derived behavior. Infection and curse timing belong to MAGIC.
- **Design questions** — Which identity fields and abilities should change with transformation or cure?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-019-A01. Documented mechanics/entitlement/asset, MOD and SAVE dependencies remain open.

### My Intended Specification

[CHAR-019 — Approved specification v1](../../design/systems/CHAR/CHAR-019.md). Birth/condition/form separation, source-owned grants, explicit inheritance/compatibility and validated transformation/cure. Mechanics/entitlement/asset, MOD and SAVE contracts remain dependencies.

## CHAR-020 — Activity fatigue and practice

- **Parent subsystem** — Survival
- **Purpose** — Apply fatigue costs as time and movement progress.
- **Existing implementation** — PlayerEntity.Update uses current activity on a changed game minute, with climbing and running taking precedence over swimming. Rest suppresses that periodic deduction. Swimming can tally practice and apply a higher cost after a failed check for non-Argonians. Jumping charges and tallies once per detected jump. Athleticism uses 0.9 or 0.8 loss multipliers in the applicable branch.
- **Source** — `Game/Entities/PlayerEntity.cs#Update`, `Game/Entities/PlayerEntity.cs#FixedUpdate`, `Game/Entities/DaggerfallEntity.cs#DecreaseFatigue`
- **Inputs and outputs** — Clock, movement state, race, career and skill → fatigue deduction and practice.
- **Dependencies** — MOVE, TIME, RULE, MAGIC, CHAR-012, CHAR-018
- **Edge cases and interactions** — The minute branch checks for a change rather than looping for each missed minute. The source labels Athleticism values as an approximation needing verification.
- **Design questions** — Which activities should spend fatigue, and how should elapsed-time jumps be handled?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-020-A01. Documented TIME/MOVE cadence/integration, mod-schema and SAVE dependencies remain open.

### My Intended Specification

[CHAR-020 — Approved specification v1](../../design/systems/CHAR/CHAR-020.md). Retained fatigue rates/Athleticism, actual-context elapsed accounting, frame-independent practice and explicit owned intervals. TIME/MOVE cadence/integration, mod-schema and SAVE contracts remain dependencies.

## CHAR-021 — Rest recovery

- **Parent subsystem** — Survival
- **Purpose** — Restore vital pools as rest advances.
- **Existing implementation** — The rest window computes health, fatigue and spell-point recovery through FormulaHelper and adds the amounts to current pools. The rest flow also calls RaiseSkills. Shared rest veto and threat checks are documented in CORE-019.
- **Source** — `Game/UserInterfaceWindows/DaggerfallRestWindow.cs`, `Game/Formulas/FormulaHelper.cs#CalculateHealthRecoveryRate`, `Game/Formulas/FormulaHelper.cs#CalculateFatigueRecoveryRate`, `Game/Formulas/FormulaHelper.cs#CalculateSpellPointRecoveryRate`
- **Inputs and outputs** — Rest progression, current pools, career and recovery formulas → vital gains and possible skill check.
- **Dependencies** — TIME, MAGIC, RULE, CORE-019, CHAR-013
- **Edge cases and interactions** — Verify restrictions from special abilities and the timing of each recovery step around interruptions. Rest duration and encounters remain TIME scope.
- **Design questions** — Which pools should recover during rest, and under what restrictions?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-021-A01. Documented TIME/environment/schema and SAVE dependencies remain open.

### My Intended Specification

[CHAR-021 — Approved specification v1](../../design/systems/CHAR/CHAR-021.md). Hourly recovery/practice, explicit interior Darkness, moddable environment/cadence and interruption/unrecoverable settlement. TIME/environment/schema and SAVE contracts remain dependencies.

## CHAR-022 — Exhaustion and collapse

- **Parent subsystem** — Survival
- **Purpose** — Handle a depleted fatigue pool in or out of danger.
- **Existing implementation** — The exhaustion handler stops movement and displays context-specific text. With no nearby enemies and outside swimming, it advances one hour, applies recovery and tallies Medical. Otherwise it sets health to zero.
- **Source** — `Game/Entities/PlayerEntity.cs#PlayerEntity_OnExhausted`, `Game/Entities/DaggerfallEntity.cs#SetFatigue`, `Game/GameManager.cs#AreEnemiesNearby`
- **Inputs and outputs** — Exhaustion event, health, nearby threats and swimming state → collapse, recovery or lethal health request.
- **Dependencies** — CORE-019, MOVE, TIME, UI, CHAR-021, CHAR-023
- **Edge cases and interactions** — Repeated events while the popup is displayed and events at zero health are ignored. Lethal requests still pass through player health handling.
- **Design questions** — Should collapse resolve differently in combat, water and safe areas?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-022-A01. Documented threat/activity/outcome, mod-schema and SAVE dependencies remain open.

### My Intended Specification

[CHAR-022 — Approved specification v1](../../design/systems/CHAR/CHAR-022.md). Purpose-specific safe/lethal outcomes, once-only forced recovery, modded interruptions and persistent unresolved incapacitation. Threat/activity/outcome, mod-schema and SAVE contracts remain dependencies.

## CHAR-023 — Lethal damage and death sequence

- **Parent subsystem** — Survival
- **Purpose** — Resolve death prevention and transition out of play.
- **Existing implementation** — God mode restores maximum HP. At zero or less health, guild AvoidDeath can leave ten percent max HP truncated to int. Otherwise death is raised. PlayerDeath gates repeat animation, pauses input, drops the camera, fades HUD, plays audio and later requests death return.
- **Source** — `Game/Entities/PlayerEntity.cs#SetHealth`, `Game/PlayerDeath.cs#PlayerEntity_OnDeath`, `Game/PlayerDeath.cs#ClearDeathAnimation`, `Game/Utility/StartGameBehaviour.cs#StartTitleMenuFromDeath`
- **Inputs and outputs** — Lethal health change, god mode, guild benefit and scene state → survival or death event and menu handoff.
- **Dependencies** — FACT, COMBAT, AV, UI, CORE-008, CORE-015
- **Edge cases and interactions** — A small max HP can round the guild survival value down to zero. Verify restore-time lethal states and missing-camera behavior.
- **Design questions** — What may prevent death, and which controls should remain available during the sequence?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-06; approval CHAR-023-A01. Documented benefit/AV/input, mod-schema and SAVE dependencies remain open.

### My Intended Specification

[CHAR-023 — Approved specification v1](../../design/systems/CHAR/CHAR-023.md). Deterministic once-only prevention/death, positive survival health, unskippable initial presentation and CORE-008 movie/menu handoff; death-state saving blocked. Benefit/AV/input, mod-schema and SAVE contracts remain dependencies.

## Classic inheritance and unresolved evidence

- Preset careers and biography questions depend on classic-style files and DFU's available content. Verify actual templates, answer effects and port changes with DATA-008 and representative fixtures. The wizard comment identifies additional biography templates as a mod extension.
- Skill formulas, mastery rules, progression and recovery are directly visible DFU implementations. Source alone cannot establish equivalence to original Daggerfall. Athleticism multipliers have an explicit uncertainty comment. The estimated starting skill sum on restore is a DFU heuristic.
- Review CHAR-001 through CHAR-010 with a preset and a custom character. Then follow CHAR-012 through CHAR-016 across rest, training, travel and a level-up, including mastery and multi-threshold cases. Review survival and restore cases with runtime fixtures after those baselines are understood.
- Combat resolution, full movement physics, spell effect rules, world placement, legal state, guild membership and save format remain with their owning systems. Verify all tally callers and per-special enforcement in those passes. No runtime or original-game comparison was performed.

