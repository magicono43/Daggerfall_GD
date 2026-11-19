# WORLD-015 — Building discovery and custom names

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Let players recognize buildings they have visited or identified and label them on the local map. A temporary quest alias can disappear when the quest ends while independently learned information and personal labels survive.

## Confirmed requirements

- **WORLD-015-D01.** Successful entry and deliberate exterior inspection grant permanent exact discovery where the building's policy permits. Explicit sources can grant permanent exact marks. Proximity and compass hints leave exact discovery unchanged. Hidden buildings can require authorization, and mods can change eligible triggers.
- **WORLD-015-D02.** Store authored names, authorized quest aliases and player labels separately. Where the mark is visible, display the player's label first. Clearing it shows the applicable name. Quest cleanup preserves independent discovery and player labels. A label stays dormant while its building mark is hidden.
- **WORLD-015-D03.** MOVE-020 owns failed lockpick history independently of discovery and names. Lockpicking grants map knowledge only when a separate authorized discovery trigger applies.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-015-interview-decisions) records these decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Internal/PlayerGPS.cs#DiscoverBuilding` attempts current settlement discovery, then records a building within the location's pixel-keyed discovery record. It can use an override or resolve quest-related naming. `UndiscoverBuilding` supports residence and name checks and protects certain guild hideouts from removal. `SetDiscoveredBuildingCustomName` and `SetLastLockpickAttempt` both update the discovered-building record. Callers include `Game/PlayerActivate.cs`, `Game/PlayerEnterExit.cs`, `Game/TalkManager.cs` and quest cleanup. Findings are from static inspection.

## Detailed rules and behaviors

1. Resolve the building by stable location identity and its scoped building identity under LOC. The pixel, display name and live door handle are lookup or presentation data. Towns sharing a pixel can independently contain buildings with identical local keys.
2. Commit a permanent exact mark on successful entry or validated deliberate exterior inspection when policy permits. A failed or cancelled entry grants nothing from the entry trigger. A previously completed inspection or authorized reveal retains its own outcome. Use NPC-020 and QUEST-014 for direction, exact marks and source authorization. A building grant identifies its parent for local-map placement. Any separate settlement reveal requires WORLD-014 authorization.
3. Retain independent grants and their precision and duration. Quest and service sources may authorize a mark or alias within their scopes. Cleanup withdraws only the applicable grant or alias. Independently earned knowledge remains effective. Retry of the same committed disclosure reuses its outcome.
4. Allow the player to set or clear a custom label for a visible discovered building. Display the custom label first on its visible mark, then an applicable authorized alias, then the authorized authored or derived name. A personal label cannot expose a hidden mark or authorize a quest alias. Preserve dormant labels by stable identity and restore them when visibility returns. Name refresh updates its own layer while preserving the other layers.
5. Door access and locking remain under MOVE-020. Rediscovery, alias changes and map cleanup have no effect on failed-attempt history or retry eligibility. Only approved attempts change that history.

## Relevant formulas, parameters and configuration

Configure discovery eligibility, source precision, retention and applicable naming policies through validated content. NPC-020 owns its hint odds. MOVE-020 owns failed-attempt thresholds. Exact alias precedence among simultaneous eligible aliases and custom-label input limits remain open.

## Required data

Character identity, stable location and scoped building identity, definition and layout version, discovery grants and source IDs, precision and retention, authored or derived names, authorized aliases, optional player label and committed reveal identity. MOVE retains its own lockpick data.

## Inputs, outputs and events

- **Inputs** — Committed entry, validated inspection, authorized reveal, alias lifecycle, custom-label input, content refresh and native restore.
- **Outputs** — Effective building discovery, visible label when authorized, unchanged or explicit unavailable result.
- **Events** — Publish committed discovery and label changes to the local map. Map redraw and name lookup have no independent gameplay effects. Exact public APIs remain open.

## Cross-system interactions

LOC and WORLD-006 provide scoped building records and live readiness. WORLD-013/014 provide committed boundary facts and settlement discovery. NPC-020 and QUEST-014 govern authorized disclosure and temporary marks. MOVE-020/026 own door attempts and entry. UI presents labels and map marks. DATA/MOD provide validated content and SAVE handles durable state and compatibility.

## Edge cases and failure conditions

- Test reused building keys across towns sharing a pixel, building renames, moved quest subjects and multiple entrances to the same building.
- Test removal of a temporary mark with and without an independent permanent grant. A dormant label remains hidden until visibility returns.
- Test failed arrival after a completed lockpick attempt, or renaming after a failed pick. Retry eligibility follows MOVE-020.
- Test missing, stale and ambiguous references. Do not bind an alias or label to another building based on its name or pixel.

## Save/load considerations

Persist durable discovery grants and player labels, supported temporary marks and aliases, and needed disclosure outcomes. Use stable references and validated migration or recovery for changed layouts. Rebuild visible labels from restored grants and current authorized naming data. Restore failed lockpick history through MOVE independently. Loading does not replay discovery, entry or attempts.

## Technical constraints

Target Godot 4.7.2. Keep record identity, authorization and presentation coherent across streaming and content changes. Use the applicable LOC compatibility contract for building identities. Exact storage, local-map UI and text validation remain open.

## Acceptance criteria

1. Eligible inspection and committed entry grant a permanent exact mark for the correct building. Proximity, compass hints and failed entry do not grant one. Hidden sites honor authorization.
2. Same-pixel towns and reused building keys remain distinct. A renamed building preserves its personal label and earned discovery.
3. A visible mark shows its custom label first. Clearing it exposes the applicable authorized name. Temporary cleanup preserves independent grants and dormant labels.
4. Changing visibility or names does not alter failed lockpick history. Lockpicking alone does not reveal the building.
5. Native load restores effective visibility, labels and independent lock history without replaying owner effects.

## Outstanding questions

- Define stock inspection interactions and hidden-building profiles with LOC, NPC and QUEST.
- Decide precedence among simultaneous aliases and the custom-label input and display limits.
- Verify stable building migration and local-map rendering, including dormant labels and same-pixel settlements.
