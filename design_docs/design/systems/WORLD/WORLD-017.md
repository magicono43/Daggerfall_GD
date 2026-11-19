# WORLD-017 — Nearby object queries

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Provide reliable proximity information to detection effects, enchantments and other local systems. Passive indicators can refresh periodically. Gameplay effects use current eligible targets, with concealment, targeting and disclosure governed by the feature that uses the query.

## Confirmed requirements

- **WORLD-017-D01.** Allow periodic observations for passive indicators. Check current results before committing gameplay effects, interactions or target selection. Support moddable freshness profiles.
- **WORLD-017-D02.** Each feature declares its query scope and requires live, eligible subjects under that scope. A terrain seam alone does not break valid coverage. Stock detection excludes unloaded subjects and other interiors. Support validated mod-defined scopes and eligibility.
- **WORLD-017-D03.** Relevant owners supply or validate classifications. WORLD provides proximity facts and the requesting feature controls sensing, presentation and targeting. Support mods that add or change classifications, sensing and disclosure policy under those owner contracts.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-017-interview-decisions) records the interview decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 release snapshot. In `Assets/Scripts/Internal/PlayerGPS.cs`, `UpdateNearbyObjects` refreshes a list of registered enemies, mobile civilians and loot containers at roughly 0.33-second intervals. It records 3D distance and category flags. `GetNearbyObjects` filters by all requested flags, strict range and hierarchy activity. `GetEntityFlags` classifies enemy groups, humanoids and actors with active effects. `GetLootFlags` marks nonempty containers as treasure. Detect Enemy, Detect Magic, Detect Treasure and several enchantments call the query.

## Detailed rules and behaviors

1. Bind requests to a valid origin, active context and declared query scope. Resolve candidates by live owner identity. Apply the requested category, range and eligibility against a coherent coordinate frame. A valid path across a terrain seam can still query eligible subjects in the same scope. Adjacent towns sharing a pixel and distinct interiors are evaluated under the feature's scope rules.
2. Passive consumers may reuse observations within their declared freshness policy. An authoritative query at a gameplay commitment boundary must account for current membership, position, eligibility and owner state, including subjects that newly qualify. Revalidate conditions needed by the action before commitment. Changes such as removal, unloading or session replacement invalidate incompatible observations even within a normal refresh interval.
3. NPC, ITEM, MAGIC and other applicable owners supply or validate category and eligibility facts. A candidate may qualify for several categories. Mod profiles may define classification, filter matching, scope and freshness behavior within supported contracts. A profile that uses cached observations still requires current validation at an authoritative commitment.
4. Return proximity facts to authorized consumers. The requesting feature owns visibility, through-wall sensing, access, target legality and what information the player receives. Stock MAGIC-025 detection retains its loaded scope, category rules, strict range and compass disclosure. A nearby query alone grants no discovery, exact inventory disclosure, line of sight or attack permission.
5. Cache or index candidates as needed, with observations tied to session, context and applicable frame. Keep unavailable required coverage distinguishable from a valid empty result. Retirement, despawn, pickup and rebasing cannot expose stale subjects or duplicate matches.

## Relevant formulas, parameters and configuration

Stock MAGIC-025 detection uses 3D distance strictly below 14 reference units, subject to native-scale fixtures. Other features declare their range, metric and boundary behavior. Supported mod profiles may configure refresh cadence, acceptable observation age for passive use, scope, range, eligibility, classification and authorized disclosure. DFU's refresh interval is a reference value. Each feature retains its approved gameplay defaults.

## Required data

Request origin and coordinate frame, session and query scope, category and range filters, owner identities, current positions and eligibility, observation time or revision, applicable policy and required coverage status.

## Inputs, outputs and events

- **Inputs** — Request and declared use, resolved policy, live registry and owner state, location and frame, and lifecycle invalidations.
- **Outputs** — Matching live subject references with authorized proximity observations and freshness provenance, valid empty result, or explicit unavailable or invalid result.
- **Events** — Registry and context changes can invalidate observations. Detection, targeting and reveal events remain with requesting owners. Public APIs remain open.

## Cross-system interactions

WORLD-001/002 provide position and coherent origin shifts. WORLD-004/006/007 and LOC provide readiness, activation and scope. NPC and ITEM supply actor and loot facts. MAGIC-025 owns stock detection and compass disclosure. MOVE, COMBAT and interaction owners validate actions. MOD and DATA validate extensions. CORE/SAVE coordinate restoration.

## Edge cases and failure conditions

- Test a subject entering range after a passive observation, an emptied container, a dead or unloaded actor and a superseded context.
- Test an exact range boundary, stacked floors, different interiors and an outdoor seam. Apply the requesting profile's metric and scope.
- Test through-wall detection with ordinary targeting still gated by its owner. Confirm hidden map geometry and loot details stay undisclosed.
- Test modded scope, category and freshness profiles. Reject invalid required definitions explicitly and apply current validation before commitment.

## Save/load considerations

Rebuild indexes and observations from restored context and active owner records. Save supported effect, interaction and disclosure state through its owner. Cached proximity results and live handles are runtime data. Load alone produces no discovery or gameplay commitment.

## Technical constraints

Target Godot 4.7.2. Measure query cost and refresh latency with representative actors and objects. Keep authoritative validation coherent with lifecycle and frame changes. Exact indexing, identifiers, policy extension interfaces and scheduling budgets remain open.

## Acceptance criteria

1. Passive observations can refresh periodically. Gameplay commitment checks the current eligible set, including newly eligible and removed subjects. Mod freshness settings preserve this boundary.
2. Stock detection includes eligible loaded subjects across a valid terrain seam and excludes other interiors and unloaded subjects. Validated mods can supply other supported live scopes.
3. Owner classifications can be extended through validated mod policies. Stock MAGIC-025 maintains its approved radius, through-wall sensing and compass disclosure.
4. Queries neither discover places nor authorize attacks. Scope replacement, rebasing and retirement cannot supply stale targets.
5. Restore rebuilds observations from current live state while preserving supported owner state without replay.

## Outstanding questions

- Define stock passive freshness budgets and measure query cost.
- Specify scope boundaries, classification and filter formats, and the mod extension interface with the applicable owners.
- Verify native range scaling, readiness and authoritative timing with representative detection and action fixtures.
