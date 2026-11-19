# WORLD-014 — Location discovery

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Remember the places a character learns about through exploration, clues and authorized services. Record only the precision the source grants. Towns that share a map pixel can be discovered independently, and revisiting or loading preserves what the character already knows.

## Confirmed requirements

- **WORLD-014-D01.** Eligible entry into an ordinary settlement grants a permanent exact mark. A committed teleport can qualify. Hidden sites follow their authorized reveal policies. Nearby passage, streaming and load alone grant no discovery. Mods can define entry eligibility and reveal precision.
- **WORLD-014-D02.** Stock random reveals select uniformly among authorized sites in the source's declared area for which the character lacks a current exact mark. Partial clues leave a site eligible. Retain the selected site on retry and report exhaustion. Mods can define other pools and weights.
- **WORLD-014-D03.** Apply authored defaults at character creation. When a supported content change adds a site to an existing character, use normal discovery triggers unless an explicit, supported reveal rule grants discovery.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-014-interview-decisions) records the interview decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

Static inspection of the local DFU 1.1.1 snapshot. In `Assets/Scripts/Internal/PlayerGPS.cs`, `DiscoverCurrentLocation` requires a loaded location and records discovery keyed by map pixel ID. `DiscoverLocation` resolves a named location through its region and name, then records it by pixel ID. `DiscoverRandomLocation` samples uniformly from locations in the current region that have neither the authored discovery flag nor a recorded discovery, and returns an empty location when exhausted. Guild reveal services and an inventory map path call it. DATA-004 documents the remaining verification of classic initial discoveries.

## Detailed rules and behaviors

1. Store per-character discovery against stable location identity. Distinguish disclosure precision and source, including independent permanent and temporary grants. Present only the precision the active grants authorize. An eligible exact grant makes that site known without revealing other sites that share its pixel.
2. Apply validated authored defaults when initializing a new character. Use WORLD-013 committed entry and any declared discovery area to evaluate exploration eligibility. Ordinary eligible settlement entry grants a permanent exact mark. Successful teleport can qualify through committed endpoints. Hidden or restricted sites use their declared authorization. A proximity check, restored presence or scene activation alone does not reveal a site.
3. Resolve explicit disclosures by stable site identity and validate their authorization and precision under QUEST-014 and the source owner. Preserve independent grants when a temporary mark is removed. A partial clue may coexist with a later exact reveal. Retrying the same committed disclosure reuses its outcome.
4. For a stock random reveal, snapshot the eligible set in the declared area at selection. Include only sites that the source may reveal and that lack a currently effective exact mark, including sites with partial clues. Select once and retain the target for the operation. If a retained target becomes unavailable, return an owner-handled result without silently selecting another site. A new authorized operation can evaluate the current pool. Report exhaustion explicitly.
5. A supported content change preserves valid prior discoveries and stable site references. Newly added sites use their normal triggers unless a validated policy explicitly grants a reveal to the existing character. Validate changed or missing definitions with DATA and SAVE. Map visibility uses the effective authorized precision.

## Relevant formulas, parameters and configuration

For a stock random pool of size N greater than zero, each eligible site has probability 1/N. An empty pool returns exhaustion. Mods can define validated area, eligibility, precision, duration and weighting rules. The source owner controls any payment, item use or consequence associated with an exhausted or failed reveal.

## Required data

Character and site IDs, current content definitions, authored defaults and reveal policies, disclosure source and precision, applicable retention and expiry, committed entry or reveal identity, and the retained selection and outcome for supported unresolved operations.

## Inputs, outputs and events

- **Inputs** — Character initialization, committed boundary facts, authorized explicit or random reveal requests, retention changes and validated content or restore context.
- **Outputs** — Effective known precision, committed discovery or unchanged result, retained random target, exhaustion or explicit failure.
- **Events** — Publish changes after authoritative commitment. Consumer redraw, lookup and retry cannot grant or duplicate discovery.

## Cross-system interactions

WORLD-012/013 provide geographic context and committed boundaries. DATA-004, WORLD-006 and MOD provide stable identities and validated content. QUEST-014, NPC and item or service owners authorize disclosure and its consequences. RULE supplies retained randomness. UI renders the authorized precision. CORE/SAVE coordinate native restore and compatibility.

## Edge cases and failure conditions

- Same-pixel locations, duplicate names and moved sites resolve by stable ID.
- Check hidden sites, partial clues, temporary exact marks and multiple independent sources. Removing one grant preserves other grants still in effect.
- Check empty pools, repeated requests and target invalidation after selection. Retry cannot reroll or repeat a committed source consequence.
- Check restored presence, failed teleport and supported mod additions to an existing save. Each reveals only through authorized triggers.

## Save/load considerations

Persist committed discovery grants, applicable temporary state and supported retained operations through SAVE and source owners. Rebuild effective precision from restored state. Load does not reapply new-character defaults or replay entry, payment or source effects. Missing or changed sites use validated mapping or the applicable recovery policy.

## Technical constraints

Target Godot 4.7.2. Stable location identity is independent of display name, pixel and scene residency. Validate source authorization and commit discovery coherently with supported owner operations. Exact schema, APIs and compatibility mechanics remain open.

## Acceptance criteria

1. Eligible entry grants a permanent exact mark for the specific site. Hidden sites, proximity, streaming and native load obey their declared reveal rules.
2. A stock random reveal samples only eligible sites without exact marks. Partial clues remain eligible, exhausted pools are explicit, and retry retains the chosen site.
3. A temporary mark can be removed without losing an independent permanent discovery. Same-pixel sites remain separately discoverable.
4. A new character receives validated defaults. An existing character learns a mod-added site only through a normal trigger or explicit supported grant.
5. Native restoration preserves authorized precision and committed outcomes without replay.

## Outstanding questions

- Verify stock initially known sites and site-specific reveal rules against representative content.
- Define discovery grant schemas, source ownership and map presentation for partial or same-pixel discoveries.
- Define mod policy validation and pending reveal compatibility with RULE, DATA and SAVE.
