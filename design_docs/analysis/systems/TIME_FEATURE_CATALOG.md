# TIME feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Source paths are relative to `Assets/Scripts/`. Symbols follow `#`. Complexity estimates review scope. Confidence rates the sampled source trace.

## TIME-001 — Calendar and classic time conversion

- **Parent subsystem** — Clock
- **Purpose** — Represent game dates and elapsed time.
- **Existing implementation** — DaggerfallDateTime advances seconds, derives season and date presentation, and converts to/from classic game minutes. New-character startup uses the classic start value.
- **Source** — `Utility/DaggerfallDateTime.cs#RaiseTime`, `Utility/DaggerfallDateTime.cs#ToClassicDaggerfallTime`, `Utility/DaggerfallDateTime.cs#FromClassicDaggerfallTime`, `Utility/DaggerfallDateTime.cs#SetClassicGameStartTime`
- **Inputs and outputs** — Seconds or classic minutes → date and calendar context
- **Dependencies** — CORE-011, SAVE, DATA
- **Edge cases and interactions** — Check rollover, precision lost in minute conversion and classic epoch fixtures.
- **Design decision** — Use a checked signed 64-bit timestamp in game milliseconds with fixed calendar units and a separate checked classic minute conversion.
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-15 (TIME-001-A01).

### My Intended Specification

[TIME-001 approved specification](../../design/systems/TIME/TIME-001.md)

## TIME-002 — Continuous and requested time advance

- **Parent subsystem** — Clock
- **Purpose** — Advance the clock during ordinary play.
- **Existing implementation** — WorldTime consumes a positive RaiseTimeInSeconds request and clears it, then adds Unity deltaTime times TimeScale each update. Travel and prison also call the date object directly.
- **Source** — `Internal/WorldTime.cs#Update`, `Utility/DaggerfallDateTime.cs#RaiseTime`
- **Inputs and outputs** — Scaled delta or explicit advance → current date
- **Dependencies** — CORE-016, LAW-015, SAVE
- **Edge cases and interactions** — Pause affects scaled delta while explicit advances use their own paths. Check competing advances in one update.
- **Design decision** — Use a moddable 12× ordinary calendar rate and one TIME-owned advance operation. An authorized activity can advance under its own suspension while independent blockers prevent new segments.
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-15 (TIME-002-A01).

### My Intended Specification

[TIME-002 approved specification](../../design/systems/TIME/TIME-002.md)

## TIME-003 — Calendar boundary events

- **Parent subsystem** — Clock
- **Purpose** — Notify systems when calendar fields change.
- **Existing implementation** — WorldTime compares current and previous fields for new hour/day/month/year. Dawn, dusk, midday, midnight and city-light events require arrival in the matching hour.
- **Source** — `Internal/WorldTime.cs#RaiseEvents`, `Internal/WorldTime.cs#RaiseOnDawnEvent`, `Internal/WorldTime.cs#RaiseOnCityLightsOnEvent`
- **Inputs and outputs** — Previous and current clock fields → boundary callbacks
- **Dependencies** — AV, WORLD, LOC
- **Edge cases and interactions** — A jump can skip named hours or land on the same hour/day field and miss a change callback. This path does not replay all crossed boundaries.
- **Design decision** — Detect crossings through the committed endpoint, group coincident markers, and refresh presentation from the destination state. Gameplay owners select their catch-up behavior under TIME-004.
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-15 (TIME-003-A01).

### My Intended Specification

[TIME-003 approved specification](../../design/systems/TIME/TIME-003.md)

## TIME-004 — Elapsed-time catch-up across systems

- **Parent subsystem** — Clock
- **Purpose** — Process simulated time after rest, travel or prison.
- **Existing implementation** — Time consumers have separate update policies. Effect broker catches up minute rounds with a cap. PlayerEntity has day and minute branches for world updates. Quest Clock and LoanChecker use their own checks.
- **Source** — `Game/MagicAndEffects/EntityEffectBroker.cs#Update`, `Game/Entities/PlayerEntity.cs#Update`, `Game/Questing/Clock.cs#Tick`, `Game/LoanChecker.cs`
- **Inputs and outputs** — Clock jump and flags → per-system progression
- **Dependencies** — MAGIC-008, QUEST-010, FACT-008, LAW-015, ECON-012
- **Edge cases and interactions** — Compare long jumps and suppression flags. Callback order and precise catch-up are fixture questions.
- **Design decision** — Coordinate owner-declared catch-up chronologically where order matters, apply explicit dependencies at simultaneous instants, and retain progress through bounded processing and recovery.
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-15 (TIME-004-A01).

### My Intended Specification

[TIME-004 approved specification](../../design/systems/TIME/TIME-004.md)

## TIME-005 — Climate and seasonal weather selection

- **Parent subsystem** — Environment
- **Purpose** — Select weather for geographic and calendar context.
- **Existing implementation** — Weather table exposes climate/season weighted selection. WeatherManager can poll current climate and initialize six climate-zone entries. A separate path uses the stored climate array for the current climate.
- **Source** — `Game/Weather/Weather.cs#ParseJsonTable`, `Game/Weather/Weather.cs#CompileOdds`, `Game/WeatherManager.cs#PollWeatherChanges`, `Game/WeatherManager.cs#SetClimateWeathers`, `Game/WeatherManager.cs#SetWeatherFromWeatherClimateArray`
- **Inputs and outputs** — Climate, season, tables and stored array → weather type
- **Dependencies** — WORLD-012, DATA, RULE, SAVE
- **Edge cases and interactions** — Check weather mode settings and invalid climate mapping. Stored-array and live poll paths can differ.
- **Design decision** — Retain one daily weather result per climate group using DFU's shared climate-array mapping and seasonal weights. Mods can add weather types, override profiles and use variable-duration schedules.
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-15 (TIME-005-A01).

### My Intended Specification

[TIME-005 approved specification](../../design/systems/TIME/TIME-005.md)

## TIME-006 — Weather transitions and interior context

- **Parent subsystem** — Environment
- **Purpose** — Apply weather and its local presentation.
- **Existing implementation** — SetWeather clears current weather then dispatches overcast, fog, rain, storm or snow behavior. It raises the change event before setting PlayerWeather.WeatherType. Separate transition handlers cover building, dungeon and exterior.
- **Source** — `Game/WeatherManager.cs#SetWeather`, `Game/WeatherManager.cs#SetFog`, `Game/WeatherManager.cs#OnTransitionToInterior`, `Game/WeatherManager.cs#OnTransitionToExterior`, `Game/PlayerWeather.cs#SetWeather`
- **Inputs and outputs** — Weather type and scene context → lighting, fog, precipitation and event
- **Dependencies** — AV, LOC, MOVE-026
- **Edge cases and interactions** — Cloudy skybox and smooth transitions are TODOs. Verify subscriber reads during event and restoring weather on exit.
- **Design decision** — Use local interior presentation with optional authored exterior weather cues. Blend live changes and prepare covered destinations before reveal. Publish committed weather and context before notifying consumers.
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-15 (TIME-006-A01).

### My Intended Specification

[TIME-006 approved specification](../../design/systems/TIME/TIME-006.md)

## TIME-007 — Sunlight, day/night and lighting

- **Parent subsystem** — Environment
- **Purpose** — Expose illumination to visuals and gameplay.
- **Existing implementation** — SunlightManager updates light intensity. WorldTime emits city light events. PlayerEnterExit tracks gameplay sunlight as daytime outdoors and outside prison. Weather adjusts sunlight scale and ambience.
- **Source** — `Game/SunlightManager.cs#Update`, `Game/WeatherManager.cs#SetSunlightScale`, `Internal/WorldTime.cs#RaiseEvents`, `Game/PlayerEnterExit.cs#Update`
- **Inputs and outputs** — Clock, weather and context → lighting and sunlight exposure
- **Dependencies** — AV, CHAR, MAGIC, LOC
- **Edge cases and interactions** — Visual brightness and gameplay exposure have separate paths. Check dusk, fog and transition ordering.
- **Design decision** — Use moddable daylight and city-light schedules, actor-specific exposure based on authoritative shelter context, and smooth lighting derived from committed state.
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-15 (TIME-007-A01).

### My Intended Specification

[TIME-007 approved specification](../../design/systems/TIME/TIME-007.md)

## TIME-008 — Regional holidays

- **Parent subsystem** — Environment
- **Purpose** — Identify date-sensitive local events.
- **Existing implementation** — FormulaHelper resolves holiday by date and region. PlayerEnterExit exposes holiday text and tracks whether a pending message still belongs to the current location. Identification pricing can use a festival override.
- **Source** — `Game/Formulas/FormulaHelper.cs#GetHolidayId`, `Game/PlayerEnterExit.cs#ShowHolidayText`, `Game/PlayerEnterExit.cs#Update`, `Game/Formulas/FormulaHelper.cs#CalculateItemIdentifyCost`
- **Inputs and outputs** — Time, region and location → holiday ID, notice or service input
- **Dependencies** — RULE-028, ECON-008, WORLD, UI
- **Edge cases and interactions** — Verify actual dates, message suppression after leaving and clock jumps into a holiday.
- **Design decision** — Present one classic-style notice per holiday and date on eligible arrival or day change. Mods can change triggers and presentation. Service owners determine benefits.
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-15 (TIME-008-A01).

### My Intended Specification

[TIME-008 approved specification](../../design/systems/TIME/TIME-008.md)

## TIME-009 — Rest eligibility and bed context

- **Parent subsystem** — Rest
- **Purpose** — Determine whether the player can sleep at the current site.
- **Existing implementation** — Rest checks outdoor town rules, ownership, rentals and allocated bed context. Illegal town camping can assign Vagrancy and request guards. Shared veto/threat checks are under CORE.
- **Source** — `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#CanRest`, `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#CheckRent`, `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#MoveToBed`, `Game/GameManager.cs#GetPreventedRestMessage`
- **Inputs and outputs** — Location, rental, ownership and restrictions → rest allowed, prompt or charge
- **Dependencies** — CORE-019, LAW-006, ECON-015, LOC, MAGIC
- **Edge cases and interactions** — Verify confirmation routes and expiry during sleep. Owned and rented access have different inputs.
- **Design decision** — Require a suitable site, current permission where applicable, and fresh threat and veto checks. Validate assigned bed placement and stop rental sleep at exact expiry.
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-009-A01).

### My Intended Specification

[TIME-009 approved specification](../../design/systems/TIME/TIME-009.md)

## TIME-010 — Timed rest, heal-until and loiter

- **Parent subsystem** — Rest
- **Purpose** — Run the selected time-advance mode.
- **Existing implementation** — Rest window distinguishes timed sleep, full rest and loiter. Update checks heal state or remaining hours, ticks rest and handles stop input. Sleep tick events apply only to sleep modes. Full healing accepts unrecovered magicka for NoRegenSpellPoints careers.
- **Source** — `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#Update`, `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#TickRest`, `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#IsPlayerFullyHealed`, `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#LoiterPrompt_OnGotUserInput`
- **Inputs and outputs** — Mode, hours and vitals → elapsed time and rest progression
- **Dependencies** — CHAR-021, RULE-008, MAGIC, UI
- **Edge cases and interactions** — Check time increments and no-regeneration termination. Verify loiter behavior independently from sleep.
- **Design decision** — Use moddable limits of 1–99 hours for timed sleep and 1–3 hours for loiter. Loiter has separate eligibility and grants no stock sleep recovery. Use stoppable pacing and at most ten game minutes per default segment, splitting at earlier required boundaries.
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-010-A01).

### My Intended Specification

[TIME-010 approved specification](../../design/systems/TIME/TIME-010.md)

## TIME-011 — Interruption and completion

- **Parent subsystem** — Rest
- **Purpose** — End rest safely and notify consumers.
- **Existing implementation** — Rest can stop on player death, healing, elapsed duration, encounter or an explicit stop. EndRest selects mode-specific feedback and rental-expiry handling. Completion popup can trigger skill advancement.
- **Source** — `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#EndRest`, `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#AbortRestForEnemySpawn`, `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#RestFinishedPopup_OnClose`, `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#RaiseOnSleepEndEvent`
- **Inputs and outputs** — Stop condition and rest state → end event, UI and skill check
- **Dependencies** — NPC-006, CHAR-013, MAGIC, CORE-019
- **Edge cases and interactions** — Check competing interruptions and whether a popup must close before advancement.
- **Design decision** — Settle due gameplay before recovery, preserve committed progress, and publish one terminal outcome. Apply eligible skill and long-sleep item-effect checks once, with moddable routing and feedback.
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-011-A01).

### My Intended Specification

[TIME-011 approved specification](../../design/systems/TIME/TIME-011.md)

## TIME-012 — Travel map search and destination choice

- **Parent subsystem** — Travel
- **Purpose** — Select a known destination.
- **Existing implementation** — Travel map displays location dots, tracks hovered locations and provides name search and picker routes with filters.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTravelMapWindow.cs#UpdateMapLocationDotsTexture`, `Game/UserInterfaceWindows/DaggerfallTravelMapWindow.cs#HandleLocationFindEvent`, `Game/UserInterfaceWindows/DaggerfallTravelMapWindow.cs#ShowLocationPicker`, `Game/UserInterfaceWindows/DaggerfallTravelMapWindow.cs#HandleLocationPickEvent`
- **Inputs and outputs** — Discovery, filters and player selection → destination
- **Dependencies** — WORLD-014, DATA-004, UI
- **Edge cases and interactions** — Check duplicate names, undiscovered places and filter differences between search and click.
- **Design decision** — Require exact disclosure for destination selection. Use moddable region-only base search, preserve distinct same-name sites, and preview stable site selections before separate confirmation.
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-012-A01).

### My Intended Specification

[TIME-012 approved specification](../../design/systems/TIME/TIME-012.md)

## TIME-013 — Route time estimation

- **Parent subsystem** — Travel
- **Purpose** — Estimate journey duration from terrain and options.
- **Existing implementation** — Calculator steps map pixels toward the destination, samples climate, accumulates ocean pixels and applies terrain, horse/cart and camping adjustments. Noncautious travel halves the accumulated minutes.
- **Source** — `Game/Utility/TravelTimeCalculator.cs#GetPlayerTravelPosition`, `Game/Utility/TravelTimeCalculator.cs#CalculateTravelTime`
- **Inputs and outputs** — Start, destination and travel options → time and ocean count
- **Dependencies** — WORLD, DATA-006, MOVE-016
- **Edge cases and interactions** — Test equal axes, same pixel and sea crossing. The stepping estimate and final teleport are separate paths.
- **Design decision** — Use moddable DFU timing modifiers and endpoint-correct traversal, with valid detours where required. Return a timed route with ocean statistics and support quest-authored estimation assumptions.
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-013-A01).

### My Intended Specification

[TIME-013 approved specification](../../design/systems/TIME/TIME-013.md)

## TIME-014 — Trip quote and departure checks

- **Parent subsystem** — Travel
- **Purpose** — Calculate fees and decide whether travel can start.
- **Existing implementation** — Trip cost uses duration and ocean count for inns and ship fares, with room and ship entitlement exceptions. Travel popup checks gold and exposes disease confirmation and option toggles.
- **Source** — `Game/Utility/TravelTimeCalculator.cs#CalculateTripCost`, `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs#BeginButtonOnClickHandler`, `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs#enoughGoldCheck`, `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs#ConfirmTravelPopupDiseasedButtonClick`
- **Inputs and outputs** — Travel options, quote state, disease and funds → confirmation or denial
- **Dependencies** — ECON, FACT-017, MAGIC, UI
- **Edge cases and interactions** — Cost depends on ocean count from the time estimate. Source notes classic lacks the negative inn-cost guard.
- **Design decision** — Itemize route-based charges, waivers and tender. Apply moddable departure restrictions and known-risk warnings, then revalidate material terms and payment before commitment.
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-014-A01).

### My Intended Specification

[TIME-014 approved specification](../../design/systems/TIME/TIME-014.md)

## TIME-015 — Fast-travel settlement and arrival

- **Parent subsystem** — Travel
- **Purpose** — Commit journey and apply arrival effects.
- **Existing implementation** — Travel deducts gold, raises pre-event, caches ship scene when applicable, resets vertical compensation and requests marker-based teleport. It advances time and suppresses imminent random spawns. Cautious travel restores vitals with magicka restrictions and adjusts late/early arrival to 07:10 unless sunlight restrictions take precedence. Post-event follows skill check and fade request.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs#performFastTravel`, `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs#DeductFastTravelGold`, `Terrain/StreamingWorld.cs#TeleportToCoordinates`
- **Inputs and outputs** — Confirmed quote, destination and character state → payment, clock, arrival request and events
- **Dependencies** — WORLD-003, CHAR-013, MAGIC-028, LAW-016, SAVE
- **Edge cases and interactions** — Vampirism or sunlight disadvantage delays daytime arrival to the dusk hour while retaining minute offset. Verify placement timing relative to post-event.
- **Design decision** — Settle accepted route time and applicable consequences, then commit safe placement, destination readiness and eligible completion effects before announcing arrival once.
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-015-A01).

### My Intended Specification

[TIME-015 approved specification](../../design/systems/TIME/TIME-015.md)

## TIME-016 — Mount and cart availability

- **Parent subsystem** — Transport
- **Purpose** — Expose local transport and travel modifiers.
- **Existing implementation** — TransportManager checks horse/cart ownership and toggles mount state. Travel estimator uses horse first, then cart, to choose movement modifier. MOVE handles controller size and movement.
- **Source** — `Game/TransportManager.cs#ToggleMount`, `Game/TransportManager.cs#HasHorse`, `Game/TransportManager.cs#HasCart`, `Game/Utility/TravelTimeCalculator.cs#CalculateTravelTime`
- **Inputs and outputs** — Items, current context and selection → mount or route modifier
- **Dependencies** — MOVE-016, ITEM, ECON
- **Edge cases and interactions** — Check usable transport after losing items and contexts where owned transport cannot be mounted.
- **Design decision** — Select horse, cart or foot by route eligibility. Requote changes before departure. Base arrival is on foot and preserves local mount preference. Support validated mod overrides.
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-016-A01).

### My Intended Specification

[TIME-016 approved specification](../../design/systems/TIME/TIME-016.md)

## TIME-017 — Ship access and return context

- **Parent subsystem** — Transport
- **Purpose** — Connect ship entitlement to movement and travel.
- **Existing implementation** — TransportManager has ship detection and transition handling. Bank manager supplies owned ship coordinates. Fast travel from a ship caches its scene before departure.
- **Source** — `Game/TransportManager.cs#IsOnShip`, `Game/TransportManager.cs#HandleTransition`, `Game/DaggerfallBankManager.cs#GetShipCoords`, `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs#performFastTravel`
- **Inputs and outputs** — Ship state, deed and destination → ship context or departure cache
- **Dependencies** — ECON-014, WORLD, SAVE, MOVE
- **Edge cases and interactions** — Verify ship entry/return and sold ship behavior with native saves.
- **Design decision** — Preserve the exact ship and its contents independently of each boarding visit. Keep the validated return anchor until authorized ashore placement commits.
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-017-A01).

### My Intended Specification

[TIME-017 approved specification](../../design/systems/TIME/TIME-017.md)

## TIME-018 — Time and weather restoration

- **Parent subsystem** — Persistence
- **Purpose** — Rebuild environment after loading.
- **Existing implementation** — SaveLoadManager restores date/time. WeatherManager responds to load and respawn and can reapply climate-array weather after GPS readiness. Classic import converts saved date and climate weather codes.
- **Source** — `Game/Serialization/SaveLoadManager.cs#RestoreDateTimeData`, `Game/WeatherManager.cs#SaveLoadManager_OnLoad`, `Game/WeatherManager.cs#UpdateFromClimateArrayCheck`, `Game/Utility/StartGameBehaviour.cs#StartFromClassicSave`
- **Inputs and outputs** — Saved date, climate and loaded world → resumed clock and weather
- **Dependencies** — SAVE, CORE-014, WORLD, MAGIC
- **Edge cases and interactions** — Check weather events during load and classic fog flag loss. Verify old data and listener timing.
- **Design decision** — Restore precise time, retained weather and supported work positions. Rebuild presentation from validated context before reveal, with zero elapsed time and no replay of settled consequences.
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (TIME-018-A01).

### My Intended Specification

[TIME-018 approved specification](../../design/systems/TIME/TIME-018.md)

## Classic provenance and next review steps

- Classic calendar conversion and climate weather codes have direct import paths. The travel cost clamp is a documented DFU difference. Weather presentation uses Unity systems and weather tables. Compare actual archive terrain/climate samples, classic travel outcomes and saved climate values before asserting parity.
- Start with ordinary time and a multi-day jump, comparing clock events, quest deadlines, effects and environmental state. Then trace interrupted rest, a cautious sea trip with sunlight restrictions and native save restoration. Include a rental expiring during rest.
- WORLD owns streaming and placement, CHAR owns recovery formulas and progression outcomes, ECON owns property and rental transactions, and LAW owns prison sentencing. Per-weather asset behavior, route fidelity, event timing and original-game comparison remain open.
