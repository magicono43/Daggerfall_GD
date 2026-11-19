# DATA-004 — Regions, locations and map identity

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Provide consistent region/location identity and geographic lookup for maps, quests, travel, world construction and saves. Preserve references when names, list order or authored geography change without treating identity as proof that an old saved layout remains compatible.

## Intended player experience

A place remains the same referenced place when renamed or validly moved by content. Map, quest and discovery references agree about its identity. Invalid conflicts and missing destinations produce explicit failures rather than silently selecting another place. Original geography and discovery defaults form the verified baseline, with explicit supported overrides.

## Confirmed requirements

DATA-004-D01–D09 in the [decision log](../../GAMEPLAY_DECISIONS.md) establish stable IDs and classic mappings, replacement and addition rules, conflict rejection, duplicate display names with ID-based references, separate authored and current discovery, validated geographic overrides, moved-location resolution and explicit missing-reference failure. WORLD-006-D04 supersedes the original single-location occupancy rule.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `API/MapsFile.cs#GetMapPixelID`: computes `mapPixelY * 1000 + mapPixelX`. `GetPixelFromPixelID` reverses that representation.
- `MapsFile#MapPixelToWorldCoord` converts to native classic units using `X = mapPixelX * 32768`, `Z = (499 - mapPixelY) * 32768`; `WorldCoordToMapPixel` uses integer division and the inverse axis convention. These are classic conversion observations, not approved Godot units or universal out-of-range behavior.
- `Utility/ContentReader.cs#EnumerateMaps` lazily builds summaries keyed by `MapId & 0x000fffff`, retaining full `MapId`, region/location indexes and classifications separately. It links classic quest location IDs to summary keys. Collision handling logs an error after dictionary insertion exceptions; this can leave partially populated indexes.
- `ContentReader#GetLocation`, `HasLocation` and `GetQuestLocation` provide region/name or index, coordinate, and classic quest-ID lookup paths. The source notes classic quest location ID differs from coordinate-derived map ID and is not available for every location.
- `EnumerateMaps` copies `mapTable.Discovered` but has a TODO for forgotten graveyards that start discovered in classic. Source inspection alone does not establish the complete correct initial discovery set.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static observations only; original-data fixtures and runtime behavior have not been verified here. Source remains unchanged.

## Detailed rules and behaviors

### Durable identity

Assign stable region/location IDs independently of display names, array positions and coordinates. Maintain explicit mappings from applicable classic identifiers to these IDs. Different classic identifier kinds must remain distinguishable: full map values, coordinate-derived keys and quest location IDs are not interchangeable. Absence of a classic quest-ID mapping must not make an otherwise valid location nonexistent.

Renaming, list reordering or moving a location does not alone create a new identity. Explicit replacement retains the replaced location ID; adding a location requires its own unused ID. Adding with an existing ID is invalid under DATA-003. Preserve compatible original identifiers through mappings rather than inventing requirements for a universal numeric ID format. New package identity/allocation conventions remain technical contracts to define.

### Geography and occupancy

Preserve original region membership, location coordinates and location/dungeon classifications as the baseline, allowing explicit validated content overrides. Internal Godot units and transforms may differ while resolving to the intended classic places. WORLD owns runtime coordinate representation; DATA owns interpretation/mapping of source geography.

The user removed the one-location-per-pixel limit on 2026-11-14. A pixel may contain any number of separately identified exterior locations, including mod-authored additions. Exterior features such as large terrain formations may also share the pixel without being registered as locations. The geographic pixel is a spatial index. Stable IDs identify specific locations. See [WORLD-006-D04](../../GAMEPLAY_DECISIONS.md#world-006-interview-decisions).

### Lookups and names

Gameplay, quests and saves reference stable IDs. Provide geographic lookup and explicit legacy-ID resolution without substituting names for identity. Display names may repeat; name searches may return multiple candidates and must not silently select the first ambiguous result. Localization changes presentation rather than durable identity.

Stable location references resolve to current authored position and region after a valid content change. Existing quest/discovery references continue identifying that place. This does not automatically move a saved player, rebuild a compatible old interior, retarget arbitrary saved coordinates, or translate every quest's stored spatial state; SAVE, LOC and QUEST retain those owner-specific validations.

Missing stable/legacy references produce explicit failure. Do not substitute a similarly named location or nearby pixel. Consumers decide rejection or an explicitly approved fallback. A valid pixel without a location is distinguishable from malformed data or unavailable source under DATA-002. Exact query/result representation remains deferred.

### Validation and publication

Validate required identity/geographic indexes before actual main-menu entry, including final resolved content after DATA-003 configuration changes. Reject duplicate stable identities and ambiguous classic-ID mappings. An explicit valid replacement of the same identity is allowed. Publish required indexes only after successful validation.

Apply DATA-003's contribution ordering, operation validation, whole-contribution rejection and explicit recovery where applicable. Later-source precedence does not authorize keeping two distinct locations at one pixel or unresolved required references. Required classic reader/index failure retains DATA-001/002 recovery; it cannot be bypassed as an optional patch.

Deleting a location while leaving required definition references unresolved invalidates the resolved content. Independently, a valid configuration may be incompatible with an older save referencing removed content; SAVE owns that decision and must receive the missing identity rather than an automatic substitute.

### Discovery defaults and character state

Authored initially-discovered status belongs to location definitions. Current discovery belongs to the character/session's owner and is stored/restored through its save contract. New characters receive the authored defaults; loads restore that character's discoveries rather than resetting them from current definitions.

Verify original defaults, including forgotten graveyards, against suitable original-data/behavior evidence. Do not treat DFU's copied summary flag as complete. Exact classic defaults, how a save encounters newly added definitions, discovery triggers and map visibility rules remain WORLD/UI/SAVE contracts. DATA supplies defaults and stable identity without owning all discovery gameplay.

## Relevant formulas and parameters

There is no fixed per-pixel location count cap. Classic reference transforms are documented above. Supported bounds, axis conventions, rounding and boundary checks require WORLD coordinate fixtures.

## Required data

Stable region/location IDs; classic-ID mapping kind/value/scope; region membership; authored map coordinates; full source map identity where needed; location/dungeon classifications; authored names/localized presentation keys; initial discovery defaults; source/package provenance and validated resolved indexes. Character discovery, saved player pose and live world state remain outside shared definitions. Exact ID encoding, allocation and complete source field mapping remain technical dependencies.

## Inputs, outputs and events

Inputs include classic records, validated content changes and queries by stable ID, legacy ID, pixel or name. A pixel query returns zero or more locations. Queries that require a specific location use stable identity or an explicit selection rule. Outputs also include explicit missing, ambiguous, invalid and unavailable outcomes.

## Cross-system interactions

- DATA-001/002 provide basic source validation, required-reader/index readiness and record-failure distinctions. DATA-003 supplies deterministic contribution resolution and pre-menu candidate rebuild/lock behavior.
- WORLD owns runtime geography, coordinates and discovery gameplay/state where assigned; LOC owns layout construction and local state. Both consume stable definitions without treating display names as keys.
- QUEST binds locations through stable IDs and explicit legacy conversion; its own saved coordinates, resources and missing-reference recovery remain QUEST-owned.
- UI maps/searches use definitions and localized names without assuming name uniqueness. ECON/TIME/travel consumers resolve destinations through the same identity/geography contract; their formulas and eligibility rules are not defined here.
- SAVE stores durable references and character discoveries, validates content compatibility and decides migrations. CORE-010's safe identity/restoration rules and CORE-011's stable opening-location reference remain binding.
- MOD supplies package identities and resolved order. Domain additions and replacements must satisfy identity, geography and reference validation.

## Edge cases and failure conditions

- A rename or reordered source table preserves identity and references. Duplicate names return ambiguity/candidates without choosing one arbitrarily.
- A valid moved location preserves identity/discovery references but may invalidate an old saved interior or pose. That compatibility requires owner validation.
- Two distinct locations at one pixel, an add reusing an ID, or one classic key ambiguously resolving to multiple locations fails required index validation. No first/last dictionary insertion silently wins an invalid collision.
- A replacement changing coordinates must still satisfy geography and reference validation after final resolution. Publish the resolved index only after validation.
- A location without a classic quest ID remains addressable through its stable ID and supported other lookups.
- Removing required referenced content invalidates the configuration. An older save can independently reference missing content; propagate failure rather than substituting by name or proximity.
- Invalid coordinates, boundary conversions or unsupported source classifications must be validated under explicit format/domain rules, not interpreted through accidental integer truncation. Exact handling remains a required technical contract.
- Loading discovery state does not rerun new-character defaults and reveal undiscovered places merely because authored defaults changed.

## Configuration and balancing options

Explicit content overrides may change geography, classifications and defaults within validated schemas. No player-facing toggle for bypassing identity collisions or enabling multiple locations per pixel is approved. Discovery balance and travel/map rules belong to their owners; this feature adds no automatic reveal or relocation mechanic.

## Save/load considerations

Use stable region/location references rather than names, table positions or transient scene handles. Preserve per-character discoveries across renames/moves when identity remains valid. Character loads do not change DATA-003's locked content configuration or source selection. Save versioning, missing-content recovery, migrations, newly added discovery defaults and compatibility with moved/replaced layouts remain SAVE/domain dependencies; stable IDs alone are insufficient evidence of compatibility.

## Technical constraints

Target engine is Godot 4.7.2. Keep source conversions explicit, definition indexes read-only to normal consumers, and mutable discovery/session state separately owned. Publish a coherent index for the current content. Durable identity is independent of pixel membership. Concrete registries, key formats, engine-space coordinate math and APIs remain open.

## Acceptance criteria

1. Stable region/location IDs survive display-name changes and table reordering, with explicit distinguishable classic-ID mappings.
2. Explicit replacement preserves identity; additions require unused IDs. Renaming/moving alone does not create a new identity.
3. Multiple valid locations in one pixel are independently resolvable by stable ID and appear in the pixel's location results.
4. Duplicate names are allowed. Authoritative references use IDs; ambiguous name searches do not silently select a first match.
5. Classic geography/classifications form the baseline; supported explicit overrides validate before publication. Coordinate conversions resolve intended places under verified bounds/axis rules.
6. Duplicate identities and ambiguous classic mappings fail before main-menu entry. Partial required indexes never publish as ready; DATA-002/003 recovery remains truthful.
7. A moved location resolves to current authored geography by stable ID without automatically relocating saved players or certifying old interiors.
8. Missing references return explicit failure without name/proximity substitution. Required-definition dangling references invalidate configuration.
9. New characters receive verified authored discovery defaults, including appropriate classic forgotten-graveyard handling. Loads restore character discovery rather than reapplying defaults.
10. Original source files remain unchanged, content lock/restart rules remain intact, and older-save compatibility is validated by SAVE/LOC/QUEST as applicable.

These are future verification criteria. No implementation, original-data fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–003 and approved CORE identity/session/startup/load contracts, particularly CORE-010, CORE-011 and CORE-013. No contradiction identified. Conflict rejection respects DATA-003's explicit operation rules and whole-contribution recovery. Required indexes follow DATA-002's before-menu gate. Stable identity does not imply a universal ID allocator or replace SAVE compatibility checks. The future multi-location possibility is an extension goal, not approval to implement that behavior now.

## Outstanding questions and approval

Open dependencies include stable-ID allocation and classic mapping scopes, definition schemas, verified original geography and discovery defaults, coordinate fixtures, discovery persistence, and compatibility for changed content. Detailed same-pixel map and travel selection, footprint and overlap rules, and migration remain with the relevant owners.

The user approved v1 on 2026-11-05 under DATA-004-A01. The user amended the pixel occupancy rule on 2026-11-14 under WORLD-006-D04. See the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).
