# TIME-018 — Time and weather restoration

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-018-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended experience

Resume at the saved instant with the same retained weather. The first revealed view uses the restored location's fog, lighting and precipitation. A player loading in an inn during a storm can step outside into that storm if it remains active. Loading adds zero elapsed game time.

## Confirmed requirements

[TIME-018-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm restoration before reveal, migration and optional presentation fallback, and settlement of supported unfinished work without replay.

## Daggerfall Unity reference

In the local DFU 1.1.1 Release snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#RestoreDateTimeData` restores a whole-second clock through `FromSeconds`. `SerializablePlayer` saves the current weather type with player position. `Game/WeatherManager.cs#SaveLoadManager_OnLoad` applies saved outdoor weather and then overrides fog for building or dungeon context. `StreamingWorld_OnInitWorld` checks a load flag to avoid replacing that weather with its climate-array path. `PlayerEnterExit_OnRespawnerComplete` can independently force a poll after a climate change. These are static findings. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits. CORE-013 scopes this feature to native Godot saves.

## Saved data and time rules

- Preserve TIME-001's integer game-millisecond timestamp and TIME-002's retained remainder `0 ≤ f < 1` game millisecond. Restore both exactly. Existing absolute deadlines and accepted durations remain with their owners. Save/load wall time contributes zero. A compatible change to calendar rate affects future eligible advancement.
- Preserve retained TIME-005 weather for active and offscreen groups, including stable group, profile and weather IDs, compatible policy provenance and validity interval. A daily result covers its saved calendar day. A variable-duration result retains its selected type and exact exclusive end. Validate interval bounds and retain the position necessary for the owner's future schedule resolution. Offscreen schedule position may precede the saved clock where TIME-005 permits deferred resolution. Preserve it for approved catch-up when required.
- Save active operations only under an explicit activity and SAVE contract. Required data include the accepted operation, last committed endpoint, remainder where applicable, relevant weather interval and pending work position, and records of settled effects. Save settled state by default. Restore precise owner timing phase for hazards, effects and deadlines through the respective owners.
- Rebuild presentation targets, caches, blend progress, particles and audio from committed state and resolved assets. Presentation quality and optional asset availability cannot change gameplay exposure or overwrite retained weather.

## Restoration order

1. **Preflight.** Validate save and required schema, timestamp and remainder ranges, retained weather records and definitions, location references where detectable, and support for recorded unfinished work. Prepare migrations and applicable optional recovery before replacing the current session under CORE-013 and SAVE. Preserve the current session on preflight failure or cancellation.
2. **Restore under suspension.** In the prepared session establish the saved clock and retained weather before normal environment initialization can generate or publish a selection. Restore authoritative owner records, then resolve validated location, placement and exposure context. Weather queries use the retained group and interval for that location. Reject stale readiness or initialization work from another session or operation.
3. **Reconcile supported pending work.** Use TIME-004 and the owning feature to resolve required work from its recorded position. Apply only unsettled consequences. Loading itself performs no clock advance. If the supported activity resumes its remaining requested advance, it must do so through authorized TIME-002 progression and applicable suspension rules. A settled load emits no crossed boundary or hazard tick. A saved timestamp exactly at midnight or a weather transition does not repeat the committed result.
4. **Prepare and reveal.** Build the effective environment from the final committed time, weather and ready location. Apply interior precedence and any supported exterior cues under TIME-006. Resolve gameplay sunlight from authoritative location under TIME-007 and restore effect phases under MAGIC. Prepare the complete destination view while covered, then publish readiness through CORE-013 once required work is settled. Use a restore/readiness outcome for interested consumers. Scene rebuilding does not publish a historical weather change or elapsed-time event.

## Compatibility, configuration and failure

- Use DATA-003 resolved definitions and SAVE compatibility rules. Preserve a compatible saved selection and end time when future odds or duration parameters change. Apply new compatible policy to unresolved future intervals at their normal selection boundary. RULE-003 governs fresh randomness for unresolved work. A retained result cannot be reconstructed by drawing again.
- An explicit validated migration may map removed or changed required definitions while preserving committed time and relevant owner semantics. Missing optional visuals use a declared safe fallback and applicable CORE-013 disclosure. A fallback visual keeps the saved weather identity and gameplay context. If a required group, type, profile or environmental rule cannot be restored or migrated, fail preflight where detectable with an actionable explanation. Any late required failure uses CORE/SAVE safe recovery before reveal.
- Mods may provide validated migration maps, compatibility metadata and optional asset fallback. They cannot change the saved clock, discard required pending work or grant elapsed effects merely by rebuilding presentation. No additional clock or weather tuning parameter is introduced here. Exact serialization, definition version representation and public hooks remain implementation decisions.

## Inputs, outputs and cross-system interactions

Inputs include the selected native save generation, clock and weather records, resolved definition versions, validated location and placement outcome, and supported owner work positions. Outputs include validated or migrated state, preflight rejection or explicit recovery, reconstructed environment and an authoritative session-ready outcome. TIME-001–007 supply time, accounting, catch-up, weather and exposure. CORE-013 and SAVE coordinate handoff, WORLD/LOC supply location and placement, AV builds presentation, and MAGIC/QUEST/LAW and activity owners retain their own phase and consequence state.

## Acceptance criteria

1. A settled save restores a nonzero millisecond timestamp and fractional remainder exactly. No wall time or boundary effects are added, including at midnight. No retained weather is redrawn.
2. Loading inside during a storm shows correct interior fog and lighting on the first revealed frame. Eligible exterior cues use the retained weather. Exiting during the same interval shows that outdoor result. An outdoor load has correct weather and lighting immediately.
3. Compatible odds and duration changes preserve current and retained offscreen selections and their exclusive endpoints. A validated migration follows its declared rules. An optional missing visual uses the applicable fallback without changing gameplay. An incompatible required definition blocks preflight and leaves the current session intact.
4. Supported unfinished work reconciles before player control. Already committed charges, weather selections, deadlines and hazard ticks are not replayed. Restoration of exposure does not reset an active vulnerability's phase or grant a new initial tick.
5. Duplicate or stale world-ready work cannot overwrite restored weather or announce successful restoration twice. A late required error keeps the incomplete scene gated and enters explicit recovery.

## Consistency review and outstanding dependencies

The specification follows TIME-001–007, CORE-013, DATA-003, RULE-003 and MAGIC-008/028. Save schemas, mod compatibility metadata, supported activity snapshots and exact readiness integration remain owner dependencies.
