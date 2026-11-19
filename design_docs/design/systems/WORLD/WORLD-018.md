# WORLD-018 — World and discovery restore

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Restore the player's location, movement context and earned map knowledge from a native save. Saving leaves the live map unchanged. Loading a compatible save returns the player to a coherent world with the same authorized discoveries and personal labels.

## Confirmed requirements

- **WORLD-018-D01.** Capture committed discoveries, applicable temporary grants and labels through a read-only snapshot. Rebuild map and streaming caches and reconstruct the scene origin from authoritative saved position and context.
- **WORLD-018-D02.** Resolve missing required references through validated migration. Reject unresolved required references during preflight where detectable and preserve the current session. Allow disclosed recovery that retains missing map-only records inactive for possible later reactivation after validation.
- **WORLD-018-D03.** Preserve earned knowledge when the same site moves through a validated content change. Render it at its current authorized position. Validate saved placement and active quest references separately. Mods can supply explicit supported migrations.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-018-interview-decisions) records these decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. Paths are relative to `Assets/Scripts/`.

- `Internal/PlayerGPS.cs#GetDiscoverySaveData` prunes discovered buildings whose display name matches the localized generic residence label, then returns the live dictionary. `RestoreDiscoveryData` adopts supplied records and removes legacy entries with a zero pixel ID.
- `Game/Serialization/SaveLoadManager.cs` restores vertical world compensation for the saved interior context and restores discovery or clears prior-session discovery if the payload is absent. It then prepares position restoration through `PlayerEnterExit`. `Game/ExteriorAutomap.cs#SetExteriorAutomapStateFromLoadGame` provides a separate map refresh path.

## Detailed rules and behaviors

1. At an eligible SAVE boundary, capture a coherent generation of committed coordinates, context and exploration state. Read discovery grants, sources, authorized precision, retention and player labels without altering live records. Carry supported temporary grants and operation outcomes as required by their owners. Apply existing save admission rules during unresolved placement, arrival or other transitions.
2. During CORE-013 preflight, validate coordinate and content compatibility, required site and layout references, and supported variant selections under DATA-024. A reference is required if placement, an active quest or another gameplay obligation depends on it. Resolve changed required references with validated mappings and owner checks. Reject a preflight failure before replacing the current session.
3. For a missing record used only for map knowledge or a personal label, allow owner-supported recovery with disclosure before replacement. Retain the inactive record with original identity and relevant provenance. Carry it through subsequent eligible saves. Reactivate it only after the intended identity, disclosure rights and current content validate. A label alone grants no visibility, and an expired temporary grant stays expired. A record used by required gameplay cannot use this optional recovery.
4. For a validated move of an unchanged site identity, retain earned knowledge and project it at the site's current position at the authorized precision. Check saved pose, layout and quest binding separately. A moved site does not carry the player automatically or disclose a newly assigned quest target. Resolve name or coordinate collisions through stable identity and explicit validated migration.
5. After successful preflight, reconstruct the required world context, selected layout, origin, terrain and geometry. MOVE-027 validates the saved pose and movement state within its approved correction rules. Restore discovery and resolve effective visibility before dependent gameplay resumes. Rebuild exterior map and streaming views from restored authoritative state. The restore establishes current context without replaying entry, discovery, quest reactions or new-character defaults. Late required failures use CORE-013 recovery.

## Relevant formulas, parameters and configuration

Use versioned coordinate conversions under WORLD-001/002. No new gameplay formulas or placement tolerances apply. Supported mod migrations declare source and target identities, applicable versions and any owner-approved mapping of coordinates or layout. Recovery disclosure and save compatibility follow CORE and SAVE.

## Required data

Stable character, world, location and scoped building IDs, saved position and movement support context, coordinate and content versions, required layout or variant references, discovery grants and provenance, applicable retention and reveal progress, personal labels, and any validated recovery or migration results.

## Inputs, outputs and events

- **Inputs** — Eligible snapshot request, prepared save generation, validated active content, migration and optional recovery decisions, and geometry and placement outcomes.
- **Outputs** — Coherent save snapshot, preflight rejection, disclosed inactive optional records or validated restored context and map knowledge.
- **Events** — Restore publishes owner readiness and the enclosing CORE outcome. Map rebuild and discovery reconciliation do not emit live entry or reveal effects. Public APIs remain open.

## Cross-system interactions

- **CORE-007/013 and SAVE** coordinate admission, preflight, consistency, consent and recovery. **DATA-004/006/024 and MOD** supply stable geography, compatibility and variant contracts.
- **WORLD-001/002/004 and MOVE-027/LOC** reconstruct coordinates, origin, geometry, placement and movement context. **WORLD-012/013** establish geographic membership without live crossings.
- **WORLD-014/015/016, QUEST and UI** restore authorized knowledge, labels and applicable temporary grants, and rebuild derived views. Quest and other gameplay owners validate required references and retained outcomes.

## Edge cases and failure conditions

- Test saving with a discovered unnamed building, a dormant label and a temporary mark. Snapshot capture must not prune or alter live state.
- Test two locations in one pixel and reused scoped building keys. Missing references must never resolve to a neighboring site by pixel or name.
- Test a missing quest or placement dependency versus an optional map-only record. Retain the latter inactive through a subsequent save and validate it when content returns.
- Test moved sites, changed interior layouts and a saved pose captured before an origin shift. Knowledge and valid placement have independent compatibility checks.

## Save/load considerations

Persist committed authoritative records and supported inactive map history in a consistent native SAVE generation. Derived geometry, streaming slots, map textures and live scene handles are rebuilt. Preserve source precision, duration and identity for applicable grants. Reconcile current visibility against restored game time and owner state before exposing the map. Required preflight failures preserve the old session, and late failures keep gameplay behind the existing recovery gates.

## Technical constraints

Target Godot 4.7.2. Use versioned native records and coherent owner-state boundaries. Exact serialization, migration tooling and reload ordering remain SAVE and owner dependencies. Coordinate and placement compatibility must be validated independently of discovery identity.

## Acceptance criteria

1. Saving preserves the live map and its records. Loading rebuilds derived views and streaming from authoritative state without replaying discovery or entry.
2. A missing required reference succeeds only with validated migration or other applicable owner resolution. An unresolved preflight failure leaves the current session intact.
3. Disclosed recovery retains a missing map-only discovery or label inactive through later saves. Validated compatible content can reactivate it with the correct permissions.
4. A validated moved site retains earned knowledge with its authorized location and precision. Separately validate saved placement and quest targets.
5. Restore actual supported pose and context after origin reconstruction. Context and discovery are coherent before dependent gameplay resumes.

## Outstanding questions

- Define the native record and inactive-history schemas, migration interfaces and recovery disclosure with SAVE, DATA and MOD.
- Define dependency checks that distinguish map-only records from gameplay-required links across owners.
- Verify changed site, variant and interior layouts and coordinate-version migration with representative native restore fixtures.
