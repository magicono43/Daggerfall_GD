# WORLD-006 — Exterior location activation

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Let players explore and interact with exterior locations as their immediate surroundings become playable. Two towns can sit side by side within the same map pixel and retain their own buildings, actors and quest references. Modders can also place exterior content such as a large terrain formation without creating a town or other location record.

## Confirmed requirements

- **WORLD-006-D01.** Activate ready areas when required collision, interaction data, actors and triggers are available. Use WORLD-004 holds at unfinished boundaries.
- **WORLD-006-D02.** Resolve validated location and building records during assembly. Live doors, actors and navigation must satisfy their own readiness requirements.
- **WORLD-006-D03.** Rebuild live exteriors from authored content and durable owner state. Close affected live interactions on unload. Residency alone produces no discovery, quest progress or resets.
- **WORLD-006-D04.** Allow multiple independently identified exterior locations within one map pixel, with no fixed per-pixel count cap. Allow separately placeable exterior objects and terrain features outside the location system. Both are moddable.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-006-interview-decisions) records these decisions and approval of the complete specification. D04 amends the approved DATA-004 occupancy rule and the dependent WORLD-001 lookup rule.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. In `Assets/Scripts/Terrain/StreamingWorld.cs`, `UpdateLocations` schedules exterior updates for active terrain and raises the current location availability event. `UpdateLocation` creates a location object, building directory and city navigation, builds RMB blocks with optional yields, and raises a separate update event after assembly. `GetPlayerLocationObject` scans for a location object assigned to the current map pixel and returns the first match. These paths associate one exterior location with a terrain cell and can expose an object before all its blocks are built.

## Detailed rules and behaviors

1. Use the map pixel to find candidate exterior content. Each location has stable identity and authored placement within the world. Multiple valid records can share a pixel and activate independently. Resolve a specific destination, building or quest reference by stable identity within its scope. A pixel lookup can return several locations, so consumers that require one location need explicit selection or a validated spatial rule.
2. Accept mod-authored exterior locations and independently placed objects or terrain features. A feature can supply geometry, collision or presentation through its relevant owner without becoming a location, settlement entry, or discovery target by placement alone. Coordinate validation, content references and runtime budgets still apply. Detailed footprint and overlap rules belong to LOC and the affected gameplay owners.
3. Prepare areas against WORLD-004 demand. Publish an area as usable after its required geometry, collision and gameplay dependencies are coherent. Optional decoration and more distant parts can finish afterward. A large feature with required collision participates in the same readiness checks. Preserve approved arrival and movement boundaries when an area is unfinished.
4. Expose validated authored records independently of live scene readiness. Resolve live doors, actors and navigation against the current area and activation. Navigation accepts routes only with the required usable path. Treat unloaded, preparing and ready resources distinctly. A stale scene handle or completion cannot resolve a different location in the same pixel.
5. Retire exterior areas when their applicable residency and gameplay dependencies allow. Close affected live interactions and reconcile durable state through its owners before releasing live representations. On reactivation, restore state before exposing applicable interactions. Discovery, quest reactions, population rules and timed resets follow their own gameplay conditions.

## Relevant formulas, parameters and configuration

No per-pixel location cap or shared respawn formula applies. Authoring supports location identity, world placement and layout, and independent feature placement with relevant asset and gameplay data. Activation coverage and budget use WORLD-004/005. Concrete footprint schema, placement tools, overlap rules and activation granularity remain open.

## Required data

Stable location, scoped building and owner record IDs, authored geographic placement, spatial coverage, mod provenance and layout versions, terrain and frame bindings, area readiness dependencies, live activation identity, and durable records required by LOC, NPC, QUEST, ITEM and other owners.

## Inputs, outputs and events

- **Inputs** — Validated location and feature definitions, spatial demand, current terrain and frame, owner state, and readiness or retirement results.
- **Outputs** — Pixel candidate sets, stable record lookups, ready live resources, and explicit pending, unavailable, ambiguous or failed results where applicable.
- **Events** — Area and resource readiness, retirement and restore origin are distinguishable from geographic arrival and gameplay discovery. Consumers receive matching location and activation identity. Public APIs remain open.

## Cross-system interactions

- **DATA-004 and MOD** validate geography, stable identities and modded content. **LOC** owns layout, scoped records and spatial semantics.
- **WORLD-001/003/004/005** supply geography, arrival selection, readiness and terrain residency. **WORLD-007** coordinates loose object lifecycle.
- **NPC, QUEST, ITEM and SAVE** own durable state and restore behavior. **UI and travel owners** need explicit selection when several destinations share a pixel.

## Edge cases and failure conditions

- Adjacent towns in one pixel must resolve their own buildings and destinations even if names match. A pixel lookup alone cannot stand in for the player's live location.
- An unfinished block can leave a valid building reference without a usable door or navigation route. Required preparation failure follows WORLD-004 recovery.
- A modded feature can occupy the same pixel as both towns. Validate its collision dependencies before exposing paths that use them.
- Test repeated unload and reactivation, delayed callbacks and content replacement. Preserve durable state and prevent duplicate live actors, rewards or discovery reactions.

## Save/load considerations

Persist stable location and scoped owner references plus committed durable state. Rebuild scene bindings and readiness from current validated content. Multiple locations in one pixel stay independently resolvable during restoration. Missing or incompatible required references follow approved migration or CORE/SAVE recovery. Loading a scene does not itself replay entry, discovery or quest outcomes.

## Technical constraints

Target Godot 4.7.2. Spatial queries must handle multiple candidates and independent feature placements. Keep live scene references scoped to the activation that produced them. Coordinate coherent collision and state publication with WORLD-002/004. Spatial indexing, scene assembly, activation boundaries and mod formats remain open.

## Acceptance criteria

1. Two mod-authored towns and an independent terrain feature can occupy the same map pixel. A pixel query returns both towns, and destination lookup by stable ID resolves each town independently.
2. The feature can be placed and streamed without a location record. Paths that require its collision wait for readiness.
3. Ready areas support interactions while unfinished areas use the WORLD-004 gate. A valid building reference can resolve before its live door, and navigation waits for usable paths.
4. Unload and reactivation preserve owner-held state, close stale interactions, and produce no duplicate actors, rewards, quests or discovery from residency alone.
5. Save/load and delayed callbacks resolve the correct location and activation when multiple locations share a pixel.

## Outstanding questions

- LOC and related owners must define footprints, overlap validation and selection when a position falls within competing authored areas.
- Map and travel owners must define how players see and choose multiple destinations at one map pixel.
- DATA, MOD and terrain owners must define authoring formats and placement validation for independent features, including large collision-bearing features.
- WORLD-004/005 and LOC must verify activation granularity and budgets in dense modded areas.
