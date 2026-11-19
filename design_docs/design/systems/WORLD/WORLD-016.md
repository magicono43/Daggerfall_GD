# WORLD-016 — Exterior map layout and labels

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Help players navigate settlements with readable exterior maps, useful landmarks and trustworthy position markers. Map detail settings improve legibility without changing what the character knows.

## Confirmed requirements

- **WORLD-016-D01.** Offer a basic view with roads and ordinary building outlines and a detailed view with additional authorized exterior geometry and landmarks. Both honor the same discovery permissions for exact marks, names and aliases, including concealment at the precision required by policy.
- **WORLD-016-D02.** Open on the committed settlement, including from one of its interiors. Allow explicit selection of other known settlements, including ones sharing a pixel. If the player is elsewhere, omit the player arrow and indicate that they are elsewhere. For a known entrance associated with the current interior, show a distinct entrance marker.
- **WORLD-016-D03.** Prioritize the selected building and authorized active quest marks, reduce other labels at lower zoom, and allow inspection of visible buildings for their full authorized labels. Apply WORLD-015 naming precedence. Mods can define symbols and detail layers under the same visibility rules.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-016-interview-decisions) records these decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of local DFU 1.1.1. `Assets/Scripts/Game/ExteriorAutomap.cs#CreateExteriorLayoutTexture` builds layout textures from exterior block data. Original, Extra and All vary inclusion of additional building categories and ground flats. `CreateBuildingNameplates` checks discovery and quest context, `ComputeNameplateOffsets` adjusts label layout, and `UpdatePlayerMarker` updates position and facing. `OnMapPixelChanged` can rebuild the map from the new pixel's location.

## Detailed rules and behaviors

1. Compose a read-only view of validated LOC geometry and authorized WORLD-014/015 discovery data. Basic geometry can depict ordinary buildings without assigning undisclosed identities. Apply hidden-site restrictions to geometry, labels, icons, selection and inspection whenever those could reveal prohibited precision. A view change never commits discovery.
2. Select maps by stable settlement ID. On open, use committed settlement membership where a map is available and authorized. Outside a settlement, allow selection of known maps at the precision their grants permit. Missing usable layout or lack of an eligible map produces an explicit unavailable state. A same-pixel settlement change updates the committed context independently of any pixel event.
3. Draw player position and facing from the committed exterior pose when it belongs on the selected map. Indoors, identify a known associated exterior entrance with a distinct marker, separate from the live player arrow. If no authorized entrance can be resolved, indicate the indoor context without inventing a position. When viewing another settlement, indicate the player is elsewhere.
4. For visible marks, resolve labels through WORLD-015. Prioritize the selected building and authorized active quest marks during decluttering. Reduce lower-priority label density as zoom decreases, and allow inspection of a visible building to read its full authorized label when one exists. Apply the same visibility checks to inspection and any map metadata exposed to the player.
5. Refresh the view when the selected settlement, layout version, authorized marks, names, locale or relevant view settings change. Retain selection by stable ID where still valid. Obsolete work cannot replace the currently selected view, and expired temporary disclosures must stop appearing. Use compatible geometry under DATA-021 and validate mod layers and symbols before use.

## Relevant formulas, parameters and configuration

Project authoritative positions into the selected settlement's map coordinates. Exact projection, map extent, zoom thresholds, label collision and same-priority ordering remain open. Basic and detailed layers, authorized map symbols and readability settings are configurable through validated UI and mod contracts.

## Required data

Stable settlement and scoped building IDs, validated exterior geometry and map bounds, layout and content versions, committed pose and membership, authorized entrance reference, discovery and label grants, quest mark eligibility, view selection and display settings.

## Inputs, outputs and events

- **Inputs** — Open and selection requests, zoom and detail changes, committed context, authorized discovery and naming changes, layout and locale updates.
- **Outputs** — Settlement layout, authorized marks and labels, player or entrance marker where applicable, and explicit unavailable or elsewhere indicators.
- **Events** — Consume committed WORLD and owner changes to refresh presentation. Map redraw, detail switching and inspection do not write discovery state. Public APIs remain open.

## Cross-system interactions

WORLD-001/012/013 provide committed position and membership. WORLD-006 and LOC provide scoped geometry, building and entrance records. WORLD-014/015 and QUEST-014 provide disclosure and naming decisions. DATA-021, MOD, AV and UI govern compatible layout assets and presentation. SAVE restores authoritative knowledge and committed context.

## Edge cases and failure conditions

- Test settlements sharing a pixel, direct changes between them, and viewing one while standing in the other. Membership and explicit selection use stable IDs.
- Test indoor access with known and unknown entrances. A stale door or failed transition cannot place the marker at a provisional destination.
- Test hidden sites and partial clues in both detail views, including inspection, active quest priorities and mod layers.
- Test crowded labels, dormant custom labels, expired aliases, and delayed layout results after a selection change. Preserve authorized information and consistent view identity.

## Save/load considerations

Persist discovery, labels and player context through their owners. Rebuild map geometry, labels and marker projections from restored references. View preferences and any supported saved selection follow UI/SAVE. Cached textures and pending rendering jobs are runtime data. Native load does not grant map knowledge.

## Technical constraints

Target Godot 4.7.2. Use stable world and layout coordinates across rebases. Keep map data compatible with navigable geometry and interaction locations. Dungeon and interior map presentation belongs to LOC and UI. Rendering strategy, cache budgets and label layout algorithms remain open.

## Acceptance criteria

1. Basic and detailed modes vary authorized layout detail while preserving identical disclosure restrictions. Hidden or partial knowledge cannot be upgraded through inspection or a mod layer.
2. Opening selects the committed settlement where available. Known same-pixel settlements can be selected independently. Remote views omit the player arrow and indicate that the player is elsewhere.
3. A known indoor entrance uses a distinct marker. Unknown entrance and provisional or failed transition data cannot produce a false player position.
4. Crowded labels favor selected and authorized quest marks. Visible buildings can be inspected for their full authorized label using WORLD-015 precedence.
5. Streaming, reload and delayed rendering preserve the correct view identity and do not disclose or restore expired marks.

## Outstanding questions

- Define stock layer contents, zoom and label thresholds, marker symbols and controller interaction.
- Define map availability for partial settlement clues and which indoor entrance reference MOVE/LOC supplies.
- Calibrate layout and redraw performance, and validate mod layer permissions and resource budgets.
