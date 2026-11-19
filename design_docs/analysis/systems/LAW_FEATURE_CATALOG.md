# LAW feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Paths are relative to `Assets/Scripts/`. Symbols follow `#`. Complexity estimates review scope. Confidence rates the sampled source trace.

## LAW-001 — Current charge and suppression

- **Parent subsystem** — Crime state
- **Purpose** — Record the current offense.
- **Existing implementation** — The CrimeCommitted setter stores one enum value, substitutes None when a racial override suppresses crime and emits OnCrimeUpdate even when cleared. Some periodic enforcement branches write the backing field directly.
- **Source** — `Game/Entities/PlayerEntity.cs#SetCrimeCommitted`, `Game/Entities/PlayerEntity.cs#Update`, `Game/Questing/Actions/SetPlayerCrime.cs`
- **Inputs and outputs** — Offense, racial override and caller → current charge and optional event
- **Dependencies** — CHAR, MAGIC-029, QUEST-021, MOD
- **Edge cases and interactions** — Direct writes bypass setter suppression and event. Caller side effects can occur independently of the stored charge.
- **Design questions** — Which actions should create, replace or suppress a charge?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-001 — Current charge and suppression](../../design/systems/LAW/LAW-001.md)

## LAW-002 — Forced entry and trespass

- **Parent subsystem** — Offenses
- **Purpose** — Record illegal building access.
- **Existing implementation** — Static door activation includes attempted breaking-and-entering and completed breaking-and-entering paths with guard spawning. Lock, bash and spell entry use distinct checks.
- **Source** — `Game/PlayerActivate.cs#ActivateStaticDoor`, `Game/PlayerActivate.cs#AttemptExteriorDoorBash`, `Game/PlayerActivate.cs#BuildingIsUnlocked`
- **Inputs and outputs** — Building state, entry action and eligibility → access or charge and guard request
- **Dependencies** — MOVE-020, LOC, QUEST, MAGIC
- **Edge cases and interactions** — Trace exact detection and quest-access exceptions per route. Verify whether successful lockpicking and bashing share consequences.
- **Design questions** — Which entry methods should attract enforcement?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-002 — Forced entry and trespass](../../design/systems/LAW/LAW-002.md)

## LAW-003 — Pickpocketing detection

- **Parent subsystem** — Offenses
- **Purpose** — Escalate detected theft from a person.
- **Existing implementation** — PlayerActivate tallies Pickpocket and uses a shared chance calculation. The detected branch sets Pickpocketing and requests immediate guards.
- **Source** — `Game/PlayerActivate.cs#Pickpocket`, `Game/Formulas/FormulaHelper.cs#CalculatePickpocketingChance`
- **Inputs and outputs** — Target and skill → theft result and possible enforcement
- **Dependencies** — MOVE-024, RULE-010, ITEM, NPC
- **Edge cases and interactions** — Check target type and failed versus detected cases. Do not infer all failed checks have identical consequences.
- **Design questions** — What should determine whether a failed attempt is noticed?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-003 — Pickpocketing detection](../../design/systems/LAW/LAW-003.md)

## LAW-004 — Shoplifting and private property

- **Parent subsystem** — Offenses
- **Purpose** — Detect taking protected items.
- **Existing implementation** — Inventory has a private-property theft path. Trade has a separate Theft assignment during shop interaction. Both are distinct from person pickpocketing.
- **Source** — `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#AttemptPrivatePropertyTheft`, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs`, `Game/Formulas/FormulaHelper.cs#CalculateShopliftingChance`
- **Inputs and outputs** — Container or shop, item context and detection → transfer outcome or theft charge
- **Dependencies** — ITEM-022, ECON, RULE-010, MOVE-022
- **Edge cases and interactions** — Verify when detection occurs relative to transfer and which branches request guards. Test mixed stacks and repeated attempts.
- **Design questions** — Should opening, moving or leaving with an item trigger detection?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-004 — Shoplifting and private property](../../design/systems/LAW/LAW-004.md)

## LAW-005 — Violence against civilians and guards

- **Parent subsystem** — Offenses
- **Purpose** — Classify violent contact and escalate.
- **Existing implementation** — WeaponManager sets murder for non-guard mobile NPC hits and assault for guard NPC hits, replacing the latter with a hostile guard. Entity behavior also has assault and murder paths outside the weapon manager.
- **Source** — `Game/WeaponManager.cs#WeaponDamage`, `Game/Entities/DaggerfallEntityBehaviour.cs`, `Game/Entities/PlayerEntity.cs#TallyCrimeGuildRequirements`
- **Inputs and outputs** — Victim type and damage route → charge, guard response and possible recruitment tally
- **Dependencies** — COMBAT-018, NPC, FACT-012, MAGIC
- **Edge cases and interactions** — Compare weapon, spell and other damage routes and transformed-player suppression.
- **Design questions** — Should assault and murder depend on contact, injury or death?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-005 — Violence against civilians and guards](../../design/systems/LAW/LAW-005.md)

## LAW-006 — Vagrancy and loan default

- **Parent subsystem** — Offenses
- **Purpose** — Apply legal consequences outside combat.
- **Existing implementation** — Rest window can set Vagrancy. On overdue loans, LoanChecker attempts repayment from the account, then flags a remaining loan as defaulted and applies LoanDefault reputation loss once for the region.
- **Source** — `Game/UserInterfaceWindows/DaggerfallRestWindow.cs`, `Game/LoanChecker.cs#OverdueLoan`, `Game/Entities/PlayerEntity.cs#LowerRepForCrime`
- **Inputs and outputs** — Rest context or overdue debt and funds → charge or regional standing loss
- **Dependencies** — TIME, ECON, FACT
- **Edge cases and interactions** — Loan default directly changes reputation. Source notes uncertainty about whether the classic default flag was ever set.
- **Design questions** — Which nonviolent violations should trigger arrest versus standing loss?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-006 — Vagrancy and loan default](../../design/systems/LAW/LAW-006.md)

## LAW-007 — Immediate guard placement

- **Parent subsystem** — Enforcement
- **Purpose** — Create hostile guards after a reported crime.
- **Existing implementation** — SpawnCityGuards gates on dungeon state and active guard count. Eligible interiors use an outer door and spawn 2–5 guards. Exterior immediate response prefers nearby pooled guards, may use non-guards behind the player and falls back to a foe spawner.
- **Source** — `Game/Entities/PlayerEntity.cs#SpawnCityGuards`, `Game/Entities/PlayerEntity.cs#SpawnCityGuard`, `Game/Utility/PopulationManager.cs`
- **Inputs and outputs** — Crime response, location, door or pool → guard enemies
- **Dependencies** — NPC-001, NPC-007, LOC, COMBAT
- **Edge cases and interactions** — The count gate is checked before a batch and allows equality with five. Missing location, pool or eligible door can block response.
- **Design questions** — Where should guards emerge and what should cap their numbers?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-007 — Immediate guard placement](../../design/systems/LAW/LAW-007.md)

## LAW-008 — Delayed pursuit and regional warrants

- **Parent subsystem** — Enforcement
- **Purpose** — Trigger guards for ongoing legal exposure.
- **Existing implementation** — Player update checks legal reputation below -10 with a 5-percent roll and banishment flag with a 10-percent roll, assigning Criminal Conspiracy directly. Delayed arrivals track a location and immediate spawning occurs when countdown expires at that same location.
- **Source** — `Game/Entities/PlayerEntity.cs#Update`, `Game/Entities/PlayerEntity.cs#SpawnCityGuards`, `Game/Entities/PlayerEntity.cs#MakeNPCGuardsIntoEnemiesIfGuardsSpawned`
- **Inputs and outputs** — Elapsed time, region flags, civilian context and location → delayed or active guards
- **Dependencies** — TIME, NPC, WORLD, LAW-001
- **Edge cases and interactions** — Check catch-up iteration, location departure and simultaneous low-standing and banishment rolls.
- **Design questions** — How should a regional warrant affect ordinary travel?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-008 — Delayed pursuit and regional warrants](../../design/systems/LAW/LAW-008.md)

## LAW-009 — Surrender and arrest handoff

- **Parent subsystem** — Enforcement
- **Purpose** — Convert a guard encounter into court.
- **Existing implementation** — Surrender rejects dead players, then calls SetHealth(1). Involuntary surrender fails below -20 legal standing and can fail by random roll at -20 through zero. Voluntary surrender bypasses these rejection branches. Court entry requests exterior transition if inside and sets Arrested.
- **Source** — `Game/Entities/PlayerEntity.cs#SurrenderToCityGuards`, `Game/Entities/PlayerEntity.cs#CourtWindow`, `Game/EnemyAttack.cs#SurrenderToGuardsDialogue_OnButtonClick`
- **Inputs and outputs** — Health, surrender type and legal standing → arrest or rejection
- **Dependencies** — COMBAT-019, CHAR-018, MOVE-026, UI
- **Edge cases and interactions** — Health is set before later rejection branches. Verify actual guard attack timing and interior fade order.
- **Design questions** — When should surrender be possible and what happens on rejection?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-009 — Surrender and arrest handoff](../../design/systems/LAW/LAW-009.md)

## LAW-010 — Regional penalties and faction spillover

- **Parent subsystem** — Standing
- **Purpose** — Apply crime consequences to standing.
- **Existing implementation** — LowerRepForCrime subtracts a crime-indexed amount from the selected region and propagates negative half to the regional people faction. Sentence recovery uses a stored half-loss value minus one for legal standing, and half that delta for faction standing.
- **Source** — `Game/Entities/PlayerEntity.cs#LowerRepForCrime`, `Game/Entities/PlayerEntity.cs#RaiseReputationForDoingSentence`, `Game/Entities/PlayerEntity.cs#ClampLegalReputations`
- **Inputs and outputs** — Crime, region and recorded penalty → legal and faction deltas
- **Dependencies** — FACT-003, TIME, SAVE
- **Edge cases and interactions** — Integer division can make small changes zero or negative on recovery. Clamp is a separate path. Source notes classic used the opposite faction-recovery sign.
- **Design questions** — Which outcomes should affect local versus faction standing?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-010 — Regional penalties and faction spillover](../../design/systems/LAW/LAW-010.md)

## LAW-011 — Penalty severity and fine calculation

- **Parent subsystem** — Court
- **Purpose** — Generate a sentence from charge and standing.
- **Existing implementation** — Court derives severe-punishment chances from negative legal standing. It clamps a crime-specific amount, divides by 40 and uses classic RNG to allocate units to 40 gold or three prison days. Insufficient money caps the fine and adds days for unpaid units.
- **Source** — `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#HandleCourtLogic`, `API/DFRandom.cs#rand`
- **Inputs and outputs** — Charge, legal standing, gold and RNG → punishment category, fine and days
- **Dependencies** — RULE-001, RULE-002, ECON, FACT
- **Edge cases and interactions** — Court closes for None. Mixed RNG and integer truncation affect outcomes. Verify table coverage by crime type.
- **Design questions** — Should penalty estimates be shown before pleading?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-011 — Penalty severity and fine calculation](../../design/systems/LAW/LAW-011.md)

## LAW-012 — Guild rescue

- **Parent subsystem** — Court
- **Purpose** — Allow member intervention before trial.
- **Existing implementation** — Court checks Dark Brotherhood for assault/murder and Thieves Guild for selected entry offenses and pickpocketing. A member can be rescued when rank meets a Unity random draw of 0–19. Rescue fills vitals and applies sentence-reputation handling.
- **Source** — `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#HandleCourtLogic`, `Game/Guilds/GuildManager.cs#GetGuild`
- **Inputs and outputs** — Crime category, guild membership, rank and RNG → rescue or normal plea
- **Dependencies** — FACT-012, CHAR, UI
- **Edge cases and interactions** — Check eligibility by enum index and whether rescue uses the same release effects as acquittal.
- **Design questions** — Which charges should guilds intervene in?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-012 — Guild rescue](../../design/systems/LAW/LAW-012.md)

## LAW-013 — Plea, debate and lie

- **Parent subsystem** — Court
- **Purpose** — Resolve player choice and conviction.
- **Existing implementation** — Guilty can halve ordinary fines and days. Not Guilty offers Debate or Lie, tallying Etiquette or Streetwise respectively. Acquittal chance is legal standing plus half the sum of live skill and Personality, clamped to 5–95. Failed defense can alter the fine.
- **Source** — `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#GuiltyNotGuilty_OnButtonClick`, `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#DebateLie_OnButtonClick`
- **Inputs and outputs** — Plea, skill, Personality, standing and rolls → acquittal or punishment
- **Dependencies** — CHAR-012, RULE-001, ECON, UI
- **Edge cases and interactions** — Acquittal refills vitals and restores some standing in this implementation. Verify fine debit timing in each conviction route.
- **Design questions** — How should plea choice change risk and punishment?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-013 — Plea, debate and lie](../../design/systems/LAW/LAW-013.md)

## LAW-014 — Banishment and execution reachability

- **Parent subsystem** — Court
- **Purpose** — Apply severe regional punishment.
- **Existing implementation** — Banishment sets regional flag bit 1, refills vitals and requests entrance reposition. An execution UI state exists and sets bit 2, but the sampled default selection assigns only 0 or 2 to punishmentType, so execution is not selected by that logic.
- **Source** — `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#HandleCourtLogic`, `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#DebateLie_OnButtonClick`, `Game/Entities/PlayerEntity.cs#Update`
- **Inputs and outputs** — Severe verdict → regional flag and release path
- **Dependencies** — WORLD, TIME, SAVE, LAW-008
- **Edge cases and interactions** — The source also describes execution as unavailable in classic with uncertainty. Check legacy saves containing severe flags.
- **Design questions** — Should severe sentences persist as regional restrictions?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-014 — Banishment and execution reachability](../../design/systems/LAW/LAW-014.md)

## LAW-015 — Prison time and release

- **Parent subsystem** — Court
- **Purpose** — Advance the clock and return the player to the world.
- **Existing implementation** — Prison counts down using real time and can accelerate with Back. At zero it advances game time by the full sentence, emits the end event and refills vitals. Release advances four more hours, clears the crime, can reposition at a random entrance marker and clears enemies.
- **Source** — `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#UpdatePrisonScreen`, `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#ReleaseFromPrison`, `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#PositionPlayerAtLocationEntrance`, `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#OnPop`
- **Inputs and outputs** — Sentence, UI timing and map context → elapsed time, released state and position
- **Dependencies** — TIME, MAGIC-008, CORE-020, WORLD, UI
- **Edge cases and interactions** — Spawn and normalization suppression flags affect catch-up. Verify missing locations, event ordering and every release route.
- **Design questions** — Which systems should advance during incarceration?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-015 — Prison time and release](../../design/systems/LAW/LAW-015.md)

## LAW-016 — Legal state across transitions and saves

- **Parent subsystem** — Persistence
- **Purpose** — Restore the charge and regional consequences.
- **Existing implementation** — SerializablePlayer stores current charge and region data and guards older region records. Classic startup imports region and crime data. PlayerEntity clears current charge on location exit and post-fast-travel handlers.
- **Source** — `Game/Serialization/SerializablePlayer.cs`, `Game/Utility/StartGameBehaviour.cs#StartFromClassicSave`, `Game/Entities/PlayerEntity.cs#PlayerGPS_OnExitLocationRect`, `Game/Entities/PlayerEntity.cs#DaggerfallTravelPopUp_OnPostFastTravel`
- **Inputs and outputs** — Native or classic save and movement events → restored or cleared charge and regional flags
- **Dependencies** — SAVE, CORE-014, WORLD, TIME
- **Edge cases and interactions** — Court-window state persistence and save restrictions during arrest need verification. Clearing a charge does not itself change regional flags.
- **Design questions** — What should survive a boundary crossing or reload?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

[LAW-016 — Legal state across transitions and saves](../../design/systems/LAW/LAW-016.md)

## Classic provenance and next review steps

- Classic save records provide region and charge inputs. Source comments identify changes to sentence reputation recovery, some release vital refills and accelerated prison countdown. Those comments establish DFU intent. Original court distributions, legal flags and guard behavior still require comparison.
- Start with attempted entry, theft and civilian assault. Follow charge assignment and regional standing separately through pursuit, surrender, trial and release. Include a rejected involuntary surrender, transformed crime suppression and a banished-region return.
- Review loan default and legacy saves independently. Verify guard counts and door/population geometry in Unity. The source trace samples offense routes and court states. Runtime behavior, complete crime-caller coverage and original parity remain open.
