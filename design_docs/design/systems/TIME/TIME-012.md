# TIME-012 — Travel map search and destination choice

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-012-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Let players find and preview known destinations without revealing undiscovered locations. A player searching for a familiar name in Wayrest sees Wayrest results. Sites with similar or identical names remain distinguishable where the character knows enough to distinguish them. Selecting a site prepares a preview. Travel starts only through a separate confirmed operation.

## Confirmed requirements

[TIME-012-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm exact-disclosure eligibility, base region-only search with moddable behavior and UI, and stable-ID selection with a separately confirmed trip.

## Daggerfall Unity reference

Static inspection of the local DFU 1.1.1 Release snapshot. In `Assets/Scripts/Game/UserInterfaceWindows/DaggerfallTravelMapWindow.cs`, `UpdateMapLocationDotsTexture` and `checkLocationDiscovered` support map disclosure. `FindLocation` searches the current region with near matches and checks visibility. `GetCurrentRegionLocalizedMapNames` keeps the first entry for a duplicate localized name. `HandleLocationFindEvent` highlights a single match or opens a picker. The `GotoPlace` path opens the destination region and sends a localized name through the search path. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Disclosure and filters

- Consume effective per-character disclosure from WORLD-014 and authorized quest disclosure from QUEST-014. Exact grants, including valid authored starting grants, permit destination selection while active. Partial grants can render only their authorized names or areas. They cannot produce an exact pin, distance, route preview or selectable result. A hidden site's data must not leak through suggestions, counts, sorting, search timing responses designed to indicate hidden matches, or error text.
- Apply user-selected type filters consistently to selectable pins, name results and the manual location picker. Show which filters are active. Filtering changes the view without changing discovery or a site's underlying eligibility. An explicitly authorized journal shortcut can select its exact site independently of a manual view filter. If necessary, temporarily reveal just that selection in the travel preview without granting discovery or changing saved filters.
- Unique location identity is independent of name, shared map pixel or localization. Several disclosed sites on one pixel remain independently selectable, using a picker when the map click is ambiguous. Display disclosed region and type for ambiguous results. Where those labels coincide, use other disclosed distinguishing information if available. Ambiguity must not result in an arbitrary selection.

## Name search and preview

1. Base search uses the open region. Changing regions changes the search scope. A matching name in another region appears when that region is open. The base UI does not offer a global search.
2. Match localized names and supported aliases under the active language's text rules. Rank exact matches first. Place prefix and near matches after exact matches, with deterministic tie ordering using visible labels and stable site identity. Keep separate result rows for distinct IDs even when their text matches. Validate and bound search work and result presentation. An empty query performs no implicit selection. A result cap must be evident and let the player narrow the search.
3. Map clicks, search results and authorized journal shortcuts resolve stable site IDs directly. A journal shortcut uses its authorized site reference and does not search by name. If the shortcut grants only partial precision, show only that precision and do not open an exact trip preview. Recheck disclosure against current state when the destination is selected, when quotes are refreshed and before confirmation. An exact grant expiring or being revoked invalidates travel only if independent valid grants no longer supply exact precision.
4. Opening a preview neither spends resources nor advances time, moves the player, or declares discovery. A selected site can be known while a trip is temporarily unavailable. TIME-013 and later travel owners supply estimates, quote validation, arrival eligibility and execution. Confirmation passes the selected site ID and current validated request context, with separate revalidation by the committing owner.

## Configuration, data and interfaces

- Support validated mods that change search scope, matching, ranking, aliases, filters, map presentation and travel UI. A mod can add cross-region search. Cross-region results preserve site identity and display authorized region context, so same-name sites can be distinguished. UI and search extensions consume authorized data and observe the same confirmation and discovery rules. Changing presentation alone grants no discovery or admission.
- Required data include stable region and site IDs, localized names and approved aliases, type, effective disclosure and its source, active filter and region context, and any authorized quest reference. Inputs include map clicks, queries, filter and scope changes, journal selection and confirmation. Outputs include disclosed markers and results, selected site, preview request, and clear no-match, unavailable or invalid outcomes. No numeric gameplay balance formula applies. Public API, search extension schema and ranking weights remain implementation decisions.

## Cross-system interactions, save/load and failures

- [WORLD-014](../WORLD/WORLD-014.md) owns discovery and precision. DATA-004 supplies location records and identity inputs. QUEST-014 and QUEST-018 own authorized quest disclosures and journal context. UI and CORE-018 own map entry and input. TIME-013 and later travel features own quotation, payment, advance and arrival. DATA-003 governs resolved mod definitions and validation.
- Persist discovery through WORLD and disclosure sources. Treat the current query, result list and unconfirmed preview as transient. An owner-supported UI restore rebuilds from current authorized data and never automatically confirms travel. Changed or missing site definitions follow validated DATA/SAVE recovery. An invalid or stale selection cannot fall back to another site sharing its name.
- Revalidate selection if region data changes, a modded provider fails, or a grant expires. Distinguish an unavailable formerly disclosed destination from an invalid lookup without exposing hidden site details. On failure leave the player at the current location with no charge or time advance. Preserve independent discovery grants when a temporary reveal disappears.

## Acceptance criteria

1. A search for an identical name in Wayrest and Sentinel returns only the active region's matches in the base UI. A modded cross-region search can show both with their distinct IDs and region labels. Exact matches rank ahead of alternatives.
2. Two disclosed sites sharing a name or pixel remain individually selectable. An ambiguous click or query cannot silently choose one. Type filters behave consistently on the map, search and manual picker.
3. An exact known site can open a preview. A partial clue shows authorized precision only. Hidden sites never appear in results, autocomplete or exact travel previews. Preview and search grant no discovery.
4. An authorized journal shortcut targets its own stable ID even when another site shares its localized name. If a temporary exact grant ends before confirmation, travel is unavailable unless another active grant preserves exact disclosure.
5. Selection and preview spend no gold, advance no time and move no actor. Restoring or redrawing the travel UI cannot confirm travel or expose stale results. A modded presentation preserves these same authority checks.

## Consistency review and outstanding dependencies

The specification fits WORLD-014 stable identity and disclosure precision, QUEST-014/018 authorized journal context, CORE-018 owner-controlled entry, and TIME-002 separation of preview from time advancement. Exact filter taxonomy, localization and alias rules, search bounds, mod UI extension contracts, and travel quote and commitment rules remain owner dependencies.
