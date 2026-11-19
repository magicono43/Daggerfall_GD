# FACT-001 — Faction identity and hierarchy

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-001-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-001-interview-decisions).

## Gameplay purpose and intended player experience

Resolve the faction an actor represents and the wider organization it belongs to. A player can deal with a local chapter, a regional court, or an independent merchant and have dialogue, work offers, and services use the appropriate context. A quest keeps the faction it was authorized to act for even if the player travels or the faction is renamed.

## Confirmed requirements

- Preserve DFU's placed NPC defaults for supported classic imports. New and modded NPCs can name a faction, explicitly inherit an authorized building or regional role, or be explicitly unaffiliated. A broken explicit reference fails. See FACT-001-D01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-001-interview-decisions).
- Return the resolved faction and its wider organizational context separately. Dialogue uses the organizational context where its reaction rules call for it. Quests and services use their explicitly authorized faction. See FACT-001-D02 in the same log.
- Preserve stable IDs, explicit classic mappings, separate authored and live state, and validated acyclic parent links with derived children. See [DATA-009](../DATA/DATA-009.md).

## Existing Daggerfall Unity behavior

Source paths refer to the local DFU 1.1.1 snapshot under `Assets/Scripts/`.

- `API/FactionFile.cs#Load` reads FACTION.TXT. `RelinkChildren` builds child links from numeric parent references. `Game/Player/PersistentFactionData.cs#AddCustomFactions` adds registered factions with unused IDs.
- `PersistentFactionData.GetFactionData` reports whether an ID resolves and localizes the returned name. `FindFactions` can return several matches by type, social group, guild group, and region. The separate `FindFactionByTypeAndRegion` returns the first exact match or the last matching type with region −1.
- `PersistentFactionData.GetParentGroupFaction` checks the starting faction and then walks up until it reaches a Group, Province, Temple, or root. `Game/TalkManager.cs#TalkToMobileNPC` uses regional People. `GetStaticNPCFactionData` uses regional Court for an unset palace faction and for generic rulers, nobles, and knights. Other unset placed NPCs use regional People.

## Rules and behaviors

1. Resolve exact references by stable faction ID. Display names can be shared or localized. Authored queries may filter by classification and region and return every match. Names and result order carry no authority to select a gameplay target.
2. Validate a forest of explicit roots and single parent links under DATA-009. Expose direct parent, children, and ancestry separately from the organizational result. A successful lookup may return the same ID for the actor faction and its organization when the actor already represents that organization. Parenthood alone grants no membership, standing change, service access, or authority to act for another faction.
3. For imported placed NPCs, translate the unset and generic nobility cases through the classic adapter. Preserve other explicit references. For new or modded records, resolve the declared faction mode. Building inheritance uses the authorized establishment context. Regional inheritance uses the region attached to the interaction or actor context. Ordinary wandering civilians use regional People under NPC-017. An explicit unaffiliated mode is a valid result.
4. Resolve the actor faction separately from the organization and from the faction authorized for the current quest or service. Capture the relevant IDs at the consumer's established binding point. Revalidate that same context before a consequential action under the consumer's rules. Crossing a regional border or encountering a new parent does not transfer an existing quest or service obligation.

## Approved defaults

- For each required single-result regional role, including People wherever ordinary civilian dialogue requires it and Court wherever an applicable classic import requires it, require exactly one binding per region in the resolved content. An optional unused role may be absent. Ordinary searches can return multiple factions. Validate conflicts after explicit DATA-003 overrides and report the relevant role, region, and source contributions.
- For DFU-style dialogue, use the nearest qualifying Group, Province, or Temple, including the starting faction, with the root as the stopping point if none qualifies. This supplies the context for NPC-018. That feature determines whether the resolved organization affects the actual reaction or greeting. A quest or service may deliberately authorize the wider organization through its own rules.

## Required data and parameters

Use stable faction and region IDs, classic numeric mappings, display names and localization references, faction types and classifications, explicit parent or root, derived child lists, regional role bindings, authorized establishment references, and actor affiliation declarations. Keep source provenance for diagnostics. Resolution uses role, classification, and ancestry checks. Reputation formulas, thresholds, alliance capacities, and guild rank rules belong to their respective features.

## Inputs, outputs, and events

Inputs include an exact ID, filters, or a declared actor affiliation with the applicable actor, region, establishment, and interaction context. Outputs include an exact record, a collection of matches, parent and organization results, or a contextual resolution outcome. Distinguish resolved affiliation, intentional absence, and invalid required context. Queries read state without emitting gameplay changes. DATA and CORE publish readiness under their existing contracts. Consumers own interaction, quest, service, and standing events.

## Cross-system interactions

- DATA-003/009 and MOD govern contributions, validated publication, and definitions. FACT supplies resolution and owns mutable faction state with the relevant FACT features.
- NPC-017 supplies the actor and interaction context. NPC-018 uses applicable faction and group context for reaction and greetings. NPC-004 and NPC-023 distinguish the actor from the establishment and its authorized providers.
- QUEST-002/008 use the authorized giver and faction for eligibility and activation. A missing required faction follows the owning feature's failure handling. ECON and guild services keep service entitlement and fulfillment with their owners. LAW owns regional legal standing.

## Edge cases and failure conditions

- Duplicate IDs, ambiguous classic mappings, missing required parents, self-parenting, and cycles fail validation under DATA-009. An explicit root is valid. Rebuilding indexes derives each child link afresh.
- A missing explicit faction, or a missing or ambiguous required regional role, produces a clear failure. A valid unaffiliated actor can use any dialogue or service its owner permits without faction context.
- A generic lookup returning several matches leaves selection to an authorized caller with a defined selection rule. This prevents a duplicate regional entry from silently redirecting quest rewards or reaction checks.
- An actor changing location or staff changing at a building can affect a new interaction. An existing authorized obligation keeps its recorded context and follows its owner's revalidation and recovery rules.

## Configuration and balancing options

Content may configure affiliation modes, role bindings, and hierarchy through validated contributions. Classic default mappings belong to the import adapter. Reputation effects of affiliation or ancestry are set by the features that use those inputs.

## Save/load considerations

Store stable IDs for durable faction bindings where the owning feature persists them. Rebuild derived hierarchy indexes from validated definitions. Preserve recorded quest and service context under owner contracts. A removed or incompatible required faction uses an explicit supported migration or recovery, or reports a compatibility failure under DATA-009 and SAVE. Resolve durable references independently of scene residency.

## Technical constraints and consistency review

Publish coherent definitions before resolving gameplay context. Keep classic sentinels and region numbering in the adapter and use stable region IDs in gameplay. Keep the definition hierarchy separate from mutable alliances, membership, and standings. The draft carries forward DATA-009 validation and compatibility, NPC-017 regional People and service-origin context, NPC-018 reaction ownership, and QUEST-002/008 authorized giver and faction binding. Review found no contradictions with those approved rules.

## Acceptance criteria

1. A renamed or localized faction keeps its ID, hierarchy, and saved references. Two factions with the same display name remain distinct.
2. Imported palace NPCs with unset faction and imported generic rulers, nobles, and knights resolve to regional Court. Other imported placed NPCs with unset faction and ordinary wandering civilians resolve to regional People.
3. An authored actor can use each declared affiliation mode. Intentional unaffiliation and a broken explicit reference produce different outcomes.
4. Rebuilding a valid hierarchy produces the same children. Missing required parents and cycles fail validation. A chapter and its organization resolve separately, and an authorized chapter quest retains the chapter across travel and reload.
5. A required regional role has one binding. Missing or conflicting bindings fail clearly, and a general filtered search can still return multiple results.
6. Loading with a removed required faction invokes supported migration or recovery, or reports a compatibility failure without redirecting the saved binding.

## Outstanding questions

Exact ID encoding, the complete imported role mapping and baseline verification, and migration mechanics remain technical dependencies under DATA and SAVE. Reputation propagation, political relationships, and service entitlement remain separate feature decisions.
